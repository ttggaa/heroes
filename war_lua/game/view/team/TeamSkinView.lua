--[[
 	@FileName 	TeamSkinView.lua
	@Authors 	cuiyake
	@Date    	2018-04-27 15:20:06
	@Email    	<cuiyake@playcrad.com>
	@Description   兵团皮肤UI
--]]
local AnimAP = require "base.anim.AnimAP"
local TeamSkinView = class("TeamSkinView",BasePopView)
function TeamSkinView:ctor(param)
    self.super.ctor(self)
    self.initAnimType = 2
    --self._heroData = param.heroData or {}
    self._teamData = param.teamData or {}
    self._isHaveTeam = param.isHaveTeam or true
    self._closeCallBack = param.closeCallBack

    self._userModel = self._modelMgr:getModel("UserModel")
    self._skinGet = 0 -- 1.经典 2.觉醒 3.运营活动
end

function TeamSkinView:getAsyncRes()
    return 
    {
        {"asset/ui/heroSkin.plist", "asset/ui/heroSkin.png"},
    }
end


function TeamSkinView:onShow()
	self._viewMgr:enableScreenWidthBar()
end

function TeamSkinView:onHide()
	self._viewMgr:disableScreenWidthBar()
end

function TeamSkinView:onDestroy()
	self._viewMgr:disableScreenWidthBar()
end

-- 第一次被加到父节点时候调用
function TeamSkinView:onAdd()

end

function TeamSkinView:onTop()
end
-- 初始化UI后会调用, 有需要请覆盖
function TeamSkinView:onInit()	

    -- 存储在本地的点击数据
    self._redInfo = {}
    local jsonStr = SystemUtils.loadAccountLocalData("TEAMSKIN_REDNOTICE_CLICKDATA" .. self._teamData.teamId)
    if jsonStr and jsonStr ~= "" and jsonStr ~= "null" then            
        self._redInfo = json.decode(jsonStr)
    else            
        self._redInfo = {}
    end
    self._attrTextColor = {
    	[1] = cc.c4b(255, 255, 255, 255),
    	[2] = cc.c4b(75, 235, 255, 255),
    	[3] = cc.c4b(255, 120, 255, 255),
    	[4] = cc.c4b(250, 146, 26, 255),
	}
    self._attrText = {[1] = "攻击",[2] = "生命"}

	self._closeBtn = self:getUI("btn_return")
	self:registerClickEvent(self._closeBtn, function ( )
        if self._closeCallBack then
        	self._closeCallBack()
        end
        self:close(true)
        UIUtils:reloadLuaFile("team.TeamSkinView")
    end)
    
	

	self._allSkinData = {}
	self:initSkinData()
	-- dump(self._allSkinData,"self._allSkinData",5)

    self._bg = self:getUI("bg")

    self._modelPanel = self:getUI("modelPanel")
    self._modelPanel:setVisible(false)
    self._modelPanel:setSwallowTouches(false)
    self:registerClickEvent(self._modelPanel, function ( )
        if self._modelPanel:isVisible() then
        	self._modelPanel:setVisible(false)
        	self._modelPanel:setSwallowTouches(false)
        end
    end)
    self:initModelPanel()

    self._hideTouchPanel = self:getUI("hideTouchPanel")
	self._hideTouchPanel:setSwallowTouches(false)
	self._isNotHide = true
	self:registerClickEvent(self._hideTouchPanel, function ( )
        -- self._modelPanel:setSwallowTouches(self._isNotHide)
        self:updateItemVisible()
    end)


    self._cardTb = {}
    self._cardPanel = self:getUI("bg.cardPanel")
    self._cardPanel:setVisible(true)
    self._roleCard = self:getUI("bg.roleCard")
    self._roleCard:setVisible(false)

    -- self._scrollView = self:getUI("bg.scrollView")
    -- self._cardW = 147
    -- local cardNum = table.nums(self._allSkinData)
    -- self._scroViewW = self._scrollView:getContentSize().width
    -- self._scrollW = self._cardW*(cardNum+1)*0.8 + self._cardW
    -- print("=========================scrollW====",self._scrollW)
    -- self._scrollView:setInnerContainerSize(cc.size(self._scrollW,self._scrollView:getContentSize().height))

    -- self._scrollView:addEventListener(function(sender, eventType)
    --     if eventType == 4 then
    --     	-- on scrolling
    --         self:scrollViewScrolling()
    --     end
    -- end)
	self._subPos = {
		[1] = 100,
		[2] = 50,
	}
    --查找到当前皮肤，初始化scrollView
    self:initCardPanel()

    self._bgImg = self:getUI("bg.bgImg")
    self._bgImg:setScale(1.11)    
    self._desImg = self:getUI("bg.desImg")
    self._desImg:setVisible(true)
    self._titleImg = self:getUI("bg.titleImg")
    self._titleLabel = self:getUI("bg.titleLabel")
    self._teambg = self:getUI("bg.bgImg.teambg")

	-- 首进定位到当前装备卡片
	-- self._currSkinIdx - 1 -> 需要移动的卡片数量
    self:updateRoleCardPos(self._currSkinIdx - 1)
    self:updateInfoPanel(self._allSkinData[self._currSkinIdx])

    self._bg:setSwallowTouches(false)
    self._desImg:setSwallowTouches(false)
	self._titleImg:setSwallowTouches(false)

	if ADOPT_IPHONEX then
	    local parameter = self._closeBtn:getLayoutParameter()
	    parameter:setMargin({left=0,top=0,right=125,bottom=0})
	    self._closeBtn:setLayoutParameter(parameter)
	    local infoBg = self:getUI("modelPanel.infoBg")
	    infoBg:setPositionX(800)
	end

