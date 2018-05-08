--[[
    Filename:    TaskView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-09-09 15:05:55
    Description: File description
--]]

local TaskItemView = require("game.view.task.TaskItemView")

local TaskView = class("TaskView", BaseView)

TaskView.kViewTypePrimaryLine = TaskItemView.kViewTypeItemPrimary
TaskView.kViewTypeEveryday = TaskItemView.kViewTypeItemEveryday
TaskView.kViewTypeAwaking = 1000

TaskView.kStatusCannot = 0
TaskView.kStatusAvailable = 1
TaskView.kStatusAlready = -1

TaskView.kNormalZOrder = 500
TaskView.kLessNormalZOrder = TaskView.kNormalZOrder - 1
TaskView.kAboveNormalZOrder = TaskView.kNormalZOrder + 1
TaskView.kHighestZOrder = TaskView.kAboveNormalZOrder + 1

TaskView.kTaskItemTag = 1000 

TaskView.kSuperiorTypeNormal = 1
TaskView.kSuperiorTypePrivileges = 2
TaskView.kSuperiorTypeAdventure = 3

function TaskView:ctor(params)
    TaskView.super.ctor(self)
    self.initAnimType = 3
    params = params or {}
    self._viewType = params.viewType
    self._isMainIn = params.isMainIn or false  --是否是主界面进入
    self._superiorType = params.superiorType or TaskView.kSuperiorTypeNormal
    self._taskModel = self._modelMgr:getModel("TaskModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._privilegesModel = self._modelMgr:getModel("PrivilegesModel")
    self._awakingModel = self._modelMgr:getModel("AwakingModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._siegeModel = self._modelMgr:getModel("SiegeModel")
    self._acModel = self._modelMgr:getModel("ActivityModel")
end

function TaskView:getAsyncRes()
    return 
        {
            {"asset/ui/task.plist", "asset/ui/task.png"},
            {"asset/ui/task1.plist", "asset/ui/task1.png"}
        }
end

function TaskView:getBgName()
    return "bg_007.jpg"
end

function TaskView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{title = "globalTitleUI_task.png",titleTxt = "任务", callback = function()
        SystemUtils.saveAccountLocalData("LAST_TASK_TAG", self._viewType)
    end})
end

function TaskView:disableTextEffect(element)
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

function TaskView:onInit()
    self:addAnimBg()
    self:disableTextEffect()
    self._layerItem = self:getUI("layer_item")
    -- 活动额外掉落  by hgf 17.12.15
    self._acAwards = self._acModel:getDailyTaskAward()
    -- 第一次进入任务界面（主界面进入）
    if not self._isMainIn then
        self._isFirstIn = true
    else        
        self._isFirstIn = self._taskModel:getTaskUIStatus()        
    end

    self._tasks = {}
    self._tasks._tableData = tab.task
    self._tasks._tableGrowAwardData = tab.growAward
    self._tasks._tableActiveAwardData = tab.activeAward
    self._primaryLineDirty = true
    self._everyDayDirty = true
    self._awakingDirty = true

    self._tableViews = {}
    self._tableViewOffset = {}
    self._layerTaskList = {}
    self._layerTaskList[TaskView.kViewTypePrimaryLine] = self:getUI("bg.task_bg.layer_task_primary_line.layer_task_list")
    self._layerTaskList[TaskView.kViewTypeEveryday] = self:getUI("bg.task_bg.layer_task_everyday.layer_task_list")

    self._buttons = {}
    self._buttons[TaskView.kViewTypePrimaryLine] = {}
    self._buttons[TaskView.kViewTypePrimaryLine]._btn = self:getUI("bg.task_bg.btn_primary_line")
    --self._buttons[TaskView.kViewTypePrimaryLine]._btn:setTitleFontName(UIUtils.ttfName)
    -- self._buttons[TaskView.kViewTypePrimaryLine]._btn:setTitleFontSize(32)    
    self._buttons[TaskView.kViewTypePrimaryLine]._red_tag = self:getUI("bg.task_bg.btn_primary_line.task_red_tag")

    self._buttons[TaskView.kViewTypeEveryday] = {}
    self._buttons[TaskView.kViewTypeEveryday]._btn = self:getUI("bg.task_bg.btn_everyday")
    --self._buttons[TaskView.kViewTypeEveryday]._btn:setTitleFontName(UIUtils.ttfName)
    -- self._buttons[TaskView.kViewTypeEveryday]._btn:setTitleFontSize(32)
    self._buttons[TaskView.kViewTypeEveryday]._red_tag = self:getUI("bg.task_bg.btn_everyday.task_red_tag")

    self._buttons[TaskView.kViewTypeAwaking] = {}
    self._buttons[TaskView.kViewTypeAwaking]._btn = self:getUI("bg.task_bg.btn_awaking")
    self._buttons[TaskView.kViewTypeAwaking]._btn.tabAnimImgName = "btn_awaking_p_task.png"
    --self._buttons[TaskView.kViewTypeAwaking]._btn:setTitleFontName(UIUtils.ttfName)
    -- self._buttons[TaskView.kViewTypeAwaking]._btn:setTitleFontSize(32)
    self._buttons[TaskView.kViewTypeAwaking]._red_tag = self:getUI("bg.task_bg.btn_awaking.task_red_tag")
    
    -- [[ 板子动画
    self._playAnimBg = self:getUI("bg.task_bg")
    self._playAnimBgOffX = 42
    self._playAnimBgOffY = -26
    self._animBtns = {self:getUI("bg.task_bg.btn_primary_line"),self:getUI("bg.task_bg.btn_everyday")}
    --]]
    --[[
    ScheduleMgr:delayCall(0, self, function()
         --按钮上 字体的位置
        local TitleText = self._buttons[TaskView.kViewTypePrimaryLine]._btn:getTitleRenderer()
        TitleText:setPositionX(self:getCurrentTag() == TaskView.kViewTypePrimaryLine and 85 or 65) 
        local TitleText1 = self._buttons[TaskView.kViewTypeEveryday]._btn:getTitleRenderer()
        TitleText1:setPositionX(self:getCurrentTag() == TaskView.kViewTypeEveryday and 85 or 65)
    end)
    ]]

    self._task_primary_line = {} 
    self._task_primary_line._layer = self:getUI("bg.task_bg.layer_task_primary_line")
    --self._task_primary_line._scrollView = self:getUI("bg.task_bg.layer_task_primary_line.scrollview")
    self._task_primary_line._progressBar = self:getUI("bg.task_bg.layer_task_primary_line.task_primary_line_progress_bar_bg.task_active_progress_bar")
    

    -- 给进度条增加遮罩  后来改为进度条 没用了 
    -- local clipNode = cc.ClippingNode:create()
    -- clipNode:setInverted(false)
    -- clipNode:setName("primaryClipNode")
    -- local mask = cc.Sprite:createWithSpriteFrameName("task_active_value_progress_mask.png")
    -- mask:setPositionX(120)
    -- mask:setScale(1.24)
    -- clipNode:setStencil(mask)
    -- clipNode:setAlphaThreshold(0.05)
    -- self._task_primary_line._progressBar:getParent():addChild(clipNode)
    -- clipNode:setPositionX(self._task_primary_line._progressBar:getPositionX()) 
    -- clipNode:setPositionY(self._task_primary_line._progressBar:getPositionY()) 
    -- self._task_primary_line._progressBar:retain()
    -- self._task_primary_line._progressBar:removeFromParent()
    -- clipNode:addChild(self._task_primary_line._progressBar)
    -- self._task_primary_line._progressBar._clipNode = clipNode 
    -- self._task_primary_line._progressBar:release()
    -- self._task_primary_line._progressBar:setPosition(-280, 0)

    self._task_primary_line._taskGrowRewardId = 1
    self._task_primary_line._taskReward = self:getUI("bg.task_bg.layer_task_primary_line.task_primary_line_progress_bar_bg.task_reward")
    self:registerClickEvent(self._task_primary_line._taskReward, function ()
        self:onPrimaryLineRewardClicked(TaskView.kStatusCannot)
    end)
    self._task_primary_line._taskRewardSelected = self:getUI("bg.task_bg.layer_task_primary_line.task_primary_line_progress_bar_bg.task_reward_s")
    self:registerClickEvent(self._task_primary_line._taskRewardSelected, function ()
        self:onPrimaryLineRewardClicked(TaskView.kStatusAvailable)
    end)
    self._task_primary_line._taskRewardSelectedMC = mcMgr:createViewMC("baoxiangguang1_baoxiang", true)
    self._task_primary_line._taskRewardSelectedMC:setVisible(false)
    self._task_primary_line._taskRewardSelectedMC:setPlaySpeed(1, true)
    self._task_primary_line._taskRewardSelectedMC:setPosition(self._task_primary_line._taskRewardSelected:getPosition())
    self._task_primary_line._taskRewardSelected:getParent():addChild(self._task_primary_line._taskRewardSelectedMC, 110)
    --[[
    self._task_primary_line._taskRewardSelected:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.ScaleTo:create(0.1, 0.7, 0.77),
        cc.ScaleTo:create(0.07, 0.7, 0.63),
        cc.Spawn:create(cc.ScaleTo:create(0.2, 0.7, 0.77), cc.MoveBy:create(0.2, cc.p(0, 3))),
        cc.Spawn:create(cc.ScaleTo:create(0.2, 0.7, 0.7), cc.MoveBy:create(0.2, cc.p(0, -3)))
    )))
    ]]

    self._task_primary_line._taskRewardSelectedMC1 = mcMgr:createViewMC("baoxiang3_baoxiang", true)
    self._task_primary_line._taskRewardSelectedMC1:setVisible(false)
    self._task_primary_line._taskRewardSelectedMC1:setPlaySpeed(1, true)
    self._task_primary_line._taskRewardSelectedMC1:setPosition(self._task_primary_line._taskRewardSelected:getPosition())
    self._task_primary_line._taskRewardSelected:getParent():addChild(self._task_primary_line._taskRewardSelectedMC1, 109)
    
    self._task_primary_line._taskRewardFinished = self:getUI("bg.task_bg.layer_task_primary_line.task_primary_line_progress_bar_bg.task_reward_f")
    self:registerClickEvent(self._task_primary_line._taskRewardFinished, function ()
        self:onPrimaryLineRewardClicked(TaskView.kStatusAlready)
    end)
    self._task_primary_line._labelGrowupValue = self:getUI("bg.task_bg.layer_task_primary_line.task_primary_line_progress_bar_bg.label_grow_up_value")
    self._task_primary_line._labelGrowupValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._task_primary_line._labelGrowupValue:getVirtualRenderer():setAdditionalKerning(2)
    --self._task_primary_line._labelGrowupValue:setColor(cc.c4b(153,255,251,255))
    --self._task_primary_line._labelGrowupValue:enableOutline(cc.c4b(88,57,12,255),2)
    --self._task_primary_line._labelGrowupValue:setFontSize(22)

    self._layer_task_everyday = {} 
    self._layer_task_everyday._layer = self:getUI("bg.task_bg.layer_task_everyday")
    --self._layer_task_everyday._scrollView = self:getUI("bg.task_bg.layer_task_everyday.scrollview")
    --self._layer_task_everyday._progressBar = self:getUI("bg.task_bg.layer_task_everyday.task_active_progress_bar_bg.task_active_progress_bar")
    -- 改为进度条了  之前是一个图片
    self._layer_task_everyday._progressBar = self:getUI("bg.task_bg.layer_task_everyday.task_active_progress_bar_bg.task_active_progress_bar")
    
    self._label_refresh = self:getUI("bg.task_bg.layer_task_everyday.label_refresh")
    -- self._label_refresh:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
 
    -- 给进度条增加遮罩
    -- local clipNode = cc.ClippingNode:create()
    -- clipNode:setInverted(false)
    -- local mask = cc.Sprite:createWithSpriteFrameName("task_active_value_progress_mask.png")
    -- mask:setPositionX(2)
    -- mask:setScale(1.24)
    -- clipNode:setStencil(mask)
    -- clipNode:setAlphaThreshold(0.05)
    -- self._layer_task_everyday._progressBar:getParent():addChild(clipNode)
    -- clipNode:setPositionX(self._layer_task_everyday._progressBar:getPositionX()) 
    -- clipNode:setPositionY(self._layer_task_everyday._progressBar:getPositionY()) 
    -- self._layer_task_everyday._progressBar:retain()
    -- self._layer_task_everyday._progressBar:removeFromParent()
    -- clipNode:addChild(self._layer_task_everyday._progressBar)
    -- self._layer_task_everyday._progressBar:release()
    -- self._layer_task_everyday._progressBar:setPosition(-590, 0)
    -- 获取左边文本框

    --[[
    self._layer_task_everyday._lableTotalValue = self:getUI("bg.task_bg.layer_task_everyday.task_active_progress_bar_bg.label_value_0")

    self._layer_task_everyday._imageActiveValueBg = self:getUI("bg.task_bg.layer_task_everyday.image_active_value_bg")
    self._layer_task_everyday._labelActiveValue = cc.Label:createWithBMFont("asset/fnt/font_task_active_value.fnt", "")
    self._layer_task_everyday._labelActiveValue:setAdditionalKerning(0)
    self._layer_task_everyday._labelActiveValue:setAnchorPoint(0.5, 0.5)
    self._layer_task_everyday._labelActiveValue:setPosition(cc.p(self._layer_task_everyday._imageActiveValueBg:getContentSize().width / 2, 
        self._layer_task_everyday._imageActiveValueBg:getContentSize().height / 2 - 6))
    self._layer_task_everyday._imageActiveValueBg:addChild(self._layer_task_everyday._labelActiveValue)
    ]]

    self._layer_task_everyday._lableTotalValue = self:getUI("bg.task_bg.layer_task_everyday.image_active_value_bg.label_value")
    self._layer_task_everyday._lableTotalValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._layer_task_everyday._imageActiveValueBg = self:getUI("bg.task_bg.layer_task_everyday.image_active_value_bg")

    self._layer_task_everyday._taskRewards = {}
    for i=1, 3 do
        self._layer_task_everyday._taskRewards[i] = {}
        self._layer_task_everyday._taskRewards[i]._normal = self:getUI("bg.task_bg.layer_task_everyday.task_active_progress_bar_bg.task_reward_" .. i)
        self:registerClickEvent(self._layer_task_everyday._taskRewards[i]._normal, function ()
            self:onEverydayRewardClicked(i, TaskView.kStatusCannot)
        end)
        self._layer_task_everyday._taskRewards[i]._selected = self:getUI("bg.task_bg.layer_task_everyday.task_active_progress_bar_bg.task_reward_" .. i .. "_s")
        self:registerClickEvent(self._layer_task_everyday._taskRewards[i]._selected, function ()
            self:onEverydayRewardClicked(i, TaskView.kStatusAvailable)
        end)
        
        self._layer_task_everyday._taskRewards[i]._selectedMC = mcMgr:createViewMC("baoxiangguang1_baoxiang", true)
        self._layer_task_everyday._taskRewards[i]._selectedMC:setVisible(false)
        self._layer_task_everyday._taskRewards[i]._selectedMC:setPlaySpeed(1, true)
        self._layer_task_everyday._taskRewards[i]._selectedMC:setPosition(self._layer_task_everyday._taskRewards[i]._selected:getPosition())
        self._layer_task_everyday._taskRewards[i]._selected:getParent():addChild(self._layer_task_everyday._taskRewards[i]._selectedMC, 110)
        --[[
        self._layer_task_everyday._taskRewards[i]._selected:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.ScaleTo:create(0.1, 0.7, 0.77),
            cc.ScaleTo:create(0.07, 0.7, 0.63),
            cc.Spawn:create(cc.ScaleTo:create(0.2, 0.7, 0.77), cc.MoveBy:create(0.2, cc.p(0, 3))),
            cc.Spawn:create(cc.ScaleTo:create(0.2, 0.7, 0.7), cc.MoveBy:create(0.2, cc.p(0, -3)))
        )))
        ]]

        local mcName = "baoxiang1_baoxiang"
        if 2 == i then
            mcName = "baoxiang2_baoxiang"
        elseif 3 == i then
            mcName = "baoxiang3_baoxiang"
        end
        self._layer_task_everyday._taskRewards[i]._selectedMC1 = mcMgr:createViewMC(mcName, true)
        self._layer_task_everyday._taskRewards[i]._selectedMC1:setVisible(false)
        self._layer_task_everyday._taskRewards[i]._selectedMC1:setPlaySpeed(1, true)
        self._layer_task_everyday._taskRewards[i]._selectedMC1:setPosition(self._layer_task_everyday._taskRewards[i]._selected:getPosition())
        self._layer_task_everyday._taskRewards[i]._selectedMC:getParent():addChild(self._layer_task_everyday._taskRewards[i]._selectedMC1, 109)

        self._layer_task_everyday._taskRewards[i]._finished = self:getUI("bg.task_bg.layer_task_everyday.task_active_progress_bar_bg.task_reward_" .. i .. "_f")
        self:registerClickEvent(self._layer_task_everyday._taskRewards[i]._finished, function ()
            self:onEverydayRewardClicked(i, TaskView.kStatusAlready)
        end)
    end
    self._layer_task_everyday._taskRewardLabelValue1 = self:getUI("bg.task_bg.layer_task_everyday.task_active_progress_bar_bg.label_value_1")
    --self._layer_task_everyday._taskRewardLabelValue1:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._layer_task_everyday._taskRewardLabelValue2 = self:getUI("bg.task_bg.layer_task_everyday.task_active_progress_bar_bg.label_value_2")
    --self._layer_task_everyday._taskRewardLabelValue2:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._layer_task_everyday._taskRewardLabelValue3 = self:getUI("bg.task_bg.layer_task_everyday.task_active_progress_bar_bg.label_value_3")
    --self._layer_task_everyday._taskRewardLabelValue3:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self._layer_awaking = {}
    self._layer_awaking._layer = self:getUI("bg.task_bg.layer_awaking")
    self._layer_awaking._layerTeam = self:getUI("bg.task_bg.layer_awaking.layer_team")
    self._layer_awaking._imageTeam = self:getUI("bg.task_bg.layer_awaking.layer_team.image_team")
    self._layer_awaking._imageBg = self:getUI("bg.task_bg.layer_awaking.image_bg")

    self._layer_awaking._imageDes1bg = self:getUI("bg.task_bg.layer_awaking.image_des_1_bg")
    self._layer_awaking._labelTeamName1 = self:getUI("bg.task_bg.layer_awaking.image_des_1_bg.label_team_name_1")
    self._layer_awaking._labelTeamName1:enable2Color(1, cc.c4b(253, 229, 175, 255))
    self._layer_awaking._labelTeamName1:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._layer_awaking._labelTeamName2 = self:getUI("bg.task_bg.layer_awaking.image_des_1_bg.label_team_name_2")
    self._layer_awaking._labelTeamName2:enable2Color(1, cc.c4b(253, 229, 175, 255))
    self._layer_awaking._labelTeamName2:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._layer_awaking._btnCheck = self:getUI("bg.task_bg.layer_awaking.image_des_1_bg.btn_check")
    self:registerClickEvent(self._layer_awaking._btnCheck, function ()
        self:onButtonCheckClicked()
    end)

    self._layer_awaking._labelDes1 = self:getUI("bg.task_bg.layer_awaking.image_des_1_bg.label_des_1")
    self._layer_awaking._btnGiveUp = self:getUI("bg.task_bg.layer_awaking.image_des_1_bg.btn_give_up")
    self._layer_awaking._btnGiveUp:setTitleFontSize(14)
    self._layer_awaking._btnGiveUp:getTitleRenderer():disableEffect()
    self:registerClickEvent(self._layer_awaking._btnGiveUp, function ()
        self:onButtonGiveUpClicked()
    end)

    self._layer_awaking._btnGoAwaking = self:getUI("bg.task_bg.layer_awaking.image_des_1_bg.btn_go_awaking")
    -- self._layer_awaking._btnGoAwaking:getTitleRenderer():disableEffect()
    self._layer_awaking._goAwakingMC = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true)
    self._layer_awaking._goAwakingMC:setPlaySpeed(1, true)
    self._layer_awaking._goAwakingMC:setPosition(self._layer_awaking._btnGoAwaking:getContentSize().width / 2, self._layer_awaking._btnGoAwaking:getContentSize().height / 2)
    self._layer_awaking._btnGoAwaking:addChild(self._layer_awaking._goAwakingMC)
    self:registerClickEvent(self._layer_awaking._btnGoAwaking, function ()
        self:onButtonGoAwakingClicked()
    end)

    self._layer_awaking._imageDes2bg = self:getUI("bg.task_bg.layer_awaking.image_des_2_bg")
    self._layer_awaking._labelTask = self:getUI("bg.task_bg.layer_awaking.image_des_2_bg.label_task")
    self._layer_awaking._labelStep = self:getUI("bg.task_bg.layer_awaking.image_des_2_bg.label_step")
    self._layer_awaking._labelValue = self:getUI("bg.task_bg.layer_awaking.image_des_2_bg.image_go_bg.label_value")
    self._layer_awaking._btnGo = self:getUI("bg.task_bg.layer_awaking.image_des_2_bg.btn_go")
    self:registerClickEvent(self._layer_awaking._btnGo, function ()
        self:onButtonAwakingGoClicked()
    end)

    self._layer_awaking._btnFinish = self:getUI("bg.task_bg.layer_awaking.image_des_2_bg.btn_finish")
    self:registerClickEvent(self._layer_awaking._btnFinish, function ()
        self:onButtonAwakingFinishClicked()
    end)

    self._layer_awaking._labelDes2Bg = self:getUI("bg.task_bg.layer_awaking.image_des_2_bg")
    self._refreshTaskMC = mcMgr:createViewMC("shuaxinguangxiao_shuaxinguangxiao", true, false)
    self._refreshTaskMC:setVisible(false)
    self._refreshTaskMC:setScaleX(1.5)
    self._refreshTaskMC:setPosition(self._layer_awaking._labelDes2Bg:getContentSize().width / 3, self._layer_awaking._labelDes2Bg:getContentSize().height / 3)
    self._layer_awaking._labelDes2Bg:addChild(self._refreshTaskMC, 50)
    self._layer_awaking._labelDes2 = self:getUI("bg.task_bg.layer_awaking.image_des_2_bg.layer_des_2")

    -- self:registerClickEvent(self._buttons[TaskView.kViewTypePrimaryLine]._btn, function ()
    --     self:switchTag(self.kViewTypePrimaryLine)
    -- end)
    -- 新切页动画处理按钮 by guojun 2017.4.17
    UIUtils:setTabChangeAnimEnable(self._buttons[TaskView.kViewTypePrimaryLine]._btn,-22,
        function ()
            self:switchTag(self.kViewTypePrimaryLine)
        end
    )

    -- self:registerClickEvent(self._buttons[TaskView.kViewTypeEveryday]._btn, function ()
    --     if not SystemUtils:enableDailyTask() then
    --         -- self._viewMgr:showTip(lang("TIP_MEIRIRENWU"))
    --         UIUtils:showNotOPenTip("DailyTask")
    --         return 
    --     end
    --     self:switchTag(self.kViewTypeEveryday)
    -- end)
    -- 新切页动画处理按钮 by guojun 2017.4.17
    UIUtils:setTabChangeAnimEnable(self._buttons[TaskView.kViewTypeEveryday]._btn,-22,
        function ()
            if not SystemUtils:enableDailyTask() then
                -- self._viewMgr:showTip(lang("TIP_MEIRIRENWU"))
                UIUtils:showNotOPenTip("DailyTask")
                return 
            end
            self:switchTag(self.kViewTypeEveryday)
        end
    )

    UIUtils:setTabChangeAnimEnable(self._buttons[TaskView.kViewTypeAwaking]._btn,-17,
        function ()
            --[[
            if not SystemUtils:enableDailyTask() then
                -- self._viewMgr:showTip(lang("TIP_MEIRIRENWU"))
                UIUtils:showNotOPenTip("DailyTask")
                return 
            end
            ]]
            self:switchTag(self.kViewTypeAwaking)
        end
    )

    self:listenReflash("TaskModel", self.onModelReflash)
    
    -- 调整位置居中
    -- self._taskbg = self:getUI("bg.task_bg")
    -- self._taskbg:setPositionY(MAX_SCREEN_HEIGHT-320)
