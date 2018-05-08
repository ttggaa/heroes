--[[
    Filename:    CityBattleView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-11-26 10:26:00
    Description: File description
--]]

local CityBattleView = class("CityBattleView",BaseView)
local tostring = tostring
local tonumber = tonumber
local realSec

require "game.view.citybattle.CityBattleConst"
-- local TEST_ANIMA = true
function CityBattleView:ctor()
    CityBattleView.super.ctor(self)
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("citybattle.CityBattleView")
            ServerManager:getInstance():RS_clear()
        elseif eventType == "enter" then 
        end
    end)
    self._isOpenDialog = false  --是否打开二级弹窗
    self._curDealyAni  = false    
    self._isInHide = false
    self._userModel = self._modelMgr:getModel("UserModel")
    self._cityBattleModel = self._modelMgr:getModel("CityBattleModel")
    self._sec = tostring(self._userModel:getData().sec)
    self._privilegeModel = self._modelMgr:getModel("PrivilegesModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    realSec = self._cityBattleModel:getMineSec()
end
local dayInfo = {[17] = "day37", [18] = "day59", [19] = "day60", [20] = "day61"}

function CityBattleView:getRegisterNames()
    return {
        {"buff1","listPanel.buffPanel.buff1"},
        {"buffPanel","listPanel.buffPanel"},
        {"goBuy","listPanel.buffPanel.goBuy"},
        {"privilegeTips","listPanel.buffPanel.privilegeTips"},
        {"world_history_btn","listPanel.world_history_btn"},
}
end

function CityBattleView:onInit()
    self:setGvgRoomStatus()
    self._userModel = self._modelMgr:getModel("UserModel")
    
    self._leagueModel = self._modelMgr:getModel("LeagueModel")
    self._formationModel = self._modelMgr:getModel("FormationModel")
    self._playerModel = self._modelMgr:getModel("PlayerTodayModel")
    self._heroModel = self._modelMgr:getModel("HeroModel")

    local uiworldLayer = self:getUI("worldLayer")
    self._worldLayer = require("game.view.citybattle.CityBattleWorldLayer").new(self)

    self:addChild(self._worldLayer, -1)
    self._worldLayer:setCascadeOpacityEnabled(true, true)
    self._worldLayer:setOpacity(255)

    self._worldElementLayer = self:createLayer("intance.WorldElementLayer", {parent = uiworldLayer, showType = 2,callBack = self.onRightBottomBtnEvent,target = self})
  
    self:addChild(self._worldElementLayer, -1)   
    -- self._worldElementLayer:standByFirstEnterAction() 

    local state, weekday, timeDes = self._cityBattleModel:getState()
    if timeDes == "s1" then
        local btn_ready = self:getUI("titleBg.readlyBg.btn_ready")
        local btnBottomMc = mcMgr:createViewMC("beizhan2_kaiqi", true, false)
        btnBottomMc:setPosition(cc.p(btn_ready:getContentSize().width/2, btn_ready:getContentSize().height/2))
        btn_ready:addChild(btnBottomMc,-1)

        local btnTopMc = mcMgr:createViewMC("beizhan1_kaiqi", true, false)
        btnTopMc:setPosition(cc.p(btn_ready:getContentSize().width/2, btn_ready:getContentSize().height/2))
        btn_ready:addChild(btnTopMc)
    end

    self._titleBg = self:getUI("titleBg")
    local gap = ADOPT_IPHONEX and 60 or 0
    self._titleBg:setPosition(MAX_SCREEN_WIDTH/2-self._titleBg:getContentSize().width/2- gap,MAX_SCREEN_HEIGHT-self._titleBg:getContentSize().height)
    self._titleBg:setZOrder(1100)
    self._readlyBg = self:getUI("titleBg.readlyBg")
    self._readlyBg:setVisible(false)
    self._fightTimeBg = self:getUI("titleBg.fightTimeBg")

    self._listPanel = self:getUI("listPanel")
    print("MAX_SCREEN_WIDTH",MAX_SCREEN_WIDTH)
    local gap = ADOPT_IPHONEX and 60 or 0
    self._listPanel:setPosition(MAX_SCREEN_WIDTH-self._listPanel:getContentSize().width-gap,MAX_SCREEN_HEIGHT-self._listPanel:getContentSize().height)
    self._listPanel:setVisible(true)
    
    -- self._fightList = self:getUI("listPanel.fightList")


    self:setTitle()

    --

    self:setListenReflashWithParam(true)
    self:listenReflash("CityBattleModel", self.listenModel)
    self:listenReflash("FormationModel", self.reflashFormationInfo)

    self:registerTimer(5, 0, 5, function ()
        self:updatePrivilegeRed()
    end)
    -- 调试
    -- self:test()

    local btn_ready = self:getUI("titleBg.readlyBg.btn_ready")
    local btn_txt = btn_ready:getChildByFullName("title")
    btn_txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    if btn_ready then
        self:registerClickEvent(btn_ready,function()
            self._serverMgr:sendMsg("CityBattleServer", "getDonateInfo", {}, true, {}, function (result, error)
                self._isOpenDialog = true
                self._viewMgr:showDialog("citybattle.CityBattleReadlyFightDialog",{callBack = function()
                    self:checkCloseDialogAni()
                end},true)
            end)
        end)
    end
    self._leftFmPanel  = self:getUI("leftFmPanel")
    self._leftFmPanel:setPosition(0,MAX_SCREEN_HEIGHT-self._leftFmPanel:getContentSize().height)
    local formationBtn = self:getUI("leftFmPanel.formationBtn")
    --by wangyan 聊天
    local chatNode = require("game.view.global.GlobalChatNode").new("all")
    chatNode:setAnchorPoint(0.5, 0.5)
    chatNode:setPosition(formationBtn:getContentSize().width * 0.5, formationBtn:getContentSize().height * 0.5 - 5)
    formationBtn:addChild(chatNode, 10000)

    local label = cc.Label:createWithTTF("聊天", UIUtils.ttfName, 14)
    label:setColor(cc.c3b(255, 255, 255))
    label:enableOutline(cc.c4b(60, 30, 10, 255), 2)
    label:setPosition(26, 10)
    label:setName("31555")
    chatNode:addChild(label, 9999)
    local chatListen = function(self, param)
        if chatNode ~= nil and chatNode.showChatUnread ~= nil then 
            chatNode:showChatUnread(param)
        end
    end
    self:setListenReflashWithParam(true)
    self:listenReflash("ChatModel", chatListen)
    self:listenReflash("PlayerTodayModel", chatListen) 
    -- self:standByFirstEnterAction()
    self:firstGetReportData()

    pcall(function()
        if self._cityBattleModel:checkNewGvgReady() then
            local s1OverTime,s2OverTime,s3OverTime,s4OverTime,s5OverTime,s6OverTime = self._cityBattleModel:getOverTime()
            SystemUtils.saveAccountLocalData("CITYBATTLE_NUM_READY_TIME",s6OverTime+363600)
        end
    end)
    if self._goBuy then
        self:registerClickEvent(self._goBuy, function()
            self:checkSavePrivalige()
            self._viewMgr:showView("privileges.PrivilegesView")
        end)
    end
    if self._privilegeTips then
        self._privilegeTips:setVisible(false)
    end
    if self._buff1 then
        self:registerClickEvent(self._buff1, function()
            self._privilegeTips:setCapInsets(cc.rect(30,30,30,30))
            self:showPrivilegesBuffTip(self._privilegeTips)
        end)
    end
    if self._world_history_btn then
        self:registerClickEvent(self._world_history_btn, function()
            self._serverMgr:sendMsg("CityBattleServer", "getSecRecordInfo", {}, true, {}, function(result)
                self._isOpenDialog = true
                self._viewMgr:showDialog("citybattle.CityBattleHistoryDialog",{callBack = function ()
                    self:checkCloseDialogAni()
                end},true)
            end)
        end)
    end
    self:updatePrivilegeRed()
end

function CityBattleView:updatePrivilegeRed()
    local status = true
    local tbuffNum = tab:Setting("G_PRIVILEGES_SHOP_BUFF_NUM").value
    for i=1,tbuffNum do 
        local flag, buffId = self._privilegeModel:getKingBuff(i)
        if flag then
            status = false
            break
        end
    end

    if status then
        local _,itemCount = self._itemModel:getItemsById(tab:Setting("G_PRIVILEGES_LVUP_ITEMID").value)
        if itemCount < 20 then
            status = false
        end
    end

    local currTime = self._userModel:getCurServerTime()
    local hour = TimeUtils.date("%H",currTime)
    local isClose = self._privilegeModel:isUpPeerage()
    print("isClose",isClose)
    if tonumber(hour) < 5 then
        currTime = currTime - 86400
    end
    local weekday = tonumber(TimeUtils.date("%w", currTime))
    if (weekday == 0 or weekday == 6) and isClose then --周六~周日
        self._buff1:setVisible(true)
        self._goBuy:setVisible(true)
    else
        status = false
        self._buff1:setVisible(false)
        self._goBuy:setVisible(false)
        self._privilegeTips:setVisible(false)
    end

    local curTime = self._userModel:getCurServerTime()
    if status then
        local showTime = SystemUtils.loadAccountLocalData("CITYBATTLE_PRI_TIME")
        if showTime then
            if not TimeUtils.checkIsOtherDay(showTime, curTime) then
                status = false
            end
        end
    end


    UIUtils.addRedPoint(self._goBuy, status)
end

function CityBattleView:checkSavePrivalige()
    local curTime = self._userModel:getCurServerTime()
    local showTime = SystemUtils.loadAccountLocalData("CITYBATTLE_PRI_TIME")
    if showTime then
        if TimeUtils.checkIsOtherDay(showTime, curTime) then
            SystemUtils.saveAccountLocalData("CITYBATTLE_PRI_TIME", curTime)
        end
    else
        SystemUtils.saveAccountLocalData("CITYBATTLE_PRI_TIME", curTime)
    end
end

function CityBattleView:checkIsHavePriBuff()
    local status = false
    local tbuffNum = tab:Setting("G_PRIVILEGES_SHOP_BUFF_NUM").value
    for i=1,tbuffNum do 
        local flag, buffId = self._privilegeModel:getKingBuff(i)
        if flag then
            status = true
            break
        end
    end
    return status
end

function CityBattleView:showPrivilegesBuffTip(inView)
    if not self:checkIsHavePriBuff() then
        self._viewMgr:showDialog("global.GlobalSelectDialog",
                {desc = lang("TIPS_UI_DES_11"),
                alignNum = 1,
                button1 = "前往",
                callback1 = function ()
                    self:checkSavePrivalige()
                    local viewMgr = self._viewMgr or ViewManager:getInstance()
                    viewMgr:showView("privileges.PrivilegesView")
                end,
                callback2 = function()

                end},true)
        return
    end
    inView:setVisible(true)
    
    local buffSum = {}
    local tbuffNum = tab:Setting("G_PRIVILEGES_SHOP_BUFF_NUM").value
    for i=1, tbuffNum do
        local buffIcon = inView:getChildByName("buffIcon" .. i)
        if buffIcon then
            buffIcon:setVisible(false)
        end
        local richText = inView:getChildByName("richText" .. i)
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
    posY = posY - 10
    for i=1,table.nums(buffSum) do
        local indexId = buffSum[i]
        local flag, buffId = self._privilegeModel:getKingBuff(indexId)
        local buffNum = tonumber(buffId)
        local buffTab = tab:PeerShop(buffNum)
        local param = {image = buffTab.icon .. ".png", quality = 5, scale = 0.90, bigpeer = true}
        local buffIcon = inView:getChildByName("buffIcon" .. i)
        if buffIcon then
            IconUtils:updatePeerageIconByView(buffIcon, param)
        else
            buffIcon = IconUtils:createPeerageIconById(param)
            buffIcon:setAnchorPoint(0.5, 0.5)
            -- buffIcon:setPosition(35,posY - i*40)
            buffIcon:setScale(0.3)
            buffIcon:setName("buffIcon" .. i)
            inView:addChild(buffIcon)
        end
        buffIcon:setPosition(35,posY - i*38 + 19)
        buffIcon:setVisible(true)

        local sysBuf = buffTab.buff
        local str = lang(buffTab.des)
        str = tsplit(str, sysBuf[2])
        local result, count = string.gsub(str, "$num", sysBuf[2])
        if count > 0 then 
            str = result
        end
        local richText = inView:getChildByName("richText" .. i)
        if richText then
            richText:removeFromParent()
        end
        richText = RichTextFactory:create(str, 180, 40)
        richText:formatText()
        richText:setPosition(140, posY - i*38 + 19)
        richText:setName("richText" .. i)
        inView:addChild(richText)
    end
    if not inView.mask then
        local mask = ccui.Layout:create()
        mask:setBackGroundColorOpacity(255)
        mask:setBackGroundColorType(1)
        mask:setBackGroundColor(cc.c3b(0,0,0))
        mask:setAnchorPoint(0.5,0.5)
        mask:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        local point = inView:convertToNodeSpace(cc.p(MAX_SCREEN_WIDTH*0.5,MAX_SCREEN_HEIGHT*0.5))
        mask:setPosition(point)
        mask:setOpacity(0)
        inView:addChild(mask,-1)
        inView.mask = mask
        mask:setTouchEnabled(true)
        self:registerClickEvent(mask,function()
            inView:setVisible(false)
        end)
    end
end

function CityBattleView:firstGetReportData()
    self._serverMgr:sendMsg("CityBattleServer", "getReportList", {}, false, {}, function (result, error)
        if result and result.list and table.nums(result.list) >0 then
            self._cityBattleModel:setRedData("personReport",{time = result.list[1].time})
        end
        self._serverMgr:sendMsg("CityBattleServer", "getCityReportList", {}, false, {}, function (result, error)
            if result and result.list and table.nums(result.list) >0 then
                self._cityBattleModel:setRedData("cityReport",{time = result.list[1].time})
            end  
            if self._worldElementLayer ~= nil then 
                self._worldElementLayer:updateExtendBar()
            end
        end)
    end)
    self._serverMgr:sendMsg("CityBattleServer", "getPoint", {}, false, {}, function (result, error)
        if result then
            self._cityBattleModel:setRewardRedData(result)
        end
        if self._worldElementLayer ~= nil then 
            self._worldElementLayer:updateExtendBar()
        end
    end)
end


-- function CityBattleView:onShow()
--     if self._worldLayer ~= nil then 
--         self._worldLayer:unLockTouch()
--     end
-- end

function CityBattleView:onTop()
    print("CityBattleView:onTop()=====================================")
    self._isInHide = false
    if self._worldLayer ~= nil then 
        self._worldLayer:unLockTouch()
    end
    if self._worldElementLayer ~= nil then 
        self._worldElementLayer:updateExtendBar()
    end
    self:checkOnTopAni()
    -- self:reGetServerData()
    -- 弹幕
    ScheduleMgr:delayCall(0, self, function()
        self:updateBulletBtnState()
        self:showBullet()
    end)
    self:updatePrivilegeRed()

    --移除撤退编组头像
    if not GameStatic.revertGvg_rebuild then
        local list = self._cityBattleModel:getAnddeleteLeaveData()
        if list then
            if not tolua.isnull(self._worldLayer) then
                print("CityBattleView:onTop2")
                self._worldLayer:listenModelDMiniIcon_CUR(list)
                local data = next(list)
                if data then
                    local cid = list[tostring(data)]
                    for i=1,4 do
                        self._worldLayer:updateDialFormation(cid, i)
                    end
                    self._worldLayer:updateDialPanelInfo(cid)
                end
            end
        end
    end
end

function CityBattleView:onHide()
    self._isInHide = true
    BulletScreensUtils.clear()
    print("CityBattleView:onHide()=====================================")
    if self._worldLayer ~= nil then 
        self._worldLayer:lockTouch()
    end
end


--[[
--! @function updateBulletBtnState
--! @desc 更新弹幕按钮
--! @return 
--]]
function CityBattleView:updateBulletBtnState()

    BulletScreensUtils.clear()

    local bulletBtn = self:getUI("buttomPanel.bulletBtn")
    local bulletLab = self:getUI("buttomPanel.bulletLab")
    if tab.Bullet then
        self._sysBullet = tab:Bullet("gvg")
    end
    if self._sysBullet == nil or GameStatic.showIntanceBullet == false then 
        bulletBtn:setVisible(false)
        bulletLab:setVisible(false)
        return
    else
        bulletBtn:setVisible(true)
        bulletLab:setVisible(true)
    end


    bulletLab:enable2Color(1, cc.c4b(255, 195, 17, 255))
    bulletLab:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self:registerClickEvent(bulletBtn, function ()
        self._viewMgr:showDialog("global.BulletSettingView", {bulletD = self._sysBullet,kuaFuEnable = true,
            callback = function (open) 
                local fileName = open and "bullet_open_btn.png" or "bullet_close_btn.png"
                bulletBtn:loadTextures(fileName, fileName, fileName, 1)       
            end})
    end)    
end

function CityBattleView:showBullet()
    if self._sysBullet == nil then 
        return
    end
    local bulletBtn = self:getUI("buttomPanel.bulletBtn")
    local open = BulletScreensUtils.getBulletChannelEnabled(self._sysBullet)
    local fileName = open and "bullet_open_btn.png" or "bullet_close_btn.png"
    bulletBtn:loadTextures(fileName, fileName, fileName, 1)    
    if open  then
        BulletScreensUtils.initBullet(self._sysBullet)
    end    
end

function CityBattleView:onReconnect()
    CityBattleView.super.onReconnect(self)
    if not self._sendJoinRoomCount then
        self._sendJoinRoomCount = 0
    end
    if self._sendJoinRoomCount < 5 then
        self:setGvgRoomStatus()
        self._sendJoinRoomCount = self._sendJoinRoomCount + 1
    else
        self._sendJoinRoomCount = 0
    end
end

function CityBattleView:applicationDidEnterBackground()
   print("CityBattleView:applicationDidEnterBackground")
end

function CityBattleView:applicationWillEnterForeground()
    print("CityBattleView:applicationWillEnterForeground")
    self:reGetServerData()
    self._sendJoinRoomCount = 0
end

--[[
    检测关闭二级弹窗，是否有需要触发的动画
]]
function CityBattleView:checkCloseDialogAni()
    self._isOpenDialog = false
    if self._curDealyAni == 0 then
        self:checkAnima(function()
            self:reGetServerData()
        end)
    elseif self._curDealyAni == 3 then
        self:runS3Animation()
    elseif self._curDealyAni == 4 then
        self:runS4Animation()
    elseif self._curDealyAni == 6 then
        self:runS6Animation()
    elseif self._curDealyAni == 7 then
        self:checkAnima()
    end
    self._curDealyAni = false
end

--[[
    检测onTop时需要播放的动画
]]
function CityBattleView:checkOnTopAni()
    if self._curDealyAni == 0 then
        self:checkAnima(function()
            self:reGetServerData()
        end)
    elseif self._curDealyAni == 3 then
        self:runS3Animation()
    elseif self._curDealyAni == 4 then
        self:runS4Animation()
    elseif self._curDealyAni == 6 then
        self:runS6Animation()
    elseif self._curDealyAni == 7 then
        self:checkAnima()
    else
        --top 时去掉重新请求数据，去掉过多的重连请求数据
        if GameStatic.revertGvg_rebuild then
            self:reGetServerData()
        end
    end
    self._curDealyAni = false
end

--右下角
function CityBattleView:onRightBottomBtnEvent(...)
    local arg = {...}
    dump(arg)
    if arg[1] == "world_report_btn" then
        print("记录")
        self._isOpenDialog = true
        self._serverMgr:sendMsg("CityBattleServer", "getReportList", {}, true, {}, function (result, error)
            if result then
                if result.list and table.nums(result.list) >0 then
                    local time = self._cityBattleModel:getMaxTime(result.list[1].time,"personReport")
                    SystemUtils.saveAccountLocalData("CITYBATTLE_PERSON_RED",time)
                end
                self._viewMgr:showDialog("citybattle.CityBattleReportDialog",{result = result,callBack = function()
                    self:checkCloseDialogAni()
                    if self._worldElementLayer ~= nil then 
                        self._worldElementLayer:updateExtendBar()
                    end
                end},true)
            end
        end)
    elseif arg[1] == "world_reward_btn" then
        print("奖励")
        self._isOpenDialog = true
        self._serverMgr:sendMsg("CityBattleServer", "getPoint", {}, true, {}, function (result, error)
            if result then
                self._viewMgr:showDialog("citybattle.CityBattleAwardDialog",{resultData = result,callBack = function()
                    self:checkCloseDialogAni()
                    if self._worldElementLayer ~= nil then 
                        self._worldElementLayer:updateExtendBar()
                    end
                    
                end},true)
            end
        end)  
    elseif arg[1] == "world_rank_btn" then
        print("排行")
        -- self:battleOpenAni()
        self._isOpenDialog = true
        self._viewMgr:showDialog("citybattle.CityBattleRankView",{callBack = function ()
            self:checkCloseDialogAni()
        end},true)
    elseif arg[1] == "world_shop_btn" then
        -- self._isOpenDialog = true
        self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = "citybattle"}, true, {}, function(result)
            dump(result)
            self._viewMgr:showView("shop.ShopView", {idx = 8})
            -- self._viewMgr:showDialog("citybattle.CityBattleShopView",{callBack = function()
            --     self:checkCloseDialogAni()
            -- end},true)
        end)
    elseif arg[1] == "world_guize_btn" then
        print("规则")
        self._isOpenDialog = true
        self._viewMgr:showDialog("citybattle.CityBattleRuleDialog",{callBack = function ()
            self:checkCloseDialogAni()
        end},true)
    elseif arg[1] == "world_history_btn" then
        print("历史")
        self._serverMgr:sendMsg("CityBattleServer", "getSecRecordInfo", {}, true, {}, function(result)
            self._isOpenDialog = true
            self._viewMgr:showDialog("citybattle.CityBattleHistoryDialog",{callBack = function ()
                self:checkCloseDialogAni()
            end},true)
        end)
    end
