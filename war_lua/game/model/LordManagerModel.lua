--
-- Author: <haotaian@playcrab.com>
-- Date: 2018-03-02 14:00:00
--

--[[
101-银钥匙招募
102-金钥匙招募
103-特权奖励
104-宝物占星
105-法术祈愿
201-每日礼包
202-联盟红包
203-联盟捐献
204-联盟佣兵
301-阴森墓穴
302-矮人宝屋
303-攻城战
304-守城战
305-龙之国-毒龙
306-龙之国-仙女龙
307-龙之国-水晶龙
308-云中城
309-元素位面-火元素
310-元素位面-水元素
311-元素位面-气
312-元素位面-土
313-元素位面-混乱
314-船坞派驻
315-船坞领取
]]--


local tab = tab

local LordManagerModel = class("LordManagerModel", BaseModel)

local costTypeImg = LordManagerUtils.costTypeImg
local rewardNum = LordManagerUtils.expArray
local donateCostNum = LordManagerUtils.costArray
local totalRespNum = 0
local curRespNum   = 0

function LordManagerModel:ctor()
    LordManagerModel.super.ctor(self) 

    self._data = nil
    self._userModel = self._modelMgr:getModel("UserModel")
    self._bossModel = self._modelMgr:getModel("BossModel")
    self._weaponModel = self._modelMgr:getModel("WeaponsModel")
    self._dailySiegeModel = self._modelMgr:getModel("DailySiegeModel")
    self._elementModel = self._modelMgr:getModel("ElementModel")
    self._mfModel = self._modelMgr:getModel("MFModel")
    self._cModel = self._modelMgr:getModel("CloudCityModel")
    self._guildModel = self._modelMgr:getModel("GuildModel")
    self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
    self._rewards = {}
    self:collectModelData()
    self._uuid = self._userModel:getUUID()
    --收集数据

    --监听对应模块 检测红点显示
    self:listenReflash("PlayerTodayModel", self.updateRedPoint)  
    self:listenReflash("BossModel", self.updateRedPoint)
    self:listenReflash("GuildModel", self.updateRedPoint)
    self:listenReflash("MFModel", self.updateRedPoint)
    self:listenReflash("CloudCityModel", self.updateRedPoint)
    self:listenReflash("ElementModel", self.updateRedPoint)
    self:listenReflash("DailySiegeModel", self.updateRedPoint)
    self:listenReflash("WeaponsModel", self.updateRedPoint)

    self:registerTimer(5, 0, 5, function ()
        self:updateRedPoint()
        self._serverMgr:sendMsg("BossServer", "getBossInfo", {}, true, {}, function(success)
            self:reflashData("reflashView")
        end)
    end)
end

--[[
    收集各模块数据
]]--

function LordManagerModel:collectModelData( ... )
    self._data = {{},{},{}}
    for k,v in pairs(tab.lordManager) do
        -- local data = clone(v)
        if v.subType ~= 203 then
            table.insert(self._data[v.type],v)
        end
    end 
end

function LordManagerModel:getDataByType(type)
    local array = {}
    for i,v in ipairs(self._data[type]) do
        local data = self:getDataByIdx(v.subType)
        if data.isOpen then
            table.insert(array,data)
        end
    end
    table.sort(array,function (a,b)
        return a.idx < b.idx
    end)
    --[[
        未完成>完成
        解锁>未解锁
        未解锁>完成
    ]]
    table.sort(array,function (a,b)
        if a.hTimes ~= b.hTimes and a.hTimes == 0 then
            return false
        elseif a.hTimes ~= b.hTimes and b.hTimes == 0 then
            return true
        elseif a.hTimes ~= 0 and b.hTimes ~= 0 then
            if a.isPass ~= b.isPass and a.isPass == true then
                return true
            end
            if a.isPass ~= b.isPass and b.isPass == true then
                return false
            end
            return a.idx < b.idx
        elseif a.hTimes == 0 and b.hTimes == 0 then
            return a.idx < b.idx
        end
        return false
    end)

    return array
end

function LordManagerModel:getData( ... )
    -- body
end

function LordManagerModel:setData(data)
    self._data = {{},{},{}}

end

