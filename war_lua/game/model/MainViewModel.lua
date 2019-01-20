--[[
    Filename:    mainViewModel.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-10-20 10:58:46
    Description: File description
--]]

local MainViewModel = class("MainViewModel", BaseModel)

function MainViewModel:ctor()
    MainViewModel.super.ctor(self)
    self._data = {}
    self._data["data1"] = {}
    self._data["notice"] = {}
    self._data["bubble"] = {}
    self._data["world_bubble"] = {}
    self._data["teshu_bubble"] = {}
    -- self._data["fristcard"] = false
    
    -- self._noticeMap = {}
    ---[[ 刷新主界面左下角 systemOn
    self:registerTimer(12, 0, 0, function ()
        self:updateMainViewAction()
    end)
    self:registerTimer(20, 0, 0, function ()
        self:updateMainViewAction()
    end)
    self:registerTimer(19, 55, 0, function ()
        self:updateMainViewAction()
    end)

    -- ]]
    self:registerTimer(5, 0, 5, function ()
        self:updateMainViewAction()
        self:clearLeijiGadget()
    end)
    self._cityBattleModel = self._modelMgr:getModel("CityBattleModel")
    self._spellBooksModel = self._modelMgr:getModel("SpellBooksModel")
    self._userModel = self._modelMgr:getModel("UserModel")

    self._acModel = self._modelMgr:getModel("ActivityModel")
end

function MainViewModel:setData(data)
    self._data["data"] = data
    
    self:reflashData()
end

function MainViewModel:getData()
    return self._data["data"]
end

function MainViewModel:setNotice(viewname,notice)
    self._data["notice"][viewname] = notice
    self:reflashData()
end

function MainViewModel:getNoticeMap( )
    return self._data["notice"]
end 

function MainViewModel:clearNotice( )
    self._data["notice"] = nil
end

function MainViewModel:setActionOpen()
    self._data["actionOpen"] = true
    self:reflashData()
end

function MainViewModel:getActionOpen()
    return self._data["actionOpen"]
end 

function MainViewModel:clearActionOpen()
    self._data["actionOpen"] = false
end 

function MainViewModel:setQipao()
    self._data["qipao"] = true
end

function MainViewModel:getQipao()
    return self._data["qipao"]
end 

-- function MainViewModel:setFristCard(fristcard)
--     local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl
--     if userlvl < 9 then
--         self._data["fristcard"] = false
--     else
--         self._data["fristcard"] = true
--     end
--     if fristcard then
--         self._data["fristcard"] = true
--     end
    
-- end

-- function MainViewModel:getFristCard()
--     return self._data["fristcard"]
-- end 

-- 根据时间开启气泡标记
function MainViewModel:getActionTimeOpen()
    return self._data["aTimeOpen"] or false
end 

function MainViewModel:setActionTimeOpen(flag)
    self._data["aTimeOpen"] = flag
end

function MainViewModel:clearQipao()
    self._data["qipao"] = false
end 

function MainViewModel:reflashMainView()
    self:reflashData()
end

-- 主线任务
function MainViewModel:checkTipsQipao1()
    local taskModel = self._modelMgr:getModel("TaskModel")
    return taskModel:hasTaskCanGetByType(1)
end

-- 月卡
function MainViewModel:checkTipsQipao2()
    local vipModel = self._modelMgr:getModel("VipModel")
    return vipModel:isMonthCardBought()
end

-- 布阵
function MainViewModel:checkTipsQipao3()
    return not self._modelMgr:getModel("FormationModel"):isCommonFormationTeamFull()
end

-- 副本
function MainViewModel:checkTipsQipao4()
    return true
end

-- 免费抽卡
function MainViewModel:checkTipsQipao5()
    return self._modelMgr:getModel("TeamModel"):isCardFree()
end

-- 半价
function MainViewModel:checkTipsQipao6()
    return self._modelMgr:getModel("TeamModel"):isCardHalf()
end

-- boss战
function MainViewModel:checkTipsQipao7()
    local bossModel = self._modelMgr:getModel("BossModel")
    return bossModel:haveBossCount()
end

-- 图鉴
function MainViewModel:checkTipsQipao8()
    local pokedexModel = self._modelMgr:getModel("PokedexModel")
    return pokedexModel:getPokedexFangzhi()
end 

-- 远征
function MainViewModel:checkTipsQipao9()
    local crusadeModel = self._modelMgr:getModel("CrusadeModel")
    return crusadeModel:getCrusadeQipaoOpen()
