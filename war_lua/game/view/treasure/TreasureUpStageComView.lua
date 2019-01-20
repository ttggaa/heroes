--
-- Author: huangguofang
-- Date: 2016-07-26 22:14:57
--
local maxComStage = table.nums(tab.devComTreasure) + 1
local GlobalTipView = require("game.view.global.GlobalTipView")
local TreasureUpStageComView = class("TreasureUpStageComView",BasePopView)
function TreasureUpStageComView:ctor()
    self.super.ctor(self)
end

function TreasureUpStageComView:getMaskOpacity()
    return 230
end

-- 初始化UI后会调用, 有需要请覆盖
function TreasureUpStageComView:onInit()
	self._attPanel = self:getUI("bg.attPanel")
	self._attPanel:setVisible(false)
	self._bigArrow = self:getUI("bg.bigArrow")
	self._old = self:getUI("bg.old")
	self._closeTip = self:getUI("bg.closeTip")
	self._closeTip:setOpacity(0)
	self._new = self:getUI("bg.new")
	self._bg = self:getUI("bg")
	self._bg3 = self:getUI("bg.bg3")

	self._fightPanel = self:getUI("bg.fightPanel")
	self._fightPanel:setVisible(false)
	self._fightOld = self._fightPanel:getChildByFullName("fightTxtOld")
	self._fightOld:setFntFile(UIUtils.bmfName_zhandouli)
	self._fightOld:setScale(0.5)
	self._fightNew = self._fightPanel:getChildByFullName("fightTxtNew")
	self._fightNew:setFntFile(UIUtils.bmfName_zhandouli)
	self._fightNew:setScale(0.5)

	self._skillBg = self:getUI("bg.skillBg")
	self._skillBg:setVisible(false)

	self._treasureData = {}

