--[[
    Filename:    IntanceSectionInfoView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-03-16 10:31:20
    Description: File description
--]]


local IntanceSectionInfoView = class("IntanceSectionInfoView", BasePopView)


function IntanceSectionInfoView:ctor()

    IntanceSectionInfoView.super.ctor(self)
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("intance.IntanceSectionInfoView")
        elseif eventType == "enter" then 
        end
    end)
end

function IntanceSectionInfoView:reflashUI(inData)
	self._intanceModel = self._modelMgr:getModel("IntanceModel")
    self:registerClickEventByName("bg.bg1.closeBtn", function()
    	UIUtils:reloadLuaFile("intance.IntanceSectionInfoView")
        self:close()
    end)

	self._callback = inData.callback
	self._moveCallback = inData.moveCallback
	self._updateCallback = inData.updateCallback
	self._curSectionId = inData.sectionId

	self._lastTaskIndex = 0
	self._curTaskIndex = 0


    local titleLab = self:getUI("bg.bg1.titleBg.title")
    UIUtils:setTitleFormat(titleLab, 1)

    local tab1 = self:getUI("bg.bg1.tab1")  --剧情
    local tab2 = self:getUI("bg.bg1.tab2")  --支线 

    self._btnList = {}
    table.insert(self._btnList, tab1)
    table.insert(self._btnList, tab2) 
    for k,v in pairs(self._btnList) do
        v:setTitleFontName(UIUtils.ttfName)
        -- v:setTitleFontSize(32)
    end

    if inData.showBranchTip == 1 then 
        local tip = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
        tip:setPosition(cc.p(20, tab2:getContentSize().height - 10))
        tip:setAnchorPoint(cc.p(0.5, 0.5))
        tab2:addChild(tip, 10)
        tab2.tip = tip
    end

    UIUtils:setTabChangeAnimEnable(tab1,-36,handler(self, self.tabButtonClick))
    UIUtils:setTabChangeAnimEnable(tab2,-36,handler(self, self.tabButtonClick))

    self._descBg = self:getUI("bg.bg1.descBg")
    self._descBg:setVisible(false)


    self._scrollBg = self:getUI("bg.bg1.scrollBg")
    self._scrollBg:setVisible(false)

    self._scrollView = self:getUI("bg.bg1.scrollBg.scrollView")
    self._scrollView:setBounceEnabled(true)
    
    self:showTaskNode()

    self:showInfoNode()

    if inData.showBranchTip == 1 then 
        self:tabButtonClick(tab2)
    else
        self:tabButtonClick(tab1)
    end
end


function IntanceSectionInfoView:tabButtonClick(sender)
    if sender == nil then
        return
    end
    
   for k,v in pairs(self._btnList) do
        if v ~= sender then 
            local text = v:getTitleRenderer()
            v:setTitleColor(UIUtils.colorTable.ccUITabColor1)
            text:disableEffect()
            v:setScaleAnim(false)
            v:stopAllActions()
            v:setBright(true)
            v:setEnabled(true)

            if self._preBtn and self._preBtn == v then
		        UIUtils:tabChangeAnim(self._preBtn,nil,true,true)
		    end
        end
    end
    
    self._preBtn = tabBtn     
    self._curChannel = sender:getName()
    UIUtils:tabChangeAnim(sender,function( )
        local text = sender:getTitleRenderer()
        text:disableEffect()
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor2)
        sender:setBright(false)
        sender:setEnabled(false)
    end)

    if sender:getName()== "tab1" then 
    	self:showTaskNode()
    else
    	local sysSectionInfo = tab:SectionInfo(self._curSectionId)
		if sysSectionInfo == nil or sysSectionInfo.openBranch == 0 then self._viewMgr:showTip("无支线目标") return end
        self:showInfoNode()
    end   
end

