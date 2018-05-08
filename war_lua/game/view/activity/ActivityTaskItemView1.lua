--[[
    Filename:    ActivityTaskItemView1.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-01-30 16:48:59
    Description: File description
--]]


local ActivityTaskItemView1 = class("ActivityTaskItemView1", BaseLayer)

ActivityTaskItemView1.kItemContentSize = {
    width = 667,
    height = 110
}

ActivityTaskItemView1.kTaskType1 = 1 -- 累计充值
ActivityTaskItemView1.kTaskType2 = 2 -- 
ActivityTaskItemView1.kTaskType3 = 3
ActivityTaskItemView1.kTaskType4 = 4 -- 招募有利
ActivityTaskItemView1.kTaskTypeEnd = 4

ActivityTaskItemView1.kRewardItemTag1 = 1000

ActivityTaskItemView1.kRewardItemTag2 = 2000
ActivityTaskItemView1.kConsumeItemTag2 = 2001

ActivityTaskItemView1.kRewardItemTag3 = 3000
ActivityTaskItemView1.kConsumeItemTag3 = 3001

ActivityTaskItemView1.kRewardItemTag4 = 3000
ActivityTaskItemView1.kConsumeItemTag4 = 3001


function ActivityTaskItemView1:ctor(params)
    ActivityTaskItemView1.super.ctor(self)
    self.initAnimType = 1
    self._container = params.container
    self._taskData = params.taskData
    self._viewType = self._taskData.uitype
    self._teamModel = self._modelMgr:getModel("TeamModel")
end

function ActivityTaskItemView1:disableTextEffect(element)
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

function ActivityTaskItemView1:onInit()
    --print("ActivityTaskItemView1:onInit")
    self:disableTextEffect()

    -- view type 1
    self._layerViewType1 = {}
    self._layerViewType1._layer = self:getUI("layer_item_1")
    self._layerViewType1._layerGray = self:getUI("layer_item_1.layer_gray")
    self._layerViewType1._taskDescriptionBg = self:getUI("layer_item_1.task_des_bg")
    self._layerViewType1._taskDescription = self:getUI("layer_item_1.task_description")
    self._layerViewType1._taskCurrentData = self:getUI("layer_item_1.task_current_data")
    self._layerViewType1._taskCurrentData:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- self._layerViewType1._taskCurrentData:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._layerViewType1._btnGo = self:getUI("layer_item_1.btn_go")
    self._layerViewType1._btnGet = self:getUI("layer_item_1.btn_get")
    -- self._layerViewType1._btnGo:setTitleFontName(UIUtils.ttfName)
    -- self._layerViewType1._btnGo:setTitleColor(cc.c4b(255, 250, 220, 255))
    -- self._layerViewType1._btnGo:getTitleRenderer():enableOutline(cc.c4b(5, 92, 144, 255), 3) --(cc.c4b(101, 33, 0, 255), 2)
    -- self._layerViewType1._btnGo:setTitleFontSize(28) 
    -- self._layerViewType1._btnGet:setTitleFontName(UIUtils.ttfName)
    -- self._layerViewType1._btnGet:setTitleColor(cc.c4b(255, 250, 220, 255))
    -- self._layerViewType1._btnGet:getTitleRenderer():enableOutline(cc.c4b(153, 93, 0, 255), 3) --(cc.c4b(101, 33, 0, 255), 2)
    -- self._layerViewType1._btnGet:setTitleFontSize(28) 

    self._layerViewType1._getMC = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true)
    self._layerViewType1._getMC:setPlaySpeed(1, true)
    self._layerViewType1._getMC:setPosition(self._layerViewType1._btnGet:getContentSize().width / 2 - 2, self._layerViewType1._btnGet:getContentSize().height / 2)
    self._layerViewType1._btnGet:addChild(self._layerViewType1._getMC)
    self:registerClickEvent(self._layerViewType1._btnGo, function ()
        self:onButtonGoClicked()
    end)

    self:registerClickEvent(self._layerViewType1._btnGet, function ()
        self:onButtonGetClicked()
    end)
    --[[
    self._layerViewType1._getMC2 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true)
    self._layerViewType1._getMC2:setPlaySpeed(1, true)
    self._layerViewType1._getMC2:setPosition(self._layerViewType1._btnGet:getContentSize().width / 2, self._layerViewType1._btnGet:getContentSize().height / 2)
    self._layerViewType1._btnGet:addChild(self._layerViewType1._getMC2)
    ]]
    self._layerViewType1._imageAlreadyGet = self:getUI("layer_item_1.image_already_get")

    self._layerViewType1._rewards = {}
    for i = 1, 4 do
        self._layerViewType1._rewards[i] = {}
        self._layerViewType1._rewards[i]._icon = self:getUI("layer_item_1.layer_reward_bg.layer_reward_" .. i)
    end

    self:updateUI()
