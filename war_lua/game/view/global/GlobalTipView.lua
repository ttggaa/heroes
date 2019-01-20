--[[
    Filename:    GlobalTipView.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-08-22 17:37:21
    Description: File description
--]]
--[[
	通用tip 参数 为table {} 内含下列内容
	tip类型  tipType 几个类型:1 有icon的,2 有title的,3 只是描述用的
	tip数据  {id=xx, des = {} or string }  
	位置     node  可传进去node节点, 自动计算位置或者ccpoint 
	
	额外参数1 teamData 技能阵营种族职业
--]]
--[[-- tip 类型  
1道具tip         
2专精、专长、法术tip
	3属性tip
4技能tip
5阵营tip
6种族tip
7职业tip
8兵团tip- todo
9 npc兵团
10 兵团生命攻击tip
11 英雄阵营(?)tip
12 boss tip
13 英雄技能cd tip
14 英雄耗魔 tip
15 宝物 详情 tip
16 纯显示内容
17 英雄初始魔法tip
18 英雄回魔tip
19 英雄回魔tip
20 宝物总属性tip
21 英雄法伤tip
22 配件Tip
23 攻城器械配件tip
24 攻城器械技能tip
25 圣徽tip
26 圣徽精通tip

--]]
local tab = tab
local raceMap = TeamUtils.getSameRaces()
local skillTp = {"主动技能","兵团被动","自动技能","开场技能","自动技能","英雄被动",}
local names
if lang then
    names = {lang("PLAYERSKILLTAG_1"), lang("PLAYERSKILLTAG_2"), lang("PLAYERSKILLTAG_3"), "", "", "", "", "", 
                    lang("PLAYERSKILLTAG_9")}
end

local GlobalTipView = class("GlobalTipView",BaseLayer)
function GlobalTipView:ctor(data)
    self.super.ctor(self)
    self:setSwallowTouches(false)
    self._panels = {}
    self._currentPanel = nil
    self._reflashFuncs = 
    {
    	self.reflashIconPanel,
    	self.reflashTitlePanel		--[[2]],
    	self.reflashDesPanel		--[[3]],
    	self.reflashRacePanel		--[[4]],
    	self.reflashMasteryPanel	--[[5]],
    	nil--[[6]],
    	self.reflashHeroAttrPanel	--[[7]],
    	self.reflashTeamAttrPanel	--[[8]],
    	self.reflashSkillCDAttrPanel--[[9]],
    	self.reflashTreasureTipPanel--[[10]],
    	self.reflashGuildEquipTipPanel--[[11]],
    	self.reflashHeroApTipPanel	--[[12]],
    	self.reflashHeroSkillMoralePanel	--[[13]],
    }
    self._raceIcons = {}
    -- 宽和高根据旋转相互转化 ..废弃
    self._tipBgH = 0
    self._tipBgW = 410
    self._skillTabMap = {
		tab.heroMastery,     
		tab.playerSkillEffect,  
		tab.skillPassive,   
		tab.skillCharacter,  
		tab.skillAttackEffect, 

	    tab.skill,
	}
    -- self._rotation = 90

    self._panelSizeH = 0
    self._desSizeH = 0
	self._adjustHeight = 0

    self._winSize = MAX_SCENE_WIDTH_PIXEL
    self._skillTalentModel = self._modelMgr:getModel("SkillTalentModel")

end

-- 第一次被加到父节点时候调用
function GlobalTipView:onAdd()

end
-- 初始化UI后会调用, 有需要请覆盖
function GlobalTipView:onInit()
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
        	if UIUtils ~= nil and UIUtils.reloadLuaFile ~= nil then
            	UIUtils:reloadLuaFile("global.GlobalTipView")
        	end
        elseif eventType == "enter" then 
        end
    end)   	
	self._iconPanel = self:getUI("bg.iconPanel")
	table.insert(self._panels,self._iconPanel) 		-- 1
	local name = self._iconPanel:getChildByName("name")
	name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	-- name:setColor(cc.c3b(255, 255, 255))
	-- name:setFontSize(22)
    self._bg = self:getUI("bg")

	self._titlePanel = self:getUI("bg.titlePanel")
	table.insert(self._panels,self._titlePanel) 	-- 2

	self._desPanel = self:getUI("bg.desPanel")
	table.insert(self._panels,self._desPanel) 		-- 3
	
	self._racePanel = self:getUI("bg.racePanel")
	table.insert(self._panels,self._racePanel) 		-- 4
	local name = self._racePanel:getChildByName("name")
	name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	-- name:setColor(cc.c3b(255, 255, 255))
	-- name:setFontSize(18)

	self._iconPanel = self:getUI("bg.iconPanel")
	table.insert(self._panels,self._iconPanel)		-- 5

	self._addtionPanel = self:getUI("bg.addtionPanel")
	table.insert(self._panels,self._addtionPanel)	-- 6
	self._addtionInitSize = self._addtionPanel:getContentSize()
	
	self._heroAttrPanel = 0 -- 延迟到刷新时创建
	table.insert(self._panels,self._heroAttrPanel)	-- 7
	
	self._teamAttrPanel = self:getUI("bg.teamAttrPanel")
	table.insert(self._panels,self._teamAttrPanel)	-- 8

	self._skillCdPanel = 0 -- 延迟到刷新创建  self:getUI("bg.heroAttrPanel") --self._heroAttrPanel:clone()
	-- self._skillCdPanel:setName("skillCdPanel")
	-- self._bg:addChild(self._skillCdPanel)
	table.insert(self._panels,self._skillCdPanel)	-- 9

	self._treasureTipPanel = 0 -- 延迟到刷新时创建
	table.insert(self._panels,self._treasureTipPanel)	-- 10

	self._guildEquipTipPanel = 0 -- 延迟到刷新时创建
	table.insert(self._panels,self._guildEquipTipPanel)	-- 11

	self._heroApTipPanel = 0 -- 延迟到刷新时创建
	table.insert(self._panels,self._heroApTipPanel)	    -- 12

	self._heroSkillMoralePanel = 0 -- 延迟到刷新时创建
	table.insert(self._panels,self._heroSkillMoralePanel)	    -- 13

	for _,panel in pairs(self._panels) do
		if not tonumber(panel) then
			panel:setSwallowTouches(false)
			panel:setVisible(false)
		end
	end


	-- 根据tiptype来索引实际上使用的是哪个panel
	self._panelIdxMap = {
		1,5,7,1,1, --[[ <  5 < --]]
		4,1,1,1,8, --[[ < 10 < --]]
		1,1,9,9,10,--[[ < 15 < --]]
		3,9,13,11,10, --[[ < 20 < --]]
		12,1,1,1,1,--[[ < 25 < --]]
		1,--[[ < 30 < --]]
	}

	-- self._tipBg = self:getUI("bg.tipBg")
	self._desInitH = self._desPanel:getContentSize().height
    self._desInitW = self._desPanel:getContentSize().width
    -- self._bg:setSwallowTouches(false) -- 2017.4.27 更改为点击就关闭
	-- self._bg:setPosition(cc.p(200,200))
	-- local notClose = true
	self._closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEventByName("bg.closeBtn",function( )
		-- if notClose then
		-- 	notClose = false
	        ViewManager:getInstance():closeHintView()
	    -- end
	end)
	self._closeBtn:setLocalZOrder(999)
	-- self._closeBtn:setVisible(true)
	self._closePanel = self:getUI("bg.closePanel")
--    -- 为背景框（点击检测区域）设置颜色，调试用
--    self._closePanel:setColor(cc.c3b(128, 128, 0))
--    self._closePanel:setBackGroundColorType(1)

	self._iconPanelTag = self:getUI("bg.iconPanel.tag")

	self._closePanel:setContentSize(cc.size(1400,720))
	self:registerClickEvent(self._closePanel,function( )
		-- if self._tipCount < 0 then
	        ViewManager:getInstance():closeHintView()
	    -- else
	    -- 	self._tipCount = self._tipCount - 1
	    -- end
	end)
	self._closePanel:setSwallowTouches(false)
end

-- 成为topView会调用, 有需要请覆盖
function GlobalTipView:onShow()
	for _,panel in pairs(self._panels) do
		if not tonumber(panel) then
			panel:setSwallowTouches(false)
			panel:setVisible(false)
		end
	end
	-- 宽和高根据旋转相互转化
    self._tipBgH = 0
    self._tipBgW = 400

    self._panelSizeH = 0
    self._desSizeH = 0
    self._currentPanel = nil
    self._tipType = nil
    self._autoW = nil
    self._autoH = nil
	self.node = nil
    self._des = nil
    -- self._fixRotation = nil 
    self._desPanel.lineNum = 0
    self._desPanel:removeAllChildren()
end

-- 被其他View盖住会调用, 有需要请覆盖
function GlobalTipView:onHide()
end
--
function GlobalTipView:createIcon( art,color,param )
	param = param or {}
	local shape = param.shape or "rect"
	local treasure = param.treasure 
	if type(color)=="table" then
		color = 1
	else
		color = color or 0
	end
	local bgNode = ccui.Widget:create()
	bgNode:setContentSize(cc.size(80,80))
	bgNode:setAnchorPoint(cc.p(0,0))
	local fu = cc.FileUtils:getInstance()
	local icon = ccui.ImageView:create()
	local sfc = cc.SpriteFrameCache:getInstance()
	if sfc:getSpriteFrameByName(art ..".jpg") then
		icon:loadTexture("" .. art ..".jpg", 1)
	else
		icon:loadTexture("" .. art ..".png", 1) 
	end
	icon:ignoreContentAdaptWithSize(false)
	icon:setContentSize(cc.size(78,78))
	icon:setAnchorPoint(cc.p(0,0))
	icon:setPosition(cc.p(0,0))
	bgNode:addChild(icon)
	-- 定制icon frame
	local iconFrame = param and param.iconFrame 
	if shape == "rect" then
		local frame = ccui.ImageView:create()
		frame:loadTexture(iconFrame or "globalImageUI4_squality" .. color .. ".png",1) 
		frame:setContentSize(cc.size(92,92))
		frame:ignoreContentAdaptWithSize(false)
		frame:setPosition(cc.p(-7,-7))
		frame:setAnchorPoint(cc.p(0,0))
		bgNode:addChild(frame,1)

		-- local iconBg = ccui.ImageView:create()
		-- if treasure then
		-- 	iconBg:loadTexture("globalImageUI6_treasurebg_" .. color .. ".png",1) 
		-- else
		-- 	iconBg:loadTexture("globalImageUI4_squality" .. color .. ".png",1) 
		-- end
		-- -- iconBg:setContentSize(cc.size(100,100))
		-- iconBg:ignoreContentAdaptWithSize(false)
		-- iconBg:setPosition(cc.p(0,0))
		-- iconBg:setScale(86/iconBg:getContentSize().width)
		-- iconBg:setAnchorPoint(cc.p(-1,-1))
		-- bgNode:addChild(iconBg,-1)
		-- bgNode:setPosition(-10,-10)
	elseif shape == "circle" then
		local frame = ccui.ImageView:create()
		frame:loadTexture(iconFrame or "globalImageUI_skillFrame.png",1) 
		frame:setContentSize(cc.size(88,88))
		frame:ignoreContentAdaptWithSize(false)
		frame:setPosition(cc.p(-5,-5))

		frame:setAnchorPoint(cc.p(0,0))
		bgNode:addChild(frame,1)

		if not param.iconFrame then
			local iconBg = ccui.ImageView:create()
			iconBg:loadTexture("globalImageUI4_heroBg2.png",1) 
			iconBg:setContentSize(cc.size(80,80))
			iconBg:ignoreContentAdaptWithSize(false)
			iconBg:setPosition(cc.p(-5,-5))
			iconBg:setScale(84/iconBg:getContentSize().width)
			iconBg:setAnchorPoint(cc.p(0,0))
			bgNode:addChild(iconBg,-1)
		
			local iconBg2 = ccui.ImageView:create()
			iconBg2:loadTexture("globalPanelUI5_tipiconbg.png",1) 
			iconBg2:setContentSize(cc.size(80,80))
			iconBg2:ignoreContentAdaptWithSize(false)
			iconBg2:setPosition(cc.p(-5,-5))
			iconBg2:setScale(90/iconBg2:getContentSize().width)
			iconBg2:setAnchorPoint(cc.p(0,0))
			bgNode:addChild(iconBg2,-2)
		end
		
		-- bgNode:setScale(0.9)
	end

	return bgNode
end

function GlobalTipView:reflashIconPanel( data )
	if not data then return end
	local iconNode = self._iconPanel:getChildByName("iconNode")
	iconNode:removeAllChildren()
	local icon
	-- dump(data)
	if data._icon then
		icon = data._icon
		if data._iconPos then
			icon:setPosition(data._iconPos.x,data._iconPos.y)
		end
	else
		icon = self:createIcon(data.art or data.icon,data.color or data.quality or data.stage or 1,{shape = data._iconshape,treasure = string.sub((data.id or "n"),1,1) == "4" ,iconFrame = data.iconFrame} )
		icon:setPositionY(-5)
		-- icon:setPosition(cc.p(iconNode:getContentSize().width/2,iconNode:getContentSize().height/2-10))
		-- icon:setPosition(0,0)--cc.p(iconNode:getContentSize().width/2,iconNode:getContentSize().height/2))
		if data._iconPos then
			icon:setPosition(data._iconPos.x,data._iconPos.y)
		end
	end
	-- icon:setScale(0.80)
	iconNode:addChild(icon)
	local nameLab = self._iconPanel:getChildByName("name")
	local nameStr = ""
	if data.name then 
		nameStr = lang(data.name)
	end
	nameLab:setFontSize(24)
	local exNameId = ""
	if OS_IS_WINDOWS and data["id"] then
		print("data..id [",data.id,"]")
		exNameId = " [" .. data.id .. "]"
		local dName = self._iconPanel:getChildByName("debugName")
		if not dName then
			dName = cc.Label:createWithTTF(exNameId, UIUtils.ttfName, 24)
			self._iconPanel:addChild(dName)
			dName:setName("debugName")
			dName:setAnchorPoint(cc.p(0,0.5))
			dName:setPosition(nameLab:getPositionX(),nameLab:getPositionY() + 24)
		end
		dName:setString(exNameId)
	end
	nameLab:setString(nameStr .. (data.nameTail or ""))
--	nameLab:setColor(self._itemName:setColor(UIUtils.colorTable["ccColorQuality".. toolD.quality or 1]))

	local nameColor = data.color or data.quality_show or data.quality or 1
	
	if nameColor then
		if type(nameColor)=="table" then
			nameLab:setColor(nameColor)
		else
			nameLab:setColor(UIUtils.colorTable["ccUIBaseColor" .. nameColor])
		end
	end
	local subDes = data._subDes or ""
	local desLab = self._iconPanel:getChildByName("des")
	if not self._iconPanelInitPos then
		self._iconPanelInitPos = {}
		self._iconPanelInitPos["name"] = nameLab:getPositionY()
		self._iconPanelInitPos["subDes"] = desLab:getPositionY()
	end
	if not desLab.initPos then
		desLab.initPos = {desLab:getPositionX(),desLab:getPositionY()}
	else
		desLab:setPosition(desLab.initPos[1],desLab.initPos[2])
	end

	if data.desConSize then
		desLab:setContentSize(data.desConSize)
	end
	if data.adjust then
		local offsetY = desLab.offsetY or 0 
		desLab:setPosition(desLab.initPos[1]+data.adjust[1],desLab.initPos[2]+data.adjust[2]+offsetY)
	end
	desLab:removeAllChildren()
	if string.find(subDes,"[-]") then
		-- subDes = "[fontsize=18]" .. subDes .."[-]"
		desLab:setString(" ")
		local rtx = RichTextFactory:create(subDes,desLab:getContentSize().width+20,desLab:getContentSize().height)
		rtx:formatText()
	    -- rtx:setVerticalSpace(5)
	    -- rtx:setAnchorPoint(cc.p(0,0))
	    local w = rtx:getInnerSize().width
	    local h = rtx:getInnerSize().height
	    local subDesOffset = data.subDesOffset or {0,0}
	    rtx:setPosition(cc.p(w/2,desLab:getContentSize().height-h))
	    UIUtils:alignRichText(rtx,{vAlign = "bottom",hAlign = "left"})
	    rtx:setName("rtx")
	    desLab:addChild(rtx)
	else
		desLab:setString(subDes or "")
		if data._subColor then
			desLab:setColor(data._subColor)
		end
	end
	local subTitle = data._subTitle 

	if subTitle then
		if not string.find(subTitle,"[-]") then
			subTitle = "[color=fae6c8,fontsize=20]" .. subTitle .. "[-]"
		end
		local rtx = RichTextFactory:create(subTitle,desLab:getContentSize().width,desLab:getContentSize().height)
		rtx:formatText()
	    -- rtx:setVerticalSpace(5)
	    -- rtx:setAnchorPoint(cc.p(0,0))
	    local w = rtx:getInnerSize().width
	    local h = rtx:getInnerSize().height
	    rtx:setPosition(cc.p(w/2,desLab:getContentSize().height-h+2))
	    UIUtils:alignRichText(rtx,{vAlign = "top",hAlign = "left"})
	    rtx:setName("rtx")
	    desLab:addChild(rtx)
	end
	local labelDes = data._label
	if labelDes then
		if not string.find(labelDes,"[-]") then
			labelDes = "[color=fae6c8,fontsize=20,outlinecolor=3c1e0a]" .. labelDes .. "[-]"
		end
		local rtx = RichTextFactory:create(labelDes,desLab:getContentSize().width,desLab:getContentSize().height)
		rtx:formatText()
	    -- rtx:setVerticalSpace(5)
	    -- rtx:setAnchorPoint(cc.p(0,0))
	    local w = rtx:getInnerSize().width
	    local h = rtx:getInnerSize().height
	    local offset = data._labelOffset or {0,0}
	    rtx:setPosition(cc.p(w/2+20+offset[1],desLab:getContentSize().height-h+20+offset[2]))
	    UIUtils:alignRichText(rtx,{vAlign = "top",hAlign = "right"})
	    rtx:setName("rtx1")
	    desLab:addChild(rtx,1)
	    if data._labelBg then
	    	local labelBg = ccui.ImageView:create()
			labelBg:loadTexture(data._labelBg,1)
			labelBg:setPosition(desLab:getContentSize().width,desLab:getContentSize().height+20)
			desLab:addChild(labelBg)
		end
		if data._labelPos then
			rtx:setPosition(data._labelPos[1],data._labelPos[2])
		end
	end
	---[[ 如果icon旁边是两行字，各向内移动5像素，否则回归原位置 16.7.30
	
	if not data.adjust then 
		if subTitle and subDes then
			nameLab:setPositionY(self._iconPanelInitPos["name"])
			desLab:setPositionY(self._iconPanelInitPos["subDes"])
             desLab.offsetY = 0
		else
			nameLab:setPositionY(self._iconPanelInitPos["name"]-8)
			desLab:setPositionY(self._iconPanelInitPos["subDes"]+10)
            desLab.offsetY = -10
		end
	end
	--]]
	
	if data.des then
		self:reflashDesPanel(data)
	end
