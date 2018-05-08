--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-09-13 23:09:40
--
local SpellBreakBatchView = class("SpellBreakBatchView",BasePopView)
function SpellBreakBatchView:ctor(param)
    self.super.ctor(self)
    self._callback = param and param.callback
end

--[[
    Filename:    SpellBreakBatchView.lua
    Author:      <libolong@playcrab.com>
    Datetime:    2015-06-15 11:54:59
    Description: File description
--]]

local SpellBreakBatchView = class("SpellBreakBatchView", BasePopView)

function SpellBreakBatchView:ctor()
    SpellBreakBatchView.super.ctor(self)
    
end

function SpellBreakBatchView:getAsyncRes()
    return
    {
        { "asset/ui/bag.plist", "asset/ui/bag.png" },
    }
end

function SpellBreakBatchView:onInit()
    -- self._scrollItem = self:getUI("bg.scrollItem")

    self._closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(self._closeBtn, function ()
    	self.dontRemoveRes = true
        self:close()
        UIUtils:reloadLuaFile("spellbook.SpellBreakBatchView")
    end)
    
    self._okBtn = self:getUI("bg.okBtn")
    self:registerClickEvent(self._okBtn, function ()
        -- self:useItem()
        if self._callback then
            self._callback(self._inputNum)
        end
        self:close()
    end)


    self._title = self:getUI("bg.headBg.title")
    -- self._title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._title:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._title,1)
    self._itemBg = self:getUI("bg.titlePanel.itemBg")
    self._itemNode = self:getUI("bg.titlePanel.itemNode")
    self._itemName = self:getUI("bg.titlePanel.itemName")
    -- self._itemName:enableOutline(cc.c4b(60,30,10,255),1)
    UIUtils:setTitleFormat(self._itemName,2)
    self._itemNum = self:getUI("bg.titlePanel.itemNum")
    -- self._itemNum:enableOutline(cc.c4b(60,30,10,255),2)
    self._itemCountDes = self:getUI("bg.titlePanel.itemCountDes")
    
    self._useTxtNum = self:getUI("bg.detailPanel.useNum")
    -- self._useTxtNum:enableOutline(cc.c4b(60,30,10,255),2)

    self._detailPanel = self:getUI("bg.detailPanel")
    self._bg1 = self:getUI("bg.bg1")
    self._greenPro = self:getUI("bg.detailPanel.greenPro")

    self._des1 = self:getUI("bg.titlePanel.des1")

    self._inputNum = 1

    -- self._leftNum = self:getUI("bg.leftNum_img.leftNum")
    -- self._haveNum = self:getUI("bg.haveNum_img.haveNum")
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
        if self._inputNum < self._maxNum then
            self._inputNum = self._inputNum + 1
            -- self._leftNum:setString(tonumber(self._useNum) - tonumber(self._inputNum))
            -- self._haveNum:setString(self._inputNum)
            local num = self._inputNum/self._maxNum*100
            self:setSliderPercent(self._inputNum/self._maxNum*100)
        elseif self._inputNum > boxMaxD.value then
            self._viewMgr:showTip(lang("TIPS_BEIBAO_01"))
        else
            self._viewMgr:showTip("已达使用上限！")
        end
        self:refreshBtnStatus()
    end)

    self._subBtn = self:getUI("bg.detailPanel.subBtn")
    self:registerClickEvent(self._subBtn, function ()
        if self._inputNum > 1 then
            self._inputNum = self._inputNum - 1
            self:setSliderPercent(self._inputNum/self._maxNum*100)
            -- self._itemNum:setString(self._maxNum + self._inputNum)
        end
        self:refreshBtnStatus()
    end)

    self._addTenBtn = self:getUI("bg.detailPanel.addTenBtn")
    self:registerClickEvent(self._addTenBtn, function ()
        self._inputNum = self._maxNum
        -- self._useCountInput:setString(self._inputNum)

        self:setSliderPercent(self._inputNum/self._maxNum*100)

        self:refreshBtnStatus()
    end)

    self._adjustPanel = false

end

function SpellBreakBatchView:setSliderPercent(num)
    local num = num * 0.01
    local newnum= 1.5 * num /(1+0.5 * num)
    self._slider:setPercent(newnum * 100)
end

function SpellBreakBatchView:reflashUI(data)
    -- dump("debug", data, "SpellBreakBatchView:reflashUI")
    -- dump(data)
    self._callback = self._callback or data.callback
    self._initNum = self._initNum or data.initNum
    local itemData = data.data or data
    local useThreshold = data.useThreshold or "one"
    self._useThreshold = useThreshold
    self._itemData = itemData
    local toolD = tab:Tool(itemData.goodsId)
    local boxMaxD = tab:Setting("G_TOOL_BOX_MAX")
