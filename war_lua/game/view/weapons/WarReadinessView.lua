--[[
 	@FileName 	WarReadinessView.lua
	@Authors 	yuxiaojing
	@Date    	2018-04-25 16:35:45
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local WarReadinessView = class("WarReadinessView", BaseView)

function WarReadinessView:ctor(param)
    WarReadinessView.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
end

function WarReadinessView:getAsyncRes()
    return 
    {
        {"asset/ui/skillCard.plist", "asset/ui/skillCard.png"}
    }
end

function WarReadinessView:getBgName()
    return "bg_001.jpg"
end

function WarReadinessView:setNavigation()
	self._viewMgr:showNavigation("global.UserInfoView", {titleTxt = lang("MAIN_WARBACKUP")})
end

function WarReadinessView:updateLockView( node, index )
	local LockImg = node:getChildByFullName("lockPanel")
	local playerLevel = self._userModel:getData().lvl

	if index == 1 then
		local tabData = tab:SystemOpen("Backup")
		local openLevel = tabData[1]

		self._backupIsOpen = false
		if openLevel <= playerLevel then
			self._backupIsOpen = true
		end
		self._backupOpenTips = tabData[3]
		LockImg:setVisible(not self._backupIsOpen)
		if not self._backupIsOpen then
			node:getChildByFullName("lockPanel.tips"):setString("玩家达到" .. openLevel .. "级开启")
			UIUtils:setGray(node, true)
		end
	elseif index == 2 then
		local tabData = tab:SystemOpen("BattleArray")
		local openLevel = tabData[1]
		self._battleArrayIsOpen = false
		if openLevel <= playerLevel then
			self._battleArrayIsOpen = true
		end
		self._battleArrayOpenTips = tabData[3]
		LockImg:setVisible(not self._battleArrayIsOpen)
		if not self._battleArrayIsOpen then
			node:getChildByFullName("lockPanel.tips"):setString("玩家达到" .. openLevel .. "级开启")
			UIUtils:setGray(node, true)
		end
	elseif index == 3 then
		local tabData = tab:SystemOpen("Weapon")
		local openLevel = tabData[1]
		self._weaponIsOpen = false
		if openLevel <= playerLevel then
			self._weaponIsOpen = true
		end
		self._weaponOpenTips = tabData[3]
		LockImg:setVisible(not self._weaponIsOpen)
		if not self._weaponIsOpen then
			node:getChildByFullName("lockPanel.tips"):setString("玩家达到" .. openLevel .. "级开启")
			UIUtils:setGray(node, true)
		end

	elseif index == 4 then
		local tabData = tab:SystemOpen("ParagonTalent")
		local openLevel = tabData[1]
		self._paragonIsOpen = false
		if openLevel <= playerLevel then
			self._paragonIsOpen = true
		end
		self._paragonOpenTips = tabData[3]
		LockImg:setVisible(not self._paragonIsOpen)
		if not self._paragonIsOpen then
			node:getChildByFullName("lockPanel.tips"):setString("玩家达到" .. openLevel .. "级开启")
			UIUtils:setGray(node, true)
		end
	end
	node:getChildByFullName("des"):setString(self._des[index])
	node:getChildByFullName("bgUp"):loadTexture(self._img[index])
end

function WarReadinessView:clickCallback( index )
	if index == 1 then
		if not self._backupIsOpen then
			self._viewMgr:showTip(lang(self._backupOpenTips))
			return
		end
		self._modelMgr:getModel("BackupModel"):showBackupGradeView()
	elseif index == 2 then
		if not self._battleArrayIsOpen then
			self._viewMgr:showTip(lang(self._battleArrayOpenTips))
			return
		end
		self._viewMgr:showView("battleArray.BattleArrayEnterView")
	elseif index == 3 then
		if not self._weaponIsOpen then
			self._viewMgr:showTip(lang(self._weaponOpenTips))
			return
		end 		
		local weaponsModel = self._modelMgr:getModel("WeaponsModel")
	    local state = weaponsModel:getWeaponState()
	    if state == 1 then
	        self._viewMgr:showTip(lang("TIP_Weapon"))
	    elseif state == 2 then
	        self._viewMgr:showTip(lang("TIP_Weapon2"))
	    elseif state == 3 then
	        self._viewMgr:showTip(lang("TIP_Weapon3"))
	    elseif state == 4 then
	        local tdata = weaponsModel:getWeaponsDataByType(1)
	        if tdata then
	            self._viewMgr:showView("weapons.WeaponsView", {})
	        else
	            self._serverMgr:sendMsg("WeaponServer", "getWeaponInfo", {}, true, {}, function(result)
	                self._viewMgr:showView("weapons.WeaponsView", {})
	            end)
	        end
	    end

	elseif index == 4 then
		if not self._paragonIsOpen then
			self._viewMgr:showTip(lang(self._paragonOpenTips))
			return
		end

		self._serverMgr:sendMsg("ParagonTalentServer", "getPTalentInfo", {}, true, {}, function(result)
            self._viewMgr:showView("paragon.ParagonTalentView")
        end)
	end
end

function WarReadinessView:onInit()
	self:getUI("bg"):setVisible(false)
	self:getUI("bg1"):setVisible(true)
	self._bg = self:getUI("bg1")

	self._des = {
		lang("backup_EntryDes"), 
		lang("EntryDes_BattleArray"), 
		lang("backup_Weapon_EntryDes"),
		lang("TIP_talent_info"),
	}
	self._img = {
		"asset/uiother/warReadiness/backup_img.jpg", 
		"asset/uiother/warReadiness/battleArray.jpg", 
		"asset/uiother/warReadiness/weapon_img.jpg",
		"asset/uiother/warReadiness/paragon_img.jpg",
	}

	local trainingNode = self._bg:getChildByFullName("trainingNode")
	trainingNode:setVisible(false)
	self._scrollView = self._bg:getChildByFullName("scrollView")
	for i = 1, #self._img do
		local node = trainingNode:clone()
		self._scrollView:addChild(node)
		node:setPosition((i - 1) * trainingNode:getContentSize().width, 0)
		node:setVisible(true)
		self:updateLockView(node, i)
		self:registerClickEvent(node, function (  )
			self:clickCallback(i)
		end)
		node:setName("node" .. i)
		node:setSwallowTouches(false)
	end
	self._scrollView:setInnerContainerSize(cc.size(#self._img * trainingNode:getContentSize().width, self._scrollView:getContentSize().height))
	self:updateButtonRed()
end

function WarReadinessView:updateButtonRed()
	for i = 1, #self._img do
		local node = self._scrollView:getChildByFullName("node" .. i)
		if node and i == 1 then
			local redPointPromptList = self._modelMgr:getModel("BackupModel"):redPointPrompt()
			node:getChildByFullName("pointIcon"):setVisible(#redPointPromptList > 0)
		elseif node and i == 2 then
			local redPointPromptList = self._modelMgr:getModel("BattleArrayModel"):getRedPrompt()
			node:getChildByFullName("pointIcon"):setVisible(#redPointPromptList > 0)
		elseif node and i == 3 then
			local red = false
			local red = self._modelMgr:getModel("WeaponsModel"):checkMainViewTips()
			
			local cCostData = tab:Setting("DRAW_SW_COST4").value[1]
		    local CostType = cCostData[1]
		    local CostCount = cCostData[3]
		    local have = self._userModel:getData()[CostType] or 0
		    if have >= CostCount then
		        red = true
		    end
		    if not self._weaponIsOpen then
		    	red = false
		    end
			node:getChildByFullName("pointIcon"):setVisible(red)
		elseif node and i == 4 then
			local isShow = self._modelMgr:getModel("ParagonModel"):checkWarReadinessRedPoint()
			node:getChildByFullName("pointIcon"):setVisible(isShow)
		end
	end
end

function WarReadinessView:beforePopAnim()
	WarReadinessView.super.beforePopAnim(self)
	for i = 1, 3 do
		local hole = self._scrollView:getChildByFullName("node" .. i)
		hole:setCascadeOpacityEnabled(true, true)
		hole:setOpacity(0)
		hole:setScaleAnim(true)
	end
end

function WarReadinessView:popAnim(callback)
	-- 执行父节点动画
	WarReadinessView.super.popAnim(self, nil)
	if self._isFromAc then
		if callback then
			callback()
		end
	end
	-- 如果是活动跳转 不播动画
	if self._isFromAc then return end

	-- 定义自己动画
	local delayTime = 0.1
	local moveTime = 0.1
	local springTime = 0.2
	local fadeInTime = 0.1
	local moveDis = 200
	local springDis = 10
	for i = 1, #self._img do
		local hole = self._scrollView:getChildByFullName("node" .. i)
		local holeInitPos = cc.p(hole:getPositionX(),hole:getPositionY())
		local holeSpringPos = cc.p(hole:getPositionX()-springDis,hole:getPositionY())
		local holebeginPos = cc.p(hole:getPositionX()+moveDis,hole:getPositionY())
		hole:setPosition(holebeginPos)
		hole._idx = i
		local holeDelayTime = delayTime*(i-1) + 0.1
		local delayAct = cc.DelayTime:create(holeDelayTime)
		local spawn = cc.Spawn:create(cc.MoveTo:create(moveTime,holeSpringPos),cc.FadeIn:create(fadeInTime))
		local seq = cc.Sequence:create(delayAct,spawn,cc.MoveTo:create(springTime,holeInitPos),cc.CallFunc:create(function(obj)
			
			hole:setScaleAnimMin(0.9)
			hole:setAnchorPoint(cc.p(0, 0))
			hole:setPosition(holeInitPos)
			if callback then
				callback()
			end
		end))
		hole:runAction(seq)
	end
end

function WarReadinessView:onTop()
	self:updateButtonRed()
end

function WarReadinessView:onDestroy( )
	WarReadinessView.super.onDestroy(self)
end

return WarReadinessView