
--[[
    Filename:    FlashCardView.lua
    Author:      <libolong@playcrab.com>
    Datetime:    2015-04-29 15:22:09
    Description: File description
--]]
local isLuckyCoin = false
local rightCostType = isLuckyCoin and "luckyCoin" or "gem"
local navigationRes = isLuckyCoin and {"LuckyCoin","Gem","Gold"} or {"Physcal","Gold","Gem"}
-- 静态全局数据
local discountSingle = tab:Setting("G_DISCOUNT_FIRST_SINGLE_DRAW").value
local discountTen = tab:Setting("G_DISCOUNT_TENTIMES_DRAW").value

local toolSingle = tab:Setting("G_DRAWCOST_TOOL_SINGLE").value[3]
local toolTen = tab:Setting("G_DRAWCOST_TOOL_TENTIMES").value[3]
local gemSingle = tab:Setting("G_DRAWCOST_GEM_SINGLE").value[3]
local gemTen = tab:Setting("G_DRAWCOST_GEM_TENTIMES").value[3]
local gemFreeCD = tab:Setting("G_FREECD_DRAW_GEM_SINGLE").value -- 转换成秒数
local toolFreeCD = tab:Setting("G_FREECD_DRAW_TOOL_SINGLE").value -- 转换成秒数
local toolFreeNum = tab:Setting("G_FREENUM_DRAW_TOOL_SINGLE").value

local FlashCardView = class("FlashCardView", BaseView)

function FlashCardView:ctor()
    FlashCardView.super.ctor(self)
    self.fixMaxWidth = ADOPT_IPHONEX and 1136 or nil 
    self._free = false
    self._mcs = {}
    -- 重新设置消耗类型
    isLuckyCoin = self._modelMgr:getModel("UserModel"):drawUseLuckyCoin()
    rightCostType = isLuckyCoin and "luckyCoin" or "gem"
    navigationRes = isLuckyCoin and {"LuckyCoin","Gem","Gold"} or {"Physcal","Gold","Gem"}
end

-- function FlashCardView:getBgName(  )
--     return "bg_001.jpg"
-- end

function FlashCardView:setNavigation()
    if self._inBuyScene then
        self._viewMgr:showNavigation("global.UserInfoView",{types= navigationRes,hideBtn = true,hideInfo=true}, nil, ADOPT_IPHONEX and self.fixMaxWidth or nil)
    else
        self._viewMgr:showNavigation("global.UserInfoView",{types= navigationRes,hideHead = true}, nil, ADOPT_IPHONEX and self.fixMaxWidth or nil)
    end
end
function FlashCardView:getAsyncRes()
    return 
    {
        {"asset/ui/flashCard.plist", "asset/ui/flashCard.png"},
        {"asset/ui/flashCard1.plist", "asset/ui/flashCard1.png"},
        {"asset/ui/flashCard3.plist", "asset/ui/flashCard3.png"},
        {"asset/anim/flashcardanimimage.plist", "asset/anim/flashcardanimimage.png"},
        {"asset/anim/flashcardgoumaishiciimage.plist", "asset/anim/flashcardgoumaishiciimage.png"},
        -- {"asset/anim/flashcarddingguangimage.plist", "asset/anim/flashcarddingguangimage.png"},
    }
end
function FlashCardView:onHide()
    self._viewMgr:disableScreenWidthBar()
    if self._updateTime then
        ScheduleMgr:unregSchedule(self._updateTime)
    end
    self._updateTime = nil
    if self._bgSchedule then
        ScheduleMgr:unregSchedule(self._bgSchedule)
    end
    -- self:destroyAct()
end

function FlashCardView:onTop( )
    self._viewMgr:enableScreenWidthBar()
    local yun1 = self._bg:getChildByFullName("yun1")
    local yun2 = self._bg:getChildByFullName("yun2")
    if not self._bgSchedule and yun1 then
        self._yunSpeed = 1
        local yunWidth = yun1:getContentSize().width
        self._bgSchedule = ScheduleMgr:regSchedule(10,self,function( )
            self:scrollBg()
        end)
    end
    self:isGemDrawFree()
    self:isToolDrawFree()
end
function FlashCardView:onComplete()
    self._viewMgr:enableScreenWidthBar()
end
function FlashCardView:onInit()
    self._preBGMName = audioMgr:getMusicFileName()
    audioMgr:playMusic("SaintHeaven", true)
    -- self:initActions() -- 初始化各种action

    self._bg = self:getUI("bg")
    self._bg0 = self:getUI("bg.bg0")
    self._bg1 = self:getUI("bg.bg1")
    self._bg2 = self:getUI("bg.bg2")
    self._bg3 = self:getUI("bg.bg3")
    self:initBg()

    self._returnBtn = self:getUI("returnBtn")
    self._returnBtn:setVisible(false)
    self:registerClickEventByName("returnBtn",function( )
        if not self._inBuyScene then
            self:close()
        else
            if not self._inBounce then
                self._isBounceLock = true
                self:lock(-1)
                self:bgBounceDown()
                -- self._gemLayer:setScale(1)
                -- self._toolLayer:setScale(1)
            end
        end
    end)
    self._showCangetBtn = self:getUI("showCangetBtn")
    self._showCangetBtn:setScale(0.9)
    self._showCangetBtn:setVisible(false)
    self:registerClickEventByName("showCangetBtn",function( )
        self._viewMgr:showDialog("flashcard.DialogFlashPreView",{tp = self._costType},nil,nil,nil,true)
    end)
    -- self._lockView = self:getUI("lockView")
    -- self._lockView:setSwallowTouches(false)
    self._toolBtnLayer = self:getUI("bg.toolBtnLayer")
    self._toolBtnLayer:setVisible(false)
    self._gemBtnLayer = self:getUI("bg.gemBtnLayer")
    self._gemBtnLayer:setVisible(false)
    self._gemBar = self:getUI("gemBar")
    self._gemBar:setVisible(false)
    self._toolBar = self:getUI("toolBar")
    self._toolBar:setVisible(false)
    self._toolLayer = self:getUI("bg.toolLayer")
    self._toolLayer:setCascadeOpacityEnabled(true,true)
    -- self._toolTitle = self:getUI("bg.toolTitle")    
    self._toolLayer:setCascadeOpacityEnabled(true)