-- dump("debug toold",toolD,"SpellBreakBatchView")
    local name = lang(toolD["name"])
    if OS_IS_WINDOWS then
        self._itemName:setString(name .. " [" .. toolD.id .. "]")
    else
        self._itemName:setString(name)
    end
    -- self._itemName:setColor(UIUtils.colorTable["ccUIBaseColor" .. toolD.color])
    self._itemBg:setContentSize(cc.size(self._itemName:getContentSize().width+100,32))
    local formatNum = ItemUtils.formatItemCount(itemData.num)
    self._itemNum:setString(formatNum or itemData.num)
    self._itemCountDes:disableEffect()
    self._itemCountDes:setPositionX(self._itemNum:getPositionX()+self._itemNum:getContentSize().width)
    -- iconUtils 创建新的icon
    self._itemNode:removeAllChildren()
    local icon = IconUtils:createItemIconById({itemId = itemData.goodsId,itemData = toolD,eventStyle=0,effect = true})
    -- icon:setContentSize(cc.size(80, 80))
    self._itemNode:addChild(icon)

    local max = itemData.num --boxMaxD["value"]
    self._useNum = itemData.num
    self._maxNum = self._useNum
    if self._maxNum > max then
        self._maxNum = max
    end

    -- self._slider:setMinimumValue(1/self._maxNum*100)

    if useThreshold == "max" then
        self._inputNum = self._maxNum
        -- self._useCountInput:setString(self._inputNum)
    else
        self._inputNum = self._initNum or 1
    end    
    self:setSliderPercent(self._inputNum/self._maxNum*100)
    self._greenPro:setScaleX((self._inputNum~=1 and self._inputNum or 0)/self._maxNum)
    if self._inputNum == 1 then
        self:setSliderPercent(0)
    end

    self:refreshBtnStatus()
end

function SpellBreakBatchView:refreshBtnStatus( )
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
    local sliderBase = 100
    local sliderPercent = self._slider:getPercent()
    sliderPercent = math.max(sliderPercent,10)
    sliderPercent = math.min(sliderPercent,95)
    self._greenPro:setScaleX(sliderPercent/100)
    local toolD = tab:Tool(self._itemData.goodsId)
    self._useTxtNum:setString(self._inputNum)
      
    if not self._adjustPanel then  
        if toolD.typeId == 3 then
             local data = tab:ToolExp(self._itemData.goodsId)  
             if data ~= nil and data.type ~= "texp" then     
                self.bg = self:getUI("bg") 
                -- self._bg1:setContentSize(487,426)
                self._detailPanel:setPosition((self.bg:getContentSize().width - self._detailPanel:getContentSize().width)/2+2, self.bg:getContentSize().height - self._detailPanel:getContentSize().height - 15)
                -- self._closeBtn:setPosition(self.bg:getContentSize().width-40,self.bg:getContentSize().height+20)
                -- self._okBtn:setPosition(self.bg:getContentSize().width/2,50)
                self._adjustPanel = true
            end
            if data ~= nil and data.type == "texp" then     
            end
        else
            self.bg = self:getUI("bg") 
            -- self._bg1:setContentSize(487,426)
            self._detailPanel:setPosition((self.bg:getContentSize().width - self._detailPanel:getContentSize().width)/2+2, self.bg:getContentSize().height - self._detailPanel:getContentSize().height - 15)
            -- self._closeBtn:setPosition(self.bg:getContentSize().width-40,self.bg:getContentSize().height+20)
            -- self._okBtn:setPosition(self.bg:getContentSize().width/2,50)
            self._adjustPanel = true
        end
            
    end 
end

--[[
--! @function useItem
--! @desc 使用道具
--! @return 
--]]
function SpellBreakBatchView:useItem()
    if self._inputNum <= 0 then 
        return 
    end
    if self._itemData.goodsId == 30000 and not tab:UserLevel(self._modelMgr:getModel("UserModel"):getData().lvl).exp then
        self._viewMgr:showTip("玩家已满级")
        return 
    end
    local giftData = tab:ToolGift(self._itemData.goodsId) or tab:EquipmentBox(self._itemData.goodsId)
    if giftData then
        local needLvl = giftData.openLv or giftData.openLevel
        if needLvl then
            local userLevel = self._modelMgr:getModel("UserModel"):getData().lvl 
            if needLvl > userLevel then
                self._viewMgr:showTip("等级" .. needLvl .."可使用")
                return 
            end
        end
    end
    
    local param = {goodsId = self._itemData.goodsId, goodsNum = self._inputNum,extraParams=nil}
    
    dump(preHave)

    local toolD = tab:Tool(self._itemData.goodsId)
    -- [[ 新增逻辑 N选一 
    
        self:sendUseItemMsg(param)
    --]]
end

-- 抽离出 发送使用物品接口
function SpellBreakBatchView:sendUseItemMsg( param )
    local preskillBookCoin = self._modelMgr:getModel("UserModel"):getData().skillBookCoin or 0
    local items = {}
    items[tostring(self._itemData.goodsId)] = self._inputNum
    self._serverMgr:sendMsg("HeroServer","resolveSpellBookPiece",{param = items}, true, {}, function(result)
        self:close(nil,function( )
	        local curskillBookCoin = ModelManager:getInstance():getModel("UserModel"):getData().skillBookCoin or 0 
	        local deltskillBookCoin = curskillBookCoin-preskillBookCoin
	        if deltskillBookCoin > 0 then
                if not preskillBookCoin then return end
                DialogUtils.showGiftGet({gifts = {{"tool",IconUtils.iconIdMap["skillBookCoin"],deltskillBookCoin}}})
	            preskillBookCoin = curskillBookCoin
	        end
        end)
    end)
end

function SpellBreakBatchView:sliderValueChange( ... )    
    local num = self._slider:getPercent() * 0.01
    -- self._inputNum = math.floor(self._maxNum * num /100)
    local newnum = (num/(1.5-0.5*num))*100
    self._inputNum = math.ceil((self._maxNum-0.9) * newnum /100)
    if self._inputNum < 1 then
        self._inputNum = 1
    end
    self:refreshBtnStatus()
end

return SpellBreakBatchView