--
-- Author: <ligen@playcrab.com>
-- Date: 2017-01-23 22:41:13
--
local heroDuejxTab = tab.heroDuejx
local tonumber = tonumber

local HeroDuelModel = class("HeroDuelModel", BaseModel)

-- 事件名
HeroDuelModel.HD_DATA_UPDATE = "HD_DATA_UPDATE"
HeroDuelModel.CARDS_UPDATE = "CARDS_UPDATE"
HeroDuelModel.ROOM_UPDATE = "ROOM_UPDATE"
HeroDuelModel.FORMATION = "FORMATION"
HeroDuelModel.BATTLE_END_EVENT = "BATTLE_END_EVENT"
HeroDuelModel.HD_DATA_RESET = "HD_DATA_RESET"
HeroDuelModel.HD_OPEN = "HD_OPEN"
HeroDuelModel.HD_CLOSE = "HD_CLOSE"
HeroDuelModel.LOGIN_SERVER_ERROR = "LOGIN_SERVER_ERROR"
HeroDuelModel.MATCH_ERROR = "MATCH_ERROR"

-- 事件名


-- 阶段状态码
HeroDuelModel.IN_MATCH = 1;         --匹配中
HeroDuelModel.IN_ROOM = 2;          --全登陆
HeroDuelModel.TEAM_BAN_READY = 3;   --ban卡准备阶段
HeroDuelModel.TEAM_BAN = 4;         --ban卡阶段
HeroDuelModel.TEAM_SELECT_READY = 5; --兵团布阵准备阶段
HeroDuelModel.TEAM_SELECT = 6;      --布阵兵团阶段
HeroDuelModel.HERO_SELECT = 7;      --英雄选择阶段
HeroDuelModel.BATTLE_BEFORE = 8;    --战前阶段
HeroDuelModel.BATTLE_END = 9;       --战斗结束阶段
-- 阶段状态码

-- 退出原因
HeroDuelModel.EXIT_NORMAL = 1; --正常退出
HeroDuelModel.EXIT_ERROR1 = 2; --托管三次异常退出
HeroDuelModel.EXIT_ERROR2 = 3; --托管战斗退出
HeroDuelModel.EXIT_ERROR3 = 4; --房间已销毁
-- 退出原因

function HeroDuelModel:ctor()
    HeroDuelModel.super.ctor(self) 

    -- 已选择卡牌数据
    self._selectedData = nil

    -- 匹配数据
    self._roomData = nil

    -- 办卡数据
    self._banCardsData = nil

    -- 赛季周数
    self._week = 1

    -- 交锋相关数据 
    self._heroDuelData = {}

    self._timerOpen = false

    self:listenRSResponse(specialize(self.onSocektResponse, self))
    self:listenGlobalResponse(specialize(self.onCarry, self))
end

--[[
--! @desc 保存交锋相关数据
--! @param data 
           status 0 未报名  1 卡组未完成  2 可匹配  3 可领奖
	 	   wins 本场胜利次数
           loses 本场失败次数
           seasonWins 本季胜利次数
--]]
function HeroDuelModel:setHeroDuelData(data)
    if type(data) ~= "table" then
        dump("此处需传入table")
        return
    end

    for k, v in pairs(data) do
        self._heroDuelData[k] = v
    end

    -- 首次进入该功能，开始定时刷新功能开启和关闭
    if not self._timerOpen then
        local duelTime = tab:Setting("DUEL_TIME").value
        for i = 1, #duelTime do
            self:registerTimer(duelTime[i][1], 0, 0, specialize(self.setHDuelOpen, self))
            self:registerTimer(duelTime[i][2], 0, 0, specialize(self.setHDuelClose, self))
        end
        self._timerOpen = true
    end
end

--[[
--! @desc 更新交锋相关数据
--! @param data 
           status 0 未报名  1 卡组未完成  2 可匹配  3 可领奖
	 	   wins 本场胜利次数
           loses 本场失败次数
           seasonWins 本季胜利次数
--]]
function HeroDuelModel:updateHeroDuelData(data)
    if type(data) ~= "table" then
        dump("此处需传入table")
        return
    end

    for k, v in pairs(data) do
        self._heroDuelData[k] = v
    end

    if self._heroDuelData["wins"] == 12 or self._heroDuelData["loses"] == 3 then
        self._heroDuelData["status"] = 3
    end

    if self._heroDuelData["wins"] > self:getMaxWins() then
        self:setMaxWins(self._heroDuelData["wins"])
    end

    self:reflashData(HeroDuelModel.HD_DATA_UPDATE)