end

function ActivityTaskItemView1:updateViewType1()
    self._layerViewType1._layerGray:setVisible(0 == self._taskData.statusInfo.status)
    self._layerViewType1._btnGo:setVisible(-1 == self._taskData.statusInfo.status and self._taskData.button > 0)
    self._layerViewType1._btnGet:setVisible(1 == self._taskData.statusInfo.status or (-1 == self._taskData.statusInfo.status and 0 == self._taskData.button))
    --self._layerViewType1._btnGet:setEnabled(1 == self._taskData.statusInfo.status)
    self._layerViewType1._btnGet:setSaturation(1 == self._taskData.statusInfo.status and 0 or -100)
    self._layerViewType1._btnGet:setBright(1 == self._taskData.statusInfo.status)
    self._layerViewType1._getMC:setVisible(1 == self._taskData.statusInfo.status)
    self._layerViewType1._imageAlreadyGet:setVisible(0 == self._taskData.statusInfo.status)
    self._layerViewType1._taskCurrentData:setVisible(not self._layerViewType1._imageAlreadyGet:isVisible())
    local labelDiscription = self._layerViewType1._taskDescription
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
    --self._layerViewType1._taskCurrentData:setPositionY((self._layerViewType1._btnGo:isVisible() or self._layerViewType1._btnGet:isVisible()) and 90 or 60)
    if not self._taskData.finish_max then
        self._layerViewType1._taskCurrentData:setString(string.format("%d/%d", self._taskData.statusInfo.value, self._taskData.statusInfo.condition))
    else
        self._layerViewType1._taskCurrentData:setString(string.format("%d/%d", self._taskData.times, self._taskData.finish_max))
    end
    self._layerViewType1._taskDescriptionBg:setContentSize(cc.size(richText:getInnerSize().width + 40, 32))
    --[[
    local conditiontype = self._taskData.conditiontype
    if 101 == conditiontype or
       102 == conditiontype then
        self._layerViewType1._taskCurrentData:setVisible(true)
        if 0 == self._taskData.statusInfo.status then
            self._layerViewType1._taskCurrentData:setString("0/1")
        elseif 1 == self._taskData.statusInfo.status then
            self._layerViewType1._taskCurrentData:setString("1/1")
        else
            self._layerViewType1._taskCurrentData:setVisible(false)
        end
    elseif 998 == conditiontype then
        self._layerViewType1._taskCurrentData:setVisible(true)
        if 0 == self._taskData.statusInfo.status then
            self._layerViewType1._taskCurrentData:setString("未购买")
        elseif 1 == self._taskData.statusInfo.status then
            self._layerViewType1._taskCurrentData:setString("已购买")
            local restDay = math.floor((self._taskData.val2 - self._modelMgr:getModel("UserModel"):getCurServerTime()) / 86400)
        else
            self._layerViewType1._taskCurrentData:setVisible(false)
        end   
    elseif 999 == conditiontype then
        if 0 == self._taskData.statusInfo.status then
            self._layerViewType1._taskCurrentData:setString("时间未到")
        elseif self._taskData.statusInfo.status >= 1 then
            self._layerViewType1._taskCurrentData:setVisible(false)
        elseif -1 == self._taskData.statusInfo.status then
            self._layerViewType1._taskCurrentData:setString("时间已过")
        end
    else
        self._layerViewType1._taskCurrentData:setVisible(not self._layerViewType1._imageAlreadyGet:isVisible())
        self._layerViewType1._taskCurrentData:setString(string.format("%d/%d", tonumber(self._taskData.val2), tonumber(self._taskData.val1)))
    end
    ]]
    local toolTableData = tab.tool
    local staticConfigTableData = IconUtils.iconIdMap

    for i=1, 4 do
        self._layerViewType1._rewards[i]._icon:setVisible(false)
    end

    local giftContain = self._taskData.reward
    local staticConfigTableData = IconUtils.iconIdMap
    for i = 1, #giftContain do
        local giftItem = self._layerViewType1._rewards[i]._icon
        giftItem:setVisible(true)
        local itemIcon = giftItem:getChildByTag(self.kRewardItemTag1)
        if itemIcon then itemIcon:removeFromParent() end

        local itemId = nil
        if giftContain[i][1] ~= "tool" and staticConfigTableData[giftContain[i][1]] then
            itemId = staticConfigTableData[giftContain[i][1]]
        else
            itemId = giftContain[i][2]
        end

        local isShowHero = false
        local eventStyle = 1--{itemId = itemId, num = num,eventStyle = 0} 
        local toolData = tab:Tool(itemId)
        if toolData and 6 == toolData.typeId then
            isShowHero = true
            eventStyle = 0      
        end
        itemIcon = IconUtils:createItemIconById({itemId = itemId, num = giftContain[i][3],eventStyle = eventStyle})
        --[=[
        self:registerTouchEvent(giftItem, function(x, y)
                self:startClock(giftItem, staticConfigTableData[giftContain[i][1]])
            end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
        ]=]
        if isShowHero then
            local heroId = string.sub(itemId, 2, string.len(itemId))
            itemIcon:setTouchEnabled(true)
            itemIcon:setSwallowTouches(false)
            
            registerClickEvent(itemIcon, function()
                local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = tonumber(heroId)}, true)
            end)
        end
        
        itemIcon:setScale(0.65)
        itemIcon:setTag(self.kRewardItemTag1)
        giftItem:addChild(itemIcon)
    end
