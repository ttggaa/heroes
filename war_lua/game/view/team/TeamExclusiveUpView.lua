--[[
 	@FileName 	TeamExclusiveUpView.lua
	@Authors 	yuxiaojing
	@Date    	2018-08-16 11:23:43
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local TeamExclusiveUpView = class("TeamExclusiveUpView", BasePopView)

function TeamExclusiveUpView:ctor(params)
    TeamExclusiveUpView.super.ctor(self)
    params = params or {}
    self._curSelect = params.selectTag or 1
    self._curSelectTeam = params.teamData or {}
end

function TeamExclusiveUpView:getAsyncRes()
    return 
        {
            {"asset/ui/hero.plist", "asset/ui/hero.png"}
        }
end

function TeamExclusiveUpView:onInit()
	self:registerClickEventByName("bg.btn_close", function ()
        self:close()
    end)

    self._title = self:getUI("bg.headNode.title")
    UIUtils:setTitleFormat(self._title, 1, 1)

    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._upgradeNode = self:getUI("bg.upgradeNode")
    self._upstarNode = self:getUI("bg.upstarNode")

    local pro_bar_frame = self._upgradeNode:getChildByFullName("leftNode.pro_bar_frame")
    self._pro_bar_frame = pro_bar_frame
	self._pro_normal = pro_bar_frame:getChildByFullName("pro_normal")
	self._pro_gray = pro_bar_frame:getChildByFullName("pro_gray")
	self._label_pro = pro_bar_frame:getChildByFullName("label_pro")
	self._layer_pro = pro_bar_frame:getChildByFullName("layer_pro")

    self._initGrade = false
    self._initStar = false

    local up2_lab1 = self._upgradeNode:getChildByFullName("leftNode.btn_up2.label")
    up2_lab1:setFontName(UIUtils.ttfName)
    up2_lab1:enableOutline(cc.c4b(136, 20, 10, 255), 2)
    up2_lab1:setColor(cc.c4b(255, 243, 229, 255))
    local up2_lab2 = self._upgradeNode:getChildByFullName("leftNode.btn_up2.label1")
    up2_lab2:setFontName(UIUtils.ttfName)
    up2_lab2:enableOutline(cc.c4b(136, 20, 10, 255), 2)
    up2_lab2:setColor(cc.c4b(255, 243, 229, 255))

    self._exclusiveData = tab.exclusive[self._curSelectTeam.teamId]
    self:updateBaseTopInfo()

    self._oldStarLevel = (self._curSelectTeam.zStar or 0) - 1
    local tabConfig = {"tab_upgrade","tab_upstar"}
    self._tab = {}
    for i = 1, 2 do
        local tab = self:getUI("bg." .. tabConfig[i])
        table.insert(self._tab, tab)
        UIUtils:setTabChangeAnimEnable(tab, 70, handler(self, self.touchTab), i)
    end

    self:touchTab(self._curSelect)

    self:registerClickEventByName("bg.upgradeNode.leftNode.btn_up", function ()
        self:onUpgrade(1)
    end)

    self:registerClickEventByName("bg.upgradeNode.leftNode.btn_up2", function ()
        self:onUpgrade(10)
    end)

    self:registerClickEventByName("bg.upstarNode.leftNode.btn_up", function ()
        self:onUpStar(1)
    end)

    self:registerClickEventByName("bg.upstarNode.leftNode.btn_awake", function ()
        self:onUpStar(2)
    end)

    self:listenReflash("UserModel", self.updateUIInfo)
end

function TeamExclusiveUpView:updateUIInfo(  )
	if self._curSelect == 1 then
		self:updateUpgradeInfo(nil, nil, true)
	elseif self._curSelect == 2 then
		self:updateUpStarInfo(true)
	end
end

function TeamExclusiveUpView:updateBaseTopInfo(  )
	local curExStarLevel = (self._curSelectTeam.zStar or 0) - 1
	local level = self._curSelectTeam.zLv or 0
	local qualityType = self._exclusiveData.type or 1
	local nameLab = self:getUI("bg.baseNode.name")
	nameLab:setString("Lv." .. level .. " " .. lang(self._exclusiveData.name))
	nameLab:setColor(TeamUtils.exclusiveNameColorTab[qualityType].color)
	nameLab:enable2Color(1, TeamUtils.exclusiveNameColorTab[qualityType].color2)

	local offset = self._exclusiveData.position or {}
	local offset1 = self._exclusiveData.position1 or {}
	local icon_bg = self:getUI("bg.baseNode.icon")
	if not self._oldStarLevel or self._oldStarLevel ~= curExStarLevel then
		local artImg = icon_bg:getChildByFullName("artImg")
		if artImg then
			artImg:removeFromParent()
		end
		if curExStarLevel < 0 then
			local artName = self._exclusiveData.art1 or "pic_artifact_30"
			artImg = ccui.ImageView:create()
			artImg:setName("artImg")
			artImg:setPosition(icon_bg:getContentSize().width / 2 + (offset[1] or 0) - 5, icon_bg:getContentSize().height / 2 + 20 + (offset[2] or 0))
			artImg:loadTexture(artName .. ".png", 1)
			artImg:setScale(offset[3] or 1)
			icon_bg:addChild(artImg)
		else
			artImg = mcMgr:createViewMC(self._exclusiveData.art2, true, false)
			artImg:setPosition(icon_bg:getContentSize().width / 2 + (offset1[1] or 0) - 5, icon_bg:getContentSize().height / 2 + 20 + (offset1[2] or 0))
			artImg:setName("artImg")
			artImg:setScale(offset1[3] or 1)
			icon_bg:addChild(artImg)
		end
		icon_bg:stopAllActions()
		icon_bg:setPosition(184, 241)
		local moveUp = cc.MoveBy:create(1.5, cc.p(0, 8))
	    local moveDown = cc.MoveBy:create(1.5, cc.p(0, -8))
	    local seq = cc.Sequence:create(moveUp, moveDown)
	    local repeateMove = cc.RepeatForever:create(seq)
	    icon_bg:runAction(repeateMove)
	end

	--是否唤醒
	--未唤醒 skin字段是否有奖励
	local skinReward = self._exclusiveData.skin
	local rewardBg = self:getUI("bg.baseNode.reward")
	local starBg = self:getUI("bg.baseNode.star_bg")
	starBg:setVisible(false)
	rewardBg:setVisible(false)
	if curExStarLevel < 0 and skinReward then
		rewardBg:setVisible(true)
		local skinRewardImg = rewardBg:getChildByFullName("skinRewardImg")
		if skinRewardImg then
			skinRewardImg:removeFromParent()
		end
		skinRewardImg = IconUtils:createItemIconById({itemId = skinReward[1][2]})
		skinRewardImg:setName("skinRewardImg")
		skinRewardImg:setScale(0.5)
		skinRewardImg:setPosition(90, -skinRewardImg:getContentSize().height * 0.5 / 2)
		rewardBg:addChild(skinRewardImg)
	elseif curExStarLevel >= 0 then
		starBg:setVisible(true)
		for i = 1, 6 do
			starBg:getChildByFullName("star" .. i):loadTexture(i <= curExStarLevel and "globalImageUI6_star3.png" or "globalImageUI6_star4.png", 1)
		end
	end
end

function TeamExclusiveUpView:updateUpgradeInfo( oldZLv, upDouble, isOnlyInfo )
	local curExLevel = self._curSelectTeam.zLv or 0
	local curExExp = self._curSelectTeam.zExp or 0
	local levelupData = tab.exclusiveLevel[curExLevel]
	local expNum = levelupData.exp
	local scaleX = (self._layer_pro:getContentSize().width - expNum) / expNum / self._pro_normal:getContentSize().width
	self._layer_pro:removeAllChildren()
	for i = 1, expNum do
		if i <= curExExp then
			local imgNormal = self._pro_normal:clone()
			imgNormal:setVisible(true)
			imgNormal:setScaleX(scaleX)
			imgNormal:setName("imgNormal" .. i)
			imgNormal:setPosition(imgNormal:getBoundingBox().width * (i - 1) + i - 1, self._layer_pro:getContentSize().height / 2)
			self._layer_pro:addChild(imgNormal, 10)

			if upDouble and i > curExExp - upDouble then
				if i ~= expNum then
					local increaseMc = mcMgr:createViewMC("yige_herospellstudyanim", false, true)
                    increaseMc:setAnchorPoint(cc.p(0, 1))
                    increaseMc:setScaleX(scaleX)
                    increaseMc:setPosition(imgNormal:getBoundingBox().width * (i - 0.5) + i - 1, self._layer_pro:getContentSize().height / 2)
                    self._layer_pro:addChild(increaseMc, 99)
				end
			end
		end
		local imgGray = self._pro_gray:clone()
		imgGray:setVisible(true)
		imgGray:setScaleX(scaleX)
		imgGray:setName("imgGray" .. i)
		imgGray:setPosition(imgGray:getContentSize().width*scaleX * (i - 1) + i - 1, self._layer_pro:getContentSize().height / 2)
		self._layer_pro:addChild(imgGray, 5)
	end

	self._label_pro:setString(string.format("%d/%d", curExExp, expNum))
	self._label_pro:enableOutline(cc.c4b(0, 0, 0, 255), 1)

	local itemBg = self._upgradeNode:getChildByFullName("leftNode.itemBg")
	local itemIcon = itemBg:getChildByFullName("consumeItem")
	if itemIcon then
		itemIcon:removeFromParent()
	end

	local consumeData = levelupData.cost[1]
	local xishu = self._exclusiveData.xishu or 1

	self._upgradeState = 0
	local itemId = consumeData[2]
	local itemType = consumeData[1]
	if itemType ~= "tool" then
		itemId = IconUtils.iconIdMap[itemType]
	end

	local needNum = math.ceil(consumeData[3] * xishu)
	local _, haveNum = self._itemModel:getItemsById(itemId)
	local numLab = itemBg:getChildByFullName("num")
	local color = cc.c4b(62, 147, 43, 255)
	if haveNum >= needNum then
		if haveNum > 999 then
			haveNum = "999+"
		end
	else
		self._upgradeState = 1
		color = UIUtils.colorTable.ccUIBaseColor6
	end
	numLab:setColor(color)
	numLab:setString(haveNum .. "/" .. needNum)
	
	local suo = self._upgradeState ~= 0 and 2 or nil
	itemIcon = IconUtils:createItemIconById({itemId = itemId, suo = suo, eventStyle = 3, clickCallback = function (  )
        DialogUtils.showItemApproach(itemId)
	end})
	itemIcon:setName("consumeItem")
	itemIcon:setScale(0.6)
	itemIcon:setPosition(-itemIcon:getContentSize().width / 2 * itemIcon:getScale(), -itemIcon:getContentSize().height / 2 * itemIcon:getScale())
	itemBg:addChild(itemIcon)

	local unlockTxt = self._upgradeNode:getChildByFullName("leftNode.unlockTxt")
	local teamLv = self._curSelectTeam.level
	if curExLevel >= teamLv then
		unlockTxt:setVisible(true)
		self._upgradeState = lang("exclusive_tip_3")
		unlockTxt:setString("需要兵团等级" .. (teamLv + 1) .. "级")
	else
		unlockTxt:setVisible(false)
	end
	if curExLevel >= tab.setting["G_EXCLUSIVE_MAXLEVEL"].value then
		self._upgradeState = lang("exclusive_tip_4")
		unlockTxt:setVisible(true)
		unlockTxt:setString(lang("exclusive_tip_4"))
	end
	if not isOnlyInfo then
		self:updateUpgradeProp(oldZLv)
	end
end

function TeamExclusiveUpView:updateUpgradeProp( oldZLv )
	local curExLevel = self._curSelectTeam.zLv or 0
	local curExStarLevel = (self._curSelectTeam.zStar or 0) - 1
	local scrollView = self._upgradeNode:getChildByFullName("rightNode.scrollView")

	local atkadd = self._exclusiveData.atkadd
	local hpadd = self._exclusiveData.hpadd
	local topNode = self._upgradeNode:getChildByFullName("rightNode.topNode")
	topNode:getChildByFullName("atknum"):setString("+" .. math.round(curExLevel * atkadd[curExStarLevel + 2]))
	topNode:getChildByFullName("atknum2"):setString("+" .. math.round((curExLevel + 1) * atkadd[curExStarLevel + 2]))
	topNode:getChildByFullName("hpnum"):setString("+" .. math.round(curExLevel * hpadd[curExStarLevel + 2]))
	topNode:getChildByFullName("hpnum2"):setString("+" .. math.round((curExLevel + 1) * hpadd[curExStarLevel + 2]))

	local propNode = scrollView:getChildByFullName("propNode")
	local baseProp = propNode:getChildByFullName("prop")
	baseProp:setVisible(false)
	local children = propNode:getChildren()
	for i = 1, #children do
		local child = children[i]
		local name = child:getName()
		if name ~= "prop" then
			child:removeFromParent()
		end
	end

	local exLevel = self._exclusiveData.exlevel
	local exAttribute = self._exclusiveData.exattribute

	local index = 0
	local inc = 10
	local posY = 15
	for i = #exLevel, 1, -1 do
		index = index + 1
		local propValue = exAttribute[i]
		local unlockLevel = exLevel[i]
		local strValue = "Lv." .. unlockLevel .. " "
		local labColor = cc.c4b(60, 43, 30, 255)
		for k, v in pairs(propValue) do
			strValue = strValue .. lang("ATTR_" .. v[1]) .. ":+" .. v[2]
			local dd = tab.attClient[v[1]]
			if dd and dd.attType == 1 then
				strValue = strValue .. "%"
			end
			strValue = strValue .. " "
		end
		local activeImgName = "globalImage_point_light.png"
		if curExLevel < unlockLevel then
			labColor = cc.c4b(209, 191, 169, 255)
			activeImgName = "globalImageUI11_0418DayTitleAdorn.png"
		end
		local w = 310
        local tLabel = {text = strValue, fontsize = 21, color = labColor, width = w, anchorPoint = ccp(0, 0)}
        local text = UIUtils:createMultiLineLabel(tLabel)
        text:setPosition(60, posY)
        text:setName("text" .. i)
		propNode:addChild(text)

		if curExLevel >= unlockLevel then
			if oldZLv and oldZLv < unlockLevel then
				local mc = mcMgr:createViewMC("guangyaoshuaxinguangxiao_baowushuaxin", false, true)
				mc:setPosition(60, posY + text:getContentSize().height / 2)
				propNode:addChild(mc)
				oldZLv = nil
			end
		end

		local activeImg = ccui.ImageView:create()
		activeImg:loadTexture(activeImgName, 1)
		activeImg:setAnchorPoint(0.5, 0.5)
		activeImg:setPosition(45, posY + text:getContentSize().height - 10)
		propNode:addChild(activeImg)
		posY = posY + text:getContentSize().height + inc
	end
	propNode:setContentSize(cc.size(propNode:getContentSize().width, posY))

	propNode:setPositionY(0)
	local minH = scrollView:getContentSize().height
	if posY < minH then
		propNode:setPositionY(minH - posY)
		posY = minH
	end
	scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width, posY))
