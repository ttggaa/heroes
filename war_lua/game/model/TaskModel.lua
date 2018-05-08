--[[
    Filename:    TaskModel.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-09-09 15:00:19
    Description: File description
--]]

local TaskModel = class("TaskModel", BaseModel)
local TaskItemView = require("game.view.task.TaskItemView")

function TaskModel:ctor()
    TaskModel.super.ctor(self)
    self._data = {
        task = {
            mainTasks = {},
            detailTasks = {},
        },

        grow = {
            val = 0,
            receive = 0,
        },

        active = {
            recordTime = 0,
            reward1 = 0,
            reward2 = 0,
            reward3 = 0,
            val = 0,
        },
    }
    self._isFirstIn = true -- 是否是第一次进入任务界面
    self._modelMgr = ModelManager:getInstance()
    self._userModel = self._modelMgr:getModel("UserModel")
    self._vipModel = self._modelMgr:getModel("VipModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._formationModel = self._modelMgr:getModel("FormationModel")
    self._awakingModel = self._modelMgr:getModel("AwakingModel")
    self:listenGlobalResponse(specialize(self.onChangeTask, self))
    self:registerTaskTimer()
    self._tableGrowAwardData = tab.growAward
end

function TaskModel:isNeedRequest()
    --PCLuaLogDump(self._data, "taskData", 5)
    if not self._cached then
        self._cached = true
        return true
    end
    local taskTableData = tab.task
    local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local currentTime = TimeUtils.getDateString(curServerTime, "*t")
    --[[
    if self._lastCheckTime.hour < 5 and currentTime.hour >= 5 then
        print("update yes")
        return true
    elseif self._lastCheckTime.hour >= 5 and currentTime.day ~= self._lastCheckTime.day and currentTime.hour >= 5 then
        print("update yes")
        return true
    end
    self._lastCheckTime = currentTime
    ]]
    local currentHour = currentTime.hour
    for k, v in pairs(taskTableData) do
        if v.conditiontype == 999 then
            local hide = false
            for kk, vv in pairs(v.hid) do
                local time1 = string.split(vv[1], ':')
                local time2 = string.split(vv[2], ':')
                if currentHour >= tonumber(time1[1]) and currentHour < tonumber(time2[1]) then
                    hide = true
                    if self._data.task.detailTasks[tostring(k)] then
                        print("hide yes")
                        return true
                    end
                end
            end
            if not hide and not self._data.task.detailTasks[tostring(k)] then
                print("show yes")
                return true
            end

            local open = false
            local time1 = string.split(v.condition[1], ':')
            local time2 = string.split(v.condition[2], ':')
            if currentHour >= tonumber(time1[1]) and currentHour < tonumber(time2[1]) then
                open = true
                if not self._data.task.detailTasks[tostring(k)] or 1 ~= self._data.task.detailTasks[tostring(k)].status then
                    print("open yes")
                    return true
                end
            end
            if not open and self._data.task.detailTasks[tostring(k)] and 1 == self._data.task.detailTasks[tostring(k)].status then
                print("close yes")
                return true
            end
        end
    end
    print("no")
    return false
    --[[
    if not self._cached then
        self._cached = {}
        self._cached.updateCache = function()
            self._cached.lvl = self._userModel:getData().lvl
            self._cached.weekCard = self._vipModel:getData().weekCard and self._vipModel:getData().weekCard or 0
            self._cached.monthCard = self._vipModel:getData().monthCard and self._vipModel:getData().monthCard or 0
        end
        self._cached.updateCache()
        return true
    end
    local lvl = self._userModel:getData().lvl
    if lvl ~= self._cached.lvl then
        self._cached.updateCache()
        return true 
    end
    local weekCard = self._vipModel:getData().weekCard and self._vipModel:getData().weekCard or 0
    if weekCard ~= self._cached.weekCard then 
        self._cached.updateCache()
        return true 
    end
    local monthCard = self._vipModel:getData().mondCard and self._vipModel:getData().mondCard or 0
    if monthCard ~= self._cached.monthCard then 
        self._cached.updateCache()
        return true 
    end
    local taskTableData = tab.task
    local currentTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local currentHour = os.date("*t", currentTime).hour
    for k, v in pairs(taskTableData) do
        if v.conditiontype == 999 then
            for kk, vv in pairs(v.hid) do
                local time1 = string.split(vv[1], ':')
                local time2 = string.split(vv[2], ':')
                if (currentHour >= tonumber(time1[1]) and currentHour <= tonumber(time2[1]) and self._data.task.detailTasks[tostring(k)]) then
                    return true
                end
            end
            if not self._data.task.detailTasks[tostring(k)] then
                return true
            end
        end
    end
    return false
    ]]
end

function TaskModel:checkData()
    if not self._data then
        self._data = {
            task = {
                mainTasks = {},
                detailTasks = {},
            },

            grow = {
                val = 0,
                receive = 0,
            },

            active = {
                recordTime = 0,
                reward1 = 0,
                reward2 = 0,
                reward3 = 0,
                val = 0,
            },
        }
    elseif not self._data.task then
        self._data.task = {
            mainTasks = {},
            detailTasks = {},
        }
    elseif not self._data.task.mainTasks then
        self._data.task.mainTasks = {}
    elseif not self._data.task.detailTasks then
        self._data.task.detailTasks = {}
    end

    if not self._data.grow then
        self._data.grow = {
            val = 0,
            receive = 0,
        }
    elseif not self._data.grow.val then
        self._data.grow.val = 0
    elseif not self._data.grow.receive then
        self._data.grow.receive = 0
    end

    if not self._data.active then
        self._data.active = {
            recordTime = 0,
            reward1 = 0,
            reward2 = 0,
            reward3 = 0,
            val = 0,
        }
    elseif not self._data.active.recordTime then
        self._data.active.recordTime = 0
    elseif not self._data.active.val then
        self._data.active.val = 0
    else
        for i=1, 3 do
            if not self._data.active["reward" .. i] then
                self._data.active["reward" .. i] = 0
            end
        end
    end
end

function TaskModel:setData(data)
    -- dump(data, "TaskModel", 5)
    self._data = data
    self:checkData()
    self._cached = true
    --self._lastCheckTime = os.date("*t", self._modelMgr:getModel("UserModel"):getCurServerTime())
    self._tableGrowAwardData = self._tableGrowAwardData or tab.growAward
    self:reflashData()
end

function TaskModel:registerTaskTimer()
    local registerTab = {}
    registerTab[5 .. ":" .. 0 .. ":" .. 0] = true
    local taskTableData = tab.task
    for k, v in pairs(taskTableData) do
        if v.conditiontype == 999 then
            for kk, vv in pairs(v.hid) do
                local time1 = string.split(vv[1], ':')
                local time2 = string.split(vv[2], ':')
                registerTab[time1[1] .. ":" .. time1[2] .. ":" .. 0] = true
                registerTab[time2[1] .. ":" .. time2[2] .. ":" .. 0] = true
            end
            local time1 = string.split(v.condition[1], ':')
            local time2 = string.split(v.condition[2], ':')
            registerTab[time1[1] .. ":" .. time1[2] .. ":" .. 0] = true
            registerTab[time2[1] .. ":" .. time2[2] .. ":" .. 0] = true
        end
    end
    for time, _ in pairs(registerTab) do
        local list = string.split(time, ":")
        self:registerTimer(tonumber(list[1]), tonumber(list[2]), tonumber(list[3]), specialize(self.setOutOfDate, self))
    end
end

function TaskModel:setOutOfDate()
    self._cached = false
    self._serverMgr:sendMsg("TaskServer", "getTask", {}, true, {}, function(success)
    end)
end

function TaskModel:onChangeTask(data)
    if not (data and data._carry_) then return end
    if data._carry_.task and data._carry_.task.mainTasks then
        table.merge(self._data.task.mainTasks, data._carry_.task.mainTasks)
    end

    if data._carry_.task and data._carry_.task.detailTasks then
        table.merge(self._data.task.detailTasks, data._carry_.task.detailTasks)
    end
    self:reflashData()
end

function TaskModel:updateReward(taskData)
    dump(taskData, "updateReward")
    if taskData.items then
        self._itemModel:updateItems(taskData.items)
        taskData.items = nil
    end

    if taskData.formations then
        self._formationModel:updateAllFormationData(taskData.formations)
        taskData.formations = nil
    end

    if taskData.adventure then
        self._modelMgr:getModel("AdventureModel"):updateAdventure(taskData.adventure)
        taskData.adventure = nil
    end

    self._userModel:updateUserData(taskData)
end

function TaskModel:updateMainTaskData(taskData, success)
    if not success then return end
    if taskData.grow and taskData.grow.val then
        self._data.grow.val = taskData.grow.val
    end
    taskData.grow = nil
    for k, v in pairs(taskData.task.mainTasks) do
        if 0 ~= v.status and 1 ~= v.status then
            self._data.task.mainTasks[k] = nil
        else
            self._data.task.mainTasks[k] = v
        end
    end
    taskData.task = nil
    self:updateReward(taskData)
    --[[
    local userInfo = { 
        freeGem = taskData.freeGem,
        freeGemTotal = taskData.freeGemTotal,
        gold = taskData.gold
    }
    self._userModel:updateUserData(userInfo)

    if taskData.items then
        self._itemModel:updateItems(taskData.items)
    end
    ]]
end

function TaskModel:updateMainTaskGrowData(growData, success)
    if not success then return end
    self._data.grow.receive = growData.grow.receive
    growData.grow = nil
    self:updateReward(growData)
    --[[
    local userInfo = { 
        freeGem = growData.freeGem,
        freeGemTotal = growData.freeGemTotal,
        gold = growData.gold
    }
    self._userModel:updateUserData(userInfo)

    if growData.items then
        self._itemModel:updateItems(growData.items)
    end
    ]]
end

function TaskModel:updateDetailTaskData(taskData, success)
    if not success then return end
    if taskData.active and taskData.active.val then
        self._data.active.val = taskData.active.val
    end
    taskData.active = nil
    for k, v in pairs(taskData.task.detailTasks) do
        if not self._data.task.detailTasks[k] then
            self._data.task.detailTasks[k] = {}
        end
        for kk, vv in pairs(v) do
            self._data.task.detailTasks[k][kk] = vv
        end
    end
    taskData.task = nil
    self:updateReward(taskData)
    --[[
    local userInfo = { 
        freeGem = taskData.freeGem,
        freeGemTotal = taskData.freeGemTotal,
        gold = taskData.gold
    }
    self._userModel:updateUserData(userInfo)

    if taskData.items then
        self._itemModel:updateItems(taskData.items)
    end
    ]]
end

function TaskModel:updateDetailTaskActiveData(activeData, success)
    if not success then return end
    for k, v in pairs(activeData.active) do
        self._data.active[k] = v
    end
    activeData.active = nil
    self:updateReward(activeData)
    --[[
    local userInfo = { 
        freeGem = activeData.freeGem,
        freeGemTotal = activeData.freeGemTotal,
        gold = activeData.gold
    }
    self._userModel:updateUserData(userInfo)

    if activeData.items then
        self._itemModel:updateItems(activeData.items)
    end
    ]]
end

function TaskModel:getData()
    return self._data
end

function TaskModel:isSpecialTreasureTaskOpen(taskId)
    if not (taskId >= 9940 and taskId <= 9943) then return true end
    local openServerTime = self._userModel:getOpenServerTime()
    local day = math.floor(openServerTime / 86400)
    return day >= 17
end


function TaskModel:hasTaskCanGet()
    if not (self._data and self._data.task) then return end
    if self._data.task.mainTasks then
        for k, v in pairs(self._data.task.mainTasks) do
            repeat
                if not self:isSpecialTreasureTaskOpen(tonumber(k)) then break end
                if 1 == v.status then
                    return true
                end
            until true
        end
    end

    if self._data.task.detailTasks then
        for k, v in pairs(self._data.task.detailTasks) do
            if 1 == v.status and --[[过滤大富翁任务]](tonumber(k) < 20000 or tonumber(k) > 20006)  then
                return true
            end
        end
    end

    local currentGrow = 0
    if self._data.grow and self._data.grow.val then
        currentGrow = self._data.grow.val
    end
    local index = 1
    if self._data.grow and self._data.grow.receive then
        index = self._data.grow.receive + 1
    end
    local currentMaxGrow = self._tableGrowAwardData[index].grow
    local percent = math.min(1, currentGrow / currentMaxGrow)
    if percent >= 1 then
        return true
    end

    if self._data.active and self._data.active.val then
        local activeConfig = {50, 100, 200}
        for i = 1, 3 do
            if self._data.active["reward" .. i] then
                if 0 == self._data.active["reward" .. i] and self._data.active.val >= activeConfig[i] then
                    return true
                end
            end
        end
    end

    if self._awakingModel:isCurrentAwakingTaskReach() then
        return true
    end


    return false
end

function TaskModel:hasTaskCanGetByType(taskType)
    if taskType == TaskItemView.kViewTypeItemPrimary then
        if self._data.task.mainTasks then
            for k, v in pairs(self._data.task.mainTasks) do
                repeat
                    if not self:isSpecialTreasureTaskOpen(tonumber(k)) then break end
                    if 1 == v.status then
                        return true
                    end
                until true
            end
        end
        local currentGrow = 0
        if self._data.grow and self._data.grow.val then
            currentGrow = self._data.grow.val
        end
        local index = 1
        if self._data.grow and self._data.grow.receive then
            index = self._data.grow.receive + 1
        end
        local currentMaxGrow = self._tableGrowAwardData[index].grow
        local percent = math.min(1, currentGrow / currentMaxGrow)
        return (percent >= 1)
    elseif taskType == TaskItemView.kViewTypeItemEveryday then
        if self._data.task.detailTasks then
            for k, v in pairs(self._data.task.detailTasks) do
                if 1 == v.status and --[[过滤大富翁任务]](tonumber(k) < 20000 or tonumber(k) > 20006) then
                    return true
                end
            end
        end
        if self._data.active and self._data.active.val then
            local activeConfig = {50, 100, 200}
            for i = 1, 3 do
                if self._data.active["reward" .. i] then
                    if 0 == self._data.active["reward" .. i] and self._data.active.val >= activeConfig[i] then
                        return true
                    end
                end
            end
        end
        return false
    end
end
-- 进入任务界面的状态 是否是第一次
function TaskModel:getTaskUIStatus()
    -- 获取上次进入时间
    if not self._UIlastInTime then
        self._UIlastInTime = SystemUtils.loadAccountLocalData("LAST_TASK_IN_TIME") or 0 
    end
    local currTime = self._userModel:getCurServerTime()
    -- 转化成当天五点
    local inTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(currTime,"%Y-%m-%d 05:00:00")) 
    if inTime > currTime then
        inTime = inTime - 86400
    end
    if inTime - self._UIlastInTime <= 0 then
        self._isFirstIn = false
    else
        self._isFirstIn = true
        self._UIlastInTime = inTime
        SystemUtils.saveAccountLocalData("LAST_TASK_IN_TIME", inTime)
    end
    -- if self._isFirstIn then 
    -- end

    return self._isFirstIn
end

function TaskModel:setTaskUIStatus(isFirst)
    self._isFirstIn = isFirst
end

function TaskModel.dtor()
    TaskItemView = nil
end

return TaskModel