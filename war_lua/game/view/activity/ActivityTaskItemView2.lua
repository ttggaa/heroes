--[[
    Filename:    ActivityTaskItemView2.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-01-30 16:48:59
    Description: File description
--]]


local ActivityTaskItemView2 = class("ActivityTaskItemView2", BaseLayer)

ActivityTaskItemView2.kItemContentSize = {
    width = 667,
    height = 110
}

ActivityTaskItemView2.kTaskType1 = 1 -- 累计充值
ActivityTaskItemView2.kTaskType2 = 2 -- 
ActivityTaskItemView2.kTaskType3 = 3
ActivityTaskItemView2.kTaskType4 = 4 -- 招募有利
ActivityTaskItemView2.kTaskTypeEnd = 4

ActivityTaskItemView2.kRewardItemTag1 = 1000

ActivityTaskItemView2.kRewardItemTag2 = 2000
ActivityTaskItemView2.kConsumeItemTag2 = 2001

ActivityTaskItemView2.kRewardItemTag3 = 3000
ActivityTaskItemView2.kConsumeItemTag3 = 3001

ActivityTaskItemView2.kRewardItemTag4 = 3000
ActivityTaskItemView2.kConsumeItemTag4 = 3001


function ActivityTaskItemView2:ctor(params)
    ActivityTaskItemView2.super.ctor(self)
    self.initAnimType = 1
    self._container = params.container
    self._taskData = params.taskData
    self._viewType = self._taskData.uitype
    self._teamModel = self._modelMgr:getModel("TeamModel")
end

function ActivityTaskItemView2:disableTextEffect(element)
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

function ActivityTaskItemView2:onInit()
    --print("ActivityTaskItemView2:onInit")
    self:disableTextEffect()

    -- view type 2
    self._layerViewType2 = {}
    self._layerViewType2._layer = self:getUI("layer_item_2")
    self._layerViewType2._layerGray = self:getUI("layer_item_2.layer_gray")
    self._layerViewType2._layerConsume = self:getUI("layer_item_2.layer_consume")
    self._layerViewType2._imageAlreadyGet = self:getUI("layer_item_2.image_already_get")
    self._layerViewType2._consumes = {}
    for i = 1, 1 do
        self._layerViewType2._consumes[i] = {}
        self._layerViewType2._consumes[i]._icon = self:getUI("layer_item_2.layer_consume.layer_item_" .. i)
    end

    self._layerViewType2._rewards = {}
    for i = 1, 1 do
        self._layerViewType2._rewards[i] = {}
        self._layerViewType2._rewards[i]._icon = self:getUI("layer_item_2.layer_reward.layer_item_" .. i)
    end

    self._layerViewType2._labelConsume = self:getUI("layer_item_2.label_consume")
    self._layerViewType2._labelConsume:enableOutline(cc.c4b(114, 66, 19), 2)
    self._layerViewType2._labelConsume:getVirtualRenderer():setAdditionalKerning(2)
    self._layerViewType2._labelExchange = self:getUI("layer_item_2.label_exchange")
    self._layerViewType2._labelExchange:enableOutline(cc.c4b(114, 66, 19), 2)
    self._layerViewType2._labelExchange:getVirtualRenderer():setAdditionalKerning(2)
    self._layerViewType2._labelReward = self:getUI("layer_item_2.label_reward")
    self._layerViewType2._labelReward:enableOutline(cc.c4b(114, 66, 19), 2)
    self._layerViewType2._labelReward:getVirtualRenderer():setAdditionalKerning(2)

    self._layerViewType2._taskCurrentData = self:getUI("layer_item_2.task_current_data")    
    self._layerViewType2._taskCurrentData:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- self._layerViewType2._taskCurrentData:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._layerViewType2._btnGo = self:getUI("layer_item_2.btn_go")
    self._layerViewType2._btnGet = self:getUI("layer_item_2.btn_get")

    -- self._layerViewType2._btnGo:setTitleFontName(UIUtils.ttfName)
    -- self._layerViewType2._btnGo:setTitleColor(cc.c4b(255, 250, 220, 255))
    -- self._layerViewType2._btnGo:getTitleRenderer():enableOutline(cc.c4b(5, 92, 144, 255), 3) --(cc.c4b(101, 33, 0, 255), 2)
    -- self._layerViewType2._btnGo:setTitleFontSize(28) 
    -- self._layerViewType2._btnGet:setTitleFontName(UIUtils.ttfName)
    -- self._layerViewType2._btnGet:setTitleColor(cc.c4b(255, 250, 220, 255))
    -- self._layerViewType2._btnGet:getTitleRenderer():enableOutline(cc.c4b(153, 93, 0, 255), 3) --(cc.c4b(101, 33, 0, 255), 2)
    -- self._layerViewType2._btnGet:setTitleFontSize(28) 

    self._layerViewType2._getMC = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true)
    self._layerViewType2._getMC:setPlaySpeed(1, true)
    self._layerViewType2._getMC:setPosition(self._layerViewType2._btnGet:getContentSize().width / 2 - 2, self._layerViewType2._btnGet:getContentSize().height / 2)
    self._layerViewType2._btnGet:addChild(self._layerViewType2._getMC)
    self:registerClickEvent(self._layerViewType2._btnGo, function ()
        self:onButtonGoClicked()
    end)

    self:registerClickEvent(self._layerViewType2._btnGet, function ()
        self:onButtonGetClicked()
    end)

    self:updateUI()
