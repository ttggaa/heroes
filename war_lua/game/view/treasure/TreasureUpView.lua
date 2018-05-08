--[[
    Filename:    TreasureUpView.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2016-01-27 15:00:36
    Description: File description
--]]
local maxComStage = table.nums(tab.devComTreasure)+1
local maxDisStage = table.nums(tab.devDisTreasure)+1
-- 引用别的文件的 解析
local GlobalTipView = require("game.view.global.GlobalTipView")
local TreasureUpView = class("TreasureUpView",BasePopView)
function TreasureUpView:ctor()
    self.super.ctor(self)

    self._tModel = self._modelMgr:getModel("TreasureModel")

    self._skillTabMap = {
		tab.heroMastery,
		tab.playerSkillEffect,
		tab.skillPassive,
		tab.skillCharacter,
		tab.skillAttackEffect,
	    tab.skill,
	}
end

-- 初始化UI后会调用, 有需要请覆盖
function TreasureUpView:onInit()
	self._disTreasureUp = self:getUI("bg.layer.disTreasureUp")
	self._comTreasureUp = self:getUI("bg.layer.comTreasureUp")
	self._materialNode = self:getUI("bg.layer.materialNode")
	-- self._topStageImg = self:getUI("bg.layer.topStageImg")
	self._topLab = self:getUI("bg.layer.topStageImg.topLab")
	self._topLab:setString("您的宝物已至最高阶")
	self._topLab:setColor(cc.c3b(255, 243, 174))
    self._topLab:enable2Color(1, cc.c4b(240, 165, 40, 255))
    self._topLab:enableOutline(cc.c4b(0, 0, 0, 255), 2)
	self._materialNode:setVisible(false)
	self._materialPanel = self:getUI("bg.layer.materialPanel")
	self._title = self:getUI("bg.layer.headBg.title")
	self._title:setColor(cc.c3b(250, 242, 192))
    self._title:enable2Color(1, cc.c4b(255, 195, 20, 255))
    self._title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._title:setFontName(UIUtils.ttfName)
    self._attPanel = self:getUI("bg.layer.attPanel")
    self._attPanel:setVisible(false)
	self._curTreasureData = {}
	self:registerClickEventByName("bg.layer.closeBtn", function ()
        self:close()
    end)
    self._upBtn = self:getUI("bg.layer.upBtn")
    self:registerClickEventByName("bg.layer.upBtn", function ()
    	if (self._curTreasureData.upType == "com" and self._curTreasureData.stage == maxComStage) or 
    		(self._curTreasureData.upType == "dis" and self._curTreasureData.stage == maxDisStage) then
    		self._viewMgr:showTip("已满阶")
    		return 
    	end
    	if not self._abundent then
    		self._viewMgr:showTip(lang("TIPS_ARTIFACT_01") or "材料不足")
    		return
    	end
    	self:lock(-1)
        if self._curTreasureData.upType == "com" then
	    	local comInfo = self._tModel:getComTreasureById(tostring(self._curTreasureData.id))
			for k,v in pairs(comInfo.treasureDev) do
				if v.s < comInfo.stage+1 then
		    		self._viewMgr:showTip(lang("TIPS_ARTIFACT_02") or "散件宝物等级不足")
		    		self:unlock()
		    		return
				end
			end
			local curTreasureData = clone(self._tModel:getComTreasureById(tostring(self._curTreasureData.id)))
        	self._serverMgr:sendMsg("TreasureServer","promoteComTreasure",{comId = self._curTreasureData.id}, true, {}, function(result)
        		
        		self._curTreasureData.stage = self._curTreasureData.stage+1        		
        		--组合宝物悬浮窗  播放进阶动画放到下一帧
    			ScheduleMgr:nextFrameCall(self, function()
    				audioMgr:playSound("Artifact")
                	self._viewMgr:showDialog("treasure.TreasureUpStageComView",{treasureData = curTreasureData,id = self._curTreasureData.id,stage = self._curTreasureData.stage}, true,false,nil,true)
				
					self:unlock()
					self:close()
                end)
				self:reflashUI(self._curTreasureData)
				
		    end)
        elseif self._curTreasureData.upType == "dis" then
        	-- local comInfo = self._tModel:getComTreasureById(tostring(self._curTreasureData.cid))
        	-- if self._curTreasureData.stage >= comInfo.stage+1 then
        	-- 	self._viewMgr:showTip("组合宝物等级不足")
        	-- 	return 
        	-- end
        	-- if true then return end
        	self._serverMgr:sendMsg("TreasureServer","promoteDisTreasure",{disId = self._curTreasureData.id,comId = self._curTreasureData.cid}, true, {}, function(result)

        		self._curTreasureData.stage = self._curTreasureData.stage+1        			
				--播放进阶动画放到下一帧
    			ScheduleMgr:nextFrameCall(self, function()
    				audioMgr:playSound("Artifact")
                	self._viewMgr:showDialog("treasure.TreasureUpStageSuccessView",{id = self._curTreasureData.id,stage = self._curTreasureData.stage}, true,false,nil,true)
                	self:unlock()
                end)

    			self:reflashUI(self._curTreasureData)
		    end)
    	end
    end)
    self:listenReflash("TreasureModel", self.reflashUI)
    self:listenReflash("ItemModel", self.reflashUI)

