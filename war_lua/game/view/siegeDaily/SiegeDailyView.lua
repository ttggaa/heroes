--[[
    @@FileName   SiegeDailyView.lua
    @Authors    hexinping
    @Date       2017-09-05 20:54:9
    @Email      <hexinping@playcrad.com>
    @Description   攻城日常UI
--]]

-- local vars
local createTeamIconById = IconUtils.createTeamIconById
local adjustIconScale    = IconUtils.adjustIconScale
local createItemIconById = IconUtils.createItemIconById
local modelManager       = ModelManager:getInstance()
local getModel           = modelManager.getModel
local ccc4b              = cc.c4b


local pageVar = {
      attackType = 1,                               --攻城
      defendType = 2,                               --守城
      pageBgName = {"siegeDaily_battleBg_Atk.jpg", "siegeDaily_battleBg_Def.jpg"},
      pagePlist  = {{"asset/ui/siegeDaily.plist", "asset/ui/siegeDaily.png"}},
      textTips   = {"暂无", "策划没有加描述", "今日剩余次数已用尽", "策划还没定"},
      labels     = {"攻城详情", "守城详情"},
      qulityIcon = {"globalImageUI_squality_jin.png","globalImageUI4_iquality0.png"}
}

local  SiegeDailyView = class("SiegeDailyView",BaseView)

function SiegeDailyView:ctor(params)
    self.super.ctor(self)
    self._viewType          = params.utype
    self._container         = params.container
    self._dailySiegeModel   = getModel(modelManager, "DailySiegeModel")
    self._teamModel         = getModel(modelManager, "TeamModel")
    self._formationModel    = getModel(modelManager, "FormationModel")
    self._userModel         = getModel(modelManager, "UserModel")
    local rankModel         = getModel(modelManager, "RankModel")
    self.FormationTypes  = {self._formationModel.kFormationTypeWeapon, self._formationModel.kFormationTypeWeaponDef}
    self._battleFunciton = {
        [1] = BattleUtils.enterBattleView_Siege_Atk,
        [2] = BattleUtils.enterBattleView_Siege_Def,
    }
    self._rankType = {rankModel.kRankTypeDailySiegeAtc, rankModel.kRankTypeDailySiegeDed}
    self:setListenReflashWithParam(true)
    self:listenReflash("DailySiegeModel", self.onModelReflash)
end

-- 第一次被加到父节点时候调用
function SiegeDailyView:onBeforeAdd(callBack)
    self._serverMgr:sendMsg("DailySiegeServer", "getDailySiegeInfo", {}, true, {},function (success)
        if success then
            if callBack then
                callBack()
            end 
            self:reflashUI()
        end 
    end)
end

