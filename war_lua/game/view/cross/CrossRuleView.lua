--[[
    Filename:    CrossRuleView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-11-25 15:09:01
    Description: File description
--]]

local CrossRuleView = class("CrossRuleView",BasePopView)
function CrossRuleView:ctor()
    self.super.ctor(self)

end

-- 初始化UI后会调用, 有需要请覆盖
function CrossRuleView:onInit()
    self._crossModel = self._modelMgr:getModel("CrossModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    

    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("cross.CrossRuleView")
    end)

    self._seasonSpot = self._crossModel:getSeasonSpot()

    local des1Bg = self:getUI("bg.scrollView.des1Bg")
    local des2Bg = self:getUI("bg.scrollView.des2Bg")
    des1Bg:setVisible(false)
    des2Bg:setVisible(false)
    self._des1Bg = des1Bg
    if self._seasonSpot ~= 0 then
        self._des1Bg = des2Bg
    end
    self._des1Bg:setVisible(true)
    self:reflashTitleInfo()

    self._scrollView = self:getUI("bg.scrollView")
    self._scrollView:setBounceEnabled(true)
    self._title = self:getUI("bg.headBg.title")
    self._title:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._title,6)
    self._scrollBg = self:getUI("bg.scrollView.scrollBg")
    self._ruleBg = self:getUI("bg.scrollView.ruleBg")
    self._rankCell = self:getUI("bg.rankCell")

    -- 文字原型
    self._textPro = ccui.Text:create()
    self._textPro:setString("")
    self._textPro:setAnchorPoint(cc.p(0,1))
    self._textPro:setPosition(cc.p(0,0))
    self._textPro:setFontSize(22)
    self._textPro:setFontName(UIUtils.ttfName)
    self._textPro:setTextColor(cc.c4b(255,110,59,255))

    -- local currRankTxt = self:getUI("bg.scrollView.des1Bg.des1")
    -- currRankTxt:setFontName(UIUtils.ttfName)

    local maxHeight = 0 --self._scrollView:getInnerContainerSize().height
    -- maxHeight = maxHeight+self._title:getContentSize().height
    maxHeight = maxHeight+self._des1Bg:getContentSize().height
    local scrollW = self._scrollView:getInnerContainerSize().width
    -- 增加抬头
    local des1 = self._textPro:clone()
    des1:setString("")
    des1:setFontSize(24)
    des1:setFontName(UIUtils.ttfName)
    des1:setTextColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- des1:setOpacity(200)
    des1:setAnchorPoint(cc.p(0,0))
    maxHeight=maxHeight+des1:getContentSize().height+5
    self._scrollView:addChild(des1)

    local des2 = self._textPro:clone()
    des2:setString("基础规则")
    des2:setFontName(UIUtils.ttfName)
    des2:setFontSize(24)
    des2:setTextColor(UIUtils.colorTable.ccUIBaseTextColor2)

    -- -- des2:setOpacity(200)
    maxHeight=maxHeight+des2:getContentSize().height+20
    self._scrollView:addChild(des2)

    -- 增加富文本
    local rtxStr = lang("cp_rule")
    -- rtxStr = string.gsub(rtxStr,"ffffff","462800")
    local rtx = RichTextFactory:create(rtxStr,418,0)
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
    self._des1Bg:setPosition(cc.p(0, maxHeight-self._des1Bg:getContentSize().height+5))

    des1:setPosition(cc.p(10,scrollBgH))
    des2:setPosition(cc.p(10,maxHeight-self._des1Bg:getContentSize().height-15))

    rtx:setPosition(cc.p(-w* 0.5+10,scrollBgH+des1:getContentSize().height+28))
    self._ruleBg:setPosition(-5,scrollBgH+des1:getContentSize().height+15)
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

function CrossRuleView:getInRangeData( rank )
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

