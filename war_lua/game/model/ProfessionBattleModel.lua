-- author lannan

local ProfessionBattleModel = class("ProfessionBattleModel", BaseModel)

function ProfessionBattleModel:ctor()
    ProfessionBattleModel.super.ctor(self)
	self._data = {}
	self._weekData = {}
	self:onInit()
end

function ProfessionBattleModel:onInit()
	for i,v in pairs(tab.professionBattle) do
		for _,showWeek in ipairs(v.time) do
			if not self._weekData[showWeek] then
				self._weekData[showWeek] = {}
			end
			table.insert(self._weekData[showWeek], v)
		end
	end
	for i,v in pairs(self._weekData) do
		table.sort(v, function(a, b)
			return a.id<b.id
		end)
	end
end

function ProfessionBattleModel:setData(data)
	if data then
		self._data = data
	end
end

function ProfessionBattleModel:updateProfessionData(data)
    if not data then
        return
    end
    if type(data) == "table" then
        local m = nil
        m = function(a, b)
            for k, v in pairs(b) do
                if type(a[k]) == "table" and type(v) == "table" then
                    m(a[k], v)
                else
                    a[k] = v
                end
            end
        end
        m(self._data, data)
    end
    self:reflashData()
end

function ProfessionBattleModel:getData()
	return self._data
end

--获取关卡id获取关卡状态
function ProfessionBattleModel:getDataById(id)
	if self._data["barriers"] and self._data["barriers"][tostring(id)] then
		return self._data["barriers"][tostring(id)]
	end
	return nil
end

--根据日期获取当天完成了几关
function ProfessionBattleModel:getFinishiNumByWeek(week)
	local num = 0
	for i,v in ipairs(self._weekData[week]) do
		local indexKey = tostring(v.id)
		if self._data.barriers and self._data.barriers[indexKey] and tonumber(self._data.barriers[indexKey].win)==1 then
			num = num + 1
		end
	end
	return num
end

--获取当前周几
function ProfessionBattleModel:getCurWeekDay()
    local currTime = self._modelMgr:getModel("UserModel"):getCurServerTime() - 5*60*60
    local weekday = tonumber(TimeUtils.date("%w", currTime))
    if weekday == 0 then
        weekday = 7
    end
    return weekday
end

--获取当前日期的兵团类型
function ProfessionBattleModel:getCurWeekType(week)
	if self._weekData[week] then
		return self._weekData[week][1].subid
	end
end

--根据星期获取当天的关卡列表
function ProfessionBattleModel:getWeekList(week)
	return self._weekData[week]
end

function ProfessionBattleModel:getMaxTimes()
	local maxTimes = tab:Setting("ArmyTestNumberOfDaily").value
	--后期可能有活动会影响每日次数
	return maxTimes
end

function ProfessionBattleModel:getOpenState()
	local myLvl = self._modelMgr:getModel("UserModel"):getPlayerLevel()
	local openLevel = tab.systemOpen["ArmyTest"][1]
	local nowWeek = self:getCurWeekDay()
	
	local isLvlEnough = myLvl>=openLevel
	local isNotWeekend = nowWeek~=6 and nowWeek~=7
	return isLvlEnough, isNotWeekend
end

return ProfessionBattleModel