--[[
    Filename:    FriendModel.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-07-26 17:57:51
    Description: File description
--]]

local FriendModel = class("FriendModel", BaseModel)

function FriendModel:ctor()
    FriendModel.super.ctor(self)
    require("game.view.friend.FriendConst")

    self._userModel = self._modelMgr:getModel("UserModel")
    self._userData = self._modelMgr:getModel("UserModel"):getData()
    self._data = {}
    self._isLoadData = {}
    self._deleteUsid = {}

    self._phyUper = 0
    self._platData = {}

    --数据重置
    self._data[FriendConst.FRIEND_TYPE.PLATFORM] = {}
    self._data[FriendConst.FRIEND_TYPE.FRIEND] = {}
    self._data[FriendConst.FRIEND_TYPE.ADD] = {}
    self._data[FriendConst.FRIEND_TYPE.BLACK] = {}
    self:resetData()  
    

    --一键加qq好友申请记录
    self._onekeyAdd = SystemUtils.loadAccountLocalData("FRIEND_ADD_QQ_RECORD") or {}  
end

function FriendModel:setIsLoadDataByType(inType)
    if not inType then
        self._isLoadData = {}
        return
    end

    if inType == FriendConst.FRIEND_TYPE.FRIEND then
        self._isLoadData[FriendConst.FRIEND_TYPE.DELETE] = true
    end

    self._isLoadData[inType] = true
end

function FriendModel:getIsLoadDataByType(inType)
    return self._isLoadData[inType]
end

function FriendModel:resetData()
    -- self._data[FriendConst.FRIEND_TYPE.PLATFORM] = {}
    -- self._data[FriendConst.FRIEND_TYPE.FRIEND] = {}
    -- self._data[FriendConst.FRIEND_TYPE.ADD] = {}
    self._data[FriendConst.FRIEND_TYPE.APPLY] = {}
    self._data[FriendConst.FRIEND_TYPE.DELETE] = {}
end

function FriendModel:setCurChannel(inType)
    if not inType then
        self._curChannel = nil
        return
    end
    self._curChannel = inType
end

function FriendModel:updateDataByType(data, inType)
    if data == nil or not (data["d"] ~= nil or data["fList"] ~= nil) then
        return
    end

    if inType == "platform" then
        self._data[inType] = data["fList"] or {}
        data["fList"] = nil
    else
        self._data[inType] = data["d"] or {}
        data["d"] = nil
    end

    -- 特殊情况处理
    if inType == "platform" then
        self._platData = data
        self:sortPlatformData()  --sort

    elseif inType == "friend" then
        self._phyUper = data["isPhysicalUper"]
        self:sortFriendData()  --sort
        
    elseif inType == "apply" then
        for i=#self._data["apply"], 1, -1 do    --清除后端坏数据
            v = self._data["apply"][i]
            local isDataRight = (not v["_id"])      or (not v["_lt"])       or 
                                (not v["avatar"])   or
                                (not v["lvl"])      or (not v["name"])      or 
                                (not v["score"])    or (not v["sendApply"]) or 
                                (not v["usid"])     or (not v["vipLvl"])
            if isDataRight then
                table.remove(self._data["apply"], i)
            end
        end
    end
end

--获取显示的10条
-- function FriendModel:getDataByTurn(type, inTurn)
--     local insertData = {}
--     for i= (inTurn-1)*10 + 1, inTurn*10 do
--         if self._data[type][i] == nil then
--             break
--         end
--         table.insert(insertData, self._data[type][i])
--     end
--     return insertData
-- end

--获取列表数据by type
function FriendModel:getDataByType(inType)
    -- dump(self._data, inType, 10)
    if inType == FriendConst.FRIEND_TYPE.DELETE then
        inType = FriendConst.FRIEND_TYPE.FRIEND
    end
    return self._data[inType] or {}
end

--保存删除的账号usid，用于批量删除
function FriendModel:setDeleteUsid(inUsid)
    if inUsid == nil then  --清空
        self._deleteUsid = {}
        return
    end

    local searchIndex = 0
    for i,v in ipairs(self._deleteUsid) do
        if v == inUsid then
            searchIndex = i
            break
        end
    end
    -- checkbox 逻辑处理
    if searchIndex > 0 then
        table.remove(self._deleteUsid, searchIndex)
    else
        table.insert(self._deleteUsid, inUsid)
    end
end

--获取删除的usid
function FriendModel:getDeleteUsid(inUsid)
    if inUsid then   --账号是否在删除列表
        local isHas = false
        for i,v in ipairs(self._deleteUsid) do
            if v == inUsid then
                isHas = true
            end
        end
        return isHas
    else
        return self._deleteUsid
    end