end

function TaskView:onBeforeAdd(callback, errorCallback)
    if self._taskModel:isNeedRequest() then
        self:doRequestData(callback, errorCallback)
    else
        self._primaryLineDirty = true
        self._everyDayDirty = true
        self._awakingDirty = true
        self._tasks._data = self:initTaskData()
        local btn = self._buttons[self:getCurrentTag() or 1]._btn
        btn._appearSelect = true
        self:switchTag(self:getCurrentTag(), true)
        if callback then
            callback()
        end
    end
end

function TaskView:onTop()
    if self._taskModel:isNeedRequest() then
        ScheduleMgr:delayCall(200, self, self.doRequestData)
    else
        self._primaryLineDirty = true
        self._everyDayDirty = true
        self._awakingDirty = true
        self._tasks._data = self:initTaskData()
        self:switchTag(self:getCurrentTag(), true)
    end
end

function TaskView:doRequestData(callback, errorCallback)
    if not (self._serverMgr and self.initTaskData and self.switchTag and self.getCurrentTag) then return end
    self._serverMgr:sendMsg("TaskServer", "getTask", {}, true, {}, function(success)
        if not (self._serverMgr and self.initTaskData and self.switchTag and self.getCurrentTag) then return end
        self._primaryLineDirty = true
        self._everyDayDirty = true
        self._awakingDirty = true
        self._tasks._data = self:initTaskData()
        self:switchTag(self:getCurrentTag(), true)
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

function TaskView:getCurrentTag()
    if self._viewType then return self._viewType end

    -- 觉醒可领取直接跳转觉醒页签
    if self._awakingModel:isCurrentAwakingTaskReach() then return self.kViewTypeAwaking end
    if self._awakingModel:isAwakingTaskOpened() and self._isFirstIn then return self.kViewTypeAwaking end

    if SystemUtils:enableDailyTask() then
        for _, v in ipairs(self._tasks._data.detailTasks) do
            if 1 == v.status then
                return self.kViewTypeEveryday
            end
        end

        if self._taskModel:hasTaskCanGetByType(TaskItemView.kViewTypeItemEveryday) then
            return self.kViewTypeEveryday
        end
    end

    for _, v in ipairs(self._tasks._data.mainTasks) do
        if 1 == v.status then
            return self.kViewTypePrimaryLine
        end
    end

    if self._taskModel:hasTaskCanGetByType(TaskItemView.kViewTypeItemPrimary) then
        return self.kViewTypePrimaryLine
    end

    --local lastTaskTag = SystemUtils.loadAccountLocalData("LAST_TASK_TAG")
    --if lastTaskTag then return lastTaskTag end

    if SystemUtils:enableDailyTask() then
        return self.kViewTypeEveryday
    end

    return self.kViewTypePrimaryLine
end

function TaskView:onModelReflash()
    if self._modelMgr:getModel("TaskModel"):isNeedRequest() then
        self:doRequestData()
    else
        self._primaryLineDirty = true
        self._everyDayDirty = true
        self._awakingDirty = true
        self._tasks._data = self:initTaskData()
        self:switchTag(self:getCurrentTag(), true)
    end
end

function TaskView:isSpecialTreasureTaskOpen(taskId)
    if not (taskId >= 9940 and taskId <= 9943) then return true end
    local openServerTime = self._userModel:getOpenServerTime()
    local day = math.floor(openServerTime / 86400)
    return day >= 17
end

function TaskView:isSiegeOver()
    return self._siegeModel:isSiegeOver()
end

function TaskView:initTaskData()
    local result = {
        detailTasks = {},
        mainTasks = {},
    }
    local taskData = self._taskModel:getData()
    --dump(taskData, "taskData", 10)
    local t1, t2 = {}, {}
    for k, v in pairs(taskData.task.mainTasks) do
        repeat
            if tonumber(k) >= 20000 and tonumber(k) <= 20006 then break end
            if (GameStatic.appleExamine or sdkMgr:isGuest()) and 9629 == tonumber(k) then break end
            if not self:isSpecialTreasureTaskOpen(tonumber(k)) then break end
            local task = v
            for kk, vv in pairs(self._tasks._tableData[tonumber(k)]) do
                task[kk] = vv
            end
            if 1 == task.status then
                table.insert(t1, task)
            else
                table.insert(t2, task)
            end
        until true
    end

    table.sort(t1, function(a, b)
        return a.rank < b.rank
    end)

    table.sort(t2, function(a, b)
        return a.rank < b.rank
    end)

    for _, v in ipairs(t1) do
        table.insert(result.mainTasks, v)
    end

    for _, v in ipairs(t2) do
        table.insert(result.mainTasks, v)
    end

    local t1, t2, t3 = {}, {}, {}
    for k, v in pairs(taskData.task.detailTasks) do
        repeat
            if tonumber(k) >= 20000 and tonumber(k) <= 20006 then break end
            if (tonumber(k) == 9631 or tonumber(k) == 9632) and not self:isSiegeOver() then break end
            if (GameStatic.appleExamine or sdkMgr:isGuest()) and 9629 == tonumber(k) then break end
            local taskTableData = self._tasks._tableData[tonumber(k)]
            if not taskTableData then break end
            local task = v
            for kk, vv in pairs(taskTableData) do
                task[kk] = vv
            end
            if 1 == task.status then
                table.insert(t1, task)
            elseif 0 == task.status then
                table.insert(t2, task)
            else
                table.insert(t3, task)
            end
        until true
    end

    table.sort(t1, function(a, b)
        if a.rank < b.rank then
            return true
        elseif a.rank == b.rank then
            return a.id < b.id
        end
    end)

    table.sort(t2, function(a, b)
        if a.rank < b.rank then
            return true
        elseif a.rank == b.rank then
            return a.id < b.id
        end
    end)

    table.sort(t3, function(a, b)
        if a.rank < b.rank then
            return true
        elseif a.rank == b.rank then
            return a.id < b.id
        end
    end)

    for _, v in ipairs(t1) do
        table.insert(result.detailTasks, v)
    end

    for _, v in ipairs(t2) do
        table.insert(result.detailTasks, v)
    end

    if #t3 > 0 then
        table.insert(result.detailTasks, { id = -1 })
        for _, v in ipairs(t3) do
            table.insert(result.detailTasks, v)
        end
    end

    result.active = taskData.active
    result.grow = taskData.grow
    self._awakingTaskData = self._awakingModel:getAwakingTaskData()
    --dump(result, "init task data result", 10)
    return result
end

function TaskView:getTaskOffset()
    for k, v in ipairs(self._tasks._data.detailTasks) do
        if (v.id >= 19618 and v.id <= 19627) or 
           (v.id >= 20000 and v.id <= 20006) then
            if v.status > 1 then
                return true, cc.p(0, self._tableViews[self._viewType]:minContainerOffset().y + (TaskItemView.kItemContentSize.height + 5) * (k - 2))
            else
                return true, cc.p(0, self._tableViews[self._viewType]:minContainerOffset().y + (TaskItemView.kItemContentSize.height + 5) * (k - 1))
            end
        end
    end
    return false
end

function TaskView:switchTag(viewType, force)
    if self._viewType == viewType and not force then return end
    if viewType == TaskView.kViewTypeAwaking and not self._awakingModel:isAwakingTaskOpened() then return end
    self._viewType = viewType
    local btn = self._buttons[TaskView.kViewTypePrimaryLine]._btn
    --btn:setTitleText(TaskView.kViewTypePrimaryLine == viewType and "主线  " or "主线   ")
    local txtRender_primary = btn:getTitleRenderer()
    txtRender_primary:disableEffect()
    if TaskView.kViewTypePrimaryLine ~= viewType then 
        btn:setTitleColor(UIUtils.colorTable.ccUITabColor1)
        btn:setEnabled(TaskView.kViewTypePrimaryLine ~= viewType)
        btn:setBright(TaskView.kViewTypePrimaryLine ~= viewType)
        btn:setZOrder(-99)
        --txtRender_primary:disableEffect()
        --txtRender_primary:setPositionX(65)
        if ( self._preBtn and self._preBtn == btn) then
            UIUtils:tabChangeAnim(self._preBtn,nil,true)
        end
    else
        btn:setTitleColor(UIUtils.colorTable.ccUITabColor2)
        self._preBtn = btn 
        UIUtils:tabChangeAnim(btn,function( )
            btn:setEnabled(TaskView.kViewTypePrimaryLine ~= viewType)
            btn:setBright(TaskView.kViewTypePrimaryLine ~= viewType)
        end)       
        --txtRender_primary:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
        --txtRender_primary:setPositionX(85)
    end

    local btn = self._buttons[TaskView.kViewTypeEveryday]._btn 
    -- btn:loadTexturePressed(SystemUtils:enableDailyTask() and "globalBtnUI4_page1_p.png" or "globalBtnUI4_page1_n.png", 1) 
    --btn:setTitleText(TaskView.kViewTypeEveryday == viewType and "日常  " or "日常   ")
    
    local txtRender_daily = btn:getTitleRenderer()
    txtRender_daily:disableEffect()
    if TaskView.kViewTypeEveryday ~= viewType then 
        btn:setTitleColor(UIUtils.colorTable.ccUITabColor1)
        btn:setEnabled(TaskView.kViewTypeEveryday ~= viewType)
        btn:setBright(TaskView.kViewTypeEveryday ~= viewType)
        btn:setZOrder(-99)
        --txtRender_daily:disableEffect()
        --txtRender_daily:setPositionX(65)
        if ( self._preBtn and self._preBtn == btn) then
            UIUtils:tabChangeAnim(self._preBtn,nil,true)
        end
    else
        btn:setTitleColor(UIUtils.colorTable.ccUITabColor2) 
        self._preBtn = btn 
        UIUtils:tabChangeAnim(btn,function( )
            btn:setEnabled(TaskView.kViewTypeEveryday ~= viewType)
            btn:setBright(TaskView.kViewTypeEveryday ~= viewType)
        end)       
        --txtRender_daily:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
        --txtRender_daily:setPositionX(85)
    end

    local btn = self._buttons[TaskView.kViewTypeAwaking]._btn 
    -- btn:loadTexturePressed(SystemUtils:enableDailyTask() and "globalBtnUI4_page1_p.png" or "globalBtnUI4_page1_n.png", 1) 
    --btn:setTitleText(TaskView.kViewTypeAwaking == viewType and "日常  " or "日常   ")
    
    local txtRender_daily = btn:getTitleRenderer()
    txtRender_daily:disableEffect()
    if TaskView.kViewTypeAwaking ~= viewType then 
        btn:setTitleColor(UIUtils.colorTable.ccUITabColor1)
        btn:setEnabled(TaskView.kViewTypeAwaking ~= viewType)
        btn:setBright(TaskView.kViewTypeAwaking ~= viewType)
        btn:setZOrder(-99)
        --txtRender_daily:disableEffect()
        --txtRender_daily:setPositionX(65)
        if ( self._preBtn and self._preBtn == btn) then
            UIUtils:tabChangeAnim(self._preBtn,nil,true)
        end
    else
        btn:setTitleColor(UIUtils.colorTable.ccUITabColor2) 
        self._preBtn = btn 
        UIUtils:tabChangeAnim(btn,function( )
            btn:setEnabled(TaskView.kViewTypeAwaking ~= viewType)
            btn:setBright(TaskView.kViewTypeAwaking ~= viewType)
        end)       
        --txtRender_daily:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
        --txtRender_daily:setPositionX(85)
    end

    
    -- if TaskView.kViewTypeEveryday == viewType then
    --     self._title:setString("每日任务")
    -- else
    --     self._title:setString("主线任务")
    -- end

    self:updateUI()
end

local function getCount(t)
    local count = 0
    for _, v in pairs(t) do
        count = count + 1
    end
    return count
end

function TaskView:updatePrimaryLineUI()
    if not self._primaryLineDirty then return end
    print("updatePrimaryLineUI")
    self._primaryLineDirty = false
    
    --[[
    --self._task_primary_line._scrollView:removeAllChildren()
    local count = self._task_primary_line._scrollView:getChildrenCount()
    local contentWidth = self._task_primary_line._scrollView:getContentSize().width
    local contentHeight = self._task_primary_line._scrollView:getContentSize().height
    local itemCount = getCount(self._tasks._data.mainTasks)
    local deltaX, deltaY = 0, 2
    local iconWidth, iconHeight = 707, 126
    local innerWidth = contentWidth
    local innerHeight = deltaY + (deltaY + iconHeight) * itemCount
    innerHeight = innerHeight <= contentHeight and contentHeight or innerHeight
    self._task_primary_line._scrollView:setInnerContainerSize(cc.size(innerWidth, innerHeight))
    local index = 1
    for _, v in ipairs(self._tasks._data.mainTasks) do
        --local item = self:createLayer("task.TaskItemView", { container = self, viewType = TaskItemView.kViewTypeItemPrimary, taskData = v })
        local item = self._task_primary_line._scrollView:getChildByTag(1000 + index)
        if not item then
            item = self:createLayer("task.TaskItemView", { container = self, viewType = TaskItemView.kViewTypeItemPrimary, taskData = v })
            item:setName("primaryItem" .. index)
            item:setTag(1000 + index)
            self._task_primary_line._scrollView:addChild(item)
        else
            item:setVisible(true)
            item:setContext({ container = self, viewType = TaskItemView.kViewTypeItemPrimary, taskData = v })
            item:updateUI()
        end
        item:setPosition(deltaX, innerHeight - ((deltaY + iconHeight) * index))
        -- item:setPosition(deltaX, innerHeight - (iconHeight * index + deltaY * (index -1)))
        index = index + 1
    end
    for i = index, count do
        local item = self._task_primary_line._scrollView:getChildByTag(1000 + index)
        if item then
            item:setVisible(false)
        end
    end
    ]]
    self:refreshTaskTableView()
    local currentGrow = self._tasks._data.grow.val
    local index = self._tasks._data.grow.receive + 1
    local currentMaxGrow = self._tasks._tableGrowAwardData[index].grow
    self._task_primary_line._labelGrowupValue:setString(string.format("%d/%d", currentGrow, currentMaxGrow))
    local percent = math.min(1, currentGrow / currentMaxGrow)
    self._task_primary_line._progressBar:setPercent(percent*100)
    self._task_primary_line._progressBar:setVisible(percent*100 > 0)
    -- self._task_primary_line._progressBar:setPositionX(-590 + percent * 590)
    self._task_primary_line._taskReward:setVisible(percent < 1)
    self._task_primary_line._taskRewardSelected:setVisible(percent >= 1)
    self._task_primary_line._taskRewardSelectedMC:setVisible(percent >= 1)
    self._task_primary_line._taskRewardSelectedMC1:setVisible(percent >= 1)
    --[=[
    if percent >= 1 then
        --[[
        self._task_primary_line._taskRewardSelectedMC1:addEndCallback(function()
            self._task_primary_line._taskRewardSelectedMC1:stop()
            self._task_primary_line._taskRewardSelectedMC1:setVisible(false)
        end)
        ]]
        SystemUtils.saveAccountLocalData("TaskViewMcActive1",true)
        
    else 
        -- 持久化存储激活状态
        SystemUtils.saveAccountLocalData("TaskViewMcActive1",false)
        SystemUtils.saveAccountLocalData("TaskViewMcFlag1",true)
    end
        
    local flag = SystemUtils.loadAccountLocalData("TaskViewMcFlag1")
    local active = SystemUtils.loadAccountLocalData("TaskViewMcActive1")
    if active == true  then
        -- SystemUtils.saveAccountLocalData("TaskViewMcActive1",false)
        if flag == true then
            SystemUtils.saveAccountLocalData("TaskViewMcFlag1",false)
            --self._task_primary_line._taskRewardSelectedMC1:setVisible(true)
            --self._task_primary_line._taskRewardSelectedMC1:gotoAndPlay(0)
        else
            self._task_primary_line._taskRewardSelectedMC1:stop()
            --self._task_primary_line._taskRewardSelectedMC1:setVisible(false)  
        end
    end
    ]=]
end

function TaskView:updateEverydayUI()
    if not self._everyDayDirty then return end
    print("updateEverydayUI")
    self._everyDayDirty = false

    --[[
    --self._layer_task_everyday._scrollView:removeAllChildren()
    local count = self._layer_task_everyday._scrollView:getChildrenCount()
    local contentWidth = self._layer_task_everyday._scrollView:getContentSize().width
    local contentHeight = self._layer_task_everyday._scrollView:getContentSize().height
    local itemCount = getCount(self._tasks._data.detailTasks)
    local deltaX, deltaY = 0, 2
    local iconWidth, iconHeight, finishHeight = 707, 126, 40
    local innerWidth = contentWidth
    local innerHeight = 0
    for _, v in ipairs(self._tasks._data.detailTasks) do
        if -1 == v.id then
            innerHeight = innerHeight + (deltaY + finishHeight)
        else
            innerHeight = innerHeight + (deltaY + iconHeight)
        end
    end
    innerHeight = innerHeight <= contentHeight and contentHeight or innerHeight
    self._layer_task_everyday._scrollView:setInnerContainerSize(cc.size(innerWidth, innerHeight))
    local index = 1
    local nowY = 0
    for _, v in ipairs(self._tasks._data.detailTasks) do
        --local item = self:createLayer("task.TaskItemView", { container = self, viewType = -1 == v.id and TaskItemView.kViewTypeFinished or TaskItemView.kViewTypeItemEveryday, taskData = v })
        local item = self._layer_task_everyday._scrollView:getChildByTag(1000 + index)
        if not item then
            item = self:createLayer("task.TaskItemView", { container = self, viewType = -1 == v.id and TaskItemView.kViewTypeFinished or TaskItemView.kViewTypeItemEveryday, taskData = v })
            item:setName("everydayItem" .. index)
            item:setTag(1000 + index)
            self._layer_task_everyday._scrollView:addChild(item)
        else
            item:setVisible(true)
            item:setContext({ container = self, viewType = -1 == v.id and TaskItemView.kViewTypeFinished or TaskItemView.kViewTypeItemEveryday, taskData = v })
            item:updateUI()
        end
        if -1 == v.id then
            nowY = nowY + (deltaY + finishHeight)
        else
            nowY = nowY + (deltaY + iconHeight)
        end
        item:setPosition(deltaX, innerHeight - nowY)
        index = index + 1
    end
    for i = index, count do
        local item = self._layer_task_everyday._scrollView:getChildByTag(1000 + index)
        if item then
            item:setVisible(false)
        end
    end
    ]]

    self:refreshTaskTableView()

    if not self._firstIn then
        self._firstIn = true
        if self._superiorType == TaskView.kSuperiorTypePrivileges or
           self._superiorType == TaskView.kSuperiorTypeAdventure then
            local found, offset = self:getTaskOffset()
            --print("_superiorType..offset....", self._superiorType, offset)
            if found then
                self._tableViews[self._viewType]:setContentOffset(offset)
            end
        end
    end
    --[[
    self._layer_task_everyday._labelActiveValue:setString(tostring((self._tasks._data.active.val or 0)))

    self._layer_task_everyday._lableTotalValue:setString(tostring((self._tasks._data.active.val or 0)))
    ]]
    self._layer_task_everyday._lableTotalValue:setString(tostring((self._tasks._data.active.val or 0)))
    -- 设置进度条 
    local active_value = self._tasks._data.active.val or 0
    local percent = 0
    if active_value <= 100 then
        percent = 2 / 3 * active_value
    else
        percent = (active_value + 100) / 3
    end
    -- print("percent " .. percent)
    -- self._layer_task_everyday._progressBar:setPositionX(-590 + positionX ) 
    self._layer_task_everyday._progressBar:setPercent(percent)
    self._layer_task_everyday._progressBar:setVisible(percent > 0)

    local activeConfig = {50, 100, 200}
    for i = 1, 3 do
        self._layer_task_everyday._taskRewards[i]._normal:setVisible((self._tasks._data.active.val or 0) < activeConfig[i])
        self._layer_task_everyday._taskRewards[i]._selected:setVisible(0 == (self._tasks._data.active["reward" .. i] or 0) and (self._tasks._data.active.val or 0) >= activeConfig[i])
        self._layer_task_everyday._taskRewards[i]._selectedMC:setVisible(0 == (self._tasks._data.active["reward" .. i] or 0) and (self._tasks._data.active.val or 0) >= activeConfig[i])
        self._layer_task_everyday._taskRewards[i]._selectedMC1:setVisible(0 == (self._tasks._data.active["reward" .. i] or 0) and (self._tasks._data.active.val or 0) >= activeConfig[i])
        self._layer_task_everyday._taskRewards[i]._finished:setVisible((self._tasks._data.active["reward" .. i] or 0) > 0 and (self._tasks._data.active.val or 0) >= activeConfig[i])
        --[=[
        -- 每次循环持久化存储相应的状态
        if percent == 100 then 
            SystemUtils.saveAccountLocalData("TaskViewMcActive4",false)
            SystemUtils.saveAccountLocalData("TaskViewMcFlag4",true)
            elseif percent >= 50  then
                SystemUtils.saveAccountLocalData("TaskViewMcActive3",false)
                SystemUtils.saveAccountLocalData("TaskViewMcFlag3",true)
                elseif percent >= 25 then
                    SystemUtils.saveAccountLocalData("TaskViewMcActive2",false)
                    SystemUtils.saveAccountLocalData("TaskViewMcFlag2",true)
            --todo
        end 
        local flag = SystemUtils.loadAccountLocalData("TaskViewMcFlag" .. i+1)
        local active = SystemUtils.loadAccountLocalData("TaskViewMcActive" .. i+1)

        if self._layer_task_everyday._taskRewards[i]._selectedMC:isVisible() then
            --[[
            self._layer_task_everyday._taskRewards[i]._selectedMC:addEndCallback(function()
                self._layer_task_everyday._taskRewards[i]._selectedMC1:stop()
                self._layer_task_everyday._taskRewards[i]._selectedMC1:setVisible(false)
            end)
            ]]
            if active == true  then
                -- SystemUtils.saveAccountLocalData("TaskViewMcActive1",false)
                if flag == true then
                    SystemUtils.saveAccountLocalData("TaskViewMcFlag" .. i+1,false)
                    --self._layer_task_everyday._taskRewards[i]._selectedMC1:setVisible(true)
                    --self._layer_task_everyday._taskRewards[i]._selectedMC1:gotoAndPlay(0)
                else
                    --self._layer_task_everyday._taskRewards[i]._selectedMC1:stop()
                    --self._layer_task_everyday._taskRewards[i]._selectedMC1:setVisible(false)  
                end
            end
        end
        ]=]
    end
end

function TaskView:updateAwakingUI()
    if not (self._awakingDirty and self._awakingModel:isAwakingTaskOpened()) then return end
    print("updateAwakingUI")
    self._awakingDirty = false

    local teamTableData = tab:Team(self._awakingTaskData.teamId)
    local awakingTaskData = tab:AwakingTask(self._awakingTaskData.taskId)
    self._layer_awaking._imageTeam:loadTexture("asset/uiother/team/" .. "t_" .. string.sub(teamTableData.art1, 4) .. ".png")
    local receData = teamTableData.race
    local raceBg = tab:Race(receData[1]).awakingBg
    if raceBg then
        self._layer_awaking._imageBg:loadTexture("asset/bg/" .. raceBg .. ".jpg")
    end
    local nameStr = lang(teamTableData.name)
    self._layer_awaking._labelTeamName1:setString(nameStr)
    if string.utf8len(nameStr) > 4 then
        self._layer_awaking._labelTeamName1:setFontSize(35)
    else
        self._layer_awaking._labelTeamName1:setFontSize(40)
    end
    self._layer_awaking._labelTeamName2:setPositionX(self._layer_awaking._labelTeamName1:getPositionX() + self._layer_awaking._labelTeamName1:getContentSize().width + 5)
    self._layer_awaking._labelDes1:setString(lang(teamTableData.awakingDes))
    self._layer_awaking._labelStep:setString(self._awakingTaskData.progress + 1 .. "/4")
    if awakingTaskData.type and 1 == awakingTaskData.type then
        local value = self._awakingModel:isCurrentAwakingTaskReach() and 1 or 0
        self._layer_awaking._labelValue:setString(value .. "/" .. 1)
    else
        local value = self._awakingTaskData.value
        local condition = awakingTaskData.condition[1]
        if value > condition then
            value = condition
        end
        self._layer_awaking._labelValue:setString(value .. "/" .. condition)
    end

    local label = self._layer_awaking._labelDes2
    local desc = lang(awakingTaskData.des)
    local richText = label:getChildByName("descRichText" )
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, label:getContentSize().width, label:getContentSize().height)
    richText:setVerticalSpace(-2)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(label:getContentSize().width / 2, label:getContentSize().height / 2)
    richText:setName("descRichText")
    label:addChild(richText)

    local isTaskReach = self._awakingModel:isCurrentAwakingTaskReach()
    local isAllFinished = 4 == self._awakingTaskData.progress

    if isTaskReach then
        self._layer_awaking._labelValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    else
        self._layer_awaking._labelValue:disableEffect()
    end
    self._layer_awaking._labelValue:setColor(isTaskReach and cc.c3b(0, 255, 30) or cc.c3b(60, 42, 30))
    self._layer_awaking._btnGo:setVisible(not isTaskReach)
    self._layer_awaking._btnFinish:setVisible(isTaskReach and not isAllFinished)
    self._layer_awaking._btnGiveUp:setVisible(not isAllFinished)
    self._layer_awaking._labelDes2Bg:setVisible(not isAllFinished)
    self._layer_awaking._btnGoAwaking:setVisible(isTaskReach and isAllFinished)