end

function GlobalTipView:reflashRacePanel( data )
	local iconNode = self._racePanel:getChildByName("iconNode")
	iconNode:removeAllChildren()
	local icon 
	if data._icon then
		icon = data._icon
		icon:setPosition(0,0)--cc.p(iconNode:getContentSize().width/2,iconNode:getContentSize().height/2))
	else
		icon = self:createIcon(data.art or data.icon,data.color or data.stage or 1,{shape = data._iconshape,treasure = string.sub((data.id or "n"),1,1) == "4" } )
		icon:setPosition(cc.p(iconNode:getContentSize().width/2,iconNode:getContentSize().height/2))
	end
	icon:setPosition(cc.p(iconNode:getContentSize().width/2,iconNode:getContentSize().height/2))
	iconNode:addChild(icon)

	local name = self._racePanel:getChildByName("name")
	local nameStr = ""
	if data.name then 
		nameStr = lang(data.name)
	end
	name:setString(nameStr or "重新看表")
	local tp = self._racePanel:getChildByName("tp")
	local tpStr = ""
	tpStr = "全部".. nameStr .."生物"
	tp:setString(tpStr )

	local subDes = data._subDes or ""
	local desLab = self._racePanel:getChildByName("des")
	desLab:removeAllChildren()
	if string.find(subDes,"[-]") then
		desLab:setString("")
		local rtx = RichTextFactory:create(subDes,desLab:getContentSize().width,desLab:getContentSize().height)
		rtx:formatText()
	    -- rtx:setVerticalSpace(5)
	    -- rtx:setAnchorPoint(cc.p(0,0))
	    local w = rtx:getInnerSize().width
	    local h = rtx:getInnerSize().height
	    
	    rtx:setPosition(cc.p(0,0))
	    UIUtils:alignRichText(rtx,{vAlign = "bottom",hAlign = "left"})
	    rtx:setName("rtx")
	    desLab:addChild(rtx)
	else
		desLab:setString(subDes or "")
	end
	
	-- if data.des then
	-- 	self:reflashDesPanel(data)
	-- end
	local races = raceMap[data.id]
	local idx = 0
	local x,y = 0,0
	local raceBg = self._racePanel:getChildByName("raceBg")
	raceBg:removeAllChildren()
	for k,id in pairs(races) do
		local teamD = tab:Team(id)
		local teamIcon = IconUtils:createSysTeamIconById({sysTeamData = teamD})
		teamIcon:setScale(70/teamIcon:getContentSize().width)
		teamIcon:setPosition(cc.p(idx%5*75,100-math.floor(idx/5)*82))
		raceBg:addChild(teamIcon)
		local name = ccui.Text:create()
		name:setFontName(UIUtils.ttfName)
		name:setString(lang(teamD.name))
		name:setFontSize(14)
		name:enableOutline(cc.c4b(64,64,64,255),1)
		name:setPosition(cc.p(idx%5*75+35,100-math.floor(idx/5)*82-5))
		raceBg:addChild(name)
		idx = idx + 1
	end
end

local skillKindOption = {{"点击","滑动","拖动"},"瞬发"}
function GlobalTipView:reflashTitlePanel( data )
	self._currentPanel = self._titlePanel
	local title = self:getUI("bg.titlePanel.title")
	local name = lang(data.name) or "法术名未配置"
	title:setString(name)
	local kindLabel = self:getUI("bg.titlePanel.kind")
	kindLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	if data.kind then
		local kindStr = ""
		if data.option then
			kindStr = skillKindOption[data.kind][data.option]
		else
			kindStr = skillKindOption[data.kind]
		end
		
		kindLabel:setString(kindStr)
	else
		kindLabel:setVisible(false)
	end
	if data.des then
		self:reflashDesPanel(data)
	end
end

function GlobalTipView:parseDesTable( desTable )
	-- desTable[#desTable+1] = "测试多行字"
	local height = 0
	local lineWidth = 0
	local offsetY = 5
	local rtxStr = ""
	for k,v in pairs(desTable) do
		-- rtxStr = rtxStr .. "[color=fae6c8]".. v .."[-]" .. "[][-]"
		-- local text = UIUtils:createMultiLineLabel({text = v,width = 350})
		-- text:setColor(cc.c3b(255, 255, 255))
		-- text:setAnchorPoint(cc.p(0,0))
		-- text:setPosition(cc.p(20,height+lineWidth+offsetY))
		-- -- self._desPanel:addChild(text)
		-- height = height + text:getContentSize().height + lineWidth
		-- lineWidth = 5
		-- local vv = string.gsub(v,"%[%]","[-]",1)
		v = string.gsub(v," ","")
		v = string.gsub(v,"　","")
	    v = string.gsub(v,"754922","fae6c8")

		if string.sub(v,1,1) ~= "[" then
			v = "[color=fae6c8,fontsize = 20]" .. v .. "[-]"
		end
		rtxStr = rtxStr .. v 
	end
	-- rtxStr = rtxStr .. "[-]"
	if string.sub(rtxStr,1,1) ~= "[" then
		rtxStr = "[color=fae6c8,fontsize = 20]" .. rtxStr .. "[-]"
	end
	rtxStr = string.gsub(rtxStr,"645252","fae6c8")
	rtxStr = string.gsub(rtxStr,"c98f55","fae6c8")
	rtxStr = string.gsub(rtxStr,"00ff00","fae6c8")
	rtxStr = string.gsub(rtxStr,"fae0bc","fae6c8")
	rtxStr = string.gsub(rtxStr,"FFFFFF","fae6c8")
	rtxStr = string.gsub(rtxStr,"3D1F00","fae6c8")
	rtxStr = string.gsub(rtxStr,"fontsize=17","fontsize=20")
	local rtx = RichTextFactory:create(rtxStr,360,height)
	rtx:formatText()
    rtx:setVerticalSpace(5)
    -- rtx:setAnchorPoint(cc.p(0,0))
    local w = rtx:getInnerSize().width
    local h = rtx:getInnerSize().height
    local desPanelH = math.max(self._desInitH,h+40)
    self._desPanel:setContentSize(cc.size(math.max(100,w+40),desPanelH))
    
    rtx:setPosition(cc.p(self._desPanel:getContentSize().width/2-20,self._desPanel:getContentSize().height/2))
    rtx:setName("rtx")
    self._desPanel:addChild(rtx)
    UIUtils:alignRichText(rtx,{vAlign = "bottom",hAlign = "left"})
   
	self._desSizeH = desPanelH
end

function GlobalTipView:reflashDesPanel( data )
	local des = data.des
	self._desPanel:removeAllChildren()
	self._desPanel:setVisible(true)
	if des and type(des) == "table" then
		self:parseDesTable(des)
	elseif des and type(des) == "string" then
		local desTable = {}
		-- if data.manacost then --and not data._skillType then
		-- 	-- desTable[#desTable+1] = "单次耗魔:[color = d7ad6a]".. data.manacost[1] .. "[-]"
		-- 	data._subTitle = "单次耗魔:[color = d7ad6a]".. data.manacost[1] .. "[-]"
		-- end
		-- if data.cd then --and not data._skillType then
		-- 	-- desTable[#desTable+1] = "冷却时间:[color = d7ad6a]".. data.cd[1]/1000 .."s[-][][-]"
		-- 	data._subDes = "冷却时间:[color = d7ad6a]".. data.cd[1]/1000 .."s[-][][-]"
		-- end
		if self._des then
			self._des = string.gsub(self._des," ","")
			self._des = string.gsub(self._des,"　　","")
			desTable[#desTable+1] = self._des 
		else
			desTable[#desTable+1] = string.gsub(lang(data.des),"　　","")  or ""
		end
		self:parseDesTable(desTable)
	end
end

local heroSmallAttrIcon = {
	"atk_icon2_hero.png",
	"def_icon2_hero.png",
	"int_icon2_hero.png",
	"ack_icon2_hero.png",
	"magic_icon_hero.png",
	"magic+_icon_hero.png",
}

local function getNatureNum( num )
	if type(num) ~= "number" or not tonumber(num) then return num end
	
	return tonumber(string.format("%01f",num))
end

function GlobalTipView:reflashHeroAttrPanel( data )
	-- dump(data)
	-- 计算 英雄收集
	local heroCollectAttr = self._modelMgr:getModel("HeroModel"):caculateHeroCollectAttr()
	local heroMasteryAttr = self._modelMgr:getModel("HeroModel"):caculateHeroMasteryAttr()
	-- dump(heroMasteryAttr,"heroMasteryAttr")
	self._heroAttrPanel:setPosition(0, -100)
	self._bg:setContentSize(0, 0)
	self._bg:setOpacity(0)
	self._bgHight = 0 --heroAttrBg:getContentSize().height
	self._bgWidth = 0 --heroAttrBg:getContentSize().width
	-- 皮肤属性
	local heroSkinAttrs = self._modelMgr:getModel("HeroModel"):getHeroSkinAttr()
	if not heroSkinAttrs then heroSkinAttrs = {} end
	-- 刻印属性
	local spellAttrs = self._modelMgr:getModel("SpellBooksModel"):getSpellBookAttrs()
	if not spellAttrs then spellAttrs = {} end
	--星体属性
	local starAttr = self._modelMgr:getModel("UserModel"):getStarHeroAttr() or {}
	-- 后援属性
	local backUpAttr = self._modelMgr:getModel("BackupModel"):getBackUpAddAtr() or {}
	-- 计算属性
	local branchBuff = self._modelMgr:getModel("UserModel"):getData().branchHAb or {}
	local heroId = data.heroData.id
    local star = data.heroData.star
    local heroD = tab:Hero(tonumber(heroId))
    local base 
    local attr, attr1, attr2, attr3, attr4, attr5, kind, icon, attr7, attr8, attr9, attr10, attr11
    local attrs = {}  -- 二维数组 四个属性 攻防智知
    attrs[1] = {}
    attr  = tonumber(string.format("%.01f",data.attributes.atk))
    attr1 = tonumber(string.format("%.01f",heroCollectAttr.atk)) --tonumber(string.format("%.01f",data.attributes.heroAttr_special[BattleUtils.HATTR_AtkAdd]))
    attr2 = tonumber(string.format("%.01f",heroMasteryAttr.atk)) --tonumber(string.format("%.01f",data.attributes.heroAttr_mastery[BattleUtils.HATTR_AtkAdd]))
    attr3 = tonumber(string.format("%.01f",data.attributes.heroAttr_treasure[BattleUtils.HATTR_AtkAdd]))
    attr4 = tonumber(string.format("%.01f",data.attributes.heroAttr_talent[BattleUtils.HATTR_AtkAdd]))
    attr5 = branchBuff[1] or branchBuff["1"] or 0
    attr7 = tonumber(string.format("%.01f",heroSkinAttrs.atk or 0))
    attr8 = tonumber(string.format("%.01f",spellAttrs.atk or 0))
    attr9 = starAttr["110"] or starAttr[110] or 0
    attr10 = backUpAttr["110"] or backUpAttr[110] or 0
    attr11 = tonumber(string.format("%.01f",data.attributes.heroAttr_paragonTalent[BattleUtils.HATTR_Atk]))
    print("attr2 atk",attr2)
    -- attr2 = attr - attr1 - attr2 - attr3 - attr4
    ---[[ -- 修正数值 因 拿到几个attr值不对
    -- base = heroD["atk"][1]+(star-heroD.star)*heroD["atk"][2]
    -- attr1 = tonumber(string.format("%.01f",base))
    -- attr4 = tonumber(string.format("%.01f",attr - attr1 - attr2 - attr3 - attr5))
    attrs[1].attr6 = attr+attr7+attr9
    attrs[1].attr1 = attr1
    attrs[1].attr2 = attr2
    attrs[1].attr3 = attr3
    attrs[1].attr4 = attr4
    attrs[1].attr5 = attr5
    attrs[1].attr7 = attr7
    attrs[1].attr8 = attr8
    attrs[1].attr9 = attr9
    attrs[1].attr10 = attr10
    attrs[1].attr11 = attr11
    --]]
    attr  = tonumber(string.format("%.01f",data.attributes.def))
    attr1 = tonumber(string.format("%.01f",heroCollectAttr.def)) --tonumber(string.format("%.01f",data.attributes.heroAttr_special[BattleUtils.HATTR_DefAdd]))
    attr2 = tonumber(string.format("%.01f",heroMasteryAttr.def)) --tonumber(string.format("%.01f",data.attributes.heroAttr_mastery[BattleUtils.HATTR_DefAdd]))
    attr3 = tonumber(string.format("%.01f",data.attributes.heroAttr_treasure[BattleUtils.HATTR_DefAdd]))
    attr4 = tonumber(string.format("%.01f",data.attributes.heroAttr_talent[BattleUtils.HATTR_DefAdd]))
    attr5 = branchBuff[2] or branchBuff["2"] or 0
    attr7 = tonumber(string.format("%.01f",heroSkinAttrs.def or 0))
    attr8 = tonumber(string.format("%.01f",spellAttrs.def or 0))
    attr9 = starAttr["113"] or starAttr[113] or 0
    attr10 = backUpAttr["113"] or backUpAttr[113] or 0
    attr11 = tonumber(string.format("%.01f",data.attributes.heroAttr_paragonTalent[BattleUtils.HATTR_Def]))
    print("def attr ",attr,"att2",attr2)
    -- attr2 = attr - attr1 - attr2 - attr3 - attr4
    
    attrs[2] = {}
    attrs[2].attr6 = attr+attr7+attr9
    attrs[2].attr1 = attr1
    attrs[2].attr2 = attr2
    attrs[2].attr3 = attr3
    attrs[2].attr4 = attr4
    attrs[2].attr5 = attr5    
	attrs[2].attr7 = attr7
    attrs[2].attr8 = attr8
    attrs[2].attr9 = attr9
    attrs[2].attr10 = attr10
    attrs[2].attr11 = attr11
    --]]
    attr  = tonumber(string.format("%.01f",data.attributes.int))
    attr1 = tonumber(string.format("%.01f",heroCollectAttr.int)) --tonumber(string.format("%.01f",data.attributes.heroAttr_special[BattleUtils.HATTR_IntAdd]))
    attr2 = tonumber(string.format("%.01f",heroMasteryAttr.int)) --tonumber(string.format("%.01f",data.attributes.heroAttr_mastery[BattleUtils.HATTR_IntAdd]))
    attr3 = tonumber(string.format("%.01f",data.attributes.heroAttr_treasure[BattleUtils.HATTR_IntAdd]))
    attr4 = tonumber(string.format("%.01f",data.attributes.heroAttr_talent[BattleUtils.HATTR_IntAdd]))
	attr5 = branchBuff[3] or branchBuff["3"] or 0
    attr7 = tonumber(string.format("%.01f",heroSkinAttrs.int or 0))
    attr8 = tonumber(string.format("%.01f",spellAttrs.int or 0))
    attr9 = starAttr["116"] or starAttr[116] or 0
    attr10 = backUpAttr["116"] or backUpAttr[116] or 0
    attr11 = tonumber(string.format("%.01f",data.attributes.heroAttr_paragonTalent[BattleUtils.HATTR_Int]))
    print("attr2 int",attr2)
    -- attr2 = attr - attr1 - attr2 - attr3 - attr4
    attrs[3] = {}
    attrs[3].attr6 = attr+attr7+attr9
    attrs[3].attr1 = attr1
    attrs[3].attr2 = attr2
    attrs[3].attr3 = attr3
    attrs[3].attr4 = attr4
    attrs[3].attr5 = attr5
    attrs[3].attr7 = attr7
    attrs[3].attr8 = attr8
    attrs[3].attr9 = attr9
    attrs[3].attr10 = attr10
    attrs[3].attr11 = attr11
    --]]
    attr  = tonumber(string.format("%.01f",data.attributes.ack))
    attr1 = tonumber(string.format("%.01f",heroCollectAttr.ack)) -- tonumber(string.format("%.01f",data.attributes.heroAttr_special[BattleUtils.HATTR_AckAdd]))
    attr2 = tonumber(string.format("%.01f",heroMasteryAttr.ack)) -- tonumber(string.format("%.01f",data.attributes.heroAttr_mastery[BattleUtils.HATTR_AckAdd]))
    attr3 = tonumber(string.format("%.01f",data.attributes.heroAttr_treasure[BattleUtils.HATTR_AckAdd]))
    attr4 = tonumber(string.format("%.01f",data.attributes.heroAttr_talent[BattleUtils.HATTR_AckAdd]))
    attr5 = branchBuff[4] or branchBuff["4"] or 0
    attr7 = tonumber(string.format("%.01f",heroSkinAttrs.ack or 0))
    attr8 = tonumber(string.format("%.01f",spellAttrs.ack or 0))
    attr9 = starAttr["119"] or starAttr[119] or 0
    attr10 = backUpAttr["119"] or backUpAttr[119] or 0
    attr11 = tonumber(string.format("%.01f",data.attributes.heroAttr_paragonTalent[BattleUtils.HATTR_Ack]))
    print("attr2 ack",attr2)
    -- attr2 = attr - attr1 - attr2 - attr3 - attr4
    attrs[4] = {}
    attrs[4].attr6 = attr+attr7+attr9
    attrs[4].attr1 = attr1
    attrs[4].attr2 = attr2
    attrs[4].attr3 = attr3
    attrs[4].attr4 = attr4
    attrs[4].attr5 = attr5
    attrs[4].attr7 = attr7
    attrs[4].attr8 = attr8
    attrs[4].attr9 = attr9
    attrs[4].attr10 = attr10
    attrs[4].attr11 = attr11
    --]]

	self._heroAttrPanel:setAttrs(attrs)
	-- 魔法行会改学院
	local des = self._heroAttrPanel:getChildByFullName("root.bg.attrCell4.des")
	if des then 
		des:setString(lang("SYSTEM_20"))
	end	
end

