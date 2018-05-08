--[[
    Filename:    ActivityView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-01-26 17:37:46
    Description: File description
--]]

local ActivityTaskItemView = require("game.view.activity.ActivityTaskItemView")
--[[ activity optimize
local ActivityTaskItemView1 = require("game.view.activity.ActivityTaskItemView1")
local ActivityTaskItemView2 = require("game.view.activity.ActivityTaskItemView2")
local ActivityTaskItemView3 = require("game.view.activity.ActivityTaskItemView3")
local ActivityTaskItemView4 = require("game.view.activity.ActivityTaskItemView4")
]]

local ActivityView = class("ActivityView", BaseView)

ActivityView.kActivityTaskItemTag = 1000
ActivityView.kActivityButtonItemTag = 2000
ActivityView.kActivityLayerTag = 3000

ActivityView.kNormalZOrder = 500
ActivityView.kLessNormalZOrder = ActivityView.kNormalZOrder - 1
ActivityView.kAboveNormalZOrder = ActivityView.kNormalZOrder + 1
ActivityView.kHighestZOrder = ActivityView.kAboveNormalZOrder + 1

ActivityView.kActivityType1 = 1
ActivityView.kActivityType2 = 2
ActivityView.kActivityType3 = 3
ActivityView.kActivityType4 = 4

function ActivityView:ctor(params)
    ActivityView.super.ctor(self)
    self.initAnimType = 1
    self._activityModel = self._modelMgr:getModel("ActivityModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._vipModel = self._modelMgr:getModel("VipModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._commentGuideModel = self._modelMgr:getModel("CommentGuideModel")
    self._specifiedActivityId = params and params.specifiedActivityId or 0
    self._lotterModel = self._modelMgr:getModel("AcLotteryModel")
end

function ActivityView:onDestroy()
    if self._reflashing then
        self._viewMgr:unlock()
    end
    -- 更新每日折扣标记位
    self._modelMgr:getModel("ActivityRebateModel"):setACERebateData(false)
    ActivityView.super.onDestroy(self)
end


function ActivityView:getAsyncRes()
    return  {
                {"asset/ui/activity.plist", "asset/ui/activity.png"},
                {"asset/ui/activity1.plist", "asset/ui/activity1.png"},
                {"asset/ui/shop.plist", "asset/ui/shop.png"},
                {"asset/ui/acERecharge.plist", "asset/ui/acERecharge.png"},
                {"asset/ui/acERecharge1.plist", "asset/ui/acERecharge1.png"},
                {"asset/ui/acCelebration.plist", "asset/ui/acCelebration.png"},
                {"asset/ui/acCelebration1.plist", "asset/ui/acCelebration1.png"},
            }
end

function ActivityView:getBgName()
    return "bg_007.jpg"
end

function ActivityView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{title = "globalTitleUI_activity.png",titleTxt = "活动"})
end

function ActivityView:disableTextEffect(element)
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

function ActivityView:onInit()
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("activity.ActivityView")
        end
    end)
    -- 通用动态背景
    self:addAnimBg()
    self:disableTextEffect()

    self._scheduler = cc.Director:getInstance():getScheduler()

    self._activity = {}
    self._taskTableView = nil
    self._buttonTableView = nil
    self._uiIndex = 0
    self._lastUIIndex = 0
    self._firstIn = true
    self._acChecked = {}

    self._bg = self:getUI("bg")

    self._layerActivity1 = self:getUI("bg.activity_bg.activity_bg_frame.layer_activity_1")
    self._layerActivity2 = self:getUI("bg.activity_bg.activity_bg_frame.layer_activity_2")

    self._layerTaskList = self:getUI("bg.activity_bg.activity_bg_frame.layer_activity_1.layer_activity_tasks.layer_task_list")

    self._layerButtonList = self:getUI("bg.activity_bg.activity_bg_frame.layer_activity_buttons.layer_buttons_list")
    self._activityButton = self:getUI("bg.activity_bg.activity_bg_frame.layer_activity_buttons.btn_activity")
    --[[
    self._activityTitle = self:getUI("bg.activity_bg.activity_bg_frame.layer_activity_1.activity_title")
    self._activityTitle:enable2Color(1, cc.c4b(255, 194, 68, 255))
    self._activityTitle:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._activityTitle:setFontName(UIUtils.ttfName_Title)
    ]]

    self._imageActivityTitle = self:getUI("bg.activity_bg.activity_bg_frame.layer_activity_1.image_activity_title")
    self._imageActivityBg = self:getUI("bg.activity_bg.activity_bg_frame.layer_activity_1.image_activity_bg")
    self._imageActivityTitle:setVisible(false)

    self._activityTimeDes = self:getUI("bg.activity_bg.activity_bg_frame.layer_activity_1.activity_time_des")
    self._activityTimeDes:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    --self._activityTimeDes:setFontName(UIUtils.ttfName)

    self._activityTime = self:getUI("bg.activity_bg.activity_bg_frame.layer_activity_1.activity_time")
    self._activityTime:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    --self._activityTime:setFontName(UIUtils.ttfName)

    self._activityDescription = self:getUI("bg.activity_bg.activity_bg_frame.layer_activity_1.activity_description")
    --self._activityDescription:enable2Color(1, cc.c4b(255, 194, 68, 255))
    --self._activityDescription:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    --self._activityDescription:setFontName(UIUtils.ttfName)
    --[[
    self:registerClickEventByName("bg.activity_bg.activity_bg_frame.btn_close", function ()
        self:close()
    end)
    ]]

    self._blowMC = mcMgr:createViewMC("huodongpiaodai_vipmainview", false, false, function()
    end, RGBA8888)
    self._blowMC:setVisible(false)
    self._blowMC:stop()
    self._blowMC:setPosition(self._bg:getContentSize().width / 2, self._bg:getContentSize().height / 2 + 10)
    self._bg:addChild(self._blowMC, 1000)

    self:registerScriptHandler(function(state)
        if state == "exit" then
            self:endClock()
        end 
    end)

    self:setListenReflashWithParam(true)
    self:listenReflash("ActivityModel", self.onModelReflash)
    self:listenReflash("UserModel", self.onModelReflash)
    self._reflashEventTab = {}
    self._reflashing = false
    -- 体力更新监听  hgf
    self:listenReflash("PhysicalPowerModel", self.reflashPhysicalUI)
    -- 每日折扣购买推送监听 qh
    self:listenReflash("ActivityRebateModel", self.reflashRebateUI)
    -- 每日抽奖
    self:listenReflash("AcLotteryModel", self.reflashLotteryUI)

    -- 圣徽周卡
    self:listenReflash("RuneCardModel", self.reflashRuneCardUI)

end


function ActivityView:refreshUI()
    self._activity = self:initActivityData()
    if self._firstIn then
        self._uiIndex = self:getActivityUIIndexById(self._specifiedActivityId)
        self._firstIn = false
    end

    if not self._playBlowMC then
        self._blowMC:addEndCallback(function()
            self._blowMC:stop()
            self._blowMC:setVisible(false)
        end)
        self._blowMC:setVisible(true)
        self._blowMC:gotoAndPlay(0)
        self._playBlowMC = true
    end

    self:refreshButtonTableView()
    self:switchActivity(self:getCurrentActiviyUIIndex(), true)
end

function ActivityView:onBeforeAdd(callback, errorCallback)
    if self._activityModel:isNeedRequest() then
        self:doRequestData(callback, errorCallback)
    else
        self:refreshUI()
        if callback then
            callback()
        end
    end
    --[[
    if self._activityModel:isNeedRequest() then
        self:doRequestData(callback, errorCallback)
    else
        self._activity = self:initActivityData()
        self:refreshButtonTableView()
        self:switchActivity(self:getCurrentActiviyUIIndex(), true)
        if callback then
            callback()
        end
    end
    ]]
end

function ActivityView:onTop()
    self._playBlowMC = false
    if self._activityModel:isNeedRequest() then
        self:doRequestData()
    else
        self:refreshUI()
    end
    --[[
    if self._activityModel:isNeedRequest() then
        ScheduleMgr:delayCall(200, self, self.doRequestData)
    else
        self._activity = self:initActivityData()
        self:refreshButtonTableView()
        self:switchActivity(self:getCurrentActiviyUIIndex(), true)
        if callback then
            callback()
        end
    end
    ]]

    -- 更新嘉年华数据
    local carnivalModel = self._modelMgr:getModel("ActivityCarnivalModel")  
    carnivalModel:doUpdate()
end
    
