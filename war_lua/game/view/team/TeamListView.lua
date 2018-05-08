--[[
    Filename:    TeamListView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-04-27 17:02:40
    Description: File description
--]]

local TeamListView = class("TeamListView", BaseView)

function TeamListView:ctor()
    TeamListView.super.ctor(self)
    self.initAnimType = 5
    self._index = 1
end

function TeamListView:getAsyncRes()
    return {{"asset/ui/team.plist", "asset/ui/team.png"}}
end

function TeamListView:getBgName()
    return "bg_012.jpg"
end

function TeamListView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{types = {"Texp","Gold","Gem"},title = "globalTitleUI_team.png",titleTxt = "兵团"})
end

function TeamListView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

--使界面处于最上层时调用
function TeamListView:onTop()
    -- self._tableView:setVisible(true)
    if self._updateView == true then 
        self:onModelReflash()
        self._updateView = false
    end
    -- print(abc.abc.abc)
end

function TeamListView:onModelReflash1()
    self._updateView = true 
    local offset = self._tableView:getContentOffset()
    self._tableView:reloadData()
    self._tableView:setContentOffset(offset, false)
end

-- function TeamListView:destroy(removeRes)
--     if self._scrollSchedule then
--         ScheduleMgr:unregSchedule(self._scrollSchedule)
--     end
--     TeamListView.super.destroy(self, removeRes)
-- end

local CARD_WIDTH = 162
local CARD_HEIGHT = 249
local CARD_COLOR_FRAME = {
    [1] = {brightness = 0, contrast = 0, color = cc.c3b(255, 255, 255)},
    [2] = {brightness = 12, contrast = 16, color = cc.c3b(66, 214, 8)},
    [3] = {brightness = 2, contrast = -22, color = cc.c3b(25, 120, 255)},
    [4] = {brightness = 16, contrast = 38, color = cc.c3b(217, 77, 242)},
    [5] = {brightness = 12, contrast = 30, color = cc.c3b(242, 161, 20)},
    [6] = {brightness = 12, contrast = 45, color = cc.c3b(174, 51, 43)},
}

