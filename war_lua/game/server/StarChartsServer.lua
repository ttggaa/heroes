--[[
    @FileName   StarChartsServer.lua
    @Authors    zhangtao
    @Date       2018-03-07 10:57:45
    @Email      <zhangtao@playcrad.com>
    @Description   描述
--]]

local StarChartsServer = class("StarChartsServer",BaseServer)

function StarChartsServer:ctor(data)
    StarChartsServer.super.ctor(self,data)
    self._starModel = self._modelMgr:getModel("StarChartsModel")
end

--星魂转换
function StarChartsServer:onConvert( result, error)
    if error == 0 then
        self:handleAboutServerData(result,"convert")
    end
    self:callback(result,error)
end
--激活星团
function StarChartsServer:onActivation( result, error)
    if error ~= 0 then 
        return
    end
    self:handleAboutServerData(result,"activation")
    self:callback(result)
    
end
--重置星图
function StarChartsServer:onReset( result, error)
    if error ~= 0 then 
        return
    end
    self:handleAboutServerData(result,"reset")
    self:callback(result)
end
--星图构成
function StarChartsServer:onCompose( result, error)
    if error ~= 0 then 
        return
    end
    self:handleAboutServerData(result,"compose")
    self:callback(result)
end
--星图灌注
function StarChartsServer:onPrime( result, error)
    if error ~= 0 then 
        return
    end
    self:handleAboutServerData(result,"prime")
    self:callback(result)
end
--星图灌注确认
function StarChartsServer:onPrimeSure( result, error)
    if error ~= 0 then 
        return
    end
    self:handleAboutServerData(result,"primeSure")
    self:callback(result)
end


function StarChartsServer:handleAboutServerData(result,upTypeName)
    if result == nil or result["d"] == nil then 
        return 
    end
    if result["d"]["formations"] ~= nil then 
        local formationModel = self._modelMgr:getModel("FormationModel")
        formationModel:updateAllFormationData(result["d"]["formations"])
        -- formationModel:updateFormationDataByType(formationModel.kFormationTypeCommon, result["d"]["formations"][tostring(formationModel.kFormationTypeCommon)])
        result["d"]["formations"] = nil
    end

    if result["unset"] ~= nil then
        local heroModel = self._modelMgr:getModel("HeroModel")
        local itemModel = self._modelMgr:getModel("ItemModel")
        for k,v in pairs(result["unset"]) do
            if string.find(k, ".") ~= nil then
                local temp = string.split(k, "%.")
                if temp[1] == "items" then
                    local tempTable = {}
                    tempTable[k] = 1
                    local removeItems = itemModel:handelUnsetItems(tempTable)
                    itemModel:delItems(removeItems, true)
                else
                    local tempTable = {}
                    tempTable[k] = 1
                    local removeItems = heroModel:handelUnsetStarItems(tempTable)
                    for k , v in pairs(removeItems) do
                        heroModel:delItems(v)
                    end
                    self._starModel:setStarInfoByHeroId(removeItems["heroId"])
                end
            end
        end

        self._starModel:reflashData(upTypeName)
    end

    if result["d"].items then
        self._modelMgr:getModel("ItemModel"):updateItems(result["d"].items)
        result["d"].items = nil
    end
    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
    if result["d"]["hStar"] then
        userModel:updateHeroStarInfo(result["d"]["hStar"])
    end

    if result["d"]["heros"] ~= nil then 
        local heroModel = self._modelMgr:getModel("HeroModel")
        heroModel:unlockHero(result["d"]["heros"])
        self._starModel:updateStarInfo(clone(result["d"]["heros"]),upTypeName)
        result["d"]["heros"] = nil
    end
    
    --更新任务数据
    local taskModel = self._modelMgr:getModel("TaskModel")
    taskModel:onChangeTask(result)
end


return StarChartsServer