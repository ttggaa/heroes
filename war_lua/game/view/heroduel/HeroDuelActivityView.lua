--
-- Author: <ligen@playcrab.com>
-- Date: 2017-08-03 21:25:53
--
local HeroDuelActivityView = class("HeroDuelActivityView", BasePopView)
function HeroDuelActivityView:ctor(data)
    HeroDuelActivityView.super.ctor(self)
end

function HeroDuelActivityView:onInit()
    self:registerClickEventByName("bg", function()
        self:close()
        UIUtils:reloadLuaFile("heroduel.HeroDuelActivityView")
    end)

    local closeBtn = self:getUI("bg.layer.closeBtn")
    self:registerClickEvent(closeBtn, function()
        self:close()
        UIUtils:reloadLuaFile("heroduel.HeroDuelActivityView")
    end)
    closeBtn:setPositionX(closeBtn:getPositionX() + (MAX_SCREEN_WIDTH - MAX_DESIGN_WIDTH) / 2)

    local scaleNum = MAX_SCREEN_WIDTH/1022
    scaleNum = scaleNum >= 1 and scaleNum or 1
    local activityImg = cc.Sprite:create("asset/uiother/heroduel/activity_heroduel.jpg")
    activityImg:setPosition(480,320)
    activityImg:setScale(scaleNum)
    self:getUI("bg.layer"):addChild(activityImg)

    SystemUtils.saveAccountLocalData("showHDuelActivity", 1)
end

return HeroDuelActivityView