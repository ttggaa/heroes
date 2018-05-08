--[[
    @FileName   SiegeRuleView.lua
    @Authors    zhangtao
    @Date       2017-09-19 21:43:43
    @Email      <zhangtao@playcrad.com>
    @Description   描述
--]]
local SiegeRuleView = class("SiegeRuleView",BasePopView)
local ruleStrTable = 
                {
                    [1] = {"SIEGE_EVENT_ATKRULES1","攻城战斗规则","攻城战结算奖励","SIEGE_EVENT_ATKRULES2"},
                    [2] = {"SIEGE_EVENT_ATKRULES1","攻城战斗规则","攻城战结算奖励","SIEGE_EVENT_ATKRULES2"},
                    [3] = {"SIEGE_EVENT_DEFENDRULES1","守城战斗规则","守城战结算奖励","SIEGE_EVENT_DEFENDRULES2"}
                }      
function SiegeRuleView:ctor(data)
    self.super.ctor(self)
    self._stageId = data.stageId
end

-- 初始化UI后会调用, 有需要请覆盖
function SiegeRuleView:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("siege.SiegeRuleView")
    end)

    self._siegeType = tab.siegeMainStage[self._stageId]["type"] or 1    --城市类型

    self._scrollView = self:getUI("bg.scrollView")
    self._scrollView:setBounceEnabled(true)
    self._des1Bg = self:getUI("bg.scrollView.des1Bg")
    self._title = self:getUI("bg.headBg.title")
    self._title:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._title,6)
    self._scrollBg = self:getUI("bg.scrollView.scrollBg")
    self._ruleBg = self:getUI("bg.scrollView.ruleBg")
    self._rankCell = self:getUI("bg.rankCell")

    local diamondImg = self:getUI("bg.scrollView.des1Bg.diamondImg")         
    diamondImg:setScale(0.6)
    local goldImg = self._des1Bg:getChildByFullName("goldImg")          
    goldImg:setScale(0.55)
    local currencyImg = self._des1Bg:getChildByFullName("currencyImg")       
    currencyImg:setScale(0.55)

    local goldNum = self:getUI("bg.scrollView.des1Bg.goldNum")
    goldNum:setPositionX(goldImg:getPositionX()+goldImg:getContentSize().width*0.6/2+5) 
    local diamondNum = self:getUI("bg.scrollView.des1Bg.diamondNum")
    diamondNum:setPositionX(diamondImg:getPositionX()+diamondImg:getContentSize().width*0.55/2+5) 
    local currencyNum = self:getUI("bg.scrollView.des1Bg.currencyNum")
    currencyNum:setPositionX(currencyImg:getPositionX()+currencyImg:getContentSize().width*0.55/2+5) 

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

    -- local txtdes2 = self:getUI("bg.scrollView.des1Bg.des2")
    -- txtdes2:setFontName(UIUtils.ttfName)
    -- txtdes2:setPositionX(txtrank:getPositionX()+txtrank:getContentSize().width+2)

    -- local txttopRank = self:getUI("bg.scrollView.des1Bg.topRank")
    -- txttopRank:setColor(cc.c3b(70, 40, 0))
    -- txttopRank:setFontName(UIUtils.ttfName)
    -- txttopRank:setPositionX(txtdes2:getPositionX()+txtdes2:getContentSize().width+2)

    -- local txtdes4 = self:getUI("bg.scrollView.des1Bg.des4")
    -- txtdes4:setFontName(UIUtils.ttfName)
    -- txtdes4:setPositionX(txttopRank:getPositionX()+txttopRank:getContentSize().width+2)

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
    des1:setString(ruleStrTable[self._siegeType][3])   --奖励结算
    des1:setFontSize(24)
    des1:setFontName(UIUtils.ttfName)
    des1:setTextColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- des1:setOpacity(200)
    des1:setAnchorPoint(cc.p(0,0))
    maxHeight=maxHeight+des1:getContentSize().height+5
    self._scrollView:addChild(des1)

    local des2 = self._textPro:clone()
    des2:setString(ruleStrTable[self._siegeType][2])                   --战斗规则
    des2:setFontName(UIUtils.ttfName)
    des2:setFontSize(24)
    des2:setTextColor(UIUtils.colorTable.ccUIBaseTextColor2)

    -- des2:setOpacity(200)
    maxHeight=maxHeight+des2:getContentSize().height+20
    self._scrollView:addChild(des2)

    -- 增加富文本
    local rtxStr = lang(ruleStrTable[self._siegeType][1])  --lang("RULE_ARENA")
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

