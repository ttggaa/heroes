--[[
    Filename:    MonthCardLayer.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-05-17 15:59
    Description: 双月卡界面
--]]


local MonthCardLayer = class("MonthCardLayer", require("game.view.activity.common.ActivityCommonLayer"))

function MonthCardLayer:getBgName()
    return "montCardBg.jpg"
end

function MonthCardLayer:ctor()
    MonthCardLayer.super.ctor(self)
    self._isMCardBuy = false
    self._isHMCardBuy = false
    self._paymentModel = self._modelMgr:getModel("PaymentModel")
end
  
function MonthCardLayer:onInit()
    --设置已读
    self._modelMgr:getModel("ActivityModel"):setCheckMCardState()

    for i=1,2 do
        self:getUI("bg.card" ..i.. ".sumGet.label1"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        self:getUI("bg.card" ..i.. ".sumGet.gemNum"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        self:getUI("bg.card" ..i.. ".pay.num"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        self:getUI("bg.card" ..i.. ".pay.label1"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        self:getUI("bg.card" ..i.. ".pay.label2"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        self:getUI("bg.card" ..i.. ".dayTxt"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

        local tipDes = self:getUI("bg.card" ..i.. ".tipDes")
        tipDes:setColor(cc.c4b(255, 255, 255, 255))
        tipDes:enable2Color(1, cc.c4b(255, 221, 63, 255))
        tipDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

        local cardBtn = self:getUI("bg.card" ..i.. ".cardBtn")
        cardBtn:setTitleFontSize(22)
        cardBtn:getTitleRenderer():enableOutline(cc.c4b(124, 64, 0, 255), 2)
        cardBtn._type = i
        self:registerClickEvent(cardBtn, function()
            local btnName = cardBtn:getTitleText()
            self:onMonthCardClicked(btnName, cardBtn._type)
        end)
    end

    local ruleBtn = self:getUI("bg.ruleBtn")
    self:registerClickEvent(ruleBtn, function ()
        local ruleDesc = lang("monthcard_rule")
        self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = ruleDesc},true)
    end)

    local bg = ccui.ImageView:create() 
    bg:loadTexture("asset/bg/montCardBg.jpg")
    bg:setAnchorPoint(cc.p(0, 0))
    bg:setPosition(cc.p(0, 0))
    self:getUI("bg"):addChild(bg, -1)

    self:reflashUI()
end

function MonthCardLayer:reflashUI()
    local vipData = self._modelMgr:getModel("VipModel"):getData()
    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()   --当前时间
    local start_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 05:00:00"))  --当日开启时间
    if curTime < start_time then   --过零点判断
        start_time = start_time - 86400
    end

    -- dump(vipData, "MonthCard", 10)

    local payName = {
        [1] = "payment_month",
        [2] = "payment_monthsuper",
    }

    local need = tab.setting["G_month_price"].value
    local isCard1Aciv =  false  --初级月卡是否激活
    for i=1,2 do
        local cardData = (vipData["mCard"] and vipData["mCard"][payName[i]]) or nil
        local isBuy = (cardData and cardData["expireTime"]) and cardData["expireTime"] >= curTime or false  --是否已购买
        local isGet = (cardData and cardData["lastUpTime"]) and cardData["lastUpTime"] >= start_time or false  --是否已领奖

        self:getUI("bg.card" ..i.. ".sumGet"):setVisible(not isBuy)
        self:getUI("bg.card" ..i.. ".pay"):setVisible(not isBuy)
        self:getUI("bg.card" ..i.. ".dayTxt"):setVisible(isBuy)
        self:getUI("bg.card" ..i.. ".activedImg"):setVisible(isBuy)
        self:getUI("bg.card" ..i.. ".costImg"):setVisible(not isBuy)

        --月卡失效后重置已充值数为0 【失效且没有新的充值时】
        --1.初级月卡失效时，高级月卡没有失效，激活初级月卡，高级月卡失效后显示58
        --2.高级月卡失效时，初级月卡没有失效，激活高级月卡，初级月卡失效后显示0
        --初级月卡失效前高级月卡已激活，初级月卡失效，sum置为0，高级月卡继续走完30天周期
        if i == 1 and vipData["time"] and curTime > vipData["time"] then
            vipData["sum"] = 0
        end

        local cardBtn = self:getUI("bg.card" ..i.. ".cardBtn")
        if isBuy == true then
            local dayLast = 30
            if cardData["lastUpTime"] then
                dayLast = math.floor((cardData["expireTime"] - cardData["lastUpTime"]) / 86400)
                if cardData["lastUpTime"] < start_time then
                    local unGetNum = math.floor( (start_time - cardData["lastUpTime"])/86400 ) 
                    dayLast = dayLast - unGetNum
                end
            else
                if cardData["expireTime"] then
                    dayLast = math.ceil((cardData["expireTime"] - start_time) / 86400)
                end
            end
            local lastDays = math.min(math.max(0, dayLast), 31)
            self:getUI("bg.card" ..i.. ".dayTxt"):setString("剩余" .. lastDays .. "天")
            
            if isGet == true then
                cardBtn:setSaturation(-100)
                cardBtn:setTitleText("已领取")
                cardBtn:setTouchEnabled(false)
            else
                cardBtn:setTitleText("领取")
                cardBtn:setTouchEnabled(true)
            end

            if i == 1  then
                isCard1Aciv = true
                self._card1LastDays = dayLast
            end
        else
            self:getUI("bg.card" ..i.. ".sumGet.gemNum"):setString(100*i*30)
            local payNum = math.max(need[i] - (vipData["sum"] or 0), 0)  --剩余充值数
            self:getUI("bg.card" ..i.. ".pay.num"):setString(payNum / 10)
            cardBtn:setTitleText("充值")
            cardBtn:setTouchEnabled(true)
        end
    end
end

function MonthCardLayer:onMonthCardClicked(btnName, typeID)
    if btnName == "充值" then
        self._viewMgr:showView("vip.VipView", {viewType = 0})

    elseif btnName == "领取" then
        local typeName = {
            [1] = "payment_month",
            [2] = "payment_monthsuper"
        }
        self._modelMgr:getModel("ActivityModel"):setMCardClickType(typeID)
        self._serverMgr:sendMsg("VipServer", "getMCardGift", {id = typeName[typeID]}, true, {}, function(result)
            -- dump(result, "123", 10)

            function refreshTipView() 
                local acModel = ModelManager:getInstance():getModel("ActivityModel")
                local vipModel = ModelManager:getInstance():getModel("VipModel")
                local userModel = ModelManager:getInstance():getModel("UserModel")
                local viewMgr = ViewManager:getInstance()
                
                local curType = acModel:getMCardClickType()
                if not curType or curType ~= 1 then
                    return 
                end
                acModel:setMCardClickType(-1)

               
                local vipData = vipModel:getData()
                local cardData = (vipData["mCard"] and vipData["mCard"]["payment_month"]) or nil
                if cardData == nil then
                    return
                end

                if not cardData["expireTime"] then
                    return
                end

                local curTime = userModel:getCurServerTime()   --当前时间
                local start_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 05:00:00"))  --当日开启时间
                if curTime < start_time then   --过零点判断
                    start_time = start_time - 86400
                end
                local dayLast = 30
                if cardData["lastUpTime"] then
                    dayLast = math.floor((cardData["expireTime"] - cardData["lastUpTime"]) / 86400)
                    if cardData["lastUpTime"] < start_time then
                        local unGetNum = math.floor( (start_time - cardData["lastUpTime"])/86400 ) 
                        dayLast = dayLast - unGetNum
                    end
                else
                    if cardData["expireTime"] then
                        dayLast = math.ceil((cardData["expireTime"] - start_time) / 86400)
                    end
                end
                local lastDays = math.min(math.max(0, dayLast), 31)
                if lastDays > 3 then
                    return
                end

                --高级月卡是否失效
                local sCardData = (vipData["mCard"] and vipData["mCard"]["payment_monthsuper"]) or nil
                local isOutTime = (not sCardData or (sCardData and sCardData["expireTime"]) and sCardData["expireTime"] < curTime) or false
                if not isOutTime then
                    return
                end

                local lastClickT = SystemUtils.loadAccountLocalData("IS_MONTHCARD_TIP1_SHOWED")
                if lastClickT and lastClickT >= cardData["expireTime"] then
                    return
                end
                SystemUtils.saveAccountLocalData("IS_MONTHCARD_TIP1_SHOWED", cardData["expireTime"])

                local need = tab.setting["G_month_price"].value
                local payNum = math.max(need[2] - (vipData["sum"] or 0), 0)
                local tipDes
                if lastDays == 0 then
                    tipDes = lang("MONTHCARD_TIP2")
                else
                    tipDes = lang("MONTHCARD_TIP1")
                    tipDes = string.gsub(tipDes, "{$day}", lastDays)
                end
                tipDes = string.gsub(tipDes, "{$num}", payNum / 10)
                viewMgr:showDialog("global.GlobalSelectDialog",
                    {   desc = tipDes,
                        button1 = "立即前往",
                        button2 = "放弃福利", 
                        callback1 = function ()
                            viewMgr:showView("vip.VipView", {viewType = 0})
                        end,
                        callback2 = function()

                        end})
            end

            DialogUtils.showGiftGet( {
                gifts = result["reward"], 
                callback = function()
                    refreshTipView()
                end
            })
        end)
    elseif btnName == "已领取" then
        self._viewMgr:showTip(lang("TiPS_YILINGQU"))
    end  
end

function MonthCardLayer:isActivityCanGet()
    return self._modelMgr:getModel("ActivityModel"):getData()
end

return MonthCardLayer