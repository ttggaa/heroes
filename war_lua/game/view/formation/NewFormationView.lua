--[[
    Filename:    NewFormationView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-02-24 10:55:22
    Description: File description
--]]

local bit = bit

local NewFormationIconView = require("game.view.formation.NewFormationIconView")
local NewFormationDescriptionView = require("game.view.formation.NewFormationDescriptionView")

local NewFormationView = class("NewFormationView", BaseView)

NewFormationView.kGridTypeTeam = NewFormationIconView.kIconTypeTeam
NewFormationView.kGridTypeHero = NewFormationIconView.kIconTypeHero

NewFormationView.kGridTypeHireTeam = NewFormationIconView.kIconTypeHireTeam

NewFormationView.kGridTypeIns = NewFormationIconView.kIconTypeIns

NewFormationView.kNormalZOrder = 500
NewFormationView.kLessNormalZOrder = NewFormationView.kNormalZOrder - 1
NewFormationView.kAboveNormalZOrder = NewFormationView.kNormalZOrder + 1
NewFormationView.kHighestZOrder = NewFormationView.kAboveNormalZOrder + 1
NewFormationView.kAboveHighestZOrder = NewFormationView.kHighestZOrder * 10

NewFormationView.kItemTag = 1000
NewFormationView.kItemTagHero = 2000
NewFormationView.kBattleLightTag = 3000

NewFormationView.kRightFormationTag = 3000
NewFormationView.kDescriptionTag = 4000

NewFormationView.kRelationBuildTag = 5000
NewFormationView.kRelationBuildIconFrame = 6000

NewFormationView.kMoveThreshold = OS_IS_WINDOWS and 15 or 20

NewFormationView.kTeamGridCount = 16
NewFormationView.kTeamMaxCount = 8
NewFormationView.kInsMaxCount = 3

NewFormationView.kNullHeroId = 70000001

NewFormationView.kActionDeltaTime = 0.4
NewFormationView.kIconRotateDegree = 26

--[[
    formationData = {
        team1 = 101,
        team2 = 102,
        team3 = 103,
        team4 = 105,
        team5 = 0,
        team6 = 0,
        team7 = 0,
        team8 = 0,
        g1 = 2,
        g2 = 4,
        g3 = 6,
        g4 = 8,
        g5 = 0,
        g6 = 0,
        g7 = 0,
        g8 = 0,
        filter = "101, 102, 103"
        heroId = 60102,
}]]

local function clearFormationRequire()
    local requireList = 
    {
        "game.view.formation.NewFormationView",
        "game.view.formation.NewFormationView_CityBattle",
        "game.view.formation.NewFormationView_League",
        "game.view.formation.NewFormationView_HeroDuel",
        "game.view.formation.NewFormationView_GodWar",
        "game.view.formation.NewFormationView_CrossGodWar",
        "game.view.formation.NewFormationView_GloryArena",
        -- "game.view.formation.NewFormationView_CrossPK",
    }

    if OS_IS_64 then
        for i = 1, #requireList do
            local filename = requireList[i] .. "64"
            package.loaded[filename] = nil
        end
    else
        for i = 1, #requireList do
            local filename = requireList[i]
            package.loaded[filename] = nil
        end
    end

    collectgarbage("collect")
    collectgarbage("collect")
    collectgarbage("collect")
end

function NewFormationView:ctor(params)
    NewFormationView.super.ctor(self)
    self.fixMaxWidth = 1136
    self.noSound = true
    self._formationModel = self._modelMgr:getModel("FormationModel")
    self._intanceModel = self._modelMgr:getModel("IntanceModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._heroModel = self._modelMgr:getModel("HeroModel")
    self._crusadeModel = self._modelMgr:getModel("CrusadeModel")
    self._leagueModel = self._modelMgr:getModel("LeagueModel")
    self._heroDuelModel = self._modelMgr:getModel("HeroDuelModel")
    self._awakingModel = self._modelMgr:getModel("AwakingModel")
    self._guildModel = self._modelMgr:getModel("GuildModel")
    self._weaponsModel = self._modelMgr:getModel("WeaponsModel")
    self._siegeModel = self._modelMgr:getModel("SiegeModel")
    self._pokedexModel = self._modelMgr:getModel("PokedexModel")
    self._backupModel = self._modelMgr:getModel("BackupModel")
    params = params or { formationType = self._formationModel.kFormationTypeCommon }
    self._formationType = params.formationType
    print("self._formationType",self._formationType)
    self._subType = params.subType
    self._enemyFormationData = params.enemyFormationData
    --dump(self._enemyFormationData, "enemyFormationData")
    self:dealWithEnemyFormationData()
    self._battleCallBack = params.callback
    self._closeCallBack = params.closeCallback
    self._customCallBack = params.customCallback
    self._extend = params.extend or {}
    self._recommend = params.recommend or {}
    self._filter = params.filter or {}
    self._wall = params.wall or {}
    --dump(self._extend, "self._extend", 5)

    self._rulesTable = {
        [self._formationModel.kFormationTypeCityBattle1] = "NewFormationView_CityBattle",
        [self._formationModel.kFormationTypeCityBattle2] = "NewFormationView_CityBattle",
        [self._formationModel.kFormationTypeCityBattle3] = "NewFormationView_CityBattle",
        [self._formationModel.kFormationTypeCityBattle4] = "NewFormationView_CityBattle",
        [self._formationModel.kFormationTypeLeague] = "NewFormationView_League",
        [self._formationModel.kFormationTypeHeroDuel] = "NewFormationView_HeroDuel",
        [self._formationModel.kFormationTypeGodWar1] = "NewFormationView_GodWar",
        [self._formationModel.kFormationTypeGodWar2] = "NewFormationView_GodWar",
        [self._formationModel.kFormationTypeGodWar3] = "NewFormationView_GodWar",
        [self._formationModel.kFormationTypeCrossGodWar1] = "NewFormationView_CrossGodWar",
        [self._formationModel.kFormationTypeCrossGodWar2] = "NewFormationView_CrossGodWar",
        [self._formationModel.kFormationTypeCrossGodWar3] = "NewFormationView_CrossGodWar",
        [self._formationModel.kFormationTypeGloryArenaAtk1] = "NewFormationView_GloryArena",
        [self._formationModel.kFormationTypeGloryArenaAtk2] = "NewFormationView_GloryArena",
        [self._formationModel.kFormationTypeGloryArenaAtk3] = "NewFormationView_GloryArena",
        [self._formationModel.kFormationTypeGloryArenaDef1] = "NewFormationView_GloryArena",
        [self._formationModel.kFormationTypeGloryArenaDef2] = "NewFormationView_GloryArena",
        [self._formationModel.kFormationTypeGloryArenaDef3] = "NewFormationView_GloryArena",
        --[[
        [self._formationModel.kFormationTypeCrossPKAtk1] = "NewFormationView_CrossPK",
        [self._formationModel.kFormationTypeCrossPKAtk2] = "NewFormationView_CrossPK",
        [self._formationModel.kFormationTypeCrossPKAtk3] = "NewFormationView_CrossPK",
        [self._formationModel.kFormationTypeCrossPKDef1] = "NewFormationView_CrossPK",
        [self._formationModel.kFormationTypeCrossPKDef2] = "NewFormationView_CrossPK",
        [self._formationModel.kFormationTypeCrossPKDef3] = "NewFormationView_CrossPK",
        ]]
    }
end

function NewFormationView:onDestroy()
    if not (self._formationType == self._formationModel.kFormationTypeGodWar1 or
       self._formationType == self._formationModel.kFormationTypeGodWar2 or
       self._formationType == self._formationModel.kFormationTypeGodWar3) then
        BulletScreensUtils.clear()
    end
    self:clearLock()
    clearFormationRequire()
    self._viewMgr:disableScreenWidthBar()
    NewFormationView.super.onDestroy(self)
end

function NewFormationView:getAsyncRes()
    return 
    {
        {"asset/ui/newFormation3.plist", "asset/ui/newFormation3.png"},
        {"asset/ui/newFormation2.plist", "asset/ui/newFormation2.png"},
        {"asset/ui/newFormation1.plist", "asset/ui/newFormation1.png"},  
        {"asset/ui/newFormation.plist", "asset/ui/newFormation.png"},
        {"asset/ui/backup.plist", "asset/ui/backup.png"},
        --{"asset/ui/steamandshero1.plist", "asset/ui/steamandshero1.png"},
        --{"asset/ui/steamandshero2.plist", "asset/ui/steamandshero2.png"},
    }
end

function NewFormationView:disableTextEffect(element)
    if element == nil then
        element = self._widget
    end
    local desc = element:getDescription()
    if desc == "Label" then
        element:disableEffect()
    end
    local count = #element:getChildren()
    for i = 1, count do
        self:disableTextEffect(element:getChildren()[i])
    end
end

--[[
bit.bnot(a) - 返回一个a的补充   
bit.band(w1,...) - 返回w的位与   
bit.bor(w1,...) - 返回w的位或   
bit.bxor(w1,...) - 返回w的位异或   
bit.lshift(a,b) - 返回a向左偏移到b位   
bit.rshift(a,b) - 返回a逻辑右偏移到b位   
bit.arshift(a,b) - 返回a算术偏移到b位   
bit.mod(a,b) - 返回a除以b的整数余数   
]]

local FormationGrid = class("FormationGrid")
FormationGrid.kStateBlank = 0x01 --未放置0000 0001
FormationGrid.kStateFull = 0x02 --已放置0000 0010
FormationGrid.kStateValid = 0x04 --有效状态0000 0100
FormationGrid.kStateInvalid = 0x08 --无效状态0000 1000
FormationGrid.kStateSelecting = 0x10 --选中状态0001 0000
FormationGrid.kStateAddition = 0x20 --未选中状态0010 0000
FormationGrid.kStateSelected = 0x40 --未选中状态0100 0000
FormationGrid.kStateWall = 0x80 --城墙状态1000 0000
FormationGrid.kStateLocked = 0x100 --锁定状态1 0000 0000

FormationGrid.kTagIcon = 5000

function FormationGrid:ctor(container, gridType, gridIndex)
    self._gridType = gridType
    self._gridIndex = gridIndex and gridIndex or 0
    self._gridState = 0x00
    self._container = container
    self._grid = nil
    self._iconView = nil
    --[[
    self._gridStateFull = nil
    self._gridStateValid = nil
    self._gridStateInvalid = nil
    self._gridStateSelecting = mcMgr:createViewMC("xuanzhong_selectedanim", true)
    self._gridStateSelecting:setPlaySpeed(1, true)
    self._gridStateAddition = nil
    self._gridLoaded = nil

    if 0 ~= self._gridIndex then
        self._grid = self._container:getUI("bg.layer_left.layer_team_formation.formation_icon_" .. gridIndex)
        self._gridStateFull = self._container:getUI("bg.layer_left.layer_team_formation.formation_icon_" .. gridIndex .. ".grid_f")
        self._gridStateValid = self._container:getUI("bg.layer_left.layer_team_formation.formation_icon_" .. gridIndex .. ".grid_v")
        self._gridStateInvalid = self._container:getUI("bg.layer_left.layer_team_formation.formation_icon_" .. gridIndex .. ".grid_i")
        self._gridStateAddition = self._container:getUI("bg.layer_left.layer_team_formation.formation_icon_" .. gridIndex .. ".grid_a")
    else
        self._grid = self._container:getUI("bg.layer_left.layer_hero_formation")
        self._gridStateFull = self._container:getUI("bg.layer_left.layer_hero_formation.grid_f")
        self._gridStateValid = self._container:getUI("bg.layer_left.layer_hero_formation.grid_v")
        self._gridStateInvalid = self._container:getUI("bg.layer_left.layer_hero_formation.grid_i")
        self._gridStateAddition = self._container:getUI("bg.layer_left.layer_hero_formation.grid_a")
    end
    ]]
    if self._gridType == NewFormationView.kGridTypeTeam then
        self._grid = self._container:getUI("bg.layer_left.layer_team_formation.formation_icon_" .. self._gridIndex)
    elseif self._gridType == NewFormationView.kGridTypeIns then
        self._grid = self._container:getUI("bg.layer_left.layer_ins_formation.ins_icon_" .. self._gridIndex)
    else
        self._grid = self._container:getUI("bg.layer_left.layer_hero_formation")
    end

    if self._gridType == NewFormationView.kGridTypeTeam then
        self._gridStateFull = ccui.ImageView:create("grid_team_f_bg_forma.png", 1)
    elseif self._gridType == NewFormationView.kGridTypeIns then
        self._gridStateFull = ccui.ImageView:create("globalImageUI6_meiyoutu.png", 1)
    else
        self._gridStateFull = ccui.ImageView:create("grid_hero_f_bg_forma.png", 1)
    end
    self._gridStateFull:setVisible(false)
    self._gridStateFull:setPosition(self._grid:getContentSize().width / 2, self._grid:getContentSize().height / 2)
    self._grid:addChild(self._gridStateFull, NewFormationView.kNormalZOrder)

    self._gridStateFullEx = mcMgr:createViewMC("saijiredian1_leagueredian", true)
    self._gridStateFullEx:setVisible(false)
    self._gridStateFullEx:setPosition(self._gridStateFull:getContentSize().width / 2, self._gridStateFull:getContentSize().height / 2)
    self._gridStateFull:addChild(self._gridStateFullEx, NewFormationView.kNormalZOrder)
    
    self._gridStateFullEx1 = mcMgr:createViewMC("saijiredian2_leagueredian", true)
    self._gridStateFullEx1:setVisible(false)
    self._gridStateFullEx1:setPosition(self._grid:getContentSize().width / 2, self._grid:getContentSize().height / 2)
    self._grid:addChild(self._gridStateFullEx1, NewFormationView.kAboveHighestZOrder)

    if self._gridType == NewFormationView.kGridTypeTeam then
        self._gridStateValid = ccui.ImageView:create("grid_team_v_bg_forma.png", 1)
    elseif self._gridType == NewFormationView.kGridTypeIns then
        self._gridStateValid = ccui.ImageView:create("grid_ins_v_bg_forma.png", 1)
    else
        self._gridStateValid = ccui.ImageView:create("grid_hero_v_bg_forma.png", 1)
    end
    self._gridStateValid:setVisible(false)
    self._gridStateValid:setScale(0.9)
    self._gridStateValid:setPosition(self._grid:getContentSize().width / 2, self._grid:getContentSize().height / 2)
    self._grid:addChild(self._gridStateValid, NewFormationView.kAboveNormalZOrder)

    if self._gridType == NewFormationView.kGridTypeTeam then
        self._gridStateInvalid = ccui.ImageView:create("grid_team_i_bg_forma.png", 1)
    elseif self._gridType == NewFormationView.kGridTypeIns then
        self._gridStateInvalid = ccui.ImageView:create("grid_ins_i_bg_forma.png", 1)
    else
        self._gridStateInvalid = ccui.ImageView:create("grid_hero_i_bg_forma.png", 1)
    end
    self._gridStateInvalid:setVisible(false)
    self._gridStateInvalid:setPosition(self._grid:getContentSize().width / 2, self._grid:getContentSize().height / 2)
    self._grid:addChild(self._gridStateInvalid, NewFormationView.kAboveNormalZOrder)

    self._gridStateSelecting = mcMgr:createViewMC("xuanzhong_selectedanim", true)
    if self._gridType == NewFormationView.kGridTypeIns then
        self._gridStateSelecting = mcMgr:createViewMC("gongchengkefangzhi_gongchengbuzhen", true)
    end
    self._gridStateSelecting:setVisible(false)
    self._gridStateSelecting:setScale(1.05)
    self._gridStateSelecting:setPlaySpeed(1, true)
    self._gridStateSelecting:setPosition(self._grid:getContentSize().width / 2, self._grid:getContentSize().height / 2)
    self._grid:addChild(self._gridStateSelecting, NewFormationView.kAboveNormalZOrder)

    --[[
    self._gridStateAddition = ccui.ImageView:create("globalImageUI4_addition.png", 1)
    self._gridStateAddition:setVisible(false)
    self._gridStateAddition:setPosition(self._grid:getContentSize().width / 2, self._grid:getContentSize().height / 2)
    self._grid:addChild(self._gridStateAddition, NewFormationView.kLessNormalZOrder)
    ]]
    if self._gridType == NewFormationView.kGridTypeTeam then
        self._gridStateAddition = mcMgr:createViewMC("kefangzhi_selectedanim", true)
    elseif self._gridType == NewFormationView.kGridTypeIns then
        self._gridStateAddition = mcMgr:createViewMC("gongchengkeshangzhen_gongchengbuzhen", true)
    else
        self._gridStateAddition = mcMgr:createViewMC("kefangzhiyingxiong_selectedanim", true)
    end
    self._gridStateAddition:setVisible(false)
    self._gridStateAddition:setPosition(self._grid:getContentSize().width / 2, self._grid:getContentSize().height / 2)
    self._grid:addChild(self._gridStateAddition, NewFormationView.kLessNormalZOrder)

    if self._gridType == NewFormationView.kGridTypeTeam then
        self._gridStateSelected = mcMgr:createViewMC("xuanzhongbingtuan_selectedanim", true)
    else
        self._gridStateSelected = mcMgr:createViewMC("xuanzhongyingxiong_selectedanim", true)
    end
    self._gridStateSelected:setVisible(false)
    self._gridStateSelected:setPlaySpeed(1, true)
    self._gridStateSelected:setPosition(self._grid:getContentSize().width / 2, self._grid:getContentSize().height / 2)
    self._grid:addChild(self._gridStateSelected, NewFormationView.kAboveNormalZOrder)

    self._gridLoaded = mcMgr:createViewMC("shangzhen_selectedanim", false, false)
    self._gridLoaded:setRotation3D(cc.Vertex3F(NewFormationView.kIconRotateDegree, 0, 0))
    self._gridLoaded:setVisible(false)
    self._gridLoaded:stop()
    self._gridLoaded:setPosition(self._grid:getContentSize().width / 2, self._grid:getContentSize().height / 2 + 10)
    self._grid:addChild(self._gridLoaded, NewFormationView.kHighestZOrder)

    self._gridLoadedBottom = mcMgr:createViewMC("shangzhendi_selectedanim", false, false)
    self._gridLoadedBottom:setRotation3D(cc.Vertex3F(NewFormationView.kIconRotateDegree, 0, 0))
    self._gridLoadedBottom:setVisible(false)
    self._gridLoadedBottom:setScale(1.2)
    self._gridLoadedBottom:stop()
    self._gridLoadedBottom:setPosition(self._grid:getContentSize().width / 2, self._grid:getContentSize().height / 2 + 6)
    self._grid:addChild(self._gridLoadedBottom, NewFormationView.kNormalZOrder)

    self._gridLoadedEx = mcMgr:createViewMC("tihuanshuaxin_selectedexanim", false, false)
    self._gridLoadedEx:setRotation3D(cc.Vertex3F(NewFormationView.kIconRotateDegree, 0, 0))
    self._gridLoadedEx:setVisible(false)
    self._gridLoadedEx:stop()
    self._gridLoadedEx:setPosition(self._grid:getContentSize().width / 2, self._grid:getContentSize().height / 2)
    self._grid:addChild(self._gridLoadedEx, NewFormationView.kHighestZOrder)

    self._gridUnloadedEx = mcMgr:createViewMC("ruotishi_selectedexanim", false, false)
    self._gridUnloadedEx:setRotation3D(cc.Vertex3F(NewFormationView.kIconRotateDegree, 0, 0))
    self._gridUnloadedEx:setVisible(false)
    self._gridUnloadedEx:stop()
    self._gridUnloadedEx:setPosition(self._grid:getContentSize().width / 2, self._grid:getContentSize().height / 2)
    self._grid:addChild(self._gridUnloadedEx, NewFormationView.kHighestZOrder)

    self._gridLoadedExBottom = mcMgr:createViewMC("tihuanshuaxindi_selectedexanim", false, false)
    self._gridLoadedExBottom:setRotation3D(cc.Vertex3F(NewFormationView.kIconRotateDegree, 0, 0))
    self._gridLoadedExBottom:setVisible(false)
    self._gridLoadedExBottom:stop()
    self._gridLoadedExBottom:setPosition(self._grid:getContentSize().width / 2, self._grid:getContentSize().height / 2)
    self._grid:addChild(self._gridLoadedExBottom, NewFormationView.kLessNormalZOrder)

    if self._container._formationType == self._container._formationModel.kFormationTypeCloud1 or
        self._container._formationType == self._container._formationModel.kFormationTypeCloud2 then
        self._gridStateWall = ccui.ImageView:create("grid_team_h_bg_forma.png", 1)
    else
        self._gridStateWall = ccui.ImageView:create("grid_team_w_bg_forma.png", 1)
    end
    self._gridStateWall:setVisible(false)
    self._gridStateWall:setPosition(self._grid:getContentSize().width / 2, self._grid:getContentSize().height / 2)
    self._grid:addChild(self._gridStateWall, NewFormationView.kNormalZOrder)

    self:setState(FormationGrid.kStateBlank)
end

function FormationGrid:getGridType()
    return self._gridType
end

function FormationGrid:getGridIndex()
    return self._gridIndex
end

function FormationGrid:getGridState()
    return self._gridState
end

function FormationGrid:getGrid()
    return self._grid
end

function FormationGrid:getIconView()
    return self._iconView
end

function FormationGrid:onLoaded()
    audioMgr:playSound("UploadS")
    self._gridLoaded:addEndCallback(function()
        self._gridLoaded:stop()
        self._gridLoaded:setVisible(false)
    end)
    self._gridLoaded:setVisible(true)
    self._gridLoaded:gotoAndPlay(0)

    self._gridLoadedBottom:addEndCallback(function()
        self._gridLoadedBottom:stop()
        self._gridLoadedBottom:setVisible(false)
    end)
    self._gridLoadedBottom:setVisible(true)
    self._gridLoadedBottom:gotoAndPlay(0)
end

function FormationGrid:onLoadedEx(isLoaded)
    audioMgr:playSound("UploadL")
    if isLoaded then
        self._gridLoadedEx:addEndCallback(function()
            self._gridLoadedEx:stop()
            self._gridLoadedEx:setVisible(false)
        end)
        self._gridLoadedEx:setVisible(true)
        self._gridLoadedEx:gotoAndPlay(0)
    else
        self._gridUnloadedEx:addEndCallback(function()
            self._gridUnloadedEx:stop()
            self._gridUnloadedEx:setVisible(false)
        end)
        self._gridUnloadedEx:setVisible(true)
        self._gridUnloadedEx:gotoAndPlay(0)
    end
    self._gridLoadedExBottom:addEndCallback(function()
        self._gridLoadedExBottom:stop()
        self._gridLoadedExBottom:setVisible(false)
    end)
    self._gridLoadedExBottom:setVisible(true)
    self._gridLoadedExBottom:gotoAndPlay(0)
end

function FormationGrid:setIconView(iconView)
    if self._iconView then
        self._iconView:setIconGrid()
        self._iconView:removeFromParent()
        self._iconView = nil
        self:unsetState(FormationGrid.kStateFull)
    end
    if iconView then
        iconView:retain()
        iconView:removeFromParent()
        if iconView:isFromIconGrid() then
            iconView:getIconGrid():setIconView()
        end
        self._iconView = iconView
        self._iconView:setRotation3D(cc.Vertex3F(NewFormationView.kIconRotateDegree, 0, 0))
        self._iconView:setPosition(self._grid:getContentSize().width / 2, self._grid:getContentSize().height / 2)
        self._iconView:updateState(NewFormationIconView.kIconStateBody)
        self._iconView:setIconGrid(self)
        self._grid:addChild(self._iconView, NewFormationView.kAboveNormalZOrder)
        iconView:release()
        self:setState(FormationGrid.kStateFull)
    end
end

function FormationGrid:isStateBlank()
    return 0x00 ~= bit.band(FormationGrid.kStateBlank, self._gridState)
end

function FormationGrid:isStateFull()
    return 0x00 ~= bit.band(FormationGrid.kStateFull, self._gridState)
end

function FormationGrid:isStateValid()
    return 0x00 ~= bit.band(FormationGrid.kStateValid, self._gridState)
end

function FormationGrid:isStateSelected()
    return 0x00 ~= bit.band(FormationGrid.kStateSelected, self._gridState)
end

function FormationGrid:isStateWall()
    return 0x00 ~= bit.band(FormationGrid.kStateWall, self._gridState)
end

function FormationGrid:isRecommend()
    local iconView = self:getIconView()
    if not iconView then return false end
    return self._container:isRecommend(iconView:getIconId())
end

function FormationGrid:isShowRedian()
    return self._container:isShowRedian()
end

function FormationGrid:setState(state)
    if 0x00 ~= bit.band(FormationGrid.kStateBlank, state) then
        self:unsetState(bit.bor(bit.bor(bit.bor(FormationGrid.kStateValid, FormationGrid.kStateInvalid), FormationGrid.kStateSelecting), FormationGrid.kStateSelected))
    elseif 0x00 ~= bit.band(FormationGrid.kStateFull, state) then
        self:unsetState(bit.bor(bit.bor(bit.bor(bit.bor(FormationGrid.kStateValid, FormationGrid.kStateInvalid), FormationGrid.kStateSelecting), FormationGrid.kStateAddition), FormationGrid.kStateSelected))
    elseif 0x00 ~= bit.band(FormationGrid.kStateValid, state) then
        self:unsetState(bit.bor(FormationGrid.kStateInvalid, FormationGrid.kStateSelected))
    elseif 0x00 ~= bit.band(FormationGrid.kStateInvalid, state) then
        self:unsetState(bit.bor(FormationGrid.kStateValid, FormationGrid.kStateSelected))
    elseif 0x00 ~= bit.band(FormationGrid.kStateSelecting, state) then
        self:unsetState(bit.bor(FormationGrid.kStateInvalid, FormationGrid.kStateSelected))
    elseif 0x00 ~= bit.band(FormationGrid.kStateAddition, state) then
        --self:unsetState(bit.bor(FormationGrid.kStateFull, FormationGrid.kStateWall))
        self:unsetState(FormationGrid.kStateFull)
    elseif 0x00 ~= bit.band(FormationGrid.kStateSelected, state) then
        self:unsetState(bit.bor(FormationGrid.kStateValid, FormationGrid.kStateInvalid))
    elseif 0x00 ~= bit.band(FormationGrid.kStateWall, state) then
        self:unsetState(bit.bor(bit.bor(bit.bor(FormationGrid.kStateValid, FormationGrid.kStateInvalid), FormationGrid.kStateSelecting), FormationGrid.kStateSelected))
    end
    self._gridState = bit.bor(self._gridState, state)
end

function FormationGrid:unsetState(state)
    self._gridState = bit.band(self._gridState, bit.bnot(state))
end

function FormationGrid:getNormalZorder()
    return NewFormationView.kNormalZOrder + math.floor(self:getGridIndex() / 4)
end

function FormationGrid:updateState()
    self._gridStateFull:setVisible( 0x00 ~= bit.band(FormationGrid.kStateFull, self._gridState) )
    self._gridStateFullEx:setVisible(self._gridStateFull:isVisible() and self:isShowRedian() and self:isRecommend())
    self._gridStateFullEx1:setVisible(self._gridStateFull:isVisible() and self:isShowRedian() and self:isRecommend())
    self._gridStateValid:setVisible( 0x00 ~= bit.band(FormationGrid.kStateValid, self._gridState) )
    self._gridStateInvalid:setVisible( 0x00 ~= bit.band(FormationGrid.kStateInvalid, self._gridState) )
    self._gridStateSelecting:setVisible( 0x00 ~= bit.band(FormationGrid.kStateSelecting, self._gridState) )
    self._gridStateSelected:setVisible( 0x00 ~= bit.band(FormationGrid.kStateSelected, self._gridState) )
    self._gridStateAddition:setVisible( 0x00 ~= bit.band(FormationGrid.kStateAddition, self._gridState) )
    self._gridStateWall:setVisible( 0x00 ~= bit.band(FormationGrid.kStateWall, self._gridState) )
    --self._grid:setLocalZOrder( 0x00 ~= bit.band(FormationGrid.kStateSelecting, self._gridState) and NewFormationView.kAboveHighestZOrder or self:getNormalZorder())
end

function NewFormationView:dealWithEnemyFormationData()
    if not (self._enemyFormationData and type(self._enemyFormationData) == "table") then return end
    for k, v in pairs(self._enemyFormationData) do
        if not v.score then
            v.score = 0
        end
        v.filter = self._formationModel.decodeFilterString(v.filter)
    end
end

function NewFormationView:isNewFormationViewEx()
    return (self._formationType == self._formationModel.kFormationTypeCityBattle1 or 
           self._formationType == self._formationModel.kFormationTypeCityBattle2 or 
           self._formationType == self._formationModel.kFormationTypeCityBattle3 or 
           self._formationType == self._formationModel.kFormationTypeCityBattle4 or 
           self._formationType == self._formationModel.kFormationTypeLeague or
           self._formationType == self._formationModel.kFormationTypeHeroDuel or
           self._formationType == self._formationModel.kFormationTypeGodWar1 or
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
           self._formationType == self._formationModel.kFormationTypeGloryArenaDef3
           )
            --[[or 
           self._formationType == self._formationModel.kFormationTypeCrossPKAtk1 or 
           self._formationType == self._formationModel.kFormationTypeCrossPKAtk2 or 
           self._formationType == self._formationModel.kFormationTypeCrossPKAtk3 or 
           self._formationType == self._formationModel.kFormationTypeCrossPKDef1 or 
           self._formationType == self._formationModel.kFormationTypeCrossPKDef2 or 
           self._formationType == self._formationModel.kFormationTypeCrossPKDef3]]
end

function NewFormationView:isShowEnemyFormation()
    return (self._enemyFormationData and type(self._enemyFormationData) == "table")
end

function NewFormationView:isShowEnemyFormationCheckArrow()

    if self._formationType == self._formationModel.kFormationTypeArena then
        return false
    end

    if self._formationType == self._formationModel.kFormationTypeElemental1 or
       self._formationType == self._formationModel.kFormationTypeElemental2 or
       self._formationType == self._formationModel.kFormationTypeElemental3 or
       self._formationType == self._formationModel.kFormationTypeElemental4 or
       self._formationType == self._formationModel.kFormationTypeElemental5 then
       return false
    end

    if self._formationType == self._formationModel.kFormationTypeCrossPKAtk1 or 
       self._formationType == self._formationModel.kFormationTypeCrossPKAtk2 or 
       self._formationType == self._formationModel.kFormationTypeCrossPKAtk3 or 
       self._formationType == self._formationModel.kFormationTypeCrossPKDef1 or 
       self._formationType == self._formationModel.kFormationTypeCrossPKDef2 or 
       self._formationType == self._formationModel.kFormationTypeCrossPKDef3 then
        return false
    end

    if self._formationType == self._formationModel.kFormationTypeStakeAtk1 then
        return false
    end
    
    return self:isShowEnemyFormation()
end

function NewFormationView:isShowCountDownInfo()
    return self:isShowEnemyFormation() and self._formationType == self._formationModel.kFormationTypeLeague
end

function NewFormationView:isShowNextFight()
    return (self:isShowCloudInfo() or self:isShowStakeAtkDef2()) and self._extend.enterBattle and not self._extend.enterBattle[self._context._formationId]
end

function NewFormationView:isSwitchFormationButtonDisabled()
    if not self:isShowCloudInfo() then return false end
    local formationId1 = self._formationType
    local formationId2 = self._formationModel.kFormationTypeCloud1 + self._formationModel.kFormationTypeCloud2 - formationId1
    return (self._extend.enterBattle and self._extend.enterBattle[formationId1] and not self._extend.enterBattle[formationId2])
end

function NewFormationView:isShowButtonCareer()
    return self._formationType == self._formationModel.kFormationTypeCommon
end

function NewFormationView:isShowCitySelectInfo()
    return SystemUtils:enableWeapon() and self._formationType == self._formationModel.kFormationTypeWeaponDef and not (self._extend and self._extend.hideDefWeapon)
end

function NewFormationView:isShowButtonTraining()
    return self._formationType == self._formationModel.kFormationTypeTraining
end

function NewFormationView:isShowBullet()
    return self:isShowButtonTraining() and not (self._extend and self._extend.hideBullet)
end

function NewFormationView:isShowButtonSelect()
    return false
    --[[
    return not (self:isShowEnemyFormation() or 
           self._formationType == self._formationModel.kFormationTypeArena or 
           self._formationType == self._formationModel.kFormationTypeAiRenMuWu or 
           self._formationType == self._formationModel.kFormationTypeZombie or 
           self._formationType == self._formationModel.kFormationTypeDragon or 
           self._formationType == self._formationModel.kFormationTypeDragon1 or 
           self._formationType == self._formationModel.kFormationTypeDragon2 or 
           self._formationType == self._formationModel.kFormationTypeCrusade or
           self._formationType == self._formationModel.kFormationTypeMF or
           self._formationType == self._formationModel.kFormationTypeMFDef)
    ]]
end

function NewFormationView:isShowReadyBattle()
    return self:isShowCountDownInfo() and not self._isBattleButtonClicked
end

function NewFormationView:isShowAlreadyBattle()
    return self:isShowCountDownInfo() and self._isBattleButtonClicked
end

function NewFormationView:isShowButtonBattle()
    return (self:isShowEnemyFormation() or 
           self._formationType == self._formationModel.kFormationTypeAiRenMuWu or 
           self._formationType == self._formationModel.kFormationTypeZombie or 
           self._formationType == self._formationModel.kFormationTypeDragon or
           self._formationType == self._formationModel.kFormationTypeDragon1 or
           self._formationType == self._formationModel.kFormationTypeDragon2 or
           self._formationType == self._formationModel.kFormationTypeMF or
           --self._formationType == self._formationModel.kFormationTypeMFDef or
           self._formationType == self._formationModel.kFormationTypeCloud1 or
           self._formationType == self._formationModel.kFormationTypeCloud2 or
           self._formationType == self._formationModel.kFormationTypeAdventure or
           self._formationType == self._formationModel.kFormationTypeTraining or
           self._formationType == self._formationModel.kFormationTypeGuild or
           self._formationType == self._formationModel.kFormationTypeElemental1 or
           self._formationType == self._formationModel.kFormationTypeElemental2 or
           self._formationType == self._formationModel.kFormationTypeElemental3 or
           self._formationType == self._formationModel.kFormationTypeElemental4 or
           self._formationType == self._formationModel.kFormationTypeElemental5 or
           self._formationType == self._formationModel.kFormationTypeWeapon or
           self._formationType == self._formationModel.kFormationTypeWeaponDef or 
           self._formationType == self._formationModel.kFormationTypeStakeAtk2 or 
           self._formationType == self._formationModel.kFormationTypeStakeDef2 or 
           self._formationType == self._formationModel.kFormationTypeProfession1 or 
           self._formationType == self._formationModel.kFormationTypeProfession2 or 
           self._formationType == self._formationModel.kFormationTypeProfession3 or 
           self._formationType == self._formationModel.kFormationTypeProfession4 or 
           self._formationType == self._formationModel.kFormationTypeProfession5 or 
           self._formationType == self._formationModel.kFormationTypeWorldBoss)
end

function NewFormationView:isShowHireTeam()
    if not (self._formationType == self._formationModel.kFormationTypeCrusade or 
       self._formationType == self._formationModel.kFormationTypeElemental1 or
       self._formationType == self._formationModel.kFormationTypeElemental2 or
       self._formationType == self._formationModel.kFormationTypeElemental3 or
       self._formationType == self._formationModel.kFormationTypeElemental4 or
       self._formationType == self._formationModel.kFormationTypeElemental5) then
        return false
    end

    if not (self._extend and self._extend.hireTeams) then return false end

    return true
end

function NewFormationView:isCheckHireTeam()
    if not self:isShowHireTeam() then return -1 end
    return self._extend.isShowHireTeam
end

function NewFormationView:isShowDescriptionView(iconType)
    return not (iconType == NewFormationIconView.kIconTypeInstanceHero or
           iconType == NewFormationIconView.kIconTypeAiRenMuWuHero or
           iconType == NewFormationIconView.kIconTypeZombieHero or
           iconType == NewFormationIconView.kIconTypeDragonHero or
           GuideUtils.isGuideRunning)
end

function NewFormationView:isShowBattleTip()
    return (self._formationType == self._formationModel.kFormationTypeCommon or
           --(self._formationType == self._formationModel.kFormationTypeArena and (self._modelMgr:getModel("UserModel"):getData().lvl >= 16)) or
            self._formationType == self._formationModel.kFormationTypeAiRenMuWu or 
            self._formationType == self._formationModel.kFormationTypeZombie or 
            self._formationType == self._formationModel.kFormationTypeDragon or
            self._formationType == self._formationModel.kFormationTypeDragon1 or
            self._formationType == self._formationModel.kFormationTypeDragon2 or
            self._formationType == self._formationModel.kFormationTypeMF or
            self._formationType == self._formationModel.kFormationTypeMFDef or
            self._formationType == self._formationModel.kFormationTypeCloud1 or
            self._formationType == self._formationModel.kFormationTypeCloud2 or
            self._formationType == self._formationModel.kFormationTypeAdventure or
            self._formationType == self._formationModel.kFormationTypeTraining or 
            self._formationType == self._formationModel.kFormationTypeProfession1 or 
            self._formationType == self._formationModel.kFormationTypeProfession2 or 
            self._formationType == self._formationModel.kFormationTypeProfession3 or 
            self._formationType == self._formationModel.kFormationTypeProfession4 or 
            self._formationType == self._formationModel.kFormationTypeProfession5 or 
            self._formationType == self._formationModel.kFormationTypeWorldBoss)
end

function NewFormationView:isShowWeaponInfo()
    --(self._formationType ~= self._formationModel.kFormationTypeCrossPKFight) add by yuxiaojing
    return SystemUtils:enableWeapon() and ((self._formationType == self._formationModel.kFormationTypeWeapon or self._formationType == self._formationModel.kFormationTypeWeaponDef) or (self._extend and self._extend.isShowWeapon)) and (self._formationType ~= self._formationModel.kFormationTypeCrossPKFight)
end

function NewFormationView:isShowEnemyInsFormation()
    if not self:isShowEnemyFormation() then return false end
    local enemyFormationData = self._enemyFormationData[self._context._formationId]
    if not enemyFormationData then return false end
    for i=1, 3 do
        if enemyFormationData["weapon" .. i] and 0 ~= enemyFormationData["weapon" .. i] then return true end
    end
    return false
end

function NewFormationView:isShowInsFormation()
    return (SystemUtils:enableWeapon() and 4 == self._weaponsModel:getWeaponState()) and
           ((self._formationType == self._formationModel.kFormationTypeCommon and not self._extend.hideWeapon and not self._extend.isSimpleFormation) or
           ((self._formationType == self._formationModel.kFormationTypeArena or self._formationType == self._formationModel.kFormationTypeArenaDef) and (self._modelMgr:getModel("UserModel"):getData().lvl >= 16)) or
           self._formationType == self._formationModel.kFormationTypeCrusade or
           self._formationType == self._formationModel.kFormationTypeLeague or
           self._formationType == self._formationModel.kFormationTypeGodWar1 or
           self._formationType == self._formationModel.kFormationTypeGodWar2 or
           self._formationType == self._formationModel.kFormationTypeGodWar3 or
           self._formationType == self._formationModel.kFormationTypeCityBattle1 or
           self._formationType == self._formationModel.kFormationTypeCityBattle2 or
           self._formationType == self._formationModel.kFormationTypeCityBattle3 or
           self._formationType == self._formationModel.kFormationTypeCityBattle4 or
           self._formationType == self._formationModel.kFormationTypeGuild or
           self._formationType == self._formationModel.kFormationTypeGuildDef or
           self._formationType == self._formationModel.kFormationTypeWeapon or
           self._formationType == self._formationModel.kFormationTypeClimbTower or  
           self._formationType == self._formationModel.kFormationTypeCrossGodWar1 or
           self._formationType == self._formationModel.kFormationTypeCrossGodWar2 or
           self._formationType == self._formationModel.kFormationTypeCrossGodWar3 or
           self._formationType == self._formationModel.kFormationTypeStakeAtk1 or  
           self._formationType == self._formationModel.kFormationTypeStakeAtk2 or  
           self._formationType == self._formationModel.kFormationTypeStakeDef2 or  
           self._formationType == self._formationModel.kFormationTypeGloryArenaAtk1 or  
           self._formationType == self._formationModel.kFormationTypeGloryArenaAtk2 or  
           self._formationType == self._formationModel.kFormationTypeGloryArenaAtk3 or  
           self._formationType == self._formationModel.kFormationTypeGloryArenaDef1 or  
           self._formationType == self._formationModel.kFormationTypeGloryArenaDef2 or  
           self._formationType == self._formationModel.kFormationTypeGloryArenaDef3 or  
           self._formationType == self._formationModel.kFormationTypeCrossPKAtk1 or  
           self._formationType == self._formationModel.kFormationTypeCrossPKAtk2 or  
           self._formationType == self._formationModel.kFormationTypeCrossPKAtk3 or  
           self._formationType == self._formationModel.kFormationTypeCrossPKDef1 or  
           self._formationType == self._formationModel.kFormationTypeCrossPKDef2 or  
           self._formationType == self._formationModel.kFormationTypeCrossPKDef3 or  
           self._formationType == self._formationModel.kFormationTypeCrossPKFight or 
           self._formationType == self._formationModel.kFormationTypeWorldBoss or  
           (self._extend and self._extend.isShowWeapon))
end

function NewFormationView:isShowInsEvn()
    return (self._formationType == self._formationModel.kFormationTypeWeapon or self._formationType == self._formationModel.kFormationTypeWeaponDef)
end

function NewFormationView:isInsBubbleShow()
    if not self:isShowInsFormation() then return false end
    return self._formationModel:isWeaponTipsShow(self._context._formationId)
end

function NewFormationView:isShowRecommend()
    return (self._formationType == self._formationModel.kFormationTypeCommon or
           (self._formationType == self._formationModel.kFormationTypeArena and (self._modelMgr:getModel("UserModel"):getData().lvl >= 16)) or
            self._formationType == self._formationModel.kFormationTypeAiRenMuWu or 
            self._formationType == self._formationModel.kFormationTypeZombie or 
            self._formationType == self._formationModel.kFormationTypeDragon or
            self._formationType == self._formationModel.kFormationTypeDragon1 or
            self._formationType == self._formationModel.kFormationTypeDragon2 or 
            self._formationType == self._formationModel.kFormationTypeWorldBoss)
end

function NewFormationView:isShowPveRecommendHero()
        return (self._formationType == self._formationModel.kFormationTypeAiRenMuWu or 
             self._formationType == self._formationModel.kFormationTypeZombie or 
             self._formationType == self._formationModel.kFormationTypeProfession1 or 
             self._formationType == self._formationModel.kFormationTypeProfession2 or 
             self._formationType == self._formationModel.kFormationTypeProfession3 or 
             self._formationType == self._formationModel.kFormationTypeProfession4 or 
             self._formationType == self._formationModel.kFormationTypeProfession5 or 
             self._formationType == self._formationModel.kFormationTypeWorldBoss)
end

function NewFormationView:isShowRedian()
    return self._formationType == self._formationModel.kFormationTypeLeague
end

function NewFormationView:isShowCloudInfo()
    return (self._formationType == self._formationModel.kFormationTypeCloud1 or self._formationType == self._formationModel.kFormationTypeCloud2)
end

function NewFormationView:isShowCrossPKLimitInfo()
    if self:isShowAwakingTaskInfo() then return false end
    if not (self._extend and self._extend.crosspkLimitInfo) then return false end
    return (self._formationType == self._formationModel.kFormationTypeCrossPKAtk1 or 
           self._formationType == self._formationModel.kFormationTypeCrossPKAtk2 or 
           self._formationType == self._formationModel.kFormationTypeCrossPKAtk3 or 
           self._formationType == self._formationModel.kFormationTypeCrossPKDef1 or 
           self._formationType == self._formationModel.kFormationTypeCrossPKDef2 or 
           self._formationType == self._formationModel.kFormationTypeCrossPKDef3)
end

function NewFormationView:isShowStakeAtkDef2(  )
    return (self._formationType == self._formationModel.kFormationTypeStakeAtk2 or self._formationType == self._formationModel.kFormationTypeStakeDef2)
end

function NewFormationView:isShowAwakingTaskInfo()
    if not (self._formationType == self._formationModel.kFormationTypeArena or
            self._formationType == self._formationModel.kFormationTypeLeague or
            self._formationType == self._formationModel.kFormationTypeCrusade or
            self._formationType == self._formationModel.kFormationTypeGuild or
            self._formationType == self._formationModel.kFormationTypeAiRenMuWu or 
            self._formationType == self._formationModel.kFormationTypeZombie or 
            self._formationType == self._formationModel.kFormationTypeDragon or
            self._formationType == self._formationModel.kFormationTypeDragon1 or
            self._formationType == self._formationModel.kFormationTypeDragon2) then
            return false
    end

    if not self._awakingModel:isAwakingTaskOpened() then 
        return false
    end

    local taskId = self._awakingModel:getCurrentAwakingTaskId()
    local awakingTaskData = tab:AwakingTask(taskId)
    if not awakingTaskData then return false end
    local showFormationId = awakingTaskData.buzhenshow
    if not showFormationId then return false end
    local found = false
    for _, v in ipairs(showFormationId) do
        if self._formationType == v then
            found = true
            break
        end
    end
    if not found then return false end
    if awakingTaskData["heros"] or awakingTaskData["warrior"] or awakingTaskData["needRace"] or awakingTaskData["needClass"] then
        return true
    end

    return false
end

function NewFormationView:isShowTreasureInfo()
    local isTreasureInfoShow =  SystemUtils:enableTreasure() 
                            and self._formationType ~= self._formationModel.kFormationTypeHeroDuel 
                            and self._formationType ~= self._formationModel.kFormationTypeTraining
                            and not self._extend.isSimpleFormation
    if isTreasureInfoShow then
        local sfc = cc.SpriteFrameCache:getInstance()
        local tc = cc.Director:getInstance():getTextureCache() 
        if not tc:getTextureForKey("bigSkillFrame_treasureSkill.png") then
            sfc:addSpriteFrames("asset/ui/treasureSkill.plist", "asset/ui/treasureSkill.png")
        end
    end
    print("self._formationType:" .. self._formationType)
    return isTreasureInfoShow 
end

function NewFormationView:isShowPokedexInfo()
    local isTreasureInfoShow =  SystemUtils:enablePokedex() 
                            and self._formationType ~= self._formationModel.kFormationTypeHeroDuel 
                            and self._formationType ~= self._formationModel.kFormationTypeTraining
                            and not self._extend.isSimpleFormation
    return isTreasureInfoShow 
    --[[
    local isTreasureInfoShow =  SystemUtils:enableTreasure() 
                            and self._formationType ~= self._formationModel.kFormationTypeHeroDuel 
                            and self._formationType ~= self._formationModel.kFormationTypeTraining
    if isTreasureInfoShow then
        local sfc = cc.SpriteFrameCache:getInstance()
        local tc = cc.Director:getInstance():getTextureCache() 
        if not tc:getTextureForKey("bigSkillFrame_treasureSkill.png") then
            sfc:addSpriteFrames("asset/ui/treasureSkill.plist", "asset/ui/treasureSkill.png")
        end
    end
    return isTreasureInfoShow 
    ]]
end

function NewFormationView:isShowPveInfo()
    return (self._formationType == self._formationModel.kFormationTypeAiRenMuWu or 
            self._formationType == self._formationModel.kFormationTypeZombie or 
            self._formationType == self._formationModel.kFormationTypeDragon or
            self._formationType == self._formationModel.kFormationTypeDragon1 or
            self._formationType == self._formationModel.kFormationTypeDragon2 or 
            self._formationType == self._formationModel.kFormationTypeWorldBoss or 
            self._formationType == self._formationModel.kFormationTypeProfession1 or 
            self._formationType == self._formationModel.kFormationTypeProfession2 or 
            self._formationType == self._formationModel.kFormationTypeProfession3 or 
            self._formationType == self._formationModel.kFormationTypeProfession4 or 
            self._formationType == self._formationModel.kFormationTypeProfession5)
end

function NewFormationView:isShowButtonReturn()
--    return not (self:isShowCountDownInfo()--[[ or self._formationType == self._formationModel.kFormationTypeAdventure]]) and (self._extend and not self._extend.isSimpleFormation)
    if self._extend and self._extend.isSimpleFormation then
        return false
    else
        return not (self:isShowCountDownInfo()--[[ or self._formationType == self._formationModel.kFormationTypeAdventure]])
    end
end

function NewFormationView:isHaveExtendHeroes()
    return (self._extend and self._extend.heroes and (#self._extend.heroes > 0))
end

function NewFormationView:isHaveFixedHero()
    return (self._extend and self._extend.fixedHero)
end

function NewFormationView:dealWithFixedHero()
    if self._formationType ~= self._formationModel.kFormationTypeCommon then return end
    if not (self._layerLeft._teamFormation._data and self._layerLeft._teamFormation._data[self._formationModel.kFormationTypeCommon]) then return end
    local formationData = self._layerLeft._teamFormation._data[self._formationModel.kFormationTypeCommon]
    formationData.heroId = self._extend.fixedHero
end

function NewFormationView:isHaveDefaultHero()
    return (self._extend and self._extend.defaultHero)
end

function NewFormationView:dealWithDefaultHero()
    if self._formationType ~= self._formationModel.kFormationTypeCommon then return end
    if not (self._layerLeft._teamFormation._data and self._layerLeft._teamFormation._data[self._formationModel.kFormationTypeCommon]) then return end
    local formationData = self._layerLeft._teamFormation._data[self._formationModel.kFormationTypeCommon]
    formationData.heroId = self._extend.defaultHero
end

function NewFormationView:isHaveFixedWeapon()
    return not not (--[[SystemUtils:enableWeapon() and]] self._extend and self._extend.fixedWeapon)
end

function NewFormationView:dealWithFixedWeapon()
    if self._formationType ~= self._formationModel.kFormationTypeWeapon or not self:isHaveFixedWeapon() then return end
    if not (self._layerLeft._teamFormation._data and self._layerLeft._teamFormation._data[self._formationModel.kFormationTypeWeapon]) then return end
    local formationData = self._layerLeft._teamFormation._data[self._formationModel.kFormationTypeWeapon]
    local fixedWeapon = self._extend.fixedWeapon
    for i=1, #fixedWeapon do
        local weaponId = fixedWeapon[i][1]
        local weaponType = fixedWeapon[i][2]
        formationData["weapon" .. weaponType] = weaponId
    end
end

function NewFormationView:showFixedWeaponInfo()
    if not self:isHaveFixedWeapon() then return end
    if not self._fixedWeaponShowing then
        self._fixedWeaponShowing = clone(self._extend.fixedWeapon)
        self._fixedWeaponShowingIndex = 1
    end

    if self._fixedWeaponShowingIndex > #self._fixedWeaponShowing then return end

    local fixedWeaponData = self._fixedWeaponShowing[self._fixedWeaponShowingIndex]
    if 1 ~= SystemUtils.loadAccountLocalData("FORMATION_FIXED_WEAPON_INFO_SHOWED_" .. fixedWeaponData[1] .. "_" .. fixedWeaponData[2]) then
        ScheduleMgr:delayCall(300, nil, function()
            self._viewMgr:showDialog("weapons.WeaponsUnlockSuccessDialog", {weaponId = fixedWeaponData[1], weaponType = fixedWeaponData[2], isShowLimitInfo = true, callback = function()
                SystemUtils.saveAccountLocalData("FORMATION_FIXED_WEAPON_INFO_SHOWED_" .. fixedWeaponData[1] .. "_" .. fixedWeaponData[2], 1)
                if self._fixedWeaponShowingIndex and self.showFixedWeaponInfo then
                    self._fixedWeaponShowingIndex = self._fixedWeaponShowingIndex + 1
                    self:showFixedWeaponInfo()
                end
            end})
        end)
    else
        if self._fixedWeaponShowingIndex and self.showFixedWeaponInfo then
            self._fixedWeaponShowingIndex = self._fixedWeaponShowingIndex + 1
            self:showFixedWeaponInfo()
        end
    end
end

function NewFormationView:showUnlockWeaponInfo()
    if not self:isShowInsFormation() then return end
    if not self._unlockWeaponShowing then
        self._unlockWeaponShowing = clone(self._weaponsModel:getWeaponsDataF())
        self._unlockWeaponShowingIndex = 1
    end

    if self._unlockWeaponShowingIndex > #self._unlockWeaponShowing then return end

    local unlockWeaponData = self._unlockWeaponShowing[self._unlockWeaponShowingIndex]
    if 1 ~= SystemUtils.loadAccountLocalData("FORMATION_UNLOCK_WEAPON_INFO_SHOWED_" .. unlockWeaponData["weaponId"] .. "_" .. unlockWeaponData["weaponType"]) then
        ScheduleMgr:delayCall(300, nil, function()
            self._viewMgr:showDialog("weapons.WeaponsUnlockSuccessDialog", {weaponId = unlockWeaponData["weaponId"], unlockWeaponData["weaponType"], callback = function()
                SystemUtils.saveAccountLocalData("FORMATION_UNLOCK_WEAPON_INFO_SHOWED_" .. unlockWeaponData["weaponId"] .. "_" .. unlockWeaponData["weaponType"], 1)
                if self._unlockWeaponShowingIndex and self.showUnlockWeaponInfo then
                    self._unlockWeaponShowingIndex = self._unlockWeaponShowingIndex + 1
                    self:showUnlockWeaponInfo()
                end
            end})
        end)
    end
end

function NewFormationView:isShowTalk()
    return (self._extend and self._extend.talkId)
end

function NewFormationView:isScenarioHero(heroId)
    if self._formationType ~= self._formationModel.kFormationTypeCommon then return false end
    if self._scenarioHero and self._scenarioHero == heroId then return true end
    return false
end

function NewFormationView:isHaveScenarioHero()
    if self._formationType ~= self._formationModel.kFormationTypeCommon then return false end
    if self:isHaveFixedHero() or self._scenarioHero then return true end
    return false
end

function NewFormationView:setFormationLocked(locked)
    self._formationLocked = locked
end

function NewFormationView:isFormationLocked(locked)
    return self._formationLocked
end

function NewFormationView:onComplete()
    self._viewMgr:enableScreenWidthBar()
end

function NewFormationView:updateExtendBtn(  )
    local posX = {45, 116}
    local panelBG = self._extendBG:getChildByFullName('Panel_96')
    self._extendBG:setVisible(false)
    local careerBtn = panelBG:getChildByFullName('btn_career')
    local buildsBtn = panelBG:getChildByFullName('btn_builds')
    careerBtn:setVisible(false)
    buildsBtn:setVisible(false)

    local bgImg = panelBG:getChildByFullName('Image_89')
    local extendBtn = panelBG:getChildByName('button')

    panelBG:setContentSize(cc.size(83, panelBG:getContentSize().height))
    bgImg:setContentSize(cc.size(83, bgImg:getContentSize().height))
    local extendBtn1 = panelBG:getChildByFullName('button')
    local extendBtn2 = panelBG:getChildByFullName('button_1')
    local btnList = {}

    local isShowCareer = self:isShowButtonCareer()
    if isShowCareer then
        table.insert(btnList, careerBtn)
        self:registerClickEvent(careerBtn, function ()
            self:showTeamCareerInfo()
        end)
    end
    local isShowBuilds = self:isShowButtonTraining()
    if not isShowBuilds then
        table.insert(btnList, buildsBtn)
        self:registerClickEvent(buildsBtn, function ()
            self:onButtonBuildsClicked()
        end)
        buildsBtn:setVisible(true)
    end
    for k, v in pairs(btnList) do
        v:setVisible(true)
        v:setPositionX(posX[k])
    end

    if #btnList == 2 then
        panelBG:setContentSize(cc.size(158, panelBG:getContentSize().height))
        bgImg:setContentSize(cc.size(158, bgImg:getContentSize().height))
    end
    extendBtn1:setPositionX(bgImg:getContentSize().width + 11)
    extendBtn2:setPositionX(bgImg:getContentSize().width + 11)

    panelBG:setPositionX(-(panelBG:getContentSize().width - 10))
    extendBtn1:setVisible(true)
    extendBtn2:setVisible(false)
    self:registerClickEvent(extendBtn1, function (  )
        extendBtn2:setVisible(true)
        extendBtn1:setVisible(false)
        panelBG:runAction(cc.MoveBy:create(0.1, cc.p(panelBG:getContentSize().width - 10, 0)))
    end)

    self:registerClickEvent(extendBtn2, function (  )
        extendBtn2:setVisible(false)
        extendBtn1:setVisible(true)
        panelBG:runAction(cc.MoveBy:create(0.1, cc.p(-(panelBG:getContentSize().width - 10), 0)))
    end)

    if #btnList > 0 then
        self._extendBG:setVisible(true)
    end

    -- self._btnCareer = self:getUI("bg.layer_information.btn_career")
    -- self._btnCareer:setVisible(self:isShowButtonCareer())
    -- if self:isShowButtonCareer() then
    --     self:registerClickEvent(self._btnCareer , function ()
    --         self:showTeamCareerInfo()
    --     end)
    -- end

    -- self._layerLeft._relationBuildUI._btnBuilds = self:getUI("bg.layer_information.btn_builds")
    -- self._layerLeft._relationBuildUI._btnBuilds:setVisible(not self:isShowButtonTraining())
    -- self:registerClickEvent(self._layerLeft._relationBuildUI._btnBuilds, function ()
    --     self:onButtonBuildsClicked()
    -- end)
end

function NewFormationView:getBackupFilterList(  )
    -- Redmine #21851 特殊情况处理
    if self._formationType ~= self._formationModel.kFormationTypeCrusade and 
        self._formationType ~= self._formationModel.kFormationTypeCrossPKAtk1 and 
        self._formationType ~= self._formationModel.kFormationTypeCrossPKAtk2 and 
        self._formationType ~= self._formationModel.kFormationTypeCrossPKAtk3 and 
        self._formationType ~= self._formationModel.kFormationTypeCrossPKFight and 
        self._formationType ~= self._formationModel.kFormationTypeCrossPKDef1 and 
        self._formationType ~= self._formationModel.kFormationTypeCrossPKDef2 and 
        self._formationType ~= self._formationModel.kFormationTypeCrossPKDef3 and 
        self._formationType ~= self._formationModel.kFormationTypeGuild and 
        self._formationType ~= self._formationModel.kFormationTypeGuildDef then
        return {}
    end
    local data = clone(self._teamModel:getData())
    local t2 = {}
    for k, v in pairs(data) do
        repeat
            if self:isLoaded(NewFormationView.kGridTypeTeam, v.teamId) then break end
            if self:isFiltered(v.teamId) then
                table.insert(t2, v.teamId)
            end
        until true
    end
    return t2
end

function NewFormationView:getUsingTeamList(  )
    local formationData = self._layerLeft._teamFormation._data[self._context._formationId]
    local teamUsing = {}
    for i = 1, NewFormationView.kTeamMaxCount do
        local teamId = formationData["team" .. i]
        if teamId and teamId ~= 0 then
            table.insert(teamUsing, teamId)
        end
    end
    if self:isShowCloudInfo() then
        local formationId = self._formationModel.kFormationTypeCloud1 + self._formationModel.kFormationTypeCloud2 - self._context._formationId
        local data = self._layerLeft._teamFormation._data[formationId]
        for i = 1, NewFormationView.kTeamMaxCount do
            local teamId = data["team" .. i]
            if teamId and teamId ~= 0 then
                table.insert(teamUsing, teamId)
            end
        end
    end
    return teamUsing
end

function NewFormationView:updateBackupInfo(  )
    self._backupBG:setVisible(false)
    if not table.indexof(self._formationModel.kBackupFormation, self._context._formationId) or not self._backupModel:isOpen() then
        return
    end
    local formationData = self._layerLeft._teamFormation._data[self._context._formationId]
    -- 自动下不能用的兵团
    local noUseList = self:getBackupFilterList()
    local backupTs = formationData.backupTs or {}
    for k, v in pairs(backupTs) do
        for i = 1, 3 do
            local teamId = v["bt" .. i]
            if teamId and (teamId == 0 or table.indexof(noUseList, teamId)) then
                v["bt" .. i] = nil
            end
        end
    end
    local label = self._backupBG:getChildByFullName('name')
    if formationData.bid and backupTs[tostring(formationData.bid)] then
        local addImg = self._backupBG:getChildByName("addImg")
        if addImg then
            addImg:setVisible(false)
        end
        local data = tab.backupMain[formationData.bid]
        local sData = self._backupModel:getBackupById(data.id) or {}
        label:setString(lang(data.name) .. " Lv." .. (sData.lv or 1))
        local formationIcons = self._backupModel:handleBackupThumb(self._backupBG, data.icon)
        self._backupModel:handleFormation(formationIcons, data.icon)
    else
        label:setString("尚未选择阵型")
        self._backupModel:clearBackupThumb(self._backupBG)
        local addImg = self._backupBG:getChildByName("addImg")
        if not addImg then
            addImg = ccui.Button:create()
            addImg:loadTextures("golbalIamgeUI5_add.png", "golbalIamgeUI5_add.png", "golbalIamgeUI5_add.png", 1)
            addImg:setAnchorPoint(cc.p(0.5, 0.5))
            addImg:setPosition(cc.p(42, self._backupBG:getContentSize().height / 2))
            addImg:setName("addImg")
            addImg:setScale(0.5)
            self._backupBG:addChild(addImg, 10)
            addImg:setScale(0.5)
            addImg:setSwallowTouches(false)
            addImg:runAction(cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.Spawn:create(cc.ScaleTo:create(1, 0.4), cc.FadeTo:create(1, 180)),
                    cc.Spawn:create(cc.ScaleTo:create(1, 0.5), cc.FadeTo:create(1, 255))
                )))
        else
            addImg:setVisible(true)
        end
    end

    -- 气泡提示
    local isTips = false
    local img_tip = self._backupBG:getChildByFullName('img_qipao')
    img_tip:setVisible(false)
    if not formationData.bid then
        img_tip:loadTexture('qipao_xuanzehouyuan.png', 1)
        img_tip:setVisible(true)
        isTips = true
    end

    local teamUsing = self:getUsingTeamList()

    local isHaveEmptySeat = self._backupModel:isHaveEmptySeat(formationData.backupTs, formationData.bid, clone(noUseList), clone(teamUsing))

    if not isTips and isHaveEmptySeat then
        img_tip:loadTexture('qipao_jiaren.png', 1)
        img_tip:setVisible(true)
        isTips = true
    end

    local isHaveConflictTeam = self._backupModel:isHaveConflictTeam(formationData.backupTs, formationData.bid, clone(teamUsing))

    if not isTips and isHaveConflictTeam then
        img_tip:loadTexture('qipao_bingtuanchongtu.png', 1)
        img_tip:setVisible(true)
        isTips = true
    end

    if isTips then
        local seq = cc.Sequence:create(cc.ScaleTo:create(1, 1.2), cc.ScaleTo:create(1, 1))
        img_tip:runAction(cc.RepeatForever:create(seq))
    else
        img_tip:stopAllActions()
    end

    self._backupBG:setVisible(true)
    local button = self._backupBG:getChildByFullName('Button_83')
    self:registerClickEvent(button, function (  )
        if self._isBattleButtonClicked and self._formationType == self._formationModel.kFormationTypeLeague then
            return
        end
        -- dump(self._layerLeft._teamFormation._data[self._context._formationId], "============", 10)
        local formationData = self._layerLeft._teamFormation._data[self._context._formationId]
        local teamUsing, backupTeamUsing = self:getUsingTeamList()
        self._modelMgr:getModel('BackupModel'):showBackupFormationDialog({
            bid = formationData.bid,
            backupTs = clone(formationData.backupTs or {}),
            teamUsing = clone(teamUsing),
            formationType = self._context._formationId,
            sortList = self:getBackupFilterList(),
            formationView = self,
            callback = function( bid, data )
                formationData.bid = bid
                formationData.backupTs = clone(data)
                self:updateBackupInfo()
                self:refreshItemsTableView()
                self:updateRelative()
            end})
    end)
end

function NewFormationView:onInit()
    if self:isShowEnemyFormation() then
        self._musicFileName = audioMgr:getMusicFileName()
        audioMgr:playMusic("preFormation", true)
    end

    self:disableTextEffect()

    self._scheduler = cc.Director:getInstance():getScheduler()
    self._winSize = {width = MAX_SCREEN_WIDTH, height = MAX_SCREEN_HEIGHT}
    self._winSize1 = self._winSize
    if ADOPT_IPHONEX then
        self._winSize1 = {width = 1136, height = self._winSize.height}
    end

    self._context = {
        _formationId = self._formationModel:formationTypeToId(self._formationType),
        _gridType = {},
        _position = {},
        _listOffset = {},
    }

    local allFormationType = self._formationModel:getAllFormationType()
    for _, formationType in ipairs(allFormationType) do
        self._context._gridType[formationType] = NewFormationView.kGridTypeTeam
        self._context._position[formationType] = {}
        self._context._position[formationType]._gridType = 0
        self._context._position[formationType]._id = 0
        self._context._listOffset[formationType] = {}
        self._context._listOffset[formationType][NewFormationView.kGridTypeTeam] = cc.p(0, 0)
        self._context._listOffset[formationType][NewFormationView.kGridTypeHero] = cc.p(0, 0)
        self._context._listOffset[formationType][NewFormationView.kGridTypeHireTeam] = cc.p(0, 0)
        self._context._listOffset[formationType][NewFormationView.kGridTypeIns] = cc.p(0, 0)
    end

    self._formationLocked = false
    self:getUI("bg.layer_information_beifen"):setVisible(false)
    self._layer_information = self:getUI("bg.layer_information")

    self._layer_information:setVisible(true)
    --self._layerDescription = self:getUI("bg.layer_description")
    self._btnBattle = self._layer_information:getChildByFullName("btn_battle")
    self._imageBattle = self._layer_information:getChildByFullName("btn_battle.image_battle")
    self._imageReady = self._layer_information:getChildByFullName("btn_battle.image_ready")
    self._imageAlready = self._layer_information:getChildByFullName("btn_battle.image_already")
    self._backupBG = self._layer_information:getChildByFullName("backup_bg")

    self._btnNextFight = self._layer_information:getChildByFullName("btn_next_fight")
    self._btnUnloadAll = self._layer_information:getChildByFullName("btn_unload_all")
    if self._formationType == self._formationModel.kFormationTypeStakeAtk2 or self._formationType == self._formationModel.kFormationTypeStakeDef2 then
        self._btnNextFight:loadTextures("stake_img1.png", "stake_img1.png", "stake_img1.png", 1)
    end

    self._extendBG = self._layer_information:getChildByFullName("extend_bg")
    self:updateExtendBtn()

    self._btnTraining = self._layer_information:getChildByFullName("btn_training")
    self._btnTraining:setVisible(self:isShowBullet())

    self._btnBullet = self._layer_information:getChildByFullName("btn_bullet")
    self._labelBullet = self._layer_information:getChildByFullName("label_bullet")
    self._labelBullet:enable2Color(1, cc.c4b(255, 195, 17, 255))
    self._labelBullet:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._btnBullet:setVisible(false)
    self._labelBullet:setVisible(false)
    if self:isShowBullet() then
        -- 训练所布阵弹幕
        self._btnBullet:setVisible(true)
        self._labelBullet:setVisible(true)
        self._bulletD = tab:Bullet("training"..self._extend.trainigData.id)
        local open = BulletScreensUtils.getBulletChannelEnabled(self._bulletD)
        local fileName = open and "bullet_open_btn.png" or "bullet_close_btn.png"
        self._btnBullet:loadTextures(fileName, fileName, fileName, 1)    
        if open then
            BulletScreensUtils.initBullet(self._bulletD)
        end
    end

    -- local amin = mcMgr:createViewMC("saoguang_battlebtn", true)  --扫光
    -- amin:setPosition(self._btnBattle:getContentSize().width/2, self._btnBattle:getContentSize().height/2)
    -- local clipNode = cc.ClippingNode:create()   
    -- clipNode:setInverted(false) 
    -- local mask = cc.Sprite:createWithSpriteFrameName("battleBtn_clipNode1.png")  --遮罩
    -- mask:setPosition(cc.p(self._btnBattle:getContentSize().width/2, self._btnBattle:getContentSize().height/2))
    -- clipNode:setStencil(mask)  
    -- clipNode:setAlphaThreshold(0.01)
    -- clipNode:addChild(amin)  
    -- clipNode:setAnchorPoint(cc.p(0, 0))
    -- clipNode:setPosition(0, 0)
    -- self._btnBattle:addChild(clipNode)
    -- clipNode:setCascadeOpacityEnabled(true, true)
    -- clipNode:setOpacity(0)
    -- clipNode:runAction(cc.FadeIn:create(0.5))

    local mc = mcMgr:createViewMC("zhandouguangxiao_battlebtn", true)
    mc:setVisible(self:isShowReadyBattle())
    mc:setTag(NewFormationView.kBattleLightTag)
    mc:setPosition(self._btnBattle:getContentSize().width/2, self._btnBattle:getContentSize().height/2)
    self._btnBattle:addChild(mc)

    local amin2 = mcMgr:createViewMC("zhandousaoguang_battlebtn", true)
    amin2:setPosition(self._imageBattle:getContentSize().width/2, self._imageBattle:getContentSize().height/2)
    self._imageBattle:addChild(amin2)

    -- formation relation config
    self._config = {}
    self._config._isShowBuildEffect = false
    self._config._formationBuild = tab.formation_build
    self._config._formationTeam = tab.formation_team
    self._config._formationHero = tab.formation_hero
    self._config._relationBuilds = {
        _cached = false,
        _builds = {
            _teams = {},
            _heroes = {}
        },
    }

    if self._formationType == self._formationModel.kFormationTypeCommon then
        if self._extend and self._extend.heroes then
            self._scenarioHero = self._extend.heroes[1]
        end
    end

    -- left
    self._layerLeft = {}

    self._layerLeft._layerTouch = self:getUI("bg.layer_left_touch")
    self._layerLeft._layerTouch:setContentSize(self._winSize)
    self._layerLeft._layerTouch.noSound = true
    self._layerLeft._sPosition = cc.p(0, 0)
    self._layerLeft._mPosition = cc.p(0, 0)
    self._layerLeft._ePosition = cc.p(0, 0)
    self._layerLeft._isIconHitted = false
    self._layerLeft._isIconMoved = false
    self._layerLeft._isHittedIconSwitched = false
    self._layerLeft._hittedIcon = nil
    self._layerLeft._hittedIconGrid = nil
    self._layerLeft._cloneHittedIcon = nil
    self._layerLeft._isBeganFromTeamIconGrid = false
    self._layerLeft._isBeganFromHeroIconGrid = false
    self._layerLeft._isBeganFromInsIconGrid = false
    self._layerLeft._isHeroFormationLayerHitted = false
    self._layerLeft._isteamFormationLayerHitted = false
    self._layerLeft._isinsFormationLayerHitted = false
    self._layerLeft._isItemsLayerHitted = false
    self:enableLayerLeftTouch(true)

    self._layerLeft._unloadMC = mcMgr:createViewMC("xiaoshi_selectedmissanim", true)
    self._layerLeft._unloadMC:setVisible(false)
    self._layerLeft._unloadMC:stop()
    self._layerLeft._unloadMC:addEndCallback(function()
        self._layerLeft._unloadMC:stop()
        self._layerLeft._unloadMC:setVisible(false)
    end)
    self._layerLeft._layerTouch:addChild(self._layerLeft._unloadMC, NewFormationView.kHighestZOrder)

    self._layerLeft._layer = self:getUI("bg.layer_left")
    self._layerLeft._layer:setContentSize(self._winSize1)
    --self._layerLeft._layer:setBackGroundImage("asset/bg/bg_formation.jpg")
    --self._layerLeft._imageMap = ccui.ImageView:create("bg_formation.jpg")
    self._layerLeft._imageMap = ccui.ImageView:create("bg_formation.jpg", 1)
    -- self._layerLeft._imageMap:setContentSize(self._winSize)
    self._layerSize = self._layerLeft._layer:getContentSize()
    self._mapSize = self._layerLeft._imageMap:getContentSize()
    self._layerLeft._layer:getLayoutParameter():setMargin({ left = 0, right = 0, top = 0, bottom = self._winSize.height / 2})
    self._layerLeft._imageMap:setPosition(cc.p(self._mapSize.width / 2, self._layerSize.height / 2))
    self._layerLeft._layer:addChild(self._layerLeft._imageMap)
    self._layerLeft._layerArrow = self:getUI("bg.layer_left.layer_arrow")
    self._layerLeft._layerArrow:setVisible(self:isShowEnemyFormationCheckArrow() and not self:isShowCountDownInfo())
    local arrowMC = mcMgr:createViewMC("kanchadiqing_selectedanim", true)
    arrowMC:setPosition(self._layerLeft._layerArrow:getContentSize().width / 2, self._layerLeft._layerArrow:getContentSize().height / 2)
    self._layerLeft._layerArrow:addChild(arrowMC)
    self._layerLeft._layerCountDown = self._layer_information:getChildByFullName("layer_count_down")
    self._layerLeft._layerCountDown:setVisible(self:isShowCountDownInfo())
    self._layerLeft._layerTips = self:getUI("bg.layer_left.layer_tips")
    self._layerLeft._layerTips:setVisible(false)
    self._layerLeft._labelTips = self:getUI("bg.layer_left.layer_tips.label_tips")
    self._layerLeft._labelTips:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._layerLeft._layerInformation = self._layer_information:getChildByFullName("info_left")
    self._layerLeft._layerInformation:getParent():reorderChild(self._layerLeft._layerInformation, 10)
    self._layerLeft._imageInfoBg1 = self._layer_information:getChildByFullName("info_left.image_info_bg")
    self._layerLeft._labelCurrentFightScore = self._layer_information:getChildByFullName("info_left.image_info_bg.label_current_fight_score")
    self._layerLeft._labelCurrentFightScore:setScale(0.58)
    self._layerLeft._labelCurrentFightScore:setFntFile(UIUtils.bmfName_zhandouli_little)
    self._layerLeft._labelCurrentFightScore:getVirtualRenderer():setAdditionalKerning(-3)
    self._layerLeft._layerRightFormation = {}

    self._layerLeft._layerRightFormationTitle = self._layer_information:getChildByFullName("info_left.layer_right_formation.label_title")
    self._layerLeft._layerRightFormationTitle:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    local layerRightFormationScore = self._layer_information:getChildByFullName("info_left.layer_right_formation.label_score")
    layerRightFormationScore:setVisible(false)
    self._layerLeft._layerRightFormationScore = ccui.TextBMFont:create("0", UIUtils.bmfName_zhandouli_little) 
    self._layerLeft._layerRightFormationScore:setScale(0.5)
    self._layerLeft._layerRightFormationScore:setAnchorPoint(cc.p(0.5,0.5))
    self._layerLeft._layerRightFormationScore:setPosition(layerRightFormationScore:getPosition())
    layerRightFormationScore:getParent():addChild(self._layerLeft._layerRightFormationScore)
    if self:isShowEnemyFormation() then
        self._layerLeft._layerRightFormationScore:setString("a"..self._enemyFormationData[self._context._formationId].score)
    end

    self._layerLeft._layerRightFormation._layer = self._layer_information:getChildByFullName("info_left.layer_right_formation") 
    self._layerLeft._layerRightFormation._layer:setVisible((self:isShowEnemyFormation() and not self:isShowCountDownInfo()) or self:isShowStakeAtkDef2())

    self._layerLeft._layerRightFormation._icon = {}
    for i = 1, NewFormationView.kTeamGridCount do
        self._layerLeft._layerRightFormation._icon[i] = self._layer_information:getChildByFullName("info_left.layer_right_formation.formation_icon_" .. i)
    end

    self._layerLeft._labelFormationName = self._layer_information:getChildByFullName("info_left.image_info_bg.label_formation_name")
    self._layerLeft._labelFormationName:setSkewX(15)
    self._layerLeft._labelFormationName:setFontName(UIUtils.ttfName)
    --self._layerLeft._labelFormationName:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self._layerLeft._btnFormationSelect = self._layer_information:getChildByFullName("info_left.image_info_bg.btn_select")
    --self._layerLeft._btnFormationSelect:setVisible(self:isShowButtonSelect())
    self._layerLeft._btnFormationSelect:setVisible(false)  -- temp code fixed me, 2016.6.20
    -- temp code
    --self._layerLeft._labelFormationName:setPositionX(122)
    --self._layerLeft._btnFormationSelect:setPositionX(230)

    --self._layerLeft._imageInfoBg2 = self:getUI("bg.layer_left.image_info_bg")
    self._layerLeft._labelCurrentLoad = self._layer_information:getChildByFullName("info_left.image_info_bg.label_current_load")
    self._layerLeft._labelCurrentLoad:setFontName(UIUtils.ttfName)
    self._layerLeft._labelCurrentLoad:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._layerLeft._labelCurrentLoadMC = mcMgr:createViewMC("renshutishi_selectedanim", true)
    self._layerLeft._labelCurrentLoadMC:setPlaySpeed(1, true)
    self._layerLeft._labelCurrentLoadMC:setScale(0.65)
    self._layerLeft._labelCurrentLoadMC:setVisible(false)
    self._layerLeft._labelCurrentLoadMC:setPosition(self._layerLeft._labelCurrentLoad:getContentSize().width / 1.5 + 17, self._layerLeft._labelCurrentLoad:getContentSize().height / 2 + 3)
    self._layerLeft._labelCurrentLoad:addChild(self._layerLeft._labelCurrentLoadMC, 10)
    self._layerLeft._labelNextUnlockLoad = self._layer_information:getChildByFullName("info_left.image_info_bg.label_next_unlock_load")
    self._layerLeft._labelNextUnlockLoad:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    --self._labelTeamCount = self:getUI("bg.layer_left.label_team_count")
    self._layerLeft._labelTeamValue1 = self._layer_information:getChildByFullName("info_left.image_info_bg.label_team_value_1")
    self._layerLeft._labelTeamValue1:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._layerLeft._labelTeamValue2 = self._layer_information:getChildByFullName("info_left.image_info_bg.label_team_value_2")
    self._layerLeft._labelTeamValue2:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    -- cloud info
    self._layerLeft._cloudInfo = {}

    self._layerLeft._cloudInfo._info = self._layer_information:getChildByFullName("info_left.cloud_info")
    self._layerLeft._cloudInfo._info:setVisible(self:isShowCloudInfo() or self:isShowPveInfo() or self:isShowWeaponInfo() or self:isShowCrossPKLimitInfo() or self:isShowStakeAtkDef2())
    self._layerLeft._cloudInfo._info:getChildByFullName("image_env_bg"):setVisible(not self:isShowStakeAtkDef2())
    self._layerLeft._cloudInfo._labelEvnDes = self._layer_information:getChildByFullName("info_left.cloud_info.image_env_bg.label_evn_des")
    self._layerLeft._cloudInfo._btnQuestion = self._layer_information:getChildByFullName("info_left.cloud_info.image_env_bg.btn_question")

    self._layerLeft._cloudInfo._btnQuestion:setVisible(false)
    self._layerLeft._cloudInfo._imageSwitchBg = self._layer_information:getChildByFullName("info_left.cloud_info.image_switch_bg")
    self._layerLeft._cloudInfo._imageSwitchBg:setPositionX(self._winSize.width / 2)

    self._layerLeft._cloudInfo._imageSwitchBg:setVisible(self:isShowCloudInfo() or self:isShowStakeAtkDef2())
    self._layerLeft._cloudInfo._btnLeft = self._layer_information:getChildByFullName("info_left.cloud_info.image_switch_bg.btn_left")
    self._layerLeft._cloudInfo._btnRight = self._layer_information:getChildByFullName("info_left.cloud_info.image_switch_bg.btn_right")
    self._layerLeft._cloudInfo._title1 = self._layer_information:getChildByFullName("info_left.cloud_info.image_switch_bg.cloud_title_1")
    self._layerLeft._cloudInfo._title2 = self._layer_information:getChildByFullName("info_left.cloud_info.image_switch_bg.cloud_title_2")
    self._layerLeft._cloudInfo._btnCloudCityGuide = self._layer_information:getChildByFullName("btn_cloud_city")

    self._layerLeft._cloudInfo._btnCloudCityGuide:setVisible(self:isShowCloudInfo())
    if self:isShowStakeAtkDef2() then
        self._layerLeft._cloudInfo._title1:loadTexture("stake_title_1_forma.png", 1)
        self._layerLeft._cloudInfo._title2:loadTexture("stake_title_2_forma.png", 1)
    end

    if self:isShowAwakingTaskInfo() then
        local screenSize = {width = MAX_SCREEN_WIDTH, height = MAX_SCREEN_HEIGHT}
        local isPad = (screenSize.width / screenSize.height) <= (3.0 / 2.0)
        self._layerLeft._awakingTaskInfo = {}
        self._layerLeft._awakingTaskInfo._info = self._layer_information:getChildByFullName("info_left.awaking_task_info")
        if isPad then
            self._layerLeft._awakingTaskInfo._info:getLayoutParameter():setMargin({ left = screenSize.width / 2, right = 0, top = 0, bottom = 0})
        end
        self._layerLeft._awakingTaskInfo._info:setVisible(self:isShowAwakingTaskInfo())
        self._layerLeft._awakingTaskInfo._labelTask = self._layer_information:getChildByFullName("info_left.awaking_task_info.label_task")
        self._layerLeft._awakingTaskInfo._labelTask:enable2Color(1, cc.c4b(253, 204, 87, 255))
        self._layerLeft._awakingTaskInfo._taskInfo = {}
        self._layerLeft._awakingTaskInfo._taskInfo._labelDes = {}
        self._layerLeft._awakingTaskInfo._taskInfo._labelLoad = {}
        self._layerLeft._awakingTaskInfo._taskInfo._labelValue = {}
        for i=1, 2 do
            self._layerLeft._awakingTaskInfo._taskInfo._labelDes[i] = self._layer_information:getChildByFullName("info_left.awaking_task_info.label_des_" .. i)
            self._layerLeft._awakingTaskInfo._taskInfo._labelLoad[i] = self._layer_information:getChildByFullName("info_left.awaking_task_info.label_current_load_" .. i)
            self._layerLeft._awakingTaskInfo._taskInfo._labelValue[i] = self._layer_information:getChildByFullName("info_left.awaking_task_info.label_team_value_" .. i)
            self._layerLeft._awakingTaskInfo._taskInfo._labelValue[i]:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        end
    end
    
    -- icon info
    self._layerLeft._iconInfo = {}
    self._layerLeft._iconInfo._info = self._layer_information:getChildByFullName("info_left.icon_info")
    self._layerLeft._iconInfo._info:setVisible(true)

    self._layerLeft._editInfo = {}
    self._layerLeft._editInfo._info = self._layerLeft._iconInfo._info:getChildByFullName("info_edit")
    self._layerLeft._editInfo._info:setVisible(true)
    self._layerLeft._editInfo._name = self._layerLeft._editInfo._info:getChildByFullName("label_name")
    self._layerLeft._editInfo._name:setFontName(UIUtils.ttfName)

    self:registerClickEvent(self._layerLeft._editInfo._info, function ()
        self:onButtonEditInfoClicked()
    end)

    self._layerLeft._heroFormation = {}
    self._layerLeft._heroFormation._layer = self:getUI("bg.layer_left.layer_hero_formation")
    self._layerLeft._heroFormation._layer:setRotation3D(cc.Vertex3F(-NewFormationView.kIconRotateDegree, 0, 0))
    self._layerLeft._heroFormation._layer:setPosition(70, self._layerSize.height / 2 - 40)
    if self:isHaveScenarioHero() then
        self._layerLeft._fixedHeroMC1 = mcMgr:createViewMC("juqingyingxiong_selectedmissanim", false, true)
        self._layerLeft._fixedHeroMC1:setRotation3D(cc.Vertex3F(NewFormationView.kIconRotateDegree, 0, 0))
        self._layerLeft._fixedHeroMC1:stop()
        self._layerLeft._fixedHeroMC1:setVisible(false)
        self._layerLeft._fixedHeroMC1:setPosition(self._layerLeft._heroFormation._layer:getContentSize().width / 2, self._layerLeft._heroFormation._layer:getContentSize().height / 2)
        self._layerLeft._heroFormation._layer:addChild(self._layerLeft._fixedHeroMC1)

        self._layerLeft._fixedHeroMC2 = mcMgr:createViewMC("juqingyingxiong1_selectedmissanim", false, true)
        self._layerLeft._fixedHeroMC2:stop()
        self._layerLeft._fixedHeroMC2:setRotation3D(cc.Vertex3F(NewFormationView.kIconRotateDegree, 0, 0))
        self._layerLeft._fixedHeroMC2:setVisible(false)
        self._layerLeft._fixedHeroMC2:setPosition(self._layerLeft._heroFormation._layer:getContentSize().width / 2, self._layerLeft._heroFormation._layer:getContentSize().height / 2)
        self._layerLeft._heroFormation._layer:addChild(self._layerLeft._fixedHeroMC2, 1000)

        self._layerLeft._fixedHeroMC3 = mcMgr:createViewMC("juqingyingxiongtanban_selectedmissanim", true, false)
        self._layerLeft._fixedHeroMC3:stop()
        self._layerLeft._fixedHeroMC3:setVisible(false)
        self._layerLeft._fixedHeroMC3:setPosition(self._layerSize.width / 2, self._layerSize.height / 1.5)
        self._layerLeft._layer:addChild(self._layerLeft._fixedHeroMC3, 1000)
    end
    self._layerLeft._heroFormation._grid = FormationGrid.new(self, NewFormationView.kGridTypeHero)

    self._layerLeft._insFormation = {}
    self._layerLeft._insFormation._layer = self:getUI("bg.layer_left.layer_ins_formation")
    self._layerLeft._insFormation._layer:setVisible(self:isShowInsFormation() or self:isHaveFixedWeapon())
    self._layerLeft._insFormation._layer:setRotation3D(cc.Vertex3F(-NewFormationView.kIconRotateDegree, 0, 0))
    self._layerLeft._insFormation._layer:setPosition(self._layerLeft._heroFormation._layer:getPositionX() + 110, self._layerLeft._heroFormation._layer:getPositionY() - 90)
    self._layerLeft._insFormation._grid = {}
    for i=1, NewFormationView.kInsMaxCount do
        self._layerLeft._insFormation._grid[i] = FormationGrid.new(self, NewFormationView.kGridTypeIns, i)
    end

    self._layerLeft._teamFormation = {}
    self._layerLeft._teamFormation._allowLoadCount = {}--self:getCurrentAllowLoadCount()
    self._layerLeft._teamFormation._layer = self:getUI("bg.layer_left.layer_team_formation")
    self._layerLeft._teamFormation._layer:setRotation3D(cc.Vertex3F(-NewFormationView.kIconRotateDegree, 0, 0))
    self._layerLeft._teamFormation._layer:setPosition(self._layerLeft._heroFormation._layer:getPositionX() + 200, self._layerLeft._heroFormation._layer:getPositionY() - 170)
    self._layerLeft._teamFormation._grid = {}
    for i = 1, NewFormationView.kTeamGridCount do
        self._layerLeft._teamFormation._grid[i] = FormationGrid.new(self, NewFormationView.kGridTypeTeam, i)
    end

    self._layerLeft._layerList = {}
    self._layerLeft._layerList._layer = self:getUI("bg.layer_left.layer_list")
    self._layerLeft._layerList._btnLeft = self:getUI("bg.layer_left.layer_list.btn_left")
    self._layerLeft._layerList._btnRight = self:getUI("bg.layer_left.layer_list.btn_right")
    self._layerLeft._layerList._layerLeftArrow = self:getUI("bg.layer_left.layer_list.layer_left_arrow")
    self._layerLeft._layerList._layerLeftArrow:setVisible(false)
    local mc = mcMgr:createViewMC("zuojiantou_teamnatureanim", true, false)
    mc:setPosition(self._layerLeft._layerList._layerLeftArrow:getContentSize().width / 2, self._layerLeft._layerList._layerLeftArrow:getContentSize().height / 2)
    self._layerLeft._layerList._layerLeftArrow:addChild(mc)
    self._layerLeft._layerList._layerRightArrow = self:getUI("bg.layer_left.layer_list.layer_right_arrow")
    self._layerLeft._layerList._layerRightArrow:setVisible(false)
    local mc = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    mc:setPosition(self._layerLeft._layerList._layerRightArrow:getContentSize().width / 2, self._layerLeft._layerList._layerRightArrow:getContentSize().height / 2)
    self._layerLeft._layerList._layerRightArrow:addChild(mc)
    self._layerLeft._layerList._btnTabTeam = self:getUI("bg.layer_left.layer_list.btn_tab_team")
    self._layerLeft._layerList._btnTabTeam:getTitleRenderer():disableEffect()
    self._layerLeft._layerList._btnTabTeam:getTitleRenderer():enableOutline(cc.c4b(60, 30, 10, 255), 1)
    --self._layerLeft._layerList._btnTabTeam:setColor(cc.c4b(147, 107, 81, 255))
    self._layerLeft._layerList._btnTabTeam:setScaleAnim(false)
    self._layerLeft._layerList._btnTabHero = self:getUI("bg.layer_left.layer_list.btn_tab_hero")
    --self._layerLeft._layerList._btnTabHero:setVisible(self._heroModel:getHeroCount() >= 2 or self:isShowCloudInfo() or self:isHaveExtendHeroes())
    --self._layerLeft._layerList._btnTabHero:setVisible(not (self._heroModel:getHeroCount() < 2 and self._formationType == self._formationModel.kFormationTypeCommon))
    self._layerLeft._layerList._btnTabHero:setSaturation(self:isHaveFixedHero() and -100 or 0)
    self._layerLeft._layerList._btnTabHero:getTitleRenderer():disableEffect()
    self._layerLeft._layerList._btnTabHero:getTitleRenderer():enableOutline(cc.c4b(60, 30, 10, 255), 1)
    --self._layerLeft._layerList._btnTabHero:setColor(cc.c4b(147, 107, 81, 255))
    self._layerLeft._layerList._btnTabHero:setScaleAnim(false)
    self._layerLeft._layerList._loadedHireTeam = {}
    self._layerLeft._layerList._hireTeamLimitLevel = tab:Setting("G_LANSQUENET_LEVEL_LIMIT").value
    self._layerLeft._layerList._btnTabHireTeam = self:getUI("bg.layer_left.layer_list.btn_tab_hire_team")
    self._layerLeft._layerList._btnTabHireTeam:setVisible(self:isShowHireTeam())
    self._layerLeft._layerList._btnTabHireTeam:getTitleRenderer():disableEffect()
    self._layerLeft._layerList._btnTabHireTeam:getTitleRenderer():enableOutline(cc.c4b(60, 30, 10, 255), 1)
    --self._layerLeft._layerList._btnTabHireTeam:setColor(cc.c4b(147, 107, 81, 255))
    self._layerLeft._layerList._btnTabHireTeam:setSaturation(0 == self:isCheckHireTeam() and 0 or -100)
    self._layerLeft._layerList._btnTabIns = self:getUI("bg.layer_left.layer_list.btn_tab_ins")
    self._layerLeft._layerList._btnTabIns:setVisible(self:isShowInsFormation() and not self:isHaveFixedWeapon())
    self._layerLeft._layerList._btnTabIns:getTitleRenderer():disableEffect()
    self._layerLeft._layerList._btnTabIns:getTitleRenderer():enableOutline(cc.c4b(60, 30, 10, 255), 1)
    if self:isShowInsFormation() then
        self._layerLeft._layerList._btnTabHireTeam:getLayoutParameter():setMargin({ left = 390, right = 0, top = 0, bottom = 112})
    end

    self._layerLeft._layerList._imageInsBubble = self:getUI("bg.layer_left.layer_list.btn_tab_ins.image_bubble")
    self._layerLeft._layerList._imageInsBubble:setVisible(self:isInsBubbleShow())
    if self:isInsBubbleShow() then
        self._layerLeft._layerList._imageInsBubble:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(10, 0)), cc.MoveBy:create(0.5, cc.p(-10, 0)))))
    end

    self._btnCitySelect = self._layer_information:getChildByFullName("btn_city_select")
    self._btnCitySelect:setVisible(self:isShowCitySelectInfo())

    if self:isShowCitySelectInfo() then
        self:registerClickEvent(self._btnCitySelect , function ()
            self:showCitySelectInfo()
        end)
    end

    self._layerLeft._layerList._imageBubbleRecom = self:getUI("bg.layer_left.layer_list.image_bubble_recom")
    self._layerLeft._layerList._imageBubbleRecom:setVisible(false)
    self._layerLeft._layerList._labelBubbleRecom = self:getUI("bg.layer_left.layer_list.image_bubble_recom.label_recom")
    self._layerLeft._layerList._labelBubbleRecom:setColor(cc.c3b(255,248,192))
    self._layerLeft._layerList._labelBubbleRecom:enable2Color(1, cc.c4b(255, 197, 20, 255))
    self._layerLeft._layerList._labelBubbleRecom:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._layerLeft._layerList._layerItems = self:getUI("bg.layer_left.layer_list.layer_items")
    self._layerLeft._layerList._layerItemsBlank = self:getUI("bg.layer_left.layer_list.layer_items_blank")
    self._layerLeft._layerList._itemsTableView = nil
    self._layerLeft._layerList._isIconMoved = false

    --[[
    -- version 6.0
    self._layerLeft._heroFormationMaskLayer = cc.RenderTexture:create(self._layerSize.width, self._layerSize.height, RGBART)
    self._layerLeft._heroFormationMaskLayer:setPosition(self._layerSize.width / 2, self._layerSize.height / 2)
    self._layerLeft._heroFormationMaskLayer:setVisible(false)
    self._layerLeft._heroFormationMaskLayer:getSprite():getTexture():setAntiAliasTexParameters()
    self._layerLeft._layer:addChild(self._layerLeft._heroFormationMaskLayer, 19)
    ]]

    self._layerLeft._layerList._teamData = nil
    self._layerLeft._layerList._heroData = nil
    self._layerLeft._layerList._hireTeamData = nil
    self._layerLeft._layerList._insData = nil

    -- filter
    self._layerLeft._layerList._allTeamsData = {}
    self._layerLeft._layerList._allTeamsInit = false
    self._layerLeft._layerList._allHeroInit = false
    self._layerLeft._layerList._allHerosData = {}
    self._teamRaceTypeList = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 12}
    self._heroRaceTypeList = {0, 1, 2, 4, 3, 5, 6, 7, 8, 9, 10}
    self._layerLeft._layerList._filterType = 100
    self._layerLeft._layerList._filterHeroType = 0
    self._layerLeft._layerList._btnFilter = self._layer_information:getChildByFullName("info_left.btn_filter")
    self._layerLeft._layerList._btnFilter:setScaleAnim(true)
    self:registerClickEvent(self._layerLeft._layerList._btnFilter, function ()
        self:onFilterButtonClicked()
    end)
    self._layerLeft._layerList._layerFilter = self._layer_information:getChildByFullName("info_left.layer_filter_bg")
    self._layerLeft._layerList._layerFilter:setVisible(false)
    self._layerLeft._layerList._layerFilter:setAnchorPoint(0, 0)
    self._layerLeft._layerList._btnFilterType = {}
    for i = 1, 11 do
        self._layerLeft._layerList._btnFilterType[i] = self._layer_information:getChildByFullName("info_left.layer_filter_bg.raceBtn" .. i - 1)
        self._layerLeft._layerList._btnFilterType[i]:setSwallowTouches(true)
        self:registerClickEvent(self._layerLeft._layerList._btnFilterType[i], function ()
            self:onFilterTypeButtonClicked(i)
        end)
    end

    -- right
    self._layerRight = {}

    self._layerRight._layerTouch = self:getUI("bg.layer_right_touch")
    self._layerRight._layerTouch:setContentSize(self._winSize)
    self._layerRight._layerTouch.noSound = true
    self._layerRight._layerTouch:setVisible(false)
    self._layerRight._hittedIconGrid = nil
    self._layerRight._isHeroFormationLayerHitted = false
    self._layerRight._isteamFormationLayerHitted = false
    self:enableLayerRightTouch(true)

    self._layerRight._layer = self:getUI("bg.layer_right")
    self._layerRight._layer:setContentSize(self._winSize1)
    self._layerRight._layer:getLayoutParameter():setMargin({ left = self._mapSize.width + self._mapSize.width - self._layerSize.width - 2, right = 0, top = 0, bottom = self._winSize.height / 2})
    self._layerRight._layer:setVisible(self:isShowEnemyFormation())
    --self._layerRight._layer:setBackGroundImage("asset/bg/bg_formation.jpg")
    --self._layerRight._imageMap = ccui.ImageView:create("asset/bg/bg_formation.jpg", 1)
    self._layerRight._imageMap = ccui.ImageView:create("bg_formation.jpg", 1)
    self._layerRight._imageMap:setFlippedX(true)
    self._layerRight._imageMap:setPosition(cc.p(self._layerSize.width - self._mapSize.width / 2, self._layerSize.height / 2))
    self._layerRight._layer:addChild(self._layerRight._imageMap)
    self._layerRight._layerArrow = self:getUI("bg.layer_right.layer_arrow")
    local arrowMC = mcMgr:createViewMC("huidaobuzhen_selectedanim", true)
    arrowMC:setRotation(180)
    arrowMC:setPosition(self._layerRight._layerArrow:getContentSize().width / 2, self._layerRight._layerArrow:getContentSize().height / 2)
    self._layerRight._layerArrow:addChild(arrowMC)

    self._layerRight._layerInformation = self._layer_information:getChildByFullName("info_right")
    self._layerRight._layerInformation:setVisible(false)
    --[[
    self._layerRight._labelCurrentFightScore = self._layer_information:getChildByFullName("info_right.label_current_fight_score")
    self._layerRight._labelCurrentFightScore:setFntFile(UIUtils.bmfName_zhandouli_little)
    self._layerRight._labelCurrentFightScore:getVirtualRenderer():setAdditionalKerning(-4)
    ]]
    self._layerRight._layerLeftFormation = {}
    self._layerRight._layerLeftFormation._layer = self._layer_information:getChildByFullName("info_right.layer_left_formation")

    local label_title1 = self._layer_information:getChildByFullName("info_right.layer_left_formation.label_title")
    label_title1:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    local layerLeftFormationScore = self._layer_information:getChildByFullName("info_right.layer_left_formation.label_score")
    layerLeftFormationScore:setVisible(false)

    self._layerRight._layerLeftFormationScore = ccui.TextBMFont:create("a", UIUtils.bmfName_zhandouli_little) --self._layer_information:getChildByFullName("info_left.layer_right_formation.label_score")
    self._layerRight._layerLeftFormationScore:setScale(0.5)
    self._layerRight._layerLeftFormationScore:setAnchorPoint(cc.p(0.5,0.5))
    self._layerRight._layerLeftFormationScore:setPosition(layerRightFormationScore:getPosition())
    layerLeftFormationScore:getParent():addChild(self._layerRight._layerLeftFormationScore)

    for i = 1, NewFormationView.kTeamGridCount do
        self._layerRight._layerLeftFormation[i] = self._layer_information:getChildByFullName("info_right.layer_left_formation.formation_icon_" .. i)
    end

    self._layerRight._heroFormation = {}
    self._layerRight._heroFormation._layer = self:getUI("bg.layer_right.layer_hero_formation")
    self._layerRight._heroFormation._layer:setRotation3D(cc.Vertex3F(-NewFormationView.kIconRotateDegree, 0, 0))
    self._layerRight._heroFormation._layer:setPosition(cc.p(self._layerSize.width - 240, self._layerSize.height / 2 - 40))
    self._layerRight._heroFormation._grid = self:getUI("bg.layer_right.layer_hero_formation")
    self._layerRight._heroFormation._gridFull = ccui.ImageView:create("grid_hero_f_bg_forma.png", 1)
    self._layerRight._heroFormation._gridFull:setVisible(false)
    self._layerRight._heroFormation._gridFull:setPosition(self._layerRight._heroFormation._grid:getContentSize().width / 2, self._layerRight._heroFormation._grid:getContentSize().height / 2)
    self._layerRight._heroFormation._grid:addChild(self._layerRight._heroFormation._gridFull, 5)
    self._layerRight._heroFormation._gridSelected = mcMgr:createViewMC("xuanzhongyingxiong_selectedanim", true)
    self._layerRight._heroFormation._gridSelected:setVisible(false)
    self._layerRight._heroFormation._gridSelected:setPlaySpeed(1, true)
    self._layerRight._heroFormation._gridSelected:setPosition(self._layerRight._heroFormation._grid:getContentSize().width / 2, self._layerRight._heroFormation._grid:getContentSize().height / 2)
    self._layerRight._heroFormation._grid:addChild(self._layerRight._heroFormation._gridSelected, 6)
    self._layerRight._teamFormation = {}
    --self._layerRight._teamFormation._allowLoadCount = self:getCurrentAllowLoadCount()
    self._layerRight._teamFormation._layer = self:getUI("bg.layer_right.layer_team_formation")
    self._layerRight._teamFormation._layer:setRotation3D(cc.Vertex3F(-NewFormationView.kIconRotateDegree, 0, 0))
    self._layerRight._teamFormation._layer:setPosition(cc.p(self._layerRight._heroFormation._layer:getPositionX() - 715, self._layerRight._heroFormation._layer:getPositionY() - 170))
    self._layerRight._teamFormation._grid = {}
    self._layerRight._teamFormation._gridFull = {}
    self._layerRight._teamFormation._gridSelected = {}
    self._layerRight._teamFormation._gridHexin1 = {}
    self._layerRight._teamFormation._gridHexin2 = {}
    self._layerRight._teamFormation._gridWall = {}
    for i = 1, NewFormationView.kTeamGridCount do
        self._layerRight._teamFormation._grid[i] = self:getUI("bg.layer_right.layer_team_formation.formation_icon_" .. i)
        self._layerRight._teamFormation._gridFull[i] = ccui.ImageView:create("grid_team_f_bg_forma.png", 1)
        self._layerRight._teamFormation._gridFull[i]:setVisible(false)
        self._layerRight._teamFormation._gridFull[i]:setPosition(self._layerRight._teamFormation._grid[i]:getContentSize().width / 2, self._layerRight._teamFormation._grid[i]:getContentSize().height / 2)
        self._layerRight._teamFormation._grid[i]:addChild(self._layerRight._teamFormation._gridFull[i], 5)
        self._layerRight._teamFormation._gridSelected[i] = mcMgr:createViewMC("xuanzhongbingtuan_selectedanim", true)
        self._layerRight._teamFormation._gridSelected[i]:setVisible(false)
        self._layerRight._teamFormation._gridSelected[i]:setPlaySpeed(1, true)
        self._layerRight._teamFormation._gridSelected[i]:setPosition(self._layerRight._teamFormation._grid[i]:getContentSize().width / 2, self._layerRight._teamFormation._grid[i]:getContentSize().height / 2)
        self._layerRight._teamFormation._grid[i]:addChild(self._layerRight._teamFormation._gridSelected[i], 6)
        self._layerRight._teamFormation._gridHexin1[i] = mcMgr:createViewMC("bosstishi1_bosstishi", true)
        self._layerRight._teamFormation._gridHexin1[i]:setVisible(false)
        self._layerRight._teamFormation._gridHexin1[i]:setPlaySpeed(1, true)
        self._layerRight._teamFormation._gridHexin1[i]:setPosition(self._layerRight._teamFormation._grid[i]:getContentSize().width / 2, self._layerRight._teamFormation._grid[i]:getContentSize().height / 2)
        self._layerRight._teamFormation._grid[i]:addChild(self._layerRight._teamFormation._gridHexin1[i], 7)
        self._layerRight._teamFormation._gridHexin2[i] = mcMgr:createViewMC("bosstishi12_bosstishi", true)
        self._layerRight._teamFormation._gridHexin2[i]:setVisible(false)
        self._layerRight._teamFormation._gridHexin2[i]:setPlaySpeed(1, true)
        self._layerRight._teamFormation._gridHexin2[i]:setPosition(self._layerRight._teamFormation._grid[i]:getContentSize().width / 2, self._layerRight._teamFormation._grid[i]:getContentSize().height / 2)
        self._layerRight._teamFormation._grid[i]:addChild(self._layerRight._teamFormation._gridHexin2[i], NewFormationView.kHighestZOrder)
        self._layerRight._teamFormation._gridWall[i] = ccui.ImageView:create("grid_team_w_bg_forma.png", 1)
        self._layerRight._teamFormation._gridWall[i]:setVisible(false)
        self._layerRight._teamFormation._gridWall[i]:setPosition(self._layerRight._teamFormation._grid[i]:getContentSize().width / 2, self._layerRight._teamFormation._grid[i]:getContentSize().height / 2)
        self._layerRight._teamFormation._grid[i]:addChild(self._layerRight._teamFormation._gridWall[i], 5)
    end

    self._layerRight._insFormation = {}
    self._layerRight._insFormation._layer = self:getUI("bg.layer_right.layer_ins_formation")
    self._layerRight._insFormation._layer:setVisible(((self:isShowInsFormation() and self._formationType ~= self._formationModel.kFormationTypeCrusade) or self:isHaveFixedWeapon()) and self:isShowEnemyInsFormation())
    self._layerRight._insFormation._layer:setRotation3D(cc.Vertex3F(-NewFormationView.kIconRotateDegree, 0, 0))
    self._layerRight._insFormation._layer:setPosition(self._layerRight._heroFormation._layer:getPositionX() - 70, self._layerRight._heroFormation._layer:getPositionY() - 100)
    self._layerRight._insFormation._grid = {}
    for i=1, NewFormationView.kInsMaxCount do
        self._layerRight._insFormation._grid[i] = self:getUI("bg.layer_right.layer_ins_formation.ins_icon_" .. i)
    end

    if self:isNewFormationViewEx() then
        if self._rulesTable[self._formationType] then
            require("game.view.formation." .. self._rulesTable[self._formationType])
            self:onInitEx()
        end
    end

    self:onModelReflash()
    self:startClock()

    if self._teamModel:getTeamAndIndexById(104) then
        GuideUtils.checkTriggerByType("action", "3")
    end

    if self._heroModel:checkHero(60303) 
        and not self:isLoaded(NewFormationView.kGridTypeHero, 60303) 
        and self._formationType == self._formationModel.kFormationTypeCrusade then
        GuideUtils.checkTriggerByType("action", "4")
    end

    if self._extend.intanceId then
        local stage = self._intanceModel:getStageInfo(self._extend.intanceId)
        if stage and stage.star == 0 then 
            GuideUtils.checkTriggerByType("formation", tostring(self._extend.intanceId))
        end
    end

    if self:isShowCountDownInfo() then
        self:showCountDownInfo()
    end

    if self:isHaveFixedHero() then
        if self._extend and not self._extend.isSimpleFormation then
            self:showScenarioHeroEffect(true)
        end
    end

    self:registerScriptHandler(function(state)
        if state == "enter" then
            cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION3_D)
            if self:isNewFormationViewEx() then
                self:onEnterEx()
            end
        elseif state == "exit" then
            cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION2_D)
            if self:isNewFormationViewEx() then
                self:onExitEx()
            end
        end 
    end)

    self:registerClickEvent(self._layerLeft._layerList._btnTabTeam, function ()
        self:switchLayerList(NewFormationView.kGridTypeTeam)
    end)

    self:registerClickEvent(self._layerLeft._layerList._btnTabHero, function ()
        if self._extend and self._extend.isSimpleFormation then
            self._viewMgr:showTip("不允许更换英雄")
            return
        end
        self:switchLayerList(NewFormationView.kGridTypeHero)
    end)
    if self._extend and self._extend.isSimpleFormation then
        self._layerLeft._layerList._btnTabHero:setVisible(false)
        ScheduleMgr:delayCall(0, self, function()
           self._layerLeft._layerList._btnTabIns:setPosition(self._layerLeft._layerList._btnTabHero:getPosition())
        end)
    end

    

    if self:isShowHireTeam() then
        self:registerClickEvent(self._layerLeft._layerList._btnTabHireTeam, function ()
            local checkValue = self:isCheckHireTeam()
            if -1 == checkValue then return end
            if 0 ~= checkValue then
                self._viewMgr:showTip(lang("OPEN_LANSQUENET_TIP" .. checkValue))
                return
            end
            self:switchLayerList(NewFormationView.kGridTypeHireTeam)
        end)
    end

    if self:isShowInsFormation() then
        self:registerClickEvent(self._layerLeft._layerList._btnTabIns, function ()
            self:switchLayerList(NewFormationView.kGridTypeIns)
        end)
    end

    local btn_item_blank = self:getUI("bg.layer_left.layer_list.layer_items_blank.image_icon_blank")
    self:registerClickEvent(btn_item_blank, function ()
        btn_item_blank:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 0.85), cc.ScaleTo:create(0.1, 1.0), cc.CallFunc:create(function()
            self._viewMgr:showView("flashcard.FlashCardView")
        end)))
    end)

    self:registerClickEvent(self._layerLeft._btnFormationSelect, function ()
        self:onShowFormationSelectView({container = self, currentFormationId = self._context._formationId, data = clone(self._layerLeft._teamFormation._data)})
    end)

    if self:isShowEnemyFormation() then
        self:registerClickEvent(self._layerLeft._layerArrow, function ()
            self:showEnemayFormation(true)
        end)
        self:registerClickEvent(self._layerRight._layerArrow, function ()
            self:showEnemayFormation(false)
        end)

        self:registerClickEvent(self._layerLeft._layerRightFormation._layer, function ()
            if not self:isShowEnemyFormationCheckArrow() then
                self._viewMgr:showTip(lang("TIP_BUZHEN_ARENA"))
                return
            end
            self:showEnemayFormation(true)
        end)
        self:registerClickEvent(self._layerRight._layerLeftFormation._layer, function ()
            self:showEnemayFormation(false)
        end)
    end

    if self:isShowCloudInfo() then
        self:registerClickEvent(self._layerLeft._cloudInfo._btnQuestion, function ()
            self:showCloudRuleDialog()
        end)

        self:registerClickEvent(self._layerLeft._cloudInfo._btnLeft, function()
            self:switchCloudFormation()
        end)

        self:registerClickEvent(self._layerLeft._cloudInfo._btnRight, function()
            self:switchCloudFormation()
        end)

        self:registerClickEvent(self._btnNextFight, function ()
            self:onNextFightButtonClicked()
        end)

        self:registerClickEvent(self._btnUnloadAll, function ()
            self:onUnloadAllButtonClicked()
        end)

        self:registerClickEvent(self._layerLeft._cloudInfo._btnCloudCityGuide, function ()
            self:onButtonCloudCityGuideClicked()
        end)

        if self._extend and self._extend.isShowWallGuide then
            ScheduleMgr:delayCall(0, self, self.showWallGuideView)
        end
    end

    if self:isShowStakeAtkDef2() then
        self:registerClickEvent(self._layerLeft._cloudInfo._btnLeft, function()
            self:switchStakeFormation()
        end)

        self:registerClickEvent(self._layerLeft._cloudInfo._btnRight, function()
            self:switchStakeFormation()
        end)

        self:registerClickEvent(self._btnNextFight, function ()
            self:switchStakeFormation()
        end)
    end

    self:registerClickEvent(self._btnBattle, function ()
        self:onBattleButtonClicked()
    end)

    if USESRDATA then
        local btn = ccui.Button:create("123.png", "123.png", "123.png", 1)
        btn:setPosition(MAX_SCREEN_WIDTH - 160, 180)
        btn:setTitleText("极速战斗")
        self:addChild(btn)
        self:registerClickEvent(btn, function ()
            BattleUtils.onceFastBattle = true
            self:onBattleButtonClicked()
        end)
    end

    if self:isShowButtonTraining() then
        if self._extend and self._extend.isFirstTrain then
            ScheduleMgr:delayCall(0, self, self.showTrainingInfo)
        end
        self:registerClickEvent(self._btnTraining, function ()
            self:showTrainingInfo()
        end)
        if self:isShowBullet() then
            self:registerClickEvent(self._btnBullet, function ()
                self._viewMgr:showDialog("global.BulletSettingView", {bulletD = self._bulletD, 
                    callback = function (open) 
                        local fileName = open and "bullet_open_btn.png" or "bullet_close_btn.png"
                        self._btnBullet:loadTextures(fileName, fileName, fileName, 1)       
                    end})
            end)
        end
    end

    local btnReturn = self:getUI("bg.btn_return")
    btnReturn:setVisible(self:isShowButtonReturn())
    self:registerClickEvent(btnReturn, function ()
        self:onCloseButtonClicked()
    end)
    
    local saveBtn = self:getUI("bg.sureBtn")
    local cancelBtn = self:getUI("bg.cancleBtn")
    saveBtn:setVisible(self._extend and self._extend.isSimpleFormation)--not self:isShowButtonReturn())
    cancelBtn:setVisible(self._extend and self._extend.isSimpleFormation)--not self:isShowButtonReturn())
    self:registerClickEvent(saveBtn, function()
        self:doSimpleClose()
    end)
    self:registerClickEvent(cancelBtn, function()
        self:close()
    end)
    self:updateBackupInfo()
end

function NewFormationView:onInitEx()

end

function NewFormationView:onEnterEx()

end

function NewFormationView:onExitEx()
    
end

function NewFormationView:destroy()
    self:endClock()
    if self:isNewFormationViewEx() then
        self:endClockEx()
    end
    NewFormationView.super.destroy(self, true)
end

function NewFormationView:enableButtonArrow(enable)
    self._layerLeft._layerArrow:setEnabled(enable)
    self._layerRight._layerArrow:setEnabled(enable)
end

function NewFormationView:enableLayerLeftTouch(enable)
    if not enable then
        return self._layerLeft._layerTouch:setTouchEnabled(false)
    end
    self._layerLeft._layerTouch:setTouchEnabled(true)
    self._layerLeft._layerTouch:setSwallowTouches(false)
    self:registerTouchEvent(self._layerLeft._layerTouch, 
        handler(self, self.onLayerLeftTouchBegan), 
        handler(self, self.onLayerLeftTouchMoved), 
        handler(self, self.onLayerLeftTouchEnded), 
        handler(self, self.onLayerLeftTouchCancelled))
end

function NewFormationView:enableLayerRightTouch(enable)
    if not enable then
        return self._layerRight._layerTouch:setTouchEnabled(false)
    end
    self._layerRight._layerTouch:setTouchEnabled(true)
    self._layerRight._layerTouch:setSwallowTouches(false)
    self:registerTouchEvent(self._layerRight._layerTouch, 
        handler(self, self.onLayerRightTouchBegan), 
        handler(self, self.onLayerRightTouchMoved), 
        handler(self, self.onLayerRightTouchEnded), 
        handler(self, self.onLayerRightTouchCancelled))
end

function NewFormationView:onTop()
    self._viewMgr:enableScreenWidthBar()
    cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION3_D)
    self:updateUI()
end

function NewFormationView:onHide()
    self._viewMgr:disableScreenWidthBar()
end

function NewFormationView:updateUI()
    self:switchLayerList(self._context._gridType[self._context._formationId], true)
    self:updateLeftTeamFormation()
    self:updateLeftTeamFormationAddition()
    self:updateLeftHeroFormation()
    self:updateBackupInfo()
    if self:isShowEnemyFormation() then
        self:updateLeftTeamFormationPreview()
        self:updateRightTeamFormationPreview()
        self:updateRightTeamFormation()
        self:updateRightHeroFormation()
    end
    --self:onShowDescriptionView()
    self:updateRelative()
    self:updateBattleInfo()
    if gridType == NewFormationView.kGridTypeTeam then
        self:updateFilterType()
    elseif gridType == NewFormationView.kGridTypeHero then
        self:updateHeroFilterType()
    end

    if self:isShowCloudInfo() then
        self:updateCloudInfo()
        if self._extend and self._extend.isShowBattleGuide and self._extend.isShowBattleGuide[self._context._formationId] then
            ScheduleMgr:delayCall(0, self, self.showBattleGuideView)
        end
    end

    if self:isShowStakeAtkDef2() then
        self:updateStakeInfo()
    end

    if self:isShowPveInfo() then
        self:updatePveInfo()
    end

    -- if self:isShowTreasureInfo() then
    --     self:updateTreasureInfo()
    -- end

    -- if self:isShowPokedexInfo() then
    --     self:updatePokedexInfo()
    -- end

    if self:isHaveFixedWeapon() then
        self:showFixedWeaponInfo()
    -- elseif self:isShowInsFormation() then
    --     self:showUnlockWeaponInfo()
    end

    if self:isShowInsEvn() then
        self:updateWeaponInfo()
    end

    if self:isShowCrossPKLimitInfo() then
        self:updateCrossPKLimitInfo()
    end

    if self:isNewFormationViewEx() then
        self:updateUIEx()
    end
end

function NewFormationView:updateUIEx()

end

function NewFormationView:showEnemayFormation(isShow)
    self._layerLeft._layerTouch:setVisible(not isShow)
    self._layerRight._layerTouch:setVisible(isShow)

    self._layerLeft._layerInformation:setVisible(false)
    self._layerRight._layerInformation:setVisible(false)

    self:enableButtonArrow(false)

    if isShow then
        self._extendBG:setVisible(false)
        self._btnBullet:setVisible(false)
        self._labelBullet:setVisible(false)
        self._backupBG:setVisible(false)
        self._layerLeft._teamFormation._layer:runAction(cc.Sequence:create(cc.FadeOut:create(0.01), cc.CallFunc:create(function()
            self:updateLeftTeamFormationAddition(true)
        end)))

        self._layerLeft._layer:runAction(cc.Sequence:create(cc.MoveTo:create(NewFormationView.kActionDeltaTime, cc.p(-(self._mapSize.width + self._mapSize.width - self._layerSize.width - 2), 0)), cc.CallFunc:create(function ()
            self._layerLeft._layerInformation:setVisible(false)
            self._layerLeft._teamFormation._layer:runAction(cc.Sequence:create(cc.FadeIn:create(0.01), cc.CallFunc:create(function()
                self:updateLeftTeamFormationAddition()
            end)))
        end)))

        self._layerRight._layer:setVisible(true)
        self._layerRight._layer:runAction(cc.Sequence:create(cc.MoveTo:create(NewFormationView.kActionDeltaTime, cc.p(0, 0)), cc.CallFunc:create(function()
            self._layerRight._layerInformation:setVisible(true)
            self:enableButtonArrow(true)
        end)))
    else
        self._layerLeft._layer:setVisible(true)
        self._layerLeft._layer:runAction(cc.Sequence:create(cc.MoveTo:create(NewFormationView.kActionDeltaTime, cc.p(0, 0)), cc.CallFunc:create(function()
            self._layerLeft._layerInformation:setVisible(true)
        end)))

        self._layerRight._teamFormation._layer:runAction(cc.FadeOut:create(0.01))
        self._layerRight._layer:runAction(cc.Sequence:create(cc.MoveTo:create(NewFormationView.kActionDeltaTime, cc.p(self._mapSize.width + self._mapSize.width - self._layerSize.width - 2, 0)), cc.CallFunc:create(function()
            self._layerRight._layer:setVisible(false)
            self._layerRight._layerInformation:setVisible(false)
            self:enableButtonArrow(true)
            self._layerRight._teamFormation._layer:runAction(cc.FadeIn:create(0.01))
            self._btnBullet:setVisible(self:isShowBullet())
            self._labelBullet:setVisible(self:isShowBullet())
            self:updateExtendBtn()
            self:updateBackupInfo()
        end)))
    end

    self:updateLeftTeamFormationPreview()
end

function NewFormationView:showCountDownInfo()
    local node = ccui.Layout:create()
    node:setContentSize(cc.size(100,100))
    node:setPosition(0, 320)
    node:setScale(0.75)
    node:setName("leagueCountDownNode")
    self._layerLeft._layerCountDown:addChild(node)
    self._layerLeft._layerCountDown:getParent():reorderChild(self._layerLeft._layerCountDown, 5)

    local bg = ccui.ImageView:create()
    bg:loadTexture("countDown_league.png",1)
    bg:setPositionY(-15)
    node:addChild(bg)


    local countLab = ccui.Text:create()
    countLab:setName("countLab")
    countLab:setFontSize(50)
    countLab:setFontName(UIUtils.ttfName)
    countLab:setColor(cc.c3b(255, 255, 255))
    countLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    countLab:enable2Color(1,cc.c4b(226, 226, 226, 255))
    node:addChild(countLab)

    -- 增加敌方准备动画
    local enemyNode = ccui.Widget:create()
    enemyNode:setPosition(cc.p(400, 160))
    self._layerLeft._layerCountDown:addChild(enemyNode)
    local enemyBg = ccui.ImageView:create()
    enemyBg:loadTexture("enemybg_league.png",1)
    enemyBg:setScale9Enabled(true)
    enemyBg:setCapInsets(cc.rect(14,17,1,1))
    enemyBg:setContentSize(cc.size(134,162))
    enemyNode:addChild(enemyBg)
    local enemyTitle = ccui.Text:create()
    enemyTitle:setFontSize(24) 
    enemyTitle:setFontName(UIUtils.ttfName) 
    enemyTitle:setPosition(0,60)
    enemyTitle:setString("敌方情况")
    enemyTitle:setColor(cc.c3b(252, 229, 151))
    enemyNode:addChild(enemyTitle)

    local enemyReady = ccui.Text:create()
    enemyReady:setFontSize(24) 
    enemyReady:setFontName(UIUtils.ttfName) 
    enemyReady:setPosition(-44,-65)
    enemyReady:setAnchorPoint(cc.p(0,0.5))
    enemyReady:setString("准备中.")
    enemyReady:setColor(cc.c3b(255, 251, 235))
    enemyReady:enable2Color(2,cc.c4f(255, 229, 89, 255))
    enemyReady:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    enemyNode:addChild(enemyReady)

    local enemyAlReady = ccui.Text:create()
    enemyAlReady:setFontSize(24) 
    enemyAlReady:setFontName(UIUtils.ttfName) 
    enemyAlReady:setPosition(0,-65)
    enemyAlReady:setString("已准备")
    enemyAlReady:setColor(cc.c3b(0, 255, 30))
    enemyAlReady:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    enemyAlReady:setVisible(false)
    enemyNode:addChild(enemyAlReady)

    local clockT = math.floor(os.clock()*10)
    GRandomSeed(tostring(os.time()+clockT):reverse():sub(1, 6))
    local enemyReadyTime = GRandom(tab:Setting("G_LEAGUE_PREPARE").value[1],tab:Setting("G_LEAGUE_PREPARE").value[2])

    local enemyHeroId = self._enemyFormationData[self._context._formationId].heroId 
    local heroData = self._modelMgr:getModel("LeagueModel"):getEnemyHeroData() or {}
    local heroDataClone = clone(tab:Hero(tonumber(enemyHeroId) or 60102))
    heroDataClone.star = heroData.star or 1
    local heroIcon = IconUtils:createHeroIconById({sysHeroData = heroDataClone})
    heroIcon:setPosition(0,0)
    heroIcon:setScale(0.8)
    enemyNode:addChild(heroIcon,1)
 
    -- 检测锁屏 node 的action 比较安全
    heroIcon:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.DelayTime:create(0.02),
            cc.CallFunc:create(function( )
                if self._isBattleButtonClicked then
                    heroIcon:stopAllActions()
                    -- self:lock(-1)
                end
            end)
        )
    ))


    -- stageBgMc:setPosition(cc.p(stageBgW/2-215,stageBgH/2+260))
    -- self._stageImg:addChild(stageBgMc,-1)
    -- local node = xxx
    self._enemyAlReady = false
    local countNum = tab:Setting("G_LEAGUE_FORMATION").value
    countLab:setString(string.format("%02d",countNum))
    local animLab1
    local soundId 
    local function show3CountDow( callback )
        soundId = audioMgr:playSound("LeagueFormationCount")
        self:updateLeagueBattleInfo(true)
        node:setVisible(false)
        local countInNum = 3
        -- countNum = 3
        if not animLab1 then
            animLab1 = ccui.Text:create()
            animLab1:setFontSize(150)
            animLab1:setFontName(UIUtils.ttfName)
            animLab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
            animLab1:setPosition(0,100)
            animLab1:setString(" " or countInNum)
            self._layerLeft._layerCountDown:addChild(animLab1,99)
            local countMc = mcMgr:createViewMC("daojishi_leagueredian", false, true,function( _,sender )
                -- sender:gotoAndPlay(10)
                sender:stop()
            end,RGBA8888)
            -- countMc:setPlaySpeed(0.5)
            countMc:setPosition(50,100)
            -- countMc:stop()
            animLab1:addChild(countMc,2)
            local animLab2 = animLab1:clone()
            animLab2:setPosition(0,100)
            animLab2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
            animLab2:setString(" " or countInNum)
            self._layerLeft._layerCountDown:addChild(animLab2,99)
            animLab2:runAction(
                cc.RepeatForever:create(
                    cc.Sequence:create(
                        cc.Spawn:create(cc.ScaleTo:create(0.2,1.5),cc.FadeTo:create(0.2,180)),
                        cc.Spawn:create(cc.ScaleTo:create(0.3,2.5),cc.FadeOut:create(0.3)),
                        cc.DelayTime:create(0.5),
                        cc.CallFunc:create(function( )
                            -- animLab2:setScale(1)
                            -- animLab2:setOpacity(255)
                            countInNum = countInNum-1
                            if countInNum < 1 then
                                audioMgr:stopAll()
                                if callback then
                                    callback()
                                end
                                animLab2:stopAllActions()
                                return
                            end
                            animLab1:setString(" " or countInNum)
                            animLab2:setString(" " or countInNum)
                            -- countMc:gotoAndPlay(0)
                            -- countMc:addEndCallback(function (_, sender)
                            --     sender:stop()
                            -- end)
                        end)
                    )
                ))
        end
    end
    local function doPreParedBattle( )
        -- audioMgr:stopSound(soundId)
        -- node:stopAllActions()
        -- node:removeFromParent()
        -- self:unlock()
        if self:isSaveRequired() then
            self:doSave(function(success)
                if type(self._customCallBack) == "function" then
                    self._customCallBack()
                end
            end)
        else
            if type(self._customCallBack) == "function" then
                self._customCallBack()
            end
        end
        self._viewMgr:closeHintView()
    end
    local readyStrs = {"准备中.","准备中..","准备中..."}
    local readyIdx = 1
    node:runAction(cc.RepeatForever:create(
        cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function( )
            if countLab._forceNum then
                countNum = countLab._forceNum 
                countLab._forceNum = nil
            end
            countNum = countNum-1
            enemyReadyTime = enemyReadyTime - 1
            if enemyReadyTime <= 0 then
                self._enemyAlReady = true
                enemyAlReady:setVisible(true)
                enemyReady:setVisible(false)
                if self._isBattleButtonClicked then
                    show3CountDow( function( )
                        doPreParedBattle()
                    end)
                end
            else
                readyIdx = readyIdx + 1
                enemyReady:setString(readyStrs[readyIdx%3+1])
            end
            if countNum <= 0 then
                show3CountDow( function( )
                    doPreParedBattle()
                end)
            else
                if countLab then
                    countLab:setString(string.format("%02d",countNum))
                    -- 三秒时拍脸动画
                    -- if countNum < 4 then
                    -- end
                end
            end
        end)
        )))

    -- [[    
    local heroBody = self._layerLeft._heroFormation._grid:getIconView()
    local selfPos = {x=0,y=0}
    if heroBody then
        local heroBodyContentSize = heroBody:getBodyContentSize()
        selfPos = {x=heroBodyContentSize.width/2,y=heroBodyContentSize.height}
    end
    -- [[ 喊话功能
    local shoutBox = self._viewMgr:createLayer("global.ShoutBox",{selfNode=function( )
        return self._layerLeft._heroFormation._grid:getIconView()
    end,rivalNode=enemyNode,maxTime = countNum,selfPos = {x=80,y=80},rivalPos = {x=0,y=0}})
    if MAX_SCREEN_WIDTH >= 1136 then
        shoutBox:setPosition(-592,-100)
        enemyNode:setPositionX(400)
    else
        shoutBox:setPosition(-592,-100)
        enemyNode:setPositionX(300)
    end
    if MAX_SCREEN_HEIGHT > 640 then
        shoutBox:setPositionY(-200)
    else
        shoutBox:setPositionY(-100)
    end
    shoutBox:setSwallowTouches(false)
    self._layerLeft._layerCountDown:addChild(shoutBox,999)
    --]]
    --]]
end

function NewFormationView:showCloudRuleDialog()
    if not self:isShowCloudInfo() then return end
    if not (self._extend.cloudData1 and self._extend.cloudData2) then return end
    local cloudData = self._extend.cloudData1
    if self._context._formationId == self._formationModel.kFormationTypeCloud2 then
        cloudData = self._extend.cloudData2
    end
    -- cloudData.rule
    print("This is the cloud rule dialog.")
end

function NewFormationView:showWallGuideView()
    if not (self:isShowCloudInfo() and self._extend.isShowWallGuide) then return end
    self._viewMgr:showDialog("formation.NewFormationExplainView")
end

function NewFormationView:showBattleGuideView()
    if not (self:isShowCloudInfo() and self._extend.isShowBattleGuide[self._context._formationId]) then return end
    self._extend.isShowBattleGuide[self._context._formationId] = false
    if not (self._extend.cloudData1 and self._extend.cloudData2) then return end
    local cloudData = self._extend.cloudData1
    if self._context._formationId == self._formationModel.kFormationTypeCloud2 then
        cloudData = self._extend.cloudData2
    end
    self._viewMgr:showDialog("cloudcity.CloudCityExplainView", cloudData)
end

function NewFormationView:onButtonCloudCityGuideClicked()
    self._viewMgr:showDialog("cloudcity.CloudCityExplainView")
end

function NewFormationView:showTeamCareerInfo()
    self._viewMgr:showDialog("team.TeamGradeDialog", {classlabel = 101})
end

function NewFormationView:showTrainingInfo()
    if not (self._extend and self._extend.trainigData) then return end
    self._viewMgr:showDialog("training.TrainingTargetDialog", {trainingId = self._extend.trainigData.id, trainingData = self._extend.trainigData})--, forceShow, Async, callback, noPop)   
end

function NewFormationView:showCitySelectInfo()
    if not self:isShowCitySelectInfo() then return false end
    local cityData = self._weaponsModel:getWeaponsDataD()
    if #cityData <= 0 then 
        self._viewMgr:showTip("未解锁任何城池，请配表")
        return
    end
    local formationData = self._layerLeft._teamFormation._data[self._context._formationId]
    local weaponId = formationData["weapon4"] or 0
    self._viewMgr:showDialog("formation.NewFormationCitySelectView", {currentLoadedWeapon = weaponId, callback = function(weaponId)
        formationData["weapon4"] = weaponId
        self:updateWeaponDefInfo()
    end})
end

function NewFormationView:showBullet(isShow)
    print("show bullet", isShow)
end

function NewFormationView:showTipsInfo(isShowed)
    if not isShowed or not self._layerLeft._isIconHitted then
        self._layerLeft._layerTips:setVisible(false)
        return 
    end
    local iconType = self._layerLeft._hittedIcon:getIconType()
    local iconId = self._layerLeft._hittedIcon:getIconId()
    local isHaveCurrentTeam = self:isHaveCurrentTeam(iconId)
    if iconType ~= NewFormationView.kGridTypeTeam and iconType ~= NewFormationView.kGridTypeHireTeam and iconType ~= NewFormationView.kGridTypeIns then
        self._layerLeft._layerTips:setVisible(false)
        return 
    end
    local teamTableData = self:getTableData(iconType, iconId)
    if not teamTableData then
        self._layerLeft._layerTips:setVisible(false)
        return 
    end
    local tip = ""
    if iconType == NewFormationView.kGridTypeIns then
        if 1 == teamTableData.type then
            tip = lang("SIEGECON_TIPS21")
        elseif 2 == teamTableData.type then
            tip = lang("SIEGECON_TIPS22")
        elseif 3 == teamTableData.type then
            tip = lang("SIEGECON_TIPS23")
        end
    else
        if self._formationType == self._formationModel.kFormationTypeWeaponDef then
            tip = lang("SIEGECON_TIPS24")
        elseif self:isShowHireTeam() and iconType == NewFormationView.kGridTypeHireTeam and self:isHireTeamLoaded() then
            tip = lang("TIPS_BUZHEN_SHUOMING_7")
        elseif self:isShowHireTeam() and isHaveCurrentTeam then
            tip = lang("TIPS_BUZHEN_SHUOMING_8")
        elseif not self._layerLeft._isteamFormationLayerHitted and self:isTeamLoadedFull() and not self._layerLeft._isBeganFromTeamIconGrid then
            tip = lang("TIPS_BUZHEN_SHUOMING_6")
        elseif 1 == teamTableData.class then
            tip = lang("TIPS_BUZHEN_SHUOMING_1")
        elseif 2 == teamTableData.class then
            tip = lang("TIPS_BUZHEN_SHUOMING_2")
        elseif 3 == teamTableData.class then
            tip = lang("TIPS_BUZHEN_SHUOMING_3")
        elseif 4 == teamTableData.class then
            tip = lang("TIPS_BUZHEN_SHUOMING_4")
        elseif 5 == teamTableData.class then
            tip = lang("TIPS_BUZHEN_SHUOMING_5")
        end
    end
    self._layerLeft._layerTips:setVisible(true)
    self._layerLeft._labelTips:setString(tip)
    --self._layerLeft._layerTips:setContentSize(cc.size(math.max(280, self._layerLeft._labelTips:getContentSize().width + 30), self._layerLeft._layerTips:getContentSize().height))
    --self._layerLeft._labelTips:setPosition(self._layerLeft._layerTips:getContentSize().width / 2, self._layerLeft._layerTips:getContentSize().height / 2)
end

function NewFormationView:showScenarioHeroEffect(isShowHeroEffect)
    if isShowHeroEffect then
        self._layerLeft._fixedHeroMC1:setVisible(true)
        self._layerLeft._fixedHeroMC1:gotoAndPlay(0)
        self._layerLeft._fixedHeroMC2:setVisible(true)
        self._layerLeft._fixedHeroMC2:gotoAndPlay(0)
        --[[
        self._layerLeft._fixedHeroMC2:addEndCallback(function()
            ViewManager:getInstance():enableTalking(123, "", function() end)
        end)
        ]]
    end

    if isShowHeroEffect then
        self:lock(-1)
    end

    self._layerLeft._fixedHeroMC3:addEndCallback(function()
        self._layerLeft._fixedHeroMC3:stop()
        self._layerLeft._fixedHeroMC3:setVisible(false)

        if isShowHeroEffect then
            self:unlock()
        end

        if isShowHeroEffect then
            if self:isShowTalk() then
                ViewManager:getInstance():enableTalking(self._extend.talkId, "", function()
                    if self:isHaveFixedHero() then
                        local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                        self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeHero, iconId = self._extend.fixedHero, isShowSkillUnlockEffect = true, isCustom = true, formationType = self._formationType, closeCallback = function()
                        end}, true)
                    end
                    --[[
                    if self._extend and self._extend.storyId then
                        self._viewMgr:showDialog("intance.IntanceHeroUnlockView", {storyId = self._extend.storyId, showType = 1, callback = function()
                        end})
                    end
                    ]]
                end)
            end
        end
    end)
    self._layerLeft._fixedHeroMC3:setVisible(true)
    self._layerLeft._fixedHeroMC3:gotoAndPlay(0)
end

function NewFormationView:updateFilterType()
    local teamType = {}
    for k, v in pairs(self._layerLeft._layerList._allTeamsData) do
        if v["race"] and v["race"][1] then
            if not teamType[v["race"][1]] then
                teamType[v["race"][1]] = {}
            end
            if not (self:isLoaded(NewFormationView.kGridTypeTeam, v.teamId) or self:isFiltered(v.teamId)) then
                table.insert(teamType[v["race"][1]], v.teamId)
            end
        end
    end

    for i=1, 10 do
        local raceIndex = self._teamRaceTypeList[i + 1]
        local isEnabled = teamType[100 + raceIndex] and table.getn(teamType[100 + raceIndex]) > 0
        self._layerLeft._layerList._btnFilterType[i + 1]:setSwallowTouches(isEnabled)
        self._layerLeft._layerList._btnFilterType[i + 1]:setEnabled(isEnabled)
        self._layerLeft._layerList._btnFilterType[i + 1]:setSaturation(isEnabled and 0 or -100)

    end
end

function NewFormationView:updateHeroFilterType(  )
    local heroType = {}
    for k, v in pairs(self._layerLeft._layerList._allHerosData) do
        local heroId = v.id or v.heroId
        local heroTableData = tab:Hero(heroId)
        if heroTableData and heroTableData.masterytype then
            local raceT = tonumber(heroTableData.masterytype)
            if not heroType[raceT] then
                heroType[raceT] = {}
            end
            if not self:isLoaded(NewFormationView.kGridTypeHero, tonumber(heroId)) then
                table.insert(heroType[raceT], heroId)
            end
        end
    end
    for i = 1, 10 do
        local raceIndex = self._heroRaceTypeList[i + 1]
        local isEnabled = heroType[raceIndex] and table.getn(heroType[raceIndex]) > 0
        self._layerLeft._layerList._btnFilterType[i + 1]:setSwallowTouches(isEnabled)
        self._layerLeft._layerList._btnFilterType[i + 1]:setEnabled(isEnabled)
        self._layerLeft._layerList._btnFilterType[i + 1]:setSaturation(isEnabled and 0 or -100)
    end
end

function NewFormationView:setFilterMode(isSet)
    self:setFormationLocked(isSet)

    if isSet then
        self._layerLeft._layerList._btnTabTeam:setEnabled(false)
        self._layerLeft._layerList._btnTabHero:setEnabled(false)

        if self:isShowHireTeam() then
            self._layerLeft._layerList._btnTabHireTeam:setEnabled(false)
        end

        if self:isShowInsFormation() then
            self._layerLeft._layerList._btnTabIns:setEnabled(false)
        end
    else
        self._layerLeft._layerList._btnTabTeam:setEnabled(NewFormationView.kGridTypeTeam ~= iconType)
        self._layerLeft._layerList._btnTabHero:setEnabled(NewFormationView.kGridTypeHero ~= iconType)

        if self:isShowHireTeam() then
            self._layerLeft._layerList._btnTabHireTeam:setEnabled(NewFormationView.kGridTypeHireTeam ~= iconType)
        end

        if self:isShowInsFormation() then
            self._layerLeft._layerList._btnTabIns:setEnabled(NewFormationView.kGridTypeIns ~= iconType)
        end
    end
end

function NewFormationView:onFilterTypeButtonClicked(clickIndex)
    local gridType = self._context._gridType[self._context._formationId]
    if gridType == NewFormationView.kGridTypeTeam then
        local filterType = self._teamRaceTypeList[clickIndex]
        if filterType == self._layerLeft._layerList._filterType then return end
        self._layerLeft._layerList._filterType = 100 + filterType
        self._layerLeft._layerList._layerFilter:setVisible(false)
        self:refreshItemsTableView(true)
        self:setFilterMode(false)
    elseif gridType == NewFormationView.kGridTypeHero then
        local filterType = self._heroRaceTypeList[clickIndex]
        if filterType == self._layerLeft._layerList._filterHeroType then return end
        self._layerLeft._layerList._filterHeroType = filterType
        self._layerLeft._layerList._layerFilter:setVisible(false)
        self:refreshItemsTableView(true)
        self:setFilterMode(false)
    end    
end

function NewFormationView:onFilterButtonClicked()
    local isShow = not self._layerLeft._layerList._layerFilter:isVisible()
    local sequenceAction
    if isShow then
        self:setFilterMode(true)
        local scale = cc.ScaleTo:create(0.1, 1)
        local move = cc.MoveTo:create(0.1, cc.p(10, 138))
        local spawn = cc.Spawn:create(scale, move, cc.FadeTo:create(0.1, 255))
        sequenceAction = cc.Sequence:create(cc.CallFunc:create(function()
            self._layerLeft._layerList._layerFilter:setVisible(isShow)
        end), spawn)
        self._layerLeft._layerList._layerFilter:runAction(sequenceAction)
    else
        self:setFilterMode(false)
        local scale = cc.ScaleTo:create(0.1, 0.6)
        local move = cc.MoveTo:create(0.1, cc.p(10, 80))
        local spawn = cc.Spawn:create(scale, move, cc.FadeTo:create(0.1, 0))
        sequenceAction = cc.Sequence:create(spawn, cc.CallFunc:create(function()
            self._layerLeft._layerList._layerFilter:setVisible(isShow)
        end))
        self._layerLeft._layerList._layerFilter:runAction(sequenceAction)
    end
end

function NewFormationView:switchLayerList(iconType, force)
    if self._context._gridType[self._context._formationId] == iconType and not force then return end

    if NewFormationView.kGridTypeHero == iconType then
        if self:isHaveFixedHero() then
            self._viewMgr:showTip(string.format("这里还是上阵%s更合适。", lang(tab:NpcHero(self._extend.fixedHero).heroname)))
            return
        end
    end

    --self._context._gridType[self._context._formationId] = iconType

    local allFormationType = self._formationModel:getAllFormationType()
    for _, formationType in ipairs(allFormationType) do
        self._context._gridType[formationType] = iconType
    end

    self._layerLeft._layerList._btnTabTeam:setEnabled(NewFormationView.kGridTypeTeam ~= iconType)
    self._layerLeft._layerList._btnTabTeam:setBright(NewFormationView.kGridTypeTeam ~= iconType)

    self._layerLeft._layerList._btnTabHero:setEnabled(NewFormationView.kGridTypeHero ~= iconType)
    self._layerLeft._layerList._btnTabHero:setBright(NewFormationView.kGridTypeHero ~= iconType)

    self._layerLeft._layerList._btnFilter:setEnabled((NewFormationView.kGridTypeTeam == iconType or NewFormationView.kGridTypeHero == iconType))
    self._layerLeft._layerList._btnFilter:setSaturation((NewFormationView.kGridTypeTeam == iconType or NewFormationView.kGridTypeHero == iconType) and 0 or -100)
    if NewFormationView.kGridTypeTeam == iconType then
        self:updateFilterType()
    elseif NewFormationView.kGridTypeHero == iconType then
        self:updateHeroFilterType()
    end

    if self:isShowHireTeam() then
        self._layerLeft._layerList._btnTabHireTeam:setEnabled(NewFormationView.kGridTypeHireTeam ~= iconType)
        self._layerLeft._layerList._btnTabHireTeam:setBright(NewFormationView.kGridTypeHireTeam ~= iconType)
    end

    if self:isShowInsFormation() then
        self._layerLeft._layerList._btnTabIns:setEnabled(NewFormationView.kGridTypeIns ~= iconType)
        self._layerLeft._layerList._btnTabIns:setBright(NewFormationView.kGridTypeIns ~= iconType)
    end

    self._layerLeft._layerList._imageBubbleRecom:setVisible(false)

    if self:isShowPveRecommendHero() then
        if self._formationType == self._formationModel.kFormationTypeWorldBoss then
            if not self._pveRecommendHeroCheck then
                local formationData = self._layerLeft._teamFormation._data[self._formationType]
                local heroId = formationData.heroId or 0
                if self._recommend and #self._recommend > 0 and not self:isRecommend(heroId) then
                    self._layerLeft._layerList._imageBubbleRecom:setVisible(true)
                    self._layerLeft._layerList._imageBubbleRecom:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(1, 1.2), 
                    cc.ScaleTo:create(1, 1.0))))
                end
            end
            if NewFormationView.kGridTypeHero == iconType then
                self._layerLeft._layerList._imageBubbleRecom:setVisible(false)
                self._layerLeft._layerList._imageBubbleRecom:stopAllActions()
                self._pveRecommendHeroCheck = true
            end
        else
            local heroId = 0
            if not self._pveRecommendHeroCheck then
                for k, v in ipairs(self._layerLeft._layerList._heroData) do
                    if self:isRecommend(v.id) then
                        if 1 ~= SystemUtils.loadAccountLocalData("PVERECOMMAENDHERO_" .. v.id) then
                            heroId = v.id
                            self._layerLeft._layerList._imageBubbleRecom:setVisible(true)
                            self._layerLeft._layerList._imageBubbleRecom:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(1, 1.2), 
                            cc.ScaleTo:create(1, 1.0))))
                            break
                        end
                    end
                end
            end

            if NewFormationView.kGridTypeHero == iconType then
                self._layerLeft._layerList._imageBubbleRecom:setVisible(false)
                self._layerLeft._layerList._imageBubbleRecom:stopAllActions()
                if 0 ~= heroId then
                    SystemUtils.saveAccountLocalData("PVERECOMMAENDHERO_" .. heroId, 1)
                end
                self._pveRecommendHeroCheck = true
            end
        end
    end

    if NewFormationView.kGridTypeTeam == iconType then
        self._layerLeft._layerList._btnTabTeam:setTitleColor(cc.c4b(252, 244, 197, 255))
        --self._layerLeft._layerList._btnTabTeam:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

        self._layerLeft._layerList._btnTabHero:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabHero:getTitleRenderer():disableEffect()

        self._layerLeft._layerList._btnTabHireTeam:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabHireTeam:getTitleRenderer():disableEffect()

        self._layerLeft._layerList._btnTabIns:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabHireTeam:getTitleRenderer():disableEffect()
    elseif NewFormationView.kGridTypeHero == iconType then
        self._layerLeft._layerList._btnTabHero:setTitleColor(cc.c4b(252, 244, 197, 255))
        --self._layerLeft._layerList._btnTabHero:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

        self._layerLeft._layerList._btnTabTeam:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabTeam:getTitleRenderer():disableEffect()

        self._layerLeft._layerList._btnTabHireTeam:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabHireTeam:getTitleRenderer():disableEffect()

        self._layerLeft._layerList._btnTabIns:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabHireTeam:getTitleRenderer():disableEffect()
    elseif NewFormationView.kGridTypeHireTeam == iconType and self:isShowHireTeam() then
        self._layerLeft._layerList._btnTabHireTeam:setTitleColor(cc.c4b(252, 244, 197, 255))
        --self._layerLeft._layerList._btnTabHireTeam:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

        self._layerLeft._layerList._btnTabHero:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabHero:getTitleRenderer():disableEffect()

        self._layerLeft._layerList._btnTabTeam:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabTeam:getTitleRenderer():disableEffect()

        self._layerLeft._layerList._btnTabIns:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabHireTeam:getTitleRenderer():disableEffect()
    elseif NewFormationView.kGridTypeIns == iconType and self:isShowInsFormation() then

        if self:isInsBubbleShow() then
            self._layerLeft._layerList._imageInsBubble:setVisible(false)
            self._layerLeft._layerList._imageInsBubble:stopAllActions()
            self._formationModel:setWeaponTipsShowed(self._context._formationId)
        end

        self._layerLeft._layerList._btnTabIns:setTitleColor(cc.c4b(252, 244, 197, 255))
        --self._layerLeft._layerList._btnTabHireTeam:getTitleRenderer():disableEffect()

        self._layerLeft._layerList._btnTabHero:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabHero:getTitleRenderer():disableEffect()

        self._layerLeft._layerList._btnTabTeam:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabTeam:getTitleRenderer():disableEffect()

        self._layerLeft._layerList._btnTabHireTeam:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabHireTeam:getTitleRenderer():disableEffect()
    end
    --[[
    -- version 6.0
    if NewFormationView.kGridTypeHero == iconType then
        local posX, posY = self._layerLeft._heroFormation._layer:getPosition()
        local size = self._layerLeft._heroFormation._layer:getContentSize()
        self._layerLeft._heroFormationMaskLayer:beginWithClear(0, 0, 0, 0.65)
        local sprite = cc.Sprite:create("asset/other/circle.png")
        sprite:setPosition(posX + size.width / 2, posY + size.height / 2)
        sprite:setBlendFunc({src = gl.ZERO, dst = gl.ONE_MINUS_SRC_ALPHA})
        sprite:visit()
        self._layerLeft._heroFormationMaskLayer:endToLua()
        self._layerLeft._heroFormationMaskLayer:setVisible(true)
        --self._layerLeft._heroFormationMaskLayer:getSprite():setOpacity(255)
    else
        self._layerLeft._heroFormationMaskLayer:removeAllChildren()
        --self._layerLeft._heroFormationMaskLayer:getSprite():runAction(cc.FadeOut:create(0.2))
        self._layerLeft._heroFormationMaskLayer:setVisible(false)
    end
    ]]

    self:updateLeftTeamFormationAddition(not (NewFormationView.kGridTypeTeam == iconType or NewFormationView.kGridTypeHireTeam == iconType))
    self:updateLeftHeroAddition(NewFormationView.kGridTypeHero ~= iconType)
    self:updateLeftInsFormationAddition(NewFormationView.kGridTypeIns ~= iconType)

    self:refreshItemsTableView(true)
end

function NewFormationView:updateLeftTeamFormation(formationId)
    formationId = tonumber(formationId) or tonumber(self._context._formationId)
    --print("update team formation id:", formationId)

    if not (self._layerLeft._teamFormation._data and self._layerLeft._teamFormation._data[formationId]) then return end

    for i = 1, NewFormationView.kTeamGridCount do
        self._layerLeft._teamFormation._grid[i]:setIconView()
    end

    for i = 1, NewFormationView.kTeamMaxCount do
        repeat
            local teamId = self._layerLeft._teamFormation._data[formationId][string.format("team%d", i)]
            if 0 == teamId then break end
            local isHireTeam = self:isHireTeam(teamId)
            local teamPositionId = self._layerLeft._teamFormation._data[formationId][string.format("g%d", i)]
            local iconGrid = self._layerLeft._teamFormation._grid[teamPositionId]
            local iconView = NewFormationIconView.new({iconType = isHireTeam and NewFormationView.kGridTypeHireTeam or NewFormationView.kGridTypeTeam, iconId = teamId, iconState = NewFormationIconView.kIconStateBody, formationType = self._formationType, isCustom = self:isTeamCustom(teamId), isLocal = self:isTeamLocal(teamId), container = self})
            --[[
            if self:isFiltered(teamId) then
                iconView:showFilter(true)
            end
            ]]
            local isNeedChanged, changeTeamId = self:isTeamNeedChanged(teamId)
            if isNeedChanged then
                iconView:changeProfile(changeTeamId)
            end
            iconView:setName("icon_"..i)
            iconGrid:setIconView(iconView)
            iconGrid:updateState()
        until true
    end

    for i = 1, NewFormationView.kInsMaxCount do
        self._layerLeft._insFormation._grid[i]:setIconView()
    end

    local custom = self:isHaveFixedWeapon()
    for i=1, NewFormationView.kInsMaxCount do
        repeat
            local insId = self._layerLeft._teamFormation._data[formationId]["weapon" .. i]
            if not insId or  0 == insId then break end
            local iconGrid = self._layerLeft._insFormation._grid[i]
            local iconSubtype = tab:SiegeWeapon(insId).type
            if not iconSubtype then break end
            local iconView = NewFormationIconView.new({iconType = NewFormationView.kGridTypeIns, iconSubtype = iconSubtype, iconId = insId, iconState = NewFormationIconView.kIconStateBody, formationType = self._formationType, isCustom = custom, container = self})
            --[[
            if self:isFiltered(teamId) then
                iconView:showFilter(true)
            end
            ]]
            iconView:setName("icon_weapon"..i)
            iconGrid:setIconView(iconView)
            iconGrid:updateState()
        until true
    end

    if not self._layerLeft._teamFormation._initFormation then
        self._layerLeft._teamFormation._initFormation = true
    end    
end

function NewFormationView:updateLeftTeamFormationAddition(forceHide)
    print("updateLeftTeamFormationAddition", forceHide)
    local isTeamLoadedFull = self:isTeamLoadedFull(nil, true)
    for i = 1, NewFormationView.kTeamGridCount do
        local iconGrid = self._layerLeft._teamFormation._grid[i]
        if self:isLeftGridWall(i) then
            iconGrid:setState(FormationGrid.kStateWall)
        elseif not isTeamLoadedFull and not iconGrid:isStateFull() and not iconGrid:isStateWall() and not forceHide then
            iconGrid:setState(FormationGrid.kStateAddition)
        else
            iconGrid:unsetState(FormationGrid.kStateWall)
            iconGrid:unsetState(FormationGrid.kStateAddition)
        end
        iconGrid:updateState()
    end
end

function NewFormationView:updateLeftHeroAddition(forceHide)
    print("updateLeftHeroAddition", forceHide)
    local iconGrid = self._layerLeft._heroFormation._grid
    if not forceHide then
        iconGrid:setState(FormationGrid.kStateAddition)
    else
        iconGrid:unsetState(FormationGrid.kStateAddition)
    end
    iconGrid:updateState()
end

function NewFormationView:updateLeftInsFormationAddition(forceHide)
    print("updateLeftInsFormationAddition", forceHide)
    for i=1, NewFormationView.kInsMaxCount do
        local iconGrid = self._layerLeft._insFormation._grid[i]
        if not iconGrid:isStateFull() and not forceHide then
            iconGrid:setState(FormationGrid.kStateAddition)
        else
            iconGrid:unsetState(FormationGrid.kStateAddition)
        end
        iconGrid:updateState()
    end
end

function NewFormationView:updateSelectedState()
    for i = 1, NewFormationView.kTeamGridCount do
        local iconGrid = self._layerLeft._teamFormation._grid[i]
        iconGrid:unsetState(FormationGrid.kStateSelected)
        iconGrid:updateState()
    end

    local iconGrid = self._layerLeft._heroFormation._grid
    iconGrid:unsetState(FormationGrid.kStateSelected)
    iconGrid:updateState()

    for i=1, NewFormationView.kInsMaxCount do
        local iconGrid = self._layerLeft._insFormation._grid[i]
        iconGrid:unsetState(FormationGrid.kStateSelected)
        iconGrid:updateState()
    end
end

function NewFormationView:updateLeftHeroFormation(formationId)
    formationId = tonumber(formationId) or tonumber(self._context._formationId)
    --print("update hero formation id:", formationId)

    if not (self._layerLeft._teamFormation._data and self._layerLeft._teamFormation._data[formationId]) then return end

    self._layerLeft._heroFormation._grid:setIconView()

    local heroId = self._layerLeft._teamFormation._data[formationId].heroId
    if 0 == heroId then return end
    local iconGrid = self._layerLeft._heroFormation._grid
    local iconView = NewFormationIconView.new({iconType = NewFormationView.kGridTypeHero, iconId = heroId, iconState = NewFormationIconView.kIconStateBody, formationType = self._formationType, isCustom = self:isHeroCustom(heroId), isLocal = self:isHeroLocal(heroId), isScenarioHero = self:isScenarioHero(heroId), container = self})
    iconGrid:setIconView(iconView)
    iconGrid:updateState()
end

function NewFormationView:updateRightTeamFormationPreview()
    if not self:isShowEnemyFormation() then return end

    for i = 1, NewFormationView.kTeamGridCount do
        self._layerLeft._layerRightFormation._icon[i]:removeAllChildren()
        if self:isRightGridWall(i) then
            local iconGrid = self._layerLeft._layerRightFormation._icon[i]
            local imageView = ccui.ImageView:create(IconUtils.iconPath .. "image_wall_forma.png", 1)
            imageView:setScale(0.75)
            --imageView:setFlippedX(true)
            imageView:setPosition(cc.p(iconGrid:getContentSize().width / 2, iconGrid:getContentSize().height / 2))
            iconGrid:addChild(imageView)
        end
    end

    for i = 1, NewFormationView.kTeamMaxCount do
        repeat
            local teamId = self._enemyFormationData[self._context._formationId][string.format("team%d", i)]
            if 0 == teamId or not teamId then break end
            local teamPositionId = self._enemyFormationData[self._context._formationId][string.format("g%d", i)]
            local teamTableData = nil
            local enemyTeamType = NewFormationIconView.getEnemyTeamTypeByFormationType(self._formationType)

            local className = nil
            if enemyTeamType == NewFormationIconView.kIconTypeArenaTeam then
                teamTableData = tab:Team(teamId)
                local teamData = self._modelMgr:getModel("ArenaModel"):getEnemyDataById(teamId)
                className = TeamUtils:getClassIconNameByTeamD(teamData, "classlabel", teamTableData, true)
            elseif enemyTeamType == NewFormationIconView.kIconTypeCrusadeTeam then
                teamTableData = tab:Team(teamId)
                local teamData = self._modelMgr:getModel("CrusadeModel"):getEnemyTeamDataById(teamId)
                className = TeamUtils:getClassIconNameByTeamD(teamData, "classlabel", teamTableData, true)
            elseif enemyTeamType == NewFormationIconView.kIconTypeGuildTeam then
                teamTableData = tab:Team(teamId)
                local teamData = self._modelMgr:getModel("GuildMapModel"):getEnemyDataById(teamId)
                className = TeamUtils:getClassIconNameByTeamD(teamData, "classlabel", teamTableData, true)
            elseif enemyTeamType == NewFormationIconView.kFormationTypeLeague then
                teamTableData = tab:Team(teamId)
                local teamData = self._modelMgr:getModel("LeagueModel"):getEnemyDataById(teamId)
                className = TeamUtils:getClassIconNameByTeamD(teamData, "classlabel", teamTableData, true)
            elseif enemyTeamType == NewFormationIconView.kIconTypeMFTeam then
                teamTableData = tab:Team(teamId)
                local teamData = self._modelMgr:getModel("MFModel"):getEnemyDataById(teamId)
                className = TeamUtils:getClassIconNameByTeamD(teamData, "classlabel", teamTableData, true)
            elseif enemyTeamType == NewFormationIconView.kIconTypeAdventureTeam then
                teamTableData = tab:Team(teamId)
                local teamData = self._modelMgr:getModel("AdventureModel"):getEnemyDataById(teamId)
                className = TeamUtils:getClassIconNameByTeamD(teamData, "classlabel", teamTableData, true)
            elseif enemyTeamType == NewFormationIconView.kIconTypeCrossPKTeam then
                teamTableData = tab:Team(teamId)
                local teamData = self._modelMgr:getModel("CrossModel"):getEnemyDataById(teamId)
                className = TeamUtils:getClassIconNameByTeamD(teamData, "classlabel", teamTableData, true)
            else
                teamTableData = tab:Npc(teamId)
                className = TeamUtils:getNpcClassName(teamTableData)
            end
            local iconGrid = self._layerLeft._layerRightFormation._icon[teamPositionId]
            if not iconGrid then break end
            local imageView = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
            imageView:setScale(0.75)
            --imageView:setFlippedX(true)
            imageView:setPosition(cc.p(iconGrid:getContentSize().width / 2, iconGrid:getContentSize().height / 2))
            iconGrid:addChild(imageView)
        until true
    end
end

function NewFormationView:updateLeftTeamFormationPreview(formationId)
    formationId = tonumber(formationId) or tonumber(self._context._formationId)
    --print("update team formation id:", formationId)

    if not (self._layerLeft._teamFormation._data and self._layerLeft._teamFormation._data[formationId]) then return end

    for i = 1, NewFormationView.kTeamGridCount do
        self._layerRight._layerLeftFormation[i]:removeAllChildren()
    end

    for i = 1, NewFormationView.kTeamMaxCount do
        repeat
            local teamId = self._layerLeft._teamFormation._data[formationId][string.format("team%d", i)]
            if 0 == teamId then break end
            local isHireTeam = self:isHireTeam(teamId)
            local teamPositionId = self._layerLeft._teamFormation._data[formationId][string.format("g%d", i)]
            local teamTableData = self:getTableData(isHireTeam and NewFormationView.kGridTypeHireTeam or NewFormationView.kGridTypeTeam, teamId)
            local iconGrid = self._layerRight._layerLeftFormation[teamPositionId]
            local teamD = self._teamModel:getTeamAndIndexById(teamId)
            local className = TeamUtils:getClassIconNameByTeamD(teamD, "classlabel", teamTableData, true)
            local imageView = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
            imageView:setScale(0.75)
            imageView:setPosition(cc.p(iconGrid:getContentSize().width / 2, iconGrid:getContentSize().height / 2))
            iconGrid:addChild(imageView)
        until true
    end
end

function NewFormationView:updateRightTeamFormation()
    if not (self._enemyFormationData and type(self._enemyFormationData) == "table" and self._enemyFormationData[self._context._formationId]) then return end

    for i = 1, NewFormationView.kTeamGridCount do
        self._layerRight._teamFormation._grid[i]:removeChildByTag(NewFormationView.kRightFormationTag)
        if self:isRightGridWall(i) then
            self._layerRight._teamFormation._gridWall[i]:setVisible(true)
        end
        local iconGridFull = self._layerRight._teamFormation._gridFull[i]
        iconGridFull:setVisible(false)
    end

    for i = 1, NewFormationView.kTeamMaxCount do
        repeat
            local teamId = self._enemyFormationData[self._context._formationId][string.format("team%d", i)]
            if 0 == teamId or not teamId then break end
            local teamPositionId = self._enemyFormationData[self._context._formationId][string.format("g%d", i)]
            local iconGrid = self._layerRight._teamFormation._grid[teamPositionId]
            local iconGridFull = self._layerRight._teamFormation._gridFull[teamPositionId]
            iconGridFull:setVisible(true)
            local iconGridHexin1 = self._layerRight._teamFormation._gridHexin1[teamPositionId]
            local iconGridHexin2 = self._layerRight._teamFormation._gridHexin2[teamPositionId]
            iconGridHexin1:setVisible(self:isEnemyHexin(teamId))
            iconGridHexin2:setVisible(self:isEnemyHexin(teamId))
            local iconView = NewFormationIconView.new({iconType = NewFormationIconView.getEnemyTeamTypeByFormationType(self._formationType), iconId = teamId, iconState = NewFormationIconView.kIconStateBody, formationType = self._formationType, container = self})
            --[[
            if self:isEnemyFiltered(teamId) then
                iconView:showFilter(true)
            end
            ]]
            local isNeedChanged, changeTeamId = self:isEnemyTeamNeedChanged(teamId)
            if isNeedChanged then
                iconView:changeEnemyProfile(changeTeamId)
            end
            iconView:setRotation3D(cc.Vertex3F(NewFormationView.kIconRotateDegree, 0, 0))
            iconView:enableTouch(false)
            iconView:setTag(NewFormationView.kRightFormationTag)
            iconView:setPosition(iconGrid:getContentSize().width / 2, iconGrid:getContentSize().height / 2)
            iconGrid:addChild(iconView, NewFormationView.kNormalZOrder)
        until true
    end

    for i = 1, NewFormationView.kInsMaxCount do
        self._layerRight._insFormation._grid[i]:removeAllChildren()
    end

    for i=1, NewFormationView.kInsMaxCount do
        repeat
            local insId = self._enemyFormationData[self._context._formationId]["weapon" .. i]
            if not insId or  0 == insId then break end
            local iconGrid = self._layerRight._insFormation._grid[i]
            local iconSubtype = tab:SiegeWeapon(insId).type
            if not iconSubtype then break end
            local iconView = NewFormationIconView.new({iconType = NewFormationView.kGridTypeIns, iconSubtype = iconSubtype, iconId = insId, iconState = NewFormationIconView.kIconStateBody, formationType = self._formationType, isCustom = custom, container = self})
            iconView:setName("icon_enemy_weapon"..i)
            iconView:setRotation3D(cc.Vertex3F(-26, 180, 0))
            iconView:setPosition(iconGrid:getContentSize().width / 2, iconGrid:getContentSize().height / 2)
            iconGrid:addChild(iconView, NewFormationView.kNormalZOrder)
        until true
    end
end

function NewFormationView:updateRightHeroFormation()
    if not (self._enemyFormationData and type(self._enemyFormationData) == "table" and self._enemyFormationData[self._context._formationId]) then return end
    if self._enemyFormationData[self._context._formationId].heroId == NewFormationView.kNullHeroId then return end

    self._layerRight._heroFormation._grid:removeChildByTag(NewFormationView.kRightFormationTag)

    local heroId = self._enemyFormationData[self._context._formationId].heroId
    local iconGrid = self._layerRight._heroFormation._grid
    local iconGridFull = self._layerRight._heroFormation._gridFull
    iconGridFull:setVisible(true)
    local iconView = NewFormationIconView.new({iconType = NewFormationIconView.getEnemyHeroTypeByFormationType(self._formationType), iconId = heroId, iconState = NewFormationIconView.kIconStateBody, formationType = self._formationType, container = self})
    iconView:setRotation3D(cc.Vertex3F(NewFormationView.kIconRotateDegree, 0, 0))
    iconView:enableTouch(false)
    iconView:setTag(NewFormationView.kRightFormationTag)
    iconView:setPosition(iconGrid:getContentSize().width / 2, iconGrid:getContentSize().height / 2)
    iconGrid:addChild(iconView, NewFormationView.kNormalZOrder)
end

function NewFormationView:updateRelative(formationId)
    formationId = tonumber(formationId) or tonumber(self._context._formationId)

    --self._layerLeft._imageInfoBg1:setContentSize(cc.size(245, 21))
    if formationId == self._formationModel.kFormationTypeTraining and not self:isShowBullet() then
        self._layerLeft._labelFormationName:setString("英雄传记编组")
    elseif self._extend and self._extend.isSimpleFormation then
        self._layerLeft._labelFormationName:setString("推荐阵容编组")
    else
        self._layerLeft._labelFormationName:setString(self._formationModel:getFormationNameById(formationId))
    end
    self._layerLeft._labelCurrentFightScore:setScale(0.58)
    self._layerLeft._labelCurrentFightScore:setString("a" .. self:getCurrentFightScore())
    local newW = self._layerLeft._labelCurrentFightScore:getContentSize().width
    local scale = 320 / newW
    if scale > 1 then scale = 1 end
    self._layerLeft._labelCurrentFightScore:setScale(scale * 0.58)
    --self._layerLeft._btnFormationSelect:setPositionX()
    self._layerRight._layerLeftFormationScore:setString("a"..self:getCurrentFightScore())

    local team_count = self:getCurrentLoadedTeamCount()
    --self._layerLeft._labelCurrentLoad:setPositionX(self._layerLeft._teamFormation._allowLoadCount.currentTeamCount >= self._layerLeft._teamFormation._allowLoadCount.maxTeamCount and 166 or 78)
    --self._layerLeft._labelTeamValue1:setPositionX(self._layerLeft._teamFormation._allowLoadCount.currentTeamCount >= self._layerLeft._teamFormation._allowLoadCount.maxTeamCount and 258 or 170)
    local color = cc.c3b(205, 32, 30)
    if team_count >= self._layerLeft._teamFormation._allowLoadCount.currentTeamCount then
        color = cc.c3b(39, 247, 58)
    end

    self._layerLeft._labelCurrentLoadMC:setVisible(team_count < self._layerLeft._teamFormation._allowLoadCount.currentTeamCount)
    self._layerLeft._labelTeamValue1:setColor(color)
    self._layerLeft._labelTeamValue1:setString(team_count)
    self._layerLeft._labelTeamValue2:setString("/" .. self._layerLeft._teamFormation._allowLoadCount.currentTeamCount)

    self._layerLeft._labelNextUnlockLoad:setVisible(true)
    if self._layerLeft._teamFormation._allowLoadCount.currentTeamCount >= self._layerLeft._teamFormation._allowLoadCount.maxTeamCount or self:isShowCloudInfo() or self:isShowButtonTraining() then
        self._layerLeft._labelNextUnlockLoad:setVisible(false)
        --self._layerLeft._imageInfoBg2:setContentSize(cc.size(190, 21))
    else
        self._layerLeft._labelNextUnlockLoad:setVisible(true)
        self._layerLeft._labelNextUnlockLoad:setString("(" .. self._layerLeft._teamFormation._allowLoadCount.nextTeamCountUnlockLevel .. "级开启下一位置)")
        --self._layerLeft._imageInfoBg2:setContentSize(cc.size(330, 21))
    end

    if self:isShowAwakingTaskInfo() then
        self:updateAwakingTaskInfo()
    end

    if self:isNewFormationViewEx() then
        self:updateRelativeEx()
    end
end

function NewFormationView:updateRelativeEx()

end

function NewFormationView:updateAwakingTaskInfo()
    if not self:isShowAwakingTaskInfo() then return end

    for i=1, 2 do
        self._layerLeft._awakingTaskInfo._taskInfo._labelDes[i] = self._layer_information:getChildByFullName("info_left.awaking_task_info.label_des_" .. i)
        self._layerLeft._awakingTaskInfo._taskInfo._labelLoad[i] = self._layer_information:getChildByFullName("info_left.awaking_task_info.label_current_load_" .. i)
        self._layerLeft._awakingTaskInfo._taskInfo._labelValue[i] = self._layer_information:getChildByFullName("info_left.awaking_task_info.label_team_value_" .. i)
    end

    local awakingData = self._awakingModel:getAwakingTaskData()
    if not awakingData then return end
    local awakingTaskData = tab:AwakingTask(awakingData.taskId)
    if not awakingTaskData then return end
    local taskInfo = {}
    local count = 0
    if awakingTaskData.heros then
        local heroData = tab:Hero(awakingTaskData.heros)
        if heroData then
            count = count + 1
            taskInfo[count] = {
                heroname = "",
                teamname = "",
                num = 0,
                value = 0,
                conditiontype = 1,
                condition = {1},
                race = "",
                class = "",
                desc = "",
            }
            taskInfo[count].heroname = lang(heroData.heroname)
            taskInfo[count].desc = lang("AWAKING_BUZHEN_TIPS_1")
            taskInfo[count].conditiontype = 1
            taskInfo[count].condition = {tonumber(awakingTaskData.heros), 1}
        end
    end

    if awakingTaskData.warrior then
        local teamData = tab:Team(awakingTaskData.warrior[1])
        if teamData then
            count = count + 1
            taskInfo[count] = {
                heroname = "",
                teamname = "",
                num = 0,
                value = 0,
                conditiontype = 1,
                condition = {1},
                race = "",
                class = "",
                desc = "",
            }
            taskInfo[count].teamname = lang(teamData.name)
            taskInfo[count].desc = lang("AWAKING_BUZHEN_TIPS_2")
            taskInfo[count].conditiontype = 2
            taskInfo[count].condition = {tonumber(awakingTaskData.warrior[1]), 1}
        end
    end

    if awakingTaskData.needRace then
        count = count + 1
        taskInfo[count] = {
            heroname = "",
            teamname = "",
            num = 0,
            value = 0,
            conditiontype = 1,
            condition = {1},
            race = "",
            class = "",
            desc = "",
        }
        taskInfo[count].race = lang(tab:Race(awakingTaskData.needRace[1]).name)
        taskInfo[count].num = awakingTaskData.needRace[2]
        taskInfo[count].desc = lang("AWAKING_BUZHEN_TIPS_3")
        taskInfo[count].conditiontype = 3
        taskInfo[count].condition = {awakingTaskData.needRace[1], awakingTaskData.needRace[2]}
    end

    if awakingTaskData.needClass then
        count = count + 1
        taskInfo[count] = {
            heroname = "",
            teamname = "",
            num = 0,
            value = 0,
            conditiontype = 1,
            condition = {1},
            race = "",
            class = "",
            desc = "",
        }
        taskInfo[count].class = lang("CLASS_10" .. awakingTaskData.needClass[1] .. "0")
        taskInfo[count].num = awakingTaskData.needClass[2]
        taskInfo[count].desc = lang("AWAKING_BUZHEN_TIPS_4")
        taskInfo[count].conditiontype = 4
        taskInfo[count].condition = {awakingTaskData.needClass[1], awakingTaskData.needClass[2]}
    end

    for i = 1, 2 do
        self._layerLeft._awakingTaskInfo._taskInfo._labelDes[i]:setVisible(false)
        self._layerLeft._awakingTaskInfo._taskInfo._labelLoad[i]:setVisible(false)
        self._layerLeft._awakingTaskInfo._taskInfo._labelValue[i]:setVisible(false)
    end

    self._layerLeft._awakingTaskInfo._taskInfo._labelDes[1]:setPositionY(1 == count and 95 or 110)
    self._layerLeft._awakingTaskInfo._taskInfo._labelLoad[1]:setPositionY(1 == count and 112 or 126)
    self._layerLeft._awakingTaskInfo._taskInfo._labelValue[1]:setPositionY(1 == count and 112 or 126)

    local hireTeamId = 0
    if self:isHireTeamLoaded() then
        hireTeamId = self:getLoadedHireTeam()
    end


    for i = 1, count do
        local heroname = taskInfo[i].heroname
        local teamname = taskInfo[i].teamname
        local num = taskInfo[i].num
        local conditiontype = taskInfo[i].conditiontype
        local condition = taskInfo[i].condition
        local race = taskInfo[i].race
        local class = taskInfo[i].class
        local desc =taskInfo[i].desc
        local value = 0

        local varibleNameToValue = {
            ["$heroname"] = heroname,
            ["$teamname"] = teamname,
            ["$num"] = num,
            ["$race"] = race,
            ["$class"] = class,
        }

        desc = string.gsub(desc, "%b{}", function(substring)
            return string.gsub(string.gsub(substring, "%$%w+", function(variableName)
                return tostring(varibleNameToValue[variableName])
            end), "[{}]", "")
        end)

        desc = string.gsub(desc, "，", ",")

        local label = self._layerLeft._awakingTaskInfo._taskInfo._labelDes[i]
        local richText = label:getChildByName("descRichText" )
        if richText then
            richText:removeFromParentAndCleanup()
        end
        richText = RichTextFactory:create(desc, label:getContentSize().width, label:getContentSize().height)
        richText:setVerticalSpace(-2)
        richText:formatText()
        richText:enablePrinter(true)
        richText:setPosition(label:getContentSize().width / 2, label:getContentSize().height / 2)
        richText:setName("descRichText")
        label:addChild(richText)

        local caculateConditionValue = function()
            local result = 0
            local formationData = self._layerLeft._teamFormation._data[self._context._formationId]
            if 1 == conditiontype then
                result = condition[1] == tonumber(formationData["heroId"]) and 1 or 0
            elseif 2 == conditiontype then
                for i=1, NewFormationView.kTeamMaxCount do
                    local teamId = tonumber(formationData["team" .. i])
                    if teamId and 0 ~= teamId and teamId ~= hireTeamId then
                        if teamId == condition[1] then
                            result = 1
                            break
                        end
                    end
                end
            elseif 3 == conditiontype then
                for i=1, NewFormationView.kTeamMaxCount do
                    local teamId = tonumber(formationData["team" .. i])
                    if teamId and 0 ~= teamId and teamId ~= hireTeamId then
                        local teamData = tab:Team(teamId)
                        if teamData and teamData.race and teamData.race[1] and teamData.race[1] == condition[1] then
                            result = result + 1
                        end
                    end
                end
            elseif 4 == conditiontype then
                for i=1, NewFormationView.kTeamMaxCount do
                    local teamId = tonumber(formationData["team" .. i])
                    if teamId and 0 ~= teamId and teamId ~= hireTeamId then
                        local teamData = tab:Team(teamId)
                        if teamData and teamData.class and teamData.class == condition[1] then
                            result = result + 1
                        end
                    end
                end
            end
            return result
        end

        value = caculateConditionValue()

        if value > condition[2] then
            value = condition[2]
        end

        local isReach = value >= condition[2]
        self._layerLeft._awakingTaskInfo._taskInfo._labelValue[i]:setColor(isReach and cc.c3b(39, 247, 58) or cc.c3b(251, 47, 44))
        self._layerLeft._awakingTaskInfo._taskInfo._labelValue[i]:setString(value .. "/" .. condition[2])

        self._layerLeft._awakingTaskInfo._taskInfo._labelDes[i]:setVisible(true)
        self._layerLeft._awakingTaskInfo._taskInfo._labelLoad[i]:setVisible(true)
        self._layerLeft._awakingTaskInfo._taskInfo._labelValue[i]:setVisible(true)
    end
end

function NewFormationView:updateBattleInfo()
    self._btnBattle:setVisible(self:isShowButtonBattle() and not self:isShowNextFight())
    self._imageBattle:setVisible(not self:isShowCountDownInfo() and not self:isShowNextFight())
    self._imageReady:setVisible(self:isShowReadyBattle())
    self._imageAlready:setVisible(self:isShowAlreadyBattle())
    self._btnNextFight:setVisible(self:isShowNextFight())
    self._btnUnloadAll:setVisible(self:isShowCloudInfo())
end

function NewFormationView:updateLeagueBattleInfo(noAnim)
    self._btnBattle:setEnabled(false)
    self._btnBattle:setSaturation(-100)
    self._btnBattle:getChildByTag(NewFormationView.kBattleLightTag):setVisible(false)
    self._isBattleButtonClicked = true
    self:setFormationLocked(true)
    if not noAnim then
        local mc = mcMgr:createViewMC("zhunbeitexiao_leagueanniuzhunbei", false, true, function(_, sender)
            sender:stop()
        end, RGBA8888)
        --mc:setPosition(self._imageAlready:getContentSize().width / 2, self._imageAlready:getContentSize().height / 2)
        --self._imageAlready:addChild(mc,99)
        mc:setPosition(self._btnBattle:getPosition())
        local buttonParent = self._btnBattle:getParent()
        if buttonParent then
            buttonParent:addChild(mc, 99)
        end
    end
    self:updateBattleInfo()
end

function NewFormationView:updateCloudInfo()
    if not self:isShowCloudInfo() then return end
    if self._extend.cloudData1 and self._extend.cloudData2 then
        local cloudData = self._extend.cloudData1
        if self._context._formationId == self._formationModel.kFormationTypeCloud2 then
            cloudData = self._extend.cloudData2
        end
        local label = self._layerLeft._cloudInfo._labelEvnDes
        local desc = cloudData.info and lang(cloudData.info) or "[color=3D1F00, fontsize=20]" .. "no info" .. "[-]"
        local richText = label:getChildByName("descRichText" )
        if richText then
            richText:removeFromParentAndCleanup()
        end
        richText = RichTextFactory:create(desc, 230, 70)
        richText:setVerticalSpace(-4)
        richText:formatText()
        richText:enablePrinter(true)
        richText:setPosition(label:getContentSize().width / 2, label:getContentSize().height / 2)
        richText:setName("descRichText")
        label:addChild(richText)
    end
    self._layerLeft._cloudInfo._title1:setVisible(self._context._formationId == self._formationModel.kFormationTypeCloud1)
    self._layerLeft._cloudInfo._title2:setVisible(self._context._formationId == self._formationModel.kFormationTypeCloud2)

    if self._extend.allowBattle then
        self:setFormationLocked(not self._extend.allowBattle[self._context._formationId])
    end
end

function NewFormationView:updateStakeInfo(  )
    if not self:isShowStakeAtkDef2() then return end
    self._layerLeft._cloudInfo._title1:setVisible(self._context._formationId == self._formationModel.kFormationTypeStakeAtk2)
    self._layerLeft._cloudInfo._title2:setVisible(self._context._formationId == self._formationModel.kFormationTypeStakeDef2)

    local formationId1 = self._context._formationId
    local formationId2 = self._formationModel.kFormationTypeStakeAtk2 + self._formationModel.kFormationTypeStakeDef2 - formationId1
    local formationData = self._layerLeft._teamFormation._data[formationId2]

    self._layerLeft._layerRightFormationScore:setString("a" .. self:getCurrentFightScore(formationId2))

    for i = 1, NewFormationView.kTeamGridCount do
        self._layerLeft._layerRightFormation._icon[i]:removeAllChildren()
    end

    self._layerLeft._layerRightFormationTitle:setString(self._context._formationId == self._formationModel.kFormationTypeStakeAtk2 and "防守阵容" or "进攻阵容")

    for i = 1, NewFormationView.kTeamMaxCount do
        repeat
            local teamId = formationData[string.format("team%d", i)]
            if 0 == teamId or not teamId then break end
            local teamPositionId = formationData[string.format("g%d", i)]
            local teamTableData = tab.team[teamId]
            local iconGrid = self._layerLeft._layerRightFormation._icon[teamPositionId]
            if not iconGrid then break end
            local className = TeamUtils:getClassIconNameByTeamId(teamId, "classlabel", teamTableData, true)
            local imageView = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
            imageView:setScale(0.75)
            imageView:setPosition(cc.p(iconGrid:getContentSize().width / 2, iconGrid:getContentSize().height / 2))
            iconGrid:addChild(imageView)
        until true
    end
end

function NewFormationView:updateWeaponDefInfo()
    print("NewFormationView:updateWeaponDefInfo")
end

function NewFormationView:updateWeaponInfo()
    print("NewFormationView:updateWeaponInfo")
    if not self:isShowWeaponInfo() then return end
    local label = self._layerLeft._cloudInfo._labelEvnDes
    local desc = "[color=3D1F00, fontsize=20]" .. "no info" .. "[-]"
    if self._formationType == self._formationModel.kFormationTypeWeapon then 
        desc = lang("PVE_JIANXUN_GONGCHENGZHAN")
    elseif self._formationType == self._formationModel.kFormationTypeWeaponDef then
        desc = lang("PVE_JIANXUN_SHOUCHENGZHAN")
    end
    local richText = label:getChildByName("descRichText" )
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, 230, 70)
    richText:setVerticalSpace(-4)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(label:getContentSize().width / 2, label:getContentSize().height / 2)
    richText:setName("descRichText")
    label:addChild(richText)
end

function NewFormationView:updateCrossPKLimitInfo()
    print("NewFormationView:updateCrossPKLimitInfo")
    if not self:isShowCrossPKLimitInfo() then return end
    local idToIndex = {
        [32] = 1,
        [33] = 2,
        [34] = 3,
        [105] = 1,
        [106] = 2,
        [107] = 3
    }
    local label = self._layerLeft._cloudInfo._labelEvnDes
    local limitData = self._extend.crosspkLimitInfo
    local limitId = idToIndex[self._formationType]
    local regiontype = limitData["regiontype" .. limitId] or 1
    local extratype = limitData["extra" .. limitId]
    local limitInfo = lang("cp_region" .. regiontype)
    if extratype and #extratype > 0 then
        for _, v in ipairs(extratype) do
            limitInfo = limitInfo .. "、" .. lang("cp_region" .. v)
        end
    end
    local desc = "[color=21f418,fontsize=18]提示：[-][color=ffffff,fontsize=18]可使用[-][color=21f418,fontsize=18]" .. limitInfo .. "[-][color=ffffff,fontsize=18]英雄及兵团[-]"
    local richText = label:getChildByName("descRichText" )
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, 230, 70)
    richText:setVerticalSpace(-2)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(label:getContentSize().width / 2, label:getContentSize().height / 2)
    richText:setName("descRichText")
    label:addChild(richText)
end

function NewFormationView:updatePveInfo()
    if not self:isShowPveInfo() then return end
    if self._extend.pveData then
        local pveData = self._extend.pveData
        local label = self._layerLeft._cloudInfo._labelEvnDes
        local desc = pveData.formationinf and lang(pveData.formationinf) or "[color=3D1F00, fontsize=20]" .. "no info" .. "[-]"
        local richText = label:getChildByName("descRichText" )
        if richText then
            richText:removeFromParentAndCleanup()
        end
        richText = RichTextFactory:create(desc, 230, 70)
        richText:setVerticalSpace(-4)
        richText:formatText()
        richText:enablePrinter(true)
        richText:setPosition(label:getContentSize().width / 2, label:getContentSize().height / 2)
        richText:setName("descRichText")
        label:addChild(richText)
    end
end

-- 更新宝物编组信息
function NewFormationView:updateTreasureInfo(relativeUpdate)
    if not self:isShowTreasureInfo() then return end
    local formationData = self._layerLeft._teamFormation._data[self._context._formationId]
    local tid = formationData.tid or 1 
    -- 刷新编组显示
    local tfModel = self._modelMgr:getModel("TformationModel")
    local tFormationData = tfModel:getTFormDataById(tid)
    if tFormationData then
        local tfName = tFormationData.name 
        if not tfName or tfName == "" then tfName = "宝物编组" .. tid end
        self._layerLeft._treasureInfo._name:setString(tfName or "宝物编组")
    end

    if relativeUpdate then
        self:updateRelative()
    end
end

function NewFormationView:updatePokedexInfo(relativeUpdate)
    local pFormation = self._pokedexModel:getPFormation()
    self._userModel = self._modelMgr:getModel("UserModel")
    local userData = self._userModel:getData()
    local pfId = userData.pfId or 1
    local pfLab = self:getUI("organizeBg.pfBtn.pfLab")
    local pName = pFormation[tostring(pfId)]
    if (not pName) or pName == "" then
        pName = "图鉴编组" .. pfId
    end
    self._layerLeft._pokedexInfo._name:setString(pName)

    if relativeUpdate then
        self:updateRelative()
    end
end

function NewFormationView:checkHeroSpecialtyEffect(t, k)
    for _, v in pairs(t) do
        if v[1] == k[1] and v[2] == k[2] then
            return true
        end
    end

    return false
end

function NewFormationView:getGlobalHeroSpecialtyEffect()
    local t = {}
    for k, v in pairs(self._specials) do
        if v.creplace3 then
            for _, v0 in ipairs(v.creplace3) do
                local heroId = v0[1]
                local star = v0[2]
                if self._heroModel:checkHero(tonumber(heroId)) then
                    local heroData = self._heroModel:getHeroData(tonumber(heroId))
                    if heroData.star >= star then
                        table.insert(t, {[1] = v0[3], [2] = v0[4], g = true})
                    end
                end
            end
        end
    end 
    return t
end

function NewFormationView:getHeroSpecialtyEffect(heroId)
    if 0 == heroId then return {} end
    local result = {}
    local t = {}
    local heroData = nil
    local heroTableData = nil
    local star = 0
    if self._formationType == self._formationModel.kFormationTypeLeague and self:isHeroCustom(heroId) then
        heroTableData = self._leagueModel:getMyHeroData(heroId)
        if not heroTableData then return {} end
        star = heroTableData.star or 0
    elseif self._formationType == self._formationModel.kFormationTypeHeroDuel and self:isHeroCustom(heroId) then
        heroTableData = tab:Hero(heroId)
        if not heroTableData then return {} end
        local heroDuelId = self._heroDuelModel:getWeekNum()
        local heroDuelTableData = tab:HeroDuel(heroDuelId)
        if not heroDuelTableData then return {} end
        star = heroDuelTableData.herostar or 0
    elseif self._formationType == self._formationModel.kFormationTypeCommon and self:isScenarioHero(heroId) then
        heroTableData = tab:NpcHero(heroId)
        if not heroTableData then return {} end
        star = heroTableData.herostar or 0
    else
        heroData = self._heroModel:getData()[tostring(heroId)]
        if not heroData then return {} end
        heroTableData = tab:Hero(heroId)
        if not heroTableData then return {} end
        star = heroData.star or 0
    end
    local special = heroTableData.special
    if not self._specials then
        self._specials = clone(tab.heroMastery)
        for k, v in pairs(self._specials) do
            if 1 ~= v.class then
                self._specials[k] = nil
            end
        end
    end

    local specialTableData = {}
    for k, v in pairs(self._specials) do
        if special == v.baseid then
            table.insert(specialTableData, v)
        end
    end

    table.sort(specialTableData, function(a, b)
        return a.masterylv < b.masterylv
    end)

    t = self:getGlobalHeroSpecialtyEffect()

    for k, v in ipairs(specialTableData) do
        if special == v.baseid then
            if star >= v.masterylv and v.creplace2 then
                for _, v0 in ipairs(v.creplace2) do
                    t[#t + 1] = v0
                end
            end
        end
    end

    local t1 = clone(t)
    t = {}
    for i=1, #t1 do
        repeat
            if t1[i][3] then break end
            local id = 0
            for j=i, #t1 do
                repeat
                    if t1[j][3] then break end
                    if t1[j][1] == t1[i][1] then
                        t1[j][3] = true
                        id = t1[j][2]
                    end
                until true
            end
            if 0 ~= id then
                t[#t + 1] = { [1] = t1[i][1], [2] = id }
            end
        until true
    end

    for i = 1, #t do
        if not self:checkHeroSpecialtyEffect(result, t[i]) then
            result[#result + 1] = t[i]
        end
    end

    return result
end

function NewFormationView:isTeamNeedChanged(teamId)
    local currentHeroId = self._layerLeft._teamFormation._data[self._context._formationId].heroId
    if 0 == currentHeroId then return false end
    local currentHeroSpecialEffect = self:getHeroSpecialtyEffect(currentHeroId)
    for _, v in ipairs(currentHeroSpecialEffect) do
        if teamId == v[1] then
            return true, v[2]
        end
    end 
    return false
end

function NewFormationView:getEnemyHeroSpecialtyEffect(heroId)
    if 0 == heroId then return {} end
    local result = {}
    local t = {}
    local heroData = nil
    local heroTableData = nil
    if self._formationType == self._formationModel.kFormationTypeCommon then
        heroData = clone(tab:NpcHero(heroId))
        if not heroData then print("invalid hero icon id", heroId) return {} end
        heroData.id = heroId
        heroData.star = heroData.herostar
        heroTableData = tab:NpcHero(heroData.id)
        if not heroTableData then return {} end
    elseif self._formationType == self._formationModel.kFormationTypeCrusade then
        heroData = self._crusadeModel:getEnemyHeroData()
        if not heroData then print("invalid hero icon id", heroId) return {} end
        heroData.id = heroId
        heroTableData = tab:Hero(heroData.id)
        if not heroTableData then return {} end
    end
    if not (heroData and heroTableData) then return {} end
    local star = heroData.star
    local special = heroTableData.special
    if not self._specials then
        self._specials = clone(tab.heroMastery)
        for k, v in pairs(self._specials) do
            if 1 ~= v.class then
                self._specials[k] = nil
            end
        end
    end

    local specialTableData = {}
    for k, v in pairs(self._specials) do
        if special == v.baseid then
            table.insert(specialTableData, v)
        end
    end

    table.sort(specialTableData, function(a, b)
        return a.masterylv < b.masterylv
    end)

    for k, v in ipairs(specialTableData) do
        if special == v.baseid then
            if star >= v.masterylv and v.creplace2 then
                for _, v0 in ipairs(v.creplace2) do
                    t[#t + 1] = v0
                end
            end
        end
    end

    local t1 = clone(t)
    t = {}
    for i=1, #t1 do
        repeat
            if t1[i][3] then break end
            local id = 0
            for j=i, #t1 do
                repeat
                    if t1[j][3] then break end
                    if t1[j][1] == t1[i][1] then
                        t1[j][3] = true
                        id = t1[j][2]
                    end
                until true
            end
            if 0 ~= id then
                t[#t + 1] = { [1] = t1[i][1], [2] = id }
            end
        until true
    end

    for i = 1, #t do
        if not self:checkHeroSpecialtyEffect(result, t[i]) then
            result[#result + 1] = t[i]
        end
    end

    return result
end

function NewFormationView:isEnemyTeamNeedChanged(teamId)
    if not self:isShowEnemyFormation() then return false end
    local currentHeroId = self._enemyFormationData[self._context._formationId].heroId
    if currentHeroId == NewFormationView.kNullHeroId then return false end
    local currentHeroSpecialEffect = self:getEnemyHeroSpecialtyEffect(currentHeroId)
    for _, v in ipairs(currentHeroSpecialEffect) do
        if teamId == v[1] then
            return true, v[2]
        end
    end 
    return false
end

function NewFormationView:dealWithEffect(iconGrid, iconView)
    local removeHeroSpecialtyEffectIf = function(t, pred)
        for k, v in pairs(t) do
            if pred(v) then
                t[k] = nil
            end
        end
    end

    local iconType = iconView:getIconType()
    local iconId = iconView:getIconId()
    local currentHeroId = self._layerLeft._teamFormation._data[self._context._formationId].heroId
    if iconType == NewFormationView.kGridTypeHero then
        local iconHeroGrid = self._layerLeft._heroFormation._grid
        local iconHeroView = iconHeroGrid:getIconView()
        if iconHeroView then
            currentHeroId = iconHeroView:getIconId()
        end
    end
    local lastHeroSpecialEffect = self:getHeroSpecialtyEffect(currentHeroId)
    if iconType == NewFormationView.kGridTypeTeam or iconType == NewFormationView.kGridTypeHireTeam then
        for _, v in ipairs(lastHeroSpecialEffect) do
            if iconId == v[1] then
                iconView:changeProfile(v[2])
                iconGrid:setIconView(iconView)
                self:showRelationEffect(false, iconView)
                iconGrid:onLoadedEx(true)
                self:clearRelationBuilds()
                return
            end
        end
    elseif iconType == NewFormationView.kGridTypeHero then
        -------------------------
        --local lastHeroSpecialEffect = {[1] = {104, 1104}, [2] = {105, 1105}, [3] = {106, 1106}}
        --local currentHeroSpecialEffect = {[1] = {104, 1105}, [2] = {105, 1105}, [3] = {107, 1108}}
        -------------------------
        local currentHeroSpecialEffect = self:getHeroSpecialtyEffect(iconId)
        local realLastSpecialEffect, realCurrentSpecialEffect = {}, {}
        for i = 1, #currentHeroSpecialEffect do
            if self:checkHeroSpecialtyEffect(lastHeroSpecialEffect, currentHeroSpecialEffect[i]) then
                removeHeroSpecialtyEffectIf(lastHeroSpecialEffect, function(v)
                    return ((v[1] == currentHeroSpecialEffect[i][1] and v[2] == currentHeroSpecialEffect[i][2]) or v.g)
                end)
            end
            realCurrentSpecialEffect[#realCurrentSpecialEffect + 1] = currentHeroSpecialEffect[i]
        end 

        removeHeroSpecialtyEffectIf(lastHeroSpecialEffect, function(v)
            for _, v0 in ipairs(realCurrentSpecialEffect) do
                if v[1] == v0[1] then
                    return true
                end
            end
            return false
        end)

        realLastSpecialEffect = table.values(lastHeroSpecialEffect)

        local hasSpecial = false
        for i = 1, NewFormationView.kTeamGridCount do
            local iconTeamGrid = self._layerLeft._teamFormation._grid[i]
            if iconTeamGrid:isStateFull() then
                local iconTeamView = iconTeamGrid:getIconView()
                local iconTeamId = iconTeamView:getIconId()
                for _, v in ipairs(realLastSpecialEffect) do
                    if iconTeamId == v[1] then
                        iconTeamView:resetProfile()
                        iconTeamGrid:onLoadedEx(false)
                    end
                end

                for _, v in ipairs(realCurrentSpecialEffect) do
                    if iconTeamId == v[1] and iconTeamView:getChangedId() ~= v[2] then
                        iconTeamView:changeProfile(v[2])
                        iconTeamGrid:onLoadedEx(true)
                        hasSpecial = true
                    end
                end 
            end
        end
        -- 英雄上阵 彩蛋音效
        if hasSpecial then
            local heroTableData = self:getTableData(NewFormationView.kGridTypeHero, iconId)
            if heroTableData.soundTrigger then
                if self._selectHeroSoundId then
                    audioMgr:stopSound(self._selectHeroSoundId)
                    self._selectHeroSoundId = nil
                end
                self._selectHeroSoundId = audioMgr:playSound(heroTableData.soundTrigger)
            end
        end

        -- 剧情英雄上阵特效
        if self:isScenarioHero(iconId) then
            self:showScenarioHeroEffect()
        end
    end

    iconGrid:setIconView(iconView)
    self:showRelationEffect(false, iconView)
    if self:hasRelationEffect(iconType, iconId) then
        iconGrid:onLoadedEx(true)
    else
        iconGrid:onLoaded()
    end
    self:clearRelationBuilds()
end

function NewFormationView:swapGridIcon(iconGrid1, iconView1, iconGrid2)
    --print("swap icon grid")
    -- swap data
    local data = self._layerLeft._teamFormation._data[self._context._formationId]
    local iconType = iconView1:getIconType()
    if iconType == NewFormationView.kGridTypeTeam or iconType == NewFormationView.kGridTypeHireTeam then
        local positionId1, positionId2 = iconGrid1:getGridIndex(), iconGrid2:getGridIndex()
        table.walk(data, function(v, k)
            if not string.find(tostring(k), "g") then return end
            if v == positionId1 then data[k] = positionId2
            elseif v == positionId2 then data[k] = positionId1
            end
        end)
    end

    self._layerLeft._teamFormation._data[self._context._formationId] = data

    -- swap ui
    iconGrid1:setIconView(iconGrid2:getIconView())
    iconGrid2:setIconView(iconView1)
    iconGrid2:onLoaded()

    if self:isNewFormationViewEx() then
        self:swapGridIconEx(iconGrid1, iconView1, iconGrid2)
    end
end

function NewFormationView:swapGridIconEx(iconGrid1, iconView1, iconGrid2)

end

function NewFormationView:moveGridIcon(iconGrid1, iconView1, iconGrid2)
    --print("move icon grid")
     -- move data
    local data = self._layerLeft._teamFormation._data[self._context._formationId]
    local iconType = iconView1:getIconType()
    if iconType == NewFormationView.kGridTypeTeam or iconType == NewFormationView.kGridTypeHireTeam then
        local positionId1, positionId2 = iconGrid1:getGridIndex(), iconGrid2:getGridIndex()
        table.walk(data, function(v, k)
            if not string.find(tostring(k), "g") then return end
            if v == positionId1 then data[k] = positionId2 end
        end)
    end
    self._layerLeft._teamFormation._data[self._context._formationId] = data

    -- move ui
    iconGrid2:setIconView(iconView1)
    iconGrid2:onLoaded()

    if self:isNewFormationViewEx() then
        self:moveGridIconEx(iconGrid1, iconView1, iconGrid2)
    end
end

function NewFormationView:moveGridIconEx(iconGrid1, iconView1, iconGrid2)
    
end

function NewFormationView:dealWithCloudFormationData(iconType, iconId)
    local formationId = self._formationModel.kFormationTypeCloud1 + self._formationModel.kFormationTypeCloud2 - self._context._formationId
    local data = self._layerLeft._teamFormation._data[formationId]
    if iconType == NewFormationView.kGridTypeTeam or iconType == NewFormationView.kGridTypeHireTeam then
        for k, v in pairs(data) do
            if string.find(tostring(k), "team") and not string.find(tostring(k), "g") and iconId == v then
                data[k] = 0
                data[string.format("g%d", tonumber(string.sub(tostring(k), -1)))] = 0
                break
            end
        end
    elseif data.heroId == iconId then
        data.heroId = 0
    end
end

function NewFormationView:loadGridIcon(iconGrid, iconView)
    --print("load icon grid")
    if not (iconGrid and iconView) then return end

    -- data
    local iconType = iconView:getIconType()
    local iconId = iconView:getIconId()
    local iconSubtype = iconView:getIconSubtype()

    local data = self._layerLeft._teamFormation._data[self._context._formationId]
    if iconType == NewFormationView.kGridTypeTeam or iconType == NewFormationView.kGridTypeHireTeam then
        local gridIndex = iconGrid:getGridIndex()
        local isGridFull = iconGrid:isStateFull()
        if isGridFull then
            local iconView1 = iconGrid:getIconView()
            if not iconView1 then return end
            local iconId1 = iconView1:getIconId()
            if self:isHireTeamLoaded() and iconId1 == self:getLoadedHireTeam() then
                self:setLoadedHireTeam()
            end
            for k, v in pairs(data) do
                if string.find(tostring(k), "team") and not string.find(tostring(k), "g") and v == iconId1 then
                    data[k] = iconId
                    data[string.format("g%d", tonumber(string.sub(tostring(k), -1)))] = gridIndex
                    break
                end
            end
        else
            for k, v in pairs(data) do
                if string.find(tostring(k), "team") and not string.find(tostring(k), "g") and 0 == v then
                    data[k] = iconId
                    data[string.format("g%d", tonumber(string.sub(tostring(k), -1)))] = gridIndex
                    break
                end
            end
        end
    elseif iconType == NewFormationView.kGridTypeHero then
        data.heroId = iconId
    elseif iconType == NewFormationView.kGridTypeIns then
        local gridIndex = iconGrid:getGridIndex()
        if gridIndex >= 1 and gridIndex <= 3 then
            data["weapon" .. gridIndex] = iconId
        end
    end

    if self:isShowCloudInfo() then
        self:dealWithCloudFormationData(iconType, iconId)
    end

    if self:isShowHireTeam() and iconType == NewFormationView.kGridTypeHireTeam and self:isHireTeam(iconId) then
        self:setLoadedHireTeam(iconId, iconView:getIconSubtype())
    end

    -- ui
    if iconType == NewFormationView.kGridTypeTeam or iconType == NewFormationView.kGridTypeHireTeam then
        local teamTableData = self:getTableData(iconType, iconId)
        local hasSurprise = false
        if teamTableData.enemy and teamTableData.soundEnemy then
            -- 兵团上阵 死敌音效
            local hasEnemy = false
            for k, v in pairs(data) do
                if string.find(tostring(k), "team") and not string.find(tostring(k), "g") and v == teamTableData.enemy then
                    hasSurprise = true
                    break
                end
            end
        end
        if hasSurprise then
            if self._selectTeamSoundId then
                audioMgr:stopSound(self._selectTeamSoundId)
                self._selectTeamSoundId = nil
            end
            self._selectTeamSoundId = audioMgr:playSound(teamTableData.soundEnemy)
        elseif teamTableData.soundtrigger then
            -- 兵团上阵 彩蛋音效
            local hasCompanion = false
            local heroData = self._heroModel:getHeroData(data.heroId)
            if heroData then
                if not teamTableData.zuhe or (heroData.id == teamTableData.zuhe[1] and heroData.star >= teamTableData.zuhe[2]) then
                    hasCompanion = true
                end
            end
            if hasCompanion then
                if self._selectTeamSoundId then
                    audioMgr:stopSound(self._selectTeamSoundId)
                    self._selectTeamSoundId = nil
                end
                self._selectTeamSoundId = audioMgr:playSound(teamTableData.soundtrigger)
            end
        end
    elseif iconType == NewFormationView.kGridTypeHero then
        -- 英雄上阵 普通音效
        local heroTableData = self:getTableData(NewFormationView.kGridTypeHero, iconId)
        if heroTableData.soundUpload then
            if self._selectHeroSoundId then
                audioMgr:stopSound(self._selectHeroSoundId)
                self._selectHeroSoundId = nil
            end
            self._selectHeroSoundId = audioMgr:playSound(heroTableData.soundUpload .. "_0" .. GRandom(4))
        end
    end

    self:dealWithEffect(iconGrid, iconView)

    if self:isNewFormationViewEx() then
        self:loadGridIconEx(iconGrid, iconView)
    end
end

function NewFormationView:loadGridIconEx(iconGrid, iconView)

end

function NewFormationView:isTeamCanUnload(iconType, iconId)
    if (iconType == NewFormationView.kGridTypeTeam or iconType == NewFormationView.kGridTypeHireTeam) and self:getCurrentLoadedTeamCount() <= 1 and not self:isShowCloudInfo() then
        return false
    end
    return true
end

function NewFormationView:unloadGridIcon(iconGrid, iconView)
    --print("unload icon grid")
    if not (iconGrid and iconView) then return end

    local iconType = iconView:getIconType()
    local iconId = iconView:getIconId()

    if not self:isTeamCanUnload(iconType, iconId) then
        self._viewMgr:showTip(lang("TIP_BUZHEN_1"))
        iconGrid:setIconView(iconView)
        return false
    end

    -- data
    local data = self._layerLeft._teamFormation._data[self._context._formationId]
    if iconType == NewFormationView.kGridTypeTeam or iconType == NewFormationView.kGridTypeHireTeam then
        for k, v in pairs(data) do
            if string.find(tostring(k), "team") and not string.find(tostring(k), "g") and v == iconId then
                data[k] = 0
                data[string.format("g%d", tonumber(string.sub(tostring(k), -1)))] = 0
                break
            end 
        end
    elseif iconType == NewFormationView.kGridTypeIns then
        local gridIndex = iconGrid:getGridIndex()
        if gridIndex >= 1 and gridIndex <= 3 then
            data["weapon" .. gridIndex] = 0
        end
    end

    if self:isShowHireTeam() and iconType == NewFormationView.kGridTypeHireTeam and self:isHireTeam(iconId) then
        self:setLoadedHireTeam()
    end

    -- ui
    audioMgr:playSound("Download")
    iconView:removeFromParentAndCleanup()

    self._layerLeft._unloadMC:setPosition(self._layerLeft._ePosition)
    self._layerLeft._unloadMC:setVisible(true)
    self._layerLeft._unloadMC:gotoAndPlay(0)

    if self:isNewFormationViewEx() then
        self:unloadGridIconEx(iconGrid, iconView)
    end
    
    return true
end

function NewFormationView:unloadGridIconEx(iconGrid, iconView)

end

function NewFormationView:onUnloadAllButtonClicked()
    if not self:isShowCloudInfo() then return end
    if 0 == self:getCurrentLoadedTeamCount() and self:isLoadedHeroNull() then return end
    audioMgr:playSound("Download")
    local formationData = self._layerLeft._teamFormation._data[self._context._formationId]
    for i=1, NewFormationView.kTeamMaxCount do
        formationData["team" .. i] = 0
        formationData["g" .. i] = 0
    end
    if 0 ~= formationData["heroId"] then
        formationData["heroId"] = 0
    end
    self:updateUI()
end

function NewFormationView:isLoaded(iconType, iconId, outIconView, teamSubtype)
    local found = false
    local position = 0
    local data = self._layerLeft._teamFormation._data[self._context._formationId]
    if not data then
        -- ApiUtils.playcrab_lua_error("invalid formation data:" .. tostring(self._context._formationId), serialize(self._modelMgr:getModel("FormationModel"):getFormationData()), "formation")
        -- self._viewMgr:onLuaError("invalid formation data:" .. tostring(self._context._formationId) .. serialize(self._modelMgr:getModel("FormationModel"):getFormationData()))
        return false
    end
    if iconType == NewFormationView.kGridTypeTeam then
        local hireTeamId = 0
        if self:isHireTeamLoaded() then
            hireTeamId = self:getLoadedHireTeam()
        end
        for k, v in pairs(data) do
            if string.find(tostring(k), "team") and not string.find(tostring(k), "g") and v == iconId and v ~= hireTeamId then
                position = tonumber(data[string.format("g%d", tonumber(string.sub(tostring(k), -1)))])
                found = true
                break
            end 
        end
    elseif iconType == NewFormationView.kGridTypeHireTeam then
        if self:isHireTeamLoaded() then
            local hireTeamId, hireTeamUserId = self:getLoadedHireTeam()
            if hireTeamId == iconId and hireTeamUserId == teamSubtype then
                found = true
            end
        end
    elseif iconType == NewFormationView.kGridTypeHero then
        if data["heroId"] and data["heroId"] == iconId then
            found = true
        end
    elseif iconType == NewFormationView.kGridTypeIns then
        for i=1, NewFormationView.kInsMaxCount do
            local insId = data["weapon" .. i]
            if insId and insId ~= 0 and insId == iconId then
                position = i
                found = true
            end
        end
    end

    if outIconView and found then
        local iconGrid = nil
        local iconView = nil
        if iconType == NewFormationView.kGridTypeTeam or iconType == NewFormationView.kGridTypeHireTeam then
            iconGrid = self._layerLeft._teamFormation._grid[position]
        elseif iconType == NewFormationView.kGridTypeHero then
            iconGrid = self._layerLeft._heroFormation._grid
        elseif iconType == NewFormationView.kGridTypeIns then
            iconGrid = self._layerLeft._insFormation._grid[position]            
        end
        if iconGrid then
            iconView = iconGrid:getIconView()
        end
        if iconView then
            return found, iconView
        end
    end

    return found
end

function NewFormationView:isHaveCurrentTeam(teamId)
    local data = self._layerLeft._teamFormation._data[self._context._formationId]
    for i=1, NewFormationView.kTeamMaxCount do
        local currentTeamId = data["team" .. i]
        if currentTeamId and 0 ~= currentTeamId and teamId == currentTeamId then
            return true
        end
    end

    return false
end

function NewFormationView:isTeamLoadedFull(formationId, realLoaded)
    formationId = tonumber(formationId) or tonumber(self._context._formationId)
    if formationId == self._formationModel.kFormationTypeAiRenMuWu or 
       formationId == self._formationModel.kFormationTypeZombie then
       local count = 0
       for _, v in ipairs(self._layerLeft._layerList._teamData) do
           if not self:isFiltered(v.id) then
               count = count + 1
           end
       end
       return self:getCurrentLoadedTeamCount(formationId) >= self._layerLeft._teamFormation._allowLoadCount.currentTeamCount or count <= 0
    end
    return self:getCurrentLoadedTeamCount(formationId) >= self._layerLeft._teamFormation._allowLoadCount.currentTeamCount
end

function NewFormationView:isLeftGridWall(gridIndex)
    if self._formationType ~= self._formationModel.kFormationTypeCrusade and
        self._formationType ~= self._formationModel.kFormationTypeCloud1 and 
        self._formationType ~= self._formationModel.kFormationTypeCloud2 and 
        self._formationType ~= self._formationModel.kFormationTypeTraining and
        self._formationType ~= self._formationModel.kFormationTypeWeaponDef then
        return false
    end

    if self._formationType == self._formationModel.kFormationTypeWeaponDef then
       local wallIndex = {3, 4, 7, 8, 11, 12, 15, 16}
       for _, v in ipairs(wallIndex) do
           if v == gridIndex then 
               return true 
           end
       end
       return false
    end

    if not (self._wall and self._wall[self._context._formationId]) then return false end

    local wallIndex = self._wall[self._context._formationId]
    for _, v in ipairs(wallIndex) do
        if v == gridIndex then 
            return true 
        end
    end
    return false
end

function NewFormationView:isRightGridWall(gridIndex)
    if not (self._enemyFormationData and type(self._enemyFormationData) == "table" and self._enemyFormationData[self._context._formationId]) then return false end
    if not self._enemyFormationData[self._context._formationId].siegeid then return false end
    local wallIndex = {3, 4, 7, 8, 11, 12, 15, 16}
    for _, v in ipairs(wallIndex) do
        if v == gridIndex then 
            return true 
        end
    end
    return false
end

function NewFormationView:isPositionValid(gridIndex, classPosition)
    for _, v in ipairs(classPosition) do
        if v == gridIndex then
            return true
        end
    end
    return false
end

function NewFormationView:isPositionLocked(gridIndex)
    local iconGrid = self._layerLeft._teamFormation._grid[gridIndex]
    if iconGrid and iconGrid:isStateFull() then
        local iconView = iconGrid:getIconView()
        if iconView then
            return iconView:isShowLocked()
        end
    end
    return false
end

function NewFormationView:isSortFront( iconId )
    if not self._extend then return false end
    local frontList = self._extend.sortFront or {}
    for k, v in pairs(frontList) do
        if v == iconId then
            return true
        end
    end
    return false
end

function NewFormationView:isFiltered(iconId)
    if 0 == iconId then return false end

    local found = false
    local data = self._layerLeft._teamFormation._data[self._context._formationId]
    if data and data.filter then
        for k, v in pairs(data.filter) do
            if v == iconId then
                found = true
                break
            end
        end
    end
    --[[
    if self._filter then
        for k, v in pairs(self._filter) do
            if v == iconId then
                found = true
                break
            end
        end
    end
    ]]

    if self._formationType == self._formationModel.kFormationTypeAiRenMuWu then
        local teamData = tab:Team(iconId)
        if teamData and 1 ~= teamData.atktype then
            return true
        end
    elseif self._formationType == self._formationModel.kFormationTypeZombie then
        local teamData = tab:Team(iconId)
        if teamData and 2 ~= teamData.atktype then
            return true
        end
    elseif self._formationType == self._formationModel.kFormationTypeCrossPKAtk1 or 
           self._formationType == self._formationModel.kFormationTypeCrossPKAtk2 or 
           self._formationType == self._formationModel.kFormationTypeCrossPKAtk3 or 
           self._formationType == self._formationModel.kFormationTypeCrossPKDef1 or 
           self._formationType == self._formationModel.kFormationTypeCrossPKDef2 or 
           self._formationType == self._formationModel.kFormationTypeCrossPKDef3 then
        if not (self._extend and self._extend.allowLoadIds) then return false end
        for _, id in ipairs(self._extend.allowLoadIds) do
            if id == iconId then
                return false
            end
        end
        return true
    end

    return found
end

function NewFormationView:isHireTeamLevelLimit(teamData)
    if not self:isShowHireTeam() then return false end
    if not (teamData and teamData["level"]) then return false end
    local userLevel = self._modelMgr:getModel("UserModel"):getPlayerLevel()
    local limitLevel = self._layerLeft._layerList._hireTeamLimitLevel
    return teamData["level"] - userLevel > limitLevel
end

function NewFormationView:isHireTeamCanUsed(teamData)
    if not self:isShowHireTeam() then return false end
    if not (teamData and teamData["times"]) then return false end
    return teamData["times"] > 0
end

function NewFormationView:isHireTeamLoaded(formationId)
    formationId = formationId or self._context._formationId
    return self._layerLeft._layerList._loadedHireTeam[formationId] and 0 ~= self._layerLeft._layerList._loadedHireTeam[formationId]._teamId
end

function NewFormationView:setLoadedHireTeam(teamId, teamSubtype, formationId)
    formationId = formationId or self._context._formationId
    if not self._layerLeft._layerList._loadedHireTeam[formationId] then
        self._layerLeft._layerList._loadedHireTeam[formationId] = {}
    end
    self._layerLeft._layerList._loadedHireTeam[formationId]._teamId = teamId and teamId or 0
    self._layerLeft._layerList._loadedHireTeam[formationId]._teamSubtype = teamSubtype and teamSubtype or 0
end

function NewFormationView:getLoadedHireTeam(formationId)
    formationId = formationId or self._context._formationId
    if not (self._layerLeft._layerList._loadedHireTeam[formationId] and 
        self._layerLeft._layerList._loadedHireTeam[formationId]._teamId and 
        self._layerLeft._layerList._loadedHireTeam[formationId]._teamSubtype) then
        return 0, 0
    end
    return self._layerLeft._layerList._loadedHireTeam[formationId]._teamId, self._layerLeft._layerList._loadedHireTeam[formationId]._teamSubtype
end

function NewFormationView:hireTeamLoadedPosition()
    if not self:isHireTeamLoaded() then return 0 end
    local hireTeamId = self:getLoadedHireTeam()
    local formationData = self._layerLeft._teamFormation._data[self._context._formationId]
    if not formationData then return 0 end
    for i=1, NewFormationView.kTeamMaxCount do
        local teamId = tonumber(formationData["team" .. i])
        if teamId and 0 ~= teamId and hireTeamId == teamId then
            return formationData["g" .. i]
        end
    end

    return 0
end

function NewFormationView:isHireTeam(teamId)
    if not self:isShowHireTeam() then return false end
    if not self._layerLeft._teamFormation._initFormation then return false end
    if not self._extend.hireTeamsInit then
        for _, id in ipairs(self._extend.hireTeams) do
            if id == teamId then
                return true
            end
        end
    else
        for _, v in pairs(self._extend.hireTeams) do
            if v.teamId == teamId then
                return true
            end
        end
    end

    return false
end

function NewFormationView:getUsingHireTeamData( formationId )
    if not self:isShowHireTeam() then return false end
    if not self._layerLeft._teamFormation._initFormation then return false end
    formationId = formationId or self._context._formationId
    local teamId, _ = self:getLoadedHireTeam(formationId)
    if teamId == 0 then
        return nil
    end
    if self._extend.hireTeamsInit then
        for _, v in pairs(self._extend.hireTeams) do
            if v.teamId == teamId then
                return clone(v)
            end
        end
    end
    return nil
end

function NewFormationView:isShowBackupTag( iconId, iconType )
    if not table.indexof(self._formationModel.kBackupFormation, self._formationType) then
        return false
    end
    if iconType ~= NewFormationView.kGridTypeTeam then return false end
    local data = self._layerLeft._teamFormation._data[self._context._formationId]
    local bid = data.bid
    local backupTs = data.backupTs or {}
    if bid == nil then
        return false
    end
    local backupData = backupTs[tostring(bid)]
    if backupData == nil then return false end
    for i = 1, 3 do
        local teamId = backupData["bt" .. i]
        if teamId and teamId ~= 0 and teamId == iconId then
            return true
        end
    end
    return false
end

function NewFormationView:isRecommend(iconId)
    if not (self._formationType == self._formationModel.kFormationTypeAiRenMuWu or 
        self._formationType == self._formationModel.kFormationTypeZombie or 
        self._formationType == self._formationModel.kFormationTypeDragon or
        self._formationType == self._formationModel.kFormationTypeDragon1 or
        self._formationType == self._formationModel.kFormationTypeDragon2 or 
        self._formationType == self._formationModel.kFormationTypeLeague or
        self._formationType == self._formationModel.kFormationTypeElemental1 or
        self._formationType == self._formationModel.kFormationTypeElemental2 or
        self._formationType == self._formationModel.kFormationTypeElemental3 or
        self._formationType == self._formationModel.kFormationTypeElemental4 or
        self._formationType == self._formationModel.kFormationTypeElemental5 or
        self._formationType == self._formationModel.kFormationTypeWeapon or
        self._formationType == self._formationModel.kFormationTypeStakeAtk1 or
        self._formationType == self._formationModel.kFormationTypeWeaponDef or 
        self._formationType == self._formationModel.kFormationTypeProfession1 or 
        self._formationType == self._formationModel.kFormationTypeProfession2 or 
        self._formationType == self._formationModel.kFormationTypeProfession3 or 
        self._formationType == self._formationModel.kFormationTypeProfession4 or 
        self._formationType == self._formationModel.kFormationTypeProfession5 or 
        self._formationType == self._formationModel.kFormationTypeWorldBoss) then
        return false
    end

    if self._formationType == self._formationModel.kFormationTypeAiRenMuWu then
        local pveTableData = tab:PveSetting(901)
        if not (pveTableData.recommend and type(pveTableData.recommend) == "table") then return false end
        for i = 1, #pveTableData.recommend do
            if pveTableData.recommend[i] == iconId then
                return true
            end
        end
    elseif self._formationType == self._formationModel.kFormationTypeZombie then
        local pveTableData = tab:PveSetting(902)
        if not (pveTableData.recommend and type(pveTableData.recommend) == "table") then return false end
        for i = 1, #pveTableData.recommend do
            if pveTableData.recommend[i] == iconId then
                return true
            end
        end
    elseif self._formationType == self._formationModel.kFormationTypeDragon or 
           self._formationType == self._formationModel.kFormationTypeDragon1 or
           self._formationType == self._formationModel.kFormationTypeDragon2 then
        local pveTableData = tab:PveSetting(self._subType)
        if not (pveTableData.recommend and type(pveTableData.recommend) == "table") then return false end
        for i = 1, #pveTableData.recommend do
            if pveTableData.recommend[i] == iconId then
                return true
            end
        end
    elseif self._formationType == self._formationModel.kFormationTypeLeague or
           self._formationType == self._formationModel.kFormationTypeElemental1 or
           self._formationType == self._formationModel.kFormationTypeElemental2 or
           self._formationType == self._formationModel.kFormationTypeElemental3 or
           self._formationType == self._formationModel.kFormationTypeElemental4 or
           self._formationType == self._formationModel.kFormationTypeElemental5 or
           self._formationType == self._formationModel.kFormationTypeWeapon or
           self._formationType == self._formationModel.kFormationTypeWeaponDef then
        for _, v in ipairs(self._recommend) do
            if v == iconId then
                return true
            end
        end
    elseif self._formationType == self._formationModel.kFormationTypeStakeAtk1 then
        for _, v in ipairs(self._recommend) do
            if tonumber(v) == tonumber(iconId) then
                return true
            end
        end
    elseif self._formationType == self._formationModel.kFormationTypeWorldBoss or 
            self._formationType == self._formationModel.kFormationTypeProfession1 or 
            self._formationType == self._formationModel.kFormationTypeProfession2 or 
            self._formationType == self._formationModel.kFormationTypeProfession3 or 
            self._formationType == self._formationModel.kFormationTypeProfession4 or 
            self._formationType == self._formationModel.kFormationTypeProfession5 then
        for _, v in pairs(self._recommend) do
            if tonumber(v) == tonumber(iconId) then
                return true
            end
        end
    else
        return false
    end

    return false
end

function NewFormationView:isTeamCustom(teamId)
    if not (self._extend and self._extend.teams) then return false end
    for k, v in pairs(self._extend.teams) do
        if teamId == k then
            return true
        end
    end
    return false
    --[[
    for _, v in ipairs(self._layerLeft._layerList._teamData) do
        if teamId == v.id then
            return v.custom
        end
    end
    return false
    ]]
end

function NewFormationView:isHeroCustom(heroId)
    if not (self._extend and self._extend.heroes) then return false end
    for k, v in pairs(self._extend.heroes) do
        if heroId == k then
            return true
        end
    end
    return false
    --[[
    for _, v in ipairs(self._layerLeft._layerList._heroData) do
        if heroId == v.id then
            return v.custom
        end
    end
    return false
    ]]
end

function NewFormationView:isTeamLocal(teamId)
    return false
end

function NewFormationView:isHeroLocal(heroId)
    return false
end

function NewFormationView:getTableData(iconType, iconId)
    local tableData = nil
    if iconType == NewFormationView.kGridTypeTeam then
        if self:isTeamCustom(iconId) then
            tableData = tab:Npc(iconId)
        else
            tableData = tab:Team(iconId)
        end
    elseif iconType == NewFormationView.kGridTypeHero then
        if self:isHeroCustom(iconId) then
            tableData = tab:NpcHero(iconId)
        else
            tableData = tab:Hero(iconId)
        end
    elseif iconType == NewFormationView.kGridTypeHireTeam then
        tableData = tab:Team(iconId)
    elseif iconType == NewFormationView.kGridTypeIns then
        tableData = tab:SiegeWeapon(iconId)
    end
    return tableData
end

function NewFormationView:getCurrentTeamFilterCount(formationId)
    formationId = tonumber(formationId) or tonumber(self._context._formationId)
    local data = self._layerLeft._teamFormation._data[formationId]
    if data.filter then
        return table.getn(data.filter)
    end
    return 0
end

function NewFormationView:isEnemyFiltered(iconId)
    if not (self._enemyFormationData and type(self._enemyFormationData) == "table" and self._enemyFormationData[self._context._formationId]) then return false end
    local found = false
    local data = self._enemyFormationData[self._context._formationId]
    if data.filter then
        for k, v in pairs(data.filter) do
            if v == iconId then
                found = true
                break
            end
        end
    end
    return found
end

function NewFormationView:isEnemyHexin(iconId)
    if self._formationType ~= self._formationModel.kFormationTypeCommon then
        return false
    end
    local teamTableData = tab:Npc(iconId)
    return teamTableData and teamTableData.hx and 1 == teamTableData.hx
end

function NewFormationView:getCurrentLoadedTeamCount(formationId)
    formationId = tonumber(formationId) or tonumber(self._context._formationId)
    local data = self._layerLeft._teamFormation._data[formationId]
    local team_count = 0
    table.walk(data, function(v, k)
        if 0 == v then return end
        if string.find(tostring(k), "team") and not string.find(tostring(k), "g") then
            team_count = team_count + 1
        end
    end)
    return team_count
end

function NewFormationView:getCurrentLoadedTeamCountWithFilter(formationId)
    formationId = tonumber(formationId) or tonumber(self._context._formationId)
    local data = self._layerLeft._teamFormation._data[formationId]
    local team_count = 0
    local hireTeamId = 0
    if self:isHireTeamLoaded() then
        hireTeamId = self:getLoadedHireTeam()
    end
    table.walk(data, function(v, k)
        if 0 == v or (self:isFiltered(v) and v ~= hireTeamId) then return end
        if string.find(tostring(k), "team") and not string.find(tostring(k), "g") then
            team_count = team_count + 1
        end
    end)
    return team_count
end

function NewFormationView:isCloudCurrentLoadedTeamEmpty()
    --[[
    if self:isSwitchFormationButtonDisabled() then
        return self:getCurrentLoadedTeamCountWithFilter()
    end
    local formationId1 = self._context._formationId
    local formationId2 = self._formationModel.kFormationTypeCloud1 + self._formationModel.kFormationTypeCloud2 - formationId1
    if self._extend.enterBattle and self._extend.enterBattle[formationId1] and not self._extend.enterBattle[formationId2] then
        return self:getCurrentLoadedTeamCountWithFilter(formationId2)
    end
    ]]
    local formationId1 = self._formationModel.kFormationTypeCloud1
    local formationId2 = self._formationModel.kFormationTypeCloud2
    local count1 = self:getCurrentLoadedTeamCountWithFilter(formationId1)
    if 0 == count1 and self._extend.allowBattle and self._extend.allowBattle[formationId1] then
        return true
    end

    local count2 = self:getCurrentLoadedTeamCountWithFilter(formationId2)
    if 0 == count2 and self._extend.allowBattle and self._extend.allowBattle[formationId2] then
        return true
    end

    return false
end

function NewFormationView:isStakeCurrentLoadedTeamEmpty(  )
    local formationId1 = self._formationModel.kFormationTypeStakeAtk2
    local formationId2 = self._formationModel.kFormationTypeStakeDef2
    local count1 = self:getCurrentLoadedTeamCountWithFilter(formationId1)
    local count2 = self:getCurrentLoadedTeamCountWithFilter(formationId2)
    return count1 > 0 and count2 > 0
end

function NewFormationView:isLoadedHeroNull(formationId)
    formationId = tonumber(formationId) or tonumber(self._context._formationId)
    local data = self._layerLeft._teamFormation._data[formationId]
    return 0 == data.heroId
end

function NewFormationView:isCloudLoadedHeroNull(formationId)
    local formationId1 = self._formationModel.kFormationTypeCloud1
    local formationId2 = self._formationModel.kFormationTypeCloud2
    local formationData1 = self._layerLeft._teamFormation._data[formationId1]
    if 0 == formationData1.heroId and self._extend.allowBattle and self._extend.allowBattle[formationId1] then
        return true
    end

    local formationData2 = self._layerLeft._teamFormation._data[formationId2]
    if 0 == formationData2.heroId and self._extend.allowBattle and self._extend.allowBattle[formationId2] then
        return true
    end

    return false
end

function NewFormationView:isStakeLoadedHeroNull(     )
    local formationId1 = self._formationModel.kFormationTypeStakeAtk2
    local formationId2 = self._formationModel.kFormationTypeStakeDef2
    local formationData1 = self._layerLeft._teamFormation._data[formationId1]
    local heroId1 = formationData1.heroId
    local formationData2 = self._layerLeft._teamFormation._data[formationId2]
    local heroId2 = formationData2.heroId

    return heroId1 and heroId1 ~= 0 and heroId2 and heroId2 ~= 0
end

function NewFormationView:getCurrentAllowLoadCount()
    local userLevel = self._modelMgr:getModel("UserModel"):getData().lvl
    local userLevelInfo = tab.userLevel
    local currentTeamCount = self._modelMgr:getModel("UserModel"):getData().formationTeamNum
    if (self:isShowButtonTraining() or self:isShowCloudInfo()) and self._extend.count and self._extend.count[self._context._formationId] then
        currentTeamCount = tonumber(self._extend.count[self._context._formationId])
    end
    local nextTeamCountUnlockLevel = userLevelInfo[userLevel].nextlevel
    local nextTeamCount = 0 == nextTeamCountUnlockLevel and 0 or userLevelInfo[nextTeamCountUnlockLevel].num
    return { currentTeamCount = currentTeamCount, nextTeamCount = nextTeamCount, maxTeamCount = NewFormationView.kTeamMaxCount, nextTeamCountUnlockLevel = nextTeamCountUnlockLevel, currentInstrumentCount = 0, nextInstrumentCount = 0, maxInstrumentCount = self.kInsMaxCount, nextInstrumentCountUnlockLevel = 0, }
end

function NewFormationView:getCurrentAllowLoadTeamCount()
    return self._layerLeft._teamFormation._allowLoadCount.currentTeamCount
end

function NewFormationView:getCurrentFightScore(formationId)
    formationId = tonumber(formationId) or tonumber(self._context._formationId)
    local data = self._layerLeft._teamFormation._data[formationId]
    local hireTeamId, hireTeamType = self:getLoadedHireTeam()
    return self._formationModel:getCurrentFightScoreByType(formationId, data, self:isHireTeamLoaded(), hireTeamId, hireTeamType, self:isHaveFixedWeapon())
end

function NewFormationView:getCurrentIconData()
    local gridType = self._context._gridType[self._context._formationId]
    if NewFormationView.kGridTypeHero == gridType then
        return self._layerLeft._layerList._heroData
    elseif NewFormationView.kGridTypeHireTeam == gridType then
        return self._layerLeft._layerList._hireTeamData
    elseif NewFormationView.kGridTypeTeam == gridType then
        return self._layerLeft._layerList._teamData
    elseif NewFormationView.kGridTypeIns == gridType then
        return self._layerLeft._layerList._insData
    end
end

function NewFormationView:getIcontCount()
    if NewFormationView.kGridTypeHero == self._context._gridType[self._context._formationId] then
        return 9 -- 10
    else
        return 10 -- 11
    end
end

function NewFormationView:initFormationData()
    self._layerLeft._teamFormation._data = clone(self._formationModel:getFormationData())
    if self:isHaveFixedHero() then
        self:dealWithFixedHero()
    elseif self:isHaveDefaultHero() then
        self:dealWithDefaultHero()
    end

    if self:isHaveFixedWeapon() then
        self:dealWithFixedWeapon()
    end
end

function NewFormationView:isTeamTypeFiltered(teamData, isUserData)
    if 100 == self._layerLeft._layerList._filterType then return false end
    if not (teamData and teamData["race"] and teamData["race"][1]) then
        teamData["race"] = { true }
    end
    local race = teamData["race"][1]
    --[[if isUserData then
        local teamTableData = tab:Team(teamData["teamId"])
        race = teamTableData["race"][1]
    else
        race = teamData["race"][1]
    end]]
    if race ~= self._layerLeft._layerList._filterType then 
        return true
    end
    return false
end

function NewFormationView:isHeroTypeFiltered( heroData )
    if 0 == self._layerLeft._layerList._filterHeroType then return false end
    local heroId = heroData.id or heroData.heroId
    local heroTableData = tab:Hero(heroId)
    if heroTableData and heroTableData.masterytype then
        if heroTableData.masterytype ~= self._layerLeft._layerList._filterHeroType then
            return true
        end
    end
    return false
end

function NewFormationView:initCustomTeamData()
    if not (self._extend and self._extend.teams) then return end
    local t = {}
    for _, id in ipairs(self._extend.teams) do
        repeat
            local data = clone(tab:Npc(id))
            if not data then break end
            data.teamId = data.id
            data.custom = true
            data.id = nil
            t[data.teamId] = data
        until true
    end
    self._extend.teams = t
end

function NewFormationView:initCustomHeroData()
    if not (self._extend and self._extend.heroes) then return end
    local t = {}
    for _, id in ipairs(self._extend.heroes) do
        repeat
            local data = clone(tab:NpcHero(id))
            if not data then break end
            data.heroId = data.id
            data.custom = true
            data.id = nil
            t[data.heroId] = data
        until true
    end
    self._extend.heroes = t
end

function NewFormationView:initTeamListData()
    self._layerLeft._layerList._teamData = {}
    local data = {}
    if self._formationType == self._formationModel.kFormationTypeTraining and self._extend and self._extend.teams then
        if not self._extend.teamsInit then
            self:initCustomTeamData()
            self._extend.teamsInit = true
        end
        data = clone(self._extend.teams)
    else
        data = clone(self._teamModel:getData())
        for k, v in pairs(data) do
            v["race"] = tab:Team(v.teamId).race
        end
    end

    if not self._layerLeft._layerList._allTeamsInit then
        self._layerLeft._layerList._allTeamsData = clone(data)
        self._layerLeft._layerList._allTeamsInit = true
    end

    local t1, t2 = {}, {}
    for k, v in pairs(data) do
        repeat
            if self:isTeamTypeFiltered(v) then break end
            if self:isLoaded(NewFormationView.kGridTypeTeam, v.teamId) then break end
            if not self:isFiltered(v.teamId) then
                v.id = v.teamId
                v.teamId = nil
                table.insert(t1, v)
            else
                v.id = v.teamId
                v.teamId = nil
                table.insert(t2, v)
            end
        until true
    end

    table.sort(t1, function(a, b)
        return a.score > b.score
    end)

    table.sort(t2, function(a, b)
        return a.score > b.score
    end)

    for i = 1, #t1 do
        self._layerLeft._layerList._teamData[#self._layerLeft._layerList._teamData + 1] = t1[i]
    end

    for i = 1, #t2 do
        self._layerLeft._layerList._teamData[#self._layerLeft._layerList._teamData + 1] = t2[i]
    end
end

function NewFormationView:initHeroListData()
    self._layerLeft._layerList._heroData = {}
    local data = {}
    if self._extend and self._extend.heroes then
        if not self._extend.heroesInit then
            self:initCustomHeroData()
            self._extend.heroesInit = true
        end
        if self._formationType == self._formationModel.kFormationTypeCommon then
            data = clone(self._heroModel:getData())
            table.merge(data, self._extend.heroes)
        elseif self._formationType == self._formationModel.kFormationTypeTraining then
            data = clone(self._extend.heroes)
        else
            data = clone(self._heroModel:getData())
        end
    else
        data = clone(self._heroModel:getData())
    end

    if not self._layerLeft._layerList._allHeroInit then
        self._layerLeft._layerList._allHerosData = clone(data)
        self._layerLeft._layerList._allHeroInit = true
    end

    local t1, t2, t3 = {}, {}, {}
    for k, v in pairs(data) do
        repeat
            if self:isHeroTypeFiltered(v) then break end
            if self:isLoaded(NewFormationView.kGridTypeHero, tonumber(k)) then break end
            if self:isSortFront(tonumber(k)) then 
                v.id = tonumber(k)
                table.insert(t3, v)
            elseif not self:isFiltered(tonumber(k)) then
                v.id = tonumber(k)
                table.insert(t1, v)
            else
                v.id = tonumber(k)
                table.insert(t2, v)
            end
        until true
    end

    table.sort(t1, function(a, b)
        if self._scenarioHero then
            if self._scenarioHero == a.id then
                return true
            elseif self._scenarioHero == b.id then
                return false
            end
        end
        return a.score > b.score
    end)

    table.sort(t2, function(a, b)
        return a.score > b.score
    end)

    table.sort(t3, function ( a, b )
        return a.score > b.score
    end)

    for i = 1, #t3 do
        self._layerLeft._layerList._heroData[#self._layerLeft._layerList._heroData + 1] = t3[i]
    end

    for i = 1, #t1 do
        self._layerLeft._layerList._heroData[#self._layerLeft._layerList._heroData + 1] = t1[i]
    end

    for i = 1, #t2 do
        self._layerLeft._layerList._heroData[#self._layerLeft._layerList._heroData + 1] = t2[i]
    end
end

function NewFormationView:initCustomHireTeamData()
    if not self:isShowHireTeam() then return end
    local t = {}
    for _, v in ipairs(self._extend.hireTeams) do
        repeat
            local id = v[1]
            local teamSubtype = v[2]
            local data = clone(self._guildModel:getEnemyDataById(id, teamSubtype))
            if not data then break end
            data.teamId = id
            data.teamSubtype = teamSubtype
            table.insert(t, data)
        until true
    end
    self._extend.hireTeams = t
end

function NewFormationView:initHireTeamListData()
    self._layerLeft._layerList._hireTeamData = {}
    if not self:isShowHireTeam() then return end
    if not self._extend.hireTeamsInit then
        self:initCustomHireTeamData()
        self._extend.hireTeamsInit = true
    end
    local data = clone(self._extend.hireTeams)
    local t1, t2, t3 = {}, {}, {}
    for k, v in ipairs(data) do
        repeat
            if self:isLoaded(NewFormationView.kGridTypeHireTeam, v.teamId, false, v.teamSubtype) then break end
            if not self:isHireTeamLevelLimit(v) and self:isHireTeamCanUsed(v) then
                v.id = v.teamId
                v.teamId = nil
                table.insert(t1, v)
            elseif not self:isHireTeamCanUsed(v) then
                v.id = v.teamId
                v.teamId = nil
                table.insert(t2, v)
            else
                v.id = v.teamId
                v.teamId = nil
                table.insert(t3, v)
            end
        until true
    end

    table.sort(t1, function(a, b)
        return a.score > b.score
    end)

    table.sort(t2, function(a, b)
        return a.score > b.score
    end)

    table.sort(t3, function(a, b)
        return a.score > b.score
    end)

    for i = 1, #t1 do
        self._layerLeft._layerList._hireTeamData[#self._layerLeft._layerList._hireTeamData + 1] = t1[i]
    end

    for i = 1, #t2 do
        self._layerLeft._layerList._hireTeamData[#self._layerLeft._layerList._hireTeamData + 1] = t2[i]
    end

    for i = 1, #t3 do
        self._layerLeft._layerList._hireTeamData[#self._layerLeft._layerList._hireTeamData + 1] = t3[i]
    end
end

function NewFormationView:initInsListData()
    self._layerLeft._layerList._insData = {}
    local data = clone(self._weaponsModel:getWeaponsDataF())
    local t1, t2 = {}, {}
    local custom = self:isHaveFixedWeapon()
    for k, v in pairs(data) do
        repeat
            if self:isLoaded(NewFormationView.kGridTypeIns, v.weaponId, nil, v.weaponType) then break end
            if not self:isFiltered(v.weaponId) then
                v.id = v.weaponId
                v.weaponId = nil
                v.teamSubtype = v.weaponType
                v.custom = custom
                table.insert(t1, v)
            else
                v.id = v.weaponId
                v.weaponId = nil
                v.teamSubtype = v.weaponType
                v.custom = custom
                table.insert(t2, v)
            end
        until true
    end

    table.sort(t1, function(a, b)
        if a.teamSubtype < b.teamSubtype then 
            return true
        end
        return a.id < b.id
    end)

    table.sort(t2, function(a, b)
        if a.teamSubtype < b.teamSubtype then 
            return true
        end
        return a.id < b.id
    end)

    for i = 1, #t1 do
        self._layerLeft._layerList._insData[#self._layerLeft._layerList._insData + 1] = t1[i]
    end

    for i = 1, #t2 do
        self._layerLeft._layerList._insData[#self._layerLeft._layerList._insData + 1] = t2[i]
    end

    -- dump(self._layerLeft._layerList._insData, "self._layerLeft._layerList._insData", 5)
end

function NewFormationView:onModelReflash()
    self:initFormationData()
    self:initTeamListData()
    self:initHeroListData()
    if self:isShowHireTeam() then
        self:initHireTeamListData()
    end
    if self:isShowInsFormation() then
        self:initInsListData()
    end
    self._layerLeft._teamFormation._allowLoadCount = self:getCurrentAllowLoadCount()
    --dump(self._layerLeft._layerList._teamData, "self._layerLeft._layerList._teamData")
    --dump(self._layerLeft._layerList._heroData, "self._layerLeft._layerList._heroData")
    self:updateUI()
end

function NewFormationView:refreshItemsTableView(noOffset)
    if NewFormationView.kGridTypeTeam == self._context._gridType[self._context._formationId] then
        self:initTeamListData()
    elseif NewFormationView.kGridTypeHero == self._context._gridType[self._context._formationId] then
        self:initHeroListData()
    elseif NewFormationView.kGridTypeHireTeam == self._context._gridType[self._context._formationId] and self:isShowHireTeam() then
        self:initHireTeamListData()
    elseif NewFormationView.kGridTypeIns == self._context._gridType[self._context._formationId] and self:isShowInsFormation() then
        self:initInsListData()
    end
    self:destroyItemsTableView()
    if NewFormationView.kGridTypeTeam == self._context._gridType[self._context._formationId] and #self:getCurrentIconData() <= 0 and not self:isShowButtonTraining() and self._formationType ~= self._formationModel.kFormationTypeLeague then
        self._layerLeft._layerList._layerItems:setVisible(false)
        self._layerLeft._layerList._layerItemsBlank:setVisible(true)
    else
        self._layerLeft._layerList._layerItems:setVisible(true)
        self._layerLeft._layerList._layerItemsBlank:setVisible(false)
    end
    self:createItemsTableView()
    if not noOffset then
        local offset = self._context._listOffset[self._context._formationId][self._context._gridType[self._context._formationId]]
        local minOffset = self._layerLeft._layerList._itemsTableView:minContainerOffset().x
        local maxOffset = self._layerLeft._layerList._itemsTableView:maxContainerOffset().x
        offset.x = math.min(math.max(offset.x, minOffset), maxOffset)
        self._layerLeft._layerList._itemsTableView:setContentOffset(offset, false)
        --self._layerLeft._layerList._itemsTableView:setContentOffset(self._context._listOffset[self._context._formationId][self._context._gridType[self._context._formationId]], false)
    end
end

function NewFormationView:destroyItemsTableView()
    if not self._layerLeft._layerList._itemsTableView then return end
    self._context._listOffset[self._context._formationId][self._context._gridType[self._context._formationId]] = self._layerLeft._layerList._itemsTableView:getContentOffset()
    self._layerLeft._layerList._itemsTableView:removeFromParentAndCleanup()
    self._layerLeft._layerList._itemsTableView = nil
end

function NewFormationView:createItemsTableView()
    if self._layerLeft._layerList._itemsTableView then return end
    self._layerLeft._layerList._itemsTableView = cc.TableView:create(self._layerLeft._layerList._layerItems:getContentSize())
    self._layerLeft._layerList._itemsTableView:setDelegate()
    self._layerLeft._layerList._itemsTableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    --self._layerLeft._layerList._itemsTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._layerLeft._layerList._itemsTableView:setAnchorPoint(cc.p(0, 0))
    self._layerLeft._layerList._itemsTableView:setPosition(cc.p(0, 0))
    --self._layerLeft._layerList._itemsTableView:setBounceable(false)
    self._layerLeft._layerList._layerItems:addChild(self._layerLeft._layerList._itemsTableView, self.kAboveNormalZOrder)
    self._layerLeft._layerList._itemsTableView:registerScriptHandler(handler(self, self.itemsTableViewCellTouched), cc.TABLECELL_TOUCHED)
    self._layerLeft._layerList._itemsTableView:registerScriptHandler(handler(self, self.itemsTableViewCellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._layerLeft._layerList._itemsTableView:registerScriptHandler(handler(self, self.itemsTableViewCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._layerLeft._layerList._itemsTableView:registerScriptHandler(handler(self, self.itemsTableViewDidScroll), cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._layerLeft._layerList._itemsTableView:registerScriptHandler(handler(self, self.numberOfCellsInItemsTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._layerLeft._layerList._itemsTableView:reloadData()
end

function NewFormationView:getCurrentLeftHittedGridIndex(position, specifiedIndex)
    local gridIndex = 0
    if specifiedIndex and type(specifiedIndex) == "number" then
        gridIndex = specifiedIndex
    else
        for i = 1, NewFormationView.kTeamGridCount do
            if self._layerLeft._teamFormation._grid[i]:getGrid():isScreenPointInNodeRect(position.x, position.y) then
                gridIndex = self._layerLeft._teamFormation._grid[i]:getGridIndex()
                break
            end
        end
    end
    return gridIndex
end

function NewFormationView:getCurrentLeftInsHittedGridIndex(position, specifiedIndex)
    local gridIndex = 0
    if specifiedIndex and type(specifiedIndex) == "number" then
        gridIndex = specifiedIndex
    else
        for i = 1, NewFormationView.kInsMaxCount do
            if self._layerLeft._insFormation._grid[i]:getGrid():isScreenPointInNodeRect(position.x, position.y) then
                gridIndex = self._layerLeft._insFormation._grid[i]:getGridIndex()
                break
            end
        end
    end
    return gridIndex
end


function NewFormationView:updateState()
    if self:isFormationLocked() then return end

    if not (self._layerLeft._isIconHitted and self._layerLeft._isIconMoved) then return end

    local iconId = self._layerLeft._hittedIcon:getIconId()
    local iconType = self._layerLeft._hittedIcon:getIconType()
    local iconSubtype = self._layerLeft._hittedIcon:getIconSubtype()
    local isHaveCurrentTeam = self:isHaveCurrentTeam(iconId)
    --[[
    if self._layerLeft._isItemsLayerHitted then
        if not self._layerLeft._isBeganFromTeamIconGrid and not self._layerLeft._cloneHittedIcon then
            self._layerLeft._cloneHittedIcon = self._layerLeft._hittedIcon:clone()
            --self._layerLeft._cloneHittedIcon:setPosition(cc.p(self._layerLeft._hittedIcon:getParent():convertToWorldSpace(cc.p(self._layerLeft._hittedIcon:getPosition()))))
            self._layerLeft._layerTouch:addChild(self._layerLeft._cloneHittedIcon)
        end
        if self._layerLeft._cloneHittedIcon then
            self._layerLeft._cloneHittedIcon:updateState(NewFormationIconView.kIconStateImage)
        else
            self._layerLeft._hittedIcon:updateState(NewFormationIconView.kIconStateImage)
        end
    else
        if self._layerLeft._cloneHittedIcon then
            self._layerLeft._cloneHittedIcon:updateState(NewFormationIconView.kIconStateBody)
        else
            self._layerLeft._hittedIcon:updateState(NewFormationIconView.kIconStateBody)
        end
    end

    if self._layerLeft._isBeganFromTeamIconGrid and not self._layerLeft._isHittedIconSwitched then
        self._layerLeft._hittedIcon:retain()
        if self._layerLeft._hittedIconGrid then
            self._layerLeft._hittedIconGrid:setIconView()
        end
        self._layerLeft._hittedIcon:setRotation3D(cc.Vertex3F(0, 0, 0))
        self._layerLeft._layerTouch:addChild(self._layerLeft._hittedIcon)
        self._layerLeft._isHittedIconSwitched = true
        self._layerLeft._hittedIcon:release()
    end
    ]]
    local validTeamFormation = function(valid)
        if valid then
            local gridIndex = self:getCurrentLeftHittedGridIndex(self._layerLeft._mPosition)
            for i = 1, NewFormationView.kTeamGridCount do
                if self:isLeftGridWall(i) then
                    self._layerLeft._teamFormation._grid[i]:setState(FormationGrid.kStateWall)
                elseif not self:isPositionValid(i, self._layerLeft._hittedIcon:getClassPosition()) or self:isPositionLocked(i) then
                    self._layerLeft._teamFormation._grid[i]:setState(FormationGrid.kStateInvalid)
                elseif self:isShowHireTeam() and iconType == NewFormationView.kGridTypeHireTeam and self:isHireTeamLoaded() and not self._layerLeft._isBeganFromTeamIconGrid then
                    local iconView = self._layerLeft._teamFormation._grid[i]:getIconView()
                    if iconView then
                        local iconId1 = iconView:getIconId()
                        local iconType1 = iconView:getIconType()
                        if iconType1 and iconType1 == NewFormationView.kGridTypeHireTeam and not (isHaveCurrentTeam and iconId ~= iconId1) then
                            self._layerLeft._teamFormation._grid[i]:setState(FormationGrid.kStateValid)
                        else
                            self._layerLeft._teamFormation._grid[i]:setState(FormationGrid.kStateInvalid)
                        end
                    else
                        self._layerLeft._teamFormation._grid[i]:setState(FormationGrid.kStateInvalid)
                    end
                elseif self:isShowHireTeam() and iconType == NewFormationView.kGridTypeHireTeam and not self:isHireTeamLoaded() and not self._layerLeft._isBeganFromTeamIconGrid and isHaveCurrentTeam then
                    local iconView = self._layerLeft._teamFormation._grid[i]:getIconView()
                    if iconView then
                        local iconId1 = iconView:getIconId()
                        local iconType1 = iconView:getIconType()
                        if iconId1 and iconId1 == iconId and iconType1 and iconType1 == NewFormationView.kGridTypeTeam then
                            self._layerLeft._teamFormation._grid[i]:setState(FormationGrid.kStateValid)
                        else
                            self._layerLeft._teamFormation._grid[i]:setState(FormationGrid.kStateInvalid)
                        end
                    else
                        self._layerLeft._teamFormation._grid[i]:setState(FormationGrid.kStateInvalid)
                    end
                elseif self:isShowHireTeam() and iconType == NewFormationView.kGridTypeTeam and self:isHireTeamLoaded() and not self._layerLeft._isBeganFromTeamIconGrid and isHaveCurrentTeam then
                    local iconView = self._layerLeft._teamFormation._grid[i]:getIconView()
                    if iconView then
                        local iconId1 = iconView:getIconId()
                        local iconType1 = iconView:getIconType()
                        if iconId1 and iconId1 == iconId and iconType1 and iconType1 == NewFormationView.kGridTypeHireTeam then
                            self._layerLeft._teamFormation._grid[i]:setState(FormationGrid.kStateValid)
                        else
                            self._layerLeft._teamFormation._grid[i]:setState(FormationGrid.kStateInvalid)
                        end
                    else
                        self._layerLeft._teamFormation._grid[i]:setState(FormationGrid.kStateInvalid)
                    end
                elseif self._layerLeft._isBeganFromTeamIconGrid and self._layerLeft._teamFormation._grid[i]:isStateFull() then
                    local iconView = self._layerLeft._teamFormation._grid[i]:getIconView()
                    local iconGrid = self._layerLeft._hittedIconGrid
                    if iconView and iconGrid and self:isPositionValid(iconGrid:getGridIndex(), iconView:getClassPosition()) then
                        self._layerLeft._teamFormation._grid[i]:setState(FormationGrid.kStateValid)
                    else
                        self._layerLeft._teamFormation._grid[i]:setState(FormationGrid.kStateInvalid)
                    end
                elseif not self._layerLeft._isBeganFromTeamIconGrid and self:isTeamLoadedFull() then
                    if self._layerLeft._teamFormation._grid[i]:isStateFull() then
                        self._layerLeft._teamFormation._grid[i]:setState(FormationGrid.kStateValid)
                    else
                        self._layerLeft._teamFormation._grid[i]:setState(FormationGrid.kStateInvalid)
                    end
                else
                    self._layerLeft._teamFormation._grid[i]:setState(FormationGrid.kStateValid)
                end
                if i == gridIndex and self._layerLeft._teamFormation._grid[i]:isStateValid() then
                    self._layerLeft._teamFormation._grid[i]:setState(FormationGrid.kStateSelecting)
                else
                    self._layerLeft._teamFormation._grid[i]:unsetState(FormationGrid.kStateSelecting)
                end
                self._layerLeft._teamFormation._grid[i]:updateState()
            end
        else
            for i = 1, NewFormationView.kTeamGridCount do
                self._layerLeft._teamFormation._grid[i]:setState(FormationGrid.kStateInvalid)
                self._layerLeft._teamFormation._grid[i]:updateState()
            end
        end
    end

    local blankTeamFormation = function()
        for i = 1, NewFormationView.kTeamGridCount do
            self._layerLeft._teamFormation._grid[i]:setState(FormationGrid.kStateBlank)
            self._layerLeft._teamFormation._grid[i]:updateState()
        end
    end

    local validHeroFormation = function(valid, isSelected)
        if valid then
            self._layerLeft._heroFormation._grid:setState(FormationGrid.kStateValid)
            if isSelected then
                self._layerLeft._heroFormation._grid:setState(FormationGrid.kStateSelecting)
            end
            self._layerLeft._heroFormation._grid:updateState()
        else
            self._layerLeft._heroFormation._grid:setState(FormationGrid.kStateInvalid)
            self._layerLeft._heroFormation._grid:updateState()
        end
    end

    local blankHeroFormation = function()
        self._layerLeft._heroFormation._grid:setState(FormationGrid.kStateBlank)
        self._layerLeft._heroFormation._grid:updateState()
    end

    local validInsFormation = function(valid)
        if valid then
            local gridIndex = self:getCurrentLeftInsHittedGridIndex(self._layerLeft._mPosition)
            for i = 1, NewFormationView.kInsMaxCount do
                if iconSubtype and iconSubtype == i then
                    self._layerLeft._insFormation._grid[i]:setState(FormationGrid.kStateValid)
                else
                    self._layerLeft._insFormation._grid[i]:setState(FormationGrid.kStateInvalid)
                end

                if i == gridIndex and self._layerLeft._insFormation._grid[i]:isStateValid() then
                    self._layerLeft._insFormation._grid[i]:setState(FormationGrid.kStateSelecting)
                else
                    self._layerLeft._insFormation._grid[i]:unsetState(FormationGrid.kStateSelecting)
                end
                self._layerLeft._insFormation._grid[i]:updateState()
            end
        else
            for i = 1, NewFormationView.kInsMaxCount do
                self._layerLeft._insFormation._grid[i]:setState(FormationGrid.kStateInvalid)
                self._layerLeft._insFormation._grid[i]:updateState()
            end
        end
    end

    local blankInsFormation = function()
        for i = 1, NewFormationView.kInsMaxCount do
            self._layerLeft._insFormation._grid[i]:setState(FormationGrid.kStateBlank)
            self._layerLeft._insFormation._grid[i]:updateState()
        end
    end

    if self._layerLeft._isteamFormationLayerHitted or self._layerLeft._isHeroFormationLayerHitted or self._layerLeft._isinsFormationLayerHitted then
        if self._layerLeft._isteamFormationLayerHitted then
            if iconType == NewFormationView.kGridTypeTeam or iconType == NewFormationView.kGridTypeHireTeam then
                validTeamFormation(true)
                --validHeroFormation(false)
                --validInsFormation(false)
            elseif iconType == NewFormationView.kGridTypeHero then
                validTeamFormation(false)
                validHeroFormation(true)
                validInsFormation(false)
            else
                validTeamFormation(false)
                validHeroFormation(false)
                validInsFormation(true)
            end
        elseif self._layerLeft._isHeroFormationLayerHitted then
            if iconType == NewFormationView.kGridTypeHero then
                --validTeamFormation(false)
                validHeroFormation(true, true)
                --validInsFormation(false)
            elseif iconType == NewFormationView.kGridTypeTeam or iconType == NewFormationView.kGridTypeHireTeam then
                validTeamFormation(true)
                validHeroFormation(false)
                validInsFormation(false)
            else
                validTeamFormation(false)
                validHeroFormation(false)
                validInsFormation(true)
            end
        elseif self._layerLeft._isinsFormationLayerHitted then
            if iconType == NewFormationView.kGridTypeIns then
                validTeamFormation(false)
                validHeroFormation(false)
                validInsFormation(true)
            elseif iconType == NewFormationView.kGridTypeTeam or iconType == NewFormationView.kGridTypeHireTeam then
                validTeamFormation(true)
                validHeroFormation(false)
                validInsFormation(false)
            else
                validTeamFormation(false)
                validHeroFormation(true)
                validInsFormation(false)
            end
        end
    else
        blankTeamFormation()
        blankHeroFormation()
        blankInsFormation()
    end

    if self._layerLeft._cloneHittedIcon then
        self._layerLeft._cloneHittedIcon:setPosition(self._layerLeft._mPosition)
    elseif self._layerLeft._hittedIcon then
        self._layerLeft._hittedIcon:setPosition(self._layerLeft._mPosition)
    end
end

function NewFormationView:startClock()
    if self._timer_id then self:endClock() end
    self._timer_id = self._scheduler:scheduleScriptFunc(function()
        self:updateState()
    end, 0, false)
end

function NewFormationView:endClock()
    if self._timer_id then 
        self._scheduler:unscheduleScriptEntry(self._timer_id)
        self._timer_id = nil
    end
end

function NewFormationView:endClockEx()

end

function NewFormationView:convertPointToTargetNodeSpace(node, x, y)
    return node:convertToNodeSpace(cc.p(x,y))
end

function NewFormationView:fillRelationBuilds(iconType, iconId)
    --[[
    self._config._formationBuild = tab.formation_build
    self._config._formationTeam = tab.formation_team
    self._config._formationHero = tab.formation_hero
    self._config._relationBuild = {}
    ]]
    --dump(self._config._formationBuild, "self._config._formationBuild")
    --dump(self._config._formationTeam, "self._config._formationTeam")
    --dump(self._config._formationHero, "self._config._formationHero")
    if self._config._relationBuilds._cached then return true end
    local build = nil
    if iconType == NewFormationView.kGridTypeTeam then
        if self._config._formationTeam[iconId] then
            build = self._config._formationTeam[iconId].build
        end
    else
        if self._config._formationHero[iconId] then
            build = self._config._formationHero[iconId].build
        end
    end
    if not build then return self:clearRelationBuilds() end

    local teams = {}
    local heroes = {}
    if iconType == NewFormationView.kGridTypeTeam then
        teams[iconId] = {
            effects = {},
            builds = {},
            relationIds = {},
        }
        for k, v in ipairs(build) do
            repeat
                local buildId = v[1]
                local buildType = v[2]
                local items = self._config._formationBuild[buildId] and self._config._formationBuild[buildId]["build" .. buildType]
                if not items then break end
                if not teams[iconId].relationIds[buildId] then
                    teams[iconId].relationIds[buildId] = {
                        teams = {},
                        heroes = {}
                    }
                end
                local data = nil
                if buildType < 3 then
                    data = teams[iconId].relationIds[buildId].teams
                else
                    data = teams[iconId].relationIds[buildId].heroes
                end
                if not data then break end
                for i=1, #items do
                    data[#data + 1] = items[i]
                end
                data = table.unique(data, true)
                if not teams[iconId].builds[buildId] then
                    table.insert(teams[iconId].effects, tonumber(buildId))
                    teams[iconId].builds[buildId] = true
                end
            until true
        end
    else
        heroes[iconId] = {
            effects = {},
            builds = {},
            relationIds = {},
        }
        for k, v in ipairs(build) do
            repeat
                local buildId = v[1]
                local buildType = v[2]
                local items = self._config._formationBuild[buildId] and self._config._formationBuild[buildId]["build" .. buildType]
                if not items then break end
                if not heroes[iconId].relationIds[buildId] then
                    heroes[iconId].relationIds[buildId] = {
                        teams = {},
                        heroes = {}
                    }
                end
                local data = nil
                if buildType < 3 then
                    data = heroes[iconId].relationIds[buildId].teams
                else
                    data = heroes[iconId].relationIds[buildId].heroes
                end
                if not data then break end
                for i=1, #items do
                    data[#data + 1] = items[i]
                end
                data = table.unique(data, true)
                if not heroes[iconId].builds[buildId] then
                    table.insert(heroes[iconId].effects, tonumber(buildId))
                    heroes[iconId].builds[buildId] = true
                end
            until true
        end
    end

    for k, v in ipairs(build) do
        repeat
            local buildId = v[1]
            local buildType = v[2]
            local items = self._config._formationBuild[buildId] and self._config._formationBuild[buildId]["build" .. buildType]
            if not items then break end
            local data = nil
            if buildType < 3 then
                data = teams
                -- if iconType == NewFormationView.kGridTypeTeam then
                --     if not data[iconId].relationIds[buildId] then
                --         data[iconId].relationIds[buildId] = {}
                --     end
                --     for i=1, #items do
                --         data[iconId].relationIds[buildId][#data[iconId].relationIds[buildId] + 1] = items[i]
                --     end
                --     data[iconId].relationIds[buildId] = table.unique(data[iconId].relationIds[buildId], true)
                --     if not data[iconId].builds[buildId] then
                --         table.insert(data[iconId].effects, tonumber(buildId))
                --         data[iconId].builds[buildId] = true
                --     end
                -- end
            else
                data = heroes
                -- if iconType == NewFormationView.kGridTypeHero and not data[iconId].builds[buildId] then
                --     table.insert(data[iconId].effects, tonumber(buildId))
                --     data[iconId].builds[buildId] = true
                -- end
            end
            if not data then break end
            for k1, v1 in ipairs(items) do
                local id = tonumber(v1)
                repeat
                    if data[id] and data[id].builds[buildId] then break end
                    if not data[id] then
                        data[id] = {
                            effects = {},
                            builds = {}
                        }
                    end
                    table.insert(data[id].effects, tonumber(buildId))
                    data[id].builds[buildId] = true
                until true
            end
        until true
    end

    for k, v in pairs(teams) do
        if v.effects then
            table.sort(v.effects, function(a, b)
                return a < b
            end)
        end
    end

    for k, v in pairs(heroes) do
        if v.effects then
            table.sort(v.effects, function(a, b)
                return a < b
            end)
        end
    end

    self._config._relationBuilds._builds._teams = teams
    self._config._relationBuilds._builds._heroes = heroes
    self._config._relationBuilds._cached = true

    --dump(self._config._relationBuilds._builds, "builds", 5)

    return true
end

function NewFormationView:clearRelationBuilds()
    self._config._relationBuilds = {
        _cached = false,
        _builds = {
            _teams = {},
            _heroes = {}
        },
    }
end

function NewFormationView:showRelationEffect(isBegan, iconView)
    if self:isFormationLocked() then return false end
    if isBegan then
        if not iconView then return end
        local iconId = iconView:getIconId()
        local iconType = iconView:getIconType()
        self:fillRelationBuilds(iconType, iconId)
        for k, v in pairs(self._config._relationBuilds._builds._teams) do
            local found, iconViewRelation = self:isLoaded(NewFormationView.kGridTypeTeam, tonumber(k), true)
            if iconViewRelation then
                iconViewRelation:relationEffectBreath(true)
            end
        end

        for k, v in pairs(self._config._relationBuilds._builds._heroes) do
            local found, iconViewRelation = self:isLoaded(NewFormationView.kGridTypeHero, tonumber(k), true)
            if iconViewRelation then
                iconViewRelation:relationEffectBreath(true)
            end
        end
    else
        if not iconView then return end
        local iconId = iconView:getIconId()
        local iconType = iconView:getIconType()
        self:clearRelationBuilds()
        self:fillRelationBuilds(iconType, iconId)

        local getValidEffects = function(effects, relationIds)
            local validEffects = {}
            for _, effect in ipairs(effects) do
                local valid = false
                if relationIds[effect] then
                    if relationIds[effect].teams then
                        for _, id in ipairs(relationIds[effect].teams) do
                            if self:isLoaded(NewFormationView.kGridTypeTeam, tonumber(id)) then
                                valid = true
                                break
                            end
                        end
                    end
                    
                    if relationIds[effect].heroes then
                        for _, id in ipairs(relationIds[effect].heroes) do
                            if self:isLoaded(NewFormationView.kGridTypeHero, tonumber(id)) then
                                valid = true
                                break
                            end
                        end
                    end
                end
                if valid then
                    table.insert(validEffects, effect)
                end
            end

            table.sort(validEffects, function(a, b)
                return a < b
            end)

            return validEffects
        end

        for k, v in pairs(self._config._relationBuilds._builds._teams) do
            if v.relationIds then
                v.effects = getValidEffects(v.effects, v.relationIds)
            end
            local found, iconViewRelation = self:isLoaded(NewFormationView.kGridTypeTeam, tonumber(k), true)
            if iconViewRelation then
                iconViewRelation:showRelationEffect(v.effects)
            end
        end

        for k, v in pairs(self._config._relationBuilds._builds._heroes) do
            if v.relationIds then
                v.effects = getValidEffects(v.effects, v.relationIds)
            end
            local found, iconViewRelation = self:isLoaded(NewFormationView.kGridTypeHero, tonumber(k), true)
            if iconViewRelation then
                iconViewRelation:showRelationEffect(v.effects)
            end
        end
    end
end

function NewFormationView:clearRelationEffect()
    for k, v in pairs(self._config._relationBuilds._builds._teams) do
        local found, iconView = self:isLoaded(NewFormationView.kGridTypeTeam, tonumber(k), true)
        if iconView then
            iconView:clearRelationEffect()
        end
    end

    for k, v in pairs(self._config._relationBuilds._builds._heroes) do
        local found, iconView = self:isLoaded(NewFormationView.kGridTypeHero, tonumber(k), true)
        if iconView then
            iconView:clearRelationEffect()
        end
    end
    self:clearRelationBuilds()
    self._config._isShowBuildEffect = false
end

function NewFormationView:hasRelationEffect(iconType, iconId)
    if iconType == NewFormationView.kGridTypeTeam then
        local builds = self._config._relationBuilds._builds._teams[iconId]
        if builds and #builds.effects > 0  then
            return true
        end
    else
        local builds = self._config._relationBuilds._builds._heroes[iconId]
        if builds and #builds.effects > 0  then
            return true
        end
    end
    return false
end

function NewFormationView:onButtonBuildsClicked()
    local formationData = self._layerLeft._teamFormation._data[self._context._formationId]

    local teams = {}
    local heroId = formationData.heroId
    for i = 1, NewFormationView.kTeamMaxCount do
        local teamId = tonumber(formationData["team" .. i])
        if teamId and 0 ~= teamId then
            teams[teamId] = true
        end
    end
    local backupIds = {}
    if formationData.bid and formationData.backupTs then
        local ts = formationData.backupTs[tostring(formationData.bid)] or {}
        for i = 1, 3 do
            local id = ts["bt" .. i]
            if id and id ~= 0 and not teams[id] then
                teams[id] = true
                table.insert(backupIds, id)
            end
        end
    end
    local allBuilds = self._formationModel:getAllRelationBuilds(teams, heroId)
    local data = {}
    local count = 0
    for k, v in ipairs(allBuilds) do
        if (v[1] and table.nums(v[1]) > 0) or (v[2] and table.nums(v[2]) > 0) or (v[3] and table.nums(v[3]) > 0) or (v[4] and table.nums(v[4]) > 0) then
            count = count + 1
            data[k] = v
        end
    end
    count = math.min(count, 5)

    if count <= 0 then
        self._viewMgr:showTip(lang("TIP_BUZHEN_MEIGUANLIAN"))
        return
    end
    self._viewMgr:showDialog("formation.FormationCombinationDialog", {relationData = data, backupIds = backupIds})
end

function NewFormationView:onIconTouchBegan(iconView, x, y)
    self._layerLeft._layerList._isIconMoved = false
    if iconView:isShowFilter() then return false end

    if iconView:isShowLocked() then
        self._viewMgr:showTip(lang("HERODUEL9"))
        return false
    end

    if iconView:isShowLimit() then
        self._viewMgr:showTip(lang("LINEUP_LANSQUENET_TIP1"))
        return false
    end

    if iconView:isShowUsed() then
        return false
    end

    local result, reason = self:onIconTouchBeganEx(iconView)
    if not result then 
        self._viewMgr:showTip(reason)
        return false 
    end
    self._layerLeft._isIconHitted = true
    self._layerLeft._hittedIcon = iconView
    self._layerLeft._hittedIconGrid = self._layerLeft._hittedIcon:getIconGrid()
    self._layerLeft._hittedIcon:onClickingBegan()
    --self:showTipsInfo(true)
    --[[
    if self._layerLeft._isItemsLayerHitted then
        self:showRelationEffect(true, self._layerLeft._hittedIcon)
    end
    ]]
    return true
end

function NewFormationView:onIconTouchBeganEx(iconView)
    return true
end

function NewFormationView:onIconTouchMoved(iconView, x, y)
    --lf._layerLeft._layerList._isIconMoved = true
end

function NewFormationView:onIconTouchEnded(iconView, x, y)

end

function NewFormationView:onIconTouchCancelled(iconView, x, y)

end

function NewFormationView:disableItemTableView(disable)
    if not self._layerLeft._layerList._itemsTableView then return end
    --self._layerLeft._layerList._itemsTableView:setTouchEnabled(not disable)
    self._layerLeft._layerTouch:setSwallowTouches(disable)
end

function NewFormationView:updateLayerLeftHittedState(x, y)
    self._layerLeft._isHeroFormationLayerHitted = self._layerLeft._heroFormation._layer:isScreenPointInNodeRect(x, y)
    self._layerLeft._isteamFormationLayerHitted = self._layerLeft._teamFormation._layer:isScreenPointInNodeRect(x, y)
    self._layerLeft._isinsFormationLayerHitted = self._layerLeft._insFormation._layer:isScreenPointInNodeRect(x, y)
    self._layerLeft._isItemsLayerHitted = self._layerLeft._layerList._layerItems:isScreenPointInNodeRect(x, y)
end

function NewFormationView:resetAllLeftState()
    for i = 1, NewFormationView.kTeamGridCount do
        self._layerLeft._teamFormation._grid[i]:setState(FormationGrid.kStateBlank)
        self._layerLeft._teamFormation._grid[i]:updateState()
    end

    self._layerLeft._heroFormation._grid:setState(FormationGrid.kStateBlank)
    self._layerLeft._heroFormation._grid:updateState()

    local data = self:getCurrentIconData()
    for idx=1, #data do
        repeat
            local oneCell = self._layerLeft._layerList._itemsTableView:cellAtIndex(idx-1)
            if not oneCell then break end
            local item = oneCell:getChildByTag(NewFormationView.kItemTag)
            if item then self:setTableViewItemSelected(item, false) end
        until true
    end
end

function NewFormationView:onLayerLeftTouchBegan(_, x, y)
    --local position = self:convertPointToTargetNodeSpace(self._layerLeft._layerTouch, x, y)
    --print("formation touch began:", x, y)
    self._layerLeft._sPosition = cc.p(x, y)
    self:updateLayerLeftHittedState(x, y)
    self:disableItemTableView(false)
    self:updateSelectedState()
    self._layerLeft._isBeganFromTeamIconGrid = (not self._layerLeft._isHeroFormationLayerHitted and not self._layerLeft._isinsFormationLayerHitted) and self._layerLeft._isteamFormationLayerHitted
    self._layerLeft._isBeganFromHeroIconGrid = (not self._layerLeft._isteamFormationLayerHitted and not not self._layerLeft._isinsFormationLayerHitted) and self._layerLeft._isHeroFormationLayerHitted
    self._layerLeft._isBeganFromInsIconGrid = (not self._layerLeft._isteamFormationLayerHitted and not self._layerLeft._isHeroFormationLayerHitted) and self._layerLeft._isinsFormationLayerHitted
    if self._layerLeft._isteamFormationLayerHitted then
        local gridIndex = self:getCurrentLeftHittedGridIndex(self._layerLeft._sPosition)
        if 0 ~= gridIndex then
            local iconGrid = self._layerLeft._teamFormation._grid[gridIndex]
            if iconGrid:isStateFull() then
                local iconView = iconGrid:getIconView()
                if iconView and iconView:isShowLocked() then
                    self._viewMgr:showTip(lang("HERODUEL9"))
                end
                if iconView and not iconView:isShowLocked() then
                    self._layerLeft._isIconHitted = true
                    self._layerLeft._hittedIcon = iconView
                    self._layerLeft._hittedIconGrid = iconGrid
                end
            end
        end
    end

    if self._layerLeft._isinsFormationLayerHitted then
        local gridIndex = self:getCurrentLeftInsHittedGridIndex(self._layerLeft._sPosition)
        if 0 ~= gridIndex then
            local iconGrid = self._layerLeft._insFormation._grid[gridIndex]
            if iconGrid:isStateFull() then
                local iconView = iconGrid:getIconView()
                if iconView and iconView:isShowLocked() then
                    self._viewMgr:showTip(lang("HERODUEL9"))
                end
                if iconView and not iconView:isShowLocked() then
                    self._layerLeft._isIconHitted = true
                    self._layerLeft._hittedIcon = iconView
                    self._layerLeft._hittedIconGrid = iconGrid
                end
            end
        end
    end

    self._layerLeft._isHittedIconSwitched = false
    --self:showTipsInfo(true)
    self:resetAllLeftState()
    return true
end

function NewFormationView:onLayerLeftTouchMoved(_, x, y)
    --local position = self:convertPointToTargetNodeSpace(self._layerLeft._layerTouch, x, y)
    if self:isFormationLocked() then return false end
    if not self._layerLeft._isIconHitted then return end
    if self._layerLeft._isBeganFromHeroIconGrid then return end
    if self._layerLeft._isBeganFromInsIconGrid and (not self:isShowInsFormation() or self:isHaveFixedWeapon()) then return end
    --print("formation touch moved:", x, y)

    self._layerLeft._mPosition = cc.p(x, y)
    self:updateLayerLeftHittedState(x, y)

    if not self._layerLeft._isIconMoved then
        if OS_IS_WINDOWS then
            self._layerLeft._isIconMoved = (self._layerLeft._isBeganFromInsIconGrid or self._layerLeft._isBeganFromTeamIconGrid) or 
            (self._layerLeft._isItemsLayerHitted and math.abs(self._layerLeft._mPosition.x - self._layerLeft._sPosition.x) <= 5 * NewFormationView.kMoveThreshold and math.abs(self._layerLeft._mPosition.y - self._layerLeft._sPosition.y) >= NewFormationView.kMoveThreshold) or
            (self._layerLeft._isItemsLayerHitted and #self:getCurrentIconData() <= self:getIcontCount())
        else
            self._layerLeft._isIconMoved = ((self._layerLeft._isBeganFromInsIconGrid or self._layerLeft._isBeganFromTeamIconGrid) and (math.abs(self._layerLeft._mPosition.x - self._layerLeft._sPosition.x) >= NewFormationView.kMoveThreshold / 4 or math.abs(self._layerLeft._mPosition.y - self._layerLeft._sPosition.y) >= NewFormationView.kMoveThreshold / 4)) or 
            (self._layerLeft._isItemsLayerHitted and math.abs(self._layerLeft._mPosition.x - self._layerLeft._sPosition.x) <= 5 * NewFormationView.kMoveThreshold and math.abs(self._layerLeft._mPosition.y - self._layerLeft._sPosition.y) >= NewFormationView.kMoveThreshold) or
            (GuideUtils.isGuideRunning and self._layerLeft._isItemsLayerHitted and #self:getCurrentIconData() <= self:getIcontCount())
        end
    end

    if not self._layerLeft._isIconMoved then return end

    if not self._config._isShowBuildEffect then
        if self._layerLeft._isItemsLayerHitted then
            self:showRelationEffect(true, self._layerLeft._hittedIcon)
        end
        self._config._isShowBuildEffect = true
    end

    self._layerLeft._layerList._isIconMoved = true
    self._layerLeft._hittedIcon:onClickingEnded()
    self:showTipsInfo(true)

    if self._layerLeft._isItemsLayerHitted then
        self:disableItemTableView(true)
    end

    if self._layerLeft._isItemsLayerHitted then
        if (not (self._layerLeft._isBeganFromTeamIconGrid or self._layerLeft._isBeganFromInsIconGrid)) and not self._layerLeft._cloneHittedIcon then
            self._layerLeft._cloneHittedIcon = self._layerLeft._hittedIcon:clone()
            --self._layerLeft._cloneHittedIcon:setPosition(cc.p(self._layerLeft._hittedIcon:getParent():convertToWorldSpace(cc.p(self._layerLeft._hittedIcon:getPosition()))))
            self._layerLeft._layerTouch:addChild(self._layerLeft._cloneHittedIcon)
        end
        if self._layerLeft._cloneHittedIcon then
            self._layerLeft._cloneHittedIcon:updateState(NewFormationIconView.kIconStateImage)
        else
            self._layerLeft._hittedIcon:updateState(NewFormationIconView.kIconStateImage)
        end
    else
        if self._layerLeft._cloneHittedIcon then
            self._layerLeft._cloneHittedIcon:updateState(NewFormationIconView.kIconStateBody)
        else
            self._layerLeft._hittedIcon:updateState(NewFormationIconView.kIconStateBody)
        end
    end

    if (self._layerLeft._isBeganFromTeamIconGrid or self._layerLeft._isBeganFromInsIconGrid) and not self._layerLeft._isHittedIconSwitched then
        self._layerLeft._hittedIcon:retain()
        if self._layerLeft._hittedIconGrid then
            self._layerLeft._hittedIconGrid:setIconView()
        end
        self._layerLeft._hittedIcon:setRotation3D(cc.Vertex3F(0, 0, 0))
        self._layerLeft._layerTouch:addChild(self._layerLeft._hittedIcon)
        self._layerLeft._isHittedIconSwitched = true
        self._layerLeft._hittedIcon:release()
    end
    --[[
    if self._layerLeft._cloneHittedIcon then
        self._layerLeft._cloneHittedIcon:setPosition(self._layerLeft._mPosition)
    elseif self._layerLeft._hittedIcon then
        self._layerLeft._hittedIcon:setPosition(self._layerLeft._mPosition)
    end
    ]]
end

function NewFormationView:onLayerLeftTouchEnded(_, x, y, _, specifiedIndex)
    --local position = self:convertPointToTargetNodeSpace(self._layerLeft._layerTouch, x, y)
    --print("formation touch ended:", x, y)
    self._layerLeft._ePosition = cc.p(x, y)
    self:updateLayerLeftHittedState(x, y)
    
    if not self._layerLeft._isIconMoved then 
        --if self._layerLeft._isBeganFromTeamIconGrid then
        if self._layerLeft._isteamFormationLayerHitted or self._layerLeft._isHeroFormationLayerHitted or self._layerLeft._isinsFormationLayerHitted then
            if self._layerLeft._hittedIcon then
                if self._layerLeft._hittedIconGrid then
                    self._layerLeft._hittedIconGrid:setState(FormationGrid.kStateSelected)
                    self._layerLeft._hittedIconGrid:updateState()
                end
                local iconType = self._layerLeft._hittedIcon:getIconType()
                local iconId = self._layerLeft._hittedIcon:getIconId()
                local iconSubtype = self._layerLeft._hittedIcon:getIconSubtype()
                if (iconType == NewFormationView.kGridTypeTeam or iconType == NewFormationView.kGridTypeHireTeam) then
                    if not (x <= 505 and y <= 155) then
                        self:onShowDescriptionView(iconType, iconId, iconSubtype, self._layerLeft._hittedIcon:isChangedProfile(), self._layerLeft._hittedIcon:getChangedId(), self:isTeamCustom(iconId), self:isTeamLocal(iconId))
                    end
                else
                    self:onShowDescriptionView(iconType, iconId, iconSubtype, nil, nil, self:isHeroCustom(iconId), self:isHeroLocal(iconId))
                end
            end
        end
        if self._layerLeft._hittedIcon and self._layerLeft._hittedIcon.onClickingEnded then
            self._layerLeft._hittedIcon:onClickingEnded()
        end
        self._layerLeft._isIconHitted = false
        self._layerLeft._hittedIcon = nil
        self._layerLeft._cloneHittedIcon = nil
        self._layerLeft._hittedIconGrid = nil
        self:clearRelationEffect()
        self:showTipsInfo(false)
        return 
    end

    local isFormationReplaced = false
    local iconType = self._layerLeft._hittedIcon:getIconType()
    local iconId = self._layerLeft._hittedIcon:getIconId()
    local iconSubtype = self._layerLeft._hittedIcon:getIconSubtype()
    if self._layerLeft._isteamFormationLayerHitted then
        if iconType == NewFormationView.kGridTypeTeam or iconType == NewFormationView.kGridTypeHireTeam then
            local gridIndex = self:getCurrentLeftHittedGridIndex(self._layerLeft._mPosition, specifiedIndex)
            if 0 ~= gridIndex then
                local iconGrid = self._layerLeft._teamFormation._grid[gridIndex]
                if self._layerLeft._cloneHittedIcon then
                    if iconGrid:isStateValid() then
                        self:loadGridIcon(iconGrid, self._layerLeft._cloneHittedIcon)
                        isFormationReplaced = true
                        if self:isShowBackupTag(iconId, iconType) then
                            self._viewMgr:showTip(lang("backup_Tips3"))
                        end
                    else
                        self._layerLeft._cloneHittedIcon:removeFromParent()
                    end
                elseif self._layerLeft._hittedIcon and self._layerLeft._hittedIconGrid then
                    if self._layerLeft._hittedIconGrid:getGridIndex() == gridIndex or not iconGrid:isStateValid() then
                        self._layerLeft._hittedIconGrid:setIconView(self._layerLeft._hittedIcon)
                    elseif iconGrid:isStateFull() then
                        self:swapGridIcon(self._layerLeft._hittedIconGrid, self._layerLeft._hittedIcon, iconGrid)
                    else
                        self:moveGridIcon(self._layerLeft._hittedIconGrid, self._layerLeft._hittedIcon, iconGrid)
                    end
                end
            else
                if self._layerLeft._cloneHittedIcon then
                    self._layerLeft._cloneHittedIcon:removeFromParent()
                elseif self._layerLeft._hittedIcon then
                    self._layerLeft._hittedIconGrid:setIconView(self._layerLeft._hittedIcon)
                    --[[
                    if self:unloadGridIcon(self._layerLeft._hittedIconGrid, self._layerLeft._hittedIcon) then
                        isFormationReplaced = true
                    end
                    ]]
                end
            end
        end
    else
        if iconType == NewFormationView.kGridTypeTeam or iconType == NewFormationView.kGridTypeHireTeam then
            if self._layerLeft._cloneHittedIcon then
                self._layerLeft._cloneHittedIcon:removeFromParent()
            elseif self._layerLeft._hittedIcon then
                if self:unloadGridIcon(self._layerLeft._hittedIconGrid, self._layerLeft._hittedIcon) then
                    isFormationReplaced = true
                end
            end
        end
    end

    if self._layerLeft._isHeroFormationLayerHitted then
        if iconType == NewFormationView.kGridTypeHero then
            if self._layerLeft._cloneHittedIcon then
                self:loadGridIcon(self._layerLeft._heroFormation._grid, self._layerLeft._cloneHittedIcon)
                isFormationReplaced = true
            elseif self._layerLeft._hittedIcon then
                self._layerLeft._hittedIconGrid:setIconView(self._layerLeft._hittedIcon)
            end
        end
    else
        if iconType == NewFormationView.kGridTypeHero then
            if self._layerLeft._cloneHittedIcon then
                self._layerLeft._cloneHittedIcon:removeFromParent()
            else
                self._layerLeft._hittedIconGrid:setIconView(self._layerLeft._hittedIcon)
            end
        end
    end

    if self._layerLeft._isinsFormationLayerHitted then
        if iconType == NewFormationView.kGridTypeIns then
            local gridIndex = self:getCurrentLeftInsHittedGridIndex(self._layerLeft._mPosition)
            if 0 ~= gridIndex then
                local iconGrid = self._layerLeft._insFormation._grid[gridIndex]
                if self._layerLeft._cloneHittedIcon then
                    if iconGrid:isStateValid() then
                        self:loadGridIcon(iconGrid, self._layerLeft._cloneHittedIcon)
                        isFormationReplaced = true
                    else
                        self._layerLeft._cloneHittedIcon:removeFromParent()
                    end
                elseif self._layerLeft._hittedIcon and self._layerLeft._hittedIconGrid then
                    if self._layerLeft._hittedIconGrid:getGridIndex() == gridIndex or not iconGrid:isStateValid() then
                        self._layerLeft._hittedIconGrid:setIconView(self._layerLeft._hittedIcon)
                    end
                end
            else
                if self._layerLeft._cloneHittedIcon then
                    self._layerLeft._cloneHittedIcon:removeFromParent()
                elseif self._layerLeft._hittedIcon then
                    self._layerLeft._hittedIconGrid:setIconView(self._layerLeft._hittedIcon)
                    --[[
                    if self:unloadGridIcon(self._layerLeft._hittedIconGrid, self._layerLeft._hittedIcon) then
                        isFormationReplaced = true
                    end
                    ]]
                end
            end
        end
    else
        if iconType == NewFormationView.kGridTypeIns then
            if self._layerLeft._cloneHittedIcon then
                self._layerLeft._cloneHittedIcon:removeFromParent()
            elseif self._layerLeft._hittedIcon then
                if self:unloadGridIcon(self._layerLeft._hittedIconGrid, self._layerLeft._hittedIcon) then
                    isFormationReplaced = true
                end
            end
        end
    end

    self:updateLeftTeamFormationAddition(not (NewFormationView.kGridTypeTeam == iconType or NewFormationView.kGridTypeHireTeam == iconType))
    self:updateLeftHeroAddition(NewFormationView.kGridTypeHero ~= iconType)
    self:updateLeftInsFormationAddition(NewFormationView.kGridTypeIns ~= iconType)

    for i = 1, NewFormationView.kTeamGridCount do
        self._layerLeft._teamFormation._grid[i]:setState(FormationGrid.kStateBlank)
        self._layerLeft._teamFormation._grid[i]:updateState()
    end

    self._layerLeft._heroFormation._grid:setState(FormationGrid.kStateBlank)
    self._layerLeft._heroFormation._grid:updateState()

    for i = 1, NewFormationView.kInsMaxCount do
        self._layerLeft._insFormation._grid[i]:setState(FormationGrid.kStateBlank)
        self._layerLeft._insFormation._grid[i]:updateState()
    end

    if isFormationReplaced then
        self:updateRelative()
        self:refreshItemsTableView()
        self:updateBackupInfo()
        local gridType = self._context._gridType[self._context._formationId]
        if gridType == NewFormationView.kGridTypeTeam then
            self:updateFilterType()
        elseif gridType == NewFormationView.kGridTypeHero then
            self:updateHeroFilterType()
        end
    end
    --self:onShowDescriptionView(iconType, iconId)
    if self._layerLeft._hittedIcon and self._layerLeft._hittedIcon.onClickingEnded then
        self._layerLeft._hittedIcon:onClickingEnded()
    end
    self._layerLeft._isIconMoved = false
    self._layerLeft._cloneHittedIcon = nil
    self:disableItemTableView(false)
    self._layerLeft._isBeganFromTeamIconGrid = false
    self._layerLeft._isBeganFromHeroIconGrid = false
    self._layerLeft._isBeganFromInsIconGrid = false
    self._layerLeft._isIconHitted = false
    self._layerLeft._hittedIcon = nil
    self._layerLeft._hittedIconGrid = nil
    self:clearRelationEffect()
    self:showTipsInfo(false)
end

function NewFormationView:onLayerLeftTouchCancelled(_, x, y)
    --local position = self:convertPointToTargetNodeSpace(self._layerLeft._layerTouch, x, y)
    --print("formation touch cancelled:", x, y)

    self:onLayerLeftTouchEnded(_, x, y)
    --[[
    self._layerLeft._ePosition = cc.p(x, y)
    self:updateLayerLeftHittedState(x, y)
    if not self._layerLeft._isIconMoved then return end

    local isFormationReplaced = false

    if self._layerLeft._cloneHittedIcon then
        self._layerLeft._cloneHittedIcon:removeFromParent()
    elseif self._layerLeft._hittedIcon then
        if self:unloadGridIcon(self._layerLeft._hittedIconGrid, self._layerLeft._hittedIcon) then
            isFormationReplaced = true
        end
    end

    self:updateLeftTeamFormationAddition()
    for i = 1, NewFormationView.kTeamGridCount do
        self._layerLeft._teamFormation._grid[i]:setState(FormationGrid.kStateBlank)
        self._layerLeft._teamFormation._grid[i]:updateState()
    end

    self._layerLeft._heroFormation._grid:setState(FormationGrid.kStateBlank)
    self._layerLeft._heroFormation._grid:updateState()

    if isFormationReplaced then
        self:updateRelative()
        self:refreshItemsTableView()
    end

    self._layerLeft._isIconMoved = false
    self._layerLeft._cloneHittedIcon = nil
    self:disableItemTableView(false)
    self._layerLeft._isBeganFromTeamIconGrid = false
    self._layerLeft._isBeganFromHeroIconGrid = false
    self._layerLeft._isBeganFromInsIconGrid = false
    self._layerLeft._isIconHitted = false
    self._layerLeft._hittedIcon = nil
    self._layerLeft._hittedIconGrid = nil
    ]]
end

function NewFormationView:getCurrentRightHittedGridIndex(position)
    local gridIndex = 0
    for i = 1, NewFormationView.kTeamGridCount do
        if self._layerRight._teamFormation._grid[i]:isScreenPointInNodeRect(position.x, position.y) then
            gridIndex = i
            break
        end
    end
    return gridIndex
end

function NewFormationView:resetAllRightState()
    for i = 1, NewFormationView.kTeamGridCount do
        self._layerRight._teamFormation._gridSelected[i]:setVisible(false)
    end

    self._layerRight._heroFormation._gridSelected:setVisible(false)
end

function NewFormationView:updateLayerRightHittedState(x, y)
    self._layerRight._isteamFormationLayerHitted = self._layerRight._teamFormation._layer:isScreenPointInNodeRect(x, y)
    self._layerRight._isHeroFormationLayerHitted = self._layerRight._heroFormation._layer:isScreenPointInNodeRect(x, y)
end

function NewFormationView:onLayerRightTouchBegan(_, x, y)
    self:resetAllRightState()
    return true
end

function NewFormationView:onLayerRightTouchMoved(_, x, y)
    
end

function NewFormationView:onLayerRightTouchEnded(_, x, y)
    self:updateLayerRightHittedState(x, y)
    if self._layerRight._isteamFormationLayerHitted then
        local isGridFull = function(gridIndex)
            if not self:isShowEnemyFormation() then return false end
            for k, v in pairs(self._enemyFormationData[self._context._formationId]) do
                repeat
                    if 0 == v then break end
                    if string.find(tostring(k), "g") and v == gridIndex then
                        if 0 ~= self._enemyFormationData[self._context._formationId][string.format("team%d", tonumber(string.sub(tostring(k), -1)))] then
                            return true
                        end
                    end
                until true
            end

            return false
        end
        local gridIndex = self:getCurrentRightHittedGridIndex(cc.p(x, y))
        if 0 ~= gridIndex then
            local iconGrid = self._layerRight._teamFormation._grid[gridIndex]
            if isGridFull(gridIndex) then
                self._layerRight._teamFormation._gridSelected[gridIndex]:setVisible(true)
                self._layerRight._hittedIconGrid = iconGrid
            end
        end
    elseif self._layerRight._isHeroFormationLayerHitted then
        if self._enemyFormationData[self._context._formationId].heroId ~= NewFormationView.kNullHeroId then
            self._layerRight._heroFormation._gridSelected:setVisible(true)
            self._layerRight._hittedIconGrid = self._layerRight._heroFormation._grid
        end
    end
    if self._layerRight._hittedIconGrid then
        local iconView = self._layerRight._hittedIconGrid:getChildByTag(NewFormationView.kRightFormationTag)
        if iconView then
            self:onShowDescriptionView(iconView:getIconType(), iconView:getIconId(), iconView:getIconSubtype(), iconView:isChangedProfile(), iconView:getChangedId())
        end
    end
    self._layerRight._isIconHitted = false
    self._layerRight._cloneHittedIcon = nil
    self._layerRight._hittedIconGrid = nil
end

function NewFormationView:onLayerRightTouchCancelled(_, x, y)
    
end

function NewFormationView:showItemFlag(item)
    local found = false
    local itemType = item:getIconType()
    local itemId = item:getIconId()

    if self:isFiltered(itemId) then return false end

    if not self:isShowCloudInfo() then
        item:showBackupTag(self:isShowBackupTag(itemId, itemType))
        return 
    end

    local formationId = self._formationModel.kFormationTypeCloud1 + self._formationModel.kFormationTypeCloud2 - self._context._formationId
    local formationData = self._layerLeft._teamFormation._data[formationId]
    if itemType == NewFormationView.kGridTypeTeam then
        for k, v in pairs(formationData) do
            repeat 
                if 0 == v then break end
                if string.find(tostring(k), "team") and not string.find(tostring(k), "g") and v == itemId then
                    found = true
                end
            until true
            if found then break end
        end
    else
        found = 0 ~= formationData.heroId and itemId == formationData.heroId
    end

    if not found then 
        item:showRedFlag(false)
        item:showBlueFlag(false)
        item:showBackupTag(self:isShowBackupTag(itemId, itemType))
        return 
    end

    if self._context._formationId == self._formationModel.kFormationTypeCloud1 then
        item:showRedFlag(true)
        item:showBlueFlag(false)
    else
        item:showRedFlag(false)
        item:showBlueFlag(true)
    end
end

function NewFormationView:setTableViewItemSelected(item, selected)
    local imageSelected = item:getChildByName("imageSelected")
    if not imageSelected then
        local imageSelected = ccui.ImageView:create("globalImageUI4_selectFrame.png", 1)
        imageSelected:setName("imageSelected")
        imageSelected:setContentSize(cc.size(110, 110))
        if NewFormationView.kGridTypeHero == self._context._gridType[self._context._formationId] then
            imageSelected:setScale(1.0)
            imageSelected:setPosition(cc.p(item:getContentSize().width / 2 - 2, item:getContentSize().height / 2 - 2))
        elseif NewFormationView.kGridTypeHireTeam == self._context._gridType[self._context._formationId] then
            imageSelected:setScale(0.9)
            imageSelected:setPosition(cc.p(item:getContentSize().width / 2 - 5, item:getContentSize().height / 2 + 10))
        elseif NewFormationView.kGridTypeIns == self._context._gridType[self._context._formationId] then
            imageSelected:setScale(1.0)
            imageSelected:setPosition(cc.p(item:getContentSize().width / 2 + 4, item:getContentSize().height / 2 + 3))
        else
            imageSelected:setScale(1.0)
            imageSelected:setPosition(cc.p(item:getContentSize().width / 2 + 2, item:getContentSize().height / 2 + 2))
        end
        imageSelected:ignoreContentAdaptWithSize(false)
        imageSelected:setVisible(selected)
        item:addChild(imageSelected)
    else
        imageSelected:setVisible(selected)
    end

    if selected and not self._layerLeft._layerList._isIconMoved then
        local isCustom = false
        local isLocal = false
        if item:getIconType() == NewFormationView.kGridTypeTeam then
            isCustom = self:isTeamCustom(item:getIconId())
            isLocal = self:isTeamLocal(item:getIconId())
        else
            isCustom = self:isHeroCustom(item:getIconId())
            isLocal = self:isHeroLocal(item:getIconId())
        end
        self:onShowDescriptionView(item:getIconType(), item:getIconId(), item:getIconSubtype(), nil, nil, isCustom, isLocal)
    end
end

function NewFormationView:itemsTableViewDidScroll()
    local offset = self._layerLeft._layerList._itemsTableView:getContentOffset().x
    local minOffset = self._layerLeft._layerList._itemsTableView:minContainerOffset().x
    local maxOffset = self._layerLeft._layerList._itemsTableView:maxContainerOffset().x
    self._layerLeft._layerList._layerLeftArrow:setVisible((offset <= maxOffset - 100) and #self:getCurrentIconData() > self:getIcontCount())
    self._layerLeft._layerList._layerRightArrow:setVisible((offset >= minOffset + 100) and #self:getCurrentIconData() > self:getIcontCount())
end

function NewFormationView:itemsTableViewCellTouched(tableView, cell)
    --self._context._listOffset[self._context._formationId][self._context._gridType[self._context._formationId]] = self._layerLeft._layerList._itemsTableView:getContentOffset()
    local data = self:getCurrentIconData()
    for idx=1, #data do
        repeat
            local oneCell = self._layerLeft._layerList._itemsTableView:cellAtIndex(idx-1)
            if not oneCell then break end
            local item = oneCell:getChildByTag(NewFormationView.kItemTag)
            if item then self:setTableViewItemSelected(item, oneCell == cell) end
        until true
    end
end

function NewFormationView:itemsTableViewCellSizeForTable(tableView, idx)
    if self._context._gridType[self._context._formationId] == NewFormationView.kGridTypeHero then
        return 100, 118
    else
        return 100, 103
    end
end

function NewFormationView:itemsTableViewCellAtIndex(tableView, idx)
    local cell = tableView:dequeueCell()
    local data = self:getCurrentIconData()
    local iconType = self._context._gridType[self._context._formationId]
    local iconId = data[idx + 1].id
    if nil == cell then
        cell = cc.TableViewCell:new()
        local item = NewFormationIconView.new({iconType = iconType, iconId = iconId, iconSubtype = data[idx + 1].teamSubtype, iconState = NewFormationIconView.kIconStateImage, formationType = self._formationType, isCustom = data[idx + 1].custom, isScenarioHero = self:isScenarioHero(iconId), container = self})
        item:setPosition(iconType == NewFormationView.kGridTypeHero and cc.p(55, 60) or cc.p(55, 50))
        item:setTag(NewFormationView.kItemTag)
        if iconType ~= NewFormationView.kGridTypeHireTeam and iconType ~= NewFormationView.kGridTypeIns then
            item:showFilter(self:isFiltered(iconId))
            item:showRecommand(self:isRecommend(iconId))
        end
        -- if not self:isFiltered(iconId) then
        --     item:showBackupTag(self:isShowBackupTag(iconId, iconType))
        -- end
        if iconType == NewFormationView.kGridTypeHero then
            item:showScenarioHero(self:isScenarioHero(iconId))
        end
        if iconType == NewFormationView.kGridTypeHireTeam then
            item:showLimit(self:isHireTeamLevelLimit(data[idx + 1]))
            item:showUsed(not self:isHireTeamCanUsed(data[idx + 1]))
        end
        self:showItemFlag(item)
        item:updateState(NewFormationIconView.kIconStateImage, true)
        item:setName("item_"..idx)
        cell:setName("cell_"..idx)
        cell:addChild(item)
    else
        local item = cell:getChildByTag(NewFormationView.kItemTag)
        item:setIconId(iconId)
        item:setIconSubtype(data[idx + 1].teamSubtype)
        if iconType ~= NewFormationView.kGridTypeHireTeam and iconType ~= NewFormationView.kGridTypeIns then
            item:showFilter(self:isFiltered(iconId))
            item:showRecommand(self:isRecommend(iconId))
        end
        -- if not self:isFiltered(iconId) then
        --     item:showBackupTag(self:isShowBackupTag(iconId, iconType))
        -- end
        if iconType == NewFormationView.kGridTypeHero then
            item:showScenarioHero(self:isScenarioHero(iconId))
        end
        if iconType == NewFormationView.kGridTypeHireTeam then
            item:showLimit(self:isHireTeamLevelLimit(data[idx + 1]))
            item:showUsed(not self:isHireTeamCanUsed(data[idx + 1]))
        end
        self:showItemFlag(item)
        item:setCustom(data[idx + 1].custom)
        item:setScenarioHero(self:isScenarioHero(iconId))
        item:updateState(NewFormationIconView.kIconStateImage, true)
    end
    return cell
end

function NewFormationView:numberOfCellsInItemsTableView(tableView)
    return #self:getCurrentIconData()
end

function NewFormationView:isSaveRequired(formationId)
    if self._extend and self._extend.isSimpleFormation then
        return
    end
    formationId = formationId or self._context._formationId
    local ta = self._formationModel:getFormationData()[formationId]
    local tb = self._layerLeft._teamFormation._data[formationId]
    if table.nums(ta) ~= table.nums(tb) then return true end
    local keys = table.keys(ta)
    for _, v in pairs(keys) do
        repeat
            if not string.find(v, "team") and not string.find(v, "g") then break end
            if tb[v] ~= ta[v] then
                return true
            end
        until true
    end

    if ta.heroId ~= tb.heroId then
        return true
    end

    if ta.tid ~= tb.tid then
        return true
    end

    if not self:isHaveFixedWeapon() then
        for i=1, 4 do
            if ta["weapon" .. i] ~= tb["weapon" .. i] then
                return true
            end
        end
    end

    if self._formationModel:isFormationDataChanged(formationId) then
        return true
    end

    if self:isShowHireTeam() and self:isHireTeamLoaded() then
        return true
    end

    if table.indexof(self._formationModel.kBackupFormation, self._context._formationId) then
        if ta.bid ~= tb.bid then
            return true
        end

        local backupData = clone(tab.backupMain)
        local taBackupTs = ta.backupTs or {}
        local tbBackupTs = tb.backupTs or {}
        for k, v in pairs(backupData) do
            local data1 = taBackupTs[tostring(v.id)] or {}
            local data2 = tbBackupTs[tostring(v.id)] or {}
            if data1["bt1"] ~= data2["bt1"] then
                return true
            end
            if data1["bt2"] ~= data2["bt2"] then
                return true
            end
            if data1["bt3"] ~= data2["bt3"] then
                return true
            end
            if data1["bpos"] ~= data2["bpos"] then
                return true
            end
        end
    end

    return false
end

function NewFormationView:doSimpleClose()
    local formationData = self._layerLeft._teamFormation._data[self._context._formationId]
    local idList = {}
    for i=1, NewFormationView.kTeamMaxCount do
        local numID = tonumber(formationData["team" .. i])
        if numID ~= 0 then
            idList[#idList+1] = numID
        end
    end
    if #idList < 8 then
        --[[self._viewMgr:showDialog("global.GlobalSelectDialog",
                        {desc = lang("hero_comment_4"),
                        alignNum = 1,
                        callback1 = function ()
                            self:doClose()
                        end,
                        callback2 = function()
                        end},true) --]]
        self._viewMgr:showTip(lang("hero_comment_4"))
        return
    end
    if self._closeCallBack then
        local closeFormation = function()
            self:doClose()
        end
        self._closeCallBack(idList, closeFormation)
    end
--    self:doClose()
end

function NewFormationView:onCloseButtonClicked()
    if not self:isShowCloudInfo() then
        if self._extend and self._extend.isSimpleFormation then
                self._viewMgr:showDialog("global.GlobalSelectDialog",
                        {desc = lang("hero_comment_7"),
                        alignNum = 1,
                        callback1 = function ()
                           self:doSimpleClose()
                        end,
                        callback2 = function()
                            self:doClose()
                        end},true)    
        else
            self:doClose()
        end
    else
        if self._extend.isShowCloseTips then
            self._viewMgr:showSelectDialog(lang("towertip_3"), "", function()
                self:doCloudClose()
            end, "")
        else
            self:doCloudClose()
        end
    end
end

function NewFormationView:doClose()
    --[[
    -- version 2.0
    local teamLoadedCount = self:getCurrentLoadedTeamCount()
    if teamLoadedCount <= 0 then
        self._viewMgr:showNotificationDialog(lang("TIP_BUZHEN_1"))
        return 
    end
    ]]
    if self._musicFileName then
        audioMgr:playMusic(self._musicFileName, true)
    end
    if self:isSaveRequired() then
        self._viewMgr:showTip(lang("TIPS_BAOCUNBUZHEN"))
        self:doSave(function (success)
            if not success then
                self._viewMgr:showTip(lang("TIP_BUZHEN_3"))
            end
            if self._closeCallBack and type(self._closeCallBack) == "function" then
                self._closeCallBack(self:isScenarioHero(self._layerLeft._teamFormation._data[self._context._formationId].heroId))
            end
            self:close()
        end)
    else
        if self._closeCallBack and type(self._closeCallBack) == "function" then
            self._closeCallBack(self:isScenarioHero(self._layerLeft._teamFormation._data[self._context._formationId].heroId))
        end
        self:close()
    end
end

function NewFormationView:doCloudClose()
    if self._musicFileName then
        audioMgr:playMusic(self._musicFileName, true)
    end
    local formationId1 = self._context._formationId
    local formationId2 = self._formationModel.kFormationTypeCloud1 + self._formationModel.kFormationTypeCloud2 - formationId1
    if self:isSaveRequired(formationId1) or self:isSaveRequired(formationId2) then
        self._viewMgr:showTip(lang("TIPS_BAOCUNBUZHEN"))
        self:doCloudSave(function (success)
            if not success then
                self._viewMgr:showTip(lang("TIP_BUZHEN_3"))
            end
            if self._closeCallBack and type(self._closeCallBack) == "function" then
                self._closeCallBack()
            end
            self:close()
        end)
    else
        if self._closeCallBack and type(self._closeCallBack) == "function" then
            self._closeCallBack()
        end
        self:close()
    end
end

function NewFormationView:onButtonEditInfoClicked(  )
    if self:isFormationLocked() then return end
    -- 改变宝物编组前先保存编组

    local formationData = self._layerLeft._teamFormation._data[self._context._formationId]
    local pFormation = self._pokedexModel:getPFormation()
    self._formationModel:showFormationEditView({
        isShowTreasure = self:isShowTreasureInfo(),
        isShowPokedex = self:isShowPokedexInfo(),
        tFormId = formationData.tid or 1,
        formationId = self._context._formationId,
        pokedexData = pFormation,
        hireTeamData = self:getUsingHireTeamData(),
        callback = function ( formId )
            formationData.tid = formId
            self:updateRelative()
            -- self:updatePokedexInfo(true)
            -- self:updateTreasureInfo(true)
        end,
        fieldCallback = function ( areaSkillTeam )
            formationData.areaSkillTeam = areaSkillTeam
        end
    })
end

-- function NewFormationView:onButtonChangeTreasureClicked()
--     if self:isFormationLocked() then return end
--     if not self:isShowCloudInfo() then
--         self:doChangeTreasureClicked()
--     else
--         self:doChangeCloudTreasureClicked()
--     end
-- end

-- function NewFormationView:doChangeTreasureClicked()
--     local changeTFormFunc = function( )
--         local formationData = self._layerLeft._teamFormation._data[self._context._formationId]
--         self._viewMgr:showDialog("treasure.TreasureSelectFormDialog",{
--             tFormId = formationData.tid or 1,
--             formationId = self._context._formationId,
--             callback = function( formId )
--                 -- self._layerLeft._teamFormation._data = clone(self._formationModel:getFormationData())
--                 -- self._layerLeft._teamFormation._allowLoadCount = self:getCurrentAllowLoadCount()
--                 formationData.tid = formId
--                 self:updateTreasureInfo(true)
--             end})
--     end
--     -- 改变宝物编组前先保存编组
--     if self:isSaveRequired() then
--         self:doSave(function(success)
--             if not success then
--                 self._viewMgr:showTip(lang("TIP_BUZHEN_3"))
--                 return
--             end
--             changeTFormFunc()
--         end)
--     else
--         changeTFormFunc()
--     end
-- end

-- function NewFormationView:doChangeCloudTreasureClicked()
--     local changeTFormFunc = function( )
--         local formationData = self._layerLeft._teamFormation._data[self._context._formationId]
--         self._viewMgr:showDialog("treasure.TreasureSelectFormDialog",{
--             tFormId = formationData.tid or 1,
--             formationId = self._context._formationId,
--             callback = function( formId )
--                 -- self._layerLeft._teamFormation._data = clone(self._formationModel:getFormationData())
--                 -- self._layerLeft._teamFormation._allowLoadCount = self:getCurrentAllowLoadCount()
--                 formationData.tid = formId
--                 self:updateTreasureInfo(true)
--             end})
--     end
--     -- 改变宝物编组前先保存编组
--     local formationId1 = self._context._formationId
--     local formationId2 = self._formationModel.kFormationTypeCloud1 + self._formationModel.kFormationTypeCloud2 - formationId1
--     if self:isSaveRequired(formationId1) or self:isSaveRequired(formationId2) then
--         self:doCloudSave(function(success)
--             if not success then
--                 self._viewMgr:showTip(lang("TIP_BUZHEN_3"))
--                 return
--             end
--             changeTFormFunc()
--         end)
--     else
--         changeTFormFunc()
--     end
-- end

function NewFormationView:onBattleButtonClicked()
    if self:isShowCloudInfo() then
        local formationId1 = self._context._formationId
        local formationId2 = self._formationModel.kFormationTypeCloud1 + self._formationModel.kFormationTypeCloud2 - formationId1
        if self:isSaveRequired(formationId1) or self:isSaveRequired(formationId2) then
            self:doCloudSave(function(success)
                if not success then
                    self._viewMgr:showTip(lang("TIP_BUZHEN_3"))
                    return
                end
                self:doCloudBattle()
            end)
            return
        end
        self:doCloudBattle()
    elseif self:isShowStakeAtkDef2() then
        local formationId1 = self._context._formationId
        local formationId2 = self._formationModel.kFormationTypeStakeAtk2 + self._formationModel.kFormationTypeStakeDef2 - formationId1
        if self:isSaveRequired(formationData1) then
            self:doSave(function ( success )
                if not success then
                    self._viewMgr:showTip("TIP_BUZHEN_3")
                    return
                end
                self:doStakeBattle()
            end)
            return
        end
        self:doStakeBattle()
    else
        if self:isSaveRequired() then
            self:doSave(function(success)
                if not success then
                    self._viewMgr:showTip(lang("TIP_BUZHEN_3"))
                    return
                end
                self:doBattle()
            end)
            return
        end
        self:doBattle()
    end
end

function NewFormationView:isCanBattle()
    if self._modelMgr:getModel("AdventureModel"):inResetTime() then
        return false
    end
    return true
end

function NewFormationView:doBattle()

    if self._formationType == self._formationModel.kFormationTypeAdventure and not self:isCanBattle() then
        self._viewMgr:showTip("小骷髅正在准备开启新的冒险，还请耐心等待一会哦~")
        return 
    end

    if 0 == self:getCurrentLoadedTeamCountWithFilter() then
        self._viewMgr:showTip(lang("TIP_BUZHEN_MEIREN"))
        return
    end

    if self:isLoadedHeroNull() then
        self._viewMgr:showTip(lang("towertip_4"))
        return
    end

    local battle = function()
        local battleData = self._formationModel:initBattleData(self._formationType, clone(self._layerLeft._teamFormation._data[self._context._formationId]))
        if self._battleCallBack and type(self._battleCallBack) == "function" then
            self._battleCallBack(battleData[1], 
                self:getCurrentLoadedTeamCountWithFilter(), 
                self:getCurrentTeamFilterCount(), 
                self._context._formationId, 
                self:isScenarioHero(self._layerLeft._teamFormation._data[self._context._formationId].heroId), 
                self:hireTeamLoadedPosition(),
                self:getLoadedHireTeam())
        end
    end

    local beforeBattle = function()
        audioMgr:playSound("enterBattle")
        if self._extend.physical then
            self._viewMgr:lock(9999)
            local nodes = {}
            nodes[1] = cc.Sprite:createWithSpriteFrameName("globalImageUI4_power.png")
            nodes[2] = cc.Label:createWithTTF("-" .. self._extend.physical, UIUtils.ttfName, 24)
            nodes[2]:setColor(cc.c4b(90, 248, 13, 255))
            nodes[2]:enableOutline(cc.c4b(0, 0, 0,255), 2)
            local node = UIUtils:createHorizontalNode(nodes)
            node:setAnchorPoint(cc.p(0.5, 0.5))
            node:setPosition(self._btnBattle:getPositionX(), self._btnBattle:getPositionY() + 20)
            self._btnBattle:getParent():addChild(node, 100)
            node:setCascadeOpacityEnabled(true, true)
            node:setOpacity(0)
            node:runAction(cc.Sequence:create(
                cc.Spawn:create(cc.MoveBy:create(0.05, cc.p(0, 30)), cc.FadeIn:create(0.05)),
                cc.MoveBy:create(0.3, cc.p(0, 30)),
                cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(0, 30)), cc.FadeOut:create(0.2)),
                cc.CallFunc:create(function()
                    node:removeFromParent()
                    self._viewMgr:unlock()
                    battle()
            end)))
        elseif self:isShowReadyBattle() then
            self:updateLeagueBattleInfo()
        else
            battle()
        end
    end

    if not self:isTeamLoadedFull() and self:isShowBattleTip() and not self._formationModel.getFormationDialogShowed() then
        self._formationModel.setFormationDialogShowed(true)
        self._viewMgr:showSelectDialog(lang("TIP_YINDAOBUZHEN_BUMAN"), "", function()
            beforeBattle()
        end, "")
    elseif self._formationModel:isFieldSkillEmpty(self._formationType, self:getUsingHireTeamData()) and not self._formationModel:isShowFieldDialogByType(self._formationType) then
        self._formationModel:setShowFieldDialogByType(self._formationType)
        self._viewMgr:showSelectDialog(lang("LINGYUTIPS_COMMON"), "", function()
            beforeBattle()
        end, "")
    else
        beforeBattle()
    end
    
end

function NewFormationView:doCloudBattle()
    --[[
    if self:isShowCloudInfo() and not self._extend.allowBattle[self._context._formationId] then
        self._viewMgr:showTip("您已经获得该场战斗的胜利，点击重置可以重新挑战。请策划配表")
        return
    end
    ]]
    if self:isCloudCurrentLoadedTeamEmpty() then
        self._viewMgr:showTip(lang("towertip_11"))
        return
    end

    if self:isCloudLoadedHeroNull() then
        self._viewMgr:showTip(lang("towertip_4"))
        return
    end

    local battle = function()
        local formationId1 = self._formationModel.kFormationTypeCloud1
        local formationData1 = self._layerLeft._teamFormation._data[formationId1]
        local formationId2 = self._formationModel.kFormationTypeCloud2
        local formationData2 = self._layerLeft._teamFormation._data[formationId2]
        local battleData1 = self._formationModel:initBattleData(formationId1, clone(formationData1))
        local battleData2 = self._formationModel:initBattleData(formationId2, clone(formationData2))
        if self._battleCallBack and type(self._battleCallBack) == "function" then
            self._battleCallBack(formationId1, battleData1[1], formationId2, battleData2[1])
        end
    end
    if not self:isTeamLoadedFull() and self:isShowBattleTip() and not self._formationModel.getFormationDialogShowed() then
        self._formationModel.setFormationDialogShowed(true)
        self._viewMgr:showSelectDialog(lang("TIP_YINDAOBUZHEN_BUMAN"), "", function()
            battle()
        end, "")
    elseif self._formationModel:isFieldSkillEmpty(self._formationModel.kFormationTypeCloud1, self:getUsingHireTeamData()) and not self._formationModel:isShowFieldDialogByType(self._formationModel.kFormationTypeCloud1) then
        self._formationModel:setShowFieldDialogByType(self._formationModel.kFormationTypeCloud1)
        self._viewMgr:showSelectDialog(lang("LINGYUTIPS_LIGHT"), "", function()
            battle()
        end, "")
    elseif self._formationModel:isFieldSkillEmpty(self._formationModel.kFormationTypeCloud2, self:getUsingHireTeamData()) and not self._formationModel:isShowFieldDialogByType(self._formationModel.kFormationTypeCloud2) then
        self._formationModel:setShowFieldDialogByType(self._formationModel.kFormationTypeCloud2)
        self._viewMgr:showSelectDialog(lang("LINGYUTIPS_DARK"), "", function()
            battle()
        end, "")
    else
        if self._backupModel:isOpen() then
            local teamUsing = self:getUsingTeamList()
            local formationId1 = self._formationModel.kFormationTypeCloud1
            local formationData1 = self._layerLeft._teamFormation._data[formationId1]
            local formationId2 = self._formationModel.kFormationTypeCloud2
            local formationData2 = self._layerLeft._teamFormation._data[formationId2]
            local isHaveConflictTeam1 = self._backupModel:isHaveConflictTeam(formationData1.backupTs, formationData1.bid, clone(teamUsing))
            local isHaveConflictTeam2 = self._backupModel:isHaveConflictTeam(formationData2.backupTs, formationData2.bid, clone(teamUsing))
            if isHaveConflictTeam1 or isHaveConflictTeam2 then
                self._viewMgr:showSelectDialog(lang("backup_Tips8"), "", function (  )
                    battle()
                end, "")
                return
            end
            local isHaveEmptySeat1 = self._backupModel:isHaveEmptySeat(formationData1.backupTs, formationData1.bid, {}, clone(teamUsing))
            local isHaveEmptySeat2 = self._backupModel:isHaveEmptySeat(formationData2.backupTs, formationData2.bid, {}, clone(teamUsing))
            if isHaveEmptySeat1 or isHaveEmptySeat2 then
                self._viewMgr:showSelectDialog(lang("backup_Tips9"), "", function (  )
                    battle()
                end, "")
                return
            end
        end
        battle()
    end
end

function NewFormationView:doStakeBattle(  )
    if not self:isStakeCurrentLoadedTeamEmpty() then
        self._viewMgr:showTip(lang("STAKE_USER2_TIPS"))
        return
    end

    if not self:isStakeLoadedHeroNull() then
        self._viewMgr:showTip(lang("STAKE_USER1_TIPS"))
        return
    end

    local battle = function()
        local formationId1 = self._formationModel.kFormationTypeStakeAtk2
        local formationData1 = self._layerLeft._teamFormation._data[formationId1]
        local formationId2 = self._formationModel.kFormationTypeStakeDef2
        local formationData2 = self._layerLeft._teamFormation._data[formationId2]
        local battleData1 = self._formationModel:initBattleData(formationId1, clone(formationData1))
        local battleData2 = self._formationModel:initBattleData(formationId2, clone(formationData2))
        if self._battleCallBack and type(self._battleCallBack) == "function" then
            self._battleCallBack(formationId1, battleData1[1], formationId2, battleData2[1])
        end
    end

    if self._formationModel:isFieldSkillEmpty(self._formationModel.kFormationTypeStakeAtk2, self:getUsingHireTeamData()) and not self._formationModel:isShowFieldDialogByType(self._formationModel.kFormationTypeStakeAtk2) then
        self._formationModel:setShowFieldDialogByType(self._formationModel.kFormationTypeStakeAtk2)
        self._viewMgr:showSelectDialog(lang("LINGYUTIPS_ATTACK"), "", function()
            battle()
        end, "")
    elseif self._formationModel:isFieldSkillEmpty(self._formationModel.kFormationTypeStakeDef2, self:getUsingHireTeamData()) and not self._formationModel:isShowFieldDialogByType(self._formationModel.kFormationTypeStakeDef2) then
        self._formationModel:setShowFieldDialogByType(self._formationModel.kFormationTypeStakeDef2)
        self._viewMgr:showSelectDialog(lang("LINGYUTIPS_DEFEND"), "", function()
            battle()
        end, "")
    else
        battle()
    end

    -- if not self:isTeamLoadedFull() and self:isShowBattleTip() and not self._formationModel.getFormationDialogShowed() then
    --     self._formationModel.setFormationDialogShowed(true)
    --     self._viewMgr:showSelectDialog(lang("TIP_YINDAOBUZHEN_BUMAN"), "", function()
    --         battle()
    --     end, "")
    -- else
    -- end
end

function NewFormationView:doSave(callback)
    self._formationModel:saveData(clone(self._layerLeft._teamFormation._data[self._context._formationId]), self._context._formationId, self:isScenarioHero(self._layerLeft._teamFormation._data[self._context._formationId].heroId), self:getLoadedHireTeam(), self:isHaveFixedWeapon(), callback)
end

function NewFormationView:doCloudSave(callback)
    local formationId1 = self._context._formationId
    local formationData1 = self._layerLeft._teamFormation._data[formationId1]
    local formationId2 = self._formationModel.kFormationTypeCloud1 + self._formationModel.kFormationTypeCloud2 - formationId1
    local formationData2 = self._layerLeft._teamFormation._data[formationId2]
    local isFormation1Changed = self:isSaveRequired(formationId1)
    local isFormation2Changed = self:isSaveRequired(formationId2)
    self._formationModel:saveMultipleData(isFormation1Changed and formationData1 or nil, isFormation1Changed and formationId1 or 0, isFormation2Changed and formationData2 or nil, isFormation2Changed and formationId2 or 0, callback)
end

function NewFormationView:onNextFightButtonClicked()
    if self:isShowNextFight() then
        self:switchCloudFormation()
    end
end

function NewFormationView:onShowDescriptionView(iconType, iconId, iconSubtype, isChanged, changedId, isCustom, isLocal)
    if self:isFormationLocked() then return end
    if not self:isShowDescriptionView(iconType) then return end
    if iconType == NewFormationIconView.kIconTypeIns then
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
        if self:isHaveFixedWeapon() then
            local weaponTableData = tab:SiegeWeaponNpc(iconId)
            if weaponTableData then
                weaponData.lv = weaponTableData.lv
                for i=1, 4 do
                    if weaponTableData["equip" .. i] then
                        weaponData["sp" .. i] = {id = weaponTableData["equip" .. i][1], lv = weaponTableData["equip" .. i][2], score = weaponTableData.score}
                    end
                end
                weaponData.ss1 = weaponTableData.skill
                weaponData.ss2 = weaponTableData.skill1
            end
        else
            weaponData = clone(self._weaponsModel:getWeaponsDataByType(iconSubtype))
            if weaponData then
                for i=1, 4 do
                    local sp = weaponData["sp" .. i]
                    if 0 ~= sp then
                        local propsData = self._weaponsModel:getPropsDataByKey(sp)
                        if propsData then
                            weaponData["sp" .. i] = {id = propsData.id, lv = propsData.lv, score = propsData.score}
                        end
                    else
                        weaponData["sp" .. i] = {}
                    end
                end
            end
        end
        self._viewMgr:showDialog("rank.RankWeaponsDetailView", {userWeapon = weaponData, weaponId = iconId, weaponType = iconSubtype}, true)
    else
        self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = iconType, iconId = iconId, iconSubtype = iconSubtype, isChanged = isChanged, changedId = changedId, formationType = self._formationType, isCustom = isCustom, isLocal = isLocal,purgatoryId = self._extend.purgatoryId}, true)
    end
end

function NewFormationView:onShowFormationSelectView(params)
    --self._viewMgr:showDialog("formation.NewFormationSelectView", params, true)
end

function NewFormationView:switchFormation(formationId)
    -- version 2.0
    if self._context._formationId == formationId then return end
    
    local doSwitchFormation = function()
        self._context._formationId = formationId
        self._layerLeft._teamFormation._data = clone(self._formationModel:getFormationData())
        self._layerLeft._teamFormation._allowLoadCount = self:getCurrentAllowLoadCount()
        self:updateUI()
    end
    
    if self:isSaveRequired() then
        self._viewMgr:lock(-1)
        self:doSave(function(success)
            if not success then
                self._viewMgr:showTip(lang("TIP_BUZHEN_3"))
                return
            end
            doSwitchFormation()
            self._viewMgr:unlock()
        end)
    else
        self._viewMgr:lock(-1)
        doSwitchFormation()
        self._viewMgr:unlock()
    end
end

function NewFormationView:switchCloudFormation()

    if self:isSwitchFormationButtonDisabled() then
        self._viewMgr:showTip(lang("towertip_12"))
        return
    end

    local formationId1 = self._context._formationId
    local formationId2 = self._formationModel.kFormationTypeCloud1 + self._formationModel.kFormationTypeCloud2 - formationId1

    if self._context._formationId == formationId2 then return end
    
    local doSwitchFormation = function()
        self._context._formationId = formationId2
        self._layerLeft._teamFormation._data = clone(self._formationModel:getFormationData())
        self._layerLeft._teamFormation._allowLoadCount = self:getCurrentAllowLoadCount()
        self:updateUI()
    end
    
    if self:isSaveRequired(formationId1) or self:isSaveRequired(formationId2) then
        self._viewMgr:lock(-1)
        self:doCloudSave(function(success)
            if not success then
                self._viewMgr:showTip(lang("TIP_BUZHEN_3"))
                return
            end
            doSwitchFormation()
            self._viewMgr:unlock()
        end)
    else
        self._viewMgr:lock(-1)
        doSwitchFormation()
        self._viewMgr:unlock()
    end
end

function NewFormationView:switchStakeFormation(  )
    local formationId1 = self._context._formationId
    local formationId2 = self._formationModel.kFormationTypeStakeAtk2 + self._formationModel.kFormationTypeStakeDef2 - formationId1

    if self._context._formationId == formationId2 then return end

    local doSwitchFormation = function (  )
        self._context._formationId = formationId2
        self._layerLeft._teamFormation._data = clone(self._formationModel:getFormationData())
        self._layerLeft._teamFormation._allowLoadCount = self:getCurrentAllowLoadCount()
        self:updateUI()

        for i = 1, NewFormationView.kTeamGridCount do
            local iconTeamGrid = self._layerLeft._teamFormation._grid[i]
            if iconTeamGrid:isStateFull() then
                iconTeamGrid:onLoaded()
            end
        end

        local iconGrid = self._layerLeft._heroFormation._grid
        if iconGrid:isStateFull() then
            iconGrid:onLoaded()
        end

        for i = 1, NewFormationView.kInsMaxCount do
            local iconGrid = self._layerLeft._insFormation._grid[i]
            if iconGrid:isStateFull() then
                iconGrid:onLoaded()
            end
        end
    end

    if self:isSaveRequired(formationId1) or self:isSaveRequired(formationId2) then
        self._viewMgr:lock(01)
        self:doSave(function ( success )
            if not success then
                self._viewMgr:showTip(lang("TIP_BUZHEN_3"))
                return
            end
            doSwitchFormation()
            self._viewMgr:unlock()
        end)
    else
        self._viewMgr:lock(-1)
        doSwitchFormation()
        self._viewMgr:unlock()
    end
end

function NewFormationView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

return NewFormationView
