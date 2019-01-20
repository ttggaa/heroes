--[[
    Filename:    ShopView.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-10-09 15:34:39
    Description: File description
--]]

local titleNames = {
    "神秘", --1
    "竞技", --2
    "战役", --3
    "宝物", --4
    "联盟", --5
    "冠军", --6
    "位面", --7
    "征战", --8
    "王国", --9
    "跨服", --10
    "荣耀", --11
}
local leftTitleNames = {
    "神秘",
    "竞技",
    "战役",
    "宝物",
    "联盟",
    "冠军",
    "位面",
    "征战",
    "王国",
    "跨服",
    "荣耀",
}
local shortTitleNames = {
    "神秘",
    "竞技",
    "战役",
    "宝物",
    "联盟",
    "冠军",
    "位面",
    "征战",
    "王国",
    "跨服",
    "荣耀",
}
-- local titleImgs = {
--     "globalTitleUI_shop1.png",
--     "globalTitleUI_shopArena.png",
--     "globalTitleUI_shopFar.png",
--     "globalTitleUI_shopTreasure.png",
--     "globalTitleUI_shopGuild.png",
-- }
local tabSys = {
    "MysteryShop",
    "Arena",
    "CrusadeShop",
    "TreasureShop",
    "GuildShop",
    "LeagueShop",
    "ElementShop",
    "CityBattle",
    "CrossPK",
    "CrossGodWar",
    "CrossArena",   --"honorArena"
}

local tabImg = {
    selected = "globalBtnUI4_page1_p.png",
    normal = "globalBtnUI4_page1_n.png",
    disabled = "globalBtnUI4_page1_d.png",
}
local shopIdx = {
    "mystery",
    "arena",
    "crusade",
    "treasure",
    "guild",
    "league",
    "element",
    "citybattle",
    "cp",
    "crossFight",
    "honorArena",
}

local shopTableIdx = {
    "shopAward",
    "shopArena",
    "shopCrusade",
    "shopTreasure",
    "shopGuild",
    "shopLeague",
    "shopElement",
    "shopCrossFight",  ---不知道做什么
    "shopCrossFight",  ---不知道做什么
    "shopCrossFight",  --跨服诸神使用
    "honorArenaShop",  --荣耀竞技场
}
-- 是否需要创建特殊layer
local tabFunc = {
    [6] = {
        layerName="league.LeagueShopView",
        specialFunc = "detectLeagueOpen",   -- specialFunc单独请求积分联赛数据
        shopReflashFunc="reflashShopInfo",
        userReflashFunc="reflashShopInfo",
        otherReflashFunc = "reflashShopInfo",
    }, 
    [8] = {
        layerName="citybattle.CityBattleShopView", 
        shopReflashFunc="reflashShopInfo",
        userReflashFunc="updateShopItem",
    },
    [9] = { 
        layerName="cross.CrossShopView",
        shopReflashFunc="reflashShopGoodsData",
        userReflashFunc="reflashShopUserData",
    }
}
local tabNum = 11
-- local tabNames = {"bg.mainBg.smBtn","bg.mainBg.jjBtn","bg.mainBg.yzBtn","bg.mainBg.bwBtn"} cocostudio里的按钮
-- listenModel ....
local ShopView = class("ShopView",BaseView)

function ShopView:ctor(param)
    param = param or {}
    self.super.ctor(self)
    self.initAnimType = 3
    self._idx = param.idx or 1 -- 暂时默认进神秘商店
    self._showDialogTreasure = param.showDialogTreasure
    if not param.idx then
        self._noInitIdx = true
    end
    self._items = {}   -- 缓存节点，不移除商店格子
    self._grids = {}
end

function ShopView:getAsyncRes()
    return 
        {
            {"asset/ui/shop.plist", "asset/ui/shop.png"},
            {"asset/anim/shoprefreshanimimage.plist", "asset/anim/shoprefreshanimimage.png"}
        }
end

function ShopView:getBgName(  )
    return "bg_007.jpg"
end

