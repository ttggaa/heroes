--[[
    Filename:    GuildMapServer.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-06-13 14:20:08
    Description: File description
--]]

local GuildMapServer = class("GuildMapServer", BaseServer)

function GuildMapServer:ctor(data)
    GuildMapServer.super.ctor(self)
    self._guildMapModel = self._modelMgr:getModel("GuildMapModel")
end

function GuildMapServer:onGetJReward(result, error)
	if error~=0 then
		self:handleErrorCode(error)
	end
	self:handleAboutServerData(result, true)
	self:callback(result)
end

function GuildMapServer:onAcJNpc2(result, error)
	if error~=0 then
		self:handleErrorCode(error)
		return
	end
	self._guildMapModel:setOfficerTargetGuildId()
	self:handleAboutServerData(result, true)
	self._guildMapModel:setCommanderData(result.jxRewardSt)
	self:callback(result)
end

function GuildMapServer:onAcJNpc1(result, error)
	if error~=0 then
		self:handleErrorCode(error)
		return
	end
	local guildMapModel = self._modelMgr:getModel("GuildMapModel")
	guildMapModel:updateEleData(result, false)
	self:handleAboutServerData(result, true)
	self:callback(result)
end

--获取新年使者信息
function GuildMapServer:onAcYearAmb(result, error)
	if error ~= 0 then
		self:handleErrorCode(error)
		return
	end
	self:handleAboutServerData(result, true)
	self:callback(result)
end

--新年使者开迷雾推送
function GuildMapServer:onPushYearMissFog(result, error)
	if self:checkPushExcludeUser(result) then return end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end

    self:onMissFog(result, error, true)
end

--新年使者事件之地图移动
function GuildMapServer:onYearAmbMove(result, error)
	if error ~= 0 then
		if self:handleErrorCode(error) then return end   
		return 
	end
	local guildMapModel = self._modelMgr:getModel("GuildMapModel")
	guildMapModel:updateSkipPosData(result, false)
	self:handleAboutServerData(result)
	self:callback(result, error)
end

--发现秘境
function GuildMapServer:onGenerateSecretLand(result, error)
	if error ~= 0 and self:handleFamErrorCode(error) then
		return
    end
	if self:checkPushExcludeUser(result) then return end
    self._guildMapModel:addData(result, true)

    self._guildMapModel:updateRoleMoveData(result, true)
	local keys = table.keys(result)
	local guild = result[keys[1]].guild

	local myId = self._modelMgr:getModel("UserModel"):getRID()
	if guild.stid==myId then
		--弹邀请窗，动画
		self._guildMapModel:noticePlayerFam(guild)
	end
    self:handleAboutServerData(result, true)
    self:callback(result)
end

--获取秘境内信息
function GuildMapServer:onGetSecretLandInfo(result, error)
    if error ~= 0 and error~=3041 and self:handleFamErrorCode(error) then--3041时直接在回调里清掉当前点的秘境就好，不需要在此处理
		return
    end
	self:callback(result, error)
end

function GuildMapServer:onGetSecretLandStatus(result, error)
	if error~=0 and self:handleFamErrorCode(error) then
		return
	end
	self:callback(result, error)
end

function GuildMapServer:onBeforeSecretLand(result, error)
    if error ~= 0 and self:handleFamErrorCode(error, 1) then
		return
    end
    self:callback(result, error)
end

function GuildMapServer:onAfterSecretLand(result, error)
    if error ~= 0 and self:handleFamErrorCode(error, 1) then
		return
    end
	self:handleAboutServerData(result)
	self:callback(result, error)
end

function GuildMapServer:onCompleteSecretLand(result, error)
    if error ~= 0 and self:handleFamErrorCode(error, 2) then
		return
    end
	self:handleAboutServerData(result)
	self:callback(result, error)
end

