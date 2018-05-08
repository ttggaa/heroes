--[[
    Filename:    TreasureUpStageSuccessView.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2016-03-07 17:36:31
    Description: File description
--]]
local TreasureUpStageSuccessView = class("TreasureUpStageSuccessView",BasePopView)
function TreasureUpStageSuccessView:ctor()
    self.super.ctor(self)
end

function TreasureUpStageSuccessView:getMaskOpacity()
    return 230
end

-- 初始化UI后会调用, 有需要请覆盖
function TreasureUpStageSuccessView:onInit()
	-- self._title = self:getUI("bg.titleImg")
	self._attPanel = self:getUI("bg.attPanel")
	self._attPanel:setVisible(false)
	self._bigArrow = self:getUI("bg.bigArrow")
	self._bigArrow:setVisible(false)
	self._old = self:getUI("bg.old")
	self._old:setVisible(false)
	self._closeTip = self:getUI("bg.closeTip")
	self._closeTip:setOpacity(0)

	self._new = self:getUI("bg.new")
	self._new:setVisible(false)
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

end
local volumeChange = {25,16,9,4,1}
function TreasureUpStageSuccessView:initBasicInfo(id,stage )
	local preAtts = {}
	local afterAtts = {}
	
	local disTreasure = tab:DisTreasure(id)
	local icon = IconUtils:createItemIconById({itemId = id,eventStyle = 0})
	local iconName = ccui.Text:create()
	iconName:setName("name")
	iconName:setAnchorPoint(cc.p(0.5,0.5))
	iconName:setFontSize(22)
	iconName:setFontName(UIUtils.ttfName)
	iconName:setPosition(cc.p(self._old:getContentSize().width/2,-15))
	iconName:setString(lang(tab:DisTreasure(id).name).. "+" .. (stage))
	iconName:setColor(UIUtils.colorTable["ccColorQuality".. (tab:DisTreasure(id).quality or 2)])
	iconName:enableOutline(cc.c4b(54,0,4,255),1.5)
	icon:addChild(iconName,99)

	self._old:addChild(icon)
	local icon2 = IconUtils:createItemIconById({itemId = id,eventStyle = 0})
	local iconName2 = ccui.Text:create()
	iconName2:setName("name")
	iconName2:setAnchorPoint(cc.p(0.5,0.5))
	iconName2:setFontSize(22)
	iconName2:setFontName(UIUtils.ttfName)
	iconName2:setPosition(cc.p(self._old:getContentSize().width/2,-15))
	iconName2:setString(lang(tab:DisTreasure(id).name) .. "+" .. (stage+1))
	iconName2:setColor(UIUtils.colorTable["ccColorQuality".. (tab:DisTreasure(id).quality or 2)])
	iconName2:enableOutline(cc.c4b(54,0,4,255),1.5)
	icon2:addChild(iconName2,99)
	self._new:addChild(icon2)
	----战斗力 散件*英雄基础
	local treasureTableData = tab:DisTreasure(id)
	local userData = self._modelMgr:getModel("UserModel"):getData()
	local level = userData.lvl or userData.level
	local heroPower = tab:HeroPower(tonumber(level))
	-- print("===========stage==",stage)
	-- print("=====treasureTableData.fightNum[1]======",treasureTableData.fightNum[1])
	-- print("=====treasureTableData.fightNum[2]======",treasureTableData.fightNum[2])
	-- print("==========heroPower.base=================",heroPower.base)
	self._treasureOldFight = (tonumber(treasureTableData.fightNum[1]) + (stage-1)*tonumber(treasureTableData.fightNum[2]))*(tonumber(heroPower.baowu))
	self._treasureNewFight = (tonumber(treasureTableData.fightNum[1]) + (stage)*tonumber(treasureTableData.fightNum[2]))*(tonumber(heroPower.baowu))
	-- self._fightOld:setString("a" .. math.ceil(treasureOldFight))
	-- self._fightNew:setString(math.ceil(treasureNewFight))

	-- [[ 重新计算宝物战斗力
	local caculateFightNum = function( stage )
		local base  	 = tonumber(treasureTableData.fightNum[1] or 0)
		local stageBase = (stage-1)*tonumber(treasureTableData.fightNum[2] or 0)
		local baowuBase  = tonumber(heroPower.baowu)

		local exScore = 0 
		local exBase  = treasureTableData.fightNum[3] or 0
		local attradd = treasureTableData.unlockaddattr
		for i,v in ipairs(attradd) do
			if stage >= v then
				exScore = exScore + exBase*baowuBase
			end
		end
		return (base+stageBase)*baowuBase+exScore
	end

	self._treasureOldFight = self._modelMgr:getModel("TreasureModel"):caculateDisTreasureScore(id,nil,stage) -- caculateFightNum(stage)
	self._treasureNewFight = self._modelMgr:getModel("TreasureModel"):caculateDisTreasureScore(id,nil,stage+1) -- caculateFightNum(stage+1)
	--]]

	self._fightOld:setString("a" .. math.ceil(string.format("%.2f",self._treasureOldFight)))
	self._fightNew:setString(math.ceil(string.format("%.2f",self._treasureNewFight)))


	preAtts = self._modelMgr:getModel("TreasureModel"):getTreasureAtts(id,stage,true)
	afterAtts = self._modelMgr:getModel("TreasureModel"):getTreasureAtts(id,stage+1,true)
	

	local panelW, panelH = self._attPanel:getContentSize().width,self._attPanel:getContentSize().height+5
	self._panelH = panelH
	local x,y = panelW/2,self._new:getPositionY()-32	
	-- local offsetx,offsety = 0,-35
	self._fightPanel:setPositionY(y - self._fightPanel:getContentSize().height)
	y = y  - self._fightPanel:getContentSize().height
	local idx = 0
	self._panels = {}
	self._old:setVisible(false)
	self._bigArrow:setVisible(false)
	self._new:setVisible(false)
	table.insert(self._panels,self._old)
	table.insert(self._panels,self._bigArrow)
	table.insert(self._panels,self._new)
	table.insert(self._panels,self._fightPanel)
	self._old:setOpacity(0)
	self._old:setCascadeOpacityEnabled(true)
	self._bigArrow:setOpacity(0)
	self._bigArrow:setCascadeOpacityEnabled(true)
	self._new:setOpacity(0)
	self._new:setCascadeOpacityEnabled(true)
	self._fightPanel:setOpacity(0)
	self._fightPanel:setCascadeOpacityEnabled(true)

	for k,v in pairs(preAtts) do
		idx = idx+1
		local attPanel = self._attPanel:clone()
		-- attPanel:setAnchorPoint(cc.p(0.5,0))
		-- attPanel:setVisible(true)
		-- if idx%2 == 0 then
		attPanel:setOpacity(0)
		-- end
		print("=========================yyyy",y)		
		y = y  - panelH
		attPanel:setPositionY(y)
		self._bg:addChild(attPanel,99)
		attPanel:setOpacity(0)
		attPanel:setCascadeOpacityEnabled(true)
		table.insert(self._panels,attPanel)

		local attName = attPanel:getChildByFullName("attName")
		local att1 = attPanel:getChildByFullName("att1")
		att1:setFontName(UIUtils.ttfName)
		local att2 = attPanel:getChildByFullName("att2")
		att2:setColor(UIUtils.colorTable.ccUIBaseColor2)
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
		att2:setColor(UIUtils.colorTable.ccUIBaseColor2)
	end
	-- for i,v in ipairs(self._panels) do
	-- 	v:setPosition(panelW, y+offsety-idx*panelH)
	-- end

	-- 加额外属性展示
	local disData = tab.disTreasure[tonumber(id)]
    local unlockData = disData.unlockaddattr
    local addAttrsData = disData.addattr
    
	local unlockIdx = 0
	for i,v in ipairs(unlockData) do
        if unlockData[i] == stage+1 then
            unlockIdx = i
        end 
    end
    if unlockIdx > 0 then
        local item = ccui.Layout:create()
        item:setBackGroundColorOpacity(255)
        item:setBackGroundColorType(1)
        item:setBackGroundColor(cc.c4b(145, 105, 50, 128))
		item:setCascadeOpacityEnabled(true)
        item:setOpacity(0) -- 255*(i%2))
        item:setContentSize(360, 32)
        item:setAnchorPoint(0,0)
        y = y  - panelH
        item:setPosition(x-115,y)
        table.insert(self._panels,item)
	
        self._bg:addChild(item)

        local stageUpImg = ccui.ImageView:create()
        stageUpImg:loadTexture("txt_upskill_treasure.png",1)
        stageUpImg:setPosition(260,-6)
        -- stageUpImg:setScale(0.8)
        stageUpImg:setAnchorPoint(0,0)
        stageUpImg:setName("upStage")
        item:addChild(stageUpImg)
        -- item:reorderChild(item,10)

        local addAttrData = addAttrsData[unlockIdx]
        local volume = addAttrData[1]
        volume = volumeChange[volume]
        local attr = addAttrData[2]
        local addValue = addAttrData[3]

        local des = "[color=27f73a,outlinecolor=3c1e0aff,outlinesize=1]" .. volume .. "单位兵团" .. lang("ATTR_" .. attr) .. "[color=27f73a,outlinecolor=3c1e0aff,outlinesize=1]+" .. addValue .. "[-][-]"

        if item:getChildByName("rtx") then
            item:getChildByName("rtx"):removeFromParent()
        end

        local rtx = RichTextFactory:create(des or "",item:getContentSize().width,item:getContentSize().height)
        rtx:formatText()
        rtx:setCascadeOpacityEnabled(true)
        local w = rtx:getInnerSize().width
        local h = rtx:getInnerSize().height
        rtx:setPosition(cc.p(w/2,item:getContentSize().height/2))
        UIUtils:alignRichText(rtx,{vAlign = "center",hAlign = "left"})
        rtx:setName("rtx")
        rtx:setVisible(false)
        item:addChild(rtx)
        local teams = self._modelMgr:getModel("TeamModel"):getData()
		-- dump(teams)
		local count = 0
		for k,v in pairs(teams) do
			if tonumber(v.volume) == volume then
				count = count+1
			end
		end
        if count > 0 then
	        self._callback = function( )
				local fightCallBack = self.fightCallBack
				local oldFight = math.floor(self._treasureOldFight)
				local newFight = math.floor(self._treasureNewFight)
		        self._viewMgr:showDialog("treasure.TreasureUpTeamView",{volume=volume,buffId=attr,buffValue=addValue,callback = function( )
		        	fightCallBack(oldFight,newFight)
		        end})
	        end
	    end
    end
	
