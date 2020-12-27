--[[
--MIT License
--
--Copyright (c) 2019 manilarome
--Copyright (c) 2020 Tom Meyers
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.
]]
-- vim: st=4 sts=4 sw=4 et:
--- Main Sentry reporting module.
-- This module contains the core of the reporting logic, it still depends on a
-- network layer to actually send the data to the Sentry server.
--
-- @module TDE
-- @copyright 2014-2017 CloudFlare, Inc.
-- @license BSD 3-clause (see LICENSE file)

local util = require("lib-tde.sentry.util")
local filehandle = require("lib-tde.file")
local cjson = require("cjson")

local _M = {}
_M._VERSION = util._VERSION

local debug_getinfo = debug.getinfo
local table_insert = table.insert
local unpack = unpack or table.unpack -- luacheck: ignore
local generate_event_id = util.generate_event_id
local iso8601 = util.iso8601
local json_encode = cjson.encode

local catcher_trace_level = 4

--- Table describing main Sentry client settings.
-- @field sender Object used to send message, see `rave.senders.*` modules to
--  find a sender suitable with your application
-- @field level  Set the message level (string), defaults to `"error"`
-- @field logger Sets the message logger (string), defaults to `"root"`
-- @field tags   Defaults tags for sent messages, defaults to `{}`. Example:
--  `{ "foo"="bar", ... }`
-- @field extra  Default extra data sent with messages, defaults to `{}`
-- @field release  Sets the release id for message, defaults to `SENTRY_RELEASE`
-- @table sentry_conf

local TDE_mt = {}
TDE_mt.__index = TDE_mt

-- utility function to deal errors, xpcall and stack traces

-- This metatable is associated with returned error object so the original
-- error message is returned when tostring is invoked on it. This allows to use
-- the error objects for logging purposes as well. This is mostly a workaround
-- of xpcall error handlers having a single result.
local err_mt = {
    __tostring = function(self)
        return self.message
    end
}

-- return a string detailing the function running at a stack level
local function get_culprit(level)
    local culprit

    level = level + 1
    local info = debug_getinfo(level, "Snl")
    if info.name then
        culprit = info.name
    else
        culprit = info.short_src .. ":" .. info.linedefined
    end

    return culprit
end

