--[[
    Filename:    GlobalNoticeView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-03-02 20:05:21
    Description: File description
--]]

local GlobalNoticeView = class("GlobalNoticeView", BaseView)

function GlobalNoticeView:ctor()
    GlobalNoticeView.super.ctor(self)
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
    			-- local maxWidth = (self._textBg:getContentSize().width + self._cacheMoveToX)
    			-- local parent = math.abs((self._cachePosition + self._cacheMoveToX) / maxWidth)

    			local textWid = self._textBg:getContentSize().width
			    local needT = (textWid +  self._cachePosition) / self._moveDis
    			
			    self._textBg:runAction(cc.Sequence:create(
			    		cc.MoveTo:create(needT, cc.p(- self._cacheMoveToX, 0)), 
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

function GlobalNoticeView:onInit()
	self._isShow = false
	-- 每秒移动距离
	self._moveDis = 100
	-- 移动所到点
	self._cacheMoveToX = 0
	-- 移动时间
	self._cacheMoveTime = 0
	-- 当前移动点
	self._cachePosition = 0
	self._noticeModel = self._modelMgr:getModel("NoticeModel")
	self:listenReflash("NoticeModel", self.reflashUI)

	local bg = self:getUI("bg.bg")
    bg:setOpacity(0)
end


function GlobalNoticeView:reflashUI(inData)
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
	local noticeData = self._noticeModel:getNoticeData()
	if noticeData == nil then 
		self._isShow = false
		bg:runAction(cc.FadeTo:create(0.2, 0))
		return
	end
	self._isShow = true
	bg:removeAllChildren()
	bg:runAction(cc.FadeTo:create(0.2, 150))

	self._textBg =  cc.Layer:create()
	self._textBg:setAnchorPoint(0, 0)

	--富文本
	local context = self:getRichText(noticeData)
	if context == nil then 
		self._isShow = false
		self._textBg = nil
		bg:setOpacity(0)
		return 
	end

	--富文本格式容错
	local stringTable
    pcall(function ()
        stringTable = richTextDecode(context)
    end)
    if stringTable == nil then
		self._isShow = false
		self:reflashUI()
		return
	end

	pcall(function()		
	    local richText = RichTextFactory:create(context, 3000, 0)
	    richText:formatText()
	    self._textBg:setContentSize(richText:getRealSize().width, bg:getContentSize().height)
	    richText:setPosition(richText:getContentSize().width/2, self._textBg:getContentSize().height/2)
	    self._textBg:addChild(richText)
	end)

    self._textBg:setPosition(bg:getContentSize().width, 0)
    bg:addChild(self._textBg)

    self._cacheMoveToX = self._textBg:getContentSize().width 
    -- self._cacheMoveTime = 4 * (1 + self._cacheMoveToX / self._textBg:getContentSize().width)

    local textWid = self._textBg:getContentSize().width
    local bgWid = bg:getContentSize().width
    local needT = (textWid +  bgWid) / self._moveDis

    self._textBg:runAction(cc.Sequence:create(
    		cc.MoveTo:create(needT, cc.p(-self._cacheMoveToX, 0)), 
    		cc.CallFunc:create(function() 
    			self._isShow = false
    			self:reflashUI()
    		end)))
end

function GlobalNoticeView:getRichText(inData)
	local context = "[color=fa921a,outlinecolor=3c1e0a,fontsize=16]空{$name}{$num}[-]"
	--限时神将
	if inData.bdType and inData.bdType == "limitTeam" then
		local acOpenInfoTableData = tab.activityopen
	    if OS_IS_WINDOWS and is_activityOpenDev then
	        acOpenInfoTableData = tab.activityopen_dev
	    end
	    local acId = acOpenInfoTableData[tonumber(inData["acId"])].activity_id
		if inData["type"] == 1 then   --整卡
			context = lang("GUANGBO_ac" .. acId .."_2")
			context = string.gsub(context, "{$name}", inData["name"])
		elseif inData["type"] == 3 then  --招募
			context = lang("GUANGBO_ac" .. acId .."_1")
			context = string.gsub(context, "{$name}", inData["name"])
		end

	--系统循环播放消息
	elseif inData.adType and inData.adType == "sys" then
		context = "[color=F9DBA6,outlinecolor=3c1e0aff]" .. (inData["content"] or "") .. "[-]"

	else
		context = lang(inData.id)
		if context == nil then
			return nil
		end

		for i,v in pairs(inData.replace) do
			local releaceData = string.split(v, "::")
			if #releaceData == 2 then

				local key = releaceData[1]
		 		local name = releaceData[2]

				if string.find(releaceData[1], '$teamId') ~= nil then
					local sysTeam = tab:Team(tonumber(releaceData[2]))
					if inData.id == "GUANGBO_AWAKING" then   --兵团觉醒
						key = "$awakingName"
						name = lang(sysTeam.awakingName)
					else
						name = lang(sysTeam.name)
					end
				elseif string.find(releaceData[1], '$heroId') ~= nil then
					local sysTeam = tab:Hero(tonumber(releaceData[2]))
					name = lang(sysTeam.heroname)
				elseif string.find(releaceData[1], '$gift') ~= nil then
					local chatModel = self._modelMgr:getModel("ChatModel")
		            local giftId,itemType,itemCount = chatModel:getGiftId(releaceData[2])
		            if itemType == "hero" then
		            	local sysTeam = tab:Hero(tonumber(giftId))
						name = lang(sysTeam.heroname)
					elseif itemType == "team" then
						local sysTeam = tab:Team(tonumber(giftId))
						name = lang(sysTeam.name)
					elseif itemType == "tool" then
						local sysTool = tab:Tool(tonumber(giftId))
			            name = lang(sysTool.name)
			            -- 周礼包获得兵团碎片，英雄碎片，后加 碎片2字描述  lishunan
			            if inData.id == "GUANGBO_vipgift" then 
			            	if sysTool.typeId == 1 or sysTool.typeId == 6 then
			            		name = name .. "碎片"
			            	end
			            	if itemCount then
			            		local itemCustomColor = UIUtils:getItemColorValue(tonumber(giftId),itemCount)
				            	local uresult,count1 = string.gsub(context, "ffe430", itemCustomColor)
								if count1 > 0 then 
									context = uresult
								end
			            	end
			            end
		            end
				end

				local uresult,count1 = string.gsub(context, key, name)
				if count1 > 0 then 
					context = uresult
				end
			end
		end
	end

	return context
end

return GlobalNoticeView