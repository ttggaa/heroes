--
-- Author: <ligen@playcrab.com>
-- Date: 2017-02-09 10:15:32
--
local HeroDuelGiveUpView = class("HeroDuelGiveUpView", BasePopView)
function HeroDuelGiveUpView:ctor(data)
    HeroDuelGiveUpView.super.ctor(self)

    self._rewardData = data.data
    self._callBack = data.callBack
end

function HeroDuelGiveUpView:onInit()
    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 6)
    title:setString("参赛奖励")

    self:registerClickEventByName("bg.closeBtn", function()
        self:close()
        UIUtils:reloadLuaFile("heroduel.HeroDuelGiveUpView")
    end )

    self:registerClickEventByName("bg.btn1", function()
        self._callBack()
        self:close()
    end )

    self:registerClickEventByName("bg.btn2", function()
        self:close()
    end )

    local descLabel = self:getUI("bg.descLabel")
    descLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    descLabel:setString("如果您现在放弃比赛，可获得以下奖励")

    local rewardNode = self:getUI("bg.rewardNode")

    local rewardNum = #self._rewardData
    local iconWidth = 90
    local spaceX = 10
    local offsetX = 5+(iconWidth+spaceX)*0.5*(3-rewardNum)
    for i = 1, rewardNum do
        local itemType = self._rewardData[i][1]
        local itemId = nil
        if itemType == "tool" then
            itemId = self._rewardData[i][2]
        else 
            itemId = IconUtils.iconIdMap[itemType]
        end
        local toolD = tab:Tool(tonumber(itemId))
        local rewardIcon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD, num = self._rewardData[i][3]})
        rewardIcon:setScale(iconWidth / rewardIcon:getContentSize().width)
        rewardIcon:setPosition((i - 1) * (iconWidth + spaceX) + offsetX , 10)
        rewardNode:addChild(rewardIcon)
    end
end

return HeroDuelGiveUpView