--[[
    Filename:    ActivityBatchExchangeView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2017-08-18 11:51:47
    Description: File description
--]]

local ActivityBatchExchangeView = class("ActivityBatchExchangeView", BasePopView)

function ActivityBatchExchangeView:ctor(params)
    ActivityBatchExchangeView.super.ctor(self)
    self._activityId = params.activityId
    self._taskData = params.taskData
    self._userModel = self._modelMgr:getModel("UserModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
end

function ActivityBatchExchangeView:onInit()
    self._closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(self._closeBtn, function ()
        self:close()
        UIUtils:reloadLuaFile("activity.ActivityBatchExchangeView")
    end)
    
    self._okBtn = self:getUI("bg.okBtn")
    self:registerClickEvent(self._okBtn, function ()
        self._okBtn:setEnabled(false)
        self._okBtn:setBright(false)
        self:useItem()
    end)

    self._title = self:getUI("bg.headBg.title")
    self._title:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._title,1)
    self._itemBg = self:getUI("bg.titlePanel.itemBg")
    self._itemNode = self:getUI("bg.titlePanel.itemNode")
    self._itemName = self:getUI("bg.titlePanel.itemName")
    UIUtils:setTitleFormat(self._itemName,2)
    self._itemNum = self:getUI("bg.titlePanel.itemNum")
    self._itemCountDes = self:getUI("bg.titlePanel.itemCountDes")
    self._useTxtNum = self:getUI("bg.detailPanel.useNum")
    self._detailPanel = self:getUI("bg.detailPanel")
    self._desPanel = self:getUI("bg.desPanel")
    self._desPanel:setVisible(false)
    self._bg1 = self:getUI("bg.bg1")
    self._greenPro = self:getUI("bg.detailPanel.greenPro")
    self._canGetValue = self:getUI("bg.desPanel.canGetValue")
    self._totalValue = self:getUI("bg.desPanel.totalValue")
    self._des1 = self:getUI("bg.titlePanel.des1")
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
            local num = self._inputNum/self._maxNum*100
            self:setSliderPercent(self._inputNum/self._maxNum*100)
        else
            self._viewMgr:showTip("已达兑换上限！")
        end
        self:refreshBtnStatus()
    end)

    self._subBtn = self:getUI("bg.detailPanel.subBtn")
    self:registerClickEvent(self._subBtn, function ()
        if self._inputNum > 1 then
            self._inputNum = self._inputNum - 1
            self:setSliderPercent(self._inputNum/self._maxNum*100)
        end
        self:refreshBtnStatus()
    end)

    self._addTenBtn = self:getUI("bg.detailPanel.addTenBtn")
    self:registerClickEvent(self._addTenBtn, function ()
        self._inputNum = self._maxNum
        self:setSliderPercent(self._inputNum/self._maxNum*100)

        self:refreshBtnStatus()
    end)

    self._inputNum = 1
    self._adjustPanel = false

    self:updateUI()
end

function ActivityBatchExchangeView:setSliderPercent(num)
    local num = num * 0.01
    local newnum= 1.5 * num /(1+0.5 * num)
    self._slider:setPercent(newnum * 100)
end

