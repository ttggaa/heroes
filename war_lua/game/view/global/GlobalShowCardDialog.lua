--[[
    Filename:    GlobalShowCardDialog.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-10-26 18:36:43
    Description: File description
--]]


local GlobalShowCardDialog = class("GlobalShowCardDialog",BasePopView)
function GlobalShowCardDialog:ctor()
    self.super.ctor(self)
end

-- 初始化UI后会调用, 有需要请覆盖
function GlobalShowCardDialog:onInit()
	self._card = self:getUI("bg.card")
	self._card:setVisible(false)
	self._bg = self:getUI("bg")
	self._bg:setVisible(true)
	self._bg1 = self:getUI("bg1")
	self._title = self:getUI("title")
	self._title:setCascadeOpacityEnabled(true)
	self._title:setOpacity(0)
	local titleMc = mcMgr:createViewMC("jingjichangpaimingshanguang_commonwin", true)
    titleMc:setPlaySpeed(1, true)
    --titleMc:setPosition(self._bg:getContentSize().width / 2 + 10, self._bg:getContentSize().height / 2 - 55)
    titleMc:setPosition(self._title:getContentSize().width / 2, self._title:getContentSize().height / 2+25)
    titleMc:setScale(3,0.3)
    titleMc:setCascadeOpacityEnabled(true,true)
    -- titleMc:setPlaySpeed(0.5)
    self._title:addChild(titleMc, 4)
	self._closePanel = self:getUI("closePanel")
	self._closeLab = self:getUI("closeLab")
	self._closeLab:setOpacity(0)
	self._bg1:setVisible(false)
	local isClose = false
	
	self._name = self:getUI("bg1.name")
	self._name:setLocalZOrder(999)
	self._name:enableOutline(cc.c4b(65,65,65,255),1)
	self._name:setPositionY(self._name:getPositionY())
	self._starBg = self:getUI("bg1.starBg")

	-- 背景
	self._allBg = self:getUI("allBg")
	self._allBg:loadTexture("asset/bg/bg_showCard.jpg",0)

	self._floatBg = self:getUI("bg..floatBg")
	-- 额外资源
    -- self._kapaiBg = ccui.ImageView:create()
    -- self._kapaiBg:loadTexture("asset/bg/bg_showCard.jpg",0) -- bg_showCard -- bg_teamget
    -- self._kapaiBg:setVisible(false)
    -- self._kapaiBg:setPosition(cc.p(0,0))
    
    -- self:addChild(self._kapaiBg,-10)
    -- self._kapaiBg:setPosition(-MAX_SCREEN_WIDTH/2+self._bg:getContentSize().width/2,-MAX_SCREEN_HEIGHT/2+self._bg:getContentSize().height/2)
    -- self._bg:addChild(self._kapaiBg,-10)
	self:resetBg(false)

    self._shareNode = require("game.view.share.GlobalShareBtnNode").new({mType = "ShareTeamModule", curType = 1})
    self._shareNode:setPosition(ADOPT_IPHONEX and 185 or 85, 57)
    self._shareNode:setCascadeOpacityEnabled(true, true)
    self:addChild(self._shareNode, 20)
end

function GlobalShowCardDialog:resetBg( showTeam )
	-- if not showTeam then
		-- self._kapaiBg:loadTexture("asset/bg/bg_showCard.jpg",0)
		-- self._kapaiBg:setBrightness(-30)
	-- else
	-- 	self._kapaiBg:loadTexture("asset/bg/bg_teamget.jpg",0)
	-- end
	local xscale = MAX_SCREEN_WIDTH / self._allBg:getContentSize().width
    local yscale = MAX_SCREEN_HEIGHT / self._allBg:getContentSize().height
    if xscale > yscale then
        self._allBg:setScale(xscale)
    else
        self._allBg:setScale(yscale)
    end
    self._allBg:setBrightness(-30)
    -- self._kapaiBg:setAnchorPoint(cc.p(0,0))
    -- self._kapaiBg:setPosition(-MAX_SCREEN_WIDTH/2+480,-MAX_SCREEN_HEIGHT/2+320)
end