end

-- 首抽
function MainViewModel:checkTipsQipao10()
    return self._modelMgr:getModel("TeamModel"):isFirstCardHalf()
end

-- 竞技场、积分联赛次数
function MainViewModel:checkTipsQipao12()
    print("竞技场、积分联赛次数")
    return ( self._modelMgr:getModel("ArenaModel"):haveChanllengeNum() and not self._modelMgr:getModel("ArenaModel"):inChanllengeCD() )
          or self._modelMgr:getModel("LeagueModel"):haveChallengeNum()
end

-- 积分联赛奖励
function MainViewModel:checkTipsQipao13()
    print(" 积分联赛奖励",self._modelMgr:getModel("LeagueModel"):haveAward() or self._modelMgr:getModel("LeagueModel"):timeAwardFull(),
        self._modelMgr:getModel("LeagueModel"):haveAward() , self._modelMgr:getModel("LeagueModel"):timeAwardFull())

    return self._modelMgr:getModel("LeagueModel"):haveAward() or self._modelMgr:getModel("LeagueModel"):timeAwardFull()
end

-- pve奖励
function MainViewModel:checkTipsQipao14()
    print(" pve奖励")
    return self._modelMgr:getModel("BossModel"):getHasReward()
end

-- 学院
function MainViewModel:checkTipsQipao15()
    return self._modelMgr:getModel("TalentModel"):checkTalentPopTip()
end

--法术祈愿
function MainViewModel:checkTipsQipao33()
   return self._spellBooksModel:checkSkillCardRed()
end

--法术书柜
function MainViewModel:checkTipsQipao34()
   return self._modelMgr:getModel("SkillTalentModel"):checkRed()
end

-- 航海任务
function MainViewModel:checkTipsQipao16()
    return self._modelMgr:getModel("MFModel"):isMFTip() --  false 
end


-- 训练所
function MainViewModel:checkTipsQipao17()
    return self._modelMgr:getModel("TrainingModel"):isJuniorPass() 
end

-- 云中城
function MainViewModel:checkTipsQipao18()
    return self._modelMgr:getModel("CloudCityModel"):isHaveTimes()
end

-- 兵团技巧
function MainViewModel:checkTipsQipao19()
    return self._modelMgr:getModel("TeamModel"):isTeamBoostTip()
end

-- 射箭箭矢可领取
function MainViewModel:checkTipsQipao20()
    return self._modelMgr:getModel("ArrowModel"):checkBubble()
end

function MainViewModel:checkTipsQipao21()
    return self._modelMgr:getModel("IntanceEliteModel"):checkSectionStarState()
end

--联盟新功能气泡
function MainViewModel:checkTipsQipao22()
   local flag = self._modelMgr:getModel("GuildModel"):checkNewGuildFunction()
    return flag
end

--联盟地图加个主界面气泡的判断
function MainViewModel:checkTipsQipao23()
    return self._modelMgr:getModel("GuildMapModel"):checkGuildMapRedpoint()
end

--GVG 战报红点
function MainViewModel:checkTipsQipao26()
    return self._cityBattleModel:checkReprotRedData()
end

--GVG 奖励红点
function MainViewModel:checkTipsQipao29()
    return self._cityBattleModel:checkRewardRedData() or self._cityBattleModel:checkNewGvg()
end

--GVG 副本界面 奖励红点
function MainViewModel:checkTipsQipao30()
    return self._cityBattleModel:checkRewardRedData()
end

--宝物抽卡免费气泡
function MainViewModel:checkTipsQipao31()
    local freenNum = self._modelMgr:getModel("PlayerTodayModel"):getData().day12 or 0
    local haveFree = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.BaoWuChouKa) or 0
    return haveFree > 0 and freenNum < haveFree
end
--元素位面有挑战次数气泡
function MainViewModel:checkTipsQipao32()
    return self._modelMgr:getModel("ElementModel"):isHaveTimes()
end

--GVG zhandou 阶段
function MainViewModel:checkTipsQipao27()
    if not self._cityBattleModel:checkIsGvgOpen() then
        return 
    end
    print("MainViewModel:checkTipsQipao27==========================")
    local state, weekday, timeType = self._cityBattleModel:getState()
    if state == 1 and (timeType == "s3" or timeType == "s5") then return true end
    return false
end

