--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-09-08 17:31:26
--
local HeroSpellBookView = class("HeroSpellBookView",BasePopView)
function HeroSpellBookView:ctor(param)
    self.super.ctor(self)
    self._heroData = param and param.heroData
    self._callback = param and param.callback
    self._idx = param and param.tabIdx or 1
    self._spModel = self._modelMgr:getModel("SpellBooksModel")
    dump(self._heroData.slot,"slotInfo......")
    self._spellFilterMap = {}
    local spells = self._heroData.spell 
    for k,v in pairs(spells) do
    	self._spellFilterMap[v] = true
    end
end

function HeroSpellBookView:getAsyncRes( )
	return 
	{
		{"asset/ui/spellBook.plist", "asset/ui/spellBook.png"},
		{"asset/ui/skillCard.plist", "asset/ui/skillCard.png"},
		{"asset/ui/spellBook1.plist", "asset/ui/spellBook1.png"},
		{"asset/ui/treasureSkill.plist", "asset/ui/treasureSkill.png"},
	}
end

-- 初始化UI后会调用, 有需要请覆盖
function HeroSpellBookView:onInit()
	-- local sfc = cc.SpriteFrameCache:getInstance()
	-- -- 手动管理图集
	--    local tc = cc.Director:getInstance():getTextureCache() 
	--    if not tc:getTextureForKey("spellBook_itemFrame.png") then
	--        sfc:addSpriteFrames("asset/ui/spellBook1.plist", "asset/ui/spellBook1.png")
	--    end
	-- if not tc:getTextureForKey("skillBg_s_treasureSkill.png") then
	--        sfc:addSpriteFrames("asset/ui/treasureSkill.plist", "asset/ui/treasureSkill.png")
	--    end
    self._closeBtn = self:getUI("bg.layer.closeBtn")
	self:registerClickEvent(self._closeBtn,function() 
		if self._callback then
			self._callback()
		end
		self.dontRemoveRes = true
		self:close()
		UIUtils:reloadLuaFile("spellbook.HeroSpellBookView")
	end)
	self._panels = {}
	self._panels["tab_equip"] = self:getUI("bg.layer.markPanel")
	self._panels["tab_mark"] = self:getUI("bg.layer.slotPanel") 
	self._panels["tab_equip"]:setVisible(self._idx == 1)
	self._panels["tab_mark"]:setVisible(self._idx ~= 1)
	-- 增加点击动画
    UIUtils:setTabChangeAnimEnable(self:getUI("bg.layer.tab_equip"),-35,handler(self, self.tabButtonClick))
    UIUtils:setTabChangeAnimEnable(self:getUI("bg.layer.tab_mark"),-35,handler(self, self.tabButtonClick))
    self._tabEventTarget = {}
    table.insert(self._tabEventTarget, self:getUI("bg.layer.tab_equip"))
    table.insert(self._tabEventTarget, self:getUI("bg.layer.tab_mark"))
    self._animBtns = self._tabEventTarget
    
    self._title = self:getUI("bg.layer.headBg.title")
    UIUtils:setTitleFormat(self._title,1)
    self._title:setString(self._idx == 1 and "法术刻印" or "法术打孔")

    self._mCostLab = self:getUI("bg.layer.markPanel.costLab")
    self._mCostLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._mCostImg = self:getUI("bg.layer.markPanel.costImg")
    self._markSlot = self:getUI("bg.layer.markPanel.slot")

    self._sCostLab = self:getUI("bg.layer.slotPanel.costLab")
    -- self._sCostLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._sCostImg = self:getUI("bg.layer.slotPanel.costImg")
    self._slotBtn = self:getUI("bg.layer.slotPanel.slotBtn")
    self._perfectImg = self:getUI("bg.layer.slotPanel.perfectImg")
    self._slotsBtn = self:getUI("bg.layer.slotPanel.slotsBtn")
    -- self._slotsBtn:setTitleText("万能\n碎片")
    -- self._slotsBtn:setTitleFontSize(16)
    
    self._okBtn = self:getUI("bg.layer.slotPanel.okBtn")
	self:registerClickEvent(self._okBtn,function() 
		self:sendSaveMsg()
	end)
	self._cancelBtn = self:getUI("bg.layer.slotPanel.cancelBtn")
	self:registerClickEvent(self._cancelBtn,function() 
        self:showSaveBtn(false)
        self:reflashUI()
	end)
	self:showSaveBtn(false)
	
	self:detectTabOpen()
    self:tabButtonClick(self._tabEventTarget[self._idx],true)

    self:registerClickEventByName("bg.layer.markPanel.listPanel.clickDes",function() 
    	self._viewMgr:showView("skillCard.SkillCardTakeView")
    end)
    -- 刻印展示相关
    self._typeDes = self:getUI("bg.layer.markPanel.typeDes")
    self._desBg = self:getUI("bg.layer.markPanel.desBg")
    self._sDesBg = self:getUI("bg.layer.slotPanel.desBg")
    self._noneDesS = self:getUI("bg.layer.markPanel.noneDes.des")
    self._noneDesS:getVirtualRenderer():setMaxLineWidth(290)
    self._markBtn = self:getUI("bg.layer.markPanel.markBtn")
    self:registerClickEvent(self._markBtn,function() 
    	-- self._serverMgr:sendMsg("HeroServer","refreshHeroSlot",{heroId = self._heroData.id}, true, {}, function(result, success)
	    -- end)
		if self._markBtn._noSlotDes then
			self._viewMgr:showTip(self._markBtn._noSlotDes)
			return 
		end
		local isMarkAbundence,cost = self:isMarkAbundence()
    	if self._markBtn._status == "toMark" then
	    	local sid = self._markSid 
	    	if not sid then 
	    		self._viewMgr:showTip("没有可刻印法术书")
	    		return
	    	end
	    	self._markBtn:setEnabled(false)
		    self._serverMgr:sendMsg("HeroServer","equipSpellBook",{heroId = self._heroData.id,sid = sid}, true, {}, function(result, success)
		    	local heroData = result.d and result.d.heros
	            if self._heroData then
	                self._modelMgr:getModel("HeroModel"):mergeHeroData(self._heroData, heroData[tostring(self._heroData.id)] or {})
	                local addScore = self._heroData.slot and self._heroData.slot.score or 0
	                if addScore > 0 then
						TeamUtils:setFightAnim(self:getUI("bg.layer"),{x=250,y=480,oldFight = 0,newFight=addScore,})
					end
	            end
	            if self._markMc then
					self._markMc:gotoAndPlay(0)
					self._markMc:setVisible(true)
					self._markMc:addCallbackAtFrame(20,function( )
						self._markMc:stop()
						self._markMc:setVisible(false)
						self._markBtn:setEnabled(true)
			            self:reflashUI()
					end)
				end
		    end)
		elseif self._markBtn._status == "unload" then
			if not isMarkAbundence then
				DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"), callback1=function( )
				    local viewMgr = ViewManager:getInstance()
				    viewMgr:showView("vip.VipView", {viewType = 0})
				end})
				return 
			end
			self._markBtn:setEnabled(false)
			self._serverMgr:sendMsg("HeroServer","takeSpellBook",{heroId = self._heroData.id}, true, {}, function(result, success)
				self._preSelId = nil
				self._markSid = nil
				if self._unloadMc then
					self._unloadMc:gotoAndPlay(0)
					self._unloadMc:setVisible(true)
					self._unloadMc:addCallbackAtFrame(20,function( )
						self._unloadMc:stop()
						self._unloadMc:setVisible(false)
			    		self:reflashUI()
			    		self._markBtn:setEnabled(true)
					end)
				end
	    		local heroData = result.d and result.d.heros
	            if self._heroData and heroData then
                    self._modelMgr:getModel("HeroModel"):mergeHeroData(self._heroData, heroData[tostring(self._heroData.id)] or {})
                    self._modelMgr:getModel("HeroModel"):reflashAllSlotSkillex()
                end
		    end)
		end

		-- self._serverMgr:sendMsg("HeroServer","resolveSpellBookPiece",{sid = 500303,num = 1}, true, {}, function(result, success)
		-- end)
    end)

    self:registerClickEventByName("bg.layer.slotPanel.slotBtn",function() 
    	self:sendRefreshMsg(1)
    end)

    self:registerClickEvent(self._slotsBtn,function() 
    	dump(self._heroData)
    	UIUtils:reloadLuaFile("hero.HeroFragUseView")
    	local cost = tab.setting["SKILLBOOK_FIRST_COST"] and tab.setting["SKILLBOOK_FIRST_COST"].value or 1
    	self._viewMgr:showDialog("hero.HeroFragUseView", { heroData = self._heroData, container = self ,needNum = cost,needStr = "打孔还需要:" }, true)
    end)


	-- tip
	local desTip = self:getUI("touchLayer.desTip")
	local tipDes =  self:getUI("touchLayer.desTip.tipDes")
	tipDes:setString(lang("SKILLBOOK_TIPS5"))
	desTip:setVisible(false)
	local touchLayer = self:getUI("touchLayer")
	self:registerClickEventByName("touchLayer",function() 
    	if desTip:isVisible() then
    		desTip:setVisible(false)
    	end
    end)
	touchLayer:setSwallowTouches(false)

	self:registerClickEventByName("bg.layer.markPanel.ruleBtn",function() 
    	if not desTip:isVisible() then
    		desTip:setVisible(true)
    	end
    end)
		
	self:registerClickEventByName("bg.layer.slotPanel.ruleBtn",function() 
    	self._viewMgr:showDialog("spellbook.SpellBookRuleView",{title = "打孔规则",des = lang("SHOPSKILLBOOK_RULE1")})
    end)

    self:listenReflash("SpellBooksModel", function( )
    	self:reflashUI()
    end)
    self:listenReflash("HeroModel", function( )
    	self:reflashUI(true)
    end)
    self:resetMarkSlot()
    -- 列表
    self._noneDes = self:getUI("bg.layer.markPanel.noneDes")
    self._listPanel = self:getUI("bg.layer.markPanel.listPanel")
    self._skillCell = self:getUI("bg.layer.skillCell")
    self._tableData = {}
    self:addTableView()

    self:initSlotPanel()
    self:resetDigSlot()

    local mcSpeed = 3
    local mc = mcMgr:createViewMC("baowufenjie_treasureui",true,false)
	mc:setPosition(54,54)
	mc:setScale(0.8)
	mc:setPlaySpeed(mcSpeed)
	self._markSlot:addChild(mc,99)
	self._markMc = mc
	self._markMc:setVisible(false)
	self._markMc:stop()

	local mc = mcMgr:createViewMC("xiaoshi_selectedmissanim",true,false)
	mc:setPosition(54,54)
	mc:setScale(-1,1)
	mc:setPlaySpeed(mcSpeed)
	self._markSlot:addChild(mc,99)
	self._unloadMc = mc
	self._unloadMc:setVisible(false)
	self._unloadMc:stop()
	
	local mc = mcMgr:createViewMC("baowufenjie_treasureui",true,false)
	mc:setPosition(54,54)
	mc:setScale(0.8)
	mc:setPlaySpeed(mcSpeed)
	self._curSlot:addChild(mc,99)
	self._slotMc = mc
	self._slotMc:setVisible(false)
	self._slotMc:stop()

	mcSpeed = 1
	local mc = mcMgr:createViewMC("shuaxin1_skillbookfashukeyin",true,false)
	mc:setPosition(54,54)
	mc:setScale(0.8)
	mc:setPlaySpeed(mcSpeed)
	self._curSlot:addChild(mc,99)
	self._digMc = mc
	self._digMc:setVisible(false)
	self._digMc:stop()

	local mc = mcMgr:createViewMC("shuaxin2_skillbookfashukeyin",true,false)
	mc:setPosition(0,53)
	mc:setScale(0.8)
	mc:setPlaySpeed(mcSpeed)
	local mcLayer1 = ccui.Layout:create()
	mcLayer1:setContentSize({width=105,height=105})
	--    mcLayer1:setBackGroundColorOpacity(100)
	--    mcLayer1:setBackGroundColorType(1)
	--    mcLayer1:setBackGroundColor(cc.c3b(0, 0, 0))
    mcLayer1:setAnchorPoint(0.5,0.5)
    mcLayer1:setPosition(315+53,225+53)
	self:getUI("bg.layer.slotPanel"):addChild(mcLayer1)
	self._rotaLy = mcLayer1
	self._rotaLy:addChild(mc,99)
	self._rotaMc = mc
	self._rotaMc:setVisible(false)
	self._rotaMc:stop()

	-- 结果tip
	self._resultTip = self:getUI("touchLayer.resultTip")
	self._resultTip:setVisible(false)
	self._resultDes = self:getUI("touchLayer.resultTip.des")
	self._resultDes:setColor(cc.c3b(255, 252, 226))
	self._resultDes:setZOrder(8)
	self._resultTip:setCascadeOpacityEnabled(true,true)