-- 初始化UI后会调用, 有需要请覆盖
function ShopView:onInit()
    audioMgr:playSound("bar")
    -- layer管理
    self._layerTb = {}
    -- 通用动态背景
    self:addAnimBg()
    self._mainBg = self:getUI("bg.mainBg")
    self._scrollView = self:getUI("bg.mainBg.scrollView")
    self.scrollViewW = self._scrollView:getContentSize().width
    self.scrollViewH = self._scrollView:getContentSize().height
    self._leftArrow = self:getUI("bg.mainBg.leftArrow")
    self._rightArrow = self:getUI("bg.mainBg.rightArrow")
    self._downArrow = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    self._downArrow:setPosition(self._mainBg:getContentSize().width*0.5,90)
    self._downArrow:setRotation(90)
    self._downArrow:setVisible(false)
    self._mainBg:addChild(self._downArrow, 1)
    self._scrollView:addEventListener(function(sender, eventType)
        if eventType == 1 then
            self._downArrow:setVisible(false)
        elseif eventType == 2 then
            -- event.name = "SCROLL_TO_LEFT"
            self:showArrow("right")
        elseif eventType == 3 then
            -- event.name = "SCROLL_TO_RIGHT"
            self:showArrow("left")
            
        elseif eventType == 4 then
            if self._goodData and table.getn(self._goodData) > 8 then           
                self._downArrow:setVisible(true)
            end
            self:showArrow()-- 滑动中            
        end
    end)
    self:registerClickEvent(self._leftArrow, function( )
    end)
    self:registerClickEvent(self._rightArrow, function( )
    end)

    self._refreshBtn = self:getUI("bg.mainBg.backTexture.refreshBtn")
    -- self._refreshBtn:setScale(0.9)
    -- self._refreshBtn:setTitleFontSize(22)
    -- self._refreshBtn:setTitleFontName(UIUtils.ttfName) 
    self:registerClickEvent(self._refreshBtn, function( )
        self:sendReFreshShopMsg()
    end)

    -- 宝物兑换按钮
    self._showBtn = self:getUI("bg.mainBg.backTexture.showBtn")
    -- self._showBtn:setScale(0.9)
    self:registerClickEvent(self._showBtn, function( )
        self._offsetY = nil
        self._viewMgr:showDialog("treasure.TreasureExchangePreview", {})
    end)

    self._item = self:getUI("bg.item")
    self._item:setVisible(false)
    local priceLab = self._item:getChildByFullName("priceLab")
    -- priceLab:setFntFile(UIUtils.bmfName_shop)
    priceLab:setAnchorPoint(0,0.5)
    
    self._tabItems = {}
    local tabNames = {"bg.mainBg.smBtn","bg.mainBg.jjBtn","bg.mainBg.yzBtn","bg.mainBg.bwBtn","bg.mainBg.alBtn","bg.mainBg.gjBtn","bg.mainBg.wmBtn"}
    for k,v in pairs(tabNames) do
        local btn = self:getUI(v)
        btn:setVisible(false)
    end
    local subH = 72
    local btnH = tabNum * subH
    local posY = btnH - subH * 0.5

    self._btnScrollView = self:getUI("bg.mainBg.btnScrollView")
    self._btnScrollView:setSwallowTouches(false)
    self._btnDownArrow = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    self._btnDownArrow:setPosition(self._btnScrollView:getPositionX() + self._btnScrollView:getContentSize().width*0.5,20)
    self._btnDownArrow:setRotation(90)
    self._btnDownArrow:setVisible(tabNum > 7)
    self._mainBg:addChild(self._btnDownArrow, 100)
    self._btnScrollView:addEventListener(function(sender, eventType)
        if eventType == 1 then
            self._btnDownArrow:setVisible(false)
        elseif eventType == 2 then
            -- event.name = "SCROLL_TO_LEFT"
        elseif eventType == 3 then
            -- event.name = "SCROLL_TO_RIGHT"
            
        elseif eventType == 4 then
            if tabNum > 7 then           
                self._btnDownArrow:setVisible(true)
            end         
        end
    end)

    local sHeight = self._btnScrollView:getContentSize().height
    local scrollH = sHeight > btnH 
                    and sHeight 
                    or btnH + 10
    self._btnScrollView:setInnerContainerSize(cc.size(self._btnScrollView:getContentSize().width,scrollH ))
    self._btnScrollView:setZOrder(-1)
    -- self._btnScrollView:setBounceEnabled(true)
    self._btnScrollView:setClippingType(0)

    -- 切换动画时显示 防止按钮闪烁

    for i=1,tabNum do
        local shopBtn = ccui.Button:create()
        shopBtn:setPosition(64, posY + 5)  
        shopBtn:setAnchorPoint(0.5,0.5)
        shopBtn:setScaleAnim(true)
        shopBtn:setTitleFontName(UIUtils.ttfName)
        shopBtn:setTitleFontSize(22)
        shopBtn:setSwallowTouches(false)
        self._btnScrollView:addChild(shopBtn)

        posY = posY - subH
        table.insert(self._tabItems,shopBtn)

        self:registerClickEvent(shopBtn,function( )
            self:touchTab(i)
        end)
        -- UIUtils:setTabChangeAnimEnable(shopBtn,65,handler(self, self.touchTab),i)
    end

    -- 按钮显示
    if self._idx > 7 then
        ScheduleMgr:delayCall(0, self, function( )
            self._btnScrollView:getInnerContainer():setPositionY(0)
            self._btnDownArrow:setVisible(false)
        end)           
    end
    -- [[ 板子动画
    self._playAnimBg = self:getUI("bg.mainBg")
    self._playAnimBgOffX = 46
    self._playAnimBgOffY = -29
    self._animBtns = self._tabItems
    self._animFinishFun = function()
        if self._btnScrollView then 
            self._btnScrollView:setZOrder(6)
        end
    end
    --]]
    self._title = self:getUI("bg.mainBg.title")
    self._title:setFontName(UIUtils.ttfName)
    -- self._title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    -- self._titleImg = self:getUI("bg.mainBg.titleImg")
    self._costImg = self:getUI("bg.mainBg.backTexture.costImg")
    self._costImgInitPos = self._costImg:getPositionX()
    self._refreshTimeLab = self:getUI("bg.mainBg.backTexture.refreshTimeLab")
    self._reflashCostBg = self:getUI("bg.mainBg.backTexture.reflashCostBg")
    self._refreshTimeLabPos = self._refreshTimeLab:getPositionX()
    self._backTexture = self:getUI("bg.mainBg.backTexture")
    self._backTexture:setVisible(false)
    --
    self:listenReflash("ArenaModel", self.reflashShopInfo)
    ModelManager:getInstance():getModel("GuildModel"):setQuitAlliance(false)
    local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
    local isGuildPreOpen = guildId and guildId ~= 0
    self:listenReflash("UserModel", function( )
        if self._idx == 5 or isGuildPreOpen then
            local alliance = self._modelMgr:getModel("GuildModel"):getQuitAlliance()
            if alliance == true then
                -- 为了处理多次执行这个方法
                return
            end
            local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
            if not guildId or guildId == 0 then
                ModelManager:getInstance():getModel("GuildModel"):setQuitAlliance(true)
                self._viewMgr:returnMain()
                return
            end
        end
        self:reorderTabs()
        for k,v in pairs(self._layerTb) do
            if v.__userFuncStr then
                v[v.__userFuncStr](v)
            end            
        end
        if tabFunc[self._idx] then return end
        self:updateShopItem()
    end)
    self:listenReflash("ShopModel", function( )
        for k,v in pairs(self._layerTb) do
            if v.__shopFuncStr then
                v[v.__shopFuncStr](v)
            end            
        end        
        if tabFunc[self._idx] then return end
        self:reflashShopInfo()
    end)
    self:listenReflash("ItemModel", function( )
        for k,v in pairs(self._layerTb) do
            if v.__otherFuncStr then
                v[v.__otherFuncStr](v)
            end            
        end        
        if tabFunc[self._idx] then return end
        self:reflashShopInfo()
    end)
    self:listenReflash("VipModel", function( )
        for k,v in pairs(self._layerTb) do
            if v.__otherFuncStr then
                v[v.__otherFuncStr](v)
            end            
        end
        if tabFunc[self._idx] then return end
        self:reflashShopInfo()
    end)
    self:listenReflash("PlayerTodayModel", function( )
        local treasureTab = self._tabItems[4]
        --[[ 去掉宝物商店的提示红点 2016.11.29 ]]
--        self:addTabDot(treasureTab,not self._shopModel:treasureFreeDrawCount())
    end)

    self._shopModel = self._modelMgr:getModel("ShopModel")

    -- 计时器
    self._timeLab = self:getUI("bg.mainBg.timeLab")
    self._des1 = self:getUI("bg.mainBg.des1")
    local timeSL = ccui.Text:create()
    timeSL:setFontSize(20)
    timeSL:setPosition(50,-10)
    timeSL:setColor(cc.c3b(128, 255, 0))
    self._timeLab:addChild(timeSL)

    local time = self._shopModel:getShopRefreshTime(shopIdx[self._idx]) or 0
    self._nextRefreshTime = time
    self._timeLab:setString("00:00:00") --(string.format("%02d:%02d:%02d",math.floor(time/3600),math.floor((time%3600)/60),time%60) or 
    local tmpIdx = self._idx
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local currWeek = tonumber(TimeUtils.date("%w",nowTime))
    local timerFunc = function( )
        if not self._shopModel.getShopRefreshTime then
            self._timeLab:setVisible(false)
            return 
        end
        local restTime = self._nextRefreshTime - self._modelMgr:getModel("UserModel"):getCurServerTime() + 2
        local reflashDate = TimeUtils.date("*t",self._nextRefreshTime) 
        if restTime > -10 then
            if restTime <= 0 then
                self._shopModel:setData({})
                self._refreshAnim = true
                ScheduleMgr:delayCall(800, self, function( )
                    self._refreshAnim = nil
                end)
                self:sendGetShopInfoMsg(shopIdx[self._idx])
            else   
                if tmpIdx ~= self._idx then
                    self._nextRefreshTime = self._shopModel:getShopRefreshTime(shopIdx[self._idx])
                    tmpIdx = self._idx
                    restTime = self._nextRefreshTime - self._modelMgr:getModel("UserModel"):getCurServerTime()
                end
                if restTime < 0 then return end
                local hour = self._shopModel:getShopRefreshHour(shopIdx[self._idx])
                if hour then
                    self._timeLab:setString(" ".. hour ..":00")
                end
            end
        end
        if currWeek == 1 then
            local tab = self._tabItems[6]
            if tab then 
                if not tab._notOpen 
                    and self._modelMgr:getModel("LeagueModel"):isMondayRest() then
                    if self._idx == 6 then
                        self:touchTab(1)
                    end
                    self:reorderTabs()
                elseif tab._notOpen 
                    and not self._modelMgr:getModel("LeagueModel"):isMondayRest() then
                    self:reorderTabs()
                end
            end
        end
    end
    timerFunc()
    self._timerFunc = timerFunc
    self.timer = ScheduleMgr:regSchedule(1000,self,function( )
        self._timerFunc()
        if self._idx == 6 and self._layerTb[6] then
            self._layerTb[6]:updateTimeLab()
        end
    end)
    self:updateNeedItems()
    self:registerTimer(5,0,1,function(  )
        if self._idx == 6 and self._layerTb[6] then
            self:sendGetShopInfoMsg("league")
        end
        if self._idx == 8 and self._layerTb[8] then
            self:sendGetShopInfoMsg("citybattle")
        end
    end)
    -- 周一四点 统一刷新
    self:registerTimer(4,0,1,function(  )
        if self._idx == 6 and self._layerTb[6] then
            self:sendGetShopInfoMsg("league")
        end
    end)
end

-- 对积分联赛数据单独请求
function ShopView:detectLeagueOpen( )
    local isOpen,openDes = LeagueUtils:isLeagueOpen(101,true)
    if isOpen then
        if not self._modelMgr:getModel("LeagueModel"):getLeague() then
            ScheduleMgr:nextFrameCall(self,function( )
                ServerManager:getInstance():sendMsg("LeagueServer", "enterLeague", {}, true, {}, function(result)
                    self:reorderTabs()
                end, function (errorCode)
                    if errorCode == 3216 then
                        self._viewMgr:showTip("")
                    end
                end)
            end)
        end
    end
end

function ShopView:updateNeedItems( )
    -- 取物品需求表
    self._modelMgr:getModel("TeamModel"):refreshDataOrder()
    -- self._modelMgr:getModel("TeamModel"):refreshDataOrder()
    local countMax = self._modelMgr:getModel("FormationModel"):getCommonFormationCount()+2 or 10
    self._needItems = self._modelMgr:getModel("TeamModel"):getEquipItems(countMax)
    local teamModelData = self._modelMgr:getModel("TeamModel"):getData()
    for i,v in ipairs(teamModelData) do
        if i<= countMax then
            local teamId = v.teamId
            local itemId = 3000+tonumber(teamId)
            if self._needItems[itemId] then
                self._needItems[itemId] = self._needItems[itemId]+1
            else
                self._needItems[itemId] = -1
            end
        end
    end
end

function ShopView:onHide()
    if self.timer then
        ScheduleMgr:unregSchedule(self.timer)
        self.timer = nil
    end
end

function ShopView:onTop( )
    if not self.timer then
        self.timer = ScheduleMgr:regSchedule(1000,self,function( )
            self._timerFunc()
        end)
    end
    self:updateNeedItems()
end

function ShopView:onBeforeAdd(callback)
    if callback then
        callback()
    end
    self:reorderTabs()
    if self._noInitIdx then
        self._idx = self._tabPosItems[1].sortAKey 
    end
    if self._idx == 6 then
        if self._modelMgr:getModel("LeagueModel"):isMondayRest() then
            self._idx = 1
        end
    end
    self:touchTab(self._idx)
    self._tabItems[self._idx]._appearSelect = true
end

-- 页签加红点
function ShopView:addTabDot( tab,isRemove )
    if not tab then return end
    if not isRemove then
        if not tab:getChildByName("dot") then
            local dot = ccui.ImageView:create()
            dot:loadTexture("globalImageUI_bag_keyihecheng.png", 1)
            dot:setPosition(10,60)--node:getContentSize().width,node:getContentSize().height))
            dot:setName("dot")
            tab:addChild(dot,99)
        end
    else
        if tab:getChildByName("dot") then
            tab:getChildByName("dot"):removeFromParent()
        end
    end
end

-- 排序页签
function ShopView:reorderTabs( )
    if not self._tabPoses then
        self._tabPoses = {}
        self._tabPosItems = {}
        for i,v in pairs(self._tabItems) do
            local y = v:getPositionY()
            table.insert(self._tabPoses,y)
            table.insert(self._tabPosItems,v)
            v.sortKey = tabSys[i]
            v.sortAKey = i
        end
    end
    table.sort(self._tabPosItems,function( a,b )
        local aOpen
        local isOpen = SystemUtils["enable"..a.sortKey] and SystemUtils["enable"..a.sortKey]()
        if a.sortKey == "GuildShop" then
            local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
            if not guildId or guildId == 0 then
                isOpen = false
            end
        elseif a.sortKey == "LeagueShop" then
            isOpen = LeagueUtils:isLeagueOpen(101,true)
            if self._modelMgr:getModel("LeagueModel"):isMondayRest() then
                isOpen = false
            end
        elseif a.sortKey == "CrossGodWar" then
            isOpen = self._modelMgr:getModel("CrossGodWarModel"):isShopOpen()
            isOpen = GameStatic.is_open_crossGodWar ~= false and isOpen or false
        end
        if not isOpen then 
            aOpen = 0
            a:setBright(false)
            -- a:setEnabled(false)
            -- self:setTabState(a,"disabled")
            a._notOpen = true
            UIUtils:setGray(a,true)
            -- a:loadTextureNormal("globalBtnUI4_page1_d.png",1)
            -- a:loadTexturePressed("globalBtnUI4_page1_d.png",1)
        else
            UIUtils:setGray(a,false)
            -- a:loadTextureNormal("globalBtnUI4_page1_n.png",1)
            a:loadTexturePressed("globalBtnUI4_page1_n.png",1)
            aOpen = 1 
            a._notOpen = false
        end

        local bOpen
        local isOpen = SystemUtils["enable".. b.sortKey] and SystemUtils["enable".. b.sortKey]()
        if b.sortKey == "GuildShop" then
            local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
            if not guildId or guildId == 0 then
                isOpen = false
            end
        elseif b.sortKey == "LeagueShop" then
            isOpen = LeagueUtils:isLeagueOpen(101,true)
            if self._modelMgr:getModel("LeagueModel"):isMondayRest() then
                isOpen = false
            end
        elseif b.sortKey == "CrossGodWar" then
            isOpen = self._modelMgr:getModel("CrossGodWarModel"):isShopOpen()
            isOpen = GameStatic.is_open_crossGodWar ~= false and isOpen or false
        end
        if not isOpen then
            bOpen = 0
            b:setBright(false)
            -- b:setEnabled(false)
            b._notOpen = true
            UIUtils:setGray(b,true)
            -- self:setTabState(b,"disabled")
            -- b:loadTextureNormal("globalBtnUI4_page1_d.png",1)
            -- b:loadTexturePressed("globalBtnUI4_page1_d.png",1)
        else
            -- b:loadTextureNormal("globalBtnUI4_page1_n.png",1)
            UIUtils:setGray(b,false)
            b:loadTexturePressed("globalBtnUI4_page1_n.png",1)
            bOpen = 1 
            b._notOpen = false
        end
        if aOpen == bOpen then
            return a.sortAKey < b.sortAKey
        else
            return aOpen > bOpen
        end
    end)

    for i,v in pairs(self._tabPosItems) do
        v:setPositionY(self._tabPoses[i])
    end

