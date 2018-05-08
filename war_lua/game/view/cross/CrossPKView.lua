--[[
    Filename:    CrossPKView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-11-09 16:05:00
    Description: File description
--]]

local l_tempId = 6

local CrossPKView = class("CrossPKView", BaseView)
local CrossUtils = CrossUtils

local awardImg = {
    [40010] = "globalImageUI_kuafuCoinmin.png",
    [30203] = "globalImageUI_texp.png",
    [907016] = "i_907016.png",
    [3905] = "ti_shiyuansu.jpg",
}

local tostring = tostring
local tonumber = tonumber

function CrossPKView:ctor(param)
    CrossPKView.super.ctor(self)
    self._arenaId = param.arenaId
    self._openReport = 1
    self._tabSelect = param.tabSelect or 1
    self._crossWidth = 1136
    -- self._soloSelect = 1
    print("MAX_SCREEN_WIDTH < self._crossWidth=============", MAX_SCREEN_WIDTH, self._crossWidth)
    if MAX_SCREEN_WIDTH < self._crossWidth then
        self._crossWidth = MAX_SCREEN_WIDTH
    end
end

function CrossPKView:onComplete()
    self._viewMgr:enableScreenWidthBar()
    self._widget:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    if MAX_SCREEN_WIDTH > self._crossWidth then
        self._widget:setContentSize(self._crossWidth, MAX_SCREEN_HEIGHT)
    end
end

function CrossPKView:onTop()
    self._viewMgr:enableScreenWidthBar()
end

function CrossPKView:onHide()
    -- self._crossBar = true
    if self._crossBar ~= true then
        self._viewMgr:disableScreenWidthBar()
    end
end

function CrossPKView:onDestroy()
    self._viewMgr:disableScreenWidthBar()
    CrossPKView.super.onDestroy(self)
end


function CrossPKView:onInit()
    self._userModel = self._modelMgr:getModel("UserModel")
    self._crossModel = self._modelMgr:getModel("CrossModel")

    local arenaData = self._crossModel:getOpenArenaData()
    self._arenaType = arenaData[self._arenaId]
    self._lineUp = self._crossModel:getFormationFightData(self._arenaType) 

    self._isSeasonSpot = (self._arenaType == 3 and self._crossModel:getSeasonSpot() ~= 0)
    self._isWeaponSpot = (self._arenaType == 3 and self._crossModel:getSeasonSpot() == 1)

    print("self._arenaType=========", self._arenaType)
    self._tableData = {}
    for i=1,5 do
        self._tableData[i] = i
    end

    self._bgcell = self:getUI("bgcell")
    self._bgcell:setVisible(false)

    local changeBtn = self:getUI("rightDown.changeBtn")
    self._changeClick = true
    self:registerClickEvent(changeBtn, function()
        if self._changeClick == true then
            self:refreshCrossPK()
            self._changeClick = false
        else
            self._viewMgr:showTip(lang("cp_tips_refreshbattle"))
        end
        local callFunc = cc.CallFunc:create(function()
            self._changeClick = true
        end)
        local seq = cc.Sequence:create(cc.DelayTime:create(1), callFunc)
        changeBtn:runAction(seq)
        -- self:getChallengeInfo()
    end)

    local scoreRuleBtn = self:getUI("leftLayer.pkLayer.scoreRuleBtn")
    self:registerClickEvent(scoreRuleBtn, function()
        UIUtils:reloadLuaFile("cross.CrossScoreRuleView")
        self._viewMgr:showDialog("cross.CrossScoreRuleView")
    end)

    self:addTableView()

    self:reflashUI()


    local tab1 = self:getUI("leftLayer.tab1")
    local tab2 = self:getUI("leftLayer.tab2")
    self:registerClickEvent(tab1, function(sender)self:tabButtonClick(sender, 1) end)
    self:registerClickEvent(tab2, function(sender)self:tabButtonClick(sender, 2) end)
    self._tabEventTarget = {}
    table.insert(self._tabEventTarget, tab1)
    table.insert(self._tabEventTarget, tab2)

    self:tabButtonClick(self:getUI("leftLayer.tab" .. (self._tabSelect or 1)), (self._tabSelect or 1))
    self:listenReflash("CrossModel", self.updatePkView)

    -- self:updatePKLayer()
    -- self:getChallengeInfo()

    self:popCrossPKView()
    self:onInitUI()
    self:initBtn()
    self:initPKAnim()
    self:updatePKLayer()
end

function CrossPKView:popCrossPKView()
    local right = self:getUI("rightLayer.right")
    local timeTab = self._crossModel:getOpenTime()
    local endTime = timeTab[3] - 5
    local callFunc = cc.CallFunc:create(function()
        local curServerTime = self._userModel:getCurServerTime()
        if curServerTime > endTime then
            right:stopAllActions()
            self:close()
        end
    end)
    local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
    right:runAction(cc.RepeatForever:create(seq))
end 

function CrossPKView:getSoloTime()
    local timeTab = self._crossModel:getOpenTime()
    local endTime = timeTab[3]
    local curServerTime = self._userModel:getCurServerTime()
    local flag = true
    if curServerTime > endTime then
        flag = false
    end
    return flag
end 

function CrossPKView:onAnimEnd()
    local tableList = self._crossModel:getDefReport()
    if table.nums(tableList) > 0 then
        UIUtils:reloadLuaFile("cross.CrossDefDialog")
        self._viewMgr:showDialog("cross.CrossDefDialog", {arenaType = self._arenaType})
    end

    --line position
    local line1 = self:getUI('leftDown.line1')
    local line2 = self:getUI('leftDown.line2')
    
    if self._isSeasonSpot then
        local rightDown = self:getUI('rightDown')
        local centerDown = self:getUI('centerDown')
        local leftDown = self:getUI('leftDown')
        local centerPosX = centerDown:getPositionX()
        local posX = centerPosX - (centerPosX - leftDown:getContentSize().width ) / 2
        line1:setPositionX(posX)
        local rightPosX = rightDown:getPositionX()
        posX = rightPosX - (rightPosX - (centerDown:getContentSize().width + centerPosX)) / 2
        line2:setVisible(true)
        line2:setPositionX(posX)
    else
        line1:setPositionX(MAX_SCREEN_WIDTH / 2)
        line2:setVisible(false)
    end

    
end

function CrossPKView:updatePkView()
    local param = {region = self._arenaType, defReport = 1}
    self._serverMgr:sendMsg("CrossPKServer", "enterCrossPK", param, true, {}, function (result)
        if not self._tableView then 
            return
        end
        self:reflashUI()
        if self._tabSelect == 1 then
            self:updatePKLayer()
        elseif self._tabSelect == 2 then
            self:getChallengeInfo()
        end
    end)
end 

function CrossPKView:applicationWillEnterForeground(second)
    self:updatePkView()
end


function CrossPKView:scrollToNext(selectedIndex)
    local param = self._tableData

    local userId = self._userModel:getData()._id
    -- dump(self._enemyData)
    local userIndex = 1
    for k,v in ipairs(self._enemyData) do
        if userId == v.rid then
            userIndex = k
        end
    end
    local selectedIndex = selectedIndex or userIndex

    local tt = math.floor(selectedIndex/3)
    if (selectedIndex/3 - tt) ~= 0 then
        tt = tt + 1
    end
    local tempheight = 640*5
    local tabHeight = tempheight - 640*tt
    if selectedIndex > 8 then
        tabHeight = tabHeight + 150
    end

    self._tableView:setContentOffset(cc.p(0, -1*tabHeight))
end

