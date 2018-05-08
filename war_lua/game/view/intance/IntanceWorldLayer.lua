--[[
    Filename:    IntanceWorldLayer.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-02-01 20:47:32
    Description: File description
--]]
local cc = cc
local GlobalScrollLayer = require "game.view.global.GlobalScrollLayer"

local IntanceWorldLayer = class("IntanceWorldLayer", GlobalScrollLayer)


function IntanceWorldLayer:ctor(switchCallback, parentView, actNewSectionId)
    IntanceWorldLayer.super.ctor(self)

    self._boxQuality = {
        {3},
        {2, 3},
        {1, 2, 3} 
    }

    self._parentView = parentView

    self._actNewSectionId = actNewSectionId



    self._switchCallback = switchCallback
    
    self:setClassName("IntanceWorldLayer")
    self:setName("IntanceWorldLayer")

    self._clickOtherView = false
    self._curStoryId = 1

    self._userModel = self._modelMgr:getModel("UserModel")
    self._cacheUserLvl = self._userModel:getData().lvl

    self._intanceModel = self._modelMgr:getModel("IntanceModel")
    self._siegeModel = self._modelMgr:getModel("SiegeModel")

    self:loadBigMap()


    self._worldElementLayer = self._parentView:createLayer("intance.WorldElementLayer", {parent = self, showType = 1})
    self:addChild(self._worldElementLayer, 1)

    self._worldCompassBg = cc.Sprite:createWithSpriteFrameName("world_temp_4.png")
    self._worldCompassBg:setAnchorPoint(cc.p(0, 1))
    self._worldCompassBg:setPosition(cc.p(0, MAX_SCREEN_HEIGHT))
    self:addChild(self._worldCompassBg)

    self._worldCompass = cc.Sprite:createWithSpriteFrameName("world_temp_5.png")
    self._worldCompass:setAnchorPoint(cc.p(0.5, 0.5))
    self._worldCompass:setPosition(cc.p(self._worldCompassBg:getContentSize().width * 0.5, MAX_SCREEN_HEIGHT - self._worldCompassBg:getContentSize().height * 0.5))
    self:addChild(self._worldCompass)
    self._worldCompass:setRotation(75)

    self._worldTitleBg = ccui.Widget:create()
    self._worldTitleBg:setContentSize(636, 81)
    self._worldTitleBg:setAnchorPoint(cc.p(0.5, 1))
    self._worldTitleBg:setPosition(cc.p(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT + 10))
    self:addChild(self._worldTitleBg, 10)
    self._worldTitleBg:setTouchEnabled(false)




    local leftTitle = cc.Scale9Sprite:createWithSpriteFrameName("globalImageUI_specialTitleBg.png")
    leftTitle:setCapInsets(cc.rect(207, 1, 1, 0))
    leftTitle:setContentSize(636, 63)
    leftTitle:setAnchorPoint(cc.p(0, 0))
    leftTitle:setPosition(cc.p(0, 12))
    self._worldTitleBg:addChild(leftTitle)


    local centerTitle = ccui.ImageView:create()
    centerTitle:loadTexture("world_big_title3.png", 1)
    centerTitle:setAnchorPoint(cc.p(0.5, 0.5))
    centerTitle:setPosition(cc.p(318, 52.5))
    self._worldTitleBg:addChild(centerTitle)


    local titleTouchArea1 = ccui.Widget:create()
    titleTouchArea1:setContentSize(700, 29)
    titleTouchArea1:setAnchorPoint(0.5, 1)
    titleTouchArea1:setPosition(self._worldTitleBg:getContentSize().width/2, self._worldTitleBg:getContentSize().height)
    self._worldTitleBg:addChild(titleTouchArea1)
    registerClickEvent(titleTouchArea1, function()
        if self._lockTouch == true then return end
        self._worldSubBg:runOpenAction(true)
    end)

    local titleTouchArea2 = ccui.Widget:create()
    titleTouchArea2:setContentSize(570, 25)
    titleTouchArea2:setAnchorPoint(0.5, 1)
    titleTouchArea2:setPosition(self._worldTitleBg:getContentSize().width/2, self._worldTitleBg:getContentSize().height - 29)
    self._worldTitleBg:addChild(titleTouchArea2)
    registerClickEvent(titleTouchArea2, function()
        if self._lockTouch == true then return end
        self._worldSubBg:runOpenAction(true)
    end)

    local titleTouchArea3 = ccui.Widget:create()
    titleTouchArea3:setContentSize(300, 20)
    titleTouchArea3:setAnchorPoint(0.5, 1)
    titleTouchArea3:setPosition(self._worldTitleBg:getContentSize().width/2, self._worldTitleBg:getContentSize().height - 54)
    self._worldTitleBg:addChild(titleTouchArea3)
    registerClickEvent(titleTouchArea3, function()
        if self._lockTouch == true then return end
        self._worldSubBg:runOpenAction(true)
    end)

    local titleTouchArea4 = ccui.Widget:create()
    titleTouchArea4:setContentSize(220, 13)
    titleTouchArea4:setAnchorPoint(0.5, 1)
    titleTouchArea4:setPosition(self._worldTitleBg:getContentSize().width/2, self._worldTitleBg:getContentSize().height - 74)
    self._worldTitleBg:addChild(titleTouchArea4)
    registerClickEvent(titleTouchArea4, function()
        if self._lockTouch == true then return end
        self._worldSubBg:runOpenAction(true)
    end)

    self._worldSubBg = ccui.Widget:create()
    self._worldSubBg:setContentSize(230, 29)
    self._worldSubBg:setAnchorPoint(0.5, 1)
    self._worldSubBg:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT - self._worldTitleBg:getContentSize().height + 20)
    self:addChild(self._worldSubBg, 2)
    self._worldSubBg.isOpen = false
    self._worldSubBg.positionY = self._worldSubBg:getPositionY()
    registerClickEvent(self._worldSubBg, function()
        if self._lockTouch == true then return end
        self._worldSubBg:runOpenAction(true)
    end)




    -- self._bgLayer = ccui.Layout:create()
    -- self._bgLayer:setBackGroundColorOpacity(255)
    -- self._bgLayer:setBackGroundColorType(1)
    -- self._bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    -- self._bgLayer:setTouchEnabled(true)
    -- self._bgLayer:setContentSize(self._worldSubBg:getContentSize().width, self._worldSubBg:getContentSize().width)
    -- self._worldSubBg:addChild(self._bgLayer, 0)


    -- 黄色箭头
    local subLeftTitle = cc.Scale9Sprite:createWithSpriteFrameName("world_big_title1.png")
    subLeftTitle:setCapInsets(cc.rect(30, 1, 1, 1))
    subLeftTitle:setContentSize(116, 27)
    subLeftTitle:setAnchorPoint(cc.p(0, 0))
    subLeftTitle:setPosition(cc.p(0, 14))
    self._worldSubBg:addChild(subLeftTitle)

    local subRightTitle = cc.Scale9Sprite:createWithSpriteFrameName("world_big_title1.png")
    subRightTitle:setCapInsets(cc.rect(30, 1, 1, 1))
    subRightTitle:setContentSize(116, 27)
    subRightTitle:setAnchorPoint(cc.p(1, 0))
    subRightTitle:setPosition(cc.p(115, 14))
    self._worldSubBg:addChild(subRightTitle)
    subRightTitle:setScaleX(-1)

    -- 黄色箭头
    local tempTitle2 = ccui.ImageView:create()
    tempTitle2:loadTexture("world_big_title2.png",1)
    tempTitle2:setAnchorPoint(0.5, 0.5)
    tempTitle2:setPosition(self._worldSubBg:getContentSize().width * 0.5 + 2, self._worldSubBg:getContentSize().height * 0.5 + 14)
    self._worldSubBg:addChild(tempTitle2)
    tempTitle2:setRotation(180)
    tempTitle2:setName("openBtn")
    registerClickEvent(tempTitle2, function()
        if self._lockTouch == true then return end
        self._worldSubBg:runOpenAction(true)
    end)

    -- 黑色面板
    self._worldTipBg = cc.Scale9Sprite:createWithSpriteFrameName("world_temp_7.png")
    self._worldTipBg:setContentSize(458, 460)
    self._worldTipBg:setAnchorPoint(0.5, 0)
    self._worldTipBg:setPosition(self._worldSubBg:getContentSize().width * 0.5, self._worldSubBg:getContentSize().height + 12)
    self._worldSubBg:addChild(self._worldTipBg)
    self._worldTipBg:setVisible(false)

    local labTeamDes = UIUtils:createMultiLineLabel({text = lang("STORY_BACKDES"), color = cc.c3b(255, 230, 200),width = self._worldTipBg:getContentSize().width - 20, fontsize = 18})
    labTeamDes:setAnchorPoint(0.5, 0.5)
    labTeamDes:setPosition(self._worldTipBg:getContentSize().width * 0.5 , self._worldTipBg:getContentSize().height * 0.5 + 20)
    self._worldTipBg:addChild(labTeamDes)


    local viewBtn = ccui.Button:create("globalButtonUI13_1_2.png", "globalButtonUI13_1_2.png", "", 1)
    viewBtn:setTitleFontName(UIUtils.ttfName)
    viewBtn:setTitleText("剧情回顾")
    viewBtn:setTitleFontSize(24)
    viewBtn:ignoreContentAdaptWithSize(false)
    viewBtn:setPosition(self._worldTipBg:getContentSize().width * 0.5, 10)
    viewBtn:setAnchorPoint(0.5, 0)
    viewBtn:setScaleAnim(true)
    self._parentView:L10N_Text(viewBtn)
    self._worldTipBg:addChild(viewBtn)
    registerTouchEvent(viewBtn, nil, nil, function()
        self._viewMgr:showDialog("intance.IntancePlotReviewView", {})
    end)
    -- 展开位置
    self._worldSubBg.mPositionY = MAX_SCREEN_HEIGHT - self._worldTipBg:getContentSize().height - self._worldSubBg:getContentSize().height - 8

    self._worldSubBg.runOpenAction = function(sender, anim, close)
        self._lockTouch = true
        local y = 0
        local openBtn = sender:getChildByName("openBtn")
        local isShow 
        if close == true then 
            if sender.isOpen then
                y = sender.positionY 
                isShow = false
                openBtn:setRotation(180)
                self._lockTouch = false
            else
                return
            end
        else
            if sender.isOpen then 
                y = sender.positionY 
                isShow = false
                openBtn:setRotation(180)
            else 
                isShow = true
                self._worldTipBg:setVisible(isShow)
                y = sender.mPositionY 
                openBtn:setRotation(0)

                local bgTouch = ccui.Widget:create()
                bgTouch:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
                bgTouch:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT* 0.5)
                self:addChild(bgTouch, 1)
                self._worldSubBg.bgTouch = bgTouch
                registerClickEvent(bgTouch, function()
                    if self._lockTouch == true then return end
                    bgTouch:removeFromParent()
                    self._worldSubBg.bgTouch = nil
                    self._worldSubBg:runOpenAction(true)
                end)
            end
        end
        sender.isOpen = not sender.isOpen
        if anim == true then
            print("y==================", y)
            sender:runAction(cc.Sequence:create(
                cc.MoveTo:create(0.2, cc.p(sender:getPositionX(), y)),
                cc.CallFunc:create(function()
                    self._lockTouch = false
                    self._worldTipBg:setVisible(isShow)
                    if isShow == false then 
                        if self._worldSubBg.bgTouch ~= nil then 
                            self._worldSubBg.bgTouch:removeFromParent(true)
                            self._worldSubBg.bgTouch = nil
                        end
                    end
                end)
                ))
        else
            self._lockTouch = false
            self._worldTipBg:setVisible(isShow)
            sender:setPosition(sender:getPositionX(), y)
        end
    end

    self:screenToSize(1)

    local mainsData = self._intanceModel:getData().mainsData
    if mainsData.curStageId > IntanceConst.GUILDE_SWITCH_WORLD_STAGE_ID then
        self:standByFirstEnterAction()
        self._worldElementLayer:standByFirstEnterAction()

        ScheduleMgr:delayCall(0, self, function()
            self._worldElementLayer:runFirstEnterAction()
            self:runFirstEnterAction()
        end)
    end
    self:updateGvgQipao()

    self._modelMgr:registerTimer(4,55,1,self,specialize(self.updateOnTime, self))
    self._modelMgr:registerTimer(5,10,5,self,specialize(self.updateOnTime, self))
    self._modelMgr:registerTimer(19,45,2,self,specialize(self.updateOnTime, self))
    self._modelMgr:registerTimer(20,00,2,self,specialize(self.updateOnTime, self))
    self._modelMgr:registerTimer(20,45,2,self,specialize(self.updateOnTime, self))
    -- self._modelMgr:registerTimer(5,0,10,self,specialize(self.showSiegeFireAnimation, self))
    

    self:showSiegeFireAnimation()
end

--[[
    五点刷新
]]
function IntanceWorldLayer:updateOnTime()
    print("IntanceWorldLayer:updateOnTime")
    if self._worldElementLayer ~= nil then 
        self._worldElementLayer:resetLeftBtnState()
    else
        print("$$$$$$$$$$$$$$$$$$")
    end
end
--[[
    更新gvg气泡
    积分奖励气泡
]]
function IntanceWorldLayer:updateGvgQipao()
    local citybattleModel = self._modelMgr:getModel("CityBattleModel")
    if citybattleModel:checkIsGvgOpen() then
        self._serverMgr:sendMsg("CityBattleServer", "getPoint", {}, false, {}, function (result, error)
            if result then
                citybattleModel:setRewardRedData(result)
            end
            if self._worldElementLayer ~= nil then 
                self._worldElementLayer:initLeftBtnTip()
            end
        end)
    end
end

--[[
    攻城战底部火焰特效
]]
function IntanceWorldLayer:showSiegeFireAnimation()
    mcMgr:loadRes("duizhanui", function ()
        local isShow, statusData = self._siegeModel:getEntranceState()
        if isShow and statusData and statusData.status < self._siegeModel.STATUS_PREOVER then
            if not self._siegeFire1 then
                local mc = mcMgr:createViewMC("buffguangxiaoxia_duizhanui", true,false)
                self:addChild(mc,0)
                mc:setPosition(100,-50)
                mc:setScale(2)
                self._siegeFire1 = mc
            end
            if not self._siegeFire2 then
                local mc = mcMgr:createViewMC("buffguangxiaoxia_duizhanui", true,false)
                self:addChild(mc,0)
                mc:setScale(3)
                mc:setPosition(MAX_SCREEN_WIDTH*0.5,-180)
                self._siegeFire2 = mc
            end
            if not self._siegeFire3 then
                local mc = mcMgr:createViewMC("buffguangxiaoxia_duizhanui", true,false)
                self:addChild(mc,0)
                mc:setScale(2.5)
                mc:setPositionX(MAX_SCREEN_WIDTH-20)
                self._siegeFire3 = mc
            end
        else
            if not tolua.isnull(self._siegeFire1) then
                self._siegeFire1:removeFromParent(true)
                self._siegeFire1 = nil
            end
            if not tolua.isnull(self._siegeFire2) then
                self._siegeFire2:removeFromParent(true)
                self._siegeFire2 = nil
            end
            if not tolua.isnull(self._siegeFire3) then
                self._siegeFire3:removeFromParent(true)
                self._siegeFire3 = nil
            end
        end
    end)