function SiegeDailyView:_initVars()
    local prefixStr   = "bg"
    self._attackImage = self:getUI(prefixStr..".attackImage")
    self._defendImage = self:getUI(prefixStr..".defendImage")

    self._rank        = {}
    self._myRank      = {}
    self._buttons     = {}
    self._battleBtns  = {}
    self._targetInfo  = {}
    self._recommend   = {}

    prefixStr      = "bg.left"
    self._rewardTp = self:getUI(prefixStr ..".rewards.rewardTp")
    self._rewardNode = self:getUI(prefixStr ..".rewards.rewardNode")

    prefixStr = "bg.left.rank"
    local varNames = {"rank1","rank2","rank3"}
    for i,v in ipairs(varNames) do
        local name          = self:getUI(prefixStr ..".".. v..".name")
        local diamondImg    = self:getUI(prefixStr ..".".. v..".diamondImg")
        local num           = self:getUI(prefixStr ..".".. v..".num")
        self._rank[v]       = {name, diamondImg, num}
    end

    self._rankRewLabel = self:getUI(prefixStr .. ".rankRewLabel")

    varNames = {"ranking","diamondImg","num"}
    for i,v in ipairs(varNames) do
        local node = self:getUI(prefixStr ..".myRank.".. v)
        self._myRank[v] = node
    end 

    prefixStr = "bg.left.buttons"
    self._attackNode = self:getUI(prefixStr ..".attack")
    self._defendNode = self:getUI(prefixStr ..".defend")
    varNames  = {"rankBtn","cityInfoBtn"}
    for i,v in ipairs(varNames) do
        local btn = self:getUI(prefixStr ..".attack.".. v)
        self._buttons["attack"..v] = btn
    end

    varNames = {"rewardBtn","ruleBtn","rankBtn"}
    for i,v in ipairs(varNames) do
        local btn = self:getUI(prefixStr ..".defend.".. v)
        self._buttons["defend"..v]  = btn
    end

    prefixStr = "bg.right.buttons"
    varNames  = {"battleBtn","sweepingBtn"}
    for i,v in ipairs(varNames) do
        local btn = self:getUI(prefixStr ..".".. v)
        self._battleBtns[v] = btn
    end

    self._remainNum = self:getUI("bg.right.buttons.battleBtn.num")
    local label = self:getUI("bg.right.buttons.battleBtn.label")
    label:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._remainNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    prefixStr = "bg.right.target"
    varNames  = {"img","name","des"}
    for i,v in ipairs(varNames) do
        local node = self:getUI(prefixStr ..".attackTarget.".. v)
        self._targetInfo["attack"..v] = node
    end

    self._teamTp = self:getUI(prefixStr..".teamTp")
    self._teamsNode = self:getUI(prefixStr..".teamsNode")

    self._attackTarget = self:getUI(prefixStr..".attackTarget")
    self._defendTarget = self:getUI(prefixStr..".defendTarget")

    self._enimyTp = self:getUI(prefixStr..".defendTarget.enimyTp")
    self._enimysNode = self:getUI(prefixStr..".defendTarget.enimysNode")

    prefixStr = "bg.right.recommend"
    self._teamTp = self:getUI(prefixStr..".teamTp")
    self._teamsNode = self:getUI(prefixStr..".teamsNode")
    self._recommendDes = self:getUI(prefixStr..".des")

    local infoBtn = self:getUI("bg.left.rewards.defNode.infoBtn")
    self:registerClickEvent(infoBtn,function ()
        self:clickInfoBtn(infoBtn)
    end)

end

function SiegeDailyView:clickInfoBtn(infoBtn)
    self._viewMgr:showHintView("global.GlobalTipView",
        {tipType = 16, node = infoBtn, des = lang("SIEGE_DAILY_DEFENDRULES3"), notAutoClose = true})
end

function SiegeDailyView:_isAttackPage()
    return self._viewType == pageVar.attackType
end

function SiegeDailyView:_initTitleImage()
    local visible = self:_isAttackPage()
    self._attackImage:setVisible(visible)
    self._defendImage:setVisible(not visible)
end

function SiegeDailyView:_initRewards()
    local label = self:getUI("bg.left.rewards.diaoluoLabel")
    label:setString(pageVar.labels[self._viewType])
    label:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    local isAck = self._viewType == pageVar.attackType
    local aktNode = self:getUI("bg.left.rewards.aktNode")
    local defNode = self:getUI("bg.left.rewards.defNode")
    aktNode:setVisible(isAck)
    defNode:setVisible(not isAck)

    local function setLabel(node, name, str)
       local label = node:getChildByFullName(name)
       label:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
       label:setString(str)
    end
    if isAck then
        local diff = lang("LONGZHIGUONANDU_" .. self._cfgdata.diff)
        setLabel(aktNode, "levelLabel", diff)
    else
        local t = self._dailySiegeModel:getMonsterLevelAndBuff()
        local  monsterLevel = t.level
        setLabel(defNode, "levelLabel", monsterLevel)
        local buff = t.buff
        setLabel(defNode, "levelLabel1", buff)
    end 
   
end

