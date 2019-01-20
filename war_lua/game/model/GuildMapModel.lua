--[[
    Filename:    GuildMapModel.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-06-13 14:20:16
    Description: File description
--]]


local GuildMapModel = class("GuildMapModel", BaseModel)

require "game.view.guild.GuildConst"
function GuildMapModel:ctor()
    GuildMapModel.super.ctor(self)
    self:onInit()
end

function GuildMapModel:onInit(isPreview)
    self._data.upTime = 0
    self._data.mapid = 0
    self._data.isRelashMap = false

    self._data.fogs = {}
    self._data.sphinxRank = {}
    self._shapes = {}
    self._events = {}
    if isPreview == true then
        self._lockPush = true
    else
        self._lockPush = false
    end
	self._yearBuff = {}

    self._enemyHeroData = {}
    self._enemyData = {}
    --是否打开过规则界面，用于判断红点 by wangyan   
    self._isOpenRule = SystemUtils.loadAccountLocalData("GUILD_MAP_RULEVIEW_OPEN_STATE") or false   
end

function GuildMapModel:getData()
    return self._data
end

function GuildMapModel:interceptFogs(data)
    if data.fogs ~= nil then 
        self._data.fogs = {}
        for k,v in pairs(data.fogs) do
            self._data.fogs[v] = 1
        end
        data.fogs = nil
    end
end

-- 子类覆盖此方法来存储数据
function GuildMapModel:setData(data)
    self._infoChecked = false
    -- if self._data.mapList == nil then 
    --     self._data.mapList = {}
    -- end

    -- 对比id处理地图重置
    if self._data.mapid ~= data.mapId  then 
        local tempFogs = {}
        if data.fogs ~= nil then
            tempFogs.fogs = data.fogs
            data.fogs = nil
        end
		if self._data.tMap ~= nil and not data.tMap then
			self:clearTreasureState()
		end
        self._data = data
        self:interceptFogs(tempFogs)
        self._data.isReflashMap = true
		if data.yearBuff then
			self:setYearBuffData(data.yearBuff)
		end
		if data.jxGid and data.jxGid~=0 then
			self:setOfficerTargetGuildId(data.jxGid)
		end
    end
    if self._data.fogs == nil then 
        self._data.fogs = {}
    end
end

function GuildMapModel:addData(data, reflash)
    for k,v in pairs(data) do
        if self._data.mapList[k] ~= nil then 
            for k1,v1 in pairs(v) do
                -- 移除数据,my,common,guild
                self._data.mapList[k][k1] = v1
            end
        else
            self._data.mapList[k] = v
        end
    end
    
    self._events["AddEle"] = clone(data)
    if reflash == true then 
        self:reflashData("AddEle")
    end
    -- self._events["DelEle"] = tempData
    -- self:reflashData("DelEle")
end

function GuildMapModel:delData(data, reflash)
    for k,v in pairs(data) do
        if self._data.mapList[k] ~= nil then 
            for k1,v1 in pairs(v) do
                -- 移除数据,my,common,guild
                if self._data.mapList[k][k1] ~= nil then 
                    self._data.mapList[k][k1] = nil
                end
            end
        end
    end
    if reflash == true then 
        self._events["DelEle"] = clone(data)
        self:reflashData("DelEle")
    else
        self._events["DelEle_CUR"] = clone(data)
    end
    -- self._events["DelEle"] = tempData
    -- self:reflashData("DelEle")
end

function GuildMapModel:updateGuildListData(data, reflash)
    if data.currentGuildId ~= nil then
        self._data.currentGuildId = data.currentGuildId
    end
    if data.guildList ~= nil then
        self._data.guildList = data.guildList
    end
    if data.speGid ~= nil then
        self._data.speGid = data.speGid
    end
end


function GuildMapModel:updateNearGrid(data, reflash)
    local backData = {}
    for k,v in pairs(data.upNear) do
        self._data.mapList[k] = v
        backData[k] = v
    end
    if reflash == true then 
        self._events["UpNear"] = backData
        self:reflashData("UpNear")
    else
        self._events["UpNear_CUR"] = backData
    end    
end


