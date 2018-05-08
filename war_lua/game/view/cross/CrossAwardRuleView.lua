--[[
    Filename:    CrossAwardRuleView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-11-30 17:26:45
    Description: File description
--]]


local CrossAwardRuleView = class("CrossAwardRuleView",BasePopView)
function CrossAwardRuleView:ctor()
    self.super.ctor(self)

end

-- 初始化UI后会调用, 有需要请覆盖
function CrossAwardRuleView:onInit()
    self._crossModel = self._modelMgr:getModel("CrossModel")
    

    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("cross.CrossAwardRuleView")
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
    maxHeight = maxHeight+self._des1Bg:getContentSize().height
    local scrollW = self._scrollView:getInnerContainerSize().width
    -- 增加抬头
    local des1 = self._textPro:clone()
    des1:setString("排名奖励")
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
    local rtxStr = lang("cp_rankaward_tips")  --lang("RULE_ARENA")
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

function CrossAwardRuleView:getInRangeData( rank )
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

function CrossAwardRuleView:reflashTitleInfo()
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

function CrossAwardRuleView:generateRanks()
    local itemH,itemW = self._rankCell:getContentSize().height,self._rankCell:getContentSize().width
    local arenaHonor = clone(tab["cpRankReward"])
    local arenaData = self._crossModel:getData()
    local bgHeight = (#arenaHonor)*itemH
    for i,rankD in ipairs(arenaHonor) do
        local item = self._rankCell:clone()
        item:setVisible(true)
        item:setPosition(0,itemH*(i-1))
        ---[[ 用数据初始化item
        local rankRange = item:getChildByFullName("rankRange")
        local pos = rankD.pos
        local rankStr = "第" .. getRange(pos[1],pos[2]) .. "名"
        -- rankRange:setFontSize(22)
        rankRange:setString(rankStr)

        if i == table.nums(arenaHonor) then
            for i=1,3 do
                local rankTitle = item:getChildByFullName("rankTitle" .. i)
                rankTitle:setVisible(true)
                local regiontype = arenaData["regiontype" .. i]
                local regionName = lang("cp_npcRegion" .. regiontype)
                rankTitle:setString(regionName)
            end
        end

        -- dump(rankD)
        local awardData = rankD.reward1
        local itemData = awardData[2]
        local itemType = itemData[1]
        local itemId = itemData[2]
        local itemNum = itemData[3] or 0
        local awardNum1 = item:getChildByFullName("awardNum1")
        awardNum1:setString(itemNum or 0)

        local itemData = awardData[1]
        local itemType = itemData[1]
        local itemId = itemData[2]
        local itemNum = itemData[3] or 0
        local fileName
        if IconUtils.resImgMap[itemType] then
            fileName = IconUtils.resImgMap[itemType]
        else
            local toolD = tab:Tool(itemId)
            fileName = toolD.art .. ".png"
        end
        local awardImg2 = item:getChildByFullName("awardImg2")
        awardImg2:loadTexture(fileName, 1)
        local awardNum2 = item:getChildByFullName("awardNum2")
        awardNum2:setString(itemNum or 0)

        local awardData = rankD.reward2
        local itemData = awardData[1]
        local itemType = itemData[1]
        local itemId = itemData[2]
        local itemNum = itemData[3] or 0
        local fileName
        if IconUtils.resImgMap[itemType] then
            fileName = IconUtils.resImgMap[itemType]
        else
            local toolD = tab:Tool(itemId)
            fileName = toolD.art .. ".png"
        end
        local awardImg3 = item:getChildByFullName("awardImg3")
        awardImg3:loadTexture(fileName, 1)
        local awardNum3 = item:getChildByFullName("awardNum3")
        awardNum3:setString(itemNum or 0)

        local awardData = rankD.reward3
        local itemData = awardData[1]
        local itemType = itemData[1]
        local itemId = itemData[2]
        local itemNum = itemData[3] or 0
        local fileName
        if IconUtils.resImgMap[itemType] then
            fileName = IconUtils.resImgMap[itemType]
        else
            local toolD = tab:Tool(itemId)
            fileName = toolD.art .. ".png"
        end
        local awardImg4 = item:getChildByFullName("awardImg4")
        awardImg4:loadTexture(fileName, 1)
        local awardNum4 = item:getChildByFullName("awardNum4")
        awardNum4:setString(itemNum or 0)

        self._scrollBg:addChild(item)
    end
    -- 顶部描述
    -- local rtxStr = "[color=8a5c1d,fontsize=18]竞技场每日[color=8a5c1d,fontsize=18]21:00[-]结算奖励，奖励将通过邮件发放。[-]"
    -- local topDes = RichTextFactory:create(rtxStr,418,height)
    -- topDes:formatText()
    -- topDes:setVerticalSpace(3)
    -- topDes:setAnchorPoint(cc.p(0,0))
    local w = 0 -- topDes:getInnerSize().width
    local h = 0 -- topDes:getVirtualRendererSize().height
    -- topDes:setName("topDes")
    -- topDes:setPosition(cc.p(-w*0.5+5,bgHeight))
    -- self._scrollBg:addChild(topDes)
    bgHeight = bgHeight+h
    self._scrollBg:setContentSize(cc.size(itemW,bgHeight - 2))
    self._scrollBg:setBackGroundImageCapInsets(cc.rect(217,30,1,1))
    return bgHeight
end
-- 接收自定义消息
function CrossAwardRuleView:reflashUI(data)

end

return CrossAwardRuleView