end

-- 获取交锋相关数据
-- @param dataKey 对应数据的key，不传则全部返回
function HeroDuelModel:getHeroDuelData(dataKey)
    if dataKey ~= nil then
        return self._heroDuelData[dataKey]
    else
        return self._heroDuelData
    end
end

-- 历史最高胜场
function HeroDuelModel:setMaxWins(winNum)
    self._maxWins = winNum
end

function HeroDuelModel:getMaxWins()
    return self._maxWins or 0
end

-- 保存开赛期数
function HeroDuelModel:setWeekNum(wNum)
    self._week = wNum
    self._hasBaseInfo = true
end

-- 获取开赛期数
function HeroDuelModel:getWeekNum()
    return self._week or 1
end

-- 判断是否为觉醒兵团
function HeroDuelModel:isTeamJx(teamId)
    for k, v in pairs(heroDuejxTab) do
        if tonumber(k) == tonumber(teamId) then
            return true
        end
    end
    return false
end

-- 保存选卡信息
function HeroDuelModel:setCardsInfo(cListInfo)
    self._selectedData = cListInfo or {}
    self:reflashData(HeroDuelModel.CARDS_UPDATE)
end

-- 增加选卡信息
function HeroDuelModel:addCardsInfo(cardInfo)
    if type(cardInfo) ~= "table" then
        if self._selectedData.heros == nil then
            self._selectedData.heros = {}
        end
        table.insert(self._selectedData.heros, cardInfo)
    else
        if self._selectedData.teams == nil then
            self._selectedData.teams = {}
        end
        table.insert(self._selectedData.teams, cardInfo)
    end
    self:reflashData(HeroDuelModel.CARDS_UPDATE)
end

-- 获取选卡信息
function HeroDuelModel:getCardsInfo()
    return self._selectedData
end

-- 根据兵种标签获取数量
function HeroDuelModel:getNumByClass(class)
    local count = 0
    local teams = self._selectedData.teams
    if teams ~= nil then
        for i = 1, #teams do
            if tab:Team(teams[i].id).class == class then
                count = count + 1
            end
        end
    end
    return count
end

-- 根据兵种规格获取数量
function HeroDuelModel:getNumByVolume(volume)
    local count = 0
    local teams = self._selectedData.teams
    if teams ~= nil then
        for i = 1, #teams do
            if tab:Team(teams[i].id).volume == volume then
                count = count + 1
            end
        end
    end
    return count
end

-- 获取被禁用卡牌
function HeroDuelModel:getForbiddenedCards(FBDdata)
    local FBDlist = {}
    if type(FBDdata) == "table" then
        for i = 1, #FBDdata do
            for _, v in pairs(self._selectedData.teams) do
                if v.id == FBDdata[i] then
                    table.insert(FBDlist, v)
                end
            end
        end
    else
        dump("禁用数据格式有误")
    end
    return FBDlist
end


-- 根据ID判断是英雄ID或者兵团ID
function HeroDuelModel:isHeroOrTeam(id)
    if string.len(tostring(id)) == 5 then
        return "HERO"
    else
        return "TEAM"
    end
end

-- 保存匹配数据
-- @mInfo 匹配数据及办选数据
function HeroDuelModel:setRoomData(mInfo)
    self._roomData = self:_formatRoomData(mInfo)

    self:setFightOrder(mInfo.common.firstRid)
--    self:reflashData(HeroDuelModel.ROOM_UPDATE)
end

-- 更新房间数据
function HeroDuelModel:updateRoomData(mInfo)
    local mergeFun
    mergeFun = function(oldTab, newTab)
        for k, v in pairs(newTab) do
            if type(v) == "table" then
                if oldTab[k] == nil then
                    oldTab[k] = v
                else
                    mergeFun(oldTab[k], v)
                end
            else
                oldTab[k] = v
            end
        end
    end

    local clientMinfo = self:_formatRoomData(mInfo)
    mergeFun(self._roomData, clientMinfo)