end

function ShopView:setNavigation()
    if not self._naviTypes then
        self._naviTypes = {
            [1] = {"Physcal","Gold","Gem"},
            [2] = {"Currency","Gold","Gem"},
            [3] = {"Crusading","Gold","Gem"},
            [4] = {"TreasureCoin","Gold","Gem"},
            [5] = {"GuildCoin","Gold","Gem"},
            [6] = {"LeagueCoin","Gold","Gem"},
            [7] = {"PlaneCoin","Gold","Gem"},
            [8] = {"cbCoin","Gold","Gem"},
            [9] = {"cpCoin","Gold","Gem"},
            [10] = {"crossGodWarCoin","Fans","Gem"},
            [11] = {"honorCertificate","Gold","Gem"},
        }
    end
    self._viewMgr:showNavigation("global.UserInfoView",{types = self._naviTypes[self._idx],titleTxt = leftTitleNames[self._idx]})
    if not self.__popAnimOver then 
        self._viewMgr:getNavigation("global.UserInfoView"):setOpacity(0)
    end
end
function ShopView:touchTab( idx,notRefresh )
    self._offsetY = nil
    if idx ~= self._idx then
        self._isBuyBack = false
    end
    audioMgr:playSound("Tab")
    -- if idx > 3 then return end
    local isOpen,_,openLevel
    if idx == 5 then
        local userModel = self._modelMgr:getModel("UserModel")
        isOpen,_,openLevel = SystemUtils["enable"..tabSys[idx]]() -- true, 28
        if isOpen == true then
            local guildOpen = userModel:getIdGuildOpen()
            if guildOpen == false then
                isOpen = false
            end
        else
            openLevel = openLevel
        end
        if isOpen == false and openLevel <= userModel:getData().lvl then
            self._viewMgr:showTip("您还未加入联盟")
            -- UIUtils:tabTouchAnimOut(self._tabItems[idx])
            self._tabItems[idx]:setEnabled(true)
            return
        end
    elseif idx == 6 then
        isOpen,openDes = LeagueUtils:isLeagueOpen()
        isOpen = LeagueUtils:isLeagueOpen(101,true)
        if self._modelMgr:getModel("LeagueModel"):isMondayRest() then
            isOpen = false
        end
        if isOpen == false then
            self._viewMgr:showTip(openDes or "冠军对决还未开启")
            -- UIUtils:tabTouchAnimOut(self._tabItems[idx])
            self._tabItems[idx]:setEnabled(true)
            return
        end
    elseif idx == 10 then
        local userModel = self._modelMgr:getModel("UserModel")
        isOpen = self._modelMgr:getModel("CrossGodWarModel"):isShopOpen()
        isOpen = GameStatic.is_open_crossGodWar ~= false and isOpen or false
        if not isOpen then
            self._viewMgr:showTip("跨服诸神未开启")
            return
        end
    else
        isOpen,_,openLevel = SystemUtils["enable"..tabSys[idx]]()
        openLevel = openLevel .. "级"
    end
    if not isOpen then
        local _,_,_,systemOpenTip = SystemUtils["enable"..tabSys[idx]]()
        if not systemOpenTip then
            if tab.systemOpen[tabSys[idx]] then
                self._viewMgr:showTip(tab.systemOpen[tabSys[idx]][1] .. "级开启")
            else
                self._viewMgr:showTip("暂未开启")
            end
        else
            self._viewMgr:showTip(lang(systemOpenTip))
        end
        -- UIUtils:tabTouchAnimOut(self._tabItems[idx])
        self._tabItems[idx]:setEnabled(true)
        return 
    end
    self._refreshAnim = nil
    local shopName = shopIdx[idx] 
    -- if shopName == "treasure" then
    --     self._backTexture:setVisible(false)
    -- else
    --     self._backTexture:setVisible(true)
    -- end

    
    if self._title then
        self._title:setString(titleNames[idx])
    end
    -- self._titleImg:loadTexture(titleImgs[idx],1)
    for k,btn in pairs(self._tabItems) do
        if k ~= idx then
            btn:loadTextureNormal(tabImg["normal"],1)
            btn:setEnabled(true)
            -- btn:setTitleFontSize(30)
            btn:setTitleFontName(UIUtils.ttfName)
            btn:setTitleText(shortTitleNames[k])
            local text = btn:getTitleRenderer()
            if btn._notOpen then
                btn:setTitleColor(UIUtils.colorTable.ccUITabColor1)
                -- text:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
            else
                btn:setTitleColor(UIUtils.colorTable.ccUITabColor1)
            end 
            text:disableEffect()
            -- text:enableOutline(cc.c4b(79, 45, 10,255),0)
            -- self:setTabState(btn,"normal")
            -- btn:setEnabled(true)
            btn:setScaleAnim(false)
            -- btn:stopAllActions()
            if btn:getChildByName("changeBtnStatusAnim") then 
                btn:getChildByName("changeBtnStatusAnim"):removeFromParent()
            end
        end
    end
    
    local item = self._tabItems[idx]
    -- 切页动画
    -- if self._preBtn then
    --     UIUtils:tabChangeAnim(self._preBtn,nil,true)
    -- end
    self._idx = idx
    self:setNavigation()
    -- 按钮动画
    self._preBtn = item
    -- UIUtils:tabChangeAnim(item,function( )
        item:loadTextureNormal(tabImg["selected"],1)
        item:setEnabled(false)
        -- item:setBright(false)
        item:setTitleText(shortTitleNames[idx])
        local text = item:getTitleRenderer()
        item:setTitleColor(UIUtils.colorTable.ccUITabColor2)
        text:disableEffect()
        -- text:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
        -- self:setTabState(item,"selected")
         -- 切页时判断是否需要发更新请求
        local shopData = self._shopModel:getShopByType(shopName)

        if shopData == nil then
            ScheduleMgr:delayCall(0, self, function( )
                if self.sendGetShopInfoMsg then
                    self:sendGetShopInfoMsg(shopName)
                end
            end) 
        else
            local lastUpTime = shopData.lastUpTime 
            local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
            if not lastUpTime or lastUpTime == 0 then
                lastUpTime = nowTime
            end
            local nextRefrashTime = self._shopModel:getShopRefreshTime(shopIdx[idx],lastUpTime)
            if nowTime >= nextRefrashTime and idx ~= 6 then
                ScheduleMgr:delayCall(0, self, function( )
                    if self.sendGetShopInfoMsg then
                        self:sendGetShopInfoMsg(shopName)
                    end
                end)
            end
        end
        if not notRefresh then
            ScheduleMgr:delayCall(20, self, function( )
                self:reflashShopInfo()
            end) 
        end
        -- if self._leagueShopLayer then
        --     self._leagueShopLayer:removeFromParent()
        --     self._leagueShopLayer = nil
        --     UIUtils:reloadLuaFile("league.LeagueShopView")
        --     -- self._leagueShopLayer:setVisible(false)
        -- end
        local currLayer = self._layerTb[idx]
        if tabFunc[idx] then
            if not currLayer then
                local shopFunc = tabFunc[idx]["shopReflashFunc"]
                local userFunc = tabFunc[idx]["userReflashFunc"]
                local otherFunc = tabFunc[idx]["otherReflashFunc"]
                if tabFunc[idx].detectLeagueOpen then
                    self[tabFunc[idx].detectLeagueOpen]()
                end
                local shipLayerName = tabFunc[idx]["layerName"]
                UIUtils:reloadLuaFile(shipLayerName)
                local shopType = shopIdx[idx]
                local shopData = self._modelMgr:getModel("ShopModel"):getShopGoods(shopType) or {}
                if not next(shopData) then
                    -- ScheduleMgr:delayCall(0, self, function( )
                        if not self._mainBg then return end
                        self._serverMgr:sendMsg("ShopServer", "getShopInfo", {["type"] = shopType}, true, {}, function(result)
                            local shopLayer = self:createLayer(shipLayerName)                            
                            shopLayer:reflashUI()
                            shopLayer:setPosition(-53,-43)
                            shopLayer.__userFuncStr = shopFunc
                            shopLayer.__shopFuncStr = userFunc
                            shopLayer.__otherFuncStr = otherFunc
                            self._mainBg:addChild(shopLayer,2)
                            self._layerTb[idx] = shopLayer
                        end)
                    -- end)
                else
                     -- ScheduleMgr:delayCall(0, self, function( )
                        if not self._mainBg then return end
                        local shopLayer = self:createLayer(shipLayerName)
                        shopLayer:reflashUI()
                        shopLayer:setPosition(-53,-43)
                        shopLayer.__userFuncStr = shopFunc
                        shopLayer.__shopFuncStr = userFunc
                        shopLayer.__otherFuncStr = otherFunc
                        self._mainBg:addChild(shopLayer,2)
                        self._layerTb[idx] = shopLayer
                    -- end)
                end
            else
                currLayer:setVisible(true)
                if idx ~= self._idx then
                    currLayer:resetOffsetY()
                end
                currLayer:reflashUI()
            end
        end

        for i,v in pairs(self._layerTb) do
            if i ~= idx then
                v:setVisible(false)
                v:reflashUI()
            end
        end

    -- end)
    
    -- if idx == 4 then
    --     if not self._treasureShop then
    --         UIUtils:reloadLuaFile("treasure.TreasureShopView")
    --         self._treasureShop = self:createLayer("treasure.TreasureShopView")
    --         self._treasureShop:setPosition(25,25)
    --         self._mainBg:addChild(self._treasureShop,1)
    --     else
    --         self._treasureShop:setVisible(true)
    --     end
    --     self._timeLab:setVisible(false)
    --     self._des1:setVisible(false)
    --     if self._showDialogTreasure then
    --         self:lock(-1)
    --         self._showDialogTreasure = false
    --         ScheduleMgr:delayCall(500, self, function( )
    --             self._viewMgr:showDialog("treasure.DialogTreasureShop",{},true)
    --             self:unlock()
    --         end)
    --     end
    -- else
        -- if self._treasureShop then
        --     -- self._treasureShop:removeFromParent()
        --     -- self._treasureShop = nil
        --     self._treasureShop:setVisible(false)
        -- end

        self._nextRefreshTime = self._shopModel:getShopRefreshTime(shopIdx[self._idx])
        self._timerFunc()
        self._timeLab:setVisible(true)
        self._des1:setVisible(true)
    -- end
        
    -- self:refreshRefresBtnCost()