--[[
    hTimes:剩余挑战次数
    maxTimes:最大次数
]]--
function LordManagerModel:getDataByIdx(idx)
    local data = {}
    data.idx = idx 
    data.isOpen = true
    data.isPass = false
    local level = self._modelMgr:getModel("UserModel"):getPlayerLevel()
    if idx == 101 then
        --银钥匙最大免费次数
        data.maxTimes = tab:Setting("G_FREENUM_DRAW_TOOL_SINGLE").value+self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_8)
        --银钥匙已使用次数
        data.hTimes = data.maxTimes  - (self._modelMgr:getModel("PlayerTodayModel"):getData().day7 or 0)
    elseif idx == 102 then
        data.maxTimes = 1
        local day1 = self._modelMgr:getModel("PlayerTodayModel"):getData().day1 or 0
        data.hTimes = day1 == 0 and 1 or 0
    elseif idx == 103 then
        if level >= tab.systemOpen["Privilege"][1] and self._modelMgr:getModel("PrivilegesModel"):getPeerage() > 0 then
            --可以领取
            data.maxTimes = 1
            data.hTimes = self._modelMgr:getModel("PlayerTodayModel"):getData().day25 == 0 and 1 or 0
        else
            data.isOpen = false
        end
    elseif idx == 104 then
        local freenNum = self._modelMgr:getModel("PlayerTodayModel"):getData().day12 or 0
        local haveFree = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.BaoWuChouKa)
        if level >= tab.systemOpen["TreasureShop"][1] and haveFree > 0 then
            data.maxTimes = haveFree
            data.hTimes = freenNum == 0 and 1 or 0
        else
            data.isOpen = false
        end
    elseif idx == 105 then
        if level >= tab.systemOpen["SkillBook"][1] then 
            local getTimes = self._modelMgr:getModel("PlayerTodayModel"):getData().day68 or 0
            data.maxTimes = 1
            data.hTimes = getTimes == 0 and 1 or 0
        else
            data.isOpen = false
        end  
    elseif idx == 201 then
        local guildId = self._userModel:getData().guildId or 0
        if level >= tab.systemOpen["Guild"][1] and guildId ~=0 then 
            local dayinfo = self._modelMgr:getModel("PlayerTodayModel"):getData().day47
            data.maxTimes = 1
            data.hTimes = dayinfo == 0 and 1 or 0
        else
            data.isOpen = false
        end   
    elseif idx == 202 then
        local guildId = self._userModel:getData().guildId or 0
        if level >= tab.systemOpen["Guild"][1] and guildId ~=0 then 
            data.maxTimes = 3
            local sysRedData = self._modelMgr:getModel("GuildRedModel"):getSysData()
            data.hTimes = 0
            for i=1,table.nums(sysRedData) do
                if sysRedData[i] and sysRedData[i].robRed == 0 then
                    data.hTimes = data.hTimes + 1
                end
            end
        else
            data.isOpen = false
        end 
    elseif idx == 203 then
        local guildId = self._userModel:getData().guildId or 0
        if level >= tab.systemOpen["Guild"][1] and guildId ~=0 then  
            local times = self._modelMgr:getModel("GuildModel"):getDonateTimes()
            local dTimes = self._modelMgr:getModel("UserModel"):getRoleAlliance().dTimes
            data.maxTimes = times
            data.hTimes = times - dTimes
        else
            data.isOpen = false
        end 
    elseif idx == 204 then
        local guildId = self._userModel:getData().guildId or 0
        if level >= tab.systemOpen["Guild"][1] and guildId ~=0 then 
            data.maxTimes = 1
            data.hTimes = self._modelMgr:getModel("GuildModel"):canGetAward() == true and 1 or 0
        else
            data.isOpen = false
        end 
    elseif idx == 301 then
        local bossData = self._bossModel:getDataByPveId(PVETYPE) or {}
        if level >= tab.systemOpen["Crypt"][1] then
            data.maxTimes = tab:Setting("G_PVE_" .. 5).value
            data.hTimes = 0
            if self._bossModel:isPassByPveType(5) then
                data.isPass = true
            end
            local bossData = self._bossModel:getDataByPveId(5)
            if bossData then
                data.hTimes = 2 - bossData.times
            end
        else
            data.isOpen = false
        end 
    elseif idx == 302 then
        if level >= tab.systemOpen["DwarvenTreasury"][1] and self._bossModel:isPassByPveType(4)  then
            data.maxTimes = tab:Setting("G_PVE_" .. 4).value
            data.hTimes = 3
            if self._bossModel:isPassByPveType(4) then
                data.isPass = true
            end
            local bossData = self._bossModel:getDataByPveId(4)
            if bossData then
                data.hTimes = 2 - bossData.times
            end
        else
            data.isOpen = false
        end

    elseif idx == 303 then
        local maxLevel = self._dailySiegeModel:getChallengeLevelMax() or 0
        if self._weaponModel:getWeaponState() == 4 then
            local total, num = self._dailySiegeModel:getRemainNum(1)
            data.maxTimes = total
            data.hTimes = num
            if maxLevel > 0 then
                data.isPass = true
            end
        else
            data.isOpen = false
        end
    elseif idx == 304 then
        local isShowSweep = self._dailySiegeModel:isDefendCity()
        if self._weaponModel:getWeaponState() == 4 then
            local total, num = self._dailySiegeModel:getRemainNum(2)
            data.maxTimes = total
            data.hTimes = num
            if isShowSweep then
                data.isPass = true
            end
        else
            data.isOpen = false
        end
    elseif idx == 305 then
        local pveData = self._bossModel:getDataByPveId(1)
        if level >= tab.systemOpen["Boss"][1] and pveData then
            data.maxTimes = tab:Setting("G_PVE_1").value
            data.hTimes = 2 - (pveData.times or 0)
            if self._bossModel:isPassByPveType(1) then
                data.isPass = true
            end
        else
            data.isOpen = false
        end
    elseif idx == 306 then
        local pveData = self._bossModel:getDataByPveId(2)
        if level >= tab.systemOpen["Boss"][1] and pveData then
            data.maxTimes = tab:Setting("G_PVE_2").value
            data.hTimes = 2 - (pveData.times or 0)
            if self._bossModel:isPassByPveType(2) then
                data.isPass = true
            end
        else
            data.isOpen = false
        end
    elseif idx == 307 then
        local pveData = self._bossModel:getDataByPveId(3)
        if level >= tab.systemOpen["Boss"][1] and pveData then
            data.maxTimes = tab:Setting("G_PVE_3").value
            data.hTimes = 2 - (pveData.times or 2)
            if self._bossModel:isPassByPveType(3) then
                data.isPass = true
            end
        else
            data.isOpen = false
        end
    elseif idx == 308 then
        if level >= tab.systemOpen["CloudCity"][1] then
            data.maxTimes = self._cModel:getMaxChallengeTimes()
            data.hTimes = self._cModel:getChallengeTimes()
            if self._cModel:getPassMaxStageId() > 0 then
                data.isPass = true
            end
        else
            data.isOpen = false
        end
    elseif idx == 309 then
        local index = idx - 308
        local openStage = self._elementModel:getElementData()["stageId"..index] or 0
        if level >= tab.systemOpen["Element"][1] and self._elementModel:planOrOpen(index) then
            data.maxTimes = 1
            data.hTimes = self._elementModel:getAllElementTimes()[index]
            if openStage > 0 then
                data.isPass = true
            end
        else
            data.isOpen = false
        end
    elseif idx == 310 then
        local index = idx - 308
        local openStage = self._elementModel:getElementData()["stageId"..index] or 0
        if level >= tab.systemOpen["Element"][1] and self._elementModel:planOrOpen(index) then
            data.maxTimes = 1
            data.hTimes = self._elementModel:getAllElementTimes()[index]
            if openStage > 0 then
                data.isPass = true
            end
        else
            data.isOpen = false
        end
    elseif idx == 311 then
        local index = idx - 308
        local openStage = self._elementModel:getElementData()["stageId"..index] or 0
        if level >= tab.systemOpen["Element"][1] and self._elementModel:planOrOpen(index) then
            data.maxTimes = 1
            data.hTimes = self._elementModel:getAllElementTimes()[index]
            if openStage > 0 then
                data.isPass = true
            end
        else
            data.isOpen = false
        end
    elseif idx == 312 then
        local index = idx - 308
        local openStage = self._elementModel:getElementData()["stageId"..index] or 0
        if level >= tab.systemOpen["Element"][1] and self._elementModel:planOrOpen(index) then
            data.maxTimes = 1
            data.hTimes = self._elementModel:getAllElementTimes()[index]
            if openStage > 0 then
                data.isPass = true
            end
        else
            data.isOpen = false
        end
    elseif idx == 313 then
        local index = idx - 308
        local openStage = self._elementModel:getElementData()["stageId"..index] or 0
        if level >= tab.systemOpen["Element"][1] and self._elementModel:planOrOpen(index) then
            data.maxTimes = 1
            data.hTimes = self._elementModel:getAllElementTimes()[index]
            if openStage > 0 then
                data.isPass = true
            end
        else
            data.isOpen = false
        end
    elseif idx == 314 then
        if level >= tab:MfOpen(1)["lv"] then
            data.isPass = true
            for i=1,6 do
                if level < tab:MfOpen(1)["lv"] then
                    data.maxTimes = i - 1
                else
                    data.maxTimes = i
                end
            end
            data.hTimes = 0
            local taskData = self._mfModel:getTasks()
            for i=1,table.nums(taskData) do
                if not taskData[tostring(i)].finishTime then
                    data.hTimes = data.hTimes + 1 
                end
            end
        else
            data.isOpen = false
        end  
    elseif idx == 315 then
        if level >= tab:MfOpen(1)["lv"] then
            data.isPass = true
            for i=1,6 do
                if level < tab:MfOpen(1)["lv"] then
                    data.maxTimes = i - 1
                else
                    data.maxTimes = i
                end
            end
            data.hTimes = 0
            local taskData = self._mfModel:getTasks()
            for i=1,table.nums(taskData) do
                local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
                if taskData[tostring(i)].finishTime and taskData[tostring(i)].finishTime <= curServerTime then
                    data.hTimes = data.hTimes + 1
                end
            end
        else
            data.isOpen = false
        end  
    end
    return data
