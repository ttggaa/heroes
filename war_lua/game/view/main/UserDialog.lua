--[[
    Filename:    UserDialog.lua
    Author:      qiaohuan@playcrab.com 
    Datetime:    2015-12-01 18:20:48
    Description: File description
--]]
local UserDialog = class("UserDialog", BasePopView)

local httpManager = HttpManager:getInstance()

function UserDialog:ctor(param)
    param = param or {}
    UserDialog.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
    self._userInfo = self._userModel:getData()
    self._idx = param.idx or 1
    self._callBack = param and param.callBack
end

function UserDialog:onInit() 
    self._bgPanel = self:getUI("bg.bgPanel")

    self._setPanel = self:getUI("bg.setPanel")
    self._setPanel:setVisible(false)
    self._exp = self:getUI("bg.bgPanel.exp")
    self._exp:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._union = self:getUI("bg.bgPanel.desBg1.union")

    UIUtils:setTitleFormat(self:getUI("bg.titleBg.title"),1)
    --联盟退出按钮
    self._guildExitBtn = ccui.Button:create()
    self._guildExitBtn:loadTextures("globalButtonUI7_float_yellow.png","globalButtonUI7_float_yellow.png","",1)    
    self._guildExitBtn:setTitleFontName(UIUtils.ttfName)
    self._guildExitBtn:setTitleColor(UIUtils.colorTable.ccUICommonBtnColor1)
    self._guildExitBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine6,1)
    self._guildExitBtn:setTitleFontSize(22)
    self._guildExitBtn:setTitleText("退出联盟")    
    local btnW = self._guildExitBtn:getContentSize().width * 0.8    
    -- self._guildExitBtn:setPosition(self._union:getPositionX()+self._union:getContentSize().width+btnW*0.5+10,self._union:getPositionY()+3)
    self._guildExitBtn:setPosition(230,self._union:getPositionY())
    self._union:getParent():addChild(self._guildExitBtn)

    self:registerClickEvent(self._guildExitBtn, function ( )



    local tips = lang("GUILD_EXIT_TIPS_4")
    local player_level = self._userModel:getData().lvl
    local limit_level = tab:Setting("G_GUILD_EXIT_LEVEL").value
    if player_level >= tonumber(limit_level) then
        tips = lang("GUILD_EXIT_TIPS_1")
    end
    self._viewMgr:showDialog("global.GlobalSelectDialog",
                {desc = tips,
                alignNum = 1,
                -- button1 = "确定",
                -- button2 = "取消", 
                callback1 = function ()
                    self._serverMgr:sendMsg("GuildServer", "quitGuild", {}, true, {}, function (result)
                        self._viewMgr:showTip("已成功退出联盟！")
                        self._modelMgr:getModel("MainViewModel"):reflashMainView()
                        self._modelMgr:getModel("UserModel"):updateGuildLevel(0)

                        --删除全局抢红包界面  wangyan
                        if self._viewMgr._redBoxLayer.robLayer ~= nil then
                            self._viewMgr._redBoxLayer.robLayer:removeFromParent(true)
                            self._viewMgr._redBoxLayer.robLayer = nil
                        end
                        -- 更新联盟显示
                        self:updateGuildInfo()
                    end)
                end,
                callback2 = function()

                end},true)    
    end)

    self._nameBg = self:getUI("bg.bgPanel.nameBg")
    self._name = self:getUI("bg.bgPanel.name")
    self._name:setFontName(UIUtils.ttfName)
    -- self._name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    --描述加描边 id
    local idDes = self:getUI("bg.bgPanel.desBg1.idDes")
    -- idDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    local id = self:getUI("bg.bgPanel.desBg1.id")

    local realName = cc.Sprite:createWithSpriteFrameName("globalImg_realName.png")