end

function TeamExclusiveUpView:updateUpStarInfo( isOnlyInfo )
	if not isOnlyInfo then
		self:updateUpstarProp()
	end

	local curExStarLevel = (self._curSelectTeam.zStar or 0) - 1
	self._oldStarLevel = curExStarLevel
	local consumeList = self._exclusiveData.costs
	local maxLevel = #consumeList - 1
	local btn_up = self._upstarNode:getChildByFullName("leftNode.btn_up")
	local itemBg = self._upstarNode:getChildByFullName("leftNode.itemBg")
	local btn_awake = self._upstarNode:getChildByFullName("leftNode.btn_awake")
	local img_full = self._upstarNode:getChildByFullName("leftNode.img_full")
	img_full:setVisible(maxLevel <= curExStarLevel)
	btn_up:setVisible(not (maxLevel <= curExStarLevel))
	btn_awake:setVisible(not (maxLevel <= curExStarLevel))
	itemBg:setVisible(not (maxLevel <= curExStarLevel))
	if maxLevel <= curExStarLevel then
		return
	end

	if curExStarLevel < 0 then
		btn_awake:setVisible(true)
		btn_up:setVisible(false)
	else
		btn_awake:setVisible(false)
		btn_up:setVisible(true)
	end

	local consumeData = consumeList[curExStarLevel + 2]

	self._upStarState = 0
	local itemId = consumeData[2]
	local itemType = consumeData[1]
	local needNum = consumeData[3]
	if itemType ~= "tool" then
		itemId = IconUtils.iconIdMap[itemType]
	end

	local _, haveNum = self._itemModel:getItemsById(itemId)
	local numLab = itemBg:getChildByFullName("num")
	local color = cc.c4b(62, 147, 43, 255)
	if haveNum >= needNum then
		if haveNum > 999 then
			haveNum = "999+"
		end
	else
		self._upStarState = 1
		color = UIUtils.colorTable.ccUIBaseColor6
	end
	numLab:setColor(color)
	numLab:setString(haveNum .. "/" .. needNum)

	local itemIcon = itemBg:getChildByFullName("itemIcon1")
	if itemIcon then
		itemIcon:removeFromParent()
	end
	local suo = self._upStarState ~= 0 and 2 or nil
	itemIcon = IconUtils:createItemIconById({itemId = itemId, suo = suo, eventStyle = 3, clickCallback = function (  )
        DialogUtils.showItemApproach(itemId)
	end})
	itemIcon:setScale(0.6)
	itemIcon:setName("itemIcon1")
	itemIcon:setPosition(-itemIcon:getContentSize().width / 2 * itemIcon:getScale(), -itemIcon:getContentSize().height / 2 * itemIcon:getScale())
	itemBg:addChild(itemIcon)
