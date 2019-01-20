--[[
    Filename:    ItemModel.lua (内部包含背包数据)
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-05-20 23:02:36
    Description: File description
--]]

--[[
    ********数据瘦身记录********
    typeId  => t
]]--

local ItemModel = class("ItemModel", BaseModel)

function ItemModel:ctor()
    ItemModel.super.ctor(self)
    self._tabItemsCache = {}
    self._typeItemsCache = {}
    self._hadNoticeInBag = {} -- 记录本次游戏内是否
end

function ItemModel:getData()
    return self._data
end
 
-- 子类覆盖此方法来存储数据
function ItemModel:setData(data)
	local backData = self:processData(data)
    self._data = backData

	self:refreshDataOrder()
	self:refreshAllTabDataOrder()
    self:reflashData()
end


--[[
--! @function processData
--! @desc 处理数据（临时）
--! @param inData table 追加数据集合
--! @return table
--]]
function ItemModel:processData(inData)
	local backData = {}
	for k1,v1 in pairs(inData) do
		local id = tonumber(k1)
		local toolD = tab.tool[id]
		if toolD then
			v1.goodsId = id
			v1.typeId = toolD.typeId
			v1.t = toolD.typeId
			v1.tabId = toolD.tabId
				
			if toolD.typeId ~= 100 and (v1.num and v1.num > 0) then
				table.insert(backData, v1)
				if not self._tabItemsCache[v1.tabId] then
					self._tabItemsCache[v1.tabId] = {}
				end 
				table.insert(self._tabItemsCache[v1.tabId], v1)
			end
		else
			ViewManager:getInstance():onLuaError("item " .. id .." not exsit!!!")
		end
	end
	return backData
end

--[[
--! @function getItemsById
--! @desc 根据物品id获取背包内物品数据和总数
--! @param inItemId int 物品id
--! @return tempItems table 获取物品数据集合
--! @return tempCount int 获取物品数据总数
--]]
function ItemModel:getItemsById(inItemId)
	local tempItems = {}
	local tempCount = 0
	for k,v in pairs(self._data) do
		if v.goodsId == inItemId then
			tempCount = tempCount + v.num 
			table.insert(tempItems,v)
		end
	end
	return tempItems, tempCount
end


--[[
--! @function getMaterialItems
--! @desc 获取背包内材料道具
--! @return table 获取物品数据集合
--]]
function ItemModel:getMaterials()
	return self:getItemsByTabId(ItemUtils.ITEM_KIND_MATERIAL)
end

--[[
--! @function getTeamSoul
--! @desc 获取背包内怪兽魂
--! @return table 获取物品数据集合
--]]
function ItemModel:getTeamSouls()
	return self:getItemsByTabId(ItemUtils.ITEM_KIND_TEAMSOUL)
end


--[[
--! @function getHeroSoul
--! @desc 获取背包内怪兽魂
--! @return table 获取物品数据集合
--]]
function ItemModel:getHeroSouls()
	return self:getItemsByTabId(ItemUtils.ITEM_KIND_HEROSOUL)
end


--[[
--! @function getConsumables
--! @desc 获取背包内消耗品
--! @return table 获取物品数据集合
--]]
function ItemModel:getConsumables()
	return self:getItemsByTabId(ItemUtils.ITEM_KIND_CONSUMABLES)
end

--[[
--! @function getTreasures
--! @desc 获取背包内消耗品
--! @return table 获取物品数据集合
--]]
function ItemModel:getTreasures()
	return self:getItemsByTabId(ItemUtils.ITEM_KIND_TREASURE)
end

--[[
--! @function getItemByType
--! @desc 根据物品类型获取背包内物品数据和总数
--! @param inType int 物品类型
--! @return tempItems table 获取物品数据集合
--]]
function ItemModel:getItemsByType(inType)
	local tempItems = {}
	for k,v in pairs(self._data) do
		local sysItem = tab.tool[v.goodsId]
		if sysItem.typeId == inType then
			table.insert(tempItems,v)
		end
	end
	return tempItems
end

--[[
--! @function getItemsByTabId
--! @desc 根据切页类型获取技能背包内物品数据
--! @param inType int 物品类型
--! @return tempItems table 获取物品数据集合
--]]
function ItemModel:getItemsByTabId(inTabId) 
	if not self._tabItemsCache[inTabId] or not next(self._tabItemsCache[inTabId]) then
		self._tabItemsCache[inTabId] = {}
		for k,v in pairs(self._data) do
			if v.tabId == inTabId then
				table.insert(self._tabItemsCache[inTabId],v)
			end
		end
	end
	return self._tabItemsCache[inTabId] or {}
