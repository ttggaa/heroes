--[[
    FileName:       GloryArenaView
    Author:         <dongcheng@playcrab.com>
    Datetime:       2018-08-10 10:15:38
    Description:    荣耀竞技场协议
]]  

--1108    超出挑战范围，不可挑战该对手！
--1103    对手排位已变更，请重新打开页面
--9501    荣耀之证不足,无法兑换
--9502    挑战次数小于最低领取次数,无法领取
--9503    该奖励不属于当前赛季，无法领取
--9504    无法扫荡比你排名比你高的玩家
--9505    超过允许的最大隐藏数量
--9506    非法的编组id
--9507    出现重复的编组id
--9508    你当前正在被其他玩家挑战
--9509    该玩家当前正在被其他玩家挑战
--9510    英雄或者兵团数量不能小于3个

--每个请求
--9611   您还没有初始化荣耀竞技场数据
--9612   新赛季荣耀竞技场还未开启


local CrossArenaServer = class("CrossArenaServer", BaseServer)

function CrossArenaServer:ctor()
    CrossArenaServer.super.ctor(self)
    self._gloryArenaModel = self._modelMgr:getModel("GloryArenaModel")
end


--获取荣耀竞技场的数据
function CrossArenaServer:onEnterCrossArena(result, error)
    if error ~= 0 then 
		return
	end
--    dump(result)
    self._gloryArenaModel:setData(result)
    self:callback(result)
end


--购买挑战次数
function CrossArenaServer:onBuyChallengeNum(result, error)
    if error ~= 0 then 
		return
	end

    local arena = result.d.crossArena
    self._gloryArenaModel:lSetSelfAttackCount(arena)
    result.d.crossArena = nil
    local userModel = self._modelMgr:getModel("UserModel")
	userModel:updateUserData(result.d)
    self:callback(result)
end


--获取排行
function CrossArenaServer:onGetRank(result, error)
    if error ~= 0 then 
		return
	end

    self._gloryArenaModel:lSetGloryArenaRank(result)

    self:callback(result)
end


--刷新竞技场对手
function CrossArenaServer:onReflashArena(result, error)
    
    if error ~= 0 then 
		return
	end

    self._gloryArenaModel:lSetMainRankData(result.enemys)
--    self:
    self:callback(result)
end


--竞技场生涯商城兑换
function CrossArenaServer:onExchangeShop(result, error)
    if error ~= 0 then 
		self:callback({errorCode = error})
		return
	end
    self._gloryArenaModel:updateArenaShop(result.d.crossArena.shop1, 1)
	result.d.crossArena.shop1 = nil
--	self._gloryArenaModel:updateArena(result.d.crossArena)
	result.d.crossArena = nil
	-- todo 更新物品
	self._modelMgr:getModel("ItemModel"):updateItems(result.d.items)
	result.d.items = nil
	self._modelMgr:getModel("UserModel"):updateUserData(result.d)
	self:callback(result)
end

--获取战报
--请求：
--{
--	time : 12344 最新时间
--}
function CrossArenaServer:onGetReportList(result, error)
    if error ~= 0 then 
		return
	end
	self._gloryArenaModel:lSetGloryArenaReport(result or {})
    self:callback(result)
end


--挑战
--请求：
--{
--	id : 8001_501
--	rank:100
--}
function CrossArenaServer:onChallenge(result, error)
     if error ~= 0 then
        -- print("****************************", error)
        if tonumber(error) == 1108 or tonumber(error) == 1103 then
            --挑战次数小于最低领取次数
            --超出挑战范围，不可挑战该对手！
            --对手排位已变更，请重新打开页面
            self._gloryArenaModel:reflashEnterCrossArena()
        end
		return
	end
--    dump(result)
    self._gloryArenaModel:lSetSelfAttackCount(result.d.crossArena)
    result.d.crossArena = nil
    self._modelMgr:getModel("UserModel"):updateUserData(result.d)
    self:callback(result)
end

--更具战报keu获取战斗数据
function CrossArenaServer:onGetBattleReport(result, error)
    if error ~= 0 then 
		return
	end
   
--    dump(result)
    self:callback(result)
end

function CrossArenaServer:onGetChallengeAward(result, error)
    if error ~= 0 then
--        print("****************************", error)
--        if tonumber(error) == 9502 then
--            --挑战次数小于最低领取次数
--            --超出挑战范围，不可挑战该对手！
--            --对手排位已变更，请重新打开页面
----            self._gloryArenaModel:reflashEnterCrossArena()
----            print("+++++++++++++++++++++")

--        end
        self:callback({errorCode = error})
		return
	end
--    dump(result)
    self._gloryArenaModel:updateArenaShop(result.d.crossArena.shop2, 2)
	result.d.crossArena.shop1 = nil
--	self._gloryArenaModel:updateArena(result.d.crossArena)
	result.d.crossArena = nil
	-- todo 更新物品
	self._modelMgr:getModel("ItemModel"):updateItems(result.d.items)
	result.d.items = nil
	self._modelMgr:getModel("UserModel"):updateUserData(result.d)
	self:callback(result)
end

function CrossArenaServer:onGetDetailInfo(result, error)
    if error ~= 0 then 
		return
	end
--    dump(result)
    self:callback(result)
end

--扫荡请求：
--{
--  "defId" : 8001#8001_501  带区服的id
--  "defRankId" : 100  防守方名次
--}
function CrossArenaServer:onSweepEnemy(result, error)

    print("onSweepEnemy   ", error)

    if error ~= 0 then 
        if tonumber(error) == 9504 then
            --无法扫荡比你排名比你高的玩家
            self._gloryArenaModel:reflashEnterCrossArena()
        end
		return
	end
    self._gloryArenaModel:lSetSelfAttackCount(result.d.crossArena)
    result.d.crossArena = nil
    self._modelMgr:getModel("UserModel"):updateUserData(result.d)
    self:callback(result)
end

-- 隐藏编组
-- 请求：
-- {
--   "hiddens" : [109,110] //隐藏的编组  数组  
-- }
function CrossArenaServer:onHiddenFormation(result, error)
    if error ~= 0 then 
        self:callback({errorCode = error})
		return
    end
--    dump(result)
    self._gloryArenaModel:lSetHideArray(result.d.crossArena.hiddens or "")
    self:callback(result)
end

function CrossArenaServer:onGetDefFormation(result, error)
    if error ~= 0 then 
		return
    end
--    dump(result)
    self._gloryArenaModel:lSaveDefenseArray(result)
    self:callback(result)
end

function CrossArenaServer:onGetAtkFormation(result, error)
    if error ~= 0 then 
		return
    end
--    dump(result)
    self._gloryArenaModel:lSaveAttackArray(result)
    self:callback(result)
end

--一键扫荡
--{
    -- num:5  次数
--}
function CrossArenaServer:onOneKeySweep(result, error)

    print("onOneKeySweep   ", error)

    if error ~= 0 then 
        if tonumber(error) == 9504 then
            --无法扫荡比你排名比你高的玩家
            self._gloryArenaModel:reflashEnterCrossArena()
        end
        return
    end
    self._gloryArenaModel:lSetSelfAttackCount(result.d.crossArena)
    result.d.crossArena = nil
    self._modelMgr:getModel("UserModel"):updateUserData(result.d)
    self:callback(result)
end

return CrossArenaServer




--endregion