end


function HeroSpellBookView:onFragViewClose()
	self:reflashUI()
end

function HeroSpellBookView:detectTabOpen( )
	local na = self._heroData.slot and self._heroData.slot.na or 0
	-- 未初始化孔时置灰
	local tabBtn = self._tabEventTarget[1]
	if tabBtn._notOpen == true and na ~= 0 then
		self._rotaLy:runAction(cc.Sequence:create(
			cc.DelayTime:create(0.5),
			cc.CallFunc:create(function( )
				local mc = mcMgr:createViewMC("jiesuokeyin_skillbookjiesuokeyin",false,true)
				mc:setPosition(65,30)
				tabBtn:addChild(mc,99)
				UIUtils:setGray(tabBtn,na == 0)
			end)
		))
	else
		UIUtils:setGray(tabBtn,na == 0)
	end
	tabBtn._notOpen = na == 0
	tabBtn._notOpenDes = lang("TIP_SkillBook3") -- "请先打孔"
   	
end

function HeroSpellBookView:tabButtonClick(sender,noAudio)
    if sender == nil then 
        return 
    end
    -- self:showSaveBtn(false)
    print("sender:getName()",sender:getName())
    local name = sender:getName()
    if not noAudio then 
        audioMgr:playSound("Tab")
    end
    if sender._notOpen then
    	self._viewMgr:showTip(sender._notOpenDes or "未开启")
    	UIUtils:tabTouchAnimOut(sender)
	    return
	end
    for k,v in pairs(self._tabEventTarget) do
        if v ~= sender then 
            local text = v:getTitleRenderer()
            v:setTitleColor(UIUtils.colorTable.ccUITabColor1)
            text:disableEffect()
            -- text:setPositionX(85)
            v:setScaleAnim(false)
            v:stopAllActions()
            v:setScale(1)
            if v:getChildByName("changeBtnStatusAnim") then 
                v:getChildByName("changeBtnStatusAnim"):removeFromParent()
            end
            v:setZOrder(-10)
            self:setTabStatus(v, false)
        end
    end
    if self._preBtn then
        UIUtils:tabChangeAnim(self._preBtn,nil,true)
    end
    
    -- text:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    -- 按钮动画
    self._preBtn = sender
    sender:stopAllActions()
    sender:setZOrder(99)
    UIUtils:tabChangeAnim(sender,function( )
        local text = sender:getTitleRenderer()
        text:disableEffect()
        -- text:setPositionX(85)
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor2)
        self:setTabStatus(sender, true)
        self._panels["tab_equip"]:setVisible(name == "tab_equip")
		self._panels["tab_mark"]:setVisible(name == "tab_mark")
		self._title:setString(name == "tab_equip" and "法术刻印" or "法术打孔")
    end)
