--[[
    Filename:    CrusadeModel.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-11-23 10:13:30
    Description: File description
--]]

local CrusadeModel = class("CrusadeModel", BaseModel)

function CrusadeModel:ctor()
    CrusadeModel.super.ctor(self)
end

function CrusadeModel:getData()
    return self._data
end

-- 子类覆盖此方法来存储数据
function CrusadeModel:setData(data)
	local event = data["event"]
	local box = data["box"]
	local fighting = data["fighting"]


	local sysCrusadeMain = tab.crusadeMain
	local tempData = {}
	for k,v in pairs(sysCrusadeMain) do
		if v.type == 1 then 
			tempData[k] = fighting[tostring(k)]
		elseif v.type == 2 then  
			tempData[k] = event[tostring(k)]
		elseif v.type == 3 then 
			tempData[k] = box[tostring(k)] 
		end
	end

	data.crusadeData = tempData
	-- data.crusade.crusadeData = tempData
	-- data.crusade = nil
	-- if data.reSetNum == nil then 
	-- 	data.reSetNum = 0
	-- end

	if data.playEffect == nil then 
		data.playEffect = 0
	end

	if data.usePcs == nil then 
		data.usePcs = 0 
	end 
	if data.needPcs == nil then 
		data.needPcs = 0 
	end

	if data.unusePcs == nil then 
		data.unusePcs = 0 
	end	
	
	if data.lastResetTime == nil then 
		data.lastResetTime = 0
	end


	if data.pcsPosition == nil then 
		data.pcsPosition = {}
	end

    if data.resetLimit == nil then 
        data.resetLimit = 0
    end
	-- 是否第一次进入远征，如果无值则不是
	if data.isFirst == nil then 
		data.isFirst = 0
	end
	self._data = data
	self:updateLastCrusade()
end

function CrusadeModel:updateCrusadeData(inCrusade)
	local function updateSubData(inSubData, inUpData)
		if type(inSubData) == "table" then
			for k,v in pairs(inUpData) do
				local backData = updateSubData(inSubData[k], v)
				inSubData[k] = backData
			end
			return inSubData
		else 
			return inUpData
		end

	end
	for k,v in pairs(inCrusade) do
		local backData = updateSubData(self._data[k], v)
		self._data[k] = backData
	end
	self:updateLastCrusade()
	self:reflashData()
end 


function CrusadeModel:updateLastCrusade()
    if self._data.lastCrusade == nil  then 
		self._data.lastCrusade = 0
	end
	local tempIndex = 0
	local sysCrusadeMain = tab.crusadeMain
	for k,v in pairs(sysCrusadeMain) do
		if self._data.lastCrusade == v.id then 
			tempIndex = k
			break
		end
	end
	if sysCrusadeMain[tempIndex+1] ~= nil then 
		self._data.activeCrusadeId = sysCrusadeMain[tempIndex+1].id
	else
		self._data.activeCrusadeId = self._data.lastCrusade
	end
end

-- function CrusadeModel:updateReSetTime()
-- 	-- if self._data.reSetNum > 0 then
-- 	-- 	local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
-- 	-- 	local lastResetTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(self._data.lastResetTime,"%Y-%m-%d 05:00:00"))
-- 	-- 	local tempTodayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
-- 	-- 	if curServerTime >= tempTodayTime then
-- 	-- 	    if tempTodayTime > lastResetTime then 
-- 	-- 	        self._data.reSetNum = 0
-- 	-- 	    end
-- 	-- 	end
-- 	-- end

-- end


function CrusadeModel:getLastReSetNum()
	local reSetNum = self._modelMgr:getModel("PlayerTodayModel"):getData().day8
    local vipInfo = self._modelMgr:getModel("VipModel"):getData()
    local sysVip = tab:Vip(vipInfo.level)
    local userModel = self._modelMgr:getModel("UserModel")
    if userModel:getData().resetCrusadeCD == nil then 
        userModel:getData().resetCrusadeCD = 0
    end
    -- print("&&&&&&&&",userModel:getCurServerTime(), userModel:getData().resetCrusadeCD)
    if userModel:getCurServerTime() < userModel:getData().resetCrusadeCD then 
        return 0
    end
    return (sysVip.crusadeTimes - reSetNum)
end

--[[
--! @function setEnemyData
--! @desc 设置敌方数据提供给布阵临时存储数据
--！@param inData 怪兽数据
--! @return table
--]]
function CrusadeModel:setEnemyTeamData(inData)
    local tempData = {}
    for k,v in pairs(inData) do
        v.teamId = tonumber(k)
        tempData[tonumber(k)] = v
    end
    self._enemyData = tempData
end