end
function TreasureUpStageComView:initBasicInfo(id,stage )
	local preAtts = {}
	local afterAtts = {}
	local tableTreasureData = tab:ComTreasure(id)
	self._curComData = tableTreasureData
	self._curComInfo = self._modelMgr:getModel("TreasureModel"):getTreasureById(id)
	local icon = ccui.ImageView:create()--IconUtils:createTreasureIcon({id = self._curComData.id})
	icon:loadTexture(IconUtils.iconPath .. tableTreasureData.art ..".png", 1)
	icon:setAnchorPoint(cc.p(0.5,0.5))	
	-- icon:setScale(250/icon:getContentSize().width)
	self._new:addChild(icon)

	local treasureName = self:getUI("bg.new.treasureName")
	treasureName:setFontName(UIUtils.ttfName)
	treasureName:setString(lang(tab:ComTreasure(id).name) .. "+" .. (stage+1))
	treasureName:setColor(UIUtils.colorTable["ccUIBaseColor".. (tab:ComTreasure(id).quality or 2)])
	treasureName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	--计算组合宝物战斗力
	-- self:calculateFight(id,stage)
	-- 数据与后端保持一致
    self._oldFightValue = (self._treasureData.disScore or 0) +(self._treasureData.comScore or 0)
	self._fightOld:setString("a" ..self._oldFightValue)

	local newTreasureData =  self._modelMgr:getModel("TreasureModel"):getComTreasureById(tostring(id))
    self._newFightValue = (newTreasureData.disScore or 0) +(newTreasureData.comScore or 0)
	self._fightNew:setString(self._newFightValue)

	--初始化宝物技能
	self:initSkillPanel(id,stage)

	preAtts = self._modelMgr:getModel("TreasureModel"):getTreasureAtts(id,stage)
	afterAtts = self._modelMgr:getModel("TreasureModel"):getTreasureAtts(id,stage+1)
	
	local panelW, panelH = self._attPanel:getContentSize().width,self._attPanel:getContentSize().height+5
	self._panelH = panelH
	local x,y = panelW/2+60,self._fightPanel:getPositionY()	
	local idx = 0
	self._panels = {}
	self._new:setVisible(false)
	-- action 1
	table.insert(self._panels,self._new)
	-- action 2
	table.insert(self._panels,self._skillBg)
	-- action 3
	self._fightPanel._isNeedMc = true
	table.insert(self._panels,self._fightPanel)

	for k,v in pairs(preAtts) do
		idx = idx+1
		local attPanel = self._attPanel:clone()
		attPanel:setAnchorPoint(cc.p(0.5,0))
		-- attPanel:setVisible(true)
		-- if idx%2 == 0 then
		attPanel:setOpacity(0)
		-- end
		-- print("=========================yyyy",y)		
		y = y  - panelH
		attPanel:setPosition(x,y)
		self._bg:addChild(attPanel,99)
		-- action 4
		attPanel._isNeedMc = true
		table.insert(self._panels,attPanel)

		local attName = attPanel:getChildByFullName("attName")
		local att1 = attPanel:getChildByFullName("att1")
		att1:setFontName(UIUtils.ttfName)
		local att2 = attPanel:getChildByFullName("att2")
		att2:setFontName(UIUtils.ttfName)

		local name = lang("ARTIFACTDES_PRO_" .. v.attId)
		if not name then 
			name = lang("ATTR_" .. v.attId)
		end
		if name then
			name = string.gsub(name,"　","")
			name = string.gsub(name," ","") .. "+"
		end
		local tail = ""
		if tonumber(v.attId) == 2 or tonumber(v.attId) == 5 or tonumber(v.attId) == 131 then
			tail = "%"
		end
		local attrImg = attPanel:getChildByFullName("attrImg")
		attrImg:loadTexture(IconUtils.attLittleIcon[tonumber(v.attId)],1)
		attrImg:setAnchorPoint(cc.p(0.5,0.5))
		attName:setString(name)
		-- attrImg:setPositionX(attName:getPositionX() - attrImg:getContentSize().width/2 - 3)
		att1:setString(v.attNum .. tail)
		att1:setPositionX(attName:getPositionX() + attName:getContentSize().width + 10)
		att2:setString(afterAtts[k]["attNum"] .. tail)
	end

	-- action 5
	local skillDes = self:getUI("bg.skillDes")
	skillDes:setVisible(false)
	table.insert(self._panels,skillDes)

    -- [[
    local des = ""
	local formationModel = self._modelMgr:getModel("FormationModel")
	local defaultHeroData = formationModel:getFormationDataByType(formationModel.kFormationTypeCommon)
	local heroData = clone(self._modelMgr:getModel("HeroModel"):getData()[tostring(defaultHeroData.heroId)])
	heroData.id = defaultHeroData.heroId
    local attributes = BattleUtils.getHeroAttributes(heroData)
	attributes.sklevel = (stage or 1) + 1
	attributes.artifactlv = 1
	local skillType = tab:ComTreasure(id).addattr[1][1]
	local skillId = tab:ComTreasure(id).addattr[1][2]
	skillId = tonumber(skillId) or skillId
	print(id,"id....",skillId)
	local formationSkillType = BattleUtils.kIconTypeSkill
	if skillType == 2 then
		formationSkillType = BattleUtils.kIconTypeHeroSpecialty
	end
	-- des = BattleUtils.getDescription(formationSkillType, skillId, attributes, 1)
	des = "[color=fae0bc, fontsize=20]" .. self:generateDes(math.min(stage+1,maxComStage)).."[-]" -- "[color=fae0bc, fontsize=20]" .. BattleUtils.getDescription(formationSkillType, skillId, attributes, 1) .. "[-]"
	-- print("skilldes ...... ....",des)
	local skillDesRich = RichTextFactory:create(des,skillDes:getContentSize().width,skillDes:getContentSize().height)
    skillDesRich:formatText()
    skillDesRich:setAnchorPoint(cc.p(0,0.5))
    -- local h = skillDesRich:getInnerSize().height
    -- local posX = self._title:getPositionX() - 260
    -- local posY = self._rewardPanel:getPositionY()+self._rewardPanel:getContentSize().height + 20
    skillDesRich:setPosition(-skillDes:getContentSize().width/2,skillDes:getContentSize().height/2)
    -- UIUtils:alignRichText(rtx)
    skillDes:addChild(skillDesRich,10) 
	skillDes:setString("")
	--]]
	y = y - 50
	skillDes:setPositionY(y)
	y = y - (46 -skillDesRich:getRealSize().height )
	y = y - skillDesRich:getRealSize().height
	-- for i,v in ipairs(self._panels) do
	-- 	v:setPosition(panelW, y+offsety-idx*panelH)
	-- end
	local disData = tab.comTreasure[id]
    local unlockData = disData.unlockaddattr
    local addAttrsData = disData.addattr
    -- dump(unlockData)
    local unlockIdx = 0
	for i,v in ipairs(unlockData) do
        if unlockData[i] == stage+1 then
            unlockIdx = i
        end 
    end
    if unlockIdx > 0 then
    -- 创建额外加成显示
	    y = y  - panelH
        local item = ccui.Layout:create()
        item:setBackGroundColorOpacity(255)
        item:setBackGroundColorType(1)
        item:setBackGroundColor(cc.c4b(108, 73, 5, 128))
        item:setCascadeOpacityEnabled(true)
        item:setOpacity(0)
        item:setContentSize(400, 32)
        item:setAnchorPoint(0,0)
        item:setPosition(x-50,y)
        -- action 5
        item._isNeedMc = true
        table.insert(self._panels,item)
        self._bg:addChild(item)

        local stageUpImg = ccui.ImageView:create()
        stageUpImg:loadTexture("txt_upskill_treasure.png",1)
        stageUpImg:setPosition(400,16)
        stageUpImg:setAnchorPoint(0.5,0.5)
        stageUpImg:setName("upStage")
        stageUpImg:setScale(0.8)
        item:addChild(stageUpImg)
        self._bg:reorderChild(item,10)

        local attr = addAttrsData[unlockIdx][1]
        local addValue = addAttrsData[unlockIdx][2]

        -- dump(addAttrsData)
        
        local des = lang("HEROMASTERYDES_" .. addValue)
        if des == "" then
            des = lang("PLAYERSKILLDES2_" .. addValue)
        end
        

        -- if stage < unlockData[i] then
        --     des = "[color=646464,fontsize=18]" .. " " .. " " .. des .. "[-]"
        -- elseif stage <= unlockData[i]  then
            des = "[color=fae6c8,fontsize=18]" .. " " .. " " .. des .. "[-]"
        -- else
        --     des = "[color=825528,fontsize=18]" .. " " .. "[color=462800] " .. des .. "[-][-]"
        -- end
		print("des....===========",unlockIdx,addValue,"PLAYERSKILLDES2_" .. addValue,des)
        if item:getChildByName("rtx") then
            item:getChildByName("rtx"):removeFromParent()
        end

        local rtx = RichTextFactory:create(des or "",350,item:getContentSize().height)
        rtx:formatText()
        -- rtx:setVerticalSpace(5)
        -- rtx:setAnchorPoint(cc.p(0,0))
        local w = rtx:getInnerSize().width
        local h = rtx:getInnerSize().height
        if h > 32 then
        	item:setContentSize(400,h)
        end
        local realW = rtx:getRealSize().width
        stageUpImg:setPosition(math.max(realW+30,330),math.max(16,h/2))
        rtx:setPosition(cc.p(w/2,item:getContentSize().height/2))
        rtx:setCascadeOpacityEnabled(true)
        UIUtils:alignRichText(rtx,{vAlign = "center",hAlign = "left"})
        rtx:setName("rtx")
        rtx:setVisible(false)
        item:addChild(rtx)
    end