function GuildMapModel:updateData(data, reflash)
    if data.upTime ~= nil then 
        self._data.upTime = data.upTime
    end
    if self._data.mapList == nil then 
        return
    end
    local function updateSubData(inSubData, inUpData)
        local backData
        if type(inSubData) == "table" and next(inSubData) ~= nil then
            for k,v in pairs(inUpData) do
                if type(v) == "table" and next(v) ~= nil then 
                    backData = updateSubData(inSubData[k], v)
                else
                    backData = v
                end
                inSubData[k] = backData
            end
            return inSubData
        else 
            return inUpData
        end
    end

    self:interceptFogs(data)
    local backData 
    for k,v in pairs(data) do
        if k ~= "mapList" then 
            backData = updateSubData(self._data[k], v)
            self._data[k] = backData
        end
    end
    if data.mapList == nil then 
        return
    end
    local backData = {}
    for k,v in pairs(data.mapList) do
        if self._data.mapList[k] == nil  then 
            self._data.mapList[k] = {}
        end 
        if backData[k] == nil then 
            backData[k] = {}
        end
        for k1,v1 in pairs(v) do
            self._data.mapList[k][k1] = v1
            backData[k][k1] = v1        
        end
    end
    return backData
end

-- function GuildMapModel:updateDataState(data)
--     for k,v in pairs(data) do
--         if k ~= "mapList" then 
--             self._data[k] = v
--         else
--             for k1,v1 in pairs(v) do
--                 local tempStr = json.decode(v1)
--                 local md5 = pc.PCTools:md5(tempStr)
--                 if self._data.mapList[k1].md5 ~= md5 then 
--                     self._data.mapList[k1].md5 = md5
--                     self._data.mapList[k1].isUpdate = true
--                 end
--             end
--         end
--     end
-- end

function GuildMapModel:updateSkipPosData(data, reflash)
    print("updateRoleMoveData======================")
    if data.mapList ~= nil then
        for k,v in pairs(data.mapList) do
            if data.mapList[k].player == nil then 
                data.mapList[k].player ={}
            end
        end   
        self:updateData(data) 
    end
    
    local tempData = {}
    if data.mvInfo ~= nil then 
        tempData = data.mvInfo
    end
    
    if reflash == true then 
        self._events["SkipPos"] = tempData
        self:reflashData("SkipPos")
    else
        self._events["SkipPos_CUR"] = tempData
    end
end

function GuildMapModel:updateRoleMoveData(data, reflash)
    if data.mapList ~= nil then
        for k,v in pairs(data.mapList) do
            if data.mapList[k].player == nil then 
                data.mapList[k].player ={}
            end
        end   
        self:updateData(data) 
    end
    
    if reflash == true then 
        local tempData = {}
        if data.mvInfo ~= nil then 
            tempData = data.mvInfo
        end
        self._events["RoleMove"] = clone(tempData)
        self:reflashData("RoleMove")
    else
        if data.selfPoint ~= nil then
            print("reflash============RoleMove_CUR=============")
            self._events["RoleMove_CUR"] = data.selfPoint
        end
    end
end


function GuildMapModel:updateFog(data, reflash)
    local fogBig = data.fogBig
    data.fogBig = nil
    local backData = self:updateData(data)
    if reflash == true then 
        self._events["MissFog"] = fogBig
        self:reflashData("MissFog")
    else
        self._events["MissFog_CUR"] = fogBig
    end
end

function GuildMapModel:updateRoleProgress(data, reflash)
    if data.userList == nil or next(data.userList) == nil then 
        return
    end
    
    if reflash == true then 
        self._events["RoleProgress"] = clone(data.userList)
        self:reflashData("RoleProgress")
    else
        self._events["RoleProgress_CUR"] = clone(data.userList)
    end
end


-- function GuildMapModel:quickCancelRoleProgress(data, reflash)
--     if reflash == true then 
--         self._events["CancelRoleProgress"] = clone(data)
--         self:reflashData("CancelRoleProgress")
--     else
--         self._events["CancelRoleProgress_CUR"] = clone(data)
--     end
-- end

function GuildMapModel:cancelRoleProgress(data, reflash)
    if data.userList == nil or next(data.userList) == nil then 
        return
    end
    
    if reflash == true then 
        self._events["CancelRoleProgress"] = clone(data.userList)
        self:reflashData("CancelRoleProgress")
    else
        self._events["CancelRoleProgress_CUR"] = clone(data.userList)
    end
end

