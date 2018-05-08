--[[
    Filename:    ShopModel.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-11-23 19:11:18
    Description: File description
--]]

local ShopModel = class("ShopModel", BaseModel)

function ShopModel:ctor()
    ShopModel.super.ctor(self)
    self._data = {}
    self._refreshTimes = {}
    self._shopRefreshTimes = tab:Setting("G_MYSTERY_BONUS_REFLASH").value
end

function ShopModel:setData(data)
    -- dump(data)
    if data and table.nums(data) > 0 then 
    	self:updateShop(data)
        self:reflashData()
    else
        self._data = {}
    end

end

function ShopModel:getData()
    return self._data
end

function ShopModel:getShopByType( shopTp )
	return self._data[shopTp]
end

function ShopModel:setShopByType( shopTp )
	-- body
end

function ShopModel:updateShop( inData )
    -- dump(inData)
    local function sortGoods(inKey, inGds)  
        if not inGds then return end

        local goodsTemp = {}
        local sysShopSlot = tab.shopSlot
        for i,v in ipairs(sysShopSlot) do
            local curIndex = v[inKey .. "Slot"] or i
            if curIndex then
                goodsTemp[tostring(i)] = inGds[tostring(curIndex)]
            end
        end
        return goodsTemp
    end

	for k,v in pairs(inData) do
        v["goods"] = sortGoods(k, v["goods"])  --by wangyan

		self._data[k] = v
        self._refreshTimes[k] = v.reflashTimes or self._refreshTimes[k]
        self._data[k].reflashTimes = self._refreshTimes[k]
    end
    self:reflashData()
end
function ShopModel:updateShopGoods( inData )
    -- dump(inData)
    for k,shop in pairs(inData) do
        if self._data[k] then -- 判断商店
            if k == "league" or k == "godWar" then
                for k1,itemNum in pairs(shop) do
                    if self._data[k][k1] then
                        if type(self._data[k][k1]) == "table" then
                            for k2,v2 in pairs(itemNum) do
                                self._data[k][k1][k2] = v2
                            end
                        else
                            self._data[k][k1] = itemNum
                        end
                    end
                end
            else
                for k1,goods in pairs(shop) do
                    for k2,itemNum in pairs(goods) do
                        if self._data[k]["goods"][k2] then
                            self._data[k]["goods"][k2] = itemNum
                        end
                    end
                end
            end
            self._data[k].reflashTimes = shop.reflashTimes or self._refreshTimes[k]
        end
    end
    self:reflashData()
end
function ShopModel:updateShopGoodsAfterBuy( inData )
    -- dump(inData,"************")
    for k,shop in pairs(inData) do
        if self._data[k] then -- 判断商店
            if k == "league" or k == "godWar" then
                for k1,itemNum in pairs(shop) do
                    local showIndex = self:getShowIndex(k1, k)
                    local temp = self._data[k][k1]
                    if showIndex then
                        temp = self._data[k][tostring(showIndex)]
                    end

                    if temp then
                        if type(temp) == "table" then
                            for k2,v2 in pairs(itemNum) do
                                temp[k2] = v2
                            end
                        else
                            temp = itemNum
                        end
                    else
                        temp = itemNum
                    end
                end
            elseif k == "heroDuel" or k == "HDAvatar" or k == "HDSkin" then
                for k1,itemNum in pairs(shop) do
                    self._data[k][k1] = itemNum
                end
            else
                for k1,goods in pairs(shop) do
                    for k2,itemNum in pairs(goods) do
                        local showIndex = self:getShowIndex(k2, k)
                        local temp = self._data[k]["goods"][k2]
                        if showIndex then
                            temp = self._data[k]["goods"][tostring(showIndex)]
                        end

                        if temp then
                            if type(temp) == "table" then
                                for k3,v3 in pairs(itemNum) do
                                    temp[k3] = v3
                                end
                            else
                                temp = itemNum
                            end
                        else
                            temp = itemNum
                        end
                    end
                end
            end

            self._data[k].reflashTimes = shop.reflashTimes or self._refreshTimes[k]
        end
    end
    self:reflashData()