end

function CityBattleView:showLeidaTips(sec)
    local level = self._cityBattleModel:getReadlyLevel(sec)
    local readyData = self._cityBattleModel:getReadlyData()[sec]
    local partKey = self._cityBattleModel:getMinOpenDayKey()

    local secData = {}
    secData.secName = self._cityBattleModel:getSecName(sec)

    local servers = self._cityBattleModel:fiterServers(sec)
    local str = ""
    for index,id in pairs (servers) do 
        local num = self._cityBattleModel:getRealNum(id)
        local platform = self._cityBattleModel:getPlatformName(id)
        platform = platform or ""
        str = str .. platform .. num .. "区"
        if index ~= table.nums(servers) then
            str = str .. "、"
        end
    end
    secData.secDes = str

    CityBattleUtils.createLeiDaTip(self,level,readyData, secData,partKey)
end

-- function CityBattleView:getPartKey()
--     local serverOpenDay = math.ceil(self._userModel:getOpenServerTime()/86400) 
--     if serverOpenDay <= 30 then
--         return 0
--     elseif serverOpenDay > 30 and serverOpenDay <= 45 then 
--         return  1
--     elseif serverOpenDay > 45 and serverOpenDay <= 60 then
--         return 2
--     elseif serverOpenDay > 60 and serverOpenDay <= 75 then
--         return 3
--     else
--         return 4
--     end
-- end

