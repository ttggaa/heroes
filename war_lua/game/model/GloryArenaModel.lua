--[[
    FileName:       GloryArenaView
    Author:         <dongcheng@playcrab.com>
    Datetime:       2018-08-10 10:15:38
    Description:    荣耀竞技场数据model
]]

local GloryArenaModel = class("GloryArenaModel", BaseModel)

function GloryArenaModel:ctor()
    GloryArenaModel.super.ctor(self)
    self._mianRankData = {}         --主界面显示的数据，已经排好顺序
    self._selfAttackCount = {}
    self._selfRank = 0
    self._gloryArenaRank = {}
    self._gloryArenaReport = {}
    self._arenaShop = {}
    self._battleCountShop = {}
    self._chalNum = 0
    self._season = 0 --赛季
    self._cross = 0 --是否跨服 0不跨服
    self._beginTime = 0
    self._endTime = 0
    self._secs = {}
    self._errorStatus = 0
    --隐藏的编组id
    self._hideArray = {}
end

function GloryArenaModel:setData(data)
--      print("************************11", ModelManager:getInstance():getModel("UserModel"):getCurServerTime())
--      dump(data)

    self.super.setData(self, data)
    self:lSetMainRankData(data.enemys)
    self._selfAttackCount = clone(data.crossAarena)
    self._selfRank = data.rank
    self._season = data.season or 0
    self._cross = data.cross or 0
    self._beginTime = data.begin or 0
    self._endTime = data["end"] or 0
    self._secs = data.secs
    self:setArenaShop(data.crossAarena, 1)
    self:setArenaShop(data.crossAarena, 2)
    self:lSetHideArray(data.crossAarena.hiddens)
    self._errorStatus = data.errorStatus or 0
--    self._errorStatus = 2
--    self:lCheckDefenseArray(data)
    self:reflashData(data)
end

function GloryArenaModel:lGetTimeShow(nType)
--    local function _getTime(str)
--        local str1 = string.sub(str, 1, 4) or ""
--        local str2 = string.sub(str, 5, 6) or ""
--        local str3 = string.sub(str, 7, 8) or ""
--        return str1, str2, str3
--    end
--    local  str1, str2, str3 = _getTime(tostring(self._beginTime))
--    local  str4, str5, str6 = _getTime(tostring(self._endTime))
    if nType == 1 then
        return TimeUtils.getDateString(self._beginTime,"%Y.%m.%d") .. "~" .. TimeUtils.getDateString(self._endTime,"%Y.%m.%d")
--        return str1 .. "." .. str2 .. "." .. str3 .. "~" .. str4 .. "." .. str5 .. "." .. str6
    elseif nType == 2 then
        return TimeUtils.getDateString(self._beginTime,"%m.%d") .. "~" .. TimeUtils.getDateString(self._endTime,"%m.%d")
--        return str2 .. "." .. str3 .. "~" .. str5 .. "." .. str6
    end
end

--领主管家用  显示赛季时间
function GloryArenaModel:lGetLordShowTimes()
    return TimeUtils.getDateString(self._beginTime,"%Y.%m.%d"),TimeUtils.getDateString(self._endTime,"%Y.%m.%d")
end

function GloryArenaModel:lIsCurTimeOpen()
    local nowTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()

    if nowTime < self._beginTime or nowTime > self._endTime then
        return false 
    end
    return true
end


function GloryArenaModel:lCheckDefenseArray(callback)
    local defense = false
    local formationModel = ModelManager:getInstance():getModel("FormationModel")
    local formationData = formationModel:getFormationData()
    for i = formationModel.kFormationTypeGloryArenaDef1 , formationModel.kFormationTypeGloryArenaDef3 do
        if not formationModel:isFormationDataExistByType(i) then
            defense = true
            break
        end
    end

    if defense then
        self._serverMgr:sendMsg("CrossArenaServer", "getDefFormation", {},true ,{}, function(resule)
            if callback then
                callback()
            end
        end)
    else
        if callback then
            callback()
        end
    end