-- 钻石抽卡 金钥匙的数量显示
    local _,haveKeyNum = self._modelMgr:getModel("ItemModel"):getItemsById(3041)
    self._goldKeyNum = self._gemBar:getChildByFullName("goldKeyNum")    
    self._keyImg = self._gemBar:getChildByFullName("goldKey")
    self._keyBg = self._gemBar:getChildByFullName("goldKeyBg")
    self._goldKeyNum:setString(haveKeyNum)
    if haveKeyNum <= 0 then
        self._keyImg:setVisible(false)
        self._keyBg:setVisible(false)
        self._goldKeyNum:setVisible(false)
    end

    self:registerClickEventByName("bg.toolLayer",function( )
        if self._toolLayer:isVisible() then
            self._gemBtnLayer:setVisible(false)
            self._isBounceLock = true
            self:lock(-1)
            self._costType = "tool"
            -- self:setNodeBrightNess(self._toolLayer)
            self._toolLayer:setBrightness(40)
            ScheduleMgr:delayCall(150, self, function( )
                if not self._toolBtnLayer then return end
                self._toolBtnLayer:setOpacity(0)
                local children = self._toolBtnLayer:getChildren()
                for k,v in pairs(children) do
                    v:setOpacity(0)
                    local children1 = v:getChildren()
                    if #children1 > 0 then
                         for k1,v1 in pairs(children1) do
                            v1:setOpacity(0)
                        end
                    end
                end
                self._toolLayer:setBrightness(0)
                self:bgBounceUp()
                -- self:addAnimation2Node("shanguang_flashcardanim",self._bg,{zOrder = 99,endCallback = function( sender )
                --     sender:removeFromParent()
                -- end})   
            end)
        end
    end)
    -- local title1 = self:getUI("bg.toolLayer.title")
    -- title1:setFontName(UIUtils.ttfName)
    -- title1:setFontSize(26)
    -- title1:setColor(cc.c3b(117, 174, 253))
    -- title1:enable2Color(1, cc.c4b(207, 233, 248, 255))
    -- title1:enableOutline(cc.c4b(1, 28, 115, 255), 2)
    -- title1:setString("小瓶经验药水")
    -- local title2 = self:getUI("bg.gemLayer.title")
    -- title2:setFontName(UIUtils.ttfName)
    -- title2:setFontSize(26)
    -- title2:setColor(cc.c3b(254, 197, 48))
    -- title2:enable2Color(1, cc.c4b(251, 253, 46, 255))
    -- title2:enableOutline(cc.c4b(96, 36, 0, 255), 2)
    -- title2:setString("大瓶经验药水")

    self._gemLayer = self:getUI("bg.gemLayer")
    self._gemLayer:setCascadeOpacityEnabled(true,true)
    -- self._gemTitle = self:getUI("bg.gemTitle")
    self:registerClickEventByName("bg.gemLayer",function( )
        if self._gemLayer:isVisible() then
            self._toolBtnLayer:setVisible(false)
            self._isBounceLock = true
            self:lock(-1)
            self._costType = rightCostType
            self._gemLayer:setBrightness(40)
            ScheduleMgr:delayCall(150, self, function( )
                if not self._gemBtnLayer then return end
                self._gemBtnLayer:setOpacity(0)
                local children = self._gemBtnLayer:getChildren()
                for k,v in pairs(children) do
                    v:setOpacity(0)
                    local children1 = v:getChildren()
                    if #children1 > 0 then
                         for k1,v1 in pairs(children1) do
                            v1:setOpacity(0)
                        end
                    end
                end
                self._gemLayer:setBrightness(0)
                self:bgBounceUp()
                -- self:addAnimation2Node("shanguang_flashcardanim",self._bg,{zOrder = 99,endCallback = function( sender )
                --     sender:removeFromParent()
                -- end})   
            end)
        end
    end)

    self._buyNum = 1
    self._buyAginFunc = nil
    self:registerClickEventByName("bg.toolBtnLayer.buyOneBtn", function ()
        if self._inBounce then return end
        self._costType = "tool"
        self:buyOneByTool()
        self._buyAginFunc = function( )
            self:buyOneByTool()
        end
        -- self._toolBtnLayer:setVisible(false)
    end)

    self:registerClickEventByName("bg.toolBtnLayer.buyTenBtn", function ()
        if self._inBounce then return end
        self._costType = "tool"
        self:buyTenByTool()
        self._buyAginFunc = function( )
            self:buyTenByTool()
        end
        -- self._toolBtnLayer:setVisible(false)
    end)

    self:registerClickEventByName("bg.gemBtnLayer.buyOneBtn", function ()
        if self._inBounce then return end
        local player = self._modelMgr:getModel("UserModel"):getData()
        local gem = player[rightCostType] or 0
        local gemCost = gemSingle
        local gemDiscountLab = self._gOneCost:getChildByFullName("greenText")
        local disCountGem
        if gemDiscountLab and gemDiscountLab:isVisible() then
            disCountGem =  tonumber(gemDiscountLab:getString())
        end
        local costLabStrNum = disCountGem or tonumber(self._gOneCost:getString())
        if costLabStrNum and costLabStrNum < gemSingle then
            gemCost = costLabStrNum
        end
        local _,haveKeyNum = self._modelMgr:getModel("ItemModel"):getItemsById(3041)
        -- local num = self._modelMgr:getModel("PlayerTodayModel"):getData().day1
        local free ,disCountNum = self:isGemDrawFree()
        -- print(free,haveKeyNum,disCountNum,"==============================day1====,",day1)
        if (haveKeyNum > 0 and not disCountNum) or (gem >= gemCost or free) then
            self._costType = rightCostType
            -- self._bg:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function( )
            self:buyOneByGem()
            self._buyAginFunc = function( )
                self:buyOneByGem()
            end
            -- end)))
            -- self._gemBtnLayer:setVisible(false)
        else
            -- DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_LUCKYCOIN"),button1 = "前往",title = "幸运币不足",callback1=function( )
            --     DialogUtils.showBuyRes({goalType = "luckyCoin",inputNum = gemCost-gem })
            -- end})
            self:showNeedCharge(gemCost-gem)
        end
    end)

    self:registerClickEventByName("bg.gemBtnLayer.buyTenBtn", function ()
        if self._inBounce then return end
        local player = self._modelMgr:getModel("UserModel"):getData()
        local gem = player[rightCostType] or 0
        local _,haveKeyNum = self._modelMgr:getModel("ItemModel"):getItemsById(3041)
        -- print("===========================haveKeyNum======",haveKeyNum)
        if haveKeyNum <= 0 and gem < gemTen*discountTen then
            -- DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_LUCKYCOIN"),button1 = "前往",title = "幸运币不足",callback1=function( )
            --     -- local viewMgr = ViewManager:getInstance()
            --     -- viewMgr:showView("vip.VipView", {viewType = 0})
            --     DialogUtils.showBuyRes({goalType = "luckyCoin",inputNum = gemTen*discountTen-gem})
            -- end})
            self:showNeedCharge(gemTen*discountTen-gem)
            return 
        end
        self._costType = rightCostType
        -- self._bg:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function( )
        self:buyTenByGem()
        self._buyAginFunc = function( )
            self:buyTenByGem()
        end
        -- end)))
        -- self._gemBtnLayer:setVisible(false)
    end)

    self._playerDayModel = self._modelMgr:getModel("PlayerTodayModel")
    --按钮
    local gOneBtn = self:getUI("bg.gemBtnLayer.buyOneBtn")
    gOneBtn:setTitleFontSize(28)
    gOneBtn:setTitleColor(cc.c4b(255, 251, 237, 255))
    gOneBtn:getTitleRenderer():enable2Color(1,cc.c4b(252, 222, 153, 255))
    gOneBtn:getTitleRenderer():enableOutline(cc.c4b(61, 24, 0, 255), 2)
    self._gOneBtn = gOneBtn

    local gTenBtn = self:getUI("bg.gemBtnLayer.buyTenBtn")
    gTenBtn:setTitleFontSize(28)
    gTenBtn:setTitleColor(cc.c4b(255, 251, 237, 255))
    gTenBtn:getTitleRenderer():enable2Color(1,cc.c4b(252, 222, 153, 255))
    gTenBtn:getTitleRenderer():enableOutline(cc.c4b(61, 24, 0, 255), 2)
    self._gTenBtn = gTenBtn

    gTenBtn:setCascadeOpacityEnabled(true)

    local discountTag = ccui.ImageView:create()
    discountTag:loadTexture("globalImageUI6_connerTag_r.png",1)
    discountTag:setName("discountTag")
    discountTag:setAnchorPoint(cc.p(1,1))
    discountTag:setScale(0.9)
    discountTag:setPosition(gTenBtn:getContentSize().width-25,gTenBtn:getContentSize().height)
    discountTag:setCascadeOpacityEnabled(true)
    discountTag:setOpacity(0)

    local discountName = ccui.Text:create()
    discountName:setString("超值")
    discountName:setFontSize(22)
    discountName:setFontName(UIUtils.ttfName)
    discountName:setColor(cc.c3b(255, 255, 255))
    discountName:enableOutline(cc.c4b(146,19,5,255),3)
    discountName:setRotation(41)
    discountName:setPosition(44,36)
    discountTag:addChild(discountName)
    discountTag:setScale(0.9)
    gTenBtn:addChild(discountTag,9)

    local tOneBtn = self:getUI("bg.toolBtnLayer.buyOneBtn")
    tOneBtn:setTitleFontSize(28)
    tOneBtn:setTitleColor(cc.c4b(255, 251, 237, 255))
    tOneBtn:getTitleRenderer():enable2Color(1,cc.c4b(252, 222, 153, 255))
    tOneBtn:getTitleRenderer():enableOutline(cc.c4b(61, 24, 0, 255), 2)
    self._tOneBtn = tOneBtn

    local tTenBtn = self:getUI("bg.toolBtnLayer.buyTenBtn")
    tTenBtn:setTitleFontSize(28)
    tTenBtn:setTitleColor(cc.c4b(255, 251, 237, 255))
    tTenBtn:getTitleRenderer():enable2Color(1,cc.c4b(252, 222, 153, 255))
    tTenBtn:getTitleRenderer():enableOutline(cc.c4b(61, 24, 0, 255), 2)
    self._tTenBtn = tTenBtn

    -- 换按钮 by guojun 
    tOneBtn:loadTextures("flashcard_btn1.png","flashcard_btn1.png","flashcard_btn1.png",1)
    tOneBtn:setTitleText("")
    tTenBtn:loadTextures("flashcard_btn2.png","flashcard_btn2.png","flashcard_btn2.png",1)
    tTenBtn:setTitleText("")
    gOneBtn:loadTextures("flashcard_btn1.png","flashcard_btn1.png","flashcard_btn1.png",1)
    gOneBtn:setTitleText("")
    gTenBtn:loadTextures("flashcard_btn2.png","flashcard_btn2.png","flashcard_btn2.png",1)
    gTenBtn:setTitleText("")
    local gAnimImg = self:getUI("bg.gemBtnLayer.buyTenBtn.animImg")
    gAnimImg:loadTexture("flashcard_btn2.png",1)
    gAnimImg:setPosition(94,37)
    local tAnimImg = self:getUI("bg.toolBtnLayer.buyTenBtn.animImg")
    tAnimImg:loadTexture("flashcard_btn2.png",1)
    tAnimImg:setPosition(94,37)


    -- 首次进入展示
    self._tTimeLab = self:getUI("bg.toolLayer.timeLab")
    -- self._tTimeLab:setFontSize(22)
    self._tTimeDes = self:getUI("bg.toolLayer.timeDes")
    self._tCost = self:getUI("bg.toolLayer.cost")
    self._tCost:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._tOneCost = self:getUI("bg.toolBtnLayer.buyOneCostLayer.cost")
    self._tOneCost:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._tOneCost:setFontName(UIUtils.ttfName)
    self._tBtnTimeLab = self:getUI("bg.toolBtnLayer.buyOneCostLayer.timeLab")
    self._tBtnTimeLab:setVisible(true)
    self._tTenCost = self:getUI("bg.toolBtnLayer.buyTenCostLayer.cost")
    self._tTenCost:setFontName(UIUtils.ttfName)
    self._tTenCost:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._tDot = self:getUI("bg.toolLayer.dot")
    self._tDot:setZOrder(100)
    self._tBoardW = self._toolLayer:getContentSize().width
    -- self._tTimeLab:setString("00:10:00后免费")
    self._tOneCost:setString(toolSingle)
    self._tTenCost:setString(toolTen)
    
    self._gOneBtn = self:getUI("bg.gemBtnLayer.buyOneBtn")
    self._gTimeLab = self:getUI("bg.gemLayer.timeLab")
    self._gTimeDes = self:getUI("bg.gemLayer.timeDes")

    self._gCost = self:getUI("bg.gemLayer.cost")
    self._gCostImg = self:getUI("bg.gemLayer.diamond_img")

    self._gOneCost = self:getUI("bg.gemBtnLayer.buyOneCostLayer.cost")
    self._gOneCostImg = self:getUI("bg.gemBtnLayer.buyOneCostLayer.Image_29")
    self._gOneCost:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._gOneCost:setFontName(UIUtils.ttfName)

    self._gBtnTimeLab = self:getUI("bg.gemBtnLayer.buyOneCostLayer.timeLab")
    self._gBtnTimeLab:setVisible(true)
    self._gBtnTimeLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

    self._gTenCost = self:getUI("bg.gemBtnLayer.buyTenCostLayer.cost")
    self._gTenCostImg = self:getUI("bg.gemBtnLayer.buyTenCostLayer.Image_30")
    self._gTenCost:setFontName(UIUtils.ttfName)
    self._gTenCost:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

    self._gDot = self:getUI("bg.gemLayer.dot")
    self._gDot:setZOrder(100)
    self._gTimeLabInitPos = cc.p(self._gTimeLab:getPositionX(),self._gTimeLab:getPositionY())
    self._gTimeDesInitPos = cc.p(self._gTimeDes:getPositionX(),self._gTimeDes:getPositionY())

    self._gTimeLabC = self._gTimeLab:clone()
    self._gTimeLabC:setPosition(self._gTimeLabInitPos.x,self._gTimeLabInitPos.y+10)
    self._gTimeDesC = self._gTimeDes:clone()
    self._gTimeDesC:setPosition(self._gTimeDesInitPos.x,self._gTimeDesInitPos.y+10)

    self._gemLayer:addChild(self._gTimeLabC)
    self._gemLayer:addChild(self._gTimeDesC)

    self._gBoardW = self._gemLayer:getContentSize().width
    -- self._gTimeLab:setString("00:10:00后免费")
    self._gOneCost:setString(gemSingle)
    self._gTenCost:setString(math.ceil(gemTen*discountTen))

    -- 特殊处理
    local gemDiscountLab = ccui.Text:create()
    gemDiscountLab:setFontName(UIUtils.ttfName)
    gemDiscountLab:setName("greenText")
    gemDiscountLab:setFontSize(self._gOneCost:getFontSize())
    self._gOneCost:addChild(gemDiscountLab)

    local drawNode = cc.DrawNode:create()
    self._gbtnDraw = drawNode
    self:getUI("bg.gemBtnLayer.buyOneCostLayer"):addChild(drawNode,999)
    
    self._toolFree = false
    self._teamFree = false
    self:isToolDrawFree()
    self:isGemDrawFree()
    self:refreshTime()
    self:reflashTimeLabel()

    -- toolBar 抽卡道具
    local toolLab = self._toolBar:getChildByFullName("toolLab")
    local _,count = self._modelMgr:getModel("ItemModel"):getItemsById(3001)
    toolLab:setString(count)
    self:listenReflash("ItemModel", function( )
        local _,count = self._modelMgr:getModel("ItemModel"):getItemsById(3001)
        toolLab:setString(ItemUtils.formatItemCount(count))
    end)
    -- gemBar 砖石条数据
    local gemLab = self._gemBar:getChildByFullName("gemLab")
    local buyGemBtn = self._gemBar:getChildByFullName("buyGemBtn")
    self._buyGemBtn = buyGemBtn
    self:registerClickEvent(buyGemBtn,function( )
        DialogUtils.showBuyRes({goalType = "gem"})
    end)
    
    -- +2 功能 幸运币
    local luckyLab = self._gemBar:getChildByFullName("luckyLab")
    local buyLuckyBtn = self._gemBar:getChildByFullName("buyLuckyBtn")
    self._buyLuckyBtn = buyLuckyBtn
    self:registerClickEvent(buyLuckyBtn,function( )
        DialogUtils.showBuyRes({goalType = "luckyCoin"})
    end)

    gemLab:setString(ItemUtils.formatItemCount(self._modelMgr:getModel("UserModel"):getData().gem))
    self:listenReflash("UserModel", function( )
        gemLab:setString(ItemUtils.formatItemCount(self._modelMgr:getModel("UserModel"):getData().gem))
        if isLuckyCoin and luckyLab then
            luckyLab:setString(ItemUtils.formatItemCount(self._modelMgr:getModel("UserModel"):getData().luckyCoin or 0))
        end
        self:isGemDrawFree()
        local _,toolHaveNum = self._modelMgr:getModel("ItemModel"):getItemsById(3041)
        self._goldKeyNum:setString(toolHaveNum)
    end)

    -- 不使用幸运币则隐藏
    if not isLuckyCoin then
        local hideMap = {"luckyLab","buyLuckyBtn","lukyIcon","lukyBg"}
        for _,name in pairs(hideMap) do
            local node = self._gemBar:getChildByFullName(name)
            if node then node:removeFromParent() end
        end
        local goldMap = {goldKeyNum = 250,goldKey = 180,goldKeyBg = 250}
        for name,posX in pairs(goldMap) do
            local node = self._gemBar:getChildByFullName(name)
            if node then node:setPositionX(posX) end
        end
    else
        -- +2 功能 幸运币
        local luckyLab = self._gemBar:getChildByFullName("luckyLab")
        local buyLuckyBtn = self._gemBar:getChildByFullName("buyLuckyBtn")
        self._buyLuckyBtn = buyLuckyBtn
        self:registerClickEvent(buyLuckyBtn,function( )
            DialogUtils.showBuyRes({goalType = "luckyCoin"})
        end)

        luckyLab:setString(ItemUtils.formatItemCount(self._modelMgr:getModel("UserModel"):getData().luckyCoin or 0))
    end
    
    -- 增加动画
    -- self:addAnimation2Node("zuoka_flashcarduianim",self._toolLayer,{offsetx = -44,offsety = 82,scale =0.95})
    self:addAnimation2Node("youguangxiao_flashcarduianim",self._gemLayer,{zOrder = -1,offsetx = 0,offsety = 100,scale =0.95,delayTime=7})
    self:addAnimation2Node("zitiguangxiao_flashcarduianim",self._toolLayer,{offsetx = -20,offsety = -120})
    self:addAnimation2Node("zitiguangxiao_flashcarduianim",self._gemLayer,{zOrder = 10,offsetx = -20,offsety = -120})
    self:addAnimation2Node("anniuguangxiao_tongyonganniu",self:getUI("bg.gemBtnLayer.buyTenBtn.animImg"),{zOrder = 10,offsetx = 0,offsety = 0})
    -- self:addMcWithMask(self:getUI("bg.gemBtnLayer.buyTenBtn.animImg"),"buytenmask1_flashcard.png","saoguang1_flashcardgoumaishici",{scale={0.9,0.85},x=94,y=40})
    -- self:addMcWithMask(self:getUI("bg.gemBtnLayer.buyTenBtn.animImg"),"buytenmask2_flashcard.png","saoguang2_flashcardgoumaishici",{scale={0.9,0.85},x=94,y=40})
    
    self:addAnimation2Node("anniuguangxiao_tongyonganniu",self:getUI("bg.toolBtnLayer.buyTenBtn.animImg"),{zOrder = 10,offsetx = 0,offsety = 0})
    -- self:addMcWithMask(self:getUI("bg.toolBtnLayer.buyTenBtn.animImg"),"buytenmask1_flashcard.png","saoguang1_flashcardgoumaishici")
    -- self:addMcWithMask(self:getUI("bg.toolBtnLayer.buyTenBtn.animImg"),"buytenmask2_flashcard.png","saoguang2_flashcardgoumaishici")
    self._baoxiangdingguangMc = self:addAnimation2Node("dingguang_flashcarddingguang",self._bg,{zOrder = 3,offsetx = 0,offsety = MAX_SCREEN_HEIGHT/2-320,notLoop=true})
    self._baoxiangdingguangMc:stop()
    self._baoxiangdingguangMc:setVisible(false)
    self:registerTimer(5,0,0,function(  )
        
    end)

    -- 重置节点order
    local tRoleImg = self._toolLayer:getChildByName("roleImg")
    -- self._toolLayer:reorderChild(tRoleImg, -1)
    -- self._toolLayer:setScale(0.95)
    -- local gRoleImg = self._gemLayer:getChildByName("roleImg")
    -- self._gemLayer:reorderChild(gRoleImg, -2)
    -- self._gemLayer:setScale(0.95)

    -- 新宝箱光
    self._jinMc = self:addAnimation2Node("jinbaoxiang_flashcardjinse",self._bg,{offsety = 120})
    self._jinMc:gotoAndStop(0)
    -- self._jinMc:setScale(0.75)
    self._jinMc:setVisible(false)
    self._jinMc:setCascadeOpacityEnabled(true,true)
    local starJinMc = self:addAnimation2Node("baoxiangchangtai_flashcardjinbaoxiangtexiao",self._jinMc,{offsety = 0,zOrder = -99})
    -- starJinMc:gotoAndStop(0)
    -- starJinMc:setVisible(false)
    starJinMc:setCascadeOpacityEnabled(true,true)
    self._starJinMc = starJinMc

    -- 金宝箱开箱一帧是单出的
    self._jinOpenMc = self:addAnimation2Node("jinbaoxiangdakai_flashcardjinbaoxiangtexiao",self._bg,{offsety = 50})
    self._jinOpenMc:gotoAndStop(0)
    -- self._jinOpenMc:setScale(0.75)
    self._jinOpenMc:setVisible(false)
    self._jinOpenMc:setCascadeOpacityEnabled(true,true)
    -- 速度线
    self._jinSpeedMc = self:addAnimation2Node("jinbanxiangtexiao_flashcardjinbaoxiangtexiao",self._bg,{offsetx=-20,offsety = 90})
    self._jinSpeedMc:gotoAndStop(0)
    -- self._jinSpeedMc:setScale(0.75)
    self._jinSpeedMc:setVisible(false)
    self._jinSpeedMc:setCascadeOpacityEnabled(true,true)
    

    -- 银宝箱

    self._yinMc = self:addAnimation2Node("yinbaoxiang_flashcardyinse",self._bg,{offsety = 100})
    self._yinMc:gotoAndStop(0)
    self._yinMc:setPlaySpeed(1.5)
    self._yinMc:setVisible(false)
    self._yinMc:setCascadeOpacityEnabled(true,true)

    local starYinMc = self:addAnimation2Node("baoxiangchangtai_flashcardjinbaoxiangtexiao",self._yinMc,{offsety = 0,zOrder = -99})
    -- starYinMc:gotoAndStop(0)
    -- starYinMc:setVisible(false)
    starYinMc:setHue(-120)
    starYinMc:setCascadeOpacityEnabled(true,true)
    self._starYinMc = starYinMc
    -- 
