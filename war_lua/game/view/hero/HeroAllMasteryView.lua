--[[
    Filename:    HeroAllMasteryView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-03-16 16:33:21
    Description: File description
--]]

local FormationIconView = require("game.view.formation.FormationIconView")

local HeroAllMasteryView = class("HeroAllMasteryView", BasePopView)

HeroAllMasteryView.kMasteryTag = 1000
HeroAllMasteryView.kMasteryIteamTag = 2000

HeroAllMasteryView.kNormalZOrder = 500
HeroAllMasteryView.kLessNormalZOrder = HeroAllMasteryView.kNormalZOrder - 1
HeroAllMasteryView.kAboveNormalZOrder = HeroAllMasteryView.kNormalZOrder + 1
HeroAllMasteryView.kHighestZOrder = HeroAllMasteryView.kAboveNormalZOrder + 1

function HeroAllMasteryView:ctor(params)
    HeroAllMasteryView.super.ctor(self)
    self._container = params.container
    self._heroData = params.heroData
    self._callback = params.callback
    self._userModel = self._modelMgr:getModel("UserModel")
    self._vipModel = self._modelMgr:getModel("VipModel")
end

function HeroAllMasteryView:disableTextEffect(element)
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

function HeroAllMasteryView:onInit()
    self:disableTextEffect()

    self._layerItem = self:getUI("bg.layer.layer_item")
    self._layerItem:setVisible(false)
    self._layerItemContentSize = self._layerItem:getContentSize()
    self._layerList = self:getUI("bg.layer.layer_list")
    self._masteryTableView = nil

    self._attributeValues = BattleUtils.getHeroAttributes(self._heroData)
    self._masteryData = self:initMasteryData()

    --dump(self._masteryData, "mastery Data", 5)

    self._title = self:getUI("bg.layer.titleBg.title")
    -- self._title:setColor(UIUtils.colorTable.titleColorRGB)
    self._title:setFontName(UIUtils.ttfName_Title)
    -- self._title:enable2Color(1, cc.c4b(240, 165, 40, 255))
    self._title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- self._title:setFontSize(28)

    self:refreshMasteryTableView()

    self:registerClickEventByName("bg.layer.btn_close", function ()
        if self._callback and type(self._callback) == "function" then
            self._callback()
        end
        self:close()
    end)
end