end

--功能是否默认选中
function LordManagerModel:isSave(idx)
    return tonumber(UserDefault:getStringForKey("LordManager_"..self._uuid..idx,"1")) == 1
end

--save 捐献类型
function LordManagerModel:saveDonateType(idx)
    UserDefault:setStringForKey("LordManager_DoneteType"..self._uuid,idx)
end

function LordManagerModel:getDonateType()
    return UserDefault:getStringForKey("LordManager_DoneteType"..self._uuid,"1")
end

--保存捐献科技id
function LordManagerModel:saveScienceType(idx)
    UserDefault:setStringForKey("LordManager_ScienceType"..self._uuid,idx)
end

function LordManagerModel:getScienceType()
    return UserDefault:getStringForKey("LordManager_ScienceType"..self._uuid,"2")
end

--本地保存选中状态 1 选中  0 未勾选
function LordManagerModel:saveSelectedState(idx,state)
    UserDefault:setStringForKey("LordManager_".. self._uuid ..idx,state)
end

--保存云中城扫荡设置
function LordManagerModel:saveTowerType(idx)
    UserDefault:setStringForKey("LordManager_TowerType"..self._uuid,idx)
end

function LordManagerModel:getTowerType()
    return UserDefault:getStringForKey("LordManager_TowerType"..self._uuid,"1")
end

function LordManagerModel:updateData(data)
    
end

function LordManagerModel:updatePushData(data)
    self:updateData(data)
    self:reflashData("statePushUpdate")
end

--检测科技捐献花费
function LordManagerModel:checkIsNeedCostMoney(idx)
    -- local donateData = self:getDataByIdx(203)
    -- if idx == 2 and self:isSave(203) and donateData.isOpen and donateData.hTimes > 0 then 

    --     --需要先检查被选联盟科技的状态
    --     local tid = tonumber(self:getScienceType())
    --     local did = tonumber(self:getDonateType())
    --     if tid == 0 or did == 0 then 
    --         self._viewMgr:showTip("请先选择要捐献的目标或类型")
    --         return
    --     end
    --     local isMax,needExp = self._guildModel:isMaxLevel(tid)
    --     if isMax then 
    --         self:getAllReward(idx)
    --         return
    --     end
    --     local times  = donateData.hTimes < (math.floor(needExp/rewardNum[did])) and donateData.hTimes or (math.floor(needExp/rewardNum[did]))
    --     local cost = donateCostNum[did]
    --     local maxCost = cost * times
    --     local img  =  costTypeImg[did]
    --     local lan = lang("LordManager_Text2")
    --     local desc = "[color=3d1f00,fontsize=24]".. lan .."[-][][-][pic=".. img .. "][-][color=3d1f00,fontsize=24]".. maxCost .. "[-]"
    --     self._viewMgr:showDialog("global.GlobalSelectDialog", {desc = desc,callback1 = function()
    --         local has = 0
    --         if tonumber(self:getDonateType()) == 1 then
    --             has = self._userModel:getData().gold or 0 
    --         else
    --             has = self._userModel:getData().gem or 0
    --         end
    --         if has < cost then
    --             if did == 1 then
    --                 DialogUtils.showLackRes( {goalType = "gold"})
    --             else
    --                 local title = "钻石不足"
    --                 DialogUtils.showNeedCharge({button1 = "前往",title = title,callback1 = function ( ... )
    --                     self._viewMgr:showView("vip.VipView", {viewType = 0})
    --                 end})
    --             end  
    --         else
    --             --todo
    --             self:getAllReward(idx)
    --         end

    --     end,},true) 
    -- else
    self:calcTotalRespNum(idx)
    self:getAllReward(idx)
    -- end
end

--计算服务器请求总数
function LordManagerModel:calcTotalRespNum(idx)
    local array = self:getDataByType(idx)
    for k,v in pairs(array) do
        
        if not self:isSave(v.idx) then
        else
            local times = v
            if idx == 3 then
                if v.isPass then
                    local t = times.hTimes or 0
                    if (v.idx == 101 or v.idx == 202 or v.idx == 301 or v.idx == 302 or v.idx == 315 or v.idx == 314 ) and t > 0 then
                        self:calcSendTimes(v.idx,t)
                    else
                        if t > 0 then
                            for i=1,t do
                               self:calcSendTimes(v.idx,i)
                            end
                        end
                    end
                end
            else
                local t = times.hTimes or 0
                if (v.idx == 101 or v.idx == 202 or v.idx == 301 or v.idx == 302 or v.idx == 315 or v.idx == 314 ) and t > 0 then
                    self:calcSendTimes(v.idx,t)
                else
                    if t > 0 then
                        for i=1,t do
                           self:calcSendTimes(v.idx,i)
                        end
                    end
                end
            end
        end
    end