--完成秘境任务
function GuildMapServer:onKillSecretLand(result, error)
    if error ~= 0 and self:handleFamErrorCode(error) then
		return
    end
	local info = result.info
	local gridKeys = table.keys(info)
	local ids = table.keys(info[gridKeys[1]])
	local data = info[gridKeys[1]][ids[1]]
	self._modelMgr:getModel("GuildMapFamModel"):noticeKilled(gridKeys[1], tonumber(ids[1]), data)
end

function GuildMapServer:onSkipPos(result, error)
    dump(result, "tset" ,10)
    if error ~= 0 then
        if self:handleErrorCode(error) then return end   
        return 
    end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateSkipPosData(result, false)
    self:handleAboutServerData(result)
    self:callback(result, error)
end

function GuildMapServer:onPushSkipPos(result, error)
    if self:checkPushExcludeUser(result) then return end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end

    local userModel = self._modelMgr:getModel("UserModel")
    if result.pid == userModel:getData()._id then 
        return
    end
    guildMapModel:updateSkipPosData(result, true)
end

function GuildMapServer:onGetMapInfo(result, error)
    -- if error == 3020 then 
    --     if self:handleErrorCode(error) then return end   
    --     return
    -- end
    -- dump(result, "onGetMapInfo")
    if (result ~= nil and error == 0) then 
        local guildMapModel = self._modelMgr:getModel("GuildMapModel")
        local userModel = self._modelMgr:getModel("UserModel")
        guildMapModel:onInit() 
        if result.code == nil or result.code == 0 then 
            guildMapModel:setData(result)
        end
        self:handleAboutServerData(result)
    end
    self:callback(result, error)
end

function GuildMapServer:onPreViewMap(result, error)
    if (result ~= nil and error == 0) then 
        local guildMapModel = self._modelMgr:getModel("GuildMapModel")
        guildMapModel:onInit(true)
        if result.code == nil or result.code == 0 then 
            guildMapModel:setData(result)
        end
        self:handleAboutServerData(result)
    end
    self:callback(result, error)
end

function GuildMapServer:onRoleMove(result, error)
    if self:handleErrorCode(error) then return end
    if error == 0 then
        local guildMapModel = self._modelMgr:getModel("GuildMapModel")
        guildMapModel:updateRoleMoveData(result, false)
        self:handleAboutServerData(result)
    end
    self:callback(result, error)
end


--[[
--! @function checkPushExcludeUser
--! @desc 检测是否要排除当前用户
--! @param inGridKey 服务器端返回结果
--! @param bool 是否排除
--! @return 
--]]
function GuildMapServer:checkPushExcludeUser(result)
    if result.exUsers == nil then return false end

    local userId = self._modelMgr:getModel("UserModel"):getData()._id
    for k,v in pairs(result.exUsers) do
        if v == userId then 
            return true
        end
    end

    return false
end

function GuildMapServer:onPushRoleMove(result)
    if self:checkPushExcludeUser(result) then return end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end

    local userModel = self._modelMgr:getModel("UserModel")
    if result.pid == userModel:getData()._id then 
        return
    end
    guildMapModel:updateRoleMoveData(result, true)

    -- self:callback(result, error)    
end

function GuildMapServer:onPushMissFog(result, error)
    if self:checkPushExcludeUser(result) then return end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end

    self:onMissFog(result, error, true)
end


function GuildMapServer:onMissFog(result, error, reflash)
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if reflash == nil then
        reflash = false
    end
    guildMapModel:updateFog(result, reflash)

    self:callback(result, error)    
end


function GuildMapServer:onRoleGetReward(result, error)
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end 
        return 
    end
    self:handleAboutServerData(result, false)
    self:callback(result)    
    -- local userModel = self._modelMgr:getModel("UserModel")
    -- result.upTime = userModel:getCurServerTime()

    -- local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    -- if reflash == nil then
    --     reflash = false
    -- end
    -- guildMapModel:updateFog(result, reflash)

    -- self:callback(result, error)    
end

function GuildMapServer:onExchangeReward(result, error)
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end   
        return 
    end
    self:handleAboutServerData(result)
    self:callback(result)
end

