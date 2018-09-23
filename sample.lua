-----------------------------------------------
-- Sample of SlibBME280.lua for W4.00.03
-- Copyright (c) 2018, Saya
-- All rights reserved.
-- 2018/09/20 rev.0.04
-----------------------------------------------

local script_path = function()
	local  str = debug.getinfo(2, "S").source:sub(2)
	return str:match("(.*/)")
end

-- main
local myDir  = script_path()
local libDir = myDir.."lib/"
local sensor = require(libDir .. "SlibBME280")
local sensor_sadr = 0x76
local sea_lvl_press = 1013.25

-- setup sample---------
-- Normal mode
-- Tstandby 0.5[ms]
-- Filter off
-- All oversampling x16
------------------------
local csv_text
local res = sensor:setup(sensor_sadr, 400, 3, 0, 4, 2, 1, 5)
--local res = sensor:setup()
--local res = sensor:setup{sadr=sensor_sadr, frq=400, mode=3, t_sb=0, filter=4, osrs_t=2, osrs_p=1, osrs_h=5}

local res, temp, humi, pres, alti, thi = sensor:readData(sea_lvl_press)

if res=="OK" then
	csv_text = string.format( "%8.2f,%8.2f,%8.2f,%8.2f,%8.2f\n",temp, humi, pres, alti, thi)
else
	csv_text = res
end

local file_path = string.format( myDir .. "sample.csv" )
local fh = io.open(file_path, "a+")
fh:write(csv_text .. "\n")
fh:close()

return
