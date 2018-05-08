--
-- Author: huachangmiao@playcrab.com
-- Date: 2016-08-16 23:12:25
--

-- 技能预览

local GlobalSkillPreviewDialog = class("GlobalSkillPreviewDialog", BasePopView)

local tc = cc.Director:getInstance():getTextureCache()
local sfc = cc.SpriteFrameCache:getInstance()
local sfResMgr = SpriteFrameResManager:getInstance()
local mcMgr = MovieClipManager:getInstance()
function GlobalSkillPreviewDialog:getAsyncRes()
    return 
    {
        "asset/bg/skillPreviewBg.png",
    }
end

local function getResFileName(resname)
    local list = string.split(resname, "_")
    return {"asset/anim/"..list[#list].."image.plist", "asset/anim/"..list[#list].."image.png"} 
end

function GlobalSkillPreviewDialog:ctor(data)
    GlobalSkillPreviewDialog.super.ctor(self)

    self._isInBattle = data.inBattle

    if self._isInBattle then
    	self.popAnim = false
    end

    -- 施法者
    self._teamD = tab.team[data.teamId]
    -- 技能
    self._skillD = tab.skill[data.skillId]
    -- 敌人
    self._targetD = tab.team[self._skillD["targeId"]]
    if self._targetD == nil then
    	self._targetD = tab.team[101]
    end
    self._targetCount = 6
    if self._skillD["targetCount"] then
    	self._targetCount = self._skillD["targetCount"]
    end
    -- 敌人2号位
    if self._skillD["targeId2"] then
	    self._targetD2 = tab.team[self._skillD["targeId2"]]
	    if self._targetD2 == nil then
	    	self._targetD2 = tab.team[101]
	    end
    end
    -- 敌人3号位
    if self._skillD["targeId3"] then
	    self._targetD3 = tab.team[self._skillD["targeId3"]]
	    if self._targetD3 == nil then
	    	self._targetD3 = tab.team[101]
	    end
    end

    self._mcScale = self._skillD["mcScale"]
    if self._mcScale == nil then
    	self._mcScale = 0.5
    end
    -- 友军
    self._friendD = tab.team[self._skillD["friendId"]]
    if self._friendD == nil then
    	self._friendD = tab.team[101]
    end

    self._dis = self._skillD["muzhuang"]
    if self._dis == nil then
    	self._dis = 400
    end
    self._number = self._skillD["falsehurt"]
    if self._number == nil then
    	self._number = 8888
    end

    -- 为了区分mc和sfc 的mgr管理的纹理
    self._loadingList = {}
    self._releaseList = {}
    local skillD = self._skillD 
    local AnimAP = require "base.anim.AnimAP"

    -- 左方图
    if AnimAP["mcList"][self._teamD["art"]] then
    	self._leftIsMc = true
    	self._loadingList[#self._loadingList + 1] = {"asset/anim/"..self._teamD["art"].."image.plist", "asset/anim/"..self._teamD["art"].."image.png"}
    else
        self._loadingList[#self._loadingList + 1] = {"asset/role/"..self._teamD["art"]..".plist", "asset/role/"..self._teamD["art"]..".png"}
    end
    -- 右方图
    if AnimAP["mcList"][self._targetD["art"]] then
    	self._rightIsMc = true
    	self._loadingList[#self._loadingList + 1] = {"asset/anim/"..self._targetD["art"].."image.plist", "asset/anim/"..self._targetD["art"].."image.png"}
    else
        self._loadingList[#self._loadingList + 1] = {"asset/role/"..self._targetD["art"].."_e.plist", "asset/role/"..self._targetD["art"].."_e.png"}
    end
    -- 友军图
    if AnimAP["mcList"][self._friendD["art"]] then
    	self._friendIsMc = true
    	self._loadingList[#self._loadingList + 1] = {"asset/anim/"..self._friendD["art"].."image.plist", "asset/anim/"..self._friendD["art"].."image.png"}
    else
    	self._loadingList[#self._loadingList + 1] = {"asset/role/"..self._friendD["art"]..".plist", "asset/role/"..self._friendD["art"]..".png"}
    end
    if self._targetD2 then
    	self._loadingList[#self._loadingList + 1] = {"asset/role/"..self._targetD2["art"].."_e.plist", "asset/role/"..self._targetD2["art"].."_e.png"}
    end
    if self._targetD3 then
    	self._loadingList[#self._loadingList + 1] = {"asset/role/"..self._targetD3["art"].."_e.plist", "asset/role/"..self._targetD3["art"].."_e.png"}
    end

    -- self._loadingList[#self._loadingList + 1] = {"asset/role/bullet.plist", "asset/role/bullet.png"}
    self._loadingList[#self._loadingList + 1] = {"asset/role/shadow.plist", "asset/role/shadow.png"}
    self._releaseList[#self._releaseList + 1] = self._loadingList[#self._loadingList]

    local keyTable1 = {"skillart",
                    "frontstk_v", "frontstk_h", "backstk_v", "backstk_h",
                    "frontimp_v1", "frontimp_h1", "backimp_v1", "backimp_h1"}

    local keyTable2 = {"frontoat_v", "frontoat_h", "backoat_v", "backoat_h"}
    for i = 1, #keyTable1 do
    	if skillD[keyTable1[i]] then
    		self._loadingList[#self._loadingList + 1] = getResFileName(skillD[keyTable1[i]])
    	end
    end
    if skillD["buffid1"] then
    	local buffD = tab.skillBuff[skillD["buffid1"]]
    	if buffD["buffart"] then
    		self._loadingList[#self._loadingList + 1] = getResFileName(buffD["buffart"])
    	end
    	self._buffD = buffD
    end
    if skillD["objectid"] then
    	local totemD = tab.object[skillD["objectid"]]
	    for i = 1, #keyTable2 do
	    	if totemD[keyTable2[i]] then
	    		self._loadingList[#self._loadingList + 1] = getResFileName(totemD[keyTable2[i]])
	    	end
	    end
    	self._totemD = totemD
    end
end

function GlobalSkillPreviewDialog:onInit()
	-- self._bg = cc.Sprite:create("asset/bg/skillPreviewBg.png")
	-- self._bg:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
	local bg = self:getUI("bg")

	local closeBtn = self:getUI("bg.imageBg.closeBtn")
    self:registerClickEvent(closeBtn, function()
    	-- 释放资源
    	self:_releaseRes()
        self:close()
    end)
	-- bg:addChild(self._bg)
	self._bg = self:getUI("bg.imageBg.imageMiddle")
	self._bg:loadTexture("asset/bg/skillPreviewBg.png")
	self._layer = self:getUI("bg.imageBg")
	self._stage = ccui.Layout:create()
	self._stage:setClippingEnabled(true)
	self._stage:setContentSize(self._bg:getContentSize().width, self._bg:getContentSize().height-10)
	self._stage:setPosition(10, 10)
	self._bg:addChild(self._stage)

	-- local label = cc.Label:createWithTTF("点击任意位置退出", UIUtils.ttfName, 22)
	-- label:setPosition(MAX_SCREEN_WIDTH * 0.5, (MAX_SCREEN_HEIGHT - self._bg:getContentSize().height) * 0.25)
	-- bg:addChild(label)

	local height = 80
	-- 中心
	self._x0, self._y0 = self._bg:getContentSize().width * 0.5, height
	-- 自己
	self._x1, self._y1 = self._bg:getContentSize().width * 0.5 - self._dis * 0.5, height
	-- 敌人
	self._x2, self._y2 = self._bg:getContentSize().width * 0.5 + self._dis * 0.5, height
	-- 友军
	self._x3, self._y3 = self._bg:getContentSize().width * 0.5, height

	-- 敌人2
	self._x4, self._y4 = self._bg:getContentSize().width * 0.5 + self._dis * 0.5 - 60, height + 90
	-- 敌人3
	self._x5, self._y5 = self._bg:getContentSize().width * 0.5 + self._dis * 0.5 + 60, height - 90

	self:lock(1)
	UIUtils:aysncLoadRes(self._loadingList, function ()
		self:unlock()
		self:previewSkill()
	end)

	local teamD = self._teamD
	-- 名称
	local race = teamD["race"][1]
	local name = self:getUI("bg.imageBg.titleLabel") 
	name:setString(lang(teamD["name"]))
	-- name:setAnchorPoint(0, 0)
	name:setColor(cc.c3b(78,50,13))
	-- if race == 101 then
 --    	name:enable2Color(1,cc.c4b(94,208,255,255))
 --    elseif race == 102 then
 --    	name:enable2Color(1,cc.c4b(94,255,94,255))
 --    elseif race == 103 then
 --    	name:enable2Color(1,cc.c4b(255,181,94,255))
 --   	elseif race == 104 then
 --    	name:enable2Color(1,cc.c4b(255,139,94,255))
 --   	elseif race == 105 then
 --    	name:enable2Color(1,cc.c4b(255,54,210,255))
 --   	elseif race == 109 then
 --    	name:enable2Color(1,cc.c4b(94,255,94,255))	
 --    end
    -- name:setPosition(30, 60)
    -- self._bg:addChild(name)

    -- 简介
 --    local des = cc.Label:createWithTTF(lang("CARDDES_"..teamD["carddes"]), UIUtils.ttfName, 22)
	-- des:setAnchorPoint(0, 0)
	-- des:setColor(cc.c3b(255,255,255))
	-- des:setPosition(30, 34)
 --    self._bg:addChild(des)

    local skillD = self._skillD
    -- 技能名称
 --  	local skillname = cc.Label:createWithTTF(lang(skillD["showname"]), UIUtils.ttfName, 30)
	-- skillname:setAnchorPoint(1, 0)
	-- skillname:setColor(cc.c3b(255,234,22))
 --    skillname:setPosition(772, 456)
 --    self._bg:addChild(skillname)  

    -- 技能简介
 --    local skilldes = cc.Label:createWithTTF(lang(skillD["showlang"]), UIUtils.ttfName, 22)
	-- skilldes:setAnchorPoint(1, 0)
	-- skilldes:setColor(cc.c3b(255,255,255))
 --    skilldes:setPosition(772, 430)
 --    self._bg:addChild(skilldes) 

 	local skillDes = self:getUI("bg.imageBg.skillDes")
 	skillDes:setString(lang("CARDDES_"..teamD["carddes"]))
 	local imgLine1 = self:getUI("bg.imageBg.des_imge1")
 	imgLine1:setPositionX(skillDes:getPositionX()-skillDes:getContentSize().width/2-10)
 	local imgLine2 = self:getUI("bg.imageBg.des_imge2")
 	imgLine2:setPositionX(skillDes:getPositionX()+skillDes:getContentSize().width/2+32)


    local richStr = "[color=3c2a1e,fontsize = 24]"..lang(skillD["showname"])..":[-][color=645252,fontsize = 20]"..lang(skillD["showlang"]).."[-]"
    self._desRich = RichTextFactory:create(richStr, 820, 100)
    self._desRich:formatText()
    self._desRich:enablePrinter(true)
    self._desRich:setPosition(473, 47)
    self._layer:addChild(self._desRich)
	UIUtils:alignRichText(self._desRich,{hAlign = "center"})
end

local dieEffName = {nil, "ranshaosiwang", "bingdongsiwang", "dianjisiwang"}
local teamPos1 = {{10, 30}, {-50, 30}, {30, 0}, {-30, 0}, {50, -30}, {-10, -30}}
local teamPos2 = {{30, 0}, {-30, 0}}
local teamPos3 = {{30, 0}, {-30, 0}}
local teamPoss = {teamPos1}
function GlobalSkillPreviewDialog:previewSkill()
	self._stage:removeAllChildren()
	local skillD = self._skillD

	local targetIsSelf = false
	if skillD["pointkind"] == 1 and (skillD["rangetype1"] == 0 or skillD["rangetype1"] == 3) then 
		targetIsSelf = true
		self._x1, self._y1 = self._x0, self._y0
	end
	-- 建立左边人物
	local leftSp
	if self._leftIsMc then
		MovieClipAnim.new(self._stage, self._teamD["art"], 
			function (sp) 
				leftSp = sp
				leftSp:changeMotion(1)
				leftSp:setScale(0.3)
				leftSp:setPosition(self._x1, self._y1)
				leftSp:setLocalZOrder(100)
				leftSp:play()
				self._w, self._h = leftSp:getSize()
			end, false, nil, nil, false) 
	else
		sfResMgr:cache(self._teamD["art"])
		SpriteFrameAnim.new(self._stage, self._teamD["art"], function (sp)
			leftSp = sp
        	leftSp:changeMotion(1)
        	leftSp:setScale(0.8)
			leftSp:setPosition(self._x1, self._y1)
			leftSp:setLocalZOrder(100)
			leftSp:play()
			self._w, self._h = leftSp:getSize()
    	end, false) 
	end
	local s = self._teamD["s"]
	if s then
		if s > 50 then
			s = 1
		end
		local shadow = cc.Sprite:createWithSpriteFrameName("shadow_"..s..".png")
		shadow:setPosition(self._x1, self._y1)
		shadow:setOpacity(80)
		if self._leftIsMc then
			shadow:setScale(0.75)
		end
		self._stage:addChild(shadow)
	end
	local rightSp = {}
	local friendSp = {}
	local shadow = {}

	local pos = teamPoss[1]
	if not targetIsSelf then
		-- 建立右边人物
		local s = self._targetD["s"]
		if s then
			if s > 50 then
				s = 1
			end
		end
		
		if self._rightIsMc then
			for i = 1, self._targetCount do
				if s then
					shadow[i] = cc.Sprite:createWithSpriteFrameName("shadow_"..s..".png")
					shadow[i]:setPosition(self._x2 + pos[i][1], self._y2 + pos[i][2])
					shadow[i]:setOpacity(80)
					self._stage:addChild(shadow[i])
				end
				MovieClipAnim.new(self._stage, self._targetD["art"], 
					function (sp) 
						rightSp[i] = sp
						rightSp[i]:changeMotion(1)
						rightSp[i]:setScale(0.3)
						rightSp[i]:setScaleX(-0.6)
						rightSp[i]:setPosition(self._x2 + pos[i][1], self._y2 + pos[i][2])
						rightSp[i]:play()
					end, true, nil, nil, false) 
			end
		else
			local targetArt = self._targetD["art"].."_e"
			sfResMgr:cache(targetArt)
			for i = 1, self._targetCount do
				if s then
					shadow[i] = cc.Sprite:createWithSpriteFrameName("shadow_"..s..".png")
					shadow[i]:setPosition(self._x2 + pos[i][1], self._y2 + pos[i][2])
					shadow[i]:setOpacity(80)
					self._stage:addChild(shadow[i])
				end
				SpriteFrameAnim.new(self._stage, targetArt, function (sp)
					rightSp[i] = sp
		        	rightSp[i]:changeMotion(1)
		        	rightSp[i]:setScale(0.8)
		        	rightSp[i]:setScaleX(-0.8)
					rightSp[i]:setPosition(self._x2 + pos[i][1], self._y2 + pos[i][2])
					rightSp[i]:play()
		    	end, true) 
		    end
		    if self._targetD2 then
	    		local ss = self._targetD2["s"]
				if ss then
					if ss > 50 then
						ss = 1
					end
				end
			    for i = 1, #teamPos2 do
					if ss then
						local shadow = cc.Sprite:createWithSpriteFrameName("shadow_"..ss..".png")
						shadow:setPosition(self._x4 + teamPos2[i][1], self._y4 + teamPos2[i][2])
						shadow:setOpacity(80)
						self._stage:addChild(shadow)
					end
					SpriteFrameAnim.new(self._stage, self._targetD2["art"].."_e", function (sp)
			        	sp:changeMotion(1)
			        	sp:setScale(0.6)
			        	sp:setScaleX(-0.6)
						sp:setPosition(self._x4 + teamPos2[i][1], self._y4 + teamPos2[i][2])
						sp:play()
			    	end, true) 
			    end
			end
			if self._targetD3 then
				local ss = self._targetD3["s"]
				if ss then
					if ss > 50 then
						ss = 1
					end
				end
			    for i = 1, #teamPos3 do
					if ss then
						local shadow = cc.Sprite:createWithSpriteFrameName("shadow_"..ss..".png")
						shadow:setPosition(self._x5 + teamPos3[i][1], self._y5 + teamPos3[i][2])
						shadow:setOpacity(80)
						self._stage:addChild(shadow)
					end
					SpriteFrameAnim.new(self._stage, self._targetD3["art"].."_e", function (sp)
			        	sp:changeMotion(1)
			        	sp:setScale(0.8)
			        	sp:setScaleX(-0.8)
						sp:setPosition(self._x5 + teamPos3[i][1], self._y5 + teamPos3[i][2])
						sp:play()
			    	end, true) 
			    end
			end
		end
		
		if skillD["damagekind1"] == 1 then 
			-- 如果是有利法术, 就添加友军
			local s = self._friendD["s"]
			if s then
				if s > 50 then
					s = 1
				end
			end
			local pos = teamPoss[1]
			local shadow
			if self._friendIsMc then
				for i = 1, #pos do
					if s then
						shadow = cc.Sprite:createWithSpriteFrameName("shadow_"..s..".png")
						shadow:setPosition(self._x3 + pos[i][1], self._y3 + pos[i][2])
						shadow:setOpacity(80)
						self._stage:addChild(shadow)
					end
					MovieClipAnim.new(self._stage, self._friendD["art"], 
						function (sp) 
							friendSp[i] = sp
							friendSp[i]:changeMotion(1)
							friendSp[i]:setScale(0.3)
							friendSp[i]:setPosition(self._x3 + pos[i][1], self._y3 + pos[i][2])
							friendSp[i]:play()
						end, false, nil, nil, false) 
				end
			else
				local friendArt = self._friendD["art"]
				sfResMgr:cache(friendArt)
				for i = 1, #pos do
					if s then
						shadow = cc.Sprite:createWithSpriteFrameName("shadow_"..s..".png")
						shadow:setPosition(self._x3 + pos[i][1], self._y3 + pos[i][2])
						shadow:setOpacity(80)
						self._stage:addChild(shadow)
					end
					SpriteFrameAnim.new(self._stage, friendArt, function (sp)
						friendSp[i] = sp
			        	friendSp[i]:changeMotion(1)
			        	friendSp[i]:setScale(0.8)
						friendSp[i]:setPosition(self._x3 + pos[i][1], self._y3 + pos[i][2])
						friendSp[i]:play()
			    	end, false) 
			    end
			end
		end
	end

	local number = self._number
	if skillD["damagekind1"] == 2 then
		number = -number
	end
	local dieart = skillD["dieart"]
	ScheduleMgr:delayCall(300, self, function()

		-- 释放特效
		if skillD["skillart"] then
		    local scale = 1
	        if skillD["skillartscale"] then
	            scale = skillD["skillartscale"] * 0.01
	        end
	        local mc = mcMgr:createViewMC(skillD["skillart"], false, true)
	       	mc:setPosition(self._x1, self._y1)
	       	mc:setLocalZOrder(200)
	       	mc:setScale(scale * self._mcScale)
	       	self._stage:addChild(mc)
	    end

		local skillMotion = {3, 5, 6, 7}
		
		leftSp:changeMotion(skillMotion[skillD["actionart"]], nil, function ()
			leftSp:changeMotion(1)
		end)
		local calculation = skillD["calculation"]
		if not calculation then
			calculation = 0
		end
        local delaystk = 0
        if skillD["delaystk"] then
            delaystk = skillD["delaystk"] / 50
        end
		-- 受击点特效
		ScheduleMgr:delayCall((calculation + delaystk) * 50, self, function()
            local _x, _y
           	if skillD["pointkind"] == 1 then 
                _x, _y = self._x1, self._y1
            else
            	_x, _y = self._x2, self._y2
            end
            local __x, __y = 0, 0
            if skillD["stkpoint"] then
            	local pos = skillD["stkpoint"]
	            if pos == 1 then
			        -- 头
			        local ap = leftSp:getAp(2)
			        __x, __y = ap[1] * leftSp:getScale(), ap[2] * leftSp:getScale() + 5
			    elseif pos == 2 then
			        -- 身
			        local ap = leftSp:getAp(1)
			         __x, __y = ap[1] * leftSp:getScale(), ap[2] * leftSp:getScale()
			    elseif pos == 3 then
			        -- 脚
			    else   
					local ap = leftSp:getAp(3)
			        __x, __y = ap[1] * leftSp:getScale(), ap[2] * leftSp:getScale()    	
			   	end	
			   	_x = _x + __x
			   	_y = _y + __y
            end
            if skillD["frontstk_v"] then
		        local mc = mcMgr:createViewMC(skillD["frontstk_v"], false, true)
		       	mc:setPosition(_x, _y)
		       	mc:setLocalZOrder(200)
		       	mc:setScale(self._mcScale)
		       	self._stage:addChild(mc)
            end
            if skillD["frontstk_h"] then
		        local mc = mcMgr:createViewMC(skillD["frontstk_h"], false, true)
		       	mc:setPosition(_x, _y)
		       	mc:setLocalZOrder(200)
		       	mc:setScale(self._mcScale)
		       	self._stage:addChild(mc)
            end
            if skillD["backstk_v"] then
		        local mc = mcMgr:createViewMC(skillD["backstk_v"], false, true)
		       	mc:setPosition(_x, _y)
		       	mc:setLocalZOrder(0)
		       	mc:setScale(self._mcScale)
		       	self._stage:addChild(mc)
            end
            if skillD["backstk_h"] then
		        local mc = mcMgr:createViewMC(skillD["backstk_h"], false, true)
		       	mc:setPosition(_x, _y)
		       	mc:setLocalZOrder(0)
		       	mc:setScale(self._mcScale)
		       	self._stage:addChild(mc)
            end 
            -- 上图腾
            if self._totemD then
                local _delay = self._totemD["objectdelay"]
                if _delay == nil then
                    _delay = 0
                end
                ScheduleMgr:delayCall(_delay * 50, self, function()
		            if self._totemD["frontoat_v"] then
				        local mc = mcMgr:createViewMC(self._totemD["frontoat_v"], true)
				       	mc:setPosition(_x, _y)
				       	mc:setLocalZOrder(200)
				       	mc:setScale(self._mcScale)
				       	self._stage:addChild(mc)
		            end
		            if self._totemD["frontoat_h"] then
				        local mc = mcMgr:createViewMC(self._totemD["frontoat_h"], true)
				       	mc:setPosition(_x, _y)
				       	mc:setLocalZOrder(200)
				       	mc:setScale(self._mcScale)
				       	self._stage:addChild(mc)
		            end
		            if self._totemD["backoat_v"] then
				        local mc = mcMgr:createViewMC(self._totemD["backoat_v"], true)
				       	mc:setPosition(_x, _y)
				       	mc:setLocalZOrder(0)
				       	mc:setScale(self._mcScale)
				       	self._stage:addChild(mc)
		            end
		            if self._totemD["backoat_h"] then
				        local mc = mcMgr:createViewMC(self._totemD["backoat_h"], true)
				       	mc:setPosition(_x, _y)
				       	mc:setLocalZOrder(0)
				       	mc:setScale(self._mcScale)
				       	self._stage:addChild(mc)
		            end     
		        end)   	
            end

		end)

		local hitdelay = skillD["delay1"]
		if not hitdelay then
			hitdelay = 0
		end
		local function doDie()
			if skillD["damagekind1"] == 2 then
				if dieart then
					local mcname = "die_"..dieEffName[dieart]
		        	for i = 1, #rightSp do
		        		rightSp[i]:setVisible(false)
		        		shadow[i]:setVisible(false)
		        		local mc = mcMgr:createViewMC(mcname, false, false)
		        		mc:gotoAndPlay(GRandom(3))
		        		mc:setPosition(self._x2 + pos[i][1], self._y2 + pos[i][2])
		        		self._stage:addChild(mc)
		        		if rightSp[i].buff then
		        			rightSp[i].buff:removeFromParent()
		        		end
		        	end
				else
		        	for i = 1, #rightSp do
		        		shadow[i]:setVisible(false)
		        		rightSp[i]:changeMotion(4, nil, function ()
		        			rightSp[i]:setVisible(false)
		        		end, true)
		        		if rightSp[i].buff then
		        			rightSp[i].buff:removeFromParent()
		        		end
		        	end
		        end
		    end
        	ScheduleMgr:delayCall(2500, self, function ()
        		self:previewSkill()
        	end)
		end
		local function doHP()
			if targetIsSelf then
				-- 治疗
				if skillD["damagekind1"] == 1 then
					local w, h = leftSp:getSize()
					self:hpAnim(self._x1, self._y1, h * 0.4, number)	
				end
			else
				if skillD["damagekind1"] == 2 then
					-- 伤害
					for i = 1, #rightSp do
						local w, h = rightSp[i]:getSize()
						self:hpAnim(self._x2 + pos[i][1], self._y2 + pos[i][2] + h * 0.4, number)
					end
				elseif skillD["damagekind1"] == 1 then
					-- 治疗
					for i = 1, #friendSp do
						local w, h = friendSp[i]:getSize()
						self:hpAnim(self._x3 + pos[i][1], self._y3 + pos[i][2] + h * 0.4, number)
					end
				end
			end
		end

		local function addBuff(buffname)
			if targetIsSelf then
				-- 治疗
				local mc = mcMgr:createViewMC(buffname, true)
		       	mc:setPosition(self._x1, self._y1 + self._h * 0.5)
		       	mc:setLocalZOrder(400)
		       	mc:setScale(self._mcScale)
		       	self._stage:addChild(mc)
			else
				if skillD["damagekind1"] == 1 then
					-- 治疗
					for i = 1, #friendSp do
						local w, h = friendSp[i]:getSize()
						local mc = mcMgr:createViewMC(buffname, true)
				       	mc:setPosition(self._x3 + pos[i][1], self._y3 + pos[i][2] + h * 0.5)
				       	mc:setLocalZOrder(400)
				       	mc:setScale(self._mcScale)
				       	self._stage:addChild(mc)
					end
				end
				-- 伤害
				for i = 1, #rightSp do
					local w, h = rightSp[i]:getSize()
					local mc = mcMgr:createViewMC(buffname, true)
			       	mc:setPosition(self._x2 + pos[i][1], self._y2 + pos[i][2] + h * 0.5)
			       	mc:setLocalZOrder(400)
			       	mc:setScale(self._mcScale)
			       	self._stage:addChild(mc)
			       	-- print(buffname)
			       	rightSp[i].buff = mc
				end
			end
		end

		ScheduleMgr:delayCall((calculation + delaystk) * 50, self, function()
			local __x, __y
			if skillD["damagekind1"] == 2 then
				__x, __y = self._x2, self._y2
			elseif skillD["damagekind1"] == 1 then 
				__x, __y = self._x3, self._y3
			end
            if skillD["frontimp_v1"] then
		        local mc = mcMgr:createViewMC(skillD["frontimp_v1"], false, true)
		       	mc:setPosition(__x, __y)
		       	mc:setLocalZOrder(200)
		       	mc:setScale(self._mcScale)
		       	self._stage:addChild(mc)
            end
            if skillD["frontimp_h1"] then
		        local mc = mcMgr:createViewMC(skillD["frontimp_h1"], false, true)
		       	mc:setPosition(__x, __y)
		       	mc:setLocalZOrder(200)
		       	mc:setScale(self._mcScale)
		       	self._stage:addChild(mc)
            end
            if skillD["backimp_v1"] then
		        local mc = mcMgr:createViewMC(skillD["backimp_v1"], false, true)
		       	mc:setPosition(__x, __y)
		       	mc:setLocalZOrder(0)
		       	mc:setScale(self._mcScale)
		       	self._stage:addChild(mc)
            end
            if skillD["backimp_h1"] then
		        local mc = mcMgr:createViewMC(skillD["backimp_h1"], false, true)
		       	mc:setPosition(__x, __y)
		       	mc:setLocalZOrder(0)
		       	mc:setScale(self._mcScale)
		       	self._stage:addChild(mc)
            end 

            ScheduleMgr:delayCall(hitdelay * 50, self, function ()
	            -- 上buff
	        	if self._buffD and self._buffD["buffart"] then
	        		addBuff(self._buffD["buffart"])
	        	end

	            local muti = skillD["muti1"]
	            if muti then
	                for m = 0, muti[1] - 1 do
	                    ScheduleMgr:delayCall(m * muti[2] * 50, self, function ()
	                    	doHP()
	                        if m == muti[1] - 1 then
	                        	doDie()
	                        end
	                    end)
	                end
	            else
	            	doHP()
	            	doDie()
	            end	
	        end)
		end)
	end)
end

local PCTools = pc.PCTools
function GlobalSkillPreviewDialog:hpAnim(x, y, number)
	local hpLabel
	if number < 0 then
		hpLabel = cc.Label:createWithBMFont(UIUtils.bmfName_yellow, number)
		hpLabel:setPosition(x, y)
		hpLabel:setAdditionalKerning(-5)
		hpLabel:setScale(0.4)
	    PCTools:diyAction(hpLabel, 4)
	else
		hpLabel = cc.Label:createWithBMFont(UIUtils.bmfName_green, number)
		hpLabel:setPosition(x, y)
		hpLabel:setAdditionalKerning(-5)
		hpLabel:setScale(0.4)
	    PCTools:diyAction(hpLabel, 2)
	end
	
	self._stage:addChild(hpLabel, 200)
end

function GlobalSkillPreviewDialog:_releaseRes()
	ScheduleMgr:cleanMyselfDelayCall(self)
	self._bg:removeAllChildren()
	if not self._isInBattle then
		sfResMgr:clear()
		mcMgr:clear()
		local info
		for i = 1, #self._releaseList do
			info = self._releaseList[i]
			if type(info) == "string" then
				tc:removeTextureForKey(info)
			else
				sfc:removeSpriteFramesFromFile(info[1])
			    tc:removeTextureForKey(info[2])
			end
		end
	end
end

function GlobalSkillPreviewDialog.dtor()
	tc = nil
	sfc = nil
	sfResMgr = nil
	PCTools = nil
	mcMgr = nil
	dieEffName = nil
end

return GlobalSkillPreviewDialog