-- 接收自定义消息
function GlobalShowCardDialog:reflashUI(data)
	audioMgr:playSound("NewCreature")
	 -- 加转化描述 16.7.4 by guojun
    if data.changeNum then
        local changeText = ccui.Text:create()
        changeText:setFontSize(20)
        changeText:setFontName(UIUtils.ttfName)
        changeText:setString("已获得此兵团，无损转换为".. data.changeNum .."个碎片")
        changeText:setColor(cc.c3b(255, 255, 255))
        changeText:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        changeText:setPosition(cc.p(480,60))
        changeText:setOpacity(0)
        changeText:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.FadeIn:create(0.5)))
        self._bg:addChild(changeText,999)
        self._changeNum = data.changeNum
    end
	local toolD = tab:Tool(data.itemId)
	print(data.itemId)
	dump(data)
    --由于team表中的新阵营加了超出4位数的结构，所以这里通过以前的方法获取碎片数据就有问题了 dongcheng 2018.6.2
--    local teamD = tab:Team(data.itemId - 3000)
	local teamD = tab:Team(tonumber(string.sub(data.itemId, 2)))
	if not teamD then
		-- local 
	end
	local name = lang(teamD.name) or "不知名卡片"
	self._name:setString(name)
	self._name:setFontName(UIUtils.ttfName)
	self._name:setColor(cc.c3b(255, 243, 174))
    self._name:enable2Color(1, cc.c4b(240, 165, 40, 255))
    self._closeLab:setColor(cc.c3b(248, 255, 252))
	self._closeLab:enableOutline(cc.c4b(65,65,65,255),2)
	-- self._title:loadTexture("title_gongxihuode.png",1)
	self._callback = data.callback
	local mcMgr = MovieClipManager:getInstance()
    self._showTeam = data.showTeam
    self._itemId = data.itemId
    local teamId = tonumber(string.sub(self._itemId,2))
    if teamId == 102 or teamId == 106 then
    	self._shareNode:setVisible(false)
    end
    mcMgr:loadRes("getteamanim", function ()
    	if self.preAnim then
        	self:preAnim()
        end
    end, RGBAUTO)
    -- 碎片转化规则
    local cardStar = teamD.starlevel
    if data.changeNum then
    	local num = data.changeNum 
    	if num >= 80 then
    		cardStar = math.max(cardStar,3)
		elseif num >= 30 then
			cardStar = math.max(cardStar,2)
		elseif num >= 10 then
			cardStar = math.max(cardStar,1)
		end
	end
    local param = {teamD = teamD,  star = cardStar}
    local card = CardUtils:createTeamCard(param)
    card:setPosition(103, 104)
    card:setScale(0.96,0.955)
    -- card:setCascadeOpacityEnabled(true)
    self._card:addChild(card)
    self._card:setVisible(false)
	-- self:showBgAnim(true)
end

-- -- 先展示拼碎片界面
function GlobalShowCardDialog:preAnim( show )
	local mcCardShow = mcMgr:createViewMC( "kaipaichuxian_flashcardkaipaichuxian", false, false, function (_, sender)
        -- self:close()
        -- UIUtils:reloadLuaFile("league.LeagueOpenFlyView")
    end,RGBA8888)
    mcCardShow:setPosition(480,320)
    mcCardShow:addCallbackAtFrame(40,function( )
        self._card:setVisible(true)
        self:animBegin(show)
    end)
    self._bg:addChild(mcCardShow,99)
end

