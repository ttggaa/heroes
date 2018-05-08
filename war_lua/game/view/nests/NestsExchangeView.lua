--
-- Author: <ligen@playcrab.com>
-- Date: 2016-12-13 17:45:33
--
local NestsExchangeView = class("NestsExchangeView", BasePopView)

local kGrooveMax = 10
function NestsExchangeView:ctor(data)
    NestsExchangeView.super.ctor(self)

    self._nestId = data.nId
    self._callBack = data.callBack

    self._nModel = self._modelMgr:getModel("NestsModel")

    self._pointList = {}
end


function NestsExchangeView:onInit()
    self:initData()

    local title = self:getUI("bg.title")
    UIUtils:setTitleFormat(title, 1)
    title:setString("碎片兑换")

    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("nests.NestsExchangeView")
    end)

    self._nestTempData = tab:Nests(tonumber(self._nestId))

    self._infoNode = self:getUI("bg.infoNode")

    local iconNode = self._infoNode:getChildByFullName("iconNode")
    -- 添加icon
    self._goodsId = tab:Team(self._nestTempData.team)["goods"]
    local toolData = tab:Tool(self._goodsId)
    local iconImg = IconUtils:createItemIconById({itemId = self._goodsId,itemData = toolData,eventStyle = 3,effect = true})
    iconImg:setScale(110 / iconImg:getContentSize().width)
    iconNode:addChild(iconImg)

    local nameLabel = self._infoNode:getChildByFullName("nameLabel")
    nameLabel:setFontName(UIUtils.ttfName)
    nameLabel:setString(lang(toolData.name))
    nameLabel:setColor(UIUtils.colorTable["ccColorQuality" .. toolData.color])
    nameLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    
    local itemBg = self._infoNode:getChildByFullName("itemBg")
    itemBg:setContentSize(nameLabel:getContentSize().width + 110, 35)

    local rDesLabel = self._infoNode:getChildByFullName("rDesLabel")
    rDesLabel:setString("生长率")
    rDesLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    local cDesLabel = self._infoNode:getChildByFullName("cDesLabel")
    cDesLabel:setString("存储量")
    cDesLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    self._haveLabel = self._infoNode:getChildByFullName("haveLabel")
    self._haveLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._haveLabel:setString("拥有")

    self._jianLabel = self._infoNode:getChildByFullName("jianLabel")
    self._jianLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._jianLabel:setString("个")

    self._countLabel = self._infoNode:getChildByFullName("countLabel")
    self._countLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    self._storeNode = self._infoNode:getChildByFullName("storeNode")

    for i = 1, kGrooveMax do
        local eImg = cc.Sprite:createWithSpriteFrameName("powerBg_nests.png")
        eImg:setPosition(9 + (i - 1) * 17, 13)
        eImg:setVisible(true)
        self._storeNode:addChild(eImg)
    end

    local _,count = self._modelMgr:getModel("ItemModel"):getItemsById(self._goodsId)
    self._countLabel:setString(tostring(count))
    self._haveLabel:setPositionX(self._countLabel:getPositionX() - self._countLabel:getContentSize().width*0.5 - self._haveLabel:getContentSize().width)
    self._jianLabel:setPositionX(self._countLabel:getPositionX() + self._countLabel:getContentSize().width*0.5)

    local rateLabel = self._infoNode:getChildByFullName("rateBg.lab")
    rateLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    rateLabel:setString(tostring(self._nModel:getTimeById(self._nestId, self._nestData.lvl) .. "小时/个"))

    self._rateBar = self._infoNode:getChildByFullName("rateBg.bar")

    if self._nestData.prd == 1 then
        self._lightMc = mcMgr:createViewMC("jindu_qianghua", true, false)
        self._lightMc:setScaleX(0.625)
        self._lightMc:setScaleY(1.35)
        self._lightMc:setPosition(14, 11)
        self._rateBar:addChild(self._lightMc)
    end

    local maxTimes = tab:Vip(self._modelMgr:getModel("VipModel"):getLevel()).nest
    local harvestBtn = self._infoNode:getChildByFullName("harvestBtn")
    harvestBtn:setVisible(maxTimes > 0)

    self._nestData = self._nModel:getNestDataById(self._nestId)
    self:registerClickEvent(harvestBtn,specialize(self.onHarvest, self))

    local costNode = self:getUI("bg.costNode")

    self._numTxt1 = costNode:getChildByFullName("numTxt1")
    self._numTxt1:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    self._numTxt2 = costNode:getChildByFullName("nunTxt2")
    self._numTxt2:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    self._numTxt2:setString(lang(toolData.name) .. "碎片需要:")

    self._needLabel = costNode:getChildByFullName("needLabel")
    self._needLabel:setColor(UIUtils.colorTable.ccUIBaseColor2)
    self._needLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._needLabel:setString("6个")

    self._currencyNode = costNode:getChildByFullName("currencyNode")

    local countNode = costNode:getChildByFullName("countNode")
    self._greenPro = countNode:getChildByFullName("greenPro")
    self._slider = countNode:getChildByFullName("sliderBar")
    self._slider:setCascadeOpacityEnabled(false)
    self._slider:getVirtualRenderer():setOpacity(0)

    self._slider:addEventListener(function(sender, eventType)
        local event = {}
        if eventType == 0 then
            event.name = "ON_PERCENTAGE_CHANGED"            
            self:sliderValueChange()
        end
        event.target = sender
        -- callback(event)
    end)

    self._addBtn = countNode:getChildByFullName("addBtn")
    self:registerClickEvent(self._addBtn, function ()
        if self._inputNum < self:getCanGetMax() then
            self._inputNum = self._inputNum + 1
            local num = self._inputNum/self._maxNum*100
            self:setSliderPercent(self._inputNum/self._maxNum*100)
        end
        self:refreshBtnStatus()
    end)

    self._subBtn = countNode:getChildByFullName("subBtn")
    self:registerClickEvent(self._subBtn, function ()
        if self._inputNum > 1 then
            self._inputNum = self._inputNum - 1
            self:setSliderPercent(self._inputNum/self._maxNum*100)
        end
        self:refreshBtnStatus()
    end)

    self._addTenBtn = countNode:getChildByFullName("addTenBtn")
    self:registerClickEvent(self._addTenBtn, function ()
        self._inputNum = self:getCanGetMax()
        self:setSliderPercent(self._inputNum/self._maxNum*100)
        self:refreshBtnStatus()
    end)

    self._exchangeBtn = self:getUI("bg.exchangeBtn")
    self:registerClickEvent(self._exchangeBtn, specialize(self.onExchange, self))

    self:setListenReflashWithParam(true)
    self:listenReflash("NestsModel", self.onModelReflash)
