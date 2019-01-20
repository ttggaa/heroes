--[[
    Filename:    UserModel.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-04-28 12:04:09
    Description: File description
--]]

local UserModel = class("UserModel", BaseModel)

function UserModel:ctor()
    UserModel.super.ctor(self)
    self:listenGlobalResponse(specialize(self.interceptData, self))
    self._deltaTime = 0
    self._timezone = nil
    self._allowArrowUpdate = true
    self._platNickName = ""
    self._platPic = ""

    -- 贵宾特权是否领取过
    self._vipGift = 0

    -- 是否是支付top100 用户
    self._wxSubscribe = {}

    self:registerTimer(5, 0, 0, function ()
        self:checkLoginDays()
        -- 5点重置领取体力数据 hgf
        self:resetGetPhysicalData()
    end)

    self:registerTimer(0, 0, GRandom(0, 60), function ()
        self:simulationLogin()
    end)

    self:registerTimer(5, 0, GRandom(0, 10), function ()
        self:simulationLogin()
    end)
end

function UserModel:getAllowArrowUpdate()
    return self._allowArrowUpdate
end

function UserModel:getData()
    return self._data
end
 
-- 子类覆盖此方法来存储数据
function UserModel:setData(data)
    if data["arrowNum"] then  --射箭箭数 先进行防改换算  -by wangyan
        local arrowModel = self._modelMgr:getModel("ArrowModel")
        data["arrowNum"] = arrowModel:handleArrowNum(data["arrowNum"])
    end

    self._data = data
    if not self._data.statis then
        self._data.statis = {} 
    end

    if not self._data["luckyCoin"] then    --by wangyan
        self._data["luckyCoin"] = 0
    end

    if not self._data["plvl"] then    --by wangyan
        self._data["plvl"] = 0
    end

    self._lastLvl = self._data.lvl
    self._lastExpCoin = self._data.expCoin or 0
    self._lastPhysical = self._data.physcal
    self._lastPLvl = self._data.plvl
    self._lastPTalentPoint = self._data.pTalentPoint or 0

    -- 英雄全局专长
    self:setGlobalMasterys()

    self:reflashGem()
    self:reflashData("UserModel")
    if OS_IS_WINDOWS then
        RestartMgr:updateWindosTitle()
    end
end

function UserModel:reflashGem()
    if self._data.payGem == nil then 
        self._data.payGem = 0
    end
    if self._data.freeGem == nil then 
        self._data.freeGem = 0
    end
    self._data.gem = self._data.payGem + self._data.freeGem
end

--[[
    是否需要展示经验兑换
]]
function UserModel:isShowExpExchangeBtn()
    return self._data.openExpShop == 1
end

--[[
    是否经验满了，并且未进入过兑换商店
]]
function UserModel:isShowExpExchangeRedPoint()
    if not self:isShowExpExchangeBtn() then
        return
    end
    local isIn =  SystemUtils.loadAccountLocalData("EXP_SHOP_IN")
    if not isIn then
        return true
    end
end



-- --[[
-- --! @function updatePhyscal
-- --! @desc 更新体力与时间
-- --! @param updatePhyscal int 体力总值
-- --! @param inPhyTime int 最新一次更新体力时间
-- --! @return 
-- --]]
-- function UserModel:updatePhyscal(inPhyscal, inPhyTime)
--  self._data.physcal = inPhyscal
--  if inPhyTime ~= nil then 
--      self._data.upPhyTime = inPhyTime
--  end
--     self:reflashData()
-- end