end

-- local tabStates = {selected = 1,normal = 2,disabled = 3}
-- function ShopView:setTabState( sender,state )
    -- for i=1,3 do
    --     local text = sender:getChildByFullName("text_" .. i)
    --     if i == tabStates[state] then
    --         text:setVisible(true)
    --     else
    --         text:setVisible(false)
    --     end
    --     text:setVisible(false)
    -- end
-- end

-- 接收自定义消息
function ShopView:reflashUI(data)
    local tabIdx = data.idx or 2
    self:touchTab(tabIdx)
end
-- 按类型返回商店数据
function ShopView:getGoodsData( tp )
    print("xxxx",tp)
    if tabFunc[self._idx] then return end
    local goodsData
    local shopData = self._shopModel:getShopGoods(shopIdx[tp])
    if shopData ~= nil then
        goodsData = {}
        local shopTableName = shopTableIdx[tp]

        for pos,data in pairs(shopData) do
            local shopD
            if tab[shopTableName] then
                shopD = clone(tab[shopTableName][tonumber(data.id)])
            end
            if shopD == nil then
                self._viewMgr:showTip("不存在的商品, ".. shopTableName .." ID=".. (data.id or ""))
                break
            end
            -- if shopD.num == 0 then
            --     shopD.buyTimes = 1
            -- else
            --     shopD.buyTimes = 0
            -- end
            shopD.itemId = data.item

            if self._idx == 10 then
                if shopD.item[1] ~= "tool" 
                    and shopD.item[1] ~= "hero" 
                    and shopD.item[1] ~= "team" 
                    and shopD.item[1] ~= "avatarFrame" 
                    and shopD.item[1] ~= "avatar" 
                    and shopD.item[1] ~= "hSkin" 
                    and shopD.item[1] ~= "siegeProp"
                then
                    shopD.itemId = IconUtils.iconIdMap[shopD.item[1]]
                else
                    shopD.itemId = shopD.item[2]
                end
                shopD.num = shopD.item[3]
            end

            local buyTimes = data.buy
            -- for k1,v1 in pairs(itemInfo) do
            --     shopD.itemId = k1--or shopD.itemId[1]
            --     buyTimes = v1
            -- end
            if buyTimes ~= 0 then
                shopD.buyTimes = buyTimes
            else
                shopD.buyTimes = 0
            end
            shopD.id = tonumber(data.id)-- 勘正表错误代码
            -- shopD.costType = "currency"
            shopD.shopBuyType = shopIdx[tp]

            local serverIndex = self._shopModel:getServerIndex(pos, shopIdx[tp])
            shopD.pos = serverIndex or pos
            
            goodsData[tonumber(pos)] = shopD
        end
        -- table.sort(goodsData,function( a,b )
        --     local aS = a.sort or a.position or 0
        --     local bS = b.sort or b.position or 0
        --     if not tonumber(aS) or not tonumber(bS) or tonumber(aS) == tonumber(bS) then
        --         return tonumber(a.itemId) < tonumber(b.itemId) 
        --     end
        --     return tonumber(aS or 0) < tonumber(bS or 0)
        -- end)
    end
    
    return goodsData
end

-- 单独抽出来
function ShopView:refreshRefresBtnCost( )
    local refreshTimes = 50
    if self._shopModel.getRefreshCost then
        local costType = "gem"
        refreshTimes,costType = self._shopModel:getRefreshCost(shopIdx[self._idx])
        self._refreshTimeLab:setString(refreshTimes)
        -- self._costImg:setPositionX(self._refreshTimeLab:getPositionX() - self._refreshTimeLab:getContentSize().width)
        self._refreshTimeLab:setVisible(true)
        local _,costType = self._shopModel:getRefreshCost( shopIdx[self._idx] )
        local costRes = IconUtils.resImgMap[costType]--tab[shopIdx[self._idx]][1]["costType"]]
        if costRes and costRes ~= "" then
            self._costImg:loadTexture(costRes,1)
            self._costImg:setScale(0.8)
        end
    else
        print("setVisible(heororororolllll.dalkhgajhglkajglgj)")
        self._refreshTimeLab:setVisible(false)
    end
    local privilgeNum = self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_10) or 0
    local hadUse = self._modelMgr:getModel("PlayerTodayModel"):getData().day11 or 0
    local shopName = shopIdx[self._idx]
    self._refreshTimeLab:disableEffect()
    if shopName == "mystery" and privilgeNum > 0 and privilgeNum > hadUse then
        self._costImg:loadTexture(IconUtils.resImgMap["privilege"],1)
        -- self._costImg:setPositionX(self._costImgInitPos-10)
        self._refreshTimeLab:setString("免费(".. (privilgeNum-hadUse) ..")")
        self._refreshTimeLab:setAnchorPoint(1,0.5)
        self._refreshTimeLab:setPositionX(self._refreshTimeLabPos+43)
        -- self._refreshTimeLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        self._costImg:setPositionX(self._refreshTimeLab:getPositionX() - self._refreshTimeLab:getContentSize().width)
        self._refreshTimeLab:setColor(UIUtils.colorTable.ccUIBaseColor9)
    else
        local _,refreshCostType = self._shopModel:getRefreshCost(shopIdx[self._idx])
        self._costImg:loadTexture(IconUtils.resImgMap[refreshCostType],1)
        -- self._costImg:setPositionX(self._costImgInitPos)
        -- local refreshTimes = self._shopModel:getRefreshCost(shopIdx[self._idx])
        self._refreshTimeLab:setString(refreshTimes)
        self._costImg:setPositionX(self._costImgInitPos)
        self._refreshTimeLab:setAnchorPoint(0.5,0.5)
        self._refreshTimeLab:setPositionX(self._refreshTimeLabPos)
        self._refreshTimeLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    end
    local _,costType = self._shopModel:getRefreshCost( shopIdx[self._idx] )
    if refreshTimes and refreshTimes > (self._modelMgr:getModel("UserModel"):getData()[costType] or 0) then
        if not (shopName == "mystery" and privilgeNum > 0 and privilgeNum > hadUse) then
            self._refreshTimeLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
        end
    end
    local costImgLabWidth = self._costImg:getContentSize().width+self._refreshTimeLab:getContentSize().width
    costImgLabWidth = math.max(costImgLabWidth,60)
    self._reflashCostBg:setContentSize(cc.size(costImgLabWidth+25,49)) 
    local centerX = self._reflashCostBg:getPositionX()-costImgLabWidth/2-15
    UIUtils:center2Widget(self._costImg,self._refreshTimeLab,centerX,5)
end

function ShopView:reflashShopInfo()
    -- self._scrollView:removeAllChildren()

    if self._treasureShop then
        self._treasureShop:reflashUI()
    end

    -- 宝物商店免费时加红点
    local treasureTab = self._tabItems[4]
    --[[ 去掉宝物商店的提示红点 2016.11.29 ]]
