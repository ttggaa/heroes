--[[
    Filename:    CityBattleServer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-02-21 11:04:03
    Description: File description
--]]

local CityBattleServer = class("CityBattleServer", BaseServer)

function CityBattleServer:ctor()
    CityBattleServer.super.ctor(self)
    self._cityBattleModel = self._modelMgr:getModel("CityBattleModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
end



-- 派遣编组php
function CityBattleServer:onUpGVGBattleInfo(result, error)
    self:callback(result, error)
end


-- 进入战场
function CityBattleServer:onInitGVGFormation(result, error)
    -- dump(result, "test", 10)
    if error ~= 0  then return end
    if result["d"] ~= nil then
        if result["d"]["formations"] ~= nil then 
            local formationModel = self._modelMgr:getModel("FormationModel")
            formationModel:updateAllFormationData(result["d"]["formations"])
            -- formationModel:updateFormationDataByType(formationModel.kFormationTypeCommon, result["d"]["formations"][tostring(formationModel.kFormationTypeCommon)])
            result["d"]["formations"] = nil
        end
    end
    self:callback(result)
end

-- 进入战场
function CityBattleServer:onEnterCityBattle(result, error)
    -- dump(result,"CityBattleServer:onEnterCityBattle",10)
    if error ~= 0 then
        self:callback() 
        return
    end
    self._cityBattleModel:setData(result)
    self:callback(result)
end

-- 派遣编组
function CityBattleServer:onSendTeam(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)

    self:callback(result)
end

-- 撤回兵团
function CityBattleServer:onWithDrawTeam(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 捐赠贡献
function CityBattleServer:onDonate(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result,"onDonate",10)
    -- self:handAboutServerData(result)
    -- self._cityBattleModel:updateGVGUserData(result["d"])
    self._cityBattleModel:updateReadyDataAfterDone(result)
    self:callback(result)
end

-- 鲜花和鸡蛋
function CityBattleServer:onThrowFlowersOrEggs(result, error)
    if error ~= 0 then 
        return
    end

    self:callback(result)
end

-- 复活编组
function CityBattleServer:onReviveFormation(result, error)
    if error ~= 0 then 
        self:callback(result, error)
        return
    end
    if result["fid"] == nil then 
        self:callback(result, 1000000000)
        return 
    end

    self._cityBattleModel:delFormationData(result["fid"])
    if result["d"] ~= nil then
        -- 更新用户数据
        local userModel = self._modelMgr:getModel("UserModel")
        userModel:updateUserData(result["d"])
    end
    self:callback(result, error)
end

-- 获取领袖信息
function CityBattleServer:onGetBattleUser(result, error)
    if error ~= 0 then 
        return
    end

    self:callback(result)
end

-- 加入房间
function CityBattleServer:onJoinCity(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result, "=onJoinCity===", 10)
    self:callback(result)
end

-- 离开房间
function CityBattleServer:onLeaveCity(result, error)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end

-- 获取城池在某一轮的某一场战斗
function CityBattleServer:onGetRealBattle(result, error)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end

--获取个人奖励
function CityBattleServer:onGetPoint(result,error)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end

-- 领取奖励
function CityBattleServer:onGetAward(result, error)
    if error ~= 0 then 
        return
    end
    if result["d"] and result["d"]["items"] ~= nil then
        self._itemModel:updateItems(result["d"]["items"], true)
        result["d"]["items"] = nil 
    end
    self._userModel:updateUserData(result["d"])
    self:callback(result)
end

-- 获取战报列表
function CityBattleServer:onGetReportList(result, error)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end

-- 获取战报详情
function CityBattleServer:onGetBattleReport(result, error)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end

-- 获取城池战报列表
function CityBattleServer:onGetCityReportList(result, error)
    -- dump(result,"CityBattleServer:onGetCityReportList",10)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end

-- 获取联盟积分排行
function CityBattleServer:onGetGuildRank(result, error)
    -- dump(result,"CityBattleServer:onGetGuildRank",10)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end

-- 获取防守队列
function CityBattleServer:onGetDefQueue(result, error)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end

-- 获取攻击队列
function CityBattleServer:onGetAtkQueue(result, error)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end

-- 查看NPC数据
function CityBattleServer:onGetNpcData(result, error)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end

-- 获取城池战斗日志
function CityBattleServer:onGetLog(result, error)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end

-- 获取所有城池的当前人数
function CityBattleServer:onGetAllCityNum(result, error)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end

-- 获取个人结算
function CityBattleServer:onGetPeopleResult(result, error)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end

-- 获取服务器结算
function CityBattleServer:onGetSectionResult(result, error)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end

-- [self] => Array            个人结算
--     (
--         [w] => 5             连胜
--         [s] => 0             复活次数
--         [k] => Array       每个编组的击杀数量
--             (
--                 [17] => 5
--             )
--     )
-- [all] => Array              区结算
--     (
--         [c] => Array         每个区拥有的城池数
--             (
--                 [9994] => 6
--                 [9992] => 7
--             )
--         [k] => Array         每个城击杀玩家数
--             (
--                 [9992] => 5
--             )
--     )


--------------------------------------------------------------------------------
-- 推送数据

-- 战斗数据推送
function CityBattleServer:onPushBattleResult(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result, "result ==========fight ==", 10)
    -- self._cityBattleModel:
    self:callback(result)
end



function CityBattleServer:handAboutServerData(result)
    -- dump(result, "result==========", 10)
    if result == nil then 
        return 
    end
    -- 更新玩家信息
    if result["u"] ~= nil then
        self._cityBattleModel:updateGVGUserData(result["u"])
    end
    -- 更新城市信息
    if result["c"] ~= nil then
        self._cityBattleModel:updateCityData(result["c"])
    end

    if result["d"] and result["d"]["cb"] ~= nil then
        self._cityBattleModel:updateGVGUserData(result["d"]["cb"])
        result["d"]["cb"] = nil
    end

   -- 物品数据处理要优先于怪兽
    if result["d"] and result["d"]["items"] ~= nil then
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"], true)
        result["d"]["items"] = nil 
    end

    -- 去掉多余信息
    if result["unset"] ~= nil then 
        local removeFormation = self._cityBattleModel:handelUnsetCityBattle(result["unset"])
        self._cityBattleModel:retreatFormation(removeFormation)

        -- self._cityBattleModel:delItems(removeItems)
        -- itemModel:delItems(removeItems, true)
    end

   --  if result["unset"] ~= nil then 
   --      local itemModel = self._modelMgr:getModel("ItemModel")
   --      local removeItems = itemModel:handelUnsetItems(result["unset"])
   --      itemModel:delItems(removeItems, true)
   --  end

   --  if result["d"]["teams"] ~= nil  then 
   --      local teamModel = self._modelMgr:getModel("TeamModel")
   --      teamModel:updateTeamData(result["d"]["teams"])
   --      result["d"]["teams"] = nil
   --  end 

   --  if result["d"]["formations"] ~= nil then 
   --      local formationModel = self._modelMgr:getModel("FormationModel")
   --      formationModel:updateAllFormationData(result["d"]["formations"])
   --      -- formationModel:updateFormationDataByType(formationModel.kFormationTypeCommon, result["d"]["formations"][tostring(formationModel.kFormationTypeCommon)])
   --      result["d"]["formations"] = nil
   --  end

   --  if result.d and result.d.dayInfo then
   --      self._modelMgr:getModel("PlayerTodayModel"):updateDayInfo(result.d.dayInfo)
   --  end
        
   --  if result["d"]["teamPokedex"] ~= nil  then
   --      self._modelMgr:getModel("PokedexModel"):updateData(result["d"]["teamPokedex"])
   --  end

    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
end

--领取备战宝箱奖励
function CityBattleServer:onGetDonateAward(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result, "CityBattleServer:onGetDonateAward", 10)
    if result["d"] and result["d"]["items"] ~= nil then
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"], true)
        result["d"]["items"] = nil 
    end
    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
    self:callback(result)
end

function CityBattleServer:onGetDonateInfo(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result,"CityBattleServer:onGetDonateInfo",10)
    self._cityBattleModel:resetReadlyData(result)
    self:callback(result)
end

function CityBattleServer:onGetInfo(result, error)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end

function CityBattleServer:onGetCitybattleSoketData(result, error)
    if error ~= 0 then
        self:callback({status = 1001}, 1001)  
        return
    end
    local data = result
    data.rid = self._modelMgr:getModel("UserModel"):getRID()
    data.platform = GameStatic.userSimpleChannel
    data.sec = self._cityBattleModel:getMineSec()
    print("onGetCitybattleSoketData",self._cityBattleModel:getMineSec())
--    data.url = "ws://192.168.5.207:9191/war"

--    data.url = "ws://172.16.42.57:9191/war"
--    data.roomId = "default#1"

    if data.url == nil then 
        self._viewMgr:showTip(lang("CITYBATTLE_TIP_34"))
        self:callback({status = 1002}, 1002)
        return 
    end

    if data.roomId == nil then
        self._viewMgr:showTip(lang("CITYBATTLE_TIP_34"))
        self:callback({status = 1001}, 1001)
        return 
    end
    --清除获取数据状态
    self._cityBattleModel:clearStatus10001()

    -- 保存MapId
    self._cityBattleModel:setMapId(data.roomId)
    self._cityBattleModel:setSocketData(data)

    ServerManager:getInstance():RS_initSocket(data,
    function (errorCode)
        if errorCode ~= 0 then 
           -- self._cityBattleModel:onSocektError({status = 1000, error = 1})
           self:callback({status = 1000}, errorCode)
           return 
        end
        -- 连接成功回调
        print("rs init success")
        self._cityBattleModel:onListenRSResponse()
        self:callback({status = 1000}, 0)
    end)

    self:callback({status = 999}, 0)
end

--[[
    进入GVG 界面
]]
function CityBattleServer:onJoinRoom(result, error)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end
--[[
    离开GVG 界面
]]
function CityBattleServer:onExitRoom(result, error)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end

--[[
    获取历史战绩
]]
function CityBattleServer:onGetSecRecordInfo(result, error)
    if error ~= 0 then 
        return
    end
    self._cityBattleModel:setSecRecordData(result)
    self:callback(result)
end


return CityBattleServer