function CrossPKView:onInitUI()
    local allScore1 = self:getUI("leftLayer.pkLayer.serverBg.allScore1")
    local allScore2 = self:getUI("leftLayer.pkLayer.serverBg.allScore2")
    local saddNum1 = self:getUI("leftLayer.pkLayer.serverBg.saddNum1")
    local saddNum2 = self:getUI("leftLayer.pkLayer.serverBg.saddNum2")
    local sName1Lab = self:getUI("leftLayer.pkLayer.serverBg.sName1")
    local sName2Lab = self:getUI("leftLayer.pkLayer.serverBg.sName2")
    local lab1 = self:getUI("leftLayer.pkLayer.serverBg.lab1")
    local lab2 = self:getUI("leftLayer.pkLayer.serverBg.lab2")

    local scoreLab = self:getUI("leftLayer.pkLayer.scoreBg.score")
    local addNum = self:getUI("leftLayer.pkLayer.scoreBg.addNum")

    local addChangeBtn = self:getUI("rightDown.addChangeBtn")
    local myRank = self:getUI("leftLayer.pkLayer.myRank")
    local soloNum = self:getUI("rightDown.soloNum")

    local pname = self:getUI("leftLayer.soloLayer.heroBg.pname")
    local pserverName = self:getUI("leftLayer.soloLayer.heroBg.pserverName")
    local arenaNameLab = self:getUI("leftLayer.soloLayer.arenaBg.arenaName")

    local ruleBtn = self:getUI("leftLayer.soloLayer.ruleBtn")
    self:registerClickEvent(ruleBtn, function()
        UIUtils:reloadLuaFile("cross.CrossRuleView")
        local str = lang("cp_limitbattle_rule")
        self._viewMgr:showDialog("cross.CrossSoloRuleView", {str = str}, true)
    end) 

    allScore1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    allScore2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    saddNum1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    saddNum2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    sName1Lab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    sName2Lab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    scoreLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    addNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    scoreLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    addNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    addChangeBtn:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    myRank:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    soloNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    lab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    lab2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    pname:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    pserverName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    arenaNameLab:setColor(cc.c3b(255,255,255))
    arenaNameLab:enable2Color(1, cc.c4b(252, 232, 49, 255))
    arenaNameLab:enableOutline(cc.c4b(90, 13, 13, 255), 1)

    local richtextBg = self:getUI("leftDown.richtextBg")
    local leftLabel = self:getUI('leftDown.Label_45')
    local richText = richtextBg:getChildByName("richText")
    if richText ~= nil then
        richText:removeFromParent()
    end


    local arenaData = self._crossModel:getData()
    local arenaRace = lang("cp_region" .. self._arenaId)
    local extra = arenaData["extra" .. self._arenaType] or {}
    if table.nums(extra) > 0 then
        arenaRace = arenaRace .. "、"
    end
    for k,v in ipairs(extra) do
        if k == table.nums(extra) then
            arenaRace = arenaRace .. lang("cp_region" .. v)
        else
            arenaRace = arenaRace .. lang("cp_region" .. v) .. "、"
        end
    end
    local desc = lang("cp_tips_arenaui")
    if string.find(desc, "color=") == nil then
        desc = "[color=462800]"..desc.."[-]"
    end
    desc = string.gsub(desc, "{$openregion}", arenaRace)

    leftLabel:setString(arenaRace)
    richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(richText:getContentSize().width / 2, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5 - 8)
    richText:setName("richText")
    richtextBg:addChild(richText)
    local leftDown = self:getUI('leftDown')
    leftDown:setContentSize(leftLabel:getContentSize().width + 180, leftDown:getContentSize().height)

    --centerDown
    local centerDown = self:getUI('centerDown')
    if self._isSeasonSpot then
        centerDown:setVisible(true)
        local centerDown_label = self:getUI('centerDown.Label_45')
        centerDown_label:setColor(cc.c4b(250, 146, 26, 255))
        centerDown_label:setFontSize(20)
        centerDown_label:setString(lang("CP_SEASONSPOT" .. self._crossModel:getSeasonSpot()))
        local cdlWidth = centerDown_label:getContentSize().width
        centerDown:setContentSize(cdlWidth + 40, centerDown:getContentSize().height)

        local centerDown_icon = self:getUI('centerDown.Image_94')
        centerDown_icon:loadTexture('cross_season_' .. self._crossModel:getSeasonSpot() .. '.png', 1)
    else
        centerDown:setVisible(false)
    end
end

function CrossPKView:getChallengeInfo()
    local soloData = self._crossModel:getSoloArenaData(self._arenaType)
    if soloData == false then
        self:tabButtonClick(self:getUI("leftLayer.tab1"), 1)
        self._viewMgr:showTip(lang("cp_tips_limitbattle"))
        return
    else
        local tstate = self._crossModel:getSoloEnemyData()
        if tstate ~= 1 then
            self:tabButtonClick(self:getUI("leftLayer.tab1"), 1)
            self._viewMgr:showTip(lang("cp_tips_limitopen"))
            return 
        end
        if soloData then
            self:updateSoloArena(soloData)
        else
            local param = {region = self._arenaType}
            self._serverMgr:sendMsg("CrossPKServer", "getChallengeInfo", param, true, {}, function (result)
                -- self:test()
                local soloData = self._crossModel:getSoloArenaData(self._arenaType)
                dump(soloData, "result==========", 5)
                if soloData == false then
                    self:tabButtonClick(self:getUI("leftLayer.tab1"), 1)
                    self._viewMgr:showTip(lang("cp_tips_limitbattle"))
                    return
                end
                self:updateSoloArena(soloData)
            end)
        end
    end
end


function CrossPKView:updateSoloArena(soloData)
    local heroBg = self:getUI("leftLayer.soloLayer.heroBg")
    heroBg:setVisible(true)
    local pname = self:getUI("leftLayer.soloLayer.heroBg.pname")
    local pserverName = self:getUI("leftLayer.soloLayer.heroBg.pserverName")

    local arenaNameLab = self:getUI("leftLayer.soloLayer.arenaBg.arenaName")
    -- local lab = self:getUI("leftLayer.soloLayer.heroBg.lab")

    dump(soloData, "CpRegionSwitch==========", 2)
    local nameStr = soloData.name
    local secServer = soloData.sec
    local serverName = self._crossModel:getServerName(secServer)
    local cpTab = tab:CpRegionSwitch(self._arenaId)
    local arenaName = lang(cpTab.winName)
    if secServer == "npcsec" then
        nameStr = lang(cpTab.npcName)
        serverName = lang(cpTab.npcRegion)
    end
    pname:setString(nameStr)
    pserverName:setString(serverName)
    arenaNameLab:setString(arenaName)

    if heroBg.heroArt then
        heroBg.heroArt:removeFromParent()
    end
    local heroD = tab:Hero(soloData.heroId)
    local heroArt = heroD["heroart"]
    local skin = soloData.heroSkin
    if skin and skin ~= 0  then
        local heroSkinD = tab.heroSkin[skin]
        heroArt = heroSkinD["heroart"] or heroD["heroart"]
    end
    heroBg.heroArt = mcMgr:createViewMC("stop_" .. heroArt, true, false)
    heroBg.heroArt:setPosition(80, 68)
    heroBg.heroArt:setScale(0.7)
    heroBg.heroArt:setName("heroArt")
    heroBg:addChild(heroBg.heroArt, 10)

    local zhandouliLab = heroBg.zhandouliLab
    local heroFight = soloData.formation.score
    if not zhandouliLab then
        zhandouliLab = cc.LabelBMFont:create("", UIUtils.bmfName_zhandouli_little)
        zhandouliLab:setName("zhandouli")
        zhandouliLab:setScale(0.5)
        zhandouliLab:setAnchorPoint(0,0.5)
        zhandouliLab:setPosition(210, 71)
        heroBg:addChild(zhandouliLab, 1)
        heroBg.zhandouliLab = zhandouliLab
    end
    zhandouliLab:setString("a" .. heroFight)

    local cdiff = self._crossModel:getCdiff()
    local diffNum = cdiff[self._arenaType]

    local cpLimitBattleTab = tab.cpLimitBattle
    for i=1,5 do
        local soloTab = cpLimitBattleTab[i]
        local diff = self:getUI("leftLayer.soloLayer.diff" .. i)
        local lab = self:getUI("leftLayer.soloLayer.diff" .. i .. ".lab")
        local selectImg = self:getUI("leftLayer.soloLayer.diff" .. i .. ".selectImg")

        -- local labStr = soloTab.difficulty * 100
        -- lab:setString(labStr .. "%")
        lab:setString(lang(soloTab.difficultyTxt))

        selectImg:setVisible(false)

        print("i > diffNum==========", i, diffNum)
        if i > diffNum then
            diff:setSaturation(0)
            if not self._soloSelect then
                self._soloSelect = i
            end
            self:registerClickEvent(diff, function()
                self:selectDifficulty(i)
                self:updateAward() 
            end)
        else
            diff:setSaturation(-100)
            self:registerClickEvent(diff, function()
                -- self:selectDifficulty(i)
                self._viewMgr:showTip(lang("cp_tips_choosebattle"))
            end)
        end
        if self._soloSelect == i then
            selectImg:setVisible(true)
        end
    end

    if self._soloSelect and self._soloSelect ~= 6 then
        local awardBg1 = self:getUI("leftLayer.soloLayer.awardBg1")
        awardBg1:setVisible(false)
        local awardBg = self:getUI("leftLayer.soloLayer.awardBg")
        awardBg:setVisible(true)
        local soloBtn = self:getUI("leftLayer.soloLayer.awardBg.soloBtn")
        self:registerClickEvent(soloBtn, function()
            self:soloRob()
        end)
    else
        self._soloSelect = 6
        local awardBg = self:getUI("leftLayer.soloLayer.awardBg")
        awardBg:setVisible(false)
        local awardBg1 = self:getUI("leftLayer.soloLayer.awardBg1")
        awardBg1:setVisible(true)
    end
    self:updateAward() 