end

function GloryArenaModel:lSaveDefenseArray(data)
    local formationModel = ModelManager:getInstance():getModel("FormationModel")
    formationModel:private_saveGloryArenaBattleFormationData(true, data)
end

function GloryArenaModel:lCheckAttackArray(callback)
    local defense = false
    local formationModel = ModelManager:getInstance():getModel("FormationModel")
    local formationData = formationModel:getFormationData()
    for i = formationModel.kFormationTypeGloryArenaAtk1 , formationModel.kFormationTypeGloryArenaAtk1 do
        if not formationModel:isFormationDataExistByType(i) then
            defense = true
            break
        end
    end

    if defense then
        self._serverMgr:sendMsg("CrossArenaServer", "getAtkFormation", {},true ,{}, function(resule)
            if callback then
                callback()
            end
        end)
    else
        if callback then
            callback()
        end
    end
end

function GloryArenaModel:lSaveAttackArray(data)
    local formationModel = ModelManager:getInstance():getModel("FormationModel")
    formationModel:private_saveGloryArenaAttackFormationData(true, data)
end

--function GloryArenaModel:lIsCurTimeOpen1(callback)
--    if not self:lIsCurTimeOpen() then
--        if callback then
--            callback()
--        end
--    end
--    return true
--end

--更具等级判断是否需要重新获取数据
function GloryArenaModel:lCheckLevelEnter(callback) 
    local sTimeOpenD = tab:STimeOpen(106)
    if sTimeOpenD then
        local openLvl = sTimeOpenD.level
        local userLvl = ModelManager:getInstance():getModel("UserModel"):getData().lvl
        if userLvl >= openLvl then
            --这个时候等级达到了，但是没有请求数据
            self._serverMgr:sendMsg("CrossArenaServer", "enterCrossArena", {},true ,{}, function(resule)
--                    print("_______________________________")
                if callback then
                    callback()
                end
            end)
        end
    end
end


--如果等级到了
function GloryArenaModel:lCheckTime(callback)   
--    print("11111111111111", self._beginTime, self._endTime)
    if (self._beginTime and self._beginTime == 0) or (self._endTime and self._endTime == 0) then
        self:lCheckLevelEnter(callback)
    elseif self._beginTime and self._beginTime > 0 and self._endTime and self._endTime > 0 and self._season == 0 then
        if self:lIsCurTimeOpen() then
            self:lCheckLevelEnter(callback)
        end
    end
end

function GloryArenaModel:lCheckAdditionalContion()
    local isOpen = true
    local tipStr = ""
    if self._errorStatus == 1 then
        isOpen = false
        tipStr = lang("honorArena_tip_18")
    elseif self._errorStatus == 2 then
        isOpen = false
        tipStr = lang("honorArena_tip_20")
    end
    if isOpen then
        if not GameStatic.is_show_gloryArena then
            isOpen = false
            tipStr = lang("honorArena_tip_26")
        end
    end
    return isOpen, tipStr
end


--判断开启的条件
function GloryArenaModel:lIsStartContion()
    local sTimeOpenD = tab:STimeOpen(106)
    local tipStr = ""
    local serverBeginTime = ModelManager:getInstance():getModel("UserModel"):getData().sec_open_time
	if serverBeginTime then
		local sec_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime,"%Y-%m-%d 05:00:00"))
		if serverBeginTime < sec_time then   --过零点判断
			serverBeginTime = sec_time - 86400
		end
	end
    print("serverBeginTime??????????",os.date("%x",serverBeginTime),sTimeOpenD.opentime)
	local serverHour = tonumber(TimeUtils.date("%H",serverBeginTime)) or 0
	local nowTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
	local openDay = (sTimeOpenD.opentime or 1)-1
	local openTimeNotice = sTimeOpenD.openhour or 0
	local openHour = string.format("%02d:00:00",openTimeNotice)
	local openTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime + openDay*86400,"%Y-%m-%d " .. openHour))
    local leftTime = openTime - nowTime
	local isOpen = leftTime <= 0

    if isOpen then
        local openTab = sTimeOpenD
		local openLvl = openTab.level
		local userLvl = ModelManager:getInstance():getModel("UserModel"):getData().lvl
		if openLvl > userLvl then
            isOpen = false
            tipStr = lang("honorArena_tip_7")
        end
    else
        tipStr = lang("honorArena_tip_1")
    end
    return isOpen, tipStr 
