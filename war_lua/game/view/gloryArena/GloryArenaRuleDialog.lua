--[[
    FileName:       GloryArenaRuleDialog
    Author:         <dongcheng@playcrab.com>
    Datetime:       2018-08-13 16:39:06
    Description:
]]

local GloryArenaRuleDialog = class("GloryArenaRuleDialog", BasePopView)

function GloryArenaRuleDialog:ctor()   
    self.super.ctor(self) 
end

function GloryArenaRuleDialog:disableTextEffect(element)
    if element == nil then
        element = self._widget
    end
    local desc = element:getDescription()
    if desc == "Label" then
        element:disableEffect()
    end
    local count = #element:getChildren()
    for i = 1, count do
        self:disableTextEffect(element:getChildren()[i])
    end
end

-- 初始化UI后会调用, 有需要请覆盖
function GloryArenaRuleDialog:onInit()
    
    self:disableTextEffect()

    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("gloryArena.GloryArenaRuleDialog")
    end)

    self._scrollView = self:getUI("bg.scrollView")
    self._scrollView:setBounceEnabled(true)
    self._des1Bg = self:getUI("bg.scrollView.des1Bg")
    self._title = self:getUI("bg.headBg.title")
    self._title:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._title,6)
    self._title:setString("荣耀竞技场")
    self._scrollBg = self:getUI("bg.scrollView.scrollBg")
    self._scrollBg:setVisible(true)
    self._rankCell = self:getUI("bg.rankCell")

    local diamondImg = self:getUI("bg.scrollView.des1Bg.diamondImg")         
    diamondImg:setScale(0.6)
    local goldImg = self._des1Bg:getChildByFullName("goldImg")
    goldImg:ignoreContentAdaptWithSize(false)
    goldImg:loadTexture("globalImageUI_texp.png", ccui.TextureResType.plistType) 
    goldImg:setScale(0.55)
    local currencyImg = self._des1Bg:getChildByFullName("currencyImg")       
    currencyImg:setScale(0.55)
    currencyImg:ignoreContentAdaptWithSize(false)
    currencyImg:loadTexture("globalImageUI_gloryArenaIcon_min.png", ccui.TextureResType.plistType)

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

    local txtdes2 = self:getUI("bg.scrollView.des1Bg.des2")
    txtdes2:setFontName(UIUtils.ttfName)
    txtdes2:setPositionX(txtrank:getPositionX()+txtrank:getContentSize().width+2)

    local txttopRank = self:getUI("bg.scrollView.des1Bg.topRank")
    txttopRank:setColor(cc.c3b(70, 40, 0))
    txttopRank:setFontName(UIUtils.ttfName)
    txttopRank:setPositionX(txtdes2:getPositionX()+txtdes2:getContentSize().width+2)

    local txtdes4 = self:getUI("bg.scrollView.des1Bg.des4")
    txtdes4:setFontName(UIUtils.ttfName)
    txtdes4:setPositionX(txttopRank:getPositionX()+txttopRank:getContentSize().width+2)

    local txtdes3 = self:getUI("bg.scrollView.des1Bg.des3")
    txtdes3:setFontName(UIUtils.ttfName)

    local txtrankRange = self:getUI("bg.scrollView.des1Bg.rankRange")
    txtrankRange:setFontName(UIUtils.ttfName)

    local maxHeight = 0 --self._scrollView:getInnerContainerSize().height
    -- maxHeight = maxHeight+self._title:getContentSize().height
    maxHeight = maxHeight+self._des1Bg:getContentSize().height
    local scrollW = self._scrollView:getInnerContainerSize().width

    local bIsCross = self._modelMgr:getModel("GloryArenaModel"):bIsCross()
--    local serverIp = 
--本期玩法：跨服战（本服战）
--匹配服务器：服务器xxxx（无）
    local type_text = currRankTxt:clone()
    type_text:setString("本期玩法：" .. (bIsCross and "跨服战" or "本服战"))
    maxHeight = maxHeight + type_text:getContentSize().height+5
