--[[
    Filename:    CrossMainView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-11-07 17:15:27
    Description: File description
--]]

local CrossMainView = class("CrossMainView", BaseView)
local CrossUtils = CrossUtils

local tostring = tostring
local tonumber = tonumber

function CrossMainView:ctor()
    CrossMainView.super.ctor(self)
    self._inFirst = true
end

function CrossMainView:onInit()
    self._userModel = self._modelMgr:getModel("UserModel")
    self._crossModel = self._modelMgr:getModel("CrossModel")
    self._crossModel:setJoinMainView(true)

    local mainBtn = self:getUI("quickBg.mainBtn")
    self:registerClickEvent(mainBtn, function()
        UIUtils:reloadLuaFile("cross.CrossMainView")
        self._crossModel:setJoinMainView(false)
        -- self:close()
        local viewMgr = ViewManager:getInstance()
        viewMgr:returnMain()
        -- local viewMgr = ViewManager:getInstance()
        -- viewMgr:returnMain()
    end)

    local detailBtn = self:getUI("rightScoreBg.scorePanel.detailBtn")
    self:registerClickEvent(detailBtn, function()
        UIUtils:reloadLuaFile("cross.CrossDetailDialog")
        self._viewMgr:showDialog("cross.CrossDetailDialog")

        -- local mergeList = self._crossModel:getServerMap()
        -- dump(mergeList)

        -- UIUtils:reloadLuaFile("cross.CrossScoreRuleView")
        -- self._viewMgr:showDialog("cross.CrossScoreRuleView")

        -- UIUtils:reloadLuaFile("cross.CrossDeclareDialog")
        -- self._viewMgr:showDialog("cross.CrossDeclareDialog")

        -- UIUtils:reloadLuaFile("cross.CrossEndDialog")
        -- self._viewMgr:showDialog("cross.CrossEndDialog")

        -- UIUtils:reloadLuaFile("cross.CrossBegDialog")
        -- self._viewMgr:showDialog("cross.CrossBegDialog")

        
        -- local _, state = self._crossModel:getDialogState() 
        -- print("flag============", state)
    end)

    local leftAdvance = self:getUI("leftAdvance.Image_35")
    self:registerClickEvent(leftAdvance, function()
        local str = lang("cp_rule")
        self._viewMgr:showDialog("cross.CrossRuleView", {str = str}, true)
    end)

    local hideRight = self:getUI("rightScoreBg.hideRight")
    self._rightClick = 1
    self:registerClickEvent(hideRight, function()
        local width = self._widget:getContentSize().width
        local rightScoreBg = self:getUI("rightScoreBg")
        rightScoreBg:stopAllActions()
        local height = rightScoreBg:getPositionY()
        if self._rightClick == 1 then
            self._rightClick = 2
            local move = cc.MoveTo:create(0.1, cc.p(width+5, height))
            local ease = cc.EaseOut:create(move, 0.5)
            local seq = cc.Sequence:create(ease)
            rightScoreBg:runAction(seq)
            -- rightScoreBg:setPositionX(width)
            hideRight:setFlippedX(true)
        elseif self._rightClick == 2 then
            self._rightClick = 1
            rightScoreBg:setPositionX(width-200)
            hideRight:setFlippedX(false)
        end
    end)

    self:onMainAnim()

    self._arenaBtn = self:getUI("arenaBtn")
    self:listenReflash("CrossModel", self.reflashUI)
    -- self:listenReflash("CrossModel", self.reflashUI)
	
	self:initHistoryBtn()
end

function CrossMainView:onAnimEnd()
    local callback = function()
        self._crossModel:setCrossMainOpenDialog()
        local flag = self._crossModel:getCrossMainDialog() 
        if flag == true then
            UIUtils:reloadLuaFile("cross.CrossDeclareDialog")
            self._viewMgr:showDialog("cross.CrossDeclareDialog")
        end
    end

    local _, state = self._crossModel:getDialogState() 
    if state == 2 then
        local flag = self._crossModel:getCrossMainOpenDialog()
        if flag == true then
            UIUtils:reloadLuaFile("cross.CrossBegDialog")
            self._viewMgr:showDialog("cross.CrossBegDialog", {callback = callback})
        else
            callback()
        end
    elseif state == 3 then
        local flag = self._crossModel:getCrossMainOpenDialog()
        if flag == true then
            UIUtils:reloadLuaFile("cross.CrossEndDialog")
            self._viewMgr:showDialog("cross.CrossEndDialog", {callback = callback})
        else
            callback()
        end
    else
        callback()
    end
end

function CrossMainView:applicationWillEnterForeground(second)
    if not SystemUtils:enableCrossPK() then   --by wangyan
        return
    end
    self._serverMgr:sendMsg("CrossPKServer", "getCrossPKInfo", {}, true, {}, function (result)
       self:reflashUI()
    end)
end

