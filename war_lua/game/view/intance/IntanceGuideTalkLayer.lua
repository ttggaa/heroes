--[[
    Filename:    IntanceGuideTalkLayer.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-12-31 10:49:14
    Description: File description
--]]

local IntanceGuideTalkLayer = class("IntanceGuideTalkLayer",BaseMvcs, ccui.Widget)

--[[
 @desc  创建
 @return 
--]]
function IntanceGuideTalkLayer:ctor(inData)
	IntanceGuideTalkLayer.super.ctor(self)

	self._stepCallback = inData.stepCallback

	self._finishCallback = inData.finishCallback

    self._autoPlay = inData.autoPlay

	self._talk = inData.talkContent

    self:registerScriptHandler(function (state)
        if state == "exit" then
        	if self._updateId then
            	ScheduleMgr:unregSchedule(self._updateId)
            end
            UIUtils:reloadLuaFile("intance.IntanceGuideTalkLayer")
            package.loaded["game.config.guide.GuideStoryConfig"] = nil  
		    require("game.config.guide.GuideStoryConfig")
        end
    end)

	self._talkIndex = 0
	self._runPrinter = false
	self._printerJump = false

    self._talkBg = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI4_guideTalkBg1.png")  
    self._talkBg:setCapInsets(cc.rect(122, 24, 1, 1))
    self._talkBg:setContentSize(cc.size(854,157))
    self._talkBg:setPosition(MAX_SCREEN_WIDTH/2, 20)
    self._talkBg:setAnchorPoint(cc.p(0.5, 0))
    self:addChild(self._talkBg, 20)


	local goOn =  cc.Sprite:createWithSpriteFrameName("guideImage_goOn.png")
	goOn:setAnchorPoint(0.5,0.5)
	goOn:setPosition(self._talkBg:getContentSize().width/2, 0)
	self._talkBg:addChild(goOn)
	goOn:runAction(cc.RepeatForever:create(cc.Sequence:create(
					cc.MoveTo:create(0.5, cc.p(goOn:getPositionX(), -10)),
					cc.MoveTo:create(0.5, cc.p(goOn:getPositionX(), 0)))
			))

    self._talkBg:setCascadeOpacityEnabled(true, true)
	self._talkBg:setOpacity(0)


    local bgLayer = ccui.Layout:create()
    bgLayer:setBackGroundColorOpacity(0)
    bgLayer:setBackGroundColorType(1)
    bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    bgLayer:setTouchEnabled(true)
    bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    bgLayer.noSound = true
    self:addChild(bgLayer, 1)

    registerClickEvent(bgLayer, function ()
    	if self._printerText ~= nil then 
    		if self._printerJump == false then 
        		self._printerText:finishAll()
        	else
        		self:stopAllActions()
				if self._talk[self._talkIndex + 1] == nil and self._notClose then

				else
					if self._printerText ~= nil then 
						self._printerText:removeFromParent()
						self._printerText = nil
					end
				end
				self._printerJump = false
				self:roleEntrance()
        	end
    	end
    end)

	self._talkRole1 = cc.Sprite:create()
	self._talkRole1:setAnchorPoint(1,0)
	self._talkRole1:setPosition(0, -10)
	self:addChild(self._talkRole1,21)

	self._talkRole1.roleImg = ""
    self._talkRole1.isEntrance = false
    -- 名牌节点
    self._nameNode1 = ccui.Widget:create()
    self._nameNode1:setPosition(600, 200)
	self._nameNode1:setVisible(false)
    self._talkRole1:addChild(self._nameNode1)
    -- 名牌背景
    self._nameBg1 = cc.Scale9Sprite:createWithSpriteFrameName("globalImageUI_talkNameBg.png",cc.rect(126,21,1,1))
	self._nameBg1:setContentSize(cc.size(127,42))
	self._nameBg1:setAnchorPoint(1,0.5)
	self._nameBg1:setScaleX(-2)
	self._nameBg1:setVisible(false)
	self._talkRole1:addChild(self._nameBg1,-1)
    -- 名牌
    self._name1 = cc.Label:createWithTTF("", UIUtils.ttfName_Title, 30)
    self._name1:setColor(cc.c4b(255,246,235,255))
    self._name1:enable2Color(1,cc.c4b(255,219,173,255))
    self._name1:enableOutline(cc.c4b(60,34,0,255),3)
    self._name1:setAnchorPoint(0,0.5)
    self._name1:setPositionX(10)
    self._nameNode1:addChild(self._name1,23)

	self._talkRole2 =  cc.Sprite:create()
	self._talkRole2:setAnchorPoint(0,0)
	self._talkRole2:setPosition(MAX_SCREEN_WIDTH, -10)
	self:addChild(self._talkRole2,21)

	-- 名牌背景
    self._nameNode2 = ccui.Widget:create()
    self._nameNode2:setPosition(-200, 200)
	self._nameNode2:setVisible(false)
    self._talkRole2:addChild(self._nameNode2)
    self._nameBg2 = cc.Scale9Sprite:createWithSpriteFrameName("globalImageUI_talkNameBg.png",cc.rect(126,21,1,1))
	self._nameBg2:setContentSize(cc.size(127,42))
	self._nameBg2:setAnchorPoint(1,0.5)
	self._nameBg2:setScaleX(2)
	self._nameBg2:setVisible(false)
	self._talkRole2:addChild(self._nameBg2,-1)
    -- 名牌
    self._name2 = cc.Label:createWithTTF("", UIUtils.ttfName_Title, 30)
    self._name2:setColor(cc.c4b(255,246,235,255))
    self._name2:enable2Color(1,cc.c4b(255,219,173,255))
    self._name2:enableOutline(cc.c4b(60,34,0,255),3)
    self._name2:setAnchorPoint(1,0.5)
    self._nameNode2:addChild(self._name2,23)

	self._talkRole2.roleImg = ""
    self._talkRole2.isEntrance = false

	local hasSpine1 = false
	local hasSpine2 = false
	for i = 1, #self._talk do
		if not string.find(self._talk[i][5] or self._talk[i][3], ".png") then
			if self._talk[i][1] == 1 then
				hasSpine1 = true
			else
				hasSpine2 = true
			end
		end
	end
	if hasSpine1 then
	    spineMgr:createSpine("xinshouyindao", function (spine)
	        spine:setVisible(false)
	        spine.endCallback = function ()
	            spine:setAnimation(0, "pingdan", true)
	        end 
	        local anim = "pingdan"
        	if self._talkRole1.spineAnim then
        		anim = self._talkRole1.spineAnim
        	end
	        spine:setAnimation(0, anim, true)
	        spine:setPosition(-280, 200)
	        self._talkRole1:addChild(spine)
	        self._spine1 = spine
	    end)
	end
	if hasSpine2 then
	    spineMgr:createSpine("xinshouyindao", function (spine)
	        spine:setVisible(false)
	        spine.endCallback = function ()
	            spine:setAnimation(0, "pingdan", true)
	        end 
        	local anim = "pingdan"
        	if self._talkRole2.spineAnim then
        		anim = self._talkRole2.spineAnim
        	end
	        spine:setAnimation(0, anim, true)
	        spine:setScaleX(-1)
	  		spine:setPosition(200, 200)
	        self._talkRole2:addChild(spine)
	        self._spine2 = spine
	    end)
	end

	self._spJumpGuideBg = ccui.Button:create("globalBtn_jumpGuide.png", "globalBtn_jumpGuide.png", "", 1)
    self._spJumpGuideBg:setAnchorPoint(1,1)
    self._spJumpGuideBg:setPosition(MAX_SCREEN_WIDTH - (ADOPT_IPHONEX and 70 or 10), MAX_SCREEN_HEIGHT - 10)
    self:addChild(self._spJumpGuideBg, 999)

    self._spJumpGuideBg:setTouchEnabled(true)
    registerClickEvent(self._spJumpGuideBg, function()
    	self._spJumpGuideBg:setVisible(false)
    	if not self._notClose then
    		self:setVisible(false)
    	end
		if self._finishCallback ~= nil then 
			self._finishCallback(1)
			self._finishCallback = nil
			self:over()
		end
    end)