--开战动画界面
function CityBattleView:battleOpenAni(callback)
    self._battleOpenLayer = self:createLayer("citybattle.CityBattleOpenLayer",{callBack = function()
         -- if self._listPanel then
         --    self._listPanel:setCascadeOpacityEnabled(true,true)
         --    self._listPanel:setOpacity(0)
         --    self._listPanel:setVisible(true)
         --    self._listPanel:runAction(cc.Sequence:create(
         --        cc.FadeIn:create(0.5),
         --        cc.CallFunc:create(function()
         --            if callback then
         --                callback()
         --            end
         --        end)
         --    ))
         -- end
        if self._worldLayer ~= nil then 
            self._worldLayer:unLockTouch()
        end
        if callback then
            callback()
        end
    end})
    self:addChild(self._battleOpenLayer,102)
    self._battleOpenLayer:setPosition((MAX_SCREEN_WIDTH-960)/2,(MAX_SCREEN_HEIGHT-640)/2)
end

function CityBattleView:reflashUI()
    print("CityBattleView:reflashUI")
    self:setTitle2()
    self:reflashServerNum()
    self:reflashFormationInfo()
    self:tickGetServerInfo()
end
function CityBattleView:getServerDes(sec)
    -- local b = math.mod(sec,1000)
    -- local des
    -- local sdkMgr = SdkManager:getInstance()
    -- if sdkMgr:isQQ() then
    --     des = "qq".. b .. "区"
    -- elseif sdkMgr:isWX() then
    --     des = "微信".. b .. "区"
    -- else
    --     des = "win".. b .. "区"
    -- end
    -- des = des or b .. "区"
    -- return des or b
    return self._cityBattleModel:getServerName(sec, true)
end

--[[
    更新区服编组和区服城池数
]]
function CityBattleView:reflashServerInfo()
    local cityServerData = self._cityBattleModel:getCityServerList()
    local serverInfo = self._cityBattleModel:getData().serverInfo
    -- dump(serverInfo,"serverInfo",10)
    if not serverInfo then
        return
    end
    -- local cityNum = self._cityBattleModel:getServerCityData()
    local serverNum = table.nums(cityServerData)
    for i=2,3 do
        local fightList = self:getUI("listPanel.fightList" .. i)
        fightList:setVisible(false)
    end
    local fightList = self:getUI("listPanel.fightList" .. serverNum)
    fightList:setVisible(true)
    for i=1, serverNum do
        local cityLab = self:getUI("listPanel.fightList" .. serverNum ..".cityLab" .. i)
        local cityRobLab = self:getUI("listPanel.fightList" .. serverNum ..".cityRobLab" .. i)
        local sec = tostring(cityServerData[i].sec)
        if serverInfo.scn and serverInfo.scn[sec] then
            cityLab:setString(serverInfo.scn[sec])
        end
        if serverInfo.sfn and serverInfo.sfn[sec] then
            cityRobLab:setString(serverInfo.sfn[sec])
        end
    end
end

--[[
    定时请求编组数据,10s一次
]]
function CityBattleView:tickGetServerInfo()
    local state, weekday, timeDes = self._cityBattleModel:getState()
    if timeDes ~= "s3" and timeDes ~= "s5" then
        if self._schedule then
            ScheduleMgr:unregSchedule(self._schedule)
            self._schedule = nil
        end
        return
    end
    if self._schedule then
        return
    end
    self._schedule = ScheduleMgr:regSchedule(10000,self,function( )
        local params = {}
        self:sendSocketMgs("getSecFormationNum",params)
    end)
end

function CityBattleView:sendSocketMgs(name, params)
    params.mapId = self._cityBattleModel:getMapId()
    params.rid = self._userModel:getData()._id
    ServerManager:getInstance():RS_sendMsg("PlayerProcessor", name, params or {})
end

function CityBattleView:reflashServerNum()
    local cityServerData = self._cityBattleModel:getCityServerList()
    local cityNum = self._cityBattleModel:getServerCityData()
    -- dump(cityNum)
    local serverNum = #cityServerData
    -- dump(cityServerData)

    local data = self._cityBattleModel:getData()
    -- dump(data,"aaaaa",10)

    local endNum = self._cityBattleModel:getSendNum()
    -- dump(endNum, "endNum======", 10)
    for i=2,3 do
        local fightList = self:getUI("listPanel.fightList" .. i)
        fightList:setVisible(false)
    end

    if serverNum == 3 and not self._buffPanel.isAdjust then
        self._buffPanel.isAdjust = true
        self._buffPanel:setPositionY(self._buffPanel:getPositionY()-37)
        self._world_history_btn:setPositionY(self._world_history_btn:getPositionY()-37)
    end

    local fightList = self:getUI("listPanel.fightList" .. serverNum)
    local serverList = self._leagueModel:getServerList()
    fightList:setVisible(true)
    local serverSmallImage = {"citybattle_view_temp6","citybattle_view_temp8","citybattle_view_temp7"}
    local serverBg = {"citybattle_view_temp21","citybattle_view_temp22","citybattle_view_temp23"}

    for i=1, serverNum do
        local serverLab = self:getUI("listPanel.fightList" .. serverNum ..".serverLab" .. i)
        local cityLab = self:getUI("listPanel.fightList" .. serverNum ..".cityLab" .. i)
        local cityRobLab = self:getUI("listPanel.fightList" .. serverNum ..".cityRobLab" .. i)
        local serverIma = self:getUI("listPanel.fightList" .. serverNum ..".cityImage" .. i)
        local serverBgIma = self:getUI("listPanel.fightList" .. serverNum ..".cityBg" .. i)

        -- local serverName = self._leagueModel:getServerName(cityServerData[i]) 
        local des = self:getServerDes(tonumber(cityServerData[i].sec))
        if des then
            serverLab:setString(des)
            serverLab:setFontSize(18)
        end
        -- serverLab:setString(tonumber(cityServerData[i].sec) .. "服")
        serverLab:setColor(cc.c4b(235, 190, 105, 255))
        cityRobLab:setString(cityNum[i]["allTeamNum"])
        cityRobLab:setColor(cc.c4b(235, 190, 105, 255))
        cityLab:setString(cityNum[i]["cityNum"])
        cityLab:setColor(cc.c4b(235, 190, 105, 255))
        if cityServerData[i].color then
            serverIma:loadTexture(serverSmallImage[cityServerData[i].color]..".png",1)
            serverBgIma:loadTexture(serverBg[cityServerData[i].color]..".png",1)
            if not serverBgIma.eventClick then
                serverBgIma.eventClick = true
                serverBgIma:setTouchEnabled(true)
                self:registerClickEvent(serverBgIma,function()
                    self:showLeidaTips(tostring(cityServerData[i].sec))
                end)
            end
        end

        cityRobLab:setVisible(true)
        serverLab:setVisible(true)
        cityLab:setVisible(true)
        if i == 1 then
            local panel = self:getUI("listPanel.fightList" .. serverNum)
            if not panel:getChildByName("mine_mask") then
                local mask_mine = cc.Sprite:createWithSpriteFrameName("cityBattle_mineServer_mask.png")
                panel:addChild(mask_mine,10)
                mask_mine:setName("mine_mask")
                local key = "cityBg1"
                if panel:getChildByFullName(key) then
                    mask_mine:setPosition(panel:getChildByFullName(key):getPosition())
                end
            end
        end
    end
end