function CrossMainView:reflashUI()
    print("CrossMainView:reflashUI")
    self:showState()
    self:updateMap()
    self:updatePrompt()
    
    self:updateTitle() 
    self:updateRight() 
    self:updateActivePrompt()
end

function CrossMainView:updateActivePrompt(  )
    self._extendBar:initOtherViewBtnTip()
end

function CrossMainView:initData() 
    -- 右拉菜单
    self:onRightBottomBtn()

    -- 预告
    self:updateAdvance() 

    -- 抬头
    self:updateTitle() 

    -- 右侧展板
    self:updateRight() 
end

function CrossMainView:showState() 
    local state = self._crossModel:getOpenState()

    local titleBg = self:getUI("leftAdvance.panel")
    local rightScoreBg = self:getUI("rightScoreBg")

    if state == 1 or state == 4 then
        -- titleBg:setVisible(false)
        rightScoreBg:setVisible(false)
    else
        -- titleBg:setVisible(true)
        rightScoreBg:setVisible(true)
    end
    
end

function CrossMainView:updateTitle() 
    local arenaData = self._crossModel:getData()
    local setStr1 = arenaData["sec1"]
    local setStr2 = arenaData["sec2"]
    local sec = arenaData[setStr] 
    local sName1 = self._crossModel:getServerName(setStr1)
    local sName2 = self._crossModel:getServerName(setStr2)

    local bProgress = self:getUI("leftAdvance.panel.bProgress")
    local rProgress = self:getUI("leftAdvance.panel.rProgress")
    local bServerName = self:getUI("leftAdvance.panel.bServerName")
    local rServerName = self:getUI("leftAdvance.panel.rServerName")
    bServerName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    rServerName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    bServerName:setString(sName1)
    rServerName:setString(sName2)
    dump(arenaData)

    local sec1score = arenaData["sec1score"] or 0
    local sec2score = arenaData["sec2score"] or 0
    if sec1score == 0 then
        sec1score = 1
    end
    if sec2score == 0 then
        sec2score = 1
    end
    local percentStr = sec1score/(sec1score+sec2score)
    if percentStr < 0 then
        percentStr = 0
    end
    if percentStr > 1 then
        percentStr = 1
    end
    bProgress:setScaleX(percentStr)
end


function CrossMainView:updateRight() 
    local lab1 = self:getUI("rightScoreBg.rankPanel.lab1")
    lab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local serverName = self:getUI("rightScoreBg.rankPanel.serverName")
    local serverImg = self:getUI("rightScoreBg.rankPanel.serverImg")
    serverName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    local lab1 = self:getUI("rightScoreBg.scorePanel.lab1")
    local lab2 = self:getUI("rightScoreBg.scorePanel.lab2")
    local serverScore = self:getUI("rightScoreBg.scorePanel.serverScore")
    local rankLab = self:getUI("rightScoreBg.scorePanel.rankLab")
    local tishi = self:getUI("rightScoreBg.scorePanel.tishi")

    serverScore:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    rankLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    tishi:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    lab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    lab2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    local lab1 = self:getUI("leftAdvance.lab1")
    local arenaName = self:getUI("leftAdvance.arenaName")
    local seasonName = self:getUI("leftAdvance.seasonName")
    local lab2 = self:getUI("leftAdvance.lab2")
    local timeLab = self:getUI("leftAdvance.timeLab")
    lab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    arenaName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    seasonName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    lab2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    timeLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    seasonName:setColor(cc.c4b(249, 247, 95, 255))

    -- local arenaData = self._crossModel:getData()
    -- local setStr1 = arenaData["sec1"]
    -- local setStr2 = arenaData["sec2"]
    -- local sec = arenaData[setStr] 
    -- local sName1 = self._crossModel:getServerName(setStr1)
    -- local sName2 = self._crossModel:getServerName(setStr2)

    -- local usId = self._crossModel:getServerId()
    -- if usId == setStr1 then
    --     serverName:setString(sName1)
    -- else
    --     serverName:setString(sName2)
    -- end

    -- local serRank = 1
    -- local sec1score = arenaData["sec" .. serverFlag .. "score"] or 0
    -- local sec2score = arenaData["sec" .. enemyFlag .. "score"] or 0
    -- local tishiStr = ""
    -- if sec1score < sec2score then
    --     serRank = 2
    --     tishiStr = "(落后" .. (sec2score - 1) .. "积分)"
    -- end


    local arenaData = self._crossModel:getData()
    -- local serverFlag, enemyFlag = self._crossModel:getMyServer(tostring(arenaData["sec1"]))
    -- local setStr = "sec" .. serverFlag

    local usId = self._crossModel:getServerId()
    local sName, stype = self._crossModel:getServerName(tonumber(usId))
    serverName:setString(sName)
    if stype == 1 then
        serverImg:loadTexture("crossUI_img56.png", 1)
        serverName:setColor(cc.c3b(148, 216, 255))
    else
        serverImg:loadTexture("crossUI_img57.png", 1)
        serverName:setColor(cc.c3b(255, 163, 130))
    end

    -- local serverFlag, enemyFlag = self._crossModel:getMyServer(tonumber(usId))
    -- local sName, stype = self._crossModel:getServerName(tonumber(usId))
    -- local setStr = "sec" .. serverFlag

    local serverFlag = 1
    local enemyFlag = 2
    if stype == 2 then
        serverFlag = 2
        enemyFlag = 1
    end

    local serRank = 1
    local sec1score = arenaData["sec" .. serverFlag .. "score"] or 0
    local sec2score = arenaData["sec" .. enemyFlag .. "score"] or 0
    local tishiStr = ""
    local rankImg = self:getUI("rightScoreBg.scorePanel.rankImg")
    rankImg:loadTexture("crossUI_img68.png", 1)
    if sec1score < sec2score then
        serRank = 2
        rankImg:loadTexture("crossUI_img69.png", 1)
        tishiStr = "(落后" .. (sec2score - sec1score) .. "积分)"
    end

    local serverTh = self._crossModel:getMyServerTh(stype)
    for i=1,3 do
        local rankName = self:getUI("rightScoreBg.rankPanel.rankName" .. i)
        rankName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        local playData = serverTh[i]
        if playData then
            local rankNameStr = playData.name 
            rankName:setString(rankNameStr)
        else
            local rankNameStr = "虚位以待"
            rankName:setString(rankNameStr)
        end
    end
    -- local rankNameStr1 = "虚位以待"
    -- rankName1:setString(rankNameStr1)
    -- local rankNameStr2 = "虚位以待"
    -- rankName2:setString(rankNameStr2)
    -- local rankNameStr3 = "虚位以待"
    -- rankName3:setString(rankNameStr3)

    serverScore:setString(sec1score)
    rankLab:setString(serRank)

    tishi:setString(tishiStr)