end

-- 接收自定义消息
function TreasureUpView:reflashUI(data)
	if data and not data.id then data = nil end
	self._curTreasureData = data or self._curTreasureData
	if not data then data = self._curTreasureData end
	local upType = self._curTreasureData.upType or "dis"
	if upType == "dis" then
		self._title:setString("宝物进阶")
		self._disTreasureUp:setVisible(true)
		self._comTreasureUp:setVisible(false)

		self._curDisData = tab:DisTreasure(data.id)

		local old = self:getUI("bg.layer.disTreasureUp.old")
		old:removeAllChildren()
		local icon = self:createDisTreasureIcon( data.id,data.stage )
		old:addChild(icon,99)

		local new = self:getUI("bg.layer.disTreasureUp.new")
		new:removeAllChildren()
		if data.stage < maxDisStage then
			local newIcon = self:createDisTreasureIcon( data.id,data.stage+1 ,true)
			new:addChild(newIcon,99)
			local materials = {}
			local devDisT = tab:DevDisTreasure(data.stage)
			local material = {"tool",data.id,devDisT.treasureNum}
			table.insert(materials,material)
			-- for i=1,5 do
			material = devDisT["mater" .. self._curDisData.quality]
			table.insert(materials,material)
			-- end
			self:generateMatirals(materials)
		else
			-- self._topStageImg:setVisible(true)
			-- self._upBtn:setVisible(false)
			self._materialPanel:removeAllChildren()
		end


	else
		self._curComData = tab:ComTreasure(data.id)

		self._title:setString("组合进阶")
		self._disTreasureUp:setVisible(false)
		self._comTreasureUp:setVisible(true)

		self:createComTreasureIcon(data.id,data.stage)

		if data.stage < maxComStage then
			-- local afterAtts = self:createComTreasureIcon(data.id,data.stage+1,true)
			-- after:addChild(afterAtts)
			local devComT = tab:DevComTreasure(data.stage)
			local materials = devComT["special" .. self._curComData.quality]
			
			self:generateMatirals(materials)
		else
			-- self._topStageImg:setVisible(true)
			-- self._upBtn:setVisible(false)
			self._materialPanel:removeAllChildren()
		end
	end
	local canUp = true
	if (self._curTreasureData.upType == "com" and self._curTreasureData.stage == maxComStage) or 
		(self._curTreasureData.upType == "dis" and self._curTreasureData.stage == maxDisStage) then
		canUp = false
	end
	if not self._abundent then
		canUp = false
	end
    if self._curTreasureData.upType == "com" then
    	local comInfo = self._tModel:getComTreasureById(tostring(self._curTreasureData.id))
		for k,v in pairs(comInfo.treasureDev) do
			if v.s < comInfo.stage+1 then
				canUp = false
			end
		end
	end
	self._upBtn:removeAllChildren()
	if canUp then
		local mc1 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
	    mc1:setName("anim")
	    -- mc1:setScale(1.3,1.3)
		mc1:setPosition(70, 30)
	    self._upBtn:addChild(mc1, 1)
	end
	UIUtils:setGray(self._upBtn,not canUp)