end

function TeamExclusiveUpView:updateUpstarProp(  )
	local curExStarLevel = (self._curSelectTeam.zStar or 0) - 1
	local scrollView = self._upstarNode:getChildByFullName("rightNode.scrollView")
	local autoList = scrollView:getChildByFullName("autoList")

	local propNode = autoList:getChildByFullName("propNode")
	local baseNode = propNode:getChildByFullName("prop")
	baseNode:setVisible(false)
	local children = propNode:getChildren()
	for i = 1, #children do
		local child = children[i]
		local name = child:getName()
		if name ~= "prop" then
			child:removeFromParent()
		end
	end

	local effectDes = self._exclusiveData.effectdes or {}
	local effectShow = self._exclusiveData.effectshow
	local effectShowLv = effectShow[curExStarLevel + 2]
	local posY = 5
	for i = #effectDes, 1, -1 do
		local node = baseNode:clone()
		node:setName("node" .. i)
		local activeImg = node:getChildByFullName("activeImg")
		local bg = node:getChildByFullName("bg")
		local starTxt = node:getChildByFullName("starTxt")
		if i > 1 then
			starTxt:setString((i - 1) .. "星")
		else
			starTxt:setString("唤醒")
		end
		local des = ""
		local showSa = 100
		if i > effectShowLv then
			for k, v in pairs(effectShow) do
				if i <= v and v <= showSa then
					showSa = (k - 2)
				end
			end
			des = "*******（专属" .. showSa .. "星可见）"
		else
			des = lang(effectDes[i])
		end
		if des == "" then
			des = "*****please call qiziwei*****"
		end
		local textColor = cc.c4b(70, 40, 0, 255)
        if curExStarLevel >= (i - 1) then
        	activeImg:loadTexture("globalImageUI_propActive1.png", 1)
        else
        	activeImg:loadTexture("globalImageUI_propActive2.png", 1)
        	if (i - 1) <= showSa then
        		if (i - 1) == (curExStarLevel + 1) then
					textColor = cc.c4b(196, 73, 4, 255)
				else
					textColor = cc.c4b(120, 120, 120, 255)
				end
        	else
        		textColor = cc.c4b(120, 120, 120, 255)
        	end
        end
        starTxt:setColor(textColor)
		local tLabel = {text = des, fontsize = 18, color = textColor, width = 285, anchorPoint = ccp(0, 0)}
        local text = UIUtils:createMultiLineLabel(tLabel)
        text:setPosition(110, 13)
        node:addChild(text)
        local nodeH = text:getContentSize().height + 30
        node:setContentSize(cc.size(node:getContentSize().width, nodeH))
        bg:setContentSize(cc.size(bg:getContentSize().width, nodeH))
        bg:setVisible(i % 2 == 0)
        node:setVisible(true)
        node:setPosition(0, posY)
        propNode:addChild(node)
        activeImg:setPositionY(nodeH - activeImg:getContentSize().height / 2 - 15)
        starTxt:setPositionY(activeImg:getPositionY())
        posY = posY + nodeH

        local fireMC = node:getChildByFullName("fireMC")
        if fireMC then
        	fireMC:removeFromParent()
        end
        bg:setZOrder(-2)
        if i == 1 or i == 4 or i == 7 then
	        fireMC = mcMgr:createViewMC("zhuanshushengxinghuomiao_zhuanshuhuomiao", true, false)
	        fireMC:setName("fireMC")
	        fireMC:setScaleY(0.8)
			fireMC:setPosition(activeImg:getPositionX(), activeImg:getPositionY() - 5)
			node:addChild(fireMC, -1)
		end
	end
	propNode:setContentSize(cc.size(propNode:getContentSize().width, posY))
	autoList:setContentSize(cc.size(autoList:getContentSize().width, posY))
	autoList:setPositionY(0)
	local minH = scrollView:getContentSize().height
	if posY < minH then
		autoList:setPositionY(minH - posY)
		posY = minH
	end
	scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width, posY))
