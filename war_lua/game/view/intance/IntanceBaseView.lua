--[[
    Filename:    IntanceBaseView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-11-08 20:49:59
    Description: File description
--]]

local IntanceBaseView = class("IntanceBaseView", BaseMvcs)
require "game.view.intance.IntanceConst"
require "game.view.intance.IntanceUtils" 

function IntanceBaseView:ctor()
    IntanceBaseView.super.ctor(self)
end

function IntanceBaseView:registerTouchEventWithLight(btn, clickCallback)
    local touchX, touchY = 0, 0
    btn:setScaleAnim(false)
    btn:registerScriptHandler(function (state)
        if state == "exit" then
            if self._btnSchedule then
                ScheduleMgr:unregSchedule(self._btnSchedule)
                self._btnSchedule = nil
            end
        end
    end)    
    registerTouchEvent(btn,
        function (sendr, x, y)
            touchX, touchY = x, y
            btn.flashes = 10
            local tempFlashes = 0
            if not self._btnSchedule then
                self._btnSchedule = ScheduleMgr:regSchedule(0.1, self,function( )
                    if btn.flashes >= 30 then 
                        tempFlashes = -5
                    end
                    if btn.flashes <= 10 then
                        tempFlashes = 5
                    end
                    btn.flashes = btn.flashes + tempFlashes
                    btn:setBrightness(btn.flashes)
                end)
            end
            btn.downSp = btn:getVirtualRenderer()
        end,
        function ()
            if btn.downSp ~= btn:getVirtualRenderer() then
                btn:setBrightness(0)
            end
        end,
        function (sendr, x, y)
            if self._btnSchedule then
                ScheduleMgr:unregSchedule(self._btnSchedule)
                self._btnSchedule = nil
            end
            btn:setBrightness(0)
            if math.abs(touchX - x) > 10
                or math.abs(touchY- y) > 10 then 
                return false
            end
            if clickCallback ~= nil then 
                clickCallback()
            end
        end,
        function()
            if self._btnSchedule then
                ScheduleMgr:unregSchedule(self._btnSchedule)
                self._btnSchedule = nil
            end
            btn:setBrightness(0)
        end)
    btn:setSwallowTouches(false)
end

return IntanceBaseView

