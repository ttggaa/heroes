--[[
    Filename:    AcIntelligentRechargeLayer.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2017-08-09 15:25:39
    Description: File description
--]]

local AcIntelligentRechargeLayer = class("AcIntelligentRechargeLayer", BasePopView)

AcIntelligentRechargeLayer.kRewardItemTag = 1000

function AcIntelligentRechargeLayer:ctor(params)
    self.super.ctor(self)
    self._activityModel = self._modelMgr:getModel("ActivityModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._callback = params.callback
end

function AcIntelligentRechargeLayer:getAsyncRes()
    return 
    {
        "asset/bg/ac_intelligent_recharge_bg.png",
    }
end

function AcIntelligentRechargeLayer:onDestroy()
    AcIntelligentRechargeLayer.super.onDestroy(self)
    if self._bgImg then
        cc.Director:getInstance():getTextureCache():removeTextureForKey(self._bgImg)
    end
end

function AcIntelligentRechargeLayer:onAdd()

end

function AcIntelligentRechargeLayer:onTop()
    
end

function AcIntelligentRechargeLayer:onInit()

    self._activityModel:setTeHuiActivityChecked(true)

    self._bgImg = "asset/bg/ac_intelligent_recharge_bg.png"
    self._imageBg = self:getUI("bg.layer.image_bg")
    self._imageBg:loadTexture(self._bgImg)

    self._imageTag = self:getUI("bg.layer.image_tag")
    self._labelTag = self:getUI("bg.layer.image_tag.label_tag")
    self._labelTag:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self._labelTitle = self:getUI("bg.layer.label_title")

    self._btnCharge = self:getUI("bg.layer.btn_charge")
    self._btnCharge:setTitleFontName(UIUtils.ttfName)
    self._btnCharge:setColor(cc.c4b(255, 250, 220, 255))
    self._btnCharge:getTitleRenderer():enableOutline(cc.c4b(178, 103, 3, 255), 3) --(cc.c4b(101, 33, 0, 255), 2)
    self._btnCharge:setTitleFontSize(36)

    self._btnGet = self:getUI("bg.layer.btn_get")
    self._btnGet:setTitleFontName(UIUtils.ttfName)
    self._btnGet:setColor(cc.c4b(255, 250, 220, 255))
    self._btnGet:getTitleRenderer():enableOutline(cc.c4b(178, 103, 3, 255), 3) --(cc.c4b(101, 33, 0, 255), 2)
    self._btnGet:setTitleFontSize(36)

    self._scheduler = cc.Director:getInstance():getScheduler()

    self._rewardsIcon = {}
    for i=1, 3 do
        self._rewardsIcon[i] = self:getUI("bg.layer.layer_reward_" .. i)
    end

    self._label_count_down = self:getUI("bg.layer.label_count_down_time")

    self:refreshUI()

    self:registerClickEvent(self._btnCharge, function ()
        self:onButtonChargeClicked()
    end)

    self:registerClickEvent(self._btnGet, function ()
        self:onButtonGetClicked()
    end)

    self:registerClickEventByName("bg.layer.btn_close", function ()
        if self._callback and type(self._callback) == "function" then
            self._callback()
        end
        self:close()
        UIUtils:reloadLuaFile("activity.AcIntelligentRechargeLayer")
    end)

    self:registerScriptHandler(function(state)
        if state == "exit" then
            self:endClock()
        end 
    end)

    self:registerTimer(5, 0, 11, function ()
        self:refreshUI()
    end)

    self:listenReflash("ActivityModel", self.refreshUI)
end

function AcIntelligentRechargeLayer:formatRewardData()
    local result = {}
    local goodDataInfo = self._acData.goodDataInfo
    if goodDataInfo and type(goodDataInfo) == "string" then
        goodDataInfo = json.decode(goodDataInfo)
    end
    local size = table.getn(table.keys(goodDataInfo))
    for i=1, size do
        repeat
            local data = goodDataInfo[tostring(i)]
            if not data then break end
            table.insert(result, {[1] = data.type, [2] = data.typeId, [3] = data.num})
        until true
    end
    return result
end

function AcIntelligentRechargeLayer:refreshUI()
    self._acData = self._activityModel:getIntRechargeData()
    --dump(self._acData, "self._acData", 5)
    if not self._acData then return end
    self._acReward = self:formatRewardData()
    self:startClock()
    self:updateTimeCountDown()
    self:updateUI()
end

function AcIntelligentRechargeLayer:updateUI()

    local vipLevel = 0
    local intRechargeTableData = tab.intelligentRechargePrize
    for k, v in pairs(intRechargeTableData) do
        if v.recharge == self._acData.rechargeLimit then
            vipLevel = v.viptag
            break
        end
    end
    self._labelTag:setString("V" .. vipLevel .. "尊享")
    self._imageTag:setVisible(0 ~= vipLevel)

    self._labelTitle:setString("单笔充值满" .. self._acData.rechargeLimit .. "元即可领取")
    self._btnCharge:setVisible(self._acData.rechargeNum < self._acData.rechargeLimit)
    self._btnGet:setVisible(self._acData.rechargeNum >= self._acData.rechargeLimit)
    self._btnGet:setSaturation(0 == self._acData.hasReceived and 0 or -100)
    self._btnGet:setEnabled(0 == self._acData.hasReceived)
    self._btnGet:setTitleText(0 == self._acData.hasReceived and "领取" or "已领取")

    for i=1, 3 do
        self._rewardsIcon[i]:setVisible(false)
    end

    local giftContain = self._acReward
    for i = 1, #giftContain do
        local giftItem = self._rewardsIcon[i]
        giftItem:setVisible(true)
        local itemIcon = giftItem:getChildByTag(AcIntelligentRechargeLayer.kRewardItemTag)
        if itemIcon then itemIcon:removeFromParent() end
        local itemId = giftContain[i][2]
        local itemType = giftContain[i][1]
        local eventStyle = 1--{itemId = itemId, num = num,eventStyle = 0} 
        if itemType == "hero" then
            local heroData = clone(tab:Hero(itemId))
            itemIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
            --itemIcon:setAnchorPoint(cc.p(0, 0))
            itemIcon:getChildByName("starBg"):setVisible(false)
            for i=1,6 do
                if itemIcon:getChildByName("star" .. i) then
                    itemIcon:getChildByName("star" .. i):setPositionY(itemIcon:getChildByName("star" .. i):getPositionY() + 5)
                end
            end
            itemIcon:setPosition(giftItem:getContentSize().width / 2, giftItem:getContentSize().height / 2)
            itemIcon:setSwallowTouches(false)
            registerClickEvent(itemIcon, function()
                local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = itemId}, true)
            end)
        elseif itemType == "team" then
            local teamTeam = clone(tab:Team(itemId))
            itemIcon = IconUtils:createSysTeamIconById({sysTeamData = teamTeam})
            --itemIcon:setAnchorPoint(cc.p(0,0))
            --itemIcon:setSwallowTouches(false)
        else
            if itemType ~= "tool" then
                itemId = IconUtils.iconIdMap[itemType]
            end
            itemIcon = IconUtils:createItemIconById({itemId = itemId, num = giftContain[i][3],eventStyle = eventStyle})
        end
        itemIcon:setScale(0.8)
        itemIcon:setTag(AcIntelligentRechargeLayer.kRewardItemTag)
        giftItem:addChild(itemIcon)
    end