end

--点击隐藏或显示
function TeamSkinView:updateItemVisible()
	self._isNotHide = not self._isNotHide
	self._desImg:setVisible(self._isNotHide)
	self._desTxt:setVisible(self._isNotHide)
	--self._titleImg:setVisible(self._isNotHide)
    self._titleLabel:setVisible(self._isNotHide)
	self._cardPanel:setVisible(self._isNotHide)
	self._closeBtn:setVisible(self._isNotHide)
end

-- 初始化左下卡片
function TeamSkinView:initCardPanel( )
	local zOrderNum = 5
	local index = 1
	local subW = 40 --self._cardW*0.8 + 2
	local initPosX = self._cardPanel:getContentSize().width - 75 --subW + self._cardW*0.8*0.5
	local posX = initPosX
	dump(self._allSkinData)
	-- 初始卡片位置
	self._cardDataTb = {}
	for k,v in pairs(self._allSkinData) do
		local skinGet = v.skinget or 1
		local roleCard = self._roleCard:clone()
		roleCard:setVisible(true)
		--local roleImg = roleCard:getChildByFullName("roleImg")
		--roleImg:loadTexture("asset/uiother/cteam/" .. v.teamskinSelection .. ".jpg")  --配表
        -- 背景
        local centerx,centery = roleCard:getContentSize().width /2 ,roleCard:getContentSize().height /2
        local mask = cc.Sprite:create("asset/uiother/cteam/cardt_framebg2.png")
        mask:setPosition(centerx, centery)
        mask:setName("mask")
        mask:setScaleX(0.88)
        mask:setScaleY(0.95)
        -- 裁剪框
        local cardClip = cc.ClippingNode:create()
        cardClip:setInverted(false)
        cardClip:setStencil(mask)
        cardClip:setAlphaThreshold(0.2)
        cardClip:setName("cardClip")
        cardClip:setAnchorPoint(cc.p(0.5,0.5))
        roleCard:addChild(cardClip,0)

        local roleImg = cc.Sprite:create("asset/uiother/cteam/" .. v.teamskinSelection .. ".jpg")
        roleImg:setName("roleImg")
        cardClip:addChild(roleImg, 1)     -- 1-2
        -- if skinGet ~= 9 then
    	roleImg:setAnchorPoint(1, 0)
    	roleImg:setPosition(centerx * 2+5, 0) 
        -- else
        -- 	roleImg:setScale(mask:getContentSize().width / roleImg:getContentSize().width)
        -- 	roleImg:setAnchorPoint(0.5, 0.5)
        -- 	roleImg:setPosition(centerx, centery)

        -- 	local roleBg = cc.Sprite:create("asset/uiother/cteam/bg_teamSkin.jpg")
        -- 	roleBg:setName("roleBg")
        -- 	cardClip:addChild(roleBg)
        -- 	roleBg:setAnchorPoint(0.5, 0.5)
        -- 	roleBg:setPosition(centerx, centery)
        -- end

		-- roleCard:loadTexture("heroSkin_card_26010202.png",1) 
		-- 属性标志
		local flagImg = roleCard:getChildByFullName("flagImg")
		flagImg:setVisible(false)
		local qualityNum = 1
		if v.quality and v.quality ~= 1 then 
			flagImg:setVisible(true)
			flagImg:loadTexture("heroSkin_skinAttr_flag" .. v.quality .. ".png",1)
			qualityNum = v.quality
		end
		-- 属性描述
		local attrBg = roleCard:getChildByFullName("infoBg.attrBg")
		attrBg:setVisible(false)
		-- dump(v)
		if v.addteamAttr then 
			local desStr = (v.state and v.state == 0) and "解锁加成：" or "收集加成："
			attrBg:setVisible(true)
			local attrDes = attrBg:getChildByFullName("attrDes")
			attrDes:setString(desStr)
			local attrText = attrBg:getChildByFullName("attrText")			
			attrDes:setColor(self._attrTextColor[qualityNum])
			attrText:setColor(self._attrTextColor[qualityNum])
			if table.nums(v.addteamAttr) == 4 then
				attrText:setString("全属性" .. "+" .. v.addteamAttr[1][2])
			else
				attrText:setString(self._attrText[v.addteamAttr[1][1]] .. "+" .. v.addteamAttr[1][2])
			end
		end
		-- local shine = v.shine
		-- -- 未解锁
		-- if shine and v.state and v.state ~= 0 then
		-- 	--self._effectTb
		-- 	for k,v in pairs(shine) do
		-- 		local mask = cc.Sprite:create("asset/uiother/dhero/d_Catherine.jpg")
		-- 		local clipNode = cc.ClippingNode:create()
		-- 	    clipNode:setPosition(93,158)
		-- 	    clipNode:setContentSize(cc.size(147, 239))
			     
		-- 	    mask:setAnchorPoint(0.5,0.5)
		-- 	    clipNode:setStencil(mask)
		-- 	    clipNode:setAlphaThreshold(0.05)
		-- 	    -- clipNode:setInverted(true)
		-- 	    local mc = mcMgr:createViewMC(v, true,false)
			   
		-- 	    -- clipNode:setScale(0.5)
		-- 	    clipNode:addChild(mc)
		-- 	    roleImg:addChild(clipNode,1)
		-- 	end
		-- end

		local roleName = roleCard:getChildByFullName("roleName")
		roleName:setString(lang(v.skinword))

		-- 红点
		local redImg = roleCard:getChildByFullName("redImg")
		redImg:setVisible(v.isRed)
		redImg:setZOrder(20)

		local lockPanel = roleCard:getChildByFullName("lockPanel")
		lockPanel:setSwallowTouches(false)
		lockPanel:setVisible(v.state and v.state == 0)
		local tipsTxt = roleCard:getChildByFullName("lockPanel.tipsTxt")
		tipsTxt:setString(lang(v.teamgetword))
		local unLockPanel = roleCard:getChildByFullName("unLockPanel")
		unLockPanel:setSwallowTouches(false)
		unLockPanel:setVisible(v.state and v.state ~= 0)
		
		local usedTxt = roleCard:getChildByFullName("unLockPanel.usedTxt")
		usedTxt:setVisible(v.state and v.state == 2)
		usedTxt:setColor(UIUtils.colorTable.ccColorQuality2)
		usedTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
		local getTxt = roleCard:getChildByFullName("unLockPanel.getTxt")
		getTxt:setVisible(v.state and v.state == 1)
		getTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

		local roleFrame = roleCard:getChildByFullName("roleFrame")
		roleFrame:setVisible(index == 1)

		local infoBg = roleCard:getChildByFullName("infoBg")
		infoBg:setZOrder(-1)
		infoBg:setVisible(index == 1)
		local useBtn = roleCard:getChildByFullName("infoBg.useBtn")
		useBtn:setVisible(v.state and v.state == 1 and self._isHaveTeam)
		self:L10N_Text(useBtn)
        local goBtn = roleCard:getChildByFullName("infoBg.goBtn")
		-- goBtn:setVisible(v.skinget and v.skinget == 3 and v.state == 0)
		goBtn:setVisible(false)
		self:L10N_Text(goBtn)
		local titleTxt = roleCard:getChildByFullName("infoBg.titleTxt")
		titleTxt:setColor(cc.c4b(255,255,255,255))
        titleTxt:enable2Color(1, cc.c4b(253,229,123,255))
        titleTxt:setString((v.state and v.state ~= 0) and "已解锁:" or "未解锁:")

        local skinAnim = roleCard:getChildByFullName("skinAnim")
        if skinAnim then
        	skinAnim:removeFromParent()
        end
        if skinGet == 9 then
        	skinAnim = mcMgr:createViewMC("yingxiongbiankuangtexiao_yingxiongkuangtexiao", true, false)
        	skinAnim:setName("skinAnim")
        	skinAnim:setZOrder(10)
        	skinAnim:setPosition(roleCard:getContentSize().width / 2 - 5, roleCard:getContentSize().height / 2 + 5)
        	roleCard:addChild(skinAnim)
        end

        -- dump(v,"====>",4)
        for i=1,4 do
        	local desTxt = roleCard:getChildByFullName("infoBg.desTxt" .. i)
        	local img = roleCard:getChildByFullName("infoBg.img" .. i)
        	desTxt:setVisible(false)
			img:setVisible(false)
        	if v.skinFeatures and v.skinFeatures[i] then
        		desTxt:setVisible(true)
				img:setVisible(true)
				desTxt:setColor(UIUtils.colorTable.ccUIBasePromptColor)
				desTxt:setString(lang(v.skinFeatures[i]))
        	end
        end
		
		local scale = 1 - (index-1)*0.1
		roleCard:setScale(scale)

		roleCard:setPosition(posX, 135)
		roleCard.__initPosX = posX
		roleCard.__zOrderNum = zOrderNum
		roleCard.__initIndex = index
		roleCard.__scale = scale
		roleCard.__skinData = v

		local data = {}
		data.__initPosX = posX
		data.__zOrderNum = zOrderNum
		data.__initIndex = index
		data.__scale = scale
		self._cardDataTb[index] = data

		self._cardPanel:addChild(roleCard,zOrderNum)

		if self._subPos[tonumber(k)] then
			posX = posX - self._subPos[tonumber(k)]
		else			
			posX = posX - subW
		end
		index = index + 1
		zOrderNum = zOrderNum - 1

		table.insert(self._cardTb, roleCard)

		roleCard:setTouchEnabled(true)
		local soundBtn = roleCard:getChildByFullName("infoBg.soundBtn")	    
		soundBtn:setVisible(false)
		if v.skinSound then
			soundBtn:setVisible(true)
			self:registerClickEvent(soundBtn, function ( )
		        -- 播放音效
		        audioMgr:playSound(v.skinSound)
		    end)
		end

		self:registerClickEvent(roleCard, function ( )
	        -- 显示更新
	        if roleCard.__initIndex ==  1 then
	        	return
	        end
	        self:changeCardAnim()
	        -- self:updateRoleCardPos(roleCard.__initIndex)
	        -- self:updateInfoPanel(roleCard.__skinData)
	    end)
		local useBtn = roleCard:getChildByFullName("infoBg.useBtn")	    
	    self:registerClickEvent(useBtn, function ( )
	        -- 换肤 更新数据
	        self:changeHeroSkin(roleCard.__skinData)
	    end)

        self:registerClickEvent(goBtn, function ( )
	        
	    end)

	    local infoBtn = roleCard:getChildByFullName("infoBg.infoBtn")	 
	    self:registerClickEvent(infoBtn, function ( )
	        -- 信息面板
	        if not self._modelPanel:isVisible() then
	        	self._modelPanel:setVisible(true)
	        	self._modelPanel:setSwallowTouches(true)
	        	self:updateModelPanel(roleCard.__skinData)
	        end
	    end)
	    if tonumber(k) ~= 1 then
		    local infoBg = roleCard:getChildByFullName("infoBg")
		    local shareBtn = require("game.view.share.GlobalShareBtnNode").new({mType = "ShareTeamSkinModule"})
		    shareBtn:setPosition(246, 30)
		    shareBtn:setCascadeOpacityEnabled(true, true)
		    infoBg:addChild(shareBtn, 100)
		    shareBtn:setVisible(v.state and v.state ~= 0)
		    shareBtn:registerClick(function()
		        return {skinData = roleCard.__skinData,moduleName = "ShareTeamSkinModule",teamId = roleCard.__skinData.teamid,isAsyncRes = false, isHideBtn = false}
		    end)
		end
	end
