--[[
    Filename:    TaskServer.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-09-09 15:18:57
    Description: File description
--]]


local TaskServer = class("TaskServer", BaseServer)

function TaskServer:ctor()
    TaskServer.super.ctor(self)
    self._taskModel = self._modelMgr:getModel("TaskModel")
end

function TaskServer:onGetTask(result, error)
    --dump(result, "TaskServer:onGetTask", 5)
    if 0 ~= tonumber(error) then
        print("TaskServer:onChonGetTaskangeTask error", error)
        ViewManager:getInstance():onLuaError("TaskServer:onGetTask error:" .. error)
        return
    end
    self._taskModel:setData(result)
    self:callback(0 == tonumber(error))
end

function TaskServer:onChangeTask(result, error)
    --[[
    -- dump(result, "onChangeTask", 5)
    if 0 ~= tonumber(error) then
        print("TaskServer:onChangeTask error", error)
        ViewManager:getInstance():onLuaError("TaskServer:onChangeTask error:" .. error)
    end
    if not (result and result.task) then return end
    self._taskModel:onChangeTask(result, 0 == tonumber(error))
    ]]
end

function TaskServer:onMainTaskReward(result, error)
    --dump(0, result, "TaskServer:onMainTaskReward")
    if 0 ~= tonumber(error) then
        print("TaskServer:onMainTaskReward error", error)
        --ViewManager:getInstance():onLuaError("TaskServer:onMainTaskReward error:" .. error)
    end
    if result and result["d"] then 
        self._taskModel:updateMainTaskData(result["d"], 0 == tonumber(error))
        self:callback(0 == tonumber(error), result["d"])
    else
        self:callback(0 == tonumber(error))
    end
end

function TaskServer:onDetailTaskReward(result, error)
    dump(result, "TaskServer:onDetailTaskReward", 5)
    if 0 ~= tonumber(error) then
        print("TaskServer:onDetailTaskReward error", error)
        --ViewManager:getInstance():onLuaError("TaskServer:onDetailTaskReward error:" .. error)
    end
    if result and result["d"] and result["d"]["sign"] then
        self._modelMgr:getModel("SignModel"):updateData(result["d"]["sign"])
    end
    if result and result["d"] then 
        self._taskModel:updateDetailTaskData(result["d"], 0 == tonumber(error))
        self:callback(0 == tonumber(error), result)
    else
        self:callback(0 == tonumber(error))
    end
end

function TaskServer:onReceiveGrowReward(result, error)
    --dump(result, "TaskServer:onReceiveGrowReward")
    if 0 ~= tonumber(error) then
        print("TaskServer:onReceiveGrowReward error", error)
        ViewManager:getInstance():onLuaError("TaskServer:onReceiveGrowReward error:" .. error)
    end
    if result and result["d"] then 
        self._taskModel:updateMainTaskGrowData(result["d"], 0 == tonumber(error))
    end
    self:callback(result, 0 == tonumber(error))
end

function TaskServer:onReceiveActiveReward(result, error)
    --dump(result, "TaskServer:onReceiveActiveReward")
    if 0 ~= tonumber(error) then
        print("TaskServer:onReceiveActiveReward error", error)
        ViewManager:getInstance():onLuaError("TaskServer:onReceiveActiveReward error:" .. error)
    end
    if result and result["d"] then 
        self._taskModel:updateDetailTaskActiveData(result["d"], 0 == tonumber(error))
    end
    self:callback(result, 0 == tonumber(error))
end


function TaskServer:onWeekTaskReward(result, error)
    dump(result, "TaskServer:onWeeklyTaskReward", 5)
    if 0 ~= tonumber(error) then
        print("TaskServer:onDetailTaskReward error", error)
        --ViewManager:getInstance():onLuaError("TaskServer:onDetailTaskReward error:" .. error)
    end
    if result and result["d"] and result["d"]["sign"] then
        self._modelMgr:getModel("SignModel"):updateData(result["d"]["sign"])
    end
    if result and result["d"] then 
        self._taskModel:updateWeeklyTaskData(result["d"], 0 == tonumber(error))
        self:callback(0 == tonumber(error), result)
    else
        self:callback(0 == tonumber(error))
    end
end

function TaskServer:onReceiveWeekActiveReward(result, error)
    --dump(result, "TaskServer:onReceiveWeeklyActiveReward")
    if 0 ~= tonumber(error) then
        print("TaskServer:onReceiveActiveReward error", error)
        ViewManager:getInstance():onLuaError("TaskServer:onReceiveActiveReward error:" .. error)
    end
    if result and result["d"] then 
        self._taskModel:updateWeeklyTaskActiveData(result["d"], 0 == tonumber(error))
    end
    self:callback(result, 0 == tonumber(error))
end
return TaskServer