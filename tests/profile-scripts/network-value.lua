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