function GuildMapServer:onGetBuff(result, error)
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end   
        return 
    end
    self:handleAboutServerData(result)
    self:callback(result)
end

function GuildMapServer:onGetTimeBuffRead(result, error)
    if error ~= 0 then
        if self:handleErrorCode(error) then return end   
        return 
    end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateEleData(result, false)
    guildMapModel:updateRoleProgress(result, false)
    self:handleAboutServerData(result)
    self:callback(result)
end

function GuildMapServer:onPushTimeBuffRead(result)
    if self:checkPushExcludeUser(result) then return end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end
        
    guildMapModel:updateRoleProgress(result, true)
    guildMapModel:updateEleData(result, true)

    self:handleAboutServerData(result, true)
end

function GuildMapServer:onPushCancelTimeBuffRead(result)
    if self:checkPushExcludeUser(result) then return end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end
    guildMapModel:updateEleData(result, true)
    guildMapModel:cancelRoleProgress(result, true)

    self:handleAboutServerData(result, true)
end

function GuildMapServer:onCancelTimeBuffRead(result, error)
    if error ~= 0 then
        if self:handleErrorCode(error) then return end   
        return 
    end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateEleData(result, false)
    guildMapModel:cancelRoleProgress(result, false)

    self:handleAboutServerData(result)
    self:callback(result)
end

function GuildMapServer:onGetTimeBuffGet(result, error)
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end  
        return 
    end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateData(result, false)

    self:handleAboutServerData(result)
    self:callback(result)
end
  

function GuildMapServer:onGetTimeRewardGet(result, error)
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end  
        return 
    end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateData(result, false)

    self:handleAboutServerData(result)
    self:callback(result)
end


function GuildMapServer:onGetTimeRewardRead(result, error)
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end  
        return 
    end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateRoleProgress(result, false)
    guildMapModel:updateEleData(result, false)

    self:handleAboutServerData(result)
    self:callback(result)
end

function GuildMapServer:onCancelTimeRewardRead(result, error)
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end  
        return 
    end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateEleData(result, false)
    guildMapModel:cancelRoleProgress(result, false)

    self:handleAboutServerData(result)
    self:callback(result)
end


function GuildMapServer:onPushTimeRewardGet(result)
    if self:checkPushExcludeUser(result) then return end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end
    dump(result, "testr", 10)
    guildMapModel:updateEleData(result, true)
    self:handleAboutServerData(result,true)
end


function GuildMapServer:onPushTimeRewardRead(result)
    if self:checkPushExcludeUser(result) then return end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end

    guildMapModel:updateRoleProgress(result, true)
    guildMapModel:updateEleData(result, true)
    self:handleAboutServerData(result, true)
end

function GuildMapServer:onPushLeaveCenter(result)
    if self:checkPushExcludeUser(result) then return end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateEleData(result, true)

    guildMapModel:updateRoleMoveData(result, true)

    self:handleAboutServerData(result, true)
    self:callback(result)
end

function GuildMapServer:onPushDefendCenter(result)
    if self:checkPushExcludeUser(result) then return end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateEleData(result, true)

    guildMapModel:updateRoleMoveData(result, true)

    self:handleAboutServerData(result, true)
    self:callback(result)
end



function GuildMapServer:onDefendCenterCity(result, error)
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end  
        return 
    end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateEleData(result, false)

    guildMapModel:updateRoleMoveData(result, false)

    self:handleAboutServerData(result)
    self:callback(result)
end

function GuildMapServer:onLeaveCenterCity(result, error)
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end  
        return 
    end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateEleData(result, false)

    guildMapModel:updateRoleMoveData(result, false)

    self:handleAboutServerData(result)
    self:callback(result)
end

function GuildMapServer:onPushUpdateMap(result)
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if result.code == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_REPLACE_GUILD then
        guildMapModel:releaceGuild()
        return
    end
    if result.currentGuildId ~= nil then 
        guildMapModel:updateGuildListData(result)
    end
end

