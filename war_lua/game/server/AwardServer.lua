--
-- Author: huangguofang
-- Date: 2016-03-11 17:46:53
--
local AwardServer = class("VipServer", BaseServer)

function AwardServer:ctor()
    AwardServer.super.ctor(self)
    self._vipModel = self._modelMgr:getModel("VipModel")
    self._userModel = self._modelMgr:getModel("UserModel")
end

function AwardServer:onGetFirstRecharge(result, error)
	-- dump(result)
    if not result then return end
    if 0 ~= error then return end
	-- 物品数据处理要优先于怪兽
    local itemModel = self._modelMgr:getModel("ItemModel")
    itemModel:updateItems(result["d"]["items"], true)
    result["d"]["items"] = nil

    if result["unset"] ~= nil then 
        local removeItems = itemModel:handelUnsetItems(result["unset"])
        itemModel:delItems(removeItems, true)
    end
    if result["d"]["teams"] then
        local teamModel = self._modelMgr:getModel("TeamModel")
        teamModel:updateTeamData(result["d"]["teams"])
        result["d"]["teams"] = nil
    end

    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
    self:callback(0 == tonumber(error), result["d"])

end

function AwardServer:onReceiveLoginReward(result, error)
    if error ~= 0 then 
        return
    end
    dump(result, "test", 10)
    self:handleAboutServerData(result)
    if result["d"] ~= nil then
        if result["d"]["award"] ~= nil then
            local sevenDaysModel = self._modelMgr:getModel("ActivitySevenDaysModel")
            if result["d"]["award"]["login"] then 
                sevenDaysModel:updateData(result["d"]["award"]["login"], result["d"]["award"]["loginFinish"])
                result["d"]["award"]["login"] = nil
                result["d"]["award"]["loginFinish"] = nil
            end
            if result["d"]["award"]["loginExt"] then 
                sevenDaysModel:updateLoginExt(result["d"]["award"]["loginExt"])
            end
        end  
    end
    self:callback(result)
end

function AwardServer:onReceiveLoginReward2(result, error)
    if error ~= 0 then 
        return
    end
    dump(result)
    self:handleAboutServerData(result)
    if result["d"] ~= nil then
        if result["d"]["award"] ~= nil and result["d"]["award"]["login2"] then 
            local halfMonthModel = self._modelMgr:getModel("ActivityHalfMonthModel")
            halfMonthModel:updateData(result["d"]["award"]["login2"], result["d"]["award"]["loginFinish2"])
            result["d"]["award"]["login2"] = nil
            result["d"]["award"]["loginFinish2"] = nil
        end  
    end
    self:callback(result)
end

function AwardServer:onReceiveLevelReward(result, error)
    if error ~= 0 then 
        return
    end
    self:handleAboutServerData(result)
    if result["d"] ~= nil then
        if result["d"]["award"] ~= nil and result["d"]["award"]["levels"] then 
            local levelFeedBackModel = self._modelMgr:getModel("ActivityLevelFeedBackModel")
            levelFeedBackModel:updateData(result["d"]["award"]["levels"], result["d"]["award"]["levelsFinish"])
            result["d"]["award"]["levels"] = nil
        end  
    end
    self:callback(result)
end

function AwardServer:onGetSevenAimReward(result,error) 
    if error ~= 0 then 
        return
    end
    self:handleAboutServerData(result)
    if result["d"] ~= nil then
        if result["d"]["award"] ~= nil and result["d"]["award"]["sevenAim"] then 
            local cainivalModel = self._modelMgr:getModel("ActivityCarnivalModel")
            cainivalModel:updateCarnivalData(result["d"]["award"]["sevenAim"])
            result["d"]["award"]["sevenAim"] = nil
        end  
    end
    self:callback(result)
end

function AwardServer:handleAboutServerData(result,inType)
    if result == nil or result["d"] == nil then 
        return 
    end
    -- dump(result,"result===>",5)
    if result["d"]["items"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"])
        result["d"]["items"] = nil
    end

    if result["d"]["heros"] ~= nil then 
        local heroModel = self._modelMgr:getModel("HeroModel")
        heroModel:unlockHero(result["d"]["heros"])
        result["d"]["heros"] = nil
    end

    if result["d"]["formations"] ~= nil then 
        dump(result["d"]["formations"], "test", 10)
        local formationModel = self._modelMgr:getModel("FormationModel")
        formationModel:updateAllFormationData(result["d"]["formations"])
        result["d"]["formations"] = nil
    end

    if result["d"]["teams"] ~= nil then
        local teamModel = self._modelMgr:getModel("TeamModel")
        teamModel:updateTeamData(result["d"]["teams"])
        result["d"]["teams"] = nil
    end

    if result["d"]["weaponInfo"] ~= nil  then 
        local weaponsModel = self._modelMgr:getModel("WeaponsModel")
        weaponsModel:updateWeaponsInfo(result["d"]["weaponInfo"])
        result["d"]["weaponInfo"] = nil
    end
    
    -- 更新用户数据
    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])

end

-- 领取体力1
function AwardServer:onGetDailyPy(result, error)   

    if 0 ~= error then return end   

     --更新体力领取数据结构  先更新award ，执行完动画回调中更新体力
    local data = {}
    data.award = result["d"].award
    result["d"].award = nil
    -- 更新用户数据
    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(data)

    self:callback(0 == tonumber(error), result["d"])
   
end
-- 领取体力2
function AwardServer:onGetOverducDailyPy(result, error)   

    if 0 ~= error then return end   

    --更新体力领取数据结构
    local data = {}
    data.award = result["d"].award
    result["d"].award = nil
    -- 更新用户数据
    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(data)

    self:callback(0 == tonumber(error), result["d"])
    
end

-- 
function AwardServer:onGetLuckStar(result, error) 
    if 0 ~= error then return end  
    -- dump(result,"result==>",5)
    self:handleAboutServerData(result)

    self:callback(result["d"],0 == tonumber(error))
end

function AwardServer:onGetTuringLuckStar(result, error) 
    if 0 ~= error then return end  
    -- dump(result,"result==>",5)
    self:handleAboutServerData(result)

    self:callback(result["d"],0 == tonumber(error))
end

return AwardServer