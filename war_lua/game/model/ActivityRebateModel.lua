--[[
    Filename:    ActivityRebateModel.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-03-09 19:49:26
    Description: File description
--]]


local ActivityRebateModel = class("ActivityRebateModel", BaseModel)

function ActivityRebateModel:ctor()
    ActivityRebateModel.super.ctor(self)
    self._activityModel = self._modelMgr:getModel("ActivityModel")
end

-- 获取每日折扣数据
function ActivityRebateModel:getACERebateShowList() 
    
    local showList = self._activityModel:getActivityShowList()
    local aCERebate = {}
    for k,v in pairs(showList) do
        if v.activity_id == 101 then
            if self._rebateData == nil then
                self._rebateData = {}
                self:updateACERebateAllPlayer(v.dailyDiscount) 
            end
            aCERebate = v
        end
    end
    return aCERebate
end

-- 更新全服已购买道具数量
function ActivityRebateModel:updateACERebateAllPlayer(data) 
    if not data then
        return
    end
    if self._rebateData == nil then
        self:getACERebateShowList()
    end
    if self._rebateData == nil then
        self._rebateData = {}
    end
    for k,v in pairs(data) do
        self._rebateData[tostring(k)] = v 
    end 
    self:reflashData()
end


-- 获取全服已购买道具数量
function ActivityRebateModel:getACERebateAllPlayer()   
    return self._rebateData
end

function ActivityRebateModel:setACERebateData(flag)
    self._rebateNum = flag
end

function ActivityRebateModel:isACERebateData()
    return self._rebateNum or false
end

return ActivityRebateModel