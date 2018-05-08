--
-- Author: <ligen@playcrab.com>
-- Date: 2016-11-23 15:30:50
--
local CloudCitySweepRewardView = class("CloudCitySweepRewardView", BasePopView)

function CloudCitySweepRewardView:ctor(data)
    CloudCitySweepRewardView.super.ctor(self)

    self._rewardData = data.reward
    self._againCallBack = data.againCallBack
    self._stageId = data.stageId

    self._cModel = self._modelMgr:getModel("CloudCityModel")
end

function CloudCitySweepRewardView:onInit()
    local title = self:getUI("bg.bg1.Image_30.title")
    UIUtils:setTitleFormat(title, 1)

    self:registerClickEventByName("bg.closeBtn", function()
        UIUtils:reloadLuaFile("cloudcity.CloudCitySweepRewardView")
        self:close()
    end)

    self:registerClickEventByName("bg.bg1.againBtn", function()
        self._againCallBack(self._stageId)
    end)

    local itemTitle = self:getUI("bg.bg1.rewardItem.itemTitle")
    itemTitle:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    itemTitle:setString("第1次扫荡获得:")

    self._rewardItem = self:getUI("bg.bg1.rewardItem")
    self._rewardItem:setCascadeOpacityEnabled(true)
    self._currencyNode = self._rewardItem:getChildByFullName("currencyNode")
    self._itemNode = self._rewardItem:getChildByFullName("itemNode")
end

function CloudCitySweepRewardView:reflashUI(data)
    self._currencyNode:removeAllChildren()
    self._itemNode:removeAllChildren()

    self._rewardItem:setOpacity(0)
    self._rewardItem:setPositionY(self._rewardItem:getPositionY()-10)
    self._rewardItem:runAction(cc.Spawn:create(cc.FadeIn:create(0.1), cc.MoveBy:create(0.1, cc.p(0, 10))) )

    local isActivityOpen = self._cModel:isActivityOpen()

    local iconWidth = 82
    local cIconWidth = 34
    local offsetX = 3
    local infoEndPos = 0
    for i = 1, #self._rewardData do
        local data = self._rewardData[i]
        if data.type == "tool" then
            local toolD = tab:Tool(data.typeId)
            local itemIcon = IconUtils:createItemIconById({itemId = data.typeId, itemData = toolD, num = data.num})
            itemIcon:setScale(iconWidth / itemIcon:getContentSize().width)
            itemIcon:setPosition(#self._itemNode:getChildren() * (iconWidth + offsetX) , 0)
            local countStrColor = isActivityOpen and UIUtils.colorTable.ccUIBaseColor2 or cc.c3b(255,255,255)
            itemIcon:getChildByFullName("iconColor"):getChildByFullName("numLab"):setColor(countStrColor)
            self._itemNode:addChild(itemIcon)

        else
            local currencyIcon = nil
            local iconPath = IconUtils.resImgMap[data.type]
            if iconPath == nil then
                local itemId = tonumber(IconUtils.iconIdMap[data.type])
                local toolD = tab:Tool(itemId)
                iconPath = IconUtils.iconPath .. toolD.art .. ".png"
                currencyIcon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD})
            end
            currencyIcon = cc.Sprite:createWithSpriteFrameName(iconPath)
            currencyIcon:setScale(cIconWidth / currencyIcon:getContentSize().width)
            currencyIcon:setPosition(infoEndPos + cIconWidth / 2 + 20, 19)
            self._currencyNode:addChild(currencyIcon)
            infoEndPos = currencyIcon:getPositionX() + cIconWidth / 2

            local rewardCount = cc.Label:createWithTTF(tostring(data.num), UIUtils.ttfName, 22) 
            rewardCount:setColor(cc.c4b(61,31,0,255))
            rewardCount:setPosition(infoEndPos + rewardCount:getContentSize().width / 2 + 5, 19)
            self._currencyNode:addChild(rewardCount)

            infoEndPos = rewardCount:getPositionX() + rewardCount:getContentSize().width / 2
        end
    end

    if self._finishMc ~= nil then
        self._finishMc = mcMgr:createViewMC("fubensaodang_shuaxinguangxiao", false, true)
        self._finishMc:setPosition(cc.p(self:getContentSize().width/2 + 10, self:getContentSize().height/2))
        self:addChild(self._finishMc,10)
    end
end

function CloudCitySweepRewardView:onShow()
    if self._finishMc == nil then
        self._finishMc = mcMgr:createViewMC("fubensaodang_shuaxinguangxiao", false, true)
        self._finishMc:setPosition(cc.p(self:getContentSize().width/2 + 10, self:getContentSize().height/2))
        self:addChild(self._finishMc,10)
    end
end

return CloudCitySweepRewardView