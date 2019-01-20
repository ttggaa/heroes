--
-- Author: <ligen@playcrab.com>
-- Date: 2017-01-24 15:38:59
--
local HeroDuelCardFinishView = class("HeroDuelCardFinishView", BasePopView)
function HeroDuelCardFinishView:ctor()
    HeroDuelCardFinishView.super.ctor(self)
    self._hModel = self._modelMgr:getModel("HeroDuelModel")
end

function HeroDuelCardFinishView:onInit()
    self:registerClickEventByName("bg", function()
        self:close()
        UIUtils:reloadLuaFile("heroduel.HeroDuelCardFinishView")
    end)

    local lightNode = self:getUI("bg.layer.lightNode")
    local lightMc = mcMgr:createViewMC("huodedaojudiguang_commonlight", true, false)
    lightMc:setPosition(lightNode:getContentSize().width*0.5, -10)
    lightNode:addChild(lightMc)

    self._bgTitle = self:getUI("bg.layer.bgTitle")
    self._bgTitle:setScale(1.3)
    self._bgTitle:setVisible(false)

    local heroNode = self:getUI("bg.layer.heroNode")
    local teamNode = self:getUI("bg.layer.teamNode")

    local cardsInfo = self._hModel:getCardsInfo()
    -- 英雄图标
    self._heroData = cardsInfo.heros or {}
    for hI = 1, #self._heroData do
        local heroData = clone(tab:Hero(self._heroData[hI]))
        heroData.star = tab:HeroDuel(self._hModel:getWeekNum()).herostar or 0
        local heroIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
        heroIcon:setPosition(60+(hI-1)*100, 61)
        heroIcon:setScale(90 / heroIcon:getContentSize().width)
        heroNode:addChild(heroIcon)

        self:registerClickEvent(heroIcon, function()
            local NewFormationIconView = require "game.view.formation.NewFormationIconView"
            local param = {
                isCustom = true, 
                iconType = NewFormationIconView.kIconTypeHero, 
                iconId = self._heroData[hI],
                formationType = self._modelMgr:getModel("FormationModel").kFormationTypeHeroDuel
            }
            self._viewMgr:showDialog("formation.NewFormationDescriptionView", param, true)
        end)
    end

    -- 兵团图标
    self._teamsData = cardsInfo.teams or {}

    local realW = 81
    local offsetX = 10
    local offsetY = 108
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
            aLvl = aLvl,
            stage = heroDuelTab.teamquality
            }
        local param = {teamData = inTeamData, 
            sysTeamData = sysTeam,
            quality = quality[1], 
            quaAddition = 0,  
            eventStyle = 2,
            formationType = self._modelMgr:getModel("FormationModel").kFormationTypeHeroDuel,
            isCustom = true,
            isHeroDuel = 1
        }
        local teamIcon = IconUtils:createTeamIconById(param)
        teamIcon:setPosition(offsetX+(tI-1)%8*(realW+3), offsetY-math.floor((tI-1)/8)*(realW+12))
        teamIcon:setScale(realW / teamIcon:getContentSize().width)
        teamNode:addChild(teamIcon)

        local className = TeamUtils:getClassIconNameByTeamD(inTeamData, "classlabel", sysTeam)
        local classIcon = cc.Sprite:createWithSpriteFrameName(className .. ".png")
        classIcon:setAnchorPoint(0, 1)
        classIcon:setPosition(-2, teamIcon:getContentSize().height)
        classIcon:setScale(0.8)
        teamIcon:addChild(classIcon, 99)
    end
end

function HeroDuelCardFinishView:onPopEnd()
    self._bgTitle:setVisible(true)
    
    self._bgTitle:runAction(cc.Sequence:create(
        cc.EaseOut:create(cc.ScaleTo:create(0.1, 0.8), 3),
        cc.EaseOut:create(cc.ScaleTo:create(0.1, 1), 3)
    ))
end

return HeroDuelCardFinishView