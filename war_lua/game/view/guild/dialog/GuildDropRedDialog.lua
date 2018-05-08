--[[
    Filename:    GuildDropRedDialog.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-04-19 23:33:20
    Description: 随机获得联盟红包奖励界面
--]]

local GuildDropRedDialog = class("GuildDropRedDialog", BasePopView)

function GuildDropRedDialog:ctor(redData)
	GuildDropRedDialog.super.ctor(self)
	self._redData = redData or {}
	self._curIndex = 1
	self._redId = self._redData[1]
end

function GuildDropRedDialog:getMaskOpacity( ... )
    return 220
end

function GuildDropRedDialog:getAsyncRes()
    return {}
end

function GuildDropRedDialog:onInit()

	self:registerClickEventByName("bg.okBtn", function()
		self:close()
		end)
	local redPanel = self:getUI("bg.redPanel")
	local sendBtn = redPanel:getChildByFullName("send")
	self:registerClickEvent(sendBtn, function()
		self:sendUserRed()
    end)

	self._richPanel = self:getUI("bg.talkBg.Panel_18")
	self._roleImg = self:getUI("bg.roleImg")
	self._roleImg:loadTexture("asset/bg/global_reward2_img.png")


	self:refreshUI()
end


-- 玩家发送红包
function GuildDropRedDialog:sendUserRed()
	local redId = self._redItemID
	printf(" redId == %d",redId)
    self._serverMgr:sendMsg("GuildRedServer", "sendRandomRed", {redId = redId}, true, {}, function (result)
        -- dump(result, "resul玩家发送红包t==============")
		-- if result["reward"] and table.nums(result["reward"]) > 0 then
		-- 	DialogUtils.showGiftGet({gifts = result["reward"]})
		-- end
		self._viewMgr:showTip("发送成功，可在联盟红包中查看")
        self:sendUserRedFinish(result)
    end, function(errorId)
    	if tonumber(errorId) == 2808 then
			self._viewMgr:showTip("大人，您今天没有次数了")
		elseif tonumber(errorId) == 2802 then
			self._viewMgr:showTip("这个红包已过期")
		elseif tonumber(errorId) == 2801 then
			self._viewMgr:showTip("5点可参与红包活动")
		end
    end)
end

function GuildDropRedDialog:sendUserRedFinish()
	self._curIndex = self._curIndex + 1
	self._redId = self._redData[self._curIndex]
	if self._redId == nil then
		self:close()
		return
	end
	self:refreshUI()
end

function GuildDropRedDialog:refreshUI()


	--可获得红包奖励
	print("self._redId"..self._redId)
	local configData = tab:RandomRed(self._redId)
	dump(configData)
	local toolData = configData.tool[1]
	local toolID = toolData[2]
	self._redItemID = toolID
	local redConfigData = tab:GuildUserRed(toolID)
	local richTxt = lang(configData.word)


	--富文本---
	self._richPanel:removeAllChildren()
	local richLable = RichTextFactory:create(richTxt, self._richPanel:getContentSize().width, self._richPanel:getContentSize().height)
	richLable:formatText()
	richLable:setPositionY(self._richPanel:getContentSize().height/2)
	richLable:setPositionX(self._richPanel:getContentSize().width/2)
	self._richPanel:addChild(richLable,11)

	local count = self:getUI("bg.redPanel.count")
	local num = redConfigData.give[3]
	count:setString(num)

end

function GuildDropRedDialog:runAnim()
	--精灵
	self._roleImg:setOpacity(0)
	self._roleImg:setBrightness(80)
	self._roleImg:runAction(cc.Spawn:create(
		cc.FadeIn:create(0.4),
		cc.Sequence:create(
			cc.MoveTo:create(0.25, cc.p(298, 353)),
			cc.CallFunc:create(function()
				self._roleImg:setBrightness(0)
				self:addDecorateCorner()
				end),
			cc.MoveTo:create(0.15, cc.p(288, 353))
			 )))

	--对话
	local talkBg = self:getUI("bg.talkBg")
	local posX, posY = talkBg:getPositionX(), talkBg:getPositionY()
	talkBg:setScale(0)
	talkBg:runAction(cc.Spawn:create(
		cc.FadeIn:create(0.3),
		cc.Sequence:create(
			cc.DelayTime:create(0.1),
			cc.ScaleTo:create(0.2, 1),
			cc.CallFunc:create(function()
				talkBg:runAction(cc.RepeatForever:create(
					cc.Sequence:create(
						cc.MoveTo:create(0.5, cc.p(posX + 3, posY + 3)),
						cc.MoveTo:create(0.5, cc.p(posX, posY)) )
					))
				end)
			)))

	--背景条
	local rewardBg = self:getUI("bg.rewardBg")
	rewardBg:setScale(0)
	rewardBg:runAction(cc.Speed:create(cc.Spawn:create(
		cc.FadeIn:create(0.35),
		cc.Sequence:create(
			cc.ScaleTo:create(0.25, 1, 0.9),
			cc.ScaleTo:create(0.05, 1, 1.1),
			cc.ScaleTo:create(0.05, 1, 1)
			)), 1.1))

	--翅膀
	local swing1 = self:getUI("bg.rewardBg.Image_38")
	swing1:setAnchorPoint(cc.p(0, 0))
	swing1:setPosition(247, -6)
	local swing2 = self:getUI("bg.rewardBg.Image_39")
	swing1:runAction(cc.Sequence:create(
		cc.RotateTo:create(0.1, 20), 
		cc.RotateTo:create(0.1, -10), 
		cc.RotateTo:create(0.3, 0)
		))
	swing2:runAction(cc.Sequence:create(
		cc.RotateTo:create(0.1, -20), 
		cc.RotateTo:create(0.1, 10), 
		cc.RotateTo:create(0.3, 0)
		))
	

	--奖励
	local reward = self:getUI("bg.reward")
	for i,v in ipairs(reward.rwds) do
		local scaleL = v["img"]:getScale()
		v["img"]:setScale(0)
		v["mc"]:setVisible(false)
		v["img"]:runAction(cc.Spawn:create(
			cc.FadeIn:create(0.35),
			cc.Sequence:create(
				cc.ScaleTo:create(0.25, scaleL - 0.05),
				cc.CallFunc:create(function()
					v["mc"]:setVisible(true)
					end),
				cc.ScaleTo:create(0.05, scaleL + 0.05),
				cc.ScaleTo:create(0.05, scaleL)
				)))
	end
	
end

return GuildDropRedDialog