function GuildMapServer:onPushPvpAimRs(result)
    if self:checkPushExcludeUser(result) then return end
    dump(result)
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end

    guildMapModel:updateData(result, true)

    guildMapModel:cancelRoleProgress(result, true)  

    guildMapModel:updateRoleQuit(result, true)

    self:handleAboutServerData(result, true)

    require "game.view.guild.GuildConst"
    if result.code == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_SWITCH_MAP then
        local guildMapModel = self._modelMgr:getModel("GuildMapModel")
        guildMapModel:pushSwitchGuild(result, true)
        return
    end
    if result.shows ~= nil then 
        guildMapModel:updateBattleTip(result.shows)
    end
    if result.backCity ~= nil  then 
        guildMapModel:updateBackCityData(result, true)
    end
    guildMapModel:updateBackReviveData(result, true)
end


function GuildMapServer:onQuitMapRoom(result, error)
    return
end



function GuildMapServer:onPushRoleJoin(result)
    if self:checkPushExcludeUser(result) then return end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end
    guildMapModel:updateNewRoleJoin(result, true)

end


function GuildMapServer:onPushCancelTimeRewardRead(result)
    if self:checkPushExcludeUser(result) then return end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end
    guildMapModel:updateEleData(result, true)
    guildMapModel:cancelRoleProgress(result, true)
    self:handleAboutServerData(result, true)
end


function GuildMapServer:onAcGoldMine(result, error)
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end  
        return 
    end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateEleData(result, false)

    self:handleAboutServerData(result)
    self:callback(result)
end

function GuildMapServer:onAcTent(result, error)
    if error ~= 0 then
        if self:handleErrorCode(error) then return end   
        return 
    end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateEleData(result, false)

    self:handleAboutServerData(result)
    self:callback(result)
end


function GuildMapServer:onPushAcTent(result)
    if self:checkPushExcludeUser(result) then return end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end

    guildMapModel:updateEleData(result, true)

    self:handleAboutServerData(result, true)
    self:callback(result)
end


function GuildMapServer:onPushAcGuildTower(result)
    if self:checkPushExcludeUser(result) then return end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end

    guildMapModel:updateEleData(result, true)

    self:handleAboutServerData(result,  true)
    self:callback(result)
end


function GuildMapServer:onAcGuildTower(result, error)
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end  
        return 
    end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateEleData(result, false)

    self:handleAboutServerData(result)
    self:callback(result)
end


function GuildMapServer:onPushAcGoldMine(result)
    if self:checkPushExcludeUser(result) then return end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end

    if result.mapList ~= nil then
        local function updateSubData(inSubData, inUpData)
            local backData
            if type(inSubData) == "table" and next(inSubData) ~= nil then
                for k,v in pairs(inUpData) do
                    if k ~= "haduse" then
                        if type(v) == "table" and next(v) ~= nil then 
                            backData = updateSubData(inSubData[k], v)
                        else
                            backData = v
                        end
                        inSubData[k] = backData
                    end 
                end
                return inSubData
            else 
                return inUpData
            end
        end
        local backData
        for k,v in pairs(result.mapList) do
            backData = updateSubData(v, guildMapModel:getData().mapList[k])
            result.mapList[k] = backData
        end
    end

    guildMapModel:updateEleData(result, true)
    self:handleAboutServerData(result, true)
end



function GuildMapServer:onPushPveAfter(result)
    if self:checkPushExcludeUser(result) then return end
    
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end

    guildMapModel:updateEleData(result, true)
    
    guildMapModel:updateBackCityData(result, true)

    self:handleAboutServerData(result, true)
end




function GuildMapServer:onPushCenterBack(result)
    if self:checkPushExcludeUser(result) then return end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end

    guildMapModel:updateBackReviveData(result, true)

    self:handleAboutServerData(result)
end


function GuildMapServer:onPushBackCity(result)
    if self:checkPushExcludeUser(result) then return end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end

    guildMapModel:updateBackCityData(result, true)

    self:handleAboutServerData(result, true)
end

