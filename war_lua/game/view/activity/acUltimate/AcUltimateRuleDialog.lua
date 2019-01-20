--
-- Author: huangguofang
-- Date: 2018-05-09 15:36:27
--
local AcUltimateRuleDialog = class("AcUltimateRuleDialog", BasePopView)

function AcUltimateRuleDialog:ctor(params)
    AcUltimateRuleDialog.super.ctor(self)
    self._acId = params.acId
    self._acData = params.acData or {}
    self.rank = 0    
end

function AcUltimateRuleDialog:onInit()

    self:registerClickEventByName("bg.closeBtn", function()
        self:close()
        UIUtils:reloadLuaFile("activity.acUltimate.AcUltimateRuleDialog")
    end)

    local viewtype = self._viewType
    self._scrollView = self:getUI("bg.scrollView")
    self._scrollView:setBounceEnabled(true)
    self._title = self:getUI("bg.headBg.title")
    self._title:setString("规则说明")
    UIUtils:setTitleFormat(self._title, 6)
    self._scrollBg = self:getUI("bg.scrollView.scrollBg")
    self._rankCell = self:getUI("bg.rankCell")
    self._rankCell:setVisible(false)

    local maxHeight = 0
    local scrollW = self._scrollView:getInnerContainerSize().width

	-- 基础规则 title
    local des2 = ccui.Text:create()
    des2:setFontSize(24)
    des2:setFontName(UIUtils.ttfName)
    des2:setString("基础规则")
    des2:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    des2:setAnchorPoint(cc.p(0,0))
    maxHeight=maxHeight+des2:getContentSize().height+5
    self._scrollView:addChild(des2)

    -- 增加富文本基本规则
    local str = lang("zjjl_Rule")
    if not string.find(str,"[-]") then
    	str = "[color=000000]"..str.."[-]"
    end
    local numD = self._acData.number or {}
    for i=1,#numD do
        str = string.gsub(str,"{$num"..i.."}" ,numD[i])
    end
	local rtx = RichTextFactory:create(str,380,height)
    rtx:setPixelNewline(true)
    rtx:formatText()
    rtx:setVerticalSpace(3)
    rtx:setAnchorPoint(cc.p(0,0))
    local w = rtx:getInnerSize().width
    local h = rtx:getVirtualRendererSize().height+30
    rtx:setName("rtx")
    self._scrollView:addChild(rtx)
    maxHeight = maxHeight+h

    -- 排行奖励 title
    local des3 = ccui.Text:create()
    des3:setFontSize(24)
    des3:setFontName(UIUtils.ttfName)
    des3:setString("排行奖励")
    des3:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    des3:setAnchorPoint(cc.p(0,0))
    maxHeight=maxHeight+des3:getContentSize().height+5
    self._scrollView:addChild(des3)
   
   	-- 奖励列表
    local scrollBgH = self:initRewardList() 
    maxHeight = maxHeight+scrollBgH
    self._scrollView:setInnerContainerSize(cc.size(scrollW,maxHeight))
    
    self._scrollBg:setPosition(cc.p(5,0))

    des2:setPosition(cc.p(30,scrollBgH+h+30))
    rtx:setPosition(cc.p(-w* 0.5+30,scrollBgH+50))
    des3:setPosition(cc.p(30,scrollBgH+10))

end

local function getRange( num1,num2 )
    if num1 == num2 then
        return num1
    elseif num1 > num2 then
        return num2 .. "-" .. num1
    elseif num1 < num2 then
        return num1 .. "-" .. num2
    end

end
function AcUltimateRuleDialog:initRewardList()
    local itemH,itemW = self._rankCell:getContentSize().height,self._rankCell:getContentSize().width
    local tableD = tab["guildReward" .. self._acId]
    local stakeTb = {}
    if tableD then
		stakeTb = clone(tab.guildReward50001)
	    table.sort(stakeTb,function(a,b)
	    	return a.id > b.id
	    end)
	end
	self._rankCell:setTouchEnabled(true)
	self._rankCell:setSwallowTouches(false)
    local bgHeight = (#stakeTb)*itemH
    for i,rankD in ipairs(stakeTb) do
        local item = self._rankCell:clone()
        item:setVisible(true)
        item:setPosition(cc.p(-20,itemH*(i-1)+5))
        if i%2 == 1 then
            item:setOpacity(0)
        end
        item:setTouchEnabled(true)
        item:setSwallowTouches(false)
        local rankRange = item:getChildByFullName("rankRange")
        rankRange:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        local pos = rankD.rank
        local rewardD = rankD.reward
        local rankStr = "联盟排名第" .. getRange(pos[1],pos[2]) .. "名并且总信物量超过" .. (rankD.jifen or 0)      
        rankRange:setString(rankStr)
        local posX = 63
        for k,v in pairs(rewardD) do
        	local reward = v
        	local icon
			local toolD
		  	local itemId = reward[2]
	    	if reward[1] == "tool"then
	            local toolD = tab:Tool(tonumber(itemId))
	            icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = reward[3],eventStyle = 0})
	            icon:setScale(0.4)
	        else
	        	itemId = IconUtils.iconIdMap[reward[1]]
	        	toolD = tab:Tool(tonumber(itemId))
	            icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = reward[3],eventStyle = 0})
	            icon:setScale(0.4)
	        end
	 		local boxIcon = icon.boxIcon
	        local iconColor = icon.iconColor
	        if boxIcon then
	            boxIcon:setVisible(false)
	        end
	        if iconColor then
	            iconColor:setVisible(false)
	        end
	        icon:setPosition(posX,1)
	        item:addChild(icon)
	        local numTxt = ccui.Text:create()
	        numTxt:setFontSize(20)
	        numTxt:setFontName(UIUtils.ttfName)
	        numTxt:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	        numTxt:setString(reward[3] or 0)
	        numTxt:setAnchorPoint(0,0.5)
	        numTxt:setPosition(posX+icon:getContentSize().width*0.4+5,18)
	        item:addChild(numTxt)
	        posX = posX + 90
        end
       
        self._scrollBg:addChild(item)   
    end

    -- 顶部描述
    -- local rtxStr = "[color=3d1f00,outlinecolor = 241b1200,outlinesize = 2]矮人宝屋每日[color=c6b46a,outlinecolor = 241b1200,outlinesize = 2]5:00[-]结算奖励，奖励将通过邮件发放。[-]"
    self._scrollBg:setContentSize(cc.size(itemW,bgHeight - 2))
    self._scrollBg:setBackGroundImageCapInsets(cc.rect(217,30,1,1))

    return bgHeight
end

function AcUltimateRuleDialog.dtor()
    stringTable = nil
end

return AcUltimateRuleDialog