end

--[[
--! @function refreshTabDataOrder
--! @desc 对分类的数据进行排序
--! @param 
--! @return 
--]]
function ItemModel:refreshTabDataOrder(tabId)
	self._tabItemsCache[tabId] = self:getItemsByTabId(tabId)
	local sortFunc = function(a, b) 
    	if not a then ViewManager:getInstance():onLuaError(serialize(self._data)) return true end
    	if not b then ViewManager:getInstance():onLuaError(serialize(self._data)) return false end
    	local sysItemA = tab.tool[a.goodsId]
    	local sysItemB = tab.tool[b.goodsId]
        if (sysItemA.rank or 0) < (sysItemB.rank or 1) then
            return true
        end
    end

    table.sort(self._tabItemsCache[tabId], sortFunc)
end

-- 对所有分类缓存的数据排序
function ItemModel:refreshAllTabDataOrder()
	for k,v in pairs(self._tabItemsCache) do
		self:refreshTabDataOrder(k)
	end
end

--[[
--! @function refreshDataOrder
--! @desc 对数据进行排序
--! @param 
--! @return 
--]]
function ItemModel:refreshDataOrder()
	if #self._data <= 1 then 
		return 
	end

    local sortFunc = function(a, b) 
    	if not a then ViewManager:getInstance():onLuaError(serialize(self._data)) return true end
    	if not b then ViewManager:getInstance():onLuaError(serialize(self._data)) return false end
    	local sysItemA = tab.tool[a.goodsId]
    	local sysItemB = tab.tool[b.goodsId]
    	if sysItemA.rank == sysItemB.rank then -- 预防策划不配 rank字段或者配重
    		return a.goodsId < b.goodsId
    	end
        if (sysItemA.rank or 0) < (sysItemB.rank or 1) then
            return true
        end
    end

    table.sort(self._data, sortFunc)
end

--[[
--! @function handelUnsetItems
--! @desc 对删除数据进行处理
--! @param inData table
--! @return 
--]]
function ItemModel:handelUnsetItems(inData)
	local tempData = {}
	for k,v in pairs(inData) do
		if string.find(k, ".") ~= nil then
			local temp = string.split(k, "%.")
			if #temp >= 2 then
				table.insert(tempData,tonumber(temp[2]))
			end
		end
	end
	return tempData
end


--[[
--! @function updateItems
--! @desc 更新背包数据(如果存在则更新，如果数量小于=0则删除，如果不存在则插入)
--! @param inItems table 需更新背包数据集合
--! @return table
--]]
function ItemModel:delItems(inItems)
    for k2,v2 in pairs(inItems) do
        local tempIndex = 0
	    for k1,v1 in pairs(self._data) do
            if v1.goodsId == tonumber(v2) then 
                tempIndex = k1
                break
            end
	    end
	    if tempIndex > 0 then
            table.remove(self._data, tempIndex)
	    end
	end
	self._tabItemsCache = {}
	self:reflashData()

end

--[[
--! @function updateItems
--! @desc 更新背包数据(如果存在则更新，如果数量小于=0则删除，如果不存在则插入)
--! @param inItems table 需更新背包数据集合
--! @return table
--]]
function ItemModel:updateItems(inItems)
	if inItems == nil then 
		return
	end
	local isNeedUpdate = false
	local tempItemData = {}
	-- 更新操作
	for k1,v1 in pairs(self._data) do
		for k2,v2 in pairs(inItems) do
			v2.goodsId = tonumber(k2)
            if v1.goodsId == v2.goodsId then 
                tempItemData[k2] = 1
                for k3,v3 in pairs (v1) do 
                    if v2[k3] ~= nil then 
                        v1[k3] = v2[k3]
                    end
                end
                break
            end
	    end
	end
	-- 如果上面有未过滤的说明是新增
	for k2,v2 in pairs(inItems) do
		if tempItemData[k2] == nil then
			v2.goodsId = tonumber(k2)
	    	isNeedUpdate = true
	    	if tab:Tool(v2.goodsId) then
	    		local toolD = tab:Tool(v2.goodsId)
	    		v2.typeId = toolD.typeId
				v2.t = toolD.typeId
				v2.tabId = toolD.tabId
		    	table.insert(self._data, v2)
		    else
		    	ViewManager:getInstance():onLuaError("item " .. v2.goodsId .." not exsit!!!")
	    	end
   		end
    end
    self._tabItemsCache = {}
	if isNeedUpdate == true then
		self:refreshDataOrder()
	end
	if SystemUtils:enableSkillBook() then
		self._modelMgr:getModel("SpellBooksModel"):checkNotice()
	end

	self:reflashData()
