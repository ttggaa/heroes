--
-- Author: <ligen@playcrab.com>
-- Date: 2017-01-23 22:41:31
--
local HeroDuelServer = class("HeroDuelServer", BaseServer)

function HeroDuelServer:ctor()
    HeroDuelServer.super.ctor(self)
    self._hModel = self._modelMgr:getModel("HeroDuelModel")
    self._formationModel = self._modelMgr:getModel("FormationModel")

    self._userModel = self._modelMgr:getModel("UserModel")
end

function HeroDuelServer:onHDuelGetBaseInfo(result, error)
    if error ~= 0 then 
		return
	end
    self._hModel:setWeekNum(result.configId)
    self._hModel:setHadEnterHDuel(result.notEntered)
    self._hModel:setMaxWins(result.winMax)
	self:callback(result)
end

-- 获取主界面信息
function HeroDuelServer:onHDuelGetMainInfo(result, error)
	if error ~= 0 then 
		return
	end

--    dump(result["d"]["items"])

    if result["d"] and result["d"]["items"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"])
        result["d"]["items"] = nil
    end

    if result["d"] and result["d"]["formations"] then
        self._modelMgr:getModel("FormationModel"):updateAllFormationData(result["d"]["formations"])
        result["d"]["formations"] = nil
    end

    self._hModel:setCardsInfo(result.selected)
    self._hModel:setWeekNum(result.configId)

    -- 保存胜负场信息
    local hdData = {}
    hdData["status"] = result["status"]
    hdData["wins"] = result["wins"] or 0
    hdData["seasonWins"] = result["seasonWins"] or 0
    hdData["loses"] = result["loses"] or 0
    self._hModel:setHeroDuelData(hdData)

	self:callback(result)
end

-- 入场
function HeroDuelServer:onHDuelSignUp(result, error)
	if error ~= 0 then 
		return
	end

    if result["d"] and result["d"]["items"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"])
        result["d"]["items"] = nil
    end

    if result["unset"] then
		local itemModel = self._modelMgr:getModel("ItemModel")
		local removeItems = itemModel:handelUnsetItems(result["unset"])
        itemModel:delItems(removeItems, true)
	end

    -- 更新用户数据
    self._userModel:updateUserData(result["d"])

	self:callback(result)
end

-- 获取选卡界面信息
function HeroDuelServer:onHDuelGetSelectInfo(result, error)
	if error ~= 0 then 
		return
	end

	self:callback(result)
end

-- 选择卡牌
function HeroDuelServer:onHDuelSelectCards(result, error)
	if error ~= 0 then 
		return
	end

	self:callback(result)
end

-- 开始匹配
function HeroDuelServer:onHDuelMatchRival(result, error)
	if error ~= 0 then 
		return
	end
    dump(result)

    if result ~= nil and result.win ~= nil then
        local hdData = {}
        if result.win == 1 then
            hdData["wins"] = result["d"].heroDuel.wins
            hdData["seasonWins"] = result["d"].heroDuel.seasonWins
            self._hModel:updateHeroDuelData(hdData)
        else
            hdData["loses"] = result["d"].heroDuel.loses
            self._hModel:updateHeroDuelData(hdData)
        end
    end

    self._hModel:sethDuelState(self._hModel.IN_MATCH)
	self:callback(result)
end

-- 推送匹配成功消息
function HeroDuelServer:onHDuelMatchComplete(result, error)
	if error ~= 0 then 
		return
	end

    dump(result)
    if not self._hModel:getIsCorrectState(self._hModel.IN_MATCH) then
        print("拒绝接受匹配成功")
        return
    end

    if result.banMT ~= nil then
        self._hModel:setMatchError(result.banMT)
        return
    end

    self:_loginRoom(result)
	self:callback(result)
end

-- 进入房间
function HeroDuelServer:_loginRoom(data)
    data.rid = self._userModel:getRID()
--    data.platform = GameStatic.userSimpleChannel
    ServerManager:getInstance():RS_initSocket(data,
    function (errorCode)
        if errorCode ~= 0 then return end
        -- 连接成功回调
        print("rs init success")
        self._hModel:onListenRSResponse()
        self._hModel:sethDuelState(self._hModel.IN_ROOM)
    end)
end 

-- 取消匹配
function HeroDuelServer:onHDuelCancelMatch(result, error)
	if error ~= 0 then 
		return
	end

    if result.status ~= -1 then
        self._hModel:resethDuelState()
        ServerManager:getInstance():RS_clear()
    end
	self:callback(result)
end

function HeroDuelServer:onHDuelFightAfter(result, error)
    if error ~= 0 then 
        return
    end

    -- 更新用户数据
    self._userModel:updateUserData(result["d"])
    self:callback(result)
end


-- 获取数据统计结果
function HeroDuelServer:onHDuelGetStatis(result, error)
	if error ~= 0 then 
		return
	end

	self:callback(result)
end

-- 获取精彩对局
function HeroDuelServer:onHDuelGetSeasonShow(result, error)
	if error ~= 0 then 
		return
	end

	self:callback(result)
end

-- 获取累计胜场奖励数据
function HeroDuelServer:onHDuelGetAwardList(result, error)
	if error ~= 0 then 
		return
	end

	self:callback(result)
end

-- 领取赛季奖励
function HeroDuelServer:onHDuelGetSeasonAward(result, error)
	if error ~= 0 then 
		return
	end

    if result["d"]["items"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"])
    end

    -- 更新用户数据
    self._userModel:updateUserData(result["d"])

	self:callback(result)
end

-- 领取奖励
function HeroDuelServer:onHDuelGetSingleAward(result, error)
	if error ~= 0 then 
		return
	end

    if result["d"]["items"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"])
    end

    -- 更新用户数据
    self._userModel:updateUserData(result["d"])

    -- 重置本场数据
    self._hModel:resetHeroDuelData()

	self:callback(result)
end

-- 获取战报
function HeroDuelServer:onHDuelGetReport(result, error)
	if error ~= 0 then 
		return
	end
	self:callback(result)
end

--[[
-- 布阵相关
function HeroDuelServer:onHDuelSetFormReady(result, error)
    print("HeroDuelServer:onHDuelSetFormReady", error)
    dump(result, "result", 5)
    self:callback(0 == tonumber(error), result)
end

function HeroDuelServer:onHDuelSetFormation(result, error)
    print("HeroDuelServer:onHDuelSetFormation", error)
    dump(result, "result", 5)
    self:callback(0 == tonumber(error), result)
end

function HeroDuelServer:onHDuelFormReq(result, error)
    print("HeroDuelServer:onHDuelFormReq", error)
    dump(result, "result", 5)
    self:callback(0 == tonumber(error), result)
end

function HeroDuelServer:onPushHeroDuelEvent(result, error)
    print("HeroDuelServer:onPushHeroDuelEvent", error)
    print("pushHeroDuelEvent时间戳" .. self._modelMgr:getModel("UserModel"):getCurServerTime())
    dump(result, "result", 5)
    self._formationModel:onPushHeroDuelEvent(0 == tonumber(error), result)
end
-- 布阵相关
]]
return HeroDuelServer
