--[[
    Filename:    SiegeDailyDefBattleTimeOutView.lua
    Author:      <hexinping@playcrab.com>
    Datetime:    2017-10-16 
    Description: 日常守城战斗时间耗尽界面
--]]
--
local pageVar = {
    colors = {cc.c3b(255, 252, 226),cc.c3b(255, 232, 125)}
}

local SiegeDailyDefBattleTimeOutView = class("SiegeDailyDefBattleTimeOutView", BasePopView)

function SiegeDailyDefBattleTimeOutView:ctor(data)
    SiegeDailyDefBattleTimeOutView.super.ctor(self)
    self._canTouch = false
end

function SiegeDailyDefBattleTimeOutView:getMaskOpacity()
    return 229
end

function SiegeDailyDefBattleTimeOutView:onInit()
    self:registerClickEventByName("bg", function()
        if not self._canTouch then return end 
        if self._callBack ~= nil then
            self._callBack()
        end
        self:close()
        UIUtils:reloadLuaFile("siegeDaily.SiegeDailyDefBattleTimeOutView")
    end )

    local layer      = self:getUI("bg.layer")
    self._nodeUp     = self:getUI("bg.layer.nodeUp")
    self._nodeDown   = self:getUI("bg.layer.nodeDown")
    self._spineNode  = self:getUI("bg.layer.spineNode")
    self._titleImage = self:getUI("bg.layer.titleImage")

    self._nodeUp:setVisible(false)
    self._nodeDown:setVisible(false)
    self._titleImage:setVisible(false)

    local rewardTitle = self._nodeDown:getChildByFullName("titleLabel")
    rewardTitle:setFontName(UIUtils.ttfName) 

    spineMgr:createSpine("xinshouyindao", function (spine)
        -- spine:setVisible(false)
        spine.endCallback = function ()
            spine:setAnimation(0, "pingdan", true)
        end 
        local anim = "pingdan"
        spine:setAnimation(0, anim, true)
        spine:setPosition(0, 0)
        spine:setScale(1)
        self._spineNode:addChild(spine)
    end)
    self._spineNode:setVisible(false)

    local flowerMc = mcMgr:createViewMC("piaoluocaidai_leaguejinjiechenggong", true, false)
    flowerMc:setPosition(450,600)
    layer:addChild(flowerMc)

    local desLabel3 = self._nodeUp:getChildByFullName("desLabel3")
    desLabel3:setFontName(UIUtils.ttfName)
    local desLabel = self._nodeDown:getChildByFullName("desLabel")
    self:enable2Color(desLabel)
    desLabel = self._nodeDown:getChildByFullName("desLabel1")
    self:enable2Color(desLabel)
end

function SiegeDailyDefBattleTimeOutView:enable2Color(desLabel)
    desLabel:setColor(pageVar.colors[1])
    desLabel:enable2Color(1,pageVar.colors[2])
    desLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
end

function SiegeDailyDefBattleTimeOutView:addTitleImageAction()
    
    local ease = cc.EaseIn:create(cc.ScaleTo:create(0.1,1),0.5)
    local fade = cc.FadeIn:create(0.2)
    local spaw = cc.Spawn:create(ease,fade)
    local innerImage = self._titleImage:getChildByFullName("innerImage")
    innerImage:setBrightness(100)
    self._titleImage:runAction(spaw)
    ScheduleMgr:delayCall(100, self, function()
        innerImage:runAction(cc.Sequence:create(
            cc.Spawn:create(cc.EaseIn:create(cc.ScaleTo:create(0.1,1.1),0.5),cc.FadeTo:create(0.2,100)),
            cc.RemoveSelf:create()
            ))
    end)
end

function SiegeDailyDefBattleTimeOutView:onShow()
    self._nodeUp:setPositionX(self._nodeUp:getPositionX() - 50)
    self._nodeDown:setPositionY(self._nodeDown:getPositionY() - 80)
    self._spineNode:setPositionX(self._spineNode:getPositionX() - 100)
    self._titleImage:setScale(5)
    self._titleImage:setOpacity(0)

    self._spineNode:setVisible(true)
    self._spineNode:runAction(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(200, 0)), cc.CallFunc:create(function()
            self._titleImage:setVisible(true)
            self:addTitleImageAction()
            ScheduleMgr:delayCall(200, self, function()
                self._nodeUp:setVisible(true)
                self._nodeUp:runAction(cc.Sequence:create(cc.MoveBy:create(0.1, cc.p(60, 0)), cc.MoveBy:create(0.1, cc.p(-10, 0))))

                ScheduleMgr:delayCall(200, self, function()
                    self._nodeDown:setVisible(true)
                    self._nodeDown:runAction(cc.Sequence:create(
                        cc.MoveBy:create(0.1, cc.p(0, 90)), cc.CallFunc:create(function()
                            self._nodeUp:runAction(cc.Sequence:create(cc.MoveBy:create(0.1, cc.p(0, 10)), cc.MoveBy:create(0.1, cc.p(0, -10))))
                            self._nodeDown:runAction(cc.MoveBy:create(0.1, cc.p(0, -10)))
                            self:unlock()
                            self._canTouch = true
                        end)))
                end)

            end)
        end))) 
end

-- function SiegeDailyDefBattleTimeOutView:getAsyncRes()
--     return {{"asset/ui/siegeDaily.plist", "asset/ui/siegeDaily.png"}}
-- end

function SiegeDailyDefBattleTimeOutView:_clearVars()
    self._nodeUp     = nil
    self._nodeDown   = nil
    self._spineNode  = nil
    self._titleImage = nil
end

function SiegeDailyDefBattleTimeOutView:onDestroy()
    self:_clearVars()
end

return SiegeDailyDefBattleTimeOutView