--    self:addTabDot(treasureTab,not self._shopModel:treasureFreeDrawCount())
    self._showBtn:setVisible(false and (self._idx == 4 or self._idx == 6))
    if tabFunc[self._idx] then 
        return 
    end
    --
    for k,v in pairs(self._grids) do
        v:removeFromParent()
        v = nil
    end
    self._grids = {} -- 清空空格子
    for k,v in pairs(self._items) do
        v:setVisible(false)
    end

    self._scrollView:setInnerContainerSize(cc.size(self.scrollViewW,self.scrollViewH))
    self:refreshRefresBtnCost()    
    self._goodData = self:getGoodsData(self._idx)
    local goodsData = self._goodData
    if not goodsData then 
        return 
    end

    local itemSizeX,itemSizeY = 186,192
    local offsetX,offsetY = 5,0
    local goodsNum = #goodsData
    local row = math.ceil(goodsNum/4)--2--
    local col = 4 --math.ceil(#goodsData/2) --

    local boardHeight = row*itemSizeY
    local scrollHeight = self._scrollView:getContentSize().height

    if boardHeight < scrollHeight then
        boardHeight = scrollHeight 
        self._downArrow:setVisible(false)
    else
        self._downArrow:setVisible(true)
        self._scrollView:setInnerContainerSize(cc.size(self.scrollViewW,boardHeight))
    end
    -- local boardWidth = math.ceil(#goodsData/2)*itemSizeX
    -- if boardWidth > self.scrollViewW then
    --     self._scrollView:setInnerContainerSize(cc.size(boardWidth+20,self.scrollViewH))
    --     self:showArrow("right")
    -- end
    local x,y = 0,0
    local goodsCount = math.max(8,row*col)
    self:lock()

    -- dump(goodsData,"goodsData")
    -- 处理联盟商店数据
    local guildGridData = clone(goodsData)
    if self._idx == 5 then
        local guildData = {}
        
        local guildLevel = self._modelMgr:getModel("GuildModel"):getAllianceDetail().level
        if not guildLevel then
            guildLevel = self._modelMgr:getModel("UserModel"):getData().guildLevel
        end
        for i=1,goodsNum do
            if tab:ShopGuildLimit(i).level <= (guildLevel or 0) then
                table.insert(guildData, goodsData[i])
            end
        end
        if table.nums(guildData) ~= 0 then
            goodsData = guildData
        end
    end
    local cGodWarData = {}
    if self._idx == 10 then
        for pos = 1,8 do
            for id,data in pairs(tab.shopCrossFight) do
                if data.position == pos and (not goodsData[pos]) then
                    cGodWarData[pos] = clone(data)
                end
            end
        end
    end
    self._nextOpenIdx = #goodsData+1
    if self._idx == 4 then
        for i=1,goodsCount do
            if not self:detectOpenPos(i) and goodsData[i] then
                self._nextOpenIdx = i
                break
            end
        end
    end
    self._itemTable = {}
    for i=1,goodsCount do
        -- x = math.floor((i-1)/row)*itemSizeX+offsetX
        -- y = self.scrollViewH/2 - (i-1)%row*itemSizeY+offsetY
        x = (i-1)%col*itemSizeX+offsetX+itemSizeX*0.5
        y = boardHeight - (math.floor((i-1)/col) + 1)*itemSizeY+offsetY+itemSizeY*0.5 - 1
        
        if self._idx == 4 then
            local isOpen = self:detectOpenPos(i)
            if isOpen and goodsData[i] then           
                self:createItem( i,goodsData[i],x,y)
            elseif goodsData[i] then
                self:createTreasureGrid(i,x,y,goodsData[i])
            else
                self:createGrid(x,y,i)
            end
        elseif goodsData[i] then
            self:createItem( i,goodsData[i],x,y)
        elseif self._idx == 5 then
            if guildGridData[i] then 
                self:createGuildGrid(i,x,y,guildGridData[i])
            else
                self:createGrid(x,y,i)
            end
        elseif self._idx == 10 then
            dump(cGodWarData[i])
            self:createCrossGodWarGrid(i,x,y,cGodWarData[i])
        else
            self:createGrid(x,y,i)
        end
    end
    
    self:unlock()

    if not self._backTexture:isVisible() then
        self._backTexture:setVisible(true)
    end

    if self._offsetY then
        local offsetY = self._offsetY
        local subHeight = self._scrollView:getContentSize().height - boardHeight
        if subHeight < offsetY then
            self._scrollView:getInnerContainer():setPositionY(offsetY)            
        else
            self._scrollView:getInnerContainer():setPositionY(subHeight)
        end
        -- self._offsetY = nil
    end
end

function ShopView:updateShopItem()
    -- if self._idx == 4 then 
    --     return 
    -- end
    self._goodData = self:getGoodsData(self._idx)
    local goodsData = self._goodData
    if not goodsData then 
        return 
    end
    if not self._itemTable or table.nums(self._itemTable) == 0 then 
        return
    end
    local goodsCount = table.getn(goodsData)
    local player = self._modelMgr:getModel("UserModel"):getData()   
    for i=1,goodsCount do
        data = goodsData[i]
        if type(data.costType) == "table" then
            haveNum = player[(data.costType[1] or data.costType["type"])] or 0
            costNum = data.costType[3] or data.costType["num"]
            data.costType = (data.costType[1] or data.costType["type"])
            data.costNum = costNum
        else
            haveNum = player[data.costType] or 0
            costNum = data.costNum
        end
        -- 花费
        if not tolua.isnull(self._itemTable[i]) then
            local priceLab = self._itemTable[i]:getChildByFullName("priceLab")
            if priceLab then 
                -- priceStr = string.format("% 6d",costNum)
                priceLab:setString(ItemUtils.formatItemCount(costNum) or "")
                if haveNum < costNum and data.buyTimes ~= 1 then
                    priceLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
                    -- priceLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
                else
                    priceLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
                    -- priceLab:disableEffect()
                end
            end
        end
    end
    self._downArrow:setVisible(goodsCount > 8)
end

function ShopView:showArrow( direction )
    self._rightArrow:setVisible(false)
    -- self._rightArrow:stopAllActions()
    self._leftArrow:setVisible(false)
    -- self._leftArrow:stopAllActions()
    if self._scrollView:getInnerContainerSize().width <= self.scrollViewW or not direction then
        return
    end
    local arrow = self["_" .. direction .. "Arrow"]
    if arrow then
        arrow:setVisible(true)
        -- arrow:runAction(cc.RepeatForever:create(cc.Blink:create(0.8,1)))
    end
end
local discountToCn = {
    "一折","二折","三折",
    "四折","五折","六折",
    "七折","八折","九折",
}
function ShopView:createItem(index, data,x,y)
    local item
    item = self._items[index]
    if not item then
        item = self._item:clone() 
        self._items[index] = item 
        self._scrollView:addChild(item)
    end   
    if self._grids[index] and not tolua.isnull(self._grids[index]) then
        self._grids[index]:removeFromParent()
    end
    -- 商店格子不放大 
    item:setScaleAnim(false)
    self._itemTable[index] = item
    item:setSwallowTouches(true)

    -- table.insert(self._itemTable,item)
    item:setSwallowTouches(false)
    item:setName("item"..index)
    item:setVisible(true)
    
    item:setPosition(x,y)

    local itemId = tonumber(data.itemId)
    if not itemId then
        itemId = IconUtils.iconIdMap[data.itemId]
    end
    local toolD = tab:Tool(itemId)
    local canTouch = true
    --加图标
    local itemIcon = item:getChildByFullName("itemIcon")
    itemIcon:setSwallowTouches(false)
    itemIcon:removeAllChildren()
    local num = data.num 
    if num == 1 then 
        num = nil
    end
    local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = num,eventStyle = 0})
    icon:setContentSize(100, 100)
    icon:setScale(0.9)
    itemIcon:addChild(icon)

    -- local 

    -- 设置名称
    local itemName = item:getChildByFullName("itemName")
    itemName:setString(lang(toolD.name) or "没有名字")
    itemName:setFontName(UIUtils.ttfName)
    -- itemName:setColor(UIUtils.colorTable["ccUIBaseColor" .. toolD.color])
    -- itemName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    local haveNum = 0
    local costNum = 0
    local player = self._modelMgr:getModel("UserModel"):getData()
    if type(data.costType) == "table" then
        haveNum = player[(data.costType[1] or data.costType["type"])] or 0
        costNum = data.costType[3] or data.costType["num"]
        data.costType = (data.costType[1] or data.costType["type"])
        data.costNum = costNum
    else
        haveNum = player[data.costType] or 0
        costNum = data.costNum
    end
    -- 花费
    local priceLab = item:getChildByFullName("priceLab")
    -- priceStr = string.format("% 6d",costNum)
    priceLab:setString(ItemUtils.formatItemCount(costNum) or "")
    if haveNum < costNum and data.buyTimes ~= 1 then
        -- priceLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        priceLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
    else
        priceLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        -- priceLab:disableEffect()
    end
    -- priceBmpLab:setPositionX((item:getContentSize().width-priceBmpLab:getContentSize().width)/2)
    -- 购买类型
    local buyIcon = item:getChildByFullName("diamondImg")
    buyIcon:loadTexture(IconUtils.resImgMap[data.costType],1)
    local scaleNum = math.floor((32/buyIcon:getContentSize().width)*100)
    buyIcon:setScale(scaleNum/100)
    -- buyIcon:setScale(1)

    local iconW = buyIcon:getContentSize().width*scaleNum/100
    local labelW = priceLab:getContentSize().width
    local itemW = item:getContentSize().width - 5
    buyIcon:setPositionX(itemW/2-labelW/2-3)
    priceLab:setPositionX(itemW/2+iconW/2-labelW/2-3)

    UIUtils:center2Widget(buyIcon,priceLab,itemW/2,5)

    self:registerClickEvent(item, function( )
        if canTouch then
            self._refreshAnim = nil            
            self._offsetY = self._scrollView:getInnerContainer():getPositionY()
            -- print("============self._offsetY====",self._offsetY)
            local param = {shopData = data,closeCallBack=function ( ... )
                self._isBuyBack = true
            end}
            self._viewMgr:showDialog("shop.DialogShopBuy",param,true)
        end
    end)
    -- data.discount = 3
    local discountBg = item:getChildByFullName("discountBg")

    if data.discount and data.discount > 0 then
        local color = "r"
        if data.discount > 5 then 
            color = "p"
        end
        discountBg:loadTexture("globalImageUI6_connerTag_" .. color ..".png",1)
        local discountLab = discountBg:getChildByFullName("discountLab")
        discountLab:setFontName(UIUtils.ttfName)
        discountLab:setRotation(41)
        discountLab:setFontSize(20)
        -- discountLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
        discountLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        discountLab:setString(discountToCn[data.discount])
        discountBg:setVisible(true)
    else
        discountBg:setVisible(false)
    end
    local soldOut = item:getChildByFullName("soldOut")
    soldOut:setVisible(false)
    self:setNodeColor(item,cc.c4b(255, 255, 255,255),true)
	
	local mc
	local iconColor = icon:getChildByName("iconColor")
	if iconColor then
		mc = iconColor:getChildByName("bgMc")
	end
    if data.buyTimes == 1 then
        canTouch = false
        -- local soldOut = item:getChildByFullName("soldOut")
        soldOut:setVisible(true)
        if item.hadSold == false then
            soldOut:setOpacity(0)
            soldOut:setScale(1.2)
            soldOut:runAction(cc.Sequence:create(
                    cc.DelayTime:create(5),
                    cc.Spawn:create(cc.FadeIn:create(0.5),cc.ScaleTo:create(0.2,0.9),cc.ScaleTo:create(0.3,1)),
                    cc.CallFunc:create(function( )
                        item.hadSold = true
                    end)
                    )
                )
        end
        item:setEnabled(false)
        -- UIUtils:setGray(item,true)
        -- item:setBrightness(-50)
        self:setNodeColor(item,cc.c4b(182, 182, 182,255))
        self:setNodeColor(soldOut,cc.c4b(255, 255, 255,255))
        -- self:setNodeColor(discountBg,cc.c4b(255, 255, 255,255))
		
		if mc then
			mc:setVisible(false)
		end
    else
        item:setEnabled(true)
        canTouch = true
        local soldOut = item:getChildByFullName("soldOut")
        soldOut:setVisible(false)
        if mc then
            mc:setVisible(true)
        end
    end

    -- 添加红点
    local _,count = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
    local needCount = self._needItems[itemId] or 0
    local dot = item:getChildByFullName("noticeTip")
    if not tolua.isnull(dot) then 
        dot:removeFromParent()
    end
    if (count < needCount or needCount == -1) and canTouch  then
        local dot = ccui.ImageView:create()
        local teamId = string.sub(tostring(itemId),2,string.len(tostring(itemId)))
        if teamId and string.len(itemId) == 4 then
            local isInFormation = self._modelMgr:getModel("FormationModel"):isTeamLoaded(tonumber(teamId))
            if isInFormation then
                dot:loadTexture("globalIamgeUI6_addTeam.png", 1)
                dot:setContentSize(69,51)
                dot:setPosition(item:getContentSize().width/2-icon:getContentSize().width/2+15,item:getContentSize().height/2-icon:getContentSize().height/2+70)
            -- else -- 没上阵的去掉推荐
            --     dot:loadTexture("recommand_shop.png", 1)
            --     dot:setPosition(10,item:getContentSize().height-dot:getContentSize().height/2+10)
            end
        else
            dot:loadTexture("globalImageUI_bag_keyihecheng.png", 1)
            dot:setContentSize(32,32)
            dot:setPosition(item:getContentSize().width/2+icon:getContentSize().width/2-10,item:getContentSize().height/2+icon:getContentSize().height/2-10)
        end
        dot:setName("noticeTip")
        item:addChild(dot,99)
    end
    if self._refreshAnim then
        local mc = mcMgr:createViewMC("shangdianshuaxin_shoprefreshanim", false, true,function( )
        end)
        -- mc:setPosition(x,y)
        mc:setScaleY(1)
        mc:setPosition(x-4,y-5)
        self._scrollView:addChild(mc,9999)
        -- item:addChild(mc,9999)
    end

    -- 加特殊标签
    local subTitleImg = item:getChildByFullName("subTitleImg")
    if not tolua.isnull(subTitleImg) then 
        subTitleImg:removeFromParent()
    end
    if toolD.subtitle then
        local subTitleImg = ccui.ImageView:create()
        subTitleImg:loadTexture("globalImageUI_" .. toolD.subtitle .. ".png",1)
        subTitleImg:setPosition(60,60)
        subTitleImg:setRotation(20)
        subTitleImg:setName("subTitleImg")
        item:addChild(subTitleImg,999)
    end