function GuildMapModel:updateEleData(data, reflash)
    if data.mapList == nil or next(data.mapList) == nil then 
        return
    end
    local backData = self:updateData(data)
    if reflash == true then 
        self._events["EleState"] = clone(backData)
        self:reflashData("EleState")
    else
        self._events["EleState_CUR"] = clone(backData)
    end
end

function GuildMapModel:updateBackReviveData(data, reflash)
    if (data.bp == nil or next(data.bp) == nil) then 
        return
    end

    local userId = self._modelMgr:getModel("UserModel"):getData()._id
    local mySelfBp = {}
    local otherUserBp = {}
    local bp = data.bp
    for k,backCity in pairs(bp) do
        local playerBeginGrid = self._data.mapList[backCity["begin"]]
        if playerBeginGrid == nil then 
            self._data.mapList[backCity["begin"]] = {}
            playerBeginGrid = self._data.mapList[backCity["begin"]]
        end

        local playerEndGrid = self._data.mapList[backCity["end"]]
        if playerEndGrid == nil then 
            self._data.mapList[backCity["end"]] = {}
            playerEndGrid = self._data.mapList[backCity["end"]]
        end
        if playerEndGrid.player == nil then 
            playerEndGrid.player = {}
        end
        playerEndGrid.player[backCity.userId] = 1

        if playerBeginGrid ~= nil and playerBeginGrid.player ~= nil then 
            for k,v in pairs(playerBeginGrid.player) do
                if k == backCity.userId then 
                    playerBeginGrid.player[k] = nil
                    break
                end
            end
        end
        backCity.isQuick = true
        if userId == backCity.userId and reflash ~= true then
            table.insert(mySelfBp, backCity)
        else
            table.insert(otherUserBp, backCity)
        end
    end
    data.bp = nil
    local backData = self:updateData(data)
    if mySelfBp ~= nil and next(mySelfBp) ~= nil then 
        self._events["BackRevive_CUR"] = mySelfBp
    end
    if otherUserBp ~= nil and next(otherUserBp) ~= nil then
        self._events["BackRevive"] = otherUserBp
        self:reflashData("BackRevive")
    end
end


function GuildMapModel:updateBackCityData(data, reflash)
    if data.backCity == nil or next(data.backCity) == nil then 
        return
    end
    local backCity = data.backCity
    local playerBeginGrid = self._data.mapList[backCity["begin"]]
    if playerBeginGrid == nil then 
        playerBeginGrid = {}
    end

    local playerEndGrid = self._data.mapList[backCity["end"]]
    if playerEndGrid == nil then 
        self._data.mapList[backCity["end"]] = {}
        playerEndGrid = self._data.mapList[backCity["end"]]
    end
    if playerEndGrid.player == nil then 
        playerEndGrid.player = {}
    end
    playerEndGrid.player[backCity.userId] = 1

    if playerBeginGrid ~= nil and playerBeginGrid.player ~= nil then 
        for k,v in pairs(playerBeginGrid.player) do
            if k == backCity.userId then 
                playerBeginGrid.player[k] = nil
                break
            end
        end
    end
    backCity.isQuick = true
    data.backCity = nil
    local backData = self:updateData(data)
    if reflash == true then 
        self._events["BackCity"] = clone(backCity)
        self._events["RoleMove"] = clone(backCity)
        self:reflashData("RoleMove")
        self:reflashData("BackCity")
    else
        self._events["BackCity_CUR"] = clone(backCity)
        self._events["RoleMove_CUR"] = clone(backCity)
    end
end


function GuildMapModel:updateBattleData(data, reflash)
    -- dump(data)
    self:updateEleData(data, false)
    self:updateBackCityData(data, false)
end



function GuildMapModel:updateBattleTip(data)
    self._events["BattleTip"] = nil
    self._events["BattleTip"] = data
    self:reflashData("BattleTip")
end

function GuildMapModel:updateNewRoleJoin(data, reflash)
    self._events["NewRoleJoin"] = nil
    if data.userList == nil or next(data.userList) == nil then 
        return
    end    
    local backData = self:updateData(data)
    if reflash == true then  
        self._events["NewRoleJoin"] = clone(data)
        self:reflashData("NewRoleJoin")
    end
end

