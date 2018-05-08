--[[
    Filename:    GodWarServer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-03-31 16:41:59
    Description: File description
--]]


local GodWarServer = class("GodWarServer",BaseServer)

function GodWarServer:ctor(data)
    GodWarServer.super.ctor(self,data)
    self._godWarModel = self._modelMgr:getModel("GodWarModel")
    self._formationModel = self._modelMgr:getModel("FormationModel")
end

-- 主入口
function GodWarServer:onEnterGodWar(result, error)
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    result["r1"] = nil
    result["r2"] = nil
    result["r3"] = nil

    self._godWarModel:setData(result)
    self:callback(result)
end

-- 发送红包
function GodWarServer:onSendRed(result, error)
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    self:callback(result)
end

-- 押注比赛
function GodWarServer:onStakeFight(result, error)
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    self._godWarModel:updateWarBattleData(result)
    self:callback(result)
end

-- 一键领取押注奖励
function GodWarServer:onOnekeyReceiveStakeRewards(result, error)
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
    self:callback(result)
end

-- 领取押注奖励
function GodWarServer:onReceiveStakeRewards(result, error)
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
    self:callback(result)
end

-- 获取押注列表
function GodWarServer:onGetReceiveStakeList(result, error)
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    self._godWarModel:setWarStakeList(result)
    self:callback(result)
end

-- 获取参加列表
function GodWarServer:onGetJoinList(result, error)
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    if result then
        self._godWarModel:updatePlayerData(result)
    end
    self:callback(result)
end

-- 获取小组赛数据
function GodWarServer:onGetGroupBattle(result, error)
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    if result["gp"] then
        self._godWarModel:updateGroupBattleData(result["gp"])
        result["gp"] = nil
    end
    self:callback(result)
end

-- 获取晋级赛数据
function GodWarServer:onGetPowBattle(result, error)
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    if result then
        self._godWarModel:updateWarBattleData(result)
    end
    self:callback(result)
end

-- 获取小组赛战报信息
function GodWarServer:onGetGroupBattleInfo(result, error)
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    self:callback(result)
end

-- 获取晋级赛战报信息
function GodWarServer:onGetWarBattleInfo(result, error)
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    self:callback(result)
end


-- 获取小组赛某场战斗攻方，守方数据
function GodWarServer:onGetGpBattleInfo(result, error)
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    self:callback(result)
end

-- 获取晋级赛某场战斗攻方，守方数据
function GodWarServer:onGetPowBattleInfo(result, error)
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    self:callback(result)
end

-- 膜拜冠军
function GodWarServer:onWorshipChampion(result, error)
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

function GodWarServer:onQuickSetFormations(result, error)
    --dump(result, "result", 5)
    if 0 ~= tonumber(error) then return end
    if result and result["d"] and result["d"]["formations"] then
        self._formationModel:updateAllFormationData(result["d"]["formations"])
    end
end

-- 快速布阵
function GodWarServer:onFastSetFormations(result, error)
    self:callback(0 == tonumber(error), result)
end

-- 获取前三名的皮肤
function GodWarServer:onGetTop3Skin(result, error)
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    self._godWarModel:updatePlayer(result)
    self:callback(result)
end

-- 更新当前赛季数据
function GodWarServer:onUpdateSeason(result, error)
    if error ~= 0 then 
        print("error ....",error)
        return
    end

    self:callback(result)
end

-- 离开房间
function GodWarServer:onExitRoom(result, error)
    if error ~= 0 then 
        print("error ....",error)
        return
    end

    self:callback(result)
end


function GodWarServer:handAboutServerData(result)
    if result == nil then 
        return 
    end

    if result["jn"] then
        self._godWarModel:updatePlayerData(result["jn"])
        result["jn"] = nil
    end

    if result["gp"] then
        self._godWarModel:updateGroupBattleData(result["gp"])
        result["gp"] = nil
    end

    if result["war"] then
        self._godWarModel:updateWarBattleData(result["war"])
        result["war"] = nil
    end

    dump(result)
    if not result["d"] then
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

    if result["d"]["teams"] ~= nil  then 
        local teamModel = self._modelMgr:getModel("TeamModel")
        teamModel:updateTeamData(result["d"]["teams"])
        result["d"]["teams"] = nil
    end 

    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
end



-- 抢红包
function GodWarServer:onRobRed(result, error)
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    dump(result)
    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
    self:callback(result)
end


-- 推送
-- 发红包
function GodWarServer:onRobGodWarRed(result, error)
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    local dayinfo = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(57)
    if dayinfo > 6 then
        return
    end
    if self._modelMgr:getModel("GodWarModel"):getShowRed() == true then
        local data
        for k,v in pairs(result) do
            if v.belong == "godwar" then
                v.redKey = k
                data = v
                break
            end
        end
        self._viewMgr:activeGiftMoneyTip(data)
    end
    self:callback(result)
end


return GodWarServer
