--
-- Author: <wangguojun@playcrab.com>
-- Date: 2018-02-03 13:26:59
--
local PurgatoryModel = class("PurgatoryModel", BaseModel)

function PurgatoryModel:ctor()
    PurgatoryModel.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
    self._data = {}
    self._curStage = 1  -- 当前层数
    self._stageInfos = {}   -- 当前有的层数数据
    self._buffIds = {}  -- 已选择的buff列表
    self._maxBuffStage = 0  -- 已选buff的最高层数
    self._careerList = {}   -- 已领生涯奖励的层数
    self._careerStageId = 0    -- 历史通过最高关卡
    self._friendList = {}   -- 基友闯关信息
    self._historyMaxStageId = 0     --历史最高层
end

function PurgatoryModel:setData(data, isAll)
	self._data = {}

    self._data = data

    if data.si then
    	self._curStage = data.si
    	data.si = nil
    end

    if data.stageInfos then
    	self:setStageInfos(data.stageInfos)
    	data.stageInfos = nil
    end

    if data.buffIds then
        self._buffIds = clone(data.buffIds)
        data.buffIds = nil
    elseif isAll then
        self._buffIds = {}
    end

    if data.bi then
        self._maxBuffStage = data.bi
        data.bi = nil
    elseif isAll then
        self._maxBuffStage = 0
    end

    if data.maxi then
        self._historyMaxStageId = data.maxi
        data.maxi = nil
    end

    if data.acci then
        self._careerStageId = data.acci
        data.acci = nil
    end

    if data.acr then
        self._careerList = data.acr
        data.acr = nil
    end

    self:reflashData()
end

function PurgatoryModel:getHistoryMaxStageId(  )
    return self._historyMaxStageId
end

function PurgatoryModel:setFriendData( list )
    list = list or {}
    if #list <= 0 then
        return
    end
    self._friendList = {}
    self._friendList = list
end

function PurgatoryModel:getFriendDataByFloor( floor )
    local result = {}
    for k, v in pairs(self._friendList) do
        if v and v.hPurI and v.hPurI >= floor then
            table.insert(result, clone(v))
        end
    end
    return result
end

function PurgatoryModel:getCareerInfo(  )
    return self._careerStageId, self._careerList
end

function PurgatoryModel:setStageInfos( info )
	for k, v in pairs(info) do
		self._stageInfos[tonumber(k)] = clone(v)
	end
end

function PurgatoryModel:getBuffIds(  )
    return self._buffIds
end

function PurgatoryModel:getData()
    return self._data
end

function PurgatoryModel:getCurrentSite(  )
	return self._curStage
end

function PurgatoryModel:getStageInfos(  )
	return self._stageInfos
end

function PurgatoryModel:updateData( inData )
	self:reflashData()
end

function PurgatoryModel:isHaveRedPrompt(  )
    -- 是否有可领取奖励
    local isOpen = self:isOpenPurgatory()
    if not isOpen then
        return false
    end
    
    local careerCfg = clone(tab.purAccuReward)
    for k, v in pairs(careerCfg) do
        local floorNum = v.floor
        if floorNum <= self._careerStageId then
            local isGetReward = self._careerList[tostring(v.id)]
            if not isGetReward then
                return true
            end
        end
    end
    return false
end

function PurgatoryModel:getHighScoreStage(  )
    local hscore = self._userModel:getData().hScore
    local result = 1
    local purFight = clone(tab.purFight)
    for k, v in pairs(purFight) do
        local reach = v.reach
        if hscore >= reach then
            result = k
        else
            break
        end
    end
    return result
end

function PurgatoryModel:getShowBuffIdList(  )
    if self._curStage - self._maxBuffStage < 2 then
        return {}
    end
    local showBuffIdList = {}
    local stageCfg = tab.purFight
    for i = self._maxBuffStage + 1, self._curStage - 1 do
        local st = stageCfg[i].type or 100
        if st == 2 then
            table.insert(showBuffIdList, i)
        end
    end
    return showBuffIdList
end

