--[[
    Filename:    GuildMapInfoTipView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-04-12 16:29:13
    Description: File description
--]]


local GuildMapInfoTipView = class("GuildMapInfoTipView", BasePopView)

function GuildMapInfoTipView:ctor(data)
    GuildMapInfoTipView.super.ctor(self)
    self._rewardData = data.reward
    self._rewardTime = data.time

    self._showType = data.showType or 1

    self._otherData = data.otherData

    self._callback = data.callback
end


function GuildMapInfoTipView:onInit()
    dump(self._rewardData, "test", 10)
    self:registerClickEventByName("bg.enterBtn", function ()
        if self._callback ~= nil then 
            self._callback()
        end
        self:close()
    end)

    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("guild.map.GuildMapInfoTipView")
        elseif eventType == "enter" then 
        end
    end)   
    for i=1,2 do
        local bg = self:getUI("bg.bg" .. i )
        bg:setVisible(false)
    end
    self["onInit" .. self._showType](self)
 
end

function GuildMapInfoTipView:onInit1()
    local bg = self:getUI("bg.bg1")
    bg:setVisible(true)

    local tipLab = self:getUI("bg.bg1.tipLab")
    tipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local tipLab1 = self:getUI("bg.bg1.Label_19")
    tipLab1:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local tipLab2 = self:getUI("bg.bg1.tipLab2")
    tipLab2:setColor(UIUtils.colorTable.ccUIBaseColor2)
    tipLab2:setString(math.ceil(self._rewardTime / 60))
    tipLab2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    
    tipLab1:setPositionX(tipLab2:getPositionX() + tipLab2:getContentSize().width)
    local tipLab3 = self:getUI("bg.bg1.Label_36")
    tipLab3:setColor(UIUtils.colorTable.ccUIBaseTextColor2)


    local itemType = self._rewardData[1] or self._rewardData.type
    local itemId = self._rewardData[2] or self._rewardData.typeId 
    local itemNum = self._rewardData[3] or self._rewardData.num
    -- dump(data,"data i n createitem")
    if itemType ~= "tool" then
        itemId = IconUtils.iconIdMap[itemType]
    end
    local itemData = tab.tool[itemId]

    local rewardBg = self:getUI("bg.bg1.rewardBg")
    local itemIcon = IconUtils:createItemIconById({itemId = itemId,num = itemNum,itemData = itemData,effect = false })
    itemIcon:setAnchorPoint(0.5, 0.5)
    itemIcon:setPosition(rewardBg:getContentSize().width * 0.5, rewardBg:getContentSize().height * 0.5)
    rewardBg:addChild(itemIcon)
    itemIcon:setScale(0.9)

    local iconColor = itemIcon:getChildByFullName("iconColor")

    local numLab = itemIcon:getChildByFullName("numLab") or iconColor:getChildByFullName("numLab")
    -- numLab:setVisible(false)
    if numLab ~= nil then
        numLab:setAnchorPoint(cc.p(0.5, 0))
        numLab:setPosition(itemIcon:getContentSize().width * 0.5, -25)
        numLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        numLab:setFontSize(24)
        numLab:disableEffect()
    end
end



function GuildMapInfoTipView:onInit2()
    
    print("GuildMapInfoTipView================================")
    local bg = self:getUI("bg.bg2")
    bg:setVisible(true)

    local tipLab = self:getUI("bg.bg2.tipLab")
    tipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    local str = lang("GUILD_MAP_RESET")
    local richText = RichTextFactory:create(str, bg:getContentSize().width, 0)
    richText:setPixelNewline(true)
    richText:formatText() 
    richText:setPosition(bg:getContentSize().width * 0.5 + (bg:getContentSize().width - richText:getRealSize().width) * 0.5 , bg:getContentSize().height * 0.5 - richText:getRealSize().height * 0.5)
    bg:addChild(richText) 
end

function GuildMapInfoTipView:onInit3()
    local bg = self:getUI("bg.bg2")
    bg:setVisible(true)
    local tipLab = self:getUI("bg.bg2.tipLab")
    tipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local str = lang("GUILD_MAP_DIE")
    str = string.gsub(str, "{$guildname}", self._otherData.groupName or "")
    str = string.gsub(str, "{$name}", self._otherData.aimName or "")
    local richText = RichTextFactory:create(str, bg:getContentSize().width, 0)
    richText:setPixelNewline(true)
    richText:formatText() 
    richText:setPosition(bg:getContentSize().width * 0.5 + (bg:getContentSize().width - richText:getRealSize().width) * 0.5, bg:getContentSize().height * 0.5 - richText:getRealSize().height * 0.5)
    bg:addChild(richText) 
end

return GuildMapInfoTipView