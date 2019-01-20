--[[
 	@FileName 	BattleArrayModel.lua
	@Authors 	yuxiaojing
	@Date    	2018-07-19 15:29:22
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

--[[

	数据结构
	{
		"101" = {
			lv 		等级
			aIds 	当前等级激活战阵
			aAIds	当前激活过的战阵ID
			soul 	该阵营战魂数
			score 	该阵营战力
		},
		"102" = {
			...
		}

	}

--]]

local BattleArrayModel = class("BattleArrayModel", BaseModel)

function BattleArrayModel:ctor(  )
	BattleArrayModel.super.ctor(self)

	self._itemModel = self._modelMgr:getModel("ItemModel")
	self._userModel = self._modelMgr:getModel("UserModel")

	self._data = {}
	self:initDiagramData()
end

function BattleArrayModel:setBattleArrayData( data )
	self._data = {}
	self._data = data

	for k, v in pairs(self._data) do
        if not v["aIds"] then v["aIds"] = {} end
        if not v["aAIds"] then v["aAIds"] = {} end
        if not v["score"] then v["score"] = 0 end
        local newT = {}
        for k1, v1 in pairs(v["aIds"]) do
        	newT[tonumber(k1)] = v1
        end
        v["aIds"] = newT

        local newT1 = {}
        for k1, v1 in pairs(v["aAIds"]) do
        	newT1[tonumber(k1)] = v1
        end
        v["aAIds"] = newT1
    end
end

function BattleArrayModel:updateData( data )
	for k, v in pairs(data) do
		if not v["aIds"] then v["aIds"] = {} end
        if not v["aAIds"] then v["aAIds"] = {} end
        if not v["score"] then v["score"] = 0 end
		local newT = {}
        for k1, v1 in pairs(v["aIds"]) do
        	newT[tonumber(k1)] = v1
        end
        v["aIds"] = newT

        local newT1 = {}
        for k1, v1 in pairs(v["aAIds"]) do
        	newT1[tonumber(k1)] = v1
        end
        v["aAIds"] = newT1

		self._data[k] = v
	end
end

function BattleArrayModel:updateSoul( data )
	for k, v in pairs(data) do
		if v["soul"] then
			if self._data[k] then
				self._data[k]["soul"] = v["soul"]
			end
		end
	end
end

function BattleArrayModel:getData(  )
	return self._data
end

function BattleArrayModel:getDataByRace( raceType )
	local data = self._data[tostring(raceType)]
	if data == nil then
		data = {}
		data.lv = 1
		data.aIds = {}
		data.aAIds = {}
		data.score = 0
		data.soul = 0
	end
	return clone(data)
end

function BattleArrayModel:getLevelupPointsNum( raceType )
	local baData = self:getDataByRace(raceType)
	local level = baData.lv or 1
	local DBBattleUp = self._battleUp[raceType] or {}
	local dd = DBBattleUp[level] or {}
	return dd.levelupPointsNum or 84
end

function BattleArrayModel:getpropDataByRace( raceType )
	raceType = raceType or 101
	local baData = self:getDataByRace(raceType)
	local DBData = self._diagramDB[raceType] or {}
	local DBBattleUp = self._battleUp[raceType] or {}
	local base = {}
	local level = baData.lv or 1

	local baseAttr, allAttr = {}, {}
	local baseCoe = 1
	local allCoe = 1

	for i = 1, level do
		local levelupData = DBBattleUp[i] or {}
		allCoe = levelupData.coefficientAtt2 or 1
		if i < level then
			baseCoe = levelupData.coefficientAtt2 or 1
		elseif i == level then
			baseCoe = 0
		end
		local pointMaxId = levelupData.pointId
		for k, v in pairs(DBData) do
			if tonumber(k) < pointMaxId then
				local attr = v.diagramAtt or {}
				for k1, v1 in pairs(attr) do
					local id = v1[1]
					local num = v1[2]
					if not baseAttr[id] then baseAttr[id] = 0 end
					if not allAttr[id] then allAttr[id] = 0 end
					baseAttr[id] = baseAttr[id] + self:formatnumberDecimal(num * baseCoe, 2)
					allAttr[id] = allAttr[id] + self:formatnumberDecimal(num * allCoe, 2)
				end
			end
		end
	end

	local levelupData = DBBattleUp[level] or {}
	local pointMaxId = levelupData.pointId
	for k, v in pairs(baData.aIds) do
		if tonumber(k) < pointMaxId then
			local dd = DBData[k] or {}
			local attr = dd.diagramAtt or {}
			for k1, v1 in pairs(attr) do
				local id = v1[1]
				local num = v1[2]
				local levelupData = DBBattleUp[level] or {}
				local coe = levelupData.coefficientAtt2 or 1
				baseAttr[id] = baseAttr[id] + self:formatnumberDecimal(num * coe, 2)
			end
		end
	end

	return baseAttr, allAttr
end

function BattleArrayModel:getCanActiveArray( raceType, activeList, isInit )
	local res = {}
	local data = self._diagramDB[raceType] or {}
	local initPoint = self._initPoint[raceType] or {}
	local pointMaxId = self:getBattleUpLevelData(raceType).pointId
	for k, v in pairs(activeList) do
		local temp = data[k]
		if temp then
			local aftpositionId = temp.aftpositionId or {}
			for k1, v1 in pairs(aftpositionId) do
				if not activeList[v1] and tonumber(v1) < pointMaxId then
					res[v1] = 1
				end
			end
		end
	end
	if isInit then
		for k, v in pairs(initPoint) do
			if not activeList[v] then
				res[v] = 1
			end
		end
	end
	return res
end

function BattleArrayModel:getActiveLine( raceType, active, canActive )
	raceType = raceType or 101
	local a1 = clone(active or {})
	local a2 = clone(canActive or {})
	for k, v in pairs(a2) do
		a1[k] = v
	end
	local res = {}
	if table.nums(a1) <= 0 then return res end
	local data = self._diagramDB[raceType] or {}
	local lineData = tab.battleLineMap
	local lineMaxId = self:getBattleUpLevelData(raceType).lineIdRead
	for k, v in pairs(a1) do
		local d1 = data[k]
		if d1 then
			local nearLine = d1.nearLine or {}
			for k1, v1 in pairs(nearLine) do
				local d2 = lineData[v1]
				if d2 and d2.pointId then
					local points = d2.pointId
					local isY = true
					for k2, v2 in pairs(points) do
						if not a1[v2] then
							isY = false
						end
					end
					if isY and tonumber(v1) < lineMaxId then
						res[v1] = 1
					end
				end
			end
		end
	end
	return res
end

function BattleArrayModel:insertReturnRes( res, data )
	local isHave = false
	for k, v in pairs(res) do
		if v[1] == data[1] and v[2] == data[2] then
			isHave = true
			v[3] = v[3] + data[3]
		end
	end
	if not isHave then
		table.insert(res, data)
	end
end

function BattleArrayModel:getResetReturnRes( raceType )
	raceType = raceType or 101
	local baData = self:getDataByRace(raceType)
	local aIds = baData.aIds or {}
	local DBBattleUp = self._battleUp[raceType] or {}
	local levelupData = DBBattleUp[baData.lv or 1]
	local coe = levelupData.coefficientAtt1 or 1
	local coe1 = levelupData.coefficientAtt4 or 1
	local data = self._diagramDB[raceType] or {}
	local res = {}
	for k, v in pairs(aIds) do
		local dd = data[k]
		if dd and dd.ecpend then
			for k1, v1 in pairs(dd.ecpend) do
				local itemType = v1[1]
				local itemId = v1[2]
				local itemNum = self:formatConsumeNumber(math.ceil(v1[3] * coe))
				local resD = {itemType, itemId, itemNum}
				self:insertReturnRes(res, resD)
			end
		end
		if dd and dd.ecpend2 then
			for k1, v1 in pairs(dd.ecpend2) do
				local itemType = v1[1]
				local itemId = v1[2]
				local itemNum = math.ceil(v1[3] * coe1)
				local resD = {itemType, itemId, itemNum}
				self:insertReturnRes(res, resD)
			end
		end
	end
	return res
end

function BattleArrayModel:getRedPrompt(  )
	local res = {}
	local openRace = tab.setting["BATTLEARRAY_TEAMOPEN"].value
	for k, v in pairs(openRace) do
		local baData = self:getDataByRace(v)
		local soul = baData.soul or 0
		local activeList = baData.aIds or {}
		local DBData = self:getDBDataByRace(v)
		local aNum = table.nums(activeList)
		local battleUpDB = self:getBattleUpDBDataByRace(v)
		local level = baData.lv or 1
		local dNum = battleUpDB[level].levelupPointsNum
		if aNum >= dNum then
			local maxLevel = table.nums(battleUpDB)
			if level < maxLevel then
				local consumeD = battleUpDB[level]["ecpend"] or {}
				local itemId = consumeD[1][2]
				local itemType = consumeD[1][1]
				if itemType and itemType ~= "tool" then
					itemId = IconUtils.iconIdMap[itemType]
				end
				local haveNum, needNum = 0, consumeD[1][3]
	        	if "tool" == itemType then
	        		local _, num = self._itemModel:getItemsById(itemId)
	        		haveNum = num
	        	elseif "gold" == itemType then
	        		haveNum = self._userModel:getData().gold
	        	elseif "gem" == itemType then
	        		haveNum = self._userModel:getData().freeGem + self._userModel:getData().payGem
	        	end
				if haveNum >= needNum then
					table.insert(res, v)
				end
			end
		else
			local canActiveList = self:getCanActiveArray(v, activeList, true)
			for k1, v1 in pairs(canActiveList) do
				local dd = DBData[k1]
				if dd then
					local coe1 = battleUpDB[level].coefficientAtt1 or 1
					local coe2 = battleUpDB[level].coefficientAtt4 or 1
					local consume1 = dd["ecpend"]
					local needNum = 0
					if consume1 and consume1[1] and consume1[1][3] then
						needNum = self:formatConsumeNumber(math.ceil(consume1[1][3] * coe1))
					end
					if soul >= needNum then
						local consume2 = dd["ecpend2"] or {}
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
					        		table.insert(res, v)
					        		break
					        	end
					        else
					        	table.insert(res, v)
					        	break
					        end
						else
							table.insert(res, v)
							break
						end
					end
				end
			end
		end
	end
	return res
end

function BattleArrayModel:initDiagramData(  )
	self._diagramDB = {}
	self._initPoint = {}
	local dbData = tab.battleDiagram
	local openRace = tab.setting["BATTLEARRAY_TEAMOPEN"].value
	for k, v in pairs(openRace) do
		self._diagramDB[v] = {}
		self._initPoint[v] = {}
	end
	for k, v in pairs(dbData) do
		if self._diagramDB[v.battleId] then
			self._diagramDB[v.battleId][v.diagramId] = clone(v)
		end
		if self._initPoint[v.battleId] then
			if v.initPoint and v.initPoint == 1 then
				table.insert(self._initPoint[v.battleId], v.diagramId)
			end
		end
	end

	--BattleUp
	self._battleUp = {}
	local dbData = tab.battleUp
	for k, v in pairs(openRace) do
		self._battleUp[v] = {}
	end
	for k, v in pairs(dbData) do
		local raceType = v.battleId
		if self._battleUp[raceType] then
			self._battleUp[raceType][v.battleLevel] = clone(v)
		end
	end
end

function BattleArrayModel:getDBDataByRace( raceType )
	raceType = raceType or 101
	return self._diagramDB[raceType] or {}
end

function BattleArrayModel:getBattleUpDBDataByRace( raceType )
	raceType = raceType or 101
	return self._battleUp[raceType] or {}
end

function BattleArrayModel:getBattleUpLevelData( raceType )
	raceType = raceType or 101
	local DBBattleUp = self._battleUp[raceType]	or {}
	local baData = self:getDataByRace(raceType)
	local level = baData.lv or 1
	local dd = DBBattleUp[level] or {}
	return dd
end

function BattleArrayModel:showBattleArrayView( raceType )
	raceType = raceType or 101
	local openRace = tab.setting["BATTLEARRAY_TEAMOPEN"].value
	local isReq = false
	for k, v in pairs(openRace) do
		if self._data[tostring(v)] == nil then
			isReq = true
		end
	end
	if not isReq then
    	self._viewMgr:showView("battleArray.BattleArrayView", {raceType = raceType})
		return
	end
	self._serverMgr:sendMsg("BattleArrayServer", "getInfo", {}, true, {}, function(success, data)
    	self._viewMgr:showView("battleArray.BattleArrayView", {raceType = raceType})
    end, function ( errorId )
        errorId = tonumber(errorId)
        print("errorId:" .. errorId)
        self._viewMgr:unlock()
    end)
end

function BattleArrayModel:getBattleSoulNum( fType )
	fType = fType or 101
	local dd = self:getDataByRace(fType)
	return dd.soul or 0
end

function BattleArrayModel:formatnumberDecimal( value, num )
    local initValue = value
    num = num or 5
    if num > 5 then num = 5 end
    local fValue = math.floor(value)
    if fValue == value then -- 没有小数
        return value
    end
    -- 有小数
    local decNum = 0
    for i = 1, num do
        value = value * 10
        fValue = math.floor(value)
        if value > fValue then
            decNum = decNum + 1
        elseif value == fValue then
            decNum = decNum + 1
            break
        end
    end
    local res = string.format("%0." .. decNum .. "f", initValue)
    return res
end

function BattleArrayModel:formatConsumeNumber( value )
	local bitValue = value % 10
	if bitValue == 0 then
		return value
	end
	value = value - bitValue
	if bitValue >= 5 then
		value = value + 10
	end
	return value
end

function BattleArrayModel:getRateFightReachNum( fightNum )
	local res = 0
	if not fightNum or type(fightNum) ~= "number" then
		return res
	end
	local openRace = tab.setting["BATTLEARRAY_TEAMOPEN"].value
	for k, v in pairs(self._data) do
		if v and v.score and v.score >= fightNum and table.indexof(openRace, tonumber(k)) then
			res = res + 1
		end
	end
	return res
end

return BattleArrayModel