end


function IntanceGuideTalkLayer:runTalk()
	self._runPrinter = true
    local talkContent = "空"
    if self._talk[self._talkIndex] ~= nil and self._talk[self._talkIndex][2] ~= nil then talkContent = self._talk[self._talkIndex][2] end
    self._printerText = RichTextFactory:create(talkContent, 500, 140)
    self._printerText:enablePrinter(true)
    self._printerText:setPrintInterval(0.1)
    self._printerText:formatText()
    self._printerText:setAnchorPoint(cc.p(0.5, 0.5))
    local x = 0
    if self._talkRole2.isEntrance == true then 
    	x = self._talkRole1:getPositionX() + self._talkRole1.width/2 - self._printerText:getInnerSize().width/2 + (ADOPT_IPHONEX and 200 or 80)
    else
		x = self._talkBg:getPositionX() - self._talkBg:getContentSize().width /2 + (ADOPT_IPHONEX and 180 or 100) + self._printerText:getInnerSize().width/2
    end
    local offsetX,offsetY = 0,0
    if self._talk[self._talkIndex][12] then
    	offsetX = self._talk[self._talkIndex][12][1] or 0
    	offsetY = self._talk[self._talkIndex][12][2] or 0
	end
    self._printerText:setPosition(x+offsetX , 20 + self._talkBg:getContentSize().height/2+offsetY)

    self:addChild(self._printerText, 22)
