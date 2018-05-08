--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-09-09 20:20:28
--
local SpellBookUpDialog = class("SpellBookUpDialog",BasePopView)
function SpellBookUpDialog:ctor(param)
    self.super.ctor(self)
    self._callback = param.callback
    self._spellId = param and param.spellId
    self._bookD = tab.skillBookBase[tonumber(self._spellId) or 0]
    self._spellModel = self._modelMgr:getModel("SpellBooksModel")
    local skillType = self._bookD and self._bookD.skillType 
	self._isMastery = skillType and skillType ~= 1
	self._tipHeroData = clone(ModelManager:getInstance():getModel("HeroModel"):getData()["60102"])
end
function SpellBookUpDialog:getAsyncRes( )
	return 
	{
		{"asset/ui/hero1.plist", "asset/ui/hero1.png"},
		{"asset/ui/hero.plist", "asset/ui/hero.png"},
	}
end
-- 初始化UI后会调用, 有需要请覆盖
function SpellBookUpDialog:onInit()
	self:registerClickEventByName("bg.closeBtn",function( )
		self.dontRemoveRes = true
		if self._callback then
			self._callback()
		end
	    self:close()
	    UIUtils:reloadLuaFile("spellbook.SpellBookUpDialog")
	end)

	self._upgradeBtn = self:getUI("bg.upgradeBtn")
	self:registerClickEventByName("bg.upgradeBtn",function() 
		if self._upgradeBtn._status == "active" then 
			self:sendActiveMsg(self._spellId)
		elseif self._upgradeBtn._status == "upgrade" then
			self:sendUpMsg(self._spellId)
		elseif self._upgradeBtn._status == "notEnough" then
			self._viewMgr:showTip(lang("SKILLBOOK_TIPS2"))
			-- DialogUtils.showItemApproach(self._bookD.goodsId)
		end
	end)

	local title = self:getUI("bg.headBg.title")
	UIUtils:setTitleFormat(title,1)
	self._title = title
	self._topImg = self:getUI("bg.topImg")
	self._skill_icon = self:getUI("bg.skill_icon")
	self._attPanel_1 = self:getUI("bg.attPanel_1")
	self._attPanel_2 = self:getUI("bg.attPanel_2")

	self._layer_effect = self:getUI("bg.image_bg_2.layer_effect")
	self._costImg = self:getUI("bg.costImg")
	self._cost = self:getUI("bg.cost")
	self._materialNode = self:getUI("bg.materialNode")
	self._layerEffect = self:getUI("bg.image_bg_2.layer_effect")
	self._activeBuff = self:getUI("bg.activeBuff")
	self._buffDes = self:getUI("bg.activeBuff.buffDes")
	local exDes1 = ccui.Text:create()
	exDes1:setFontName(UIUtils.ttfName)
	exDes1:setFontSize(16)
	exDes1:setString("(激活后直接生效)")
	exDes1:setSaturation(0)
	exDes1:setColor(cc.c3b(79,68,67))
	self._buffDes.exDes = exDes1
	self._activeBuff:addChild(exDes1)
	self._buffDes2 = self:getUI("bg.activeBuff.buffDes2")
	local exDes2 = ccui.Text:create()
	exDes2:setFontName(UIUtils.ttfName)
	exDes2:setFontSize(16)
	exDes2:setString("(升级后可增加使用次数)")
	exDes2:setSaturation(0)
	exDes2:setColor(cc.c3b(79,68,67))
	self._activeBuff:addChild(exDes2)
	self._buffDes2.exDes = exDes2
	local exDes3 = ccui.Text:create()
	exDes3:setFontName(UIUtils.ttfName)
	exDes3:setFontSize(16)
	exDes3:setString("属性加成无需刻印即可生效")
	exDes3:setSaturation(0)
	exDes3:setPosition(145,70)
	exDes3:setColor(cc.c3b(79,68,67))
	self._exDes3 = exDes3
	self._materialNode:addChild(exDes3,999)
	self:listenReflash("ItemModel", self.reflashUI)

	-- 刷光条
	-- audioMgr:playSound("adTag")
	local mcShua = mcMgr:createViewMC("shuxingshuguang_itemeffectcollection", true, false, function (_, sender)
	    sender:removeFromParent()
	end,RGBA8888)
	mcShua:setPosition(self._attPanel_1:getContentSize().width/2-100,self._attPanel_1:getContentSize().height/2)
	-- mcShua:setPlaySpeed(0.2)
	self._attPanel_1:addChild(mcShua,99)
	self._mcShua1 = mcShua
	self._mcShua1:stop()
	self._mcShua1:setVisible(false)
	
	local mcShua = mcMgr:createViewMC("shuxingshuguang_itemeffectcollection", true, false, function (_, sender)
	    sender:removeFromParent()
	end,RGBA8888)
	mcShua:setPosition(self._attPanel_2:getContentSize().width/2-100,self._attPanel_2:getContentSize().height/2)
	-- mcShua:setPlaySpeed(0.2)
	self._attPanel_2:addChild(mcShua,99)
	self._mcShua2 = mcShua
	self._mcShua2:stop()
	self._mcShua2:setVisible(false)

	local mc1 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
    mc1:setPosition(70, 28)
    mc1:setVisible(false)
    self._upgradeBtn._animMc = mc1
    self._upgradeBtn:addChild(mc1, 1)