--    realName:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    realName:setScale(0.9)
    realName:setPosition(493, 99)
    realName:setVisible(GameStatic.is_show_realName)
    self:getUI("bg.bgPanel.desBg1"):addChild(realName)

    self._headIcon = self:getUI("bg.bgPanel.headImgNode")

    self._expProBar = self:getUI("bg.bgPanel.expProBar")

    --设置面板
    -- for i = 1, 3 do
    --     local checkBoxDes = self:getUI("bg.setPanel.checkBg.checkBoxDes"..i)
    --     checkBoxDes:setColor(UIUtils.colorTable.ccUIBaseColor1)
    --     checkBoxDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    -- end

    local checkBox
    -- 省电模式
    checkBox = self:getUI("bg.setPanel.checkBg.checkBox1")
    checkBox:setSelected(GameStatic.setting_PowerSaving)
    checkBox:addEventListener(function (_, state)
        local selected = state == 0
        GameStatic.setting_PowerSaving = selected
        if GameStatic.setting_PowerSaving then
            GameStatic.normalAnimInterval  = 1 / 30   
        else
            GameStatic.normalAnimInterval  = 1 / 60
        end
        cc.Director:getInstance():setAnimationInterval(GameStatic.normalAnimInterval)
        SystemUtils.saveGlobalLocalData("setting_PowerSaving", selected)
    end)

    -- 点击效果
    checkBox = self:getUI("bg.setPanel.checkBg.checkBox2")
    checkBox:setSelected(GameStatic.setting_ClickEff)
    checkBox:addEventListener(function (_, state)
        local selected = state == 0
        GameStatic.setting_ClickEff = selected
        SystemUtils.saveGlobalLocalData("setting_ClickEff", selected)
    end)
    -- 体力推送
    checkBox = self:getUI("bg.setPanel.checkBg.checkBox3")
    checkBox:setSelected(GameStatic.setting_PushPhysic)
    checkBox:addEventListener(function (_, state)
        local selected = state == 0
        GameStatic.setting_PushPhysic = selected
        SystemUtils.saveGlobalLocalData("setting_PushPhysic", selected) 
    end)
    --音量设置
    -- local musicTitle = self:getUI("bg.setPanel.musicSel.title")
    -- local effectTitle = self:getUI("bg.setPanel.effectSel.title")
    -- musicTitle:setColor(UIUtils.colorTable.ccUIBaseColor1)
    -- effectTitle:setColor(UIUtils.colorTable.ccUIBaseColor1)
    -- musicTitle:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    -- effectTitle:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    --战斗力
    self._fightData = {}
    -- self:initFightData()
    self._figthPanel = self:getUI("bg.bgPanel.fightPanel")
    self._scrollView = self:getUI("bg.bgPanel.fightPanel.scrollView")
    --初始化战力列表
    -- self:initFightPanel()

    self:listenReflash("UserModel", self.reflashUI)
    self:registerClickEventByName("bg.back", function ()
        if self._lastTimeSch then
            ScheduleMgr:unregSchedule(self._lastTimeSch)
            self._lastTimeSch = nil
        end
        if self._callBack then
            self._callBack()
        end
        self:close()
        UIUtils:reloadLuaFile("main.UserDialog")
    end)
    self:registerClickEventByName("bg.bgPanel.changeIcon", function ()
        print("更换头像")
        self._serverMgr:sendMsg("AvatarsServer","getAvatarInfo",{}, true, {},function( )
            self._viewMgr:showDialog("main.DialogSelectAvatar",{},true)
        end)
    end)
    local arenaOpen = SystemUtils["enableArena"]
    self:registerClickEventByName("bg.bgPanel.changeSlogan", function ()
        -- self._serverMgr:sendMsg("ArenaServer", "enterArena", {}, true, {}, function(result)
            self._viewMgr:showDialog("arena.DialogArenaSlogan",{},true)
        -- end)
    end)

    if not arenaOpen then
        local sloganBtn = self:getUI("bg.bgPanel.changeSlogan")
        sloganBtn:setEnabled(false)
        sloganBtn:setBright(false)
    end
    self:registerClickEventByName("bg.bgPanel.changeName", function ()
        -- print("改名字")
        self._viewMgr:showDialog("main.DialogChangeName",{},true)
    end)
    self:registerClickEventByName("bg.bgPanel.detail.exChange", function ()
        self._viewMgr:showTip("暂未开放")
        -- print("礼包兑换")
    end)

    self:registerClickEventByName("bg.bgPanel.showBtn", function ()
        -- print("炫耀一下")
        self._viewMgr:showTip("暂未开放")
        -- self._viewMgr:showView("mf.MFView")
    end)


    self:addShareBtn(true)

    -- 登出
    local logoutBtn = self:getUI("bg.setPanel.logoutBtn")
    self:registerClickEvent(logoutBtn, function ()
        if not GameStatic.enableSDK then
            self._viewMgr:restart()
        else
            sdkMgr:logout({}, function(code, data)
                code = tonumber(code)
                if code == sdkMgr.SDK_STATE.SDK_LOGOUT_SUCCESS then
                    self._viewMgr:restart()
                elseif code == sdkMgr.SDK_STATE.SDK_LOGOUT_FAIL then
                    self._viewMgr:showTip("切换账号失败")
                end
            end)
        end
    end)

    -- 当前服务器
    local serverName = self:getUI("bg.setPanel.serverBg.serverName")
    serverName:setString(self._modelMgr:getModel("LeagueModel"):getServerName(self._userInfo.sec))

    local contractLabel = self:getUI("bg.setPanel.innerBg.contractLabel")
    contractLabel:setScaleAnim(true)
    self:registerClickEvent(contractLabel, function ()
        sdkMgr:loadUrl({type = "1", url = GameStatic.contractUrl})
        print(GameStatic.contractUrl)
    end)

    local versionLabel = self:getUI("bg.setPanel.innerBg.versionLabel")
    versionLabel:setString("版本号：" .. GameStatic.version )

    if not OS_IS_WINDOWS then
        versionLabel:setString(versionLabel:getString() .. " (" .. GameStatic.walleVersion .. ")")
    end

    local btnList = {}
    btnList[#btnList+1] = {"问题反馈", 
    function () 
        local chatModel = self._modelMgr:getModel("ChatModel")
        local isPriOpen, tipDes = chatModel:isPirChatOpen()
        if isPriOpen == false then
            self._viewMgr:showTip(tipDes)
            return
        end
        self._viewMgr:showDialog("chat.ChatPrivateView", {oldUI = self, viewtType = "debug"}, true)     
    end}    
    if (not GameStatic.appleExamine) and (sdkMgr:isWX() or OS_IS_WINDOWS) then
        btnList[#btnList+1] = {"微信订阅", 
        function (sender) 
            SystemUtils.saveGlobalLocalData("setting_WXSubscriber", 0) 
            if sender.tip ~= nil then 
                sender.tip:removeFromParent()
                sender.tip = nil
            end
            local tabSet = self:getUI("bg.tab_set")
            if tabSet.tip ~= nil then 
                tabSet.tip:removeFromParent()
                tabSet.tip = nil
            end
            self._viewMgr:showDialog("main.WXSubscriberView", {}, true)         
        end, function(sender)
            -- 微信订阅增加红点逻辑   
            local showTip = SystemUtils.loadGlobalLocalData("setting_WXSubscriber") or 1
            if showTip == 1 then 
                local tip = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
                print('sender:getContentSize().wdith===========', sender:getContentSize().wdith)
                tip:setPosition(cc.p(sender:getContentSize().width, sender:getContentSize().height))
                tip:setAnchorPoint(cc.p(0.5, 0.5))
                sender:addChild(tip, 10)
                sender.tip = tip

            end
        end}   
    end
    if not GameStatic.appleExamine then
        btnList[#btnList+1] = {"联系客服", 
        function () 
            CustomServiceUtils.setting()  
        end}
    end
    btnList[#btnList+1] = {"游戏公告", 
    function () 
        ApiUtils.getNotice(1)
    end}    
    btnList[#btnList+1] = {"黑名单", 
    function () 
        local friendModel = self._modelMgr:getModel("FriendModel")
        local isFriOpen, tipDes = friendModel:isFriendOpen()
        if isFriOpen == false then
            self._viewMgr:showTip(tipDes)
            return
        end
        self._viewMgr:showDialog("friend.FriendBlackView", {}, true)        
    end}

    btnList[#btnList+1] = {"特权隐藏", 
    function () 
        self._viewMgr:showDialog("main.HideVipDialog", {}, true)        
    end}
    if IS_ANDROID_OUTSIDE_CHANNEL then
        btnList[#btnList+1] = {"兑换码", 
        function () 
            if sdkMgr:isQQ() == true then
                sdkMgr:loadUrl({url = GameStatic.CDK_qq_url})
                print(GameStatic.CDK_qq_url)
            elseif sdkMgr:isWX() == true then
                sdkMgr:loadUrl({url = GameStatic.CDK_wx_url})
                print(GameStatic.CDK_wx_url)
            end
            -- self._viewMgr:showDialog("main.DialogCodeExchangeView", {}, true)        
        end}
    end
    
    -- btnList[#btnList+1] = {"服务条款", 
    -- function () 
    --     sdkMgr:loadUrl({type = "1", url = GameStatic.serviceUrl})
    --     print(GameStatic.serviceUrl)
    -- end}
    -- btnList[#btnList+1] = {"隐私政策", 
    -- function () 
    --     sdkMgr:loadUrl({type = "1", url = GameStatic.privacyUrl})
    --     print(GameStatic.privacyUrl)
    -- end}
    
    local privacyBtn = self:getUI("bg.setPanel.innerBg.privacyBtn")
    privacyBtn:setScaleAnim(true)
    -- 安卓隐藏链接 17.11.21 by guojun
    if OS_IS_ANDROID then
        privacyBtn:setVisible(false)
    end
    self:registerClickEvent(self:getUI("bg.setPanel.innerBg.privacyBtn"), function ()
        sdkMgr:loadUrl({type = "1", url = GameStatic.privacyUrl})
        print(GameStatic.privacyUrl)
    end)
    local serverBtn = self:getUI("bg.setPanel.innerBg.serverBtn"):setScaleAnim(true)
    -- 安卓隐藏链接 17.11.21 by guojun
    if OS_IS_ANDROID then
        serverBtn:setVisible(false)
    end
    self:registerClickEvent(serverBtn, function ()
        sdkMgr:loadUrl({type = "1", url = GameStatic.serviceUrl})
        print(GameStatic.serviceUrl)
    end)

    local bg = self:getUI("bg.setPanel.innerBg")
    local headBg = self:getUI("bg.bgPanel.headBg")
    headBg:setOpacity(0)
    local filename = "globalButtonUI13_1_2.png"
    local x, y = 97, 225
    for i = 1, #btnList do
        local btn = ccui.Button:create(filename, filename, filename, 1)
        btn:setTitleFontName(UIUtils.ttfName)
        btn:setTitleColor(UIUtils.colorTable.ccUICommonBtnColor1)
        btn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine2,1)
        btn:setTitleFontSize(22) 
        bg:addChild(btn)
        btn:setPosition(x, y)
        x = x + 178
        if x > 650 then
            x = 97
            y = y - 67
        end
        btn:setTitleText(btnList[i][1])
        self:registerClickEvent(btn, function (sender)
            btnList[i][2](sender)
        end)
        if btnList[i][3] ~= nil then 
            btnList[i][3](btn)
        end
    end

    local tabs = {}
    table.insert(tabs,self:getUI("bg.tab_info"))
    table.insert(tabs,self:getUI("bg.tab_set"))

    -- 微信订阅增加红点逻辑   
    local showTip = SystemUtils.loadGlobalLocalData("setting_WXSubscriber") or 1
    print("showTip==============", showTip)
    if not GameStatic.appleExamine then
        if showTip == 1 and (sdkMgr:isWX() or OS_IS_WINDOWS) then
            local tabSet = self:getUI("bg.tab_set")
            local tip = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
            tip:setPosition(cc.p(20, tabSet:getContentSize().height - 10))
            tip:setAnchorPoint(cc.p(0.5, 0.5))
            tabSet:addChild(tip, 10)
            tabSet.tip = tip
        end
    end

    local function touchTab(sender)
        for k,v in pairs(tabs) do
            if v ~= sender then
                v:setEnabled(true)
                v:setBright(true)
                v:setTitleFontName(UIUtils.ttfName )
                local title = v:getTitleRenderer()
                title:setColor(UIUtils.colorTable.ccUITabColor1)
                -- title:setPositionX(65)
                -- title:enableOutline(cc.c4b(62, 20, 8, 255),1)
                title:disableEffect()
            end
        end

         if self._preBtn then
            UIUtils:tabChangeAnim(self._preBtn,nil,true)
        end
        
        -- text:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
        -- 按钮动画
        self._preBtn = sender
        sender:stopAllActions()
        sender:setZOrder(99)
        UIUtils:tabChangeAnim(sender,function( )
            sender:setEnabled(false)
            sender:setBright(false)
            local title = sender:getTitleRenderer()
            -- title:setPositionX(75)
            title:setColor(UIUtils.colorTable.ccUITabColor2)
            -- title:enableOutline(cc.c4b(70, 65, 85, 255),2)
        end)
        if self._idx == 1 then
            self:checkExpExchangeStatus()
        end
       
    end
    ScheduleMgr:delayCall(0, self, function()
        touchTab(tabs[self._idx])
    end)

    self._btnQQAward = self:getUI("bg.bgPanel.btnQQTequan")
    self._btnQQAward:setPosition(self._btnQQAward:getPositionX() + 20, self._btnQQAward:getPositionY() - 17)

	self._btnQQTequan = ccui.ImageView:create("tencentIcon_qqTequan.png", 1)
    self._btnQQTequan:setPosition(652, 353)
    self._btnQQTequan:setScaleAnim(true)
    self._btnQQTequan:setVisible(false)
	self._bgPanel:addChild(self._btnQQTequan, 99)

    self._btnWXTequan = self:getUI("bg.bgPanel.btnWXTequan")
    self._btnWXTequan:setPosition(self._btnWXTequan:getPositionX() + 20, self._btnWXTequan:getPositionY() - 15)

    self:registerClickEvent(self._btnQQAward,function( sender )
        sdkMgr:loadUrl({url = self._modelMgr:getModel("TencentPrivilegeModel"):getPrivilegeUrl()})
    end)

    self:registerClickEvent(self._btnQQTequan,function( sender )
        self._viewMgr:showDialog("tencentprivilege.TencentPrivilegeView")
    end)

    self:registerClickEvent(self._btnWXTequan,function( sender )
        self._viewMgr:showDialog("tencentprivilege.TencentPrivilegeView")
    end)

    --经验兑换
    local expExchange = self:getUI("bg.expExchange")
    expExchange:setVisible(false)
    self:registerClickEvent(expExchange,function( sender )
        self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = "exp"}, true, {}, function(result)
            dump(result,"aaaa",10)
            self._viewMgr:showDialog("shop.ExpShopView",{callBack = function()
                self:checkExpExchangeStatus()
            end},true)
        end)
    end)
    local exp_qipao = self:getUI("bg.exp_qipao")
    exp_qipao:setVisible(false)

    -- 增加点击动画
    UIUtils:setTabChangeAnimEnable(self:getUI("bg.tab_info"),80,function( )
        -- 切页签音效     
        audioMgr:playSound("Tab")
        touchTab(self:getUI("bg.tab_info"))        

        -- self._tabName = "damage"
        -- self:reflashUI()
        self._bgPanel:setVisible(true)
        self._setPanel:setVisible(false)

        self:addShareBtn(true)
        self:checkExpExchangeStatus()
    end)
    UIUtils:setTabChangeAnimEnable(self:getUI("bg.tab_set"),80,function( )
        -- 切页签音效     
        audioMgr:playSound("Tab")
        touchTab(self:getUI("bg.tab_set"))
        -- self._tabName = "hurt"
        -- self:reflashUI()
        self._setPanel:setVisible(true)
        self._bgPanel:setVisible(false)
        self:addShareBtn(false)
        expExchange:setVisible(false)
        exp_qipao:setVisible(false)
    end)

    self:initInfoBg()
    self:initSetBg()

    self:reflashTencentBtn()
    
    self:listenReflash("UserModel", self.reflashUI)
    self:listenReflash("TreasureModel", self.reflashUI)
    self:listenReflash("TeamModel", self.reflashUI)
    self:listenReflash("TreasureModel", self.reflashUI)
    self:listenReflash("PokedexModel", self.reflashUI)
    self:listenReflash("TencentPrivilegeModel", self.reflashTencentBtn)
