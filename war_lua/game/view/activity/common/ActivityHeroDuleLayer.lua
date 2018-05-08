--[[
    Filename:    ActivityHeroDuleLayer.lua
    Author:      <hexinping@playcrab.com>
    Datetime:    2017-9-19 
    Description: 英雄交锋活动
--]]

-- local vars
local tonumber                  = tonumber
local tostring                  = tostring
local tableInsert               = table.insert
local tableSort                 = table.sort
local mathFloor                 = math.floor
local mathFmod                  = math.fmod
local stringFormat              = string.format
local modelManager              = ModelManager:getInstance()
local getModel                  = modelManager.getModel
local createHeroIconById        = IconUtils.createHeroIconById
local createSysTeamIconById     = IconUtils.createSysTeamIconById
local createHeadFrameIconById   = IconUtils.createHeadFrameIconById
local createItemIconById        = IconUtils.createItemIconById
local iconIdMap                 = IconUtils.iconIdMap


local ActivityHeroDuleLayer = class("ActivityHeroDuleLayer", require("game.view.activity.common.ActivityCommonLayer"))

local pageVar = {
    kActivityTaskItemTag = 1000,
    kRewardItemTag1      = 1000,
}

function ActivityHeroDuleLayer:ctor(params)
    ActivityHeroDuleLayer.super.ctor(self)
    self._activityId = params.activityId
    self._activityModel = getModel(modelManager, "ActivityModel")
    self._userModel     = getModel(modelManager,"UserModel")
    self._vipModel      = getModel(modelManager,"VipModel")
    self._itemModel     = getModel(modelManager,"ItemModel")
end

function ActivityHeroDuleLayer:onDestroy()
    ActivityHeroDuleLayer.super.onDestroy(self)
end

function ActivityHeroDuleLayer:disableTextEffect(element)
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

function ActivityHeroDuleLayer:onInit()
    self:disableTextEffect()
    self._scheduler = cc.Director:getInstance():getScheduler()

    self._activityData = tab:DailyActivity(self._activityId)

    self._activityTaskData = {}
    self._taskTableView = nil
    self._cellW = 638 
    self._cellH = 120

    self._layerItem = self:getUI("layer_item_1")
    self._layerTaskList = self:getUI("bg.layer_activity_tasks.layer_task_list")

    self._imageActivityTitle = self:getUI("bg.image_activity_title")
    self._imageActivityBg = self:getUI("bg.image_activity_bg")

    self._activityTimeDes = self:getUI("bg.activity_time_des")
    self._activityTimeDes:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self._activityTime = self:getUI("bg.activity_time")
    self._activityTime:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self._activityDescription = self:getUI("bg.activity_description")

    self:refreshUI()

    self:registerScriptHandler(function(state)
        if state == "exit" then
            self:endClock()
        end 
    end)
end


function ActivityHeroDuleLayer:refreshUI()
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


function ActivityHeroDuleLayer:getTaskStatus(data, acData)
    local conditionNum = data.condition_num
    local t = {}

    -- 先判断是否已经领取
    if acData.taskList then
        for k,v in pairs(acData.taskList) do
            if tonumber(k) == data.id and v == 1 then
                t.status = 0
                break
            end 
        end
    end

    if data.type == 1 then
        local value = acData.winTotal or 0
        if t.status == nil  then
            t.status = value >= conditionNum[1] and 1 or -1
        end
    
        t.rcv = value
        t.lim = conditionNum[1]
        return true, t
    elseif data.type == 2 then
        
        local condition = conditionNum[1]
        local value = 0 
        if type(acData.tWins) == "table" then
            local num = conditionNum[2]
            for k,v in pairs(acData.tWins) do
                if v >= num then
                    value = value + 1
                end 
            end
        end
        if t.status ==  nil then
            t.status = value >= condition and 1 or -1
        end 
        t.rcv = value
        t.lim = condition
        return true, t

    elseif data.type == 3 then
        local heroId = conditionNum[1]
        local value = 0
        if type(acData.heroWin) == "table" then
            for k,v in pairs(acData.heroWin) do
                if heroId == tonumber(k) then
                    value = tonumber(v)
                    break
                end 
            end
        end
        if t.status == nil then
            t.status = value >= conditionNum[2] and 1 or -1
        end
        t.rcv = value
        t.lim = conditionNum[2]
        return true, t
    end
    return false 