end

function SpellBookUpDialog:onShow( )
	self:updateRealVisible(true)
end

-- 接收自定义消息
function SpellBookUpDialog:reflashUI(data)
	local spellInfo = self._modelMgr:getModel("SpellBooksModel"):getData()
	local curSpellInfo = spellInfo[tostring(self._spellId)]
	self._curInfo = curSpellInfo 
	local isEnough,canUp = self:detectEnough()
	if not curSpellInfo or curSpellInfo.l < 1 then
		self._upgradeBtn:setTitleText("激活")
		self._upgradeBtn._status = "active"
		self._activeBuff:setVisible(true)
		self._layer_effect:setOpacity(0)
		self._title:setString("法术书激活")
	else
		self._upgradeBtn:setTitleText("升级")
		self._upgradeBtn._status = "upgrade"
		self._activeBuff:setVisible(false)
		self._layer_effect:setOpacity(255)
		self._title:setString("法术书升级")
	end
	self._upgradeBtn._status = isEnough and self._upgradeBtn._status or "notEnough"
	self._upgradeBtn:setVisible(canUp)
	self._topImg:setVisible(not canUp)
	self._costImg:setVisible(false and canUp)
	self._cost:setVisible(false and canUp)
	local level = curSpellInfo and curSpellInfo.l or 0
	local maxLevel = #self._bookD.skillbook_exp
	local needNum = self._bookD.skillbook_exp[math.min(maxLevel,level+1)] or 0
	local itemId = self._bookD.goodsId 
	local _,haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
	self._upgradeBtn._animMc:setVisible(canUp and haveNum >= needNum)
	self._materialNode:setVisible(level < maxLevel)
	-- if haveNum < needNum then
	-- 	-- UIUtils:setGray(self._upgradeBtn,true)
	-- 	-- self._upgradeBtn:setEnabled(false)
	-- 	self._cost:setColor(UIUtils.colorTable.ccUIBaseColor6)
	-- else
	-- 	-- UIUtils:setGray(self._upgradeBtn,false)
	-- 	-- self._upgradeBtn:setEnabled(true)
	-- 	self._cost:setColor(UIUtils.colorTable.ccUIBaseColor9)
	-- end
	-- local toolD = tab.tool[itemId]
	-- self._costImg:loadTexture(toolD.art .. ".png",1)
	-- self._costImg:setScale(30/self._costImg:getContentSize().width)
	self._cost:setString(haveNum .. "/" .. needNum)
	self:reflashMatNode(itemId,haveNum,needNum)
	UIUtils:center2Widget(self._costImg,self._cost,230,5)
	self:reflashSkillInfo()
	if not tolua.isnull(self._approachView) then
		self._approachView:reflashUI()
	end
end

