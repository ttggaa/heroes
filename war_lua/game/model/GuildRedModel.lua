--[[
    Filename:    GuildRedModel.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-06-07 14:10:56
    Description: File description
--]]


local GuildRedModel = class("GuildRedModel", BaseModel)

function GuildRedModel:ctor()
    GuildRedModel.super.ctor(self)
    self._sysRedData = {}
    self._robRedList = {}
    self._randRedList = {}
    self:registerTimer(21,0,0, specialize(self.updateUI, self))
    -- self._modelMgr = ModelManager:getInstance()
    -- self._userModel = self._modelMgr:getModel("UserModel")
    -- self._vipModel = self._modelMgr:getModel("VipModel")
    -- self._itemModel = self._modelMgr:getModel("ItemModel")



end



-- 处理抢红包列表排序
function GuildRedModel:progressRobRed()
    if table.nums(self._robRedList) <= 1 then
        return 
    end
    local sortFunc = function(a,b)
        local acheck = a.robRed
        local bcheck = b.robRed
        local atime = a.cTime 
        local btime = b.cTime 
        if acheck < bcheck then
            return true
        elseif acheck == bcheck then
            if atime > btime then
                return true
            end
        end
        return false
    end
    table.sort(self._robRedList, sortFunc)
end

--接受随机红包数据
function GuildRedModel:setRandRedData(data)
    self._randRedList = {}
    for _,redId in pairs (data) do 
        table.insert(self._randRedList,redId)
    end
    self:reflashData()
end


--检测是否弹出随机红包获得 或 发随机红包界面
function GuildRedModel:checkRandRed()

    print(">>>>>>>>>>>>>>>>> GuildRedModel:checkRandRed <<<<<<<<<<<<<<<<<<<")
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local roleGuild = userData.roleGuild
    if not self._randRedList then self._randRedList = {} end
    if #self._randRedList > 0 then
        local viewData = {}
        if not roleGuild then --没有联盟
            local reward = {}
            for _,id in pairs (self._randRedList) do 
                local tempData = tab:RandomRed(id).tool[1]
                table.insert(reward,{type = tempData[1],typeId = tempData[2],num = tempData[3]})
            end
            viewData.gifts = reward
        else
            viewData.redIdList = self._randRedList
        end
        self._viewMgr:activeRandRedDialog(viewData)
    end
end

function GuildRedModel:getRandRedData()
    return self._randRedList or {}
end


function GuildRedModel:setRobList(data)
    self._robRedList = {}
    local userid = self._modelMgr:getModel("UserModel"):getData()._id 
    for k,v in pairs(data) do
        local robRed = 0
        local redTab = tab:GuildUserRed(v.id)
        if redTab["people"] - v.rob <= 0 then
            robRed = 2
        end
        for kk,vv in pairs(v.ids) do
            if tostring(vv) == userid then
                robRed = 1
                break
            end
        end
        v.robRed = robRed
        v.redId = k
        table.insert(self._robRedList, v)
    end
    self._modelMgr:getModel("GuildRedModel"):setUpdateRobList(true)
    self:progressRobRed()
    self:reflashData()
end

-- 更新抢红包列表
function GuildRedModel:updateUserRedData(data)
    local userid = self._modelMgr:getModel("UserModel"):getData()._id 
    for k,v in pairs(data) do
        local robRed = 0
        local redTab = tab:GuildUserRed(v.id)
        if redTab["people"] - v.rob <= 0 then
            robRed = 2
        end
        for kk,vv in pairs(v.ids) do
            if tostring(vv) == userid then
                robRed = 1
                break
            end
        end
        v.robRed = robRed
        v.redId = k
        for i=1,table.nums(self._robRedList) do
            if self._robRedList[i]["redId"] == k then
                self._robRedList[i] = v
            end
        end
    end
    self:progressRobRed()
    self:reflashData()
end

-- 获取抢红包列表
function GuildRedModel:getRobList()
    return self._robRedList or {}
end

function GuildRedModel:setUpdateRobList(flag)
    if flag == false then
        self._robRedList = {}
    end
    self._robRedData = flag
end

-- 是否刷新抢红包列表
function GuildRedModel:getUpdateRobList()
    return self._robRedData
end



-- function GuildRedModel:reflashRedRobUI()
--     self:reflashData()
-- end

-- 更新红包数据
function GuildRedModel:updateSysRedData(data)
    -- dump(data)
    local userid = self._modelMgr:getModel("UserModel"):getData()._id 
    for k,v in pairs(data) do
        local robRed = 0
        local redTab = tab:GuildRed(v.id)
        if redTab["people"] - v.rob <= 0 then
            robRed = 2
        end
        for kk,vv in pairs(data[k].ids) do
            if tostring(vv) == userid then
                robRed = 1
                break
            end
        end
        v.robRed = robRed
        v.redId = k
        if tab:GuildRed(v.id)["type"] == "gold" then
            self._sysRedData[1] = v
        elseif tab:GuildRed(v.id)["type"] == "gem" then
            self._sysRedData[2] = v
        elseif tab:GuildRed(v.id)["type"] == "treasureCoin" then
            self._sysRedData[3] = v
        end
    end
    self:reflashData()