function SiegeDailyView:_initRank()

    local rankLabel = self:getUI("bg.left.rank.rankLabel")
    rankLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local isAttack = true
    self._rankRewLabel:setVisible(not isAttack)

    -- rank info
    local rankDatas = self._dailySiegeModel:getRankData()
    local varNames = {"rank1","rank2","rank3"}
    local rankNodeT = self._rank
    for i,v in ipairs(varNames) do
        local rankData = rankDatas[i]
        local rankNodes = rankNodeT[v]
        rankNodes[1]:setVisible(true)
        rankNodes[2]:setVisible(not isAttack)
        rankNodes[3]:setVisible(not isAttack)

        if rankData then
            rankNodes[1]:setString(rankData.name)
        else
            rankNodes[1]:setString(pageVar.textTips[1])
        end
        local reward = self._dailySiegeModel:getRankRewardByRank(i)
        rankNodes[3]:setString(reward)
    end

    -- myRank
    local myRank =  self._myRank
    myRank["diamondImg"]:setVisible(not isAttack)
    myRank["num"]:setVisible(not isAttack)

    local myRankData = self._dailySiegeModel:getMyRankData()
    local rw = self._dailySiegeModel:getRankRewardByRank(myRankData.rank)
    myRank["num"]:setString(rw)
    local str = myRankData.rank
    if myRankData.rank == nil or myRankData.rank == 0 then
        str = pageVar.textTips[1]
    end 
    myRank["ranking"]:setString(str)

    local rankWidget = self:getUI("bg.left.rankClickPanel")
    self:registerClickEvent(rankWidget, function ()
        self:clickRankBtn()
    end)

end

function SiegeDailyView:_initLeftBtns()
    local isAttack = self:_isAttackPage()
    self._attackNode:setVisible(isAttack)
    self._defendNode:setVisible(not isAttack)
    for k,v in pairs(self._buttons) do
        -- add clickEvent
        self:registerClickEvent(v, function ()
            self:_btnClick(k)
        end)
    end
end

function SiegeDailyView:_initTarget()
    local isAttack = self:_isAttackPage()
    self._attackTarget:setVisible(isAttack)
    self._defendTarget:setVisible(not isAttack)

    -- updata target info 
    local targetInfo = self._targetInfo
    if isAttack then
        local theme   = self._cfgdata.theme 
        local iconPng = "globalImgUI_class"..theme..".png"
        local name    = lang("NESTS_CAMP_NAME_"..theme)
        local des     = lang(self._cfgdata.themeDes) or pageVar.textTips[2]
        targetInfo["attackimg"]:loadTexture(iconPng,1)
        targetInfo["attackname"]:setString(name)
        targetInfo["attackname"]:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        targetInfo["attackdes"]:setString(des)
    else
        local label = self:getUI("bg.right.target.defendTarget.label")
        label:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        local enimyDatas = self._dailySiegeModel:getEnimys(self._cfgdata.id)
        local offsetX = 15
        local teamModel = self._modelMgr:getModel("TeamModel")
        local getTeamQualityByStage = teamModel.getTeamQualityByStage
        self._enimysNode:removeAllChildren()
        for i,v in ipairs(enimyDatas) do
            local id = v
            local teamTableData = tab:Team(id)
            if not teamTableData then print("invalid team id:", self._iconId) end
            local backQuality = getTeamQualityByStage(self, teamTableData.stage)
            local icon = createTeamIconById(self,{
                teamData = {id = id}, 
                sysTeamData = teamTableData, 
                quality = backQuality[1],
                quaAddition = backQuality[2],  
                eventStyle = 2})
            icon.iconColor:loadTexture(pageVar.qulityIcon[1], 1)
            IconUtils:setTeamIconStarVisible(icon, false)
            local enimyTp = self._enimyTp:clone()
            enimyTp:addChild(icon)
            adjustIconScale(self, enimyTp, icon)
            local posX = -i*enimyTp:getContentSize().width - (i-1) * offsetX + self._enimysNode:getContentSize().width
            enimyTp:setPosition(posX,0)
            self._enimysNode:addChild(enimyTp)
        end
    end 
end

