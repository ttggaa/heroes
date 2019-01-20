--
-- Author: huangguofang
-- Date: 2018-08-29 10:56:53
--

local comMcOffset =
{
    [41] = {50,50,0.4},
    [44] = {65,65,0.45},
    [43] = {65,63,0.4},
    [40] = {65,65,0.4},
    [46] = {70,65,0.5},
    [42] = {60,80,0.4},
    [33] = {65,50,0.6},    
}
require("game.view.treasure.TreasureConst")
local TreasureDirectShopView = class("TreasureDirectShopView",BaseView)
function TreasureDirectShopView:ctor(param)
    self.super.ctor(self)
    self.initAnimType       = 2
    self._tModel            = self._modelMgr:getModel("TreasureModel")
    self._userModel         = self._modelMgr:getModel("UserModel")
    self._merchantModel     = self._modelMgr:getModel("TreasureMerchantModel")
    self._isInBackGround = false

end
function TreasureDirectShopView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView", { titleTxt = "", hideInfo = true,hideHead=true },nil)
end
function TreasureDirectShopView:getAsyncRes()
    return
    {
        { "asset/ui/treasureDirectShop.plist", "asset/ui/treasureDirectShop.png" },
        
    }
end
function TreasureDirectShopView:getBgName()
    return "ACtreasureDirectShop_Bg.jpg"
end

-- 初始化UI后会调用, 有需要请覆盖
function TreasureDirectShopView:onInit()
    self:processData()

    self._treasureName  = self:getUI("bg.infolayer.titleImg.treasureName")
    self._levelTxt      = self:getUI("bg.infolayer.titleImg.levelTxt")
    self._oldPriceTxt   = self:getUI("bg.infolayer.oldPriceTxt")
    self._priceTxt      = self:getUI("bg.infolayer.priceTxt")
    local timeDes       = self:getUI("bg.infolayer.cdPanel.timeDes")
    self._timeLabel     = self:getUI("bg.infolayer.cdPanel.timeLabel")
    self._awardPanel    = self:getUI("bg.infolayer.awardPanel")
    self._itemPanel     = self:getUI("bg.infolayer.awardPanel.itemPanel")
    local noticeTxt     = self:getUI("bg.infolayer.noticeTxt")
    noticeTxt:setString(lang("mysticalMerchant_dialogBox"))
    local ruleBtn       = self:getUI("bg.infolayer.titleImg.ruleBtn")
    registerClickEvent(ruleBtn,function(sender) 
        local ruleDesc  = lang("mystical_merchant_Rule")
        self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = ruleDesc},true)
    end)
    self._oldPriceTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._priceTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    timeDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._timeLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    -- 侧边滚动栏
    self._scrollView = self:getUI("bg.scrollBg.scrollView")
    self._scrollView:setContentSize(cc.size(320,MAX_SCREEN_HEIGHT))
    self._scrollView:setPositionY((640-MAX_SCREEN_HEIGHT)/2+40)
    self._scrollView:addEventListener(function(sender, eventType)
        if eventType == 4 then
            -- on scrolling
            self:onComScrolling()
        end
    end)
    self._scrollBg = self:getUI("bg.scrollBg")

    -- 加上下箭头
    self._downArrow = mcMgr:createViewMC("zuojiantou_teamnatureanim", true, false)
    self._downArrow:setPosition(200,620)
    self._downArrow:setRotation(65)
    self._scrollBg:addChild(self._downArrow, 5)


    self._upArrow = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    self._upArrow:setPosition(200,80)
    self._upArrow:setRotation(125)
    self._scrollBg:addChild(self._upArrow, 5)

    -- 购买
    local buyBtn = self:getUI("bg.infolayer.buyBtn")
    self:registerClickEvent(buyBtn, function(sender)
        self:buyBtnClicked(sender)
    end)
    local discount = self:getUI("bg.infolayer.buyBtn.discount")
    discount:setZOrder(5)
    discount:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor)
    self._discount = discount
    self._discountImg = self:getUI("bg.infolayer.buyBtn.priceImg")

    self:initLeftComInfo()   
    -- 倒计时
    self:updateCDTime()

    -- item 添加特效
    for i=1,3 do
        local itemBg = self._awardPanel:getChildByFullName("item" .. i)
        if itemBg then
            local mc = mcMgr:createViewMC("shenmoshangdianxuanzhong01_shenmishangdianxuanzhong", true, false)
            mc:setPosition(61, 73)
            itemBg:addChild(mc)
        end
    end

    self:listenReflash("TreasureMerchantModel", self.reflashShopInfoAndUI)
    -- iphoneX
    if ADOPT_IPHONEX then
        local parameter = self._scrollBg:getLayoutParameter()
        parameter:setMargin({left=0,top=0,right=125,bottom=0})
        self._scrollBg:setLayoutParameter(parameter)
    end