--GVG 准备阶段
function MainViewModel:checkTipsQipao28()
    -- if not self._cityBattleModel:checkIsGvgOpen() then
    --     return 
    -- end
    -- print("MainViewModel:checkTipsQipao28==========================")
    -- local state, weekday, timeType = self._cityBattleModel:getState()
    -- if state == 0 and timeType == "s1" then return true end
    -- return false
    return self._cityBattleModel:checkNewGvgReady()
end

--联盟地图加个钻石气泡的判断
function MainViewModel:checkTipsQipao24()
    if GameStatic.appleExamine == true then
        return false
    end
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local guildModel = self._modelMgr:getModel("GuildModel")
    local roleGuild = userData.roleGuild
    if not roleGuild then
        guildModel:setGemQipao(false)
        return false
    end
    local bindGuildGroup = roleGuild.bindGuildGroup
    if bindGuildGroup and bindGuildGroup == 1 then
        --领取过钻石
        guildModel:setGemQipao(false)
        return false
    end

    
    local bindGroup = guildModel:getAllianceDetail().bindGroup
    if bindGroup == nil then 
        bindGroup = {}
    end
    local status = 0
    if bindGroup.hadBind == nil or bindGroup.hadBind == "" or tonumber(bindGroup.hadBind) == 0 then 
        status = 1 --未绑定
    end
    if status == 1 and roleGuild.pos ~= 1 then --普通成员提醒状态，不显示气泡
        guildModel:setGemQipao(false)
        return false
    end
    guildModel:setGemQipao(true)
    return true
end

--联盟地图加个主界面气泡的判断
function MainViewModel:checkTipsQipao25()
    return self._modelMgr:getModel("GodWarModel"):getGodwarMainTip()
end

-- 战争器械有可装备的配件
function MainViewModel:checkTipsQipao36()
    local siegeModel = self._modelMgr:getModel("SiegeModel")
    --没有开启功能之前不显示气泡
    local lvl = self._userModel:getData().lvl
    local needLevel = tab:SystemOpen("Weapon")[1]
    if lvl < needLevel then
        return false
    end

    local isRed1 = self._modelMgr:getModel("WeaponsModel"):checkMainViewTips()
    local isRed2 = self._modelMgr:getModel("ParagonModel"):checkWarReadinessRedPoint()
    return isRed1 or isRed1
end

--机械制造气泡
function MainViewModel:checkTipsQipao37()
    local lvl = self._userModel:getData().lvl
    local needLevel = tab:SystemOpen("Weapon")[1]
    if lvl < needLevel then
        return false
    end

    local cCostData = tab:Setting("DRAW_SW_COST4").value[1]
    local CostType = cCostData[1]
    local CostCount = cCostData[3]

    local have = self._userModel:getData()[CostType] or 0
    if have >= CostCount then
        return true
    end
end

-- 攻城战攻打次数不为0
function MainViewModel:checkTipsQipao39()
    return self._modelMgr:getModel("SiegeModel"):canBattle()
end

-- 攻城战日常攻打次数不为0
function MainViewModel:checkTipsQipao40()
    return self._modelMgr:getModel("DailySiegeModel"):canBattle()
end

-- 攻城战有宝箱可领取
function MainViewModel:checkTipsQipao41()
    return self._modelMgr:getModel("SiegeModel"):checkAllStageAward()
end

-- 跨服竞技场是否有气泡
function MainViewModel:checkTipsQipao42()
    return self._modelMgr:getModel("CrossModel"):getCrossMainState() == 2
end

-- 跨服竞技场主界面提示结算
function MainViewModel:checkTipsQipao43()
    return self._modelMgr:getModel("CrossModel"):getMainViewTip()
end

-- 法术天赋气泡
function MainViewModel:checkTipsQipao45()
    return self._modelMgr:getModel("SkillTalentModel"):checkRed()
end

-- 开启战争器械气泡
function MainViewModel:checkTipsQipao38()
    return self._modelMgr:getModel("WeaponsModel"):openWeapon()
end

-- 无尽炼狱气泡
function MainViewModel:checkTipsQipao44(  )
    if self._modelMgr:getModel("PurgatoryModel"):isShowQiPao() then
        return true
    else
        return self._modelMgr:getModel("PurgatoryModel"):isHaveRedPrompt()
    end
end

-- 法术祈愿热点橙色法术
function MainViewModel:checkTipsQipao52(  )
    return self._modelMgr:getModel("SpellBooksModel"):getHotSpotFlag()