function GlobalShowCardDialog:animBegin( show )
	-- if show then
	
	--[[
		local mc =  mcMgr:createViewMC("shang_getteamanim", true, false, function (_, sender)
	        -- sender:gotoAndPlay(80)
	        sender:removeFromParent()
	    end)
	    mc:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2)
	    -- self._mcs[name] = mc
	    self:addChild(mc,-1)

	    local mc1 =  mcMgr:createViewMC("xia_getteamanim", true, false, function (_, sender)
	        sender:gotoAndPlay(80)
	        -- sender:removeFromParent()
	    end)
	    local xscale = MAX_SCREEN_WIDTH / 960
	    local yscale = MAX_SCREEN_HEIGHT / 640
	    if xscale > yscale then
	        mc1:setScale(xscale)
	    else
	        mc1:setScale(yscale)
	    end
	    mc1:setAnchorPoint(cc.p(0,0))
    	mc1:setName("xia")
	    mc1:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2)
	    self:addChild(mc1,-1)

	    local mc2 = mcMgr:createViewMC("zhong_getteamanim", false, true
	    -- 	, function (_, sender)
	    --     -- sender:gotoAndPlay(80)
	    --     sender:removeFromParent()
	    -- end
	    )
	    mc2:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2)
	    self:addChild(mc2,-1)

     --    local mc3 = mcMgr:createViewMC("zhongjianfazhen_getteamanim", false, true
	    -- -- 	, function (_, sender)
	    -- --     -- sender:gotoAndPlay(80)
	    -- --     sender:removeFromParent()
	    -- -- end
	    -- )
	    -- mc3:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2-30)
	    -- self:addChild(mc3,-1)
	    --]]
        -- self._card:setVisible(false)
        -- self._card:setScale(0.5)
        -- self._card:setCascadeOpacityEnabled(true)
	    -- self._card:setOpacity(0)
	    ScheduleMgr:delayCall(100, self, function( )
	    	if tolua.isnull(self._card) then return end
	    	self._card:setBrightness(0)
	    	self._card:setScale(1)
	    	self._card:runAction(
	    		cc.Spawn:create(
		    		cc.DelayTime:create(0),
		    		-- cc.FadeIn:create(0.2),
		    		cc.Sequence:create(
		    			cc.ScaleTo:create(0.2,1),
		    			-- cc.ScaleTo:create(0.3,1),
		    			cc.CallFunc:create(function( )
		    				self._card:setVisible(true)
		    				if self._showTeam then
		    					audioMgr:playSound("Turn")
		    					ScheduleMgr:delayCall(500, self, function ( )
			    					self._card:setBrightness(40)
			    					self._card:setCascadeOpacityEnabled(true,true)
		    						self._card:runAction(cc.Spawn:create(cc.FadeOut:create(0.5),cc.Sequence:create(cc.ScaleTo:create(0.15,1.2),cc.ScaleTo:create(0.35,0.6),cc.CallFunc:create(function ( )
		    							-- self:resetBg(true)
		    						end))))
                                    local mc2 = mcMgr:createViewMC("choukahuodeguang_flashchoukahuode", true, false
                                    )
                                    -- mc2:setHue(80)
                                    -- mc2:setSaturation(-30)
                                    mc2:setPosition(480, 310)
                                    self._bg1:addChild(mc2,0)
                                    -- local children = self._bg:getChildren()
	    							-- for k,v in pairs(children) do
	    							-- 	if v ~= self._card then
	    							-- 		v:runAction(cc.FadeOut:create(0.6))
	    							-- 	end
    								-- end	
	    						end)
	    						ScheduleMgr:delayCall(900, self, function ( )
			    					self._title:setScale(2)
			    					self._title:runAction(cc.Spawn:create(cc.FadeIn:create(0.3),cc.Sequence:create(CCScaleTo:create(0.15, 0.6),
										CCScaleTo:create(0.05, 1))))
	    							self._bg:setVisible(false)
	    							-- self._bg:runAction(cc.FadeOut:create(0.5))
	    							self._bg1:setOpacity(0)	
				    				self._bg1:setVisible(true)
				    				self._bg1:runAction(cc.FadeIn:create(1))	
	    							self._name = self:getUI("bg1.name")
				    				local des1 = self:getUI("bg1.des1")
				    				local teamId = tonumber(string.sub(self._itemId,2))
			    					self:initTeamDes(teamId)
				    				local teamD = tab:Team(teamId or 101)
				    				local outStr = lang("CARDDES_"..teamD.carddes)
				    				if outStr then
					    				des1:setString("兵团特征：" .. outStr)
				    				else
				    					des1:setVisible(false)
				    				end
				    				self:showStar(teamD.starlevel)
				    				local teamVolume = self._modelMgr:getModel("TeamModel"):getTeamVolume({teamId = teamId})--{25,16,9,4,1}
									local teamNode = TeamUtils.showTeamRoles(teamId,1 or teamVolume[tonumber(teamD.volume)])
									teamNode:setPosition(self._bg1:getContentSize().width/2, self._bg1:getContentSize().height/2-30)
									-- teamNode:setBrightness(40)
									teamNode:setScale(0.8)
									self._closeLab:runAction(cc.FadeIn:create(0.3))
									teamNode:setCascadeOpacityEnabled(true,true)
									teamNode:setOpacity(0)
									teamNode:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeIn:create(0)),cc.CallFunc:create(function()
										teamNode:setBrightness(80)
					                    local brigthness = 80
					                    local opacity = 15
					                    teamNode:runAction(cc.Repeat:create(
					                        cc.Sequence:create(
					                            cc.DelayTime:create(0.02),
					                            cc.CallFunc:create(function(  )
					                                brigthness = brigthness - 5
					                                teamNode:setBrightness(brigthness)
					                                opacity = 15+opacity
					                                teamNode:setOpacity(opacity)
					                            end)
					                        )
					                    ,16))
										self._closePanel:setTouchEnabled(false)
										local isClose = false
										self:registerClickEvent(self._closePanel, function( )
											if isClose == false then
												isClose = true
												if teamD.zuhe then
													DialogUtils.showZuHe(tonumber(string.sub(self._itemId,2)))
							    					-- self._viewMgr:showDialog("global.DialogTeamRecommandView",{teamId = tonumber(string.sub(self._itemId,2))})
							    				end
												self:close(true,self._callback)
												UIUtils:reloadLuaFile("global.GlobalShowCardDialog")
											end
										end)
										self._shareNode:registerClick(function()
											return {moduleName = "ShareTeamModule", teamId = teamId, isHideBtn = true}
											end)
									end)))
									-- local children = teamNode:getChildren()
	    				-- 			for k,v in pairs(children) do
	    				-- 				if v ~= self._card then
	    				-- 					v:setBrightness(40)
	    				-- 					v:runAction(cc.Sequence:create(cc.FadeIn:create(0.3),cc.CallFunc:create(function( )
									-- 			v:setBrightness(0)
									-- 		end)))
	    				-- 				end
    					-- 			end	
									-- teamNode:setScale(1)
									self._bg1:addChild(teamNode,1)
	    						end)
							else
								local action = cc.Sequence:create(cc.DelayTime:create(0.7),cc.ScaleTo:create(0.2,0.8))
								self._card:runAction(action)
								audioMgr:playSound("Turn")
		    					ScheduleMgr:delayCall(2000, self, function ( )
			    	-- 				self._card:setBrightness(40)
			    	-- 				self._card:setCascadeOpacityEnabled(true,true)
		    		-- 				self._card:runAction(cc.Spawn:create(cc.FadeOut:create(0.5),cc.Sequence:create(cc.ScaleTo:create(0.15,1.2),cc.ScaleTo:create(0.35,0.6))))
        --                             local toolD = tab:Tool(self._itemId)
        --                             local item = IconUtils:createItemIconById({itemId = self._itemId,num = self._changeNum,itemData = toolD,effect = false })
        --                             item:setPosition(cc.p(self._bg:getContentSize().width/2-55,self._bg:getContentSize().height/2-55))
        --                             self._bg:addChild(item,3)
        --                             item:setOpacity(0)
        --                             item:runAction(cc.FadeIn:create(1))
									local isClose = false
									self:registerClickEvent(self._closePanel, function( )
										if isClose == false then
											isClose = true
											if self._callback then
												self._callback()
											end
											self:close(true)
											UIUtils:reloadLuaFile("global.GlobalShowCardDialog")
										end
									end)

									self._shareNode:registerClick(function()
										local teamId = tonumber(string.sub(self._itemId,2))
										return {moduleName = "ShareTeamModule", teamId = teamId, isHideBtn = true}
									end)
	    						end)
			    			end
		    			end)
	    			)
		    	)
	    	)
		end)
	-- end