end

-- 初始化左侧组合宝物列表
function TreasureDirectShopView:initLeftComInfo( )
    -- 初始化基本界面数据
    local comTreasureTab = { }
    self._comTreasures = {}  -- 商品icon
    local shopItem = self._shopData
    local tbComTreasure = clone(tab.comTreasure)
    -- dump(self._shopData,"self._shopData==>",2)
    for k, v in pairs(self._shopData) do
        if v.allow_open == 1 then
            local comTreasure = tbComTreasure[v.TreasureId]
            comTreasure.shopGoodsType = v.type
            comTreasure.shopData = v
            table.insert(comTreasureTab, comTreasure)
        end
    end

    local idx = 1
    local maxPageCount = 1
    local x, y = 0, 0
    local comTSize = 160
    local offsetx, offsety = 25, 25
    -- local leftOffset, rightOffset = 0, 0
    local scrollW, scrollH = self._scrollView:getContentSize().width, self._scrollView:getContentSize().height
    self._scrollView:setInnerContainerSize({width=scrollW, height=scrollH})
    local comTNum = table.nums(comTreasureTab)

    local maxHeight = comTNum * comTSize
    if scrollH < maxHeight then
        self._scrollView:setInnerContainerSize({width= scrollW, height= maxHeight})
    else
        self._scrollView:setInnerContainerSize({width=scrollW, height=scrollH})
        offsety = (scrollH - comTNum * comTSize) / 2

    end
    local initSel = nil
    for k, comTreasure in pairs(comTreasureTab) do
        local icon = self:createTreasureIcon(comTreasure.id, comTreasure, false)
        y = maxHeight - idx* comTSize
        
        icon:setPositionY(y + offsety)
        self._scrollView:addChild(icon)
        -- 从新计算位置
        self:reCalculatePos(icon)

        icon._comIdx = idx
        self._comTreasures[tonumber(comTreasure.id)] = icon
        icon._TreasureId = comTreasure.id
        icon._shopGoodsType = comTreasure.shopGoodsType
        icon._data = comTreasure
        icon._shopData = comTreasure.shopData
        icon._click = true
        self:registerTouchEvent(icon,
        function()
            -- down
            icon:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create( function()
                icon._click = false
                -- self._viewMgr:showHitView({tipType = 10,id = comTreasure.id , treasureData = comTreasure})
            end )))
        end ,
        function()
            -- move
            icon._click = true
        end ,
        function()
            -- up
            if icon._click then
                self:clickTreasure(icon)
            end
            icon._click = true
            icon:stopAllActions()
        end ,
        function()
            -- out
            icon:stopAllActions()
            icon._click = true
        end
        )
        idx = idx + 1
    end
    
    initSel = self._scrollView:getChildren()[1]
    
    self:clickTreasure(initSel)
    self._comTNum = table.nums(self._comTreasures)

    self:updateArrows()
end

function TreasureDirectShopView:clickTreasure(icon,isUpdate)
    if not icon then
        return
    end
    if self._currclickIcon == icon and not isUpdate then
        return
    end
    if self._currclickIcon and self._currclickIcon._selectMc then
        self._currclickIcon._selectMc:setVisible(false)
    end
    if icon._selectMc then
        icon._selectMc:setVisible(true)
    end
    self._currclickIcon = icon
    local tbData = icon._data
    local treaData = self._tModel:getComTreasureById(tostring(tbData.id)) or {} -- 是否拥有宝物
    local stage = treaData.stage or 0
    self._treasureName:setString(lang(tbData.name))
    self._levelTxt:setString(stage .. "级")
    local currShowData = self:getCurrShowData(icon._shopGoodsType,stage)
    self._currShowData = currShowData
    -- dump(currShowData)
    local price1 = currShowData.price1 or 0
    local price2 = currShowData.price2 or 0
    self._oldPriceTxt:setString("原价￥" .. price1)
    self._priceTxt:setString("现价￥" .. price2)

    self._discount:setVisible(price1 ~= price2)
    self._discountImg:setVisible(price1 ~= price2)
    self._itemPanel:removeAllChildren()
    local reward = currShowData.reward or {}
    -- dump(reward)
    for i=1,3 do
        local v = reward[i]
        local itemBg = self._awardPanel:getChildByFullName("item" .. i)
        if v and itemBg then
            itemBg:setVisible(true)

            if v[1] == "tool" then
                itemId = v[2]
            else
                itemId = IconUtils.iconIdMap[v[1]]
            end
            local toolD = tab:Tool(tonumber(itemId))
            
            local toolData = tab:Tool(itemId)
            icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = v[3]})
            -- icon:setScale(0.4)
            icon:setPosition(itemBg:getPositionX()-46,itemBg:getPositionY()-46)

            self._itemPanel:addChild(icon)
        else
            if itemBg then
                itemBg:setVisible(false)
            end
        end
    end