end

-- 荣耀竞技场免费次数
function MainViewModel:checkTipsQipao53(  )
    return self._modelMgr:getModel("GloryArenaModel"):bIsCanAttack()
end

-- 免费阵营抽卡
function MainViewModel:checkTipsQipao55( )
    return self._modelMgr:getModel("RaceDrawModel"):haveFreeTips()
end

-- 半价阵营抽卡
function MainViewModel:checkTipsQipao54( )
    return self._modelMgr:getModel("RaceDrawModel"):haveHalfTips()
end

-- 军团试炼当日气泡
function MainViewModel:checkTipsQipao56( )
	return self._modelMgr:getModel("BossModel"):isNeedLegionTimesTip()
end

function MainViewModel:checkTipsQipao()
    local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl
    if userlvl < 9 then
        self._canDoFirstCardHalftip = false 
    else
        self._canDoFirstCardHalftip = true
    end
    self._data["teshu_bubble"] = {}
    self._data["world_bubble"] = {}
    self._data["bubble"] = {}
    self._data["common_bubble"] = {}

    local tempBubble, callback, qipao
    -- dump(tab.qipao)
    for i, tip in pairs(tab.qipao) do
        tempBubble = {}
        tempBubble.qipao = tip.btn 
        tempBubble.pos = i 
        local condition = tip.condition or 1
        local levelLimit = tip.level
        if self["checkTipsQipao" .. condition] ~= nil then 
            tempBubble.callback = function()
                if levelLimit and #levelLimit > 1 then
                    if userlvl >= levelLimit[1] and userlvl <= levelLimit[2] then
                        return self["checkTipsQipao" .. condition](self)
                    else
                        return false
                    end
                else
                    return self["checkTipsQipao" .. condition](self)
                end
            end
        else
            tempBubble.callback = function()
                return false
            end
        end
        if tip.rank == nil then
            self._viewMgr:showTip("Qipao表配错")
            return
        end
        tempBubble.id = tip.id
        tempBubble.rotationY = tip.rotationY
        tempBubble.rank = tip.rank
        tempBubble.sign = tip.sign
        if condition == 36 then
            dump(tempBubble,"666hahaha")
        end
        -- print("tip.id==========================", tip.id, tip.condition)
        local sign = tip.sign
        if sign and sign == 1 then --无数量要求的普通气泡 add lishunan
            table.insert(self._data["bubble"],tempBubble)
        elseif tip.id > 100 and tip.id <= 200 then 
            table.insert(self._data["world_bubble"],tempBubble)
        elseif tip.id == 1004 then
            table.insert(self._data["teshu_bubble"],tempBubble)
        else
            table.insert(self._data["bubble"],tempBubble)
        end
    end

    local function sortFun(data1,data2)
        if data1.rank ~= data2.rank then
            return data1.rank < data2.rank
        end
    end
    -- table.sort(self._data["common_bubble"],sortFun)
    table.sort(self._data["bubble"],sortFun)
    table.sort(self._data["world_bubble"],sortFun)
end

function MainViewModel:getTipsQipao()
    return self._data["bubble"]
end

-- function MainViewModel:getCommonQipao()
--     return self._data["common_bubble"] or {}
-- end

function MainViewModel:getWorldTipsQipao()
    return self._data["world_bubble"]
end

function MainViewModel:getTeshuTipsQipao()
    return self._data["teshu_bubble"]
end

function MainViewModel:releaseFirstCardHalfTip()
    self._canDoFirstCardHalftip = true
end