end


function CrossPKView:updateAward() 
    local cdiff = self._crossModel:getCdiff()
    local diffNum = cdiff[self._arenaType]
    local awardKey, awardValue = self:getSoloAwardNum(0, diffNum, self._arenaType)
    local num = table.nums(awardKey)
    for i=1,3 do
        local awardNum = self:getUI("leftLayer.soloLayer.awardBg.awardNum" .. i)
        local itemImg = self:getUI("leftLayer.soloLayer.awardBg.itemImg" .. i)
        local itemId = awardKey[i]
        local toolD = tab:Tool(itemId)
        if i <= num then 
            awardNum:setVisible(true)
            itemImg:setVisible(true)
            local fileName = toolD.art .. ".png"
            if awardImg[itemId] then
                fileName = awardImg[itemId]
            end
            itemImg:loadTexture(fileName, 1)
            awardNum:setString(awardValue[itemId] or 0)
        else
            awardNum:setVisible(false)
            itemImg:setVisible(false)
        end
    end

    local awardKey, awardValue = self:getSoloAwardNum(diffNum+1, self._soloSelect, self._arenaType)
    local num = table.nums(awardKey)
    for i=1,3 do
        local tawardNum = self:getUI("leftLayer.soloLayer.awardBg.tawardNum" .. i)
        local tItemImg = self:getUI("leftLayer.soloLayer.awardBg.tItemImg" .. i)
        local itemId = awardKey[i]
        local toolD = tab:Tool(itemId)
        if i <= num then 
            tawardNum:setVisible(true)
            tItemImg:setVisible(true)
            local fileName = toolD.art .. ".png"
            if awardImg[itemId] then
                fileName = awardImg[itemId]
            end
            print("awardImg[itemId]===========", fileName, itemId)
            tItemImg:loadTexture(fileName, 1)
            tawardNum:setString(awardValue[itemId] or 0)
            fileName = nil
        else
            tawardNum:setVisible(false)
            tItemImg:setVisible(false)
        end
    end

    local awardKey, awardValue = self:getSoloAwardNum(0, 5, self._arenaType)
    local num = table.nums(awardKey)
    for i=1,3 do
        local awardNum = self:getUI("leftLayer.soloLayer.awardBg1.awardNum" .. i)
        local itemImg = self:getUI("leftLayer.soloLayer.awardBg1.itemImg" .. i)
        local itemId = awardKey[i]
        local toolD = tab:Tool(itemId)
        if i <= num then 
            awardNum:setVisible(true)
            itemImg:setVisible(true)
            local fileName = toolD.art .. ".png"
            if awardImg[itemId] then
                fileName = awardImg[itemId]
            end
            itemImg:loadTexture(fileName, 1)
            awardNum:setString(awardValue[itemId] or 0)
        else
            awardNum:setVisible(false)
            itemImg:setVisible(false)
        end
    end
end

function CrossPKView:getSoloAwardNum(begId, endId, arenaType) 
    local awardValue = {}
    local awardKey = {}
    local indexId = 0
    for i=begId, endId do
        local cpAwardTab = tab:CpLimitBattle(i)
        if cpAwardTab then
            local cpAward = cpAwardTab["region" .. arenaType .. "Reward"]
            for k,v in ipairs(cpAward) do
                local itemType = v[1]
                local itemId = v[2]
                if IconUtils.iconIdMap[itemType] then
                    itemId = IconUtils.iconIdMap[itemType]
                end
                local itemNum = v[3]
                if not awardValue[itemId] then
                    awardValue[itemId] = 0
                end
                awardValue[itemId] = awardValue[itemId] + itemNum
            end
        end
    end
    if endId > 5 then
        endId = 5
    end
    if endId < 1 then
        endId = 1
    end
    local cpAwardTab = tab:CpLimitBattle(1)
    local cpAward = cpAwardTab["region" .. arenaType .. "Reward"]
    for i=1,table.nums(cpAward) do
        local itemId = cpAward[i][2]
        local itemType = cpAward[i][1]
        if IconUtils.iconIdMap[itemType] then
            itemId = IconUtils.iconIdMap[itemType]
        end
        awardKey[i] = itemId
    end

    return awardKey, awardValue
end

function CrossPKView:selectDifficulty(selectId)
    local tselectImg = self:getUI("leftLayer.soloLayer.diff" .. self._soloSelect .. ".selectImg")
    tselectImg:setVisible(false)
    self._soloSelect = selectId
    local tselectImg = self:getUI("leftLayer.soloLayer.diff" .. self._soloSelect .. ".selectImg")
    tselectImg:setVisible(true)

    local soloTab = tab:CpLimitBattle(selectId)


end