--    type_text:setPosition(cc.p(currRankTxt:getPositionX(), maxHeight))
    self._scrollView:addChild(type_text)

    local serverIDList = self._modelMgr:getModel("GloryArenaModel"):lGetAttackServerId()
    local serverId_text = cc.Label:createWithTTF("匹配服务器：" .. (serverIDList or ""), UIUtils.ttfName, 20, cc.size(410, 0))--txtdes3:clone()
    serverId_text:setColor(txtdes3:getColor())
--    serverId_text:setFontSize()
    serverId_text:setAnchorPoint(cc.p(0, 0.5))
--    serverId_text:setString("匹配服务器：" .. (serverIDList or ""))
    self._scrollView:addChild(serverId_text)
    maxHeight = maxHeight + serverId_text:getContentSize().height+5

    local goldBg = self:getUI("bg.scrollView.des1Bg.goldBg"):clone()
    self._scrollView:addChild(goldBg)

    -- 增加抬头
    local des1 = self._textPro:clone()
    des1:setString("荣耀竞技场结算奖励")
    des1:setFontSize(24)
    des1:setFontName(UIUtils.ttfName)
    des1:setTextColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- des1:setOpacity(200)
    des1:setAnchorPoint(cc.p(0,0))
    maxHeight=maxHeight+des1:getContentSize().height+5
    self._scrollView:addChild(des1)

    local des2 = self._textPro:clone()
    des2:setString("荣耀竞技场战斗规则")
    des2:setFontName(UIUtils.ttfName)
    des2:setFontSize(24)
    des2:setTextColor(UIUtils.colorTable.ccUIBaseTextColor2)

    -- des2:setOpacity(200)
    maxHeight=maxHeight+des2:getContentSize().height+20
    self._scrollView:addChild(des2)


    -- 增加富文本
    local rtxStr = lang("RULE_GLORYARENA") or ""  --lang("RULE_ARENA")
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


    local scrollBgH = self:generateRanks()
    maxHeight = maxHeight+scrollBgH

    self._scrollView:setInnerContainerSize(cc.size(scrollW,maxHeight))
    
    self._scrollBg:setPosition(cc.p(5,0))
    -- self._title:setPositionY(maxHeight-self._title:getContentSize().height/2)
    self._des1Bg:setPosition(cc.p(0,maxHeight-self._des1Bg:getContentSize().height+5))


    des1:setPosition(cc.p(10,scrollBgH))
    des2:setPosition(cc.p(10,maxHeight-(self._des1Bg:getContentSize().height + 30 + type_text:getContentSize().height + serverId_text:getContentSize().height)))

    rtx:setPosition(cc.p(-w* 0.5+10,scrollBgH+des1:getContentSize().height+28))

    type_text:setPosition(cc.p(10, self._des1Bg:getPositionY() - type_text:getContentSize().height / 2 - 9))
    serverId_text:setPosition(cc.p(10, type_text:getPositionY() - serverId_text:getContentSize().height / 2 - 16))
    goldBg:setPosition(cc.p(10 + goldBg:getContentSize().width / 2, serverId_text:getPositionY() - serverId_text:getContentSize().height / 2 - 10))

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

function GloryArenaRuleDialog:getInRangeData( rank )
    if rank > 10000 then
        rank = 10000
    end
    local arenaHonor = tab["honorArenaAward"]
    for i,honorD in ipairs(arenaHonor) do
        local low,high = honorD.pos[1],honorD.pos[2]
        if rank >= low and rank <= high then
            return honorD
        end
    end
end