function SiegeDailyView:getTeamIconById(id)
    local teamId = id
    local teamTableData = tab:Team(teamId)
    local star = 0
    local stage = 1
    if teamTableData then
        star = teamTableData.star
        stage = teamTableData.stage
    end
    local backQuality = self._teamModel:getTeamQualityByStage(stage)
    local team = createTeamIconById(self,{
        teamData = {id = teamId, star = star}, 
        sysTeamData = teamTableData, 
        quality = nil, 
        quaAddition = backQuality[2], 
        tipType = 9, 
        eventStyle = 2})
    IconUtils:setTeamIconStarVisible(team, false)
    team.iconColor:loadTexture(pageVar.qulityIcon[2], 1)
    return team
end

function SiegeDailyView:_initRecommend()
    local title = self:getUI("bg.right.recommend.title")
    title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local recommend = self:getUI("bg.right.recommend")
    local visible = self._cfgdata.showRecommend == 1 and true or false
    recommend:setVisible(visible)
    -- local des = self._cfgdata.recommenddes
    local des = self._viewType == pageVar.attackType and "SIEGE_GONGCHENG_RECOMMEND" or "SIEGE_SHOUCHENG_RECOMMEND"
    -- self._recommendDes:setString("")

    local strDes = RichTextFactory:create(lang(des),600,52)
    strDes:formatText()
    strDes:setVerticalSpace(3)
    strDes:setAnchorPoint(cc.p(0,0))
    local w = strDes:getVirtualRendererSize().width
    local h = strDes:getVirtualRendererSize().height
    local w2 = strDes:getRealSize().width 

    strDes:setPosition(-w2-w*0.5,-1.5*h)
    self._recommendDes:removeAllChildren()
    self._recommendDes:addChild(strDes)
    self._teamsNode:removeAllChildren()
    local offsetX = 10
    local recommendCfg = self._cfgdata.recommend
    if self._viewType == pageVar.defendType then
        recommendCfg = self._dailySiegeModel:getDefendRecommend()
    end

    local itemW = self._teamTp:getContentSize().width
    local containerW = self._teamsNode:getContentSize().width
    for i,v in ipairs(recommendCfg) do
        local team = self:getTeamIconById(v)
        local teamTp = self._teamTp:clone()
        teamTp:addChild(team)
        adjustIconScale(self, teamTp, team)
        local posX = -i*itemW - i* offsetX + containerW
        teamTp:setPosition(posX,0)
        self._teamsNode:addChild(teamTp)
    end
end

function SiegeDailyView:_initRightBtns()
    local isAttack = self:_isAttackPage()
    -- 是否守城过
    local isShowSweep = self._dailySiegeModel:isDefendCity()
    self._battleBtns["sweepingBtn"]:setVisible(not isAttack and isShowSweep)
    for k,v in pairs(self._battleBtns) do
        -- add clickEvent
        self:registerClickEvent(v, function ()
            self:_btnClick(k)
        end)
    end

    local total, num = self._dailySiegeModel:getRemainNum(self._viewType)
    local color = ccc4b(133, 244, 126, 255)
    if num == 0 then
        color = UIUtils.colorTable.ccColorQuality6
    end 
    self._remainNum:setTextColor(color)
    self._remainNum:setString(num.."/"..total)

    local historyTxt = self:getUI("bg.right.buttons.sweepingBtn.histroyTxt")
    if historyTxt then
        historyTxt:setString("守城最佳战力值:"..self._dailySiegeModel:getMaxHisPower().."\n 守城最高伤害:"..(self._dailySiegeModel:getData()._maxDamage or 0))
    end
end

function SiegeDailyView:_initLeftUI()
    self:_initRewards()
    self:_initLeftBtns()

    local theme = self._cfgdata.theme
    self._serverMgr:sendMsg("DailySiegeServer", "getSiegeShowData", 
        {siegeType = self._viewType,type = theme}, true, {}, 
        function(success)
            if success then
                -- 不知道测试测个什么鬼，报_initRank方法找不到 加个防御
                if self["_initRank"] then
                    self:_initRank()
                end  
            end 
    end)
end

function SiegeDailyView:_initRightUI()
    self:_initTarget()
    self:_initRightBtns()
    self:_initRecommend()
end