end

function FlashCardView:addMcWithMask( node,maskName,mcName,param )
    param = param or {}
    local x,y = param.x or node:getContentSize().width/2,param.y or node:getContentSize().height/2
    local mcx,mcy = param.offsetx or 0,param.offsety or 0
    local scale = param.scale or 1
    local clipNode = cc.ClippingNode:create()
    if type(scale) == "number" then
        clipNode:setScale(scale)
    elseif type(scale) == "table" then
        clipNode:setScale(unpack(scale))
    end

    clipNode:setPosition(x or 90,y or 42)
    clipNode:setContentSize(cc.size(109, 114))
    local mask = cc.Sprite:createWithSpriteFrameName(maskName)
    mask:setAnchorPoint(0.5,0.5)
    clipNode:setStencil(mask)
    clipNode:setAlphaThreshold(0.05)
    -- clipNode:setInverted(true)
    clipNode:setCascadeOpacityEnabled(true)

    local mc = mcMgr:createViewMC(mcName, true,false)
    mc:setPosition(mcx or 0,mcy or 0)
    clipNode:addChild(mc)
    mc:setCascadeOpacityEnabled(true,true)
    clipNode:setCascadeOpacityEnabled(true,true)
    local delayTime = param.delayTime
    -- if delayTime then
    --     clipNode:runAction(cc.RepeatForever:create(
    --         cc.Sequence:create(
    --             cc.DelayTime:create(delayTime),
    --             cc.CallFunc:create(function( )
    --                 clipNode:setVisible(not clipNode:isVisible())
    --                 if clipNode:isVisible() then
    --                     mc:gotoAndPlay(0)
    --                 else
    --                     mc:stop()
    --                 end
    --             end)
    --         )
    --     ))
    -- end
    node:setCascadeOpacityEnabled(true,true)
    node:addChild(clipNode,2)
    return mc
end

function FlashCardView:addAnimation2Node( name,node,param )
    param = param or {}
    local x,y = param.x or node:getContentSize().width/2,param.y or node:getContentSize().height/2
    local offsetx,offsety = param.offsetx or 0,param.offsety or 0
    local zOrder = param.zOrder or 0
    local endCallback = param.endCallback
    local speed = param.speed 
    local scale = param.scale 
    local delayTime = param.delayTime
    local loop = not param.notLoop
    local mc = mcMgr:createViewMC(name, loop)
    mc:setPosition(x+offsetx, y+offsety)
    mc:setName("effectAnim")
    mc:setCascadeOpacityEnabled(true,true)
    if speed then
        mc:setPlaySpeed(speed)
    end
    if scale then
        if type(scale) == "table" then
            mc:setScale(scale.x,scale.y)
        else
            mc:setScale(scale)
        end
    end
    if endCallback then
        mc:addEndCallback(function (_, sender)
            endCallback(sender)
        end)
    end
    self._mcs[name] = mc
    node:addChild(mc,zOrder)
    mc:setCascadeOpacityEnabled(true)
    -- if delayTime then
    --     mc:runAction(cc.RepeatForever:create(
    --         cc.Sequence:create(
    --             cc.DelayTime:create(delayTime),
    --             cc.CallFunc:create(function( )
    --                 mc:setVisible(not mc:isVisible())
    --                 if mc:isVisible() then
    --                     mc:gotoAndPlay(0)
    --                 else
    --                     mc:stop()
    --                 end
    --             end)
    --         )
    --     ))
    -- end
    return mc