end
function ShopModel:getShopGoods( shopTp )
	if self._data[shopTp] then
		return self._data[shopTp].goods or self._data[shopTp]
	end
end

function ShopModel:getShopRefreshTime( shopTp,detectTime  )
    -- print("shopTp",shopTp)
    shopTp = shopTp or "mystery"
    local nowTimeSec = detectTime or self._modelMgr:getModel("UserModel"):getCurServerTime()
    local nowHour = tonumber(TimeUtils.date("%H",nowTimeSec))
    local nowDate = TimeUtils.date("*t",self._modelMgr:getModel("UserModel"):getCurServerTime())
    local nextHour
    local nextDaySec = 0
    local timeValue
    if shopTp == "mystery" then
        timeValue = tab:Setting("G_MYSTERY_BONUS_REFLASH").value
    elseif shopTp == "arena" then
        timeValue = tab:Setting("G_ARENA_BONUS_REFLASH").value
    elseif shopTp == "crusade" then
        timeValue = tab:Setting("G_CRUSADE_BONUS_REFLASH").value
    elseif shopTp == "treasure" then
        timeValue = tab:Setting("G_TREASURE_BONUS_REFLASH").value
    elseif shopTp == "guild" then
        timeValue = tab:Setting("G_GUILDSHOP_REFLASH").value
    elseif shopTp == "element" then
        timeValue = tab:Setting("G_ELEMENTAL_BONUS_REFLASH").value
    elseif shopTp == "friend" then
        timeValue = tab:Setting("G_FRIEND_RETURN_REFRESH").value
    end
    if type(timeValue) == "string" then
        local timeTable = string.split(timeValue,":")
        nextHour = tonumber(timeTable[1])+tonumber(timeTable[2] or 0)/60
        if nowHour >= nextHour then
            nextDaySec = 86400
        end
    elseif type(timeValue) == "table" then
        for k,v in pairs(timeValue) do
            if nowHour < tonumber(v) then
                nextHour = v
                break
            end
        end
        if nextHour == nil then
            nextHour = tonumber(timeValue[1])+tonumber(timeValue[2] or 0)/60
            nextDaySec = 86400
        end
    end
    -- 判断是否同一天
    local detectDay = tonumber(TimeUtils.date("%d",nowTimeSec))
    local nowServerDay = tonumber(TimeUtils.date("%d",self._modelMgr:getModel("UserModel"):getCurServerTime()))
    local inSameDay = detectDay == nowServerDay
    -- 跨天 取0点判断（必定刷新）
    if not inSameDay 
    and type(timeValue) == "table" 
    and (table.nums(timeValue) > 1 or nextDaySec > 0) then 
        nextHour = 0
        nextDaySec = 0
    end
    nowDate.hour = nextHour or 0
    nowDate.min = 0
    nowDate.sec = 0
    -- print("nowHour",nowHour,nextHour,os.time(nowDate),os.date("%c",os.time(nowDate)+nextDaySec))

    local timeStr = nowDate.year .. "-" .. nowDate.month .. "-" .. nowDate.day .. " " .. nowDate.hour .. ":" .. nowDate.min .. ":" .. nowDate.sec
    local refreshTime = TimeUtils.getIntervalByTimeString(timeStr) + nextDaySec
    -- local refreshTime = os.time(nowDate)+nextDaySec -- nowTimeSec+restSec

    return refreshTime
end