end

function HeroSpellBookView:setTabStatus( tabBtn,isSelect )
    if isSelect then
        tabBtn:loadTextureNormal("globalBtnUI4_page1_p.png",1)
        local text = tabBtn:getTitleRenderer()
        tabBtn:setTitleColor(UIUtils.colorTable.ccUITabColor1)
        text:disableEffect()
    else
        tabBtn:loadTextureNormal("globalBtnUI4_page1_n.png",1)
        local text = tabBtn:getTitleRenderer()
        tabBtn:setTitleColor(UIUtils.colorTable.ccUITabColor2)
        text:disableEffect()
    end
    tabBtn:setEnabled(not isSelect)
end

-- 显示选择的slot
function HeroSpellBookView:resetMarkSlot()
	if not self._heroData.slot then return end
	local tp = self._heroData.slot.tp or 1
	local na = self._heroData.slot.na or 1
	local textureUp = self:getUI("bg.layer.markPanel.leftInfo.textureUp")
	local textureDown = self:getUI("bg.layer.markPanel.leftInfo.textureUp.textureDown")
	textureUp:loadTexture("spellBook_markTag" .. na .. ".png",1)
	textureDown:loadTexture("spellBook_markTag" .. na .. ".png",1)
	local typeDes = self:getUI("bg.layer.markPanel.typeDes")
	local tpDesMap = {"神剑","中级","大招","被动","万能"}
	local naDesMap = {"火系","水系","气系","土系","彩虹"}
	typeDes:setString(naDesMap[na] .. lang("SKILLBOOK_TIPS109"))

	-- 更新刻印信息
	local sid = self._heroData.slot.sid
	local skillIcon = self._markSlot:getChildByFullName("skillIcon")
	if sid and sid ~= 0 then
		if not skillIcon then
			skillIcon = ccui.ImageView:create()
            skillIcon:setName("skillIcon")
			-- skillIcon:setScale(62/skillIcon:getContentSize().height)
			self._markSlot:addChild(skillIcon)

			-- 
			local frame = ccui.ImageView:create()
            frame:setName("frame")
            frame:loadTexture("hero_skill_bg2_forma.png",1)
            frame:setPosition(41,41)
            frame:setScale(1.01)
			-- skillIcon:setScale(62/skillIcon:getContentSize().height)
			skillIcon:addChild(frame)
		end
		local skillData = tab.skillBookBase[tonumber(sid)]
		local art = skillData.art 
		local sfc = cc.SpriteFrameCache:getInstance()
		if sfc:getSpriteFrameByName(art ..".jpg") then
			skillIcon:loadTexture("" .. art ..".jpg", 1)
		else
			skillIcon:loadTexture("" .. art ..".png", 1) 
		end
		skillIcon:setPosition(self._markSlot:getContentSize().width/2,self._markSlot:getContentSize().height/2)
		skillIcon:setVisible(true)

	else
		if skillIcon then
			skillIcon:setVisible(false)
		end
 	end 

 	-- 
 	local sid = self._heroData.slot.sid 
 	if sid and sid ~= 0 then 
 		self._markBtn:setTitleText("卸下")
 		self._markBtn._status = "unload"
 		self._mCostLab:setVisible(true)
 		self._mCostImg:setVisible(true)
 	else
 		self._markBtn:setTitleText("刻印")
 		self._markBtn._status = "toMark"
 		self._mCostLab:setVisible(false)
 		self._mCostImg:setVisible(false)
 	end
end

