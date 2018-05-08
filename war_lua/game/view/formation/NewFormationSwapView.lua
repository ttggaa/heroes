--[[
    Filename:    NewFormationSwapView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2017-10-09 20:42:07
    Description: File description
--]]


local NewFormationView = require("game.view.formation.NewFormationView")
local FormationIconView = require("game.view.formation.FormationIconView")
local NewFormationSwapView = class("NewFormationSwapView", BasePopView)

NewFormationSwapView.kTeamGridCount = 16

NewFormationSwapView.kFormationTag = 1000
NewFormationSwapView.kFormationTeamTag = 2000

NewFormationSwapView.kNormalZOrder = 500
NewFormationSwapView.kLessNormalZOrder = NewFormationSwapView.kNormalZOrder - 1
NewFormationSwapView.kAboveNormalZOrder = NewFormationSwapView.kNormalZOrder + 1
NewFormationSwapView.kHighestZOrder = NewFormationSwapView.kAboveNormalZOrder + 1

function NewFormationSwapView:ctor(params)
    NewFormationSwapView.super.ctor(self)
    self._container = params.container
    self._formationData = params.formationData
    self._formationOriginData = clone(self._formationData)
    self._callback1 = params.callback1
    self._callback2 = params.callback2
    self._allowBattle = params.allowBattle
    self._formationModel = self._modelMgr:getModel("FormationModel")
end

function NewFormationSwapView:disableTextEffect(element)
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


function NewFormationSwapView:onInit()
    --[[
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
    ]]
    self:disableTextEffect()

    -- title
    self._title = self:getUI("bg.layer.titleBg.title")
    self._title:setFontName(UIUtils.ttfName)
    self._title:setColor(UIUtils.colorTable.titleColorRGB)

    self._labelDes = self:getUI("bg.layer.label_des")
    self._labelDes:disableEffect()

    self._currentSelectedIndex = 0
    self._formationPreview = {}
    for i=1, 3 do
        self._formationPreview[i] = {}
        self._formationPreview[i]._layer = self:getUI("bg.layer.layer_" .. i)
        self:registerClickEvent(self._formationPreview[i]._layer, function()
            self:onButtonFormationSelectClicked(i)
        end)

        self._formationPreview[i]._layerFormation = {}
        self._formationPreview[i]._layerFormation._layer = self:getUI("bg.layer.layer_formation_" .. i)
        self._formationPreview[i]._layerFormation._imageSelected = self:getUI("bg.layer.layer_formation_" .. i .. ".image_selected")
        self._formationPreview[i]._layerFormation._labelScore = self:getUI("bg.layer.layer_formation_" .. i .. ".label_score")
        -- self._formationPreview[i]._labelTitle = self:getUI("bg.layer.label_title")
        self._formationPreview[i]._layerFormation._formationUI = {}
        for j=1, NewFormationSwapView.kTeamGridCount do
            self._formationPreview[i]._layerFormation._formationUI[j] = self:getUI("bg.layer.layer_formation_" .. i .. ".formation_icon_" .. j)
        end
    end

    self:updateUI()

    self:registerClickEventByName("bg.layer.btn_ok", function ()
        self:onButtonOkClicked()
    end)

    self:registerClickEventByName("bg.layer.btn_close", function ()
        self:onButtonCloseClicked()
    end)
end