end

-- 
function ItemModel:isItemHadNoticed( itemId )
	if not itemId or not tonumber(itemId) then return end
	return self._hadNoticeInBag[tonumber(itemId)]
end

--
function ItemModel:setItemNoticed( itemId )
	if not itemId or not tonumber(itemId) then return end
	self._hadNoticeInBag[tonumber(itemId)] = true
end

function ItemModel:haveNoticeItem( )
	local hadNoticeItem = false
	for k,v in pairs(self._data) do
		if not self:isItemHadNoticed(v.goodsId) then
			local toolD = tab:Tool(v.goodsId)
			local isExpBottle = (tonumber(v.goodsId) == 30201 or tonumber(v.goodsId) == 30202 or tonumber(v.goodsId) == 30203 )
		    local teamToUp -- 兵团经验小于50000 的时候pres == 2 的物品有通知
		    if toolD.pres and toolD.pres == 2 and isExpBottle then
		        teamToUp = self._modelMgr:getModel("UserModel"):getData().texp < 50000
		    end
			if (toolD.pres and toolD.pres == 1) or teamToUp then
				local giftData = tab:ToolGift(v.goodsId) or tab:EquipmentBox(v.goodsId)
			    if giftData then
			        local needLvl = giftData.openLv or giftData.openLevel
			        if needLvl then
			            local userLevel = self._modelMgr:getModel("UserModel"):getData().lvl 
			            if needLvl > userLevel then
			                hadNoticeItem = false
			            else
			            	hadNoticeItem = true
			            	break
			            end
			        else
			        	hadNoticeItem = true
			        	break
			        end
			    else
			    	hadNoticeItem = true
			    	break
			    end
			end
		end
	end
	return hadNoticeItem
end