-- 兵团特殊tip
function GlobalTipView:reflashTeamAttrPanel( data )
	local attrs = data.attrs 
	dump(attrs,"=======attrs===========")
	self._teamAttrPanel:setPosition(0, 0)
	self._bg:setContentSize(self._teamAttrPanel:getContentSize().width, self._teamAttrPanel:getContentSize().height)
	self._bgHight = self._teamAttrPanel:getContentSize().height
	self._bgWidth = self._teamAttrPanel:getContentSize().width
	-- data.des = string.gsub(data.des,"%b[]","")[color=00ff22]
	local atkPanel = self._teamAttrPanel:getChildByName("atkPanel")
	local atkAttr = atkPanel:getChildByName("attr")
	atkAttr:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	atkAttr:setString(TeamUtils.getNatureNums(attrs.atk))
	local attrMap = {"base","treasure","pokedex","teamboost","hero","holy","skin"}
	local atkDes4 = atkPanel:getChildByName("label4")
	if atkDes4 then atkDes4:setString("天赋:") end
	for i=1,7 do
		local attr = atkPanel:getChildByName("attr" .. i)
		attr:setString(TeamUtils.getNatureNums(attrs["atk" .. attrMap[i]]))
	end
	local hpPanel = self._teamAttrPanel:getChildByName("hpPanel")
	local hpAttr = hpPanel:getChildByName("attr")
	hpAttr:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	hpAttr:setString(TeamUtils.getNatureNums(attrs.hp))
	local atkDes4 = hpPanel:getChildByName("label4")
	if atkDes4 then atkDes4:setString("天赋:") end
	for i=1,7 do
		local attr = hpPanel:getChildByName("attr" .. i)
		attr:setString(TeamUtils.getNatureNums(attrs["hp" .. attrMap[i]]))
	end
	
end

--[[
--! @function reflashGuildEquipTipPanel
--! @desc 联盟探索装备属性
--! @param data 传入参数
--! @return 
--]]
function GlobalTipView:reflashGuildEquipTipPanel(data )
	if tonumber(self._guildEquipTipPanel) then return end
	self._guildEquipTipPanel:setPosition(0, 0)
	self._guildEquipTipPanel:setAnchorPoint(0, 0)
	-- self._bg:setOpacity(0)
	-- local size = cc.size(0,0)
	-- local bg = self._guildEquipTipPanel._widget:getChildByName("bg")
	-- if bg then
	-- 	size = bg:getContentSize(size)
	-- end
	self._bg:setContentSize(cc.size(268,143))
	self._bgHight = 143
	self._bgWidth = 0
	self._guildEquipTipPanel:setAttrs(data.id)
end

function GlobalTipView:reflashHeroSkillMoralePanel( data )
	if tonumber(self._heroSkillMoralePanel) then return end
	self._bg:setOpacity(0)
	self._bg:setContentSize(0, 0)
	self._bgHight = 0 --heroAttrBg:getContentSize().height
	self._bgWidth = 0 --heroAttrBg:getContentSize().width
	self._heroSkillMoralePanel:setAttrs(data)
	self._heroSkillMoralePanel:setPosition(280,-10)
	-- 魔法行会改学院
	local des = self._heroSkillMoralePanel:getChildByFullName("root.bg.attrCell2.des")
	if des then 
		des:setString(lang("SYSTEM_20"))
	end	
end

-- 英雄技能cd tip 展示cd效果的来源
-- 英雄耗魔tip  复用 
-- 复用英雄属性的tip板子
function GlobalTipView:reflashSkillCDAttrPanel( data )
	if tonumber(self._skillCdPanel) then return end
	self._bg:setOpacity(0)
	self._bg:setContentSize(0, 0)
	self._bgHight = 0 --heroAttrBg:getContentSize().height
	self._bgWidth = 0 --heroAttrBg:getContentSize().width
	self._skillCdPanel:setAttrs(data)
	self._skillCdPanel:setPosition(280,-10)
	-- 魔法行会改学院
	local des = self._skillCdPanel:getChildByFullName("root.bg.attrCell2.des")
	if des then 
		des:setString(lang("SYSTEM_20"))
	end	
	if true then return end
	-- self._skillCdPanel:setPosition(0, 0)
	-- self._bg:setContentSize(self._skillCdPanel:getContentSize().width, self._skillCdPanel:getContentSize().height)
	-- -- 记录初始大小
	-- if not self._initSillCDPanelWidth then
	-- 	self._initSillCDPanelWidth =  self._skillCdPanel:getContentSize().width
	-- 	self._initSillCDPanelHight = self._skillCdPanel:getContentSize().height
	-- end
	-- -- data.des = string.gsub(data.des,"%b[]","")[color=00ff22]
	-- data.des = string.gsub(data.des,"%[color=00ff22%]","[color=00ff22,outlinecolor=3b1c0a]")
	-- local desLab = self:getUI("bg.skillCdPanel.des")
	-- local rtx = desLab:getChildByName("rtx")
	-- if rtx then
	-- 	rtx:removeFromParent()
	-- end
	-- rtx = RichTextFactory:create("[color=fae6c8,fontsize=20]" .. data.des .. "[-]",300,40)
	-- rtx:formatText()
 --    -- rtx:setVerticalSpace(5)
 --    -- rtx:setAnchorPoint(cc.p(0,0))
 --    local w = rtx:getInnerSize().width
 --    local h = rtx:getInnerSize().height
 --    rtxH = rtx:getRealSize().height
 --    rtx:setPosition(w/2,h/2)
 --    rtx:setName("rtx")
 --    desLab:addChild(rtx)
	-- UIUtils:alignRichText(rtx,{hAlign = "left",vAlign = "bottom"})
	-- self:getUI("bg.skillCdPanel.des"):setString("　" )--data.des)
	-- self:getUI("bg.skillCdPanel.kind"):setString(data.kind)
	-- self:getUI("bg.skillCdPanel.label5"):setString("学院")
	-- self:getUI("bg.skillCdPanel.icon"):loadTexture(data.art,1) --"hero_tip_".. (data.icon or 1) ..".png", 1)
	-- self:getUI("bg.skillCdPanel.icon"):setPurityColor(250, 230, 200)
	-- self:getUI("bg.skillCdPanel.attr"):setString(data.attr)
	-- UIUtils:outlineNodeLabel(self:getUI("bg.skillCdPanel.attr"))
	-- local decreaseStr = ": 减少"
	-- self:getUI("bg.skillCdPanel.attr1"):setString(": " .. getNatureNum(tonumber(data.attr1) and math.abs(data.attr1) or data.attr1)) -- 
	-- self:getUI("bg.skillCdPanel.attr2"):setString(decreaseStr .. getNatureNum(tonumber(data.attr3) and math.abs(data.attr3) or data.attr3))
	-- self:getUI("bg.skillCdPanel.attr3"):setString(decreaseStr .. getNatureNum(tonumber(data.attr2) and math.abs(data.attr2) or data.attr2))
	-- self:getUI("bg.skillCdPanel.attr4"):setString(decreaseStr .. getNatureNum(tonumber(data.attr4) and math.abs(data.attr4) or data.attr4))
	-- self:getUI("bg.skillCdPanel.attr5"):setString(decreaseStr .. getNatureNum(tonumber(data.attr5) and math.abs(data.attr5 or 0) or data.attr5))

	-- data.attr3,data.attr2 = data.attr2,data.attr3
	-- for i = 1, 4 do 
	-- 	local nameIdx = i
	-- 	if nameIdx == 2 then 
	-- 		nameIdx = 3 
	-- 	elseif nameIdx == 3 then 
	-- 		nameIdx = 2 
	-- 	end
	-- 	self:getUI("bg.skillCdPanel.label".. nameIdx):setString(lang("HERO_ATTRTIP_".. i))
	-- end
	-- local children = self._skillCdPanel:getChildren()
	-- if not self._skillCdPanelPosY then
	-- 	self._skillCdPanelPosY = {}
	-- 	self._skillCdPanelPosX = {}
	-- 	self._skillCdPosMapY = {}
	-- 	self._skillCdPosMapX = {}
	-- 	for i = 1,5 do
	-- 		table.insert(self._skillCdPanelPosY,self:getUI("bg.skillCdPanel.attr"..i):getPositionY())
	-- 		table.insert(self._skillCdPanelPosX,self:getUI("bg.skillCdPanel.attr"..i):getPositionX())
	-- 	end
	-- 	for k,v in pairs(children) do
	-- 		self._skillCdPosMapY[v:getName()] = v:getPositionY()
	-- 		self._skillCdPosMapX[v:getName()] = v:getPositionX()
	-- 	end
	-- 	-- self._skillCdPanelPosY[3],self._skillCdPanelPosY[4] = self._skillCdPanelPosY[4],self._skillCdPanelPosY[3]
	-- end
	-- -- 因为一直在复用 设置初始位置
	-- for k,v in pairs(children) do
	-- 	local name = v:getName()
	-- 	v:setPositionY(self._skillCdPosMapY[name])  
	-- end
	-- local index = 1
	-- -- 第五项学院特殊处理 x轴偏移值
	-- local attLabOffxs = {0,0,0,0,50}
	-- for i=1,5 do
	-- 	local att = getNatureNum(tonumber(data["attr" .. i]) and math.abs(data["attr" .. i]) or data["attr" .. i])
	-- 	local desLab = self:getUI("bg.skillCdPanel.label"..i)
	-- 	local numLab = self:getUI("bg.skillCdPanel.attr"..i)

	-- 	-- 下边再设置显示的位置
	-- 	if att == 0 then
	-- 		desLab:setVisible(false)
	-- 		numLab:setVisible(false)
	-- 	else
	-- 		desLab:setVisible(true)
	-- 		numLab:setVisible(true)
	-- 		desLab:setPositionY(self._skillCdPanelPosY[index])
	-- 		numLab:setPositionY(self._skillCdPanelPosY[index])
	-- 		numLab:setPositionX(self._skillCdPanelPosX[index]-5+attLabOffxs[i])
	-- 		index = index+1
	-- 	end
	-- end
	-- -- [[ 按照新的板子高度调整位置
	-- local decreaseH = (6-index)*28
	-- for k,v in pairs(children) do
	-- 	local name = v:getName()
	-- 	-- v:setPositionY(self._skillCdPosMapY[name])
	-- 	if (string.find(name,"attr") and (string.len(name) < 5) ) or (not string.find(name,"attr") and not string.find(name,"label") ) then
	-- 		v:setPositionY(self._skillCdPosMapY[name]-decreaseH)  
	-- 	end
	-- end
	-- for i=1,5 do
	-- 	local desLab = self:getUI("bg.skillCdPanel.label"..i)
	-- 	local numLab = self:getUI("bg.skillCdPanel.attr"..i)
	-- 	desLab:setPositionY(desLab:getPositionY()-decreaseH)
	-- 	numLab:setPositionY(numLab:getPositionY()-decreaseH)
	-- end
	-- --]]

	-- local lastHeight = self._initSillCDPanelHight-(7-index)*28
	-- self._skillCdPanel:setContentSize(cc.size(self._initSillCDPanelWidth,lastHeight))
	-- self._bg:setContentSize(cc.size(self._initSillCDPanelWidth,lastHeight))
	-- self._bgWidth = self._initSillCDPanelWidth
	-- self._bgHight = lastHeight
	
	-- self._skillCdPanel:setPosition(0, -(5-index)*25+5)
end

-- 英雄法伤tip
function GlobalTipView:reflashHeroApTipPanel( data )
	if tonumber(self._heroApTipPanel) then return end
	self._bg:setOpacity(0)
	self._bg:setContentSize(0, 0)
	self._bgHight = 0 --heroAttrBg:getContentSize().height
	self._bgWidth = 0 --heroAttrBg:getContentSize().width
	self._heroApTipPanel:setAttrs(data)
	self._heroApTipPanel:setPosition(280,0)
	-- 魔法行会改学院
	local des = self._heroApTipPanel:getChildByFullName("root.bg.attrCell2.des")
	if des then 
		des:setString(lang("SYSTEM_20"))
	end	
end

-- 宝物详情tip
function GlobalTipView:reflashTreasureTipPanel( data )
	if tonumber(self._treasureTipPanel) then return end
	self._bg:setOpacity(0)
	self._bg:setContentSize(420, 400)
	self._bgHight = 400 --heroAttrBg:getContentSize().height
	self._bgWidth = 420 --heroAttrBg:getContentSize().width
	self._treasureTipPanel:setAttrs(data.id, data.stage,data.showAllTreasure)
	-- self._treasureTipPanel:setPosition(200,200)
end

--[[
self:registerClickEvent("bg.scrollView.infoNode.tanchushuxing",function( )
        self:showHintView("global.GlobalTipView",
        {   
            tipType = 3, node = node,
            heroId = heroId,
            star = heroStar, 
            kind = kind,
            icon = icon,
            attr = attr,
            attr1 = attr1,
            attr2 = attr2,
            attr3 = attr3,
            attr4 = attr4,
            des = BattleUtils.getDescription(iconType, iconId, data.attributes),
            center = true,
        })
    end)
]]

-- 创建特长cell
function GlobalTipView:createSpecialCell( data,specials,star,isLocked )
	-- [[创建展示板子
	local specialBg = ccui.ImageView:create()
	specialBg:setPosition(175,50)
	specialBg:setScale9Enabled(true)
	specialBg:setCapInsets(cc.rect(15,15,1,1))
	specialBg:setContentSize(cc.size(510,120))
	specialBg:loadTexture("globalImageUI_tipCellBg.png",1)
	-- node:addChild(specialBg)

	local imageFrame = ccui.ImageView:create()
	imageFrame:loadTexture("globalImageUI7_hsquality1.png",1)
	imageFrame:setPosition(60,57)
	imageFrame:setScale(1.1)
	specialBg:addChild(imageFrame,6)

	local imageStar = ccui.ImageView:create()
	imageStar:loadTexture("globalImageUI_heroStar".. star ..".png",1)
	imageStar:setPosition(60,28)
	specialBg:addChild(imageStar,20)
	
	local imageLocked = ccui.ImageView:create()
	imageLocked:loadTexture("pokeImage_suo.png",1)
	imageLocked:setPosition(60,57)
	specialBg:addChild(imageLocked,10)

	local imageSpecialIcon = ccui.ImageView:create()
	imageSpecialIcon:loadTexture("globalImageUI7_hsquality1.png",1)
	imageSpecialIcon:setPosition(60,56)
	imageSpecialIcon:setScale(1)
	specialBg:addChild(imageSpecialIcon,4)

	local specialDes = ccui.Layout:create()
	specialDes:setContentSize(cc.size(360,85))
	specialDes:setPosition(108,8)
	specialBg:addChild(specialDes,2)

	local imageGlobalSpecialtyBg = ccui.ImageView:create()
	imageGlobalSpecialtyBg:setScale9Enabled(true)
	imageGlobalSpecialtyBg:setCapInsets(cc.rect(12,12,1,1))
	imageGlobalSpecialtyBg:setContentSize(cc.size(500,30))
	imageGlobalSpecialtyBg:setPosition(250,15)
	imageGlobalSpecialtyBg:loadTexture("specialty_bg_2_hero.png",1)
	imageGlobalSpecialtyBg:setSaturation(-100)
	specialBg:addChild(imageGlobalSpecialtyBg,3)

	local labelGlobalTitle = ccui.Text:create()
	labelGlobalTitle:setFontSize(18)
	labelGlobalTitle:setFontName(UIUtils.ttfName)
	labelGlobalTitle:setPosition(215,18)
	labelGlobalTitle:setString("英雄不在场依然有效")
	specialBg:addChild(labelGlobalTitle,5)

	local imageMask = ccui.ImageView:create()
	imageMask:loadTexture("globalPanelUI7_zhezhao.png",1)
	imageMask:setContentSize(cc.size(80,80))
	imageMask:setPosition(56,48)
	imageMask:setScale(0.925)
	specialBg:addChild(imageMask,15)

	--]]
	local global = (data.heroD and data.heroD.global) or (tab.hero[tonumber(data.heroD.heroId) or tonumber(data.heroD.id)] and tab.hero[tonumber(data.heroD.heroId) or tonumber(data.heroD.id)].global)
	local hadAddBuffDes = global == star -- 是否有额外效果 labelGlobalTitle 可见
	local isNpcHero
	if data.heroD and tab.npcHero[data.heroD.id or 0] then
		isNpcHero = true
		hadAddBuffDes = false
	end
	local rtxOffset = 0
	if hadAddBuffDes then 
		rtxOffset = 10
    	imageFrame:loadTexture("globalImageUI7_ghsquality" .. star .. ".png",1)
    else
	    imageFrame:loadTexture("globalImageUI7_hsquality" .. star .. ".png", 1)
	end
    -- imageFrame:setVisible(not data.heroD.global or star ~= data.heroD.global)

    imageLocked:setVisible(isLocked)
    imageMask:setVisible(isLocked)
    imageSpecialIcon:setScale(0.9)
    imageSpecialIcon:loadTexture(specials[star].icon .. ".jpg", 1)
    local label = specialDes
    local descColor = isLocked and cc.c3b(182, 182, 182) or cc.c3b(250, 230, 200) --"[color=808080, fontsize=24]" or "[color=fae6c8, fontsize=24]" 
    local desc = lang(specials[star].des)
    -- local richText = label:getChildByName("descRichText" )
    -- if richText then
    --     richText:removeFromParentAndCleanup()
    -- end
    -- richText = RichTextFactory:create(desc, 360, 80)
    -- richText:setVerticalSpace(-4)
    -- richText:formatText()
    -- richText:enablePrinter(true)
    -- richText:setPosition(label:getContentSize().width / 2+rtxOffset, label:getContentSize().height / 1.8+5)
    -- richText:setName("descRichText")
    -- label:addChild(richText)
    desc = string.gsub(desc,"%b[]",function( )
    	return ""
    end)
    desc = string.gsub(desc," ","")
    desc = string.gsub(desc,"　","")
    local specialDes = ccui.Text:create()
	specialDes:setFontSize(18)
	specialDes:setFontName(UIUtils.ttfName)
	specialDes:setPosition(10,15)
	specialDes:setString(desc)
	specialDes:setAnchorPoint(0,0)
	specialDes:setColor(descColor)
	specialDes:getVirtualRenderer():setMaxLineWidth(380)
	specialDes:getVirtualRenderer():setHorizontalAlignment(0)
	label:addChild(specialDes,5) 

	-- 调整 specicalDes 的位置
	local specialDesH = specialDes:getVirtualRenderer():getContentSize().height
	print("=====specialDesH======"..specialDesH)
	if specialDesH == 52 then
		if hadAddBuffDes then
			specialDes:setPosition(10,27)
		else
			specialDes:setPosition(10,20)
		end
	elseif specialDesH < 52 then
		if hadAddBuffDes then
			specialDes:setPosition(10,40)
		else
			specialDes:setPosition(10,35)
		end
	elseif specialDesH > 52 then
		if hadAddBuffDes then
			specialDes:setPosition(10,20)
		else
			specialDes:setPosition(10,50-specialDesH/2)
		end
	end

    imageGlobalSpecialtyBg:setVisible(false and hadAddBuffDes)
    labelGlobalTitle:setVisible(hadAddBuffDes)
    local color = isLocked and cc.c3b(128, 128, 128) or cc.c3b(0, 255, 30)
    if isLocked then
    	labelGlobalTitle:setSaturation(-100)
        labelGlobalTitle:disableEffect()
    else
    	labelGlobalTitle:setSaturation(0)
        labelGlobalTitle:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end
    labelGlobalTitle:setColor(color)
    return specialBg