end


function CrossMainView:updateAdvance() 
    local arenaData = self._crossModel:getOpenArenaData()
    -- dump(arenaData)
    local state = self._crossModel:getOpenState()

    local arenaName = self:getUI("leftAdvance.arenaName")
    local seasonName = self:getUI("leftAdvance.seasonName")
    local lab2 = self:getUI("leftAdvance.lab2")
    local timeLab = self:getUI("leftAdvance.timeLab")

    if self._crossModel:getSeasonSpot() == 0 then
        local nameStr = ""
        local tnum = 1
        for i,v in pairs(arenaData) do
            if tnum == 3 then
                nameStr = nameStr .. lang("cp_npcRegion" .. i)
            else
                nameStr = nameStr .. lang("cp_npcRegion" .. i) .. "、"
            end
            tnum = tnum + 1
        end
        arenaName:setString(nameStr)
        seasonName:setVisible(false)
    else
        local arenaStr = lang("cp_npcRegion" .. table.keyof(arenaData, 1)) .. "、" .. lang("cp_npcRegion" .. table.keyof(arenaData, 2)) .. "、"
        local seasonStr = lang("cp_npcRegion" .. table.keyof(arenaData, 3))
        arenaName:setString(arenaStr)
        seasonName:setString(seasonStr)
        seasonName:setPositionX(arenaName:getPositionX() + arenaName:getContentSize().width)
        seasonName:setVisible(true)
    end


    timeLab:stopAllActions()
    if state == 1 then
        lab2:setString("开赛倒计时:")
        local callFunc = cc.CallFunc:create(function()
            local curServerTime = self._userModel:getCurServerTime()
            local speedTime = self._crossModel:getOpenTime()
            local begTime = speedTime[2]
            local tTime = begTime-curServerTime
            if tTime < 0 then
                timeLab:stopAllActions()
                self:updateAdvance()
                return
            end
            local day = math.floor(tTime/86400)
            tTime = tTime-day*86400
            local hour = math.floor(tTime/3600)
            tTime = tTime-hour*3600
            local min = math.floor(tTime/60)
            tTime = tTime-min*60
            local sec = tTime
            -- local str = day .. "天" .. hour .. ":" .. min .. ":" .. sec
            local str = string.format("%d天 %.2d:%.2d:%.2d", day, hour, min, sec)
            if day == 0 then
                -- str = hour .. ":" .. min .. ":" .. sec
                str = string.format("%.2d:%.2d:%.2d", hour, min, sec)
            end
            timeLab:setString(str)
        end)
        local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
        timeLab:runAction(cc.RepeatForever:create(seq))
    elseif state == 2 then
        lab2:setString("赛季持续时间:")
        local showStr = self._crossModel:getShowStr()
        timeLab:setString(showStr)
    elseif state == 3 then
        lab2:setString("本赛季结束")
        timeLab:setString("")
    elseif state == 4 then
        lab2:setString("本赛季结束")
        timeLab:setString("")
    end
end