end

-- 接收自定义消息
function TreasureDirectShopView:reflashUI(data)
    
end

-- 
function TreasureDirectShopView:updateArrows( )
    local comTNum = self._comTNum or table.nums(self._comTreasures)
    if comTNum > 4 then
        local offsety = self._scrollView:getInnerContainer():getPositionY()
        local scrollH = self._scrollView:getInnerContainerSize().height
        local scrollVisibleH = self._scrollView:getContentSize().height

       -- print("offsetx  ============" , offsety)
        if self._downArrow then  --_upArrow
            if  offsety > -(scrollH - scrollVisibleH) then
                self._downArrow:setVisible(true)
            else
                self._downArrow:setVisible(false)
            end
        end
        if self._upArrow then
            if offsety < 0  then
                self._upArrow:setVisible(true)
            else
                self._upArrow:setVisible(false)
            end
        end
    else
        if self._upArrow then
            self._upArrow:setVisible(false)
        end
        if self._downArrow then
            self._downArrow:setVisible(false)
        end
    end
end

-- 创建组合宝物icon
function TreasureDirectShopView:createTreasureIcon(id, data, isGray)
    local widget = ccui.Widget:create()

    local iconBg = ccui.ImageView:create()
    iconBg:setAnchorPoint(0, 0)
    widget._iconBg = iconBg
    iconBg:loadTexture("treasureDirectShop_treasureBg.png", 1)
    local iconW, iconH = iconBg:getContentSize().width, iconBg:getContentSize().height
    iconBg:ignoreContentAdaptWithSize(false)
    iconBg:setContentSize({width=iconW, height=iconH})
    widget:addChild(iconBg, -1)
    iconBg:setPosition((iconW - iconBg:getContentSize().width) / 2,(iconH - iconBg:getContentSize().height) / 2)
    widget:setContentSize({width=iconW, height=iconH})
    widget:setAnchorPoint(0, 0)
    local iconImage = ccui.ImageView:create()
    local filename = data.icon .. ".png"
    iconImage:loadTexture(filename, 1)
    iconImage:setAnchorPoint(0, 0)
    widget._iconImage = iconImage
    iconBg:addChild(iconImage,1)
    iconImage:setPosition((iconW - iconImage:getContentSize().width) / 2,(iconH - iconImage:getContentSize().height) / 2)

    local leftCountBg = ccui.ImageView:create()
    leftCountBg:loadTexture("treasureDirectShop_numBg.png", 1)
    leftCountBg:setAnchorPoint(0.5, 0.5)
    leftCountBg:setPosition(widget:getContentSize().width*0.5, 10)
    widget:addChild(leftCountBg,8)

    local leftCountTxt =  ccui.Text:create()
    local leftCount = data.shopData and data.shopData.leftCount or 0
    if not leftCount then
        leftCount = 0
    end
    leftCountTxt:setString("剩余"  .. leftCount .. "件")
    widget._leftCountTxt = leftCountTxt
    leftCountTxt:setFontSize(20)
    leftCountTxt:setColor(cc.c4b(255,245,184,255))
    leftCountTxt:enableOutline(cc.c4b(53,28,8,255),2)
    leftCountTxt:setAnchorPoint(.5, .5)
    leftCountTxt:setPosition(widget:getContentSize().width*0.5, 10)
    leftCountTxt:setFontName(UIUtils.ttfName)
    widget:addChild(leftCountTxt,9)

    if TreasureConst.comMcs[id] then
        -- print("=============",id)
        local mc = mcMgr:createViewMC(TreasureConst.comMcs[id], true, false)
        widget._mc = mc
        mc:setPlaySpeed(0.25)
        if comMcOffset then
            mc:setScale(comMcOffset[id][3])
            mc:setPosition(comMcOffset[id][1], comMcOffset[id][2])
        end
        widget:addChild(mc,1)
        iconImage:setVisible(false)
    end

    local selectMc = mcMgr:createViewMC("shenmoshangdianxuanzhong02_shenmishangdianxuanzhong", true, false)
    selectMc:setVisible(false)
    widget._selectMc = selectMc
    selectMc:setPosition(65, 65)
    widget:addChild(selectMc,5)

    return widget