function CrossPKView:updatePKLayer()
    local allScore1 = self:getUI("leftLayer.pkLayer.serverBg.allScore1")
    local allScore2 = self:getUI("leftLayer.pkLayer.serverBg.allScore2")
    local saddNum1 = self:getUI("leftLayer.pkLayer.serverBg.saddNum1")
    local saddNum2 = self:getUI("leftLayer.pkLayer.serverBg.saddNum2")
    local sName1Lab = self:getUI("leftLayer.pkLayer.serverBg.sName1")
    local sName2Lab = self:getUI("leftLayer.pkLayer.serverBg.sName2")
    local lingxian1 = self:getUI("leftLayer.pkLayer.serverBg.lingxian1")
    local lingxian2 = self:getUI("leftLayer.pkLayer.serverBg.lingxian2")

    local scoreLab = self:getUI("leftLayer.pkLayer.scoreBg.score")
    local addNum = self:getUI("leftLayer.pkLayer.scoreBg.addNum")
    local tishiLab = self:getUI("leftLayer.pkLayer.scoreBg.Label_31")
    local img_double = self:getUI("leftLayer.pkLayer.scoreBg.img_double")
    local addLabel = self:getUI("leftLayer.pkLayer.scoreBg.lab5")
    tishiLab:setString("(每日9~22点)")
    if self._isSeasonSpot and self._crossModel:getSeasonSpot() == 4 then
        img_double:setVisible(true)
        addNum:setColor(cc.c3b(240, 240, 0))
    else
        img_double:setVisible(false)
        addNum:setColor(cc.c3b(255, 255, 255))
    end
    -- tishiLab:setString(lang("cp_arenatips"))

    local addChangeBtn = self:getUI("rightDown.addChangeBtn")
    local myRank = self:getUI("leftLayer.pkLayer.myRank")
    local soloNum = self:getUI("rightDown.soloNum")

    local arenaData = self._crossModel:getData()
    local setStr1 = arenaData["sec1"]
    local setStr2 = arenaData["sec2"]
    local sName1 = self._crossModel:getServerName(setStr1)
    local sName2 = self._crossModel:getServerName(setStr2)
    sName1Lab:setString(sName1)
    sName2Lab:setString(sName2)

    local sec1score = arenaData["sec1region" .. self._arenaType .. "score"] or 0
    local sec2score = arenaData["sec2region" .. self._arenaType .. "score"] or 0
    allScore1:setString(sec1score)
    allScore2:setString(sec2score)

    lingxian1:setVisible(false)
    lingxian2:setVisible(false)
    if sec1score > sec2score then
        lingxian1:setVisible(true)
    elseif sec1score < sec2score then
        lingxian2:setVisible(true)
    end

    local sec1Add = arenaData["sec1region" .. self._arenaType .. "add"] or 0
    local sec2Add = arenaData["sec2region" .. self._arenaType .. "add"] or 0
    local str1 = "（增长: " .. sec1Add .. "/小时）"
    saddNum1:setString(str1)
    local str1 = "（增长: " .. sec2Add .. "/小时）"
    saddNum2:setString(str1)

    local myData = self._crossModel:getMyInfo()
    local playRankStr = myData["rank" .. self._arenaType]
    local playScoreStr = myData["score" .. self._arenaType]
    myRank:setString(playRankStr)
    scoreLab:setString(playScoreStr)

    local tRank = playRankStr
    local hourScore = 0
    local cpServerScoreTab = tab.cpServerScore
    for i,v in ipairs(cpServerScoreTab) do
        local rankTab = v.rank
        if tRank >= rankTab[1] and tRank <= rankTab[2] then
            hourScore = v.score
        end
    end
    addNum:setString(hourScore)
    addLabel:setPositionX(addNum:getPositionX() - addNum:getContentSize().width - 3)

    local freeTimes = tab:Setting("CROSSPK_FIGHTCOUNT_FREE").value
    local dayinfo = self._modelMgr:getModel("PlayerTodayModel"):getData()
    local day76 = dayinfo["day76"] or 0
    local day77 = dayinfo["day77"] or 0
    local haveTimes = freeTimes - day76 + day77
    local soloNum0 = self:getUI("rightDown.soloNum_0")
    soloNum0:setString("/" .. freeTimes)

    if haveTimes == 0 then
        soloNum:setString(haveTimes)
        soloNum:setColor(UIUtils.colorTable.ccColorQuality6)
        addChangeBtn:setVisible(true)
    else
        addChangeBtn:setVisible(false)
        soloNum:setColor(UIUtils.colorTable.ccColorQuality2)
        soloNum:setString(haveTimes)
    end

    self:registerClickEvent(addChangeBtn, function()
        local dayinfo = self._modelMgr:getModel("PlayerTodayModel"):getData()
        local day76 = dayinfo["day76"] or 0
        local day77 = dayinfo["day77"] or 0
        local viplvl = self._modelMgr:getModel("VipModel"):getData().level
        local buyCrossPk = tab:Vip(viplvl).buyCrossPk
        if day77 < buyCrossPk then
            local userData = self._userModel:getData()
            local gemNum = userData.gem
            local nums = day77 + 1
            local costGem = tab:ReflashCost(nums).costCrossPk
            if gemNum < costGem then
                print("钻石不足")
                DialogUtils.showNeedCharge({callback1=function( )
                    local viewMgr = ViewManager:getInstance()
                    viewMgr:showView("vip.VipView", {viewType = 0})
                end})
            else
                print("购买挑战次数")
                local nextCost = costGem -- math.ceil(tab:ReflashCost(costIdx).costArena*self:getActivityDiscount())
                local canBuyNum = buyCrossPk - day77 
                local canBuyDes = lang("TIPS_ARENA_12")
                canBuyDes = string.gsub(canBuyDes,"{$resetlim}",canBuyNum)
                DialogUtils.showBuyDialog({costNum = nextCost,goods = "购买一次挑战次数(" .. canBuyDes .. ")",callback1 = function( )
                    self:buyCrossPKTimes()
                end})
            end
        else
            -- self._viewMgr:showTip("购买挑战次数达到上限")
            self._viewMgr:showDialog("global.GlobalResTipDialog",{},true)
        end
    end)
end


function CrossPKView:buyCrossPKTimes(callback)
    self._serverMgr:sendMsg("CrossPKServer", "buyCrossPKTimes", {}, true, {}, function(result)
        dump(result, "result==========", 10)
        self:updatePKLayer()
        if callback then
            callback()
        end
        -- UIUtils:reloadLuaFile("cross.CrossPKView")
        -- self._viewMgr:showView("cross.CrossPKView", {arenaId = region})
    end)
end


function CrossPKView:refreshCrossPK()
    local param = {region = self._arenaType}
    self._serverMgr:sendMsg("CrossPKServer", "refreshCrossPK", param, true, {}, function (result)
        self:updatePlayer()
        dump(result, "result==========", 10)
        -- UIUtils:reloadLuaFile("cross.CrossPKView")
        -- self._viewMgr:showView("cross.CrossPKView", {arenaId = region})
    end)
end

function CrossPKView:updatePlayer()
    local offset = self._tableView:getContentOffset()
    self._enemyData = self._crossModel:getEnemyData()
    self._tableView:reloadData()
    self._tableView:setContentOffset(offset, false)
end

function CrossPKView:reflashUI()
    print("CrossPKView:reflashUI====================")
    self._enemyData = self._crossModel:getEnemyData()
    -- dump(self._enemyData)
    self._tableView:reloadData()
    self:scrollToNext(selectedIndex)
end

function CrossPKView:initBtn()
    local rankBtn = self:getUI("leftLayer.pkLayer.rankBtn")
    local buzhenBtn = self:getUI("leftLayer.pkLayer.buzhenBtn")
    local scoreBtn = self:getUI("leftLayer.pkLayer.scoreBtn")
    local reportBtn = self:getUI("leftLayer.pkLayer.reportBtn")
    UIUtils:addFuncBtnName(rankBtn, "排行", cc.p(rankBtn:getContentSize().width*0.5,4))
    UIUtils:addFuncBtnName(buzhenBtn, "防守", cc.p(rankBtn:getContentSize().width*0.5,4))
    UIUtils:addFuncBtnName(scoreBtn, "数据", cc.p(rankBtn:getContentSize().width*0.5,4))
    UIUtils:addFuncBtnName(reportBtn, "战报", cc.p(rankBtn:getContentSize().width*0.5,4))

    self:registerClickEvent(rankBtn, function()
        print("self._arenaId============", self._arenaId)
        self:getRankList()
        -- local enemyData = self._crossModel:getDefReport()
        -- dump(enemyData)
        -- UIUtils:reloadLuaFile("cross.CrossDefDialog")
        -- self._viewMgr:showDialog("cross.CrossDefDialog", {arenaType = self._arenaType})
    end)

    self:registerClickEvent(buzhenBtn, function()
        local crossData = self._crossModel:getData()
        self._viewMgr:showView("formation.NewFormationView", {
            formationType = self._modelMgr:getModel("FormationModel")["kFormationTypeCrossPKDef" .. self._arenaType],
            extend = {
                allowLoadIds = self._lineUp,
                crosspkLimitInfo = crossData,
                isShowWeapon = self._isWeaponSpot
            },
        })
    end)

    self:registerClickEvent(scoreBtn, function()
        -- UIUtils:reloadLuaFile("cross.CrossIntegralDialog")
        -- self._viewMgr:showDialog("cross.CrossIntegralDialog")
        local param = {region = self._arenaType}
        self._serverMgr:sendMsg("CrossPKServer", "getNowFT", param, true, {}, function(result) 
            dump(result, "resu===========", 5)
            local callback = function()
                self._crossBar = false
            end
            self._crossBar = true
            UIUtils:reloadLuaFile("cross.CrossIntegralDialog")
            self._viewMgr:showDialog("cross.CrossIntegralDialog", {crossPK = result["d"]["crossPK"], arenaType = self._arenaType, callback = callback})
        end)
    end)

    self:registerClickEvent(reportBtn, function()
        local param = {region = self._arenaType}
        self._serverMgr:sendMsg("CrossPKServer", "getReports", param, true, {}, function(result) 
            dump(result, "resu===========", 5)
            UIUtils:reloadLuaFile("cross.CrossReportDialog")
            self._viewMgr:showDialog("cross.CrossReportDialog", {crossPK = result["d"]["crossPK"], arenaType = self._arenaType})
        end)
    end)