end

function ActivityTaskItemView2:updateViewType2()
    self._layerViewType2._layerGray:setVisible(0 == self._taskData.statusInfo.status)
    self._layerViewType2._btnGo:setVisible(-1 == self._taskData.statusInfo.status and self._taskData.button > 0)
	self._layerViewType2._btnGet:setVisible(1 == self._taskData.statusInfo.status or (-1 == self._taskData.statusInfo.status and 0 == self._taskData.button))
    --self._layerViewType2._btnGet:setEnabled(1 == self._taskData.statusInfo.status)
    self._layerViewType2._btnGet:setSaturation(1 == self._taskData.statusInfo.status and 0 or -100)
    self._layerViewType2._btnGet:setBright(1 == self._taskData.statusInfo.status)
    self._layerViewType2._getMC:setVisible(1 == self._taskData.statusInfo.status)
    self._layerViewType2._imageAlreadyGet:setVisible(0 == self._taskData.statusInfo.status)
    self._layerViewType2._taskCurrentData:setVisible(not self._layerViewType2._imageAlreadyGet:isVisible())
    --self._layerViewType2._taskCurrentData:setPositionY((self._layerViewType2._btnGo:isVisible() or self._layerViewType2._btnGet:isVisible()) and 90 or 60)
    if not self._taskData.finish_max then
        self._layerViewType2._taskCurrentData:setString(string.format("%d/%d", self._taskData.statusInfo.value, self._taskData.statusInfo.condition))
    else
        self._layerViewType2._taskCurrentData:setString(string.format("%d/%d", self._taskData.times, self._taskData.finish_max))
    end
    --[[
    local conditiontype = self._taskData.conditiontype
    if 101 == conditiontype or
       102 == conditiontype then
        self._layerViewType2._taskCurrentData:setVisible(true)
        if 0 == self._taskData.statusInfo.status then
            self._layerViewType2._taskCurrentData:setString("0/1")
        elseif 1 == self._taskData.statusInfo.status then
            self._layerViewType2._taskCurrentData:setString("1/1")
        else
            self._layerViewType2._taskCurrentData:setVisible(false)
        end
    elseif 998 == conditiontype then
        self._layerViewType2._taskCurrentData:setVisible(true)
        if 0 == self._taskData.statusInfo.status then
            self._layerViewType2._taskCurrentData:setString("未购买")
        elseif 1 == self._taskData.statusInfo.status then
            self._layerViewType2._taskCurrentData:setString("已购买")
            local restDay = math.floor((self._taskData.val2 - self._modelMgr:getModel("UserModel"):getCurServerTime()) / 86400)
        else
            self._layerViewType2._taskCurrentData:setVisible(false)
        end   
    elseif 999 == conditiontype then
        if 0 == self._taskData.statusInfo.status then
            self._layerViewType2._taskCurrentData:setString("时间未到")
        elseif self._taskData.statusInfo.status >= 1 then
            self._layerViewType2._taskCurrentData:setVisible(false)
        elseif -1 == self._taskData.statusInfo.status then
            self._layerViewType2._taskCurrentData:setString("时间已过")
        end
    else
        self._layerViewType2._taskCurrentData:setVisible(not self._layerViewType2._imageAlreadyGet:isVisible())
        self._layerViewType2._taskCurrentData:setString(string.format("%d/%d", tonumber(self._taskData.val2), tonumber(self._taskData.val1)))
    end
    ]]
    local toolTableData = tab.tool
    local staticConfigTableData = IconUtils.iconIdMap

    for i=1, 1 do
        self._layerViewType2._consumes[i]._icon:setVisible(false)
    end

    local giftContain = self._taskData.exchange_num
    local staticConfigTableData = IconUtils.iconIdMap
    for i = 1, --[[#giftContain]]1 do
        local giftItem = --[[1 == #giftContain and self._layerViewType2._consumes[2]._icon or]] self._layerViewType2._consumes[i]._icon
        giftItem:setVisible(true)
        local itemIcon = giftItem:getChildByTag(self.kConsumeItemTag2)
        if itemIcon then itemIcon:removeFromParent() end
        if giftContain[i][1] ~= "tool" and staticConfigTableData[giftContain[i][1]] then
            itemIcon = IconUtils:createItemIconById({itemId = staticConfigTableData[giftContain[i][1]], num = giftContain[i][3]})
            --[=[
            self:registerTouchEvent(giftItem, function(x, y)
                    self:startClock(giftItem, staticConfigTableData[giftContain[i][1]])
                end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
            ]=]
            self._layerViewType2._labelConsume:setString(lang(tab:Tool(staticConfigTableData[giftContain[i][1]]).name) .. "*" .. giftContain[i][3])
        elseif giftContain[i][1] == "tool" then
            itemIcon = IconUtils:createItemIconById({itemId = giftContain[i][2], num = giftContain[i][3]})
            --[[
            self:registerTouchEvent(giftItem, function(x, y)
                    self:startClock(giftItem, giftContain[i][2])
                end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
            ]]
            self._layerViewType2._labelConsume:setString(lang(tab:Tool(giftContain[i][2]).name) .. "*" .. giftContain[i][3])
        end

        itemIcon:setScale(0.65)
        itemIcon:setTag(self.kConsumeItemTag2)
        giftItem:addChild(itemIcon)
    end

    for i=1, 1 do
        self._layerViewType2._rewards[i]._icon:setVisible(false)
    end

    local giftContain = self._taskData.reward
    local staticConfigTableData = IconUtils.iconIdMap
    for i = 1, --[[#giftContain]]1 do
        local giftItem = --[[1 == #giftContain and self._layerViewType2._rewards[2]._icon or]] self._layerViewType2._rewards[i]._icon
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
            self._layerViewType2._labelReward:setString(lang(tab:Tool(staticConfigTableData[giftContain[i][1]]).name) .. "*" .. giftContain[i][3])
        elseif giftContain[i][1] == "tool" then
            itemIcon = IconUtils:createItemIconById({itemId = giftContain[i][2], num = giftContain[i][3]})
            --[[
            self:registerTouchEvent(giftItem, function(x, y)
                    self:startClock(giftItem, giftContain[i][2])
                end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
            ]]
            self._layerViewType2._labelReward:setString(lang(tab:Tool(giftContain[i][2]).name) .. "*" .. giftContain[i][3])
        end
        itemIcon:setScale(0.65)
        itemIcon:setTag(self.kRewardItemTag2)
        giftItem:addChild(itemIcon)
    end
end

function ActivityTaskItemView2:updateUI()
    self:updateViewType2()
    --[[
    for viewType = ActivityTaskItemView2.kTaskType1, ActivityTaskItemView2.kTaskTypeEnd do
        repeat
            if viewType == self._viewType then
                self["_layerViewType" .. viewType]._layer:setVisible(true)
                break
            end
            self["_layerViewType" .. viewType]._layer:setVisible(false)
        until true
    end

    --dump(self._taskData, "ActivityTaskItemView2")
    --self:setSaturation(0 == self._taskData.statusInfo.status and -100 or 0)
    if self["updateViewType" .. self._viewType] and "function" == type(self["updateViewType" .. self._viewType]) then
        self["updateViewType" .. self._viewType](self)
    end
    ]]
end

function ActivityTaskItemView2:setContext(context)
    self._container = context.container
    self._taskData = context.taskData
    self._viewType = self._taskData.uitype
end

function ActivityTaskItemView2:onButtonGoClicked()
    if not (self._container and self._container.onButtonGoClicked) then return end
    self._container:onButtonGoClicked(self._taskData)
end

function ActivityTaskItemView2:onButtonGetClicked()
    if not (self._container and self._container.onButtonGetClicked) then return end
    self._container:onButtonGetClicked(self._taskData)
end

return ActivityTaskItemView2