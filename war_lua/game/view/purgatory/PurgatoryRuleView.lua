--[[
    Filename:    PurgatoryRuleView.lua
    Author:      <yuxiaojing@playcrab.com>
    Datetime:    2018-02-06 16:32:00
    Description: File description
--]]

local PurgatoryRuleView = class("PurgatoryRuleView",BasePopView)

function PurgatoryRuleView:ctor()
    self.super.ctor(self)
end

function PurgatoryRuleView:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("purgatory.PurgatoryRuleView")
    end)

    self._rankModel = self._modelMgr:getModel("RankModel")
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

    local txtrank = self:getUI("bg.scrollView.des1Bg.rank")
    txtrank:setFontName(UIUtils.ttfName)
    txtrank:setColor(UIUtils.colorTable.ccUIBaseColor9)
    txtrank:setPositionX(currRankTxt:getPositionX()+currRankTxt:getContentSize().width+2)

    local txtdes2 = self:getUI("bg.scrollView.des1Bg.des2")
    txtdes2:setFontName(UIUtils.ttfName)
    txtdes2:setPositionX(txtrank:getPositionX()+txtrank:getContentSize().width+2)
    txtdes2:setVisible(false)

    local txttopRank = self:getUI("bg.scrollView.des1Bg.topRank")
    txttopRank:setColor(cc.c3b(70, 40, 0))
    txttopRank:setFontName(UIUtils.ttfName)
    txttopRank:setPositionX(txtdes2:getPositionX()+txtdes2:getContentSize().width+2)
    txttopRank:setVisible(false)

    local txtdes4 = self:getUI("bg.scrollView.des1Bg.des4")
    txtdes4:setFontName(UIUtils.ttfName)
    txtdes4:setPositionX(txttopRank:getPositionX()+txttopRank:getContentSize().width+2)
    txtdes4:setVisible(false)

    local txtdes3 = self:getUI("bg.scrollView.des1Bg.des3")
    txtdes3:setFontName(UIUtils.ttfName)

    local txtrankRange = self:getUI("bg.scrollView.des1Bg.rankRange")
    txtrankRange:setFontName(UIUtils.ttfName)

    local maxHeight = 0 --self._scrollView:getInnerContainerSize().height
    -- maxHeight = maxHeight+self._title:getContentSize().height
    maxHeight = maxHeight+self._des1Bg:getContentSize().height
    local scrollW = self._scrollView:getInnerContainerSize().width
    -- 增加抬头
    local des1 = self._textPro:clone()
    des1:setString("无尽炼狱结算奖励")
    des1:setFontSize(24)
    des1:setFontName(UIUtils.ttfName)
    des1:setTextColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- des1:setOpacity(200)
    des1:setAnchorPoint(cc.p(0,0))
    maxHeight=maxHeight+des1:getContentSize().height+5
    self._scrollView:addChild(des1)

    local des2 = self._textPro:clone()
    des2:setString("无尽炼狱战斗规则")
    des2:setFontName(UIUtils.ttfName)
    des2:setFontSize(24)
    des2:setTextColor(UIUtils.colorTable.ccUIBaseTextColor2)

    -- des2:setOpacity(200)
    maxHeight=maxHeight+des2:getContentSize().height+20
    self._scrollView:addChild(des2)

    -- 增加富文本
    local rtxStr = lang("pur_rule")  --lang("RULE_ARENA")
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
    self._des1Bg:setPosition(cc.p(0,maxHeight-self._des1Bg:getContentSize().height+5))


    des1:setPosition(cc.p(10,scrollBgH))
    des2:setPosition(cc.p(10,maxHeight-self._des1Bg:getContentSize().height-15))

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

function PurgatoryRuleView:getInRangeData( rank )
    if rank > 10000 then
        rank = 10000
    end
    local purRank = tab["purRank"]
    for i,honorD in ipairs(purRank) do
        local low,high = honorD.rank[1], honorD.rank[2]
        if rank >= low and rank <= high then
            return honorD
        end
    end
end

function PurgatoryRuleView:reflashTitleInfo()
    local rankData = self._rankModel:getSelfRankInfo(33)
    local rank = self._des1Bg:getChildByFullName("rank")
    local ranknum = rankData.rank or 0
    local rankTx = ranknum
    if ranknum == 0 then
        rankTx = "暂未上榜"
    end
    rank:setString(rankTx)
    local txtdes2 = self:getUI("bg.scrollView.des1Bg.des2")
    txtdes2:setPositionX(rank:getPositionX()+rank:getContentSize().width+2)  
    -- local topRank = self._des1Bg:getChildByFullName("topRank")
    -- topRank:setString(math.min(arenaD.arena.hRank or ranknum,10000))    
    -- topRank:setPositionX(txtdes2:getPositionX()+txtdes2:getContentSize().width+2)
    -- local des4 = self._des1Bg:getChildByFullName("des4")
    -- des4:setPositionX(topRank:getPositionX()+topRank:getContentSize().width)
    local des3 = self._des1Bg:getChildByFullName('des3')
    local value_1 = self._des1Bg:getChildByFullName('value_1')
    local value_2 = self._des1Bg:getChildByFullName('value_2')
    local value_3 = self._des1Bg:getChildByFullName('value_3')
    if ranknum > 0 then
        local honorD = self:getInRangeData(ranknum)
        if honorD then
            local rankRange = self._des1Bg:getChildByFullName("rankRange")
            rankRange:setString("(" .. getRange(honorD.rank[1], honorD.rank[2]) .. ")")
            self:updateReward(self._des1Bg, honorD.reward)
        end
    else
        des3:setString('当前排名奖励：无')
        value_1:setVisible(false)
        value_2:setVisible(false)
        value_3:setVisible(false)
    end
