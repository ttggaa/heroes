--
-- Author: huangguofang
-- Date: 2016-09-29 14:43:50
-- Description:训练所任务列表界面(初级，精英)

local TrainingTaskView = class("TrainingTaskView",BasePopView)
function TrainingTaskView:ctor(data)
    self.super.ctor(self)
    -- self.initAnimType = 1
    self._parent = data.parent
    self._trainType = data.trainType or 1
    self._goStageIdx = data.goStageIdx
    self._isFromAc = data.isFromAc
    -- print("================================trainTypetrainType==",self._trainType)
    self._trainingModel = self._modelMgr:getModel("TrainingModel")
    self._rankModel = self._modelMgr:getModel("RankModel")
    self._acModel = self._modelMgr:getModel("ActivityModel")
    self._userModel = self._modelMgr:getModel("UserModel")

end
function BasePopView:getMaskOpacity()
    return 150
end
-- 初始化UI后会调用, 有需要请覆盖
function TrainingTaskView:onInit()

    -- 高级解锁动画是否播放完
    local isAnim = SystemUtils.loadAccountLocalData("trainUnlockAnim")
    if not isAnim then
        SystemUtils.saveAccountLocalData("trainUnlockAnim",self._trainingModel:isSeniorOpen())
    end

    self._detailPanel_Ac = self:getUI("bg.detail_panel_activity")
    self._detailPanel_Ac:setVisible(false)

    self._beforePanel_Ac = self:getUI("bg.beforeLivePanel")
    self._beforePanel_Ac:setVisible(false)

    if self._trainType == 3 then
        self:initActivityData()
        -- self._isBeforeLive = false
        -- self._isLiving = false
        -- self._isAcOpen = true
        if self._isBeforeLive then
            self:initLivePanel()
        end
        local rankPanel = self._detailPanel_Ac:getChildByFullName("rankPanel")
        if rankPanel then
            rankPanel:setVisible(self._isAcOpen)
        end
    end

    -- user level 
    self._userLvl = self._userModel:getPlayerLevel()
    self._userLvl = tonumber(self._userLvl)
    self._trainBtn = {}
    self._currBtn = 1
    -- 是否是战后
    self._isAfterBattle = false
    -- 首次开界面
    self._isFirst = true
    self._titleBgImg = {
        [1] = "trainigView_junior_bg.png",
        [2] = "trainigView_middle_bg.png",
        [3] = "trainigView_senior_bg.png"
    }
    self._titleText = {
        [1] = "新兵训练营",
        [2] = "精英训练营",
        [3] = "皇家演练场"
    }
    self._roleName = {
        [1] = "新兵训练官",
        [2] = "精英训练官",
        [3] = "皇家训练官"
    }
    self._seniorEvaluateImg = {
        [1] = "globalImgUI_pingjia4.png",
        [2] = "globalImgUI_pingjia3.png",
        [3] = "globalImgUI_pingjia2.png",
        [4] = "globalImgUI_pingjia1.png",
        [5] = "globalImgUI_pingjia1.png",
    }

    self._seniorCupImg = {
        [1] = "trainingView_senior_cupCopper.png",
        [2] = "trainingView_senior_cupSliver.png",
        [3] = "trainingView_senior_cupGolden.png",
        [4] = "trainingView_senior_cupWG.png",
    }

    self._tipsColor = {
        [1] = cc.c4b(153,153,153,255),
        [2] = cc.c4b(14,198,0,255),
        [3] = cc.c4b(0,104,220,255),  
        [4] = cc.c4b(168,13,213,255),
        [5] = cc.c4b(255,126,0,255),
        [6] = cc.c4b(221,164,42,255) 
    }

    local roleName = self:getUI("bg.detail_panel.roleNameBg.roleName")
    roleName:setString(self._roleName[self._trainType])
    roleName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    -- 动画用
    self._initLeftPoint = cc.p(230,320)
    self._initRightPoint = cc.p(380,128)
    self._initDownPoint = cc.p(0,-232)

    self._bg = self:getUI("bg")
    -- 左边的panel
    self._leftBg = self:getUI("bg.tableviewBg")
    -- self._leftBg:setPosition(self._bg:getContentSize().width*0.5, self._bg:getContentSize().height*0.5)

    self._detailPanel = self:getUI("bg.detail_panel")
    
    -- print("=========self._titleBgImg[self._trainType]=====",self._titleBgImg[self._trainType])
    self._detailPanel:setBackGroundImage(self._titleBgImg[self._trainType],1)

    -- 训练描述
    --tipsbg
    self._titleBg = self:getUI("bg.detail_panel.titleBg")
    local titleBg = self._titleBg:getChildByFullName("titleBg")
    titleBg:setContentSize(188,80)
    --奖励面板
    self._awardPanel = self:getUI("bg.detail_panel.awardPanel")
    self._awardGetImg = self:getUI("bg.detail_panel.awardPanel.getImg")

    self._closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEventByName("bg.closeBtn", function(  )        
        if self._livingTimer then
            ScheduleMgr:unregSchedule(self._livingTimer)
            self._livingTimer = nil
        end
        if self._acTimer then
            ScheduleMgr:unregSchedule(self._acTimer)
            self._acTimer = nil
        end
        if self._parent then
            if self._parent.clearTaskNode then 
                self._parent:clearTaskNode()  
            end
            if self._isFromAc then    
                self._trainingModel:setIgnoreGuide(false)
                self._parent:close()
            end
        end
        if self.close then
            self:close()
        end
        -- self._parent:unlockSeniorAnim()
        UIUtils:reloadLuaFile("training.TrainingTaskView")
    end)
    -- self._closeBtn:setEnabled(false)

    local tableNode1 = self:getUI("bg.tableviewBg.tableNode") 
    tableNode1:setVisible(true)

    local seniorPanel = self:getUI("bg.tableviewBg.seniorPanel")
    seniorPanel:setVisible(false)
	self._tableNode = tableNode1  
    
    self._starPanel = self:getUI("bg.tableviewBg.seniorPanel.starPanel") 
    self._starPanel:setSwallowTouches(false)

    if 3 == self._trainType then
        tableNode1:setVisible(false)
        seniorPanel:setVisible(true)
        local tableNode3 = self:getUI("bg.tableviewBg.seniorPanel.tableNode") 
        self._tableNode = tableNode3
        self:initSeniorPanel()
    end

    -- self:listenReflash("TrainingModel", self.reflashUI)
    -- ScheduleMgr:delayCall(300, self, self.viewAnimBegin)
    self._rankList = {}
    self:initDetailPanelActicity()

    local nameImg = self:getUI("bg.detail_panel_activity.nameImg")
    nameImg:setVisible(false)
end

function TrainingTaskView:initActivityData()
    -- 直播时间
    local acShowList   = self._acModel:getActivityShowList()
    local currTime     = self._userModel:getCurServerTime()
    currTime = tonumber(currTime)
    local liveID = 30001
    local acID = 30002
    -- 直播开始时间
    local liveData

    -- 活动结束时间
    local acData 
    for k,v in pairs(acShowList) do
        if tonumber(v.activity_id) == tonumber(liveID) then
            liveData = v
        end
        if tonumber(v.activity_id) == tonumber(acID) then
            acData = v
        end
    end

    -- 直播前
    self._isBeforeLive = false
    -- 直播是否结束结束
    self._isLiving = false
    if liveData then
        self._liveStarTime = tonumber(liveData.start_time)
        self._liveEndTime = tonumber(liveData.end_time)
        if currTime < self._liveStarTime then
          self._isBeforeLive = true
        end
        if currTime >= self._liveStarTime and currTime < self._liveEndTime then
            self._isLiving = true
        end
    end

    -- 活动是否结束(包含直播时间)
    self._isAcOpen = false
    if acData then
        --appear_time  --disappear_time
        self._acStartTime = tonumber(acData.start_time)
        self._acEndTime = tonumber(acData.end_time)
        self._acDisappearTime = tonumber(acData.disappear_time)
        if currTime >= self._acStartTime and currTime < self._acEndTime then
            self._isAcOpen = true
        end
    end

end
--初始化直播面板
function TrainingTaskView:initLivePanel( )
    local timeTxt = self._beforePanel_Ac:getChildByFullName("timeTxt")
    timeTxt:setString(lang("TRAINING_ACTIVITY_SHOW_3"))
    timeTxt:setColor(cc.c4b(255,241,207,255))
    timeTxt:enable2Color(1,cc.c4b(122,95,66,255))

    for i=1,4 do
        local desTxt = self._beforePanel_Ac:getChildByFullName("desTxt" .. i)
        local str = lang("TRAINING_ACTIVITY_LANG_" .. i)
        desTxt:setString(str)
    end
   
