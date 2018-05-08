--[[
    Filename:    ACEveryDayRebateLayer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-04-07 21:04:28
    Description: File description
--]]
-- 每日折扣
local ACEveryDayRebateLayer = class("ACEveryDayRebateLayer", require("game.view.activity.common.ActivityCommonLayer"))

-- function ACEveryDayRebateLayer:getBgName()
--     return "ac_bg_2.jpg"
-- end

-- function ACEveryDayRebateLayer:getAsyncRes()
--     return 
--     {
--         -- "asset/bg/ac_bg_2.jpg",
--         {"asset/ui/acERecharge.plist", "asset/ui/acERecharge.png"},
--     }
-- end

function ACEveryDayRebateLayer:ctor()
    ACEveryDayRebateLayer.super.ctor(self)
end

function ACEveryDayRebateLayer:destroy()
    ACEveryDayRebateLayer.super.destroy(self)
end

-- stopAllAction = 1
function ACEveryDayRebateLayer:onInit()
    self._activityRebateModel = self._modelMgr:getModel("ActivityRebateModel")
    local tab1 = self:getUI("bg.btnDay1")
    local tab2 = self:getUI("bg.btnDay2")
    local tab3 = self:getUI("bg.btnDay3")
    local tab4 = self:getUI("bg.btnDay4")
    local tab5 = self:getUI("bg.btnDay5")
    local tab6 = self:getUI("bg.btnDay6")
    local tab7 = self:getUI("bg.btnDay7")

    self:registerClickEvent(tab1, function(sender)self:tabButtonClick(sender, 1) end)
    self:registerClickEvent(tab2, function(sender)self:tabButtonClick(sender, 2) end)
    self:registerClickEvent(tab3, function(sender)self:tabButtonClick(sender, 3) end)
    self:registerClickEvent(tab4, function(sender)self:tabButtonClick(sender, 4) end)
    self:registerClickEvent(tab5, function(sender)self:tabButtonClick(sender, 5) end)
    self:registerClickEvent(tab6, function(sender)self:tabButtonClick(sender, 6) end)
    self:registerClickEvent(tab7, function(sender)self:tabButtonClick(sender, 7) end)

    self._tabEventTarget = {}
    table.insert(self._tabEventTarget, tab1)
    table.insert(self._tabEventTarget, tab2)
    table.insert(self._tabEventTarget, tab3)
    table.insert(self._tabEventTarget, tab4)
    table.insert(self._tabEventTarget, tab5)
    table.insert(self._tabEventTarget, tab6)
    table.insert(self._tabEventTarget, tab7)

    local titleTxt = self:getUI("bg.title.titleTxt")
    titleTxt:setColor(cc.c4b(240,240,0,255))
    -- titleTxt:enable2Color(1,cc.c4b(189,118,7,255))
    -- titleTxt:enableOutline(cc.c4b(27,4,2,255),2)
    titleTxt:setFontName(UIUtils.ttfName_Title)
    local oldLab = self:getUI("bg.commonBg.oldLab")
    oldLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local oldPrice = self:getUI("bg.commonBg.oldPrice")
    oldPrice:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local newLab = self:getUI("bg.commonBg.newLab")
    newLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local newPrice = self:getUI("bg.commonBg.newPrice")
    newPrice:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local haveLab = self:getUI("bg.commonBg.haveLab")
    haveLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    haveLab:setFontSize(16)
    local haveNum = self:getUI("bg.commonBg.haveNum")
    haveNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    haveNum:setFontSize(16)
    local rebateNum = self:getUI("bg.commonBg.rebateNum")
    rebateNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local rebateNum_0 = self:getUI("bg.commonBg.rebateNum_0")
    rebateNum_0:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    local oldLab = self:getUI("bg.vipBg.oldLab")
    oldLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local oldPrice = self:getUI("bg.vipBg.oldPrice")
    oldPrice:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local newLab = self:getUI("bg.vipBg.newLab")
    newLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local newPrice = self:getUI("bg.vipBg.newPrice")
    newPrice:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local haveLab = self:getUI("bg.vipBg.haveLab")
    haveLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    haveLab:setFontSize(16)
    local haveNum = self:getUI("bg.vipBg.haveNum")
    haveNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    haveNum:setFontSize(16)
    
    local rebateNum = self:getUI("bg.vipBg.rebateNum")
    rebateNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local rebateNum_0 = self:getUI("bg.vipBg.rebateNum_0")
    rebateNum_0:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local vipLevel = self:getUI("bg.vipBg.vipLevelBg.vipLevel")
    vipLevel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local vipLab = self:getUI("bg.vipBg.vipLevelBg.vipLab")
    vipLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local vipHave = self:getUI("bg.vipBg.vipLevelBg.vipHave")
    vipHave:setColor(cc.c3b(255,255,255))
    vipHave:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

