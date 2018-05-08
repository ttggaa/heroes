--
-- Author: <ligen@playcrab.com>
-- Date: 2017-02-08 20:11:42
--
local HeroDuelFeatureView = class("HeroDuelFeatureView", BasePopView)
function HeroDuelFeatureView:ctor(data)
    HeroDuelFeatureView.super.ctor(self)

    self._callBack = data and data.callBack or nil
end

function HeroDuelFeatureView:onInit()
    self:registerClickEventByName("bg", function()
        if self._callBack then
            self._callBack()
        end
        self:close()
    end)

    self:getUI("bg.layer.closeBtn"):setVisible(false)

    local featureId = tab:HeroDuel(self._modelMgr:getModel("HeroDuelModel"):getWeekNum()).char1
    local featureData = tab:HeroDuelSelect(featureId)
    local featureImg = cc.Sprite:create("asset/bg/heroDuel/" .. featureData.image2 .. ".png")
    featureImg:setPosition(480,320)
    self:getUI("bg.layer"):addChild(featureImg)
end

return HeroDuelFeatureView