function PurgatoryModel:showBuffSelectDialog( stageId, callback )
    --stage
    if stageId and stageId == self._curStage then
        local sData = self._stageInfos[stageId]
        if sData and sData.buffs then
            self._viewMgr:showDialog("purgatory.PurgatoryBuffSelectDialog", {buff = clone(sData), callback = callback})
        end
        return
    end

    if stageId then
        return
    end

    --forwards
    local showBuffIdList = self:getShowBuffIdList()
    if #showBuffIdList <= 0 then
        return
    end
    local reqList = {}
    for k, v in pairs(showBuffIdList) do
        if not self._stageInfos[v] then
            table.insert(reqList, v)
        end
    end

    local function showBuffSelectList( buffList )
        print("========PurgatoryBuffSelectDialog buffList num:", #buffList)
        local completeList = {}
        for k, v in pairs(buffList) do
            local sData = self._stageInfos[v]
            if sData and sData.buffs then
                table.insert(completeList, clone(sData))
            end
        end
        if #completeList > 0 then
            print("========PurgatoryBuffSelectDialog completeList num:", #completeList)
            self._viewMgr:showDialog("purgatory.PurgatoryBuffSelectDialog", {buffList = completeList, callback = callback})
        end
    end

    if #reqList <= 0 then
        showBuffSelectList(showBuffIdList)
        return
    end
    self._serverMgr:sendMsg("PurgatoryServer", "getStageInfo", {stageIds = reqList}, true, {}, function ( result )
        showBuffSelectList(showBuffIdList)
    end, function ( errorId )
        errorId = tonumber(errorId)
        print("errorId:" .. errorId)
    end)
end

function PurgatoryModel:setEnemyData(inData)
    local tempData = {}
    for k,v in pairs(inData) do
        v.teamId = tonumber(k)
        tempData[tonumber(k)] = v
    end
    self._enemyData = tempData
end

function PurgatoryModel:setEnemyHeroData(inData)
    self._enemyHeroData = inData
end

function PurgatoryModel:getEnemyHeroData()
    if self._enemyHeroData == nil then 
        return nil
    end
    return self._enemyHeroData
end

function PurgatoryModel:setStageId( id )
    self._stageId = id
end

function PurgatoryModel:getStageId( id )
    return self._stageId
end

function PurgatoryModel:getEnemyDataById(inTeamId)
    if self._enemyData == nil then 
        return nil
    end
    return self._enemyData[tonumber(inTeamId)]
end

function PurgatoryModel:getStageRandomEnemy( stage, random )
    local curServerTime = self._userModel:getCurServerTime()
    local timeStr = TimeUtils.getDateString(curServerTime, "%Y%m%d")
    local localData = SystemUtils.loadGlobalLocalData("PURGATORY_STAGE_RANDOM_ENEMY_" .. timeStr) or {}
    if localData[stage] then
        return localData[stage]
    else
        localData[stage] = random
        SystemUtils.saveGlobalLocalData("PURGATORY_STAGE_RANDOM_ENEMY_" .. timeStr, localData)
        return random
    end
    return random
end

function PurgatoryModel:isShowQiPao(  )
    local isOpen = self:isOpenPurgatory()
    if not isOpen then
        return false
    end
    local curServerTime = self._userModel:getCurServerTime()
    local timeStr = TimeUtils.getDateString(curServerTime, "%Y%m%d")
    local isQiPao = SystemUtils.loadGlobalLocalData("PURGATORY_IS_SHOW_QIPAO" .. timeStr)
    if isQiPao == nil then
        return true
    end
    return false
end

function PurgatoryModel:isOpenPurgatory(  )
    local openDay = tab.setting["PURGATORY_DAY"].value or {}
    local openTime = tab.setting["PURGATORY_TIME"].value or {}

    if #openDay < 1 or #openTime < 2 then
        return false, "活动未开启"
    end

    local userModel = self._modelMgr:getModel("UserModel")
    local time = userModel:getCurServerTime()
    local weekday = TimeUtils.getDateString(time, "%w")
    local hour = TimeUtils.getDateString(time, "%H")
    weekday = tonumber(weekday)
    hour = tonumber(hour)
    if weekday == 0 then
        weekday = 7
    end
    if table.indexof(openDay, weekday) then
        if hour >= openTime[1] and hour < openTime[2] then
            return true, ""
        end
    end

    local tips = "无尽炼狱只在每"
    local zh = {"一", "二", "三", "四", "五", "六", "日"}
    for k, v in pairs(openDay) do
        if k ~= #openDay then
            tips = tips .. '周' .. zh[v] .. "、"
        else
            tips = tips .. '周' .. zh[v]
        end
    end
    tips = tips .. openTime[1] .. "点到" .. openTime[2] .. "点开启，敬请期待"

    return false, tips
end

function PurgatoryModel:showPurgatoryView(  )
    local isOpen, toBeOpen, level = SystemUtils["enablePurgatory"]()
    if isOpen then
        local open, txt = self:isOpenPurgatory()
        if open then
            self._viewMgr:showView("purgatory.PurgatoryView")
        else
            self._viewMgr:showTip(txt)
        end
    else
        local tips = "无尽炼狱将在" .. level .. "级开启，敬请期待"
        self._viewMgr:showTip(tips)
    end
end

return PurgatoryModel