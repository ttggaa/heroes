--[[
    Filename:    BossServer.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-11-11 10:51:01
    Description: File description
--]]

local BossServer = class("BossServer", BaseServer)

function BossServer:ctor()
    BossServer.super.ctor(self)
    self._bossModel = self._modelMgr:getModel("BossModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
end

function BossServer:onGetBossInfo(result, error)
    if 0 == tonumber(error) then
        self._bossModel:setData(result)
    end
    -- dump(result,"111",10)
    self:callback(0 == tonumber(error))
end

function BossServer:onGetPVEScoreRank( result,error )
    if 0 == tonumber(error) then
         self._bossModel:setPVEScoreRank(result)
    end
    self:callback(0 == tonumber(error))
end

function BossServer:onGetPVERankDetailInfo( result,error  )
    if error ~= 0 then 
        return
    end
        self:callback(result)
end

-- 获取我的排名 信息 
function BossServer:onGetMyPVEScoreRank(result, error)
    if 0 == tonumber(error) then
        -- self._bossModel:setData(result)
        -- 设置排名和分数 
        dump(result, "BossServer:onGetMyPVEScoreRank")
        self._bossModel:setMyPVEScoreRank(result)
    end
    self:callback(0 == tonumber(error))
end

function BossServer:onBeforeAttackBoss(result, error)
    dump(result, "onBeforeAttackBoss", 5)
    self:callback(tonumber(error), result)
end

function BossServer:onAfterAttackBoss(result, error)
    dump(result, "onAfterAttackBoss", 5)
    self:callback(tonumber(error), result)
    if result["d"] then
        result["d"].boss = nil
        result["d"].statis = nil
    end    
    if result["d"] and result["d"].items then
        self._itemModel:updateItems(result["d"].items or {})
        result["d"].items = nil
    end
    self._userModel:updateUserData(result["d"])
end

function BossServer:onSweepBoss(result, error)
    self:callback(0 == tonumber(error), result)
    if 0 == tonumber(error) then
        result["d"].boss = nil
        result["d"].statis = nil
        if result["d"].items then
            self._itemModel:updateItems(result["d"].items or {})
            result["d"].items = nil
        end
        self._userModel:updateUserData(result["d"])
    end
end

function BossServer:onGetPVEDailyReward(result, error)
    if 0 == tonumber(error) then
        self:callback(0 == tonumber(error),result)

        if result["d"] ~= nil then
            if result["d"]["items"] ~= nil then 
                local itemModel = self._modelMgr:getModel("ItemModel")
                itemModel:updateItems(result["d"]["items"])
                result["d"]["items"] = nil
            end
            -- 更新用户数据
            local userModel = self._modelMgr:getModel("UserModel")
            userModel:updateUserData(result["d"])
        end
    end
    -- self._bossModel:setRewardData(data)
end

--获取扫荡奖励
function BossServer:onGetSweepReward(result, error)
    
    self:callback(result,error == 0)
end

return BossServer