function CityBattleView:reflashFormationInfo()

    local leftFmPanel = self:getUI("leftFmPanel")
    local state, weekday, timeDes= self._cityBattleModel:getState()
    if timeDes == "s1" or timeDes == "s6" or timeDes == "s7" then
        leftFmPanel:setVisible(false)
        return 
    end
    -- leftFmPanel:setVisible(true)
    local cityData = self._cityBattleModel:getData()
    local cityInfos = self._cityBattleModel:getData().c.c


    for i=1,4 do
        local fmStateReady = self:getUI("leftFmPanel.fmStateReady" .. i)
        fmStateReady:setVisible(false)
        local tipLab = self:getUI("leftFmPanel.fmStateReady" .. i .. ".tipLab")
        tipLab:enableOutline(cc.c4b(60, 30, 10,255),1) 

        local fmStateBattle = self:getUI("leftFmPanel.fmStateBattle" .. i)
        fmStateBattle:setVisible(false) 
        local tipLab = self:getUI("leftFmPanel.fmStateBattle" .. i .. ".tipLab")
        tipLab:enableOutline(cc.c4b(60, 30, 10,255),1) 
                
        if fmStateBattle.battleMc == nil then
            local battleMc = mcMgr:createViewMC("zhandouzhong_citybattlechengchidianji", true, false)
            battleMc:setPosition(cc.p(fmStateBattle:getContentSize().width * 0.5 - 7, fmStateBattle:getContentSize().height * 0.5 + 7))
            battleMc:setScale(0.6)
            fmStateBattle:addChild(battleMc)
            fmStateBattle.battleMc = battleMc
        end

        local fmStateFree = self:getUI("leftFmPanel.fmStateFree" .. i)
        fmStateFree:setVisible(false)     

        local tipLab = self:getUI("leftFmPanel.fmStateFree" .. i .. ".tipLab")
        tipLab:enableOutline(cc.c4b(60, 30, 10,255),1) 


        local fmStateDie = self:getUI("leftFmPanel.fmStateDie" .. i)
        fmStateDie:setVisible(false)

        local tipLab = self:getUI("leftFmPanel.fmStateDie" .. i .. ".tipLab")
        tipLab:enableOutline(cc.c4b(60, 30, 10,255),1) 

        local fmAdd = self:getUI("leftFmPanel.fmImg" .. i .. ".fmAdd")
        fmAdd:setVisible(false)     


        local fmImg = self:getUI("leftFmPanel.fmImg" .. i)
        fmImg:setTouchEnabled(false)
        
        if fmImg.lockTipLab ~= nil then 
            fmImg.lockTipLab:setVisible(false)
        end

        local fid = self._formationModel["kFormationTypeCityBattle" .. i]
        local formation = self._formationModel:getFormationDataByType(fid)
        
        local formationCount = self._formationModel:getFormationCountByType(fid)

        if fmImg.fcountLab == nil then 
            fmImg.fcountLab = cc.Label:createWithTTF("0/0", UIUtils.ttfName, 16)
            fmImg.fcountLab:setAnchorPoint(1, 0)
            fmImg.fcountLab:setPosition(fmImg:getContentSize().width - 10, 5)
            fmImg:addChild(fmImg.fcountLab, 10)
        end

        local haveCount = formationCount

        local formationInfo = {}
         
        if cityData["f"] ~= nil and cityData["f"][tostring(fid)] ~= nil then 
            formationInfo = cityData["f"][tostring(fid)]
            haveCount = formationInfo.bl or formationCount
        end  

        fmImg.fcountLab:setString(haveCount .. "/" .. formationCount)
        fmImg.fcountLab:setVisible(false)

        local heroId = formation["heroId"]

        local state, beginTime, cdTime, limitLevel = self._cityBattleModel:getFormationState(fid, formation)
        print("state===============================", state)
        local heroIcon = fmImg:getChildByName("heroIcon")
        if heroIcon ~= nil then 
            heroIcon:setVisible(false)
        end

        if fmImg.timeProg ~= nil then
            fmImg.timeProg:removeFromParent()
            fmImg.timeProg = nil
        end
        if fmImg.timeLab ~= nil then 
            fmImg.timeLab:removeFromParent()
            fmImg.timeLab = nil
        end

        if fmImg.lifeLabel ~= nil then
            fmImg.lifeLabel:removeFromParent()
            fmImg.lifeLabel = nil
        end

        if fmImg.lockStateMc ~= nil then 
            fmImg.lockStateMc:removeFromParent()
            fmImg.lockStateMc = nil
        end

        if state >= CityBattleConst.FORMATION_STATE.FREE then 
            fmImg.fcountLab:setVisible(true)
            local inHeroData = self._heroModel:getHeroData(heroId)
            local heroD = clone(tab:Hero(heroId))
            heroD.star = inHeroData["star"]
            heroD.skin = inHeroData.skin
            local param = {sysHeroData = heroD}
            if heroIcon then
                IconUtils:updateHeroIconByView(heroIcon, param)
            else
                heroIcon = IconUtils:createHeroIconById(param)
                heroIcon:setName("heroIcon")
                heroIcon:setAnchorPoint(cc.p(0,0))
                heroIcon:setScale(0.74)
                heroIcon:setPosition(cc.p(8, 2))
                fmImg:addChild(heroIcon)
            end
            local starBg = heroIcon:getChildByName("starBg")
            if starBg ~= nil then 
                starBg:setVisible(false)
            end
            local boxIcon = heroIcon:getChildByName("boxIcon")
            if boxIcon ~= nil then 
                boxIcon:setVisible(false)
            end
            heroIcon:setVisible(true)
            heroIcon:setTouchEnabled(false)
        end 

        local moveBtn 
        -- 战斗队列
        if state == CityBattleConst.FORMATION_STATE.BATTLE then 
            fmStateBattle:setVisible(true)

            self:registerClickEvent(heroIcon, function()

                if self._worldLayer:resetSelectedCityState() == 1 then return end
                local state, weekday, timeDes= self._cityBattleModel:getState()
                if timeDes == "s4" or timeDes == "s6" then self._viewMgr:showTip(lang("CITYBATTLE_TIP_25")) return end
                local tip = lang("CITYBATTLE_TIP_05")
                if formationInfo.cid == nil then return end
                local sysCityBattle = tab:CityBattle(tonumber(formationInfo.cid))
                tip, count = string.gsub(tip, "{$city}", lang(sysCityBattle.name))
                self._viewMgr:showDialog("global.GlobalSelectDialog",
                    {desc = tip,
                    button1 = "确定", 
                    button2 = "取消" ,
                    callback1 = function ()
                        self._viewMgr:showView("citybattle.CityBattleFightView", {cityId = formationInfo.cid})
                    end,
                    callback2 = function()
                    end})
            end)
            moveBtn = fmStateBattle
        -- 准备中
        elseif state == CityBattleConst.FORMATION_STATE.READY then
            fmStateReady:setVisible(true)
            local tipLab = fmStateReady:getChildByName("tipLab")
            local stateImg = fmStateReady:getChildByName("stateImg")

            local cityInfo = cityInfos[tostring(cityData["f"][tostring(fid)].cid)]
            if cityInfo.b == tostring(realSec) then 
                tipLab:setString("防守中")
                stateImg:loadTexture("citybattle_view_temp35.png", 1)
            else
                tipLab:setString("进攻中")
                stateImg:loadTexture("citybattle_view_temp11.png", 1)                
            end
            self:registerClickEvent(heroIcon, function()
                if self._worldLayer:resetSelectedCityState() == 1 then return end
                local state, weekday, timeDes= self._cityBattleModel:getState()
                if timeDes == "s4" or timeDes == "s6" then self._viewMgr:showTip(lang("CITYBATTLE_TIP_25")) return end
                if formationInfo.cid == nil then 
                    -- 数据异常重新刷新分组
                    self:reflashFormationInfo()
                    return 
                end

                local str = lang("CITYBATTLE_TIP_06")
                local sysCityBattle = tab:CityBattle(tonumber(formationInfo.cid))
                str, count = string.gsub(str, "{$city}", lang(sysCityBattle.name))
                if string.find(str, "color=") == nil then
                    str = "[color=000000]"..str.."[-]"
                end                          
                self._viewMgr:showDialog("global.GlobalSelectDialog",
                    {desc = str,
                    button1 = "确定", 
                    button2 = "取消" ,
                    callback1 = function ()
                        self._viewMgr:lock()
                        self._worldLayer:leaveRoom(fid, function(result, error)
                            self._viewMgr:unlock()
                            if error ~= 0 then return end
                            self._worldLayer:removeCityMiniHeroIcon(formationInfo.cid, heroId)
                        end)
                    end,
                    callback2 = function()
                    end})
            end)
            moveBtn = fmStateReady
        -- 可创建编组
        elseif state == CityBattleConst.FORMATION_STATE.CREATE then 
            fmAdd:setVisible(true)
            fmAdd:setOpacity(100)
            fmAdd:runAction(cc.RepeatForever:create(cc.Sequence:create(
                    cc.FadeTo:create(0.8, 255),
                    cc.FadeTo:create(0.8, 100)
                )))
            self:registerClickEvent(fmImg, function()
                if self._worldLayer:resetSelectedCityState() == 1 then return end
                self:openFormation(i)
            end)
        -- 空闲待派遣
        elseif state == CityBattleConst.FORMATION_STATE.FREE then

            fmStateFree:setVisible(true)
            self:registerClickEvent(heroIcon, function()
                print("heroIcon==============================================")
                if self._worldLayer:resetSelectedCityState() == 1 then return end
                self:openFormation(i)
            end)
            moveBtn = fmStateFree
        -- 死亡
        elseif state == CityBattleConst.FORMATION_STATE.DIE then
            fmStateDie:setVisible(true)
            local function callRevive()
                if self._worldLayer:resetSelectedCityState() == 1 then return end

                --新增，点击复活优先判断是否真实死亡，不死亡情况下，强制做一个刷新编组
                local formation = self._formationModel:getFormationDataByType(fid)
                local state = self._cityBattleModel:getFormationState(fid, formation)
                if state ~= CityBattleConst.FORMATION_STATE.DIE then 
                    self:reflashFormationInfo()
                    return 
                end

                local state, weekday, timeDes= self._cityBattleModel:getState()
                if timeDes == "s4" or timeDes == "s6" then self._viewMgr:showTip(lang("CITYBATTLE_TIP_25")) return end                
                local playerData = self._playerModel:getData()
                local receive = (playerData[dayInfo[fid]] or 0) + 1
                local maxCount = table.nums(tab.reflashCost)
                receive = math.min(maxCount, receive)
                local sysReflashCost = tab:ReflashCost(receive).reviveCityBattle[3]
                local player = self._modelMgr:getModel("UserModel"):getData()


                local tip = lang("CITYBATTLE_TIP_12")
                if string.find(tip, "color=") == nil then
                    tip = "[color=000000]"..tip.."[-]"
                end                  
                if formationInfo.cid == nil then return end
                -- local sysCityBattle = tab:CityBattle(tonumber(formationInfo.cid))
                
                tip, count = string.gsub(tip, "{$revive}", sysReflashCost)
                self._reviveCDView = self._viewMgr:showDialog("arena.ArenaDialogCD", {
                    desc = tip,
                    --确定回调
                    callBack1 = function()
                        if (sysReflashCost ~= nil and player.gem < sysReflashCost) then
                            DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"), callback1 = function( )
                                local viewMgr = ViewManager:getInstance()
                                viewMgr:showView("vip.VipView", {viewType = 0})
                            end})           
                            return false
                        end
                        self:receiveFormation(fid)
                    end,
                    --取消回调
                     callBack2 = function()
                        if self._reviveCDView then
                            self._viewMgr:closeDialog(self._reviveCDView)
                            self._reviveCDView = nil
                        end
                    end
                })
                self._reviveCDView.fid = fid
                local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime() 
                if self._reviveCDView then
                    self._reviveCDViewId = formationId
                    self._reviveCDView:CDupdate(cdTime - curTime)
                end
            end
            self:registerClickEvent(heroIcon, function()
                callRevive()
            end)
            self:registerClickEvent(fmStateDie, function()
                callRevive()
            end)

            local timeProg = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("citybattle_view_temp29.png"))
            timeProg:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
            timeProg:setBarChangeRate(cc.p(0.5, 0)) 

            local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime() 
            print("curTime====", curTime)
            local per = (curTime - beginTime ) / (cdTime - beginTime) * 100
            print('111111111111111111111111111111111111111111111111111per=======================', per)
            timeProg:setReverseProgress(true)
            timeProg:setPercentage(100 - per)
            timeProg:setPosition(fmImg:getContentSize().width * 0.5, fmImg:getContentSize().height * 0.5)         
            fmImg:addChild(timeProg, 10)
            timeProg:runAction(cc.ProgressTo:create(cdTime - curTime, 0))
            fmImg.timeProg = timeProg

            --点击复活
            local lifeLabel = cc.Label:createWithTTF("点击复活",UIUtils.ttfName, 14)
            lifeLabel:setColor(cc.c3b(255,255,255))
            lifeLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
            lifeLabel:setPosition(fmImg:getContentSize().width * 0.5, 15)       
            fmImg:addChild(lifeLabel, 11)
            fmImg.lifeLabel = lifeLabel
            lifeLabel:runAction(cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.ScaleTo:create(0.5,1.1),
                    cc.ScaleTo:create(0.5,1),
                    cc.DelayTime:create(0.2)
                )
            ))

            local timeLab = cc.Label:createWithTTF(cdTime - curTime,UIUtils.ttfName, 45)
            timeLab:setColor(cc.c3b(255,83,83))
            timeLab:setPosition(fmImg:getContentSize().width * 0.5, fmImg:getContentSize().height * 0.5)       
            fmImg:addChild(timeLab, 11)
            fmImg.timeLab = timeLab
            timeLab:runAction(
                cc.RepeatForever:create(
                    cc.Sequence:create(
                        cc.CallFunc:create(
                            function()
                                local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime() 
                                if curTime >= cdTime then 
                                    timeProg:stopAllActions()
                                    self:reflashFormationInfo()
                                    if self._reviveCDView then
                                        self._viewMgr:closeDialog(self._reviveCDView)
                                        self._reviveCDView = nil
                                    end                                    
                                    return
                                end
                                timeLab:setString(cdTime - curTime)
                                if self._reviveCDView and self._reviveCDView.fid == fid then
                                    self._reviveCDView:CDupdate(cdTime - curTime)
                                end
                            end
                        ),
                        cc.DelayTime:create(1)
                    )
                )
            )
        elseif state == CityBattleConst.FORMATION_STATE.LOCK then
            SystemUtils.saveAccountLocalData("CITY_BATTLE_FORMATION_LOCK_" .. fid, 1)
            local lockStateMc = mcMgr:createViewMC("jiesuo_citybattlechengchidianji", false, true)
            lockStateMc:setPosition(cc.p(fmImg:getContentSize().width * 0.5, fmImg:getContentSize().height * 0.5 - 5))
            fmImg:addChild(lockStateMc)
            lockStateMc:stop()
            fmImg.lockStateMc = lockStateMc

            if fmImg.lockTipLab == nil then
                local lockTipLab = cc.Label:createWithTTF(limitLevel .. "级开启", UIUtils.ttfName, 15)
                lockTipLab:setColor(cc.c3b(255, 71, 74))
                lockTipLab:setPosition(fmImg:getContentSize().width * 0.5, fmImg:getContentSize().height * 0.5)       
                fmImg:addChild(lockTipLab, 11)
                lockTipLab:enableOutline(cc.c4b(116,10,14,255),1)
                fmImg.lockTipLab = lockTipLab 
            end   
            fmImg.lockTipLab:setVisible(true)
            fmImg.lockTipLab:setString(limitLevel .. "级开启")        
        end


        if state == CityBattleConst.FORMATION_STATE.CREATE then
            local lockState = SystemUtils.loadAccountLocalData("CITY_BATTLE_FORMATION_LOCK_" .. fid)
            if lockState == 1 then 
                SystemUtils.saveAccountLocalData("CITY_BATTLE_FORMATION_LOCK_" .. fid, 2)
                local lockStateMc = mcMgr:createViewMC("jiesuo_citybattlechengchidianji", false, true)
                lockStateMc:setPosition(cc.p(fmImg:getContentSize().width * 0.5, fmImg:getContentSize().height * 0.5 - 5))
                fmImg:addChild(lockStateMc)
                lockStateMc:gotoAndPlay(1)
                fmAdd:setVisible(false)
                fmAdd:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
                    fmAdd:setVisible(true)
                end)))
            end
        end
  
        if moveBtn ~= nil then
            self:registerClickEvent(moveBtn, function()
                if self._worldLayer:resetSelectedCityState() == 1 then return end
                if formationInfo.cid == nil then 
                    self._worldLayer:activeCanBattleTip(function()
                        self._viewMgr:showTip(lang("CITYBATTLE_TIP_04"))
                    end)
                    return 
                end

                self._worldLayer:locateCity(formationInfo.cid)
            end)
        end

        if timeDes ~= "s3" and timeDes ~= "s5" then
            fmStateReady:setVisible(false)
            fmStateBattle:setVisible(false)
            fmStateFree:setVisible(false)
            fmStateDie:setVisible(false)
        end
    end