end



function IntanceGuideTalkLayer:update()
	if self._runPrinter == false then 
		return
	end
	if self._printerText ~= nil and 
		self._printerText:allFinished() then 
		self._runPrinter = false
		if self._callback ~= nil then 
			self._callback()
		end
		self._printerJump = true 
        if self._autoPlay == true then
    		local delay = cc.DelayTime:create(2)
    		self:runAction(cc.Sequence:create(delay,cc.CallFunc:create(function()
    			if self._notClose ~= true then 
    				if self._printerText ~= nil then 
    					self._printerText:removeFromParent()
    					self._printerText = nil
    				end
    			end
    			self._printerJump = false
    			self:roleEntrance()
    		end)))
        end
	end
end

function IntanceGuideTalkLayer:resetData(inData)
	self._stepCallback = inData.stepCallback

	self._finishCallback = inData.finishCallback

	self._talk = inData.talkContent
	self._talkIndex = 0

	self._talkRole1:setAnchorPoint(1,0)
	self._talkRole1:setPosition(0, -10)
	self._talkRole2:setAnchorPoint(0,0)
	self._talkRole2:setPosition(MAX_SCREEN_WIDTH, -10)
end

function IntanceGuideTalkLayer:play(notClose, noJump)
	self._notClose = notClose
	self._noJump = noJump
	self._spJumpGuideBg:setVisible(not self._noJump)
	self._talkBg:runAction(cc.Sequence:create(cc.FadeIn:create(0.2),cc.CallFunc:create(function()
			self:roleEntrance()
	end)))
    self._updateId = ScheduleMgr:regSchedule(0.001, self, function()
       self:update()
    end)
end


function IntanceGuideTalkLayer:over()
	ScheduleMgr:unregSchedule(self._updateId)
end