function MainViewModel:isShowNotice()
    local userModel = self._modelMgr:getModel("UserModel")
    local userData = userModel:getData()

    local userData = userModel:getData()
    local sysOpenTime = userData.sec_open_time or 0  -- 开服时间
    local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(sysOpenTime,"%Y-%m-%d 05:00:00"))
    if sysOpenTime < tempTime then
        sysOpenTime = sysOpenTime - 86400
    end
    local curServerTime = userModel:getCurServerTime()
    local openNoticeId
    -- local flag = false
    for i=1,table.nums(tab.sTimeOpen) do
        local indexId = 100+i 
        local flag = true
        if indexId == 104 then -- 英雄交锋
            flag = self._modelMgr:getModel("HeroDuelModel"):getHDuelIsOpen()
        end
        local sTimeTab = tab:STimeOpen(indexId)
        print("+----------===",sysOpenTime, userData.lvl , sTimeTab["noticelv"] , sTimeTab["level"])
        -- if notice.prevelege == 0 then
            
        --     local userData = self._modelMgr:getModel("UserModel"):getData()
        --     local sysOpenTime = userData.sec_open_time 
        --     local openTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(sysOpenTime + notice["opentime"]*86400,"%Y-%m-%d 05:00:00"))
        --     local tempTime = openTime - userModel:getCurServerTime() - 86400
        --     if tempTime > 0 then
        --         openNoticeId = indexId
        --         break
        --     end
        -- end
        if userData.lvl >= sTimeTab["noticelv"] and flag then
        -- if userData.lvl >= sTimeTab["noticelv"] and userData.lvl <= sTimeTab["level"] then
            local tishiTime = sysOpenTime + sTimeTab.notice*86400 - 86400 -- 提示时间
            local showDay = sTimeTab["opentime"] - sTimeTab["notice"]
            local minCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(tishiTime,"%Y-%m-%d 05:00:00"))
            local maxCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(tishiTime+86400*showDay,"%Y-%m-%d 00:00:00")) + (sTimeTab["openhour"])*3600
            print("sTimeTab.notice", sTimeTab.notice, showDay)
            print(curServerTime,maxCurDayTime,minCurDayTime )
            if curServerTime <= maxCurDayTime and curServerTime >= minCurDayTime then
                openNoticeId = indexId
                break
            elseif curServerTime >= minCurDayTime then
                if userData.lvl < sTimeTab["level"] then
                    openNoticeId = indexId
                    break
                end
            end
        end
    end
    -- if openNoticeId then
    --     flag = true
    -- end
    return openNoticeId
end

function MainViewModel:isOpenShowNotice(flag)
    local userModel = self._modelMgr:getModel("UserModel")
    local userData = userModel:getData()

    local userData = userModel:getData()
    local sysOpenTime = userData.sec_open_time or 0  -- 开服时间
    local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(sysOpenTime,"%Y-%m-%d 05:00:00"))
    if sysOpenTime < tempTime then
        sysOpenTime = sysOpenTime - 86400
    end
    local curServerTime = userModel:getCurServerTime()
    local openNoticeId
    -- local flag = false

    local openNoticeLevel = SystemUtils.loadAccountLocalData("OPENLEVEL_Notice")
    local bubbleId = self._modelMgr:getModel("PlayerTodayModel"):getBubble()["b2"]
    -- if tempdate ~= timeDate then
    -- print("OPENLEVEL_Notice===", bubbleId)
        
    --     return true
    -- end
    -- SystemUtils.saveAccountLocalData("OPENLEVEL_Notice", 12)
    

    for i=1,table.nums(tab.sTimeOpen) do
        local indexId = 100+i 
        -- print("++++++++++++++++++++++++++++", indexId)
        local sTimeTab = tab:STimeOpen(indexId)
        -- print("+userData+++++", userData.lvl, sTimeTab["level"])
        local flag = true
        if indexId == 104 then -- 英雄交锋
            flag = self._modelMgr:getModel("HeroDuelModel"):getHDuelIsOpen()
        end
        if userData.lvl >= sTimeTab["level"] and flag == true then
            local openTime = sysOpenTime + (sTimeTab["opentime"]-1)*86400 -- 提示时间
            local curDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(openTime,"%Y-%m-%d 00:00:00"))+(sTimeTab["openhour"])*3600
            if curServerTime >= curDayTime then
                -- if (not openNotice) or (openNotice and openNotice < sTimeTab["level"]) then
                -- print("bubbleId ===", bubbleId,"type =", type(bubbleId),"indexId", indexId, "===", type(indexId))
                if (not bubbleId) or (bubbleId and bubbleId < indexId) then
                    local openAnimStr = sTimeTab["opentime"]..sTimeTab["level"]
                    openNoticeId = indexId
                    if (not openNoticeLevel) or (openNoticeLevel and openNoticeLevel ~= openAnimStr) then
                        print("1==========")
                        if userData.lvl == 34 or userData.lvl == 37 or userData.lvl == 39 or userData.lvl == 41 or userData.lvl == 44 then
                            if userData.exp > 130 then
                                SystemUtils.saveAccountLocalData("OPENLEVEL_Notice", openAnimStr)
                                self:setActionTimeOpen(true)
                                self:setActionOpen()
                            end
                        else
                            SystemUtils.saveAccountLocalData("OPENLEVEL_Notice", openAnimStr)
                            self:setActionTimeOpen(true)
                            self:setActionOpen()
                        end
                    else
                        print("2==========")
                        openNoticeId = indexId 
                    end
                    break
                end
            end
        end
    end

    print("openNoticeId===", openNoticeId)
    return openNoticeId