--[[
--! @function updateUserData
--! @desc 更新用户信息
--! @param inData table 新的用户信息
--! @return 
--]]
function UserModel:updateUserData(inData)
    -- dump(inData,"show...userData .. ",5)
    local modelMgr = ModelManager:getInstance()
    if not inData then return end


    if inData["arrowNum"] then  --射箭箭数 先进行防改换算
        local arrowModel = self._modelMgr:getModel("ArrowModel")
        inData["arrowNum"] = arrowModel:handleArrowNum(inData["arrowNum"])
    end
    
    if inData.lvl then
        self._lastLvl = self._data.lvl
        self._lastExpCoin = self._data.expCoin or 0 
        self._lastPhysical = self._data.physcal
        modelMgr:getModel("TalentModel"):setOutOfDate()
        modelMgr:getModel("FormationModel").setFormationDialogShowed(false)
    end

    if inData.plvl then
        self._lastPLvl = self._data.plvl
        self._lastPTalentPoint = self._data.pTalentPoint or 0
    end

    if inData["items"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(inData["items"])
        inData["items"] = nil
    end


    local runes = inData["runes"]
    if runes ~= nil then 
        local teamModel = self._modelMgr:getModel("TeamModel")
        teamModel:updateHolyData(runes)
    end

    local rewardData = inData["reward"]
    if inData["reward"] ~= nil then 
        inData["reward"] = nil
    end

    local formationsData = inData["formations"]
    if inData["formations"] then
        modelMgr:getModel("FormationModel"):updateAllFormationData(inData["formations"])
        inData["formations"] = nil
    end

    local privilegesData = inData["privileges"]
    if inData["privileges"] ~= nil then 
        modelMgr:getModel("PrivilegesModel"):updatePrivilegeData(inData["privileges"])
        inData["privileges"] = nil
    end

    if inData["talent"] ~= nil then 
        -- modelMgr:getModel("TalentModel"):getData().score = inData["talent"]["score"] or 0
        modelMgr:getModel("TalentModel"):updateData(inData["talent"])

        inData["talent"] = nil
    end

    if inData["treasures"] ~= nil then 
        modelMgr:getModel("TreasureModel"):upDateTreasure(inData["treasures"])
        inData["treasures"] = nil
    end

    if inData["pokedex"] ~= nil then 
        modelMgr:getModel("PokedexModel"):updatePokedexData(inData["pokedex"])
        inData["pokedex"] = nil
    end
    
    if inData["adventure"] ~= nil then 
        -- modelMgr:getModel("TalentModel"):getData().score = inData["talent"]["score"] or 0
        modelMgr:getModel("AdventureModel"):updateAdventure(inData["adventure"])

        inData["adventure"] = nil
    end

    if inData["sign"] ~= nil then 
        modelMgr:getModel("SignModel"):updateData(inData["sign"])
        inData["sign"] = nil
    end

    if inData["arrow"] ~= nil then 
        modelMgr:getModel("ArrowModel"):updateData(inData["arrow"])
        inData["arrow"] = nil
    end

    if inData["vip"] ~= nil then 
        modelMgr:getModel("VipModel"):updateData(inData["vip"])
        inData["vip"] = nil
    end

    if inData["dayInfo"] ~= nil then 
        modelMgr:getModel("PlayerTodayModel"):updateDayInfo(inData["dayInfo"])
        inData["dayInfo"] = nil
    end

    if inData["leagueheros"] then
        modelMgr:getModel("LeagueModel"):upadateLeagueHeros(inData["leagueheros"])
        inData["leagueheros"] = nil
    end

    if inData["uMastery"] then
        self:updateuMastery(inData["uMastery"])
        inData["uMastery"] = nil
    end
    
    if inData["hAb"] then
        self:updateGlobalAttributes(inData["hAb"])
        inData["hAb"] = nil
    end
    
    if inData["branchHAb"] then
        self:updateBranchHAb(inData["branchHAb"])
        inData["branchHAb"] = nil
    end

    -- if inData["hStar"] and inData["hStar"]["qhab"] then
    --     self:updateHeroStarHAb(inData["hStar"]["qhab"])
    --     inData["hStar"] = nil
    -- end

    if inData["hStar"] then
        self:updateHeroStarInfo(inData["hStar"])
        inData["hStar"] = nil
    end
    if inData["element"] then
        modelMgr:getModel("ElementModel"):updateElementInfo(inData["element"])
        inData["element"] = nil
    end

    if inData["acHeroDuel"] then
        modelMgr:getModel("ActivityModel"):updateAcHeroDuelDataAfterF(inData["acHeroDuel"])
        inData["acHeroDuel"] = nil
    end

    local guildBackupData = inData["guildBackup"]
    if inData["guildBackup"] ~= nil then 
        if not self._data["guildBackup"] then
            self._data["guildBackup"] = {}
        end
        for i,value in pairs(inData["guildBackup"]) do
            if i == "guildDonate" then
                if not self._data["guildBackup"][i] then
                    self._data["guildBackup"][i] = {}
                end
                for donateId,donateflag in pairs(value) do
                    self._data["guildBackup"][i][donateId] = donateflag
                end
            else
                self._data["guildBackup"][i] = value
            end
        end
        inData["guildBackup"] = nil
    end

    local roleGuildData = inData["roleGuild"]
    if inData["roleGuild"] ~= nil then 
        if not self._data["roleGuild"] then
            self._data["roleGuild"] = {}
        end
        for i, value in pairs(inData["roleGuild"]) do
            if type(value) == "table" and next(value) ~= nil then
                if self._data["roleGuild"][i] == nil then 
                    self._data["roleGuild"][i] = {}
                end
                for k1,v1 in pairs(value) do
                    self._data["roleGuild"][i][k1] = v1
                end
            else
                self._data["roleGuild"][i] = value
            end
        end
        inData["roleGuild"] = nil
    end

    local updateSubData = function(inKey, inData)
        if not self._data[inKey] then
            self._data[inKey] = {}
        end
        for i, value in pairs(inData[inKey]) do
            if type(value) == "table" and next(value) then
                if not self._data[inKey][i] then
                    self._data[inKey][i] = value
                else
                    --todo
                    for kk,vv in pairs(value) do
                        self._data[inKey][i][kk] = vv
                    end
                end
            else
                self._data[inKey][i] = value
            end 
            -- self._data[inKey][i] = value
        end  
    end

    -- 更新幸运星活动的状态
    -- local luckStarData = inData["award"] and inData["award"]["luckStar"] or {}
    if inData["award"] and inData["award"]["luckStar"] then
        for i, value in pairs(inData["award"]["luckStar"]) do
            if type(value) == "table" and next(value) then
                if not self._data["award"]["luckStar"] then
                    self._data["award"]["luckStar"] = {}
                else
                    if not self._data["award"]["luckStar"][i] then
                        self._data["award"]["luckStar"][i] = value
                    else
                        for kk,vv in pairs(value) do
                            self._data["award"]["luckStar"][i][kk] = vv
                        end
                    end
                end
            else
                self._data["award"]["luckStar"][i] = value
            end 
        end 

        inData["award"]["luckStar"] = nil   
    end

    -- 幸运星（图灵）
    if inData["award"] and inData["award"]["turingLuckStar"] then
        for i, value in pairs(inData["award"]["turingLuckStar"]) do
            if type(value) == "table" and next(value) then
                if not self._data["award"]["turingLuckStar"] then
                    self._data["award"]["turingLuckStar"] = {}
                else
                    if not self._data["award"]["turingLuckStar"][i] then
                        self._data["award"]["turingLuckStar"][i] = value
                    else
                        for kk,vv in pairs(value) do
                            self._data["award"]["turingLuckStar"][i][kk] = vv
                        end
                    end
                end
            else
                self._data["award"]["turingLuckStar"][i] = value
            end 
        end 

        inData["award"]["turingLuckStar"] = nil   
    end


    local awardData = inData["award"]
    if inData["award"] ~= nil then 
        updateSubData("award", inData)
        inData["award"] = nil
    end

    local skillOpenData = inData["skillOpen"]
    if inData["skillOpen"] ~= nil then 
        updateSubData("skillOpen", inData)
        inData["skillOpen"] = nil
    end


    
    local statisData = inData["statis"] 
    if inData["statis"] ~= nil then 
        updateSubData("statis", inData)
        inData["statis"] = nil
    end

    local aFramesData = inData["avatarFrames"]
    if inData["avatarFrames"] ~= nil then 
        updateSubData("avatarFrames", inData)
        inData["avatarFrames"] = nil
    end

    local pokedexData = inData["pokedex"]
    inData["pokedex"] = nil

    local rcRdData = inData["rcRd"]
    if inData["rcRd"] ~= nil then 
        updateSubData("rcRd", inData)
        inData["rcRd"] = nil
    end

    if inData["share"] ~= nil then 
        updateSubData("share", inData)
        inData["share"] = nil
    end

    -- 处理英雄皮肤数据
    if inData["hSkin"] then
        self:updateSkinData(inData["hSkin"])
        inData["hSkin"] = nil
    end

    -- 处理兵团皮肤数据
    if inData["tSkin"] then
        self:updateTeamSkinData(inData["tSkin"])
        inData["tSkin"] = nil
    end

    -- 公测庆典数据
    if inData["celebrity"] ~= nil then
        local celebrationModel = self._modelMgr:getModel("CelebrationModel")
        celebrationModel:updateData(inData["celebrity"])
        inData["celebrity"] = nil
    end

    -- 处理联盟探索地图统计
    if inData["mapStatis"] ~= nil then 
        updateSubData("mapStatis", inData)
        inData["mapStatis"] = nil
    end  

    if inData["extra"] then
        updateSubData("extra", inData)
        inData["extra"] = nil
    end

    if inData and inData["weaponInfo"] ~= nil  then 
        local weaponsModel = self._modelMgr:getModel("WeaponsModel")
        weaponsModel:setData(inData["weaponInfo"])
        inData["weaponInfo"] = nil
    end 

    if inData and inData["backFlow"] ~= nil  then 
        local weaponsModel = self._modelMgr:getModel("BackflowModel")
        weaponsModel:updateBaseData(inData["backFlow"])
        inData["backFlow"] = nil
    end 

    -- 幸运抽奖
    if inData["runeLottery"] ~= nil then
        local runeLotteryModel = self._modelMgr:getModel("RuneLotteryModel")
        runeLotteryModel:updateServerData(inData["runeLottery"])
        inData["runeLottery"] = nil
    end

    -- 圣徽周卡
    if inData["runeCard"] then
        updateSubData("runeCard", inData)
        inData["runeCard"] = nil
    end

    if inData and inData["eleGift"] ~= nil  then 
        updateSubData("eleGift", inData)
        inData["eleGift"] = nil
    end

    -- 宝物直购
    if inData and inData["treasureMerchant"] ~= nil then 
        updateSubData("treasureMerchant", inData)
        inData["treasureMerchant"] = nil
    end
    for k,v in pairs(inData) do
        self._data[k] = v
    end

    if pokedexData ~= nil then  -- 图鉴要等玩家等级改变之后再处理数据
        modelMgr:getModel("PokedexModel"):updatePokedexData(pokedexData)
    end

    -- 以防界面用到，所以重新赋值
    inData["statis"] = statisData
    inData["award"] = awardData
    inData["skillOpen"] = skillOpenData
    inData["roleGuild"] = roleGuildData
    inData["guildBackup"] = guildBackupData
    inData["guildBackup"] = privilegesData
    inData["formations"] = formationsData
    inData["avatarFrames"] = aFramesData

     
    modelMgr:getModel("ActivityCarnivalModel"):setNeedUpdate(true)

    self:setGlobalMasterys()
    self:reflashGem()
    modelMgr:getModel("ActivityModel"):pushUserEvent()

    self:reflashData("UserModel")
    if OS_IS_WINDOWS then
        RestartMgr:updateWindosTitle()
    end
    SRDATAID = self._data.pid
end

function UserModel:isOneCash()
    return self._data.award.oneCash and self._data.award.oneCash > 0
end

function UserModel:getLastLvl()
    return self._lastLvl
end

function UserModel:getLastPhysical()
    return self._lastPhysical
end

function UserModel:getLastPLvl(  )
    return self._lastPLvl
end

function UserModel:getLastPTalentPoint(  )
    return self._lastPTalentPoint
end

function UserModel:updateScoreF1(score)
    if score then
        self._data.scoreF1 = score
    end
end

--[[
--! @function validationPhyles
--! @desc 验证种族标签
--! @param bool 是否存在
--! @return 
--]]
function UserModel:validationPhyles(inRace)
    if self._data.phyles == nil then 
        return false
    end
    local tmpPhyles = string.split(self._data.phyles, ",") 
    for k,v in pairs(tmpPhyles) do
        if tonumber(v) == tonumber(inRace) then 
            return true
        end
    end
    return false
end

-- 判断玩家是否加入联盟
function UserModel:getIdGuildOpen()
    local flag = false
    if self._data["guildId"] and self._data["guildId"] ~= 0 then
        flag = true
    end
    return flag
end

function UserModel:getIdipMessage()
    if not (self._data and self._data.idip and self._data.idip.msg) then return false end
    return true, self._data.idip.msg
end

function UserModel:setWarHero(heroId)
    self._data.currentHid = heroId
end

function UserModel:setDefaultFormationId(formationId)
    self._data.defaultForId = formationId
end

function UserModel:getLoginTime()   
    return self._data._lt
end

-- 获取当前服务器时间
function UserModel:getCurServerTime()
    return os.time() + self._deltaTime
end

-- 获取开服时间, 会强制转成当天5点
function UserModel:getOpenServerTime()
    local serverNowTime = os.time() + self._deltaTime
    local t = TimeUtils.date("*t", self._data.sec_open_time)
    if t.hour < 5 then
        local day = self._data.sec_open_time - 86400
        t = TimeUtils.date("*t", day)
    end
    local openTime = os.time({year = t.year, month = t.month, day = t.day, hour = 5, min = 0, sec = 0})
    return serverNowTime - openTime
end

--获取创角时间
function UserModel:getCreateRoleTime()
    local serverNowTime = os.time() + self._deltaTime
    local t = TimeUtils.date("*t", self._data._it)
    if t.hour < 5 then
        local day = self._data._it - 86400
        t = TimeUtils.date("*t", day)
    end
    local createTime = os.time({year = t.year, month = t.month, day = t.day, hour = 5, min = 0, sec = 0})
    return serverNowTime - createTime
end

function UserModel:adjustServerTime(time)
    self._deltaTime = time - os.time()
    self._modelMgr:setServerDeltaTime(self._deltaTime)
end

function UserModel:getPlayerLevel()
    return self._data.lvl
end

--[[
    玩家当前是否到达最大等级
]]
function UserModel:isMaxLevel()
    -- local maxlevel = tab:Setting("MAX_LV").value
    -- if maxlevel then
    --     return self._data.lvl >= tonumber(maxlevel)
    -- end

    return false
end

function UserModel:isHaveParagonLevel(  )
    local maxlevel = tab:Setting("MAX_LV").value
    if maxlevel then
        return self._data.lvl >= tonumber(maxlevel)
    end
    return false
end

function UserModel:isMaxParagonLevel(  )
    local maxlevel = tab:Setting("PARAGON_MAX_LEVEL").value
    if maxlevel then
        return (self._data.plvl or 0) >= tonumber(maxlevel)
    end
end

function UserModel:getUID()
    return self._data._id
end

function UserModel:getUSID()
    return self._data.usid
end

function UserModel:getPID()
    return self._data.pid
end

function UserModel:getUUID()
    if self._data.uuid == 0 then
        return self._data._id
    else
        return self._data.uuid
    end
end

function UserModel:getPFKey()
    return self._data.pfkey or ""
end

-- 获取对应货币数量
function UserModel:getCurrencyByType(cType)
    return self._data[cType] or 0 
end

function UserModel:hasTrigger(name)
    if self._data.trigger == nil then return false end
    return (self._data.trigger[tostring(name)] ~= nil)
end

function UserModel:setTrigger(name)
    if self._data.trigger == nil then 
        self._data.trigger = {}
    end
    self._data.trigger[tostring(name)] = 1
end

function UserModel:getRID()
    return self._data._id
end

function UserModel:getUserName()
    return self._data.name or ""
end

function UserModel:getSkillOpen()
    return self._data.skillOpen
end

function UserModel:getAccelerate()
    return self._data.accelerate
end

function UserModel:getQuit()
    return self._data.quit
end

-- 英雄全局专长
function UserModel:setGlobalMasterys(gs)
    self._globalMasterys = {}
    if gs == nil then
        gs = self._data.globalSpecial
    end
    if gs == nil then
        return
    end
    if gs ~= "" then
        self._globalMasterys = json.decode(gs)
    end
end

function UserModel:getGlobalMasterys()
    return self._globalMasterys
end

function UserModel:getGlobalAttributes()
    return self._data.hAb
end
--获取星图属性
function UserModel:getHeroStarHAb()
    if self._data.hStar then
        return self._data.hStar.qhab
    else
        return nil
    end
end

function UserModel:updateGlobalAttributes(data)
    if not data then return end
    -- dump(data, "updateGlobalAttributes:data", 5)
    if self._data.hAb == nil then
        self._data.hAb = {}
    end
    table.merge(self._data.hAb, data)
end

function UserModel:updateBranchHAb(data)
    if not data then return end
    -- dump(data, "updateBranchHAb:data", 5)
    if self._data.branchHAb == nil then
        self._data.branchHAb = {}
    end
    table.merge(self._data.branchHAb, data)
end
--星图属性
function UserModel:updateHeroStarHAb(data)
    if not data then return end
    if self._data.hStar == nil then
        self._data.hStar = {}
    else
        if self._data.hStar.qhab == nil then
            self._data.hStar.qhab = {}
        else
            table.merge(self._data.hStar.qhab, data)
        end
    end
end
--更新用户星图信息
function UserModel:updateHeroStarInfo(hStarInfo)
    if hStarInfo then
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
        if self._data["hStar"] == nil then
            self._data["hStar"] = hStarInfo
        else
            m(self._data["hStar"], hStarInfo)
        end
        
    end
end

function UserModel:getHeroStarInfo()
    return self._data["hStar"]
end

function UserModel:getuMastery()
    return self._data.uMastery
end

function UserModel:updateuMastery(data, isReplaceMastery)
    if not data then return end
    -- dump(data, "updateuMastery:data", 5)
    if self._data.uMastery == nil then
        self._data.uMastery = {}
    end
    if isReplaceMastery then
        self._data.uMastery = data
    else
        table.merge(self._data.uMastery, data)
    end
end

function UserModel:setPlayerStatis(data)
    self._data.statis = data
end

function UserModel:getPlayerStatis()
    return self._data.statis
end

function UserModel:updatePlayerStatis(data)
    if not (data and type(data) == "table") then return end
    if not (self._data.statis and data["d"] and data["d"].statis) then return end
    table.merge(self._data.statis, data["d"].statis)
    data["d"].statis = nil
    ModelManager:getInstance():getModel("ActivityModel"):evaluateActivityData()
    ModelManager:getInstance():getModel("ActivityCarnivalModel"):setNeedUpdate(true)
end

function UserModel:setActivityStatis(data)
    self._data.activityStatis = data
end

function UserModel:getActivityStatis()
    return self._data.activityStatis
end

-- 终极降临活动联盟统计值
function UserModel:getAcGuildStatis()
    return self._data.guildStatis
end

function UserModel:updateActivityStatis(data)
    if not (data and type(data) == "table") then return end
    if not (self._data.activityStatis and data["d"] and data["d"].activityStatis) then return end
    for k, v in pairs(data["d"].activityStatis) do
        if not self._data.activityStatis[tostring(k)] then
            self._data.activityStatis[tostring(k)] = {}
        end
        for k0, v0 in pairs(v) do
            self._data.activityStatis[tostring(k)][tostring(k0)] = v0
        end
    end
    data["d"].activityStatis = nil
    ModelManager:getInstance():getModel("ActivityModel"):evaluateActivityData()
    ModelManager:getInstance():getModel("ActivityCarnivalModel"):setNeedUpdate(true)
    ModelManager:getInstance():getModel("AcUltimateModel"):setNeedUpdate(true)
end

function UserModel:updateAcGuildStatis(data)
    if not (data and type(data) == "table") then return end
    if not (self._data.guildStatis and data["d"] and data["d"].guildStatis) then return end
    for k, v in pairs(data["d"].guildStatis) do
        if not self._data.guildStatis[tostring(k)] then
            self._data.guildStatis[tostring(k)] = {}
        end
        for k0, v0 in pairs(v) do
            self._data.guildStatis[tostring(k)][tostring(k0)] = v0
        end
    end
    data["d"].guildStatis = nil
    ModelManager:getInstance():getModel("ActivityModel"):evaluateActivityData()
    ModelManager:getInstance():getModel("AcUltimateModel"):setNeedUpdate(true)
end

function UserModel:isAcGoodsBuy(activityId)
    if not (self._data.award and self._data.award.simBuyGoods) then return false end
    return 1 == self._data.award.simBuyGoods[tostring(activityId)]
end

-- 顶层拦截因用户升级引起的英雄数据更新
function UserModel:updateHeroWhenUserLvlUp(data)
    if not (data and type(data) == "table") then return end
    if not ( data["d"] and data["d"].heros) then return end
    if data["d"]["heros"] ~= nil then 
        local heroModel = self._modelMgr:getModel("HeroModel")
        heroModel:unlockHero(data["d"]["heros"])
    end
end

function UserModel:interceptData(data)
    if not (data and type(data) == "table") then return end
    if data["d"] and data["d"].statis then 
        self:updatePlayerStatis(data)
    end

    if data["d"] and data["d"].activityStatis then 
        self:updateActivityStatis(data)
    end
    if data["d"] and data["d"].guildStatis then 
        self:updateAcGuildStatis(data)
    end

    if data["d"] and data["d"].heros then 
        self:updateHeroWhenUserLvlUp(data)
    end

    if data["d"] and data["d"].raceDraws then 
        local raceDrawModel = self._modelMgr:getModel("RaceDrawModel")
        raceDrawModel:updateData(data["d"].raceDraws)
        -- data["d"].raceDraws = nil
    end

end

-- 宣言
-- 设置宣言
function UserModel:setSlogan( msg )
    self._data.msg = msg
    self:reflashData()
end
-- 返回宣言
function UserModel:getSlogan( msg )
    return self._data.msg
end

-- 获取玩家身上公会的基本数据
function UserModel:getRoleAlliance(isLog)
    local curServerTime = self:getCurServerTime()
    local t = TimeUtils.date("*t", curServerTime)
    local curServerTime2 = curServerTime
    if t.hour < 5 then
        curServerTime2 = curServerTime2 - 86400
    end
    -- print("curServerTime:",curServerTime)
    -- local tempTodayTime = os.time({year = t.year, month = t.month, day = t.day, hour = 5, min = 0, sec = 0})
    local tempTodayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime2,"%Y-%m-%d 05:00:00"))
    -- print("tempTodayTime:",tempTodayTime)
    -- local tempTodayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    -- print("lastTime",self._data.roleGuild.lastTime)
    if curServerTime >= tempTodayTime then
        if not self._data.roleGuild.lastTime then self._data.roleGuild.lastTime = 0 end
        if self._data.roleGuild.lastTime < tempTodayTime then
            self._data.roleGuild.dTimes = 0
        end
    end
    if isLog then
        return self._data.roleGuild,tempTodayTime,curServerTime
    end
    return self._data.roleGuild
