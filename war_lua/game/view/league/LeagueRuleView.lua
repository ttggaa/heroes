--[[
    Filename:    LeagueRuleView.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2016-08-16 16:19:03
    Description: File description
--]]

local LeagueRuleView = class("LeagueRuleView",BasePopView)
function LeagueRuleView:ctor(param)
    self.super.ctor(self)
    self._showAwardFirst = param.showAwardFirst
end

-- 初始化UI后会调用, 有需要请覆盖
function LeagueRuleView:onInit()
	self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("league.LeagueRuleView")
    end)

    self._scrollView = self:getUI("bg.scrollView")
    self._scrollView:setBounceEnabled(true)
    self._des1Bg = self:getUI("bg.scrollView.des1Bg")
    self._des2Bg = self:getUI("bg.scrollView.des2Bg")
    self._des3Bg = self:getUI("bg.scrollView.des3Bg")
    self._title = self:getUI("bg.headBg.title")
    -- self._title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    -- self._title:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._title,6)
    self._scrollBg = self:getUI("bg.scrollView.scrollBg")
    self._ruleBg = self:getUI("bg.scrollView.ruleBg")
    self._rankCell = self:getUI("bg.rankCell")


    local diamondImg = self:getUI("bg.scrollView.des1Bg.diamondImg")   
    diamondImg:setPositionY(diamondImg:getPositionY()-3)       
    local scaleNum1 = math.floor((32/diamondImg:getContentSize().width)*100)
    diamondImg:setScale(scaleNum1/100)
    local goldImg = self._des1Bg:getChildByFullName("goldImg")  
    goldImg:setPositionY(goldImg:getPositionY()-2)         
    goldImg:setScale(scaleNum1/100)
    local currencyImg = self._des1Bg:getChildByFullName("currencyImg") 
    currencyImg:setPositionY(currencyImg:getPositionY()-2)         
    currencyImg:setScale(scaleNum1/100)

    local goldNum = self:getUI("bg.scrollView.des1Bg.goldNum")
    goldNum:setPosition(goldImg:getPositionX()+goldImg:getContentSize().width*scaleNum1/100/2+5,goldImg:getPositionY()) 
    local diamondNum = self:getUI("bg.scrollView.des1Bg.diamondNum")
    diamondNum:setPosition(diamondImg:getPositionX()+diamondImg:getContentSize().width*scaleNum1/100/2+5,diamondImg:getPositionY()) 
    local currencyNum = self:getUI("bg.scrollView.des1Bg.currencyNum")
    currencyNum:setPosition(currencyImg:getPositionX()+currencyImg:getContentSize().width*scaleNum1/100/2+5,currencyImg:getPositionY()) 

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
    -- currRankTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    currRankTxt:setFontName(UIUtils.ttfName)

    local txtpoint = self:getUI("bg.scrollView.des1Bg.point")
    txtpoint:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    txtpoint:setFontName(UIUtils.ttfName)
    txtpoint:setPositionX(currRankTxt:getPositionX()+currRankTxt:getContentSize().width+2)

    local txtdes2 = self:getUI("bg.scrollView.des1Bg.des2")
    -- txtdes2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    txtdes2:setFontName(UIUtils.ttfName)
    -- txtdes2:setPositionX(txtpoint:getPositionX()+txtpoint:getContentSize().width+2)

    local txttopRank = self:getUI("bg.scrollView.des1Bg.topRank")
    txttopRank:setColor(cc.c3b(70, 40, 0))
    -- txttopRank:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    txttopRank:setFontName(UIUtils.ttfName)
    txttopRank:setPositionX(txtdes2:getPositionX()+txtdes2:getContentSize().width+2)

    local txtdes3 = self:getUI("bg.scrollView.des1Bg.des3")
    -- txtdes3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    txtdes3:setFontName(UIUtils.ttfName)

    local txtrankRange = self:getUI("bg.scrollView.des1Bg.rankRange")
    -- txtrankRange:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    txtrankRange:setFontName(UIUtils.ttfName)

    self:reflashTitleInfo()
    local maxHeight = 0 --self._scrollView:getInnerContainerSize().height
    -- maxHeight = maxHeight+self._title:getContentSize().height
    maxHeight = maxHeight+self._des1Bg:getContentSize().height
    maxHeight = maxHeight+self._des2Bg:getContentSize().height
    maxHeight = maxHeight+self._des3Bg:getContentSize().height
    local scrollW = self._scrollView:getInnerContainerSize().width
    -- 增加抬头
    local des1 = self._textPro:clone()
    des1:setString("赛季奖励")
    des1:setFontName(UIUtils.ttfName)
    des1:setFontSize(24)
    des1:setTextColor(cc.c4b(70,40,0,255))
    -- des1:setOpacity(200)
    des1:setAnchorPoint(cc.p(0,0))
    -- des1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    maxHeight=maxHeight+des1:getContentSize().height+5
    self._scrollView:addChild(des1)

    local des2 = self._textPro:clone()
    des2:setString("基本规则")
    des2:setFontSize(24)
    des2:setFontName(UIUtils.ttfName)
    des2:setTextColor(cc.c4b(70,40,0,255))
    -- des2:setOpacity(200)
    -- des2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    maxHeight=maxHeight+des2:getContentSize().height+20
    self._scrollView:addChild(des2)

    -- 增加富文本 FF462800
	local rtxStr = lang("RULE_LEAGUE")  --lang("RULE_ARENA")
    rtxStr = string.gsub(rtxStr,"ffffff","462800")
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
    self._des2Bg:setPosition(cc.p(0,maxHeight-self._des1Bg:getContentSize().height-self._des2Bg:getContentSize().height+5))
    self._des3Bg:setPosition(cc.p(0,maxHeight-self._des1Bg:getContentSize().height-self._des2Bg:getContentSize().height-self._des3Bg:getContentSize().height+5))

    des1:setPosition(cc.p(10,scrollBgH))
    des2:setPosition(cc.p(10,maxHeight-self._des1Bg:getContentSize().height-self._des2Bg:getContentSize().height-self._des3Bg:getContentSize().height-15))

    rtx:setPosition(cc.p(-w* 0.5+10,scrollBgH+des1:getContentSize().height+28))
    self._ruleBg:setPosition(-5,scrollBgH+des1:getContentSize().height+15)

    -- self:reflashTitleInfo()