end

-- 计算阶数的des
function TreasureUpStageComView:generateDes( stage )
    local skillDes
    local skillId = self._curComData.addattr[1][2]
    local skillD = { }
    for k, v in pairs(self._skillTabMap) do
        if v[skillId] and(v[skillId].art or v[skillId].icon) then
            skillD = clone(v[skillId])
            break
        end
    end
    local tipDataD = GlobalTipView["getDataDForTipType2"](GlobalTipView,
    { tipType = 2, node = desBg, id = skillD.id,comId = self._curComData.id, skillType = self._curComData.addattr[1][1], skillLevel = math.min(stage, maxComStage) })
    skillDes = GlobalTipView._des
    skillDes = string.gsub(skillDes, "fontsize=16", "fontsize=20")
    skillDes = string.gsub(skillDes, "fontsize=17", "fontsize=20")
    skillDes = string.gsub(skillDes, "fontsize=18", "fontsize=20")
    skillDes = string.gsub(skillDes, "fontsize=24", "fontsize=20")
    skillDes = string.gsub(skillDes, "color=3d1f00", "color=fae0bc")
    skillDes = string.gsub(skillDes, "outlinecolor=3c1e0a00", "")
    skillDes = string.gsub(skillDes, "outlinecolor=3c1e0aff", "")

    GlobalTipView._des = nil
    return skillDes