end

-- 处理系统红包
function GuildRedModel:setSysData(data)
    self._sysRedData = self:processRedData(data)
    self:reflashData()
end

function GuildRedModel:processRedData(data)
    local tempData = {}
    -- dump(data, "data ======")
    local userid = self._modelMgr:getModel("UserModel"):getData()._id 
    for k,v in pairs(data) do
        local robRed = 0
        local redTab = tab:GuildRed(v.id)
        if redTab["people"] - v.rob <= 0 then
            robRed = 2
        end
        for kk,vv in pairs(data[k].ids) do
            if tostring(vv) == userid then
                robRed = 1
                break
            end
        end
        v.robRed = robRed
        v.redId = k
        if tab:GuildRed(v.id)["type"] == "gold" then
            tempData[1] = v
        elseif tab:GuildRed(v.id)["type"] == "gem" then
            tempData[2] = v
        elseif tab:GuildRed(v.id)["type"] == "treasureCoin" then
            tempData[3] = v
        end
    end
    return tempData
end

function GuildRedModel:getSysData()
    return self._sysRedData
end

-- 9点刷新
function GuildRedModel:updateUI()
    self._sysRedData = {}
    self:reflashData()
end

function GuildRedModel:setRedRob(flag)
    self._redRobHistory = flag
end

function GuildRedModel:getRedRob()
    return self._redRobHistory or false
end

function GuildRedModel:setRedSend(flag)
    self._redSendHistory = flag
end

function GuildRedModel:getRedSend()
    return self._redSendHistory or false
end

--全局红包推送  wangyan
function GuildRedModel:updateRobMainRed(data)
    --每日领取上限
    local curNum = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(15) or 0
    local maxNum = self._modelMgr:getModel("GuildModel"):getRedRobTimes()
    if curNum >= maxNum then
        return
    end

    local isRand = false
    for _,v in pairs (data) do 
        if v.type == "random" then
            isRand = true
            break
        end
    end

    local isSend = self:isRedChaoshi()
    if isSend == false and isRand ~= true then   --5点之后才可领取
        print("5点之后才可领取")
        return
    end

    -- dump(data, "data =======", 10)

    local userData = self._modelMgr:getModel("UserModel"):getData()
    for k,v in pairs(data) do
        if v["rid"] ~= userData["_id"] then
            self:setGlobalRobRedList(k, v)
            self._viewMgr:activeGiftMoneyTip()
        end
    end
end 

function GuildRedModel:setGlobalRobRedList(index, data)
    if self.globalRedList == nil then
        self.globalRedList = {}
    end
    self.globalRedList[index] = data
end

function GuildRedModel:removeGlobalRed(index)
    self.globalRedList[index] = nil
end

function  GuildRedModel:getGlobalRobRedList()
    return self.globalRedList
end

-- 退出联盟后第二天凌晨5点可领取红包
function GuildRedModel:isRedChaoshi()
    local userModel = self._modelMgr:getModel("UserModel")
    local guildLeaveTime = userModel:getData()["guildLeave"] or 0
    local curServerTime = userModel:getCurServerTime()

    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(guildLeaveTime,"%Y-%m-%d 05:00:00"))
    if tempCurDayTime > guildLeaveTime then
        tempCurDayTime = tempCurDayTime - 86400
    end

    if curServerTime - tempCurDayTime > 86400 then
        return true
    else
        return false
    end
end

-- 红包红点提示
function GuildRedModel:updateRedTipButtle()
    -- local flag = false

    local sysRedData = self:getSysData()
    local flag = 0
    for i=1,3 do
        local redData = sysRedData[i]
        if redData and redData.robRed == 0 then
            flag = 1
            break
        end
    end

    local param = {["1"] = flag}
    self._modelMgr:getModel("GuildModel"):updateBubbleData(param)
end



--nil 为没有半价 1,2,3 分别对应 黄金,钻石,宝物
function GuildRedModel:isShowHalfRed()
    local isHalf = self._modelMgr:getModel("PlayerTodayModel"):getData().day56
    print("GuildRedModel:isShowHalfRed-----------------------------------")
    print(isHalf)
    if not isHalf or isHalf <= 0 then
        local userVipLv = self._modelMgr:getModel("VipModel"):getLevel()
        local gold,gem,treasure
        local guildUserData = tab:GuildUserRed(2)
        gold = guildUserData.vipEffect
        guildUserData = tab:GuildUserRed(4)
        gem = guildUserData.vipEffect
        guildUserData = tab:GuildUserRed(6)
        treasure = guildUserData.vipEffect
        return userVipLv >= treasure and 3 or userVipLv >= gem and 2 or userVipLv >= gold and 1
    end
end

-- function GuildRedModel:logProgessData()
--     if table.nums(self._logData) <= 1 then
--         return 
--     end
--     local sortFunc = function(a,b)
--         local acheck = a.eventTime
--         local bcheck = b.eventTime
--         if acheck > bcheck then
--             return true
--         end
--     end
--     table.sort(self._logData, sortFunc)
-- end



return GuildRedModel
