--[[
    Filename:    VipRewardView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-01-20 23:33:20
    Description: vip界面首次进入奖励界面
--]]

local VipRewardView = class("VipRewardView", BasePopView)

function VipRewardView:ctor(param)
	VipRewardView.super.ctor(self)

	self._callback = param.callback
	self._type = param.openType or 1
end

function VipRewardView:getMaskOpacity( ... )
    return 220
end

function VipRewardView:getAsyncRes()
    return {}
end

function VipRewardView:onInit()
	-- self:registerClickEventByName("closePanel", function()
	-- 	self:close()
	-- 	end)

	self:registerClickEventByName("bg.okBtn", function()
		if self._callback then
			self._callback()
		end
		self:close()
		-- UIUtils:reloadLuaFile("vip.VipRewardView")
		end)

	self._roleImg = self:getUI("bg.roleImg")
	self._roleImg:loadTexture("asset/bg/global_reward2_img.png")
	self._roleImg:setPosition(0, 353)

	local tipDes2 = self:getUI("bg.reward.des1.Label_32")
	tipDes2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	local tipDes1 = self:getUI("bg.reward.des1.Label_31")
	tipDes1:setColor(UIUtils.colorTable.ccUIMenuBtnColor1)
	tipDes1:enable2Color(1, UIUtils.colorTable.ccUIMenuBtnColor2)
	local tipDes3 = self:getUI("bg.reward.des1.Label_33")
	tipDes3:setColor(UIUtils.colorTable.ccUIMenuBtnColor1)
	tipDes3:enable2Color(1, UIUtils.colorTable.ccUIMenuBtnColor2)
	local tipDes4 = self:getUI("bg.reward.des2")
	tipDes4:setColor(UIUtils.colorTable.ccUIMenuBtnColor1)
	tipDes4:enable2Color(1, UIUtils.colorTable.ccUIMenuBtnColor2)

	self:refreshUI()
	self:runAnim()
end

function VipRewardView:refreshUI()
	local _res = {
		[1] = {   	--首次进入vip	
			des1 = "[color=462800,fontsize = 20]购买月卡，每天都可以获赠[-][color=4eebfe,outlinecolor=3c1e0aff,fontsize = 20]100钻石[-][color=462800,fontsize = 22]呢[-]",
			rwdImg = {"vip_baoshi_4.png"},
			btnTitle = "收下啦"},

		[2] = { 	--月卡	
			des1 = "[color=462800,fontsize = 20]月卡激活后，记得去活动界面领取每日的钻石福利哦~[-]",
			des2 = "已激活初级月卡！",
			rwdImg = {"vip_monthCard.png"},
			btnTitle = "领取福利"},

		[3] = { 	--至尊月卡	
			des1 = "[color=462800,fontsize = 20]月卡激活后，记得去活动界面领取每日的钻石福利哦~[-]",
			des2 = "已激活至尊月卡！",
			rwdImg = {"vvip_monthCard.png"},
			btnTitle = "领取福利"},
		
		[4] = { 	--双月卡	
			des1 = "[color=462800,fontsize = 20]月卡激活后，记得去活动界面领取每日的钻石福利哦~[-]",
			des2 = "已激活初级月卡&至尊月卡！",
			rwdImg = {"vip_monthCard.png", "vvip_monthCard.png"},
			btnTitle = "领取福利"},
	}
	local _posX = {[1] = {0}, [2] = {-100, 100}}

	local data = _res[self._type]

	--okBtn
	local okBtn = self:getUI("bg.okBtn")
	okBtn:setTitleText(data["btnTitle"])

	--tip1
	local talkBg = self:getUI("bg.talkBg")
    if self._type == 1 then
    	local img = ccui.ImageView:create("vip_monthCard.png", 1)
		img:setPosition(77, 47)
		img:setScale(0.32)
		img:ignoreContentAdaptWithSize(false)
		talkBg:addChild(img) 

    	local tip1 = RichTextFactory:create(data["des1"], 180, 0)
    	tip1:formatText()
    	tip1:setPosition(212, 46)
    	talkBg:addChild(tip1)
    else
    	local tip1 = RichTextFactory:create(data["des1"], 258, 0)
    	tip1:formatText()
    	tip1:setPosition(168, 46)
    	talkBg:addChild(tip1)
    end

    --Tip2
    local tip21 = self:getUI("bg.reward.des1")  --vip
    local tip22 = self:getUI("bg.reward.des2")  --monthcard
    tip21:setVisible(false)
    tip22:setVisible(false)
    if self._type == 1 then
    	tip21:setVisible(true)
    elseif self._type == 2 or self._type == 3 then
    	tip22:setVisible(true)
    	tip22:setString(data["des2"])
    end

    --rwdImg
    local reward = self:getUI("bg.reward")
    reward.rwds = {}
	for i,v in ipairs(data["rwdImg"]) do
		local rwdImg = ccui.ImageView:create(v, 1)
		rwdImg:setPosition(_posX[#data["rwdImg"]][i], 0)
		rwdImg:setScale(0.65)
		rwdImg:ignoreContentAdaptWithSize(false)
		reward:addChild(rwdImg)

		local lightMc = mcMgr:createViewMC("huodedaojudiguang_commonlight", true)
		lightMc:setCascadeOpacityEnabled(true, true)
	    lightMc:setOpacity(120)
		lightMc:setPosition(rwdImg:getPosition())
		table.insert(reward.rwds, {img = rwdImg, mc = lightMc})
		reward:addChild(lightMc, -1)

		if self._type == 1 then
			rwdImg:setScale(1.6)
	    end
	end
end

function VipRewardView:runAnim()
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
	if GameStatic.appleExamine then
		talkBg:setVisible(false)
	end
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

return VipRewardView