end

-- 生成散件属性列
function TreasureUpView:createDisTreasureIcon( id,stage,up )
	local icon = IconUtils:createItemIconById({itemId = id,eventStyle = 0})
	self:generateAtts(id,stage,icon,0,0,maxDisStage)
	
	local iconName = ccui.Text:create()
	iconName:setAnchorPoint(cc.p(0.5,0.5))
	iconName:setFontSize(24)
	iconName:setFontName(UIUtils.ttfName)
	iconName:setPosition(cc.p(icon:getContentSize().width/2,-25))
	icon:addChild(iconName,99)

	iconName:setString(lang(tab:DisTreasure(id).name) .. "+" .. stage)
	iconName:setColor(UIUtils.colorTable["ccColorQuality".. (tab:DisTreasure(id).quality or 2)])
	iconName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

	return icon
end


function TreasureUpView:createComTreasureIcon( id,stage,up )
	local treasureNode = self._comTreasureUp:getChildByFullName("treasureNode")
	treasureNode:removeAllChildren()
	local icon = ccui.ImageView:create()--IconUtils:createTreasureIcon({id = self._curComData.id})
	icon:loadTexture(IconUtils.iconPath .. self._curComData.art ..".png", 1)

	local iconScale = 140/icon:getContentSize().width
	icon:setScale(iconScale)
	icon:setPosition(cc.p(50,50))
	treasureNode:addChild(icon)

	local mc = mcMgr:createViewMC("jinjiewupinguang_comtreasurebg", true, false,nil,RGBA8888)
    mc:setName("anim")
    mc:setPosition(50, 50)
	treasureNode:addChild(mc,-1)
	
	
	self:generateAtts(id,stage,treasureNode,40,-20,maxComStage)
	local x,y = 0,0
	local offsetx,offsety = -40,30
	local lineHeight = 20
	local height,width = -5,10
	x = width+offsetx

	local comName = ccui.Text:create()
	comName:setFontName(UIUtils.ttfName)
	comName:setFontSize(22)
	comName:setAnchorPoint(cc.p(0.5,0.5))
	comName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	comName:setString(lang(self._curComData.name) .. " +" .. stage)
	comName:setColor(UIUtils.colorTable["ccColorQuality" .. (self._curComData.quality or 2)])
	comName:setPosition(cc.p(50,-treasureNode:getContentSize().height/2+25))
	treasureNode:addChild(comName)
	

	local skillId = self._curComData.addattr[1][2]
	local skillD = {}
	for k,v in pairs(self._skillTabMap) do
		if v[skillId] and (v[skillId].art or v[skillId].icon) then
			skillD = clone(v[skillId])
			break
		end
	end

	local left = self._comTreasureUp:getChildByFullName("left")
	local right = self._comTreasureUp:getChildByFullName("right")

	local lLevel = left:getChildByFullName("level")
	local lName = left:getChildByFullName("name")
	lLevel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	lName:setColor(UIUtils.colorTable["ccColorQuality" .. (self._curComData.quality or 2)])
	lName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	lName:setString(lang(skillD.name))
	lLevel:setString("Lv." .. stage)
	local rLevel = right:getChildByFullName("level")
	local rName = right:getChildByFullName("name")
	rName:setColor(UIUtils.colorTable["ccColorQuality" .. (self._curComData.quality or 2)])
	rName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	rLevel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	rLevel:setColor(cc.c3b(0, 255, 30))
	rName:setString(lang(skillD.name))
	if stage < maxComStage then
		rLevel:setString("Lv." .. stage+1)
	else
		rLevel:setString("Lv.MAX")
	end

	-- 技能icon..
	local bgNode = ccui.Widget:create()
	bgNode:setContentSize(cc.size(80,80))
	bgNode:setAnchorPoint(cc.p(0,0))
	bgNode:setPosition(cc.p(5,-5))
	local fu = cc.FileUtils:getInstance()
	local skillIcon = ccui.ImageView:create()
	local sfc = cc.SpriteFrameCache:getInstance()
	local art = skillD.art or skillD.icon
	if sfc:getSpriteFrameByName(art ..".jpg") then
		skillIcon:loadTexture("" .. art ..".jpg", 1)
	else
		skillIcon:loadTexture("" .. art ..".png", 1) 
	end
	skillIcon:ignoreContentAdaptWithSize(false)
	skillIcon:setContentSize(cc.size(78,78))
	skillIcon:setAnchorPoint(cc.p(0,0))
	skillIcon:setPosition(cc.p(0,0))
	bgNode:addChild(skillIcon)
	local frame = ccui.ImageView:create()
	frame:loadTexture("skillBg_treasure.png",1) 
	frame:setContentSize(cc.size(106,106))
	frame:ignoreContentAdaptWithSize(false)
	frame:setPosition(cc.p(-14,-13))

	frame:setAnchorPoint(cc.p(0,0))
	bgNode:addChild(frame,1)

	local iconBg = ccui.ImageView:create()
	iconBg:loadTexture("globalImageUI4_heroBg2.png",1) 
	iconBg:setContentSize(cc.size(80,80))
	iconBg:ignoreContentAdaptWithSize(false)
	iconBg:setPosition(cc.p(-5,-5))
	iconBg:setScale(84/iconBg:getContentSize().width)
	iconBg:setAnchorPoint(cc.p(0,0))
	bgNode:addChild(iconBg,-1)
	bgNode:setScale(0.8)

	left:addChild(bgNode)

	local skillDes 
	local desBg = self._comTreasureUp:getChildByFullName("desBg")
	local tipDataD = GlobalTipView["getDataDForTipType2"](GlobalTipView,
		{tipType = 2, node = desBg, id = skillD.id,skillType = self._curComData.addattr[1][1],skillLevel = math.min(stage+1,maxComStage)})
	skillDes = GlobalTipView._des
	skillDes = string.gsub(skillDes,"fontsize=16","fontsize=20,outlinecolor=3c1e0a00")
	skillDes = string.gsub(skillDes,"fontsize=17","fontsize=20,outlinecolor=3c1e0a00")
	skillDes = string.gsub(skillDes,"fontsize=18","fontsize=20,outlinecolor=3c1e0a00")
	skillDes = string.gsub(skillDes,"fontsize=24","fontsize=20,outlinecolor=3c1e0a00")
	skillDes = string.gsub(skillDes,"color=3d1f00","color=fae0bc")
	local rtx = RichTextFactory:create("[color = fae0bc,outlinecolor=3c1e0a00,outlinesize=2]".. skillDes .."[-]",620,40)
    rtx:formatText()
    rtx:setVerticalSpace(7)
    rtx:setName("rtx")
    rtx:setPosition(cc.p(desBg:getContentSize().width/2,23))
    desBg:addChild(rtx,99)
    UIUtils:alignRichText(rtx)

	GlobalTipView._des = nil

	-- if up then
	-- 	iconName:setString(lang(tab:DisTreasure(id).name) .. " +1")
	-- 	iconName:setColor(cc.c4b(255, 209, 38, 255))
	-- 	iconName:enableOutline(cc.c4b(54,0,4,255),1.5)
	-- else
	-- 	iconName:setString(lang(tab:DisTreasure(id).name))
	-- 	iconName:setColor(cc.c4b(255, 255, 255, 255))
	-- 	iconName:enableOutline(cc.c4b(0,0,4,255),1.5)
	-- end


	return icon
