--[[
    Filename:    ActivitySingleChargeLayer.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-11-01 20:05:14
    Description: File description
--]]

-- local ActivityTaskItemView = require("game.view.activity.ActivityTaskItemView")

local ActivitySingleChargeLayer = class("ActivitySingleChargeLayer", require("game.view.activity.common.ActivityCommonLayer"))

ActivitySingleChargeLayer.kActivityTaskItemTag = 1000

ActivitySingleChargeLayer.kNormalZOrder = 500
ActivitySingleChargeLayer.kLessNormalZOrder = ActivitySingleChargeLayer.kNormalZOrder - 1
ActivitySingleChargeLayer.kAboveNormalZOrder = ActivitySingleChargeLayer.kNormalZOrder + 1
ActivitySingleChargeLayer.kHighestZOrder = ActivitySingleChargeLayer.kAboveNormalZOrder + 1

ActivitySingleChargeLayer.kActivityType1 = 1
ActivitySingleChargeLayer.kActivityType2 = 2
ActivitySingleChargeLayer.kActivityType3 = 3
ActivitySingleChargeLayer.kActivityType4 = 4

function ActivitySingleChargeLayer:ctor(params)
    ActivitySingleChargeLayer.super.ctor(self)
    self._activityId = params.activityId

    self._activityModel = self._modelMgr:getModel("ActivityModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._vipModel = self._modelMgr:getModel("VipModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
end

function ActivitySingleChargeLayer:onDestroy()
    ActivitySingleChargeLayer.super.onDestroy(self)
end

function ActivitySingleChargeLayer:disableTextEffect(element)
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

function ActivitySingleChargeLayer:onInit()
    self:disableTextEffect()
    self._scheduler = cc.Director:getInstance():getScheduler()

    self._activityData = tab:DailyActivity(self._activityId)

    self._activityTaskData = {}
    self._taskTableView = nil
    self._cellW = 202 
    self._cellH = 330
    self._itemPos = {
        [1] = {{0,0}},
        [2] = {{-0.5,0},{0.5,0}},
        [3] = {{0,0.5},{-0.5,-0.5},{0.5,-0.5}},
        [4] = {{-0.5,0.5},{0.5,0.5},{-0.5,-0.5},{0.5,-0.5}},
    }

    self._layerTaskList = self:getUI("bg.layer_activity_tasks.layer_task_list")

    self._imageActivityTitle = self:getUI("bg.image_activity_title")
    self._imageActivityBg = self:getUI("bg.image_activity_bg")

    self._activityTimeDes = self:getUI("bg.activity_time_des")
    self._activityTimeDes:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self._activityTime = self:getUI("bg.activity_time")
    self._activityTime:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self._activityDescription = self:getUI("bg.activity_description")

    -- 规则按钮
    self._ruleBtn = ccui.Button:create()
    self._ruleBtn:loadTextures("globalImage_info.png","globalImage_info.png","",1)
    self._ruleBtn:setPosition(635, 440)  
    self:addChild(self._ruleBtn,10) 
    -- 规则
    registerClickEvent(self._ruleBtn,function(sender) 
        self:showRuleDialog()
    end)

    self:refreshUI()

    self:registerScriptHandler(function(state)
        if state == "exit" then
            self:endClock()
        end 
    end)
end

function ActivitySingleChargeLayer:showRuleDialog()
    local ruleDesc = lang("singlerecharge_rule")
    self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = ruleDesc},true)
end

function ActivitySingleChargeLayer:refreshUI()
    self._activityTaskData = self:initActivityData()
    self._activityShowList = self:getActivityShowList()
    local acTaskData = tab:DailyActivity(tonumber(self._activityId))
    self._imageActivityTitle:setVisible(false)
    if acTaskData then
        -- self._imageActivityTitle:loadTexture(acTaskData.titlepic1 .. ".png", 1)
        self._imageActivityBg:loadTexture(acTaskData.titlepic2 .. ".png", 1)
        self._activityDescription:setString(lang(acTaskData.description))

        self._imageActivityBg:removeAllChildren()
        local label = UIUtils:getActivityLabel(lang(acTaskData.title), 70)
        label:setPosition(10, 10)
        self._imageActivityBg:addChild(label)
    end
    self:startClock()
    self:updateTimeCountDown()
    self:createActivityTaskTableView()