function GloryArenaRuleDialog:reflashTitleInfo()
    local arenaD = self._modelMgr:getModel("GloryArenaModel"):getData()
    local rank = self._des1Bg:getChildByFullName("rank")
    local ranknum = math.min(arenaD.rank or 10000,10000)
    rank:setString(ranknum)
    local txtdes2 = self:getUI("bg.scrollView.des1Bg.des2")
    txtdes2:setPositionX(rank:getPositionX()+rank:getContentSize().width+2)  
    local topRank = self._des1Bg:getChildByFullName("topRank")
    topRank:setString(math.min(arenaD.crossAarena.hRank or ranknum,10000))    
    topRank:setPositionX(txtdes2:getPositionX()+txtdes2:getContentSize().width+2)
    local des4 = self._des1Bg:getChildByFullName("des4")
    des4:setPositionX(topRank:getPositionX()+topRank:getContentSize().width)
    local honorD = self:getInRangeData(ranknum)
    if honorD then
        local rankRange = self._des1Bg:getChildByFullName("rankRange")
        rankRange:setString("(" .. getRange(honorD.pos[1],honorD.pos[2]) .. ")")
        local goldNum = self._des1Bg:getChildByFullName("goldNum")
        goldNum:setString(honorD.texp or 0)

        local diamondImg = self._des1Bg:getChildByFullName("diamondImg"):setVisible(false)
        local diamondNum = self._des1Bg:getChildByFullName("diamondNum")
        
        local itemId = honorD.diamond[2] or 301303
        local itemCount = honorD.diamond[3] or 301303
        if honorD.diamond[1] ~= "tool" then
            print("找策划，奖励配置错了")
            itemId = 301303
            itemCount = 0
        end

        diamondNum:setString(itemCount)

        local sysItem = tab:Tool(itemId)
        local _item = IconUtils:createItemIconById({itemId = itemId, itemData = sysItem})
        _item:setAnchorPoint(cc.p(0.5, 0.5))
        _item:setPosition(cc.p(diamondImg:getPosition()))
--        self._sysItem:setContentSize(cc.size(42, 42))
        _item:setScale(0.3)
        diamondImg:getParent():addChild(_item)

        local currencyNum = self._des1Bg:getChildByFullName("currencyNum")
        currencyNum:setString(honorD.honorCertificate or 0)

    end
end

function GloryArenaRuleDialog:generateRanks()
    local itemH,itemW = self._rankCell:getContentSize().height,self._rankCell:getContentSize().width
    local arenaHonor = clone(tab["honorArenaAward"])
    local bgHeight = (#arenaHonor)*itemH
    for i,rankD in ipairs(arenaHonor) do
        local item = self._rankCell:clone()
        item:setVisible(true)
        item:setPosition(cc.p(-25,itemH*(i-1)-3))
        if i%2 == 1 then
            item:getVirtualRenderer():setVisible(false)
        end
        ---[[ 用数据初始化item
        local rankRange = item:getChildByFullName("rankRange")
        local pos = rankD.pos
        local rankStr = "第" .. getRange(pos[1],pos[2]) .. "名"
        -- rankRange:setFontSize(22)
        rankRange:setString(rankStr)

        
        
        local diamondImg = item:getChildByFullName("diamondImg"):setVisible(false)

        local itemId = rankD.diamond[2] or 301303
        local itemCount = rankD.diamond[3] or 301303
        if rankD.diamond[1] ~= "tool" then
            print("找策划，奖励配置错了")
            itemId = 301303
            itemCount = 0
        end


        local goldImg = item:getChildByFullName("goldImg")
        goldImg:ignoreContentAdaptWithSize(false)
        goldImg:loadTexture("globalImageUI_texp.png", ccui.TextureResType.plistType) 
        local currencyImg = item:getChildByFullName("currencyImg")       
        currencyImg:ignoreContentAdaptWithSize(false)
        currencyImg:loadTexture("globalImageUI_gloryArenaIcon_min.png", ccui.TextureResType.plistType)

        local diamondNum = item:getChildByFullName("diamondNum")

        diamondNum:setString(itemCount)

        local sysItem = tab:Tool(itemId)
        local _item = IconUtils:createItemIconById({itemId = itemId, itemData = sysItem})
        _item:setAnchorPoint(cc.p(0.5, 0.5))
        _item:setPosition(cc.p(diamondImg:getPosition()))
--        self._sysItem:setContentSize(cc.size(42, 42))
        _item:setScale(0.3)
        diamondImg:getParent():addChild(_item)


        local goldNum = item:getChildByFullName("goldNum")
        goldNum:setString(rankD.texp or 0)
        local currencyNum = item:getChildByFullName("currencyNum")
        currencyNum:setString(rankD.honorCertificate or 0)
        --]]
        self._scrollBg:addChild(item)
    end
    -- 顶部描述
    local rtxStr = "[color=8a5c1d,fontsize=18]竞技场每日[color=8a5c1d,fontsize=18]21:00[-]结算奖励，奖励将通过邮件发放。[-]"
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
function GloryArenaRuleDialog:reflashUI(data)

end

return GloryArenaRuleDialog


--endregion