end

--[[
    显示经验兑换
]]
function UserDialog:checkExpExchangeStatus()
    
    local expExchange = self:getUI("bg.expExchange")
    expExchange:setVisible(false)
    local exp_qipao = self:getUI("bg.exp_qipao")
    exp_qipao:setVisible(false)
    if self._userModel:isShowExpExchangeBtn() then
        expExchange:setVisible(true)
    end
    if self._userModel:isShowExpExchangeRedPoint() then
        exp_qipao:setVisible(true)
        exp_qipao:stopAllActions()
        local posX = exp_qipao:getPositionX()
        local posY = exp_qipao:getPositionY()
        exp_qipao:runAction(cc.RepeatForever:create(
            cc.Sequence:create(
                cc.MoveTo:create(0.5, cc.p(posX+3, posY)),
                cc.MoveTo:create(0.5, cc.p(posX-3, posY))
                )))
    else
        exp_qipao:setVisible(false)
    end
end

-- function UserDialog:getAsyncRes()
--     return  
--         { 
--             {"asset/ui/privileges.plist", "asset/ui/privileges.png"},
--         }
-- end

--by wangyan 分享
function UserDialog:addShareBtn(isShow)
    if self._shareNode == nil then
        self._shareNode = require("game.view.share.GlobalShareBtnNode").new({mType = "ShareMainModule"})
        self._shareNode:setPosition(200, -34)
        self._shareNode:setScale(0.75)
        self._shareNode:setCascadeOpacityEnabled(true, true)
        self:getUI("bg.titleBg"):addChild(self._shareNode, 10)
        self._shareNode:registerClick(function()
            return {moduleName = "ShareMainModule"}
            end)
    end

    self._shareNode:setVisible(isShow)
