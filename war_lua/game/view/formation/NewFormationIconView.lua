--[[
    Filename:    NewFormationIconView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-02-25 15:19:53
    Description: File description
--]]
local FormationModel = require("game.model.FormationModel")

local NewFormationIconView = class("NewFormationIconView", BaseMvcs , BaseEvent, function()
    return ccui.Widget:create()
end)

NewFormationIconView.kIconTypeTeam = 1                  --玩家兵团
NewFormationIconView.kIconTypeHero = 2                  --玩家英雄
NewFormationIconView.kIconTypeInstanceTeam = 3          --副本兵团
NewFormationIconView.kIconTypeInstanceHero = 4          --副本英雄
NewFormationIconView.kIconTypeArenaTeam = 5             --竞技场兵团
NewFormationIconView.kIconTypeArenaHero = 6             --竞技场英雄
NewFormationIconView.kIconTypeAiRenMuWuTeam = 7         --矮人宝物兵团
NewFormationIconView.kIconTypeAiRenMuWuHero = 8         --矮人宝物英雄
NewFormationIconView.kIconTypeZombieTeam = 9            --阴森墓穴兵团
NewFormationIconView.kIconTypeZombieHero = 10           --阴森墓穴英雄
NewFormationIconView.kIconTypeDragonTeam = 11           --龙之国兵团
NewFormationIconView.kIconTypeDragonHero = 12           --龙之国英雄
NewFormationIconView.kIconTypeCrusadeTeam = 13          --远征兵团
NewFormationIconView.kIconTypeCrusadeHero = 14          --远征英雄
NewFormationIconView.kIconTypeLocalTeam = 15            --本地数据兵团
NewFormationIconView.kIconTypeLocalHero = 16            --本地数据英雄
NewFormationIconView.kIconTypeGuildTeam = 17            --联盟兵团
NewFormationIconView.kIconTypeGuildHero = 18            --联盟英雄
NewFormationIconView.kIconTypeMFTeam = 19               --航海兵团
NewFormationIconView.kIconTypeMFHero = 20               --航海英雄
NewFormationIconView.kIconTypeCloudTeam = 21            --云中城兵团
NewFormationIconView.kIconTypeCloudHero = 22            --云中城英雄
NewFormationIconView.kIconTypeAdventureTeam = 23        --大富翁兵团
NewFormationIconView.kIconTypeAdventureHero = 24        --大富翁英雄
NewFormationIconView.kIconTypeTrainingTeam = 25         --训练所兵团
NewFormationIconView.kIconTypeTrainingHero = 26         --训练所英雄
NewFormationIconView.kIconTypeElementalTeam = 27        --元素位面兵团
NewFormationIconView.kIconTypeElementalHero = 28        --元素位面英雄
NewFormationIconView.kIconTypeWeaponTeam = 29        --元素位面兵团
NewFormationIconView.kIconTypeWeaponHero = 30        --元素位面英雄
NewFormationIconView.kIconTypeCrossPKTeam = 31        --元素位面英雄
NewFormationIconView.kIconTypeCrossPKHero = 32        --元素位面英雄
NewFormationIconView.kIconTypeClimbTowerTeam = 33         -- 无尽炼狱
NewFormationIconView.kIconTypeClimbTowerHero = 34         -- 无尽炼狱
NewFormationIconView.kIconTypeStakeAtk1Team = 35         -- 木桩
NewFormationIconView.kIconTypeStakeAtk1Hero = 36         -- 木桩
NewFormationIconView.kIconTypeProfessionTeam = 37       -- pve 军团试炼
NewFormationIconView.kIconTypeProfessionHero = 38

NewFormationIconView.kIconTypeHireTeam = 10000          --玩家雇佣兵团
NewFormationIconView.kIconTypeIns = 10001          --玩家雇佣兵团

NewFormationIconView.kIconStateImage = 10
NewFormationIconView.kIconStateBody = 11

NewFormationIconView.kTeamScale = 1.0
NewFormationIconView.kTeamSpecialScale = 1.0
NewFormationIconView.kHeroScale = 1.0

NewFormationIconView.kTagTeamNumberBg = 1000
NewFormationIconView.kTagTeamNumber = 2000
NewFormationIconView.kTagTeamClass = 3000
NewFormationIconView.kTagTeamFlagRed = 4000
NewFormationIconView.kTagTeamFlagBlue = 5000
NewFormationIconView.kTagTeamX = 6000
NewFormationIconView.kTagHireTeam = 7000

NewFormationIconView.kTagTeamFlagHeroHelp = 6000
NewFormationIconView.kTagTeamFlagNextHeroHelp = 6001
NewFormationIconView.kTagTeamFlagDoubleHeroHelp = 6002
NewFormationIconView.kTagTeamScenarioHero = 6003

function NewFormationIconView:ctor(params)
    NewFormationIconView.super.ctor(self)
    self._formationModel = self._modelMgr:getModel("FormationModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._heroModel = self._modelMgr:getModel("HeroModel")
    self._leagueModel = self._modelMgr:getModel("LeagueModel")
    self._heroDuelModel = self._modelMgr:getModel("HeroDuelModel")
    --self._crusadeModel = self._modelMgr:getModel("CrusadeModel")
    --self._arenaModel = self._modelMgr:getModel("ArenaModel")
    --self._guildMapModel = self._modelMgr:getModel("GuildMapModel")
    self._guildModel = self._modelMgr:getModel("GuildModel")
    self._weaponsModel = self._modelMgr:getModel("WeaponsModel")
    self._crossModel = self._modelMgr:getModel("CrossModel")

    self._iconType = params.iconType
    self._iconId = params.iconId
    self._iconSubtype = params.iconSubtype
    self._iconChangedId = self._iconId
    self._iconState = params.iconState
    self._formationType = params.formationType
    self._isCustom = params.isCustom
    self._isLocal = params.isLocal
    self._isScenarioHero = params.isScenarioHero
    self._container = params.container

    self._scheduler = cc.Director:getInstance():getScheduler()
    self._relationActionPosition = nil
    self._relationImages = {}

    self:setContentSize(90, 90)
    self:setAnchorPoint(cc.p(0.5, 0.5))

    self._updateFunctionMap = {
        -- left
        [NewFormationIconView.kIconTypeTeam] = handler(self, self.updateTeamInformation),
        [NewFormationIconView.kIconTypeHero] = handler(self, self.updateHeroInformation),
        [NewFormationIconView.kIconTypeHireTeam] = handler(self, self.updateHireTeamInformation),
        [NewFormationIconView.kIconTypeIns] = handler(self, self.updateInsInformation),
        -- right
        [NewFormationIconView.kIconTypeInstanceTeam] = handler(self, self.updateInstanceTeamInformation),
        [NewFormationIconView.kIconTypeInstanceHero] = handler(self, self.updateInstanceHeroInformation),
        [NewFormationIconView.kIconTypeArenaTeam] = handler(self, self.updateArenaTeamInformation),
        [NewFormationIconView.kIconTypeArenaHero] = handler(self, self.updateArenaHeroInformation),
        [NewFormationIconView.kIconTypeAiRenMuWuTeam] = handler(self, self.updateAiRenMuWuTeamInformation),
        [NewFormationIconView.kIconTypeAiRenMuWuHero] = handler(self, self.updateAiRenMuWuHeroInformation),
        [NewFormationIconView.kIconTypeZombieTeam] = handler(self, self.updateZombieTeamInformation),
        [NewFormationIconView.kIconTypeZombieHero] = handler(self, self.updateZombieHeroInformation),
        [NewFormationIconView.kIconTypeDragonTeam] = handler(self, self.updateDragonTeamInformation),
        [NewFormationIconView.kIconTypeDragonHero] = handler(self, self.updateDragonHeroInformation),
        [NewFormationIconView.kIconTypeCrusadeTeam] = handler(self, self.updateCrusadeTeamInformation),
        [NewFormationIconView.kIconTypeCrusadeHero] = handler(self, self.updateCrusadeHeroInformation),
        [NewFormationIconView.kIconTypeLocalTeam] = handler(self, self.updateLocalTeamInformation),
        [NewFormationIconView.kIconTypeLocalHero] = handler(self, self.updateLocalHeroInformation),
        [NewFormationIconView.kIconTypeGuildTeam] = handler(self, self.updateGuildTeamInformation),
        [NewFormationIconView.kIconTypeGuildHero] = handler(self, self.updateGuildHeroInformation),
        [NewFormationIconView.kIconTypeMFTeam] = handler(self, self.updateMFTeamInformation),
        [NewFormationIconView.kIconTypeMFHero] = handler(self, self.updateMFHeroInformation),
        [NewFormationIconView.kIconTypeCloudTeam] = handler(self, self.updateNpcTeamInformation),
        [NewFormationIconView.kIconTypeCloudHero] = handler(self, self.updateNpcHeroInformation),
        [NewFormationIconView.kIconTypeAdventureTeam] = handler(self, self.updateAdventureTeamInformation),
        [NewFormationIconView.kIconTypeAdventureHero] = handler(self, self.updateAdventureHeroInformation),
        [NewFormationIconView.kIconTypeTrainingTeam] = handler(self, self.updateNpcTeamInformation),
        [NewFormationIconView.kIconTypeTrainingHero] = handler(self, self.updateNpcHeroInformation),
        [NewFormationIconView.kIconTypeElementalTeam] = handler(self, self.updateElementalTeamInformation),
        [NewFormationIconView.kIconTypeElementalHero] = handler(self, self.updateElementalHeroInformation),
        [NewFormationIconView.kIconTypeWeaponTeam] = handler(self, self.updateWeaponTeamInformation),
        [NewFormationIconView.kIconTypeWeaponHero] = handler(self, self.updateWeaponHeroInformation),
        [NewFormationIconView.kIconTypeCrossPKTeam] = handler(self, self.updateCrossPKTeamInformation),
        [NewFormationIconView.kIconTypeCrossPKHero] = handler(self, self.updateCrossPKHeroInformation),
        [NewFormationIconView.kIconTypeClimbTowerTeam] = handler(self, self.updateClimbTowerTeamInformation),
        [NewFormationIconView.kIconTypeClimbTowerHero] = handler(self, self.updateClimbTowerHeroInformation),
        [NewFormationIconView.kIconTypeStakeAtk1Team] = handler(self, self.updateStakeAtk1TeamInformation),
        [NewFormationIconView.kIconTypeStakeAtk1Hero] = handler(self, self.updateStakeAtk1HeroInformation),
        [NewFormationIconView.kIconTypeProfessionTeam] = handler(self, self.updateInstanceTeamInformation),
        [NewFormationIconView.kIconTypeProfessionHero] = handler(self, self.updateInstanceHeroInformation),
    }

    self._layerItemImage = nil
    self._layerItemBody = nil

    local filterFileName = "globalImageUI4_dead.png"
    if self._formationType == self._formationModel.kFormationTypeGuild then
        filterFileName = "globalImageUI7_hurt.png"
    elseif self._formationType == self._formationModel.kFormationTypeCloud1 or
           self._formationType == self._formationModel.kFormationTypeCloud2 then
        filterFileName = "globalImageUI5_treasureLock.png"
    elseif self._formationType == self._formationModel.kFormationTypeLeague then
        filterFileName = "globalImageUI6_meiyoutu.png"
    elseif self._formationType == self._formationModel.kFormationTypeHeroDuel then
        filterFileName = "image_ban_forma.png"
    elseif self._formationType == self._formationModel.kFormationTypeAiRenMuWu or 
           self._formationType == self._formationModel.kFormationTypeZombie or
           self._formationType == self._formationModel.kFormationTypeCrossPKAtk1 or 
           self._formationType == self._formationModel.kFormationTypeCrossPKAtk2 or 
           self._formationType == self._formationModel.kFormationTypeCrossPKAtk3 or 
           self._formationType == self._formationModel.kFormationTypeCrossPKDef1 or 
           self._formationType == self._formationModel.kFormationTypeCrossPKDef2 or 
           self._formationType == self._formationModel.kFormationTypeCrossPKDef3 then
        filterFileName = "team_forbidden_forma.png"
    end
    self._imageFilter = ccui.ImageView:create(filterFileName, 1)
    self._imageFilter:setTouchEnabled(false)
    self._imageFilter:setVisible(false)
    self._imageFilter:setPosition(cc.p(49, 45))
    self:addChild(self._imageFilter, 20)

    if self._formationType == self._formationModel.kFormationTypeHeroDuel then
        self._imageLocked = ccui.ImageView:create("pokeImage_suo.png", 1)
        self._imageLocked:setTouchEnabled(false)
        self._imageLocked:setVisible(false)
        self._imageLocked:setPosition(cc.p(45, 70))
        self:addChild(self._imageLocked, 20)
    end

    if (self._formationType == self._formationModel.kFormationTypeElemental1 or
       self._formationType == self._formationModel.kFormationTypeElemental2 or
       self._formationType == self._formationModel.kFormationTypeElemental3 or
       self._formationType == self._formationModel.kFormationTypeElemental4 or
       self._formationType == self._formationModel.kFormationTypeElemental5 or
       self._formationType == self._formationModel.kFormationTypeCrusade) then

        self._imageLimit = ccui.ImageView:create("image_level_limit_forma.png", 1)
        self._imageLimit:setTouchEnabled(false)
        self._imageLimit:setVisible(false)
        self._imageLimit:setPosition(cc.p(45, 45))
        self:addChild(self._imageLimit, 20)

        self._isLimit = false

        self._imageUsed = ccui.ImageView:create("image_used_forma.png", 1)
        self._imageUsed:setTouchEnabled(false)
        self._imageUsed:setVisible(false)
        self._imageUsed:setPosition(cc.p(45, 45))
        self:addChild(self._imageUsed, 20)
    end

    --[[
    self._unloadMC = mcMgr:createViewMC("xiaoshi_selectedmissanim", false)
    self._unloadMC:setVisible(false)
    self._unloadMC:stop()
    self._unloadMC:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 1.2)
    self:addChild(self._unloadMC, 25)
    ]]

    local recommandFileName = "team_recommend_forma.png"
    if self._formationType == self._formationModel.kFormationTypeLeague or 
        self._formationType == self._formationModel.kFormationTypeStakeAtk1 then
        recommandFileName = "team_recommend1_forma.png"
    end
    self._imageRecommand = ccui.ImageView:create(recommandFileName, 1)
    --self._imageRecommand:setScale(0.8)
    self._imageRecommand:setTouchEnabled(false)
    self._imageRecommand:setVisible(false)
    self._imageRecommand:setPosition(cc.p(78, 40))
    self:addChild(self._imageRecommand, 20)

    if self._formationType == self._formationModel.kFormationTypeGodWar1 or 
       self._formationType == self._formationModel.kFormationTypeGodWar2 or
       self._formationType == self._formationModel.kFormationTypeGodWar3 or 
       self._formationType == self._formationModel.kFormationTypeCrossGodWar1 or 
       self._formationType == self._formationModel.kFormationTypeCrossGodWar2 or 
       self._formationType == self._formationModel.kFormationTypeCrossGodWar3 or 
       self._formationType == self._formationModel.kFormationTypeGloryArenaAtk1 or   
       self._formationType == self._formationModel.kFormationTypeGloryArenaAtk2 or   
       self._formationType == self._formationModel.kFormationTypeGloryArenaAtk3 or   
       self._formationType == self._formationModel.kFormationTypeGloryArenaDef1 or   
       self._formationType == self._formationModel.kFormationTypeGloryArenaDef2 or   
       self._formationType == self._formationModel.kFormationTypeGloryArenaDef3 then   
        self._imageFormationIndex = ccui.ImageView:create("index_1_forma.png", 1)
        self._imageFormationIndex:setTouchEnabled(false)
        self._imageFormationIndex:setVisible(false)
        self._imageFormationIndex:setPosition(cc.p(49, 30))
        self:addChild(self._imageFormationIndex, 20)
    end

    if self._formationType == self._formationModel.kFormationTypeCityBattle1 or 
       self._formationType == self._formationModel.kFormationTypeCityBattle2 or
       self._formationType == self._formationModel.kFormationTypeCityBattle3 or
       self._formationType == self._formationModel.kFormationTypeCityBattle4 then
        self._imageFormationIndex = ccui.ImageView:create("index_1_forma.png", 1)
        self._imageFormationIndex:setTouchEnabled(false)
        self._imageFormationIndex:setVisible(false)
        self._imageFormationIndex:setPosition(cc.p(50, 50))
        self:addChild(self._imageFormationIndex, 20)
    end
    if table.indexof(self._formationModel.kBackupFormation, self._formationType) then
        self._backupTagImage = ccui.ImageView:create("backup_img22.png", 1)
        self._backupTagImage:setTouchEnabled(false)
        self._backupTagImage:setVisible(true)
        self._backupTagImage:setPosition(cc.p(45, 45))
        self._backupTagImage:setVisible(false)
        self:addChild(self._backupTagImage, 20)
    end

    --[[
    self._labelRecommand = ccui.Text:create("推荐", UIUtils.ttfName, 24)
    self._labelRecommand:setAnchorPoint(cc.p(0, 0.5))
    self._labelRecommand:setPosition(cc.p(5, 13))
    self._labelRecommand:setColor(cc.c3b(255, 243, 121))
    self._labelRecommand:enableOutline(cc.c4b(146, 19, 5, 255), 3)
    self._imageRecommand:addChild(self._labelRecommand)
    ]]
    self:enableTouch(true)

    self:updateState(self._iconState, true)

    self:registerScriptHandler(function(state)
        if state == "enter" then
        elseif state == "exit" then
            self:clearRelationEffect()
        end 
    end)
end

function NewFormationIconView:clone()
    return NewFormationIconView.new({iconType = self._iconType, iconId = self._iconId, iconSubtype = self._iconSubtype, iconState = self._iconState, formationType = self._formationType, isCustom = self._isCustom, isLocal = self._isLocal, isScenarioHero = self._isScenarioHero, container = self._container})
end

function NewFormationIconView:setIconId(iconId)
    self._iconId = iconId
end

function NewFormationIconView:getIconId()
    return self._iconId
end

function NewFormationIconView:getIconType()
    return self._iconType
end

function NewFormationIconView:setIconSubtype(iconSubtype)
    self._iconSubtype = iconSubtype
end

function NewFormationIconView:getIconSubtype()
    return self._iconSubtype
end

function NewFormationIconView:getIconGrid()
    return self._iconGrid
end

function NewFormationIconView:setIconGrid(iconGrid)
    self._iconGrid = iconGrid
end

function NewFormationIconView:setCustom(isCustom)
    self._isCustom = isCustom
end

function NewFormationIconView:getCustom()
    return self._isCustom
end

function NewFormationIconView:setLocal(isLocal)
    self._isLocal = isLocal
end

function NewFormationIconView:getLocal()
    return self._isLocal
end

function NewFormationIconView:setScenarioHero(isScenarioHero)
    self._isScenarioHero = isScenarioHero
end