end

function LordManagerModel:getAllReward(idx)
    local array = self:getDataByType(idx)
    local state = self:checkMFState()
    for k,v in pairs(array) do
        if not self:isSave(v.idx) then
        else
            local times = v
            if idx == 3 then
                if v.isPass then
                    local t = times.hTimes or 0
                    if (v.idx == 301 or v.idx == 302 or v.idx == 315 or v.idx == 314 ) and t > 0 then
                        if v.idx == 315 and state == 2 then
                        else
                            self:sendMsg(v.idx,t,state)
                        end
                    else
                        if t > 0 then
                            for i=1,t do
                               self:sendMsg(v.idx,i)
                            end
                        end
                    end
                end
            else
                local t = times.hTimes or 0
                if (v.idx == 101 or v.idx == 202 ) and t > 0 then
                    self:sendMsg(v.idx,t)
                else
                    if t > 0 then
                        for i=1,t do
                           self:sendMsg(v.idx,i)
                        end
                    end
                end
            end  
        end
    end
end
function LordManagerModel:checkGetReward()
    if curRespNum >= totalRespNum and totalRespNum ~= 0 then
        self:showReward()
    end
end

function LordManagerModel:showReward( ... )
    local function getAwardArray( ... )
        local array = {}
        for k,v in pairs(self._rewards) do
            local data = {}
            data.idx = k
            data.awards = v
            table.insert(array,data)
        end

        if #array > 1 then
            table.sort(array,function (a,b)
                return a.idx < b.idx
            end)
        end
        return array
    end   
    local param = {
        awards = getAwardArray(),
        callback = self.callback
    }
    self:reflashData("reflashView")
    if table.nums(self._rewards) ~= 0 then
        self._viewMgr:showDialog("lordmanager.LordSweepResultDialog",param)
        self._rewards = {}
        self._viewMgr:showTip("一键领取完成")
        totalRespNum = 0
        curRespNum = 0
    else
        totalRespNum = 0
        curRespNum = 0
        self._rewards = {}
    end
end

function LordManagerModel:timeoutCallback( )
    self:showReward()
end