-- function SiegeRuleView:getInRangeData( rank )
--     if rank > 10000 then
--         rank = 10000
--     end
--     local siegeRank = tab["siegeRank"]
--     for i,siegeData in ipairs(siegeRank) do
--         if siegeData["sectionID"] == self._stageId then
--             local low,high = siegeData.rank[1],siegeData.rank[2]
--             if rank >= low and rank <= high then
--                 return siegeData
--             end
--         end
--     end
-- end

function SiegeRuleView:reflashTitleInfo()
    local rankData = self._modelMgr:getModel("SiegeModel"):getPrepareData()
    local rank = self._des1Bg:getChildByFullName("rank")
    local ranknum = 0
    if rankData["ownerInfo"] then
        ranknum = rankData["ownerInfo"]["rank"]
    end
    local ranknum = math.min(ranknum or 10000,10000)
    rank:setString(ranknum)
    local noAward = self._des1Bg:getChildByFullName("noAward")
    local rewardD = self._modelMgr:getModel("SiegeModel"):getInRangeData(ranknum,self._stageId)
    if rewardD then
        self:createTopRankNode(self._des1Bg,rewardD["award"])
        noAward:setVisible(false)
    else
        noAward:setVisible(true)
    end
end

function SiegeRuleView:generateRanks()
    local itemH,itemW = self._rankCell:getContentSize().height,self._rankCell:getContentSize().width
    local siegeData = clone(tab["siegeRank"])
    local realSiegeData = {}
    for i,v in ipairs(siegeData) do
        if v["sectionID"] == self._stageId then
            table.insert(realSiegeData,v)
        end
    end
    local bgHeight = (#realSiegeData)*itemH
    for i,rankD in ipairs(realSiegeData) do
        local item = self._rankCell:clone()
        item:setVisible(true)
        item:setPosition(cc.p(-25,itemH*(i-1)-3))
        if i%2 == 1 then
            item:getVirtualRenderer():setVisible(false)
        end

        ---用数据初始化item
        local rankRange = item:getChildByFullName("rankRange")
        local pos = rankD.rank
        local rankStr = "第" .. getRange(pos[1],pos[2]) .. "名"
        -- rankRange:setFontSize(22)
        rankRange:setString(rankStr)

        self:createListNode(item,rankD["award"])

        -- local diamondNum = item:getChildByFullName("diamondNum")
        -- diamondNum:setString(rankD.diamond or 0)

        -- local goldNum = item:getChildByFullName("goldNum")
        -- goldNum:setString(rankD.gold or 0)
        -- local currencyNum = item:getChildByFullName("currencyNum")
        -- currencyNum:setString(rankD.currency or 0)

        self._scrollBg:addChild(item)
    end
    -- 顶部描述
    local rtxStr = "[color=8a5c1d,fontsize=18]"..lang(ruleStrTable[self._siegeType][4]).."[-]"
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

function SiegeRuleView:createListNode(item,award)
    local posTable = {{x = 185,y=1},{x = 260,y=1},{x=360,y=1}}
    for k , data in pairs(award) do
        local itemId
        local teamId
        local num
        local starlevel 
        if data[1] == "tool" then
            itemId = data[2]
            num = data[3]
        elseif data[1] == "team" then 
            teamId = data[2]
            num = data[3]
            starlevel = data[4]
        elseif data[1] == "hero" then
            return
        else
            itemId = IconUtils.iconIdMap[data[1]]
            num = data[3]
        end
        local itemIcon = item:getChildByName("awardItemIcon"..k)
        if itemId then
            local param = {itemId = itemId, effect = false, eventStyle = 0, num = num}
            -- local itemIcon = itemBg:getChildByName("itemIcon")
            if itemIcon then
                IconUtils:updateItemIconByView(itemIcon, param)
            else
                itemIcon = IconUtils:createItemIconById(param)
                itemIcon:setName("awardItemIcon"..k)
                itemIcon:setScale(0.3)
                itemIcon:setPosition(posTable[k]["x"],posTable[k]["y"])
                item:addChild(itemIcon)
            end
            itemIcon.iconColor.numLab:setVisible(false)
        elseif teamId then
            local sysTeamData = clone(tab.team[teamId])
            if starlevel ~= nil  then 
                sysTeamData.starlevel = starlevel
            end
            local param = {sysTeamData = sysTeamData, effect = false, eventStyle = 0, isJin = true}
            if itemIcon then
                IconUtils:updateSysTeamIconByView(itemIcon, param)
            else
                itemIcon = IconUtils:createSysTeamIconById(param)
                itemIcon:setName("awardItemIcon"..k)
                itemIcon:setScale(0.3)
                itemIcon:setPosition(posTable[k]["x"],posTable[k]["y"])
                item:addChild(itemIcon)
            end
        end

        local awardLab =  ccui.Text:create()
        awardLab:setName("awardLab")
        awardLab:setFontSize(18)
        awardLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        -- awardLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        awardLab:setAnchorPoint(0, 0.5)
        awardLab:setPosition(posTable[k]["x"]+30,posTable[k]["y"]+12)
        awardLab:setFontName(UIUtils.ttfName)
        awardLab:setString(num)
        item:addChild(awardLab)
    end
end

function SiegeRuleView:createTopRankNode(item,award)
    local posTable = {{x = 145,y=8},{x = 220,y=8},{x=320,y=8}}
    for k , data in pairs(award) do
        local itemId
        local teamId
        local num
        local starlevel 
        if data[1] == "tool" then
            itemId = data[2]
            num = data[3]
        elseif data[1] == "team" then 
            teamId = data[2]
            num = data[3]
            starlevel = data[4]
        elseif data[1] == "hero" then
            return
        else
            itemId = IconUtils.iconIdMap[data[1]]
            num = data[3]
        end
        local itemIcon = item:getChildByName("awardItemIcon"..k)
        if itemId then
            local param = {itemId = itemId, effect = false, eventStyle = 0, num = num}
            -- local itemIcon = itemBg:getChildByName("itemIcon")
            if itemIcon then
                IconUtils:updateItemIconByView(itemIcon, param)
            else
                itemIcon = IconUtils:createItemIconById(param)
                itemIcon:setName("awardItemIcon"..k)
                itemIcon:setScale(0.32)
                itemIcon:setPosition(posTable[k]["x"],posTable[k]["y"])
                item:addChild(itemIcon)
            end
            itemIcon.iconColor.numLab:setVisible(false)
        elseif teamId then
            local sysTeamData = clone(tab.team[teamId])
            if starlevel ~= nil  then 
                sysTeamData.starlevel = starlevel
            end
            local param = {sysTeamData = sysTeamData, effect = false, eventStyle = 0, isJin = true}
            if itemIcon then
                IconUtils:updateSysTeamIconByView(itemIcon, param)
            else
                itemIcon = IconUtils:createSysTeamIconById(param)
                itemIcon:setName("awardItemIcon"..k)
                itemIcon:setScale(0.32)
                itemIcon:setPosition(posTable[k]["x"],posTable[k]["y"])
                item:addChild(itemIcon)
            end
        end

        local awardLab =  ccui.Text:create()
        awardLab:setName("awardLab")
        awardLab:setFontSize(18)
        awardLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        -- awardLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        awardLab:setAnchorPoint(0, 0.5)
        awardLab:setPosition(posTable[k]["x"]+30,posTable[k]["y"]+13)
        awardLab:setFontName(UIUtils.ttfName)
        awardLab:setString(num)
        item:addChild(awardLab)
    end
end

-- 接收自定义消息
function SiegeRuleView:reflashUI(data)

end

return SiegeRuleView