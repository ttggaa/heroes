--[[
    Filename:    ActivityLevelFeedBackModel.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-03-23 13:17:06
    Description: File description
--]]

local ActivityLevelFeedBackModel = class("ActivityLevelFeedBackModel", BaseModel)

function ActivityLevelFeedBackModel:ctor()
    ActivityLevelFeedBackModel.super.ctor(self)
    self._data = {}
    self._data.isFinish = 0
end

function ActivityLevelFeedBackModel:setData(data)
    self._data = data
end

function ActivityLevelFeedBackModel:getData()
    return self._data
end

function ActivityLevelFeedBackModel:getTimeOut()
    local userModel = self._modelMgr:getModel("UserModel")
    local userInfo = userModel:getData()

    local firstReshTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(userInfo._it,"%Y-%m-%d 05:00:00"))
    local createTime = userInfo._it
    local subTime = createTime - firstReshTime
    local leftDay = 7
    if subTime < 0 then
        leftDay = 6
    end
    self._data.timeOut = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(userInfo._it + (86400 * leftDay),"%Y-%m-%d 05:00:00"))
    -- print("self._data.timeOut===", self._data.timeOut, userInfo._it)
end

function ActivityLevelFeedBackModel:updateData(data, isFinish)
    -- self._data.timeOut = userInfo._it + 86400 * 7 
    if isFinish ~= nil then 
        self._data.isFinish = isFinish
    end
    if data == nil then 
        return
    end
    for k,v in pairs(data) do
        self._data[k] = v
    end
end

function ActivityLevelFeedBackModel:isLevelFBTip()
    local userModel = self._modelMgr:getModel("UserModel")
    -- userModel:getData().lvl
    local keys = {}
    for k,v in pairs(tab.activity903) do
        table.insert(keys, k)
    end
    table.sort(keys)
    local showTip = false
    for k,v in pairs(keys) do
        if userModel:getData().lvl >= v and 
            self:getData()[tostring(v)] == nil then 
            showTip = true
        end
    end
    return showTip
end

return ActivityLevelFeedBackModel
