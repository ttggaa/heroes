--[[
    Filename:    HeroFragUseView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-05-11 17:46:10
    Description: File description
--]]

local HeroBasicInformationView = require("game.view.hero.HeroBasicInformationView")
local HeroFragUseView = class("HeroFragUseView", BasePopView)

HeroFragUseView.kFragToolId = HeroBasicInformationView.kFragToolId 

HeroFragUseView.kItemTag = 1000

function HeroFragUseView:ctor(params)
    HeroFragUseView.super.ctor(self)
    self._heroData = params.heroData
    self._container = params.container
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._needStr = params.needStr or "升星还需要:"
end

function HeroFragUseView:onInit()
    -- self._scrollItem = self:getUI("bg.scrollItem")

    --dump(self._heroData, "self._heroData", 10)
    self._closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(self._closeBtn, function ()
        self._container:onFragViewClose()
        self:close()
    end)
    
    self._okBtn = self:getUI("bg.okBtn")
    self:registerClickEvent(self._okBtn, function ()
        self:useItem()
    end)

    self._title = self:getUI("bg.title")
    self._title:setFontName(UIUtils.ttfName_Title)
    self._title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    self._itemNode = self:getUI("bg.detailPanel.itemNode")
    self._useTxtNum = self:getUI("bg.detailPanel.useNum")
    --self._useTxtNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    
    self._fragNode = self:getUI("bg.detailPanel.fragNode")
    self._itemNum = self:getUI("bg.detailPanel.itemNum")
    --self._itemNum:enableOutline(cc.c4b(60, 30, 10, 255),1)
    self._greenPro = self:getUI("bg.detailPanel.greenPro")
    self._detailPanel = self:getUI("bg.detailPanel")
    self._desPanel = self:getUI("bg.desPanel")
    self._bg1 = self:getUI("bg.bg1")

    self._canGetTxt = self:getUI("bg.desPanel.canGetTxt")
    self._canGetTxt:setString(self._needStr or "")
    self._canGetValue = self:getUI("bg.desPanel.canGetValue")
    --self._canGetValue:setColor(cc.c3b(239, 109, 254))
    self._canGetValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._totalValue = self:getUI("bg.desPanel.totalValue")
    --self._totalValue:setColor(cc.c3b(255, 122, 15))
    self._totalValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self._des1 = self:getUI("bg.detailPanel.des1")

    self:initData()

    self._slider = self:getUI("bg.detailPanel.sliderBar")
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

    self._addBtn = self:getUI("bg.detailPanel.addBtn")
    self:registerClickEvent(self._addBtn, function ()
        if self._inputNum < self._maxNeed then
            self._inputNum = self._inputNum + 1
            self:setSliderPercent(self._inputNum/self._maxNeed*100)
        else
            self._viewMgr:showTip("已达使用上限！")
        end
        self:refreshBtnStatus()
    end)

    self._subBtn = self:getUI("bg.detailPanel.subBtn")
    self:registerClickEvent(self._subBtn, function ()
        if self._inputNum > 1 then
            self._inputNum = self._inputNum - 1
            self:setSliderPercent(self._inputNum/self._maxNeed*100)
        end
        self:refreshBtnStatus()
    end)

    self._addTenBtn = self:getUI("bg.detailPanel.addTenBtn")
    self:registerClickEvent(self._addTenBtn, function ()
        self._inputNum = self._maxNeed

        self:setSliderPercent(self._inputNum/self._maxNeed*100)

        self:refreshBtnStatus()
    end)

    self._adjustPanel = false

    self:updateUI()
end

function HeroFragUseView:initData()
    local _, itemNum = self._modelMgr:getModel("ItemModel"):getItemsById(HeroFragUseView.kFragToolId)
    self._itemCount = itemNum
    local _, itemNum = self._modelMgr:getModel("ItemModel"):getItemsById(self._heroData.soul)
    self._fragCount = itemNum
    self._maxNeed = self._itemCount
    local sum = 0
    for i = self._heroData.star, 3 do
        local cost = 0
        if 0 == i then
            cost = self._heroData.unlockcost[3]
        else
            cost = self._heroData.starcost[i][1][3]
        end
        if self._fragCount < cost then
            self._maxNeed = cost - self._fragCount + sum
            break
        end
        sum = sum + cost
    end
    if 4 == self._heroData.star then
        local cost = self._heroData.scrollUnlock 
                    and self._heroData.scrollUnlock[1] 
                    and self._heroData.scrollUnlock[1][3] or 30
        if self._fragCount < cost then
            self._maxNeed = cost - self._fragCount
        end
    end
    if self._maxNeed >= self._itemCount then
        self._maxNeed = self._itemCount
    end
    self._inputNum = 1
end

function HeroFragUseView:setSliderPercent(num)
    local num = num * 0.01
    local newnum= 1.5 * num /(1+0.5 * num)
    self._slider:setPercent(newnum * 100)
end