function CrossMainView:resetLeftBtnState() 
    print("resetLeftBtnState========================================================")
    -- local gvgBtn = self:getUI("leftBtnBg.gvgBtn")
    -- local pvpBtn = self:getUI("leftBtnBg.pvpBtn")
    -- local intanceBtn = self:getUI("leftBtnBg.intanceBtn")
    -- self._positionX = intanceBtn:getPositionX()
    -- self._funOpenList = {
    --     {intanceBtn, "intance.IntanceView", nil, nil},
    --     {gvgBtn, "citybattle.CityBattleView", 102,"globalImageUI8_worldMenuTip2"},
    --     {pvpBtn, "", 103, "globalImageUI8_worldMenuTip3"},
    -- }  
    -- for i,v in ipairs(self._funOpenList) do
    --     if v[1].positionX == nil then 
    --         v[1].positionX = v[1]:getPositionX()
    --     end
    --     self:addBtnFunction(v)
    -- end
    self:initLeftBtnTip()
    -- self:resetLeftBtnState1()
end

function CrossMainView:initMap()
    local sp1 = cc.Sprite:create("asset/uiother/map/chaodaditu.jpg")
    sp1:setScale(0.7)
    sp1:setPosition(700, 700)

    self._scrollView = self:getUI("scrollView")
    self._scrollView:setContentSize(cc.size(MAX_SCREEN_WIDTH,MAX_SCREEN_HEIGHT))
    self._scrollView:setInnerContainerSize(cc.size(1400, 1400))
    self._scrollView:addChild(sp1)

    self:initPos()
    self:updatePrompt()
end

function CrossMainView:initPos()
    local nests = CrossUtils.mapImg
    local arenaData = self._crossModel:getOpenArenaData()
    local red = true
    for i=1,9 do
        if arenaData[i] then
            local colorValue = nests[i]

            local pos = colorValue.pos
            local imgStr = colorValue.img

            local sp1 = self._scrollView["sp" .. i]
            if not sp1 then
                -- sp1 = cc.Sprite:create("asset/uiother/nests/mapBorder" .. i .. "_nests.png")
                -- sp1:setScale(1)
                sp1 = cc.Sprite:create("asset/uiother/crossMap/" .. imgStr)
                sp1:setScale(1.43)
                sp1:setName("sp" .. i)
                self._scrollView:addChild(sp1)
                self._scrollView["sp" .. i] = sp1
            end
            sp1:setPosition(pos[1], pos[2])

            local colorMap = {}
            colorMap[1] = colorValue.hue
            colorMap[2] = colorValue.saturation
            colorMap[3] = colorValue.brightness
            colorMap[4] = colorValue.contrast

            sp1:setHue(colorMap[1])
            sp1:setSaturation(colorMap[2])
            sp1:setBrightness(colorMap[3])
            sp1:setContrast(colorMap[4])

            local btnpos = colorValue.btnpos

            local arenaBtn = self._scrollView["arenaBtn" .. i]
            if not arenaBtn then
                arenaBtn = self._arenaBtn:clone()
                self._scrollView:addChild(arenaBtn)
                self._scrollView["arenaBtn" .. i] = arenaBtn
            end
            arenaBtn:setPosition(btnpos[1], btnpos[2])

            self:updateArenaWin(arenaBtn, colorValue, i)

            self:registerClickEvent(arenaBtn, function()
                local state = self._crossModel:getOpenState()
                if state == 2 then
                    self:enterCrossPK(i)
                else
                    self._viewMgr:showTip(lang("cp_tips_clickpk"))
                end
                
                -- self:updateArenaWin(arenaBtn, colorValue, i)
                -- UIUtils:reloadLuaFile("cross.CrossPKView")
                -- self._viewMgr:showView("cross.CrossPKView", {arenaId = i})
            end)
        end

        -- local colorValue = nests[i]
        -- local btnpos = colorValue.btnpos
        -- local numLab = self._scrollView["numLab" .. i]
        -- if not numLab then
        --     numLab = ccui.Text:create()
        --     numLab:setString(i)
        --     numLab:setName("numLab" .. i)
        --     numLab:setFontName(UIUtils.ttfName)
        --     numLab:setFontSize(30)
        --     numLab:setPosition(btnpos[1], btnpos[2])
        --     self._scrollView["numLab" .. i] = numLab
        --     self._scrollView:addChild(numLab,10)
        --     numLab:enableOutline(cc.c4b(0, 0, 0, 255), 1)
        --     numLab:setColor(UIUtils.colorTable.ccColorNew2)
        -- end
    end

    self:scrollToNext()
end

function CrossMainView:updatePrompt(  )
    local arenaData = self._crossModel:getOpenArenaData()
    for i = 1, 9 do
        if arenaData[i] then
            local arenaBtn = self._scrollView["arenaBtn" .. i]
            if arenaBtn then
                local promptImg = arenaBtn:getChildByFullName('nameBg'):getChildByFullName('prompt')
                if self._crossModel:getRegionPrompt(arenaData[i]) then
                    promptImg:setVisible(true)
                else
                    promptImg:setVisible(false)
                end
            end
        end
    end
