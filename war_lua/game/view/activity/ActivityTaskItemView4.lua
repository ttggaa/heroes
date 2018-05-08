--[[
    Filename:    ActivityTaskItemView4.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-01-30 16:48:59
    Description: File description
--]]


local ActivityTaskItemView4 = class("ActivityTaskItemView4", BaseLayer)

ActivityTaskItemView4.kItemContentSize = {
    width = 667,
    height = 110
}

ActivityTaskItemView4.kTaskType1 = 1 -- 累计充值
ActivityTaskItemView4.kTaskType2 = 2 -- 
ActivityTaskItemView4.kTaskType3 = 3
ActivityTaskItemView4.kTaskType4 = 4 -- 招募有利
ActivityTaskItemView4.kTaskTypeEnd = 4

ActivityTaskItemView4.kRewardItemTag1 = 1000

ActivityTaskItemView4.kRewardItemTag2 = 2000
ActivityTaskItemView4.kConsumeItemTag2 = 2001

ActivityTaskItemView4.kRewardItemTag3 = 3000
ActivityTaskItemView4.kConsumeItemTag3 = 3001

ActivityTaskItemView4.kRewardItemTag4 = 3000
ActivityTaskItemView4.kConsumeItemTag4 = 3001


function ActivityTaskItemView4:ctor(params)
    ActivityTaskItemView4.super.ctor(self)
    self.initAnimType = 1
    self._container = params.container
    self._taskData = params.taskData
    self._viewType = self._taskData.uitype
    self._teamModel = self._modelMgr:getModel("TeamModel")
end

function ActivityTaskItemView4:disableTextEffect(element)
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

function ActivityTaskItemView4:onInit()
    --print("ActivityTaskItemView4:onInit")
    self:disableTextEffect()

    -- view type 4
    self._layerViewType4 = {}
    self._layerViewType4._layer = self:getUI("layer_item_4")
    self._layerViewType4._layerGray = self:getUI("layer_item_4.layer_gray")
    self._layerViewType4._layerConsume = self:getUI("layer_item_4.layer_consume")
    self._layerViewType4._imageAlreadyGet = self:getUI("layer_item_4.image_already_get")
    self._layerViewType4._consumes = {}
    for i = 1, 3 do
        self._layerViewType4._consumes[i] = {}
        self._layerViewType4._consumes[i]._icon = self:getUI("layer_item_4.layer_consume.layer_item_" .. i)
    end

    self._layerViewType4._rewards = {}
    for i = 1, 1 do
        self._layerViewType4._rewards[i] = {}
        self._layerViewType4._rewards[i]._icon = self:getUI("layer_item_4.layer_reward.layer_item_" .. i)
    end

    self._layerViewType4._taskDescriptionBg = self:getUI("layer_item_4.task_des_bg")
    self._layerViewType4._taskDescription = self:getUI("layer_item_4.task_description")
    self._layerViewType4._taskCurrentData = self:getUI("layer_item_4.task_current_data")
    self._layerViewType4._taskCurrentData:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- self._layerViewType4._taskCurrentData:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._layerViewType4._btnGo = self:getUI("layer_item_4.btn_go")
    self._layerViewType4._btnGet = self:getUI("layer_item_4.btn_get")

    -- self._layerViewType4._btnGo:setTitleFontName(UIUtils.ttfName)
    -- self._layerViewType4._btnGo:setTitleColor(cc.c4b(255, 250, 220, 255))
    -- self._layerViewType4._btnGo:getTitleRenderer():enableOutline(cc.c4b(5, 92, 144, 255), 3) --(cc.c4b(101, 33, 0, 255), 2)
    -- self._layerViewType4._btnGo:setTitleFontSize(28) 
    -- self._layerViewType4._btnGet:setTitleFontName(UIUtils.ttfName)
    -- self._layerViewType4._btnGet:setTitleColor(cc.c4b(255, 250, 220, 255))
    -- self._layerViewType4._btnGet:getTitleRenderer():enableOutline(cc.c4b(153, 93, 0, 255), 3) --(cc.c4b(101, 33, 0, 255), 2)
    -- self._layerViewType4._btnGet:setTitleFontSize(28) 

    self._layerViewType4._getMC = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true)
    self._layerViewType4._getMC:setPlaySpeed(1, true)
    self._layerViewType4._getMC:setPosition(self._layerViewType4._btnGet:getContentSize().width / 2 - 2, self._layerViewType4._btnGet:getContentSize().height / 2)
    self._layerViewType4._btnGet:addChild(self._layerViewType4._getMC)
    self:registerClickEvent(self._layerViewType4._btnGo, function ()
        self:onButtonGoClicked()
    end)

    self:registerClickEvent(self._layerViewType4._btnGet, function ()
        self:onButtonGetClicked()
    end)

    self:updateUI()
end