end

function ActivitySingleChargeLayer:initActivityData()
    local result = {}
    local acData = self._activityModel:getSingleRechargeData()
    local acTaskData = tab:DailyActivity(tonumber(self._activityId))
    acData = acData[tostring(self._activityId)]
    if not acData then return {} end

    local findacTableData = function(key)
        local acTableData = tab:ActSingleRecharge(tonumber(key))
        if not acTableData then return false end
        return true, {
            id = tonumber(key),
            button = 2,
            payment = acTableData.payment,
            description = acTableData.desc,
            reward = acTableData.reward,
            rewardtype = acTableData.rewardtype,
            uitype = ActivitySingleChargeLayer.kActivityType1,
        }
    end

    local findacData = function(key)
        for k, v in pairs(acData) do
            if tonumber(k) == tonumber(key) then
                return true, clone(v)
            end
        end
        return false
    end

    for _, id in pairs(acTaskData.task_list) do
        local f, t = findacTableData(tonumber(id))
        if f then
            local f1, t2 = findacData(t.payment)
            if f1 then
                t.statusInfo = {
                    status = t2.status,
                    value = t2.rcv,
                    condition = t2.lim
                }
                if t2.status == 1 then
                    t.order = 3
                elseif t2.status == -1 then
                    t.order = 2
                else
                    t.order = 1
                end
            end
            table.insert(result, t)
        end
    end

    table.sort(result, function(a, b)
        if a.order == b.order then
            return a.id < b.id
        else
            return a.order > b.order 
        end
    end)

    --dump(result, "result", 5)

    return result
end

function ActivitySingleChargeLayer:getActivityShowList()
    local acShowList = self._activityModel:getActivityShowList()
    for k, v in pairs(acShowList) do
        if v.activity_id == self._activityId then
            return v
        end
    end
end

function ActivitySingleChargeLayer:hasTaskCanGet(index)
    if not (self._activity and self._activity[index]) then return false end
    if ActivitySingleChargeLayer.kActivityType1 == self._activity[index].acType then
        if not self._activity[index].taskList then return false end
        for _, v in ipairs(self._activity[index].taskList) do
            if 1 == v.statusInfo.status then
                return true
            end
        end
        if self._activity[index].redTag then
            return true
        end
    else
        if self._activity[index].redTag then
            return true
        end

        if 101 == self._activity[index].id then
            return self._activityModel:isACERebateDateTip()
        elseif 102 == self._activity[index].id then
            return self._activityModel:isACERechargeTip()
        elseif 99 == self._activity[index].id then
            return self._activityModel:isShareDataTip()                    
        elseif 100 == self._activity[index].id then
            return self._activityModel:isMonthCardCandGet()
        elseif 99999 == self._activity[index].id then
            return self._activityModel:isPhysicalCandGet()
        end
    end   
    
    return false
end

function ActivitySingleChargeLayer:getRemainTimeAndTips()
    local currentTime = self._userModel:getCurServerTime()
    local isClose = 1 == self._activityShowList.isClose
    local appearTime = self._activityShowList.appear_time
    local startTime = self._activityShowList.start_time
    local endTime = self._activityShowList.end_time
    local disappearTime = self._activityShowList.disappear_time
    local remainTime = 0
    local tips = ""
    
    if not isClose then
        tips = "%02d天%02d:%02d:%02d"
        remainTime = endTime - currentTime
    elseif currentTime >= appearTime and currentTime < startTime then
        tips = "%02d天%02d:%02d:%02d"
        remainTime = startTime - currentTime
    end
    
    return remainTime, tips
end

