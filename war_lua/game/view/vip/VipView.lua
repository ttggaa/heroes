--[[
    Filename:    VipView.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-10-16 15:03:21
    Description: File description
--]]

local VipView = class("VipView", BaseView)

VipView.kViewTypeRecharge = 0
VipView.kViewTypeVip = 1

VipView.kVipViewStatusInit = 10
VipView.kVipViewStatusKeep = 11
VipView.kVipViewStatusRollLeft = 12
VipView.kVipViewStatusRollRight = 13

VipView.kMaxVipLevel = 15

VipView.kGiftItemTag = 1000

VipView.kVipDesCount = 20

function VipView:ctor(params)
    VipView.super.ctor(self)
    self.initAnimType = 1
    self._viewType = params.viewType
    self._callback = params.callback
    self._specifiedIndex  = params.index and (params.index <= VipView.kMaxVipLevel and params.index or VipView.kMaxVipLevel) or nil
    self._vipModel = self._modelMgr:getModel("VipModel")
    self._paymentModel = self._modelMgr:getModel("PaymentModel")
    self._isShowVipReward = false --当前是否展示VipReward

    -- 如果没有初始化数据，则取本地数据
    local clickData = self._vipModel:getGiftClickData()
    if not clickData then        
        local clickJson = SystemUtils.loadAccountLocalData("VIP_GIFT_NOTGET_CLICKDATA")  
        -- print("=============================clickJson=======",clickJson) 
        if clickJson and clickJson ~= "" then
            self._vipModel:setGiftClickData(json.decode(clickJson))
        else
            self._vipModel:setGiftClickData({})
        end
    end
    self._viewMgr:disableIndulge()
end

function VipView:getAsyncRes()
    return 
        {
            {"asset/ui/vip.plist", "asset/ui/vip.png"},
            {"asset/ui/vip1.plist", "asset/ui/vip1.png"}
        }
end

function VipView:getBgName()
    return "bg_007.jpg"
end

function VipView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView", {title = "globalTitle_recharge.png",titleTxt = "充值", hideBtn = false, callback = function()
        if self._callback and type(self._callback) == "function" then
            self._callback()
        end
    end})
end