function NewFormationSwapView:updateUI()
    for formationId = self._formationModel.kFormationTypeGodWar1, self._formationModel.kFormationTypeGodWar3 do
        local currentIndex = formationId - self._formationModel.kFormationTypeGodWar1 + 1
        for i = 1, NewFormationSwapView.kTeamGridCount do
            self._formationPreview[currentIndex]._layerFormation._formationUI[i]:removeAllChildren()
        end

        local formationData = self._formationData[formationId]
        for i = 1, NewFormationView.kTeamMaxCount do
            repeat
                local teamId = formationData[string.format("team%d", i)]
                if 0 == teamId then break end
                local teamPositionId = formationData[string.format("g%d", i)]
                local teamTableData = tab:Team(teamId)
                local iconGrid = self._formationPreview[currentIndex]._layerFormation._formationUI[teamPositionId]
                local imageView = ccui.ImageView:create(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
                imageView:setScale(0.75)
                imageView:setPosition(cc.p(iconGrid:getContentSize().width / 2, iconGrid:getContentSize().height / 2))
                iconGrid:addChild(imageView)
            until true
        end
    end

    for i=1, 3 do
        local formationId = self._formationModel.kFormationTypeGodWar1 - 1 + i
        self._formationPreview[i]._layerFormation._layer:setSaturation((self._allowBattle and self._allowBattle[formationId]) and 0 or -100)
        self._formationPreview[i]._layerFormation._imageSelected:setVisible(i == self._currentSelectedIndex)
        self._formationPreview[i]._layerFormation._labelScore:setString(self._formationModel:getCurrentFightScoreByType(formationId, self._formationData[formationId]))
    end
end

function NewFormationSwapView:onButtonFormationSelectClicked(index)
    if index < 1 or index > 3 then return end
    local formationId = self._formationModel.kFormationTypeGodWar1 - 1 + index
    if not (self._allowBattle and self._allowBattle[formationId]) then
        self._viewMgr:showTip(lang("GODWAR_ARRAY"))
        return
    end
    if 0 == self._currentSelectedIndex then
        self._currentSelectedIndex = index
        -- self._labelDes:setString("点击其他编组进行交换或者再次点击取消选中")
    elseif self._currentSelectedIndex == index then
        self._currentSelectedIndex = 0
        -- self._labelDes:setString("点击布阵模块以快速的互换布阵阵容")
    else
        local formationId1 = self._formationModel.kFormationTypeGodWar1 - 1 + self._currentSelectedIndex
        local formationData = clone(self._formationData[formationId1])
        self._formationData[formationId1] = self._formationData[formationId]
        self._formationData[formationId] = formationData
        local layer1 = self._formationPreview[self._currentSelectedIndex]._layerFormation._layer
        local layer2 = self._formationPreview[index]._layerFormation._layer
        local position1 = cc.p(layer1:getPosition())
        local position2 = cc.p(layer2:getPosition())
        layer1:runAction(cc.MoveTo:create(0.2, position2))
        layer2:runAction(cc.MoveTo:create(0.2, position1))
        local layer = self._formationPreview[self._currentSelectedIndex]._layerFormation
        self._formationPreview[self._currentSelectedIndex]._layerFormation = self._formationPreview[index]._layerFormation
        self._formationPreview[index]._layerFormation = layer
        self._currentSelectedIndex = 0
    end

    for i=1, 3 do
        self._formationPreview[i]._layerFormation._imageSelected:setVisible(i == self._currentSelectedIndex)
    end
end

function NewFormationSwapView:isFormationChanged()
    for formationId = self._formationModel.kFormationTypeGodWar1, self._formationModel.kFormationTypeGodWar3 do
        local formationData1 = self._formationOriginData[formationId]
        local formationData2 = self._formationData[formationId]
        if formationData1 and formationData2 then
            for i=1, 8 do
                if formationData1["team" .. i] ~= formationData2["team" .. i] or
                   formationData1["g" .. i] ~= formationData2["g" .. i] then
                   return true
                end
            end

            if formationData1["tid"] ~= formationData2["tid"] then
                return true
            end

            for i=1, 4 do
                if formationData1["weapon" .. i] ~= formationData2["weapon" .. i] then
                    return true
                end
            end
        end
    end
    return false
end

function NewFormationSwapView:onButtonOkClicked()
    if self._callback1 and type(self._callback1) == "function" then
        self._callback1(self._formationData)
        self:close()
    end
end

function NewFormationSwapView:onButtonCloseClicked()
    if self:isFormationChanged() then
        self._viewMgr:showSelectDialog(lang("KUAISUHUHUAN_BUZHEN_TIPS"), "", function()
            self:close()        
        end, "")
        return
    end
    self:close()
end

return NewFormationSwapView