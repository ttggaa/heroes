--[[
    Filename:    GuildMapCommonBattle.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-08-19 16:50:59
    Description: File description
--]]

local GuildMapCommonBattle = class("GuildMapCommonBattle", BaseMvcs)

function GuildMapCommonBattle:ctor()
    GuildMapCommonBattle.super.ctor(self)
    self._isPass = 0
end

function GuildMapCommonBattle:getPvpRes()
    local teamMap = {}
    for i = 1, #self._playerInfo.team do
        teamMap[self._playerInfo.team[i].id] = true
    end
    for i = 1, #self._enemyInfo.team do
        teamMap[self._enemyInfo.team[i].id] = true
    end
    local teamArr = {}
    for k, v in pairs(teamMap) do
        teamArr[#teamArr + 1] = k
    end

    local teamId = 101
    if #teamArr > 0 then
        teamId = teamArr[GRandom(#teamArr)]
    end
    BattleUtils.loadingTeamId = teamId
    cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION2_D)
    self._loadingView = self:createLayer("global.LoadingView", {type = BattleUtils.BATTLE_TYPE_GuildPVP, teamId = teamId, noLoading = true})
    self._viewMgr:getCurView():getLayerNode():addChild(self._loadingView)


    self._viewMgr:lock(-1)
    self._enterBattle = true
    ScheduleMgr:delayCall(0, self, function()
        self._viewMgr:unlock()
        -- 检查静态数据表
        if GameStatic.checkTable then
            local res = BattleUtils.checkTable_GuildPVP(self._playerInfo, self._enemyInfo)
            if res ~= nil then
                if OS_IS_WINDOWS then
                    ViewManager:getInstance():onLuaError("配置表被更改: "..res)
                else
                    ApiUtils.playcrab_lua_error("tab_xiugai_gpvp", res)
                    if GameStatic.kickTable then
                        do _G["AppExit"..math.random(10)]() if not APP_EXIT then ServerManager = nil ModelManager = nil end return end
                        return
                    end
                end
            end
        end

        local battleResult = BattleUtils.enterBattleView_GuildPVP(self._playerInfo, self._enemyInfo, nil, nil, true)
        if battleResult.win then
            battleResult.win = 1
        else
            battleResult.win = 0
        end
        local mySelfHp = math.ceil(battleResult.hp[1] / battleResult.hp[2] * 100)
        local enemyHp = math.ceil(battleResult.hp[3] / battleResult.hp[4] * 100)
        if self._battleWin == 1 and mySelfHp <= 0 then 
            mySelfHp = 1
        end

        self._serverMgr:sendMsg("GuildMapServer", "getPvpRes", 
            {tagPoint = self._targetId, isPass = self._isPass, aimId = self._operateUserId, 
            args = json.encode({win= battleResult.win, time = battleResult.time,
                serverInfoEx = json.encode({
                    battleTime = battleResult.battleTime,
                    heroID = battleResult.heroID,
                    walleVersion = GameStatic.walleVersion,
                    localTime = os.time(),
                }),
                uhp = mySelfHp, mhp = enemyHp})}, true, {}, function (result)
            if self.getPvpResFinish == nil then return end
            return self:getPvpResFinish(result)
        end)
    end)
end

function GuildMapCommonBattle:getPvpResFinish(result)
    self._battleResult = result
    if result.code ~= nil then 
        if result.code == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_SWITCH_MAP then
            self._modelMgr:getModel("GuildMapModel"):lockPush()
        elseif tostring(result.code) ~= "0"  then
            self._viewMgr:popView()
            
            if GuildConst.GUILD_MAP_RESULT_CODE_TIP[result.code] == nil then
                ViewManager:getInstance():showTip("code:" .. result.code)
            else
                ViewManager:getInstance():showTip(lang("GUILD_MAP_RESULT_CODE_TIP_" .. result.code))
            end
            self:closeInit()
            return
        end
    end
    self:enterArenaBattle()
end

function GuildMapCommonBattle:enterArenaBattle()
    self._viewMgr:popView()
    self._enterBattle = true
    BattleUtils.enterBattleView_GuildPVP(self._playerInfo, self._enemyInfo,
    function (info, callback)
        -- 战斗结束
        if info.win then
            self._battleWin = 1
        end
        if self._battleResult == nil then 
            ViewManager:getInstance():popView()
            ViewManager:getInstance():showTip("战斗结束，数据同步中")
            if self.close == nil then return end
            self:close(true)
            return
        end
        callback(self._battleResult)
    end,
    function (info)
        print("退出战斗")
        if self.close == nil then return end
        -- 退出战斗
        -- ViewManager:getInstance():popView()
        self._battleResult.win = self._battleWin
        self._callback(self._battleResult)
        self:close(true)
    end, false)
    self._viewMgr:unlock()
end


function GuildMapCommonBattle:getAimInfo(inUserId, isPass)
    print("getAimInfo========================")
    if isPass == nil then 
        self._isPass = 0 
    else
        self._isPass = isPass
    end
    self._battleWin = 0
    self._operateUserId = inUserId
    self._serverMgr:sendMsg("GuildMapServer", "getAimInfo", {tagPoint = self._targetId, aimId = inUserId, isPass = self._isPass, serverInfoEx = BattleUtils.getBeforeSIE()}, true, {}, function (result)
        -- 容错，激烈战斗下可能会主动关闭当前页面，此时的callback会出错
        if self.getAimInfoFinish == nil then return end

        return self:getAimInfoFinish(result)
    end)
end

function GuildMapCommonBattle:getAimInfoFinish(result)
    if result == nil then 
        ApiUtils.playcrab_lua_error("GuildMapCommonBattle getAimInfoFinish===== result is empty", serialize({}))
        return
    end 
    -- if 1 == 1 then self:closeInit() return end

    if result.code ~= nil then 
        if GuildConst.GUILD_MAP_RESULT_CODE_TIP[result.code] == nil then
            self._viewMgr:showTip("code:" .. result.code)
        else
            self._viewMgr:showTip(lang("GUILD_MAP_RESULT_CODE_TIP_" .. result.code))
        end
        self:closeInit()
        return
    end
    self._token = result.token
    local enemyFormation = clone(result.battle.formation)
    enemyFormation.filter = ""

    -- 给布阵传递怪兽数据
    self._guildMapModel:setEnemyTeamData(result.battle.teams)
    -- 给布阵传递英雄数据
    self._guildMapModel:setEnemyHeroData(result.battle.hero)

    local formationModel = self._modelMgr:getModel("FormationModel")

    self._enemyInfo = BattleUtils.jsonData2lua_battleData(result.battle)
    self._formationView = true
    self._viewMgr:showView("formation.NewFormationView", {
        formationType = formationModel.kFormationTypeGuild, 
        enemyFormationData = {[formationModel.kFormationTypeGuild] = enemyFormation},
        callback = function(leftData)
            self._formationView = false
            if self.getPvpRes == nil then 
                ViewManager:getInstance():popView()
                ViewManager:getInstance():showTip(lang("GUILD_MAP_RESULT_CODE_TIP_3023"))
                return
            end
            self._serverMgr:sendMsg("FormationServer", "getSelfBattleInfo", {fid = 9}, true, {}, function(_result) 
                self._playerInfo = BattleUtils.jsonData2lua_battleData(_result["atk"])
                -- dump(self._playerInfo, "a", 10)
                -- dump(self._enemyInfo, "a", 10)
                if self.getPvpRes == nil then 
                    ViewManager:getInstance():popView()
                    ViewManager:getInstance():showTip(lang("GUILD_MAP_RESULT_CODE_TIP_3023"))
                    return
                end
                self:getPvpRes()
            end)        
        end,
        closeCallback = function()
            self._formationView = false
            if self._callback ~= nil then
                self._callback(nil)
            end
            self:close(true)            
        end
    })

end
 


function GuildMapCommonBattle:pveBefore()
    self._battleWin = 0
    self._battleResult = nil
    self._serverMgr:sendMsg("GuildMapServer", "pveBefore", {tagPoint = self._targetId, type = self._eleTypeName, serverInfoEx = BattleUtils.getBeforeSIE()}, true, {}, function (result)
        print("GuildMapCommonBattle:pveBefore=========================")
        if result["code"] == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_PVE_NOT_EXIST then
            self._callback(result)
            self:close()
            return
        end
        return self:pveBeforeFinish(result)
    end)
end

function GuildMapCommonBattle:pveBeforeFinish(result)
    -- dump(result)
    if result == nil or result.token == nil then 
        return
    end
    self._token = result.token

    local formationModel = self._modelMgr:getModel("FormationModel")
    local GuildMapUtils = require "game.view.guild.map.GuildMapUtils"
    local enemyInfo 
    -- local enemyFormation
    local enemyFormationData 
    if self._mapInfomation ~= nil then
        enemyInfo  = GuildMapUtils:initBattleData(self._mapInfomation)

         -- 给布阵传递怪兽数据
        self._guildMapModel:setEnemyTeamData(enemyInfo.team)
        -- 给布阵传递英雄数据
        self._guildMapModel:setEnemyHeroData(enemyInfo.hero)

        if self._mapInfomation.formation.hero ~= nil and enemyInfo.hero ~= nil then
            self._mapInfomation.formation.hero.score = enemyInfo.hero.score
        end
        self._mapInfomation.formation.score = enemyInfo.score

        -- enemyFormation = self._mapInfomation.formation
        enemyFormationData = {[formationModel.kFormationTypeGuild] = self._mapInfomation.formation}

    end
    local function callBattle(inLeftData)
        -- 我方联盟探索buffer, 服务器传回的数据自带buff

        GuildConst.IS_ENTER_BATTLE = true
        self._viewMgr:popView()
        if self._pveBattleFunction == nil then 
            self._pveBattleFunction = BattleUtils.enterBattleView_GuildPVE
        end
        print("inLeftData==================================")
        dump(inLeftData, "test", 10)
        if self._isBossBattle then 
            self._pveBattleFunction(self._bossLvl, --等级
                                    self._bossHp > 100, --是否秒人， 耐力>100为true
            inLeftData,
            function (info, callback)
                if info.isSurrender then 
                    callback(nil)
                    return
                end
                if self.pveAfter == nil then return end
                self:pveAfter(info, callback)
            end,
            function (info)
                print("退出战斗")

                if self._callback ~= nil and self._battleResult ~= nil then 
                    self._battleResult.win = self._battleWin
                    self._callback(self._battleResult)
                end
                if self.close == nil then return end
                -- 退出战斗
                self:close(true)
            end)
        else 
            BattleUtils.enterBattleView_GuildPVE(inLeftData, enemyInfo, 
            function (info, callback)
                if info.isSurrender then 
                    callback(nil)
                    return
                end
                if self.pveAfter == nil then return end
                self:pveAfter(info, callback)
            end,
            function (info)
                print("退出战斗")

                if self._callback ~= nil and self._battleResult ~= nil then 
                    self._battleResult.win = self._battleWin
                    self._callback(self._battleResult)
                end
                if self.close == nil then return end
                -- 退出战斗 
                self:close(true)
            end)
        end
    end

    self._formationView = true
    self._viewMgr:showView("formation.NewFormationView", {
        formationType = formationModel.kFormationTypeGuild,
        enemyFormationData = enemyFormationData,
        callback = function(inLeftData)
            if self._serverMgr == nil then return end
            self._formationView = false
            self._serverMgr:sendMsg("FormationServer", "getSelfBattleInfo", {fid = 9}, true, {}, function(_result) 
                callBattle(BattleUtils.jsonData2lua_battleData(_result["atk"]))
            end)
        end,
        closeCallback = function()
            self._formationView = false
            if self.parentView ~= nil then
                self.parentView:setMaskLayerOpacity(0)
            end
            
            if self._callback ~= nil then
                self._callback(nil)
            end
            if self.close == nil then return end
            self:setVisible(false)
            self:close(false)
        end
        }
    )

end


-- function GuildMapCommonBattle:pveAfter()
--     self._serverMgr:sendMsg("GuildMapServer", "pveAfter", {tagPoint = self._targetId, type = self._eleTypeName}, true, {}, function (result)
--         return self:pveAfterFinish(result)
--     end)
-- end

function GuildMapCommonBattle:pveAfter(data, inCallBack)
    if data.win then
        self._battleWin = 1
    end
    
    local allyDead = {}
    local enemyDead = {}
    if not data.isSurrender then
        for k,v in pairs(data.dieList[1]) do
            table.insert(allyDead, k)
        end
        for k,v in pairs(data.dieList[2]) do
            table.insert(enemyDead, k)
        end
    end

    if #enemyDead == 0 then 
        enemyDead = nil
    end
    if #allyDead == 0 then 
        allyDead = nil
    end
        
    local mySelfHp = math.ceil(data.hp[1] / data.hp[2] * 100)
    local enemyHp = math.ceil(data.hp[3] / data.hp[4] * 100)

    local param = {tagPoint = self._targetId, type = self._eleTypeName, token = self._token, 
    args = json.encode({win= self._battleWin, skillList = data.skillList, 
        serverInfoEx = data.serverInfoEx,
        time = data.time, uhp = mySelfHp, mhp = enemyHp, allyDead=allyDead, enemyDead=enemyDead})}
    self._serverMgr:sendMsg("GuildMapServer", "pveAfter", param, true, {}, function(result)
        if result == nil then 
            return 
        end
        if result["extract"] then
            dump(result["extract"]["hp"], "a", 10)
        end
        local mapList = self._guildMapModel:getData().mapList

        local afterEnemyMapHurt = 0
        local afterMyselfMapHurt = 0
        if self._battleWin == 1 then
            afterMyselfMapHurt = self._modelMgr:getModel("UserModel"):getData().roleGuild.mapHurt
        else
            afterMyselfMapHurt = 0
        end
        if (mapList[self._targetId] == nil and mapList[self._targetId][self._eleTypeName] == nil) or 
            (mapList[self._targetId] ~= nil and mapList[self._targetId][self._eleTypeName] == nil) then 
            afterEnemyMapHurt = 0
        else
            afterEnemyMapHurt = mapList[self._targetId][self._eleTypeName].npcHp
        end        
        result.mapHurt = {self._myselfMapHurt, afterMyselfMapHurt, self._enemyMapHurt, afterEnemyMapHurt}


        self._battleResult = result
        -- 像战斗层传送数据
        if inCallBack ~= nil then
            inCallBack(result)
        end
    end)
end


function GuildMapCommonBattle:closeInit()
    self:setVisible(false)
    self._viewMgr:lock(-1)
    ScheduleMgr:delayCall(0, self, function ()
        self._viewMgr:unlock()
        if self._closePopCallback ~= nil then 
            self._closePopCallback(self.parentView)
        end
        if self.close ~= nil then
            self:close(true)
        end
    end)
end


function GuildMapCommonBattle:onDestroy1()
end

return GuildMapCommonBattle 