function VipView:onInit()  
    self:addAnimBg()
    -- self._btn_return = self:getUI("btn_return")
    -- self._btn_return:setVisible(false)
    self._top = {}
    self._top._vipImage = self:getUI("bg.layer.vipbg.top.imageVip")
    self._top._vipImageDoubleMC = mcMgr:createViewMC("VIPxingxing1_vipanim", true)
    self._top._vipImageDoubleMC:setScale(0.9)
    self._top._vipImageDoubleMC:setVisible(false)
    self._top._vipImageDoubleMC:setPlaySpeed(1, true)
    self._top._vipImageDoubleMC:setPosition(self._top._vipImage:getPositionX(), self._top._vipImage:getPositionY())
    self._top._vipImage:getParent():addChild(self._top._vipImageDoubleMC, 20)
    self._top._vipImageSingleMC = mcMgr:createViewMC("VIPxingxing1_vipanim", true)
    self._top._vipImageSingleMC:setScale(0.9)
    self._top._vipImageSingleMC:setVisible(false)
    self._top._vipImageSingleMC:setPlaySpeed(1, true)
    self._top._vipImageSingleMC:setPosition(self._top._vipImage:getPositionX(), self._top._vipImage:getPositionY())
    self._top._vipImage:getParent():addChild(self._top._vipImageSingleMC, 20)
    self._top._vipInfo = self:getUI("bg.layer.vipbg.top.layer_vip_info")
    -- self._top._vipLabel = self:getUI("bg.layer.vipbg.top.vipLabel")
    -- self._top._vipLabel:setFntFile(UIUtils.bmfName_vip_1)
    -- self._top._vipLabel:getVirtualRenderer():setAdditionalKerning(-8)
    -- self._top._nextLabel = self:getUI("bg.layer.vipbg.top.layer_vip_info.vipNextLabel")
    -- self._top._nextLabel:setFntFile(UIUtils.bmfName_vip)

    local top = self:getUI("bg.layer.vipbg.top")
    self._top._vipLabel = cc.LabelBMFont:create("1", UIUtils.bmfName_vip_1)
    self._top._vipLabel:setAnchorPoint(cc.p(0,0.5))
    self._top._vipLabel:setPosition(self._top._vipImage:getPositionX()+self._top._vipImage:getContentSize().width*0.5+2, self._top._vipImage:getPositionY() + 15)
    top:addChild(self._top._vipLabel, 5)

    local vipMC = mcMgr:createViewMC("hongsechoudaiguang_vipanim", true, false, function()
    end, RGBA8888)
    vipMC:setPlaySpeed(1, true)
    vipMC:setPosition(top:getContentSize().width / 2, top:getContentSize().height / 2 + 2)
    top:addChild(vipMC, 1000)

    local layer_vip_info = self:getUI("bg.layer.vipbg.top.layer_vip_info")
    self._top._nextLabel = cc.LabelBMFont:create("1", UIUtils.bmfName_vip_1)
    self._top._nextLabel:setAnchorPoint(cc.p(0,0.5))
    self._top._nextLabel:setScale(0.5)
    self._top._nextLabel:setPosition(cc.p(142, 37))
    layer_vip_info:addChild(self._top._nextLabel, 1)
    --[[
    local image_title_bg = self:getUI("bg.layer.vipbg.vipPanel.layer_page.layer_current_page.layer_left.image_title_bg")
    local label_vip = cc.LabelBMFont:create("1", UIUtils.bmfName_vip_1)
    label_vip:setScale(0.5)
    label_vip:setName("label_vip")
    label_vip:setAnchorPoint(cc.p(1,0.5))
    label_vip:setPosition(cc.p(241, 37))
    image_title_bg:addChild(label_vip, 1)

    local image_title_bg = self:getUI("bg.layer.vipbg.vipPanel.layer_page.layer_new_page.layer_left.image_title_bg")
    local label_vip = cc.LabelBMFont:create("1", UIUtils.bmfName_vip_1)
    label_vip:setScale(0.5)
    label_vip:setName("label_vip")
    label_vip:setAnchorPoint(cc.p(1,0.5))
    label_vip:setPosition(cc.p(241, 37))
    image_title_bg:addChild(label_vip, 1)
    ]]
    self._vip_giftLayer = self:getUI("bg.layer.vipbg.vipPanel.layer_gift")
    self._vip_giftLayer:setOpacity(255)
    self._vip_giftLayer:setCascadeOpacityEnabled(true)

    local btnBuy = self:getUI("bg.layer.vipbg.vipPanel.layer_gift.btn_buy")
    self:initBtnUIFormat(btnBuy)

    self._top._countLabel = self:getUI("bg.layer.vipbg.top.layer_vip_info.countLabel")
    self._top._countLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._top._pro = self:getUI("bg.layer.vipbg.top.pro")
    self._top._proLabel = self:getUI("bg.layer.vipbg.top.proLabel")
    self._top._proLabel:getVirtualRenderer():setAdditionalKerning(2)
    self._top._proLabel:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    local mask = cc.Sprite:createWithSpriteFrameName("vip_exp.png")
    self._top._maskContentSize = mask:getContentSize()
    mask:setPosition(self._top._maskContentSize.width / 2, self._top._maskContentSize.height / 2)
    local clipNode = cc.ClippingNode:create()
    clipNode:setStencil(mask)
    clipNode:setAlphaThreshold(0.05)
    clipNode:setContentSize(self._top._maskContentSize)
    clipNode:setPosition(self._top._pro:getPositionX() - self._top._maskContentSize.width / 2, self._top._pro:getPositionY() - self._top._maskContentSize.height / 2)
    self._top._pro:getParent():addChild(clipNode, 4)
    self._top._pro:retain()
    self._top._pro:removeFromParent()
    self._top._pro:setPosition(self._top._maskContentSize.width / 2, self._top._maskContentSize.height / 2)
    clipNode:addChild(self._top._pro, 5)
    self._top._pro:release()
    self._top._rechargeLabel = self:getUI("bg.layer.vipbg.top.layer_vip_info.label_recharge")
    self._top._rechargeLabel:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._top._upgradeToLabel = self:getUI("bg.layer.vipbg.top.layer_vip_info.label_upgrade_to")
    self._top._upgradeToLabel:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    -- self._top._vipStencil = cc.Node:create()
    -- self._top._vipClipNode = cc.ClippingNode:create()
    -- self._top._vipClipNode:setStencil(self._top._vipStencil)
    -- self._top._vipClipNode:setAlphaThreshold(0.05)
    -- self._top._vipImage:getParent():addChild(self._top._vipClipNode, 10)
    self._top._vipMC = mcMgr:createViewMC("vip_vipanim", true)
    self._top._vipMC:setPlaySpeed(1, true)
    self._top._vipMC:setPosition(self._top._vipImage:getContentSize().width/2+8,self._top._vipImage:getContentSize().height/2+1)
    self._top._vipImage:addChild(self._top._vipMC, 20)

    self._recharge = {}
    self._recharge._tableData = tab.payment
    self._recharge._layer = self:getUI("bg.layer.vipbg.rechargePanel")
    -- self._recharge._layer:setBounceEnabled(true)
    self._recharge._vipBtn = self:getUI("bg.layer.vipbg.top.vipBtn")
    -- local mc = mcMgr:createViewMC("chongzhiguangdi_vipanim", true)
    -- mc:setPlaySpeed(1, true)
    -- mc:setPosition(self._recharge._vipBtn:getPositionX(), self._recharge._vipBtn:getPositionY())
    -- -- --self._recharge._vipBtn:getParent():addChild(mc, 0)
    local mc1 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true)
    mc1:setPlaySpeed(1, true)
    mc1:setScale(0.8)
    mc1:setPosition(self._recharge._vipBtn:getContentSize().width/2,self._recharge._vipBtn:getContentSize().height/2)
    self._recharge._vipBtn:addChild(mc1, 20)
    self:registerClickEvent(self._recharge._vipBtn, function()
        self._data = self:initVipData()

        self._vip._vipCurrentIndex = 0 == self._data.index and 1 or self._data.index
        self:switchTag(VipView.kViewTypeVip)
    end)

    local btnBuy2 = self._recharge._layer:getChildByFullName("layer_left.btn_buy")
    self:initBtnUIFormat(btnBuy2)
    self._recharge._rechargeBtns = {}
    for i = 1, 8 do
        self._recharge._rechargeBtns[i] = {}
        self._recharge._rechargeBtns[i]._btn = self:getUI("bg.layer.vipbg.rechargePanel.btn" .. i)
        self._recharge._rechargeBtns[i]._btn:setScaleAnim(false)

        local downY, clickFlag
        registerTouchEvent(
            self._recharge._rechargeBtns[i]._btn,
            function (_, _, y)
                downY = y
                clickFlag = false
                self._recharge._rechargeBtns[i]._btn:setBrightness(40)
            end, 
            function (_, _, y)
                if downY and math.abs(downY - y) > 5 then
                    clickFlag = true
                end
            end, 
            function ()
                if clickFlag == false then 
                    if not GameStatic.openVipRecharge or DIFF_PLATFORM then
                        self._viewMgr:showTip("此功能尚未开放")
                        self._recharge._rechargeBtns[i]._btn:setBrightness(0)
                        return
                    end
                    self:onRechargeButtonClicked(i)
                end
                self._recharge._rechargeBtns[i]._btn:setBrightness(0)
            end,
            function ()
                self._recharge._rechargeBtns[i]._btn:setBrightness(0)
            end)


        -- self:registerClickEvent(self._recharge._rechargeBtns[i]._btn, function()
        --     if not GameStatic.openVipRecharge then
        --         self._viewMgr:showTip("此功能尚未开放")
        --         return
        --     end
        --     self:onRechargeButtonClicked(i)
        -- end)
        self._recharge._rechargeBtns[i]._image = self:getUI("bg.layer.vipbg.rechargePanel.btn" .. i .. ".image")
        --[[
        local mcName = i == 7 and "VIPxingxing1_vipanim" or "VIPxingxing1_vipanim"
        local mc = mcMgr:createViewMC(mcName, true)
        mc:setPlaySpeed(1, true)
        mc:setPosition(self._recharge._rechargeBtns[i]._image:getPositionX(), self._recharge._rechargeBtns[i]._image:getPositionY())
        ]]
        -- --self._recharge._rechargeBtns[i]._image:getParent():addChild(mc, 20)
        self._recharge._rechargeBtns[i]._name = self:getUI("bg.layer.vipbg.rechargePanel.btn" .. i .. ".name")
        self._recharge._rechargeBtns[i]._name:setFontName(UIUtils.ttfName)
        self._recharge._rechargeBtns[i]._name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        --[[
        if 7 == i then
            self._recharge._rechargeBtns[i]._name:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        else
            self._recharge._rechargeBtns[i]._name:enableOutline(cc.c4b(60, 30, 10, 255), 1)
            --self._recharge._rechargeBtns[i]._name:enable2Color(1, cc.c4b(255,232,210,255))
        end
        ]]
        self._recharge._rechargeBtns[i]._name:getVirtualRenderer():setAdditionalKerning(2)
        self._recharge._rechargeBtns[i]._rmb = self:getUI("bg.layer.vipbg.rechargePanel.btn" .. i .. ".rmb")
        --self._recharge._rechargeBtns[i]._rmb:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._recharge._rechargeBtns[i]._double = self:getUI("bg.layer.vipbg.rechargePanel.btn" .. i .. ".double")
        local label_double = self:getUI("bg.layer.vipbg.rechargePanel.btn" .. i .. ".double.label_double")
        label_double:setFontName(UIUtils.ttfName)
        label_double:setFontSize(22)
        label_double:setColor(cc.c3b(255,255,255))
        label_double:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

        self._recharge._rechargeBtns[i]._bonus = self:getUI("bg.layer.vipbg.rechargePanel.btn" .. i .. ".bonus")
        self._recharge._rechargeBtns[i]._labelBonus = self:getUI("bg.layer.vipbg.rechargePanel.btn" .. i .. ".bonus.label_bonus")
        self._recharge._rechargeBtns[i]._labelBonus:setFontName(UIUtils.ttfName)
        self._recharge._rechargeBtns[i]._labelBonus:setFontSize(22)
        self._recharge._rechargeBtns[i]._labelBonus:setColor(cc.c3b(255,255,255))
        self._recharge._rechargeBtns[i]._labelBonus:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

        --[[
        self._recharge._rechargeBtns[i]._bonus = self:getUI("bg.layer.vipbg.rechargePanel.btn" .. i .. ".bonus")
        self._recharge._rechargeBtns[i]._bonus:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        ]]

        self._recharge._rechargeBtns[i]._diaImg = self:getUI("bg.layer.vipbg.rechargePanel.btn" .. i .. ".diamondImg")
        self._recharge._rechargeBtns[i]._extendNum = self:getUI("bg.layer.vipbg.rechargePanel.btn" .. i .. ".extendNum")
        self._recharge._rechargeBtns[i]._extendNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    end

    self._recharge._serviceBtn = self:getUI("bg.layer.vipbg.rechargePanel.btn_service")
    self:registerClickEvent(self._recharge._serviceBtn, function()
        CustomServiceUtils.rechargeFailed()
    end)

    self._recharge._helpBtn = self:getUI("bg.layer.vipbg.rechargePanel.btn_help")
    self._recharge._helpBtn:setVisible(OS_IS_IOS)
    if OS_IS_IOS then
        self:registerClickEvent(self._recharge._helpBtn, function()
            self._viewMgr:showDialog("vip.VipHelpView", {}, true)
        end)
    end

    self._vip = {}
    self._vip._tableData = tab.vip
    self._vip._layer = self:getUI("bg.layer.vipbg.vipPanel")
    self._vip._rechargeBtn = self:getUI("bg.layer.vipbg.vipPanel.rechargeBtn")
    local mc = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true)
    mc:setPlaySpeed(1, true)
    mc:setScale(0.8)
    mc:setPosition(self._vip._rechargeBtn:getPositionX(), self._vip._rechargeBtn:getPositionY())
    self._vip._rechargeBtn:getParent():addChild(mc, 20)
    self:registerClickEvent(self._vip._rechargeBtn, function()
        self:switchTag(VipView.kViewTypeRecharge)
    end)

    self._vip._vipCurrentStatus = VipView.kVipViewStatusInit
    self._vip._btnLeft = self:getUI("bg.layer.vipbg.vipPanel.btn_left")
    self._vip._btnRight = self:getUI("bg.layer.vipbg.vipPanel.btn_right")
    self._vip._btnLeft:setOpacity(0)
    self._vip._btnRight:setOpacity(0)
    -- [[
    --左侧按钮特效 hgf
    self._vip._btnLeftMc = mcMgr:createViewMC("tujianzuojiantou_teamnatureanim", true, false, function (_, sender)
        sender:gotoAndPlay(0)
    end)
    -- self._vip._btnLeftMc:setPlaySpeed(0.5)
    self._vip._btnLeftMc:setPosition(25, 23)
    self._vip._btnLeft:addChild(self._vip._btnLeftMc,5)
    --右侧按钮特效 hgf
    self._vip._btnRightMc = mcMgr:createViewMC("tujianyoujiantou_teamnatureanim", true, false, function (_, sender)
        sender:gotoAndPlay(0)
    end)
    -- self._vip._btnRightMc:setPlaySpeed(0.5)
    self._vip._btnRightMc:setPosition(25, 23)
    self._vip._btnRight:addChild(self._vip._btnRightMc,5)
    --]]
    --tips小精灵 hgf
    self._tipsSprite = self:getUI("bg.layer.vipbg.vipPanel.tipsImg")
    local action = cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5,ccp(10,0)),cc.MoveBy:create(0.5,ccp(-10,0))))
    self._tipsSprite:runAction(action)

    self._vip._vipTouchPositionX = 0
    self._vip._vipLayerPage = self:getUI("bg.layer.vipbg.vipPanel.layer_page")
    self._scheduler = cc.Director:getInstance():getScheduler()
    self._vip._layerCurrentPage = self:getUI("bg.layer.vipbg.vipPanel.layer_page.layer_current_page")
    self._imageCurrentArrow = self:getUI("bg.layer.vipbg.vipPanel.layer_page.layer_current_page.layer_left.image_arrow")
    local mc = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    mc:setPosition(cc.p(self._imageCurrentArrow:getContentSize().width / 2, self._imageCurrentArrow:getContentSize().height / 2))
    self._imageCurrentArrow:addChild(mc)

    local scrollView = self:getUI("bg.layer.vipbg.vipPanel.layer_page.layer_current_page.layer_left.layer_vip_des_details")
    scrollView:addEventListener(function(sender, eventType)
        if eventType == 6 or eventType == 1 then
            self._imageCurrentArrow:setVisible(false)
        else
            self._imageCurrentArrow:setVisible(true)
        end
    end)

    --[[
    for i = 1, 8 do
        local vipGiftItem = self._vip._layerCurrentPage:getChildByFullName("layer_right.vip_gift_item_bg.vip_gift_item_" .. i)
        self:registerTouchEvent(vipGiftItem, function(x, y)
            self:startClock(vipGiftItem, 0, 0)
        end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
    end
    ]]
    self._vip._layerNewPage = self:getUI("bg.layer.vipbg.vipPanel.layer_page.layer_new_page")
    self._imageNewArrow = self:getUI("bg.layer.vipbg.vipPanel.layer_page.layer_new_page.layer_left.image_arrow")
    local mc = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    mc:setPosition(cc.p(self._imageNewArrow:getContentSize().width / 2, self._imageNewArrow:getContentSize().height / 2))
    self._imageNewArrow:addChild(mc)

    local scrollView = self:getUI("bg.layer.vipbg.vipPanel.layer_page.layer_new_page.layer_left.layer_vip_des_details")
    scrollView:addEventListener(function(sender, eventType)
        if eventType == 6 or eventType == 1 then
            self._imageNewArrow:setVisible(false)
        else
            self._imageNewArrow:setVisible(true)
        end
    end)

    --[[
    for i = 1, 8 do
        local vipGiftItem = self._vip._layerNewPage:getChildByFullName("layer_right.vip_gift_item_bg.vip_gift_item_" .. i)
        self:registerTouchEvent(vipGiftItem, function(x, y)
            self:startClock(vipGiftItem, 0, 0)
        end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
    end
    ]]
    local pageSizeWidth = self._vip._vipLayerPage:getContentSize().width
    self._vip._pagePosition = {
        left = cc.p(-pageSizeWidth, 0),
        middle = cc.p(0, 0),
        right = cc.p(pageSizeWidth, 0)
    }

    if VipView.kViewTypeRecharge == self._viewType then
        self._recharge._vipBtn:setVisible(true)
        self._vip._rechargeBtn:setVisible(false)
        self._recharge._layer:setVisible(true)
        self._vip._layer:setVisible(false)
        self._tipsSprite:setVisible(false)
    elseif VipView.kViewTypeVip == self._viewType then
        self._recharge._vipBtn:setVisible(false)
        self._vip._rechargeBtn:setVisible(true)
        self._recharge._layer:setVisible(false)
        self._vip._layer:setVisible(true)
        self._tipsSprite:setVisible(true)
    end
    --[[
    self:registerClickEventByName("btn_return", function()
        if VipView.kViewTypeVip == self._viewType then
            return self:switchTag(VipView.kViewTypeRecharge)
        end
        self._btn_return:setVisible(false)

        if self._callback and type(self._callback) == "function" then
            self._callback()
        end
        self:close()
    end)
    ]]
    self:registerClickEvent(self._vip._btnRight, function()
        self:onBtnRightClicked()
    end)

    self:registerClickEvent(self._vip._btnLeft, function()
        self:onBtnLeftClicked()
    end)

    self:registerTouchEvent(self._vip._vipLayerPage, function(_, x, y)
        self:onLayerPageBegan(x, y)
    end, function(_, x, y)
        self:onLayerPageMoved(x, y)
    end, function(_, x, y)
        self:onLayerPageEnded(x, y)
    end, function(_, x, y)
        self:onLayerPageCancelled(x, y)
    end)

    local vipData = self._vipModel:getData()
    if not (vipData.free and 1 == tonumber(vipData.free)) then 
        self._serverMgr:sendMsg("VipServer", "getFreeGem", {}, true, {}, function(success, data)
            if not success then return end
            -- local reward = tab:Setting("PAYMENT_FREE").value
            -- DialogUtils.showGiftGet({gifts = reward, bottomDes = "首次打开充值界面奖励100钻石"})
            self._viewMgr:showDialog("vip.VipRewardView",{openType = 1},true)
        end)
    end

    --[[
    -- 临时帮助按钮
    local buttonHelp = ccui.Button:create("globalButtonUI13_3_1.png", "globalButtonUI13_3_1.png", "globalButtonUI13_3_1.png", 1)
    buttonHelp:setTitleText("帮助")
    buttonHelp:setTitleFontSize(24)
    buttonHelp:setTitleFontName(UIUtils.ttfName)
    --buttonHelp:setColor(cc.c4b(255, 250, 220, 255))
    buttonHelp:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine2, 2)
    buttonHelp:setPosition(self._vip._layer:getContentSize().width / 1.5 - 25, self._vip._layer:getContentSize().height / 5 - 25)
    buttonHelp:setSwallowTouches(false)
    self._recharge._layer:addChild(buttonHelp, 100)
    self:registerClickEvent(buttonHelp, function()
        CustomServiceUtils.rechargeFailed()
    end)
    ]]

    self:listenReflash("VipModel", self.onShow)
    self:listenReflash("GuildRedModel", self.checkRandRed)

end

function VipView:onShow()
    if self._modelMgr:getModel("VipModel"):isNeedRequest() then
        self:doRequestData(callback, errorCallback)
    else
        self._data = self:initVipData()
        -- dump(self._data,"123123")
        self._vip._vipCurrentIndex = 0 == self._data.index and 1 or self._data.index
        self:switchTag(self._viewType, true)
    end
end

function VipView:initVipData()
    local result = clone(self._modelMgr:getModel("VipModel"):getData())
    local userData = self._modelMgr:getModel("UserModel"):getData()
    result.currentTotalGem = userData.freeGem + userData.payGem
    result.currentTotalExp = result.exp
    result.index = result.level <= VipView.kMaxVipLevel and result.level or VipView.kMaxVipLevel
    if self._specifiedIndex then 
        result.index = self._specifiedIndex
        self._specifiedIndex = nil
    end
    result.recharge = clone(userData.rcRd)
    return result
end

function VipView:doRequestData()
    self._serverMgr:sendMsg("VipServer", "getVipInfo", {}, true, {}, function(success)
        self._data = self:initVipData()
        self._vip._vipCurrentIndex = 0 == self._data.index and 1 or self._data.index
        self:switchTag(self._viewType, true)
    end)
end

function VipView:getVipPageCount()
    local count = 0
    for k, v in pairs(self._vip._tableData) do
        count = count + 1
    end
    return count - 1
end

function VipView:switchTag(viewType, force)
    if self._viewType == viewType and not force then return end
    self._viewType = viewType
    if VipView.kViewTypeRecharge == self._viewType then
        self._recharge._vipBtn:setVisible(true)
        self._vip._rechargeBtn:setVisible(false)
        if self._giftTipsTimer then
            ScheduleMgr:unregSchedule(self._giftTipsTimer)
            self._giftTipsTimer = nil
        end
    elseif VipView.kViewTypeVip == self._viewType then
        self._recharge._vipBtn:setVisible(false)
        self._vip._rechargeBtn:setVisible(true)
    end
    self:updateUI()
end

function VipView:updateUI(viewType)
    viewType = viewType or tonumber(self._viewType)

    self._top._vipLabel:setString(self._data.level)
    self._top._vipImageSingleMC:setVisible(self._data.level < 10)
    self._top._vipImageDoubleMC:setVisible(self._data.level >= 10)

    if self._data.level < VipView.kMaxVipLevel then
        self._top._vipInfo:setVisible(true)
        self._top._nextLabel:setString("v"..self._data.level + 1)
        -- self._top._nextLabel:setString("v15")
        self._top._countLabel:setString(self._vip._tableData[self._data.level + 1].exp - self._data.currentTotalExp)
        local percent = self._data.currentTotalExp / self._vip._tableData[self._data.level + 1].exp
        self._top._pro:setPositionX((self._top._maskContentSize.width + 5) * percent - self._top._maskContentSize.width / 2 - 5)
        self._top._proLabel:setString(string.format("%d/%d", self._data.currentTotalExp, self._vip._tableData[self._data.level + 1].exp))
    else
        self._top._vipInfo:setVisible(false)
        self._top._nextLabel:setString("v"..VipView.kMaxVipLevel)
         -- self._top._nextLabel:setString("v15")
        self._top._countLabel:setString(self._vip._tableData[VipView.kMaxVipLevel].exp)
        local percent = 1
        self._top._pro:setPositionX((self._top._maskContentSize.width + 5) * percent - self._top._maskContentSize.width / 2 - 5)
        self._top._proLabel:setString(string.format("%d/%d", self._vip._tableData[VipView.kMaxVipLevel].exp, self._vip._tableData[VipView.kMaxVipLevel].exp))
    end

    local vipImageContentSize = self._top._vipImage:getContentSize()
    local contentSize = cc.size(vipImageContentSize.width, vipImageContentSize.height)
    -- self._top._vipStencil:removeAllChildren()
    -- self._top._vipStencil:setContentSize(contentSize)
    -- self._top._vipClipNode:setContentSize(contentSize)
    -- self._top._vipClipNode:setPosition(self._top._vipImage:getPositionX() - vipImageContentSize.width / 2-3, self._top._vipImage:getPositionY() - vipImageContentSize.height / 2 - 5)
    -- self._top._vipMC:setPosition(contentSize.width / 2, contentSize.height / 2)
    -- local maskVip = cc.Sprite:createWithSpriteFrameName("mask_vip.png")
    -- maskVip:setPosition(maskVip:getContentSize().width / 2 + 3, maskVip:getContentSize().height / 2 + 6)
    -- self._top._vipStencil:addChild(maskVip)

    --[[
    local currentVipLevel = self._data.level
    local ten = math.floor(currentVipLevel / 10)
    local unit = currentVipLevel % 10
    local vipImageContentSize = self._top._vipImage:getContentSize()
    local vipLabelContentSize = self._top._vipLvImage:getContentSize()
    local contentSize = cc.size(vipImageContentSize.width + vipLabelContentSize.width + 10, math.max(vipImageContentSize.height, vipLabelContentSize.height))
    self._top._vipStencil:removeAllChildren()
    self._top._vipStencil:setContentSize(contentSize)
    self._top._vipClipNode:setContentSize(contentSize)
    self._top._vipClipNode:setPosition(self._top._vipImage:getPositionX() - vipImageContentSize.width / 2, self._top._vipImage:getPositionY() - vipImageContentSize.height / 2)
    self._top._vipMC:setPosition(contentSize.width / 2, contentSize.height / 2)
    local maskVip = cc.Sprite:createWithSpriteFrameName("mask_vip.png")
    maskVip:setPosition(maskVip:getContentSize().width / 2 + 3, maskVip:getContentSize().height / 2 + 6)
    self._top._vipStencil:addChild(maskVip)
    local maskNumber = cc.Sprite:createWithSpriteFrameName(string.format("number_%d_vip.png", currentVipLevel))
    maskNumber:setScale(0.92)
    maskNumber:setPosition(maskVip:getPositionX() + maskVip:getContentSize().width / 2 + maskNumber:getContentSize().width / 2, maskVip:getPositionY())
    self._top._vipStencil:addChild(maskNumber)
    ]]

    --[[
    self._top._vipStencil:removeAllChildren()
    local currentVipLevel = self._data.level
    local ten = math.floor(currentVipLevel / 10)
    local unit = currentVipLevel % 10
    local maskVip = cc.Sprite:createWithSpriteFrameName("mask_vip.png")
    maskVip:setPosition(self._top._vipImage:getParent():convertToWorldSpace(cc.p(self._top._vipImage:getPosition())))
    --maskVip:setPosition(self._top._vipImage:convertToWindowSpace(cc.p(0, 0)))
    self._top._vipStencil:addChild(maskVip, 10)
    self._top._vipMC:setPosition(maskVip:getPosition())
    ]]
    --[[
    if ten > 0 then
        local maskNumberTen = cc.Sprite:createWithSpriteFrameName(string.format("number_%d_vip.png", ten))
        maskNumberTen:setPosition(maskVip:getPositionX() + maskVip:getContentSize().width / 2 + maskNumberTen:getContentSize().width / 2, maskVip:getContentSize().height / 2)
        self._top._vipStencil:addChild(maskNumberTen)
        local maskNumberUnit = cc.Sprite:createWithSpriteFrameName(string.format("number_%d_vip.png", unit))
        maskNumberUnit:setPosition(maskNumberTen:getPositionX() + maskNumberTen:getContentSize().width / 2 + maskNumberUnit:getContentSize().width / 2, maskNumberUnit:getContentSize().height / 2)
        self._top._vipStencil:addChild(maskNumberUnit)
    else
        local maskNumberUnit = cc.Sprite:createWithSpriteFrameName(string.format("number_%d_vip.png", unit))
        maskNumberUnit:setPosition(maskVip:getPositionX() + maskVip:getContentSize().width / 2 + maskNumberUnit:getContentSize().width / 2, maskVip:getContentSize().height / 2)
        self._top._vipStencil:addChild(maskNumberUnit)
    end
    ]]
    --[[
    if ten > 0 then
        local maskNumberTen = cc.Sprite:createWithSpriteFrameName(string.format("number_%d_vip.png", ten))
        maskNumberTen:setPosition(maskVip:getPositionX() + maskVip:getContentSize().width / 2 + maskNumberTen:getContentSize().width / 2, maskVip:getContentSize().height / 2)
        self._top._vipStencil:addChild(maskNumberTen)
        local maskNumberUnit = cc.Sprite:createWithSpriteFrameName(string.format("number_%d_vip.png", unit))
        maskNumberUnit:setPosition(maskNumberTen:getPositionX() + maskNumberTen:getContentSize().width / 2 + maskNumberUnit:getContentSize().width / 2, maskVip:getContentSize().height / 2)
        self._top._vipStencil:addChild(maskNumberUnit)
    else
        local maskNumberUnit = cc.Sprite:createWithSpriteFrameName(string.format("number_%d_vip.png", unit))
        maskNumberUnit:setPosition(maskVip:getPositionX() + maskVip:getContentSize().width / 2 + maskNumberUnit:getContentSize().width / 2, maskVip:getContentSize().height / 2)
        self._top._vipStencil:addChild(maskNumberUnit)
    end
    ]]
    --[[
    local mask = cc.Sprite:createWithSpriteFrameName("vip_exp.png")
    self._top._maskContentSize = mask:getContentSize()
    mask:setPosition(self._top._maskContentSize.width / 2, self._top._maskContentSize.height / 2)
    self._top._vipClipNode:setContentSize(self._top._maskContentSize)
    self._top._vipClipNode:setPosition(self._top._vipImage:getPositionX() - self._top._maskContentSize.width / 2, self._top._vipImage:getPositionY() - self._top._maskContentSize.height / 2)
    self._top._vipImage:getParent():addChild(self._top._vipClipNode, 10)
    self._top._vipImage:retain()
    self._top._vipImage:removeFromParent()
    self._top._vipImage:setPosition(self._top._maskContentSize.width / 2, self._top._maskContentSize.height / 2)
    self._top._vipClipNode:addChild(self._top._vipImage, 5)
    self._top._vipImage:release()
    ]]

    if VipView.kViewTypeRecharge == self._viewType then
        self._recharge._layer:setVisible(true)
        self._vip._layer:setVisible(false)
        self._tipsSprite:setVisible(false)
        self:updateRechargeUI()
    elseif VipView.kViewTypeVip == self._viewType then
        self._recharge._layer:setVisible(false)
        self._vip._layer:setVisible(true)
        self._tipsSprite:setVisible(true)
        self:updateVipUI()
    end
end

function VipView:updateRechargeUI()
    print("updateRechargeUI--------")
    local idToName = {
        [1] = "payment_30",
        [2] = "payment_60",
        [3] = "payment_98",
        [4] = "payment_198",
        [5] = "payment_328",
        [6] = "payment_648",
        [7] = "payment_6",
        [8] = "payment_18",
    }

    if OS_IS_IOS then
        idToName = {
            [1] = "diamond_300",
            [2] = "diamond_600",
            [3] = "diamond_980",
            [4] = "diamond_1980",
            [5] = "diamond_3280",
            [6] = "diamond_6480",
            [7] = "diamond_60",
            [8] = "diamond_180",
        }
    end

    for i = 1, 8 do
        local isRecharged = self._data.recharge and self._data.recharge[idToName[i]] and self._data.recharge[idToName[i]] >= 1
        self._recharge._rechargeBtns[i]._name:setString(self._recharge._tableData[idToName[i]].gem)
        self._recharge._rechargeBtns[i]._rmb:setString(self._recharge._tableData[idToName[i]].cash .. "元")
        self._recharge._rechargeBtns[i]._double:setVisible(not isRecharged)
        if not isRecharged then
            self._recharge._rechargeBtns[i]._bonus:setVisible(false)
            self._recharge._rechargeBtns[i]._labelBonus:setVisible(false)
            self._recharge._rechargeBtns[i]._extendNum:setVisible(true)
            self._recharge._rechargeBtns[i]._extendNum:setString(string.format("送%d", self._recharge._tableData[idToName[i]].gem)) --string.format("花费%d元，获得%d钻石", self._recharge._tableData[idToName[i]].cash, self._recharge._tableData[idToName[i]].gem))
        else
            if self._recharge._tableData[idToName[i]].giveGem > 0 then
                self._recharge._rechargeBtns[i]._bonus:setVisible(true)
                self._recharge._rechargeBtns[i]._labelBonus:setVisible(true)
                self._recharge._rechargeBtns[i]._labelBonus:setString(string.format("送%d%%", self._recharge._tableData[idToName[i]].giveshow * 100))
                self._recharge._rechargeBtns[i]._extendNum:setString(string.format("送%d", self._recharge._tableData[idToName[i]].giveGem)) --string.format("花费%d元，获得%d钻石", self._recharge._tableData[idToName[i]].cash, self._recharge._tableData[idToName[i]].gem))
            else
                self._recharge._rechargeBtns[i]._bonus:setVisible(false)
                self._recharge._rechargeBtns[i]._labelBonus:setVisible(false)
                self._recharge._rechargeBtns[i]._extendNum:setVisible(false)
            end
        end
        if isRecharged and self._recharge._tableData[idToName[i]].giveGem <= 0 then
            local nameW = self._recharge._rechargeBtns[i]._name:getContentSize().width
            local extendNumW = self._recharge._rechargeBtns[i]._extendNum:getContentSize().width
            local diaImgW = self._recharge._rechargeBtns[i]._diaImg:getContentSize().width * self._recharge._rechargeBtns[i]._diaImg:getScale()
            local width =  nameW + diaImgW
            local posX = (self._recharge._rechargeBtns[i]._btn:getContentSize().width - width )*0.5
            self._recharge._rechargeBtns[i]._diaImg:setPositionX(posX+diaImgW*0.5)
            self._recharge._rechargeBtns[i]._name:setPositionX(posX+diaImgW + 2)
            self._recharge._rechargeBtns[i]._extendNum:setPositionX(posX+diaImgW+nameW + 2)
        else
            local nameW = self._recharge._rechargeBtns[i]._name:getContentSize().width
            local extendNumW = self._recharge._rechargeBtns[i]._extendNum:getContentSize().width
            local diaImgW = self._recharge._rechargeBtns[i]._diaImg:getContentSize().width * self._recharge._rechargeBtns[i]._diaImg:getScale()
            local width =  nameW + extendNumW + diaImgW
            local posX = (self._recharge._rechargeBtns[i]._btn:getContentSize().width - width )*0.5
            self._recharge._rechargeBtns[i]._diaImg:setPositionX(posX+diaImgW*0.5)
            self._recharge._rechargeBtns[i]._name:setPositionX(posX+diaImgW + 2)
            self._recharge._rechargeBtns[i]._extendNum:setPositionX(posX+diaImgW+nameW + 2)
        end

        --[=[
        self._recharge._rechargeBtns[i]._name:setString(7 == i and ((self._data.recharge and self._data.recharge[idToName[i]] and 1 == self._data.recharge[idToName[i]]) and "已领取" or self._recharge._tableData[idToName[i]].giveGem .. "钻石") or self._recharge._tableData[idToName[i]].gem .. "钻石")
        self._recharge._rechargeBtns[i]._rmb:setString(7 == i and "免费" or (self._recharge._tableData[idToName[i]].cash .. "元"))
        --self._recharge._rechargeBtns[i]._double:setVisible(not (self._data.recharge and self._data.recharge[idToName[i]] and 1 == self._data.recharge[idToName[i]]) and 7 ~= i)
        self._recharge._rechargeBtns[i]._recommand:setVisible(false)
        --self._recharge._rechargeBtns[i]._bonus:setVisible(not (self._data.recharge and self._data.recharge[idToName[i]] and 1 == self._data.recharge[idToName[i]]) and 7 ~= i)
        --self._recharge._rechargeBtns[i]._bonus:setString("额外赠送钻石" .. ((not (self._data.recharge and self._data.recharge[idToName[i]] and 1 == self._data.recharge[idToName[i]])) and (self._recharge._tableData[idToName[i]].gem) or (self._recharge._tableData[idToName[i]].giveGem and self._recharge._tableData[idToName[i]].giveGem or 0)))
        ]=]
    end
    -- self:updateLeftRechargeUI()