end

function IntanceWorldLayer:onExit()
    IntanceWorldLayer.super.onExit(self)
    setMultipleTouchDisabled()

    if self._countDownId then
        ScheduleMgr:unregSchedule(self._countDownId)
        self._countDownId = nil
    end
    if self._scrollSchedule then
        ScheduleMgr:unregSchedule(self._scrollSchedule)
        self._scrollSchedule = nil
    end
    ScheduleMgr:cleanMyselfDelayCall(self) 
    _speed = nil
    local intanceData = self._intanceModel:getData()
    if intanceData ~= nil and intanceData.mainsData ~= nil and intanceData.mainsData.acSectionId ~= nil and self._lastSectionId ~= nil then
        local acSectionId = intanceData.mainsData.acSectionId
        if self._lastSectionId < acSectionId and (IntanceConst.FIRST_SECTION_ID + 1) == acSectionId then 
            ViewManager:getInstance():doCustomGuide("IntanceWorldLayer" .. acSectionId )
        end
    end
    UIUtils:reloadLuaFile("intance.IntanceWorldLayer")
end


function IntanceWorldLayer:onHide()
    setMultipleTouchDisabled()
    self:lockTouch()
    if self._scrollSchedule then
        ScheduleMgr:unregSchedule(self._scrollSchedule)
        self._scrollSchedule = nil
    end    
end

function IntanceWorldLayer:onTop()
    setMultipleTouchEnabled()
    if self.__guideLock  ~= true then 
        self:unLockTouch()
    end
    local userLvl = self._userModel:getData().lvl
    if self._cacheUserLvl < userLvl then

        if self._worldElementLayer ~= nil then 
            self._worldElementLayer:resetLeftBtnState()
        end
        self:initOtherViewBtn()
    end
    self:initOtherViewBtnTip()

    if self._worldElementLayer ~= nil then 
        self._worldElementLayer:updateExtendBar()
        self._worldElementLayer:initLeftBtnTip()
    end
    -- self._worldSubBg:runOpenAction(false, true)

    self:siegeEffectLimite()
    if self._curSelectedFun ~= nil then 
        self:quickShowBtn(self._curSelectedFun)
        self._curSelectedFun = nil
    end

    if IntanceConst.CACHE_GUIDE_LEVEL_JUMP == 1 then 
        IntanceConst.CACHE_GUIDE_LEVEL_JUMP = 0
        self:quickCheckActiveNewSection()
    end
end

function IntanceWorldLayer:onEnter()
    print("IntanceWorldLayer:onEnter")
    IntanceWorldLayer.super.onEnter(self)
    setMultipleTouchEnabled()
end