function CrossRuleView:reflashTitleInfo()
    local arenaData = self._crossModel:getData()
    dump(arenaData)
    local panel_100 = self._des1Bg:getChildByFullName('Panel_100')
    local des2 = panel_100:getChildByFullName('des3')
    local des1 = panel_100:getChildByFullName('des2')
    local serName1 = panel_100:getChildByFullName('serName1')
    local serName2 = panel_100:getChildByFullName('serName2')

    local setStr1, setStr2 = self._crossModel:getWarZoneName(true)

    local tempL = cc.Label:createWithTTF(setStr1, serName1:getFontName(), serName1:getFontSize(), cc.size(315, 0))
    local h = tempL:getContentSize().height
    serName1:setContentSize(serName1:getContentSize().width, h)

    local tempL = cc.Label:createWithTTF(setStr2, serName2:getFontName(), serName2:getFontSize(), cc.size(315, 0))
    local h = tempL:getContentSize().height
    serName2:setContentSize(serName2:getContentSize().width, h)

    serName1:setString(setStr1)
    serName2:setString(setStr2)

    serName2:setPositionY(0)
    des2:setPositionY(serName2:getContentSize().height - des2:getContentSize().height)

    serName1:setPositionY(serName2:getContentSize().height)
    des1:setPositionY(serName1:getPositionY() + serName1:getContentSize().height - des1:getContentSize().height)

    panel_100:setContentSize(panel_100:getContentSize().width, serName1:getPositionY() + serName1:getContentSize().height)

    local panel_101 = self._des1Bg:getChildByFullName("Panel_101")

    local arenaName1 = panel_101:getChildByFullName("arenaName1")
    local arenaName2 = panel_101:getChildByFullName("arenaName2")
    local arenaName3 = panel_101:getChildByFullName("arenaName3")
    local arenaLab1 = panel_101:getChildByFullName("arenaLab1")
    local arenaLab2 = panel_101:getChildByFullName("arenaLab2")
    local arenaLab3 = panel_101:getChildByFullName("arenaLab3")
    panel_101:getChildByFullName("des1"):setFontName(UIUtils.ttfName)

    for i=1,3 do
        local regiontype = arenaData["regiontype" .. i]
        local arenaName = panel_101:getChildByFullName("arenaName" .. i)
        local arenaLab = panel_101:getChildByFullName("arenaLab" .. i)
        local str = lang("cp_npcRegion" .. regiontype) .. ":"
        arenaName:setString(str)

        arenaLab:setPositionX(arenaName:getPositionX()+arenaName:getContentSize().width+10)

        local arenaRace = lang("cp_region" .. regiontype)
        local extra = arenaData["extra" .. i] or {}
        if table.nums(extra) > 0 then
            arenaRace = arenaRace .. "、"
        end
        for k,v in ipairs(extra) do
            if k == table.nums(extra) then
                arenaRace = arenaRace .. lang("cp_region" .. v)
            else
                arenaRace = arenaRace .. lang("cp_region" .. v) .. "、"
            end
        end
        arenaLab:setString(arenaRace)
    end

    if self._seasonSpot ~= 0 then
        local hotName = panel_101:getChildByFullName("hotName")
        local hotValue = panel_101:getChildByFullName("hotValue")
        hotName:setString(lang("cp_npcRegion" .. arenaData["regiontype3"]) .. ":")
        hotValue:setString(lang("CP_SEASONSPOT_NAME" .. self._seasonSpot))
        hotValue:setPositionX(hotName:getPositionX() + hotName:getContentSize().width + 10)
    end

    self._des1Bg:setContentSize(self._des1Bg:getContentSize().width, panel_100:getContentSize().height + panel_101:getContentSize().height + 20)
    panel_101:setPositionY(panel_100:getContentSize().height + 20)
end

function CrossRuleView:generateRanks()
    local bgHeight = 0
    -- for i,rankD in ipairs(arenaHonor) do
    --     local item = self._rankCell:clone()
    --     item:setVisible(true)
    --     item:setPosition(0,itemH*(i-1))
    --     ---[[ 用数据初始化item
    --     local rankRange = item:getChildByFullName("rankRange")
    --     local pos = rankD.pos
    --     local rankStr = "第" .. getRange(pos[1],pos[2]) .. "名"
    --     -- rankRange:setFontSize(22)
    --     rankRange:setString(rankStr)

    --     if i == table.nums(arenaHonor) then
    --         for i=1,3 do
    --             local rankTitle = item:getChildByFullName("rankTitle" .. i)
    --             rankTitle:setVisible(true)
    --             local regiontype = arenaData["regiontype" .. i]
    --             local regionName = lang("cp_npcRegion" .. regiontype)
    --             rankTitle:setString(regionName)
    --         end
    --     end

    --     -- dump(rankD)
    --     local awardData = rankD.reward1
    --     local itemData = awardData[2]
    --     local itemType = itemData[1]
    --     local itemId = itemData[2]
    --     local itemNum = itemData[3] or 0
    --     local awardNum1 = item:getChildByFullName("awardNum1")
    --     awardNum1:setString(itemNum or 0)

    --     local itemData = awardData[1]
    --     local itemType = itemData[1]
    --     local itemId = itemData[2]
    --     local itemNum = itemData[3] or 0
    --     local fileName
    --     if IconUtils.resImgMap[itemType] then
    --         fileName = IconUtils.resImgMap[itemType]
    --     else
    --         local toolD = tab:Tool(itemId)
    --         fileName = toolD.art .. ".png"
    --     end
    --     local awardImg2 = item:getChildByFullName("awardImg2")
    --     awardImg2:loadTexture(fileName, 1)
    --     local awardNum2 = item:getChildByFullName("awardNum2")
    --     awardNum2:setString(itemNum or 0)

    --     local awardData = rankD.reward2
    --     local itemData = awardData[1]
    --     local itemType = itemData[1]
    --     local itemId = itemData[2]
    --     local itemNum = itemData[3] or 0
    --     local fileName
    --     if IconUtils.resImgMap[itemType] then
    --         fileName = IconUtils.resImgMap[itemType]
    --     else
    --         local toolD = tab:Tool(itemId)
    --         fileName = toolD.art .. ".png"
    --     end
    --     local awardImg3 = item:getChildByFullName("awardImg3")
    --     awardImg3:loadTexture(fileName, 1)
    --     local awardNum3 = item:getChildByFullName("awardNum3")
    --     awardNum3:setString(itemNum or 0)

    --     local awardData = rankD.reward3
    --     local itemData = awardData[1]
    --     local itemType = itemData[1]
    --     local itemId = itemData[2]
    --     local itemNum = itemData[3] or 0
    --     local fileName
    --     if IconUtils.resImgMap[itemType] then
    --         fileName = IconUtils.resImgMap[itemType]
    --     else
    --         local toolD = tab:Tool(itemId)
    --         fileName = toolD.art .. ".png"
    --     end
    --     local awardImg4 = item:getChildByFullName("awardImg4")
    --     awardImg4:loadTexture(fileName, 1)
    --     local awardNum4 = item:getChildByFullName("awardNum4")
    --     awardNum4:setString(itemNum or 0)

    --     self._scrollBg:addChild(item)
    -- end
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
    return bgHeight
end
-- 接收自定义消息
function CrossRuleView:reflashUI(data)

end

return CrossRuleView