-- 时间
    local activityModel = self._modelMgr:getModel("ActivityModel")
    activityModel:setACERebateDateTip()
    local everyRechargeData = self._activityRebateModel:getACERebateShowList() 
    local userModel = self._modelMgr:getModel("UserModel")
    local userTimes = userModel:getCurServerTime()
    local endTime = self:getUI("bg.time")
    endTime:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- endTime:setFontSize(22)
    local endLab = self:getUI("bg.timeLab")
    endLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- endLab:setFontSize(22)
    local tempTime = everyRechargeData.end_time - userModel:getCurServerTime() -- 85600 -- userTimes
    local day, hour, minute, second, tempValue
    -- self:stopAllActions()
    -- if stopAllAction == 2 then
    --     print(abc.abc.abc)
    -- end
    -- stopAllAction = stopAllAction + 1
    print("============stopAllActionsstopAllActions===================")
    self:runAction(cc.RepeatForever:create(
        cc.Sequence:create(cc.CallFunc:create(function()
            tempTime = tempTime - 1
            tempValue = tempTime
            -- print("day======", tempValue)
            day = math.floor(tempValue/86400) 
            tempValue = tempValue - day*86400
            -- print("hour======", tempValue)
            hour = math.floor(tempValue/3600)
            tempValue = tempValue - hour*3600
            -- print("minute r======", tempValue)
            minute = math.floor(tempValue/60)
            tempValue = tempValue - minute*60
            -- print("second ======", tempValue)
            second = math.fmod(tempValue, 60)
            local showTime = string.format("%.2d天%.2d:%.2d:%.2d", day, hour, minute, second)
            if day == 0 then
                showTime = string.format("00天%.2d:%.2d:%.2d", hour, minute, second)
            end
            if tempTime <= 0 then
                showTime = "00天00:00:00"
            end
            endTime:setString(showTime)
            endTime:setPositionX(endLab:getPositionX() + endTime:getContentSize().width + 5)
            -- endLab:setPositionX(endTime:getPositionX() - endTime:getContentSize().width)
        end), cc.DelayTime:create(1))
    ))
-- CCRepeat:create(pAction, times)

    -- self._index = 7 - math.floor(tempTime/86400)
    local tempTime = everyRechargeData.start_time - userModel:getCurServerTime() 
    self._index = -1 * math.floor(tempTime/86400)

    for i=1,7 do
        if self._index < i then
            local btnDay = self:getUI("bg.btnDay" .. i)
            btnDay:setSaturation(-100)
            self:registerClickEvent(btnDay, function()
                self._viewMgr:showTip("商品准备中，请第" .. i .. "天再来哦~")
            end)
        end
    end
    
    -- -- 向服务器请求数据
    self:getDailyDiscountInfo()
    -- self:reflashUI()
    if tonumber(self._index) > 7 then
        self._index = 7
    end
    local tempDays = self._modelMgr:getModel("ActivityModel"):getACRebateShowDays() 
    if self._modelMgr:getModel("ActivityModel"):isShowBuyDays() then
        self._modelMgr:getModel("ActivityModel"):isShowBuyDays(false)
        if tempDays and tempDays ~= 0 then
            self._index = tempDays
        end 
    end

    self:tabButtonClick(self:getUI("bg.btnDay" .. (self._index or 1)), self._index or 1)
    ACEveryDayRebateLayer.super.onInit(self)
    local timeLab = self:getUI("bg.timeLab")
    -- timeLab:enableOutline(cc.c4b(38,30,19,255), 2)
    local tishi = self:getUI("bg.tishi")
    tishi:setFontSize(22)
    print ("===================+++++++++++++++++++++++++1111111111111", self._index, tempDays)
    tishi:enableOutline(cc.c4b(60,30,10,255), 1)
    -- local time = self:getUI("bg.time")
    -- time:enableOutline(cc.c4b(38,30,19,255), 2)