end
--初始化活动详情面板
function TrainingTaskView:initDetailPanelActicity( )
    local roleName = self:getUI("bg.detail_panel_activity.roleNameBg.roleName")
    roleName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    local livingPanel = self:getUI("bg.detail_panel_activity.livingPanel")
    local afterPanel = self:getUI("bg.detail_panel_activity.afterPanel")
    livingPanel:setSwallowTouches(false)
    afterPanel:setSwallowTouches(false)
    local infoPanel = self:getUI("bg.detail_panel_activity.afterPanel.infoPanel")
    local selfIcon  = infoPanel:getChildByFullName("selfIcon")
    local nameTxt   = infoPanel:getChildByFullName("nameTxt")
    local scoreDes  = infoPanel:getChildByFullName("scoreDes")
    local scoreTxt  = infoPanel:getChildByFullName("scoreTxt")
    local userInfo = self._userModel:getData()
    local icon = IconUtils:createHeadIconById({avatar = userInfo.avatar,tp = 4, isSelf = true, eventStyle=0})   --,tp = 2
    icon:setScale(0.6)
    icon:setPosition(10, 5)
    selfIcon:addChild(icon)
    nameTxt:setString(userInfo.name or "")
    nameTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    scoreDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    scoreTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    scoreTxt:setColor(UIUtils.colorTable.ccUIBaseColor2)
    scoreDes:setString("时间")

    local HIcon  = infoPanel:getChildByFullName("HIcon")
    local HnameTxt   = infoPanel:getChildByFullName("HnameTxt")
    local HscoreDes  = infoPanel:getChildByFullName("HscoreDes")
    local HscoreTxt  = infoPanel:getChildByFullName("HscoreTxt")
    local icon = IconUtils:createHeadIconById({avatar = 1101,tp = 4, eventStyle=0})   --,tp = 2
    local iconColor = icon:getChildByFullName("iconColor")
    iconColor:loadTexture("globalImageUI4_heroBg1.png",1)
    local headIcon = iconColor:getChildByFullName("headIcon")
    headIcon:loadTexture("trainingView_ac_head.png",1)
    icon:setScale(0.6)
    icon:setPosition(10, 5)
    HIcon:addChild(icon)
    HnameTxt:setString("黄执中")
    HnameTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    HscoreDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    HscoreTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    HscoreTxt:setColor(UIUtils.colorTable.ccUIBaseColor2)
    HscoreDes:setString("时间")

    local afterPanel = self:getUI("bg.detail_panel_activity.afterPanel")
    local des1      = afterPanel:getChildByFullName("des1")
    local num       = afterPanel:getChildByFullName("num")
    local des2      = afterPanel:getChildByFullName("des2")
    local rankPanel = self:getUI("bg.detail_panel_activity.rankPanel")
    local serverName1  = rankPanel:getChildByFullName("serverName1")
    local serverName2  = rankPanel:getChildByFullName("serverName2")
    local serverName3  = rankPanel:getChildByFullName("serverName3")
    -- serverName1:setTextAreaSize(cc.size(80,21))
    -- serverName2:setTextAreaSize(cc.size(80,21))
    -- serverName3:setTextAreaSize(cc.size(80,21))
    local rankName1  = rankPanel:getChildByFullName("rankName1")
    local rankName2  = rankPanel:getChildByFullName("rankName2")
    local rankName3  = rankPanel:getChildByFullName("rankName3")
    local scoreTxt1  = rankPanel:getChildByFullName("scoreTxt1")
    local scoreTxt2  = rankPanel:getChildByFullName("scoreTxt2")
    local scoreTxt3  = rankPanel:getChildByFullName("scoreTxt3")
    local score1  = rankPanel:getChildByFullName("score1")
    local score2  = rankPanel:getChildByFullName("score2")
    local score3  = rankPanel:getChildByFullName("score3")

    local rankTxt = rankPanel:getChildByFullName("rankTxt")
    serverName1:setString("")
    serverName2:setString("")
    serverName3:setString("")
    rankName1:setVisible(false)
    rankName2:setVisible(false)
    rankName3:setVisible(false)
    scoreTxt1:setVisible(false)
    scoreTxt2:setVisible(false)
    scoreTxt3:setVisible(false)
    score1:setVisible(false)
    score2:setVisible(false)
    score3:setVisible(false)
    num:setString("")

    scoreTxt1:setString("时间")
    scoreTxt2:setString("时间")
    scoreTxt3:setString("时间")

    des1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    num:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    des2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    serverName1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    serverName2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    serverName3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    rankName1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    rankName2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    rankName3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    scoreTxt1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    scoreTxt2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    scoreTxt3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    score1:setColor(UIUtils.colorTable.ccUIBaseColor2)
    score2:setColor(UIUtils.colorTable.ccUIBaseColor2)
    score3:setColor(UIUtils.colorTable.ccUIBaseColor2)
    score1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    score2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    score3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    rankTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

    -- 排行榜
    self:registerClickEventByName("bg.detail_panel_activity.rankPanel.rankBtn", function()   
        self:trainShowRankDialog()
    end)
    -- 排行榜
    self:registerClickEventByName("bg.detail_panel_activity.rankPanel.bgimg", function() 
        self:trainShowRankDialog()
    end)

    local liveBtn = self:getUI("bg.detail_panel_activity.livingPanel.liveBtn")
    liveBtn:setPosition(liveBtn:getPositionX()-20,liveBtn:getPositionY()-10)
    local btnTxt = self:getUI("bg.detail_panel_activity.livingPanel.liveBtn.title")
    btnTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    -- 直播按钮
    self:registerClickEventByName("bg.detail_panel_activity.livingPanel.liveBtn", function()    
        local trainUrl = self._trainingModel:getTrainLiveUrl()
        if not trainUrl then
            self._serverMgr:sendMsg("TrainingServer", "getTrainingShowURL", {}, true, {}, function(result) 
                trainUrl = result and result.showURL or nil
                if trainUrl then
                    print("==看个直播11===",trainUrl)
                    sdkMgr:loadUrl({url = trainUrl})
                end
            end)
        else
            print("==看个直播22===",trainUrl)
            sdkMgr:loadUrl({url = trainUrl})
        end
        
    end)
end

function TrainingTaskView:trainShowRankDialog()
    if not self._currBtn or not self._tableData then return end
    if not self._isAcOpen then return end
        local tData = self._tableData[self._currBtn] or {}
        self._rankModel:setRankTypeAndStartNum(9,1)
        self._serverMgr:sendMsg("TrainingServer", "getTrainingRankByTrainId", {id=tData.id,startRank = 1}, true, {}, function(result) 
            -- 更新rankList 前三数据
            -- dump(result,"result==>",5)
            local listData = result.rankList
            if listData then
                table.sort(listData,function (a,b)
                    return a.rank < b.rank
                end)
            end
            local Hscore = result and result.targetScore or nil
            local currTime = self._userModel:getCurServerTime()
            local isAwardShow = self._acDisappearTime and (currTime < self._acDisappearTime)
            --   trainData = tData
            self._viewMgr:showDialog("training.TrainingRankDialog",{stageId = tData.id,liveEndTime = self._liveEndTime,endTime = self._acEndTime,Hscore = Hscore,isAcOpen=isAwardShow,callback = function()       
                -- 更新训练场前三显示
                if self._rankList[tData.id] and self._rankList[tData.id].rankList and listData then
                    for i=1,3 do
                        if listData[i] then
                            self._rankList[tData.id].rankList[i] = listData[i]
                        end
                    end
                    self:updateRankListPanel(tData)
                end
            end})
        end)
end
--初始化高级训练所面板
function TrainingTaskView:initSeniorPanel()
    local seniorPanel = self:getUI("bg.tableviewBg.seniorPanel")
    local ruleBtn = self:getUI("bg.tableviewBg.seniorPanel.ruleBtn")
    registerClickEvent(ruleBtn,function(sender) 
        -- print("=============奖杯规则==================")
        self._viewMgr:showDialog("training.TrainingCupRuleDialog")
    end)

    self._noCupTxt = self:getUI("bg.tableviewBg.seniorPanel.noCupTxt")
    self._noCupTxt:setString("暂未获得评价")
    self._noCupTxt:setAnchorPoint(0,0.5)
    self._noCupTxt:setPositionX(30)
    self._cupTxt = self:getUI("bg.tableviewBg.seniorPanel.cupTxt")
    self._cupTxt:setPositionX(30)

    self._cupTxt:setFontName(UIUtils.ttfName)
    -- self._cupTxt:setColor(cc.c3b(250,242,192))
    -- self._cupTxt:enable2Color(1, cc.c3b(255, 195, 17))
    
    --奖杯
    self._cupImg = self:getUI("bg.tableviewBg.seniorPanel.cupImg")

end
-- 个更新高级奖杯显示
function TrainingTaskView:updateSeniorPanel()

    -- 获取高级训练所的奖杯数据       
    self._starPanel = self:getUI("bg.tableviewBg.seniorPanel.starPanel") 
    local sNum = self._trainingModel:getScoreSNum(3)
    local starNum = sNum % 3

    for i=1,3 do
        local star = self._starPanel:getChildByFullName("star" .. i)
        if i <= starNum then
            star:setVisible(true)
        else
            star:setVisible(false)
        end
    end

    --奖杯数据
    local cupData = self._trainingModel:getCupDataBuySNum()
    -- dump(cupData,"cupDat==>")
    self._cupImg = self:getUI("bg.tableviewBg.seniorPanel.cupImg")

    if sNum == 0 then
        -- self._starPanel:setVisible(false)
        self._cupImg:loadTexture("trainingView_senior_cupEmpty.png",1)
    else
        -- 零星的时候不显示星星
        -- self._starPanel:setVisible(not (starNum == 0))          
        local cupData = self._trainingModel:getCupDataBuySNum()    
        if cupData then
            if cupData.art and cupData.art ~= "" then
                self._cupImg:loadTexture(cupData.art)
            else
                -- print("===============self._seniorCupImg[cupData.id]==",self._seniorCupImg[cupData.id])
                self._cupImg:loadTexture(self._seniorCupImg[cupData.id],1)
            end
        end
    end 
    
end