function ActivitySingleChargeLayer:updateTimeCountDown()
    --[[
    if self._timerDirty then
        self._remainTime, self._timerTips = self:getRemainTimeAndTips()
        self._timerDirty = false
    else
        self._remainTime = self._remainTime - 1
    end
    ]]
    -- local remainTime = os.date("*t", self._remainTime)
    -- self._activityTime:setString(string.format(self._timerTips, remainTime.day, remainTime.hour, remainTime.min, remainTime.sec))

    self._remainTime, self._timerTips = self:getRemainTimeAndTips()

    local tempValue = self._remainTime    
    local day = math.floor(tempValue/86400) 
    tempValue = tempValue - day*86400
    
    local hour = math.floor(tempValue/3600)
    tempValue = tempValue - hour*3600

    local minute = math.floor(tempValue/60)
    tempValue = tempValue - minute*60
   
    local second = math.fmod(tempValue, 60)
    local showTime = string.format("%.2d天%.2d:%.2d:%.2d", day, hour, minute, second)
    if day == 0 then
        showTime = string.format("00天%.2d:%.2d:%.2d", hour, minute, second)
    end
    if self._remainTime <= 0 then
        showTime = "00天00:00:00"
    end
    self._activityTime:setString(showTime)
end

function ActivitySingleChargeLayer:startClock()
    self._timerDirty = true
    if self._timer_id then return end
    self._timer_id = self._scheduler:scheduleScriptFunc(handler(self, self.updateTimeCountDown), 1, false)
end

function ActivitySingleChargeLayer:endClock()
    if not self._timer_id then return end
    if self._timer_id then 
        self._scheduler:unscheduleScriptEntry(self._timer_id)
        self._timer_id = nil
        self._timerDirty = false
    end
end
--[[
function ActivitySingleChargeLayer:updateActivityTaskItem(activityTaskItem, index)
    index = index + 1
    activityTaskItem:setContext({container = self, taskData = self._activityTaskData[index]})
    activityTaskItem:updateUI()
end
]]