end

function FlashCardView:removeMC( name )
    if not tolua.isnull(self._mcs[name]) then
        self._mcs[name]:removeFromParent()
        self._mcs[name] = nil
    end
end

function FlashCardView:reflashTimeLabel()
    self._toolFree = self:isToolDrawFree()
    self._teamFree = self:isGemDrawFree()
    if self._toolFree and self._teamFree then
        if self._updateTime then
            ScheduleMgr:unregSchedule(self._updateTime)
        end
        self._updateTime = nil
    else
        if not self._updateTime then
            self._updateTime = ScheduleMgr:regSchedule(1000,self,function()
                self:refreshTime()
            end)
        end
    end
end

function FlashCardView:isToolDrawFree( )
    local isFree = false
    local toolLastTime = self._modelMgr:getModel("PlayerTodayModel"):getDrawAward().drawToolLastTime or 0
    local toolNum = self._modelMgr:getModel("PlayerTodayModel"):getData().day7 or 0
    local cost = toolSingle
    self._tCost:setColor(cc.c4b(255,255,255,255))
    self._tOneCost:setColor(cc.c4b(255,255,255,255))
    local boardOffsetX = self._tBoardW/2+5
    toolFreeNum = tab:Setting("G_FREENUM_DRAW_TOOL_SINGLE").value+self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_8)
    local quanImg = self:getUI("bg.toolBtnLayer.buyOneCostLayer.Image_28")
    local quanIcon = self:getUI("bg.toolLayer.quan_img")
    if (self._modelMgr:getModel("UserModel"):getCurServerTime()-toolLastTime > 0 and toolNum < toolFreeNum) then
        isFree = true
        -- cost = "本次免费"
        cost = " 免费（" .. (toolFreeNum-toolNum) .. "）"
        quanImg:setVisible(false)
        quanIcon:setVisible(false)
        self._tCost:setColor(cc.c4b(0,255,30,255))
        self._tOneCost:setColor(cc.c4b(0,255,30,255))
        -- self._tTimeLab:setString("（" .. (toolFreeNum-toolNum) .. "）")-- .. "/" .. toolFreeNum)
        self._tTimeDes:setString(lang("BUY_CARD_TOOL"))
        self._tTimeDes:setColor(cc.c4b(0,255,30,255))
        self._tTimeDes:setPositionX(180)
        
        self._tTimeDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
        self._tBtnTimeLab:setString("")
        -- local lw = self._tTimeLab:getContentSize().width
        -- local dw = self._tTimeDes:getContentSize().width
        -- boardOffsetX = boardOffsetX-(lw-dw)/2+25
        -- self._tTimeLab:setPositionX(lw/2+boardOffsetX+2)
        -- self._tTimeDes:setPositionX(-dw/2+boardOffsetX)
        -- if not self._tMianfeiMc then
        --     self._tMianfeiMc = self:addAnimation2Node("mianfeitishi_flashcarduianim",self:getUI("bg.toolLayer"),{offsetx = 0,offsety = -205, scale = {x=1.25,y=1}})
        -- end
        if not self._priviligeIcon  then
            self._priviligeIcon = ccui.ImageView:create()
            self._priviligeIcon:loadTexture(IconUtils.resImgMap["privilege"],1)
            self._priviligeIcon:setPosition(quanIcon:getPosition())
            self._priviligeIcon:setScale(0.9)
            self:getUI("bg.toolLayer"):addChild(self._priviligeIcon)
        end
        self._priviligeIcon:setVisible(true)
        self._tDot:setVisible(true)
    else
        self._tCost:setColor(cc.c4b(255,255,255,255))
        self._tOneCost:setColor(cc.c4b(255,255,255,255))
        quanImg:setVisible(true)
        -- if self._tMianfeiMc then
        --     self._tMianfeiMc:removeFromParent()
        --     self._tMianfeiMc = nil
        -- end
        quanIcon:setVisible(true)
        if self._priviligeIcon then
            self._priviligeIcon:setVisible(false)
        end
        if toolNum < toolFreeNum then
            self._tTimeLab:setString(self._tTime or "00:00:00")
            self._tTimeDes:setString("后免费")
            self._tTimeLab:setColor(cc.c4b(255,255,255,255))
            self._tTimeDes:setColor(cc.c4b(255,255,255,255))
            self._tTimeLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
            self._tTimeDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
            local lw = self._tTimeLab:getContentSize().width
            local dw = self._tTimeDes:getContentSize().width
            boardOffsetX = boardOffsetX+(lw-dw)/2
            self._tTimeLab:setPositionX(-lw/2+boardOffsetX)
            self._tTimeDes:setPositionX(dw/2+boardOffsetX+3)
            self._tBtnTimeLab:setColor(cc.c4b(255,255,255,255))
            self._tBtnTimeLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
            self._tBtnTimeLab:setString((self._tTime or "00:00:00") .. "后免费")
        else
            self._tTimeLab:setString("")
            self._tTimeDes:setColor(cc.c4b(255,255,255,255))
            self._tBtnTimeLab:setString("")
            -- self._tTimeDes:disableEffect()
            self._tTimeDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
            self._tTimeDes:setString(lang("BUY_CARD_TOOL"))
            -- self._tTimeLab:setPositionX(self._tTimeLab:getContentSize().width/2+boardOffsetX)
            -- self._tTimeDes:setPositionX(boardOffsetX)
        end
        self._tDot:setVisible(false)
    end 

    self._tTimeLab:setVisible((not isFree))
    -- self._tTimeDes:setVisible((not isFree))
    local _,toolHaveNum = self._modelMgr:getModel("ItemModel"):getItemsById(3001)
    self:textColorRed(self._tCost,toolHaveNum< toolSingle and not isFree)
    self:textColorRed(self._tOneCost,toolHaveNum< toolSingle and not isFree)
    self:textColorRed(self._tTenCost,toolHaveNum< toolTen)

    --按钮特效层 不满足条件，不加特效
    local btnAnim = self._tTenBtn:getChildByFullName("animImg")
    if btnAnim then
        btnAnim:setVisible(toolHaveNum >= toolTen)
    end
    if isFree then
        self._tCost:setColor(cc.c4b(0,255,30,255))
        self._tOneCost:setColor(cc.c4b(0,255,30,255))
        self._tCost:setString(cost)
        self._tOneCost:setString(cost)
    else
        self._tCost:setString( toolHaveNum .. "/" .. cost)
        self._tOneCost:setString(toolHaveNum .. "/" .. cost)
    end
    self._tTenCost:setString(toolHaveNum .. "/" .. toolTen)
    return isFree
end
function FlashCardView:textColorRed( node,red,color )
    if red then
        node:setColor(cc.c4b(255, 23, 23, 255))
    else
        node:setColor(color or node:getColor())
    end