end

-- 功能开启是否播放
function MainViewModel:isOpenNotice(systemopen)
    local flag = false
    -- local openNoticeLevel = SystemUtils.loadAccountLocalData("OPENLEVEL_Notice")
    local bubbleId = self._modelMgr:getModel("PlayerTodayModel"):getBubble()["b2"]
    if bubbleId ~= systemopen then
        flag = true
    end
    return flag
end

-- 按照时间段展示功能提示
function MainViewModel:getTimeShowOpen()
    local userModel = self._modelMgr:getModel("UserModel")
    local userData = userModel:getData()
    local curServerTime = userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    if weekday == 0 then
        weekday = 7
    end
    -- local systemOnTab = tab:SystemOn(101)
    local sonTab = {
        [1] = 106,
        [2] = 102,
        [3] = 103,
        [4] = 104,
        [5] = 101,
        [6] = 105,
        [7] = 108,
        [8] = 109,
        [9] = 110,
        [10] = 111,
    }

    local hourOpenTab = {}
    local hourEndTab = {}
    local openId = 0
    local openIdList = {}

    local userData = userModel:getData()
    local sysOpenTime = userData.sec_open_time or 0  -- 开服时间
    local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(sysOpenTime,"%Y-%m-%d 05:00:00"))
    if sysOpenTime < tempTime then
        sysOpenTime = sysOpenTime - 86400
    end

    local tabSystemOn = tab.systemOn
    for indexId=1,table.nums(sonTab) do
        local i = sonTab[indexId]
        local v = tabSystemOn[i]
        if v then
            local openTime = v.openhour[1] .. ":" .. v.openminut[1]
            local endTime = v.openhour[2] .. ":" .. v.openminut[2]
            local weeklyTab = v.weekly
            local curOpenTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d " .. openTime .. ":00"))
            local curEndTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d " .. endTime .. ":00"))
            if curServerTime > curOpenTime and curServerTime < curEndTime then
                local opensysTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(sysOpenTime + (v["notice"]-1)*86400,"%Y-%m-%d 00:00:00"))
                local tempTime = curServerTime - opensysTime
                if (userData.lvl >= v.noticelv) and (tempTime > 0) then
                    if table.indexof(weeklyTab, weekday) ~= false then 
                        if v.id == 102 or v.id == 103 or v.id == 104 then
                            local godWarModel = self._modelMgr:getModel("GodWarModel")
                            local flag = godWarModel:getTimeSystemOn()
                            if flag == true then
                                -- openId = v.id
                                table.insert(openIdList, v.id)
                                -- break
                            end
                        elseif v.id == 106 then
                            if SystemUtils:enableCityBattle() then
                                -- openId = v.id
                                table.insert(openIdList, v.id)
                                -- break
                            end
                        elseif v.id == 108 then
                            local flag = self._modelMgr:getModel("PurgatoryModel"):isOpenPurgatory()
                            if flag then
                                -- openId = v.id
                                table.insert(openIdList, v.id)
                                -- break
                            end
                        elseif v.id == 109 or v.id == 110 or v.id == 111 then
                            local cGodWarModel = self._modelMgr:getModel("CrossGodWarModel")
                            local flag = cGodWarModel:getTimeSystemOn()
                            if flag == true then
                                table.insert(openIdList, v.id)
                            end
                        else
                            local flag = self._modelMgr:getModel("HeroDuelModel"):getHDuelIsOpen()
                            if flag ~= false then
                                -- openId = v.id
                                table.insert(openIdList, v.id)
                                -- break
                            end
                        end
                    end 
                end
            end
        end
    end

    if #openIdList > 0 then
        openId = openIdList[1]
        for k, v in pairs(openIdList) do
            local oldData = tabSystemOn[openId]
            local newData = tabSystemOn[v]
            if newData.priv and oldData.priv and newData.priv < oldData.priv then
                openId = v
            end
        end
    end

    return openId
end

function MainViewModel:updateMainViewAction()
    self:reflashMainView()