end

--批量删除好友, deleteIDs为服务器返回列表
function FriendModel:deleteFriend(deleteIDs)
    local friendData = self._data[FriendConst.FRIEND_TYPE.FRIEND]
    deleteIDs = deleteIDs or self._deleteUsid
    for i,v in ipairs(deleteIDs) do
        for j,k in ipairs(friendData) do
            if v == k["usid"] then
                table.remove(friendData, j)
                break
            end
        end
    end
end

-- 平台好友排序
function FriendModel:sortPlatformData()
    local platformData = self._data[FriendConst.FRIEND_TYPE.PLATFORM]
    for i=#platformData, 1, -1 do
        --加默认值
        if platformData[i].logoutTime == nil then
            platformData[i].logoutTime = 856622797   --1997/2/22 22:46:37
        end
        if (not platformData[i].level) or (not platformData[i].storyId) then
            table.remove(platformData, i)
        end
    end

    local comp = function(a, b)
        if a.level > b.level then 
            return true
        else
            if a.level == b.level then 
                if a.storyId > b.storyId then
                    return true
                else
                    if a.storyId == b.storyId then
                        if a.logoutTime < b.logoutTime then 
                            return true
                        end
                    end
                end
            end
        end
    end

    table.sort(platformData, comp)
end

--玩家列表排序
function FriendModel:sortFriendData()
    local friendData = self._data[FriendConst.FRIEND_TYPE.FRIEND]
    local giftGet = {}  --在线【可赠送/已赠送--》登录晚》登录早】/离线【可赠送/已赠送--》登录晚》登录早】
    local onlineTab = {}  --可赠送【登录晚》登录早】/已赠送【登录晚》登录早】
    local offlineTab = {} --可赠送【登录晚》登录早】/已赠送【登录晚》登录早】

    for i,v in ipairs(friendData) do
        if v["getPhy"] == 1 then       --未领取
            table.insert(giftGet, v)
        elseif v["online"] == 1 then   --在线
            table.insert(onlineTab, v)
        else                           --离线
            table.insert(offlineTab, v)
        end
    end

    local comp = function(a, b) return a["_lt"] > b["_lt"] end
    local function compBySend(inTab)
        local _send = {}
        local _unsend = {}
        for i,v in ipairs(inTab) do
            if v["sendPhy"] == 0 then  --可赠送
                table.insert(_send, v)
            else
                table.insert(_unsend, v)
            end
        end
        table.sort(_send, comp)
        table.sort(_unsend, comp)

        for p,q in ipairs(_unsend) do
            table.insert(_send, q)
        end
        return _send
    end

    local function getComp(inTab)
        local _online = {}
        local _offline = {}
        for i,v in ipairs(inTab) do
            if v["online"] == 1 then  --在线
                table.insert(_online, v)
            else
                table.insert(_offline, v)
            end
        end
        _online = compBySend(_online)
        _offline = compBySend(_offline)

        for p,q in ipairs(_offline) do
            table.insert(_online, q)
        end
        return _online
    end

    giftGet = getComp(giftGet)
    onlineTab = compBySend(onlineTab)
    offlineTab = compBySend(offlineTab)

    for p1,q1 in ipairs(onlineTab) do
        table.insert(giftGet, q1)
    end

    for p2,q2 in ipairs(offlineTab) do
        table.insert(giftGet, q2)
    end

    self._data[FriendConst.FRIEND_TYPE.FRIEND] = giftGet
end

--plat
function FriendModel:getPlatPhysical(inOpenid)
    local platData = self._data[FriendConst.FRIEND_TYPE.PLATFORM]
    for i,v in ipairs(platData) do
        if v["openid"] == inOpenid then
            v["getPhy"] = 2
            break
        end
    end
    self:reflashData("redPoint")
end

function FriendModel:setPhyUperPlat(inNum)
    if inNum == -1 then
        self._platData["canGet"] = 0
    else
        self._platData["canGet"] = math.max(self._platData["canGet"] - inNum, 0)
    end
    self:reflashData("redPoint")
end

function FriendModel:getPhyUperPlat()
    return self._platData["canGet"] or 0
end
function FriendModel:checkIsPhyUperPlat()
    if self._platData["canGet"] and self._platData["canGet"] > 0 then
        return false
    end
    return true
end

function FriendModel:sendPlatPhysical(inOpenid)
    local platData = self._data[FriendConst.FRIEND_TYPE.PLATFORM]
    for i,v in ipairs(platData) do
        if v["openid"] == inOpenid then
            v["sendPhy"] = 1
            break
        end
    end
