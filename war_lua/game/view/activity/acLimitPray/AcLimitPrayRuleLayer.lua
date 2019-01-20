--
-- Author: huangguofang
-- Date: 2018-08-07 15:13:05
--

-- 规则layer
local AcLimitPrayRuleLayer = class("AcLimitPrayRuleLayer",BaseLayer)
function AcLimitPrayRuleLayer:ctor(params)
    self.super.ctor(self)
    -- parent=self,UIInfo = self._info,openId=self._openId
    self._parent = params.parent
    self._UIInfo = params.UIInfo or {}
    self._openId = params.openId
    self._selfRank = params.selfRank or 0

    self._userModel = self._modelMgr:getModel("UserModel")
    self._limitPrayModel = self._modelMgr:getModel("LimitPrayModel")
end

-- 初始化UI后会调用, 有需要请覆盖
function AcLimitPrayRuleLayer:onInit()
	self._acData 	 = self._limitPrayModel:getDataById(self._openId)
	self._prayConfig = tab.prayConfig
 	local teamId = self._UIInfo.teamId or 0
 	-- print("=============teamId======",teamId)
    self._staticTeamData = tab:Team(teamId)

    -- self:registerClickEventByName("bg.closeBtn", function ()
    --     self:close()
    --     UIUtils:reloadLuaFile("arena.AcLimitPrayRuleLayer")
    -- end)

    self._scrollView = self:getUI("bg.scrollView")
    self._scrollView:setBounceEnabled(true)
    
    -- 当前排名
    local maxHeight = 0
	local rankDesTxt = ccui.Text:create()
    rankDesTxt:setString("当前排名：")
    rankDesTxt:setAnchorPoint(0,0.5)
    rankDesTxt:setFontSize(30)
    rankDesTxt:setFontName(UIUtils.ttfName)
    rankDesTxt:setColor(cc.c4b(255,255,255,255))
    rankDesTxt:enable2Color(1,cc.c4b(254,247,146,255))
    rankDesTxt:enableOutline(cc.c4b(79,28,61,255),2)
	self._scrollView:addChild(rankDesTxt)

    local currRankTxt = ccui.Text:create()
    currRankTxt:setString(self._selfRank)
    currRankTxt:setAnchorPoint(0,0.5)
    currRankTxt:setFontSize(30)
    currRankTxt:setFontName(UIUtils.ttfName)
    currRankTxt:setColor(cc.c4b(255,255,255,255))
    currRankTxt:enable2Color(1,cc.c4b(254,247,146,255))
    currRankTxt:enableOutline(cc.c4b(79,28,61,255),2)
	self._scrollView:addChild(currRankTxt)
    maxHeight = maxHeight + 70

    -- 当前排名奖励 des
    local currTxt = ccui.Text:create()
    currTxt:setString("当前排名奖励:")
    currTxt:setAnchorPoint(0,0.5)
    currTxt:setFontSize(22)
    currTxt:setFontName(UIUtils.ttfName)
    currTxt:setColor(cc.c4b(255,255,255,255))
    currTxt:enable2Color(1,cc.c4b(192,192,192,255))
	self._scrollView:addChild(currTxt)

	local noAwardTxt = ccui.Text:create()
    noAwardTxt:setString("暂无奖励")
    noAwardTxt:setAnchorPoint(0,0.5)
    noAwardTxt:setFontSize(22)
    noAwardTxt:setFontName(UIUtils.ttfName)
    noAwardTxt:setColor(cc.c4b(255,255,255,255))
    noAwardTxt:enable2Color(1,cc.c4b(192,192,192,255))
	self._scrollView:addChild(noAwardTxt)

	-- 當前排名獎勵
	local currAward = ccui.Layout:create()
    -- currAward:setBackGroundColorOpacity(255)
    -- currAward:setBackGroundColorType(1)
    -- currAward:setBackGroundColor(cc.c3b(0,0,0))
    currAward:setContentSize(200, 50)
    currAward:setTouchEnabled(true)
    self._scrollView:addChild(currAward)
    local awardD = self:getInRangeData(self._selfRank)
    if awardD.reward then
    	for k,v in pairs(awardD.reward) do
    		local itemId 
			local icon 
	    	if v[1] == "avatarFrame" then
				itemId = v[2]
				local frameData = tab:AvatarFrame(itemId)
		        param = {itemId = itemId, itemData = frameData}
		        icon = IconUtils:createHeadFrameIconById(param)
		        icon:setPosition((k-1)*45,2)
		        icon:setScale(0.36)
            elseif v[1] == "heroShadow" then
                itemId = v[2]
                local itemData = tab:HeroShadow(itemId)
                icon = IconUtils:createShadowIcon({itemData = itemData,eventStyle=1})
                icon.iconColor.nameLab:setVisible(false)
                local quality = itemData.avaQuality and (itemData.avaQuality + 3) or 1
                local color = UIUtils.colorTable["ccUIBaseColor"..quality]
                icon.iconColor.nameLab:setColor(color)
                icon:setScale(0.4)
                icon:setPosition((k-1)*45,2)
			else
				if v[1] == "tool" then
					itemId = v[2]
				else
					itemId = IconUtils.iconIdMap[v[1]]
				end
				local toolD = tab:Tool(tonumber(itemId))
				
				local toolData = tab:Tool(itemId)
				icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = v[3]})
				icon:setScale(0.4)
				icon:setPosition((k-1)*45,2)
			end

			icon:setSwallowTouches(false)
			icon:setAnchorPoint(0,0)
			
			currAward:addChild(icon)
    	end
    end
    currAward:setPosition(100, 100)
    maxHeight = maxHeight + 50 + 5

    if self._selfRank <= 0 then
		currRankTxt:setString("暂无排名")
		currAward:setVisible(false)
		noAwardTxt:setVisible(true)
	else
		currRankTxt:setString(self._selfRank)
		currAward:setVisible(true)
		noAwardTxt:setVisible(false)
    end

    -- 规则说明BG
    local ruleDesBg = ccui.ImageView:create()
    ruleDesBg:loadTexture("acLimitPray_rule_txtBg.png",1)
    ruleDesBg:setName("ruleDesBg")
    ruleDesBg:setPosition(0, 97)
    ruleDesBg:setAnchorPoint(0,0.5)
    self._scrollView:addChild(ruleDesBg)
    -- 规则说明des
    local ruleDesTxt = ccui.Text:create()
    ruleDesTxt:setString("活动规则说明")
    ruleDesTxt:setAnchorPoint(0,0.5)
    ruleDesTxt:setFontSize(20)
    ruleDesTxt:setFontName(UIUtils.ttfName)
    ruleDesTxt:setColor(cc.c4b(255,255,255,255))
    ruleDesTxt:enable2Color(1,cc.c4b(254,247,146,255))
    ruleDesTxt:enableOutline(cc.c4b(79,28,61,255),2)
    ruleDesTxt:setPosition(24, 13)
	ruleDesBg:addChild(ruleDesTxt)
	maxHeight = maxHeight + 30
	-- 规则富文本
	local rtxStr = lang("pray_rule")
    local rtx = RichTextFactory:create(rtxStr,560,0)
    rtx:setPixelNewline(true)
    rtx:formatText()
    rtx:setVerticalSpace(3)
    rtx:setAnchorPoint(cc.p(0,1))
    local w = rtx:getInnerSize().width
    local h = rtx:getVirtualRendererSize().height+30
    rtx:setName("rtx")
    self._scrollView:addChild(rtx)
    maxHeight = maxHeight+h

	-- 奖励Bg
    local awardDesBg = ccui.ImageView:create()
    awardDesBg:loadTexture("acLimitPray_rule_txtBg.png",1)
    awardDesBg:setName("awardDesBg")
    awardDesBg:setPosition(0, 80)
    awardDesBg:setAnchorPoint(0,0.5)
    self._scrollView:addChild(awardDesBg)
	-- 奖励des
    local awardDesTxt = ccui.Text:create()
    awardDesTxt:setString("结算奖励说明")
    awardDesTxt:setAnchorPoint(0,0.5)
    awardDesTxt:setFontSize(20)
    awardDesTxt:setFontName(UIUtils.ttfName)
    awardDesTxt:setColor(cc.c4b(255,255,255,255))
    awardDesTxt:enable2Color(1,cc.c4b(254,247,146,255))
    awardDesTxt:enableOutline(cc.c4b(79,28,61,255),2)
    awardDesTxt:setPosition(24, 13)
	awardDesBg:addChild(awardDesTxt)
	maxHeight = maxHeight + 30

	rtxStr = lang("pray_rule1")
    local acEndTime = self._limitPrayModel:getAcEndTime() 
    local rankEndTime = acEndTime - tab.prayConfig["rank"]["value"] * 3600
    local ranktimeStr = TimeUtils.getDateString(rankEndTime,"%d")
    rtxStr = string.gsub(rtxStr,"{$day}",tonumber(ranktimeStr))
    local awardRichTxt = RichTextFactory:create(rtxStr,560,0)
    awardRichTxt:setPixelNewline(true)
    awardRichTxt:formatText()
    awardRichTxt:setVerticalSpace(3)
    awardRichTxt:setAnchorPoint(cc.p(0,0))
    w = awardRichTxt:getInnerSize().width
    h = awardRichTxt:getVirtualRendererSize().height+30
    awardRichTxt:setName("awardRichTxt")
    self._scrollView:addChild(awardRichTxt)
    maxHeight = maxHeight+h

    -- 奖励展示
	local awardPanel = ccui.Layout:create()
    awardPanel:setBackGroundImage("acLimitPray_awardBgImg.png",1)
	awardPanel:setBackGroundImageScale9Enabled(true)
	awardPanel:setBackGroundImageCapInsets(cc.rect(25,25,1,1))   
    awardPanel:setTouchEnabled(true)
    awardPanel:setAnchorPoint(0,0)
    self._scrollView:addChild(awardPanel)

    local function createItem(data,i)
		local item = ccui.Layout:create()
		item:setAnchorPoint(0,0)
		-- item:setBackGroundColorOpacity(255)
   		-- item:setBackGroundColorType(1)
		item:setContentSize(540, 31)
	    item:setTouchEnabled(true)
	    item:setSwallowTouches(false)
		if not data then return  item end

		local itemBg = ccui.ImageView:create()
	    itemBg:loadTexture("acLimitPray_itemBg.png",1)
	    itemBg:setName("itemBg")
	    itemBg:setPosition(0, 0)
	    itemBg:setScaleX(2)
        itemBg:setScaleY(1.3)
	    itemBg:setAnchorPoint(0,0)
	    item:addChild(itemBg)
	    itemBg:setVisible(i%2~=0)    

		local subRank = data.rank[2] - data.rank[1]
		local rankStr = "第" ..data.rank[1].. "名"
		if subRank ~= 0 then
			rankStr = "第" .. data.rank[1] .. "~" .. data.rank[2] .. "名"
		end
	    --条件
	    local rankTxt = ccui.Text:create()
	    rankTxt:setFontSize(18)
	    rankTxt:setName("rankTxt")
	    rankTxt:setFontName(UIUtils.ttfName)
	    rankTxt:setAnchorPoint(0.5,0.5)
	    rankTxt:setPosition(80, 15)
	    rankTxt:setString(rankStr)
	    item:addChild(rankTxt,2)
	    rankTxt:setColor(cc.c4b(253,247,212,255))

	    local cutlineImg = ccui.ImageView:create()
	    cutlineImg:loadTexture("acLimitPray_rule_cutline.png",1)
	    cutlineImg:setName("cutlineImg")
	    cutlineImg:setPosition(160, 15)
	    cutlineImg:setScaleY(0.25)
	    item:addChild(cutlineImg,2)

	    for k,v in pairs(data.reward) do
	    	local itemId 
			local icon 
	    	if v[1] == "avatarFrame" then
                itemId = v[2]
                local frameData = tab:AvatarFrame(itemId)
                param = {itemId = itemId, itemData = frameData}
                icon = IconUtils:createHeadFrameIconById(param)
                icon:setPosition(220+(k-1)*45,0)
                icon:setScale(0.4)
            elseif v[1] == "heroShadow" then
                itemId = v[2]
                local itemData = tab:HeroShadow(itemId)
                icon = IconUtils:createShadowIcon({itemData = itemData,eventStyle=1})
                icon.iconColor.nameLab:setVisible(false)
                local quality = itemData.avaQuality and (itemData.avaQuality + 3) or 1
                local color = UIUtils.colorTable["ccUIBaseColor"..quality]
                icon.iconColor.nameLab:setColor(color)
                icon:setScale(0.4)
                icon:setPosition(220+(k-1)*45,0)
            else
                if v[1] == "tool" then
                    itemId = v[2]
                else
                    itemId = IconUtils.iconIdMap[v[1]]
                end
                local toolD = tab:Tool(tonumber(itemId))
                
                local toolData = tab:Tool(itemId)
                icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = v[3]})
                icon:setScale(0.4)
                icon:setPosition(220+(k-1)*45,0)
            end

			icon:setSwallowTouches(false)
			icon:setAnchorPoint(0,0)
			
			item:addChild(icon,2)
	    end

	    return item
	end
	local rankData = clone(tab.prayRank)
	table.sort(rankData,function(a,b)
		return a.id > b.id
	end)
	local posY= 0
	for i=1,#rankData do
		print("===========awardPanel==========",i)
		local item = createItem(rankData[i],i)
		item:setPosition(0, posY)
		posY = posY + 40
		awardPanel:addChild(item)
	end
	awardPanel:setContentSize(540, posY)
	maxHeight = maxHeight+posY

    self._scrollView:setInnerContainerSize(cc.size(scrollW,maxHeight))

    -- 设置位置
    local positionY = maxHeight - 40
    rankDesTxt:setPosition(20,positionY)
	currRankTxt:setPosition(160,positionY)
	currTxt:setPosition(20,positionY-rankDesTxt:getContentSize().height - 15)
	noAwardTxt:setPosition(165,positionY-rankDesTxt:getContentSize().height - 15)
	currAward:setPosition(165,positionY-rankDesTxt:getContentSize().height-35)

	local lineImg = ccui.ImageView:create()
    lineImg:loadTexture("acLimitPray_rule_cutline.png",1)
    lineImg:setName("lineImg")
    lineImg:setAnchorPoint(0.5,0.5)
    lineImg:setScaleY(3.5)
    lineImg:setRotation(90)
    lineImg:setPosition(311, currTxt:getPositionY()-30)
    self._scrollView:addChild(lineImg)

	ruleDesBg:setPosition(20,lineImg:getPositionY()-25)
	rtx:setPosition(-240,ruleDesBg:getPositionY()-ruleDesBg:getContentSize().height*0.5-10)

	awardDesBg:setPosition(20,posY+55)

	lineImg = ccui.ImageView:create()
    lineImg:loadTexture("acLimitPray_rule_cutline.png",1)
    lineImg:setName("lineImg")
    lineImg:setAnchorPoint(0.5,0.5)
    lineImg:setScaleY(3.5)
    lineImg:setRotation(90)
    lineImg:setPosition(311, awardDesBg:getPositionY()+awardDesBg:getContentSize().height*0.5+10)
    self._scrollView:addChild(lineImg)

	awardRichTxt:setPosition(-240,posY+15)
	awardPanel:setPosition(41,10)
end

-- 接收自定义消息
function AcLimitPrayRuleLayer:reflashUI(data)
	print("===================reflashUI=================")
end

function AcLimitPrayRuleLayer:getInRangeData( rank )
    if not rank or rank > 1000 then
        rank = 1000
    end
    if rank == 0 then
    	return {}
    end
    local prayRank = tab["prayRank"]
    for i,awardD in ipairs(prayRank) do
        local low,high = awardD.rank[1],awardD.rank[2]
        if rank >= low and rank <= high then
            return awardD
        end
    end

    return {}
end


return AcLimitPrayRuleLayer