end

function UserModel:checkLoginDays()
    local tempTodayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    local tempCreateTIme = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(self._data._it,"%Y-%m-%d 05:00:00"))     
    local loginDay = (tempTodayTime - tempCreateTIme) / 86400
    if loginDay > self._data.statis.snum6 then 
        self._data.statis.snum6 = loginDay
    end
end

function UserModel:simulationLogin()
    self._allowArrowUpdate = false  --防止同步过程中玩家仍在点击消耗箭
    local function userUpdate()
        local _network = 0
        local _netType = AppInformation:getInstance():getNetworkType()
        if _netType == 2 then
            _network = 2
        elseif _network == 3 then
            _network = 1
        end
        self._serverMgr:sendMsg("UserServer", "simulationLogin", {network = _network}, true, {}, function(data)
            self:updateUserData(data)
            self._serverMgr:sendMsg("UserServer", "getPlayerAction", {}, true, {}, function ()
                self._serverMgr:sendMsg("GlobalServer", "getAll", {}, true, {})
                self._allowArrowUpdate = true
            end)
        end)
    end

    --射箭同步[防止未同步的后端数据覆盖model数据]
    local syncData = SystemUtils.loadAccountLocalData("syncArrowData")
    if syncData ~= nil and type(syncData) == "table" and syncData["arrowList"] and next(syncData["arrowList"]) ~= nil then
        syncData["mStatis"][1] = syncData["mStatis"][1] + 1
        syncData["syncReqId"] = SystemUtils.loadAccountLocalData("SYNC_ARROW_REQUEST_ID") or 1  --上次同步id
        ServerManager:getInstance():sendMsg("ArrowServer", "syncArrowData", syncData, true, {}, function (result)
            userUpdate()
            end)
        return
    end
    userUpdate()