function GuildMapModel:updateRoleQuit(data, reflash)
    print('updateRoleQuit-----------------------')
    if data.delUser == nil then 
        return
    end
    print('1updateRoleQuit-----------------------')

    if data.delUser.userId == nil then 
        return
    end

    print('2updateRoleQuit-----------------------')

    if data.delUser.gid == nil then 
        return
    end
    
    self._events["RoleQuit"] = nil

    print('3updateRoleQuit-----------------------')

    local userId = data.delUser.userId
    data.userid = nil

    local gridKey = data.delUser.gid 
    data.gid = nil

    -- 退出公会，移除数据
    if self._data ~= nil and self._data.mapList ~= nil then 
        local playerGrid = self._data.mapList[gridKey]
        if playerGrid ~= nil and playerGrid.player ~= nil then 
            for k,v in pairs(playerGrid.player) do
                if k == userId then 
                    playerGrid.player[k] = nil
                    break
                end
            end
        end
    end
    local param = {userId = userId, gid = gridKey}
    local backData = self:updateData(data)
    self._events["RoleQuit"] = clone(param)
    if reflash == true then 
        print('updateRoleQuit=============================')
        self:reflashData("RoleQuit")
    end
    local cancelData = {}
    cancelData[userId] = ""
    -- self:quickCancelRoleProgress(reflash)
end

function GuildMapModel:dataNotMatching(data)
    self:reflashData("Matching")
    self:onInit()
    self:setData(data)
    self:reflashData("MatchingFinish")
end

function GuildMapModel:pushSwitchGuild()
    self._events["PushSwitchGuild"] = 1
    self:reflashData("PushSwitchGuild")
end

function GuildMapModel:switchGuild(data, reflash)
    if reflash == true then 
        self._events["SwitchGuild"] = 1
        self:reflashData("SwitchGuild")
    else
        self._events["SwitchGuild_CUR"] = clone(backData)
    end    
end

function GuildMapModel:initShapes(inMaxGrid, inFirstPoint, inScale, gCallback)
    if self._shapes ~= nil and next(self._shapes) ~= nil then 
        return 
    end
    self._shapes = {}
    local x1, y1 = inFirstPoint.x, inFirstPoint.y
    local x,  y = 0, 0
    for a=1, inMaxGrid.a do
        for b=1, inMaxGrid.b do
        
            y = y1 - (math.floor(b/2) * 88 * inScale + math.floor((b - 1) / 2) * 23 * inScale + (a - 1) * 65 * inScale)
            x = x1 - (math.floor(b/2) * 47 * inScale + math.floor((b - 1) / 2) * 177 * inScale - (a - 1) * 129 * inScale)
            
            self._shapes[a .. "," .. b] = {}
            self._shapes[a .. "," .. b].pos = cc.p(x, y)
            self._shapes[a .. "," .. b].grid = gCallback(a, b)
        end
    end
end

function GuildMapModel:getShapes()
    return self._shapes
end


function GuildMapModel:getEvents()
    return self._events
end


--[[
--! @function setEnemyData
--! @desc 设置敌方数据提供给布阵临时存储数据
--！@param inData 怪兽数据
--! @return table
--]]
function GuildMapModel:setEnemyTeamData(inData)
    if next(self._enemyData) ~= nil then self._enemyData = {} end
    local tempData = {}
    for k,v in pairs(inData) do
        if v.id == nil then 
            v.id = k 
        end
        v.teamId = tonumber(v.id)
        tempData[tonumber(v.id)] = v
    end
    self._enemyData = tempData
end


function GuildMapModel:getEnemyDataById(inTeamId)
    return self._enemyData[tonumber(inTeamId)]
end


--[[
--! @function setEnemyData
--! @desc 设置敌方数据提供给布阵临时存储数据
--！@param inData 怪兽数据
--! @return table
--]]
function GuildMapModel:setEnemyHeroData(inData)
    if next(self._enemyHeroData) ~= nil then self._enemyHeroData = {} end
    self._enemyHeroData = inData
end


function GuildMapModel:getEnemyHeroData()
    return self._enemyHeroData
end