end


-- 切换动画
function TeamSkinView:changeCardAnim(idx)
	local cIndex = idx
	if not cIndex then
		cIndex = 2
	end
	local cardDataTb = self._cardDataTb
	local cardNum = table.nums(self._cardTb)
	local num = 0
	local skinData = {}
	for k,v in pairs(self._cardTb) do
		num = num + 1
		local roleCard = v	
		local index = roleCard.__initIndex - 1 
		v:setTouchEnabled(false)	
		if index <= 0 then
			local scaleNum = cardDataTb[cardNum].__scale or 1
			local targetPosX = cardDataTb[cardNum].__initPosX
			v:setZOrder(0)
			v:setOpacity(255)
			local frame = v:getChildByFullName("roleFrame")
			frame:setVisible(false)
			local action = cc.Sequence:create(
							cc.Spawn:create(cc.FadeOut:create(0.15),cc.ScaleTo:create(0.15, scaleNum),cc.MoveTo:create(0.15, cc.p(targetPosX,v:getPositionY()))),
							cc.CallFunc:create(function()
								v:setPositionX(targetPosX)
								v:setOpacity(255)
							end))
			v:runAction(action)
			local infoBg = v:getChildByFullName("infoBg")
			infoBg:setVisible(false)
			infoBg:setOpacity(0)
		else			
			local scaleNum = cardDataTb[index].__scale or 1
			local targetPosX = cardDataTb[index].__initPosX
			local frame = v:getChildByFullName("roleFrame")
			frame:setVisible(tonumber(k) == cIndex)
			local action = cc.Sequence:create(
							cc.Spawn:create(cc.ScaleTo:create(0.15, scaleNum),cc.MoveTo:create(0.15, cc.p(targetPosX,v:getPositionY()))),
							cc.CallFunc:create(function()
								
							end))
			v:runAction(action)

			local infoBg = v:getChildByFullName("infoBg")
			local posX = infoBg:getPositionX()
			infoBg:setPositionX(posX - 40)
			local frame = v:getChildByFullName("roleFrame")
			infoBg:setVisible(index == 1)
			frame:setVisible(index == 1)
			if index == 1 then
				skinData = v.__skinData
			end

			infoBg:setOpacity(0)
			infoBg:setCascadeOpacityEnabled(true)
			local infoAc = cc.Sequence:create(
							cc.DelayTime:create(0.1),
							cc.Spawn:create(cc.FadeIn:create(0.2),cc.MoveTo:create(0.2, cc.p(posX,infoBg:getPositionY()))),
							cc.CallFunc:create(function()
								
							end))
			infoBg:runAction(infoAc)

		end
	end

	local tempImg = self._bgImg:clone()
	tempImg:setOpacity(255)
    tempImg:setCascadeOpacityEnabled(true)
	self._bgImg:getParent():addChild(tempImg)

	local tempAc1 = cc.Sequence:create(cc.FadeOut:create(0.3),cc.DelayTime:create(0.1),cc.CallFunc:create(function ()
		-- 更新面板的显示和位置
		self:updateRoleCardPos()
		for k,v in pairs(self._cardTb) do
			v:setTouchEnabled(true)
		end
		tempImg:removeFromParent()
	end))
	tempImg:runAction(tempAc1)

	self:updateInfoPanel(skinData)
	self._bgImg:setOpacity(0)
    self._bgImg:setCascadeOpacityEnabled(true)
	local imgAc2 = cc.Sequence:create(cc.FadeIn:create(0.3),cc.CallFunc:create(function ()
		-- self:updateInfoPanel(skinData)		
	end))
	self._bgImg:runAction(imgAc2)

