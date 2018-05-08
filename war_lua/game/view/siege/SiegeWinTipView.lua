--
-- Author: <ligen@playcrab.com>
-- Date: 2017-10-12 09:02:18
--
local SiegeWinTipView = class("SiegeWinTipView", BasePopView)
function SiegeWinTipView:ctor(data)
    SiegeWinTipView.super.ctor(self)
    self._type = data.tipType
    self._callback = data.callback
end

function SiegeWinTipView:onInit()
    self._bg = self:getUI("bg")
    self:registerClickEvent(self._bg, function()
        if self._callback then
            self._callback()
        end
        self:close()
        UIUtils:reloadLuaFile("siege.SiegeWinTipView")
    end)

    self._labelBg = self:getUI("bg.labelBg")
    self._labelBg:setContentSize(MAX_SCREEN_WIDTH, 232)

    self._label = self._labelBg:getChildByFullName("label")
    self._label:setColor(cc.c3b(255,255,232))
    self._label:enable2Color(1, cc.c4b(221,176,81,255))
    self._label:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._titleBg = self:getUI("bg.titleBg")
    self._titleBg:setOpacity(0)
    self._titleBg:setCascadeOpacityEnabled(true)
    self._titleBg:setScale(3)

    local titleTxt = self._titleBg:getChildByFullName("titleTxt")


    self._titleAni = mcMgr:createViewMC("shouweichenggong_gongcheng", false, false)
    self._titleAni:stop()
    self._titleAni:setPosition(480, 512)
    self._bg:addChild(self._titleAni, -1)

    mcMgr:loadRes("leaguejinjiechenggong",function( )
        local mc = mcMgr:createViewMC("piaoluocaidai_leaguejinjiechenggong", true, false)
        mc:setPosition(450,600)
        self._bg:addChild(mc)
    end)


    self._desLabel = self:getUI("bg.desLabel")
    self._desLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._desLabel:setString("(活动关闭后，领主大人们可以每日继续进行攻城和守城玩法)")
    self._desLabel:setOpacity(0)

    if self._type == 1 then
        self._label:setString("经过凯瑟琳和各位玩家的努力\n斯坦德威克成功被夺下！")
        titleTxt:loadTexture("siege_winLabel1.png", 1)
        self._desLabel:setVisible(false)

        SystemUtils.saveAccountLocalData("siegeWinTip", 1)
    else
        self._label:setString("围城敌人四散奔逃\n斯坦德威克守卫战圆满完成！")
        titleTxt:loadTexture("siege_winLabel2.png", 1)

        SystemUtils.saveAccountLocalData("siegeWinTip", 2)
    end
    self._label:setPositionX(MAX_SCREEN_WIDTH * 0.5)
end

function SiegeWinTipView:onShow()
    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.4),
        cc.CallFunc:create(function()
            self._titleAni:play()
        end)
    ))

    self._titleBg:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.2),
        cc.Spawn:create(
            cc.EaseOut:create(cc.ScaleTo:create(0.15, 1), 1.5),
            cc.FadeIn:create(0.15)
        ))
    )

    self._desLabel:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.6),
        cc.FadeIn:create(0.1)
    ))

end

return SiegeWinTipView