end

function ACEveryDayRebateLayer:reflashUI()  
    local activityModel = self._modelMgr:getModel("ActivityModel")
    local everyRechargeData = self._activityRebateModel:getACERebateShowList() 
    local userModel = self._modelMgr:getModel("UserModel")
    local tempTime = everyRechargeData.start_time - userModel:getCurServerTime() 
    local openDay = -1 * math.floor(tempTime/86400)
    print("=ACEveryDayRebateLayer:reflashUI=================", self._index , openDay)
    if self._index < openDay then
        self._index = openDay
        for i=1,7 do
            local btnDay = self:getUI("bg.btnDay" .. i)
            if self._index < i then
                btnDay:setSaturation(-100)
                self:registerClickEvent(btnDay, function()
                    self._viewMgr:showTip("暂未开放")
                end)
            else
                btnDay:setSaturation(0)
                self:registerClickEvent(btnDay, function(sender)self:tabButtonClick(sender, i) end)
            end
        end
    end
    self:updateItemNum()
end

--[[
--! @function tabButtonClick
--! @desc 选项卡按钮点击事件处理
--! @param sender table 操作对象
--! @return 
--]]
function ACEveryDayRebateLayer:tabButtonClick(sender, day)
   if sender == nil then 
        print("==sender is nil============")
        return 
    end
    if self._tabName == sender:getName() then 
        return 
    end
    for k,v in pairs(self._tabEventTarget) do
        -- v:setTitleColor(cc.c3b(232,251,255))
        -- v:getTitleRenderer():enableOutline(cc.c4b(43, 87, 183, 178), 2)
        self:tabButtonState(v, false)
    end
    self:tabButtonState(sender, true)
    -- sender:setTitleColor(cc.c3b(117, 201, 250))
    -- sender:getTitleRenderer():enableOutline(cc.c4b(30, 75, 172, 178), 2)
    if day then
        self._day = day 
    end
    self:setCommonPanel(day)
    self:setVipPanel(day)
    self:updateItemNum()
end


-- 选项卡状态切换
function ACEveryDayRebateLayer:tabButtonState(sender, isSelected)
    sender:setBright(not isSelected)
    sender:setEnabled(not isSelected)
    if isSelected then
        sender:setTitleColor(cc.c3b(255,238,160))
        sender:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    else
        sender:setTitleColor(cc.c3b(163,117,86))
        sender:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        -- sender:getTitleRenderer():enableOutline(cc.c4b(30, 75, 172, 178), 2)
    end
end