function SpellBookUpDialog:reflashSkillInfo()
	local skillId = tonumber(self._spellId)
	local skillData = {}
	local skillType = self._bookD.skillType 
	self._isMastery = skillType ~= 1
	masterIdByLvl = ""
	local lvl = self._curInfo and self._curInfo.l or 0
	if self._isMastery and lvl and lvl > 1 then
		masterIdByLvl = lvl-1
	end
	if skillType == 1 then 
		skillData = tab.playerSkillEffect[skillId]
	else
		skillData = tab.heroMastery[tonumber(skillId .. masterIdByLvl)]
	end
	if not skillData then return end
	local skill_icon_touch = self._skill_icon:getChildByName("skill_icon_touch")
    local icon = skill_icon_touch:getChildByName("skillIcon")
    if not icon then
    	icon = ccui.ImageView:create()
    	-- icon:loadTexture(IconUtils.iconPath .. skillData.art .. ".png")
	    --icon:setScale(0.85)
	    icon:setName("skillIcon")
	    skill_icon_touch:addChild(icon)
		local skillLevel = 1
		local sklevel = 1
	    local spellInfo = self._spellModel:getData()
	    local bookInfo = spellInfo and spellInfo[tostring(skillId)]
		local tipHeroData = nil
	    if bookInfo and bookInfo.b then
	    	local heroId = tonumber(bookInfo.b)
			if heroId and heroId ~= 0 then
		    	local heroData = self._modelMgr:getModel("HeroModel"):getHeroData(heroId)
		    	local heroDataC = heroData and clone(heroData) or {}
		    	local sid = heroDataC.slot and heroDataC.slot.sid and tonumber(heroDataC.slot.sid)
		        if sid and sid ~= 0 then
		            local bookId = tonumber(sid)
		            local bookInfo = self._modelMgr:getModel("SpellBooksModel"):getData()[tostring(bookId)]
		            if bookInfo then
		                heroDataC.skillex = {heroDataC.slot.sid, heroDataC.slot.s, bookInfo.l}
		            end
			        local attributeValues = BattleUtils.getHeroAttributes(heroDataC)
					tipHeroData = heroDataC
					skillLevel = bookInfo and bookInfo.l or 1
			        for k,v in pairs(attributeValues.skills) do
			            local sid1 = v[1]
						if skillId == sid1 then
			                sklevel = v[2] or 1
                			skillLevel = not self._isMastery and v[3] or v[2] or 1
			                break
			            end
			        end
		        end
			else
				skillLevel = bookInfo and bookInfo.l or 1
	        	tipHeroData = clone(ModelManager:getInstance():getModel("HeroModel"):getData()["60102"])
		    end
	    end
		self._tipHeroData = tipHeroData or self._tipHeroData
	    self:registerClickEvent(skill_icon_touch,function() 
	    	self._viewMgr:showHintView("global.GlobalTipView",
			{
				tipType = 2, 
				node = icon, 
				id = tonumber(skillId .. masterIdByLvl),
				heroData = not self._isMastery and self._tipHeroData,--clone(self._heroData), 
				skillLevel = skillLevel,
				sklevel = sklevel,
				notAutoClose=true
			})
	    end)
	end
	icon:loadTexture(IconUtils.iconPath .. (skillData.art or skillData.icon) .. ".png",1)
    icon:setPosition(skill_icon_touch:getContentSize().width / 2, skill_icon_touch:getContentSize().height / 2)
    local skillType = skillData.type or 1
    local color = UIUtils.colorTable["ccUIHeroSkillColor" .. skillType]
    local labelSkillName = self._skill_icon:getChildByName("label_skill_name")
    labelSkillName:setColor(color)
    local debugId = ""
    if OS_IS_WINDOWS then
    	debugId = "\n[" .. self._bookD.id .. masterIdByLvl .. "/" .. self._bookD.goodsId ..  "]"
    end
    labelSkillName:setString(lang(skillData.name) .. debugId)

    --add  by wangyan
    local image_fire = skill_icon_touch:getChildByName("image_fire")
    local image_water = skill_icon_touch:getChildByName("image_water")
    local image_wind = skill_icon_touch:getChildByName("image_wind")
    local image_soil = skill_icon_touch:getChildByName("image_soil")
    
    local sysSkillData = tab.skillBookBase[self._spellId]
    local imgRes = {"skill_bg_fire01_hero", "skill_bg_water01_hero", "skill_bg_wind01_hero", "skill_bg_soil01_hero"}
    local iconList = {image_fire, image_water, image_wind, image_soil}
    if sysSkillData and sysSkillData["type"] == 4 then
        for i=1, 4 do
            iconList[i]:loadTexture(imgRes[i] .. ".png", 1)
        end
    end

    image_fire:setVisible(skillType == 2)
    image_water:setVisible(skillType == 3)
    image_wind:setVisible(skillType == 4)
    image_soil:setVisible(skillType == 5)
    self._skill_icon:getChildByName("final_skill_0"):setVisible(skillData.dazhao ~= nil)

    self:reflashAttPanel()