end
local isSetGemFirstImg = false
function FlashCardView:isGemDrawFree()
    -- 换成幸运币
    local costImageName = isLuckyCoin and "globalImageUI_luckyCoin.png" or "globalImageUI_diamond.png"
    self._gCostImg:loadTexture(costImageName,1)
    self._gOneCostImg:loadTexture(costImageName,1)
    self._gTenCostImg:loadTexture(costImageName,1)

    --玩家拥有的金钥匙道具  hgf
    local _,toolHaveNum = self._modelMgr:getModel("ItemModel"):getItemsById(3041)
    self._goldKeyNum:setString(toolHaveNum)
    if toolHaveNum <= 0 then
        self._keyImg:setVisible(false)
        self._keyBg:setVisible(false)
        self._goldKeyNum:setVisible(false)
    else
        self._keyImg:setVisible(true)
        self._keyBg:setVisible(true)
        self._goldKeyNum:setVisible(true)
    end
    local havePrivilege = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.ZuanShiChouKa)
    local isFree = false
    local isHalf = false
    local cost = gemSingle
    local disCount
    local disCountNum = 1
    local teamLastTime = (self._modelMgr:getModel("PlayerTodayModel"):getDrawAward().drawTeamLastTime or 0)-self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_9)
    -- self._gCost:setColor(cc.c4b(255,255,255,255))
    -- self._gOneCost:setColor(cc.c4b(255,255,255,255))
    local boardOffsetX = self._gBoardW/2

    local gemDiscountLab = self._gOneCost:getChildByFullName("greenText")
    if gemDiscountLab then
        gemDiscountLab:setVisible(false)
    end
    if self._gbtnDraw then
        self._gbtnDraw:clear()
    end
    local diaImg1 = self:getUI("bg.gemBtnLayer.buyOneCostLayer.Image_29")
    local teamNum = self._modelMgr:getModel("PlayerTodayModel"):getData().day1 or 0

    if teamNum == 0 then
        isFree = true
        cost = "本次免费"
        diaImg1:setVisible(false)
        self._gCost:setColor(cc.c4b(0,255,30,255))
        self._gCost:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
        self._gOneCost:setColor(cc.c4b(0,255,30,255))
        self._gTimeLab:setString(lang("CHOUKA_MIANFEI") or lang("BUY_CARD_GEM") or "　")
        self._gTimeLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
        self._gTimeLab:setPositionX(boardOffsetX)
        self._gTimeDes:setString("")
        self._gBtnTimeLab:setString("")
        self._gTimeLabC:setVisible(false)
        self._gTimeDesC:setVisible(false)
        self._gTimeLab:setPosition(self._gTimeLabInitPos)
        self._gTimeDes:setPosition(self._gTimeDesInitPos)
        -- if not self._gMianfeiMc then
        --     self._gMianfeiMc = self:addAnimation2Node("mianfeitishi_flashcarduianim",self:getUI("bg.gemLayer"),{offsetx = 0,offsety = -205, scale = {x=1.25,y=1}})
        -- end
        self._gDot:setVisible(true)
    else
        self._gCost:setColor(cc.c4b(255,255,255,255))
        self._gCost:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
        self._gOneCost:setColor(cc.c4b(255,255,255,255))
        self._gOneCost:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
        diaImg1:setVisible(true)        


        local teamNum = self._modelMgr:getModel("PlayerTodayModel"):getData().day1
        if teamNum == 1 and havePrivilege ~= 0 then
            cost = cost*discountSingle
            disCount = "半价"
            disCountNum = discountSingle

            self._gTimeLab:setString("半价")
            self._gTimeLab:setFontSize(22)
            self._gTimeLab:setColor(cc.c4b(0, 255, 30, 255))
            self._gTimeLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
            self._gTimeDes:setString("每日首次")
            self._gTimeDes:setColor(cc.c4b(255, 217, 24, 255))
            self._gTimeDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
            local lw = self._gTimeLab:getContentSize().width
            local dw = self._gTimeDes:getContentSize().width
            boardOffsetX = boardOffsetX-(lw-dw)/2
            -- 固定字儿设固定改位置
            self._gTimeLab:setPositionX(50+self._gBoardW/2)
            self._gTimeDes:setPositionX(-15+self._gBoardW/2)
            -- self._gTimeLab:setPositionX(lw/2+boardOffsetX)
            -- self._gTimeDes:setPositionX(-dw/2+boardOffsetX)
            self._gBtnTimeLab:setString("")

            -- self._gTimeLabC:setString("半价")
            -- self._gTimeLabC:setFontSize(22)
            -- self._gTimeLabC:setColor(cc.c4b(0, 255, 30, 255))
            -- self._gTimeLabC:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
            -- self._gTimeDesC:setString("每日首次")
            -- self._gTimeDesC:setColor(cc.c4b(61, 31, 0, 255))
            -- local lw = self._gTimeLabC:getContentSize().width
            -- local dw = self._gTimeDesC:getContentSize().width
            -- boardOffsetX = boardOffsetX-(lw-dw)/2
            -- self._gTimeLabC:setPositionX(lw/2+boardOffsetX)
            -- self._gTimeDesC:setPositionX(-dw/2+boardOffsetX)

            -- self._gTimeLabC:setVisible(true)
            -- self._gTimeDesC:setVisible(true)
            -- self._gTimeLab:setPositionY(self._gTimeLabInitPos.y-15)
            -- self._gTimeDes:setPositionY(self._gTimeDesInitPos.y-15)
            self._gDot:setVisible(true)
            -- if not self._gMianfeiMc then
            --     self._gMianfeiMc = self:addAnimation2Node("mianfeitishi_flashcarduianim",self:getUI("bg.gemLayer"),{offsetx = 0,offsety = -205, scale = {x=1.25,y=1}})
            -- end
        else
            -- 判断是否有金钥匙
            if toolHaveNum > 0 then
                self._gCostImg:loadTexture("flashcard_choukaGoldKey.png",1)
                self._gOneCostImg:loadTexture("flashcard_choukaGoldKey.png",1)
                cost = toolHaveNum .. "/1"
            end
            self._gTimeLabC:setVisible(false)
            self._gTimeDesC:setVisible(false)
            self._gTimeLab:setPosition(self._gTimeLabInitPos)
            self._gTimeDes:setPosition(self._gTimeDesInitPos)
            self._gDot:setVisible(false)
            -- 
            self._gTimeLab:setString("次日5点免费")
            self._gTimeLab:setColor(cc.c4b(255, 255, 255, 255))
            self._gTimeLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
            self._gTimeDes:setString("")
            self._gBtnTimeLab:setString("次日5点免费")
            self._gTimeDes:setColor(cc.c4b(255, 255, 255, 255))
            self._gTimeDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
            local lw = self._gTimeLab:getContentSize().width
            local dw = self._gTimeDes:getContentSize().width
            boardOffsetX = self._gBoardW/2+(lw-dw)/2
            self._gTimeLab:setPositionX(-self._gTimeLab:getContentSize().width/2+boardOffsetX)
            self._gTimeDes:setPositionX(self._gTimeDes:getContentSize().width/2+boardOffsetX+2)
        end
    end 
    self._gCost:setString(disCount or cost)
    self._gOneCost:setString(cost)
    if disCount then
        self._gOneCost:setString(gemSingle)
    end
   
    local gemHaveNum = self._modelMgr:getModel("UserModel"):getData()[rightCostType] or 0
    if disCountNum < 1 then
        local costW,costH = self._gOneCost:getContentSize().width,self._gOneCost:getContentSize().height
        local costX,costY = self._gOneCost:getPositionX(),self._gOneCost:getPositionY()
        self._gbtnDraw:drawSegment(cc.p(costX-costW/2,costY),cc.p(costX+costW/2,costY),1,cc.c4f(1.0, 0.0, 0.0, 1.0))
        gemDiscountLab:setPosition(cc.p(costW*1.5,costH/2))
        gemDiscountLab:setVisible(true)
        self._gCost:setColor(cc.c4b(0,255,0,255))
        self._gOneCost:setColor(cc.c4b(255,255,255,255))
        gemDiscountLab:setString(cost)
        self:textColorRed(gemDiscountLab,(gemHaveNum < gemSingle*disCountNum) and not isFree,cc.c4b(0, 255, 0, 255))
    else
        self:textColorRed(self._gOneCost,(toolHaveNum <= 0 and gemHaveNum < gemSingle*disCountNum) and not isFree)
    end 
   -- self._gbtnDraw:drawSegment(cc.p(0,0),cc.p(500,500),1,cc.c4b(1.0, 0.0, 0.0, 1.0))
   
    self:textColorRed(self._gCost,(toolHaveNum <= 0 and gemHaveNum < gemSingle*disCountNum) and not isFree)   

    if toolHaveNum < 10 then
        self._gTenCost:setString(math.ceil(gemTen*discountTen))       
        self:textColorRed(self._gTenCost,(gemHaveNum < gemTen*discountTen), cc.c4b(0, 255, 0, 255))
    else
        self._gTenCostImg:loadTexture("flashcard_choukaGoldKey.png",1)
        self._gTenCost:setString(toolHaveNum .. "/10")
    end

    --按钮特效层 不满足条件，不加特效
    local btnAnim = self._gTenBtn:getChildByFullName("animImg")
    if btnAnim then
        btnAnim:setVisible((toolHaveNum >= 10) or (gemHaveNum >= gemTen*discountTen))
    end

    if not isFree and self._modelMgr:getModel("PlayerTodayModel"):getDrawAward().first == 0 then
        local desImg = self._gemLayer:getChildByFullName("desImg")
        if desImg then
            desImg:loadTexture("text_bingtuan_f_flashcard.png",1)
        end
    else
        local desImg = self._gemLayer:getChildByFullName("desImg")
        if desImg then
            desImg:loadTexture("text_bintuan_n_flashcard.png",1)
        end
        -- if not isSetGemFirstImg then
        --     isSetGemFirstImg = true
        -- end
    end
    return isFree,disCountNum < 1
end

function FlashCardView:reflashUI(data)
    --更新用户钻石
    if data.d and data.d.drawAward then
        self._playerDayModel:updateDrawAward(data.d.drawAward)
    end
   
    if data.d and data.d.dayInfo then
        self._playerDayModel:updateDayInfo(data.d.dayInfo)
    end

    if data.d and data.d.items then
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(data.d.items)
        data.d.items = nil
    end

    if data.d and data.d.teams then
        local teamModel = self._modelMgr:getModel("TeamModel")
        teamModel:updateTeamData(data.d.items)
        data.d.teams = nil
    end
    if data.d then
        local userModel = self._modelMgr:getModel("UserModel")
        userModel:updateUserData(data.d)
    end
    self:reflashTimeLabel()
    --显示用户奖励
    -- self:getRewards(data)
    -- self:addAnimation2Node("shanguang_flashcardanim",self._bg,{zOrder = 99,endCallback = function( sender )
    --     sender:removeFromParent()
    -- end})
    -- self._gemBtnLayer:setVisible(false)
    -- self._toolBtnLayer:setVisible(false)
    local moveAction = cc.Sequence:create(cc.MoveBy:create(0.2,cc.p(0,50)),cc.MoveBy:create(0.35,cc.p(0,-300)),cc.CallFunc:create(function()
        self._gemBtnLayer:setVisible(false)
        self._toolBtnLayer:setVisible(false) 
        self._viewMgr:showDialog("flashcard.DialogFlashCardResult",{ awards = (data.awards or {}),costType = self._costType,buyNum = self._buyNum,
        callback = function( awards )
            -- self:removeMC("choukabeijing_choukaanim2")
            self:bgBounceUp(true)
            local moveBack = cc.Sequence:create(cc.MoveBy:create(0.25,cc.p(0,270)),cc.MoveBy:create(0.2,cc.p(0,-20)))
            if self._costType == rightCostType then
                self._gemBtnLayer:setVisible(true)
                self._gemBtnLayer:setOpacity(255)
                self._gemBtnLayer:runAction(moveBack)
            else
                self._toolBtnLayer:setVisible(true)
                self._toolBtnLayer:setOpacity(255)
                self._toolBtnLayer:runAction(moveBack)
            end
            self._tOneBtn:setTouchEnabled(true)
            self._tTenBtn:setTouchEnabled(true)
            self._gOneBtn:setTouchEnabled(true)
            self._gTenBtn:setTouchEnabled(true)
            self._returnBtn:setTouchEnabled(true)
            self._showCangetBtn:setTouchEnabled(true)
            self._buyGemBtn:setTouchEnabled(true)
            
            self:reflashTimeLabel()
            self._resultView = nil 
            self:showCommentView(awards or data.awards)
            self._modelMgr:getModel("GuildRedModel"):checkRandRed()
            self._jinMc:play()
            self._jinMc:gotoAndStop(0)
            self._yinMc:gotoAndStop(0)
            self._starJinMc:play()
            self._starYinMc:play()
        end},true)
    end))
    if self._costType == rightCostType then
        self._gemBtnLayer:runAction(moveAction)                
    else
        self._toolBtnLayer:runAction(moveAction)              
    end
    -- cc.MoveTo:create(0.2,cc.p(0,0)),0.3)
    
end

--[[
--! @function refreshTime
--! @desc 倒计时刷新时间
--! @param 
--! @return 
--]]