function ActivityView:doRequestData(callback, errorCallback)
    self._serverMgr:sendMsg("ActivityServer", "getAcAll", {}, true, {}, function(success)
        if not success then return end
        self._activityModel:evaluateActivityData("evaluateActivityData", true)
        self:refreshUI()
        if callback then
            callback()
        end
    end, 
    function(errorCode)
        if errorCode and errorCallback then
            errorCallback()
        end
    end)
end

--[=[
function ActivityView:doRequestData(callback, errorCallback)
    self._serverMgr:sendMsg("ActivityServer", "getTaskAcInfo", {}, true, {}, function(success)
        self._serverMgr:sendMsg("ActivityServer", "getShowList", {}, true, {}, function(success)
            self._activity = self:initActivityData()
            self:refreshButtonTableView()
            self:switchActivity(self:getCurrentActiviyUIIndex(), true)
            if callback then
                callback()
            end
        end, errorCallback)
    end, errorCallback)
end

function ActivityView:activityIndexToUIIndex(acIndex)
    for k, v in ipairs(self._activity) do
        if v.acIndex == acIndex then
            return k
        end
    end
    return 1
end

function ActivityView:uiIndexToActivityIndex(uiIndex)
    return self._activity[uiIndex].acIndex
end

function ActivityView:getCurrentActiviyUIIndex()

    --local lastActivityIndex = SystemUtils.loadAccountLocalData("LAST_ACTIVITY_INDEX")
    --if lastActivityIndex then return self:activityIndexToUIIndex(lastActivityIndex) end

    return self:activityIndexToUIIndex(self._activity[1].acIndex)
    --[[
    if self._uiIndex then return self._uiIndex end

    if SystemUtils:enableDailyTask() then
        for _, v in ipairs(self._activity.detailTasks) do
            if 1 == v.status then
                return self.kuiIndexEveryday
            end
        end

        if self._activityModel:hasTaskCanGetByType(TaskItemView.kuiIndexItemEveryday) then
            return self.kuiIndexEveryday
        end
    end

    for _, v in ipairs(self._activity.mainTasks) do
        if 1 == v.status then
            return self.kuiIndexPrimaryLine
        end
    end

    if self._activityModel:hasTaskCanGetByType(TaskItemView.kuiIndexItemPrimary) then
        return self.kuiIndexPrimaryLine
    end

    local lastTaskTag = self:loadLocalData("LAST_TASK_TAG" .. self._userModel:getUID())
    if lastTaskTag then return lastTaskTag end

    return self.kuiIndexPrimaryLine
    ]]
end
]=]

function ActivityView:getCurrentActiviyUIIndex()
    if 0 ~= self._uiIndex and self._activity and self._activity[self._uiIndex] then 
        return self._uiIndex 
    end
    return 1
end

function ActivityView:getActivityUIIndexById(activityId)
    for k, v in ipairs(self._activity) do
        if v.id == activityId then
            return tonumber(k)
        end
    end
    return 0 ~= self._uiIndex and self._uiIndex or 1
end

-- 根据类型获得活动数据
function ActivityView:getActivityUIIndexByType(acType)
    for k, v in ipairs(self._activity) do
        if v.acType and v.acType == acType then
            return tonumber(k)
        end
    end
    return 0 ~= self._uiIndex and self._uiIndex or 1
end

function ActivityView:onModelReflash(eventName)
    print("eventName:", eventName)
    local currentUIIndex = self:getCurrentActiviyUIIndex()
    if not self._activity[currentUIIndex] then return end
    if eventName and type(eventName) == "string" then
        if eventName == "UserModel" or 
           eventName == "updateSpecialData" then
            if self._activity[currentUIIndex].layer then
                -- self._activity[currentUIIndex].layer:reflashUI()
                self._reflashEventTab[1] = true
            end
            -- self:refreshButtonTableView()
            self._reflashEventTab[2] = true
        elseif eventName == "evaluateActivityData" then
            if self._activity[currentUIIndex].layer then
                -- self._activity[currentUIIndex].layer:reflashUI()
                self._reflashEventTab[1] = true
            end
            -- self:refreshUI()
            self._reflashEventTab[3] = true
        elseif eventName == "pushUserEvent" then
            if self._activity[currentUIIndex].layer then
                -- self._activity[currentUIIndex].layer:reflashUI()
                self._reflashEventTab[1] = true
            else
                -- self:refreshUI()
                self._reflashEventTab[3] = true
            end
        elseif eventName == "pushActivityEvent" then
            -- self:refreshUI()
            self._reflashEventTab[3] = true
        else
            -- self:refreshUI()
            self._reflashEventTab[3] = true
        end
    else
        self._reflashEventTab[3] = true
        -- self:refreshUI()
    end

    local checkValid = function()
        return (self._reflashEventTab and self.refreshUI and self.getCurrentActiviyUIIndex and self._activity and self.refreshButtonTableView and self._viewMgr)
    end
    -- self._reflashEventTab
    -- 1 为self._activity[currentUIIndex].layer:reflashUI()
    -- 2 为self:refreshButtonTableView()
    -- 3 为refreshUI()
    if not self._reflashing then
        self._reflashing = true
        self._viewMgr:lock(-1)
        ScheduleMgr:delayCall(100, self, function()
            if not checkValid() then return end
            if self._reflashEventTab[3] then
                self:refreshUI()
            else
                if self._reflashEventTab[1] then
                    local currentUIIndex = self:getCurrentActiviyUIIndex()
                    if self._activity[currentUIIndex] and self._activity[currentUIIndex].layer and self._activity[currentUIIndex].layer.reflashUI then
                        self._activity[currentUIIndex].layer:reflashUI()
                    end
                end
                if self._reflashEventTab[2] then
                    self:refreshButtonTableView()
                end
            end
            self._reflashEventTab = {}
            self._viewMgr:unlock()
            self._reflashing = false
        end)
    end
end