-- return the line, pre and post line information
local function fileinfo(file, lineno)
    if not filehandle.exists(file) then
        return nil, nil, nil
    end

    local size = 12

    local lines = filehandle.lines(file)

    local line = lines[lineno]

    local pre
    local post

    if lineno < size then
        pre = {table.unpack(lines, 1, lineno - 1)}
    else
        pre = {table.unpack(lines, lineno - size, lineno - 1)}
    end

    if (lineno + size) > #lines then
        post = {table.unpack(lines, lineno + 1, #lines)}
    else
        post = {table.unpack(lines, lineno + 1, lineno + size)}
    end

    return line, pre, post
end

-- it is in app if the filename is not /usr/share/awesome
local function isInApp(filename, index)
    local find = "/usr/share/tde"
    local result = not (filename:sub(1, #find) == find)
    index = index or ""
    print(filename .. ":" .. tostring(index) .. " IsInApp: " .. tostring(result))
    return result
end

-- returns if the given file is a plugin or not
local function isInPlugin(filename)
    -- find the base plugin directory
    local basePluginDir = os.getenv("HOME") .. "/.config/tde/"
    return filename:sub(1, #basePluginDir) == basePluginDir
end

local function validateSourceFile(source)
    if source:sub(1, 1) == "@" then
        return source:sub(2, #source)
    end
    return ""
end

local function backtrace(level)
    local frames = {}

    level = level + 1
    local isPlugin = false
    while true do
        -- +3 is done because we offset the stacktrace by 3 function (all of which are used to log the error and are not related to the error itself)
        local info = debug_getinfo(level + 3, "Snl")
        if not info then
            break
        end

        local filename = validateSourceFile(info.source)

        if isInPlugin(filename) then
            isPlugin = true
        end

        local line, pre, post = fileinfo(filename, info.currentline)
        table_insert(
            frames,
            1,
            {
                filename = filename,
                ["function"] = info.name,
                lineno = info.currentline,
                context_line = line,
                pre_context = pre,
                post_context = post,
                in_app = isInApp(filename, info.currentline)
            }
        )

        level = level + 1
    end
    print("Is in plugin?: " .. tostring(isPlugin))
    return {frames = frames}, isPlugin
end

-- error_catcher: used to catch an error from xpcall and return a correct
-- error message
local function error_catcher(err)
    local trace, _ = backtrace(catcher_trace_level)
    return {
        message = err,
        culprit = get_culprit(catcher_trace_level),
        exception = {
            {
                value = err,
                stacktrace = trace
            }
        }
    }
end

-- a wrapper around error_catcher that will return something even if
-- error_catcher itself crashes
local function capture_error_handler(err)
    local ok, json_exception = pcall(error_catcher, err)
    if not ok then
        -- when failed, json_exception is error message
        util.errlog("failed to run exception catcher: " .. tostring(json_exception))
        -- try to return something anyway (error message with no culprit and
        -- no stacktrace
        json_exception = {
            message = err,
            culprit = "???",
            exception = {{value = err}}
        }
    end
    return setmetatable(json_exception, err_mt)
end
_M.capture_error_handler = capture_error_handler

--- Create a new Sentry client.
-- It takes a @{sentry_conf} table tune its behavior.
-- @param conf client configuration.
-- @return     a new TDE instance
-- @usage
-- local TDE = require "TDE"
-- local rvn = TDE.new {
--    sender = require("TDE.senders.luasocket").new {
--       dsn = "http://pub:secret@127.0.0.1:8080/sentry/proj-id",
--    },
--    tags = { foo = "bar", abc = "def" },
--    logger = "foo",
--    release = "879939692a0c3bdbd1662fd666477f4248290da0",
--    environment = "staging"
-- }
function _M.new(conf)
    local obj = {
        sender = assert(conf.sender, "sender is required"),
        level = conf.level or "error",
        logger = conf.logger or "root",
        release = conf.release or os.getenv("SENTRY_RELEASE"),
        environment = conf.environment or os.getenv("SENTRY_ENVIRONMENT"),
        tags = conf.tags or nil,
        extra = conf.extra or nil
    }

    return setmetatable(obj, TDE_mt)
end

--- This method is reponsible to return the `server_name` field.
-- The default implementation just returns `"undefined"`, users are encouraged
-- to override this to something more sensible.
function _M.get_server_name()
    return os.getenv("USER")
end

local function merge_tables(msg, root)
    if not root then
        return msg
    elseif not msg then
        return root
    end

    -- both table exist, merge root into msg
    for k, v in pairs(root) do
        msg[k] = msg[k] or v
    end
    return msg
end

--- This table can be used to tune the message reporting.
-- @field tags Tags for the message, they will be coalesced with the ones
--  provided in the @{sentry_conf} table used in the constructor if any. In
--  case of conflict, the message tags have precedence.
--
-- @field extra Extra data for the message. Like tags, data is merged with
--  the extra data passed to the constructor.
--
-- @field trace_level Starting stack level for the report (can be used to skip
--  useless frames. The internal TDE frames are automatically skipped, so a
--  level of `1` is means that the direct caller will be reported as culprit.
--
-- @table report_conf

--- A TDE client instance is responsible to collect events and send them
-- using the associated sender object.
-- @type TDE

--- Send an exception to Sentry.
-- See [reference](https://docs.sentry.io/clientdev/interfaces/exception/).
-- Note that the stack trace will be filled automatically.
--
-- Note that the `conf` table will be modified by the function, therefore it
-- is not safe to reuse conf table across calls. Consider passing common
-- attributes to the client constructor instead.
--
-- @function TDE:captureException
-- @param exception  a table describing the exception conforming to the Sentry
--  format described in the reference docs
-- @param conf       capture configuration table, see @{report_conf}
-- @return           On success, return event id. If not success, return nil and
--  an error string.
-- @usage
-- local rvn = TDEnew(...)
-- local exception = { { -- beware, exceptions are arrays
--    type = "SyntaxError",
--    value = "Wattttt!",
--    module = "mymodule",
--    -- stacktrace is populated automatically
-- } }
-- local id, err = rvn:captureException(exception,
--     { tags = { foo = "bar", abc = "def" }})
function TDE_mt:captureException(exception, conf)
    local trace_level
    if not conf then
        conf = {trace_level = 2}
    elseif not conf.trace_level then
        conf.trace_level = 2
    else
        conf.trace_level = conf.trace_level + 1
    end

    trace_level = conf.trace_level
    local trace, plugin = backtrace(trace_level)

    if plugin then
        conf.tags = merge_tables({application_type = "plugin"}, conf.tags)
    else
        conf.tags = merge_tables({application_type = "tde-main"}, conf.tags)
    end

    exception[1].stacktrace = trace

    local payload = {
        exception = exception,
        message = exception[1].value,
        culprit = get_culprit(trace_level)
    }

    -- because whether tail call will or will not appear in the stack back trace
    -- is different between PUC-lua or LuaJIT, so just avoid tail call
    local id, err = self:send_report(payload, conf)
    return id, err
end

--- Send a message to Sentry.
-- See [reference](https://docs.sentry.io/clientdev/interfaces/message/).
--
-- Note that the `conf` table will be modified by the function, therefore it
-- is not safe to reuse conf table across calls. Consider passing common
-- attributes to the client constructor instead.
--
-- @function TDE:captureMessage
-- @param message the message, usually a raw string
-- @param conf    capture configuration table, see @{report_conf}
-- @return        On success, return event id. If not success, return nil and
--  an error string.
-- @usage
-- local rvn = TDEnew(...)
-- local id, err = rvn:captureMessage("simple message",
--     { tags = { foo = "bar", abc = "def" }})
function TDE_mt:captureMessage(message, conf)
    if not conf then
        conf = {trace_level = 2}
    elseif not conf.trace_level then
        conf.trace_level = 2
    else
        conf.trace_level = conf.trace_level + 1
    end

    local payload = {
        message = message,
        culprit = get_culprit(conf.trace_level)
    }

    local id, err = self:send_report(payload, conf)
    return id, err
end

--- Alias of @{TDE:captureException}.
-- @function TDE:capture_exception
TDE_mt.capture_exception = TDE_mt.captureException

--- Ailas of @{TDE:captureMessage}.
-- @function TDE:capture_message
TDE_mt.capture_message = TDE_mt.captureMessage

--- Send directly a report to Sentry.
-- This is an internal function, you should not call it directly, use
-- @{TDE:captureException} or @{TDE:captureMessage} instead.
--
-- Note that the `conf` table will be modified by the function, therefore it
-- is not safe to reuse conf table across calls. Consider passing common
-- attributes to the client constructor instead.
--
-- @function TDE:send_report
-- @param json table to be sent. Don't need to fill `event_id`, `timestamp`,
--  `tags` and `level`.
-- @param conf capture configuration table, see @{report_conf}
-- @return On success, return event id. If not success, return nil and an
--  error string.
function TDE_mt:send_report(json, conf)
    local event_id = generate_event_id()

    if not json then
        json = self.json
        if not json then
            return
        end
    end

    json.event_id = event_id
    json.timestamp = iso8601()
    json.level = self.level
    json.platform = "lua"
    json.logger = self.logger
    json.release = self.release
    json.environment = self.environment

    if conf then
        json.tags = merge_tables(conf.tags, self.tags)
        json.extra = merge_tables(conf.extra, self.extra)

        if conf.level then
            json.level = conf.level
        end
    else
        json.tags = self.tags
        json.extra = self.extra
    end

    json.server_name = _M.get_server_name()

    local json_str = json_encode(json)
    local ok, err = self.sender:send(json_str)

    if not ok then
        util.errlog("Failed to send to Sentry: ", err, " ", json_str)
        return nil, err
    end
    return json.event_id
end

-- the above two function used to be exposed as method, but there is no reason
-- to do so as they don't need self at the end.

-- Get culprit using given level
function TDE_mt:get_culprit(level) -- luacheck: ignore self
    return get_culprit(level)
end

-- catcher: used to catch an error from xpcall.
function TDE_mt:catcher(err) -- luacheck: ignore self
    return error_catcher(err)
end

--- Call given function and report any errors to Sentry.
-- @function TDE:call
-- @param f     function to be called
-- @param ...   function's arguments
-- @return      the same as @{xpcall}
-- @usage
-- function func(a, b, c)
--     return a * b + c
-- end
-- return rvn:call(func, 1, 'foo', true)
function TDE_mt:call(f, ...)
    -- When used with ngx_lua, connecting a tcp socket in xpcall error handler
    -- will cause a "yield across C-call boundary" error. To avoid this, we
    -- move all the network operations outside of the xpcall error handler.
    local res = {xpcall(f, capture_error_handler, ...)}
    if not res[1] then
        self:send_report(res[2])
        res[2] = res[2].message -- turn the error object back to its initial form
    end

    return unpack(res)
end

--- Return a error handler function to be used with @{xpcall}
-- This is a high performance version of the @{call} method, but it demands
-- some more work to be used. It return a function that will turn a Lua error
-- into a Sentry exception table. It is meant to be used as a @{xpcall} error
-- hander.
--
-- The error handler returns that table, the should then be sent with the
-- @{send_report} method when appropriate. This cannot be easily done in the
-- error handler itself as Lua disallow yielding form an error handler.
--
-- It has better performance than @{call} because it avoid creating temporary
-- objects at each invocation.
--
-- Note that the error table generated by the handler has a `__tostring`
-- metamethod returning the original error message for logging purposes.
--
-- @function TDE:gen_capture_err
-- @usage
-- local handler = rvn:gen_capture_err()
-- local ok, err = xpcall(function() error("boom") end, handler)
-- if not ok then
--    rvn:send_report(err, { tags = { "foo"="bar" } })
-- end
function TDE_mt:gen_capture_err() -- luacheck: ignore self
    return capture_error_handler
end

return _M
