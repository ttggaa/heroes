--[[
    @FileName   ElementModel.lua
    @Authors    zhangtao
    @Date       2017-08-14 15:49:50
    @Email      <zhangtao@playcrad.com>
    @Description   描述
--]]
local ElementModel = class("ElementModel", BaseModel)

function ElementModel:ctor()
    ElementModel.super.ctor(self)
    self._data = {}
    self._openState = {}  --位面开启状态
    self._curFirstOrderInfo = {}  --当前位面前三名信息
    self._hasChallengeTimes = 0 
    self._elementData = {}
    self._crossData = {}
end

function ElementModel:setData(data)
    self._data = data

    self:reflashData()
end

function ElementModel:getData()
    return self._data
end
--位面元素开启状态
function ElementModel:getOpenState()
    for i = 1 , 5 do
        self._openState[i] =  self:planOrOpen(i)
    end
    return self._openState
end

--获取当前周几
function ElementModel:getCurWeekDay()
    local currTime = self._modelMgr:getModel("UserModel"):getCurServerTime() - 5*60*60
    local weekday = tonumber(TimeUtils.date("%w", currTime))
    if weekday == 0 then
        weekday = 7
    end
    return weekday
end
--位面是否开启
function ElementModel:planOrOpen(index)
    for k, v in pairs(self:getOpenList()[index]) do
        if tonumber(v) == tonumber(self:getCurWeekDay()) then
            return true
        end
    end
    return false
end

function ElementModel:setFirstOrderInfo(data)
    self._curFirstOrderInfo = data
    self:reflashData()
end

function ElementModel:getFirstOrderInfo()
    return self._curFirstOrderInfo
end

-- 获取所有位面剩余次数
function ElementModel:getChallengeTimes()
    local elementTimes = self:getAllElementTimes()
    local totalTimes = 0
    for index, isOpen in pairs(self:getOpenState()) do
        if isOpen then
            totalTimes = totalTimes + elementTimes[index]
        end
    end
    return totalTimes
end

function ElementModel:getAllElementTimes()
    local elementTimes = {}
    local maxTimes = self:getMaxChallengeTimes()
    local challengeTimes1 = self._modelMgr:getModel("PlayerTodayModel"):getData()["day62"] or 0
    local challengeTimes2 = self._modelMgr:getModel("PlayerTodayModel"):getData()["day63"] or 0
    local challengeTimes3 = self._modelMgr:getModel("PlayerTodayModel"):getData()["day64"] or 0
    local challengeTimes4 = self._modelMgr:getModel("PlayerTodayModel"):getData()["day65"] or 0
    local challengeTimes5 = self._modelMgr:getModel("PlayerTodayModel"):getData()["day66"] or 0
    table.insert(elementTimes,maxTimes - challengeTimes1)
    table.insert(elementTimes,maxTimes - challengeTimes2)
    table.insert(elementTimes,maxTimes - challengeTimes3)
    table.insert(elementTimes,maxTimes - challengeTimes4)
    table.insert(elementTimes,maxTimes - challengeTimes5)
    return elementTimes
end

function ElementModel:getMaxChallengeTimes()
    local maxTimes = tab:Setting("G_ELEMENTAL_TIMES").value
    -- 元素位面活动增加次数
    local activityModel = self._modelMgr:getModel("ActivityModel")
    local addTimes = activityModel:getAbilityEffect(activityModel.PrivilegIDs.PrivilegID_34) or 0
    maxTimes = maxTimes + addTimes
    return maxTimes
end

-- 判断指定位面双倍活动是否开启
function ElementModel:isActivityOpen(elementId)
    local activityModel = self._modelMgr:getModel("ActivityModel")
    local privilegIdTable = {
                                [1] = activityModel.PrivilegIDs.PrivilegID_35,
                                [2] = activityModel.PrivilegIDs.PrivilegID_36,
                                [3] = activityModel.PrivilegIDs.PrivilegID_37,
                                [4] = activityModel.PrivilegIDs.PrivilegID_39,
                                [5] = activityModel.PrivilegIDs.PrivilegID_38,
                            }
    return activityModel:getAbilityEffect(privilegIdTable[elementId]) > 0
end

-- 判断是否有开启双倍活动的位面
function ElementModel:checkIsOpenElement(elementId)

    -- for i = 1 , 5 do
    --     if self:isActivityOpen(i) then
    --         if self._openState[i] and self:getAllElementTimes()[i] > 0 then
    --             return true
    --         end
    --     end
    -- end
    -- return false
    if self:isActivityOpen(elementId) then 
        print("===self._openState[i]=====",self:planOrOpen(elementId))
        print("======self:getAllElementTimes()[i]========",self:getAllElementTimes()[elementId])
        if self:planOrOpen(elementId) and self:getAllElementTimes()[elementId] > 0 then
            return true
        end
    end
    return false
end
--获取开启
function ElementModel:getOpenList()
    local openList = {
                        tab:Setting("G_ELEMENTAL_TIME_1").value,
                        tab:Setting("G_ELEMENTAL_TIME_2").value,
                        tab:Setting("G_ELEMENTAL_TIME_3").value,
                        tab:Setting("G_ELEMENTAL_TIME_4").value,
                        tab:Setting("G_ELEMENTAL_TIME_5").value,
                    }
    return openList
end

-- 判断是否有挑战次数
function ElementModel:isHaveTimes()
    return self:getChallengeTimes() > 0 and true or false
end


--更新位面信息
function ElementModel:updateElementInfo(data)
    for k , v in pairs(data) do
        self._elementData[k] = v
    end
end

function ElementModel:getElementData()
    if next(self._elementData) == nil then
        self._userModel = self._modelMgr:getModel("UserModel")
        if self._userModel:getData()["element"] ~= nil then
            self._elementData = self._userModel:getData()["element"]
        else
            self._elementData = {}
        end
    end
    return self._elementData
end

--通关后的数据
function ElementModel:setCrossData(data)
    self._crossData = data
end
function ElementModel:getCrossData()
    return self._crossData
end

return ElementModel