end

function TaskView:updateUI(viewType)
    --print("TaskView:updateUI")
    viewType = tonumber(viewType) or tonumber(self._viewType)

    self._buttons[TaskView.kViewTypePrimaryLine]._red_tag:setVisible(self._taskModel:hasTaskCanGetByType(TaskItemView.kViewTypeItemPrimary))
    self._buttons[TaskView.kViewTypeEveryday]._red_tag:setVisible(SystemUtils:enableDailyTask() and self._taskModel:hasTaskCanGetByType(TaskItemView.kViewTypeItemEveryday))
    self._buttons[TaskView.kViewTypeAwaking]._btn:setVisible(self._awakingModel:isAwakingTaskOpened())
    local isTaskReach = self._awakingModel:isCurrentAwakingTaskReach()
    self._buttons[TaskView.kViewTypeAwaking]._red_tag:setVisible(isTaskReach)

    if viewType == self.kViewTypePrimaryLine then
        self._task_primary_line._layer:setVisible(true)
        self._layer_task_everyday._layer:setVisible(false)
        self._layer_awaking._layer:setVisible(false)
        self:updatePrimaryLineUI()
    elseif viewType == self.kViewTypeEveryday then
        self._task_primary_line._layer:setVisible(false)
        self._layer_task_everyday._layer:setVisible(true)
        self._layer_awaking._layer:setVisible(false)
        self:updateEverydayUI()
    else
        self._task_primary_line._layer:setVisible(false)
        self._layer_task_everyday._layer:setVisible(false)
        self._layer_awaking._layer:setVisible(true)
        self:updateAwakingUI()
    end