function NewFormationIconView:getBodyContentSize()
    if not self._layerItemBody then return cc.size(0, 0) end
    return self._layerItemBody:getContentSize()
end

function NewFormationIconView:relationEffectBreath(isBreath)
    if not self._layerItemBody then return end
    if isBreath then
        if self._breathing then return end
        self._breathTimerId = self._scheduler:scheduleScriptFunc(function(dt)
            if not self._breathOut then
                self._layerItemBody:setBrightness(80)
                self._breathOut = true
            else
                self._layerItemBody:setBrightness(0)
                self._breathOut = false
            end
        end, 0.4, false)
        self._breathing = true
    else
        if self._breathTimerId then 
            self._scheduler:unscheduleScriptEntry(self._breathTimerId)
            self._breathTimerId = nil
        end
        self._layerItemBody:setBrightness(0)
        self._breathOut = false
        self._breathing = false
    end
end

function NewFormationIconView:showRelationEffect(effects)
    if not self._layerItemBody then return end
    if not self._relationActionPosition then
        if self._iconType == NewFormationIconView.kIconTypeTeam then
            self._relationActionPosition = cc.p(self._layerItemBody:getContentSize().width / 2, self._layerItemBody:getContentSize().height - 20)
        else
            self._relationActionPosition = cc.p(self._layerItemBody:getContentSize().width / 2, self._layerItemBody:getContentSize().height - 30)
        end
    end
    self:clearRelationEffect()
    local actions = {}
    for _, v in ipairs(effects) do
        if not self._relationImages[v] then
            self._relationImages[v] = ccui.ImageView:create("guanlian_" .. v .. ".png", 1)
            self._relationImages[v]:setPosition(self._relationActionPosition)
            self._relationImages[v]:setVisible(false)
            self._layerItemBody:addChild(self._relationImages[v], 1000)
        end

        local action = cc.CallFunc:create(function()
            self._relationImages[v]:runAction(cc.Sequence:create({
            cc.CallFunc:create(function(sender)
                if sender then
                    sender:setVisible(true)
                    --sender:setOpacity(100)
                    sender:setPosition(self._relationActionPosition)
                end
            end),
            cc.EaseOut:create(cc.MoveBy:create(0.3, cc.p(0, 20)), 2), 
            cc.DelayTime:create(0.2), 
            cc.EaseIn:create(cc.Spawn:create(cc.MoveBy:create(0.3, cc.p(0, 20))--[[, cc.FadeOut:create(0.3)]]), 2), 
            cc.CallFunc:create(function(sender)
                if sender and self._layerItemBody then
                    sender:setVisible(false)
                end
            end)}))
        end)

        table.insert(actions, action)
        table.insert(actions, cc.DelayTime:create(1))
    end
    if #actions > 0 then
        self._layerItemBody:runAction(cc.Sequence:create(cc.Sequence:create(actions), cc.DelayTime:create(2 * #actions), cc.CallFunc:create(function()
                -- self:clearRelationEffect()
        end)))
    end
end

function NewFormationIconView:clearRelationEffect()
    self:relationEffectBreath(false)
    for k, v in pairs(self._relationImages) do
        v:stopAllActions()
        v:setVisible(false)
    end

    if self._layerItemBody then
        self._layerItemBody:stopAllActions()
    end
end