end

--[[
用tableview实现
--]]
function CrossPKView:addTableView()
    self._up = self:getUI("rightLayer.right")
    local mc1 = mcMgr:createViewMC("tujianyoujiantou_teamnatureanim", true, false)
    mc1:setPosition(cc.p(self._up:getContentSize().width*0.5-30, self._up:getContentSize().height*0.5-20))
    self._up:addChild(mc1)

    self._down = self:getUI("rightLayer.left")
    local mc2 = mcMgr:createViewMC("tujianzuojiantou_teamnatureanim", true, false)
    mc2:setPosition(cc.p(self._down:getContentSize().width*0.5-20, self._down:getContentSize().height*0.5-20))
    self._down:addChild(mc2)

    local tableViewBg = self:getUI("rightLayer")
    print("MAX_SCREEN_HEIGHT=============", MAX_SCREEN_HEIGHT)
    self._tableView = cc.TableView:create(cc.size(1136, 720))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end, cc.SCROLLVIEW_SCRIPT_SCROLL)
    
    self._tableView:setBounceable(false)
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    tableViewBg:addChild(self._tableView, 1)
end


-- 判断是否滑动到结束
function CrossPKView:scrollViewDidScroll(view)
    self._inScrolling = view:isDragging()
    local tempPos = view:getContentSize().height + view:getContainer():getPositionY()
    -- print("==============",tempPos, view:getContainer():getPositionY(), view:getContentSize().height)
    -- down left
    -- up   right
    if view:getContainer():getPositionY() == 0 then
        if view:getContentSize().height < 960 then
            self._up:setVisible(false)
            self._down:setVisible(false)
        else
            self._up:setVisible(true)
            self._down:setVisible(false)
        end
    elseif tempPos <= 640 then
        if view:getContentSize().height < 960 then
            self._up:setVisible(false)
            self._down:setVisible(false)
        else
            self._up:setVisible(false)
            self._down:setVisible(true)
        end
    elseif tempPos == 720 then
        if view:getContentSize().height < 960 then
            self._up:setVisible(false)
            self._down:setVisible(false)
        else
            self._up:setVisible(false)
            self._down:setVisible(true)
        end
    elseif view:getContentSize().height > 960 then
        self._up:setVisible(true)
        self._down:setVisible(true)
    end
end


-- 触摸时调用
function CrossPKView:tableCellTouched(table,cell)
end

-- cell的尺寸大小
function CrossPKView:cellSizeForTable(table,idx) 
    local width = 778 
    local height = 640
    if idx == 0 then
        height = 640 + 80
    end
    return height, width
end

-- 创建在某个位置的cell
function CrossPKView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local param = self._tableData[idx+1]
    local indexId = idx + 1 -- idx+1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local bgcell = self._bgcell:clone() 
        bgcell:setVisible(true)
        bgcell:setAnchorPoint(0,0)
        bgcell:setPosition(0,0)
        bgcell:setName("bgcell")
        cell:addChild(bgcell)
        cell.bgcell = bgcell


        for i=1,3 do
            local arena = bgcell:getChildByFullName("arena" .. i)
            self:initEnemyData(arena)
        end
        -- serverScore:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        -- UIUtils:setButtonFormat(inView, _type)

        self:updateCell(bgcell, param, indexId)
        bgcell:setSwallowTouches(false)
    else
        local bgcell = cell.bgcell
        -- local bgcell = cell:getChildByName("bgcell")
        if bgcell then
            self:updateCell(bgcell, param, indexId)
            bgcell:setSwallowTouches(false)
        end
    end

    return cell
end

-- 返回cell的数量
function CrossPKView:numberOfCellsInTableView(table)
    local enemyNum = #self._enemyData
    local tnum = math.floor(enemyNum/3) + 1
    return 5 -- tnum
end

function CrossPKView:updateCell(bgcell, param, indexId)
	--[[local hasScene = {
		[1] = true,
		[2] = true,
		[3] = true,
		[4] = true,
		[5] = true,
		[6] = true,
	}--]]
	local sceneAnim1 = {
		[2] = "kuafuchangjing2_kuafujingji2",
		[5] = "kuafuchanjing6_kuafujingji5",
        [8] = "kuafujingjichang9_kuafujingji9"
	}
	local sceneAnim2 = {
		[2] = "kuafuchangjing3_kuafujingji2",
		[5] = "kuafuchanjing7_kuafujingji5",
        [8] = "kuafujingjichang8_kuafujingji9"
	}
    local bg = bgcell:getChildByFullName("bg")
    if bg then
        bg:setAnchorPoint(0, 0)
        bg:setPosition(0, 0)
        local raceId = self._arenaId
		--[[if not hasScene[raceId] then
			raceId = l_tempId
		end--]]
		if bg:getChildByName("mc") then
			bg:removeChild(bg:getChildByName("mc"))
		end
        if indexId == 1 then
            bg:loadTexture("asset/uiother/crossMap/crossbg_race_" .. raceId .. "1.jpg", 0)
			if sceneAnim1[raceId] then
				local mc = mcMgr:createViewMC(sceneAnim1[raceId], true, false)
				mc:setPosition(bg:getContentSize().width*0.5, bg:getContentSize().height*0.5)
				mc:setName("mc")
				bg:addChild(mc, 10)
			end
        else
            bg:loadTexture("asset/uiother/crossMap/crossbg_race_" .. raceId .. "2.jpg", 0)
			if sceneAnim2[raceId] then
				local mc = mcMgr:createViewMC(sceneAnim2[raceId], true, false)
				mc:setPosition(bg:getContentSize().width*0.5, bg:getContentSize().height*0.5)
				mc:setName("mc")
				bg:addChild(mc, 10)
			end
            -- bg:loadTexture("asset/bg/crossbg2.jpg", 0)
        end
        bg:setScale(1136/1022)
    end

    for i=1,3 do
        local arena = bgcell:getChildByFullName("arena" .. i)
        local tindex = (indexId-1)*3+i
        self:updateEnemyData(arena, tindex)
    end

end


function CrossPKView:initEnemyData(inView)
    local pname = inView:getChildByFullName("pname")
    if pname then
        pname:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end

    local rank = inView:getChildByFullName("rank")
    if rank then
        rank:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end

    local fight = inView:getChildByFullName("fight")
    if fight then
        fight:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        fight:setVisible(false)
        local zhandouliLab = cc.LabelBMFont:create("", UIUtils.bmfName_zhandouli_little)
        zhandouliLab:setName("zhandouli")
        zhandouliLab:setAnchorPoint(1,0.5)
        zhandouliLab:setScale(0.4)
        zhandouliLab:setPosition(fight:getPositionX(), fight:getPositionY())
        inView:addChild(zhandouliLab, 1)
        inView.zhandouliLab = zhandouliLab
    end

    local lab1 = inView:getChildByFullName("lab1")
    if lab1 then
        lab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end

    local lab2 = inView:getChildByFullName("lab2")
    if lab2 then
        lab2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end
end