function ACEveryDayRebateLayer:setCommonPanel(day)
    local index = tonumber(1 .. day)
    local commonItem = tab:Activity101(index)

    local activityModel = self._modelMgr:getModel("ActivityModel")
    local rebateSpecial = activityModel:getACERebateSpecialData()
    -- dump(commonItem,"commonItem ==========")
    local itemBg = self:getUI("bg.commonBg.itemBg")
    itemBg:removeAllChildren()
    local itemName = self:getUI("bg.commonBg.itemName")
    -- itemName:setColor(cc.c3b(61,202,254))
    -- itemName:enableOutline(cc.c4b(5,29,53,255), 2)
    local oldLab = self:getUI("bg.commonBg.oldLab")
    local oldGemIcon = self:getUI("bg.commonBg.oldGemIcon")
    local oldPrice = self:getUI("bg.commonBg.oldPrice")
    local newLab = self:getUI("bg.commonBg.newLab")
    local newGemIcon = self:getUI("bg.commonBg.newGemIcon")
    local newPrice = self:getUI("bg.commonBg.newPrice")
    local buyBtn = self:getUI("bg.commonBg.buyBtn")
    buyBtn:setTitleFontSize(36)
    buyBtn:getTitleRenderer():enableOutline(cc.c4b(178, 103, 3, 255), 3) --(cc.c4b(101, 33, 0, 255), 2)
    buyBtn:setColor(cc.c4b(255, 250, 220, 255))
    local haveLab = self:getUI("bg.commonBg.haveLab")
    local haveNum = self:getUI("bg.commonBg.haveNum")

    local rebateNum = self:getUI("bg.commonBg.rebateNum")
    -- rebateNum:setFontSize(40)
    local rebateNum_0 = self:getUI("bg.commonBg.rebateNum_0")
    -- rebateNum_0:setFontSize(30)
    -- 物品
    local itemIcon = itemBg:getChildByName("itemIcon")
    local itemId = commonItem.goods[2]
    local num = commonItem.goods[3]
    if IconUtils.iconIdMap[commonItem.goods[1]] then
        itemId = IconUtils.iconIdMap[commonItem.goods[1]]
    else -- if commonItem.goods[1] == "tool" then
        itemId = commonItem.goods[2]
    end
    local isShowHero = false
    local param = {}--{itemId = itemId, num = num,eventStyle = 0} 
    local toolData = tab:Tool(itemId)
    if toolData then
        itemName:setString(lang(toolData.name))
        if 6 == toolData.typeId then
            isShowHero = true
            param = {itemId = itemId, num = num,eventStyle = 0} 
        else
            param = {itemId = itemId, num = num} 
        end            
    end
    -- dump(param, "param ===========")
    if not itemIcon then
        itemIcon = IconUtils:createItemIconById(param)
        itemIcon:setName("itemIcon")
        itemIcon:setPosition(0, 5)
        itemIcon:setScale(0.84)
        itemBg:addChild(itemIcon)
    else
        IconUtils:updateItemIconByView(itemIcon, param)
    end
    local toolData = tab:Tool(itemId)
    -- dump()
    if isShowHero then
        local heroId = string.sub(itemId, 2, string.len(itemId))
        itemIcon:setTouchEnabled(true)
        itemIcon:setSwallowTouches(false)
        
        registerClickEvent(itemIcon, function()
            local NewFormationIconView = require "game.view.formation.NewFormationIconView"
            self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = tonumber(heroId)}, true)
        end)
    end
    -- 折扣
    rebateNum:setString(commonItem.discount)
    -- 价格
    oldPrice:setString(commonItem.price2)
    newPrice:setString(commonItem.price1)

    -- 气泡
    self:setQipao(commonItem, 1)
end

