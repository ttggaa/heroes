--[[
    @FileName   ElementSweepRewardView.lua
    @Authors    zhangtao
    @Date       2017-08-17 15:25:04
    @Email      <zhangtao@playcrad.com>
    @Description   扫荡
--]]
local ElementSweepRewardView = class("ElementSweepRewardView",BasePopView)
function ElementSweepRewardView:ctor(data)
    ElementSweepRewardView.super.ctor(self)

    self._elementId = data.elementId
    self._rewardData = data.reward
    self._againCallBack = data.againCallBack
    self._stageId = data.stageId
end

function ElementSweepRewardView:onInit()
    local title = self:getUI("bg.bg1.titleBk.title")
    UIUtils:setTitleFormat(title, 1)

    self:registerClickEventByName("bg.closeBtn", function()
        UIUtils:reloadLuaFile("elemental.ElementSweepRewardView")
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

function ElementSweepRewardView:reflashUI(data)
    self._currencyNode:removeAllChildren()
    self._itemNode:removeAllChildren()

    self._rewardItem:setOpacity(0)
    self._rewardItem:setPositionY(self._rewardItem:getPositionY()-10)
    self._rewardItem:runAction(cc.Spawn:create(cc.FadeIn:create(0.1), cc.MoveBy:create(0.1, cc.p(0, 10))) )

    local iconWidth = 82
    local cIconWidth = 34
    local offsetX = 3
    local infoEndPos = 0
    for i = 1, #self._rewardData do
        local data = self._rewardData[i]
        dump(data,"==========data==========")
        if data.type == "planeCoin" then
            local currencyIcon = nil
            local iconPath = IconUtils.resImgMap[data.type]
            local itemId = tonumber(IconUtils.iconIdMap[data.type])
            local toolD = tab:Tool(itemId)
            iconPath = IconUtils.iconPath .. toolD.art .. ".png"
            currencyIcon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = data.num})
            currencyIcon:setScale(iconWidth / currencyIcon:getContentSize().width)
            currencyIcon:setPosition(#self._itemNode:getChildren() * (iconWidth + offsetX) , 0)
            self._itemNode:addChild(currencyIcon)

            local isActivityOpen = self._modelMgr:getModel("ElementModel"):isActivityOpen(self._elementId)
            local countStrColor = isActivityOpen and UIUtils.colorTable.ccUIBaseColor2 or cc.c3b(255,255,255)
            currencyIcon:getChildByFullName("iconColor"):getChildByFullName("numLab"):setColor(countStrColor)

        else
            local toolD
            local currencyIcon = nil
            local itemId = tonumber(IconUtils.iconIdMap[data.type])
            if data.type == "tool" then
                toolD = tab:Tool(data.typeId)

            else
                toolD = tab:Tool(itemId)
            end
            local iconPath = IconUtils.resImgMap[data.type]
            if iconPath == nil then
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
            -- if data.type == "planeCoin" then
            --     local isActivityOpen = self._modelMgr:getModel("ElementModel"):isActivityOpen(self._elementId)
            --     local countStrColor = isActivityOpen and UIUtils.colorTable.ccUIBaseColor2 or cc.c3b(61,31,0)
            --     rewardCount:setColor(countStrColor)
            -- end
        end
    end

    if self._finishMc ~= nil then
        self._finishMc = mcMgr:createViewMC("fubensaodang_shuaxinguangxiao", false, true)
        self._finishMc:setPosition(cc.p(self:getContentSize().width/2 + 10, self:getContentSize().height/2))
        self:addChild(self._finishMc,10)
    end
end

function ElementSweepRewardView:onShow()
    if self._finishMc == nil then
        self._finishMc = mcMgr:createViewMC("fubensaodang_shuaxinguangxiao", false, true)
        self._finishMc:setPosition(cc.p(self:getContentSize().width/2 + 10, self:getContentSize().height/2))
        self:addChild(self._finishMc,10)
    end
end

return ElementSweepRewardView