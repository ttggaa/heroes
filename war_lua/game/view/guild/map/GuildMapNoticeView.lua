--[[
    Filename:    GuildMapNoticeView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-03-25 11:08:21
    Description: 联盟地图跑马灯
--]]

local GuildMapNoticeView = class("GuildMapNoticeView", BaseView)

function GuildMapNoticeView:ctor()
    GuildMapNoticeView.super.ctor(self)
    self._setVisible = self.setVisible
    -- 拦截visible 做相关处理
    self.setVisible = function(self,isVisible)
    	if self:isVisible() == isVisible then 
    		return 
    	end
    	local bg = self:getUI("bg.bg")
    	if isVisible == false then
    		if self._textBg ~= nil then 
    			self._textBg:stopAllActions()
    			self._cachePosition = self._textBg:getPositionX()
    		end
    		bg:setOpacity(0)
    	else
    		if self._textBg ~= nil then
    			bg:runAction(cc.FadeTo:create(0.2, 150))
    			local maxWidth = (self._textBg:getContentSize().width + self._cacheMoveToX)
    			local parent = math.abs((self._cachePosition + self._cacheMoveToX) / maxWidth)
			    self._textBg:runAction(cc.Sequence:create(
			    		cc.MoveTo:create(self._cacheMoveTime * parent, cc.p(- self._cacheMoveToX, 0)), 
			    		cc.CallFunc:create(function() 
			    				self._isShow = false
			    				self:reflashUI()
				    			print("_richText finish") 
			    		end)))    			
    		end
    	end
    	self:_setVisible(isVisible)
	end
end

function GuildMapNoticeView:onInit()
	self._isShow = false
	-- 移动所到点
	self._cacheMoveToX = 0
	-- 移动时间
	self._cacheMoveTime = 0
	-- 当前移动点
	self._cachePosition = 0
	self._guildMapModel = self._modelMgr:getModel("GuildMapModel")

	local bg = self:getUI("bg.bg")
    bg:setOpacity(0)
end

function GuildMapNoticeView:reflashUI(inData)
	if inData ~= nil and inData.clearState == true then 
		if self._textBg ~= nil then 
			self._textBg:stopAllActions()
			self._textBg:removeFromParent()
			self._textBg = nil
		end
		self._isShow = false
		return
	end

	if self._isShow == true then
		return 
	end
	local bg = self:getUI("bg.bg")

	if self._textBg ~= nil then 
		self._textBg:stopAllActions()
		self._textBg = nil
	end
	self._isShow = true

	local noticeData = self._guildMapModel:getNoticeData()
	if noticeData == nil then 
		self._isShow = false
		bg:runAction(cc.FadeTo:create(0.2, 0))
		return
	end
	bg:removeAllChildren()
	bg:runAction(cc.FadeTo:create(0.2, 150))

	self._textBg =  cc.Layer:create()
	self._textBg:setAnchorPoint(0, 0)

	-- dump(noticeData, "GuildMapNoticeView", 10)
	--desc
	local context = lang(tab:GuildMapReport(noticeData.type)["guangbo"])
	if context == nil then 
		self._isShow = false
		self._textBg = nil
		bg:setOpacity(0)
		return 
	end
    for k,v in pairs(noticeData.params) do
        context = string.gsub(context, "{$" .. k .. "}", v)
    end
    if string.find(context, "color=") == nil then
        context = "[color=3d1f00]"..context.."[-]"
    end  

    local richText = RichTextFactory:create(context, 3000, 0)
    richText:formatText()
    self._textBg:setContentSize(richText:getRealSize().width, bg:getContentSize().height)
    richText:setPosition(richText:getContentSize().width/2, self._textBg:getContentSize().height/2)
    self._textBg:addChild(richText)


    self._textBg:setPosition(bg:getContentSize().width, 0)
    bg:addChild(self._textBg)
    self._cacheMoveToX = self._textBg:getContentSize().width 
    self._cacheMoveTime = 4 * (1 + self._cacheMoveToX / self._textBg:getContentSize().width)
    self._textBg:runAction(cc.Sequence:create(
    		cc.MoveTo:create(self._cacheMoveTime, cc.p(-self._cacheMoveToX, 0)), 
    		cc.CallFunc:create(function() 
    			self._isShow = false
    			self:reflashUI()
    		end)))
end



return GuildMapNoticeView