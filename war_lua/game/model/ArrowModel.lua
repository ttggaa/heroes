--[[
    Filename:    ArrowModel.lua
    Author:      <wangyan02@playcrab.com>
    Datetime:    2016-03-10 11:41:42
    Description: File description
--]]

local ArrowModel = class("ArrowModel", BaseModel)

function ArrowModel:ctor()
	ArrowModel.super.ctor(self)
	require("game.view.activity.arrow.ArrowConst")
    self._userModel = self._modelMgr:getModel("UserModel")

    self._isFirstLoad = false
    self._mul = 111      --防改参数[箭总，能量值，statis参数表]
    self._syncData = {   --同步数据结构初始化
        --syncReqId = oldReqId,  -当前同步的id，用于解决弱网时强制退出，重进又重复同步数据问题(同步时获取)
        arrowList = {},     --射箭列表{{普通箭数，大招开始时间},...}
        dieList = {},       --射死列表{{怪表id，{普通箭射中列表},{激光箭射中列表}, 大招最后一箭时间, 对应的大招开始时间, 切后台时间},...}
        mStatis = {-1, 0, 0},--{当前能量值, 命中数，爆头数}
    }
    self:initData()
end 

-- 判断当前是否在射箭界面，此时获取好友数据只更新射箭
function ArrowModel:setIsRankView(inType)
    self._isArrow = inType
end
function ArrowModel:getIsRankView()
    return self._isArrow or false
end

function ArrowModel:clearPopBoxRewards()
    self._data["popBoxRwds"] = nil
end

function ArrowModel:getPopBoxRewards()
    return self._data["popBoxRwds"] or {}
end

function ArrowModel:initData()
    local rNum = 0  --同步时后端不返回rNum字段 所以前端自己记
    if self._data["arrow"] and self._data["arrow"]["rNum"] then
        rNum = self._data["arrow"]["rNum"]
    end

	self._data = {}
	self._data["arrow"] = {}
	--rewards  铜银金
	self._data["arrow"]["rewards"] = {}
	for i=1,3 do
		self._data["arrow"]["rewards"][tostring(i)] = 0
	end
    --arrowPower
    self._data["arrow"]["arrowPower"] = -1    --0
    --CD  --2017/8/16改为supplyGT:上次领取补给箭时间
    self._data["arrow"]["supplyGT"] = 0
    --送箭红点数 
    self._data["arrow"]["rNum"] = rNum
    
    --tArrow    射箭数
    self._data["arrow"]["tArrow"] = 0
    --tHeadShot 爆头数
    self._data["arrow"]["tHeadShot"] = 0
    --tHit      射中数
    self._data["arrow"]["tHit"] = 0
    --statis
    self._data["arrow"]["mStatis"] = {
        ["1"] = 0, ["2"] = 0, ["3"] = 0, ["4"] = 0, ["5"] = 0, ["6"] = 0,
    }
    
    --memberList 送箭
    self._data["memberList"] = {}
    --eventList 送箭
    self._data["eventList"] = {}
    --friend 排行
    self._data["friend"] = {}
    --guildMember 排行
    self._data["guildMember"] = {}
end

function ArrowModel:getData()
	return self._data
end

function ArrowModel:insertArrowData(inData, inType)
    self._data[inType] = inData
    -- dump(inData, "123", 10)
    self:sortDataByType(self._data[inType], inType)
    
end

function ArrowModel:updateData(data) 
    -- dump(data, "updateData", 10)
    --重整数据
    if data["arrowPower"] then
        data["arrowPower"] = data["arrowPower"] * self._mul - 1
    end

	local function updateSubData(inSubData, inUpData)
        if type(inSubData) == "table" then
            for k,v in pairs(inUpData) do
                local backData = updateSubData(inSubData[k], v)
                inSubData[k] = backData
            end
            return inSubData
        else 
            return inUpData
        end
    end

    for k,v in pairs(data) do
        local backData = updateSubData(self._data["arrow"][k], v)
        self._data["arrow"][k] = backData
    end
end

function ArrowModel:resetPopBoxReward(inRwd)
    self._data["arrow"]["rewards"] = {}
    for i=1,3 do
        self._data["arrow"]["rewards"][tostring(i)] = 0
    end

    self._data["popBoxRwds"] = inRwd