function ActivitySingleChargeLayer:createActivityTaskTableView()
    if not self._taskTableView then
        self._taskTableView = cc.TableView:create(self._layerTaskList:getContentSize())
        self._taskTableView:setDelegate()
        self._taskTableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        self._taskTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_LEFTRIGHT)
        self._taskTableView:setAnchorPoint(cc.p(0, 0))
        self._taskTableView:setPosition(cc.p(0, 0))
        --self._taskTableView:setBounceable(false)
        self._layerTaskList:addChild(self._taskTableView, self.kAboveNormalZOrder)
        self._taskTableView:registerScriptHandler(handler(self, self.activityTaskTableViewCellTouched), cc.TABLECELL_TOUCHED)
        self._taskTableView:registerScriptHandler(handler(self, self.activityTaskTableViewCellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
        self._taskTableView:registerScriptHandler(handler(self, self.activityTaskTableViewCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
        self._taskTableView:registerScriptHandler(handler(self, self.activityTaskNumberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        
    end
    self._taskTableView:reloadData()
end

function ActivitySingleChargeLayer:activityTaskTableViewCellTouched(tableView, cell)

end

function ActivitySingleChargeLayer:activityTaskTableViewCellSizeForTable(tableView, idx)
    return self._cellH, self._cellW
end
--[[
function ActivitySingleChargeLayer:activityTaskTableViewCellAtIndex(tableView, idx)
    local cell = tableView:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
        local taskData = self._activityTaskData[idx+1]
        local activityItemName = "activity.ActivityTaskItemView"
        local activityTaskItemView = self._viewMgr:createLayer(activityItemName, {container = self, taskData = taskData, tmpShowRematinTimes = true})
        activityTaskItemView:setTouchEnabled(false)
        activityTaskItemView:setVisible(true)
        activityTaskItemView:setTag(self.kActivityTaskItemTag)
        self:updateActivityTaskItem(activityTaskItemView, idx)
        cell:addChild(activityTaskItemView)
    else
        local activityTaskItemView = cell:getChildByTag(self.kActivityTaskItemTag)
        self:updateActivityTaskItem(activityTaskItemView, idx)
    end
    return cell
end
]]
function ActivitySingleChargeLayer:activityTaskTableViewCellAtIndex(tableView, idx)
    local cell = tableView:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
        local taskData = self._activityTaskData[idx+1]
        local acItem = self:createItem(taskData,idx)
        acItem:setTag(self.kActivityTaskItemTag)
        self:updateAcItem(acItem, idx)
        cell:addChild(acItem)
    else
        local acItem = cell:getChildByTag(self.kActivityTaskItemTag)
        self:updateAcItem(acItem, idx)
    end
    return cell
end
function ActivitySingleChargeLayer:activityTaskNumberOfCellsInTableView(tableView)
    if not (self._activityTaskData and type(self._activityTaskData)  == "table") then return 0 end
    return #self._activityTaskData
end

function ActivitySingleChargeLayer:createItem(data)
    local item = ccui.Layout:create()
    item:setAnchorPoint(0,0)
    item:setContentSize(self._cellW, self._cellH)
    item:setTouchEnabled(true)
    item:setSwallowTouches(false)
    if not data then return  item end

    -- 背景
    local bgImg = ccui.ImageView:create()
    bgImg:loadTexture("activity_single_bg.png",1)
    bgImg:setPosition(self._cellW*0.5, self._cellH*0.5)
    bgImg:setName("bgImg")
    item:addChild(bgImg)

    -- 标题背景
    local titleBg = ccui.ImageView:create()
    titleBg:loadTexture("activity_single_shade1.png",1)
    titleBg:setName("titleBg")
    titleBg:setPosition(self._cellW*0.5, self._cellH - 10)
    titleBg:setAnchorPoint(0.5,1)
    item._titleBg = titleBg
    item:addChild(titleBg)

    -- 标题
    -- local title_txt = ccui.Text:create()
    -- title_txt:setFontSize(20)
    -- title_txt:setName("title_txt")
    -- title_txt:setFontName(UIUtils.ttfName)
    -- title_txt:setString("单笔充值960钻石")
    -- title_txt:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
    -- -- title_txt:enableOutline(cc.c4b(14,56,94),1)
    -- title_txt:setAnchorPoint(0.5,0.5)
    -- title_txt:setPosition(self._cellW*0.5, self._cellH - 30)
    -- item._titleTxt = title_txt
    -- item:addChild(title_txt,1)

    -- 奖励面板
    local iconPanel = ccui.Layout:create()
    iconPanel:setAnchorPoint(0,0)
    iconPanel:setName("iconPanel")
    iconPanel:setContentSize(174, 162)
    iconPanel:setPosition(15,125)
    iconPanel:setTouchEnabled(true)
    iconPanel:setSwallowTouches(false)
    item._iconPanel = iconPanel
    item:addChild(iconPanel,2)
    -- iconPanel:setBackGroundColorOpacity(80)
    -- iconPanel:setBackGroundColorType(1)

    --条件des
    local condTxt1 = ccui.Text:create()
    condTxt1:setFontSize(20)
    condTxt1:setName("condTxt1")
    condTxt1:setFontName(UIUtils.ttfName)
    condTxt1:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    condTxt1:setAnchorPoint(0.5,0.5)
    condTxt1:setPosition(85, 92)
    condTxt1:setString("可完成次数:")
    item._condTxt1 = condTxt1
    condTxt1:setVisible(false)
    item:addChild(condTxt1,10)
    --条件
    local condTxt2 = ccui.Text:create()
    condTxt2:setFontSize(20)
    condTxt2:setName("condTxt2")
    condTxt2:setFontName(UIUtils.ttfName)
    condTxt2:setColor(UIUtils.colorTable.ccUITabColor1)
    condTxt2:setAnchorPoint(0.5,0.5)
    condTxt2:setPosition(154, 92)
    condTxt2:setString("2/2")
    item._condTxt2 = condTxt2
    condTxt2:setVisible(false)
    item:addChild(condTxt2,10)

    --领取按钮
    local getBtn = ccui.Button:create()
    getBtn:loadTextures("globalButtonUI13_1_2.png","globalButtonUI13_1_2.png","",1)
    getBtn:setTitleText("领取")
    getBtn:setPosition(self._cellW*0.5, 50)  
    getBtn:setName("getBtn")
    getBtn:setTitleFontName(UIUtils.ttfName)
    getBtn:setTitleColor(UIUtils.colorTable.ccUICommonBtnColor1)
    getBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine5, 2) --(cc.c4b(101, 33, 0, 255), 2)
    getBtn:setTitleFontSize(22) 
    getBtn:setVisible(false)
    item._getBtn = getBtn
    item:addChild(getBtn,2)

    -- 领取按钮特效   
    local anniuAnim = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true,false)
    anniuAnim:setName("anniuAnim")
    anniuAnim:setVisible(false)
    anniuAnim:setPosition(getBtn:getContentSize().width/2-2, getBtn:getContentSize().height/2+2)
    getBtn:addChild(anniuAnim,1)
    item._getMC = anniuAnim

    -- 前往按钮
    local goBtn = ccui.Button:create()
    goBtn:loadTextures("globalButtonUI13_2_2.png","globalButtonUI13_2_2.png","",1)
    goBtn:setName("goBtn")
    goBtn:setPosition(self._cellW*0.5, 50) 
    goBtn:setTitleFontName(UIUtils.ttfName)
    goBtn:setTitleColor(UIUtils.colorTable.ccUICommonBtnColor2)
    goBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine7, 2) --(cc.c4b(101, 33, 0, 255), 2)
    goBtn:setTitleFontSize(22)
    goBtn:setTitleText("前往")
    item._goBtn = goBtn   
    item:addChild(goBtn,5)
    goBtn:setVisible(false)

    -- 已领取
    local getSp = cc.Sprite:createWithSpriteFrameName("globalImageUI_activity_getItBlue.png")
    getSp:setName("getSp")
    getSp:setVisible(false)
    getSp:setPosition(self._cellW*0.5, 65)
    item._getSp = getSp
    item:addChild(getSp,5)

    return item
end

function ActivitySingleChargeLayer:updateAcItem(acItem,idx)
    local index = idx + 1 
    local acData = self._activityTaskData[index]
    if not acData then return end

    local titleBg   = acItem._titleBg
    local iconPanel = acItem._iconPanel
    local condTxt1  = acItem._condTxt1
    local condTxt2  = acItem._condTxt2
    local getBtn    = acItem._getBtn
    local getMC     = acItem._getMC
    local goBtn     = acItem._goBtn
    local getSp     = acItem._getSp

    titleBg:loadTexture("activity_single_shade" .. (index%3+1) .. ".png",1)
    local desc = lang(acData.description)
    local richText = acItem._titleTxt
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, 200, 40, true)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(self._cellW*0.5, self._cellH - 30)
    richText:setName("descRichText")
    acItem._titleTxt = richText
    acItem:addChild(richText)

    iconPanel:removeAllChildren()
    local itemW = 60
    -- local itemN = 2
    -- 中心点位置
    local itemX = 91
    local itemY = 88

    -- 是否是选择性奖励展示
    if 0 == acData.rewardtype then
        -- 标题背景
        local txtBg = ccui.ImageView:create()
        txtBg:loadTexture("globalPanelUI7_halfBar1.png",1)
        txtBg:setName("txtBg")
        txtBg:setPosition(iconPanel:getContentSize().width*0.5, 12)
        txtBg:setAnchorPoint(0.5,0.5)
        iconPanel:addChild(txtBg,4)

        -- 标题
        local text = ccui.Text:create()
        text:setFontSize(16)
        text:setName("text")
        text:setFontName(UIUtils.ttfName)
        text:setString("以上物品多选一")
        text:setAnchorPoint(0.5,0.5)
        text:setPosition(iconPanel:getContentSize().width*0.5, 12)
        iconPanel:addChild(text,5)
    end

    if acData.reward then
        local rewardNum = #acData.reward
        local posArr = self._itemPos[rewardNum] or {}
        for i=1,rewardNum do        
            local data = acData.reward[i]
            local itemId = data[2]
            local itemType = data[1]
            local eventStyle = 1--{itemId = itemId, num = num,eventStyle = 0} 
            local scale = 0.6
            if itemType == "hero" then
                local heroData = clone(tab:Hero(itemId))
                itemIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
                itemIcon:getChildByName("starBg"):setVisible(false)
                for i=1,6 do
                    if itemIcon:getChildByName("star" .. i) then
                        itemIcon:getChildByName("star" .. i):setPositionY(itemIcon:getChildByName("star" .. i):getPositionY() + 5)
                    end
                end
                itemIcon:setSwallowTouches(false)
                registerClickEvent(itemIcon, function()
                    local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                    self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = itemId}, true)
                end)
                scale = 0.53
            elseif itemType == "team" then
                local teamTeam = clone(tab:Team(itemId))
                itemIcon = IconUtils:createSysTeamIconById({sysTeamData = teamTeam,isJin=true})
                scale = 0.52
            elseif itemType == "avatarFrame" then
                local frameData = tab:AvatarFrame(itemId)
                param = {itemId = itemId, itemData = frameData}
                itemIcon = IconUtils:createHeadFrameIconById(param)
                scale = 0.52
            elseif itemType == "rune" then
                local stoneTab = tab:Rune(itemId) 
                local param = {suitData = stoneTab, num = data[3]}
                itemIcon = IconUtils:createHolyIconById(param)
                itemIcon:setScaleAnim(true)
                scale = 0.52
            else
                if itemType ~= "tool" then
                    itemId = IconUtils.iconIdMap[itemType]
                end
                itemIcon = IconUtils:createItemIconById({itemId = itemId, num = data[3],eventStyle = eventStyle})
            end
            local posX = itemX
            local posY = itemY
            if posArr[i] then
                posX = itemX + posArr[i][1]*itemW - itemW*0.5
                posY = itemY + posArr[i][2]*itemW - itemW*0.5
            end
            itemIcon:setScale(scale)
            itemIcon:setPosition(posX, posY)
            itemIcon:setAnchorPoint(0,0)
            iconPanel:addChild(itemIcon)
            -- if i % itemN == 0 then
            --     itemY = itemY - itemW
            --     itemX = 6
            -- else
            --     itemX = itemX + itemW
            -- end

            -- N选1
            -- if 0 == acData.rewardtype and i < rewardNum then
            --     local txt = ccui.Text:create()
            --     txt:setFontSize(24)
            --     txt:setColor(cc.c4b(122,82,55,255))
            --     txt:setFontName(UIUtils.ttfName)
            --     txt:setString("或")
            --     txt:setName("selectTip" .. i)
            --     txt:setVisible(true)
            --     txt:setPosition((i-1)*100 + 80,30)
            --     iconPanel:addChild(txt)
            -- end
        end
    end

    condTxt1:setVisible(0 ~= acData.statusInfo.status)
    condTxt2:setVisible(0 ~= acData.statusInfo.status)
    condTxt2:setColor(1 == acData.statusInfo.status and UIUtils.colorTable.ccUIBaseColor9 or UIUtils.colorTable.ccUITabColor1)
    condTxt2:setString((acData.statusInfo.condition - acData.statusInfo.value) .. "/" .. acData.statusInfo.condition)
    goBtn:setVisible(-1 == acData.statusInfo.status and acData.button > 0)

    getBtn:setVisible(1 == acData.statusInfo.status or (-1 == acData.statusInfo.status and 0 == acData.button))
    getBtn:setSaturation(1 == acData.statusInfo.status and 0 or -100)
    getBtn:setBright(1 == acData.statusInfo.status)
    getMC:setVisible(1 == acData.statusInfo.status)

    getSp:setVisible(0 == acData.statusInfo.status)
    -- 领取按钮事件
    registerClickEvent(getBtn,function(sender) 
        self:onButtonGetClicked(acData)
    end)
    -- 前往按钮事件
    registerClickEvent(goBtn,function(sender) 
        self:onButtonGoClicked(acData)
    end)