function FlashCardView:refreshTime()
    if not self._toolFree and self._modelMgr:getModel("PlayerTodayModel"):getDrawAward() then
        local lastToolTime = self._modelMgr:getModel("PlayerTodayModel"):getDrawAward().drawToolLastTime or 0
        if (self._modelMgr:getModel("UserModel"):getCurServerTime() >= lastToolTime)  then
            self._tTimeLab:setString("00:00:00")
            self._tTime = "00:00:00"
            self:reflashTimeLabel()
        else 
            local toolNum = self._modelMgr:getModel("PlayerTodayModel"):getData().day7 or 0
            if toolNum < toolFreeNum then
                local timeInt = lastToolTime - self._modelMgr:getModel("UserModel"):getCurServerTime()
                local timeStr = string.format("%02d:%02d:%02d",math.floor(timeInt/3600),math.floor(timeInt/60)%60,timeInt%60).. ""
                self._tTime = timeStr
                self._tTimeLab:setString(timeStr)
                self._tBtnTimeLab:setString(timeStr .. "后免费")
            end
        end
    end
    if not self._teamFree and self._modelMgr:getModel("PlayerTodayModel"):getDrawAward() then
        local lastTeamTime = (self._modelMgr:getModel("PlayerTodayModel"):getDrawAward().drawTeamLastTime or 0)-self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_9)
        local teamNum = self._modelMgr:getModel("PlayerTodayModel"):getData().day1 or 0
        if teamNum == 0 then
            self._gTimeLab:setString("00:00:00")
            self:reflashTimeLabel()
        else
            local havePrivilege = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.ZuanShiChouKa)
            if not (havePrivilege ~= 0 and teamNum ==1) then
                -- self._gTimeLab:setString("")
                -- self._gTimeDes:setString("")
            -- else
                local timeInt = lastTeamTime - self._modelMgr:getModel("UserModel"):getCurServerTime()
                local timeStr = string.format("%02d:%02d:%02d",math.floor(timeInt/3600),math.floor(timeInt/60)%60,timeInt%60).. ""
                --os.date("%H:%M:%S",lastTeamTime-self._modelMgr:getModel("UserModel"):getCurServerTime()) .. "后免费"
                self._gTime = timeStr
                self._gTimeLab:setString("次日5点免费")
                self._gBtnTimeLab:setString("次日5点免费")
            end
        end
    end
end

--[[
--! @function buyCardByGem
--! @desc 钻石抽卡
--! @param 抽卡所需要的价钱，钱足够的时候执行的函数
--! @return 
--]]
function FlashCardView:buyCardByGem(price,num)
    local player = self._modelMgr:getModel("UserModel"):getData()
    local gem = player[rightCostType] or 0
    local _,haveKeyNum = self._modelMgr:getModel("ItemModel"):getItemsById(3041)
    local free ,disCountNum = self:isGemDrawFree()
    local conditions = false
    if 1 == num then
        conditions = ((haveKeyNum > 0 and not disCountNum) or gem >= price or (price == gemSingle and free))
    else
        conditions = (haveKeyNum >= 10 or gem >= price)
    end
    if conditions then
        -- local notUnLock = true
        -- self._returnBtn:setEnabled(false)

        self._tOneBtn:setTouchEnabled(false)
        self._tTenBtn:setTouchEnabled(false)
        self._gOneBtn:setTouchEnabled(false)
        self._gTenBtn:setTouchEnabled(false)
        self._returnBtn:setTouchEnabled(false)
        self._showCangetBtn:setTouchEnabled(false)
        self._buyGemBtn:setTouchEnabled(false)

        self._serverMgr:sendMsg("TeamServer", "drawAward", {typeId = 2, num = num}, true, {}, function(result) 
            dump(result,"0000000-------抽卡结果")
            if not self.lock then return end
            self:lock(-1)
            audioMgr:playSound("Draw")
            self._yunSpeed = 1-- 去掉云加速 2017.5.17 

            self:showJinBobMc()
            self:playStatueMc()
            ScheduleMgr:delayCall(2000, self, function( )
                if not self.reflashUI then return end
                -- notUnLock = false
                if self.unlock then 
                    self:unlock()
                end     
                self:reflashUI(result)
                self._yunSpeed = 1
                self:stopStatueMc()
            end)
        end,
        function( )
            if self.unlock then 
                self:unlock()
            end
            if not self._tOneBtn then return end
            self._tOneBtn:setTouchEnabled(true)
            self._tTenBtn:setTouchEnabled(true)
            self._gOneBtn:setTouchEnabled(true)
            self._gTenBtn:setTouchEnabled(true)
            self._returnBtn:setTouchEnabled(true)
            self._showCangetBtn:setTouchEnabled(true)
            self._buyGemBtn:setTouchEnabled(true)
        end)
        -- ScheduleMgr:delayCall(10000, self, function( )
        --     if self and self._returnBtn then
        --         -- self._returnBtn:setEnabled(true)
        --         self._tOneBtn:setTouchEnabled(true)
        --         self._tTenBtn:setTouchEnabled(true)
        --         self._gOneBtn:setTouchEnabled(true)
        --         self._gTenBtn:setTouchEnabled(true)
        --         self._returnBtn:setTouchEnabled(true)
        --     end
        -- end)
    else
        -- "购买兵团经验赠送幸运币，\n是否前往购买？"
        -- DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_LUCKYCOIN"),button1 = "前往",title = "幸运币不足",callback1=function( )
        --     DialogUtils.showBuyRes({goalType = "luckyCoin",inputNum = price-gem })
        -- end})
        self:showNeedCharge(price-gem)
        self._gemBtnLayer:setVisible(true)
        -- self._viewMgr:showDialog("flashcard.DialogBuyMoneyView",{name = "充值", title = "钻石不足", desc = lang("TIP_GLOBAL_LACK_GEM")})
    end
   
end

--[[
--! @function buyCardByTool
--! @desc 道具抽卡
--! @param 抽卡所需要的道具的数量，道具数量足够的时候执行的函数
--! @return 
--]]
function FlashCardView:buyCardByTool(count,num)
    local ToolSingle = tab:Setting("G_DRAWCOST_TOOL_SINGLE")
    local toolId = tonumber(ToolSingle["value"][2])
    local item = self._modelMgr:getModel("ItemModel")
    local idata,icount = item:getItemsById(toolId)
    if icount >= count or ( count == 1 and self:isToolDrawFree()) then
        -- self._returnBtn:setEnabled(false)

        self._tOneBtn:setTouchEnabled(false)
        self._tTenBtn:setTouchEnabled(false)
        self._gOneBtn:setTouchEnabled(false)
        self._gTenBtn:setTouchEnabled(false)
        self._returnBtn:setTouchEnabled(false)
        self._showCangetBtn:setTouchEnabled(false)
        self._buyGemBtn:setTouchEnabled(false)

        self._serverMgr:sendMsg("TeamServer", "drawAward", {typeId = 1, num = num}, true, {}, function(result) 
            if not self.lock then return end
            dump(result,"qwre")
            self:lock(-1)
            audioMgr:playSound("Draw")
            self._yunSpeed = 1-- 去掉云加速 2017.5.17 
            self._yinMc:stopAllActions()
            self._yinMc:gotoAndPlay(0)
            self:playStatueMc("yin")
            ScheduleMgr:delayCall(2000, self, function( )
                if not self.reflashUI then return end
                if self.unlock then 
                    self:unlock()
                end
                self:reflashUI(result)
                self._yunSpeed = 1
                self._yinMc:stop()
                -- ScheduleMgr:delayCall(1500,self,function( )
                --     if not self._yinMc then return end
                -- end)
                self:stopStatueMc("yin")
            end)
        end,
        function( )
            if self.unlock then 
                self:unlock()
            end
            if not self._tOneBtn then return end
            self._tOneBtn:setTouchEnabled(true)
            self._tTenBtn:setTouchEnabled(true)
            self._gOneBtn:setTouchEnabled(true)
            self._gTenBtn:setTouchEnabled(true)
            self._returnBtn:setTouchEnabled(true)
            self._showCangetBtn:setTouchEnabled(true)
            self._buyGemBtn:setTouchEnabled(true)
        end)
        -- ScheduleMgr:delayCall(10000, self, function( )
        --     if self and self._returnBtn then
        --         -- self._returnBtn:setEnabled(true)

        --         self._tOneBtn:setTouchEnabled(true)
        --         self._tTenBtn:setTouchEnabled(true)
        --         self._gOneBtn:setTouchEnabled(true)
        --         self._gTenBtn:setTouchEnabled(true)
        --         self._returnBtn:setTouchEnabled(true)

        --     end
        -- end)
    else
        -- DialogUtils.showNeedCharge({desc = "道具不足，是否前去购买？",callback1=function( )
        -- end})
        self._viewMgr:showTip("道具不足!")
        self._toolBtnLayer:setVisible(true)
        self._toolBtnLayer:setOpacity(255)
        -- self._toolBtnLayer:runAction(cc.EaseIn:create(cc.MoveTo:create(0.2,cc.p(0,0)),0.3))
    end
end

function FlashCardView:buyOneByTool( )
    local cost = toolSingle
    if self._toolFree then
        cost = 0
    end
    self._buyNum = 1
    self:buyCardByTool(cost,1)
end

function FlashCardView:buyTenByTool( )
    local cost = toolTen
    self._buyNum = 10
    self:buyCardByTool(cost,10)
end

function FlashCardView:buyOneByGem( )
    local cost = gemSingle
    local num = self._modelMgr:getModel("PlayerTodayModel"):getData().day1
    if self._teamFree then
        cost = 0
    elseif num == 1 then
        cost = cost*discountSingle
    end
    self._buyNum = 1
    self:buyCardByGem(cost,1)
end

function FlashCardView:buyTenByGem( )
    local cost = gemTen*discountTen
    self._buyNum = 10
    self:buyCardByGem(cost,10)
end

--================ 辅助动画效果 ========================
function FlashCardView:setNodeBrightNess( node,bright )
    bright = bright or 40
    node:setBrightness(bright)
    local children = node:getChildren()
    for k,v in pairs(children) do
        v:setBrightness(bright)
    end
end
local fadeOutTime = 0.3
-- 隐藏
function FlashCardView:fadeOutWithChildren( node,callback )
    self:isToolDrawFree()
    self:isGemDrawFree()
    node:setScale(1)    
    -- node:setVisible(false)
    node:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeOut:create(fadeOutTime),cc.ScaleTo:create(0.2,1)),cc.CallFunc:create(function( )
        if callback then
            callback()
        end
        -- node:setScale(1)
        node:setVisible(false)
        node:setOpacity(0)
        node:setBrightness(0)
        self:isToolDrawFree()
        self:isGemDrawFree()
    end)))
    local children = node:getChildren()
    for k,v in pairs(children) do
        v:setCascadeOpacityEnabled(true)
        -- v:setVisible(false)
        -- v:setOpacity(0)
        v:runAction(cc.Sequence:create(cc.FadeOut:create(fadeOutTime),cc.CallFunc:create(function( )
            -- v:setVisible(false)
            v:setOpacity(0)
            -- v:setBrightness(0)
            -- self._gemLayer:setScale(1)
            -- self._toolLayer:setScale(1)
        end)))
    end
end
local fadeInTime = 0.3
-- 展示
function FlashCardView:fadeInWithChildren( node,callback )
    -- self._gemLayer:setScale(1)
    -- self._toolLayer:setScale(1)
    self:isToolDrawFree()
    self:isGemDrawFree()
    node:setScale(1)
    node:setVisible(true)
    node:setOpacity(0)
    node:runAction(cc.Sequence:create(cc.FadeIn:create(fadeInTime),cc.CallFunc:create(function( )
        if callback then
            callback()
        end
        node:setVisible(true)
        self:isToolDrawFree()
        self:isGemDrawFree()
    
    end)))
    local children = node:getChildren()
    for k,v in pairs(children) do
        v:setVisible(true)
        v:setOpacity(0)
        v:runAction(cc.FadeIn:create(fadeInTime))
        -- v:runAction(cc.Sequence:create(cc.FadeIn:create(fadeInTime),cc.CallFunc:create(function( )
        --     -- v:setVisible(true)
        -- end)))
    end
