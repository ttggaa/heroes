--[[
    Filename:    ChatSysCel.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-04-07 19:38:13
    Description: File description
--]]

local ChatSysCell = class("ChatSysCell", cc.TableViewCell)

function ChatSysCell:ctor()

end

function ChatSysCell:onInit()

end

function ChatSysCell:reflashUI(data, richText, width, height)
    if richText:getParent() ~= nil then 
        local tempText = richText
        richText = cc.Node:create()
        richText:setContentSize(cc.size(tempText:getContentSize().width, tempText:getContentSize().height))
    end
    if richText.getRealSize == nil then 
        richText.getRealSize = richText.getContentSize
    end 
      
	if self._channelSp == nil then
        self._channelSp = ccui.ImageView:create("chatImg_channel_" .. data.type .. ".png", 1)
        self._channelSp:setAnchorPoint(0, 1)
        self:addChild(self._channelSp)
    else
        self._channelSp:loadTexture("chatImg_channel_" .. data.type .. ".png", 1)
    end
    self._channelSp:setPosition(10, height - 5)

    if self._textBg == nil then 
    	self._textBg = cc.Node:create()
    	self._textBg:setAnchorPoint(0, 1)
    	self:addChild(self._textBg)
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
    self._textBg:setPosition(60, height)
    

    richText:setPosition(x, textBgHeight/2)

    self._textBg:addChild(richText)

    self.richText = richText
end

return ChatSysCell