end

-- 如果进入过对应的功能应返回false
function MainViewModel:getTimeActionOpen(indexId)
    local flag = true
    if indexId == 104 then -- 英雄交锋
        flag = self._modelMgr:getModel("HeroDuelModel"):getHDuelIsOpen()
    elseif indexId == 101 then
        flag = self._modelMgr:getModel("LeagueModel"):isCurBatchFirstIn()
    end
    return flag
end

function MainViewModel:initActivity()
    self._activityCallback = {}
    local elementModel = self._modelMgr:getModel("ElementModel")
    self._activityCallback[301] = function()
        return self._modelMgr:getModel("BossModel"):haveBossCount(1)
    end
    self._activityCallback[302] = function()
        return self._modelMgr:getModel("BossModel"):haveBossCount(2)
    end
    self._activityCallback[303] = function()
        return self._modelMgr:getModel("BossModel"):haveBossCount(3)
    end
    self._activityCallback[401] = function()
        return self._modelMgr:getModel("CrusadeModel"):getCrusadeQipaoOpen()
    end
    self._activityCallback[304] = function()
        return self._modelMgr:getModel("CloudCityModel"):isShowQipao()
    end
    self._activityCallback[305] = function()
        return elementModel:checkIsOpenElement(1)
    end
    self._activityCallback[306] = function()
        return elementModel:checkIsOpenElement(2)
    end
    self._activityCallback[307] = function()
        return elementModel:checkIsOpenElement(3)
    end
    self._activityCallback[308] = function()
        return elementModel:checkIsOpenElement(5)
    end
    self._activityCallback[309] = function()
        return elementModel:checkIsOpenElement(4)
    end
    self._activityCallback[601] = function()
        return self._modelMgr:getModel("MFModel"):acMFTip()
    end
end

function MainViewModel:getHuodongQipao(_type)
    if not self._activityCallback then
        self:initActivity()
    end
    local flag = self._activityCallback[_type] and self._activityCallback[_type]() or false
    return flag or false
end

-- function MainViewModel:getHuodongQipao(_type)
--     local flag = false
--     if _type == 301 then
--         flag = self._modelMgr:getModel("BossModel"):haveBossCount(1)
--     elseif _type == 302 then
--         flag = self._modelMgr:getModel("BossModel"):haveBossCount(2)
--     elseif _type == 303 then
--         flag = self._modelMgr:getModel("BossModel"):haveBossCount(3)
--     elseif _type == 401 then
--         flag = self._modelMgr:getModel("CrusadeModel"):getCrusadeQipaoOpen()
--     end
--     return flag or false
-- end

--检测是否满足开启周签活动
function MainViewModel:checkOpenWeekSign()
    local constCondition = tab:Setting("G_WEEKLYSIGN_LIMIT")
    local needDay,needLv = 10,6
    if constCondition then
        needDay = tonumber(constCondition.value[1])
        needLv  = tonumber(constCondition.value[2])
    end
    --开服时间
    local openDay = math.floor(self._modelMgr:getModel("UserModel"):getOpenServerTime()/86400)
    if openDay < 10 then
        print("MainViewModel:checkOpenWeekSign openDay less")
        return
    end

    --等级
    local lv = self._modelMgr:getModel("UserModel"):getData().lvl
    if lv < 6 then
        return 
    end

    --今天是否周签
    local isWeekSign = self._modelMgr:getModel("PlayerTodayModel"):getData().day58

    print("isWeekSign == %d",isWeekSign)
    if isWeekSign and isWeekSign >= 1 then
        return
    end

    --今天的周签是否配置
    local serverTime = self._modelMgr:getModel("UserModel"):getCurServerTime() - 18000
    local id = tonumber(TimeUtils.formatTime_1(serverTime))
    if id and tab:WeeklySign(id) then
        return true
    end
end

function MainViewModel:updateRedDotsData(data)
    local userModel = self._modelMgr:getModel("UserModel")
    userModel:setRedDotsData(data)

    self:reflashData("updateRedDots")
end

-- 主界面 心悦特权红点
function MainViewModel:isRedNoticedByKey(key)
    -- print("========心悦特权红点=========key===,",key)
    if not key then return false end
    local redData  = self._modelMgr:getModel("UserModel"):getRedDotsData() or {}
    -- dump(redData,"redData",5)
    local isRed = false
    --  1:显示红点  0:不显示
    if redData and redData[tostring(key)] == 1 then
        isRed = true
    end

    return isRed