end

function PurgatoryRuleView:updateReward(item, reward)
    for i = 1, 3 do
        local img = item:getChildByFullName('img_' .. i)
        local value = item:getChildByFullName('value_' .. i)
        if reward[i] == nil then
            img:setVisible(false)
            value:setVisible(false)
            return
        end
        
        img:setVisible(true)
        value:setVisible(true)

        local itemIcon = img:getChildByTag(9982)
        if itemIcon then itemIcon:removeFromParent() end

        local itemId = reward[i][2]
        local itemType = reward[i][1]
        local eventStyle = 1
        local scale = 0.8
        -- if itemType == "guildCoin" then
        --     itemIcon = ccui.ImageView:create()
        --     itemIcon:loadTexture(IconUtils.resImgMap.guildCoin, 1)
        --     itemIcon:setPosition(img:getContentSize().width / 2, img:getContentSize().height / 2)
        --     scale = 1
        -- else
        if itemType == "avatarFrame" then
            local frameData = tab:AvatarFrame(itemId)
            param = {itemId = itemId, itemData = frameData}
            itemIcon = IconUtils:createHeadFrameIconById(param)
            scale = 0.4
        elseif itemType == "siegeProp" then
            self.rewardsSiegeProp = true
            local propsTab = tab:SiegeEquip(itemId)
            local param = {itemId = itemId, level = 1, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 1}
            itemIcon = IconUtils:createWeaponsBagItemIcon(param)
        else
            if itemType ~= "tool" then
                itemId = IconUtils.iconIdMap[itemType]
            end
            scale = 0.5
            itemIcon = IconUtils:createItemIconById({itemId = itemId, num = reward[i][3],eventStyle = eventStyle})
            itemIcon:getChildByFullName('iconColor'):getChildByFullName('numLab'):setVisible(false)
        end
        
        itemIcon:setScale(scale)
        itemIcon:setTag(9982)
        img:addChild(itemIcon)

        value:setString(reward[i][3])
    end
end

function PurgatoryRuleView:generateRanks()
    local itemH,itemW = self._rankCell:getContentSize().height,self._rankCell:getContentSize().width
    local purRank = clone(tab["purRank"])
    local bgHeight = (#purRank)*itemH
    table.sort( purRank, function ( item1, item2 )
        return item1.id > item2.id
    end )
    for i,rankD in ipairs(purRank) do
        local item = self._rankCell:clone()
        item:setVisible(true)
        item:setPosition(cc.p(-25,itemH*(i-1)-3))
        if i%2 == 1 then
            item:getVirtualRenderer():setVisible(false)
        end
        local rankRange = item:getChildByFullName("rankRange")
        local rank = rankD.rank
        local rankStr = "第" .. getRange(rank[1], rank[2]) .. "名"
        rankRange:setString(rankStr)

        self:updateReward(item, rankD.reward)

        self._scrollBg:addChild(item)
    end
    -- 顶部描述
    local time = tab.setting["PURGATORYRESARD_TIME"].value
    local rtxStr = "[color=8a5c1d,fontsize=18]无尽炼狱当日[color=8a5c1d,fontsize=18]" .. time .. "[-]结算奖励，奖励将通过邮件发放。[-]"
    local topDes = RichTextFactory:create(rtxStr,418,height)
    topDes:formatText()
    topDes:setVerticalSpace(3)
    topDes:setAnchorPoint(cc.p(0,0))
    local w = topDes:getInnerSize().width
    local h = topDes:getVirtualRendererSize().height
    topDes:setName("topDes")
    topDes:setPosition(cc.p(-w*0.5+5,bgHeight))
    self._scrollBg:addChild(topDes)
    bgHeight = bgHeight+h
    self._scrollBg:setContentSize(cc.size(itemW,bgHeight - 2))
    self._scrollBg:setBackGroundImageCapInsets(cc.rect(217,30,1,1))
    return bgHeight
end
-- 接收自定义消息
function PurgatoryRuleView:reflashUI(data)

end

return PurgatoryRuleView