end
function GlobalTipView:parseMastery( data )

	dump(data.heroD)
	self._iconPanel:setVisible(false)
	-- [[专长title
	local titleBg = ccui.ImageView:create()
	titleBg:loadTexture("globalImageUI_tip_title.png",1)
	titleBg:setContentSize(540,50)
    titleBg:setScale9Enabled(true)
    titleBg:setCapInsets(cc.rect(90,10,1,1))
	titleBg:setPosition(200,550)
	self._desPanel:addChild(titleBg)
	local specialDesLab = ccui.Text:create()
	specialDesLab:setFontSize(26)
	specialDesLab:setFontName(UIUtils.ttfName)
	specialDesLab:setColor(cc.c3b(255, 212, 120))
	specialDesLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	specialDesLab:setString("专长:")
	specialDesLab:setAnchorPoint(cc.p(0,0.5))
	specialDesLab:setPosition(65+100,24)
	titleBg:addChild(specialDesLab)

	local specialTitle = ccui.Text:create()
	specialTitle:setFontSize(26)
	specialTitle:setFontName(UIUtils.ttfName)
	specialTitle:setAnchorPoint(cc.p(0,0.5))
	specialTitle:setColor(cc.c3b(255, 255, 255))
	specialTitle:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	specialTitle:setString(lang(data.name))
	specialTitle:setPosition(135+100,24)
	titleBg:addChild(specialTitle)

	local heroTableData = tab:Hero(data.heroD.id or data.heroD.heroId)
	if heroTableData and not data.heroD.showdes then
		data.heroD.showdes = heroTableData.showdes
		data.heroD.herodes1 = heroTableData.herodes1
	end

	local showdes = data.heroD.showdes
	if tonumber(showdes) == 1 then
	    local tipsBtn = ccui.Button:create()
	    tipsBtn:loadTextures("globalImage_info.png","globalImage_info.png","globalImage_info.png",1)
	    tipsBtn:setPosition(410+100,24)
	    registerClickEvent(tipsBtn,function() 
	        self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = lang(data.heroD.herodes1),titleDes = "专长补充"},true)
	    end)
	    titleBg:addChild(tipsBtn)

	end

	--]]
	local star = tonumber(data.star)
	local data1 = clone(data.heroD)
    local special = data1.special
    local specialTableData = clone(tab.heroMastery)
    for k, v in pairs(specialTableData) do
        if 1 ~= v.class then
            specialTableData[k] = nil
        end
    end
    data1.specialtyInfo = {
        specials = {},
        nextUnlockSpecialIndex = 0,
    }
    for k, v in pairs(specialTableData) do
        if special == v.baseid then
            v.unlock = star >= v.masterylv 
            table.insert(data1.specialtyInfo.specials, v)
        end
    end
    table.sort(data1.specialtyInfo.specials, function(a, b)
        return a.masterylv < b.masterylv or a.id < b.id
    end)
    for k, v in ipairs(data1.specialtyInfo.specials) do
        if not v.unlock then
            data1.specialtyInfo.nextUnlockSpecialIndex = k
            break
        end
    end

    local specials = data1.specialtyInfo.specials
    -- dump(specials)

    local nextUnlockSpecialIndex = data1.specialtyInfo.nextUnlockSpecialIndex
    local nextStar = star + 1
    -- self._specialtyIcon:loadTexture(IconUtils.iconPath .. specials[1].icon .. ".jpg")
    -- self._specialtyName:setString(lang("HEROSPECIAL_" .. data.special))
    local label = self._desPanel
    self._desSizeH = 188
    local rtxMaxWidth = 0
    local haveHero = true
    if data.crehero then
    	haveHero = self._modelMgr:getModel("HeroModel"):checkHero(data.crehero)
    elseif data.heroD.unlock ~= nil then
    	haveHero = data.heroD.unlock
	end
	--2017.6.1 如果是npcHero 只判断星级够不够就行
	local isNpcHero
	if data.heroD and tab.npcHero[data.heroD.id or 0] then
		isNpcHero = true
	end
    if not data.showCurStarOnly then
	    self._desPanel:setContentSize(cc.size(499,428))
	    titleBg:setPosition(235,520)
	    for k, v in ipairs(specials) do
	    	local isLocked =  not haveHero or (haveHero and k>=nextStar) 
	    	if isNpcHero then
	    		isLocked = k>=nextStar
	    	end
	    	local specialCell = self:createSpecialCell(data,specials,k, isLocked)
	    	specialCell:setPosition(237,555-127*k)
	        label:addChild(specialCell)
	    end
	else
		self._desPanel:setContentSize(cc.size(499,90))
		titleBg:setPosition(235,180)
		local k = star -- 截取上一段代码
		local v = specials[1]
		for k1,v1 in pairs(specials) do
			if k1 == k then
				v = v1 
			end 
		end
		local specialCell = self:createSpecialCell(data,specials,k,k>=nextStar)
    	specialCell:setPosition(237,75)
        label:addChild(specialCell)
		self.node.offsetX = 60
		UIUtils.autoCloseTip = false
		self.posCenter = false
	end
	
end

function GlobalTipView:reflashMasteryPanel( data )
	self:reflashIconPanel(data)
	if data.heroD and data.isMastery then
		self:parseMastery(data)
	end
end

local skillEffect
local toolType = {"怪兽碎片","符文材料","经验材料","礼包","英雄宝物",[99]="资源道具",[98]="其他道具"}
-- 接收自定义消息
function GlobalTipView:reflashUI(data)
	self.posCenter = false
	UIUtils.autoCloseTip = not data.notAutoClose
	if data.posCenter then
		self.posCenter = data.posCenter
		UIUtils.autoCloseTip = false
	end
	self._bg:setOpacity(255)
	self._addtionPanel:removeAllChildren()
	self._addtionPanel:setContentSize(self._addtionInitSize)
	self._addtion = nil
	self._iconPanelTag:setString("")
	self._iconPanelTag:removeAllChildren()
	self._desPanel:removeAllChildren()
	-- [[ 宝物详情tip
	if not tonumber(self._treasureTipPanel) then
		self._treasureTipPanel:removeFromParent()
		self._treasureTipPanel = nil
		self._treasureTipPanel = 0
		self._panels[10] = self._treasureTipPanel
	end
	-- UIUtils:reloadLuaFile("guild.map.GuildMapEquipTipView")
	-- UIUtils:reloadLuaFile("treasure.TreasureTipView")
	-- UIUtils:reloadLuaFile("global.HeroAttrTipView")
	-- UIUtils:reloadLuaFile("global.HeroApAttrTipView")
	-- UIUtils:reloadLuaFile("global.HeroSingleAttrTipView")
	--]]
	self._des = nil
	self._subDes = nil 
	self._subTitle = nil
	 
	-- self._bg:setVisible(false)
	-- if true then return end
	local tipType = data.tipType
	self._tipType = tipType
	print("tip type ............",tipType)
	self._fixRotation = data.rotation
	if tipType then
		if tipType == 3 then
			if self._heroAttrPanel == 0 then
				self._heroAttrPanel = self._viewMgr:createLayer("global.HeroAttrTipView")
				self._bg:addChild(self._heroAttrPanel)
				self._panels[7] = self._heroAttrPanel
			end
		elseif tipType == 15 or tipType == 20 then
			if self._treasureTipPanel == 0 then
				self._treasureTipPanel = self._viewMgr:createLayer("treasure.TreasureTipView")
				self._bg:addChild(self._treasureTipPanel)
				self._panels[10] = self._treasureTipPanel
			end
		elseif tipType == 13 or tipType == 14 or tipType == 17 then
			if self._skillCdPanel == 0 then 
				self._skillCdPanel = self._viewMgr:createLayer("global.HeroSingleAttrTipView")
				self._bg:addChild(self._skillCdPanel)
				self._panels[9] = self._skillCdPanel
			end
		elseif tipType == 18 then
			if self._heroSkillMoralePanel == 0 then
				self._heroSkillMoralePanel = self._viewMgr:createLayer("global.HeroSkillMoraleTipView")
				self._bg:addChild(self._heroSkillMoralePanel)
				self._panels[13] = self._heroSkillMoralePanel
			end
		elseif tipType == 19 then
			if self._guildEquipTipPanel == 0 then
				self._guildEquipTipPanel = self._viewMgr:createLayer("guild.map.GuildMapEquipTipView")
				self._bg:addChild(self._guildEquipTipPanel)
				self._panels[11] = self._guildEquipTipPanel
			end
		elseif tipType == 21 then
			if self._heroApTipPanel == 0 then 
				self._heroApTipPanel = self._viewMgr:createLayer("global.HeroApAttrTipView")
				self._bg:addChild(self._heroApTipPanel)
				self._panels[12] = self._heroApTipPanel
			end	
		end
		self._currentPanel = self._panels[self._panelIdxMap[tipType]]
		self._currentPanel:setVisible(true)
		local dataD = {}
		print("tipType " , data.tipType)
		if data.id or data.tipType then
			if self["getDataDForTipType" .. data.tipType] then
				dataD = self["getDataDForTipType" .. data.tipType](self,data)
			else
				dataD = clone(data)
			end
		else
			dataD = clone(data)
		end
		if data.des and type(data.des) == "string" then
			self._des = data.des
		end
		if type(data.node) == "userdata" then
			self.node = data.node
		elseif type(data.node) == "table" then
			self.pos = data.node
		end
		self._reflashFuncs[self._panelIdxMap[tipType]](self,dataD)
		if self._panelIdxMap[tipType] ~= 7 and self._panelIdxMap[tipType] ~= 8 and self._panelIdxMap[tipType] ~= 11 then
			self:autoResize()
		end
		self:resetViewPos()
	else
	end
end