end

-- 重新计算位置
function TreasureDirectShopView:reCalculatePos( comIcon )
    -- if true then return end
    local _,y = comIcon:getPositionX(),comIcon:getPositionY()
    local pos = comIcon:getParent():convertToWorldSpace(cc.p(x,y))
    local radius = 500
    local offsetX = -25
    
    local x = self:getPosX(radius, pos.y, {x=80,y=MAX_SCREEN_HEIGHT*0.5-60})
    comIcon:setPositionX(math.min(x-radius,150))
end

-- 圆形轨道坐标X
-- @param r:圆形半径
-- @param posY:对应最表Y
-- @param posC:圆心坐标
function TreasureDirectShopView:getPosX(r, posY, posC)
    local y = posY
    local cX = posC.x
    local cY = posC.y
    return (math.sqrt(math.pow(r,2) - math.pow((y - cY), 2)) + cX)
end
-- 组合宝物滚动事件回调
function TreasureDirectShopView:onComScrolling( )
    for k,comIcon in pairs(self._comTreasures) do
        self:reCalculatePos( comIcon )
    end
    self:updateArrows()
end

function TreasureDirectShopView:updateCDTime( )
    --添加倒计时
    local currTime = self._userModel:getCurServerTime()
    local acEndTime = self._merchantModel:getAcEndTime()
    local tempTime = acEndTime - currTime
    print("=================acEndTime=====",acEndTime)
    
     -- getDragonOpenData
    if tempTime > 0 then
        local day, hour, min, sec, tempValue
        tempTime = tempTime + 1
        self:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.CallFunc:create(function()
                tempTime = tempTime - 1
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
                    showTime = "00天00时00分"
                else
                    showTime = string.format("%.2d天%.2d时%.2d分", day, hour, min, sec)
                end
                self._timeLabel:setString(showTime)
            end),cc.DelayTime:create(1))
        ))
    else
        self._timeLabel:setString("00天00时00分")
    end
end

-- 购买
function TreasureDirectShopView:buyBtnClicked(sender)
    local currTime = self._userModel:getCurServerTime()
    local acEndTime = self._merchantModel:getAcEndTime()
    if acEndTime - currTime <= 0 then
        self._viewMgr:showTip("活动已结束")
        return
    end
    local leftCount = (self._currclickIcon 
                        and self._currclickIcon._shopData
                        and self._currclickIcon._shopData.leftCount
                       ) 
                        and self._currclickIcon._shopData.leftCount or 0
    if leftCount <= 0 then
        self._viewMgr:showTip("可购买的宝物数为0")
        return
    end
    local function goBuy()
        local currShowData = self._currShowData
        local goodData = tab:CashGoodsLib(currShowData.goodID)
        -- payment_android
        -- payment_ios
        local param1 = {}
        param1.ftype = 5
        param1.gname = lang(goodData.des)
        param1.gdes = lang(goodData.des)
        if OS_IS_IOS then
            param1.product_id = "com.tencent.yxwdzzjy."..goodData.payment_ios
        end
        param1.ext = json.encode({id = currShowData.id, type = currShowData.type})
        local price = currShowData.price2 or 0
        price = price * 10
        local param2 = "com.tencent.yxwdzzjy.".. goodData.payment_ios .."*".. price .."*".. 1
        self:rmbReCharge(param1,param2)
        -- self._modelMgr:getModel("PaymentModel"):chargeDirect(param1,param2)
    end

    goBuy()
end

function TreasureDirectShopView:rmbReCharge(param1,param2)
    local tag = SystemUtils.loadAccountLocalData("treasureMerchant_no_warning")
    if tag and tag == 1 then
        print("rmbReCharge 1")
        self._modelMgr:getModel("PaymentModel"):chargeDirect(param1,param2)
    else
        self._viewMgr:showDialog("shop.DirectChargeSureDialog",{
                                    localTxt = "treasureMerchant_no_warning",
                                    contentTxt = "zhigouremind2",
                                    callback = function ()
                                        print("rmbReCharge 2")
                                        self._modelMgr:getModel("PaymentModel"):chargeDirect(param1,param2)
                                    end})
    end
