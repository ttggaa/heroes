--[[
    Filename:    AwakingModel.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-08-11 19:59:30
    Description: File description
--]]


local AwakingModel = class("AwakingModel", BaseModel)

function AwakingModel:ctor()
    AwakingModel.super.ctor(self)
    self._data = {}
    self:listenGlobalResponse(specialize(self.onChangeAwakingTask, self))
end

function AwakingModel:setData(data)
    self._data = data
    self:reflashData()
end

function AwakingModel:getData()
    -- self:setPokedexSumScore()
    return self._data
end

function AwakingModel:updateAwakingData(data)
    for k,v in pairs(data) do
        self._data[k] = v 
    end
    self:reflashData()
end

function AwakingModel:setAwakingTaskData(data)
    self._awakingTaskData = data
end

function AwakingModel:getAwakingTaskData()
    return self._awakingTaskData
end

function AwakingModel:isAwakingTaskOpened()
    if self._awakingTaskData and table.getn(table.keys(self._awakingTaskData)) > 0 and 0 ~= self._awakingTaskData.taskId then 
        return true 
    end
    return false
end

function AwakingModel:updateAwakingTaskData(data)
    if not self._awakingTaskData then
        self._awakingTaskData = {}
    end
    for k, v in pairs(data) do
        self._awakingTaskData[k] = v 
    end
    self:reflashData()
end

function AwakingModel:onChangeAwakingTask(data)
    if not (data and data._carry_) then return end
    if data._carry_.awaking then
        self:updateAwakingTaskData(data._carry_.awaking)
        self._viewMgr:taskChangeTip()
    end
end

function AwakingModel:isCurrentAwakingTaskReach()
    if not self:isAwakingTaskOpened() then return false end
    local awakingTaskTableData = tab:AwakingTask(self._awakingTaskData["taskId"])
    if not awakingTaskTableData then return false end
    return self._awakingTaskData["value"] >= awakingTaskTableData["condition"][1], self._awakingTaskData["taskId"], self._awakingTaskData["value"], awakingTaskTableData["condition"]
end

function AwakingModel:getCurrentAwakingTaskId()
    if not self:isAwakingTaskOpened() then return 0 end
    local awakingTaskTableData = tab:AwakingTask(self._awakingTaskData["taskId"])
    if not awakingTaskTableData then return 0 end
    return self._awakingTaskData["taskId"]
end

function AwakingModel:getCurrentAwakingTeamId()
    if not self:isAwakingTaskOpened() then return 0 end
    local awakingTaskTableData = tab:AwakingTask(self._awakingTaskData["taskId"])
    if not awakingTaskTableData then return 0 end
    return self._awakingTaskData["teamId"]
end

-- 矮人 201
function AwakingModel:getAwakingTaskAirenCondition()
    if not self:isAwakingTaskOpened() then return nil end
    local taskId = self:getCurrentAwakingTaskId()
    if 0 == taskId then return nil end
    local awakingTaskTableData = tab:AwakingTask(taskId)
    if awakingTaskTableData and 201 == awakingTaskTableData["conditiontype"] then
        return true
    end
    return false
end

-- 阴森墓穴 202
function AwakingModel:getAwakingTaskZombieCondition()
    if not self:isAwakingTaskOpened() then return nil end
    local taskId = self:getCurrentAwakingTaskId()
    if 0 == taskId then return nil end
    local awakingTaskTableData = tab:AwakingTask(taskId)
    if awakingTaskTableData and 202 == awakingTaskTableData["conditiontype"] then
        return true
    end
    return false
end

-- 龙之国 203
function AwakingModel:getAwakingTaskDragonCondition()
    if not self:isAwakingTaskOpened() then return nil end
    local taskId = self:getCurrentAwakingTaskId()
    if 0 == taskId then return nil end
    local awakingTaskTableData = tab:AwakingTask(taskId)
    if not (awakingTaskTableData and (203 == awakingTaskTableData["conditiontype"] or 204 == awakingTaskTableData["conditiontype"])) then return nil end
    if not (awakingTaskTableData and awakingTaskTableData["condition"]) then return nil end
    return awakingTaskTableData["condition"][2] ,203 == awakingTaskTableData["conditiontype"]
end

function AwakingModel:getAwakingTaskDungeonReward(dungeonId)
    if not self:isAwakingTaskOpened() then return nil end
    local awakingTaskTableData = tab:AwakingTask(self._awakingTaskData["taskId"])
    if not (awakingTaskTableData and awakingTaskTableData["dungeon"]) then return nil end
    for k, v in ipairs(awakingTaskTableData["dungeon"]) do
        if v[1] == dungeonId then
            return v
        end
    end
    return nil
end

return AwakingModel