end


function CrossMainView:updateMap()
    local nests = CrossUtils.mapImg
    local arenaData = self._crossModel:getOpenArenaData()
    local arenaWin = self._crossModel:getServerArenaWin() 

    local red = 1
    for i=1,9 do
        local arenaType = arenaData[i]
        if arenaType then
            local colorValue = nests[i]

            local pos = colorValue.pos
            local imgStr = colorValue.img

            local sp1 = self._scrollView["sp" .. i]
            if not sp1 then
                sp1 = cc.Sprite:create("asset/uiother/crossMap/" .. imgStr)
                -- sp1 = cc.Sprite:create("asset/uiother/nests/mapBorder" .. imgStr .. "_nests.png")
                -- sp1:setScale(1)
                sp1:setName("sp" .. i)
                sp1:setScale(1.43)
                self._scrollView:addChild(sp1)
                self._scrollView["sp" .. i] = sp1
            end
            sp1:setPosition(pos[1], pos[2])

            local colorMap = {}
            colorMap[1] = colorValue.hue
            colorMap[2] = colorValue.saturation
            colorMap[3] = colorValue.brightness
            colorMap[4] = colorValue.contrast

            sp1:setHue(colorMap[1])
            sp1:setSaturation(colorMap[2])
            sp1:setBrightness(colorMap[3])
            sp1:setContrast(colorMap[4])

            local color = cc.c4b(255,255,255,255)
            if arenaWin[arenaType] == 2 then
                color = colorValue.rColor
                sp1:setScale(1.43)
                sp1:setTexture("asset/uiother/crossMap/" .. imgStr)
            elseif arenaWin[arenaType] == 1 then
                color = colorValue.bColor
                sp1:setScale(1.43)
                sp1:setTexture("asset/uiother/crossMap/" .. imgStr)
            end
            sp1:setColor(color)
        end
    end
end

function CrossMainView:updateArenaWin(inView, colorValue, indexId)
    local arenaData = self._crossModel:getOpenArenaData()
    local arenaType = arenaData[indexId]
    local arenaData = self._crossModel:getData()
    local playData = self._crossModel:getSoloArenaData(arenaType)

    local playBg = inView:getChildByFullName("playBg")
    local aname = inView:getChildByFullName("nameBg.aname")
    if aname then
        aname:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        aname:setString(lang("cp_nameRegion" .. indexId))
    end
    local raceImg = inView:getChildByFullName("raceImg")
    if raceImg then
        raceImg:loadTexture("cross_race_" .. indexId .. ".png", 1)
    end
    local aNameBg = inView:getChildByFullName("aNameBg")
    if aNameBg then
        aNameBg:setVisible(false)
    end

    local promptImg = inView:getChildByFullName('nameBg.prompt')
    if promptImg then
        promptImg:setVisible(false)
    end

    local mc1 = inView.mc1
    local duikan = inView.duikan
    if playData == false then
        playBg:setVisible(false)
        if not duikan then
            local mcName = "kuafurukou_crosskuafurokou"
            if arenaType and arenaType == 3 and self._crossModel:getSeasonSpot() ~= 0 then
                mcName = "kuaifurukoujiaqiang_kuafurukou2"
            end
            duikan = mcMgr:createViewMC(mcName, true, false)
            duikan:setPosition(inView:getContentSize().width*0.5, inView:getContentSize().height)
            inView.duikan = duikan
            inView:addChild(duikan, 1)
        else
            duikan:setVisible(true)
        end
        if mc1 then
            mc1:setVisible(false)
        end
        return
    end
    playBg:setVisible(true)
    aNameBg:setVisible(true)
    local param = {avatar = playData.avatar, level = playData.lv, tp = 4, avatarFrame = playData["avatarFrame"], plvl = playData.plvl}
    local icon = inView.headIcon
    if not icon then
        icon = IconUtils:createHeadIconById(param)
        icon:setName("icon")
        icon:setScale(0.8)
        icon:setPosition(40, 144)
        inView:addChild(icon)
        inView.headIcon = icon
    else
        IconUtils:updateHeadIconByView(icon, param)
    end
    local winname = inView:getChildByFullName("aNameBg.winname")
    winname:setColor(cc.c3b(255,255,255))
    winname:enable2Color(1, cc.c4b(252, 232, 49, 255))
    winname:enableOutline(cc.c4b(90, 13, 13, 255), 1)
    winname:setString(lang("cp_winName" .. indexId))

    if duikan then
        duikan:setVisible(true)
    end

    if mc1 then
        mc1:removeFromParent()
    end
    local mcName = "kuafurukou_crosskuafurokou"
    if arenaType == 3 and self._crossModel:getSeasonSpot() ~= 0 then
        mcName = "kuaifurukoujiaqiang_kuafurukou2"
    end
    mc1 = mcMgr:createViewMC(mcName, true, false)
    mc1:setPosition(inView:getContentSize().width*0.5, inView:getContentSize().height)
    inView.mc1 = mc1
    inView:addChild(mc1, 1)

    local pname = inView:getChildByFullName("playBg.pname")
    local pnameStr = playData.name
    local secStr = playData.sec 
    local serverName = self._crossModel:getServerName(secStr)
    if secStr == "npcsec" then
        pnameStr = lang("cp_npcName" .. indexId)
        serverName = lang("cp_npcRegion" .. indexId)
    end
    if pname then
        pname:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        pname:setString(serverName)
    end

    local arenaName = inView:getChildByFullName("playBg.arenaName")
    if arenaName then
        arenaName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        arenaName:setString(pnameStr)
    end

