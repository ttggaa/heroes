--[[
    Filename:    GuildManageLogCell.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-04-22 17:53:32
    Description: File description
--]]

-- 联盟日志cell
local GuildManageLogCell = class("GuildManageLogCell", cc.TableViewCell)

function GuildManageLogCell:ctor()

end

function GuildManageLogCell:onInit()

end

-- data.type    1：日期 
--              2：消息
function GuildManageLogCell:reflashUI(data, richText, width, height)
    -- if self._channelSp == nil then
    --     self._channelSp = cc.Sprite:createWithSpriteFrameName("chatImg_channel_" .. data.type .. ".png")
    --     self._channelSp:setAnchorPoint(0, 1)
    --     self:addChild(self._channelSp)
    -- end
    -- 
    -- self._channelSp:setSpriteFrame("chatImg_channel_" .. data.type .. ".png")

    local tempH = height - 5
    if data.timeType == 2 then
        
        -- dump(data)
        if self._titleLab == nil then
            self._titleLab = cc.Label:createWithTTF("", UIUtils.ttfName, 24)
            self._titleLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            self._titleLab:setAnchorPoint(0, 1)
            self:addChild(self._titleLab)
        end
        self._titleLab:setVisible(true) 
        self._titleLab:setPosition(2, tempH)
        self._titleLab:setString(data.day)
        tempH = tempH - self._titleLab:getContentSize().height
        if self._channelSp == nil then
            self._channelSp = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
            self._channelSp:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            self._channelSp:setAnchorPoint(0, 1)
            self:addChild(self._channelSp)
        end
        self._channelSp:setPosition(17, tempH)
        self._channelSp:setString(data.time)
    else
        if self._titleLab then
            self._titleLab:setVisible(false) 
        end
        if self._channelSp == nil then
            self._channelSp = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
            self._channelSp:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            self._channelSp:setAnchorPoint(0, 1)
            self:addChild(self._channelSp)
        end
        self._channelSp:setPosition(17, tempH)
        self._channelSp:setString(data.time)
    end
     -- 4

    if self._textBg == nil then 
        self._textBg = cc.Node:create()
        self._textBg:setAnchorPoint(0, 1)
        self:addChild(self._textBg)
    end

    if self._textBg:getChildByName("text") ~= nil then
        self._textBg:getChildByName("text"):retain()
        self._textBg:removeAllChildren()
    end

    local x = richText:getRealSize().width / 2
    if richText:getRealSize().width < richText:getContentSize().width then 
        x = richText:getContentSize().width / 2
    end
    x = x + 20
    
    local textBgHeight = 35 
    if richText:getRealSize().height + 10 > textBgHeight then 
        textBgHeight = richText:getRealSize().height + 10
    end

    self._textBg:setContentSize(cc.size(width + 40, textBgHeight))
    self._textBg:setPosition(60, tempH + 5)
    

    richText:setPosition(x, textBgHeight/2)

    self._textBg:addChild(richText)
end

return GuildManageLogCell