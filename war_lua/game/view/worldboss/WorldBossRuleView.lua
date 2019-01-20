--[[
    @FileName   WorldBossRuleView.lua
    @Authors    zhangtao
    @Date       2018-10-16 17:31:32
    @Email      <zhangtao@playcrad.com>
    @Description   描述
--]]
local WorldBossRuleView = class("WorldBossRuleView", BasePopView)

local stringTable = {
    {
    title = "规则说明",
    des1  = "",
    des2  = "",
    rtxTopStr1 = lang("worldBoss_Rules2"),--"[color=462800]阴森墓穴每周一[color=462800]05:00[-]结算排名奖励，奖励将通过邮件发放。[-]",
    rtxTopStr2 = lang("worldBoss_Rules3"),
    des = lang("worldBoss_Rules1"),
    rewardImg = "texpImg",
    reward1 = "worldBossRank",
    reward2 = "worldBossLeagueRank"
    }
}

function WorldBossRuleView:ctor()
    WorldBossRuleView.super.ctor(self)
    self._viewType = 1
    -- 默认是有两个奖励，以后变动的时候只需要改变item的种类即可变成一种奖励
    self._ItemType =1 
    self._worldBossModel = self._modelMgr:getModel("WorldBossModel")
    local bossInfo = self._worldBossModel:getBossInfo()
    self._myRankData = {}
    if bossInfo and bossInfo.pRank and next(bossInfo.pRank) and bossInfo.pRank.owner then
        self._myRankData = bossInfo.pRank.owner
    end
    self._hRank = 0
    if bossInfo and bossInfo.worldBoss and next(bossInfo.worldBoss) then
        self._hRank = bossInfo.worldBoss.hRank or 0
    end

    if next(self._myRankData) then
        self.rank = self._myRankData.rank or 0
    else
        self.rank = 0
    end
end

function WorldBossRuleView:onInit()
    local viewtype = self._viewType
    self._scrollView = self:getUI("bg.scrollView")
    self._scrollView:setBounceEnabled(true)
    self._des1Bg = self:getUI("bg.scrollView.des1Bg")
    self._title = self:getUI("bg.headBg.title")
    self._title:setString(stringTable[self._viewType].title)
    UIUtils:setTitleFormat(self._title, 6)
    local noDes = self._des1Bg:getChildByFullName("noDes")
    bgLayer = self:getUI("bg.scrollView.scrollBg")
    bgLayer:setPositionY(self._des1Bg:getPositionY())
    -- self._des1Bg:setVisible(false)
    -- self._ruleBg = self:getUI("bg.scrollView.ruleBg")
    self._rankCell = self:getUI("bg.rankCell" .. self._ItemType)
    -- self._titleBg = self:getUI("bg.scrollView.titlebg") 

    self._rankCell:setVisible(false)

    local currRankTxt = self:getUI("bg.scrollView.des1Bg.des1")
    currRankTxt:setFontName(UIUtils.ttfName)
    currRankTxt:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    currRankTxt:setString("当前排名:")


    local currRewardTxt = self:getUI("bg.scrollView.des1Bg.des3")
    currRewardTxt:setFontName(UIUtils.ttfName)
    currRewardTxt:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    currRewardTxt:setString("当前排名奖励")
    local txtrank = self:getUI("bg.scrollView.des1Bg.rank")
    txtrank:setFontName(UIUtils.ttfName)
    txtrank:setColor(UIUtils.colorTable.ccUIBaseTextColor1)

    local rewardNum = self:getUI("bg.scrollView.des1Bg.rewardNum")
    rewardNum:setFontName(UIUtils.ttfName)
    rewardNum:setString(0)
    rewardNum:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    if self.rank == 0 then
        noDes:setVisible(true)
        txtrank:setString("暂无排名")
    else
        txtrank:setString(tostring(self.rank))
        noDes:setVisible(false)
    end
    
    -- txtrank:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    txtrank:setPositionX(currRankTxt:getPositionX()+currRankTxt:getContentSize().width+2)


    local maxHeight = 20 --self._scrollView:getInnerContainerSize().height
    maxHeight = maxHeight+self._des1Bg:getContentSize().height
    local scrollW = self._scrollView:getInnerContainerSize().width

    local des2 = ccui.Text:create()
    des2:setFontSize(24)
    des2:setFontName(UIUtils.ttfName)
    des2:setString(stringTable[self._viewType].des2)
    des2:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    des2:setAnchorPoint(cc.p(0,0))
    local des2Height = des2:getContentSize().height
    maxHeight = maxHeight + des2Height
    self._scrollView:addChild(des2)


    -- 增加富文本
    -- local rtxStr = lang("RULE_DWARF")  --lang("RULE_ARENA")
    --    rtxStr = string.gsub(rtxStr,"ffffff","d49f66")
    local rtx = RichTextFactory:create(stringTable[self._viewType].des,380,height)
    rtx:setPixelNewline(true)
    rtx:formatText()
    rtx:setVerticalSpace(3)
    rtx:setAnchorPoint(cc.p(0,0))
    local w = rtx:getInnerSize().width
    local h = rtx:getVirtualRendererSize().height
    rtx:setName("rtx")
    self._scrollView:addChild(rtx)
    maxHeight = maxHeight+h
    -- self._ruleBg:setContentSize(cc.size(447,h))

    local scrollBgH =  self:createRankAwardList() 
    maxHeight = maxHeight+scrollBgH
    self._scrollView:setInnerContainerSize(cc.size(scrollW,maxHeight))

    bgLayer:setPositionY(0)
    self._des1Bg:setPosition(cc.p(10,maxHeight-self._des1Bg:getContentSize().height+5))
    des2:setPosition(cc.p(20,maxHeight - des2Height))
    rtx:setPosition(cc.p(-w* 0.5+20,scrollBgH + 20))

    -- local rewardImg = self:getUI("bg.scrollView.des1Bg.".. stringTable[self._viewType].rewardImg)
    -- rewardImg:loadTexture("globalImageUI_diamond.png",1)
    -- rewardImg:setVisible(true)

    self:registerClickEventByName("bg.closeBtn", function()
        self:close()
        UIUtils:reloadLuaFile("worldboss.WorldBossRuleView")
    end)
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