end
--计算组合宝物战斗力
function TreasureUpStageComView:calculateFight(id,stage)
	--战斗力 [(散件1*level)+ (散件2*level)+... +(组合宝物*level)]*英雄基础(level)\
	local tableTreasureData = tab:ComTreasure(id)
	--散件ID
	local disaIdData = tableTreasureData.form

	local treasureData = self._modelMgr:getModel("TreasureModel"):getComTreasureById(tostring(id)) or {}

	-- dump(treasureData,"treasureData===>")
	local oldComFight = tonumber(tableTreasureData.fightNum[1])+(stage - 1) * tonumber(tableTreasureData.fightNum[2])
	local newComFight = tonumber(tableTreasureData.fightNum[1])+stage * tonumber(tableTreasureData.fightNum[2])
	-- print("==========oldComFight=,newComFight===============",oldComFight,newComFight)
	for k,v in pairs(disaIdData) do		
		local disTreasureData = tab:DisTreasure(tonumber(v))
		local disStage = 1
		-- local newDisStage = 2
		for kk,vv in pairs(treasureData) do
			if treasureData.treasureDev and treasureData.treasureDev[tostring(v)] then				
				disStage = treasureData.treasureDev[tostring(v)].s
				break
			end
		end
		oldComFight = oldComFight + tonumber(disTreasureData.fightNum[1]) + (disStage - 1) * tonumber(disTreasureData.fightNum[2])
		newComFight = newComFight + tonumber(disTreasureData.fightNum[1]) + (disStage - 1) * tonumber(disTreasureData.fightNum[2])
		-- print("=====oldComFight,newComFight=======",oldComFight,newComFight,disStage)
	end
	-- print("=======oldComFight,newComFight=============",oldComFight,newComFight)
	local userData = self._modelMgr:getModel("UserModel"):getData()
	local level = userData.lvl or userData.level
	local heroPower = tab:HeroPower(tonumber(level))
	oldComFight = oldComFight * (tonumber(heroPower.baowu))
	newComFight = newComFight * (tonumber(heroPower.baowu))
	print("string.format(%.2f,oldComFight) === ",string.format("%.2f",oldComFight))
	print("string.format(%.2f,newComFight) === ",string.format("%.2f",newComFight))
	self._fightOld:setString("a" .. math.ceil(string.format("%.2f",oldComFight)))
	self._fightNew:setString(math.ceil(string.format("%.2f",newComFight)))
end
--初始化技能面板
function TreasureUpStageComView:initSkillPanel(id,stage)
	local skillD = {}
	self._skillTabMap = {
		tab.heroMastery,
		tab.playerSkillEffect,
		tab.skillPassive,
		tab.skillCharacter,
		tab.skillAttackEffect,
	    tab.skill,
	    tab.skillBuff,
	    tab.skillObject,
	}
	local skillId = tab:ComTreasure(id).addattr[1][2]
	for k,v in pairs(self._skillTabMap) do
		if v[skillId] then
			skillD = clone(v[skillId])
			break
		end
	end
	-- dump(skillD)

	local art = skillD.art or skillD.icon
	-- print("====================",art)
	local skillImg = self._skillBg:getChildByFullName("skillImg")
	skillImg:loadTexture(IconUtils.iconPath .. art .. ".png", 1) 
	local skillImg_0 = self._skillBg:getChildByFullName("skillImg_0")
	skillImg_0:loadTexture(IconUtils.iconPath .. art .. ".png", 1) 
	-- skillImg:setScale(70/skillImg:getContentSize().width) 

	local skillName = self._skillBg:getChildByFullName("skillName")
	skillName:setString((lang(skillD.name) or ""))
	skillName:setFontSize(24)
	skillName:setColor(UIUtils.colorTable.ccUIBaseColor7)  
	-- skillName:setColor(UIUtils.colorTable["ccColorQuality".. (tab:ComTreasure(data.id).quality or 2)])
	skillName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)	

	local oldLevel = self:getUI("bg.skillBg.levelPanel.oldLevel") --self._skillBg:getChildByFullName("oldLevel")
	oldLevel:setString("Lv. " .. stage)
	local newLevel = self:getUI("bg.skillBg.levelPanel.newLevel")
	newLevel:setString("Lv. " .. (stage + 1))
