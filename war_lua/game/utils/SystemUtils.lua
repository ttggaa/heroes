--[[
    Filename:    SystemUtils.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-11-16 20:35:51
    Description: File description
--]]
local modelMgr
if ModelManager then
	modelMgr = ModelManager:getInstance()
end

local SystemUtils = {} 

local levelTab
local sTime
local eTime
local isInit = false
function SystemUtils.isInit()
	return isInit
end

function SystemUtils.init()
	isInit = true
	levelTab = {}
    sTime = 0
    eTime = 0
	local userModel = modelMgr:getModel("UserModel")
	for systemName, systemData in pairs(tab.systemOpen) do
        local level = systemData[1]
		levelTab[systemName] = level
		local name = systemName
		SystemUtils["enable" .. name] = function ()
			local level = userModel:getPlayerLevel()
			if level == nil then
				print("userModel:getPlayerLevel() == nil")
				return false
			end
			if levelTab[name] == nil then
				print("levelTab[name] == nil", name)
				return false
			end
			return level >= levelTab[name], level >= systemData[2], levelTab[name],systemData.systemOpenTip -- level >= levelTab[name] - 5
		end
	end

    for _, sTimeData in pairs(tab.sTimeOpen) do
        local name = sTimeData.system
        local openLevel = sTimeData.level
        local openTime = sTimeData.opentime
        local openHour = sTimeData.openhour
		SystemUtils["enable" .. name] = function ()
			local level = userModel:getPlayerLevel()
            local serverBeginTime = userModel:getData().sec_open_time or 0
            if serverBeginTime then
				local sec_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime,"%Y-%m-%d 05:00:00"))
				if serverBeginTime < sec_time then   --过零点判断
					serverBeginTime = sec_time - 86400
				end
			end
	        local serverHour = tonumber(TimeUtils.date("%H",serverBeginTime)) or 0
	        local nowTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
	        local openDay = openTime-1
	        local openHourStr = string.format("%02d:00:00",openHour)
	        local openTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime + openDay*86400,"%Y-%m-%d " .. openHourStr))

			if level == nil then
				print("userModel:getPlayerLevel() == nil")
				return false
			end
			if openLevel == nil then
				print("openLevel == nil", name)
				return false
			end
            if openTime == nil then
				print("openTime == nil", name)
				return false
			end
            if openHour == nil then
				print("openHour == nil", name)
				return false
			end
			return (level >= openLevel) and (nowTime >= openTime), nowTime >= openTime, openLevel,sTimeData.systemOpenTip
		end
	end
	-- dump(tab.systemOpen)
end

-- 客户端全局本地存储
function SystemUtils.saveGlobalLocalData(key, data)
    UserDefault:setStringForKey("global_" .. key, serialize(data))
end

function SystemUtils.loadGlobalLocalData(key)
    return unserialize(UserDefault:getStringForKey("global_" .. key, ""))
end

-- 客户端角色本地存储, 只有登录之后才可以用
function SystemUtils.saveAccountLocalData(key, data)
	local uuid = modelMgr:getModel("UserModel"):getUUID()
	if uuid then
    	UserDefault:setStringForKey(uuid .. "_" .. key, serialize(data))
    end
end

function SystemUtils.loadAccountLocalData(key)
	local uuid = modelMgr:getModel("UserModel"):getUUID()
	if uuid then
    	return unserialize(UserDefault:getStringForKey(uuid .. "_" .. key, ""))
    else
    	return nil
    end
end

function SystemUtils.getTotalTextureMBytes()
	return cc.Director:getInstance():getTextureCache():getTotalTextureBytes() / 1024 / 1024
end

function getChildrenCount(root)
	local count = 1
	for i = 1, #root:getChildren() do
		count = count + getChildrenCount(root:getChildren()[i])
	end
	return count 
end

function SystemUtils.getAllNodeCount()
	print(getChildrenCount(ViewManager:getInstance():getRootLayer()))
end

function SystemUtils.applicationDidEnterBackground()
    local userModel = modelMgr:getModel("UserModel")
    sTime = userModel:getCurServerTime()
end

function SystemUtils.applicationWillEnterForeground()
    local userModel = modelMgr:getModel("UserModel")
    eTime = userModel:getCurServerTime()
end

function SystemUtils.isNeedLogin()
    if not sTime or not eTime or 0 == sTime or 0 == eTime then return false end
    local currentTime = os.date("*t", eTime)
    local lastTime = os.date("*t", sTime)
    if lastTime.hour < 5 and currentTime.hour >= 5 then
        return true
    elseif lastTime.hour >= 5 and currentTime.day ~= lastTime.day and currentTime.hour >= 5 then
        return true
    end
    return false
end

function SystemUtils.dtor()
	levelTab = nil
    sTime = nil
    eTime = nil
	modelMgr = nil
	SystemUtils = nil
end

return SystemUtils

