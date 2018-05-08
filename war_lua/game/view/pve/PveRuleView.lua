--
-- Author: zhaoyang
-- Date: 2016-06-12 18:57:00
--
--
-- Author: zhaoyang
-- Date: 2016-06-12 16:15:58
-- description ： 该类 是奖励说明需要传入参数
-- 其中 viewType 1：是矮人， 2是墓穴
local PveRuleView = class("PveRuleView", BasePopView)
PveRuleView.kViewTypeAiRenMuWu = 1
PveRuleView.kViewTypeZombie = 2
local stringTable = {
	{
	title = "规则说明",
	des1  = "矮人宝屋结算奖励",
	des2  = "矮人宝屋战斗规则",
	rtxTopStr = lang("RULE_DWARF_SUP"),--"[color=462800]矮人宝屋每周一[color=462800]05:00[-]结算排名奖励，奖励将通过邮件发放。[-]",
	des = lang("RULE_DWARF"),
    rewardImg = "goldImg",
    bossId = "4",
    rankName =""
	},
	{
	title = "规则说明",
	des1  = "阴森墓穴结算奖励",
	des2  = "阴森墓穴战斗规则",
	rtxTopStr = lang("RULE_CRYPT_SUP"),--"[color=462800]阴森墓穴每周一[color=462800]05:00[-]结算排名奖励，奖励将通过邮件发放。[-]",
	des = lang("RULE_CRYPT"),
    rewardImg = "texpImg",
    bossId = "5"
	}
}
function PveRuleView:ctor(params)
    PveRuleView.super.ctor(self)
    self._viewType = params.viewType
    -- 默认是有两个奖励，以后变动的时候只需要改变item的种类即可变成一种奖励
    self._ItemType =1 
    self._bossModel = self._modelMgr:getModel("BossModel")

    local pveData = self._bossModel:getDataByPveId(stringTable[self._viewType].bossId)
    if pveData then
        self.rank = pveData.rank or 0
    else
        self.rank = 0
    end
end