function LordManagerModel:sendMsg(subType,idx,mfState)
    if subType == 101 then
        self._serverMgr:sendMsg("TeamServer", "drawAward", {typeId = 1, num = 1}, true, {}, function(result)
            curRespNum = curRespNum + 1
            self:dealWithRewardResult(result.awards,subType)
        end,function (errorid)
            curRespNum = curRespNum + 1
            self:checkGetReward()
        end,nil,function ( ... )
            self:timeoutCallback()
        end)
    elseif subType == 102 then
        self._serverMgr:sendMsg("TeamServer", "drawAward", {typeId = 2, num = 1}, true, {}, function(result)
            curRespNum = curRespNum + 1
            self:dealWithRewardResult(result.awards,subType)
        end,function (errorid)
            curRespNum = curRespNum + 1
            self:checkGetReward()
        end,nil,function ( ... )
            self:timeoutCallback()
        end)
    elseif subType == 103 then
        self._serverMgr:sendMsg("PrivilegesServer", "getWages", {}, true, {}, function(result)
            curRespNum = curRespNum + 1
            self:dealWithRewardResult(result.reward,subType)
        end,function (errorid)
            curRespNum = curRespNum + 1
            self:checkGetReward()
        end,nil,function ( ... )
            self:timeoutCallback()
        end)
    elseif subType == 104 then
        self._serverMgr:sendMsg("TreasureServer", "drewFreeDisTreasure", {num=1}, true, {}, function(result)
            curRespNum = curRespNum + 1    
            self:dealWithRewardResult(result.rewards,subType) 
        end,function (errorid)
            curRespNum = curRespNum + 1
            self:checkGetReward()
        end,nil,function ( ... )
            self:timeoutCallback()
        end)
    elseif subType == 105 then
        local param = {num =1, type = 0}
        self._serverMgr:sendMsg("HeroServer", "drawSpeelBook", param, true, {}, function(result)
            curRespNum = curRespNum + 1
            if result then
                self:dealWithRewardResult(result.rewards,subType)
            else
                self:checkGetReward()
            end
        end,nil,nil,function ( ... )
            self:timeoutCallback()
        end)
    elseif subType == 201 then
        --每日礼包
        self._serverMgr:sendMsg("GuildServer", "getGuildDailyGift", {}, true, {}, function (result)
            curRespNum = curRespNum + 1
            self:dealWithRewardResult(result.award,subType)
        end,function (errorid)
            curRespNum = curRespNum + 1
            self:checkGetReward()
        end,nil,function ( ... )
            self:timeoutCallback()
        end)
    elseif subType == 202 then
        local robData = self._modelMgr:getModel("GuildRedModel"):getSysData()
        for k,v in pairs(robData) do
            if v.robRed == 0 then
                self._serverMgr:sendMsg("GuildRedServer", "robGuildRed", {redId = v.redId}, true, {}, function (result)
                    local rewards = {}
                    table.insert(rewards,result.reward)
                    curRespNum = curRespNum + 1
                    self:dealWithRewardResult(rewards,subType)
                end,function (errorId)
                    curRespNum = curRespNum + 1
                    self:checkGetReward()
                end,nil,function ( ... )
                    self:timeoutCallback()
                end)
            end
        end
    elseif subType == 203 then
        self._isDonate = false
        local tid = tonumber(self:getScienceType())
        local did = tonumber(self:getDonateType())
        if tid == 0 or did == 0 then return end
        local param = {tid = tid, did = did}
        local dStatus = self._modelMgr:getModel("UserModel"):getData().roleGuild.dStatus
        local factor = 1 
        if dStatus and dStatus == 1 then
            factor = 2
        end
        local isMax,needExp = self._guildModel:isMaxLevel(tid)
        if isMax then return end
        local hTimes = self:getDataByIdx(203).hTimes
        local times = hTimes < (math.floor(needExp/LordManagerUtils.expArray[did])) and hTimes or (math.floor(needExp/LordManagerUtils.expArray[did]))
        local function sendMsgAgain(idx)
            local has = 0
            if did == 1 then
                has = self._modelMgr:getModel("UserModel"):getData().gold or 0 
            else
                has = self._modelMgr:getModel("UserModel"):getData().gem or 0
            end
            if LordManagerUtils.costArray[did] > has then return end
            self._serverMgr:sendMsg("GuildServer", "techDonate", param, true, {}, function (result)
                if not result["gameGuild"]["todayExp"] then
                    factor = 0
                else
                    self._modelMgr:getModel("GuildModel"):updateAllianceTodayExp(result["gameGuild"]["todayExp"])
                end
                local roleGuild = self._modelMgr:getModel("UserModel"):getData().roleGuild
                if not roleGuild["d" .. param.did] then
                    roleGuild["d" .. param.did] = 0
                end
                roleGuild["d" .. param.did] = roleGuild["d" .. param.did] + 1

                local reward = {}
                
                local data = {num = factor*rewardNum[param.did],type = "guildCoin",typeId = 0 }
                table.insert(reward,data)
                
                self:dealWithRewardResult(reward,subType)
                
                self._isDonate = true
                -- if result["gameGuild"]["todayExp"] then

                local isMax = self._guildModel:isMaxLevel(tid)
                --捐献上限了
                if isMax then
                    self:getGuildDonateReward()
                    return
                end
                idx = idx - 1
                if idx > 0 then
                    sendMsgAgain(idx)
                else
                    self:getGuildDonateReward()
                end
            end)
        end
        sendMsgAgain(times)
    elseif subType == 204 then
        local result = self._modelMgr:getModel("GuildModel"):getGuildMercenary()
        for k , v in pairs(result["mercenaryDetails"]) do 
            if v.teamId ~= 0 then   
                self._serverMgr:sendMsg("GuildServer", "getMercenaryReward", {pos = k}, true, {}, function(result, errorCode)
                    curRespNum = curRespNum + 1
                    self:dealWithRewardResult(result.reward,subType)
                end,function (errorid)
                    curRespNum = curRespNum + 1
                    self:checkGetReward()
                end,nil,function ( ... )
                    self:timeoutCallback()
                end)
            end
        end
    elseif subType == 301 then
        local function sendMsgAgain(idx)
            self._serverMgr:sendMsg("BossServer", "sweepBoss", {id = 902}, true, {}, function(success, result)
                if not success then
                    self._viewMgr:showTip("扫荡失败。请策划配表")
                    curRespNum = curRespNum + 1
                    self:checkGetReward()
                    return
                end
                curRespNum = curRespNum + 1
                self._bossModel:setTimes(5, result["d"]["boss"][tostring(5)].times)
                self._bossModel:setHighScore(5,result["d"]["boss"][tostring(5)])
                local dataList = self._bossModel:getRewardIdList(5)
                idx = idx - 1 
                if idx == 0 and #dataList > 0 then
                    self:dealWithRewardResult(result.reward,subType,1)
                    totalRespNum = totalRespNum + 1
                    self:sendPveMsg(5,dataList)
                    return
                else
                    self:dealWithRewardResult(result.reward,subType)
                end
                if idx > 0 then
                    sendMsgAgain(idx)
                end
            end,nil,nil,function ( ... )
                self:timeoutCallback()
            end)
        end
        sendMsgAgain(idx)
    elseif subType == 302 then  
        local function sendMsgAgain(idx)
            self._serverMgr:sendMsg("BossServer", "sweepBoss", {id = 901}, true, {}, function(success, result)
                if not success then
                    self._viewMgr:showTip("扫荡失败。请策划配表")
                    curRespNum = curRespNum + 1
                    self:checkGetReward()
                    return
                end
                curRespNum = curRespNum + 1
                self._bossModel:setTimes(4, result["d"]["boss"][tostring(4)].times)
                self._bossModel:setHighScore(4,result["d"]["boss"][tostring(4)])
                local dataList = self._bossModel:getRewardIdList(4)
                idx = idx - 1 
                if idx == 0 and #dataList > 0 then
                    self:dealWithRewardResult(result.reward,subType,1)
                    totalRespNum = totalRespNum + 1
                    self:sendPveMsg(4,dataList)
                    return
                else
                    self:dealWithRewardResult(result.reward,subType)
                end
                if idx > 0 then
                    sendMsgAgain(idx)
                end
            end,nil,nil,function ( ... )
                self:timeoutCallback()
            end)
        end      
        sendMsgAgain(idx)
    elseif subType == 303 then
        local theme,diff = self._dailySiegeModel:getMaxSweepLevelAndThemeByType(1)
        if diff > 0 then
            self._serverMgr:sendMsg("DailySiegeServer", "sweepSiege", 
                {type = theme, diff = diff}, true, {},function (success, result)
                    curRespNum = curRespNum + 1
                    if success then
                        self:dealWithRewardResult(result.reward,subType)
                    end
            end,function (errorid)
                curRespNum = curRespNum + 1
                self:checkGetReward()
            end,nil,function ( ... )
                self:timeoutCallback()
            end)
        end
    elseif subType == 304 then
        local theme = self._dailySiegeModel:getMaxSweepLevelAndThemeByType(2)
        self._serverMgr:sendMsg("DailySiegeServer", "sweepDefend", 
        {type = theme}, true, {},function (success, result)
            curRespNum = curRespNum + 1
            if success then
                self:dealWithRewardResult(result.reward,subType)
            end 
        end,function (errorid)
            curRespNum = curRespNum + 1
            self:checkGetReward()
        end,nil,function ( ... )
            self:timeoutCallback()
        end)
    elseif subType == 305 then
        --毒龙
        local dragonSelectedId = subType - 304
        local pveData = self._bossModel:getDataByPveId(dragonSelectedId)
        local hardLevel = 0
        if pveData and pveData.hValue then
            hardLevel = pveData.hValue.diffId or 0
        end
        if hardLevel == 0 then return end
        local pveId = dragonSelectedId * 100 + hardLevel
        local dragonInfo = tab:Npc(tab:PveSetting(pveId).NPC[1])
        self._serverMgr:sendMsg("BossServer", "sweepBoss", {id = pveId, damage = dragonInfo.a4[1] and dragonInfo.a4[1] or 0}, true, {}, function(success, result)
            if not success then
                self._viewMgr:showTip("扫荡失败。请策划配表")
                curRespNum = curRespNum + 1
                self:checkGetReward()
                return
            end
            local challengeTimes = result["d"]["boss"][tostring(dragonSelectedId)].times
            self._bossModel:setTimes(dragonSelectedId, challengeTimes)
            curRespNum = curRespNum + 1
            if success then
                self:dealWithRewardResult(result.reward,subType)
            end
        end,nil,nil,function ( ... )
            self:timeoutCallback()
        end)
    elseif subType == 306 then
        --仙女龙
        local dragonSelectedId = subType - 304
        local pveData = self._bossModel:getDataByPveId(dragonSelectedId)
        local hardLevel = 0
        if pveData and pveData.hValue then
            hardLevel = pveData.hValue.diffId or 0
        end
        if hardLevel == 0 then return end
        local pveId = dragonSelectedId * 100 + hardLevel
        local dragonInfo = tab:Npc(tab:PveSetting(pveId).NPC[1])
        self._serverMgr:sendMsg("BossServer", "sweepBoss", {id = pveId, damage = dragonInfo.a4[1] and dragonInfo.a4[1] or 0}, true, {}, function(success, result)
            if not success then
                self._viewMgr:showTip("扫荡失败。请策划配表")
                curRespNum = curRespNum + 1
                self:checkGetReward()
                return
            end
            local challengeTimes = result["d"]["boss"][tostring(dragonSelectedId)].times
            self._bossModel:setTimes(dragonSelectedId, challengeTimes)
            curRespNum = curRespNum + 1
            if success then
                self:dealWithRewardResult(result.reward,subType)
            end
        end,nil,nil,function ( ... )
            self:timeoutCallback()
        end)
    elseif subType == 307 then
        --水晶龙
        local dragonSelectedId = subType - 304
        local pveData = self._bossModel:getDataByPveId(dragonSelectedId)
        local hardLevel = 0
        if pveData and pveData.hValue then
            hardLevel = pveData.hValue.diffId or 0
        end
        if hardLevel == 0 then return end
        local pveId = dragonSelectedId * 100 + hardLevel
        local dragonInfo = tab:Npc(tab:PveSetting(pveId).NPC[1])
        self._serverMgr:sendMsg("BossServer", "sweepBoss", {id = pveId, damage = dragonInfo.a4[1] and dragonInfo.a4[1] or 0}, true, {}, function(success, result)
            if not success then
                self._viewMgr:showTip("扫荡失败。请策划配表")
                curRespNum = curRespNum + 1
                self:checkGetReward()
                return
            end

            local challengeTimes = result["d"]["boss"][tostring(dragonSelectedId)].times
            self._bossModel:setTimes(dragonSelectedId, challengeTimes)
            curRespNum = curRespNum + 1
            if success then
                self:dealWithRewardResult(result.reward,subType)
            end
        end,nil,nil,function ( ... )
            self:timeoutCallback()
        end)
    elseif subType == 308 then
        local type  = tonumber(self:getTowerType())
        if type == 0 then return end
        local stage = self:getStageByTowerState(idx)
        self._serverMgr:sendMsg("CloudyCityServer", "sweepCloudyCity", {stageId = stage}, true, {}, function(result)
            curRespNum = curRespNum + 1
            self:dealWithRewardResult(result.reward,subType)
        end,function (errorid)
            curRespNum = curRespNum + 1
            self:checkGetReward()
        end,nil,function ( ... )
            self:timeoutCallback()
        end)
    elseif subType == 309 then
        local index = subType - 308
        local hasTimes = self._elementModel:getAllElementTimes()[self._itemId]
        local stageId = self._elementModel:getElementData()["stageId"..index] or 0
        if stageId > 0 then
            self._serverMgr:sendMsg("ElementServer", "sweepElement", {elementId = index,stageId = stageId}, true, {}, function(result)
                curRespNum = curRespNum + 1
                self:dealWithRewardResult(result.reward,subType)
            end,function (errorid)
                curRespNum = curRespNum + 1
                self:checkGetReward()
            end,nil,function ( ... )
                self:timeoutCallback()
            end)
        end
    elseif subType == 310 then
        local index = subType - 308
        local hasTimes = self._elementModel:getAllElementTimes()[self._itemId]
        local stageId = self._elementModel:getElementData()["stageId"..index] or 0
        if stageId > 0 then
            self._serverMgr:sendMsg("ElementServer", "sweepElement", {elementId = index,stageId = stageId}, true, {}, function(result)
                curRespNum = curRespNum + 1
                self:dealWithRewardResult(result.reward,subType)
            end,function (errorid)
                curRespNum = curRespNum + 1
                self:checkGetReward()
            end,nil,function ( ... )
                self:timeoutCallback()
            end)
        end
    elseif subType == 311 then
        local index = subType - 308
        local hasTimes = self._elementModel:getAllElementTimes()[self._itemId]
        local stageId = self._elementModel:getElementData()["stageId"..index] or 0
        if stageId > 0 then
            self._serverMgr:sendMsg("ElementServer", "sweepElement", {elementId = index,stageId = stageId}, true, {}, function(result)
                curRespNum = curRespNum + 1
                self:dealWithRewardResult(result.reward,subType)
            end,function (errorid)
                curRespNum = curRespNum + 1
                self:checkGetReward()
            end)
        end
    elseif subType == 312 then
        local index = subType - 308
        local hasTimes = self._elementModel:getAllElementTimes()[self._itemId]
        local stageId = self._elementModel:getElementData()["stageId"..index] or 0
        if stageId > 0 then
            self._serverMgr:sendMsg("ElementServer", "sweepElement", {elementId = index,stageId = stageId}, true, {}, function(result)
                curRespNum = curRespNum + 1
                self:dealWithRewardResult(result.reward,subType)
            end,function (errorid)
                curRespNum = curRespNum + 1
                self:checkGetReward()
            end,nil,function ( ... )
                self:timeoutCallback()
            end)
        end
    elseif subType == 313 then
        local index = subType - 308
        local hasTimes = self._elementModel:getAllElementTimes()[self._itemId]
        local stageId = self._elementModel:getElementData()["stageId"..index] or 0
        if stageId > 0 then
            self._serverMgr:sendMsg("ElementServer", "sweepElement", {elementId = index,stageId = stageId}, true, {}, function(result)
                curRespNum = curRespNum + 1
                self:dealWithRewardResult(result.reward,subType)
            end,function (errorid)
                curRespNum = curRespNum + 1
                self:checkGetReward()
            end,nil,function ( ... )
                self:timeoutCallback()
            end)
        end
    elseif subType == 314 then
        local level = self._modelMgr:getModel("UserModel"):getPlayerLevel()
        local function getAvailableIdx()
            local array = {}
            for i=1,6 do
                local mfData = self._mfModel:getTasksById(i)
                if level >= tab:MfOpen(i)["lv"] and mfData.finishTime == nil then
                    table.insert(array,i)
                end
            end
            return array
        end
        local array = getAvailableIdx()
        if #array <= 0 then return end
        local index = 1
        local function sendMsgAgain(idx)
            local hero,tempTeams = self._mfModel:getHeroAndTeamsByTaskId(array[idx])
            if not hero then 
                self:reflashData("reflashView")
                self._viewMgr:showTip("船坞派驻英雄不足")
                if mfState and mfState == 2 then
                    self:sendMsg(315)
                end
                return
            end
            if not tempTeams then
                self:reflashData("reflashView")
                self._viewMgr:showTip("船坞派驻兵团不足")
                if mfState and mfState == 2 then
                    self:sendMsg(315)
                end
                return
            end
            local teams = {}
            for i=1,table.nums(tempTeams) do
                table.insert(teams, tempTeams[i]["teamId"])
            end
            local param = {id = array[idx],heroId = hero.heroId,teams = teams, rate = 1}
            self._serverMgr:sendMsg("MFServer", "startMF", param, true, {}, function(result) 
                idx=idx+1
                if idx <=#array and array[idx] then
                    sendMsgAgain(idx)
                else
                    self._viewMgr:showTip("派驻成功")
                    if mfState and mfState == 2 then
                        self:sendMsg(315)
                    end
                    self:reflashData("reflashView")
                end
            end)
        end
        sendMsgAgain(index)
    elseif subType == 315 then
        local gifts = self._mfModel:getAllGifts()
        local ids = {}
        for i,v in ipairs(gifts) do
            table.insert(ids, v.index)
        end
        if table.nums(gifts) ~= 0 then
            self._serverMgr:sendMsg("MFServer", "oneKeyGetfinishMFReward", {ids = ids}, true, {}, function(result)
                curRespNum = curRespNum + 1
                self.callback = function ()
                    local gifts = gifts
                    local rewards = {}
                    for _,v in pairs(result.reward) do
                        for i,reward in ipairs(v) do
                            table.insert(rewards, reward)
                        end
                    end
                    self._viewMgr:showDialog("MF.MFReceiveDialog", {gifts = gifts,desc = lang("LordManager_Text6"), rewards = rewards, callback = function()
                        self:reflashData("reflashView")
                        self.callback = nil
                    end})
                end
                self:dealWithRewardResult(result.reward,subType)
                
            end,function (errorid)
                curRespNum = curRespNum + 1
                self:checkGetReward()
            end,nil,function ( ... )
                self:timeoutCallback()
            end)
        end
    elseif subType == 210 then
        self._serverMgr:sendMsg("GuildServer", "getDailyAward", {id = idx}, true, {}, function (result)
            if result.rewards then
                local rewards = {}
                for i,v in ipairs(result.rewards) do
                     local data = {}
                    data.type = v[1]
                    data.typeId = v[2]
                    data.num = v[3]
                    table.insert(rewards,data)
                end
                self:dealWithRewardResult(rewards,subType)
            end
        end)
    else

    end
