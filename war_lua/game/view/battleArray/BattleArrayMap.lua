--[[
 	@FileName 	BattleArrayMap.lua
	@Authors 	yuxiaojing
	@Date    	2018-07-13 15:13:59
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local BattleArrayMap = class("BattleArrayMap", BaseLayer)

function BattleArrayMap:ctor( params )
	BattleArrayMap.super.ctor(self)

	self._baLayer = params.baLayer
	self._baView = self._baLayer._parentView
end

function BattleArrayMap:onInit(  )
	self._baModel = self._baView._modelMgr:getModel("BattleArrayModel")
	self._itemModel = self._modelMgr:getModel("ItemModel")
	self._userModel = self._modelMgr:getModel("UserModel")
	self._mapNode = self:getUI("mapNode")
	self._point = {}
	self._line = {}
	self._showPoint = {}
	self._showLine = {}
	self._activeList = {}
	self._canActiveList = {}
	self._DBData = {}
	self._activeLineList = {}
	self._battleUpDBData = {}
	self:initPoint()
end

function BattleArrayMap:reflashView( mcType, mcList )
	self._baData = self._baView._baData
	self._activeList = self._baView._activeList
	self._canActiveList = self._baView._canActiveList
	self._activeLineList = self._baView._activeLineList
	self._DBData = self._baView._DBData
	self._battleUpDBData = self._baView._battleUpDBData
	self._mcType = mcType
	self._mcList = mcList
	self:initShowMap()
	self:updateRaceBg()
	self:updateCenterPoint()
	self:updateOtherPoint()
	self:updateAllLine()
	self:updateCenterPointMC()
	self._baView:updateBottomInfo()
	self._mcType = nil
	self._mcList = nil
end

function BattleArrayMap:initShowMap(  )
	local upDB = self._battleUpDBData[self._baData.lv or 1]
	local pMax = upDB.pointId
	local lMax = upDB.lineIdRead
	self._showPoint = {}
	self._showLine = {}
	for k, v in pairs(self._point) do
		if k < pMax then
			v:setVisible(true)
			self._showPoint[k] = v
		else
			v:setVisible(false)
		end
	end
	for k, v in pairs(self._line) do
		if k < lMax then
			v:setVisible(true)
			self._showLine[k] = v
		else
			v:setVisible(false)
		end
	end
end

function BattleArrayMap:updateRaceBg(  )
	self._mapNode:getChildByFullName("bg"):loadTexture("asset/uiother/race/race_ba_" .. self._baView._filterType .. ".png")
end

function BattleArrayMap:updateCenterPoint(  )
	self._centerLevel:setString("Lv." .. self._baData.lv)
end

function BattleArrayMap:showPointMC( pid, mcType )
	if pid == nil then return end
	if pid == 1 then
		if mcType == "allLight" then
			local mc = mcMgr:createViewMC("quanbudianliang1_yangchengjiemian-HD", false, true)
			mc:setPosition(self._center:getContentSize().width / 2, self._center:getContentSize().height / 2)
			self._center:addChild(mc, 1)
		end
		return
	end
	local node = self._showPoint[pid]
	if not node then return end
	local mc
	if mcType == "active" then
		mc = mcMgr:createViewMC("dianliang_yangchengjiemian-HD", false, true)
	elseif mcType == "reset" then
		mc = mcMgr:createViewMC("chongzhi1_yangchengjiemian-HD", false, true)
	elseif mcType == "allLight" then
		mc = mcMgr:createViewMC("quanbudianliang2_yangchengjiemian-HD", false, true)
	else
		print("***********************please call yuxiaojing pid:" .. pid)
		return
	end
	mc:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
	mc:setScale(node:getChildByFullName("img"):getScale())
	node:addChild(mc, 1)
end

function BattleArrayMap:showAllLightMC(  )
	self:showPointMC(1, "allLight")
	for k, v in pairs(self._showPoint) do
		self:showPointMC(k, "allLight")
	end
end

function BattleArrayMap:switchSelectState( mid )
	if mid == nil then return end
	if self._selectMC ~= nil then
		self._selectMC:removeFromParent()
		self._selectMC = nil
	end
	if mid == 1 then
		self._selectMC = mcMgr:createViewMC("zhenyanxuanzhong_yangchengjiemian-HD", true, false)
		self._selectMC:setPosition(self._center:getContentSize().width / 2, self._center:getContentSize().height / 2)
		self._center:addChild(self._selectMC, 1)
		return
	end
	local node = self._showPoint[mid]
	if not node then return end
	self._selectMC = mcMgr:createViewMC("zhanzhenxuanzhong1_yangchengjiemian-HD", true, false)
	self._selectMC:setPosition(node:getContentSize().width / 2 + 1, node:getContentSize().height / 2 - 1)
	self._selectMC:setScale(node:getChildByFullName("img"):getScale())
	node:addChild(self._selectMC, 1)
end

function BattleArrayMap:updateCenterPointMC(  )
	local maxNum = self._baModel:getLevelupPointsNum(self._baView._filterType)
	local isAllLight = (maxNum <= table.nums(self._activeList))
	local mc = self._center:getChildByFullName("centerMC")
	if isAllLight and not mc then
		mc = mcMgr:createViewMC("zhenyandianliangchangtai_yangchengjiemian-HD", true, false)
		mc:setPosition(self._center:getContentSize().width / 2, self._center:getContentSize().height / 2)
		mc:setName("centerMC")
		self._center:addChild(mc)
	else
		if mc then
			mc:removeFromParent()
		end
	end
end

function BattleArrayMap:updatePartView( active, activeLine )
	self._baData = self._baView._baData
	self._activeList = self._baView._activeList
	self._canActiveList = self._baView._canActiveList
	self._activeLineList = self._baView._activeLineList
	for k, v in pairs(active) do
		self:updateOnePoint(k)
	end

	for k, v in pairs(activeLine) do
		self:setLineState(self._showLine[k], true)
	end

	for k, v in pairs(self._canActiveList) do
		self:updateOnePoint(k)
	end
	self:updateCenterPointMC()
end

function BattleArrayMap:updateOnePoint( pId )
	local node = self._showPoint[pId]
	if not node then return end
	local sysData = self._DBData[pId]
	if not sysData then return end
	node:getChildByFullName("img"):loadTexture(sysData.activationIcon .. ".png", 1)
	node:getChildByFullName("img"):setScale(sysData.iconScale)

	node:setBrightness(0)
	node:getChildByFullName("img"):setBrightness(0)
	node:getChildByFullName("img"):setContrast(0)

	local addImg = node:getChildByFullName("add")
	addImg:setVisible(false)
	addImg:stopAllActions()

	local activeOutLight = node:getChildByFullName("activeOutLight")
	if not activeOutLight then
		activeOutLight = ccui.ImageView:create()
		activeOutLight:loadTexture(sysData.outLight .. ".png", 1)
		activeOutLight:setPosition(activeOutLight:getContentSize().width / 2 - 11, activeOutLight:getContentSize().height / 2 - 11)
		activeOutLight:setScale(sysData.iconScale)
		activeOutLight:setName("activeOutLight")
		node:addChild(activeOutLight)
	end
	activeOutLight:setVisible(false)
	if self._activeList[pId] then
		activeOutLight:setVisible(true)
		node:getChildByFullName("img"):setBrightness(30)
		node:getChildByFullName("img"):setContrast(20)
	elseif self._canActiveList[pId] then
		addImg:setVisible(true)
		local isCanActive = false
		local consume1 = sysData.ecpend
		local curHave = self._baData.soul or 0
		if consume1 and consume1[1] and consume1[1][3] then
			local battleUpDB = self._battleUpDBData[self._baData.lv or 1]
			local coe1 = battleUpDB.coefficientAtt1 or 1
			local coe2 = battleUpDB.coefficientAtt4 or 1
			local needNum = self._baModel:formatConsumeNumber(math.ceil(consume1[1][3] * coe1))
			if curHave >= needNum then
				local consume2 = sysData.ecpend2 or {}
				if consume2[1] then
					local itemType = consume2[1][1]
					local itemId = consume2[1][2]
					if itemType and itemType ~= "tool" then
			            itemId = IconUtils.iconIdMap[itemType]
			        end
			        if itemId then
			        	local haveNum, needNum = 0, math.ceil(consume2[1][3] * coe2)
			        	if "tool" == itemType then
			        		local _, num = self._itemModel:getItemsById(itemId)
			        		haveNum = num
			        	elseif "gold" == itemType then
			        		haveNum = self._userModel:getData().gold
			        	end
			        	if haveNum >= needNum then
			        		isCanActive = true
			        	end
			        else
			        	isCanActive = true
			        end
			    else
			    	isCanActive = true
				end
			end
		end
		
		if isCanActive then
			addImg:loadTexture("battleArray_img3.png", 1)
			addImg:runAction(cc.RepeatForever:create(
				cc.Sequence:create(
			        cc.Spawn:create(cc.ScaleTo:create(1, 0.9), cc.FadeTo:create(1, 220)),
			        cc.Spawn:create(cc.ScaleTo:create(1, 1), cc.FadeTo:create(1, 255))
				)))
		else
			addImg:loadTexture("battleArray_img2.png", 1)
		end
	else
		node:setBrightness(-50)
	end

	if self._mcType and self._mcList and self._mcList[pId] then
		self:showPointMC(pId, self._mcType)
	end
end

function BattleArrayMap:updateAllLine(  )
	for k, v in pairs(self._showLine) do
		if self._activeLineList[k] then
			self:setLineState(v, true)
		else
			self:setLineState(v, false)
		end
	end
end

function BattleArrayMap:updateOtherPoint(  )
	for k, v in pairs(self._showPoint) do
		self:updateOnePoint(k)
	end
end

function BattleArrayMap:setLineState( node, flag )
	if not node then return end
	local curName = node:getTextureName()
	curName = string.sub(curName, 1, -5)
	local splitRes = string.split(curName, "_")
	local lightName = splitRes[1]
	local darkName = lightName .. "_dark.png"
	lightName = lightName .. ".png"
	local name = lightName
	if not flag then
		name = darkName
	end
	node:loadTexture(name, 1)
end

function BattleArrayMap:initPoint(  )
	self._center = self._mapNode:getChildByFullName("center")
	self._centerLevel = self._center:getChildByFullName("level")
	self._centerLevel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
	self._center:setScaleAnim(false)
	
	self._baLayer:registerTouchEventWithLight(self._center, function (  )
		self._baView:updateBottomInfo()
	end)

	self._point = {}
	local mapNodes = self._mapNode:getChildren()
	for k, v in pairs(mapNodes) do
		local wName = v:getName()
		if string.find(wName, "p_") then
			local wId = string.sub(wName, 3, -1)
			self._point[tonumber(wId)] = v
			v:setScaleAnim(false)
			self._baLayer:registerTouchEventWithLight(v, function (  )
				self._baView:updateBottomInfo(tonumber(wId))
			end)
		elseif string.find(wName, "l_") then
			local wId = string.sub(wName, 3, -1)
			self._line[tonumber(wId)] = v
		end
	end
end

return BattleArrayMap