function SiegeDailyView:_btnClick(key)
    local clickFunc  = {
        attackrankBtn       = "clickRankBtn",           -- 攻城排行榜
        attackcityInfoBtn   = "clickCityInfoBtn",       -- 攻城城市信息
        defendrewardBtn     = "clickRewardBtn",         -- 守城奖励
        defendruleBtn       = "clickRuleBtn",           -- 守城规则
        defendrankBtn       = "clickRankBtn",           -- 守城排行榜
        battleBtn           = "clickBattleBtn",         -- 攻城守城战斗
        sweepingBtn         = "clickSweepingBtn",       -- 守城扫荡
    }

    for k,v in pairs(clickFunc) do
        if key == k then
            print("click btn ".. key)
            self[v](self)
            break
        end 
    end
end

function SiegeDailyView:clickCityInfoBtn()
    self._viewMgr:showDialog("siegeDaily.SiegeDailyCityInfoView")
end

function SiegeDailyView:clickRewardBtn()
    self._viewMgr:showDialog("siegeDaily.SiegeDailyRewardView")
end

function SiegeDailyView:clickRuleBtn()
    self._viewMgr:showDialog("siegeDaily.SiegeDailyRuleView", {viewType = self._viewType})
end

-- 初始化UI后会调用, 有需要请覆盖
function SiegeDailyView:onInit()
    self:_initVars()
end

-- 接收自定义消息
function SiegeDailyView:reflashUI(data)
    self._cfgdata = self._dailySiegeModel:getCardConfigData(self._viewType)
    self:_initTitleImage()
    self:_initLeftUI()
    self:_initRightUI()
    if self._container then
        self._container:update()
    end 
end

function SiegeDailyView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{hideInfo = true, hideHead = true})
end

function SiegeDailyView:clickRankBtn()
    local rankType = self._rankType[self._viewType]
    self._modelMgr:getModel("RankModel"):setRankTypeAndStartNum(rankType,1)
    self._serverMgr:sendMsg("RankServer", "getRankList", {type=rankType,id=self._cfgdata.theme,startRank = 1}, true, {}, function(result) 
        local resultKey = result.key
        self._viewMgr:showDialog("siegeDaily.SiegeDailyRankDialog",
            {   targetId  = self._cfgdata.theme,
                rankType  = rankType,
                resultKey = resultKey
            })
    end)
end

function SiegeDailyView:isCanBattle()
    local _,remainNum = self._dailySiegeModel:getRemainNum(self._viewType)
    if remainNum <= 0 then
        self._viewMgr:showTip(pageVar.textTips[3])
        return false
    end
    return true
end
-- 攻城战斗
function SiegeDailyView:clickBattleBtn()
    if not self:isCanBattle() then return end
    if self._viewType == pageVar.attackType then
        local theme = self._cfgdata.theme
        local diff  = self._cfgdata.diff
        self._siegeLevelSelectedDialog = self._viewMgr:showDialog("siegeDaily.SiegeLevelSelectedView", 
        {container = self, theme = theme, level = diff}, true, true)
    else
        self:defendBattle()
    end 
end

--扫荡
function SiegeDailyView:clickSweepingBtn()
    if not self:isCanBattle() then return end

    local sweepFunc = function ()
        self._serverMgr:sendMsg("DailySiegeServer", "sweepDefend", 
        {type = self._cfgdata.theme}, true, {},function (success, result)
            if success then
                local reward = result.reward
                DialogUtils.showGiftGet({gifts = reward, callback = function()
                    self:closeLevelDialog()
                    self._dailySiegeModel:setForceReflash(false)
                    self:reflashUI()
                end})
            end 
        end)
    end

    -- 二次确认
    if self:checkRecomment() then
        DialogUtils.showShowSelect({desc = lang("TIPS_PVE_CRYPT_04"),callback1=function( )
            sweepFunc()
        end})
    else
         -- 发送获取奖励协议
        self._serverMgr:sendMsg("DailySiegeServer", "getSweepReward", {type = self._cfgdata.theme}, true, {}, function(success, result)
            if not success then
                self._viewMgr:showTip("扫荡奖励获取失败")
                return
            end
            local siegeWeaponExp = result[1][3] or 0
            local texp = result[2][3] or 0
            local curDesc  = string.gsub(lang("TIPS_SIEGEDAILY_DEFENCE_01"), "{$siegeItem}", ItemUtils.formatItemCount(siegeWeaponExp))
            curDesc = string.gsub(curDesc, "{$texp}", ItemUtils.formatItemCount(texp))
            DialogUtils.showShowSelect({desc = curDesc,callback1=function( )
                sweepFunc()
            end})
        end)
    end