function PveRuleView:onInit()
    local viewtype = self._viewType
    self._scrollView = self:getUI("bg.scrollView")
    self._scrollView:setBounceEnabled(true)
    self._des1Bg = self:getUI("bg.scrollView.des1Bg")
    self._title = self:getUI("bg.headBg.title")
    self._title:setString(stringTable[self._viewType].title)
    UIUtils:setTitleFormat(self._title, 6)
    self._scrollBg = self:getUI("bg.scrollView.scrollBg")
    -- self._ruleBg = self:getUI("bg.scrollView.ruleBg")
    self._rankCell = self:getUI("bg.rankCell" .. self._ItemType)
    -- self._titleBg = self:getUI("bg.scrollView.titlebg") 

    self._rankCell:setVisible(false)

    local currRankTxt = self:getUI("bg.scrollView.des1Bg.des1")
    currRankTxt:setFontName(UIUtils.ttfName)
    currRankTxt:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    currRankTxt:setString("当前排名")
    local currRewardTxt = self:getUI("bg.scrollView.des1Bg.des3")
    currRewardTxt:setFontName(UIUtils.ttfName)
    currRewardTxt:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    currRewardTxt:setString("当前排名奖励")
    local txtrank = self:getUI("bg.scrollView.des1Bg.rank")
    txtrank:setFontName(UIUtils.ttfName)
    txtrank:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    -- self.rank = 100 
    -- self.rank = self._bossModel:getData()[bossId].rank or 0
    local rewardNum = self:getUI("bg.scrollView.des1Bg.rewardNum")
    rewardNum:setFontName(UIUtils.ttfName)
    rewardNum:setString(0)
    rewardNum:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    if self.rank == 0 then
        txtrank:setString("暂无排名")
    else
        txtrank:setString(tostring(self.rank))
    end
    
    -- txtrank:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    txtrank:setPositionX(currRankTxt:getPositionX()+currRankTxt:getContentSize().width+2)


    local maxHeight = 20 --self._scrollView:getInnerContainerSize().height
    maxHeight = maxHeight+self._des1Bg:getContentSize().height
    local scrollW = self._scrollView:getInnerContainerSize().width

    -- 增加抬头
    local des1 = ccui.Text:create()
    des1:setFontSize(24)
    des1:setFontName(UIUtils.ttfName)
    des1:setString(stringTable[self._viewType].des1)
    des1:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    des1:setAnchorPoint(cc.p(0,0))
    maxHeight=maxHeight+des1:getContentSize().height+5
    self._scrollView:addChild(des1)

    local des2 = ccui.Text:create()
    des2:setFontSize(24)
    des2:setFontName(UIUtils.ttfName)
    des2:setString(stringTable[self._viewType].des2)
    des2:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    des2:setAnchorPoint(cc.p(0,0))
    maxHeight=maxHeight+des2:getContentSize().height
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
    local h = rtx:getVirtualRendererSize().height+30
    rtx:setName("rtx")
    self._scrollView:addChild(rtx)
    maxHeight = maxHeight+h
    -- self._ruleBg:setContentSize(cc.size(447,h))

    local scrollBgH = nil 
    if PveRuleView.kViewTypeAiRenMuWu == self._viewType then
      	scrollBgH = self:generateAiRenRanks()
    else
        scrollBgH = self:generateMuxueRanks()
    end
    maxHeight = maxHeight+scrollBgH

    self._scrollView:setInnerContainerSize(cc.size(scrollW,maxHeight))
    
    self._scrollBg:setPosition(cc.p(5,0))
    self._des1Bg:setPosition(cc.p(10,maxHeight-self._des1Bg:getContentSize().height+5))

    des1:setPosition(cc.p(20,scrollBgH+5))
    des2:setPosition(cc.p(20,maxHeight-self._des1Bg:getContentSize().height - 45))

    rtx:setPosition(cc.p(-w* 0.5+20,scrollBgH+des1:getContentSize().height+30))

    local rewardImg = self:getUI("bg.scrollView.des1Bg.".. stringTable[self._viewType].rewardImg)
    rewardImg:loadTexture("globalImageUI_diamond.png",1)
    rewardImg:setVisible(true)

    -- self:reflashTitleInfo()

    --顶部描述
    -- local rtxStr = "[color=3d1f00,outlinecolor = 241b1200,outlinesize = 2]竞技场每日[color=c6b46a,outlinecolor = 241b1200,
    								-- outlinesize = 2]22:00[-]结算奖励，奖励将通过邮件发放。[-]"

    self:registerClickEventByName("bg.closeBtn", function()
        self:close()
        UIUtils:reloadLuaFile("pve.PveRuleView")
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
function PveRuleView:generateAiRenRanks()
    local itemH,itemW = self._rankCell:getContentSize().height,self._rankCell:getContentSize().width
    local dwarfWeeklyReward = clone(tab["dwarfWeeklyReward"])
    local bgHeight = (#dwarfWeeklyReward)*itemH
    -- dump(dwarfWeeklyReward, "dwarfWeeklyReward")

    for i,rankD in ipairs(dwarfWeeklyReward) do
        local item = self._rankCell:clone()
        item:setVisible(true)
        print(i .. " itemH*(i)-3)" .. itemH*(i-1)-3 )
        item:setPosition(cc.p(-20,itemH*(i-1)-3))
        if i%2 == 1 then
            item:getVirtualRenderer():setVisible(false)
        end
        ---[[ 用数据初始化item
        -- local rewardImg = self:getUI("bg.rankCell1." .. stringTable[self._viewType].rewardImg)
        -- rewardImg:setVisible(true)
        local rankRange = item:getChildByFullName("rankRange")
        rankRange:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        local pos = rankD.pos
        local award = rankD.award
        local rankStr = "第" .. getRange(pos[1],pos[2]) .. "名"      
        -- rankRange:setFontSize(22)
        rankRange:setString(rankStr)
	        -- local diamondNum = item:getChildByFullName("diamondNum")
	        -- diamondNum:enableOutline(cc.c4b(36,27,18,255),2)
	        -- diamondNum:setString(curRankData.diamond or 0)

	        local physicalNum = item:getChildByFullName("physicalNum")
            physicalNum:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
            -- physicalNum:enableOutline(cc.c4b(36,27,18,255),2)
	        physicalNum:setString(award[1][3] or 10)
	        -- local currencyNum = item:getChildByFullName("currencyNum")
	        -- currencyNum:enableOutline(cc.c4b(36,27,18,255),2)
	        -- currencyNum:setString(curRankData.currency or 0)
	        -- --]]
	        self._scrollBg:addChild(item)   
    end
    -- 初始化 rank范围 
    self:initAiRenRankRange(dwarfWeeklyReward)

    -- 顶部描述
    -- local rtxStr = "[color=3d1f00,outlinecolor = 241b1200,outlinesize = 2]矮人宝屋每日[color=c6b46a,outlinecolor = 241b1200,outlinesize = 2]5:00[-]结算奖励，奖励将通过邮件发放。[-]"
	local topDes = RichTextFactory:create(stringTable[self._viewType].rtxTopStr,400,height)
    topDes:formatText()
    topDes:setVerticalSpace(3)
    topDes:setAnchorPoint(cc.p(0,0))
	local w = topDes:getInnerSize().width
    local h = topDes:getVirtualRendererSize().height
    topDes:setName("topDes")
    topDes:setPosition(cc.p(-w*0.5+15,bgHeight))
    self._scrollBg:addChild(topDes)
    bgHeight = bgHeight+h
    self._scrollBg:setContentSize(cc.size(itemW,bgHeight - 2))
    self._scrollBg:setBackGroundImageCapInsets(cc.rect(217,30,1,1))
    return bgHeight
end

function PveRuleView:generateMuxueRanks()
    local itemH,itemW = self._rankCell:getContentSize().height,self._rankCell:getContentSize().width
    local cryptWeeklyReward = clone(tab["cryptWeeklyReward"])
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
        local award = rankD.award 
        local physicalNum = item:getChildByFullName("physicalNum")
        physicalNum:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        -- physicalNum:enableOutline(cc.c4b(36,27,18,255),2)
        physicalNum:setString(award[1][3] or 10)
       
        self._scrollBg:addChild(item)   
    end
    self:initMuXueRankRange(cryptWeeklyReward)
    -- 顶部描述
    -- local rtxStr = "[color=3d1f00,outlinecolor = 241b1200,outlinesize = 2]矮人宝屋每日[color=c6b46a,outlinecolor = 241b1200,outlinesize = 2]5:00[-]结算奖励，奖励将通过邮件发放。[-]"
    local topDes = RichTextFactory:create(stringTable[self._viewType].rtxTopStr,400,height)
    topDes:formatText()
    topDes:setVerticalSpace(3)
    topDes:setAnchorPoint(cc.p(0,0))
        local w = topDes:getInnerSize().width
    local h = topDes:getVirtualRendererSize().height
    topDes:setName("topDes")
    topDes:setPosition(cc.p(-w*0.5+15,bgHeight))
    self._scrollBg:addChild(topDes)
    bgHeight = bgHeight+h
    self._scrollBg:setContentSize(cc.size(itemW,bgHeight - 2))
    self._scrollBg:setBackGroundImageCapInsets(cc.rect(217,30,1,1))
    return bgHeight
end

function PveRuleView:initAiRenRankRange( data )
    -- local dwarfWeeklyReward = clone(tab["dwarfWeeklyReward"])
    -- local txtrankRange = self:getUI("bg.scrollView.des1Bg.rankRange")
     for i,rankD in ipairs(data) do
        local pos = rankD.pos
        if self.rank >= pos[1] and self.rank <= pos[2] then
            -- txtrankRange:setString("(" .. pos[1] .. "-" .. pos[2] .. ")")
            local award = rankD.award 
            local txtrank = self:getUI("bg.scrollView.des1Bg.rewardNum")
            txtrank:setString(award[1][3] or 10)
            return 
        end
     end 
end

function PveRuleView:initMuXueRankRange( data )
    -- local txtrankRange = self:getUI("bg.scrollView.des1Bg.rankRange")
    -- local txtrankRange = self:getUI("bg.scrollView.des1Bg.rankRange")
     for i,rankD in ipairs(data) do
        local pos = rankD.pos
        if self.rank == 0  then
            local txtrank = self:getUI("bg.scrollView.des1Bg.rewardNum")
            local pos = data[#data].pos
            txtrank:setString("0")
        end
        if self.rank >= pos[1] and self.rank <= pos[2] then
            -- txtrankRange:setString("(" .. pos[1] .. "-" .. pos[2] .. ")")
            local award = rankD.award 
            local txtrank = self:getUI("bg.scrollView.des1Bg.rewardNum")
            txtrank:setString(award[1][3] or 10)
            return 
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

function PveRuleView.dtor()
    stringTable = nil
end

return PveRuleView