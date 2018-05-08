--
-- Author: huangguofang
-- Date: 2016-10-24 15:21:37
--

local BattleResultShareWin = class("BattleResultShareWin", BasePopView)

function BattleResultShareWin:ctor(data)
    BattleResultShareWin.super.ctor(self)
    self._result = data.result
    self._callback = data.callback
    self._replayCallback = data.replayCallback
    self._battleInfo = data.battleInfo
    self._data = data.data
end

function BattleResultShareWin:onInit()
    audioMgr:playSoundForce("WinBattle")
    
    self._replayBtn = self:getUI("mask.bg.replayBtn")
    self._quitBtn = self:getUI("mask.bg.quitBtn")
    self:registerClickEvent(self._replayBtn, function ()
        if self._replayCallback then
            self._replayCallback()
        end
    end)
    self:registerClickEvent(self._quitBtn, function ()
        if self._callback then
            self._callback()
        end
    end)

    local bg1 = self:getUI("mask.bg.bg1")
    local bg2 = self:getUI("mask.bg.bg2")
    self._bg1 = bg1
    self._bg2 = bg2


    local reverse = self._battleInfo.reverse
    local draw = false
    if self._result.isTimeUp and self._battleInfo.showDraw then
        draw = true
    end

    local light
    local win = self._data.win
    if reverse then win = not win end
    if win then
        if draw then
            self:getUI("mask.bg.bg1.win"):loadTexture("report_draw_battle.png", 1)
            self:getUI("mask.bg.bg2.win"):loadTexture("report_draw_battle.png", 1)
            self:getUI("mask.bg.bg1.win"):setScale(1)
            self:getUI("mask.bg.bg2.win"):setScale(1)
        else
            self:getUI("mask.bg.bg1.win"):loadTexture("report_win_battle.png", 1)
            self:getUI("mask.bg.bg2.win"):loadTexture("report_lose_battle.png", 1)
        end
        light = cc.Sprite:createWithSpriteFrameName("report_bg_3_battle.png")
        light:setAnchorPoint(0, 0)
        light:setPurityColor(255, 255, 255)
        light:setOpacity(0)
        bg1:addChild(light, 99999)
    else
        if draw then
            self:getUI("mask.bg.bg1.win"):loadTexture("report_draw_battle.png", 1)
            self:getUI("mask.bg.bg2.win"):loadTexture("report_draw_battle.png", 1)
            self:getUI("mask.bg.bg1.win"):setScale(1)
            self:getUI("mask.bg.bg2.win"):setScale(1)
        else
            self:getUI("mask.bg.bg1.win"):loadTexture("report_lose_battle.png", 1)
            self:getUI("mask.bg.bg2.win"):loadTexture("report_win_battle.png", 1)
        end
        light = cc.Sprite:createWithSpriteFrameName("report_bg_4_battle.png")
        light:setAnchorPoint(0, 0)
        light:setPurityColor(255, 255, 255)
        light:setOpacity(0)
        bg2:addChild(light, 99999)
    end

    self._name1 = self:getUI("mask.bg.bg1.name")
    self._name2 = self:getUI("mask.bg.bg2.name")
    self._level1 = self:getUI("mask.bg.bg1.level")
    self._level2 = self:getUI("mask.bg.bg2.level")

    local info1, info2
    if reverse then
        info2 = self._battleInfo.playerInfo
        info1 = self._battleInfo.enemyInfo
        bg1:setCascadeOpacityEnabled(false)
        bg1:setOpacity(0)
        local bg11 = cc.Sprite:createWithSpriteFrameName("report_bg_4_battle.png")
        bg11:setRotation(180)
        bg11:setPosition(bg1:getContentSize().width * 0.5, bg1:getContentSize().height * 0.5)
        bg1:addChild(bg11, -1)

        bg2:setCascadeOpacityEnabled(false)
        bg2:setOpacity(0)
        local bg22 = cc.Sprite:createWithSpriteFrameName("report_bg_3_battle.png")
        bg22:setRotation(180)
        bg22:setPosition(bg2:getContentSize().width * 0.5, bg2:getContentSize().height * 0.5)
        bg2:addChild(bg22, -1)
    else
        info1 = self._battleInfo.playerInfo
        info2 = self._battleInfo.enemyInfo
    end

    self._name1:setString(info1.name or "无名氏1")
    self._name2:setString(info2.name or "无名氏2")
    self._level1:setString(info1.lv or "100")
    self._level2:setString(info2.lv or "100")

    local scoreLab = ccui.TextBMFont:create("a"..(info1.curScore or "1000000"), UIUtils.bmfName_zhandouli)
    scoreLab:setAnchorPoint(0, 0)
    scoreLab:setPosition(510, 101)
    scoreLab:setScale(0.55)
    bg1:addChild(scoreLab)

    local scoreLab = ccui.TextBMFont:create("a"..(info2.curScore or "1000000"), UIUtils.bmfName_zhandouli)
    scoreLab:setAnchorPoint(0, 0)
    scoreLab:setPosition(454, 100)
    scoreLab:setScale(0.55)
    bg2:addChild(scoreLab)


    local id = info1.hero.id
    local heroD = tab.hero[id]
    if heroD == nil then
        heroD = tab.npcHero[id]
    end
    local dizuo = cc.Sprite:create("asset/uiother/dizuo/heroDizuo.png")
    dizuo:setScale(0.75, 0.75)
    dizuo:setPosition(95, 105)
    bg1:addChild(dizuo)

    
    -- local filename
    -- if info1.hero.skin then
    --     local heroSkinD = tab.heroSkin[info1.hero.skin]
    --     filename = "asset/uiother/shero/"..(heroSkinD["shero"] or heroD["shero"])..".png"
    -- else
    --     filename = "asset/uiother/shero/"..heroD["shero"]..".png"
    -- end
    -- local hero = cc.Sprite:create(filename)
    -- hero:setAnchorPoint(0.5, 0)
    -- hero:setScale(0.55, 0.55)
    -- hero:setPosition(95, 20)
    -- bg1:addChild(hero)

    local filename
    if info1.hero.skin then
        local heroSkinD = tab.heroSkin[info1.hero.skin]
        filename = heroSkinD["heroart"] or heroD["heroart"]
    else
        filename = heroD["heroart"]
    end

    if draw then
        local sp = mcMgr:createMovieClip("stop_"..filename)
        sp:setScale(0.75, 0.75)
        sp:setPosition(95, 45)
        bg1:addChild(sp)
        sp:play()
    else
        local sp = mcMgr:createMovieClip((win and "win_" or "dizzy_")..filename)
        sp:setScale(0.75, 0.75)
        sp:setPosition(95, 45)
        bg1:addChild(sp)
        sp:play()
    end

    local id = info2.hero.id
    local heroD = tab.hero[id]
    if heroD == nil then
        heroD = tab.npcHero[id]
    end
    local dizuo = cc.Sprite:create("asset/uiother/dizuo/heroDizuo.png")
    dizuo:setScale(-0.75, 0.75)
    dizuo:setPosition(740, 105)
    bg2:addChild(dizuo)

    -- local filename
    -- if info2.hero.skin then
    --     local heroSkinD = tab.heroSkin[info2.hero.skin]
    --     filename = "asset/uiother/shero/"..(heroSkinD["shero"] or heroD["shero"])..".png"
    -- else
    --     filename = "asset/uiother/shero/"..heroD["shero"]..".png"
    -- end
    -- local hero = cc.Sprite:create(filename)
    -- hero:setAnchorPoint(0.5, 0)
    -- hero:setScale(-0.55, 0.55)
    -- hero:setPosition(740, 20)
    -- bg2:addChild(hero)

    local filename
    if info2.hero.skin then
        local heroSkinD = tab.heroSkin[info2.hero.skin]
        filename = heroSkinD["heroart"] or heroD["heroart"]
    else
        filename = heroD["heroart"]
    end
    if draw then
        local sp = mcMgr:createMovieClip("stop_"..filename)
        sp:setScale(-0.75, 0.75)
        sp:setPosition(740, 45)
        bg2:addChild(sp)
        sp:play()
    else
        local sp = mcMgr:createMovieClip((win and "dizzy_" or "win_")..filename)
        sp:setScale(-0.75, 0.75)
        sp:setPosition(740, 45)
        bg2:addChild(sp)
        sp:play()
    end

    -- 兵团头像
    local teams = info1.team
    local data, quality
    local teamdata = reverse and self._data.rightData or self._data.leftData
    local dieIcon
    for i = 1, #teams do
        data = teams[i]
        local quality = BattleUtils.TEAM_QUALITY[data.stage]
        local icon = IconUtils:createTeamIconById({teamData = {id = data.id, star = data.star, level = data.level, ast = data.jx and 3 or 0},
        sysTeamData = tab.team[data.id], quality = quality[1], quaAddition = quality[2], eventStyle = 0})        
        icon:setScale(0.6)
        icon:setPosition(175 + (i - 1) * 66, 15)
        bg1:addChild(icon)
        if teamdata[i].die ~= -1 then
            icon:setSaturation(-100)
            dieIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI4_dead.png")
            dieIcon:setScale(0.8)
            dieIcon:setPosition(175 + (i - 1) * 66 + 32, 15 + 32)
            bg1:addChild(dieIcon)
        end
    end

    -- 兵团头像
    local teams = info2.team
    local data, quality
    local teamdata = reverse and self._data.leftData or self._data.rightData
    local dieIcon
    for i = 1, #teams do
        data = teams[i]
        local quality = BattleUtils.TEAM_QUALITY[data.stage]
        local icon = IconUtils:createTeamIconById({teamData = {id = data.id, star = data.star, level = data.level, ast = data.jx and 3 or 0},
        sysTeamData = tab.team[data.id], quality = quality[1], quaAddition = quality[2], eventStyle = 0})        
        icon:setScale(0.6)
        icon:setPosition(120 + (i - 1) * 66, 15)
        bg2:addChild(icon)
        if teamdata[i].die ~= -1 then
            icon:setSaturation(-100)
            dieIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI4_dead.png")
            dieIcon:setScale(0.8)
            dieIcon:setPosition(120 + (i - 1) * 66 + 32, 15 + 32)
            bg2:addChild(dieIcon)
        end
    end

    -- 动画
    self._replayBtn:setScale(0)
    self._quitBtn:setScale(0)
    bg1:setAnchorPoint(1, 0.5)
    bg2:setAnchorPoint(0, 0.5)

    local x1 = (1136 - MAX_SCREEN_WIDTH) * 0.5
    local x2 = 1136 - x1
    local y1 = bg1:getPositionY()
    bg1:setPositionX(x1)
    local y2 = bg2:getPositionY()
    bg2:setPositionX(x2)

    bg1:runAction(cc.EaseIn:create(cc.MoveTo:create(0.1, cc.p(x1 + 827, y1)), 2))
    bg2:runAction(cc.EaseIn:create(cc.MoveTo:create(0.1, cc.p(x2 - 827, y2)), 2))
    self._replayBtn:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.ScaleTo:create(0.1, 1)))
    self._quitBtn:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.ScaleTo:create(0.1, 1)))
    light:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.FadeIn:create(0.05), cc.FadeOut:create(0.7)))
end

function BattleResultShareWin.dtor()
    BattleResultShareWin = nil

end

return BattleResultShareWin