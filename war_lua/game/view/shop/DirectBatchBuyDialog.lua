--[[
    Filename:    DirectBatchBuyDialog.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-06-05 17:18:59
    Description: File description
--]]

local DirectBatchBuyDialog = class("DirectBatchBuyDialog", BasePopView)

local _data
local _callBack
local MAX_COUNT = 200
function DirectBatchBuyDialog:ctor(param)
    DirectBatchBuyDialog.super.ctor(self)


    if param then
        dump(param)
    end
    --value init
    self._minNum = 1
    _data  = param.data
    _callBack = param.callBack
    self:calMaxNum()
end

function DirectBatchBuyDialog:onInit()
    self._closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(self._closeBtn, function ()
        self:close()
        UIUtils:reloadLuaFile("shop.DirectBatchBuyDialog")
    end)
    
    self._okBtn = self:getUI("bg.okBtn")
    self:registerClickEvent(self._okBtn, function ()
        self:buyItem()
    end)

    self._curCount  = self:getUI("bg.detailPanel.useNum")
    self._label1    = self:getUI("bg.costPanel.label1")
    self._label2    = self:getUI("bg.costPanel.label2")
    self._label3    = self:getUI("bg.costPanel.label3")
    self._label4    = self:getUI("bg.costPanel.label4")
    self._gemImage  = self:getUI("bg.costPanel.image")
    self._costPanle = self:getUI("bg.costPanel")
    ------------------头像，名字---------------------------------
    local itemNode = self:getUI("bg.titlePanel.itemNode") 
    local nameNode = self:getUI("bg.titlePanel.itemName")
    if _data.rewardType == "hero" then
        local param = {sysHeroData = _data.toolD, effect = false}
        local icon = IconUtils:createHeroIconById(param)
        icon:setAnchorPoint(0.5,0.5)
        icon:setPosition(itemNode:getContentSize().width/2,itemNode:getContentSize().height/2)
        itemNode:addChild(icon)
    else
        local icon = IconUtils:createItemIconById({itemId = _data.itemId , itemData = _data.toolD,num = _data.num,effect = false,eventStyle = 0})
        icon:setAnchorPoint(0.5,0.5)
        icon:setPosition(itemNode:getContentSize().width/2,itemNode:getContentSize().height/2)
        itemNode:addChild(icon)
    end
    nameNode:setString(_data.name)


    self._title = self:getUI("bg.titleBg.title")
    self._title:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._title,1)
    self._itemNode = self:getUI("bg.titlePanel.itemNode")
    self._itemName = self:getUI("bg.titlePanel.itemName")
    self._detailPanel = self:getUI("bg.detailPanel")
    self._bg1 = self:getUI("bg.bg1")
    self._greenPro = self:getUI("bg.detailPanel.greenPro")
    
    self._slider = self:getUI("bg.detailPanel.sliderBar")
    self._slider:setCascadeOpacityEnabled(false)
    self._slider:getVirtualRenderer():setOpacity(0)
    self._slider:setPercent(0)
    -- self:setSliderPercent(self._minNum/self._maxNum*100)
    self._greenPro:setScaleX((self._minNum~=1 and self._minNum or 0)/self._maxNum)
    self._slider:addEventListener(function(sender, eventType)
        local event = {}
        if eventType == 0 then
            event.name = "ON_PERCENTAGE_CHANGED"    
            self:sliderValueChange()
        end
        event.target = sender
    end)
    self._addBtn = self:getUI("bg.detailPanel.addBtn")
    self:registerClickEvent(self._addBtn, function ()
        if self._minNum < self._maxNum then
            self._minNum = self._minNum + 1
            self:setSliderPercent(self._minNum/self._maxNum*100)
        else
            self._viewMgr:showTip("已达使用上限！")
        end
        self:refreshBtnStatus()
    end)

    self._subBtn = self:getUI("bg.detailPanel.subBtn")
    self:registerClickEvent(self._subBtn, function ()
        if self._minNum > 1 then
            self._minNum = self._minNum - 1
            self:setSliderPercent(self._minNum/self._maxNum*100)
        end
        self:refreshBtnStatus()
    end)

    self._addMaxBtn = self:getUI("bg.detailPanel.addTenBtn")
    self:registerClickEvent(self._addMaxBtn, function ()
        self._minNum = self._maxNum
        self:setSliderPercent(100)
        self:refreshBtnStatus()
    end)
    self:refreshCountAndCost()