end

-- 保存主城小物件数据
function MainViewModel:setGadgetData(data)
    if self._gadgetData == nil then
        self._gadgetData = {}
    end
    if data then
        self._gadgetData.rNum = data.rNum or 0
        self._gadgetData.nNum = data.nNum or 0
        self._gadgetData.list = data.list
    end
end

function MainViewModel:getGadgetData()
    if self._gadgetData == nil then
        self._gadgetData = {}
        self._gadgetData.rNum = 0 -- 累积小物件已领取个数
        self._gadgetData.nNum = 0 -- 累积小物件未领取个数
    end
    if self._gadgetData.list == nil then -- 时间段小物件已领取个数
        self._gadgetData.list = {}
    end
    return self._gadgetData
end

-- 获取小物件数量
function MainViewModel:getGadgetNum()
    local data = self:getGadgetData()
    local num = data.nNum
    local addList = data.list
    local timeSpan = self:getTimeSpan()
    for i = 1, #timeSpan do
        if addList[tostring(timeSpan[i].id)] ~= nil then
            num = num + timeSpan[i].num - addList[tostring(timeSpan[i].id)]
        else
            num = num + timeSpan[i].num
        end
    end
    return num
end

-- 领取小物件
-- @param tp 小物件类型 1:累积小物件 2:时间段小物件
-- @param tp 小物件相关数据
function MainViewModel:minusGadgetNum(tp, data)
    local gadgetData = self:getGadgetData()
    if tp == 1 then
        gadgetData.rNum = gadgetData.rNum + 1
        gadgetData.nNum = gadgetData.nNum - 1

    elseif tp == 2 then
        gadgetData.list[tostring(data.id)] =  gadgetData.list[tostring(data.id)] or 0
        gadgetData.list[tostring(data.id)] = gadgetData.list[tostring(data.id)] + 1
    end
end

-- 获得对应时间跨度的小物件生成表数据
function MainViewModel:getTimeSpan()
    local tempData = {}
    local serverTime = self._userModel:getCurServerTime()
    local serverYear = os.date("%Y", serverTime)
    local serverMonth = os.date("%m", serverTime)
    local serverDay = os.date("%d", serverTime)
    local tabTemp = tab.gadgetTime
    for i = 1, #tabTemp do
        local startTime = os.time({year = serverYear, month = serverMonth, day = serverDay,
            hour = tonumber(tabTemp[i].start_time[1]), min = tonumber(tabTemp[i].start_time[2]), sec = 0})
        local endTime = os.time({year = serverYear, month = serverMonth, day = serverDay,
            hour = tonumber(tabTemp[i].end_time[1]), min = tonumber(tabTemp[i].end_time[2]), sec = 0})

        if startTime < serverTime and serverTime < endTime then
            table.insert(tempData, {id = i, num = tabTemp[i].num})
        end
    end
    return tempData
end

-- 生成小物件
-- @param tp 生成类型：1、累积在线时间  2、时间段随机生成
-- @param data 生成数据
function MainViewModel:addGadget(tp, data)
    local gadgetData = self:getGadgetData()
    if tp == 1 then
        if gadgetData.nNum + gadgetData.rNum < tab:GadgetConfig("dailyLimit_reward").value then
            gadgetData.nNum = gadgetData.nNum + 1

--            -- 如果小物件数量超过上限，则替代时间段小物件(会消失)
--            if self:getGadgetNum() > table.maxn(tab:GadgetConfig("location").value) then 
--                local timeSpan = self:getTimeSpan()
--                for i = 1, #timeSpan do
--                    if timeSpan[i].num - gadgetData.list[timeSpan[i].id] > 0 then
--                        gadgetData.list[timeSpan[i].id] = gadgetData.list[timeSpan[i].id] + 1
--                    end
--                end
--            end
            self:reflashData("addGadget")
        end
    elseif tp == 2 then
--        if data.num + self:getGadgetNum() > table.maxn(tab:GadgetConfig("location").value) then
--            gadgetData[data.id] = gadgetData.data.num
--        end
    end
end

-- 五点清空当天未领取累积小物件
function MainViewModel:clearLeijiGadget()
    local gadgetData = self:getGadgetData()
    gadgetData.nNum = 0
    gadgetData.rNum = 0
    self:reflashData("clearLeijiGadget")
end
return MainViewModel