end


function GloryArenaModel:lIsOpen()
--    local nowTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
    local isOpen, tipStr = self:lIsStartContion()
    if isOpen then
        if not self:lIsCurTimeOpen() then
            isOpen = false
            tipStr = lang("honorArena_tip_6")
            -- tipStr = lang((nowTime < self._beginTime and "honorArena_tip_2" or "honorArena_tip_3"))
        end
    end

    if isOpen then
        isOpen, tipStr = self:lCheckAdditionalContion()
    end

    return isOpen, tipStr
end

function GloryArenaModel:lOpenGloryArena()
    local isOpen, tipStr = self:lIsOpen()
    if isOpen then
        self._serverMgr:sendMsg("CrossArenaServer", "enterCrossArena", {},true ,{}, function(resule)
            self._viewMgr:showView("gloryArena.GloryArenaView")
        end
        )
    else
        self._viewMgr:showTip(tipStr or lang("honorArena_tip_1"))
        self._serverMgr:sendMsg("CrossArenaServer", "enterCrossArena", {},true ,{}, function(resule)
            
        end)
    end
end

function GloryArenaModel:lGetServerNameStr(serverId)
    serverId = tonumber(serverId)
    local sdkMgr = SdkManager:getInstance()
    local function getPlatform(sec)
        local platform =""
        local sec = tonumber(sec)
        if sec and sec >= 5001 and sec < 7000 then
            platform = "双线"
        elseif sdkMgr:isQQ() then
            platform = "qq"
        elseif sdkMgr:isWX() then
            platform = "微信"
        else
            platform = "win"
        end
        return platform
    end

    local function getRealNum(sec)
        sec = tonumber(sec)
        local num = 0
        if sec < 5001 then
            num = sec % 1000
        elseif (sec >= 5001 and sec < 5026) or (sec >= 6001 and sec < 6026) then
            num = (sec % 1000)*2 - 1
        elseif (sec >= 5026 and sec < 5501) or (sec >= 6026 and sec < 6501) then   --5025  6025 以后不区分单双号服务器
            local temp = 6025
            if sec < 6000 then
                temp = 5025
            end
            num = sec - temp + 50
        elseif (sec >= 5501 and sec < 6000) or (sec >= 6501 and sec < 7000) then
            num = (sec % 100) * 2
        else
            num = sec % 1000
        end
        return num
    end
    local str1 = getPlatform(serverId) or ""
    local str2 = getRealNum(serverId) or ""
    local serverStr = str1 .. str2 .. "区"
    return serverStr
end

function GloryArenaModel:lGetAttackServerId()
    if self:bIsCross() then
        local selfSec = ModelManager:getInstance():getModel("UserModel"):getServerId()
        local str = ""
        for key, var in ipairs(self._secs or {}) do
            if var and tonumber(var) ~= tonumber(selfSec) then
                if str == "" then
                    str = str .. self:lGetServerNameStr(var)
                else    
                    str = str .. "," .. self:lGetServerNameStr(var)
                end
            end
        end
        return str
    else
        return "无"--ModelManager:getInstance():getModel("UserModel"):getServerId()
    end
end

function GloryArenaModel:lGetShowTiem()
    return self:lGetTimeShow(1)
end

