--[[
    Filename:    ChatEmojiNode.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-03-31 16:04:53
    Description: File description
--]]

local ChatEmojiNode = class("ChatEmojiNode", BaseLayer)

function ChatEmojiNode:ctor(param)
	self._callback = param.callback
	self._type = param.type
    ChatEmojiNode.super.ctor(self)
    -- self._isPri = false
end

function ChatEmojiNode:onInit()
	self._viewState = false
	local scrollView = self:getUI("bg.scrollView")
	local height = scrollView:getContentSize().height
	if math.floor(#tab.emoji / 8) * 60 > height  then 
		height = math.floor(#tab.emoji / 8) * 60 
	end
	scrollView:setInnerContainerSize(cc.size(0, height))
	local x = 10
	local y = height - 55
	local i = 1
	for k,v in pairs(tab.emoji) do
		local gifBg = ccui.Widget:create()
		gifBg:setContentSize(60, 60)
		local gifIcon = UIUtils:createGifNode("asset/other/emoji/" .. v.resource)
		gifIcon:setPosition(0, 0)
		gifIcon:setScale(0.5)
		gifIcon:setAnchorPoint(0, 0)
		gifBg:addChild(gifIcon)
		gifBg:setPosition(x, y)
		gifBg:setAnchorPoint(0, 0)
		x = x + 60
		if math.mod(i, 8) == 0 then 
			x = 10 
			y = y - 60
		end
		scrollView:addChild(gifBg)
		gifBg:setSwallowTouches(false)
		registerTouchEvent(gifBg,
		function()

		end,nil,
		function()
			if self._callback ~= nil then
				self._callback(k)
			end
		end,
		function()

		end)
		i = i + 1
	end
	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn, function ()
		self:hideView(true)
	end)
end

function ChatEmojiNode:hideView(anim)
	if self._viewState == false then 
		return
	end
	if anim == false then 
		self:setVisible(false)
	else
		self._viewState = false
		self._viewMgr:lock(-1)
		self:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1, 0),
		cc.CallFunc:create(function()
			self:setVisible(false)
			self._viewMgr:unlock()
		end)))
	end
end

function ChatEmojiNode:showView(anim)
	-- self._isPri = false
	if self._viewState == true then 
		return
	end
	self._viewState = true
	if anim == false then 
		self:setVisible(true)
		self:setScaleY(1)
	else
		self:setVisible(true)
		self:setScaleY(0)
		self._viewMgr:lock(-1)
		self:runAction(cc.Sequence:create(
		cc.ScaleTo:create(0.1, 1, 1),
		cc.CallFunc:create(function()
			self._viewMgr:unlock()
		end)))
	end
end

return ChatEmojiNode