end

function TeamExclusiveUpView:updateUpgradeEffect( double, isUpgrade )
	if not double or double == 0 then return end

	local mcName = nil
	if double == 2 then
		mcName = "baoji2_herospellstudyanim"
	elseif double == 3 then
		mcName = "baoji3_herospellstudyanim"
	end
	if mcName then
		local doubleMC = mcMgr:createViewMC(mcName, false, true)
		doubleMC:setPosition(self._pro_bar_frame:getContentSize().width / 2, self._pro_bar_frame:getContentSize().height + 20)
		self._pro_bar_frame:addChild(doubleMC, 100)
		doubleMC:gotoAndPlay(0)
	end

	local studyText = ccui.Text:create()
    studyText:setFontSize(14)
    studyText:setFontName(UIUtils.ttfName_Title)
    studyText:setString("淬炼进度+" .. double)
    studyText:setColor(cc.c4b(255, 46, 46, 255))
    studyText:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    studyText:setPosition(cc.p(self._pro_bar_frame:getContentSize().width - 30, self._pro_bar_frame:getContentSize().height - 10))
    self._pro_bar_frame:addChild(studyText,999)
    studyText:runAction(cc.Sequence:create({cc.Spawn:create({cc.EaseOut:create(cc.MoveBy:create(0.9, cc.p(0, 15)), 3), cc.FadeOut:create(0.9)}), cc.CallFunc:create(function()
        studyText:removeFromParent()
    end)}))

    if isUpgrade then
    	local increaseMc = mcMgr:createViewMC("tiaomanzhuangtai_herospellstudyanim", false, true)
        increaseMc:gotoAndPlay(0)
        increaseMc:setPosition(self._pro_bar_frame:getContentSize().width / 2, self._pro_bar_frame:getContentSize().height / 2)
        self._pro_bar_frame:addChild(increaseMc,99)
    end