function TrainingTaskView:addBtnScrollView()

    self._scrollView = self._tableNode:getChildByFullName("scrollView")
    self._scrollView:removeAllChildren()
    local width = self._scrollView:getContentSize().width
    local height = self._scrollView:getContentSize().height
    -- print("=================addBtnScrollView==============================")
    -- 添加scrollView
    -- self._scrollView = cc.ScrollView:create() 
    -- self._scrollView:setViewSize(cc.size(width, height))
    -- self._scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置滚动方向
    -- self._scrollView:setClippingEnabled(true)
    -- self._scrollView:setBounceable(true)
    -- self._scrollView:setPosition(0, 8)
    -- self._tableNode:addChild(self._scrollView,2)
   
    self._scrollView:setBounceEnabled(true)
    self._scrollView:setPosition(0, 8)

    local itemW = 274
    local itemH = 60
    local itemNum = #self._tableData

    -- 计算滚动区域的大小
    local posY = 0
    local maxHeight = itemH * itemNum 
    if self._isBeforeLive  then
        maxHeight = maxHeight + itemH
    end
    maxHeight = maxHeight > height and maxHeight or height+2
    self._scrollView:setInnerContainerSize(cc.size(width, maxHeight))

    local nums = table.nums(self._tableData)
    local i = 1
    for k,v in pairs(self._tableData) do
        -- 直播前预告关
        if self._isBeforeLive and i == nums then
            -- print("==================明星关卡=================")
            -- 添加直播预告btn
            local newItem = self:createItem3(v,i)
            newItem._nameTxt:setString(lang("TRAINING_ACTIVITY_YUGAO"))
            newItem._index = i
            newItem._isNewItem = true
            registerClickEvent(newItem,function(sender) 
                if self._currBtn == sender._index then return end
                self._currBtn = sender._index
                self:changeBtnState(self._currBtn)
                self:updateAcPanel1()

            end)
            posY = maxHeight - i*itemH
            newItem:setPosition(cc.p(8,posY))
            self._scrollView:addChild(newItem)
            self._trainBtn[i] = newItem
            i = i + 1
        end
        local item 
        -- if不是高级
        if self._trainType ~= 3 then
            item = self:createItem(v,i)
        else
            item = self:createItem3(v,i)
        end
        posY = maxHeight - i*itemH
        item:setPosition(cc.p(8,posY))
        self._scrollView:addChild(item)
        item._index = i

        self._trainBtn[i] = item
       
        registerClickEvent(item,function(sender) 
            if self._currBtn == sender._index then return end
            self._currBtn = sender._index
            self:changeBtnState(self._currBtn)
            self:updateDetailPanel(v)           

            -- self:updateScrollViewPos()
        end)
        i = i + 1

    end
    -- self._scrollView:setContentOffset(cc.p(0 ,height - maxHeight), false)

end

--创建item
function TrainingTaskView:createItem(data,idx)
	if not data then return end
	local layout = ccui.Layout:create()
	layout:setAnchorPoint(cc.p(0,0))
	layout:setContentSize(cc.size(249, 56))
    -- layout:setTouchEnabled(true)
    -- layout:setSwallowTouches(true)
	-- layer:setBackGroundImage(self._titleBgImg[self._trainType],1)	

    -- 背景
    local bgImg = ccui.ImageView:create()
    bgImg:loadTexture("trainigView_trainBtn_normal.png",1)
    bgImg:setAnchorPoint(cc.p(0,0))
    bgImg:setPosition(7, 0)
    bgImg:setName("bgImg")
    layout._bgImg = bgImg
    -- bgImg:setContentSize(cc.size(276,76))
    -- bgImg:setScale9Enabled(true)
    -- bgImg:setCapInsets(cc.rect(100,38,1,1))
    layout:addChild(bgImg)

    -- local layer = cc.LayerColor:create(cc.c4b(100,100,100,255))
    -- 未通图片
    local noPassTxt = ccui.Text:create()
    noPassTxt:setFontSize(18)
    noPassTxt:setFontName(UIUtils.ttfName)
    noPassTxt:setString("挑战")
    noPassTxt:setColor(cc.c4b(60,40,30,255))
    noPassTxt:setAnchorPoint(cc.p(1,0.5))
    noPassTxt:setPosition(layout:getContentSize().width - 20,layout:getContentSize().height/2)
    noPassTxt:setOpacity(255*0.7)
    layout:addChild(noPassTxt,3)
    noPassTxt:setName("noPassTxt")
    layout._noPassTxt = noPassTxt
    noPassTxt:setVisible(false)

    local img = ccui.ImageView:create()
    img:loadTexture("trainingVew_button_goImg.png",1)
    img:setAnchorPoint(cc.p(0,0.5))
    img:setPosition(noPassTxt:getContentSize().width + 5,noPassTxt:getContentSize().height*0.5)
    noPassTxt:addChild(img)
    if data.level and self._userLvl < tonumber(data.level) then
        img:setVisible(false)
        noPassTxt:setPositionX(layout:getContentSize().width - 10)
        noPassTxt:setString(data.level .. "级开启")
    end

    --已通标志  未通图片 
    local passImg = ccui.ImageView:create()
    passImg:loadTexture("training_pass.png",1)
    passImg:setAnchorPoint(cc.p(0.5,0.5))
    -- passImg:setRotation(30)
    passImg:setName("passImg")
    layout._passImg = passImg
    passImg:setPosition(layout:getContentSize().width - 30,layout:getContentSize().height/2)
    passImg:setVisible(false)
    layout:addChild(passImg)    

    --红点
    local redImg = ccui.ImageView:create()
    redImg:loadTexture("globalImageUI_bag_keyihecheng.png",1)
    redImg:setAnchorPoint(cc.p(0.5,0.5))
    redImg:setName("redImg")
    layout._redImg = redImg
    redImg:setPosition(15,layout:getContentSize().height-10)
    redImg:setVisible(false)
    layout:addChild(redImg,5) 

    local nameTxt = ccui.Text:create()
    nameTxt:setFontSize(20)
    nameTxt:setFontName(UIUtils.ttfName)
    nameTxt:setString(lang(data.name))
    layout._nameTxt = nameTxt
    -- cc.c4b(60,40,30,255)
    nameTxt:setColor(cc.c4b(60,40,30,255))
    -- nameTxt:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
    nameTxt:setAnchorPoint(cc.p(0,0.5))
    nameTxt:setPosition(50, layout:getContentSize().height*0.5)
    layout:addChild(nameTxt,3)
    
    -- 名字前的小标志
    local tipsColor = data.color or 8
    tipsColor = tonumber(tipsColor) > 8 and 8 or tipsColor
    local flagImg = ccui.ImageView:create()
    flagImg:loadTexture("trainingView_button_flag" .. tipsColor .. ".png",1)
    flagImg:setAnchorPoint(cc.p(0,0.5))
    flagImg:setColor(cc.c4b(60,40,30,255))
    flagImg:setPosition(15, layout:getContentSize().height*0.5)
    layout:addChild(flagImg)
    layout._flagImg = flagImg

    -- 默认显示第一个
    if self._currBtn == idx then
        bgImg:loadTexture("trainigView_trainBtn_selected.png",1)
        noPassTxt:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
        nameTxt:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
        flagImg:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
    end
    if 0 == data.state then
        noPassTxt:setVisible(true)
    elseif 1 == data.state then
        passImg:setVisible(true) 
        redImg:setVisible(true)         
    elseif 2 == data.state then
        --todo
        passImg:setVisible(true)               
    end

	return layout
	
end

--创建item
function TrainingTaskView:createItem3(data,idx)
    if not data then return end
    local layout = ccui.Layout:create()
    layout:setAnchorPoint(cc.p(0,0))
    layout:setContentSize(cc.size(249, 56))
    -- layout:setTouchEnabled(true)
    -- layout:setSwallowTouches(true)
    -- layer:setBackGroundImage(self._titleBgImg[self._trainType],1)    

    -- 背景
    local bgImg = ccui.ImageView:create()
    bgImg:loadTexture("trainigView_trainBtn_normal.png",1)
    bgImg:setAnchorPoint(cc.p(0,0))
    bgImg:setPosition(7, 0)
    bgImg:setName("bgImg")
    layout._bgImg = bgImg
    -- bgImg:setContentSize(cc.size(276,76))
    -- bgImg:setScale9Enabled(true)
    -- bgImg:setCapInsets(cc.rect(100,38,1,1))
    layout:addChild(bgImg)

    -- local layer = cc.LayerColor:create(cc.c4b(100,100,100,255))

    -- flower
    local flower = ccui.ImageView:create()
    flower:loadTexture("trainingView_flawer.png",1)
    flower:setAnchorPoint(cc.p(1,0.5))
    flower:setName("flower")
    layout._flower = flower
    flower:setVisible(false)
    flower:setPosition(layout:getContentSize().width,layout:getContentSize().height/2)
    layout:addChild(flower)  

    -- 未通文字
    local noPassTxt = ccui.Text:create()
    noPassTxt:setFontSize(16)
    noPassTxt:setFontName(UIUtils.ttfName)
    noPassTxt:setString("暂无评分")
    noPassTxt:setName("noPassTxt")    
    layout._noPassTxt = noPassTxt
    noPassTxt:setColor(cc.c4b(128,85,38,255))
    noPassTxt:setAnchorPoint(cc.p(0.5,0.5))
    noPassTxt:setOpacity(255*0.7)
    noPassTxt:setPosition(layout:getContentSize().width - 43,layout:getContentSize().height/2)
    layout:addChild(noPassTxt,3)

    if data.level and self._userLvl < tonumber(data.level) then
        noPassTxt:setString(data.level .. "级开启")
    end

    --已通标志
    local evaluateData = self._trainingModel:getEvaluateDataByScore(data.score or 0)
    local passImg = ccui.ImageView:create()
    passImg:loadTexture(self._seniorEvaluateImg[tonumber(evaluateData.evaluate)],1)
    passImg:setAnchorPoint(cc.p(0.5,0.5))
    passImg:setName("passImg")
    passImg:setScale(0.8)
    layout._passImg = passImg
    passImg:setPosition(layout:getContentSize().width - 40,layout:getContentSize().height/2)
    layout:addChild(passImg,2)    

    --红点
    local redImg = ccui.ImageView:create()
    redImg:loadTexture("globalImageUI_bag_keyihecheng.png",1)
    redImg:setAnchorPoint(cc.p(0.5,0.5))
    redImg:setName("redImg")
    layout._redImg = redImg
    redImg:setPosition(15,layout:getContentSize().height-10)
    layout:addChild(redImg,5) 

    local nameTxt = ccui.Text:create()
    nameTxt:setFontSize(20)
    nameTxt:setFontName(UIUtils.ttfName)
    nameTxt:setString(lang(data.name))
    nameTxt:setColor(cc.c4b(60,40,30,255))
    nameTxt:setAnchorPoint(cc.p(0,0.5))
    nameTxt:setPosition(50, layout:getContentSize().height*0.5)
    layout:addChild(nameTxt,3)
    layout._nameTxt = nameTxt

    -- 名字前的小标志
    local tipsColor = data.color or 8
    tipsColor = tonumber(tipsColor) > 8 and 8 or tipsColor
    local flagImg = ccui.ImageView:create()
    flagImg:loadTexture("trainingView_button_flag" .. tipsColor .. ".png",1)
    flagImg:setAnchorPoint(cc.p(0,0.5))
    flagImg:setColor(cc.c4b(60,40,30,255))
    flagImg:setPosition(15, layout:getContentSize().height*0.5)
    layout:addChild(flagImg)
    layout._flagImg = flagImg

    -- 默认显示第一个
    if self._currBtn == idx then
        bgImg:loadTexture("trainigView_trainBtn_selected.png",1)        
        noPassTxt:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
        nameTxt:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
        flagImg:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
    end
    -- 0 未通 1 未领 2 已通
    if 0 == data.state then
        noPassTxt:setVisible(true)
        passImg:setVisible(false) 
        redImg:setVisible(false) 
        flower:setVisible(true)
    elseif 1 == data.state then
        noPassTxt:setVisible(false)
        passImg:setVisible(true) 
        redImg:setVisible(true)         
    elseif 2 == data.state then
        --todo
        passImg:setVisible(true)               
        redImg:setVisible(false) 
        noPassTxt:setVisible(false)
    end

    if data.cType and data.cType == 3 then
        noPassTxt:setVisible(false)
        passImg:setVisible(false) 
        redImg:setVisible(false) 
        flower:setVisible(false)
    end

    return layout
    