end

function LeagueRuleView:reflashAwardImg( node,awards )
    if not node or not awards then return end
    local images = {}
    local awardNum = {}
    if awards then
        for i,v in ipairs(awards) do
            if v[1] == "tool" and v[2] ~= 3002 and v[2] ~= 3004 then
                local toolD = tab:Tool(v[2])
                local filename = IconUtils.iconPath .. toolD.art .. ".png"
                local sfc = cc.SpriteFrameCache:getInstance()
                if not sfc:getSpriteFrameByName(filename) then
                    filename = IconUtils.iconPath .. toolD.art .. ".jpg"
                end
                table.insert(images,filename)
            elseif v[2] == 3002 then
                table.insert(images,"globalImageUI_herosplice1.png")
            elseif v[2] == 3004 then
                table.insert(images,"globalImageUI_fashujuanzhou.png")
            else
                table.insert(images,IconUtils.resImgMap[v[1]])
            end
            table.insert(awardNum,v[3])
        end
    end
    local goldImg = node:getChildByFullName("goldImg")
    goldImg:loadTexture(images[1],1) 
    goldImg:setScale(math.floor((32/goldImg:getContentSize().width)*100)/100) 
    local diamondImg = node:getChildByFullName("diamondImg")
    diamondImg:loadTexture(images[2],1)
    diamondImg:setScale(math.floor((32/diamondImg:getContentSize().width)*100)/100)
    local currencyImg = node:getChildByFullName("currencyImg") 
    currencyImg:loadTexture(images[3],1)
    currencyImg:setScale(math.floor((32/currencyImg:getContentSize().width)*100)/100)

    local goldNum = node:getChildByFullName("goldNum")
    -- goldNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    goldNum:setString(awardNum[1] or 0)
    local diamondNum = node:getChildByFullName("diamondNum")
    -- diamondNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    diamondNum:setString(awardNum[2] or 0)
    local currencyNum = node:getChildByFullName("currencyNum")
    -- currencyNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    currencyNum:setString(awardNum[3] or 0)

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

