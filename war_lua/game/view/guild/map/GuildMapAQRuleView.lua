--[[
    Filename:    GuildMapAQRuleView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-7-06 19:17:10
    Description: 斯芬克斯谜题 规则界面
--]]

local GuildMapAQRuleView = class("GuildMapAQRuleView",BasePopView)

function GuildMapAQRuleView:ctor(param)
    self.super.ctor(self)
    self._arenaModel = self._modelMgr:getModel("ArenaModel")
    self._rankModel = self._modelMgr:getModel("RankModel")

    self._rankType = param.curType
    if param.curType == 20 then
        self._sysData = tab.sphinxPersonRank
    else
        self._sysData = tab.sphinxGuildRank
    end
end

-- 初始化UI后会调用, 有需要请覆盖
function GuildMapAQRuleView:onInit()
	self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("guild.map.GuildMapAQRuleView")
    end)

    self._scrollView = self:getUI("bg.scrollView")
    self._scrollView:setBounceEnabled(true)

    self._title = self:getUI("bg.headBg.title")
    self._title:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._title,6)

    self._scrollBg = self:getUI("bg.scrollView.scrollBg")
    self._ruleBg = self:getUI("bg.scrollView.ruleBg")
    self._rankCell = self:getUI("bg.rankCell")
    self._rankCell:setVisible(false)
    self._des1Bg = self:getUI("bg.scrollView.des1Bg")

    local tip2 = self._des1Bg:getChildByFullName("tip2")
    self:createRewards(tip2)
    for i=1,3 do
        local rwdIcon = self:getUI("bg.scrollView.des1Bg.tip2.rwd" .. i)
        local rwdNum = self:getUI("bg.scrollView.des1Bg.tip2.rwdNum" .. i)
        rwdNum:setPositionX(rwdIcon:getPositionX() + 15) 
    end

    -- 文字原型
    self._textPro = ccui.Text:create()
    self._textPro:setString("")
    self._textPro:setAnchorPoint(cc.p(0,1))
    self._textPro:setPosition(cc.p(0,0))
    self._textPro:setFontSize(22)
    self._textPro:setFontName(UIUtils.ttfName)
    self._textPro:setTextColor(cc.c4b(255,110,59,255))

    local currRankTxt = self:getUI("bg.scrollView.des1Bg.des1")
    currRankTxt:setFontName(UIUtils.ttfName)

    local txtdes3 = self:getUI("bg.scrollView.des1Bg.des3")
    txtdes3:setFontName(UIUtils.ttfName)

    local txtrank = self:getUI("bg.scrollView.des1Bg.rank")
    txtrank:setFontName(UIUtils.ttfName)
    txtrank:setColor(UIUtils.colorTable.ccUIBaseColor9)
    txtrank:setPositionX(currRankTxt:getPositionX() + currRankTxt:getContentSize().width + 2)

    local maxHeight = 0 
    maxHeight = maxHeight+self._des1Bg:getContentSize().height
    local scrollW = self._scrollView:getInnerContainerSize().width

    -- 增加抬头
    local des1 = self._textPro:clone()
    des1:setString("斯芬克斯结算奖励")
    des1:setFontSize(24)
    des1:setFontName(UIUtils.ttfName)
    des1:setTextColor(UIUtils.colorTable.ccUIBaseTextColor2)
    des1:setAnchorPoint(cc.p(0,0))
    maxHeight=maxHeight+des1:getContentSize().height+5
    self._scrollView:addChild(des1)

    maxHeight = maxHeight + 20

    -- 增加富文本
	local rtxStr = lang("SPHINX_RULE")
	local rtx = RichTextFactory:create(rtxStr,418,height)
    rtx:setPixelNewline(true)
    rtx:formatText()
    rtx:setVerticalSpace(3)
    rtx:setAnchorPoint(cc.p(0,0))
    local w = rtx:getInnerSize().width
    local h = rtx:getVirtualRendererSize().height+30
    rtx:setName("rtx")
    self._scrollView:addChild(rtx)
    maxHeight = maxHeight+h

    local scrollBgH = self:generateRanks()
    maxHeight = maxHeight+scrollBgH

    self._scrollView:setInnerContainerSize(cc.size(scrollW,maxHeight))
    
    self._scrollBg:setPosition(cc.p(5,0))
    self._des1Bg:setPosition(cc.p(0,maxHeight-self._des1Bg:getContentSize().height+5))

    des1:setPosition(cc.p(10,scrollBgH))

    rtx:setPosition(cc.p(-w* 0.5+10, scrollBgH+des1:getContentSize().height + 28))
    self._ruleBg:setContentSize(cc.size(447,h))
    self._ruleBg:setPosition(-5,scrollBgH+des1:getContentSize().height+15)

    self:reflashTitleInfo()
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