end

function ActivityTaskItemView1:updateUI()
    self:updateViewType1()
    --[[
    for viewType = ActivityTaskItemView1.kTaskType1, ActivityTaskItemView1.kTaskTypeEnd do
        repeat
            if viewType == self._viewType then
                self["_layerViewType" .. viewType]._layer:setVisible(true)
                break
            end
            self["_layerViewType" .. viewType]._layer:setVisible(false)
        until true
    end

    --dump(self._taskData, "ActivityTaskItemView1")
    --self:setSaturation(0 == self._taskData.statusInfo.status and -100 or 0)
    if self["updateViewType" .. self._viewType] and "function" == type(self["updateViewType" .. self._viewType]) then
        self["updateViewType" .. self._viewType](self)
    end
    ]]
end

function ActivityTaskItemView1:setContext(context)
    self._container = context.container
    self._taskData = context.taskData
    self._viewType = self._taskData.uitype
end

function ActivityTaskItemView1:onButtonGoClicked()
    if not (self._container and self._container.onButtonGoClicked) then return end
    self._container:onButtonGoClicked(self._taskData)
end

function ActivityTaskItemView1:onButtonGetClicked()
    if not (self._container and self._container.onButtonGetClicked) then return end
    self._container:onButtonGetClicked(self._taskData)
end

return ActivityTaskItemView1