function TeamListView:createTeamListCard(inTable)
    local cardbg = ccui.Layout:create()
    cardbg:setAnchorPoint(0.5, 0.5)
    cardbg:setBackGroundColorOpacity(0)
    cardbg:setBackGroundColorType(1)
    cardbg:setBackGroundColor(cc.c3b(255,255,255))
    cardbg:setContentSize(CARD_WIDTH, CARD_HEIGHT)
    cardbg:setName("cardbg")

    local centerx, centery = CARD_WIDTH * 0.5, CARD_HEIGHT * 0.5

    -- -- 裁剪框
    -- local cardClip = ccui.Layout:create()
    -- cardClip:setAnchorPoint(0.5, 0.5)
    -- cardClip:setPosition(centerx, centery)
    -- cardClip:setClippingEnabled(true)
    -- cardClip:setContentSize(CARD_WIDTH-6, CARD_HEIGHT-10)
    -- cardClip:setName("cardClip")
    -- cardbg:addChild(cardClip)     -- 1

    -- 背景
    local mask = cc.Sprite:create("asset/uiother/cteam/cardt_framebg1-HD.png")
    mask:setPosition(centerx, centery+2)
    mask:setName("mask")

    -- 裁剪框
    local cardClip = cc.ClippingNode:create()
    cardClip:setInverted(false)
    cardClip:setStencil(mask)
    cardClip:setAlphaThreshold(0.2)
    cardClip:setName("cardClip")
    cardClip:setAnchorPoint(cc.p(0.5,0.5))
    -- cardClip:setPosition(centerx*0.5, centery*0.5)
    cardbg:addChild(cardClip)

    local roleBg = cc.Sprite:create("asset/uiother/cteam/cardt_framebg1-HD.png")
    roleBg:setPosition(centerx, centery+2)
    roleBg:setName("roleBg")
    cardbg:addChild(roleBg, -1)

    local roleSp = cc.Sprite:create()
    roleSp:setAnchorPoint(1, 0)
    roleSp:setPosition(CARD_WIDTH, 2) 
    roleSp:setName("roleSp")
    cardClip:addChild(roleSp)     -- 1-2

    -- 遮黑框
    local cardClipBg = ccui.Layout:create()
    cardClipBg:setBackGroundColorOpacity(175)
    cardClipBg:setBackGroundColorType(1)
    cardClipBg:setBackGroundColor(cc.c3b(0,0,0))
    cardClipBg:setContentSize(CARD_WIDTH-2, CARD_HEIGHT-10)
    cardClipBg:setPosition(0, 10)
    cardClipBg:setName("cardClipBg")
    cardClip:addChild(cardClipBg, 20)     -- 1
    
    -- 前景
    local fg = cc.Sprite:create()
    fg:setPosition(centerx, centery - 25)
    fg:setName("fg")
    cardClip:addChild(fg)          -- 1-3

    local classlabel = cc.Sprite:create()
    classlabel:setPosition(CARD_WIDTH-26, CARD_HEIGHT-26)
    classlabel:setScale(0.7)
    classlabel:setName("classlabel")
    cardClip:addChild(classlabel, 3) -- 3

    local name = cc.Label:createWithTTF("123", UIUtils.ttfName, 18)
    name:setAnchorPoint(1, 0.5)
    name:setPosition(CARD_WIDTH - 10, 60)
    name:setName("name")
    cardClip:addChild(name) -- 4

    local level = cc.Label:createWithTTF("123", UIUtils.ttfName, 18)
    level:setAnchorPoint(0, 0.5)
    level:setPosition(5, 60)
    level:setName("level")
    cardClip:addChild(level) -- 4

    -- 星星
    local teamstar = cc.Sprite:createWithSpriteFrameName("globalImageUI6_cardteamStar1.png")
    teamstar:setAnchorPoint(1, 0.5)
    teamstar:setScale(0.7)
    teamstar:setPosition(CARD_WIDTH-10, centery-32)
    teamstar:setName("teamstar")
    cardClip:addChild(teamstar, 3) -- 3

    -- 框
    local zhaozi = cc.Sprite:create("asset/uiother/cteam/cardt_frame1.png")
    zhaozi:setPosition(centerx, centery)
    zhaozi:setName("zhaozi")
    cardbg:addChild(zhaozi) -- 2

    -- 品阶
    local ctquality = cc.Sprite:create()
    -- local ctquality = cc.Sprite:createWithSpriteFrameName("globalImageUI_ctquality3.png")
    ctquality:setAnchorPoint(0, 1)
    ctquality:setPosition(0, CARD_HEIGHT+5)
    ctquality:setName("ctquality")
    cardbg:addChild(ctquality, 20) -- 3

    local qualityLab = cc.Label:createWithTTF("123", UIUtils.ttfName, 22)
    qualityLab:setPosition(22, 22)
    qualityLab:setName("qualityLab")
    ctquality:addChild(qualityLab) -- 4

    -- 上阵
    -- local onTeamIcon = cc.Sprite:create()
    local addTeam = cc.Sprite:createWithSpriteFrameName("globalIamgeUI6_addTeam.png")
    addTeam:setAnchorPoint(0, 1)
    addTeam:setPosition(0, CARD_HEIGHT-65)
    addTeam:setName("addTeam")
    cardbg:addChild(addTeam, 20) -- 3

    -- 红点
    local onTeamIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
    onTeamIcon:setAnchorPoint(1, 1)
    onTeamIcon:setPosition(CARD_WIDTH+12, CARD_HEIGHT+12)
    onTeamIcon:setName("onTeamIcon")
    cardbg:addChild(onTeamIcon, 20) -- 3

    -- 进度条
    local progressBg = cc.Sprite:createWithSpriteFrameName("teamImageUI_img57.png")
    progressBg:setPosition(centerx, centery + 20)
    progressBg:setName("progressBg")
    cardbg:addChild(progressBg) -- 3

    local prox = progressBg:getContentSize().width*0.5
    local proy = progressBg:getContentSize().height*0.5
    local progressBar = cc.Sprite:createWithSpriteFrameName("teamImageUI_img59.png")
    progressBar:setAnchorPoint(0, 0.5)
    progressBar:setPosition(2, proy)
    progressBar:setName("progressBar")
    progressBg:addChild(progressBar, 2) -- 3


    local zhaomuBtn = ccui.Button:create("globalBtnUI_preViewBtn.png", "globalBtnUI_preViewBtn.png", "globalBtnUI_preViewBtn.png", 1)
    zhaomuBtn:setPosition(centerx+10, -1*centery + 15)
    zhaomuBtn:setName("zhaomuBtn")
    zhaomuBtn:setScale(0.6)
    progressBg:addChild(zhaomuBtn, 5)

    local zhaomu = cc.Sprite:createWithSpriteFrameName("teamImageUI_img5.png")
    zhaomu:setPosition(prox, proy-30)
    zhaomu:setName("zhaomu")
    progressBg:addChild(zhaomu, 5) -- 3

    local progressFrame = cc.Sprite:createWithSpriteFrameName("teamImageUI_img58.png")
    progressFrame:setPosition(prox, proy)
    progressFrame:setName("progressFrame")
    progressBg:addChild(progressFrame, 5) -- 3

    local itemNumLab = cc.Label:createWithTTF("123", UIUtils.ttfName, 18)
    itemNumLab:setAnchorPoint(0, 0.5)
    itemNumLab:setPosition(0, proy-15)
    itemNumLab:setName("itemNumLab")
    itemNumLab:setColor(cc.c3b(252, 200, 100))
    itemNumLab:enableOutline(UIUtils.colorTable.titleOutLineColor, 1)
    progressBg:addChild(itemNumLab) -- 4

    local tName = cc.Label:createWithTTF("123", UIUtils.ttfName, 24)
    tName:enableOutline(UIUtils.colorTable.titleOutLineColor, 1)
    tName:setPosition(prox, proy+15)
    tName:setName("tName")
    progressBg:addChild(tName) -- 4

    self:updateTeamCard(cardbg, inTable)
    return cardbg
end

