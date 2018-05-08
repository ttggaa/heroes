--
-- Author: huangguofang
-- Date: 2017-02-15 15:39:38
--
local HeroBiographyRuleDialog = class("HeroBiographyRuleDialog", BasePopView)

function HeroBiographyRuleDialog:ctor()
    HeroBiographyRuleDialog.super.ctor(self)
end


function HeroBiographyRuleDialog:onInit()
  
    local title = self:getUI("bg.titlebg.title")
    UIUtils:setTitleFormat(title, 6)
   
    self._scrollView = self:getUI("bg.ScrollView")
    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("hero.HeroBiographyRuleDialog")
    end)
end

function HeroBiographyRuleDialog:reflashUI()
    local str = lang("RULE_HEROBIO") 
    if string.find(str, "color=") == nil then
        str = "[color=000000]".. str .."[-]"
    end
    self._scrollViewW = self._scrollView:getContentSize().width
    local heroData = tab.hero
    -- 获取已开放英雄传记的英雄信息
    local heroBioTb = {}
    for k,v in pairs(heroData) do
    	if v.heroBioID then
    		table.insert(heroBioTb,v)
    	end
    end

   	local heroIconH = 105
    local iconNum = 4
    local iconBgH = math.ceil(#heroBioTb/iconNum)*heroIconH + 20
    local iconBgW = 110 * iconNum 
    local height  = self._scrollView:getContentSize().height
    local heightMax = iconBgH + 20 -- 20 间距校正

    -- local ruleDes = ccui.Text:create()
    -- ruleDes:setFontSize(24)
    -- ruleDes:setFontName(UIUtils.ttfName)
    -- ruleDes:setColor(cc.c4b(130,85,40,255))
    -- ruleDes:setAnchorPoint(0,1)    
    -- ruleDes:setString("基本规则：")
    -- self._scrollView:addChild(ruleDes)
    -- heightMax = heightMax + 30
   
    local richText = RichTextFactory:create(str, self._scrollViewW, 0)
    richText:formatText()
    self._scrollView:addChild(richText)
    heightMax = heightMax + richText:getRealSize().height

 --    local ruleDes2 = ccui.Text:create()
 --    ruleDes2:setFontSize(24)
 --    ruleDes2:setFontName(UIUtils.ttfName)
 --    ruleDes2:setColor(cc.c4b(130,85,40,255))
 --    ruleDes2:setAnchorPoint(0,1)    
 --    ruleDes2:setString("已开放传记功能的英雄：")
 --    self._scrollView:addChild(ruleDes2)
	-- heightMax = heightMax + 30

	-- contentsizeH
    if height > heightMax then
        heightMax = height
    end
    self._scrollView:setInnerContainerSize(cc.size(self._scrollViewW, heightMax))
    -- ruleDes:setPosition(0,heightMax - 5)
    local posY = heightMax - richText:getRealSize().height/2 --- ruleDes:getContentSize().height
    richText:setPosition(self._scrollViewW/2,posY)
    posY = heightMax - richText:getRealSize().height + 20 --- ruleDes:getContentSize().height
    -- ruleDes2:setPosition(0,posY)

    -- 英雄iconpanel 
    local iconBgImg = ccui.ImageView:create()
    iconBgImg:loadTexture("globalPanelUI7_innerBg3.png",1)
    iconBgImg:setAnchorPoint(0,1)
    iconBgImg:setName("iconBgImg")
    iconBgImg:setContentSize(iconBgW,iconBgH)
    iconBgImg:setScale9Enabled(true)
    iconBgImg:setCapInsets(cc.rect(25,25,1,1))
    iconBgImg:setPosition((self._scrollViewW-iconBgW)*0.5, posY - 30)
    self._scrollView:addChild(iconBgImg)
    
    local itemX = (self._scrollViewW-iconBgW)*0.5 + heroIconH*0.5 + 10
    local itemY = posY - 30 + heroIconH * 0.5 - 10 
    for k,v in pairs(heroBioTb) do
        if 1 == tonumber(k) % iconNum then
            itemX = (self._scrollViewW-iconBgW)*0.5 + heroIconH*0.5 + 10 
            itemY = itemY - heroIconH 
        end
        v.hideFlag = true
        icon = IconUtils:createHeroIconById({sysHeroData = v})
        icon:setSwallowTouches(false)
        icon:setPosition(itemX, itemY)
        icon:setScale(0.8)
        self._scrollView:addChild(icon)

        itemX = itemX + heroIconH
    end

end

--[[
function HeroBiographyRuleDialog:createHeroCard(data,x,y)
	-- herobg	-- heroname
	local item = ccui.Layout:create()
	item:setAnchorPoint(0,0)
	item:setContentSize(556, 106)
    item:setTouchEnabled(true)
    item:setSwallowTouches(false)

    -- 标题
	local heroName = ccui.Text:create()
    heroName:setFontSize(24)
    heroName:setName("heroName")
    heroName:setFontName(UIUtils.ttfName)
    heroName:setString(lang(data.heroname))
    heroName:setColor(cc.c4b(70,40,0))
    heroName:setAnchorPoint(0,0.5)
    heroName:setPosition(x, y)
    item:addChild(heroName,1)
 	
 	-- 英雄卡
 	-- print("==============heroBg=",data["herobg"])
    local heroCardImg = ccui.ImageView:create()
    heroCardImg:loadTexture("asset/uiother/hero/"..data["herobg"]..".png",0)
    heroCardImg:setPosition(self._scrollViewW-5, y)
    heroCardImg:setName("heroCardImg")
    heroCardImg:setAnchorPoint(1,0.5)
    heroCardImg:setScale(0.7)
    item:addChild(heroCardImg)

    return item 
end
]]
return HeroBiographyRuleDialog