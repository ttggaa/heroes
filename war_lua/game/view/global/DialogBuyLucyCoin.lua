--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-08-21 16:19:29
--
local DialogBuyLucyCoin = class("DialogBuyLucyCoin",BasePopView)
function DialogBuyLucyCoin:ctor(data)
    self.super.ctor(self)
    self._maxConst = tab.setting["LUCKYCOIN_CHANGE"].value
    self._maxNum = self._maxConst
    dump(data,"aaaa",10)
    self._closeCallBack = data and data.closeCallback
    self._touchState = 0
    self._chargeDialog = nil
end

local presslongScheduleId 

function DialogBuyLucyCoin:getAsyncRes()
    return 
    {
        {"asset/ui/bag.plist", "asset/ui/bag.png"},
    }
end

-- 初始化UI后会调用, 有需要请覆盖
function DialogBuyLucyCoin:onInit()

	self._closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(self._closeBtn, function ()
        if self._closeCallBack then
            self._closeCallBack()
        end
    	self.dontRemoveRes = true
        self:close()
        UIUtils:reloadLuaFile("global.DialogBuyLucyCoin")
    end)

    self._title = self:getUI("bg.headBg.title")
    -- self._title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._title:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._title,1)
	    
    self._useTxtNum = self:getUI("bg.desBg.useNum")
    self._goalNum = self:getUI("bg.desBg.goalNum")
    self._luckCoinNum = self:getUI("bg.desBg.luckCoinNum")
    -- self._useTxtNum:enableOutline(cc.c4b(60,30,10,255),2)

    self._sliderPanel = self:getUI("bg.sliderPanel")
    self._bg1 = self:getUI("bg.bg1")
    self._greenPro = self:getUI("bg.sliderPanel.greenPro")

	self._slider = self:getUI("bg.sliderPanel.sliderBar")
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

	self._addBtn = self:getUI("bg.sliderPanel.addBtn")
    self:registerTouchEvent(self._addBtn,function ( ... )
        self:addLuckyCoinBegin(true)
    end,nil,function ()
        self:addLuckyCoinBeginEnd()
    end,
    function ()
        self:addLuckyCoinBeginEnd()
    end)

    self._subBtn = self:getUI("bg.sliderPanel.subBtn")
    -- self:registerClickEvent(self._subBtn, function ()
    --     if self._inputNum > 1 then
    --         self._inputNum = self._inputNum - 10
    --         self:setSliderPercent(self._inputNum/self._maxNum*100)
    --         -- self._itemNum:setString(self._maxNum + self._inputNum)
    --     end
    --     self:refreshBtnStatus()
    -- end)
    self:registerTouchEvent(self._subBtn,function ()
        self:addLuckyCoinBegin(false)
    end,nil,function ()
        self:addLuckyCoinBeginEnd()
    end,
    function()
        self:addLuckyCoinBeginEnd()
    end)

    self._addTenBtn = self:getUI("bg.sliderPanel.addTenBtn")
    self:registerClickEvent(self._addTenBtn, function ()
        if self:isNeedChargeMoney() and self._chargeDialog == nil then
            self._chargeDialog = DialogUtils.showNeedCharge({button1 = "前往",title = "钻石不足",callback1 = function ( ... )
                self._viewMgr:showView("vip.VipView", {viewType = 0})
                self._chargeDialog = nil
            end,callback2 = function ( ... )
                self._chargeDialog = nil
            end})
            return
        end
        self._inputNum = self._maxNum
        -- self._useCountInput:setString(self._inputNum)

        self:setSliderPercent(self._inputNum/self._maxNum*100)

        self:refreshBtnStatus()
    end)

    self._tipBtn = self:getUI("bg.tipBtn")
    self:registerClickEvent(self._tipBtn, function ()
        self._viewMgr:showTip(lang("LUCKYCOIN_TIPS")) --"购买幸运币不计入钻石累计消耗，消耗幸运币计入")
    end)

    self._okBtn = self:getUI("bg.okBtn")
    self:registerClickEvent(self._okBtn, function ()
        self:sendBuyMsg()

    end)

    self:listenReflash("UserModel", function( )
        self:reflashUI(self._data)
    end)
end