function CrossPKView:updateEnemyData(inView, indexId)
    local enemyData = self._enemyData[indexId]
    inView:setVisible(true)
    if not enemyData then
        inView:setVisible(false)
        return
    end

    local npcRob = false
    local playName = lang("cp_npcName" .. self._arenaId)
    local secServer = enemyData.sec
    if secServer == "npcsec" then
        npcRob = true
    end
    local qizi = inView:getChildByFullName("qizi")
    if qizi then
        -- print("secServer================", indexId, secServer)
        local _, serverFlag = self._crossModel:getServerName(secServer)
        -- local serverFlag = self._crossModel:getMyServer(secServer)
        if npcRob == true then
            qizi:loadTexture("crossUI_img31.png", 1)
        elseif serverFlag == 1 then
            qizi:loadTexture("crossUI_img23.png", 1)
        elseif serverFlag == 2 then
            qizi:loadTexture("crossUI_img19.png", 1)
        end
    end

    local pname = inView:getChildByFullName("pname")
    if pname then
        if npcRob == true then
            pname:setString(playName)
        else
            pname:setString(enemyData.name)
        end
    end

    local playRank = enemyData.rank
    local rank = inView:getChildByFullName("rank")
    if rank then
        rank:setString(enemyData.rank)
    end
    local dizuo = inView:getChildByFullName("dizuo")
    if dizuo then
        if playRank == 1 then
            dizuo:loadTexture("arenaMain_heroBg1.png", 1)
        elseif playRank == 2 then
            dizuo:loadTexture("arenaMain_heroBg2.png", 1)
        elseif playRank == 3 then
            dizuo:loadTexture("arenaMain_heroBg3.png", 1)
        else
            dizuo:loadTexture("arenaMain_heroBg4.png", 1)
        end
    end

    qizi:stopAllActions()
    local callFunc = cc.CallFunc:create(function()
        if inView.heroArt and not tolua.isnull(inView.heroArt) then
            inView.heroArt:removeFromParent()
        end
        local heroD = tab:Hero(enemyData.heroId)
        local heroArt = heroD["heroart"]
        local skin = enemyData.heroSkin
        if skin and skin ~= 0  then
            local heroSkinD = tab.heroSkin[skin]
            heroArt = heroSkinD["heroart"] or heroD["heroart"]
        end
        inView.heroArt = mcMgr:createViewMC("stop_" .. heroArt, true, false)
        inView.heroArt:setPosition(90, 50)
        inView.heroArt:setScale(0.6)
        inView.heroArt:setName("heroArt")
        inView:addChild(inView.heroArt, 10)
    end)
    local seq = cc.Sequence:create(cc.DelayTime:create(0.01*indexId), callFunc)
    qizi:runAction(seq)

    if self._changeClick == false then
        local renAnim = mcMgr:createViewMC("shangdianshuaxin_arenarefreshanim", false, true)
        renAnim:setPosition(90, 50)
        inView:addChild(renAnim, 20)    
    end
        
    local fight = inView.zhandouliLab
    if fight then
        fight:setString(enemyData.fScore)
    end
    local myself = inView:getChildByFullName("myself")
    if myself then
        myself:setVisible(false)
    end

    local clickFlag = false
    local downY
    local posX, posY
    registerTouchEvent(
        inView,
        function (_, _, y)
            downY = y
            clickFlag = false
        end, 
        function (_, _, y)
            if downY and math.abs(downY - y) > 5 then
                clickFlag = true
            end
        end, 
        function ()
            if clickFlag == false then 
                -- dump(enemyData)
                local param = {region = self._arenaType, aimSec = enemyData.sec, aimId = enemyData.rid, rank = enemyData.rank}
                self:getDetailInfo(param, enemyData)
            end
        end,
        function ()
        end)
    inView:setSwallowTouches(false)

    local solo = inView:getChildByFullName("solo")
    local chakanBtn = inView:getChildByFullName("chakanBtn")
    local state = enemyData.state
    self:registerClickEvent(solo, function()
        local freeTimes = tab:Setting("CROSSPK_FIGHTCOUNT_FREE").value
        local dayinfo = self._modelMgr:getModel("PlayerTodayModel"):getData()
        local day76 = dayinfo["day76"] or 0
        local day77 = dayinfo["day77"] or 0
        local haveTimes = freeTimes - day76 + day77

        local fightCallback = function()
            local callback = function()
                local param = {region = self._arenaType, aimSec = enemyData.sec, aimId = enemyData.rid, rank = enemyData.rank}
                self:soloEnemy(param, enemyData)            
            end
        
            local flag = self._crossModel:isMyServer(enemyData.sec)
            -- local serverId, fserverId = self._crossModel:getServerId()
            -- local serverName, serverType = self._crossModel:getServerName(enemyData.sec)
            -- local userSec = self._crossModel:getServerId()
            if flag == true then
                self._viewMgr:showDialog("global.GlobalSelectDialog", {desc = lang("cp_tips_battle"), button1 = "", callback1 = callback, 
                    button2 = "", callback2 = nil,titileTip="温馨提示", title = "温馨提示"},true)
            else
                callback()
            end
        end
        if haveTimes == 0 then
            local viplvl = self._modelMgr:getModel("VipModel"):getData().level
            local buyCrossPk = tab:Vip(viplvl).buyCrossPk
            if day77 < buyCrossPk then
                local userData = self._userModel:getData()
                local gemNum = userData.gem
                local nums = day77 + 1
                local costGem = tab:ReflashCost(nums).costCrossPk
                if gemNum < costGem then
                    print("钻石不足")
                    DialogUtils.showNeedCharge({callback1=function( )
                        local viewMgr = ViewManager:getInstance()
                        viewMgr:showView("vip.VipView", {viewType = 0})
                    end})
                else
                    local nextCost = costGem 
                    local canBuyNum = buyCrossPk - day77 
                    local canBuyDes = lang("TIPS_ARENA_12")
                    canBuyDes = string.gsub(canBuyDes,"{$resetlim}",canBuyNum)
                    self._viewMgr:showDialog("arena.ArenaDialogBuyCounts",{desc = "[color=462800,fontsize=24]是否花费[pic=globalImageUI_littleDiamond.png][-][color=462800,fontsize=24]"..nextCost.."[-][-][color=462800,fontsize=24]购买一次挑战次数(".. canBuyDes ..")并进入战斗[-]",
                        callBack1 = function()
                            self:buyCrossPKTimes(fightCallback)
                        end                 
                    })
                end
            else
                -- self._viewMgr:showTip("购买挑战次数达到上限")
                self._viewMgr:showDialog("global.GlobalResTipDialog",{},true)
            end
            return
        end

        -- local param = {region = self._arenaType, aimSec = enemyData.sec, aimId = enemyData.rid, rank = enemyData.rank}
        -- dump(param)
        -- self:soloEnemy(param, enemyData)
        fightCallback()
        print("solo==========", tindex)
    end)
    self:registerClickEvent(chakanBtn, function()
        local param = {region = self._arenaType, aimSec = enemyData.sec, aimId = enemyData.rid, rank = enemyData.rank}
        self:getDetailInfo(param, enemyData)
        dump(enemyData)
        print("solo==========", tindex)
    end)

    local solo1 = inView:getChildByFullName("solo1")
    local sweepBtn = inView:getChildByFullName("sweepBtn")
    self:registerClickEvent(solo1, function()
        local freeTimes = tab:Setting("CROSSPK_FIGHTCOUNT_FREE").value
        local dayinfo = self._modelMgr:getModel("PlayerTodayModel"):getData()
        local day76 = dayinfo["day76"] or 0
        local day77 = dayinfo["day77"] or 0
        local haveTimes = freeTimes - day76 + day77

        local fightCallback = function()
            local callback = function()
                local param = {region = self._arenaType, aimSec = enemyData.sec, aimId = enemyData.rid, rank = enemyData.rank}
                self:soloEnemy(param, enemyData)            
            end
        
            local flag = self._crossModel:isMyServer(enemyData.sec)
            -- local serverId, fserverId = self._crossModel:getServerId()
            -- local serverName, serverType = self._crossModel:getServerName(enemyData.sec)
            -- local userSec = self._crossModel:getServerId()
            if flag == true then
                self._viewMgr:showDialog("global.GlobalSelectDialog", {desc = lang("cp_tips_battle"), button1 = "", callback1 = callback, 
                    button2 = "", callback2 = nil,titileTip="温馨提示", title = "温馨提示"},true)
            else
                callback()
            end
        end
        if haveTimes == 0 then
            local viplvl = self._modelMgr:getModel("VipModel"):getData().level
            local buyCrossPk = tab:Vip(viplvl).buyCrossPk
            if day77 < buyCrossPk then
                local userData = self._userModel:getData()
                local gemNum = userData.gem
                local nums = day77 + 1
                local costGem = tab:ReflashCost(nums).costCrossPk
                if gemNum < costGem then
                    print("钻石不足")
                    DialogUtils.showNeedCharge({callback1=function( )
                        local viewMgr = ViewManager:getInstance()
                        viewMgr:showView("vip.VipView", {viewType = 0})
                    end})
                else
                    local nextCost = costGem 
                    local canBuyNum = buyCrossPk - day77 
                    local canBuyDes = lang("TIPS_ARENA_12")
                    canBuyDes = string.gsub(canBuyDes,"{$resetlim}",canBuyNum)
                    self._viewMgr:showDialog("arena.ArenaDialogBuyCounts",{desc = "[color=462800,fontsize=24]是否花费[pic=globalImageUI_littleDiamond.png][-][color=462800,fontsize=24]"..nextCost.."[-][-][color=462800,fontsize=24]购买一次挑战次数(".. canBuyDes ..")并进入战斗[-]",
                        callBack1 = function()
                            self:buyCrossPKTimes(fightCallback)
                        end                 
                    })
                end
            else
                -- self._viewMgr:showTip("购买挑战次数达到上限")
                self._viewMgr:showDialog("global.GlobalResTipDialog",{},true)
            end
            return
        end

        fightCallback()
    end)
    self:registerClickEvent(sweepBtn, function()
        local freeTimes = tab:Setting("CROSSPK_FIGHTCOUNT_FREE").value
        local dayinfo = self._modelMgr:getModel("PlayerTodayModel"):getData()
        local day76 = dayinfo["day76"] or 0
        local day77 = dayinfo["day77"] or 0
        local haveTimes = freeTimes - day76 + day77

        if haveTimes == 0 then
            local viplvl = self._modelMgr:getModel("VipModel"):getData().level
            local buyCrossPk = tab:Vip(viplvl).buyCrossPk
            if day77 < buyCrossPk then
                local userData = self._userModel:getData()
                local gemNum = userData.gem
                local nums = day77 + 1
                local costGem = tab:ReflashCost(nums).costCrossPk
                if gemNum < costGem then
                    print("钻石不足")
                    DialogUtils.showNeedCharge({callback1=function( )
                        local viewMgr = ViewManager:getInstance()
                        viewMgr:showView("vip.VipView", {viewType = 0})
                    end})
                else
                    local nextCost = costGem 
                    local canBuyNum = buyCrossPk - day77 
                    local canBuyDes = lang("TIPS_ARENA_12")
                    canBuyDes = string.gsub(canBuyDes,"{$resetlim}",canBuyNum)
                    self._viewMgr:showDialog("arena.ArenaDialogBuyCounts",{desc = "[color=462800,fontsize=24]是否花费[pic=globalImageUI_littleDiamond.png][-][color=462800,fontsize=24]"..nextCost.."[-][-][color=462800,fontsize=24]购买一次挑战次数(".. canBuyDes ..")并进入战斗[-]",
                        callBack1 = function()
                            self:buyCrossPKTimes(function() self:sweepPK() end)
                        end                 
                    })
                end
            else
                -- self._viewMgr:showTip("购买挑战次数达到上限")
                self._viewMgr:showDialog("global.GlobalResTipDialog",{},true)
            end
            return
        end

        self:sweepPK()
    end)

    if state == 0 then
        local myData = self._crossModel:getMyInfo()
        local playRankStr = myData["rank" .. self._arenaType]
        if playRankStr < enemyData.rank then
            solo:setVisible(false)
            chakanBtn:setVisible(false)
            solo1:setVisible(true)
            sweepBtn:setVisible(true)
        else
            solo:setVisible(true)
            chakanBtn:setVisible(false)
            solo1:setVisible(false)
            sweepBtn:setVisible(false)
        end
    elseif state == 1 then
        solo:setVisible(false)
        chakanBtn:setVisible(true)
        chakanBtn:setTitleText("查看")
        solo1:setVisible(false)
        sweepBtn:setVisible(false)
    else
        solo1:setVisible(false)
        sweepBtn:setVisible(false)
        solo:setVisible(false)
        chakanBtn:setVisible(false)
        if myself then
            myself:setVisible(true)
        end
    end