end


function CrossMainView:enterCrossPK(region)
    local arenaData = self._crossModel:getOpenArenaData()
    local arenaType = arenaData[region]
    local param = {region = arenaType, defReport = 2}
    self._crossModel:removeRegionPrompt(arenaType)
    self:updatePrompt()
    self._serverMgr:sendMsg("CrossPKServer", "enterCrossPK", param, true, {}, function (result)
        local tabSelect = 2
        local soloData = self._crossModel:getSoloArenaData(arenaType)
        local weakNpcData = self._crossModel:getWeakNpcData(arenaType)
        if soloData == false then
            tabSelect = 1
        else
            local tstate = self._crossModel:getSoloEnemyData()
            if tstate ~= 1 then
                tabSelect = 1
            end
            if not soloData then
                local tparam = {region = arenaType}
                self._serverMgr:sendMsg("CrossPKServer", "getChallengeInfo", tparam, true, {}, function (result)
                    local soloData = self._crossModel:getSoloArenaData(arenaType)
                    if soloData == false then
                        tabSelect = 1
                    end
                end)
            end
            if not weakNpcData then
                local tparam = {region = arenaType}
                self._serverMgr:sendMsg("CrossPKServer", "getWeakNpcData", tparam, true, {}, function ( result )
                    local weakNpcData = self._crossModel:getWeakNpcData(arenaType)
                    if weakNpcData == nil then
                        tabSelect = 1
                    end
                end)
            end
        end

        -- dump(result, "result==========", 10)
        UIUtils:reloadLuaFile("cross.CrossPKView")
        self._viewMgr:showView("cross.CrossPKView", {arenaId = region, defReport = 2, tabSelect = tabSelect})
    end)
end

-- 组装战斗数据 copy from GlobalFormationView
function CrossMainView:getEnemyInfo()
    local enemyInfo = BattleUtils.jsonData2lua_battleData(self._enemyData)

    -- 给布阵设数据
    -- self._modelMgr:getModel("MFModel"):setEnemyHeroData(self._enemyData.hero)
    -- self._modelMgr:getModel("MFModel"):setEnemyData(self._enemyData.teams)
    --
    return enemyInfo
end



function CrossMainView:initLeftBtnTip()
    -- self._worldTipRichText = nil
    -- local mainViewModel = self._modelMgr:getModel("MainViewModel")
    -- local worldTips = mainViewModel:getWorldTipsQipao()
    -- for k,v in pairs(self._funOpenList) do
    --     local name = v[1]:getName() .. "qipao"
    --     if v[1]:getChildByName(name) ~= nil then 
    --         v[1]:getChildByName(name):removeFromParent()
    --     end
    -- end

    -- for i=1, #worldTips do
    --     if worldTips[i].callback ~= nil and  worldTips[i]:callback() == true then 
    --         local sysQiqao = tab:Qipao(worldTips[i].id)
    --         if sysQiqao ~= nil then 
    --             local tempBtn = self:getUI("leftBtnBg." .. sysQiqao.btn)
    --             local tempQipaoNode = UIUtils:addShowBubble(nil, sysQiqao)
    --             if tempBtn ~= nil and tempBtn:isVisible() == true and tempQipaoNode ~= nil then
    --                 tempQipaoNode:setName(sysQiqao.btn .. "qipao")
    --                 tempBtn:addChild(tempQipaoNode, 100)
    --                 break 
    --             end
    --         end
    --     end
    -- end
    local intanceBtn = self:getUI("leftBtnBg.intanceBtn")
    self:registerClickEvent(intanceBtn, function()
        self._viewMgr:showView("intance.IntanceView")
        self:close()
    end)

-- 
end


function CrossMainView:onBeforeAdd(callback, errorCallback)
    self._onBeforeAddCallback = function(inType)
        if inType == 1 then 
            callback()
        else
            errorCallback()
        end
    end
    self:getCrossPKInfo()
end