--设置编组的显示
function GloryArenaModel:lSetHideArray(data)
    self._hideArray = {}
    data = data or ""
    local hideTable = string.split(data, ",")
    for i,v in ipairs(hideTable or {}) do
        if v and v ~= "" then
            self._hideArray[tonumber(v)] = true
        end
    end
end

--获取编组的显示
function GloryArenaModel:lGetHideArray()
    return clone(self._hideArray) or {}
end



--是否跨服 0不跨服
function GloryArenaModel:bIsCross()
    return self._cross == 1
end

function GloryArenaModel:lGetSeason()
    return tonumber(self._season)
end

function GloryArenaModel:lSetMainRankData(data)
    self._mianRankData = clone(data)

    table.sort(self._mianRankData, function(var1, var2)
        return var1.rank < var2.rank
    end)

end

function GloryArenaModel:lGetMainRankData()
    return self._mianRankData
end

function GloryArenaModel:lGetSelfAttackCount()
    return self._selfAttackCount
end

function GloryArenaModel:lGetSelfRank()
    return self._selfRank
end

function GloryArenaModel:lSetSelfAttackCount(data)
    for key, var in pairs(data) do
        if var then
            self._selfAttackCount[key] = var
            self._data.crossAarena[key] = var
        end
    end
    self:reflashData()
end

--设置排行数据
function GloryArenaModel:lSetGloryArenaRank(data)
    self._gloryArenaRank = data
--    self:reflashData(data)
end

function GloryArenaModel:lGetGloryArenaRank()
    return self._gloryArenaRank
end

-- 还可购买次数
function GloryArenaModel:canBuyChanllengeNum( )
    if not self:lGetSelfAttackCount() then return 0 end
    local buyNum = self:lGetSelfAttackCount().buyNum
    local vip = self._modelMgr:getModel("VipModel"):getData().level

    local canBuyNum = tonumber(tab:Vip(vip).refreshHonorArena)-buyNum
    return canBuyNum 
end