-- 获得刷新对应的 刷新小时
function ShopModel:getShopRefreshHour( shopTp )
    local serverTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local tt = TimeUtils.date("*t",serverTime)
    local hour = tt.hour
    local nextRefreshHour
    local timeValue
    if shopTp == "mystery" then
        timeValue = tab:Setting("G_MYSTERY_BONUS_REFLASH").value
    elseif shopTp == "arena" then
        timeValue = tab:Setting("G_ARENA_BONUS_REFLASH").value
    elseif shopTp == "crusade" then
        timeValue = tab:Setting("G_CRUSADE_BONUS_REFLASH").value
    elseif shopTp == "treasure" then
        timeValue = tab:Setting("G_TREASURE_BONUS_REFLASH").value
    elseif shopTp == "guild" then
        timeValue = tab:Setting("G_GUILDSHOP_REFLASH").value
    elseif shopTp == "element" then
        timeValue = tab:Setting("G_ELEMENTAL_BONUS_REFLASH").value
    elseif shopTp == "friend" then
        timeValue = tab:Setting("G_FRIEND_RETURN_REFRESH").value
    end
    if type(timeValue) == "string" then
        local timeTable = string.split(timeValue,":")
        nextRefreshHour = tonumber(timeTable[1])+tonumber(timeTable[2] or 0)/60
    elseif type(timeValue) == "table" then
        for k,v in pairs(timeValue) do
            if hour < tonumber(v) then
                nextRefreshHour = v
                break
            end
        end
        if nextRefreshHour == nil then
            nextRefreshHour = tonumber(timeValue[1])
        end
    end
    return nextRefreshHour
end

-- 对应的折扣活动id
local actDiscountIds = {
    mystery = "PrivilegID_27",
    arena   = "PrivilegID_28",
    crusade = "PrivilegID_29",
    treasure= "PrivilegID_30",
    guild   = "PrivilegID_31",
}
function ShopModel:getRefreshCost( shopName )
	if table.nums(self._data) == 0 or not self._data[shopName] then
        if shopName == "mystery" then
            shopName = "Award"
        end
        shopName = string.upper(string.sub(shopName,1,1)) .. string.sub(shopName,2,string.len(shopName))
        local cost = tab:ReflashCost(1)["shop" .. shopName] or 50
        local costType = "gem"
        if type(cost) == "table" then
            costType = cost[1]
            cost = cost[3]
        end
		return cost,costType
	end
	-- dump(self._data)
    local times = self._data[shopName].reflashTimes or 0 -- tonumber(self._arenaShop.shopNum or 0)
    -- print("shopName,reflashTimes",shopName,times)
    local actDiscount = self._modelMgr:getModel("ActivityModel"):getAbilityEffect(self._modelMgr:getModel("ActivityModel").PrivilegIDs[actDiscountIds[shopName]])
    if shopName == "mystery" then
        shopName = "Award"
    elseif shopName == "citybattle" then
        shopName = "cityBattle"
    elseif shopName == "element" then
        shopName = "elemental"
    elseif shopName == "skillbook" then
        shopName = "skillBook"
    end

    shopName = string.upper(string.sub(shopName,1,1)) .. string.sub(shopName,2,string.len(shopName))
    local cost = tab:ReflashCost(math.min(times+1,#tab.reflashCost))["shop" .. shopName] or 0
    local costType = "gem"
    if type(cost) == "table" then
        costType = cost[1]
        cost = cost[3]
    end
    return cost*(1+actDiscount),costType
end

-- 竞技场商店第一次免费
function ShopModel:isArenaShopFree( )
    local userInfo = self._modelMgr:getModel("UserModel"):getData()
    local statis = userInfo.statis
    if not statis then
        statis = {}
    end
    local isFree = statis["snum19"]
    return not isFree
end

-- 对外接口
-- 宝物抽卡免费次数
function ShopModel:treasureFreeDrawCount( )
    local freenNum = self._modelMgr:getModel("PlayerTodayModel"):getData().day12 or 0
    local haveFree = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.BaoWuChouKa)
    return haveFree > 0 and freenNum < haveFree 
end

function ShopModel:getServerIndex(inPos, inType)     --by wangyan
    if not (type(inPos) == "number" or type(inPos) == "string") then
        return
    end

    local sysData = tab.shopSlot[tonumber(inPos)]
    if sysData and sysData[inType .. "Slot"] then
        return sysData[inType .. "Slot"]
    end
end

function ShopModel:getShowIndex(inPos, inType)
    if not (type(inPos) == "number" or type(inPos) == "string") then
        return
    end

    local sysShopSlot = tab.shopSlot
    for i,v in ipairs(sysShopSlot) do
        local index = v[inType .. "Slot"]
        if index == tonumber(inPos) then
            return i
        end
    end
end


return ShopModel