end

-- 更新卡片位置
function TeamSkinView:updateRoleCardPos(idx)
	-- print("===============updateRoleCardPos==========",index)

	local cardDataTb = self._cardDataTb
	local subNum = idx or 1
	local cardNum = table.nums(self._cardTb)
	for k,v in pairs(self._cardTb) do	
		local roleCard = v	
		local index = roleCard.__initIndex - subNum 

		if index <= 0 then
			index = cardNum + index
		end
		roleCard.__initPosX = cardDataTb[index].__initPosX
		roleCard.__zOrderNum = cardDataTb[index].__zOrderNum
		roleCard.__initIndex = index
		roleCard.__scale = cardDataTb[index].__scale

		roleCard:setScale(roleCard.__scale)
		roleCard:setPosition(roleCard.__initPosX, 135)
		roleCard:setZOrder(roleCard.__zOrderNum)

		-- 更新选中状态
		local roleFrame = roleCard:getChildByFullName("roleFrame")
		roleFrame:setVisible(index == 1)

		local infoBg = roleCard:getChildByFullName("infoBg")
		infoBg:setZOrder(-1)
		infoBg:setVisible(index == 1)

		-- 更新红点信息
		if index == 1 then
			self:updateCardRedInfo(roleCard)
		end

	end
	
end

