--[[
    Filename:    SkillTalentModel.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-12-11 14:41:57
    Description: File description
--]]

local SkillTalentModel = class("SkillTalentModel", BaseModel)

function SkillTalentModel:ctor()
    SkillTalentModel.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
    self._spellBooksModel = self._modelMgr:getModel("SpellBooksModel")
    self._heroModel = self._modelMgr:getModel("HeroModel")
end

--[[
	user
   spTalent
      id
         l   等级
         s  战力

]]
function SkillTalentModel:setData(data)
	local tabData = clone(tab.skillBookTalent)
	for _,_data in pairs (tabData) do 
		_data.level = 0
		_data.score = 0
	end
	for id,_data in pairs (data) do 
		local num_id = tonumber(id)
		local data = tabData[num_id]
		data.level = _data.l
		data.score = _data.s
	end
	table.sort(tabData, function(a ,b)
		local aL = a.level and a.level > 0 and 1 or 0
		local bL = b.level and b.level > 0 and 1 or 0
		if aL ~= bL then
			return aL > bL
		elseif a.order ~= b.order then
			return a.order < b.order
		end
	end)

	self._data = tabData
end

function SkillTalentModel:sortData()
	if not self._data then return end
	table.sort(self._data, function(a ,b)
		local aL = a.level and a.level > 0 and 1 or 0
		local bL = b.level and b.level > 0 and 1 or 0
		if aL ~= bL then
			return aL > bL
		elseif a.order ~= b.order then
			return a.order < b.order
		end
	end)
end

function SkillTalentModel:updateData(data)
	for id,_data in pairs (data) do 
		local num_id = tonumber(id)
		for _,d in pairs (self._data) do 
			if num_id == d.id then
				d.level = _data.l
				d.score = _data.s
			end

		end
	end
	-- dump(self._data,"SkillTalentModel:updateData",10)
	self:reflashData()
end

--根据天赋id获取对应数据
function SkillTalentModel:dataWithId(tid)
	local numid = tonumber(tid)
	for _,data in pairs (self._data) do 
		if data.id == numid then
			return data
		end
	end
end

function SkillTalentModel:getTotalScore()
	if not self._data then return 0 end
	local num = 0
	for _,data in pairs (self._data) do 
		num = num + data.score
	end
	return num
end

--[[
	获取法术天赋的最大等级
	@param id 法术天赋id
	@return maxlevel 当前最大等级，最终最大等级
]]
function SkillTalentModel:getTalentMaxLevelById(id)
	local talentData = tab.skillBookTalent[tonumber(id)]
	local Skilldata = self._spellBooksModel:getData()
	local maxLevel = 0 --当前最大等级
	local maxLevel2 = 0 --最终最大等级
	for _,skillId in pairs (talentData.skillbook) do 
		local data = tab.skillBookBase[tonumber(skillId)]
		maxLevel2 = maxLevel2 + #data.skillbook_exp
		local data = Skilldata[tostring(skillId)]
		if data then
			maxLevel = maxLevel + data.l
		end
	end
	return maxLevel,maxLevel2
end

--[[
	获取法术受天赋影响的技能cd值
	@skillid 法术id
	@return num 受影响的值
]]
function SkillTalentModel:getSkillCdReduceNum(skillid)
	if not self._data then return 0 end
	local skillid = tonumber(skillid)
	local findData
	for _, data in pairs (self._data) do
		if data.level > 0 then
			local effectSkills = data.skillbookex
			if effectSkills then
				for _,id in pairs (effectSkills) do 
					if skillid == id then
						findData = data
					end
				end
			end
		end 
	end
	if not findData then return 0 end
	local talentLevel = findData.level
	local num = 0
	local skillBaseCd = tab.playerSkillEffect[skillid].cd

	local baseNum = 0
	local baseType = findData.sort1
	if baseType == 11 then
		baseNum = math.max(findData.base,findData.base + (talentLevel - 1) * findData.addition)
	elseif baseType == 12 then
		baseNum = math.max(findData.base,findData.base + (talentLevel - 1) * findData.addition) / 100
	end

	---解锁的阶段属性
	local index = 0
	if findData.advancedlv then
		for _,level in pairs (findData.advancedlv) do 
			if talentLevel < level then
				break
			end
			index = index + 1
		end
	end 
	if index == 0 then return baseNum end
	for i=1,index do 
		local sort = findData["advancedsort"..i]
		local base = findData["advancedbase"..i]
		if sort == 11 then
			baseNum = baseNum + base
		elseif sort == 12 then
			baseNum = baseNum + base/100
		end
	end

	return baseNum