function TeamListView:updateHaveTeamUI(inView, inTable)
    local systeam = inTable.systeam
    local teamD = inTable.teamD
    if not systeam then
        return
    end

    local centerx, centery = CARD_WIDTH * 0.5, CARD_HEIGHT * 0.5
    local teamId = teamD.teamId
    local backQuality = self._teamModel:getTeamQualityByStage(teamD["stage"])
    -- 觉醒数据
    local isAwaking, aLvl = TeamUtils:getTeamAwaking(teamD)
    local teamName, art1, art2, art3 = TeamUtils:getTeamAwakingTab(teamD)

    local cardClip = inView:getChildByFullName("cardClip")
    cardClip:setSaturation(0)

    -- local bg = cardClip:getChildByFullName("bg")
    -- if bg then
    --     UIUtils:asyncLoadTexture(bg, "asset/uiother/cteam/cardt_framebg" .. backQuality[1] .. ".png")
    -- end

    local cardClipBg = cardClip:getChildByFullName("cardClipBg")
    if cardClipBg then
        cardClipBg:setVisible(false)
    end

    local roleSp = cardClip:getChildByFullName("roleSp")
    if roleSp then
        local fileName = "asset/uiother/cteam/ct_" .. teamId .. ".jpg"
        if isAwaking == true then
            fileName = "asset/uiother/cteam/cta_" .. teamId .. ".jpg"
        end
        UIUtils:asyncLoadTexture(roleSp, fileName)
    end

    local fg = cardClip:getChildByFullName("fg")
    if fg then
        UIUtils:asyncLoadTexture(fg, "asset/uiother/cteam/cardt_farebg.png")
    end

    local classlabel = cardClip:getChildByFullName("classlabel")
    if classlabel then
        local tclasslabel = systeam.classlabel1
        classlabel:setSpriteFrame(tclasslabel .. ".png")
    end

    local level = cardClip:getChildByFullName("level")
    if level then
        level:setString("Lv." .. (teamD.level or 1))
    end

    local ctquality = inView:getChildByFullName("ctquality")
    local qualityLab = ctquality:getChildByFullName("qualityLab")
    if ctquality and qualityLab then
        if backQuality[2] ~= 0 then
            ctquality:setSpriteFrame("globalImageUI_ctquality" .. backQuality[1] .. ".png")
            ctquality:setVisible(true)
            qualityLab:setString("+" .. backQuality[2])
        else
            ctquality:setVisible(false)
        end
    end

    local addTeam = inView:getChildByFullName("addTeam")
    if addTeam then
        if teamD.isInFormation == true then
            addTeam:setVisible(true)
        else
            addTeam:setVisible(false)
        end
    end

    -- 名字
    local name = cardClip:getChildByFullName("name")
    if name then
        local str = lang(teamName)
        name:setString(str)
        name:setColor(UIUtils.colorTable["ccColorQuality" .. backQuality[1]])
        name:enableOutline(UIUtils.colorTable["ccColorQualityOutLine" .. backQuality[1]], 1)
    end

    local teamstar = cardClip:getChildByFullName("teamstar")
    if teamstar then
        teamstar:setSpriteFrame("globalImageUI6_cardteamStar" .. teamD.star .. ".png")
    end
    
    -- 外框
    local zhaozi = inView:getChildByFullName("zhaozi")
    if zhaozi then
        local colorframe = CARD_COLOR_FRAME[backQuality[1]]
        zhaozi:setBrightness(colorframe.brightness)
        zhaozi:setContrast(colorframe.contrast)
        zhaozi:setColor(colorframe.color)
        local fileName = "asset/uiother/cteam/cardt_frame1.png"
        if isAwaking == true then
            fileName = "asset/uiother/cteam/cardt_awakingframe1.png"
        end
        UIUtils:asyncLoadTexture(zhaozi, fileName)
        -- UIUtils:asyncLoadTexture(zhaozi, "asset/uiother/cteam/cardt_frame" .. backQuality[1] .. ".png")
    end

    -- 红点
    local onTeamIcon = inView:getChildByFullName("onTeamIcon")
    if onTeamIcon then
        if (teamD.isInFormation == true and teamD.onTeam == true) or (teamD.onTree == 1) then 
            onTeamIcon:setVisible(true)
        else
            onTeamIcon:setVisible(false)
        end
    end

    local progressBg = inView:getChildByFullName("progressBg")
    if progressBg then
        progressBg:setVisible(false)
    end
    if level then
        level:setVisible(true)
    end

    local teamRuneData = self:getTeamCellRune(teamD, systeam)
    self:addTeamRune(cardClip, teamRuneData)
end