end

function NestsExchangeView:onModelReflash(eventName)
    if eventName == "update" then
        self:reflashUI()
    end
end

function NestsExchangeView:initData()
    self._nestData = clone(self._nModel:getNestDataById(self._nestId))
    self._originLus = self._nestData.lus
end

function NestsExchangeView:reflashUI()
    self:initData()
    self._storeNum = self._nestData.frg or 0
    self._maxNum = self._storeNum

    if self._storeNum < kGrooveMax then
        self:startRefreshSchedule()
        self._hasFull = false
    else
        self:closeRefreshSchedule()
        self._hasFull = true
    end

    for k, v in pairs(self._pointList) do
        v:removeFromParent(true)
    end
    self._pointList = {}

    if self._nestData.frg > kGrooveMax then
        for i = 1, kGrooveMax do
            local picName = nil
            if i <= self._nestData.frg - kGrooveMax then
                picName = "powerPointRed_nests.png"
            else
                picName = "powerPoint_nests.png"
            end
            local pImg = cc.Sprite:createWithSpriteFrameName(picName)
            pImg:setPosition(8 + (i - 1) * 17, 14)
            pImg:setVisible(true)
            self._storeNode:addChild(pImg)
            table.insert(self._pointList, pImg)
        end
    else
        for i = 1, kGrooveMax do
            if i <= self._nestData.frg then
                local pImg = cc.Sprite:createWithSpriteFrameName("powerPoint_nests.png")
                pImg:setPosition(8 + (i - 1) * 17, 14)
                pImg:setVisible(true)
                self._storeNode:addChild(pImg)
                table.insert(self._pointList, pImg)
            end
        end
    end


    self._rateBar:setPercent(self._nestData.lus / tab:Setting("NESTS_PRODUCE").value * 100)

    local costDataArr = self._nestTempData.exchange
    for i = 1, #costDataArr do
        local cData = costDataArr[i]
        local canBuyMax = math.floor(self._modelMgr:getModel("UserModel"):getCurrencyByType(cData[1]) / cData[3])
        self._maxNum = math.min(self._maxNum, canBuyMax)
    end

    self._slider:setEnabled(not (self._maxNum <= 1))
    UIUtils:setGray(self._slider, self._maxNum <= 1)
    self._subBtn:setEnabled(not (self._maxNum <= 1))
    UIUtils:setGray(self._subBtn, self._maxNum <= 1)
    self._addBtn:setEnabled(not (self._maxNum <= 1))
    UIUtils:setGray(self._addBtn, self._maxNum <= 1)
    self._addTenBtn:setEnabled(not (self._maxNum <= 1))
    UIUtils:setGray(self._addTenBtn, self._maxNum <= 1)

    if self._inputNum == nil then
        self._inputNum = 1
        self:updateNum(self._inputNum)
    end