-- 显示选择的slot
function HeroSpellBookView:resetDigSlot(doAnim)
	local slot = self._heroData.slot or {na=0,tp=0}
	
	local isTemp = self._inDigging
	local temp = ""
	if isTemp and slot.tmp then
		temp = json.decode(self._heroData.slot.tmp or "1:1")
	end
	local curTp = slot.tp 
	local curNa = slot.na
	if curNa == 5 then
		self._slotBtn:setVisible(false)
		self._perfectImg:setVisible(true)
		-- self._sCostLab:setVisible(false)
		-- self._sCostImg:setVisible(false)
	else
		self._perfectImg:setVisible(false)
		-- self._sCostLab:setVisible(true)
		-- self._sCostImg:setVisible(true)
	end
	local tp = isTemp and temp["1"]["1"] or slot.tp 
	local na = isTemp and temp["1"]["2"] or slot.na 
	if not tp or not na then
		dump(slot,"slot--------")
	end
	tp = tp or 0
	na = na or 0
	if curNa == 0 then
		curNa = 5
	end
	if not doAnim then
		local textureUp = self:getUI("bg.layer.slotPanel.equipBg.textureUp")
		local textureDown = self:getUI("bg.layer.slotPanel.equipBg.textureUp.textureDown")
		textureUp:loadTexture("spellBook_markTag" .. (curNa or 1) .. ".png",1)
		textureDown:loadTexture("spellBook_markTag" .. (curNa or 1) .. ".png",1)
	end
	
	-- for k,v in pairs(self._allSlots) do
	-- 	v:setBrightness(0)
	-- end
	local selMap = {1,2,4,5,3}
	local selTp = selMap[tp] 
	local selNa = selMap[na]
	print(tp,"tp--na",na,"FFFFFFFFFFFFFFselTp",selTp,"selNa",selNa)
	-- local lSelSlot = self._rightSlots[selTp]
	-- lSelSlot:setBrightness(50)

	for k,v in pairs(self._leftSlots) do
		v._mc:setVisible(false)
		if v._bMc then v._bMc:setVisible(false) end
	end
	local curSlotDes = self:getUI("bg.layer.slotPanel.curSlotDes")
	if selNa then
		local rSelSlot = self._leftSlots[selNa]
		rSelSlot._mc:setVisible(true)
		if rSelSlot._bMc then rSelSlot._bMc:setVisible(true) end
		-- local tpDesMap = {"神剑","中级","大招","被动","万能"}
		local naDesMap = {"火系","水系","气系","土系","彩虹"}
		curSlotDes:setString("当前开孔：" .. naDesMap[na] .. lang("SKILLBOOK_TIPS109"))
	else
		curSlotDes:setString("")
	end
	-- rSelSlot:setBrightness(50)

end

function HeroSpellBookView:showSaveBtn( isShow )
	self._okBtn:setVisible(isShow)
	self._cancelBtn:setVisible(isShow)
	-- self._slotsBtn:setVisible(not isShow)
	self._slotBtn:setVisible(not isShow)
	self._inDigging = isShow
	self._sCostImg:setVisible(not isShow)
	self._sCostLab:setVisible(not isShow)
	local curNa = self._heroData.slot and self._heroData.slot.na
	if curNa == 5 then
		self._sCostLab:setVisible(false)
		self._sCostImg:setVisible(false)
	end
end

function HeroSpellBookView:isMatch( sid )
	-- if true then return true end
	local skillData = tab.skillBookBase[tonumber(sid)]
	if not self._heroData.slot or not skillData then return false end
	local tp = self._heroData.slot.tp 
	local na = self._heroData.slot.na
	local isEquiped = false
	if (tp == 5 or tp == skillData.type) and  
	   (na == 5 or na == skillData.nature)
	   and not self._spellFilterMap[tonumber(sid)]
	then
		return true
	end
	return false
end

function HeroSpellBookView:isMarkAbundence( )
	local cost = tab.setting["SKILLBOOK_UNSN_COST"].value and tab.setting["SKILLBOOK_UNSN_COST"].value[1]
	local costType = "gem"
	local costId = nil
	if type(cost) == "table" then
		costType = cost[1] or cost["type"]
		costId = cost[2] or cost["typeId"]
		cost = cost[3] or cost["num"]
	end
	local haveNum = 0
	if costType == "tool" and costId ~= 0 then
		_,haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(costId or 0)
	else
		haveNum = self._modelMgr:getModel("UserModel"):getData()[costType] or 0
	end
	haveNum  = haveNum or 0	
	print(haveNum,"have---cost",cost)
	local isMarkAbundence = haveNum >= cost

	return isMarkAbundence,cost
end

function HeroSpellBookView:detectCanMark( sid )
	local isMatch = self:isMatch(sid)
	local isMarkAbundence = self:isMarkAbundence()
	return isMarkAbundence and isMatch
end

function HeroSpellBookView:isSlotAbundence( )
	local slot = self._heroData.slot
	local haveNum = 0
	local cost = 0
	if slot then
		cost = tab.setting["SKILLBOOK_COST"].value and tab.setting["SKILLBOOK_COST"].value[1]
		local costType = "gem"
		local costId = nil
		if type(cost) == "table" then
			costType = cost[1] or cost["type"]
			costId = cost[2] or cost["typeId"]
			cost = cost[3] or cost["num"]
		end
		if costType == "tool" and costId ~= 0 then
			_,haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(costId or 0)
		else
			haveNum = self._modelMgr:getModel("UserModel"):getData()[costType] or 0
		end
		haveNum  = haveNum or 0	
		print(haveNum,"have---cost",cost)
		self._sCostImg:loadTexture("globalImageUI_littleDiamond.png",1)
		-- self._slotBtn:setTitleText("重新打孔")
		self._slotsBtn:setVisible(false)
		self._slotCostDes = nil
	else
		local unlockD = self._heroData.scrollUnlock and self._heroData.scrollUnlock[1]
		cost = unlockD and unlockD[3]
		local costType = unlockD and unlockD[1]
		local costId = unlockD and unlockD[2]
		_,haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(costId)
		if costType ~= "tool" then
		    costId = IconUtils.iconIdMap[costType] or costId
		    haveNum = self._modelMgr:getModel("UserModel"):getData()[costType] or 0
		end
		haveNum = haveNum or 0
		local costDes = lang("SKILLBOOK_TIPS1")
		local toolD = tab.tool[tonumber(costId)]
		local name = ""
		if toolD then
		    name = lang(toolD.name)
		end
		costDes = string.gsub(costDes,"%b{}",function(catchStr)
		    catchStr = string.gsub(catchStr,"{","")
		    catchStr = string.gsub(catchStr,"}","")
		    if string.find(catchStr,"$num") then
		        return cost
		    end 
		    if string.find(catchStr,"$name") then
		        return name 
		    end
		    return ""
		end)
		self._sCostImg:loadTexture("globalImageUI_splice.png",1)
		self._sCostImg:setScale(0.7)
		self._slotCostDes = costDes
		-- self._slotBtn:setTitleText("打孔")
		local _,haveAllSpl = self._modelMgr:getModel("ItemModel"):getItemsById(3002)
		self._slotsBtn:setVisible(haveAllSpl > 0 and haveNum < cost)
	end

	local isSlotAbundence = haveNum >= cost
	return isSlotAbundence,cost,haveNum
