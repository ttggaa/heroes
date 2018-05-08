--[[
    Filename:    NewNewFormationSelectView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-02-29 11:26:33
    Description: File description
--]]

local NewFormationView = require("game.view.formation.NewFormationView")
local FormationIconView = require("game.view.formation.FormationIconView")
local NewFormationSelectView = class("NewFormationSelectView", BasePopView)


NewFormationSelectView.kFormationTag = 1000
NewFormationSelectView.kFormationTeamTag = 2000

NewFormationSelectView.kNormalZOrder = 500
NewFormationSelectView.kLessNormalZOrder = NewFormationSelectView.kNormalZOrder - 1
NewFormationSelectView.kAboveNormalZOrder = NewFormationSelectView.kNormalZOrder + 1
NewFormationSelectView.kHighestZOrder = NewFormationSelectView.kAboveNormalZOrder + 1

function NewFormationSelectView:ctor(params)
    NewFormationSelectView.super.ctor(self)
    self._container = params.container
    self._currentFormationId = params.currentFormationId
    self._formation = {}
    self._formation._data = params.data
    self._formationModel = self._modelMgr:getModel("FormationModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
end

function NewFormationSelectView:disableTextEffect(element)
    if element == nil then
        element = self._widget
    end
    local desc = element:getDescription()
    if desc == "Label" then
        element:disableEffect()
        element:setFontName(UIUtils.ttfName)
    end
    local count = #element:getChildren()
    for i = 1, count do
        self:disableTextEffect(element:getChildren()[i])
    end
end


function NewFormationSelectView:onInit()

    -- version 3.0
    local formationData = clone(self._formation._data)
    self._formation._data = {}
    for i = 1, 2 do
        if formationData[i] then
            self._formation._data[i] = formationData[i]
        end
    end
    formationData = {}
    self._realFormationCount = table.nums(self._formation._data)

    -- version 3.0
    self:disableTextEffect()

     -- version 3.0
    -- title
    self._title = self:getUI("bg.layer.image_title_bg.label_title")
    self._title:setFontName(UIUtils.ttfName)
    self._title:setColor(UIUtils.colorTable.titleColorRGB)
    self._title:enableOutline(UIUtils.colorTable.titleOutLineColor, 2)

    self._tips = self:getUI("bg.layer.label_tips")
    self._tips:disableEffect()

    self._formation._layer = self:getUI("bg.layer.layer_formation_list")
    self._formation._formationItem = self:getUI("bg.layer.formation_item")
    self._formation._formationItem:setVisible(false)
    self._formation._formationItemContentSize = self._formation._formationItem:getContentSize()

    self:refreshFormationTableView()

    self:registerClickEventByName("bg.btn_return", function ()
        self:close()
    end)
end

function NewFormationSelectView:indexToFormationId(index)
    if not self._dataKeys then
        self._dataKeys = table.keys(self._formation._data)
        table.sort(self._dataKeys, function(a, b)
            return a < b
        end)
    end
    return self._dataKeys[index]
end

function NewFormationSelectView:updateFormationItem(formationItem, index)
    index = index + 1
    local imageLocked = formationItem:getChildByFullName("image_locked")
    imageLocked:setVisible(index > self._realFormationCount)
    if index > self._realFormationCount then return end
    local formationId = self:indexToFormationId(index)
    print("updateFormationItem", formationId)
    local formationName = formationItem:getChildByFullName("formation_name")
    formationName:setColor(cc.c4b(73,201,233,255))
    formationName:enableOutline(cc.c4b(21, 14, 14, 255), 2)
    formationName:setString(self._formationModel:getFormationNameById(formationId))
    local fightPanel = formationItem:getChildByFullName("fight_value")
    fightPanel:setPositionX(formationName:getPositionX()+formationName:getContentSize().width+fightPanel:getContentSize().width/2)
    --local imageHero = formationItem:getChildByFullName("layer_hero")
    --imageHero:setBackGroundImage("hero_icon1_1_hero.png", 1) -- version 3.0
    --local heroData = tab:Hero(self._formation._data[formationId].heroId)
    --imageHero:loadTexture(tostring(heroData.herohead .. ".png"), 1)

    for i = 1, NewFormationView.kTeamMaxCount do
        local iconGrid = formationItem:getChildByFullName("layer_formation.formation_icon_" .. i)
        local icon  = iconGrid:getChildByTag(self.kFormationTeamTag)
        if icon then iconGrid:removeChildByTag(self.kFormationTeamTag) end
        local iconAddition = formationItem:getChildByFullName("layer_formation.formation_icon_" .. i .. ".image_addition")
        if iconAddition then
            iconAddition:setVisible(true)
        end
    end

    local data = clone(self._formation._data[formationId])

    local teamIds = {}
    for k, v in pairs(data) do
        repeat
            if string.find(tostring(k), "g") or 0 == v then break end
            if string.find(tostring(k), "team") then
               table.insert(teamIds, v) 
            end
        until true
    end

    table.sort(teamIds, function(a, b)
        local teamData1 = self._teamModel:getTeamAndIndexById(a)
        local teamData2 = self._teamModel:getTeamAndIndexById(b)
        if not (teamData1 and teamData2) then return end
        return teamData1.score > teamData2.score
    end)

    local gridId = 1
    for i = 1, NewFormationView.kTeamMaxCount do
        repeat
            local teamId = teamIds[i]
            if 0 == teamId or not teamId then break end
            local iconAddition = formationItem:getChildByFullName("layer_formation.formation_icon_" .. gridId .. ".image_addition")
            iconAddition:setVisible(false)
            local iconGrid = formationItem:getChildByFullName("layer_formation.formation_icon_" .. gridId)
            local icon = FormationIconView.new({iconType = FormationIconView.kIconTypeTeam, iconId = teamId})
            icon:showStar(false)
            icon:showStage(false)
            icon:showLevel(false)
            icon:setTag(self.kFormationTeamTag)
            icon:setTouchEnabled(false)
            icon:setPosition(iconGrid:getContentSize().width / 2, iconGrid:getContentSize().height / 2)
            iconGrid:addChild(icon, 15)
            gridId = gridId + 1
        until true
    end

    local formationLoadedTeamCount = self._container:getCurrentLoadedTeamCount(FormationIconView.kIconTypeTeam, formationId)
    local formationAllowLoadTeamCount = math.min(self._container:getCurrentAllowLoadTeamCount(), 8)
    for i = formationLoadedTeamCount, formationAllowLoadTeamCount do
        local iconAddition = formationItem:getChildByFullName("layer_formation.formation_icon_" .. i .. ".image_addition")
        iconAddition:setVisible(true)
    end

    local fightVale = formationItem:getChildByFullName("fight_value.label_fight_BMF")
    fightVale:setFntFile(UIUtils.bmfName_zhandouli_little)
    fightVale:setString("a"..self._container:getCurrentFightScore(formationId))
   
end

function NewFormationSelectView:setFormationItemSelected(formationItem, selected)
    local imageSelecetd = formationItem:getChildByFullName("image_selected")
    imageSelecetd:setVisible(selected)
end

function NewFormationSelectView:refreshFormationTableView()
    self:destroyFormationTableView()
    self:createFormationTableView()
end

function NewFormationSelectView:destroyFormationTableView()
    if not self._formation._table_view then return end
    self._formation._table_view:removeFromParentAndCleanup()
    self._formation._table_view = nil
end

function NewFormationSelectView:createFormationTableView()
    if self._formation._table_view then return end
    self._formation._table_view = cc.TableView:create(self._formation._layer:getContentSize())
    self._formation._table_view:setDelegate()
    self._formation._table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._formation._table_view:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._formation._table_view:setAnchorPoint(cc.p(0, 0))
    self._formation._table_view:setPosition(cc.p(0, 0))
    --self._formation._table_view:setBounceable(false)
    self._formation._layer:addChild(self._formation._table_view, self.kAboveNormalZOrder)
    self._formation._table_view:registerScriptHandler(handler(self, self.formationTableCellTouched), cc.TABLECELL_TOUCHED)
    self._formation._table_view:registerScriptHandler(handler(self, self.formationCellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._formation._table_view:registerScriptHandler(handler(self, self.formationTableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._formation._table_view:registerScriptHandler(handler(self, self.formationNumberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._formation._table_view:reloadData()
    --self:formationTableCellTouched(self._formation._table_view, self._formation._table_view:cellAtIndex(0))
end

function NewFormationSelectView:formationTableCellTouched(tableView, cell)
    local index = cell:getIdx() + 1
    if index > self._realFormationCount then return end
    self._currentFormationId = self:indexToFormationId(index)
    for idx=1, #self._formation._data do
        repeat
            local oneCell = self._formation._table_view:cellAtIndex(idx-1)
            if not oneCell then break end
            local formationItem = oneCell:getChildByTag(self.kFormationTag)
            if formationItem then self:setFormationItemSelected(formationItem, oneCell == cell) end
        until true
    end
    if self._container and self._container.switchFormation then
        self._container:switchFormation(self._currentFormationId)
    end
    self:close()
end

function NewFormationSelectView:formationCellSizeForTable(tableView, idx)
    return self._formation._formationItemContentSize.height + 8, self._formation._formationItemContentSize.width + 20
end

function NewFormationSelectView:formationTableCellAtIndex(tableView, idx)
    local cell = tableView:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
        local formationItem = self._formation._formationItem:clone()
        formationItem:setTouchEnabled(false)
        formationItem:setVisible(true)
        formationItem:setPosition(cc.p(self._formation._formationItemContentSize.width / 2 + 10, self._formation._formationItemContentSize.height / 2 + 5))
        formationItem:setTag(self.kFormationTag)
        self:updateFormationItem(formationItem, idx)
        self:setFormationItemSelected(formationItem, self._currentFormationId == self:indexToFormationId(idx + 1))
        cell:addChild(formationItem)
    else
        local formationItem = cell:getChildByTag(self.kFormationTag)
        self:updateFormationItem(formationItem, idx)
        self:setFormationItemSelected(formationItem, self._currentFormationId == self:indexToFormationId(idx + 1))
    end
    return cell
end

function NewFormationSelectView:formationNumberOfCellsInTableView(tableView)
    return 2--self._formationModel:getMaxFormationCount() - 1
end

return NewFormationSelectView