function HeroFragUseView:updateUI(data)
    local itemIcon = self._itemNode:getChildByTag(HeroFragUseView.kItemTag)
    if itemIcon then itemIcon:removeFromParent() end
    itemIcon = IconUtils:createItemIconById({itemId = HeroFragUseView.kFragToolId, num = -1, eventStyle = 0})
    self._itemNode:addChild(itemIcon)

    local itemIcon = self._fragNode:getChildByTag(HeroFragUseView.kItemTag)
    local _, itemNum = self._modelMgr:getModel("ItemModel"):getItemsById(self._heroData.soul)
    if itemIcon then itemIcon:removeFromParent() end
    itemIcon = IconUtils:createItemIconById({itemId = self._heroData.soul, num = -1, eventStyle = 0})
    self._fragNode:addChild(itemIcon)

    self:refreshBtnStatus()
end

function HeroFragUseView:refreshBtnStatus( )
    if self._inputNum == 1 then
        self._subBtn:setEnabled(false)
        self._subBtn:setBright(false) 
        self:setSliderPercent(0)
    else
        self._subBtn:setEnabled(true)
        self._subBtn:setBright(true)
    end

    if self._inputNum >= self._maxNeed then 
        self._addBtn:setEnabled(false)
        self._addBtn:setBright(false)
        self:setSliderPercent(100)
    else
        self._addBtn:setEnabled(true)
        self._addBtn:setBright(true)
    end
    self._useTxtNum:setString(self._itemCount - self._inputNum > 0 and self._itemCount - self._inputNum or 0)
    self._itemNum:setString(self._inputNum)
    self:setSliderPercent(self._inputNum / self._maxNeed * 100)
    self._greenPro:setScaleX(self._slider:getPercent()/100)
    local star = self._heroData.star
    local cost = 0
    if 0 == star then
        cost = self._heroData.unlockcost[3]
    elseif 4 == star then
        cost = self._heroData.scrollUnlock 
                and self._heroData.scrollUnlock[1] 
                and self._heroData.scrollUnlock[1][3] or 30
    else
        cost = self._heroData.starcost[star][1][3]
    end
    local upgradeNeed = cost - self._fragCount - self._inputNum
    if upgradeNeed < 0 then upgradeNeed = 0 end
    local color = UIUtils.colorTable.ccColorQuality1
    local colorType = tab:Tool(self._heroData.soul).color
    if colorType and type(colorType) == "number" then
        color = UIUtils.colorTable["ccColorQuality" .. colorType]
    end
    self._canGetValue:setColor(color)
    self._canGetValue:setString(lang(tab:Tool(self._heroData.soul).name) .. "x" .. upgradeNeed)
    local restCount = self._itemCount - self._inputNum
    if restCount < 0 then restCount = 0 end
    color = UIUtils.colorTable.ccColorQuality1
    colorType = tab:Tool(HeroFragUseView.kFragToolId).color
    if colorType and type(colorType) == "number" then
        color = UIUtils.colorTable["ccColorQuality" .. colorType]
    end
    self._totalValue:setColor(color)
    self._totalValue:setString(lang(tab:Tool(HeroFragUseView.kFragToolId).name) .. "x" .. restCount)
end

--[[
--! @function useItem
--! @desc 使用道具
--! @return 
--]]
function HeroFragUseView:useItem()
    if self._inputNum <= 0 or self._itemCount <= 0 then 
        self._viewMgr:showTip("至少转换一个，请配表")
        return 
    end

    self._serverMgr:sendMsg("HeroServer", "convertSoul", {heroId = self._heroData.id, num = self._inputNum}, true, {}, function(result, success) 
        if not success then 
            self._viewMgr:showTip("转换失败，请配表")
            self._container:onFragViewClose()
            self:close()
            return 
        end

        if result["unset"] ~= nil then 
            local removeItems = self._itemModel:handelUnsetItems(result["unset"])
            self._itemModel:delItems(removeItems, true)
        end
        
        if result["d"].items then
            self._itemModel:updateItems(result["d"].items)
            result["d"].items = nil
        end

        --self:initData()
        --self:refreshBtnStatus()
        local star = self._heroData.star
        local gifts = {}
        if 0 == star then
            gifts = clone(self._heroData.unlockcost)
            gifts[3] = self._inputNum
        elseif 4 == star then
            gifts = {"tool",300000+tonumber(self._heroData.id),self._inputNum}
        else
            gifts = clone(self._heroData.starcost[star])
            gifts[1][3] = self._inputNum
        end
        if type(gifts) == "table" and type(gifts[1]) ~= "table" then
            gifts = {gifts}
        end
        DialogUtils.showGiftGet({gifts = gifts, callback = function()
            self._container:onFragViewClose()
            self:close()
        end})
    end)
end

function HeroFragUseView:sliderValueChange()    
    local num = self._slider:getPercent() * 0.01
    -- self._inputNum = math.floor(self._itemCount * num /100)
    local newnum = (num/(1.5-0.5*num))*100
    self._inputNum = math.ceil((self._maxNeed-0.9) * newnum /100)
    if self._inputNum < 1 then
        self._inputNum = 1
    end
    self:refreshBtnStatus()
end

return HeroFragUseView