end

--[[
    检测船坞 任务接取&领取奖励
    314 & 315 不能同时请求
]]
function LordManagerModel:checkMFState( ... )
    -- body
    local state = 1
    if self:isSave(314) and self:isSave(315) then
        local d1 = self:getDataByIdx(314)
        local d2 = self:getDataByIdx(315)
        if d1.isOpen and d2.isOpen and d1.hTimes > 0 and d2.hTimes > 0 then
            state = 2
        end
    end
    return state
end

function LordManagerModel:calcSendTimes(subType,idx)
    if subType == 101 then
        totalRespNum = totalRespNum + 1
    elseif subType == 102 then
        totalRespNum = totalRespNum + 1
    elseif subType == 103 then
        totalRespNum = totalRespNum + 1
    elseif subType == 104 then
        totalRespNum = totalRespNum + 1
    elseif subType == 105 then
        totalRespNum = totalRespNum + 1
    elseif subType == 201 then
        totalRespNum = totalRespNum + 1
    elseif subType == 202 then
        local robData = self._modelMgr:getModel("GuildRedModel"):getSysData()
        for k,v in pairs(robData) do
            if v.robRed == 0 then
                totalRespNum = totalRespNum + 1
            end
        end
    elseif subType == 203 then
    elseif subType == 204 then
        local result = self._modelMgr:getModel("GuildModel"):getGuildMercenary()
        for k , v in pairs(result["mercenaryDetails"]) do 
            if v.teamId ~= 0 then   
                totalRespNum = totalRespNum + 1
            end
        end
    elseif subType == 301 then
        totalRespNum = totalRespNum + idx
        local dataList = self._bossModel:getRewardIdList(5)
    elseif subType == 302 then  
        totalRespNum = totalRespNum + idx
        local dataList = self._bossModel:getRewardIdList(4)
    elseif subType == 303 then
        local theme,diff = self._dailySiegeModel:getMaxSweepLevelAndThemeByType(1)
        if diff > 0 then
            totalRespNum = totalRespNum + 1
        end
    elseif subType == 304 then
        totalRespNum = totalRespNum + 1
    elseif subType == 305 then
        --毒龙
        local dragonSelectedId = subType - 304
        local pveData = self._bossModel:getDataByPveId(dragonSelectedId)
        local hardLevel = 0
        if pveData and pveData.hValue then
            hardLevel = pveData.hValue.diffId or 0
        end
        if hardLevel == 0 then return end
        totalRespNum = totalRespNum + 1
    elseif subType == 306 then
        --仙女龙
        local dragonSelectedId = subType - 304
        local pveData = self._bossModel:getDataByPveId(dragonSelectedId)
        local hardLevel = 0
        if pveData and pveData.hValue then
            hardLevel = pveData.hValue.diffId or 0
        end
        if hardLevel == 0 then return end
        totalRespNum = totalRespNum + 1
    elseif subType == 307 then
        --水晶龙
        local dragonSelectedId = subType - 304
        local pveData = self._bossModel:getDataByPveId(dragonSelectedId)
        local hardLevel = 0
        if pveData and pveData.hValue then
            hardLevel = pveData.hValue.diffId or 0
        end
        if hardLevel == 0 then return end
        totalRespNum = totalRespNum + 1
    elseif subType == 308 then
        local type  = tonumber(self:getTowerType())
        if type == 0 then return end
        totalRespNum = totalRespNum + 1
    elseif subType == 309 then
        local index = subType - 308
        local hasTimes = self._elementModel:getAllElementTimes()[self._itemId]
        local stageId = self._elementModel:getElementData()["stageId"..index] or 0
        if stageId > 0 then
            totalRespNum = totalRespNum + 1
        end
    elseif subType == 310 then
        local index = subType - 308
        local hasTimes = self._elementModel:getAllElementTimes()[self._itemId]
        local stageId = self._elementModel:getElementData()["stageId"..index] or 0
        if stageId > 0 then
            totalRespNum = totalRespNum + 1
        end
    elseif subType == 311 then
        local index = subType - 308
        local hasTimes = self._elementModel:getAllElementTimes()[self._itemId]
        local stageId = self._elementModel:getElementData()["stageId"..index] or 0
        if stageId > 0 then
            totalRespNum = totalRespNum + 1
        end
    elseif subType == 312 then
        local index = subType - 308
        local hasTimes = self._elementModel:getAllElementTimes()[self._itemId]
        local stageId = self._elementModel:getElementData()["stageId"..index] or 0
        if stageId > 0 then
            totalRespNum = totalRespNum + 1
        end
    elseif subType == 313 then
        local index = subType - 308
        local hasTimes = self._elementModel:getAllElementTimes()[self._itemId]
        local stageId = self._elementModel:getElementData()["stageId"..index] or 0
        if stageId > 0 then
            totalRespNum = totalRespNum + 1
        end
    elseif subType == 314 then
    elseif subType == 315 then
        local gifts = self._mfModel:getAllGifts()
        if table.nums(gifts) ~= 0 then
            totalRespNum = totalRespNum + 1
        end
    elseif subType == 210 then
    else
    end