end



function CityBattleView:openFormation(indexId)
    local playerData = self._playerModel:getData()
    
    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime() 
    local ftcb1 = self._formationModel.kFormationTypeCityBattle1
    local ftcb2 = self._formationModel.kFormationTypeCityBattle2
    local ftcb3 = self._formationModel.kFormationTypeCityBattle3
    local ftcb4 = self._formationModel.kFormationTypeCityBattle4

    local cityBattleInfo = {}
    for i=1,4 do
        local fid = self._formationModel["kFormationTypeCityBattle" .. i]
        local receive = playerData[dayInfo[fid]]
        local formation = self._formationModel:getFormationDataByType(fid)
        local state, beginTime, cdTime = self._cityBattleModel:getFormationState(fid, formation)

        if cityBattleInfo.reviveInfo == nil then  cityBattleInfo.reviveInfo = {} end
        if cityBattleInfo.deadInfo == nil then  cityBattleInfo.deadInfo = {} end
        if cityBattleInfo.fightInfo == nil then  cityBattleInfo.fightInfo = {} end
        -- 复活次数
        if receive == nil then
            cityBattleInfo.reviveInfo[fid] = 0
        else
            cityBattleInfo.reviveInfo[fid] = receive
        end
        -- 是否死亡， 死亡为秒
        if state == CityBattleConst.FORMATION_STATE.DIE and (cdTime - curTime) > 0 then 
            cityBattleInfo.deadInfo[fid] = cdTime  
        else
            cityBattleInfo.deadInfo[fid] = false
        end
        -- 是否出战
        if state == CityBattleConst.FORMATION_STATE.BATTLE or state == CityBattleConst.FORMATION_STATE.READY then
            cityBattleInfo.fightInfo[fid] = true
        else
            cityBattleInfo.fightInfo[fid] = false
        end

    end

    self._viewMgr:showView("formation.NewFormationView", {
        formationType = self._formationModel.kFormationTypeCityBattle1 + indexId - 1,
        extend = {cityBattleInfo = cityBattleInfo}
    })
end


function CityBattleView:setTitle()
    self._worldTitleBg = ccui.Widget:create()
    self._worldTitleBg:setContentSize(707, 81)
    self._worldTitleBg:setAnchorPoint(cc.p(0.5, 1))
    self._worldTitleBg:setPosition(cc.p(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT + 10))
    self:addChild(self._worldTitleBg, 99)
    self._worldTitleBg:setTouchEnabled(false)

    local centerTitle = ccui.ImageView:create()
    centerTitle:loadTexture("citybattle_view_img33.png", 1)
    centerTitle:setAnchorPoint(cc.p(0.5, 0.5))
    centerTitle:setPosition(cc.p(353.5, 48.5))
    self._worldTitleBg:addChild(centerTitle)

end

--s1进入s2阶段动画，收备战旗子，显示外部倒计时，显示左侧布阵（不带状态）,播放匹配服务器动画
function CityBattleView:runS2Animation()
    print("CityBattleView:runS2Animation")
    local fightTime = self._fightTimeBg:getChildByFullName("fightTime")
    fightTime:setColor(UIUtils.colorTable.ccUIBaseColor6)
    local function timeDown()
        self:runS3Animation()
    end
    CityBattleUtils:setCountDown(fightTime, 900, "距离开战剩余", function()
        print("开战 fire")
    end,{3},{timeDown})
    self._readlyBg:setCascadeOpacityEnabled(true)
    self._fightTimeBg:setCascadeOpacityEnabled(true)
    self._readlyBg:runAction(cc.Sequence:create(
        cc.Spawn:create(
            cc.MoveBy:create(0.2,cc.p(0,self._readlyBg:getContentSize().height)),
            cc.FadeOut:create(0.2)
        ),
        cc.CallFunc:create(function()
            self._readlyBg:setVisible(false)
            self._fightTimeBg:setOpacity(0)
            self._fightTimeBg:setVisible(true)
            self._fightTimeBg:runAction(cc.Sequence:create(
                cc.FadeIn:create(0.2),
                cc.CallFunc:create(function()
                    print("CityBattleView:runS2Animation 1")
                    if not self._isOpenDialog and not self._isInHide then
                        print("CityBattleView:runS2Animation 2")
                        self:checkAnima(function()
                            self:reGetServerData()
                        end)
                    else
                        print("CityBattleView:runS2Animation 3")
                        self._curDealyAni = 0
                    end
                end)
            ))
        end)
    ))

    --布阵出现
    self:reflashFormationInfo()
    self._leftFmPanel:setPositionX(self._leftFmPanel:getPositionX()-200)
    self._leftFmPanel:setVisible(true)
    self._leftFmPanel:runAction(
        cc.Sequence:create(
            cc.MoveBy:create(0.2,cc.p(210,0)),
            cc.MoveBy:create(0.2,cc.p(-10,0))
        )
    )

end