--[[
--! @function loadBigMap
--! @desc 加载大地图
--! @return 
--]]
function IntanceWorldLayer:loadBigMap()
    self._usingIcon = {}
    self._sectionIcon = {}
    if self._bgLayer ~= nil then self._bgLayer:removeFromParent() self._bgLayer = nil end
    cc.Texture2D:setDefaultAlphaPixelFormat(RGB565)
    self._bgLayer = cc.Sprite:create()
    self._bgLayer:setName("bgLayer")
    self._sceneLayer:addChild(self._bgLayer)
    self._bgLayer:setTexture("asset/uiother/map/chaodaditu.jpg")
    self._bgLayer:setPosition(self._bgLayer:getContentSize().width/2, self._bgLayer:getContentSize().height/2)
    self._bgLayer:setAnchorPoint(0.5, 0.5)
    self._bgLayer:setScale(IntanceConst.SCENE_SCALE_INIT)
    cc.Texture2D:setDefaultAlphaPixelFormat(RGBAUTO)

    self._curSectionAction = mcMgr:createViewMC("dangqianguan1_intancejiantou", true, false)
    self._curSectionAction:setCascadeOpacityEnabled(true, true)
    self._curSectionAction:setOpacity(255)
    self._bgLayer:addChild(self._curSectionAction, 10)


    self._curSectionAction1 = mcMgr:createViewMC("dangqianguan2_intancejiantou", true, false)
    self._curSectionAction1:setCascadeOpacityEnabled(true, true)
    self._curSectionAction1:setOpacity(255)
    self._bgLayer:addChild(self._curSectionAction1, 16)
    self._curSectionAction1:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2)
   

    self._maxHorBlockNum = math.floor(self._bgLayer:getContentSize().width / 50)
    
    local bgWidth = self._bgLayer:getContentSize().width
    local bgHeight = self._bgLayer:getContentSize().height

    -- 生成章信息
    -- local mainsData = self._intanceModel:getData().mainsData
    -- self._canDoSectionId =  tonumber(string.sub(mainsData.curStageId, 1 , 5))


    self._endSectionId = tab:Setting("G_FINISH_SECTION_STORY").value
    local sysMainSection = tab:MainSection(self._endSectionId)
    local lastStageId = sysMainSection.includeStage[#sysMainSection.includeStage]
    local userStageInfo = self._intanceModel:getStageInfo(lastStageId)
    self._endStageState = 0
    if userStageInfo.star > 0 then 
        self._endStageState = 1
    end

    self._curSectionId = self._intanceModel:getCurMainSectionId()
    self._lastSectionId = self._curSectionId
    if self._actNewSectionId ~= nil then
        self._lastSectionId = self._actNewSectionId - 1
    end

    self._storyGroup = {}
    self._openArea = {}
    for k,v in pairs(tab.mainStory) do
        self:updateStoryInfo(v.id)
    end

    -- 第一章默认开启
    -- self:updateSectionInfo(IntanceConst.FIRST_SECTION_ID, true)

    self._touchYun = nil
    ScheduleMgr:delayCall(0, self, function()
                self._touchYun = mcMgr:createViewMC("yun_intancestory", true, false)
                self._touchYun:setPosition(self._bgLayer:getContentSize().width/2 + 200, self._bgLayer:getContentSize().height/2 - 100)
                self._touchYun:setCascadeOpacityEnabled(true, true)
                self._touchYun:setOpacity(0)
                self._bgLayer:addChild(self._touchYun, 99)
                self._touchYun:setScale(1.3)
                self._touchYun.moveChildren = {}
                -- 记录初始位置
                for i=1,3 do
                    self._touchYun.moveChildren[i] = self._touchYun:getChildren()[i]
                    self._touchYun.moveChildren[i].cacheInitX = self._touchYun:getChildren()[i]:getPositionX()
                end
                self._touchYun:runAction(cc.FadeIn:create(1))
                self:adjustMapPos(true)
            end)

 

    local hideImgPos = {{1022, 1344}, {686, 447}, {1710, 730}}
    
    local hideImgPos1 = {{668* 1.428571, 925* 1.428571}, {686, 447}, {1230* 1.428571, 520* 1.428571}}
    
    -- 美化信息
    for i=1,3 do
        if i ~= 2 then
            local name = "world_hide_story" .. i .. ".png"
            if i == 1 then 
                name = "world_hide_story" .. i .. "_2.png"
            end
            local tempHideImg = cc.Sprite:createWithSpriteFrameName(name)
            tempHideImg:setPosition(hideImgPos[i][1], hideImgPos[i][2])
            tempHideImg:setAnchorPoint(cc.p(0.5, 0.5))
            self._bgLayer:addChild(tempHideImg)
            tempHideImg:setScale(2)

            local tempTip1 = cc.Sprite:createWithSpriteFrameName("world_temp_3.png")
            tempTip1:setPosition(hideImgPos1[i][1], hideImgPos1[i][2])
            tempTip1:setAnchorPoint(0.5, 0.5)
            self._bgLayer:addChild(tempTip1, 3)
        end
    end

    if not self._scrollSchedule then
        self._scrollSchedule = ScheduleMgr:regSchedule(0.001, self, function()
            if self.adjustMapPos == nil then ScheduleMgr:unregSchedule(self._scrollSchedule) return end
            self:adjustMapPos(false)
        end)
    end
    self:updateCurSectionMcByStoryId(self._curStoryId)

    self:initOtherViewBtn()
    self:initOtherViewBtnTip()
end

--[[
--! @function initOtherViewBtn
--! @desc 初始化跳转其他页面按钮
--! @return 
--]]
function IntanceWorldLayer:initOtherViewBtn()
    --   normal=按钮名称, pos=坐标, view=名称, title=标题, 
    --   sysName=名称, param=参数, imgTitle=图片title, tOffset标题偏移
    self._funOpenList = {
        et = {  
                id = 1,
                normal = "world_elite_btn", 
                unActImg = "world_elite_btn_unact",
                unActAnim = nil,
                actAnim = "dixiacheng_worldunopenfun",
                actOffset = {0, -40},
                pos = {773, 552}, 
                size = {120, 120}, 
                view = "intance.IntanceEliteView", 
                title = "地下城",
                sysName = "Elite", 
                param = {},
                imgTitle = "world_elite_btn_title"
            },
        mf = {  
                id = 2,
                normal = "world_mf_btn",
                unActImg = "world_mf_btn_unact",
                unActAnim = nil,
                actAnim = "chuanwukaiqi_worldunopenfun",
                actDelayFrame = 26,
                actOffset = {0, 0},
                pos = {448, 477}, 
                size = {120, 120}, 
                view = "MF.MFView", 
                title = "船坞",
                sysName = "MF", 
                param = {},
                imgTitle = "world_mf_btn_title"
            },
        ct = {  
                id = 3,
                normal = "world_cloudcity_btn", 
                unActImg = nil, 
                unActAnim = "yunzhongcheng_worldunopenfun",
                unActAnimScale = 2,
                actAnim = "yunzhongchengkaiqiyun_worldunopenfun",
                actDelayFrame = 7,
                actOffset = {0, 0},
                pos = {1015, 662}, 
                size = {113, 122}, 
                view = "cloudcity.CloudCityView", 
                title = "云中城", 
                sysName = "CloudCity", 
                param = {},
                imgTitle = "world_cloudcity_btn_title", 
            },
        gd = {  
                id = 4,
                normal = "world_guild_btn", 
                unActImg = "world_guild_btn_unact", 
                unActAnim = nil,
                actAnim = nil,
                actDelayFrame = nil,
                actOffset = {0, 0},
                normalAnim = "chuansongmenhuang_intanceportal", 
                pos = {709, 721}, 
                size = {150, 122}, 
                view = "guild.map.GuildMapView", 
                title = "联盟探索", 
                sysName = "GuildMap", 
                param = {},
                imgTitle = "world_guild_btn_title", 
            },
         el = {  
                id = 5,
                normal = "world_element_btn", 
                unActImg = "world_element_btn_unact", 
                actAnim = "weimianchuxianshanguang_weimianrukou",
                actDelayFrame = nil,
                actOffset = {0, 0},
                pos = {1380, 760}, 
                size = {100, 130}, 
                view = "elemental.ElementalView", 
                title = "元素位面", 
                sysName = "Element", 
                param = {},
                imgTitle = "world_guild_btn_title", 
            },
          si = {  
                id = 6,
                normal = "world_siege_btn", 
                unActImg = "world_siege_btn", 
                unActAnim = "gongchengweikaiqi_gongchengrukou",
                actAnim = nil,
                actDelayFrame = 25,
                actOffset = {0, 0},
                normalAnim = nil, 
                pos = {875, 1000}, 
                size = {159, 151}, 
                view = "siege.SiegeMapView", 
                title = "斯坦德威克", 
                sysName = "Siege", 
                param = {},
                imgTitle = "", 
                tOffset = {0, -10}
            },   
            pr = {  
                id = 7,
                normal = "world_purgatory_btn", 
                unActImg = "world_purgatory_btn", 
                unActAnim = nil,
                actAnim = "kaiqi_wujinlianyurukou",
                normalAnim = "wujinlianyu_wujinlianyurukou", 
                normalAnimScale = 1,
                actDelayFrame = nil,
                actOffset = {0, 0},
                pos = {670, 1430}, 
                size = {109, 109}, 
                view = "purgatory.PurgatoryView", 
                title = "无尽炼狱", 
                sysName = "Purgatory", 
                param = {},
                tOffset = {0, 10}
            },          
    }--
    for k,v in pairs(self._funOpenList) do
        local tempBtn = self._bgLayer:getChildByName(v.normal)
        if tempBtn ~= nil then 
            if tempBtn.clear ~= nil then
                tempBtn.clear()
            end
            tempBtn:removeFromParent()
        end
    end
    for i,v in pairs(self._funOpenList) do
        self:addBtnFunction(i, v)
    end


    SystemUtils.saveAccountLocalData("IWFunOpenMinLevel", 0)
    SystemUtils.saveAccountLocalData("IWFunOpenMaxLevel", 0)
end

function IntanceWorldLayer:initOtherViewBtnTip()
    self._worldTipRichText = nil
    local mainViewModel = self._modelMgr:getModel("MainViewModel")
    local worldTips = mainViewModel:getWorldTipsQipao()
    for k,v in pairs(self._funOpenList) do
        local tempBtn = self._bgLayer:getChildByName(v.normal)
        if tempBtn ~= nil then 
            if tempBtn:getChildByName("qipao") ~= nil then 
                tempBtn:getChildByName("qipao"):removeFromParent()
            end
        end
    end

    for i=1, #worldTips do
        if worldTips[i].callback ~= nil and  worldTips[i]:callback() == true then 
            local sysQiqao = tab:Qipao(worldTips[i].id)
            if sysQiqao ~= nil then 
                local tempBtn = self._bgLayer:getChildByName(sysQiqao.btn)
                local tempQipaoNode = UIUtils:addShowBubble(nil, sysQiqao)
                if tempBtn ~= nil and tempBtn.isOpen == true and  tempQipaoNode ~= nil then
                    tempQipaoNode:setName("qipao")
                    tempBtn:addChild(tempQipaoNode)
                    if tempQipaoNode:getChildByName("richText") ~= nil then
                        self._worldTipRichText = tempQipaoNode:getChildByName("richText"):getVirtualRenderer()
                    end
                    if sysQiqao.position_rank ~= nil and sysQiqao.position_rank == 1 then 
                        self._quickShowBtnWithQipao = tempBtn.id
                    end
                    break
                end
            end
        end
    end
end

function IntanceWorldLayer:getWorldTipRichText()
    return self._worldTipRichText
end

function IntanceWorldLayer:addBtnFunction(key, data)
    local btn = ccui.Widget:create()
    if data.size ~= nil then
        btn:setContentSize(data.size[1], data.size[2])
    end
    btn.id = key
    btn.funName = data.sysName
    btn:setAnchorPoint(cc.p(0.5, 0))
    btn:setPosition(data.pos[1], data.pos[2])
    btn:setName(data.normal)
    self._bgLayer:addChild(btn, 15)

    local isOpen, toBeOpen, level = SystemUtils["enable".. data.sysName]()
    local isShowOpenLv = true
    if btn.funName == "Siege" then
        isOpen = self._modelMgr:getModel("SiegeModel"):getEntranceState()
        isShowOpenLv = false
    end

    local minLevel = SystemUtils.loadAccountLocalData("IWFunOpenMinLevel")
    if minLevel == nil then 
        minLevel = 0
    end
    -- minLevel = 10
    local maxLevel = SystemUtils.loadAccountLocalData("IWFunOpenMaxLevel")
    if maxLevel == nil then 
        maxLevel = 0
    end
        -- maxLevel = 80
    -- isOpen = false
    local delayTimeOpen = false
    if btn.funName ~= "Siege" then
        if maxLevel ~= 0 and minLevel ~= 0 and isOpen == true then 
            if maxLevel >= level and level > minLevel then 
                delayTimeOpen = true
            end
        end
    end

--    -- 攻城战开启单独判断
--    if btn.funName == "Siege" and isOpen == true and SystemUtils.loadAccountLocalData("SiegeOpen") == nil then
--        delayTimeOpen = true
--    end

    if data.title ~= nil and btn.titleBg == nil then
        local titleBg = cc.Scale9Sprite:createWithSpriteFrameName("title_bg_main.png")
        titleBg:setContentSize(105 , titleBg:getContentSize().height)
        if data.tOffset then
            titleBg:setPosition(btn:getContentSize().width * 0.5 + 10 + data.tOffset[1], btn:getContentSize().height * 0.5 - 40 + data.tOffset[2])
        else
            titleBg:setPosition(btn:getContentSize().width * 0.5 + 10, btn:getContentSize().height * 0.5 - 40)
        end
        btn:addChild(titleBg, 1)

        local titleLab = cc.Label:createWithTTF(data.title, UIUtils.ttfName, 18)
        titleLab:setAnchorPoint(0.5, 0.5)
        titleLab:setPosition(titleBg:getContentSize().width * 0.5, titleBg:getContentSize().height * 0.5)
        titleLab:setCascadeOpacityEnabled(true, true)
        titleBg:addChild(titleLab)
        titleLab:setColor(UIUtils.colorTable.ccBuildNameColor)
        titleLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        
        btn.titleBg = titleBg
        btn.titleLab = titleLab
        if data.sysName == "GuildMap" then 
            titleBg:setPositionX(titleBg:getPositionX() + 8)
        elseif data.sysName == "Purgatory" then
            titleBg:setPositionX(titleBg:getPositionX() + 10)
        end
    end    

    print("minLevel=================================", key, minLevel, maxLevel, isOpen, delayTimeOpen)
    btn.isOpen = false
    btn.unActive = function(sender)
        if sender.titleBg ~= nil then 
            sender.titleBg:setVisible(true)
        end
        sender.isOpen = false
        if data.unActImg ~= nil then
            local unActiveImg = ccui.ImageView:create()
            unActiveImg:loadTexture(data.unActImg .. ".png",1)
            if data.size == nil then
                sender:setContentSize(unActiveImg:getContentSize().width, unActiveImg:getContentSize().height)
            end            
            unActiveImg:setAnchorPoint(cc.p(0.5, 0.5))
            unActiveImg:setPosition(sender:getContentSize().width * 0.5, sender:getContentSize().height * 0.5)
            unActiveImg:ignoreContentAdaptWithSize(false)
            sender:addChild(unActiveImg)
            unActiveImg:setPosition(sender:getContentSize().width * 0.5, sender:getContentSize().height * 0.5)
        end

        if data.unActAnim ~= nil then
            -- local normalImg = ccui.ImageView:create()
            -- normalImg:loadTexture(data.normal .. ".png",1)
            -- if data.size == nil then
            --     sender:setContentSize(normalImg:getContentSize().width, normalImg:getContentSize().height)
            -- end            
            -- normalImg:setAnchorPoint(cc.p(0.5, 0.5))
            -- normalImg:setPosition(sender:getContentSize().width * 0.5, sender:getContentSize().height * 0.5)
            -- normalImg:ignoreContentAdaptWithSize(false)
            -- sender:addChild(normalImg)

            local unActiveAnim = mcMgr:createViewMC(data.unActAnim, true)
            unActiveAnim:setPosition(sender:getContentSize().width * 0.5, sender:getContentSize().height * 0.5)
            sender:addChild(unActiveAnim)
            unActiveAnim:setCascadeOpacityEnabled(true, true)
            if data.unActAnimScale then
                unActiveAnim:setScale(data.unActAnimScale)
            end

            print("unActiveAnim:get======", unActiveAnim:getContentSize().width, unActiveAnim:getContentSize().height)
        end

        -- local numLimitImg = IntanceUtils:convertToImgNum(level, "world_num_", "world_level_limit.png")
        -- numLimitImg:setPosition(sender:getContentSize().width * 0.5, sender:getContentSize().height * 0.5 - 10)
        -- sender:addChild(numLimitImg, 1)  

        if isShowOpenLv then
            local numLimitLab = cc.Label:createWithTTF(level .. "级开启", UIUtils.ttfName, 18)
            numLimitLab:setAnchorPoint(0.5, 0.5)
            numLimitLab:setPosition(sender:getContentSize().width * 0.5 + 10, numLimitLab:getContentSize().height - 25)
            numLimitLab:setCascadeOpacityEnabled(true, true)
            numLimitLab:setColor(cc.c4b(205, 204, 205,255))
            numLimitLab:enableOutline(cc.c4b(0, 0, 0,255), 1)
            sender:addChild(numLimitLab)
            sender.numLimitLab = numLimitLab
            if sender.funName == "Purgatory" then
                numLimitLab:setPositionX(numLimitLab:getPositionX() + 10)
            end
        end

        if sender.titleBg ~= nil then
            sender.titleBg:setSaturation(-150)
        end

        if sender.funName == "Siege" then
            self:initSiegeBtn(sender, false)
        end    

        -- local whiteTitle = cc.Sprite:createWithSpriteFrameName(data.normal .. "_b.png")
        -- whiteTitle:setPosition(sender:getContentSize().width * 0.5, sender:getContentSize().height * 0.5 - 40)
        -- sender:addChild(whiteTitle, 1)
        -- whiteTitle:setScale(0.8)

        -- local whiteTitleBg = cc.Scale9Sprite:createWithSpriteFrameName("world_star_num_bg.png")
        -- whiteTitleBg:setContentSize(whiteTitle:getContentSize().width, 20)
        -- whiteTitleBg:setAnchorPoint(cc.p(0.5, 0.5))
        -- whiteTitleBg:setPosition(sender:getContentSize().width * 0.5, sender:getContentSize().height * 0.5 - 40)
        -- sender:addChild(whiteTitleBg)
        -- whiteTitleBg:setScale(0.8)
    end
    
    btn.normal = function(sender)

        if sender.titleBg ~= nil then 
            sender.titleBg:setVisible(true)
        end
        sender.isOpen = true
        local normalImg = ccui.ImageView:create()
        normalImg:loadTexture(data.normal .. ".png",1)
        if data.size == nil then
            sender:setContentSize(normalImg:getContentSize().width, normalImg:getContentSize().height)
        end            
        normalImg:setAnchorPoint(cc.p(0.5, 0.5))
        normalImg:setPosition(sender:getContentSize().width * 0.5, sender:getContentSize().height * 0.5)
        normalImg:ignoreContentAdaptWithSize(false)
        sender:addChild(normalImg)
        sender.normalImg = normalImg

        if sender.titleBg ~= nil then
            sender.titleBg:setSaturation(0)
        end

        if sender.numLimitLab ~= nil then
            sender.numLimitLab:setVisible(false)
        end

        -- if data.imgTitle ~= "" then
        --     local btnTitle = ccui.ImageView:create()
        --     btnTitle:loadTexture(data.imgTitle .. ".png",1)  
        --     btnTitle:setAnchorPoint(cc.p(0.5, 0.5))
        --     btnTitle:setPosition(data.pos[1], data.pos[2])
        --     btnTitle:ignoreContentAdaptWithSize(false)
        --     self._bgLayer:addChild(btnTitle, 15)
        --     if data.tOffset ~= nil then 
        --         btnTitle:setPosition(data.pos[1] + data.tOffset[1], data.pos[2] + data.tOffset[2])
        --     end
        -- end
        if data.normalAnim ~= nil then
            local anim = mcMgr:createViewMC(data.normalAnim, true)
            if data.normalAnimScale and data.normalAnimScale == 1 then
                anim:setPosition(sender:getContentSize().width * 0.5, sender:getContentSize().height * 0.5)
            else
                anim:setPosition(sender:getContentSize().width * 0.5 + 20, sender:getContentSize().height * 0.5 -5)
                anim:setScale(-0.5)
                anim:setScaleX(-0.5)
            end
            sender:addChild(anim)
        end

        self:registerTouchEventWithLight(btn, function()
            if self._lockTouch == true then return end
            if data.view == nil then
                 return
            end
            if self._endStageState == 1 then
                SystemUtils.saveAccountLocalData(IntanceConst.USE_SELECT_SECTION, "2_" .. key)
            end
            self._curSelectedFun = key
            if key == "gd" then
                local guildId = self._userModel:getData().guildId
                print("guildId=============", guildId)
                if guildId == nil or guildId == 0 then 
                    local param = {indexId = 9}
                    self._viewMgr:showDialog("global.GlobalPromptDialog", param)
                    return
                end
            end
            if key == "si" then
                self:showSiegeView()
                return
            end
            if key == "pr" then
                local purModel = self._modelMgr:getModel("PurgatoryModel")
                local open, txt = purModel:isOpenPurgatory()
                if open then
                    self._viewMgr:showView(data.view, data.param)
                else
                    self._viewMgr:showTip(txt)
                end
                return
            end
            self._viewMgr:showView(data.view, data.param)
        end)   
        
        if sender.funName == "Siege" then
            self:initSiegeBtn(sender, true)
        end     
    end

    btn.active = function(sender, callback)
        print("btn.active=======================")
        -- 不跳转镜头是因为新手引导会出发移动镜头
        -- self:screenToPos(data.pos[1], data.pos[2], true, function()
            if data.actDelayFrame == nil then 
                if sender.titleBg ~= nil then 
                    sender.titleBg:setVisible(false)
                end
                sender:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.8),
                cc.CallFunc:create(function()
                    sender:normal()
                end)
                ))
            end
            if data.actAnim == nil then if callback ~= nil then callback() end return end

            local activeAnim = mcMgr:createViewMC(data.actAnim, false, true, function()
                if callback ~= nil then callback() end
            end)  
            
            self._bgLayer:addChild(activeAnim, 20)
            activeAnim:setCascadeOpacityEnabled(true, true)
            if data.actOffset ~= nil then 
                activeAnim:setPosition(data.pos[1] + data.actOffset[1], data.pos[2] + sender:getContentSize().height * 0.5 + data.actOffset[2])
            else
                activeAnim:setPosition(data.pos[1], data.pos[2] + sender:getContentSize().height * 0.5)
            end
            if data.actDelayFrame ~= nil then 
                activeAnim:addCallbackAtFrame(data.actDelayFrame, function()
                    sender.titleBg = nil
                    sender.titleLab = nil
                    sender:removeAllChildren()
                    sender.numLimitLab = nil
                    sender:normal()
                end)
            end
            -- activeAnim:setVisible(false)
        -- end, nil, nil, 0.5)
    end
    if isOpen == false or (isOpen == true and delayTimeOpen == true) then 
        btn:unActive()
        if isOpen == true then 
            btn.delayTimeOpen = true
        end
    elseif isOpen == true and delayTimeOpen == false then 
        btn:normal()
    end
    

   
    -- btn:normal()
    -- local isOpen, toBeOpen, level = SystemUtils["enable"..systemName]()



    -- if imgtitle ~= "" then
    --     local btnTitle = ccui.ImageView:create()
    --     btnTitle:loadTexture(imgtitle .. ".png",1)  
    --     btnTitle:setAnchorPoint(cc.p(0.5, 0.5))
    --     btnTitle:setName(imgtitle)
    --     btnTitle:setPosition(pos[1], pos[2])
    --     btnTitle:ignoreContentAdaptWithSize(false)
    --     self._bgLayer:addChild(btnTitle, 15)
    --     btn.title = btnTitle
    -- end

    -- if titleOffset ~= nil and btn.title ~= nil then 
    --     btn.title:setPosition(btn.title:getPositionX() + titleOffset[1], btn.title:getPositionY() + titleOffset[2])
    -- end

    -- local isOpen = true
    -- local toBeOpen = true

    -- if systemName then
    --     isOpen, toBeOpen, level = SystemUtils["enable"..systemName]()
    -- end 

    -- btn.noSound = true
    -- btn:setScaleAnim(false)
    -- local touchX, touchY = 0, 0

    -- self:registerTouchEventWithLight(btn, function()
    --     if viewname == "" then
    --         return
    --     end
    --     if not isOpen and not GameStatic.openAllSystem then
    --         local systemOpenTip = tab.systemOpen[systemName][3]
    --         if not systemOpenTip then
    --             self._viewMgr:showTip(tab.systemOpen[systemName][1] .. "级开启")
    --         else
    --             self._viewMgr:showTip(lang(systemOpenTip))
    --         end
    --     else
    --         self._viewMgr:showView(viewname, param)
    --     end 
    -- end)
    -- if not isOpen and not GameStatic.openAllSystem then 
    --     btn:setColor(cc.c4b(0, 0, 0, 255))
    --     btn:setEnabled(false)
    --     if btn.title ~= nil then 
    --         btn.title:setVisible(false)  
    --     end
    --     if tab.systemOpen[systemName] then 
    --         local numLimitImg = IntanceUtils:convertToImgNum(tab.systemOpen[systemName][1], "world_num_", "world_level_limit.png")
    --         numLimitImg:setPosition(btn:getContentSize().width * 0.5, btn:getContentSize().height * 0.5 )
    --         btn:addChild(numLimitImg)
    --     end
    --     local whiteTitle = cc.Sprite:createWithSpriteFrameName(btnpic .. "_b.png")
    --     whiteTitle:setPosition(btn:getContentSize().width * 0.5, btn:getContentSize().height * 0.5 - 20)
    --     btn:addChild(whiteTitle)
    -- end
end

function IntanceWorldLayer:updateSiegeEntrance()
    local tempBtn = self._bgLayer:getChildByName(self._funOpenList["si"].normal)
    if tempBtn ~= nil then 
        if tempBtn.clear ~= nil then
            tempBtn.clear()
        end
        tempBtn:removeFromParent()
    end
    self:addBtnFunction("si", self._funOpenList["si"])

    self:showSiegeFireAnimation()
end