function NewFormationIconView:getClassPosition()
    if self._iconType ~= NewFormationIconView.kIconTypeTeam and self._iconType ~= NewFormationIconView.kIconTypeHireTeam then
        return {}
    end
    local teamTableData = nil
    if self._formationType == self._formationModel.kFormationTypeWeaponDef then
        return {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
    elseif not self._isCustom and (self._iconType == NewFormationIconView.kIconTypeTeam or self._iconType == NewFormationIconView.kIconTypeHireTeam) then
        teamTableData = tab:Team(self._iconId)
    elseif self._isCustom and self._formationType ~= self._formationModel.kFormationTypeHeroDuel then
        teamTableData = tab:Npc(self._iconId)
    else
        teamTableData = tab:Team(self._iconId)
    end
    if not teamTableData then print("invalid team icon id", self._iconId) return {} end
    if self._formationType == self._formationModel.kFormationTypeGodWar1 or
       self._formationType == self._formationModel.kFormationTypeGodWar2 or
       self._formationType == self._formationModel.kFormationTypeGodWar3 then
       return clone(tab:GodWarPosition(teamTableData.posclass).position)
    else
        return clone(tab:ClassPosition(teamTableData.posclass).position)
    end
end

function NewFormationIconView:showBackupTag( isShow )
    if self._backupTagImage then
        self._backupTagImage:setVisible(isShow)
    end
end

function NewFormationIconView:showFilter(isShow)
    if self._layerItemImage then
        self._layerItemImage:setSaturation(isShow and -100 or 0)
    end
    if self._imageFilter then
        self._imageFilter:setVisible(isShow)
    end
end
--[[
function NewFormationIconView:showFilter(isShow, index)
    if self._layerItemImage then
        self._layerItemImage:setSaturation(isShow and -100 or 0)
    end
    if self._imageFilter then
        if index then
            if self._formationType == self._formationModel.kFormationTypeGodWar1 or 
               self._formationType == self._formationModel.kFormationTypeGodWar2 or
               self._formationType == self._formationModel.kFormationTypeGodWar3 then
                self._imageFilter:loadTexture("index_" .. index .. "_forma.png", 1)
            end
        end
        self._imageFilter:setVisible(isShow)
    end
end
]]
--[[
function NewFormationIconView:showFilter(isShow, index)
    if self._layerItemImage then
        self._layerItemImage:setSaturation(isShow and -100 or 0)
    end
    if self._imageFilter then
        if index then
            if self._formationType == self._formationModel.kFormationTypeGodWar1 or 
               self._formationType == self._formationModel.kFormationTypeGodWar2 or
               self._formationType == self._formationModel.kFormationTypeGodWar3 then
                self._imageFilter:loadTexture("index_" .. index .. "_forma.png", 1)
            elseif self._formationType == self._formationModel.kFormationTypeCityBattle1 or 
               self._formationType == self._formationModel.kFormationTypeCityBattle2 or
               self._formationType == self._formationModel.kFormationTypeCityBattle3 or
               self._formationType == self._formationModel.kFormationTypeCityBattle4 then
                self._imageFilter:loadTexture("index_" .. index .. "_forma.png", 1)
            end
        end
        self._imageFilter:setVisible(isShow)
    end
end
]]
function NewFormationIconView:showRecommand(isShow)
    if self._imageRecommand then
        self._imageRecommand:setVisible(isShow)
    end
end

function NewFormationIconView:isShowFilter()
    return self._imageFilter:isVisible()
end

function NewFormationIconView:showLocked(isShow)
    if self._imageLocked then
        self._imageLocked:setVisible(isShow)
    end
end

function NewFormationIconView:showLimit(isShow)
    self._isLimit = isShow
    if self._layerItemImage then
        self._layerItemImage:setSaturation(isShow and -90 or 0)
    end
    if self._imageLimit then
        self._imageLimit:setVisible(isShow)
    end
end

function NewFormationIconView:showUsed(isShow)
    if self._layerItemImage then
        self._layerItemImage:setSaturation(isShow or self._isLimit and -90 or 0)
    end

    if self._imageUsed then
        self._imageUsed:setVisible(isShow)
    end
end

function NewFormationIconView:isShowLocked()
    return self._imageLocked and self._imageLocked:isVisible()
end

function NewFormationIconView:isShowLimit()
    return self._isLimit
    --return self._imageLimit and self._imageLimit:isVisible()
end

function NewFormationIconView:isShowUsed()
    return self._imageUsed and self._imageUsed:isVisible()
end

function NewFormationIconView:showRedFlag(isShow)
    local flagRed = self:getChildByTag(NewFormationIconView.kTagTeamFlagRed)
    local flagBlue = self:getChildByTag(NewFormationIconView.kTagTeamFlagBlue)

    if not (flagRed and flagBlue) then return end

    if self._layerItemImage then
        self._layerItemImage:setSaturation((isShow or flagBlue:isVisible()) and -50 or 0)
    end

    flagRed:setVisible(isShow)
end

function NewFormationIconView:showBlueFlag(isShow)
    local flagRed = self:getChildByTag(NewFormationIconView.kTagTeamFlagRed)
    local flagBlue = self:getChildByTag(NewFormationIconView.kTagTeamFlagBlue)

    if not (flagRed and flagBlue) then return end

    if self._layerItemImage then
        self._layerItemImage:setSaturation((isShow or flagRed:isVisible()) and -50 or 0)
    end

    flagBlue:setVisible(isShow)
end

function NewFormationIconView:showHeroHelpFlag(isShow)
    local flagHeroHelp = self:getChildByTag(NewFormationIconView.kTagTeamFlagHeroHelp)
    local flagNextHeroHelp = self:getChildByTag(NewFormationIconView.kTagTeamFlagNextHeroHelp)
    local flagDoubleHeroHelp = self:getChildByTag(NewFormationIconView.kTagTeamFlagDoubleHeroHelp)

    if flagHeroHelp then
        flagHeroHelp:setVisible(isShow)
    end

    if isShow then
        if flagNextHeroHelp then
            flagNextHeroHelp:setVisible(false)
        end

        if flagDoubleHeroHelp then
            flagDoubleHeroHelp:setVisible(false)
        end
    end
end

function NewFormationIconView:showNextHeroHelpFlag(isShow)
    local flagHeroHelp = self:getChildByTag(NewFormationIconView.kTagTeamFlagHeroHelp)
    local flagNextHeroHelp = self:getChildByTag(NewFormationIconView.kTagTeamFlagNextHeroHelp)
    local flagDoubleHeroHelp = self:getChildByTag(NewFormationIconView.kTagTeamFlagDoubleHeroHelp)

    if flagNextHeroHelp then
        flagNextHeroHelp:setVisible(isShow)
    end

    if isShow then
        if flagHeroHelp then
            flagHeroHelp:setVisible(false)
        end

        if flagDoubleHeroHelp then
            flagDoubleHeroHelp:setVisible(false)
        end
    end
end

function NewFormationIconView:showDoubleHeroHelpFlag(isShow)
    local flagHeroHelp = self:getChildByTag(NewFormationIconView.kTagTeamFlagHeroHelp)
    local flagNextHeroHelp = self:getChildByTag(NewFormationIconView.kTagTeamFlagNextHeroHelp)
    local flagDoubleHeroHelp = self:getChildByTag(NewFormationIconView.kTagTeamFlagDoubleHeroHelp)

    if flagDoubleHeroHelp then
        flagDoubleHeroHelp:setVisible(isShow)
    end

    if isShow then
        if flagHeroHelp then
            flagHeroHelp:setVisible(false)
        end

        if flagNextHeroHelp then
            flagNextHeroHelp:setVisible(false)
        end
    end
end

function NewFormationIconView:showScenarioHero(isShow)
    local flagScenarioHero = self:getChildByTag(NewFormationIconView.kTagTeamScenarioHero)
    if flagScenarioHero then
        flagScenarioHero:setVisible(isShow)
    end
end

function NewFormationIconView:showFormationIndexFlag(isShow, index, isFiltered)
    self:setSaturation(0)
    if self._layerItemImage then
        if isShow and isFiltered then
            self:setSaturation(-100)
        elseif isShow then
            self._layerItemImage:setSaturation(-50)
        else
            self._layerItemImage:setSaturation(0)
        end
    end

    if self._imageFormationIndex then
        if index then
            if self._formationType == self._formationModel.kFormationTypeGodWar1 or 
               self._formationType == self._formationModel.kFormationTypeGodWar2 or
               self._formationType == self._formationModel.kFormationTypeGodWar3 or 
               self._formationType == self._formationModel.kFormationTypeCrossGodWar1 or 
               self._formationType == self._formationModel.kFormationTypeCrossGodWar2 or 
               self._formationType == self._formationModel.kFormationTypeCrossGodWar3 or 
               self._formationType == self._formationModel.kFormationTypeGloryArenaAtk1 or 
               self._formationType == self._formationModel.kFormationTypeGloryArenaAtk2 or 
               self._formationType == self._formationModel.kFormationTypeGloryArenaAtk3 or 
               self._formationType == self._formationModel.kFormationTypeGloryArenaDef1 or 
               self._formationType == self._formationModel.kFormationTypeGloryArenaDef2 or 
               self._formationType == self._formationModel.kFormationTypeGloryArenaDef3 then 
                self._imageFormationIndex:loadTexture("index_" .. index .. "_forma.png", 1)
            elseif self._formationType == self._formationModel.kFormationTypeCityBattle1 or 
               self._formationType == self._formationModel.kFormationTypeCityBattle2 or
               self._formationType == self._formationModel.kFormationTypeCityBattle3 or
               self._formationType == self._formationModel.kFormationTypeCityBattle4 then
                --self._imageFormationIndex:loadTexture("already_loaded_" .. index .. "_forma.png", 1)
                self._imageFormationIndex:loadTexture("index_" .. index .. "_forma.png", 1)
            end
        end
        self._imageFormationIndex:setVisible(isShow)
    end
end

function NewFormationIconView:onUnload()
    --[[
    self:enableTouch(false)
    self._unloadMC:addEndCallback(function()
        self._unloadMC:stop()
        self._unloadMC:setVisible(false)
    end)

    if self._layerItemImage then
        self._layerItemImage:setVisible(false)
    end

    if self._layerItemBody then
        self._layerItemBody:setVisible(false)
    end

    self._unloadMC:setVisible(true)
    self._unloadMC:gotoAndPlay(0)
    ]]
end

function NewFormationIconView:onClickingBegan()
    if self._clicking or NewFormationIconView.kIconStateBody == self._iconState then return end
    self:runAction(cc.ScaleTo:create(0.1, 1.1))
    self._clicking = true
end

function NewFormationIconView:onClickingEnded()
    if not self._clicking or NewFormationIconView.kIconStateBody == self._iconState then self:setScale(1.0) return end
    self:runAction(cc.ScaleTo:create(0.05, 1.0))
    self._clicking = false
end

function NewFormationIconView:changeProfile(teamId)
    if (self._iconType ~= NewFormationIconView.kIconTypeTeam and self._iconType ~= NewFormationIconView.kIconTypeHireTeam) or self._iconChangedId == teamId then return end

    local teamData = nil
    if self._formationType == self._formationModel.kFormationTypeHeroDuel then
        teamData = clone(tab:Team(self._iconId))
        local heroDuelId = self._heroDuelModel:getWeekNum()
        local heroDuelTableData = tab:HeroDuel(heroDuelId)
        local awakingData = tab:HeroDuejx(self._iconId)
        if heroDuelTableData then
            teamData.star = heroDuelTableData.teamstar
            teamData.stage = heroDuelTableData.teamquality
            for i = 1, 4 do
                teamData["sl" .. i] = heroDuelTableData.teamskill[i]
            end
        end

        if awakingData then
            teamData.ast = 3
            teamData.aLvl = awakingData.aLvl
        end
    elseif (self._formationType == self._formationModel.kFormationTypeElemental1 or
       self._formationType == self._formationModel.kFormationTypeElemental2 or
       self._formationType == self._formationModel.kFormationTypeElemental3 or
       self._formationType == self._formationModel.kFormationTypeElemental4 or
       self._formationType == self._formationModel.kFormationTypeElemental5) and 
       self._iconType == NewFormationIconView.kIconTypeHireTeam then
       teamData = self._guildModel:getEnemyDataById(self._iconId, self._iconSubtype)
    else
        teamData = self._teamModel:getTeamAndIndexById(self._iconId)
    end

    if not teamData then print("invalid team icon id", self._iconId) end
    local teamTableData = tab:Team(teamId)
    if not teamTableData then print("invalid team change icon id", teamId) end
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)

    if self._layerItemImage then
        IconUtils:updateTeamIconByView(self._layerItemImage, {teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
    end

    if self._layerItemBody then
        local awakingTeamName, _, _, awakingTeamSteam, _ = TeamUtils:getTeamAwakingTab(teamData, teamId)
        self._layerItemBody:loadTexture(awakingTeamSteam .. ".png", 1)

        local teamNumBg = self._layerItemBody:getChildByTag(NewFormationIconView.kTagTeamNumberBg)
        local imageClass = self._layerItemBody:getChildByTag(NewFormationIconView.kTagTeamClass)
        local teamNumX = self._layerItemBody:getChildByTag(NewFormationIconView.kTagTeamX)
        if teamNumBg and imageClass and teamNumX then
            teamNumBg:setPosition(self._layerItemBody:getContentSize().width / 2 + teamNumBg:getContentSize().width / 2, 0)
            imageClass:setPosition(teamNumBg:getPositionX() - teamNumBg:getContentSize().width / 2 - 5, teamNumBg:getPositionY() + 6)
            teamNumX:setPosition(imageClass:getPositionX() + 30, -1)
        end

        local teamNum = self._layerItemBody:getChildByTag(NewFormationIconView.kTagTeamNumber)
        if teamNum then
            teamNum:setPosition(teamNumX:getPositionX() + teamNum:getContentSize().width, -1)
            teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
            teamNum:setString((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")))
        end

        local imageHire = self._layerItemBody:getChildByTag(NewFormationIconView.kTagHireTeam)
        if imageHire then
            imageHire:setPosition(teamNum:getPositionX() + imageHire:getContentSize().width, 2)
        end
    end

    self._iconChangedId = teamId
end

function NewFormationIconView:resetProfile()
    if (self._iconType ~= NewFormationIconView.kIconTypeTeam and self._iconType ~= NewFormationIconView.kIconTypeHireTeam) or self._iconChangedId == self._iconId then return end

    local teamData = nil
    if self._formationType == self._formationModel.kFormationTypeHeroDuel then
        teamData = clone(tab:Team(self._iconId))
        local heroDuelId = self._heroDuelModel:getWeekNum()
        local heroDuelTableData = tab:HeroDuel(heroDuelId)
        local awakingData = tab:HeroDuejx(self._iconId)
        if heroDuelTableData then
            teamData.star = heroDuelTableData.teamstar
            teamData.stage = heroDuelTableData.teamquality
            for i = 1, 4 do
                teamData["sl" .. i] = heroDuelTableData.teamskill[i]
            end
        end

        if awakingData then
            teamData.ast = 3
            teamData.aLvl = awakingData.aLvl
        end
    elseif (self._formationType == self._formationModel.kFormationTypeElemental1 or
       self._formationType == self._formationModel.kFormationTypeElemental2 or
       self._formationType == self._formationModel.kFormationTypeElemental3 or
       self._formationType == self._formationModel.kFormationTypeElemental4 or
       self._formationType == self._formationModel.kFormationTypeElemental5) and
       self._iconType == NewFormationIconView.kIconTypeHireTeam then
       teamData = self._guildModel:getEnemyDataById(self._iconId, self._iconSubtype)
    else
        teamData = self._teamModel:getTeamAndIndexById(self._iconId)
    end
    if not teamData then print("invalid team icon id", self._iconId) end
    local teamTableData = tab:Team(self._iconId)
    if not teamTableData then print("invalid team change icon id", teamId) end
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)

    if self._layerItemImage then
        IconUtils:updateTeamIconByView(self._layerItemImage, {teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
    end

    if self._layerItemBody then
        local awakingTeamName, _, _, awakingTeamSteam, _ = TeamUtils:getTeamAwakingTab(teamData, self._iconId)
        self._layerItemBody:loadTexture(awakingTeamSteam .. ".png", 1)

        local teamNumBg = self._layerItemBody:getChildByTag(NewFormationIconView.kTagTeamNumberBg)
        local imageClass = self._layerItemBody:getChildByTag(NewFormationIconView.kTagTeamClass)
        local teamNumX = self._layerItemBody:getChildByTag(NewFormationIconView.kTagTeamX)
        if teamNumBg and imageClass and teamNumX then
            teamNumBg:setPosition(self._layerItemBody:getContentSize().width / 2 + teamNumBg:getContentSize().width / 2, 0)
            imageClass:setPosition(teamNumBg:getPositionX() - teamNumBg:getContentSize().width / 2 - 5, teamNumBg:getPositionY() + 6)
            teamNumX:setPosition(imageClass:getPositionX() + 30, -5)
        end

        local teamNum = self._layerItemBody:getChildByTag(NewFormationIconView.kTagTeamNumber)
        if teamNum then
            teamNum:setPosition(teamNumX:getPositionX() + teamNum:getContentSize().width + 5, -1)
            teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
            teamNum:setString((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")))
        end

        local imageHire = self._layerItemBody:getChildByTag(NewFormationIconView.kTagHireTeam)
        if imageHire then
            imageHire:setPosition(teamNum:getPositionX() + imageHire:getContentSize().width, 2)
        end
    end

    self._iconChangedId = self._iconId
end

function NewFormationIconView:changeEnemyProfile(teamId)
    if self._iconType ~= NewFormationIconView.kIconTypeInstanceTeam and 
       self._iconType ~= NewFormationIconView.kIconTypeArenaTeam and
       self._iconType ~= NewFormationIconView.kIconTypeAiRenMuWuTeam and
       self._iconType ~= NewFormationIconView.kIconTypeZombieTeam and
       self._iconType ~= NewFormationIconView.kIconTypeDragonTeam and
       self._iconType ~= NewFormationIconView.kIconTypeCrusadeTeam and
       self._iconType ~= NewFormationIconView.kIconTypeLocalTeam and
       self._iconType ~= NewFormationIconView.kIconTypeGuildHero or
       self._iconType ~= NewFormationIconView.kIconTypeProfessionTeam or
       self._iconChangedId == teamId then return end

    local teamTableData = nil
    if self._iconType == NewFormationIconView.kIconTypeInstanceTeam or 
        self._iconType == NewFormationIconView.kIconTypeProfessionTeam then
        teamTableData = tab:Npc(teamId)
    elseif self._iconType == NewFormationIconView.kIconTypeArenaTeam then
        teamTableData = tab:Team(teamId)
    elseif self._iconType == NewFormationIconView.kIconTypeAiRenMuWuTeam then
        teamTableData = tab:Npc(teamId)
    elseif self._iconType == NewFormationIconView.kIconTypeZombieTeam then
        teamTableData = tab:Npc(teamId)
    elseif self._iconType == NewFormationIconView.kIconTypeDragonTeam then
        teamTableData = tab:Npc(teamId)
    elseif self._iconType == NewFormationIconView.kIconTypeCrusadeTeam then
        teamTableData = tab:Team(teamId)
    elseif self._iconType == NewFormationIconView.kIconTypeLocalTeam then
        teamTableData = tab:Team(teamId)
    elseif self._iconType == NewFormationIconView.kIconTypeGuildHero then
        teamTableData = tab:Team(teamId)
    end

    if not teamTableData then print("invalid team change icon id", teamId) end

    if self._layerItemBody then
        self._layerItemBody:loadTexture(TeamUtils.getNpcTableValueByTeam(teamTableData, "steam") .. ".png", 1)
        -- 变身的时候品质不变 bug#520
        -- local quality = self._teamModel:getTeamQualityByStage(teamTableData.stage)
        -- local teamNum = self._layerItemBody:getChildByTag(NewFormationIconView.kTagTeamNumber)
        -- teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        -- teamNum:setString((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")))
    end
    
    self._iconChangedId = teamId
end

--[=[
function NewFormationIconView:resetEnemyProfile()
    if self._iconType ~= NewFormationIconView.kIconTypeTeam or self._iconChangedId == self._iconId then return end

    local teamData = self._teamModel:getTeamAndIndexById(self._iconId)
    if not teamData then print("invalid team icon id", self._iconId) end
    local teamTableData = tab:Team(self._iconId)
    if not teamTableData then print("invalid team change icon id", teamId) end
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)
    IconUtils:updateTeamIconByView(self._layerItemImage, {teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})

    self._layerItemBody:loadTexture(TeamUtils.getNpcTableValueByTeam(teamTableData, "steam") .. ".png", 1)

    local teamNum = self._layerItemBody:getChildByTag(NewFormationIconView.kTagTeamNumber)
    teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
    teamNum:setString((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")))
    
    self._iconChangedId = self._iconId
end
]=]

function NewFormationIconView:isChangedProfile()
    return self._iconId ~= self._iconChangedId
end

function NewFormationIconView:getChangedId()
    return self._iconChangedId
end

function NewFormationIconView:isFromIconGrid()
    return not not self:getIconGrid()
end

function NewFormationIconView.getEnemyTeamTypeByFormationType(formationType)
    if formationType == FormationModel.kFormationTypeCommon then
        return NewFormationIconView.kIconTypeInstanceTeam
    elseif formationType == FormationModel.kFormationTypeArena or
           formationType == FormationModel.kFormationTypeArenaDef then
        return NewFormationIconView.kIconTypeArenaTeam
    elseif formationType == FormationModel.kFormationTypeAiRenMuWu then
        return NewFormationIconView.kIconTypeAiRenMuWuTeam
    elseif formationType == FormationModel.kFormationTypeZombie then
        return NewFormationIconView.kIconTypeZombieTeam
    elseif formationType == FormationModel.kFormationTypeDragon or
           formationType == FormationModel.kFormationTypeDragon1 or
           formationType == FormationModel.kFormationTypeDragon2 then
        return NewFormationIconView.kIconTypeDragonTeam
    elseif formationType == FormationModel.kFormationTypeCrusade then
        return NewFormationIconView.kIconTypeCrusadeTeam
    elseif formationType == FormationModel.kFormationTypeGuild or
           formationType == FormationModel.kFormationTypeGuildDef then
        return NewFormationIconView.kIconTypeGuildTeam
    elseif formationType == FormationModel.kFormationTypeMF or 
           formationType == FormationModel.kFormationTypeMFDef then
        return NewFormationIconView.kIconTypeMFTeam
    elseif formationType == FormationModel.kFormationTypeCloud1 or formationType == FormationModel.kFormationTypeCloud2 then
        return NewFormationIconView.kIconTypeCloudTeam
    elseif formationType == FormationModel.kFormationTypeAdventure then
        return NewFormationIconView.kIconTypeAdventureTeam
    elseif formationType == FormationModel.kFormationTypeTraining then
        return NewFormationIconView.kIconTypeTrainingTeam
    elseif formationType == FormationModel.kFormationTypeElemental1 or 
           formationType == FormationModel.kFormationTypeElemental2 or 
           formationType == FormationModel.kFormationTypeElemental3 or 
           formationType == FormationModel.kFormationTypeElemental4 or 
           formationType == FormationModel.kFormationTypeElemental5 then
        return NewFormationIconView.kIconTypeElementalTeam
    elseif formationType == FormationModel.kFormationTypeWeapon or 
           formationType == FormationModel.kFormationTypeWeaponDef then
        return NewFormationIconView.kIconTypeWeaponTeam
    elseif formationType == FormationModel.kFormationTypeCrossPKAtk1 or 
           formationType == FormationModel.kFormationTypeCrossPKAtk2 or 
           formationType == FormationModel.kFormationTypeCrossPKAtk3 or 
           formationType == FormationModel.kFormationTypeCrossPKDef1 or 
           formationType == FormationModel.kFormationTypeCrossPKDef2 or 
           formationType == FormationModel.kFormationTypeCrossPKDef3 or
           formationType == FormationModel.kFormationTypeCrossPKFight then
        return NewFormationIconView.kIconTypeCrossPKTeam
    elseif formationType == FormationModel.kFormationTypeClimbTower then
        return NewFormationIconView.kIconTypeClimbTowerTeam
    elseif formationType == FormationModel.kFormationTypeStakeAtk1 then
        return NewFormationIconView.kIconTypeStakeAtk1Team
    elseif formationType == FormationModel.kFormationTypeProfession1 or 
        formationType == FormationModel.kFormationTypeProfession2 or 
        formationType == FormationModel.kFormationTypeProfession3 or 
        formationType == FormationModel.kFormationTypeProfession4 or 
        formationType == FormationModel.kFormationTypeProfession5 then
        return NewFormationIconView.kIconTypeProfessionTeam
    end
end

function NewFormationIconView.getEnemyHeroTypeByFormationType(formationType)
    if formationType == FormationModel.kFormationTypeCommon then
        return NewFormationIconView.kIconTypeInstanceHero
    elseif formationType == FormationModel.kFormationTypeArena or
           formationType == FormationModel.kFormationTypeArenaDef then
        return NewFormationIconView.kIconTypeArenaHero
    elseif formationType == FormationModel.kFormationTypeAiRenMuWu then
        return NewFormationIconView.kIconTypeAiRenMuWuHero
    elseif formationType == FormationModel.kFormationTypeZombie then
        return NewFormationIconView.kIconTypeZombieHero
    elseif formationType == FormationModel.kFormationTypeDragon or
           formationType == FormationModel.kFormationTypeDragon1 or
           formationType == FormationModel.kFormationTypeDragon2 then
        return NewFormationIconView.kIconTypeDragonHero
    elseif formationType == FormationModel.kFormationTypeCrusade then
        return NewFormationIconView.kIconTypeCrusadeHero
    elseif formationType == FormationModel.kFormationTypeGuild or
           formationType == FormationModel.kFormationTypeGuildDef then
        return NewFormationIconView.kIconTypeGuildHero
    elseif formationType == FormationModel.kFormationTypeMF or
           formationType == FormationModel.kFormationTypeMFDef then
        return NewFormationIconView.kIconTypeMFHero
    elseif formationType == FormationModel.kFormationTypeCloud1 or formationType == FormationModel.kFormationTypeCloud2 then
        return NewFormationIconView.kIconTypeCloudHero
    elseif formationType == FormationModel.kFormationTypeAdventure then
        return NewFormationIconView.kIconTypeAdventureHero
    elseif formationType == FormationModel.kFormationTypeTraining then
        return NewFormationIconView.kIconTypeTrainingHero
    elseif formationType == FormationModel.kFormationTypeElemental1 or 
           formationType == FormationModel.kFormationTypeElemental2 or 
           formationType == FormationModel.kFormationTypeElemental3 or 
           formationType == FormationModel.kFormationTypeElemental4 or 
           formationType == FormationModel.kFormationTypeElemental5 then
        return NewFormationIconView.kIconTypeElementalHero
    elseif formationType == FormationModel.kFormationTypeWeapon or
           formationType == FormationModel.kFormationTypeWeaponDef then
        return NewFormationIconView.kIconTypeWeaponHero
    elseif formationType == FormationModel.kFormationTypeCrossPKAtk1 or 
           formationType == FormationModel.kFormationTypeCrossPKAtk2 or 
           formationType == FormationModel.kFormationTypeCrossPKAtk3 or 
           formationType == FormationModel.kFormationTypeCrossPKDef1 or 
           formationType == FormationModel.kFormationTypeCrossPKDef2 or 
           formationType == FormationModel.kFormationTypeCrossPKDef3 or
           formationType == FormationModel.kFormationTypeCrossPKFight then
        return NewFormationIconView.kIconTypeCrossPKHero
    elseif formationType == FormationModel.kFormationTypeClimbTower then
        return NewFormationIconView.kIconTypeClimbTowerHero
    elseif formationType == FormationModel.kFormationTypeStakeAtk1 then 
        return NewFormationIconView.kIconTypeStakeAtk1Hero
    elseif formationType == FormationModel.kFormationTypeProfession1 or 
        formationType == FormationModel.kFormationTypeProfession2 or 
        formationType == FormationModel.kFormationTypeProfession3 or 
        formationType == FormationModel.kFormationTypeProfession4 or 
        formationType == FormationModel.kFormationTypeProfession5 then
        return NewFormationIconView.kIconTypeProfessionHero
    end
end

function NewFormationIconView:isTeamSpecial()
    local specialTeamId = {
        107,
        507,
        71003071,
        71003091,
        71004151,
        71006151,
        71007151,
        71012131,
        71012151,
        72005051,
        72006051,
        72007051,
        73003201,
        73003301,
        73006501,
        73007403,
        73007404,
        79000001,
        79000002,
    }
    for _, id in ipairs(specialTeamId) do
        if id == self._iconId then
            return true
        end
    end
    return false
end

function NewFormationIconView:updateInformation(state)
    if not (self._updateFunctionMap and self._iconType) then return end
    local updateFunction = self._updateFunctionMap[self._iconType]
    if updateFunction and type(updateFunction) == "function" then
        updateFunction(state)
    end
end

function NewFormationIconView:updateTeamInformation(state)
    --print("NewFormationIconView:updateTeamInformation")
    if self._isCustom then 
        return self:updateCustomTeamInformation(state)
    end

    if self._isLocal then 
        return self:updateLocalTeamInformation(state)
    end

    state = state or self._iconState
    local teamData = self._teamModel:getTeamAndIndexById(self._iconId)
    if not teamData then 
        self._viewMgr:onLuaError("invalid team id:" .. self._iconId .. serialize(self._modelMgr:getModel("FormationModel"):getFormationData()))
    end
    local teamTableData = tab:Team(teamData.teamId)
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createTeamIconById({teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setVisible(false)
            --self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateTeamIconByView(self._layerItemImage, {teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
        end

        local imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        local className = TeamUtils:getClassIconNameByTeamD(teamData, "classlabel", teamTableData, true)
        if not imageClass then
            imageClass = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
            imageClass:setScale(0.7)
            imageClass:setPosition(13, 92)
            imageClass:setTag(NewFormationIconView.kTagTeamClass)
            self._layerItemImage:addChild(imageClass, 20)
        else
            imageClass:loadTexture(IconUtils.iconPath .. className .. ".png", 1)
        end
        imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)

        --[[
        self._layerItemBody = ccui.ImageView:create(TeamUtils.getNpcTableValueByTeam(teamTableData, "steam") .. ".png", 1)
        --self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setVisible(false)
        self._layerItemBody:setScale(0.8)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 1.3)
        self:addChild(self._layerItemBody)
        ]]

        local flagRed = self:getChildByTag(NewFormationIconView.kTagTeamFlagRed)
        if not flagRed then
            --flagRed = mcMgr:createViewMC("saijirediankuang_leaguerediantexiao", true, false, nil, RGBA8888)
            flagRed = ccui.ImageView:create("flag_dark_forma.png", 1)
            --flagRed:setScale(1.1)
            flagRed:setVisible(false)
            flagRed:setPosition(cc.p(45, 45))
            flagRed:setTag(NewFormationIconView.kTagTeamFlagRed)
            self:addChild(flagRed, 100)
        end

        local flagBlue = self:getChildByTag(NewFormationIconView.kTagTeamFlagBlue)
        if not flagBlue then
            --flagBlue = mcMgr:createViewMC("duanweirediankuang_leaguerediantexiao", true, false, nil, RGBA8888)
            flagBlue = ccui.ImageView:create("flag_light_forma.png", 1)
            --flagBlue:setScale(1.1)
            flagBlue:setVisible(false)
            flagBlue:setPosition(cc.p(45, 45))
            flagBlue:setTag(NewFormationIconView.kTagTeamFlagBlue)
            self:addChild(flagBlue, 100)
        end
    else
        local teamScale = NewFormationIconView.kTeamScale
        if self:isTeamSpecial() then
            teamScale = NewFormationIconView.kTeamSpecialScale
        end
        local awakingTeamName, _, _, awakingTeamSteam, _ = TeamUtils:getTeamAwakingTab(teamData)
        self._layerItemBody = ccui.ImageView:create(awakingTeamSteam .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(teamScale)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)

        local teamNumBg = ccui.ImageView:create("team_num_bg_forma.png", 1)
        teamNumBg:setScale(1 / teamScale)
        teamNumBg:setPosition(self._layerItemBody:getContentSize().width / 2 + teamNumBg:getContentSize().width / 2, 2)
        teamNumBg:setTag(NewFormationIconView.kTagTeamNumberBg)
        self._layerItemBody:addChild(teamNumBg, 5)

        local className = TeamUtils:getClassIconNameByTeamD(teamData, "classlabel", teamTableData, true)
        local imageClass = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
        imageClass:setScale(0.7 / teamScale)
        imageClass:setPosition(teamNumBg:getPositionX() - teamNumBg:getContentSize().width / 2 - 5, teamNumBg:getPositionY() + 6)
        imageClass:setTag(NewFormationIconView.kTagTeamClass)
        self._layerItemBody:addChild(imageClass, 20)

        local teamNumX = ccui.Text:create("X", UIUtils.ttfName, 14)
        teamNumX:setScale(1 / teamScale)
        teamNumX:setPosition(imageClass:getPositionX() + 30, -1)
        teamNumX:setTag(NewFormationIconView.kTagTeamX)
        teamNumX:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNumX:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNumX, 10)

        local teamNum = ccui.Text:create((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")), UIUtils.ttfName, 22)
        teamNum:setScale(1 / teamScale)
        teamNum:setPosition(teamNumX:getPositionX() + teamNum:getContentSize().width, -1)
        teamNum:setTag(NewFormationIconView.kTagTeamNumber)
        teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNum, 10)
    end
end

function NewFormationIconView:updateHireTeamInformation(state)
    --print("NewFormationIconView:updateHireTeamInformation")
    state = state or self._iconState
    local teamData = clone(self._guildModel:getEnemyDataById(self._iconId, self._iconSubtype))
    teamData.teamId = self._iconId
    if not teamData then 
        self._viewMgr:onLuaError("invalid team id:" .. self._iconId .. serialize(self._modelMgr:getModel("FormationModel"):getFormationData()))
    end
    local teamTableData = tab:Team(teamData.teamId)
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createTeamIconById({teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
            self._layerItemImage:setScale(0.8)
            self._layerItemImage:setVisible(false)
            self._layerItemImage:setPosition(cc.p(0, 10))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateTeamIconByView(self._layerItemImage, {teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
        end

        local labelUserName = self._layerItemImage.userName
        if labelUserName then
            if teamData.userName then
                labelUserName:setString(teamData.userName)
            else
                labelUserName:setVisible(false)
            end
        end

        local imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        local className = TeamUtils:getClassIconNameByTeamD(teamData, "classlabel", teamTableData, true)
        if not imageClass then
            imageClass = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
            imageClass:setScale(0.7)
            imageClass:setPosition(13, 92)
            imageClass:setTag(NewFormationIconView.kTagTeamClass)
            self._layerItemImage:addChild(imageClass, 20)
        else
            imageClass:loadTexture(IconUtils.iconPath .. className .. ".png", 1)
        end
        imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)

        --[[
        self._layerItemBody = ccui.ImageView:create(TeamUtils.getNpcTableValueByTeam(teamTableData, "steam") .. ".png", 1)
        --self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setVisible(false)
        self._layerItemBody:setScale(0.8)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 1.3)
        self:addChild(self._layerItemBody)
        ]]

        local flagRed = self:getChildByTag(NewFormationIconView.kTagTeamFlagRed)
        if not flagRed then
            --flagRed = mcMgr:createViewMC("saijirediankuang_leaguerediantexiao", true, false, nil, RGBA8888)
            flagRed = ccui.ImageView:create("flag_dark_forma.png", 1)
            --flagRed:setScale(1.1)
            flagRed:setVisible(false)
            flagRed:setPosition(cc.p(45, 45))
            flagRed:setTag(NewFormationIconView.kTagTeamFlagRed)
            self:addChild(flagRed, 100)
        end

        local flagBlue = self:getChildByTag(NewFormationIconView.kTagTeamFlagBlue)
        if not flagBlue then
            --flagBlue = mcMgr:createViewMC("duanweirediankuang_leaguerediantexiao", true, false, nil, RGBA8888)
            flagBlue = ccui.ImageView:create("flag_light_forma.png", 1)
            --flagBlue:setScale(1.1)
            flagBlue:setVisible(false)
            flagBlue:setPosition(cc.p(45, 45))
            flagBlue:setTag(NewFormationIconView.kTagTeamFlagBlue)
            self:addChild(flagBlue, 100)
        end
    else
        local teamScale = NewFormationIconView.kTeamScale
        if self:isTeamSpecial() then
            teamScale = NewFormationIconView.kTeamSpecialScale
        end
        local awakingTeamName, _, _, awakingTeamSteam, _ = TeamUtils:getTeamAwakingTab(teamData)
        self._layerItemBody = ccui.ImageView:create(awakingTeamSteam .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(teamScale)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)

        local teamNumBg = ccui.ImageView:create("team_num_bg_forma.png", 1)
        teamNumBg:setScale(1 / teamScale)
        teamNumBg:setPosition(self._layerItemBody:getContentSize().width / 2 + teamNumBg:getContentSize().width / 2, 2)
        teamNumBg:setTag(NewFormationIconView.kTagTeamNumberBg)
        self._layerItemBody:addChild(teamNumBg, 5)

        local className = TeamUtils:getClassIconNameByTeamD(teamData, "classlabel", teamTableData, true)
        local imageClass = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
        imageClass:setScale(0.7 / teamScale)
        imageClass:setPosition(teamNumBg:getPositionX() - teamNumBg:getContentSize().width / 2 - 5, teamNumBg:getPositionY() + 6)
        imageClass:setTag(NewFormationIconView.kTagTeamClass)
        self._layerItemBody:addChild(imageClass, 20)

        local teamNumX = ccui.Text:create("X", UIUtils.ttfName, 14)
        teamNumX:setScale(1 / teamScale)
        teamNumX:setPosition(imageClass:getPositionX() + 20, -1)
        teamNumX:setTag(NewFormationIconView.kTagTeamX)
        teamNumX:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNumX:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNumX, 10)

        local teamNum = ccui.Text:create((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")), UIUtils.ttfName, 22)
        teamNum:setScale(1 / teamScale)
        teamNum:setPosition(teamNumX:getPositionX() + teamNum:getContentSize().width, -1)
        teamNum:setTag(NewFormationIconView.kTagTeamNumber)
        teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNum, 10)

        local imageHire = ccui.ImageView:create("hire_team_tag_forma.png", 1)
        imageHire:setScale(1 / teamScale)
        imageHire:setPosition(teamNum:getPositionX() + imageHire:getContentSize().width, 2)
        imageHire:setTag(NewFormationIconView.kTagHireTeam)
        self._layerItemBody:addChild(imageHire, 10)
    end
end

function NewFormationIconView:updateCrossPKHeroInformation(state)
    --print("NewFormationIconView:updateCrossPKHeroInformation")
    state = state or self._iconState
    local heroTableData = clone(tab:Hero(self._iconId))
    if not heroTableData then print("invalid hero icon id", self._iconId) end
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createHeroIconById({sysHeroData = heroTableData})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateHeroIconByView(self._layerItemImage, {sysHeroData = heroTableData})
        end
        --[=[
        if not self._layerItemImage then
            self._layerItemImage = ccui.ImageView:create(IconUtils.iconPath .. heroTableData.herohead .. ".png")
            self._layerItemImage:setVisible(false)
            self._layerItemImage:setScale(0.8)
            self._layerItemImage:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
            --[[
            local heroIconBg = ccui.ImageView:create("globalImageUI4_heroBg1.png", 1)
            heroIconBg:setPosition(self._layerItemImage:getContentSize().width / 2, self._layerItemImage:getContentSize().height / 2)
            self._layerItemImage:addChild(heroIconBg)
            ]]
            self:addChild(self._layerItemImage)
        else
            self._layerItemImage:loadTexture(IconUtils.iconPath .. heroTableData.herohead .. ".png")
        end
        ]=]
    else
        self._layerItemBody = ccui.ImageView:create(heroTableData.shero .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(NewFormationIconView.kHeroScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 + 5)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)
    end
end

function NewFormationIconView:updateClimbTowerTeamInformation(state)
    --print("NewFormationIconView:updateNpcTeamInformation")
    state = state or self._iconState
    local teamTableData = tab:Npc(self._iconId)
    if not teamTableData then print("invalid team icon id", self._iconId) end
    local stage = teamTableData.stage
    local stageId = self._modelMgr:getModel("PurgatoryModel"):getStageId()
    local cfg = tab.purFight[stageId]
    if cfg then
        stage = cfg.teamquality
    end
    local quality = self._teamModel:getTeamQualityByStage(stage)
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createTeamIconById({teamData = {id = self._iconId, star = teamTableData.star}, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setVisible(false)
            --self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateTeamIconByView(self._layerItemImage, {teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
        end

    else
        local teamScale = NewFormationIconView.kTeamScale
        if self:isTeamSpecial() then
            teamScale = NewFormationIconView.kTeamSpecialScale
        end

        self._layerItemBody = ccui.ImageView:create(TeamUtils.getNpcTableValueByTeam(teamTableData, "steam") .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(teamScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        --self._layerItemBody:setScale(0.8)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)

        local teamNumBg = ccui.ImageView:create("team_num_bg_forma.png", 1)
        teamNumBg:setScale(1 / teamScale)
        teamNumBg:setPosition(self._layerItemBody:getContentSize().width / 2 - teamNumBg:getContentSize().width / 2, 0)
        teamNumBg:setTag(NewFormationIconView.kTagTeamNumberBg)
        self._layerItemBody:addChild(teamNumBg, 5)

        local className = TeamUtils:getNpcClassName(teamTableData)
        local imageClass = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
        imageClass:setScale(0.7 / teamScale)
        imageClass:setRotation3D(cc.Vertex3F(0, 180, 0))
        imageClass:setPosition(teamNumBg:getPositionX() + teamNumBg:getContentSize().width / 2 + 5, teamNumBg:getPositionY() + 6)
        imageClass:setTag(NewFormationIconView.kTagTeamClass)
        self._layerItemBody:addChild(imageClass, 20)

        local teamNumX = ccui.Text:create("X", UIUtils.ttfName, 14)
        teamNumX:setScale(1 / teamScale)
        teamNumX:setPosition(imageClass:getPositionX() - 30, -1)
        teamNumX:setTag(NewFormationIconView.kTagTeamX)
        teamNumX:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNumX:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNumX, 10)

        local teamNum = ccui.Text:create((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")), UIUtils.ttfName, 22)
        teamNum:setFlippedX(true)
        teamNum:setScale(1 / teamScale)
        teamNum:setPosition(teamNumX:getPositionX() - teamNum:getContentSize().width, -1)
        teamNum:setTag(NewFormationIconView.kTagTeamNumber)
        teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNum, 10)
    end
end

function NewFormationIconView:updateClimbTowerHeroInformation(state)
    --print("NewFormationIconView:updateCrossPKHeroInformation")
    state = state or self._iconState
    local heroTableData = clone(tab:Hero(self._iconId))
    if not heroTableData then print("invalid hero icon id", self._iconId) end
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createHeroIconById({sysHeroData = heroTableData})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateHeroIconByView(self._layerItemImage, {sysHeroData = heroTableData})
        end
    else
        self._layerItemBody = ccui.ImageView:create(heroTableData.shero .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(NewFormationIconView.kHeroScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 + 5)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)
    end
end

function NewFormationIconView:updateStakeAtk1TeamInformation( state )
    state = state or self._iconState

    local teamTableData = tab:Npc(self._iconId)
    if not teamTableData then print("invalid team icon id", self._iconId) end
    local quality = self._teamModel:getTeamQualityByStage(teamTableData.stage)
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createTeamIconById({teamData = {id = self._iconId, star = teamTableData.star}, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setVisible(false)
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateTeamIconByView(self._layerItemImage, {teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
        end
    else
        local teamScale = NewFormationIconView.kTeamScale
        if self:isTeamSpecial() then
            teamScale = NewFormationIconView.kTeamSpecialScale
        end

        self._layerItemBody = ccui.ImageView:create(TeamUtils.getNpcTableValueByTeam(teamTableData, "steam") .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(teamScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)

        local teamNumBg = ccui.ImageView:create("team_num_bg_forma.png", 1)
        teamNumBg:setScale(1 / teamScale)
        teamNumBg:setPosition(self._layerItemBody:getContentSize().width / 2 - teamNumBg:getContentSize().width / 2, 0)
        teamNumBg:setTag(NewFormationIconView.kTagTeamNumberBg)
        self._layerItemBody:addChild(teamNumBg, 5)

        local imageClass = ccui.ImageView:create(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
        imageClass:setScale(0.7 / teamScale)
        imageClass:setRotation3D(cc.Vertex3F(0, 180, 0))
        imageClass:setPosition(teamNumBg:getPositionX() + teamNumBg:getContentSize().width / 2 + 5, teamNumBg:getPositionY() + 6)
        imageClass:setTag(NewFormationIconView.kTagTeamClass)
        self._layerItemBody:addChild(imageClass, 20)

        local teamNumX = ccui.Text:create("X", UIUtils.ttfName, 14)
        teamNumX:setScale(1 / teamScale)
        teamNumX:setPosition(imageClass:getPositionX() - 30, -1)
        teamNumX:setTag(NewFormationIconView.kTagTeamX)
        teamNumX:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNumX:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNumX, 10)

        local teamNum = ccui.Text:create((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")), UIUtils.ttfName, 22)
        teamNum:setFlippedX(true)
        teamNum:setScale(1 / teamScale)
        teamNum:setPosition(teamNumX:getPositionX() - teamNum:getContentSize().width, -1)
        teamNum:setTag(NewFormationIconView.kTagTeamNumber)
        teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNum, 10)
    end
end

function NewFormationIconView:updateStakeAtk1HeroInformation( state )
    state = state or self._iconState
    local heroTableData = clone(tab:NpcHero(self._iconId))
    if not heroTableData then print("invalid hero icon id", self._iconId) end
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createHeroIconById({sysHeroData = heroTableData})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateHeroIconByView(self._layerItemImage, {sysHeroData = heroTableData})
        end
    else
        self._layerItemBody = ccui.ImageView:create(heroTableData.shero .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(NewFormationIconView.kHeroScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 + 5)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)
    end
end

function NewFormationIconView:updateInsInformation(state)
    --print("NewFormationIconView:updateTeamInformation")
    state = state or self._iconState
    --[[
    local weaponData = {
        exp = 0,
        lv = 0,
        score = 0,
        sp1 = {},
        sp2 = {},
        sp3 = {},
        sp4 = {},
        ss1 = 0,
        ss2 = 0,
        unlockIds = {},
    }
    if self._isCustom then 
        local weaponCustomTableData = tab:SiegeWeaponNpc(self._iconId)
        weaponData.lv = weaponCustomTableData.lv
        for i=1, 4 do
            if weaponCustomTableData["equip" .. i] then
                weaponData["sp" .. i] = {id = weaponCustomTableData["equip" .. i][1], lv = weaponCustomTableData["equip" .. i][2], score = weaponCustomTableData["equip" .. i][3]}
            end
        end
    else
        weaponData = self._weaponsModel:getWeaponsTypeDataById(self._iconId)
    end
    if not weaponData then 
        self._viewMgr:onLuaError("invalid weapon id:" .. self._iconId .. serialize(self._modelMgr:getModel("FormationModel"):getFormationData()))
    end
    ]]
    local weaponTableData = tab:SiegeWeapon(self._iconId)
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createWeaponsIconById({weaponsTab = weaponTableData, wType = weaponTableData.type, eventStyle = 0})
            self._layerItemImage:setScale(1.0)
            self._layerItemImage:setVisible(false)
            --self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateWeaponsIcon(self._layerItemImage, {weaponsTab = weaponTableData, wType = weaponTableData.type, eventStyle = 0})
        end
        --[[
        local imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        if not imageClass then
            imageClass = ccui.ImageView:create(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
            imageClass:setScale(0.7)
            imageClass:setPosition(13, 92)
            imageClass:setTag(NewFormationIconView.kTagTeamClass)
            self._layerItemImage:addChild(imageClass, 20)
        else
            imageClass:loadTexture(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
        end
        imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        ]]
        --[[
        self._layerItemBody = ccui.ImageView:create(TeamUtils.getNpcTableValueByTeam(teamTableData, "steam") .. ".png", 1)
        --self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setVisible(false)
        self._layerItemBody:setScale(0.8)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 1.3)
        self:addChild(self._layerItemBody)
        ]]
        --[[
        local flagRed = self:getChildByTag(NewFormationIconView.kTagTeamFlagRed)
        if not flagRed then
            --flagRed = mcMgr:createViewMC("saijirediankuang_leaguerediantexiao", true, false, nil, RGBA8888)
            flagRed = ccui.ImageView:create("flag_dark_forma.png", 1)
            --flagRed:setScale(1.1)
            flagRed:setVisible(false)
            flagRed:setPosition(cc.p(45, 45))
            flagRed:setTag(NewFormationIconView.kTagTeamFlagRed)
            self:addChild(flagRed, 100)
        end

        local flagBlue = self:getChildByTag(NewFormationIconView.kTagTeamFlagBlue)
        if not flagBlue then
            --flagBlue = mcMgr:createViewMC("duanweirediankuang_leaguerediantexiao", true, false, nil, RGBA8888)
            flagBlue = ccui.ImageView:create("flag_light_forma.png", 1)
            --flagBlue:setScale(1.1)
            flagBlue:setVisible(false)
            flagBlue:setPosition(cc.p(45, 45))
            flagBlue:setTag(NewFormationIconView.kTagTeamFlagBlue)
            self:addChild(flagBlue, 100)
        end
        ]]
    else
        local teamScale = 1.0--NewFormationIconView.kTeamScale
        self._layerItemBody = ccui.ImageView:create(weaponTableData.steam .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.3))
        self._layerItemBody:setScale(teamScale)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)
        --[=[
        local teamNumBg = ccui.ImageView:create("team_num_bg_forma.png", 1)
        teamNumBg:setScale(1 / teamScale)
        teamNumBg:setPosition(self._layerItemBody:getContentSize().width / 2 + teamNumBg:getContentSize().width / 2, 2)
        teamNumBg:setTag(NewFormationIconView.kTagTeamNumberBg)
        self._layerItemBody:addChild(teamNumBg, 5)

        local imageClass = ccui.ImageView:create(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
        imageClass:setScale(0.7 / teamScale)
        imageClass:setPosition(teamNumBg:getPositionX() - teamNumBg:getContentSize().width / 2 - 5, teamNumBg:getPositionY() + 6)
        imageClass:setTag(NewFormationIconView.kTagTeamClass)
        self._layerItemBody:addChild(imageClass, 20)

        local teamNumX = ccui.Text:create("X", UIUtils.ttfName, 14)
        teamNumX:setScale(1 / teamScale)
        teamNumX:setPosition(imageClass:getPositionX() + 30, -1)
        teamNumX:setTag(NewFormationIconView.kTagTeamX)
        teamNumX:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNumX:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNumX, 10)

        local teamNum = ccui.Text:create((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")), UIUtils.ttfName, 22)
        teamNum:setScale(1 / teamScale)
        teamNum:setPosition(teamNumX:getPositionX() + teamNum:getContentSize().width, -1)
        teamNum:setTag(NewFormationIconView.kTagTeamNumber)
        teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNum, 10)
        ]=]
    end
end

function NewFormationIconView:updateInstanceTeamInformation(state)
    --print("NewFormationIconView:updateInstanceTeamInformation")
    state = state or self._iconState
    local teamTableData = tab:Npc(self._iconId)
    if not teamTableData then print("invalid team icon id", self._iconId) end
    local quality = self._teamModel:getTeamQualityByStage(teamTableData.stage)
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createTeamIconById({teamData = {id = self._iconId, star = teamTableData.star}, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setVisible(false)
            --self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateTeamIconByView(self._layerItemImage, {teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
        end
        --[[
        local imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        if not imageClass then
            imageClass = ccui.ImageView:create(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
            imageClass:setScale(0.7)
            imageClass:setPosition(18, 92)
            imageClass:setTag(NewFormationIconView.kTagTeamClass)
            self._layerItemImage:addChild(imageClass, 20)
        else
            imageClass:loadTexture(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
        end
        imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        ]]
    else
        local teamScale = NewFormationIconView.kTeamScale
        if self:isTeamSpecial() then
            teamScale = NewFormationIconView.kTeamSpecialScale
        end

        self._layerItemBody = ccui.ImageView:create(TeamUtils.getNpcTableValueByTeam(teamTableData, "steam") .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(teamScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        --self._layerItemBody:setScale(0.8)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)

        local teamNumBg = ccui.ImageView:create("team_num_bg_forma.png", 1)
        teamNumBg:setScale(1 / teamScale)
        teamNumBg:setPosition(self._layerItemBody:getContentSize().width / 2 - teamNumBg:getContentSize().width / 2, 0)
        teamNumBg:setTag(NewFormationIconView.kTagTeamNumberBg)
        self._layerItemBody:addChild(teamNumBg, 5)

        local className = TeamUtils:getNpcClassName(teamTableData)
        local imageClass = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
        imageClass:setScale(0.7 / teamScale)
        imageClass:setRotation3D(cc.Vertex3F(0, 180, 0))
        imageClass:setPosition(teamNumBg:getPositionX() + teamNumBg:getContentSize().width / 2 + 5, teamNumBg:getPositionY() + 6)
        imageClass:setTag(NewFormationIconView.kTagTeamClass)
        self._layerItemBody:addChild(imageClass, 20)

        local teamNumX = ccui.Text:create("X", UIUtils.ttfName, 14)
        teamNumX:setScale(1 / teamScale)
        teamNumX:setPosition(imageClass:getPositionX() - 30, -1)
        teamNumX:setTag(NewFormationIconView.kTagTeamX)
        teamNumX:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNumX:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNumX, 10)

        local teamNum = ccui.Text:create((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")), UIUtils.ttfName, 22)
        teamNum:setFlippedX(true)
        teamNum:setScale(1 / teamScale)
        teamNum:setPosition(teamNumX:getPositionX() - teamNum:getContentSize().width, -1)
        teamNum:setTag(NewFormationIconView.kTagTeamNumber)
        teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNum, 10)

        --[[
        self._layerItemBody = ccui.ImageView:create(TeamUtils.getNpcTableValueByTeam(teamTableData, "steam") .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        self._layerItemBody:setVisible(false)
        self._layerItemBody:setScale(0.5)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self:addChild(self._layerItemBody)
        ]]
    end
end

function NewFormationIconView:updateArenaTeamInformation(state)
    --print("NewFormationIconView:updateArenaTeamInformation")
    state = state or self._iconState
    local teamData = self._modelMgr:getModel("ArenaModel"):getEnemyDataById(self._iconId)
    if not teamData then 
        self._viewMgr:onLuaError("invalid arena team id:" .. self._iconId)
    end
    local teamTableData = tab:Team(teamData.teamId)
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createTeamIconById({teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setVisible(false)
            --self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateTeamIconByView(self._layerItemImage, {teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
        end

        --[[
        local imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        if not imageClass then
            imageClass = ccui.ImageView:create(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
            imageClass:setScale(0.7)
            imageClass:setPosition(18, 92)
            imageClass:setTag(NewFormationIconView.kTagTeamClass)
            self._layerItemImage:addChild(imageClass, 20)
        else
            imageClass:loadTexture(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
        end
        imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        ]]
    else
        local teamScale = NewFormationIconView.kTeamScale
        if self:isTeamSpecial() then
            teamScale = NewFormationIconView.kTeamSpecialScale
        end

        self._layerItemBody = ccui.ImageView:create(TeamUtils.getNpcTableValueByTeam(teamTableData, "steam") .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(teamScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        --self._layerItemBody:setScale(0.8)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)

        local teamNumBg = ccui.ImageView:create("team_num_bg_forma.png", 1)
        teamNumBg:setScale(1 / teamScale)
        teamNumBg:setPosition(self._layerItemBody:getContentSize().width / 2 - teamNumBg:getContentSize().width / 2, 0)
        teamNumBg:setTag(NewFormationIconView.kTagTeamNumberBg)
        self._layerItemBody:addChild(teamNumBg, 5)

        local className = TeamUtils:getClassIconNameByTeamD(teamData, "classlabel", teamTableData, true)
        local imageClass = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
        imageClass:setScale(0.7 / teamScale)
        imageClass:setRotation3D(cc.Vertex3F(0, 180, 0))
        imageClass:setPosition(teamNumBg:getPositionX() + teamNumBg:getContentSize().width / 2 + 5, teamNumBg:getPositionY() + 6)
        imageClass:setTag(NewFormationIconView.kTagTeamClass)
        self._layerItemBody:addChild(imageClass, 20)

        local teamNumX = ccui.Text:create("X", UIUtils.ttfName, 14)
        teamNumX:setScale(1 / teamScale)
        teamNumX:setPosition(imageClass:getPositionX() - 30, -1)
        teamNumX:setTag(NewFormationIconView.kTagTeamX)
        teamNumX:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNumX:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNumX, 10)

        local teamNum = ccui.Text:create((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")), UIUtils.ttfName, 22)
        teamNum:setFlippedX(true)
        teamNum:setScale(1 / teamScale)
        teamNum:setPosition(teamNumX:getPositionX() - teamNum:getContentSize().width, -1)
        teamNum:setTag(NewFormationIconView.kTagTeamNumber)
        teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNum, 10)
    end
end

function NewFormationIconView:updateAiRenMuWuTeamInformation(state)
    --print("NewFormationIconView:updateTeamIconInformation")
    state = state or self._iconState
    local teamTableData = tab:Npc(self._iconId)
    if not teamTableData then print("invalid team icon id", self._iconId) end
    local quality = self._teamModel:getTeamQualityByStage(teamTableData.stage)
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createTeamIconById({teamData = {id = self._iconId, star = teamTableData.star}, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setVisible(false)
            --self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateTeamIconByView(self._layerItemImage, {teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
        end

        --[[
        local imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        if not imageClass then
            imageClass = ccui.ImageView:create(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
            imageClass:setScale(0.7)
            imageClass:setPosition(18, 92)
            imageClass:setTag(NewFormationIconView.kTagTeamClass)
            self._layerItemImage:addChild(imageClass, 20)
        else
            imageClass:loadTexture(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
        end
        imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        ]]
    else
        local teamScale = NewFormationIconView.kTeamScale
        if self:isTeamSpecial() then
            teamScale = NewFormationIconView.kTeamSpecialScale
        end

        self._layerItemBody = ccui.ImageView:create(TeamUtils.getNpcTableValueByTeam(teamTableData, "steam") .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(teamScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        --self._layerItemBody:setScale(0.8)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)

        local teamNumBg = ccui.ImageView:create("team_num_bg_forma.png", 1)
        teamNumBg:setScale(1 / teamScale)
        teamNumBg:setPosition(self._layerItemBody:getContentSize().width / 2 - teamNumBg:getContentSize().width / 2, 0)
        teamNumBg:setTag(NewFormationIconView.kTagTeamNumberBg)
        self._layerItemBody:addChild(teamNumBg, 5)

        local className = TeamUtils:getNpcClassName(teamTableData)
        local imageClass = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
        imageClass:setScale(0.7 / teamScale)
        imageClass:setRotation3D(cc.Vertex3F(0, 180, 0))
        imageClass:setPosition(teamNumBg:getPositionX() + teamNumBg:getContentSize().width / 2 + 5, teamNumBg:getPositionY() + 6)
        imageClass:setTag(NewFormationIconView.kTagTeamClass)
        self._layerItemBody:addChild(imageClass, 20)

        local teamNumX = ccui.Text:create("X", UIUtils.ttfName, 14)
        teamNumX:setScale(1 / teamScale)
        teamNumX:setPosition(imageClass:getPositionX() - 30, -1)
        teamNumX:setTag(NewFormationIconView.kTagTeamX)
        teamNumX:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNumX:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNumX, 10)

        local teamNum = ccui.Text:create((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")), UIUtils.ttfName, 22)
        teamNum:setFlippedX(true)
        teamNum:setScale(1 / teamScale)
        teamNum:setPosition(teamNumX:getPositionX() - teamNum:getContentSize().width, -1)
        teamNum:setTag(NewFormationIconView.kTagTeamNumber)
        teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNum, 10)
    end
end

function NewFormationIconView:updateZombieTeamInformation(state)
    --print("NewFormationIconView:updateZombieTeamInformation")
    state = state or self._iconState
    local teamTableData = tab:Npc(self._iconId)
    if not teamTableData then print("invalid team icon id", self._iconId) end
    local quality = self._teamModel:getTeamQualityByStage(teamTableData.stage)
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createTeamIconById({teamData = {id = self._iconId, star = teamTableData.star}, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setVisible(false)
            --self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateTeamIconByView(self._layerItemImage, {teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
        end

        --[[
        local imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        if not imageClass then
            imageClass = ccui.ImageView:create(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
            imageClass:setScale(0.7)
            imageClass:setPosition(18, 92)
            imageClass:setTag(NewFormationIconView.kTagTeamClass)
            self._layerItemImage:addChild(imageClass, 20)
        else
            imageClass:loadTexture(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
        end
        imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        ]]
    else
        local teamScale = NewFormationIconView.kTeamScale
        if self:isTeamSpecial() then
            teamScale = NewFormationIconView.kTeamSpecialScale
        end

        self._layerItemBody = ccui.ImageView:create(TeamUtils.getNpcTableValueByTeam(teamTableData, "steam") .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(teamScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        --self._layerItemBody:setScale(0.8)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)

        local teamNumBg = ccui.ImageView:create("team_num_bg_forma.png", 1)
        teamNumBg:setScale(1 / teamScale)
        teamNumBg:setPosition(self._layerItemBody:getContentSize().width / 2 - teamNumBg:getContentSize().width / 2, 0)
        teamNumBg:setTag(NewFormationIconView.kTagTeamNumberBg)
        self._layerItemBody:addChild(teamNumBg, 5)

        local className = TeamUtils:getNpcClassName(teamTableData)
        local imageClass = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
        imageClass:setScale(0.7 / teamScale)
        imageClass:setRotation3D(cc.Vertex3F(0, 180, 0))
        imageClass:setPosition(teamNumBg:getPositionX() + teamNumBg:getContentSize().width / 2 + 5, teamNumBg:getPositionY() + 6)
        imageClass:setTag(NewFormationIconView.kTagTeamClass)
        self._layerItemBody:addChild(imageClass, 20)

        local teamNumX = ccui.Text:create("X", UIUtils.ttfName, 14)
        teamNumX:setScale(1 / teamScale)
        teamNumX:setPosition(imageClass:getPositionX() - 30, -1)
        teamNumX:setTag(NewFormationIconView.kTagTeamX)
        teamNumX:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNumX:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNumX, 10)

        local teamNum = ccui.Text:create((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")), UIUtils.ttfName, 22)
        teamNum:setFlippedX(true)
        teamNum:setScale(1 / teamScale)
        teamNum:setPosition(teamNumX:getPositionX() - teamNum:getContentSize().width, -1)
        teamNum:setTag(NewFormationIconView.kTagTeamNumber)
        teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNum, 10)
    end
end

function NewFormationIconView:updateDragonTeamInformation(state)
    --print("NewFormationIconView:updateDragonTeamInformation")
    state = state or self._iconState
    local teamTableData = tab:Npc(self._iconId)
    if not teamTableData then print("invalid team icon id", self._iconId) end
    local quality = self._teamModel:getTeamQualityByStage(teamTableData.stage)
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createTeamIconById({teamData = {id = self._iconId, star = teamTableData.star}, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setVisible(false)
            --self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateTeamIconByView(self._layerItemImage, {teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
        end

        --[[
        local imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        if not imageClass then
            imageClass = ccui.ImageView:create(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
            imageClass:setScale(0.7)
            imageClass:setPosition(18, 92)
            imageClass:setTag(NewFormationIconView.kTagTeamClass)
            self._layerItemImage:addChild(imageClass, 20)
        else
            imageClass:loadTexture(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
        end
        imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        ]]
    else
        local teamScale = NewFormationIconView.kTeamScale
        if self:isTeamSpecial() then
            teamScale = NewFormationIconView.kTeamSpecialScale
        end

        self._layerItemBody = ccui.ImageView:create(TeamUtils.getNpcTableValueByTeam(teamTableData, "steam") .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(teamScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        --self._layerItemBody:setScale(0.8)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)

        local teamNumBg = ccui.ImageView:create("team_num_bg_forma.png", 1)
        teamNumBg:setScale(1 / teamScale)
        teamNumBg:setPosition(self._layerItemBody:getContentSize().width / 2 - teamNumBg:getContentSize().width / 2, 0)
        teamNumBg:setTag(NewFormationIconView.kTagTeamNumberBg)
        self._layerItemBody:addChild(teamNumBg, 5)

        local className = TeamUtils:getNpcClassName(teamTableData)
        local imageClass = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
        imageClass:setScale(0.7 / teamScale)
        imageClass:setRotation3D(cc.Vertex3F(0, 180, 0))
        imageClass:setPosition(teamNumBg:getPositionX() + teamNumBg:getContentSize().width / 2 + 5, teamNumBg:getPositionY() + 6)
        imageClass:setTag(NewFormationIconView.kTagTeamClass)
        self._layerItemBody:addChild(imageClass, 20)

        local teamNumX = ccui.Text:create("X", UIUtils.ttfName, 14)
        teamNumX:setScale(1 / teamScale)
        teamNumX:setPosition(imageClass:getPositionX() - 30, -1)
        teamNumX:setTag(NewFormationIconView.kTagTeamX)
        teamNumX:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNumX:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNumX, 10)

        local teamNum = ccui.Text:create((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")), UIUtils.ttfName, 22)
        teamNum:setFlippedX(true)
        teamNum:setScale(1 / teamScale)
        teamNum:setPosition(teamNumX:getPositionX() - teamNum:getContentSize().width, -1)
        teamNum:setTag(NewFormationIconView.kTagTeamNumber)
        teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNum, 10)
    end
end

function NewFormationIconView:updateCrusadeTeamInformation(state)
    --print("NewFormationIconView:updateCrusadeTeamInformation")
    state = state or self._iconState
    local teamData = self._modelMgr:getModel("CrusadeModel"):getEnemyTeamDataById(self._iconId)
    if not teamData then 
        self._viewMgr:onLuaError("invalid crusade team id:" .. self._iconId)
    end
    local teamTableData = tab:Team(teamData.teamId)
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createTeamIconById({teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setVisible(false)
            --self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateTeamIconByView(self._layerItemImage, {teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
        end

        --[[
        local imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        if not imageClass then
            imageClass = ccui.ImageView:create(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
            imageClass:setScale(0.7)
            imageClass:setPosition(18, 92)
            imageClass:setTag(NewFormationIconView.kTagTeamClass)
            self._layerItemImage:addChild(imageClass, 20)
        else
            imageClass:loadTexture(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
        end
        imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        ]]
    else
        local teamScale = NewFormationIconView.kTeamScale
        if self:isTeamSpecial() then
            teamScale = NewFormationIconView.kTeamSpecialScale
        end
        
        local awakingTeamName, _, _, awakingTeamSteam, _ = TeamUtils:getTeamAwakingTab(teamData)
        if not awakingTeamSteam then
            awakingTeamSteam = TeamUtils.getNpcTableValueByTeam(teamTableData, "steam")
        end
        self._layerItemBody = ccui.ImageView:create(awakingTeamSteam .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(teamScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        --self._layerItemBody:setScale(0.8)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)

        local teamNumBg = ccui.ImageView:create("team_num_bg_forma.png", 1)
        teamNumBg:setScale(1 / teamScale)
        teamNumBg:setPosition(self._layerItemBody:getContentSize().width / 2 - teamNumBg:getContentSize().width / 2, 0)
        teamNumBg:setTag(NewFormationIconView.kTagTeamNumberBg)
        self._layerItemBody:addChild(teamNumBg, 5)

        local className = TeamUtils:getClassIconNameByTeamD(teamData, "classlabel", teamTableData, true)
        local imageClass = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
        imageClass:setScale(0.7 / teamScale)
        imageClass:setRotation3D(cc.Vertex3F(0, 180, 0))
        imageClass:setPosition(teamNumBg:getPositionX() + teamNumBg:getContentSize().width / 2 + 5, teamNumBg:getPositionY() + 6)
        imageClass:setTag(NewFormationIconView.kTagTeamClass)
        self._layerItemBody:addChild(imageClass, 20)

        local teamNumX = ccui.Text:create("X", UIUtils.ttfName, 14)
        teamNumX:setScale(1 / teamScale)
        teamNumX:setPosition(imageClass:getPositionX() - 30, -1)
        teamNumX:setTag(NewFormationIconView.kTagTeamX)
        teamNumX:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNumX:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNumX, 10)

        local teamNum = ccui.Text:create((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")), UIUtils.ttfName, 22)
        teamNum:setFlippedX(true)
        teamNum:setScale(1 / teamScale)
        teamNum:setPosition(teamNumX:getPositionX() - teamNum:getContentSize().width, -1)
        teamNum:setTag(NewFormationIconView.kTagTeamNumber)
        teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNum, 10)
    end
end

function NewFormationIconView:updateLocalTeamInformation(state)
    --print("NewFormationIconView:updateLocalTeamInformation")
    state = state or self._iconState
    local teamTableData = tab:Team(self._iconId)
    if not teamTableData then print("invalid team icon id", self._iconId) end
    local quality = self._teamModel:getTeamQualityByStage(teamTableData.stage)
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createTeamIconById({teamData = {id = self._iconId, star = teamTableData.star}, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setVisible(false)
            --self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateTeamIconByView(self._layerItemImage, {teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
        end

        --[[
        local imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        if not imageClass then
            imageClass = ccui.ImageView:create(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
            imageClass:setScale(0.7)
            imageClass:setPosition(18, 92)
            imageClass:setTag(NewFormationIconView.kTagTeamClass)
            self._layerItemImage:addChild(imageClass, 20)
        else
            imageClass:loadTexture(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
        end
        imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        ]]
    else
        local teamScale = NewFormationIconView.kTeamScale
        if self:isTeamSpecial() then
            teamScale = NewFormationIconView.kTeamSpecialScale
        end

        self._layerItemBody = ccui.ImageView:create(TeamUtils.getNpcTableValueByTeam(teamTableData, "steam") .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(teamScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        --self._layerItemBody:setScale(0.8)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)

        local teamNumBg = ccui.ImageView:create("team_num_bg_forma.png", 1)
        teamNumBg:setScale(1 / teamScale)
        teamNumBg:setPosition(self._layerItemBody:getContentSize().width / 2 - teamNumBg:getContentSize().width / 2, 0)
        teamNumBg:setTag(NewFormationIconView.kTagTeamNumberBg)
        self._layerItemBody:addChild(teamNumBg, 5)

        local className = TeamUtils:getClassIconNameByTeamD(teamData, "classlabel", teamTableData, true)
        local imageClass = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
        imageClass:setScale(0.7 / teamScale)
        imageClass:setRotation3D(cc.Vertex3F(0, 180, 0))
        imageClass:setPosition(teamNumBg:getPositionX() + teamNumBg:getContentSize().width / 2 + 5, teamNumBg:getPositionY() + 6)
        imageClass:setTag(NewFormationIconView.kTagTeamClass)
        self._layerItemBody:addChild(imageClass, 20)

        local teamNumX = ccui.Text:create("X", UIUtils.ttfName, 14)
        teamNumX:setScale(1 / teamScale)
        teamNumX:setPosition(imageClass:getPositionX() - 30, -1)
        teamNumX:setTag(NewFormationIconView.kTagTeamX)
        teamNumX:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNumX:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNumX, 10)

        local teamNum = ccui.Text:create((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")), UIUtils.ttfName, 22)
        teamNum:setFlippedX(true)
        teamNum:setScale(1 / teamScale)
        teamNum:setPosition(teamNumX:getPositionX() - teamNum:getContentSize().width, -1)
        teamNum:setTag(NewFormationIconView.kTagTeamNumber)
        teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNum, 10)

        --[[
        self._layerItemBody = ccui.ImageView:create(TeamUtils.getNpcTableValueByTeam(teamTableData, "steam") .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        self._layerItemBody:setVisible(false)
        self._layerItemBody:setScale(0.5)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self:addChild(self._layerItemBody)
        ]]
    end
end

function NewFormationIconView:updateGuildTeamInformation(state)
    --print("NewFormationIconView:updateGuildTeamInformation")
    state = state or self._iconState
    local teamData = self._modelMgr:getModel("GuildMapModel"):getEnemyDataById(self._iconId)
    if not teamData then 
        self._viewMgr:onLuaError("invalid guild team id:" .. self._iconId)
    end
    local teamTableData = tab:Team(teamData.teamId)
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createTeamIconById({teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setVisible(false)
            --self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateTeamIconByView(self._layerItemImage, {teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
        end

        --[[
        local imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        if not imageClass then
            imageClass = ccui.ImageView:create(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
            imageClass:setScale(0.7)
            imageClass:setPosition(18, 92)
            imageClass:setTag(NewFormationIconView.kTagTeamClass)
            self._layerItemImage:addChild(imageClass, 20)
        else
            imageClass:loadTexture(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
        end
        imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        ]]
    else
        local teamScale = NewFormationIconView.kTeamScale
        if self:isTeamSpecial() then
            teamScale = NewFormationIconView.kTeamSpecialScale
        end

        local awakingTeamName, _, _, awakingTeamSteam, _ = TeamUtils:getTeamAwakingTab(teamData)
        if not awakingTeamSteam then
            awakingTeamSteam = TeamUtils.getNpcTableValueByTeam(teamTableData, "steam")
        end
        self._layerItemBody = ccui.ImageView:create(awakingTeamSteam .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(teamScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        --self._layerItemBody:setScale(0.8)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)

        local teamNumBg = ccui.ImageView:create("team_num_bg_forma.png", 1)
        teamNumBg:setScale(1 / teamScale)
        teamNumBg:setPosition(self._layerItemBody:getContentSize().width / 2 - teamNumBg:getContentSize().width / 2, 0)
        teamNumBg:setTag(NewFormationIconView.kTagTeamNumberBg)
        self._layerItemBody:addChild(teamNumBg, 5)

        local className = TeamUtils:getClassIconNameByTeamD(teamData, "classlabel", teamTableData, true)
        local imageClass = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
        imageClass:setScale(0.7 / teamScale)
        imageClass:setRotation3D(cc.Vertex3F(0, 180, 0))
        imageClass:setPosition(teamNumBg:getPositionX() + teamNumBg:getContentSize().width / 2 + 5, teamNumBg:getPositionY() + 6)
        imageClass:setTag(NewFormationIconView.kTagTeamClass)
        self._layerItemBody:addChild(imageClass, 20)

        local teamNumX = ccui.Text:create("X", UIUtils.ttfName, 14)
        teamNumX:setScale(1 / teamScale)
        teamNumX:setPosition(imageClass:getPositionX() - 30, -1)
        teamNumX:setTag(NewFormationIconView.kTagTeamX)
        teamNumX:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNumX:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNumX, 10)

        local teamNum = ccui.Text:create((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")), UIUtils.ttfName, 22)
        teamNum:setFlippedX(true)
        teamNum:setScale(1 / teamScale)
        teamNum:setPosition(teamNumX:getPositionX() - teamNum:getContentSize().width, -1)
        teamNum:setTag(NewFormationIconView.kTagTeamNumber)
        teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNum, 10)
    end
end

function NewFormationIconView:updateMFTeamInformation(state)
    --print("NewFormationIconView:updateMFTeamInformation")
    state = state or self._iconState
    local teamData = self._modelMgr:getModel("MFModel"):getEnemyDataById(self._iconId)
    if not teamData then 
        self._viewMgr:onLuaError("invalid MF team id:" .. self._iconId)
    end
    local teamTableData = tab:Team(teamData.teamId)
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createTeamIconById({teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setVisible(false)
            --self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateTeamIconByView(self._layerItemImage, {teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
        end

        --[[
        local imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        if not imageClass then
            imageClass = ccui.ImageView:create(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
            imageClass:setScale(0.7)
            imageClass:setPosition(18, 92)
            imageClass:setTag(NewFormationIconView.kTagTeamClass)
            self._layerItemImage:addChild(imageClass, 20)
        else
            imageClass:loadTexture(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
        end
        imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        ]]
    else
        local teamScale = NewFormationIconView.kTeamScale
        if self:isTeamSpecial() then
            teamScale = NewFormationIconView.kTeamSpecialScale
        end

        local awakingTeamName, _, _, awakingTeamSteam, _ = TeamUtils:getTeamAwakingTab(teamData)
        if not awakingTeamSteam then
            awakingTeamSteam = TeamUtils.getNpcTableValueByTeam(teamTableData, "steam")
        end
        self._layerItemBody = ccui.ImageView:create(awakingTeamSteam .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(teamScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        --self._layerItemBody:setScale(0.8)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)

        local teamNumBg = ccui.ImageView:create("team_num_bg_forma.png", 1)
        teamNumBg:setScale(1 / teamScale)
        teamNumBg:setPosition(self._layerItemBody:getContentSize().width / 2 - teamNumBg:getContentSize().width / 2, 0)
        teamNumBg:setTag(NewFormationIconView.kTagTeamNumberBg)
        self._layerItemBody:addChild(teamNumBg, 5)

        local className = TeamUtils:getNpcClassName(teamTableData)
        local imageClass = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
        imageClass:setScale(0.7 / teamScale)
        imageClass:setRotation3D(cc.Vertex3F(0, 180, 0))
        imageClass:setPosition(teamNumBg:getPositionX() + teamNumBg:getContentSize().width / 2 + 5, teamNumBg:getPositionY() + 6)
        imageClass:setTag(NewFormationIconView.kTagTeamClass)
        self._layerItemBody:addChild(imageClass, 20)

        local teamNumX = ccui.Text:create("X", UIUtils.ttfName, 14)
        teamNumX:setScale(1 / teamScale)
        teamNumX:setPosition(imageClass:getPositionX() - 30, -1)
        teamNumX:setTag(NewFormationIconView.kTagTeamX)
        teamNumX:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNumX:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNumX, 10)

        local teamNum = ccui.Text:create((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")), UIUtils.ttfName, 22)
        teamNum:setFlippedX(true)
        teamNum:setScale(1 / teamScale)
        teamNum:setPosition(teamNumX:getPositionX() - teamNum:getContentSize().width, -1)
        teamNum:setTag(NewFormationIconView.kTagTeamNumber)
        teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNum, 10)
    end
end

function NewFormationIconView:updateNpcTeamInformation(state)
    --print("NewFormationIconView:updateNpcTeamInformation")
    state = state or self._iconState
    local teamTableData = tab:Npc(self._iconId)
    if not teamTableData then print("invalid team icon id", self._iconId) end
    local quality = self._teamModel:getTeamQualityByStage(teamTableData.stage)
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createTeamIconById({teamData = {id = self._iconId, star = teamTableData.star}, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setVisible(false)
            --self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateTeamIconByView(self._layerItemImage, {teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
        end

        --[[
        local imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        if not imageClass then
            imageClass = ccui.ImageView:create(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
            imageClass:setScale(0.7)
            imageClass:setPosition(18, 92)
            imageClass:setTag(NewFormationIconView.kTagTeamClass)
            self._layerItemImage:addChild(imageClass, 20)
        else
            imageClass:loadTexture(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
        end
        imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        ]]
    else
        local teamScale = NewFormationIconView.kTeamScale
        if self:isTeamSpecial() then
            teamScale = NewFormationIconView.kTeamSpecialScale
        end

        self._layerItemBody = ccui.ImageView:create(TeamUtils.getNpcTableValueByTeam(teamTableData, "steam") .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(teamScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        --self._layerItemBody:setScale(0.8)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)

        local teamNumBg = ccui.ImageView:create("team_num_bg_forma.png", 1)
        teamNumBg:setScale(1 / teamScale)
        teamNumBg:setPosition(self._layerItemBody:getContentSize().width / 2 - teamNumBg:getContentSize().width / 2, 0)
        teamNumBg:setTag(NewFormationIconView.kTagTeamNumberBg)
        self._layerItemBody:addChild(teamNumBg, 5)

        local className = TeamUtils:getNpcClassName(teamTableData)
        local imageClass = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
        imageClass:setScale(0.7 / teamScale)
        imageClass:setRotation3D(cc.Vertex3F(0, 180, 0))
        imageClass:setPosition(teamNumBg:getPositionX() + teamNumBg:getContentSize().width / 2 + 5, teamNumBg:getPositionY() + 6)
        imageClass:setTag(NewFormationIconView.kTagTeamClass)
        self._layerItemBody:addChild(imageClass, 20)

        local teamNumX = ccui.Text:create("X", UIUtils.ttfName, 14)
        teamNumX:setScale(1 / teamScale)
        teamNumX:setPosition(imageClass:getPositionX() - 30, -1)
        teamNumX:setTag(NewFormationIconView.kTagTeamX)
        teamNumX:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNumX:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNumX, 10)

        local teamNum = ccui.Text:create((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")), UIUtils.ttfName, 22)
        teamNum:setFlippedX(true)
        teamNum:setScale(1 / teamScale)
        teamNum:setPosition(teamNumX:getPositionX() - teamNum:getContentSize().width, -1)
        teamNum:setTag(NewFormationIconView.kTagTeamNumber)
        teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNum, 10)
    end
end

function NewFormationIconView:updateElementalTeamInformation(state)
    --print("NewFormationIconView:updateElementalTeamInformation")
    state = state or self._iconState
    local teamTableData = tab:Npc(self._iconId)
    if not teamTableData then print("invalid team icon id", self._iconId) end
    local quality = self._teamModel:getTeamQualityByStage(teamTableData.stage)
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createTeamIconById({teamData = {id = self._iconId, star = teamTableData.star}, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setVisible(false)
            --self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateTeamIconByView(self._layerItemImage, {teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
        end

        --[[
        local imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        if not imageClass then
            imageClass = ccui.ImageView:create(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
            imageClass:setScale(0.7)
            imageClass:setPosition(18, 92)
            imageClass:setTag(NewFormationIconView.kTagTeamClass)
            self._layerItemImage:addChild(imageClass, 20)
        else
            imageClass:loadTexture(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
        end
        imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        ]]
    else
        local teamScale = NewFormationIconView.kTeamScale
        if self:isTeamSpecial() then
            teamScale = NewFormationIconView.kTeamSpecialScale
        end

        self._layerItemBody = ccui.ImageView:create(TeamUtils.getNpcTableValueByTeam(teamTableData, "steam") .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(teamScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        --self._layerItemBody:setScale(0.8)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)

        local teamNumBg = ccui.ImageView:create("team_num_bg_forma.png", 1)
        teamNumBg:setScale(1 / teamScale)
        teamNumBg:setPosition(self._layerItemBody:getContentSize().width / 2 - teamNumBg:getContentSize().width / 2, 0)
        teamNumBg:setTag(NewFormationIconView.kTagTeamNumberBg)
        self._layerItemBody:addChild(teamNumBg, 5)

        local className = TeamUtils:getNpcClassName(teamTableData)
        local imageClass = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
        imageClass:setScale(0.7 / teamScale)
        imageClass:setRotation3D(cc.Vertex3F(0, 180, 0))
        imageClass:setPosition(teamNumBg:getPositionX() + teamNumBg:getContentSize().width / 2 + 5, teamNumBg:getPositionY() + 6)
        imageClass:setTag(NewFormationIconView.kTagTeamClass)
        self._layerItemBody:addChild(imageClass, 20)

        local teamNumX = ccui.Text:create("X", UIUtils.ttfName, 14)
        teamNumX:setScale(1 / teamScale)
        teamNumX:setPosition(imageClass:getPositionX() - 30, -1)
        teamNumX:setTag(NewFormationIconView.kTagTeamX)
        teamNumX:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNumX:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNumX, 10)

        local teamNum = ccui.Text:create((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")), UIUtils.ttfName, 22)
        teamNum:setFlippedX(true)
        teamNum:setScale(1 / teamScale)
        teamNum:setPosition(teamNumX:getPositionX() - teamNum:getContentSize().width, -1)
        teamNum:setTag(NewFormationIconView.kTagTeamNumber)
        teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNum, 10)
    end
end

function NewFormationIconView:updateWeaponTeamInformation(state)
    --print("NewFormationIconView:updateWeaponTeamInformation")
    state = state or self._iconState
    local teamTableData = tab:Npc(self._iconId)
    if not teamTableData then print("invalid team icon id", self._iconId) end
    local quality = self._teamModel:getTeamQualityByStage(teamTableData.stage)
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createTeamIconById({teamData = {id = self._iconId, star = teamTableData.star}, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setVisible(false)
            --self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateTeamIconByView(self._layerItemImage, {teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
        end

        --[[
        local imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        if not imageClass then
            imageClass = ccui.ImageView:create(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
            imageClass:setScale(0.7)
            imageClass:setPosition(18, 92)
            imageClass:setTag(NewFormationIconView.kTagTeamClass)
            self._layerItemImage:addChild(imageClass, 20)
        else
            imageClass:loadTexture(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
        end
        imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        ]]
    else
        local teamScale = NewFormationIconView.kTeamScale
        if self:isTeamSpecial() then
            teamScale = NewFormationIconView.kTeamSpecialScale
        end

        self._layerItemBody = ccui.ImageView:create(TeamUtils.getNpcTableValueByTeam(teamTableData, "steam") .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(teamScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        --self._layerItemBody:setScale(0.8)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)

        local teamNumBg = ccui.ImageView:create("team_num_bg_forma.png", 1)
        teamNumBg:setScale(1 / teamScale)
        teamNumBg:setPosition(self._layerItemBody:getContentSize().width / 2 - teamNumBg:getContentSize().width / 2, 0)
        teamNumBg:setTag(NewFormationIconView.kTagTeamNumberBg)
        self._layerItemBody:addChild(teamNumBg, 5)

        local className = TeamUtils:getClassIconNameByTeamD(teamData, "classlabel", teamTableData, true)
        local imageClass = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
        imageClass:setScale(0.7 / teamScale)
        imageClass:setRotation3D(cc.Vertex3F(0, 180, 0))
        imageClass:setPosition(teamNumBg:getPositionX() + teamNumBg:getContentSize().width / 2 + 5, teamNumBg:getPositionY() + 6)
        imageClass:setTag(NewFormationIconView.kTagTeamClass)
        self._layerItemBody:addChild(imageClass, 20)

        local teamNumX = ccui.Text:create("X", UIUtils.ttfName, 14)
        teamNumX:setScale(1 / teamScale)
        teamNumX:setPosition(imageClass:getPositionX() - 30, -1)
        teamNumX:setTag(NewFormationIconView.kTagTeamX)
        teamNumX:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNumX:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNumX, 10)

        local teamNum = ccui.Text:create((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")), UIUtils.ttfName, 22)
        teamNum:setFlippedX(true)
        teamNum:setScale(1 / teamScale)
        teamNum:setPosition(teamNumX:getPositionX() - teamNum:getContentSize().width, -1)
        teamNum:setTag(NewFormationIconView.kTagTeamNumber)
        teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNum, 10)
    end
end

function NewFormationIconView:updateCustomTeamInformation(state)
    --print("NewFormationIconView:updateCustomTeamInformation")
    state = state or self._iconState
    local teamTableData = nil
    local className = nil
    if self._formationType == self._formationModel.kFormationTypeHeroDuel then
        teamTableData = clone(tab:Team(self._iconId))
        local heroDuelId = self._heroDuelModel:getWeekNum()
        local heroDuelTableData = tab:HeroDuel(heroDuelId)
        local awakingData = tab:HeroDuejx(self._iconId)
        if heroDuelTableData then
            teamTableData.star = heroDuelTableData.teamstar
            teamTableData.stage = heroDuelTableData.teamquality
            teamTableData.sl = {}
            for i = 1, 4 do
                teamTableData.sl[i] = heroDuelTableData.teamskill[i]
            end
        end
        className = TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel")
        if awakingData then
            teamTableData.ast = 3
            teamTableData.aLvl = awakingData.aLvl
            className = className .. "_awake"
        end
    else
        teamTableData = tab:Npc(self._iconId)
        className = TeamUtils:getNpcClassName(teamTableData)
    end
    if not teamTableData then print("invalid team icon id", self._iconId) end
    local quality = self._teamModel:getTeamQualityByStage(teamTableData.stage)
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createTeamIconById({teamData = {id = self._iconId, star = teamTableData.star, ast = teamTableData.ast, aLvl = teamTableData.aLvl}, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setVisible(false)
            --self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateTeamIconByView(self._layerItemImage, {teamData = {id = self._iconId, star = teamTableData.star, ast = teamTableData.ast, aLvl = teamTableData.aLvl}, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
        end

        local imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        if not imageClass then
            imageClass = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
            imageClass:setScale(0.7)
            imageClass:setPosition(13, 92)
            imageClass:setTag(NewFormationIconView.kTagTeamClass)
            self._layerItemImage:addChild(imageClass, 20)
        else
            imageClass:loadTexture(IconUtils.iconPath .. className .. ".png", 1)
        end
        imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)

        --[[
        self._layerItemBody = ccui.ImageView:create(TeamUtils.getNpcTableValueByTeam(teamTableData, "steam") .. ".png", 1)
        --self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setVisible(false)
        self._layerItemBody:setScale(0.8)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 1.3)
        self:addChild(self._layerItemBody)
        ]]
    else
        local teamScale = NewFormationIconView.kTeamScale
        if self:isTeamSpecial() then
            teamScale = NewFormationIconView.kTeamSpecialScale
        end
        if self._formationType == self._formationModel.kFormationTypeHeroDuel then
            local awakingTeamName, _, _, awakingTeamSteam, _ = TeamUtils:getTeamAwakingTab(teamTableData, self._iconId)
            self._layerItemBody = ccui.ImageView:create(awakingTeamSteam .. ".png", 1)
        else
            self._layerItemBody = ccui.ImageView:create(TeamUtils.getNpcTableValueByTeam(teamTableData, "steam") .. ".png", 1)
        end
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(teamScale)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)

        local teamNumBg = ccui.ImageView:create("team_num_bg_forma.png", 1)
        teamNumBg:setScale(1 / teamScale)
        teamNumBg:setPosition(self._layerItemBody:getContentSize().width / 2 + teamNumBg:getContentSize().width / 2, 0)
        teamNumBg:setTag(NewFormationIconView.kTagTeamNumberBg)
        self._layerItemBody:addChild(teamNumBg, 5)

        local imageClass = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
        imageClass:setScale(0.7 / teamScale)
        imageClass:setPosition(teamNumBg:getPositionX() - teamNumBg:getContentSize().width / 2 - 5, teamNumBg:getPositionY() + 6)
        imageClass:setTag(NewFormationIconView.kTagTeamClass)
        self._layerItemBody:addChild(imageClass, 20)

        local teamNumX = ccui.Text:create("X", UIUtils.ttfName, 14)
        teamNumX:setScale(1 / teamScale)
        teamNumX:setPosition(imageClass:getPositionX() + 30, -1)
        teamNumX:setTag(NewFormationIconView.kTagTeamX)
        teamNumX:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNumX:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNumX, 10)

        local teamNum = ccui.Text:create((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")), UIUtils.ttfName, 22)
        teamNum:setScale(1 / teamScale)
        teamNum:setPosition(teamNumX:getPositionX() + teamNum:getContentSize().width, -1)
        teamNum:setTag(NewFormationIconView.kTagTeamNumber)
        teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNum, 10)
    end
end

function NewFormationIconView:updateCrossPKTeamInformation(state)
    -- print("NewFormationIconView:updateCrossPKTeamInformation")
    state = state or self._iconState
    local teamData = self._crossModel:getEnemyDataById(self._iconId)
    if not teamData then print("invalid team icon id", self._iconId) end
    local teamTableData = tab:Team(self._iconId)
    if not teamTableData then print("invalid team icon id", self._iconId) end
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createTeamIconById({teamData = {id = self._iconId, star = teamTableData.star}, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setVisible(false)
            --self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateTeamIconByView(self._layerItemImage, {teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
        end
    else
        local teamScale = NewFormationIconView.kTeamScale
        if self:isTeamSpecial() then
            teamScale = NewFormationIconView.kTeamSpecialScale
        end

        local awakingTeamName, _, _, awakingTeamSteam, _ = TeamUtils:getTeamAwakingTab(teamData, self._iconId)
        self._layerItemBody = ccui.ImageView:create(awakingTeamSteam .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(teamScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        --self._layerItemBody:setScale(0.8)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)

        local teamNumBg = ccui.ImageView:create("team_num_bg_forma.png", 1)
        teamNumBg:setScale(1 / teamScale)
        teamNumBg:setPosition(self._layerItemBody:getContentSize().width / 2 - teamNumBg:getContentSize().width / 2, 0)
        teamNumBg:setTag(NewFormationIconView.kTagTeamNumberBg)
        self._layerItemBody:addChild(teamNumBg, 5)

        local className = TeamUtils:getClassIconNameByTeamD(teamData, "classlabel", teamTableData, true)
        local imageClass = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
        imageClass:setScale(0.7 / teamScale)
        imageClass:setRotation3D(cc.Vertex3F(0, 180, 0))
        imageClass:setPosition(teamNumBg:getPositionX() + teamNumBg:getContentSize().width / 2 + 5, teamNumBg:getPositionY() + 6)
        imageClass:setTag(NewFormationIconView.kTagTeamClass)
        self._layerItemBody:addChild(imageClass, 20)

        local teamNumX = ccui.Text:create("X", UIUtils.ttfName, 14)
        teamNumX:setScale(1 / teamScale)
        teamNumX:setPosition(imageClass:getPositionX() - 30, -1)
        teamNumX:setTag(NewFormationIconView.kTagTeamX)
        teamNumX:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNumX:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNumX, 10)

        local teamNum = ccui.Text:create((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")), UIUtils.ttfName, 22)
        teamNum:setFlippedX(true)
        teamNum:setScale(1 / teamScale)
        teamNum:setPosition(teamNumX:getPositionX() - teamNum:getContentSize().width, -1)
        teamNum:setTag(NewFormationIconView.kTagTeamNumber)
        teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNum, 10)
    end
end

function NewFormationIconView:updateAdventureTeamInformation(state)
    --print("NewFormationIconView:updateAdventureTeamInformation")
    state = state or self._iconState
    local teamData = self._modelMgr:getModel("AdventureModel"):getEnemyDataById(self._iconId)
    if not teamData then 
        self._viewMgr:onLuaError("invalid guild team id:" .. self._iconId)
    end
    local teamTableData = tab:Team(teamData.teamId)
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createTeamIconById({teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setVisible(false)
            --self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateTeamIconByView(self._layerItemImage, {teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
        end

        --[[
        local imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        if not imageClass then
            imageClass = ccui.ImageView:create(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
            imageClass:setScale(0.7)
            imageClass:setPosition(18, 92)
            imageClass:setTag(NewFormationIconView.kTagTeamClass)
            self._layerItemImage:addChild(imageClass, 20)
        else
            imageClass:loadTexture(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
        end
        imageClass = self._layerItemImage:getChildByTag(NewFormationIconView.kTagTeamClass)
        ]]
    else
        local teamScale = NewFormationIconView.kTeamScale
        if self:isTeamSpecial() then
            teamScale = NewFormationIconView.kTeamSpecialScale
        end

        self._layerItemBody = ccui.ImageView:create(TeamUtils.getNpcTableValueByTeam(teamTableData, "steam") .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(teamScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        --self._layerItemBody:setScale(0.8)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)

        local teamNumBg = ccui.ImageView:create("team_num_bg_forma.png", 1)
        teamNumBg:setScale(1 / teamScale)
        teamNumBg:setPosition(self._layerItemBody:getContentSize().width / 2 - teamNumBg:getContentSize().width / 2, 0)
        teamNumBg:setTag(NewFormationIconView.kTagTeamNumberBg)
        self._layerItemBody:addChild(teamNumBg, 5)

        local imageClass = ccui.ImageView:create(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
        imageClass:setScale(0.7 / teamScale)
        imageClass:setRotation3D(cc.Vertex3F(0, 180, 0))
        imageClass:setPosition(teamNumBg:getPositionX() + teamNumBg:getContentSize().width / 2 + 5, teamNumBg:getPositionY() + 6)
        imageClass:setTag(NewFormationIconView.kTagTeamClass)
        self._layerItemBody:addChild(imageClass, 20)

        local teamNumX = ccui.Text:create("X", UIUtils.ttfName, 14)
        teamNumX:setScale(1 / teamScale)
        teamNumX:setPosition(imageClass:getPositionX() - 30, -1)
        teamNumX:setTag(NewFormationIconView.kTagTeamX)
        teamNumX:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNumX:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNumX, 10)

        local teamNum = ccui.Text:create((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")), UIUtils.ttfName, 22)
        teamNum:setFlippedX(true)
        teamNum:setScale(1 / teamScale)
        teamNum:setPosition(teamNumX:getPositionX() - teamNum:getContentSize().width, -1)
        teamNum:setTag(NewFormationIconView.kTagTeamNumber)
        teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        teamNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._layerItemBody:addChild(teamNum, 10)
    end
end

function NewFormationIconView:updateHeroInformation(state)
    --print("NewFormationIconView:updateHeroIconInformation")
    if self._isCustom then 
        return self:updateCustomHeroInformation(state)
    end

    if self._isLocal then 
        return self:updateLocalHeroInformation(state)
    end

    state = state or self._iconState
    local heroData = self._heroModel:getHeroData(self._iconId)
    local heroTableData = clone(tab:Hero(self._iconId))
    if heroData.star then
        heroTableData.star = heroData.star
        heroTableData.skin = heroData.skin
    end
    if not heroTableData then print("invalid hero icon id", self._iconId) end
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createHeroIconById({sysHeroData = heroTableData})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setPosition(cc.p(45, 45))
            --icon:setPosition(self._layerItemImage:getContentSize().width / 2, self._layerItemImage:getContentSize().height / 2)
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateHeroIconByView(self._layerItemImage, {sysHeroData = heroTableData})
        end

        --[=[
        if not self._layerItemImage then
            self._layerItemImage = ccui.ImageView:create(IconUtils.iconPath .. heroTableData.herohead .. ".png")
            self._layerItemImage:setVisible(false)
            self._layerItemImage:setScale(0.8)
            self._layerItemImage:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
            --[[
            local heroIconBg = ccui.ImageView:create("globalImageUI4_heroBg1.png", 1)
            heroIconBg:setPosition(self._layerItemImage:getContentSize().width / 2, self._layerItemImage:getContentSize().height / 2)
            self._layerItemImage:addChild(heroIconBg)
            ]]
            self:addChild(self._layerItemImage)
        else
            self._layerItemImage:loadTexture(IconUtils.iconPath .. heroTableData.herohead .. ".png")
        end
        ]=]

        local flagRed = self:getChildByTag(NewFormationIconView.kTagTeamFlagRed)
        if not flagRed then
            --flagRed = mcMgr:createViewMC("saijirediankuang_leaguerediantexiao", true, false, nil, RGBA8888)
            flagRed = ccui.ImageView:create("flag_dark_forma.png", 1)
            --flagRed:setScale(0.9)
            flagRed:setVisible(false)
            flagRed:setPosition(cc.p(45, 45))
            flagRed:setTag(NewFormationIconView.kTagTeamFlagRed)
            self:addChild(flagRed, 100)
        end

        local flagBlue = self:getChildByTag(NewFormationIconView.kTagTeamFlagBlue)
        if not flagBlue then
            --flagBlue = mcMgr:createViewMC("duanweirediankuang_leaguerediantexiao", true, false, nil, RGBA8888)
            flagBlue = ccui.ImageView:create("flag_light_forma.png", 1)
            --flagBlue:setScale(0.9)
            flagBlue:setVisible(false)
            flagBlue:setPosition(cc.p(45, 45))
            flagBlue:setTag(NewFormationIconView.kTagTeamFlagBlue)
            self:addChild(flagBlue, 100)
        end
    else
        --[[
        self._layerItemBody = mcMgr:createViewMC("idle_" .. heroTableData.heroart, true)
        self:setRotation3D(cc.Vertex3F(0, 180, 0))
        self._layerItemBody:setScale(1.5)
        self._layerItemBody:setVisible(false)
        --self._layerItemBody:stop()
        --self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 4)
        self:addChild(self._layerItemBody)
        ]]

        --[[
        self._layerItemBody = ccui.ImageView:create(heroTableData.shero .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setVisible(false)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self:addChild(self._layerItemBody)
        ]]

        local sHero = heroTableData.shero
        if heroTableData.skin then
            local skinTableData = tab:HeroSkin(tonumber(heroTableData.skin))
            sHero = skinTableData and skinTableData.shero or sHero
        end
        self._layerItemBody = ccui.ImageView:create(sHero .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(NewFormationIconView.kHeroScale)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 + 5)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)
    end
end

function NewFormationIconView:updateInstanceHeroInformation(state)
    --print("NewFormationIconView:updateHeroIconInformation")
    state = state or self._iconState
    local heroTableData = clone(tab:NpcHero(self._iconId))
    if not heroTableData then print("invalid hero icon id", self._iconId) end
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createHeroIconById({sysHeroData = heroTableData})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateHeroIconByView(self._layerItemImage, {sysHeroData = heroTableData})
        end

        --[=[
        if not self._layerItemImage then
            self._layerItemImage = ccui.ImageView:create(IconUtils.iconPath .. heroTableData.herohead .. ".png")
            self._layerItemImage:setVisible(false)
            self._layerItemImage:setScale(0.8)
            self._layerItemImage:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
            --[[
            local heroIconBg = ccui.ImageView:create("globalImageUI4_heroBg1.png", 1)
            heroIconBg:setPosition(self._layerItemImage:getContentSize().width / 2, self._layerItemImage:getContentSize().height / 2)
            self._layerItemImage:addChild(heroIconBg)
            ]]
            self:addChild(self._layerItemImage)
        else
            self._layerItemImage:loadTexture(IconUtils.iconPath .. heroTableData.herohead .. ".png")
        end
        ]=]
    else
        self._layerItemBody = ccui.ImageView:create(heroTableData.shero .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(NewFormationIconView.kHeroScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 + 5)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)

        --[[
        self._layerItemBody = mcMgr:createViewMC("idle_" .. heroTableData.heroart, true)
        self:setRotation3D(cc.Vertex3F(0, 180, 0))
        self._layerItemBody:setScale(1.5)
        self._layerItemBody:setVisible(false)
        --self._layerItemBody:stop()
        --self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 4)
        self:addChild(self._layerItemBody)
        ]]

        --[[
        self._layerItemBody = ccui.ImageView:create(heroTableData.shero .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        self._layerItemBody:setVisible(false)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self:addChild(self._layerItemBody)
        ]]
    end
end

function NewFormationIconView:updateArenaHeroInformation(state)
    --print("NewFormationIconView:updateHeroIconInformation")
    state = state or self._iconState
    local heroTableData = clone(tab:Hero(self._iconId))
    if not heroTableData then print("invalid hero icon id", self._iconId) end
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createHeroIconById({sysHeroData = heroTableData})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateHeroIconByView(self._layerItemImage, {sysHeroData = heroTableData})
        end
        --[=[
        if not self._layerItemImage then
            self._layerItemImage = ccui.ImageView:create(IconUtils.iconPath .. heroTableData.herohead .. ".png")
            self._layerItemImage:setVisible(false)
            self._layerItemImage:setScale(0.8)
            self._layerItemImage:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
            --[[
            local heroIconBg = ccui.ImageView:create("globalImageUI4_heroBg1.png", 1)
            heroIconBg:setPosition(self._layerItemImage:getContentSize().width / 2, self._layerItemImage:getContentSize().height / 2)
            self._layerItemImage:addChild(heroIconBg)
            ]]
            self:addChild(self._layerItemImage)
        else
            self._layerItemImage:loadTexture(IconUtils.iconPath .. heroTableData.herohead .. ".png")
        end
        ]=]
    else
        self._layerItemBody = ccui.ImageView:create(heroTableData.shero .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(NewFormationIconView.kHeroScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 + 5)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)
    end
end

function NewFormationIconView:updateAiRenMuWuHeroInformation(state)
    --print("NewFormationIconView:updateHeroIconInformation")
    state = state or self._iconState
    local heroTableData = clone(tab:NpcHero(self._iconId))
    if not heroTableData then print("invalid hero icon id", self._iconId) end
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createHeroIconById({sysHeroData = heroTableData})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateHeroIconByView(self._layerItemImage, {sysHeroData = heroTableData})
        end
        --[=[
        if not self._layerItemImage then
            self._layerItemImage = ccui.ImageView:create(IconUtils.iconPath .. heroTableData.herohead .. ".png")
            self._layerItemImage:setVisible(false)
            self._layerItemImage:setScale(0.8)
            self._layerItemImage:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
            --[[
            local heroIconBg = ccui.ImageView:create("globalImageUI4_heroBg1.png", 1)
            heroIconBg:setPosition(self._layerItemImage:getContentSize().width / 2, self._layerItemImage:getContentSize().height / 2)
            self._layerItemImage:addChild(heroIconBg)
            ]]
            self:addChild(self._layerItemImage)
        else
            self._layerItemImage:loadTexture(IconUtils.iconPath .. heroTableData.herohead .. ".png")
        end
        ]=]
    else
        self._layerItemBody = ccui.ImageView:create(heroTableData.shero .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(NewFormationIconView.kHeroScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 + 5)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)
    end
end

function NewFormationIconView:updateZombieHeroInformation(state)
    --print("NewFormationIconView:updateHeroIconInformation")
    state = state or self._iconState
    local heroTableData = clone(tab:NpcHero(self._iconId))
    if not heroTableData then print("invalid hero icon id", self._iconId) end
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createHeroIconById({sysHeroData = heroTableData})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateHeroIconByView(self._layerItemImage, {sysHeroData = heroTableData})
        end
        --[=[
        if not self._layerItemImage then
            self._layerItemImage = ccui.ImageView:create(IconUtils.iconPath .. heroTableData.herohead .. ".png")
            self._layerItemImage:setVisible(false)
            self._layerItemImage:setScale(0.8)
            self._layerItemImage:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
            --[[
            local heroIconBg = ccui.ImageView:create("globalImageUI4_heroBg1.png", 1)
            heroIconBg:setPosition(self._layerItemImage:getContentSize().width / 2, self._layerItemImage:getContentSize().height / 2)
            self._layerItemImage:addChild(heroIconBg)
            ]]
            self:addChild(self._layerItemImage)
        else
            self._layerItemImage:loadTexture(IconUtils.iconPath .. heroTableData.herohead .. ".png")
        end
        ]=]
    else
        self._layerItemBody = ccui.ImageView:create(heroTableData.shero .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(NewFormationIconView.kHeroScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 + 5)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)
    end
end

function NewFormationIconView:updateDragonHeroInformation(state)
    --print("NewFormationIconView:updateHeroIconInformation")
    state = state or self._iconState
    local heroTableData = clone(tab:NpcHero(self._iconId))
    if not heroTableData then print("invalid hero icon id", self._iconId) end
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createHeroIconById({sysHeroData = heroTableData})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateHeroIconByView(self._layerItemImage, {sysHeroData = heroTableData})
        end
        --[=[
        if not self._layerItemImage then
            self._layerItemImage = ccui.ImageView:create(IconUtils.iconPath .. heroTableData.herohead .. ".png")
            self._layerItemImage:setVisible(false)
            self._layerItemImage:setScale(0.8)
            self._layerItemImage:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
            --[[
            local heroIconBg = ccui.ImageView:create("globalImageUI4_heroBg1.png", 1)
            heroIconBg:setPosition(self._layerItemImage:getContentSize().width / 2, self._layerItemImage:getContentSize().height / 2)
            self._layerItemImage:addChild(heroIconBg)
            ]]
            self:addChild(self._layerItemImage)
        else
            self._layerItemImage:loadTexture(IconUtils.iconPath .. heroTableData.herohead .. ".png")
        end
        ]=]
    else
        self._layerItemBody = ccui.ImageView:create(heroTableData.shero .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(NewFormationIconView.kHeroScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 + 5)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)
    end
end

function NewFormationIconView:updateCrusadeHeroInformation(state)
    --print("NewFormationIconView:updateHeroIconInformation")
    state = state or self._iconState
    local heroData = self._modelMgr:getModel("CrusadeModel"):getEnemyHeroData()
    local heroTableData = clone(tab:Hero(self._iconId))
    if heroData.star then
        heroTableData.star = heroData.star
        heroTableData.skin = heroData.skin
    end
    if not heroTableData then print("invalid hero icon id", self._iconId) end
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createHeroIconById({sysHeroData = heroTableData})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateHeroIconByView(self._layerItemImage, {sysHeroData = heroTableData})
        end
        --[=[
        if not self._layerItemImage then
            self._layerItemImage = ccui.ImageView:create(IconUtils.iconPath .. heroTableData.herohead .. ".png")
            self._layerItemImage:setVisible(false)
            self._layerItemImage:setScale(0.8)
            self._layerItemImage:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
            --[[
            local heroIconBg = ccui.ImageView:create("globalImageUI4_heroBg1.png", 1)
            heroIconBg:setPosition(self._layerItemImage:getContentSize().width / 2, self._layerItemImage:getContentSize().height / 2)
            self._layerItemImage:addChild(heroIconBg)
            ]]
            self:addChild(self._layerItemImage)
        else
            self._layerItemImage:loadTexture(IconUtils.iconPath .. heroTableData.herohead .. ".png")
        end
        ]=]
    else
        local sHero = heroTableData.shero
        if heroTableData.skin then
            local skinTableData = tab:HeroSkin(tonumber(heroTableData.skin))
            sHero = skinTableData and skinTableData.shero or sHero
        end
        self._layerItemBody = ccui.ImageView:create(sHero .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(NewFormationIconView.kHeroScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 + 5)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)
    end
end

function NewFormationIconView:updateLocalHeroInformation(state)
    --print("NewFormationIconView:updateLocalHeroInformation")
    state = state or self._iconState
    local heroTableData = clone(tab:Hero(self._iconId))
    if not heroTableData then print("invalid hero icon id", self._iconId) end
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createHeroIconById({sysHeroData = heroTableData})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateHeroIconByView(self._layerItemImage, {sysHeroData = heroTableData})
        end
        --[=[
        if not self._layerItemImage then
            self._layerItemImage = ccui.ImageView:create(IconUtils.iconPath .. heroTableData.herohead .. ".png")
            self._layerItemImage:setVisible(false)
            self._layerItemImage:setScale(0.8)
            self._layerItemImage:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
            --[[
            local heroIconBg = ccui.ImageView:create("globalImageUI4_heroBg1.png", 1)
            heroIconBg:setPosition(self._layerItemImage:getContentSize().width / 2, self._layerItemImage:getContentSize().height / 2)
            self._layerItemImage:addChild(heroIconBg)
            ]]
            self:addChild(self._layerItemImage)
        else
            self._layerItemImage:loadTexture(IconUtils.iconPath .. heroTableData.herohead .. ".png")
        end
        ]=]
    else
        self._layerItemBody = ccui.ImageView:create(heroTableData.shero .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(NewFormationIconView.kHeroScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 + 5)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)
    end
end

function NewFormationIconView:updateGuildHeroInformation(state)
    --print("NewFormationIconView:updateGuildHeroInformation")
    state = state or self._iconState
    local heroTableData = clone(tab:Hero(self._iconId))
    if not heroTableData then print("invalid hero icon id", self._iconId) end
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createHeroIconById({sysHeroData = heroTableData})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateHeroIconByView(self._layerItemImage, {sysHeroData = heroTableData})
        end
        --[=[
        if not self._layerItemImage then
            self._layerItemImage = ccui.ImageView:create(IconUtils.iconPath .. heroTableData.herohead .. ".png")
            self._layerItemImage:setVisible(false)
            self._layerItemImage:setScale(0.8)
            self._layerItemImage:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
            --[[
            local heroIconBg = ccui.ImageView:create("globalImageUI4_heroBg1.png", 1)
            heroIconBg:setPosition(self._layerItemImage:getContentSize().width / 2, self._layerItemImage:getContentSize().height / 2)
            self._layerItemImage:addChild(heroIconBg)
            ]]
            self:addChild(self._layerItemImage)
        else
            self._layerItemImage:loadTexture(IconUtils.iconPath .. heroTableData.herohead .. ".png")
        end
        ]=]
    else
        self._layerItemBody = ccui.ImageView:create(heroTableData.shero .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(NewFormationIconView.kHeroScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 + 5)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)
    end
end

function NewFormationIconView:updateMFHeroInformation(state)
    --print("NewFormationIconView:updateMFHeroInformation")
    state = state or self._iconState
    local heroTableData = clone(tab:Hero(self._iconId))
    if not heroTableData then print("invalid hero icon id", self._iconId) end
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createHeroIconById({sysHeroData = heroTableData})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateHeroIconByView(self._layerItemImage, {sysHeroData = heroTableData})
        end
        --[=[
        if not self._layerItemImage then
            self._layerItemImage = ccui.ImageView:create(IconUtils.iconPath .. heroTableData.herohead .. ".png")
            self._layerItemImage:setVisible(false)
            self._layerItemImage:setScale(0.8)
            self._layerItemImage:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
            --[[
            local heroIconBg = ccui.ImageView:create("globalImageUI4_heroBg1.png", 1)
            heroIconBg:setPosition(self._layerItemImage:getContentSize().width / 2, self._layerItemImage:getContentSize().height / 2)
            self._layerItemImage:addChild(heroIconBg)
            ]]
            self:addChild(self._layerItemImage)
        else
            self._layerItemImage:loadTexture(IconUtils.iconPath .. heroTableData.herohead .. ".png")
        end
        ]=]
    else
        self._layerItemBody = ccui.ImageView:create(heroTableData.shero .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(NewFormationIconView.kHeroScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 + 5)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)
    end
end

function NewFormationIconView:updateNpcHeroInformation(state)
    --print("NewFormationIconView:updateNpcHeroInformation")
    state = state or self._iconState
    local heroTableData = clone(tab:NpcHero(self._iconId))
    if not heroTableData then print("invalid hero icon id", self._iconId) end
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createHeroIconById({sysHeroData = heroTableData})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateHeroIconByView(self._layerItemImage, {sysHeroData = heroTableData})
        end
        --[=[
        if not self._layerItemImage then
            self._layerItemImage = ccui.ImageView:create(IconUtils.iconPath .. heroTableData.herohead .. ".png")
            self._layerItemImage:setVisible(false)
            self._layerItemImage:setScale(0.8)
            self._layerItemImage:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
            --[[
            local heroIconBg = ccui.ImageView:create("globalImageUI4_heroBg1.png", 1)
            heroIconBg:setPosition(self._layerItemImage:getContentSize().width / 2, self._layerItemImage:getContentSize().height / 2)
            self._layerItemImage:addChild(heroIconBg)
            ]]
            self:addChild(self._layerItemImage)
        else
            self._layerItemImage:loadTexture(IconUtils.iconPath .. heroTableData.herohead .. ".png")
        end
        ]=]
    else
        self._layerItemBody = ccui.ImageView:create(heroTableData.shero .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(NewFormationIconView.kHeroScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 + 5)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)
    end
end

function NewFormationIconView:updateElementalHeroInformation(state)
    --print("NewFormationIconView:updateElementalHeroInformation")
    state = state or self._iconState
    local heroTableData = clone(tab:NpcHero(self._iconId))
    if not heroTableData then print("invalid hero icon id", self._iconId) end
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createHeroIconById({sysHeroData = heroTableData})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateHeroIconByView(self._layerItemImage, {sysHeroData = heroTableData})
        end
        --[=[
        if not self._layerItemImage then
            self._layerItemImage = ccui.ImageView:create(IconUtils.iconPath .. heroTableData.herohead .. ".png")
            self._layerItemImage:setVisible(false)
            self._layerItemImage:setScale(0.8)
            self._layerItemImage:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
            --[[
            local heroIconBg = ccui.ImageView:create("globalImageUI4_heroBg1.png", 1)
            heroIconBg:setPosition(self._layerItemImage:getContentSize().width / 2, self._layerItemImage:getContentSize().height / 2)
            self._layerItemImage:addChild(heroIconBg)
            ]]
            self:addChild(self._layerItemImage)
        else
            self._layerItemImage:loadTexture(IconUtils.iconPath .. heroTableData.herohead .. ".png")
        end
        ]=]
    else
        self._layerItemBody = ccui.ImageView:create(heroTableData.shero .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(NewFormationIconView.kHeroScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 + 5)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)
    end
end

function NewFormationIconView:updateWeaponHeroInformation(state)
    --print("NewFormationIconView:updateWeaponHeroInformation")
    state = state or self._iconState
    local heroTableData = clone(tab:NpcHero(self._iconId))
    if not heroTableData then print("invalid hero icon id", self._iconId) end
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createHeroIconById({sysHeroData = heroTableData})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateHeroIconByView(self._layerItemImage, {sysHeroData = heroTableData})
        end
        --[=[
        if not self._layerItemImage then
            self._layerItemImage = ccui.ImageView:create(IconUtils.iconPath .. heroTableData.herohead .. ".png")
            self._layerItemImage:setVisible(false)
            self._layerItemImage:setScale(0.8)
            self._layerItemImage:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
            --[[
            local heroIconBg = ccui.ImageView:create("globalImageUI4_heroBg1.png", 1)
            heroIconBg:setPosition(self._layerItemImage:getContentSize().width / 2, self._layerItemImage:getContentSize().height / 2)
            self._layerItemImage:addChild(heroIconBg)
            ]]
            self:addChild(self._layerItemImage)
        else
            self._layerItemImage:loadTexture(IconUtils.iconPath .. heroTableData.herohead .. ".png")
        end
        ]=]
    else
        self._layerItemBody = ccui.ImageView:create(heroTableData.shero .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(NewFormationIconView.kHeroScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 + 5)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)
    end
end

function NewFormationIconView:updateCustomHeroInformation(state)
    --print("NewFormationIconView:updateCustomHeroInformation")
    state = state or self._iconState
    local heroTableData = nil
    if self._formationType == self._formationModel.kFormationTypeLeague then
        heroTableData = clone(self._leagueModel:getMyHeroData(self._iconId))
    elseif self._formationType == self._formationModel.kFormationTypeHeroDuel then
        heroTableData = clone(tab:Hero(self._iconId))
        local heroDuelId = self._heroDuelModel:getWeekNum()
        local heroDuelTableData = tab:HeroDuel(heroDuelId)
        if heroDuelTableData then
            heroTableData.star = heroDuelTableData.herostar
            heroTableData.spelllv = {}
            for i = 1, 4 do
                heroTableData.spelllv[i] = heroDuelTableData.heroskill
            end
        end
    else
        heroTableData = clone(tab:NpcHero(self._iconId))
    end
    if not heroTableData then print("invalid hero icon id", self._iconId) end
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createHeroIconById({sysHeroData = heroTableData})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateHeroIconByView(self._layerItemImage, {sysHeroData = heroTableData})
        end
        --[=[
        if not self._layerItemImage then
            self._layerItemImage = ccui.ImageView:create(IconUtils.iconPath .. heroTableData.herohead .. ".png")
            self._layerItemImage:setVisible(false)
            self._layerItemImage:setScale(0.8)
            self._layerItemImage:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
            --[[
            local heroIconBg = ccui.ImageView:create("globalImageUI4_heroBg1.png", 1)
            heroIconBg:setPosition(self._layerItemImage:getContentSize().width / 2, self._layerItemImage:getContentSize().height / 2)
            self._layerItemImage:addChild(heroIconBg)
            ]]
            self:addChild(self._layerItemImage)
        else
            self._layerItemImage:loadTexture(IconUtils.iconPath .. heroTableData.herohead .. ".png")
        end
        ]=]

        
        local flagHeroHelp = self:getChildByTag(NewFormationIconView.kTagTeamFlagHeroHelp)
        if not flagHeroHelp then
            flagHeroHelp = ccui.ImageView:create("hero_help_forma.png", 1)
            --flagHeroHelp:setScale(0.9)
            flagHeroHelp:setVisible(false)
            flagHeroHelp:setPosition(cc.p(45, 80))
            flagHeroHelp:setTag(NewFormationIconView.kTagTeamFlagHeroHelp)
            self:addChild(flagHeroHelp, 100)
        end

        local flagNextHeroHelp = self:getChildByTag(NewFormationIconView.kTagTeamFlagNextHeroHelp)
        if not flagNextHeroHelp then
            --flagNextHeroHelp = mcMgr:createViewMC("saijirediankuang_leaguerediantexiao", true, false, nil, RGBA8888)
            flagNextHeroHelp = ccui.ImageView:create("next_hero_help_forma.png", 1)
            --flagNextHeroHelp:setScale(0.9)
            flagNextHeroHelp:setVisible(false)
            flagNextHeroHelp:setPosition(cc.p(45, 80))
            flagNextHeroHelp:setTag(NewFormationIconView.kTagTeamFlagNextHeroHelp)
            self:addChild(flagNextHeroHelp, 100)
        end

        local flagDoubleHeroHelp = self:getChildByTag(NewFormationIconView.kTagTeamFlagDoubleHeroHelp)
        if not flagDoubleHeroHelp then
            --flagDoubleHeroHelp = mcMgr:createViewMC("saijirediankuang_leaguerediantexiao", true, false, nil, RGBA8888)
            flagDoubleHeroHelp = ccui.ImageView:create("double_hero_help_forma.png", 1)
            --flagDoubleHeroHelp:setScale(0.9)
            flagDoubleHeroHelp:setVisible(false)
            flagDoubleHeroHelp:setPosition(cc.p(45, 80))
            flagDoubleHeroHelp:setTag(NewFormationIconView.kTagTeamFlagDoubleHeroHelp)
            self:addChild(flagDoubleHeroHelp, 100)
        end

        local flagScenarioHero = self:getChildByTag(NewFormationIconView.kTagTeamScenarioHero)
        if not flagScenarioHero then
            --flagScenarioHero = mcMgr:createViewMC("saijirediankuang_leaguerediantexiao", true, false, nil, RGBA8888)
            flagScenarioHero = ccui.ImageView:create("scenario_forma.png", 1)
            --flagScenarioHero:setScale(0.9)
            flagScenarioHero:setVisible(false)
            flagScenarioHero:setPosition(cc.p(45, 80))
            flagScenarioHero:setTag(NewFormationIconView.kTagTeamScenarioHero)
            self:addChild(flagScenarioHero, 100)
        end
    else
        local sHero = heroTableData.shero
        if heroTableData.skin then
            local skinTableData = tab:HeroSkin(tonumber(heroTableData.skin))
            sHero = skinTableData and skinTableData.shero or sHero
        end
        self._layerItemBody = ccui.ImageView:create(sHero .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(NewFormationIconView.kHeroScale)
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 + 5)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)

        if self._isScenarioHero then
            local imageScenarioHero = ccui.ImageView:create("image_scenario_forma.png", 1)
            imageScenarioHero:setScale(1 / NewFormationIconView.kHeroScale)
            imageScenarioHero:setPosition(self._layerItemBody:getContentSize().width / 2, -20)
            self._layerItemBody:addChild(imageScenarioHero, 10)
        end
    end
end

function NewFormationIconView:updateAdventureHeroInformation(state)
    --print("NewFormationIconView:updateAdventureHeroInformation")
    state = state or self._iconState
    local heroTableData = clone(tab:Hero(self._iconId))
    if not heroTableData then print("invalid hero icon id", self._iconId) end
    if NewFormationIconView.kIconStateImage == state then
        if not self._layerItemImage then
            self._layerItemImage = IconUtils:createHeroIconById({sysHeroData = heroTableData})
            self._layerItemImage:setScale(0.9)
            self._layerItemImage:setPosition(cc.p(45, 45))
            self:addChild(self._layerItemImage)
        else
            IconUtils:updateHeroIconByView(self._layerItemImage, {sysHeroData = heroTableData})
        end
        --[=[
        if not self._layerItemImage then
            self._layerItemImage = ccui.ImageView:create(IconUtils.iconPath .. heroTableData.herohead .. ".png")
            self._layerItemImage:setVisible(false)
            self._layerItemImage:setScale(0.8)
            self._layerItemImage:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
            --[[
            local heroIconBg = ccui.ImageView:create("globalImageUI4_heroBg1.png", 1)
            heroIconBg:setPosition(self._layerItemImage:getContentSize().width / 2, self._layerItemImage:getContentSize().height / 2)
            self._layerItemImage:addChild(heroIconBg)
            ]]
            self:addChild(self._layerItemImage)
        else
            self._layerItemImage:loadTexture(IconUtils.iconPath .. heroTableData.herohead .. ".png")
        end
        ]=]
    else
        self._layerItemBody = ccui.ImageView:create(heroTableData.shero .. ".png", 1)
        self._layerItemBody:setAnchorPoint(cc.p(0.5, 0.1))
        self._layerItemBody:setScale(NewFormationIconView.kHeroScale)
        self._layerItemBody:setRotation3D(cc.Vertex3F(0, 180, 0))
        self._layerItemBody:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 + 5)
        self._layerItemBody:setVisible(false)
        self:addChild(self._layerItemBody)
    end
end

function NewFormationIconView:updateState(state, force)
    --if not (self._layerItemImage and self._layerItemBody) then return end
    if self._iconState == state and not force then return end

    if (NewFormationIconView.kIconStateBody == state and not self._layerItemBody) or
       (NewFormationIconView.kIconStateImage == state and not self._layerItemImage) or force then
       self:updateInformation(state)
    end

    self._iconState = state
    --print("NewFormationIconView:updateState")
    if NewFormationIconView.kIconStateBody == self._iconState then
        if self._layerItemImage then
            self._layerItemImage:setVisible(false)
        end
        if self._layerItemBody then
            --self._layerItemBody:gotoAndPlay(0)
            self._layerItemBody:setVisible(true)
        end
    else
        if self._layerItemBody then
            self._layerItemBody:setVisible(false)
        end
        if self._layerItemImage then
            --self._layerItemBody:stop()
            self._layerItemImage:setVisible(true)
        end
    end
end

function NewFormationIconView:enableTouch(enable)
    if not enable then
        return self:setTouchEnabled(false)
    end
    self:setTouchEnabled(true)
    self:setSwallowTouches(false)
    self:registerTouchEvent(self, 
        handler(self, self.onTouchBegan), 
        handler(self, self.onTouchMoved), 
        handler(self, self.onTouchEnded), 
        handler(self, self.onTouchCancelled))
end

function NewFormationIconView:onTouchBegan(_, x, y)
    --print("began x, y", x, y)
    --local position = self:convertToNodeSpace(cc.p(x,y))
    --print("began after convert:", position.x, position.y)
    if not (self._container and self._container.onIconTouchBegan) then return end
    return self._container:onIconTouchBegan(self, x, y)
end

function NewFormationIconView:onTouchMoved(_, x, y)
    --print("moved x, y", x, y)
    if not (self._container and self._container.onIconTouchMoved) then return end
    self._container:onIconTouchMoved(self, x, y)
end

function NewFormationIconView:onTouchEnded(_, x, y)
    --print("ended x, y", x, y)
    if not (self._container and self._container.onIconTouchEnded) then return end
    self._container:onIconTouchEnded(self, x, y)
end

function NewFormationIconView:onTouchCancelled(_, x, y)
    --print("canceled x, y", x, y)
    if not (self._container and self._container.onIconTouchCancelled) then return end
    self._container:onIconTouchCancelled(self, x, y)
end

function NewFormationIconView.dtor()
    FormationModel = nil
    NewFormationIconView = nil
end

return NewFormationIconView
