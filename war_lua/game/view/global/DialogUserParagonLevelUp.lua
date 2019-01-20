--[[
 	@FileName 	DialogUserParagonLevelUp.lua
	@Authors 	yuxiaojing
	@Date    	2018-09-29 14:55:29
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local DialogUserParagonLevelUp = class("DialogUserParagonLevelUp", BasePopView)

function DialogUserParagonLevelUp:ctor(data)
    DialogUserParagonLevelUp.super.ctor(self)
    self._oldPlvl = data.oldPlvl
    self._plvl = data.plvl
    self._pTalentPoint = data.pTalentPoint
end

function DialogUserParagonLevelUp:onInit(  )

    self:registerClickEventByName("closePanel", function ()
        ScheduleMgr:nextFrameCall(self, function()
            self:close()
        end)
    end)

    self._closePanel = self:getUI("closePanel")
    self._show1 = self:getUI("bg.layer.show1")
    self._show2 = self:getUI("bg.layer.show2")
    self._layer = self:getUI("bg.layer")
    self._bgImg = self:getUI("bg.bg3")

    self._closePanel:setTouchEnabled(false)

    self:updateView()
    audioMgr:playSound("ItemGain_1")
    self:addPopViewTitleAnim(self:getUI("bg"), "dianfengshengji_dianfengshengji", 0, -10, 42, 1.3)

    local seq = cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(-3, 0)), cc.MoveBy:create(0.3, cc.p(3, 0)))
    self._show1:getChildByFullName("arrow"):runAction(cc.RepeatForever:create(seq))

    local bgHeight = 50
    self._bgImg:setOpacity(0)
    local bgWith = self._bgImg:getContentSize().width
    local maxHeight = self._bgImg:getContentSize().height
    ScheduleMgr:delayCall(500, self, function( )
    	self._bgImg:setOpacity(255)
    	self._bgImg:setContentSize(cc.size(bgWith, bgHeight))
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
                self._bgImg:setContentSize(cc.size(bgWith, bgHeight))
            else
                self._bgImg:setContentSize(cc.size(bgWith, maxHeight))
                ScheduleMgr:unregSchedule(sizeSchedule)
            	self:showView()
            end
        end)
    end)
end

function DialogUserParagonLevelUp:showView(  )
	for i = 1, 2 do
		local panel = self:getUI("bg.layer.show" .. i)
		ScheduleMgr:delayCall(200 * i, self, function (  )
			if not panel then return end
			panel:setVisible(true)
			panel:runAction(cc.JumpBy:create(0.2,cc.p(0,0),10,1))

			local mcShua = mcMgr:createViewMC("shuxingshuguang_itemeffectcollection", true, false, function (_, sender)
                sender:removeFromParent()
            end,RGBA8888)
            mcShua:setPosition(cc.p(0, panel:getContentSize().height / 2 + 2))
            mcShua:setScaleY(1)
            audioMgr:playSound("adTag")
            panel:addChild(mcShua)
		end)
	end

	self:getUI('bg.touchLab'):runAction(cc.Sequence:create(
        cc.DelayTime:create(0.8),
        cc.CallFunc:create(function (  )
        	self._closePanel:setTouchEnabled(true)
        end),
        cc.FadeIn:create(0.5)
        ))
end

function DialogUserParagonLevelUp:updateView(  )
	self:getUI('bg.touchLab'):setOpacity(0)
	self._show1:setVisible(false)
	self._show2:setVisible(false)

	local preLevel = self._show1:getChildByFullName("preLevel")
	local nowLevel = self._show1:getChildByFullName("level")
	local arrow = self._show1:getChildByFullName("arrow")
	local point = self._show2:getChildByFullName("level")

	preLevel:setString(self._oldPlvl)
	nowLevel:setString(self._plvl)
	point:setString("+" .. self._pTalentPoint)

	local arrowX = preLevel:getPositionX() + preLevel:getContentSize().width
	arrow:setPositionX(arrowX + 10)
	nowLevel:setPositionX(arrow:getPositionX() + arrow:getContentSize().width + 8)
	self._show1:setContentSize(cc.size(nowLevel:getPositionX() + nowLevel:getContentSize().width, self._show1:getContentSize().height))	
	self._show1:setPositionX(self._layer:getContentSize().width / 2 - self._show1:getContentSize().width / 2)
	self._show2:setPositionX(self._show1:getPositionX())
end

return DialogUserParagonLevelUp