end

-- 玩家体力恢复满时间
function UserModel:getPhysicFullTime( )
    if self._data == nil or self._data._id == nil then 
        return 0
    end
    local privileges = self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_7) or 0
    local privilegeBuff = 0
    if privileges then
        privilegeBuff = privileges or 0
    end

    local upPhyTime = self._modelMgr:getModel("UserModel"):getData().upPhyTime or self._modelMgr:getModel("UserModel"):getCurServerTime()
    local maxPhyNum = (tab:Setting("G_INITIAL_PHYSCAL_MAX").value or 0)+privilegeBuff
    if self._data.physcal >= maxPhyNum then
        return -1
    end
    local physcalAdd = tab:Setting("G_PHYSCAL_ADD").value*60
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    
    local lastTime = physcalAdd - (nowTime-upPhyTime)%physcalAdd
    local lastFull = (maxPhyNum-self._modelMgr:getModel("UserModel"):getData().physcal)*physcalAdd+lastTime
    return lastFull
end


function UserModel:isBigPrivilege()
    local guildPower = tab:Setting("G_INITIAL_GUILDPOWER_MAX").value or 0
    local guildPowerBuff1 = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.AlliancePower1)
    local guildPowerBuff = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.AlliancePowerMax)
    guildPower = guildPower + guildPowerBuff + guildPowerBuff1
    return guildPower