end

function SiegeDailyView:checkRecomment()
    local playerPower = self._formationModel:getCurrentFightScoreByType(self.FormationTypes[self._viewType])
    local warning     = self._dailySiegeModel:getSweepWarning()
    local hisMax      = self._dailySiegeModel:getMaxHisPower()
    if playerPower-hisMax > warning then
        return true
    end
    return false
end

-- 守城战斗
function SiegeDailyView:defendBattle()
    local battle = function(battleData)
        self._serverMgr:sendMsg("DailySiegeServer", "atkBeforeDefend", 
            {type = self._cfgdata.theme}, true, {}, 
            function(success, result)
                if not success then 
                    return 
                end
                self._token = result.token
                self._viewMgr:popView()
                local battleId = self._dailySiegeModel:getDefBattleId()
                local defWin = self._dailySiegeModel:getDefBattleWinNum()
                self._battleFunciton[self._viewType](BattleUtils.jsonData2lua_battleData(result["atk"]), battleId, defWin, false,
                function (info, callback)
                    if not info then
                        return
                    end
                    local quit  = 0
                    if info.isSurrender then
                        quit = 1
                    end 
                    local args = { win = info.win,
                       zzid = GameStatic.zzid8,
                       time = info.time,
                       skillList = info.skillList,
                       serverInfoEx = info.serverInfoEx,
                       waves = info.exInfo.waveCount,
                       damage = info.exInfo.damageCount,
                      }
                    self._serverMgr:sendMsg("DailySiegeServer", "atkAfterDefend", 
                        {type = self._cfgdata.theme,token = self._token,args = json.encode(args),quit = quit}, true, {},
                    function (success, result)
                        if success then
                             self._dailySiegeModel:setForceReflash(false)
                             self:reflashUI()
                             info["exInfo"]["newRank"] = result.newRank
                             info["exInfo"]["oldRank"] = result.oldRank
                             info.exInfo.isHistoryMaxDamage = self._dailySiegeModel:isHisMaxDamage()
                             callback(info, result.reward)
                        end 
                    end)


                end,
                function (info) end)
        end)
    end
    self:showFormationView(battle)
end

function SiegeDailyView:_clearVars()
    -- clear vars
    local tb = { "_rank", "_myRank", "_buttons", "_defendNode", 
                "_defendTarget","_targetInfo", "_remainNum", 
                "_viewType", "_attackImage", "_defendImage", 
                "_battleBtns","_attackNode", "_recommendDes", 
                "_attackTarget","_enimysNode","_rankRewLabel",
                "_rewardTp","_rewardNode", "_teamTp","_teamsNode",
                "_enimyTp","_siegeLevel"
               }
    for i,v in ipairs(tb) do
        if type(self[v]) == "table" then
            for k,node in pairs(self[v]) do
                if type(node) == "table" then
                    for _,m in pairs(node) do
                        m = nil
                    end
                    node = nil
                else
                    node = nil
                end 
            end
            self[v] = nil
        else
            self[v] = nil
        end
    end
    tb = nil
end

function SiegeDailyView:onDestroy()
    self:_clearVars()
end

function SiegeDailyView:getBgName()
    return pageVar.pageBgName[self._viewType]
end

function SiegeDailyView:onSiegeLevelClose()
   self._siegeLevelSelectedDialog = nil
end