-- 更新红点的显示及数据
function TeamSkinView:updateCardRedInfo(card)
	if not card or not card.__skinData then return end
	local skinData = card.__skinData
	-- 更新红点信息
	if skinData and skinData.isRed then
		local redImg = card:getChildByFullName("redImg")
		redImg:setVisible(false)
		skinData.isRed = false
		-- 添加到点击数组
		table.insert(self._redInfo,{id=skinData.id})
		local jsonStr = ""
		dump(self._redInfo,"self._redInfo",4)
	    if table.nums(self._redInfo) > 0 then
	        jsonStr = json.encode(self._redInfo)
	    end
	    SystemUtils.saveAccountLocalData("TEAMSKIN_REDNOTICE_CLICKDATA" .. self._teamData.teamId,jsonStr)

	end
end

-- 更新立绘信息
function TeamSkinView:updateInfoPanel(skinData)
	if not skinData then return end
	local posX,posY,scale = 0,0,1
	if skinData.artCoordinate then
	 	posX =  skinData.artCoordinate[1]
		posY =  skinData.artCoordinate[2]
		scale =  skinData.artCoordinate[3]
	end 
	local imgName = skinData.teamskinbackground
    local teamImgName = skinData.skinart2
    if imgName and teamImgName then
    	local filename = "asset/uiother/teamskin/" .. imgName .. ".jpg"
		if cc.FileUtils:getInstance():isFileExist(filename) then
			self._bgImg:loadTexture(filename)
		else
			print("===========have no image==============")
		end

        local teamFileName = "asset/uiother/team/" .. teamImgName .. ".png"
        if cc.FileUtils:getInstance():isFileExist(teamFileName) then
			self._teambg:loadTexture(teamFileName)
            self._teambg:setPosition(self._bgImg:getContentSize().width / 2 + 50 + posX,self._bgImg:getContentSize().height / 2 + posY)
            self._teambg:setScale(scale)
		else
			print("===========have no image==============")
		end
    end

    if self._desTxt then
    	self._desTxt:removeFromParent()
    	self._desTxt = nil
    end
    
    local rtxStr = lang(skinData.teamskinDescr)
    -- rtxStr = "[color=ffffff,fontsize=20,outlinecolor=3c1e0aff,outlinesize=1]若不是宴会人多，你就能看到花园对面父王的宫殿，那一盏彻夜不灭的绿灯，指引着我回家的方向。[-][][-][color=ffffff,fontsize=20]　        ——凯瑟琳对她的好友克里斯丁说[-][]"
    -- rtxStr = "[color=ffffff,fontsize=20,outlinecolor=3c1e0aff,outlinesize=1]每至疾风时龙首轮廓昭示着维京战神的再次降临[-]"
	self._desTxt = RichTextFactory:create(rtxStr,340,100)
    self._desTxt:formatText()
    self._desTxt:setVerticalSpace(3)
    self._desTxt:setName("desTxt")
    self._desTxt:setAnchorPoint(cc.p(0.5,0.5))
    self._desTxt:setPosition(self._desImg:getPositionX(),self._desImg:getPositionY())
	self._bg:addChild(self._desTxt,3)
	--self._titleImg:loadTexture("heroSkin_titleImg_" .. skinData.id .. ".png",1)
    self._titleLabel:setString(lang(skinData.teamskinName))