end

-- 玩家行动力恢复满时间
function UserModel:getGuildPowerFullTime()
    -- 防止push出发在loading前面
    if self._data == nil or self._data._id == nil then 
        return 0
    end
    local maxGuildNum = self:isBigPrivilege() or 0
    local guildAdd = tab:Setting("G_GUILDPOWER_ADD").value*60 or 0
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local nowNum = userData.guildPower or 0
    if maxGuildNum - nowNum > 0 then
        local upGPTime = userData.upGPTime or self._modelMgr:getModel("UserModel"):getCurServerTime()
        local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
        return guildAdd * (maxGuildNum - nowNum) - (nowTime-upGPTime)%guildAdd
    end
    return 0
end

-- 获得玩家战斗力 不传值时返回table
function UserModel:getUserScore( sys )
    local formationModel = self._modelMgr:getModel("FormationModel")
    local data = formationModel:getFormationData()[formationModel.kFormationTypeCommon]
    if not data  then
        return 0
    end
    local teamScore = 0
    local pScore = 0
    local teamModel = self._modelMgr:getModel("TeamModel")
    table.walk(data, function(v, k)
        if 0 == v then return end
        if string.find(tostring(k), "team") and not string.find(tostring(k), "g") then
            local teamData = teamModel:getTeamAndIndexById(v)
            teamScore = teamScore + teamData.score
            pScore = pScore + teamData.pScore
        end
    end)
    local heroData = self._modelMgr:getModel("HeroModel"):getData()[tostring(data.heroId)]
    local heroScore = heroData and heroData.score or 0
    local treasureScore = self._modelMgr:getModel("TreasureModel"):getTreasureScore()
    local total = formationModel:getCurrentFightScoreByType(formationModel.kFormationTypeCommon)
    local talentScore = self._modelMgr:getModel("TalentModel"):getBattleNum()
    local weaponScore = self._modelMgr:getModel("WeaponsModel"):getWeaponAllScore()
    local allScore = {
        hero = heroScore,
        team = total-heroScore-treasureScore-pScore-talentScore,
        treasure = treasureScore,
        pokedex = pScore,
        talent = talentScore,
        total = total,
        siegeWeapon = weaponScore,
    }
    if sys then 
        return allScore[sys] or 0
    else
        return allScore
    end
