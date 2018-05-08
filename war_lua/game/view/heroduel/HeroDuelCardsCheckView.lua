--
-- Author: <ligen@playcrab.com>
-- Date: 2017-02-03 16:35:25
--
local HeroDuelCardsCheckView = class("HeroDuelCardsCheckView", BasePopView)
function HeroDuelCardsCheckView:ctor()
    HeroDuelCardsCheckView.super.ctor(self)

    self._hModel = self._modelMgr:getModel("HeroDuelModel")
end

function HeroDuelCardsCheckView:onInit()
    self:registerClickEventByName("bg", function()
        self:close()
        UIUtils:reloadLuaFile("heroduel.HeroDuelCardsCheckView")
    end)

    self._titleLabel = self:getUI("bg.layer.titleBg.titleLabel")
    self._titleLabel:setString("我的卡组")
    self._titleLabel:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)

--    UIUtils:setTitleFormat(self._titleLabel, 1)

    self._bgInner1 = self:getUI("bg.layer.bgInner1")
    self._bgInner2 = self:getUI("bg.layer.bgInner2")
    self._bgInner3 = self:getUI("bg.layer.bgInner3")
    self._bgInner4 = self:getUI("bg.layer.bgInner4")

    local tLabel1 = self._bgInner1:getChildByFullName("tLabel1")
    local tLabel2 = self._bgInner2:getChildByFullName("tLabel2")
    local tLabel3 = self._bgInner3:getChildByFullName("tLabel3")
    local tLabel4 = self._bgInner4:getChildByFullName("tLabel4")

    self:formatLabel(tLabel1, nil, cc.c3b(255, 251, 222), true)
    self:formatLabel(tLabel2, nil, cc.c3b(255, 251, 222), true)
    self:formatLabel(tLabel3, nil, cc.c3b(255, 251, 222), true)
    self:formatLabel(tLabel4, nil, cc.c3b(255, 251, 222), true)

    -- 英雄图标
    self._heroData = self._hModel:getCardsInfo().heros or {}
    for hI = 1, #self._heroData do
        local heroData = clone(tab:Hero(self._heroData[hI]))
        heroData.star = tab:HeroDuel(self._hModel:getWeekNum()).herostar or 0
        local heroIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
        heroIcon:setPosition(125+(hI-1)*110, 59)
        heroIcon:setScale(90 / heroIcon:getContentSize().width)
        self._bgInner1:addChild(heroIcon)

        self:registerClickEvent(heroIcon, function()
            local NewFormationIconView = require "game.view.formation.NewFormationIconView"
            local param = {
                isCustom = true, 
                iconType = NewFormationIconView.kIconTypeHero, 
                iconId = self._heroData[hI],
                formationType = self._modelMgr:getModel("FormationModel").kFormationTypeHeroDuel
                }
            dump(param)
            self._viewMgr:showDialog("formation.NewFormationDescriptionView", param, true)
        end)
    end

    -- 兵团图标
    self._teamsData = self._hModel:getCardsInfo().teams or {}

    local realW = 81
    local offsetX = 79
    local offsetY = 196
    for tI = 1, #self._teamsData do
        local teamId = tonumber(self._teamsData[tI].id)
    	local sysTeam = tab:Team(teamId)
        local heroDuelTab = tab:HeroDuel(self._hModel:getWeekNum())
        local quality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(heroDuelTab.teamquality)

        local ast = nil
        local aLv = nil
        if self._hModel:isTeamJx(teamId) then
            ast = 3
            aLvl = tab:HeroDuejx(teamId).aLvl
        end

        local inTeamData = {
            teamId=teamId,
            level=nil,
            star=heroDuelTab.teamstar,
            ast = ast,
            aLvl = aLvl
        }
        local param = {teamData = inTeamData, 
            sysTeamData = sysTeam,
            quality = quality[1], 
            quaAddition = 0,  
            eventStyle = 1,
            formationType = self._modelMgr:getModel("FormationModel").kFormationTypeHeroDuel,
            isCustom = true
        }
        local teamIcon = IconUtils:createTeamIconById(param)
        teamIcon:setPosition(offsetX+(tI-1)%6*(realW+8), offsetY-math.floor((tI-1)/6)*(realW+12))
        teamIcon:setScale(realW / teamIcon:getContentSize().width)
        self._bgInner2:addChild(teamIcon)

        local classIcon = cc.Sprite:createWithSpriteFrameName(sysTeam.classlabel .. ".png")
        classIcon:setAnchorPoint(0, 1)
        classIcon:setPosition(-2, teamIcon:getContentSize().height)
        classIcon:setScale(0.8)
        teamIcon:addChild(classIcon, 99)
    end

    -- 职业数量
    self._countLabelList = {}
    self._countLabelList[1] = self._bgInner3:getChildByFullName("countLabel1")
    self._countLabelList[2] = self._bgInner3:getChildByFullName("countLabel2")
    self._countLabelList[3] = self._bgInner3:getChildByFullName("countLabel3")
    self._countLabelList[4] = self._bgInner3:getChildByFullName("countLabel4")
    self._countLabelList[5] = self._bgInner3:getChildByFullName("countLabel5")

    local countLabelColor = {
       [1] = UIUtils.colorTable.ccUIBaseColor6,
       [2] = UIUtils.colorTable.ccUIBaseColor5,
       [3] = UIUtils.colorTable.ccUIBaseColor3,
       [4] = UIUtils.colorTable.ccUIBaseColor2,
       [5] = UIUtils.colorTable.ccUIBaseColor4
    }
    for cK, cV in pairs(self._countLabelList) do
        local cardsCount = self._hModel:getNumByClass(cK)
        self:formatLabel(cV, cardsCount, countLabelColor[cK], true)
    end

    -- 兵团规格数量
    self._volumeLabelList = {}
    self._volumeLabelList[5] = self._bgInner4:getChildByFullName("countLabel1")
    self._volumeLabelList[4] = self._bgInner4:getChildByFullName("countLabel2")
    self._volumeLabelList[3] = self._bgInner4:getChildByFullName("countLabel3")
    self._volumeLabelList[2] = self._bgInner4:getChildByFullName("countLabel4")
    
    for vK,vV in pairs(self._volumeLabelList) do
        local cardsCount = self._hModel:getNumByVolume(vK)
        self:formatLabel(vV, "x"..cardsCount, nil,true)
    end

end

function HeroDuelCardsCheckView:formatLabel(label, str, color, isOutLine)
    if str then
        label:setString(tostring(str))
    end

    if color then
        label:setColor(color)
    end

    if isOutLine then
        label:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end
end


return HeroDuelCardsCheckView