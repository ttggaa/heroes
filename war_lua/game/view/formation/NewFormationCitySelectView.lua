--[[
    Filename:    NewFormationCitySelectView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2017-10-11 17:37:19
    Description: File description
--]]

local NewFormationView = require("game.view.formation.NewFormationView")
local FormationIconView = require("game.view.formation.FormationIconView")
local NewFormationCitySelectView = class("NewFormationCitySelectView", BasePopView)

NewFormationCitySelectView.kWeaponIconTag = 1000
NewFormationCitySelectView.kWeaponSkillIconTag = 2000

NewFormationCitySelectView.kNormalZOrder = 500
NewFormationCitySelectView.kLessNormalZOrder = NewFormationCitySelectView.kNormalZOrder - 1
NewFormationCitySelectView.kAboveNormalZOrder = NewFormationCitySelectView.kNormalZOrder + 1
NewFormationCitySelectView.kHighestZOrder = NewFormationCitySelectView.kAboveNormalZOrder + 1

function NewFormationCitySelectView:ctor(params)
    NewFormationCitySelectView.super.ctor(self)
    self._container = params.container
    self._currentLoadedWeapon = params.currentLoadedWeapon or 0
    self._callback = params.callback
    self._weaponsModel = self._modelMgr:getModel("WeaponsModel")
end

function NewFormationCitySelectView:disableTextEffect(element)
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


function NewFormationCitySelectView:onInit()
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
    self._title = self:getUI("bg.layer.titleImg.titleTxt")
    UIUtils:setTitleFormat(self._title, 1)

    self._imageBody = self:getUI("bg.layer.layer_city.layer_left.image_bg.image_body")
    self._labelName = self:getUI("bg.layer.layer_city.layer_right.label_name")
    self._labelScore = self:getUI("bg.layer.layer_city.layer_right.label_score")
    self._labelScore:setFntFile(UIUtils.bmfName_zhandouli_little)
    self._labelScore:setScale(0.6)
    self._labelAttribute = self:getUI("bg.layer.layer_city.layer_right.label_attr_des")

    self._skillIcon = {}
    for i=1, 3 do
        self._skillIcon[i] = self:getUI("bg.layer.layer_city.layer_right.layer_skill_icon_" .. i)
    end

    self._layerIcon = {}
    for i=1, 5 do
        self._layerIcon[i] = {}
        self._layerIcon[i]._icon = self:getUI("bg.layer.layer_city.layer_bottom.layer_icon_" .. i)
        self._layerIcon[i]._icon:setVisible(false)
        self:registerClickEvent(self._layerIcon[i]._icon, function ()
            self:onCityIconClicked(i)
        end)
        self._layerIcon[i]._imageSelect = self:getUI("bg.layer.layer_city.layer_bottom.layer_icon_" .. i .. ".image_select")
        self._layerIcon[i]._imageLoaded = self:getUI("bg.layer.layer_city.layer_bottom.layer_icon_" .. i .. ".image_loaded")
        self._layerIcon[i]._imageLocked = self:getUI("bg.layer.layer_city.layer_bottom.layer_icon_" .. i .. ".image_locked")
        self._layerIcon[i]._labelName = self:getUI("bg.layer.layer_city.layer_bottom.layer_icon_" .. i .. ".label_name")
    end

    self:updateUI()

    self:registerClickEventByName("bg.layer.btn_close", function ()
        self:onButtonCloseClicked()
    end)
end