function IntanceSectionInfoView:showTaskNode()
    local taskDescBg = self:getUI("bg.bg1.taskDescBg")
    taskDescBg:setVisible(true)
	self._descBg:setVisible(true)
	self._scrollBg:setVisible(false)

    if self._descBg.isOk == true then return end
    self._descBg.isOk = true

	local sysSectionInfo = tab:SectionInfo(self._curSectionId)
	local sysMainSectionMap = tab:MainSectionMap(self._curSectionId)
	if sysSectionInfo ~= nil then 
		local str = lang(sysSectionInfo.des)
		if string.find(str, "color=") == nil then
			str = "[color=000000]"..str.."[-]"
		end
		print("str======================", str)
	    local richText = RichTextFactory:create(str, 580, 0)
	    richText:formatText()
	    richText:setPixelNewline(true)
		richText:setPosition(302, 100)
		richText:setPosition(self._descBg:getContentSize().width/2, self._descBg:getContentSize().height - richText:getRealSize().height * 0.5)
	    self._descBg:addChild(richText)       
    end	

		self._lastTaskIndex = 0
		self._curTaskIndex = 0
        self._finTaskIndex = 0
        local indexLab = self:getUI("bg.bg1.taskDescBg.indexLab")
        indexLab:setFontName(UIUtils.ttfName)
        indexLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)   

        local tipLab = self:getUI("bg.bg1.taskDescBg.tipLab")
        tipLab:setFontName(UIUtils.ttfName)
        tipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)  

	    local taskDescBg = self:getUI("bg.bg1.taskDescBg")
	    print("sysMainSectionMap.task==================", sysMainSectionMap.task)

	    if sysMainSectionMap.task == nil then 
	    	if taskDescBg.rich ~= nil then 
	    		taskDescBg.rich:removeFromParent()
	    		taskDescBg.rich = nil
	    	end
	    	return 
	    end
        

	    local branchWithStage = self._intanceModel:getSysBranchWithStageDatas()
	    local curStageId = self._intanceModel:getData().mainsData.curStageId
	    for k1,v1 in pairs(sysMainSectionMap.task) do
	    	print("k1===========", k1)
	        local v = tab:MainTask(v1)
	        local targetType = v.taskTarget[1]
	        local targetId = v.taskTarget[2]
	        if targetType == 1 then 
	            local stageInfo = self._intanceModel:getStageInfo(targetId)
	            if stageInfo.star > 0 then
	            	self._curTaskIndex = k1
                    self._finTaskIndex = k1
	            elseif stageInfo.star <= 0 then
	                self._curTaskIndex = k1
	                break
	            end
	        else
	            if targetId <= IntanceConst.FIRST_SECTION_LAST_STAGE_ID and curStageId >= targetId then
	                self._curTaskIndex = k1
                    self._finTaskIndex = k1
	            elseif branchWithStage[targetId] ~= nil then 
	                local stageInfo = self._intanceModel:getStageInfo(branchWithStage[targetId])
	                if stageInfo.branchInfo[targetId] ~= nil then
	                	self._curTaskIndex = k1
                        self._finTaskIndex = k1
	                elseif stageInfo.branchInfo[targetId] == nil then
	                    self._curTaskIndex = k1
	                    break
	                end
	            end
	        end
	    end
	    self._lastTaskIndex = self._curTaskIndex


	    local function showTaskByIndex(inIndex)
            local leftBtn = self:getUI("bg.bg1.taskDescBg.leftBtn")

            local rightBtn = self:getUI("bg.bg1.taskDescBg.rightBtn")

            if inIndex == 1 then
                leftBtn:setVisible(false)
            else
                leftBtn:setVisible(true)
            end
            if inIndex == self._lastTaskIndex then 
                rightBtn:setVisible(false)
            else
                rightBtn:setVisible(true)
            end
            indexLab:setString(inIndex .. "/" .. self._lastTaskIndex)
	    	local taskId = sysMainSectionMap.task[inIndex]
	    	if taskId == nil then return end
	    	if taskDescBg.rich ~= nil then 
	    		taskDescBg.rich:removeFromParent()
	    		taskDescBg.rich = nil
	    	end

	    	local sysTask = tab:MainTask(taskId)
		    local str = lang(sysTask.openDes)
			if string.find(str, "color=") == nil then
				str = "[color=000000]"..str.."[-]"
			end
			print("str========================", str)
		    local richText = RichTextFactory:create(str, 580, 0)
		    richText:setPixelNewline(true)
		    richText:formatText()
			richText:setPosition(taskDescBg:getContentSize().width * 0.5, taskDescBg:getContentSize().height - richText:getRealSize().height * 0.5 - 60)
		    taskDescBg:addChild(richText)
		    taskDescBg.rich = richText

            local tipLab = self:getUI("bg.bg1.taskDescBg.tipLab")
            tipLab:setString(lang(sysTask.taskDes))
            local finishImg = self:getUI("bg.bg1.taskDescBg.finishImg")
            if self._finTaskIndex >= inIndex then 
                finishImg:setVisible(true)
            else
                finishImg:setVisible(false)
            end
		end
		showTaskByIndex(self._curTaskIndex)
	    local leftBtn = self:getUI("bg.bg1.taskDescBg.leftBtn")

	    local rightBtn = self:getUI("bg.bg1.taskDescBg.rightBtn")
	    self:registerClickEvent(leftBtn, function ()
	    	if self._curTaskIndex == 1 then 
	    		self._viewMgr:showTip("无目标可选")
	    		return
	    	end
	    	self._curTaskIndex = self._curTaskIndex - 1
	    	showTaskByIndex(self._curTaskIndex)
	    end)

	    self:registerClickEvent(rightBtn, function ()
	    	if self._curTaskIndex == self._lastTaskIndex then 
	    		self._viewMgr:showTip("当前目标还未完成")
	    		return
	    	end
	    	self._curTaskIndex = self._curTaskIndex + 1
	    	showTaskByIndex(self._curTaskIndex)
	    end)	    