end

function VipView:updateLeftRechargeUI()
    if true then
        self._recharge._layer:getChildByFullName("layer_left"):setVisible(false)
        return
    end
    local lvl = self._vipModel:getLevel()
    if lvl == 0 then
        lvl = 1
        self._recharge._layer:getChildByFullName("layer_left"):setVisible(false)
        return
    end
    self:updateGiftLayer(self._recharge._layer:getChildByFullName("layer_left"),lvl)
end

function VipView:onIconPressOn(node, iconId)
    --print("onIconPressOn")
    if not iconId then return end
    DialogUtils.showHintView(self, {tipType = 1, node = node, id = iconId})
end

function VipView:onIconPressOff()
    --print("onIconPressOff")
    DialogUtils.closeHintView()
end

function VipView:startClock(node, iconId)
    if VipView.kVipViewStatusKeep ~= self._vip._vipCurrentStatus then return end
    if self._timer_id then self:endClock() end
    self._first_tick = true
    self._timer_id = self._scheduler:scheduleScriptFunc(function()
        if not self._first_tick then return end
        self._first_tick = false
        self:onIconPressOn(node, iconId)
    end, 0.2, false)
end

function VipView:endClock()
   if self._timer_id then 
        self._scheduler:unscheduleScriptEntry(self._timer_id)
        self._timer_id = nil
    end
    self:onIconPressOff()
