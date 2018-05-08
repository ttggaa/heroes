--[[
    Filename:    TreasureActiveView.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2016-04-01 16:45:18
    Description: File description
--]]
local maxComStage = table.nums(tab.devComTreasure) + 1
local GlobalTipView = require("game.view.global.GlobalTipView")
local TreasureActiveView = class("TreasureActiveView",BasePopView)
function TreasureActiveView:ctor(param)
    TreasureActiveView.super.ctor(self)
	param = param or {}
	self._callback = param.callback 

end

function TreasureActiveView:getMaskOpacity()
    return 230
end

-- 初始化UI后会调用, 有需要请覆盖 
function TreasureActiveView:onInit()
	-- self._title = self:getUI("bg.titleImg")
	-- self._attPanel = self:getUI("bg.attPanel")
	-- self._attPanel:setVisible(false)
	self._bigArrow = self:getUI("bg.bigArrow")
	self._old = self:getUI("bg.old")
	self._closeTip = self:getUI("bg.closeTip")
	self._closeTip:setOpacity(0)
	self._new = self:getUI("bg.new")
	self._bg = self:getUI("bg")
	self._bg3 = self:getUI("bg.bg3")
	self._title = self:getUI("bg.title")
	self._title:setScale(3)
	self._title:setCascadeOpacityEnabled(true,true)
	self._title:setOpacity(0)

	--share  by wangyan
	self._shareNode = require("game.view.share.GlobalShareBtnNode").new({mType = "ShareTreasureModule"})
    self._shareNode:setPosition(653, 38)
    self._shareNode:setCascadeOpacityEnabled(true, true)
    self._new:addChild(self._shareNode, 2)
    self._shareNode:setCascadeOpacityEnabled(true,true)
    self._shareNode:setOpacity(0)