end

function IntanceSectionInfoView:showInfoNode()
	local sysSectionInfo = tab:SectionInfo(self._curSectionId)
	if sysSectionInfo == nil or sysSectionInfo.finishReward == nil then return end
	self._descBg:setVisible(false)
	self._scrollBg:setVisible(true)
    local taskDescBg = self:getUI("bg.bg1.taskDescBg")
    taskDescBg:setVisible(false)    
    -- self._scrollView:removeAllChildren()

    if self._scrollBg.isOk == true then return end
    self._scrollBg.isOk = true
       
  	local height  = 20

    local progressHeight, progressNode = self:createProgressNode(sysSectionInfo)
    -- height = height + progressHeight
    progressNode:setPosition(0, self._scrollBg:getContentSize().height + 5)
    progressNode:setAnchorPoint(0, 0)
    self._scrollBg:addChild(progressNode, 104)   


 	local branchHeight, branchNode = self:createBranchNode(sysSectionInfo)
 	height = height + branchHeight
    branchNode:setAnchorPoint(0, 0)
    self._scrollView:addChild(branchNode)   

 	local roleInfoHeight, roleNode = self:createRoleNode(sysSectionInfo)
 	height = height + roleInfoHeight
    roleNode:setAnchorPoint(0, 0)
    self._scrollView:addChild(roleNode)   


    if height < self._scrollView:getContentSize().height then 
    	height = self._scrollView:getContentSize().height
    end


    self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, height))


    branchNode:setPosition(0, height - branchHeight)


    height = height - branchHeight - 10

    roleNode:setPosition(0, height - roleInfoHeight)


    self._scrollView:jumpToPercentVertical(0)

end

function IntanceSectionInfoView:createInfoNode(inSysSectionInfo)
	local height = 0
	local str = lang(inSysSectionInfo.des)
	if string.find(str, "color=") == nil then
		str = "[color=000000]"..str.."[-]"
	end  
    local richText = RichTextFactory:create(str, 570, 0)
    richText:formatText()
    height = height + richText:getRealSize().height + 10

    height = height + 25

	local infoBg = cc.Sprite:create()
	infoBg:setContentSize(cc.size(625, height))

	local maxHeight = height + 32

	richText:setPosition(302, height - richText:getRealSize().height/2 - 20)

	infoBg:addChild(richText)

	height = height - 30 - richText:getRealSize().height

	return maxHeight, infoBg
end

function IntanceSectionInfoView:createTargetNode(inSysSectionInfo)
	local height = 40 + #inSysSectionInfo.traget * 30 

	local infoBg = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI6_qianBg50_50.png")
	infoBg:setCapInsets(cc.rect(25, 25, 1, 1))
	infoBg:setContentSize(cc.size(538, height))

	-- local infoTitleBg = cc.Sprite:createWithSpriteFrameName("intanceImageUI6_tmp1.png")
	-- infoTitleBg:setAnchorPoint(0, 0)
	-- infoTitleBg:setPosition(0, height)
	-- infoBg:addChild(infoTitleBg)

	local infoTitle = cc.Label:createWithTTF("主线目标", UIUtils.ttfName, 24)
	infoTitle:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- infoTitle:enableOutline(cc.c4b(60, 30, 10,255), 2)
	infoTitle:setAnchorPoint(0.5, 0.5)
	-- infoTitle:setPosition(infoTitleBg:getContentSize().width/2, infoTitleBg:getContentSize().height/2)
	infoTitle:setPosition(0, height)
	infoBg:addChild(infoTitle)

    local intanceModel = self._modelMgr:getModel("IntanceModel")
    local curStageId = intanceModel:getData().mainsData.curStageId

    local y = height - 30
	for k,v in pairs(inSysSectionInfo.traget) do
		local sysMainStage = tab:MainStage(v)
		local infoTitle = cc.Label:createWithTTF(lang(sysMainStage.title), UIUtils.ttfName, 22)
		infoTitle:setAnchorPoint(0, 0.5)
		infoTitle:setPosition(30, y)
		infoBg:addChild(infoTitle)

		local infoNum = cc.Label:createWithTTF("", UIUtils.ttfName, 22)
		infoNum:setAnchorPoint(1, 0.5)
		-- infoNum:setPosition(30, y)
		infoBg:addChild(infoNum)
		if curStageId > v then 
			infoTitle:setColor(UIUtils.colorTable.ccColorQuality2)
			infoTitle:enableOutline(UIUtils.colorTable.ccColorQualityOutLine2, 2)   --ccColorQualityOutLine5  
																-- ccColorQuality5
			infoNum:setString("1/1")
			infoNum:setColor(UIUtils.colorTable.ccColorQuality2)
			infoNum:enableOutline(UIUtils.colorTable.ccColorQualityOutLine2, 2)
		else
			infoTitle:setColor(UIUtils.colorTable.ccColorQuality5)
			infoTitle:enableOutline(UIUtils.colorTable.ccColorQualityOutLine5, 2)
			infoNum:setString("0/1")
			infoNum:setColor(UIUtils.colorTable.ccColorQuality5)
			infoNum:enableOutline(UIUtils.colorTable.ccColorQualityOutLine5, 2)
		end
		infoNum:setPosition(infoBg:getContentSize().width - 30, y)

		y = y - infoTitle:getContentSize().height - 10
	end

	-- height = height + infoTitleBg:getContentSize().height
	height = height + 32

	return height, infoBg