--[[
--! @function initSiegeBtn
--! @desc 特殊处理攻城战按钮
--! @return 
--]]
function IntanceWorldLayer:initSiegeBtn(btn, isActive)
    btn.clear = function()
        self:_updateCountDown("siege", nil)
    end

    local siegeModel = self._modelMgr:getModel("SiegeModel")
    local isOpen, stateData = siegeModel:getEntranceState()

    if stateData == nil then
        return
    end

    -- 全服没有超过90级玩家
    if stateData.status == siegeModel.STATUS_PRE and (stateData.playerNum == nil or stateData.playerNum == 0) then
        local label = self:_createLabel(
            "全服最高等级\n达到" .. tab:SiegeSetting(1).value .. "级启动", 
            16,cc.c4b(205, 204, 205,255), nil, cc.TEXT_ALIGNMENT_LEFT
        )
        label:enableOutline(cc.c4b(0, 0, 0,255), 1)
        label:setPosition(89, -14)
        btn:addChild(label)
        return 
    end

    -- 为满足80级参与等级
    if not isOpen and stateData.notEnable then
        local _,_,openLv = SystemUtils:enableSiege()
        local label = self:_createLabel(
            openLv .. "级可参与", 
            18,cc.c4b(205, 204, 205,255), nil, cc.TEXT_ALIGNMENT_LEFT
        )
        label:enableOutline(cc.c4b(0, 0, 0,255), 1)
        label:setPosition(89, -2)
        btn:addChild(label)
        return 
    end

    -- if not isActive then
    --     return 
    -- end 

    if isActive then
        if stateData.status >=  siegeModel.STATUS_SIEGE and stateData.status < siegeModel.STATUS_PREOVER then
            local anim = mcMgr:createViewMC("gongchenghuodong_gongchengrukou", true)
            anim:setPosition(btn:getContentSize().width * 0.5 -3, btn:getContentSize().height * 0.5)
            anim:setScale(0.9)
            btn:addChild(anim)
        end

        if isOpen then
            btn.normalImg:loadTexture("world_siegeActivity_btn.png", 1)
        end
    end

--    --TODO 屏蔽日常攻城战
--    if stateData.status == siegeModel.STATUS_OVER then
--        return
--    end
    local paoBg = nil
    if stateData.status < siegeModel.STATUS_OVER then
        paoBg = ccui.Scale9Sprite:createWithSpriteFrameName("globalImageUI_shout_qipaobg.png")
        paoBg:setCapInsets(cc.rect(60, 30, 1, 1))
        paoBg:setAnchorPoint(0, 0)
        paoBg:setPosition(67, 88)
        btn:addChild(paoBg, 1)
    end

    if stateData.status == siegeModel.STATUS_PRE then
        local label1 = self:_createLabel(
            "90级领主: " .. stateData.playerNum .. "人\n积分增长: " .. stateData.perScore .. "/天", 
            14,
            UIUtils.colorTable.ccUIBaseTextColor2, nil, cc.TEXT_ALIGNMENT_LEFT
        )
        label1:setAnchorPoint(0, 0.5)
        label1:setPosition(10, 52)
        paoBg:addChild(label1)

        local label2 = self:_createLabel(
            "开启积分: " .. stateData.score .. "/" .. stateData.maxScore .. "(五点更新)", 
            14,
            UIUtils.colorTable.ccUIBaseColor6, nil, cc.TEXT_ALIGNMENT_LEFT
        )
        label2:setAnchorPoint(0, 0.5)
        label2:setPosition(10, 27)
        paoBg:addChild(label2)

        paoBg:setContentSize(cc.size(label2:getContentSize().width + 19, 78))

        local shalouMc = mcMgr:createViewMC("shalou_mfhanghaifengweitexiao", true, false)
        shalouMc:setPosition(27, -17)
        paoBg:addChild(shalouMc)

    elseif stateData.status == siegeModel.STATUS_PRESIEGE then
        local label1 = self:_createLabel(self:_formatTimeStr(stateData.nextTime) .. "后攻城开启", 14,
            cc.c3b(63, 63, 63), nil, cc.TEXT_ALIGNMENT_CENTER)
        label1:setPosition(72, 35)
        paoBg:addChild(label1)

        paoBg:setContentSize(cc.size(146, 63))
        self:_updateCountDown("siege", function()
            if not tolua.isnull(label1) then
                label1:setString(self:_formatTimeStr(stateData.nextTime) .. "后攻城开启")
            end
        end)
    
        local shalouMc = mcMgr:createViewMC("shalou_mfhanghaifengweitexiao", true, false)
        shalouMc:setPosition(27, -17)
        paoBg:addChild(shalouMc)

    elseif stateData.status == siegeModel.STATUS_SIEGE then
        if stateData.isLastStage then
            local label1 = self:_createLabel("进攻主城", 16,
                cc.c3b(252, 255, 0), 1, cc.TEXT_ALIGNMENT_CENTER)
            label1:setPosition(58, 35)
            paoBg:addChild(label1)

            paoBg:setContentSize(cc.size(116, 63))

            local hpBg = ccui.Scale9Sprite:createWithSpriteFrameName("world_siegeHpBg.png")
            hpBg:setCapInsets(cc.rect(20, 9, 1, 1))
            hpBg:setContentSize(138, 18)
            hpBg:setPosition(23 , -90)
            hpBg:setScale(0.7)
            paoBg:addChild(hpBg)

            local hpBar = ccui.LoadingBar:create("world_siegeHp.png", 1, stateData.hpPercent)
            hpBar:setAnchorPoint(1, 0)
            hpBar:setOpacity(255)
            hpBar:setPosition(68, -93)
            paoBg:addChild(hpBar)
        else
            local label1 = self:_createLabel("城池围攻中", 16,
                cc.c3b(0, 255, 0), 1, cc.TEXT_ALIGNMENT_CENTER)
            label1:setPosition(58, 35)
            paoBg:addChild(label1)

            paoBg:setContentSize(cc.size(116, 63))
        end

    elseif stateData.status == siegeModel.STATUS_PREDEFEND then
        local label1 = self:_createLabel("攻占成功", 14,
            cc.c3b(0, 255, 0), 1, cc.TEXT_ALIGNMENT_CENTER)
        label1:setPosition(70, 44)
        paoBg:addChild(label1) 

        local label2 = self:_createLabel(self:_formatTimeStr(stateData.nextTime), 14,
            cc.c3b(255, 35, 0), 0, cc.TEXT_ALIGNMENT_CENTER)
        label2:setPosition(34, 26)
        paoBg:addChild(label2) 

        local label3 = self:_createLabel("后守城开始", 14,
            UIUtils.colorTable.ccUIBaseTextColor2, 0, cc.TEXT_ALIGNMENT_CENTER)
        label3:setPosition(96, 26)
        paoBg:addChild(label3) 
    
        paoBg:setContentSize(cc.size(140, 63))

        self:_updateCountDown("siege", function()
            if not tolua.isnull(label2) then
                label2:setString(self:_formatTimeStr(stateData.nextTime))
            end
        end)

        local siegeMc = mcMgr:createViewMC("jingong_citybattlechengchidianji", true)
        siegeMc:setPosition(10, -20)
        paoBg:addChild(siegeMc)

    elseif stateData.status == siegeModel.STATUS_DEFEND then
        local label1 = self:_createLabel("守城进行中", 14,
            cc.c3b(252, 255, 0), 1, cc.TEXT_ALIGNMENT_CENTER)
        label1:setPosition(75, 44)
        paoBg:addChild(label1) 

        local waves = stateData.waves
        if tonumber(waves) > 99999 then
            if tonumber(waves) > 99999999 then
                waves = tonumber(string.format("%0.2f",waves/100000000)).."亿"
            else
                waves = tonumber(string.format("%0.2f",waves/10000)).."万"
            end
        end

        local label2 = self:_createLabel("剩余敌人波数:" .. waves, 14,
            UIUtils.colorTable.ccUIBaseTextColor2, 0, cc.TEXT_ALIGNMENT_CENTER)
        label2:setPosition(75, 26)
        paoBg:addChild(label2) 

        paoBg:setContentSize(cc.size(150, 63))

    elseif stateData.status == siegeModel.STATUS_PREOVER then

        local label1 = self:_createLabel("守城成功", 14,
            cc.c3b(0, 255, 0), 1, cc.TEXT_ALIGNMENT_CENTER)
        label1:setPosition(70, 44)
        paoBg:addChild(label1) 

        local label2 = self:_createLabel(self:_formatTimeStr(stateData.nextTime), 14,
            cc.c3b(255, 35, 0), 0, cc.TEXT_ALIGNMENT_CENTER)
        label2:setPosition(34, 26)
        paoBg:addChild(label2) 

        local label3 = self:_createLabel("后活动结束", 14,
            UIUtils.colorTable.ccUIBaseTextColor2, 0, cc.TEXT_ALIGNMENT_CENTER)
        label3:setPosition(96, 26)
        paoBg:addChild(label3) 
    
        paoBg:setContentSize(cc.size(140, 63))

        self:_updateCountDown("siege", function()
            if not tolua.isnull(label2) then
                label2:setString(self:_formatTimeStr(stateData.nextTime))
            end
        end)

        local yanhuaMc = mcMgr:createViewMC("yanhua_gezhongdun", true, false)
        yanhuaMc:setPosition(30, 0)
        yanhuaMc:setScale(0.3)
        paoBg:addChild(yanhuaMc)

        btn.normalImg:loadTexture("world_siege_btn.png", 1)
    else 
        btn.normalImg:loadTexture("world_siege_btn.png", 1)
    end
end

function IntanceWorldLayer:showSiegeView()
    local siegeModel = self._modelMgr:getModel("SiegeModel")
    local stateData = siegeModel:getData()
    if stateData and stateData.status == siegeModel.STATUS_OVER then 
        self._viewMgr:showDialog("siegeDaily.SiegeDailySelectView")
    else
        self._viewMgr:showView("siege.SiegeMapView")
    end
end

-- 活动期间展示英雄对话气泡
-- 创建英雄对话气泡
function IntanceWorldLayer:createSiegeTalkBubble( data,callback )
    local isRight = data and data.flop == 2 or false
    local widget = ccui.Widget:create()
    widget:setCascadeOpacityEnabled(true)
    widget:setOpacity(0)
    local rtxStr = "[color=ffffff,fontsize=18]" .. (lang(data.words) or "") .. "[-]"
    local detectRtx = RichTextFactory:create(rtxStr,1000,40)
    detectRtx:formatText()
    local detectW = detectRtx:getRealSize().width

    local rtxW = detectW/2+10
    local rtx = RichTextFactory:create(rtxStr,rtxW,40)
    rtx:formatText()
    local w,h = rtx:getInnerSize().width,rtx:getInnerSize().height
    rtx:setPosition(-w/2,-h/2)
    widget:addChild(rtx,2)

    local talkBg = ccui.ImageView:create()
    talkBg:loadTexture("world_siege_talkbg.png",1)
    talkBg:setCapInsets(cc.rect(88,31,1,1))
    talkBg:setScale9Enabled(true)
    talkBg:setContentSize(cc.size(100+rtxW,62))
    talkBg:setPosition(-35-w/2,-h/2)
    widget:addChild(talkBg,-1)

    local hero = ccui.ImageView:create()
    hero:loadTexture(data.art,1)
    hero:setPosition(32,32)
    hero:setScale(0.8)

    local clipNode = cc.ClippingNode:create()
    clipNode:setPosition(0,0)
    local mask = cc.Sprite:createWithSpriteFrameName("globalImage_IconMaskCircle.png")
    mask:setPosition(31, 31)
    mask:setScale(0.48)
    clipNode:setStencil(mask)
    clipNode:setAlphaThreshold(0.5)
    clipNode:addChild(hero)
    clipNode:setCascadeOpacityEnabled(true)
    talkBg:addChild(clipNode, -1)

    widget:setPositionX(w/2+100)
    if isRight then
        talkBg:setScale(-1,1)
        talkBg:setPosition(-w/2+35,-h/2)
        -- hero:setScale(-1,1)
    end

    widget:runAction(cc.Sequence:create(
        cc.FadeIn:create(0.2),
        cc.DelayTime:create(0.8),
        cc.CallFunc:create(function( )
            if callback then 
                callback()
            end
        end)
    ))

    return widget
end

function IntanceWorldLayer:showSiegeHeroTalk( index, callback )
    local inActivity = true
    if inActivity then
        local allTalks = {}
        for i,v in ipairs(tab.siegeDialog) do
            if tonumber(v.part) == tonumber(index) then
                table.insert(allTalks,v)
            end
        end
        local btnName = self._funOpenList["si"] and self._funOpenList["si"]["normal"]
        local btn = self._bgLayer:getChildByName(btnName or "")
        local talkH = 70
        local offsetX = 300
        local offsetY = #allTalks*talkH
        local showTalk
        local talkNodes = {}
        local lock = true
        showTalk=function( idx )
            local talkD = allTalks[idx]
            if talkD then
                local talk = self:createSiegeTalkBubble(talkD,function( )
                    print(idx+1,"------------------------")
                    showTalk(idx+1)
                end)
                if btn and talk then
                    talkNodes[idx] = talk
                    talk:setPosition(btn:getPositionX() + 142, btn:getPositionY() + offsetY-idx*talkH)
                    self._bgLayer:addChild(talk,99)
                    btn:setColor(cc.c3b(0,0,0))
                end
            else
                ScheduleMgr:delayCall(2000,self,function( )
                    if self._siegeTalklock then
                        self._viewMgr:unlock()
                        self._siegeTalklock = false

                        if callback then
                            callback()
                        end
                    end
                    for k,v in pairs(talkNodes) do
                        if v then
                            v:removeFromParent()
                        end
                    end
                end)
            end
        end
        if not self._siegeTalklock then
            self._siegeTalklock = true
            self._viewMgr:lock(-1)
        end
        showTalk(1)
        ScheduleMgr:delayCall(10000,self,function( )
            if self._siegeTalklock then
                ViewManager:getInstance():unlock()
                self._siegeTalklock = false

                if callback then
                    callback()
                end
            end
        end)
    end
end


--[[
--! @function createLabel
--! @desc 创建label
--! @param str 文本内容
--! @param fontSize 字号
--! @param color 字色
--! @param outline 描边
--! @param hAlign 横向排版
--! @return 
--]]
function IntanceWorldLayer:_createLabel(str, fontSize, color, outline, hAlign)
    if str == nil then return end
    local label = cc.Label:createWithTTF(str, UIUtils.ttfName, fontSize)
    label:setAnchorPoint(0.5, 0.5)
    label:setCascadeOpacityEnabled(true, true)
    label:setColor(color)
    label:setAlignment(hAlign, cc.TEXT_ALIGNMENT_CENTER)
    if outline then
        label:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, outline)
    end
    return label
end

-- 转换倒计时时间格式
function IntanceWorldLayer:_formatTimeStr(toTime)
    local leftTime = toTime - self._userModel:getCurServerTime()
    if leftTime <= 86400 then
        return TimeUtils.getTimeString(leftTime)
    else
        return TimeUtils:getTimeDisByFormat(leftTime)
    end
end

-- 更新倒计时时间
function IntanceWorldLayer:_updateCountDown(key, callback)
    if self._countDownList == nil then
        self._countDownList = {}
    end
    self._countDownList[key] = callback
    if self._countDownId == nil then
        self._countDownId = ScheduleMgr:regSchedule(1000, self, function( )
            if self._countDownList[key] then
                self._countDownList[key]()
            end
        end)
    end
end

--[[
--! @function adjustCompassAngle
--! @desc 矫正指南针偏移角度
--! @return 
--]]
function IntanceWorldLayer:adjustCompassAngle()

end