function DialogBuyLucyCoin:addLuckyCoinBegin(isAdd)
    if self:isNeedChargeMoney() and self._chargeDialog == nil then
        self._chargeDialog = DialogUtils.showNeedCharge({button1 = "前往",title = "钻石不足",callback1 = function ( ... )
            self._viewMgr:showView("vip.VipView", {viewType = 0})
            self._chargeDialog = nil
        end,callback2 = function ( ... )
            self._chargeDialog = nil
        end})
        return
    end
    self._touchState = isAdd==true and 1 or -1
    local delay = cc.DelayTime:create(0.5)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(function()
            addNum = -1 
            local numsch = 100
            if isAdd then addNum = 1 end
            presslongScheduleId = ScheduleMgr:regSchedule(100, self, function()
                if math.fmod(numsch,1000) == 0 then
                    addNum = addNum * 2 
                end
                numsch = numsch + 100
                if self._inputNum <= self._maxNum then
            
                    self._inputNum = self._inputNum + addNum
                    self._inputNum = self._inputNum < self._maxNum and self._inputNum or self._maxNum
                    self._inputNum = self._inputNum < 1 and 1 or self._inputNum
                    local num = self._inputNum/self._maxNum*100
                    self:setSliderPercent(self._inputNum/self._maxNum*100)
                else
                    -- self._viewMgr:showTip("已达使用上限！")
                end
                self:refreshBtnStatus()
            end)
        end))
    self:runAction(sequence)
end

function DialogBuyLucyCoin:addLuckyCoinBeginEnd()
    self:stopAllActions()
    if presslongScheduleId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(presslongScheduleId)
        presslongScheduleId = nil
        return
    else
        if self._touchState ~= 0 then
            if self._inputNum <= self._maxNum then
                self._inputNum = self._inputNum + self._touchState
                self._inputNum = self._inputNum < self._maxNum and self._inputNum or self._maxNum
                self._inputNum = self._inputNum < 1 and 1 or self._inputNum
                local num = self._inputNum/self._maxNum*100
                self:setSliderPercent(self._inputNum/self._maxNum*100)
            else
                -- self._viewMgr:showTip("已达使用上限！")
            end
            self._touchState = 0
            self:refreshBtnStatus()
        end
    end
end

function DialogBuyLucyCoin:isNeedChargeMoney(cost)
    local isNeed = false
    if self._maxNum <= 0 then
        isNeed = true
    end
    return isNeed
end

-- 接收自定义消息
function DialogBuyLucyCoin:reflashUI(data)
	dump(data,"DialogBuyLucyCoin:reflashUI")
	self._data = data or self._data
	self._inputNum = data and data.inputNum or 1
	local gem = self._modelMgr:getModel("UserModel"):getData().gem or 0
	if gem > self._maxConst then
		self._maxNum = self._maxConst
	else
		self._maxNum = gem 
	end
	self._inputNum = math.min(self._inputNum,self._maxNum)
	self._inputNum = math.max(self._inputNum,1)
	if self._maxNum ~= 0 then
		self:setSliderPercent(self._inputNum/self._maxNum*100)
	else
		self:setSliderPercent(0)
	end
	self:refreshBtnStatus()
end
function DialogBuyLucyCoin:sliderValueChange()
	local step = math.floor(100/math.floor(self._maxNum/100))
    local num = self._slider:getPercent()* 0.01
    local newnum = num -- (num/(1.5-0.5*num))*100
    self._inputNum = math.ceil((self._maxNum-0.9) * newnum )
    if self._slider:getPercent() < 100 then
	    self._inputNum = math.floor(self._inputNum/100)*100
	    self:setSliderPercent(self._inputNum/self._maxNum*100)
	end
	self._inputNum = math.abs(self._inputNum)
    if self._inputNum < 1 then
        self._inputNum = 1
    end
    if self._maxNum == 0 then
    	-- self._inputNum = 0
    	self:setSliderPercent(0)
    end
    self:refreshBtnStatus()
    if self:isNeedChargeMoney() and self._chargeDialog == nil then
        self._chargeDialog = DialogUtils.showNeedCharge({button1 = "前往",title = "钻石不足",callback1 = function ( ... )
            self._viewMgr:showView("vip.VipView", {viewType = 0})
            self._chargeDialog = nil
        end,callback2 = function ( ... )
            self._chargeDialog = nil
        end})
        return
    end
end
---------------------- 处理滑动条 begin
function DialogBuyLucyCoin:refreshBtnStatus( )
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

    if self._inputNum >= self._maxNum and self._maxNum ~= 0 then 
        self._addBtn:setEnabled(false)
        self._addBtn:setBright(false)
        self:setSliderPercent(100)
    else
        self._addBtn:setEnabled(true)
        self._addBtn:setBright(true)
    end
    local sliderBase = 100
    local sliderPercent = self._slider:getPercent()
    sliderPercent = sliderPercent+1
    sliderPercent = math.max(sliderPercent,10)
    sliderPercent = math.min(sliderPercent,92)
    self._greenPro:setScaleX(sliderPercent/100)
    self._useTxtNum:setString(self._inputNum)
    self._goalNum:setString(self._inputNum)
    self._luckCoinNum:setString(self._inputNum)
    if self._maxNum == 0 then
    	self._useTxtNum:setColor(UIUtils.colorTable.ccUIBaseColor6)
    	self._goalNum:setColor(UIUtils.colorTable.ccUIBaseColor6)
    	self._luckCoinNum:setColor(UIUtils.colorTable.ccUIBaseColor6)
    else 
    	self._useTxtNum:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    	self._goalNum:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    	self._luckCoinNum:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    end