function LeagueRuleView:getInRangeData( rank )
    local leagueHonor = tab["leagueHonor"]
    for i,honorD in ipairs(leagueHonor) do
        local low,high = honorD.pos[1],honorD.pos[2]
        if rank >= low and rank <= high then
            return honorD
        end
    end
end

function LeagueRuleView:reflashTitleInfo()
    local leagueD = self._modelMgr:getModel("LeagueModel"):getData()
    local curRankData = tab:LeagueRank(leagueD.league.currentZone or 1)
    local ranknum = leagueD.rank or 10000
    local topStageData = self:getStageByScore((leagueD.historyScore or 0))
    local txtdes2 = self:getUI("bg.scrollView.des1Bg.des2")
    -- txtdes2:setPositionX(pointLab:getPositionX()+pointLab:getContentSize().width+2)  
    local topRank = self._des1Bg:getChildByFullName("topRank")
    topRank:setString(leagueD.historyRank or ranknum)    
    topRank:setPositionX(txtdes2:getPositionX()+txtdes2:getContentSize().width+2)
    local stage = self:getUI("bg.scrollView.des1Bg.stage")
    stage:setFontName(UIUtils.ttfName)
    stage:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    stage:setColor(cc.c3b(250, 242, 192))
    stage:enable2Color(1,cc.c4b(255, 195, 17, 255))
    -- stage:setString(lang(curRankData.name) or "")
    stage:setString(lang(topStageData.name) or "")
    local pointLab = self._des1Bg:getChildByFullName("point")
    pointLab:setString("(" .. math.max( (leagueD.historyScore or 0),(leagueD.league.currentPoint or 0) ).. ")")
    pointLab:setPositionX(stage:getPositionX()+stage:getContentSize().width+2)
    local honorD = self:getInRangeData(leagueD.historyRank or ranknum)
    if honorD then
        local rankRange = self._des1Bg:getChildByFullName("rankRange")
        rankRange:setString("(" .. getRange(honorD.pos[1],honorD.pos[2]) .. ")")
        if honorD.monthlyawards then
            self:reflashAwardImg(self._des1Bg,honorD.monthlyawards)
        end
    end
    -- 刷新des2bg
    local curStage = self:getUI("bg.scrollView.des2Bg.stage")
    curStage:setFontName(UIUtils.ttfName)
    curStage:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    curStage:setColor(cc.c3b(250, 242, 192))
    curStage:enable2Color(1,cc.c4b(255, 195, 17, 255))
    curStage:setString(lang(curRankData.name) or "")

    local curPointLab = self._des2Bg:getChildByFullName("point")
    curPointLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    curPointLab:setString("(" .. (leagueD.league.currentPoint or 0) .. ")")
    curPointLab:setPositionX(curStage:getPositionX()+curStage:getContentSize().width+2)

    local serverTitle = self._des3Bg:getChildByFullName("serverTitle")
    serverTitle:setColor(cc.c3b(70, 40, 0))
    -- serverTitle:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    local serverListLab = self._des3Bg:getChildByFullName("serverListLab")
    serverListLab:setVisible(false)
    local serverListStr = ""
    if leagueD.league then
    	-- dump(leagueD.league.leagueRivalList.rival)
	    serverListStr = self._modelMgr:getModel("LeagueModel"):getServerList() --self:getServerList( leagueD.league.leagueRivalList.rival )
	end
    if serverListStr == "" or serverListStr == "暂无" then
        self._des3Bg:setVisible(false)
        self._des3Bg:setContentSize(cc.size(self._des3Bg:getContentSize().width, 0))
    end
    self:reflashAwardImg(self._des2Bg,curRankData.weeklyawards)

    -- serverListLab:setString(serverListStr)
    -- serverListLab:setAnchorPoint(0,1)
    -- serverListLab:setPosition(10,30)
    -- serverListLab:setLineBreakWithoutSpace(true)
    -- serverListLab:getVirtualRenderer():setMaxLineWidth(400)

    --add by wangyan 改用richtext label中文空格换行有问题
    local tempDes = "[color=7a5237,fontsize=22]" .. serverListStr .."[-]"
    local serverDes = RichTextFactory:create(tempDes, 400, 0)
    serverDes:setPixelNewline(true)
    serverDes:formatText()
    self:getUI("bg.scrollView.des3Bg"):addChild(serverDes)

    local rtPosX = serverTitle:getPositionX() - serverTitle:getContentSize().width * 0.5 + serverDes:getContentSize().width * 0.5 + 1
    local rtPosY = serverTitle:getPositionY() - serverTitle:getContentSize().height * 0.5 - serverDes:getRealSize().height * 0.5 - 8
    serverDes:setPosition(rtPosX, rtPosY)

    local listHeigth = serverDes:getRealSize().height
    local childrenOffsetY = 0
    if listHeigth > 25  then
        childrenOffsetY = listHeigth-25
        self._des3Bg:setContentSize(cc.size(self._des3Bg:getContentSize().width,
        self._des3Bg:getContentSize().height + childrenOffsetY))
    end
    -- self:registerClickEventByName("bg.scrollView.des1Bg.tipBtn1",function( )
    --     self._scrollView:scrollToPercentVertical(89, 0, false)
    -- end)
    -- self:registerClickEventByName("bg.scrollView.des2Bg.tipBtn2",function( )
    --     self._viewMgr:showDialog("league.LeagueStageView",{},true)
    -- end)
    self:getUI("bg.scrollView.des1Bg.tipBtn1"):setVisible(false)
    self:getUI("bg.scrollView.des2Bg.tipBtn2"):setVisible(false)
    if childrenOffsetY > 0 then
        local children = self._des3Bg:getChildren()
        for k,v in pairs(children) do
            v:setPositionY(v:getPositionY()+childrenOffsetY)
        end
    end
    if self._showAwardFirst then
        self._scrollView:scrollToPercentVertical(88, 0, false)
    end