end
function TreasureActiveView:initBasicInfo(data )
	self._curComData = tab:ComTreasure(data.id)
	-- local preAtts = {}
	-- local afterAtts = {}
	-- if isCom then
	-- 	for i=1,4 do
	-- 		local property = tab:ComTreasure(data.id)["property" .. i]
	-- 		if not property then break end
	-- 		preAtts[property[1]] = preAtts[property[1]] or {}
	-- 		afterAtts[property[1]] = afterAtts[property[1]] or {}

	-- 		preAtts[property[1]].attId = property[1] 
	-- 		preAtts[property[1]].attNum = property[2]+math.max(stage-1,0)*property[3]
	-- 		afterAtts[property[1]].attId = property[1] 
	-- 		afterAtts[property[1]].attNum = property[2]+math.max(stage,0)*property[3]
	-- 	end
	local icon = ccui.ImageView:create()--IconUtils:createTreasureIcon({id = self._curComData.id})
	icon:loadTexture(IconUtils.iconPath .. tab:ComTreasure(data.id).art ..".png", 1)
	icon:setPosition(cc.p(30,30))
	icon:setScale(200/icon:getContentSize().width)
	local iconName = self._old:getChildByFullName("comDes") --ccui.Text:create()
	iconName:setName("name")
	iconName:setFontSize(18)
	iconName:setString(lang(tab:ComTreasure(data.id).des))
	iconName:setColor(UIUtils.colorTable["ccColorQuality".. (tab:ComTreasure(data.id).quality or 2)])
	iconName:enableOutline(cc.c4b(54,0,4,255),1.5)
	self._old:addChild(icon)
	local name = self._old:getChildByFullName("name")
	dump(data,"data.....".. data.id)
	UIUtils:createTreasureNameLab(data.id,nil,32,self:getUI("bg.treasureName"),true)

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
	local skillId = tab:ComTreasure(data.id).addattr[1][2]
	skillId = tonumber(skillId) or skillId
	for k,v in pairs(self._skillTabMap) do
		if v[skillId] then
			skillD = clone(v[skillId])
			break
		end
	end
	dump(skillD)

	local skillName = self._new:getChildByFullName("skillName")
	skillName:setString("宝物技能:")
	skillName:setFontSize(30)
	skillName:setColor(cc.c4b(252,244,197,255))  
	-- skillName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	-- skillName:enableOutline(cc.c4b(54,0,4,255),2)

	local skillNameTxt = self._new:getChildByFullName("skillNameTxt")
	skillNameTxt:setString((lang(skillD.name) or ""))
	skillNameTxt:setFontSize(30)
	skillNameTxt:setPositionX(skillName:getPositionX()+skillName:getContentSize().width+5)
	skillNameTxt:setColor(cc.c3b(254, 143, 0))  
	-- skillNameTxt:setColor(UIUtils.colorTable["ccColorQuality".. (tab:ComTreasure(data.id).quality or 2)])
	-- skillNameTxt:enableOutline(cc.c4b(54,0,4,255),2)

	---[[
	local des = self:generateDes(1)-- SkillUtils:getTreasureSkillDes(skillId,1)
	print(des)
	local skillDes = self._new:getChildByFullName("skillDes")
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

	local art = skillD.art or skillD.icon
	local skillImg = self:getUI("bg.new.iconNode.skillImg")
	skillImg:loadTexture(IconUtils.iconPath .. art ..".png", 1) 
	skillImg:setScale(70/skillImg:getContentSize().width)

	self._panels = {}
	-- self._old:setVisible(false)
	-- self._bigArrow:setVisible(false)
	-- self._new:setVisible(false)
	table.insert(self._panels,self._old)
	-- table.insert(self._panels,self._bigArrow)
	table.insert(self._panels,self._new)
	-- for k,v in pairs(preAtts) do
	
end

-- 计算阶数的des
function TreasureActiveView:generateDes( stage )
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
    { tipType = 2, node = self._old, id = skillD.id,comId = self._curComData.id, skillType = self._curComData.addattr[1][1], skillLevel = math.min(stage, maxComStage) })
    skillDes = GlobalTipView._des
    print(skillDes,"raw...")
    skillDes = string.gsub(skillDes, "fontsize=16", "fontsize=18")
    skillDes = string.gsub(skillDes, "fontsize=17", "fontsize=18")
    skillDes = string.gsub(skillDes, "fontsize=18", "fontsize=18")
    skillDes = string.gsub(skillDes, "fontsize=24", "fontsize=18")
    skillDes = string.gsub(skillDes, "color=1ca216", "color=00ff60")
    skillDes = string.gsub(skillDes, "color=3d1f00", "color=00ff60")
    skillDes = string.gsub(skillDes, "outlinecolor=3c1e0a00", "")
    skillDes = string.gsub(skillDes, "outlinecolor=3c1e0aff", "")
    skillDes = "[color = a99a88,fontsize=18]" .. skillDes ..  "[-]"
    GlobalTipView._des = nil
    return skillDes
end

-- 接收自定义消息
function TreasureActiveView:reflashUI(data)
    self:initBasicInfo(data)
    self._title:loadTexture("treasureActiveTitle_" .. (tab:ComTreasure(data.id).quality or 2) .. ".png",1)
    self._title:runAction(cc.Sequence:create(
    	cc.Spawn:create(
	    	cc.ScaleTo:create(0.2,0.8),
    		cc.FadeIn:create(0.2)
    	),
    	cc.ScaleTo:create(0.1,1)
    ))
	local maxHeight = 425 -- 170+(#self._panels-3)*35+20
    local step = 0.5
    local stepConst = 60
    -- self.bgWidth,self.bgHeight = self._bg3:getContentSize().width,self._bg3:getContentSize().height/2
    -- self._bg3:setContentSize(cc.size(self.bgWidth,self.bgHeight))
    -- self._bg3:setVisible(false)
    -- self._bg3:setOpacity(0)
    self._bg3:loadTexture("treasureActiveBg_" .. (tab:ComTreasure(data.id).quality or 2) .. ".png",1)
    self:animBegin(function( )
    	-- self._bg3:runAction(cc.FadeIn:create(0.3))
	    -- local sizeSchedule
	    -- sizeSchedule = ScheduleMgr:regSchedule(1,self,function( )
	    --     if stepConst < 1 then 
	    --     	step = 0
	    --         stepConst = 1
	    --     else
	    --     	stepConst = stepConst-step
	    --     end
	    --     self.bgHeight = self.bgHeight+stepConst
	    --     if self.bgHeight < maxHeight then
	    --         self._bg3:setContentSize(cc.size(self.bgWidth,self.bgHeight))
	    --     else
	    --         self._bg3:setContentSize(cc.size(self.bgWidth,maxHeight))
	    --         ScheduleMgr:unregSchedule(sizeSchedule)
	    --         local mcMgr = MovieClipManager:getInstance()
	    --         self:addDecorateCorner()
	    --     end
	    -- end)
    end)


end


function TreasureActiveView:animBegin(callback)
	audioMgr:playSound("adTitle")
    local bgW,bgH = self._bg3:getContentSize().width,self._bg3:getContentSize().height
    self._bgW,self._bgH = bgW,bgH
    -- self:addPopViewTitleAnim(self._bg,"baowujihuo_huodetitleanim",284,390)   
    ScheduleMgr:delayCall(400, self, function( )
        if callback and self._bg then
            callback()
        end
	    self._shareNode:runAction(cc.FadeIn:create(0.5))
		self._shareNode:registerClick(function()
	        return {moduleName = "ShareTreasureModule", treasureid = self._curComData.id, isHideBtn = true}
	        end)
	    -- for i=1,#self._panels do
	    --     local des = self._panels[i]
	    --     ScheduleMgr:delayCall(i*200, self, function( )
	    --     	if not des or tolua.isnull(des) then return end
	    --         des:setVisible(true)
	    --         -- des:runAction(cc.JumpBy:create(0.1,cc.p(0,0),10,1))--cc.Sequence:create(,cc.CallFunc:create(function ( )
	    --         if i == 1 or i == 3 then
	    --         	audioMgr:playSound("adIcon")
	    --         end
	    --         if i > 3 then
	    --         	audioMgr:playSound("adTag")
			  --       des:setPositionY((#self._panels-3)*35+20 - (i-3.5)*self._panelH)
		   --          local mcShua = mcMgr:createViewMC("shuxingshuguang_itemeffectcollection", true, false, function (_, sender)
		   --              sender:removeFromParent()
		   --          end,RGBA8888)
		   --          mcShua:setPosition(cc.p(bgW/2,des:getPositionY()))
		   --          -- mcShua:setPlaySpeed(0.2)
		   --          self._bg3:addChild(mcShua,99)
		   --      end
	    --     end)
	    -- end
	    ScheduleMgr:delayCall(300, self, function( )
		    self._closeTip:runAction(cc.FadeIn:create(0.3))
		    self:registerClickEventByName("closePanel",function( )
		    	if self._callback then
		    		self._callback()
		    	end
				self:close()
				UIUtils:reloadLuaFile("treasure.TreasureActiveView")
			end)

	    end)
    end)
end

return TreasureActiveView