end

-- 领取体力数据结构重置 hgf
function UserModel:resetGetPhysicalData()
    if self._data["award"] then
        self._data["award"]["dailyPy"] = {}
    end
end

function UserModel:updateGuildLevel(level)
    if level then
        print("=======更新联盟等级=======", level)
        self._data.guildLevel = level 
        self:reflashData()
    end
end

function UserModel:getShareStatus(inShareId)
    local sysShareAward = tab:ShareAward(inShareId)
    local userShareData = self._data.share

    if userShareData == nil or userShareData[tostring(inShareId)] == nil then 
        return true, sysShareAward.award[1]
    end
    local userShareInfo = userShareData[tostring(inShareId)]
    -- 分享奖励领取达到上限时判断原因
    if (userShareInfo.c + 1) > #sysShareAward.award then 
        if sysShareAward.timelimit == nil then 
            return false, 0 
        end

        -- 如果到达重置时间则清空次数
        -- local nextShareTime = userShareInfo.t + sysShareAward.timelimit
        -- local nowTime = self:getCurServerTime()
        -- if nextShareTime > nowTime then 
        --     return false, nowTime - nextShareTime
        -- end

        --改为固定每天5点重置    edit by yuxiaojing
        local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
        local todayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime, "%Y-%m-%d 05:00:00"))
        if not (todayTime > userShareInfo.t and curServerTime >= todayTime) then
            return false, 0
        end
        userShareInfo.c = 0
    end
    return true, sysShareAward.award[userShareInfo.c + 1]
end

-- 获取英雄全局属性
function UserModel:getHeroGlobalhAb()
    if not self._data then return end
    return self._data.hAb or {}
end

-- 设置WX订阅
function UserModel:setWXSubscribe(inWXSubscribe)
    if not inWXSubscribe then return end
    self._wxSubscribe = inWXSubscribe
end

function UserModel:getWXSubscribe()
    return self._wxSubscribe
end

function UserModel:handleConstList(inConstList)
    GameStatic.opencode = inConstList["opencode"]
    if inConstList["appleExamine"] ~= nil then
        if tonumber(inConstList["appleExamine"]) == 1 then
            GameStatic.appleExamine = true
        end
    end
    if inConstList["questionList"] ~= nil then
        local map = inConstList["questionList"]
        -- dump(map)
        for k, v in pairs(map) do
            GameStatic[k] = v
        end
    end
    if inConstList["crossPK"] ~= nil then
        self:setCrossPKConstData(inConstList["crossPK"])
        inConstList["crossPK"] = nil
    end
    if inConstList["radio"] ~= nil then
        self:setRadioConstData(inConstList["radio"])
        inConstList["radio"] = nil
    end
    if inConstList["godWar"] ~= nil then
        self:setGodWarConstData(inConstList["godWar"])
        inConstList["godWar"] = nil
    end
    if inConstList["TIME_ZONE"] ~= nil then
        TimeUtils.serverTimezone = inConstList["TIME_ZONE"]
        TimeUtils.serverUTC = TimeUtils.serverTimezone / 3600
    end
    if inConstList["subscribeList"] ~= nil then
        self:setWXSubscribe(inConstList["subscribeList"])
    end

    if inConstList["vipgift"] ~= nil then
        self._vipGift = inConstList["vipgift"]
    end
    if inConstList["powerGameUrl"] then 
        GameStatic.powerGameUrl = inConstList["powerGameUrl"]
    end
    self._platNickName = inConstList.nickName or ""
    self._platPic = inConstList.pic or ""
end

function UserModel:setCrossPKConstData(data)
    self._crossConst = data
end

function UserModel:getCrossPKConstData()
    return self._crossConst or {}
end

function UserModel:setGodWarConstData(data)
    self._godWarConst = data
end

function UserModel:getGodWarConstData()
    return self._godWarConst
end

function UserModel:setRadioConstData(data)
    self._radioConst = data
end

function UserModel:getRadioConstData()
    return self._radioConst or {}
end

function UserModel:isRadioActivityOpen( )
    return self._radioConst and self._radioConst["open"] == 1 or false
end




function UserModel:setVipGift(inVipGift)
    self._vipGift = inVipGift
end

function UserModel:getVipGift()
    return self._vipGift
end

-- 获取玩家所有皮肤数据
function UserModel:getUserSkinData()
    return self._data.hSkin or {}
end

-- 获取玩家英雄英雄Id皮肤数据
function UserModel:getSkinDataById(heroId)
    -- dump(self._data,"self._data",5)
    if not heroId then return {} end
    local skinData = {}
    if self._data and self._data.hSkin then
        skinData = self._data.hSkin[tostring(heroId)] or {}
    end    
    return skinData
end

-- 更新皮肤数据
function UserModel:updateSkinData(skinData)
    if not skinData then return end
    -- dump(skinData,"skinData==>",5)
    if self._data and self._data.hSkin then
        local uSkinData = self._data.hSkin
        for k,v in pairs(skinData) do
            if uSkinData[tostring(k)] and type(v) == "table" then
                for kk,vv in pairs(v) do
                    uSkinData[tostring(k)][tostring(kk)] = vv
                end
            else
                uSkinData[tostring(k)] = v
            end
        end
       
    end
end

-- 获取玩家所有兵团皮肤数据
function UserModel:getTeamSkinData()
    return self._data.tSkin or {}