--[[
--! @function adjustMapPos
--! @desc 矫正云偏移位置
--! @return 
--]]
local _speed = {0.2, 0.4, 0.8}
function IntanceWorldLayer:adjustMapPos(quickOffset)
    if (not self._touche1Down and not self._touche2Down) and not quickOffset then return end
    if self._worldCompass.pauseAuto == true then self:adjustCompassAngle() end

    if not self._touchYun then return end
    local x, y = self._sceneLayer:getPosition()
    for i=1, 3 do
        self._touchYun.moveChildren[i]:setPositionX(self._touchYun.moveChildren[i].cacheInitX + x * _speed[i])
    end
end

--[[
--! @function updateHeroUnlockInfo
--! @desc 更新英雄解锁信息
--！@param inSysStory 系统大章信息
--! @return 
--]]
function IntanceWorldLayer:updateHeroUnlockInfo(inSysStory)
    local MSReward = self._intanceModel:getData().mainsData.MSReward
    local lastSectionId = 0
    local tempSections = {}
    for k,v in pairs(inSysStory.include) do
        local sectionInfo = self._intanceModel:getSectionInfo(v)
        if sectionInfo.sr == nil then
            table.insert(tempSections, v)
        end
    end

    if #tempSections > 0 and  inSysStory.reward ~= nil then 
        local rewardHeroId = inSysStory.reward[1][2]
        for k,v in pairs(tempSections) do
            local tempSectionNode = self._bgLayer:getChildByName("Section_" .. v)
            if tempSectionNode ~= nil then 
                local spTip = cc.Sprite:createWithSpriteFrameName("intanceImage_heroUnlockIcon" .. rewardHeroId .. ".png")
                spTip:setAnchorPoint(0.5, 0.5)
                spTip:setPosition(tempSectionNode:getContentSize().width , tempSectionNode:getContentSize().height)
                tempSectionNode:addChild(spTip, 100)
                local seq = cc.Sequence:create(cc.ScaleTo:create(0.6, 1.2), cc.ScaleTo:create(0.6, 1))
                spTip:runAction(cc.RepeatForever:create(seq))            
            end
        end
    end
end

