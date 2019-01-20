-- Author lannan

local PVETYPE_PROFESSIONBATTLE = 6

local ProfessionBattleServer = class("ProfessionBattleServer", BaseServer)

function ProfessionBattleServer:ctor(data)
    ProfessionBattleServer.super.ctor(self)
    self._professionBattleModel = self._modelMgr:getModel("ProfessionBattleModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
end

function ProfessionBattleServer:onGetInfo(result, error)
	if error~=0 then
		self:handleErrorCode(error)
		return
	end
    self._professionBattleModel:setData(result.professionBattle)
    if result.formations ~= nil then 
        dump(result.formations,"result.formations==>",5)
        local formationModel = self._modelMgr:getModel("FormationModel")
        formationModel:updateAllFormationData(result.formations)
        result.formations = nil
    end
	self:callback(result)
end

function ProfessionBattleServer:onBeforeBattle(result, error)
    -- dump(result, "onBeforeBattle", 5)
    self:callback(tonumber(error), result)
end

function ProfessionBattleServer:onAfterBattle(result, error)
    -- dump(result, "onAfterBattle", 5)
    -- if 0 ~= tonumber(error) then 
    --     return
    -- end
    self:callback(tonumber(error), result)
    self:handleAboutServerData(result)
end

function ProfessionBattleServer:onSweep(result, error)
    if 0 ~= tonumber(error) then 
        return
    end
    -- dump(result,"onSweep==>",5)
    self:callback(0 == tonumber(error), result)

    self:handleAboutServerData(result)
    
end

function ProfessionBattleServer:handleAboutServerData(result)
    if result == nil then
        return 
    end

    if result.formations ~= nil then 
        local formationModel = self._modelMgr:getModel("FormationModel")
        formationModel:updateAllFormationData(result.formations)
        result.formations = nil
    end
    
    if result["d"] and result["d"].professionBattle then
		self._modelMgr:getModel("BossModel"):setTimes(PVETYPE_PROFESSIONBATTLE, result.d.professionBattle.times)
        self._professionBattleModel:updateProfessionData(result["d"].professionBattle)
        result["d"].professionBattle = nil
    end
    if result["d"] and result["d"].items then
        self._itemModel:updateItems(result["d"].items or {})
        result["d"].items = nil
    end
    if result["d"] then 
        self._userModel:updateUserData(result["d"])
    end
end

return ProfessionBattleServer