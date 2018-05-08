--[[
    Filename:    SkillTalentUpDialog.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-12-18 17:36:31
    Description: File description
--]]


local SkillTalentUpDialog = class("SkillTalentUpDialog",BasePopView)
function SkillTalentUpDialog:ctor(data)
    SkillTalentUpDialog.super.ctor(self)

    self._oldLevel = data.oldLevel
    self._callback = data.callback
    self._skillTalentModel = self._modelMgr:getModel("SkillTalentModel")
end

function SkillTalentUpDialog:getMaskOpacity()
    return 230
end

function SkillTalentUpDialog:getRegisterNames()
	return {
		{"closePanel","closePanel"},
		{"name","bg.name"},
		{"bigArrow","bg.bigArrow"},

		{"richBg","bg.richBg"},
		{"closeTip","bg.closeTip"},
		{"iconPanel","bg.iconPanel"},

		{"levelold","bg.levelold"},
		{"levelNew","bg.levelNew"},
		{"break","bg.break"},
		{"bg3", "bg.bg3"},
		{"bg", "bg"},
		{"bg", "bg"}
	}
end

-- 初始化UI后会调用, 有需要请覆盖
function SkillTalentUpDialog:onInit()
	self._closePanel:setOpacity(0)
	self._name:setVisible(false)
	self._bigArrow:setVisible(false)
	self._richBg:setVisible(false)
	self._iconPanel:setVisible(false)
	self._levelold:setVisible(false)
	self._levelNew:setVisible(false)
	self._break:setVisible(false)
end


-- 接收自定义消息
function SkillTalentUpDialog:reflashUI(data)
    -- self:initBasicInfo(data.id,data.stage-1)
    -- self.fightCallBack = data.callBack


    local id = data.id
    local oldLevel = data.oldLevel
    local newLevel = oldLevel + 1
    local icon = self._iconPanel:getChildByFullName("icon")
    local levelLabel = self._iconPanel:getChildByFullName("level")
    local talentData = self._skillTalentModel:dataWithId(id)

    icon:loadTexture(talentData.image .. ".png",1)
    self._name:setString(lang(talentData.name))
    levelLabel:setString(newLevel)
    self._levelold:setString("Lv." .. oldLevel)
    self._levelNew:setString("Lv." .. newLevel)
    self._bigArrow:setPositionX(self._levelold:getPositionX()+self._levelold:getContentSize().width + 39)
    self._levelNew:setPositionX(self._levelold:getPositionX()+self._levelold:getContentSize().width+78)

    local richDes = lang(talentData.dsc1)
    richDes = "[color=ffeea0,fontsize=18]" .. richDes .. "[-]"
    local base = talentData.base
    local addNum = math.max(base,base + (talentData.level - 1) * talentData.addition)
    richDes = string.gsub(richDes,"{$int}",addNum)

    local rtx = RichTextFactory:create(richDes,self._richBg:getContentSize().width,self._richBg:getContentSize().height)
    rtx:formatText()
    rtx:setVerticalSpace(1)
    self._richBg:addChild(rtx)
    self._richBg.richNode = rtx
    rtx:setPosition(self._richBg:getContentSize().width*0.5,self._richBg:getContentSize().height*0.5)

    

    self._panels = {}
	table.insert(self._panels,self._iconPanel)
	table.insert(self._panels,self._name)
	table.insert(self._panels,self._levelold)
	table.insert(self._panels,self._bigArrow)
	table.insert(self._panels,self._levelNew)
	table.insert(self._panels,self._richBg)

	local advanceData = talentData.advancedlv
	dump(advanceData)
	local isBreak = false
	local index = 0
	for _index,level in pairs (advanceData) do 
		if level == newLevel then
			isBreak = true
			index = _index
			break
		end
	end
	if isBreak then
		local des = self._break:getChildByFullName("des")
	    local text = talentData["dscsp" .. index .. "_" .. index]
	    -- if oldLevel ~= 0 then
	    -- 	text = talentData.dscsp2_2
	    -- end
	    des:setString(lang(text))
		table.insert(self._panels,self._break)
	end 
	

	for _,item in pairs (self._panels) do 
		item:setCascadeOpacityEnabled(true)
		item:setOpacity(0)
	end




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


function SkillTalentUpDialog:animBegin(callback)
	audioMgr:playSound("adTitle")

    local bgW,bgH = self._bg3:getContentSize().width,self._bg3:getContentSize().height
    self._bgW,self._bgH = bgW,bgH
    if self._oldLevel == 0 then
    	self:addPopViewTitleAnim(self._bg,"gongxihuode_jihuochenggongui",284,340) 
    else
    	self:addPopViewTitleAnim(self._bg,"shengjichenggong_shengjichenggong",284,340) 
    end
     

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
	            des:runAction(spawn)
	            -- if des:getChildByName("rtx") then
	            -- 	des:getChildByName("rtx"):setVisible(true)
	            -- end
	            -- if i == 1 or i == 3 then
	            -- 	audioMgr:playSound("adIcon")
	            -- end
	         --    if i > 3 then
	         --    	audioMgr:playSound("adTag")
			       --  -- des:setPositionY((#self._panels-3)*35+20 - (i-3.5)*self._panelH)
		        --     local mcShua = mcMgr:createViewMC("shuxingshuguang_itemeffectcollection", true, false, function (_, sender)
		        --         sender:removeFromParent()
		        --     end,RGBA8888)
		        --     mcShua:setPosition(cc.p(self._bg:getContentSize().width/2-120,des:getPositionY()+self._panelH/2-4))
		        --     -- mcShua:setPlaySpeed(0.2)
		        --     self._bg:addChild(mcShua,99)
		        -- end
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

function SkillTalentUpDialog:doClear()
	if self._callback then
		self._callback()
	else
	    -- self.fightCallBack(math.floor(self._treasureOldFight), math.floor(self._treasureNewFight))
	end
	self:close(true)
	UIUtils:reloadLuaFile("spellbook.SkillTalentUpDialog")
end
return SkillTalentUpDialog