end

-- 换肤
function TeamSkinView:changeHeroSkin(skinData)
	-- 发送换肤协议
	self._serverMgr:sendMsg("TeamServer", "switchSkin", {teamId=self._teamData.teamId,sId = skinData.id}, true, {}, function(result,succ)
		-- callback 更新数据信息
		self:updateSkinData(skinData.id)
		self:updateCardPanel()
		self._teamData.sId = skinData.id
		local teamModel = self._modelMgr:getModel("TeamModel")
		teamModel:updateTeamSkinId(self._teamData.teamId,skinData.id)   
     end)
end
-- 更新卡片数据信息
function TeamSkinView:updateCardPanel( )
	if not self._cardTb then return end
	
	for k,v in pairs(self._cardTb) do
		local roleCard = v
		local skinData = v.__skinData
		local index = v.__initIndex
		local lockPanel = roleCard:getChildByFullName("lockPanel")
		lockPanel:setVisible(skinData.state and skinData.state == 0)
		
		local unLockPanel = roleCard:getChildByFullName("unLockPanel")
		unLockPanel:setVisible(skinData.state and skinData.state ~= 0)
		
		local usedTxt = roleCard:getChildByFullName("unLockPanel.usedTxt")
		usedTxt:setVisible(skinData.state and skinData.state == 2)
		local getTxt = roleCard:getChildByFullName("unLockPanel.getTxt")
		getTxt:setVisible(skinData.state and skinData.state == 1)

		local roleFrame = roleCard:getChildByFullName("roleFrame")
		roleFrame:setVisible(index == 1)

		local infoBg = roleCard:getChildByFullName("infoBg")
		infoBg:setZOrder(-1)
		infoBg:setVisible(index == 1)
		local useBtn = roleCard:getChildByFullName("infoBg.useBtn")
		useBtn:setVisible(skinData.state and skinData.state == 1)

        local goBtn = roleCard:getChildByFullName("infoBg.goBtn")
		-- goBtn:setVisible(skinData.skinget and skinData.skinget == 3 and skinData.state == 0)
		goBtn:setVisible(false)
		local roleFrame = roleCard:getChildByFullName("roleFrame")
		roleFrame:setVisible(index == 1)

	end