end


function ActivitySingleChargeLayer:onButtonGoClicked(taskData)
    --print("onButtonGoClicked")
    if self["goView" .. taskData.button] then
        self["goView" .. taskData.button](self)
    end
end

function ActivitySingleChargeLayer:goView1() self._viewMgr:showView("intance.IntanceView", {superiorType = 1}) end
function ActivitySingleChargeLayer:goView2() self._viewMgr:showView("vip.VipView", {viewType = 0}) end
function ActivitySingleChargeLayer:goView3()
    if not SystemUtils:enableElite() then
        self._viewMgr:showTip(lang("TIP_JINGYING_1"))
        return 
    end
    self._viewMgr:showView("intance.IntanceEliteView", {superiorType = 1}) 
end
function ActivitySingleChargeLayer:goView4() 
    if not SystemUtils:enableDwarvenTreasury() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("pve.AiRenMuWuView") 
end
function ActivitySingleChargeLayer:goView5() 
    if not SystemUtils:enableCrypt() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("pve.ZombieView") 
end
function ActivitySingleChargeLayer:goView6() 
    if not SystemUtils:enableBoss() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("pve.DragonView") 
end
function ActivitySingleChargeLayer:goView7() self._viewMgr:showView("team.TeamListView") end
function ActivitySingleChargeLayer:goView8() self._viewMgr:showView("flashcard.FlashCardView") end
function ActivitySingleChargeLayer:goView9() 
    if not SystemUtils:enableArena() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("arena.ArenaView") 