end

function DialogBuyLucyCoin:setSliderPercent(num)
    local num = num * 0.01
    local newnum= num --1.5 * num /(1+0.5 * num)
    self._slider:setPercent(newnum * 100)
end
---------------------- 处理滑动条 end 

-- 抽离出 发送使用物品接口
function DialogBuyLucyCoin:sendBuyMsg( param )
	if self._maxNum == 0 then
		DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"), callback1=function( )
            local viewMgr = ViewManager:getInstance()
            viewMgr:showView("vip.VipView", {viewType = 0})
        end})
		return 
	end
	local param = {num = self._inputNum,extraParams=nil}

    local preHave = clone(self._modelMgr:getModel("UserModel"):getData())
    self._serverMgr:sendMsg("UserServer", "buyLuckyCoin", param, true, {}, function(result) 
        -- self:upgradeBag(result)
        dump(result,"result==>",5)
        -- 先判断是否是头像框
        if result.reward then
            
            local giftData = tab:ToolGift(param.goodsId) or {}
            local gifts = giftData.giftContain

            -- 头像框 
            if giftData.type == 5 then
                local notChange = false
                for k,v in pairs(result.reward) do
                    if v[1] == "avatarFrame" or v["type"] == "avatarFrame" 
                        or v[1] == "avatar" or v["type"] == "avatar" then
                            notChange = true
                    end
                end
                if notChange and table.nums(result.reward) == 1 then
                    DialogUtils.showAvatarFrameGet( {gifts = gifts}) 
                else
                    DialogUtils.showGiftGet( {gifts = result.reward,notPop=true})
                end 
            else
                DialogUtils.showGiftGet( {gifts = result.reward,notPop=true})                
            end
            
            self._inputNum = 0
            -- self._viewMgr:showTip("使用礼包成功")
        
        elseif tab:ToolGift(param.goodsId) then
            local giftData = tab:ToolGift(param.goodsId) or {}
            local gifts = giftData.giftContain
            -- 头像框 
            if giftData.type == 5 then
                DialogUtils.showAvatarFrameGet( {gifts = gifts})   
            else
                DialogUtils.showGiftGet( {gifts = gifts,notPop=true})                
            end

            self._inputNum = 0
            -- self._viewMgr:showTip("使用礼包成功")
        else
            -- self._viewMgr:showTip("使用成功")
            local goodsData = tab:Tool(param.goodsId)
            if goodsData and goodsData.typeId == 102 then
                DialogUtils.showSkinGetDialog( {skinId = tonumber("2" .. param.goodsId)})
            else
                local items = {}
                local uniqueTab = {}
                for k,v in pairs(result.d) do
                    if (result.d["payGem"] and not uniqueTab["payGem"]) or (result.d["freeGem"] and not uniqueTab["freeGem"])  then
                        result.d["payGem"] = nil
                        if result.d["payGem"] then
                            uniqueTab["payGem"] = true 
                        end
                        if result.d["freeGem"] then
                            uniqueTab["freeGem"] = true 
                        end
                        result.d["freeGem"] = nil
                        local item = {"gem",0}
                        local itemNum = self._modelMgr:getModel("UserModel"):getData().gem-preHave["gem"]
                        if itemNum > 0 then
	                        table.insert(item,itemNum)
	                        table.insert(items,item)
	                    end
                    elseif IconUtils.iconIdMap[k] and not uniqueTab[IconUtils.iconIdMap[k]] then
                        local item = {"tool",IconUtils.iconIdMap[k]}
                        local itemNum = v-(preHave[k] or 0)
                        if itemNum > 0 then 
	                        table.insert(item,itemNum or 0)
	                        table.insert(items,item)
	                    end
                        uniqueTab[IconUtils.iconIdMap[k]] = true
                    end
                end
                if #items > 0 then
                    DialogUtils.showGiftGet( {gifts = items,notPop=true})
                end
            end
        end
        if self._closeCallBack then
            self._closeCallBack()
        end
        self:close()
    end)
end

return DialogBuyLucyCoin