end

function HeroSpellBookView:addTableView( )
    local tableView = cc.TableView:create(cc.size(260, 355))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(1,45)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._listPanel:addChild(tableView)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(function ( table,cell )
        return self:tableCellTouched(table,cell)
    end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( table,index )
        return self:cellSizeForTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index )
        return self:tableCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table )
        return self:numberOfCellsInTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    self._tableView = tableView
end

function HeroSpellBookView:scrollViewDidScroll(view)
    -- print("scrollViewDidScroll")
end

function HeroSpellBookView:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function HeroSpellBookView:tableCellTouched(table,cell)
    -- print("cell touched at index: " .. cell:getIdx())
end

function HeroSpellBookView:cellSizeForTable(table,idx) 
    return 90,260
end

function HeroSpellBookView:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    end

    local item = cell:getChildByName("skillCell")
	if not item then
		item = self._skillCell:clone()
		item:setName("skillCell")
		item:setPosition(0,0)
		cell:addChild(item)
	end
	self:updateItem(item,self._tableData[idx+1])

    return cell
end

function HeroSpellBookView:updateItem( item,data )
	item = item or self._bookItem:clone()
	local isSlotMastery = not tab.playerSkillEffect[tonumber(data.sid)]
	local skillId = tonumber(data.sid)
	if isSlotMastery then
		local bookInfo = self._modelMgr:getModel("SpellBooksModel"):getData()[tostring(skillId)]
        if tonumber(bookInfo.l) > 1 then
        	skillId = tonumber(skillId .. (tonumber(bookInfo.l) - 1))
        end
	end
	local skillData = tab.skillBookBase[tonumber(data.sid)]
	-- 法术书名字
	local name = item:getChildByName("skillName")
	local tailStr = ""
	if OS_IS_WINDOWS then
		tailStr = "\n[" .. skillData.goodsId .. "/" .. skillData.id .. "]"
	end
	name:setString(lang(skillData.name) .. tailStr)

	-- 法术书图片
	local skillBookImg = item:getChildByFullName("skillImg")
	local art = skillData.art or skillData.icon
	local sfc = cc.SpriteFrameCache:getInstance()
	if sfc:getSpriteFrameByName(art ..".jpg") then
		skillBookImg:loadTexture("" .. art ..".jpg", 1)
	else
		skillBookImg:loadTexture("" .. art ..".png", 1) 
	end
	skillBookImg:setScale(62/skillBookImg:getContentSize().height)
	self:registerClickEvent(skillBookImg,function() 
		self._viewMgr:showHintView("global.GlobalTipView",
			{
				tipType = 2, 
				node = skillBookImg, 
				id = skillId,
				heroData = not isSlotMastery and clone(self._heroData), 
				skillLevel = 1,
				notAutoClose=true
			})
	end)	
	-- 进度条和数量
	local skillTag = item:getChildByName("skillTag")
	local qualityImg = item:getChildByName("qualityImg")
	local typeLab = item:getChildByName("typeLab")
	local lvl = item:getChildByName("lvl")
	local skillFrame = item:getChildByName("skillFrame")
	-- local spellInfo = self._spbInfo[tostring(data.id)]
	local level = data and data.l or 0
	local tp = skillData.nature or 1
	typeLab:setString("" or lang("magicSeriesSign_6" .. tp))
	skillTag:loadTexture("globalImageUI_skilltag_".. (tp + 1)..".png", 1)
	skillFrame:loadTexture("spellBook_itemFrame".. skillData.skillQuality ..".png", 1)
	qualityImg:loadTexture("spellBook_quality".. skillData.skillQuality ..".png", 1)
	lvl:setString(level)
	
	local equipTag = item:getChildByFullName("equipTag")
	local equipTagDes = equipTag:getChildByFullName("des")
	equipTagDes:getVirtualRenderer():setLineHeight(15)
	-- equipTagDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	equipTagDes:setPositionY(35)
	-- 是否装备到英雄身上
	local hadEquipedId = tonumber(self._heroData.slot.sid) and tonumber(self._heroData.slot.sid) ~= 0 
	local isEquiped = tonumber(self._heroData.slot.sid) == tonumber(data.sid)
    item:setBackGroundImage("skillBg_n_treasureSkill.png", 1)
	if isEquiped then
		item:setBackGroundImage("skillBg_s_treasureSkill.png", 1)
	-- else
	-- 	item:setBackGroundImage("skillBg_n_treasureSkill.png", 1)
	end
	equipTag:setVisible(isEquiped)
	if self._preSelId == data.sid then
		self._preSelectItem = item
		item:setBackGroundImage("skillBg_s_treasureSkill.png", 1)
	end
	self:registerClickEvent(item,function()
		local hadEquipedId = tonumber(self._heroData.slot.sid) and tonumber(self._heroData.slot.sid) ~= 0 
		local isEquiped = tonumber(self._heroData.slot.sid) == tonumber(data.sid)
		if hadEquipedId and not isEquiped then
			self._viewMgr:showTip("需要先卸下法术书")
			return 
		end
        if isEquiped then return end
        if not self._preSelId then
        	self._preSelectItem = item
        	self._preSelId = data.sid
        end
        if self._preSelId ~= data.sid then
        	self._preSelectItem:setBackGroundImage("skillBg_n_treasureSkill.png", 1)
            self._preSelectItem = item
            self._preSelId = data.sid
        end
        

        item:setBackGroundImage("skillBg_s_treasureSkill.png", 1)
		local isMatch = self:isMatch(data.sid) 
		self._markSid = isMatch and data.sid
	end)
	item:setSwallowTouches(false)

	return item
end

function HeroSpellBookView:numberOfCellsInTableView(tableView)
   return table.nums(self._tableData)
end