end

-- 创建联盟未开启格子
function ShopView:createCrossGodWarGrid(index,x,y,data)
    if self._grids[index] and not tolua.isnull(self._grids[index]) then
        self._grids[index]:removeFromParent()
    end
    if not tolua.isnull(self._items[index]) then
        self._items[index]:setVisible(false)
    end
    local item = ccui.ImageView:create()
    self._grids[index] = item
    item:setScaleAnim(true)
    item:loadTexture("globalPanelUI7_cellBg1.png",1)
    item:setContentSize(cc.size(190, 200))
    item:setScale9Enabled(true)
    --CCScale9Sprite:createWithSpriteFrameName(spriteFrameName, capInsets)
    -- item:ignoreContentAdaptWithSize(false)
    -- item:setCapInsets(cc.rect(60,50,10,10))
    -- item:setScale(180/item:getContentSize().width,172/item:getContentSize().height)
    local offsetx,offsety = -2,2
    local shopGridFrame = ccui.ImageView:create()
    shopGridFrame:loadTexture("globalImageUI4_squality1.png", 1)
    shopGridFrame:setName("shopGridFrame")
    shopGridFrame:setContentSize(98, 98)
    shopGridFrame:setAnchorPoint(0.5,0.5)
    shopGridFrame:setPosition(102+offsetx,105+offsety)
    shopGridFrame:setScale(85/shopGridFrame:getContentSize().width)
    item:addChild(shopGridFrame,2)
    local shopGridBg = ccui.ImageView:create()
    shopGridBg:loadTexture("globalImageUI4_itemBg1.png", 1)
    shopGridBg:setName("shopGridBg")
    shopGridBg:setContentSize(100, 100)
    shopGridBg:setAnchorPoint(0.5,0.5)
    shopGridBg:setPosition(102+offsetx,105+offsety)
    shopGridBg:setScale(80/shopGridBg:getContentSize().width)
    item:addChild(shopGridBg,1)

    -- 加装饰条
    local decorateImg = self._item:getChildByFullName("bottomDecorate")
    if decorateImg then
        local decImg = decorateImg:clone()
        item:addChild(decImg,0)
        decImg:setPosition(95,33)
    end
    if data.item[1] ~= "tool" 
        and data.item[1] ~= "hero" 
        and data.item[1] ~= "team" 
        and data.item[1] ~= "avatarFrame" 
        and data.item[1] ~= "avatar" 
        and data.item[1] ~= "hSkin" 
        and data.item[1] ~= "siegeProp"
    then
        data.itemId = IconUtils.iconIdMap[data.item[1]]
    else
        data.itemId = data.item[2]
    end
    data.num = data.item[3]

    local itemId = tonumber(data.itemId)
    if not itemId then
        itemId = IconUtils.iconIdMap[data.itemId]
    end
    local toolD = tab:Tool(itemId)

    local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,effect=true,num = nil,eventStyle = 0})
    icon:setContentSize(100, 100)
    icon:setScale(0.9)
    icon:setPosition(item:getContentSize().width/2-40,item:getContentSize().height/2-38)
    item:addChild(icon,2)

    local lock = ccui.ImageView:create()
    lock:loadTexture("globalImageUI5_treasureLock.png",1)
    lock:setName("lock")
    lock:setPosition(item:getContentSize().width/2,item:getContentSize().height/2+2)
    -- lock:setScale(0.85)
    item:addChild(lock,3)
    self._scrollView:addChild(item)
    item:setAnchorPoint(0.5,0.5)
    item:setPosition(x,y)

    local title = ccui.Text:create()
    title:setFontName(UIUtils.ttfName)
    title:setAnchorPoint(0.5,0.5)
    title:setFontSize(20)
    title:setFontName(UIUtils.ttfName)

    title:setString(lang(toolD.name) or "没有名字")
    title:setColor(UIUtils.colorTable["ccUIBaseTextColor2"])

    title:setName("stage")
    title:setPosition(item:getContentSize().width/2,item:getContentSize().height-25)
    item:addChild(title,99)

    local rtxStr = "[color = 865c30] [-]"
    local limit = data.rankLimit
    if limit then
        rtxStr = "[color = 3c3c3c,fontSize = 18]前" .. limit .. "名开启[-]"--"[color = 865c30,fontSize = 22]级开启[-]"
    end

    local rtx = RichTextFactory:create(rtxStr,200,40)
    rtx:formatText()
    rtx:setName("rtx")
    local w = rtx:getInnerSize().width
    local h = rtx:getInnerSize().height
    rtx:setPosition(item:getContentSize().width/2+1,20+h/2)
    -- rtx:setScale(0.8)
    item:addChild(rtx)
    UIUtils:alignRichText(rtx)
    -- 置灰显示
    self:setNodeColor(item,cc.c4b(182, 182, 182,255))
end

-- 创建联盟未开启格子
function ShopView:createGuildGrid(index,x,y,data)
    if self._grids[index] and not tolua.isnull(self._grids[index]) then
        self._grids[index]:removeFromParent()
    end
    if not tolua.isnull(self._items[index]) then
        self._items[index]:setVisible(false)
    end
    local item = ccui.ImageView:create()
    self._grids[index] = item
    item:setScaleAnim(true)
    item:loadTexture("globalPanelUI7_cellBg1.png",1)
    item:setContentSize(cc.size(190, 200))
    item:setScale9Enabled(true)
    --CCScale9Sprite:createWithSpriteFrameName(spriteFrameName, capInsets)
    -- item:ignoreContentAdaptWithSize(false)
    -- item:setCapInsets(cc.rect(60,50,10,10))
    -- item:setScale(180/item:getContentSize().width,172/item:getContentSize().height)
    local offsetx,offsety = -2,2
    local shopGridFrame = ccui.ImageView:create()
    shopGridFrame:loadTexture("globalImageUI4_squality1.png", 1)
    shopGridFrame:setName("shopGridFrame")
    shopGridFrame:setContentSize(98, 98)
    shopGridFrame:setAnchorPoint(0.5,0.5)
    shopGridFrame:setPosition(102+offsetx,105+offsety)
    shopGridFrame:setScale(85/shopGridFrame:getContentSize().width)
    item:addChild(shopGridFrame,2)
    local shopGridBg = ccui.ImageView:create()
    shopGridBg:loadTexture("globalImageUI4_itemBg1.png", 1)
    shopGridBg:setName("shopGridBg")
    shopGridBg:setContentSize(100, 100)
    shopGridBg:setAnchorPoint(0.5,0.5)
    shopGridBg:setPosition(102+offsetx,105+offsety)
    shopGridBg:setScale(80/shopGridBg:getContentSize().width)
    item:addChild(shopGridBg,1)

    -- 加装饰条
    local decorateImg = self._item:getChildByFullName("bottomDecorate")
    if decorateImg then
        local decImg = decorateImg:clone()
        item:addChild(decImg,0)
        decImg:setPosition(95,33)
    end

    local itemId = tonumber(data.itemId)
    if not itemId then
        itemId = IconUtils.iconIdMap[data.itemId]
    end
    local toolD = tab:Tool(itemId)
    if self._nextOpenIdx == index then
        local num = data.num 
            if num == 1 then 
                num = nil
            end
        local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,effect=true,num = num,eventStyle = 0})
        icon:setContentSize(100, 100)
        icon:setScale(0.9)
        icon:setPosition(item:getContentSize().width/2-40,item:getContentSize().height/2-38)
        item:addChild(icon,2)
    end

    local lock = ccui.ImageView:create()
    lock:loadTexture("globalImageUI5_treasureLock.png",1)
    lock:setName("lock")
    lock:setPosition(item:getContentSize().width/2,item:getContentSize().height/2+2)
    -- lock:setScale(0.85)
    item:addChild(lock,3)
    self._scrollView:addChild(item)
    item:setAnchorPoint(0.5,0.5)
    item:setPosition(x,y)

    local title = ccui.Text:create()
    title:setFontName(UIUtils.ttfName)
    title:setAnchorPoint(0.5,0.5)
    title:setFontSize(20)
    title:setFontName(UIUtils.ttfName)
    if self._nextOpenIdx == index then
        title:setString(lang(toolD.name) or "没有名字")
        -- title:setColor(UIUtils.colorTable["ccUIBaseColor" .. toolD.color])
    else
        title:setString("暂未开启")
    end
    title:setColor(UIUtils.colorTable["ccUIBaseTextColor2"])

    -- title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    title:setName("stage")
    title:setPosition(item:getContentSize().width/2,item:getContentSize().height-25)
    item:addChild(title,99)

    local rtxStr = "[color = 865c30] [-]"
    local guildLevel = tab:ShopGuildLimit(index).level
    if guildLevel then
        rtxStr = "[color = 3c3c3c,fontSize = 18]联盟" .. guildLevel .. "级开启[-]"--"[color = 865c30,fontSize = 22]级开启[-]"
    end

    local rtx = RichTextFactory:create(rtxStr,200,40)
    rtx:formatText()
    rtx:setName("rtx")
    local w = rtx:getInnerSize().width
    local h = rtx:getInnerSize().height
    rtx:setPosition(item:getContentSize().width/2+1,20+h/2)
    -- rtx:setScale(0.8)
    item:addChild(rtx)
    UIUtils:alignRichText(rtx)
    -- 置灰显示
    self:setNodeColor(item,cc.c4b(182, 182, 182,255))