end

function FlashCardView:initBg( )
    self:loadSceneBg()
    self._bgs = {}
    -- self._bg0:loadTexture("flashcardbg_0.png",1)
    self._bg0:setLocalZOrder(-2)
    table.insert(self._bgs,self._bg0)
    -- self._bg1:loadTexture("flashcardbg_1.png",1)
    self._bg1:setLocalZOrder(-1)
    self._bg1:setAnchorPoint(cc.p(0.5,0.58))
    table.insert(self._bgs,self._bg1)
    -- self._bg2:loadTexture("flashcardbg_2.png",1)
    self._bg2:setLocalZOrder(0)
    self._bg2:setAnchorPoint(cc.p(0.5,0.3))
    table.insert(self._bgs,self._bg2)
    -- self._bg3:loadTexture("altar_yin_flashcard.png",1)
    self._bg3:setLocalZOrder(0)
    self._bg3:setAnchorPoint(cc.p(0.5,0.0))
    table.insert(self._bgs,self._bg3)

    -- -- 神像上遮罩光
    -- self:addStatueClipAnim()
    
    self._bgScales = {}
    local maxHeight = self._bg:getContentSize().height
    local scales = {
        MAX_SCREEN_HEIGHT*1.15/self._bg0:getContentSize().height,
        MAX_SCREEN_HEIGHT*1.15/self._bg1:getContentSize().height-0.03,
        1,--MAX_SCREEN_HEIGHT*1.15/self._bg2:getContentSize().height-0.1,
        0.8,
    }
    self._initBgScales = scales
    self._bounceUpScales = {
        MAX_SCREEN_HEIGHT*1.15/self._bg0:getContentSize().height+0.06,
        MAX_SCREEN_HEIGHT*1.15/self._bg1:getContentSize().height+0.08,
        1.1,--MAX_SCREEN_HEIGHT*1.15/self._bg2:getContentSize().height+0.12,
        1,
    }
    local initDark = {0.46,0.46,0.52,0.52}
    for i,bg in ipairs(self._bgs) do
        local scale = scales[i] --maxHeight/bg:getContentSize().height
        table.insert(self._bgScales,scale)
        bg:setScale(scale)
        bg:setColor(cc.c3b(255*initDark[i], 255*initDark[i], 255*initDark[i]))
    end
    -- 新增切换黄昏
    local isYellow = GameStatic.mainViewVer == 2
    local yunColorTail = isYellow and "2" or ""
    local sfc = cc.SpriteFrameCache:getInstance()
    local tc = cc.Director:getInstance():getTextureCache() 
    if isYellow then
        sfc:addSpriteFrames("asset/ui/flashCard2.plist", "asset/ui/flashCard2.png")
    end
    
    local yun1 = ccui.ImageView:create()
    yun1:loadTexture("flashcard_yun".. yunColorTail ..".jpg",1)
    yun1:setScale(MAX_SCREEN_WIDTH/yun1:getContentSize().width,MAX_SCREEN_HEIGHT/yun1:getContentSize().height)
    -- yun1:setColor(cc.c4b(255, 0, 0, 128))
    yun1:setAnchorPoint(cc.p(0,1))
    yun1:setPosition(cc.p((960-MAX_SCREEN_WIDTH)/2,MAX_SCREEN_HEIGHT+(640-MAX_SCREEN_HEIGHT)/2))
    yun1:setName("yun1")
    self._bg:addChild(yun1,-3)
    local yunWidth = MAX_SCREEN_WIDTH -- yun1:getContentSize().width
    local yun2 = ccui.ImageView:create()
    yun2:loadTexture("flashcard_yun".. yunColorTail ..".jpg",1)
    yun2:setScale(MAX_SCREEN_WIDTH/yun2:getContentSize().width,MAX_SCREEN_HEIGHT/yun2:getContentSize().height)
    yun2:setAnchorPoint(cc.p(0,1))
    yun2:setPosition(cc.p(yunWidth-1,MAX_SCREEN_HEIGHT+(640-MAX_SCREEN_HEIGHT)/2))
    yun2:setName("yun2")
    self._bg:addChild(yun2,-3)
    
    self._yunSpeed = 1
    if not self._bgSchedule then
        self._bgSchedule = ScheduleMgr:regSchedule(10,self,function( )
            self:scrollBg()
        end)
    end
end

function FlashCardView:scrollBg( )
    local yun1 = self._bg:getChildByFullName("yun1")
    local yun2 = self._bg:getChildByFullName("yun2")
    local w = MAX_SCREEN_WIDTH --yun1:getContentSize().width*yun1:getScaleX()
    local screenOffset = -960+MAX_SCREEN_WIDTH
    local x1 = yun1:getPositionX()
    local x2 = yun2:getPositionX()
    local speed = self._yunSpeed
    if x1 <= -w-screenOffset/2 then
        x1 = w-screenOffset/2-speed 
    else
        x1 = x1-speed
    end
    if x2 <= -w-screenOffset/2 then
        x2 = w-screenOffset/2-speed 
    else
        x2 = x2-speed
    end
    -- 变速矫正
    if x1 < x2 then
        x2 = x1+w-1
    elseif x2 < x1 then
        x1 = x2+w-1
    end
    yun1:setPositionX(x1)
    yun2:setPositionX(x2)
end