end

--[[
	获取法术受天赋影响的技能魔耗值
	@skillid 法术id
	@return num 受影响的值
]]
function SkillTalentModel:getSkillManaReduceNum(skillid)

	if not self._data then return 0 end
	local skillid = tonumber(skillid)
	local findData
	for _, data in pairs (self._data) do
		if data.level > 0 then
			local effectSkills = data.skillbookex
			if effectSkills then
				for _,id in pairs (effectSkills) do 
					if skillid == id then
						findData = data
					end
				end
			end
		end 
	end
	if not findData then return 0 end
	local talentLevel = findData.level
	local num = 0
	local skillBaseCd = tab.playerSkillEffect[skillid].manacost

	local baseNum = 0
	local baseType = findData.sort1
	if baseType == 9 then
		baseNum = math.max(findData.base,findData.base + (talentLevel - 1) * findData.addition)
	elseif baseType == 10 then
		baseNum = math.max(findData.base,findData.base + (talentLevel - 1) * findData.addition) / 100
	end

	---解锁的阶段属性
	local index = 0
	if findData.advancedlv then
		for _,level in pairs (findData.advancedlv) do 
			if talentLevel < level then
				break
			end
			index = index + 1
		end
	end 
	if index == 0 then return baseNum end
	for i=1,index do 
		local sort = findData["advancedsort"..i]
		local base = findData["advancedbase"..i]
		if sort == 9 then
			baseNum = baseNum + base
		elseif sort == 10 then
			baseNum = baseNum + base/100
		end
	end

	return baseNum
end

function SkillTalentModel:getTalentDataInFormat()
	local result = {}
	if not self._data then return result end
	for _,data in pairs (self._data) do
	  local data_ = {}
	  data_.l =  data.level
	  data_.s =  data.score
	  result[tostring(data.id)] = data_
	end
	return result
end


--[[
	获取法术天赋类型加成
]]
function SkillTalentModel:getTalentAdd(id, otherSp)
	local result = {}
	for i=1,14 do 
		result["$talent"..i] = 0
	end

	if not otherSp then return result end
	local realData = otherSp
	if otherSp then
		local tabData = clone(tab.skillBookTalent)
		for _,_data in pairs (tabData) do 
			_data.level = 0
			_data.score = 0
		end
		for id,_data in pairs (otherSp) do 
			local num_id = tonumber(id)
			local data = tabData[num_id]
			data.level = _data.l
			data.score = _data.s
		end
		realData = tabData
	end
	local skillid = tonumber(id)
	local findData
	local placeSkill = self._heroModel:getPlaceSkillIds() or {}
	print("getTalentAdd:",id)
	for _, data in pairs (realData) do
		if data.level > 0 then
			local effectSkills = data.skillbookex
			if effectSkills then
				for _,id in pairs (effectSkills) do 
					if skillid == id or placeSkill[skillid] == id then
						findData = data
					end
				end
			end
		end 
	end
	if not findData then return result end
	local talentLevel = findData.level
	local addDamageNum = 0
	local addDamagePer = 0
	local baseType = findData.sort1
	if baseType == 1 or baseType == 3 or baseType == 13 then
		result["$talent"..baseType] = result["$talent"..baseType] + math.max(findData.base,findData.base + (talentLevel - 1) * findData.addition)
	else
		result["$talent"..baseType] = result["$talent"..baseType] + math.max(findData.base,findData.base + (talentLevel - 1) * findData.addition)/100
	end
	
	---解锁的阶段属性
	local index = 0
	if findData.advancedlv then
		for _,level in pairs (findData.advancedlv) do 
			if talentLevel < level then
				break
			end
			index = index + 1
		end
	end 
	if index == 0 then return result end
	for i=1,index do 
		local sort = findData["advancedsort"..i]
		local base = findData["advancedbase"..i]
		print("sort",sort,"base",base)
		if sort == 1 or sort == 3 or sort == 13 then
			result["$talent"..sort] = result["$talent"..sort] + base
		else
			result["$talent"..sort] = result["$talent"..sort] + base/100
		end
	end
	-- dump(result)
	return result