function TeamListView:updateNoTeamUI(inView, inTable)
    local systeam = inTable.systeam
    local teamD = inTable.teamD
    if not systeam then
        return
    end

    local centerx, centery = CARD_WIDTH * 0.5, CARD_HEIGHT * 0.5
    local teamId = teamD.teamId

    local cardClip = inView:getChildByFullName("cardClip")
    cardClip:setSaturation(-100)

    local bg = cardClip:getChildByFullName("bg")
    if bg then
        UIUtils:asyncLoadTexture(bg, "asset/uiother/cteam/cardt_framebg1-HD.png")
    end

    local cardClipBg = cardClip:getChildByFullName("cardClipBg")
    if cardClipBg then
        cardClipBg:setVisible(true)
    end

    local roleSp = cardClip:getChildByFullName("roleSp")
    if roleSp then
        UIUtils:asyncLoadTexture(roleSp, "asset/uiother/cteam/ct_" .. teamId .. ".jpg")
    end

    local fg = cardClip:getChildByFullName("fg")
    if fg then
        UIUtils:asyncLoadTexture(fg, "asset/uiother/cteam/cardt_farebg.png")
    end

    local teamstar = cardClip:getChildByFullName("teamstar")
    if teamstar then
        teamstar:setSpriteFrame("globalImageUI6_cardteamStar" .. teamD.starlevel .. ".png")
    end

    local zhaozi = inView:getChildByFullName("zhaozi")
    if zhaozi then
        local colorframe = CARD_COLOR_FRAME[1]
        zhaozi:setBrightness(colorframe.brightness)
        zhaozi:setContrast(colorframe.contrast)
        zhaozi:setColor(colorframe.color)
        UIUtils:asyncLoadTexture(zhaozi, "asset/uiother/cteam/cardt_frame1.png")
        -- UIUtils:asyncLoadTexture(zhaozi, "asset/uiother/cteam/cardt_frame1.png")
    end


    local ctquality = inView:getChildByFullName("ctquality")
    if ctquality then
        ctquality:setVisible(false)
    end

    local addTeam = inView:getChildByFullName("addTeam")
    if addTeam then
        addTeam:setVisible(false)
    end

    local classlabel = cardClip:getChildByFullName("classlabel")
    if classlabel then
        local tclasslabel = systeam.classlabel1
        classlabel:setSpriteFrame(tclasslabel .. ".png")
    end

    local name = cardClip:getChildByFullName("name")
    local namestr = lang(systeam["name"])
    if name then
        name:setString(namestr)
        name:setColor(UIUtils.colorTable["ccColorQuality1"])
        name:enableOutline(UIUtils.colorTable["ccColorQualityOutLine1"], 1)
    end

    local level = cardClip:getChildByFullName("level")
    if level then
        level:setVisible(false)
    end
    
    local progressBg = inView:getChildByFullName("progressBg")
    if progressBg then
        progressBg:setVisible(true)
    end

    local zhaomuBtn = progressBg:getChildByFullName("zhaomuBtn")
    self:registerClickEvent(zhaomuBtn, function()
        self._viewMgr:showDialog("formation.NewFormationDescriptionView", {iconType = 15, iconId = teamD.teamId}, true)
    end)

    local progressBar = progressBg:getChildByFullName("progressBar")

    local progressFrame = progressBg:getChildByFullName("progressFrame")
    if progressFrame then
        progressFrame:setVisible(true)
    end


    local sameSouls, sameSoulCount = self._itemModel:getItemsById(systeam.goods)
    local teamStar = tab.star[systeam.starlevel]
    local onTeamIcon = inView:getChildByFullName("onTeamIcon")
    local zhaomu = progressBg:getChildByFullName("zhaomu")
    local itemNumLab = progressBg:getChildByFullName("itemNumLab")
    if sameSoulCount >= teamStar.sum then 
        -- 红点提示
        local teamModel = self._modelMgr:getModel("TeamModel")
        if onTeamIcon then
            if next(teamModel:getCanGatTeams()) ~= nil then 
                onTeamIcon:setVisible(true)
            else
                onTeamIcon:setVisible(false)
            end
        end
        if inView.zhaomuMc then 
            inView.zhaomuMc:setVisible(true)
        else
            local zhaomuMc = mcMgr:createViewMC("dianjizhaomu_teamupgrade", true)
            zhaomuMc:setPosition(progressBg:getContentSize().width*0.5, progressBg:getContentSize().height*0.5)
            zhaomuMc:setName("zhaomuMc")
            progressBg:addChild(zhaomuMc, 100)
            inView.zhaomuMc = zhaomuMc
        end

        -- 点击招募
        if zhaomu then
            zhaomu:setVisible(true)
            zhaomu:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.8, 0.9), cc.ScaleTo:create(0.8, 1.1))))
        end
        if progressBar then
            progressBar:setScaleX(1)
        end
        if itemNumLab then
            itemNumLab:setVisible(false)
        end
    else
        if zhaomu then
            zhaomu:setVisible(false)
        end

        if inView.zhaomuMc then 
            inView.zhaomuMc:setVisible(false)
        end
        if onTeamIcon then
            onTeamIcon:setVisible(false)
        end
        if itemNumLab then
            itemNumLab:setVisible(true)
            itemNumLab:setString(sameSoulCount .. "/" .. teamStar.sum)
        end
        if progressBar then
            local value = sameSoulCount / teamStar.sum
            progressBar:setScaleX(value)
        end
    end

    local tName = progressBg:getChildByFullName("tName")
    if tName then
        tName:setString(namestr)
    end

    local teamRuneData = self:getNoTeamCellRune(teamD, systeam)
    self:addTeamRune(cardClip, teamRuneData)
end

function TeamListView:updateTeamCard(inView, inTable)
    local teamD = inTable.teamD
    if not teamD then
        return
    end

    if teamD.showType == 1 then
        touchType = 1
        self:updateHaveTeamUI(inView, inTable)
    else
        self:updateNoTeamUI(inView, inTable)
        -- local sameSouls, sameSoulCount = self._itemModel:getItemsById(sysTeam.goods)
        -- local teamStar = tab.star[sysTeam.starlevel]
        -- local numLab 
        -- if sameSoulCount >= teamStar.sum then 
        --     touchType = 2
        -- else
        --     touchType = 3
        -- end 
    end
end

function TeamListView:getNoTeamCellRune(teamD, systeam)
    local teamRuneData = {}
    -- 符文
    local equipx = -9
    for k,v in ipairs(systeam.equip) do
        local flag = -3
        local sysEquip = tab:Equipment(v)
        teamRuneData[k] = {}
        teamRuneData[k][1] = 1
        teamRuneData[k][2] = 0
        teamRuneData[k][3] = flag
        teamRuneData[k][4] = sysEquip
        teamRuneData[k][5] = teamD
        teamRuneData[k][6] = k
        teamRuneData[k][7] = equipx + 35 * k
    end
    return teamRuneData
end


function TeamListView:getTeamCellRune(teamD, systeam)
    local teamRuneData = {}
    -- 符文
    local equipx = -7
    for k,v in ipairs(systeam.equip) do
        local flag = 1
        local sysEquip = tab:Equipment(v)
        local sysMater = sysEquip["mater" .. teamD["es" .. k]]
        -- 所需材料
        if sysMater then
            for k1,mater in pairs(sysMater) do
                local systemItem = tab:Tool(mater[1])
                local tempItems, tempItemCount = self._itemModel:getItemsById(mater[1])
                local approatchIsFlag = self._itemModel:approatchIsOpen(mater[1])
                if tempItemCount < mater[2] then
                    flag = -1
                    if approatchIsFlag == false then
                        flag = -2
                        break
                    end
                end
            end 
        else
            flag = -3
        end
        teamRuneData[k] = {}
        local backQuality = self._teamModel:getTeamQualityByStage(teamD["es" .. k])
        teamRuneData[k][1] = backQuality[1]
        teamRuneData[k][2] = backQuality[2]
        teamRuneData[k][3] = flag
        teamRuneData[k][4] = sysEquip
        teamRuneData[k][5] = teamD
        teamRuneData[k][6] = k
        teamRuneData[k][7] = equipx + 35 * k
    end
    return teamRuneData
end

function TeamListView:addTeamRune(inView, inTeamRuneData)
    for i,v in ipairs(inTeamRuneData) do
        self:updateTeamCellRune(inView, v, i)
    end
end