end

function TrainingTaskView:updateCurrLeftBtn(index)
    if not index then return end 

    local data = self._tableData[index]
    local item = self._trainBtn[index]

    if not data or not item then return end 

    -- 活动预告关卡 不需要刷新
    if item._isNewItem then return end

    --已通标志
    local passImg = item:getChildByFullName("passImg")
    passImg:setVisible(false)
    if 3 == self._trainType then        
        local evaluateData = self._trainingModel:getEvaluateDataByScore(data.score or 0)
        passImg:loadTexture(self._seniorEvaluateImg[tonumber(evaluateData.evaluate)],1)
    end

    local redImg = item._redImg
    redImg:setVisible(false)

    -- 初级 精英
    local noPassTxt = item._noPassTxt    
    if noPassTxt then
        noPassTxt:setVisible(false)
    end

    -- 高级
    local flower = item._flower
    if flower then
        flower:setVisible(0 == data.state)
    end
    -- print("===================updateCurrLeftBtn========",data.state)
    -- 0 未通 1 未领 2 已通
    if 0 == data.state then
        if noPassTxt then
            noPassTxt:setVisible(true)
        end
        if noPassTxt then
            noPassTxt:setVisible(true)
        end
    elseif 1 == data.state then              
        passImg:setVisible(true) 
        redImg:setVisible(true)         
    elseif 2 == data.state then
        --todo
        passImg:setVisible(true)               
        redImg:setVisible(false) 
              
    end
end

--按钮更新点击状态
function TrainingTaskView:changeBtnState(idx)
    -- print("=================idx=====",idx)
    for k,layout in pairs(self._trainBtn) do
        if layout then
            layout._bgImg:loadTexture("trainigView_trainBtn_normal.png",1)
            layout._noPassTxt:setColor(cc.c4b(60,40,30,255))
            layout._nameTxt:setColor(cc.c4b(60,40,30,255))
            layout._flagImg:setColor(cc.c4b(60,40,30,255))
        end
    end
    if self._trainBtn[idx] then
        self._trainBtn[idx]._bgImg:loadTexture("trainigView_trainBtn_selected.png",1)
        self._trainBtn[idx]._noPassTxt:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
        self._trainBtn[idx]._nameTxt:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
        self._trainBtn[idx]._flagImg:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
    end
end

function TrainingTaskView:updateDetailPanel(trainData,isFirst)
    -- print("===========================updateDetailPanel=",trainData.id)
    if not trainData then return end
    if self._isBeforeLive then
        local item = self._trainBtn[self._currBtn]
        -- 活动预告关卡 不需要刷新
        if item and item._isNewItem then 
            self:updateAcPanel1()
            if item._isNewItem then return end
        end
    end
    self._detailPanel:setVisible(false)
    self._detailPanel_Ac:setVisible(false)
    self._beforePanel_Ac:setVisible(false)
    if self._shareNode then
        self._shareNode:setVisible(false)
    end
    self._isNeedAnim = true
    if self._trainType == 3 and trainData.cType and trainData.cType == 3 then
        self._detailPanel:setVisible(true)
        self:updateDetailPanelMore(trainData)
    elseif self._trainType == 3 and trainData.cType and trainData.cType == 2 then 
        self._isNeedAnim = false
        -- if not self._rankList[trainData.id] and not self._isBeforeLive then

            self._detailPanel_Ac:setVisible(not self._isBeforeLive)
            self._beforePanel_Ac:setVisible(self._isBeforeLive)
            local livingPanel = self._detailPanel_Ac:getChildByFullName("livingPanel")
            local afterPanel = self._detailPanel_Ac:getChildByFullName("afterPanel")
            livingPanel:setVisible(self._isAcOpen and self._isLiving)
            afterPanel:setVisible(not self._isLiving)
            local acDes = self._detailPanel_Ac:getChildByFullName("afterPanel.acDes")
            local timeLabel = self._detailPanel_Ac:getChildByFullName("afterPanel.timeLabel")
            acDes:setVisible(self._isAcOpen)
            timeLabel:setVisible(self._isAcOpen)
            if self._resultAwardTxt then
                self._resultAwardTxt:setVisible(self._isAcOpen)
            end

            self:sendGetRankListMsg(trainData)
        -- else            
            -- self:updateDetailPanelActivity(trainData)
        -- end
    else
        self._detailPanel:setVisible(true)
        self:updateDetailPanelNormal(trainData)
    end
    if isFirst then
        self._isNeedAnim = false
    end
    -- 气泡动画
    if self._isNeedAnim then 
        self:lock(-1)
        self._titleBg:setOpacity(255)
        self._titleBg:setCascadeOpacityEnabled(true)
        self._titleBg:setScale(0)
        self._titleBg:runAction(cc.Sequence:create(cc.Spawn:create(cc.ScaleTo:create(0.15, 1),cc.FadeIn:create(0.15)),cc.CallFunc:create(function( ... )
            self:unlock()
        end)))
    end

end

-- 请求前三数据
function TrainingTaskView:sendGetRankListMsg(trainData)
    -- 获取排行信息
    if not trainData or not trainData.id then return end
    if self._trainType == 3 and trainData.cType and trainData.cType == 2 then 
        self._serverMgr:sendMsg("TrainingServer", "getTrainingRankList", {id = trainData.id}, true, {}, function(result,succ)
            -- if succ then 
            -- 更新前三数据及前三面板
            self:updaterankListData(result,trainData)
            -- 更新面板显示
            self:updateDetailPanelActivity(trainData)
            -- end
        end)
    end
end

-- 更新前三数据
function TrainingTaskView:updaterankListData(result,trainData)
    -- dump(result,"result==>",5)
    local rankData = result and result.rankList 
    if rankData then
       table.sort(rankData ,function (a,b)
            if a.rank and b.rank then
                return a.rank < b.rank
            else
                return true 
            end
        end)
        if not self._rankList[trainData.id] then
            self._rankList[trainData.id] = {}
        end
        self._rankList[trainData.id].rankList = rankData
        if result.amount then
            self._rankList[trainData.id].amount = result.amount
        end
        if result.targetScore then
            self._rankList[trainData.id].targetScore = result.targetScore
        end

        self:updateRankListPanel(trainData)
    end    

end

function TrainingTaskView:updateDetailPanelMore(trainData)

    local tipsMoreBg = self._titleBg:getChildByFullName("tipsMoreBg") 
    tipsMoreBg:setVisible(true)
    local titleBg = self._titleBg:getChildByFullName("titleBg") 
    titleBg:setVisible(false)
    if self._tipsTxt then 
        self._tipsTxt:removeFromParent()
        self._tipsTxt = nil
    end
    if self._tipsMoreTxt then 
        self._tipsMoreTxt:removeFromParent()
        self._tipsMoreTxt = nil
    end
    if trainData.des then
        local desTxt = lang(trainData.des)
        if string.sub(desTxt,1,1) ~= "[" then
            desTxt = "[color=3c2800]" .. desTxt .."[-]"
        end
        self._tipsMoreTxt = RichTextFactory:create(desTxt,280,88)
        self._tipsMoreTxt:formatText()
        self._tipsMoreTxt:setVerticalSpace(3)
        -- self._tipsMoreTxt:setAnchorPoint(cc.p(0,0.5))
        self._tipsMoreTxt:setPosition(15,tipsMoreBg:getContentSize().height*0.5-5)
        self._titleBg:addChild(self._tipsMoreTxt,100)
    end

    local awardImg = self._awardPanel:getChildByFullName("awardImg") 
    awardImg:loadTexture("trainingView_awardText_bg1.png",1)
    local iconPanel = self._awardPanel:getChildByFullName("awardIcon") 
    iconPanel:setPositionX(60)
    iconPanel:removeAllChildren()
    -- award
    local width = 75
    -- local lenX = (180 - table.nums(data.award) * width) * 0.5 --/(table.nums(data.award) + 1)    
    for i=1,4 do
        local v = trainData.award[i]
        if v then
            local itemId 
            if v[1] == "tool" then
                itemId = v[2]
            else
                itemId = IconUtils.iconIdMap[v[1]]
            end
            local toolD = tab:Tool(tonumber(itemId))
            local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = v[3]})
            icon:setScale(0.7)
            -- icon:settouchs
            icon:setAnchorPoint(cc.p(0,0))
            icon:setPosition(cc.p((i-1)*width,-4))    --lenX + (k-1)*(width+lenX)
            iconPanel:addChild(icon)
        end
    end

    local goBtn = self:getUI("bg.detail_panel.goBtn")
    local getBtn = self:getUI("bg.detail_panel.getBtn") 
    local reviewBtn = self:getUI("bg.detail_panel.reviewBtn")    
    local noCupTxt = self:getUI("bg.tableviewBg.seniorPanel.noCupTxt")
    local getImg = self._awardPanel:getChildByFullName("getImg") 
    goBtn:setVisible(false)
    getBtn:setVisible(false)
    reviewBtn:setVisible(false)
    awardImg:setVisible(true)
    getImg:setVisible(false)
    self._cupTxt:setVisible(false)
    noCupTxt:setVisible(false)