end

function TeamExclusiveUpView:onUpgrade( eType )
	if self._upgradeState == 1 then
		self._viewMgr:showTip(lang("exclusive_tip_2"))
		return
	elseif self._upgradeState ~= 0 then
		self._viewMgr:showTip(self._upgradeState)
		return
	end
	eType = eType or 1
	local oldFightNum = self._curSelectTeam.score
	local oldZLv = self._curSelectTeam.zLv or 0
	self._serverMgr:sendMsg("TeamServer", "upExclusiveLv", {teamId = self._curSelectTeam.teamId, type = eType}, true, {}, function(data)
		self._curSelectTeam = self._teamModel:getTeamAndIndexById(self._curSelectTeam.teamId)
		self:updateUpgradeInfo(oldZLv, data.double)
		self:updateBaseTopInfo()
		local newFightNum = self._curSelectTeam.score
		if newFightNum > oldFightNum then
			TeamUtils:setFightAnim(self, {oldFight = oldFightNum, newFight = newFightNum, x = self:getContentSize().width / 2, y = self:getContentSize().height - 200})
		end
		self:updateUpgradeEffect(data.double, (self._curSelectTeam.zLv or 0) > oldZLv)
    end, function ( errorId )
        errorId = tonumber(errorId)
        print("errorId:" .. errorId)
        self._viewMgr:unlock()
    end)