function TeamListView:updateTeamCellRune(inView, inTeamRuneData, key)
    if not inTeamRuneData then
        return
    end
    local posx = inTeamRuneData[7]
    local posy = 26
    local tscale = 0.35
    -- 背景
    local runeIconBg = inView:getChildByName("runeIconBg" .. key)
    if not runeIconBg then
        runeIconBg = cc.Sprite:create()
        runeIconBg:setName("runeIconBg" .. key)
        runeIconBg:setPosition(posx, posy)
        runeIconBg:setScale(tscale)
        inView:addChild(runeIconBg, 1)
    end
    local filename = "globalImageUI6_itembg_" .. inTeamRuneData[1] .. ".png"
    runeIconBg:setSpriteFrame(filename)

    -- 图片
    local runeIcon = inView:getChildByName("runeIcon" .. key)
    if not runeIcon then
        runeIcon = cc.Sprite:create()
        runeIcon:setName("runeIcon" .. key)
        runeIcon:setScale(tscale)
        runeIcon:setPosition(posx, posy)
        inView:addChild(runeIcon, 2)
    end
    local filename = inTeamRuneData[4].art .. ".png"
    runeIcon:setSpriteFrame(filename)

    -- 箭头
    local arrowUp = inView:getChildByName("arrowUp" .. key)
    if not arrowUp then
        arrowUp = cc.Sprite:create()
        arrowUp:setScale(tscale)
        arrowUp:setName("arrowUp" .. key)
        arrowUp:setPosition(posx+5, posy-5)
        inView:addChild(arrowUp, 3)
    end
    local filename = "globalImageUI5_upArrow.png"
    local equLevel = inTeamRuneData[5]["el" .. inTeamRuneData[6]]
    local equStage = inTeamRuneData[5]["es" .. inTeamRuneData[6]]
    if inTeamRuneData[3] >= 0 then 
        if arrowUp ~= nil then 
            if equLevel >= inTeamRuneData[4].level[equStage] and inTeamRuneData[3] == 1 then
                filename = "globalImageUI5_upArrow.png"  -- 绿色箭头
            else 
                filename = "globalImageUI5_upArrow1.png"  -- 黄色箭头
            end
            arrowUp:setVisible(true)
        end
    else  
        arrowUp:setVisible(false)
        if arrowUp and inTeamRuneData[3] == -1 then
            filename = "globalImageUI6_team_cha.png"  -- XX
            arrowUp:setVisible(true)
        end
        local modelMgr = ModelManager:getInstance()
        local userlvl = modelMgr:getModel("UserModel"):getData().lvl
        if userlvl >= 4 and userlvl <= 9 then
            arrowUp:setVisible(false)
        end
    end
    arrowUp:setSpriteFrame(filename)

    -- 框
    local iconColor = inView:getChildByName("iconColor" .. key)
    if not iconColor then
        iconColor = cc.Sprite:createWithSpriteFrameName("globalImageUI4_squality" .. inTeamRuneData[1] .. ".png")
        iconColor:setScale(tscale)
        iconColor:setName("iconColor" .. key)
        iconColor:setPosition(posx, posy)
        inView:addChild(iconColor,3)
    end
    local filename = "globalImageUI4_squality" .. inTeamRuneData[1] .. ".png"
    iconColor:setSpriteFrame(filename)

    -- 品阶
    local iconGem = inView:getChildByFullName("gem" .. key)
    if iconGem == nil then
        iconGem = cc.Sprite:create()
        iconGem:setScale(tscale)
        iconGem:setName("gem" .. key)
        iconGem:setAnchorPoint(0.5,1)
        iconGem:setPosition(posx, posy+18)
        inView:addChild(iconGem,6) 
    end
    if inTeamRuneData[2] == 0 then
        iconGem:setVisible(false)
    elseif inTeamRuneData[2] > 1 then
        iconGem:setVisible(true)
        iconGem:setSpriteFrame("globalImageUI_quality" .. inTeamRuneData[1] .. "_" .. inTeamRuneData[2] .. ".png")
    else
        iconGem:setVisible(true)
        iconGem:setSpriteFrame("globalImageUI_quality" .. inTeamRuneData[1] .. ".png")
    end
end