end

function SpellBookUpDialog:reflashAttPanel( )
	dump(self._curInfo,"curInfol.......")
	local lvl = self._curInfo and self._curInfo.l or 0
	local notActive =  not lvl or lvl < 1
	self._attPanel_1:setVisible(not notActive and not self._isMastery)
	self._attPanel_2:setVisible(not notActive)
	local rtx = self._layer_effect:getChildByFullName("skillDes")
	local masterIdByLvl = ""
	if self._isMastery  and lvl and lvl > 1 then
		local maxLevel = #self._bookD.skillbook_exp
		masterIdByLvl = math.min(lvl,maxLevel-1)
	end
	if notActive or self._isMastery then
		local GlobalTipView = require("game.view.global.GlobalTipView")
		local tipDataD = GlobalTipView["getDataDForTipType2"](GlobalTipView,
	    { tipType = 2, node = self._attPanel_1, id = tonumber(self._bookD.id .. masterIdByLvl), 
	    skillLevel = lvl,sklevel = 1,heroData = self._tipHeroData ,isSlotMastery = self._isMastery})
	    local skillDes = GlobalTipView._des or ""
	    skillDes = string.gsub(skillDes, "fontsize=16", "fontsize=20") -- 
	    skillDes = string.gsub(skillDes, "fontsize=17", "fontsize=20") -- 
	    skillDes = string.gsub(skillDes, "fontsize=18", "fontsize=20") -- 
	    skillDes = string.gsub(skillDes, "fontsize=20", "fontsize=20") -- 
	    skillDes = string.gsub(skillDes, "fontsize=24", "fontsize=20") -- 
	    skillDes = string.gsub(skillDes, "color=3d1f00", "color=fae0bc")
	    skillDes = string.gsub(skillDes, "outlinecolor=3c1e0a00", "")
	    skillDes = string.gsub(skillDes, "outlinecolor=3c1e0aff", "")
	    skillDes = string.gsub(skillDes, "outlinesize=1", "")
	    skillDes = string.gsub(skillDes, "outlinesize=2", "")

	    GlobalTipView._des = nil
		self._skillDes = skillDes
        if rtx then rtx:removeFromParent() end
        rtx = RichTextFactory:create("[color = 8a5c1d,fontsize=20]" .. skillDes ..  "[-]", 350, 112)
        rtx:formatText()
        rtx:setName("skillDes")
        local w = rtx:getInnerSize().width
        local h = rtx:getInnerSize().height
        rtx:setPosition(370-w/2, 130-h/2)
        self._layer_effect:addChild(rtx, 99)
        if stage == 0 then UIUtils:setGray(rtx,true) end
        UIUtils:alignRichText(rtx, { hAlign = "top"})
	else
		if rtx then
			rtx:setVisible(false)
		end
	end
	self._exDes3:setVisible(not notActive)

	-- 刷新属性
	local frequency = self._bookD.frequency
	local freNum = table.nums(frequency)
	local curFre = math.min(lvl+1,freNum)
	local nextFre = math.min(lvl+2,freNum)
	local arrow = self:getUI("bg.attPanel_1.arrow")
	local att1 = self:getUI("bg.attPanel_1.att1")
	att1:setColor(cc.c3b(255, 252, 226))
    att1:enable2Color(1, cc.c4b(255, 232, 125, 255))
    att1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    att1:setString("释放次数:" .. frequency[curFre])
    local att2 = self:getUI("bg.attPanel_1.att2")
	att2:setColor(cc.c3b(255, 252, 226))
    att2:enable2Color(1, cc.c4b(255, 232, 125, 255))
    att2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	self._releaseNum = frequency[nextFre]
	att2:setString("释放次数:" .. frequency[nextFre])
	self._buffDes2:setString("战斗中释放次数:".. frequency[nextFre] .."次")
	self._buffDes2.exDes:setPosition(
		self._buffDes2:getPositionX()+self._buffDes2:getContentSize().width+90, 
		self._buffDes2:getPositionY()
	)
	self._buffDes2:setVisible(not self._isMastery)
	self._buffDes2.exDes:setVisible(not self._isMastery)
	if curFre == nextFre then
		arrow:setVisible(false)
		att2:setVisible(false)
		self._attPanel_1:setPositionX(150)
	else
		arrow:setVisible(true)
		att2:setVisible(true)
		self._attPanel_1:setPositionX(50)
    end
    
    local quality_type = self._bookD.quality_type
	local quality = self._bookD.quality
	local freNum = table.nums(quality)-1
	local curIdx = math.min(lvl,freNum)
	local nextIdx = math.min(lvl+1,freNum)
	local arrow = self:getUI("bg.attPanel_2.arrow")
	local attName = lang("ARTIFACTDES_PRO_" .. quality_type)
    if not attName or attName == "" then
        attName = lang("ATTR_" .. quality_type)
    end
	local attName1 = self:getUI("bg.attPanel_2.attName1")
	attName1:setString(attName)
	self._attName = attName
    local attName2 = self:getUI("bg.attPanel_2.attName2")
    attName2:setString(attName)
    local att1 = self:getUI("bg.attPanel_2.att1")
    local att1Num = self._spellModel:sumLvlQuality(self._bookD.id,curIdx)
    local att2Num = self._spellModel:sumLvlQuality(self._bookD.id,nextIdx)
    att1:setString(att1Num)
    local att2 = self:getUI("bg.attPanel_2.att2")
	att2:setString(att2Num)
	self._attNum = att2Num
	self._buffDes:setString("属性加成：".. attName .. "+" .. att2Num)
	self._buffDes.exDes:setPosition(
		self._buffDes:getPositionX()+self._buffDes:getContentSize().width+64, 
		self._buffDes:getPositionY()
	)
	if curIdx == nextIdx then
		arrow:setVisible(false)
		att2:setVisible(false)
		attName2:setVisible(false)
		self._attPanel_2:setPositionX(150)
	else
		arrow:setVisible(true)
		att2:setVisible(true)
		attName2:setVisible(true)
		self._attPanel_2:setPositionX(50)
    end
    -- 4.5版本逻辑
    if self._isMastery and not notActive then
    	self._attPanel_2:setPositionY(200)
    	if not self._masteryDes then
    		self._masteryDes = ccui.Text:create()
    		self._masteryDes:setFontSize(20)
    		self._masteryDes:setFontName(UIUtils.ttfName)
    		self._masteryDes:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            self._masteryDes:setString("附加效果")
    		self._masteryDes:setPosition(230,180)
    		self:getUI("bg"):addChild(self._masteryDes)
    	end
    	if rtx then
    		local w = rtx:getInnerSize().width
	        local h = rtx:getInnerSize().height
	        local realW = rtx:getRealSize().width
	        if realW < 340 then
		        rtx:setPosition(370+(370-realW)/2-w/2,60-h/2)
		    else
		    	rtx:setPosition(370-w/2,60-h/2)
	    	end
    	end
    	self._masteryDes:setVisible(true)
    else
    	if self._masteryDes then
    		self._masteryDes:setVisible(false)
    	end
    	if rtx then
    		local w = rtx:getInnerSize().width
	        local h = rtx:getInnerSize().height
	        rtx:setPosition(370-w/2, 130-h/2)
    	end
    end