end


function IntanceSectionInfoView:createBranchNode(inSysSectionInfo)
	local height = 0

	local infoBg = cc.Sprite:create()
	infoBg:setContentSize(cc.size(668,  5 + #inSysSectionInfo.branchId * 120))
	height = height + infoBg:getContentSize().height

    local leftTmpImg = cc.Sprite:createWithSpriteFrameName("teamImageTps_listTmp1.png")
    -- leftTmpImg:setScaleX(-1)
    leftTmpImg:setAnchorPoint(1, 0.5)
    leftTmpImg:setPosition(infoBg:getContentSize().width * 0.5 - 50, height - 10)
    infoBg:addChild(leftTmpImg)


    local rightTmpImg = cc.Sprite:createWithSpriteFrameName("teamImageTps_listTmp1.png")
    rightTmpImg:setScaleX(-1)
    rightTmpImg:setAnchorPoint(1, 0.5)
    rightTmpImg:setPosition(infoBg:getContentSize().width * 0.5 + 50, height - 10)
    infoBg:addChild(rightTmpImg)

	local infoTitle = cc.Label:createWithTTF("支线信息", UIUtils.ttfName, 20)
	infoTitle:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	infoTitle:setAnchorPoint(0.5, 0.5)
	infoTitle:setPosition(infoBg:getContentSize().width * 0.5, height - 10)
	infoBg:addChild(infoTitle)

	-- height = height + infoTitleBg:getContentSize().height
	height = height + 22

	local branchInfo = {}

	local branchStageInfo = {}

	local sysMainSection = tab:MainSection(inSysSectionInfo.id)

	local intanceModel = self._modelMgr:getModel("IntanceModel")
	local mainsData = intanceModel:getData().mainsData

	local branchHasEye = {}
	local branchWithStage = intanceModel:getSysBranchWithStageDatas()

	for k,v in pairs(sysMainSection.includeStage) do
		local stageInfo = intanceModel:getStageInfo(v)
		for k1,v1 in pairs(stageInfo.branchInfo) do
			branchInfo[tonumber(k1)] = true
		end

		if mainsData.curStageId <= v then
    		branchHasEye[tonumber(v)] = true
    	end
	end


	local x = 10
	local y = infoBg:getContentSize().height - 30
	for k,v in pairs(inSysSectionInfo.branchId) do
		local sysBranchStage = tab:BranchStage(v)
		local data = inSysSectionInfo.branchReward[k]
		local itemType = data[1] or data.type
	    local itemId = data[2] or data.typeId 
	    local num = data[3] or data.num 
	    local isHide = 0
    	if sysBranchStage.hide == 1 then 
    		isHide = 1
    	end	    


		local dropBg = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI7_cellBg21.png")
		dropBg:setContentSize(cc.size(668, 115))  
		dropBg:setAnchorPoint(0, 1)
		dropBg:setPosition(x, y)
		infoBg:addChild(dropBg)
		local dropIcon 
		if isHide == 1 then
			dropIcon = ccui.Widget:create()
			local iconBg = cc.Sprite:createWithSpriteFrameName("globalImageUI6_itembg_1.png")

			local quality = cc.Sprite:createWithSpriteFrameName("globalImageUI4_squality5.png")
			dropIcon:setContentSize(quality:getContentSize().width, quality:getContentSize().height)

			iconBg:setPosition(dropIcon:getContentSize().width * 0.5, dropIcon:getContentSize().height * 0.5)
			dropIcon:addChild(iconBg)

			quality:setPosition(dropIcon:getContentSize().width * 0.5, dropIcon:getContentSize().height * 0.5)
			dropIcon:addChild(quality)

			local secret = cc.Sprite:createWithSpriteFrameName("globalImageUI_secretIcon.png")
			secret:setPosition(dropIcon:getContentSize().width * 0.5, dropIcon:getContentSize().height * 0.5)
			dropIcon:addChild(secret)
				
			dropIcon:setAnchorPoint(0, 0.5)
			-- dropIcon:setScale(0.9)
			dropIcon:setPosition(15, dropBg:getContentSize().height/2 + 1)
			dropBg:addChild(dropIcon, 1)			
		else
			if inSysSectionInfo.branchReward[k][1] == "team" then
	          local sysTeam = tab:Team(inSysSectionInfo.branchReward[k][2])
	          dropIcon = IconUtils:createSysTeamIconById({sysTeamData = sysTeam})
	          dropIcon:setAnchorPoint(0, 0.5)
	          -- dropIcon:setScale(0.9)
	          dropIcon:setPosition(15, dropBg:getContentSize().height/2)
              dropIcon:setScale(0.9)
	          dropBg:addChild(dropIcon, 1)
	    	else
		    	if itemType ~= "tool" then
			        itemId = IconUtils.iconIdMap[itemType]
			    end
				-- if data.isItem then
				local sysItem = tab:Tool(itemId)
		        dropIcon = IconUtils:createItemIconById({itemId = itemId,itemData = sysItem})
				dropIcon:setAnchorPoint(0, 0.5)
				-- dropIcon:setScale(0.9)
		        dropIcon:setPosition(15, dropBg:getContentSize().height/2)
		        dropBg:addChild(dropIcon, 1)
		    end


		end
		-- 隐藏奖励，领取后只有icon保持？状态
	    if branchInfo[v] ~= nil then 
	    	isHide = 0 
	    end
	    dropIcon:setScale(dropIcon:getScale() * 0.9)

		local title = lang(sysBranchStage.title)
		if isHide == 1 then 
			title = "隐藏奖励"
		end
		local dropTitle = cc.Label:createWithTTF(title, UIUtils.ttfName, 24)--24
		dropTitle:setAnchorPoint(0, 0.5)
		dropTitle:setPosition(116, 82)  --60
		dropBg:addChild(dropTitle)
		dropTitle:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
		

	

		local desc = lang(sysBranchStage.stageGoal)
		if isHide == 1 then 
			desc = "未发现线索"
		end
        print("desc====", desc)
        if desc ~= nil and string.len(desc) > 0 then
            local cutline = cc.Sprite:createWithSpriteFrameName("globalImageUI12_cutline1.png")
            cutline:setAnchorPoint(0, 0.5)
            cutline:setPosition(dropTitle:getPositionX() + dropTitle:getContentSize().width + 22, 82)
            dropBg:addChild(cutline, 100)

    		local dropDes = cc.Label:createWithTTF(desc, UIUtils.ttfName, 22)
    		dropDes:setAnchorPoint(0, 0.5)
    		dropDes:setPosition(cutline:getPositionX()  + cutline:getContentSize().width + 22, 82) 
    		dropDes:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    		dropBg:addChild(dropDes)
        end

		local temp1 = cc.Sprite:createWithSpriteFrameName("intanceImageUI6_magicEye.png")
        local buildingIcon = ccui.Widget:create()
        buildingIcon:setContentSize(cc.size(temp1:getContentSize().width, temp1:getContentSize().height))
		buildingIcon:addChild(temp1)
		temp1:setPosition(temp1:getContentSize().width/2, temp1:getContentSize().height/2)
		buildingIcon:setAnchorPoint(0.5, 0.5)
		buildingIcon:setPosition(550 - buildingIcon:getContentSize().width/2 + 80, 15 + buildingIcon:getContentSize().height/2)
		buildingIcon:setScaleAnim(true)
		dropBg:addChild(buildingIcon)

		if branchInfo[v] ~= nil then 
			local getIt = cc.Sprite:createWithSpriteFrameName("intanceImageUI_finish.png")
			getIt:setAnchorPoint(0.5, 0.5)
			getIt:setPosition(buildingIcon:getPositionX(), buildingIcon:getPositionY())
			dropBg:addChild(getIt, 100)
			buildingIcon:setVisible(false)
		end

		registerClickEvent(buildingIcon, function()
			if isHide == 1 then 
				self._viewMgr:showTip(lang("sectionInfortip_1"))		
				return
			end
			if branchHasEye[branchWithStage[v]] == nil then 
				if branchInfo[v] ~= nil then 
					self._viewMgr:showTip(lang("TIP_MAGICEYE"))		
				else
					buildingIcon:setTouchEnabled(false)
					if self._moveCallback ~= nil then 
						self._moveCallback(v)
						self:close()
					end
				end
			else
				if self._callback ~= nil then 
					self._callback(branchWithStage[v] + 1, v)
					self:close()
				end
			end
		end)
		-- x = x + dropIcon:getContentSize().width + 5

		local showRewards = nil
		if sysBranchStage.type == IntanceConst.STAGE_BRANCH_TYPE.WAR then
			showRewards = {}
			local sysBranchMonsterStage = tab:BranchMonsterStage(sysBranchStage.id)
			for i=1, 3 do
				if sysBranchMonsterStage["dropItemNum" .. i] ~= nil then 
					local tempReward = {"tool", sysBranchMonsterStage["dropItem" .. i], sysBranchMonsterStage["dropItemNum" .. i][1][1]}
					table.insert(showRewards, tempReward)
				end
			end
		else
			showRewards = sysBranchStage.reward
		end
		if isHide == 0 and showRewards ~= nil then 
			local rewards = {}
			rewards[1] = cc.Label:createWithTTF("奖励:", UIUtils.ttfName, 22)
            rewards[1]:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
			for k1,data1 in pairs(showRewards) do
				
				local itemType1 = data1[1] or data1.type
			    local itemId1 = data1[2] or data1.typeId 
			    local num1 = data1[3] or data1.num 
			    if itemType1 ~= "tool" then
			        itemId1 = IconUtils.iconIdMap[itemType1]
			    end
			    local sysItem1 = tab:Tool(itemId1)
			    local tempSp = IconUtils:createItemIconById({itemId = itemId1,itemData = sysItem1})
				tempSp:setScale(0.25)  --0.35
				table.insert(rewards, tempSp)

				local tempLab = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
				tempLab:setString(num1)
				tempLab:setColor(cc.c3b(134, 92, 48))
				table.insert(rewards, tempLab)

				local tempSp = cc.Sprite:create()
				tempSp:setContentSize(10, 10)
				table.insert(rewards, tempSp)
			end
		    local nodeTip1 = UIUtils:createHorizontalNode(rewards)
		    nodeTip1:setAnchorPoint(cc.p(0, 0.5))
		    nodeTip1:setPosition(116, 37)
		    dropBg:addChild(nodeTip1)

            local labFinishRate = cc.Label:createWithTTF("探索度+" .. sysBranchStage.rate .. "", UIUtils.ttfName, 20)
            labFinishRate:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
            labFinishRate:setAnchorPoint(0, 0.5)
            labFinishRate:setPosition(nodeTip1:getPositionX() + nodeTip1:getContentSize().width * nodeTip1:getScaleX() + 30, 37)
            dropBg:addChild(labFinishRate)
            labFinishRate:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
		end
		y = y - 115 - 5
	end
	return height, infoBg
end

function IntanceSectionInfoView:createRoleNode(inSysSectionInfo)
	local height = 20


    -- 怪兽信息
    local sysTeam = tab:Team(inSysSectionInfo.showMonster)
    local teamIcon = IconUtils:createSysTeamIconById({sysTeamData = sysTeam, eventStyle = 0})
	local labTeamDes = UIUtils:createMultiLineLabel({text = lang(sysTeam.des), color = cc.c3b(61, 31, 0),width = 470})

	local teamAreaHeight = 0
	if labTeamDes:getContentSize().height > teamIcon:getContentSize().height then 
		teamAreaHeight = labTeamDes:getContentSize().height + 15
	else
		teamAreaHeight = teamIcon:getContentSize().height
	end

	height = teamAreaHeight + height + 20

	-- 英雄信息
	local sysHero = tab:Hero(inSysSectionInfo.showHero)
	local heroIcon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. sysHero.herohead .. ".jpg")
	
	local heroBox = cc.Sprite:createWithSpriteFrameName("globalImageUI4_heroBg1.png")
	heroBox:setAnchorPoint(0.5, 0.5)
	heroIcon:setScale(0.82)
	heroBox:setScale(1.11)
	heroBox:setPosition(heroIcon:getContentSize().width/2,  heroIcon:getContentSize().height/2)
	heroIcon:addChild(heroBox)

	local labHeroDes = UIUtils:createMultiLineLabel({text = lang(sysHero.herodes), color = cc.c3b(61, 31, 0), width = 470})
	
	local heroAreaHeight = 0
	if labHeroDes:getContentSize().height > heroIcon:getContentSize().height then 
		heroAreaHeight = labHeroDes:getContentSize().height
	else
		heroAreaHeight = heroIcon:getContentSize().height
	end
	height = heroAreaHeight + height + 20

	local infoBg = cc.Sprite:create()
	infoBg:setContentSize(cc.size(668, 115))


	-- local infoTitleBg = cc.Sprite:createWithSpriteFrameName("intanceImageUI6_tmp1.png")
	-- infoTitleBg:setAnchorPoint(0, 0)
	-- infoTitleBg:setPosition(0, height)
	-- infoBg:addChild(infoTitleBg)
    local leftTmpImg = cc.Sprite:createWithSpriteFrameName("teamImageTps_listTmp1.png")
    -- leftTmpImg:setScaleX(-1)
    leftTmpImg:setAnchorPoint(1, 0.5)
    leftTmpImg:setPosition(infoBg:getContentSize().width * 0.5 - 50, height - 10)
    infoBg:addChild(leftTmpImg)


    local rightTmpImg = cc.Sprite:createWithSpriteFrameName("teamImageTps_listTmp1.png")
    rightTmpImg:setScaleX(-1)
    rightTmpImg:setAnchorPoint(1, 0.5)
    rightTmpImg:setPosition(infoBg:getContentSize().width * 0.5 + 50, height - 10)
    infoBg:addChild(rightTmpImg)

    local infoTitle = cc.Label:createWithTTF("人物信息", UIUtils.ttfName, 20)
    infoTitle:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    infoTitle:setAnchorPoint(0.5, 0.5)
    infoTitle:setPosition(infoBg:getContentSize().width * 0.5, height - 10)
    infoBg:addChild(infoTitle)




	-- local maxHeight = height + infoTitleBg:getContentSize().height
	local maxHeight = height + 22
	local labelWidth = math.max(teamIcon:getContentSize().width, heroIcon:getContentSize().width)

	height = height  - 30

	local dropBg1 = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI7_cellBg21.png") 
	dropBg1:setContentSize(cc.size(668, 115))
	dropBg1:setAnchorPoint(0, 1)
	dropBg1:setPosition(10, height)
	infoBg:addChild(dropBg1)

	teamIcon:setAnchorPoint(0, 0.5)
	teamIcon:setScale(0.81)
	teamIcon:setPosition(15, dropBg1:getContentSize().height/2)
	dropBg1:addChild(teamIcon)

	labTeamDes:setAnchorPoint(0, 1)
	labTeamDes:setPosition(labelWidth + 10, dropBg1:getContentSize().height - 20)
	dropBg1:addChild(labTeamDes)

	
	height = height - teamAreaHeight - 7

	local dropBg2 = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI7_cellBg21.png")
	dropBg2:setContentSize(cc.size(668, 115))
	dropBg2:setAnchorPoint(0, 1)
	dropBg2:setPosition(10, height)
	infoBg:addChild(dropBg2)

	heroIcon:setAnchorPoint(0, 0.5)
	heroIcon:setScale(0.84)
	heroIcon:setPosition(21, dropBg2:getContentSize().height/2)

	dropBg2:addChild(heroIcon)

	labHeroDes:setAnchorPoint(0, 1)
	labHeroDes:setPosition(labelWidth + 10, dropBg2:getContentSize().height - 20)
	dropBg2:addChild(labHeroDes)

	height = height - heroAreaHeight - 5

	return maxHeight, infoBg
end


function IntanceSectionInfoView:createProgressNode(inSysSectionInfo)
	local bgNode = cc.Node:create()
	bgNode:setName("progressNode")
	bgNode:setContentSize(688, 85)


	local intanceModel = self._modelMgr:getModel("IntanceModel")
	local sectionInfo = intanceModel:getSectionInfo(inSysSectionInfo.id)
	local maxNum = inSysSectionInfo.finishReward[1][1]
	local minNum = sectionInfo.b.num


	local labTip = cc.Label:createWithTTF("地图探索度:", UIUtils.ttfName, 22)
	labTip:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
	labTip:setAnchorPoint(0, 0)
	labTip:setPosition(0, 10)
	bgNode:addChild(labTip)

  
    local progress = ccui.LoadingBar:create("intanceImageUI_0422DayProg1.png", 1, 100)
    progress:setAnchorPoint(0.5, 0)
    progress:setPosition(350, 13)
    progress:setPercent(minNum / maxNum * 100)
    --progress:setPercent(20)
    bgNode:addChild(progress, 101)

    local progressBg = cc.Scale9Sprite:createWithSpriteFrameName("globalImageUI11_0418DayProgBg.png")
    progressBg:setCapInsets(cc.rect(27, 1, 1, 1))
    progressBg:setContentSize(457, 22)
    progressBg:setPosition(350, 10)
    progressBg:setAnchorPoint(0.5, 0)
    bgNode:addChild(progressBg, 100)
    -- :setLineBreakWithoutSpace(true)

    local progressFront = cc.Scale9Sprite:createWithSpriteFrameName("globalImageUI11_0418DayProgFront.png")
    progressFront:setCapInsets(cc.rect(18, 0, 1, 1))
    progressFront:setContentSize(457, 22)
    progressFront:setPosition(350, 10)
    progressFront:setAnchorPoint(0.5, 0)
    bgNode:addChild(progressFront, 102)
    



	local labProgress = cc.Label:createWithTTF("/" .. maxNum, UIUtils.ttfName, 20)
    labProgress:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
	labProgress:setAnchorPoint(1, 0)
	labProgress:setPosition(570, 30)
	bgNode:addChild(labProgress, 102)


    local labProgress1 = cc.Label:createWithTTF(minNum, UIUtils.ttfName, 20)
    labProgress1:setColor(UIUtils.colorTable.ccUIBaseColor2)
    labProgress1:setAnchorPoint(1, 0)
    labProgress1:setPosition(labProgress:getPositionX() -  labProgress:getContentSize().width, 30)
    bgNode:addChild(labProgress1, 102)
    labProgress1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1) 
	
	if minNum == maxNum then
		if sectionInfo.b[tostring(maxNum)] ~= nil then 
		    local rewardIcon = ccui.ImageView:create()
		    rewardIcon:loadTexture("box_3_p.png",1)
		    -- rewardIcon:setAnchorPoint(0.5, 0.5)
            rewardIcon:setPosition(624, 30)
            bgNode:addChild(rewardIcon, 105)
	        self:registerClickEvent(rewardIcon, function()    
	        	self:getBranchAcReward(inSysSectionInfo, 1)
	        end)
		else
			local animBg = ccui.Widget:create()
			animBg:setAnchorPoint(0.5, 0.5)
			animBg:setContentSize(62, 62)

            boxLight = mcMgr:createViewMC("baoxiangguang1_baoxiang", true)
            boxLight:setPosition(animBg:getContentSize().width * 0.5, animBg:getContentSize().height * 0.5)
            boxLight:setName("box_light")
            animBg:addChild(boxLight,10)

            boxAnim = mcMgr:createViewMC("baoxiang3_baoxiang", true)
            boxAnim:setPosition(animBg:getContentSize().width * 0.5, animBg:getContentSize().height * 0.5)
            animBg:addChild(boxAnim, 3)
            animBg:setPosition(624, 30)
            bgNode:addChild(animBg, 105)
 	        self:registerClickEvent(animBg, function()    
	        	self:getBranchAcReward(inSysSectionInfo)
	        end)
		end
	else
		-- lang("FINISHSTAGEAWARD_1")
		local rewardIcon = ccui.ImageView:create()
		rewardIcon:loadTexture("box_3_n.png",1)
        rewardIcon:setPosition(624, 30)
        bgNode:addChild(rewardIcon, 105)
        self:registerClickEvent(rewardIcon, function()    
        	self:getBranchAcReward(inSysSectionInfo)
        end)
	end

    print("createProgressNode==========================")
    return 85, bgNode
