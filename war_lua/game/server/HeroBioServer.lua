--
-- Author: huangguofang
-- Date: 2017-03-31 14:58:37
--
local HeroBioServer = class("HeroBioServer", BaseServer)

function HeroBioServer:ctor()
    HeroBioServer.super.ctor(self)
    self._heroModel = self._modelMgr:getModel("HeroModel")
    self._userModel = self._modelMgr:getModel("UserModel")
end

-- 领取传记宝箱
function HeroBioServer:onGetHeroBioBox(result,error)
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    -- dump(result,"result==>",5)
    if result and result["d"] and result["d"]["heros"] then
        self._heroModel:updateBioData(result["d"]["heros"])
        result["d"]["heros"] = nil
    end

    -- 获得奖励数据处理
    -- 物品数据处理要优先于怪兽
    local itemModel = self._modelMgr:getModel("ItemModel")
    itemModel:updateItems(result["d"]["items"], true)
    result["d"]["items"] = nil

    if result and result["unset"] ~= nil then 
        local removeItems = itemModel:handelUnsetItems(result["unset"])
        itemModel:delItems(removeItems, true)
    end
    if result and result["d"] and result["d"]["teams"] then
        local teamModel = self._modelMgr:getModel("TeamModel")
        teamModel:updateTeamData(result["d"]["teams"])
        result["d"]["teams"] = nil
    end
    -- 头像更新
    if result and result["d"] and result["d"]["avatars"] then
        local avatarModel = self._modelMgr:getModel("AvatarModel")
        avatarModel:updateAvatarData(result["d"]["avatars"])
        result["d"]["avatars"] = nil
    end
    self._userModel:updateUserData(result["d"])

    self:callback(result, 0 == tonumber(error))
end

-- 传记 战前协议
function HeroBioServer:onBeforeAttkHeroBio(result,error)
    if error ~= 0 then return end
    self:callback(result,0 == error)
end
-- 传记 战后协议
function HeroBioServer:onAfterAttkHeroBio(result,error)
    if error ~= 0 then return end
    -- dump(result,"=====>",5)
    -- 战后更新数据
    if result["d"] then
        self._heroModel:updateBioData(result["d"]["heros"])
    end

    self:callback(result,0 == error)
    
end

-- 获取传记数据
function HeroBioServer:onGetHeroBioInfo(result, error)
    -- dump(result, "onGetHeroBioInfo",10)
    if 0 ~= tonumber(error) then return end
    if result then
        -- 新英雄传记数据初始化
        self._heroModel:updateBioData(result)
    end
    self:callback(result) 

end

return HeroBioServer