end

function SpellBookUpDialog:reflashMatNode( itemId,hadNum,needNum )
    local item = self._materialNode
    local icon = self._materialNode._icon
    local needNumLab = item:getChildByName("needNum")
    if hadNum < needNum then
        needNumLab:setColor(UIUtils.colorTable["ccUIBaseColor6"])
        -- needNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        local suo = 2 
        if icon then
        	IconUtils:updateItemIconByView(icon, {
	            itemId = itemId,
	            eventStyle = 3,
	            suo = suo,
	            clickCallback = function()
	                self._approachView = DialogUtils.showItemApproach(itemId)
	            end
	        } )
        else
	        icon = IconUtils:createItemIconById( {
	            itemId = itemId,
	            eventStyle = 3,
	            suo = suo,
	            clickCallback = function()
	                self._approachView = DialogUtils.showItemApproach(itemId)
	            end
	        } )
	        item:addChild(icon)
	        item._icon = icon
	    end
    else
        if icon then
        	IconUtils:updateItemIconByView(icon, {
	            itemId = itemId,
	            eventStyle = 3,
	            suo = 3,
	            clickCallback = function()
	                self._approachView = DialogUtils.showItemApproach(itemId)
	            end
	        } )
        else
	        icon = IconUtils:createItemIconById( {
	            itemId = itemId,
	            eventStyle = 3,
	            clickCallback = function()
	                self._approachView = DialogUtils.showItemApproach(itemId)
	            end
	        } )
	        item:addChild(icon)
	        item._icon = icon
	    end
        needNumLab:setColor(UIUtils.colorTable["ccUIBaseColor9"])
        -- needNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end
    icon:setScale(55 / icon:getContentSize().width)
    icon:setPositionX(5)
    
    local toolD = tab:Tool(itemId)
    local color = 1
    if toolD then
        color = toolD.color or 1
    end
    needNumLab:setString(ItemUtils.formatItemCount(hadNum or 0) .. "/" .. needNum)