end

function TeamExclusiveUpView:onUpStar(  )
	if self._upStarState == 1 then
		self._viewMgr:showTip(lang("exclusive_tip_5"))
		return
	end
	local oldFightNum = self._curSelectTeam.score
	self._serverMgr:sendMsg("TeamServer", "upExclusiveStar", {teamId = self._curSelectTeam.teamId}, true, {}, function(data)
		self._curSelectTeam = self._teamModel:getTeamAndIndexById(self._curSelectTeam.teamId)
		self:updateBaseTopInfo()
		self:updateUpStarInfo()
		local newZStar = (self._curSelectTeam.zStar or 0) - 1
		if newZStar <= 0 then
			self._viewMgr:showView("team.TeamExclusiveAwakeView", {teamId = self._curSelectTeam.teamId, callback = function (  )
				ScheduleMgr:nextFrameCall(self, function (  )
					self._viewMgr:showDialog("team.TeamExclusiveUpSuccessDialog", {oldFightNum = oldFightNum, teamData = self._curSelectTeam, callback = function (  )
						local newFightNum = self._curSelectTeam.score
						if newFightNum > oldFightNum then
							TeamUtils:setFightAnim(self, {oldFight = oldFightNum, newFight = newFightNum, x = self:getContentSize().width / 2, y = self:getContentSize().height - 200})
						end
					end})
				end)
			end})
		else
			self._viewMgr:showDialog("team.TeamExclusiveUpSuccessDialog", {oldFightNum = oldFightNum, teamData = self._curSelectTeam, callback = function (  )
				local newFightNum = self._curSelectTeam.score
				if newFightNum > oldFightNum then
					TeamUtils:setFightAnim(self, {oldFight = oldFightNum, newFight = newFightNum, x = self:getContentSize().width / 2, y = self:getContentSize().height - 200})
				end
			end})
		end
    end, function ( errorId )
        errorId = tonumber(errorId)
        print("errorId:" .. errorId)
        self._viewMgr:unlock()
    end)