end

function AcIntelligentRechargeLayer:startClock()
    if self._timer_id then return end
    self._timer_id = self._scheduler:scheduleScriptFunc(handler(self, self.updateTimeCountDown), 1, false)
end

function AcIntelligentRechargeLayer:endClock()
    if not self._timer_id then return end
    if self._timer_id then 
        self._scheduler:unscheduleScriptEntry(self._timer_id)
        self._timer_id = nil
    end
end

function AcIntelligentRechargeLayer:updateTimeCountDown()
    local currentTime = self._userModel:getCurServerTime()
    local nextDayTime = currentTime + 86400
    local nextDayTimeDate = TimeUtils.date("*t", nextDayTime)
    local nextDayTimeString = string.format("%d-%d-%d 5:00:00", nextDayTimeDate.year, nextDayTimeDate.month, nextDayTimeDate.day)
    local nextTime = TimeUtils.getIntervalByTimeString(nextDayTimeString)
    local endTime = self._acData.endTime
    if nextTime >= endTime then
        nextTime = endTime
    end

    local remainTime = nextTime - currentTime

    local tempValue = remainTime    
    local day = math.floor(tempValue/86400) 
    tempValue = tempValue - day*86400
    
    local hour = math.floor(tempValue/3600)
    tempValue = tempValue - hour*3600

    local minute = math.floor(tempValue/60)
    tempValue = tempValue - minute*60
   
    local second = math.fmod(tempValue, 60)
    local showTime = string.format("%.2d天%.2d:%.2d:%.2d", day, hour, minute, second)
    if day == 0 then
        showTime = string.format("00天%.2d:%.2d:%.2d", hour, minute, second)
    end
    if remainTime <= 0 then
        self:endClock()
        showTime = "00天00:00:00"
    end
    self._label_count_down:setString(showTime)
end

function AcIntelligentRechargeLayer:showRewardDialog(data)
    local params = clone(data["reward"])
    DialogUtils.showGiftGet({gifts = params})
end

function AcIntelligentRechargeLayer:onButtonChargeClicked()
    self._viewMgr:showView("vip.VipView", {viewType = 0})
end

function AcIntelligentRechargeLayer:onButtonGetClicked()
    if 0 ~= self._acData.hasReceived then
        return
    end
    local doGet = function(selectedIndex)
        local context = {id = selectedIndex}
        self._serverMgr:sendMsg("ActivityServer", "getIntelligentReward", context, true, {}, function(success, data)
            if not success then return end
            self:showRewardDialog(data)
        end)
    end

    self._viewMgr:showDialog("global.GlobalSelectAwardDialog", {gift = self._acReward or {}, callback = function(selectedIndex)
        if not selectedIndex then return end
        doGet(selectedIndex)
    end})
end

return AcIntelligentRechargeLayer