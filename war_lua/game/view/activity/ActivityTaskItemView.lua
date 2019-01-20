--[[
    Filename:    ActivityTaskItemView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-01-30 16:48:59
    Description: File description
--]]


local ActivityTaskItemView = class("ActivityTaskItemView", BaseLayer)

ActivityTaskItemView.kItemContentSize = {
    width = 667,
    height = 111
}

ActivityTaskItemView.kTaskType1 = 1 -- 累计充值
ActivityTaskItemView.kTaskType2 = 2 -- 
ActivityTaskItemView.kTaskType3 = 3
ActivityTaskItemView.kTaskType4 = 4 -- 招募有利
ActivityTaskItemView.kTaskType5 = 5 -- 四选一
ActivityTaskItemView.kTaskType6 = 6
ActivityTaskItemView.kTaskTypeEnd = 7

ActivityTaskItemView.kRewardItemTag1 = 1000

ActivityTaskItemView.kRewardItemTag2 = 2000
ActivityTaskItemView.kConsumeItemTag2 = 2001

ActivityTaskItemView.kRewardItemTag3 = 3000
ActivityTaskItemView.kConsumeItemTag3 = 3001

ActivityTaskItemView.kRewardItemTag4 = 3000
ActivityTaskItemView.kConsumeItemTag4 = 3001


function ActivityTaskItemView:ctor(params)
    ActivityTaskItemView.super.ctor(self)
    self.initAnimType = 1
    self._container = params.container
    self._taskData = params.taskData
    self._viewType = self._taskData.uitype
    self._isHideConditionValue = params.isHideConditionValue
    self._tmpShowBuy = params.tmpShowBuy
    self._tmpShowRematinTimes = params.tmpShowRematinTimes
    self._teamModel = self._modelMgr:getModel("TeamModel")
    -- print("============self._viewType=====",self._viewType)
end

function ActivityTaskItemView:disableTextEffect(element)
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