function GuildMapServer:onBackCity(result, error)
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end  
        return 
    end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateBackCityData(result, false)

    self:handleAboutServerData(result)
    self:callback(result)
end

function GuildMapServer:onPushRoleQuit(result)
    if self:checkPushExcludeUser(result) then return end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end

    guildMapModel:updateRoleQuit(result, true)

    self:handleAboutServerData(result, true)
    self:callback(result)
end


function GuildMapServer:onPveBefore(result, error)
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end  
        return 
    end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateEleData(result, false)
    self:handleAboutServerData(result)    
    -- local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    -- guildMapModel:updateRoleQuit(result, true)

    -- self:handleAboutServerData(result)
    self:callback(result)
end

function GuildMapServer:onPassPortal(result, error)
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end  
        return 
    end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:switchGuild(result, false)
    guildMapModel:clear()
    guildMapModel:setData(result)
    self:handleAboutServerData(result)
    self:callback(result)
end

function GuildMapServer:onPveAfter(result, error)
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end  
        return 
    end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateBattleData(result, false)
    
    self:handleAboutServerData(result)

    self:callback(result)
end

function GuildMapServer:handleResultCode(result)
    if result == nil then
        return 0
    end
    if result.code == nil or result.code == 0 then
        return 1
    end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:dataNotMatching(result)
    return 0
end

function GuildMapServer:onGetMapEvent(result, error)
    if error ~= 0 then
        if self:handleErrorCode(error) then return end  
        return 
    end
    -- local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    -- guildMapModel:updateRoleQuit(result, true)

    -- self:handleAboutServerData(result)
    self:callback(result)
end

-- function GuildMapServer:onPushMapTask(result)   --wangyan
--     if self:checkPushExcludeUser(result) then return end

--     local guildMapModel = self._modelMgr:getModel("GuildMapModel")
--     if guildMapModel:isLockPush() then return end

--     guildMapModel:pushMapTask(result)
-- end

function GuildMapServer:onGetMapTaskReward(result, error)   --wangyan
    if error ~= 0 then
        if self:handleErrorCode(error) then return end 
        return
    end
    -- dump(result, "4546", 10)
    self:handleAboutServerData(result)
    self._modelMgr:getModel("GuildMapModel"):pushMapTask(result)
    self:callback(result, error)
end

function GuildMapServer:onPushMapEvent(result)
    --聊天  by wangyan
    local chatModel = self._modelMgr:getModel("ChatModel")
    local _, _, sendData = chatModel:paramHandle("log", {infoType = "GUILD_MAP_REPORT", infoData = result})
    if sendData ~= nil then
        chatModel:pushData(sendData)
    end

    --跑马灯
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:insertNoticeData(result)

    if self:checkPushExcludeUser(result) then return end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end

    guildMapModel:updateReportState(1)
end

function GuildMapServer:onGiveUpExchange(result, error)
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end 
        return 
    end
    self:handleAboutServerData(result)
    self:callback(result)
end


function GuildMapServer:onGetAimInfo(result, error)
    if error ~= 0 then 
        return 
    end
    self:callback(result)
end


function GuildMapServer:onGetPvpRes(result, error)
    if error ~= 0 then 
        if error == 3035 then
            self._viewMgr:closeTip()
        end
        if self:handleErrorCode(error) then return end 
        return 
    end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateEleData(result, false)

    guildMapModel:updateRoleQuit(result, true)

    guildMapModel:cancelRoleProgress(result, true)
    
    if result.backCity ~= nil  then  
        local userId = self._modelMgr:getModel("UserModel"):getData()._id
        if result.backCity.userId == userId then
            guildMapModel:updateBackCityData(result, false)
        else
            guildMapModel:updateBackCityData(result, true)
        end
    end
    -- updateBackReviveData 内部区分是否及时push
    guildMapModel:updateBackReviveData(result, false)

    if result.shows ~= nil then 
        guildMapModel:updateBattleTip(result.shows)
    end

    self:handleAboutServerData(result)
    self:callback(result)
end