function ACEveryDayRebateLayer:setVipPanel(day)
    -- print("设置VIP面板")
    local index = tonumber(2 .. day)
    local vipItem = tab:Activity101(index)
    local activityModel = self._modelMgr:getModel("ActivityModel")
    local rebateSpecial = activityModel:getACERebateSpecialData()
    -- dump(commonItem,"commonItem ==========")
    local itemBg = self:getUI("bg.vipBg.itemBg")
    local itemName = self:getUI("bg.vipBg.itemName")
    -- itemName:setColor(cc.c3b(235,234,116))
    -- itemName:enableOutline(cc.c4b(37,9,53,255), 2)
    local oldLab = self:getUI("bg.vipBg.oldLab")
    local oldGemIcon = self:getUI("bg.vipBg.oldGemIcon")
    local oldPrice = self:getUI("bg.vipBg.oldPrice")
    local newLab = self:getUI("bg.vipBg.newLab")
    local newGemIcon = self:getUI("bg.vipBg.newGemIcon")
    local newPrice = self:getUI("bg.vipBg.newPrice")
    local haveNum = self:getUI("bg.vipBg.haveNum")
    
    local rebateNum = self:getUI("bg.vipBg.rebateNum")
    -- rebateNum:setFontSize(40)
    local rebateNum_0 = self:getUI("bg.vipBg.rebateNum_0")
    -- rebateNum_0:setFontSize(30)
    local vipLevel = self:getUI("bg.vipBg.vipLevelBg.vipLevel")

    -- 物品
    local itemIcon = itemBg:getChildByName("itemIcon")
    local itemId = vipItem.goods[2]
    local num = vipItem.goods[3]
    if IconUtils.iconIdMap[vipItem.goods[1]] then
        itemId = IconUtils.iconIdMap[vipItem.goods[1]]
    else -- if vipItem.goods[1] == "tool" then
        itemId = vipItem.goods[2]
    end
    local isShowHero = false
    local param = {}--{itemId = itemId, num = num,eventStyle = 0} 
    local toolData = tab:Tool(itemId)
    if toolData then
        itemName:setString(lang(toolData.name))
        if 6 == toolData.typeId then
            isShowHero = true
            param = {itemId = itemId, num = num,eventStyle = 0} 
        else
            param = {itemId = itemId, num = num} 
        end            
    end
    -- dump(param, "param ===========")
    if not itemIcon then
        itemIcon = IconUtils:createItemIconById(param)
        itemIcon:setName("itemIcon")
        itemIcon:setPosition(0, 5)
        itemIcon:setScale(0.84)
        itemBg:addChild(itemIcon)
    else
        IconUtils:updateItemIconByView(itemIcon, param)
    end
    -- dump()
    if isShowHero then
        local heroId = string.sub(itemId, 2, string.len(itemId))
        itemIcon:setTouchEnabled(true)
        itemIcon:setSwallowTouches(false)
        
        registerClickEvent(itemIcon, function()
            local NewFormationIconView = require "game.view.formation.NewFormationIconView"
            self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = tonumber(heroId)}, true)
        end)
    end

    -- 折扣
    rebateNum:setString(vipItem.discount)

    -- 价格
    oldPrice:setString(vipItem.price2)
    newPrice:setString(vipItem.price1)


    vipLevel:setString(vipItem.viplimit)

    -- 气泡
    self:setQipao(vipItem, 2)
end