function ActivityTaskItemView:onInit()
    --print("ActivityTaskItemView:onInit")
    self:disableTextEffect()

    -- view type 1
    self._layerViewType1 = {}
    self._layerViewType1._layer = self:getUI("layer_item_1")
    self._layerViewType1._layerGray = self:getUI("layer_item_1.layer_gray")
    -- self._layerViewType1._taskDescriptionBg = self:getUI("layer_item_1.task_des_bg")
    self._layerViewType1._taskDescription = self:getUI("layer_item_1.task_description")
    self._layerViewType1._taskCurrentDataBg = self:getUI("layer_item_1.task_current_data_bg")
    self._layerViewType1._taskCurrentData = self:getUI("layer_item_1.task_current_data_bg.task_current_data")
    self._layerViewType1._taskCurrentData:setColor(cc.c3b(138, 92, 29))
    -- self._layerViewType1._taskCurrentData:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._layerViewType1._taskCurrentDataBg0 = self:getUI("layer_item_1.task_current_data_bg0")
    self._layerViewType1._taskCurrentData0 = self:getUI("layer_item_1.task_current_data_bg0.task_current_data")
    self._layerViewType1._taskCurrentData0:setColor(cc.c3b(138, 92, 29))

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
        self._layerViewType2._rewards[i]._tag = self:getUI("layer_item_2.layer_reward.layer_item_" .. i .. ".image_tag")
        self._layerViewType2._rewards[i]._labelTag = self:getUI("layer_item_2.layer_reward.layer_item_" .. i .. ".image_tag.label_tag")
        self._layerViewType2._rewards[i]._labelTag:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        self._layerViewType2._rewards[i]._labelTag:setFontName(UIUtils.ttfName)
    end

    self._layerViewType2._labelConsume = self:getUI("layer_item_2.label_consume")
    --self._layerViewType2._labelConsume:enableOutline(cc.c4b(114, 66, 19), 2)
    self._layerViewType2._labelConsume:getVirtualRenderer():setAdditionalKerning(2)
    self._layerViewType2._labelExchange = self:getUI("layer_item_2.label_exchange")
    
    -- self._layerViewType2._labelExchange:enableOutline(cc.c4b(114, 66, 19), 2)
    self._layerViewType2._labelExchange:getVirtualRenderer():setAdditionalKerning(2)
    self._layerViewType2._labelReward = self:getUI("layer_item_2.label_reward")
    -- self._layerViewType2._labelReward:enableOutline(cc.c4b(114, 66, 19), 2)
    self._layerViewType2._labelReward:getVirtualRenderer():setAdditionalKerning(2)

    self._layerViewType2._taskCurrentDataBg = self:getUI("layer_item_2.task_current_data_bg")
    self._layerViewType2._taskCurrentData = self:getUI("layer_item_2.task_current_data")    
    self._layerViewType2._taskCurrentData:setColor(cc.c3b(138, 92, 29))
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

    -- view type 3
    self._layerViewType3 = {}
    self._layerViewType3._layer = self:getUI("layer_item_3")
    self._layerViewType3._layerGray = self:getUI("layer_item_3.layer_gray")
    self._layerViewType3._layerConsume = self:getUI("layer_item_3.layer_consume")
    self._layerViewType3._imageAlreadyGet = self:getUI("layer_item_3.image_already_get")
    self._layerViewType3._consumes = {}
    for i = 1, 3 do
        self._layerViewType3._consumes[i] = {}
        self._layerViewType3._consumes[i]._icon = self:getUI("layer_item_3.layer_consume.layer_item_" .. i)
    end

    self._layerViewType3._rewards = {}
    for i = 1, 1 do
        self._layerViewType3._rewards[i] = {}
        self._layerViewType3._rewards[i]._icon = self:getUI("layer_item_3.layer_reward.layer_item_" .. i)
        local labelTag = self:getUI("layer_item_3.layer_reward.layer_item_" .. i .. ".image_tag.label_tag")
        if labelTag then
            labelTag:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            labelTag:setFontName(UIUtils.ttfName)
        end
    end

    -- self._layerViewType3._taskDescriptionBg = self:getUI("layer_item_3.task_des_bg")
    self._layerViewType3._taskDescription = self:getUI("layer_item_3.task_description")
    self._layerViewType3._taskCurrentDataBg = self:getUI("layer_item_3.task_current_data_bg")
    self._layerViewType3._taskCurrentData = self:getUI("layer_item_3.task_current_data")
    self._layerViewType3._taskCurrentData:setColor(cc.c3b(138, 92, 29))
    -- self._layerViewType3._taskCurrentData:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._layerViewType3._btnGo = self:getUI("layer_item_3.btn_go")
    self._layerViewType3._btnGet = self:getUI("layer_item_3.btn_get")

    -- self._layerViewType3._btnGo:setTitleFontName(UIUtils.ttfName)
    -- self._layerViewType3._btnGo:setTitleColor(cc.c4b(255, 250, 220, 255))
    -- self._layerViewType3._btnGo:getTitleRenderer():enableOutline(cc.c4b(5, 92, 144, 255), 3) --(cc.c4b(101, 33, 0, 255), 2)
    -- self._layerViewType3._btnGo:setTitleFontSize(28) 
    -- self._layerViewType3._btnGet:setTitleFontName(UIUtils.ttfName)
    -- self._layerViewType3._btnGet:setTitleColor(cc.c4b(255, 250, 220, 255))
    -- self._layerViewType3._btnGet:getTitleRenderer():enableOutline(cc.c4b(153, 93, 0, 255), 3) --(cc.c4b(101, 33, 0, 255), 2)
    -- self._layerViewType3._btnGet:setTitleFontSize(28) 

    self._layerViewType3._getMC = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true)
    self._layerViewType3._getMC:setPlaySpeed(1, true)
    self._layerViewType3._getMC:setPosition(self._layerViewType3._btnGet:getContentSize().width / 2 - 2, self._layerViewType3._btnGet:getContentSize().height / 2)
    self._layerViewType3._btnGet:addChild(self._layerViewType3._getMC)
    self:registerClickEvent(self._layerViewType3._btnGo, function ()
        self:onButtonGoClicked()
    end)

    self:registerClickEvent(self._layerViewType3._btnGet, function ()
        self:onButtonGetClicked()
    end)

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
    for i = 1, 2 do
        self._layerViewType4._rewards[i] = {}
        self._layerViewType4._rewards[i]._icon = self:getUI("layer_item_4.layer_reward.layer_item_" .. i)
    end

    -- self._layerViewType4._taskDescriptionBg = self:getUI("layer_item_4.task_des_bg")
    self._layerViewType4._taskDescription = self:getUI("layer_item_4.task_description")
    self._layerViewType4._taskCurrentDataBg = self:getUI("layer_item_4.task_current_data_bg")
    self._layerViewType4._taskCurrentData = self:getUI("layer_item_4.task_current_data")
    self._layerViewType4._taskCurrentData:setColor(cc.c3b(138, 92, 29))
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

    -- vier type 5
    self._layerViewType5 = {}
    self._layerViewType5._layer = self:getUI("layer_item_5")
    self._layerViewType5._layerGray = self:getUI("layer_item_5.layer_gray")
    -- self._layerViewType5._taskDescriptionBg = self:getUI("layer_item_5.task_des_bg")
    self._layerViewType5._taskDescription = self:getUI("layer_item_5.task_description")
    self._layerViewType5._taskCurrentDataBg = self:getUI("layer_item_5.task_current_data_bg")
    self._layerViewType5._taskCurrentData = self:getUI("layer_item_5.task_current_data")
    self._layerViewType5._taskCurrentData:setColor(cc.c3b(138, 92, 29))
    -- self._layerViewType5._taskCurrentData:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._layerViewType5._btnGo = self:getUI("layer_item_5.btn_go")
    self._layerViewType5._btnGet = self:getUI("layer_item_5.btn_get")
    -- self._layerViewType5._btnGo:setTitleFontName(UIUtils.ttfName)
    -- self._layerViewType5._btnGo:setTitleColor(cc.c4b(255, 250, 220, 255))
    -- self._layerViewType5._btnGo:getTitleRenderer():enableOutline(cc.c4b(5, 92, 144, 255), 3) --(cc.c4b(101, 33, 0, 255), 2)
    -- self._layerViewType5._btnGo:setTitleFontSize(28) 
    -- self._layerViewType5._btnGet:setTitleFontName(UIUtils.ttfName)
    -- self._layerViewType5._btnGet:setTitleColor(cc.c4b(255, 250, 220, 255))
    -- self._layerViewType5._btnGet:getTitleRenderer():enableOutline(cc.c4b(153, 93, 0, 255), 3) --(cc.c4b(101, 33, 0, 255), 2)
    -- self._layerViewType5._btnGet:setTitleFontSize(28) 

    self._layerViewType5._getMC = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true)
    self._layerViewType5._getMC:setPlaySpeed(1, true)
    self._layerViewType5._getMC:setPosition(self._layerViewType5._btnGet:getContentSize().width / 2 - 2, self._layerViewType5._btnGet:getContentSize().height / 2)
    self._layerViewType5._btnGet:addChild(self._layerViewType5._getMC)
    self:registerClickEvent(self._layerViewType5._btnGo, function ()
        self:onButtonGoClicked()
    end)

    self:registerClickEvent(self._layerViewType5._btnGet, function ()
        self:onButtonGetClicked()
    end)
    --[[
    self._layerViewType5._getMC2 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true)
    self._layerViewType5._getMC2:setPlaySpeed(1, true)
    self._layerViewType5._getMC2:setPosition(self._layerViewType5._btnGet:getContentSize().width / 2, self._layerViewType5._btnGet:getContentSize().height / 2)
    self._layerViewType5._btnGet:addChild(self._layerViewType5._getMC2)
    ]]
    self._layerViewType5._imageAlreadyGet = self:getUI("layer_item_5.image_already_get")

    self._layerViewType5._rewards = {}
    for i = 1, 4 do
        self._layerViewType5._rewards[i] = {}
        self._layerViewType5._rewards[i]._icon = self:getUI("layer_item_5.layer_reward_bg.layer_reward_" .. i)
    end

    self._layerViewType5._or = {}
    for i = 1, 3 do
        self._layerViewType5._or[i] = self:getUI("layer_item_5.layer_reward_bg.label_or_" .. i)
    end

    -- view type 6
    self._layerViewType6 = {}
    self._layerViewType6._layer = self:getUI("layer_item_6")
    self._layerViewType6._layerGray = self:getUI("layer_item_6.layer_gray")
    self._layerViewType6._layerConsume = self:getUI("layer_item_6.layer_consume")
    self._layerViewType6._imageAlreadyGet = self:getUI("layer_item_6.image_already_get")

    self._layerViewType6._rewards = {}
    for i = 1, 4 do
        self._layerViewType6._rewards[i] = {}
        self._layerViewType6._rewards[i]._icon = self:getUI("layer_item_6.layer_reward.layer_item_" .. i)
    end

    -- self._layerViewType6._taskDescriptionBg = self:getUI("layer_item_6.task_des_bg")
    self._layerViewType6._taskDescription = self:getUI("layer_item_6.task_description")
    self._layerViewType6._taskCurrentDataBg = self:getUI("layer_item_6.task_current_data_bg")
    self._layerViewType6._taskCurrentData = self:getUI("layer_item_6.task_current_data")
    self._layerViewType6._taskCurrentData:setColor(cc.c3b(138, 92, 29))
    -- self._layerViewType6._taskCurrentData:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._layerViewType6._btnGo = self:getUI("layer_item_6.btn_go")
    self._layerViewType6._btnGet = self:getUI("layer_item_6.btn_get")

    -- self._layerViewType6._btnGo:setTitleFontName(UIUtils.ttfName)
    -- self._layerViewType6._btnGo:setTitleColor(cc.c4b(255, 250, 220, 255))
    -- self._layerViewType6._btnGo:getTitleRenderer():enableOutline(cc.c4b(5, 92, 144, 255), 3) --(cc.c4b(101, 33, 0, 255), 2)
    -- self._layerViewType6._btnGo:setTitleFontSize(28) 
    -- self._layerViewType6._btnGet:setTitleFontName(UIUtils.ttfName)
    -- self._layerViewType6._btnGet:setTitleColor(cc.c4b(255, 250, 220, 255))
    -- self._layerViewType6._btnGet:getTitleRenderer():enableOutline(cc.c4b(153, 93, 0, 255), 3) --(cc.c4b(101, 33, 0, 255), 2)
    -- self._layerViewType6._btnGet:setTitleFontSize(28) 

    self._layerViewType6._getMC = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true)
    self._layerViewType6._getMC:setPlaySpeed(1, true)
    self._layerViewType6._getMC:setPosition(self._layerViewType6._btnGet:getContentSize().width / 2 - 2, self._layerViewType6._btnGet:getContentSize().height / 2)
    self._layerViewType6._btnGet:addChild(self._layerViewType6._getMC)
    self:registerClickEvent(self._layerViewType6._btnGo, function ()
        self:onButtonGoClicked()
    end)

    self:registerClickEvent(self._layerViewType6._btnGet, function ()
        self:onButtonGetClicked()
    end)

    self:updateUI()
