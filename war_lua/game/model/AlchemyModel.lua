local AlchemyModel = class("AlchemyModel", BaseModel)

function AlchemyModel:ctor()
	AlchemyModel.super.ctor(self)
	self._alchemy = {}
	
	self._libType = nil
	self._formulaData = {}
end

function AlchemyModel:updateAlchemyData(data)
	if type(data)=="table" then
		for key,value in pairs(data) do
			if type(value)~="table" then
				self._alchemy[key] = value
			else
				if self._alchemy[key] and table.nums(value)~=0 then
					for i,v in pairs(value) do
						self._alchemy[key][i] = v
					end
				else
					self._alchemy[key] = value
				end
			end
		end
	end
end

function AlchemyModel:setData(data)
	if data then
		self._alchemy = data
	end
end

function AlchemyModel:getData()
	return self._alchemy
end

local sortFun = function(a, b)
	return a.planOrder < b.planOrder
end

function AlchemyModel:getFormulaLibraryData(libType)
	local backData = {}
	local allData = tab.alchemyPlan
	for i,v in pairs(allData) do
		if v.isVisible==1 then
			if not libType then
				table.insert(backData, v)
			else
				for _,inType in ipairs(v.planClassaA) do
					if inType==libType then
						table.insert(backData, v)
						break
					end
				end
			end
		end
	end
	table.sort(backData, sortFun)
	return backData
end

function AlchemyModel:getFormulaTableData(page)
	local backData = {}
	self._formulaData = {}
	for i,v in pairs(self._alchemy.rAids) do
		if v~=0 then
			local tempData = clone(tab.alchemyPlan[v])
			tempData.gridId = i
			table.insert(self._formulaData, tempData)
		end
	end
	table.sort(self._formulaData, sortFun)
	local pageCount = 20
	local beginIndex = (page-1)*20+1
	local indexLimit = (page-1)*20+20
	for i=beginIndex, indexLimit do
		table.insert(backData, self._formulaData[i])
	end
	local maxPage = table.nums(self._formulaData)
	maxPage = math.ceil(maxPage/pageCount)
	maxPage = maxPage==0 and 1 or maxPage
	return backData, maxPage
end

function AlchemyModel:getQuickFormulaData()
	local backData = {}
	local tempData = {}
	if self._formulaData then
		for i,v in pairs(self._formulaData) do
			local classOrder = v.planClassB
			if not backData[classOrder] then
				backData[classOrder] = {}
			end
			table.insert(backData[classOrder], clone(v))
		end
	else
		
	end
	return backData
end

function AlchemyModel:getNowProFormulaId()
	return self._alchemy.aid, self._alchemy.proTime
end

function AlchemyModel:getPreProData()
	return self._alchemy.pAids or {}
end

function AlchemyModel:getConsumeTools()
	local backData = {}
	
	local itemAll = self._modelMgr:getModel("ItemModel"):getData()
	local tabAlchemyPoint = tab.toolAlchemyPoint
	for i,v in ipairs(itemAll) do
		if tabAlchemyPoint[v.goodsId] then
			local tempItem = clone(v)
			tempItem.goodsData = tab.tool[v.goodsId]
			table.insert(backData, tempItem)
		end
	end
	return backData
end

function AlchemyModel:getUnlockNum()
	return self._alchemy.unlockGNum or 0
end

function AlchemyModel:getRefreshTimes()
	return self._alchemy.refreshT or 0
end

function AlchemyModel:getCanUseToolDataByFormulaId(id)
	local formulaData = tab.alchemyPlan[id]
	local needCount = formulaData.costRandomMaterial[2]
	local backData = {}
	for i,v in ipairs(formulaData.costRandomMaterial[1]) do
		if v[1]~="tool" then
			self._viewMgr:showTip("消耗物品类型配置错误，请联系相关策划人员")
			return
		end
		local items = self._modelMgr:getModel("ItemModel"):getItemsById(v[2])
		for i,v in ipairs(items) do
			table.insert(backData, v)
		end
	end
	return backData
end

function AlchemyModel:getNowPreProCount()
	if self._alchemy and self._alchemy.pAids then
		return table.nums(self._alchemy.pAids)
	else
		return 0
	end
end

function AlchemyModel:getFormulaProductTimes(formulaId)
	local times = 0
	if self._alchemy.dPAids then
		times = self._alchemy.dPAids[tostring(formulaId)] or 0
	end
	return times
end

function AlchemyModel:getFormulaSpeedUpTimes(formulaId)
	local times = 0
	if self._alchemy.dSAids then
		times = self._alchemy.dSAids[tostring(formulaId)] or 0
	end
	return times
end

function AlchemyModel:getFormulaLifeUseTimes(formulaId)
	local times = 0
	if self._alchemy.cPAids then
		times = self._alchemy.cPAids[tostring(formulaId)] or 0
	end
	return times
end

function AlchemyModel:getProFormulaIdByIndex(index)
	if self._alchemy and self._alchemy.pAids then
		return self._alchemy.pAids[tostring(index)]
	end
end

function AlchemyModel:getAlchemyReport()
	if self._alchemy and self._alchemy.reports then
		return self._alchemy.reports
	end
end

function AlchemyModel:getLibData()
	local backData = {}
	if self._alchemy and self._alchemy.tList then
		for i,v in pairs(self._alchemy.tList) do
			if v~="" then
				local tempData = json.decode(v)
				tempData.gridId = tonumber(i)
				table.insert(backData, tempData)
			end
		end
	end
	return backData
end

return AlchemyModel