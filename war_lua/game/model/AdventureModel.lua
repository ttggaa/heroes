--[[
    Filename:    AdventureModel.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-09-22 15:59
    Description: 大冒险
--]]

local AdventureModel = class("AdventureModel", BaseModel)

function AdventureModel:ctor()
    AdventureModel.super.ctor(self)
    self._data = {}
    self._preData = {} -- 记录之前的状态
    self._passedGrids = {[1]=true} -- 走过格子 初始化第一格肯定是走过的
end

function AdventureModel:setData(data)
    self._data = data
    self._preData = clone(data)
    self:updatePassedGrids()
    self:reflashData()
end

function AdventureModel:getData()
    return self._data
end

function AdventureModel:resetData( )
    self._data.grid = 1
end

-- 在重置时间内
function AdventureModel:inResetTime( )
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local reflashRestTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime,"%Y-%m-%d 04:59:59"))
    local reflashRestEndTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime,"%Y-%m-%d 05:00:12"))
    if nowTime > reflashRestTime and nowTime < reflashRestEndTime then
        self._viewMgr:showTip("小骷髅正在准备开启新的冒险，还请耐心等待一会哦~")
        return true
    end
end

-- 判断有没有重置
function AdventureModel:isAllReadyReset( )
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local lastResetTime = self._data.lot
    local checkTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime,"%Y-%m-%d 05:00:00"))
    if lastResetTime > checkTime  then
        return true
    else
        return false
    end
end
-- 获得当前位置
function AdventureModel:getCurGridId( )
	return self._data.gid or 1
end

-- 获得圈数
function AdventureModel:getRoundNum( )
	return self._data.rn or 0
end

-- 获得色子数目
function AdventureModel:getHadDiceNum()
	return (self._data.dn or 0)
end

-- 获得藏宝图状态
function AdventureModel:isTreasureMapOpen( )
    return self._data.tmo and self._data.tmo ~= 0
end

-- 获得魔盒状态
function AdventureModel:getMagicBoxStatus( )
	return self._data.po and self._data.po ~= 0--,self._data.pn or 0
end

-- 判断是不是刚开启
function AdventureModel:isMagicBoxOpening( )
    return self._data.po~=0 and self._data.po ~= self._preData.po
end

-- 判断是不是刚关闭
function AdventureModel:isMagicBoxClosing( )
    return self._data.po~=1 and self._data.po ~= self._preData.po
end

-- 魔井的状态
function AdventureModel:getMagicWellStatus( )
    return self._data.mw or 1
end

-- 魔井状态变化
function AdventureModel:isMagicWellStatusChanged( )
    return self._data.mw ~= self._preData.mw
end

-- 获得剩余时间
function AdventureModel:getRestTime( )
    return self._data.resTime
end

-- 宝箱状态 0 不满足条件 1 可领取 2 已领取
function AdventureModel:hadBoxGeted( boxId )
	if self:getRoundNum() >= boxId then
		if not self._data.bid[tostring(boxId)] or self._data.bid[tostring(boxId)] == 0 then
			return 1
		else
			return 2
		end
	else
		return 0
	end
end

-- 获得魔盒九个怪之后奖励
function AdventureModel:getPanRwd( )
    return self._data.panRwd 
end

-- 更新走过的格子
function AdventureModel:updatePassedGrids()
    self._passedGrids = {}
    local temp = string.split(self._data.pgids or "1",",")
    for i,v in ipairs(temp) do
        if tonumber(v) then
            self._passedGrids[tonumber(v)] = true
        end
    end
    if table.nums(self._passedGrids) > 2 then
        self._prePassedGrids = self._passedGrids
    end
    -- dump(self._passedGrids)
    -- dump(self._prePassedGrids)
end
-- 是否走过格子
function AdventureModel:isGridPassed( gridId )
    return self._passedGrids[gridId]
end

-- 圈数重置前走过的格子
function AdventureModel:getPrePassedGridIds( )
    local prePassedGrids = {}
    local temp = string.split(self._preData.pgids or "1",",")
    for i,v in ipairs(temp) do
        prePassedGrids[tonumber(v)] = true
    end
    return self._prePassedGrids or {}
end

-- 更新数据
function AdventureModel:updateAdventure( inData )
    dump(data,"adventure...")
	if not inData then return end
	for k,v in pairs(inData) do
		if type(v) ~= "table" or not self._data[k] then
            self._preData[k] = self._data[k] -- 记录
			self._data[k] = inData[k]
		else
            self._preData[k] = self._data[k]
			table.merge(self._data[k],inData[k])
		end
	end
	-- dump(self._data,"updateAdventure..........=====",10)
    self:updatePassedGrids()
	self:reflashData()
end

function AdventureModel:correctDiceNum( )
    -- if self._data.dn and 
end

--[[
--! @function setEnemyData
--! @desc 设置敌方数据提供给布阵临时存储数据
--！@param inData 怪兽数据
--! @return table
--]]
function AdventureModel:setEnemyTeamData(inData)
    local tempData = {}
    for k,v in pairs(inData) do
        if v.id == nil then 
            v.id = k 
        end
        v.teamId = tonumber(v.id)
        tempData[tonumber(v.id)] = v
    end
    self._enemyData = tempData
end


function AdventureModel:getEnemyDataById(inTeamId)
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
function AdventureModel:setEnemyHeroData(inData)
    self._enemyHeroData = inData
end


function AdventureModel:getEnemyHeroData()
    return self._enemyHeroData
end

------------------------------------- 对外接口 ---------------------------------
-- 是否有红点
function AdventureModel:haveNoticeDot( )
    if not self._data or not next(self._data) then return false end
    -- 骰子个数不为0
    if self._data.dn and self._data.dn > 0 then return true end
    -- 有未领取的圈数宝箱
    if self._data.rn and self._data.rn > table.nums(self._data.bid or {}) then return true end
end

return AdventureModel