--[[
    Filename:    ActivitySevenDaysModel.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-03-23 13:19:13
    Description: File description
--]]

local ActivitySevenDaysModel = class("ActivitySevenDaysModel", BaseModel)

function ActivitySevenDaysModel:ctor()
    ActivitySevenDaysModel.super.ctor(self)
    self._data = {}
    self._data.isFinish = 0
end

function ActivitySevenDaysModel:setData(data)
	if data == nil then 
		return
	end
    self._data = data
end

function ActivitySevenDaysModel:getData()
    return self._data
end

function ActivitySevenDaysModel:updateLoginExt(inData)
    self._data.loginExt = inData
end


function ActivitySevenDaysModel:updateData(data, isFinish)
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

function ActivitySevenDaysModel:reflashMainView()
    self:reflashData()
end 


function ActivitySevenDaysModel:getShowDayAndState()
    local tipTextState = {1,2,2,1,1,1,2,2,1,1,1,1,1,1}
    local userInfo = self._modelMgr:getModel("UserModel"):getData()
    local loginDay = userInfo.statis.snum6 or 0
    if loginDay > 14 then 
        loginDay = 14
    end
    local showDay = 0
    local showTextState = 1

    local flag = 0 
    for i=1, 14 do
        if loginDay > i and self._data[tostring(i)] == nil then 
            flag =  1
        end
    end
    if flag == 0 then 
        -- 如果当前登录天数已经领取则展示下一天状态
        if self._data[tostring(loginDay)] ~= nil and loginDay ~= 14 then 
            showDay = loginDay + 1
            showTextState = tipTextState[showDay]
        elseif loginDay == 1 and self._data[tostring(loginDay)] == nil then 
            showDay = 1
            showTextState = tipTextState[showDay]
        end
    end
    -- 如果当前登录天数未领取则按顺序展现
    if showDay == 0 then 
        local showDayOrder = {2, 3, 7, 1, 4, 5, 6, 8, 9, 10, 11, 12, 13, 14}
        for k,v in pairs(showDayOrder) do
            if self._data[tostring(v)] == nil then 
                if loginDay >= v then 
                    showDay = v
                    showTextState = 1
                end
                if showDay ~= 0 then 
                    break
                end
            end
        end
    end
    return showDay, showTextState
end

function ActivitySevenDaysModel:isSevenDaysTip()
    local showDay, showTextState = self:getShowDayAndState()
    local userInfo = self._modelMgr:getModel("UserModel"):getData()
    local loginDay = userInfo.statis.snum6 or 0
    if loginDay >= showDay and self._data[tostring(showDay)] == nil and showTextState == 1 then 
        return true
    else
        return false
    end
end

return ActivitySevenDaysModel