end

function TeamExclusiveUpView:setTabStatus( tabBtn, isSelect )
    if isSelect then
        tabBtn:loadTextureNormal("globalBtnUI4_page1_p.png",1)
        local text = tabBtn:getTitleRenderer()
        tabBtn:setTitleColor(UIUtils.colorTable.ccUITabColor1)
        text:disableEffect()
    else
        tabBtn:loadTextureNormal("globalBtnUI4_page1_n.png",1)
        local text = tabBtn:getTitleRenderer()
        tabBtn:setTitleColor(UIUtils.colorTable.ccUITabColor2)
        text:disableEffect()
    end
    tabBtn:setEnabled(not isSelect)
end

function TeamExclusiveUpView:touchTab( idx )
	self._curSelect = idx
	for i, v in ipairs(self._tab) do
        if i ~= idx then
            self:setTabStatus(v, false)
            if self._preBtn then
                UIUtils:tabChangeAnim(self._preBtn, nil, true)
            end
        end
    end
    local selectTab = self._tab[idx]
    self._preBtn = selectTab 
    UIUtils:tabChangeAnim(selectTab, function( )
        self:setTabStatus(selectTab, true)
    end)

    self._title:setString(idx == 1 and "专属升级" or "专属升星")
    if idx == 1 then
    	self._upgradeNode:setVisible(true)
    	self._upstarNode:setVisible(false)
    	if not self._initGrade then
    		self:updateUpgradeInfo()
    		self._initGrade = true
    	end
    else
    	self._upgradeNode:setVisible(false)
    	self._upstarNode:setVisible(true)
    	if not self._initStar then
    		self:updateUpStarInfo()
    		self._initStar = true
    	end
    end
end

return TeamExclusiveUpView