function ItemModel:approatchIsOpen( itemId )
	local toolD = tab:Tool(itemId)
	if not toolD then return false end
    local approachData1 = toolD.approach or {}
    local approachData2 = toolD.approach2 or {}
    local approachData3 = toolD.approach3 or {}
    local approachData = {}
    -- for i = 1, #approachData3 do
    --     approachData[#approachData + 1] = approachData3[i]
    -- end
    for i = 1, #approachData2 do
        approachData[#approachData + 1] = approachData2[i]
    end
    for i = 1, #approachData1 do
        approachData[#approachData + 1] = approachData1[i]
    end
    for _,data in pairs(approachData) do
		local lvType = data[1]
	    local lvSectionId = data[2]
	    local lvBaseId = data[3]
		local stageInfo = {}
		local shopInfo = {}
		if lvType == 1 then
	        -- 普通副本
	        stageInfo = self._modelMgr:getModel("IntanceModel"):getStageInfo(lvBaseId)
	    elseif lvType == 2 then
	        -- 精英副本
	        stageInfo = self._modelMgr:getModel("IntanceEliteModel"):getStageInfo(lvBaseId)
	    elseif lvType == 3 then
	        -- 商店
	        if lvSectionId == 1 then
	            isOpen = SystemUtils["enableMysteryShop"]()
	        elseif lvSectionId == 2 then
	            isOpen = SystemUtils["enableArena"]()
	        elseif lvSectionId == 3 then
	            isOpen = SystemUtils["enableCrusade"]() 
	        elseif lvSectionId == 4 then
	            isOpen = SystemUtils["enableTreasure"]()
	        elseif lvSectionId == 5 then 
	            isOpen = SystemUtils["enableGuildShop"]() and self._modelMgr:getModel("UserModel"):getIdGuildOpen()
	        elseif lvSectionId == 6 then 
	            isOpen = LeagueUtils:isLeagueOpen()
	        elseif lvSectionId == 7 then
	            isOpen = SystemUtils["enableTreasure"]()
	        end
	        shopInfo = {isOpen = isOpen}
	    elseif lvType == 4 then
	        local isOpen = true
	        if not SystemUtils:enableGuild() or not self._modelMgr:getModel("UserModel"):getIdGuildOpen() then
	            isOpen = false
	        else
	            local level = self._modelMgr:getModel("GuildModel"):getData().level
	            if lvSectionId == 1 then -- 联盟战
	                if level < tab:GuildRoad(5).limit then
	                    isOpen = false
	                end
	            elseif lvSectionId == 2 then -- 联盟交易？支援
	                if level < tab:GuildRoad(8).limit then
	                    isOpen = false
	                end
	            end
	        end
	        shopInfo = {isOpen = isOpen}
	    elseif lvType == 5 then
	        if lvSectionId == 1 then
	            stageInfo = {isOpen = true}
	        else
	            -- 星级宝箱
	            -- 开放条件是最低的章节满足
	            stageInfo = self._modelMgr:getModel("IntanceModel"):getStageInfo(lvBaseId[1]*100+1)
	        end
	    elseif lvType == 6 then
	        if lvSectionId == 1 then
	            stageInfo = {isOpen = SystemUtils["enableElite"]()}
	        else
	            -- 星级宝箱
	            -- 开放条件是最低的章节满足
	            stageInfo = self._modelMgr:getModel("IntanceEliteModel"):getStageInfo(lvBaseId[1]*100+1)
	        end
	    elseif lvType == 7 then
	        -- 玩法
	        if lvSectionId == 1 then
	            stageInfo = { isOpen = SystemUtils["enableDwarvenTreasury"]()}
	        elseif lvSectionId == 2 then
	            stageInfo = { isOpen = SystemUtils["enableCrypt"]()}
	        elseif lvSectionId == 3 then
	            stageInfo = { isOpen = SystemUtils["enableBoss"]()}
	        elseif lvSectionId == 4 then
	            stageInfo = { isOpen = SystemUtils["enableCloudCity"]()}
	        end             
	    elseif lvType == 8 then
	        -- 远征
	        stageInfo = {
	            isOpen = SystemUtils["enableCrusade"]()
	        }
	    elseif lvType == 10 then
	        stageInfo = {
	            isOpen = SystemUtils["enableDailyTask"]()
	        }
	    elseif lvType == 11 then
	        stageInfo = {
	            isOpen = true
	        }
	    elseif lvType == 12 then
	        stageInfo = {
	            isOpen = SystemUtils["enableMF"]()
	        }
	    elseif lvType == 13 then
	        local stageId = lvBaseId
	        local guanNum = stageId%4
	        if guanNum == 0 then
	            guanNum = 4 
	        end
	        stageInfo = {
	            isOpen = SystemUtils:enableCloudCity() and self._modelMgr:getModel("CloudCityModel"):canArriveStage(stageId) or false,
	            notOpenTipDes = "通关第".. math.ceil(stageId/4) .."层第" .. guanNum .."关开启",
	        }
	    elseif lvType == 14 then
	        stageInfo = {
	            isOpen = LeagueUtils:isLeagueOpen()
	        }
	    elseif lvType == 15 then
	        stageInfo = {
	            isOpen = false -- 暂时关闭 -- LeagueUtils:isLeagueOpen()
	        }
	    end
	    if stageInfo.isOpen or shopInfo.isOpen then
	    	return true
	    end
    end
    return false
end

-- 获取英雄皮肤属性
function ItemModel:getHeroSkinAttr(hSkin)
    local attrs = {atk=0,def=0,int=0,ack=0}
    local changeMap = {[101] = "atk",[102] = "def", [103]="int",[104] = "ack"}
    local skinData = hSkin or self._userModel:getTeamSkinData()
    local skinTb = tab.teamSkin
    for k,v in pairs(skinData) do
        for kk,vv in pairs(v) do
            local tempData = skinTb[tonumber(kk)]
            if tempData and tempData.addAttr then
                for key,value in pairs(tempData.addAttr) do                    
                    local changeType = changeMap[tonumber(value[1])]
                    if changeType then
                        attrs[changeType] = attrs[changeType]+tonumber(value[2])
                    end
                end
            end
        end
    end
    return attrs
end

function ItemModel:isHaveAutoUseMaterial()
	local param = {}
	param.goodsIds  = {}
	param.goodsNums  = {}
	local tem = tab:Setting("Auto_Item").value
	for i,v in ipairs(tem) do
		for ii,good in ipairs(self._data) do
			if tonumber(good.goodsId) == tonumber(v) and good.num > 0 then
				table.insert(param.goodsIds,good.goodsId)
				local num = good.num
				local maxNum = tab:Setting("G_TOOL_BOX_MAX").value
				--超过200 按200算
				if good.num > maxNum then
					num = maxNum
				end
				table.insert(param.goodsNums,num)
			end
		end
	end
	return #param.goodsNums > 0 , param
end

return ItemModel