-- 随时更新物品剩余数量
function ACEveryDayRebateLayer:updateItemNum()
    if not self._day then
        self._day = 1
    end
    local activityModel = self._modelMgr:getModel("ActivityModel")
    local rebateItemNum = self._activityRebateModel:getACERebateAllPlayer()
    local rebateSpecial = activityModel:getACERebateSpecialData()
    -- dump(rebateSpecial, 'rebateSpecial ===========')
    -- print("==================rebateSpecial",rebateSpecial)
    local commonNum = 0
    if rebateItemNum[tostring(1 .. self._day)] then
        commonNum = rebateItemNum[tostring(1 .. self._day)]
    end
    local commonItem = tab:Activity101(tonumber(1 .. self._day))
    local haveNum = self:getUI("bg.commonBg.haveNum")
    -- 剩余数量
    -- print("===========",self._day, commonItem.total, commonNum, commonItem.total - commonNum)
    if commonItem.total - commonNum <= 0 then
        haveNum:setString(0)
    else
        haveNum:setString(commonItem.total - commonNum)
    end
    

    local userData = self._modelMgr:getModel("UserModel"):getData()
    commonNum = commonItem.total
    if rebateItemNum[tostring(1 .. self._day)] then
        commonNum = commonItem.total - rebateItemNum[tostring(1 .. self._day)]
    end


    local buyBtn = self:getUI("bg.commonBg.buyBtn")
    if rebateSpecial[tostring(1 .. self._day)] then
        buyBtn:setTitleText("已购买")
        buyBtn:setSaturation(-100)
        self:registerClickEvent(buyBtn, function()
            self._viewMgr:showTip("已购买")
        end)
    elseif commonNum <= 0 then
        buyBtn:setTitleText("已售完")
        buyBtn:setSaturation(-100)
        self:registerClickEvent(buyBtn, function()
            self._viewMgr:showTip("普通物品数量不足")
        end)
    elseif userData.gem < commonItem.price1 then
        buyBtn:setTitleText("购买")
        buyBtn:setSaturation(0)
        self:registerClickEvent(buyBtn, function()
            -- self._viewMgr:showTip("钻石不够")
            DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
                local viewMgr = ViewManager:getInstance()
                viewMgr:showView("vip.VipView", {viewType = 0})
            end})
        end)
    else
        buyBtn:setTitleText("购买")
        buyBtn:setSaturation(0)
        self:registerClickEvent(buyBtn, function()
            -- print ("============", self._index)
            self:getSpecialAcReward(1 .. self._day)
        end)
    end



    local vipNum = 0
    if rebateItemNum[tostring(2 .. self._day)] then
        vipNum = rebateItemNum[tostring(2 .. self._day)]
    end

    local vipItem = tab:Activity101(tonumber(2 .. self._day))
    local haveNum = self:getUI("bg.vipBg.haveNum")
    -- 剩余数量
    haveNum:setString(vipItem.total - vipNum)

    local userData = self._modelMgr:getModel("UserModel"):getData()
    local viplevel = self._modelMgr:getModel("VipModel"):getData().level
    -- local rebateItemNum = activityModel:getACERebateAllPlayer()
    vipNum = vipItem.total
    if rebateItemNum[tostring(2 .. self._day)] then
        vipNum = vipItem.total - rebateItemNum[tostring(2 .. self._day)]
    end
    local buyBtn = self:getUI("bg.vipBg.buyBtn")
    buyBtn:setTitleFontSize(36)
    buyBtn:getTitleRenderer():enableOutline(cc.c4b(178, 103, 3, 255), 3) --(cc.c4b(101, 33, 0, 255), 2)
    buyBtn:setColor(cc.c4b(255, 250, 220, 255))
    if rebateSpecial[tostring(2 .. self._day)] == 1 then
        buyBtn:setTitleText("已购买")
        buyBtn:setSaturation(-100)
        self:registerClickEvent(buyBtn, function()
            self._viewMgr:showTip("已购买")
        end)
    elseif vipNum <= 0 then
        buyBtn:setTitleText("已售完")
        buyBtn:setSaturation(-100)
        self:registerClickEvent(buyBtn, function()
            self._viewMgr:showTip("物品数量不足")
        end)
    elseif userData.gem < vipItem.price1 then
        buyBtn:setTitleText("购买")
        buyBtn:setSaturation(0)
        self:registerClickEvent(buyBtn, function()
            -- self._viewMgr:showTip("钻石不够")
            -- local costName = lang("TOOL_" .. IconUtils.iconIdMap[self._costType])
            DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
                local viewMgr = ViewManager:getInstance()
                viewMgr:showView("vip.VipView", {viewType = 0})
            end})
        end)
    elseif viplevel < vipItem.viplimit then
        buyBtn:setTitleText("购买")
        buyBtn:setSaturation(0)
        self:registerClickEvent(buyBtn, function()
            -- self._viewMgr:showTip("vip等级不够")
            DialogUtils.showNeedCharge({desc = "VIP等级不足，是否前往充值？",callback1=function( )
                local viewMgr = ViewManager:getInstance()
                viewMgr:showView("vip.VipView", {viewType = 0})
            end})
        end)
    else
        buyBtn:setTitleText("购买")
        buyBtn:setSaturation(0)
        self:registerClickEvent(buyBtn, function()
            self:getSpecialAcReward(2 .. self._day)
        end)
    end
end

function ACEveryDayRebateLayer:getDailyDiscountInfoNum()
    self._serverMgr:sendMsg("ActivityServer", "getDailyDiscountInfo", {acId = 101}, true, {}, function (result)
        -- self:getDailyDiscountInfoFinish(result)
    end)
end
-- function ACEveryDayRebateLayer:getDailyDiscountInfoFinish(result)
--     dump(result)
--     self:updateItemNum()
-- end

