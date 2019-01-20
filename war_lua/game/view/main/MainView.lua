--[[
    Filename:    MainView.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-04-29 15:21:37
    Description: File description
--]]

local MainView = class("MainView", BaseView)

local bgNameExt = ""
local mainViewVer = TimeUtils.mainViewVer
if mainViewVer == 1 then
    bgNameExt = ""
else
    bgNameExt = tostring(mainViewVer)
end
-- 小旗子
local isJieRi = GameStatic.mainViewJieRi
if isJieRi == nil then
    isJieRi = true
end
-- 中秋节
local isJieRi2 = GameStatic.mainViewJieRi2
if isJieRi2 == nil then
    isJieRi2 = true
end
-- 圣诞节
local isJieRi3 = GameStatic.mainViewJieRi3
if isJieRi3 == nil then
    isJieRi3 = true
end

--周年庆烟花间隔时间
local dtTime1 = 0
local dtTime2 = 0

local JIERI_3_BEGIN = "2018-12-24 05:00:00"
local JIERI_3_END = "2019-1-1 05:00:00"
function MainView:ctor(data)
    MainView.super.ctor(self)
    -- self.dontAdoptIphoneX = true
    if data then
        self._isShowAd = data.showAd   
    end
    self.noSound = true
    self._isExtend = false
    self._leftBtns = {}
    self._topBtns = {}
    self._noticeMap = {} 
    self._mcs = {}
    self._inFirst = false
    -- 右上角按钮红点检查 （点击打开popView ）
    self._noticeMap2 = {}
    self._isInWeekSign = false --当前是否打开了周签界面
    self._isCloseAd = false -- 是否关闭广告界面
    self._userModel = self._modelMgr:getModel("UserModel")
    self._siegeModel = self._modelMgr:getModel("SiegeModel")
    self._lordManagerModel = self._modelMgr:getModel("LordManagerModel")
    self._worldBossModel = self._modelMgr:getModel("WorldBossModel")
    self._lastReqGameStaticTick = socket.gettime()

    self._dtTime = 0
    self._curGadgetId = 0
end
--[[  16.11.04  推送
    V1，      推荐初级月卡 
    V2-V3，   推荐高级月卡  ps: v3如果有至尊月卡 显示四星凤凰
    V4，      4星凤凰      5
    V5-V7     五星凤凰     8
    V8-V9     三星黑骑     10
    V10-V11   四星黑骑     12
    V12       橙色宝物     13
    V13       橙色宝物     14
    V14       五星黑骑     15
    V15       黑骑专属     16
    V16       4星斩魂      17
    V17       满星斩魂     18
--]]
local activityLvL = {1,3,4,7,9,11,12,13,14,15,16,17}
local activetyBtnData = {
    {toViewData={name="activity.ActivityView",jumpType=1,specifiedAcId = 100},toIndex = 2,txtImg=lang("MAIN_YUEKA"),iconName="button_yueka_mainView.png",pos={x=0,y=0},fontSize=16},
    -- {toViewData={name="vip.VipView",type=0,index=0},toIndex = 3,txtImg=lang("MAIN_YUEKA"),iconName="button_yueka_mainView.png",pos={x=0,y=12},fontSize=16},
    {toViewData={name="activity.ActivityView",jumpType=1,specifiedAcId = 100},toIndex = 3,txtImg=lang("MAIN_YUEKASUPER"),iconName="button_yuekaVip_mainView.png",pos={x=0,y=0},fontSize=16},
    {toViewData={name="vip.VipView",jumpType=2,type=1,index=5},toIndex = 0,txtImg=lang("MAIN_SIXINGFENGHUANG"),iconName="button_shouchong_mainView.png",effect = "shouchong_firstrechargeanim",pos={x=-2,y=0},fontSize=16},
    {toViewData={name="vip.VipView",jumpType=2,type=1,index=8},toIndex = 0,txtImg=lang("MAIN_WUXINGFENGHUANG"),iconName="button_shouchong_mainView.png",effect = "shouchong_firstrechargeanim",pos={x=-2,y=0},fontSize=16},
    {toViewData={name="vip.VipView",jumpType=2,type=1,index=10},toIndex = 0,txtImg=lang("MAIN_SANXINGSIQI"),iconName="button_siqi_mainView.png",pos={x=0,y=0},fontSize=16},
    {toViewData={name="vip.VipView",jumpType=2,type=1,index=12},toIndex = 0,txtImg=lang("MAIN_SIXINGSIQI"),iconName="button_siqi_mainView.png",pos={x=0,y=0},fontSize=16},
    {toViewData={name="vip.VipView",jumpType=2,type=1,index=13},toIndex = 0,txtImg=lang("MAIN_CHENGSEBAOWU"),iconName="button_orangeTreasure_mainView.png",pos={x=-2,y=0},fontSize=16},
    {toViewData={name="vip.VipView",jumpType=2,type=1,index=14},toIndex = 0,txtImg=lang("MAIN_WUXINGSIQI"),iconName="button_siqi_mainView.png",pos={x=0,y=0},fontSize=16} ,
    {toViewData={name="vip.VipView",jumpType=2,type=1,index=15},toIndex = 0,txtImg=lang("MAIN_CHENGSEBAOWU"),iconName="button_orangeTreasure_mainView.png",pos={x=-2,y=0},fontSize=16},
    -- {toViewData={name="vip.VipView",type=1,index=4},txtImg=lang("MAIN_HEROUP"),iconName="button_heroStar_mainView.png",pos={x=0,y=11},fontSize=16} , 
    {toViewData={name="vip.VipView",jumpType=2,type=1,index=16},toIndex = 0,txtImg=lang("MAIN_DKWEAPON"),iconName="botton_vip15_mainView.png",pos={x=-2,y=0},fontSize=16},
    {toViewData={name="vip.VipView",jumpType=2,type=1,index=17},toIndex = 0,txtImg=lang("MAIN_DKWEAPON4STARS"),iconName="botton_vip15_mainView.png",pos={x=0,y=0},fontSize=16} ,
    {toViewData={name="vip.VipView",jumpType=2,type=1,index=18},toIndex = 0,txtImg=lang("MAIN_DKWEAPON6STARS"),iconName="botton_vip15_mainView.png",pos={x=-2,y=0},fontSize=16},   
}

local DirectShopOpenNeedDay = tab:Setting("G_SPECIALSHOP_ACTIV").value/24 --直购功能需要的开服时间（天）
-- 创建功能按钮上面的文字

local function createUpBtnTitleLabel(ui, name, x, y,fontSize)
    if ui:getChildByFullName(31555) then ui:removeChildByName(31555, true) end
    -- ui:setScale(0.85)
    -- print("=====================",fontSize)2
    -- y = 0getui
    local fntSize = 14   --fontSize or 
    local label = cc.Label:createWithTTF(name, UIUtils.ttfName, fntSize)
    label:setColor(cc.c3b(255, 255, 255))
    label:enableOutline(cc.c4b(60, 30, 10, 255), 2)
    label:setPosition(ui:getContentSize().width * 0.5 + x, y)
    label:setTag(31555)
    label:setName(31555)
    ui.label = label
    ui:addChild(label, 9999)
    local bgImg = ui:getChildByFullName("bg_img") 
    if bgImg then
        -- local labelW = label:getContentSize().width
        -- labelW = math.max(labelW,54)
        bgImg:setPosition(ui:getContentSize().width*0.5,12)
        -- bgImg:setContentSize(cc.size(labelW,27))
        -- bgImg:setScale9Enabled(true)
        -- bgImg:setCapInsets(cc.rect(25,16,1,1))
    end
end

local function createViewTitleLabel(ui, name)

    local label = cc.Label:createWithTTF(name, UIUtils.ttfName, 18)
    label:setName("titleTxt")
    label:setColor(UIUtils.colorTable.ccBuildNameColor)
    label:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- label:enableShadow(cc.c4b(0, 0, 0, 160), cc.size(3, -3))
    ui.label = label
    ui:setScale9Enabled(true)
    ui:setCapInsets(cc.rect(21,18,1,1))
    local w, h = 103,36--label:getContentSize().width + 10, label:getContentSize().height 
    -- if h < 40 then h = 40 end
    ui:setContentSize(w, h)
    label:setPosition(ui:getContentSize().width * 0.5, ui:getContentSize().height * 0.5)
    ui:addChild(label)

end

function MainView:destroy()
    if self._scrollSchedule then
        ScheduleMgr:unregSchedule(self._scrollSchedule)
    end
    if self._updateId then
        ScheduleMgr:unregSchedule(self._updateId)
        self._updateId = nil
    end
    if self._sRedSche then
        ScheduleMgr:unregSchedule(self._sRedSche)
        self._sRedSche = nil
    end
    if pc.PCTools.hasNationalVoice then
        sdkMgr:gvoice_QuitRoom(GameStatic.diantai_roomName, function ()

        end)
        sdkMgr:gvoice_setMessageMode()
    end
    if GameStatic.diantai_show and self._initGFMSDK then 
        sdkMgr:gfmCloseLive()
    end

    if self._crossGodWarUpdate then
        ScheduleMgr:unregSchedule(self._crossGodWarUpdate)
        self._crossGodWarUpdate = nil
    end

    if self._crossGodWar64Ready then
        ScheduleMgr:unregSchedule(self._crossGodWar64Ready)
        self._crossGodWar64Ready = nil
    end
    MainView.super.destroy(self, true)
end

function MainView:onHide()
    if self._updateId then
        ScheduleMgr:unregSchedule(self._updateId)
        self._updateId = nil
    end
    self.__isHide = true

    if self._crossGodWarUpdate then
        ScheduleMgr:unregSchedule(self._crossGodWarUpdate)
        self._crossGodWarUpdate = nil
    end

    if self._crossGodWar64Ready then
        ScheduleMgr:unregSchedule(self._crossGodWar64Ready)
        self._crossGodWar64Ready = nil
    end
end

function MainView:onTop()
    self:hideQipaoOnTop()
    self.__isHide = false
    -- 展示特权buff
    self:showPrivilegesBuff()
    self:newActionOpen()
    self:updateGodWarTitle()
    -- local tempNoticeId = self._modelMgr:getModel("MainViewModel"):getActionOpen()
    -- print("MainViewModel============", tempNoticeId)
    -- if tempNoticeId == true then
    --     self._viewMgr:lock(-1)
    -- end
    self:checkDirectShopOpen()
    self:checkExpExchangeOpen()
    self._battery:setPercent(sdkMgr:getBatteryPercent() * 100)
    
    --更新底部按钮位置
    if self._extendBar then 
        self._extendBar:updateExtendBar()
    end

    self:updateExtendBar2()
    self:setNavigation()
    if isJieRi3 then
        audioMgr:playMusic("mainmenuChristmas", true)
    else
        audioMgr:playMusic("mainmenu", true)
    end

    self:hadNewBtnInfo()

    self:updateFightNum()
    self:resumeDaysTimeCount()  
    self:updateTaskBtn()
    if not self._preFightNum then
        self._preFightNum = self:updateFightNum()
    end
    local newFightNum = self:updateFightNum()
    if self._preFightNum < newFightNum then
        self:fightNumScroll( self._preFightNum,newFightNum )
        self._preFightNum = newFightNum
    end
    if self._preFightNum ~= newFightNum then
        self._preFightNum = newFightNum
    end
    if self._updateId then
        ScheduleMgr:unregSchedule(self._updateId)
        self._updateId = nil
    end
    self._updateId = ScheduleMgr:regSchedule(5000, self, function(self, dt)
        self:update(dt)
    end)
    self:update()
    
    
    -- 根据时间改变主城背景
    TimeUtils.reCalculateMainViewTimeType()
    if TimeUtils.mainViewVer ~= mainViewVer then
        self:changeBG()
    end

    -- 云彩
    local tc = cc.Director:getInstance():getTextureCache() 
    if not tc:getTextureForKey("asset/bg/mainViewBg"..bgNameExt..".png") then
        self:cloudAnim()
    end

    -- self:actionOpen()
    local carnivalModel = self._modelMgr:getModel("ActivityCarnivalModel")  
    carnivalModel:doUpdate()
    local acUltimateModel = self._modelMgr:getModel("AcUltimateModel")  
    acUltimateModel:doUpdate()

    -- 回流更新
    if self._backFlowView and self._backFlowView.updateACLayer3Data then
        self._backFlowView:updateACLayer3Data()
    end
    -- 右上按钮回主界面主动展开
    -- if not self._extendRightBtnIsShow then
    --     self._extendRightBtnIsShow = true
    -- end

    -- 更新训练场新关卡气泡
    self:initTrainBtnQipao()

    self:reflashAdvanve()
    -- 更新庆典按钮状态
    self:updateCelebrationBtn()

    function AppExit()
        APP_EXIT = true
        local scene = cc.Director:getInstance():getRunningScene()
        if scene then scene:setPosition(-10000, -10000) end
        if OS_IS_IOS then
            cc.Director:getInstance():endToLua()
            os.exit()
        else
            cc.Director:getInstance():endToLua()
        end
    end

    for i = 1, 10 do
        _G["AppExit"..i] = function ()
            APP_EXIT = true
            local scene = cc.Director:getInstance():getRunningScene()
            if scene then scene:setPosition(-10000, -10000) end
            if OS_IS_IOS then
                cc.Director:getInstance():endToLua()
                os.exit()
            else
                cc.Director:getInstance():endToLua()
            end
        end
    end

    self:onSombra()

    self:updateInstanceBtnImage()

    self:updateDianTai()

    if self._modelMgr:getModel("ActivityModel"):isActivityOpen(40005) then
        self:updateGadget(1)
    end

    self._modelMgr:getModel("LordManagerModel"):reflashMainView()
    self:updateMerchantBtn()
end

function MainView:onReconnect()
    GLOBAL_VALUES.onSombra = true
    if self.visible then
        self:onSombra()
    end
end

function MainView:onSombra()
    -- 重新请求gameStatic和patch
    if OS_IS_WINDOWS then return end
    pcall(function ()
        local canDo = false
        local tick = socket.gettime()
        if GameStatic.reqGameStaticType == 2 then
            if GLOBAL_VALUES.onSombra then
                GLOBAL_VALUES.onSombra = nil
                canDo = true
            end
        end
        if GameStatic.reqGameStaticType == 1 then
            local inv = GameStatic.reqGameStaticInv or 3600
            if tick > self._lastReqGameStaticTick + inv then
                self._lastReqGameStaticTick = tick
                canDo = true
            end
        end
        if canDo then
            if GLOBAL_VALUES.vmsUrl then
                self:lock()
                HttpManager:getInstance():sendMsg(GLOBAL_VALUES.vmsUrl, "get", {}, 
                    function (result)
                        self:unlock()
                        local response = json.encode(result)
                        if self._lastReqGameStatic ~= response then
                            self._lastReqGameStatic = response
                            if GameStatic and result and result.GameStatic and type(result.GameStatic) == "table" then
                                -- 更新游戏配置
                                for key, value in pairs(result.GameStatic) do
                                    local oldValue = GameStatic[key]
                                    GameStatic[key] = value
                                    pcall(function () print("GameStatic [key]" .. key .. " "..tostring(oldValue).." => " .. tostring(value)) end)
                                end
                            end
                            if result.patch and result.patch ~= cjson.null and result.patch ~= "" then
                                if self._lastPatch ~= result.patch then
                                    local f = loadstring(result.patch)
                                    self._lastPatch = result.patch
                                    G_patchTab = {}
                                    pcall(f)
                                    print("newPatch")
                                end
                            end
                        end
                    end,
                    function ()
                        self:unlock()
                    end, GameStatic.useHttpDns_Vms)
            end
        end
    end)
end

function MainView:onShow()
    local isHaveMsg, msg = self._modelMgr:getModel("UserModel"):getIdipMessage()
    if isHaveMsg then
        self._viewMgr:showSelectDialog(msg, "", function()
            print("send readIdipMsg")
            self._serverMgr:sendMsg("IndexServer", "readIdipMsg", {}, true, {})
        end, "")
    end
    if not self._preFightNum then
        self._preFightNum = self:updateFightNum()
    end
    -- 登录后进入主界面检测拉起
    WakeUpUtils.checkCacheExtInfo()

    -- 检查换包奖励
    local gameVerTab = tab.setting["G_GAME_VERSION"] and tab.setting["G_GAME_VERSION"].value
    local gameVer
    if OS_IS_IOS then
        gameVer = gameVerTab and gameVerTab[2]
    else
        gameVer = gameVerTab and gameVerTab[1]
    end
    local changePakageVer = self._modelMgr:getModel("UserModel"):getChangePakageVer()
    local gameCurVersion = string.sub(GameStatic.version,5,string.len(GameStatic.version))
    gameCurVersion = tonumber(GameStatic.version) or tonumber(gameCurVersion)
    print("gameVer",gameVer,"changePakageVer",changePakageVer,"gameCurVersion",gameCurVersion,"GameStatic.version",GameStatic.version)
    if gameVer and gameCurVersion and (not changePakageVer or (changePakageVer ~= gameVer and gameCurVersion == gameVer)) then
        self._serverMgr:sendMsg("UserServer", "replacePackage", {packageVer = gameCurVersion}, true, {}, function(result,succ)
            if OS_IS_WINDOWS then
                self._viewMgr:showTip("已领取换包奖励！")
            end
        end,function( )
        end)
    end 
    TimeUtils.reCalculateMainViewTimeType()
    if TimeUtils.mainViewVer ~= mainViewVer then
        self:changeBG()
    end
end

-- 检查是否开启调查问卷
function MainView:checkQuestionOpen()
    local serverOpenTime = os.time()--self._modelMgr:getModel("UserModel"):getOpenServerTime()
    local lv = self._modelMgr:getModel("UserModel"):getData().lvl
    for i = 1, GameStatic.questionCount do
        local beginTime = GameStatic["question"..i.."Begin"]
        local endTime = GameStatic["question"..i.."End"]
        if beginTime <= serverOpenTime and serverOpenTime <= endTime and lv >= GameStatic["question"..i.."Level"] then
            self._questionAddress = GameStatic["questionAddress"..i]
            print(serverOpenTime)
            if i == 1 then
                self:getUI("leftBtnLayer.scrollView.surveyBtn").label:setString("问卷有礼")
            else
                self:getUI("leftBtnLayer.scrollView.surveyBtn").label:setString("问卷有礼"..i)
            end
            return true,i
        end
    end
    return false,nil
end

function MainView:cloudAnim()
    if self._cloudMc then self._cloudMc:removeFromParent() end
    self._cloudMc = mcMgr:createViewMC("yunqiehuan1_mfqiehuanyun", false, true, function ()
        self._cloudMc = nil
    end)
    self._cloudMc:gotoAndStop(6)
    self._cloudMc:setAnchorPoint(cc.p(0.5, 0.5))
    self._cloudMc:setPosition(self._bg:getContentSize().width * 0.5, self._bg:getContentSize().height * 0.5)
    self._widget:addChild(self._cloudMc, 3)
    
    cc.SpriteFrameCache:getInstance():addSpriteFrames("asset/bg/mainViewBg"..bgNameExt..".plist", "asset/bg/mainViewBg"..bgNameExt..".png")
    self._backBg.backBg1:setSpriteFrame("bg_mainview.png")
    self._backBg.backBg2:setSpriteFrame("bg_mainview.png")
    self._backBg.backBg3:setSpriteFrame("bg_mainview.png")
    if mainViewVer == 3 then
        self._backBg2:setSpriteFrame("bg_mainview1.png")
    end
    self._fgSp2:setSpriteFrame("mainviewfg_1_2.png")
    for i = 1, #self._maps do
        self._maps[i][1]:loadTexture(self._maps[i][2], 1)
    end
    ScheduleMgr:delayCall(0, self, function()
        if self._cloudMc then
            self._cloudMc:play()
        end
    end)
end

function MainView:enterBattle()
    local sfc = cc.SpriteFrameCache:getInstance()
    local tc = cc.Director:getInstance():getTextureCache() 
    self._backBg.backBg1:setSpriteFrame("bg_head_mainView.png")
    self._backBg.backBg2:setSpriteFrame("bg_head_mainView.png")
    self._backBg.backBg3:setSpriteFrame("bg_head_mainView.png")
    self._backBg2:setSpriteFrame("bg_head_mainView.png")
    self._fgSp2:setSpriteFrame("bg_head_mainView.png")
    for i = 1, #self._maps do
        self._maps[i][1]:loadTexture("bg_head_mainView.png", 1)
    end
    sfc:removeSpriteFramesFromFile("asset/bg/mainViewBg"..bgNameExt..".plist")
    tc:removeTextureForKey("asset/bg/mainViewBg"..bgNameExt..".png")
end


function MainView:update(dt)
    self._dtTime = self._dtTime + (dt or 0)

    local time = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
    self._timeLabel:setString(TimeUtils.date("%H:%M", time))

    local netType = AppInformation:getInstance():getNetworkType()
    if netType == 2 then
        -- wifi
        self._network:setVisible(true)
        self._network:loadTexture("wifi_mainView.png", 1)
    elseif netType == 3 then
        -- 234G
        self._network:setVisible(true)
        self._network:loadTexture("2g_mainView.png", 1)
    else
        self._network:setVisible(false)
    end

    if TimeUtils.getIntervalByTimeString(JIERI_3_BEGIN) < time and
        TimeUtils.getIntervalByTimeString(JIERI_3_END) > time
    then
        GameStatic.mainViewJieRi3 = true
    else
        GameStatic.mainViewJieRi3 = false
    end

    if isJieRi3 ~= GameStatic.mainViewJieRi3 then
        isJieRi3 = GameStatic.mainViewJieRi3
        self:setJieRi3()
    end
    if isJieRi ~= TimeUtils.mainViewActIsOpen(TimeUtils.Year) then
        isJieRi = TimeUtils.mainViewActIsOpen(TimeUtils.Year)
        self:setJieRi()
    end

    if self._dtTime >= 60 then
        self._dtTime = 0
        if not self._modelMgr:getModel("ActivityModel"):isActivityOpen(40005) then
            self:clearGadget()
        else
            if self._gadgetIcons == nil then
                self:initGadget()
            else
                self:updateGadget()
            end
        end
    end
    --更新主城烟花特效
    self:updateYanHuaAni(dt)
    --更新主城boss战入口
    self:addWorldBossBtn()
end

-- 回主界面时战斗力变化动画
function MainView:fightNumScroll( oldFightNum,newFightNum )
    local fightLabel = self._zhandouliLabel
    -- self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
        audioMgr:playSound("PowerCount")
    -- end)))
    -- local addfight = self:getUI("nameBg.addFight")
    -- addfight:setVisible(true)
    -- addfight:setColor(cc.c3b(118,238,0))
    -- addfight:enableOutline(cc.c4b(60,30,10, 255), 1)
    fightLabel:stopAllActions()
    -- addfight:setString("+" .. (inTable.newFight - inTable.oldFight))
    local tempGunlun, tempFight 
    -- if (inTable.newFight - inTable.oldFight) < 10 then
    --     tempFight = math.floor(inTable.newFight * 0.01) * 100
    --     tempGunlun = inTable.newFight - tempFight
    -- elseif (inTable.newFight - inTable.oldFight) < 100 then
    --     tempFight = math.floor(inTable.newFight * 0.001) * 1000
    --     tempGunlun = inTable.newFight - tempFight
    -- else
    --     tempFight = 0
    --     tempGunlun = inTable.newFight - tempFight
    -- end
    -- tempGunlun = newFightNum - oldFightNum
    -- tempFight = oldFightNum
    -- local fightNum = tempGunlun / 20
    -- local numsch = 1
    -- local sequence = cc.Sequence:create(
    --     cc.ScaleTo:create(0.05, 0.9),
    --     cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(0.05),cc.CallFunc:create(function()
    --         fightLabel:setString("a" .. (tempFight + math.ceil(fightNum * numsch)))
    --         numsch = numsch + 1
    --     end)), 20),
    --     cc.CallFunc:create(function()
    --         fightLabel:setString("a" .. newFightNum)
    --         -- addfight:setPositionX(fightLabel:getPositionX() + fightLabel:getContentSize().width + 8)
    --         -- addfight:runAction(cc.Sequence:create(
    --         --     cc.FadeIn:create(0.2),
    --         --     cc.FadeTo:create(0.3, 80),
    --         --     -- cc.FadeOut:create(0.3),
    --         --     cc.FadeIn:create(0.2),
    --         --     cc.FadeOut:create(0.3)
    --         --     )
    --         -- )
    --     end),
    --     cc.ScaleTo:create(0.05, 0.8)
    --     )

    local tempGunlun, tempFight 
    tempFight = oldFightNum
    tempGunlun = newFightNum - oldFightNum

    local fightNum = tempGunlun / 10
    local numsch = 1
    local sequence = cc.Sequence:create(
        -- cc.Spawn:create(cc.ScaleBy:create(0.07, 0.2), cc.FadeTo:create(0.07, 167)),
        -- cc.Spawn:create(cc.ScaleTo:create(0.1, 0.7), cc.FadeTo:create(0.1, 255)),
        cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(0.06),cc.CallFunc:create(function()
            fightLabel:setString(tempFight + math.ceil(fightNum * numsch))
            numsch = numsch + 1
        end)), 10),
        
        cc.CallFunc:create(function()
            fightLabel:setString(newFightNum)
        end)
        )

    fightLabel:runAction(sequence)
end

function MainView:getAsyncRes()
    return 
        {
           
        }
end

-- 初始化伸缩条
function MainView:initExtendBar()
    local param = {}
    param.extendInfo = self._extendInfo
    -- 指定按钮宽度
    param.btnWidth = 82
    -- 预留宽度
    param.reserveWidth = 151
    -- 初始化状态1伸展，0收缩
    param.initState = 1
    -- 初始化风格，按照按钮宽度
    param.style = 1
    -- 按钮间距
    param.spaceWidth = 20
    param.fontSize = 16
    param.motionCallback = function(inState)
    -- inState 1展开，0收缩

    end
    -- 横向方向1左侧，2右侧
    param.horizontal = 2
    self._extendBar = require("game.view.global.GlobalExtendBarNode").new(param)
    local quickBg = self:getUI("bottomLayer")
    quickBg:addChild(self._extendBar)
    self._extendBar:setAnchorPoint(1, 0.5)
    self._extendBar:setPosition(quickBg:getContentSize().width, 60)

end

-- 左侧按钮伸缩
function MainView:initExtendBar2()
    self._extendBg2 = self:getUI("topLayer")
    -- self._extendBtn2 = self:getUI("topLayer.extendBtn")

    self._closeMorePanel = self:getUI("moreBtnPanel")
    self._closeMorePanel:setSwallowTouches(true)
    self._closeMorePanel.noSound = true
    self:registerClickEvent(self._closeMorePanel, function ()
        self:closeMoreBtnPanel()
    end)
    self._leftBtnLayer = self:getUI("leftBtnLayer")
    self:getUI("leftBtnLayer.Panel_83"):setSwallowTouches(true)
    self._moreBtnScrollView = self:getUI("leftBtnLayer.scrollView")

    self._moreBtn = self:getUI("topLayer.moreBtn")
    local redImg = self:addNoticeDot(self._moreBtn,{pos=cc.p(47,47)}) 
    redImg:setVisible(false)
    self:registerClickEvent(self._moreBtn, function ()
        self:openMoreBtnPanel()
    end)
    if GameStatic.appleExamine then
        self._moreBtn:setVisible(false)
    end
    self._extendBarIsExtend2 = false
    self._leftBtnLayer:setVisible(true)
    self._leftBtnLayer:setScale(0)
    local worldPos = self._moreBtn:getParent():convertToWorldSpace(cc.p(self._moreBtn:getPositionX(),self._moreBtn:getPositionY()))
    local pos = self._leftBtnLayer:getParent():convertToNodeSpace(cc.p(worldPos.x,worldPos.y))
    self._leftBtnLayer:setPositionY(pos.y)
    self._closeMorePanel:setVisible(false)

    -- 平台能力
    self._extendList = 
    {
        -- {self:getUI("leftBtnLayer.scrollView.buluoBtn")},

        {self:getUI("leftBtnLayer.scrollView.surveyBtn"), function ()
            local isOpen,idx = self:checkQuestionOpen()           
            return GameStatic.questionOpen and isOpen
        end},
        {self:getUI("leftBtnLayer.scrollView.discussBtn"), function()
            return false   --sdkMgr:isWX() or OS_IS_WINDOWS  --隐藏显示 by hgf 17.06.28
        end},
        {self:getUI("topLayer.qqVipBtn"), function()

            if GameStatic.appleExamine then return false end
            local tencentModel = self._modelMgr:getModel("TencentPrivilegeModel")
            if not tencentModel:isOpenPrivilege() then
                return false
            end
            return sdkMgr:isQQ() or OS_IS_WINDOWS
        end},
        {self:getUI("leftBtnLayer.scrollView.wxPublicBtn"), function()
            return sdkMgr:isWX() or OS_IS_WINDOWS
        end},
        {self:getUI("leftBtnLayer.scrollView.qqGiftsCenterBtn"), function()
            return (sdkMgr:isQQ() and (tonumber(sdkMgr:getChannelID()) and (tonumber(sdkMgr:getChannelID()) == 10000144 or tonumber(sdkMgr:getChannelID()) == 0)) or OS_IS_WINDOWS)
        end},
        -- vivo 渠道屏蔽心悦微社区部落格
        {self:getUI("leftBtnLayer.scrollView.xinyueBtn"), function()
            return (tonumber(sdkMgr:getChannelID()) and (tonumber(sdkMgr:getChannelID()) ~= 10003392 or tonumber(sdkMgr:getChannelID()) == 0)) or OS_IS_WINDOWS
        end},
        {self:getUI("leftBtnLayer.scrollView.weiSheQuBtn"), function()
            return (tonumber(sdkMgr:getChannelID()) and (tonumber(sdkMgr:getChannelID()) ~= 10003392 or tonumber(sdkMgr:getChannelID()) == 0)) or OS_IS_WINDOWS
        end},
        {self:getUI("leftBtnLayer.scrollView.buluoBtn"), function()
            return (tonumber(sdkMgr:getChannelID()) and (tonumber(sdkMgr:getChannelID()) ~= 10003392 or tonumber(sdkMgr:getChannelID()) == 0)) or OS_IS_WINDOWS
        end},

    }

    -- 位置适配
    self._leftBtnList = {
        self:getUI("topLayer.mailBtn"),
        self:getUI("topLayer.friendBtn"),
        self:getUI("topLayer.fShopBtn"),
        self:getUI("topLayer.chatBtn"),
        self:getUI("topLayer.moreBtn"),
    }

    -- 平台按钮
    self._extendList2 = 
    {
        self:getUI("leftBtnLayer.scrollView.surveyBtn"),
        self:getUI("leftBtnLayer.scrollView.buluoBtn"),
        -- self:getUI("lecloseMorePanel.leftBtnLayer.scrollView.qaBtn"),
        self:getUI("leftBtnLayer.scrollView.topPayBtn"),
        -- self:getUI("topLayer.qqVipBtn"),
        self:getUI("leftBtnLayer.scrollView.discussBtn"),
        self:getUI("leftBtnLayer.scrollView.xinyueBtn"),
        self:getUI("leftBtnLayer.scrollView.weiSheQuBtn"),
        self:getUI("leftBtnLayer.scrollView.wxPublicBtn"),
        self:getUI("leftBtnLayer.scrollView.qqGiftsCenterBtn"),
    }
    -- for i = 1, #self._extendList do
    --     self._extendList[i][1]:setCascadeOpacityEnabled(true)
    -- end

    -- for i = 1, #self._extendList2 do
    --     self._extendList2[i]:setCascadeOpacityEnabled(true)
    -- end
    -- self._extendBarIsExtend2 = true
    -- self:registerClickEvent(self._extendBtn2, function ()
    --     self:doExtendBarAnim2()
    -- end) 
end


function MainView:updateExtendBar2()
    local btn
    local commonY = self._leftBtnList[1]:getPositionY()
    local commonH = self._leftBtnList[1]:getContentSize().height + 12  --按钮之间的间距

    -- qq特权按钮位置
    local qqVipBtn = self:getUI("topLayer.qqVipBtn")
    qqVipBtn:setPosition(46, commonY + qqVipBtn:getContentSize().height + 12)

    for i = 1, #self._leftBtnList do
        btn = self._leftBtnList[i]
        if btn and btn:isVisible() then                    
            btn:setPosition(46, commonY)
            commonY = commonY - commonH
        end
    end

    --领主管家按钮位置 适配
    local posY = self:getUI("topLayer.qqVipBtn"):getPositionY()
    local posX = 46
    if sdkMgr:isQQ() or OS_IS_WINDOWS then
        posX = 116
    end
    local pos = cc.p(posX,posY)
    self:getUI("topLayer.lordBtn"):setPosition(pos)
    -- self._extendVisibleBtns2 = {}
    local height = self._leftBtnLayer:getContentSize().height
    local width = self._leftBtnLayer:getContentSize().width
    for i = 1, #self._extendList do
        -- 如果有限制开启 加在这里
        repeat
            if self._extendList[i][2] then
                if not self._extendList[i][2]() then
                    self._extendList[i][1]:setVisible(false)
                    break
                else
                    self._extendList[i][1]:setVisible(true)
                end
            end
            -- self._extendVisibleBtns2[#self._extendVisibleBtns2 + 1] = self._extendList[i][1]
        until true
    end
 
    local tencentModel = self._modelMgr:getModel("TencentPrivilegeModel")
    if tencentModel:isOpenPrivilege() then
        self:getUI("topLayer.qqVipBtn.redPoint"):setVisible(false)
        local qqVipBtn = self:getUI("topLayer.qqVipBtn")
        local redDot = qqVipBtn:getChildByName("noticeTip")
        if not redDot then
            redDot = self:addNoticeDot(qqVipBtn,{pos=cc.p(47,47)}) 
        end
        redDot:setVisible((sdkMgr:isQQ() or OS_IS_WINDOWS) and tencentModel:isQQPrivilegeTip())
    end
    -- self:getUI("topLayer.qqVipBtn.redPoint"):setVisible(
    --     (vipTp == tencentModel.IS_QQ_VIP or vipTp == tencentModel.IS_QQ_SVIP or OS_IS_WINDOWS) and
    --     tencentModel:isQQPrivilegeTip()
    -- )

    -- 更新调查问卷红点
    local surveyBtn = self:getUI("leftBtnLayer.scrollView.surveyBtn")
    if surveyBtn:isVisible() then        
        local redDot = surveyBtn:getChildByName("noticeTip")
        if not redDot then
            redDot = self:addNoticeDot(surveyBtn,{pos=cc.p(47,47)}) 
        end
        local isOpen,idx = self:checkQuestionOpen()
        local clicked = false
        if idx then
            clicked = SystemUtils.loadAccountLocalData("SURVEYBTN_HAD_CLICKED" .. idx)
        end
        redDot:setVisible(not clicked)
    end
    local count = 0
    self._moreBtnIsRed = false
    for i = 1, #self._extendList2 do
        -- btn:setVisible(true)  --test
        btn = self._extendList2[i]
        if btn:isVisible() then      
            count = count + 1
            local redDot = btn:getChildByName("noticeTip")
            if not self._moreBtnIsRed and redDot and redDot:isVisible() then
                self._moreBtnIsRed = true
            end
        end
    end

    -- 展开按钮添加红点
    local extendDot = self._moreBtn:getChildByName("noticeTip")
    if extendDot then
        extendDot:setVisible(self._moreBtnIsRed and not self._extendBarIsExtend2)
    end

    local btnH = 76
    local scroH = math.ceil(count/4) * btnH + 12
    scroH = scroH > self._moreBtnScrollView:getContentSize().height and scroH or self._moreBtnScrollView:getContentSize().height
    self._moreBtnScrollView:setInnerContainerSize(cc.size(self._moreBtnScrollView:getContentSize().width,scroH))
    
    local btnX = 36
    local btnY = scroH + btnH * 0.5
    local btnNum = 4    --一行四个

    count = 0
    for i = 1, #self._extendList2 do
        btn = self._extendList2[i]
        if btn:isVisible() then
            if count % btnNum == 0 then
                btnX = 36
                btnY = btnY - btnH
            end           
            btn:setPosition(btnX, btnY)
            btnX = btnX + btnH          
            count = count + 1
        end
    end
   
    -- 超过三行可拖动
    if math.ceil(count / btnNum) < 3 then
        self._moreBtnScrollView:setBounceEnabled(false)
    else
        self._moreBtnScrollView:setBounceEnabled(true) 
    end
end

-- 心悦特权红点更新
function MainView:updatePlatformBtnRed()
     -- 红点列表
    if not self._platformBtnList then
        self._platformBtnList = {
            {self:getUI("leftBtnLayer.scrollView.xinyueBtn"),function ()                
                return self._mainViewModel:isRedNoticedByKey("heartPrivilege")
            end},           
        }
    end
    for k,v in pairs(self._platformBtnList) do
        local btn = v[1]
        if btn then
            local redDot = btn:getChildByName("noticeTip")
            if redDot then
                redDot:setVisible(v[2]())
            end
        end
    end

    -- 更新更多按钮红点
    self:updateMoreBtnRed()
end 

function MainView:openMoreBtnPanel()
    if self._extendBarIsExtend2 then return end
    if self._extendBarAniming2 then return end    
    self._leftBtnLayer:setVisible(true)
    self._closeMorePanel:setVisible(true)  
    self._extendBarAniming2 = true
    self._leftBtnLayer:setScale(0)
    ScheduleMgr:delayCall(0, self, function ()
        self._leftBtnLayer:setScale(0.7)
        self._leftBtnLayer:runAction(cc.Sequence:create(
            cc.EaseOut:create(cc.ScaleTo:create(0.1, 1.05), 3), 
            cc.ScaleTo:create(0.07, 1.0),
            cc.CallFunc:create(function ()
                self._extendBarAniming2 = false
                self._extendBarIsExtend2 = true 
                SystemUtils.saveAccountLocalData("mainView_leftBtnIsShow", true)

            end)))
    end)
    -- 打开界面隐藏红点
    local extendDot = self._moreBtn:getChildByName("noticeTip")
    if extendDot then
        extendDot:setVisible(false)
    end
end

function MainView:closeMoreBtnPanel()
    if not self._extendBarIsExtend2 then return end
    if self._extendBarAniming2 then return end
    -- self._closeMorePanel:setVisible(false)    
    self._extendBarAniming2 = true
    self._leftBtnLayer:runAction(cc.Sequence:create(
        cc.ScaleTo:create(0.05, 1.1),
        cc.ScaleTo:create(0.06, 0.6),
        cc.CallFunc:create(function ()
            self._extendBarAniming2 = false
            self._extendBarIsExtend2 = false 
            self._leftBtnLayer:setVisible(false)
            self._closeMorePanel:setVisible(false) 
            SystemUtils.saveAccountLocalData("mainView_leftBtnIsShow", false)
            -- 更新更多按钮红点
            self:updateMoreBtnRed()
        end)))

    
    
end

-- 更新更多按钮的红点
function MainView:updateMoreBtnRed()
    self._moreBtnIsRed = false
    for i = 1, #self._extendList2 do
        -- btn:setVisible(true)  --test
        btn = self._extendList2[i]
        if btn:isVisible() then
            local redDot = btn:getChildByName("noticeTip")
            if not self._moreBtnIsRed and redDot and redDot:isVisible() then
                self._moreBtnIsRed = true
            end
        end
    end

    -- 展开按钮添加红点
    local extendDot = self._moreBtn:getChildByName("noticeTip")
    if extendDot then
        extendDot:setVisible(self._moreBtnIsRed and not self._extendBarIsExtend2)
    end
end

--[[
function MainView:doExtendBarAnim2()
    if self._extendBarAniming2 then return end
    self._extendBarIsExtend2 = not self._extendBarIsExtend2

    local disY = self._leftBtnLayer:getContentSize().height
    if not self._extendBarIsExtend2 then
        self._extendBtn2:setRotation(180)
        local btn, x, y
        for i = 1, #self._extendList2 do
            btn = self._extendList2[i]
            btn:stopAllActions()
            x = btn:getPositionX()
            y = btn:getPositionY()
            btn:runAction(cc.MoveTo:create(0.15, cc.p(x , y + disY)))
        end
    else
        self._extendBtn2:setRotation(0)
        local btn, x, y
        for i = 1, #self._extendList2 do
            btn = self._extendList2[i]
            btn:stopAllActions()
            x = btn:getPositionX()
            y = btn:getPositionY()
            btn:runAction(cc.MoveTo:create(0.15, cc.p(x, y - disY)))
        end
        
    end
    for i = 1, #self._extendList2 do
        self._extendList2[i]:setTouchEnabled(false)
    end
    
    self._extendBarAniming2 = true
    ScheduleMgr:delayCall(disY / 1093 * 1000 + 100, self, function()
        for i = 1, #self._extendList2 do
            self._extendList2[i]:setTouchEnabled(true)
        end        
        self._extendBarAniming2 = false
    end)
end
]]

function MainView:getRegisterNames()
    return {
        {"instanceBtn","bottomLayer.instanceBtn"},
}
end

function MainView:updateInstanceBtnImage()

    local isSiegeOpen,statusData = self._siegeModel:getEntranceState()
    isSiegeOpen = isSiegeOpen and statusData and statusData.status ~= self._siegeModel.STATUS_OVER
    local image
    if not isSiegeOpen then
       image = "button_fuben_mainView.png"
    else
       image = "button_siege_mainView.png"
    end
    self._instanceBtn:loadTextures(image,image,image,1)
    local order = 10
    -- if self._instanceBtn.shijie1 then
    --     self._instanceBtn.shijie1:removeFromParent(true)
    --     self._instanceBtn.shijie1 = nil
    -- end

    if isSiegeOpen then
       
        if self._instanceBtn.shijie2 then
            self._instanceBtn.shijie2:removeFromParent(true)
            self._instanceBtn.shijie2 = nil
        end
        if self._instanceBtn.shijie3 then
            self._instanceBtn.shijie3:removeFromParent(true)
            self._instanceBtn.shijie3 = nil
        end

        if not self._instanceBtn.siegeAni then
            local siegeAni = self:addAnimation2Node("gongchengzhananniu_gongchenganniu",self._instanceBtn,{zOrder=-1,offsetx = 1,offsety=-2,scale=1})
            self._instanceBtn.siegeAni = siegeAni
        end
        order = -2
    else
        if self._instanceBtn.siegeAni then
            self._instanceBtn.siegeAni:removeFromParent(true)
            self._instanceBtn.siegeAni = nil
        end
        
        if not self._instanceBtn.shijie2 then
            local clipNode = cc.ClippingNode:create()
            clipNode:setPosition(61,67)
            clipNode:setContentSize(cc.size(122, 127))
            local mask = cc.Sprite:createWithSpriteFrameName("button_more_mainView.png")
            mask:setAnchorPoint(0.5,0.5)
            mask:setScale(1.18)
            clipNode:setStencil(mask)
            clipNode:setAlphaThreshold(0.05)
            local mc = mcMgr:createViewMC("shijie2_mainviewrenwushijie", true,false)
            clipNode:addChild(mc)
            self._instanceBtn:addChild(clipNode,11)
            self._instanceBtn.shijie2 = clipNode
        end
        if not self._instanceBtn.shijie3 then
            local shijie3 = self:addAnimation2Node("shijie3_mainviewrenwushijie",self._instanceBtn,{zOrder=12,offsetx = 2,offsety=0,scale=1})
            self._instanceBtn.shijie3 = shijie3
        end
    end
    if not self._instanceBtn.shijie1 then
        local shijie1 = self:addAnimation2Node("shijie1_mainviewrenwushijie",self._instanceBtn,{zOrder=order,offsetx = 0,offsety=0,scale=1})
        self._instanceBtn.shijie1 = shijie1
    else
        self._instanceBtn:reorderChild(self._instanceBtn.shijie1,order)
        local x = self._instanceBtn:getContentSize().width*0.5
        local y = self._instanceBtn:getContentSize().height*0.5
        self._instanceBtn.shijie1:setPosition(x,y)
    end
    self:showSiegeQipao()
end

function MainView:showSiegeQipao()

    local isSiegeOpen, statusData = self._siegeModel:getEntranceState()
    isSiegeOpen = isSiegeOpen and statusData and statusData.status ~= self._siegeModel.STATUS_OVER
    local status = statusData.status
    local STATUS_SIEGE = self._siegeModel.STATUS_SIEGE
    local STATUS_PREDEFEND = self._siegeModel.STATUS_PREDEFEND
    local STATUS_DEFEND = self._siegeModel.STATUS_DEFEND
    local STATUS_PREOVER = self._siegeModel.STATUS_PREOVER
    if not isSiegeOpen or ( status ~= STATUS_SIEGE
        and status ~= STATUS_PREDEFEND
            and status ~= STATUS_DEFEND
                and status ~= STATUS_PREOVER) then
        if self._instanceBtn.siegeQipao then
            self._instanceBtn.siegeQipao:removeFromParent(true)
            self._instanceBtn.siegeQipao = nil
        end  
        return
    end
    local firstLable
    local secondLable
    local sprite
    local width,height = 147,57
    if not self._instanceBtn.siegeQipao then
        sprite = ccui.Scale9Sprite:createWithSpriteFrameName("globalImageUI_qipao2.png")
        sprite:setCapInsets(cc.rect(50, 15, 1, 1))
        sprite:setContentSize(147, 57)
        sprite:setFlippedX(true)
        sprite:setPosition(-20,125)
        self._instanceBtn:addChild(sprite,200)
        local scale = 1 / self._instanceBtn:getScale()
        local seq = cc.Sequence:create(cc.ScaleTo:create(1, scale+scale*0.1), cc.ScaleTo:create(1, scale))
        sprite:runAction(cc.RepeatForever:create(seq))
        self._instanceBtn.siegeQipao = sprite

        
        --第一行文字
        local firstLine = cc.Label:createWithTTF("斯坦德威克", UIUtils.ttfName, 16)
        firstLine:setAnchorPoint(0,0.5)
        firstLine:setPosition(width-8,height-15)
        firstLine:setColor(cc.c3b(60,30,0))
        -- firstLine:setFlipX(180)
        local _3dVertex1 = cc.Vertex3F(0,180, 0)
        firstLine:setRotation3D(_3dVertex1)
        sprite:addChild(firstLine)
        self._instanceBtn.firstLine = firstLine
        firstLable = firstLine

        --第二行文字
        local secondLine = cc.Label:createWithTTF("攻城中", UIUtils.ttfName, 14)
        secondLine:setAnchorPoint(0,0.5)
        secondLine:setPosition(width-8,height-32)
        secondLine:setColor(cc.c3b(60,30,0))
        -- secondLine:setFlipX(180)
        local _3dVertex1 = cc.Vertex3F(0,180, 0)
        secondLine:setRotation3D(_3dVertex1)
        sprite:addChild(secondLine)
        self._instanceBtn.secondLine = secondLine
        secondLable = secondLine
        -- secondLine:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    else
        sprite = self._instanceBtn.siegeQipao
        firstLable = self._instanceBtn.firstLine
        secondLable = self._instanceBtn.secondLine
    end
    local firstLineDes = {
        [3] = "斯坦德威克",
        [5] = "斯坦德威克",
        [4] = "斯坦德威克守卫战",
        [6] = "斯坦德威克守城战",
    }


    local function getTimeDes()
        local curTime = self._userModel:getCurServerTime()
        local leftTime = statusData.nextTime - curTime
        if leftTime <= 0 then
            return
        end
        local des = ""
        if leftTime <= 86400 then
            des = TimeUtils.getTimeString(leftTime)
        else
            des = TimeUtils:getTimeDisByFormat(leftTime)
        end
        return des
    end
    
    if secondLable then
        secondLable:stopAllActions()
        if status == STATUS_SIEGE then
            secondLable:setString("攻城中...")
            secondLable:setColor(cc.c3b(240,240,55))
            sprite:setContentSize(118, 57)
            width = 118
            secondLable:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        elseif status == STATUS_PREDEFEND then
            secondLable:setColor(cc.c3b(15,40,210))
            secondLable:runAction(cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.CallFunc:create(function()
                        local des = getTimeDes()
                        if des then
                            secondLable:setString(des.."后开启")
                        else
                            secondLable:stopAllActions()
                        end
                    end),
                    cc.DelayTime:create(1)
                )
            ))
            sprite:setContentSize(147, 57)
            width = 147
            secondLable:disableEffect()
        elseif status == STATUS_DEFEND then
            secondLable:setColor(cc.c3b(39,247,60))
            secondLable:setString("守城中...")
            sprite:setContentSize(118, 57)
            width = 118
            secondLable:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        elseif status == STATUS_PREOVER then
            secondLable:setColor(cc.c3b(250,40,40))
            sprite:setContentSize(147, 57)
            width = 147
            secondLable:runAction(cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.CallFunc:create(function()
                        local des = getTimeDes()
                        if des then
                            secondLable:setString(des.."后结束")
                        else
                            secondLable:stopAllActions()
                        end
                    end),
                    cc.DelayTime:create(1)
                )
            ))
            secondLable:disableEffect()
        end
        secondLable:setPositionX(width-8)
    end

    if firstLable and firstLineDes[status] then
        firstLable:setString(firstLineDes[status])
        firstLable:setPositionX(width-8)
    end


end

function MainView:onInit()
    audioMgr:playMusic("mainmenu", true)

    self._beginTick = socket.gettime()
    self._extendInfo = 
    {
        {"privilegeBtn",    "button_tequan_mainView.png",       lang("MAIN_TEQUAN"),        "privileges.PrivilegesView", "Privilege"},
        {"taskBtn",         "button_renwu_mainView.png",        lang("MAIN_RENWU"),         "task.TaskView", "Task",{isMainIn = true}},
        {"formationBtn",    "button_buzhen_mainView.png",       lang("MAIN_BUZHEN"),        "formation.NewFormationView", "Formation"},   
        {"bagBtn",          "button_beibao_mainView.png",       lang("MAIN_BEIBAO"),        "bag.BagView", "Item"},
        {"treasureBtn",     "button_treasure_mainView.png",     lang("MAIN_BAOWU"),         "treasure.TreasureView", "Treasure"},
        {"holyBtn",         "button_holy_mainView.png",         lang("MAIN_SHENGHUI"),      "team.TeamHolyView", "Holy"},     
        {"heroBtn",         "button_yingxiong_mainView.png",    lang("MAIN_YINGXIONG"),     "hero.HeroView", "Hero"},     
        {"monsterBtn",      "button_bingtuan_mainView.png",     lang("MAIN_BINGTUAN"),      "team.TeamListView", "Team"}, 
    }
    if GameStatic.enableDevelop then
        self._extendInfo[#self._extendInfo + 1] = {"devBtn","123.png","研发中",function () self._viewMgr:showDialog("dev.DevelopDialog", {}, true) end}
    end
    self:initExtendBar()
    -- 左上角按钮
    self._extendBg2 = self:getUI("topLayer")
    -- self._extendBtn2 = self:getUI("topLayer.extendBtn")
    self:initExtendBar2()

    self._inActionFirst = false

    -- 右上按钮
    self:initExtendRightBtn()

    createViewTitleLabel(self:getUI("bg.midBg1.chouka.title"), lang("MAIN_JITAN"))
    createViewTitleLabel(self:getUI("bg.midBg1.mana.title"), lang("MAIN_MOFAHANGHUI"))
    createViewTitleLabel(self:getUI("bg.midBg1.market2.title"), lang("MAIN_BAOWUCHOUKA"))
    createViewTitleLabel(self:getUI("bg.midBg1.market.title"), lang("MAIN_SHICHANG"))
    createViewTitleLabel(self:getUI("bg.midBg2.congress.title"), lang("MAIN_GUOHUI"))
    createViewTitleLabel(self:getUI("bg.midBg2.bar.title"), lang("MAIN_WARBACKUP"))
    createViewTitleLabel(self:getUI("bg.midBg2.huitushi.title"), lang("MAIN_TRAINING"))
    createViewTitleLabel(self:getUI("bg.midBg4.home.title"), lang("MAIN_DABENYING"))
    createViewTitleLabel(self:getUI("bg.midBg3.pve.title"), lang("MAIN_ZHANSHENXIANG"))
    createViewTitleLabel(self:getUI("bg.midBg4.yuanzheng.title"), lang("MAIN_YIJIEZHIMEN"))
    createViewTitleLabel(self:getUI("bg.midBg4.chuanwu.title"), lang("MAIN_HUITUSHI"))
    createViewTitleLabel(self:getUI("bg.midBg4_5.cloudy.title"), lang("MAIN_ZHUSHENDIAN"))
    createViewTitleLabel(self:getUI("bg.midBg5.chaoxue.title"), lang("MAIN_CHAOXUE"))

    self:getUI("topLayer.fShopBtn"):setVisible(true)
    self:getUI("rightLayer.rightBtnLayer.recallAcBtn"):setVisible(true)

    -- 天空城变色
    local _cloudCity = self:getUI("bg.midBg4_5.Image_52")
    _cloudCity:loadTexture("cloud_mainView"..bgNameExt..".png", 1)

    -- 注释 by hgf 17.04.11
    -- createUpBtnTitleLabel(self:getUI("leftBtnLayer.scrollView.qaBtn"), "GM", 0, 0,16)
    createUpBtnTitleLabel(self:getUI("leftBtnLayer.scrollView.surveyBtn"), lang("MAIN_QUESTIONNAIREGIFT"), 0, 0, 16)

    if sdkMgr:isWX() or OS_IS_WINDOWS then
        createUpBtnTitleLabel(self:getUI("leftBtnLayer.scrollView.buluoBtn"), "游戏圈", 0, 0, 16)
    else
        createUpBtnTitleLabel(self:getUI("leftBtnLayer.scrollView.buluoBtn"), "部落", 0, 0, 16)
    end
    createUpBtnTitleLabel(self:getUI("leftBtnLayer.scrollView.discussBtn"), "交流群", 0, 0, 16)
    createUpBtnTitleLabel(self:getUI("topLayer.qqVipBtn"), "QQ特权", 0, 0, 16)
    createUpBtnTitleLabel(self:getUI("leftBtnLayer.scrollView.xinyueBtn"), "心悦特权", 0, 0, 16)
    createUpBtnTitleLabel(self:getUI("leftBtnLayer.scrollView.weiSheQuBtn"), "微社区", 0, 0, 16)
    createUpBtnTitleLabel(self:getUI("leftBtnLayer.scrollView.wxPublicBtn"), "公众号", 0, 0, 16)
    createUpBtnTitleLabel(self:getUI("leftBtnLayer.scrollView.qqGiftsCenterBtn"), "礼包中心", 0, 0, 16)   
    createUpBtnTitleLabel(self:getUI("topLayer.mailBtn"), lang("MAIN_YOUJIAN"), 0, 0,16)
    createUpBtnTitleLabel(self:getUI("topLayer.friendBtn"), lang("MAIN_HAOYOU"), 0, 0,16)
    createUpBtnTitleLabel(self:getUI("topLayer.fShopBtn"), "友情商店", 0, 0,16)
    createUpBtnTitleLabel(self:getUI("topLayer.moreBtn"), "更多", 0, 0,16)
    createUpBtnTitleLabel(self:getUI("topLayer.lordBtn"), "领主管家", 0, 3,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.levelFBBtn"), lang("MAIN_SHENGJIYOULI"), 0, 0,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.chargeBtn"), lang("MAIN_CHONGZHI"), 0, 12,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.activityBtn"), lang("MAIN_HUODONG"), 0, 0,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.signBtn"), lang("MAIN_QIANDAO"), 0, 12,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.activityCommonBtn"), lang("MAIN_HUODONG"), 0,12,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.directShopBtn"), "商店", 0, 12,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rankBtn"), lang("MAIN_PAIHANG"), 0, 11,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.fightDragonBtn"), lang("MAIN_RANKGREENDRAGON"), 0, 0,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.acAdventureBtn"), lang("MAIN_SHENMIBAOZANG"), 0, 0,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.luckStarBtn"), lang("MAIN_XINGYUNLINGZHU"), 0, 0,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.luckTulingBtn"), lang("MAIN_XINGYUNLINGZHU"), 0, 0,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.lichBuyGiftBtn"), lang("MAIN_CHAOXUETEHUI"), 0, 0,16)
    createUpBtnTitleLabel(self:getUI("leftBtnLayer.scrollView.topPayBtn"), "贵宾特权", 0, 0,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.limitTeamBtn"), "限时招募", 0, 0,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.limitAwakenBtn"), "觉醒魂石", 0, 0,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.happyPopBtn"), "法术特训", 0, 0,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.recallAcBtn"), "友情福利", 0, 0,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.sprRedBtn"), "红包祝福", 0, 0,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.trainAcBtn"), lang("TRAINING_ACTIVITY_ICON"), 0, 0,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.celebrationBtn"), "元素庆典", 0, 0,16)
    -- createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.backflowBtn"), "回流活动", 0, 0,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.qqActivityBtn"), "邀请有礼", 0, 0,16)    
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.tehuiActivityBtn"), "充值特惠", 0, 0,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.powerGameBtn"), "凛冬已至", 0, 0,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.worldCupBtn"), "竞猜有礼", 0, 0,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.growthwayBtn"), "成长之路", 0, 0,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.ultimateBtn"), "终极降临", 0, 0,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.luckyLotteryBtn"), lang("MAIN_LUCKYLOTTERY"), 0, 0,16)
    createUpBtnTitleLabel(self:getUI("handbookBg.handbookBtn"), "领主手册", 0, -6, 30)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.oneChargeBtn"), "一元购", 0, 0,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.chargePresentBtn"), lang("ZHOUNIANHUIKUI_BUTTON_03"), 0, 0,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.limitPrayBtn"), "限时祈愿", 0, 0,16)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.wroldBossBtn"), "巨龙侵袭", 0, 0,16)

    self:showFriendRedPoint()

    self._vipIcon = self:getUI("topLayer.vipIcon")
    -- self._vipIcon:setAnchorPoint(cc.p(0,0.5))

    self._progressBar = self:getUI("topLayer.progressBar")
    self._levelLabel = self:getUI("topLayer.level")
    self._levelLabel:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    self._name = self:getUI("topLayer.name")
    self._userLv = self:getUI("topLayer.userLv")
    self._name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._userLv:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._timeLabel = self:getUI("topLayer.time")
    self._timeLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._battery = self:getUI("topLayer.batteryBg.battery")
    self._network = self:getUI("topLayer.network")

    self._battery:setPercent(sdkMgr:getBatteryPercent() * 100)

    -- self._zhandouliLabel = self:getUI("topLayer.zhandouliLabel2")
    local timeLab = self:getUI("bg.midBg4_5.cloudy.timeLab")
    timeLab:loadTexture("topBtn_bg_mainView_godwar.png", 1)

    local topLayer = self:getUI("topLayer")
    local fightText = ccui.Text:create()
    fightText:setString("战斗力")
    fightText:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
    fightText:enableOutline(cc.c4b(0,0,0,255),1)
    fightText:setFontName(UIUtils.ttfName)
    fightText:setFontSize(16)
    fightText:setAnchorPoint(cc.p(0,0.5))
    fightText:setPosition(cc.p(100, 133))
    topLayer:addChild(fightText, 1)

    self._zhandouliLabel = cc.LabelBMFont:create("1", UIUtils.bmfName_zhandouli)
    self._zhandouliLabel:setScale(0.5)
    self._zhandouliLabel:setAnchorPoint(cc.p(0,0.5))
    self._zhandouliLabel:setPosition(cc.p(100+fightText:getContentSize().width+2, 140))
    topLayer:addChild(self._zhandouliLabel, 1)


    self._fightNumTip = self:getUI("topLayer.fightNumTip")

    self._headImgNode = self:getUI("topLayer.headImgNode")

    self:registerClickEventByName("topLayer.Image_39_1", function( )
        -- DialogUtils.showScoreTip()
        self._viewMgr:showDialog("main.UserDialog", {callBack = function()
            self:checkExpExchangeOpen()
        end}, true)
    end)
    if OS_IS_WINDOWS or GameStatic.superDebug == "playcrab19870515" then
        local ui = self:getUI("topLayer.Image_39_1")
        local label = cc.Label:createWithTTF("uid: "..self._modelMgr:getModel("UserModel"):getUID() .. 
            "\n  id: "..self._modelMgr:getModel("UserModel"):getUSID(), UIUtils.ttfName, 20)
        label:setAnchorPoint(0, 1)
        label:enableOutline(cc.c4b(0,0,0,255), 2)
        label:setPosition(10, -80)
        ui:addChild(label)
    end

    self._bg = self:getUI("bg")
    self._foreBg = self:getUI("bg.foreBg")

    local buttonActivity = self:getUI("rightLayer.activityCommonBtn")
    self:addBtnEffect(buttonActivity,"huodong_mainactivityicon",buttonActivity:getContentSize().width/2,buttonActivity:getContentSize().height/2)
    -- print("==========================================",buttoncarnival.name)
    self._iconPoses = {}
    self:updateCarnivalState() 
    self:updateAcRightUpBtn()
    self._funOpenList = {
    --   按钮名称                           view名称,  systemOpen名称,  未开启前是否隐藏, 参数
        {"bg.midBg1.mana",                  "talent.CollegeView", "Talent"},
        {"bg.midBg1.market",                "shop.ShopView", "Shop"},
        {"bg.midBg1.market2",               "treasure.TreasureShopView","Treasure"},
        {"bg.midBg1.chouka",                "flashcard.FlashCardView"},
        {"bg.midBg2.congress",              "pokedex.PokedexView", "Pokedex"}, -- "guild.join.GuildInView","Guild"},
        {"bg.midBg2.bar",                   "weapons.WarReadinessView", "BattleArray"},
        {"bg.midBg2.huitushi",              "training.TrainingView","Training"},  --{"MF.MFView","MF"},
        {"bg.midBg4.home",                  "guild.join.GuildInView","Guild"}, -- "pokedex.PokedexView", "Pokedex"},
        {"bg.midBg4.chuanwu",               "crusade.CrusadeView", "Crusade"},
        {"bg.midBg3.pve",                   "pvp.PvpInView","Pvp"},
        {"bg.midBg4.yuanzheng",             "pve.PveView", "Pve"},
        {"bg.midBg4_5.cloudy",              "godwar.GodWarEntranceView", "GodWar"},
        {"bg.midBg5.chaoxue",               "nests.NestsView", "Nests"},
        

        {"bottomLayer.instanceBtn",         "intance.IntanceView", nil, {isReleaseAllOnShow = true}},

        -- "rightLayer.rightBtnLayer.firstChargeBtn",}
        {"rightLayer.signBtn",              "activity.ActivitySignInView","sign",true},  
        {"rightLayer.rightBtnLayer.activityBtn",          "",nil,true},
        
        {"rightLayer.rightBtnLayer.sevenDaysBtn",         "activity.ActivitySevenDaysView", "SevenDay", true},
        {"rightLayer.rightBtnLayer.levelFBBtn",           "activity.ActivityLevelFeedBackView", "LevelAward",true},
        {"rightLayer.activityCommonBtn",    "activity.ActivityView", "activity",true},

        {"rightLayer.rankBtn",              "rank.RankView","Rank",true},
        {"topLayer.friendBtn",              "friend.FriendView","GameFriend",true},
        {"topLayer.fShopBtn",               "friend.FriendShopView","FriendShop",true},
        {"topLayer.mailBtn",                "mailbox.MailBoxView", "Mail",true},  
        {"topLayer.lordBtn",                "lordmanager.LordManagerView", "LordManager",true},
        
    }
    
    --添加特效列表
    self._effectList = {
        --   按钮名称                        特效名,                           特效参数,                                       ,系统是否开启
        {"bg.midBg1.chouka",    "zhuchengchouka_mainviewchoukarukoufla",      {zOrder=99,offsetx = -2,offsety=20,scale=0.5}},
        {"bg.midBg4.yuanzheng", "zhuchengyijiezhimen_mainviewyijiezhimenfla", {zOrder=-1,scale=0.5,offsetx = 5,offsety=-17}       ,"Pve"},
        {"bg.midBg2.huitushi",  "xunlianchang_mainviewtraining",              {zOrder=-1,scale=0.5,offsetx = -5,offsety=-10}      ,"Training"},
        {"bg.midBg1.market2",   "zhuchengbaowuheishi_mainviewbaowuheishi",    {zOrder=-1,scale=0.5,offsetx = 10,offsety= 5}       ,"Treasure"},
        {"bg.midBg4.chuanwu",   "zhuchengzhanyi_mainviewyuanzheng",           {zOrder=99,scale=0.5,offsetx = -5,offsety=-8}       ,"Crusade"},
    }
    for i,v in ipairs(self._effectList) do
        local systemName = v[4]
        local btn = self:getUI(v[1])
        local isOpen = true
        if systemName then
            isOpen,_ = SystemUtils["enable".. systemName]()
        end
        if btn.__buildMc then
            btn.__buildMc:setVisible(isOpen)
        else
            local mc = self:addAnimation2Node(v[2],self:getUI(v[1]),v[3])
            mc:setVisible(isOpen)
        end
    end

    for i,v in ipairs(self._funOpenList) do
        self:addBtnFunction(v)
    end
    -- 竞技场标题可点击
    self:registerClickEventByName("bg.midBg3.pve.title", function ()
        if SystemUtils:enableArena() then
            self._viewMgr:showView("pvp.PvpInView")
        end
    end)
    -- 副本
    local instanceBtn = self:getUI("bottomLayer.instanceBtn")

    self:registerClickEventByName("topLayer.vipIcon", function ()
        self._bg:stopScroll()
        local vipLevel = self._modelMgr:getModel("VipModel"):getData().level or 0
        self._viewMgr:showView("vip.VipView", {viewType = 1,index = vipLevel})
    end)

    self._rightVipBtn = self:getUI("rightLayer.rightBtnLayer.vipBtn")
    self._rightVipBtn:setVisible(false)


    self._welfareBtn = self:getUI("topLayer.welfareBtn")
    self:registerClickEvent(self._welfareBtn, function ()
        self._viewMgr:showDialog("tencentprivilege.TencentPrivilegeView")
    end)
    if IS_ANDROID_OUTSIDE_CHANNEL then
        self._welfareBtn:setVisible(false)
    end

    --首冲
    local buttonFirst = self:getUI("rightLayer.rightBtnLayer.firstChargeBtn")
    local mc = self:addBtnEffect(buttonFirst,"shouchong_firstrechargeanim",buttonFirst:getContentSize().width/2,buttonFirst:getContentSize().height/2)
    createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.firstChargeBtn"), lang("MAIN_SHOUCHONG"), 0, 0,16)
    self:registerClickEventByName("rightLayer.rightBtnLayer.firstChargeBtn", function ()
        self._viewMgr:showDialog("activity.FirstRechargeView", {}, true)
    end)
    local chargePresentBtn = self:getUI("rightLayer.rightBtnLayer.chargePresentBtn")
    chargePresentBtn:setOpacity(0)
    local mc = self:addBtnEffect(chargePresentBtn,"huodonglonggui_huodonglonggui",chargePresentBtn:getContentSize().width/2,chargePresentBtn:getContentSize().height/2)
    mc:setScale(1)
    -- charge
    self:registerClickEventByName("rightLayer.chargeBtn", function ()
        self._bg:stopScroll()
        self._viewMgr:showView("vip.VipView", {viewType = 0})
    end)

    local directShopBtn = self:getUI("rightLayer.directShopBtn")
    --directShop
    self:registerClickEventByName("rightLayer.directShopBtn", function ()
        self._bg:stopScroll()
        local tabIndex = self._modelMgr:getModel("DirectShopModel"):getTopTabIndex() or 1
        self._viewMgr:showView("shop.DirectShopView",{idx = tabIndex},true)
    end)
    local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl
    local openDay = math.floor(self._modelMgr:getModel("UserModel"):getOpenServerTime()/86400)

    -- print("openDay == "..openDay)

    -- print("userlvl == "..userlvl)

    if openDay < DirectShopOpenNeedDay or userlvl < 23 then
        directShopBtn:setVisible(false)
    else
        directShopBtn:setVisible(true)
    end
    if GameStatic.appleExamine == true then
       directShopBtn:setVisible(true)
    end

    -- 限时祈愿
    -- local limitPrayBtn = self:getUI("rightLayer.rightBtnLayer.limitPrayBtn")
    -- local mc = self:addBtnEffect(limitPrayBtn,"shenpanguanrukou_shenpanguanrukou",limitPrayBtn:getContentSize().width*.5,limitPrayBtn:getContentSize().height*.5)

    -- local i = 1
    local headBg = self:getUI("topLayer.headImgNode.headBg")
    headBg:setOpacity(0)
    headBg:ignoreContentAdaptWithSize(false)
    headBg:setContentSize(108,108)
    self:registerClickEvent(headBg, function ()
        self._viewMgr:showDialog("main.UserDialog", {callBack = function()
            self:checkExpExchangeOpen()
        end}, true)        

        -- DialogUtils.showTeam({teamId=104}) --(100)*math.floor(i/7+1)+i%7+1})
        -- DialogUtils.showTeam({teamId=104})
        -- i=i+1
        -- DialogUtils.showGiftGet({gifts = {{"tool",3001,15},{"tool",3001,15},{"tool",3001,15},{"tool",3001,15}},bottomDes1 = "天下围殴共就对啦几个哦啊欧冠熬了ID的佳绩"})
        -- local heroUnlockLayer = self._viewMgr:createLayer("hero.HeroUnlockView", {heroId = 60102, callBack = function()end})
        -- self:addChild(heroUnlockLayer,999)

        -- DialogUtils.showGiftGet({
        --     gifts = {{"tool",3001,15}},
        --     title = lang("FINISHSTAGETITLE"),
        --     vipPlus = 1.5})

    end)
    headBg:setSwallowTouches(false)

    self:registerClickEventByName("handbookBg.handbookBtn", function ()
          self:showHandbookView()
    end)

    self:registerClickEventByName("noticeBg.notice", function ()
    --        local mainViewModel = self._modelMgr:getModel("MainViewModel")
    --        mainViewModel:clearQipao()
    --        mainViewModel:reflashMainView()
    --        self._viewMgr:showDialog("main.MainActionOpenDialog", {inType = 1}, true)
          self:showHandbookView()
    end)

    self:registerClickEventByName("noticeBg.notice1", function ()
        local mainViewModel = self._modelMgr:getModel("MainViewModel")
        mainViewModel:clearQipao()
        mainViewModel:reflashMainView()
        self._viewMgr:showDialog("main.MainActionOpenDialog", {inType = 2}, true)
    end)

    self._mainViewModel = self._modelMgr:getModel("MainViewModel")

    local buluoBtn = self:getUI("leftBtnLayer.scrollView.buluoBtn")
    if sdkMgr:isWX() then
        buluoBtn:loadTextures("button_youxiquan_mainView.png", "button_youxiquan_mainView.png", "", 1)
    end
    buluoBtn:setVisible(true)

    self:registerClickEventByName("leftBtnLayer.scrollView.discussBtn", function ()
        sdkMgr:loadUrl({url = GameStatic.wxDiscussUrl})
        print(GameStatic.wxDiscussUrl)
    end)

    self:registerClickEventByName("topLayer.qqVipBtn", function (sender)
        sdkMgr:loadUrl({url = self._modelMgr:getModel("TencentPrivilegeModel"):getPrivilegeUrl()})
        -- sender:getChildByFullName("redPoint"):setVisible(false)
        local redDot = sender:getChildByName("noticeTip")
        if redDot then
            redDot:setVisible(false)
        end
        self._modelMgr:getModel("TencentPrivilegeModel"):setHideQQPrivilegeTip()
    end)
    
    self:registerClickEventByName("leftBtnLayer.scrollView.buluoBtn", function ()
        if sdkMgr:isWX() then
            sdkMgr:loadUrl({url = GameStatic.wxGroupUrl})
            print(GameStatic.wxGroupUrl)
        else
            sdkMgr:loadUrl({url = GameStatic.qqGroupUrl})
            print(GameStatic.qqGroupUrl)
        end
    end)
    -- 心悦
    local xinyueBtn = self:getUI("leftBtnLayer.scrollView.xinyueBtn")
    self:registerClickEventByName("leftBtnLayer.scrollView.xinyueBtn", function ()        
        -- 1：心悦特权
        self._serverMgr:sendMsg("UserServer", "viewRedDots", {type=1}, true, {}, function (result)
            -- print("===========心悦特权点击协议============")
        end)
        local url = GameStatic.xinyuePrivilegeUrl .. GameStatic.opencode
        print("xinyue===", url)
        sdkMgr:loadUrl({url = url})
    end)
    local xinyueRedDot = xinyueBtn:getChildByName("noticeTip")
    if not xinyueRedDot then
        xinyueRedDot = self:addNoticeDot(xinyueBtn,{pos=cc.p(47,47)}) 
    end
    xinyueRedDot:setVisible(self._mainViewModel:isRedNoticedByKey("heartPrivilege"))
    xinyueBtn:setVisible(true)
    -- 微社区
    local weiSheQuBtn = self:getUI("leftBtnLayer.scrollView.weiSheQuBtn")
    self:registerClickEventByName("leftBtnLayer.scrollView.weiSheQuBtn", function ()
        print("微社区===",GameStatic.weiSheQuUrl)
        sdkMgr:loadUrl({url = GameStatic.weiSheQuUrl})
    end)
    weiSheQuBtn:setVisible(true)

    -- 关注公众号
    self:registerClickEventByName("leftBtnLayer.scrollView.wxPublicBtn", function ()
        if OS_IS_IOS then
            -- ios
            print("关注公众号IOS===",GameStatic.wxPublicUrlIOS)
            sdkMgr:loadUrl({url = GameStatic.wxPublicUrlIOS})
        elseif OS_IS_ANDROID then
            -- Android
            print("关注公众号Android===",GameStatic.wxPublicUrl)
            sdkMgr:loadUrl({url = GameStatic.wxPublicUrl})
        else
            print("关注公众号else===",GameStatic.wxPublicUrl)
            sdkMgr:loadUrl({url = GameStatic.wxPublicUrl})
        end
    end)

    -- 礼包中心
    local qqGiftsCenterBtn = self:getUI("leftBtnLayer.scrollView.qqGiftsCenterBtn")
    self:registerClickEventByName("leftBtnLayer.scrollView.qqGiftsCenterBtn", function ()
        print("礼包中心===",GameStatic.qqGiftsCenterUrl)
        sdkMgr:loadUrl({url = GameStatic.qqGiftsCenterUrl})
    end)

    --by wangyan 聊天
    local chatBtn = self:getUI("topLayer.chatBtn")
    chatBtn:setOpacity(0)
    local chatNode = require("game.view.global.GlobalChatNode").new(nil, function ()
        self:updateDianTai()
    end)
    chatNode:setAnchorPoint(0.5,0.5)
    chatNode:setPosition(chatBtn:getContentSize().width*0.5, chatBtn:getContentSize().height*0.5)
    chatBtn:addChild(chatNode, 100)
    createUpBtnTitleLabel(chatNode, "聊天", 0, 10,16)
    local chatListen = function(self, param)
        if chatNode ~= nil and chatNode.showChatUnread ~= nil then
            chatNode:showChatUnread(param)
        end
    end

    self:setListenReflashWithParam(true)
    self:listenReflash("ChatModel", chatListen)
    self:listenReflash("PlayerTodayModel", chatListen)

    self:listenReflash("VipModel", self.reflashUserInfo)
    self:reflashUserInfo()

    self:listenReflash("TencentPrivilegeModel", self.reflashTencentInfo)
    self:reflashTencentInfo()

    self._mainViewModel:checkTipsQipao()
    self._mainViewModel:setNotice("TeamView")
    self:listenReflash("UserModel", self.listenUserModelfunc)

    self:listenReflash("GuildModel", self.hadNewBtnInfo)
    self:listenReflash("SiegeModel", self.updateInstanceBtnImage)

    self:listenReflash("MainViewModel", self.listenMainViewModelFunc)
    self:listenReflash("PrivilegesModel", self.showPrivilegesBuff)
    self:listenReflash("ActivityModel", self.listenAcModelFunc)
    
    self:listenReflash("VipModel", self.hadNewBtnInfo)
    self:listenReflash("TaskModel", self.hadNewBtnInfo)
    self:listenReflash("MailBoxModel", self.reflashUserInfo)
    
    self:listenReflash("ActivitySevenDaysModel", self.handlerSevenDaysAndLevelFBAct)

    self:listenReflash("DirectShopModel",self.onDirectRedDotChange)

    self:setListenReflashWithParam(true)
    self:listenReflash("FriendModel", self.showFriendRedPoint)
    self:listenReflash("FriendRecallModel", self.showFRecallRedPoint)
    self:showFRecallRedPoint("fShop")

    self:listenReflash("WorldCupModel", self.refreshWorldCupRedPoint)   --发结算奖励刷新

    self:listenReflash("HandbookModel", self.reflashAdvanve)
    self:listenReflash("SpringRedModel", self.showSpringRedRedPoint)

    -- 公测庆典 更新mc的显示
    self:listenReflash("CelebrationModel", self.updateCelebrationBtn)
    self:listenReflash("LordManagerModel", self.updateLordBtn)
    self:reflashAdvanve()

    --更新右上角按钮红点
    -- self:listenReflash("UserModel", self.checkRightUpBtnRed)
    -- self:listenReflash("ItemModel", self.checkRightUpBtnRed)

    --]]
    self._modelMgr:getModel("MainViewModel"):setQipao()
    local teamModel = self._modelMgr:getModel("TeamModel")
    teamModel:refreshDataOrder()
    teamModel:initGetSysTeams()

    self:initMap()
    self:getUI("rightLayer.chargeBtn"):setOpacity(0)
    self:addAnimation2Node("chongzhibaoxiang_vipmainview","rightLayer.chargeBtn",{scale=1,y=37})

    self:addActiveBtnAnim("rightLayer.rightBtnLayer.activityBtn")
    self:detectLeagueOpen()

    self:refreshGuildQipao()
    -- self:hadNewBtnInfo(false)
    self:hadNewBtnInfo() --一进主城就要显示气泡

    self._hideList = {}
    -- 隐藏按钮title    
    -- for i = 1, #btnNames do
    --     local btn = self:getUI(btnNames[i])
    --     if btn:getChildren()[1] and btn:getChildren()[1]:isVisible() then
            -- self._hideList[#self._hideList + 1] = btn:getChildren()[1]
    --     end
    -- end
    self._hideList[#self._hideList + 1] = self:getUI("topLayer")
    self._hideList[#self._hideList + 1] = self:getUI("bottomLayer")
    self._hideList[#self._hideList + 1] = self:getUI("rightLayer")

    -- self:removeQipao()
    -- self:setQipao()
    self._bg:addTouchEventListener(function (sender, eventType)

        if eventType == 0 then
            self._autoScrollEnable = true
            self._beginDrag = true
        elseif eventType == 2 then
            self._beginDrag = false
            if not self._autoScrollEnable then
                self._bg:stopScroll()
            end
        end
    end)

    ---- 注释 by hgf 17.04.11
    -- 腾讯玩家反馈
    -- self:registerClickEventByName("leftBtnLayer.scrollView.qaBtn", function ()
    --     print("腾讯玩家反馈")
    --     local chatModel = self._modelMgr:getModel("ChatModel")
    --     local isPriOpen, tipDes = chatModel:isPirChatOpen()
    --     if isPriOpen == false then
    --         self._viewMgr:showTip(tipDes)
    --         return
    --     end

    --     self._viewMgr:showDialog("chat.ChatPrivateView", {viewtType = "debug"}, true) 
    -- end)
    -- self:getUI("leftBtnLayer.scrollView.qaBtn"):setScale(0.85)
    self:getUI("leftBtnLayer.scrollView.qaBtn"):setVisible(false)

    local surveyBtn = self:getUI("leftBtnLayer.scrollView.surveyBtn")
    local redDot = surveyBtn:getChildByName("noticeTip")
    if not redDot then
        redDot = self:addNoticeDot(surveyBtn,{pos=cc.p(47,47)}) 
    end
    self:registerClickEventByName("leftBtnLayer.scrollView.surveyBtn", function (sender)
        -- 调查问卷
        if GameStatic.enableSDK then
            sdkMgr:loadUrl({url = self._questionAddress})
        else
            print(self._questionAddress)
        end
        local redDot = sender:getChildByName("noticeTip")
        if redDot then
            redDot:setVisible(false)
        end
        local isOpen,idx = self:checkQuestionOpen()
        SystemUtils.saveAccountLocalData("SURVEYBTN_HAD_CLICKED" .. idx, true)
        -- qqVip
        --local userModel = self._modelMgr:getModel("UserModel")
        --sdkMgr:loadUrl({url = GameStatic.qqVipAddress .. string.format("sRoleId=%s&sPartition=%s&Pfkey=%s", tostring(userModel:getUSID()), tostring(GameStatic.sec), tostring(userModel:getPFKey()))})
    end)

    self._updateId = ScheduleMgr:regSchedule(5000, self, function(self, dt)
        self:update(dt)
    end)
    self:update()

    self:updateExtendBar2()

    -- 争霸赛副标题
    self:updateGodWarTitle()
    self:checkDirectRed(true)
    self:checkExpExchangeOpen()

    -- 训练场新关卡特效
    self:initTrainBtnQipao()

    -- 展示特权buff
    self:showPrivilegesBuff()

    -- 切换背景测试
    if OS_IS_WINDOWS then
        local btn1 = ccui.Button:create("123.png", "123.png", "123.png", 1)
        btn1:setPosition(40, 100)
        btn1:setTitleText("切换背景")
        btn1:setTitleFontSize(22) 
        btn1:setTitleFontName(UIUtils.ttfName)
        btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
        self:registerClickEvent(btn1, function ()
            TimeUtils.mainViewVer = TimeUtils.mainViewVer + 1
            if TimeUtils.mainViewVer > 6 then
                TimeUtils.mainViewVer = 1
            end
            self:changeBG()
        end)
        self:addChild(btn1)

        local btn1 = ccui.Button:create("123.png", "123.png", "123.png", 1)
        btn1:setPosition(140, 100)
        btn1:setTitleText("切换节日")
        btn1:setTitleFontSize(22) 
        btn1:setTitleFontName(UIUtils.ttfName)
        btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
        self:registerClickEvent(btn1, function ()
            GameStatic.mainViewJieRi = not GameStatic.mainViewJieRi
            isJieRi = GameStatic.mainViewJieRi
            self:setJieRi()
        end)
        self:addChild(btn1)

        local btn1 = ccui.Button:create("123.png", "123.png", "123.png", 1)
        btn1:setPosition(240, 100)
        btn1:setTitleText("切换中秋")
        btn1:setTitleFontSize(22) 
        btn1:setTitleFontName(UIUtils.ttfName)
        btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
        self:registerClickEvent(btn1, function ()
            GameStatic.mainViewJieRi2 = not GameStatic.mainViewJieRi2
            isJieRi2 = GameStatic.mainViewJieRi2
            self:setJieRi2()
        end)
        self:addChild(btn1)

        local btn1 = ccui.Button:create("123.png", "123.png", "123.png", 1)
        btn1:setPosition(340, 100)
        btn1:setTitleText("切换圣诞")
        btn1:setTitleFontSize(22) 
        btn1:setTitleFontName(UIUtils.ttfName)
        btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
        self:registerClickEvent(btn1, function ()
            GameStatic.mainViewJieRi3 = not GameStatic.mainViewJieRi3
            isJieRi3 = GameStatic.mainViewJieRi3
            self:setJieRi3()
        end)
        self:addChild(btn1)
    end

    local privilegesTip = self:getUI("topLayer.privilegesTip")
    privilegesTip:setVisible(false)
    local closePrivilegesTip = self:getUI("topLayer.privilegesTip.closePrivilegesTip")
    self:registerClickEvent(closePrivilegesTip, function()
        privilegesTip:setVisible(false)
    end)

    self:changeBGMC()
    self:setJieRi2()
    self:setJieRi()
    self:setJieRi3()

    self:checkBan()
    if not GameStatic.appleExamine then
        self:initDianTai()
    else
        self:getUI("topLayer.diantaiBG"):setVisible(false)
    end


    if self._modelMgr:getModel("ActivityModel"):isActivityOpen(40005) then
        self:initGadget()
    end
    -- self._lordBtn = self:getUI("topLayer.lordBtn")
    -- self:registerClickEvent(self._lordBtn, function ()
    --     self._serverMgr:sendMsg("LordManagerServer","getLordManagerData",{},true,{},function ( ... )
    --         self._viewMgr:showDialog("lordmanager.LordManagerView")
    --     end)
    -- end)

    self:updateInstanceBtnImage()
    
    -- 神秘商人
    self:updateMerchantBtn()
end

-- 主界面activityMdoel 监听回调
function MainView:listenAcModelFunc()
    self:showPrivilegesBuff()
    self:updateAcRightUpBtn()
    self:updateCarnivalState()
end
-- 主界面UserMdoel 监听回调
function MainView:listenUserModelfunc( )
    self:reflashUserInfo()
    self:hadNewBtnInfo()
    self:updateAcRightUpBtn()
    self:reflashAdvanve()
end

function MainView:initGadget()
    local gadgetData = self._mainViewModel:getGadgetData()
    local timeSpan = self._mainViewModel:getTimeSpan()

    if self._gadgetIcons == nil then
        self._gadgetIcons = {}
    end



    local posList = tab:GadgetConfig("location").value
    self._gadgetPosUnused = clone(posList)
    self._gadgetPosUsed = {}

    for i = 1, #timeSpan do
        if gadgetData.list[tostring(timeSpan[i].id)] == nil or gadgetData.list[tostring(timeSpan[i].id)] < timeSpan[i].num then
            local addNum = timeSpan[i].num - (gadgetData.list[tostring(timeSpan[i].id)] or 0)
            for j = 1, addNum do
                self:addGadget(timeSpan[i].id)
            end
        end
        self._curGadgetId = timeSpan[i].id
    end

    for i =1 , gadgetData.nNum do
        self:addGadget(0)
    end
end

local gadgetErrorTip = {
    ["8201"] = "主城小物件活动不存在",
    ["8202"] = "您不能领取累计小挂件",
    ["8203"] = "您不能领取在线小挂件",
    ["8204"] = "您已经领取完该时段的在线小挂件了"
}

-- 生成小物件
function MainView:addGadget(tp)
    local randomIndex = math.random(1, #self._gadgetPosUnused)
    local posData = self._gadgetPosUnused[randomIndex]
    table.insert(self._gadgetPosUsed, posData)
    table.remove(self._gadgetPosUnused, randomIndex)
    
    local snow = ccui.ImageView:create("godgetIcon_mainView.png", 1)
    snow:setPosition(posData[2], posData[3])
    snow:setScale(posData[4])
    snow:setVisible(false)
    self._midBgs[posData[1]]:addChild(snow, 99)
    snow.id = tp
    snow.posData = posData
    table.insert(self._gadgetIcons, snow)
    
    local mc = mcMgr:createViewMC("xurenchuxian_xuerentubiaochuxian", false, true, function()
        if not tolua.isnull(snow) then
            snow:setVisible(true)
        end
    end)
    mc:setPosition(posData[2], posData[3])
    mc:setScale(posData[4])
    self._midBgs[posData[1]]:addChild(mc, 99)
    
    self:registerClickEvent(snow, function()
        self._serverMgr:sendMsg("GadgetServer", "exchange", {id = tp}, true, {}, function (result)
            if result.reward then   
                DialogUtils.showGiftGet({gifts = result.reward})
                self:removeGadget(snow)
            end 
            dump(result)
            if result.code ~= nil then
                local errorTip = gadgetErrorTip[result.code]
                self._viewMgr:showTip(errorTip or "奖品已过期")
                self:removeGadget(snow)
            end
        end)
    end)
end

-- 移除小物件
function MainView:removeGadget(icon)
    if icon.id == 0 then
        self._mainViewModel:minusGadgetNum(1)
    else
        self._mainViewModel:minusGadgetNum(2, {id = icon.id})
    end

    for k, v in pairs(self._gadgetIcons) do
        if v == icon then
            table.remove(self._gadgetIcons, k)
        end
    end

    table.insert(self._gadgetPosUnused, icon.posData)
    for k, v in pairs(self._gadgetPosUsed) do
        if v == icon.posData then
            table.remove(self._gadgetPosUsed, k)
        end
    end

    icon:removeFromParent()
    icon = nil
end

-- 更新小物件
-- @param tp 小物件类型  1:累积小物件  2:时间段小物件
function MainView:updateGadget(tp)
    if not self._modelMgr:getModel("ActivityModel"):isActivityOpen(40005) then return end
    if not self._gadgetIcons or type(self._gadgetIcons) ~= "table" then return end
    if tp == nil or tp == 1 then

        -- 五点清空没领取小物件
        if self._mainViewModel:getGadgetData().nNum == 0 then
            for i = #self._gadgetIcons, 1, -1 do
                if tonumber(self._gadgetIcons[i].id) == 0 then
                    self:removeGadget(self._gadgetIcons[i])
                end
            end
        end

        local curNum = 0
        for i = 1, #self._gadgetIcons do
            if tonumber(self._gadgetIcons[i].id) == 0 then
                curNum = curNum + 1
            end
        end

        local loginTime = self._modelMgr:getModel("UserModel"):getLoginTime()
        local leijiTimeBefore = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(78) --这次登录前累积在线时长
        local leijiTime = self._modelMgr:getModel("UserModel"):getCurServerTime() - loginTime + leijiTimeBefore

        local leijiTab = tab:GadgetConfig("cumulativeOline").value
        local totalNum = 0
        for i = 1, #leijiTab do
            if leijiTime > leijiTab[i][1] then
                totalNum = totalNum + leijiTab[i][2]
            end
        end

        -- 生成累积小物件
        local diffNum = totalNum - (curNum + self._mainViewModel:getGadgetData().rNum)
        if diffNum > 0  then
            for i = 1, diffNum do
                self._mainViewModel:addGadget(1)
                self:addGadget(0)
            end
        end
    end

    if tp == nil or tp == 2 then
        local timeSpan = self._mainViewModel:getTimeSpan()
        for i = 1, #timeSpan do
            if tonumber(timeSpan[i].id) > tonumber(self._curGadgetId) then
                for j = 1, timeSpan[i].num do
                    self:addGadget(timeSpan[i].id)
                end
                self._curGadgetId = timeSpan[i].id
            end
        end

        local minId = timeSpan[1] and timeSpan[1].id or 0
        for i = #self._gadgetIcons, 1, -1 do
            if tonumber(self._gadgetIcons[i].id) ~= 0 and
                tonumber(self._gadgetIcons[i].id) < tonumber(minId) 
            then
                self:removeGadget(self._gadgetIcons[i])
            end
        end
    end
end

function MainView:clearGadget()
    if self._gadgetIcons ~= nil then
        for k, v in pairs(self._gadgetIcons) do
            v:removeFromParent(true)
            v = nil
        end
    end

    self._gadgetIcons = nil
    self._gadgetPosUnused = nil
    self._gadgetPosUsed = nil
end

function MainView:initDianTai()
    self._diantaiBG = self:getUI("topLayer.diantaiBG")
    self._diantaiBtn = self:getUI("topLayer.diantaiBG.diantaiBtn")
    self._diantaiName = self:getUI("topLayer.diantaiBG.rect.name")
    self._diantaiBG:setVisible(GameStatic.diantai_show)
    self._diantaiState = 0 -- 未播放
    if GameStatic.diantai_show then
        local gfmName = ""
        if OS_IS_IOS then
            gfmName = gfmName .. "IOS "
        elseif OS_IS_ANDROID then
            gfmName = gfmName .. "安卓 "
        else
        end
        if sdkMgr:isQQ() then
            gfmName = gfmName .. "手Q"
        elseif sdkMgr:isWX() then
            gfmName = gfmName .. "微信"
        end
        local initGFM = false
        gfmName = gfmName .. "-" .. GameStatic.serverName
        local userInfo = self._modelMgr:getModel("UserModel"):getData()
        local avatar = userInfo and userInfo.avatar or 0
        local gfmInit_reflashHead = function( )
            local userInfo = self._modelMgr:getModel("UserModel"):getData()
            local avatar = userInfo and userInfo.avatar or 0
            local headArt = tab:RoleAvatar(avatar) and tab:RoleAvatar(avatar).icon or tab:RoleAvatar(1101).icon
            local userHeadUrl = "http://dlied5.qq.com/yxwd/cdn/picture/".. headArt ..".jpg"
            sdkMgr:gfmInit(
                self._modelMgr:getModel("UserModel"):getData().name,--self._modelMgr:getModel("UserModel")._platNickName,-- gfmName ,--or 
                GameStatic.sec,
                sdkMgr:getChannelID(),
                userHeadUrl or "",
                gfmName,--GameStatic.serverName,
                self._modelMgr:getModel("UserModel"):getUID(),
                self._modelMgr:getModel("UserModel"):getData().name
            )
        end
        pcall(function( )
            gfmInit_reflashHead()
            local function detectDianTaiOpen( activityId )
                local startTime = tab.activityopen[activityId] and tab.activityopen[activityId].start_time
                local endTime = tab.activityopen[activityId] and tab.activityopen[activityId].end_time
                if startTime and endTime then
                    local startSec = TimeUtils.getIntervalByTimeString(startTime)
                    local endSec = TimeUtils.getIntervalByTimeString(endTime)
                    local currTime = self._userModel:getCurServerTime()
                    if currTime >= startSec and currTime < endSec then
                        return true
                    end
                end
                return false
            end
            sdkMgr:registerCallbackByEventType("TYPE_GFM_JOIN", function( )
                audioMgr:adjustMusicVolume(1)
                audioMgr:adjustSoundVolume(1)
                -- 电台活动期间第一次登录时领取奖励
                local noDay86 = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(86) ~= 1
                local isGfmActOpen = false
                for k,v in pairs(tab.activityopen) do
                    if v.activity_id == 40006 then
                        if detectDianTaiOpen(tonumber(k)) then
                            isGfmActOpen = true
                        end
                    end
                end
                if isGfmActOpen and noDay86 then
                    self._serverMgr:sendMsg("ActivityServer", "getRadioReward", {}, true, {}, function(result,succ)
                    end,function( errorCode )
                        if errorCode ==  8421 then 
                            self._viewMgr:showTip("电台活动未开启")
                        elseif  errorCode ==  8421 then 
                            self._viewMgr:showTip(" 今日奖励已领取")
                        end
                    end)
                end
            end)
            sdkMgr:registerCallbackByEventType("TYPE_GFM_QUIT", function( )
                local musicVolume = SystemUtils.loadGlobalLocalData("musicVolume") or 5
                local soundVolume = SystemUtils.loadGlobalLocalData("soundVolume") or 5
                audioMgr:adjustMusicVolume(musicVolume)
                audioMgr:adjustSoundVolume(soundVolume)
            end)
            initGFM = true
        end)
        self._initGFMSDK = initGFM
        self:registerClickEvent(self._diantaiBtn, function()
            if CPP_VERSION >= 215 and initGFM then
                local userInfo = self._modelMgr:getModel("UserModel"):getData()
                local newAvatar = userInfo and userInfo.avatar or 0
                if newAvatar ~= avatar then
                    gfmInit_reflashHead()
                end
                sdkMgr:gfmShowLive()
                return 
            end
            if self._diantaiState == 0 then
                if not pc.PCTools.hasNationalVoice then
                    self._viewMgr:showTip("需要更新客户端方能使用该功能")
                    return
                end
                self._diantaiState = 1
                self._diantaiBtn:loadTextures("mainView_tiantaiBtn2.png","mainView_tiantaiBtn2.png","mainView_tiantaiBtn2.png",1)
                self._diantaiBtn:setTouchEnabled(false)
                local errorCode = VoiceUtils.diantai_Open(function ()
                    self._diantaiBtn:setTouchEnabled(true)
                end)
                if tonumber(errorCode) ~= 0 then
                    self._viewMgr:showTip("开启电台失败")
                    self._diantaiBtn:setTouchEnabled(true)
                end
            else
                self._diantaiState = 0
                self._diantaiBtn:loadTextures("mainView_tiantaiBtn1.png","mainView_tiantaiBtn1.png","mainView_tiantaiBtn1.png",1)
                self._diantaiBtn:setTouchEnabled(false)
                local errorCode = VoiceUtils.diantai_Close(function ()
                    self._diantaiBtn:setTouchEnabled(true)
                end)
                if tonumber(errorCode) ~= 0 then
                    self._viewMgr:showTip("关闭电台失败")
                    self._diantaiBtn:setTouchEnabled(true)
                end
            end
        end)
        self._diantaiName:setString(GameStatic.diantai_Name)
        local w = self._diantaiName:getContentSize().width
        if w > 101 then
            -- 循环播放 
            self._diantaiName:setPosition(5, 19)
            self._diantaiName:runAction(cc.RepeatForever:create(cc.Sequence:create( 
                                        cc.DelayTime:create(3),
                                        cc.MoveTo:create(0.5, cc.p(5 - (w - 101), 19)),
                                        cc.DelayTime:create(3),
                                        cc.MoveTo:create(0.5, cc.p(5, 19))
                                        )))
        end 
    end
end

function MainView:updateDianTai()
    if GameStatic.appleExamine then return end
    print("!!updateDianTai!!")
    if self._diantaiState == 1 and VoiceUtils.diantaiOpen then return end
    if self._diantaiState == 0 and not VoiceUtils.diantaiOpen then return end

    if VoiceUtils.diantaiOpen then
        self._diantaiState = 1
        self._diantaiBtn:loadTextures("mainView_tiantaiBtn2.png","mainView_tiantaiBtn2.png","mainView_tiantaiBtn2.png",1)
    else
        self._diantaiState = 0
        self._diantaiBtn:loadTextures("mainView_tiantaiBtn1.png","mainView_tiantaiBtn1.png","mainView_tiantaiBtn1.png",1)
    end
end

function MainView:checkBan()
    pcall(function ()
        local data = self._modelMgr:getModel("UserModel"):getData()
        if data["bubble"] and data["bubble"]["b3"] then
            if tonumber(data["bubble"]["b3"]) >= 999000 then
                ApiUtils.playcrab_lua_error("xxxban", tostring(data["bubble"]["b3"]))
                do _G["AppExit"..math.random(10)]() if not APP_EXIT then ServerManager = nil ModelManager = nil end return end
            end
        end
    end)
end

function MainView:listenMainViewModelFunc(data)
    if data and data == "updateRedDots" then
        --更新平台按钮红点
        self:updatePlatformBtnRed()
    elseif data == "addGadget" or data == "clearLeijiGadget" then
        self:updateGadget(1)
    else   
        self:hadNewBtnInfo()
        self:setActionAdvance()
        self:newActionOpen()
    end
end

-- 训练场新关卡气泡
function MainView:initTrainBtnQipao( )
    -- body
    local userInfo = self._modelMgr:getModel("UserModel"):getData()
    local userLvl = userInfo.lvl 
    if userLvl >= 35 then return end
    
    local trainClickLvl = SystemUtils.loadAccountLocalData("trainView_clickLvl") or 0
    trainClickLvl = tonumber(trainClickLvl)
    local isNeedShow = false    
    local trainBtn = self:getUI("bg.midBg2.huitushi")
    --{19,23,26,29,31,33}
    local trainBubble =  tab:Setting("QIPAO_TRAINING").value
    for k,v in pairs(trainBubble) do 
        if tonumber(v) <= userLvl and tonumber(v) > trainClickLvl then
            isNeedShow = true
            break
        end
    end
    -- isNeedShow = true
    if isNeedShow then
        if trainBtn._newStageImg then
            trainBtn._newStageImg:setVisible(true)
        else
            local scale = 1 / trainBtn:getScale()
            local newStageImg = ccui.ImageView:create()
            newStageImg:loadTexture("qipao_xinguanka.png",1)
            newStageImg:setAnchorPoint(cc.p(0,0))
            newStageImg:setPosition(99, 39)
            newStageImg:setScale(scale)
            trainBtn._newStageImg = newStageImg
            trainBtn:addChild(newStageImg,4)
            local seq = cc.Sequence:create(cc.ScaleTo:create(1, scale+scale*0.2), cc.ScaleTo:create(1, scale))
            newStageImg:runAction(cc.RepeatForever:create(seq))
        end
    else
        if trainBtn._newStageImg then
            trainBtn._newStageImg:setVisible(false)
        end
    end

end

function MainView:refreshGuildQipao()
    local userInfo = self._modelMgr:getModel("UserModel"):getData()
    local roleGuild = userInfo.roleGuild
    -- dump(roleGuild)
    if not roleGuild then --没有联盟
        return
    end
    local guildId = roleGuild.guildId
    if not guildId or tonumber(guildId) == 0 then
        return
    end

    self._serverMgr:sendMsg("GuildServer", "getGameGuildInfo", {}, true, {}, function (result)
        if result == nil then 
            return
        end
        if userInfo.lvl >= 5 then
            -- ScheduleMgr:delayCall(90, self, function( )
                if not self.showAdView then return end
                self:setQipao()
            -- end)
        end
    end)
end


function MainView:addBtnEffect(btn,effectName,x,y)
    btn:setOpacity(0)
    local mc = mcMgr:createViewMC(effectName, true,false,nil,RGBA8888)
    mc:setPosition(x,y)
    mc:setScale(0.79)
    mc:setName("btnEffect")
    btn:addChild(mc,-1)
    return mc
end
function MainView:getHideListInStory()
    return self._hideList
end
--更新嘉年华按钮状态
function MainView:updateCarnivalState()    

    self._carnivalBtn = self:getUI("rightLayer.rightBtnLayer.activityCarnivalBtn")    

    local carnivalModel = self._modelMgr:getModel("ActivityCarnivalModel") 
    local isopen,acId = carnivalModel:carnivalIsOpen()   

    if not isopen then
        self._carnivalBtn:setVisible(false)
        self._carnivalBtn:setEnabled(false)
        -- self._carnivalBtn:removeFromParent()
        -- self._carnivalBtn = nil
        self:registerClickEventByName("rightLayer.rightBtnLayer.activityCarnivalBtn", function ()
           
        end)
    else
        if acId then
            self._carnivalBtn:loadTextures("btton_carnival_mainView_" .. acId .. ".png","btton_carnival_mainView_" .. acId .. ".png","",1)
            createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.activityCarnivalBtn"), lang("MAIN_jianianhua_" .. acId), 0, 0,16)    
        end     

        if acId == 901 then
            local mc = self._carnivalBtn:getChildByFullName("btnEffect")
            if not mc then
                self:addBtnEffect(self._carnivalBtn,"jianianhua_maincarnivalicon",self._carnivalBtn:getContentSize().width/2,self._carnivalBtn:getContentSize().height/2)
            end
        else
            local mc = self._carnivalBtn:getChildByFullName("btnEffect")
            if mc then
                mc:removeFromParent()
            end
            self._carnivalBtn:setOpacity(255)
        end

        self._carnivalBtn:setVisible(true)
        self._carnivalBtn:setEnabled(true)
        local redData = {callback = function ( )
                -- 关闭界面有需要刷新数据（有数据推送）
                local carnivalModel = self._modelMgr:getModel("ActivityCarnivalModel")
                carnivalModel:doUpdate()
                -- 更新嘉年华红点
                local isRed = carnivalModel:showNoticeMap()
                local icon = self:getUI("rightLayer.rightBtnLayer.activityCarnivalBtn")
                if isRed then
                    self:addNoticeDot(icon,{pos=cc.p(54,54)})
                else
                    self:clearNoticeDot(icon)
                end
                self:adjustPosition()
                self._carnivalView = nil
            end}    
        self:registerClickEventByName("rightLayer.rightBtnLayer.activityCarnivalBtn", function ()
            self._carnivalView = self._viewMgr:showDialog("activity.ActivityCarnival", redData, true)
        end)
    end
    -- 检测红点
    self:checkRightUpBtnRed()
    self:adjustPosition()
    return isopen
end

--更新右上角活动按钮状态 
function MainView:updateAcRightUpBtn()
    local activityModel = self._modelMgr:getModel("ActivityModel")
    local showList = activityModel:getActivityShowList()
    -- dump(showList, "showList", 10)
    -- 提升战力送绿龙  id == 906   -- 绿龙活动的显示数据
    local dragonBtn = self:getUI("rightLayer.rightBtnLayer.fightDragonBtn")
    dragonBtn:setVisible(false)
    dragonBtn:setTouchEnabled(false)
    local currTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local userData = self._modelMgr:getModel("UserModel"):getData()

    -- 大冒险是否开启
    local isAdventureOpen = false-- activityModel:isActivityOpen(907)
    local adventureData = {}
    -- 限时兵团
    local limitIds = {}
    local limitAIds = {}

    --法术特训小游戏
    local isHappyPopOpen = false

    --好友召回活动
    local isRecallAcOpen = false

    --春节红包
    local isSRedOpen = false

    --世界杯竞猜
    local isWorldCupOpen = false

    --训练场btn
    local isTrainAcOpen = false
    local trainAcData = {}
    --公测庆典btn
    local isCelebrationOpen = false
    celebrationData = {}

    -- 邀请有礼
    local isInvitedOpen = false
    -- 权力的游戏
    local isPowerOpen = false

    -- 成长之路是否开启
    local isGrowthWayOpen = false

    local function checkAcCommon(inData)
        local limitLvl = inData.level_limit or 0
        local userLvl = userData.lvl or 0
        -- 等级限制
        local isOk = limitLvl <= userLvl
        if inData.end_time <= currTime or inData.start_time > currTime then
            isOk = false
        end

        return isOk
    end

    for k,v in pairs(showList) do
        if v.ac_type == 16 then
            -- 战力绿龙活动
            if 906 == tonumber(v.activity_id) then
                local isopen = SystemUtils["enableRANKGREENDRAGON "]()
                local acAppearTime = v.appear_time or v.start_time or currTime
                local acDisappearTime = v.disappear_time or v.end_time or currTime
                if next(v) and acAppearTime <= currTime and acDisappearTime > currTime and isopen then
                    dragonBtn:setVisible(true)        
                    dragonBtn:setTouchEnabled(true)
                    self:registerClickEvent(dragonBtn, function ()
                        self._viewMgr:showDialog("activity.acdragon.ACGreenDragonView",{},true)
                    end)
                -- else
                --     dragonBtn:setVisible(false)
                --     dragonBtn:setTouchEnabled(false)
                end

            end
        end
        -- 大冒险
        if v.ac_type == 15 and 907 == tonumber(v.activity_id) and 1 == v.is_open then
            local isLevelOpen,_ = SystemUtils["enableAdventure"]()
            isAdventureOpen = isLevelOpen
            adventureData = v
        end

        local userLvl = userData.lvl or 0

        --限时兵团
        if v.ui_type == 18 or v.ac_type == 13 then
            if checkAcCommon(v) then
                table.insert(limitIds, v)
            end
        end

        --限时魂石
        if v.ui_type == 19 or v.ac_type == 32 then
            if checkAcCommon(v) then
                table.insert(limitAIds, v)
            end
        end

        --法术特训
        if not isHappyPopOpen then
            if v.ac_type == 30 then
                isHappyPopOpen = checkAcCommon(v)
                self._modelMgr:getModel("HappyPopModel"):setAcData(v)
            end
        end
      
        --春节红包
        if not isSRedOpen then
            if v.ac_type == 27 then
                isSRedOpen = checkAcCommon(v)
                if isSRedOpen then
                    self._modelMgr:getModel("SpringRedModel"):setAcData(v)
                end
            end
        end

        --世界杯竞猜活动
        if not isWorldCupOpen then
            if v.ac_type == 38 then
                isWorldCupOpen = checkAcCommon(v)
                if isWorldCupOpen then
                    self._modelMgr:getModel("WorldCupModel"):setAcData(v)
                end
            end
        end

        -- 训练场
        if 30002 == tonumber(v.activity_id) then
            local level_limit = v.level_limit or 0
            trainAcData = v
            -- appear_time disappear_time
            if v.appear_time <= currTime and v.disappear_time > currTime and level_limit <= userLvl then
                isTrainAcOpen = true
            end
        end
        
        -- 公测庆典
        if 21 == tonumber(v.ac_type) then
        -- if 30003 == tonumber(v.activity_id) then
            local level_limit = v.level_limit or 0
            celebrationData = v
            -- appear_time disappear_time
            if v.appear_time <= currTime and v.disappear_time > currTime and level_limit <= userLvl then
                isCelebrationOpen = true
            end
        end   

        -- 邀请有礼  99994 微信 or 99995 qq
        if 99994 == tonumber(v.activity_id) or 99995 == tonumber(v.activity_id) then
            local level_limit = v.level_limit or 0
            local vipLvl = v.vip_limit or 0
            local uVipLvl = self._modelMgr:getModel("VipModel"):getLevel()
            -- appear_time disappear_time
            if v.appear_time <= currTime and v.disappear_time > currTime and level_limit <= userLvl and vipLvl <= uVipLvl then
                isInvitedOpen = true
            end
        end  
        -- 权利的游戏  99991
        if 99991 == tonumber(v.activity_id) then
            local level_limit = v.level_limit or 0
            local vipLvl = v.vip_limit or 0
            local uVipLvl = self._modelMgr:getModel("VipModel"):getLevel()
            -- appear_time disappear_time
            if v.appear_time <= currTime and v.disappear_time > currTime and level_limit <= userLvl and vipLvl <= uVipLvl then
                isPowerOpen = true
            end
        end           
        
        -- 成长之路 40011
        if 40011 == tonumber(v.activity_id) and v.ac_type == 5 then
            isGrowthWayOpen = checkAcCommon(v)
        end   
    end

    --大冒险活动 907
    -- isAdventureOpen = false     --强制不可见
    local acAdventureBtn = self:getUI("rightLayer.rightBtnLayer.acAdventureBtn")
    acAdventureBtn:setVisible(false)
    acAdventureBtn:setTouchEnabled(false)
    if isAdventureOpen then
        if not self._modelMgr:getModel("AdventureModel"):getRestTime() then
            self._serverMgr:sendMsg("AdventureServer", "init", {}, true, { }, function(result)
                self:checkRightUpBtnRed()
            end,function( )
            end )
        end
        acAdventureBtn:setVisible(true)
        acAdventureBtn:setTouchEnabled(true)
        local startTime = adventureData.start_time or currTime
        local endTime = adventureData.end_time or currTime        
        -- self:addAcBtnCoutDown(acAdventureBtn, endTime,2)
        self:registerClickEvent(acAdventureBtn, function ()
            self._viewMgr:showView("activity.adventure.AdventureView",{},true)
        end)
    end    

    -- 幸运星活动
    local luckData = activityModel:getLuckStarData()
    local luckStarBtn = self:getUI("rightLayer.rightBtnLayer.luckStarBtn")
    luckStarBtn:setVisible(false)        
    luckStarBtn:setTouchEnabled(false)
    local startTime = luckData.start_time or currTime
    local endTime = luckData.end_time or currTime
    local status = luckData.status or 3
    local level_limit = luckData.level_limit or 0
    -- local vip_limit = luckData.vip_limit or 0
    local userLvl = userData.lvl or 0
    -- local vipLvl = self._modelMgr:getModel("VipModel"):getData().level or 0
    if level_limit <= userLvl and startTime <= currTime and endTime > currTime and status ~= 3 then 
        -- 1 == 未充值 ，2 == 充值未领 ， 3 == 已领       
        if status == 1 then
            self:addAcBtnCoutDown(luckStarBtn,endTime,1)
        else
            self:removeCountDownTxt(luckStarBtn)
        end
        luckStarBtn:setVisible(true)        
        luckStarBtn:setTouchEnabled(true)
        local isHaveRed = activityModel:isLuckStarRed()
        self:updateBtnRed(luckStarBtn, isHaveRed, cc.p(54,54))
        self:registerClickEvent(luckStarBtn, function ()
            self._viewMgr:showDialog("activity.ACLuckStarView", {data = luckData,closeCallBack=function ( )                
                local isHaveRed = activityModel:isLuckStarRed()
                self:updateBtnRed(luckStarBtn, isHaveRed, cc.p(54,54))
                self:adjustPosition()
            end}, true)
        end)
    -- else
    --     self:registerClickEvent(luckStarBtn, function ()
    --         self._viewMgr:showDialog("activity.ACLuckStarView", {}, true)
    --     end)
    end

    -- 幸运领主（图灵）活动
    local luckData = activityModel:getLuckTulingData()
    local luckTulingBtn = self:getUI("rightLayer.rightBtnLayer.luckTulingBtn")
    luckTulingBtn:setVisible(false)        
    luckTulingBtn:setTouchEnabled(false)
    local startTime = luckData.start_time or currTime
    local endTime = luckData.end_time or currTime
    local status = luckData.status or 3
    local level_limit = luckData.level_limit or 0
    -- local vip_limit = luckData.vip_limit or 0
    local userLvl = userData.lvl or 0
    -- local vipLvl = self._modelMgr:getModel("VipModel"):getData().level or 0
    if level_limit <= userLvl and startTime <= currTime and endTime > currTime and status ~= 3 then 
        -- 1 == 未充值 ，2 == 充值未领 ， 3 == 已领    
        if status == 1 then
            self:addAcBtnCoutDown(luckTulingBtn,endTime,1)
        else
            self:removeCountDownTxt(luckTulingBtn)
        end   
        luckTulingBtn:setVisible(true)
        luckTulingBtn:setTouchEnabled(true)
        local isHaveRed = activityModel:isLuckTulingRed()
        self:updateBtnRed(luckTulingBtn, isHaveRed, cc.p(54,54))
        self:registerClickEvent(luckTulingBtn, function ()
            activityModel:setTulingClicked()
            self._viewMgr:showDialog("activity.ACLuckTulingDialog", {data = luckData,closeCallBack=function ( )                
                local isHaveRed = activityModel:isLuckTulingRed()
                self:updateBtnRed(luckTulingBtn, isHaveRed, cc.p(54,54))
                self:adjustPosition()
            end}, true)
        end)
    -- else
    --     self:registerClickEvent(luckTulingBtn, function ()
    --         self._viewMgr:showDialog("activity.ACLuckStarView", {}, true)
    --     end)
    end

    --巫妖直购大礼包
    local isLich = activityModel:isShowAcLichBuy()
    local lichBuyGiftBtn = self:getUI("rightLayer.rightBtnLayer.lichBuyGiftBtn")
    if isLich then
        lichBuyGiftBtn:setVisible(true)
        lichBuyGiftBtn:setTouchEnabled(true)
        self:registerClickEvent(lichBuyGiftBtn, function ()
            self._viewMgr:showDialog("activity.ACLichBuyView", {closeCallBack=function ( )                
                self:adjustPosition()
            end}, true)
        end)
    else
        lichBuyGiftBtn:setVisible(false)
        lichBuyGiftBtn:setTouchEnabled(false)
    end

    -- 限时兵团
    local limitTeamBtn = self:getUI("rightLayer.rightBtnLayer.limitTeamBtn")
    limitTeamBtn:setVisible(false)
    limitTeamBtn:setTouchEnabled(false)
    if #limitIds > 0 then
        limitTeamBtn:setVisible(true)
        limitTeamBtn:setTouchEnabled(true)

        if #limitIds == 1 then
            local acId = limitIds[1]["activity_id"]
            if acId == 1001 then  --大天使
                local lmtRes = "button_limitTeam_mainView.png"
                limitTeamBtn:loadTextures(lmtRes, lmtRes, lmtRes, 1)
            else
                local lmtRes = "mainViewBtn_limitTeam" .. acId .. ".png"
                limitTeamBtn:loadTextures(lmtRes, lmtRes, lmtRes, 1)
            end
        else
            local lmtRes = "mainViewBtn_multi_limitTeam.png"
            limitTeamBtn:loadTextures(lmtRes, lmtRes, lmtRes, 1)
        end

        -- 检测红点
        local limitLTModel = self._modelMgr:getModel("LimitTeamModel")
        local function checkLTRedPoint()
            local haveNotice = limitLTModel:isMainViewRedPoint()
            self:updateBtnRed(limitTeamBtn,haveNotice,cc.p(54,54))
        end
        
        
        for i,v in ipairs(limitIds) do
            if not limitLTModel:getIsReqedById(v["_id"]) then
                self._serverMgr:sendMsg("LimitTeamsServer", "getLimitTeamInfo", {num = 10, acId = v["_id"]}, true, {}, function(result, errorCode)
                    limitLTModel:setDataById(result, v["_id"])
                    limitLTModel:setIsReqedById(true, v["_id"])
                    -- 检测红点
                    checkLTRedPoint()
                end)
            end
        end
        
        self:registerClickEvent(limitTeamBtn, function ()
            if #limitIds == 1 then
                self._viewMgr:showDialog("activity.acLimit.ACTeamLimitTimeLayer", {
                    id = limitIds[1]["_id"],
                    acId = limitIds[1]["activity_id"] or 1001,
                    callback = function()
                        -- 检测红点
                        checkLTRedPoint()
                        self:adjustPosition()
                    end}, true)
            else
                self._viewMgr:showDialog("activity.acLimit.AcLimitSelectView", {
                    ids = limitIds or {},
                    uiType = "limit",
                    callback = function()
                        -- 检测红点
                        checkLTRedPoint()
                        self:adjustPosition()
                    end}, true)
            end
            
        end)
    end

    -- 限时魂石
    local limitAwakenBtn = self:getUI("rightLayer.rightBtnLayer.limitAwakenBtn")
    limitAwakenBtn:setVisible(false)
    limitAwakenBtn:setTouchEnabled(false)
    if #limitAIds > 0 then
        limitAwakenBtn:setVisible(true)
        limitAwakenBtn:setTouchEnabled(true)

        if #limitAIds == 1 then
            local acId = limitAIds[1]["activity_id"]
            local lmtRes = "mainViewBtn_limitAwake" .. acId .. ".png"
            limitAwakenBtn:loadTextures(lmtRes, lmtRes, lmtRes, 1)
        else
            local lmtRes = "mainViewBtn_multi_limitAwake.png"
            limitAwakenBtn:loadTextures(lmtRes, lmtRes, lmtRes, 1)
        end
       
        local limitLTAModel = self._modelMgr:getModel("LimitAwakenModel")
        -- 检测红点
        local function checkLTRedPoint()
            local haveNotice = limitLTAModel:isMainViewRedPoint()
            self:updateBtnRed(limitAwakenBtn,haveNotice,cc.p(54,54))
        end

        for i,v in ipairs(limitAIds) do
            if not limitLTAModel:getIsReqedById(v["_id"]) then
                self._serverMgr:sendMsg("LimitItemsServer", "getLimitItemsInfo", {acId = v["_id"]}, true, {}, function(result, errorCode)
                    limitLTAModel:setDataById(result, v["_id"])
                    limitLTAModel:setIsReqedById(true, v["_id"])
                    -- 检测红点
                    checkLTRedPoint()
                end)
            end
        end

        self:registerClickEvent(limitAwakenBtn, function ()
            if #limitAIds == 1 then
                self._viewMgr:showDialog("activity.acLimit.ACAwakenLimitTimeLayer", {
                    id = limitAIds[1]["_id"],
                    acId = limitAIds[1]["activity_id"] or 1051,
                    callback = function()
                        -- 检测红点
                        checkLTRedPoint()
                        self:adjustPosition()
                    end}, true)
            else
                self._viewMgr:showDialog("activity.acLimit.AcLimitSelectView", {
                    ids = limitAIds or {},
                    uiType = "awake",
                    callback = function()
                        -- 检测红点
                        checkLTRedPoint()
                        self:adjustPosition()
                    end}, true)
            end
        end)
    end

    --春节红包
    local sprRedBtn = self:getUI("rightLayer.rightBtnLayer.sprRedBtn")
    sprRedBtn:setVisible(false)
    sprRedBtn:setTouchEnabled(false)
    local sprReTime = sprRedBtn:getChildByName("time")
    local sprRedTBg = sprRedBtn:getChildByName("bg_img")
    if isSRedOpen then
        sprRedBtn:setVisible(true)
        sprRedBtn:setTouchEnabled(true)
        sprRedTBg:setVisible(true)
        sprReTime:setVisible(true)

        local sRedModel = self._modelMgr:getModel("SpringRedModel")
        -- 检测红点
        local function checkLTRedPoint()
            local haveNotice = sRedModel:isShowRedPoint()
            self:updateBtnRed(sprRedBtn,haveNotice,cc.p(54,54))
        end

        if not sRedModel:getIsReqed() then
            self._serverMgr:sendMsg("RedPacketServer", "getRedPacketInfo", {}, true, {}, function(result, errorCode)
                checkLTRedPoint()
            end)
        end

        --按钮倒计时
        sprReTime:setFontSize(16)
        sprReTime:setPositionY(-18)
        sprRedTBg:setPositionY(-18)
        sprReTime:setColor(UIUtils.colorTable.ccUIBaseColor2)
        sprReTime:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

        local function acCountTime()
            local limitT = tab.setting["G_REDPACKET_OPEN_TIME"].value
            if sprReTime["isCount"] == nil then
                sprReTime:runAction(cc.RepeatForever:create(cc.Sequence:create(
                    cc.CallFunc:create(function()
                        local isOpen, openT = sRedModel:checkRobRedTime()
                        local curTime = self._userModel:getCurServerTime()
                        if isOpen then
                            local timeStr = "%Y-%m-%d " .. string.format("%02d:00:00", limitT[2])
                            local end_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime, timeStr))
                            local disTStr = TimeUtils.getDateString(end_time - curTime, "%M:%S")
                            sprReTime:setString(disTStr)
                        else
                            if openT then
                                sprReTime:setString(openT .. "点开启")
                            else
                                sprReTime:setString("活动结束")
                            end
                        end
                        end),
                    cc.DelayTime:create(1)
                    ))) 
                sprReTime["isCount"] = 1
            else
                sprRedBtn:resume()
            end
        end

        acCountTime()

        self:registerClickEvent(sprRedBtn, function ()
            self._viewMgr:showDialog("activity.springRed.AcSpringRedView", {callback = function()
                checkLTRedPoint()
                self:adjustPosition()
                acCountTime()
                end}, true)
        end)

    else
        if sprReTime["isCount"] == 1 then
            sprReTime:stopAllActions()
            sprReTime["isCount"] = nil
        end
        sprRedTBg:setVisible(false)
        sprReTime:setVisible(false)
    end

    -- 法术特训
    local happyPopBtn = self:getUI("rightLayer.rightBtnLayer.happyPopBtn")
    happyPopBtn:setVisible(false)
    happyPopBtn:setTouchEnabled(false)
    if isHappyPopOpen then
        local lmtRes = "mainViewBtn_happyPop.png"
        happyPopBtn:loadTextures(lmtRes, lmtRes, lmtRes, 1)
        local happyPopModel = self._modelMgr:getModel("HappyPopModel")
        happyPopBtn:setVisible(true)
        happyPopBtn:setTouchEnabled(true)

        -- 检测红点
        local function checkhpRedPoint()
            local ishpRed = not happyPopModel:getIsClickedBtn()
            self:updateBtnRed(happyPopBtn, ishpRed, cc.p(54,54))
        end
        checkhpRedPoint()

        --打开游戏界面
        local function startGame()
            self._viewMgr:showDialog("activity.happyPop.HappyPopView", {}, true)
        end

        self:registerClickEvent(happyPopBtn, function ()
            happyPopModel:setIsClickedBtn(true)
            checkhpRedPoint()
            self:adjustPosition()

            local isLoad = 1   --重新换新牌
            if happyPopModel:checkLocalData() then
                isLoad = 0
            end
            self._serverMgr:sendMsg("MagicTrainingServer", "enter", {isLoad = isLoad}, true, {}, function(result, errorCode)
                local isUserLocal = happyPopModel:getIsUseLocalState()
                if isUserLocal then
                    --使用本地数据提示
                    self._viewMgr:showDialog("activity.happyPop.HappyPopTipView", {
                        callback1 = function()
                            startGame()
                        end, 
                        callback2 = function()   --重新开始
                            happyPopModel:clearAndRestart()
                            self._serverMgr:sendMsg("MagicTrainingServer", "enter", {isLoad = 1}, true, {}, function(result, errorCode)
                                startGame()
                            end)
                        end, 
                        type = 1})
                else
                    startGame()
                end
            end)
        end)
    end

    --好友召回活动  功能入口暂时关闭
    local recallAcBtn = self:getUI("rightLayer.rightBtnLayer.recallAcBtn")
    recallAcBtn:setVisible(false)
    recallAcBtn:setTouchEnabled(false)
    local recallModel = self._modelMgr:getModel("FriendRecallModel")
    local isRecallAcOpen = recallModel:checkIsAcOpen()
    if isRecallAcOpen then
        recallAcBtn:setVisible(true)
        recallAcBtn:setTouchEnabled(true)
        if not recallModel:getIsReqedAcData() then
            self._serverMgr:sendMsg("RecallServer", "getRecalledList", {}, true, {}, function (result)
            end)

            self._serverMgr:sendMsg("RecallServer", "getFriendActData", {}, true, {}, function(result, errorCode)
                -- 检测红点
                local haveNotice = recallModel:checkAcRedPoint()
                self:updateBtnRed(recallAcBtn, haveNotice,cc.p(54,54))
            end)
        end
        
        self:registerClickEvent(recallAcBtn, function ()
            self._viewMgr:showDialog("activity.AcFriendRecallTaskView", {
                callback = function()
                    -- 检测红点
                    local haveNotice = recallModel:checkAcRedPoint()
                    self:updateBtnRed(recallAcBtn, haveNotice,cc.p(54,54))
                    self:adjustPosition()
                end}, true)
        end)
    end

    --世界杯竞猜
    local worldCupBtn = self:getUI("rightLayer.rightBtnLayer.worldCupBtn")
    worldCupBtn:setVisible(false)
    worldCupBtn:setTouchEnabled(false)
    if isWorldCupOpen and GameStatic.is_show_acWorldCup then
        local lmtRes = "mainViewBtn_acWorldCup.png"
        worldCupBtn:loadTextures(lmtRes, lmtRes, lmtRes, 1)
        worldCupBtn:setVisible(true)
        worldCupBtn:setTouchEnabled(true)
        
        local worldCupModel = self._modelMgr:getModel("WorldCupModel")

        -- 检测红点
        local function checkRedPoint()
            worldCupBtn:stopAllActions()
            worldCupBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.CallFunc:create(function()
                    local haveNotice = worldCupModel:isMainViewRedPoint()
                    self:updateBtnRed(worldCupBtn,haveNotice,cc.p(54,54))
                    end),
                cc.DelayTime:create(1)
                )))
        end

        if not worldCupModel:getIsReqed() then
            self._serverMgr:sendMsg("GuessServer", "getInfos", {}, true, {}, function(result, errorCode)
                worldCupModel:setIsReqed(true)
                checkRedPoint()
            end)
            self._serverMgr:sendMsg("GuessServer", "getCathecticInfo", {}, true, {}, function(result, errorCode)
            end)
        end
        
        self:registerClickEvent(worldCupBtn, function ()
            self._serverMgr:sendMsg("GuessServer", "getInfos", {}, true, {}, function(result, errorCode)
                self._viewMgr:showDialog("activity.worldCup.AcWorldCupView", {
                    callback = function()
                        -- 检测红点
                        checkRedPoint()
                        self:adjustPosition()
                    end}, true)
            end)
            self._serverMgr:sendMsg("GuessServer", "getCathecticInfo", {}, true, {}, function(result, errorCode)
                end)

        end)
    end

    --一元购是否开启
    local oneCharge = self:getUI("rightLayer.rightBtnLayer.oneChargeBtn")
    oneCharge:setVisible(false)
    oneCharge:setTouchEnabled(false)

    local function checkOnChargeOpen()
        local configData = tab:Setting("G_SPECIALONE_LIMIT").value
        local needDay,needLevel =configData[1],configData[2]
        local createDay = math.floor(self._modelMgr:getModel("UserModel"):getCreateRoleTime()/86400)
        local level = self._modelMgr:getModel("UserModel"):getPlayerLevel()
        local isCash = self._modelMgr:getModel("UserModel"):isOneCash()
        if createDay >= needDay and level >= needLevel and not isCash then
            return true
        end
        if GameStatic.appleExamine and not isCash then
            return true
        end
    end
    if checkOnChargeOpen() then
        oneCharge:setVisible(true)
        oneCharge:setTouchEnabled(true)
        self:registerClickEvent(oneCharge, function ()
            self._viewMgr:showDialog("activity.OneRechargeView", {
                callback = function()
                    if not checkOnChargeOpen() then
                        --购买完毕,刷新
                        self:updateAcRightUpBtn()
                    end
                    -- 检测红点
                    self._modelMgr:getModel("ActivityModel"):setOneChargeOpenStatus(true)
                    self:updateBtnRed(oneCharge,false,cc.p(54,54))
                    self:adjustPosition()
                end}, true)
        end)
        local isOpen = self._modelMgr:getModel("ActivityModel"):isOneChargeOpen()
        self:updateBtnRed(oneCharge,not isOpen,cc.p(54,54))
    end
    
    -- 训练场活动    
    local trainAcBtn = self:getUI("rightLayer.rightBtnLayer.trainAcBtn")
    trainAcBtn:setVisible(false)
    trainAcBtn:setTouchEnabled(false)
    -- isTrainAcOpen = true
    if isTrainAcOpen then
        trainAcBtn:setVisible(true)
        trainAcBtn:setTouchEnabled(true)
        local startTime = trainAcData.start_time or currTime
        local endTime = trainAcData.end_time or currTime   
        local isHaveRed = self._modelMgr:getModel("TrainingModel"):isAcBtnHaveRed()
        self:updateBtnRed(trainAcBtn,isHaveRed,cc.p(54,54))
        self:registerClickEvent(trainAcBtn, function ()
            -- isAcBtnHaveRed
            self._modelMgr:getModel("TrainingModel"):setAcBtnRed(false)
            -- 检测红点
            self:updateBtnRed(trainAcBtn,false,cc.p(54,54))
            self._viewMgr:showDialog("activity.ACTrainingLiveDialog", {trainAcData=trainAcData,
                callback = function()
                    -- 适配btn位置
                    self:adjustPosition()
                end}, true)
        end)
    end 

    -- 公测庆典
    local celebrationBtn = self:getUI("rightLayer.rightBtnLayer.celebrationBtn")
    celebrationBtn:setVisible(false)
    celebrationBtn:setTouchEnabled(false)
    -- isCelebrationOpen = true
    if isCelebrationOpen then
        celebrationBtn:setVisible(true)
        celebrationBtn:setTouchEnabled(true)
        celebrationBtn:setOpacity(0)
        
        -- 更新特效显示状态
        self:updateCelebrationBtn()
        local isCanGet = self._modelMgr:getModel("CelebrationModel"):isMainIconNeedRed()
        self:updateBtnRed(celebrationBtn,isCanGet,cc.p(54,54))

        local startTime = celebrationData.start_time or currTime
        local endTime = celebrationData.end_time or currTime   
        -- print("=====================startTime=,=endTime=",startTime,endTime)
        -- 判断是否需要展示特效
        self:registerClickEvent(celebrationBtn, function ()
            local tabIdx = 1
            if self._modelMgr:getModel("CelebrationModel"):isIntPointNeedPlayEffect() then
                tabIdx = 2
            end
            self._viewMgr:showDialog("activity.celebration.AcCelebrationView", {
                currIdx = tabIdx,
                callback = function()
                    self:updateCelebrationBtn()
                    local isCanGet = self._modelMgr:getModel("CelebrationModel"):isMainIconNeedRed()
                    self:updateBtnRed(celebrationBtn,isCanGet,cc.p(54,54))
                    -- 适配btn位置
                    self:adjustPosition()
                end}, true)
        end)
    end 
    if GameStatic.appleExamine then
        celebrationBtn:setVisible(false)
    end

    -- 回流活动
    local backflowBtn = self:getUI("topLayer.backflowBtn")
    backflowBtn:setVisible(false)
    backflowBtn:setTouchEnabled(false)
    local isBackflowOpen = self._modelMgr:getModel("BackflowModel"):getBackflowOpen()
    if isBackflowOpen then
        backflowBtn:setVisible(true)
        backflowBtn:setTouchEnabled(true)
        self:updateBackFlowBtn(backflowBtn)        
        -- local isCanGet = self._modelMgr:getModel("BackflowModel"):getBackflowTip()
        -- self:updateBtnRed(backflowBtn,isCanGet,cc.p(54,54))
        local startTime = celebrationData.start_time or currTime
        local endTime = celebrationData.end_time or currTime   
        -- print("=====================startTime=,=endTime=",startTime,endTime)
        local callback = function()
            if self._backFlowView then 
                self._backFlowView = nil
            end
            -- local isCanGet = self._modelMgr:getModel("BackflowModel"):getBackflowTip()
            -- self:updateBtnRed(backflowBtn,isCanGet,cc.p(54,54))
            self:updateBackFlowBtn(backflowBtn)
            -- 适配btn位置
            -- self:adjustPosition()
        end
        -- 判断是否需要展示特效
        self:registerClickEvent(backflowBtn, function ()
            self._backFlowView = self._viewMgr:showDialog("backflow.BackflowView", {callback = callback})
        end)
    end 

    -- 动态单笔充值活动
    local tehuiActivityBtn = self:getUI("rightLayer.rightBtnLayer.tehuiActivityBtn")
    tehuiActivityBtn:setVisible(false)
    tehuiActivityBtn:setTouchEnabled(false)
    local isTeHuiActivityOpen = self._modelMgr:getModel("ActivityModel"):getTeHuiActivityOpen()
    if isTeHuiActivityOpen then
        local teHuiData = self._modelMgr:getModel("ActivityModel"):getIntRechargeData()
        tehuiActivityBtn:setVisible(true)
        tehuiActivityBtn:setTouchEnabled(true)
        
        local isCanGet = self._modelMgr:getModel("ActivityModel"):getIntRechargeCanGet()
        self:updateBtnRed(tehuiActivityBtn,isCanGet,cc.p(54,54))

        local startTime = teHuiData.start_time or currTime
        local endTime = teHuiData.end_time or currTime   
        -- print("=====================startTime=,=endTime=",startTime,endTime)
        local callback = function()
            local isCanGet = self._modelMgr:getModel("ActivityModel"):getIntRechargeCanGet()
            self:updateBtnRed(tehuiActivityBtn,isCanGet,cc.p(54,54))
            -- 适配btn位置
            self:adjustPosition()
        end
        -- 判断是否需要展示特效
        self:registerClickEvent(tehuiActivityBtn, function ()
            self._viewMgr:showDialog("activity.AcIntelligentRechargeLayer", {callback = callback})
        end)
    end 
    
    -- 幸运转盘（抽奖转转转）
    local runeLotteryModel = self._modelMgr:getModel("RuneLotteryModel")
    local luckyLotteryBtn = self:getUI("rightLayer.rightBtnLayer.luckyLotteryBtn")
    luckyLotteryBtn:setVisible(false)        
    luckyLotteryBtn:setTouchEnabled(false)
    if runeLotteryModel:isLotteryOpen() then
        luckyLotteryBtn:setVisible(true)        
        luckyLotteryBtn:setTouchEnabled(true)
        local isHaveRed = runeLotteryModel:isLuckyLotteryRed()
        self:updateBtnRed(luckyLotteryBtn, isHaveRed, cc.p(54,54))
        self:registerClickEvent(luckyLotteryBtn, function ()
        
            self._serverMgr:sendMsg("RuneLotteryServer", "getInfo", {type=buyNum}, true, {}, function(data)
                -- 播放动画
                print("============抽奖回调============")
                self._viewMgr:showDialog("activity.acLuckyLottery.AcLuckyLotteryDialog",
                    {closeCallBack=function ( )                
                        local isHaveRed = runeLotteryModel:isLuckyLotteryRed()
                        self:updateBtnRed(luckyLotteryBtn, isHaveRed, cc.p(54,54))
                        self:adjustPosition()
                    end},
                    false,nil,nil,false) 
            end)
        end)
        
    end

    -- 成长之路
    local growthwayBtn = self:getUI("rightLayer.rightBtnLayer.growthwayBtn")
    growthwayBtn:setVisible(false)
    growthwayBtn:setTouchEnabled(false)
    -- 通过静态文件GameStatic额外控制是否显示
    if not GameStatic.showGrowthWay then
        isGrowthWayOpen = GameStatic.showGrowthWay
    end
    -- 这个部分先设置成常开，等有了正式的活动ID走正式流程
    if isGrowthWayOpen then
        growthwayBtn:setVisible(true)
        growthwayBtn:setTouchEnabled(true)
        local isHaveRed = self._modelMgr:getModel("GrowthWayModel"):isHaveRedPoint()
        self:updateBtnRed(growthwayBtn,not isHaveRed, cc.p(54,54))
        self:registerClickEvent(growthwayBtn, function ()
        self._serverMgr:sendMsg("RoadOfGrowthServer", "getRoadOfGrowth", {}, true, {}, function(result, success) 
            self._viewMgr:showDialog("activity.growthway.GrowthWayView",{callback = function ( )
                local isHaveRed = self._modelMgr:getModel("GrowthWayModel"):isHaveRedPoint()
                self:updateBtnRed(growthwayBtn,not isHaveRed, cc.p(54,54))
                self:adjustPosition()
                end},true)
            end)
        end)
    end
    
    -- 终极降临
    local acUltimateModel = self._modelMgr:getModel("AcUltimateModel")
    local ultimateBtn = self:getUI("rightLayer.rightBtnLayer.ultimateBtn")
    ultimateBtn:setVisible(false)        
    ultimateBtn:setTouchEnabled(false)
    if acUltimateModel:isActivityOpen() then
        ultimateBtn:setVisible(true)
        ultimateBtn:setTouchEnabled(true)
        local isHaveRed = acUltimateModel:isRedNotice()
        self:updateBtnRed(ultimateBtn, isHaveRed, cc.p(54,54))
        self:registerClickEvent(ultimateBtn, function ()
            if not acUltimateModel:isActivityOpen() then
                self._viewMgr:showTip("活动已结束")
                return
            end
            self._serverMgr:sendMsg("ComingGuildAcServer", "getInfo", {}, true, {}, function(data)
                -- 获取信息回调
                self._viewMgr:showDialog("activity.acUltimate.AcUltimateDialog",
                    {closeCallBack=function ( )
                        -- 有推送消息更新
                        local acUltimateModel = self._modelMgr:getModel("AcUltimateModel")
                        acUltimateModel:doUpdate()
                        local isHaveRed = acUltimateModel:isRedNotice()
                        self:updateBtnRed(ultimateBtn, isHaveRed, cc.p(54,54))
                        self:adjustPosition()
                    end},
                    false,nil,nil,false)
            end)
        end)
    end

    -- 限时祈愿
    local limitPrayBtn = self:getUI("rightLayer.rightBtnLayer.limitPrayBtn")
    local limitPrayModel = self._modelMgr:getModel("LimitPrayModel")
    limitPrayBtn:setVisible(false)        
    limitPrayBtn:setTouchEnabled(false)
    local isOpen = limitPrayModel:isActicityOpen()
    -- print("============isOpen=====",isOpen)
    
    if isOpen and GameStatic.is_show_limitPray then
        if not self._limitBtnMc then
            self._limitBtnMc = {
                [978] = {                   -- 审判官
                        mcName   = "shenpanguanrukou_shenpanguanrukou",
                },
                [1041] = {                  -- 傀儡龙
                        mcName   = "kuileilongtubiao_kuileilongtubiao",                
                },
                [1094] = {                  -- 海后
                        mcName   = "haihourukou_haihourukou",  
                },
                [1187] = {                  -- 暗黑领主
                        mcName   = "sishenrukou_sishenrukou",  
                },
                [1250] = {                  -- 邪魔女
                        mcName   = "xieshennvrukou_xiemonvrukou",  
                },
                [1333] = {                  -- 螳螂
                        mcName   = "tanglangrukou_tanglangrukou",  
                },
            }
        end
    
        limitPrayBtn:setVisible(true)        
        limitPrayBtn:setTouchEnabled(true)
        local openID ,acID = limitPrayModel:getCurrPrayId()
        if limitPrayBtn.openID ~= openID then
            if self._limitBtnMc[openID] and self._limitBtnMc[openID].mcName then
                self:addBtnEffect(limitPrayBtn,self._limitBtnMc[openID].mcName,limitPrayBtn:getContentSize().width*.5,limitPrayBtn:getContentSize().height*.5)
            end
            -- if self._limitBtnMc[openID] and self._limitBtnMc[openID].opacityNum then
            --     limitPrayBtn:setOpacity(255)
            -- end
            limitPrayBtn.openID = openID
        end
        self._serverMgr:sendMsg("LimitPrayServer", "getLimitPrayInfo", {acId = openID}, true, {}, function (result, error)
            limitPrayModel:setDataById(result,openID)
            local isHaveRed = limitPrayModel:isHaveRedNotice(openID)
            -- print("================isHaveRed=======",isHaveRed)
            self:updateBtnRed(limitPrayBtn,isHaveRed, cc.p(54,54))             
        end)
        
        -- print(isOpen,"==========openID===",openID,acID)
        self:registerClickEvent(limitPrayBtn, function ()
            if not limitPrayModel:getDataById(openID) then
                return
            end
            self._viewMgr:showView("activity.acLimitPray.AcLimitPrayView",{openId = openID,acId = acID},true)
        end)
    end
    --添加boss按钮
    local wroldBossBtn = self:getUI("rightLayer.rightBtnLayer.wroldBossBtn")
    wroldBossBtn:setVisible(false)        
    wroldBossBtn:setTouchEnabled(false)
    self:addWorldBossBtn()


    -- 邀请有礼活动
    self:updateInvitedBtn(isInvitedOpen)
    -- 凛冬已至
    self:updatePowerGameBtn(isPowerOpen)
    
    -- 检测红点
    self:checkRightUpBtnRed()
    self:adjustPosition()
    self:updateMerchantBtn()
end


function MainView:addWorldBossBtn()
    if not GameStatic.is_show_worldBoss then
        return
    end
    --世界boss
    local wroldBossBtn = self:getUI("rightLayer.rightBtnLayer.wroldBossBtn")
    if wroldBossBtn:isVisible() then
        return
    end
    wroldBossBtn:setVisible(false)        
    wroldBossBtn:setTouchEnabled(false)
    local clearTime = tab.setting["WORLDBOSS_CLEARTIME"].value
    local isOpen = self._worldBossModel:checkLevelAndServerTime()
    local openStatus,hasTime = 0 , 0
    if isOpen then
        openStatus,hasTime = self._worldBossModel:checkOpenTime(clearTime*60)
        isOpen = openStatus == self._worldBossModel.isOpen and true or false
    end
    if wroldBossBtn.timer then
        ScheduleMgr:unregSchedule(wroldBossBtn.timer)       
        wroldBossBtn.timer = nil
    end

    if isOpen then
        local bossTime = wroldBossBtn:getChildByFullName("time")
        bossTime:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        bossTime:setString("")
        if not wroldBossBtn._normalMc then
            local mc = mcMgr:createViewMC("bosszhanrukou_booszhanrukou", true,false)
            mc:setPosition(30,30)
            wroldBossBtn:addChild(mc)
            wroldBossBtn._normalMc = mc
        end
        wroldBossBtn:setVisible(true)        
        wroldBossBtn:setTouchEnabled(true)
        self:registerClickEvent(wroldBossBtn, function ()
            self._viewMgr:showView("worldboss.WorldBossView",{},true)
        end)
        wroldBossBtn.timer = ScheduleMgr:regSchedule(1000,self,function( )
            local realHasTime = hasTime - clearTime*60
            if realHasTime > 0 then
                bossTime:setString(TimeUtils.getStringTimeForInt(realHasTime))
            else
                bossTime:setString("")
            end
            
            if hasTime == 0 then
                wroldBossBtn:setVisible(false)        
                wroldBossBtn:setTouchEnabled(false)
                ScheduleMgr:unregSchedule(wroldBossBtn.timer)       
                wroldBossBtn.timer = nil
                self:adjustPosition()
            else
                hasTime = hasTime - 1
            end
        end)
        self:adjustPosition()
    end
end

-- 神秘商人
function MainView:updateMerchantBtn()
    if not GameStatic.is_show_treasureMerchant then 
        return
    end
    if not self._merchantModel then
        self._merchantModel = self._modelMgr:getModel("TreasureMerchantModel")
    end
    local isOpen = self._merchantModel:isTreasureMerchantOpen()
    print("===========123123123====isOpen======",isOpen)
    if self._merchantBtn then 
        self._merchantBtn:setVisible(isOpen)
        return
    end
    if not isOpen then
        return
    end
    
    local merchantBtn = ccui.Button:create("button_treasureMerchant_mainView.png", "button_treasureMerchant_mainView.png", "button_treasureMerchant_mainView.png", 1)
    merchantBtn:setPosition(980, 190)
    merchantBtn:setScaleAnim(false)
    self:registerClickEvent(merchantBtn, function ()
        
    end)
    self:registerTouchEvent(merchantBtn,
        function () --downCallback
            if merchantBtn._lightImg then         
                merchantBtn._lightImg:stopAllActions()
                merchantBtn._lightImg:setOpacity(100)
                merchantBtn._lightImg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 100), cc.FadeTo:create(0.5, 50))))
            end
        end,
        function () --moveCallback
            if merchantBtn.downSp ~= merchantBtn:getVirtualRenderer() then
                merchantBtn:setBrightness(0)
            end
        end,
        function () --upCallback
            if merchantBtn._lightImg then
                merchantBtn._lightImg:stopAllActions()
                merchantBtn._lightImg:setOpacity(0)
                merchantBtn._lightImg:setBrightness(0)
            end
            self._serverMgr:sendMsg("ActivityServer", "getTreasureMerchantInfo", {}, true, {}, function (result, error)
                self._merchantModel:setQipaoStatus(true) 
                self._viewMgr:showView("activity.mysteryTreasure.TreasureDirectShopView",{},true)   
                if merchantBtn.__tipsImg then
                    merchantBtn.__tipsImg:setVisible(false)
                end
            end)

        end,
        function()  --outCallback
            if merchantBtn._lightImg then
                merchantBtn._lightImg:stopAllActions()
                merchantBtn._lightImg:setOpacity(0)
                merchantBtn._lightImg:setBrightness(0)
            end
        end)
    local midBg = self:getUI("bg.midBg1")
    self._merchantBtn = merchantBtn
    midBg:addChild(merchantBtn)

    -- 气泡
    local tipsImg = ccui.ImageView:create()
    tipsImg:loadTexture("button_treasureMerchantQipao_mainView.png",1)
    -- tipsImg:setScale9Enabled(true)
    -- tipsImg:setCapInsets(cc.rect(10,30,1,1))
    -- tipsImg:setContentSize(cc.size(150,64))
    tipsImg:setAnchorPoint(0.5,0.5)
    tipsImg:setPosition(50,105)
    merchantBtn:addChild(tipsImg)
    merchantBtn.__tipsImg = tipsImg    
    local seq = cc.Sequence:create(cc.ScaleTo:create(1, 1.1), cc.ScaleTo:create(1, 1))
    tipsImg:runAction(cc.RepeatForever:create(seq))

    local qipaoStatus = self._merchantModel:getQipaoStatus()
    -- print("============v====",qipaoStatus)
    tipsImg:setVisible(not qipaoStatus)  

    local lightImg = ccui.ImageView:create()
    lightImg:loadTexture("button_treasureMerchantLight_mainView.png",1)
    lightImg:setAnchorPoint(0,0)
    lightImg:setPosition(0,0)
    lightImg:setOpacity(0)
    merchantBtn._lightImg = lightImg
    merchantBtn:addChild(lightImg)

    -- local titleTxt = ccui.Text:create()
    -- titleTxt:setString("领主,选个宝物吧")
    -- titleTxt:setFontSize(18)
    -- titleTxt:setFontName(UIUtils.ttfName)
    -- titleTxt:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- -- titleTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    -- titleTxt:setAnchorPoint(0.5,0.5)
    -- titleTxt:setPosition(0,110)
    -- merchantBtn:addChild(titleTxt)

end

-- 邀请有礼
function MainView:updateInvitedBtn(isOpen)
    local qqActivityBtn = self:getUI("rightLayer.rightBtnLayer.qqActivityBtn")
    qqActivityBtn:setVisible(false)
    qqActivityBtn:setTouchEnabled(false)
    if not isOpen then return end
    qqActivityBtn:setVisible(true)
    qqActivityBtn:setTouchEnabled(true)
    -- 红点
    local isClicked = SystemUtils.loadAccountLocalData("MainView_InvitedBtnRed")
    self:updateBtnRed(qqActivityBtn,not isClicked,cc.p(54,54))
    self:registerClickEvent(qqActivityBtn, function ()
        if not isClicked then
            SystemUtils.saveAccountLocalData("MainView_InvitedBtnRed", true)
            self:updateBtnRed(qqActivityBtn,false,cc.p(54,54))
        end
        if sdkMgr:isQQ() then
            print("==qqUrl==",GameStatic.qqInviteUrl)
            sdkMgr:loadUrl({url = GameStatic.qqInviteUrl})
        elseif sdkMgr:isWX() then
            print("==wxUrl==",GameStatic.wxInviteUrl)
            sdkMgr:loadUrl({url = GameStatic.wxInviteUrl})
        else
            print("==windowsUrl==",GameStatic.qqInviteUrl)
            sdkMgr:loadUrl({url = GameStatic.qqInviteUrl})
        end
    end)

end

function MainView:updatePowerGameBtn(isOpen)
    local powerGameBtn = self:getUI("rightLayer.rightBtnLayer.powerGameBtn")
    powerGameBtn:setVisible(false)
    powerGameBtn:setTouchEnabled(false)
    if not isOpen then return end
    powerGameBtn:setVisible(true)
    powerGameBtn:setTouchEnabled(true)
    -- 红点
    self:registerClickEvent(powerGameBtn, function ()
        -- print("==powerGameUrl==",GameStatic.powerGameUrl)
        if GameStatic.powerGameUrl and GameStatic.powerGameUrl ~= "" then 
            local userModel = self._modelMgr:getModel("UserModel")
            local tempUrl = GameStatic.powerGameUrl
            local platid = 0   --平台 安卓1  ios0
            local areaid = 1   -- 微信 1   qq 2

            if OS_IS_IOS then
                platid = 0
            elseif OS_IS_ANDROID then
                platid = 1
            end
            if sdkMgr:isQQ() then
                areaid = 2
            elseif sdkMgr:isWX() then
                areaid = 1
            end
            local flag = "?"
            if string.find(tempUrl,"?") then
                flag = ""
            end
            tempUrl = tempUrl .. flag .. string.format("partition=%s&roleid=%s&platId=%s&areaId=%s", 
                tostring(GameStatic.sec), 
                tostring(userModel:getRID()),
                platid,
                areaid)

            sdkMgr:loadUrl({url = tempUrl})
        end 
    end)

end

function MainView:updateCelebrationBtn()
    local celebrationBtn = self:getUI("rightLayer.rightBtnLayer.celebrationBtn")
    if not celebrationBtn:isVisible() then return end
    local isNeedMc = self._modelMgr:getModel("CelebrationModel"):isIntPointNeedPlayEffect()
    -- 常态mc
    if not celebrationBtn.__normalMc then
        local normalMc = mcMgr:createViewMC("huodongqingdian1_huodongqingdian", true, false) 
        -- normalMc:setScale(0.9)
        normalMc:setPosition(celebrationBtn:getContentSize().width*0.5, celebrationBtn:getContentSize().height*0.5)
        normalMc:setName("normalMc")
        celebrationBtn:addChild(normalMc,1)
        celebrationBtn.__normalMc = normalMc
    end

    -- 特殊态mc
    if not celebrationBtn.__getMc then 
        local getMc = mcMgr:createViewMC("huodongqingdian2_huodongqingdian", true, false) 
        -- getMc:setScale(0.9)
        getMc:setPosition(celebrationBtn:getContentSize().width*0.5, celebrationBtn:getContentSize().height*0.5)
        getMc:setName("getMc")
        celebrationBtn:addChild(getMc,1)
        celebrationBtn.__getMc = getMc
    end
    celebrationBtn.__normalMc:setVisible(not isNeedMc)
    celebrationBtn.__getMc:setVisible(isNeedMc)

    -- 主界面 庆典活动红点
    local isCanGet = self._modelMgr:getModel("CelebrationModel"):isMainIconNeedRed()
    self:updateBtnRed(celebrationBtn,isCanGet,cc.p(54,54))
end

function MainView:updateBackFlowBtn()
    local backflowBtn = self:getUI("topLayer.backflowBtn")
    backflowBtn:setOpacity(0)
    if not backflowBtn._mc then
        local mc = mcMgr:createViewMC("huiguifuli_huiliutubiao", true, false) 
        mc:setPosition(backflowBtn:getContentSize().width*0.5, backflowBtn:getContentSize().height*0.5)
        mc:setName("mc")
        backflowBtn:addChild(mc)
        backflowBtn._mc = mc
    end
    if not backflowBtn.__action then
        local action = cc.RepeatForever:create(
            cc.Sequence:create(cc.MoveTo:create(1, cc.p(358, 128)),
                cc.MoveTo:create(1, cc.p(358, 138))
            ))
        backflowBtn:runAction(action)
        backflowBtn.__action = action
    end
    local score = self._modelMgr:getModel("BackflowModel"):getTaskDataScore() or 0
    if not self._maxCount then 
        local taskRewardData = self._modelMgr:getModel("BackflowModel"):getTaskRewardData() or {}
        local boxNum = #taskRewardData
        self._maxCount = taskRewardData[boxNum] and taskRewardData[boxNum].accumulatepoints or 100
    end
    -- 进度条
     if not backflowBtn.__pro then

        local proBg1 = ccui.ImageView:create()
        proBg1:setScale(0.4)
        proBg1:loadTexture("backFlow_proBg_mainView.png",1)
        proBg1:setPosition(backflowBtn:getContentSize().width*0.5,20)
        backflowBtn:addChild(proBg1,2)

        local proBox = ccui.ImageView:create()
        proBox:loadTexture("backFlow_btnBox_mainView.png",1)
        proBox:setPosition(backflowBtn:getContentSize().width*0.5,20)
        backflowBtn:addChild(proBox,2)

        local sp = cc.Sprite:createWithSpriteFrameName("backFlow_pro_mainView.png")
        local pro = cc.ProgressTimer:create(sp)
        -- pro:setPurityColor(255, 0, 0)
        pro:setScale(0.4)
        pro:setRotation(180)
        pro:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
        backflowBtn:addChild(pro,2)
        pro:setPosition(backflowBtn:getContentSize().width*0.5, 21)
        backflowBtn.__pro = pro
        local proNum = score/self._maxCount * 90 + 5
        pro:setPercentage(proNum)
    else
        local proNum = score/self._maxCount * 90 + 5
        backflowBtn.__pro:setPercentage(proNum)
    end 
end
        
--[[
    经验兑换人物头像处红点
]]
function MainView:checkExpExchangeOpen()
    if self._userModel:isShowExpExchangeRedPoint() then
        local btn = self:getUI("topLayer.headImgNode")
        self:updateBtnRed(btn,true,cc.p(25,100))
    else
        local btn = self:getUI("topLayer.headImgNode")
        self:updateBtnRed(btn,false,cc.p(25,100))
    end
end

function MainView:onDirectRedDotChange()
    local directModel = self._modelMgr:getModel("DirectShopModel")
    local info = directModel:getDirectShopRedInfo()
    if not info then return end
    local cick = directModel:getCickTab()
    local haveRed 

    -- dump(info,"onDirectRedDotChange",5)
    -- dump(cick,"onDirectRedDotChangecick",5)
    for tabIndex,status in pairs (info) do 
        if status == true and table.find(cick,tabIndex) == nil then
            haveRed = true
            break
        end
    end
    local btn = self:getUI("rightLayer.directShopBtn")
    self:updateBtnRed(btn,haveRed,cc.p(60,60))
end


--直购商店红点检测
function MainView:checkDirectRed(isFirst)
    local palyerLevel  = self._modelMgr:getModel("UserModel"):getData().lvl
    local openDay = math.floor(self._modelMgr:getModel("UserModel"):getOpenServerTime()/86400)
    if palyerLevel < 23 or openDay < DirectShopOpenNeedDay then
        return
    end
    local directModel = self._modelMgr:getModel("DirectShopModel")
    if directModel:isServerDataDirty() then
        directModel:setServerDataStatus(false)
        self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = "zhigou"}, true, {}, function(result)
            print("MainView:checkDirectRed----1")
            if isFirst == true then
                directModel:checkRedInfo()
            else
                directModel:updateRedInfo()
            end
            self:onDirectRedDotChange()
        end)
        return
    end
    print("MainView:checkDirectRed----2")
    if isFirst == true then
        directModel:checkRedInfo()
    else
        directModel:updateRedInfo()
    end
    self:onDirectRedDotChange()
end

-- 右上角按钮红点刷新
function MainView:updateBtnRed(btn,ishavered,pos)
    if not btn then return end
    local position = pos or cc.p(54,54)
    if ishavered then
        self:addNoticeDot(btn,{pos = position})
    else
        self:clearNoticeDot(btn)
    end
end

--[[
--! @function addAcBtnCoutDown
--! @desc 添加活动按钮倒计时
--! @param btn      obj 倒计时父节点
           endTime  int 结束时间
           mode     int 显示模式
                1:时：分：秒
                2:多少天以后
--! @return
--]]
function MainView:addAcBtnCoutDown(btn,endTime,mode)
    -- 添加倒计时label

    local CDmode = mode
    if not mode then
        CDmode = 1
    end
    local funcMode = {}
    funcMode[1] = function(totalTime) 
        local isNeedHide = false 
        local hour ,min,sec = TimeUtils.getTimeStringSplitHMS(totalTime)                            
        local str = hour .. ":" .. min .. ":" .. sec 
        if 0 == tonumber(hour) and 0 == tonumber(min) and 0 == tonumber(sec) then
            isNeedHide = true
        end
        return str,isNeedHide
    end

    funcMode[2] = function(totalTime) 

        local hour ,min,sec = TimeUtils.getTimeStringSplitHMS(totalTime) 
        local str = ""                           
        if tonumber(hour) ~= 0 then
            str = hour .. "h" .. "后结束"
        elseif tonumber(min) ~= 0 then
            str = min .. "m" .. "后结束"
        else
            str = sec .. "s" .. "后结束"
        end
        local isNeedHide = false 
        if 0 == tonumber(hour) and 0 == tonumber(min) and 0 == tonumber(sec) then
            isNeedHide = true
        end
        return str,isNeedHide
    end

    if not btn.timeTxt then 
        local currTime = self._modelMgr:getModel("UserModel"):getCurServerTime() 
        local timeTxt = cc.Label:createWithTTF("", UIUtils.ttfName, 16)
        timeTxt:setColor(cc.c3b(57, 250, 0))
        timeTxt:setAnchorPoint(0.5, 1)
        timeTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        timeTxt:setPosition(btn:getContentSize().width/2, -7)
        timeTxt:setName("CDTime")
        btn.timeTxt = timeTxt
        -- local hour ,min,sec = TimeUtils.getTimeStringSplitHMS(endTime - currTime)                            
        local str,_ = funcMode[tonumber(CDmode)](endTime - currTime) 
        btn:addChild(timeTxt, 10001)
        btn.timeTxt:setString(str)
    end
    btn.timer = ScheduleMgr:regSchedule(1000,self,function( )
        local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()                             
        local str,isNeedHide = funcMode[tonumber(CDmode)](endTime - curServerTime)   
        btn.timeTxt:setString(str)
        if isNeedHide then
            btn:setVisible(false)        
            btn:setTouchEnabled(false)
            ScheduleMgr:unregSchedule(btn.timer)
            btn.timer = nil
        end
    end)
end

function MainView:removeCountDownTxt(btn)
    if not btn then return end
    if btn.timer then
        ScheduleMgr:unregSchedule(btn.timer)
        btn.timer = nil
    end
    if btn.timeTxt then 
        btn.timeTxt:setVisible(false)
    end    
end

function MainView:reflashUserInfo( viewname )
    local userInfo = self._modelMgr:getModel("UserModel"):getData()
    -- dump("userInfo", userInfo, "------------")
    if table.nums(userInfo) == 0 then
        return 
    end

    --更新直购商店状态
    self:checkDirectShopOpen()

    self:checkExpExchangeOpen()

    --更新任务特效
    self:updateTaskBtn()
    --todo

    local rewardState = self._userModel:getTopPayWeekRewardState()
    -- 是否是toppay100 
    local topPay = userInfo.topPay 
    local topPayBtn = self:getUI("leftBtnLayer.scrollView.topPayBtn")
    topPayBtn:setScaleAnim(true)
    local topPayRed = topPayBtn:getChildByName("noticeTip")
    if not topPayRed then
        topPayRed = self:addNoticeDot(topPayBtn,{pos=cc.p(47,47)}) 
    end
    topPayRed:setVisible((rewardState == false))
    
    if topPay == 1 or OS_IS_WINDOWS then 
        topPayBtn:setVisible(true)
        self:registerClickEvent(topPayBtn, function ()
            self._viewMgr:showDialog("main.TopPayView", {})
        end)
    else
        topPayBtn:setVisible(false)
    end
    

    -- IconUtils:createHeadIconById()
    -- if not self._avatar then
    --     local art = tab:RoleAvatar(userInfo.avatar).icon or 1101
    --     self._avatar = cc.Sprite:createWithSpriteFrameName("".. art .. ".jpg")
    --     self._avatar:setPosition(60, 77)
    --     self._headImgNode:addChild(self._avatar)
    -- else
    --     local art = tab:RoleAvatar(userInfo.avatar).icon or 1101
    --     self._avatar:setSpriteFrame("".. art .. ".jpg")
    -- end
    -- print("=======------------=======",userInfo.avatar)
    local tencetTp = nil

    if not IS_ANDROID_OUTSIDE_CHANNEL and self._modelMgr:getModel("TencentPrivilegeModel"):isOpenPrivilege() then
        if sdkMgr:isWX() then
            tencetTp = self._modelMgr:getModel("TencentPrivilegeModel"):getTencentTeQuan()
        elseif sdkMgr:isQQ()  then
            tencetTp = self._modelMgr:getModel("TencentPrivilegeModel"):getQQVip()
        end
    end

    if not self._avatar then 
        self._avatar = IconUtils:createHeadIconById({avatar = userInfo.avatar,tp = 4, isSelf = true, eventStyle=1, tencetTp = tencetTp})   --,tp = 2
        self._avatar:setPosition(17, 20)
        self._headImgNode:addChild(self._avatar)
    else
        IconUtils:updateHeadIconByView(self._avatar,{avatar = userInfo.avatar,tp = 4, isSelf = true, eventStyle=1, tencetTp = tencetTp})   --,tp = 2
    end
    local needExp = nil
    if self._userModel:isMaxParagonLevel() then
        self._progressBar:loadTexture("expBar_pTalent_mainView.png", 1)
        needExp = tab:ParagonLevel(userInfo.plvl).exp
        
    elseif self._userModel:isHaveParagonLevel() then
        self._progressBar:loadTexture("expBar_pTalent_mainView.png", 1)
        needExp = tab:ParagonLevel((userInfo.plvl or 0) + 1).exp
    else
        self._progressBar:loadTexture("expBar_mainView.png", 1)
        needExp = tab:UserLevel(userInfo.lvl).exp
    end
    if needExp then
        self._progressBar:setPercent(userInfo.exp/needExp*100)
    end
    self._levelLabel:setString(userInfo.lvl or "0")
    self._levelLabel:setVisible(false)
    local userScore = self:updateFightNum()
    self._zhandouliLabel:setString(userScore or "100")
    -- self._zhandouliTipImg:setPositionX(self._zhandouliLabel:getContentSize().width+2)
    local name = userInfo.name
    if name == "" then
        name = self._modelMgr:getModel("UserModel"):getUID()
    end
    local lvl = userInfo.lvl or ""
    local tempUserLv = UIUtils:adjustLevelShow(self._userLv, {lvlStr = "Lv." .. lvl}, 1)
    self._name:setString(name)
    self._name:setPositionX(tempUserLv:getPositionX()+tempUserLv:getContentSize().width+5)
    local vip = self._modelMgr:getModel("VipModel"):getData().level or 0
    if vip > 0 then
        self._vipIcon:setVisible(true)  
        self._vipIcon:loadTexture(("chatPri_vipLv"..math.max(1, vip)..".png"), 1)
    else
        -- 增加 vip0标签 by guojun 2017.3.23
        self._vipIcon:setVisible(true)
        self._vipIcon:loadTexture(("chatPri_vipLv0.png"), 1)
    end
    -- local x = self._name:getPositionX() + self._name:getContentSize().width + 20
    -- if x < 240 then x = 240 end
    -- self._vipIcon:setPosition(x, self._vipIcon:getPositionY())

    -- 重新设置主界面按钮开启状态--
    for i,v in ipairs(self._funOpenList) do
        self:addBtnFunction(v)
    end

    -- 更新特效显示
    for i,v in ipairs(self._effectList) do
        local systemName = v[4]
        local isOpen = true
        if systemName then
            isOpen,_ = SystemUtils["enable".. systemName]()
        end 
        local btn = self:getUI(v[1])
        if btn then
            if btn.__buildMc then
                btn.__buildMc:setVisible(isOpen)
            else
                self:addAnimation2Node(v[2],self:getUI(v[1]),v[3])
            end
        end
    end  

    -- if userInfo.lvl < 35 then
    --     self:setActionAdvance()
    -- else
    --     self:removeActionAdvance()
    -- end
        self:setActionAdvance()

    local vipLevel = self._modelMgr:getModel("VipModel"):getData().level or 0
    --首冲按钮的开启
    local firstIsOpen,_ = SystemUtils["enablefirstpay"]()
    local btn = self:getUI("rightLayer.rightBtnLayer.firstChargeBtn") 
    local payGemNum = 0
    if userInfo.statis then
        payGemNum = userInfo.statis.snum18 or 0
    else
        payGemNum = 0
    end
    btn:setVisible(firstIsOpen or (tonumber(payGemNum) > 0) ) 
    if tonumber(payGemNum) > 0 then 
        if tonumber(userInfo.award.first_recharge) == 1 then 
            btn:setVisible(false)              
            self._rightVipBtn:setVisible(true)     
            if tonumber(vipLevel) > 0 and tonumber(vipLevel) <= activityLvL[#activityLvL] then   --月卡
                local num = self:getLvlByVipLevel(tonumber(vipLevel))
                self:updateActivityBtn(tonumber(num)) 
            else
                -- self._monthBtn:setVisible(false)
                self._rightVipBtn:setVisible(false)
            end
            -- chargePresentBtn -- 次充领奖
            self:updateChargePresentBtn(userInfo)
            self:adjustPosition() 
        else
            self:addNoticeDot(btn,{pos=cc.p(54,54)})
            createUpBtnTitleLabel(btn, lang("MAIN_LINGQU"), 0, 0,16)
        end        
    end


    self:handlerSevenDaysAndLevelFBAct()
    -- 达到等级开启嘉年华
    self:updateCarnivalState()
    self:updateExtendBar2()

    -- 右侧充值一排按钮位置自适应
    self:rightBtnAdjustPosition()
end

-- 更新次充按钮
function MainView:updateChargePresentBtn(userInfo)
    local chargePresentBtn = self:getUI("rightLayer.rightBtnLayer.chargePresentBtn")
    chargePresentBtn:setVisible(false)
    chargePresentBtn:setEnabled(false)
    -- 已领 活动关闭
    if userInfo.award.second_recharge and tonumber(userInfo.award.second_recharge) == 2 then
        return
    end
    if userInfo.award.second_recharge and tonumber(userInfo.award.second_recharge) == 1 then
        self:addNoticeDot(chargePresentBtn,{pos=cc.p(54,54)})
    end
    if not self._activityModel then
        self._activityModel = self._modelMgr:getModel("ActivityModel")
    end    
    local acData = self._activityModel:getAcShowDataByType(42) or {}
    local startTime = acData.start_time or 0
    local endTime = acData.end_time or 0
    local currTime = self._userModel:getCurServerTime()

    print("=============startTime=currTime=endTime====",startTime,currTime,endTime)
    if startTime <= currTime and endTime > currTime then
        chargePresentBtn:setVisible(true)
        chargePresentBtn:setEnabled(true)
        self:registerClickEventByName("rightLayer.rightBtnLayer.chargePresentBtn", function ()
            self._viewMgr:showDialog("activity.AcRechargePresentView", {closeCallBack=function ( )  
                local currTime = self._userModel:getCurServerTime()
                print("=======close======startTime=currTime=endTime====",startTime,currTime,endTime)       
                if not (startTime <= currTime and endTime > currTime) then
                    chargePresentBtn:setVisible(false)
                    chargePresentBtn:setEnabled(false)
                end
            end}, true)
        end)
    end
end

function MainView:rightBtnAdjustPosition()
    local btnList = {
        self:getUI("rightLayer.chargeBtn"),
        self:getUI("rightLayer.activityCommonBtn"),
        self:getUI("rightLayer.directShopBtn"),
        self:getUI("rightLayer.rankBtn"),
        self:getUI("rightLayer.signBtn"),
    }
    local posY = btnList[1]:getPositionY()
    local btnH = 78
    for k,v in pairs(btnList) do
        if v:isVisible() then            
            v:setPositionY(posY)
            posY = posY - btnH
        end
    end
end
function MainView:reflashTencentInfo()
    local tencentModel = self._modelMgr:getModel("TencentPrivilegeModel")

    if not GameStatic.appleExamine and tencentModel:isOpenPrivilege() then
        if sdkMgr:isQQ() then
            self._welfareBtn:setVisible(true)
            self._welfareBtn:setPositionX(self._welfareBtn:getPositionX() + 10)
        elseif sdkMgr:isWX()  then
            self._welfareBtn:loadTextures("tencentIcon_wxHead.png","tencentIcon_wxHead.png",nil,1)
            self._welfareBtn:setVisible(true)
            self._welfareBtn:setPositionX(self._welfareBtn:getPositionX() + 10)
        else 
            self._welfareBtn:setVisible(false)
        end
        self:getUI("topLayer.qqVipBtn"):setVisible(sdkMgr:isQQ() or OS_IS_WINDOWS)
    else
        self._welfareBtn:setVisible(false)
        self:getUI("topLayer.qqVipBtn"):setVisible(false)
    end
    if IS_ANDROID_OUTSIDE_CHANNEL then
        self._welfareBtn:setVisible(false)
    end
end

function MainView:updateTaskBtn()
    --通过有没有红点判断任务是否显示特效
    local taskBtn = self:getUI("bottomLayer.extendBar.bg.taskBtn")
    if self._modelMgr:getModel("TaskModel"):hasTaskCanGet() then
     
    else

    end
end
local _speed = {0, 0.2, 0.3, 0.4, 0.55, 0.7}--1590 1364
_speed[0] = -0.5
local _offsetX = {324, -30, 535, -210 + 64, -230, -230} 
_offsetX[0] = 0
function MainView:adjustMapPos()
    local bg = self._bg
    if not self._midBgs then
        self._midBgs = {}
    end
    local x = bg:getInnerContainer():getPositionX()
    if x == self._bgInnerPositionX then
        return
    end

    local xx = 0
    if ADOPT_IPHONEX then
        xx = -60
    end
    self._bgInnerPositionX = x
    for i,v in ipairs(self._midBgs) do
        v:setPositionX(-x*_speed[i] + _offsetX[i] + xx)
    end
    self._foreBg:setPositionX(-x*_speed[0] + _offsetX[0] + xx)
    self._backBg:setPositionX(-x * 0.9 + xx)
end

function MainView:initMap() 
    self._maps = {}
    local bg = self._bg
    local backNode = cc.Node:create()
    bg:addChild(backNode, 0)
    backNode:setAnchorPoint(0, 1)
    backNode:setPosition(0, MAX_SCREEN_HEIGHT)

    local backBg1 = cc.Sprite:createWithSpriteFrameName("bg_mainview.png")
    backBg1:setAnchorPoint(0, 1)
    backNode:addChild(backBg1)
    backNode.backBg1 = backBg1
    local backBg2 = cc.Sprite:createWithSpriteFrameName("bg_mainview.png")
    backBg2:setAnchorPoint(1, 0)
    backBg2:setPositionX(1)
    backBg1:addChild(backBg2)
    backNode.backBg2 = backBg2
    local backBg3 = cc.Sprite:createWithSpriteFrameName("bg_mainview.png")
    backBg3:setAnchorPoint(0, 0)
    backBg3:setPositionX(backBg1:getContentSize().width - 1)
    backBg1:addChild(backBg3)
    backNode.backBg3 = backBg3

    self._backBg = backNode 

    local backBg4
    if mainViewVer == 3 then
        backBg4 = cc.Sprite:createWithSpriteFrameName("bg_mainview1.png")
    else
        backBg4 = cc.Sprite:createWithSpriteFrameName("bg_head_mainView.png")
    end
    backBg4:setScale(((MAX_SCREEN_WIDTH / 682) > 2) and (MAX_SCREEN_WIDTH / 682) or 2)
    backBg4:setAnchorPoint(0.5, 1)
    backBg4:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT)
    self:addChild(backBg4, -1)
    self._backBg2 = backBg4

    local foreBg = self:getUI("bg.foreBg")
    foreBg:loadTexture("mainviewfg_1_1.png", 1)
    foreBg:ignoreContentAdaptWithSize(false)
    foreBg:setContentSize(foreBg:getContentSize().width * 1.000, foreBg:getContentSize().height * 1.000)
    local sp = cc.Sprite:createWithSpriteFrameName("mainviewfg_1_2.png")
    self._fgSp2 = sp
    sp:setScale(1.000)
    sp:setAnchorPoint(1, 0)
    sp:setPosition(2730, 0)
    foreBg:addChild(sp)
    bg:setInertiaScrollEnabled(true)
    local midBg = self:getUI("bg.midBg1")
    self._midBgs = {}
    self._maps[#self._maps + 1] = {foreBg, "mainviewfg_1_1.png"}
    for i=1,5 do
        local _bg = self:getUI("bg.midBg".. i)
        _bg:loadTexture("mainviewbg_".. i .. ".png", 1)
        _bg:ignoreContentAdaptWithSize(false)
        _bg:setContentSize(_bg:getContentSize().width * 1.000, _bg:getContentSize().height * 1.000)
        table.insert(self._midBgs,_bg)
        self._maps[#self._maps + 1] = {_bg, "mainviewbg_".. i .. ".png"}
    end
    self._midBgs[6] = self._midBgs[5]
    local _bg = self:getUI("bg.midBg4_5")
    _bg:ignoreContentAdaptWithSize(false)
    _bg:setContentSize(_bg:getContentSize().width * 1.000, _bg:getContentSize().height * 1.000)
    self._midBgs[5] = _bg

    bg:setInnerContainerSize(cc.size(self:getUI("bg.midBg1"):getContentSize().width + 84 + 100, bg:getContentSize().height))
    local gettime = socket.gettime
    local fmod = math.fmod
    local speed = 6
    if not self._scrollSchedule then
        self._scrollSchedule = ScheduleMgr:regSchedule(0.001, self,function()
            if self._beginDrag and self._autoScrollEnable then
                local x = self._bg:getInnerContainer():getPositionX()
                if self._lastScrollX then
                    if math.abs(x - self._lastScrollX) < 0.001 then
                        if self._dragStopTick == nil then
                            self._dragStopTick = os.clock()
                        end
                        if os.clock() > self._dragStopTick + 0.05 then
                            self._dragStopTick = nil
                            self._autoScrollEnable = false
                        end
                    else
                        self._dragStopTick = nil
                    end
                end
                self._lastScrollX = x
            end
            self:adjustMapPos()
            if not self.__isHide then
                -- 背景云彩飘动
                local tick = fmod((gettime() - self._beginTick)*speed, 1363)
                self._backBg.backBg1:setPositionX(tick)
            end
        end)
    end
    self._lastScrollX = bg:getInnerContainer():getPositionX()

    -- 添加主界面动画
    self:addAnim()
end

function MainView:addAnim()

    --[[ 大世界特效换个地方加
    -- 大世界动画
    self:addAnimation2Node("shijie1_mainviewrenwushijie",self:getUI("bottomLayer.instanceBtn"),{zOrder=10,offsetx = -2,offsety=0,scale=1})
    local instanceBtn = self:getUI("bottomLayer.instanceBtn")    
    local clipNode = cc.ClippingNode:create()
    clipNode:setPosition(57,67)
    clipNode:setContentSize(cc.size(122, 127))
    local mask = cc.Sprite:createWithSpriteFrameName("button_more_mainView.png")
    mask:setAnchorPoint(0.5,0.5)
    mask:setScale(1.18)
    clipNode:setStencil(mask)
    clipNode:setAlphaThreshold(0.05)

    local mc = mcMgr:createViewMC("shijie2_mainviewrenwushijie", true,false)
    -- mc:setPosition(-15,-90)
    -- clipNode:setScale(0.5)
    clipNode:addChild(mc)
    instanceBtn:addChild(clipNode,11)
    self:addAnimation2Node("shijie3_mainviewrenwushijie",self:getUI("bottomLayer.instanceBtn"),{zOrder=12,offsetx = -2,offsety=0,scale=1})
    ]]
    -- 任务动画
    local taskBtn = self:getUI("bottomLayer.extendBar.bg.taskBtn")    
    local clipNode = cc.ClippingNode:create()
    clipNode:setPosition(36,34)
    clipNode:setContentSize(cc.size(70, 70))
    local mask = cc.Sprite:createWithSpriteFrameName("button_renwu_mainView.png")
    mask:setAnchorPoint(0.5,0.5)
    mask:setScale(0.9,1)
    clipNode:setStencil(mask)
    clipNode:setAlphaThreshold(0.05)

    local mc = mcMgr:createViewMC("renwusaoguang_mainviewrenwushijie", true,false)
    -- mc:setPosition(-15,-90)
    -- clipNode:setScale(0.5)
    clipNode:addChild(mc)
    taskBtn:addChild(clipNode,11)
    
end

function MainView:onAdd() 
    -- self:showAdView()
    self._bg:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self:showWeekSignView()
    self:adjustMapPos()
    self:scrollIconToCenter("chouka",0,true,0)
    self:cloudAnim()

    -- 这里打一个设备点，再打一个角色点，想减可以得出重复设备
    ApiUtils.playcrab_device_monitor_action("MainView")

    local has = SystemUtils.loadAccountLocalData("MainView2")
    if has == nil or has == "" then
        SystemUtils.saveAccountLocalData("MainView2")
        ApiUtils.playcrab_monitor_action("MainView2", true)
    end
end

function MainView:addBtnFunction(data)    
    local btntitle = data[1]
    local viewname = data[2]
    local systemName = data[3]
    local hideIfUnopen = data[4]
    local param = data[5]
    local btn = self:getUI(btntitle)
    local isBuildingBtn = (string.find(btntitle, "bg.") ~= nil)
    if isBuildingBtn then
        btn.noSound = true
        btn:setScaleAnim(false)
    end
    -- btn:setZoomScale(0.2)
    -- btn:setPressedActionEnabled(true)
    local isOpen = true
    local toBeOpen = true
    if systemName then
        isOpen,toBeOpen = SystemUtils["enable"..systemName]()
    end 
    local showTitle = not (viewname == "" or (not isOpen and not GameStatic.openAllSystem and not toBeOpen))
    local title = btn:getChildByFullName("title")
    if title then
        title:setVisible(showTitle)
    end
    -- print("======================")
    btn:setEnabled(showTitle)
    if (not isOpen or viewname == "" ) and hideIfUnopen then
        btn:setVisible(false)
    else
        btn:setVisible(true)
    end
    if not toBeOpen then
        btn:setVisible(false)
    end
    if isBuildingBtn then
        btn:setCascadeOpacityEnabled(false)
        btn:setOpacity(0)
    end
    self:registerTouchEvent(btn,
        function ()
            if isBuildingBtn then
                btn:stopAllActions()
                btn:setOpacity(50)
                btn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 100), cc.FadeTo:create(0.5, 50))))
            else
                btn:setBrightness(40)
            end
            btn.downSp = btn:getVirtualRenderer()
        end,
        function ()
            if btn.downSp ~= btn:getVirtualRenderer() then
                btn:setBrightness(0)
            end
        end,
        function ()
            if isBuildingBtn then
                btn:stopAllActions()
                btn:setOpacity(0)
            end
            btn:setBrightness(0)
            self._bg:stopScroll()
            -- self:ActionOpen()
            if viewname == "" then
                return
            end
            
            if not isOpen and not GameStatic.openAllSystem then
                if toBeOpen then
                    local systemOpenTip = tab.systemOpen[systemName][3]
                    if not systemOpenTip then
                        self._viewMgr:showTip(tab.systemOpen[systemName][1] .. "级开启")
                    else
                        self._viewMgr:showTip(lang(systemOpenTip))
                    end
                end
            elseif viewname == "godwar.GodWarEntranceView" then
                self._viewMgr:showView(viewname)
            elseif viewname == "guild.join.GuildInView" then
                self._serverMgr:sendMsg("UserServer", "getUserGuildId", {}, true, {}, function(data)
                    local userData = self._userModel:getData()
                    if not userData.guildId or userData.guildId == 0 then
                        self._viewMgr:showView("guild.join.GuildInView", param)
                    else
                        self:checkOpenGuildOrManagerView(param)
                    end
                end)
            elseif viewname == "activity.ActivitySignInView" then
                local redData = {callback = function ( )
                    -- 更新签到红点
                    local isRed = self._modelMgr:getModel("SignModel"):isSignInTip()
                    local icon = self:getUI("rightLayer.signBtn")
                    if isRed then
                        self:addNoticeDot(icon,{pos=cc.p(61,61)})
                    else
                        self:clearNoticeDot(icon)
                    end
                end}
                self._viewMgr:showDialog("activity.ActivitySignInView",redData)
            elseif viewname == "activity.ActivitySevenDaysView" then
                local redData = {callback = function ( )
                    -- 更新七日登陆红点
                    local isRed = self._modelMgr:getModel("ActivitySevenDaysModel"):isSevenDaysTip()
                    local icon = self:getUI("rightLayer.rightBtnLayer.sevenDaysBtn")
                    if isRed then
                        self:addNoticeDot(icon,{pos=cc.p(54,54)})
                    else
                        self:clearNoticeDot(icon)
                    end
                    self:adjustPosition()
                end}

                self._viewMgr:showDialog("activity.ActivitySevenDaysView",redData)
            elseif viewname == "activity.ActivityLevelFeedBackView" then
                local redData = {callback = function ( )
                    -- 更新升有礼红点
                    local isRed = self._modelMgr:getModel("ActivityLevelFeedBackModel"):isLevelFBTip()
                    local icon = self:getUI("rightLayer.rightBtnLayer.levelFBBtn")
                    if isRed then
                        self:addNoticeDot(icon,{pos=cc.p(54,54)})
                    else
                        self:clearNoticeDot(icon)
                    end
                    self:adjustPosition()
                end}
                self._viewMgr:showDialog("activity.ActivityLevelFeedBackView",redData)
            elseif viewname == "activity.ActivityHalfMonthView" then
                local redData = {callback = function ( )                   
                    self:adjustPosition()
                end}

                self._viewMgr:showDialog("activity.ActivityHalfMonthView",redData)
                
                --todo
                -- self._viewMgr:showTip(lang(tab.systemOpen["Guild"][3]))
            -- elseif viewname == "MF.MFView" then
            --     self._viewMgr:showTip("暂未开放")

            elseif viewname == "friend.FriendShopView" then
                local redData = {callback = function ( )                   
                    self:adjustPosition()
                end}

                self._viewMgr:showDialog("friend.FriendShopView",redData)
            elseif viewname == "talent.CollegeView" then
                self._viewMgr:showView("talent.CollegeView", param)
                --[[
                local _,isShow = SystemUtils:enableSkillBook()
                if isShow then
                    self._viewMgr:showView("talent.CollegeView", param)
                else
                    self._viewMgr:showView("talent.TalentView", param)
                end
                -]]
            elseif viewname == "lordmanager.LordManagerView" then
                self._serverMgr:sendMsg("LordManagerServer","getLordManagerData",{},true,{},function ( ... )
                    self._viewMgr:showDialog("lordmanager.LordManagerView")
                end)
            else
                if viewname then
                    self._viewMgr:showView(viewname, param)
                end
            end 

        end,
        function()
            if isBuildingBtn then
                btn:stopAllActions()
                btn:setOpacity(0)
            end
            btn:setBrightness(0)
        end)

    local prix1 = string.sub(btntitle,1,2)
    local prix2 = string.sub(btntitle,9,9)
    local prix3 = string.sub(btntitle,11,string.len(btntitle))
    if prix1 == "bg" and prix3 then
        if prix2 == "g" then
            prix2 = 0
        end
        self._iconPoses[prix3] = {btn, tonumber(prix2)}
    end

    if not isOpen and title and showTitle then
        title:setSaturation(-100)
        local sp = title:getChildByFullName("lockImg") 
        if not sp then 
            local titleTxt = title:getChildByFullName("titleTxt")
            sp = cc.Sprite:createWithSpriteFrameName("main_unlock.png")
            sp:setName("lockImg")
            sp:setPosition(titleTxt:getPositionX() - titleTxt:getContentSize().width/2-sp:getContentSize().width/2,titleTxt:getPositionY())
            title:addChild(sp,5)
        end
    else   
        if title then
            local sp = title:getChildByFullName("lockImg")
            if sp then 
                sp:setVisible(false)
                sp:removeFromParent(true)
            end
            title:setSaturation(0)  
        end
    end
end

--判断是直接打开联盟地图还是直接打开联盟大厅界面
function MainView:checkOpenGuildOrManagerView(param)
    local flag = self._modelMgr:getModel("GuildModel"):getGuildADFristShow()
    local guildAnimLvl = self._modelMgr:getModel("GuildModel"):getAllianceOpenActionLevel()
    if flag == true and guildAnimLvl == 1 then
        -- self._viewMgr:showDialog("activity.ActivitySignInView",redData)
        self._serverMgr:sendMsg("GuildServer", "getGameGuildInfo", {}, true, {}, function (result)
            self._viewMgr:showDialog("guild.manager.GuildManageNewView")
        end)
    else
        self._viewMgr:showView("guild.GuildView", param)
    end
end

function MainView:scrollIconToCenter( btnName,duration,noAnim,x )
    if not self._iconPoses[btnName] then
        return
    end
    self._bg:getInnerContainer():stopAllActions()
    local btn = self._iconPoses[btnName][1]
    local speed = self._iconPoses[btnName][2]
    local width = btn:getContentSize().width
    local pt = btn:convertToWorldSpace(cc.p(0, 0))
    local posX = pt.x + width * btn:getScale() * 0.5
    local offset = self._bg:getInnerContainer():getPositionX() + (MAX_SCREEN_WIDTH * 0.5 - posX) / (1 - _speed[speed])
    offset = offset + x
    if offset > 0 then
        offset = 0
    end
    if offset < -(self._bg:getInnerContainerSize().width-self._bg:getContentSize().width) then
        offset =  -(self._bg:getInnerContainerSize().width-self._bg:getContentSize().width)
    end
    if noAnim then
        self._bg:getInnerContainer():setPositionX(offset)
        self:adjustMapPos()
    else
        self._bg:getInnerContainer():runAction(cc.MoveTo:create(duration or 1,cc.p(offset,0)))
        -- -- if offset < 0 then return end
        -- self._bg:scrollToPercentHorizontal(offset/self._bg:getInnerContainerSize().width*100,duration or 1,true)--offset/self._bg:getInnerContainerSize().width*100
    end
    return iconPos
end

function MainView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView", {types={"Physcal","Gold","Gem"}, hideBtn = true,isAnim = true})
end

function MainView:addNoticeDot(node,param)
    local dot = node:getChildByName("noticeTip")
    if dot then return end
    param = param or {}
    local pos = param.pos or cc.p(60,70)
    local dot 
    if param.mcName then
        dot = self:addAnimation2Node(param.mcName,node,{zOrder=99,x=pos.x,y=pos.y})
        dot:setName("noticeTip")
        dot._mcBg = true
        if param.active then
            self:addActiveBtnAnim(node)
        end
    else
        dot = ccui.ImageView:create()
        dot:loadTexture("globalImageUI_bag_keyihecheng.png", 1)
        dot:setPosition(pos)--node:getContentSize().width,node:getContentSize().height))
        dot:setName("noticeTip")
        node:addChild(dot,99)
    end
    return dot
end

function MainView:clearNoticeDot(node)
    local dot = node:getChildByName("noticeTip")
    if dot then
        dot:removeFromParent()
        if dot._mcBg then
            self:clearActiveBtnAnim(node)
        end
    end
end

-- 积分联赛需要判断发送请求
function MainView:detectLeagueOpen( callback )
    local isOpen,openDes = LeagueUtils:isLeagueOpen(101,true)
    if isOpen then
        if not self._modelMgr:getModel("LeagueModel"):getLeague() then
            ScheduleMgr:nextFrameCall(self,function( )
                ServerManager:getInstance():sendMsg("LeagueServer", "enterLeague", {}, true, {}, function(result)
                    -- 检测红点
                    self._modelMgr:getModel("ActivityModel"):pushUserEvent()
                    self:checkRightUpBtnRed()
                    self._modelMgr:getModel("MainViewModel"):reflashMainView()
                    self:lock(-1)
                    self:unlock()
                    if callback then 
                        callback()
                    end
                end, function (errorCode)
                    if errorCode == 3216 then
                        self._viewMgr:showTip("")
                    end
                end)
            end)
        else
            if callback then 
                callback()
            end
        end
    end
end



--[[
    ontop时先删除主界面的气泡
]]
function MainView:hideQipaoOnTop()
    local mainViewModel = self._modelMgr:getModel("MainViewModel")
    self:removeQipao(mainViewModel:getTipsQipao())
end

function MainView:hadNewBtnInfo( inFirst )

    self:checkDirectShopOpen()
    if self._checkhadNewBtnInfoing then return end
    self._checkhadNewBtnInfoing = true
    ScheduleMgr:delayCall(100, self, function()
        if self._hadNewBtnInfo == nil then return end
        self:_hadNewBtnInfo(inFirst)
        self._checkhadNewBtnInfoing = false
    end)
end

function MainView:_hadNewBtnInfo(inFirst)
    self:adjustPosition() 
    -- 判断新邮件 
    if #self._noticeMap == 0 then
        -- local mailBtn = self:getUI("topLayer.mailBtn")
        -- local posX,posY = mailBtn:getPosition()

        local noticeMap = {
            -- 背包
            {iconName = "bottomLayer.extendBar.bg.bagBtn",pos =cc.p(65,66),detectFuc = function( )
                return self._modelMgr:getModel("ItemModel"):haveNoticeItem()
            end},
            -- 布阵
            {iconName = "bottomLayer.extendBar.bg.formationBtn",pos =cc.p(63,65),detectFuc = function( )
                return not self._modelMgr:getModel("FormationModel"):isCommonFormationTeamFull()
                        or self._modelMgr:getModel("FormationModel"):isHaveWeaponCanLoaded(1) 
            end},
            -- 兵团
            {iconName = "bottomLayer.extendBar.bg.monsterBtn",pos =cc.p(65,65),detectFuc = function( )
                return self._modelMgr:getModel("TeamModel"):isNoticeMainTip()
            end},
             -- 英雄
            {iconName = "bottomLayer.extendBar.bg.heroBtn",pos =cc.p(65,65),detectFuc = function( )
                return self._modelMgr:getModel("HeroModel"):isHeroRedTagShow()
            end},
             -- 宝物
            {iconName = "bottomLayer.extendBar.bg.treasureBtn",pos =cc.p(65,65),detectFuc = function( )
                return self._modelMgr:getModel("TreasureModel"):havePromoteTreasure()
            end},
            --圣徽
            {
            iconName = "bottomLayer.extendBar.bg.holyBtn", pos = cc.p(65,65), detectFuc = function()
                return self._modelMgr:getModel("TeamModel"):isShowHolyRedPoint()
            end},
             -- 任务
            {iconName = "bottomLayer.extendBar.bg.taskBtn",pos =cc.p(65,65),detectFuc = function( )
                return self._modelMgr:getModel("TaskModel"):hasTaskCanGet()
            end},

            {iconName = "bottomLayer.extendBar.bg.privilegeBtn",pos =cc.p(65,65),detectFuc = function( )
                return self._modelMgr:getModel("PrivilegesModel"):havePrivilegeTip() -- getNoticeMap()["PrivilegesView"]
            end},
            -- vip
            -- {iconName = "rightLayer.chargeBtn",pos = cc.p(61,61),mcName = "mianfeizuanshi_mainviewanim",active=true,pos = cc.p(45,75),detectFuc = function( )
            --     return self._modelMgr:getModel("VipModel"):isFreeGemGet()
            -- end},
           
            {iconName = "rightLayer.activityCommonBtn",pos =cc.p(61,61),detectFuc = function( )
                return self._modelMgr:getModel("ActivityModel"):hasActivityTaskCanGet()
            end},
            --[[
            -- 主建筑
            -- MAIN_JITAN 抽卡
            {iconName = "bg.midBg1.chouka.title",pos =cc.p(110,20),detectFuc = function( )
                return self._modelMgr:getModel("TeamModel"):isCardFree()
            end},
            -- MAIN_MOFAHANGHUI 学院
            {iconName = "bg.midBg1.mana.title",pos =cc.p(110,20),detectFuc = function( )
                return false
            end},
            -- MAIN_SHICHANG 商店
            {iconName = "bg.midBg1.market.title",pos =cc.p(110,20),detectFuc = function( )
                return self._modelMgr:getModel("ShopModel"):treasureFreeDrawCount( )
            end},
            -- MAIN_GUOHUI 国会
            {iconName = "bg.midBg2.congress.title",pos =cc.p(110,20),detectFuc = function( )
                return self._modelMgr:getModel("GuildModel"):isGuildTip()
            end},
            -- -- MAIN_DAYE 打野
            -- {iconName = "bg.midBg2.bar.title",pos =cc.p(110,20),detectFuc = function( )
            --     return false
            -- end},
            -- MAIN_DABENYING 大本营
            {iconName = "bg.midBg4.home.title",pos =cc.p(110,20),detectFuc = function( )
                local pokedexModel = self._modelMgr:getModel("PokedexModel")
                return pokedexModel:getPokedexFangzhi()
            end},
            -- MAIN_ZHANSHENXIANG 战神像
            {iconName = "bg.midBg3.pve.title",pos =cc.p(110,20),detectFuc = function( )
                local formationModel = self._modelMgr:getModel("FormationModel")
                local formationFull = formationModel:isFormationTeamFullByType(formationModel.kFormationTypeArenaDef)
                local haveReward = self._modelMgr:getModel("ArenaModel"):haveAward()
                return formationFull or haveReward
            end},
            -- MAIN_ZHANYI 战役
            {iconName = "bg.midBg4.yuanzheng.title",pos =cc.p(110,20),detectFuc = function( )
                return self._modelMgr:getModel("CrusadeModel"):checkIsRedPoint()
            end},
            -- MAIN_CHUANWU 船坞
            {iconName = "bg.midBg4.chuanwu.title",pos =cc.p(110,20),detectFuc = function( )
                return self._modelMgr:getModel("MFModel"):isMFTip()
            end},
            -- MAIN_YUNZHONGCHENG 云中城
            {iconName = "bg.midBg5.cloudCity.title",pos =cc.p(110,20),detectFuc = function( )
                return self._modelMgr:getModel("BossModel"):getHasNotice()
            end},
        --]] 
        }
        self._noticeMap = noticeMap
    end 
    -- 邮件
    local mailBtn = self:getUI("topLayer.mailBtn")
    local mailBtnBg = mailBtn:getChildByName("mailBtnBg")
    local mailBtnTip
    if mailBtnBg then
        mailBtnTip = mailBtnBg:getChildByName("mailBtnTip")
    end
    local haveNewMail = self._modelMgr:getModel("MailBoxModel"):haveNewMail()
    -- print("haveNewMail===================",haveNewMail, tonumber(haveNewMail))
    if tonumber(haveNewMail) == 0 then
        if mailBtnBg then
            mailBtnBg:setVisible(false)
        end
    else
        -- print("我是一个神奇的", haveNewMail, type(haveNewMail))
        if mailBtnBg and mailBtnTip then
            mailBtnBg:setVisible(true)
            if haveNewMail > 99 then
                mailBtnTip:setString("99+")
            else
                mailBtnTip:setString(haveNewMail)
            end
        else
            if not mailBtnBg then
                mailBtnBg = cc.Sprite:createWithSpriteFrameName("globalImageUI6_tipBg.png")
                mailBtnBg:setAnchorPoint(cc.p(0.5,0.5))
                mailBtnBg:setName("mailBtnBg")
                mailBtnBg:setPosition(cc.p(mailBtn:getContentSize().width-10,mailBtn:getContentSize().height-10))
                mailBtn:addChild(mailBtnBg)
            end
            if not mailBtnTip then
                mailBtnTip = cc.Label:createWithTTF(haveNewMail, UIUtils.ttfName, 18)
                mailBtnTip:setName("mailBtnTip")
                mailBtnTip:setColor(UIUtils.colorTable.ccUIBaseColor1)
                -- mailBtnTip:enableOutline(cc.c4b(105,32,0,255), 2)
                mailBtnTip:setAnchorPoint(cc.p(0.5,0.5))
                mailBtnTip:setPosition(mailBtnBg:getContentSize().width * 0.5, mailBtnBg:getContentSize().height * 0.5 + 1)
                mailBtnBg:addChild(mailBtnTip)
            end
            if haveNewMail > 99 then
                mailBtnTip:setString("99+")
            else
                mailBtnTip:setString(haveNewMail)
            end
        end
    end

    -- {iconName = "topLayer.mailBtn",pos = cc.p(63,50),detectFuc = function( )
    --     return self._modelMgr:getModel("MailBoxModel"):haveNewMail()
    -- end},

    self._modelMgr:getModel("MFModel"):isMFTip()
    -- print ("======MFModelMFModelMFModelMFModelMFModelMFModel===================")


    local activityBtn = self:getUI("rightLayer.rightBtnLayer.activityBtn")
    if activityBtn then
        activityBtn:setVisible(self._modelMgr:getModel("ActivityModel"):hasActivityOpen())
    end 
    local noticeMap = self._noticeMap
    for k,noticeD in pairs(noticeMap) do
        -- ScheduleMgr:delayCall(k*40, self, function( )
        --     if not self.addNoticeDot then return end
            local icon = self:getUI(noticeD.iconName)
            local haveNotice = noticeD.detectFuc()
            if haveNotice then
                self:addNoticeDot(icon,noticeD)
            else
                self:clearNoticeDot(icon)
            end
        -- end)
    end

    local userInfo = self._modelMgr:getModel("UserModel"):getData()

    if userInfo.lvl >= 5 and inFirst ~= false then
        -- local seq = cc.Sequence:create(cc.DelayTime:create(0.02),cc.CallFunc:create(function()
        -- end))
        -- self:runAction(seq)
        -- ScheduleMgr:delayCall(90, self, function( )
            if not self.showAdView then return end
            self:setQipao()
        -- end)
    end

    -- if inFirst ~= false then
    --     ScheduleMgr:delayCall(110, self, function( )
    --         if not self.showAdView then return end
    --         if self._modelMgr:getModel("MainViewModel"):getActionTimeOpen() == true then
    --             self._modelMgr:getModel("MainViewModel"):setActionTimeOpen(false)
    --         else
    --             if self._inFirst ~= false then
    --                 self:showAdView() 
    --             end
    --             self._inFirst = true
    --         end
    --     end)
    -- end
    -- -- 刚登录游戏不走此方法
    -- if inFirst == false then
    --     -- 新功能开启动画
    --     -- self._modelMgr:getModel("MainViewModel"):isOpenShowNotice()
    --     local tempNoticeId = self._modelMgr:getModel("MainViewModel"):isOpenShowNotice(true)
    --     local actionFlag = self._modelMgr:getModel("MainViewModel"):getActionOpen()
    --     if actionFlag then
    --         self:actionOpen()
    --         self._modelMgr:getModel("MainViewModel"):clearActionOpen()
    --     end
    -- end

    -- self:adjustPosition()  
    -- self:updateCarnivalState()  

    -- 更新右上角按钮红点 （popView）
    self:checkRightUpBtnRed()

    self:checkExpExchangeOpen()
end

function MainView:newActionOpen()
    if self._modelMgr:getModel("MainViewModel"):getActionTimeOpen() == true then
        self._modelMgr:getModel("MainViewModel"):setActionTimeOpen(false)
    else
        if self._inFirst ~= false and (not self._isInWeekSign) and self._isCloseAd == true then
            self:showAdView() 
        else
            self:checkCrossGodWarInvitation()
        end
        self._inFirst = true
    end
end

function MainView:checkDirectShopOpen()
    local directShopBtn = self:getUI("rightLayer.directShopBtn")
    local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl
    local openDay = math.floor(self._modelMgr:getModel("UserModel"):getOpenServerTime()/86400)
    if not directShopBtn:isVisible() then
        if openDay >= DirectShopOpenNeedDay and userlvl >= 23 then
            directShopBtn:setVisible(true)
        end
    end

    if not self._user_lv then
        self._user_lv = userlvl
    end

    -----------------玩家升级,刷新直购红点
    if userlvl and self._user_lv then
        if userlvl > self._user_lv then
            if openDay >= DirectShopOpenNeedDay and userlvl >= 23 then
                local directModel = self._modelMgr:getModel("DirectShopModel")
                directModel:setServerDataStatus(true)
                self:checkDirectRed()
            end
            self._user_lv = userlvl
        end
    end

    --------------------过五点,刷新直购红点---
    local directModel = self._modelMgr:getModel("DirectShopModel")
    local open_day = directModel:getOpenDay()
    if not open_day then
        open_day = openDay
        directModel:setOpenDay(openDay)
    end

    if open_day and openDay then
        if open_day ~= openDay then
            if openDay >= DirectShopOpenNeedDay and userlvl >= 23 then
                local directModel = self._modelMgr:getModel("DirectShopModel")
                directModel:setServerDataStatus(true)
                directModel:cleanRedStatus()
                self:checkDirectRed(true)
            end
            directModel:setOpenDay(openDay)
        end
    end

end

-- 延迟合并
function MainView:checkRightUpBtnRed()
    if self._checkRightUpBtnReding then return end
    self._checkRightUpBtnReding = true
    ScheduleMgr:delayCall(200, self, function()
        if self._checkRightUpBtnRed == nil then return end
        self:_checkRightUpBtnRed()
        self._checkRightUpBtnReding = false
    end)
end

function MainView:_checkRightUpBtnRed()   
    -- print("===================checkRightUpBtnRed==================") 
    if #self._noticeMap2 == 0 then
        -- local mailBtn = self:getUI("topLayer.mailBtn")
        -- local posX,posY = mailBtn:getPosition()
        self._noticeMap2 = {
           
            -- 签到
            {iconName = "rightLayer.signBtn",pos =cc.p(61,61),detectFuc = function( )
                return self._modelMgr:getModel("SignModel"):isSignInTip()
            end},
            {iconName = "rightLayer.rightBtnLayer.levelFBBtn",pos =cc.p(54,54),detectFuc = function( )
                return self._modelMgr:getModel("ActivityLevelFeedBackModel"):isLevelFBTip()
            end},
            {iconName = "rightLayer.rightBtnLayer.sevenDaysBtn",pos =cc.p(54,54),detectFuc = function( )
                return self._modelMgr:getModel("ActivitySevenDaysModel"):isSevenDaysTip()
            end},
            --嘉年华
            {iconName = "rightLayer.rightBtnLayer.activityCarnivalBtn",pos =cc.p(54,54),detectFuc = function( )
                return self._modelMgr:getModel("ActivityCarnivalModel"):showNoticeMap()
            end},
            -- {iconName = "rightLayer.rightBtnLayer.halfMonthBtn",pos =cc.p(54,54),detectFuc = function( )
            --     return self._modelMgr:getModel("ActivityHalfMonthModel"):isHalfMonthTip()
            -- end},
            {iconName = "rightLayer.rightBtnLayer.acAdventureBtn",pos =cc.p(54,54),detectFuc = function( )
                return self._modelMgr:getModel("AdventureModel"):haveNoticeDot()
            end},    
            --VIP推送
            {iconName = "rightLayer.rightBtnLayer.vipBtn",pos =cc.p(54,54),detectFuc = function( )
                return self._modelMgr:getModel("VipModel"):haveCanGetGift()
            end},      
        }

    end 

    for k,noticeD in pairs(self._noticeMap2) do
        -- ScheduleMgr:delayCall(k*31, self, function( )
        --     if not self.addNoticeDot then return end
            local icon = self:getUI(noticeD.iconName)
            local haveNotice = noticeD.detectFuc()
            -- print(noticeD.iconName,"======================haveNotice=====",haveNotice)
            if haveNotice then
                self:addNoticeDot(icon,noticeD)
            else
                self:clearNoticeDot(icon)
            end
        -- end)
    end
    local carnivalModel = self._modelMgr:getModel("ActivityCarnivalModel")
    carnivalModel:doUpdate()

    local acUltimateModel = self._modelMgr:getModel("AcUltimateModel")  
    acUltimateModel:doUpdate()
end

--初始化右侧活动按钮
function MainView:initExtendRightBtn( )
    
    -- 右侧活动按钮
    self._extendBtnRight = self:getUI("rightLayer.extendBtn")
    local redImg = self:addNoticeDot(self._extendBtnRight,{pos=cc.p(0,0)})    
    redImg:setVisible(false)
    self._rightBtnLayer = self:getUI("rightLayer.rightBtnLayer")
    self._rightBtnLayer:setSwallowTouches(false)

    self._extendRightBtnIsShow = true  -- SystemUtils.loadAccountLocalData("mainView_acBtnIsShow")
    -- 默认打开
    -- if self._extendRightBtnIsShow == nil then
    --     self._extendRightBtnIsShow = true 
    --     SystemUtils.saveAccountLocalData("mainView_acBtnIsShow", true)
    -- end
    self:registerClickEvent(self._extendBtnRight, function ()
        SystemUtils.saveAccountLocalData("mainView_acBtnIsShow", not self._extendRightBtnIsShow)
        self:doExtendBarAnimRight()
    end)

    self._orderRightBtnNum = 7    --一行可以放七个按钮

    -- 展示右侧面板图标顺序
    self._orderRightBtn = {
        [1]={uiname="rightLayer.rightBtnLayer.wroldBossBtn"},
        [2]={uiname="rightLayer.rightBtnLayer.firstChargeBtn"},
        [3]={uiname="rightLayer.rightBtnLayer.chargePresentBtn"},
        [4]={uiname="rightLayer.rightBtnLayer.limitTeamBtn"},
        [5]={uiname="rightLayer.rightBtnLayer.fightDragonBtn"},
        [6]={uiname="rightLayer.rightBtnLayer.sevenDaysBtn"},
        [7]={uiname="rightLayer.rightBtnLayer.activityCarnivalBtn"},
        [8]={uiname="rightLayer.rightBtnLayer.levelFBBtn"},
        [9]={uiname="rightLayer.rightBtnLayer.acAdventureBtn"},
        [10]={uiname="rightLayer.rightBtnLayer.luckStarBtn"},
        [11]={uiname="rightLayer.rightBtnLayer.vipBtn"},
        [12]={uiname="rightLayer.rightBtnLayer.celebrationBtn"},
        -- [11]={uiname="rightLayer.rightBtnLayer.backflowBtn"},   -- 不放在list里了
        [13]={uiname="rightLayer.rightBtnLayer.qqActivityBtn"},
        [14]={uiname="rightLayer.rightBtnLayer.tehuiActivityBtn"},
        [15]={uiname="rightLayer.rightBtnLayer.activityBtn"},
        [16]={uiname="rightLayer.rightBtnLayer.lichBuyGiftBtn"},
        [17]={uiname="rightLayer.rightBtnLayer.oneChargeBtn"},
        [18]={uiname="rightLayer.rightBtnLayer.trainAcBtn"},
        [19]={uiname="rightLayer.rightBtnLayer.powerGameBtn"},
        [20]={uiname="rightLayer.rightBtnLayer.recallAcBtn"},
        [21]={uiname="rightLayer.rightBtnLayer.luckTulingBtn"},
        [22]={uiname="rightLayer.rightBtnLayer.limitAwakenBtn"},
        [23]={uiname="rightLayer.rightBtnLayer.happyPopBtn"},
        [24]={uiname="rightLayer.rightBtnLayer.sprRedBtn"},
        [25]={uiname="rightLayer.rightBtnLayer.luckyLotteryBtn"},
        [26]={uiname="rightLayer.rightBtnLayer.worldCupBtn"},
        [27]={uiname="rightLayer.rightBtnLayer.ultimateBtn"},
        [28]={uiname="rightLayer.rightBtnLayer.growthwayBtn"},
        [29]={uiname="rightLayer.rightBtnLayer.limitPrayBtn"},
        
    }

    local mainiconwhitelist = tab.mainiconwhitelist
    for k,v in pairs(self._orderRightBtn) do
        local btn = self:getUI(v.uiname)
        btn:setVisible(false)
        local tableData = mainiconwhitelist[tonumber(k)]
        v.important = 0
        v.weight = 0
        v.id = tonumber(k)
        btn.isHaveShow = true  -- 初始状态都是被展示过的按钮
        btn.id = tonumber(k)
        if tableData then
            v.important = tableData.important or 0
            v.weight = tableData.weight or 0
        end
    end

    table.sort(self._orderRightBtn,function(a, b)
        if a.weight ~= b.weight then
            return a.weight > b.weight
        else
            return a.id < b.id
        end
    end)
end


--[[
--! @function adjustPosition
--! @desc 动态调整活动图标位置
--! @param 
--! @return 
--]]
function MainView:adjustPosition()

    self._extendBtnRight:setTouchEnabled(true)

    local iconW = 80
    local count = 0
    local btn
    local tempRightBtn1 = {}
    local tempRightBtn2 = {}
    -- 常驻按钮 = self._btnNum1 - self._newBtnNum1
    self._btnNum1 = 0       --新开启 + 常驻
    self._btnNum2 = 0       --新开启 + 常驻
    self._extendBtnIsRed = false
    for i = 1, #self._orderRightBtn do
        btn = self:getUI(self._orderRightBtn[i].uiname)
        if btn:isVisible() then                      
            count = count + 1
            if count <= self._orderRightBtnNum then
                if self._orderRightBtn[i].important ~= 0 then
                    self._btnNum1 = self._btnNum1 + 1
                else
                    -- 判断展开按钮是否有红点
                    if not self._extendBtnIsRed then
                        local dot = btn:getChildByName("noticeTip")
                        if dot and dot:isVisible() then
                            self._extendBtnIsRed = true
                        end
                    end
                end
                -- tempRightBtn1[btn.id] = btn
                table.insert(tempRightBtn1,btn)
            else
                if self._orderRightBtn[i].important ~= 0 then
                    self._btnNum2 = self._btnNum2 + 1
                else
                    -- 判断展开按钮是否有红点
                    if not self._extendBtnIsRed then
                        local dot = btn:getChildByName("noticeTip")
                        if dot and dot:isVisible() then
                            self._extendBtnIsRed = true
                        end
                    end
                end
                table.insert(tempRightBtn2,btn)
                -- tempRightBtn2[btn.id] = btn
            end
        end
    end
    self._orderRightBtn1 = clone(tempRightBtn1)
    self._orderRightBtn2 = clone(tempRightBtn2)

    local _btnNum1 = table.nums(self._orderRightBtn1)      -- 第一行btn数
    local _btnNum2 = table.nums(self._orderRightBtn2)      -- 第二行btn数
    local num = _btnNum1 > self._orderRightBtnNum and self._orderRightBtnNum or _btnNum1
    local layerW = num * iconW
    self._rightBtnLayer:setContentSize(layerW,180)
    self._rightBtnLayer:setPosition(-1*layerW + 10, 380)
    self._extendBtnRight:setVisible(_btnNum1 >= 3)
    -- 展开按钮添加红点
    local extendDot = self._extendBtnRight:getChildByName("noticeTip")
    if extendDot then
        extendDot:setVisible(self._extendBtnIsRed and not self._extendRightBtnIsShow)
    end

    local x1 = iconW * 0.5 --+ (self._orderRightBtnNum - _btnNum1) * iconW
    local y1 = 140
    local x2 = iconW * 0.5 --+ (self._orderRightBtnNum - _btnNum2) * iconW
    local y2 = 60


    local offsetX1 = 0
    local offsetX2 = layerW - _btnNum2 * iconW
    -- 处于隐藏状态
    if not self._extendRightBtnIsShow then
       offsetX1 = layerW - self._btnNum1 * iconW
       offsetX2 = layerW - self._btnNum2 * iconW
    end
    self._extendBtnRight:setPosition(-1*layerW - 10 + offsetX1, 512)
    self._extendBtnRight:setFlippedY(not self._extendRightBtnIsShow)
    self._extendBtnRight._subDis = (_btnNum1 - self._btnNum1)*iconW

    -- local  notShowNum = 0
    for k,v in ipairs(self._orderRightBtn1) do
        v:setPosition(x1+offsetX1, y1)
        v._subDis = (_btnNum1 - self._btnNum1)*iconW
        x1 = x1 + iconW 
    end

    -- notShowNum = 0
    for k,v in ipairs(self._orderRightBtn2) do
        v:setPosition(x2+offsetX2, y2)
        v._subDis = (_btnNum2 - self._btnNum2)*iconW
        x2 = x2 + iconW 
    end

    local extendAnim = false
    if self._lastExtendRightCount ~= count then
        self._lastExtendRightCount = count
        extendAnim = true
    end
end

function MainView:doExtendBarAnimRight()
    if self._extendRightAniming then return end
    self._extendRightBtnIsShow = not self._extendRightBtnIsShow
    self._extendBtnIsRed = false
    self._extendBtnRight:setTouchEnabled(false)
    local extendBtnX = self._extendBtnRight:getPositionX()
    local btn
    if not self._extendRightBtnIsShow then
        self._extendBtnRight:setFlippedY(true)
        local btn, x, y
        for i = 1, #self._orderRightBtn do
            btn = self:getUI(self._orderRightBtn[i].uiname)
            local disX = btn._subDis or 0
            btn:setTouchEnabled(false)
            btn:stopAllActions()
            if btn:isVisible() then
                local dot = btn:getChildByName("noticeTip")
                if dot and dot:isVisible() and self._orderRightBtn[i] and self._orderRightBtn[i].important == 0 then
                    self._extendBtnIsRed = true
                end
                x = btn:getPositionX()
                y = btn:getPositionY()
                btn:runAction(cc.MoveTo:create(0.15, cc.p(x+disX , y)))
            end
        end
        self._extendBtnRight:runAction(cc.Sequence:create(cc.DelayTime:create(0.05),
            cc.MoveTo:create(0.15, cc.p(self._extendBtnRight:getPositionX()+self._extendBtnRight._subDis, self._extendBtnRight:getPositionY()))))     
    else
        self._extendBtnRight:setFlippedY(false)
        local btn, x, y
        for i = 1, #self._orderRightBtn do
            btn = self:getUI(self._orderRightBtn[i].uiname)
            local disX = btn._subDis or 0 
            btn:setTouchEnabled(false)
            btn:stopAllActions()
            if btn:isVisible() then
                local dot = btn:getChildByName("noticeTip")
                if dot and dot:isVisible() and self._orderRightBtn[i] and self._orderRightBtn[i].important == 0 then
                    self._extendBtnIsRed = true
                end
                x = btn:getPositionX()
                y = btn:getPositionY()
                btn:runAction(cc.MoveTo:create(0.15, cc.p(x-disX, y )))
            end
        end 
        self._extendBtnRight:runAction(cc.MoveTo:create(0.15, cc.p(self._extendBtnRight:getPositionX()-self._extendBtnRight._subDis, self._extendBtnRight:getPositionY())))    
    end

    local extendDot = self._extendBtnRight:getChildByName("noticeTip")
    if extendDot then
        extendDot:setVisible(self._extendBtnIsRed and not self._extendRightBtnIsShow)
    end
    self._extendRightAniming = true
    ScheduleMgr:delayCall(500, self, function()
        if self._orderRightBtn and self._extendBtnRight then
            for i = 1, #self._orderRightBtn do
                self:getUI(self._orderRightBtn[i].uiname):setTouchEnabled(true)
            end        
            self._extendBtnRight:setTouchEnabled(true)
            self._extendRightAniming = false
        end
    end)
end

-- --[[
-- --! @function handlerHalfMonthAct
-- --! @desc 半月活动开启状态
-- --! @param 
-- --! @return 
-- --]]
-- function MainView:handlerHalfMonthAct()
--     local halfMonthModel = self._modelMgr:getModel("ActivityHalfMonthModel")
--     local halfMonthData = halfMonthModel:getData()
   
--     local halfMonthBtn = self:getUI("rightLayer.rightBtnLayer.halfMonthBtn")
--     print("halfMonthData.isFinish====", halfMonthData.isFinish)

--     if halfMonthData.isFinish > 0 then 
--         halfMonthBtn:setVisible(false)
--         return
--     end

--     halfMonthBtn:setVisible(true)
-- end

--恢复登录奖励倒计时  wangyan
function MainView:resumeDaysTimeCount()
    local sevenDaysBtn = self:getUI("rightLayer.rightBtnLayer.sevenDaysBtn")
    if sevenDaysBtn.showDay then    
        sevenDaysBtn.showDay = nil
    end
    self:handlerSevenDaysAndLevelFBAct()
end

--[[
--! @function handlerSevenDaysAndLevelFBAct
--! @desc 七日与等级回馈图标状态
--! @param 
--! @return 
--]]
function MainView:handlerSevenDaysAndLevelFBAct()
    local userModel = self._modelMgr:getModel("UserModel")
    local userInfo = userModel:getData()
    local curTime = userModel:getCurServerTime()
    local levelFBBtn = self:getUI("rightLayer.rightBtnLayer.levelFBBtn")

    -- self._modelMgr:getModel("ActivityLevelFeedBackModel"):getTimeOut()
    local levelFBData = self._modelMgr:getModel("ActivityLevelFeedBackModel"):getData()
    if levelFBData.isFinish > 0  then 
        levelFBBtn:setVisible(false)
        self:adjustPosition()
    end
    local sevenDaysBtn = self:getUI("rightLayer.rightBtnLayer.sevenDaysBtn")
    local sevenDaysModel = self._modelMgr:getModel("ActivitySevenDaysModel")
    local sevenDaysData = sevenDaysModel:getData()
    if sevenDaysData.isFinish > 0 then 
        sevenDaysBtn:stopAllActions()
        sevenDaysBtn:setVisible(false)        
        -- self:handlerHalfMonthAct()
        self:adjustPosition()
        return
    end
    -- local halfMonthBtn = self:getUI("rightLayer.rightBtnLayer.halfMonthBtn")
    -- halfMonthBtn:setVisible(false)
    self:adjustPosition()
    -- print("halfMonthBtn==============false")

    local tipTextState = {1,2,2,1,1,1,2}
    local icons = {"button_sevenDays_mainView.png", 
                    "button_sevenDays3_mainView.png",
                    "button_sevenDays1_mainView.png",
                    "button_sevenDays_mainView.png",
                    "button_sevenDays_mainView.png",
                    "button_sevenDays_mainView.png",
                    "button_sevenDays2_mainView.png",
                    "button_sevenDays_mainView.png",
                    "button_sevenDays_mainView.png",
                    "button_sevenDays_mainView.png",
                    "button_sevenDays_mainView.png",
                    "button_sevenDays_mainView.png",
                    "button_sevenDays_mainView.png",
                    "button_sevenDays_mainView.png"}
    local loginDay = 0
    if userInfo.statis then
        loginDay = userInfo.statis.snum6 or 0
    end
    if loginDay > 14 then 
        loginDay = 14
    end
    -- local showDay = 0
    -- local showTextState = 1
    local showDay, showTextState = sevenDaysModel:getShowDayAndState()
    -- local flag = 0 
    -- for i=1,7 do
    --     if loginDay > i and sevenDaysData[tostring(i)] == nil then 
    --         flag =  1
    --     end
    -- end
    -- if flag == 0 then 
    --     -- 如果当前登录天数已经领取则展示下一天状态
    --     if sevenDaysData[tostring(loginDay)] ~= nil and loginDay ~= 7 then 
    --         showDay = loginDay + 1
    --         showTextState = tipTextState[showDay]
    --     elseif loginDay == 1 and sevenDaysData[tostring(loginDay)] == nil then 
    --         showDay = 1
    --         showTextState = tipTextState[showDay]
    --     end
    -- end
    -- -- 如果当前登录天数未领取则按顺序展现
    -- if showDay == 0 then 
    --     local showDayOrder = {2, 3, 7, 1, 4, 5, 6}
    --     for k,v in pairs(showDayOrder) do
    --         if sevenDaysData[tostring(v)] == nil then 
    --             if loginDay >= v then 
    --                 showDay = v
    --                 showTextState = 1
    --             end
    --             if showDay ~= 0 then 
    --                 break
    --             end
    --         end
    --     end
    -- end
    if showDay == 0 then 
        if sevenDaysBtn.timeLab ~= nil then 
            sevenDaysBtn.timeLab:stopAllActions()
        end
        sevenDaysBtn:setVisible(false)
        self:adjustPosition()
        return
    end
    if sevenDaysBtn.showDay ~= showDay then 
        sevenDaysBtn.showDay = showDay
        sevenDaysBtn:loadTexturePressed(icons[showDay], 1)
        sevenDaysBtn:loadTextureNormal(icons[showDay], 1)

        if sevenDaysBtn.label == nil then 
            createUpBtnTitleLabel(self:getUI("rightLayer.rightBtnLayer.sevenDaysBtn"), lang("MAIN_DENGLUJIANGLI"), 0, 0,16)
            sevenDaysBtn.label = sevenDaysBtn:getChildByTag(31555)
        end

        sevenDaysBtn.label:setString(lang("MAIN_DENGLUJIANGLI"))
        
        if sevenDaysBtn.timeLab ~= nil then 
            sevenDaysBtn.timeLab:stopAllActions()
        end
        if showTextState ~= 1 then 
            if sevenDaysBtn.timeLab == nil then 
                local timeLab = cc.Label:createWithTTF("", UIUtils.ttfName, 16)
                timeLab:setColor(cc.c3b(57, 250, 0))
                timeLab:setAnchorPoint(0.5, 1)
                timeLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
                timeLab:setPosition(sevenDaysBtn:getContentSize().width/2, -7)
                sevenDaysBtn:addChild(timeLab, 10001)
                sevenDaysBtn.timeLab = timeLab
                -- local timeBg = cc.Sprite:createWithSpriteFrameName("globalImageUI_jianbianBg.png")
                -- timeBg:setScale(0.25)
                -- timeBg:setOpacity(200)
                -- timeBg:setPosition(sevenDaysBtn:getContentSize().width/2, 26)
                -- sevenDaysBtn:addChild(timeBg, 10000)
                sevenDaysBtn.timeBg = timeBg
            end
            sevenDaysBtn.timeLab:setVisible(true)
            -- sevenDaysBtn.timeBg:setVisible(true)
            sevenDaysBtn.timeLab:setString("00:00")
            local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
            local nextDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime + 86400,"%Y-%m-%d 05:00:00"))
            local tempDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
            if tempDayTime > curServerTime  then 
                nextDayTime = tempDayTime
            end
            local repAction = cc.RepeatForever:create(
                        cc.Sequence:create(cc.CallFunc:create(
                            function()
                                local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
                                if (nextDayTime - curServerTime) < 0  then
                                    sevenDaysBtn.timeLab:setVisible(false)
                                    -- sevenDaysBtn.timeBg:setVisible(false) 
                                    sevenDaysBtn.timeLab:stopAllActions()
                                    self:handlerSevenDaysAndLevelFBAct()
                                    self:adjustPosition()
                                    return
                                end
                                -- local nextDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime + 86400,"%Y-%m-%d 05:00:00"))
                                -- sevenDaysBtn.timeLab:setString(TimeUtils.getTimeStringHMS(nextDayTime - curServerTime))
                                -- timeTime = timeTime - 1 
                                local hour ,min,sec = TimeUtils.getTimeStringSplitHMS(nextDayTime - curServerTime)
                                -- print("==========================",hour,min,sec)
                                local str = ""
                                if tonumber(hour) ~= 0 then
                                    str = hour .. "h" .. "后可领"
                                elseif tonumber(min) ~= 0 then
                                    str = min .. "m" .. "后可领"
                                else
                                    str = sec .. "s" .. "后可领"
                                end
                                sevenDaysBtn.timeLab:setString(str)
                            end),
                        cc.DelayTime:create(1)
                    )
                )
            sevenDaysBtn.timeLab:runAction(repAction)
        else
            if sevenDaysBtn.timeLab ~= nil then 
                sevenDaysBtn.timeLab:setVisible(false)
                -- sevenDaysBtn.timeBg:setVisible(false)
                sevenDaysBtn.timeLab:stopAllActions()
                self:adjustPosition()
            end
        end
 
        
    end
end
-- 主界面动画管理
function MainView:addActiveBtnAnim( node )
    if type(node) == "string" then
        node = self:getUI(node)
    end
    self:addAnimation2Node("shangcengguangdian_mainviewanim",node,{scale=0.7,copy=true})
    self:addAnimation2Node("diguang_mainviewanim",node,{zOrder=-1,copy=true})

end
function MainView:clearActiveBtnAnim( node )
    if type(node) == "string" then
        node = self:getUI(node)
    end
    node:removeChildByName("shangcengguangdian_mainviewanim")
    node:removeChildByName("diguang_mainviewanim")
end
-- 
function MainView:addAnimation2Node( name,node,param )
    if type(node) == "string" then
        node = self:getUI(node)
    end
    param = param or {}
    local x,y = param.x or node:getContentSize().width/2,param.y or node:getContentSize().height/2
    local offX,offY = param.offsetx or 0,param.offsety or 0
    local zOrder = param.zOrder or 0
    local endCallback = param.endCallback
    local speed = param.speed 
    local scale = param.scale or 1
    local opacity = param.opacity
    local notSingle = param.copy 

    local mc = mcMgr:createViewMC(name, true,false,nil,param.pixelFormat)
    mc:setPosition(x+offX, y+offY)
    mc:setScale(scale)
    node.__buildMc = mc
    if opacity then
        mc:setCascadeOpacityEnabled(true, true)
        mc:setOpacity(opacity)
    end
    if speed then
        mc:setPlaySpeed(speed,true)
    end
    if endCallback then
        mc:addEndCallback(function (_, sender)
            endCallback(sender)
        end)
    end
    mc:setName(name)
    if not notSingle then
        self._mcs[name] = mc
    end
    node:addChild(mc,zOrder)
    return mc
end

function MainView:removeMC( name )
    if self._mcs[name] then
        self._mcs[name]:removeFromParent()
        self._mcs[name] = nil
    end
end

function MainView:updateFightNum( )
    local formationModel = self._modelMgr:getModel("FormationModel")
    local data = formationModel:getFormationData()[formationModel.kFormationTypeCommon]
    if not data  then
        return 0
    end
    local fightCapacity = 0
    -- local teamModel = self._modelMgr:getModel("TeamModel")
    -- table.walk(data, function(v, k)
    --     if 0 == v then return end
    --     if string.find(tostring(k), "team") and not string.find(tostring(k), "g") then
    --         local teamData = teamModel:getTeamAndIndexById(v)
    --         fightCapacity = fightCapacity + teamData.score
    --     end
    -- end)
    -- local heroData = self._modelMgr:getModel("HeroModel"):getData()[tostring(data.heroId)]
    local treasureCapacity = self._modelMgr:getModel("TreasureModel"):getTreasureScore()
    fightCapacity = formationModel:getCurrentFightScoreByType(formationModel.kFormationTypeCommon) --data.score --fightCapacity + heroData.score+treasureCapacity
    self._zhandouliLabel:setString(fightCapacity or 0)
    -- self._zhandouliTipImg:setPositionX(self._zhandouliLabel:getContentSize().width+2)
    print("战斗力。。。",data.score,fightCapacity)
    return fightCapacity,treasureCapacity
end

function MainView:setQipao()
    
    local mainViewModel = self._modelMgr:getModel("MainViewModel")
    self:removeQipao(mainViewModel:getTipsQipao())
    -- self:removeQipao(mainViewModel:getCommonQipao())
    print("==GuideUtils=============", GuideUtils.isGuideRunning)
    if mainViewModel:getQipao() and GuideUtils.isGuideRunning == false then
        -- dump(mainViewModel:getTipsQipao())
        self:setQipao1(mainViewModel:getTipsQipao())
        self:setQipao3(mainViewModel:getTeshuTipsQipao())
        -- self:setBubbleWithoutCountLimit(mainViewModel:getCommonQipao())
    end

    if mainViewModel:getQipao() and GuideUtils.isGuideRunning == false then
        self:setQipao2()
    end
end 

-- 联盟新功能 
function MainView:setQipao3(qipaoData)
    local qipao 
    local toBeOpen = true
    local flag = false

    local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl
    local tip, minLevel, maxLevel, tempIndex

    for rank=1,table.nums(qipaoData) do
        if not qipaoData[rank] then
            return
        end
        tempIndex = qipaoData[rank].pos
        tip = tab:Qipao(tempIndex)
        minLevel = tip.level[1]
        maxLevel = tip.level[2]
        flag = qipaoData[rank].callback()
        if userlvl < minLevel or userlvl > maxLevel then
            flag = false
        end
        qipao = qipaoData[rank].qipao -- tip.btn
        if qipao ~= 0 and flag == true then
            self:addShowBubble(qipao, tip)
        end
    end
end

-- 活动气泡
function MainView:setQipao2(qipaoData)
    local qipao 
    local toBeOpen = true
    local flag = false
    local activityModel = self._modelMgr:getModel("ActivityModel")
    for k,v in pairs(tab.activityqipao) do
        flag = activityModel:isActivityOpen(k)
        if flag == true then
            flag = self._modelMgr:getModel("MainViewModel"):getHuodongQipao(v.type) 
        end
        if flag == true then
            self:addShowBubble(v.btn, v, "actTipBg")
        end
        flag = false
    end
end

-- 主界面无数量要求气泡,普通气泡
function MainView:setBubbleWithoutCountLimit(qipaoData)
    local qipao 
    local toBeOpen = true
    local flag = false
    local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl
    local tip, minLevel, maxLevel, tempIndex

    for index,value in pairs (qipaoData) do 
        tempIndex = value.pos
        tip = tab:Qipao(tempIndex)
        minLevel = tip.level[1]
        maxLevel = tip.level[2]
        flag = value.callback()
        if userlvl < minLevel or userlvl > maxLevel then
            flag = false
        end
        qipao = value.qipao -- tip.btn
        if qipao ~= 0 and flag == true then
            self:addShowBubble(qipao, tip)
        end
    end
end


-- 主界面通用气泡
function MainView:setQipao1(qipaoData)
    self:detectCollegeQiPao()
    -- dump(qipaoData)
    local qipao 
    local toBeOpen = true
    local flag = false

    local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl
    local tip, minLevel, maxLevel, tempIndex
    local qipaoNum = 0
    for index,value in pairs (qipaoData) do 
        -- if not qipaoData[rank] then
        --     return
        -- end
        tempIndex = value.pos
        tip = tab:Qipao(tempIndex)
        minLevel = tip.level[1]
        maxLevel = tip.level[2]
        flag = value.callback()
        local sign = value.sign

        if userlvl < minLevel or userlvl > maxLevel then
            flag = false
        end
        qipao = value.qipao -- tip.btn
        if qipao ~= 0 and flag == true then
            self:addShowBubble(qipao, tip)
        end

        if flag == true then
            qipaoNum = qipaoNum + 1
            if qipaoNum >= 3 then
                break
            end
        end
    end
    -- 放在后边单独判断积分联赛
    self:detectLeagueQiPao()
    
end


-- 气泡箭头合一
function MainView:addShowBubble(btntitle, tip, strName)
    -- dump(tip)
    local flag = false
    local btn = self:getUI(btntitle)
    if not btn then
        return
    end
    -- 法术祈愿气泡级别最高
    local college_tip = btn:getChildByName("tipbg_college")
    if college_tip then return end
    local tempTipBg = btn:getChildByName("tipbg")
    local guanjun_tip = btn:getChildByName("tipbg_guanjun")
    if tempTipBg and guanjun_tip then -- 有其他气泡直接顶掉冠军气泡
        guanjun_tip:removeFromParent()
    end
    if strName then
        tempTipBg = btn:getChildByName(strName)
    end
    if tempTipBg then
        return
    end
    -- local tip = tip
    local scale = 1 / btn:getScale()
    local posX = tip.position[1] * scale
    local posY = tip.position[2] * scale
    -- local posX = -180
    -- local posY = 30
    if (not tip) or (not tip.pic) then
        return
    end
    if tip.jiantou ~= 5 then
        local tipbg = cc.Scale9Sprite:createWithSpriteFrameName(tip.pic .. ".png")     
        if strName then
            tipbg:setName(strName)
        else
            tipbg:setName("tipbg")
        end
        tipbg:setAnchorPoint(0.25, 0)
        tipbg:setPosition(posX, posY)
        tipbg:setScale(scale)
        local seq = cc.Sequence:create(cc.ScaleTo:create(1, scale+scale*0.2), cc.ScaleTo:create(1, scale))
        tipbg:runAction(cc.RepeatForever:create(seq))
        if tip.rotationY and type(tip.rotationY) == "number" and tip.rotationY > 0 then
            local _3dVertex1 = cc.Vertex3F(0,tip.rotationY, 0)
            tipbg:setRotation3D(_3dVertex1)
        end
        btn:addChild(tipbg, 10000)

        if tonumber(tip.condition) == 52 then   --法术祈愿，橙色法术气泡特殊处理  add by zhangtao
            local hotSpotData = self._modelMgr:getModel("SpellBooksModel"):getHotSpotData()
            if hotSpotData then
                local itemData = hotSpotData[1]
                if itemData and itemData[1] == "tool" then
                    local toolD = tab.tool[itemData[2]]
                    if toolD then
                        local filename = toolD.art .. ".png"
                        local sfc = cc.SpriteFrameCache:getInstance()
                        if not sfc:getSpriteFrameByName(filename) then
                            filename = toolD.art .. ".jpg"
                        end
                        local boxIcon = ccui.ImageView:create()
                        boxIcon:setAnchorPoint(0,0)
                        boxIcon:setPosition(10,10)
                        boxIcon:setScale(0.46)
                        tipbg:addChild(boxIcon)
                        -- boxIcon:ignoreContentAdaptWithSize(false)
                        boxIcon:loadTexture(filename, 1)
                    end
                end
            end
        end 
    elseif tip.jiantou == 5 then -- 副本
        local tipbg = mcMgr:createViewMC("c1_guidecircle-HD", true)
        tipbg:setName("tipbg")
        tipbg:setPosition(posX, posY)
        btn:addChild(tipbg)
    end
    return flag
end

-- 特做判定积分联赛气泡
function MainView:detectLeagueQiPao( )
    local isOpen = LeagueUtils:isLeagueOpen()
    if not isOpen then return end
    local btn = self:getUI("bg.midBg3.pve")
    local guanjun_tip = btn:getChildByName("tipbg_guanjun")
    local tempTipBg = btn:getChildByName("tipbg")
    if tempTipBg and guanjun_tip then -- 有其他气泡直接顶掉冠军气泡
        guanjun_tip:removeFromParent()
        return 
    end
    -- 积分联赛挑战次数
    local day31 = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(31)
    if not tolua.isnull(guanjun_tip) and day31 > 0 then
        guanjun_tip:removeFromParent()
    elseif btn:getName() == "pve" and not guanjun_tip and day31 == 0 and not tempTipBg then
        local tipScale = 1 / btn:getScale()
        local tipbg = cc.Scale9Sprite:createWithSpriteFrameName("qipao_guanjun.png")     
        tipbg:setName("tipbg_guanjun")
        tipbg._touchToRemove = true
        tipbg:setAnchorPoint(0.25, 0)
        tipbg:setPosition(50, 20)
        tipbg:setScale(tipScale)
        local seq = cc.Sequence:create(cc.ScaleTo:create(1, tipScale+tipScale*0.2), cc.ScaleTo:create(1, tipScale))
        tipbg:runAction(cc.RepeatForever:create(seq))
        btn:addChild(tipbg, 10000)
    end
end

-- 学院新功能气泡
function MainView:detectCollegeQiPao( )
    local isOpen = SystemUtils:enableSkillBook()
    if not isOpen then return end
    local btn = self:getUI("bg.midBg1.mana")
    local college_tip = btn:getChildByName("tipbg_college")
    local tempTipBg = btn:getChildByName("tipbg")
    if tempTipBg and college_tip then -- 有其他气泡直接顶掉冠军气泡
        college_tip:removeFromParent()
        return 
    end
    -- 积分联赛挑战次数
    local drawNum = self._modelMgr:getModel("SpellBooksModel"):getDrawData().spbookNum or 0
    if not tolua.isnull(college_tip) and drawNum > 0 then
        college_tip:removeFromParent()
    elseif btn:getName() == "mana" and not college_tip and drawNum == 0 and not tempTipBg then
        local tipScale = 1 / btn:getScale()
        local tipbg = cc.Scale9Sprite:createWithSpriteFrameName("qipao_xingongneng1.png")     
        tipbg:setName("tipbg_college")
        tipbg._touchToRemove = true
        tipbg:setAnchorPoint(0.25, 0)
        tipbg:setPosition(0, 50)
        tipbg:setScale(tipScale)
        local seq = cc.Sequence:create(cc.ScaleTo:create(1, tipScale+tipScale*0.2), cc.ScaleTo:create(1, tipScale))
        tipbg:runAction(cc.RepeatForever:create(seq))
        btn:addChild(tipbg, 10000)
    end
end

-- -- 气泡箭头合一
-- function MainView:addShowBubble(btntitle, tip)
--     local flag = false
--     local btn = self:getUI(btntitle)
--     if not btn then
--         return
--     end
--     -- i = 1
--     -- local tip = tip
--     local scale = 1 / btn:getScale()
--     local posX = tip.position[1] * scale
--     local posY = tip.position[2] * scale
--     -- local posX = -180
--     -- local posY = 30

--     if tip then
--         -- local tipbg = cc.Scale9Sprite:createWithSpriteFrameName("main_tip.png")
--         local str = lang(tip.content)
--         if string.find(str, "color=") == nil then
--             str = "[color=000000]"..str.."[-]"
--         end   
--         local label = RichTextFactory:create(str, 160, 50)
--         label:formatText()
--         local width = label:getRealSize().width
--         local height = label:getRealSize().height
--         label:setContentSize(width, height)
        
--         -- tipbg:setContentSize(width + 25, 50)
--         -- label:setPosition((width + 25)*0.5, 25 + height * 0.5)
--         -- tipbg:addChild(label, 2)
--         -- tipbg:setName("tipbg")
--         -- tip.jiantou = 5
--         local tipbg
--         if tip.jiantou == 1 then
--             tipbg = cc.Sprite:createWithSpriteFrameName("main_tip1.png")
--             label:setPosition(cc.p(tipbg:getContentSize().width*0.5, 10 + height * 0.5))
--             tipbg:runAction(
--                 cc.RepeatForever:create(
--                 cc.Sequence:create(
--                 cc.MoveTo:create(0.4, cc.p(posX, posY - 3)), 
--                 cc.MoveTo:create(0.4, cc.p(posX, posY + 3))
--             )))
--         elseif tip.jiantou == 2 then
--             tipbg = cc.Sprite:createWithSpriteFrameName("main_tip2.png")
--             label:setPosition(cc.p(tipbg:getContentSize().width*0.5 + 5, height * 0.5))
--             tipbg:runAction(
--                 cc.RepeatForever:create(
--                 cc.Sequence:create(
--                 cc.MoveTo:create(0.4, cc.p(posX - 3, posY)), 
--                 cc.MoveTo:create(0.4, cc.p(posX + 3, posY))
--             )))
--         elseif tip.jiantou == 3 then
--             tipbg = cc.Sprite:createWithSpriteFrameName("main_tip2.png")
--             tipbg:setFlipX(true)
--             label:setPosition(cc.p(tipbg:getContentSize().width*0.5-3, height * 0.5))
--             -- label:setScaleX(-1)
--             tipbg:runAction(
--                 cc.RepeatForever:create(
--                 cc.Sequence:create(
--                 cc.MoveTo:create(0.4, cc.p(posX - 3, posY)), 
--                 cc.MoveTo:create(0.4, cc.p(posX + 3, posY))
--             )))
--         elseif tip.jiantou == 4 then
--             tipbg = cc.Scale9Sprite:createWithSpriteFrameName("main_tip1.png") -- cc.Sprite:createWithSpriteFrameName("main_tip1.png")
--             tipbg:setContentSize(tipbg:getContentSize().width, height+35)
--             label:setPosition(cc.p(tipbg:getContentSize().width*0.5, (height+30) * 0.5 + 5))
--             tipbg:runAction(
--                 cc.RepeatForever:create(
--                 cc.Sequence:create(
--                 cc.MoveTo:create(0.4, cc.p(posX, posY - 3)), 
--                 cc.MoveTo:create(0.4, cc.p(posX, posY + 3))
--             )))
--         elseif tip.jiantou == 5 then
--             tipbg = ccui.Widget:create()
--             tipbg:setRotation(90)
--             -- local shou = mcMgr:createViewMC("shou_guidexiaoshou", true, false) 
--             -- shou:setScaleX(-1)
--             -- tipbg:addChild(shou)
--             -- tipbg:setFlippedY()
--             local quan = mcMgr:createViewMC("c1_guidecircle-HD", true)
--             quan:setPosition(-8, -120)
--             -- quan:setScale(0.35)
--             tipbg:addChild(quan)
--             -- mc:setPosition(cc.p(0, tipbg:getContentSize().height/2 - 1.5))
--         end
--         tipbg:addChild(label, 2)

--         if tip.jiantou == 5 then
--             label:removeFromParent()
--             tipbg:setScale(0.8)
--         else
--             tipbg:setScale(scale)
--         end
        
--         tipbg:setName("tipbg")
--         tipbg:setPosition(posX, posY)
        
--         btn:addChild(tipbg, 10000)
--     end
--     return flag
-- end

function MainView:removeQipao(qipaoData)
    for rankIndex,value in pairs (qipaoData) do 
        -- if not qipaoData[rankIndex] then
        --     self._viewMgr:showTip("气泡表配错" .. rankIndex)
        --     break 
        -- else
        --     self:removeBubble(qipaoData[rankIndex].qipao)
        -- end
        self:removeBubble(value.qipao)
    end

    for k,v in pairs(tab.activityqipao) do
        self:removeBubble(v.btn, "actTipBg")
    end
end


function MainView:removeBubble(btntitle, strName)
    if tonumber(btntitle) == 0 then
        return
    end

    local btn = self:getUI(btntitle)
    if not btn then
        return
    end
    local tipbg = btn:getChildByName("tipbg")
    if strName then
        tipbg = btn:getChildByName(strName)
    end
    if tipbg then
        tipbg:removeFromParent()
    end
    local guanjun_tip = btn:getChildByName("tipbg_guanjun")
    if not tolua.isnull(guanjun_tip) then 
        local isCurBatchFirstIn = self._modelMgr:getModel("LeagueModel"):isCurBatchFirstIn()
        if not isCurBatchFirstIn then 
            guanjun_tip:removeFromParent()
        end
    end
    local college_tip = btn:getChildByName("tipbg_college")
    if not tolua.isnull(college_tip) then 
        college_tip:removeFromParent()
    end
end

-- 设置新功能开启预告
function MainView:setActionAdvance()
    local noticeType1, noticeType2 = 0, 0
    local userModel = self._modelMgr:getModel("UserModel")
    local userlvl = userModel:getData().lvl 
    local userlevelTab = tab:UserLevel(userlvl)
    local systemnotice = userlevelTab.systemnotice

    if systemnotice then
        print("sysOpenTime========", sysOpenTime)
        noticeType1 = 1
        local notice = tab:SystemDes(systemnotice)

        local noticeBg = self:getUI("noticeBg")
        if noticeBg then
            noticeBg:setVisible(true)
        end
        
        local noticeSp = self:getUI("noticeBg.notice")
        local noticeName = self:getUI("noticeBg.notice.noticeName") 
        local noticeOpen = self:getUI("noticeBg.notice.noticeOpen")
        local noticeIcon = self:getUI("noticeBg.notice.noticeIcon")

        noticeName:setVisible(false)
        -- noticeName:setString(lang(notice.name))
        -- noticeName:setColor(cc.c3b(255, 225, 24))
        -- noticeName:enable2Color(1, cc.c4b(255, 226, 147, 255))
        -- noticeName:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        -- noticeName:setFontSize(20)

        local str = notice.level .. "级开启" -- string.gsub(lang(notice.des), "%b[]", "")
        noticeOpen:setString(str)

        if noticeOpen.isInit == nil then
            noticeOpen:setColor(cc.c3b(255, 255, 255))
            noticeOpen:enableOutline(cc.c4b(60, 30, 10, 255), 1)
            noticeOpen:setFontSize(18)
            noticeOpen.isInit = true
        end

        noticeIcon:loadTexture(IconUtils.iconPath .. notice.art .. ".png", 1)
        noticeIcon:setScale(50 / noticeIcon:getContentSize().width)

        if noticeSp:getChildByFullName("diguang") == nil then
            local mc = mcMgr:createViewMC("lingzhushouce_lianmengjihuo", true, false) 
            mc:setScale(0.9)
            mc:setPosition(cc.p(noticeSp:getContentSize().width*0.5, noticeSp:getContentSize().height*0.5))
            mc:setName("diguang")
            noticeSp:addChild(mc)
        end
    end
    -- print("=================",systemnotice)

    systemnotice = nil
    systemnotice = self._modelMgr:getModel("MainViewModel"):getTimeShowOpen()

    print("systemnotice=========", systemnotice)    
    if systemnotice and systemnotice ~= 0 then
        noticeType2 = 1
        local notice = tab:SystemOn(systemnotice)
        local userData = userModel:getData()

        local noticeSp = self:getUI("noticeBg.notice1")
        local noticeName = self:getUI("noticeBg.notice1.noticeName") 
        local noticeOpen = self:getUI("noticeBg.notice1.noticeOpen")
        local noticeIcon = self:getUI("noticeBg.notice1.noticeIcon")

        local endtime1 = notice.openhour[2] .. ":" .. notice.openminut[2]
        local endtimes = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(userModel:getCurServerTime(), "%Y-%m-%d ".. endtime1 ..":00"))
        -- local endtimes = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(userModel:getCurServerTime(), "%Y-%m-%d "..notice.openhour[2]..":00:00"))
        local tempTime = endtimes - userModel:getCurServerTime()

        noticeOpen:stopAllActions()
        if tempTime >= 0 then
            noticeOpen:runAction(cc.RepeatForever:create(
                cc.Sequence:create(cc.CallFunc:create(function()
                    tempTime = endtimes - userModel:getCurServerTime()
                    if tempTime < 0 then
                        self:setActionAdvance()
                    end
                    local tempValue = tempTime
                    local hour, minute, second
                    hour = math.floor(tempValue/3600)
                    tempValue = tempValue - hour*3600
                    minute = math.floor(tempValue/60)
                    tempValue = tempValue - minute*60
                    second = math.fmod(tempValue, 60)
                    local showTime = string.format("%.2d:%.2d:%.2d", hour, minute, second)

                    if tempTime < 0 then
                        showTime = "00:00:00"
                        noticeOpen:stopAllActions()
                        noticeOpen:setString(showTime)
                        local noticeBg = self:getUI("noticeBg")
                        noticeBg:setVisible(false)
                        self:setActionAdvance()
                        return
                    end
                    if noticeOpen then
                        noticeOpen:setString(showTime)
                    end
                end), cc.DelayTime:create(1))
            ))
        end

        noticeName:setVisible(false)
        -- noticeName:setString(lang(notice.name))
        -- noticeName:setColor(cc.c3b(255, 225, 24))
        -- noticeName:enable2Color(1, cc.c4b(255, 226, 147, 255))
        -- noticeName:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        -- noticeName:setFontSize(20)

        local str = "" -- string.gsub(lang(notice.des), "%b[]", "")
        noticeOpen:setString(str)
        noticeOpen:setColor(cc.c3b(255, 255, 255))
        noticeOpen:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        
        noticeIcon:loadTexture(IconUtils.iconPath .. notice.art .. ".png", 1)

        if noticeSp:getChildByFullName("diguang") == nil then
            local mc = mcMgr:createViewMC("lingzhushouce_lianmengjihuo", true, false) 
            mc:setScale(0.9)
            mc:setPosition(cc.p(noticeSp:getContentSize().width*0.5, noticeSp:getContentSize().height*0.5))
            mc:setName("diguang")
            noticeSp:addChild(mc)
        end

        self:registerClickEventByName("noticeBg.notice1", function ()
            if systemnotice == 101 or systemnotice == 105 then
                self._viewMgr:showView("heroduel.HeroDuelMainView")
            elseif systemnotice == 102 or systemnotice == 103 or systemnotice == 104 then
                self._serverMgr:sendMsg("GodWarServer", "getJoinList", {}, true, {}, function (result)
                    self._viewMgr:showView("godwar.GodWarView")
                end)
            elseif systemnotice == 106 then
                self._viewMgr:showView("citybattle.CityBattleView")
            elseif systemnotice == 108 then
                self._viewMgr:showView("purgatory.PurgatoryView")
            elseif systemnotice == 109 or systemnotice == 110 or systemnotice == 111 then
                if not GameStatic.is_open_crossGodWar then
                    self._viewMgr:showTip("系统维护中")
                    return
                end
                self._serverMgr:sendMsg("CrossGodWarServer", "enter", {}, true, {}, function(result)
                    UIUtils:reloadLuaFile("crossGod.CrossGodWarView")
                    self._viewMgr:showView("crossGod.CrossGodWarView")
                end)
            end
        end)
        self:removeActionAdvance(noticeType1, noticeType2)
        return
    end

    systemnotice = nil
    systemnotice = self._modelMgr:getModel("MainViewModel"):isShowNotice()
    if systemnotice then
        noticeType2 = 1
        local notice = tab:STimeOpen(systemnotice)
        local userData = userModel:getData()
        local sysOpenTime = userData.sec_open_time
        local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(sysOpenTime,"%Y-%m-%d 05:00:00"))
        if sysOpenTime < tempTime then
            sysOpenTime = sysOpenTime - 86400
        end
        local openTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(sysOpenTime + notice["opentime"]*86400,"%Y-%m-%d 00:00:00"))
        local subTime = 86400 - (notice["openhour"])*3600
        local tempTime = openTime - userModel:getCurServerTime() - subTime
        if tempTime > 86400 then
            noticeType2 = 0
            -- self:removeActionAdvance()
        end
        local noticeSp = self:getUI("noticeBg.notice1")
        local noticeName = self:getUI("noticeBg.notice1.noticeName") 
        local noticeOpen = self:getUI("noticeBg.notice1.noticeOpen")
        local noticeIcon = self:getUI("noticeBg.notice1.noticeIcon")

        noticeOpen:stopAllActions()
        print("notice.prevelege====+++++++++++==", notice.prevelege, tempTime)
        local openac = false
        if notice.prevelege == 0 then
            if tempTime >= 0 then
                openac = true
                noticeOpen:runAction(cc.RepeatForever:create(
                    cc.Sequence:create(cc.CallFunc:create(function()
                        tempTime = openTime - userModel:getCurServerTime() - subTime
                        if tempTime <= 86400 then
                            local noticeBg = self:getUI("noticeBg")
                            if noticeBg then
                                noticeBg:setVisible(true)
                            end
                        end
                        local tempValue = tempTime
                        local hour, minute, second
                        hour = math.floor(tempValue/3600)
                        tempValue = tempValue - hour*3600
                        minute = math.floor(tempValue/60)
                        tempValue = tempValue - minute*60
                        second = math.fmod(tempValue, 60)
                        local showTime = string.format("%.2d:%.2d:%.2d", hour, minute, second)

                        if tempTime <= 0 then
                            showTime = "00:00:00"
                            noticeOpen:stopAllActions()
                            noticeOpen:setString(showTime)
                            local noticeBg = self:getUI("noticeBg")
                            noticeBg:setVisible(false)
                            self:setActionAdvance()
                            return
                        end
                        if noticeOpen then
                            noticeOpen:setString(showTime)
                        end
                    end), cc.DelayTime:create(1))
                ))
            end
        else
            if userlvl >= notice.level then
                if tempTime >= 0 then
                    openac = true
                    noticeOpen:runAction(cc.RepeatForever:create(
                        cc.Sequence:create(cc.CallFunc:create(function()
                            tempTime = openTime - userModel:getCurServerTime() - subTime
                            local tempValue = tempTime
                            local hour, minute, second
                            hour = math.floor(tempValue/3600)
                            tempValue = tempValue - hour*3600
                            minute = math.floor(tempValue/60)
                            tempValue = tempValue - minute*60
                            second = math.fmod(tempValue, 60)
                            local showTime = string.format("%.2d:%.2d:%.2d", hour, minute, second)

                            if tempTime <= 0 then
                                showTime = "00:00:00"
                                noticeOpen:stopAllActions()
                                noticeOpen:setString(showTime)
                                local noticeBg = self:getUI("noticeBg")
                                noticeBg:setVisible(false)
                                self:setActionAdvance()
                                return
                            end
                            if noticeOpen then
                                noticeOpen:setString(showTime)
                            end
                        end), cc.DelayTime:create(1))
                    ))
                end
            end
        end

        noticeName:setVisible(false)
        -- noticeName:setString(lang(notice.name))
        -- noticeName:setColor(cc.c3b(255, 225, 24))
        -- noticeName:enable2Color(1, cc.c4b(255, 226, 147, 255))
        -- noticeName:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        -- noticeName:setFontSize(20)

        local str = notice.level .. "级开启" -- string.gsub(lang(notice.des), "%b[]", "")
        if openac == false then
            noticeOpen:setString(str)
        end
        noticeOpen:setColor(cc.c3b(255, 255, 255))
        noticeOpen:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        
        noticeIcon:loadTexture(IconUtils.iconPath .. notice.art .. ".png", 1)

        if noticeSp:getChildByFullName("diguang") == nil then
            local mc = mcMgr:createViewMC("lingzhushouce_lianmengjihuo", true, false) 
            mc:setScale(0.9)
            mc:setPosition(cc.p(noticeSp:getContentSize().width*0.5, noticeSp:getContentSize().height*0.5))
            mc:setName("diguang")
            noticeSp:addChild(mc)
        end

        self:registerClickEventByName("noticeBg.notice1", function ()
            local mainViewModel = self._modelMgr:getModel("MainViewModel")
            mainViewModel:clearQipao()
            mainViewModel:reflashMainView()
            self._viewMgr:showDialog("main.MainActionOpenDialog", {inType = 2}, true)
        end)
    end

    print("noticeType1, noticeType2=======", noticeType1, noticeType2)
    self:removeActionAdvance(noticeType1, noticeType2)
end

function MainView:removeActionAdvance(noticeType1, noticeType2)
    local notice1 = self:getUI("noticeBg.notice")
    local notice2 = self:getUI("noticeBg.notice1")
    local handbookBg = self:getUI("handbookBg")
    if notice1 and noticeType1 == 0 then
        notice1:setVisible(false)
        handbookBg:setVisible(true)
    elseif notice1 then
        notice1:setVisible(true)
        handbookBg:setVisible(false)
    end

    if notice2 and noticeType2 == 0 then
        notice2:setVisible(false)
    elseif notice2 then
        notice2:setVisible(true)
    end
    -- local noticeBg = self:getUI("noticeBg")
    -- if noticeBg then
    --     noticeBg:removeFromParent()
    -- end

end

-- 更新领主手册入口状态
function MainView:reflashAdvanve()
    local tp = self._modelMgr:getModel("HandbookModel"):hasRedPoint()
    local notice1 = self:getUI("noticeBg.notice")
    local handbookBtn = self:getUI("handbookBg.handbookBtn")

    if handbookBtn:getChildByName("diguang") == nil then
        local mc = mcMgr:createViewMC("lingzhushouce_lianmengjihuo", true, false) 
        mc:setScale(0.9)
        mc:setPosition(cc.p(handbookBtn:getContentSize().width*0.5, handbookBtn:getContentSize().height*0.5))
        mc:setName("diguang")
        handbookBtn:addChild(mc)
    end

    if tp == "hasRed" then   
        if notice1:getChildByName("diguang") then
            notice1:getChildByName("diguang"):setVisible(true)
            notice1:getChildByFullName("redPoint"):setVisible(true)
            notice1:getChildByFullName("redPoint"):loadTexture("globalImageUI_bag_keyihecheng.png", 1)
        end
        handbookBtn:getChildByName("diguang"):setVisible(true)
        handbookBtn:getChildByFullName("redPoint"):setVisible(true)
        handbookBtn:getChildByFullName("redPoint"):loadTexture("globalImageUI_bag_keyihecheng.png", 1)

    elseif tp == "hasNew" then   
        if notice1:getChildByName("diguang") then
            notice1:getChildByName("diguang"):setVisible(true)
            notice1:getChildByFullName("redPoint"):setVisible(true)
            notice1:getChildByFullName("redPoint"):loadTexture("imgNew_mainView.png", 1)
        end
        handbookBtn:getChildByName("diguang"):setVisible(true)
        handbookBtn:getChildByFullName("redPoint"):setVisible(true)
        handbookBtn:getChildByFullName("redPoint"):loadTexture("imgNew_mainView.png", 1)

    elseif tp == "noRed" then 
        if notice1:getChildByName("diguang") then
            notice1:getChildByName("diguang"):setVisible(false)
            notice1:getChildByFullName("redPoint"):setVisible(false)
        end
        handbookBtn:getChildByName("diguang"):setVisible(false)
        handbookBtn:getChildByFullName("redPoint"):setVisible(false)
    end
end

-- 动画开启
function MainView:actionOpen()
    self._viewMgr:unlock()
    -- -- 移除气泡
    -- local mainViewModel = self._modelMgr:getModel("MainViewModel")
    -- self:removeQipao(mainViewModel:getTipsQipao())
    local noticeType = 1
    local userInfo = self._modelMgr:getModel("UserModel"):getData()
    local systemopen = tab:UserLevel(userInfo.lvl).systemopen
    print("level 新功能解锁动画==========", userInfo.lvl)
    -- dump(tab:UserLevel(userInfo.lvl))
    if userInfo.exp > 130 then
        systemopen = nil
    end
    if not systemopen then
        noticeType = 2
        systemopen = self._modelMgr:getModel("MainViewModel"):isOpenShowNotice()
        print("systemopen ======================", systemopen)
    end
    if systemopen == nil then
        return
    end
    -- 移除气泡
    local mainViewModel = self._modelMgr:getModel("MainViewModel")
    self:removeQipao(mainViewModel:getTipsQipao())
    -- self:removeQipao(mainViewModel:getCommonQipao())

    local openTab
    if noticeType == 2 then
        if self._modelMgr:getModel("MainViewModel"):isOpenNotice(systemopen) then
            local param = {num = 2, val = systemopen}
            ServerManager:getInstance():sendMsg("UserServer", "bubbleModify", param, true, {}, function (result)
                -- self:setActionOpen()
            end)
            local flag = self._modelMgr:getModel("MainViewModel"):getTimeActionOpen(systemopen)
            if flag == false then
                print("flag============close action anim", systemopen)
                return
            end
            openTab = tab:STimeOpen(systemopen)
        else
            return
        end
    else
        openTab = tab:SystemDes(systemopen)
    end

    if systemopen then
        self._viewMgr:lock(-1)
        local btntitle = openTab.btn
        -- print ("==btntitle=====", btntitle)
        local btn = self:getUI(btntitle)
        if btn then
            local btnPos = btn:convertToWorldSpace(cc.p(btn:getContentSize().width*0.5, btn:getContentSize().height*0.5))
            local rect1 = cc.rect(MAX_SCREEN_WIDTH*0.2, 0, MAX_SCREEN_WIDTH*(1-0.6), MAX_SCREEN_HEIGHT)
            local flag = cc.rectContainsPoint(rect1, cc.p(btnPos.x, btnPos.y))
            local times = 1
            if (not openTab.move) or (openTab.move == 0) then
                flag = true
            end
            if flag then
                times = 0
            end

            btntitle = string.gsub(btntitle, "bg.midBg[%d].", "")
            if btntitle == "bottomLayer.instanceBtn" and userInfo.lvl == 39 then
                btntitle = "chaoxue"
                flag = false
            end
            local seq = cc.Sequence:create(cc.CallFunc:create(function()
                if flag == false then
                    -- 移动屏幕
                    self:scrollIconToCenter(btntitle,1,nil,0)
                end
                self._viewMgr:closeDialog(self)
            end),cc.DelayTime:create(times + 0.2),cc.CallFunc:create(function()
                self:setActionOpenAnim(systemopen, false, openTab)
                -- self:setActionOpen(systemopen, false, openTab)
            end))
            self:runAction(seq)
        else
            self._viewMgr:unlock()
        end
    end
end

function MainView:setActionOpenAnim(systemopen, breakBg, systemDes)
    print("执行动画=== ")
    local bgNode = self:getLayerNode()
    local bgLayer 
    if breakBg then
        bgLayer = ccui.Layout:create()
        bgLayer:setName("bgLayer")
        bgLayer:setBackGroundColorOpacity(180)
        bgLayer:setBackGroundColorType(1)
        bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
        bgLayer:setTouchEnabled(true)
        bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        bgNode:addChild(bgLayer, 1)
    else
        bgLayer = ccui.Layout:create()
        bgLayer:setName("bgLayer")
        bgLayer:setBackGroundColorOpacity(0)
        bgLayer:setBackGroundColorType(1)
        bgLayer:setTouchEnabled(true)
        bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        bgNode:addChild(bgLayer, 3)
        -- local bgLayer = bgNode
    end

    local notice = self:getUI("noticeBg.notice")
    if systemopen > 100 then
        notice = self:getUI("noticeBg.notice1")
    end

    local icon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. systemDes.art .. ".png")
    icon:setPosition(notice:getContentSize().width * 0.5, notice:getContentSize().height * 0.5)
    notice:addChild(icon, 2)
    icon:setScale(0)

    local btn = cc.Sprite:create()
    btn:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    bgNode:addChild(btn, 2)
    btn:setScale(0)

    local scale = btn:getScale()
    local bgNodePos = btn:convertToWorldSpace(cc.p(0, 0)) 
    local iconPos = icon:convertToWorldSpace(cc.p(0, 0))

    local posX = bgNodePos.x - iconPos.x + btn:getContentSize().width*0.5*btn:getScaleX() + systemDes.position[1] -- 165 --systemDes.position[1]
    local posY = bgNodePos.y - iconPos.y + btn:getContentSize().height*0.5*btn:getScaleY() + systemDes.position[2] -- 99 --systemDes.position[2]
    local disicon = math.sqrt(posX*posX+posY*posY)
    local speed = disicon/2000

    if tonumber(systemDes.id) == 1 then
        posX = posX - 25
    end

    local angle = math.deg(math.atan(posX/posY)) -- + 180
    if 0 <= posX and 0 <= posY then
        angle = angle + 180
    elseif  0 >= posX and 0 <= posY then
        angle = angle + 180
    elseif  0 >= posX and 0 >= posY then
        angle = angle 
    elseif  0 <= posX and 0 >= posY then
        angle = angle 
    end

    local rota1 = cc.RotateBy:create(0.1, -5)
    local rota2 = cc.RotateBy:create(0.1, 5)
    icon:runAction(cc.Sequence:create(
        cc.ScaleTo:create(0.1, 0.8), 
        cc.ScaleTo:create(0.2, 1.2), 
        cc.CallFunc:create(function()
            icon:setBrightness(80)
        end),
        cc.RotateBy:create(0.05, -20),
        cc.RotateBy:create(0.05, 20),
        cc.RotateBy:create(0.05, -20),
        cc.RotateBy:create(0.05, 20),
        cc.RotateBy:create(0.05, -20),
        cc.RotateBy:create(0.05, 20),
        cc.RotateBy:create(0.05, -20),
        cc.RotateBy:create(0.05, 20),
        cc.RotateBy:create(0.1, 0),
        cc.ScaleBy:create(0.2, 0.6),
        cc.ScaleBy:create(0.1, 0.01),
        cc.CallFunc:create(function()
            local mc1 = mcMgr:createViewMC("fankui_lianmengjihuo", false, true, function (_, sender) 
            end, RGBA8888)  
            mc1:setPosition(notice:getContentSize().width * 0.5, notice:getContentSize().height * 0.5)
            notice:addChild(mc1,5)

            local mc2 = mcMgr:createViewMC("guangqiu_lianmengjihuo", true, false) 
            mc2:setName("mc2")
            mc2:setScale(100) 
            mc2:setRotation(angle)
            icon:addChild(mc2)

            local sp = mcMgr:createViewMC("lashentiao_lianmengjihuo", false, false)  
            sp:setAnchorPoint(cc.p(0.5, 0))
            sp:setRotation(90)
            sp:setScaleX(0)
            mc2:addChild(sp, -1)

            local scay = 1
            if disicon < 150 then
                scay = 0.5
            elseif disicon > 400 then
                scay = 2
            end
            local spSeq = cc.Sequence:create(cc.ScaleTo:create(0.2, 0, 1), cc.ScaleTo:create(speed+0.1, scay, 1), cc.ScaleTo:create(0, 0, 1), cc.FadeOut:create(0.1))
            sp:runAction(spSeq)
        end),
        cc.DelayTime:create(0.2),      
        cc.Spawn:create(
            -- cc.ScaleBy:create(speed, 0.2), 
            cc.MoveBy:create(speed+0.1, cc.p(posX, posY)),
            cc.FadeOut:create(speed+0.1)),
        cc.CallFunc:create(function()
            local mc2 = icon:getChildByFullName("mc2")
            if mc2 then
                mc2:setCascadeOpacityEnabled(true)
                mc2:setOpacity(0)
            end
            local mc1 = mcMgr:createViewMC("fankui_lianmengjihuo", false, true, nil, RGBA8888)  
            mc1:setScale(100)
            icon:addChild(mc1,-1) 
            self:setActionOpen(systemopen, false, systemDes)
            bgLayer:removeFromParent()
        end),
        cc.RemoveSelf:create(true)))
end

-- 设置新功能开启动画
function MainView:setActionOpen(systemopen, breakBg, systemDes)
    -- local systemDes = tab:SystemDes(systemopen)
    print("执行动画=== ")
    local btntitle = systemDes.btn

    local bgNode = self:getLayerNode()
    local bgLayer 
    if breakBg then
        bgLayer = ccui.Layout:create()
        bgLayer:setName("bgLayer")
        bgLayer:setBackGroundColorOpacity(180)
        bgLayer:setBackGroundColorType(1)
        bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
        bgLayer:setTouchEnabled(true)
        bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        bgNode:addChild(bgLayer, 1)
    else
        bgLayer = ccui.Layout:create()
        bgLayer:setName("bgLayer")
        bgLayer:setBackGroundColorOpacity(0)
        bgLayer:setBackGroundColorType(1)
        bgLayer:setTouchEnabled(true)
        bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        bgNode:addChild(bgLayer, 3)
        -- local bgLayer = bgNode
    end

    local mc = mcMgr:createViewMC("diguang_lianmengjihuo", false, true, function (_, sender)

    end, RGBA8888)  
    mc:setScale(2)       
    mc:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    bgNode:addChild(mc, 2)
            local mc1 = mcMgr:createViewMC("jihuoshuxingguang_lianmengjihuo", false, true, function (_, sender) 

            end, RGBA8888)  
            mc1:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
            bgNode:addChild(mc1,5)
    local label = cc.Label:createWithTTF(lang("OPEN_SYSTEM_NEW"), UIUtils.ttfName_Title, 40)
    label:setColor(cc.c3b(255, 254, 216))
    label:enable2Color(1, cc.c4b(255, 253, 123, 255))
    label:enableOutline(cc.c4b(60, 30, 10, 255), 2)
    label:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 + 100)
    bgNode:addChild(label, 2)
    label:setScale(2.0)
    label:runAction(cc.Sequence:create(cc.ScaleTo:create(0.25, 0.9), cc.CallFunc:create(function()
        -- label:setPurityColor(255, 255, 255)
    end), cc.ScaleTo:create(0.05, 1.0), cc.DelayTime:create(1.4), cc.FadeOut:create(0.1), cc.CallFunc:create(function()
        label:removeFromParent()
    end)))

    local icon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. systemDes.art .. ".png")
    icon:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    bgNode:addChild(icon, 2)
    icon:setScale(0)

    local noticeName = cc.Label:createWithTTF(lang(systemDes.name), UIUtils.ttfName, 29)
    noticeName:setColor(cc.c3b(255,249,181))
    noticeName:enable2Color(1, cc.c4b(233, 160, 0, 255))
    noticeName:enableOutline(cc.c4b(101, 36, 0, 255), 1)
    noticeName:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 - 70)
    bgNode:addChild(noticeName, 2)
    noticeName:setOpacity(0)
    noticeName:runAction(cc.Sequence:create(cc.FadeIn:create(0.1), cc.DelayTime:create(1.4), cc.FadeOut:create(0.1)))
    
    print("·systemopen====··", systemopen)
    -- dump(systemDes, "systemDes ===")
    local btn = self:getUI(btntitle)
    -- 单独处理点金手飞行
    if systemopen == 8 then
        local userInfoView = self._viewMgr:getNavigation("global.UserInfoView")
        btn = userInfoView:getUI("bg.bar.board2.btn") 
    end

    local scale = btn:getScale()

    local bgNodePos = btn:convertToWorldSpace(cc.p(0, 0)) 
    local iconPos = icon:convertToWorldSpace(cc.p(0, 0))
    -- local disicon = cc.pGetDistance(cc.p(bgNodePos.x, bgNodePos.y),cc.p(iconPos.x,iconPos.y))

    local posX = bgNodePos.x - iconPos.x + btn:getContentSize().width*0.5*btn:getScaleX() + systemDes.position[1] -- 165 --systemDes.position[1]
    local posY = bgNodePos.y - iconPos.y + btn:getContentSize().height*0.5*btn:getScaleY() + systemDes.position[2] -- 99 --systemDes.position[2]
    local disicon = math.sqrt(posX*posX+posY*posY)
    local speed = disicon/1000

    if tonumber(systemDes.id) == 1 then
        posX = posX - 25
    end

    local angle = math.deg(math.atan(posX/posY)) -- + 180
    if 0 <= posX and 0 <= posY then
        angle = angle + 180
    elseif  0 >= posX and 0 <= posY then
        angle = angle + 180
    elseif  0 >= posX and 0 >= posY then
        angle = angle 
    elseif  0 <= posX and 0 >= posY then
        angle = angle 
    end

    icon:runAction(cc.Sequence:create(
        cc.ScaleTo:create(0, 1.0), 
        cc.DelayTime:create(1.2), 
        -- cc.FadeOut:create(0.3),
        cc.ScaleBy:create(0.3, 0.01),
        cc.CallFunc:create(function()
            local mc2 = mcMgr:createViewMC("guangqiu_lianmengjihuo", true, false) 
            mc2:setName("mc2")
            mc2:setScale(100) 
            mc2:setRotation(angle)
            icon:addChild(mc2)

            local sp = mcMgr:createViewMC("lashentiao_lianmengjihuo", false, false)  
            sp:setAnchorPoint(cc.p(0.5, 0))
            sp:setRotation(90)
            sp:setScaleX(0)
            mc2:addChild(sp, -1)

            local scay = 1
            if disicon < 150 then
                scay = 0.5
            elseif disicon > 400 then
                scay = 2
            end
            local spSeq = cc.Sequence:create(cc.ScaleTo:create(0.2, 0, 1), cc.ScaleTo:create(speed+0.1, scay, 1), cc.ScaleTo:create(0, 0, 1), cc.FadeOut:create(0.1))
            sp:runAction(spSeq)
        end),
        cc.DelayTime:create(0.2), 
        cc.CallFunc:create(function()
            noticeName:removeFromParent()
            audioMgr:playSound("Unlock")
        end),        
        cc.Spawn:create(
            -- cc.ScaleBy:create(speed, 0.2), 
            cc.MoveBy:create(speed+0.1, cc.p(posX, posY)),
            cc.FadeOut:create(speed+0.1)),
        cc.CallFunc:create(function()
            local mc2 = icon:getChildByFullName("mc2")
            if mc2 then
                mc2:setCascadeOpacityEnabled(true)
                mc2:setOpacity(0)
            end
            local mc1 = mcMgr:createViewMC("fankui_lianmengjihuo", false, true, nil, RGBA8888)  
            mc1:setScale(100)
            icon:addChild(mc1,-1) 
            
            btn:stopAllActions()
            if string.find(btntitle, "bg.mid") ~= nil then
                btn:runAction(cc.Sequence:create(
                    cc.CallFunc:create(function()
                        btn:setOpacity(100)
                    end),
                    cc.DelayTime:create(0.3), 
                    cc.CallFunc:create(function()
                        btn:setOpacity(0)
                    end)
                     ))
            else
                btn:setOpacity(255)
                btn:runAction(cc.Sequence:create(
                    cc.CallFunc:create(function()
                        btn:setScale(scale+0.1)
                        btn:setOpacity(255)
                        btn:setBrightness(40)
                    end),
                    cc.DelayTime:create(0.3), 
                    cc.CallFunc:create(function()
                        btn:setBrightness(0)
                        btn:setScale(scale)
                    end)
                     ))
            end
        end),
        cc.DelayTime:create(1), 
        -- cc.MoveTo:create(speed, cc.p(95, MAX_SCREEN_HEIGHT - 37)), 
        cc.CallFunc:create(function ()
            local mc2 = icon:getChildByFullName("mc2")
            if mc2 then
                mc2:setOpacity(0)
            end
            bgLayer:removeFromParent()
            -- 新手引导
            self._viewMgr:unlock()
            if systemDes.id < 100 then
                self._viewMgr:doNewoverGuide()
            else
                GuideUtils.checkTriggerByType("open", systemDes.id)
            end
            -- print("引导执行结束======================================")
            -- self:setQipao()
            -- local mainViewModel = self._modelMgr:getModel("MainViewModel")
            -- self:removeQipao(mainViewModel:getTipsQipao())
        end), 
        cc.RemoveSelf:create(true)))
end

--根据VIPLevel 获得数据
function MainView:getLvlByVipLevel(index)
    if not index then return end
    local Lvl
    --获取第一个大于当前值的数据
    for k,v in pairs(activityLvL) do
        if index <= v then
            Lvl = k
            break
        end
    end
    if not Lvl then
        Lvl = -1
    end
    return Lvl
end

--更新按钮显示
function MainView:updateActivityBtn(index)
    if not index or index == -1 then return end

    local data = activetyBtnData[index]
    -- 至尊月卡
    if index == 2 then
        -- hMCardData["expireTime"] 至尊月卡到期时间
        local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()   --当前时间
        local vipData = self._modelMgr:getModel("VipModel"):getData()  
        local hMCardData = vipData["mCard"] and vipData["mCard"]["payment_monthsuper"] or nil  
        local isBuy = (hMCardData and hMCardData["expireTime"]) and hMCardData["expireTime"] >= curTime or false  --是否已购买       
        if isBuy then       -- 如果有至尊月卡 则显示四星凤凰
            index = tonumber(data.toIndex)
            data = activetyBtnData[index]
        end
    end

    -- print("======index===========",index)
    -- local vipData = self._modelMgr:getModel("VipModel"):getData() 
    -- local mCardData = (vipData["mCard"] and vipData["mCard"]["payment_month"]) or nil  
    -- local hMCardData = vipData["mCard"] and vipData["mCard"]["payment_monthsuper"] or nil 
    -- if index == 1 then
    --     local vipData = self._modelMgr:getModel("VipModel"):getData() 
    --     local mCardData = (vipData["mCard"] and vipData["mCard"]["payment_month"]) or nil          
    --     if mCardData then   --显示至尊月卡
    --         index = tonumber(data.toIndex)
    --         data = activetyBtnData[index]
    --     end
    -- elseif index == 2 then   
    --     local vipData = self._modelMgr:getModel("VipModel"):getData() 
    --     local mCardData = (vipData["mCard"] and vipData["mCard"]["payment_month"]) or nil       
    --     if mCardData then   --显示至尊月卡
    --         index = tonumber(data.toIndex)
    --         data = activetyBtnData[index]
    --     end
    -- elseif index == 3 then
    --     local vipData = self._modelMgr:getModel("VipModel"):getData()  
    --     local hMCardData = vipData["mCard"] and vipData["mCard"]["payment_monthsuper"] or nil         
    --     if hMCardData then   -- 显示英雄升星  显示四星
    --         index = tonumber(data.toIndex)
    --         data = activetyBtnData[index]
    --     end
    -- end
    -- dump(data,"activityData")
    --{vipLVlMin:5,vipLvlMax:8,toViewData{name:"vip.VipView",type:1,index:10},tstImg:"btn_siqi3_txt.png",iconName:"button_siqi_mainView.png"}

    local btnImg = data.iconName
    local txtImgName = data.txtImg
    local btn = self:getUI("rightLayer.rightBtnLayer.vipBtn")
    local mc = btn._effectMc
    if not tolua.isnull(mc) then
        mc:removeFromParent()
    end
    
    if data.effect then
        local mc = mcMgr:createViewMC(data.effect, true,false,nil,RGBA8888)
        mc:setPosition(btn:getContentSize().width/2,btn:getContentSize().height/2)
        mc:setScale(0.8)
        mc:setTag(100)
        btn._effectMc = mc
        btn:setOpacity(0)
        btn:addChild(mc,0)
    else
        btn:setOpacity(255)
    end
    -- self._rightVipBtn
    btn:loadTextures(btnImg,btnImg,btnImg,1)
    createUpBtnTitleLabel(btn, txtImgName, tonumber(data.pos.x), tonumber(data.pos.y),data.fontSize)

    self:registerClickEventByName("rightLayer.rightBtnLayer.vipBtn", function ()
        self._bg:stopScroll()  
        --1:活动月卡 2:vip
        if data.toViewData.name and data.toViewData.jumpType then  
            local viewParam = {}
            if 1 == data.toViewData.jumpType then
                viewParam.specifiedActivityId = data.toViewData.specifiedAcId or 100
            elseif 2 == data.toViewData.jumpType then
                viewParam.viewType = data.toViewData.type or 1
                viewParam.index = data.toViewData.index or 0
            end 
            self._viewMgr:showView(data.toViewData.name, viewParam) 
        end          

    end)
end

function MainView:showGodWarDialog()
    local callback1 = function()
        -- 廣告結束 再開始檢測 跨服諸神邀請函和64強展示
        self:checkCrossGodWarInvitation()
        local tempNoticeId = self._modelMgr:getModel("MainViewModel"):isOpenShowNotice(true)
        local actionFlag = self._modelMgr:getModel("MainViewModel"):getActionOpen()
        print("\nactionFlag========", actionFlag)
        local callback2 = function()
            self._isCloseAd = true
        end
        if actionFlag then
            self._viewMgr:lock(-1)
            self:actionOpen()
            self._modelMgr:getModel("MainViewModel"):clearActionOpen()
            self._modelMgr:getModel("LeagueModel"):isShowCurBatchInTipMc(true) -- 第一次进如果没播积分联赛开启就不播了
            callback2()
        else
            local isShowGvgMc = self._modelMgr:getModel("CityBattleModel"):checkGvgOpenMc()
            local isOpen,openDes = LeagueUtils:isLeagueOpen(101,true)
            local gloryIsOpen = self._modelMgr:getModel("GloryArenaModel"):lIsStartContion()
            if isShowGvgMc then
                self:showGvgOpenMc(callback2)
            elseif self._modelMgr:getModel("SiegeModel"):isShowMainViewFly() then
                local _,status = self._modelMgr:getModel("SiegeModel"):isShowMainViewFly()
                self:showSiegeOpenMc(status, callback2)
            elseif isOpen == true then
                self:showLeagueOpenMC(callback2)
            elseif gloryIsOpen == true then
                self:showGloryArenaOpenMC(callback2)
            else
                callback2()
            end
        end
    end
    local godWarModel = self._modelMgr:getModel("GodWarModel")
    local gtype = godWarModel:getShowDialogType()
    -- self._inActionFirst = true
    print("gtype===========", gtype)
    if self._inActionFirst == false then
        if gtype == 1 then -- 拍脸图
            local param = {callback = callback1, gtype = 1}
            self._viewMgr:showDialog("godwar.GodWarPailianDialog", param)
        elseif gtype == 2 then -- 周一 黑名单
            local param = {callback = callback1, gtype = 2}
            self._viewMgr:showDialog("godwar.GodWarAudienceDialog", param)
        elseif gtype == 3 then -- 冠军
            local param = {callback = callback1, gtype = 3}
            self._viewMgr:showDialog("godwar.GodWarChampionDialog", param)
        elseif gtype == 4 then -- 周二黑名单
            local param = {callback = callback1, gtype = 4}
            self._viewMgr:showDialog("godwar.GodWarAudienceDialog", param)
        elseif gtype == 5 then -- 8强
            local param = {callback = callback1, gtype = 5}
            self._viewMgr:showDialog("godwar.GodWarAudienceDialog", param)
        elseif gtype == 6 then -- 4强
            local param = {callback = callback1, gtype = 6}
            self._viewMgr:showDialog("godwar.GodWarAudienceDialog", param)
        else
            callback1()
        end
        self._inActionFirst = true
    else
        callback1()
    end
end


--广告  wangyan
function MainView:showAdView()
    local adModel = self._modelMgr:getModel("AdvertisementModel") 
    local function callback1()
        self:showGodWarDialog()
        -- local tempNoticeId = self._modelMgr:getModel("MainViewModel"):isOpenShowNotice(true)
        -- local actionFlag = self._modelMgr:getModel("MainViewModel"):getActionOpen()
        -- print("\nactionFlag========", actionFlag)
        -- if actionFlag then
        --     self._viewMgr:lock(-1)
        --     self:actionOpen()
        --     self._modelMgr:getModel("MainViewModel"):clearActionOpen()
        --     self._modelMgr:getModel("LeagueModel"):isShowCurBatchInTipMc(true) -- 第一次进如果没播积分联赛开启就不播了
        -- else
        --     self:showLeagueOpenMC()
        -- end
    end

    if adModel:getAdState() == false and   --是否已弹出过
                self._isShowAd == true and         --是否过新手引导可以弹广告
                    next(adModel:getAdList()) ~= nil then  --是否有广告
        self._viewMgr:showDialog("activity.AdvertisementView", {callback = callback1}, true)
        adModel:setAdState(true)
    else
        callback1()
    end
end

--周签界面
function MainView:showWeekSignView()
    local isShowWeek = self._modelMgr:getModel("MainViewModel"):checkOpenWeekSign()
    if isShowWeek then
        if self._isShowAd == true then
            self._serverMgr:sendMsg("WeeklySignServer", "getweeklySignInfo", {}, true, {}, function(result)
                if not result then return end
                self._isInWeekSign = true
                self._viewMgr:showDialog("activity.ActivityWeekSignView", {callback = function ()
                    self:showAdView()
                    self._isInWeekSign = false
                end,data = result}, true)
            end)

            -- self._viewMgr:showDialog("activity.ActivityWeekSignView", {callback = function ()
            --     self:showAdView()
            -- end,data = result}, true)
        end
    else
        self:showAdView()
    end
end

-- 冠军对决 开启动画提示
function MainView:showLeagueOpenMC( callback )
    self:detectLeagueOpen(function( )
        local leagueOpen = LeagueUtils:isLeagueOpen()
        local isShowCurBatchMc = self._modelMgr:getModel("LeagueModel"):isShowCurBatchInTipMc(true)
        local isInRest = self._modelMgr:getModel("LeagueModel"):isInMidSeasonRestTime()
        if leagueOpen and isShowCurBatchMc and not isInRest then
            self._viewMgr:showDialog("league.LeagueOpenFlyView", {target = self:getUI("bg.midBg3.pve"),callback = callback}, true) 
        else
            --这个时候如果冠军对局赛季不能弹出就判断是否可以弹出荣耀竞技场
            self:showGloryArenaOpenMC(callback)
        end
    end)
end

-- 荣耀竞技场赛季开启条件请求
function MainView:showGloryArenaOpenMC(callback)
    local gloryArenaMode = self._modelMgr:getModel("GloryArenaModel")
    local open = gloryArenaMode:lIsStartContion()
    function checkOpenGloryArena()
        local _open = gloryArenaMode:lIsOpen()
        if _open and gloryArenaMode:lCheckSeason() then
            self._viewMgr:showDialog("gloryArena.GloryArenaOpenFlyView", {target = self:getUI("bg.midBg3.pve"),callback = callback}, true) 
        end
    end
    if open then
        --判断是否开启新的赛季，是的花弹出提示
        if gloryArenaMode:lGetSeason() == 0 then
            --这个时候需要获取数据
            gloryArenaMode:reflashEnterCrossArena(checkOpenGloryArena())
        else
            checkOpenGloryArena()
        end
    end
end

--[[
   gvg开启动画提示
]]
function MainView:showGvgOpenMc(callback)
    self._viewMgr:showDialog("citybattle.CityBattleOpenView", {target = self:getUI("bottomLayer.instanceBtn"), callback = callback}, true)
end

--[[
   攻城战开启提示
]]
function MainView:showSiegeOpenMc(status, callback)
    self._viewMgr:showDialog("siege.SiegeOpenFlyView", {target = self:getUI("bottomLayer.instanceBtn"), status = status, callback = callback}, true)
end

--好友红点 by wangyan
function MainView:showFriendRedPoint()
    local _friendRed = self:getUI("topLayer.friendBtn.redPoint")
    local _friendModel = self._modelMgr:getModel("FriendModel")
    _friendRed:setPosition(47,42)

    --friend
    local friRedPoint = _friendModel:checkFriendRedPoint()  --好友
    local isPhyUper = _friendModel:checkIsPhysicalUper()   --体力领取上限
    --add
    local addRedPoint = _friendModel:checkAddRedPoint()  --添加

    if (friRedPoint and not isPhyUper) or addRedPoint then
        _friendRed:setVisible(true)
    else
        _friendRed:setVisible(false)
    end
end

--好友召回红点 by wangyan
function MainView:showFRecallRedPoint(inData)
    local recallModel = self._modelMgr:getModel("FriendRecallModel")
    local userModel = self._modelMgr:getModel("UserModel")
    
    if inData == "friendAct" then   --活动
        local recallAcBtn = self:getUI("rightLayer.rightBtnLayer.recallAcBtn")
        local haveNotice = recallModel:checkAcRedPoint()
        self:updateBtnRed(recallAcBtn, haveNotice,cc.p(54,54))
    end

    if inData == "fShop" then       --商店
        local fRedPoint = self:getUI("topLayer.fShopBtn.redPoint")
        fRedPoint:setVisible(false)
        
        local dayNum = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(79) or 0
        local dayMax = tab.setting["FRIEND_RETURN_INVITECOINS_LIMIT"].value

        local isHasRcl = recallModel:checkIsHasRecall()

        local lastT = SystemUtils.loadAccountLocalData("LAST_TIME_ENTER_FSHOP_VIEW") or 0
        local curTime = userModel:getCurServerTime()
        local sec_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 05:00:00"))
        if curTime < sec_time then   --过零点判断
            sec_time = sec_time - 86400
        end

        if dayNum < dayMax and isHasRcl and lastT < sec_time then
            fRedPoint:setVisible(true)
        end
    end
end

--春节红包红点
function MainView:showSpringRedRedPoint()
    local sRedBtn = self:getUI("rightLayer.rightBtnLayer.sprRedBtn")
    local sRedModel = self._modelMgr:getModel("SpringRedModel")
    local haveNotice = sRedModel:isShowRedPoint()
    self:updateBtnRed(sRedBtn, haveNotice,cc.p(54,54))
end

function MainView:refreshWorldCupRedPoint()
    local haveNotice = self._modelMgr:getModel("WorldCupModel"):isMainViewRedPoint()
    local worldCupBtn = self:getUI("rightLayer.rightBtnLayer.worldCupBtn")
    self:updateBtnRed(worldCupBtn,haveNotice,cc.p(54,54))
end

-- 打开领主手册界面
function MainView:showHandbookView()
    if not SystemUtils:enableHandbook() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end

    local redData = {callback = function ( )
        -- self:checkRightUpBtnRed()
    end}

--    package.loaded["game.view.handbook.HandbookView"] = nil
    self._viewMgr:showView("handbook.HandbookView", {redData = redData})
end

function MainView:onDoGuide(config)
    if config.showGuildTuDialog ~= nil then
        self._viewMgr:showDialog("global.CommonNewGuideDialog",{showType = 1},true)
    end
end

-- 返回主界面时候，关闭弹窗
function MainView:onReturnMain()
    local popViewLists = self:getPopViews()
    for view, _ in pairs(popViewLists) do
        if view:getClassName() == "activity.ActivityCarnival" then
            view:doClose(true)
        end
    end
end

function MainView:updateGodWarTitle(notReStartTimer)
    local timeLab = self:getUI("bg.midBg4_5.cloudy.timeLab")
    local godWarModel = self._modelMgr:getModel("GodWarModel")
    local closeGodWar = godWarModel:getCloseGodWar()
    if closeGodWar == false then
        timeLab:setVisible(false)
        return
    end
    local titleLab = timeLab.titleLab
    if not titleLab then
        timeLab:setVisible(true)
        local posx = timeLab:getContentSize().width * 0.5
        local posy = timeLab:getContentSize().height * 0.5
        local mc = mcMgr:createViewMC("diguang_itemeffectcollection", true,false)
        mc:setScaleX(0.7)
        mc:setScaleY(0.3)
        mc:setOpacity(185)
        mc:setHue(-170)
        mc:setPosition(posx, posy)
        mc:setName("mc")
        timeLab:addChild(mc,-1)

        titleLab = cc.Label:createWithTTF("", UIUtils.ttfName, 12)
        titleLab:setColor(cc.c3b(255, 255, 255))
        titleLab:enableOutline(cc.c4b(60, 30, 10, 255), 2)
        titleLab:setPosition(posx, posy)
        timeLab:addChild(titleLab)
        timeLab.titleLab = titleLab
    end
    local _,openTimeStr,openTime = godWarModel:getOpenTime()
    if not titleLab:getActionByTag(123) then
        local action = cc.RepeatForever:create(
            cc.Sequence:create(
                cc.CallFunc:create(function( )
                    local _,openTimeStr,openTime = godWarModel:getOpenTime()
                    if openTime < 3600 and openTime >= 1 then
                        titleLab:setString(openTimeStr)
                        timeLab:setVisible(true)
                    elseif openTime <= 0 then
                        if openTime < -5 then
                            titleLab:stopAllActions()
                        end
                        self:updateGodWarTitle(true)
                    end
                end),
                cc.DelayTime:create(1)
            )
        )
        action:setTag(123)
        if not notReStartTimer and SystemUtils["enableLeague"]() then
            titleLab:runAction(action)
        end
    end
    if godWarModel:isGetInfoGodWar() == false then
        if not (openTime < 3600 and openTime > 1) or not SystemUtils["enableLeague"]() then 
            timeLab:setVisible(false)
        end
        return
    end
    local titleStr = godWarModel:getMainTitle()
    if titleStr == "" then
        if openTime < 3600 and openTime > -2 then
        else
            timeLab:setVisible(false)
        end
    else
        timeLab:setVisible(true)
        titleLab:setString(titleStr)
    end

end

-- 展示特权buff
function MainView:showPrivilegesBuff()
    local topLayer = self:getUI("topLayer")
    self._privilegeModel = self._modelMgr:getModel("PrivilegesModel")
    local buffSum = {}
    local indexId = 1
    local tbuffNum = tab:Setting("G_PRIVILEGES_SHOP_BUFF_NUM").value
    local flag = false
    for i=1,tbuffNum do
        flag, _ = self._privilegeModel:getKingBuff(i)
        if flag == true then
            break
        end
    end
    if flag then
        if not topLayer.__buffIcon1 then
            local buffIcon = ccui.ImageView:create()
            buffIcon:loadTexture("privileges_buffBtn_mainView.png",1)
            buffIcon:setScale(0.35)
            buffIcon:setPosition(250,86)
            topLayer.__buffIcon1 = buffIcon
            topLayer:addChild(buffIcon,29)
            local buffFrame = ccui.ImageView:create()
            buffFrame:loadTexture("globalImageUI4_squality5.png",1)
            buffFrame:setPosition(45,45)
            buffIcon:addChild(buffFrame)
            self:registerClickEvent(buffIcon, function()
                local privilegesTip = self:getUI("topLayer.privilegesTip")
                privilegesTip:setCapInsets(cc.rect(30, 30, 1, 1))
                self:showPrivilegesBuffTip(privilegesTip)
            end)
        else
            topLayer.__buffIcon1:setVisible(true)
        end
    else
        if topLayer.__buffIcon1 then
            topLayer.__buffIcon1:setVisible(false)
        end
    end

    if not self._backflowModel then 
        self._backflowModel = self._modelMgr:getModel("BackflowModel")
    end
    if self._backflowModel:isPrivilegeOpen() then
        if not topLayer.__buffIcon2 then
            local buffIcon = ccui.ImageView:create()
            buffIcon:loadTexture("backFlow_buffBtn_mainView.png",1)
            buffIcon:setScale(0.35)
            buffIcon:setPosition(215,86)
            topLayer.__buffIcon2 = buffIcon
            topLayer:addChild(buffIcon,29)
            local buffFrame = ccui.ImageView:create()
            buffFrame:loadTexture("globalImageUI4_squality5.png",1)
            buffFrame:setPosition(45,45)
            buffIcon:addChild(buffFrame)
            self:registerClickEvent(buffIcon, function()
                local privilegesTip = self:getUI("topLayer.privilegesTip")
                privilegesTip:setCapInsets(cc.rect(30, 30, 1, 1))
                self:showBackFlowBuffTip(privilegesTip)
            end)
        else
            topLayer.__buffIcon2:setVisible(true)
        end
    else
        if topLayer.__buffIcon2 then
            topLayer.__buffIcon2:setVisible(false)
        end
    end
    
end

-- 特权buff tips
function MainView:showPrivilegesBuffTip(inView)
    inView:setVisible(true)
    local layer1 = inView.__layer1
    local layer2 = inView.__layer2
    if layer1 then
        layer1:setVisible(true)
    else
        layer1 = ccui.Layout:create()
        -- layer1:setBackGroundColorOpacity(40)
        -- layer1:setBackGroundColorType(1)
        -- layer1:setBackGroundColor(cc.c3b(0,0,0))
        -- layer1:setContentSize(100,100)
        inView:addChild(layer1)
        inView.__layer1 = layer1
    end
    if layer2 then
        layer2:setVisible(false)
    end
    self._privilegeModel = self._modelMgr:getModel("PrivilegesModel")
    local buffSum = {}
    local tbuffNum = tab:Setting("G_PRIVILEGES_SHOP_BUFF_NUM").value
    for i=1,tbuffNum do
        local buffIcon = layer1:getChildByName("buffIcon" .. i)
        if buffIcon then
            buffIcon:setVisible(false)
        end
        local richText = layer1:getChildByName("richText" .. i)
        if richText then
            richText:removeFromParent()
        end
        local flag, buffId = self._privilegeModel:getKingBuff(i)
        local buffNum = tonumber(buffId)
        local buffTab = tab:PeerShop(buffNum)
        if flag == true then
            table.insert(buffSum, i)
        end
    end

    local tsplit = function(str,reps)
        local des = string.gsub(str,"%b{}",function( lvStr )
            local str = string.gsub(lvStr,"%$num",reps)
            return loadstring("return " .. string.gsub(str, "[{}]", ""))()
        end)
        return des 
    end

    local posY = table.nums(buffSum)*40 + 20
    inView:setContentSize(cc.size(220, posY))
    layer1:setContentSize(cc.size(220, posY))
    posY = posY - 10
    for i=1,table.nums(buffSum) do
        local indexId = buffSum[i]
        local flag, buffId = self._privilegeModel:getKingBuff(indexId)
        local buffNum = tonumber(buffId)
        local buffTab = tab:PeerShop(buffNum)
        local param = {image = buffTab.icon .. ".png", quality = 5, scale = 0.90, bigpeer = true}
        local buffIcon = layer1:getChildByName("buffIcon" .. i)
        if buffIcon then
            IconUtils:updatePeerageIconByView(buffIcon, param)
        else
            buffIcon = IconUtils:createPeerageIconById(param)
            buffIcon:setAnchorPoint(0.5, 0.5)
            buffIcon:setScale(0.3)
            buffIcon:setName("buffIcon" .. i)
            layer1:addChild(buffIcon)
        end
        buffIcon:setPosition(35,posY - i*38 + 19)
        buffIcon:setVisible(true)

        local sysBuf = buffTab.buff
        local str = lang(buffTab.des)
        str = tsplit(str,sysBuf[2])
        local result, count = string.gsub(str, "$num", sysBuf[2])
        if count > 0 then 
            str = result
        end
        local richText = layer1:getChildByName("richText" .. i)
        if richText then
            richText:removeFromParent()
        end
        richText = RichTextFactory:create(str, 180, 40)
        richText:formatText()
        richText:setPosition(140, posY - i*38 + 19)
        richText:setName("richText" .. i)
        layer1:addChild(richText)
    end
end

-- 回归任务buff tips
function MainView:showBackFlowBuffTip(inView)
    inView:setVisible(true)
    local layer1 = inView.__layer1
    local layer2 = inView.__layer2
    if layer2 then
        layer2:setVisible(true)
    else
        layer2 = ccui.Layout:create()
        -- layer2:setBackGroundColorOpacity(40)
        -- layer2:setBackGroundColorType(1)
        -- layer2:setBackGroundColor(cc.c3b(0,0,0))
        -- layer2:setContentSize(100,100)
        inView:addChild(layer2)
        inView.__layer2 = layer2
    end
    if layer1 then
        layer1:setVisible(false)
    end
    if not self._backflowModel then 
        self._backflowModel = self._modelMgr:getModel("BackflowModel")--:getBackflowOpen()
    end
    local privilegeData = self._backflowModel:getReturnPrivilege()
    local buffIndex = {
        [1] = {key="dragonCountry", titleTxt="龙之国",    des="技能符石收益翻倍"},
        [2] = {key="battle",        titleTxt="战役",      des="帝国勋章收益翻倍"},
        [3] = {key="cloudCity",     titleTxt="云中城",    des="天赋药剂收益翻倍"},
        [4] = {key="element",       titleTxt="元素位面",  des="位面碎片收益翻倍"},
    }
    local num = 0
    for i=1,4 do
        local buffData = privilegeData[buffIndex[i].key]
        if buffData ~= nil then
            num = num + 1
        end
    end

    local posY = num*30 + 20 + 40 -- +40 剩余时间高度
    inView:setContentSize(cc.size(300, posY))
    layer2:setContentSize(cc.size(300, posY))
    posY = posY - 25
    for i=1,4 do
        local data = buffIndex[i]
        local buffData = privilegeData[data.key]
        if buffData ~= nil then
            if layer2["__titleTxt" .. i] then
                layer2["__titleTxt" .. i]:setVisible(true)
                layer2["__titleTxt" .. i]:setString(data.titleTxt)
            else                
                local titleTxt = ccui.Text:create()
                titleTxt:setString(data.titleTxt)
                titleTxt:setFontSize(20)
                titleTxt:setFontName(UIUtils.ttfName)
                titleTxt:setColor(cc.c3b(255, 255, 255))
                titleTxt:setAnchorPoint(0,0.5)
                titleTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
                titleTxt:setPosition(20,posY)
                layer2:addChild(titleTxt)
                layer2["__titleTxt" .. i] = titleTxt
            end
            if layer2["__des"..i] then
                layer2["__des"..i]:setVisible(true)
                layer2["__des"..i]:setString(data.des)
            else
                local des = ccui.Text:create()
                des:setString(data.des)
                des:setFontSize(20)
                des:setFontName(UIUtils.ttfName)
                des:setColor(cc.c3b(255, 255, 255))
                des:setAnchorPoint(0,0.5)
                des:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
                des:setPosition(120,posY)
                layer2["__des"..i] = des
                layer2:addChild(des)
            end            

            posY = posY - 30
        else
            if layer2["__titleTxt" .. i] then
                layer2["__titleTxt" .. i]:setVisible(false)
            end 
            if layer2["__des"..i] then
                layer2["__des"..i]:setVisible(false)
            end
        end
    end
    -- 添加倒计时
    if not layer2.__timeTxt then
        local currTime = self._userModel:getCurServerTime() 
        local endTime = privilegeData.endTime or 0

        local timeDes = ccui.Text:create()
        timeDes:setString("剩余时间：")
        timeDes:setFontSize(20)
        timeDes:setFontName(UIUtils.ttfName)
        timeDes:setColor(cc.c3b(255, 255, 255))
        timeDes:setAnchorPoint(0,0.5)
        timeDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        timeDes:setPosition(20,20)
        layer2:addChild(timeDes)
        layer2.__timeDes = timeDes

        local timeTxt = ccui.Text:create()
        timeTxt:setFontSize(20)
        timeTxt:setFontName(UIUtils.ttfName)
        timeTxt:setColor(cc.c3b(255, 255, 255))
        timeTxt:setAnchorPoint(0,0.5)
        timeTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        timeTxt:setPosition(120,20)
        layer2:addChild(timeTxt)
        layer2.__timeTxt = timeTxt


        local day, hour, min, sec, tempValue
        tempTime = endTime - currTime
        layer2.__timeTxt:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.CallFunc:create(function()
                tempValue = tempTime
                day = math.floor(tempValue/86400) 
                tempValue = tempValue - day*86400

                hour = math.floor(tempValue/3600)
                tempValue = tempValue - hour*3600

                min = math.floor(tempValue/60)
                tempValue = tempValue - min*60

                sec = math.fmod(tempValue, 60)
                local showTime
                if tempTime <= 0 then
                    showTime = "00天00:00:00"
                    layer2.__timeTxt:stopAllActions()
                else
                    showTime = string.format("%.2d天%.2d:%.2d:%.2d", day, hour, min, sec)
                end                
                tempTime = tempTime - 1
                layer2.__timeTxt:setString(showTime)
            end),cc.DelayTime:create(1))
        ))

    end

end

function MainView:applicationWillEnterForeground()
    if self._battery then
        self._battery:setPercent(sdkMgr:getBatteryPercent() * 100)
    end
    if self.updateInstanceBtnImage then
        self:updateInstanceBtnImage()
    end
end

-- 切换主城背景
function MainView:changeBG()
    local sfc = cc.SpriteFrameCache:getInstance()
    local tc = cc.Director:getInstance():getTextureCache() 
    local oldmainViewVer = mainViewVer
    local oldbgNameExt = bgNameExt
    mainViewVer = TimeUtils.mainViewVer
    if oldmainViewVer == mainViewVer then return end
    if mainViewVer == nil then
        mainViewVer = 2
    end
    if mainViewVer == 1 then
        bgNameExt = ""
    else
        bgNameExt = tostring(mainViewVer)
    end
    sfc:removeSpriteFramesFromFile("asset/bg/mainViewBg"..oldbgNameExt..".plist")
    tc:removeTextureForKey("asset/bg/mainViewBg"..oldbgNameExt..".png")
    self._backBg.backBg1:setSpriteFrame("bg_head_mainView.png")
    self._backBg.backBg2:setSpriteFrame("bg_head_mainView.png")
    self._backBg.backBg3:setSpriteFrame("bg_head_mainView.png")
    self._fgSp2:setSpriteFrame("bg_head_mainView.png")
    for i = 1, #self._maps do
        self._maps[i][1]:loadTexture("bg_head_mainView.png", 1)
    end
    local _cloudCity = self:getUI("bg.midBg4_5.Image_52")
    _cloudCity:loadTexture("bg_head_mainView.png", 1)
    sfc:addSpriteFrames("asset/bg/mainViewBg"..bgNameExt..".plist", "asset/bg/mainViewBg"..bgNameExt..".png")
    self._backBg.backBg1:setSpriteFrame("bg_mainview.png")
    self._backBg.backBg2:setSpriteFrame("bg_mainview.png")
    self._backBg.backBg3:setSpriteFrame("bg_mainview.png")
    if mainViewVer == 3 then
        self._backBg2:setSpriteFrame("bg_mainview1.png")
    end
    self._fgSp2:setSpriteFrame("mainviewfg_1_2.png")
    for i = 1, #self._maps do
        self._maps[i][1]:loadTexture(self._maps[i][2], 1)
    end
    _cloudCity:loadTexture("cloud_mainView"..bgNameExt..".png", 1)
    self:changeBGMC()
end

function MainView:changeBGMC()
    if self._BGMC then
        for i = 1, #self._BGMC do
            self._BGMC[i]:removeFromParent()
        end
        self._BGMC = nil
    end
    mcMgr:clear()
    -- if mainViewVer == 2 then
    --     self._BGMC = {}
    --     local bg5 = self:getUI("bg.midBg5")
    --     local mc = mcMgr:createViewMC("yun_donghuafla", true, false)
    --     mc:setScale(0.65)
    --     mc:setPosition(580, 320)
    --     bg5:addChild(mc, -1)
    --     self._BGMC[#self._BGMC + 1] = mc

    --     local bg4 = self:getUI("bg.midBg4")
    --     local mc = mcMgr:createViewMC("shi2_donghuafla", true, false)
    --     mc:setScale(0.7)
    --     mc:setPosition(320, 410)
    --     bg4:addChild(mc, -1)
    --     self._BGMC[#self._BGMC + 1] = mc

    --     local bg4_5 = self:getUI("bg.midBg4_5")
    --     local mc = mcMgr:createViewMC("shi1_donghuafla", true, false)
    --     mc:setScale(0.7)
    --     mc:setPosition(1250, 380)
    --     bg4_5:addChild(mc, -1)
    --     self._BGMC[#self._BGMC + 1] = mc
    -- end
    if mainViewVer == 3 then
        self._BGMC = {}
        local mc = mcMgr:createViewMC("xingxing_xingxing", true, false)
        mc:setScale(0.5)
        mc:setPosition(self._backBg2:getContentSize().width * 0.5, self._backBg2:getContentSize().height * 0.5)
        self._backBg2:addChild(mc)
        self._BGMC[#self._BGMC + 1] = mc
    end
    print("========changeBGMC=========")
    if TimeUtils.mainViewActIsOpen(TimeUtils.Year) then
        local hour = tonumber(os.date("%H"))
        local isShow = false
        if hour >= 5 and hour < 20 then
        else
            isShow = true
        end
        if isShow then
            self._yanHuaNode1 = self:createYanHuaAni(1)
            -- self._yanHuaNode1:stop()
            self._yanHuaNode2 = self:createYanHuaAni(2)
            -- self._yanHuaNode2:stop()
        end
    end
end

function MainView:createYanHuaAni(sceneNum)
    local mc = mcMgr:createViewMC("zhuchengyanhua_yanhua", false, false)

    local mcColorTab = {
        ["yellow"] = {["B"] = 0 , ["S"] = 0 ,["H"] = 0},        --黄
        ["spice"] = {["B"] = 0 , ["S"] = 0 ,["H"] = 0},        --橙
        ["green"] = {["B"] = 0 , ["S"] = 0 ,["H"] = 77},      --绿
        ["purple"] = {["B"] = 0 , ["S"] = -1 ,["H"] = -68},    --紫
        ["blue"] = {["B"] = 11 , ["S"] = 0 ,["H"] = 158},    --蓝
    }
    for k , v in pairs(mc:getChildren()) do
        local name = v:getName()
        v:setHue(tonumber(mcColorTab[name]["H"]))
        v:setBrightness(tonumber(mcColorTab[name]["B"]))
        v:setSaturation(tonumber(mcColorTab[name]["S"]))
    end
    local bgContainerSiseWidth = self._bg:getInnerContainerSize().width
    local posTable = {
                        [1] = {posX = bgContainerSiseWidth*0.25},
                        [2] = {posX = bgContainerSiseWidth*0.75}
                    }
    mc:setPosition(posTable[sceneNum].posX, MAX_SCREEN_HEIGHT/2)
    self._bg:addChild(mc,10)
    self._BGMC[#self._BGMC + 1] = mc
    return mc
end

function MainView:updateYanHuaAni(dt)
    local dt = dt or 0
    -- print("=====updateYanHuaAni======")
    if TimeUtils.mainViewActIsOpen(TimeUtils.Year) then
        local hour = tonumber(os.date("%H"))
        local isShow = false
        if hour >= 5 and hour < 20 then
        else
            isShow = true
        end
        dtTime1 = dtTime1 + dt
        -- print("=====hour======"..hour)
        if isShow then
            -- print("=====dtTime1======"..dtTime1)
            if dtTime1 >= 20 then
                dtTime1 = 0
                if self._yanHuaNode1 then
                    self._yanHuaNode1:addEndCallback(function()
                        if self._yanHuaNode1 then
                            self._yanHuaNode1:stop()
                            self._yanHuaNode1:setVisible(false)
                        end
                    end)
                    self._yanHuaNode1:setVisible(true)
                    self._yanHuaNode1:gotoAndPlay(0)
                end
                if self._yanHuaNode2 then
                    ScheduleMgr:delayCall(4000, self, function( )
                        self._yanHuaNode2:addEndCallback(function()
                            if self._yanHuaNode2 then
                                self._yanHuaNode2:stop()
                                self._yanHuaNode2:setVisible(false)
                            end
                        end)
                        self._yanHuaNode2:setVisible(true)
                        self._yanHuaNode2:gotoAndPlay(0)
                    end)
                end                
            end
        end
    end
end

function MainView:setJieRi()
    -- 节日
    if TimeUtils.mainViewActIsOpen(TimeUtils.Year) then
        isJieRi = true
    end
    local jieriIcon
    jieriIcon = self:getUI("bg.midBg2.jieri1")
    if jieriIcon then jieriIcon:setVisible(isJieRi) end
    jieriIcon = self:getUI("bg.midBg2.jieri2")
    if jieriIcon then jieriIcon:setVisible(isJieRi) end
    jieriIcon = self:getUI("bg.midBg3.jieri3")
    if jieriIcon then jieriIcon:setVisible(isJieRi) end
    jieriIcon = self:getUI("bg.midBg1.jieri4")
    if jieriIcon then jieriIcon:setVisible(isJieRi) end
    jieriIcon = self:getUI("bg.midBg1.jieri5")
    if jieriIcon then jieriIcon:setVisible(isJieRi) end
    jieriIcon = self:getUI("bg.midBg4.jieri6")
    if jieriIcon then jieriIcon:setVisible(isJieRi) end
    jieriIcon = self:getUI("bg.midBg1.jieri7")
    if jieriIcon then jieriIcon:setVisible(isJieRi) end

    if self._JIERIMC then
        for i = 1, #self._JIERIMC do
            self._JIERIMC[i]:removeFromParent()
        end
        self._JIERIMC = nil
    end

    mcMgr:clear()
    if isJieRi then
        self._JIERIMC = {}
        -- 节日动画
        local bg1 = self:getUI("bg.midBg1")
        local bg2 = self:getUI("bg.midBg2")
        local bg4 = self:getUI("bg.midBg4")
        local bg5 = self:getUI("bg.midBg5")

        local mc = mcMgr:createViewMC("zhuchengqizi6_qizi", true, false)
        mc:setPosition(1162, 336)
        mc:setBrightness(-9)
        mc:setContrast(12)
        mc:setSaturation(-16)
        mc:setHue(-116)
        bg1:addChild(mc, 99)
        self._JIERIMC[#self._JIERIMC + 1] = mc

        local mc = mcMgr:createViewMC("zhuchengqizi7_qizi", true, false)
        mc:setPosition(1649, 425)
        bg1:addChild(mc, 99)
        self._JIERIMC[#self._JIERIMC + 1] = mc

        local mc = mcMgr:createViewMC("zhuchengqizi2_qizi", true, false)
        mc:setPosition(457, 353)
        bg2:addChild(mc, 99)
        self._JIERIMC[#self._JIERIMC + 1] = mc

        local mc = mcMgr:createViewMC("zhuchengqizi3_qizi", true, false)
        mc:setPosition(731, 315)
        bg2:addChild(mc, 99)
        self._JIERIMC[#self._JIERIMC + 1] = mc

        local sp1 = mc:getChildren()[1]
        sp1:setSaturation(24)
        sp1:setHue(-169)

        local sp2 = mc:getChildren()[2]
        sp2:setBrightness(-5)

        local mc = mcMgr:createViewMC("zhuchengqizi4_qizi", true, false)
        mc:setPosition(710, 279)
        bg5:addChild(mc, 99)
        self._JIERIMC[#self._JIERIMC + 1] = mc

        local mc = mcMgr:createViewMC("zhuchengqizi5_qizi", true, false)
        mc:setPosition(1436, 368)
        bg4:addChild(mc, 99)
        self._JIERIMC[#self._JIERIMC + 1] = mc
    end
end

function MainView:setJieRi2()
    if self._JIERIPIC then
        for i = 1, #self._JIERIPIC do
            self._JIERIPIC[i]:removeFromParent()
        end
        self._JIERIPIC = {}
    end
    if isJieRi2 then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("asset/ui/zhongqiujie.plist", "asset/ui/zhongqiujie.png")
        self._JIERIPIC = {}
        local bg1 = self:getUI("bg.midBg1")
        local bg2 = self:getUI("bg.midBg2")
        local bg3 = self:getUI("bg.midBg3")
        local bg4 = self:getUI("bg.midBg4")

        local sp1 = cc.Sprite:createWithSpriteFrameName("zhongqiujie1.png")
        sp1:setPosition(1138, 277)
        bg1:addChild(sp1, 99)
        self._JIERIPIC[#self._JIERIPIC + 1] = sp1

        local sp2 = cc.Sprite:createWithSpriteFrameName("zhongqiujie2.png")
        sp2:setPosition(740, 268)
        bg1:addChild(sp2, 99)
        self._JIERIPIC[#self._JIERIPIC + 1] = sp2

        local sp3 = cc.Sprite:createWithSpriteFrameName("zhongqiujie4.png")
        sp3:setPosition(768, 294)
        bg2:addChild(sp3, 99)
        self._JIERIPIC[#self._JIERIPIC + 1] = sp3

        local sp4 = cc.Sprite:createWithSpriteFrameName("zhongqiujie3.png")
        sp4:setPosition(224, 297)
        bg3:addChild(sp4, 99)
        self._JIERIPIC[#self._JIERIPIC + 1] = sp4

        local sp5 = cc.Sprite:createWithSpriteFrameName("zhongqiujie5.png")
        sp5:setPosition(490, 400)
        bg4:addChild(sp5, 99)
        self._JIERIPIC[#self._JIERIPIC + 1] = sp5

        local sp6 = cc.Sprite:createWithSpriteFrameName("zhongqiujie6.png")
        sp6:setPosition(1262, 329)
        bg4:addChild(sp6, 99)
        self._JIERIPIC[#self._JIERIPIC + 1] = sp6
    else
        cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("asset/ui/zhongqiujie.plist")
        cc.Director:getInstance():getTextureCache():removeTextureForKey("asset/ui/zhongqiujie.png")
    end
end

function MainView:setJieRi3()
    if self._JIERIPIC3 then
        for i = 1, #self._JIERIPIC3 do
            self._JIERIPIC3[i]:removeFromParent()
        end
        self._JIERIPIC3 = {}
    end
    if isJieRi3 then
        audioMgr:playMusic("mainmenuChristmas", true)
        cc.SpriteFrameCache:getInstance():addSpriteFrames("asset/ui/shengdanjie.plist", "asset/ui/shengdanjie.png")
        self._JIERIPIC3 = {}
        local bg1 = self:getUI("bg.midBg1")
        local bg2 = self:getUI("bg.midBg2")
        local bg3 = self:getUI("bg.midBg3")
        local bg4 = self:getUI("bg.midBg4")

        local sp1 = cc.Sprite:createWithSpriteFrameName("shengdanjie1.png")
        sp1:setPosition(60, 140)
        bg2:addChild(sp1, 99)
        self._JIERIPIC3[#self._JIERIPIC3 + 1] = sp1

        local sp2 = cc.Sprite:createWithSpriteFrameName("shengdanjie2.png")
        sp2:setPosition(498, 181)
        bg2:addChild(sp2, 99)
        self._JIERIPIC3[#self._JIERIPIC3 + 1] = sp2

        local sp3 = cc.Sprite:createWithSpriteFrameName("shengdanjie3.png")
        sp3:setPosition(657, 164)
        bg1:addChild(sp3, 99)
        self._JIERIPIC3[#self._JIERIPIC3 + 1] = sp3

        local sp4 = cc.Sprite:createWithSpriteFrameName("shengdanjie4.png")
        sp4:setPosition(1054, 222)
        bg1:addChild(sp4, 99)
        self._JIERIPIC3[#self._JIERIPIC3 + 1] = sp4

        local sp5 = cc.Sprite:createWithSpriteFrameName("shengdanjie5.png")
        sp5:setPosition(1482, 217)
        bg1:addChild(sp5, 99)
        self._JIERIPIC3[#self._JIERIPIC3 + 1] = sp5

    else
        cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("asset/ui/shengdanjie.plist")
        cc.Director:getInstance():getTextureCache():removeTextureForKey("asset/ui/shengdanjie.png")
    end
end

--更新领主管家红点
function MainView:updateLordBtn( ... )
    local isNeed = self._lordManagerModel:checkNeedRedPoint()
    self:getUI("topLayer.lordBtn.redPoint"):setVisible(isNeed)
    self._mainViewModel:checkTipsQipao()
    self:setQipao()
end

function MainView:checkCrossGodWarInvitation()

    --第一周 跨服诸神不开启  临时关掉打脸图
    if not GameStatic.is_open_crossGodWar then
        return 
    end

    local cGodWarModel = self._modelMgr:getModel("CrossGodWarModel")
    local isOpen = cGodWarModel:matchIsOpen()
    if self._crossGodWarUpdate then
        ScheduleMgr:unregSchedule(self._crossGodWarUpdate)
        self._crossGodWarUpdate = nil
    end
    if self._crossGodWar64Ready then
        ScheduleMgr:unregSchedule(self._crossGodWar64Ready)
        self._crossGodWar64Ready = nil
    end

    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curTime))
    local endBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 20:30:00"))
    if curTime > endBattle then
        return
    end

    local showType 
    if weekday == 1 then
        showType = 1
    elseif weekday == 2 then
        showType = 2
    elseif weekday == 3 then
        showType = 3
    elseif weekday == 4 then
        local ctime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 19:29:00"))
        if curTime <= ctime then
            showType = 4
        else
            showType = 5
        end
    end
    local isShow = cGodWarModel:getShowType(showType)
    local lv = self._userModel:getData().lvl
    if isOpen and isOpen == 0 and isShow and lv >= 50 then
        self._crossGodWarUpdate = ScheduleMgr:regSchedule(1000, self, function(self, dt)
            self:updateCrossGodWarTime(dt)
        end)
    end

    local endTimes = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 20:05:01"))
    if isOpen and isOpen == 0 and weekday == 3 and curTime <= endTimes  and lv >= 50 then
        self._crossGodWar64Ready = ScheduleMgr:regSchedule(1000, self, function(self, dt)
            self:update64ReadyTime(dt)
        end)
    end
end

function MainView:update64ReadyTime( dt )
    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local endTimes = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 20:05:01"))
    if curTime == endTimes then
        if not GuideUtils.isGuideRunning then
            self._serverMgr:sendMsg("CrossGodWarServer", "enter", {}, true, {}, function(result)
                self._viewMgr:showDialog("crossGod.CrossGodWarAudienceDialog",{})
            end)

            if self._crossGodWar64Ready then
                ScheduleMgr:unregSchedule(self._crossGodWar64Ready)
                self._crossGodWar64Ready = nil
            end
        end
    end
end

function MainView:updateCrossGodWarTime( dt )
    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curTime))
    local isShow = false
    -- print(string.format("%s week %s time",weekday,curTime))
    if weekday == 1 then
        local lastLoginTime = self._modelMgr:getModel("UserModel"):getData()._lt
        local beginBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 06:00:00"))
        if lastLoginTime <= beginBattle and curTime >= beginBattle then
            --周一第一次登陆then
            isShow = true
        end
    elseif weekday == 2 then
        local beginBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 19:29:00"))
        local endBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 20:05:00"))
        if curTime >= beginBattle and curTime <= endBattle then
            isShow = true
        end
    elseif weekday == 3 then
        local beginBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 19:29:00"))
        local endBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 20:05:00"))
        if curTime >= beginBattle and curTime <= endBattle then
            isShow = true
        end
    elseif weekday == 4 then
        local beginBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 19:29:00"))
        local endBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 19:29:00"))
        if curTime > endBattle then
            beginBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 19:59:00"))
            endBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 20:30:00"))
        end
        if curTime >= beginBattle and curTime <= endBattle then
            isShow = true
        end
    end
    if isShow then
        local beginBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 19:29:00"))
        local type = weekday
        if weekday == 4 and curTime ~= beginBattle then
            type = 5
        end
        if not GuideUtils.isGuideRunning then
            local cGodWarModel = self._modelMgr:getModel("CrossGodWarModel")
            cGodWarModel:setShowType(type)
            self._viewMgr:showDialog("crossGod.CrossGodWarInvitationDialog",{type = type})
            local endBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 19:59:00"))
            local isShowType = true
            if weekday ~= 4 then
                isShowType = cGodWarModel:getShowType(type)
            elseif weekday == 4 and curTime >= endBattle then
                isShowType = cGodWarModel:getShowType(type)
            end
            if not isShowType then
                if self._crossGodWarUpdate then
                    ScheduleMgr:unregSchedule(self._crossGodWarUpdate)
                    self._crossGodWarUpdate = nil
                end
            end
        end
    end
end

function MainView.dtor()
    _speed = nil
    activetyBtnData = nil
    activityLvL = nil
    createUpBtnTitleLabel = nil
    createViewTitleLabel = nil
    DirectShopOpenNeedDay = nil
    MainView = nil
    _offsetX = nil

    isJieRi = nil
    isJieRi2 = nil 
    isJieRi3 = nil
    bgNameExt = nil
    JIERI_3_BEGIN = nil
    JIERI_3_END = nil

    gadgetErrorTip = nil
end

return MainView
