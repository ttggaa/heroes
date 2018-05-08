--[[
    Filename:    ActivityHalfMonthModel.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-04-12 10:34:41
    Description: File description
--]]


local ActivityHalfMonthModel = class("ActivityHalfMonthModel", BaseModel)

function ActivityHalfMonthModel:ctor()
    ActivityHalfMonthModel.super.ctor(self)
    self._data = {}
    self._data.isFinish = 0
end

function ActivityHalfMonthModel:setData(data)
	if data == nil then 
		return
	end
    self._data = data
end

function ActivityHalfMonthModel:getData()
    return self._data
end

function ActivityHalfMonthModel:updateData(data, isFinish)
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

function ActivityHalfMonthModel:reflashMainView()
    self:reflashData()
end 

function ActivityHalfMonthModel:isHalfMonthTip()
    local userInfo = self._modelMgr:getModel("UserModel"):getData()
    local loginDay = userInfo.statis.snum6 or 0
    for k,v in pairs(tab.activity904) do
        if loginDay >= k and self._data[tostring(k)] == nil then 
            return true
        end
    end
    return false
end

return ActivityHalfMonthModel