function TeamListView:onInit()
    local tishi = self:getUI("tishiBg.classType.tishi")
    tishi:setFontSize(28)
    -- tishi:enableOutline(cc.c4b(130,85,40,255), 2)

    -- self._listCell = self:getUI("listCell")
    -- self._listCell:setVisible(false)

    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")

    -- 全部
    local tab1 = self:getUI("listBtn.tab1")
    -- 近战
    local tab2 = self:getUI("listBtn.tab2")
    -- 远程
    local tab3 = self:getUI("listBtn.tab3")
    -- 魔法
    local tab4 = self:getUI("listBtn.tab4")
    -- 防御
    local tab5 = self:getUI("listBtn.tab5")
    -- 突击
    local tab6 = self:getUI("listBtn.tab6")

    -- tab1:setTitleFontName(UIUtils.ttfName)
    -- tab2:setTitleFontName(UIUtils.ttfName)
    -- tab3:setTitleFontName(UIUtils.ttfName)
    -- tab4:setTitleFontName(UIUtils.ttfName)
    -- tab5:setTitleFontName(UIUtils.ttfName)
    -- tab6:setTitleFontName(UIUtils.ttfName)

    self._teamModel:initAllSysTeams()
    self._teamModel:initGetSysTeams()

    self._teamsData = self._teamModel:getAllTeamData()
    self._sysTeamsData = self._teamModel:getAllSysTeams()

    self:registerClickEvent(tab1, function(sender)self:tabButtonClick(sender, 1) end)
    self:registerClickEvent(tab2, function(sender)self:tabButtonClick(sender, 2) end)
    self:registerClickEvent(tab3, function(sender)self:tabButtonClick(sender, 3) end)
    self:registerClickEvent(tab4, function(sender)self:tabButtonClick(sender, 4) end)
    self:registerClickEvent(tab5, function(sender)self:tabButtonClick(sender, 5) end)
    self:registerClickEvent(tab6, function(sender)self:tabButtonClick(sender, 6) end)

    self._tabEventTarget = {}
    table.insert(self._tabEventTarget, tab1)
    table.insert(self._tabEventTarget, tab2)
    table.insert(self._tabEventTarget, tab3)
    table.insert(self._tabEventTarget, tab4)
    table.insert(self._tabEventTarget, tab5)
    table.insert(self._tabEventTarget, tab6)

    -- [[ 展示新板子动画设置的参数
    self._playAnimBg = self:getUI("bg")
    self._playAnimBgOffX = 0
    self._playAnimBgOffY = 0
    self._animBtns = {tab1,tab2,tab5,tab6,tab3,tab4}
    --]]

    self._cacheTeamsUI = {}
    self._cacheSysTeamsUI = {}

    self:listenReflash("TeamModel", self.onModelReflash1)
    self:listenReflash("ItemModel", self.onModelReflash1)
    self:listenReflash("UserModel", self.onModelReflash1)

    local lineNum = (MAX_SCREEN_WIDTH-300)/CARD_WIDTH
    print("lineNum====11=", lineNum)
    lineNum = math.floor(lineNum)
    print("lineNum=====", lineNum)
    self._lineNum = lineNum
    -- if MAX_SCREEN_WIDTH < 1136 then
    --     self._lineNum = 4
    -- end

    -- 首次进入需要排序
    local teamModel = self._modelMgr:getModel("TeamModel")
    teamModel:refreshDataOrder()

    self:addTableView()
    self:onModelReflash()
    self:addAnimBg()
end

-- 143
-- 55.5
--[[
用tableview实现
--]]
local cardwidth = 180
function TeamListView:addTableView()
    local tableViewBg = self:getUI("tableViewBg")
    local twidth = self._lineNum*cardwidth
    local posx = (MAX_SCREEN_WIDTH - 150 - twidth)*0.5 + 900 - twidth
    local theight = MAX_SCREEN_HEIGHT - 130
    self._tableView = cc.TableView:create(cc.size(twidth, theight))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(180, 0)
    
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end, cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:setBounceable(true)

    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end

    tableViewBg:addChild(self._tableView, 1)

    UIUtils:ccScrollViewAddScrollBar(self._tableView, cc.c3b(169, 124, 75), cc.c3b(64, 32, 12), -12, 6)
end

function TeamListView:scrollViewDidScroll(view)
    UIUtils:ccScrollViewUpdateScrollBar(view)
end

-- 触摸时调用
function TeamListView:tableCellTouched(table,cell)
end

