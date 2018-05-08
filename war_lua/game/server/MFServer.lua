--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-04-22 18:48:27
--

local MFServer = class("MFServer",BaseServer)

function MFServer:ctor(data)
    MFServer.super.ctor(self,data)
    self._mfModel = self._modelMgr:getModel("MFModel")
end

-- 获取
function MFServer:onGetMFInfo(result, error)
	if error ~= 0 then 
		return
	end
    -- self._mfModel:setTasks(result["tasks"])
	self._mfModel:setData(result)
	self:callback(result)
end

-- 开始
function MFServer:onStartMF(result, error)
	if error ~= 0 then 
		return
	end
    if result["d"]["mf"] ~= nil  then 
        local mfModel = self._modelMgr:getModel("MFModel")
        mfModel:startTasks(result["d"]["mf"])
    end 
	self:handAboutServerData(result)
	self:callback(result)
end

-- 刷新自己
function MFServer:onReflashMFTask(result, error)
	if error ~= 0 then 
		return
	end
    local mfModel = self._modelMgr:getModel("MFModel")
    mfModel:updateTasks(result["d"]["mf"])
	self:callback(result)
end

-- 领奖励
function MFServer:onGetfinishMFReward(result, error)
	if error ~= 0 then 
		return
	end
    if result["d"]["mf"] ~= nil  then 
        local mfModel = self._modelMgr:getModel("MFModel")
        mfModel:updateTasks(result["d"]["mf"])
    end 
    self:handAboutServerData(result)
	self:callback(result)
end

--一键领奖励
function MFServer:onOneKeyGetfinishMFReward(result, error)
	if error ~= 0 then
		return
	end
	if result["d"]["mf"] ~= nil  then 
        local mfModel = self._modelMgr:getModel("MFModel")
        mfModel:updateTasks(result["d"]["mf"])
    end
	self:handAboutServerData(result)
	self:callback(result)
end

-- 完成
function MFServer:onFinishMF(result, error)
	if error ~= 0 then 
		return
	end
    if result["d"]["mf"] ~= nil  then 
        local mfModel = self._modelMgr:getModel("MFModel")
        mfModel:cancleTasks(result["d"]["mf"])
    end 
    self:handAboutServerData(result)
	self:callback(result)
end

-- 取消
function MFServer:onCancleMF(result, error)
	if error ~= 0 then 
		return
	end
    if result["d"]["mf"] ~= nil  then 
        local mfModel = self._modelMgr:getModel("MFModel")
        mfModel:cancleTasks(result["d"]["mf"])
    end 
	self:handAboutServerData(result)
	self:callback(result)
end


-- pvp 接口
-- 获取好友或者联盟成员岛屿
function MFServer:onGetGameFriendMFInfo(result, error)
    if error ~= 0 then 
        return
    end
    if result["tasks"] then
        --todo
    end
    self:callback(result)
end

-- 帮助好友
function MFServer:onHelpGameFriendMF(result, error)
    if error ~= 0 then 
        return
    end
    -- if result.d and result.d.dayInfo then
    --     self._modelMgr:getModel("PlayerTodayModel"):updateDayInfo(result.d.dayInfo)
    -- end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 答谢好友
function MFServer:onThankGameFriend(result, error)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end

-- 获取答谢奖励
function MFServer:onGetThankAward(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 入侵开始
-- 匹配抢夺对手
function MFServer:onMatchRival(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 战前请求
function MFServer:onDeCnt(result, error)
    if error ~= 0 then 
        return
    end
    if result.d and result.d.dayInfo then
        self._modelMgr:getModel("PlayerTodayModel"):updateDayInfo(result.d.dayInfo)
    end
    self:callback(result)
end

-- 获取抢夺对手
function MFServer:onGetRival(result, error)
    if error ~= 0 then 
        return
    end
    if result.d and result.d.dayInfo then
        self._modelMgr:getModel("PlayerTodayModel"):updateDayInfo(result.d.dayInfo)
    end
    self:callback(result)
end

-- 抢夺结算
function MFServer:onRobMF(result, error)
    if error ~= 0 then 
        return
    end
    -- if result.d and result.d.dayInfo then
    --     self._modelMgr:getModel("PlayerTodayModel"):updateDayInfo(result.d.dayInfo)
    -- end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 获取战报
function MFServer:onGetReportList(result, error)
    if error ~= 0 then 
        return
    end

    self:callback(result)
end

-- delRob
-- 删除掠夺者
function MFServer:onDelRob(result, error)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end


function MFServer:handAboutServerData(result)
    if result == nil or result["d"] == nil then 
        return 
    end
   -- 物品数据处理要优先于怪兽
    if result["d"]["items"] ~= nil then
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"], true)
        result["d"]["items"] = nil 
    end

    if result["unset"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        local removeItems = itemModel:handelUnsetItems(result["unset"])
        itemModel:delItems(removeItems, true)
    end
	-- if result.d.mf then
	-- 	self._mfModel:updateMf(result.d.mf)
	-- end
    -- if result["d"]["mf"] ~= nil  then 
    --     local mfModel = self._modelMgr:getModel("MFModel")
    --     mfModel:updateTasks(result["d"]["mf"])
    --     -- result["d"]["mf"] = nil
    -- end 

    if result["d"]["teams"] ~= nil  then 
        -- local teamModel = self._modelMgr:getModel("TeamModel")
        -- teamModel:updateTeamData(result["d"]["teams"])
        result["d"]["teams"] = nil
    end 

    if result["d"]["heros"] ~= nil  then 
        -- local teamModel = self._modelMgr:getModel("TeamModel")
        -- teamModel:updateMfHeros(result["d"]["heros"])
        result["d"]["heros"] = nil
    end 

    if result.d and result.d.dayInfo then
        self._modelMgr:getModel("PlayerTodayModel"):updateDayInfo(result.d.dayInfo)
    end

    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
end

-- 航海推送
function MFServer:onPushHelp(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result, "re==========", 5)
    if result and result.isTip == 1 then
        self._mfModel:setTipData(true)
    end
    if result and result.tasks then
        local mf = {}
        mf["tasks"] = result.tasks
        local mfModel = self._modelMgr:getModel("MFModel")
        mfModel:updateTasks(mf)
    end    
end

function MFServer:onPushRobbed(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result, "re==========")
    if result and result.isTip == 1 then
        self._mfModel:setTipData(true)
    end
end

--[[
    一键答谢及删除抢夺者
]]
function MFServer:onOneKeyThankAndDel(result,error)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end

return MFServer