end

function SpellBookUpDialog:detectEnough(  )
	local isEnough = false
	local canUp = false
	local data = self._bookD
	local spbInfo = self._modelMgr:getModel("SpellBooksModel"):getData()
	local spellInfo = spbInfo[tostring(self._spellId)]
	local level = spellInfo and spellInfo.l or 0
	local maxLevel = #data.skillbook_exp
	local needNum = data.skillbook_exp[math.min(maxLevel,level+1)] or 0
	local itemId = data.goodsId 
	local _,haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
	local canUpLvl = table.nums(self._bookD.quality) - 1
	if haveNum >= needNum then
		isEnough = true
	end
	if level < canUpLvl  then
		canUp = true
	end

	return isEnough,canUp
end

function SpellBookUpDialog:sendUpMsg( spellId )
	local preScore = self._modelMgr:getModel("SpellBooksModel"):caculateFightNum()
	self._serverMgr:sendMsg("HeroServer","upLevelSpellBook",{sid = spellId}, true, {}, function(result, success)
    	local heroData = result.d and result.d.heros
        if self._heroData and heroData then
            self._modelMgr:getModel("HeroModel"):mergeHeroData(self._heroData, heroData[tostring(self._heroData.id)] or {})
        end
        if self.playAnim then
	        self:playAnim()
	        self._modelMgr:getModel("SpellBooksModel"):checkNotice()
	        local curScore = self._modelMgr:getModel("SpellBooksModel"):caculateFightNum()
			local addScore = curScore - preScore
	        if addScore > 0 then
				TeamUtils:setFightAnim(self:getUI("bg"),{x=100,y=360,oldFight = 0,newFight=addScore,})
			end
		end
    end)
end

function SpellBookUpDialog:sendActiveMsg( spellId )
	local preScore = self._modelMgr:getModel("SpellBooksModel"):caculateFightNum()
	self._serverMgr:sendMsg("HeroServer","combineSpellBook",{sid = spellId}, true, {}, function(result, success)
    	self._viewMgr:showDialog("spellbook.HeroSpellBookResultView",{
    		des = self._skillDes,
    		skillId = tonumber(self._spellId),
    		attName = self._attName ,
    		attNum = self._attNum,
    		releaseNum = self._releaseNum,
    		callback = function( )
		    	if self.playAnim then
			        self:playAnim()
			        self._modelMgr:getModel("SpellBooksModel"):checkNotice()
			        local curScore = self._modelMgr:getModel("SpellBooksModel"):caculateFightNum()
					local addScore = curScore - preScore
			        if addScore > 0 then
						TeamUtils:setFightAnim(self:getUI("bg"),{x=100,y=360,oldFight = 0,newFight=addScore,})
					end
				end
    		end
    		})
    end)
end

function SpellBookUpDialog:playAnim( callback )
	self._mcShua1:gotoAndPlay(0)
	self._mcShua1:setVisible(true)
	self._mcShua1:addCallbackAtFrame(10,function( )
		self._mcShua1:gotoAndStop(0)
		self._mcShua1:setVisible(false)
	end)
	-- self._mcShua2:runAction(cc.Sequence:create(
	-- 	cc.DelayTime:create(0.2),
		-- cc.CallFunc:create(function( )
			self._mcShua2:gotoAndPlay(0)
			self._mcShua2:setVisible(true)
			self._mcShua2:addCallbackAtFrame(10,function( )
				self._mcShua2:gotoAndStop(0)
				self._mcShua2:setVisible(false)
				if callback then
					callback()
				end
			end)
		-- end)
	-- ))
end

return SpellBookUpDialog