end

function FriendModel:setPlatRecallSuccess(inOpenid, inData)
    local platData = self._data[FriendConst.FRIEND_TYPE.PLATFORM]
    for i,v in ipairs(platData) do
        if v["openid"] == inOpenid then
            v["recallTime"] = self._userModel:getCurServerTime()
            break
        end
    end

    if inData["d"] and inData["d"]["recall"] and inData["d"]["recall"]["num"] then
        self._platData["recallNum"] = inData["d"]["recall"]["num"]
    end    
end

function FriendModel:getPlatRecallNum()
    if self._platData["recallNum"] == nil then
        self._platData["recallNum"] = 0
    end

    return self._platData["recallNum"]
end

--game friend
function FriendModel:getFriendPhysical(inUsid)
    local friendData = self._data[FriendConst.FRIEND_TYPE.FRIEND]
    for i,v in ipairs(friendData) do
        if v["usid"] == inUsid then
            v["getPhy"] = 2
            break
        end
    end
    self:reflashData("redPoint")
end

function FriendModel:setPhysicalUper(inData)
    if inData == -1 then
        self._phyUper = 0
    else
        self._phyUper = math.max(self._phyUper - inData, 0)
    end
    self:reflashData("redPoint")
end

function FriendModel:getPhysicalUper()
    return self._phyUper
end
function FriendModel:checkIsPhysicalUper()
    if self._phyUper and self._phyUper > 0 then
        return false
    end
    return true
end

--赠送单个好友体力
function FriendModel:sendFriendPhysical(inUsid)
    local friendData = self._data[FriendConst.FRIEND_TYPE.FRIEND]
    for i,v in ipairs(friendData) do
        if v["usid"] == inUsid then
            v["sendPhy"] = 1
            break
        end
    end
end

function FriendModel:checkIsCanGet(inType)
    local friendData = self._data[inType or FriendConst.FRIEND_TYPE.FRIEND]
    local isCanGet = false
    for i,v in ipairs(friendData) do
        if v["getPhy"] == 1 then  --未领
            isCanGet = true
            break
        end
    end
    return isCanGet
end

function FriendModel:checkIsCanSend(inType)
    local friendData = self._data[inType or FriendConst.FRIEND_TYPE.FRIEND]
    local isCanSend = false
    for i,v in ipairs(friendData) do
        if v["sendPhy"] == 0 then  --未发送
            isCanSend = true
            break
        end
    end
    return isCanSend
end

--一键领取
function FriendModel:quickGet(data, inType)
    -- dump(data, "123", 10)
    local checkData = self._data[inType or FriendConst.FRIEND_TYPE.FRIEND]
    -- for i,v in ipairs(data["getlist"]) do
    --     for p,q in ipairs(checkData) do
    --         if v == q["_id"] and q["getPhy"] == 1 then
    --             -- print("**********************************id", v)
    --             q["getPhy"] = 2
    --         end
    --     end
    -- end
    for i,v in ipairs(checkData) do
        v["getPhy"] = 2
    end
end

--一键赠送
function FriendModel:quickSend(inType)
    local friendData = self._data[inType or FriendConst.FRIEND_TYPE.FRIEND]
    for i,v in ipairs(friendData) do
        v["sendPhy"] = 1
    end
end


--同意/拒绝单个好友申请
function FriendModel:dealfriendApply(inUsid, isAccept)  --0拒绝  1接受
    local addData = self._data[FriendConst.FRIEND_TYPE.ADD]
    local friendData = self._data[FriendConst.FRIEND_TYPE.FRIEND] 

    for i=#addData, 1, -1 do
        if addData[i]["usid"] == inUsid then
            if isAccept == 1 then  --接受
                addData[i]["getPhy"] = addData[i]["getPhy"] or 0
                addData[i]["sendPhy"] = addData[i]["sendPhy"] or 0
                table.insert(friendData, addData[i])
                table.remove(addData, i)
                break
            else   --拒绝
                table.remove(addData, i)
            end
            break
        end
    end
end

--一键处理好友请求
function FriendModel:quickDealFriendApply(inType, inIds)
    local addData = self._data[FriendConst.FRIEND_TYPE.ADD]
    local friendData = self._data[FriendConst.FRIEND_TYPE.FRIEND]
    if inType == 1 then  --agree
        for i,id in ipairs(inIds) do
            for i=#addData, 1, -1 do
                if id == addData[i]["usid"] or id == addData[i]["_id"] then
                    addData[i]["getPhy"] = addData[i]["getPhy"] or 0
                    addData[i]["sendPhy"] = addData[i]["sendPhy"] or 0
                    table.insert(friendData, addData[i])
                    table.remove(addData, i)
                    break
                end
            end
        end
    else
        self._data[FriendConst.FRIEND_TYPE.ADD] = {}
    end
