--[[
    Filename:    ACLichBuyView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2017-02-07 14:16:27
    Description: File description
--]]
local ACLichBuyView = class("ACLichBuyView", BasePopView)

ACLichBuyView.kRewardItemTag = 1000

function ACLichBuyView:ctor(param)
    self.super.ctor(self)
    self._activityModel = self._modelMgr:getModel("ActivityModel")
    self._paymentModel = self._modelMgr:getModel("PaymentModel")
    self._closeCallBack = param.closeCallBack
end

function ACLichBuyView:getAsyncRes()
    return 
    {
        "asset/ui/ac_lich_buy.png",
        {"asset/ui/activity.plist", "asset/ui/activity.png"}
    }
end

function ACLichBuyView:onDestroy()
    ACLichBuyView.super.onDestroy(self)
    if self._bgImg then
        cc.Director:getInstance():getTextureCache():removeTextureForKey(self._bgImg)
    end
end

function ACLichBuyView:onAdd()

end

function ACLichBuyView:onTop()
    
end

function ACLichBuyView:onInit()

    self._bgImg = "asset/bg/ac_lich_buy.png"
    self._imageBg = self:getUI("bg.layer.image_bg")
    self._imageBg:loadTexture(self._bgImg)

    self._btnBuy = self:getUI("bg.layer.btn_buy")
    self._btnBuy:setTitleFontSize(24)
    self._btnBuy:getTitleRenderer():enableOutline(cc.c4b(124, 64, 0, 255), 2)

    self._rewardsIcon = {}
    for i=1, 3 do
        self._rewardsIcon[i] = self:getUI("bg.layer.layer_reward_" .. i)
    end

    self:initActivityData()
    self:refreshUI()

    self:registerClickEvent(self._btnBuy, function ()
        self:onButtonBuyClicked()
    end)

    self:registerClickEventByName("bg.layer.btn_close", function ()
        if self._closeCallBack then
            self._closeCallBack()
        end
        self:close()
        UIUtils:reloadLuaFile("activity.ACLichBuyView")
    end)
end

function ACLichBuyView:refreshUI()
    if not self._initFinished then
        self._btnBuy:setVisible(false)
        return
    end
    self._btnBuy:setVisible(true)

    for i=1, 3 do
        self._rewardsIcon[i]:setVisible(false)
    end

    local giftContain = self._activityReward
    for i = 1, #giftContain do
        local giftItem = self._rewardsIcon[i]
        giftItem:setVisible(true)
        local itemIcon = giftItem:getChildByTag(ACLichBuyView.kRewardItemTag)
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
        itemIcon:setTag(ACLichBuyView.kRewardItemTag)
        giftItem:addChild(itemIcon)
    end
end

function ACLichBuyView:initActivityData()
    self._initFinished = false
    self._activityData = self._activityModel:getAcLichBuyData()
    if not self._activityData then return end
    self._activityId = self._activityData.activity_id
    self._activityReward = tab:CashGoodsLib(tab:Setting("G_NESTREWARD").value).reward
    self._initFinished = true
end

function ACLichBuyView:showRewardDialog()
    local params = clone(self._activityReward)
    DialogUtils.showGiftGet({gifts = params})
end

function ACLichBuyView:onButtonBuyClicked()
    self._btnBuy:setEnabled(false)
    self._btnBuy:setBright(false)
    ScheduleMgr:delayCall(2000, nil, function()
        if self._btnBuy then
            self._btnBuy:setEnabled(true)
            self._btnBuy:setBright(true)
        end
    end)
    self._paymentModel:charge(self._paymentModel.kProductType3, {activityId = self._activityId}, function(success, data)
        if not success then return end
        if not (self.refreshUI and self.showRewardDialog) then return end
        self:showRewardDialog()
        if self._closeCallBack then
            self._closeCallBack()
        end
        self:close()
    end)
end

return ACLichBuyView