function GuildMapServer:onRobGoldMineRead(result, error)
    if error ~= 0 then
        if self:handleErrorCode(error) then return end   
        return 
    end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateEleData(result, false)
    guildMapModel:updateRoleProgress(result, false)
    self:handleAboutServerData(result)
    self:callback(result)
end

function GuildMapServer:onRobGoldMineCancel(result, error)
    if error ~= 0 then
        if self:handleErrorCode(error) then return end   
        return 
    end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateEleData(result, false)
    guildMapModel:cancelRoleProgress(result, false)

    self:handleAboutServerData(result)
    self:callback(result)
end

function GuildMapServer:onRobGoldMineGet(result, error)
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end  
        return 
    end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateEleData(result, false)

    self:handleAboutServerData(result)
    self:callback(result)
end

function GuildMapServer:onPushRobGoldMineRead(result)
    if self:checkPushExcludeUser(result) then return end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end
    
    guildMapModel:updateEleData(result, true)

    guildMapModel:updateRoleProgress(result, true)

    self:handleAboutServerData(result, true)
end

function GuildMapServer:onPushRobGoldMineCancel(result)
    if self:checkPushExcludeUser(result) then return end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end

    guildMapModel:updateEleData(result, true)
    guildMapModel:cancelRoleProgress(result, true)
    
    self:handleAboutServerData(result, true)
end

function GuildMapServer:onPushRobGoldMineGet(result)
    if self:checkPushExcludeUser(result) then return end
    
    -- 针对onPushRobGoldMineGet 特殊处理，反推数据进行更新，为了走通用接口
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end
    if result.mapList ~= nil then
        local function updateSubData(inSubData, inUpData)
            local backData
            if type(inSubData) == "table" and next(inSubData) ~= nil then
                for k,v in pairs(inUpData) do
                    if k ~= "perc" then
                        if type(v) == "table" and next(v) ~= nil then 
                            backData = updateSubData(inSubData[k], v)
                        else
                            backData = v
                        end
                        inSubData[k] = backData
                    end 
                end
                return inSubData
            else 
                return inUpData
            end
        end
        local backData
        for k,v in pairs(result.mapList) do
            backData = updateSubData(v, guildMapModel:getData().mapList[k])
            result.mapList[k] = backData
        end
    end

    guildMapModel:updateEleData(result, true)

    self:handleAboutServerData(result, true)
end


function GuildMapServer:onPushAddCommonPoint(result)
    if self:checkPushExcludeUser(result) then return end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end

    guildMapModel:updateEleData(result, true)

    self:handleAboutServerData(result)    
end

function GuildMapServer:onPushCenterCityFree(result)
    if self:checkPushExcludeUser(result) then return end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end

    guildMapModel:updateEleData(result, true)

    self:handleAboutServerData(result)    
end

function GuildMapServer:onPushCenterCityOccupy(result)
    if self:checkPushExcludeUser(result) then return end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if guildMapModel:isLockPush() then return end

    guildMapModel:updateEleData(result, true)

    self:handleAboutServerData(result)    
end

function GuildMapServer:onGetPointInfo(result, error)
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end  
        return 
    end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateEleData(result, false)
    self:handleAboutServerData(result) 

    self:callback(result, error)
end

function GuildMapServer:onGetRankList(result, error)
    self:callback(result, error)
end

function GuildMapServer:onAcMTask1(result, error)
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end  
        return 
    end

    local newTask
    if result["addTaskId"] then
        newTask = result["addTaskId"]
        result["addTaskId"] = nil
    end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateEleData(result, false)
    self:handleAboutServerData(result) 
    self._modelMgr:getModel("GuildMapModel"):pushMapTask(result, newTask)

    self:callback(result, error)
end

function GuildMapServer:onAcMTask2(result, error)
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end  
        return 
    end

    local newTask
    if result["addTaskId"] then
        newTask = result["addTaskId"]
        result["addTaskId"] = nil
    end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateEleData(result, false)
    self:handleAboutServerData(result) 
    self._modelMgr:getModel("GuildMapModel"):pushMapTask(result, newTask)

    self:callback(result, error)
