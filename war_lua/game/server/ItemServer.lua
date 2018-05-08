--[[
    Filename:    ItemServer.lua(同时对应背包)
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-05-20 23:01:20
    Description: File description
--]]

local ItemServer = class("ItemServer", BaseServer)

function ItemServer:ctor(data)
    ItemServer.super.ctor(self,data)
    self._bagModel = self._modelMgr:getModel("ItemModel")
end

function ItemServer:onGetItems(result, error)
	if error ~= 0 then 
		return
	end

    local d = self._bagModel:setData(result["items"])
    self:callback()
end

function ItemServer:onUseItem(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutTeamServerData(result)
    self:callback(result)
end


function ItemServer:handAboutTeamServerData(result)
    if result == nil or result["d"] == nil then 
        return 
    end
    dump(result,"result....",10)
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

    if result["d"]["heros"] then
        local heroModel = self._modelMgr:getModel("HeroModel")
        heroModel:updateHeroData(result["d"])
        result["d"]["heros"] = nil
    end

    local userModel = self._modelMgr:getModel("UserModel")
    if result["d"] and result["d"]["hSkin"] then
        userModel:updateSkinData(result["d"]["hSkin"])
        result["d"]["hSkin"] = nil
    end

    local activityModel = self._modelMgr:getModel("ActivityModel")
    if result["d"] and result["d"]["activity"] then
        activityModel:updateSpecialData(result["d"]["activity"])
        result["d"]["activity"] = nil
    end

    if result["d"] and result["d"]["sRcg"] then
        activityModel:updateSingleRechargeData(result, true)
        result["d"]["sRcg"] = nil
    end

    if result["d"] and result["d"]["intelligentRecharge"] then
        activityModel:updateIntRechargeData(result, true)
        result["d"]["intelligentRecharge"] = nil
    end

    userModel:updateUserData(result["d"])
end

return ItemServer