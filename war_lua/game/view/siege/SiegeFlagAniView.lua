--
-- Author: <ligen@playcrab.com>
-- Date: 2017-10-14 22:16:34
--
local SiegeFlagAniView = class("SiegeFlagAniView", BasePopView)
function SiegeFlagAniView:ctor(data)
    SiegeFlagAniView.super.ctor(self)
    self._type = data.tipType
    self._callback = data.callbackFunc
    self.popAnim = false
end

function SiegeFlagAniView:onInit()
    self._bg = self:getUI("bg")
--    self:registerClickEvent(self._bg, function()
--        if self._callback then
--            self._callback()
--        end
--        self:close()
--        UIUtils:reloadLuaFile("siege.SiegeFlagAniView")
--    end)

    self._flag = self:getUI("bg.layer.flag")
    self._flag:setCascadeOpacityEnabled(true)
    self._flag:setOpacity(0)
    self._flag:setPositionY(818)

    self._titleImg = self._flag:getChildByFullName("titleImg")
    self._titleImg:loadTexture("world_flagTitleImg" .. self._type .. ".png", 1)

    self._desImg = self._flag:getChildByFullName("desImg")
    self._desImg:loadTexture("world_flagDesImg" .. self._type .. ".png", 1)

    SystemUtils.saveAccountLocalData("SiegeFlagAni", self._type)
end

function SiegeFlagAniView:onShow()
    local x,y = self._flag:getPosition()
    self._flag:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.2),
        cc.Spawn:create(
            cc.EaseOut:create(cc.MoveTo:create(0.3, cc.p(x, y - 430)), 1.5),
            cc.FadeIn:create(0.3)
        ),
        cc.DelayTime:create(1),
        cc.Spawn:create(
            cc.EaseIn:create(cc.MoveTo:create(0.2, cc.p(x, y)), 1.5),
            cc.FadeOut:create(0.2)
        ),
        cc.CallFunc:create(function()
            if self._callback then
                self._callback()
            end
            self:close()
        end))
    )
end

return SiegeFlagAniView