--    self:reflashData(HeroDuelModel.ROOM_UPDATE)
end

-- 获取匹配数据
function HeroDuelModel:getRoomData()
    return self._roomData
end

-- 格式化服务端房间数据
function HeroDuelModel:_formatRoomData(serverInfo)
    local clientInfo = {}
    local myRid = self._modelMgr:getModel("UserModel"):getRID()
    for k, v in pairs(serverInfo) do
        if type(k) == "string" and tonumber(string.sub(k, 1, 1)) ~= nil then
            if myRid == k then
                clientInfo["self"] = v
            else
                clientInfo["rival"] = v
            end
        end
    end

    clientInfo["self"].banOp = {}
    clientInfo["rival"].banOp = {}

    if serverInfo.common.operator == myRid then
        clientInfo["self"].banOp.turn = 1
        clientInfo["rival"].banOp.turn = 0
    else
        clientInfo["self"].banOp.turn = 0
        clientInfo["rival"].banOp.turn = 1
    end

    -- BAN卡结束，准备布阵
    if serverInfo.common.status == HeroDuelModel.TEAM_SELECT_READY then
        clientInfo["self"].banOp.turn = 2
    end

--    clientInfo["self"].banned = {}
--    clientInfo["rival"].banned = {}
    clientInfo["common"] = serverInfo.common
    return clientInfo or {}
end

-- 格式化服务端房间数据
function HeroDuelModel:_formatFormaRoomData(serverInfo)
    local rid = self._modelMgr:getModel("UserModel"):getRID()
    local myTurn = tostring(serverInfo["common"]["operator"]) == tostring(rid)
    local myData = serverInfo[tostring(rid)] or {}
    local commonData = serverInfo["common"] or {}
    local data = {
        self = {
            formOp = commonData["stepInfo"] or {},
            form = myData["form"] or {},
            formC = myData["formC"] or {},
        }
    }

    if myTurn then
        data.self.formOp.ptime = data.self.formOp.ptime
        data.self.formOp.time = data.self.formOp.ptime
    else
        data.self.formOp.ptime = data.self.formOp.ptime
        data.self.formOp.time = data.self.formOp.time
    end

    data.self.formOp.step = commonData.step

    local turn = 1000
    local status = commonData["status"]
    local concurrent = commonData["concurrent"]
    local setHero = myData["form"].heroId and 0 ~= myData["form"].heroId

    if status == HeroDuelModel.TEAM_SELECT then
        if myTurn then
            turn = 1001
        else
            turn = 1002
        end
    elseif status == HeroDuelModel.HERO_SELECT then
        if setHero then
            turn = 1009
        else
            turn = 1003
        end
        --[[
        if 2 == concurrent then
            turn = 1003
        end
        ]]
    else
        turn = 1004
    end

    data.self.formOp.turn = turn

    data.self.formOp.num = data.self.formOp.num or 0
    data.self.formOp.time = data.self.formOp.time or 0
    data.self.formOp.ptime = data.self.formOp.ptime or 0
    data.self.formOp.lot = data.self.formOp.lot or 0

    return data
end

function HeroDuelModel:setFormaRoomData(data)
    self._formaRoomData = self:_formatFormaRoomData(data)
--    self:reflashData()
end

function HeroDuelModel:getFormaRoomData()
    local data = self._formaRoomData
    self._formaRoomData = {}
    return data
end

-- 保存战斗数据
function HeroDuelModel:setBattleBefore(data)
    self._battleBefore = data
end

-- 获取战斗数据
function HeroDuelModel:getBattleBefore()
    return self._battleBefore
end

-- 保存先后手顺序
-- @offensiveState 办选先后手顺序
function HeroDuelModel:setFightOrder(offensiveRID)
    self._offensiveState = offensiveRID == self._modelMgr:getModel("UserModel"):getRID()
end

-- 判断是否为战斗攻击方
function HeroDuelModel:isOffensiveOrder()
    return self._offensiveState
end