end

function TreasureUpView:generateMatirals( data )
	self._materialPanel:removeAllChildren()
	self._abundent = true
	local num = table.nums(data)
	local itemSize = 200
	local x,y = 0,0
	local offsetx,offsety = 10,25
	-- -itemSize*num*0.5+20+self._materialPanel:getContentSize().width/2
	for i,material in ipairs(data) do
		local item = self._materialNode:clone()
		item:setVisible(true)
		local itemId = material[2]
		local _,hadNum = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
		local needNum = item:getChildByFullName("needNum")
		local name = item:getChildByFullName("name")
		name:setString(lang(tab:Tool(itemId).name))
		name:setColor(UIUtils.colorTable["ccUIBaseColor".. (tab:Tool(itemId).color or 2)])
		name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
		local icon
		if hadNum < self._tModel:getCurrentNum(material[2],material[3]) then
			needNum:setColor(UIUtils.colorTable["ccUIBaseColor6"])
			needNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
			self._abundent = false			
			local itemRedFlag = self._modelMgr:getModel("ItemModel"):approatchIsOpen(itemId)
			local suo = itemRedFlag and 2 or nil
			icon = IconUtils:createItemIconById({itemId = itemId,eventStyle = 3,suo=suo,clickCallback = function( )
				DialogUtils.showItemApproach(itemId)
			end})
		else
			icon = IconUtils:createItemIconById({itemId = itemId})
			needNum:setColor(UIUtils.colorTable["ccUIBaseColor9"])
			needNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
		end
		icon:setScale(80/icon:getContentSize().width)
		item:addChild(icon)
		local toolD = tab:Tool(itemId)
		local color = 1
		if toolD then
			color = toolD.color or 1
		end
		needNum:setString(ItemUtils.formatItemCount(hadNum or 0) .. "/" .. self._tModel:getCurrentNum(material[2],material[3]))
		x = itemSize*(i-1)
		item:setPosition(cc.p(x+offsetx,y+offsety))
		self._materialPanel:addChild(item)
	end