end
local discountToCn = {
    "一折","二折","三折",
    "四折","五折","六折",
    "七折","八折","九折",
}
function ActivityTaskItemView:updateViewType1()
    if  self._taskData and self._taskData.discount_label then
        if not self._layerViewType1._btnGet.__flag then
            local disCountImg = ccui.ImageView:create()
            disCountImg:loadTexture("globalImageUI6_connerTag_L.png",1)
            disCountImg:setPosition(29,31)
            disCountImg:setScale(0.8)
            self._layerViewType1._btnGet:addChild(disCountImg)
            local txt = ccui.Text:create()
            txt:setFontSize(20)
            txt:setFontName(UIUtils.ttfName)
            if discountToCn[math.ceil(self._taskData.discount_label/100)] then 
                txt:setString(discountToCn[math.ceil(self._taskData.discount_label/100)])
            else
                txt:setString("") 
            end
            txt:setPosition(25,35)
            txt:setRotation(-45)
            txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            disCountImg:addChild(txt,1)
            self._layerViewType1._btnGet.__flag = disCountImg
            self._layerViewType1._btnGet.__flagTxt = txt
        else
            self._layerViewType1._btnGet.__flag:setVisible(true)
            if discountToCn[math.ceil(self._taskData.discount_label/100)] then 
                self._layerViewType1._btnGet.__flagTxt:setString(discountToCn[math.ceil(self._taskData.discount_label/100)])
            else
                self._layerViewType1._btnGet.__flagTxt:setString("") 
            end  
        end
    else
        if self._layerViewType1._btnGet.__flag then
            self._layerViewType1._btnGet.__flag:setVisible(false)
        end
    end
    self._layerViewType1._layerGray:setVisible(0 == self._taskData.statusInfo.status)
    self._layerViewType1._btnGo:setVisible(-1 == self._taskData.statusInfo.status and self._taskData.button > 0)
    self._layerViewType1._btnGet:setVisible(1 == self._taskData.statusInfo.status or (-1 == self._taskData.statusInfo.status and 0 == self._taskData.button))
    --self._layerViewType1._btnGet:setEnabled(1 == self._taskData.statusInfo.status)
    self._layerViewType1._btnGet:setSaturation(1 == self._taskData.statusInfo.status and 0 or -100)
    self._layerViewType1._btnGet:setBright(1 == self._taskData.statusInfo.status)
    self._layerViewType1._getMC:setVisible(1 == self._taskData.statusInfo.status)
    self._layerViewType1._imageAlreadyGet:setVisible(0 == self._taskData.statusInfo.status)
    self._layerViewType1._taskCurrentDataBg:setVisible(not self._layerViewType1._imageAlreadyGet:isVisible() and not self._isHideConditionValue and not self._tmpShowRematinTimes)
    -- self._layerViewType1._taskCurrentData:setVisible(not self._layerViewType1._imageAlreadyGet:isVisible() and not self._isHideConditionValue)
    self._layerViewType1._taskCurrentData:setColor(1 == self._taskData.statusInfo.status and cc.c3b(28, 162, 22) or cc.c3b(138, 92, 29))
    --self._layerViewType1._taskCurrentData:setVisible(not self._layerViewType1._imageAlreadyGet:isVisible() and not (self._isHideConditionValue and 1 == self._taskData.statusInfo.condition)) -- temp code fixed me
    self._layerViewType1._taskCurrentDataBg0:setVisible(not self._layerViewType1._imageAlreadyGet:isVisible() and not self._isHideConditionValue and self._tmpShowRematinTimes)
    self._layerViewType1._taskCurrentData0:setColor(1 == self._taskData.statusInfo.status and cc.c3b(28, 162, 22) or cc.c3b(138, 92, 29))
    self._layerViewType1._btnGet:setPositionY(self._layerViewType1._taskCurrentData:isVisible() and 50 or 65)
    self._layerViewType1._btnGo:setPositionY(self._layerViewType1._taskCurrentData:isVisible() and 50 or 65)
    -- tmp code
    if self._tmpShowBuy then
        self._layerViewType1._btnGet:setTitleText("购买")
    end
    -- tmp code
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
    local labelCurrentData = self._tmpShowRematinTimes and self._layerViewType1._taskCurrentData0 or self._layerViewType1._taskCurrentData
    if not self._taskData.finish_max then
        labelCurrentData:setString(string.format("%d/%d", self._taskData.statusInfo.value, self._taskData.statusInfo.condition))
    else
        labelCurrentData:setString(string.format("%d/%d", self._taskData.times, self._taskData.finish_max))
    end
    -- self._layerViewType1._taskDescriptionBg:setContentSize(cc.size(math.max(richText:getInnerSize().width + 40, 160), 32))
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

    for i=1, 4 do
        self._layerViewType1._rewards[i]._icon:setVisible(false)
    end

    local giftContain = self._taskData.reward
    for i = 1, #giftContain do
        local giftItem = self._layerViewType1._rewards[i]._icon
        giftItem:setVisible(true)
        local itemIcon = giftItem:getChildByTag(self.kRewardItemTag1)
        if itemIcon then itemIcon:removeFromParent() end
        local itemId = giftContain[i][2]
        local itemType = giftContain[i][1]
        local eventStyle = 1--{itemId = itemId, num = num,eventStyle = 0} 
        if itemType == "hero" then
            local heroData = clone(tab:Hero(itemId))
            itemIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
            --itemIcon:setAnchorPoint(cc.p(0, 0))
            itemIcon:getChildByName("starBg"):setVisible(false)
            for i=1,6 do
                if itemIcon:getChildByName("star" .. i) then
                    itemIcon:getChildByName("star" .. i):setPositionY(itemIcon:getChildByName("star" .. i):getPositionY() + 5)
                end
            end
            itemIcon:setPosition(giftItem:getContentSize().width / 2, giftItem:getContentSize().height / 2)
            itemIcon:setSwallowTouches(false)
            registerClickEvent(itemIcon, function()
                local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = itemId}, true)
            end)
        elseif itemType == "team" then
            local teamTeam = clone(tab:Team(itemId))
            itemIcon = IconUtils:createSysTeamIconById({sysTeamData = teamTeam,isJin=true})
            --itemIcon:setAnchorPoint(cc.p(0,0))
            --itemIcon:setSwallowTouches(false)
        elseif itemType == "avatarFrame" then
            local frameData = tab:AvatarFrame(itemId)
            param = {itemId = itemId, itemData = frameData}
            itemIcon = IconUtils:createHeadFrameIconById(param)
        elseif itemType == "siegeProp" then
            self.rewardsSiegeProp = true
            local propsTab = tab:SiegeEquip(itemId)
            local param = {itemId = itemId, level = 1, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 1}
            itemIcon = IconUtils:createWeaponsBagItemIcon(param)
        elseif itemType == "rune" then
            local runeData = tab:Rune(itemId)
            itemIcon =IconUtils:createHolyIconById({suitData = runeData})
        else
            if itemType ~= "tool" then
                itemId = IconUtils.iconIdMap[itemType]
            end
            itemIcon = IconUtils:createItemIconById({itemId = itemId, num = giftContain[i][3],eventStyle = eventStyle})
        end
        local scale = 0.71
        if itemType == "team" or itemType == "hero" then
            scale = 0.61
        elseif itemType == "avatarFrame" then
            scale = 0.58
        end
        itemIcon:setScale(scale)
        itemIcon:setTag(self.kRewardItemTag1)
        giftItem:addChild(itemIcon)
        --[==[
        if giftContain[i][1] ~= "tool" and IconUtils.iconIdMap[giftContain[i][1]] then
            itemId = IconUtils.iconIdMap[giftContain[i][1]]
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
        
        itemIcon:setScale(0.71)
        itemIcon:setTag(self.kRewardItemTag1)
        giftItem:addChild(itemIcon)
        ]==]
    end
end

function ActivityTaskItemView:updateViewType7()
    self:updateViewType2()
end

