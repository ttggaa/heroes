--
-- Author: <ligen@playcrab.com>
-- Date: 2016-12-08 15:55:27
--
local NestsServer = class("NestsServer", BaseServer)

function NestsServer:ctor()
    NestsServer.super.ctor(self)

    self._nestsModel = self._modelMgr:getModel("NestsModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._playerTodataModel = self._modelMgr:getModel("PlayerTodayModel")
end

-- 获取巢穴信息 
function NestsServer:onGetNestsInfo(result, error)
	if error ~= 0 then 
		return
	end

    self._nestsModel:setData(result)
    self:callback(result)
end

-- 建造巢穴 
function NestsServer:onConstructNest(result, error)
	if error ~= 0 then 
		return
	end
    
    if type(result.d.nests) == "table" then
        self._nestsModel:setNestData(result.d.nests)
    end

    -- 更新用户数据
    self._userModel:updateUserData(result["d"])

    self:callback(result)
end

-- 升级巢穴
function NestsServer:onUpgradeNest(result, error)
	if error ~= 0 then 
		return
	end

    if type(result.d.nests) == "table" then
        self._nestsModel:setNestData(result.d.nests)
    end

    -- 更新用户数据
    self._userModel:updateUserData(result["d"])

    self:callback(result)
end

-- 兑换碎片
function NestsServer:onExchangeFragment(result, error)
	if error ~= 0 then 
		return
	end

    -- 更新用户数据
    self._userModel:updateUserData(result["d"])

    if result["d"]["items"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"])
        result["d"]["items"] = nil
    end

    local backData = {}
    local nData = result["d"]["nests"]
    if type(nData) == "table" then
        local cId = next(nData)
        local campData = self._nestsModel:getCampDataById(cId)
        for k,v in pairs(nData[cId]) do
            if v.frg <= campData[k].frg then
                backData.newCount = v.frg
                backData.oldCount = campData[k].frg
            end
        end

        self._nestsModel:setNestData(nData)
    end

    self:callback(backData)
end

-- 阵营丰收
function NestsServer:onHarvest(result, error)
	if error ~= 0 then 
		return
	end

    self._userModel:updateUserData(result["d"])

    if result["d"] and result["d"]["dayInfo"] then
        self._playerTodataModel:updateDayInfo(result["d"]["dayInfo"])
    end

    local backData = {}
    local nData = result["d"]["nests"]
    if type(nData) == "table" then
        local cId = next(nData)
        local campData = self._nestsModel:getCampDataById(cId)
        for k,v in pairs(nData[cId]) do
            if v.frg ~= campData[k].frg then
                backData[k] = {newCount = v.frg, oldCount = campData[k].frg}
            end
        end

        self._nestsModel:setNestData(nData)
    end

    self:callback(backData)
end

return NestsServer