function ACEveryDayRebateLayer:getSpecialAcReward(rewardId)
    print("领取奖励 ====+++=", rewardId)
    self._modelMgr:getModel("ActivityModel"):setACRebateShowDays(self._day)
    self._modelMgr:getModel("ActivityModel"):isShowBuyDays(true)
    -- print(abc.abc.abc)
    if not rewardId then
        self._viewMgr:showTip("参数有误")
        return
    end
    self._activityRebateModel:setACERebateData(false)
    self._serverMgr:sendMsg("ActivityServer", "getSpecialAcReward", {acId = 101, args = json.encode({id = rewardId})}, true, {}, function (result)
        self:getSpecialAcRewardFinish(result)
    end)
end

function ACEveryDayRebateLayer:getSpecialAcRewardFinish(result)
    if result == nil then
        return
    end
    self:getDailyDiscountInfo()
    -- dump(result, "result =========")
    if result.reward then
        DialogUtils.showGiftGet({
            gifts = result.reward,
            title = lang("FINISHSTAGETITLE"),
            callback = function()
        end})
    end
    print("领取奖励 =====", rewardId, self._index)
    -- self:reflashUI()
    print("领取奖励 =====", rewardId, self._index)
end

function ACEveryDayRebateLayer:setQipao(inTable, _type)
    local bubble = self:getUI("bg.commonBg.bubble1")
    if _type == 2 then
        bubble = self:getUI("bg.vipBg.bubble1")
    end
    if not inTable then
        bubble:setVisible(false)
        return
    end
    if not inTable.qipao then
        bubble:setVisible(false)
        return
    end
    local flag = false
    local indexId = tostring(_type .. self._day)
    if inTable.qipao == 1 then
        local activityModel = self._modelMgr:getModel("ActivityModel")
        local rebateItemNum = self._activityRebateModel:getACERebateAllPlayer()
        local rebateSpecial = activityModel:getACERebateSpecialData()
        local commonNum = 0
        if rebateItemNum[indexId] then
            commonNum = rebateItemNum[indexId]
        end

        local userData = self._modelMgr:getModel("UserModel"):getData()
        commonNum = inTable.total
        if rebateItemNum[indexId] then
            commonNum = inTable.total - rebateItemNum[indexId]
        end

        if (not rebateSpecial[indexId]) and commonNum > 0 then
            local heroD = self._modelMgr:getModel("HeroModel"):checkHero(60303)
            if heroD then
                flag = true
            end
        end
    elseif inTable.qipao == 2 then
        local activityModel = self._modelMgr:getModel("ActivityModel")
        local rebateItemNum = self._activityRebateModel:getACERebateAllPlayer()
        local rebateSpecial = activityModel:getACERebateSpecialData()
        local commonNum = 0
        if rebateItemNum[indexId] then
            commonNum = rebateItemNum[indexId]
        end

        local userData = self._modelMgr:getModel("UserModel"):getData()
        commonNum = inTable.total
        if rebateItemNum[indexId] then
            commonNum = inTable.total - rebateItemNum[indexId]
        end
        
        if (not rebateSpecial[indexId]) and commonNum > 0 then
            local peeragelv = self._modelMgr:getModel("PrivilegesModel"):getPeerage()
            if peeragelv == 2 then
                flag = true
            end
        end
    end

    if flag == true then
        bubble:setVisible(true)
        local text = bubble:getChildByFullName("text")
        local str = lang("ac101qipao" .. inTable.qipao) 
        text:setString(str)
    else
        bubble:setVisible(false)
    end
end


-- 获取初始数据
function ACEveryDayRebateLayer:getDailyDiscountInfo()
    local haveRebate = self._modelMgr:getModel("ActivityRebateModel"):isACERebateData()
    if haveRebate ~= true then
        print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
        self._serverMgr:sendMsg("ActivityServer", "getDailyDiscountInfo", {acId = 101}, true, {}, function (result)
            -- self:reflashUI()
            self._modelMgr:getModel("ActivityRebateModel"):setACERebateData(true)
        end)
    else
        -- self:reflashUI()
    end
end


return ACEveryDayRebateLayer