end

function TrainingTaskView:updateDetailPanelNormal(trainData)
    -- print("===========================updateDetailPanel=",trainData.id)
    if not trainData then return end

    local tipsMoreBg = self._titleBg:getChildByFullName("tipsMoreBg") 
    tipsMoreBg:setVisible(false)
    local titleBg = self._titleBg:getChildByFullName("titleBg") 
    titleBg:setVisible(true)
    if self._tipsTxt then 
        self._tipsTxt:removeFromParent()
        self._tipsTxt = nil
    end
    if self._tipsMoreTxt then 
        self._tipsMoreTxt:removeFromParent()
        self._tipsMoreTxt = nil
    end
    if trainData.des then
        local desTxt = lang(trainData.des)
        if string.sub(desTxt,1,1) ~= "[" then
            desTxt = "[color=3c2800]" .. desTxt .."[-]"
        end
        self._tipsTxt = RichTextFactory:create(desTxt,150,48)
        self._tipsTxt:formatText()
        self._tipsTxt:setVerticalSpace(3)
        self._tipsTxt:setAnchorPoint(cc.p(0,0.5))
        self._tipsTxt:setPosition(-65,self._titleBg:getContentSize().height*0.5+5)
        self._titleBg:addChild(self._tipsTxt,100)
    end

    local goBtn = self:getUI("bg.detail_panel.goBtn")
    local getBtn = self:getUI("bg.detail_panel.getBtn") 
    local reviewBtn = self:getUI("bg.detail_panel.reviewBtn")
    -- local mc = getBtn:getChildByFullName("anniuAnim")
    -- if not mc then
    --     mc = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true,false)
    --     mc:setName("anniuAnim")
    --     mc:setPosition(getBtn:getContentSize().width/2-2, getBtn:getContentSize().height/2)
    --     getBtn:addChild(mc,10)
    -- end

    registerClickEvent(getBtn,function(sender) 
        self:getTrainingAward(trainData.id)
    end)
    registerClickEvent(goBtn,function(sender) 
        if tonumber(self._userLvl) < tonumber(trainData.level) then
            self._viewMgr:showTip("玩家" .. trainData.level .. "级开启挑战")
        else
            self:goToFormation(trainData.id,trainData,true)
        end
    end)
    registerClickEvent(reviewBtn,function(sender)
        self:goToFormation(trainData.id,trainData,true)
    end)

    local awardImg = self._awardPanel:getChildByFullName("awardImg") 
    awardImg:loadTexture("trainingView_awardText_bg2.png",1)
    local awardIconPosX = 60
    local iconPanel = self._awardPanel:getChildByFullName("awardIcon") 
    iconPanel:removeAllChildren()
    -- award
    local width = 75
    -- local lenX = (180 - table.nums(data.award) * width) * 0.5 --/(table.nums(data.award) + 1)    
    for i=1,4 do
        local v = trainData.award[i]
        if v then
            local itemId 
            if v[1] == "tool" then
                itemId = v[2]
            else
                itemId = IconUtils.iconIdMap[v[1]]
            end
            local toolD = tab:Tool(tonumber(itemId))
            local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = v[3]})
            icon:setScale(0.7)
            -- icon:settouch
            icon:setAnchorPoint(cc.p(0,0))
            icon:setPosition(cc.p((i-1)*width,-4))    --lenX + (k-1)*(width+lenX)
            iconPanel:addChild(icon)
        end
    end

    awardImg:setVisible(true)
    self._awardGetImg:setVisible(false)
    local titleTxtGo = 3 == self._trainType and "进行演练" or "前往训练"
    local titleTxtAgain = 3 == self._trainType and "复习演练" or "复习训练"
    -- 根据状态显示  
    if 0 == trainData.state then      -- 未通
        goBtn:setVisible(true)
        goBtn:setTitleText(titleTxtGo)
        reviewBtn:setVisible(false)
        getBtn:setVisible(false) 
        self._awardGetImg:setVisible(false)

    elseif 1 == trainData.state then  -- 领奖
        goBtn:setVisible(false)
        reviewBtn:setVisible(false)
        getBtn:setVisible(true)  
    else                              -- 复习
        goBtn:setVisible(false)
        getBtn:setVisible(false) 
        reviewBtn:setVisible(true)
        reviewBtn:setTitleText(titleTxtAgain)
        self._awardGetImg:setVisible(true)
        awardImg:setVisible(false)
        awardIconPosX = 30
    end
    iconPanel:setPositionX(awardIconPosX)

    if self._trainType == 3 then
        --更新面板上面的文字提示
        local noCupTxt = self:getUI("bg.tableviewBg.seniorPanel.noCupTxt")

        if 0 == trainData.state then
            noCupTxt:setVisible(true)
            self._cupTxt:setVisible(false)
        else
            -- 根据评分 筛选数据
            noCupTxt:setVisible(false)
            self._cupTxt:setVisible(true)
            self._cupTxt:setString("")
            local evaluateData = self._trainingModel:getEvaluateDataByScore(trainData.score or 0)
            -- print("================trainDataid and score ==",trainData.id,trainData.score)
            if evaluateData then
                self._cupTxt:setString(lang(evaluateData.lang))
            end
        end
    end
end

function TrainingTaskView:updateDetailPanelActivity(trainData)
    if not trainData then return end
    if self._isAcOpen then
        if self._isBeforeLive then
            self:updateAcPanel1(trainData)
        elseif self._isLiving then
            self:updateAcPanel2(trainData)
        else
            self:updateAcPanel3(trainData)
        end
    else
        -- 结束
        self:updateAcPanel4(trainData)
    end

end

-- 直播前准备
function TrainingTaskView:updateAcPanel1()
    print("===============直播前")
    local noCupTxt = self:getUI("bg.tableviewBg.seniorPanel.noCupTxt")
    self._cupTxt:setVisible(false)
    noCupTxt:setVisible(false)
    self._detailPanel_Ac:setVisible(false)
    self._beforePanel_Ac:setVisible(true)
    self._detailPanel:setVisible(false)
end

--直播中
function TrainingTaskView:updateAcPanel2(trainData)
    print("===============直播中")
    self._detailPanel_Ac:setVisible(true)
    self._beforePanel_Ac:setVisible(false)
    self._detailPanel:setVisible(false)
    --隐藏info
    local livingPanel = self._detailPanel_Ac:getChildByFullName("livingPanel")
    local afterPanel = self._detailPanel_Ac:getChildByFullName("afterPanel")
    livingPanel:setVisible(true)
    afterPanel:setVisible(false)
    -- 显示直播计时
    local timeLabel = self._detailPanel_Ac:getChildByFullName("livingPanel.timeLabel")
    -- timeLabel:setString("00:00:00")
    --开始倒计时
    if not self._livingTimer and self._liveStarTime then 
        local currTime = self._userModel:getCurServerTime()
        local subTime = currTime - self._liveStarTime
        local timeStr = TimeUtils.getStringTimeForInt(subTime)
        timeLabel:setString(timeStr)
        self._livingTimer = ScheduleMgr:regSchedule(1000,self,function( )
            local currTime = self._userModel:getCurServerTime()
            local subTime = currTime - self._liveStarTime
            local timeStr = TimeUtils.getStringTimeForInt(subTime)
            timeLabel:setString(timeStr)
            if self._liveEndTime == currTime then
                timeLabel:setString("02:00:00")
                ScheduleMgr:unregSchedule(self._livingTimer)
                self._livingTimer = nil
                self._isLiving = false
                -- 获取一次前三数据，更新黄执中时间
                local data = self._tableData[self._currBtn]
                self:sendGetRankListMsg(data)
                -- 更新当前面板显示
                -- self:updateAcPanel3(data)
            end
        end)
    end
    self:updateAcInfoPanel(trainData)