-- 接收自定义消息
function HeroSpellBookView:reflashUI(doAnim)
	-- 刻印界面
	local spellBooks = {}
	local spellBooksInfo = self._spModel:getData() or {}
	local tp,na = 0,0
	if self._heroData and self._heroData.slot then
		tp,na = self._heroData.slot.tp , self._heroData.slot.na
	end
	self._typeDes:setVisible(na ~= 0)
   	self._desBg:setVisible(na ~= 0)
   	self._sDesBg:setVisible(na ~= 0)
   	UIUtils:setGray(self._markBtn,na == 0)
   	self._slotBtn:setTitleText(na ~= 0 and "重新打孔" or "激活刻印孔")
   	self:detectTabOpen(doAnim)
	if na ~= 0 then 
		for k,v in pairs(spellBooksInfo) do
			local spellBook = {}
			spellBook.sid = k
			local isMatch = self:isMatch(k)
	        if isMatch and (not(v.b) or tonumber(v.b) == 0 or tonumber(v.b) == self._heroData.id) then
				table.merge(spellBook,v)
				table.insert(spellBooks,spellBook)
			end
		end
		table.sort(spellBooks,function( bookA,bookB )
			local aEquiped = tonumber(bookA.sid) == tonumber(self._heroData.slot.sid)
			local bEquiped = tonumber(bookB.sid) == tonumber(self._heroData.slot.sid)
			if aEquiped ~= bEquiped then
				return aEquiped 
			else
				local aOrder = bookA.order 
                local bOrder = bookB.order 
                if aOrder ~= bOrder then
                    return aOrder < bOrder 
                else
					return tonumber(bookA.sid) > tonumber(bookB.sid)
                end
			end
		end)
		self._tableData = spellBooks
		self._tableView:reloadData()
		self._noneDes:setVisible(#self._tableData == 0)
		self._noneDesS:setString(lang("SKILLBOOK_TIPS122"))
		self._markBtn._noSlotDes = nil
	else
		self._markBtn._noSlotDes = lang("TIP_SkillBook3")
    	self._noneDesS:setString(lang("TIP_SkillBook3"))
	end

	-- 消耗显示
	local isMarkAbundence,cost = self:isMarkAbundence()
	self._mCostLab:setString(cost)
	UIUtils:center2Widget(self._mCostImg,self._mCostLab,241,5)

	-- ---------------打孔界面-------------------------
	local isSlotAbundence,cost,haveNum = self:isSlotAbundence()
	self._sCostLab:setColor(UIUtils.colorTable.ccUIBaseColor9)
	-- self._sCostLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	if self._heroData.slot then 
		self._sCostLab:setString(cost)
	else
		self._sCostLab:setString(haveNum .. "/" .. cost)
		if haveNum < cost then
			self._sCostLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
			-- self._sCostLab:disableEffect()
		end
	end
	UIUtils:center2Widget(self._sCostImg,self._sCostLab,372,5)

	self:resetMarkSlot()
	self:resetDigSlot(doAnim)
end

function HeroSpellBookView:addLabel( node,name,imgName )
	local lab = ccui.Text:create()
	lab:setFontSize(16)
	lab:setFontName(UIUtils.ttfName)
	lab:setString(tostring(name) or "")
	lab:setColor(cc.c3b(255, 252, 226))
    lab:enable2Color(1, cc.c4b(255, 232, 125, 255))
	lab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	lab:setPosition(node:getContentSize().width/2,5)
	node:addChild(lab)

	local img = ccui.ImageView:create()
	img:loadTexture(imgName,1)
	img:setPosition(node:getContentSize().width/2,node:getContentSize().height/2)
	node:addChild(img)
end

function HeroSpellBookView:initSlotPanel( )
	-- 孔
	local allSlots = {}
	local leftSlots = {}
	local rightSlots = {}
	local slotNames = {
		"火","水","彩虹","气","土",
		"神剑","中级","万能","大招","被动",
	}

	local slotImgs = {
		"spellBook_na_1.png","spellBook_na_2.png","spellBook_na_5.png","spellBook_na_3.png","spellBook_na_4.png",
		"spellBook_tp_1.png","spellBook_tp_2.png","spellBook_tp_5.png","spellBook_tp_3.png","spellBook_tp_4.png",
	}
	local slotT = self:getUI("bg.layer.slotPanel.slots.slot_1")
	local posx,posy = slotT:getContentSize().width/2,slotT:getContentSize().height/2
	local mc 
	local mcName = {
		"xuanzhong2_skillbookfashukeyin",
		"xuanzhong2_skillbookfashukeyin",
		"xuanzhong1_skillbookfashukeyin",
		"xuanzhong2_skillbookfashukeyin",
		"xuanzhong2_skillbookfashukeyin",
	}
	self._animMcs = {}
	for i=1,5 do
		local slot = self:getUI("bg.layer.slotPanel.slots.slot_" .. i)
		self:addLabel(slot,slotNames[i],slotImgs[i])
		table.insert(leftSlots,slot)
		table.insert(allSlots,slot)

		mc = mcMgr:createViewMC(mcName[i],true,false)
		if i == 3 then
			mc:setPosition(posx+5,posy+8)
			mc:setScale(1.4)
		else
			mc:setPosition(posx,posy)
			mc:setScale(1.2)
		end
		slot:addChild(mc,99)
		slot._mc = mc
		table.insert(self._animMcs,mc)
	end
	-- 调整位置
	self._animMcs[5],self._animMcs[3] = self._animMcs[3],self._animMcs[5]
	self._animMcs[5]._nextMc = self._animMcs[1]
	self._animMcs[1]._nextMc = self._animMcs[2]
	self._animMcs[2]._nextMc = self._animMcs[3]
	self._animMcs[3]._nextMc = self._animMcs[4]
	self._animMcs[4]._nextMc = self._animMcs[5]
	slotT = self:getUI("bg.layer.slotPanel.slots.slot_3")
	slotT:setScale(1)
	mc = mcMgr:createViewMC("changtai_skillbookfashukeyin",true,false)
	mc:setPosition(posx+5,posy+8)
	slotT:addChild(mc,99)
	slotT._bMc = mc

	for i=6,10 do
		local slot = self:getUI("bg.layer.slotPanel.slots.slot_" .. i)
		self:addLabel(slot,slotNames[i],slotImgs[i])
		table.insert(rightSlots,slot)
		table.insert(allSlots,slot)
	end

	self._curSlot = self:getUI("bg.layer.slotPanel.slots.slot")
	self._allSlots = allSlots
	self._leftSlots = leftSlots
	self._rightSlots = rightSlots 
end

function HeroSpellBookView:sendRefreshMsg( num )
	local isSlotAbundence,cost = self:isSlotAbundence()
	if not isSlotAbundence then
		if not self._slotCostDes then
			DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"), callback1=function( )
			    local viewMgr = ViewManager:getInstance()
			    viewMgr:showView("vip.VipView", {viewType = 0})
			end})
		else
			local des = lang("SKILLBOOK_TIPS123")
			if not des or des == "" then
				des = "英雄碎片不足"
			end
			self._viewMgr:showTip(des)
		end
		return 
	end
	if self._slotCostDes then
		DialogUtils.showShowSelect({desc = self._slotCostDes,callback1=function( )
		    self._serverMgr:sendMsg("HeroServer","initHeroSlot",{heroId = self._heroData.id}, true, {}, function(result, success)
		        BattleUtils.unLockSkillHero[self._heroData.id] = true
		        local heroData = result.d and result.d.heros
		        if self._heroData then
		            self._modelMgr:getModel("HeroModel"):mergeHeroData(self._heroData, heroData[tostring(self._heroData.id)] or {})
		        end
		        if heroData then
			        self:doChangeMc(function( )
			        	if not self.showSaveBtn then return end
			            self:showSaveBtn(false)
			            self:reflashUI(true--[[doAnim]])
			            local addScore = self._heroData.slot and self._heroData.slot.score or 0
		                if addScore > 0 then
							TeamUtils:setFightAnim(self:getUI("bg.layer"),{x=250,y=480,oldFight = 0,newFight=addScore,})
						end
		            end)
			    end

		    end)
		end})
		return
	end
	local sid = self._heroData.slot and self._heroData.slot.sid
	if sid and sid ~= 0 then
		DialogUtils.showShowSelect({desc = lang("SKILLBOOK_TIPS6"),callback1=function( )
	    		self._serverMgr:sendMsg("HeroServer","refreshHeroSlot",{heroId = self._heroData.id,num = num}, true, {}, function(result, success)
			    	local heroData = result.d and result.d.heros
		            if self._heroData then
	                    self._modelMgr:getModel("HeroModel"):mergeHeroData(self._heroData, heroData[tostring(self._heroData.id)] or {})
		                if self.runRefreshAnim then
		                	local from = self._heroData.slot and self._heroData.slot.na or 1
		                	local tempArr = self._heroData.slot 
                				and self._heroData.slot.tmp
                                and json.decode(self._heroData.slot.tmp )
		                	local to = tempArr
		                				and tempArr["1"] 
		                				and tempArr["1"]["2"]
		                				or from
		                	local selMap = {1,2,4,5,3} 
		                	to = selMap[to]
			                self:runRefreshAnim(from,to,function( )
			                	if to == 3 then
			                		self:showSaveBtn(false)
			                		self:sendSaveMsg()
			                	else
					                if num == 1 then
						                self:showSaveBtn(true)
						            else
						            	self._viewMgr:showDialog("spellbook.SpellBookRefreshView",{heroData = self._heroData,result=result.attr})
						            end
					                self:reflashUI()
					            end
			                end)
			            end
	                end
			    end)
        end})
	else
    	self._serverMgr:sendMsg("HeroServer","refreshHeroSlot",{heroId = self._heroData.id,num = num}, true, {}, function(result, success)
		    local heroData = result.d and result.d.heros
            if self._heroData then
                self._modelMgr:getModel("HeroModel"):mergeHeroData(self._heroData, heroData[tostring(self._heroData.id)] or {})
	            if self.runRefreshAnim then
	                local from = self._heroData.slot and self._heroData.slot.na or 1
                    local tempArr = self._heroData.slot 
                				and self._heroData.slot.tmp
                                and json.decode(self._heroData.slot.tmp )
                	local to = tempArr
                				and tempArr["1"] 
                				and tempArr["1"]["2"]
                				or from
                	local selMap = {1,2,4,5,3} 
                	to = selMap[to]
	                self:runRefreshAnim(from,to,function( )
		                if to == 3 then
		                	self:showSaveBtn(false)
	                		self:sendSaveMsg()
	                	else
			                if num == 1 then
				                self:showSaveBtn(true)
				            else
				            	self._viewMgr:showDialog("spellbook.SpellBookRefreshView",{heroData = self._heroData,result=result.attr})
				            end
			                self:reflashUI()
			            end
	                end)
	            end
            end
	    end)
	end