--[[
--! @function pushMapTask
--! @desc 推送任务数据[推送只是统计值，任务手动更新]
--！@param data 任务数据
--! @return 
--]]
function GuildMapModel:pushMapTask(data, taskId)   --wangyan
    if not data or next(data) == nil then
        return
    end
    -- dump(data, "pushMapTask")

    if taskId then  --自己做的任务记状态延时刷新
        self._data["markTask"] = taskId
    end

    local userData = self._modelMgr:getModel("UserModel"):getData()
    if data["mapTask"] then
        if data["rid"] and data["rid"] == userData._id then  --自己做的任务记状态延时刷新
            self._data["mapTask"] = data["mapTask"]
        end
        if self._data["mapTask"] == nil then 
            self._data["mapTask"] = {}
        end
        for k,v in pairs(data["mapTask"]) do
            self._data["mapTask"][k] = v
        end
    end

    if data["d"] and data["d"]["mapStatis"] then
        local statis = data["d"]["mapStatis"]
        if self._data["markTaskStatis"] == nil then
            self._data["markTaskStatis"] = {}
        end
        if data["rid"] and data["rid"] == userData._id then  --自己做的任务记状态延时刷新
            table.insert(self._data["markTaskStatis"], statis)
        end
        
        if userData["mapStatis"] == nil then 
            userData["mapStatis"] = {}
        end
        for k,v in pairs(statis) do
            userData["mapStatis"][k] = v
            if tonumber(k) == 6 then
                ModelManager:getInstance():getModel("ActivityModel"):pushUserEvent()
            elseif tonumber(k) == 5 or tonumber(k) == 10 then
                ModelManager:getInstance():getModel("ActivityCarnivalModel"):setNeedUpdate(true)
            end
        end
    end

    if data["rid"] and data["rid"] ~= userData._id then  --非自己主动做任务及时刷新
        self:reflashData("PushMapTask")
    end
end

function GuildMapModel:updateReportState(state)
    self._data.havetips = state
    self:reflashData("UpdateReport")
end

function GuildMapModel:getReportState()
    return self._data.havetips or 0
end

function GuildMapModel:updateRuleOpenState(inState)
    if self._isOpenRule == false and inState == true then  --平生只显示一次红点点过消失 除非换端
        SystemUtils.saveAccountLocalData("GUILD_MAP_RULEVIEW_OPEN_STATE", true)
        self._isOpenRule = inState
        self:reflashData("UpdateRuleOpen")
    end
end

function GuildMapModel:getRuleOpenState()
    return self._isOpenRule or false
end

function GuildMapModel:getTaskCompleteState(taskID)
    local taskType = tab.guildMapTask[taskID].condition
    local userData = self._modelMgr:getModel("UserModel"):getData()
    if userData["mapStatis"] == nil then
        userData["mapStatis"] = {}
    end
    return userData["mapStatis"][tostring(taskType)] or 0
end

--[[
--! @function getShowElementDataByGridKey
--! @desc 根据格子key获取当前展示元件信息，guild，common，my分别是展示优先级
--! @return 
--]]
function GuildMapModel:getShowElementDataByGridKey(inGridKey)
    if self._data.mapList == nil or self._data.mapList[inGridKey] == nil then 
        return nil
    end
    print("inGridKey============================", inGridKey)
    local thisEle
    local mapData = self._data.mapList[inGridKey]
    if mapData[GuildConst.ELEMENT_TYPE.GUILD] ~= nil then 
        thisEle = mapData[GuildConst.ELEMENT_TYPE.GUILD]
		if thisEle.eid==9001 then--秘境，有藏宝图时要返回藏宝图数据
			if mapData[GuildConst.ELEMENT_TYPE.MY]--有个人点数据
					and mapData[GuildConst.ELEMENT_TYPE.MY].tmKey~=nil--根据tmKey和tType字段判断是不是藏宝图
					and mapData[GuildConst.ELEMENT_TYPE.MY].tType~=nil then
				thisEle = mapData[GuildConst.ELEMENT_TYPE.MY]--返回藏宝图数据
			end
		end
    elseif mapData[GuildConst.ELEMENT_TYPE.COMMON] ~= nil then
        thisEle = mapData[GuildConst.ELEMENT_TYPE.COMMON]
    elseif mapData[GuildConst.ELEMENT_TYPE.MY] ~= nil then
        thisEle = mapData[GuildConst.ELEMENT_TYPE.MY]                            
    end
    return thisEle
end


--[[
--! @function lockPush
--! @desc 主要用于玩家异地战斗失败，数据非及时更新
         （战斗后请求更新）过程中的push数据不同步
--]]
function GuildMapModel:lockPush()
    self._lockPush = true
