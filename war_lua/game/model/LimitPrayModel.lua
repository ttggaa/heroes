--
-- Author: huangguofang
-- Date: 2018-08-01 15:18:27
--

local LimitPrayModel = class("LimitPrayModel", BaseModel)

function LimitPrayModel:ctor()
	LimitPrayModel.super.ctor(self)
	self._userModel = self._modelMgr:getModel("UserModel")
	self._acModel = self._modelMgr:getModel("ActivityModel")
	self._data = {}
end

-- --是否请求过数据
-- function LimitPrayModel:setIsReqedById(inState, inId)
-- 	if not self._data[inId] then
-- 		return
-- 	end

-- 	self._data[inId]["isReqed"] = inState
-- end

-- function LimitPrayModel:getIsReqedById(inId)
-- 	if not self._data[inId] then
-- 		return false
-- 	end

-- 	return self._data[inId]["isReqed"] or false
-- end
function LimitPrayModel:setDataById(inData, inId)	
	self._data[tonumber(inId)] = inData	
end

function LimitPrayModel:updateData(inData) 
	local updateSubData = nil
    updateSubData = function(a, b)
        for k, v in pairs(b) do
            if type(a[k]) == "table" and type(v) == "table" then
                updateSubData(a[k], v)
            else
                a[k] = v
            end
        end
    end
    if not self._data[self._openId] then 
        self._data[self._openId] = {}
    end
    updateSubData(self._data[self._openId],inData[tostring(self._openId)])
end


function LimitPrayModel:getDataById(inId)
	return self._data[inId] or {}
end
--[[
function LimitPrayModel:getRewardListById(inId)
	--获取宝箱奖励数据
    local boxRewards = {}

    for i,v in ipairs(tab.prayBox) do
    	if v["dynamic"] == inId then
    		table.insert(boxRewards, v)
    		boxRewards[#boxRewards]["index"] = i
    	end
    end
    table.sort(boxRewards, function(a,b) return a.index < b.index end)

    return boxRewards
end
]]

function LimitPrayModel:isOnceFreeById(inId)
	local acData = self._data[inId]
	if not acData then
		return false
	end

	local upFreeTime = acData["upFreeTime"] or 0
	local curTime = self._userModel:getCurServerTime()
	local time1 = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 05:00:00"))
	if curTime < time1 then   --过零点判断
		time1 = time1 - 86400
	end
	if upFreeTime < time1 then
		return true
	end

	return false
end

function LimitPrayModel:isHaveRedNotice(inId)
	local acData = self._data[inId]
	if not acData then
		return false
	end
    -- 首次未进红点
    local AC_LIMITPRAY_IN = SystemUtils.loadAccountLocalData("AC_LIMITPRAY_IN")
    if not AC_LIMITPRAY_IN then
        return true
    end
	if self:isOnceFreeById(inId) then
		return true
	end

	--有宝箱未领取
	local sysLimitTeamBox = clone(tab.prayBox)--self:getRewardListById(inId)
	for i=1, #sysLimitTeamBox do
		local curScore = acData["boxPt"] or 0
        local needScore = sysLimitTeamBox[i].score
        local rwdList = acData["rewardList"] or {}
        local sysIndex = sysLimitTeamBox[i]["id"]
        local isGet = rwdList[tostring(sysIndex)]
        -- print(isGet,"===========curScore,needScore=====",curScore,needScore)
        if curScore >= needScore and isGet ~= 1 then
        	return true
        end
	end

	return false
end

function LimitPrayModel:isActicityOpen()
	local showList = self._acModel:getActivityShowList()
    local currTime = self._userModel:getCurServerTime()
    local userData = self._userModel:getData()
    local isOpen = false
    for k,v in pairs(showList) do
        if v.ac_type == 43 then
            local vipLvl = v.vip_limit or 0
            local uVipLvl = self._modelMgr:getModel("VipModel"):getLevel() or 0
            local level_limit = v.level_limit or 0
            local userLvl = userData.lvl or 0
            local acAppearTime = v.appear_time or v.start_time or currTime
            local acDisappearTime = v.disappear_time or v.end_time or currTime
            -- print("=================vipLvluVipLvllevel_limituserLvl=======",vipLvl,uVipLvl,level_limit,userLvl)
            if next(v) 
                and acAppearTime <= currTime 
                and acDisappearTime > currTime 
                and level_limit <= userLvl
                and vipLvl <= uVipLvl
            then
                self._openId = v._id
    			self._acId = v.activity_id
                self._endTime = v.end_time
    			isOpen = true
            end
        end          
    end
    
    return isOpen
end

function LimitPrayModel:getCurrPrayId()
	return self._openId  ,self._acId
end
function LimitPrayModel:getAcEndTime( ... )
    return self._endTime or 0
end

function LimitPrayModel:setShopData(data)
    self._shopData = data
end
function LimitPrayModel:updateShopData(data)
    if not data then return end
    for k,v in pairs(data) do
        if self._shopData[k] then
            for kk,vv in pairs(v) do
                self._shopData[k][kk] = vv
            end
        end
    end
end
function LimitPrayModel:getShopData(data)
    return self._shopData
end

return LimitPrayModel