end

function HeroSpellBookView:sendSaveMsg( )
	self._serverMgr:sendMsg("HeroServer","saveHeroSlot",{heroId = self._heroData.id,id = 1}, true, {}, function(result, success)
    	local heroData = result.d and result.d.heros
        if self._heroData and heroData then
            self._modelMgr:getModel("HeroModel"):mergeHeroData(self._heroData, heroData[tostring(self._heroData.id)] or {})
            self:doChangeMc(function( )
            	if not self.showSaveBtn then return end
	            self:showSaveBtn(false)
	            self:reflashUI(true--[[doAnim]])
            end)
        end
    end)
end

function HeroSpellBookView:runRefreshAnim( from,to,callback )
	self._tabEventTarget[1]:setEnabled(false)
	self._tabEventTarget[2]:setEnabled(false)
	self._slotBtn:setEnabled(false)
	self._closeBtn:setEnabled(false)

	local na = self._heroData.slot.na 
	local selMap = {1,2,4,5,3}
	local selNa = selMap[na]
	local rSelSlot = self._leftSlots[selNa]
	rSelSlot._mc:setVisible(false)
	if rSelSlot._bMc then rSelSlot._bMc:setVisible(false) end
	-- 
	local delay = 0.1
	local runCircleNum =5+to-- GRandom(2, 3)*5+to
	local runAnim 
	runAnim= function( idx,nextMc )
		if idx < runCircleNum then
			local mc = nextMc or self._animMcs[idx%5+1]
			mc:setVisible(true)
			mc:runAction(cc.Sequence:create(
				cc.DelayTime:create(delay),
				cc.CallFunc:create(function()
					mc:setVisible(false)
					nextMc = mc._nextMc
					runAnim(idx+1,nextMc)
				end)
			))
		else
			if callback then callback() end
			self._tabEventTarget[1]:setEnabled(true)
			self._tabEventTarget[2]:setEnabled(true)
			self._slotBtn:setEnabled(true)
			self._closeBtn:setEnabled(true)
			return 
		end
	end
	runAnim(from,rSelSlot._mc)
end