end
-- 直播后结束前
function TrainingTaskView:updateAcPanel3(trainData)
    print("===============直播后结束前")
    self._detailPanel_Ac:setVisible(true)
    self._beforePanel_Ac:setVisible(false)
    self._detailPanel:setVisible(false)

    -- 显示info
    local livingPanel = self._detailPanel_Ac:getChildByFullName("livingPanel")
    local afterPanel = self._detailPanel_Ac:getChildByFullName("afterPanel")
    livingPanel:setVisible(false)
    afterPanel:setVisible(true)
    -- 显示活动倒计时
    local acDes = self._detailPanel_Ac:getChildByFullName("afterPanel.acDes")
    local timeLabel = self._detailPanel_Ac:getChildByFullName("afterPanel.timeLabel")
    acDes:setVisible(true)
    timeLabel:setVisible(true)
    -- timeLabel:setString("00:00:00")
    --开始倒计时
    if not self._acTimer and self._acEndTime then 
        local currTime = self._userModel:getCurServerTime()
        local subTime = self._acEndTime - currTime
        local timeStr = TimeUtils.getTimeStringFont1(subTime)
        timeLabel:setString(timeStr)
        self._acTimer = ScheduleMgr:regSchedule(1000,self,function( )
            local currTime = self._userModel:getCurServerTime()
            local subTime = self._acEndTime - currTime
            local timeStr = TimeUtils.getTimeStringFont1(subTime)
            timeLabel:setString(timeStr)
            if subTime == 0 then
                timeLabel:setString("0天00:00:00")
                ScheduleMgr:unregSchedule(self._acTimer)
                self._acTimer = nil
                self._isAcOpen = false
                acDes:setVisible(false)
                timeLabel:setVisible(false)
                if self._resultAwardTxt then
                    self._resultAwardTxt:setVisible(false)
                end
                -- 活动结束
                local rankPanel = self._detailPanel_Ac:getChildByFullName("rankPanel")
                if rankPanel then
                    rankPanel:setVisible(self._isAcOpen)
                end
            end
        end)
    end
    if not self._resultAwardTxt then
        self._resultAwardTxt = ccui.Text:create()
        self._resultAwardTxt:setFontName(UIUtils.ttfName)
        self._resultAwardTxt:setFontSize(16)
        self._resultAwardTxt:setColor(cc.c4b(255,230,65,255))
        self._resultAwardTxt:setString("活动结束时，第一名玩家所在服务器的所有玩家可获得200钻石奖励")
        self._resultAwardTxt:setPosition(300, -50)
        afterPanel:addChild(self._resultAwardTxt,5)
    end
    self:updateAcInfoPanel(trainData)
end

-- 活动结束后
function TrainingTaskView:updateAcPanel4(trainData)  
    print("===============活动结束后") 
    self._detailPanel_Ac:setVisible(true)
    self._beforePanel_Ac:setVisible(false)
    self._detailPanel:setVisible(false)

    --显示info
    local livingPanel = self._detailPanel_Ac:getChildByFullName("livingPanel")
    local afterPanel = self._detailPanel_Ac:getChildByFullName("afterPanel")
    livingPanel:setVisible(false)
    afterPanel:setVisible(true)
    -- 不显示活动倒计时
    local acDes = self._detailPanel_Ac:getChildByFullName("afterPanel.acDes")
    local timeLabel = self._detailPanel_Ac:getChildByFullName("afterPanel.timeLabel")
    acDes:setVisible(false)
    timeLabel:setVisible(false)
    if self._resultAwardTxt then
        self._resultAwardTxt:setVisible(false)
    end
    self:updateAcInfoPanel(trainData)
end

function TrainingTaskView:updateAcInfoPanel(trainData)   
    -- body
    if not trainData then return end
    -- 顶部信息更新
    local infoPanel = self._detailPanel_Ac:getChildByFullName("afterPanel.infoPanel")
    local scoreTxt = self._detailPanel_Ac:getChildByFullName("afterPanel.infoPanel.scoreTxt")
    local HscoreTxt = self._detailPanel_Ac:getChildByFullName("afterPanel.infoPanel.HscoreTxt")
    local scoreDes  = self._detailPanel_Ac:getChildByFullName("afterPanel.infoPanel.scoreDes")
    local passTime = trainData.sTime or 0
    local hscore = self._rankList[trainData.id] and self._rankList[trainData.id].targetScore or nil
    if tonumber(passTime) <= 0 then
        scoreDes:setString("暂未通关")
        scoreTxt:setVisible(false)
        if self._shareNode then
            self._shareNode:setVisible(false)
        end
    else
        scoreDes:setString("时间")
        scoreTxt:setVisible(true)
        scoreTxt:setString(passTime .. "s")

        -- 有成绩可以分享
        if self._shareNode == nil then
            local sharePos = infoPanel:getChildByFullName("sharePos")
            self._shareNode = require("game.view.share.GlobalShareBtnNode").new({mType = "ShareTrainingModule"})
            self._shareNode:setPosition(840, 470)
            self._shareNode:setCascadeOpacityEnabled(true, true)
            self._bg:addChild(self._shareNode, 100)
            self._shareNode:setVisible((not self._isLiving and not self._isBeforeLive))
        else
            self._shareNode:setVisible((not self._isLiving and not self._isBeforeLive))
        end

        self._shareNode:registerClick(function()
            return {moduleName = "ShareTrainingModule",Hscore=hscore,score=trainData.sTime}
        end)

    end

    HscoreTxt:setString((hscore or 0) .. "s")

    --更新排行榜前三显示
    self:updateRankListPanel(trainData)
   
    local goBtn = self:getUI("bg.detail_panel_activity.goBtn")
    local getBtn = self:getUI("bg.detail_panel_activity.getBtn") 
    local reviewBtn = self:getUI("bg.detail_panel_activity.reviewBtn")
    -- local mc = getBtn:getChildByFullName("anniuAnim")
    -- if not mc then
    --     mc = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true,false)
    --     mc:setName("anniuAnim")
    --     mc:setPosition(getBtn:getContentSize().width/2-2, getBtn:getContentSize().height/2)
    --     getBtn:addChild(mc,10)
    -- end

    registerClickEvent(getBtn,function(sender) 
        self:getTrainingAward(trainData.id)
    end)
    registerClickEvent(goBtn,function(sender) 
        if tonumber(self._userLvl) < tonumber(trainData.level) then
            self._viewMgr:showTip("玩家" .. trainData.level .. "级开启挑战")
        else
            self:goToFormation(trainData.id,trainData,true)
        end
    end)
    registerClickEvent(reviewBtn,function(sender) 
        self:goToFormation(trainData.id,trainData,true)
    end)

    local awardPanel = self:getUI("bg.detail_panel_activity.awardPanel")
    local awardImg = awardPanel:getChildByFullName("awardImg") 
    awardImg:loadTexture("trainingView_awardText_bg2.png",1)
    local awardIconPosX = 60
    local iconPanel = awardPanel:getChildByFullName("awardIcon") 
    iconPanel:removeAllChildren()
    local getImg = awardPanel:getChildByFullName("getImg") 
    -- award
    local width = 75
    -- local lenX = (180 - table.nums(data.award) * width) * 0.5 --/(table.nums(data.award) + 1)    
    for i=1,4 do
        local v = trainData.award[i]
        if v then
            local itemId 
            if v[1] == "tool" then
                itemId = v[2]
            else
                itemId = IconUtils.iconIdMap[v[1]]
            end
            local toolD = tab:Tool(tonumber(itemId))
            local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = v[3]})
            icon:setScale(0.7)
            -- icon:settouch
            icon:setAnchorPoint(cc.p(0,0))
            icon:setPosition(cc.p((i-1)*width,-4))    --lenX + (k-1)*(width+lenX)
            iconPanel:addChild(icon)
        end
    end

    awardImg:setVisible(true)
    getImg:setVisible(false)
    local titleTxtGo = 3 == self._trainType and "进行演练" or "前往训练"
    local titleTxtAgain = 3 == self._trainType and "复习演练" or "复习训练"
    -- 根据状态显示  
    if 0 == trainData.state then      -- 未通
        goBtn:setVisible(true)
        goBtn:setTitleText(titleTxtGo)
        reviewBtn:setVisible(false)
        getBtn:setVisible(false) 
        getImg:setVisible(false)

    elseif 1 == trainData.state then  -- 领奖
        goBtn:setVisible(false)
        reviewBtn:setVisible(false)
        getBtn:setVisible(true)  
    else                              -- 复习
        goBtn:setVisible(false)
        getBtn:setVisible(false) 
        reviewBtn:setVisible(true)
        reviewBtn:setTitleText(titleTxtAgain)
        getImg:setVisible(true)
        awardImg:setVisible(false)
        awardIconPosX = 30
    end
    iconPanel:setPositionX(awardIconPosX)

    --更新面板上面的文字提示
    local noCupTxt = self:getUI("bg.tableviewBg.seniorPanel.noCupTxt")

    if 0 == trainData.state then
        noCupTxt:setVisible(true)
        self._cupTxt:setVisible(false)
    else
        -- 根据评分 筛选数据
        noCupTxt:setVisible(false)
        self._cupTxt:setVisible(true)
        self._cupTxt:setString("")
        local evaluateData = self._trainingModel:getEvaluateDataByScore(trainData.score or 0)
        -- print("================trainDataid and score ==",trainData.id,trainData.score)
        if evaluateData then
            self._cupTxt:setString(lang(evaluateData.lang))
        end
    end
end