end

-- 创建空格子
function ShopView:createGrid(x,y,index )
    if self._grids[index] and not tolua.isnull(self._grids[index]) then
        self._grids[index]:removeFromParent()
    end
    local item 
    item = self._item:clone()
    item:setVisible(true)
    item:setTouchEnabled(false)
    self._grids[index] = item
    local name = item:getChildByFullName("itemName")
    local diamondImg = item:getChildByFullName("diamondImg")
    local discountBg = item:getChildByFullName("discountBg")
    local priceLab = item:getChildByFullName("priceLab")
    local bottomDecorate = item:getChildByFullName("bottomDecorate")
    -- name:setVisible(false)
    diamondImg:setVisible(false)
    discountBg:setVisible(false)
    priceLab:setVisible(false)
    bottomDecorate:setOpacity(0)
    
    name:setString("暂未开启")
    name:setPositionY(158)
    name:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    local posx = item:getContentSize().width*0.5
    local posy = item:getContentSize().height*0.5+2
    local shopGridFrame = ccui.ImageView:create()
    shopGridFrame:loadTexture("globalImageUI4_squality1.png", 1)
    shopGridFrame:setName("shopGridFrame")
    shopGridFrame:setContentSize(98, 98)
    shopGridFrame:setAnchorPoint(0.5,0.5)
    shopGridFrame:setPosition(posx+3,posy+5)
    shopGridFrame:setScale(85/shopGridFrame:getContentSize().width)
    item:addChild(shopGridFrame,2)
    local shopGridBg = ccui.ImageView:create()
    shopGridBg:loadTexture("globalImageUI4_itemBg1.png", 1)
    shopGridBg:setName("shopGridBg")
    shopGridBg:setContentSize(100, 100)
    shopGridBg:setAnchorPoint(0.5,0.5)
    shopGridBg:setPosition(posx+3,posy+5)
    shopGridBg:setScale(80/shopGridBg:getContentSize().width)
    item:addChild(shopGridBg,1)

    local lock = ccui.ImageView:create()
    lock:loadTexture("globalImageUI5_treasureLock.png",1)
    lock:setName("lock")
    lock:setPosition(posx,posy)
    -- lock:setScale(0.85)
    item:addChild(lock,3)
    self._scrollView:addChild(item)
    item:setPosition(x,y)

    -- 置灰显示
    self:setNodeColor(item,cc.c4b(182, 182, 182,255))
end

-- 宝物未开启的格子
local posLimt = {}
for k,v in pairs(tab.shopTreasure) do
    if not posLimt[v.position] then
        posLimt[v.position] = {}
        posLimt[v.position].vipLevel = v.vipLevel
        posLimt[v.position].level = v.level
    end
end
function ShopView:createTreasureGrid(pos,x,y,data )
    if self._grids[pos] and not tolua.isnull(self._grids[pos]) then
        self._grids[pos]:removeFromParent()
    end
    if not tolua.isnull(self._items[pos]) then
        self._items[pos]:setVisible(false)
    end
    local item = ccui.ImageView:create()
    self._grids[pos] = item
    -- item:setCapInsets(cc.rect(60,50,10,10))
    item:loadTexture("globalPanelUI7_cellBg1.png",1)
    item:setContentSize(190,200)
    item:setScale9Enabled(true)
    -- item:setCapInsets(cc.rect(60,50,10,10))

    -- local shopGridFrame = ccui.ImageView:create()
    -- shopGridFrame:loadTexture("globalImageUI4_squality1.png", 1)
    -- shopGridFrame:setName("shopGridFrame")
    -- shopGridFrame:setContentSize(100, 100)
    -- shopGridFrame:setAnchorPoint(0.5,0.5)
    -- shopGridFrame:setPosition(96,103)
    -- shopGridFrame:setScale(0.85)
    -- item:addChild(shopGridFrame,2)
    -- local shopGridBg = ccui.ImageView:create()
    -- shopGridBg:loadTexture("globalImageUI4_itemBg1.png", 1)
    -- shopGridBg:setName("shopGridBg")
    -- shopGridBg:setContentSize(100, 100)
    -- shopGridBg:setAnchorPoint(0.5,0.5)
    -- shopGridBg:setPosition(97,104)
    -- shopGridBg:setScale(0.85)
    -- item:addChild(shopGridBg,1)

    -- 加装饰条
    local decorateImg = self._item:getChildByFullName("bottomDecorate")
    if decorateImg then
        local decImg = decorateImg:clone()
        item:addChild(decImg,0)
        decImg:setPosition(95,33)
    end

    local itemId = tonumber(data.itemId)
    if not itemId then
        itemId = IconUtils.iconIdMap[data.itemId]
    end
    local toolD = tab:Tool(itemId)
    -- if self._nextOpenIdx == pos then
        local num = data.num 
            if num == 1 then 
                num = nil
            end
        local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,effect=true,num = num,eventStyle = 0})
        icon:setContentSize(100, 100)
        icon:setScale(0.9)
        icon:setPosition(item:getContentSize().width/2-42,item:getContentSize().height/2-37)
        item:addChild(icon,2)
    -- end
    

    local lock = ccui.ImageView:create()
    lock:loadTexture("globalImageUI5_treasureLock.png",1)
    lock:setName("lock")
    lock:setPosition(item:getContentSize().width/2-1,item:getContentSize().height/2+2)
    item:addChild(lock,3)
    
    item:setAnchorPoint(0.5,0.5)
    item:setPosition(x,y)
    self._scrollView:addChild(item)
    local low,high
    if posLimt[pos] and posLimt[pos].level then
        low,high = posLimt[pos].level[1],posLimt[pos].level[2]
    end
    
    local vipLevel
    if posLimt[pos] and  posLimt[pos].vipLevel then
        vipLevel = posLimt[pos].vipLevel
    end
    local vip = self._modelMgr:getModel("VipModel"):getData().level or 0
    local lvl = self._modelMgr:getModel("UserModel"):getData().lvl or 0

    local condtion1 = low and vipLevel and (vip >= vipLevel or lvl >= low)
    local condtion2 = low and not vipLevel and (lvl >= low)
    local condtion3 = not low and vipLevel and (vip >= vipLevel)
    if condtion1 or condtion2 or condtion3 then
        self:sendGetShopInfoMsg("treasure")
    end

    local title = ccui.Text:create()
    title:setFontName(UIUtils.ttfName)
    title:setAnchorPoint(0.5,0.5)
    title:setFontSize(20)
    title:setName("stage")
    -- title:setColor(cc.c3b(255, 255, 255))
    title:setPosition(item:getContentSize().width/2,item:getContentSize().height-25)
    title:setFontName(UIUtils.ttfName)
    -- title:setString("未开启")
    -- if self._nextOpenIdx == pos then
        title:setString(lang(toolD.name) or "没有名字")
        -- title:setColor(UIUtils.colorTable["ccUIBaseColor" .. toolD.color])
    -- else
        -- title:setString("暂未开启")
    -- end
    title:setColor(UIUtils.colorTable["ccUIBaseTextColor2"])
    -- title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    item:addChild(title,99)

    -- local openCodition = ccui.Text:create()
    -- openCodition:setFontName(UIUtils.ttfName)
    -- openCodition:setAnchorPoint(0.5,0.5)
    -- openCodition:setFontSize(18)
    -- openCodition:enableOutline(cc.c4b(0, 0, 0, 255),1)
    -- openCodition:setName("stage")
    -- openCodition:setPosition(item:getContentSize().width/2,20)
    -- item:addChild(openCodition,99)

    -- local lvl = self._modelMgr:getModel("UserModel"):getData().lvl
    -- local vip = self._modelMgr:getModel("VipModel"):getData().level
    -- if lvl < low then
    --      openCodition:setString("等级不足")
    -- elseif vip < vipLevel then
    --     openCodition:setString("vip等级不足")  
    -- end
    local rtxStr = "[color = 696969] [-]"
    if low and vipLevel then
        rtxStr = "[color = 3c3c3c,fontSize = 18]" .. low .. "级[-][color = 3c3c3c,fontSize = 18]或[-][color = 3c3c3c,fontSize = 18]VIP" .. vipLevel .. "[-][color = 3c3c3c,fontSize = 18][-]"
    elseif low then
        rtxStr = "[color = 3c3c3c,fontSize = 18]" .. low .. "级[-][color = 3c3c3c,fontSize = 18][-]"
    elseif vipLevel then
        rtxStr = "[color = 3c3c3c,fontSize = 18]VIP" .. vipLevel .. "[-][color = 3c3c3c,fontSize = 18][-]"
    end
    local rtx = RichTextFactory:create(rtxStr,200,40)
    rtx:formatText()
    -- rtx:setVerticalSpace(7)
    rtx:setName("rtx")
    local w = rtx:getInnerSize().width
    local h = rtx:getInnerSize().height
    rtx:setPosition(item:getContentSize().width/2+1,21+h/2)
    -- rtx:setScale(0.8)
    item:addChild(rtx)
    UIUtils:alignRichText(rtx)

    item:setScaleAnim(true)
    self:registerClickEvent(item,function( )
        if not posLimt[pos] then return end
        local vip = self._modelMgr:getModel("VipModel"):getData().level or 0
        local lvl = self._modelMgr:getModel("UserModel"):getData().lvl or 0
        if (low and lvl < low ) and not (vip and vip < vipLevel) then
            self._viewMgr:showTip("等级" .. low .. "开启" )
            return
        end
        if (vip and vip < vipLevel) then
            self._viewMgr:showView("vip.VipView", {viewType = 0})
        end
    end)
    self:setNodeColor(item,cc.c4b(182, 182, 182,255))