end

-- 兑换碎片
function NestsExchangeView:onExchange()
    if self._inputNum > self._nestData.frg then
        self._viewMgr:showTip("存储量不足")
        return
    end

    local costDataArr = self._nestTempData.exchange
    for i = 1, #costDataArr do
        local cData = costDataArr[i]
        if cData[3] * self._inputNum >  self._modelMgr:getModel("UserModel"):getCurrencyByType(cData[1]) then
            local tData = tab:Tool(IconUtils.iconIdMap[cData[1]])

            if self._nModel:getIsNestsCurrency(cData[1]) then
                local param = {indexId = 2, tihuan = lang(tData.name)}
                self._viewMgr:showDialog("global.GlobalPromptDialog", param)
            else
                self._viewMgr:showTip(lang(tData.name) .. "不足")
            end
            return
        end
    end

    self._flyList = {}

    for i = self._nestData.frg, self._nestData.frg - self._inputNum + 1, -1 do
        local picName = nil
        local posX = 0
        if i > kGrooveMax then
            picName = "powerPointRed_nests.png"
            posX = 8 + (i - 1 - kGrooveMax) * 17
        else
            picName = "powerPoint_nests.png"
            posX = 8 + (i - 1) * 17
        end
        local flyPoint = cc.Sprite:createWithSpriteFrameName(picName)
        flyPoint:setPosition(posX, 14)
        flyPoint:setVisible(true)

        -- 此处创建飞行动画点，大于10的是红点，显示在黄点上，所以localZOrder为1，否则为0
        self._storeNode:addChild(flyPoint, i >= 10 and 1 or 0)
        table.insert(self._flyList, flyPoint)
    end

    self._serverMgr:sendMsg("NestsServer", "exchangeFragment", {cid = self._nestTempData.race, nid = self._nestTempData.id, num = self._inputNum}, true, { }, function(backData)
        self._viewMgr:showTip("兑换成功")

        self._exchangeBtn:setTouchEnabled(false)
        self:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(function()
                self._exchangeBtn:setTouchEnabled(true)
            end)
        ))

        self:playCompleteAni(backData)
        self._callBack(1)

        if backData.newCount < kGrooveMax then
            if self._lightMc == nil then
                self._lightMc = mcMgr:createViewMC("jindu_qianghua", true, false)
                self._lightMc:setScaleX(0.625)
                self._lightMc:setScaleY(1.35)
                self._lightMc:setPosition(14, 11)
                self._rateBar:addChild(self._lightMc)
            end
        end
    end)
end