end

function UserDialog:initInfoBg( )
    -- body
end

function UserDialog:initSetBg( )
    local function detectInStep(x,width,step)
        local base = width/step
        local nowStep = cc.clampf(math.floor(x/base),1,step)
        -- print("nowStep,",nowStep*(1/(base-1)),nowStep,1/(base-1),base)
        return (nowStep-1)*(base+1.8),(nowStep-1)*(1/(step-1))
    end
    local selOffset = 50
    -- local offsetX = 42    --空白部分矫正值
    self._musicSel = self:getUI("bg.setPanel.musicSel")
    local sel = self._musicSel:getChildByFullName("sel")
    local musicSelW = self._musicSel:getContentSize().width - 73
    local initPos = (musicSelW/6+1.8)*(SystemUtils.loadGlobalLocalData("musicVolume") or 1)+selOffset
    sel:setPositionX(initPos)
    self:registerTouchEvent(self._musicSel,
        function( sender,x,y )
            local pos = self._musicSel:convertToNodeSpace(cc.p(x,y))
            x = pos.x 
            local posx,volume = detectInStep(x,musicSelW,6)

            sel:setPositionX(posx+selOffset)
            
            audioMgr:adjustMusicVolume(volume * 5)
        end,
        function( sender,x,y )
            local pos = self._musicSel:convertToNodeSpace(cc.p(x,y))
            x = pos.x
            local posx,volume = detectInStep(x,musicSelW,6)
            sel:setPositionX(posx+selOffset)
            
            audioMgr:adjustMusicVolume(volume * 5)
        end,
        function( sender,x,y )
            local pos = self._musicSel:convertToNodeSpace(cc.p(x,y))
            x = pos.x
            local posx,volume = detectInStep(x,musicSelW,6)
            sel:setPositionX(posx+selOffset)
            SystemUtils.saveGlobalLocalData("musicVolume", volume * 5)
        end,
        function( sender,x,y )
            local pos = self._musicSel:convertToNodeSpace(cc.p(x,y))
            x = pos.x
            local posx,volume = detectInStep(x,musicSelW,6)
            sel:setPositionX(posx+selOffset)
            SystemUtils.saveGlobalLocalData("musicVolume", volume * 5)
        end
    )

    self._effectSel = self:getUI("bg.setPanel.effectSel")
    local sel = self._effectSel:getChildByFullName("sel")
    local effectSelW = self._effectSel:getContentSize().width - 73
    local initPos = (effectSelW/6+1.8)*(SystemUtils.loadGlobalLocalData("soundVolume") or 1)+selOffset --+ offsetX 
    sel:setPositionX(initPos)
    self:registerTouchEvent(self._effectSel,
        function( sender,x,y )
            print("x",x)
            local pos = self._effectSel:convertToNodeSpace(cc.p(x,y))
            x = pos.x
            local posx,volume = detectInStep(x,effectSelW,6)
            sel:setPositionX(posx+selOffset)
            
            audioMgr:adjustSoundVolume(volume * 5)
        end,
        function( sender,x,y )
            local pos = self._effectSel:convertToNodeSpace(cc.p(x,y))
            x = pos.x
            local posx,volume = detectInStep(x,effectSelW,6)
            sel:setPositionX(posx+selOffset)
            
            audioMgr:adjustSoundVolume(volume * 5)
        end,
        function( sender,x,y )
            local pos = self._effectSel:convertToNodeSpace(cc.p(x,y))
            x = pos.x
            local posx,volume = detectInStep(x,effectSelW,6)
            sel:setPositionX(posx+selOffset)
            SystemUtils.saveGlobalLocalData("soundVolume", volume * 5)
        end,
        function( sender,x,y )
            local pos = self._effectSel:convertToNodeSpace(cc.p(x,y))
            x = pos.x
            local posx,volume = detectInStep(x,effectSelW,6)
            sel:setPositionX(posx+selOffset)
            SystemUtils.saveGlobalLocalData("soundVolume", volume * 5)
        end
    )
