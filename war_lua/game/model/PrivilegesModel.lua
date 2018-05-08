--[[
    Filename:    PrivilegesModel.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-03-12 19:28:24
    Description: File description
--]]

local PrivilegesModel = class("PrivilegesModel", BaseModel)

function PrivilegesModel:ctor()
    PrivilegesModel.super.ctor(self)
    self._data = {}
    -- self._data["abilityList"] = {}
    -- 监听物品数据变化更改提示状态
    self:listenReflash("ItemModel", self.checkTips)

    self:registerTimer(5, 0, 10, function ()
        self:updateEverday()
    end)
end

function PrivilegesModel:setData(data)
    self:updatePrivilegeData(data)
end

function PrivilegesModel:getData()
    return self._data
end

function PrivilegesModel:updatePrivilegeData(data)
    if data.peerage ~= nil and data.peerage ~= 0 then 
        self._data["peerage"] = data.peerage
    elseif self._data["peerage"] == nil then
        self._data["peerage"] = 1
    end

    if data.abilityList ~= nil then 
        if self._data["abilityList"] == nil then 
           self._data["abilityList"] = data.abilityList
        else
            for k,v in pairs(data.abilityList) do
                self._data["abilityList"][k] = v
            end   
        end
    else
        if self._data["abilityList"] == nil then 
            self._data["abilityList"] = {}
        end
    end

    self:updateKingShop(data)

    self:checkTips()
    self:reflashData()
end

function PrivilegesModel:updateEverday()
    local isOpen,_,openLevel = SystemUtils["enablePrivilege"]()
    if isOpen == true then
        self._serverMgr:sendMsg("PrivilegesServer", "getShopInfo", {}, true, {}, function (result)
            self:reflashData()
        end)
    end
    -- self:reflashData()
end

-- 更新特权商店
function PrivilegesModel:updateKingShop(data)
    if data.shop ~= nil then
        if self._data["shop"] == nil then 
           self._data["shop"] = data.shop
        else
            for k,v in pairs(data.shop) do
                self._data["shop"][k] = v
            end   
        end
        self:progressShopData(self._data["shop"])
    end
end

function PrivilegesModel:getShopData()
    return self._data["shop"]
end

function PrivilegesModel:getBuffShopById(buffId)
    local flag = false
    local shopData = self._data.shop
    if shopData and shopData[buffId] and shopData[buffId] ~= 0 then
        flag = true
    end
    return flag
end

function PrivilegesModel:progressShopData(data)
    self._buffData = {}
    local peerShopTab = tab.peerShop
    for i=1,table.nums(peerShopTab) do
        local indexId = tostring(i)
        if data[indexId] then
            table.insert(self._buffData, indexId)
        end
    end
end

function PrivilegesModel:getShopTableData()
    return self._buffData
end

-- 判断索引值获取buffid是否开启
function PrivilegesModel:getKingBuff(indexId)
    if not self._buffData then
        self._buffData = {}
    end
    local buffId = self._buffData[indexId]
    local flag = self:getBuffShopById(buffId)
    return flag, buffId
end

function PrivilegesModel:getPeerage()
    if self._data.peerage == nil then
        return 0
    end
    return self._data.peerage or 0
end

function PrivilegesModel:isShowGuide()
    local flag = false

    local userModel = self._modelMgr:getModel("UserModel")
    local userData = userModel:getData()

    local openPri = SystemUtils.loadAccountLocalData("OPENLEVEL_privileges")
    if userData.lvl == 9 then
        if not openPri then
            flag = true
            SystemUtils.saveAccountLocalData("OPENLEVEL_privileges", userData.lvl)
        end
    end

    return flag
end

function PrivilegesModel:checkTips()
    self._checkTipData = {} 
    if self._data.peerage == nil or self._data.peerage == 0 then
        return 0
    end
    if not self._data.abilityList then
        return 0
    end
    -- end
    local peerageData = tab:Peerage(self._data.peerage)
    local xiaohao, level, onUpgrade
    for k,v in pairs(peerageData.effectId) do
        level = 1
        if self._data["abilityList"][tostring(v)] then
            -- print("==============", self._data["abilityList"][tostring(v)])
            if (self._data["abilityList"][tostring(v)] + 1) <= peerageData.lvLimit[k] then -- table.nums(tab:AbilityEffect(v)["cost"]) then
                level = self._data["abilityList"][tostring(v)] + 1
            else
                level = 0 -- self._data["abilityList"][tostring(v)] 
            end
        end
        if level ~= 0 then
            xiaohao = tab:AbilityEffect(v)["cost"][level]
            local tempItems, tempItemCount = self._modelMgr:getModel("ItemModel"):getItemsById(tab:Setting("G_PRIVILEGES_LVUP_ITEMID").value)
            -- print("==========", xiaohao, tempItemCount)
            if xiaohao <= tempItemCount then
                onUpgrade = true
            else
                onUpgrade = false
            end
        else
            onUpgrade = false
        end
        self._checkTipData[v] = onUpgrade
        -- print("==============",k,v)
        -- table.insert(self._checkTipData, onUpgrade)
    end
    -- dump(self._checkTipData,"self._getSysTeam")
    -- self._data.peerage == 
    return self._checkTipData
end

function PrivilegesModel:getCheckTip()
    if not self._checkTipData then
        self:checkTips()
    end
    return self._checkTipData
end