end

function LeagueRuleView:getStageByScore(score)
    local rankData = tab.leagueRank
    -- for k,v in pairs(rankData) do
    local id = 1
    for i=1,#rankData do
        local v = rankData[i] 
        -- print("======================",score,v.gradeup)
        if  tonumber(score) < tonumber(v.gradeup) then
            id = i
            break
        end
    end
    return rankData[id]

end

function LeagueRuleView:getServerList( scrStr )
	local strArr = string.split(scrStr,",")
	local str = ""
	local uniqueAr = {}
	for k,v in pairs(strArr) do
		local tempAr = string.split(v,"-")
		if tempAr and tempAr[1] then
			uniqueAr[tempAr[1]] = tempAr[1]
		end
	end
	for k,v in pairs(uniqueAr) do
		if str == "" then
			str = str .. v .. "区"
		else
			str = str .. "区," .. v .. "区"
		end
	end
    if str == "" or str == " " then 
        str = "暂无"
    end
	return str
end

function LeagueRuleView:generateRanks()
    local itemH,itemW = self._rankCell:getContentSize().height,self._rankCell:getContentSize().width
    local leagueHonor = clone(tab["leagueHonor"])
    local bgHeight = (#leagueHonor)*itemH
    for i,rankD in ipairs(leagueHonor) do
        local item = self._rankCell:clone()
        item:setVisible(true)
        item:setPosition(cc.p(-25,bgHeight - itemH*i-3))
        if i%2 == 1 then
            item:getVirtualRenderer():setVisible(false)
        end
        ---[[ 用数据初始化item
        local rankRange = item:getChildByFullName("rankRange")
        local pos = rankD.pos
        local rankStr = "第" .. getRange(pos[1],pos[2]) .. "名"
        -- rankRange:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)        
        -- rankRange:setFontSize(22)
        rankRange:setString(rankStr)

        self:reflashAwardImg(item,rankD.monthlyawards)
        self._scrollBg:addChild(item)
    end
    -- 顶部描述
    local rtxStr =  "[color=865c30]" .. lang("LEAGUETIP_02") .."[-]"
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
function LeagueRuleView:reflashUI(data)

end

return LeagueRuleView