function TrainingTaskView:updateRankListPanel(trainData)
     -- 排行榜前三更新
    local amount = self._rankList[trainData.id] and self._rankList[trainData.id].amount or 0
    local rankData = self._rankList[trainData.id] and self._rankList[trainData.id].rankList or {}
    if not rankData then
        rankData = {}
    end
    
    local rankPanel = self._detailPanel_Ac:getChildByFullName("rankPanel")
    local width1 = 0
    local width2 = 0
    for i=1,3 do
        local serverTxt = rankPanel:getChildByFullName("serverName" .. i)
        local nameTxt = rankPanel:getChildByFullName("rankName" .. i)
        local scoreDes = rankPanel:getChildByFullName("scoreTxt" .. i)
        local score = rankPanel:getChildByFullName("score" .. i)

        if rankData[i] then
            nameTxt:setVisible(true)
            scoreDes:setVisible(true)
            score:setVisible(true)
            local platformStr ,idStr = self._userModel:getPlatformInfoById(rankData[i].secId or 0)
            serverTxt:setString(platformStr .. " " .. idStr)
            local w1 = serverTxt:getContentSize().width
            if w1 > width1 then
                width1 = w1
            end
            nameTxt:setString(rankData[i].name or "")
            local w2 = nameTxt:getContentSize().width
             if w2 > width2 then
                width2 = w2
            end
            score:setString((rankData[i].time or 0) .. "s")
        else
            serverTxt:setString("暂无")
            nameTxt:setVisible(false)
            scoreDes:setVisible(false)
            score:setVisible(false)
        end
    end

    for i=1,3 do        
        if rankData[i] then
            local serverTxt = rankPanel:getChildByFullName("serverName" .. i)
            local nameTxt = rankPanel:getChildByFullName("rankName" .. i)
            local scoreDes = rankPanel:getChildByFullName("scoreTxt" .. i)
            local score = rankPanel:getChildByFullName("score" .. i)
            nameTxt:setPositionX(serverTxt:getPositionX()+ width1 + 3)
            scoreDes:setPositionX(nameTxt:getPositionX() + width2 + 3)
            score:setPositionX(scoreDes:getPositionX() + scoreDes:getContentSize().width+1)
        end
    end

    local afterPanel = self:getUI("bg.detail_panel_activity.afterPanel")
    -- local des1 = afterPanel:getChildByFullName("des1")
    local num = afterPanel:getChildByFullName("num")
    local des2 = afterPanel:getChildByFullName("des2")
    num:setString(amount or 0)
    des2:setString("人超过黄执中")
    des2:setPositionX(num:getPositionX() + num:getContentSize().width+2)

end

--前往布阵
function TrainingTaskView:goToFormation(trainingId,data,isWin)
    
    -- print("============前往布阵================trainingId=",trainingId)
    -- dump(data)
    local formationData , enemyFormationData ,extendData = self:formatFormationData(data)
    -- dump(formationData,"formation")
    -- dump(enemyFormationData,"enemyFormationData")
    -- dump(extendData,"extend")
    -- if true then return end
    extendData.trainigData = data
    extendData.isFirstTrain = data.state == 0
    
    local formationModel = self._modelMgr:getModel("FormationModel")
    if isWin then
        formationModel:updateFormationDataByType(formationModel.kFormationTypeTraining,formationData)
    end
    self._viewMgr:showView("formation.NewFormationView", {
        formationType = formationModel.kFormationTypeTraining, 

        enemyFormationData = { [formationModel.kFormationTypeTraining] = enemyFormationData },
        extend = extendData,
        
        callback = function(playerInfo, teamCount, filterCount, formationType)                            
            self._serverMgr:sendMsg("TrainingServer", "fightBefore", {id = trainingId, serverInfoEx = BattleUtils.getBeforeSIE()}, true, {}, function(result)
                self._viewMgr:popView()
                BattleUtils.enterBattleView_Training(playerInfo, trainingId, 
                    function (info, callback)
                    -- 战斗结束
                        -- info.win = 1
                        self._currBattleResult = info.win or false
                        -- print("=================self._currBattleResult==",self._currBattleResult)
                        self:afterTrainingBattle(playerInfo, info,callback,trainingId,data)
                        
                    end,
                    function (info)
                        -- 退出战斗
                        -- print("==========退出战斗=======self._currBattleResult==",self._currBattleResult)
                        -- ViewManager:getInstance():popView()
                        if not self._currBattleResult then
                            self:goToFormation(trainingId,data,self._currBattleResult)
                        end
                    end,false)
            end)
        end
        
    })

end

-- 格式化传入布阵的参数
function TrainingTaskView:formatFormationData(data)
    local formationData = {} 

    -- 上阵兵团
    local npc1 = data.npc1
    for i=1,8 do
        local npcData = npc1[i]
        if npcData then
            formationData["team" .. i] = tonumber(npcData[1])
            formationData["g" .. i] = tonumber(npcData[2])
        else
            formationData["team" .. i] = 0
            formationData["g" .. i] = 0
        end
    end

    -- 过滤不显示的兵团id
    formationData.filter = {}

    --上阵英雄
    local hero1 = data.hero1
    formationData.heroId = tonumber(hero1)


    -- 敌方上阵兵团
    local enemyFormationData = {}
    local enemynpc = data.enemynpc or {}
    local fightScore = 0

    for i=1,8 do
        local npcData = enemynpc[i]
        if npcData then
            enemyFormationData["team" .. i] = tonumber(npcData[1])
            enemyFormationData["g" .. i] = tonumber(npcData[2])
            local enemyData = tab:Npc(tonumber(npcData[1]))
            if enemyData.score then
                fightScore = fightScore + tonumber(enemyData.score) 
            end
        else
            enemyFormationData["team" .. i] = 0
            enemyFormationData["g" .. i] = 0
        end
    end

    -- 过滤不显示的兵团id
    enemyFormationData.filter = ""    

    --上阵英雄
    enemyFormationData.heroId = tonumber(data.enemyhero)
    local heroData = tab:NpcHero(tonumber(data.enemyhero))
    if heroData and heroData.score then
        fightScore = fightScore + tonumber(heroData.score) 
    end

    -- 战斗力
    enemyFormationData.score = fightScore

    -- 可以上场的兵团和英雄 包括已经上阵的
    local extend = {}
    extend.teams = data.npc2 or {}
    extend.heroes = data.hero2 or {}
    extend.count = {[self._modelMgr:getModel("FormationModel").kFormationTypeTraining] = data.limitNum}

    return formationData ,enemyFormationData ,extend
end

--领取奖励
function TrainingTaskView:getTrainingAward(trainingId)    
    -- print("==========================领取奖励==trainingId=",trainingId)
    self._serverMgr:sendMsg("TrainingServer", "getReward", {id = trainingId}, true, {}, function(result)
        --callBack
        -- 领取动画
        if result.award then
            DialogUtils.showGiftGet(result.award)
        end
        self:reflashUI()

    end)

end

--战后数据处理
function TrainingTaskView:afterTrainingBattle(playerInfo, info,callback,trainingId,data)
 
    local currToken = self._trainingModel:getTrainingFightToken() or ""
    -- print("========================currToken===",currToken)
    local win = info.win or 0
    local hp = info.hp or {} 
    local time = info.time or 0
  
    -- 剩余血量百分比 * n（配表数据 ）
    local score = tonumber(hp[1]) / tonumber(hp[2]) * tonumber(data.num) * 100 --100--
    score = math.ceil(score)
    -- 最低15分
    if score < 15 then
        score = 15
    end
    info.score = score > 100 and 100 or score
    local formationHeroID
    if playerInfo and playerInfo.hero then
        formationHeroID = playerInfo.hero.id
    end

    -- info.win = 1
    local param = {id = trainingId,token = currToken,
    args = json.encode({win = win,score = info.score,time = time,heroId = formationHeroID,skillList = info.skillList,serverInfoEx = info.serverInfoEx,playerInfo=json.encode(playerInfo)})}
    info.trainingData = data
    self._serverMgr:sendMsg("TrainingServer", "fightAfter", param, true, {}, function(result) 
        -- if result["extract"] then
        --     dump(result["extract"]["hp"], "a", 10)
        -- end
        if self._trainType == 3 and data.cType and data.cType == 2 then 
            -- 更新前三数据
            self:updaterankListData(result,data)
            -- 首次通关会有动画刷新界面 只需复习训练刷新界面
            if data.state == 2 then
                -- 更新面板显示
                self:updateDetailPanelActivity(data)
            end
        end
        self._isAfterBattle = win       
        --结算
        callback(info)
        --checkAnim 里面更新数据
        -- self:reflashUI()
        -- self:playPassTrainAnim(true)
    end)
    
end

-- 接收自定义消息
function TrainingTaskView:reflashUI(data)
    self:updateTableData()
    if not self._scrollView then
        --进界面先定位到可领奖励的位置 确定self._currBtn的值
        self:searchButtonPos()
        --添加按钮 
        self:addBtnScrollView()
        self:updateScrollViewPos()
    end 

    -- 更新当前选中按钮的状态
    self:updateCurrLeftBtn(self._currBtn)
    -- 默认第一条显示第一条数据    
    self:updateDetailPanel(self._tableData[self._currBtn],self._isFirst)
    self._isFirst = false

    if 3 == self._trainType then        
        self:updateSeniorPanel()
    end
end

function TrainingTaskView:searchButtonPos()
    if not self._tableData then return end
    -- print("======================self._goStageIdx======",self._goStageIdx)
    self._currBtn = 0
    -- dump(self._tableData,"_tableData=>",4)
    if self._isFromAc and 3 == self._trainType and self._isBeforeLive then
        self._currBtn = table.nums(self._tableData)
        if self._currBtn <= 0 then
            self._currBtn = 1
        end
        if true then return end
    end
    if self._goStageIdx then
        for k,v in pairs(self._tableData) do
            if tonumber(v.id) == self._goStageIdx then
                self._currBtn = tonumber(k)
                break
            end
        end
    end
    if not self._goStageIdx or self._currBtn == 0 then
        for k,v in pairs(self._tableData) do
            if v.state and 1 == v.state then
                self._currBtn = tonumber(k)
                break
            end
        end
    end
    -- 如果没有指定跳转 并且 没有奖励可领 默认1
    if self._currBtn == 0 then
        self._currBtn = 1
    end

end
-- 更新scrollView位置 当前点击按钮可见
function TrainingTaskView:updateScrollViewPos()

    local totalNum = #self._tableData
    local num = self._currBtn 
    num = num > 3 and num or 0
    local height = self._scrollView:getInnerContainerSize().height 
    local percent = (num - 2) / (totalNum - 3 )
        
    percent = percent > 1 and 1 or percent
    ScheduleMgr:delayCall(0, self, function()
        self._scrollView:jumpToPercentVertical(percent * 100)
    end)