--设置战报数据(最新的数据在最后一位)
function GloryArenaModel:lSetGloryArenaReport(data)
    self._gloryArenaReport = {}
    for key, var in ipairs(data) do
        if var ~= nil then
            self._gloryArenaReport[#data - key + 1] = var
        end
    end
    
--    self:reflashData(data)
end

--获取战报数据
function GloryArenaModel:lGetGloryArenaReport()
    return self._gloryArenaReport
end


--更具排名获取奖励
function GloryArenaModel:lGetRankReward(nRank)
    local _nRank = nRank or self._selfRank
    if _nRank > 10000 then
        _nRank = 10000
    end
    local rankRwardData = tab["honorArenaAward"]
    for key, var in ipairs(rankRwardData) do
        if var then
            if _nRank >= tonumber(var.pos[1]) and _nRank <= tonumber(var.pos[2]) then
                return var
            end
        end
    end 
    return {}
end

-- 设置竞技场商城信息
function GloryArenaModel:setArenaShop(data, nIndex)
	self._arenaShop[nIndex or 1] = {}
    for key, var in pairs(clone(data["shop" .. (nIndex or 1)]) or {}) do
        self._arenaShop[nIndex or 1][tonumber(key)] = var
    end
--    self:reflashData()
end

-- 更新竞技场商城信息
function GloryArenaModel:updateArenaShop(data, nIndex)
    local shop = self._arenaShop[nIndex or 1] or {}
    for k,v in pairs(data) do
        shop[tonumber(k)] = v
    end
    
   self:reflashData()
end

function GloryArenaModel:lGetSeasonReward()
    local rankStageAward = {}
    local season = self:lGetSeason()
    local rankStageData= clone(tab.rankStageAward)
    for key, var in ipairs(rankStageData) do
        if var and var.awardSeason == season then
            rankStageAward[#rankStageAward + 1] = var
        end
    end
    return rankStageAward
end
--获取商店的累积奖励
function GloryArenaModel:lGetAccumulateReward()
    local shop = self._arenaShop[1] or {}
    local rankStageAward = clone(tab.rankStageAward)--self:lGetSeasonReward()
    local reward = {}
    for key, var in pairs(shop) do
        if rankStageAward[key] then
            for _key, _var in ipairs(rankStageAward[key].award) do
                local newInsert = true
                if _var then
                    for __key, __var in ipairs(reward) do
                        if __var[1] == _var[1] and __var[2] == _var[2] then
                            newInsert = false
                            __var[3] = __var[3] + _var[3]
                            break
                        end
                    end
                end
                if newInsert then
                    reward[#reward + 1] = _var
                end
            end
        end
    end
    return reward or {}
--    self:reflashData()
end



function GloryArenaModel:lGetArenaShop(nIdex)
    return self._arenaShop[nIdex or 1] or {}
end


--判断是否有奖励可以领取
function GloryArenaModel:bIsCanReward()
    local honorArenaActivity = clone(tab.honorArenaActivity)
    local chalNum = self._selfAttackCount.chalNum or 0
    local shop = self._arenaShop[2] or {}
    for key, var in ipairs(honorArenaActivity) do
        if var and chalNum >= var.chalNum and shop[var.id] == nil then
            return true
        end
    end
    return false
end



--判断是否可以挑战
function GloryArenaModel:bIsCanAttack()
    return (self._selfAttackCount.num or 0) > 0
end

--判断是否有购买权限
function GloryArenaModel:bIsCanBuy()
    local shop = self._arenaShop[1] or {}
    -- local chalNum = self._selfAttackCount.chalNum or 0
    local rankStageAward = {}
    local season = self:lGetSeason()
    local rankStageData= clone(tab.rankStageAward)
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local currency = userData["honorCertificate"] or 0
    local posIndex = 0
    for key, var in ipairs(rankStageData) do
        if var and var.awardSeason == season then
            if var.limit > self._selfRank and shop[var.id] == nil and currency >= var.cost then
                return true, posIndex
            end
            posIndex = posIndex + 1
        end
    end
    return false, 0
end


function GloryArenaModel:reflashEnterCrossArena(callback)
    self._serverMgr:sendMsg("CrossArenaServer", "enterCrossArena", {},true ,{}, function(resule)
--        print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
        if callback then
            callback()
        end
    end)
end

--判断购买权限是否需要小红点
function GloryArenaModel:bIsCanBuyRed()
    if self:bIsCanBuy() then
        local saveTime = tonumber(SystemUtils.loadAccountLocalData("GLORY_ARENA_BUY_RED_TIME") or "0")
        local curTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()-- + 86400
        local sec_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 05:00:00"))
--        print("++++++++++++++++++++++++++++", TimeUtils.getDateString(saveTime,"%Y-%m-%d %H:%M:%S"), TimeUtils.getDateString(curTime,"%Y-%m-%d %H:%M:%S"), TimeUtils.getDateString(sec_time,"%Y-%m-%d %H:%M:%S"))
        if saveTime <= sec_time then
--            print("OOOOOOOOOOOOOOOOOOOO")
            return true
        end
        return false
    end
--        SystemUtils.saveAccountLocalData("AC_LORTTERY_EFFECT_PLAYED", isPlayed and 1 or 0)
    return false
end


function GloryArenaModel:bIsCanMainTips()
    if self:bIsCanAttack() or self:bIsCanReward() or self:bIsCanBuyRed() then
        return true
    end
    return false
end

--检查是否是新的赛季
function GloryArenaModel:lCheckSeason()
    local berSeason = tonumber(SystemUtils.loadAccountLocalData("GLORY_ARENA_SEASON") or "0")
    if tonumber(self._season) ~= berSeason and self._season ~= 0 then
        SystemUtils.saveAccountLocalData("GLORY_ARENA_SEASON", self._season)
        return true
    end
    return false
end


return GloryArenaModel
--endregion