end

function ActivityHeroDuleLayer:initActivityData()

    local result = {}
    local acData = self._activityModel:getAcHeroDuelData()
    local acTaskData = tab:DailyActivity(tonumber(self._activityId))

    local findacTableData = function(key)
        local acTableData = tab:AcheroDuel(tonumber(key))
        if not acTableData then return false end
        return true, {
            id = tonumber(key),
            button = 2,
            condition_num = acTableData.condition_num,
            description = acTableData.des,
            reward = acTableData.reward,
            type   = acTableData.type,
            uitype = 1,
        }
    end

    for _, id in pairs(acTaskData.task_list) do
        -- 通过任务id 从相应的表里拿到对应的任务数据
        local f, t = findacTableData(tonumber(id))
        if f then
            local f1, t2 = self:getTaskStatus(t,acData)
            if f1 then
                t.statusInfo = {
                    status = t2.status,
                    value = t2.rcv,
                    condition = t2.lim
                }
                if t2.status == 1 then
                    -- 可以领取
                    t.order = 3
                elseif t2.status == -1 then
                    -- 不能领取
                    t.order = 2
                else
                    -- 已经领取
                    t.order = 1
                end
            end
            -- 把所有的任务数据放入result里
            tableInsert(result, t)
        end
    end

    tableSort(result, function(a, b)
        if a.order == b.order then
            return a.id < b.id
        else
            return a.order > b.order 
        end
    end)
    return result
end

function ActivityHeroDuleLayer:getActivityShowList()
    local acShowList = self._activityModel:getActivityShowList()
    for k, v in pairs(acShowList) do
        if v.activity_id == self._activityId then
            return v
        end
    end
end



function ActivityHeroDuleLayer:getRemainTimeAndTips()
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

function ActivityHeroDuleLayer:updateTimeCountDown()
    self._remainTime, self._timerTips = self:getRemainTimeAndTips()

    local tempValue = self._remainTime    
    local day = mathFloor(tempValue/86400) 
    tempValue = tempValue - day*86400
    
    local hour = mathFloor(tempValue/3600)
    tempValue = tempValue - hour*3600

    local minute = mathFloor(tempValue/60)
    tempValue = tempValue - minute*60
   
    local second = mathFmod(tempValue, 60)
    local showTime = stringFormat("%.2d天%.2d:%.2d:%.2d", day, hour, minute, second)
    if day == 0 then
        showTime = stringFormat("00天%.2d:%.2d:%.2d", hour, minute, second)
    end
    if self._remainTime <= 0 then
        showTime = "00天00:00:00"
    end
    self._activityTime:setString(showTime)
end

function ActivityHeroDuleLayer:startClock()
    self._timerDirty = true
    if self._timer_id then return end
    self._timer_id = self._scheduler:scheduleScriptFunc(handler(self, self.updateTimeCountDown), 1, false)
end

function ActivityHeroDuleLayer:endClock()
    if not self._timer_id then return end
    if self._timer_id then 
        self._scheduler:unscheduleScriptEntry(self._timer_id)
        self._timer_id = nil
        self._timerDirty = false
    end
end