--s2进入s3阶段动画，
function CityBattleView:runS3Animation()
    if self._isOpenDialog or self._isInHide then
        self._curDealyAni = 3
        return
    end
    local function FormationStatusOut()
        local function actionStatus(node)
            if node:isVisible() then
                node:stopAllActions()
                node:setPositionX(node:getPositionX()-100)
                node:runAction(cc.Sequence:create(
                    cc.MoveBy:create(0.2,cc.p(110,0)),
                    cc.MoveBy:create(0.2,cc.p(-10,0))
                ))
            end
        end
        for i=1,4 do 
            local fmStateReady = self:getUI("leftFmPanel.fmStateReady" .. i)
            actionStatus(fmStateReady)
            local fmStateBattle = self:getUI("leftFmPanel.fmStateBattle" .. i)
            actionStatus(fmStateBattle)
            local fmStateFree = self:getUI("leftFmPanel.fmStateFree" .. i)
            actionStatus(fmStateFree)
            local fmStateDie = self:getUI("leftFmPanel.fmStateDie" .. i)
            actionStatus(fmStateDie)
        end
    end
    self:lock(-1)
    local mc1 = mcMgr:createViewMC("daojishi_leagueredian", false, true,function()
        local mc2 = mcMgr:createViewMC("zhandoukaiqi_zhandoukaiqi", false, true,function()
            self:reGetServerData()
            FormationStatusOut()
            self:unlock()
        end)
        mc2:setPosition(MAX_SCREEN_WIDTH/2,MAX_SCREEN_HEIGHT/2)
        self:addChild(mc2,100)
    end)
    mc1:setPosition(MAX_SCREEN_WIDTH/2,MAX_SCREEN_HEIGHT/2)
    self:addChild(mc1,100)

    --布阵状态出现
end

--[[
    s3进入s4阶段动画，
    ]]

function CityBattleView:runS4Animation()
    print("CityBattleView:runS4Animation")
    local function FormationStatusIn()
        local isNodeVisible
        local function actionStatus(node)
            if node:isVisible() then
                node:stopAllActions()
                isNodeVisible = true
                node:setCascadeOpacityEnabled(true)
                node:runAction(cc.Sequence:create(
                    cc.Spawn:create(
                        cc.MoveBy:create(0.2,cc.p(-100,0)),
                        cc.FadeOut:create(0.2)
                    ),
                    cc.CallFunc:create(function()
                        node:setVisible(false)
                        node:setPositionX(node:getPositionX()+100)
                        node:setOpacity(255)
                        self:checkAnima(function()
                            self:reGetServerData()
                        end)
                    end)
                ))
            end
        end
        
        for i=1,4 do 
            local fmStateReady = self:getUI("leftFmPanel.fmStateReady" .. i)
            actionStatus(fmStateReady)
            local fmStateBattle = self:getUI("leftFmPanel.fmStateBattle" .. i)
            actionStatus(fmStateBattle)
            local fmStateFree = self:getUI("leftFmPanel.fmStateFree" .. i)
            actionStatus(fmStateFree)
            local fmStateDie = self:getUI("leftFmPanel.fmStateDie" .. i)
            actionStatus(fmStateDie)
        end
        if not isNodeVisible then
            self:checkAnima(function()
                self:reGetServerData()
            end)
        end
    end
    print("CityBattleView:runS4Animation 1")
    self:lock(-1)
    local mc1 = mcMgr:createViewMC("daojishi_leagueredian", false, true,function()
        local mc2 = mcMgr:createViewMC("zhandoujieshu_zhandoukaiqi", false, true,function()
            print("CityBattleView:runS4Animation 2")
            self:unlock()
            FormationStatusIn()
        end)
        mc2:setPosition(MAX_SCREEN_WIDTH/2,MAX_SCREEN_HEIGHT/2)
        self:addChild(mc2,100)
    end)
    mc1:setPosition(MAX_SCREEN_WIDTH/2,MAX_SCREEN_HEIGHT/2)
    self:addChild(mc1,100)
end

--[[
    s5进入s6阶段动画
    --收布阵动画
]]
function CityBattleView:runS6Animation()
    print("CityBattleView:runS6Animation1")
    local function endAni()
        self._leftFmPanel:runAction(
            cc.Sequence:create(
                cc.MoveBy:create(0.2,cc.p(10,0)),
                cc.MoveBy:create(0.2,cc.p(-210,0)),
                cc.CallFunc:create(function()
                    self._leftFmPanel:setVisible(false)
                    self._leftFmPanel:setPositionX(self._leftFmPanel:getPositionX()+200)
                    self:checkAnima(function()
                        self:reGetServerData()
                    end)
                end)
            )
        )
    end

    self:lock(-1)
    print("CityBattleView:runS6Animation2")
    local mc1 = mcMgr:createViewMC("daojishi_leagueredian", false, true,function()
        local mc2 = mcMgr:createViewMC("zhandoujieshu_zhandoukaiqi", false, true,function()
            self:unlock()
            endAni()
            print("CityBattleView:runS6Animation3")
        end)
        mc2:setPosition(MAX_SCREEN_WIDTH/2,MAX_SCREEN_HEIGHT/2)
        self:addChild(mc2,100)
    end)
    mc1:setPosition(MAX_SCREEN_WIDTH/2,MAX_SCREEN_HEIGHT/2)
    self:addChild(mc1,100)
end

function CityBattleView:forceInitTimeSatus()
    self._cityBattleModel:initTimeStatus()
end

-- title 倒计时
function CityBattleView:setTitleTime(state, weekday, timeDes)
    print("CityBattleView:setTitleTime",state,weekday,timeDes)
    local curServerTime = self._userModel:getCurServerTime()
    local fightTime = self._fightTimeBg:getChildByFullName("fightTime")
    fightTime:setColor(UIUtils.colorTable.ccUIBaseColor1)
    local timeGap = 5
    if timeDes == "s1" then
        self._readlyBg:setVisible(true)
        self._fightTimeBg:setVisible(false)
        local readlyTime = self:getUI("titleBg.readlyBg.readlyTime")
        local huoyue = self:getUI("titleBg.readlyBg.huoyue")
        local tishi = self:getUI("titleBg.readlyBg.tishi")
        local s1OverTime,s2OverTime,s3OverTime,s4OverTime,s5OverTime,s6OverTime = self._cityBattleModel:getOverTime()
        -- local currTime = curServerTime + 86400*(6-weekday)
        local left = self._cityBattleModel:getLeftBuildTimes()
        huoyue:setString("建造次数:"..left)
        -- local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(currTime,"%Y-%m-%d 21:00:00"))
        readlyTime:enableOutline(cc.c4b(116,10,14,255),1)
        local function FifTimeDown()
            print("进入战前准备15分钟")
            self:forceInitTimeSatus()
            self:runS2Animation()
        end

        CityBattleUtils:setCountDown(readlyTime, s2OverTime-curServerTime+timeGap, "距离开战剩余 ", function()
            print("倒计时结束 setTitleTime2")
            -- self:battleOpenThreeSecDown()
        end,{900},{FifTimeDown})
    elseif timeDes == "s2" then
        self._readlyBg:setVisible(false)
        self._fightTimeBg:setVisible(true)
        fightTime:setColor(UIUtils.colorTable.ccUIBaseColor6)
        local s1OverTime,s2OverTime,s3OverTime,s4OverTime,s5OverTime,s6OverTime = self._cityBattleModel:getOverTime()
        local function timeDown()
            print("s2 timeDown")
            self:forceInitTimeSatus()
            self:runS3Animation()
        end
        local leftTime = math.max(4,s2OverTime-curServerTime)+timeGap
        CityBattleUtils:setCountDown(fightTime,leftTime, "距离开战剩余", function()
            print("开战 fire")
            -- self:enterCityBattle()
        end,{3},{timeDown})
    elseif timeDes == "s3" then
        self._readlyBg:setVisible(false)
        self._fightTimeBg:setVisible(true)
        local s1OverTime,s2OverTime,s3OverTime,s4OverTime,s5OverTime,s6OverTime = self._cityBattleModel:getOverTime()
        CityBattleUtils:setCountDown(fightTime, s3OverTime-curServerTime+timeGap-3, "距离结束", function()
            print("进入s4")
            self:forceInitTimeSatus()
            if self._isOpenDialog or self._isInHide then
                self._curDealyAni = 4
            else
                self:runS4Animation()
            end
        end)
    elseif timeDes == "s4" then
        self._readlyBg:setVisible(false)
        self._fightTimeBg:setVisible(true)
        local s1OverTime,s2OverTime,s3OverTime,s4OverTime,s5OverTime,s6OverTime = self._cityBattleModel:getOverTime()
        local leftTime = math.max(4,s4OverTime-curServerTime)+timeGap
        local function timeDown()
            self:forceInitTimeSatus()
            self:runS3Animation()
        end
        CityBattleUtils:setCountDown(fightTime, leftTime, "距离下一次开战", function()

        end,{3},{timeDown})
    elseif timeDes == "s5" then
        self._readlyBg:setVisible(false)
        self._fightTimeBg:setVisible(true)
        local s1OverTime,s2OverTime,s3OverTime,s4OverTime,s5OverTime,s6OverTime = self._cityBattleModel:getOverTime()
        CityBattleUtils:setCountDown(fightTime, s5OverTime-curServerTime+timeGap, "距离结束", function()
            print("进入s6")
            self:forceInitTimeSatus()
            self._cityBattleModel:reflashData("IntoS6")
            if self._isOpenDialog or self._isInHide then
                self._curDealyAni = 6
            else
                self:runS6Animation()
            end
        end)
    elseif timeDes == "s6" or timeDes == "s7" then
        self._readlyBg:setVisible(false)
        self._fightTimeBg:setVisible(true)
        local s1OverTime,s2OverTime,s3OverTime,s4OverTime,s5OverTime,s6OverTime,s7OverTime = self._cityBattleModel:getOverTime()
        local leftTime
        if curServerTime > s7OverTime then
            leftTime = s6OverTime + 450000 - curServerTime
        else
            leftTime = s7OverTime - curServerTime + 2
        end
        local function refreshTime()
            -- self._viewMgr:showView("intance.IntanceView",{},true)
            ViewManager:getInstance():returnMain()
        end
        CityBattleUtils:setCountDown(fightTime, leftTime, "距离下一届开始", function()
            -- self:reGetServerData()
            -- self:checkAnima()
            -- self._cityBattleModel:reflashData("IntoS1")
        end,{180},{refreshTime})
    end
end



function CityBattleView:setTitle2()
    local state, weekday, timeDes = self._cityBattleModel:getState()
    self:setTitleTime(state, weekday, timeDes)
end



function CityBattleView:onBeforeAdd(callback, errorCallback)
    self._isBeforeRequest = true
    self._onBeforeAddCallback = function(inType)
        if inType == 1 then 
            callback()
        else
            errorCallback()
            self._viewMgr:unlock(51)
        end
        self._isBeforeRequest = false
        self._onBeforeAddCallback = nil
    end

    local requestFormation = 0
    for i=1,4 do
        local fid = self._formationModel["kFormationTypeCityBattle" .. i]
        print("self._formationModel:isFormationDataExistByType(fid)================", self._formationModel:isFormationDataExistByType(fid))
        if not self._formationModel:isFormationDataExistByType(fid) then 
            requestFormation = 1
        end
    end
    if requestFormation == 1  then 
        self:initGVGFormation()
    else
        self:enterCityBattle()
    end
end