-- 重构reflashUI 
function GlobalTipView:getDataDForTipType1( data )
	local dataD = clone(tab:Tool(data.id))
	local _,hadNum = self._modelMgr:getModel("ItemModel"):getItemsById(data.id)
	if hadNum == 0 then
		if data.id == 39978 then -- payGem 特殊处理 gem在model里整合了 payGem freeGem等
			hadNum = self._modelMgr:getModel("UserModel"):getData()["gem"]
		else
			for k,v in pairs(IconUtils.iconIdMap) do
				if v == data.id then
					hadNum = self._modelMgr:getModel("UserModel"):getData()[k]
					break
				end
			end
		end
	end
	if data.id == 39977 or data.id == 39976 then -- 月卡特殊处理
		hadNum = 1 
	end
	if data.id == 39984 then -- arrowNum特殊处理
		hadNum = (hadNum + 1) / 111 
	end

	-- 骰子
	if data.id == 39985 then
		hadNum = self._modelMgr:getModel("AdventureModel"):getHadDiceNum() or 0
	end

	-- 军需币
	if data.id == 40009 then
		local userData = self._modelMgr:getModel("UserModel"):getData()
    	hadNum = userData["siegePropCoin"]
	end

	if data.battleSoulType and data.id == 40019 then
		hadNum = self._modelMgr:getModel("BattleArrayModel"):getBattleSoulNum(data.battleSoulType)
	end

	hadNum = hadNum or 0
	-- 英雄碎片 加 “/下级升星所需数目”
	local numTail = ""
    if dataD.typeId == 6 then
        local heroId = tonumber(string.sub(tostring(data.id),2,string.len(tostring(data.id))))
        heroD = tab:Hero(heroId)
        local heroData = self._modelMgr:getModel("HeroModel"):getHeroData(heroId)
        local desc = lang(dataD.des)
        if heroData then
            desc = lang(dataD["adddes"]) or desc
            desc = string.gsub(desc,"%b{}",function( )
                if heroD.starcost and heroD.starcost[heroData.star] and heroD.starcost[heroData.star][1] and heroD.starcost[heroData.star][1][3] then
                    numTail =  "/" .. heroD.starcost[heroData.star][1][3]
                    return heroD.starcost[heroData.star][1][3]
                else
                    if heroD.starcost[heroData.star] then
                        numTail = "/" .. heroD.unlockcost[3]
                    end
                    return heroD.unlockcost[3]
                end
            end)
        else  -- 没有英雄
            numTail = "/" .. heroD.unlockcost[3]
        end
        self._des = desc
    end

    if dataD.speciallDes then
        local level = dataD.speciallDes
        local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl
        if level > userlvl then
            desc = lang(dataD.des .. "_1")
            self._des = desc
        end
    end

	local rtxStr = ""
	if hadNum ~= nil then 
		rtxStr = "[color=fae6c8,fontsize=20]拥有[-][color=fae6c8,fontsize=20]".. ItemUtils.formatItemCount(hadNum)  .. numTail .."[-][color=fae6c8,fontsize=20]个[-]"
		if dataD.tabId == 1 --[[兵团碎片]] then
			local teamId = tonumber(string.sub(tostring(data.id),2,string.len(tostring(data.id))))
			local hadTeam = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(teamId)
			if hadTeam and lang(dataD.des .. "_1") then
				dataD.des = dataD.des .. "_1"
			end
		end
	end

	if data.hideTipNum then
		rtxStr = "[color=fae6c8,fontsize=20] [-]"
	end
	
	dataD._subDes = rtxStr--toolType[dataD.typeId]
	dataD._icon = IconUtils:createItemIconById({itemId = data.id,num=hadNum or 0,hideNumLab=true,forceColor=data.forceColor, eventStyle=0, battleSoulType = data.battleSoulType})
	dataD._icon:setScale(0.85)
	dataD._iconPos = cc.p(0,-10)
	if dataD.tabId == 1 --[[or dataD.tabId == 4]] then
		local teamId = tonumber(string.sub(tostring(data.id),2,string.len(data.id)))
		local teamD = tab:Team(teamId) or tab:Npc(teamId)
		if not teamD and string.find(data.id,"94") and string.len(data.id) == 5 then -- 觉醒兵团id
			teamId = tonumber(string.sub(data.id,3,5))
			teamD = tab:Team(teamId) or tab:Npc(teamId)
		end
		if teamD then
			dataD._iconPos = cc.p(0,-3)
			dataD._subTitle = "[color=fae6c8,fontsize=20]资质：[-][color=fae6c8,fontsize=20]" .. (self._modelMgr:getModel("TeamModel"):getTeamZiZhiText(teamD.zizhi)) .."[-]"
		end
	end
	-- 强转颜色
	dataD.color = data.forceColor or dataD.color

	-- 法术碎片特做 2017.9.21
    local isSlotSplice = string.sub(data.id,1,3) == "500"
    local sid = string.sub(data.id,4,string.len(data.id))
    sid = tonumber(sid)
	local skillD = tab.playerSkillEffect[sid] or tab.heroMastery[sid] 
	if isSlotSplice and skillD then
    	local isMastery = not tab.playerSkillEffect[sid]
		local skillName = "【" .. lang(skillD.name) .. "】"
		local addtionW = self._addtionPanel:getContentSize().width
		local addtionInitH = self._addtionPanel:getContentSize().height
		local addtion = ccui.Layout:create()
		addtion:setBackGroundColorOpacity(0)
		addtion:setBackGroundColorType(1)
		addtion:setPosition(0,0)
					
		-- local addtionH = 0 --math.ceil(#dataD.suit/4)*iconSize+rtxH+rtx1H
		-- local addtionW = 110 --4*(iconSize+5)
		self._addtionPanel:addChild(addtion)
		self._addtionPanel:setVisible(true)
		self._addtion = addtion

		local desOrign = self._des 
		local formationModel = ModelManager:getInstance():getModel("FormationModel")
		local defaultHeroData = formationModel:getFormationDataByType(formationModel.kFormationTypeCommon)
		local heroData = clone(ModelManager:getInstance():getModel("HeroModel"):getData()[tostring(defaultHeroData.heroId)])
		local isSlotMastery = not tab.playerSkillEffect[tonumber(sid) or 0]	
		self:getDataDForTipType2({id = sid,heroData = heroData,isSlotMastery = isSlotMastery})
		local desSkill = self._des
		desSkill = string.gsub(desSkill,"e07c44","ffeea0")
		desSkill = string.gsub(desSkill,"c98f55","ffeea0")
		desSkill = string.gsub(desSkill,"48b946","ffeea0")
		desSkill = string.gsub(desSkill,"fae0bc","ffeea0")
		desSkill = string.gsub(desSkill,"1ca216","ffeea0")
		desSkill = string.gsub(desSkill,"3D1F00","ffeea0")
		desSkill = string.gsub(desSkill,"fontsize=17","fontsize=20")
		self._des = desOrign
		print(desSkill,"YYYYYYYYYYYY")
		local rtx = RichTextFactory:create("[color = ffeea0,fontsize=20]" .. skillName .. desSkill ..  "[-]", addtionW+10, addtionH)
	    -- rtx:setVerticalSpace(-2)
	    rtx:formatText()
	    rtx:setName("skillDes")
	    local w = rtx:getInnerSize().width
	    local h = rtx:getInnerSize().height
	    local realW,realH = rtx:getRealSize().width,rtx:getRealSize().height
	    print("···",h,realH)
	    local addtionH = addtionInitH
	    if realH > addtionInitH then
	    	addtionH = realH+70
	    else
	    	addtionH = addtionInitH+70
		end
    	self._addtionPanel:setContentSize(cc.size(addtionW,addtionH))
    	addtion:setContentSize(cc.size(addtionW,addtionH))
		addtion:setPosition(0,0)
	    rtx:setPosition(-w/2+addtionW+10, -h/2+addtionH)
	    addtion:addChild(rtx, 99)
	    UIUtils:alignRichText(rtx, { hAlign = "center"})

	    local exDes = lang(isMastery and "skill_passive1" or"SKILLBOOK_TIPS119")
	    local exDesLab = ccui.Text:create()
	    exDesLab:setFontSize(20)
	    exDesLab:setFontName(UIUtils.ttfName)
	    exDesLab:getVirtualRenderer():setMaxLineWidth(addtionW+10)
	    exDesLab:setString(exDes)
	    exDesLab:setAnchorPoint(0,0)
	    exDesLab:setPosition(0,0)
	    exDesLab:setColor(cc.c3b(250,230,200))
	    addtion:addChild(exDesLab)

	    local split = ccui.ImageView:create()
	    split:loadTexture("globalImageUI12_cutline3.png",1)
	    split:setScale(2.8,0.5)
	    split:setPosition(addtionW*0.5,addtionH+10)
	    addtion:addChild(split)

	    local split = ccui.ImageView:create()
	    split:loadTexture("globalImageUI12_cutline3.png",1)
	    split:setScale(2.8,0.5)
	    split:setPosition(addtionW*0.5,60)
	    addtion:addChild(split)

	end
	return dataD
end


function GlobalTipView:getDataDForTipType2( data )
	print("skillType ",data.skillType)
	local dataD = clone(tab:PlayerSkillEffect(tonumber(data.id)))--只有这个是英雄技能！！与其他（专精专长）进行区别
	if not dataD then -- 英雄专精专长 
		local tail = ""
		local name 
		local des
		local isMastery -- false 是专精
		if data.heroData and data.heroData.star and not data.isSlotMastery then 
			tail = data.heroData.star
			if tail == 0 then 
				tail = 1
			end
			name = "HEROSPECIAL_" .. data.id
			des = ""
			self.posCenter = true
			UIUtils.autoCloseTip = false
			-- isMastery = true 专长 
			isMastery = true
		end
		dataD = clone(tab.heroMastery[tonumber(data.id .. tail)])
		dataD.isMastery = isMastery
		dataD.showCurStarOnly = data.showCurStarOnly
		if not isMastery and dataD.masterylv then -- 专精显示初中高级
			print(dataD.masterylv,"......")
			dataD._subDes = string.gsub(lang("HEROMASTERY_LV_" .. dataD.masterylv),"fontsize=18","fontsize=20")
			dataD.color = dataD.masterylv+1
		end
		-- if data.skillType then
		dataD._iconshape = "circle"
		-- end
		dataD.des = des or dataD.des
		self._des = lang(dataD.des)
		if string.find(lang(dataD.des),"morale") or string.find(lang(dataD.des),"addattr") or string.find(lang(dataD.des),"$artifactlv") then
			self._des = string.gsub(lang(dataD.des),"{[^}]+}",function( inStr )
				inStr = string.gsub(inStr,"{","")
				inStr = string.gsub(inStr,"}","")
				local function returnStrEnd( restr,tstr,num )
						local arr = {}
						num = num or 2
						local beginPos,endPos = string.find(restr,tstr,1)
						if beginPos and endPos then
							for i=1,num do
								table.insert(arr,string.sub(restr,beginPos+i+string.len(tstr)-1,beginPos+i+string.len(tstr)-1))
							end
						end
						if #arr == 0 then return false end
						return arr
				end
				-- 必须先替换morale1
				if dataD.morale1 then
					local rStr = returnStrEnd(inStr,"$morale1",2)
					if rStr then
						inStr = string.gsub(inStr,"$morale1" .. rStr[1] .. rStr[2],dataD.morale1[tonumber(rStr[1])][tonumber(rStr[2])])
					end
					local rStr = returnStrEnd(inStr,"$morale1",2)
					if rStr then
						inStr = string.gsub(inStr,"$morale1" .. tonumber(rStr[1]) .. tonumber(rStr[2]),dataD.morale1[tonumber(rStr[1])][tonumber(rStr[2])])
					end
				end
				if dataD.morale then
					local rStr = returnStrEnd(inStr,"$morale",2)
					if rStr then
						inStr = string.gsub(inStr,"$morale" .. rStr[1] .. rStr[2],dataD.morale[tonumber(rStr[1])][tonumber(rStr[2])])
					end
					local rStr = returnStrEnd(inStr,"$morale",2)
					if rStr then
						inStr = string.gsub(inStr,"$morale" .. tonumber(rStr[1]) .. tonumber(rStr[2]),dataD.morale[tonumber(rStr[1])][tonumber(rStr[2])])
					end
				end
				if dataD.formula then
					local rStr = returnStrEnd(inStr,"$formula",2)
					if rStr then
						inStr = string.gsub(inStr,"$formula" .. rStr[1] .. rStr[2],dataD.formula[tonumber(rStr[1])][tonumber(rStr[2])])
					end
					local rStr = returnStrEnd(inStr,"$formula",2)
					if rStr then
						inStr = string.gsub(inStr,"$formula" .. tonumber(rStr[1]) .. tonumber(rStr[2]),dataD.formula[tonumber(rStr[1])][tonumber(rStr[2])])
					end
				end
				if dataD.addattr then
					local rStr = returnStrEnd(inStr,"$addattr",2)
					if rStr then
						inStr = string.gsub(inStr,"$addattr" .. tonumber(rStr[1]) .. tonumber(rStr[2]),dataD.addattr[tonumber(rStr[1])][tonumber(rStr[2])])
					end
					local rStr = returnStrEnd(inStr,"$addattr",2)
					if rStr then
						inStr = string.gsub(inStr,"$addattr" .. rStr[1] .. rStr[2],dataD.addattr[tonumber(rStr[1])][tonumber(rStr[2])])
					end
				end
				local rStr = returnStrEnd(inStr,"$artifactlv",1)
				if rStr then
					local level = 1
					if data.skillLevel and data.skillLevel > 1 then
						level = data.skillLevel
					end
					inStr = string.gsub(inStr,"$artifactlv",level or 1)
				end
				local rStr = returnStrEnd(inStr,"$sklevel",1)
				if rStr then
					local level = 1
					if data.sklevel and data.sklevel > 1 then
						level = data.sklevel
					end
					inStr = string.gsub(inStr,"$sklevel",level or 1)
				end
				if string.len(inStr) > 0 then 
					local a = "return " .. inStr
                    local _number = string.format("%.4f", loadstring(a)())
		            inStr = BattleUtils.formatNumber(_number)
		        end
				return inStr
			end)
			self._des = self:changeStrColor(self._des)
		end
		dataD.name = name or dataD.name --"HEROSPECIAL_" .. data.id
	else -- 英雄技能tip
		if not data.heroData then
			local formationModel = ModelManager:getInstance():getModel("FormationModel")
			local defaultHeroData = formationModel:getFormationDataByType(formationModel.kFormationTypeCommon)
			data.heroData = clone(ModelManager:getInstance():getModel("HeroModel"):getData()[tostring(defaultHeroData.heroId)])
			data.heroData.id = defaultHeroData.heroId
		end
		-- dump(data.heroData,"data.id " .. data.id ,10)
		local attributes = data.attributes or BattleUtils.getHeroAttributes(data.heroData)
		-- dump(attributes,"attributes".. data.id,10)
		local skills = attributes.skills 
        local isReplaced, skillReplacedId = ModelManager:getInstance():getModel("HeroModel"):isNpcSpellReplaced(data.heroData,tonumber(data.heroData.id) or tonumber(data.heroData.heroId), data.id)
        if isReplaced then
            data.id = skillReplacedId
        end
        if data.treasureInfo or data.comId then
        	local comId = data.comId or data.treasureInfo and data.treasureInfo.id 
        	local transId = ModelManager:getInstance():getModel("TreasureModel"):getTransferSkillId(comId)
        	data.id = transId or data.id
        end
		local skillIndex
		for k,v in pairs(skills) do
			if tonumber(data.id) == tonumber(v[1]) then
				skillIndex = k
			end
		end
		if not skillIndex or data.skillLevel then
			skillIndex=1
			attributes.sklevel = data.skillLevel or 1
		else
			attributes.sklevel = data.heroData["sl" .. skillIndex] or ((skillIndex and data.heroData.spelllv) and data.heroData.spelllv[skillIndex]) or 1
		end
            
		-- if data.skillLevel == nil or data.skillLevel == 0 then 
		-- 	attributes.sklevel = 1
		-- else
		-- 	attributes.sklevel = data.skillLevel
		-- end

		local desRft = BattleUtils.getDescription(BattleUtils.kIconTypeSkill, data.id, attributes, skillIndex or 1, nil, data.battleType, data.spTalent) 
		-- desRft = string.gsub(desRft,"%[color=......","[color=ff9c00")
		desRft = self:changeStrColor(desRft,"ff9c00") 
		-- local i, j = string.gsub(s, pattern, repl[,n])

		self._des =  desRft
		dataD._iconshape = "circle"
		-- dataD._subDes = "[color=ff9c00, fontsize=18]" .. lang("OPTION_" ..dataD["option"]) .. "[-]"
		-- dataD._subTitle = "[color=fae6c8, fontsize=18]" .. names[dataD["dmgtag"]] .. "[-]" 
		local talentData = ModelManager:getInstance():getModel("SkillTalentModel"):getTalentAdd(data.id,data.spTalent)
		if dataD.manacost then --and not data._skillType then
			-- dump(dataD)
			local mcdData = attributes.MCD
		    local mcdAddition = 0
		    if dataD.type > 1 then
		        mcdAddition = (1 - mcdData[dataD.mgtype][dataD.type - 1] - mcdData[dataD.mgtype][5] - mcdData[4][dataD.type - 1] - mcdData[4][5])
		    else
		        mcdAddition = (1 - mcdData[dataD.mgtype][5] - mcdData[4][5])
		    end
		    if data.isNpc then
		    	mcdAddition = 1
		    end
		    local final = dataD.manacost[1]*mcdAddition
		    final = math.floor(final - talentData["$talent9"] - dataD.manacost[1]*talentData["$talent10"])
			-- desTable[#desTable+1] = "单次耗魔:[color = d7ad6a]".. data.manacost[1] .. "[-]"
			dataD._subTitle = "[color=fae6c8,fontsize=20]魔法消耗：[-][color=fae6c8,fontsize=20]".. final .. "[-]"
		end
		if dataD.cd then --and not data._skillType then
			-- desTable[#desTable+1] = "冷却时间:[color = d7ad6a]".. data.cd[1]/1000 .."s[-][][-]"math.round((dataD.cd[1] - (skillLevel-1)*dataD.cd[2]) / 100)/10
			local cdData = attributes.cd
		    local cdAddition = 0
		    if dataD.type > 1 then
		        cdAddition = (1 - cdData[dataD.mgtype][dataD.type - 1] - cdData[dataD.mgtype][5] - cdData[4][dataD.type - 1] - cdData[4][5])
		    else
		        cdAddition = (1 - cdData[dataD.mgtype][5] - cdData[4][5])
		    end
		    if data.isNpc then
		    	cdAddition = 1
		    end
		    local final = (dataD.cd[1] - ((attributes.sklevel or 1)-1)*dataD.cd[2]) / 100 / 10 * cdAddition
		    final = tostring(math.ceil(final - talentData["$talent11"] - dataD.cd[1]*talentData["$talent12"]/1000))
		    -- local cdStr = tostring(math.ceil((dataD.cd[1] - ((attributes.sklevel or 1)-1)*dataD.cd[2]) / 100 / 10 * cdAddition))
			dataD._subDes = "[color=fae6c8,fontsize=20]冷却时间：[-][color=fae6c8,fontsize=20]".. final .."秒[-][][-]"
		end
		local tag =  ccui.ImageView:create()
		tag:setAnchorPoint(cc.p(1,0.5))
		tag:loadTexture("globalImageUI_skilltag_"..(dataD["type"])..".png", 1)
		if self._iconPanelTag then
			self._iconPanelTag:addChild(tag)
		end
	end
	-- if dataD and dataD.masterylv then
	-- 	-- dataD._subDes = "[fontsize=18]" .. lang("HEROMASTERY_LV_" .. dataD.masterylv).."[-]"
	-- end

	if data.skillType then
		dataD._subDes = "[color=fae6c8,fontsize=20]类型：[-][color=fae6c8,fontsize=20]" .. (skillTp[data.skillType] or "自动") .."[-]"
		dataD._skillType = data.skillType
	end

	if dataD and data.heroData then
		dataD.heroD = clone(data.heroData)
		-- dataD.heroD.id = data.id
	end
	dataD.star =  data.star or dataD.star or( data.heroData and data.heroData.star) or 1

	if data.treasureInfo then -- 对宝物tip内容进行扩充
		local comId = data.treasureInfo.id
		local comTreasureD = tab.comTreasure[comId]
		local addTag = comTreasureD and comTreasureD.addtag 
		dataD._subDes = "[color=fae6c8,fontsize=20]类型：[-][color=fae6c8,fontsize=20]" .. (lang("BAOWUADDTAG_" .. addTag) or skillTp[data.skillType] or "自动") .."[-]"
		local stage = data.treasureInfo.stage
		local addtionW = self._addtionPanel:getContentSize().width
		local addtionInitH = self._addtionPanel:getContentSize().height
		local addtion = ccui.Layout:create()
		addtion:setBackGroundColorOpacity(0)
		addtion:setBackGroundColorType(1)
		addtion:setPositionX(0)
					
		local addtionH = 0 --math.ceil(#dataD.suit/4)*iconSize+rtxH+rtx1H
		local addtionW = 110 --4*(iconSize+5)
		addtion:setContentSize(cc.size(self._addtionPanel:getContentSize().width,addtionH))
		dataD.nameTail = "Lv." .. stage
		-- [[ 宝物技能额外部分
		local x,y = 0,0
		local offsetx,offsety = 0,45 --rtxH+15
		local disData = tab.comTreasure[comId]
	    local unlockData = disData.unlockaddattr
	    local addAttrsData = disData.addattr
	    local nextBuffId 
	    local limitCount = 1
	    local maxCount = 1
	    for i,v in ipairs(unlockData) do
	        if unlockData[i] > stage and not nextBuffId then
	            nextBuffId = unlockData[i]
	            limitCount = i
	        end 
	        maxCount = i
	    end
	    if not nextBuffId then 
	    	nextBuffId = table.nums(tab.devComTreasure) + 1  
	    	limitCount = maxCount
	    end
	    print(nextBuffId,"bfid",limitCount)
	    addtionH = 0 --32*(limitCount-1)
	    local addAttrItems = {}
	    -- 创建额外加成显示
	    for i=2,limitCount  do
	        local item = ccui.Layout:create()
            item:setBackGroundColorOpacity(0)
            item:setBackGroundColorType(1)
            item:setBackGroundColor(cc.c4b(216, 194, 156, 128))
            item:setOpacity(255)
            item:setContentSize(375, 32)
            item:setAnchorPoint(0,0)
            item:setPosition(offsetx,addtionH + offsety-i*32)
            table.insert(addAttrItems,item)
            addtion:addChild(item)
            

            local stageLab = ccui.Text:create()
            stageLab:setFontSize(20)
            stageLab:setFontName(UIUtils.ttfName)
            stageLab:setColor(cc.c3b(250, 230, 200))
            stageLab:setPosition(2,4)
            stageLab:setAnchorPoint(0,0.5)
            stageLab:setString("Lv." .. unlockData[i])
            item:addChild(stageLab)

	        local attr = addAttrsData[1][1]
	        local addValue = addAttrsData[1][2]



	        local des = lang("HEROMASTERYDES_" .. addValue .. math.max(i-1,1))
	        if des == "" then
	            des = lang("PLAYERSKILLDES2_" .. addValue .. math.max(i-1,1))
	        end
	        -- if i == 1 then
	        --     des = self:generateDes(1)
	        -- end

	        if stage < unlockData[i] then
	            des = "[color=646464,fontsize=18]" .. " " .. " " .. des .. "[-]"
	            stageLab:setColor(cc.c3b(100, 100, 100))
	        elseif stage <= unlockData[i]  then
	            des = "[color=fa921a,fontsize=18,outlinecolor=3c1e0aff,outlinesize=1]" .. " " .. " " .. des .. "[-]"
	            stageLab:setColor(cc.c3b(250, 146, 26))
	        else
	            des = "[color=fae6c8,fontsize=18]" .. des .. "[-][-]"
	            stageLab:setColor(cc.c3b(250, 230, 200))
	        end
	        -- print("des...",des)
	        if item:getChildByName("rtx") then
	            item:getChildByName("rtx"):removeFromParent()
	        end

	        local rtx = RichTextFactory:create(des or "",item:getContentSize().width-35,item:getContentSize().height)
	        rtx:formatText()
	        -- rtx:setVerticalSpace(5)
	        -- rtx:setAnchorPoint(cc.p(0,0))
	        local w = rtx:getInnerSize().width
	        local h = rtx:getInnerSize().height
	        local offsetY = 0
	        if h > 30 then
	        	offsetY = 0
	        end
	        rtx:setPosition(cc.p(w/2+50,item:getContentSize().height/2+offsetY))
	        UIUtils:alignRichText(rtx,{vAlign = "center",hAlign = "left"})
	        rtx:setName("rtx")
	        item:addChild(rtx)
	        -- 调整间距
	        local lineHeight = 32
	        if h <= lineHeight then 
	            h = lineHeight
	        else
	            h = math.ceil(h/lineHeight)*(lineHeight-5)
	        end 
	        -- if h > 32 then
	        item:setContentSize(cc.size(345,h))
	        -- end
	        local children = item:getChildren()
	        for _,child in pairs(children) do
	            local name 
	            if child.getName and child:getName() then 
	                name = child:getName()
	            end
	            if name == "rtx" then
	                child:setPositionY(math.max(16,h/2))
	            end
	            if name ~= "rtx" then
	                if h > lineHeight  then
	                    child:setPositionY(38)
	                else
	                    child:setPositionY(math.max(16,h/2))
	                end
	            end
	        end
	        addtionH = addtionH+math.max(h,lineHeight)
	        -- 调整间距end
	    end
		--]]
		local addHeight = addtionH
		for k,item in pairs(addAttrItems) do
		    local itemH = item:getContentSize().height
		    item:setPositionY(addHeight-itemH)
		    -- print("height...",addHeight-itemH)
		    addHeight = addHeight - itemH
		end
		
		addtion:setContentSize(cc.size(self._addtionPanel:getContentSize().width,addtionH))
		self._addtion = addtion
		self._addtionPanel:setContentSize(self._addtion:getContentSize())
		-- self._addtionPanel:setBackGroundImageOpacity(255)
		self._addtionPanel:addChild(addtion)
		self._addtionPanel:setVisible(true)
	end

	return dataD
end

-- function GlobalTipView:getDataDForTipType3( data )
-- 	local 
-- 	return dataD
-- end


-- 当英雄专精表和技能表有重合Id的时候，如果是子物体实现的就用技能表
-- 否则用英雄专精表
function GlobalTipView:isUseHeroMaster(id)
	local cfg1 = tab.heroMastery
	local cfg2 = tab.skill
	if cfg1[id] and cfg2[id] and cfg2[id].objectid then
		return false
	end 
	return true
end

--注意这里，兵团展示的时候获取兵团基础属性的时候数据没有，记住一定要重新初始化一下
--注意这里，兵团展示的时候获取兵团基础属性的时候数据没有，记住一定要重新初始化一下
--注意这里，兵团展示的时候获取兵团基础属性的时候数据没有，记住一定要重新初始化一下
function GlobalTipView:getTaamData(data)
    local _teamData = clone(data.teamData)
    if _teamData then
		_teamData.level = _teamData.level or data.level or 1
		_teamData.teamId = _teamData.teamId or _teamData.id
		_teamData.star = _teamData.star or _teamData.starlevel
		if not _teamData.el1 then
			if _teamData.equip then
				local e = _teamData.equip
				local s = _teamData.skill
				for i=1,7 do
					if type(e[i]) ~= "table" then
						e[i] = {}
						e[i].level = 1
						e[i].stage = 1
					end
					if type(s[i]) == "table" then 
						s[i] = 1
					end
			        _teamData["el" .. i] = e[i].level
			        _teamData["es" .. i] = e[i].stage
			        _teamData["sl".. i] = s[i]
			    end
			else
				for i=1,7 do
			        _teamData["el" .. i] = 1
			        _teamData["es" .. i] = 1
			        _teamData["sl".. i] = 1
			    end
			end
		end
    end
    return _teamData
end

-- 兵团技能tip
function GlobalTipView:getDataDForTipType4( data )
	-- dump(data,"========getDataDForTipType4========")
	local dataD = {}
	local isUseHeroMastery = self:isUseHeroMaster(data.id)
	for k,v in pairs(self._skillTabMap) do
		if isUseHeroMastery then
			if v[data.id] then
				dataD = clone(v[data.id])
				break
			end
		else
			if v[data.id] and v[data.id].class == nil then
				dataD = clone(v[data.id])
				break
			end 
		end 
		
	end
	self.posCenter = true
	UIUtils.autoCloseTip = false

	if data.level > 0 then
		if data.addLevel and data.addLevel > 0 then
			local add = string.format("[color=27f73a,fontsize=20](+%s)[-]",data.addLevel)
			dataD._subDes = "[color=fae6c8,fontsize=20][-][color=fae6c8,fontsize=20]Lv.".. data.level .."[-]"..add--lang(dataD.des1)
		else
			dataD._subDes = "[color=fae6c8,fontsize=20][-][color=fae6c8,fontsize=20]Lv.".. data.level .."[-]"--lang(dataD.des1)
		end
		
	else
		dataD._subDes = "[color=fae6c8,fontsize=20]未解锁[-]"
	end
	-- if dataD.label > 3 then
	if dataD.label then 
		dataD._label = "[color=f0c891,outlinesize=1]" .. (lang("TEAMSKILL_LABEL" .. dataD.label) or "").. "[-]"
		
		dataD._labelBg = "globalImageUI_tiplabelbg.png"
	end
	-- else
	-- 	dataD._label = "[color=81ff4e,outlinesize=1]" .. (lang("TEAMSKILL_LABEL" .. dataD.label) or "").. "[-]"
	-- end

	if data.teamData then
		local teamData = self:getTaamData(data)
		local desStr = lang(dataD.des)
		if not isUseHeroMastery and dataD.jxDes then
			desStr = lang(dataD.jxDes)
		end 
		if tab:Npc(teamData.teamId) then
			local atk = 1
			if data.teamData.a1 and type(data.teamData.a1)== "table" and #data.teamData.a1 == 2 then
				local skillLv = data.teamSkillS or data.level
				local a21 = (data.teamData.a2 and data.teamData.a2[1] or 100)
				local a22 = (data.teamData.a2 and data.teamData.a2[2] or 0)
				local a2Buff = (a21 + ((skillLv or 1) - 1) * a22)
                if data.teamSkillS then
                    a2Buff = 100+a2Buff
                end
				atk = (data.teamData.a1[1]+((skillLv or 1)-1)*data.teamData.a1[2])*a2Buff*0.01
                atk = math.floor(atk)
			end
			local level = data.addLevel and data.addLevel + data.level or data.level
			self._des = "[color=fae6c8,fontsize=20]" .. SkillUtils:handleSkillDesc(desStr, level or 1, atk, nil, nil) .. "[-]"
		else
			if teamData.volume == nil then 
				local vt = {25,16,9,4,1}
				teamData.volume = vt[tab.team[teamData.teamId].volume]
			end
			local level = data.addLevel and data.addLevel + data.level or data.level
			self._des = "[color=fae6c8,fontsize=20]" ..  SkillUtils:handleSkillDesc1(desStr, teamData, level) .. "[-]"
		end
	else
		local desStr = lang(dataD.des1)
		-- local mathStr = string.sub(desStr,string.find(desStr,"%{")+1,string.find(desStr,"%}")-1)
		-- mathStr = string.gsub(mathStr,"%$","")
		-- mathStr = string.gsub(mathStr,"ulevel","0")
		-- mathStr = string.gsub(mathStr,"level","1")
		-- mathStr = string.gsub(mathStr,"atk","1")
		-- local result = loadstring("return " .. mathStr)
		-- self._des = string.gsub(desStr, "%b{}",  TeamUtils.getNatureNums(result()))
		self._des = "[color=fae6c8,fontsize=20]" .. desStr.. "[-]"
	end
	dataD._icon = IconUtils:createTeamSkillIconById({teamSkill = dataD,teamData = data.teamData, eventStyle = 0})
	dataD._icon:setScale(107/dataD._icon:getContentSize().width)
	dataD._iconPos = cc.p(-10,-20)
	dataD.iconFrame = data.iconFrame
	-- 定制iconframe
    if dataD.iconFrame then
        local icon = dataD._icon
        local boxIcon = icon:getChildByFullName("boxIcon")
        boxIcon:loadTexture(dataD.iconFrame,1)
    end

	local addtionW = self._addtionPanel:getContentSize().width
	local addtionInitH = self._addtionPanel:getContentSize().height
	
	if dataD.suit then
		local iconSize = 80
		local addtion = ccui.Layout:create()
		addtion:setBackGroundColorOpacity(0)
		addtion:setBackGroundColorType(1)
		addtion:setPositionX(10)
		local rtxH = 0
		local rtx1H = 0
		local rtx
		local rtx1 -- 名词解释
		if dataD.suitdes then
			local skillText = lang(dataD.suitdes)
			if data.teamData then
                local teamData = self:getTaamData(data)
	            local teamid = teamData.teamid or teamData.teamId
	            if tab.team[teamid] then 
					local level = data.addLevel and data.addLevel + data.level or data.level
					skillText = SkillUtils:handleSkillDesc1(lang(dataD.suitdes), teamData,level)
	            end
			end
			local rtxStr = self:forceDefColor(skillText)
			rtx = RichTextFactory:create("[color=fae6c8,fontsize=20]" .. rtxStr .."[-]",addtionW-5,addtionInitH)
			rtx:formatText()
		    -- rtx:setVerticalSpace(5)
		    -- rtx:setAnchorPoint(cc.p(0,0))
		    local w = rtx:getInnerSize().width
		    local h = rtx:getInnerSize().height
		    rtxH = rtx:getRealSize().height
		    rtx:setPosition(w/2,h/2+10)
		    addtion:addChild(rtx)
		    UIUtils:alignRichText(rtx,{hAlign = "left",vAlign = "top"})
			
			local suitdes1 = string.gsub(dataD.suitdes,"_","1_")
			suitdes1 = self:forceDefColor(lang(suitdes1))
			rtx1 = RichTextFactory:create("[color=fae6c8,fontsize=20]" .. suitdes1 .."[-]",addtionW-5,addtionInitH)
			rtx1:formatText()
		    -- rtx:setVerticalSpace(5)
		    -- rtx:setAnchorPoint(cc.p(0,0))
		    local w = rtx1:getInnerSize().width
		    local h = rtx1:getInnerSize().height
		    rtx1H = rtx1:getRealSize().height
		    rtx1:setPosition(w/2,h/2+10)
		    addtion:addChild(rtx1)
			
		end
			
		local addtionH = math.ceil(#dataD.suit/4)*iconSize+rtxH+rtx1H
		local addtionW = 4*(iconSize+5)
		addtion:setContentSize(cc.size(self._addtionPanel:getContentSize().width,addtionH))
		if rtx then
			rtx:setPositionY(rtx:getPositionY()+ addtionH - rtx1H - rtxH)
			-- UIUtils:alignRichText(rtx,{hAlign = "left",vAlign = "top"})
		end
		if rtx1 then
			-- rtx1:setPositionY(rtx:getPositionY()-155)
			UIUtils:alignRichText(rtx1,{hAlign = "left",vAlign = "bottom"})
		end

		local x,y = 0,0
		local offsetx,offsety = 0,-rtxH+15
		for i,v in ipairs(dataD.suit) do
			local teamD = tab:Team(v)
			local teamIcon
			local teamData = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(v)
			if teamData then 
				local quality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(teamData.stage)
	 		    teamIcon = IconUtils:createTeamIconById({teamData = teamData, sysTeamData = teamD, quality = quality[1] , quaAddition = quality[2],eventStyle = 0})
			else
				teamIcon = IconUtils:createSysTeamIconById({sysTeamData = teamD,eventStyle=0})
				teamIcon:setColor(cc.c3b(128, 128, 128))
			end
			teamIcon:setScale(iconSize/teamIcon:getContentSize().width)
			-- [[ 换金边 by guojun 2017.1.16 rd: 9121
			local iconColor = teamIcon:getChildByName("iconColor")
			if iconColor then
				iconColor:loadTexture("globalImageUI_squality_jin.png",1)
				iconColor:setContentSize(cc.size(107, 107))
				iconColor:removeAllChildren()
			end
			--]]
			x = (i-1)%4*(iconSize+5)+offsetx
			y = addtionH - math.floor((i-1)/4+1)*(iconSize+5)+offsety
			teamIcon:setPosition(x,y)
			addtion:addChild(teamIcon)
		end
		self._addtion = addtion
		self._addtionPanel:setContentSize(self._addtion:getContentSize())
		local addtionBg = ccui.ImageView:create()
		addtionBg:loadTexture("specialty_bg_1_hero.png",1)
		addtionBg:setScale9Enabled(true)
		addtionBg:setCapInsets(cc.rect(25,25,1,1))
		addtionBg:setAnchorPoint(cc.p(0,0))
		addtionBg:setPosition(cc.p(0,0))
		addtionBg:setContentSize(cc.size(370,addtionH+15))
		self._addtionPanel:addChild(addtionBg,-1)
		-- self._addtionPanel:setBackGroundImageOpacity(255)
		self._addtionPanel:addChild(addtion)
		self._addtionPanel:setVisible(true)
		
	elseif dataD.suitdes1 then 
		local iconSize = 80
		local addtionW = self._addtionPanel:getContentSize().width
		local addtionInitH = self._addtionPanel:getContentSize().height
		local addtion = ccui.Layout:create()
		addtion:setBackGroundColorOpacity(0)
		addtion:setBackGroundColorType(1)
		addtion:setPositionX(10)
		local rtx1H = 0
		local rtx1 -- 名词解释
	
		local skillText = lang(dataD.suitdes1)

		if data.teamData then
            local teamData = self:getTaamData(data)
            local teamid = teamData.teamid or teamData.teamId
            if tab.team[teamid] then 
            	local level = data.addLevel and data.addLevel + data.level or data.level
				skillText = SkillUtils:handleSkillDesc1(lang(dataD.suitdes1), teamData, level)
            end
		end
		local suitdes1 = self:forceDefColor(skillText)
		rtx1 = RichTextFactory:create("[color=fae6c8,fontsize=20]" .. suitdes1 .."[-]",addtionW-5,addtionInitH)
		rtx1:formatText()
	    -- rtx:setVerticalSpace(5)
	    -- rtx:setAnchorPoint(cc.p(0,0))
	    local w = rtx1:getInnerSize().width
	    local h = rtx1:getInnerSize().height
	    rtx1H = rtx1:getRealSize().height
	    rtx1:setPosition(w/2,h/2+12.5)
	    addtion:addChild(rtx1)
			
		local addtionH = 10+rtx1H
		local addtionW = 4*(iconSize+5)
		addtion:setContentSize(cc.size(self._addtionPanel:getContentSize().width,addtionH))

		if rtx1 then
			-- rtx1:setPositionY(rtx:getPositionY()-155)
			UIUtils:alignRichText(rtx1,{hAlign = "left",vAlign = "center"})
		end		
		self._addtion = addtion
		-- self._addtionPanel:setContentSize(self._addtion:getContentSize())
		self._addtionPanel:setContentSize(cc.size(self._addtion:getContentSize().width,addtionH+15))

		local addtionBg = ccui.ImageView:create()
		addtionBg:loadTexture("specialty_bg_1_hero.png",1)
		addtionBg:setScale9Enabled(true)
		addtionBg:setCapInsets(cc.rect(25,25,1,1))
		addtionBg:setAnchorPoint(cc.p(0,0))
		addtionBg:setPosition(cc.p(0,0))
		addtionBg:setContentSize(cc.size(360,addtionH+15))
		self._addtionPanel:addChild(addtionBg,-1)
		-- self._addtionPanel:setBackGroundImageOpacity(255)
		self._addtionPanel:addChild(addtion)
		self._addtionPanel:setVisible(true)
	end

	-- 处理觉醒
	local isAwaked = TeamUtils:getTeamAwaking(data.teamData)
	if isAwaked then
		-- 索引要变换的id
		local preSkillId = data.id
		local transId = preSkillId
		local teamD = tab.team[data.teamData.teamId] or tab.npc[data.teamData.teamId]
		local transTeamD = teamD
		local curSkillIdx
		if teamD then
			local skill = teamD.skill
            if not skill then
                skill = TeamUtils.getNpcTableValueByTeam(teamD,"skill")
            end
			local skillIdxs = {}
			for i,v in ipairs(skill) do
				skillIdxs[v[2]] = i
			end
			curSkillIdx = skillIdxs[preSkillId]

			local tree = data.teamData.tree or {}
			local treeMap = {}
			for k,v in pairs(tree) do
				if v ~= 0 then
					local treeIdx = string.sub(k,2,2)
					local teamAwakeTree = teamD["talentTree" .. treeIdx]
					if teamAwakeTree[1] == curSkillIdx then
						transId = teamAwakeTree[v+1] and teamAwakeTree[v+1][2]
						for k1,v1 in pairs(self._skillTabMap) do
							if v1[data.id] then
								transTeamD = clone(v1[transId])
								break
							end
						end
						break
					end
				end
			end

			local talentTree = {}
			local _skill = teamD["skill"]
            if not _skill then
                _skill = TeamUtils.getNpcTableValueByTeam(teamD,"skill")
            end
			for i=1,3 do
			    local d = teamD["talentTree"..i]
			    local t = {}
			    if d then
			        t[1] = _skill[d[1]][2]      -- 对应的基础技能
			        t[2] = d[2][2]              -- 觉醒技能1
			        t[3] = d[3][2]              -- 觉醒技能2
			        table.insert(talentTree, t)
			    end
			end

			for i=1,3 do
				  local talentT = talentTree[i]
				  if data.id == talentT[2] or data.id == talentT[3] then
				  	 -- 替换成基础技能的名字
                     if tab.skill[talentT[1]] then
				  	    dataD.name = tab.skill[talentT[1]].name
                     elseif tab.skillPassive[talentT[1]] then
                        dataD.name = tab.skillPassive[talentT[1]].name
                     end 
				  end 
			end
		end

		if (transId and transId ~= preSkillId) or (transId and curSkillIdx == nil) then
			-- 加描述
			local transDes = transTeamD and lang(transTeamD.des) or lang("SKILLDES_" .. transId)
			if transTeamD and not string.find(transTeamD.des, "645252") then
				transDes = lang("SKILLDES_" .. transId)
			end 
			transDes = string.gsub(transDes,"645252","fae6c8")

			local rtx = RichTextFactory:create("[color=fae6c8,fontsize=20][-][color=fae6c8,fontsize=20]　觉醒效果[-][][-]" .. transDes .."[-]",addtionW,addtionInitH)
			rtx:formatText()
		    -- rtx:setVerticalSpace(5)
		    -- rtx:setAnchorPoint(cc.p(0,0))
		    local w = rtx:getInnerSize().width
		    local h = rtx:getInnerSize().height
		    rtxH = rtx:getRealSize().height
		    -- 加点
		    local potImg = ccui.ImageView:create()
		    potImg:loadTexture("globalImageUI11_0418DayTitleAdorn.png",1)
		    potImg:setPosition(8,h/2+10)
		    potImg:setPurityColor(247, 220, 205)
		    potImg:setScale(1.5)
		    rtx:addChild(potImg)
		    if not self._addtion then
				self._addtion = rtx
				local panelW,panelH = self._addtionPanel:getContentSize().width,self._addtionPanel:getContentSize().height
				panelH = math.max(panelH,h+20)
				self._addtionPanel:setContentSize(cc.size(panelW,panelH))
			    rtx:setPosition(w/2,-h/2 + 40)
			else
				local panelW,panelH = self._addtionPanel:getContentSize().width,self._addtionPanel:getContentSize().height
				panelH = panelH + h

				self._addtionPanel:setContentSize(cc.size(panelW,panelH))
				rtx:setPosition(w/2,panelH-h-h/2 + 20)
				-- local children = self._addtionPanel:getChildren()
				-- for k,child in pairs(children) do
				-- 	child:setPositionY(child:getPositionY()-h)
				-- end
			end
			self._addtionPanel:addChild(rtx)
		    UIUtils:alignRichText(rtx,{hAlign = "left",vAlign = "top"})
		    self._addtionPanel:setVisible(true)
		end
	end

	return dataD
end

function GlobalTipView:getDataDForTipType5( data )
	-- dump(data)
	local teamD = tab:Team(data.id) or tab:Npc(data.id)
	local id = teamD.race[1]
	local dataD = clone(tab:Race(id))
	dataD.des = dataD.racedes
	return dataD
end

function GlobalTipView:getDataDForTipType6( data )
	local teamD = tab:Team(data.id) or tab:Npc(data.id)
	local id = teamD.race[2]
	local dataD =clone(tab:Race(id))
	dataD._subDes = lang(dataD.racedes) 
	return dataD
end

function GlobalTipView:getDataDForTipType7( data )
	local teamD = tab:Team(data.id) or tab:Npc(data.id)
	local dataD = {}
	dataD.name = teamD.classname  or TeamUtils.getNpcTableValueByTeam(teamD,"classname")
	dataD.des = teamD.classdes or TeamUtils.getNpcTableValueByTeam(teamD,"classdes")
	dataD.art = teamD.classlabel or TeamUtils.getNpcTableValueByTeam(teamD,"classlabel")
	dataD._iconshape = "noFrame"
	return dataD
end

function GlobalTipView:getDataDForTipType8( data )
	local dataD = {}
	local teamD = tab:Team(data.id or data.teamData.id) or tab:Npc(data.id or data.teamData.id)
	dataD.name = teamD.name
	dataD.art = teamD.art1 or TeamUtils.getNpcTableValueByTeam(teamD,"art1")
	if data.teamData then
		local quality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(data.teamData.stage or 1) 
		dataD.quality = quality and quality[1] or 1
		local isAwaked = TeamUtils:getTeamAwaking(data.teamData)
		-- if isAwaked then
			local teamName = TeamUtils:getTeamAwakingTab(data.teamData) or teamD.name
			local teamData = data.teamData
			local teamTableData = tab:Team(teamData.teamId or teamData.id)
		    local quality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(teamData.stage or 1)  
            dataD._icon = IconUtils:createTeamIconById({teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],isShowOriginScore = true,eventStyle = 0})
			dataD._icon:setScale(0.8)
			dataD.name = teamName
		-- end
	end
	if data.teamData and data.teamData.level then 
		dataD._subDes = "[color=fae6c8,fontsize=20]Lv.[-][color=fae6c8,fontsize=20]".. data.teamData.level .."[-]"
		dataD.color = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(data.teamData.stage)[1]
		-- dataD._icon = IconUtils:createSysTeamIconById({sysTeamData = teamD, isGray = false ,eventStyle = 0})
	end
	local des = {}
	table.insert(des,"[color=fae6c8,fontsize=20]".. lang(tab:Race(teamD.race[1]).name) .. "、" .. lang(teamD.classname) .."[-][][-]")
	table.insert(des,lang(teamD.des))
	dataD.des = des 
	return dataD
end

function GlobalTipView:getDataDForTipType9( data )
	local dataD = {}
	local sysTeamData = data.sysTeamData
	if not data.sysTeamData then
		sysTeamData = tab:Team(data.id)
	end
	if not sysTeamData then
		sysTeamData = tab:Npc(data.id)
	end
	dataD.name = sysTeamData.name 
	dataD.art = sysTeamData.art1 or TeamUtils.getNpcTableValueByTeam(sysTeamData,"art1")
	-- dataD._subDes = "[color=01ff25]Lv.".. data.sysTeamData.level .."[-]"
	local des = {}
	table.insert(des,"[color=fae6c8,fontsize=20]".. lang(tab:Race(sysTeamData.race[1]).name) .. "、" .. lang(sysTeamData.classname or tab:Race(sysTeamData.race[2]).name) .."[-][][-]")
	table.insert(des,lang(sysTeamData.des))
	dataD.des = des
	local npc = tab:Npc(data.id) or tab:Team(data.id)
	dataD.color = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(npc.stage or 1)[1]
	return dataD
end

function GlobalTipView:getDataDForTipType11( data )
	local dataD = {}
	dataD._icon = ccui.ImageView:create(IconUtils.iconPath .. "h_prof_" .. (data.id or 1) ..".png", 1)
	dataD._iconPos = cc.p(50,55)
	local desStr = string.format("HERO_PROFESSION_%02d",data.id or 1)
	dataD.name = desStr

	return dataD
end


function GlobalTipView:getDataDForTipType12( data )
	local dataD = {}
	dataD.name = data.name
 	dataD.des = data.desStr
	dataD.art = data.art
	return dataD
end

-- tip类型 13 获得属性值的辅助函数
function GlobalTipView:genCDAttrs( data,id,skillLevel )
	local attrs = {}
	local attributes = data.attributeValues
	local cdData = attributes.cd
	local skillD = tab.playerSkillEffect[id]
	local cdAddition = 0
	if skillD.type > 1 then
	    cdAddition = (1 - cdData[skillD.mgtype][skillD.type - 1] - cdData[skillD.mgtype][5] - cdData[4][skillD.type - 1] - cdData[4][5])
	else
	    cdAddition = (1 - cdData[skillD.mgtype][5] - cdData[4][5])
	end
	local skillLevel = data.skillLevel
	if attributes.skills then
		local addLevel = 0
	    for k,v in pairs(attributes.skills) do
	        local sid = v[1]
	        if id == sid then
	            addLevel = v[2]-skillLevel
	            break
	        end
	    end
	    skillLevel = skillLevel+addLevel
	end
	local cdNoAddtion = tonumber((skillD.cd[1] - ((skillLevel or 1)-1)*skillD.cd[2]) / 100 / 10)
	local cd = tonumber((skillD.cd[1] - ((skillLevel or 1)-1)*skillD.cd[2]) / 100 / 10 * cdAddition)
	attrs.attr = cd
	local attrMap = {"","heroAttrEx_talent","heroAttrEx_mastery","heroAttrEx_special","heroAttrEx_treasure",}
	for i=2,5 do
		local attrD = attributes[attrMap[i]].cd
		local cdData = attrD
		local cdAddtion = 0
		if skillD.type > 1 then
		    cdAddition = cdData[skillD.mgtype][skillD.type - 1] + cdData[skillD.mgtype][5] + cdData[4][skillD.type - 1] + cdData[4][5]
		else
		    cdAddition = cdData[skillD.mgtype][5] + cdData[4][5]
		end
		attrs["attr" .. i] = cdAddition * cdNoAddtion
		if attrs["attr" .. i] < 1 and cdAddition * cdNoAddtion > 0 then
			attrs["attr" .. i] = cdAddition * cdNoAddtion --math.floor(cdAddition*100) .. "%"
		end
		print("dataD[attr ..".. i .."]",attrs["attr" .. i],"\n","skillLevel",skillLevel)
	end
	attrs.attr1 = cdNoAddtion
	return attrs
end

-- 英雄技能 cd的tip cd 受 宝物专精专长学院等影响会变短
function GlobalTipView:getDataDForTipType13( data )
	local dataD = {}
	local skillD = tab.playerSkillEffect[data.id]
	dataD.name = skillD.name
	dataD.art = "globalImageUI_mona_dark.png"
	dataD.kind = "冷却"
	dataD.subDes = "冷却时间" 
	dataD.unit = "秒"
	dataD.negative = "-"
 	local attrs = self:genCDAttrs(data,data.id,data.skillLevel)
 	dataD.des = lang("HERO_ATTRIBUTE_CD") -- "冷却时间:" .. attrs.attr
 	for k,v in pairs(attrs) do
 		dataD[k] = v
 	end
 	if data.originId then
 		local oAttrs = self:genCDAttrs(data,data.originId,data.skillLevel)
 		dataD.attr4 = dataD.attr4+oAttrs.attr1-dataD.attr1
 		dataD.attr1 = oAttrs.attr1
 	end
 	-- 新增魔法天赋
 	local spTalent = self._modelMgr:getModel("SkillTalentModel"):getTalentDataInFormat()
    local value = self._modelMgr:getModel("SkillTalentModel"):getTalentAdd(data.id,spTalent)
    local subVal = value["$talent11"] or 0
	local mutiVal = value["$talent12"] or 0
	attrs["attr7"] = (attrs["attr1"] or 0)*mutiVal + subVal 
	dataD["attr7"] = attrs["attr7"]
	if attrs["attr7"] then
		dataD["attr"] = dataD["attr"] - dataD["attr7"]
	end
 	dump(attrs)
	return dataD
end

-- 辅助函数 计算mcd
-- 因为专长会改变技能id 所以提取出 计算函数，用于计算专长导致变化的值
-- id可选没变的和变化之后的 
function GlobalTipView:genMCDAttrs( data,id,skillLevel )
	local attrs = {}
	local skillD = tab.playerSkillEffect[id]
	local attributes = data.attributeValues
	 	
	local mcdData = attributes.MCD
    local mcdAddition = 0

    if skillD.type > 1 then
        mcdAddition = (1 - mcdData[skillD.mgtype][skillD.type - 1] - mcdData[skillD.mgtype][5] - mcdData[4][skillD.type - 1] - mcdData[4][5])
    else
        mcdAddition = (1 - mcdData[skillD.mgtype][5] - mcdData[4][5])
    end
    -- local MCD = string.format("%.1f", (skillD.manacost[1]*mcdAddition))
    local MCD = (string.format("%.2f", skillD.manacost[1] - (skillLevel-1) * skillD.manacost[2]) * mcdAddition)
    local cdNoAddtion = string.format("%.2f",(skillD.manacost[1]))

	attrs.attr = MCD
	local attrMap = {"","heroAttrEx_talent","heroAttrEx_mastery","heroAttrEx_special","heroAttrEx_treasure",}
		-- dump(attributes)
	for i=2,5 do
		local attrD = attributes[attrMap[i]].MCD
		local mcdData = attrD
		local mcdAddition = 0
		if skillD.type > 1 then
	        mcdAddition = (1 - mcdData[skillD.mgtype][skillD.type - 1] - mcdData[skillD.mgtype][5] - mcdData[4][skillD.type - 1] - mcdData[4][5])
	    else
	        mcdAddition = (1 - mcdData[skillD.mgtype][5] - mcdData[4][5])
	    end
		attrs["attr" .. i] = string.format("%.2f",((1-mcdAddition) * cdNoAddtion))
	end
	attrs.attr1 = cdNoAddtion
	dump(attrs)
	return attrs
end

-- 英雄魔法消耗 的tip MCD 受 宝物专精专长学院等影响会变少
function GlobalTipView:getDataDForTipType14( data )
	local dataD = {}
	local skillD = tab.playerSkillEffect[data.id]
	dataD.name = skillD.name
	dataD.art = "globalImageUI_monaCd_dark.png"
	dataD.kind = "耗魔"
	dataD.subDes = "消耗魔法" 
	dataD.negative = "-"
	local attrs = self:genMCDAttrs(data,data.id,data.skillLevel)
 	dataD.des = lang("HERO_ATTRIBUTE_MANACOST") --"消耗魔法:" .. attrs.attr
 	for k,v in pairs(attrs) do
 		dataD[k] = v
 	end
 	print("data.originId",data.originId)
 	if data.originId then
 		local oAttrs = self:genMCDAttrs(data,data.originId,data.skillLevel)
 		dataD.attr4 = dataD.attr4+oAttrs.attr1-dataD.attr1
 		dataD.attr1 = oAttrs.attr1
 	end
 	-- 新增魔法天赋
 	dump(attrs)
 	local spTalent = self._modelMgr:getModel("SkillTalentModel"):getTalentDataInFormat()
    local value = self._modelMgr:getModel("SkillTalentModel"):getTalentAdd(data.id,spTalent)
    local subVal = value["$talent9"] or 0
	local mutiVal = value["$talent10"] or 0
	attrs["attr7"] = (attrs["attr1"] or 0)*mutiVal + subVal
	dataD["attr7"] = attrs["attr7"]
	if attrs["attr7"] then
		dataD["attr"] = dataD["attr"] - dataD["attr7"]
	end 
	return dataD
end

-- 宝物详情tip
function GlobalTipView:getDataDForTipType15( data )
	return data
end
-- 宝物详情tip
function GlobalTipView:getDataDForTipType20( data )
	data.showAllTreasure = true
	return data
end
-- 纯显示内容
function GlobalTipView:getDataDForTipType16( data )
	return data
end

-- 英雄初始魔法
function GlobalTipView:getDataDForTipType17( data )
	local dataD = {}
	dataD.art = "globalImageUI_baseMagic_dark.png"
	dataD.name = "魔法"
	dataD.subDes = "初始魔法" 
	-- dataD.attrs = data.attrs
	for i=1,6 do
 		dataD["attr" .. i] = data["attr" .. i]
 	end
 	dataD["attr"] = data["attr"] or data["attr6"]
 	dataD.des = lang("HERO_ATTRIBUTE_MANA")
	return dataD
end

-- 英雄回魔
function GlobalTipView:getDataDForTipType18( data )
	local dataD = {}
	dataD.art = "globalImageUI_magicRecover_dark.png"
	dataD.name = "回魔"
	dataD.subDes = "回复魔法" 
	dataD.unit = "/秒"
	dataD.averageMCD = data.averageMCD
	dataD.slotMCD = data.slotMCD
	for i=1,7 do
 		dataD["attr" .. i] = data["attr" .. i]
 	end
 	dataD["attr"] = data["attr"] or data["attr7"]
 	dataD.des = lang("HERO_ATTRIBUTE_MANAREC")
	return dataD
end

-- 英雄回魔
function GlobalTipView:getDataDForTipType19( data )
	return {id = data.id}
end

-- 英雄法伤数据
function GlobalTipView:getDataDForTipType21( data )
	local dataD = {}
	print("英雄法伤数据-----------")
	dataD.art = "icon_damage_hero.png"
	dataD.name = "法伤"
	dataD.subDes = "法术伤害" 
	for i=1,6 do
 		dataD["attr" .. i] = data["attr" .. i]
 	end
 	dataD["attr"] = data["attr"] or data["attr6"]
 	dataD.des = "英雄法术伤害"-- lang("HERO_ATTRIBUTE_MANAREC")
 	dataD.unit = "%"
	return dataD
end

function GlobalTipView:getDataDForTipType22( data )
	local EquipData = tab:SiegeEquip(data.id)
	local dataD = {}
	dataD.des = EquipData.des
	self._des = lang(dataD.des)
	if self._des == "" or not self._des then
		self._des = "文字描述文字描述文字描述文字描述文字描述文字描述文字描述文字描述文字描述文字描述文字描述"
	end
	dataD._icon = IconUtils:createWeaponIcon({itemId = data.id, effect = true})
	dataD._icon:setScale(0.85)
	dataD._iconPos = cc.p(0,-10)
	local des = {
		"杀伤专精",
		"护甲专精",
		"辅助专精"
	}
	local rtxStr = ""
	for _,data in pairs (EquipData.showintproperty) do 
		rtxStr = rtxStr .. "[color=fae6c8,fontsize=20]" .. des[data[1]] .. ":[-]"
		rtxStr = rtxStr .. "[color=00ff1e,fontsize=20]" .. "+" .. data[2] .. "~" .. data[3] .. "[-]" .. "[color=fae6c8,fontsize=20](满级属性)[-][-][][-]"
	end
	for _,data in pairs (EquipData.showpercent) do 
		rtxStr = rtxStr .. "[color=fae6c8,fontsize=20]" .. des[data[1]] .. "百分比:[-]"
		rtxStr = rtxStr .. "[color=00ff1e,fontsize=20]" .. "+" .. data[2] .. "%[-]" .. "[color=fae6c8,fontsize=20](满级属性)[-][-][][-]"
	end

	dataD._subDes = rtxStr
	dataD.desConSize = cc.size(300,90)
	dataD.adjust = {-10,54}
	return dataD
end

-- 攻城器械配件
function GlobalTipView:getDataDForTipType23( data )
	local dataD = {}
	-- icon = self:createIcon(data.art or data.icon,data.color or data.quality or data.stage or 1,{shape = data._iconshape,treasure = string.sub((data.id or "n"),1,1) == "4" },data.iconFrame )
	local id = data.id 
	local weaponD = tab.siegeEquip[id]
	dataD.art = weaponD.art
	dataD.quality = weaponD.quality
	dataD.quality_show = weaponD.quality_show
	dataD.name = weaponD.name
    local param = {itemId = id, level = level, itemData = weaponD, quality = weaponD.quality_show, iconImg = weaponD.art, eventStyle = 0}
	dataD._icon = IconUtils:createWeaponsBagItemIcon(param)        
	dataD._icon:setScale(0.9)
	dataD._icon:setAnchorPoint(0,0.15)
	dataD._iconshape = "circle"
	local levelLab = dataD._icon:getChildByName("iconColor") and dataD._icon:getChildByName("iconColor").lvlLabel
	if levelLab then
		levelLab:setVisible(false)
	end
	self._des = weaponD.des
	local wType = weaponD.type
	local level = data.level or 1
	local tagImgName = "weaponImageUI_propsType".. wType ..".png"
	dataD._subDes = "[color=fae6c8,fontsize=20]类型：[-][pic = ".. tagImgName .."] [-][][-]"
					.. "[color=fae6c8,fontsize=20]等级：Lv.".. level  .."[-]"
	if data.showMax then
		dataD._subDes = dataD._subDes .. "[color=f4914e,fontsize=20]　<满级预览>[-]"
	end
	dataD.adjust = {3,30}

	-- 展示战斗力属性
	local addtionW = self._addtionPanel:getContentSize().width
	local addtionInitH = self._addtionPanel:getContentSize().height
	local addtion = ccui.Layout:create()
	addtion:setBackGroundColorOpacity(0)
	addtion:setBackGroundColorType(1)
	addtion:setPosition(0,0)
				
	-- local addtionH = 0 --math.ceil(#dataD.suit/4)*iconSize+rtxH+rtx1H
	-- local addtionW = 110 --4*(iconSize+5)
	self._addtionPanel:addChild(addtion)
	self._addtionPanel:setVisible(true)
	self._addtion = addtion

	-- 加战斗力
	local baseScore = tab.siegePower[level] and tab.siegePower[level]["power" .. weaponD.quality]
	local score = math.floor(weaponD.powerratio*baseScore)
	local zhandouliLab = ccui.TextBMFont:create("a" .. score, UIUtils.bmfName_zhandouli_little)
    zhandouliLab:setAnchorPoint(cc.p(0,0))
    zhandouliLab:setPosition(260,2)
    zhandouliLab:setScale(.5)
    addtion:addChild(zhandouliLab,99)

	local attrMap = {"杀伤专精","护甲专精","辅助专精"}
	local attrStr = ""
	local intproperty = weaponD.intproperty
	for i,v in ipairs(intproperty) do
		local attrName = lang("SIEGEWEAPONT_" .. (v[1] or 1)) -- or attrMap[(v[1] or 1)]
		local attrNum = (v[2] or 0)+(level-1)*(v[3] or 0)
		attrStr = attrStr .. "[color=fae6c8,fontsize=20]" .. attrName .. "+" .. attrNum .."[-]"
			.. "[color=1ca216,fontsize=20](成长+".. (v[2] or 0) ..")[-]" .."[][-]"
	end

	local rtx1 = RichTextFactory:create(attrStr,addtionW,addtionInitH)
	rtx1:formatText()
    -- rtx:setVerticalSpace(5)
    -- rtx:setAnchorPoint(cc.p(0,0))
    local w1 = rtx1:getInnerSize().width
    local h1 = rtx1:getInnerSize().height
    rtx1:setPosition(cc.p(w1/2,-h1/2))
    UIUtils:alignRichText(rtx1,{vAlign = "bottom",hAlign = "left"})
    rtx1:setName("rtx1")
    addtion:addChild(rtx1)

    attrStr = ""
	local needLvls = tab.setting["SIEGE_EQUIP_LV"] and tab.setting["SIEGE_EQUIP_LV"].value
	for i=1,6 do
		local percent = weaponD["percent" .. i]
		if percent then
			local attrName = lang("SIEGEWEAPONTS_" .. (percent[1] or 1)) --attrMap[(percent[1] or 1)]
			local attrNum = (percent[2] or 0) .. "%"
			local isOpen = level >= needLvls[i]
			local color = isOpen and "fae6c8" or "a8a8a8"
			local tail = isOpen and "" or "[color=".. color ..",fontsize=20](配件" .. needLvls[i] .."级激活)[-]" 
			attrStr = attrStr .. "[color=".. color ..",fontsize=20]" .. attrName .. "+" .. attrNum .."[-]" .. tail .."[][-]"
		end
	end
	local rtx = RichTextFactory:create(attrStr,addtionW,addtionInitH)
	rtx:formatText()
    -- rtx:setVerticalSpace(5)
    -- rtx:setAnchorPoint(cc.p(0,0))
    local w = rtx:getInnerSize().width
    local h = rtx:getInnerSize().height
    rtx:setPosition(cc.p(w/2,-h/2))
    UIUtils:alignRichText(rtx,{vAlign = "bottom",hAlign = "left"})
    rtx:setName("rtx")
    addtion:addChild(rtx)

    local scoreH = zhandouliLab:getContentSize().height
    local panelH = h+h1+scoreH+20
    addtion:setContentSize(cc.size(addtionW,panelH))

    rtx1:setPosition(w/2,panelH-h1/2-scoreH-10)
    rtx:setPosition(w/2,panelH-h1-h/2-scoreH-18)
    zhandouliLab:setPosition(0,panelH-scoreH+6)
    self._addtionPanel:setContentSize(cc.size(addtionW,panelH))
    self._addtionPanel:setVisible(true)

	return dataD
end

-- 攻城器械技能
function GlobalTipView:getDataDForTipType24( data )
	local dataD = {}
	-- icon = self:createIcon(data.art or data.icon,data.color or data.quality or data.stage or 1,{shape = data._iconshape,treasure = string.sub((data.id or "n"),1,1) == "4" },data.iconFrame )
	local id = data.id 
	local skillD = tab.siegeSkillDes[id] or tab.siegeSkillDes[1] 
	dataD.art = skillD.art or skillD.image
	dataD.name = skillD.name
	dataD.iconFrame = skillD.passive and "globalImageUI_skillWeaponFrame1.png" or "globalImageUI_skillWeaponFrame.png"
	dataD._iconshape = "circle"
	dataD._iconPos = cc.p(0,skillD.passive and 0 or -10)
	local des = "[color=fae6c8,fontsize=20]" .. lang(skillD.des1) .. "[-]"
	-- 解析des
	local attValueMap = data.attrValue or {}
	des = string.gsub(des,"{[^}]+}",function( inStr )
		inStr = string.gsub(inStr,"{","")
		inStr = string.gsub(inStr,"}","")
		if string.find(inStr,"$atk") then
			inStr = string.gsub(inStr,"$atk",attValueMap[1] or 0)
		end
		if string.find(inStr,"$def") then
			inStr = string.gsub(inStr,"$def",attValueMap[2] or 0)
		end
		if string.find(inStr,"$int") then
			inStr = string.gsub(inStr,"$int",attValueMap[3] or 0)
		end

		if string.len(inStr) > 0 then 
            local a = "return " .. inStr
            print("inStr for caculate",inStr)
            inStr = TeamUtils.getNatureNums(loadstring(a)())
        end
		return inStr
	end)

	dataD.des = des 
    -- self._des = des

    dataD._subDes = des --
    -- 预判断高度
    local detectRtx = RichTextFactory:create(dataD._subDes,260,100)
	detectRtx:formatText()
    local detectH = detectRtx:getInnerSize().height

    dataD.adjust = {3,15-3+detectH/2}
    dataD._label = "[color=fae6c8,fontsize=16]" .. lang(skillD.cd or "").. "[-]"
    dataD._labelOffset = {20,5-detectH/2-3}

    -- 额外展示
    local rtxStr = ""
    local pots = {}
    local moreDesCount = 0
    for i=2,4 do
    	if skillD["des" .. i] then
		    rtxStr = rtxStr .. lang(skillD["des" .. i] or "") .. "[][-]"  
	    end 	
    end
    rtxStr = "[color=ffeea0,fontsize=20]" .. rtxStr .. "[-]"
	local addtionW = self._addtionPanel:getContentSize().width
	local addtionInitH = self._addtionPanel:getContentSize().height
	local addtion = ccui.Layout:create()
	addtion:setBackGroundColorOpacity(0)
	addtion:setBackGroundColorType(1)
	addtion:setPosition(0,0)
				
	self._addtionPanel:addChild(addtion)
	self._addtionPanel:setVisible(true)
	self._addtion = addtion
	local rtx = RichTextFactory:create(rtxStr,addtionW,addtionInitH)
	rtx:formatText()
    -- rtx:setVerticalSpace(5)
    -- rtx:setAnchorPoint(cc.p(0,0))
    local w = rtx:getInnerSize().width
    local h = rtx:getInnerSize().height
    rtx:setPosition(cc.p(w/2,-h/2))
    UIUtils:alignRichText(rtx,{vAlign = "bottom",hAlign = "left"})
    rtx:setName("rtx")
    addtion:addChild(rtx)

    local panelH = h+(detectH-70)+10
    addtion:setContentSize(cc.size(addtionW,panelH))

    rtx:setPosition(w/2+15,panelH-h/2+(70-detectH))
    for i=1,3 do
    	-- 加点
    	if skillD["des" .. (i+1)] then
		    local potImg = ccui.ImageView:create()
		    potImg:loadTexture("globalImageUI11_0418DayTitleAdorn.png",1)
		    potImg:setPosition(-15,i*25-30)
		    potImg:setPurityColor(255, 238, 160)
		    potImg:setScale(1.2,1)
		    rtx:addChild(potImg)
		    table.insert(pots,potImg)
		end
    end
    self._addtionPanel:setContentSize(cc.size(addtionW,panelH))
    self._addtionPanel:setVisible(true)
	return dataD
end

-- 圣徽tip
function GlobalTipView:getDataDForTipType25( data )
--	dump(data,"25data")
	local typeNameStr = {
		[1] = "守序",
		[2] = "善良",
		[3] = "中立",
		[4] = "混乱",
		[5] = "邪恶"
	}
	
	local dataD = {}
	dataD.art = data.runeData.tabConfig.icon
	dataD.name = data.runeData.tabConfig.name
	dataD.id = data.runeData.tabConfig.id
	dataD._icon = IconUtils:createTeamHolySuitIcon(data.runeData)
	dataD._icon:setEnabled(false)
	dataD._icon:setScale(0.9)
	dataD._iconPos = cc.p(40,45)
	dataD.quality = data.runeData.quality
	dataD._subDes = string.format("类型:%s", typeNameStr[data.runeData.tabConfig.type])
	dataD._subColor = cc.c4b(250, 230, 200, 255)
	dataD.adjust = { 0, 5 }
	local des = data.runeData.amountStr and lang("RUNE_TIPS_4") or lang("RUNE_TIPS_7")
	self._des = des
	dataD.des = self._des
	-- dump(dataD,"dartaDl...")
	-- 填充addtionPanel内容
	local addtionW = self._addtionPanel:getContentSize().width
	local addtionInitH = self._addtionPanel:getContentSize().height
	local addtion = ccui.Layout:create()
	addtion:setBackGroundColorOpacity(0)
	addtion:setBackGroundColorType(1)
	addtion:setPosition(0,0)
	-- 将需要添加的东西加在addtion上，加完之后设置高度
	
	data.desc = string.gsub(data.desc, "645252", "fae6c8")
	local richText = RichTextFactory:create(data.desc, addtionW-20, 0)
    richText:formatText()
	richText:setAnchorPoint(cc.p(0.5, 1))
    addtion:addChild(richText)
	local panelH = richText:getRealSize().height
	
	local richText2, richText3
	if data.desc2 then
		data.desc2 = string.gsub(data.desc2, "645252", "fae6c8")
		richText2 = RichTextFactory:create(data.desc2, addtionW-20, 0)
		richText2:formatText()
		richText2:setAnchorPoint(cc.p(0.5, 1))
		addtion:addChild(richText2)
		panelH = panelH + richText2:getRealSize().height+10
	end
	
	if data.desc3 then
		data.desc3 = string.gsub(data.desc3, "645252", "fae6c8")
		richText3 = RichTextFactory:create(data.desc3, addtionW-20, 0)
		richText3:formatText()
		richText3:setAnchorPoint(cc.p(0.5, 1))
		addtion:addChild(richText3)
		panelH = panelH + richText3:getRealSize().height
	end
	

	self._adjustHeight = 50+panelH/2
    addtion:setContentSize(cc.size(addtionW,panelH))
	
	local posY = panelH
    richText:setPosition(addtionW/2, posY)
	if richText2 then
		posY = posY - richText:getRealSize().height - 5
		richText2:setPosition(addtionW/2, posY)
	end
	if richText3 then
		posY = posY - richText2:getRealSize().height - 5
		richText3:setPosition(addtionW/2, posY)
	end
	
	self._addtionPanel:addChild(addtion)
	self._addtionPanel:setVisible(true)
	self._addtion = addtion
	self._addtionPanel:setContentSize(cc.size(addtionW,panelH))
    self._addtionPanel:setVisible(true)
	return dataD
end

-- 圣徽精通tip
function GlobalTipView:getDataDForTipType26( data )
	local dataD = {}
	dataD.art = "rune_master_icon" -- icon资源
	dataD.name = "RUNE_TIPS_5"
	dataD.id = 111 -- 不为空就行
	dataD.color = UIUtils.colorTable.ccUIBasePromptColor
	self._des = lang("RUNE_TIPS_6")
	dataD.des = self._des
	-- dump(dataD,"dartaDl...")
	-- 填充addtionPanel内容
	local addtionW = self._addtionPanel:getContentSize().width
	local addtionInitH = self._addtionPanel:getContentSize().height
	local addtion = ccui.Layout:create()
	addtion:setBackGroundColorOpacity(0)
	addtion:setBackGroundColorType(1)
	addtion:setPosition(0,0)
	-- 将需要添加的东西加在addtion上，加完之后设置高度
	local tabConfig = tab.runeCastingMastery
	local isNoAct = data.lv<tabConfig[1].level
	local isMax = data.lv>=tabConfig[table.nums(tabConfig)].level
	local actIndex = isMax and table.nums(tabConfig) or 0
	local nextIndex = 1
	if not isNoAct then
		for i,v in ipairs(tabConfig) do
			if data.lv<v.level then
				actIndex = i-1
				nextIndex = i
				break
			end
		end
	end
	
	local panelH = 0
	
	local nowColor = UIUtils.colorTable.ccUIBaseTitleTextColor
	local nowLevel = ccui.Text:create()--当前等级
	nowLevel:setString(string.format("当前(%s级)", data.lv))
	nowLevel:setFontName(UIUtils.ttfName)
	nowLevel:setFontSize(20)
	nowLevel:setColor(nowColor)
	nowLevel:setAnchorPoint(0, 1)
	addtion:addChild(nowLevel)
	panelH = panelH + nowLevel:getContentSize().height + 5
	local nowAttrNode = {}--当前属性文本
	if isNoAct then
		local noActLab = nowLevel:clone()
		noActLab:setString("未激活")
		addtion:addChild(noActLab)
		panelH = panelH + noActLab:getContentSize().height + 5
		table.insert(nowAttrNode, noActLab)
	else
		for i,v in ipairs(tabConfig[actIndex].castingMastery) do
			local nowAttrLab = nowLevel:clone()
			nowAttrLab:setString(UIUtils:getAttrStrWithAttrName(v[1], v[2]))
			addtion:addChild(nowAttrLab)
			panelH = panelH + nowAttrLab:getContentSize().height + 5
			table.insert(nowAttrNode, nowAttrLab)
		end
	end
	
	local nextLevel = 0
	if isMax then
		nextLevel = tabConfig[table.nums(tabConfig)].level
	else
		for i,v in ipairs(tabConfig) do
			if data.lv<v.level then
				nextLevel = v.level
				break
			end
		end
	end
	
	local nextLevelLab = nowLevel:clone()
	if isMax then
		nextLevelLab:setString(string.format("已达到最高阶级"))
	else
		nextLevelLab:setString(string.format("下一阶 (铸造总%s级可激活)", nextLevel))
	end
	nextLevelLab:setColor(UIUtils.colorTable.ccUIBaseColor5)
	addtion:addChild(nextLevelLab)
	panelH = panelH + nextLevelLab:getContentSize().height+15
	local nextAttrNode = {}
	if not isMax then
		for i,v in ipairs(tabConfig[nextIndex].castingMastery) do
			local nextAttrLab = nowLevel:clone()
			nextAttrLab:setString(UIUtils:getAttrStrWithAttrName(v[1], v[2]))
			addtion:addChild(nextAttrLab)
			panelH = panelH + nextAttrLab:getContentSize().height + 5
			nextAttrLab:setColor(cc.c4b(120, 120, 120, 255))
			table.insert(nextAttrNode, nextAttrLab)
		end
	end
	
    addtion:setContentSize(cc.size(addtionW,panelH))
	
	local posY = panelH
	nowLevel:setPosition(0, posY)
	posY=posY - nowLevel:getContentSize().height - 5
	for i,v in ipairs(nowAttrNode) do
		v:setPositionY(posY)
		posY = posY - v:getContentSize().height
	end
	posY = posY - 15
	nextLevelLab:setPositionY(posY)
	posY = posY - nextLevelLab:getContentSize().height - 5
	for i,v in ipairs(nextAttrNode) do
		v:setPositionY(posY)
		posY = posY - v:getContentSize().height
	end
	
	self._addtionPanel:addChild(addtion)
	self._addtionPanel:setVisible(true)
	self._addtion = addtion
	self._addtionPanel:setContentSize(cc.size(addtionW,panelH))
    self._addtionPanel:setVisible(true)
	return dataD
end

function GlobalTipView:changeStrColor( str,newColor )
	if true then return str end
	str = string.gsub(str,"%b[]",function( catchStr )
		local _,pos1 = string.find(catchStr,"color=")
		if pos1 then
			return string.sub(catchStr,1,pos1) .. "ff9c00" .. string.sub(catchStr,pos1+7,string.len(catchStr))
		else
			return catchStr 
		end
	end) 
	return str
end

-- 强转颜色，去掉描边 by guojun 2016.10.28
function GlobalTipView:forceDefColor( str )
	------
	-- if true then return str end
	--- 匹配模式去描边颜色
	str = string.gsub(str,"%b[]",function( catchStr )
		-- 去描边色
		local pos1,pos2 = string.find(catchStr,"outlinecolor=")
		if pos1 then
			-- catchStr = string.gsub(catchStr,,"outlinecolor=","")
			local str = string.sub(catchStr,pos1,string.len(catchStr))
			local pos3 = string.find(str,",")
			if not pos3 then
				pos3 = string.find(str,"]")
			else
				pos3=pos3+1
			end
			if pos3 then
				str = string.sub(str,pos3,string.len(str))
				catchStr =  string.sub(catchStr,1,pos1-1) .. str --string.sub(catchStr,pos3,string.len(catchStr))
			end
		end
		-- 改颜色 
		catchStr = string.gsub(catchStr,"645252","fae6c8")
		catchStr = string.gsub(catchStr,"c98f55","fae6c8")
		catchStr = string.gsub(catchStr,"00ff00","fae6c8")
		catchStr = string.gsub(catchStr,"fae0bc","fae6c8")
		catchStr = string.gsub(catchStr,"FFFFFF","fae6c8")
		catchStr = string.gsub(catchStr,"3D1F00","fae6c8")
		-- pos1,pos2 = string.find(catchStr,"color=")
		-- if pos1 then
		-- 	local str = string.sub(catchStr,pos1,string.len(catchStr))
		-- 	local pos3 = string.find(str,",")
		-- 	if not pos3 then
		-- 		pos3 = string.find(str,"]")
		-- 	else
		-- 		pos3=pos3+1
		-- 	end
		-- 	if pos3 then
		-- 		str = string.sub(str,pos3,string.len(str))
		-- 		catchStr =  string.sub(catchStr,1,pos1-1) .. "color=fae6c8," .. str --.. string.sub(catchStr,pos3,string.len(catchStr))
		-- 	end
		-- end

		return catchStr
	end)
	return str
end


-- 根据内容多少自适应大小
function GlobalTipView:autoResize(notRePos)
	-- 边缘空白 31 上下间距各7
	---[[测试旋转
	--]]
	local tipBlank = 0 -- 边缘空白
	local tipHeight = 10+tipBlank*2
	if self._currentPanel ~= self._racePanel and self._desPanel:isVisible() then
		tipHeight=tipHeight+self._desPanel:getContentSize().height
	end
	if self._addtion then
		self._desPanel:setPositionY(self._addtionPanel:getContentSize().height+30+tipBlank)
		tipHeight=tipHeight+self._addtionPanel:getContentSize().height+30+tipBlank
		self._addtionPanel:setPositionY(20+tipBlank)
	else
		tipHeight=tipHeight+30
		self._addtionPanel:setVisible(false)
		self._desPanel:setPositionY(25+tipBlank)
	end
	if self._currentPanel == self._desPanel then
		self._desPanel:setOpacity(0)
	else
		self._desPanel:setOpacity(255)--255)
		self._currentPanel:setPositionY(tipHeight-30+tipBlank)
		tipHeight=tipHeight+self._currentPanel:getContentSize().height
	end
	self._bg:setContentSize(cc.size(self._desPanel:getContentSize().width+50,tipHeight))
	self._bgHight = tipHeight
	self._bgWidth = self._bg:getContentSize().width
end

function GlobalTipView:resetViewPos( )
	self._closeBtn:setVisible(false)
	if self.posCenter then 
		self._closeBtn:setPosition(cc.p(self._bgWidth,self._bgHight))
		self._closeBtn:setAnchorPoint(cc.p(1,1))
		-- self._closeBtn:setVisible(true)
		self._closePanel:setPosition(cc.p(self._bgWidth/2,self._bgHight/2))
		self._bg:setPosition(cc.p(MAX_SCREEN_WIDTH/2-self._bgWidth/2,MAX_SCREEN_HEIGHT/2-self._bgHight/2-self._adjustHeight))
		self.posCenter = false
	elseif self.node then
		local node = self.node
		local offsetX = self.node.offsetX or 0
		local pos = node:getParent():convertToWorldSpace(cc.p(node:getPositionX(),node:getPositionY()))
		local nodeW,nodeH = node:getContentSize().width,node:getContentSize().height
		local bgW,bgH = self._bgWidth,self._bgHight
		local winW,winH = MAX_SCREEN_WIDTH,MAX_SCREEN_HEIGHT
		local offsetPos = cc.p(0,0)
		if pos.y+nodeH+bgH < winH -10 then -- 顶部显示
			self._bg:setPosition(cc.clampf(pos.x- bgW/2+nodeW/2+offsetX,0,winW-bgW-5),cc.clampf(pos.y+nodeW/2,0,winH-bgH-5))
		else -- 
			if pos.x-bgW-nodeW/2+offsetX > 0 then -- 
			 	self._bg:setPosition(cc.clampf(pos.x- bgW-nodeW/2+offsetX,0,winW-bgW-5),cc.clampf(pos.y-bgH/2,0,winH-bgH-5))
		 	else
	 			if pos.x+bgW+nodeW/2+offsetX < winW then
				 	self._bg:setPosition(cc.clampf(pos.x+nodeW/2+offsetX,0,winW-bgW-5),cc.clampf(pos.y-bgH/2,0,winH-bgH-5))	--todo	
			 	else 
			 		self._bg:setPosition(cc.p(MAX_SCREEN_WIDTH/2,MAX_SCREEN_HEIGHT/2-nodeW/2))
			 	end 
		 	end 
		end
		self.node.offsetX = 0
		self._closePanel:setPosition(cc.p(winW/2 - self._bg:getPositionX(),winH/2 - self._bg:getPositionY()))
	else
		self._bg:setPosition(cc.p(MAX_SCREEN_WIDTH/2,MAX_SCREEN_HEIGHT/2-nodeW/2))
	end
end

function GlobalTipView.dtor()
	GlobalTipView = nil
	names = nil
	raceMap = nil
	skillEffect = nil
	skillKindOption = nil
	skillTp = nil
	tab = nil
	toolType = nil
end

return GlobalTipView
