--
-- Author: huangguofang
-- Date: 2017-07-03 11:36:30
--

local AcCelebrationGiftsDialog = class("AcCelebrationGiftsDialog",BasePopView)

function AcCelebrationGiftsDialog:ctor(param)
    AcCelebrationGiftsDialog.super.ctor(self)
  	self._giftsData = param.giftsData or {}
  	self._callback = param.callBack
  	-- dump(self._giftsData,'self._giftsData',5)
end

-- 第一次被加到父节点时候调用
function AcCelebrationGiftsDialog:onAdd()

end
-- 初始化UI后会调用, 有需要请覆盖
function AcCelebrationGiftsDialog:onInit()

	-- 在赠送按钮
	self:registerClickEventByName("giftListPanel.getBtn", function()
		-- 收下离去 yeah		
		-- 领取好友赠送文字奖励	
		self._serverMgr:sendMsg("ActivityServer", "receiveFriendText", {}, true, {}, function(result,succ)
			self:close()
			if self._callback then
				self._callback()
			end
			UIUtils:reloadLuaFile("activity.celebration.AcCelebrationGiftsDialog")
		    if result["reward"] then
	        	DialogUtils.showGiftGet({ 
	        		gifts = result["reward"], 
	        		callback = function()	        		
		        		
	        		end})
	        end
		end)

	end)
	self._titleImg = self:getUI("bg.titleImg")

	-- 好友赠送礼物列表
	self._giftListPanel = self:getUI("giftListPanel")
	self._giftListPanel:setVisible(false)
	-- 礼包按钮
	self._giftBtn = self:getUI("bg.giftBtn")
	self._giftBtn:setOpacity(0)
	self._giftBtn:setEnabled(false)
	self:addGiftAnim()
	
	-- 添加动画 动画结束之后可点击
	registerClickEvent(self._giftBtn,function(sender)
		self._giftListPanel:setVisible(true)
    end)
	self._giftsArr = {}
	self._cellW = 300		
	self._cellH = 110
	self:addGiftsList()
end

-- 播放动画
function AcCelebrationGiftsDialog:addGiftAnim()	
	local giftMc = mcMgr:createViewMC("libao_jizibaoxiang", false, false,function(_,sender)
		self._giftBtn:setEnabled(true)		
	end)
    giftMc:setPosition(self._giftBtn:getContentSize().width*0.5, self._giftBtn:getContentSize().height*0.5)
    self._giftBtn:addChild(giftMc,1)

    self._titleImg:setScale(3)
    self._titleImg:setOpacity(0)
    local action = cc.Sequence:create(cc.DelayTime:create(0.6),
    	cc.CallFunc:create(function()    		
			local lightMc = mcMgr:createViewMC("choukahuodeguang_flashchoukahuode", true, false)
		    lightMc:setPosition(self._giftBtn:getContentSize().width*0.5, self._giftBtn:getContentSize().height*0.5)
		    self._giftBtn:addChild(lightMc,-1)

    	end),
    	cc.Spawn:create(cc.ScaleTo:create(0.5,1),cc.FadeIn:create(0.5)),
    	cc.CallFunc:create(function()    		
		    local ziMc = mcMgr:createViewMC("zitiguang_jizibaoxiang", false, false)
		    ziMc:setPosition(self._titleImg:getContentSize().width*0.5, self._titleImg:getContentSize().height*0.5)
		    self._titleImg:addChild(ziMc,1)
    	end))

    self._titleImg:runAction(action)

end
-- 好友赠送列表
function AcCelebrationGiftsDialog:addGiftsList()
	if not self._giftsData then return end
	local giftsList = self:getUI("giftListPanel.giftsList")
	local sVisibleH = giftsList:getContentSize().height
	local scrollH = 0
	for k,v in pairs(self._giftsData) do
		local item = self:createGiftsCell(v)
		item:setPosition(0,0)
	    item:setName("cellItem" .. k)
	    item:setAnchorPoint(0,0)
	    scrollH = scrollH + item.__height
	    giftsList:addChild(item)
	    table.insert(self._giftsArr, item)
	end
	
	scrollH = scrollH > sVisibleH and scrollH or sVisibleH
	giftsList:setInnerContainerSize(cc.size(giftsList:getContentSize().width, scrollH))

	local posY = scrollH + 8
	for k,v in pairs(self._giftsArr) do
		posY = posY - v.__height
		v:setPosition(0,posY)
	end

end

function AcCelebrationGiftsDialog:createGiftsCell(giftData)
	local nameTxt = giftData.name or ""
	local itemData = giftData.items or {}
	local giftsNum = table.nums(itemData)
	local itemH = 70

	--名片区域
	local height = 0
	height = height + math.ceil(giftsNum/4)*itemH
	local layout = ccui.Widget:create()  
	layout = ccui.Widget:create()  
	layout:setContentSize(cc.size(self._cellW, height + 30)) --40 title的高度	
	layout:setColor(cc.c4b(125,125,125,255))
	layout.__height = height + 30

	-- title1
	local title1 = ccui.Text:create()
	title1:setString("您的好友")
	title1:setFontName(UIUtils.ttfName)
	title1:setColor(UIUtils.colorTable.ccUIBasePromptColor)
	title1:setFontSize(20)
	title1:setAnchorPoint(cc.p(0,0))
	title1:setPosition(0, height)
	layout:addChild(title1)

	-- 名字
	local nameLab = ccui.Text:create()
	nameLab:setString(nameTxt)
	nameLab:setFontName(UIUtils.ttfName)
	nameLab:setColor(cc.c4b(91,232,117,255))
	nameLab:setFontSize(20)
	nameLab:setAnchorPoint(cc.p(0,0))
	nameLab:setPosition(0 + title1:getContentSize().width, height)
	layout:addChild(nameLab)

	-- title2
	local title2 = ccui.Text:create()
	title2:setString("赠送给您")
	title2:setFontName(UIUtils.ttfName)
	title2:setColor(UIUtils.colorTable.ccUIBasePromptColor)
	title2:setFontSize(20)
	title2:setAnchorPoint(cc.p(0,0))
	title2:setPosition(0 + title1:getContentSize().width + nameLab:getContentSize().width, height)
	layout:addChild(title2)

	--背景
	local bgImg = ccui.ImageView:create()
	bgImg:loadTexture("globalImageUI_tips_cellbg.png", 1)
	bgImg:setScale9Enabled(true)
	bgImg:ignoreContentAdaptWithSize(false)
	bgImg:setCapInsets(cc.rect(13, 17, 1, 1))
	bgImg:setContentSize(cc.size(self._cellW, height))
	bgImg:setAnchorPoint(0,0)
	bgImg:setPosition(0, 0)
	layout:addChild(bgImg)

	local posx = 15 
	local posy = height - itemH + 5
	-- dump(itemData,"itemData==>",5)
	local item1 = false
	for k,v in pairs(itemData) do
		local itemId = v["itemId"]
		local toolD = tab:Tool(tonumber(itemId))
		icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = v["num"]})
		icon:setName("icon" .. k)
		icon:setScale(0.66)
		-- icon:settouch
		icon:setPosition(posx,posy)
		if k == 4 then
			posx = 15
			posy = posy - itemH
		else
			posx = posx + itemH
		end
		layout:addChild(icon,5)
		
	end
	
	return layout
	
end

function AcCelebrationGiftsDialog:reflashUI()
	-- body
end


return AcCelebrationGiftsDialog