end

function TreasureDirectShopView:reflashShopInfoAndUI()
    print("========reflashShopInfoAndUI=======")
    self:onGetGift()

    self:updateData()
    self:clickTreasure(self._currclickIcon,true)
    if not self._currclickIcon then return end 
    local leftCount = self._currclickIcon._shopData and self._currclickIcon._shopData.leftCount or 0
    if not leftCount then
        leftCount = 0
    end
    local leftCountTxt = self._currclickIcon and self._currclickIcon._leftCountTxt or nil
    if leftCountTxt then 
        leftCountTxt:setString("剩余"  .. leftCount .. "件")
    end
end

-- 处理宝物直购数据
-- @param 
-- @param 
function TreasureDirectShopView:processData()
    local treasureMerchant = clone(tab.treasureMerchant)
    self._serverData    = self._userModel:getTreasureMerchant()
    self._shopData      = {}    -- 商品展示
    -- dump(self._serverData,"self._serverData===>",5)
   
    local tempD
    for k,v in pairs(treasureMerchant) do
        tempD = self._shopData[tonumber(v.type)]
        if not tempD then
            tempD = {}
            tempD.TreasureId = v.TreasureId
            tempD.allow_open = v.allow_open or 0
            tempD.sort = v.sort or 0
            tempD.type = tonumber(v.type)
            local leftCount = self._serverData.list and self._serverData.list[tostring(v.type)]
            if not leftCount then
                leftCount = 0
            end
            tempD.leftCount = leftCount
            tempD.goodsData = {}
            self._shopData[tonumber(v.type)] = tempD
        end
        table.insert(tempD.goodsData, v)
    end

    table.sort(self._shopData,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        else
            return a.type < b.type
        end
    end)
end

function TreasureDirectShopView:updateData()
    self._serverData    = self._userModel:getTreasureMerchant()
    local list = self._serverData.list or {}
    local tempD
    for k,v in pairs(list) do
        if self._shopData[tonumber(k)] then            
            self._shopData[tonumber(k)].leftCount = v
        end
    end
    if self._comTreasures then
        for k,v in pairs(self._comTreasures) do
            local shopD = v._shopData or {}
            local type1 = shopD.type
            if list[tostring(type1)] then
                v._shopData.leftCount = list[tostring(type1)]
            end
        end
    end

end

-- 获取当前展示的商品信息
-- @param typeId:商品类型
-- @param treasureLevel:宝物等级
function TreasureDirectShopView:getCurrShowData(typeId,treasureLevel)
    if not typeId or not treasureLevel then
        print("==========错误传参==========",typeId,treasureLevel)
        return {}
    end
    print("============typeIdtreasureLevel=====",typeId,treasureLevel)
    local data = self._shopData[1]
    for k,v in pairs(self._shopData) do
        if tonumber(v.type) == tonumber(typeId) then
            data = v
            break
        end
    end
    -- dump(data,"data==>")
    if not data or data.allow_open ~= 1 then 
        print("==========未开放==========",typeId,treasureLevel)
        return {}
    end

    local grade
    local goodsData = data.goodsData or {}
    for k,v in pairs(goodsData) do
        grade = v.grade
        for kk,vv in pairs(grade) do
            if vv == tonumber(treasureLevel) then
                return v
            end
        end
     
    end
    return goodsData[1]
end

function TreasureDirectShopView:applicationDidEnterBackground( ... )
    print("==========applicationDidEnterBackground=======")
    self._isInBackGround = true
    self:stopAllActions()
end

function TreasureDirectShopView:applicationWillEnterForeground(second)
    print("==========applicationWillEnterForeground=======")
    self._isInBackGround = false
    if self.updateCDTime then
        self:updateCDTime()
    end
end

function TreasureDirectShopView:onGetGift()
    if self._isInBackGround == false then
        local rmbResult = self._modelMgr:getModel("TreasureMerchantModel"):getGiftResult()
        if rmbResult and rmbResult["reward"] then
            DialogUtils.showGiftGet( {
                gifts = rmbResult["reward"],
                title = "恭喜获得",
                notPop=true,
                callback = function()
            end})
            self._modelMgr:getModel("TreasureMerchantModel"):clearGiftResult()
        end
    end
end


function TreasureDirectShopView.dtor()
    comMcOffset = nil
end
return TreasureDirectShopView