function ActivityBatchExchangeView:updateUI()
    local userData = self._userModel:getData()
    local exchange_num = self._taskData.exchange_num[1]
    local itemType = exchange_num[1]
    local itemId = exchange_num[2]
    local have, consume = 0, exchange_num[3]
    if "tool" == itemType then
        local _, toolNum = self._itemModel:getItemsById(itemId)
        have = toolNum or 0
    elseif "gold" == itemType then
        have = userData.gold or 0
    elseif "gem" == itemType then
        have = userData.gem or 0
    elseif "hDuelCoin" == itemType then
        have = userData.hDuelCoin or 0
    elseif "siegePropExp" == itemType then
        have = userData.siegePropExp or 0
    elseif "runeCoin" == itemType then
        have = userData.runeCoin
    elseif "skillBookCoin" == itemType then
        have = userData.skillBookCoin
    elseif "rune" == itemType then
        _, have = self._modelMgr:getModel("TeamModel"):getRunesById(itemId)
    end
    self._goodsId = itemId
    if "tool" ~= exchange_num[1] then
        self._goodsId = IconUtils.iconIdMap[itemType]
    end
    self._goodsNum = have
    self._goodsConsume = consume
    self._maxExchangeTimes = self._taskData.finish_max - self._taskData.times
    self._useThreshold = self._taskData.useThreshold or "one"

    local reward_num = self._taskData.reward[1]
    local rewardType = reward_num[1]
    local rewardId = reward_num[2]
    local have, consume = 0, reward_num[3]
    local name, toolD, icon = "", nil, nil

    self._rewardId = rewardId
    if "tool" ~= rewardType and IconUtils.iconIdMap[rewardType] then
        self._rewardId = IconUtils.iconIdMap[rewardType]
    end

    if "tool" == rewardType then
        local _, toolNum = self._itemModel:getItemsById(rewardId)
        have = toolNum

    elseif "gold" == rewardType then
        have = userData.gold

    elseif "gem" == rewardType then
        have = userData.gem
        
    elseif "hDuelCoin" == rewardType then
        have = userData.hDuelCoin

    elseif "siegePropExp" == rewardType then
        have = userData.siegePropExp

    elseif "runeCoin" == rewardType then
        have = userData.runeCoin

    elseif "skillBookCoin" == rewardType then
        have = userData.skillBookCoin

    elseif "rune" == rewardType then
        _, have = self._modelMgr:getModel("TeamModel"):getRunesById(rewardId)
        toolD = tab:Rune(self._rewardId)
        icon = IconUtils:createHolyIconById({suitData = toolD})

    elseif "avatarFrame" == rewardType then
        local frameD = self._modelMgr:getModel("AvatarModel"):getFrameData()
        if frameD and frameD[tostring(rewardId)] then
            have = 1
        end
        toolD = tab:AvatarFrame(rewardId)
        local param = {itemId = rewardId, itemData = toolD}
        icon = IconUtils:createHeadFrameIconById(param)

    end

    self._itemNode:removeAllChildren()
    if not icon then
        icon = IconUtils:createItemIconById({itemId = self._rewardId, itemData = toolD,eventStyle=0,effect = true})
    end
    if not toolD then
        toolD = tab:Tool(self._rewardId)
    end
    self._itemNode:addChild(icon)
    self._rewarNum = have or 0

    local name = lang(toolD["name"])
    self._itemName:setString(name)

    self._itemBg:setContentSize(cc.size(self._itemName:getContentSize().width+100,32))
    local formatNum = ItemUtils.formatItemCount(self._rewarNum)
    self._itemNum:setString(formatNum or self._rewarNum)
    self._itemCountDes:disableEffect()
    self._itemCountDes:setPositionX(self._itemNum:getPositionX()+self._itemNum:getContentSize().width)
    
    self._useNum = self._goodsNum
    self._maxNum = math.floor(self._goodsNum / self._goodsConsume)
    if self._maxNum > self._maxExchangeTimes then
        self._maxNum = self._maxExchangeTimes
    end

    if self._useThreshold == "max" then
        self._inputNum = self._maxNum
    end    
    self:setSliderPercent(self._inputNum/self._maxNum*100)
    self._greenPro:setScaleX((self._inputNum~=1 and self._inputNum or 0)/self._maxNum)
    if self._inputNum == 1 then
        self:setSliderPercent(0)
    end

    self:refreshBtnStatus()
end

function ActivityBatchExchangeView:refreshBtnStatus( )
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
    local toolD = tab:Tool(self._goodsId)
    self._useTxtNum:setString(self._inputNum)
      
    if not self._adjustPanel then  
        if toolD.typeId == 3 then
             local data = tab:ToolExp(self._goodsId)  
             if data ~= nil and data.type ~= "texp" then     
                self.bg = self:getUI("bg") 
                self._detailPanel:setPosition((self.bg:getContentSize().width - self._detailPanel:getContentSize().width)/2+2, self.bg:getContentSize().height - self._detailPanel:getContentSize().height - 15)
                self._adjustPanel = true
            end
            if data ~= nil and data.type == "texp" then     
                self._desPanel:setVisible(true)
                self._canGetValue:setString(self._inputNum*tonumber(data["exp"]))
                self._totalValue:setString(self._modelMgr:getModel("UserModel"):getData().texp) 
            end
        else
            self.bg = self:getUI("bg") 
            self._detailPanel:setPosition((self.bg:getContentSize().width - self._detailPanel:getContentSize().width)/2+2, self.bg:getContentSize().height - self._detailPanel:getContentSize().height - 15)
            self._adjustPanel = true
        end
            
    end 
end

function ActivityBatchExchangeView:useItem()
    if self._inputNum <= 0 then 
        self._viewMgr:showTip("至少兑换一个。")
        return 
    end

    self._serverMgr:sendMsg("ActivityServer", "getTaskAcReward", {acId = self._activityId, taskId = self._taskData.id, count = self._inputNum}, true, {}, function(success, result) 
        if not success then 
            self._viewMgr:showTip("兑换失败。")
            self:close()
            return 
        end

        dump(result, "result", 5)

        if result["unset"] ~= nil then 
            local removeItems = self._itemModel:handelUnsetItems(result["unset"])
            self._itemModel:delItems(removeItems, true)
        end
        
        if result["d"].items then
            self._itemModel:updateItems(result["d"].items)
            result["d"].items = nil
        end

        local reward = result.reward
        local notChange = false
        for k,v in pairs(reward) do
            if v[1] == "avatarFrame" or v["type"] == "avatarFrame" 
                or v[1] == "avatar" or v["type"] == "avatar" then
                notChange = true
            end
        end
        if notChange and table.nums(reward) == 1 then
            DialogUtils.showAvatarFrameGet( {gifts = reward, callBack = function()
                self:close()
            end})
        else
            DialogUtils.showGiftGet({gifts = reward, callback = function()
                self:close()
            end})
        end
    end)
end

function ActivityBatchExchangeView:sliderValueChange()    
    local num = self._slider:getPercent() * 0.01
    local newnum = (num/(1.5-0.5*num))*100
    self._inputNum = math.ceil((self._maxNum-0.9) * newnum /100)
    if self._inputNum < 1 then
        self._inputNum = 1
    end
    self:refreshBtnStatus()
end

return ActivityBatchExchangeView