function ActivityTaskItemView:updateViewType2()
    if  self._taskData and self._taskData.discount_label then
        if not self._layerViewType2._btnGet.__flag then
            local disCountImg = ccui.ImageView:create()
            disCountImg:loadTexture("globalImageUI6_connerTag_L.png",1)
            disCountImg:setPosition(29,31)
            disCountImg:setScale(0.8)
            self._layerViewType2._btnGet:addChild(disCountImg)
            local txt = ccui.Text:create()
            txt:setFontSize(20)
            txt:setFontName(UIUtils.ttfName)
            if discountToCn[math.ceil(self._taskData.discount_label/100)] then 
                txt:setString(discountToCn[math.ceil(self._taskData.discount_label/100)])
            else
                txt:setString("") 
            end
            txt:setPosition(25,35)
            txt:setRotation(-45)
            txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            disCountImg:addChild(txt,1)
            self._layerViewType2._btnGet.__flag = disCountImg
            self._layerViewType2._btnGet.__flagTxt = txt
        else
            self._layerViewType2._btnGet.__flag:setVisible(true)
            if discountToCn[math.ceil(self._taskData.discount_label/100)] then 
                self._layerViewType2._btnGet.__flagTxt:setString(discountToCn[math.ceil(self._taskData.discount_label/100)])
            else
                self._layerViewType2._btnGet.__flagTxt:setString("") 
            end            
        end
    else
        if self._layerViewType2._btnGet.__flag then
            self._layerViewType2._btnGet.__flag:setVisible(false)
        end
    end
    self._layerViewType2._layerGray:setVisible(0 == self._taskData.statusInfo.status)
    self._layerViewType2._btnGo:setVisible(-1 == self._taskData.statusInfo.status and self._taskData.button > 0)
	self._layerViewType2._btnGet:setVisible(1 == self._taskData.statusInfo.status or (-1 == self._taskData.statusInfo.status and 0 == self._taskData.button))
    --self._layerViewType2._btnGet:setEnabled(1 == self._taskData.statusInfo.status)
    self._layerViewType2._btnGet:setSaturation(1 == self._taskData.statusInfo.status and 0 or -100)
    self._layerViewType2._btnGet:setBright(1 == self._taskData.statusInfo.status)
    self._layerViewType2._getMC:setVisible(1 == self._taskData.statusInfo.status)
    self._layerViewType2._imageAlreadyGet:setVisible(0 == self._taskData.statusInfo.status)
    self._layerViewType2._taskCurrentDataBg:setVisible(not self._layerViewType2._imageAlreadyGet:isVisible() and not self._isHideConditionValue)
    --self._layerViewType2._taskCurrentData:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._layerViewType2._taskCurrentData:setVisible(not self._layerViewType2._imageAlreadyGet:isVisible() and not self._isHideConditionValue)
    self._layerViewType2._taskCurrentData:setColor(1 == self._taskData.statusInfo.status and cc.c3b(28, 162, 22) or cc.c3b(138, 92, 29))
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
    local preConditionUiType = 7
    self._layerViewType2._labelExchange:setVisible(not (self._taskData.uitype == preConditionUiType))
    
    for i=1, 1 do
        self._layerViewType2._consumes[i]._icon:setVisible(false)
    end

    local giftContain = self._taskData.exchange_num

    for i = 1, --[[#giftContain]]1 do
        local giftItem = --[[1 == #giftContain and self._layerViewType2._consumes[2]._icon or]] self._layerViewType2._consumes[i]._icon
        giftItem:setVisible(true)
        local itemIcon = giftItem:getChildByTag(self.kConsumeItemTag2)
        if itemIcon then itemIcon:removeFromParent() end
        local itemId = giftContain[i][2]
        local itemType = giftContain[i][1]
        local eventStyle = 1--{itemId = itemId, num = num,eventStyle = 0} 
        if itemType == "hero" then
            local heroData = clone(tab:Hero(itemId))
            itemIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
            --itemIcon:setAnchorPoint(cc.p(0, 0))
            itemIcon:getChildByName("starBg"):setVisible(false)
            for i=1,6 do
                if itemIcon:getChildByName("star" .. i) then
                    itemIcon:getChildByName("star" .. i):setPositionY(itemIcon:getChildByName("star" .. i):getPositionY() + 5)
                end
            end
            itemIcon:setPosition(giftItem:getContentSize().width / 2, giftItem:getContentSize().height / 2)
            itemIcon:setSwallowTouches(false)
            registerClickEvent(itemIcon, function()
                local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = itemId}, true)
            end)
        elseif itemType == "team" then
            local teamTeam = clone(tab:Team(itemId))
            itemIcon = IconUtils:createSysTeamIconById({sysTeamData = teamTeam,isJin=true})
            --itemIcon:setAnchorPoint(cc.p(0,0))
            --itemIcon:setSwallowTouches(false)
        elseif itemType == "avatarFrame" then
            local frameData = tab:AvatarFrame(itemId)
            param = {itemId = itemId, itemData = frameData}
            itemIcon = IconUtils:createHeadFrameIconById(param)
        elseif itemType == "siegeProp" then
            self.rewardsSiegeProp = true
            local propsTab = tab:SiegeEquip(itemId)
            local param = {itemId = itemId, level = 1, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 1}
            itemIcon = IconUtils:createWeaponsBagItemIcon(param)
        elseif itemType == "rune" then
            local runeData = tab:Rune(itemId)
            itemIcon =IconUtils:createHolyIconById({suitData = runeData})
        else
            if itemType ~= "tool" then
                itemId = IconUtils.iconIdMap[itemType]
            end
            itemIcon = IconUtils:createItemIconById({itemId = itemId, num = giftContain[i][3],eventStyle = eventStyle})

            if self._taskData.uitype == preConditionUiType then
                self._layerViewType2._labelConsume:setString(lang(self._taskData.description))
            else
                self._layerViewType2._labelConsume:setString(lang(tab:Tool(itemId).name) .. "*" .. giftContain[i][3])
            end 
        end

        local scale = 0.71
        if itemType == "team" or itemType == "hero" then
            scale = 0.61
        elseif itemType == "avatarFrame" then
            scale = 0.58
        end
        itemIcon:setScale(scale)
        itemIcon:setTag(self.kConsumeItemTag2)
        giftItem:addChild(itemIcon)
    end

    for i=1, 1 do
        self._layerViewType2._rewards[i]._icon:setVisible(false)
    end

    local giftContain = self._taskData.reward
    for i = 1, --[[#giftContain]]1 do
        local giftItem = --[[1 == #giftContain and self._layerViewType2._rewards[2]._icon or]] self._layerViewType2._rewards[i]._icon
        giftItem:setVisible(true)
        local itemIcon = giftItem:getChildByTag(self.kRewardItemTag2)
        if itemIcon then 
            self._layerViewType2._rewards[i]._tag:retain()
            self._layerViewType2._rewards[i]._tag:removeFromParent()
            giftItem:addChild(self._layerViewType2._rewards[i]._tag)
            self._layerViewType2._rewards[i]._tag:release()
            itemIcon:removeFromParent() 
        end
        local itemId = giftContain[i][2]
        local itemType = giftContain[i][1]
        local eventStyle = 1--{itemId = itemId, num = num,eventStyle = 0} 
        if itemType == "hero" then
            local heroData = clone(tab:Hero(itemId))
            itemIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
            --itemIcon:setAnchorPoint(cc.p(0, 0))
            itemIcon:getChildByName("starBg"):setVisible(false)
            for i=1,6 do
                if itemIcon:getChildByName("star" .. i) then
                    itemIcon:getChildByName("star" .. i):setPositionY(itemIcon:getChildByName("star" .. i):getPositionY() + 5)
                end
            end
            itemIcon:setPosition(giftItem:getContentSize().width / 2, giftItem:getContentSize().height / 2)
            itemIcon:setSwallowTouches(false)
            registerClickEvent(itemIcon, function()
                local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = itemId}, true)
            end)
            self._layerViewType2._labelReward:setString(lang(heroData.heroname) .. "*" .. giftContain[i][3])
        elseif itemType == "team" then
            local teamData = clone(tab:Team(itemId))
            itemIcon = IconUtils:createSysTeamIconById({sysTeamData = teamData,isJin=true})
            --itemIcon:setAnchorPoint(cc.p(0,0))
            --itemIcon:setSwallowTouches(false)
            self._layerViewType2._labelReward:setString(lang(teamData.name) .. "*" .. giftContain[i][3])
        elseif itemType == "avatarFrame" then
            local frameData = tab:AvatarFrame(itemId)
            param = {itemId = itemId, itemData = frameData}
            itemIcon = IconUtils:createHeadFrameIconById(param)
            self._layerViewType2._labelReward:setString(lang(frameData.name) .. "*" .. giftContain[i][3])
        elseif itemType == "siegeProp" then
            self.rewardsSiegeProp = true
            local propsTab = tab:SiegeEquip(itemId)
            local param = {itemId = itemId, level = 1, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 1}
            itemIcon = IconUtils:createWeaponsBagItemIcon(param)
            self._layerViewType2._labelReward:setString(lang(propsTab.name) .. "*" .. giftContain[i][3])
        elseif itemType == "rune" then
            local runeData = tab:Rune(itemId)
            itemIcon =IconUtils:createHolyIconById({suitData = runeData})
            self._layerViewType2._labelReward:setString(lang(runeData.name) .. "*" .. giftContain[i][3])
        else
            if itemType ~= "tool" then
                itemId = IconUtils.iconIdMap[itemType]
            end
            itemIcon = IconUtils:createItemIconById({itemId = itemId, num = giftContain[i][3],eventStyle = eventStyle})
            
            if self._taskData.uitype == preConditionUiType then
                self._layerViewType2._labelReward:setString("")
            else
                self._layerViewType2._labelReward:setString(lang(tab:Tool(itemId).name) .. "*" .. giftContain[i][3])
            end 
        end

        local scale = 0.71
        if itemType == "team" or itemType == "hero" then
            scale = 0.61
        elseif itemType == "avatarFrame" then
            scale = 0.58
        end
        itemIcon:setScale(scale)
        itemIcon:setTag(self.kRewardItemTag2)
        self._layerViewType2._rewards[i]._tag:retain()
        self._layerViewType2._rewards[i]._tag:removeFromParent()
        self._layerViewType2._rewards[i]._tag:setScale(1.2)
        self._layerViewType2._rewards[i]._tag:setPosition(41, 58)
        local iconColor = itemIcon:getChildByFullName("iconColor")
        if iconColor then
            iconColor:addChild(self._layerViewType2._rewards[i]._tag, 100)
        else
            itemIcon:addChild(self._layerViewType2._rewards[i]._tag, 100)
        end
        self._layerViewType2._rewards[i]._tag:release()
        giftItem:addChild(itemIcon)

        self._layerViewType2._rewards[i]._tag:setVisible(1 == self._taskData.biaoqian)
    end
end

function ActivityTaskItemView:updateViewType3()
    if  self._taskData and self._taskData.discount_label then
        if not self._layerViewType3._btnGet.__flag then
            local disCountImg = ccui.ImageView:create()
            disCountImg:loadTexture("globalImageUI6_connerTag_L.png",1)
            disCountImg:setPosition(29,31)
            disCountImg:setScale(0.8)
            self._layerViewType3._btnGet:addChild(disCountImg)
            local txt = ccui.Text:create()
            txt:setFontSize(20)
            txt:setFontName(UIUtils.ttfName)
            if discountToCn[math.ceil(self._taskData.discount_label/100)] then 
                txt:setString(discountToCn[math.ceil(self._taskData.discount_label/100)])
            else
                txt:setString("") 
            end
            txt:setPosition(25,35)
            txt:setRotation(-45)
            txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            disCountImg:addChild(txt,1)
            self._layerViewType3._btnGet.__flag = disCountImg
            self._layerViewType3._btnGet.__flagTxt = txt
        else
            self._layerViewType3._btnGet.__flag:setVisible(true)
            if discountToCn[math.ceil(self._taskData.discount_label/100)] then 
                self._layerViewType3._btnGet.__flagTxt:setString(discountToCn[math.ceil(self._taskData.discount_label/100)])
            else
                self._layerViewType3._btnGet.__flagTxt:setString("") 
            end
        end
    else
        if self._layerViewType3._btnGet.__flag then
            self._layerViewType3._btnGet.__flag:setVisible(false)
        end
    end
    self._layerViewType3._layerGray:setVisible(0 == self._taskData.statusInfo.status)
    self._layerViewType3._btnGo:setVisible(-1 == self._taskData.statusInfo.status and self._taskData.button > 0)
    self._layerViewType3._btnGet:setVisible(1 == self._taskData.statusInfo.status or (-1 == self._taskData.statusInfo.status and 0 == self._taskData.button))
    --self._layerViewType3._btnGet:setEnabled(1 == self._taskData.statusInfo.status)
    self._layerViewType3._btnGet:setSaturation(1 == self._taskData.statusInfo.status and 0 or -100)
    self._layerViewType3._btnGet:setBright(1 == self._taskData.statusInfo.status)
    self._layerViewType3._getMC:setVisible(1 == self._taskData.statusInfo.status)
    self._layerViewType3._imageAlreadyGet:setVisible(0 == self._taskData.statusInfo.status)
    self._layerViewType3._taskCurrentDataBg:setVisible(not self._layerViewType3._imageAlreadyGet:isVisible() and not self._isHideConditionValue)
    self._layerViewType3._taskCurrentData:setVisible(not self._layerViewType3._imageAlreadyGet:isVisible() and not self._isHideConditionValue)
    self._layerViewType3._taskCurrentData:setColor(1 == self._taskData.statusInfo.status and cc.c3b(28, 162, 22) or cc.c3b(138, 92, 29))
    local labelDiscription = self._layerViewType3._taskDescription
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
    -- self._layerViewType3._taskDescriptionBg:setContentSize(cc.size(math.max(richText:getInnerSize().width + 40, 160), 32))
    if not self._taskData.finish_max then
        self._layerViewType3._taskCurrentData:setString(string.format("%d/%d", self._taskData.statusInfo.value, self._taskData.statusInfo.condition))
    else
        self._layerViewType3._taskCurrentData:setString(string.format("%d/%d", self._taskData.times, self._taskData.finish_max))
    end

    for i=1, 1 do
        self._layerViewType3._consumes[i]._icon:setVisible(false)
    end

    local giftContain = self._taskData.exchange_num
    for i = 1, #giftContain do
        local giftItem = 1 == #giftContain and self._layerViewType3._consumes[2]._icon or self._layerViewType3._consumes[i]._icon
        giftItem:setVisible(true)
        local itemIcon = giftItem:getChildByTag(self.kConsumeItemTag2)
        if itemIcon then itemIcon:removeFromParent() end
        local itemId = giftContain[i][2]
        local itemType = giftContain[i][1]
        local eventStyle = 1--{itemId = itemId, num = num,eventStyle = 0} 
        if itemType == "hero" then
            local heroData = clone(tab:Hero(itemId))
            itemIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
            --itemIcon:setAnchorPoint(cc.p(0, 0))
            itemIcon:getChildByName("starBg"):setVisible(false)
            for i=1,6 do
                if itemIcon:getChildByName("star" .. i) then
                    itemIcon:getChildByName("star" .. i):setPositionY(itemIcon:getChildByName("star" .. i):getPositionY() + 5)
                end
            end
            itemIcon:setPosition(giftItem:getContentSize().width / 2, giftItem:getContentSize().height / 2)
            itemIcon:setSwallowTouches(false)
            registerClickEvent(itemIcon, function()
                local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = itemId}, true)
            end)
        elseif itemType == "team" then
            local teamTeam = clone(tab:Team(itemId))
            itemIcon = IconUtils:createSysTeamIconById({sysTeamData = teamTeam,isJin=true})
            --itemIcon:setAnchorPoint(cc.p(0,0))
            --itemIcon:setSwallowTouches(false)
        elseif itemType == "avatarFrame" then
            local frameData = tab:AvatarFrame(itemId)
            param = {itemId = itemId, itemData = frameData}
            itemIcon = IconUtils:createHeadFrameIconById(param)
        elseif itemType == "siegeProp" then
            self.rewardsSiegeProp = true
            local propsTab = tab:SiegeEquip(itemId)
            local param = {itemId = itemId, level = 1, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 1}
            itemIcon = IconUtils:createWeaponsBagItemIcon(param)
        elseif itemType == "rune" then
            local runeData = tab:Rune(itemId)
            itemIcon =IconUtils:createHolyIconById({suitData = runeData})
        else
            if itemType ~= "tool" then
                itemId = IconUtils.iconIdMap[itemType]
            end
            itemIcon = IconUtils:createItemIconById({itemId = itemId, num = giftContain[i][3],eventStyle = eventStyle})
        end

        local scale = 0.71
        if itemType == "team" or itemType == "hero" then
            scale = 0.61
        elseif itemType == "avatarFrame" then
            scale = 0.58
        end
        itemIcon:setScale(scale)
        itemIcon:setTag(self.kConsumeItemTag2)
        giftItem:addChild(itemIcon)
    end

    for i=1, 1 do
        self._layerViewType3._rewards[i]._icon:setVisible(false)
    end

    local giftContain = self._taskData.reward
    for i = 1, --[[#giftContain]]1 do
        local giftItem = --[[1 == #giftContain and self._layerViewType3._rewards[2]._icon or]] self._layerViewType3._rewards[i]._icon
        giftItem:setVisible(true)
        local itemIcon = giftItem:getChildByTag(self.kRewardItemTag2)
        if itemIcon then itemIcon:removeFromParent() end
        local itemId = giftContain[i][2]
        local itemType = giftContain[i][1]
        local eventStyle = 1--{itemId = itemId, num = num,eventStyle = 0} 
        if itemType == "hero" then
            local heroData = clone(tab:Hero(itemId))
            itemIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
            --itemIcon:setAnchorPoint(cc.p(0, 0))
            itemIcon:getChildByName("starBg"):setVisible(false)
            for i=1,6 do
                if itemIcon:getChildByName("star" .. i) then
                    itemIcon:getChildByName("star" .. i):setPositionY(itemIcon:getChildByName("star" .. i):getPositionY() + 5)
                end
            end
            itemIcon:setPosition(giftItem:getContentSize().width / 2, giftItem:getContentSize().height / 2)
            itemIcon:setSwallowTouches(false)
            registerClickEvent(itemIcon, function()
                local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = itemId}, true)
            end)
        elseif itemType == "team" then
            local teamTeam = clone(tab:Team(itemId))
            itemIcon = IconUtils:createSysTeamIconById({sysTeamData = teamTeam,isJin=true})
            --itemIcon:setAnchorPoint(cc.p(0,0))
            --itemIcon:setSwallowTouches(false)
        elseif itemType == "avatarFrame" then
            local frameData = tab:AvatarFrame(itemId)
            param = {itemId = itemId, itemData = frameData}
            itemIcon = IconUtils:createHeadFrameIconById(param)
        elseif itemType == "rune" then
            local runeData = tab:Rune(itemId)
            itemIcon =IconUtils:createHolyIconById({suitData = runeData})
        else
            if itemType ~= "tool" then
                itemId = IconUtils.iconIdMap[itemType]
            end
            itemIcon = IconUtils:createItemIconById({itemId = itemId, num = giftContain[i][3],eventStyle = eventStyle})
        end

        local scale = 0.71
        if itemType == "team" or itemType == "hero" then
            scale = 0.61
        elseif itemType == "avatarFrame" then
            scale = 0.58
        end
        itemIcon:setScale(scale)
        itemIcon:setTag(self.kRewardItemTag2)
        giftItem:addChild(itemIcon)
    end
end


function ActivityTaskItemView:updateViewType4()
    if  self._taskData and self._taskData.discount_label then
        if not self._layerViewType4._btnGet.__flag then
            local disCountImg = ccui.ImageView:create()
            disCountImg:loadTexture("globalImageUI6_connerTag_L.png",1)
            disCountImg:setPosition(29,31)
            disCountImg:setScale(0.8)
            self._layerViewType4._btnGet:addChild(disCountImg)
            local txt = ccui.Text:create()
            txt:setFontSize(20)
            txt:setFontName(UIUtils.ttfName)
            if discountToCn[math.ceil(self._taskData.discount_label/100)] then 
                txt:setString(discountToCn[math.ceil(self._taskData.discount_label/100)])
            else
                txt:setString("") 
            end
            txt:setPosition(25,35)
            txt:setRotation(-45)
            txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            disCountImg:addChild(txt,1)
            self._layerViewType4._btnGet.__flag = disCountImg
            self._layerViewType4._btnGet.__flagTxt = txt
        else
            self._layerViewType4._btnGet.__flag:setVisible(true)
            if discountToCn[math.ceil(self._taskData.discount_label/100)] then 
                self._layerViewType4._btnGet.__flagTxt:setString(discountToCn[math.ceil(self._taskData.discount_label/100)])
            else
                self._layerViewType4._btnGet.__flagTxt:setString("") 
            end  
        end
    else
        if self._layerViewType4._btnGet.__flag then
            self._layerViewType4._btnGet.__flag:setVisible(false)
        end
    end
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
    self._layerViewType4._taskCurrentDataBg:setVisible(false)
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
    -- self._layerViewType4._taskDescriptionBg:setContentSize(cc.size(math.max(richText:getInnerSize().width + 40, 160), 32))
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
        if type(self._taskData.condition_num[1]) == "table" then
            itemId = self._taskData.condition_num[1][1] 
        end
        self._layerViewType4._consumes[i]._icon:removeChildByName("itemIcon")
        if itemId > 60000 then
            local heroTableData = clone(tab:Hero(itemId))
            heroTableData.star = self._taskData.condition_num[2]
            if type(self._taskData.condition_num[1]) == "table" then
                heroTableData.star = self._taskData.condition_num[1][2] 
            end
            heroTableData.hideFlag = false
            if not heroTableData then print("invalid hero icon id", self._iconId) end
            local itemIcon = IconUtils:createHeroIconById({sysHeroData = heroTableData})
            itemIcon:setScale(0.68)
            itemIcon:setPosition(cc.p(37, 36))
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
            if type(self._taskData.condition_num[1]) == "table" then
                teamTableData.star = self._taskData.condition_num[1][2] 
            end
            teamTableData.stage = 1
            local quality = self._teamModel:getTeamQualityByStage(teamTableData.stage)
            local itemIcon = IconUtils:createTeamIconById({teamData = {id = itemId, star = teamTableData.star}, sysTeamData = teamTableData, quality = --[[quality[1]改金框--]]nil, quaAddition = quality[2],  eventStyle = 0})
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


    for i=1, 2 do
        self._layerViewType4._rewards[i]._icon:setVisible(false)
    end

    local giftContain = self._taskData.reward
    local rwdNum = math.min(#giftContain, 2)
    for i = 1, rwdNum do
        local giftItem = self._layerViewType4._rewards[i]._icon
        giftItem:setVisible(true)
        local itemIcon = giftItem:getChildByTag(self.kRewardItemTag2)
        if itemIcon then itemIcon:removeFromParent() end
        local itemId = giftContain[i][2]
        local itemType = giftContain[i][1]
        local eventStyle = 1--{itemId = itemId, num = num,eventStyle = 0} 
        if itemType == "hero" then
            local heroData = clone(tab:Hero(itemId))
            itemIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
            --itemIcon:setAnchorPoint(cc.p(0, 0))
            itemIcon:getChildByName("starBg"):setVisible(false)
            for i=1,6 do
                if itemIcon:getChildByName("star" .. i) then
                    itemIcon:getChildByName("star" .. i):setPositionY(itemIcon:getChildByName("star" .. i):getPositionY() + 5)
                end
            end
            itemIcon:setPosition(giftItem:getContentSize().width / 2, giftItem:getContentSize().height / 2)
            itemIcon:setSwallowTouches(false)
            registerClickEvent(itemIcon, function()
                local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = itemId}, true)
            end)
        elseif itemType == "team" then
            local teamTeam = clone(tab:Team(itemId))
            itemIcon = IconUtils:createSysTeamIconById({sysTeamData = teamTeam,isJin=true})
            --itemIcon:setAnchorPoint(cc.p(0,0))
            --itemIcon:setSwallowTouches(false)
        elseif itemType == "avatarFrame" then
            local frameData = tab:AvatarFrame(itemId)
            param = {itemId = itemId, itemData = frameData}
            itemIcon = IconUtils:createHeadFrameIconById(param)
        elseif itemType == "siegeProp" then
            self.rewardsSiegeProp = true
            local propsTab = tab:SiegeEquip(itemId)
            local param = {itemId = itemId, level = 1, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 1}
            itemIcon = IconUtils:createWeaponsBagItemIcon(param)
        elseif itemType == "rune" then
            local runeData = tab:Rune(itemId)
            itemIcon =IconUtils:createHolyIconById({suitData = runeData})
        else
            if itemType ~= "tool" then
                itemId = IconUtils.iconIdMap[itemType]
            end
            itemIcon = IconUtils:createItemIconById({itemId = itemId, num = giftContain[i][3],eventStyle = eventStyle})
        end

        local scale = 0.71
        if itemType == "team" or itemType == "hero" then
            scale = 0.61
        elseif itemType == "avatarFrame" then
            scale = 0.58
        end
        itemIcon:setScale(scale)
        itemIcon:setTag(self.kRewardItemTag2)
        giftItem:addChild(itemIcon)
    end
end

function ActivityTaskItemView:updateViewType5()
    if  self._taskData and self._taskData.discount_label then
        if not self._layerViewType5._btnGet.__flag then
            local disCountImg = ccui.ImageView:create()
            disCountImg:loadTexture("globalImageUI6_connerTag_L.png",1)
            disCountImg:setPosition(29,31)
            disCountImg:setScale(0.8)
            self._layerViewType5._btnGet:addChild(disCountImg)
            local txt = ccui.Text:create()
            txt:setFontSize(20)
            txt:setFontName(UIUtils.ttfName)
            if discountToCn[math.ceil(self._taskData.discount_label/100)] then 
                txt:setString(discountToCn[math.ceil(self._taskData.discount_label/100)])
            else
                txt:setString("") 
            end
            txt:setPosition(25,35)
            txt:setRotation(-45)
            txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            disCountImg:addChild(txt,1)
            self._layerViewType5._btnGet.__flag = disCountImg
            self._layerViewType5._btnGet.__flagTxt = txt
        else
            self._layerViewType5._btnGet.__flag:setVisible(true)
            if discountToCn[math.ceil(self._taskData.discount_label/100)] then 
                self._layerViewType5._btnGet.__flagTxt:setString(discountToCn[math.ceil(self._taskData.discount_label/100)])
            else
                self._layerViewType5._btnGet.__flagTxt:setString("") 
            end  
        end
    else
        if self._layerViewType5._btnGet.__flag then
            self._layerViewType5._btnGet.__flag:setVisible(false)
        end
    end
    self._layerViewType5._layerGray:setVisible(0 == self._taskData.statusInfo.status)
    self._layerViewType5._btnGo:setVisible(-1 == self._taskData.statusInfo.status and self._taskData.button > 0)
    self._layerViewType5._btnGet:setVisible(1 == self._taskData.statusInfo.status or (-1 == self._taskData.statusInfo.status and 0 == self._taskData.button))
    --self._layerViewType5._btnGet:setEnabled(1 == self._taskData.statusInfo.status)
    self._layerViewType5._btnGet:setSaturation(1 == self._taskData.statusInfo.status and 0 or -100)
    self._layerViewType5._btnGet:setBright(1 == self._taskData.statusInfo.status)
    self._layerViewType5._getMC:setVisible(1 == self._taskData.statusInfo.status)
    self._layerViewType5._imageAlreadyGet:setVisible(0 == self._taskData.statusInfo.status)
    self._layerViewType5._taskCurrentDataBg:setVisible(not self._layerViewType5._imageAlreadyGet:isVisible() and not self._isHideConditionValue)
    self._layerViewType5._taskCurrentData:setVisible(not self._layerViewType5._imageAlreadyGet:isVisible() and not self._isHideConditionValue)
    self._layerViewType5._taskCurrentData:setColor(1 == self._taskData.statusInfo.status and cc.c3b(28, 162, 22) or cc.c3b(138, 92, 29))
    --self._layerViewType5._taskCurrentData:setVisible(not self._layerViewType5._imageAlreadyGet:isVisible() and not (self._isHideConditionValue and 1 == self._taskData.statusInfo.condition)) -- temp code fixed me
    self._layerViewType5._btnGet:setPositionY(self._layerViewType5._taskCurrentData:isVisible() and 50 or 65)
    self._layerViewType5._btnGo:setPositionY(self._layerViewType5._taskCurrentData:isVisible() and 50 or 65)

    local labelDiscription = self._layerViewType5._taskDescription
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
    --self._layerViewType5._taskCurrentData:setPositionY((self._layerViewType5._btnGo:isVisible() or self._layerViewType5._btnGet:isVisible()) and 90 or 60)
    if not self._taskData.finish_max then
        self._layerViewType5._taskCurrentData:setString(string.format("%d/%d", self._taskData.statusInfo.value, self._taskData.statusInfo.condition))
    else
        self._layerViewType5._taskCurrentData:setString(string.format("%d/%d", self._taskData.times, self._taskData.finish_max))
    end
    -- self._layerViewType5._taskDescriptionBg:setContentSize(cc.size(math.max(richText:getInnerSize().width + 40, 160), 32))
    --[[
    local conditiontype = self._taskData.conditiontype
    if 101 == conditiontype or
       102 == conditiontype then
        self._layerViewType5._taskCurrentData:setVisible(true)
        if 0 == self._taskData.statusInfo.status then
            self._layerViewType5._taskCurrentData:setString("0/1")
        elseif 1 == self._taskData.statusInfo.status then
            self._layerViewType5._taskCurrentData:setString("1/1")
        else
            self._layerViewType5._taskCurrentData:setVisible(false)
        end
    elseif 998 == conditiontype then
        self._layerViewType5._taskCurrentData:setVisible(true)
        if 0 == self._taskData.statusInfo.status then
            self._layerViewType5._taskCurrentData:setString("未购买")
        elseif 1 == self._taskData.statusInfo.status then
            self._layerViewType5._taskCurrentData:setString("已购买")
            local restDay = math.floor((self._taskData.val2 - self._modelMgr:getModel("UserModel"):getCurServerTime()) / 86400)
        else
            self._layerViewType5._taskCurrentData:setVisible(false)
        end   
    elseif 999 == conditiontype then
        if 0 == self._taskData.statusInfo.status then
            self._layerViewType5._taskCurrentData:setString("时间未到")
        elseif self._taskData.statusInfo.status >= 1 then
            self._layerViewType5._taskCurrentData:setVisible(false)
        elseif -1 == self._taskData.statusInfo.status then
            self._layerViewType5._taskCurrentData:setString("时间已过")
        end
    else
        self._layerViewType5._taskCurrentData:setVisible(not self._layerViewType5._imageAlreadyGet:isVisible())
        self._layerViewType5._taskCurrentData:setString(string.format("%d/%d", tonumber(self._taskData.val2), tonumber(self._taskData.val1)))
    end
    ]]
    local toolTableData = tab.tool
    local staticConfigTableData = IconUtils.iconIdMap

    for i=1, 4 do
        self._layerViewType5._rewards[i]._icon:setVisible(false)
    end

    for i = 1, 3 do
        self._layerViewType5._or[i]:setVisible(false)
    end

    local giftContain = self._taskData.reward
    local staticConfigTableData = IconUtils.iconIdMap
    for i = 1, #giftContain-1 do
        self._layerViewType5._or[i]:setVisible(true)
    end
    for i = 1, #giftContain do
        local giftItem = self._layerViewType5._rewards[i]._icon
        giftItem:setVisible(true)
        local itemIcon = giftItem:getChildByTag(self.kRewardItemTag1)
        if itemIcon then itemIcon:removeFromParent() end
        local itemId = giftContain[i][2]
        local itemType = giftContain[i][1]
        local eventStyle = 1--{itemId = itemId, num = num,eventStyle = 0} 
        if itemType == "hero" then
            local heroData = clone(tab:Hero(itemId))
            itemIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
            --itemIcon:setAnchorPoint(cc.p(0, 0))
            itemIcon:getChildByName("starBg"):setVisible(false)
            for i=1,6 do
                if itemIcon:getChildByName("star" .. i) then
                    itemIcon:getChildByName("star" .. i):setPositionY(itemIcon:getChildByName("star" .. i):getPositionY() + 5)
                end
            end
            itemIcon:setPosition(giftItem:getContentSize().width / 2, giftItem:getContentSize().height / 2)
            itemIcon:setSwallowTouches(false)
            registerClickEvent(itemIcon, function()
                local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = itemId}, true)
            end)
        elseif itemType == "team" then
            local teamTeam = clone(tab:Team(itemId))
            itemIcon = IconUtils:createSysTeamIconById({sysTeamData = teamTeam, isJin = true})
            --itemIcon:setAnchorPoint(cc.p(0,0))
            --itemIcon:setSwallowTouches(false)
        elseif itemType == "avatarFrame" then
            local frameData = tab:AvatarFrame(itemId)
            param = {itemId = itemId, itemData = frameData}
            itemIcon = IconUtils:createHeadFrameIconById(param)
        elseif itemType == "siegeProp" then
            self.rewardsSiegeProp = true
            local propsTab = tab:SiegeEquip(itemId)
            local param = {itemId = itemId, level = 1, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 1}
            itemIcon = IconUtils:createWeaponsBagItemIcon(param)
        elseif itemType == "rune" then
            local runeData = tab:Rune(itemId)
            itemIcon =IconUtils:createHolyIconById({suitData = runeData})
        else
            if itemType ~= "tool" then
                itemId = IconUtils.iconIdMap[itemType]
            end
            itemIcon = IconUtils:createItemIconById({itemId = itemId, num = giftContain[i][3],eventStyle = eventStyle})
        end
        
        local scale = 0.71
        if itemType == "team" or itemType == "hero" then
            scale = 0.61
        elseif itemType == "avatarFrame" then
            scale = 0.58
        end
        itemIcon:setScale(scale)
        itemIcon:setTag(self.kRewardItemTag1)
        giftItem:addChild(itemIcon)
    end
end

function ActivityTaskItemView:updateViewType6()
    if  self._taskData and self._taskData.discount_label then
        if not self._layerViewType6._btnGet.__flag then
            local disCountImg = ccui.ImageView:create()
            disCountImg:loadTexture("globalImageUI6_connerTag_L.png",1)
            disCountImg:setPosition(29,31)
            disCountImg:setScale(0.8)
            self._layerViewType6._btnGet:addChild(disCountImg)
            local txt = ccui.Text:create()
            txt:setFontSize(20)
            txt:setFontName(UIUtils.ttfName)
            if discountToCn[math.ceil(self._taskData.discount_label/100)] then 
                txt:setString(discountToCn[math.ceil(self._taskData.discount_label/100)])
            else
                txt:setString("") 
            end
            txt:setPosition(25,35)
            txt:setRotation(-45)
            txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            disCountImg:addChild(txt,1)
            self._layerViewType6._btnGet.__flag = disCountImg
            self._layerViewType6._btnGet.__flagTxt = txt
        else
            self._layerViewType6._btnGet.__flag:setVisible(true)
            if discountToCn[math.ceil(self._taskData.discount_label/100)] then 
                self._layerViewType6._btnGet.__flagTxt:setString(discountToCn[math.ceil(self._taskData.discount_label/100)])
            else
                self._layerViewType6._btnGet.__flagTxt:setString("") 
            end  
        end
    else
        if self._layerViewType6._btnGet.__flag then
            self._layerViewType6._btnGet.__flag:setVisible(false)
        end
    end
    self._layerViewType6._layerGray:setVisible(0 == self._taskData.statusInfo.status)
    self._layerViewType6._btnGo:setVisible(-1 == self._taskData.statusInfo.status and self._taskData.button > 0)
    self._layerViewType6._btnGet:setVisible(1 == self._taskData.statusInfo.status or (-1 == self._taskData.statusInfo.status and 0 == self._taskData.button))
    --self._layerViewType6._btnGet:setEnabled(1 == self._taskData.statusInfo.status)
    self._layerViewType6._btnGet:setSaturation(1 == self._taskData.statusInfo.status and 0 or -100)
    self._layerViewType6._btnGet:setBright(1 == self._taskData.statusInfo.status)
    self._layerViewType6._btnGet:setSaturation(1 == self._taskData.statusInfo.status and 0 or -100)
    self._layerViewType6._getMC:setVisible(1 == self._taskData.statusInfo.status)
    self._layerViewType6._imageAlreadyGet:setVisible(0 == self._taskData.statusInfo.status)
    --self._layerViewType6._taskCurrentData:setVisible(not self._layerViewType6._imageAlreadyGet:isVisible())
    self._layerViewType6._taskCurrentDataBg:setVisible(false)
    self._layerViewType6._taskCurrentData:setVisible(false)
    local labelDiscription = self._layerViewType6._taskDescription
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
    -- self._layerViewType6._taskDescriptionBg:setContentSize(cc.size(math.max(richText:getInnerSize().width + 40, 160), 32))
    if not self._taskData.finish_max then
        self._layerViewType6._taskCurrentData:setString(string.format("%d/%d", self._taskData.statusInfo.value, self._taskData.statusInfo.condition))
    else
        self._layerViewType6._taskCurrentData:setString(string.format("%d/%d", self._taskData.times, self._taskData.finish_max))
    end

    for i=1, 4 do
        self._layerViewType6._rewards[i]._icon:setVisible(false)
    end

    local giftContain = self._taskData.reward
    for i = 1, #giftContain do
        local giftItem = --[[1 == #giftContain and self._layerViewType6._rewards[2]._icon or]] self._layerViewType6._rewards[i]._icon
        giftItem:setVisible(true)
        local itemIcon = giftItem:getChildByTag(self.kRewardItemTag2)
        if itemIcon then itemIcon:removeFromParent() end
        local itemId = giftContain[i][2]
        local itemType = giftContain[i][1]
        local eventStyle = 1--{itemId = itemId, num = num,eventStyle = 0} 
        if itemType == "hero" then
            local heroData = clone(tab:Hero(itemId))
            itemIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
            --itemIcon:setAnchorPoint(cc.p(0, 0))
            itemIcon:getChildByName("starBg"):setVisible(false)
            for i=1,6 do
                if itemIcon:getChildByName("star" .. i) then
                    itemIcon:getChildByName("star" .. i):setPositionY(itemIcon:getChildByName("star" .. i):getPositionY() + 5)
                end
            end
            itemIcon:setPosition(giftItem:getContentSize().width / 2, giftItem:getContentSize().height / 2)
            itemIcon:setSwallowTouches(false)
            registerClickEvent(itemIcon, function()
                local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = itemId}, true)
            end)
        elseif itemType == "team" then
            local teamTeam = clone(tab:Team(itemId))
            itemIcon = IconUtils:createSysTeamIconById({sysTeamData = teamTeam,isJin=true})
            --itemIcon:setAnchorPoint(cc.p(0,0))
            --itemIcon:setSwallowTouches(false)
        elseif itemType == "avatarFrame" then
            local frameData = tab:AvatarFrame(itemId)
            param = {itemId = itemId, itemData = frameData}
            itemIcon = IconUtils:createHeadFrameIconById(param)
        elseif itemType == "siegeProp" then
            self.rewardsSiegeProp = true
            local propsTab = tab:SiegeEquip(itemId)
            local param = {itemId = itemId, level = 1, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 1}
            itemIcon = IconUtils:createWeaponsBagItemIcon(param)
        elseif itemType == "rune" then
            local runeData = tab:Rune(itemId)
            itemIcon =IconUtils:createHolyIconById({suitData = runeData})
        else
            if itemType ~= "tool" then
                itemId = IconUtils.iconIdMap[itemType]
            end
            itemIcon = IconUtils:createItemIconById({itemId = itemId, num = giftContain[i][3],eventStyle = eventStyle})
        end

        local scale = 0.71
        if itemType == "team" or itemType == "hero" then
            scale = 0.61
        elseif itemType == "avatarFrame" then
            scale = 0.58
        end
        itemIcon:setScale(scale)
        itemIcon:setTag(self.kRewardItemTag2)
        giftItem:addChild(itemIcon)
    end
end

function ActivityTaskItemView:updateUI()
    for viewType = ActivityTaskItemView.kTaskType1, ActivityTaskItemView.kTaskTypeEnd do
        repeat
            if viewType == self._viewType then
                if self._viewType ~= 7 then
                    self["_layerViewType" .. viewType]._layer:setVisible(true)
                else
                    self["_layerViewType2"]._layer:setVisible(true)
                end
                break
            end
            if viewType ~= 7 then
                self["_layerViewType" .. viewType]._layer:setVisible(false)
            end
            
        until true
    end

    --dump(self._taskData, "ActivityTaskItemView")
    --self:setSaturation(0 == self._taskData.statusInfo.status and -100 or 0)
    self.rewardsSiegeProp = false
    if self["updateViewType" .. self._viewType] and "function" == type(self["updateViewType" .. self._viewType]) then
        self["updateViewType" .. self._viewType](self)
    end
end

function ActivityTaskItemView:setContext(context)
    self._container = context.container
    self._taskData = context.taskData
    self._viewType = self._taskData.uitype
    self._isHideConditionValue = context.isHideConditionValue
    -- temp code
    self._tmpShowBuy = context.tmpShowBuy
    -- temp code
end

function ActivityTaskItemView:onButtonGoClicked()
    if not (self._container and self._container.onButtonGoClicked) then return end
    self._container:onButtonGoClicked(self._taskData)
end

function ActivityTaskItemView:onButtonGetClicked()
    if not (self._container and self._container.onButtonGetClicked) then return end

    if self.rewardsSiegeProp then
        -- 器械配件
        local weaponsModel = self._modelMgr:getModel("WeaponsModel")
        local isReach = weaponsModel:isFinishMaxcapacity()
        if isReach then
            self._viewMgr:showTip("器械库已到最大容量，请先分解器械")
            return 
        end 
    end

    self._container:onButtonGetClicked(self._taskData)
end

return ActivityTaskItemView