end

-- 扫荡
function CrossPKView:sweepPK()
    self._serverMgr:sendMsg("CrossPKServer", "sweepPK", {region = self._arenaType}, true, {}, function(result)
        self:updatePKLayer()
--        self:reflashUI()
        DialogUtils.showGiftGet({gifts = result.reward})
    end)  
end

-- 玩家信息展示
function CrossPKView:getDetailInfo(param, enemyData)
    self._serverMgr:sendMsg("CrossPKServer", "getDetailInfo", param, true, {}, function(result) 
        dump(result, "result========", 4)
        local info = result["d"]["crossPK"]["defInfo"]
        info.rank = enemyData.rank
        info.rid = enemyData.rid
        info.isNotShowBtn = true
        if not info.name then
            info.name = lang("cp_npcName" .. self._arenaId)
        end
        self._viewMgr:showDialog("arena.DialogArenaUserInfo",info,true)
    end)
end

function CrossPKView:tabButtonClick(sender, key)
    if sender == nil then 
        return 
    end
    if self._tabName == sender:getName() then 
        return 
    end
    for k,v in pairs(self._tabEventTarget) do
        if v ~= sender then
            self:tabButtonState(v, false, k)
        end
    end
    self:tabButtonState(sender, true, key)
    self:switchPanel(sender, key)
end

-- 选项卡状态切换
function CrossPKView:tabButtonState(sender, isSelected, key)
    local titleNames = {
        " 竞技 ",
        " 试炼 ",
    }
    local shortTitleNames = {
        " 竞技 ",
        " 试炼 ",
    }

    sender:setBright(not isSelected)
    sender:setEnabled(not isSelected)
    sender:getTitleRenderer():disableEffect()
    sender:setTitleFontSize(24)
    if isSelected then
        sender:setTitleText(titleNames[key])
        sender:setTitleColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
    else
        sender:setTitleText(shortTitleNames[key])
        sender:setTitleColor(cc.c3b(147,107,81))
    end
end

function CrossPKView:switchPanel(sender, key)
    if sender:getName() == "tab1" then
        self._tabSelect = 1
        print("self._tabSelect============tab1=", self._tabSelect)

        local soloLayer = self:getUI("leftLayer.soloLayer")
        local pkLayer = self:getUI("leftLayer.pkLayer")
        pkLayer:setVisible(true)
        soloLayer:setVisible(false)
        self:updatePKLayer()
    elseif sender:getName() == "tab2" then 
        self._tabSelect = 2
        print("self._tabSelect============tab2=", self._tabSelect)
        local soloLayer = self:getUI("leftLayer.soloLayer")
        local pkLayer = self:getUI("leftLayer.pkLayer")
        pkLayer:setVisible(false)
        soloLayer:setVisible(true)

        self:getChallengeInfo()
    end
end

function CrossPKView:getAsyncRes()
    return {
        {"asset/ui/cross.plist", "asset/ui/cross.png"},
        {"asset/ui/arena1.plist", "asset/ui/arena1.png"},
    }
end

-- function CrossPKView:setNavigation()
-- -- 字段名cp_nameRegion1
-- -- cp_region1   1-9
--     self._viewMgr:showNavigation("global.UserInfoView",{types = {"CpCoin","Gold","Gem"},title = "globalTitleUI_team.png",titleTxt = str})
--     -- self._viewMgr:showNavigation("global.UserInfoView",{hideHead=true,hideInfo=true,titleTxt = str})
-- end
function CrossPKView:setNavigation()
    local str = lang("cp_nameRegion" .. self._arenaId)
    self._viewMgr:showNavigation("global.UserInfoView",{hideHead=false, hideInfo=true, titleTxt = str},nil,ADOPT_IPHONEX and self.fixMaxWidth or self._crossWidth)
end


-- 战斗相关