end

local starInfos = {
	{{pos = cc.p(0,50),scale = 0.8}},

	{{pos = cc.p(-25+25,50),scale = 0.8},{pos = cc.p(25+25,50),scale = 0.8}},
	{{pos = cc.p(-40+40,50),scale = 0.8},{pos = cc.p(0+40,50),scale = 0.8},{pos = cc.p(40+40,50),scale = 0.8}},
	-- {{pos = cc.p(-40,45),scale = 0.8},{pos = cc.p(0,55),scale = 1},{pos = cc.p(40,45),scale = 0.8}},
}

function GlobalShowCardDialog:showStar( starlevel )
	if not tonumber(starlevel) then return end
	local starInfo = starInfos[starlevel]
	local bgW,bgH = self._starBg:getContentSize().width,self._starBg:getContentSize().height
	for i,info in ipairs(starInfo) do
		local star = ccui.ImageView:create()
		star:loadTexture("globalImageUI6_star1.png",1)
		star:setPosition((i-1)*55,40)
		star:setAnchorPoint(0,0.5)
		-- star:setScale(info.scale)
		self._starBg:addChild(star)
	end
end

local classColorTab = { -- 攻防突射魔
	[1] = {color=cc.c4f(254, 243, 240, 255),color2 = cc.c4b(255, 70, 40, 255)},
	[2] = {color=cc.c4f(255, 254, 244, 255),color2 = cc.c4b(255, 185, 17, 255)},
	[3] = {color=cc.c4f(244, 252, 255, 255),color2 = cc.c4b(46, 203, 255, 255)},
	[4] = {color=cc.c4f(241, 249, 245, 255),color2 = cc.c4b(18, 236, 23, 255)},
	[5] = {color=cc.c4f(253, 240, 254, 255),color2 = cc.c4b(237, 241, 231, 255)},
}
function GlobalShowCardDialog:initTeamDes( teamId )
	local teamD = tab:Team(teamId)
	local panels = {}
	local leftPanel = self:getUI("bg1.leftPanel")
	table.insert(panels,leftPanel)
	local rightTopPanel = self:getUI("bg1.rightTopPanel")
	table.insert(panels,rightTopPanel)
	local leftBPanel = self:getUI("bg1.leftBPanel")
	table.insert(panels,leftBPanel)
	local rightBottomPanel = self:getUI("bg1.rightBottomPanel")
	table.insert(panels,rightBottomPanel)
	local showSkillD = SkillUtils:getTeamSkillByType(teamD.skill[teamD.skillshow][2], teamD.skill[teamD.skillshow][1]) 
	local processSkillDes = "[color=ffffff,fontsize=22,outlinecolor=424242,outlinesize=1]" .. string.gsub(lang(showSkillD.des1),"%b[]","") .."[-]"
	local desStrs = {lang(teamD.des),lang("CARDDES_"..teamD.carddes),lang(teamD.dingwei),processSkillDes}
	-- local leftBottomPanel = self:getUI("bg1.leftBottomPanel")
	-- table.insert(panels,leftBottomPanel)
	local titleBgs = {}
	local leftBottomPanelTitleBg = self:getUI("bg1.leftBottomPanel.titleBg")
	leftBottomPanelTitleBg:setOpacity(100)
	leftBottomPanelTitleBg:setColor(cc.c3b(0, 0, 0))
	table.insert(titleBgs,leftBottomPanelTitleBg)
	local leftBottomPanelTitle = self:getUI("bg1.leftBottomPanel.title")
	leftBottomPanelTitle:setColor(cc.c3b(177, 255, 239))--cc.c3b(248, 255, 252))
	leftBottomPanelTitle:enableOutline(cc.c4b(65,65,65,255),2)
	leftBottomPanelTitle:setFontName(UIUtils.ttfName)
	for i,panel in ipairs(panels) do
		local title = panel:getChildByFullName("title")
		local des = panel:getChildByFullName("des")
		-- local titleBg = panel:getChildByFullName("titleBg")
		-- titleBg:setPureColor(cc.c3b(128, 128, 128))
		-- titleBg:setOpacity(100)
		-- titleBg:setColor(cc.c3b(0, 0, 0))
		-- table.insert(titleBgs,titleBg)
		-- titleBg:setBrightness(180)
		-- title:setColor(cc.c3b(177, 255, 239))--cc.c3b(248, 255, 252))
		-- title:enableOutline(cc.c4b(65,65,65,255),2)
		-- title:setFontName(UIUtils.ttfName)
		des:setFontName(UIUtils.ttfName)
		-- des:enableOutline(cc.c4b(65,65,65,255),1)
		if i < 4 then
			des:setString(desStrs[i])
		else
			des:setString("")
			local skillDes = SkillUtils:handleSkillDesc(desStrs[i],1) or ""
			print(skillDes,"skillDes...")
		skillDes = string.gsub(skillDes, "fontsize=22", "fontsize=16") -- 
	    skillDes = string.gsub(skillDes, "fontsize=17", "fontsize=16") -- 
	    skillDes = string.gsub(skillDes, "fontsize=20", "fontsize=16") -- 
	    skillDes = string.gsub(skillDes, "fontsize=18", "fontsize=16") -- 
	    skillDes = string.gsub(skillDes, "fontsize=24", "fontsize=16") -- 
	    skillDes = string.gsub(skillDes, "color=ffffff", "color=aaa082")
	    skillDes = string.gsub(skillDes, "color=3d1f00", "color=aaa082")
	    skillDes = string.gsub(skillDes, ",outlinecolor=3c1e0a00", "")
	    skillDes = string.gsub(skillDes, ",outlinecolor=424242", "")
	    skillDes = string.gsub(skillDes, ",outlinesize=1", "")
	    skillDes = string.gsub(skillDes, ",outlinesize=2", "")
			local rtx = RichTextFactory:create(skillDes,160,145)
		    rtx:formatText()
			local realH = rtx:getRealSize().height
		    local h = rtx:getInnerSize().height
		    rtx:setVerticalSpace(7)
		    rtx:setName("rtx")
		    rtx:setPosition(cc.p(75,70))
		    rtx:setSaturation(0)
		    des:addChild(rtx,99)
		    -- UIUtils:alignRichText(rtx,{vAlign = "top"})
		    -- rtx:setPositionY(rtx:getPositionY()+(145-realH)/2-5)
		    rtx:setCascadeOpacityEnabled(true,true)
		    local skillNode = panel:getChildByFullName("skillNode")
		    skillNode:setCascadeOpacityEnabled(true,true)
		    local icon = IconUtils:createTeamSkillIconById({teamSkill = showSkillD, eventStyle = 0})
		    icon:setPosition(-20,-15)
		    skillNode:addChild(icon)
		end
	end
	-- [[单独设置左下 信息 板子内容
	local zizhiNum = teamD.zizhi or 1
	zizhiNum = self._modelMgr:getModel("TeamModel"):getTeamZiZhiText(zizhiNum)
	local leftBottomPanel = self:getUI("bg1.leftBottomPanel")
	local settingTab = {
		{name="zhenying",value=lang("RACE_" .. (teamD.race[1] or 101))},
		{name="zizhi",value=zizhiNum},
		{name="num",value=self._modelMgr:getModel("TeamModel"):getTeamVolume({teamId = teamD.id})},
		{name="zhenyingdes",value="阵营："},
		{name="zizhides",value="资质："},
		{name="numdes",value="人数："},
		{name="zizhiImg",texture="globalImageUI_zizhi_" .. ((teamD.zizhi or 1)+12) .. ".png"},
	}
	for i,v in ipairs(settingTab) do
		local lab = leftBottomPanel:getChildByFullName(v.name)
		if v.value then
			lab:setString(v.value)
			lab:setFontName(UIUtils.ttfName)
			-- lab:enableOutline(cc.c4b(65,65,65,255),1)
			if v.color2 then
			end
		else
			if not teamD.zizhi or teamD.zizhi == 1 then
				lab:setVisible(false)
			else
				lab:setVisible(true)
				lab:loadTexture(v.texture,1)
				lab:setOpacity(0)
				lab:setScale(4)
				lab:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.Spawn:create(
					cc.FadeIn:create(0.2),
					cc.ScaleTo:create(0.2,1)
				)))

			end
		end
	end
	local zizhiTemp = leftBottomPanel:getChildByFullName("zizhi")
	local zizhiImgTemp = leftBottomPanel:getChildByFullName("zizhiImg")
	zizhiImgTemp:setPositionX(zizhiTemp:getPositionX() + zizhiTemp:getContentSize().width + zizhiImgTemp:getContentSize().width / 2)
	-- 兵团类型
	local classImg = rightTopPanel:getChildByFullName("class")
	classImg:loadTexture(IconUtils.iconPath .. teamD.classlabel .. ".png",1)
	classImg:setScale(0.8)
	local classTxt = rightTopPanel:getChildByFullName("des")
	local classColor = classColorTab[teamD.class]
	if classColor then
		classTxt:setColor(classColor.color)
		classTxt:enable2Color(1,classColor.color2)
	end
	--]]
	self:showTeanInfoAnim()
	-- local maxWidth = 240
 --    local step = 1
 --    local stepConst = 20
 --   	local titleWidth,titleHeight = titleBgs[1]:getContentSize().width,titleBgs[1]:getContentSize().height
 --    local sizeSchedule
 --    sizeSchedule = ScheduleMgr:regSchedule(10,self,function( )
 --        stepConst = stepConst+step
 --        if stepConst >= 30 then 
 --            stepConst = -15
 --        end
 --        titleWidth = titleWidth+stepConst
 --        if titleWidth < maxWidth then
 --            self._bg:setContentSize(cc.size(titleWidth,titleHeight))
 --            for k,v in pairs(titleBgs) do
 --            	v:setContentSize(cc.size(titleWidth,titleHeight))
 --            end
 --        else
 --            for k,v in pairs(titleBgs) do
 --            	v:setContentSize(cc.size(maxWidth-5,titleHeight))
 --            end
 --            ScheduleMgr:unregSchedule(sizeSchedule)
 --        end
 --    end)
 --    self._titleSchedule = sizeSchedule