function HeroAllMasteryView:initMasteryData()
    local result, mastery1, mastery2, mastery3 = {}, {}, {}, {}
    local masteryTableData = tab.heroMastery
    local masteryRecommand = self._heroData.recmastery
    local isMasteryRcommand = function(masterydata)
        for _, v in ipairs(masteryRecommand) do
            if v == masterydata.baseid and masterydata.masterylv >= 2 then
                return true
            end
        end
        return false
    end

    local isMasteryGlobal = function(masteryId)
        local masteryData = tab:HeroMastery(masteryId)
        return masteryData and 1 == masteryData.global
    end

    for k, v in pairs(masteryTableData) do
        if 2 == v.class and (0 == v.masterytype or self._heroData.masterytype == v.masterytype) then
            if isMasteryRcommand(v) then
                local v0 = clone(v)
                v0.recommand = true
                table.insert(mastery1, v0)
            elseif isMasteryGlobal(v.id) then
                table.insert(mastery3, v)
            else
                table.insert(mastery2, v)
            end
        end
    end

    table.sort(mastery1, function(a, b)
        if a.masterylv == b.masterylv then
            return a.baseid < b.baseid
        end
        return a.masterylv > b.masterylv
    end)


    for _, v in ipairs(mastery1) do
        result[#result + 1] = v
    end

    table.sort(mastery3, function(a, b)
        if a.masterylv == b.masterylv then
            return a.baseid < b.baseid
        end
        return a.masterylv > b.masterylv
    end)

    for _, v in ipairs(mastery3) do
        result[#result + 1] = v
    end

    table.sort(mastery2, function(a, b)
        if a.baseid == b.baseid then
            return a.masterylv > b.masterylv
        end
        return a.baseid < b.baseid
    end)

    local t1, t2, t3 = {}, {}, {}
    for _, v in ipairs(mastery2) do
        if 3 == v.masterylv then
            table.insert(t1, v)
        elseif 2 == v.masterylv then
            table.insert(t2, v)
        else
            table.insert(t3, v)
        end
    end

    for _, v in ipairs(t1) do
        result[#result + 1] = v
    end

    for _, v in ipairs(t2) do
        result[#result + 1] = v
    end

    for _, v in ipairs(t3) do
        result[#result + 1] = v
    end

    return result
end

function HeroAllMasteryView:updateMasteryItem(masteryItem, index)
    for i = 1, 2 do
        repeat
            local preName = "item_" .. i
            local item = masteryItem:getChildByFullName(preName)
            item:setVisible(false)
            local data = self._masteryData[2 * index + i]
            if not data then break end
            item:setVisible(true)
            local layerIcon = masteryItem:getChildByFullName(preName .. ".layer_icon")
            local image_title_bg = masteryItem:getChildByFullName(preName .. ".image_title_bg")
            image_title_bg:setOpacity(168)
            local icon = layerIcon:getChildByTag(HeroAllMasteryView.kMasteryIteamTag)
            if not icon then
                icon = FormationIconView.new({ iconType = FormationIconView.kIconTypeHeroMastery, iconId = data.id, container = { _container = self } })
                icon:setTouchEnabled(false)
                icon:setPosition(layerIcon:getContentSize().width / 2+5, layerIcon:getContentSize().height / 2+5)
                icon:setTag(HeroAllMasteryView.kMasteryIteamTag)
                icon:setScale(1.4)
                layerIcon:addChild(icon)
            end 
            icon = layerIcon:getChildByTag(HeroAllMasteryView.kMasteryIteamTag)
            icon:setVisible(true)
            icon:setIconType(FormationIconView.kIconTypeHeroMastery)
            icon:setIconId(data.id)
            icon:updateIconInformation()

            local masteryName = masteryItem:getChildByFullName(preName .. ".layer_icon.label_mastery")
            -- masteryName:setFontSize(22)
            masteryName:setFontName(UIUtils.ttfName)
            masteryName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
            masteryName:setString(lang(data.name))

            local masteryLv = masteryItem:getChildByFullName(preName .. ".layer_icon.label_mastery_level")
            -- masteryLv:setFontSize(22)
            masteryLv:setFontName(UIUtils.ttfName)
            local color = nil
            local outlineColor = nil
            local levelName = nil
            if 1 == data.masterylv then
                color = cc.c3b(118, 238, 0)
                outlineColor = cc.c4b(0, 78, 0, 255)
                levelName = "初级"
            elseif 2 == data.masterylv then
                color = cc.c3b(72, 210, 255)
                outlineColor = cc.c4b(0, 44, 118, 255)
                levelName = "中级"
            elseif 3 == data.masterylv then
                color = cc.c3b(239, 109, 254)
                outlineColor = cc.c4b(71, 0, 140, 255)
                levelName = "高级"
            end
            -- masteryLv:setColor(color)
            masteryLv:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1) --enableOutline(outlineColor, 2)
            masteryLv:setString(levelName)

            local masteryRecommand = masteryItem:getChildByFullName(preName .. ".layer_icon.image_recommand")
            masteryRecommand:setVisible(not not data.recommand)
            --[[
            local label_recommand = masteryItem:getChildByFullName(preName .. ".layer_icon.image_recommand.label_recommand")
            label_recommand:setFontName(UIUtils.ttfName)
            label_recommand:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
            ]]

            local masteryGlobal = masteryItem:getChildByFullName(preName .. ".layer_icon.image_global")
            masteryGlobal:setVisible(not masteryRecommand:isVisible() and 1 == data.global)

            local desc = "[color=3d1f00,fontsize = 20]" .. BattleUtils.getDescription(BattleUtils.kIconTypeHeroMastery, data.id, self._attributeValues) .. "[-]"
            local label = masteryItem:getChildByFullName(preName .. ".layer_icon.label_descripition")
            local richText = label:getChildByName("descRichText")
            if richText then
                richText:removeFromParentAndCleanup()
            end
            richText = RichTextFactory:create(desc, 255, 45)
            richText:formatText()
            richText:enablePrinter(true)
            richText:setPosition(label:getContentSize().width / 2, label:getContentSize().height / 2)
            richText:setName("descRichText")
            label:addChild(richText)
        until true
    end
end
--[[
function HeroAllMasteryView:onIconPressOn(node, iconType, iconId)
    print("onIconPressOn")
    iconType = node.getIconType and node:getIconType() or iconType
    iconId = node.getIconId and node:getIconId() or iconId
    if not (iconType and iconId) then return end
    print("iconType, iconId", iconType, iconId)
    if iconType == FormationIconView.kIconTypeHeroSpecialty or iconType == FormationIconView.kIconTypeHeroMastery then
        self:showHintView("global.GlobalTipView",{tipType = 2, node = node, id = iconId, rotation = 90, des = BattleUtils.getDescription(iconType, iconId, self._attributeValues)})
    end
end

function HeroAllMasteryView:onIconPressOff()
    print("onIconPressOff")
    self:closeHintView()
end
]]
function HeroAllMasteryView:refreshMasteryTableView()
    self:destroyMasteryTableView()
    self:createMasteryTableView()
end

function HeroAllMasteryView:destroyMasteryTableView()
    if not self._masteryTableView then return end
    self._masteryTableView:removeFromParentAndCleanup()
    self._masteryTableView = nil
end

function HeroAllMasteryView:createMasteryTableView()
    if self._masteryTableView then return end
    self._masteryTableView = cc.TableView:create(cc.size(self._layerList:getContentSize().width, self._layerList:getContentSize().height - 30))
    self._masteryTableView:setDelegate()
    self._masteryTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._masteryTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._masteryTableView:setAnchorPoint(cc.p(0, 0))
    self._masteryTableView:setPosition(cc.p(5, 15))
    self._masteryTableView:setBounceable(true)
    self._layerList:addChild(self._masteryTableView, self.kAboveNormalZOrder)
    self._masteryTableView:registerScriptHandler(handler(self, self.masteryTableCellTouched), cc.TABLECELL_TOUCHED)
    self._masteryTableView:registerScriptHandler(handler(self, self.masteryCellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._masteryTableView:registerScriptHandler(handler(self, self.masteryTableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._masteryTableView:registerScriptHandler(handler(self, self.masteryNumberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._masteryTableView:reloadData()
    --self:masteryTableCellTouched(self._masteryTableView, self._masteryTableView:cellAtIndex(0))
end

function HeroAllMasteryView:masteryTableCellTouched(tableView, cell)

end

function HeroAllMasteryView:masteryCellSizeForTable(tableView, idx)
    return self._layerItemContentSize.height + 15, self._layerItemContentSize.width + 20
end

function HeroAllMasteryView:masteryTableCellAtIndex(tableView, idx)
    local cell = tableView:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
        local masteryItem = self._layerItem:clone()
        masteryItem:setVisible(true)
        masteryItem:setTouchEnabled(false)
        masteryItem:setVisible(true)
        masteryItem:setPosition(cc.p(10, 8))
        masteryItem:setTag(HeroAllMasteryView.kMasteryTag)
        self:updateMasteryItem(masteryItem, idx)
        cell:addChild(masteryItem)
    else
        local masteryItem = cell:getChildByTag(HeroAllMasteryView.kMasteryTag)
        self:updateMasteryItem(masteryItem, idx)
    end
    return cell
end

function HeroAllMasteryView:masteryNumberOfCellsInTableView(tableView)
    return math.round(#self._masteryData / 2)
end

return HeroAllMasteryView