function HeroSpellBookView:doChangeMc(callback)
	self._okBtn:setEnabled(false)
	local textureUp = self:getUI("bg.layer.slotPanel.equipBg.textureUp")
	local anim1,anim2,anim3,anim4
	local anim3 = function( )
		local bright = 0
		if not self._schedule then
			self._schedule = ScheduleMgr:regSchedule(20, self, function(self, dt)
		        textureUp:setBrightness(bright)
		        bright = (bright+5)%50
		    end)
		end
	end

	local anim4 = function( )
		self._slotMc:gotoAndPlay(0)
		self._slotMc:setVisible(true)
		self._slotMc:addCallbackAtFrame(20,function( )
			self._slotMc:stop()
			self._slotMc:setVisible(false)
			if callback then callback() end
			
			textureUp:setBrightness(0)
			self._okBtn:setEnabled(true)
			self:showResult()
		end)
		self:baodouAnim()
	end

	local anim2 = function( )
		local rotations = {45,320,140,220,90}
		local rotaIdx = self._heroData.slot.na
		self._rotaMc:gotoAndPlay(0)
		self._rotaMc:setVisible(true)
		self._rotaMc:setAnchorPoint(-0.5,0)
		self._rotaLy:setRotation(rotations[rotaIdx])
		self._rotaMc:addCallbackAtFrame(10,function( )
			anim3()
		end)
		self._rotaMc:addCallbackAtFrame(20,function( )
			self._rotaMc:stop()
			self._rotaMc:setVisible(false)
			anim4()
			if self._schedule then
				ScheduleMgr:unregSchedule(self._schedule)
				self._schedule = nil
			end

		end)
	end

	local anim1 = function( )
		self._digMc:gotoAndPlay(0)
		self._digMc:setVisible(true)
		self._digMc:addCallbackAtFrame(20,function( )
			self._digMc:stop()
			self._digMc:setVisible(false)
		end)
	end

	
	anim1()
	anim2()
end

function HeroSpellBookView:baodouAnim( )
    local textureUp = self:getUI("bg.layer.slotPanel.equipBg.textureUp")
    local textureC = textureUp:clone()
    local na = self._heroData.slot.na or 1
    textureC:loadTexture("spellBook_markTag" .. na .. ".png",1)
    textureC:setPosition(95,0)
    local child = textureC:getChildren() and textureC:getChildren()[1]
    if child then
    	child:loadTexture("spellBook_markTag" .. na .. ".png",1)
    end
    -- textureC:setScale(1)
    local clipNode = cc.ClippingNode:create()
    clipNode:setContentSize(cc.size(130,130))
    clipNode:setPosition(50,50)
    clipNode:setScale(1)
    clipNode:setName("clipNode")
    -- self:getUI("bg.layer.slotPanel.equipBg"):addChild(clipNode)
    self._curSlot:addChild(clipNode,-1)

    local mask = ccui.ImageView:create()
    mask:loadTexture("globalImage_IconMaskCircle.png",1)
    mask:setColor(cc.c4b(0, 0, 0,255))
    mask:setName("mask")
    clipNode._mask = mask
    -- mask:setContentSize(cc.size(130,130))
    mask:setPosition(0,0)

    mask:setScale(0.2)
    clipNode:setStencil(mask)
    clipNode:setAlphaThreshold(0.05)
	local mask = clipNode._mask 

	clipNode:addChild(textureC)
    textureC:setBrightness(30)
    -- self:lock(-1)
    local scale = 0.1
    if self._baoScheduler then
    	ScheduleMgr:unregSchedule(self._baoScheduler)
        -- self:unlock()
        self._baoScheduler = nil
    end
    -- if true then return end
    self._baoScheduler = ScheduleMgr:regSchedule(1, self, function( )
        scale = scale+0.1
        if scale >= 3.5 then
            if self._baoScheduler then 
                ScheduleMgr:unregSchedule(self._baoScheduler)
                -- self:unlock()
                self._baoScheduler = nil
                -- textureC:setBrightness(100)
                clipNode:removeFromParent()
                self:reflashUI()
            end
        else
        	textureC:setBrightness(math.max(0,30-2))
            mask:setScale(scale)
            clipNode:setStencil(mask)
            clipNode:setAlphaThreshold(0.05)
        end
    end)
end

function HeroSpellBookView:showResult( )
	local mc = self._resultTip._mc1
	if not mc then
		mc = mcMgr:createViewMC("zitiguang_kaiqi",false,false)
		self._resultTip:addChild(mc,99)
		self._resultTip._mc1 = mc
		mc:setPositionY(-4)
	end
	mc:gotoAndPlay(0)
	mc:addCallbackAtFrame(20,function( )
		mc:gotoAndStop(0)
	end)
	local na = self._heroData.slot.na
	local naDesMap = {"火系","水系","气系","土系","彩虹"}
	if na == 5 then
		local mc = self._resultTip._mc2
		if not mc then
			mc = mcMgr:createViewMC("caidai_huodetitleanim",false,false)
			self._resultTip:addChild(mc,99)
			self._resultTip._mc2 = mc
		end
		mc:gotoAndPlay(0)
		mc:setVisible(true)
		mc:addCallbackAtFrame(20,function( )
			mc:gotoAndStop(0)
			mc:setVisible(false)
		end)

		local mc = self._resultTip._mc3
		if not mc then
			mc = mcMgr:createViewMC("yanhua_juanxiandonghua",false,false)
			self._resultTip:addChild(mc,99)
			self._resultTip._mc3 = mc
		end
		mc:gotoAndPlay(0)
		mc:addCallbackAtFrame(20,function( )
			mc:gotoAndStop(0)
		end)	
	end
	self._resultDes:setString("成功获得" .. naDesMap[na] .. "孔")
	self._resultDes:setFontSize(24)
	self._resultTip:setScale(0.2)
	self._resultTip:setVisible(true)
	self._resultTip:setOpacity(255)
	self._resultTip:runAction(cc.Sequence:create(
		cc.ScaleTo:create(0.2,1),
		cc.DelayTime:create(1.2),
		cc.CallFunc:create(function( )
			self._resultTip:runAction(cc.FadeOut:create(0.2))
			-- self._resultTip:setVisible(false)
		end)
	))
end

function HeroSpellBookView:onDestroy( )
	if self._schedule then
		ScheduleMgr:unregSchedule(self._schedule)
		self._schedule = nil
	end
	if self._baoScheduler then
		ScheduleMgr:unregSchedule(self._baoScheduler)
		self._baoScheduler = nil
	end
end

return HeroSpellBookView