end

function ShopView:detectOpenPos( pos )
    local low,high
    if posLimt[pos] and posLimt[pos].level then
        low,high = posLimt[pos].level[1],posLimt[pos].level[2]
    end
    
    local vipLevel
    if posLimt[pos] and  posLimt[pos].vipLevel then
        vipLevel = posLimt[pos].vipLevel
    end
    local vip = self._modelMgr:getModel("VipModel"):getData().level or 0
    local lvl = self._modelMgr:getModel("UserModel"):getData().lvl or 0

    local condtion1 = low and vipLevel and (vip >= vipLevel or lvl >= low)
    local condtion2 = low and not vipLevel and (lvl >= low)
    local condtion3 = not low and vipLevel and (vip >= vipLevel)
    if condtion1 or condtion2 or condtion3 then
        return true
    end

    return false
end

-- 商店在某个活动开启时，刷新有折扣
function ShopView:getActDiscount( actId )
    local actDiscount = self._actModel:getAbilityEffect(self._actModel.PrivilegIDs[actId])
    return 1+actDiscount
end

function ShopView:sendReFreshShopMsg( shopName )
    shopName = shopName or shopIdx[self._idx or 1]
    self._idx = self._idx or 1
    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local lastUpTime = self._shopModel:getShopByType(shopIdx[self._idx]).lastUpTime
    -- if math.abs(curTime - lastUpTime) < 1 then
    --     self._viewMgr:showTip("刷新太频繁，请稍后再试！")
    --     return 
    -- end
    -- 刷新限制 只有宝物商店有限制
    local vip = self._modelMgr:getModel("VipModel"):getData().level or 0
    local vipLimt = tab.vip[vip].refleshTreasure
    local shopReflashData = self._shopModel:getShopByType("treasure")
    if shopReflashData then
        local times = shopReflashData.reflashTimes or 0
        times = times+1
        if times > #tab.reflashCost then
            times = #tab.reflashCost
        end
        if times > vipLimt and shopName == "treasure" then
            if vip < #tab.vip then
                -- self._viewMgr:showTip(lang("REFRESH_TREASURE_SHOP"))
                DialogUtils.showNeedCharge({desc = lang("REFRESH_TREASURE_SHOP"),callback1=function( )
                    local viewMgr = ViewManager:getInstance()
                    viewMgr:showView("vip.VipView", {viewType = 1})
                end})
            else
                self._viewMgr:showTip(lang("REFRESH_TREASURE_SHOP_MAX"))
            end
            return 
        end
    end
    
    self._refreshAnim = true
    -- ScheduleMgr:delayCall(1500, self, function( )
    --     self._refreshAnim = nil
    -- end)
    local player = self._modelMgr:getModel("UserModel"):getData()
    local cost,costType = self._shopModel:getRefreshCost( shopIdx[self._idx] )
    local haveNum = player[costType] or 0
    local times = self._shopModel:getShopByType(shopIdx[self._idx]).reflashTimes or 0
    times = times+1
    if times > #tab.reflashCost then
        times = #tab.reflashCost
    end
    if shopName == "honorArena" then
        local vipData = tab.vip[vip] or {}
        local vipLimt = vipData.refreshShopHa
        if vipLimt and times and times > vipLimt then
            if vip < #tab.vip then
                -- self._viewMgr:showTip(lang("REFRESH_TREASURE_SHOP"))
                DialogUtils.showNeedCharge({desc = lang("REFRESH_TREASURE_SHOP"),callback1=function( )
                    local viewMgr = ViewManager:getInstance()
                    viewMgr:showView("vip.VipView", {})
                end})
            else
                self._viewMgr:showTip(lang("REFRESH_TREASURE_SHOP_MAX"))
            end
            return 
        end
    end
    local privilgeNum = self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_10)
    local hadUse = self._modelMgr:getModel("PlayerTodayModel"):getData().day11 or 0
    local isFree = privilgeNum > hadUse and self._idx == 1
    -- tab:ReflashCost(times)[shopTableIdx[self._idxx]]
    -- if type(cost) == "table" then
    --     costType = cost[1]
    --     cost = cost[3]
    -- end
    if not isFree and cost > haveNum then
        -- local costName = lang("TOOL_" .. IconUtils.iconIdMap[costType])
        if costType == "gem" then
            DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_" .. string.upper(costType)),callback1=function( )
                local viewMgr = ViewManager:getInstance()
                viewMgr:showView("vip.VipView", {viewType = 0})
            end})
        else
            if costType == "guildCoin" then
                self._viewMgr:showTip("联盟币不足")
            elseif costType == "planeCoin" then
                self._viewMgr:showTip(lang("TIPS_AWARDS_05"))
            elseif costType == "honorCertificate" then
                self._viewMgr:showTip("荣耀之证不足")
            else
                self._viewMgr:showTip(lang("TIP_GLOBAL_LACK_" .. string.upper(costType)) or "缺少资源")
            end
        end
        self._refreshAnim = nil
        return 
    else
        local function sendReFlashMsg(  )
            audioMgr:playSound("Reflash")
            self._serverMgr:sendMsg("ShopServer", "reflashShop", {type = shopIdx[self._idx]}, true, {}, function(result)
                -- 限制频繁刷新 
                -- local privilgeNum = self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_10)
                -- local hadUse = self._modelMgr:getModel("PlayerTodayModel"):getData().day11 or 0
                -- if shopName == "mystery" and privilgeNum > 0 and privilgeNum > hadUse then
                --     self._costImg:loadTexture(IconUtils.resImgMap["privilege"],1)
                --     -- self._costImg:setPositionX(self._costImgInitPos-30)
                --     self._refreshTimeLab:setString("免费（".. (privilgeNum-hadUse) .."）")
                --     self._refreshTimeLab:setAnchorPoint(1,0.5)
                --     self._refreshTimeLab:setPositionX(self._refreshTimeLabPos+40)
                --     self._costImg:setPositionX(self._refreshTimeLab:getPositionX() - self._refreshTimeLab:getContentSize().width)
                --     self._refreshTimeLab:setColor(cc.c3b(5, 255, 16))
                -- else
                --     self._costImg:loadTexture(IconUtils.resImgMap["gem"],1)
                --     -- self._costImg:setPositionX(self._costImgInitPos)
                --     local refreshTimes = self._shopModel:getRefreshCost(shopIdx[self._idx])
                --     self._refreshTimeLab:setString(refreshTimes)
                --     self._costImg:setPositionX(self._costImgInitPos)
                --     self._refreshTimeLab:setAnchorPoint(0.5,0.5)
                --     self._refreshTimeLab:setPositionX(self._refreshTimeLabPos)
                --     self._refreshTimeLab:setColor(cc.c3b(255, 255, 255))
                -- end
            end)
        end
        if isFree then
            sendReFlashMsg( )
        else
            DialogUtils.showBuyDialog({costNum = cost,costType = costType,goods = "刷新一次",callback1 = function( )      
                sendReFlashMsg(  )
            end})
        end
        if not self._isBuyBack then
            self._offsetY = nil
        else
            self._isBuyBack = false
        end 
    end
    
end

function ShopView:sendGetShopInfoMsg( shopName )
    self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = shopName}, true, {}, function(result)
        if result.shop[shopIdx[self._idx]] and  
            result.shop[shopIdx[self._idx]].lastUpTime and 
            result.shop[shopIdx[self._idx]].lastUpTime > self._nextRefreshTime then 
            self._nextRefreshTime = self._shopModel:getShopRefreshTime(shopIdx[self._idx])
        end
    end)
end

-- 灰态
function ShopView:setNodeColor( node,color,notDark )
    -- if true then return end
    if node and not tolua.isnull(node) and node:getName() ~= "lock" then 
        if node:getDescription() ~= "Label" then
            node:setColor(color)
        else
            if not notDark then
                node:setBrightness(-50)
            else
                node:setBrightness(0)
            end
        end
    end
    local children = node:getChildren()
    if children == nil or #children == 0 then
        return 
    end
    for k,v in pairs(children) do
        self:setNodeColor(v,color,notDark)
    end
end

-- 处理切入后台
function ShopView:applicationDidEnterBackground()

end

function ShopView:applicationWillEnterForeground(second)
    if self._idx and self._shopModel then 
        self._shopModel:setData({})
        self:sendGetShopInfoMsg(shopIdx[self._idx])
        self:touchTab(self._idx)
    end
end

function ShopView:onDestroy()
    --[[
    -- 清除倒计时
    for k,v in pairs(self._layerTb) do
        
    end
    --]]
    if self._layerTb[6] then
        -- self._layerTb[6]:unRegTimer()
        if self._layerTb[6]._resumetimer then
            ScheduleMgr:unregSchedule(self._layerTb[6]._resumetimer)
            self._layerTb[6]._resumetimer = nil
        end
    end
    self.super.onDestroy(self)
end

return ShopView