--[[
    Filename:    ViewManager.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-05-05 18:31:56
    Description: File description
--]]
local luaprofiler = 0

local function profilerbegin()
    if luaprofiler ~= 1 then return end
    require "utils.profiler.luaprofiler"
    profiler:start()
    filename = cc.FileUtils:getInstance():getWritablePath() .."/profile.txt"
end

local function profilerend()
    if luaprofiler ~= 1 then return end
    profiler:stop()
    local outfile = io.open(filename, "w+") 
    profiler:report(outfile)
    outfile:close()
end

-- 战斗复盘测试
profilerbegin()
require "battle"
BATTLE_PROC_TEST = true

local count = 1
if luaprofiler == 1 then count = 1 end
for i = 1, count do
    local tick = os.clock()
    run(13, "test")
    print(os.clock() - tick)
end
profilerend()