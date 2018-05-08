--[[
    Filename:    SpineManager.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-07-28 16:47:49
    Description: File description
--]]

local SpineManager = class("SpineManager")
local cc = cc
local tc = cc.Director:getInstance():getTextureCache()
local ALR = pc.PCAsyncLoadRes:getInstance()

local _SpineManager = nil

function SpineManager:getInstance()
    if _SpineManager == nil then 
        _SpineManager = SpineManager.new()
        return _SpineManager
    end
    return _SpineManager
end

function SpineManager:ctor()
    -- clear的时候根据reference来决定是否释放资源
    -- loadRes并不会增加reference, 只有create mc的时候才会增加
    self._reference = {}
end
-- initUpdate() 初始化后调用，否则则会在下一帧才渲染
-- animPause() 暂停
-- animResume() 继续播放
local tc = cc.Director:getInstance():getTextureCache()
local fu = cc.FileUtils:getInstance()
function SpineManager:createSpine(name, callback)

    local function init()
        local spine = sp.SkeletonAnimation:create("asset/spine/"..name..".json", "asset/spine/"..name..".atlas")
        -- spine:setColor(cc.c3b(80, 80, 80))
        -- spine:runAction(cc.TintTo:create(0.2, 255, 255, 255))
        spine:setTimeScale(0.9)
        spine:registerScriptHandler(function (state)
            if state == "enter" then
                if self._reference[name] == nil then
                    self._reference[name] = 1
                else
                    self._reference[name] = self._reference[name] + 1
                end
            elseif state == "exit" then
                self._reference[name] = self._reference[name] - 1
            end
        end)
        spine:registerSpineEventHandler(function (event)  
            if spine.endCallback then
                spine:endCallback()
            end
        end, 2)  
        if callback then
            callback(spine)
        end
    end
    if tc:getTextureForKey("asset/spine/"..name..".png") then
        init()
    else
        local task = pc.LoadResTask:createImageTask("asset/spine/"..name..".png", RGBAUTO)
        task:setLuaCallBack(function ()
            ScheduleMgr:delayCall(0, self, function()
                init()
            end)
        end)
        ALR:addTask(task) 
    end
end

function SpineManager:clear()
    for name, reference in pairs(self._reference) do
        if reference <= 0 then
            tc:removeTextureForKey("asset/spine/".. name ..".png")
        end
    end
end

function SpineManager.dtor()
    _SpineManager = nil
    cc = nil
    SpineManager = nil
    tc = nil
    fu = nil
    ALR = nil
end

return SpineManager