function CrossMainView:getCrossPKInfo()
    if not SystemUtils:enableCrossPK() then   --by wangyan
        return
    end
    
    self._serverMgr:sendMsg("CrossPKServer", "getCrossPKInfo", {}, true, {}, function (result)
        -- dump(result)
        self:getCrossPKInfoFinish(result)
    end, function(errorId)
        errorId = tonumber(errorId)
        if errorId ~= 0 then
            self._viewMgr:showTip(lang("cp_tips_clickicon"))
            self._onBeforeAddCallback(3)
            self._viewMgr:unlock()
        end
    end)
end

function CrossMainView:getCrossPKInfoFinish(result)
    if result == nil then
        self._onBeforeAddCallback(2)
        return 
    end
    self._onBeforeAddCallback(1)
    self:initMap()
    self:initData() 
    self:reflashUI()
end


function CrossMainView:getRankList()
    local region = 2
    local param = {region = region, start = 1}
    self._serverMgr:sendMsg("CrossPKServer", "getRankList", param, true, {}, function(result) 
        -- dump(result)
        UIUtils:reloadLuaFile("cross.CrossRankDialog")
        self._viewMgr:showDialog("cross.CrossRankDialog", {arenaType = region},true)
    end)
end


function CrossMainView:onRightBottomBtn()
    self:resetLeftBtnState()
    self._extendInfo = {
        -- {"world_rank_btn",      "globalBtnUI7_paihang.png",     "排行",     function()
        --     -- self:initMap()
        --     self:getRankList()
        --     print("排行")
        -- end,    "Elite",           self._target}, 
        {"world_shop_btn",      "globalBtnUI7_shangdian.png",   "商店",     function()
--            print("商店")
			if OS_IS_WINDOWS then
				UIUtils:reloadLuaFile("cross.CrossShopView")
			end
			self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = "cp"}, true, {}, function(result) 
				-- self._viewMgr:showDialog("cross.CrossShopView", {}, true)
                self._viewMgr:showView("shop.ShopView", {idx = 9})
			end)
        end,    "Elite",           self._target}, 
        {"world_reward_btn",    "globalBtnUI7_jiangli.png",     "奖励",     function()
            print("奖励")
            UIUtils:reloadLuaFile("cross.CrossAwardView")
            self._viewMgr:showDialog("cross.CrossAwardView")
        end,    "MF",              self._target},
        {"world_report_btn",    "globalBtnUI7_guize.png",       "规则",     function()
            print("规则")
            UIUtils:reloadLuaFile("cross.CrossRuleView")
            local str = lang("cp_rule")
            self._viewMgr:showDialog("cross.CrossRuleView", {str = str}, true)
        end,    "CloudCity",       self._target},
    }    

    local param = {}
    param.extendInfo = self._extendInfo
    -- 指定按钮宽度
    param.btnWidth = 82
    -- 预留宽度
    param.reserveWidth = 141
    -- 初始化状态1伸展，0收缩
    param.initState = 1
    -- 初始化风格，按照按钮宽度
    param.style = 1
    param.redTipCallback = function(inBtnName, inBtnNode)
        if inBtnNode:getChildByName(inBtnName .. "qipaoAc") ~= nil then
            inBtnNode:getChildByName(inBtnName .. "qipaoAc"):removeFromParent()
        end
        UIUtils.addRedPoint(inBtnNode, false)

        if inBtnNode:getName() == "world_reward_btn" then
            if self._crossModel:isActiveAward() then
                UIUtils.addRedPoint(inBtnNode, true)
            end
        end
    end
    param.motionCallback = function(inState)
    -- inState 1展开，0收缩

    end
    -- 横向方向1左侧，2右侧
    param.horizontal = 2
    param.fontSize = 16

    self._extendBar = require("game.view.global.GlobalExtendBarNode").new(param)
    local quickBg = self:getUI("quickBg")
    quickBg:addChild(self._extendBar)
    self._extendBar:setAnchorPoint(1, 0.5)
    self._extendBar:setPosition(quickBg:getContentSize().width, 60)
    self._extendBar:checkLockStateCallback(
        function()
            if self._parentView1 ~= nil and self._parentView1.getLockTouch ~= nil and  self._parentView1:getLockTouch() == true then return false end
            return true
        end)
end

function CrossMainView:getAsyncRes()
    return {
        {"asset/ui/cross.plist", "asset/ui/cross.png"},
        {"asset/ui/arena1.plist", "asset/ui/arena1.png"},
        {"asset/ui/cross2.plist", "asset/ui/cross2.png"},
    }
end