function WorldBossRuleView:createRankAwardList()
    local awardNode1 , h1 = self:generateMuxueRanks(1)
    local awardNode2 , h2 = self:generateMuxueRanks(2)
    bgLayer:setContentSize(cc.size(self._rankCell:getContentSize().width,h1 + h2))
    bgLayer:addChild(awardNode1)
    bgLayer:addChild(awardNode2)
    awardNode2:setPositionY(0)
    awardNode1:setPositionY(h2+10)
    return h1 + h2 + 10
end

function WorldBossRuleView:generateMuxueRanks(typeId)
    local bgLayer = ccui.Layout:create()
    bgLayer:setBackGroundColorOpacity(255)
    bgLayer:setBackGroundColorType(1)
    bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    bgLayer:setContentSize(100, 100)
    bgLayer:setOpacity(0)
    bgLayer:setAnchorPoint(0,0)
    local itemH,itemW = self._rankCell:getContentSize().height,self._rankCell:getContentSize().width
    local cryptWeeklyReward = clone(tab[stringTable[self._viewType]["reward"..typeId]])
    local bgHeight = (#cryptWeeklyReward)*itemH

    for i,rankD in ipairs(cryptWeeklyReward) do
       
        local item = self._rankCell:clone()
        item:setVisible(true)
        item:setPosition(cc.p(-20,itemH*(i-1)-3))
        if i%2 == 1 then
            item:getVirtualRenderer():setVisible(false)
        end
        --- 用数据初始化item
        local rankRange = item:getChildByFullName("rankRange")
        rankRange:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        local pos = rankD.pos
        local rankStr = "第" .. getRange(pos[1],pos[2]) .. "名"     
        rankRange:setString(rankStr)
        local award = rankD.reward 

        local num1 = item:getChildByFullName("physicalNum1")
        local num2 = item:getChildByFullName("physicalNum2")
        local num3 = item:getChildByFullName("physicalNum3")
        local img1 = item:getChildByFullName("diamondImg1")
        local img2 = item:getChildByFullName("diamondImg2")
        local img3 = item:getChildByFullName("diamondImg3")
        local nodeTab = {{numNode = num3,imgNode = img3},{numNode = num2,imgNode = img2},{numNode = num1,imgNode = img1}}
        self:createCellAward(nodeTab,award)

        -- local physicalNum = item:getChildByFullName("physicalNum")
        -- physicalNum:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        -- -- physicalNum:enableOutline(cc.c4b(36,27,18,255),2)
        -- physicalNum:setString(award[1][3] or 10)
       
        bgLayer:addChild(item)   
    end
    if typeId == 1 then
        self:initMuXueRankRange(cryptWeeklyReward)
    end
    -- 顶部描述
    -- local rtxStr = "[color=3d1f00,outlinecolor = 241b1200,outlinesize = 2]矮人宝屋每日[color=c6b46a,outlinecolor = 241b1200,outlinesize = 2]5:00[-]结算奖励，奖励将通过邮件发放。[-]"
    local topDes = RichTextFactory:create(stringTable[self._viewType]["rtxTopStr" .. typeId],400,height)
    topDes:formatText()
    topDes:setVerticalSpace(3)
    topDes:setAnchorPoint(cc.p(0,0))
    local w = topDes:getInnerSize().width
    local h = topDes:getVirtualRendererSize().height
    topDes:setName("topDes")
    topDes:setPosition(cc.p(-w*0.5+15,bgHeight))
    bgLayer:addChild(topDes)
    bgHeight = bgHeight+h
    bgLayer:setContentSize(cc.size(itemW,bgHeight - 2))
    -- bgLayer:setBackGroundImageCapInsets(cc.rect(217,30,1,1))
    return bgLayer,bgHeight
end

function WorldBossRuleView:createCellAward(nodeTab,award)    
    for k ,v in pairs(nodeTab) do
        if award[k] then
            v.numNode:setVisible(true)
            v.imgNode:setVisible(true)

            
            local itemType = award[k][1]
            local itemId = award[k][2]
            if itemType ~= "tool" then
                itemId = IconUtils.iconIdMap[itemType]
            end
            local toolD = tab.tool[itemId]
            if toolD and toolD.art then
                local filename = IconUtils.iconPath .. toolD.art .. ".png"
                local sfc = cc.SpriteFrameCache:getInstance()
                if not sfc:getSpriteFrameByName(filename) then
                    filename = IconUtils.iconPath .. toolD.art .. ".jpg"
                end
                v.imgNode:loadTexture(filename, 1)
            end
            -- local imageName = IconUtils.resImgMap[award[k][1]]
            v.numNode:setString(award[k][3])
            v.imgNode:setScale(0.35)
            -- v.imgNode:loadTexture(imageName,1)
            v.numNode:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        else
            v.numNode:setVisible(false)
            v.imgNode:setVisible(false)
        end
    end
end

function WorldBossRuleView:initMuXueRankRange( data )
    local num1 = self._des1Bg:getChildByFullName("rewardNum")
    local num2 = self._des1Bg:getChildByFullName("rewardNum1")
    local num3 = self._des1Bg:getChildByFullName("rewardNum2")
    local img1 = self._des1Bg:getChildByFullName("texpImg")
    local img2 = self._des1Bg:getChildByFullName("texpImg1")
    local img3 = self._des1Bg:getChildByFullName("texpImg2")
    
    local nodeTab = {{numNode = num1,imgNode = img1},{numNode = num2,imgNode = img2},{numNode = num3,imgNode = img3}}
    for i,rankD in ipairs(data) do
        local pos = rankD.pos
        if self.rank == 0  then
            self:createCellAward(nodeTab,{})
        else
            if self.rank >= pos[1] and self.rank <= pos[2] then
                -- txtrankRange:setString("(" .. pos[1] .. "-" .. pos[2] .. ")")
                local award = rankD.reward 
                self:createCellAward(nodeTab,award)
                return 
            end
        end
    end 
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

function WorldBossRuleView.dtor()
    stringTable = nil
end

return WorldBossRuleView