end

function GuildMapServer:onGetRoleReward23(result, error)
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end  
        return 
    end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateEleData(result, false)
    self:handleAboutServerData(result) 
    self._modelMgr:getModel("GuildMapModel"):pushMapTask(result)

    self:callback(result, error)
end

--------------------------------------
--标记相关
function GuildMapServer:onMapMark(result, error)
    -- dump(result, "result")
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end  
        return 
    end

    self:callback(result, error)
end

function GuildMapServer:onCancelMapMark(result, error)
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end  
        return 
    end

    self:callback(result, error)
end

function GuildMapServer:onPushMapMark(result, error)
    -- dump(result, "onPushMapMark", 10)
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end  
        return 
    end

    self._guildMapModel:pushMapMark(result)
end

--------------------------------------
--斯芬克斯答题相关
function GuildMapServer:onSphinxBefore(result, error)
    dump(result, "onSphinxBefore")
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end  
        return 
    end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateData(result, false)
    self:handleAboutServerData(result)
    self:callback(result, error)
end

function GuildMapServer:onSphinxAfter(result, error)
    dump(result, "onSphinxAfter")
    if error ~= 0 then 
        if self:handleErrorCode(error) then return end  
        return 
    end

    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:updateSphinxData(result["sphinx"])
    guildMapModel:updateEleData(result, false)
    self:handleAboutServerData(result)
    self:callback(result, error)
end

function GuildMapServer:handleErrorCode(errorCode)
    if errorCode == 3020 or errorCode==3047 then 
        self:handleUpdateMap()
        return true
    elseif errorCode == 3025 then
        self:handleSwitchMap()
        return true
    end
end

function GuildMapServer:handleFamErrorCode(errorCode, famType)
	if errorCode == 3044 or errorCode == 3041 then
		self:handleFamSwichMap(errorCode, famType)
		return true
	end
end

function GuildMapServer:handleFamSwichMap(errorCode, famType)
	local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:logoutToMap(errorCode, famType)
    ViewManager:getInstance():unlock()
end

function GuildMapServer:handleUpdateMap()
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:logoutMap(true)
    ViewManager:getInstance():unlock()
end

function GuildMapServer:handleSwitchMap(error)
    ViewManager:getInstance():unlock()   
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:pushSwitchGuild() 
end

function GuildMapServer:onGetMapStatisMsg(result, error)
    if error ~= 0 then
        return
    end

    self:callback(result, error)
end

function GuildMapServer:handleAboutServerData(result, reflash)
    if result == nil then
        return 
    end
    if reflash == nil then 
        reflash = false
    end
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    if result.del ~= nil then
        guildMapModel:delData(result.del, reflash)
    end

    if result.upNear ~= nil then 
        guildMapModel:updateNearGrid(result)
    end

    if result["d"] == nil then 
        return
    end

    if result["d"]["formations"] ~= nil then 
        local formationModel = self._modelMgr:getModel("FormationModel")
        formationModel:updateAllFormationData(result["d"]["formations"])
        result["d"]["formations"] = nil
    end


    if result["d"]["items"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"])
        result["d"]["items"] = nil
    end

    if result["d"]["teams"] ~= nil then 
        local teamModel = self._modelMgr:getModel("TeamModel")
        teamModel:updateTeamData(result["d"]["teams"])
        result["d"]["teams"] = nil
    end

    -- 更新用户数据
    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
    if result["unset"] ~= nil then 
        local tempK = ""
        for k,v in pairs(result["unset"]) do
            local tempList = string.split(k, "%.")
            if tempList[1] == "guildRoleMapList" then 
                tempK = k
                break
            end
        end
        if tempK ~= "" then 
            result["unset"][tempK] = nil
        end
        local itemModel = self._modelMgr:getModel("ItemModel")
        local removeItems = itemModel:handelUnsetItems(result["unset"])
        itemModel:delItems(removeItems, true)
    end

end

return GuildMapServer