-- 重置本场数据信息
function HeroDuelModel:resetHeroDuelData()
    self._selectedData = {}
    self._roomData = nil
    self._banCardsData = nil
    self._heroDuelData = {}
    self:reflashData(HeroDuelModel.HD_DATA_RESET)
end

-- 保存英雄交锋进程状态
function HeroDuelModel:sethDuelState(status, step)
    self._hDuelStatus = status
    self._hDuelStep = step
end

-- 获取进程状态
function HeroDuelModel:gethDuelState()
    return self._hDuelStatus, self._hDuelStep
end

-- 清空英雄交锋进程状态
function HeroDuelModel:resethDuelState()
    self._hDuelStatus = nil
    self._hDuelStep = nil
end

-- 判断是否在接受对应推送状态
function HeroDuelModel:getIsCorrectState(status)
    return self._hDuelStatus == status
end

-- 功能开启
function HeroDuelModel:setHDuelOpen()
    self:reflashData(HeroDuelModel.HD_OPEN)
end

-- 功能关闭
function HeroDuelModel:setHDuelClose()
    self:reflashData(HeroDuelModel.HD_CLOSE)
end

-- 功能能是否开放
function HeroDuelModel:getHDuelIsOpen()
    local isOpen = tab:Setting("DUEL_ON").value
    return isOpen and (isOpen == 1)
end

-- 记录已进入过英雄交锋
function HeroDuelModel:setHadEnterHDuel(notEntered)
    self._hadEnter = notEntered ~= 1
end

-- 是否进入过英雄交锋
function HeroDuelModel:isFirstEnterHDuel()
    return not self._hadEnter
end

-- 是否请求过基础信息
function HeroDuelModel:hasBaseInfo()
    return self._hasBaseInfo == true
end

--[[ 保存导致胜负异常类型
-- @param data table 异常数据
--        tp 异常类型
--        isWin 胜负 1:胜 0:负
--]]
function HeroDuelModel:saveErrorType(data)
    if data.tp ~= nil then
        self._errorTp = data.tp
    elseif data.isWin ~= nil then
        if self._errorTp  == HeroDuelModel.EXIT_ERROR1 or self._errorTp  == HeroDuelModel.EXIT_ERROR3  then
            if data.isWin == 1 then
                self._errorTipTp = 2

            elseif data.isWin == 0 then
                self._errorTipTp = 1
            end
        end
    end
end

-- 获取异常类型
function HeroDuelModel:getErrorType()
    local tp = self._errorTipTp
    self._errorTp = nil
    self._errorTipTp = nil
    return tp
end

--[[ 保存匹配异常
-- @param time 发生异常，匹配等待时间
--
--]]
function HeroDuelModel:setMatchError(time)
    self._matchErrorWaitTime = time
    self:reflashData(HeroDuelModel.MATCH_ERROR)
end

-- 获取匹配异常
function HeroDuelModel:getMatchError()
    return self._matchErrorWaitTime
end

-- 根据胜场数获取对应盾牌类型
function HeroDuelModel:getAniTypeByWins(wins)
    local animType = {
        [1] = {name = "shitoudun_gezhongdun", mcX = 10, mcY = -10, fontX = 0, fontY = 0, scale = 0.9},
        [2] = {name = "tongdun_gezhongdun", mcX = 10, mcY = -20, fontX = -1, fontY = 0, scale = 0.8},
        [3] = {name = "yindun_gezhongdun", mcX = 10, mcY = -20, fontX = 0, fontY = -6, scale = 0.8},
        [4] = {name = "jindun_gezhongdun", mcX = -31, mcY = 0, fontX = -41, fontY = 0, scale = 0.7}
    }

    if wins >= 9 then
        return animType[4]
    elseif wins >= 5 then
        return animType[3]      
    elseif wins >= 1 then
        return animType[2]
    else
        return animType[1]
    end
end

-- 返回carry数据
function HeroDuelModel:onCarry(data)
    if data == nil or data._carry_ == nil then return end
--    print("==================================")
--    dump(data._carry_)
--    print("==================================")

    if data._carry_.heroDuelReissue then
        self:onReissue(data._carry_.heroDuelReissue)
    end
end