function NestsExchangeView:playCompleteAni(backData)
    local delayTime = 0
    if backData.newCount and backData.oldCount and backData.newCount < backData.oldCount then
        for i = 1, #self._flyList do
            delayTime = 0.1 * (i - 1)
            local point = self._flyList[i]
            local countPos = cc.p(self._countLabel:getPosition())
            countPos.x = countPos.x + self._countLabel:getContentSize().width
            local movePos = self._storeNode:convertToNodeSpace(self._infoNode:convertToWorldSpace(countPos))
            point:runAction(cc.Sequence:create(
                cc.DelayTime:create(delayTime),
                cc.MoveTo:create(0.2, movePos),
                cc.CallFunc:create(function()
                    table.remove(self._flyList, i)
                    self._countLabel:setColor(UIUtils.colorTable.ccUIBaseColor2)
                    if self._countLabel:getNumberOfRunningActions() == 0 then
                        self._countLabel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1.3),cc.ScaleTo:create(0.3,1),cc.CallFunc:create(function()
                            self._countLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
                            local _,count = self._modelMgr:getModel("ItemModel"):getItemsById(self._goodsId)
                            self._countLabel:setString(tostring(count))
                            self._haveLabel:setPositionX(self._countLabel:getPositionX() - self._countLabel:getContentSize().width*0.5 - self._haveLabel:getContentSize().width)
                            self._jianLabel:setPositionX(self._countLabel:getPositionX() + self._countLabel:getContentSize().width*0.5)
                            self._countLabel:disableEffect()
                        end)))
                        print("actionHere")
                    end
                    point:removeFromParent(true)
                end)))
        end
    end

    self._inputNum = 1
    self:updateNum(self._inputNum)
end


function NestsExchangeView:onHarvest()
    if self._hasFull then
        self._viewMgr:showTip(lang("NESTS_TIP_2"))
        return
    end
    local param = {
        cId = self._nestTempData.race, 
        nId = self._nestId,
        buyTimes = self._nestData.hst or 0,
        callBack = function(data)
            self._callBack(2, data)
        end
    }
    self._viewMgr:showDialog("nests.NestsHarvestView", param)
end

function NestsExchangeView:setSliderPercent(num)
    local num = num * 0.01
    local newnum= 1.5 * num /(1+0.5 * num)
    self._slider:setPercent(newnum * 100)
end

function NestsExchangeView:sliderValueChange()    
    local num = self._slider:getPercent() * 0.01
    local newnum = (num/(1.5-0.5*num))*100
    self._inputNum = math.ceil((self._maxNum-0.9) * newnum /100)
    if self._inputNum < 1 then
        self._inputNum = 1
    end
    self:refreshBtnStatus()
end

function NestsExchangeView:refreshBtnStatus( )
    local num = self._slider:getPercent() * 0.01
    
    if self._inputNum == 1 then
        self._subBtn:setEnabled(false)
        self._subBtn:setBright(false) 
        self:setSliderPercent(0)
        self._greenPro:setScaleX(0)
    else
        self._subBtn:setEnabled(true)
        self._subBtn:setBright(true)
    end

    if self._inputNum >= self._maxNum then 
        self._addBtn:setEnabled(false)
        self._addBtn:setBright(false)
        self:setSliderPercent(100)
    else
        self._addBtn:setEnabled(true)
        self._addBtn:setBright(true)
    end
    self._greenPro:setScaleX(self._slider:getPercent()/100)

    self:updateNum(self._inputNum)
end