end
-- 接收自定义消息
function TreasureUpStageSuccessView:reflashUI(data)
    self:initBasicInfo(data.id,data.stage-1)
    self.fightCallBack = data.callBack

	--- title 播完动画，拉伸卷轴	
    local maxHeight = 170+(#self._panels-3)*35+30     
	self._closeTip:setPositionY(self._bg3:getPositionY() - maxHeight -20)
    local step = 0.5
    local stepConst = 80
    self.bgWidth,self.bgHeight = self._bg3:getContentSize().width,10
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
	            local mcMgr = MovieClipManager:getInstance()
	        end
	    end)
    end)
 
end


function TreasureUpStageSuccessView:animBegin(callback)
	audioMgr:playSound("adTitle")

    local bgW,bgH = self._bg3:getContentSize().width,self._bg3:getContentSize().height
    self._bgW,self._bgH = bgW,bgH
    self:addPopViewTitleAnim(self._bg,"jinjiechenggong_huodetitleanim",284,340)  

    --显示条件的刷光动画
    
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
	            if i == 1 or i == 3 then
	            	audioMgr:playSound("adIcon")
	            end
	            if i > 3 then
	            	audioMgr:playSound("adTag")
			        -- des:setPositionY((#self._panels-3)*35+20 - (i-3.5)*self._panelH)
		            local mcShua = mcMgr:createViewMC("shuxingshuguang_itemeffectcollection", true, false, function (_, sender)
		                sender:removeFromParent()
		            end,RGBA8888)
		            mcShua:setPosition(cc.p(self._bg:getContentSize().width/2-120,des:getPositionY()+self._panelH/2-4))
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

function TreasureUpStageSuccessView:doClear()
	if self._callback then
		self._callback()
	else
	    self.fightCallBack(math.floor(self._treasureOldFight), math.floor(self._treasureNewFight))
	end
	self:close(true)
	UIUtils:reloadLuaFile("treasure.TreasureUpStageSuccessView")
end
return TreasureUpStageSuccessView