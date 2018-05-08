--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-07-11 10:21:26
--
local maxDisStage = table.nums(tab.devDisTreasure) + 1
local TreasureUpStarSuccessView = class("TreasureUpStarSuccessView",BasePopView)
function TreasureUpStarSuccessView:ctor()
    self.super.ctor(self)
    self._tModel = self._modelMgr:getModel("TreasureModel")

end

function TreasureUpStarSuccessView:getMaskOpacity()
    return 230
end

-- 初始化UI后会调用, 有需要请覆盖
function TreasureUpStarSuccessView:onInit()
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
function TreasureUpStarSuccessView:initBasicInfo(id,stage,starNum )
	local preAtts = {}
	local afterAtts = {}

	preAtts,afterAtts = self._modelMgr:getModel("TreasureModel"):caculateStarPreAftAttrs(id,starNum+1,true)
	local disTreasure = tab:DisTreasure(id)
	local icon = IconUtils:createItemIconById({itemId = id, showStar = true, starNum = starNum,eventStyle = 0})
	local iconName = ccui.Text:create()
	iconName:setName("name")
	iconName:setAnchorPoint(cc.p(0.5,0.5))
	iconName:setFontSize(22)
	iconName:setFontName(UIUtils.ttfName)
	iconName:setPosition(cc.p(self._old:getContentSize().width/2,-15))
	iconName:setString(lang(tab:DisTreasure(id).name))
	iconName:setColor(UIUtils.colorTable["ccColorQuality".. (tab:DisTreasure(id).quality or 2)])
	iconName:enableOutline(cc.c4b(54,0,4,255),1.5)
	icon:addChild(iconName,99)

	self._old:addChild(icon)
	local icon2 = IconUtils:createItemIconById({itemId = id, showStar = true, starNum = starNum+1,eventStyle = 0})
	local iconName2 = ccui.Text:create()
	iconName2:setName("name")
	iconName2:setAnchorPoint(cc.p(0.5,0.5))
	iconName2:setFontSize(22)
	iconName2:setFontName(UIUtils.ttfName)
	iconName2:setPosition(cc.p(self._old:getContentSize().width/2,-15))
	iconName2:setString(lang(tab:DisTreasure(id).name) )
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
	local preStarBuff = preAtts and preAtts.att or 0
	local curStarBuff = afterAtts and afterAtts.att or 0
	if self._tModel:isLastDisInCom(id) then
		self._treasureOldFight = self._modelMgr:getModel("TreasureModel"):getCorrectDisScore(id)
		self._treasureOldFight = self._treasureOldFight*((100+preAtts.att)/(100+afterAtts.att))
	else
		self._treasureOldFight = self._modelMgr:getModel("TreasureModel"):getCorrectDisScore(id,true)
	end
	self._treasureNewFight = self._modelMgr:getModel("TreasureModel"):getCorrectDisScore(id)
	--]]

	self._fightOld:setString("a" .. math.ceil(string.format("%.2f",self._treasureOldFight)))
	self._fightNew:setString(math.ceil(string.format("%.2f",self._treasureNewFight)))


	
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

	-- -- 属性
	-- local attsConfig = {
	-- 	[1] = {name = "宝物属性",icon = "",preAtt = preAtts.att,afterAtt = afterAtts.att},
	-- 	[2] = {name = "升星成长",icon = "",preAtt = preAtts.attAdd,afterAtt = afterAtts.attAdd},
	-- }
	-- 重新设置属性
	-- local preAtts = self._tModel:getTreasureAtts(id, math.max(stage,1),true)
	-- local afterAtts = self._tModel:getTreasureAtts(id, math.min(stage+1,maxDisStage),true)
	local baseAtts = self._tModel:getTreasureAtts(id, math.max(stage,1))
	local preAtts = {}
	local afterAtts = {}
	local addStarBuff = function( table,starBuff )
		for k,v in pairs(table) do
			v.attNum = tonumber(v.attNum)*(100+starBuff)/100
		end
		dump(table,"table..." .. starBuff)
		return table
	end
	preAtts = addStarBuff(clone(baseAtts),preStarBuff)
	afterAtts = addStarBuff(baseAtts,curStarBuff)
	-- if true then return end
	for k, v in pairs(preAtts) do
	-- for i=1,2 do
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
		att2:setFontName(UIUtils.ttfName)
		att2:setColor(UIUtils.colorTable.ccUIBaseColor2)

		local name = lang("ARTIFACTDES_PRO_" .. v.attId)
        if not name then
            name = lang("ATTR_" .. v.attId)
        end
        if name then
            name = string.gsub(name, "　", "")
            name = string.gsub(name, " ", "")
        end
        attName:setString(name)
        local tail = " "
        if tonumber(v.attId) == 2 or tonumber(v.attId) == 5 or tonumber(v.attId) == 131 then
            tail = "% "
        end
        
        local leftAttStr = v.attNum == math.floor(v.attNum) and tostring(v.attNum) or string.format("%.1f", v.attNum)
        att1:setString( leftAttStr .. tail)
        att2:setString(name )
        -- if stage < maxDisStage then
            local rightAttStr = afterAtts[k]["attNum"] == math.floor(afterAtts[k]["attNum"]) and tostring(afterAtts[k]["attNum"]) or string.format("%.1f", afterAtts[k]["attNum"])
            -- local addValue = rightAttStr-leftAttStr
            -- if addValue == 0 then
            --     att2:setString("")
            -- else
                att2:setString("" .. (rightAttStr) .. tail .. "")
            -- end
        -- else
        --     -- att2:setString("已满阶")
        --     att2:setString("已满阶")
        --     -- att2:setColor(cc.c3b(255, 255, 255))
        --     -- att2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        -- end
        -- att2:setPositionX(att2:getPositionX() + att2:getContentSize().width)
        idx = idx + 1
	end	

end
-- 接收自定义消息
function TreasureUpStarSuccessView:reflashUI(data)
    self:initBasicInfo(data.id,data.stage,data.starNum-1)
    self.fightCallBack = data.callBack
	
	--- title 播完动画,拉伸卷轴	
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


function TreasureUpStarSuccessView:animBegin(callback)
	audioMgr:playSound("adTitle")

    local bgW,bgH = self._bg3:getContentSize().width,self._bg3:getContentSize().height
    self._bgW,self._bgH = bgW,bgH
    self:addPopViewTitleAnim(self._bg,"shengxingchenggong_huodetitleanim",284,340)  

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

function TreasureUpStarSuccessView:doClear()
	if self._callback then
		self._callback()
	elseif self.fightCallBack then
	    self.fightCallBack(math.floor(self._treasureOldFight), math.floor(self._treasureNewFight))
	end
	self:close(true)
	UIUtils:reloadLuaFile("treasure.TreasureUpStarSuccessView")
end
return TreasureUpStarSuccessView