function ActivityHeroDuleLayer:createActivityTaskTableView()
    if not self._taskTableView then
        self._taskTableView = cc.TableView:create(self._layerTaskList:getContentSize())
        self._taskTableView:setDelegate()
        self._taskTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self._taskTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_LEFTRIGHT)
        self._taskTableView:setAnchorPoint(cc.p(0, 0))
        self._taskTableView:setPosition(cc.p(0, 0))
        self._layerTaskList:addChild(self._taskTableView)
        self._taskTableView:registerScriptHandler(handler(self, self.activityTaskTableViewCellTouched), cc.TABLECELL_TOUCHED)
        self._taskTableView:registerScriptHandler(handler(self, self.activityTaskTableViewCellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
        self._taskTableView:registerScriptHandler(handler(self, self.activityTaskTableViewCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
        self._taskTableView:registerScriptHandler(handler(self, self.activityTaskNumberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        
    end
    self._taskTableView:reloadData()
end

function ActivityHeroDuleLayer:activityTaskTableViewCellTouched(tableView, cell)

end

function ActivityHeroDuleLayer:activityTaskTableViewCellSizeForTable(tableView, idx)
    return self._cellH, self._cellW
end

function ActivityHeroDuleLayer:activityTaskTableViewCellAtIndex(tableView, idx)
    local cell = tableView:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
        local taskData = self._activityTaskData[idx+1]
        local acItem = self:createItem(taskData,idx+1)
        acItem:setTag(pageVar.kActivityTaskItemTag)
        -- self:updateAcItem(acItem, idx)
         acItem:setPosition(cc.p(0,0))
         acItem:setAnchorPoint(cc.p(0,0))
        cell:addChild(acItem)
    else
        local item = cell:getChildByTag(pageVar.kActivityTaskItemTag)
        local index = idx + 1
        local taskData = self._activityTaskData[index]
        self:createItem(taskData,index, item)
    end
    return cell
end
function ActivityHeroDuleLayer:activityTaskNumberOfCellsInTableView(tableView)
    if not (self._activityTaskData and type(self._activityTaskData)  == "table") then return 0 end
    return #self._activityTaskData
end

function ActivityHeroDuleLayer:updateState(item, taskData, index)
     -- update
    local layerGray = item:getChildByFullName("layer_gray")
    local btnGo = item:getChildByFullName("btn_go")
    local btnGet = item:getChildByFullName("btn_get")
    local taskDescription = item:getChildByFullName("task_description")
    local taskCurrentDataBg = item:getChildByFullName("task_current_data_bg")
    local taskCurrentDataBg0 = item:getChildByFullName("task_current_data_bg0")
    local taskCurrentData = item:getChildByFullName("task_current_data_bg.task_current_data")
    taskCurrentData:setColor(cc.c3b(138, 92, 29))
    local taskCurrentData0 = item:getChildByFullName("task_current_data_bg0.task_current_data")
    taskCurrentData0:setColor(cc.c3b(138, 92, 29))

    local getMC = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true)
    getMC:setPlaySpeed(1, true)
    getMC:setPosition(btnGet:getContentSize().width / 2 - 2, btnGet:getContentSize().height / 2)
    btnGet:removeAllChildren()
    btnGet:addChild(getMC)
    self:registerClickEvent(btnGo, function ()
        self:onButtonGoClicked(taskData, index)
    end)

    self:registerClickEvent(btnGet, function ()
        self:onButtonGetClicked(taskData, index)
    end)

    local imageAlreadyGet = item:getChildByFullName("image_already_get")

    layerGray:setVisible(0 == taskData.statusInfo.status)
    btnGo:setVisible(-1 == taskData.statusInfo.status and taskData.button > 0)
    btnGet:setVisible(1 == taskData.statusInfo.status or (-1 == taskData.statusInfo.status and 0 == taskData.button))
    --btnGet:setEnabled(1 == taskData.statusInfo.status)
    btnGet:setSaturation(1 == taskData.statusInfo.status and 0 or -100)
    btnGet:setBright(1 == taskData.statusInfo.status)
    getMC:setVisible(1 == taskData.statusInfo.status)
    imageAlreadyGet:setVisible(0 == taskData.statusInfo.status)
    taskCurrentDataBg:setVisible(not imageAlreadyGet:isVisible() and not taskData.condition and not self._tmpShowRematinTimes)
    -- taskCurrentData:setVisible(not imageAlreadyGet:isVisible() and not taskData.condition)
    taskCurrentData:setColor(1 == taskData.statusInfo.status and cc.c3b(28, 162, 22) or cc.c3b(138, 92, 29))
    --taskCurrentData:setVisible(not imageAlreadyGet:isVisible() and not (taskData.condition and 1 == taskData.statusInfo.condition)) -- temp code fixed me
    taskCurrentDataBg0:setVisible(not imageAlreadyGet:isVisible() and not taskData.condition and self._tmpShowRematinTimes)
    taskCurrentData0:setColor(1 == taskData.statusInfo.status and cc.c3b(28, 162, 22) or cc.c3b(138, 92, 29))
    btnGet:setPositionY(taskCurrentData:isVisible() and 50 or 65)
    btnGo:setPositionY(taskCurrentData:isVisible() and 50 or 65)

    local labelDiscription = taskDescription
    local desc = lang(taskData.description)
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
    --taskCurrentData:setPositionY((btnGo:isVisible() or btnGet:isVisible()) and 90 or 60)
    local labelCurrentData = self._tmpShowRematinTimes and taskCurrentData0 or taskCurrentData
    if not taskData.finish_max then
        labelCurrentData:setString(string.format("%d/%d", taskData.statusInfo.value, taskData.statusInfo.condition))
    else
        labelCurrentData:setString(string.format("%d/%d", taskData.times, taskData.finish_max))
    end
end

function ActivityHeroDuleLayer:updateReward(item, taskData)
    local rewards = {}
    for i = 1, 4 do
        rewards[i] = {}
        rewards[i]._icon = item:getChildByFullName("layer_reward_bg.layer_reward_" .. i)
        rewards[i]._icon:setVisible(false)
    end

    local giftContain = taskData.reward
    for i = 1, #giftContain do
        local giftItem = rewards[i]._icon
        giftItem:setVisible(true)
        local itemIcon = giftItem:getChildByTag(pageVar.kRewardItemTag1)
        if itemIcon then itemIcon:removeFromParent() end
        local itemId = giftContain[i][2]
        local itemType = giftContain[i][1]
        local eventStyle = 1--{itemId = itemId, num = num,eventStyle = 0} 
        if itemType == "hero" then
            local heroData = clone(tab:Hero(itemId))
            itemIcon = createHeroIconById(self, {sysHeroData = heroData})
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
            itemIcon = createSysTeamIconById(self, {sysTeamData = teamTeam,isJin=true})
            --itemIcon:setAnchorPoint(cc.p(0,0))
            --itemIcon:setSwallowTouches(false)
        elseif itemType == "avatarFrame" then
            local frameData = tab:AvatarFrame(itemId)
            param = {itemId = itemId, itemData = frameData}
            itemIcon = createHeadFrameIconById(self, param)
        else
            if itemType ~= "tool" then
                itemId = iconIdMap[itemType]
            end
            itemIcon = createItemIconById(self, {itemId = itemId, num = giftContain[i][3],eventStyle = eventStyle})
        end
        local scale = 0.71
        if itemType == "team" or itemType == "hero" then
            scale = 0.61
        elseif itemType == "avatarFrame" then
            scale = 0.58
        end
        itemIcon:setScale(scale)
        itemIcon:setTag(pageVar.kRewardItemTag1)
        giftItem:addChild(itemIcon)
    end
end

function ActivityHeroDuleLayer:createItem(data, index,layerItem)
    local item = layerItem or self._layerItem:clone()
    local taskData = data
    self:updateState(item, taskData, index)
    self:updateReward(item, taskData)
    return item
end

function ActivityHeroDuleLayer:onButtonGoClicked(taskData, index)
    printLog("onButtonGoClicked","%d",index)
    self._viewMgr:showView("heroduel.HeroDuelMainView")
end

function ActivityHeroDuleLayer:showRewardDialog(taskData)
    DialogUtils.showGiftGet({gifts = taskData.reward})
end

function ActivityHeroDuleLayer:onButtonGetClicked(taskData, index)
    printLog("onButtonGetClicked:","%d",index)

    if 1 ~= taskData.statusInfo.status then
        self._viewMgr:showTip(lang("TIP_TASK_RECIEVE"))
        return
    end
    local context = {taskId = taskData.id}
    self._serverMgr:sendMsg("AcHeroDuelServer", "getAcHeroDuelReward", context, true, {}, function(success, data)
            if not success then return end
            self:showRewardDialog(data)
            self:refreshUI()
    end)
end

function ActivityHeroDuleLayer.dtor()
    tonumber                = nil
    tostring                = nil
    tableInsert             = nil
    tableSort               = nil
    mathFloor               = nil
    mathFmod                = nil
    stringFormat            = nil
    modelManager            = nil
    getModel                = nil
    createHeroIconById      = nil
    createSysTeamIconById   = nil
    createHeadFrameIconById = nil
    createItemIconById      = nil
    iconIdMap               = nil
    pageVar                 = nil
end

return ActivityHeroDuleLayer