end

-------------------------校验ing 防修改 数据同步处理--------------------------
-------------------------------------------------------------------------------
--校验  [sync: arrowList] + [model：射箭次数]
function ArrowModel:setSyncArrowList(inType, inData)
    local arrowTb = self._syncData["arrowList"]
    if inType == 1 then         --箭数
        if #arrowTb == 0 or #arrowTb[#arrowTb] == 2 then
            table.insert(arrowTb, {inData + 1})
        else
            arrowTb[#arrowTb][1] = arrowTb[#arrowTb][1] + inData + 1
        end
        --出箭次数
        self._data["arrow"]["tArrow"] = self._data["arrow"]["tArrow"] + (inData + 1) / self._mul

    elseif inType == 2 then     --激光箭开始时间
        local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
        if #arrowTb == 0 then
            table.insert(arrowTb, {0, curTime})
        elseif #arrowTb[#arrowTb] == 1 then
            table.insert(arrowTb[#arrowTb], curTime)
        end
    end

    SystemUtils.saveAccountLocalData("syncArrowData", self._syncData)
end

--校验  [sync: dieList]
function ArrowModel:setSyncDieList(inData)
    table.insert(self._syncData["dieList"], inData)
    SystemUtils.saveAccountLocalData("syncArrowData", self._syncData)
end

--校验  [sync: mStatis] + [model：命中次数/爆头次数]
function ArrowModel:setSyncStatis(inType, inData)   
    local mStatisTb = self._syncData["mStatis"]
    if inType == 1 then         --energy
        mStatisTb[inType] = inData

    elseif inType == 2 then     --命中次数
        mStatisTb[inType] = (mStatisTb[inType] or -1) + inData + 1   
        self._data["arrow"]["tHit"] = self._data["arrow"]["tHit"] + (inData + 1) / self._mul

    elseif inType == 3 then     --爆头次数
        mStatisTb[inType] = (mStatisTb[inType] or -1) + inData + 1   
        self._data["arrow"]["tHeadShot"] = self._data["arrow"]["tHeadShot"] + (inData + 1) / self._mul
    end

    SystemUtils.saveAccountLocalData("syncArrowData", self._syncData)
end

--校验  重置本地数据
function ArrowModel:resetArrowLocalData(inData)
    self._syncData = {
        arrowList = {},
        dieList = {},
        mStatis = {-1, 0, 0},
    }
    SystemUtils.saveAccountLocalData("syncArrowData", nil)
    local oldReqId = SystemUtils.loadAccountLocalData("SYNC_ARROW_REQUEST_ID") or 1  --上次同步id
    SystemUtils.saveAccountLocalData("SYNC_ARROW_REQUEST_ID", oldReqId + 1)
end

--校验  [model：宝箱 + 射死怪列表]
--@function 射死后处理
--@param    被射死的怪数据
function ArrowModel:handleShootDieMonsters(inData, inId)
    self._data["arrow"]["rewards"][tostring(inData)] = self._data["arrow"]["rewards"][tostring(inData)] + 1
    self._data["arrow"]["mStatis"][tostring(inId)] = self._data["arrow"]["mStatis"][tostring(inId)] + 1

end

--校验  [sync: 能量值] + [model：能量值]
--@function 射箭前处理
--@param    inData   使用箭个数
function ArrowModel:handleArrowShooting(inType, inData)
    -- dump(self._data, "123")
    if inType == 1 then     --arrowNum
        local now1 = self._userModel:getData().arrowNum - 1 - inData
        self._userModel:getData().arrowNum = now1

        local powerDis = tab.setting["G_ARROW_ADD_ENERGY"].value  --energy    
        local now2 = self._data["arrow"]["arrowPower"] + math.random(powerDis[1], powerDis[2]) * self._mul
        self._data["arrow"]["arrowPower"] = math.min(now2, 100*self._mul - 1)

    else
        self._data["arrow"]["arrowPower"] = -1      --2
    end
    self:setSyncStatis(1, self._data["arrow"]["arrowPower"])
end

-- 射箭参数偏移
function ArrowModel:handleArrowNum(inArrowNum)
    local arrowNum = inArrowNum * 111 - 1
    return arrowNum
end

-- 射箭参数还原
function ArrowModel:arrowNumRecover(inArrowNum)
    local arrowNum = (inArrowNum + 1) / 111
    return arrowNum
end

--------------------------------------校验end--------------------------------------------------
----------------------------------------------------------------------------------------

--送箭/领箭排序
function ArrowModel:sortDataByType(inData, inType)
    if inType == "memberList" then
        local follow = {}
        for i=#inData, 1, -1 do
            if inData[i]["follow"] == 1 then
                table.insert(follow, inData[i])
                table.remove(inData, i)
            end
        end

        --清脏数据
        for i=#inData, 1, -1 do
            if inData[i]["lt"] == nil then
                table.remove(inData, i)
            end
        end

        local sort = function(a, b) 
            return a.lt > b.lt 
        end
        table.sort(follow, sort)
        table.sort(inData, sort)

        for i=#follow,1,-1 do
            table.insert(inData, 1, follow[i])
        end
    end
end

--关注 / 取消关注
function ArrowModel:followFriend(inId, inFollow)
    local memberList = self._data["memberList"]
    for i,v in ipairs(memberList) do
        if v["memberId"] == inId then
            v["follow"] = inFollow
            self:sortDataByType(memberList, "memberList")
            return
        end
    end
end

--送好友箭
function ArrowModel:sendArrow(inId, inNum)
    local memberList = self._data["memberList"]
    for i,v in ipairs(memberList) do
        if v["memberId"] == inId then
            if inNum ~= nil then
                v["gNum"] = inNum
            else
                v["gNum"] = v["gNum"] + 1
            end
            return
        end
    end
end

--好友送箭 推送
function ArrowModel:pushSendArrow(inData)
    self._data["arrow"]["rNum"] = inData
    self:reflashData()
end

--获取玩家排名数据 命中率之类
function ArrowModel:getArrowRankData()
    -- dump(self._data, "getArrowRankData")
    local hitPer, hitHPer, myScore = 0, 0, 0
    --命中率
    if self._data["arrow"]["tArrow"] > 0 then
        hitPer = math.floor(self._data["arrow"]["tHit"] * 1000/ self._data["arrow"]["tArrow"]) * 0.001
    end

    --爆头率
    if self._data["arrow"]["tHit"] > 0 then
        hitHPer = math.floor(self._data["arrow"]["tHeadShot"] * 1000 / self._data["arrow"]["tHit"]) * 0.001
    end

    --我的评分
    if self._data["arrow"]["tArrow"] > 0 and self._data["arrow"]["tHit"] > 0 then
        for k,v in pairs(self._data["arrow"]["mStatis"]) do
            myScore = myScore + tab.arrow[tonumber(k)].jifen * v
        end
        local num1 = self._data["arrow"]["tHit"] / self._data["arrow"]["tArrow"]
        local num2 = self._data["arrow"]["tHeadShot"] / self._data["arrow"]["tHit"] 
        myScore = math.ceil(myScore * (1+ num1*0.3 + num2))
    end

    return hitPer, hitHPer, myScore
end

--设置排行榜数据 
function ArrowModel:setRankDataByType(inData, inType)
    self._data[inType] = {}
    -- dump(inData, inType)
    local userData = self._userModel:getData()
    local vipModel = self._modelMgr:getModel("VipModel"):getData()
    local _, _, myScore = self:getArrowRankData()
    local txPrivilegeModel = self._modelMgr:getModel("TencentPrivilegeModel")

    local myself = {   --自己
        rid = userData["_id"],
        arrowScore = myScore,
        avatar = userData["avatar"],
        avatarFrame = userData["avatarFrame"],
        name = userData["name"],
        vipLvl = vipModel["level"],
        tequan = txPrivilegeModel:getTencentTeQuan(), 
        qqVip = txPrivilegeModel:getQQVip()
    }

    for k,v in pairs(inData) do
        if v["arrowScore"] and v["arrowScore"] > 0 then
            table.insert(self._data[inType], v)
        end
    end
    table.insert(self._data[inType], myself)

    if next(self._data[inType]) ~= nil then
        table.sort(self._data[inType], function(a, b) 
            return a.arrowScore > b.arrowScore 
        end)
    end
end

function ArrowModel:clearRankData()
    self._data["friend"] = {}
    self._data["memberList"] = {}
end

--红点
--1 联盟达到四级
--2 有可领取的箭
--3 有玩家送箭未领
--4 有可给玩家送箭的次数
function ArrowModel:checkIsCDRedpoint()
    local userModel = self._modelMgr:getModel("UserModel")
    local supplyGT = self._data["arrow"]["supplyGT"]
    local currTime = userModel:getCurServerTime()    
    local userData = userModel:getData()
    local day40 = self._modelMgr:getModel("PlayerTodayModel"):getData().day40
    local lastT, nextT, lastGetTime = self:getSupplyGetTime() 

    if userData.guildId and userData.guildId ~= 0 then
        local guildLevel = self._modelMgr:getModel("GuildModel"):getAllianceDetail().level
        if not guildLevel then
            guildLevel = userModel:getData().guildLevel or 0
        end

        local check1 = guildLevel >= 4
        local arrowNum = userData["arrowNum"] or -1
        local check2 = supplyGT > 0 and lastGetTime < lastT and ((arrowNum + 1)/self._mul) < tab.setting["G_ARROW_LIMIT"].value
        local check3 = self._data["arrow"]["rNum"] > 0
        local check4 = tab.setting["ARROW_GIVE"].value - day40 > 0

        if check1 and (check2 or check3 or check4) then
            return true
        end
    end

    return false
end

--主界面气泡
--1 联盟达到四级
--2 有可领取的箭
function ArrowModel:checkBubble()
    local userModel = self._modelMgr:getModel("UserModel")
    local supplyGT = self._data["arrow"]["supplyGT"]
    local currTime = userModel:getCurServerTime()    
    local userData = userModel:getData()
    local day40 = self._modelMgr:getModel("PlayerTodayModel"):getData().day40
    local lastT, nextT, lastGetTime = self:getSupplyGetTime() 

    if userData.guildId and userData.guildId ~= 0 then
        local guildLevel = self._modelMgr:getModel("GuildModel"):getAllianceDetail().level
        if not guildLevel then
            guildLevel = userModel:getData().guildLevel or 0
        end

        local check1 = guildLevel >= 4
        local arrowNum = userData["arrowNum"] or -1
        local check2 = supplyGT > 0 and lastGetTime < lastT  and ((arrowNum + 1)/self._mul) < tab.setting["G_ARROW_LIMIT"].value
        if check1 and check2 then
            return true
        end
    end

    return false
end

function ArrowModel:getSupplyGetTime()
    local lastGetTime = self._data["arrow"]["supplyGT"] or 0
    local currTime = self._userModel:getCurServerTime()

    --{上一天21:00, 当天11:30, 当天17:30, 当天21:00, 第二天11:30, 第二天17:30}
    local timeList = {}
    local sysTime = clone(tab.setting["G_ARROW_REFLESH"].value)
    table.insert(sysTime, 1, sysTime[#sysTime])
    table.insert(sysTime, sysTime[2])
    table.insert(sysTime, sysTime[3])

    for i=1, #sysTime do
        local test = "%Y-%m-%d " .. sysTime[i] .. ":00"
        local tempCurDayTime
        if i == 1 then
            tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(currTime - 86400, test))
        elseif i == 5 then
            tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(currTime + 86400, test))
        else
            tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(currTime, test))
        end

        table.insert(timeList, tempCurDayTime)
    end

    local state, lastT, nextT = 0, 0, 0   --state: 0不可领 1可领
    for i=1, #timeList do
        if currTime < timeList[i] then
                nextT = timeList[i]
            break
        else
            lastT = timeList[i]
        end
    end

    -- dump(timeList, "timeList"  .. "_" .. lastT .. "_" .. nextT .. "_" .. lastGetTime)

    return lastT, nextT, lastGetTime
end

--射箭开启首次进入联盟是否拉取过数据
function ArrowModel:setIsFristLoad()
    self._isFirstLoad = true
end

function ArrowModel:getIsFirstLoad()
    return self._isFirstLoad
end

return ArrowModel