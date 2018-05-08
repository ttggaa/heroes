--[[
    Filename:    CrossScoreRuleView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-12-05 10:30:34
    Description: File description
--]]


local CrossScoreRuleView = class("CrossScoreRuleView",BasePopView)
function CrossScoreRuleView:ctor()
    self.super.ctor(self)

end

-- 初始化UI后会调用, 有需要请覆盖
function CrossScoreRuleView:onInit()
    self._crossModel = self._modelMgr:getModel("CrossModel")
    

    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("cross.CrossScoreRuleView")
    end)

    self._scrollView = self:getUI("bg.scrollView")
    self._scrollView:setBounceEnabled(true)
    self._des1Bg = self:getUI("bg.scrollView.des1Bg")
    self._title = self:getUI("bg.headBg.title")
    self._title:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._title,6)
    self._scrollBg = self:getUI("bg.scrollView.scrollBg")
    self._ruleBg = self:getUI("bg.scrollView.ruleBg")
    self._rankCell = self:getUI("bg.rankCell")

    self._rankCell:setVisible(false)
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

    local maxHeight = 0 --self._scrollView:getInnerContainerSize().height
    -- maxHeight = maxHeight+self._title:getContentSize().height
    -- maxHeight = maxHeight+self._des1Bg:getContentSize().height
    local scrollW = self._scrollView:getInnerContainerSize().width
    -- 增加抬头
    local des1 = self._textPro:clone()
    des1:setString("积分增长")
    des1:setFontSize(24)
    des1:setFontName(UIUtils.ttfName)
    des1:setTextColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- des1:setOpacity(200)
    des1:setAnchorPoint(cc.p(0,0))
    maxHeight=maxHeight+des1:getContentSize().height+5
    self._scrollView:addChild(des1)

    -- local des2 = self._textPro:clone()
    -- des2:setString("竞技场战斗规则")
    -- des2:setFontName(UIUtils.ttfName)
    -- des2:setFontSize(24)
    -- des2:setTextColor(UIUtils.colorTable.ccUIBaseTextColor2)

    -- -- des2:setOpacity(200)
    -- maxHeight=maxHeight+des2:getContentSize().height+20
    -- self._scrollView:addChild(des2)

    -- 增加富文本
    local rtxStr = lang("cp_score_rule")  --lang("RULE_ARENA")
    -- rtxStr = string.gsub(rtxStr,"ffffff","462800")
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

    self._ruleBg:setContentSize(cc.size(447,h))

    local scrollBgH = self:generateRanks()
    maxHeight = maxHeight+scrollBgH

    self._scrollView:setInnerContainerSize(cc.size(scrollW,maxHeight))
    
    self._scrollBg:setPosition(cc.p(5,0))
    -- self._title:setPositionY(maxHeight-self._title:getContentSize().height/2)
    self._des1Bg:setPosition(cc.p(0,maxHeight-self._des1Bg:getContentSize().height+5))

    des1:setPosition(cc.p(10,scrollBgH))
    -- des2:setPosition(cc.p(10,maxHeight-self._des1Bg:getContentSize().height-15))

    rtx:setPosition(cc.p(-w* 0.5+10,scrollBgH+des1:getContentSize().height+28))
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

function CrossScoreRuleView:getInRangeData( rank )
    if rank > 10000 then
        rank = 10000
    end
    local arenaHonor = tab["arenaHonor"]
    for i,honorD in ipairs(arenaHonor) do
        local low,high = honorD.pos[1],honorD.pos[2]
        if rank >= low and rank <= high then
            return honorD
        end
    end
end

function CrossScoreRuleView:reflashTitleInfo()
    local arenaData = self._crossModel:getOpenArenaData()
    dump(arenaData)
    -- local state = self._crossModel:getOpenState()

    local arenaName = self:getUI("bg.scrollView.des1Bg.des3")
    local nameStr = ""
    local tnum = 1
    for i,v in pairs(arenaData) do
        if tnum == 3 then
            nameStr = nameStr .. lang("cp_npcRegion" .. i)
        else
            nameStr = nameStr .. lang("cp_npcRegion" .. i) .. "、"
        end
        tnum = tnum + 1
    end
    arenaName:setString(nameStr)

end

function CrossScoreRuleView:generateRanks()
    local itemH,itemW = self._rankCell:getContentSize().height,self._rankCell:getContentSize().width
    local arenaHonor = clone(tab["cpServerScore"])
    local arenaData = self._crossModel:getData()
    local bgHeight = (#arenaHonor)*itemH
    for i,rankD in ipairs(arenaHonor) do
        local item = self._rankCell:clone()
        item:setVisible(true)
        item:setPosition(0,itemH*(i-1))
        
        local rankCell = item:getChildByFullName("rankCell")
        if i%2 == 1 then
            rankCell:setVisible(false)
        end
        ---[[ 用数据初始化item
        local rankRange = item:getChildByFullName("rankRange")
        local pos = rankD.rank
        local rankStr = "第" .. getRange(pos[1],pos[2]) .. "名"
        -- rankRange:setFontSize(22)
        rankRange:setString(rankStr)

        local itemNum = rankD.score .. "/小时"
        local awardNum1 = item:getChildByFullName("awardNum1")
        awardNum1:setString(itemNum or 0)

        self._scrollBg:addChild(item)
    end

    local w = 0 -- topDes:getInnerSize().width
    local h = 0 -- topDes:getVirtualRendererSize().height

    bgHeight = bgHeight+h
    self._scrollBg:setContentSize(cc.size(itemW,bgHeight - 2))
    self._scrollBg:setBackGroundImageCapInsets(cc.rect(217,30,1,1))
    return bgHeight
end
-- 接收自定义消息
function CrossScoreRuleView:reflashUI(data)

end

return CrossScoreRuleView