end

-- 兵团信息动画
function GlobalShowCardDialog:showTeanInfoAnim( )
	local moveFromBorder = function( panel,fromX,toX,delay,callback )
		panel:setCascadeOpacityEnabled(true,true)
		panel:setOpacity(0)
		panel:setPositionX(fromX)
		panel:runAction(cc.Sequence:create(
			cc.DelayTime:create(delay),
			cc.Spawn:create(
				cc.FadeIn:create(0.3),
				cc.MoveTo:create(0.3,cc.p(toX,panel:getPositionY()))
			),
			cc.CallFunc:create(function( )
				if callback then
					callback()
				end
			end)
		))
	end
	local moveDistance = 300
	local moveConfig = {
		-- 左边三个
		{name = "bg1.leftPanel",fromX = -moveDistance,toX = 17,delay = 0,callback = function( )
			
		end},
		{name = "bg1.leftBPanel",fromX = -moveDistance,toX = 17,delay = 0.05,callback = function( )
			
		end},
		{name = "bg1.rightBottomPanel",fromX = -moveDistance,toX = 17,delay = 0.1,callback = function( )
			
		end},
		-- 右边三个
		{name = "bg1.name",fromX = 669+moveDistance,toX = 669,delay =0,callback = function( )
			
		end},
		{name = "bg1.leftBottomPanel",fromX = 657+moveDistance,toX = 657,delay = 0.05,callback = function( )
			
		end},
		{name = "bg1.rightTopPanel",fromX = 685+moveDistance,toX = 685,delay = 0.1,callback = function( )
			
		end},
		
	}
	for i,conf in ipairs(moveConfig) do
		local panel = self:getUI(conf.name)
		if panel then
			moveFromBorder(panel,conf.fromX,conf.toX,conf.delay)
		end
	end
end

function GlobalShowCardDialog:onDestroy( )
	if self._titleSchedule then
		ScheduleMgr:unregSchedule(self._titleSchedule)
		self._titleSchedule = nil
	end
	self.super.onDestroy(self)
end

return GlobalShowCardDialog