end

function TreasureUpView:generateAtts( id,stage,node,offsetx,offsety,stageMax )
	local preAtts = self._tModel:getTreasureAtts(id,stage)
	local afterAtts = self._tModel:getTreasureAtts(id,stage+1)
	local panelW, panelH = self._attPanel:getContentSize().width,self._attPanel:getContentSize().height+5
	self._panelH = panelH
	local x,y = node:getContentSize().width+2+ panelW/2,node:getContentSize().height/2+panelH*((#preAtts-1)/2)
	local offsetx,offsety = offsetx or 0,offsety or 0
	local idx = 1
	self._panels = {}
	for k,v in pairs(preAtts) do
		local attPanel = self._attPanel:clone()
		attPanel:setAnchorPoint(cc.p(0.5,0.5))
		attPanel:setVisible(true)
		if idx%2 == 1 then
			attPanel:setOpacity(0)
		end
		attPanel:setPosition(cc.p(x+offsetx,y+offsety-(idx-1)*panelH))
		node:addChild(attPanel,99)
		table.insert(self._panels,attPanel)

		local attLeft = attPanel:getChildByFullName("attLeft")
		attLeft:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
		local attRight = attPanel:getChildByFullName("attRight")
		attRight:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
		local att2 = attPanel:getChildByFullName("att2")
		att2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

		local name = lang("ARTIFACTDES_PRO_" .. v.attId)
		if not name then 
			name = lang("ATTR_" .. v.attId)
		end
		if name then
			name = string.gsub(name,"　","")
			name = string.gsub(name," ","")
		end
		local tail = ""
		if tonumber(v.attId) == 2 or tonumber(v.attId) == 5 or tonumber(v.attId) == 131 then
			tail = "%"
		end
		attLeft:setString(name .. " +" .. v.attNum .. tail)
		if stage < stageMax then
			att2:setString(" +" .. afterAtts[k]["attNum"] .. tail)
			attRight:setString(name)
		else
			attRight:setString("已满阶")
			att2:setString("")
			att2:setColor(cc.c3b(255, 255, 255))
		end
		att2:setPositionX(attRight:getPositionX()+attRight:getContentSize().width)
		idx = idx+1
	end
end

return TreasureUpView