end
function ActivitySingleChargeLayer:goView10() 
    if not SystemUtils:enableCrusade() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("crusade.CrusadeView") 
end
function ActivitySingleChargeLayer:goView11() DialogUtils.showBuyRes({goalType = "gold", callback = function(success)
    if success then self._layer_task_everyday._scrollView:scrollToTop(1, true) end
end}) end
function ActivitySingleChargeLayer:goView12() DialogUtils.showBuyRes({goalType = "physcal", callback = function(success)
    if success then self._layer_task_everyday._scrollView:scrollToTop(1, true) end
end}) end
function ActivitySingleChargeLayer:goView13()
    if self._uiIndex == self:getActivityUIIndexById(101) then
        self._viewMgr:showTip(lang("tips_zhaomuyouli"))
        return
    end
    self:switchActivityById(101)
end
function ActivitySingleChargeLayer:goView14() DialogUtils.showBuyRes({goalType = "gem", callback = function(success)
    if success then self._layer_task_everyday._scrollView:scrollToTop(1, true) end
end}) end
function ActivitySingleChargeLayer:goView15() DialogUtils.showBuyRes({goalType = "gem", callback = function(success)
    if success then self._layer_task_everyday._scrollView:scrollToTop(1, true) end
end}) end
function ActivitySingleChargeLayer:goView16() 
    if self._modelMgr:getModel("ActivityCarnivalModel"):carnivalIsOpen() then
        self._viewMgr:showDialog("activity.ActivityCarnival", {}, true)
    else
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
    end