function ActivityView:initActivityData()
    local result = {}
    local acTableData = tab.dailyActivity
    local acTaskTableData = tab.dailyActivityTask
    local acTaskData = self._activityModel:getActivityTaskData()
    local acShowList = self._activityModel:getActivityShowList()
    local acOpenInfoTableData = tab.activityopen
    -- if OS_IS_WINDOWS then
    --     acOpenInfoTableData = tab.activityopen_dev
    -- end

    -- dump(acTableData, "acTableData", 5)
    -- dump(acTaskTableData, "acTaskTableData", 5)
    -- dump(acTaskData, "acTaskData", 5)
    -- dump(acShowList, "acShowList", 5)

    local findacTableData = function(acId)
        for k, v in pairs(acTableData) do
            if v.id == acId then
                return true, v
            end
        end
        return false
    end

    local findacTaskTableData = function(acTaskId)
        for k, v in pairs(acTaskTableData) do
            if v.id == acTaskId then
                return true, v
            end
        end
        return false
    end

    local findacOpenInfoData = function(acId)
        for k, v in pairs(acShowList) do
            if tonumber(v.activity_id) == tonumber(acId) then
                local t = clone(v)
                t.acId = nil
                return true, t
            end
        end
        return false
    end

    local findacTaskData = function(acId)
        for k, v in pairs(acTaskData) do
            if tonumber(k) == acId then
                return true
            end
        end
        return false
    end

    local findacOpenInfoTableData = function(acId, inId)  --by wangyan 与表对应：acId->activity_id  inId->id
        for k, v in pairs(acOpenInfoTableData) do
            if inId then
                if tonumber(v.id) == tonumber(inId) then
                    local t = clone(v)
                    return true, t
                end
            else
                if tonumber(v.activity_id) == tonumber(acId) then
                    local t = clone(v)
                    return true, t
                end
            end
        end
        return false
    end

    local sortTask = function(t)
        table.sort(t, function(a, b)
            --[[
            if a.order ~= b.order then
                return a.order < b.order
            end
            ]]
            return a.id < b.id
        end)
    end

    for k, v in pairs(acTaskData) do
        repeat
            local t1, t2, t3 = {}, {}, {}
             -- 在dailyActivity表里是否存在
            local f, d = findacTableData(tonumber(k))
            if f then

                local f0, d0 = findacOpenInfoData(tonumber(k))
                if f0 then
                    if 1 ~= d0.ac_type then break end
                end
                -- 是否开启 activityOpen
                local f1, d1 = findacOpenInfoTableData(tonumber(k))
                if f1 then
                    if d1.level_limit then
                        local userLevel = self._userModel:getPlayerLevel()
                        if userLevel < d1.level_limit then break end
                    end
                    if d1.vip_limit then
                        local vipLevel = self._vipModel:getLevel()
                        if vipLevel < d1.vip_limit then break end
                    end
                end
                local t = clone(d)
                t.dirty = true
                t.redTag = false
                t.newTag = 1 ~= SystemUtils.loadAccountLocalData("ACTIVITY_" .. k)
                t.acType = 1
                t.uiType  = (f1 and d1) and d1.ui_type or 1
                t.taskList = {}
                t.openInfo = {}
                for k0, v0 in ipairs(v.taskList) do
                    repeat
                        -- 在dailyActivityTask
                        local f0, d0 = findacTaskTableData(tonumber(v0.id))
                        if f0 then
                            if d0.level then
                                local userLevel = self._userModel:getPlayerLevel()
                                if userLevel < d0.level then break end
                            end
                            if d0.vip then
                                local vipLevel = self._vipModel:getLevel()
                                if vipLevel < d0.vip then break end
                            end
                            local t0 = clone(d0)
                            t0.statusInfo = v0.statusInfo
                            if not t.redTag and 1 == t0.statusInfo.status then
                                t.redTag = true
                            end
                            t0.times = v0.times
                            if t.fixedorder then
                                table.insert(t1, t0)
                            else
                                if 1 == t0.statusInfo.status then
                                    table.insert(t1, t0)
                                elseif -1 == t0.statusInfo.status then
                                    table.insert(t2, t0)
                                else
                                    table.insert(t3, t0)
                                end
                            end
                        end
                    until true
                end
                --sortTask(t1)
                --sortTask(t2)
                --sortTask(t3)
                for i = 1, #t1 do
                    t.taskList[#t.taskList + 1] = t1[i]
                end

                for i = 1, #t2 do
                    t.taskList[#t.taskList + 1] = t2[i]
                end

                for i = 1, #t3 do
                    t.taskList[#t.taskList + 1] = t3[i]
                end

                local f1, d1 = findacOpenInfoData(t.id)
                if f1 then
                    table.merge(t.openInfo, d1)
                end

                table.insert(result, t)
            end
        until true
    end

    for _, v in ipairs(acShowList) do
        repeat
            if 2 == v.ac_type or 3 == v.ac_type or 4 == v.ac_type or 8 == v.ac_type or 10 == v.ac_type or 26 == v.ac_type 
                or 28 == v.ac_type
                or 29 == v.ac_type
                or 6 == v.ac_type
                or 31 == v.ac_type  --原生推广员 邀请豪礼（好友邀请）
            then
                -- 原生推广员 屏蔽游客
                if 31 == v.ac_type and sdkMgr:isGuest() then
                    break
                end
                local f, d = findacTableData(tonumber(v.activity_id))
                if f then
                    if GameStatic.appleExamine then
                        if 999 == v.activity_id 
                            or 99997 == v.activity_id 
                            or 99988 == v.activity_id 
                            or 99989 == v.activity_id then 
                            break 
                        end
                    end
                    local f1, d1 = findacOpenInfoTableData(tonumber(v.activity_id), tonumber(v._id))
                    if f1 then
                        if d1.level_limit then
                            local userLevel = self._userModel:getPlayerLevel()
                            if userLevel < d1.level_limit then break end
                        end
                        if d1.vip_limit then
                            local vipLevel = self._vipModel:getLevel()
                            if vipLevel < d1.vip_limit then break end
                        end
                    end
                    local t = clone(d)
                    t.dirty = true
                    t.redTag = false
                    t.newTag = 1 ~= SystemUtils.loadAccountLocalData("ACTIVITY_" .. v.activity_id)
                    if 101 == v.activity_id then
                        t.redTag = self._activityModel:isACERebateDateTip()
                    elseif 102 == v.activity_id then
                        t.redTag = self._activityModel:isACERechargeTip()
                    elseif 999 == v.activity_id then
                        t.redTag = self._modelMgr:getModel("ACShareGetGiftModel"):checkAcRedPoint()
                    elseif 99 == v.activity_id then
                        t.redTag = self._activityModel:isShareDataTip()
                    elseif 8002 == v.activity_id then
                        t.redTag = self._activityModel:isSingleRechargeCanGet(v.activity_id)
                    elseif 89991 == v.activity_id then
                        t.redTag = self._activityModel:isAcHeroDuelCanGet()
                    elseif 8008 == v.activity_id then
                        t.redTag = self._activityModel:isAcRmbCanGet(v.activity_id)
                    elseif 26 == v.ac_type then  --周礼包红点判断逻辑
                        t.redTag = self._activityModel:checkRedTag_Acid_107()
                    elseif 28 == v.ac_type then  --整点狂欢红点判断逻辑
                        t.redTag = self._lotterModel:isLotteryRed() or 1 ~= SystemUtils.loadAccountLocalData("ACTIVITY_" .. v.activity_id)                    
                    elseif 31 == v.ac_type then  --好友邀请红点判断逻辑
                        t.redTag = self._activityModel:isFriendInvitedRed()
                    end
                    t.acType = v.ac_type
                    t.uiType  = (f1 and d1) and d1.ui_type or 1
                    t.layer = nil
                    table.insert(result, t)
                end
            end
        until true
    end
    if not GameStatic.appleExamine then
        local f, d = findacTableData(100)
        if f then
            local t = clone(d)
            t.dirty = true
            t.redTag = self._activityModel:isMonthCardCandGet()
            t.newTag = 1 ~= SystemUtils.loadAccountLocalData("ACTIVITY_" .. t.id)
            t.acType = 100
            t.uiType  = 100
            t.layer = nil
            table.insert(result, t)
        end
    end

    local f, d = findacTableData(99999)
    if f then
        local t = clone(d)
        t.dirty = true
        t.redTag = self._activityModel:isPhysicalCandGet()
        t.newTag = false--1 ~= SystemUtils.loadAccountLocalData("ACTIVITY_" .. t.id)
        t.acType = 99999
        t.uiType  = 99999
        t.layer = nil
        table.insert(result, t)
    end

    --时间市场
    if self._activityModel:isShowOffLine() 
        or (self._activity and table.nums(self._activity) >0 and self._activity[self._uiIndex].id == 99998) then
        local f, d = findacTableData(99998)
        if f then
            local t = clone(d)
            t.dirty = true
            t.redTag = self._activityModel:checkRedTag_Acid_99998()
            t.newTag = false
            t.acType = 99998
            t.uiType  = 99998
            t.layer = nil
            table.insert(result, t)
        end
    end

    -- -- VIP周礼包
    -- if self._activityModel:isShowWeeklyGift()
    --     or (self._activity and table.nums(self._activity) >0 and self._activity[self._uiIndex].id == 107) then
    --     local f, d = findacTableData(107)
    --     if f then
    --         local t = clone(d)
    --         t.dirty = true
    --         t.redTag = self._activityModel:checkRedTag_Acid_107()
    --         t.newTag = false
    --         t.acType = 107
    --         t.uiType  = 107
    --         t.layer = nil
    --         table.insert(result, t)
    --     end
    -- end

    -- 元素分享
    if not GameStatic.appleExamine then
        for k, v in pairs(acShowList) do
            if 23 == tonumber(v.ac_type) then
                if (self._activity and table.nums(self._activity) > 0 and self._activity[self._uiIndex].id == v.activity_id)
                    or not self._activityModel:isElementAcGetAward(v.activity_id) then
                    -- dailyActivity
                    local f0,d0 = findacOpenInfoTableData(tonumber(v.activity_id))
                    local uitype = 1
                    if d0 then
                        uitype = d0.ui_type
                    end
                    local f, d = findacTableData(tonumber(v.activity_id))
                    if f then
                        local userLevel = self._userModel:getPlayerLevel()
                        local vipLevel = self._vipModel:getLevel()
                        if v.level_limit and v.vip_limit then
                            if vipLevel >= v.vip_limit and userLevel >= v.level_limit then                         
                                local t = clone(d)
                                t.dirty = true
                                t.newTag = false
                                t.redTag = false
                                t.acType = v.ac_type
                                t.uiType  = uitype or 1
                                t.layer = nil
                                table.insert(result, t)
                            end
                        end
                    end
                    break
                end
            end
        end
    end

    if self._commentGuideModel:isAcCommentShow() then
        local f, d = findacTableData(100000)
        if f then
            local t = clone(d)
            t.dirty = true
            t.redTag = self._commentGuideModel:isAcShowRed()
            t.newTag = false--1 ~= SystemUtils.loadAccountLocalData("ACTIVITY_" .. t.id)
            t.acType = 100000
            t.uiType  = 100000
            t.layer = nil
            table.insert(result, t)
        end
    end
  
    -- if not GameStatic.appleExamine then
    -- 圣徽周卡  ps:需要考虑活动关闭但是活动没过期的情况
    local runeCardData = self._userModel:getRuneCardData()
    local currTime = self._userModel:getCurServerTime()
    local expireTime = (runeCardData and runeCardData.expireTime) and runeCardData.expireTime or 0
    if SystemUtils["enableRuneCard"]() or expireTime > currTime then
        local f, d = findacTableData(108)
        if f then
            local t = clone(d)
            t.dirty = true
            t.redTag = self._activityModel:isRuneCardCandGet()
            t.newTag = 1 ~= SystemUtils.loadAccountLocalData("ACTIVITY_" .. t.id)
            t.acType = 108
            t.uiType  = 108
            t.layer = nil
            table.insert(result, t)
        end
    end
    -- end

    table.sort(result, function(a, b)
        if not a.order then 
            return false
        elseif not b.order then 
            return true 
        end
        return tonumber(a.order) < tonumber(b.order)
    end)

    --self:initTableViewFunction(result)
    --self:createTableViewFunction(result)

    -- dump(result,"result", 3)
    return result

    --[=[
    local result = {}
    local acTableData = tab.activity
    local acTaskTableData = tab.activitytask
    local acData = self._activityModel:getData()
    local acOpenInfo = self._activityModel:getOpenInfoData()

    --dump(acTableData, "acTableData", 5)
    --dump(acTaskTableData, "acTaskTableData", 5)
    --dump(acData, "acData", 5)
    --dump(acOpenInfo, "acOpenInfo", 5)
    --[[
    self._activity = {
        [1] = {
            acIndex = "1",
            id = 8001,
            title = "HUODONG1_8001",
            description = "HUODONG2_8001",
            taskList = {
                [1] = {
                    id = 130101,
                    times = 0,
                    type = 1,
                    condition = 1301,
                    statis = {
                        v1 = 0,
                        v2 = 6
                    }
                }
            }
        }
    }
    ]]
    local findacTableData = function(acId)
        for k, v in pairs(acTableData) do
            if v.id == acId then
                return true, v
            end
        end
        return false
    end

    local findacTaskTableData = function(acTaskId)
        for k, v in pairs(acTaskTableData) do
            if v.id == acTaskId then
                return true, v
            end
        end
        return false
    end

    local findacOpenInfoData = function(acIndex)
        for k, v in pairs(acOpenInfo) do
            if tonumber(k) == tonumber(acIndex) then
                local t = clone(v)
                t.acId = nil
                return true, t
            end
        end
        return false
    end

    local getTaskStatus = function(t)
        local isFinished, isGot = true, t.times > 0
        if t.statis then
            for i = 1, #t.condition_num do
                if t.statis["v" .. i] < t.condition_num[i] then
                    isFinished = false
                    break
                end
            end
        else
            isGot = t.finish_max and t.times >= t.finish_max or t.times > 0
            for i = 1, #t.exchange_num do
                local have, consume = 0, t.exchange_num[i][3]
                if "tool" == t.exchange_num[i][1] then
                    local _, toolNum = self._itemModel:getItemsById(t.exchange_num[i][2])
                    have = toolNum
                elseif "gold" == t.exchange_num[i][1] then
                    have = self._userModel:getData().gold
                elseif "gem" == t.exchange_num[i][1] then
                    have = self._userModel:getData().freeGem
                end
                if consume > have then
                    isFinished = false
                    break
                end
            end
        end
        if isFinished and not isGot then
            return 1
        elseif isFinished and isGot then
            return 0
        else
            return -1
        end
    end

    local sortTask = function(t)
        table.sort(t, function(a, b)
            if a.order ~= b.order then
                return a.order < b.order
            end
            return a.id < b.id
        end)
    end

    for k, v in pairs(acData) do
        local t1, t2, t3 = {}, {}, {}
        local f, d = findacTableData(tonumber(v.acId))
        if f then
            local t = clone(d)
            t.acIndex = k
            t.dirty = true
            t.tableView = nil
            t.taskList = {}
            t.openInfo = {}
            t.isClose = v.isClose
            for k0, v0 in pairs(v.acTaskList) do
                local f0, d0 = findacTaskTableData(tonumber(k0))
                local t0 = clone(d0)
                t0.status = -1
                t0.times = v0
                --table.merge(t0, v0)
                if v.acStatisList and v.acStatisList[tostring(d0.condition)] then
                    t0.statis = {}
                    table.merge(t0.statis, v.acStatisList[tostring(d0.condition)])
                end
                t0.status = getTaskStatus(t0)
                if 1 == t0.status then
                    table.insert(t1, t0)
                elseif -1 == t0.status then
                    table.insert(t2, t0)
                else
                    table.insert(t3, t0)
                end
            end
            sortTask(t1)
            sortTask(t2)
            sortTask(t3)
            for i = 1, #t1 do
                t.taskList[#t.taskList + 1] = t1[i]
            end

            for i = 1, #t2 do
                t.taskList[#t.taskList + 1] = t2[i]
            end

            for i = 1, #t3 do
                t.taskList[#t.taskList + 1] = t3[i]
            end

            local f1, d1 = findacOpenInfoData(t.acIndex)
            if f1 then
                table.merge(t.openInfo, d1)
            end

            table.insert(result, t)
        end
    end

    table.sort(result, function(a, b)
        return tonumber(a.acIndex) < tonumber(b.acIndex)
    end)

    dump(result, "result", 10)

    return result
    ]=]
end

function ActivityView:initTableViewFunction(activityData)
    --[[
    if not self._activity then return end

    local findTableView = function(activityId)
        for i=1, #self._activity do
            if self._activity[i].id == activityId then
                return self._activity[i].tableView
            end
        end
    end

    for i=1, #activityData do
        if 1 == activityData[i].acType then
            activityData[i].tableView = findTableView(activityData[i].id)
        end
    end
    ]]
end

function ActivityView:createTableViewFunction(activityData)
    --[[
    for i=1, #activityData do
        if 1 == activityData[i].acType then
            self["activityTaskNumberOfCellsInTableView" .. i] = function(self)
                if i ~= self._uiIndex then return 0 end
                return #activityData[i].taskList
            end
        end
    end
    ]]
end

function ActivityView:hasTaskCanGet(index)
    if not (self._activity and self._activity[index]) then return false end
    if ActivityView.kActivityType1 == self._activity[index].acType then
        if not self._activity[index].taskList then return false end
        for _, v in ipairs(self._activity[index].taskList) do
            if 1 == v.statusInfo.status then
                return true
            end
        end
        --[[
        if self._activity[index].redTag then
            return true
        end
        ]]
    else
        --[[
        if self._activity[index].redTag then
            return true
        end
        ]]
        if 101 == self._activity[index].id then
            return self._activityModel:isACERebateDateTip()
        elseif 102 == self._activity[index].id then
            return self._activityModel:isACERechargeTip()
        elseif 99 == self._activity[index].id then
            return self._activityModel:isShareDataTip()                    
        elseif 100 == self._activity[index].id then
            local isShowRed, isShowOnce = self._activityModel:isMonthCardCandGet()
            if self._uiIndex == index and not self._acChecked[self._activity[index].id] and isShowOnce then
                self._acChecked[self._activity[index].id] = true
                return false
            end
            return isShowRed
        elseif 108 == self._activity[index].id then
            return self._activityModel:isRuneCardCandGet()
        elseif 8 == self._activity[index].acType then
            return self._activityModel:isSingleRechargeCanGet(self._activity[index].id)
        elseif 8008 == self._activity[index].id then
            return self._activityModel:isAcRmbCanGet(self._activity[index].id)
        elseif 99999 == self._activity[index].id then
            return self._activityModel:isPhysicalCandGet()
        elseif 100000 == self._activity[index].id then
            if self._uiIndex == index and not self._acChecked[self._activity[index].id] then
                self._acChecked[self._activity[index].id] = true
                return false
            end
            return self._commentGuideModel:isAcShowRed()
        elseif 999 == self._activity[index].id then
            if self._uiIndex == index and not self._acChecked[self._activity[index].id] then
                self._acChecked[self._activity[index].id] = true
                return false
            end
            return self._modelMgr:getModel("ACShareGetGiftModel"):checkAcRedPoint()
        elseif 99998 == self._activity[index].id then
            return self._activityModel:checkRedTag_Acid_99998()
        elseif 12 == self._activity[index].uiType then
            return self._activityModel:checkRedTag_Acid_107()
        elseif 13 == self._activity[index].uiType then
            return self._lotterModel:isLotteryRed() or 1 ~= SystemUtils.loadAccountLocalData("ACTIVITY_" .. self._activity[index].id)
        elseif 16 == self._activity[index].uiType then
            return self._activityModel:isFriendInvitedRed()
        elseif 89991 == self._activity[index].id then
            return self._activityModel:isAcHeroDuelCanGet()
        end
    end   
    
    return false
end

function ActivityView:getRemainTimeAndTips()
    local currentTime = self._userModel:getCurServerTime()
    local isClose = 1 == self._activity[self._uiIndex].isClose
    local appearTime = self._activity[self._uiIndex].openInfo.appear_time
    local startTime = self._activity[self._uiIndex].openInfo.start_time
    local endTime = self._activity[self._uiIndex].openInfo.end_time
    local disappearTime = self._activity[self._uiIndex].openInfo.disappear_time
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

function ActivityView:updateTimeCountDown()
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

function ActivityView:startClock()
    self._timerDirty = true
    if self._timer_id then return end
    self._timer_id = self._scheduler:scheduleScriptFunc(handler(self, self.updateTimeCountDown), 1, false)
end

function ActivityView:endClock()
    if not self._timer_id then return end
    if self._timer_id then 
        self._scheduler:unscheduleScriptEntry(self._timer_id)
        self._timer_id = nil
        self._timerDirty = false
    end
end

function ActivityView:updateButtonStatus(buttonItem, isSelected)
    buttonItem:setEnabled(not isSelected)
    buttonItem:setBright(not isSelected)
    --local text = buttonItem:getChildByName("activityName")
    --text:setColor(isSelected and cc.c3b(255, 250, 220) or cc.c3b(80, 46, 10))
end

function ActivityView:switchButton()
    if not self._buttonTableView then return end
    if 0 ~= self._lastUIIndex then
        local cell = self._buttonTableView:cellAtIndex(self._lastUIIndex - 1)
        if cell then
            local buttonItem = cell:getChildByTag(self.kActivityButtonItemTag)
            if buttonItem then
                self:updateButtonStatus(buttonItem, false)
            end
        end
    end
    local cell = self._buttonTableView:cellAtIndex(self._uiIndex - 1)
    if cell then
        local buttonItem = cell:getChildByTag(self.kActivityButtonItemTag)
        if buttonItem then
            self:updateButtonStatus(buttonItem, true)
        end
    end
end

--[[
    是否强制重新创建layer
]]
function ActivityView:isForceSwitch(uiIndex)
    print("isForceSwitch",uiIndex,self._uiIndex)
    if not uiIndex or not self._uiIndex then return true end
    --dump(self._activity[uiIndex])
    if self._uiIndex == uiIndex then
        if self._activity[uiIndex] and self._activity[uiIndex].uiType == 12 then
            return false
        end
    end
    return true
end

function ActivityView:switchActivityById(activityId)
    local uiIndex = self:getActivityUIIndexById(activityId)
    self:switchActivity(uiIndex)
end

--[[
    进入layer后，手动更新页签上的红点
]]
function ActivityView:updateTabRed()
    local buttonCell = self._buttonTableView:cellAtIndex(self._uiIndex - 1)
    if buttonCell then
        local buttonItem = buttonCell:getChildByTag(self.kActivityButtonItemTag)
        if buttonItem then
            self:updatebuttonItem(buttonItem, self._uiIndex - 1)
        end
    end
end

function ActivityView:switchActivity(uiIndex, force)
    if not self:isForceSwitch(uiIndex) then
        return
    end
    print("switchActivity", uiIndex, force)
    if table.getn(self._activity) <= 0 then return end
    print(self._activity[uiIndex].dirty, force)
    if self._uiIndex == uiIndex and not self._activity[uiIndex].dirty and not force then return end
    print(self._activity[uiIndex].id)
    self._uiIndex = uiIndex
    -- 停止滚动, 避免报错
    if self._taskTableView then self._taskTableView:stopScroll() end
    --if not self._firstIn then
        SystemUtils.saveAccountLocalData("ACTIVITY_" .. self._activity[self._uiIndex].id, 1)
        self._activity[uiIndex].newTag = false
    --end

    --self._firstIn = false

    local buttonCell = self._buttonTableView:cellAtIndex(self._uiIndex - 1)
    if buttonCell then
        local buttonItem = buttonCell:getChildByTag(self.kActivityButtonItemTag)
        if buttonItem then
            self:updatebuttonItem(buttonItem, self._uiIndex - 1)
        end
        --[[
        local min, max = self._buttonTableView:minContainerOffset().y, self._buttonTableView:maxContainerOffset().y
        local n = table.getn(self._activity)
        if n > 1 then
            self._buttonTableView:setContentOffset(cc.p(0, (max - min) / (n - 1) * self._uiIndex + (n * min - max) / (n - 1)))
        end
        ]]
    end

    if ActivityView.kActivityType1 == self._activity[uiIndex].uiType then
        self._layerActivity1:setVisible(true)
        self._layerActivity2:setVisible(false)

        -- if self._activity[self._uiIndex].titlepic1 then
        --     self._imageActivityTitle:loadTexture(self._activity[self._uiIndex].titlepic1 .. ".png", 1)
        --     self._imageActivityTitle:setOpacity(0)
        -- end

        local activityD = self._activity[self._uiIndex]
        if activityD.titlepic2 then
            self._imageActivityBg:loadTexture(activityD.titlepic2 .. ".png", 1)
        end
        if activityD.title then 
            if self._imageActivityBg.title ~= activityD.title then
                self._imageActivityBg:removeAllChildren()
                local label = UIUtils:getActivityLabel(lang(activityD.title), 70)
                label:setPosition(10, 10)
                self._imageActivityBg:addChild(label)
                self._imageActivityBg.title = activityD.title
            end
        else
            self._imageActivityBg:removeAllChildren()
            self._imageActivityBg.title = nil
        end

        --[[
        self._activityTitle:setVisible(false)
        self._imageActivityTitle:setVisible(false)
        if self._activity[self._uiIndex].titlepic then
            self._activityTitle:setVisible(false)
            self._imageActivityTitle:setVisible(true)
            self._imageActivityTitle:loadTexture(self._activity[self._uiIndex].titlepic .. ".png", 1)
        elseif self._activity[self._uiIndex].title then
            self._activityTitle:setVisible(true)
            self._imageActivityTitle:setVisible(false)
            self._activityTitle:setString(lang(self._activity[self._uiIndex].title))
        end
        ]]
        self._activityDescription:setString(lang(self._activity[self._uiIndex].description))

        self:startClock()
        self:updateTimeCountDown()
        self:switchButton()
        self:changeActivityTaskTableView(force)
    else
        self:endClock()
        self._layerActivity1:setVisible(false)
        self._layerActivity2:setVisible(true)
        self:switchButton()
        self:changeActivityLayer()
    end
end

function ActivityView:updateActivityTaskItem(activityTaskItem, index)
    index = index + 1
    local taskData = self._activity[self._uiIndex].taskList[index] 
    local isHideConditionValue = taskData.statusInfo.isHideValue
    activityTaskItem:setContext({container = self, taskData = taskData, isHideConditionValue = isHideConditionValue})
    activityTaskItem:updateUI()
end

function ActivityView:updatebuttonItem(buttonItem, index)
    index = index + 1
    local text = buttonItem:getChildByName("activityName")
    if not text then
        text = ccui.Text:create(lang(self._activity[index].title), UIUtils.ttfName, 16)
        text:setColor(UIUtils.colorTable.ccUIBaseColor1)
        text:enableOutline(cc.c4b(60, 30, 10, 255), 2)
        text:setPosition(cc.p(buttonItem:getContentSize().width / 2 - 10, buttonItem:getContentSize().height / 4))
        text:setName("activityName")
        buttonItem:addChild(text, 10)
    else
        text:setString(lang(self._activity[index].title))
    end

    local image = buttonItem:getChildByName("activityImage")
    if not image then
        image = ccui.ImageView:create(self._activity[index].icon .. ".png", 1)
        image:setPosition(cc.p(buttonItem:getContentSize().width / 2 - 10, buttonItem:getContentSize().height / 2 + 10))
        image:setName("activityImage")
        buttonItem:addChild(image, 5)
    else
        image:loadTexture(self._activity[index].icon .. ".png", 1)
    end

    local acTag = buttonItem:getChildByFullName("image_tag_bg")
    acTag:setVisible(self._activity[index].tab and true or false)
    local acLabelTag = buttonItem:getChildByFullName("image_tag_bg.label_tag")
    acLabelTag:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    if self._activity[index].tab then
        local tagText = buttonItem:getChildByFullName("image_tag_bg.label_tag")
        tagText:setFontName(UIUtils.ttfName)
        tagText:setString(lang(string.format("activitytag_%02d", self._activity[index].tab)))
    end

    local redTag = buttonItem:getChildByName("activity_red_tag")
    redTag:setVisible(self:hasTaskCanGet(index))

    local acNewTag = buttonItem:getChildByFullName("image_new_tag_bg")
    acNewTag:setVisible(self._activity[index].newTag)
    local acLabelNewTag = buttonItem:getChildByFullName("image_new_tag_bg.label_tag")
    acLabelNewTag:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self:updateButtonStatus(buttonItem, index == self._uiIndex)
    --[[
    local btn = self._buttons[ActivityView.kuiIndexPrimaryLine]._btn
    local image_normal = self._buttons[ActivityView.kuiIndexPrimaryLine]._image_tab_normal
    local image_selected = self._buttons[ActivityView.kuiIndexPrimaryLine]._image_tab_selected
    btn:setEnabled(ActivityView.kuiIndexPrimaryLine ~= uiIndex)
    btn:setBright(ActivityView.kuiIndexPrimaryLine ~= uiIndex)
    image_normal:setVisible(ActivityView.kuiIndexPrimaryLine ~= uiIndex)
    image_selected:setVisible(ActivityView.kuiIndexPrimaryLine == uiIndex)

    local btn = self._buttons[ActivityView.kuiIndexEveryday]._btn
    btn:loadTexturePressed(SystemUtils:enableDailyTask() and "globalBtnUI4_page1_p2.png" or "globalBtnUI4_page1_n.png", 1)
    local image_normal = self._buttons[ActivityView.kuiIndexEveryday]._image_tab_normal
    local image_selected = self._buttons[ActivityView.kuiIndexEveryday]._image_tab_selected
    btn:setEnabled(ActivityView.kuiIndexEveryday ~= uiIndex)
    btn:setBright(ActivityView.kuiIndexEveryday ~= uiIndex)
    image_normal:setVisible(ActivityView.kuiIndexEveryday ~= uiIndex)
    image_selected:setVisible(ActivityView.kuiIndexEveryday == uiIndex)
    ]]
end

function ActivityView:changeActivityLayer()
    self._layerActivity2:removeChildByTag(ActivityView.kActivityLayerTag)
    local activityLayerInfo = {
        [1] = "activity.common.ActivityShowCommonLayer",
        [2] = "activity.ACShareGetGiftLayer",
        [3] = "activity.common.ActivityDisplayCommonLayer",
        [4] = "activity.common.ActivityShowCommonLayer",
        [6] = "activity.common.ActivityHtmlCommonLayer",
        [9] = "activity.common.ActivitySingleChargeLayer",
        [11] = "activity.common.ActivityElementShareLayer",
        [14] = "activity.common.ActivityHeroDuleLayer",             --交锋之王
        [100] = "activity.MonthCardLayer",
        [101] = "activity.common.ACEveryDayRebateLayer",    
        [102] = "activity.common.ACEveryDayRechargeLayer",
        [107] = "activity.common.AcDayRechargeLayer",
        [108] = "activity.common.AcRuneCardLayer",  -- 圣徽周卡
        [12] = "activity.common.VipWeekGiftLayer", --VIP周礼包
        [13] = "activity.common.ActivityLotteryLayer", --整点抽奖
        [16] = "activity.common.AcFriendsInvitedLayer", --好友邀请
        [17] = "activity.common.AcChristmasExchangeLayer", --好友邀请
        [99998] = "activity.common.ActivityResourcesRetrieveLayer",
        [999] = "activity.ACShareGetGiftLayer",
        [99999] = "activity.ACSupplyPhysicalPower",             --体领取体力
        [100000] = "activity.ACCommentGuideLayer",
    }

    local layerName = activityLayerInfo[self._activity[self._uiIndex].uiType]
    if not layerName and (3 == self._activity[self._uiIndex].uiType or 4 == self._activity[self._uiIndex].uiType) then
        layerName = "activity.common.ActivityShowCommonLayer"
    end

    print("=====================ActivityView===layerName", layerName)
    self._viewMgr:lock(1)
    if not trycall("changeActivityLayer", function ()
        self:createLayer(layerName, {activityId = self._activity[self._uiIndex].id, container = self}, true, function (_layer)
            self._viewMgr:unlock()
            self._activity[self._uiIndex].layer = _layer
            self._activity[self._uiIndex].dirty = false
            --self._activity[self._uiIndex].layer:setPosition(0)
            self._activity[self._uiIndex].layer:setName("layer" .. self._uiIndex)
            self._activity[self._uiIndex].layer:setTag(ActivityView.kActivityLayerTag)
            self._layerActivity2:addChild(self._activity[self._uiIndex].layer)
        end)
        self._lastUIIndex = self._uiIndex
    end) then
        self._viewMgr:unlock()
    end
end
--[[
function ActivityView:_changeActivityLayer()
    self._layerActivity2:removeChildByTag(ActivityView.kActivityLayerTag)
    local activityLayerInfo = {
        [101] = "activity.common.ACEveryDayRebateLayer",
        [102] = "activity.common.ACEveryDayRechargeLayer",
        [100] = "activity.MonthCardLayer",
        [99] = "activity.common.ActivityShareView",
        [99999] = "activity.ACSupplyPhysicalPower",             --体领取体力
        [2003] = "activity.common.ActivitySingleChargeLayer",
        [100000] = "activity.ACCommentGuideLayer",
        [999] = "activity.ACShareGetGiftLayer"
    }
    local acType = self._activity[self._uiIndex].acType
    -- 展板 只有一张图
    for id = 20000, 22000 do
        activityLayerInfo[id] = "activity.common.ActivityDisplayCommonLayer"
    end
    -- 展板  图加文字
    for id = 22001, 24000 do
        activityLayerInfo[id] = "activity.common.ActivityShowCommonLayer"
    end

    for id = 25000, 25500 do
        activityLayerInfo[id] = "activity.common.ActivityAcRmbLayer"
    end

    local layerName = activityLayerInfo[self._activity[self._uiIndex].id]
    if not layerName and (3 == self._activity[self._uiIndex].acType or 4 == self._activity[self._uiIndex].acType) then
        layerName = "activity.common.ActivityShowCommonLayer"
    end

    if not layerName and 10 == self._activity[self._uiIndex].acType then
        layerName = "activity.common.ActivityAcRmbLayer"
    end

    self._viewMgr:lock(1)
    if not trycall("changeActivityLayer", function ()
        self:createLayer(layerName, {activityId = self._activity[self._uiIndex].id, container = self}, true, function (_layer)
            self._viewMgr:unlock()
            self._activity[self._uiIndex].layer = _layer
            self._activity[self._uiIndex].dirty = false
            --self._activity[self._uiIndex].layer:setPosition(0)
            self._activity[self._uiIndex].layer:setName("layer" .. self._uiIndex)
            self._activity[self._uiIndex].layer:setTag(ActivityView.kActivityLayerTag)
            self._layerActivity2:addChild(self._activity[self._uiIndex].layer)
        end)
        self._lastUIIndex = self._uiIndex
    end) then
        self._viewMgr:unlock()
    end
end
]]
function ActivityView:changeActivityTaskTableView(force)
    local isFirstCreate = false
    if not self._taskTableView then
        self._taskTableView = cc.TableView:create(self._layerTaskList:getContentSize())
        self._taskTableView:setDelegate()
        self._taskTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self._taskTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self._taskTableView:setAnchorPoint(cc.p(0, 0))
        self._taskTableView:setPosition(cc.p(0, 0))
        --self._taskTableView:setBounceable(false)
        self._layerTaskList:addChild(self._taskTableView, self.kAboveNormalZOrder)
        self._taskTableView:registerScriptHandler(handler(self, self.activityTaskTableViewCellTouched), cc.TABLECELL_TOUCHED)
        self._taskTableView:registerScriptHandler(handler(self, self.activityTaskTableViewCellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
        self._taskTableView:registerScriptHandler(handler(self, self.activityTaskTableViewCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
        self._taskTableView:registerScriptHandler(handler(self, self.activityTaskNumberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        isFirstCreate = true
    end

    -- 在同一界面领取奖励后数据刷新但tableView偏移量位置保持不变
    local preContentOffset = nil 
    if force and self._lastUIIndex == self._uiIndex then
        preContentOffset = cc.p(self._taskTableView:getContentOffset())
    end 
    self._taskTableView:reloadData()

    if not isFirstCreate and preContentOffset then
        self._taskTableView:setContentOffset(preContentOffset)
    end 

    self._activity[self._uiIndex].dirty = false
    self._lastUIIndex = self._uiIndex
end

function ActivityView:activityTaskTableViewCellTouched(tableView, cell)
end

function ActivityView:activityTaskTableViewCellSizeForTable(tableView, idx)
    return ActivityTaskItemView.kItemContentSize.height + 10, ActivityTaskItemView.kItemContentSize.width
    -- activity optimize
    --return ActivityTaskItemView1.kItemContentSize.height + 10, ActivityTaskItemView1.kItemContentSize.width
end

function ActivityView:activityTaskTableViewCellAtIndex(tableView, idx)
    local cell = tableView:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
        local taskData = self._activity[self._uiIndex].taskList[idx+1]
        local activityItemName = "activity.ActivityTaskItemView"
        local isHideConditionValue = taskData.statusInfo.isHideValue 
        local activityTaskItemView = self._viewMgr:createLayer(activityItemName, {container = self, taskData = taskData, isHideConditionValue = isHideConditionValue}) -- hard code fixed me
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
    --[[ activity optimize
    local cell = tableView:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
        local taskData = self._activity[self._uiIndex].taskList[idx+1]
        local activityItemName = "activity.ActivityTaskItemView" .. taskData.uitype
        local activityTaskItemView = self._viewMgr:createLayer(activityItemName, {container = self, taskData = taskData})
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
    ]]
end

function ActivityView:activityTaskNumberOfCellsInTableView(tableView)
    if not (self._activity[self._uiIndex].taskList and type(self._activity[self._uiIndex].taskList)  == "table") then return 0 end
    return #self._activity[self._uiIndex].taskList
end

function ActivityView:refreshButtonTableView()
    self:destroyButtonTableView()
    self:createButtonTableView()
end

function ActivityView:destroyButtonTableView()
    if not self._buttonTableView then return end
    self._buttonTableViewOffset = self._buttonTableView:getContentOffset()
    self._buttonTableView:removeFromParentAndCleanup()
    self._buttonTableView = nil
end

function ActivityView:createButtonTableView()
    if self._buttonTableView then return end
    self._buttonTableView = cc.TableView:create(cc.size(self._layerButtonList:getContentSize().width + 20, self._layerButtonList:getContentSize().height))
    self._buttonTableView:setDelegate()
    self._buttonTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._buttonTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._buttonTableView:setAnchorPoint(cc.p(0, 0))
    self._buttonTableView:setPosition(cc.p(0, 0))
    self._buttonTableView:setBounceable(false)
    self._layerButtonList:addChild(self._buttonTableView, self.kAboveNormalZOrder)
    self._buttonTableView:registerScriptHandler(handler(self, self.buttonTableViewCellTouched), cc.TABLECELL_TOUCHED)
    self._buttonTableView:registerScriptHandler(handler(self, self.buttonTableViewCellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._buttonTableView:registerScriptHandler(handler(self, self.buttonTableViewCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._buttonTableView:registerScriptHandler(handler(self, self.numberOfCellsInButtonTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._buttonTableView:reloadData()
    if self._buttonTableViewOffset then
        local minOffset = self._buttonTableView:minContainerOffset().y
        local maxOffset = self._buttonTableView:maxContainerOffset().y
        self._buttonTableViewOffset.y = math.min(math.max(self._buttonTableViewOffset.y, minOffset), maxOffset)
        self._buttonTableView:setContentOffset(self._buttonTableViewOffset)
        self._buttonTableViewOffset = nil
    end
end

function ActivityView:buttonTableViewCellTouched(tableView, cell)
    audioMgr:playSound("Tab")
    local index = cell:getIdx() + 1
    self:switchActivity(index)
end

function ActivityView:buttonTableViewCellSizeForTable(tableView, idx)
    return self._activityButton:getContentSize().height - 13, self._activityButton:getContentSize().width
end

function ActivityView:buttonTableViewCellAtIndex(tableView, idx)
    local cell = tableView:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
        local buttonItem = self._activityButton:clone()
        buttonItem:setTouchEnabled(false)
        buttonItem:setVisible(true)
        buttonItem:setPosition(cc.p(self._activityButton:getContentSize().width / 2, self._activityButton:getContentSize().height / 2 - 13))
        buttonItem:setTag(self.kActivityButtonItemTag)
        self:updatebuttonItem(buttonItem, idx)
        cell:addChild(buttonItem)
    else
        local buttonItem = cell:getChildByTag(self.kActivityButtonItemTag)
        self:updatebuttonItem(buttonItem, idx)
    end
    return cell
end

function ActivityView:numberOfCellsInButtonTableView(tableView)
    return #self._activity
end

function ActivityView:onButtonGoClicked(taskData)
    --print("onButtonGoClicked", taskData.id, taskData.button)
    if self["goView" .. taskData.button] then
        self["goView" .. taskData.button](self)
    end
end

function ActivityView:goView1() self._viewMgr:showView("intance.IntanceView", {superiorType = 1}) end
function ActivityView:goView2() self._viewMgr:showView("vip.VipView", {viewType = 0}) end
function ActivityView:goView3()
    if not SystemUtils:enableElite() then
        self._viewMgr:showTip(lang("TIP_JINGYING_1"))
        return 
    end
    self._viewMgr:showView("intance.IntanceEliteView", {superiorType = 1}) 
end
function ActivityView:goView4() 
    if not SystemUtils:enableDwarvenTreasury() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("pve.AiRenMuWuView") 
end
function ActivityView:goView5() 
    if not SystemUtils:enableCrypt() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("pve.ZombieView") 
end
function ActivityView:goView6() 
    if not SystemUtils:enableBoss() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("pve.DragonView") 
end
function ActivityView:goView7() self._viewMgr:showView("team.TeamListView") end
function ActivityView:goView8() self._viewMgr:showView("flashcard.FlashCardView") end
function ActivityView:goView9() 
    if not SystemUtils:enableArena() then
        self._viewMgr:showTip(lang("TIP_Arena"))
        return 
    end
    self._viewMgr:showView("arena.ArenaView") 
end
function ActivityView:goView10() 
    if not SystemUtils:enableCrusade() then
        self._viewMgr:showTip(lang("TIP_Crusade"))
        return 
    end
    self._viewMgr:showView("crusade.CrusadeView") 
end
function ActivityView:goView11() DialogUtils.showBuyRes({goalType = "gold", callback = function(success)
    --if success then self._layer_task_everyday._scrollView:scrollToTop(1, true) end
end}) end
function ActivityView:goView12() DialogUtils.showBuyRes({goalType = "physcal", callback = function(success)
    --if success then self._layer_task_everyday._scrollView:scrollToTop(1, true) end
end}) end
function ActivityView:goView13()
    if self._uiIndex == self:getActivityUIIndexById(101) then
        self._viewMgr:showView("shop.ShopView",{idx = 6})
        -- self._viewMgr:showTip(lang("tips_zhaomuyouli"))
        return
    end
    self:switchActivityById(101)
end
function ActivityView:goView14() DialogUtils.showBuyRes({goalType = "gem", callback = function(success)
    --if success then self._layer_task_everyday._scrollView:scrollToTop(1, true) end
end}) end
function ActivityView:goView15() DialogUtils.showBuyRes({goalType = "gem", callback = function(success)
    --if success then self._layer_task_everyday._scrollView:scrollToTop(1, true) end
end}) end
function ActivityView:goView16() 
    if self._modelMgr:getModel("ActivityCarnivalModel"):carnivalIsOpen() then
        self._viewMgr:showDialog("activity.ActivityCarnival", {}, true)
    else
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
    end
end

function ActivityView:goView17() 
    local showday, _ = self._modelMgr:getModel("ActivitySevenDaysModel"):getShowDayAndState()
    if SystemUtils:enableSevenDay() and showday > 0  then
        self._viewMgr:showDialog("activity.ActivitySevenDaysView", {})
    else
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
    end
end

function ActivityView:goView18() 
    if not SystemUtils:enableGuild() then
        self._viewMgr:showTip(lang("TIP_Guild"))
        return 
    end
    local userData = self._userModel:getData()
    if not userData.guildId or userData.guildId == 0 then
        self._viewMgr:showView("guild.join.GuildInView")
    else
        self._viewMgr:showView("guild.GuildView")
    end
end

function ActivityView:goView19() 
    if not SystemUtils:enableTreasure() then
        self._viewMgr:showTip(lang("TIP_Treasure"))
        return 
    end

    self._viewMgr:showView("treasure.TreasureShopView")
end

function ActivityView:goView20() 
    if not SystemUtils:enableTeam() then
        self._viewMgr:showTip(lang("TIP_TEAM"))
        return 
    end

    self._viewMgr:showView("team.TeamListView")
end

function ActivityView:goView21() 
    if not SystemUtils:enableHero() then
        self._viewMgr:showTip(lang("TIP_HERO"))
        return 
    end

    self._viewMgr:showView("hero.HeroView")
end
--[[
function ActivityView:goView22() 
    if not SystemUtils:enableMF() then
        self._viewMgr:showTip(lang("TIP_MF"))
        return 
    end

    self._viewMgr:showView("MF.MFView")
end

function ActivityView:goView23() 
    if not SystemUtils:enableCloudCity() then
        self._viewMgr:showTip(lang("TIP_TOWER"))
        return 
    end

    self._viewMgr:showView("cloudcity.CloudCityView")
end

function ActivityView:goView24()
    local isOpen,openDes = LeagueUtils:isLeagueOpen()
    if not isOpen then
        self._viewMgr:showTip(openDes)
        return
    end
    self._viewMgr:showView("league.LeagueView")
end

]]

function ActivityView:goView25()
    if not SystemUtils:enablePokedex() then
        self._viewMgr:showTip(lang("TIP_Pokedex"))
        return 
    end

    self._viewMgr:showView("pokedex.PokedexView")
end

function ActivityView:goView26()
    if not SystemUtils:enableTeam() then
        self._viewMgr:showTip(lang("TIP_TEAM"))
        return 
    end

    -- self._viewMgr:showView("team.TeamListView")
    DialogUtils.showBuyRes({goalType = "texp", callback = function(success)
        --if success then self._layer_task_everyday._scrollView:scrollToTop(1, true) end
    end})
end

--[[
function ActivityView:goView27()
    self._viewMgr:showDialog("tencentprivilege.TencentPrivilegeView")
end
]]

-- [[
function ActivityView:goView28()
    local isOpen,openDes = LeagueUtils:isLeagueOpen()
    if isOpen then
        self._viewMgr:showView("league.LeagueView")
    else
        self._viewMgr:showTip(openDes)
        --todo
    end
end
--]]

function ActivityView:goView29()
    if not SystemUtils:enableTreasure() then
        self._viewMgr:showTip(lang("TIP_Treasure"))
        return 
    end

    self._viewMgr:showView("treasure.TreasureView")
end

function ActivityView:goView30()
    if not SystemUtils:enableNests() then
        self._viewMgr:showTip(lang("TIP_Nests"))
        return 
    end

    self._viewMgr:showView("nests.NestsView")
end

function ActivityView:goView31()
    local userInfo = self._userModel:getData()  
    local _,_,level = SystemUtils:enableTraining()
    if userInfo.lvl < level then
        self._viewMgr:showTip("请先将等级提升到"..level.."级")
    else
        self._viewMgr:showView("training.TrainingView")
    end
end

function ActivityView:goView32()
    if not self._weaponsModel then 
        self._weaponsModel = self._modelMgr:getModel("WeaponsModel")
    end
    local weaponsModel = self._weaponsModel
    local state = weaponsModel:getWeaponState()
    if state == 1 then
        self._viewMgr:showTip(lang("TIP_Weapon"))
    elseif state == 2 then
        self._viewMgr:showTip(lang("TIP_Weapon2"))
    elseif state == 3 then
        self._viewMgr:showTip(lang("TIP_Weapon3"))
    elseif state == 4 then
        local tdata = weaponsModel:getWeaponsDataByType(1)
        if tdata then
            self._viewMgr:showView("weapons.WeaponsView", {})
        else
            self._serverMgr:sendMsg("WeaponServer", "getWeaponInfo", {}, true, {}, function(result)
                self._viewMgr:showView("weapons.WeaponsView", {})
            end)
        end
    end
end


--[[
function ActivityView:goView31()
    if not SystemUtils:enableElement() then
        self._viewMgr:showTip(lang("TIP_elementalPlane"))
        return 
    end

    self._viewMgr:showView("elemental.ElementalView")
end
]]
function ActivityView:showRewardDialog(taskData)
    local reward = taskData.reward
    local notChange = false
    for k,v in pairs(reward) do
        if v[1] == "avatarFrame" or v["type"] == "avatarFrame" 
            or v[1] == "avatar" or v["type"] == "avatar" then
            notChange = true
        end
    end
    if notChange and table.nums(reward) == 1 then
        DialogUtils.showAvatarFrameGet( {gifts = reward}) 
    else
        DialogUtils.showGiftGet( {gifts = reward})
    end
end

function ActivityView:onButtonGetClicked(taskData)
    print("onButtonGetClicked")

    if 1 ~= taskData.statusInfo.status then
        if 2 == taskData.uitype or 3 == taskData.uitype or 7 == taskData.uitype then
            if taskData.statusInfo.premiseCondition == 0 then
                --0表示前提条件不满足 提示替换
                self._viewMgr:showTip(lang("PREMISECONDITION_1"))
            else
                self._viewMgr:showTip(lang("acexchange_tip"))
            end
        else
            self._viewMgr:showTip(lang("TIP_TASK_RECIEVE"))
        end
        return
    end


    local doGet = function(selectedIndex)
        local context = { acId = self._activity[self._uiIndex].id, taskId = taskData.id, cId = selectedIndex}
        self._serverMgr:sendMsg("ActivityServer", "getTaskAcReward", context, true, {}, function(success, data)
            if not success then return end
            self:showRewardDialog(data)
            --self._activity = self:initActivityData()
            --self:refreshButtonTableView()
            --self:switchActivity(self._uiIndex, true)
        end)
    end

    if taskData.confirm and taskData.exchange_num and taskData.reward then
        local consumeData = clone(taskData.exchange_num)
        local rewardData = clone(taskData.reward)
        local data = {}
        data.activityCallBack = doGet
        data.shopBuyType = rewardData[1][1]
        data.itemId = rewardData[1][2]
        data.num = rewardData[1][3]
        data.costType = consumeData[1][1]
        data.costItemId = consumeData[1][2]
        data.costNum = consumeData[1][3]
        self._viewMgr:showDialog("shop.DialogShopBuy", data, true)
    elseif 5 == taskData.uitype then
        self._viewMgr:showDialog("global.GlobalSelectAwardDialog", {gift = taskData.reward or {}, callback = function(selectedIndex)
            if not selectedIndex then return end
            doGet(selectedIndex)
        end})
    elseif taskData.exchange_num and taskData.finish_max >= 6 then
        self._viewMgr:showDialog("activity.ActivityBatchExchangeView",{activityId = self._activity[self._uiIndex].id, taskData = clone(taskData), useThreshold = "one"}, true)
    else
        doGet()
    end

    --[[
    local context = { taskId = taskData.id }
    if taskData.type == ActivityView.kuiIndexPrimaryLine then
        self._serverMgr:sendMsg("TaskServer", "mainTaskReward", context, true, {}, function(success)
            if not success then return end
            self:showRewardDialog(taskData)
            self._activity = self:initActivityData()
            self._primaryLineDirty = true
            self:updateUI(self.kuiIndexPrimaryLine)
        end)
    elseif taskData.type == ActivityView.kuiIndexEveryday then
        self._serverMgr:sendMsg("TaskServer", "detailTaskReward", context, true, {}, function(success, resultData)
            if not success then return end
            self:showRewardDialog(taskData, resultData)
            self._activity = self:initActivityData()
            self._everyDayDirty = true
            self:updateUI(self.kuiIndexEveryday)
        end)
    end
    ]]
end

-- 刷新体力领取界面 hgf
function ActivityView:reflashPhysicalUI()
    local layerIdx = self:getActivityUIIndexById(99999)
    
    if self._activity and self._activity[layerIdx] and self._activity[layerIdx].layer and self._activity[layerIdx].layer.reflashUI then
        self._activity[layerIdx].layer:reflashUI()
    end
end

function ActivityView:reflashRebateUI()
    local layerIdx = self:getActivityUIIndexById(101)
    
    if self._activity and self._activity[layerIdx] and self._activity[layerIdx].layer and self._activity[layerIdx].layer.reflashUI then
        self._activity[layerIdx].layer:reflashUI()
    end
end

-- 整点抽奖
function ActivityView:reflashLotteryUI()
    local layerIdx = self:getActivityUIIndexByType(28)
    if self._activity and self._activity[layerIdx] and self._activity[layerIdx].layer and self._activity[layerIdx].layer.reflashCD then
        self._activity[layerIdx].layer:reflashCD()
    end
end

-- 圣徽抽卡
function ActivityView:reflashRuneCardUI()
    local layerIdx = self:getActivityUIIndexByType(108)
    if self._activity and self._activity[layerIdx] and self._activity[layerIdx].layer and self._activity[layerIdx].layer.updateInfoPanel then
        self._activity[layerIdx].layer:updateInfoPanel()
    end
end
return ActivityView