--[[
--! @function updateSectionInfo
--! @desc 点击章信息
--！@param inSectionId 章id
--！@param inIsVisible 是否可见
--! @return 
--]]
function IntanceWorldLayer:updateSectionInfo(inSectionId, inIsVisible)
    local sectionIndex = tonumber(string.sub(inSectionId, 3 , 5))
    local sysMainStageMap = tab:MainSectionMap(inSectionId)
    local sysMainSection = tab:MainSection(inSectionId)
    local sectionInfo = self._intanceModel:getSectionInfo(inSectionId)
    if sysMainStageMap.worldIcon ~= nil then 
        local sectionIcon = ccui.Widget:create()
      
        local spIcon = ccui.ImageView:create()
        spIcon:loadTexture(sysMainStageMap.worldIcon .. ".png",1)
        sectionIcon:setContentSize(cc.size(spIcon:getContentSize().width , spIcon:getContentSize().height))
        
        sectionIcon:setAnchorPoint(0.5, 0.5)
        sectionIcon:setPosition(sysMainStageMap.worldX, sysMainStageMap.worldY)

        spIcon:setAnchorPoint(0.5, 0.5)
        spIcon:setPosition(spIcon:getContentSize().width/2, spIcon:getContentSize().height/2)
        sectionIcon:addChild(spIcon)

        self:registerTouchEventWithLight(spIcon, nil)

        local spIcon1 = cc.Sprite:createWithSpriteFrameName(sysMainStageMap.worldIcon .. ".png")
        spIcon1:setAnchorPoint(0.5, 0.5)
        spIcon1:setPosition(spIcon1:getContentSize().width/2, spIcon1:getContentSize().height/2)
        sectionIcon:addChild(spIcon1)
        spIcon1:setSaturation(-200)
        spIcon1:setOpacity(150)
        spIcon1:setName("unactSectoin")
        

        local numLimitImg = IntanceUtils:convertSectionToImgNum(sectionIndex, "world_num_")
        numLimitImg:setAnchorPoint(0.5, 0.5)
        numLimitImg:setCascadeOpacityEnabled(true, true)
        numLimitImg:setPosition(spIcon:getContentSize().width/2, spIcon:getContentSize().height - 10)
        sectionIcon:addChild(numLimitImg, 2)
        sectionIcon.numLimitImg = numLimitImg

        local numLimitImgBg = cc.Scale9Sprite:createWithSpriteFrameName("world_star_num_bg.png")
        numLimitImgBg:setContentSize(numLimitImgBg:getContentSize().width, 20)
        numLimitImgBg:setAnchorPoint(cc.p(0.5, 0.5))
        numLimitImgBg:setPosition(spIcon:getContentSize().width/2, spIcon:getContentSize().height - 10)
        sectionIcon:addChild(numLimitImgBg)
        sectionIcon.numLimitImgBg = numLimitImgBg
  
       --设置宝箱领取状态 
        local flag = 0
        if self._curSectionId >= inSectionId then   
            for e,f in pairs(sysMainSection.starNum) do
                if f <= sectionInfo.num and sectionInfo[tostring(f)] == nil then 
                    flag = self._boxQuality[#sysMainSection.starNum][e]   --有奖励未领
                end
            end
            if flag == 0 then   --没有可领  
                if sectionInfo.num >= tonumber(sysMainSection.starNum[#sysMainSection.starNum]) then 
                    flag = -1   --领完
                end
            end
        else    
            flag = -2           --章节未开启
        end
        
        --增加宝箱提示
        local function rewardBtnAnim(rewardBtnBg)
            local boxLight = mcMgr:createViewMC("baoxiangguang1_baoxiang", true)
            boxLight:setPosition(rewardBtnBg:getContentSize().width/2, rewardBtnBg:getContentSize().height/2)
            boxLight:setName("box_light")
            rewardBtnBg:addChild(boxLight,10)
            boxLight:setCascadeOpacityEnabled(true, true)
            boxLight:setOpacity(rewardBtnBg:getOpacity())
            boxLight:setScale(0.7)

            local boxAnim = mcMgr:createViewMC("baoxiang3_baoxiang", true)
            boxAnim:setPosition(rewardBtnBg:getContentSize().width/2, rewardBtnBg:getContentSize().height/2)
            boxAnim:setName("box_anim")
            rewardBtnBg:addChild(boxAnim, 3)
            boxLight:setCascadeOpacityEnabled(true, true)
            boxLight:setOpacity(rewardBtnBg:getOpacity())
            boxAnim:setScale(0.7)
        end

        if flag > 0 then      --有箱子没领，星星够了
            local posX = sectionIcon:getContentSize().width + 5
            local posY = 30
            local rewardBtnBg = cc.Sprite:createWithSpriteFrameName("world_reword_box_bg.png")

            sectionIcon:addChild(rewardBtnBg, 20)
            rewardBtnBg:setPosition(cc.p(posX, posY))
            rewardBtnAnim(rewardBtnBg)
        end 

        local tips1 = {}
        tips1[1] = cc.Sprite:createWithSpriteFrameName("intanceImageUI4_star.png")
        tips1[1]:setScale(0.6)        
        tips1[2] = cc.Label:createWithTTF(sectionInfo.num, UIUtils.ttfName, 32)
        tips1[2]:setScale(0.5)
        tips1[3] = cc.Label:createWithTTF("/" .. sysMainSection.starNum[#sysMainSection.starNum], UIUtils.ttfName, 32)
        tips1[3]:setScale(0.5)
        if flag > 0 or flag == -1 then
            tips1[2]:setColor(cc.c4b(255, 255, 0, 255))
            tips1[3]:setColor(cc.c4b(255, 255, 0, 255))
        else
            tips1[2]:setColor(cc.c4b(255, 255, 255, 255))
            tips1[3]:setColor(cc.c4b(255, 255, 255, 255))
        end

        local nodeTip1 = UIUtils:createHorizontalNode(tips1, cc.p(0, 0.5))
        nodeTip1:setAnchorPoint(cc.p(0.5, 0.5))
        nodeTip1:setPosition(sectionIcon:getContentSize().width/2, 20)
        sectionIcon:addChild(nodeTip1, 2)
        sectionIcon.starNum = nodeTip1

        local starNumBg = cc.Sprite:createWithSpriteFrameName("world_star_num_bg.png")
        starNumBg:setAnchorPoint(cc.p(0.5, 0.5))
        starNumBg:setPosition(sectionIcon:getContentSize().width/2, 20)
        sectionIcon:addChild(starNumBg)
        sectionIcon.starNumBg = starNumBg

        tips1[3]:setPosition(tips1[3]:getPositionX(), tips1[3]:getPositionY() + 0.5)
        
       if self._curSectionId > inSectionId or ( self._endSectionId == self._curSectionId and self._endStageState == 1 ) then
            local tempSp = cc.Sprite:createWithSpriteFrameName("world_temp_2.png")
            tempSp:setPosition(spIcon:getContentSize().width/2, spIcon:getContentSize().height/2 + 5)
            sectionIcon:addChild(tempSp)
            tempSp:setName("finish_sectoin")

            sectionIcon.isOpen = true
            spIcon1:setSaturation(0)
            spIcon1:setOpacity(255)
            spIcon1:setVisible(false)   
                  
        elseif self._curSectionId == inSectionId then
            sectionIcon.isOpen = true

            if self._lastSectionId >= inSectionId then
                spIcon1:setSaturation(0)
                spIcon1:setOpacity(255)
            end
            spIcon1:setVisible(false)   
            self._curSectionAction.sectionId = inSectionId
            self._curSectionAction1:setPosition(sysMainStageMap.worldX, sysMainStageMap.worldY + sectionIcon:getContentSize().height/2 + 30)
            self._curSectionAction:setPosition(sysMainStageMap.worldX, sysMainStageMap.worldY)
        else
            sectionIcon.isOpen = false
            spIcon1:setSaturation(-200)
            spIcon1:setOpacity(150)


            numLimitImgBg:setVisible(false)
            numLimitImg:setVisible(false)

            starNumBg:setVisible(false)
            nodeTip1:setVisible(false)
        end


        self._bgLayer:addChild(sectionIcon, 11)
        registerTouchEvent(sectionIcon, nil, nil, function()
            self:touchEventIcon(inSectionId)
        end)
        sectionIcon:setTouchEnabled(false)
        sectionIcon:setScaleAnim(true)
        table.insert(self._sectionIcon, sectionIcon)

        sectionIcon:setVisible(inIsVisible)

        sectionIcon:setCascadeOpacityEnabled(true, true)
        sectionIcon:setOpacity(255)
        sectionIcon:setName("Section_" .. inSectionId)
        sectionIcon.index = sectionIndex
        
        return flag
    end
    return 0
end

--[[
--! @function quickActiveNewSection
--! @desc 用户点击大章或小章便捷途径激活小章
--！@param id 小章id
--! @return 
--]]
function IntanceWorldLayer:quickActiveNewSection(id)
    self._actNewSectionId = id
    if self._scrollSchedule then
        ScheduleMgr:unregSchedule(self._scrollSchedule)
        self._scrollSchedule = nil
    end
    -- IntanceConst.GO_STAR_POINT = id
    SystemUtils.saveAccountLocalData("GO_STAR_POINT", id)
    self:loadBigMap()                    
    self:activeNewSectionStory()
end

function IntanceWorldLayer:quickCheckActiveNewSection()
    print('IntanceConst.PAUSE_ACTIVAT=============================', IntanceConst.PAUSE_ACTIVAT)
    if IntanceConst.PAUSE_ACTIVATE == true then 
        IntanceConst.CACHE_GUIDE_LEVEL_JUMP = 1
        IntanceConst.PAUSE_ACTIVATE = false 
        return 
    end
    local mainsData = self._intanceModel:getData().mainsData
    local newSectionId = tonumber(string.sub(mainsData.curStageId, 1 , 5))
    local sysSection = tab:MainSection(newSectionId)
    local callbackCode, otherParam = IntanceUtils:checkPreSection(self._intanceModel:getCurMainSectionId(), sysSection)
    if callbackCode == 0 then
        print("向服务端传递激活下一章信息========================")
        -- 向服务端传递激活下一章信息
        local param = {sectionId = sysSection.id, type = 1}
        self._serverMgr:sendMsg("StageServer", "setSectionId", param, true, {}, function (result)
            if result == nil or result["d"] == nil then
                self._viewMgr:showTip("激活副本出错， 请重新尝试")
                self._parentView:close()
                return false
            end
            self:quickActiveNewSection(sysSection.id)
        end)
        return false
    else
        --没有新章节开启动画则需要判断是否开启斯坦德威克动画
        self:siegeEffectLimite()
    end
end

--[[
--! @function clickOtherStoryId
--! @desc 点击大章信息
--！@param inStoryId 大章id
--! @return 
--]]
function IntanceWorldLayer:clickOtherStoryId(inStoryId, notShowTip)
    if self._curStoryId == inStoryId then return end
    local clickSysMainStory = tab.mainStory[inStoryId]
    local selStoryNode = self._bgLayer:getChildByName("Story_" .. inStoryId)
    if selStoryNode == nil then return end

    local storyFirstSectionId = clickSysMainStory.include[1]
  
    -- 最后一章已激活时记录用户点击的章, notShowTip 默认展示时用的，所以不在记录
    if self._endStageState == 1 and notShowTip ~= true then
        SystemUtils.saveAccountLocalData(IntanceConst.USE_SELECT_SECTION, "1_" .. tostring(storyFirstSectionId))
    end

    if not selStoryNode.isOpen then if notShowTip == true then return end self._viewMgr:showTip("该情节未开启") return end
    selStoryNode:setVisible(false)
    
    local tempStoryNode = self._bgLayer:getChildByName("Story_" .. self._curStoryId)
    if tempStoryNode ~= nil then 
        tempStoryNode:setVisible(true)
        local sysMainStory = tab.mainStory[self._curStoryId]
        for k1,v1 in pairs(sysMainStory.include) do
            local tempSectionNode = self._bgLayer:getChildByName("Section_" .. v1)
            tempSectionNode:setVisible(false)
        end
        local titleNode = self._bgLayer:getChildByName("StoryTitle_" .. self._curStoryId)
        if titleNode ~= nil then titleNode:setVisible(true) end
    end
    local tempStoryLineNode = self._bgLayer:getChildByName("StoryLine_" .. self._curStoryId)
    tempStoryLineNode:setBrightness(-58)
    tempStoryLineNode:setSaturation(-100)         

    self._curStoryId = inStoryId

    local clickSysMainStory = tab.mainStory[inStoryId]
    for k1,v1 in pairs(clickSysMainStory.include) do
        local tempSectionNode = self._bgLayer:getChildByName("Section_" .. v1)
        tempSectionNode:setVisible(true)
    end

    self:updateCurSectionMcByStoryId(inStoryId)
    local titleNode = self._bgLayer:getChildByName("StoryTitle_" .. self._curStoryId)
    if titleNode ~= nil then titleNode:setVisible(false) end

    local storyLineNode = self._bgLayer:getChildByName("StoryLine_" .. self._curStoryId)
    storyLineNode:setBrightness(0)
    storyLineNode:setSaturation(0)   

end

function IntanceWorldLayer:updateCurSectionMcByStoryId(inStoryId)
    local sysMainStory = tab.mainStory[inStoryId]
    if sysMainStory == nil then return end
    local showSectionTip = false
    for k1,v1 in pairs(sysMainStory.include) do
        if self._curSectionId == v1 then 
            if self._endSectionId == v1 and self._endStageState ~= 1 then
                showSectionTip = true
            elseif self._endSectionId ~= v1 then
                showSectionTip = true
            end
        end
    end

    if showSectionTip == false then 
        self._curSectionAction:setVisible(false)
        self._curSectionAction1:setVisible(false)
    else
        self._curSectionAction:setVisible(true)
        self._curSectionAction1:setVisible(true)        
    end
end

--[[
--! @function updateStoryInfo
--! @desc 更新大章信息
--！@param inStoryId 大章id
--! @return 
--]]
function IntanceWorldLayer:updateStoryInfo(inStoryId)
    print("self._lastSectionId========", self._lastSectionId)
    local sysMainStory = tab.mainStory[inStoryId]
    local lockArea =  1

    for k1,v1 in pairs(sysMainStory.include) do
        self._storyGroup[v1] = k
        if self._lastSectionId >= v1 then
            if self._lastSectionId == v1 then
                lockArea = 2
            elseif self._lastSectionId > v1 and lockArea ~= 2 then
                lockArea = 3
            end
        end
        if self._actNewSectionId ~= nil and self._actNewSectionId == v1 then
            self._actStoryId = inStoryId
        end
    end
    if lockArea == 2 then 
        self._curStoryId = inStoryId
    end

    local showBox = 0
    for k1,v1 in pairs(sysMainStory.include) do
        local flag = self:updateSectionInfo(v1, lockArea == 2)
        if flag > 0 then 
            showBox = 1
        end
    end

    self:updateHeroUnlockInfo(sysMainStory)

    local spNormal = cc.Sprite:createWithSpriteFrameName(sysMainStory["line"] .. ".png")
    spNormal:setAnchorPoint(0.5, 0.5)
    spNormal:setPosition(sysMainStory["posi"][1], sysMainStory["posi"][2])
    self._bgLayer:addChild(spNormal, 10)
    spNormal:setScale(1.33)
    spNormal:setName("StoryLine_" .. inStoryId)
    

    local spUnActive = cc.Sprite:createWithSpriteFrameName(sysMainStory.pic .. ".png")
    spUnActive:setScale(2)
    spUnActive:setAnchorPoint(0.5, 0.5)

    local buildingIcon = ccui.Widget:create()

    buildingIcon.noSound = true
    buildingIcon:setContentSize(cc.size(spUnActive:getContentSize().width * spUnActive:getScaleX(), spUnActive:getContentSize().height* spUnActive:getScaleX()))
    
    spUnActive:setPosition(buildingIcon:getContentSize().width/2, buildingIcon:getContentSize().height/2)


    buildingIcon:setAnchorPoint(0.5, 0.5)
    buildingIcon:setPosition(sysMainStory.posi[1], sysMainStory.posi[2])
    self._bgLayer:addChild(buildingIcon, 9)
    buildingIcon:setVisible(false)
    buildingIcon:setName("Story_" .. inStoryId)

    buildingIcon:addChild(spUnActive)

    registerTouchEvent(buildingIcon, nil, nil, function ()
        self:clickOtherStoryId(inStoryId)
    end)
    buildingIcon:setTouchEnabled(false)

    if lockArea == 2 or lockArea == 3 then 
        buildingIcon.isOpen = true 
    else
        buildingIcon.isOpen = false 
    end

    buildingIcon:setCascadeOpacityEnabled(true, true)

    for k1,v1 in pairs(sysMainStory.button) do
        self._usingIcon[v1] = buildingIcon
    end

    local titleNode = cc.Sprite:create()
    titleNode:setContentSize(165, 32)
    titleNode:setPosition(sysMainStory.titleposi[1], sysMainStory.titleposi[2])
    titleNode:setName("StoryTitle_" .. inStoryId)

    -- local layer = cc.LayerColor:create(cc.c4b(255, 106, 106, 255))
    -- layer:setPosition(0, 0)
    -- layer:setContentSize(cc.size(titleNode:getContentSize().width, titleNode:getContentSize().height))
    -- titleNode:addChild(layer)

    titleNode.runBrightness = function(sender, step)
        self._brightnessSchedule = ScheduleMgr:regSchedule(0.001, self,function( )
            if sender == nil or sender.getBrightness == nil then 
                if self._brightnessSchedule ~= nil then
                    ScheduleMgr:unregSchedule(self._brightnessSchedule)
                    self._brightnessSchedule = nil
                end
                return
            end
            sender:setBrightness(sender:getBrightness() - step)
            if self._brightnessSchedule and sender:getBrightness() <= step then
                sender:setBrightness(0)
                ScheduleMgr:unregSchedule(self._brightnessSchedule)
                self._brightnessSchedule = nil
            end
        end)
    end

    --有箱子没领，星星够了
    if showBox > 0 then
        local rewardBtnBg = cc.Sprite:createWithSpriteFrameName("world_reword_box_bg.png")
        titleNode:addChild(rewardBtnBg, 20)
        rewardBtnBg:setPosition(cc.p(titleNode:getContentSize().width * 0.5 + 55, 50))

        --增加宝箱提示
        local boxLight = mcMgr:createViewMC("baoxiangguang1_baoxiang", true)
        boxLight:setPosition(rewardBtnBg:getContentSize().width/2, rewardBtnBg:getContentSize().height/2)
        boxLight:setName("box_light")
        rewardBtnBg:addChild(boxLight,10)
        boxLight:setCascadeOpacityEnabled(true, true)
        boxLight:setOpacity(rewardBtnBg:getOpacity())
        boxLight:setScale(0.7)

        local boxAnim = mcMgr:createViewMC("baoxiang3_baoxiang", true)
        boxAnim:setPosition(rewardBtnBg:getContentSize().width/2, rewardBtnBg:getContentSize().height/2)
        boxAnim:setName("box_anim")
        rewardBtnBg:addChild(boxAnim, 3)
        boxLight:setCascadeOpacityEnabled(true, true)
        boxLight:setOpacity(rewardBtnBg:getOpacity()) 
        boxAnim:setScale(0.7)
    end 

    local titleLab = cc.Label:createWithTTF(lang(sysMainStory.titile), UIUtils.ttfName, 40)
    titleLab:setScale(0.5)
    titleLab:setAnchorPoint(0.5, 0.5)
    titleLab:setPosition(titleNode:getContentSize().width/2, titleNode:getContentSize().height/2)
    titleLab:setCascadeOpacityEnabled(true, true)
    titleNode:addChild(titleLab)
    titleLab:setColor(cc.c4b(33, 239, 32,255))
    titleLab:enableOutline(cc.c4b(0, 0, 0,255), 1)
    titleNode.titleLab = titleLab 


    local stateLab = cc.Sprite:createWithSpriteFrameName("world_story_finishTip.png")
    stateLab:setAnchorPoint(1, 0.5)
    stateLab:setPosition(titleLab:getPositionX() - titleLab:getContentSize().width * 0.5 * titleLab:getScaleX() + 5, titleNode:getContentSize().height * 0.5 - 18)
    stateLab:setCascadeOpacityEnabled(true, true)
    titleNode:addChild(stateLab)
    titleNode.stateLab = stateLab

    local subtitleLab = cc.Label:createWithTTF(lang(sysMainStory.des), UIUtils.ttfName, 30)
    subtitleLab:setScale(0.5)
    subtitleLab:setAnchorPoint(0.5, 0.5)
    subtitleLab:setPosition(titleNode:getContentSize().width/2, titleNode:getContentSize().height/2 - 23)
    subtitleLab:setCascadeOpacityEnabled(true, true)
    titleNode:addChild(subtitleLab)
    subtitleLab:setColor(cc.c4b(252, 244, 192,255))
    subtitleLab:enableOutline(cc.c4b(0, 0, 0,255), 1)
    titleNode.subTitleLab = subtitleLab 

    titleNode:setCascadeOpacityEnabled(true, true)
    titleNode:setVisible(false)
    self._bgLayer:addChild(titleNode, 15)
 

    if lockArea ~= 2 then
        titleNode:setVisible(true)
        buildingIcon:setVisible(true)  
    end
    self:updateTitleNodeWithStoryId(inStoryId, lockArea)
end

--[[
--! @function updateTitleNodeWithStoryId
--! @desc 更新大章标题状态
--！@param inStoryId 大章id
--！@param inState 状态
--! @return 
--]]
function IntanceWorldLayer:updateTitleNodeWithStoryId(inStoryId, inState)
    local titleNode = self._bgLayer:getChildByName("StoryTitle_" .. inStoryId)
    local storyLineNode = self._bgLayer:getChildByName("StoryLine_" .. inStoryId)
    if titleNode == nil then return end
    local sysMainStory = tab.mainStory[inStoryId]
    if inState == 1 then 
        -- titleNode:setSaturation(-100)
        titleNode.stateLab:setVisible(false)
        -- titleNode.stateLab:setString(sysMainStory.open .. "级开启")
        storyLineNode:setBrightness(-58)
        storyLineNode:setSaturation(-100)         
        -- if inStoryId > self._curStoryId + 1 then
            titleNode.stateLab:setVisible(false)
        -- else
        --     titleNode.stateLab:setVisible(true)
        -- end
        if titleNode.levelTip == nil then 




            local levelLab = cc.Label:createWithTTF(" ", UIUtils.ttfName, 26)
            levelLab:setScale(0.66)

            levelLab:setAnchorPoint(0.5, 0.5)
            levelLab:setPosition(titleNode:getContentSize().width * 0.5, titleNode:getContentSize().height * 0.5 - 45)
            levelLab:setCascadeOpacityEnabled(true, true)
            levelLab:setColor(cc.c4b(206, 204, 205,255))
            levelLab:enableOutline(cc.c4b(0, 0, 0,255), 1)
            titleNode:addChild(levelLab)
            titleNode.levelTip = levelLab 
        end
        titleNode.levelTip:setString(sysMainStory.open .. "级开启")
        titleNode.levelTip:setPosition(titleNode:getContentSize().width * 0.5, titleNode:getContentSize().height * 0.5 - 45)
        titleNode.titleLab:setColor(cc.c4b(206, 204, 205,255))
        titleNode.subTitleLab:setColor(cc.c4b(206, 204, 205,255))


    elseif inState == 2 then 
        if titleNode.levelTip ~= nil then 
            titleNode.levelTip:removeFromParent()
            titleNode.levelTip = nil 
        end
        -- titleNode:setSaturation(0)
        -- titleNode.stateLab:setString("已开启")
        titleNode.stateLab:setVisible(false)
        storyLineNode:setBrightness(0)
        storyLineNode:setSaturation(0)
        titleNode.titleLab:setColor(cc.c4b(33, 239, 32,255))   
        titleNode.subTitleLab:setColor(cc.c4b(252, 244, 192,255))        
    elseif inState == 3 then 
        titleNode:setSaturation(0)
        storyLineNode:setBrightness(-58)
        storyLineNode:setSaturation(-100)         
        -- titleNode.stateLab:setString("已完成")
        titleNode.stateLab:setVisible(true)
    end
end


--[[
--! @function checkSectionTouch
--! @desc 检查章图标点击，进入章
--！@param x x坐标
--！@param y y坐标
--! @return 
--]]
function IntanceWorldLayer:checkSectionTouch(x, y)
    if next(self._sectionIcon) == nil then return false end
    for k,v in pairs(self._sectionIcon) do
        local pt = v:convertToWorldSpace(cc.p(0, 0))
        if v:isVisible() and pt.x < x and pt.y < y and (pt.x + v:getContentSize().width) > x and (pt.y + v:getContentSize().height) > y  then
            -- print('v.index===============================', v.index)
            -- if not v.isOpen then 
            --     self._viewMgr:showTip("通关第" .. (v.index - 1) .. "章可开启")
            --     return false
            -- end
            v.noSound = true
            v.eventDownCallback(pt.x, pt.y, v)
            v.eventUpCallback(pt.x, pt.y, v)
            return true
        end
    end
    return false
end

--[[
--! @function checkStoryGroupTouch
--! @desc 检查大章节点击
--！@param x x坐标
--！@param y y坐标
--! @return 
--]]
function IntanceWorldLayer:checkStoryGroupTouch(x, y)
    if self._usingIcon == nil or next(self._usingIcon) == nil then 
        return false
    end
    local pt1 = self._bgLayer:convertToNodeSpace(cc.p( x, y))

    local verBlock = math.ceil((self._bgLayer:getContentSize().height - pt1.y) / 50)
    local horBlock = math.ceil(pt1.x / 50)
    local touchBlockNum = (verBlock - 1) * self._maxHorBlockNum + horBlock

    if self._usingIcon[touchBlockNum] == nil then return false end

    local v = self._usingIcon[touchBlockNum]
    v.eventDownCallback(pt1.x, pt1.y, v)
    v.eventUpCallback(pt1.x, pt1.y, v)
    return true
end

--[[
--! @function touchIcon
--! @desc 点击事件
--！@param x x坐标
--！@param y y坐标
--! @return 
--]]
function IntanceWorldLayer:checkTouchEnd(x, y)
    if x == nil or y == nil then   
        return false
    end
    if self._touchBeganPositionX == nil then return false end
    if math.abs(self._touchBeganPositionX - x) > 10
        or math.abs(self._touchBeganPositionY- y) > 10 then 
        return false
    end

    if self:checkSectionTouch(x, y) then return true end

    if self:checkStoryGroupTouch(x, y) then return true end
    
    return false
end


function IntanceWorldLayer:touchEventIcon(id)
    if self._switchCallback == nil then return end

    self._viewMgr:lock(-1)
    self:worldMapActiveSection(id, function(inType)
        self._viewMgr:unlock()
        if inType == 999 then 
            return
        end
        if inType == 2 then 
            self:quickActiveNewSection(id)
        else
            if self._endStageState == 1 then
                SystemUtils.saveAccountLocalData(IntanceConst.USE_SELECT_SECTION, "1_" .. tostring(id))
            end
            self._switchCallback(id)
        end
    end)
    return true
end



--[[
--! @function showSection
--! @desc 限制展示某一章
--！@param inSectionId 章id
--! @return 
--]]
function IntanceWorldLayer:showSection(inSectionId, isActive)
    local cacheOperateFunId = nil
    if inSectionId == 0 then 
        if self._endStageState == 1 then 
            local cacheOperate = SystemUtils.loadAccountLocalData(IntanceConst.USE_SELECT_SECTION)
            if cacheOperate ~= nil then
                local cacheOperateFun = string.split(cacheOperate, "_")
                if #cacheOperateFun >= 2 then
                    if tonumber(cacheOperateFun[1]) == 1 then 
                        inSectionId = tonumber(cacheOperateFun[2])
                    elseif tonumber(cacheOperateFun[1]) == 2 then 
                        cacheOperateFunId = cacheOperateFun[2] 
                    end
                end
            end
        end
    end
    if inSectionId == 0 then
        inSectionId = self._intanceModel:getCurMainSectionId()
    end
    for k,v in pairs(tab.mainStory) do
        local index = table.indexof(v.include, inSectionId, 1)
        if index then 
            self:clickOtherStoryId(k, true)
            break
        end
    end
    local tempSectionNode = self._bgLayer:getChildByName("Section_" .. inSectionId)
    if tempSectionNode ~= nil then 
        local x, y = tempSectionNode:getPosition()
        self:screenToPos(x, y, false)
        if isActive == true then
            return
        end
    end

    -- 跳转到新功能位置进行激活
    local orderOpenList = {}
    for k,v in pairs(self._funOpenList) do
        local tempBtn = self._bgLayer:getChildByName(v.normal)
        if tempBtn ~= nil and tempBtn.delayTimeOpen == true then 
            tempBtn.id = v.id
            table.insert(orderOpenList, tempBtn)
        end
    end
    local viewMgr = ViewManager:getInstance()
    if #orderOpenList > 0 then 
        table.sort(orderOpenList, function(a,b) return a.id < b.id end )
        -- viewMgr:lock(-1)
        self:lockTouch()
        local orderIndex = 1
        local activeOpenFun
        activeOpenFun = function()
            if orderIndex > #orderOpenList then 
                -- viewMgr:unlock()
                self:unLockTouch()
                return 
            end
            orderOpenList[orderIndex]:active(
                function()
                    orderIndex = orderIndex + 1
                    activeOpenFun()
                end)
        end
        activeOpenFun()
        return
    end
    print("cacheOperateFunId======", cacheOperateFunId)
    -- self:siegeEffectLimite()
    if self._quickShowBtnWithQipao ~= nil then 
        self:quickShowBtn(self._quickShowBtnWithQipao)
        self._quickShowBtnWithQipao = nil
    else
        if cacheOperateFunId ~= nil then 
            self:quickShowBtn(cacheOperateFunId)
        end
    end

    
end

function IntanceWorldLayer:quickShowBtn(inKey)
    if self._funOpenList[inKey] == nil then return end
    self:setMapPosition(self._funOpenList[inKey].pos[1], self._funOpenList[inKey].pos[2])
end

function IntanceWorldLayer:setMapPosition(x, y)
    self:screenToPos(x, y, false)
end
--攻城战动画显示条件
function IntanceWorldLayer:siegeEffectLimite()
    local needLocation, siegeData = self._modelMgr:getModel("SiegeModel"):isWorldLocation()
    if needLocation then
        self:quickShowBtn("si")
        self:showSiegeEffect(siegeData)
    end
end

-- 展示攻城战特效
function IntanceWorldLayer:showSiegeEffect(effectData)
    if effectData.changeAni ~= nil then
        self:showSiegeChangeAni(effectData, function(data1)
            self:showSiegeEffect(data1)
        end)

    elseif effectData.dialog ~= nil then
        self:showSiegeDialog(effectData, function(data2)
            self:showSiegeEffect(data2)
        end)

    elseif effectData.flagAni ~= nil then
        self:showSiegeFlag(effectData, function(data3)
            self:showSiegeEffect(data3)
        end)
    end
end

function IntanceWorldLayer:showSiegeChangeAni(data, callback)
    self._viewMgr:lock(-1)
    local id = data.changeAni
    data.changeAni = nil
    local siegeBtn = self._bgLayer:getChildByName(self._funOpenList["si"].normal)

    if id == 1 then
        siegeBtn.titleBg = nil
        siegeBtn.titleLab = nil
        siegeBtn:removeAllChildren()
        siegeBtn.numLimitLab = nil
        siegeBtn:unActive()

        local btnData = self._funOpenList["si"]
        local activeAnim = mcMgr:createViewMC("gongchengkaiqi_gongchengrukou", false, true)  
        activeAnim:setPosition(btnData.pos[1], btnData.pos[2] + siegeBtn:getContentSize().height * 0.5)
        self._bgLayer:addChild(activeAnim, 20)
        activeAnim:setCascadeOpacityEnabled(true, true)
        activeAnim:addCallbackAtFrame(25, function()
            siegeBtn:removeFromParent(true)
            self:addBtnFunction("si", self._funOpenList["si"])
--            siegeBtn.titleBg = nil
--            siegeBtn.titleLab = nil
--            siegeBtn:removeAllChildren()
--            siegeBtn.numLimitLab = nil
--            siegeBtn:normal()
            self._viewMgr:unlock()
            callback(data)
        end)

    elseif id == 2 then
        siegeBtn.titleBg = nil
        siegeBtn.titleLab = nil
        siegeBtn:removeAllChildren()
        siegeBtn.numLimitLab = nil

        local btnData = self._funOpenList["si"]
        local normalImg = ccui.ImageView:create()
        normalImg:loadTexture("world_siegeActivity_btn.png",1)
        if btnData.size == nil then
            siegeBtn:setContentSize(normalImg:getContentSize().width, normalImg:getContentSize().height)
        end            
        normalImg:setAnchorPoint(cc.p(0.5, 0.5))
        normalImg:setPosition(siegeBtn:getContentSize().width * 0.5, siegeBtn:getContentSize().height * 0.5)
        normalImg:ignoreContentAdaptWithSize(false)
        siegeBtn:addChild(normalImg)
        siegeBtn.normalImg = normalImg

        local anim = mcMgr:createViewMC("gongchenghuodong_gongchengrukou", true)
        anim:setPosition(siegeBtn:getContentSize().width * 0.5 -3, siegeBtn:getContentSize().height * 0.5)
        anim:setScale(0.9)
        siegeBtn:addChild(anim)

        local btnData = self._funOpenList["si"]
        local activeAnim = mcMgr:createViewMC("bianhuayanwu_gongchengrukou", false, true)  
        activeAnim:setPosition(btnData.pos[1], btnData.pos[2] + siegeBtn:getContentSize().height * 0.5)
        self._bgLayer:addChild(activeAnim, 20)
        activeAnim:setCascadeOpacityEnabled(true, true)
        activeAnim:addCallbackAtFrame(25, function()
            siegeBtn:removeFromParent(true)
            self:addBtnFunction("si", self._funOpenList["si"])

--            siegeBtn.titleBg = nil
--            siegeBtn.titleLab = nil
--            siegeBtn:removeAllChildren()
--            siegeBtn.numLimitLab = nil
--            siegeBtn:normal()
            self._viewMgr:unlock()
            callback(data)
        end)
    end
end


function IntanceWorldLayer:showSiegeDialog(data, callback)
    local id = data.dialog
    data.dialog = nil
    self:showSiegeHeroTalk(id, function()
        callback(data)
    end)
end

function IntanceWorldLayer:showSiegeFlag(data, callback)
    local id = data.flagAni
    data.flagAni = nil
    self._viewMgr:showDialog("siege.SiegeFlagAniView", {tipType = id, callbackFunc = function()
        callback(data)
    end}, true)
end

function IntanceWorldLayer:listenScale(inScale)
    self._worldElementLayer:runScale(inScale, self:getMinScale(), self:getMaxScale())
end

function IntanceWorldLayer:standByFirstEnterAction()
    self._worldTitleBg:setPosition(self._worldTitleBg:getPositionX(), MAX_SCREEN_HEIGHT + self._worldTitleBg:getContentSize().height + 15)
    self._worldSubBg:setPosition(self._worldTitleBg:getPositionX(), MAX_SCREEN_HEIGHT + self._worldTitleBg:getContentSize().height + 35)
    self._worldCompass.runStartAction = function(sender)
        sender.pauseAuto = true
        local rotation = sender:getRotation()
        self._worldCompass:setRotation(0)
        local action1 = cc.RotateTo:create(0.4, -200)
        local action2 = cc.RotateTo:create(0.2, -100) 
        local action3 = cc.RotateTo:create(0.2, 0)
        local action4 = cc.RotateTo:create(0.2, rotation + 20)
        local action5 = cc.RotateTo:create(0.2, rotation)
        sender:runAction(cc.Sequence:create(
                        action1, 
                        action2, 
                        action3,
                        action4,
                        action5,
                        cc.CallFunc:create(function()
                            sender.pauseAuto = false
                        end)))
    end

    self._worldCompassBg:setPosition(- self._worldCompassBg:getContentSize().width, self._worldCompassBg:getPositionY())
    self._worldCompass:setPosition(-self._worldCompassBg:getContentSize().width * 0.5, self._worldCompass:getPositionY())
    -- self._worldCompass:runStartAction()
end

function IntanceWorldLayer:runFirstEnterAction()
    self._worldTitleBg:runAction(
        cc.Sequence:create(
            cc.MoveTo:create(0.2, cc.p(self._worldTitleBg:getPositionX(), MAX_SCREEN_HEIGHT)),
            cc.MoveTo:create(0.2, cc.p(self._worldTitleBg:getPositionX(), MAX_SCREEN_HEIGHT + 10))
            )
        )
    self._worldSubBg:runAction(
        cc.Sequence:create(
            cc.MoveTo:create(0.2, cc.p(self._worldSubBg:getPositionX(), self._worldSubBg.positionY - 10)),
            cc.MoveTo:create(0.2, cc.p(self._worldSubBg:getPositionX(), self._worldSubBg.positionY))
            )
        )    
    self._worldCompassBg:runAction(
        cc.Sequence:create(
            cc.MoveTo:create(0.2, cc.p(10, self._worldCompassBg:getPositionY())),
            cc.MoveTo:create(0.2, cc.p(0, self._worldCompassBg:getPositionY()))
            )
        )
    self._worldCompass:runAction(
        cc.Sequence:create(
            cc.MoveTo:create(0.2, cc.p(self._worldCompassBg:getContentSize().width * 0.5 + 10, self._worldCompass:getPositionY())),
            cc.MoveTo:create(0.2, cc.p(self._worldCompassBg:getContentSize().width * 0.5, self._worldCompass:getPositionY())),
            cc.CallFunc:create(function()
                self._worldCompass:runStartAction()

            end),
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(function()
                self:listenScale(self._sceneLayer:getScale())
            end)
            )
        )
end

--[[
--! @function activeNewSectionStory
--! @desc 激活第一次进入大世界动画
--! @param 
--! @return 
--]]
function IntanceWorldLayer:activeNewSectionStory()
    print('IntanceWorldLayer:activeNewSectionStory======', self._lastSectionId)
    self.__guideLock = true
    
    self:lockTouch()
    -- self._parentView:lock(-1)
    self._curSectionAction1:setVisible(false)
    self._curSectionAction:setVisible(false)
    local sectionNode = self._bgLayer:getChildByName("Section_" .. self._lastSectionId)
    local finishSectionIcon = sectionNode:getChildByName("finish_sectoin")
    if finishSectionIcon ~= nil then 
        finishSectionIcon:setVisible(false)
    end
    -- 第一大章到第二大章特殊处理
    if self._curSectionId == IntanceConst.FIRST_SECTION_ID + 1 then
        self._worldElementLayer:standByFirstEnterAction()
        self:standByFirstEnterAction()
        self:screenToSize(0.8)
        local tempExistStoryIds = {}
        local maxStoryId = 0
        for k,v in pairs(tab.mainStory) do
            local storyNode = self._bgLayer:getChildByName("StoryTitle_" .. v.id)
            if storyNode ~= nil  then 
                if v.id <= 5 and v.id > 1 then

                    table.insert(tempExistStoryIds, 1, v.id) 
                    if maxStoryId < v.id then 
                        maxStoryId = v.id
                    end                    
                    storyNode:setOpacity(0)
                    storyNode:setScale(2)

                end
                storyNode.stateLab:setVisible(false)
                storyNode.subTitleLab:setVisible(false)
            end
        end
        table.sort(tempExistStoryIds, function(a,b) return a > b end )
        local sysMainStory = tab.mainStory[maxStoryId]
        self:screenToPos(0, self._bgLayer:getContentSize().height, false)
        
        local runIndex = 1
        local function runStoryAnim()
            if tempExistStoryIds[runIndex] == nil then self:activeNewSectionStory1() return end
            local tempStoryId = tempExistStoryIds[runIndex]
            local sysMainStory = tab.mainStory[tempStoryId]
            local function subRunStoryAnim()
                -- 亮光
                local mc = mcMgr:createViewMC("story" .. tempStoryId .. "_intancestory", true, true, function()
                    runIndex = runIndex + 1
                    runStoryAnim()
                end)
                mc:setPosition(sysMainStory.posi[1], sysMainStory.posi[2])
                mc:setCascadeOpacityEnabled(true, true)
                mc:setOpacity(255)
                self._bgLayer:addChild(mc,10)
                mc:addCallbackAtFrame(18, function()
                    -- 大章节落地并闪亮
                    local storyTitle = self._bgLayer:getChildByName("StoryTitle_" .. tempStoryId)
                    storyTitle.stateLab:setVisible(false)
                    storyTitle.subTitleLab:setVisible(false)
                    storyTitle:setScale(3)
                    storyTitle:setOpacity(255)
                    storyTitle:runAction(
                        cc.Spawn:create(
                            cc.Sequence:create(
                                cc.ScaleTo:create(0.1, 1), 
                                cc.CallFunc:create(function()
                                    self:shake(1, 5)
                                end)
                                ),
                            cc.Sequence:create(
                                cc.DelayTime:create(0.05), 
                                cc.CallFunc:create(function()
                                    storyTitle:setBrightness(78)
                                    storyTitle:runBrightness(8)
                                end)
                                )
                            ))
                end)
            end
            self:screenToPos(sysMainStory.posi[1], sysMainStory.posi[2], true, function()
                if sysMainStory.id ~= self._actStoryId then 
                    subRunStoryAnim()
                else
                    runIndex = runIndex + 1
                    runStoryAnim()
                end
            end, true, 0.3)
        end
        runStoryAnim()
        return
    end
    -- 其他大章
    self:activeNewSectionStory1()
end

--[[
--! @function activeNewSectionStory1
--! @desc 激活第故事情节
--! @param 
--! @return 
--]]
function IntanceWorldLayer:activeNewSectionStory1()
    -- 大章节激活
    print('self._actStoryId=================', self._actStoryId, self._curStoryId)
    if self._curStoryId == self._actStoryId then 
        self._actStoryId = nil
    end
    if self._actStoryId ~= nil then 
        self._tempActStoryId = self._actStoryId
        local function runActiveStoryMc(inSysMainStory, inIndex)
            if inIndex > #inSysMainStory.include then
                self._actStoryId = nil
                self._actNewSectionId = nil
                -- self:activeNewSectionStory1()
                local sectionNode = self._bgLayer:getChildByName("Section_" .. self._lastSectionId)
                self:screenToPos(sectionNode:getPositionX(), sectionNode:getPositionY(), true, function()
                    self:showPoint(1, sectionNode:getPositionX(), sectionNode:getPositionY(), true, function()
                        self:activeNewSectionStory1()
                    end)
                end)

                return
            end
            local sectionId = inSysMainStory.include[inIndex]
            local sysMainSectionMap = tab:MainSectionMap(sectionId)

                self._bgLayer:runAction(
                    cc.Sequence:create(
                        cc.CallFunc:create(
                            function()
                                local mc = mcMgr:createViewMC("sectionopen_intancestory", true, true)
                                mc:setPosition(sysMainSectionMap.worldX, sysMainSectionMap.worldY)
                                mc:setCascadeOpacityEnabled(true, true)
                                mc:setOpacity(255)
                                self._bgLayer:addChild(mc,10)

                                if self._actStoryId == 2 then 
                                    self:shake(1, 5)
                                end


                                local sectionNode = self._bgLayer:getChildByName("Section_" .. sectionId)
                                if self._curSectionId  == sectionId then 
                                    sectionNode.numLimitImgBg:setVisible(true)
                                    sectionNode.numLimitImg:setVisible(true)

                                    sectionNode.starNumBg:setVisible(true)
                                    sectionNode.starNum:setVisible(true)
                                end                                
                                sectionNode:setVisible(true)
                                sectionNode:setOpacity(0)
                                sectionNode:runAction(cc.FadeIn:create(0.5))

                            end),
                        cc.DelayTime:create(0.2),
                        cc.CallFunc:create(
                            function()
                                runActiveStoryMc(inSysMainStory, inIndex+1)
                            end)
                    )
                )

        end

    
        local function tempRunStory(sysMainStory)
            local storyNode = self._bgLayer:getChildByName("Story_" .. self._actStoryId)
            storyNode:runAction(cc.FadeOut:create(0.3))
            storyNode.isOpen = true
            if self._actStoryId ~= 2 then 
                local titleNode = self._bgLayer:getChildByName("StoryTitle_" .. self._actStoryId)
                titleNode:setVisible(true)
                titleNode:setOpacity(255)
                titleNode:runAction(cc.Sequence:create(
                                cc.FadeIn:create(0.1), 
                                cc.FadeOut:create(0.1),
                                cc.FadeIn:create(0.1),
                                cc.FadeOut:create(0.1),
                                cc.CallFunc:create(function()
                                    titleNode:setVisible(false)
                                    titleNode:setOpacity(255)
                                end)))
                self:updateTitleNodeWithStoryId(self._actStoryId, 2)
            end

            local firstSectionId = sysMainStory.include[1]
            local lastSectionId = sysMainStory.include[#sysMainStory.include]
            local firstSectionNode = self._bgLayer:getChildByName("Section_" .. firstSectionId)
            local lastSectionNode = self._bgLayer:getChildByName("Section_" .. lastSectionId)
            local lastSectionPos = cc.p(lastSectionNode:getPosition())
            local firstSectionPos = cc.p(firstSectionNode:getPosition())
            local point = MathUtils.midpoint(lastSectionPos, firstSectionPos)
            self:screenToPos(point.x, point.y, true, nil, false, 1, 0.5)

            local mc = mcMgr:createViewMC("story" .. self._actStoryId .. "_intancestory", false, true, function()
                runActiveStoryMc(sysMainStory, 1)
            end)
            mc:setPosition(sysMainStory.posi[1], sysMainStory.posi[2])
            mc:setCascadeOpacityEnabled(true, true)
            mc:setOpacity(255)
            self._bgLayer:addChild(mc,10)

        end
        local sysMainStory = tab:MainStory(self._actStoryId)
        if sysMainStory == nil then
            return
        end
        if self._actStoryId == 2 then 
            tempRunStory(sysMainStory)
            return
        end
        
        local sysPlotMainStory = tab:MainStory(self._curStoryId)
        if sysPlotMainStory.endInfo ~= nil then
            self._viewMgr:showDialog("intance.IntanceStoryInfoView",
                {
                    title = lang(sysPlotMainStory.titile), 
                    story  = sysPlotMainStory.endInfo, 
                    callback = function() 
                        tempRunStory(sysMainStory)
                    end,
                    isBegin = 2
                })
        else
            tempRunStory(sysMainStory)
        end

        -- self._storyView = ViewManager:getInstance():enableTalking(sysMainStory.story, "", function()
        --     tempRunStory(sysMainStory)
        -- end, false)
    else
        print('11111111111111111111111111111111111111self._actStoryId=================')
        local function runUnCurActiveStory()
            if self._tempActStoryId == nil then return end
            self:updateTitleNodeWithStoryId(self._curStoryId, 3)

            local sysMainStory = tab:MainStory(self._curStoryId)
            if sysMainStory == nil then return end
            for k,v in pairs(sysMainStory.include) do
                local sectionNode = self._bgLayer:getChildByName("Section_" .. v)
                sectionNode:setVisible(false)
            end
            local selStoryNode = self._bgLayer:getChildByName("Story_" .. self._curStoryId)
            selStoryNode:setVisible(true)
            selStoryNode:setOpacity(0)
            selStoryNode:runAction(cc.FadeIn:create(0.1))
            selStoryNode.isOpen = true

            local titleNode = self._bgLayer:getChildByName("StoryTitle_" .. self._curStoryId)

            titleNode:setVisible(true)
            titleNode:setScale(4)
            titleNode:runAction(cc.Sequence:create(
                    cc.ScaleTo:create(0.1, 1, 1)
                    -- , 
                    -- cc.CallFunc:create(function()
                    --     callback()
                    -- end)
                    )
            )
            self._curStoryId = self._tempActStoryId
            -- 显示当前激活的下一章节的名称
            self:updateTitleNodeWithStoryId(self._curStoryId + 1, 1)
        end

        -- 故事情节激活
        local function goNewSection()
            print("goNewSection======================================================")
            self:unLockTouch()
            local acSectionId = self._intanceModel:getData().mainsData.acSectionId
            if self._switchCallback ~= nil and (IntanceConst.FIRST_SECTION_ID + 1) == acSectionId then 
                self._switchCallback(self._curSectionId)
            end
            self:siegeEffectLimite()
            self.__guideLock  = false
        end    
        local lastSectionNode = self._bgLayer:getChildByName("Section_" .. self._lastSectionId)    
        local finishSectionIcon = lastSectionNode:getChildByName("finish_sectoin")
        finishSectionIcon:setVisible(true)
        finishSectionIcon:setOpacity(0)
        finishSectionIcon:setScale(3)
        finishSectionIcon:runAction(
            cc.Sequence:create(
                cc.EaseOut:create(
                cc.Spawn:create(
                       cc.ScaleTo:create(0.2, 3.4), 
                       cc.FadeIn:create(0.2)
                    ), 2),
                cc.ScaleTo:create(0.1, 0.8),
            cc.CallFunc:create(
                function() 
                    local mc = mcMgr:createViewMC("guoguan_intancestory", true, true)
                    mc:setPosition(finishSectionIcon:getPositionX(), finishSectionIcon:getPositionY())
                    mc:setCascadeOpacityEnabled(true, true)
                    lastSectionNode:addChild(mc,12)

                    self:shake(1, 5) 
                    local curSectionNode = self._bgLayer:getChildByName("Section_" .. self._curSectionId)
                    local lastSectionPoint = cc.p(lastSectionNode:getPosition())
                    local curSectionPoint = cc.p(curSectionNode:getPosition())
                    local arrowPoint = MathUtils.midpoint(lastSectionPoint, curSectionPoint)
                    local arrowAngle = 360 - MathUtils.angleAtan2(curSectionPoint, lastSectionPoint)
                    local mc = mcMgr:createViewMC("jiantouzhishi_intancestory", false, true, function(_, sender)
                            local unactSectoin = curSectionNode:getChildByName("unactSectoin")
                            unactSectoin:setSaturation(0)
                            unactSectoin:setBrightness(78)
                            unactSectoin:setOpacity(255)
                            unactSectoin:setColor(cc.c4b(255, 255, 204, 255))
                            unactSectoin:runAction(
                               cc.Sequence:create(
                                        cc.Spawn:create(
                                            cc.EaseOut:create(cc.ScaleTo:create(0.1, 1.5), 2), 
                                            cc.FadeOut:create(0.5)
                                        ),
                                        cc.CallFunc:create(function( ... )
                                           self:showPoint(1.2, curSectionNode:getPositionX(), curSectionNode:getPositionY(), true)
                                           unactSectoin:setVisible(false)
                                        end),
                                        cc.DelayTime:create(1.2),
                                        cc.CallFunc:create(function( ... )
                                            print("1test==========================================", self._curStoryId, self._tempActStoryId)
                                            local sysMainStory = tab:MainStory(self._curStoryId)
                                            -- 切大章
                                            if sysMainStory ~= nil and self._tempActStoryId ~= nil and sysMainStory.beginInfo ~= nil then
                                                self._viewMgr:showDialog("intance.IntanceStoryInfoView",
                                                    {
                                                        title = lang(sysMainStory.titile), 
                                                        story  = sysMainStory.beginInfo, 
                                                        callback = function() 
                                                            goNewSection()
                                                        end,
                                                        isBegin = 1
                                                    })
                                            else
                                                -- 切小章
                                                print("2test==========================================")
                                                local sysMainSectionMap = tab:MainSectionMap(self._intanceModel:getCurMainSectionId())
                                                print("sysMainSectionMap.story=================", sysMainSectionMap.story)
                                                if sysMainSectionMap.story ~= nil and sysMainSectionMap.story ~= "" then
                                                    self._storyView = ViewManager:getInstance():enableTalking(sysMainSectionMap.story, "", function()
                                                        goNewSection()
                                                    end)
                                                else
                                                    goNewSection()
                                                end
                                            end
                                        end))
                               )
                            self._curSectionAction1:setVisible(true)
                            self._curSectionAction1:setPosition(curSectionNode:getPositionX(), curSectionNode:getPositionY() + curSectionNode:getContentSize().height/2 + 25)
                            self._curSectionAction:setVisible(true)
                            self._curSectionAction:setPosition(curSectionNode:getPosition())
                            self._curSectionAction.sectionId = self._curSectionId
                            -- local acSectionId = self._intanceModel:getData().mainsData.acSectionId
                            -- if self._switchCallback ~= nil and (IntanceConst.FIRST_SECTION_ID + 1) == acSectionId then 
                            --     self._switchCallback(self._curSectionId)
                            -- end
                            runUnCurActiveStory()
                    end)
                    
                    mc:setPosition(arrowPoint.x, arrowPoint.y)
                    mc:setCascadeOpacityEnabled(true, true)
                    mc:setOpacity(255)
                    mc:setRotation(arrowAngle)
                    self._bgLayer:addChild(mc,12)

                    local pointDist = math.abs(MathUtils.pointDistance(lastSectionPoint, curSectionPoint))
                    local ratio = pointDist / 130 
                    if ratio > 1 then 
                        mc:setScaleY(ratio)
                    end
                    if self._curSectionId == IntanceConst.FIRST_SECTION_ID + 1 then
                        self._worldElementLayer:runFirstEnterAction()
                        self:runFirstEnterAction()
                    end
                end),
            cc.ScaleTo:create(0.1, 1)
            ))  
        -- end, false)
    end
end

--[[
--! @function worldMapActiveSection
--! @desc 判断是否能激活下一章
--! @param 
--! @return 
--]]
function IntanceWorldLayer:worldMapActiveSection(inSectionId, callback)
    local curSelectedIndex = tonumber(string.sub(inSectionId, 3 , 5))
    local includeSection = self._intanceModel:getSysSectionDatas()
    local preSysSection = includeSection[curSelectedIndex - 1]
    if preSysSection == nil and curSelectedIndex ~= 1 then 
        callback(nil, 999)
        return
    end

    local nextSysSection = tab:MainSection(inSectionId)
    if curSelectedIndex ~= 1 then
        local callbackCode, otherParam = IntanceUtils:checkPreSection(preSysSection.id, nextSysSection)
        if callbackCode == 1 then 
                self._viewMgr:showTip("无法前往此章节")
                callback(999)
            return
        elseif callbackCode == 2 then 
            self._viewMgr:showTip("通关第" .. (curSelectedIndex - 1) .. "章可开启")
            callback(999)
            return
        elseif callbackCode == 3 then 
            self._viewMgr:showTip("前往本章需达到Lv." .. otherParam)
            callback(999)
            return
        end
    end

    local mainsData = self._intanceModel:getData().mainsData
    local newSectionId = tonumber(string.sub(mainsData.curStageId, 1 , 5))
    local acSectionId = mainsData.acSectionId
    print("acSectionId========================================", acSectionId, newSectionId)
    if newSectionId == tonumber(nextSysSection.id) and 
        newSectionId > mainsData.acSectionId then
        -- 向服务端传递激活下一章信息
        local param = {sectionId = newSectionId, type = 1}
        self._serverMgr:sendMsg("StageServer", "setSectionId", param, true, {}, function (result)
            if result == nil or result["d"] == nil then
                self._viewMgr:showTip("激活下一章出错")
                callback(999)
                return false
            end
            callback(2)
        end) 
        return false
    end
    callback(1)
end

-- function IntanceWorldLayer:registerTouchEventWithLight(btn, clickCallback) 
--     local touchX, touchY = 0, 0   
--     registerTouchEvent(btn,
--         function ()
--             if self._lockTouch == true then return end
--             touchX, touchY = self._sceneLayer:getPosition()
--             btn.flashes = 50
--             local tempFlashes = 0
--             if not self._btnSchedule then
--                 self._btnSchedule = ScheduleMgr:regSchedule(0.1, self,function( )
--                     if btn.flashes >= 100 then 
--                         tempFlashes = -5
--                     end
--                     if btn.flashes <= 50 then
--                         tempFlashes = 5
--                     end
--                     btn.flashes = btn.flashes + tempFlashes
--                     btn:setBrightness(btn.flashes)
--                 end)
--             end
--             btn.downSp = btn:getVirtualRenderer()
--         end,
--         function ()
--             if self._lockTouch == true then return end
--             if btn.downSp ~= btn:getVirtualRenderer() then
--                 btn:setBrightness(0)
--             end
--         end,
--         function ()
--             if self._lockTouch == true then return end
--             if self._btnSchedule then
--                 ScheduleMgr:unregSchedule(self._btnSchedule)
--                 self._btnSchedule = nil
--             end
--             btn:setBrightness(0)
--             local x, y = self._sceneLayer:getPosition()
--             if math.abs(touchX - x) > 10
--                 or math.abs(touchY- y) > 10 then 
--                 return false
--             end            
--             if clickCallback ~= nil then 
--                 clickCallback()
--             end
--         end,
--         function()
--             if self._lockTouch == true then return end
--             if self._btnSchedule then
--                 ScheduleMgr:unregSchedule(self._btnSchedule)
--                 self._btnSchedule = nil
--             end
--             btn:setBrightness(0)
--         end)
--     btn:setSwallowTouches(false)
-- end


function IntanceWorldLayer:getMaxScrollHeightPixel(inScale)
    return 2000
end

function IntanceWorldLayer:getMaxScrollWidthPixel(inScale)
    return 2000
end

function IntanceWorldLayer:getMinScale()
    return 0.75
end

function IntanceWorldLayer:getMaxScale()
    return 1.25
end

function IntanceWorldLayer.dtor()
    cc = nil
end


return IntanceWorldLayer