function IntanceGuideTalkLayer:roleEntrance()
	self._talkIndex = self._talkIndex + 1
	if self._talk[self._talkIndex] == nil then
		if not self._notClose then
			self._talkBg:setVisible(false)
			self._talkRole2:setVisible(false)
			self._talkRole1:setVisible(false)
		end
		self._spJumpGuideBg:setVisible(not self._noJump)
		if self._finishCallback ~= nil then 
			self._finishCallback(2)
			self._finishCallback = nil
			self:over()
		end
		return
	end
	local callback = cc.CallFunc:create(function()
		self:runTalk()
	end)

	if self._printerText ~= nil then 
		self._printerText:removeFromParent()
		self._printerText = nil
	end
	if self._talk[self._talkIndex][4] then
		audioMgr:playTalk(self._talk[self._talkIndex][4])
	end
    if self._talk[self._talkIndex][1] == 1 then 
		self._talkRole1.isEntrance = false
		self._talkRole2.isEntrance = true
		if (self._talk[self._talkIndex][5] or self._talk[self._talkIndex][3]) ~= self._talkRole1.roleImg then 
			self._talkRole1.roleImg = self._talk[self._talkIndex][5] or self._talk[self._talkIndex][3]
			if self._talkRole1.roleImg then
				if not string.find(self._talkRole1.roleImg, ".png") then
					if self._spine1 then
						self._spine1:setVisible(true)
						self._spine1:setAnimation(0, self._talkRole1.roleImg, false)
					end
					self._talkRole1.spineAnim = self._talkRole1.roleImg
					self._talkRole1:setOpacity(0)
					self._talkRole1.width = 498
				else
					if self._spine1 then
						self._spine1:setVisible(false)
					end
					self._talkRole1:setOpacity(255)
					self._talkRole1:setTexture((not self._talk[self._talkIndex][5] and "asset/uiother/guide/" or "asset/") ..self._talkRole1.roleImg)
					-- 调整立汇大小位置颜色
					local pos = self._talk[self._talkIndex][6] or {1,0}
					self._talkRole1:setAnchorPoint(pos[1],pos[2])
					local color = self._talk[self._talkIndex][7] and cc.c3b(0,0,0) or cc.c3b(255,255,255)
					self._talkRole1:setColor(color)
					local zoom = self._talk[self._talkIndex][8] or 1
					self._talkRole1:setScale(zoom)
					self._talkRole1.width = self._talkRole1:getContentSize().width*zoom
					local flip = self._talk[self._talkIndex][11] ~= nil
	                -- if flip then
						self._talkRole1:setFlipX(flip)
	                -- end
					local namePos = self._talk[self._talkIndex][10] or {0,0}
					local nameStr = lang(self._talk[self._talkIndex][9] or "") 
					self._name1:setString(nameStr)
					self._nameNode1:setVisible(self._talk[self._talkIndex][9] ~= nil)
					self._nameBg1:setVisible(self._talk[self._talkIndex][9] ~= nil)
					self._nameNode1:setScale(1/zoom)
					self._nameNode1:setPosition(namePos[1],namePos[2])
					self._nameBg1:setScale(-2/zoom,-1/zoom)
					self._nameBg1:setPosition(namePos[1]-40,namePos[2]+3)
					-- 矫正宽度
					self._talkRole1:setCM(1,1,1,0,0,0,100)
					if namePos[1] and namePos[1] ~= 0 then
						self._talkRole1.exitOffX = self._talkRole1.width - (namePos[1]*zoom + self._nameBg1:getContentSize().width*2)
					end
				end
			end
		end
	else
		self._talkRole1.isEntrance = true
		self._talkRole2.isEntrance = false	
		if (self._talk[self._talkIndex][5] or self._talk[self._talkIndex][3]) ~= self._talkRole2.roleImg then 
			self._talkRole2.roleImg = self._talk[self._talkIndex][5] or self._talk[self._talkIndex][3]
			if not string.find(self._talkRole2.roleImg, ".png") then
				if self._spine2 then
					self._spine2:setVisible(true)
					self._spine2:setAnimation(0, self._talkRole2.roleImg, false)
				end
				self._talkRole2.spineAnim = self._talkRole2.roleImg
				self._talkRole2:setOpacity(0)
				self._talkRole2.width = 425
			else
				if self._spine2 then
					self._spine2:setVisible(false)
				end
				self._talkRole2:setOpacity(255)
				self._talkRole2:setTexture((not self._talk[self._talkIndex][5] and "asset/uiother/guide/" or "asset/") ..self._talkRole2.roleImg)
				-- 调整立汇大小位置颜色
				local pos = self._talk[self._talkIndex][6] or {0,0}
				self._talkRole2:setAnchorPoint(pos[1],pos[2])
				local color = self._talk[self._talkIndex][7] and cc.c3b(0,0,0) or cc.c3b(255,255,255)
				self._talkRole2:setColor(color)
				local zoom = self._talk[self._talkIndex][8] or 1
				self._talkRole2:setScale(zoom)
				local flip = self._talk[self._talkIndex][11] ~= nil
                -- if flip then
					self._talkRole2:setFlipX(flip)
                -- end
				self._talkRole2.width = self._talkRole2:getContentSize().width*zoom
				local namePos = self._talk[self._talkIndex][10] or {0,0}
				local nameStr = lang(self._talk[self._talkIndex][9] or "") 
				self._name2:setString(nameStr)
				self._nameNode2:setVisible(self._talk[self._talkIndex][9] ~= nil)
				self._nameBg2:setVisible(self._talk[self._talkIndex][9] ~= nil)
				self._nameNode2:setScale(1/zoom)
				self._nameNode2:setPosition(namePos[1],namePos[2])
				self._nameBg2:setScale(2/zoom,1/zoom)
				self._nameBg2:setPosition(namePos[1]+40,namePos[2])
				-- -- 矫正宽度
				if namePos[1] and namePos[1] ~= 0 then
					self._talkRole2.exitOffX = -namePos[1]*zoom + self._nameBg1:getContentSize().width*2
				end
			end
		end	
	end

	local time = 0.3 
	local addTime = 0.3

	local action1
	local x, y 
	y = self._talkRole1:getPositionY()
	if self._talkRole1.isEntrance == false then 
		x = self._talkRole1.width
		action1 = cc.EaseIn:create(cc.MoveTo:create(time, cc.p(x, y)), addTime)
	else
		x = (self._talkRole1.exitOffX or 0)
		action1 = cc.MoveTo:create(time, cc.p(x, y))
	end
	-- local action1 = cc.MoveTo:create(0.5, cc.p(x, y))
	self._talkRole1:runAction(action1)
	-- self._talkRole1.isEntrance = not (self._talkRole1.isEntrance == true)

	y = self._talkRole2:getPositionY()
	local action1
	if self._talkRole2.isEntrance == false then 
		x = MAX_SCREEN_WIDTH - self._talkRole2.width
		action1 = cc.EaseIn:create(cc.MoveTo:create(time, cc.p(x, y)), addTime)
	else
		x = MAX_SCREEN_WIDTH+(self._talkRole2.exitOffX or 0)
		action1 = cc.MoveTo:create(time, cc.p(x, y))
	end
	self._talkRole2:runAction(action1)
	-- self._talkRole2.isEntrance = not (self._talkRole2.isEntrance == true)


	local delay = cc.DelayTime:create(0.3)
	self:runAction(cc.Sequence:create(delay,callback))
end

-- function IntanceGuideTalkLayer:runTalk()
-- 	-- self._talkBg:removeAllChildren()
-- 	print("self._talkIndex===",self._talkIndex)
--     self._printerText = RichTextFactory:create(self._talk[self._talkIndex][2],660, 140)
--     self._printerText:enablePrinter(true)
--     self._printerText:setPrintInterval(0.05)
--     self._printerText:formatText()
--     self._printerText:setVerticalSpace(3)
--     self._printerText:setAnchorPoint(cc.p(0.5,0.5))
--     self._printerText:setPosition(self._talkBg:getContentSize().width/2 - 50, self._talkBg:getContentSize().height/2)

--     self._talkBg:addChild(self._printerText)
-- end

return IntanceGuideTalkLayer