end

--阴森墓穴 矮人森林 一键领取奖励
function LordManagerModel:sendPveMsg(bossId,rewardIds)
    self._serverMgr:sendMsg("BossServer", "getPVEDailyReward", 
                {bossId = bossId,id = rewardIds}, true, {}, function(errorCode ,result)
                curRespNum = curRespNum + 1
        self._bossModel:setRanksAndUserInfo(tonumber(bossId),result.d)
        self:dealWithRewardResult(result.reward,315+bossId)
    end,function (errorid)
        curRespNum = curRespNum + 1
        self:checkGetReward()
    end,nil,function ( ... )
        self:timeoutCallback()
    end)
end

function LordManagerModel:getGuildDonateReward()
    local guildScience = self._guildModel:getGuildScience()
    local scienceBase = self._guildModel:getGuildScienceBase()

    local dayinfo = self._playerTodayModel:getData()

    for i=1,3 do
        local sciRewardTab = tab:GuildContriReward(i)
        if dayinfo["day"..(17+i)] == 0 and scienceBase.todayExp >= sciRewardTab.condition then
            self:sendMsg(210, i)
        end
    end
end

function LordManagerModel:dealWithRewardResult( rewards , idx, isShow)
    if not self._rewards[idx] then
        self._rewards[idx]={}
    end
    if  idx == 315 then
        for k,reward in pairs(rewards) do
            for i,v in ipairs(reward) do
                local data = {}
                --1 type 2typeId 3 num
                data.type = v[1]
                data.typeId = v[2]
                data.num=v[3]
                if not self._rewards[idx][data.typeId] then
                    self._rewards[idx][data.typeId] = data
                else
                    if self._rewards[idx][data.typeId].type == data.type then
                        self._rewards[idx][data.typeId].num = self._rewards[idx][data.typeId].num + data.num
                    else
                        if not self._rewards[idx][data.type] then
                            self._rewards[idx][data.type] = data
                        else
                            self._rewards[idx][data.type].num = self._rewards[idx][data.type].num + data.num
                        end
                    end
                end
            end
        end
    else
        for k,v in ipairs(rewards) do
            if not self._rewards[idx][v.typeId] then
                self._rewards[idx][v.typeId] = v
            else
                if self._rewards[idx][v.typeId].type == v.type then
                    self._rewards[idx][v.typeId].num = self._rewards[idx][v.typeId].num + v.num
                else
                    if not self._rewards[idx][v.type] then
                        self._rewards[idx][v.type] = v
                    else
                        self._rewards[idx][v.type].num = self._rewards[idx][v.type].num + v.num
                    end
                end
            end
        end
    end
    if isShow == 1 then return end
    self:checkGetReward()