end

function UserDialog:initFightData()    
    --战斗力
    local userModel = self._modelMgr:getModel("UserModel")
    local userLv = userModel:getData().lvl or userModel:getData().level or 1
    local standardTable = tab:Standard(tonumber(userLv)) 
    -- dump(standardTable,"standardTable")
    local fightScore = userModel:getUserScore()

    local fightData = {
        [1] = {name = "team",titleTxt="兵团",iconPic="xgn_bingtuan.png",fightScore = fightScore.team or 0,percent = 0,openTag = "Team",toView="team.TeamListView"},--兵团
        [2] = {name = "hero",titleTxt="英雄",iconPic="xgn_yingxiong.png",fightScore = fightScore.hero or 0,percent = 0,openTag = "HeroOpen",toView="hero.HeroView"},--英雄
        [3] = {name = "pokedex",titleTxt="图鉴",iconPic="xgn_tujian.png",fightScore = fightScore.pokedex or 0,percent = 0,openTag = "Pokedex",toView="pokedex.PokedexView"},--图鉴
        [4] = {name = "treasure",titleTxt="宝物",iconPic="xgn_baowu.png",fightScore = fightScore.treasure or 0,percent = 0,openTag = "Treasure",toView="treasure.TreasureView"},--宝物
        [5] = {name = "magic",titleTxt="魔法行会",iconPic="xgn_mofa.png",fightScore = fightScore.talent or 0,percent = 0,openTag = "Talent",toView="talent.TalentView"}, --学院
        [6] = {name = "siegeWeapon",titleTxt="器械",iconPic="xgn_zhanzhengqixie.png",fightScore = fightScore.siegeWeapon or 0,percent = 0,specialIndex = "SiegeWeapon",toView="weapons.WeaponsView"}, --器械
    }
    for i=1,#fightData do
        --兵团
        if standardTable[fightData[i].name] and tonumber(standardTable[fightData[i].name]) > 0 then
            fightData[i].percent = tonumber(fightData[i].fightScore) / tonumber(standardTable[fightData[i].name])
            fightData[i].percent = math.floor(fightData[i].percent * 100)
        else
            fightData[i].percent = 0
        end 
    end
    --[[
    --兵团
    if standardTable.team and tonumber(standardTable.team) > 0 then
        fightData[1].percent = tonumber(fightData[1].fightScore) / tonumber(standardTable.team)
        fightData[1].percent = math.floor(fightData[1].percent * 100)
    else
        fightData[1].percent = 0
    end 
    --英雄
    if standardTable.hero and tonumber(standardTable.hero) > 0 then
        fightData[2].percent = tonumber(fightData[2].fightScore) / tonumber(standardTable.hero)
        fightData[2].percent = math.floor(fightData[2].percent * 100)
    else
        fightData[2].percent = 0
    end  
    --图鉴
    if standardTable.pokedex and tonumber(standardTable.pokedex) > 0 then
        fightData[3].percent = tonumber(fightData[3].fightScore) / tonumber(standardTable.pokedex)
        fightData[3].percent = math.floor(fightData[3].percent * 100)
    else
        fightData[3].percent = 0
    end 
    --宝物
    if standardTable.treasure and tonumber(standardTable.treasure) > 0 then
        fightData[4].percent = tonumber(fightData[4].fightScore) / tonumber(standardTable.treasure)
        fightData[4].percent = math.floor(fightData[4].percent * 100)
    else
        fightData[4].percent = 0
    end  
    --学院
    if standardTable.magic and tonumber(standardTable.magic) > 0 then
        fightData[5].percent = tonumber(fightData[5].fightScore) / tonumber(standardTable.magic)
        fightData[5].percent = math.floor(fightData[5].percent * 100)
    else
        fightData[5].percent = 0
    end  
    ]]
    self._fightData = fightData    

end

