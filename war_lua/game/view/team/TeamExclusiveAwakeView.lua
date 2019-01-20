--[[
 	@FileName 	TeamExclusiveAwakeView.lua
	@Authors 	yuxiaojing
	@Date    	2018-09-11 10:54:48
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local TeamExclusiveAwakeView = class("TeamExclusiveAwakeView", BaseView)

function TeamExclusiveAwakeView:ctor(data)
    TeamExclusiveAwakeView.super.ctor(self)
    data = data or {}
    self._teamId = data.teamId or 606
    self._callback = data.callback
end

function TeamExclusiveAwakeView:onInit(  )
	self._preBGMName = audioMgr:getMusicFileName()
    audioMgr:playMusic("SaintHeaven", true)

	self:registerClickEventByName("touchPanel", function ()
        ScheduleMgr:nextFrameCall(self, function()
            self:close()
        end)
    end)

	self._touchPanel = self:getUI("touchPanel")
	self._bg = self:getUI("bg")
	self._touchLab = self:getUI("touchLab")
	self._iconBg = self._bg:getChildByFullName("panel")

	self._touchLab:setVisible(false)
	self._touchPanel:setTouchEnabled(false)
	self._bg:loadTexture("asset/bg/team_exclusive_awake.jpg")

	local exclusiveData = tab.exclusive[self._teamId]
	local offset = exclusiveData.position or {}
	local offset1 = exclusiveData.position1 or {}

	self._iconBg:setPosition(self._bg:getContentSize().width / 2 - self._iconBg:getContentSize().width / 2 + 50  + (offset[1] or 0), self._bg:getContentSize().height / 2 - self._iconBg:getContentSize().height / 2 - 70 + (offset[2] or 0))

	audioMgr:playSound("team_exclusive_awake")
	
	local anim1 = mcMgr:createViewMC("huanxingdonghua1_huanxingdonghua", false, true)
	anim1:setPosition(self._bg:getContentSize().width / 2, self._bg:getContentSize().height / 2)
	anim1:setName("anim1")
	self._bg:addChild(anim1, 5)

	local anim2 = mcMgr:createViewMC("huanxingdonghua2_huanxingdonghua", false, true)
	anim2:setPosition(self._bg:getContentSize().width / 2, self._bg:getContentSize().height / 2)
	anim2:setName("anim2")
	self._bg:addChild(anim2, 20)

	local artName = exclusiveData.art1 or "pic_artifact_30"
	local artImg = ccui.ImageView:create()
	artImg:setPosition(0, 0)
	artImg:loadTexture(artName .. ".png", 1)
	self._iconBg:addChild(artImg)

	self._iconBg:runAction(cc.Sequence:create(
		cc.DelayTime:create(2.3),
		cc.MoveBy:create(0.02, cc.p(0, -3)),
		cc.MoveBy:create(0.04, cc.p(0, 6)),
		cc.MoveBy:create(0.04, cc.p(0, -6)),
		cc.MoveBy:create(0.2, cc.p(0, 100)),
		cc.DelayTime:create(1.5),
		cc.CallFunc:create(function (  )
			artImg:setBrightness(30)
			self._iconBg:runAction(cc.RepeatForever:create(cc.Sequence:create(
				cc.MoveBy:create(0.04, cc.p(0, 5)),
				cc.MoveBy:create(0.04, cc.p(0, -5))
				)))
			ScheduleMgr:delayCall(1500, self, function( )
				self._iconBg:stopAllActions()
				self._iconBg:removeAllChildren()
				local artImg = mcMgr:createViewMC(exclusiveData.art2, true, false)
				artImg:setPosition((offset1[1] or 0) , (offset1[2] or 0))
				self._iconBg:addChild(artImg)

				local moveUp = cc.MoveBy:create(1.5, cc.p(0, 8))
			    local moveDown = cc.MoveBy:create(1.5, cc.p(0, -8))
			    local seq = cc.Sequence:create(moveUp, moveDown)
			    local repeateMove = cc.RepeatForever:create(seq)
			    artImg:runAction(repeateMove)
			end)
			ScheduleMgr:delayCall(2000, self, function (  )
				self._touchPanel:setTouchEnabled(true)
			    self._touchLab:setZOrder(100)
			    self._touchLab:setVisible(true)
			end)
		end)
		))
end

function TeamExclusiveAwakeView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

function TeamExclusiveAwakeView:onDestroy( )
    if self._preBGMName then
        audioMgr:playMusic(self._preBGMName, true)
    end
    local callback = self._callback
    TeamExclusiveAwakeView.super.onDestroy(self)
    if callback then
        callback()
    end
end

return TeamExclusiveAwakeView