end



--[[
--! @function clickTreasureCase
--! @desc 点击进入奖励界面
--! @param  inSectionId 章id
--! @param  inIndex 箱子索引
--! @param  inItemId 物品id
--! @return 
--]]
function IntanceSectionInfoView:getBranchAcReward(inSysSectionInfo, inShowType)
	local intanceModel = self._modelMgr:getModel("IntanceModel")
	local sectionInfo = intanceModel:getSectionInfo(inSysSectionInfo.id)
	local needNum = inSysSectionInfo.finishReward[1][1]
	local haveNum = sectionInfo.b.num
	local sysMainSection = tab:MainSection(inSysSectionInfo.id)
    local desc = ""
    local canGet = false
    print("needNum==================", needNum)
    local viewType 
    if inShowType ~= 1 then 
        if needNum > haveNum then 
            desc = lang("FINISHSTAGEAWARD_3")
            viewType = 1
        else
            desc = lang("FINISHSTAGEAWARD_4")
            
            canGet = true
        end
    else
        desc = lang("FINISHSTAGEAWARD_4")
        viewType = 1
    end

    local result,count = string.gsub(desc, "$num1", needNum)
    if count > 0 then 
        desc = result
    end
    local result,count = string.gsub(desc, "$num", haveNum)
    if count > 0 then 
        desc = result
    end

    local tab2 = self:getUI("bg.bg1.tab2")
    if tab2.tip ~= nil then 
        tab2.tip:removeFromParent()
        tab2.tip = nil
    end

    local function showGiftGet(inBtnTitle)
        DialogUtils.showGiftGet( {
        gifts = inSysSectionInfo.finishReward[1][2],
        viewType = viewType,
        canGet = canGet, 
        des = desc,
        title = lang("FINISHSTAGETITLE"),
        btnTitle = inBtnTitle, 
        callback = function()
        end,
        notPop = not viewType})
    end
    if inShowType == nil then
        if viewType == nil then 
            local param = {gear = needNum, sectionId = inSysSectionInfo.id}
            self._serverMgr:sendMsg("StageServer", "getBranchAcReward", param, true, {}, function (result)
                showGiftGet()
			    local tmpProgressNode = self._scrollBg:getChildByName("progressNode")

			    local _, progressNode = self:createProgressNode(inSysSectionInfo)
			    progressNode:setAnchorPoint(0, 0)
			    progressNode:setPosition(tmpProgressNode:getPositionX(), tmpProgressNode:getPositionY())
			    self._scrollBg:addChild(progressNode)
			    tmpProgressNode:removeFromParent()
			    if self._updateCallback ~= nil then 
			    	self._updateCallback()
			    end
            end)
        else 
            showGiftGet()
        end
    else
        showGiftGet("已领取")
    end
end

return IntanceSectionInfoView