end

--是否有小红点
function SkillTalentModel:checkRed()
	--曾进入功能
	local his = SystemUtils.loadAccountLocalData("SKILL_TALENT_IN")
	if not his then
		return true
	end
	
	if not self._data then 
		return false 
	end


	if self:checkIsCanActOrUp() then
		local time = SystemUtils.loadAccountLocalData("SKILL_TALENT_IN_TIME")
		if not time then
			return true
		else
			local curTime = self._userModel:getCurServerTime()
			if TimeUtils.checkIsOtherDay(time,curTime) then
				return true
			end
		end
	end
	return false
end

--[[
	根据法术天赋ID判断是否解锁
	@skillid 法术天赋id
	@return true已激活，false 未激活
]]
function SkillTalentModel:isSkillTalentActive(skillid)
	-- dump(self._data,"datadata==>",5)
	if not self._data then return false end
	local isActive = false
	for k,v in pairs(self._data) do
		if tonumber(v.id) == tonumber(skillid) and v.level > 0 then
			isActive = true
			break
		end
	end
	return isActive
end

function SkillTalentModel:checkIsCanActOrUp()
	--可激活
	local activeCon = false
	for _,data in pairs (self._data) do 
		if self:checkActiveCondition(data.id, data) == 3 then  
			return true
		end
	end

	--有可升级
	if not activeCon then
		for _,data in pairs (self._data) do 
			if self:checkUpCondition(data.id, data) then  
				return true
			end
		end
	end

	return false
end

--[[
	检查某个法术天赋是否满足激活条件
	@param id 法术天赋id
	@return --1未激活 2升级碎片不足 3可激活 4已激活
	--by wangyan
]]  
function SkillTalentModel:checkActiveCondition(inId, inData)
	if not inId then
		return 1
	end

	if not inData then
		for _,data in pairs (self._data) do 
			if inId == data.id then
				inData = data
				break
			end
		end
	end

	local isAllAc = true   
	local level = inData.level
	local skillbook = inData.skillbook
	local Skilldata = self._spellBooksModel:getData()
	for _,skillBookId in pairs (skillbook) do 
		local data = Skilldata[tostring(skillBookId)]
		if not data then
			isAllAc = false
			break
		end
	end

	--碎片数判断
	local isCanUp = false
	local costTabId = inData.costsort
	local maxlevel = self:getTalentMaxLevelById(inId)
	if level < maxlevel then
	    local costTabData = tab.skillBookTalentExp[level+1]
	    if costTabData then
	    	local costData = costTabData["cost" .. costTabId]
	    	if costData then
	    		local costType,costNum = costData[1][1],costData[1][3]
			    local userHave = self._userModel:getData()[costType] or 0
			    if userHave >= costNum then
			    	isCanUp = true
			    end
	    	end
	    end
	end

	local actState = 1
	if not isAllAc then
		actState = 1
	else
		if level == 0 then
			if isCanUp then
				actState = 3
			else
				actState = 2
			end
		else
			actState = 4
		end
	end

	return actState
end

--[[
	检查某个法术天赋是否满足升级条件
	@param id 法术天赋id
	@return true可以升级，false 不可升级
	--by wangyan
]]  
function SkillTalentModel:checkUpCondition(inId, inData)
	if not inId then
		return false
	end

	if self:checkActiveCondition(inId) < 4 then
		return false
	end

	if not inData then
		for _,data in pairs (self._data) do 
			if inId == data.id then
				inData = data
				break
			end
		end
	end

	local level = inData.level
	local costTabId = inData.costsort
	local maxlevel = self:getTalentMaxLevelById(inId)
	if level < maxlevel then
	    local costTabData = tab.skillBookTalentExp[level+1]
	    if costTabData then
	    	local costData = costTabData["cost" .. costTabId]
	    	if costData then
	    		local costType,costNum = costData[1][1],costData[1][3]
			    local userHave = self._userModel:getData()[costType] or 0
			    if userHave >= costNum then
			    	return true
			    end
	    	end
	    end
	end

	return false
end

return SkillTalentModel