end

function VipView:updateVipPage(layer, index)

    local tableData = self._vip._tableData[index]
    local data = self._data
    --local labelTitle = layer:getChildByFullName("layer_left.image_title_bg.titleTxt")
    -- labelTitle:setFontName(UIUtils.ttfName)
    -- labelTitle:setColor(UIUtils.colorTable.titleColorRGB)
    -- labelTitle:enableOutline(UIUtils.colorTable.titleOutLineColor,1)
    local labelTitleVip = layer:getChildByFullName("layer_left.image_title_bg.label_vip")
    --labelTitleVip:setFntFile(UIUtils.bmfName_vip)
    labelTitleVip:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    labelTitleVip:setString("V"..index .. "特权")

    local labelGemNum = layer:getChildByFullName("layer_left.layer_vip_des.label_gem_num")
    --labelGemNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    labelGemNum:setString(tableData.exp)
    local zuanLabel = layer:getChildByFullName("layer_left.layer_vip_des.label_1_0_0") 
    --zuanLabel:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    zuanLabel:setPositionX(labelGemNum:getPositionX()+labelGemNum:getContentSize().width/2+zuanLabel:getContentSize().width/2+3)
    local label_1 = layer:getChildByFullName("layer_left.layer_vip_des.label_1") 
    label_1:setPositionX(labelGemNum:getPositionX()-labelGemNum:getContentSize().width/2-label_1:getContentSize().width/2-5)
    local labelVipLv = layer:getChildByFullName("layer_left.layer_vip_des.label_vip_lv")
    --labelVipLv:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    --labelVipLv:setFntFile(UIUtils.bmfName_vip_1)
    labelVipLv:getVirtualRenderer():setAdditionalKerning(2)
    labelVipLv:setString("V" .. index)
    local count = 0
    for i = 1, VipView.kVipDesCount do
        local textId = tableData["word" .. i]
        if textId then 
            count = count + 1
        end
    end

    local scrollView = layer:getChildByFullName("layer_left.layer_vip_des_details")
    scrollView:setScaleZ(100)
    -- scrollView:setBounceEnabled(true)
    scrollView:jumpToTop()
    scrollView:removeAllChildren()
    local contentWidth = scrollView:getContentSize().width
    local contentHeight = scrollView:getContentSize().height + 10
    local itemCount = count
    local deltaX, deltaY = -249, 5
    local iconWidth, iconHeight = 380, 30
    local innerWidth = contentWidth
    local innerHeight = deltaY + (deltaY + iconHeight) * itemCount
    innerHeight = innerHeight <= contentHeight and contentHeight or innerHeight
    scrollView:setInnerContainerSize(cc.size(innerWidth, innerHeight))
    for i = 1, VipView.kVipDesCount do
        repeat
            local textId = tableData["word" .. i]
            if not textId then break end
            local richText = RichTextFactory:create(lang(textId), 550, 30)    --465--->480 wangyan
            richText:formatText()
            richText:setAnchorPoint(cc.p(0, 0))
            richText:setPosition(deltaX, innerHeight - ((deltaY + iconHeight) * i) - 6) --3
            scrollView:addChild(richText)

            local imageLine = ccui.ImageView:create("image_line_vip.png", 1)
            imageLine:setPosition(220, innerHeight - ((deltaY + iconHeight) * i) + 7) --10
            scrollView:addChild(imageLine)

        until true
    end
    
    --左右按钮的提示特效  hgf
    --获取当前level下，点击过的礼包数组 
    local clickData = self._vipModel:getGiftClickData() 
    -- local noGetClick = SystemUtils.loadAccountLocalData("VIP_GIFT_NOTGET_CLICKDATA")
    -- if not noGetClick or noGetClick == "" then
    --     table.insert(clickData,{id = index})
    --     noGetClick = json.encode(clickData)
    --     SystemUtils.saveAccountLocalData("VIP_GIFT_NOTGET_CLICKDATA",noGetClick)
    -- end
    -- clickData = json.decode(noGetClick)
    local i = 0
    for k,v in pairs(clickData) do
        if v.id == index then
            break
        end        
        i = i + 1
    end
    -- print("===================i==",#clickData)
    local lvl = self._vipModel:getLevel()
    if i == #clickData and index <= lvl then
        table.insert(clickData,{id = index})

        self._vipModel:setGiftClickData(clickData)
        self._vipModel:saveClickLocalData()
    end
    -- SystemUtils.saveAccountLocalData("VIP_GIFT_NOTGET_CLICKDATA",json.encode(clickData))

    -- 更新未购买礼包tips
    --[[
    --显示规则：有未购买礼包 显示tips
      消失规则: 1.停留当前界面超过4S tips消失（重进游戏显示）
                2.若所有未购买礼包全部点击查看过，tips消失(升级VIP level , 未购买礼包点击数据及超时状态初始化)
    ]]
    local isShow = self._vipModel:getGiftTipsShowState()
    if not isShow then
        self._tipsSprite:setVisible(false)
    else
        local leftNum ,rightNum = self._vipModel:isNeedGiftTip(index,clickData)
        self._tipsSprite:setVisible((leftNum > 0) or (rightNum > 0))
        -- 停留超过4S 未购礼包提示消失
        self._timeNum = 0
        if self._giftTipsTimer then
            ScheduleMgr:unregSchedule(self._giftTipsTimer)
            self._giftTipsTimer = nil   
        end
        if self._tipsSprite:isVisible() then
            self._giftTipsTimer = ScheduleMgr:regSchedule(1000,self,function( )
                self._timeNum = self._timeNum + 1
                if 4 <= self._timeNum then
                    self._tipsSprite:setVisible(false)
                    self._vipModel:setGiftTipsShowState(false)
                    ScheduleMgr:unregSchedule(self._giftTipsTimer)
                    self._giftTipsTimer = nil
                end
            end)
        end
    end
    -- 更新giftlayer
    self:updateGiftLayer(self._vip_giftLayer,index)
end

function VipView:updateGiftLayer( layer,index )
    if not layer then return end
    if not index then 
        index = self._vipModel:getLevel()
    end
    local tableData = self._vip._tableData[index]
    local staticConfigTableData = IconUtils.iconIdMap
    local tool = tab.tool
    local toolGift = tab.toolGift
    local giftId = tableData.award[1][2]

    local count = 1
    local giftContain = toolGift[giftId].giftContain
    for i = 1, #giftContain do
        local vipGiftItem = layer:getChildByFullName("vip_gift_item_bg.vip_gift_item_" .. i)
        vipGiftItem:setOpacity(255)
        vipGiftItem:setCascadeOpacityEnabled(true)
        vipGiftItem:setVisible(true)
        local itemIcon = vipGiftItem:getChildByTag(self.kGiftItemTag)
        if itemIcon then itemIcon:removeFromParent() end
        
        if giftContain[i][1] ~= "tool" and staticConfigTableData[giftContain[i][1]] then

            -- 8888 钻石扫光
            if staticConfigTableData[giftContain[i][1]] == 39992 then
                print("钻石")
                itemIcon = IconUtils:createItemIconById({itemId = staticConfigTableData[giftContain[i][1]], num = giftContain[i][3],effect = false})
                -- 添加一个扫光效果
                -- local bgMcName1 = "saoguangshang_itemeffectcollection"
                -- 添加三个特效 hgf
                bgMc = IconUtils:addEffectByName({"tongyongdibansaoguang_itemeffectcollection"}) -- "wupinguang_itemeffectcollection",,"wupinkuangxingxing_itemeffectcollection"
                -- local sacleNum = 0.98
                -- bgMc:setPosition(cc.p(itemIcon:getContentSize().width/2,itemIcon:getContentSize().height/2))
                -- bgMc:setScale(sacleNum)
                bgMc:setName("bgMc")
                bgMc:setPosition(-5, -5)
                local effectParent = itemIcon:getChildByFullName("iconColor") --or itemIcon
                effectParent:addChild(bgMc,10)
            else 
                itemIcon = IconUtils:createItemIconById({itemId = staticConfigTableData[giftContain[i][1]], num = giftContain[i][3],effect = true})
            end
            --[=[
            self:registerTouchEvent(vipGiftItem, function(x, y)
                    self:startClock(vipGiftItem, staticConfigTableData[giftContain[i][1]])
                end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
            ]=]
        elseif giftContain[i][1] == "tool" then
            local toolData = tab:Tool(giftContain[i][2])
            if toolData.tabId == 1 then
                local teamId = string.sub(giftContain[i][2], 2, string.len(giftContain[i][2]))
                local hadTeam = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(tonumber(teamId))
                local eventStyle = 3
                if hadTeam then
                    eventStyle = 1 
                end
                itemIcon = IconUtils:createItemIconById({itemId = giftContain[i][2],num = giftContain[i][3],eventStyle = eventStyle,effect = false,clickCallback= function( )
                    self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = 15, iconId = tonumber(teamId)}, true) -- 15 本地数据兵团
                end})
            else
                itemIcon = IconUtils:createItemIconById({itemId = giftContain[i][2], num = giftContain[i][3],effect = false})
                --[[
                self:registerTouchEvent(vipGiftItem, function(x, y)
                        self:startClock(vipGiftItem, giftContain[i][2])
                    end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
                ]]    
            end            
        end
        itemIcon:setScale(0.69)
        itemIcon:setTag(self.kGiftItemTag)
        vipGiftItem:addChild(itemIcon)
        itemIcon:setOpacity(255)
        itemIcon:setCascadeOpacityEnabled(true)
        count = i
    end

    for i = count + 1, 6 do
        local vipGiftItem = layer:getChildByFullName("vip_gift_item_bg.vip_gift_item_" .. i)
        vipGiftItem:setVisible(false)
    end

    local labelOriginalCost = layer:getChildByFullName("label_original_cost")
    labelOriginalCost:setString(tableData.originalCost)
    labelOriginalCost:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    local labelForSale = layer:getChildByFullName("label_for_sale")
    labelForSale:setString(tableData.cost)
    labelForSale:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    local btnBuy = layer:getChildByFullName("btn_buy")
    -- btnBuy:setScaleAnim(false)
    btnBuy:setVisible(not (self._data.privilegeGift and 1 == self._data.privilegeGift[tostring(index)]))
    self:registerClickEvent(btnBuy, function()
        self:onBuyButtonClicked(index)
    end)
    local Image_89_0 = layer:getChildByFullName("Image_89_0")
    local label_original_cost = layer:getChildByFullName("label_original_cost")
    local label_for_sale = layer:getChildByFullName("label_for_sale")
    local image_line = layer:getChildByFullName("image_line")
    Image_89_0:setVisible(not (self._data.privilegeGift and 1 == self._data.privilegeGift[tostring(index)]))
    label_original_cost:setVisible(not (self._data.privilegeGift and 1 == self._data.privilegeGift[tostring(index)]))
    label_for_sale:setVisible(not (self._data.privilegeGift and 1 == self._data.privilegeGift[tostring(index)]))
    image_line:setVisible(not (self._data.privilegeGift and 1 == self._data.privilegeGift[tostring(index)]))

    local imageAlreadyBuy = layer:getChildByFullName("image_already_buy")
    imageAlreadyBuy:setVisible(self._data.privilegeGift and 1 == self._data.privilegeGift[tostring(index)])
end

function VipView:updateVipUI(index)
    index = index or self._vip._vipCurrentIndex
    if VipView.kVipViewStatusKeep == self._vip._vipCurrentStatus then 
        self:updateVipPage(self._vip._layerCurrentPage, index)
        local page_count = self:getVipPageCount()
        self._vip._btnLeft:setVisible(self._vip._vipCurrentIndex > 1)
        self._vip._btnRight:setVisible(self._vip._vipCurrentIndex < page_count)
        return 
    end

    
    local pagePosition = self._vip._pagePosition
    if VipView.kVipViewStatusInit == self._vip._vipCurrentStatus then
        self:updateVipPage(self._vip._layerCurrentPage, index)
        self._vip._vipCurrentStatus = VipView.kVipViewStatusKeep
    elseif VipView.kVipViewStatusRollLeft == self._vip._vipCurrentStatus then
        -- gift礼包panel淡入淡出
        self._vip_giftLayer:runAction(cc.Sequence:create(
                cc.CallFunc:create(function()
                        self._vip_giftLayer:setOpacity(0)
                    end),
                -- cc.DelayTime:create(0.05),
                cc.FadeIn:create(0.3)))
        local giftItem = self._vip_giftLayer:getChildByFullName("vip_gift_item_bg")
        local giftChildren = giftItem and giftItem:getChildren() or {}
        for k,v in pairs(giftChildren) do       
            if v then    
                local item = v:getChildByTag(self.kGiftItemTag)
                local bgMc = item and item:getChildByFullName("bgMc") or nil
                if bgMc then
                    bgMc:setVisible(false)
                end
                v:runAction(cc.Sequence:create(cc.CallFunc:create(function()
                        v:setOpacity(0)
                    end),
                    -- cc.DelayTime:create(0.05),
                    cc.FadeIn:create(0.3),
                    cc.CallFunc:create(function()
                        if bgMc then
                            bgMc:setVisible(false)
                        end
                    end) ))
            end
        end

        self:updateVipPage(self._vip._layerNewPage, index)
        self._vip._layerCurrentPage:runAction(cc.Sequence:create(
                cc.MoveTo:create(0.3, pagePosition.right),
                cc.CallFunc:create(function()
                    self._vip._layerCurrentPage:setVisible(false)
        end)))
        self._vip._layerNewPage:setVisible(true)
        self._vip._layerNewPage:setPosition(pagePosition.left)
        self._vip._layerNewPage:runAction(cc.Sequence:create(
                cc.MoveTo:create(0.3, pagePosition.middle),
                cc.CallFunc:create(function()
                    local temp = self._vip._layerCurrentPage
                    self._vip._layerCurrentPage = self._vip._layerNewPage
                    self._vip._layerNewPage = temp
                    self._vip._vipCurrentStatus = VipView.kVipViewStatusKeep
        end)))
    elseif VipView.kVipViewStatusRollRight == self._vip._vipCurrentStatus then
        -- gift礼包panel淡入淡出
        self._vip_giftLayer:runAction(cc.Sequence:create(
                cc.CallFunc:create(function()
                        self._vip_giftLayer:setOpacity(0)
                    end),
                -- cc.DelayTime:create(0.05),
                cc.FadeIn:create(0.3)))
        local giftItem = self._vip_giftLayer:getChildByFullName("vip_gift_item_bg")
        local giftChildren = giftItem and giftItem:getChildren() or {}
        for k,v in pairs(giftChildren) do       
            if v then    
                local item = v:getChildByTag(self.kGiftItemTag)
                local bgMc = item and item:getChildByFullName("bgMc") or nil
                if bgMc then
                    bgMc:setVisible(false)
                end
                v:runAction(cc.Sequence:create(cc.CallFunc:create(function()
                        v:setOpacity(0)
                    end),
                    -- cc.DelayTime:create(0.05),
                    cc.FadeIn:create(0.3),
                    cc.CallFunc:create(function()
                        if bgMc then
                            bgMc:setVisible(false)
                        end
                    end) ))
            end
        end

        self:updateVipPage(self._vip._layerNewPage, index)
        self._vip._layerCurrentPage:runAction(cc.Sequence:create(
                cc.MoveTo:create(0.3, pagePosition.left),
                cc.CallFunc:create(function()
                    self._vip._layerCurrentPage:setVisible(false)
        end)))
        self._vip._layerNewPage:setVisible(true)
        self._vip._layerNewPage:setPosition(pagePosition.right)
        self._vip._layerNewPage:runAction(cc.Sequence:create(
                cc.MoveTo:create(0.3, pagePosition.middle),
                cc.CallFunc:create(function()
                    local temp = self._vip._layerCurrentPage
                    self._vip._layerCurrentPage = self._vip._layerNewPage
                    self._vip._layerNewPage = temp
                    self._vip._vipCurrentStatus = VipView.kVipViewStatusKeep
        end)))
        
    end
    local page_count = self:getVipPageCount()
    self._vip._btnLeft:setVisible(self._vip._vipCurrentIndex > 1)
    self._vip._btnRight:setVisible(self._vip._vipCurrentIndex < page_count)
end

function VipView:onLayerPageBegan(x, y)
    local position = self._vip._vipLayerPage:convertToNodeSpace(cc.p(x, y))
    self._vip._vipTouchPositionX = position.x
end

function VipView:onLayerPageMoved(x, y)
    --local position = self._vip._vipLayerPage:convertToNodeSpace(cc.p(x, y))
end

function VipView:onLayerPageEnded(x, y)
    local position = self._vip._vipLayerPage:convertToNodeSpace(cc.p(x, y))
    local deltaX = position.x - self._vip._vipTouchPositionX
    if math.abs(deltaX) > 50 then
        self._vip._vipTouchPositionX = 0
        if deltaX < 0 then
            self:onBtnRightClicked()
        else
            self:onBtnLeftClicked()
        end
    end
end

function VipView:onLayerPageCancelled(x, y)
    local position = self._vip._vipLayerPage:convertToNodeSpace(cc.p(x, y))
    self._vip._vipTouchPositionX = 0
end

function VipView:onRechargeButtonClicked(index)
    if not (index >= 1 and index <= 8) then return end
   
    --add by wangyan  记录充值前的充值钱数
    self._vipModel:setChargeBeforeSum()
    local payName = {
        [1] = "payment_month",
        [2] = "payment_monthsuper",
    }
    local vipData = self._vipModel:getData()
    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()   --当前时间
    local isCardActiv = {}
    for i=1,2 do
        local cardData = (vipData["mCard"] and vipData["mCard"][payName[i]]) or nil
        local isBuy = (cardData and cardData["expireTime"]) and cardData["expireTime"] >= curTime or false  --是否已购买
        if isBuy then
            isCardActiv[payName[i]] = 1
        end
    end
    dump(isCardActiv, "isCardActiv")

    self._paymentModel:charge(self._paymentModel.kProductType1, index, function()
        if not (self._data and self.initVipData and self.updateUI) then return end
        self._data = self:initVipData()
        self:updateUI()

        -- add by wangyan 月卡充值激活界面弹出
        local vipData = self._vipModel:getData()
        local preSum = self._vipModel:getChargeBeforeSum()
        local curSum = vipData.sum or 0
        local payNeed = tab.setting["G_month_price"].value

        if vipData["time"] and curTime > vipData["time"] then
            preSum = 0
        end
    
        -- dump(vipData, "vipdata", 10)
        if  curSum < payNeed[2] and curSum >= payNeed[1] and preSum < payNeed[1] and preSum >= 0 then   --month
            if not isCardActiv[payName[1]] then
                self._isShowVipReward = true
                self._viewMgr:showDialog("vip.VipRewardView",{openType = 2,callback = function ()
                    self:checkRandRed()
                end},true)
            end
            
        -- elseif curSum >= payNeed[2] and preSum < payNeed[2] and preSum >= payNeed[1] then   --monthsuper
        elseif curSum == 0 and preSum < payNeed[2] and preSum >= payNeed[1] then   --monthsuper
            if not isCardActiv[payName[2]] then
                self._isShowVipReward = true
                self._viewMgr:showDialog("vip.VipRewardView",{openType = 3,callback = function ()
                    self:checkRandRed()
                end},true)
            end

        -- elseif preSum == 0 and curSum >= payNeed[2] then  --month/monthsuper
        elseif preSum < payNeed[1] and preSum >= 0 and curSum == 0 then  --month/monthsuper
            if not isCardActiv[payName[1]] and not isCardActiv[payName[2]] then
                self._isShowVipReward = true
                self._viewMgr:showDialog("vip.VipRewardView",{openType = 4,callback = function ()
                    self:checkRandRed()
                end},true)
            end
        end
    end)
end

function VipView:checkRandRed()
    if self._isShowVipReward == true then
        self._isShowVipReward = false
        return
    end
    self._modelMgr:getModel("GuildRedModel"):checkRandRed()
end

function VipView:onBuyButtonClicked(index)
    if not (index >= 1 and index <= VipView.kMaxVipLevel) then return end
    print("onBuyButtonClicked" .. index)
    if self._data.level < index then
        DialogUtils.showNeedCharge({
            desc = lang("TIP_GLOBAL_LACK_VIP"),
            callback1 = function()
                self:switchTag(VipView.kViewTypeRecharge)
            end
        })
    elseif self._data.currentTotalGem < self._vip._tableData[index].cost then
        DialogUtils.showNeedCharge({
            desc = lang("TIP_GLOBAL_RECHARGE_GEM"),
            callback1 = function()
                self:switchTag(VipView.kViewTypeRecharge)
            end
        })
    else
        DialogUtils.showBuyDialog({
            costNum = self._vip._tableData[index].cost,
            goods = "购买VIP" .. index .. "特权礼包",
            callback1 = function()
                local context = {level = index}
                self._serverMgr:sendMsg("VipServer", "buyPrivilageGift", context, true, {}, function(success, data)
                    if not success then
                        self._viewMgr:showTip("购买失败")
                        return 
                    end
                    local rewardDialog = DialogUtils.showGiftGet( { gifts = self._vip._tableData[index].award, callback = function()
                            self._data = self:initVipData()
                            self:updateUI()
                    end})
                end)
            end
        })
    end
end

function VipView:onBtnLeftClicked()
    if self._vip._vipCurrentStatus ~= VipView.kVipViewStatusKeep or self._vip._vipCurrentIndex <= 1 then return end
    local page_count = self:getVipPageCount()
    self._vip._vipCurrentIndex = self._vip._vipCurrentIndex - 1
    self._vip._vipCurrentStatus = VipView.kVipViewStatusRollLeft
    self:updateVipUI()
end

function VipView:onBtnRightClicked()
    local page_count = self:getVipPageCount()
    if self._vip._vipCurrentStatus ~= VipView.kVipViewStatusKeep or self._vip._vipCurrentIndex >= page_count then return end
    self._vip._vipCurrentIndex = self._vip._vipCurrentIndex + 1
    self._vip._vipCurrentStatus = VipView.kVipViewStatusRollRight
    self:updateVipUI()
end

function VipView:onDestroy()
    self._viewMgr:enableIndulge()
    VipView.super.onDestroy(self)
    -- print("======================VipView:onDestroy============")
    --点击礼包数据保存到本地
    -- self._vipModel:saveClickLocalData()
end

function VipView:initBtnUIFormat( btn )
    if not btn then return end 
    btn:enableOutline(cc.c4b(124, 64, 0, 255), 2)
    btn:setTitleFontSize(24) 
    btn:setTitleColor(cc.c4b(255,255,255, 255))  
    btn:setTitleFontName(UIUtils.ttfName)
end

return VipView