function CrusadeModel:getEnemyTeamDataById(inTeamId)
    if self._enemyData == nil then 
        return nil
    end
    return self._enemyData[tonumber(inTeamId)]
end


--[[
--! @function setEnemyData
--! @desc 设置敌方数据提供给布阵临时存储数据
--！@param inData 怪兽数据
--! @return table
--]]
function CrusadeModel:setEnemyHeroData(inData)
    self._enemyHeroData = inData
end

function CrusadeModel:getEnemyHeroData()
    return self._enemyHeroData
end

function CrusadeModel:getResetData()  --wangyan
	return self._data["trigger"] or {}
end

--判断是否需要红点
function CrusadeModel:checkIsRedPoint()
	local lastTimes = self:getLastReSetNum()
	local usePcs = self._data["usePcs"]
	local needPcs = self._data["needPcs"]
	if lastTimes > 0 or self._data["usePcs"] == self._data["needPcs"] then
		return true
	else
		return false
	end
end

function CrusadeModel:setCurLastCrusade(inData)
	self._curLastCrusade = inData["lastCrusade"]
end

function CrusadeModel:checkSencondSweepState()
	local cData = self._data["crusadeData"]
	self._spRwd = {}   --小精灵关卡
	self._buff = {}    --buff关卡
	self._treasure = {} --宝藏碎片

	local sweepId = self._data["sweepId"] * 2
	local oneKeyId = self._data["oneKeyId"]
	local sysCrusadeMains = tab.crusadeMain
	for i=oneKeyId + 1, sweepId, 1 do
		local temp = sysCrusadeMains[i]
		local sysCruBuild = tab:CrusadeBuild(cData[i].buildId)
		if temp.type == CrusadeConst.CRUSADE_TYPE.EVENT then
		 	if sysCruBuild.type == CrusadeConst.CRUSADE_BUILDING_TYPE.REWARD then     --小精灵
			 	self:checkSweepSp(i)
			else
				if sysCruBuild.id ~= 6 then   --buff
					self:checkSweepBuff(i)
				else 
					self:checkSweepTreasure(i)  --宝藏
				end
			end
		end
	end

	dump(self._spRwd, "sp", 10)
	dump(self._buff, "_buff", 10)
	dump(self._treasure, "_treasure", 10)

	return self._spRwd, self._buff, self._treasure
end

function CrusadeModel:checkSweepSp(inId) 
	local cData = self._data["crusadeData"]
	--已购买次数
	local buyTimes = cData[inId]["buyTimes"] or 0

	--特权次数
	local privilModel = self._modelMgr:getModel("PrivilegesModel")
	local temp = PrivilegeUtils.privileg_ID.PRIVILEGENAME_15
	local priviNum = privilModel:getAbilityEffect(temp)  

	--免费次数
	local freeTimes = 0       
	for m,n in pairs(tab.crusadeEvent) do
        if n["cost"] == 0 and tonumber(m) < 20 then
            freeTimes = freeTimes + 1
        end
    end

    if buyTimes < priviNum + freeTimes then
    	self._spRwd[tonumber(inId)] = {}
    end
end

function CrusadeModel:checkSweepBuff(inId) 
	local cData = self._data["crusadeData"]
	if not inId or not cData[inId] then
		return
	end

	if cData[inId]["isFinish"] ~= 1 then
		self._buff[tonumber(inId)] = {}  
	end
end

function CrusadeModel:checkSweepTreasure(inId) 
	local cData = self._data["crusadeData"]
	if not inId or not cData[inId] then
		return
	end

    local usePcs = self._data["usePcs"]
    local needPcs = self._data["needPcs"]
    local unusePcs = self._data["unusePcs"]
    if (usePcs + unusePcs) == needPcs then 
	    self._data["playEffect"] = 1
	end

	if (usePcs + unusePcs) <= needPcs then
		self._treasure[tonumber(inId)] = {}
	end
end

--主界面pop提示
function CrusadeModel:getCrusadeQipaoOpen()
    local isOpen,_ = SystemUtils["enableCrusade"]()  --开启
    local isPass = true
    if self._data and self._data.lastCrusade then
    	isPass = self._data.activeCrusadeId == self._data.lastCrusade
    else
    	isPass = #tab.crusadeMain == self._curLastCrusade
    end

	local formationModel = self._modelMgr:getModel("FormationModel")
	local teamData = self._modelMgr:getModel("TeamModel"):getData() or {}
    local formationData = formationModel:getFormationDataByType(formationModel.kFormationTypeCrusade)
    local lastTimes = self:getLastReSetNum()

    if isOpen then
    	if lastTimes > 0 then
    		return true
    	end

    	if (formationData.filter and #formationData.filter <= 4 and #teamData > #formationData.filter) and not isPass then
			return true
		end
    end

    return false  
end


return CrusadeModel