end

-- 获取玩家兵团Id皮肤数据
function UserModel:getTeamSkinDataById(teamId)
    if not teamId then return {} end
    local skinData = {}
    if self._data and self._data.tSkin then
        skinData = self._data.tSkin[tostring(teamId)] or {}
    end    
    return skinData
end

-- 更新兵团皮肤数据
function UserModel:updateTeamSkinData(skinData)
    if not skinData then return end
    -- dump(skinData,"skinData==>",5)
    if self._data then
        local uSkinData = self._data.tSkin or {}
        for k,v in pairs(skinData) do
            if uSkinData[tostring(k)] and type(v) == "table" then
                for kk,vv in pairs(v) do
                    uSkinData[tostring(k)][tostring(kk)] = vv
                end
            else
                if type(v) == "table" then
                    uSkinData[tostring(k)] = {}
                    for kk, vv in pairs(v) do
                        uSkinData[tostring(k)][tostring(kk)] = vv
                    end
                end
            end
        end
        self._data.tSkin = uSkinData
    end
end

-- 根据区服id获取平台信息
function UserModel:getPlatformInfoById(serverId)
    if not self._data and not serverId then return "","0区" end
    local platformGroups = self._data.platformGroups or {}
    -- dump(platformGroups,"platformGroups==>",5)
    if not self._platformGroups then        
        self._platformGroups = {}
        for k,v in pairs(platformGroups) do
            local idArr = string.split(v, "-")
            local obj = {}
            obj.key = k
            obj.idRange = idArr
            table.insert(self._platformGroups, obj)
        end
    end
    -- dump(self._platformGroups,"self._platformGroups",4)
    if not self._platformKeyTb then
        self._platformKeyTb = {
            iwx = "IOS 微信",
            iqq = "IOS QQ",
            awx = "安卓 微信",
            aqq = "安卓 QQ",
            default = "win 开发",
        }
    end

    local platformStr = ""
    local idStr = ""
    local serverData
    for k,v in pairs(self._platformGroups) do
        if tonumber(serverId) >= tonumber(v.idRange[1]) and tonumber(serverId) <= tonumber(v.idRange[2]) then
            serverData = v
            break
        end
    end

    if serverData then
        platformStr = self._platformKeyTb[serverData.key]
        idStr = tonumber(serverId) % 1000
    else
        platformStr = self._platformKeyTb["default"]
        idStr = 0
    end
    -- print("=================platformStr idStr",platformStr,idStr)
    return platformStr ,idStr.."区"
end

-- 更新心悦特权红点信息
function UserModel:setRedDotsData(data)
    if not data or not data.redDots then return end
    local uRedDots = self._data.redDots
    for k,v in pairs(data.redDots) do
        uRedDots[k] = v
    end
end

-- 获取红点信息
function UserModel:getRedDotsData()
    return self._data.redDots or {}
end

function UserModel:checkPlatShareState()
    if GameStatic.appleExamine then
        return false
    end

    if not(sdkMgr:isWX() or sdkMgr:isQQ() or OS_IS_WINDOWS) then
        return false
    end

    return true
end

function UserModel:isHideVip( typeStr )
    local hideVip = false
    local typeStrs = {chat = "1",userInfo = "2", guild = "3",friend = "4"}
    local hideIdx = typeStrs[typeStr]
    if self._data.extra and self._data.extra.hideVip and self._data.extra.hideVip[hideIdx] then
        hideVip = self._data.extra.hideVip[hideIdx] == 1
    end
    return hideVip
end

function UserModel:getChangePakageVer( )
    local changePackageVer
    if self._data.extra and self._data.extra.packageVer then
        changePackageVer = self._data.extra.packageVer
    end
    return changePackageVer
end

function UserModel:getTaskStatisByType(inType)
    local statis = self._data["mapStatis"]
    if statis and statis[tostring(inType)] then
        return statis[tostring(inType)]
    end

    return 0
end

-- 元素领奖之后更新extraData
function UserModel:updateExtraData(data)
    if not data or not data["extra"] then return end
    if not self._data then return end
    local exraData = data["extra"]
    for k,v in pairs(exraData) do
        if self._data["extra"] then
            self._data["extra"][k] = v
        else
            self._data["extra"] = {}
            self._data["extra"][k] = v
        end
    end
end

-- 获取元素分享领奖状态
function UserModel:getElementGetState(acId)
    local state = false
    if self._data and self._data.extra and self._data.extra.shareWithNoCondition then
        state = self._data.extra.shareWithNoCondition[tostring(acId)]
        if state and state > 1 then
            state = true
        end
    end

    return state
end


function UserModel:getTopPayWeekRewardState()
    local lastVip = 0
    if self._data["extra"] ~= nil and self._data["extra"].lastVip  ~= nil then
        lastVip = self._data["extra"].lastVip
    end
    if lastVip == 0 then return false end
    local operateDate = TimeUtils.date("*t", lastVip)
    local w = operateDate.wday
    if w == 1 then 
        w = 7
    else
        w = operateDate.wday - 1
    end
    
    local curtime = self:getCurServerTime()
    local sundaytime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(lastVip + (7 - w) * 86400,"%Y-%m-%d 23:59:59"))
    if curtime > sundaytime then 
        return false
    end

    return true
end

-- 抽卡使用钻石还是幸运币 : true 幸运币 false 钻石
function UserModel:drawUseLuckyCoin( )
    return true
end

-- 返回玩家累计消耗的钻石数
function UserModel:getTotalConsumeDiamond()
    local activityStatis = self:getActivityStatis()
    local total = 0
    for k,v in pairs(activityStatis) do
        if v then
            local consume = v.sts5 or 0
            total = total + consume
        end 
    end
    return total
end
---同步联盟Id（联盟解散或者被踢出联盟时,如果没有收到推送的时候,需要手动更新联盟id）
function UserModel:simulationGuildId()
    self._serverMgr:sendMsg("UserServer", "getUserGuildId", {}, true, {}, function(data)
        if data then
            if data["guildId"] ~= nil then
                self._data["guildId"] = data["guildId"]
            end
        end
    end)
end

--合服后id表映射
function UserModel:getServerIDMap()
    -- dump(self._data["mergeList"],"UserModel:getServerIDMap",10)
    return self._data["mergeList"] or {}
end