end

-- 初始化 modelPanel
-- 更新model小面板显示
function TeamSkinView:initModelPanel()
	local infoBg = self._modelPanel:getChildByFullName("infoBg")
	local headPanel = self._modelPanel:getChildByFullName("infoBg.headPanel")
	local titleTxt = self._modelPanel:getChildByFullName("infoBg.titleTxt")
	titleTxt:setString("皮肤详情")
	self._modelTips = self._modelPanel:getChildByFullName("infoBg.tipsTxt")
	titleTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	self._modelTips:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    local avatar = ccui.ImageView:create()
    avatar:loadTexture("bg_head_mainView.png", 1)
    avatar:setScale(0.6)
    avatar:setPosition(headPanel:getPosition())
    self._modelPanel._avatarImg = avatar
    infoBg:addChild(avatar,2)

    local avatarFrame = ccui.ImageView:create()
    avatarFrame:loadTexture("bg_head_mainView.png", 1)
    avatarFrame:setScale(0.6)
    avatarFrame:setPosition(headPanel:getPosition())
    infoBg:addChild(avatarFrame,2)

 	local dizuoImg = self._modelPanel:getChildByFullName("infoBg.dizuoImg")
	dizuoImg:loadTexture("asset/uiother/dizuo/heroDizuo.png")
	if not self._modelPanel.__lightMc then
		local clipNode = cc.ClippingNode:create()
	    clipNode:setPosition(dizuoImg:getPositionX(),286)
	    clipNode:setContentSize(cc.size(100, 100))
	    local mask = cc.Sprite:createWithSpriteFrameName("globalPanelUI7_zhezhao.png")
	    mask:setScale(1.5)
	    mask:setAnchorPoint(0.5,0)
	    clipNode:setStencil(mask)
	    clipNode:setAlphaThreshold(0.05)
	    clipNode:setInverted(true)

	    local mcAnim = mcMgr:createViewMC("jianzhuguangxiao_intancebuildingeffect-HD", true, false)   
	    mcAnim:setPosition(0, -20)
	    mcAnim:setScale(0.4)
	    clipNode:addChild(mcAnim)
	    self._modelPanel.__lightMc = clipNode
	    infoBg:addChild(clipNode, 1)
	end

end
-- 更新model小面板显示
function TeamSkinView:updateModelPanel(skinData)
	if not skinData then return end
	local infoBg = self._modelPanel:getChildByFullName("infoBg")
	local avatarImg = self._modelPanel._avatarImg
	if avatarImg then
		avatarImg:loadTexture(skinData.skinart1 .. ".jpg", 1)
		if avatarImg._avatarShine then 
			avatarImg._avatarShine:removeFromParent()
			avatarImg._avatarShine = nil
		end
		-- 添加头像特效   
        -- local shineData = skinData.avatarShine
        -- if shineData then 
        --     local realWidth = 82   -- 头像图片真实宽度                       
        --     avatarImg._avatarShine = IconUtils:addHeadFrameMc(avatarImg,shineData[1],skinData.effect ,avatarImg:getContentSize().width/realWidth,true) 
        -- end
	end

	if self._modelPanel._roleAnim then
		self._modelPanel._roleAnim:clear()
		self._modelPanel._roleAnim = nil
	end
    if self._modelPanel._mcAnim then
		self._modelPanel._mcAnim._node:removeFromParent()
		self._modelPanel._mcAnim:clear()
		self._modelPanel._mcAnim = nil
	end
	-- 左侧人物形象
	local posX,posY,scale =  0,0,1
	if skinData.Coordinate then
		posX =  skinData.Coordinate[1]
		posY =  skinData.Coordinate[2]
		scale =  skinData.Coordinate[3]
	end

	local dizuoImg = self._modelPanel:getChildByFullName("infoBg.dizuoImg")
    local teamArt = skinData["skinart"]
   	if teamArt then
         if AnimAP["mcList"][teamArt] then
            local mcAnim = MovieClipAnim.new(infoBg, teamArt, function (sp)
                sp:setPosition(dizuoImg:getPositionX() + posX, dizuoImg:getPositionY() + posY)
                sp:setScale(scale)
                sp:changeMotion(1)
                sp:play()

            end, false, nil, nil, false)
            self._modelPanel._mcAnim = mcAnim
        else
	        local sp = SpriteFrameAnim.new(infoBg, teamArt, function (sp)
			    sp:setPosition(dizuoImg:getPositionX() + posX, dizuoImg:getPositionY() + 40 + posY)
			    sp:setScale(scale)
			    sp:play()
	    	end, false) 
	   		self._modelPanel._roleAnim = sp
        end
     
	end

	self._modelTips:setString((skinData and skinData.state == 2) and "当前形象" or "皮肤和形象(换上)可生效")