end

--[[
--! @function isLockPush
--! @desc 主要用于玩家异地战斗失败，数据非及时更新
         （战斗后请求更新）过程中的push数据不同步
--! @return bool 
--]]
function GuildMapModel:isLockPush()
    if self._data.mapList == nil then return true end
    return self._lockPush
end

function GuildMapModel:unLockPush()
    self._lockPush = false
end

--[[
--! @function logoutMap
--! @desc 退出地图
--]]
function GuildMapModel:logoutMap()
    self:reflashData("LogoutMap")
end

function GuildMapModel:logoutToMap(errorCode, famType)
	self._events["LogoutToMap"] = { errorCode = errorCode, famType = famType }
	self:reflashData("LogoutToMap")
end

function GuildMapModel:setTransferState(inState)
    self._isTransfering = inState
end

function GuildMapModel:getTransferState()
    return self._isTransfering or false
end

function GuildMapModel:releaceGuild()
    self._events["ReleaceGuild"] = 1
    self:reflashData("ReleaceGuild")
end

--主界面气泡
--1 联盟地图体力已满
function GuildMapModel:checkGuildMapRedpoint()
    local userData = self._modelMgr:getModel("UserModel"):getData()
    
    if userData.guildId and userData.guildId ~= 0 then
        local privilegeModel = self._modelMgr:getModel("PrivilegesModel")
        local powerUp = tab:Setting("G_INITIAL_GUILDPOWER_MAX").value or 0
        local powerBuff = privilegeModel:getPeerageEffect(PrivilegeUtils.peerage_ID.AlliancePowerMax)
        -- 新特权也加最大值 by guojun 2017.3.1
        local guildPowerBuff1 = privilegeModel:getPeerageEffect(PrivilegeUtils.peerage_ID.AlliancePower1)
        powerUp = powerUp + powerBuff + guildPowerBuff1

        if userData["guildPower"] and userData["guildPower"] >= powerUp then
            return true
        end
    end

    return false
end

-- 跑马灯
function GuildMapModel:insertNoticeData(data)
    if data == nil then 
        return 
    end

    if self._data["ges"] == nil then
        self._data["ges"] = {}
    end
    local showType = {5,6,7,8,9,10,12,13,14,15,16,17}
    for i,v in ipairs(showType) do
        if v == data.type then
            table.insert(self._data["ges"], data)
            self:reflashData("GlobalNotice")
            return
        end
    end
end

function GuildMapModel:getNoticeData()
    if self._data["ges"] == nil then
        self._data["ges"] = {}
    end
    
    local showList = self._data["ges"]
    if #showList <= 0 then
        self._infoChecked = true 
        return nil
    end

    --是否检查过数据
    -- dump(self._data["ges"], "789")
    if self._infoChecked ~= true then 
        local showType = {5,6,7,8,9,10,12,13,14,15,16,17}  
        if self._guangboT == nil then
            self._guangboT = SystemUtils.loadAccountLocalData("GUILD_MAP_GUANGBO_TIME") or 0 --本地状态
        end

        for i=#self._data["ges"], 1, -1 do
            local v = self._data["ges"][i]
            --time
            if v["eventTime"] and self._guangboT >= v["eventTime"] then
                table.remove(showList, i)
            end

            --type
            local isShow = false
            for p, q in ipairs(showType) do
                if q == v["type"] then
                    isShow = true
                end
            end
            if isShow == false then
                table.remove(showList, i)
            end
        end
        self._infoChecked = true
    end

    if #showList <= 0 then
        return nil
    end

    -- dump(self._data["ges"], "123")       
    local tempData = showList[1]
    table.remove(showList, 1)
    -- dump(self._data["ges"], "456")
    self._guangboT = tempData["eventTime"]
    if not OS_IS_WINDOWS then
        SystemUtils.saveAccountLocalData("GUILD_MAP_GUANGBO_TIME", tempData["eventTime"])
    end
    
    return tempData
end

function GuildMapModel:getNoticeLastTime()
    return self._guangboT or 0
end

