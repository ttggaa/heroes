--
-- Author: huangguofang
-- Date: 2016-09-03 16:56:09
--
local ACGreenDragonRuleLayer = class("ACGreenDragonRuleLayer",BaseLayer)
function ACGreenDragonRuleLayer:ctor()
    self.super.ctor(self)

end

-- 初始化UI后会调用, 有需要请覆盖
function ACGreenDragonRuleLayer:onInit()

	self._scrollView = self:getUI("bg.rulePanel.scrollview")

	self._scrollView:removeAllChildren()
    self._scrollView:setBounceEnabled(true)

    local itemH = 70
    local height = 0

 --    -- 增加富文本
	-- local rtxStr = lang("rankrule")  
	-- -- print("======",rtxStr)
	-- local rtx = RichTextFactory:create(rtxStr,600,200)
 --    rtx:formatText()
 --    rtx:setVerticalSpace(3)
 --    -- rtx:setAnchorPoint(cc.p(0,1))    
 --    rtx:setName("rtx")
 --    scrollH = rtx:getVirtualRendererSize().height + 30
 --    scrollH = scrollH > height and scrollH or height
 --    -- self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, scrollH))

	-- rtx:setPosition(self._scrollView:getContentSize().width/2+10,height/2+30)
	
	-- self._scrollView:addChild(rtx)	
	for i = 1,5 do
		local tagImg = ccui.ImageView:create()
		tagImg:setName("tagImg" .. i)
		tagImg:loadTexture("greenDragon_ruleTag.png",1)	    
	    tagImg:setAnchorPoint(cc.p(0.5,1))	
		self._scrollView:addChild(tagImg,1)

        local ruleTxt = ccui.Text:create()
	    ruleTxt:setName(UIUtils.ttfName)
	    ruleTxt:setFontSize(22)
	    ruleTxt:setString(lang("rankrule" .. i))
	    ruleTxt:setTextAreaSize(cc.size(570,itemH))
	    ruleTxt:setFontName(UIUtils.ttfName)
	    ruleTxt:setAnchorPoint(cc.p(0,1))
	    ruleTxt:setColor(cc.c4b(17,37,17,255))
	    -- ruleTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	    ruleTxt:setName("ruleTxt" .. i)
        self._scrollView:addChild(ruleTxt,1)
        
        local lineNum = ruleTxt:getVirtualRenderer():getStringNumLines()
	    local h = lineNum*22
	    height = height + h + 20  --20 行间距
	    ruleTxt.__height = h

	end
	height = height + 20
	local scrollH = height > 310 and height or 310
  	self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, scrollH))
	local txtH = scrollH - 20
	for i=1,5 do
		local ruleTxt = self._scrollView:getChildByName("ruleTxt" .. i)
		local tagImg = self._scrollView:getChildByName("tagImg" .. i)
		if ruleTxt then
		    tagImg:setPosition(20, txtH)
			ruleTxt:setPosition(35, txtH)
			txtH = txtH - ruleTxt.__height - 20
		end
	end

end

-- 接收自定义消息
function ACGreenDragonRuleLayer:reflashUI(data)

end

return ACGreenDragonRuleLayer