end

--申请加单个好友
function FriendModel:applyAddFriend(inUsid)
    local applyData = self._data[FriendConst.FRIEND_TYPE.APPLY]
    for i,v in ipairs(applyData) do
        if v["usid"] == inUsid then
            v["sendApply"] = 1
            break
        end
    end
end

function FriendModel:checkIsApply(inUsid)
    local applyData = self._data[FriendConst.FRIEND_TYPE.APPLY]
    -- dump(applyData, inUsid, 10)
    local isApply = false
    for i,v in ipairs(applyData) do
        if v["usid"] == inUsid or v["usid"] == tonumber(inUsid) then
            if v["sendApply"] == 1 then
                isApply = true
                break
            end
        end
    end
    return isApply
end


--全部申请
function FriendModel:quickApply(data)
    local applyData = self._data[FriendConst.FRIEND_TYPE.APPLY]
    for i,v in ipairs(data) do
        for p,q in ipairs(applyData) do
            if v == q["usid"] or v == q["_id"] then
                q["sendApply"] = 1
            end
        end
    end
end

--获取一键申请id
function FriendModel:getQuickApplyID()  
    local applyData = self._data[FriendConst.FRIEND_TYPE.APPLY]
    local idList = {}
    for i,v in ipairs(applyData) do
        if v["sendApply"] == 0 then
            table.insert(idList, v["_id"])
        end
    end
    return idList
end

function FriendModel:checkIsCanQuickApply()
    local applyData = self._data[FriendConst.FRIEND_TYPE.APPLY]
    local isCan = false
    for i,v in ipairs(applyData) do
        if v["sendApply"] == 0 then
            isCan = true
            break
        end
    end
    return isCan
end

--搜索好友  加入到申请列表
function FriendModel:addSearchFriendToApplyList(data)
    local searchData = data["d"]
    self._data[FriendConst.FRIEND_TYPE.APPLY] = {}
    table.insert(self._data[FriendConst.FRIEND_TYPE.APPLY], searchData)
end


--从黑明单移除
function FriendModel:removeFriendFromBlack(inUsid)
    local blackData = self._data[FriendConst.FRIEND_TYPE.BLACK]
    for i,v in ipairs(blackData) do
        local isUsid = ( v["usid"] == tonumber(inUsid) or v["usid"] == inUsid )
        local isRid = ( v["rid"] == tonumber(inUsid) or v["rid"] == inUsid )
        local isID = ( v["_id"] == tonumber(inUsid) or v["_id"] == inUsid )
        if isUsid or isRid or isID then
            table.remove(blackData, i)
            break
        end
    end
end

--添加到黑名单
function FriendModel:addFriendToBlack(inData)
    local blackData = self._data[FriendConst.FRIEND_TYPE.BLACK]
    local isHas = false
    for i,v in ipairs(blackData) do
        local isUsid = ( v["usid"] == tonumber(inData["inUsid"]) or v["usid"] == inData["inUsid"] )
        local isRid = ( v["rid"] == tonumber(inData["rid"]) or v["rid"] == inData["rid"] )
        local isID = ( v["_id"] == tonumber(inData["_id"]) or v["_id"] == inData["_id"] )
        if isUsid or isRid or isID then
            isHas = true
        end
    end
    if not isHas then
        table.insert(blackData, inData)
    end

    --移除好友关系
    self:deleteFriend({inData["inUsid"]})

    -- dump(self._data[FriendConst.FRIEND_TYPE.FRIEND], "friend", 10)
    -- dump(blackData, "black", 10)
end

function FriendModel:checkIsBlack(inId)
    local blackData = self._data[FriendConst.FRIEND_TYPE.BLACK]
    local isHas = false
    for i,v in ipairs(blackData) do
        local isUsid = ( v["usid"] == tonumber(inId) or v["usid"] == inId )
        local isRid = ( v["rid"] == tonumber(inId) or v["rid"] == inId )
        local isID = ( v["_id"] == tonumber(inId) or v["_id"] == inId )
        if isUsid or isRid or isID then
            isHas = true
        end
    end
    return isHas
end
    