-- 更新兑换数量
function NestsExchangeView:updateNum(eNum)
    self._needLabel:setString(tostring(eNum) .. "个")
    self._needLabel:setPositionX(self._numTxt1:getPositionX() + self._numTxt1:getContentSize().width)
    self._numTxt2:setPositionX(self._needLabel:getPositionX() + self._needLabel:getContentSize().width)

    self._greenPro:setScaleX((self._inputNum~=1 and self._inputNum or 0)/self._maxNum)
    if self._inputNum == 1 then
        self:setSliderPercent(0)
    end

    if self._currencyNode ~= nil then
        self._currencyNode:removeAllChildren()
    end

    local costDataArr = self._nestTempData.exchange

    local infoEndPos = -30
    local rewardSpace = 30
    for i = 1, #costDataArr do
        local cData = costDataArr[i]
        local icon = nil
        local iconWidth = 30
        if cData[1] == "tool" then
            local iconPath = tab:Tool(cData[2]).art
            icon = cc.Sprite:createWithSpriteFrameName(iconPath .. ".png")
        else
            local iconPath = IconUtils.resImgMap[cData[1]]

            if iconPath == nil then
                local itemId = tonumber(IconUtils.iconIdMap[cData[1]])
                local toolD = tab:Tool(itemId)
                iconPath = IconUtils.iconPath .. toolD.art .. ".png"
                icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD})
            end
            icon = cc.Sprite:createWithSpriteFrameName(iconPath)
        end
        icon:setScale(iconWidth / icon:getContentSize().width)
        icon:setPosition(infoEndPos + iconWidth / 2 + rewardSpace, 22)
        self._currencyNode:addChild(icon)
        infoEndPos = icon:getPositionX() + iconWidth / 2

        local haveCount = self._modelMgr:getModel("UserModel"):getCurrencyByType(cData[1]) or 0
        local needCount = cData[3] * eNum
        local countTxt = nil
        if haveCount > 99999 then
            countTxt = math.floor(haveCount / 10000) .. "万" .. "/" .. tostring(needCount)
        else
            countTxt =  haveCount .. "/" .. tostring(needCount)
        end

        local rewardCount = cc.Label:createWithTTF(countTxt , UIUtils.ttfName, 22) 
        if haveCount < needCount then
            rewardCount:setColor(UIUtils.colorTable.ccUIBaseColor6)
        else
            rewardCount:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        end
        rewardCount:setPosition(infoEndPos + rewardCount:getContentSize().width / 2 + 2, 22)
        self._currencyNode:addChild(rewardCount)
        infoEndPos = rewardCount:getPositionX() + rewardCount:getContentSize().width / 2
    end

end

-- 获取可兑换最大数量
function NestsExchangeView:getCanGetMax()
    local costDataArr = self._nestTempData.exchange

    local canMax = self._maxNum
    for i = 1, #costDataArr do
        local cData = costDataArr[i]
        local haveCount = self._modelMgr:getModel("UserModel"):getCurrencyByType(cData[1]) or 0
        local needCount = cData[3]
        canMax = canMax < math.floor(haveCount / needCount) and canMax or math.floor(haveCount / needCount)
    end

--    canMax = canMax > self._maxNum and self._maxNum or canMax
    canMax = canMax == 0 and 1 or canMax
    return canMax
end

-- 开启计时刷新碎片生成进度
function NestsExchangeView:startRefreshSchedule()
    if self._timer then return end

    local produceScore = tab:Setting("NESTS_PRODUCE").value
    self._timer = ScheduleMgr:regSchedule(60000,self,function( )
        local curTimeStamp = self._modelMgr:getModel("UserModel"):getCurServerTime()
        local growTime = curTimeStamp - self._nestData.lut
        local rate = tab:Nests(tonumber(self._nestId)).born[self._nestData.lvl]
        self._nestData.lus = self._originLus + math.floor(rate * (growTime / 60))
        self._rateBar:setPercent(self._nestData.lus / tab:Setting("NESTS_PRODUCE").value * 100)
    end)
end

-- 开启计时器
function NestsExchangeView:closeRefreshSchedule()
    if self._timer then
        ScheduleMgr:unregSchedule(self._timer)
        self._timer = nil
    end
end


function NestsExchangeView:updateCurrency()
    self:reflashUI()
    self:updateNum(self._inputNum)
end

function NestsExchangeView:onDestroy()
    self:closeRefreshSchedule()
    NestsExchangeView.super.onDestroy(self)
end

function NestsExchangeView:dtor()
    kGrooveMax = nil
    NestsExchangeView = nil
end

return NestsExchangeView