end

function ActivitySingleChargeLayer:goView17() 
    local showday, _ = self._modelMgr:getModel("ActivitySevenDaysModel"):getShowDayAndState()
    if SystemUtils:enableSevenDay() and showday > 0  then
        self._viewMgr:showDialog("activity.ActivitySevenDaysView", {})
    else
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
    end
end

function ActivitySingleChargeLayer:showRewardDialog(taskData)
    DialogUtils.showGiftGet({gifts = taskData.reward})
end

function ActivitySingleChargeLayer:onButtonGetClicked(taskData)
    print("onButtonGetClicked")

    if 1 ~= taskData.statusInfo.status then
        self._viewMgr:showTip(lang("TIP_TASK_RECIEVE"))
        return
    end
    local getAwardFunc = function(taskId,awardIdx)
        local context = {tid = taskId,cid=awardIdx}
        if not self or not self._serverMgr then 
            ViewManager:getInstance():showTip("该活动已结束，未领取的奖励将通过邮件补发哦")
            return 
        end
        self._serverMgr:sendMsg("SingleRechargeServer", "getReward", context, true, {}, function(success, data)
            if not success then return end
            self:showRewardDialog(data)
            self:refreshUI()
        end)
    end

    if 0 == taskData.rewardtype then
        self._viewMgr:showDialog("global.GlobalSelectAwardDialog", {gift = taskData.reward or {},callback = function(idx)
            awardIdx = idx
            getAwardFunc(taskData.id,awardIdx)
        end})
    else
        getAwardFunc(taskData.id, awardIdx)     
    end
end

return ActivitySingleChargeLayer