--[[
    Filename:    GodWarRuleDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-05-04 21:41:27
    Description: File description
--]]

-- 规则
local GodWarRuleDialog = class("GodWarRuleDialog",BasePopView)
function GodWarRuleDialog:ctor()
    GodWarRuleDialog.super.ctor(self)

end

-- 初始化UI后会调用, 有需要请覆盖
function GodWarRuleDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("godwar.GodWarRuleDialog")
    end)

    self._scrollView = self:getUI("bg.scrollView")
    self._scrollView:setBounceEnabled(true)

    self._title = self:getUI("bg.headBg.title")
    self._title:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._title,6)

    self._roleNode = self:getUI("bg.roleNode")
    self._roleNode:setVisible(true)
    
    local dialogLabel = cc.Label:createWithTTF("领主大人，还有什么不明白吗？", UIUtils.ttfName_Title, 20)
    dialogLabel:setMaxLineWidth(145)
    dialogLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    dialogLabel:setLineHeight(30)
    dialogLabel:setPosition(279, 117)
    self._roleNode:addChild(dialogLabel)

    local detailBtn = self._roleNode:getChildByFullName("detailBtn")
    detailBtn:setTitleFontSize(22)
    self:registerClickEvent(detailBtn, function ()
        self._viewMgr:showDialog("godwar.GodWarShowTuDialog", {}, true)
    end)

    self._rankCell = self:getUI("bg.rankCell")

    self._rankCell:setVisible(false)
    -- 文字原型
    self._textPro = ccui.Text:create()
    self._textPro:setString("")
    self._textPro:setAnchorPoint(0,1)
    self._textPro:setPosition(0,0)
    self._textPro:setFontSize(22)
    self._textPro:setFontName(UIUtils.ttfName)
    self._textPro:setTextColor(cc.c4b(255,110,59,255))

    local maxHeight = 0

    local scrollBgH = self:generateRanks()
    maxHeight = maxHeight+scrollBgH

    local scrollW = self._scrollView:getInnerContainerSize().width
    -- 增加抬头
    -- local des1 = self._textPro:clone()
    -- des1:setString("胜场奖励")
    -- des1:setFontSize(24)
    -- des1:setFontName(UIUtils.ttfName)
    -- des1:setTextColor(cc.c4b(130,85,40,255))
    -- des1:setAnchorPoint(0,0)
    -- des1:setPosition(3, maxHeight + 15)
    -- self._scrollView:addChild(des1)
    -- maxHeight=maxHeight+des1:getContentSize().height+15

    -- 增加富文本
    local rtxStr = lang("RULE_GODWAR")  --lang("RULE_ARENA")
    rtxStr = string.gsub(rtxStr,"ffffff","462800")
    local rtx = RichTextFactory:create(rtxStr,418,0)
    rtx:setPixelNewline(true)
    rtx:formatText()
    rtx:setVerticalSpace(3)
    rtx:setAnchorPoint(cc.p(0,0))
    local w = rtx:getInnerSize().width
    local h = rtx:getVirtualRendererSize().height
    rtx:setName("rtx")
    rtx:setPosition(-w* 0.5+10,maxHeight + 30)
    self._scrollView:addChild(rtx)
    maxHeight = maxHeight+h +30

    -- local des2 = self._textPro:clone()
    -- des2:setString("基本规则")
    -- des2:setFontName(UIUtils.ttfName)
    -- des2:setFontSize(24)
    -- des2:setAnchorPoint(0,0)
    -- des2:setTextColor(cc.c4b(130,85,40,255))
    -- des2:setPosition(3, maxHeight + 10)
    -- self._scrollView:addChild(des2)
    -- maxHeight=maxHeight+des2:getContentSize().height + 10

    self._roleNode:removeFromParent()
    self._roleNode:setPosition(0, maxHeight + 10)
    self._scrollView:addChild(self._roleNode)
    maxHeight = maxHeight + self._roleNode:getContentSize().height + 10

    self._scrollView:setInnerContainerSize(cc.size(scrollW,maxHeight))
    
end

function GodWarRuleDialog:generateRanks()
    local itemH,itemW = self._rankCell:getContentSize().height,self._rankCell:getContentSize().width
    local godWarAwardTab = tab.godWarRank

    local godWarAwardTab = {} 
    for k, v in pairs(tab.godWarRank) do
        table.insert(godWarAwardTab, v)
    end
    table.sort(godWarAwardTab, function(a,b)
        return a.id > b.id
    end)
    dump(godWarAwardTab)
    local bgHeight = (#godWarAwardTab)*itemH
    for tabI = 1, #godWarAwardTab do
        local item = self._rankCell:clone()
        item:setVisible(true)
        item:setOpacity(155)
        item:setPosition(cc.p(-25,itemH*(tabI-1)-3))
        if tabI%2 == 1 then
            item:getVirtualRenderer():setVisible(false)
        end
        ---[[ 用数据初始化item
        local rankRange = item:getChildByFullName("rankRange")

        local rankStr = lang(godWarAwardTab[tabI].rankDes) -- godWarAwardTab[tabI].id .. "排名奖励"
        rankRange:setString(rankStr)

        local infoStartPos = 160
        local rewardSpace = 100
        local rewardData = godWarAwardTab[tabI]["award"]
        for i = 1, #rewardData do
            local cData = rewardData[i]

            local icon = nil
            local iconWidth = 30
            if cData[1] == "tool" then
                local iconPath = tab:Tool(cData[2]).art
                icon = cc.Sprite:createWithSpriteFrameName(iconPath .. ".png")
            else
                local iconPath = IconUtils.resImgMap[cData[1]]

                if iconPath == nil then
                    local itemId = tonumber(IconUtils.iconIdMap[cData[1]])
                    local toolD = tab:Tool(itemId)
                    iconPath = IconUtils.iconPath .. toolD.art .. ".png"
                    icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD})
                end
                icon = cc.Sprite:createWithSpriteFrameName(iconPath)
            end
            icon:setScale(iconWidth / icon:getContentSize().width)
            if i == 2 then
                rewardSpace = rewardSpace+10
            else
                rewardSpace = rewardSpace-10
            end
            icon:setPosition(infoStartPos + (i - 1)*rewardSpace, 17)
            item:addChild(icon)

            local countTxt = tostring(cData[3])
            local rewardCount = cc.Label:createWithTTF("x" .. countTxt, UIUtils.ttfName, 20) 
            rewardCount:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            rewardCount:setPosition(infoStartPos + (i - 1)*rewardSpace + rewardCount:getContentSize().width*0.5 + 22, 17)
            item:addChild(rewardCount)
        end

        self._scrollView:addChild(item)
    end
    -- 顶部描述
    -- local rtxStr = lang("HERODUEL_RULE2")
    -- local topDes = RichTextFactory:create(rtxStr,418, 0)
    -- topDes:formatText()
    -- topDes:setVerticalSpace(3)
    -- topDes:setAnchorPoint(cc.p(0,0))
    -- local w = topDes:getInnerSize().width
    -- local h = topDes:getVirtualRendererSize().height
    -- topDes:setName("topDes")
    -- topDes:setPosition(cc.p(-w*0.5+5,bgHeight + 10))
    -- self._scrollView:addChild(topDes)
    -- bgHeight = bgHeight+h
    -- self._scrollView:setBackGroundImageCapInsets(cc.rect(217,30,1,1))
    bgHeight = bgHeight - 20
    return bgHeight
end

return GodWarRuleDialog