-- 开始战斗展示
function CrossPKView:soloEnemy(param, enemyData)
    self._serverMgr:sendMsg("CrossPKServer", "getDetailInfo", param, true, {}, function(result) 
        local info = result["d"]["crossPK"]["defInfo"]
        dump(info, "info========", 2)
        info.name = lang("cp_npcName" .. self._arenaId)
        -- info.rank = enemyData.rank
        if enemyData.rank ~= info.rank then
            self._viewMgr:showTip(lang("cp_tips_choosepk"))
            self:refreshCrossPK()
            return
        end
        info.rid = enemyData.rid
        local crossData = self._crossModel:getData()
        self._modelMgr:getModel("CrossModel"):setEnemyHeroData(info.hero)
        self._modelMgr:getModel("CrossModel"):setEnemyData(info.teams)
        local formationData = self._modelMgr:getModel("FormationModel")
        local formationType = formationData["kFormationTypeCrossPKAtk" .. self._arenaType]
        self._viewMgr:showView("formation.NewFormationView", {
            formationType = formationType,
            enemyFormationData = {[formationType] = clone(info.formation)},
            callback = function(enemyInfo)
                print("开始战斗")
                -- dump(self._award, "_award666==============", 5)
                local flag = self:getSoloTime()
                if flag == false then
                    self._viewMgr:showTip(lang("cp_tips_closebattle"))
                    return
                end
                self:crossPK(param)
            end,
            extend = {
                allowLoadIds = self._lineUp,
                crosspkLimitInfo = crossData,
                isShowWeapon = self._isWeaponSpot
            },
        })
    end) 
end

function CrossPKView:crossPK(param)
    local myData = self._crossModel:getMyInfo()
    self._oldRank = myData["rank" .. self._arenaType]
    self._serverMgr:sendMsg("CrossPKServer", "crossPK", param, true, {}, function(result)
        dump(result, "result===========", 3)
        self._viewMgr:popView()
        self:reviewTheBattle(result, replayType)
    end)  
end


-- 竞技场战斗
function CrossPKView:reviewTheBattle(result, replayType)
    if not result then
        return
    end
    local left = self:initBattleData(result.atk)
    local right = self:initBattleData(result.def)
    local rid = result.def.rid
    local reverse = false
    local userid = self._userModel:getData()._id
    if userid == rid then
        reverse = true
    end

    -- 同步名字
    local r1 = result.r1
    local r2 = result.r2
    local replayType = 0
    local fastRes


    BattleUtils.enterBattleView_ServerArena(left, right, r1, r2, replayType, reverse, 
    function(info, callback)
        print("啦啦啦啦11111111啦")
        local crossInfo   = {}
        local myData = self._crossModel:getMyInfo()
        local playRankStr = myData["rank" .. self._arenaType]
        crossInfo.award   = result.reward
        crossInfo.preRank = self._oldRank or playRankStr
        crossInfo.rank    = playRankStr
        info = info
        info.crossInfo = crossInfo

        callback(info, callback)
    end, function(info)
        self:exitBattle()
    end, fastRes)
end

-- 退出战斗
function CrossPKView:exitBattle(reportData)
    self:updatePKLayer()
    self:reflashUI()

end

function CrossPKView:initBattleData(reportData)
    return BattleUtils.jsonData2lua_battleData(reportData)
end

-- 开始战斗展示
function CrossPKView:soloRob()
    local soloData = self._crossModel:getSoloArenaData(self._arenaType)
    -- dump(soloData)
    local info = soloData
    if info.sec == "npcsec" then
        info.name = lang("cp_npcName" .. self._arenaId)
    end
    info.rank = soloData.rank
    info.rid = soloData.rid
    self._modelMgr:getModel("CrossModel"):setEnemyHeroData(info.hero)
    self._modelMgr:getModel("CrossModel"):setEnemyData(info.teams)
    local formationData = self._modelMgr:getModel("FormationModel")
    local formationType = formationData["kFormationTypeCrossPKFight"]
    self._viewMgr:showView("formation.NewFormationView", {
        formationType = formationType,
        enemyFormationData = {[formationType] = clone(info.formation)},
        callback = function(info)
            print("开始战斗")
            local flag = self:getSoloTime()
            if flag == false then
                self._viewMgr:showTip(lang("cp_tips_closebattle"))
                return
            end
            self:atkBeforeChallenge(param)
        end,
        extend = {
            isShowWeapon = self._isWeaponSpot
        },
    })
end

function CrossPKView:atkBeforeChallenge()
    local param = {region = self._arenaType, diff = self._soloSelect}
    self._serverMgr:sendMsg("CrossPKServer", "atkBeforeChallenge", param, true, {}, function (result)
        -- dump(result, "result==========", 3)
        self._viewMgr:popView()
        self:soloRobFight(result)
    end)
end

function CrossPKView:soloRobFight(result)
    if not result then
        return
    end
    local left = self:initBattleData(result.atk)
    -- local right = self:initBattleData(soloData)
    local right = self:initBattleData(result.def)
    self._token = result.token
    local rid = result.def.rid
    local reverse = false
    local userid = self._userModel:getData()._id
    if userid == rid then
        reverse = true
    end

    -- 同步名字
    local r1 = result.r1
    local r2 = result.r2
    local isReplay = false
    local cpLimitBattleId = self._soloSelect
    local replayType = 0
    local fastRes

    BattleUtils.enterBattleView_ServerArenaFuben(left, right, r1, r2,
    function(info, callback)
        print("啦啦啦啦11111111啦")
        self:crossBattleEnd(info, callback)
    end, function(info)
        self:exitBattle()
    end, fastRes)
end

function CrossPKView:crossBattleEnd(data, inCallBack)
    if data.win then
        self._battleWin = 1
    else
        self._battleWin = 0
    end

    local param = { token = self._token,
                    diff = self._soloSelect,
                    region = self._arenaType,
                    args=json.encode(
                        {win = self._battleWin, 
                        time = data.time,
                        skillList = data.skillList,
                        zzid = 1,
                        serverInfoEx = data.serverInfoEx})
                }

    -- dump(self._award, "robMF=beg66666============", 5)
    self._serverMgr:sendMsg("CrossPKServer", "atkAfterChallenge", param, true, {}, function(result)
        dump(result)
        if self._battleWin == 1 then
            self._soloSelect = nil
        end
        self:getChallengeInfo()
        if inCallBack ~= nil then
            inCallBack(result)
        end
    end)
end


-- 
function CrossPKView:getRankList()
    local region = self._arenaType
    local param = {region = region, start = 1}
    self._serverMgr:sendMsg("CrossPKServer", "getRankList", param, true, {}, function(result) 
        UIUtils:reloadLuaFile("cross.CrossRankDialog")
        self._viewMgr:showDialog("cross.CrossRankDialog", {arenaType = region},true)
    end)
end



function CrossPKView:initPKAnim()
	local sceneAnim = {
		[1] = "kuafuchangjingtexiao_kuafuchangjing",
		[3] = "kuafujingji4_kuafujingji3",
		[4] = "changjingfenwei_crosskuafujingjichang",
		[6] = "xue_kuafujingji6",
        [7] = "kuafujingji7_kuafujingji8",
        [9] = "yu_kuafujingji7",
	}--由于场景特殊性，id:2、5无法做统一特效，所以特效加在分块的不同底图上。见updateCell
	local raceId = self._arenaId
	if sceneAnim[raceId] then
		local scrollView = self:getUI("rightLayer")
		self._mcVs = mcMgr:createViewMC(sceneAnim[raceId], true, false)
		self._mcVs:setPosition(scrollView:getContentSize().width*0.5, scrollView:getContentSize().height*0.5)
		scrollView:addChild(self._mcVs, 10)
	end

    local animBg = self:getUI("leftLayer.pkLayer.serverBg.animBg")
    self._mcVs = mcMgr:createViewMC("buffguangxiaoxia_duizhanui", true, false)
    self._mcVs:setPosition(animBg:getContentSize().width*0.5, 30)
    animBg:addChild(self._mcVs, 10)
end


function CrossPKView.dtor()
    tonumber = nil
    tostring = nil
end

return CrossPKView