function ActivityTaskItemView4:updateViewType4()
    self._layerViewType4._layerGray:setVisible(0 == self._taskData.statusInfo.status)
    self._layerViewType4._btnGo:setVisible(-1 == self._taskData.statusInfo.status and self._taskData.button > 0)
    self._layerViewType4._btnGet:setVisible(1 == self._taskData.statusInfo.status or (-1 == self._taskData.statusInfo.status and 0 == self._taskData.button))
    --self._layerViewType4._btnGet:setEnabled(1 == self._taskData.statusInfo.status)
    self._layerViewType4._btnGet:setSaturation(1 == self._taskData.statusInfo.status and 0 or -100)
    self._layerViewType4._btnGet:setBright(1 == self._taskData.statusInfo.status)
    self._layerViewType4._btnGet:setSaturation(1 == self._taskData.statusInfo.status and 0 or -100)
    self._layerViewType4._getMC:setVisible(1 == self._taskData.statusInfo.status)
    self._layerViewType4._imageAlreadyGet:setVisible(0 == self._taskData.statusInfo.status)
    --self._layerViewType4._taskCurrentData:setVisible(not self._layerViewType4._imageAlreadyGet:isVisible())
    self._layerViewType4._taskCurrentData:setVisible(false)
    local labelDiscription = self._layerViewType4._taskDescription
    local desc = lang(self._taskData.description)
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5, true)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(richText:getInnerSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)
    self._layerViewType4._taskDescriptionBg:setContentSize(cc.size(richText:getInnerSize().width + 40, 32))
    if not self._taskData.finish_max then
        self._layerViewType4._taskCurrentData:setString(string.format("%d/%d", self._taskData.statusInfo.value, self._taskData.statusInfo.condition))
    else
        self._layerViewType4._taskCurrentData:setString(string.format("%d/%d", self._taskData.times, self._taskData.finish_max))
    end

    for i=1, 1 do
        self._layerViewType4._consumes[i]._icon:setVisible(false)
    end

    for i=1, 1 do
        local itemId = self._taskData.condition_num[1]
        self._layerViewType4._consumes[i]._icon:removeChildByName("itemIcon")
        if itemId > 60000 then
            local heroTableData = clone(tab:Hero(itemId))
            heroTableData.star = self._taskData.condition_num[2]
            heroTableData.hideFlag = true
            if not heroTableData then print("invalid hero icon id", self._iconId) end
            local itemIcon = IconUtils:createHeroIconById({sysHeroData = heroTableData})
            itemIcon:setScale(0.68)
            itemIcon:setPosition(cc.p(32, 36))
            itemIcon:setName("itemIcon")
            self._layerViewType4._consumes[i]._icon:addChild(itemIcon)
            registerClickEvent(itemIcon, function()
                local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = tonumber(itemId) or 60101}, true)
            end)

        elseif itemId >= 40111 then 
            local itemIcon = IconUtils:createItemIconById({itemId = itemId, num = -1, effect = true})
            itemIcon:setScale(0.68)
            itemIcon:setPosition(cc.p(32, 36))
            itemIcon:setName("itemIcon")
            self._layerViewType4._consumes[i]._icon:addChild(itemIcon)
        else
            local teamTableData = clone(tab:Team(itemId))
            teamTableData.star = self._taskData.condition_num[2]
            teamTableData.stage = 8
            local quality = self._teamModel:getTeamQualityByStage(teamTableData.stage)
            local itemIcon = IconUtils:createTeamIconById({teamData = {id = itemId, star = teamTableData.star}, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
            itemIcon:setScale(0.68)
            itemIcon:setPosition(cc.p(0, 0))
            itemIcon:setName("itemIcon")
            self._layerViewType4._consumes[i]._icon:addChild(itemIcon)

            registerClickEvent(itemIcon, function()
                local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalTeam, iconId = tonumber(itemId) or 60101}, true)
            end)

        end
        self._layerViewType4._consumes[i]._icon:setVisible(true)
    end

    for i=1, 1 do
        self._layerViewType4._rewards[i]._icon:setVisible(false)
    end

    local giftContain = self._taskData.reward
    local staticConfigTableData = IconUtils.iconIdMap
    for i = 1, --[[#giftContain]]1 do
        local giftItem = --[[1 == #giftContain and self._layerViewType4._rewards[2]._icon or]] self._layerViewType4._rewards[i]._icon
        giftItem:setVisible(true)
        local itemIcon = giftItem:getChildByTag(self.kRewardItemTag2)
        if itemIcon then itemIcon:removeFromParent() end
        if giftContain[i][1] ~= "tool" and staticConfigTableData[giftContain[i][1]] then
            itemIcon = IconUtils:createItemIconById({itemId = staticConfigTableData[giftContain[i][1]], num = giftContain[i][3]})
            --[=[
            self:registerTouchEvent(giftItem, function(x, y)
                    self:startClock(giftItem, staticConfigTableData[giftContain[i][1]])
                end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
            ]=]
        elseif giftContain[i][1] == "tool" then
            itemIcon = IconUtils:createItemIconById({itemId = giftContain[i][2], num = giftContain[i][3]})
            --[[
            self:registerTouchEvent(giftItem, function(x, y)
                    self:startClock(giftItem, giftContain[i][2])
                end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
            ]]
        end
        itemIcon:setScale(0.65)
        itemIcon:setTag(self.kRewardItemTag2)
        giftItem:addChild(itemIcon)
    end
end

function ActivityTaskItemView4:updateUI()
    self:updateViewType4()
    --[[
    for viewType = ActivityTaskItemView4.kTaskType1, ActivityTaskItemView4.kTaskTypeEnd do
        repeat
            if viewType == self._viewType then
                self["_layerViewType" .. viewType]._layer:setVisible(true)
                break
            end
            self["_layerViewType" .. viewType]._layer:setVisible(false)
        until true
    end

    --dump(self._taskData, "ActivityTaskItemView4")
    --self:setSaturation(0 == self._taskData.statusInfo.status and -100 or 0)
    if self["updateViewType" .. self._viewType] and "function" == type(self["updateViewType" .. self._viewType]) then
        self["updateViewType" .. self._viewType](self)
    end
    ]]
end

function ActivityTaskItemView4:setContext(context)
    self._container = context.container
    self._taskData = context.taskData
    self._viewType = self._taskData.uitype
end

function ActivityTaskItemView4:onButtonGoClicked()
    if not (self._container and self._container.onButtonGoClicked) then return end
    self._container:onButtonGoClicked(self._taskData)
end

function ActivityTaskItemView4:onButtonGetClicked()
    if not (self._container and self._container.onButtonGetClicked) then return end
    self._container:onButtonGetClicked(self._taskData)
end

return ActivityTaskItemView4