end

--计算最大可够数量
function DirectBatchBuyDialog:calMaxNum()
    -- local userGem = self._modelMgr:getModel("UserModel"):getData().gem
    -- local canBuyCount = math.floor(userGem/_data.price)
    self._maxNum = math.min(MAX_COUNT,_data.leftTimes)
end

function DirectBatchBuyDialog:setSliderPercent(num)
    local num = num * 0.01
    local newnum= 1.5 * num /(1+0.5 * num)
    self._slider:setPercent(newnum * 100)
end

function DirectBatchBuyDialog:getAsyncRes()
    return 
    {
        {"asset/ui/bag.plist", "asset/ui/bag.png"}
    }
end

function DirectBatchBuyDialog:refreshCountAndCost()
    self._curCount:setString(self._minNum)
    self._label2:setString(self._minNum)
    self._label4:setString(self._minNum*_data.price)

    --adjust middle
    local _width = self._label1:getContentSize().width
    _width = _width + self._label2:getContentSize().width
    _width = _width + self._label3:getContentSize().width
    _width = _width + self._label4:getContentSize().width
    _width = _width + self._gemImage:getContentSize().width
    self._costPanle:setContentSize(_width,self._costPanle:getContentSize().height)

    self._label1:setPositionX(0)
    self._label2:setPositionX(self._label1:getPositionX() + self._label1:getContentSize().width)
    self._label3:setPositionX(self._label2:getPositionX() + self._label2:getContentSize().width)
    self._gemImage:setPositionX(self._label3:getPositionX() + self._label3:getContentSize().width)
    self._label4:setPositionX(self._gemImage:getPositionX() + self._gemImage:getContentSize().width)

end


function DirectBatchBuyDialog:refreshBtnStatus( )
    local num = self._slider:getPercent() * 0.01
    
    if self._minNum == 1 then
        self._subBtn:setEnabled(false)
        self._subBtn:setBright(false) 
        self:setSliderPercent(0)
        self._greenPro:setScaleX(0)
    else
        self._subBtn:setEnabled(true)
        self._subBtn:setBright(true)
    end

    if self._minNum >= self._maxNum then 
        self._addBtn:setEnabled(false)
        self._addBtn:setBright(false)
        self:setSliderPercent(100)
    else
        self._addBtn:setEnabled(true)
        self._addBtn:setBright(true)
    end
    local sliderBase = 100
    local sliderPercent = self._slider:getPercent()
    sliderPercent = math.max(sliderPercent,10)
    sliderPercent = math.min(sliderPercent,95)
    self._greenPro:setScaleX(sliderPercent/120)
    self:refreshCountAndCost()
end

function DirectBatchBuyDialog:sliderValueChange( ... )    
    local num = self._slider:getPercent() * 0.01
    -- self._minNum = math.floor(self._maxNum * num /100)
    local newnum = (num/(1.5-0.5*num))*100
    self._minNum = math.ceil((self._maxNum-0.9) * newnum /100)
    if self._minNum < 1 then
        self._minNum = 1
    end
    self:refreshBtnStatus()
end

function DirectBatchBuyDialog:buyItem()
    local userGem = self._modelMgr:getModel("UserModel"):getData().gem
    local totalCostGem = self._minNum*_data.price
    if totalCostGem > userGem then
        DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
            self._viewMgr:showView("vip.VipView", {viewType = 0})
        end})
        return
    end
    self._serverMgr:sendMsg("ShopServer", "buyShopItem", {id = _data.id,["type"] = "zhigou",num = self._minNum}, true, {}, function(result)
        self:close()
        audioMgr:playSound("consume")
        if _callBack then
            _callBack(result)
        end
    end)
end

function DirectBatchBuyDialog:dtor()
    _data = nil
    _callBack = nil
    MAX_COUNT = nil
end

return DirectBatchBuyDialog