function FriendModel:checkIsFriend(inId)
    local friendData = self._data[FriendConst.FRIEND_TYPE.FRIEND]
    -- dump(friendData, inId)
    local isHas = false
    for i,v in ipairs(friendData) do
        if v["usid"] == inId or v["name"] == inId or v["rid"] == inId or v["_id"] == inId then
            isHas = true
        end
    end
    return isHas
end

function FriendModel:checkIsInApply(inId)
    local addData = self._data[FriendConst.FRIEND_TYPE.ADD]
    local isHas = false
    for i,v in ipairs(addData) do
        if v["usid"] == inId or v["name"] == inId or v["rid"] == inId or v["_id"] == inId then
            isHas = true
        end
    end
    return isHas
end

--platform
function FriendModel:checkPlatRedPoint()
    local platData = self._data[FriendConst.FRIEND_TYPE.PLATFORM]
    local isNeed = false
    for i,v in ipairs(platData) do
        if v["getPhy"] == 1 then
            isNeed = true
            break
        end
    end
    return isNeed
end

--redpoint
function FriendModel:checkFriendRedPoint()
    local friendData = self._data[FriendConst.FRIEND_TYPE.FRIEND]
    local isNeed = false
    for i,v in ipairs(friendData) do
        if v["getPhy"] == 1 then
            isNeed = true
            break
        end
    end
    return isNeed
end

function FriendModel:checkAddRedPoint()
    self._applyUnread = self._applyUnread or 0
    if self._applyUnread > 0 then
        return true
    else
        return false
    end
end

function FriendModel:resetAddUnread()
    self._applyUnread = 0
    self:reflashData()   --update
end

--推送处理 赠送体力
function FriendModel:insertSendPhysical(data)
    -- dump(data)

    --取需要数据
    local userID = self._userData["_id"]
    if not data[tostring(userID)] then
        return
    else
        data = data[tostring(userID)]
    end

    local friendData = self._data[FriendConst.FRIEND_TYPE.FRIEND]
    local delIndex = ""
    for i=#friendData, 1, -1 do
        if friendData[i]["usid"] == data["usid"] then
            delIndex = i
            friendData[i] = data
            break
        end
    end

    self:reflashData("update_friend_".. delIndex) --update
end


--推送处理 玩家申请1
function FriendModel:insertFriendApply(data)
    -- dump(data)
    --取需要数据
    local userID = self._userData["_id"]
    if not data[tostring(userID)] then
        return
    else
        data = data[tostring(userID)]
    end
    
    local addData = self._data[FriendConst.FRIEND_TYPE.ADD]   --不需判断，因为只会添加
    table.insert(addData, 1, data)

    --unread
    self._applyUnread = self._applyUnread or 0
    if self._curChannel ~= FriendConst.FRIEND_TYPE.ADD then
        self._applyUnread = self._applyUnread + 1
    end
    self:reflashData("insert_add")   --insert
end

--推送处理 删除好友1
function FriendModel:insertDeleteFriend(data)
    if not data or data == 0 then
        return
    end

    -- dump(data)
    local friendData = self._data[FriendConst.FRIEND_TYPE.FRIEND]
    local delIndex = "" 
    for i=#friendData, 1, -1 do
        if friendData[i]["usid"] == data then
            delIndex = i
            table.remove(friendData, i)            
            break
        end
    end
    self:reflashData("delete_friend_" .. delIndex)  --remove
end

--@desc 推送处理 玩家同意申请1
function FriendModel:insertAgreeApply(data)
    -- dump(data)

    --取需要数据
    local userID = self._userData["_id"]
    if not data[tostring(userID)] then
        return
    else
        data = data[tostring(userID)]
    end

    local friendData = self._data[FriendConst.FRIEND_TYPE.FRIEND]
    table.insert(friendData, 1, data)
    self:reflashData("insert_friend")  --insert
end

function FriendModel:isFriendOpen()
    local friendOpen = tab.systemOpen["GameFriend"]
    local userData = self._userModel:getData()
    if userData.lvl >= friendOpen[1] then
        return true
    end

    return false, lang(friendOpen[3])
end

function FriendModel:isCanAddQQFriend(inId)
    local curTime = self._userModel:getCurServerTime()
    local lastT = self._onekeyAdd[tostring(inId)] or 0
    if curTime - lastT > 86400 then
        return true
    end

    return false
end

function FriendModel:setAddQQRecord(inId)
    self._onekeyAdd[tostring(inId)] = self._userModel:getCurServerTime()
    SystemUtils.saveAccountLocalData("FRIEND_ADD_QQ_RECORD", self._onekeyAdd)
end

return FriendModel