--获取秘境数据
function UserModel:getFamCreateTime()
    if self._data.roleGuild then
        return self._data.roleGuild.havaSecretLandTime
    end
    return 0
end

--获取联盟秘境类型
function UserModel:getFamType()
    if self._data.roleGuild then
        return self._data.roleGuild.havaSecretLandType
    end
    return 0
end

-- 好友邀请（活动）
function UserModel:getPromotionData()
    if self._data then 
        return self._data.promotion or {}
    end
    return {}
end
--获取星图增加的英雄全局属性
function UserModel:getStarHeroAttr()
    local heroStar = self._data["hStar"]
    starAttr = {}
    local starChartsStarsTab = tab.starChartsStars
    if heroStar then
        -- 星链
        for catenId,catenNum in pairs(heroStar.scmap or {}) do
            local catenInfo = tab.starChartsCatena[tonumber(catenId)]
            if catenInfo then
                local aid = tonumber(catenInfo.quality_type) or 0
                local value = tonumber(catenInfo.quality) or 0
                starAttr[aid] = starAttr[aid] or 0
                starAttr[aid] = starAttr[aid] + value*catenNum
            end
        end
        -- 星图(构成)
        for heroId,heroNum in pairs(heroStar.smap or {}) do
            local starChartsTab = tab.starCharts 
            for _,starInfo in pairs(starChartsTab) do
                if tonumber(heroId) == tonumber(starInfo.hero) then
                    local chartsId = starInfo.id
                    local starInfo = starChartsTab[tonumber(chartsId)]
                    local aid = tonumber(starInfo.quality_type1) or 0
                    local value = tonumber(starInfo.quality1) or 0
                    starAttr[aid] = starAttr[aid] or 0
                    starAttr[aid] = starAttr[aid] + value
                    aid = tonumber(starInfo.quality_type2) or 0
                    value = tonumber(starInfo.quality2) or 0
                    starAttr[aid] = starAttr[aid] or 0
                    starAttr[aid] = starAttr[aid] + value
                end
            end
        end
        --已激活星团属性
        for bodyId,bodyNum in pairs(heroStar.ssmap or {}) do
            local aid = tonumber(starChartsStarsTab[tonumber(bodyId)]["quality_type"])
            if aid then
                local value = starChartsStarsTab[tonumber(bodyId)]["quality"]
                starAttr[aid] = starAttr[aid] or 0
                starAttr[aid] = starAttr[aid] + value*bodyNum
            end
            local abilitySort = starChartsStarsTab[tonumber(bodyId)]["ability_sort"]
            local abilityShowtype = starChartsStarsTab[tonumber(bodyId)]["ability_showtype"]
            local abilitySystem = starChartsStarsTab[tonumber(bodyId)]["ability_system"]
            if (abilitySort and abilitySort == 2) and (abilityShowtype and abilityShowtype == 1)
                and (abilitySystem and abilitySystem == 0) then
                local aid = tonumber(starChartsStarsTab[tonumber(bodyId)]["ability_hero_type"])
                if aid then
                    local value = starChartsStarsTab[tonumber(bodyId)]["ability_hero"]
                    starAttr[aid] = starAttr[aid] or 0
                    starAttr[aid] = starAttr[aid] + value*bodyNum
                end
            end
        end
        -- 突破属性
        local qHab = self:getHeroStarHAb()
        if qHab then
            for key , value in pairs(qHab) do
                starAttr[tonumber(key)] = starAttr[tonumber(key)] or 0
                starAttr[tonumber(key)] = starAttr[tonumber(key)] + value
            end
        end
    end
    return starAttr
end
--获取星图增加的兵团全局属性
--只计算给几人兵团加的属性值
function UserModel:getStarTeamAttr()
    local heroStar = self._data["hStar"]
    teamAttr = {}
    if heroStar then
        --已激活星团属性
        for bodyId,bodyNum in pairs(heroStar.ssmap or {}) do
            local starChartsStarsTab = tab.starChartsStars
            local abilityShowtype = starChartsStarsTab[tonumber(bodyId)]["ability_showtype"]
            local abilitySort = starChartsStarsTab[tonumber(bodyId)]["ability_sort"]
            if tonumber(abilityShowtype) == 2 and tonumber(abilitySort) == 2 then
                local abilityTeamType = tonumber(starChartsStarsTab[tonumber(bodyId)]["ability_team_type"])
                if abilityTeamType ~= 0 then
                    local aid = tonumber(starChartsStarsTab[tonumber(bodyId)]["ability_team_sort"])
                    local value = starChartsStarsTab[tonumber(bodyId)]["ability_team_num"]
                    teamAttr[aid] = teamAttr[aid] or 0
                    teamAttr[aid] = teamAttr[aid] + value
                end
            end
        end
    end
    return teamAttr
end

function UserModel:getRuneCardData()
    if self._data then 
        return self._data.runeCard or {}
    end
    return {}
end

-- 元素馈赠
function UserModel:getElementGiftData()
    if self._data then 
        return self._data.eleGift or {}
    end
    return {}
end

function UserModel:getResNumByType( costType )
    local player = self._data
    local num = player[costType] or (player.roleGuild and player.roleGuild[costType]) 
    if num == nil then
        if tonumber(costType) then
            if tab.tool[tonumber(costType)] then 
                _,num = self._modelMgr:getModel("ItemModel"):getItemsById(tonumber(costType))
            end
        end
    end
    if costType == "dice" then
        num = self._modelMgr:getModel("AdventureModel"):getHadDiceNum()
    end
    return num or 0
end

function UserModel:getServerId()
    local serverId = self._data.sec
    serverId = tostring(serverId)
    local mergeList = self:getServerIDMap()
    local fserverId = mergeList[serverId] or serverId
    return serverId, fserverId
end

function UserModel:isEvaluateLastGuild()
    local hadJudge = self._data.roleGuild and self._data.roleGuild.hadJudge
    return hadJudge==1
end

function UserModel:getLastGuildName()
    local lastName = self._data.roleGuild and self._data.roleGuild.lastGuildName
    return lastName
end

-- 宝物直购
function UserModel:getTreasureMerchant()
    if self._data then 
        return self._data.treasureMerchant or {}
    end
    return {}
end

function UserModel:updateAreaSkillData( data )
    if not data or not data["areaSkillTeam"] then return end
    if not self._data then return end
    self._data["areaSkillTeam"] = data["areaSkillTeam"]
end

return UserModel