function GuildMapModel:sortTaskByOrder()
    local guildTask = self._data["mapTask"]
    if not guildTask or next(guildTask) == nil then
        return guildTask
    end

    local replace1 = {}
    local replace2 = {}
    for k,v in pairs(guildTask) do
        table.insert(replace1, {id = tonumber(k), info = v})
    end

    local sysGuildTask = tab.guildMapTask
    table.sort(replace1, function(a, b)
        local order1 = sysGuildTask[a["id"]]["order"]
        local order2 = sysGuildTask[b["id"]]["order"]
        return order1 < order2
        end)

    return replace1
end

--[[
--! @desc 先知小屋任务相关
--]]
function GuildMapModel:getTaskStateById(inType)
    local taskState = 0   --0无任务 1有任务未达成 2任务达成
    if not taskState then
        return 0
    end
    if self._data["mapTask"][tostring(inType)] == nil then
        taskState = 0
    elseif self._data["mapTask"][tostring(inType)] ~= 0 then
        taskState = 2
    else
        taskState = 1
    end

    return taskState
end

function GuildMapModel:getTaskStateByStatis(inType)
    local taskState = 0   --0无任务 1有任务未达成 2任务达成
    for i,v in pairs(self._data["mapTask"]) do
        local taskType = tab.guildMapTask[tonumber(i)]["condition"]
        if tonumber(taskType) == tonumber(inType) then
            if v ~= 0  then
                taskState = 2
            else
                taskState = 1
            end
            break
        end
    end

    return taskState
end

function GuildMapModel:getPassGuildName(guildId)
    local goGuildId = guildId and tostring(guildId) or tostring(self._data["speGid"])
    if goGuildId and self._data["guildList"][goGuildId] and self._data["guildList"][goGuildId]["name"] then
        return self._data["guildList"][goGuildId]["name"]
    end

    return ""
end

function GuildMapModel:getTaskIdByStatis(inType)
    local spTaskData = self._data["spTaskData"]
    if spTaskData == nil or next(spTaskData) == nil then
        return
    end

    local buildId
    local sysGuildMapThing = tab.guildMapThing
    dump(spTaskData, "spTaskData")
    if inType == GuildConst.TASK_TYPE.GUILD_MAP_ST_FIND_XUEZHE then  --寻找小精灵
        buildId = spTaskData["sp1"]["id"]
    elseif inType == GuildConst.TASK_TYPE.GUILD_MAP_ST_FIND_BOX then  --寻找宝箱
        buildId = spTaskData["sp2"]["id"]
    end

    if not buildId or not sysGuildMapThing[buildId] then
        return
    end

    local taskId = sysGuildMapThing[buildId]["task"]
    return taskId
end

function GuildMapModel:getMapItemAndTypeNameByGridKey(inGridKey)
    local mapList = self:getData().mapList
    local mapInfo = mapList[inGridKey]
    if mapInfo == nil  then return nil, nil end
    local mapItem
    local typeName
    if mapInfo.guild ~= nil then 
        mapItem = mapInfo.guild
        typeName = GuildConst.ELEMENT_TYPE.GUILD
    elseif mapInfo.common ~= nil then 
        mapItem = mapInfo.common
        typeName = GuildConst.ELEMENT_TYPE.COMMON
    elseif mapInfo.my ~= nil then
        mapItem = mapInfo.my
        typeName = GuildConst.ELEMENT_TYPE.MY
    end
    return mapItem, typeName
end


--[[
--! @desc 联盟标记相关
--]]
function GuildMapModel:getMarkingState()
    -- if true then
    --     return true
    -- end
    local mapMark = self._data["mapMark"]
    if mapMark and next(mapMark) ~= nil then
        return true
    end

    return false
end

function GuildMapModel:addTagsData(inData)
    if inData["mapMark"] == nil then
        return
    end
    self._data["mapMark"] = inData["mapMark"]
end

function GuildMapModel:removeTagsData()
    self._data["mapMark"] = {}
end

function GuildMapModel:pushMapMark(inData)
    if not inData or next(inData) == nil then
        return
    end

    self:addTagsData(inData)
    self:reflashData("PushMapMark")
end


