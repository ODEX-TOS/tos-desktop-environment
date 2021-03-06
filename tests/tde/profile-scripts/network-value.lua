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
-- This file tries to get a single cpu usage value
-- It is used to get to know how much time it takes to gain information about the cpu

require("lib-tde.luapath")
local filehandle = require("lib-tde.file")
local sleep = require("lib-tde.function.common").sleep
local common = require("lib-tde.function.common")

local biggest_upload = 1
local biggest_download = 1

local last_rx = 0
local last_tx = 0

local interface = filehandle.string("/tmp/interface.txt"):gsub("\n", "")

local function _draw_results(download, upload)
    if download > biggest_download then
        biggest_download = download
    end

    if upload > biggest_upload then
        biggest_upload = upload
    end

    local download_text = common.bytes_to_grandness(download)
    local upload_text = common.bytes_to_grandness(upload)

    print("Network download: " .. download_text)
    print("Network upload: " .. upload_text)
end

function get_network_usage()
    -- sanitizing the interface
    if interface == nil then
        interface = filehandle.string("/tmp/interface.txt"):gsub("\n", "")
        return
    end

    local valueRX = filehandle.string("/sys/class/net/" .. interface .. "/statistics/rx_bytes"):gsub("\n", "")
    local valueTX = filehandle.string("/sys/class/net/" .. interface .. "/statistics/tx_bytes"):gsub("\n", "")

    valueRX = tonumber(valueRX) or 0
    valueTX = tonumber(valueTX) or 0

    local download = math.ceil((valueRX - last_rx))
    local upload = math.ceil((valueTX - last_tx))

    if not (last_rx == 0) and not (last_tx == 0) then
        _draw_results(download, upload)
    end
    last_rx = valueRX
    last_tx = valueTX
end

get_network_usage()
sleep(1)
get_network_usage()
