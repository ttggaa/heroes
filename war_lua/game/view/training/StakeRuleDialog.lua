--
-- Author: huangguofang
-- Date: 2018-04-28 14:23:52
--
-- 
local StakeRuleDialog = class("StakeRuleDialog", BasePopView)

function StakeRuleDialog:ctor(params)
    StakeRuleDialog.super.ctor(self)
    self._stakeNum = params.stakeNum or 1   

end

function StakeRuleDialog:onInit()

    self:registerClickEventByName("bg.closeBtn", function()
        self:close()
        UIUtils:reloadLuaFile("training.StakeRuleDialog")
    end)

    local viewtype = self._viewType
    self._scrollView = self:getUI("bg.scrollView")
    self._scrollView:setBounceEnabled(true)
    self._title = self:getUI("bg.headBg.title")
    self._title:setString("规则说明")
    UIUtils:setTitleFormat(self._title, 6)
    self._scrollBg = self:getUI("bg.scrollView.scrollBg")
    -- self._ruleBg = self:getUI("bg.scrollView.ruleBg")
    self._rankCell = self:getUI("bg.rankCell")
    -- self._titleBg = self:getUI("bg.scrollView.titlebg") 
    self._rankCell:setVisible(false)

    local maxHeight = 20
    local scrollW = self._scrollView:getInnerContainerSize().width

    -- 增加抬头
    local des1 = ccui.Text:create()
    des1:setFontSize(24)
    des1:setFontName(UIUtils.ttfName)
    des1:setString("本周热点")--lang())
    des1:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    des1:setAnchorPoint(cc.p(0,0))
    maxHeight=maxHeight+des1:getContentSize().height
    self._scrollView:addChild(des1)

    -- 三个热点英雄 返回长度
    -- print("==========self._stakeNum===",self._stakeNum)
    local stakeHeroTb = tab:StakeHero(self._stakeNum)
    hotHero = stakeHeroTb.hotHero
    local count = #hotHero
    local nameStr = ""
    for k,v in pairs(hotHero) do
    	local heroData = tab:Hero(tonumber(v))
    	nameStr = nameStr .. lang(heroData.heroname)
    	if k ~= count then
    		nameStr = nameStr .. "、"
    	end
    end
    local nameTxt = ccui.Text:create()
    nameTxt:setFontSize(20)
    nameTxt:setFontName(UIUtils.ttfName)
    nameTxt:setString(nameStr)
    nameTxt:setAnchorPoint(0,0.5)
    nameTxt:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
 	maxHeight=maxHeight+nameTxt:getContentSize().height
    self._scrollView:addChild(nameTxt)

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
    local str = lang("STAKE_TIPS")
    if not string.find(str,"[-]") then
    	str = "[color=000000]"..str.."[-]"
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

    -- 战斗结算奖励 title
    local des3 = ccui.Text:create()
    des3:setFontSize(24)
    des3:setFontName(UIUtils.ttfName)
    des3:setString("战斗结算奖励")
    des3:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    des3:setAnchorPoint(cc.p(0,0))
    maxHeight=maxHeight+des3:getContentSize().height+5
    self._scrollView:addChild(des3)


    -- 奖励提示富文本
	local rtx1 = RichTextFactory:create(lang("STAKE_RANK_TIPS"),380,height)
    rtx1:setPixelNewline(true)
    rtx1:formatText()
    rtx1:setVerticalSpace(3)
    rtx1:setAnchorPoint(cc.p(0,0))
    local w1 = rtx1:getInnerSize().width
    local h1 = rtx1:getVirtualRendererSize().height+30
    rtx1:setName("rtx1")
    self._scrollView:addChild(rtx1)
    maxHeight = maxHeight+h1
   
   	-- 奖励列表
    local scrollBgH = self:initRewardList() 
    maxHeight = maxHeight+scrollBgH
    self._scrollView:setInnerContainerSize(cc.size(scrollW,maxHeight))
    
    self._scrollBg:setPosition(cc.p(5,0))

    des1:setPosition(cc.p(10,maxHeight-45))
    nameTxt:setPosition(cc.p(30,maxHeight-70))
    des2:setPosition(cc.p(10,scrollBgH+h+h1))
    rtx:setPosition(cc.p(-w* 0.5+30,scrollBgH+h1+20))
    des3:setPosition(cc.p(10,scrollBgH+h1-25))
    rtx1:setPosition(cc.p(-w* 0.5+30,scrollBgH))

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
function StakeRuleDialog:initRewardList()
    local itemH,itemW = self._rankCell:getContentSize().height,self._rankCell:getContentSize().width
    local stakeTb = clone(tab.stakeReward)
    table.sort(stakeTb,function(a,b)
    	return a.id > b.id
    end)
    local bgHeight = (#stakeTb)*itemH
    local itemCell = self._rankCell

    for i,rankD in ipairs(stakeTb) do
        local item = self._rankCell:clone()
        item:setVisible(true)
        item:setPosition(cc.p(-20,itemH*(i-1)-3))
        if i%2 ~= 1 then
            item:getVirtualRenderer():setVisible(false)
        end

        local rankRange = item:getChildByFullName("rankRange")
        rankRange:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        local pos = rankD.pos
        local rewards = rankD.reward
        local rankStr = "第" .. getRange(pos[1],pos[2]) .. "名"      
        rankRange:setString(rankStr)
        local posX = 254
        for k,v in pairs(rewards) do
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
            local diamondImg = item:getChildByFullName("diamondImg")
            diamondImg:setVisible(false)
            icon:setPosition(posX,0)
            item:addChild(icon)
            local diamondNum = item:getChildByFullName("diamondNum")
            diamondNum:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
            diamondNum:setString(reward[3] or 0)
            diamondNum:setPositionX(posX+icon:getContentSize().width*0.4+5)

            posX = posX+icon:getContentSize().width*0.4+20
        end
	  	
       
        self._scrollBg:addChild(item)   
    end

    -- 顶部描述
    -- local rtxStr = "[color=3d1f00,outlinecolor = 241b1200,outlinesize = 2]矮人宝屋每日[color=c6b46a,outlinecolor = 241b1200,outlinesize = 2]5:00[-]结算奖励，奖励将通过邮件发放。[-]"
    self._scrollBg:setContentSize(cc.size(itemW,bgHeight - 2))
    self._scrollBg:setBackGroundImageCapInsets(cc.rect(217,30,1,1))

    return bgHeight
end

function StakeRuleDialog.dtor()
    stringTable = nil
end

return StakeRuleDialog