function NewFormationCitySelectView:initCityData()
    local result = {}
    local cityData = self._weaponsModel:getWeaponsDataD()
    local findCityData = function(weaponId)
        for _, v in ipairs(cityData) do
            if weaponId == v.weaponId then
                return true, v
            end
        end
        return false
    end
    local cityTableData = tab.siegeWeapon
    local t1, t2 = {}, {}
    for k, v in pairs(cityTableData) do
        repeat
            if 4 ~= v.type then break end
            local t = clone(v)
            t.unlock = false
            t.score = 0
            local f, d = findCityData(v.id)
            if f then
                t.unlock = true
                table.merge(t, d)
            end
            if t.id == self._currentLoadedWeapon then
                table.insert(t1, t)
            else
                table.insert(t2, t)
            end
        until true
    end

    for i=1, #t1 do
        result[#result + 1] = t1[i]
    end

    for i=1, #t2 do
        result[#result + 1] = t2[i]
    end

    return result
end

function NewFormationCitySelectView:updateUI()
    self._cityData = self:initCityData()
    if not self._cityData then return end
    self._currentSelectedIndex = 1
    self:updateCityIcon()
end

function NewFormationCitySelectView:onCityIconClicked(index)
    if not (self._cityData[index] and self._cityData[index].unlock) then
        self._viewMgr:showTip(lang("SIEGECON_TIPS20"))
        return
    end
    if self._currentSelectedIndex == index then return end
    self._currentSelectedIndex = index
    self:updateSelectedIcon()
end

function NewFormationCitySelectView:updateCityIcon()
    for i=1, #self._cityData do
        local data = self._cityData[i]
        local icon = self._layerIcon[i]._icon:getChildByTag(NewFormationCitySelectView.kWeaponIconTag)
        if not icon then
            icon = IconUtils:createWeaponsIconById({weaponsTab = data, eventStyle = 0})
            icon:setTag(NewFormationCitySelectView.kWeaponIconTag)
            icon:setPosition(-5, -5)
            self._layerIcon[i]._icon:addChild(icon)
        else
            IconUtils:updateWeaponsIcon(icon, {weaponsTab = data, eventStyle = 0})
        end
        icon:setSaturation(data.unlock and 0 or -100)
        self._layerIcon[i]._imageLocked:setVisible(not data.unlock)
        self._layerIcon[i]._labelName:setString(lang(data.name))
        self._layerIcon[i]._icon:setVisible(true)
    end
    self:updateSelectedIcon()
end

function NewFormationCitySelectView:updateSelectedIcon()
    local data = self._cityData[self._currentSelectedIndex]
    if not data then return end

    self._imageBody:loadTexture("asset/uiother/weapon/Weapon_" .. data.id .. ".png")
    self._imageBody:setScale(0.9)
    self._labelName:setString(lang(data.name))
    local score = self._weaponsModel:getWeaponScore(data.weaponId, data.weaponType)
    self._labelScore:setString("a" .. score)
    self._labelAttribute:setString(lang(data.des))

    local skillTableData = data.skill
    if skillTableData then
        for i=1, 3 do
            repeat
                local skillData = tab:SiegeSkillDes(skillTableData[i])
                if not skillData then break end
                local icon = self._skillIcon[i]:getChildByTag(NewFormationCitySelectView.kWeaponSkillIconTag)
                if not icon then
                    icon = IconUtils:createWeaponsSkillIcon({sysSkill = skillData})
                    icon:setTag(NewFormationCitySelectView.kWeaponSkillIconTag)
                    icon:setScale(0.8)
                    self._skillIcon[i]:addChild(icon)
                else
                    IconUtils:updateWeaponsSkillIcon(icon, {sysSkill = skillData})
                end
                if icon then
                    self:registerClickEvent(icon, function ()
                        local attrData = self._weaponsModel:getAttrData(data.weaponId, data.weaponType)
                        local attrValue = self._weaponsModel:getAttrValue(attrData)
                        self:showHintView("global.GlobalTipView",{tipType = 24, node = icon, attrValue = attrValue, id = skillData.id, posCenter = true})
                    end)
                end
            until true
        end
    end

    for i=1, 5 do
        self._layerIcon[i]._imageSelect:setVisible(i == self._currentSelectedIndex)
        self._layerIcon[i]._imageLoaded:setVisible(i == self._currentSelectedIndex)
    end
end

function NewFormationCitySelectView:onButtonCloseClicked()
    local data = self._cityData[self._currentSelectedIndex]
    if data and data.id then
        if self._callback and type(self._callback) == "function" then
            self._callback(data.id)
        end
    end
    self:close()
end

return NewFormationCitySelectView