--[[
--! @desc 斯芬克斯谜题
--]]
--获取斯芬克斯答题 当天开启时间/截止时间
function GuildMapModel:getAQAcTime()
    local mapId = self._data["version"]
    if mapId == nil then
        return
    end

    local sysMapSetting = tab:GuildMapSetting(mapId)
    if sysMapSetting == nil or sysMapSetting.sphinx == nil then
        return
    end

    local currentTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local operateDate = TimeUtils.date("*t", currentTime)
    local curWakeDay = operateDate.wday
    if curWakeDay == 1 then 
        curWakeDay = 7
    else
        curWakeDay = operateDate.wday - 1
    end

    local acTime = {}
    local isOpen
    for i,v in ipairs(sysMapSetting.sphinx) do
        local test = "%Y-%m-%d ".. string.format("%02d:%02d:%02d", v[2], v[3], v[4])
        local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(currentTime + (v[1] - curWakeDay) * 86400,test))
        acTime[i] = tempCurDayTime
    end

    return acTime
end

function GuildMapModel:updateSphinxData(inData)
    if inData == nil then
        return
    end

    if self._data["sphinx"] == nil then
        self._data["sphinx"] = {}
    end

    for k,v in pairs(inData) do
        self._data["sphinx"][k] = v
    end
end

function GuildMapModel:setAQRankData(inData, inType)
    self._data["sphinxRank"][tonumber(inType)] = inData
end

function GuildMapModel:getAQRankData(inType)
    return self._data["sphinxRank"][tonumber(inType)] or {}
end

function GuildMapModel:clearAQRankData()
    self._data["sphinxRank"] = {{}, {}}
end

--秘境
function GuildMapModel:noticePlayerFam(famData)
	self:reflashData("FindFam")
end

function GuildMapModel:noticeScreenToFam(gridKey)
	self._events["ToInviteFamGrid"] = gridKey
	self:reflashData("ToInviteFamGrid")
end

function GuildMapModel:getFamGridKeyByRoleId(id)
	for i,v in pairs(self._data.mapList) do
		if v.guild and v.guild.eid==9001 and v.guild.stid==id then
			local lifeTime = tab.famAppear[v.guild.stype].time
			local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
			if curTime < v.guild.stime+lifeTime then
				return i
			end
		end
	end
	return nil
end

function GuildMapModel:setYearBuffData(yearBuff)
	for i,v in pairs(yearBuff) do
		self._yearBuff[i] = v
	end
	self:reflashData("UpdateYearBuff")
end

function GuildMapModel:resetYearBuffDataById(buffId, buffData)
	if not buffId then
		return
	end
	self._yearBuff[buffId] = buffData
	self:reflashData("UpdateYearBuff")
end

function GuildMapModel:getYearBuffData(buffId)
	if buffId then
		return self._yearBuff[buffId]
	end
	return self._yearBuff
end

function GuildMapModel:setOfficerTargetGuildId(guildId)
	self._data.jxGid = guildId
	self:reflashData("UpdateOfficerState")
end

function GuildMapModel:getOfficerTargetGuildId()
	return self._data.jxGid
end

function GuildMapModel:setCommanderData(jxRewardSt)
	if jxRewardSt then
		self._data.jxRewardSt = jxRewardSt
	end
	self:reflashData("UpdateOfficerState")
end

function GuildMapModel:getCommanderData()
	return self._data.jxRewardSt
end

function GuildMapModel:getCommanderAcTime()
	if self._data.jxRewardSt and self._data.jxRewardSt.actime then
		return self._data.jxRewardSt.actime
	end
end

--藏宝图
function GuildMapModel:clearTreasureState()--清空藏宝图数据（已寻宝或放弃操作）
	self._data.tMap = nil
	self:reflashData("UpdateTreasure")
end

function GuildMapModel:getTreasureData()
	return self._data.tMap
end

function GuildMapModel:setTreasureData(data)
	if data then
		self._data.tMap = data
		self:reflashData("UpdateTreasure")
	end
end

function GuildMapModel:getTreasureState()--获取当前是否有正在寻宝的藏宝图
	return self._data.tMap~=nil
end

function GuildMapModel:setTreasureReward(reward)
	if reward and table.nums(reward)>0 then
		self._treasureReward = reward
	end
end

function GuildMapModel:getTreasureReward()
	return self._treasureReward
end

function GuildMapModel:clearTreasureReward()
	self._treasureReward = nil
end

function GuildMapModel:clear()
    self._data = {}
    self._data.upTime = 0
    self._data.mapid = 0
    self._data.isRelashMap = false
    self._shapes = {}
    self._events = {}
	
	self._yearBuff = {}

    self._lockPush  = false

end

return GuildMapModel