end


function TrainingTaskView:updateTableData()

    self._tableData = self._trainingModel:getDataByType(self._trainType)

    table.sort(self._tableData,function(a,b)
        if tonumber(a.rank) ~= tonumber(b.rank) then
            return a.rank < b.rank
        else
           return a.id < b.id 
        end
    end)

    -- self._tableData = self:sortTableData(self._tableData)
end

--通关动画 
function TrainingTaskView:normalPassTrainAnim(isFly,isUp)

    -- 更新按钮状态 然后播动画
    self:updateCurrLeftBtn(self._currBtn)
    
    --回调刷新界面
    local callData = {callback = function()
        if isUp then
            -- 播放奖杯升级动画            
            local cupData = self._trainingModel:getCupDataBuySNum()
            -- print("====================cupData.num=====",cupData.num)
            if cupData then
                self._viewMgr:showDialog("training.TrainingCupUpView", cupData)
            end
        end
        -- 更新显示
        self:updateDetailPanel(self._tableData[self._currBtn])
        if 3 == self._trainType then        
            self:updateSeniorPanel()
        end        
    end }

    self:playAnim(callData,isFly)
   
end
--[[
function TrainingTaskView:unlockSeniorAnim(isFly,isUp)
    
    -- 更新按钮状态 然后播动画
    self:updateCurrLeftBtn(self._currBtn)
    
    --回调刷新界面
    local callData = {callback = function()
        if self._parent and self._parent.unlockSeniorAnim then
            -- 播放高级解锁动画            
            self:close()

            if self._parent and self._parent.unlockSeniorAnim then
                self._parent:unlockSeniorAnim()
            end

            if self._parent and self._parent.clearTaskNode then
                self._parent:clearTaskNode()
            end

            UIUtils:reloadLuaFile("training.TrainingTaskView")
        end
    end }

    self:playAnim(callData,isFly)

end
]]
--动画
function TrainingTaskView:playAnim(data,isNeedFly)
    self:lock(-1)

    local animCallBack
    if data and data.callback then
        animCallBack = data.callback
    end

    local btn = self._trainBtn[self._currBtn]  
    local passImg = btn:getChildByFullName("passImg")  
    local canVisible = passImg:isVisible()  
    passImg:setVisible(false)

    local sclaeNum = passImg:getScale()
    local animParent = self._bg 
    -- 世界坐标
    local imgPos = btn:convertToWorldSpace(cc.p(passImg:getPositionX(),passImg:getPositionY()))
    -- 相对于animParent的位置
    local animPos = animParent:convertToNodeSpace(cc.p(imgPos.x,imgPos.y))

    local spNormal = passImg:clone()
    spNormal:setVisible(true)
    spNormal:setPosition(animPos.x, animPos.y)
    spNormal:setOpacity(0)
    spNormal:setScale(0.1)
    animParent:addChild(spNormal,100)

    local spWhite = passImg:clone()
    spWhite:setOpacity(0)
    spWhite:setBrightness(200)
    spWhite:setVisible(true)
    spWhite:setPosition(animPos.x, animPos.y)
    animParent:addChild(spWhite,101)

    local bigSpawn = cc.Spawn:create(cc.FadeIn:create(0.1),cc.ScaleTo:create(0.1,4*sclaeNum))
    local seqSmall = cc.Sequence:create(bigSpawn,cc.ScaleTo:create(0.1,0.9*sclaeNum))
    -- 是否需要飞到奖杯上
    if not isNeedFly then
        local normalSeq = cc.Sequence:create(seqSmall,cc.ScaleTo:create(0.2,sclaeNum),cc.CallFunc:create(function ()
            self:unlock()
            if animCallBack then
                animCallBack()
            end        
            spNormal:removeFromParent()
            passImg:setVisible(canVisible) 
        end))
        spNormal:runAction(normalSeq)

    else 
        local cupPos = cc.p(0,0)
        -- local pos1 = cc.p(0,0) 
        local sNum = self._trainingModel:getScoreSNum(3)
        local star
        -- print("====================sNum====",sNum)
        local starIdx = sNum % 3 
        if sNum ~= 0 then
            if starIdx == 0 then
                starIdx = 3
            end            
            self._starPanel:setVisible(true)
        else
            self:unlock()
            return
        end
        star = self._starPanel:getChildByFullName("star" .. starIdx)
        star:setVisible(false)
        -- print("===========================starIdx==",starIdx)
       
        if  star then           
            -- 评价starPanel的位置
            cupPos = self._starPanel:convertToNodeSpace(cc.p(imgPos.x,imgPos.y))
        end
        -- print("==========================cupPos==",cupPos.x,cupPos.y)
        -- 相对星星的距离
        local subPosX = star:getPositionX() - cupPos.x  
        local sbuPosY = star:getPositionY() - cupPos.y

        local flyTime = math.abs((sbuPosY - 159) / 76 * 0.1) + 0.1
        -- print(cupPos.x,cupPos.y,"****************************",imgPos.x,imgPos.y)
        -- print(sbuPosY,"============================flyTime==",flyTime)
        local flySpwan = cc.Sequence:create(
            cc.Spawn:create(cc.ScaleTo:create(flyTime,0.5),
                cc.MoveBy:create(flyTime,cc.p(subPosX,sbuPosY))),
            cc.FadeOut:create(0.1),
            cc.DelayTime:create(0.2))
       
        local normalSeq = cc.Sequence:create(seqSmall,
            cc.ScaleTo:create(0.2,sclaeNum),
            cc.CallFunc:create(function ()                
                passImg:setVisible(canVisible) 
            end),
            flySpwan,
            cc.CallFunc:create(function ()            
                self:unlock()

                if animCallBack then
                    animCallBack()
                end
                spNormal:removeFromParent()
        end))

        spNormal:runAction(normalSeq)

        local dt = 0.1+0.1+0.2+flyTime
        local starAction = cc.Sequence:create(cc.DelayTime:create(dt),
            cc.CallFunc:create(function (  )
                star:setVisible(true)
            end),
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(function (  )
                local mc = mcMgr:createViewMC("fankui_lianmengjihuo", false, true,function( _,sender )
                     -- star:setVisible(true)
                end)
                mc:setScale(0.6)
                mc:setPosition(star:getPositionX(),star:getPositionY())
                self._starPanel:addChild(mc)
        end))
        if star then
            star:runAction(starAction)
        end
    end

    local spwanspW = cc.Spawn:create(cc.FadeOut:create(0.2),cc.ScaleTo:create(0.2,1.5*sclaeNum))
    local spActiong = cc.Sequence:create(cc.DelayTime:create(0.19),cc.FadeIn:create(0.01),spwanspW,cc.CallFunc:create(function ( )
        spWhite:removeFromParent()
    end))
    spWhite:runAction(spActiong)
end

-- 上一层级View ontop时调用
function TrainingTaskView:checkAnimStart()  
    -- 当前按钮位置可见
    self:updateScrollViewPos()
    -- 如果不是战后并且赢了，数据不会变化不需要刷新动画及数据
    if not self._isAfterBattle or self._isAfterBattle == 0 then
        return
    end
    self._isAfterBattle = false

    self:lock(-1)
    ScheduleMgr:delayCall(0.2, self, function()
        self:unlock()
        --滚动完检查动画播放
        self:checkAnim()
    end)

end
-- 检查是否播放动画
function TrainingTaskView:checkAnim()
    
    -- 更新数据
    self:updateTableData()

    local currData = self._tableData[self._currBtn]
    local currId = self._tableData[self._currBtn].id   
    if currData.state == 0 then return end    
    
    -- dump(currData,"currData==>")
    local isUp = false
    local isNeedFly = false
    -- print("======================currData.score===",currData.score)
    local seniorUp = false
    if 3 == self._trainType then
         -- 高级 评估等级提升
        local evaluateNum = SystemUtils.loadAccountLocalData("trainPassAnim_" .. currId) or 5
        local currEvaluate =  self._trainingModel:getEvaluateDataByScore(currData.score or 0)
        -- 通关并且评估等级上升
        if tonumber(currEvaluate.evaluate) < tonumber(evaluateNum) then
            SystemUtils.saveAccountLocalData("trainPassAnim_" .. currId,tonumber(currEvaluate.evaluate))
            -- 高级是否评估等级提升
            seniorUp = true
            -- SSS
            if currEvaluate.evaluate == 1 then
                isNeedFly = true
            end
        end
        -- -- 如果高级为通关，不播动画
        -- if currData.state == 2 then
        --     seniorUp = false
        -- end
        -- 奖杯晋级
        local saveSnum = SystemUtils.loadAccountLocalData("trainCupAnim") or 0
        local cupData = self._trainingModel:getCupDataBuySNum()
        -- print("=====================saveSnum==",saveSnum)
        -- dump(cupData,"cupData==>")
        if cupData and tonumber(cupData.num) > tonumber(saveSnum) then
            isUp = true
            SystemUtils.saveAccountLocalData("trainCupAnim",tonumber(cupData.num))
        end

    end

    -- -- 通关
    -- local unlock = self._trainingModel:isSeniorOpen()
    -- local isAnim = SystemUtils.loadAccountLocalData("trainUnlockAnim") or false
    -- if unlock and not isAnim then
    --     SystemUtils.saveAccountLocalData("trainUnlockAnim",true)
    --     self:unlockSeniorAnim()
    -- else
    -- end
    
    -- print("+========================",isNeedFly,seniorUp,isUp)
    -- 通关未领 首通
    if currData and (1 == currData.state or seniorUp ) then        
        self:normalPassTrainAnim(isNeedFly,isUp)
    end

end

return TrainingTaskView