end

function LordManagerModel:getStageByTowerState(idx)
    local state = tonumber(self:getTowerType())
    local stage = self._cModel:getPassMaxStageId()
    if state ~= 6 then
        for i = stage,1,-1 do
            if tab.towerStage[i].rewardType == state then
                stage = i
                break
            end
        end
    else
        stage = stage - idx + 1
    end
    print("stage  "..stage)
    return stage
end

function LordManagerModel:checkNeedRedPoint()
    local isNeed = false
    for k,v in pairs(tab.lordManager) do
        --临时屏蔽捐献
        if (not self:isSave(v.subType)) or v.subType == 203 then
        else
            local data = self:getDataByIdx(v.subType)
            if data.isOpen and data.hTimes > 0 then
                if v.type == 3 then
                    if data.isPass then
                        isNeed = true
                    end
                else
                    isNeed = true
                end
                
            end
        end
    end
    return isNeed
end

function LordManagerModel:checkHasReward(idx)
    local isHave = false
    local array = self:getDataByType(idx)
    for k,v in pairs(array) do
        if not self:isSave(v.idx) then
        else
            local data = v
            if data.isOpen and data.hTimes > 0 then
                if idx == 3 then
                    if data.isPass then
                        isHave = true
                    end
                else
                    isHave = true
                end
                
            end
        end
    end
    return isHave
end

function LordManagerModel:updateRedPoint()
    self:reflashData()
end

function LordManagerModel:getData()
    return self._data or {}
end

function LordManagerModel:reflashMainView()
    self:reflashData("reflashView")
end

function LordManagerModel:dtor()
    tab = nil
    costTypeImg = nil
    rewardNum = nil
    donateCostNum = nil
    totalRespNum = nil
    curRespNum   = nil
end

return LordManagerModel