function SiegeDailyView:onSiegeLevelSelected(level)
    self._siegeLevel = level
    local battle = function(battleData)
        self._serverMgr:sendMsg("DailySiegeServer", "atkBeforeSiege", 
            {type = self._cfgdata.theme, diff = self._siegeLevel}, true, {}, 
            function(success, result)
                if not success then 
                    return 
                end
                self:closeLevelDialog()
                self._token = result.token
                self._viewMgr:popView()
                local siegeCardIdDatas = self._dailySiegeModel:getConfigDataByTypeAndDiff(self._cfgdata.theme,self._siegeLevel)
                local battleId = siegeCardIdDatas.battleId
                self._battleFunciton[self._viewType](BattleUtils.jsonData2lua_battleData(result["atk"]),battleId,false,
                function (info, callback)
                    if not info then
                        return
                    end
               
                    local siegeBroken = 0
                    -- 需求改了，城破了不算人头
                    -- if info.exInfo.siegeBroken then
                    --     siegeBroken = 1
                    -- end 
                    local quit  = 0
                    if info.isSurrender then
                        quit = 1
                    end 
                    self.killCount = info.dieCount2 + siegeBroken
                    -- 添加伤害百分比的参数 先用假数据
                    -- info.percent = 100
                    info.exInfo.pro = 100 - info.exInfo.pro
                    local args = { win = info.win,
                               -- dieCount2 = info.dieCount2,
                               -- siegeBroken = siegeBroken,
                               percent = info.exInfo.pro,
                               zzid = GameStatic.zzid7,
                               time = info.time,
                               skillList = info.skillList,
                               serverInfoEx = info.serverInfoEx,
                              }
                    self._serverMgr:sendMsg("DailySiegeServer", "atkAfterSiege", 
                        {type = self._cfgdata.theme, diff = self._siegeLevel,token = self._token,args = json.encode(args),quit  = quit}, 
                        true, {}, 
                        function(success, result)
                            dump(result, "result", 5)
                            if not  success then 
                                print("atkAfterSiege error:", success)
                                self._viewMgr:onLuaError("atkAfterSiege error:" .. errorCode)
                                return 
                            end
                            self._dailySiegeModel:setForceReflash(false)
                            self:reflashUI()
                            info.exInfo.diff = self._siegeLevel
                            info.exInfo.siegeCardId = siegeCardIdDatas.id
                            info.exInfo.isHisMaxDiff = self._dailySiegeModel:isHisMaxDiff()
                            info.exInfo.isHisMaxKillCount = self._dailySiegeModel:isHisMaxKillCount()
                            callback(info, result.reward)
                           
                    end)
                end,
                function (info) end)

        end)
    end
    self:showFormationView(battle)
end

function SiegeDailyView:showFormationView(battleFunc)
    local data = {}
    data.formationType  = self.FormationTypes[self._viewType]
    data.recommend      = self._cfgdata["recommend"]
    data.callback       = function(formationData)
        battleFunc(formationData)
    end
    if self._viewType == pageVar.defendType then
        data.recommend = self._dailySiegeModel:getDefendRecommend()
    end
    self._viewMgr:showView("formation.NewFormationView", data)

end

function SiegeDailyView:onQuickPass(level)
    self._siegeLevel = level
    self._serverMgr:sendMsg("DailySiegeServer", "sweepSiege", 
        {type = self._cfgdata.theme, diff = self._siegeLevel}, true, {},function (success, result)
            if success then
                local reward = result.reward
                DialogUtils.showGiftGet({gifts = reward, callback = function()
                    self:closeLevelDialog()
                    self._dailySiegeModel:setForceReflash(false)                    
                    self:reflashUI()
                end})
            end 
    end)
end

function SiegeDailyView:closeLevelDialog()
    if self._siegeLevelSelectedDialog then
        self._siegeLevelSelectedDialog:close()
        self._siegeLevelSelectedDialog = nil
    end
end

function SiegeDailyView:getAsyncRes()
    return pageVar.pagePlist
end

function SiegeDailyView.dtor()
    createTeamIconById = nil
    adjustIconScale    = nil
    createItemIconById = nil
    modelManager       = nil
    getModel           = nil
    ccc4b              = nil
end

function SiegeDailyView:onModelReflash(event)
    if event == "refleshUIEvent" then
        self._dailySiegeModel:resetDailyNum()
        self:reflashUI()
    end
end

return SiegeDailyView