end

function TaskView:refreshTaskTableView()
    self:destroyTaskTableView()
    self:createTaskTableView()
    if self._tableViewOffset[self._viewType] then
        self._tableViews[self._viewType]:setContentOffset(self._tableViewOffset[self._viewType])
        self._tableViewOffset[self._viewType] = nil
    end
end

function TaskView:destroyTaskTableView()
    -- if not self._tableViews[self._viewType] then return end
    -- self._tableViews[self._viewType]:removeFromParentAndCleanup()
    -- self._tableViews[self._viewType] = nil
end

function TaskView:createTaskTableView()
    -- if self._tableViews[self._viewType] then return end
    if self._tableViews[self._viewType] == nil then
        local size = cc.size(self._layerTaskList[self._viewType]:getContentSize().width, self._layerTaskList[self._viewType]:getContentSize().height - 20)
        self._tableViews[self._viewType] = cc.TableView:create(size)
        self._tableViews[self._viewType].tableViewHeight = size.height
        self._tableViews[self._viewType]:setDelegate()
        self._tableViews[self._viewType]:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self._tableViews[self._viewType]:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self._tableViews[self._viewType]:setAnchorPoint(cc.p(0, 0))
        self._tableViews[self._viewType]:setPosition(cc.p(0, 10))
        --self._tableViews[self._viewType]:setBounceable(false)
        self._layerTaskList[self._viewType]:addChild(self._tableViews[self._viewType], self.kAboveNormalZOrder)
        self._tableViews[self._viewType]:registerScriptHandler(handler(self, self.taskTableViewCellTouched), cc.TABLECELL_TOUCHED)
        self._tableViews[self._viewType]:registerScriptHandler(handler(self, self.taskTableViewCellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
        self._tableViews[self._viewType]:registerScriptHandler(handler(self, self.taskTableViewCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
        self._tableViews[self._viewType]:registerScriptHandler(handler(self, self["taskNumberOfCellsInTableView" .. self._viewType]), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self._tableViews[self._viewType]:registerScriptHandler(handler(self, self["scrollViewDidScroll" .. self._viewType]), cc.SCROLLVIEW_SCRIPT_SCROLL)
        UIUtils:ccScrollViewAddScrollBar(self._tableViews[self._viewType], cc.c3b(169, 124, 75), cc.c3b(64, 32, 12), -12, 6)
    end 
    self._tableViews[self._viewType]:reloadData()
end

function TaskView:taskTableViewCellTouched(tableView, cell)
    local idx = cell:getIdx()
    local taskItemView = cell:getChildByTag(self.kTaskItemTag)
    if not taskItemView then return end
    local taskData = nil
    if self._viewType == TaskView.kViewTypePrimaryLine then
        taskData = self._tasks._data.mainTasks
    else
        taskData = self._tasks._data.detailTasks
    end
    if not taskData then return end
    local index = idx + 1
    local taskItemData = taskData[index]
    if 0 == taskItemData.status then
        --taskItemView:onButtonGoClicked()
        self._viewMgr:showTip(lang("TIP_TASK_RECIEVE"))
    end
end

function TaskView:taskTableViewCellSizeForTable(tableView, idx)
    local taskData = nil
    if self._viewType == TaskView.kViewTypePrimaryLine then
        taskData = self._tasks._data.mainTasks
    else
        taskData = self._tasks._data.detailTasks
    end
    if not taskData then return end
    local index = idx + 1
    local taskItemData = taskData[index]
    if -1 == taskItemData.id then
        return TaskItemView.kItemContentSize.height  / 3, TaskItemView.kItemContentSize.width
    else
        return TaskItemView.kItemContentSize.height, TaskItemView.kItemContentSize.width
    end
end

function TaskView:taskTableViewCellAtIndex(tableView, idx)
    local taskData = nil
    if self._viewType == TaskView.kViewTypePrimaryLine then
        taskData = self._tasks._data.mainTasks
    else
        taskData = self._tasks._data.detailTasks
    end
    if not taskData then return end
    local index = idx + 1
    local taskItemData = taskData[index]
    local cell = tableView:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
        local taskItemView = self:createLayer("task.TaskItemView", { container = self, viewType = -1 == taskItemData.id and TaskItemView.kViewTypeFinished or self._viewType, taskData = taskItemData})
        taskItemView:setTouchEnabled(false)
        taskItemView:setVisible(true)
        taskItemView:setPosition(0, -5)
        taskItemView:setTag(self.kTaskItemTag)
        taskItemView:updateUI()
        cell:addChild(taskItemView)
    else
        local taskItemView = cell:getChildByTag(self.kTaskItemTag)
        if not taskItemView then return end
        taskItemView:setContext({ container = self, viewType = -1 == taskItemData.id and TaskItemView.kViewTypeFinished or self._viewType, taskData = taskItemData})
        taskItemView:updateUI()
    end
    return cell
end

function TaskView:taskNumberOfCellsInTableView1(tableView)
    if TaskView.kViewTypePrimaryLine ~= self._viewType then return 0 end
    return #self._tasks._data.mainTasks
end

function TaskView:taskNumberOfCellsInTableView2(tableView)
    if TaskView.kViewTypeEveryday ~= self._viewType then return 0 end
    return #self._tasks._data.detailTasks
end

function TaskView:scrollViewDidScroll1(view)
    self:scrollViewDidScroll(view, 1)
end

function TaskView:scrollViewDidScroll2(view)
    self:scrollViewDidScroll(view, 2)
end

function TaskView:createLoadingMc(index)
    if index == 1 then
        return self:createLoadingMc1()
    else
        return self:createLoadingMc2()
    end
end

function TaskView:createLoadingMc1()
    if self._loadingMc1 then return self._loadingMc1 end
    -- 添加加载中动画
    local viewBg = self:getUI("bg.task_bg.layer_task_primary_line")
    self._loadingMc1 = mcMgr:createViewMC("jiazaizhong_rankjiazaizhong", true, false, function (_, sender) end)
    self._loadingMc1:setPosition(cc.p(viewBg:getContentSize().width * 0.5 - 30, 380))
    viewBg:addChild(self._loadingMc1, 100)
    return self._loadingMc1
end

function TaskView:createLoadingMc2()
    if self._loadingMc2 then return self._loadingMc2 end
    -- 添加加载中动画
    local viewBg = self:getUI("bg.task_bg.layer_task_everyday")
    self._loadingMc2 = mcMgr:createViewMC("jiazaizhong_rankjiazaizhong", true, false, function (_, sender) end)
    self._loadingMc2:setPosition(cc.p(viewBg:getContentSize().width * 0.5 - 30, 380))
    viewBg:addChild(self._loadingMc2, 100)
    return self._loadingMc2
end

function TaskView:scrollViewDidScroll(view, index)
    local offsetY = view:getContentOffset().y
    local minY = view.tableViewHeight - view:getContentSize().height
    local isDragging = view:isDragging()
    local mc
    if isDragging then
        if offsetY < minY - 60 and not self._reRequest then
            self._reRequest = true
            self:createLoadingMc(index):setVisible(true)
        end
        if offsetY > minY - 30 and self._reRequest then
            self._reRequest = false
            self:createLoadingMc(index)
            self:createLoadingMc(index):setVisible(false)
        end
    else
        if self._reRequest and minY == offsetY then
            self._reRequest = false
            -- 请求
            self:createLoadingMc(index)
            self:createLoadingMc(index):setVisible(false)
            if self._updateTaskTick == nil or socket.gettime() > self._updateTaskTick + 5 then
                self:doRequestData()
                self._updateTaskTick = socket.gettime()
            end
            
        end
    end
    UIUtils:ccScrollViewUpdateScrollBar(view)
end

function TaskView:showRewardDialog(taskData, resultData, serverRewards)
    local params = { gifts = clone(taskData.award) }
    if serverRewards then
        params = {gifts = clone(serverRewards)}
    end
    if resultData then
        params.callback = function()
            if resultData.lvl then
                local lastLvl = self._userModel:getLastLvl()
                local lastPhysical = self._userModel:getLastPhysical()
                local userLevel = self._userModel:getData().lvl
                local userphysic = self._userModel:getData().physcal
                self._viewMgr:checkLevelUpReturnMain(resultData.lvl)
                ViewManager:getInstance():showDialog("global.DialogUserLevelUp", { preLevel = lastLvl, level = resultData.lvl, prePhysic = lastPhysical, physic = resultData.physcal }, true, nil, nil, false)
            end
        end
    end
    if serverRewards then
        params.notPop = not params.viewType
        DialogUtils.showGiftGet(params)
        return
    end

    local toolTableData = tab.tool
    local staticConfigTableData = IconUtils.iconIdMap

    for i = 1, #params.gifts do
        if params.gifts[i][1] ~= "tool" and staticConfigTableData[params.gifts[i][1]] then
            if params.gifts[i][1] == "physcal" then
                if 9615 == taskData.id then
                    params.gifts[i][3] = math.round(params.gifts[i][3] + self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_19))
                elseif 9616 == taskData.id then
                    params.gifts[i][3] = math.round(params.gifts[i][3] + self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_17))
                elseif 9617 == taskData.id then
                    params.gifts[i][3] = math.round(params.gifts[i][3] + self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_18))
                end
            elseif params.gifts[i][1] == "exp" then
                if 201 ~= taskData.conditiontype then
                    params.gifts[i][3] = math.round(params.gifts[i][3] + params.gifts[i][3] * self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_16) * 0.01)
                end
            end
        end
    end
    dump(params, "params", 10)
    params.notPop = not params.viewType
    DialogUtils.showGiftGet(params)
    --[=[
    local staticConfigTableData = IconUtils.iconIdMap
    local gifts = {}
    for i=1, #taskData.award do
        local itemData = {}
        if taskData.award[i][1] ~= "tool" and staticConfigTableData[taskData.award[i][1]] then
            itemData.goodsId = tonumber(staticConfigTableData[taskData.award[i][1]])
        elseif taskData.award[i][1] == "tool" then
            itemData.goodsId = tonumber(taskData.award[i][2])
        end
        itemData.num = taskData.award[i][3]
        itemData.isItem = true
        table.insert(gifts,itemData)
    end
    DialogUtils.showGiftGet( gifts)
    ]=]
end

function TaskView:onPrimaryLineRewardClicked(status)
    if TaskView.kStatusCannot == status then
        local index = self._tasks._data.grow.receive + 1
        local currentMaxGrow = self._tasks._tableGrowAwardData[index].grow
        self._primaryLineRewardDialog = DialogUtils.showGiftGet( { gifts = self._tasks._tableGrowAwardData[index].award, viewType = 2, des = "成长值达到" .. currentMaxGrow .. "可领取"})
        return 
    elseif TaskView.kStatusAlready == status then
        self._viewMgr:showTip(lang("TiPS_YILINGQU"))
        return 
    end

    self._serverMgr:sendMsg("TaskServer", "receiveGrowReward", {}, true, {}, function(data, success)
        if not success then 
            self._viewMgr:showTip("很遗憾，领取奖励失败, 请配表")
            return 
        end
        self._primaryLineRewardDialog = DialogUtils.showGiftGet( { gifts = data["rewards"], callback = function()
            self._primaryLineDirty = true
            self:updateUI(self.kViewTypePrimaryLine)
        end,notPop = true})
    end)

    --[=[
    local giftId = self._tasks._tableGrowAwardData[self._task_primary_line._taskGrowRewardId].award
    local gifts = tab.toolGift[giftId].giftContain
    self._primaryLineRewardDialog = DialogUtils.showGiftGet( { gifts = gifts, viewType = 1, callback = function()
        if TaskView.kStatusCannot == status then
            self._viewMgr:showTip("成长值不够")
            return 
        elseif TaskView.kStatusAlready == status then
            self._viewMgr:showTip("已经领取过该奖励")
            return 
        end
        self._serverMgr:sendMsg("TaskServer", "receiveGrowReward", {}, true, {}, function(success)
            if self._primaryLineRewardDialog then
                self._primaryLineRewardDialog:close()
                self._primaryLineRewardDialog = nil
            end
            if not success then 
                self._viewMgr:showTip("很遗憾，领取奖励失败")
                return 
            end
            self._viewMgr:showTip("恭喜，领取奖励成功")
            self._primaryLineDirty = true
            self:updateUI(self.kViewTypePrimaryLine)
        end)
    end,})
    ]=]
    --[=[
    local staticConfigTableData = IconUtils.iconIdMap
    local giftId = self._tasks._tableGrowAwardData[self._task_primary_line._taskGrowRewardId].award
    local award = tab.toolGift[giftId].giftContain
    local gifts = {}
    for i=1, #award do
        local itemData = {}
        if award[i][1] ~= "tool" and staticConfigTableData[award[i][1]] then
            itemData.goodsId = tonumber(staticConfigTableData[award[i][1]])
        elseif award[i][1] == "tool" then
            itemData.goodsId = tonumber(award[i][2])
        end
        itemData.num = award[i][3]
        itemData.isItem = true
        table.insert(gifts,itemData)
    end

    DialogUtils.showGiftGet( { gifts = gifts, viewType = 1, callback = function()
        if showDetails then
            self._viewMgr:showTip("成长值不够")
            return 
        end
        self._serverMgr:sendMsg("TaskServer", "receiveGrowReward", {}, true, {}, function(success)
            if not success then return end
            self._viewMgr:showTip("恭喜，领取奖励成功")
            self._primaryLineDirty = true
            self:updateUI(self.kViewTypePrimaryLine)
        end)
    end,})
    ]=]
end

function TaskView:onEverydayRewardClicked(position, status)
    local gifts = clone(self._tasks._tableActiveAwardData[position].award)

    if TaskView.kStatusCannot == status then
        local activeConfig = {50, 100, 200}
        local acAward = self._acAwards[activeConfig[position]]
        if acAward then
            for k,v in pairs(acAward) do
                table.insert(gifts, v)
            end            
        end
        self._everydayRewardDialog = DialogUtils.showGiftGet( { gifts = gifts, viewType = 2, des = "活跃度达到" .. activeConfig[position] .. "可领取"})
        return 
    elseif TaskView.kStatusAlready == status then
        self._viewMgr:showTip(lang("TiPS_YILINGQU"))
        return 
    end
    
    self._serverMgr:sendMsg("TaskServer", "receiveActiveReward", {id = position}, true, {}, function(data, success)
        if not success then 
            self._viewMgr:showTip("很遗憾，领取奖励失败，请配表")
            return 
        end
        self._primaryLineRewardDialog = DialogUtils.showGiftGet( { gifts = data["rewards"], callback = function()
            self._everyDayDirty = true
            self:updateUI(self.kViewTypeEveryday)
        end,notPop = true})
    end)

    --[=[
    local giftId = self._tasks._tableActiveAwardData[position].award
    local gifts = tab.toolGift[giftId].giftContain
    self._everydayRewardDialog = DialogUtils.showGiftGet( { gifts = gifts, viewType = 1, callback = function()
        if TaskView.kStatusCannot == status then
            self._viewMgr:showTip("活跃值不够")
            return 
        elseif TaskView.kStatusAlready == status then
            self._viewMgr:showTip("已经领取过该奖励")
            return 
        end
        self._serverMgr:sendMsg("TaskServer", "receiveActiveReward", {id = position}, true, {}, function(success)
            if self._everydayRewardDialog then
                self._everydayRewardDialog:close()
                self._everydayRewardDialog = nil
            end
            if not success then 
                self._viewMgr:showTip("很遗憾，领取奖励失败")
                return 
            end
            self._viewMgr:showTip("恭喜，领取奖励成功")
            self._everyDayDirty = true
            self:updateUI(self.kViewTypeEveryday)
        end)
    end,})
    ]=]
    --[=[
    local staticConfigTableData = IconUtils.iconIdMap
    local giftId = self._tasks._tableActiveAwardData[position].award
    local award = tab.toolGift[giftId].giftContain
    local gifts = {}
    for i=1, #award do
        local itemData = {}
        if award[i][1] ~= "tool" and staticConfigTableData[award[i][1]] then
            itemData.goodsId = tonumber(staticConfigTableData[award[i][1]])
        elseif award[i][1] == "tool" then
            itemData.goodsId = tonumber(award[i][2])
        end
        itemData.num = award[i][3]
        itemData.isItem = true
        table.insert(gifts,itemData)
    end

    DialogUtils.showGiftGet( { gifts = gifts, viewType = 1, callback = function()
        if showDetails then
            self._viewMgr:showTip("活跃度不够")
            return 
        end
        self._serverMgr:sendMsg("TaskServer", "receiveActiveReward", {id = position}, true, {}, function(success)
            if not success then return end
            self._viewMgr:showTip("恭喜，领取奖励成功")
            self._primaryLineDirty = true
            self:updateUI(self.kViewTypePrimaryLine)
        end)
    end,})
    ]=]
end

function TaskView:onButtonGoClicked(taskData)
    --print("onButtonGoClicked")
    if self["goView" .. taskData.button] then
        if self._viewType ~= TaskView.kViewTypeAwaking then
            self._tableViewOffset[self._viewType] = self._tableViews[self._viewType]:getContentOffset()
        end
        self["goView" .. taskData.button](self, taskData.param)
    end
end

function TaskView:onButtonAwakingGoClicked()
    --print("onButtonGoClicked")
    if not self._awakingModel:isAwakingTaskOpened() then return end
    local awakingTaskData = tab:AwakingTask(self._awakingTaskData.taskId)
    self:onButtonGoClicked({button = awakingTaskData.button[1], param = awakingTaskData.button[2]})
end

function TaskView:goView1() self._viewMgr:showView("intance.IntanceView", {superiorType = 2}) end
function TaskView:goView2() self._viewMgr:showView("vip.VipView", {viewType = 0}) end
function TaskView:goView3(param)
    if not SystemUtils:enableElite() then
        self._viewMgr:showTip(lang("TIP_JINGYING_1"))
        return 
    end
    if param then
        local sectionId = param
        local sectionInfo = self._modelMgr:getModel("IntanceEliteModel"):getSectionInfo(sectionId)
        if not sectionInfo.isOpen then
            sectionId = self._modelMgr:getModel("IntanceEliteModel"):getCurSectionId()
        end
        self._viewMgr:showView("intance.IntanceEliteView", {sectionId = sectionId})
    else
        self._viewMgr:showView("intance.IntanceEliteView", {superiorType = 2})
    end
end
function TaskView:goView4() 
    if not SystemUtils:enableDwarvenTreasury() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("pve.AiRenMuWuView") 
end
function TaskView:goView5() 
    if not SystemUtils:enableCrypt() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("pve.ZombieView") 
end
function TaskView:goView6() 
    if not SystemUtils:enableBoss() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("pve.DragonView") 
end
function TaskView:goView7() self._viewMgr:showView("team.TeamListView") end
function TaskView:goView8() self._viewMgr:showView("flashcard.FlashCardView") end
function TaskView:goView9() 
    if not SystemUtils:enableArena() then
        self._viewMgr:showTip(lang("TIP_Arena"))
        return 
    end
    self._viewMgr:showView("arena.ArenaView") 
end
function TaskView:goView10() 
    if not SystemUtils:enableCrusade() then
        self._viewMgr:showTip(lang("TIP_Crusade"))
        return 
    end
    self._viewMgr:showView("crusade.CrusadeView") 
end
function TaskView:goView11() DialogUtils.showBuyRes({goalType = "gold", callback = function(success)
    if success then self._tableViews[self._viewType]:setContentOffset(self._tableViews[self._viewType]:minContainerOffset()) end
end}) end
function TaskView:goView12() DialogUtils.showBuyRes({goalType = "physcal", callback = function(success)
    if success then self._tableViews[self._viewType]:setContentOffset(self._tableViews[self._viewType]:minContainerOffset()) end
end}) end
function TaskView:goView13() DialogUtils.showBuyRes({goalType = "gem", callback = function(success)
    if success then self._tableViews[self._viewType]:setContentOffset(self._tableViews[self._viewType]:minContainerOffset()) end
end}) end
--[[
function TaskView:goView14() DialogUtils.showBuyRes({goalType = "gem", callback = function(success)
    if success then self._layer_task_everyday._scrollView:scrollToTop(1, true) end
end}) end
function TaskView:goView15() DialogUtils.showBuyRes({goalType = "gem", callback = function(success)
    if success then self._layer_task_everyday._scrollView:scrollToTop(1, true) end
end}) end
function TaskView:goView16() 
    if self._modelMgr:getModel("ActivityCarnivalModel"):carnivalIsOpen() then
        self._viewMgr:showDialog("activity.ActivityCarnival", {}, true)
    else
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
    end
end
function TaskView:goView17() 
    local showday, _ = self._modelMgr:getModel("ActivitySevenDaysModel"):getShowDayAndState()
    if SystemUtils:enableSevenDay() and showday > 0  then
        self._viewMgr:showDialog("activity.ActivitySevenDaysView", {})
    else
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
    end
end
]]
function TaskView:goView18() 
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
--[[
function TaskView:goView19() 
    if not SystemUtils:enableTreasure() then
        self._viewMgr:showTip(lang("TIP_Treasure"))
        return 
    end

    self._viewMgr:showView("treasure.TreasureView")
end

function TaskView:goView20() 
    if not SystemUtils:enableTeamBoost() then
        self._viewMgr:showTip(lang("TIP_TeamBoost"))
        return 
    end

    self._viewMgr:showView("teamboost.TeamBoostView")
end

function TaskView:goView21() 
    if not SystemUtils:enableHero() then
        self._viewMgr:showTip(lang("TIP_HERO"))
        return 
    end

    self._viewMgr:showView("hero.HeroView")
end
]]

function TaskView:goView22() 
    if not SystemUtils:enableMF() then
        self._viewMgr:showTip(lang("TIP_MF"))
        return 
    end

    self._viewMgr:showView("MF.MFView")
end

function TaskView:goView23()
    if not SystemUtils:enableCloudCity() then
        self._viewMgr:showTip(lang("TIP_TOWER"))
        return 
    end

    self._viewMgr:showView("cloudcity.CloudCityView")
end

function TaskView:goView24()
    local isOpen,openDes = LeagueUtils:isLeagueOpen()
    if not isOpen then
        self._viewMgr:showTip(openDes)
        return
    end
    self._viewMgr:showView("league.LeagueView")
end
--[[
function TaskView:goView25()
    if not SystemUtils:enablePokedex() then
        self._viewMgr:showTip(lang("TIP_Pokedex"))
        return 
    end

    self._viewMgr:showView("pokedex.PokedexView")
end
]]

function TaskView:goView26()
    if not SystemUtils:enableTeam() then
        self._viewMgr:showTip(lang("TIP_TEAM"))
        return 
    end

    self._viewMgr:showView("team.TeamView")
end


function TaskView:goView27()
    self._viewMgr:showDialog("tencentprivilege.TencentPrivilegeView")
end

-- [[
function TaskView:goView28()
    local isOpen,openDes = LeagueUtils:isLeagueOpen()
    if isOpen then
        self._viewMgr:showView("league.LeagueView")
    else
        self._viewMgr:showTip(openDes)
        --todo
    end
end
--]]

function TaskView:goView29()
    if not SystemUtils:enableTreasure() then
        self._viewMgr:showTip(lang("TIP_Treasure"))
        return 
    end

    self._viewMgr:showView("treasure.TreasureView")
end

function TaskView:goView30()
    if not SystemUtils:enableNests() then
        self._viewMgr:showTip(lang("TIP_Nests"))
        return 
    end

    self._viewMgr:showView("nests.NestsView")
end

function TaskView:goView31()
    if not SystemUtils:enableElement() then
        self._viewMgr:showTip(lang("TIP_elementalPlane"))
        return 
    end

    self._viewMgr:showView("elemental.ElementalView")
end

function TaskView:goView32()
    if not SystemUtils:enableDailySiege() then
        self._viewMgr:showTip(lang("TIP_DailySiege"))
        return 
    end

    -- self._viewMgr:showView("siegeDaily.SiegeDailyView",{utype = 1})
    self._viewMgr:showDialog("siegeDaily.SiegeDailySelectView")
end

-- 圣徽
function TaskView:goView33()
    if not SystemUtils:enableHoly() then
        self._viewMgr:showTip(lang("TIP_Runes"))
        return 
    end
    self._viewMgr:showView("team.TeamHolyView", {})
end

function TaskView:onButtonGetClicked(taskData)
    --print("onButtonGetClicked")
    -- [[体力超3000不让领取体力 by guojun 2016.8.23 
    if taskData.award and #taskData.award == 1 and taskData.award[1][1] == "physcal" then
        local physcal = self._modelMgr:getModel("UserModel"):getData().physcal 
        if physcal >= 3000 then
            self._viewMgr:showTip("体力接近上限，请去扫荡副本")
            return 
        end
    end
    --]]

    local sendServer = function ()
        local context = { taskId = taskData.id }
        if taskData.type == TaskView.kViewTypePrimaryLine then
            self._serverMgr:sendMsg("TaskServer", "mainTaskReward", context, true, {}, function(success, resultData)
                if not success then 
                    --[[
                    self._viewMgr:showTip(lang("TIP_LINGQUGUOQI"))
                    self._taskModel:updateMainTaskData({
                        task = {
                            mainTasks = {
                                [tostring(taskData.id)] = {
                                    status = -1
                                }
                            }
                        }
                    }, true)
                    self._tasks._data = self:initTaskData()
                    self._primaryLineDirty = true
                    self:updateUI(self.kViewTypePrimaryLine)
                    ]]
                    self._viewMgr:showTip(lang("TIP_LINGQUGUOQI"))
                    self:doRequestData()
                    return 
                end
                if self.showRewardDialog == nil then return end
                self:showRewardDialog(taskData, resultData)
                if not (self._tasks and self.initTaskData and self.updateUI) then return end
                self._tasks._data = self:initTaskData()
                self._primaryLineDirty = true
                self:updateUI(self.kViewTypePrimaryLine)
            end)
        elseif taskData.type == TaskView.kViewTypeEveryday or 3 == taskData.type then
            self._serverMgr:sendMsg("TaskServer", "detailTaskReward", context, true, {}, function(success, resultData)
                if not success then 
                    --[[
                    self._viewMgr:showTip(lang("TIP_LINGQUGUOQI"))
                    self._taskModel:updateDetailTaskData({
                        task = {
                            detailTasks = {
                                [tostring(taskData.id)] = {
                                    status = -1
                                }
                            }
                        }
                    }, true)
                    self._tasks._data = self:initTaskData()
                    self._everyDayDirty = true
                    self:updateUI(self.kViewTypeEveryday)
                    ]]
                    self._viewMgr:showTip(lang("TIP_LINGQUGUOQI"))
                    self:doRequestData()
                    return 
                end
                self:showRewardDialog(taskData, resultData.d,resultData.awards)
                if not (self._tasks and self.initTaskData and self.updateUI) then return end
                self._tasks._data = self:initTaskData()
                self._everyDayDirty = true
                self:updateUI(self.kViewTypeEveryday)
            end)
        end
    end

    dump(taskData, "taskData==", 10)
    if taskData and taskData.conditiontype == 201 then
        local isMaxLevel = self._userModel:isMaxLevel()
        if isMaxLevel then
            local expNum = 0
            local reward = taskData.award
            for _,data in pairs (reward) do 
                if data[1] == "exp" then
                    expNum = data[3]
                    break
                end
            end
            if expNum > 0 then
                local des = lang("JINGYANYICHU_ZHUANHUA")
                des = string.gsub(des, "{$num1}", expNum)
                des = string.gsub(des, "{$num2}", expNum)
                des = string.gsub(des, "645252", "3c2a1e")
                print(des, expNum)
                self._viewMgr:showDialog("global.GlobalSelectDialog",
                    {desc = des,
                    alignNum = 1,
                    callback1 = function ()
                        sendServer()
                    end,
                    callback2 = function()

                    end},true)
                return
            end
        end
    end
    sendServer()
end

function TaskView:onButtonCheckClicked()
    print("TaskView:onButtonCheckClicked")
    if not self._awakingModel:isAwakingTaskOpened() then return end
    local param = {teamId = self._awakingTaskData.teamId, showtype = 2}
    self._viewMgr:showDialog("team.TeamAwakenShowDialog", param)
end

function TaskView:onButtonGiveUpClicked()
    local giveUp = function()
        self._serverMgr:sendMsg("AwakingServer", "abandonAwakingTask", {}, true, {}, function(success, resultData)
            if not success then return end
            self._tasks._data = self:initTaskData()
            self._viewType = nil
            self:switchTag(self:getCurrentTag(), true)
        end)
    end

    self._viewMgr:showSelectDialog(lang("AWAKING_TIPS_3"), "", function()
        giveUp()
    end, "")
end

function TaskView:onButtonAwakingFinishClicked()
    self._serverMgr:sendMsg("AwakingServer", "finishAwakingTask", {}, true, {}, function(success, resultData)
        if not success then return end
        self._tasks._data = self:initTaskData()
        self._awakingDirty = true
        self:updateUI(self.kViewTypeAwaking)
        self._refreshTaskMC:addEndCallback(function()
            self._refreshTaskMC:stop()
            self._refreshTaskMC:setVisible(false)
        end)
        self._refreshTaskMC:gotoAndPlay(0)
        self._refreshTaskMC:setVisible(true)
    end)
end

function TaskView:onButtonGoAwakingClicked()
    if not self._awakingModel:isAwakingTaskOpened() then return end
    if 4 ~= self._awakingTaskData.progress then return end
    local teamData = self._teamModel:getTeamAndIndexById(self._awakingTaskData.teamId)
    if not teamData then return end
    self._viewType = nil
    self._viewMgr:getInstance():switchView("team.TeamView",{team = teamData, index = 1})
end

function TaskView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

return TaskView