end

-- 接收自定义消息
function TreasureUpStageComView:reflashUI(data)
	-- dump(data,"---==>>")
	self._treasureData = data.treasureData
    self.fightCallBack = data.callBack

    self:initBasicInfo(data.id,data.stage-1)

    local maxHeight = 390
    local step = 0.5
    local stepConst = 50
    self.bgWidth,self.bgHeight = self._bg3:getContentSize().width,self._bg3:getContentSize().height/2   
   	self._bg3:setContentSize(cc.size(self.bgWidth,self.bgHeight))

   	-- 拉动卷轴
   	self._bg3:setVisible(false)
    self:animBegin(function( )
    	self._bg3:setVisible(true)
	    local sizeSchedule
	    sizeSchedule = ScheduleMgr:regSchedule(1,self,function( )
	        if stepConst < 1 then 
	        	step = 0
	            stepConst = 1
	        else
	        	stepConst = stepConst-step
	        end

	        self.bgHeight = self.bgHeight+stepConst
	        if self.bgHeight < maxHeight then
	            self._bg3:setContentSize(cc.size(self.bgWidth,self.bgHeight))
	        else
	            self._bg3:setContentSize(cc.size(self.bgWidth,maxHeight))
	            ScheduleMgr:unregSchedule(sizeSchedule)
	            self:addDecorateCorner()
	        end                         
	    end)
    end)
end


function TreasureUpStageComView:animBegin(callback)
	audioMgr:playSound("adTitle")
    local bgW,bgH = self._bg3:getContentSize().width,self._bg3:getContentSize().height
    self._bgW,self._bgH = bgW,bgH
    self:addPopViewTitleAnim(self._bg,"jinjiechenggong_huodetitleanim",284,340)   
    ScheduleMgr:delayCall(400, self, function( )
        if callback and self._bg then
            callback()
        end
	    for i=1,#self._panels do
	        local des = self._panels[i]
	        ScheduleMgr:delayCall(i*200, self, function( )
	        	if not des or tolua.isnull(des) then return end
	            des:setVisible(true)
	            local spawn = cc.Spawn:create(cc.JumpBy:create(0.1,cc.p(0,0),10,1),cc.FadeIn:create(0.1))
	            des:runAction(spawn)--cc.Sequence:create(,cc.CallFunc:create(function ( )
	            if des:getChildByName("rtx") then
	            	des:getChildByName("rtx"):setVisible(true)
	            end
	            -- des:runAction(cc.JumpBy:create(0.1,cc.p(0,0),10,1))--cc.Sequence:create(,cc.CallFunc:create(function ( )
	            if i == 1 then
	            	audioMgr:playSound("adIcon")
	            end
	            if des._isNeedMc then --i > 1 and i~= #self._panels-1 and i ~= #self._panels then
	            	audioMgr:playSound("adTag")
			        -- des:setPositionY((#self._panels-3)*35+20 - (i-3.5)*self._panelH)		        
		            local mcShua = mcMgr:createViewMC("shuxingshuguang_itemeffectcollection", true, false, function (_, sender)
		                sender:removeFromParent()
		            end,RGBA8888)
		            mcShua:setPosition(cc.p(self._bg:getContentSize().width/2-20,des:getPositionY()+self._panelH/2-4))
		            -- mcShua:setPlaySpeed(0.2)
		            self._bg:addChild(mcShua,99)
		        end
	        end)
	    end
	    ScheduleMgr:delayCall(800, self, function( )
		    self._closeTip:runAction(cc.FadeIn:create(0.3))
		    self:registerClickEventByName("closePanel",function( )
				self:doClear()
			end)
			self:registerClickEventByName("bg",function( )
				self:doClear()
			end)
	    end)
    end)
end

function TreasureUpStageComView:doClear()
    self.fightCallBack(math.floor(self._oldFightValue), math.floor(self._newFightValue))
	self:close(true)
	UIUtils:reloadLuaFile("treasure.TreasureUpStageComView")
end
return TreasureUpStageComView