end
-- 接收自定义消息
function TeamSkinView:reflashUI(data)

end

function TeamSkinView:initSkinId(teamid)
	local skinTable = {}
	for i,tTable in pairs(tab.teamSkin) do
		if tTable.teamid == teamid then
			table.insert(skinTable,tTable.id)
		end
	end

	return skinTable
end

-- 初始化皮肤数据
function TeamSkinView:initSkinData()
	local skinId = self:initSkinId(self._teamData.teamId) 
	local serverSkin = self._userModel:getTeamSkinDataById(self._teamData.teamId)
	local currSkin = self._teamData.sId or "2" .. self._teamData.teamId .. "01"
	local teamModel = self._modelMgr:getModel("TeamModel")
	local isAwaking, aLvl = TeamUtils:getTeamAwaking(self._teamData)
    if isAwaking == true then
       currSkin = self._teamData.sId or "2" .. self._teamData.teamId .. "02"
    end

	self._currSkinIdx = 1
	local allSkinData = {}
	for k,v in pairs(skinId) do
		local skinData = clone(tab.teamSkin[tonumber(v)])
		-- 0 未拥有 1 已拥有 2已装备
		if skinData then
			skinData.state = 0
			-- 拥有之后是否已经点击过
			skinData.isRed = false
            --只要有兵团就会有一个默认的皮肤
            local isHaveSkin  = self._modelMgr:getModel("TeamModel"):checkTeamSkin(self._teamData.teamId)
			local skinGet = skinData.skinget or 1
			if serverSkin[tostring(v)] or skinGet == 1 or (isHaveSkin and isAwaking and skinGet == 2) then
				skinData.state = 1
				if self:isSkinClicked(v) then 
					skinData.isRed = true
				end
			end
			if tonumber(currSkin) == tonumber(v) then
				skinData.state = 2
			end
			table.insert(allSkinData, skinData)
			-- allSkinData[tonumber(v)] = skinData
		end
	end

	table.sort(allSkinData,function (a,b)
		return a.rank < b.rank
	end)
	for i,v in ipairs(allSkinData) do
		if tonumber(currSkin) == tonumber(v.id) then
			break
		else
			self._currSkinIdx = self._currSkinIdx + 1
		end
	end
	self._allSkinData = allSkinData

end

-- 判当前皮肤有没有被点击过
function TeamSkinView:isSkinClicked(skinId)
	if not skinId or not self._redInfo then return end
	local isNotClicked = true
	for k,v in pairs(self._redInfo) do
		if tonumber(skinId) == tonumber(v.id) then
			isNotClicked = false
			break
		end
	end
	return isNotClicked
end
-- 更新皮肤数据
function TeamSkinView:updateSkinData(useSkinId)
	if not self._allSkinData or not useSkinId then return end 

	for k,v in pairs(self._allSkinData) do
		local skinData = v
		-- 更新状态
		if skinData.state ~= 0 then
			skinData.state = 1
		end
		if skinData.state == 1 and tonumber(v.id) == tonumber(useSkinId) then
			skinData.state = 2
		end		
	end
	for k,v in pairs(self._cardTb) do
		local skinData = v.__skinData
		if skinData.id == useSkinId then
			skinData.state = 2
		else
			if skinData.state ~= 0 then
				skinData.state = 1
			end
		end

	end
	-- print("======================useSkinId====",useSkinId)
	-- dump(self._allSkinData,"self._allSkinData",5)
end

return TeamSkinView