function CrossMainView:onMainAnim()
    local scrollView = self:getUI("scrollView")
    self._touchYun = nil
    self._touchYun = mcMgr:createViewMC("yun_intancestory", true, false)
    self._touchYun:setPosition(scrollView:getContentSize().width/2 + 200, scrollView:getContentSize().height/2+100)
    self._touchYun:setCascadeOpacityEnabled(true, true)
    self._touchYun:setOpacity(0)
    scrollView:addChild(self._touchYun, 99)
    self._touchYun:setScale(1.3)
    self._touchYun.moveChildren = {}
    -- 记录初始位置
    for i=1,3 do
        self._touchYun.moveChildren[i] = self._touchYun:getChildren()[i]
        self._touchYun.moveChildren[i].cacheInitX = self._touchYun:getChildren()[i]:getPositionX()
    end
    self._touchYun:runAction(cc.FadeIn:create(1))
    self:adjustMapPos(true)

    local bProgress = self:getUI("leftAdvance.panel.bProgress")
    self._mcVs = mcMgr:createViewMC("duikangguang_crosskuafujingjichang", true, false)
    self._mcVs:setPosition(bProgress:getContentSize().width, bProgress:getContentSize().height*0.5)
    bProgress:addChild(self._mcVs, 10)

    -- mingziguang
end

--[[
--! @function adjustMapPos
--! @desc 矫正云偏移位置
--! @return 
--]]
local _speed = {0.2, 0.4, 0.8}
function CrossMainView:adjustMapPos(quickOffset)
    local scrollView = self:getUI("scrollView")
    if not self._touchYun then return end
    local x, y = scrollView:getPosition()
    for i=1, 3 do
        self._touchYun.moveChildren[i]:setPositionX(self._touchYun.moveChildren[i].cacheInitX + x * _speed[i])
    end
end


function CrossMainView:scrollToNext()
    local scrollOffset = {
        [1] = {0, -240},
        [2] = {0, -660},
        [3] = {0, -458},
        [4] = {0, -72},
        [5] = {0, -235},
        [6] = {0, 0},
        [7] = {0, -81},
        [8] = {0, -376},
        [9] = {0, -660},
    }

    if self._inFirst == true then
        local scrollView = self._scrollView
        local scrollInner = scrollView:getInnerContainer()
        local arenaData = self._crossModel:getData()
        local arenaType = arenaData["regiontype1"] or 1
        local pos = scrollOffset[arenaType]
        scrollInner:setPosition(pos[1], pos[2])
        self._inFirst = false
    end
end

function CrossMainView:onDestroy()
	if self._serverMgr then
		self._serverMgr:sendMsg("CrossPKServer", "exitRoom", {}, true, {}, function(result)
			print("sssssssssssssssssssss")
		end)
	end
	ScheduleMgr:cleanMyselfDelayCall(self)
    BulletScreensUtils.clear()
end

function CrossMainView:onTop()
	-- 弹幕
    ScheduleMgr:delayCall(0, self, function()
        self:updateBulletBtnState()
        self:showBullet()
    end)
    self:updateActivePrompt()
end

function CrossMainView:onHide()
    BulletScreensUtils.clear()
end

function CrossMainView:onShow()
	-- 弹幕
    ScheduleMgr:delayCall(0, self, function()
        self:updateBulletBtnState()
        self:showBullet()
    end)
end

function CrossMainView:updateBulletBtnState()
	BulletScreensUtils.clear()

	local bulletBtn = self:getUI("bulletPanel.bulletBtn")
	local bulletLab = self:getUI("bulletPanel.bulletLab")
	if tab.Bullet then
		self._sysBullet = tab:Bullet("crosspk")
	end
	if self._sysBullet == nil or GameStatic.showIntanceBullet == false then 
		bulletBtn:setVisible(false)
		bulletLab:setVisible(false)
		return
	else
		bulletBtn:setVisible(true)
		bulletLab:setVisible(true)
	end

	bulletLab:enable2Color(1, cc.c4b(255, 195, 17, 255))
	bulletLab:enableOutline(cc.c4b(60, 30, 10, 255), 1)

	self:registerClickEvent(bulletBtn, function ()
		self._viewMgr:showDialog("global.BulletSettingView", {bulletD = self._sysBullet,kuaFuEnable = true,
			callback = function (open) 
				local fileName = open and "bullet_open_btn.png" or "bullet_close_btn.png"
				bulletBtn:loadTextures(fileName, fileName, fileName, 1)       
			end})
	end)
end

function CrossMainView:showBullet()
	if self._sysBullet == nil then 
		return
	end
	local bulletBtn = self:getUI("bulletPanel.bulletBtn")
	local open = BulletScreensUtils.getBulletChannelEnabled(self._sysBullet)
	local fileName = open and "bullet_open_btn.png" or "bullet_close_btn.png"
	bulletBtn:loadTextures(fileName, fileName, fileName, 1)    
	if open  then
		BulletScreensUtils.initBullet(self._sysBullet)
	end
end

function CrossMainView:initHistoryBtn()
	local historyBtn = self:getUI("leftAdvance.historyBtn")
	local historyLab = self:getUI("leftAdvance.historyBtn.labBg.historyLab")
	historyLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	self:registerClickEvent(historyBtn, function()
		local historyData = self._crossModel:getHistoryData()
		self._viewMgr:showDialog("cross.CrossHistoryDialog", {crossData = historyData})
	end)
end

function CrossMainView.dtor()
    _speed = nil
    tonumber = nil
    tostring = nil
end

return  CrossMainView