function CityBattleView:initGVGFormation()
    self._serverMgr:sendMsg("CityBattleServer", "initGVGFormation", {}, true, {}, function (result)
        self:enterCityBattle()
    end)    
end

--[[
    初始等待登录10001，超10s无返回则关闭
]]
function CityBattleView:waitingLoginResult()
    ScheduleMgr:delayCall(10000, self, function()
        self:clearLock()
        ServerManager:getInstance():RS_clear()
        if self._onBeforeAddCallback == nil then return end
        self._onBeforeAddCallback(2)
    end)
end


function CityBattleView:enterCityBattle()
    local state, weekday = self._cityBattleModel:getState()
    if state == 1 then 
        self._cityBattleModel:setLoginCallback(function()
            print('setLoginCallback====')
            ScheduleMgr:cleanMyselfDelayCall(self)
            if self.enterCityBattleFinish then
                self:enterCityBattleFinish(1)
            end
            CityBattleConst.RECONNECTCOUNT = CityBattleConst.RECONNECTCOUNT + 1
        end)
        ServerManager:getInstance():RS_clear()
        self._serverMgr:sendMsg("CityBattleServer", "getCitybattleSoketData", {}, true, {}, function (result, error)
            if error ~= 0 then 
                -- self._viewMgr:showTip("连接服务器失败")
                if self.enterCityBattleFinish then
                    ScheduleMgr:cleanMyselfDelayCall(self)
                    self:enterCityBattleFinish()
                end
                return
            end
            --java init 成功也会走这个回调，所以判断999 php 成功
            if result and result.status == 999 then
                self:waitingLoginResult()
            end
            -- self._onBeforeAddCallback(1)
            -- self:setVisible(false)
        end)
    else
        self._serverMgr:sendMsg("CityBattleServer", "enterCityBattle", {}, true, {}, function (result)
            if self.enterCityBattleFinish then
                self:enterCityBattleFinish(result)
            end
        end)
    end
end

function CityBattleView:enterCityBattleFinish(result)
    if CityBattleConst.RECONNECTCOUNT > 0 then 
        self:clearLock()
        self:reflashUI()
        if self._worldLayer then
            self._worldLayer:resetBigMap()
        end
    else
        if self._onBeforeAddCallback == nil then return end
        if result == nil then
            self._onBeforeAddCallback(2)
            return 
        end
        self._onBeforeAddCallback(1)
        self:TheFirstComeIn()
        self:reflashUI()
        self._worldLayer:loadBigMap()
    end
end

--首次进gvg界面，显示一个规则界面
function CityBattleView:TheFirstComeIn()
    local isFirst = self._cityBattleModel:isFirstOpen()
    if isFirst then
        self._viewMgr:showDialog("global.CommonNewGuideDialog",{showType = 3,callBack = function()
            self:checkAnima()
        end},true)
    else
        self:checkAnima()
    end
    self:standByFirstEnterAction()
    self:runFirstEnterAction()
    -- ScheduleMgr:delayCall(0, self, function()
    --     self:runFirstEnterAction()   
    -- end)
end

function CityBattleView:checkAnima(callBack)
    local stats 
    if self._animaStutas then
       stats = self._animaStutas
       self._animaStutas = nil
    else
        stats = self._cityBattleModel:getShowAnimationType()
    end
    print("CityBattleView:checkAnima stats--->",stats)
    if stats == "readyAnima" then
        print("备战开启动画")
        self:playReadyAnimation(callBack)
    elseif stats == "battleAnima" then
        print("匹配服务器动画")
        self:battleOpenAni(callBack)
    else
        if stats == "result1" then
            print("展示战中结算面板")
            if GameStatic.revertGvg_rebuild then
                self._viewMgr:showView("citybattle.CityBattleResultView",{showType = 1},true)
            else
                self._viewMgr:showView("citybattle.CityBattleResultView",{showType = 1, callBack = callBack},true)
            end
        elseif stats == "result2" then
            print("展示赛季结算面板")
            if GameStatic.revertGvg_rebuild then
                self._viewMgr:showView("citybattle.CityBattleResultView",{showType = 2},true)
            else
                self._viewMgr:showView("citybattle.CityBattleResultView",{showType = 2, callBack = callBack},true)
            end
        else
            if callBack then
                callBack()
            end
        end
        local state,weekday,timeDes = self._cityBattleModel:getState()
        if timeDes == "s1" then
            self._readlyBg:setVisible(true)
        end
        self._listPanel:setVisible(true)
    end
end

function CityBattleView:onAdd()
end

function CityBattleView:standByFirstEnterAction()
    self._worldElementLayer:standByFirstEnterAction()
    self._titleBg:setVisible(false)
    self._leftFmPanel:setVisible(false)
    self._titleBg:setPosition(self._titleBg:getPositionX(),MAX_SCREEN_HEIGHT)
    self._worldTitleBg:setPosition(self._worldTitleBg:getPositionX(),MAX_SCREEN_HEIGHT+210)
    local state,weekday,timeDes = self._cityBattleModel:getState()
    if timeDes ~= "s1" and timeDes ~= "s6" and timeDes ~= "s7" then
        self._leftFmPanel:setPositionX(self._leftFmPanel:getPositionX()-200)
    end
    self._animaStutas = self._cityBattleModel:getShowAnimationType()
    if self._animaStutas ~= "readyAnima" and self._animaStutas ~= "battleAnima" then
        if timeDes == "s1" then
            self._readlyBg:setVisible(true)
        end
    end
    self._listPanel:setPositionX(self._listPanel:getPositionX()+200)
end

--[[
    首次进入的回弹动画
]]
function CityBattleView:runFirstEnterAction()
    local state, weekday, timeDes= self._cityBattleModel:getState()
    self._worldElementLayer:runFirstEnterAction()
    self._titleBg:setVisible(true)
    self._titleBg:runAction(
        cc.Sequence:create(
            cc.MoveTo:create(0.2, cc.p(self._titleBg:getPositionX(),MAX_SCREEN_HEIGHT-210)),
            cc.MoveTo:create(0.2, cc.p(self._titleBg:getPositionX(),MAX_SCREEN_HEIGHT-198))
        )
    )
    self._worldTitleBg:runAction(
        cc.Sequence:create(
            cc.MoveTo:create(0.2, cc.p(self._worldTitleBg:getPositionX(),MAX_SCREEN_HEIGHT)),
            cc.MoveTo:create(0.2, cc.p(self._worldTitleBg:getPositionX(),MAX_SCREEN_HEIGHT+10))
        )
    )
    if timeDes ~= "s1" and timeDes ~= "s6" and timeDes ~= "s7" then
        self._leftFmPanel:setVisible(true)
        self._leftFmPanel:runAction(
            cc.Sequence:create(
                cc.MoveBy:create(0.2,cc.p(210,0)),
                cc.MoveBy:create(0.2,cc.p(-10,0))
            )
        )
    end
    if self._listPanel:isVisible() then
        self._listPanel:setVisible(true)
        self._listPanel:runAction(
            cc.Sequence:create(
                cc.MoveBy:create(0.2,cc.p(-210,0)),
                cc.MoveBy:create(0.2,cc.p(10,0))
            )
        )
    end
end

-- --开战前3秒倒计时动画
-- function CityBattleView:battleOpenThreeSecDown()
--     self._readlyBg:setVisible(false)
--     self._fightTimeBg:setVisible(true)
--     local fightTime = self:getUI("titleBg.fightTimeBg.fightTime")

--     local function timeDown()
--         local mc1 = mcMgr:createViewMC("daojishi_leagueredian", false, true,function()
--             self._worldLayer:resetBigMap()
--             self:reflashUI()
--             self:checkAnima()
--             self:enterCityBattle()
--         end)
--         mc1:setPosition(MAX_SCREEN_WIDTH/2,MAX_SCREEN_HEIGHT/2)
--         self:addChild(mc1,100)
--     end
--     fightTime:setColor(UIUtils.colorTable.ccUIBaseColor6)
--     CityBattleUtils:setCountDown(fightTime, 10,"", function()

--     end,{3},{timeDown})
-- end

function CityBattleView:playReadyAnimation(callBack)
    self:lock(-1)
    self._readlyBg:setVisible(false)
    self._readlyBg:setPositionY(self._readlyBg:getPositionY()+150)
    self._readlyBg:setCascadeOpacityEnabled(true)
    self._readlyBg:setOpacity(0)
    self._worldTitleBg:setVisible(false)

    local opacityNum = 180

    local maskLayer = ccui.Layout:create()
    maskLayer:setBackGroundColorOpacity(255)
    maskLayer:setBackGroundColorType(1)
    maskLayer:setBackGroundColor(cc.c3b(0,0,0))
    maskLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    maskLayer:setOpacity(0)
    maskLayer:setAnchorPoint(0.5,1)
    maskLayer:setPosition(self._titleBg:getContentSize().width/2,self._titleBg:getContentSize().height)

    self._titleBg:addChild(maskLayer,99)
    local function Ready()
        self._readlyBg:setVisible(true)
        self._readlyBg:runAction(cc.Sequence:create(
            cc.Spawn:create(
                cc.EaseOut:create(cc.MoveBy:create(0.1, cc.p(0,-150)), 3),
                cc.FadeIn:create(0.1)
            ),
            cc.CallFunc:create(function()
                print("end")
                self._worldTitleBg:setVisible(true)
                if callBack then
                    callBack()
                end
                self:unlock()
            end)
        ))
    end

    local mc1 = mcMgr:createViewMC("kaiqiqizi_kaiqi", false, true,function()
        Ready()
    end)
    mc1:setPosition(self._titleBg:getContentSize().width/2,self._titleBg:getContentSize().height+40)
    self._titleBg:addChild(mc1,100)


    --底部光线特效
    local mc2 = mcMgr:createViewMC("guang_chuanqijiemianfla", false, true)
    mc2:setPosition(self._titleBg:getContentSize().width/2,self._titleBg:getContentSize().height)
    self._titleBg:addChild(mc2,99)
    mc2:runAction(cc.Sequence:create(
        cc.Spawn:create(
            cc.FadeIn:create(0.2),
            cc.ScaleTo:create(0.2,1.3)
        ),
        cc.FadeOut:create(0.8)
    ))
    --[[
    local title_history = self._titleBg:getChildByName("Titlewidget")
    if not title_history then
        title_history = self:setTitleNum()
        self._titleBg:addChild(title_history)
        title_history:setName("Titlewidget")
        title_history:setZOrder(101)
        title_history:setPosition(self._titleBg:getContentSize().width/2+160,self._titleBg:getContentSize().height/2+80)
    end
    
    -- title_history:setAnchorPoint(0.5,0.5)
    -- title_history:setPosition(self._titleBg:getContentSize().width/2,0)
    
    local historyNum = self._cityBattleModel:getGvgNum() or 1
    local title_totalWidth = 300
    local numLable = title_history:getChildByFullName("numLable")
    if not numLable then
        numLable = cc.Label:createWithBMFont(UIUtils.bmfName_gvg,historyNum)
        numLable:setAnchorPoint(cc.p(0.5,0.5))
        title_history:addChild(numLable, 2)
        numLable:setPosition(0,0)
        numLable:setName("numLable")
    end

    
    title_history:setCascadeOpacityEnabled(true,true)
    title_history:setOpacity(0)

    local image1 = title_history:getChildByFullName("image1")
    local image2 = title_history:getChildByFullName("image2")
    local image3 = title_history:getChildByFullName("image3")
    local image4 = title_history:getChildByFullName("image4")
    local lineWidth = title_totalWidth - image2:getContentSize().width - image3:getContentSize().width
    lineWidth = lineWidth - numLable:getContentSize().width - 20
    local scale_num = lineWidth/2/image1:getContentSize().width
    image1:setScaleX(scale_num)
    image4:setScaleX(scale_num)


    image2:setPositionX(numLable:getPositionX()-numLable:getContentSize().width/2-image2:getContentSize().width/2)
    image3:setPositionX(numLable:getPositionX()+numLable:getContentSize().width/2+image3:getContentSize().width/2)
    image1:setPositionX(image2:getPositionX()-image2:getContentSize().width/2-image1:getContentSize().width/2*scale_num-10)
    image4:setPositionX(image3:getPositionX()+image3:getContentSize().width/2+image4:getContentSize().width/2*scale_num+10)

    --5.7s 闪光字体
    local titleBg = self._titleBg
    ScheduleMgr:delayCall(600, self, function()
        local mc3 = mcMgr:createViewMC("zitiguang_kaiqi", false, true)
        mc3:setPosition(titleBg:getContentSize().width/2,titleBg:getContentSize().height-60)
        titleBg:addChild(mc3,102)
    end)
    
    ScheduleMgr:delayCall(700, self, function()
        title_history:setVisible(true)
        title_history:runAction(cc.Sequence:create(
            cc.FadeIn:create(0.2),
            cc.DelayTime:create(1.6),
            cc.FadeOut:create(0.2),
            cc.RemoveSelf:create(),
            cc.CallFunc:create(function()
                self._Titlewidget = nil 
            end)
        ))
    end)
    --]]
    

    maskLayer:runAction(cc.Sequence:create(
        cc.FadeTo:create(0.5,opacityNum),
        cc.DelayTime:create(2),
        cc.FadeTo:create(1,0)
    ))
