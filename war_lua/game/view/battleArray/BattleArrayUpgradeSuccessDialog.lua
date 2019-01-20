--[[
 	@FileName 	BattleArrayUpgradeSuccessDialog.lua
	@Authors 	yuxiaojing
	@Date    	2018-07-23 17:17:51
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local BattleArrayUpgradeSuccessDialog = class("BattleArrayUpgradeSuccessDialog", BasePopView)

function BattleArrayUpgradeSuccessDialog:ctor( params )
	self.super.ctor(self)
	params = params or {}
	self._level = params.level
	self._raceType = params.raceType
    self._callback = params.callback
end

function BattleArrayUpgradeSuccessDialog:onInit(  )

	self:registerClickEventByName("Panel", function ()
        ScheduleMgr:nextFrameCall(self, function()
            if self._callback then
                self._callback()
            end
            self:close()
        end)
    end)

	self._panel = self:getUI("Panel")
    self._bg = self:getUI('Panel.bg')
    self._left = self:getUI('leftbg')
    self._right = self:getUI('rightbg')
    self._infoPanel = self:getUI('Panel.Panel1')

    self:updateView()

    self._bg:setOpacity(0)
    self._left:setVisible(false)
    self._right:setVisible(false)
    self._left:runAction(cc.MoveTo:create(0.1, cc.p(0, 0)))
    self._right:runAction(cc.MoveTo:create(0.1, cc.p(MAX_SCREEN_WIDTH, 0)))

    self:addPopViewTitleAnim(self._panel, "tupochenggong_huodetitleanim", self._panel:getContentSize().width / 2, 460)

    local bgHeight = 200
    local maxHeight = self._bg:getContentSize().height + 12
    ScheduleMgr:delayCall(500, self, function( )
    	self._bg:setContentSize(cc.size(self._bg:getContentSize().width, bgHeight))
    	self._bg:setOpacity(255)
    	local sizeSchedule
    	local step = 0.5
        local stepConst = 30
        sizeSchedule = ScheduleMgr:regSchedule(1, self,function( )
            stepConst = stepConst-step
            if stepConst < 1 then 
                stepConst = 1
            end
            bgHeight = bgHeight + stepConst
            if bgHeight < maxHeight then
                self._bg:setContentSize(cc.size(self._bg:getContentSize().width, bgHeight))
            else
                self._bg:setContentSize(cc.size(self._bg:getContentSize().width, maxHeight))
                self._bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 1, 1.05),cc.ScaleTo:create(0.1, 1, 1)))
                ScheduleMgr:unregSchedule(sizeSchedule)
            	self:showView()
            end
        end)
    end)
end

function BattleArrayUpgradeSuccessDialog:showView(  )
	self._left:setVisible(true)
    self._right:setVisible(true)
    self._left:runAction(cc.MoveTo:create(0.3, cc.p(self._left:getContentSize().width / 2, self._left:getContentSize().height / 2)))
    self._right:runAction(cc.MoveTo:create(0.3, cc.p(MAX_SCREEN_WIDTH - self._right:getContentSize().width / 2, self._right:getContentSize().height / 2)))

    self._infoPanel:getChildByFullName("namebg"):setVisible(true)
    self._infoPanel:getChildByFullName("namebg"):runAction(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(0, 12)),cc.MoveBy:create(0.1, cc.p(0, -2))))

    local childrens = self._infoPanel:getChildren()
    for k, v in pairs(childrens) do
    	if v:getName() ~= "namebg" then
	        v:runAction(cc.Sequence:create(
	            cc.DelayTime:create(k * 0.02),
	            cc.FadeIn:create(0.2)
	            ))
	    end
    end
    self._infoPanel:getChildByFullName('touchLab'):runAction(cc.Sequence:create(
            cc.DelayTime:create(0.5),
            cc.FadeIn:create(0.2)
            ))
end

function BattleArrayUpgradeSuccessDialog:updateView(  )
    self._infoPanel:setPositionY(self._infoPanel:getPositionY() - 15)
    self._infoPanel:getChildByFullName("namebg"):setVisible(false)
    local childrens = self._infoPanel:getChildren()
    for k, v in pairs(childrens) do
    	if v:getName() ~= "namebg" then
	        v:setOpacity(0)
	        if v:getChildrenCount() > 0 then
	            v:setCascadeOpacityEnabled(true)
	        end
	    end
    end
    self._infoPanel:getChildByFullName('touchLab'):setOpacity(0)
    local levelLab = self._infoPanel:getChildByFullName("levelLab")
    local img_1 = self._infoPanel:getChildByFullName("img_1")
    local img_2 = self._infoPanel:getChildByFullName("img_2")
    levelLab:setString("突破等级Lv." .. self._level)
    levelLab:setColor(cc.c4b(254, 250, 223, 255))
    levelLab:enable2Color(1, cc.c3b(255, 239, 129))
    img_1:setPositionX(levelLab:getPositionX() - levelLab:getContentSize().width / 2 - img_1:getContentSize().width / 2 - 10)
    img_2:setPositionX(levelLab:getPositionX() + levelLab:getContentSize().width / 2 + img_2:getContentSize().width / 2 + 10)
    local data = self._modelMgr:getModel("BattleArrayModel"):getBattleUpDBDataByRace(self._raceType)
    local levelData = data[self._level]
    self._infoPanel:getChildByFullName("desc"):setString(lang(levelData.effectDes))
end

return BattleArrayUpgradeSuccessDialog