-- 补发推送失败的消息 push-carry 
function HeroDuelModel:onReissue(data)
    if data.hDuelMatchComplete then
        if not self:getIsCorrectState(HeroDuelModel.IN_MATCH) then
            print("拒绝接受匹配成功 push-carry")
            return
        end

        self._loginRoom(data.hDuelMatchComplete)
    end
end

-- 进入房间
function HeroDuelModel:_loginRoom(data)
    data.rid = self._modelMgr:getModel("UserModel"):getRID()
--    data.platform = GameStatic.userSimpleChannel
    ServerManager:getInstance():RS_initSocket(data,
    function ()
        -- 连接成功回调
        print("rs init success")
        self:onListenRSResponse()
    end)
end


-- 开始监听java服务器
function HeroDuelModel:onListenRSResponse()
    self:listenRSResponse(specialize(self.onSocektResponse, self))
end

-- java服务器的response或者push接受
function HeroDuelModel:onSocektResponse(data)
    dump(data, "onSocektResponse", 7)
    if data.error ~= nil then
        self:onSocektError(data.error.code)
        return
    end

    if data.result and data.result["common"] then
        local status = data.result["common"].status
        local step = data.result["common"].step

        local curStatus, curStep = self:gethDuelState()
        if curStatus == nil or status > curStatus or (status == curStatus and (step == nil or step >= curStep)) then
            self:sethDuelState(status, step)

            local result = data.result
            if status == HeroDuelModel.TEAM_BAN_READY then
                self:setRoomData(result)
            elseif status == HeroDuelModel.TEAM_BAN then
                self:updateRoomData(result)

            elseif status == HeroDuelModel.TEAM_SELECT_READY then
                self:updateRoomData(result)

            elseif status == HeroDuelModel.TEAM_SELECT then
                self:setFormaRoomData(result)
            elseif status == HeroDuelModel.HERO_SELECT then
                self:setFormaRoomData(result)
            elseif status == HeroDuelModel.BATTLE_BEFORE then
                self:setFormaRoomData(result)
                self:setBattleBefore(result.battleInfo)
            elseif status == HeroDuelModel.BATTLE_END then

                -- 保存退出异常原因
                self:saveErrorType({tp = result["common"].quit})

                if result["common"].quit == HeroDuelModel.EXIT_ERROR3 then
                    ServerManager:getInstance():RS_clear()
                end
            end

            if not self._responseLock then
                self._responseLock = true
                ScheduleMgr:nextFrameCall(self, function()
                    if self:gethDuelState() then
                        if self:gethDuelState() >= HeroDuelModel.BATTLE_END then
                            print("###########################HeroDuelModel.BATTLE_END")
                            self:reflashData(HeroDuelModel.BATTLE_END_EVENT)

                        elseif self:gethDuelState() >= HeroDuelModel.TEAM_SELECT then
                            print("###########################HeroDuelModel.FORMATION")
                            self:reflashData(HeroDuelModel.FORMATION)

                        elseif self:gethDuelState() >= HeroDuelModel.TEAM_BAN_READY then

                            print("###########################HeroDuelModel.ROOM_UPDATE")
                            self:reflashData(HeroDuelModel.ROOM_UPDATE)
                        end
                    end
                    self._responseLock = false
                end)
            end
        end
    end
end

HeroDuelModel.SERVER_ERROR_1 = 112 -- 无效的token
HeroDuelModel.SERVER_ERROR_2 = 100 -- 参数错误
HeroDuelModel.SERVER_ERROR_3 = 70006 -- 房间加入失败

function HeroDuelModel:onSocektError(errorId)
    -- 放弃重连
    if errorId == 111111 then
        self._viewMgr:returnMain()

    -- 服务器错误
    elseif errorId == HeroDuelModel.SERVER_ERROR_1 
        or errorId == HeroDuelModel.SERVER_ERROR_2
        or errorId == HeroDuelModel.SERVER_ERROR_3
    then
        self:resethDuelState()
        self:reflashData(HeroDuelModel.LOGIN_SERVER_ERROR)
    else
        self:resethDuelState()
        self:reflashData(HeroDuelModel.LOGIN_SERVER_ERROR)
    end
end

function HeroDuelModel:dtor()

    heroDuejxTab = nil
    tonumber = nil
end
return HeroDuelModel