function GuildMapAQRuleView:getInRangeData( rank )
    if self._sysData == nil or next(self._sysData) == nil then
        return {}
    end

    if rank > 10000 then
        rank = 10000
    end

    for i,honorD in ipairs(self._sysData) do
        local low,high = honorD.rank[1], honorD.rank[2]
        if rank >= low and rank <= high then
            return honorD
        end
    end
end

function GuildMapAQRuleView:reflashTitleInfo()
    local arenaD = self._modelMgr:getModel("ArenaModel"):getData()

    local rank = self._des1Bg:getChildByFullName("rank")
    local tip2 = self._des1Bg:getChildByFullName("tip2")
    local noRwd = self._des1Bg:getChildByFullName("noRwd")
    tip2:setVisible(false)
    noRwd:setVisible(false)

    local upperNum = self._sysData[#self._sysData]["rank"][2]
    local rankData = self._rankModel:getSelfRankInfo(self._rankType)
    local ranknum = math.min(rankData.rank or 10000, 10000)

    if not ranknum or ranknum > upperNum or ranknum == 0 or ranknum == "" then
        noRwd:setVisible(true)
        rank:setString("无")
        rank:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    else
        rank:setString(ranknum)
        rank:setColor(UIUtils.colorTable.ccUIBaseColor9)
        tip2:setVisible(true)
    end

    local honorD = self:getInRangeData(ranknum)
    if honorD then
        self:createRewards(tip2, honorD["reward"])
    end
end

function GuildMapAQRuleView:generateRanks()
    local itemH,itemW = self._rankCell:getContentSize().height,self._rankCell:getContentSize().width
    local bgHeight = (#self._sysData)*itemH

    for i,rankD in ipairs(self._sysData) do
        local item = self._rankCell:clone()
        item:setVisible(true)

        item:setPosition(cc.p(-25, itemH*(#self._sysData - i) - 3))

        if i%2 == 1 then
            item:getVirtualRenderer():setVisible(false)
        end

        --rank
        local pos = rankD.rank
        local rankStr = "第" .. getRange(pos[1], pos[2]) .. "名"
        local rankRange = item:getChildByFullName("rankRange")
        rankRange:setString(rankStr)

        --rwd
        self:createRewards(item, rankD["reward"])

        self._scrollBg:addChild(item)
    end

    -- 顶部描述
    local topDes = RichTextFactory:create(lang("SPHINX_RULE2"), 418, height)
    topDes:formatText()
    topDes:setVerticalSpace(3)
    topDes:setAnchorPoint(cc.p(0,0))
    local w = topDes:getInnerSize().width
    local h = topDes:getVirtualRendererSize().height
    topDes:setName("topDes")
    topDes:setPosition(cc.p(-w * 0.5 + 5, bgHeight))
    self._scrollBg:addChild(topDes)

    bgHeight = bgHeight + h
    self._scrollBg:setContentSize(cc.size(itemW, bgHeight - 2))
    self._scrollBg:setBackGroundImageCapInsets(cc.rect(217, 30, 1, 1))
    return bgHeight
end

function GuildMapAQRuleView:createRewards(inObj, inRwas)
    if inObj == nil or inRwas == nil then
        return
    end

    for i = 1, 3 do
        local rwd = inObj:getChildByFullName("rwd" .. i)
        local rwdNum = inObj:getChildByFullName("rwdNum" .. i)
        rwd:setVisible(true)
        rwd:removeAllChildren()
        rwdNum:setVisible(true)

        if inRwas[i] == nil then
            rwd:setVisible(false)
            rwdNum:setVisible(false)
            break
        end

        rwdNum:setString(inRwas[i][3])

        local itemId
        if inRwas[i][1] == "avatarFrame" then
            local itemId = inRwas[i][2]
            local itemNum = inRwas[i][3]
            local itemData = tab:AvatarFrame(itemId)
            local rwdIcon = IconUtils:createHeadFrameIconById({itemId = itemId, itemData = itemData})
            rwdIcon:setAnchorPoint(cc.p(0.5, 0.5))
            rwdIcon:setPosition(0, 0)
            rwdIcon:setScale(0.42)
            rwd:addChild(rwdIcon)
        else
            local itemId
            if inRwas[i][1] == "tool" then
                itemId = inRwas[i][2]
            else
                itemId = IconUtils.iconIdMap[inRwas[i][1]]
            end

            local param = {itemId = itemId, eventStyle = 4, swallowTouches = true}
            local rwdIcon = IconUtils:createItemIconById(param)
            rwdIcon:setAnchorPoint(cc.p(0.5, 0.5))
            rwdIcon:setPosition(0, 0)
            rwdIcon:setScale(0.5)
            rwd:addChild(rwdIcon)
        end 
    end
end

return GuildMapAQRuleView