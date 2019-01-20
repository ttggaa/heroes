--[[
    Filename:    FormationServer.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-05-25 17:47:26
    Description: File description
--]]

--[=[
    { 
        formationId = 0, 
        args = 
        { 
            teams = {
                { 1000, 0 },
                { 1001, 1 },
                { 1002, 2 },
                { 1003, 3 },
                { 1004, 4 },
                { 1005, 5 },
                { 1006, 6 },
                { 1007, 7 },
                { 1008, 8 },
            }, 
            instruments = {
                { 10000, 10 },
                { 10001, 11 },
                { 10002, 12 },
            }, 
            skills = { 100001, 100002, 100003, 100004, 100005, 100006 }, 
        }, 
    }

    {"teams":[[1101,1],[1102,3],[1103,5]],"ins":[],"skills":[[54013,1], [54021,2]]}
    {"teams":[[1104,6],[1105,8],[1106,10]],"ins":[],"skills":[[54013,1], [54031,3]]}
    {"teams":[[1107,11],[1108,13],[1109,15]],"ins":[],"skills":[[54031,2], [54021,3]]}


    {"teams":[[1109,1],[1110,3],[1301,5]]}
    {"teams":[[1110,6],[1301,8],[1302,10]]}
    {"teams":[[1301,11],[1302,13],[1109,15]]}
]=]

local FormationServer = class("FormationServer", BaseServer)

function FormationServer:ctor()
    FormationServer.super.ctor(self)
    self._formationModel = self._modelMgr:getModel("FormationModel")
end

function FormationServer:onGetFormation(result, error)
    --dump(result, "FormationServer:onGetFormation")
    -- Temp Code Begin
    --[[
    result["formations"] = 
    {
        [1] =
        {
            ["values"] =
            {
                ["1"]  = 1,
                ["10"] = 10,
                ["11"] = 6,
                ["12"] = 12,
                ["13"] = 7,
                ["14"] = 14,
                ["15"] = 8,
                ["16"] = 16,
                ["17"] = 9,
                ["18"] = 18,
                ["19"] = 1001,
                ["2"]  = 2,
                ["20"] = 3,
                ["21"] = 1002,
                ["22"] = 5,
                ["23"] = 1003,
                ["24"] = 7,
                ["25"] = 1004,
                ["26"] = 9,
                ["27"] = 2001,
                ["28"] = 2002,
                ["29"] = 2003,
                ["3"]  = 2,
                ["30"] = 0,
                ["31"] = 0,
                ["32"] = 0,
                ["33"] = 1432783900,
                ["4"]  = 4,
                ["5"]  = 3,
                ["6"]  = 6,
                ["7"]  = 4,
                ["8"]  = 8,
                ["9"]  = 5,
            },
        },
    }
    ]]
    -- Temp Code End
    self._formationModel:setFormationData(result["formations"])
    self:callback(0 == tonumber(error))
end

function FormationServer:onSetFormation(result, error)
    if result and result["d"] and result["d"]["scoreF1"] then
        if not self._userModel then
            self._userModel = self._modelMgr:getModel("UserModel")
        end
        self._userModel:updateScoreF1(result["d"]["scoreF1"])
    end
    self:callback(0 == tonumber(error))
end

function FormationServer:onSetFormations(result, error)
    self:callback(0 == tonumber(error), result)
end
--[[
function FormationServer:onQuickFormat(result, error)
    self:callback(0 == tonumber(error), result)
end
]]
function FormationServer:onSetDefaultForId(result, error)
    self:callback(0 == tonumber(error))
end

function FormationServer:onSetMultipleFormation(result, error)
    self:callback(0 == tonumber(error))
end

function FormationServer:onSetCityBattleFormation(result, error)
    self:callback(0 == tonumber(error), result)
end

function FormationServer:onGetSelfBattleInfo(result, error)
    self:callback(result)
end

function FormationServer:onSetCrossGodWarFormations( result, error )
    self:callback(0 == tonumber(error))
end

function FormationServer:onSetCrossArenaFormations( result, error )
    self:callback(0 == tonumber(error))
end

-- 设置布阵的宝物编组
function FormationServer:onChangeTformation(result, error)
    if error ~= 0 then 
        return
    end
    dump(result,"onChangeTformation...==========",10)
    if result.d and result.d.formations then
        self._formationModel:updateAllFormationData(result.d.formations)
    end
    self:callback(result)
end

function FormationServer:onSetAreaSkillTeam( result, error )
    if error ~= 0 then
        return
    end
    dump(result)
    if result.d and result.d.formations then
        self._formationModel:updateAllFormationData(result.d.formations)
    end
    if result["unset"] ~= nil then 
        self._formationModel:handleUnsetFormationData(result["unset"])
    end
    self:callback(result)
end

return FormationServer