local bounceTime = 0.5
local easeOutRate = 1--6
local zAngle = 30
function FlashCardView:bgBounceUp( notShowApearAnim )
    -- self._baoxiangdingguangMc:setVisible(true)
    -- self._baoxiangdingguangMc:gotoAndPlay(0)
    -- self._baoxiangdingguangMc:addEndCallback(function (_, sender)
    --     sender:clearCallbacks()
    --     sender:stop()
    -- end)
    -- local dingguangMc = mcMgr:createViewMC("dingguang_flashcarddingguang", false, true)
    -- dingguangMc:setName("dingguangMc")
    -- dingguangMc:setPosition(self._bg:getContentSize().width/2, self._bg:getContentSize().height/2)
    -- self._bg:addChild(dingguangMc,999)
    self:loadSceneBg(self._costType == "tool" and "yin" or "jin")
    self:showAltarAnim()
    self._returnBtn:setVisible(true)
    self._inBounce = true
    self._gemBtnLayer:setEnabled(false)
    self._toolBtnLayer:setEnabled(false)
    self._bg0:runAction(cc.EaseOut:create(cc.Spawn:create(cc.TintTo:create(bounceTime,cc.c3b(255, 255, 255)),cc.ScaleTo:create(bounceTime,self._bounceUpScales[1])),easeOutRate))
    -- self._bg2:runAction(cc.EaseOut:create(cc.Spawn:create(cc.ScaleTo:create(bounceTime,self._bounceUpScales[3]),cc.MoveTo:create(bounceTime,cc.p(self._bg:getContentSize().width/2,self._bg:getContentSize().height/2)),easeOutRate))
    self._bg2:runAction(cc.EaseOut:create(
            cc.Spawn:create(cc.TintTo:create(bounceTime,cc.c3b(255, 255, 255)),cc.RotateBy:create(bounceTime,0,0),cc.ScaleTo:create(bounceTime,self._bounceUpScales[3]),cc.MoveTo:create(bounceTime,cc.p(self._bg:getContentSize().width/2,0--[[self._bg:getContentSize().height*0.55--]])))
        ,easeOutRate))
    self._bg1:runAction(cc.EaseOut:create(cc.Spawn:create(cc.TintTo:create(bounceTime,cc.c3b(255, 255, 255)),cc.ScaleTo:create(bounceTime,self._bounceUpScales[2]),cc.MoveTo:create(bounceTime,cc.p(self._bg:getContentSize().width/2,self._bg:getContentSize().height*0.63))),easeOutRate))
    
    self._bg3:runAction(cc.EaseOut:create(
            cc.Spawn:create(cc.TintTo:create(bounceTime,cc.c3b(255, 255, 255)),cc.RotateBy:create(bounceTime,0,0),cc.ScaleTo:create(bounceTime,self._bounceUpScales[3]),cc.MoveTo:create(bounceTime,cc.p(self._bg:getContentSize().width/2,80)))
        ,easeOutRate))    
    
    self:runAction(cc.Sequence:create(cc.DelayTime:create(bounceTime),cc.CallFunc:create(function( )
        self._inBuyScene = true
    end))) 
    self._showCangetBtn:setVisible(true)
    self._showCangetBtn:setOpacity(0)
    self:fadeInWithChildren(self._showCangetBtn)
    -- self._lockView:setSwallowTouches(true)
    if self._costType == "tool" then
        self:fadeOutWithChildren(self._toolLayer,function( )
            -- self._lockView:setSwallowTouches(false)
            self._toolBtnLayer:setVisible(true)
            -- self._toolBtnLayer:runAction(cc.EaseIn:create(cc.MoveTo:create(0.2,cc.p(0,0)),0.3))
            self._toolBtnLayer:runAction(cc.FadeIn:create(bounceTime-0.17))
            local children = self._toolBtnLayer:getChildren()
            for k,v in pairs(children) do
                v:runAction(cc.FadeIn:create(bounceTime-0.17))
                local children1 = v:getChildren()
                if #children1 > 0 then
                     for k1,v1 in pairs(children1) do
                        v1:runAction(cc.FadeIn:create(bounceTime-0.17))
                    end
                end
            end
        end)
        self:fadeInWithChildren(self._toolBar)
        self:fadeInWithChildren(self._toolBtnLayer)
        -- self:fadeInWithChildren(self._toolTitle)
        self:fadeOutWithChildren(self._gemLayer)
        self._viewMgr:showNavigation("global.UserInfoView",{types= navigationRes,hideBtn = true,hideInfo=true})
        self:boxShowAnim(self._yinMc,function( )
                -- self:addAnimation2Node("baoxiangyin-1_flashcardanim",self._bg,{endCallback = function( sender )
                --     sender:removeFromParent()
                    self._inBounce = false
                    if self._isBounceLock then
                        self._isBounceLock = false
                        self:unlock()
                    end
                    self._gemBtnLayer:setEnabled(true)
                    self._toolBtnLayer:setEnabled(true)
                    -- self._toolBtnLayer:setVisible(true)
                --     self:addAnimation2Node("baoxiangyin-2_flashcardanim",self._bg)
                -- end})
        end,notShowApearAnim)
    elseif self._costType == rightCostType then
        self:fadeOutWithChildren(self._gemLayer,function( )
            -- self._lockView:setSwallowTouches(false)
            self._gemBtnLayer:setVisible(true)
            self._gbtnDraw:setVisible(true)
            -- self._gemBtnLayer:setOpacity(0)
            -- self._gemBtnLayer:runAction(cc.EaseIn:create(cc.MoveTo:create(bounceTime-0.17,cc.p(0,0)),0.3))
            self._gemBtnLayer:runAction(cc.FadeIn:create(bounceTime-0.17))
            local children = self._gemBtnLayer:getChildren()
            for k,v in pairs(children) do
                v:runAction(cc.FadeIn:create(bounceTime-0.17))
                local children1 = v:getChildren()
                if #children1 > 0 then
                     for k1,v1 in pairs(children1) do
                        v1:runAction(cc.FadeIn:create(bounceTime-0.17))
                    end
                end
            end
        end)
        self:fadeOutWithChildren(self._toolLayer)
        self:fadeInWithChildren(self._gemBar)
        self:fadeInWithChildren(self._gemBtnLayer)
        -- self:fadeInWithChildren(self._gemTitle)
        self._viewMgr:showNavigation("global.UserInfoView",{types= navigationRes,hideBtn = true,hideInfo=true})
        self:boxShowAnim(self._jinMc,function( )
                -- self:addAnimation2Node("baoxiangjin-1 _flashcardanim",self._bg,{endCallback = function( sender )
                    -- sender:removeFromParent()
                    self._inBounce = false
                    if self._isBounceLock then
                        self._isBounceLock = false
                        self:unlock()
                    end
                    self._gemBtnLayer:setEnabled(true)
                    self._toolBtnLayer:setEnabled(true)
                    -- self._gemBtnLayer:setVisible(true)
                --     self:addAnimation2Node("baoxiangjin-2_flashcardanim",self._bg)
                -- end})
        end,notShowApearAnim)
        -- self._jinMc:runAction(cc.Sequence:create(
        --     cc.FadeIn:create(0.5),
        --     cc.CallFunc:create(function(  )
        --     end)
        -- ))
        self._gbtnDraw:setVisible(false)
    end

end
-- local easeInRate = 3
function FlashCardView:bgBounceDown( )
    -- self._baoxiangdingguangMc:setVisible(false)
    -- self._baoxiangdingguangMc:stop()
    self:hideAltarAnim()
    self._returnBtn:setVisible(false)
    self._inBounce = true
    self._bg0:runAction(cc.EaseOut:create(cc.Spawn:create(cc.TintTo:create(bounceTime,cc.c3b(255*0.46, 255*0.46, 255*0.46)),cc.ScaleTo:create(bounceTime,self._initBgScales[1])),easeOutRate))
    self._bg1:runAction(cc.EaseOut:create(cc.Spawn:create(cc.TintTo:create(bounceTime,cc.c3b(255*0.46, 255*0.46, 255*0.46)),cc.ScaleTo:create(bounceTime,self._initBgScales[2]),cc.MoveTo:create(bounceTime,cc.p(self._bg:getContentSize().width/2,self._bg:getContentSize().height*0.5))),easeOutRate))
    self._bg2:runAction(cc.EaseOut:create(
                cc.Spawn:create(cc.TintTo:create(bounceTime,cc.c3b(255*0.52, 255*0.52, 255*0.52)),cc.RotateBy:create(bounceTime,-0,-0),cc.ScaleTo:create(bounceTime,self._initBgScales[3]),cc.MoveTo:create(bounceTime,cc.p(self._bg:getContentSize().width/2,0--[[self._bg:getContentSize().height*0.5]])))
            ,easeOutRate))
    self._bg3:runAction(cc.EaseOut:create(
                cc.Spawn:create(cc.TintTo:create(bounceTime,cc.c3b(255*0.52, 255*0.52, 255*0.52)),cc.RotateBy:create(bounceTime,-0,-0),cc.ScaleTo:create(bounceTime,self._initBgScales[3]),cc.MoveTo:create(bounceTime,cc.p(self._bg:getContentSize().width/2,80)))
            ,easeOutRate))

    self:runAction(cc.Sequence:create(cc.DelayTime:create(bounceTime),cc.CallFunc:create(function( )
        self._inBuyScene = false
        self._inBounce = false
        if self._isBounceLock then
            self._isBounceLock = false
            self:unlock()
        end
        self._gemBtnLayer:setVisible(true)
        self._gemBtnLayer:setOpacity(255)
        self._toolBtnLayer:setVisible(true)
        self._toolBtnLayer:setOpacity(255)
        
        -- self._toolLayer:setScale(1)
        -- self._gemLayer:setScale(1)


        self._costType = nil
    end)))

    -- self:removeMC("baoxiangyin-2_flashcardanim")
    -- self:removeMC("baoxiangyin-3_flashcardanim")
    -- self:removeMC("baoxiangjin-2_flashcardanim")
    -- self:removeMC("baoxiangjin-3 _flashcardanim")
    -- self._gemTitle:setVisible(false)
    -- self._toolTitle:setVisible(false)

    self:fadeInWithChildren(self._toolLayer)
    self:fadeOutWithChildren(self._toolBar,function( )
        self._viewMgr:showNavigation("global.UserInfoView",{types= navigationRes,hideHead = true}, nil, ADOPT_IPHONEX and self.fixMaxWidth or nil)
    end)

    self:fadeInWithChildren(self._gemLayer)
    self:fadeOutWithChildren(self._gemBar,function( )
        self._viewMgr:showNavigation("global.UserInfoView",{types= navigationRes,hideHead = true}, nil, ADOPT_IPHONEX and self.fixMaxWidth or nil)
    end)

    -- self._showCangetBtn:setVisible(false)
    self:fadeOutWithChildren(self._showCangetBtn,function( )
        self._showCangetBtn:setOpacity(255)
        self._showCangetBtn:setVisible(false)
    end)
    self:fadeInWithChildren(self._gbtnDraw)

    self:fadeOutWithChildren(self._gemBtnLayer)
    self:fadeOutWithChildren(self._toolBtnLayer)
    self._jinMc:setVisible(false)
    self._yinMc:setVisible(false)
end

-- 评论
function FlashCardView:showCommentView( awards )
    local buyNum = self._buyNum
    local inType = 1
    if buyNum == 10 then
        inType = 2
    end
    for k,v in pairs(awards) do
        -- 评论
        if v.isChange then
            local param = {inType = inType, teamId = tonumber(v.typeId)%1000}
            local isPop, popData = self._modelMgr:getModel("CommentGuideModel"):checkCommentGuide(param)
            if isPop == true then
                self._viewMgr:showDialog("global.GlobalCommentGuideView", popData, true)
                break
            end
        end
    end
end

-- 宝箱出现动画
function FlashCardView:boxShowAnim( mc,callback,notShowApearAnim )
    if notShowApearAnim then
        print("stop here ==================================== boxShowAnim")
        self:boxFloatAnim(mc,callback)
        return 
    end
    mc:setPosition(480-20,350)
    mc:setOpacity(0)
    mc:setVisible(true)
    mc:runAction(cc.Sequence:create(
        cc.Spawn:create(
            cc.MoveTo:create(0.5,cc.p(480-20,390)),
            cc.FadeIn:create(0.5)
        ),
        cc.CallFunc:create(function( )
            -- if callback then
            --     callback()
            -- end
            self:boxFloatAnim(mc,callback)
        end)
    ))
end

-- 宝箱常态动画
function FlashCardView:boxFloatAnim( mc,callback )
    mc:stopAllActions()
    local moveTime = 2
    local moveDis = 15
    mc:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.EaseOut:create(cc.MoveTo:create(moveTime,cc.p(480-20,390+moveDis)),0.7),
            cc.EaseOut:create(cc.MoveTo:create(moveTime,cc.p(480-20,390-moveDis)),0.7)
        )
    ))
    if callback then
        callback()
    end
end

function FlashCardView:addStatueClipAnim(color)
    color = color or "jin"
    if not tolua.isnull(self._statueMc) then 
        self._statueMc:removeFromParent()
    end
    local mc = self:addMcWithMask(self._bg1,
        "altar_mask_flashcard.png",color .. "saoguang_flashcard".. color .."se",
        {x=510,y=323})
    -- mc:setPlaySpeed(.1)
    self._statueMc = mc 
    self._statueMc:setVisible(false)
    mc:gotoAndStop(10)
    return mc
end

function FlashCardView:showJinBobMc( )
    self._jinMc:gotoAndPlay(0)
    self._jinSpeedMc:stopAllActions()
    self._jinSpeedMc:runAction(cc.Sequence:create(
        cc.DelayTime:create(1),
        cc.CallFunc:create(function( )
            self._jinSpeedMc:setVisible(true)
            self._jinSpeedMc:gotoAndPlay(0)
        end),
        cc.DelayTime:create(1),
        cc.CallFunc:create(function( )
            self._jinOpenMc:setVisible(true)
            self._jinOpenMc:gotoAndPlay(0)
            -- self._jinMc:setVisible(false)
            self._jinSpeedMc:setVisible(false)
            self._jinSpeedMc:gotoAndStop(0)
        end),
        cc.DelayTime:create(1.5),
        cc.CallFunc:create(function( )
            self._jinOpenMc:setVisible(false)
            self._jinOpenMc:gotoAndPlay(0)
            self._jinMc:stop()
        end)
    ))
end

function FlashCardView:resetBobMc( )
    
end

function FlashCardView:playStatueMc(color)
    self:addStatueClipAnim(color)
    self._statueMc:setVisible(true)
    self._statueMc:gotoAndPlay(0)
end

function FlashCardView:stopStatueMc( )
    self._statueMc:setVisible(false)
    self._statueMc:gotoAndStop(0)
end

function FlashCardView:showAltarAnim()
    self._bg3:runAction(cc.FadeIn:create(0.5))
end

function FlashCardView:hideAltarAnim()
    self._bg3:runAction(cc.FadeOut:create(0.5))
end

function FlashCardView:loadSceneBg( color )
    color = color or "yin"
    self._bg0:loadTexture("flashcardbg_0_".. color ..".png",1)
    self._bg1:loadTexture("flashcardbg_1_".. color ..".png",1)
    self._bg2:loadTexture("flashcardbg_2_".. color ..".png",1)
    self._bg3:loadTexture("altar_".. color .."_flashcard.png",1)
end

function FlashCardView:onDestroy( )
    -- self._preBGMName = audioMgr:getMusicFileName()
    -- audioMgr:playMusic("SaintHeaven", true)
    if self._preBGMName then
        audioMgr:playMusic(self._preBGMName, true)
    end
    self._viewMgr:disableScreenWidthBar()
    FlashCardView.super.onDestroy(self)
end

-- 根据类型跳转
function FlashCardView:showNeedCharge( needNum )
    if isLuckyCoin then
        DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_LUCKYCOIN"),button1 = "前往",title = "幸运币不足",callback1=function( )
            DialogUtils.showBuyRes({goalType = "luckyCoin",inputNum = needNum })
        end})
    else
        DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
            local viewMgr = ViewManager:getInstance()
            viewMgr:showView("vip.VipView", {viewType = 0})
        end})
    end
end

return FlashCardView
