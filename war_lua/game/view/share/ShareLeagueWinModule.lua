--[[
    Filename:    ShareLeagueWinModule.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-02-02 14:42:52
    Description: File description
--]]

local ShareBaseView = require("game.view.share.ShareBaseView")

--[[
    积分联赛晋升分享
    data
        段位 stage
--]]

function ShareBaseView:updateModuleView(data)
    local shareLayer = self:getShareLayer()

    local centerX, centerY = shareLayer:getContentSize().width * 0.5, shareLayer:getContentSize().height * 0.5

    self._battleInfo = data.data.battleInfo
    -- dump(self._battleInfo, "a", 3)

    -- 左边图标
    local leagueRankD1 = tab:LeagueRank(data.stage1)
    local icon = cc.Sprite:createWithSpriteFrameName(leagueRankD1["icon"]..".png")
    icon:setScale(.6)
    icon:setPosition(67, 134)
    shareLayer:addChild(icon)

    -- 右边图标
    local leagueRankD2 = tab:LeagueRank(data.stage2)
    local icon = cc.Sprite:createWithSpriteFrameName(leagueRankD2["icon"]..".png")
    icon:setScale(.6)
    icon:setPosition(1136 - 67, 134)
    shareLayer:addChild(icon)

    -- 左边人物信息
    local info = self._battleInfo.playerInfo
    local infoNode = cc.Node:create()
    infoNode:setScale(.85)
    infoNode:setContentSize(290, 130)

    local infoBg = cc.Scale9Sprite:createWithSpriteFrameName("shareImage_infoBg.png")
    infoBg:setContentSize(cc.size(290, 130))
    infoBg:setCapInsets(cc.rect(49, 5, 1, 1))    
    infoBg:setAnchorPoint(1, 0)
    infoBg:setPosition(0, 0)
    infoBg:setScaleX(-1)
    infoNode:addChild(infoBg)

    local userAvatar = IconUtils:createHeadIconById({avatar = info.avatar,level = info.lv or 0,tp = 4, isSelf = true, plvl = info.plvl})   --,tp = 2
    userAvatar:setAnchorPoint(0, 0.5)
    userAvatar:getChildByFullName("iconColor"):getChildByFullName("levelTxt"):setVisible(false)
    userAvatar:setPosition(10, infoNode:getContentSize().height * 0.5)
    infoNode:addChild(userAvatar)

    local labName = cc.Label:createWithTTF(info.name, UIUtils.ttfName, 24)
    labName:setAnchorPoint(0, 0)
    labName:setPosition(120, 80)
    infoNode:addChild(labName)


    local labLvl = cc.Label:createWithTTF("等级" .. info.lv, UIUtils.ttfName, 24)
    labLvl:setAnchorPoint(0, 0)
    labLvl:setPosition(120, 51)
    infoNode:addChild(labLvl)

    local formationModel = ModelManager:getInstance():getModel("FormationModel")
    local leagueSelfScore = formationModel:getCurrentFightScoreByType(formationModel.kFormationTypeLeague)
    local labBattleScore = cc.Label:createWithTTF("战斗力" .. (leagueSelfScore or info.score), UIUtils.ttfName, 24)
    labBattleScore:setAnchorPoint(0, 0)
    labBattleScore:setPosition(120, 23)
    infoNode:addChild(labBattleScore)
    infoNode:setPosition(0, 214)
    shareLayer:addChild(infoNode)

    -- 左边兵团
    local teams = info.team
    local data, quality, x, y, a, b
    for i = 1, #teams do
        data = teams[i]
        local quality = BattleUtils.TEAM_QUALITY[data.stage]
        local icon = IconUtils:createTeamIconById({teamData = {id = data.id, star = data.star, level = data.level},
        sysTeamData = tab.team[data.id], quality = quality[1], quaAddition = quality[2], eventStyle = 0})        
        icon:setScale(0.5)
        a, b = math.modf((i - 1) / 4) 
        x = 136 + b * 62 * 4
        y = 133 - a * 62
        icon:setPosition(x, y)
        shareLayer:addChild(icon)
    end

    local id = info.hero.id
    local heroD = tab.hero[id]
    if heroD == nil then
        heroD = tab.npcHero[id]
    end
    local heroData = clone(heroD)
    heroData.star = info.hero.star
    heroData.skin = info.hero.skin
    local hero1 = IconUtils:createHeroIconById({sysHeroData = heroData})
    hero1:setPosition(426, 136)
    hero1:setScale(0.65)
    shareLayer:addChild(hero1) 

    local labName = cc.Label:createWithTTF(lang(heroD.heroname), UIUtils.ttfName, 18)
    labName:setAnchorPoint(0.5, 0)
    labName:setPosition(426, 70)
    shareLayer:addChild(labName)

    -- 右边人物信息
    local info = self._battleInfo.enemyInfo
    local infoNode = cc.Node:create()
    infoNode:setScale(.85)
    infoNode:setContentSize(290, 130)

    local infoBg = cc.Scale9Sprite:createWithSpriteFrameName("shareImage_infoBg.png")
    infoBg:setContentSize(cc.size(290, 130))
    infoBg:setCapInsets(cc.rect(49, 5, 1, 1))    
    infoBg:setAnchorPoint(0, 0)
    infoBg:setPosition(0, 0)
    infoNode:addChild(infoBg)

    local userAvatar = IconUtils:createHeadIconById({avatar = info.avatar,level = info.lv or 0,tp = 4, isSelf = true, plvl = info.plvl})   --,tp = 2
    userAvatar:setAnchorPoint(0, 0.5)
    userAvatar:getChildByFullName("iconColor"):getChildByFullName("levelTxt"):setVisible(false)
    userAvatar:setPosition(182, infoNode:getContentSize().height * 0.5)
    infoNode:addChild(userAvatar)

    local labName = cc.Label:createWithTTF(info.name, UIUtils.ttfName, 24)
    labName:setAnchorPoint(1, 0)
    labName:setPosition(174, 80)
    infoNode:addChild(labName)


    local labLvl = cc.Label:createWithTTF("等级" .. info.lv, UIUtils.ttfName, 24)
    labLvl:setAnchorPoint(1, 0)
    labLvl:setPosition(174, 51)
    infoNode:addChild(labLvl)

    local leagueModel = ModelManager:getInstance():getModel("LeagueModel")
    local matchScore  = leagueModel:getEnemyMatchScore()
    local labBattleScore = cc.Label:createWithTTF("战斗力" .. (matchScore or info.score), UIUtils.ttfName, 24)
    labBattleScore:setAnchorPoint(1, 0)
    labBattleScore:setPosition(174, 23)
    infoNode:addChild(labBattleScore)
    infoNode:setPosition(1136 - 246, 214)
    shareLayer:addChild(infoNode)

    -- 右边兵团
    local teams = info.team
    local data, quality, x, y, a, b
    for i = 1, #teams do
        data = teams[i]
        local quality = BattleUtils.TEAM_QUALITY[data.stage]
        local icon = IconUtils:createTeamIconById({teamData = {id = data.id, star = data.star, level = data.level},
        sysTeamData = tab.team[data.id], quality = quality[1], quaAddition = quality[2], eventStyle = 0})        
        icon:setScale(0.5)
        a, b = math.modf((i - 1) / 4) 
        x = 768 + b * 62 * 4
        y = 133 - a * 62
        icon:setSaturation(-100)
        icon:setPosition(x, y)
        shareLayer:addChild(icon)
    end

    local id = info.hero.id
    local heroD = tab.hero[id]
    if heroD == nil then
        heroD = tab.npcHero[id]
    end
    local heroData = clone(heroD)
    heroData.star = info.hero.star
    heroData.skin = info.hero.skin
    local hero2 = IconUtils:createHeroIconById({sysHeroData = heroData})
    hero2:setPosition(723, 136)
    hero2:setScale(0.65)
    hero2:setSaturation(-100)
    shareLayer:addChild(hero2) 

    local labName = cc.Label:createWithTTF(lang(heroD.heroname), UIUtils.ttfName, 18)
    labName:setAnchorPoint(0.5, 0)
    labName:setPosition(723, 70)
    shareLayer:addChild(labName)
end

function ShareBaseView:getShareBgName()
    return "asset/bg/share/share_league_win.jpg"
end


function ShareBaseView:getInfoPosition()
    return nil, nil
end

function ShareBaseView:getShareId()
    return 5
end