-- cell的尺寸大小
function TeamListView:cellSizeForTable(table,idx) 
    local width = cardwidth 
    local height = 270
    local row = idx * self._lineNum 
    local index = 0
    if row >= #self._teamsData then
        index = idx * self._lineNum - (math.ceil(#self._teamsData/self._lineNum) * self._lineNum)
        if index == 0 then
            height = 351
        end
    end
    return height, width
end

-- 创建在某个位置的cell
function TeamListView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx + 1

    if nil == cell then
        cell = cc.TableViewCell:new()
        for i=1,self._lineNum do
            -- local teamData = self._teamModel:getData()[1]
            -- local teamId = 101 
            -- local systeam = tab:Team(teamId)
            local param = {}
            local listCell = self:createTeamListCard(param)
            listCell:setName("listCell" .. i)
            listCell:setVisible(true)
            listCell:setAnchorPoint(cc.p(0,0))
            listCell:setPosition(cc.p((i-1)*(cardwidth-5)+10,0))
            cell:addChild(listCell)
        end
    end

    local row = idx * self._lineNum 
    local tableData 
    local index = 0
    local teamsCell, teamIndex
    local title = false
    local tteamData = {}
    local inLeftTeamData = nil
    local inRightTeamData = nil 
    if row >= #self._teamsData then
        tableData = self._sysTeamsData
        index = row - (math.ceil(#self._teamsData/self._lineNum) * self._lineNum)
        for i=1,self._lineNum do
            teamIndex = index + i
            if #tableData >= teamIndex and tableData[teamIndex] then
                local team = tableData[teamIndex]
                tteamData[i] = team
            end        
        end

        if index == 0 then
            title = true
        end
    else
        tableData = self._teamsData
        index = idx * self._lineNum
        for i=1,self._lineNum do
            teamIndex = index + i
            if #tableData >= teamIndex and tableData[teamIndex] then
                local team = tableData[teamIndex]
                tteamData[i] = team
                -- if i == 1 then
                --     inLeftTeamData = tableData[teamIndex]
                -- elseif i == 2 then
                --     inRightTeamData = tableData[teamIndex]
                -- end
            end        
        end
    end
    self:updateCell(cell, indexId, tteamData, false, title)

    return cell
end

-- 区分板子类型
function TeamListView:updateCell(cell, indexId, tteamData, isActive, title)
    for k,v in pairs(cell:getChildren()) do
        local listCell = v
        local teamData = tteamData[k]
        if teamData then
            listCell:setName(teamData.teamId)
            listCell:setVisible(true)
            local systeam = tab:Team(teamData.teamId)
            local param = {systeam = systeam, teamD = teamData}
            self:updateTeamCard(listCell, param)



            local touchType = 1
            if teamData.showType == 1 then
                touchType = 1
            else
                local sameSouls, sameSoulCount = self._itemModel:getItemsById(systeam.goods)
                local teamStar = tab.star[systeam.starlevel]
                local numLab 

                if sameSoulCount >= teamStar.sum then 
                    touchType = 2
                else
                    touchType = 3
                end 
            end

            listCell:setBrightness(0)
            local clickFlag = false
            local downY
            local posX, posY
            registerTouchEvent(
                listCell,
                function (_, _, y)
                    downY = y
                    clickFlag = false
                    listCell:setBrightness(40)
                end, 
                function (_, _, y)
                    if downY and math.abs(downY - y) > 5 then
                        clickFlag = true
                    end
                end, 
                function ()
                    listCell:setBrightness(0)
                    if clickFlag == false then 
                        self:setButtonEvent(teamData, touchType)
                    end
                end,
                function ()
                    listCell:setBrightness(0)
                end)
            listCell:setSwallowTouches(false)
        else
            listCell:setVisible(false)
        end
    end

    -- 分割
    local listTmp1 = cell:getChildByName("listTmp1")
    local tempLab = cell:getChildByName("tempLab")
    local listTmp2 = cell:getChildByName("listTmp2")
    local lineNum = (self._lineNum*CARD_WIDTH-680)*0.5
    -- if MAX_SCREEN_WIDTH < 1136 then
    --     lineNum = 0
    -- end
    if title == true then
        if not listTmp1 then
            listTmp1 = cc.Sprite:createWithSpriteFrameName("teamImageUI_img54.png")
            listTmp1:setAnchorPoint(cc.p(0, 1))
            listTmp1:setName("listTmp1")
            cell:addChild(listTmp1)
            listTmp1:setPosition(lineNum, 300)
        else
            listTmp1:setVisible(true)
        end

        if not tempLab then
            tempLab = cc.Label:createWithTTF("未召唤兵种", UIUtils.ttfName, 24)
            tempLab:setName("tempLab")
            tempLab:setAnchorPoint(0.5, 1)
            cell:addChild(tempLab)
            tempLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
            -- tempLab:enableOutline(cc.c4b(60, 30, 10, 255), 1)
            tempLab:setPosition(listTmp1:getContentSize().width + listTmp1:getPositionX() + 20 + tempLab:getContentSize().width/2, 303)
        else
            tempLab:setVisible(true)
        end

        if not listTmp2 then
            listTmp2 = cc.Sprite:createWithSpriteFrameName("teamImageUI_img54.png")
            listTmp2:setAnchorPoint(cc.p(0, 1))
            listTmp2:setName("listTmp2")
            listTmp2:setFlipX(true)
            cell:addChild(listTmp2)
            listTmp2:setPosition(cc.p(tempLab:getPositionX() + tempLab:getContentSize().width*0.5 + 20, 300))
        else
            listTmp2:setVisible(true)
        end
    else
        if listTmp1 then
            listTmp1:setVisible(false)
        end
        if tempLab then
            tempLab:setVisible(false)
        end
        if listTmp2 then
            listTmp2:setVisible(false)
        end
    end
end

-- 点击事件
function TeamListView:setButtonEvent(inTeam,inTouchType)
    if inTouchType == 2 then
        self:getUnActiveTeam(inTeam.teamId)
    elseif inTouchType == 3 then
         self:showUnActiveTeam(inTeam)
    else
        self:showTeamView(inTeam)
    end
end

-- 返回cell的数量
function TeamListView:numberOfCellsInTableView(table)
    local lineNum = self._lineNum
    -- if MAX_SCREEN_WIDTH < 1136 then
    --     lineNum = 0.25
    -- end

    -- local teamsRow = math.ceil(#self._teamsData * lineNum)
    -- local sysTeamsRow = math.ceil(#self._sysTeamsData * lineNum)
    local teamsRow = math.ceil(self:getTableNum(self._teamsData)/lineNum)
    local sysTeamsRow = math.ceil(self:getTableNum(self._sysTeamsData)/lineNum)
    local row = teamsRow + sysTeamsRow
    return row
end

-- 返回cell的数量
function TeamListView:getTableNum(tableData)
    if not tableData then
        return 0
    end
    return table.nums(tableData) 
end

--[[
--! @function onModelReflash
--! @desc 如果model内怪兽数据刷新，则刷新页面
--! @param 
--! @return 
--]]
function TeamListView:onModelReflash()
    print("======onModelReflashonModelReflash===============")
    -- 强制进行排序，以防用户在布阵中修改上阵信息
    local teamModel = self._modelMgr:getModel("TeamModel")
    teamModel:initAllSysTeams()
    teamModel:initGetSysTeams()
    if self._tabName == nil then
        self:tabButtonClick(self._tabEventTarget[1], 1)
        return
    else
        self:refreshTabData(self._tabName)
    end
end

--[[
--! @function tabButtonClick
--! @desc 选项卡按钮点击事件处理
--! @param sender table 操作对象
--! @return 
--]]
function TeamListView:tabButtonClick(sender, key)
    if sender == nil then 
        return 
    end
    if self._tabName == sender:getName() then 
        return 
    end
    for k,v in pairs(self._tabEventTarget) do
        self:tabButtonState(v, false, k)
    end
    self:tabButtonState(sender, true, key)
    self:refreshTabData(sender:getName())
    audioMgr:playSound("Tab")
end

--[[
--! @function refreshTabData
--! @desc 更新tab界面
--! @param name 字符串 tab名称
--! @return 
--]]
function TeamListView:refreshTabData(name)
    -- self._tableView:removeAllChildren()
    local data = {}
    local teamModel = self._modelMgr:getModel("TeamModel")
    -- local teamsData, sysTeamsData
    -- self._teamsData = {}
    -- self._sysTeamsData = {}
    if name == "tab1" then
        -- print("======================全部")
        self._teamsData = teamModel:getAllTeamData()
        self._sysTeamsData = teamModel:getAllSysTeams()
        self._index = 1
    elseif name == "tab2" then
        -- print("======================输出")
        self._teamsData = teamModel:getTeamWithMelee()
        self._sysTeamsData = teamModel:getSysTeamWithMelee()
        self._index = 2
    elseif name == "tab3" then
        -- print("======================防御" , "远程")
        self._teamsData = teamModel:getTeamWithRemote()
        self._sysTeamsData = teamModel:getSysTeamWithRemote()
        self._index = 3
    elseif name == "tab4" then
        -- print("======================突击", "魔法")
        self._teamsData = teamModel:getTeamWithMagic()
        self._sysTeamsData = teamModel:getSysTeamWithMagic()
        self._index = 4
    elseif name == "tab5" then
        -- print("======================远程", "防御")
        self._teamsData = teamModel:getTeamWithDef()
        self._sysTeamsData = teamModel:getSysTeamWithDef()
        self._index = 5
    elseif name == "tab6" then
        -- print("======================魔法", "突击")
        self._teamsData = teamModel:getTeamWithSally()
        self._sysTeamsData = teamModel:getSysTeamWithSally()  
        self._index = 6      
    end
    self._tabName = name
    self:updateTishi()
    self._tableView:reloadData()
    -- self:relaodData()
end

--[[
--! @function tabButtonState
--! @desc 按钮状态切换
--! @param sender table 操作对象
--! @param isSelected bool 是否选中状态
--! @return 
--]]
function TeamListView:tabButtonState(sender, isSelected, key)
    local titleNames = {
        " 全部   ",
        " 攻击   ",
        " 射手   ",
        " 魔法   ",
        " 防御   ",
        " 突击   ",
    }
    local shortTitleNames = {
        " 全部   ",
        " 攻击   ",
        " 射手   ",
        " 魔法   ",
        " 防御   ",
        " 突击   ",
    }

    -- local tabtxt = sender:getChildByFullName("tabtxt")
    -- tabtxt:setString("")

    sender:setBright(not isSelected)
    sender:setEnabled(not isSelected)
    sender:getTitleRenderer():disableEffect()
    sender:setTitleFontSize(24)
    -- sender:setTitleFontName(UIUtils.ttfName)
    if isSelected then
        sender:setTitleText(titleNames[key])
        sender:setTitleColor(cc.c3b(251, 211, 176))
    else
        sender:setTitleText(shortTitleNames[key])
        sender:setTitleColor(cc.c3b(130, 100, 70))
    end
end


function TeamListView:updateTishi()
    local classIcon = {
    "tl_shuchu.png",
    "tl_yuancheng.png",
    "tl_mofa.png",
    "tl_fangyu.png",
    "tl_tuji.png",
}
    local tishi = self:getUI("tishiBg.classType.tishi")
    local classType = self:getUI("tishiBg.classType")
    -- classType:setVisible(false)
    tishi:setCascadeOpacityEnabled(true)
    tishi:stopAllActions()
     -- print("self._index===0", self._index)
    if self._index > 1 then
        tishi:setOpacity(255)
        local str = lang("CLASSSKILLDES_" .. (self._index-1))
        tishi:setString(str)
        classType:loadTexture(classIcon[self._index-1], 1)
    else
        local tempNum = 0
        local str
        local seq = cc.Sequence:create(cc.CallFunc:create(function()
            tempNum = tempNum + 1
            if tempNum > 5 then
                tempNum = 1
            end
            str = lang("CLASSSKILLDES_" .. tempNum)
            tishi:setString(str)
            classType:loadTexture(classIcon[tempNum], 1)
        end), cc.FadeIn:create(0.2), 
        cc.DelayTime:create(2), 
        cc.FadeOut:create(0.2)        
        )
        tishi:runAction(CCRepeatForever:create(seq))
    end
end

function TeamListView:showTeamView(inTeam)
    self._updateView = true
    self._viewMgr:showView("team.TeamView", {team = inTeam})
end

function TeamListView:getUnActiveTeam(inTeamId)
    local systeam = tab:Team(inTeamId)
    local teamStar = tab.star[systeam.starlevel]
    self._activeTeamId = inTeamId
    local param = {goodsId = systeam.goods, goodsNum = teamStar.sum, extraParams = nil}
    self._serverMgr:sendMsg("ItemServer", "useItem", param, true, {}, function (result)
        self:getUnActiveTeamFinish(result)
    end)
end

function TeamListView:getUnActiveTeamFinish(inResult)
    if inResult["d"] == nil then 
        return 
    end

    if self._activeTeamId ~= nil then 
        DialogUtils.showTeam({teamId = self._activeTeamId,callback=function()
            self._updateView = false
            self:onModelReflash()
        end})
        self._activeTeamId = nil
    end
end

function TeamListView:showUnActiveTeam(inTeam)
    -- if inTeam.inScroll == true then
        self._viewMgr:showDialog("bag.DialogAccessTo",{goodsId = inTeam.goods, needItemNum = 0},true)
    -- end
end

function TeamListView:onDoGuide(config)
    -- dump(config, "config===", 10)
    if config.showTeam ~= nil then
        local offset = self._tableView:getContentOffset()
        local tempIndex = 0
        local tempFlag = false
        for i=1,table.nums(self._teamsData) do
            if self._teamsData[i].teamId == config.showTeam then
                tempFlag = true
                break
            else
                tempIndex = tempIndex + 1
            end
        end
        -- dump(offset, "offset===")
        if tempFlag == false or math.ceil(tempIndex/self._lineNum) < 2 then
            return
        end
        offset["y"] = offset["y"] + CARD_HEIGHT*math.ceil(tempIndex/self._lineNum) - CARD_HEIGHT + 40
        -- print("===",math.ceil(tempIndex*0.5), offset["y"], -1*tempIndex*0.5*155, 155*(tempIndex*0.5))
        self._tableView:setContentOffset(cc.p(0, offset["y"]), true)
    end
end

return TeamListView