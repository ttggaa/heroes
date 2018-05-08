--[[
    Filename:    GuildTipGiftDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-03-25 14:48:52
    Description: File description
--]]

-- 公会每日礼包
local GuildTipGiftDialog = class("GuildTipGiftDialog", BasePopView)

function GuildTipGiftDialog:ctor()
    GuildTipGiftDialog.super.ctor(self)
end

function GuildTipGiftDialog:onInit()
    self._userModel = self._modelMgr:getModel("UserModel")

    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("guild.dialog.GuildTipGiftDialog")
        end
        self:close()
    end)

    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 6)

    local receiveBtn = self:getUI("bg.receiveBtn")
    self:registerClickEvent(receiveBtn, function()
        -- print("=========, 领取奖励")
        self:getGuildDailyGift()
    end)
end

function GuildTipGiftDialog:reflashUI()
    local userD = self._userModel:getData()
    local guildLevel = userD.guildLevel
    local itemId = tab:GuildLevel(guildLevel).gift 
    local itemTab = tab:ToolGift(itemId)
    local giftData = itemTab.giftContain

    for i=1,3 do
        local itemBg = self:getUI("bg.itemBg.itemBg" .. i)
        local itemName = self:getUI("bg.itemBg.itemBg" .. i .. ".name")
        if giftData[i] then
            itemBg:setVisible(true)
            local titemId = giftData[i][2]
            local titemNum = giftData[i][3]
            if IconUtils.iconIdMap[giftData[i][1]] then
                titemId = IconUtils.iconIdMap[giftData[i][1]]
            end
            local titemData = tab:Tool(titemId)
            local titemIcon = IconUtils:createItemIconById({itemId = titemId, itemData = titemData, effect = false, num = titemNum})
            titemIcon:setSwallowTouches(true)
            titemIcon:setAnchorPoint(cc.p(0,0))
            titemIcon:setVisible(true)
            itemBg:addChild(titemIcon)
            local itemNormalScale = 80/titemIcon:getContentSize().width
            titemIcon:setScale(itemNormalScale)
            itemName:setString(lang(titemData.name))
            local color = ItemUtils.findResIconColor(titemId, titemNum) or 1
            itemName:setColor(UIUtils.colorTable["ccUIBaseColor" .. color])
            -- itemName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        else
            itemBg:setVisible(false)
        end
    end
end

function GuildTipGiftDialog:getGuildDailyGift()
    self._serverMgr:sendMsg("GuildServer", "getGuildDailyGift", {}, true, {}, function (result)
        DialogUtils.showGiftGet({
            gifts = result.award,
            callback = function()
                if self.close then
                    self:close()
                end
        end})
        -- DialogUtils.showGiftGet({gifts = result.reward})
    end)
end

return GuildTipGiftDialog