end

--[[

function CityBattleView:setTitleNum()
    if self._Titlewidget then
        return self._Titlewidget
    end
    self._Titlewidget = ccui.Widget:create()
    self._Titlewidget:setContentSize(320, 80)
    self._Titlewidget:setAnchorPoint(cc.p(0.5, 0.5))
    self._Titlewidget:setColor(cc.c3b(0,0,0))

    local image1 = cc.Sprite:createWithSpriteFrameName("citybattle_rankLine.png")
    self._Titlewidget:addChild(image1)
    image1:setName("image1")
    image1:setAnchorPoint(0.5,0.5)

    local image2 = cc.Sprite:createWithSpriteFrameName("citybattle_di.png")
    self._Titlewidget:addChild(image2)
    image2:setName("image2")
    image2:setAnchorPoint(0.5,0.5)

    local image3 = cc.Sprite:createWithSpriteFrameName("citybattle_jie.png")
    self._Titlewidget:addChild(image3)
    image3:setName("image3")
    image3:setAnchorPoint(0.5,0.5)

    local image4 = cc.Sprite:createWithSpriteFrameName("citybattle_rankLine.png")
    self._Titlewidget:addChild(image4)
    image4:setName("image4")
    image4:setAnchorPoint(0.5,0.5)
    return self._Titlewidget
end
]]


function CityBattleView:listenModel(inType)
    if inType == nil then
        return
    end

    if self["reflash" .. inType] then
        self["reflash" .. inType](self)
    else
        if self._worldLayer ~= nil then 
            local listenData = string.split(inType, "_data:")
            if #listenData == 2 then 
                if self._worldLayer["listenModel" .. listenData[1]] == nil then
                    print("CityBattleView: Not found listenModel" .. listenData[1])
                    return
                end
                self._worldLayer["listenModel" .. listenData[1]](self._worldLayer, unserialize(listenData[2]))

            else
                if self._worldLayer["listenModel" .. inType] == nil then
                    print("CityBattleView: Not found listenModel" .. inType)
                    return
                end
            end
            -- print("inType--------------------------------------------------", inType)
            -- dump(self._guildMapModel:getEvents())
        end
    end
    -- self:reflashServerNum()
end

function CityBattleView:reflashReportRedChanged()
    if self._worldElementLayer ~= nil then 
        self._worldElementLayer:updateExtendBar()
    end
end

--[[
    九点弹出结算界面
]]
function CityBattleView:reflashCheckResult()
    print("CityBattleView:reflashCheckResult11111111111111")
    if not self._isOpenDialog and not self._isInHide then
        self:checkAnima()
    else
        self._curDealyAni = 7
    end
end

function CityBattleView:reflashBuildDone()
    local huoyue = self:getUI("titleBg.readlyBg.huoyue")
    local left = self._cityBattleModel:getLeftBuildTimes()
    huoyue:setString("建造次数:"..left)
end

function CityBattleView:reflashLogin()
    local result = self._cityBattleModel:getEvents()["LoginData"]
    -- if self.enterCityBattleFinish then
    --     self:enterCityBattleFinish(result)
    -- end
    -- self:setVisible(true)
    self:close()
end

function CityBattleView:onShow()
    print("CityBattleView:onShow")
    self:updateRealVisible(true)
    if self._worldLayer ~= nil then 
        self._worldLayer:unLockTouch()
    end

    if self._initShow then
        self:reGetServerData()
    end
    self._initShow = true
    -- 弹幕
    ScheduleMgr:delayCall(0, self, function()
        self:updateBulletBtnState()
        self:showBullet()
    end)
end

--[[
    等待数据返回倒计时，超10s无返回踢出界面
]]
function CityBattleView:waitingServerData()
    -- if self._waitSchedule then
    --     ScheduleMgr:unregSchedule(self._waitSchedule)
    --     self._waitSchedule = nil
    -- end

    -- self._waitSchedule = ScheduleMgr:regSchedule(10000,self,function()
    --     self:clearLock()
    --     ViewManager:getInstance():returnMain()
    -- end)
     ScheduleMgr:delayCall(10000, self, function()
        self:clearLock()
        ViewManager:getInstance():returnMain()
    end)
end

function CityBattleView:reGetServerData()
    print("CityBattleView:reGetServerData")
    local state, weekday, timeDes = self._cityBattleModel:getState()
    if state == 1 then 
        print("CityBattleView:reGetServerData 1")
        self._cityBattleModel:setLoginCallback(function()
            print("CityBattleView:reGetServerData3")
            self:clearLock()
            self:reflashUI()
            ScheduleMgr:cleanMyselfDelayCall(self)
            if self._worldLayer then
                self._worldLayer:resetBigMap()
            end
        end)
        ServerManager:getInstance():RS_clear()
        self._serverMgr:sendMsg("CityBattleServer", "getCitybattleSoketData", {}, true, {}, function (result, error)
            if self.lock == nil then return end
            if error ~= 0 then 
                self._viewMgr:showTip("连接服务器失败")
                self:clearLock()
                ViewManager:getInstance():returnMain()
                return 
            end
            if result and result.status == 999 then
                self:lock(-1)
                self:waitingServerData()
            end
        end)
    else
        print("CityBattleView:reGetServerData2")
        self._serverMgr:sendMsg("CityBattleServer", "enterCityBattle", {}, true, {}, function (result)
            print("CityBattleView:reGetServerData4")
            if timeDes == "s1" then
                self:reflashBuildDone()
            end
            self:clearLock()
            self:reflashUI()
            if self._worldLayer then
                self._worldLayer:resetBigMap()
            end
        end)
    end
end


-- 获取战报列表
function CityBattleView:getReportList()
    self._serverMgr:sendMsg("CityBattleServer", "getReportList", {}, true, {}, function (result)
        self._viewMgr:showDialog("citybattle.CityBattleReportDialog", result)
    end)
end


function CityBattleView:receiveFormation(inFid)
    local formation = self._formationModel:getFormationDataByType(inFid)
    local state, beginTime, cdTime = self._cityBattleModel:getFormationState(inFid, formation)
    if state ~= CityBattleConst.FORMATION_STATE.DIE then 
        self._viewMgr:showTip("编组无需复活")
        return 
    end
    self._serverMgr:sendMsg("CityBattleServer", "reviveFormation", {id = inFid}, true, {}, function (result, error)
        if self._reviveCDView then
            self._viewMgr:closeDialog(self._reviveCDView)
            self._reviveCDView = nil
        end             
        if error == 4207 then self._viewMgr:showTip("编组无需复活") end

        if error ~= 0 then self._viewMgr:showTip("复活失败") end
    end)

end



--[[
    进入，离开gvg, 
    _type nil or 0 进入
    _type 1 离开
]]
function CityBattleView:setGvgRoomStatus(_type)
    local actionName = "joinRoom"
    if _type == 1 then
        actionName = "exitRoom"
    end
    self._serverMgr:sendMsg("CityBattleServer", actionName, {sid = "gvg"}, false, {})
end

function CityBattleView:getAsyncRes()
    return {            
                {"asset/ui/citybattle.plist", "asset/ui/citybattle.png"},
                {"asset/ui/citybattle1.plist", "asset/ui/citybattle1.png"},
                {"asset/ui/citybattle2.plist", "asset/ui/citybattle2.png"},
                }
end

--[[
    检测消息丢失
]]
function CityBattleView:checkMessgeLog()
    if not OS_IS_WINDOWS then return end
    print("CityBattleView:checkMessgeLog begin >>>>>>>>>>>>>>>>>>>>")
    if self._worldLayer then
        self._worldLayer:printMessageLog()
    end
    print("CityBattleView:checkMessgeLog end >>>>>>>>>>>>>>>>>>>>")
end

function CityBattleView:onDestroy()
    self:checkMessgeLog()
    self:setGvgRoomStatus(1)
    if self._schedule then
        ScheduleMgr:unregSchedule(self._schedule)
        self._schedule = nil
    end
    ScheduleMgr:cleanMyselfDelayCall(self)
    BulletScreensUtils.clear()
    CityBattleConst.RECONNECTCOUNT = 0
    CityBattleView.super.onDestroy(self)
end

function CityBattleView.dtor()
    tonumber = nil
    tostring = nil
    dayInfo = nil

end

return  CityBattleView