function PrivilegesModel:havePrivilegeTip()
    local flag = false
    if self._checkTipData then
        dump(self._checkTipData,"self._getSysTeam")
        for k,v in pairs(self._checkTipData) do
            if v == true then
                flag = true
                break
            end
        end
    end 
    print("PrivilegesModel1111111111=======", flag)
    if flag == false then
        local tempUpgrade = true
        if self._data.peerage and self._data.peerage < table.nums(tab.peerage) then
            for i=1,table.nums(tab:Peerage(self._data.peerage).effectId) do
                if (self._data["abilityList"][tostring(tab:Peerage(self._data.peerage)["effectId"][i])] or 0) ~= tab:Peerage(self._data.peerage)["lvLimit"][i] then -- tab:AbilityEffect(tab:Peerage(index)["effectId"][i]).level then
                    tempUpgrade = false
                end
            end 
        else
            tempUpgrade = false
        end

        if tempUpgrade == true then
            flag = tempUpgrade
        end
    end
    print("PrivilegesModel=======", flag)
    if flag == false then
        local todayTimes = self._modelMgr:getModel("PlayerTodayModel"):getData()
        if todayTimes["day25"] ~= 1 and self._modelMgr:getModel("UserModel"):getData().lvl >= 9 then
            flag = true
        end
    end
    print("PrivilegesModelflag=======", flag)
    return flag
    -- if next(self._getSysTeam) ~= nil then
    --     self._modelMgr:getModel("MainViewModel"):setNotice("PrivilegesView",true)
    -- else
    --     -- self:checkTips()
    --     -- if next(self._getSysTeam) ~= nil then 
    --     --     self._modelMgr:getModel("MainViewModel"):setNotice("PrivilegesView",true)
    --     -- else
    --         self._modelMgr:getModel("MainViewModel"):setNotice("PrivilegesView",false)
    --     -- end
    -- end
end


function PrivilegesModel:isOpenUpgrade()
    if not self._checkTipData then
        self:checkTips()
    end
    return self._checkTipData
end

--[[
--! @function getAbilityEffect
--! @desc 获取小特权效果
--! @param data 用户特权ID
--! @return 对应特权ID的效果 有一个效果的时候只取第一个
--]]
function PrivilegesModel:getAbilityEffect(id)
    -- local x = 1
    -- if conditions then
    --     return
    -- end
    if tonumber(id) == 0 or tonumber(id) > 119 then
        return 0
    end
    if not self._data["peerage"] then 
        return 0
    end
    id = tostring(id)
    if not self._data["abilityList"] or self._data["abilityList"][id] == nil then 
        return 0
    end

    local effect = tab:AbilityEffect(tonumber(id)).effect
    local level = self._data["abilityList"][id] or 0
    if level == 0 then
        return 0
    end
    -- print("effect[level]=============================", effect[level])

    return effect[level] or 0
end

--[[
--! @function getPeerageEffect
--! @desc 获取爵位效果
--! @param data 用户特权ID
--! @return 对应特权ID的效果 有一个效果的时候只取第一个
--]]
function PrivilegesModel:getPeerageEffect(id)
    if not id then
        return 0
    end
    if tonumber(id) == 0 or tonumber(id) > 10 then
        return 0
    end
    if not self._data["peerage"] then 
        return 0
    end
    if tonumber(self._data["peerage"]) < tonumber(id) then
        return 0
    end
    local peerage = 1
    if tab:Peerage(id).effect[1] ~= 1 then
        peerage = tab:Peerage(id).effect[1]
    end
    -- print("peerage ===============", peerage)
    -- local level = 1
    -- backEffect[1] = peerage.effect[level] or 1
    -- -- for i,j in pairs(effect) do
    -- --     backEffect[i] = j[3] * level
    -- -- end
    -- dump(backEffect, "backEffect=============")
    return peerage or 0
end

-- 判断每日首次是否显示公告
function PrivilegesModel:getPrivilegesFristShow()
    local userModel = self._modelMgr:getModel("UserModel")
    local curServerTime = userModel:getCurServerTime()
    local timeDate
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime > tempCurDayTime then
        timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    else
        timeDate = TimeUtils.getDateString(curServerTime - 86400,"%Y%m%d")
    end
    local tempdate = SystemUtils.loadAccountLocalData("PRIVILEGES_FRIST_time")
    if tempdate ~= timeDate then
        SystemUtils.saveAccountLocalData("PRIVILEGES_FRIST_time", timeDate)
        return true
    end
    return false
end

-- 判断商店是否开启
function PrivilegesModel:isUpPeerage(inType)
    local privilegeData = self:getData()
    local templevelNum, tempMaxLevel = 0, 0
    local flag = false
    local nowPeerage = self:getPeerage()
    for i=1,5 do
        local peerageTab = tab:Peerage(nowPeerage)
        if i <= table.nums(peerageTab.effectId) then
            local maxLevel = peerageTab["lvLimit"][i] - peerageTab["lvCondition"][i]
            local tempLvl = privilegeData["abilityList"][tostring(peerageTab["effectId"][i])] or 0
            if peerageTab["lvCondition"][i] ~= 0 then
                tempLvl = tempLvl - peerageTab["lvCondition"][i]
            end
            if tempLvl >= maxLevel then
                tempLvl = maxLevel
            elseif tempLvl < 0 then
                tempLvl = 0
            end

            templevelNum = templevelNum + tempLvl 
            tempMaxLevel = tempMaxLevel + maxLevel
        end
    end
    
    if templevelNum == tempMaxLevel and nowPeerage == 10 then
        flag = true
    end

    if inType == 1 then
        return templevelNum, tempMaxLevel
    else
        return flag
    end
end


return PrivilegesModel