--初始化战斗力面板 
function UserDialog:initFightPanel()
    -- self._scrollView   滚动层
    local itemH = 200
    -- local height = #self._fightData * itemH
    local itemW = 140
    local width = 0
    local num = #self._fightData
    self._scrollView:removeAllChildren()
    -- self._scrollView:setClippingType(1)
    self._scrollView:setBounceEnabled(true)
    self._scrollView:setInnerContainerSize(cc.size(#self._fightData * itemW,self._scrollView:getContentSize().height))
    self._scrollView:setClippingEnabled(true)    --是否裁剪
    for i = 1,#self._fightData do
        local v = self._fightData[i]
        local item = self:createItem(i,v)
        -- item:setAnchorPoint(cc.p(0,0))
        item:setPosition(width+itemW*0.5, 3+itemH*0.5)       
        self._scrollView:addChild(item)
        -- height = height - itemH 
        width = width + itemW       
    end

end

function UserDialog:createItem(tag,itemData)
    local isOpen = false
    local specialIndex = nil
    if itemData.openTag then --and sysName ~= "" then
        isOpen,_ = SystemUtils["enable".. itemData.openTag]()
        --self._viewMgr:showTip(tab.systemOpen[itemData.openTag][1] .. "级开启") 
    elseif itemData.specialIndex then 
        specialIndex = itemData.specialIndex        
    end
    local widgetH = 194
    local widgetW = 140
    local widget = ccui.Layout:create()--ccui.Widget:create()
    widget:setContentSize(widgetW,widgetH)
    widget:setName("item" .. tag)
    widget:setAnchorPoint(cc.p(0.5, 0.5))
    -- widget:setBackGroundColorType(1)
    -- widget:setBackGroundColor(cc.c3b(100, 100, 0))

    --背景
    local itemBg = ccui.ImageView:create()
    itemBg:loadTexture("globalPanelUI7_cellBg1.png",1)
    itemBg:setScale9Enabled(true)
    itemBg:setCapInsets(cc.rect(41,41,1,1))
    itemBg:setContentSize(widgetW+7,widgetH)
    itemBg:setAnchorPoint(cc.p(0,0))
    itemBg:setPosition(-4,-7)
    widget:addChild(itemBg)

    --[[
    --战斗力提示
    local fightTxt = ccui.Text:create()
    fightTxt:setFontName(UIUtils.ttfName)
    fightTxt:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- fightTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    fightTxt:setString("战斗力：")
    fightTxt:setFontSize(26)
    fightTxt:setAnchorPoint(cc.p(0,0.5))
    fightTxt:setPosition(15, 95)
    widget:addChild(fightTxt,1)

    --战斗力value
    local fightValue = ccui.Text:create()
    fightValue:setFontName(UIUtils.ttfName)
    fightValue:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- fightValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    fightValue:setString(itemData.fightScore or 0)
    fightValue:setFontSize(26)
    fightValue:setAnchorPoint(cc.p(0,0.5))
    fightValue:setPosition(fightTxt:getPositionX()+fightTxt:getContentSize().width+3, fightTxt:getPositionY())
    widget:addChild(fightValue,1)

    --进度提示
    local proDes = ccui.Text:create()
    proDes:setFontName(UIUtils.ttfName)
    proDes:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    proDes:setString("提升进度:")
    proDes:setFontSize(26)
    proDes:setAnchorPoint(cc.p(0,0.5))
    proDes:setPosition(15, 50)
    widget:addChild(proDes,1)
    --]]

    --图标背景
    local fightIconBg = ccui.ImageView:create()
    fightIconBg:loadTexture("globalPanelUI12_innerbg2.png",1)
    fightIconBg:setScale9Enabled(true)
    fightIconBg:setCapInsets(cc.rect(25,25,1,1))
    fightIconBg:setContentSize(108,90)
    fightIconBg:setAnchorPoint(cc.p(0.5,0.5))
    fightIconBg:setPosition(widgetW*0.5,widgetH - 94*0.5 - 25)
    fightIconBg:setScaleAnim(true)
    widget:addChild(fightIconBg)
    --图标
    local fightIcon = ccui.ImageView:create()
    fightIcon:loadTexture(itemData.iconPic or "",1)
    -- fightIcon:setAnchorPoint(cc.p(1,1))
    fightIcon:setScale(0.9)
    fightIcon:setPosition(fightIconBg:getContentSize().width*0.5,fightIconBg:getContentSize().height*0.5)
    fightIconBg:addChild(fightIcon,1)
    -- self:registerClickEvent(fightIconBg, function( )
    --     if not isOpen then
    --         self._viewMgr:showTip(tab.systemOpen[itemData.openTag][1] .. "级开启") 
    --     else
    --         --跳转到View
    --         self._viewMgr:showView(itemData.toView)
    --     end
    -- end)
    local iconTxt = ccui.Text:create()
    iconTxt:setFontName(UIUtils.ttfName)
    iconTxt:setColor(UIUtils.colorTable.ccUIBaseColor1)
    iconTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    iconTxt:setString(itemData.titleTxt)
    iconTxt:setFontSize(22)
    iconTxt:setPosition(fightIconBg:getContentSize().width*0.5, 15)
    fightIconBg:addChild(iconTxt,1)

    -- 进度星星显示    
    local percent = itemData.percent > 100 and 100 or itemData.percent
    local starW = 23
    local percentNum = 20
    for i=1,5 do
        local star = ccui.ImageView:create()
        star:loadTexture("globalImageUI6_star2.png",1)
        star:setScale(0.5)
        star:setAnchorPoint(0.5,0.5)
        local perNum = i*percentNum

        if percent >= perNum then
            star:loadTexture("globalImageUI6_star1.png",1)
        end
        
        star:setPosition((i-1)*starW + 25,60)
        widget:addChild(star,2)
    end

    -- 前往图
    local goViewImg = ccui.ImageView:create()
    goViewImg:loadTexture("userDialog_goView_img.png",1)
    goViewImg:setAnchorPoint(cc.p(0.5,0.5))
    goViewImg:setPosition(widgetW*0.5,30)
    -- goViewImg:setScaleAnim(true)
    widget:addChild(goViewImg)

    widget:setScaleAnim(true)
    self:registerClickEvent(widget, function( )
        if specialIndex then
            if self["jumpToView" .. specialIndex] then
                self["jumpToView" .. specialIndex](self)
            else
                print("=======no jump func===========",specialIndex)
            end
        elseif not isOpen then
            self._viewMgr:showTip(tab.systemOpen[itemData.openTag][1] .. "级开启") 
        else
            --跳转到View
            self._viewMgr:showView(itemData.toView)
        end
    end)

    -- if true then return widget end 
    --箭头
    -- local arrow = ccui.ImageView:create()
    -- arrow:loadTexture("globalImageUI5_upArrow.png",1)
    -- arrow:setPosition(fightIcon:getContentSize().width-15,30)
    -- fightIcon:addChild(arrow,1)      
    -- arrow:setVisible(false) 
    -- local moveUp = cc.MoveBy:create(0.5, cc.p(0, 3))
    -- local moveDown = cc.MoveBy:create(0.5, cc.p(0, -3))
    -- local seq = cc.Sequence:create(moveUp, moveDown)
    -- local repeateMove = cc.RepeatForever:create(seq)
    -- arrow:runAction(repeateMove)
    --[[
    --进度条背景
    local proBg = ccui.ImageView:create()
    proBg:loadTexture("expprogressbg_main.png",1)
    -- proBg:setScale9Enabled(true)
    -- proBg:setCapInsets(cc.rect(5,10,1,1))
    -- proBg:setContentSize(150,23)
    proBg:setScaleX(0.73)
    proBg:setScaleY(2)
    proBg:setAnchorPoint(cc.p(0,0.5))
    proBg:setPosition(proDes:getPositionX()+proDes:getContentSize().width + 2,48)
    widget:addChild(proBg)

    --进度条
    local percent = itemData.percent > 100 and 100 or itemData.percent
    local sp
    if percent < 25 then 
        -- 百分比小于25%则显示提升箭头
        -- arrow:setVisible(true)
        sp = cc.Sprite:createWithSpriteFrameName("userDialog_progressR.png")
    elseif percent < 75 then
        sp = cc.Sprite:createWithSpriteFrameName("userDialog_progressY.png")
    else
        sp = cc.Sprite:createWithSpriteFrameName("userDialog_progressG.png")
    end 
    local progress = cc.ProgressTimer:create(sp)
    progress:setType(cc.PROGRESS_TIMER_TYPE_BAR) --类型为条形进度条
    progress:setMidpoint(cc.p(0, 0.5))     --设置进度条的起始点,(0,y)最左边,(1,y)最右边,(x,1)最上面,(x,0)最下面  
    progress:setBarChangeRate(cc.p(1, 0))   --设置进度条动画方向的,(1,0)横向,(0,1)纵向
    progress:setPercentage(percent)
    progress:setPosition(203, 48)
    widget:addChild(progress,2)

    --进度value
    local proValue = ccui.Text:create()
    proValue:setFontName(UIUtils.ttfName)
    proValue:setColor(UIUtils.colorTable.ccUIBaseColor1)
    -- proValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    proValue:setString(percent .. "%")
    proValue:setFontSize(20)
    proValue:setAnchorPoint(cc.p(1,0.5))
    proValue:setPosition(276, 48)
    widget:addChild(proValue,5)

    if not isOpen then
        -- score = 0
        fightValue:setString(0)
        -- 上升箭头隐藏
        -- arrow:setVisible(false)
    end
    --]]
    return widget
end

function UserDialog:reflashUI(data)
    local str1 = self._userInfo.name
    if str1 == "" then
        local userModel = self._modelMgr:getModel("UserModel")
        str1 = userModel:getUID() .. "/" .. userModel:getUSID()
    end 
    self._name:setString(str1)
    
    local tencetTp = nil

    if not GameStatic.appleExamine and self._modelMgr:getModel("TencentPrivilegeModel"):isOpenPrivilege() then
        if sdkMgr:isWX() then
            tencetTp = self._modelMgr:getModel("TencentPrivilegeModel"):getTencentTeQuan()
        elseif sdkMgr:isQQ() then
            tencetTp = self._modelMgr:getModel("TencentPrivilegeModel"):getQQVip()
        end
    end

    if not self._avatar then 
        self._avatar = IconUtils:createHeadIconById({avatar = self._userInfo.avatar,level = self._userInfo.lvl or 0,tp = 4, isSelf = true, tencetTp = tencetTp})   --,tp = 2
        self._headIcon:addChild(self._avatar)
    else
        IconUtils:updateHeadIconByView(self._avatar,{avatar = self._userInfo.avatar,self._userInfo.lvl or 0,tp = 4, isSelf = true, tencetTp = tencetTp})   --level = ,tp = 2
    end
    -- if self._avatar then
    --     self._avatar:removeFromParent()
    -- end
    -- local art = tab:RoleAvatar(self._userInfo.avatar).icon or 1101
    -- self._avatar = cc.Sprite:createWithSpriteFrameName("".. art .. ".jpg")
    -- self._avatar:setAnchorPoint(cc.p(0,0))
    -- self._avatar:setPosition(5, 5)
    -- self._headIcon:addChild(self._avatar)
    
    local nowExp = self._userInfo.exp
    local nextExp = tab:UserLevel(self._userInfo.lvl).exp or "Max"
    local str = nowExp .. "/" .. nextExp --string.format("%d %d", nowExp/nextExp)    
    self._exp:setString( str )
    -- self._exp:enableOutline(cc.c4b(0,0,0,255),1.5)
    if tonumber(nextExp) then
        self._expProBar:setPercent(nowExp/nextExp*100)
         self._exp:setString( str )
    else
        self._expProBar:setPercent(100)
        self._exp:setString( "Max" )
    end
    if self._userModel:isMaxLevel() then
        self._expProBar:setPercent(100)
        self._exp:setString( "Max" )
    end
    self:updateGuildInfo()

    -- 用户信息
    local privili = self:getUI("bg.bgPanel.desBg1.privili")
    local priviliImg = self:getUI("bg.bgPanel.desBg1.priviliImg")
    local peerage = self._modelMgr:getModel("PrivilegesModel"):getPeerage()
    if peerage > 0 then
        privili:setString(lang(tab:Peerage(peerage).name) or "")
        priviliImg:loadTexture("userDialog_peerageRes_" .. peerage .. ".png",1)
        priviliImg:setPositionX(privili:getPositionX()+privili:getContentSize().width+5)
    else
        priviliImg:setVisible(false)
        privili:setString("新手")
    end

    local level = self:getUI("bg.bgPanel.level")
    level:setString("Lv." .. self._userInfo.lvl)

    local changeName = self:getUI("bg.bgPanel.changeName")
    local vipLvl = self._modelMgr:getModel("VipModel"):getData().level or 0
    if self._vipLab then
        self._vipLab:removeFromParent()
    end
    self._vipLab = cc.Label:createWithBMFont(UIUtils.bmfName_vip, "V" .. vipLvl)
    self._vipLab:setAnchorPoint(cc.p(0,0.5))
    self._vipLab:setPosition(changeName:getPositionX()+30,changeName:getPositionY())
    self._bgPanel:addChild(self._vipLab, 2)

    local score = self:getUI("bg.bgPanel.fightPanel.score")
    score:setScale(0.5)
    score:setFntFile(UIUtils.bmfName_zhandouli)
    local formationModel = self._modelMgr:getModel("FormationModel")
    local fightCapacity = formationModel:getCurrentFightScoreByType(formationModel.kFormationTypeCommon)
    score:setString(fightCapacity or "0")
    local scoreDes = self:getUI("bg.bgPanel.fightPanel.scoreDes")
    scoreDes:setVisible(false)
    
    -- local teamNum = self:getUI("bg.bgPanel.desBg1.teamNum")
    -- teamNum:setString(self._modelMgr:getModel("UserModel"):getData().formationTeamNum or "")
    
    local id = self:getUI("bg.bgPanel.desBg1.id")
    id:setString(self._modelMgr:getModel("UserModel"):getUSID() or "")
    
    local teamLevel = self:getUI("bg.bgPanel.desBg1.teamLevel")
    -- teamLevel:setString(self._modelMgr:getModel("UserModel"):getData().lvl or "")
    
    local slogan = self:getUI("bg.bgPanel.desBg2.slogan")
    slogan:setString("")

    local arenaD = self._modelMgr:getModel("ArenaModel"):getArena()
    
    if self._modelMgr:getModel("UserModel"):getData() then
        if self._modelMgr:getModel("UserModel"):getData().msg == nil or self._modelMgr:getModel("UserModel"):getData().msg == "" then
            slogan:setString("这家伙很懒，什么都没留下")
        else
            slogan:setString(self._modelMgr:getModel("UserModel"):getData().msg or "")
        end
    else
        slogan:setString("暂未开放")
    end
    -- 刷新战斗力
    self:initFightData()
    self:initFightPanel()
end
function UserDialog:updateGuildInfo()
    local userData = self._modelMgr:getModel("UserModel"):getData()
    if not userData.guildId or userData.guildId == 0 then
        self._union:setString("未加入联盟")
        self._guildExitBtn:setVisible(false)
    else
        self._guildExitBtn:setVisible(true)
        self._union:setString(self._modelMgr:getModel("UserModel"):getData().guildName)
        --更新按钮位置
        local btnW = self._guildExitBtn:getContentSize().width * self._guildExitBtn:getScale()
        local posX = self._union:getPositionX()+self._union:getContentSize().width+btnW*0.5+10
        posX = posX > 230 and posX or 230
        self._guildExitBtn:setPosition(posX,self._union:getPositionY()+3)
    
    end
    
end

function UserDialog:reflashTencentBtn()
    local tencentModel = self._modelMgr:getModel("TencentPrivilegeModel")

    if not GameStatic.appleExamine and tencentModel:isOpenPrivilege() then
        self._btnQQAward:setVisible(sdkMgr:isQQ() == true)
        self._btnQQTequan:setVisible(sdkMgr:isQQ() == true)
        self._btnQQTequan:setSaturation(tencentModel:getTencentTeQuan() == tencentModel.QQ_GAME_CENTER and 0 or -100)
        self._btnWXTequan:setVisible(tencentModel:getTencentTeQuan() == tencentModel.WX_GAME_CENTER)
    end 
end

function UserDialog:jumpToViewSiegeWeapon()
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

function UserDialog:getAsyncRes()
    return 
        {
        }
end

function UserDialog.dtor()
    httpManager = nil
end

return UserDialog

-- self._outTime = self:getUI("bg.bgPanel.detail.outTime")
    -- self._physicalTime = self:getUI("bg.bgPanel.detail.physicalTime")
-- 更新体力
    -- local nextTime = self:getUI("bg.bgPanel.detail.outTime")
    -- local fullTime = self:getUI("bg.bgPanel.detail.physicalTime")
    -- local privileges = self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_7) or 0
    -- local privilegeBuff = 0
    -- if privileges then
    --     privilegeBuff = privileges or 0
    -- end
    -- local maxPhyNum = (tab:Setting("G_INITIAL_PHYSCAL_MAX").value or 0)+privilegeBuff
    -- local nowNum = self._userInfo.physcal
    -- local physcalAdd = tab:Setting("G_PHYSCAL_ADD").value*60
    -- if not self._lastTimeSch and maxPhyNum - nowNum > 0 then
    --     self._lastTimeSch = ScheduleMgr:regSchedule(1000,self,function ( )
    --         local upPhyTime = self._userInfo.upPhyTime
    --         local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()            
    --         local lastTime = physcalAdd - (nowTime-upPhyTime)%physcalAdd
    --         nextTime:setString(string.format("体力恢复：%02d:%02d:%02d",math.floor(lastTime/3600),math.floor(lastTime/60%60),lastTime%60))
    --         local lastFull = (maxPhyNum-self._userInfo.physcal)*physcalAdd+lastTime
    --         fullTime:setString(string.format("全部恢复：%02d:%02d:%02d",math.floor(lastFull/3600),math.floor(lastFull/60%60),lastFull%60))
    --     end)
    -- else
    --     str = "体力恢复：" .. "00:00:00"
    --     nextTime:setString(str)
    --     str = "全部恢复：" .. "00:00:00"
    --     fullTime:setString(str)
    -- end

