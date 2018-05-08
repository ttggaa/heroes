--
-- Author: huangguofang
-- Date: 2018-03-13 16:43:14
--

local TeamHolyDetailDialog = class("TeamHolyDetailDialog", BasePopView)
function TeamHolyDetailDialog:ctor(params)
    self.super.ctor(self)

    self._teamId = params.teamData and params.teamData.teamId 
    self._teamData = params.teamData
	self._runes = params.runes
	-- dump(self._runes,"self._runes===>",5)
    self._teamModel = self._modelMgr:getModel("TeamModel")    

end

-- 初始化UI后会调用, 有需要请覆盖
function TeamHolyDetailDialog:onInit()
	self:registerClickEventByName("bg.layer.btn_close", function()
        self:close()
        UIUtils:reloadLuaFile("team.TeamHolyDetailDialog")
    end)
    --配表 兵团信息
    self._teamTableData = tab:Team(tonumber(self._teamId))

    self._title = self:getUI("bg.layer.titleBg.title")
    self._title:setString("圣徽信息")
    UIUtils:setTitleFormat(self._title, 1)

    self._teamInfo1 = self:getUI("bg.layer.layer_right.team_info_1")
    local label_title1 = self:getUI("bg.layer.layer_right.team_info_1.label_title")
    UIUtils:setTitleFormat(label_title1, 3)
    self._teamInfo2 = self:getUI("bg.layer.layer_right.team_info_2")
    local label_title2 = self:getUI("bg.layer.layer_right.team_info_2.label_title")
    UIUtils:setTitleFormat(label_title2, 3)

    self._isAwaking,self._awakingLvl = TeamUtils:getTeamAwaking(self._teamData)
    self._holyData = self:processData(self._runes)
    self:updateLeftPanel()
    self:updateRightPanel()
end

function TeamHolyDetailDialog:updateLeftPanel()
    --   名字、头像、立汇、小人、动画小人
    --   teamName, art1, art2, art3 ,art4
    local teamName = self._teamTableData.name
    local steam = self._teamTableData.steam
    if self._isAwaking then
        teamName,_,_,steam = TeamUtils:getTeamAwakingTab(self._teamData)
    end
    
    local teamImg = self:getUI("bg.layer.layer_left.teamPanel.team_img")
    teamImg:loadTexture("asset/uiother/steam/" .. steam .. ".png")
    teamImg:setScale(0.8)
    --  team  race$cs   data[1]   race表 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_left.teamPanel.image_body_bg")
    local receData = self._teamTableData.race
    local race = tab:Race(receData[1]).pic
    image_body_bg:loadTexture("asset/uiother/race/race_" .. race ..".png")

    local image_body_bottom = self:getUI("bg.layer.layer_left.teamPanel.image_body_bottom")
    if image_body_bottom then
        local filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
        if receData[1] then
            filePath = "asset/uiother/dizuo/teamBgDizuo" .. receData[1] .. ".png"
            if not cc.FileUtils:getInstance():isFileExist(filePath) then
                filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
            end
        end
        image_body_bottom:loadTexture(filePath, 0)
    end

    self:updateLeftStone()

end
--设置兵团圣徽镶嵌状态
function TeamHolyDetailDialog:updateLeftStone()
    local rune = self._teamData.rune or {}
    local holyData = self._holyData 

    for i=1,6 do
    	local indexId = tostring(i)
        local item = self:getUI("bg.layer.layer_left.holyPanel.item" .. i)		

        if rune and rune[indexId] and rune[indexId] ~= 0 then
            local key = rune[indexId]
            local holyId = holyData[key].id

            local runeTab = tab:Rune(holyId) 
	        local param = {suitData = runeTab,stoneData = holyData[key]}
	        holyIcon = IconUtils:createHolyIconById(param)
            holyIcon:setScale(0.75)
            holyIcon:setAnchorPoint(0.5,0.5)
            holyIcon:setScaleAnim(true)
            holyIcon:setPosition(45, 45)
            item:addChild(holyIcon, 1)
            self:registerClickEvent(holyIcon, function()
	            local key = rune[tostring(i)]
				if key and key ~= 0 then
					local holyId = holyData[key].id
					local tabData = tab.rune[holyId]
					local score = self._teamData.score
					
					local param = { teamId = self._teamId, 
									selectStone = i, 
									key = key, 
									holyData = tabData,
									hintType = 6,
									runes = self._holyData,
									teamData = self._teamData,
									runesData = holyData,
									callback = function()
							
									end}
					param.isHideBtn = true
					UIUtils:reloadLuaFile("team.TeamHolyTipView")
					self._viewMgr:showHintView("team.TeamHolyTipView", param)
				end
		    end)
	    else
	 		local holyGrid = ccui.Widget:create()
		    holyGrid:setContentSize(cc.size(90,90))
		    -- holyGrid:setAnchorPoint(0.5,0.5)
		    local holyGridFrame = ccui.ImageView:create()
		    holyGridFrame:loadTexture("globalImageUI4_iquality0.png", 1)
		    holyGridFrame:setName("holyGridFrame")
		    holyGridFrame:setContentSize(cc.size(107, 107))
		    holyGridFrame:setAnchorPoint(0,0)
		    holyGridFrame:setPosition(3,3)
		    holyGrid:addChild(holyGridFrame,1)
		    local holyGridBg = ccui.ImageView:create()
		    holyGridBg:loadTexture("globalImageUI_quality0.png", 1)
		    holyGridBg:setName("holyGridBg")
		    holyGridBg:ignoreContentAdaptWithSize(false)
		    holyGridBg:setContentSize(cc.size(90, 90))
		    holyGridBg:setAnchorPoint(0.5,0.5)
		    -- holyGridBg
		    holyGridBg:setPosition(48,48)
		    holyGrid:addChild(holyGridBg,-1)
		    holyGrid:setScale(0.77)
		    holyGrid:setPosition(42, 42)
		    item:addChild(holyGrid, 20)
        end        
    end
end

function TeamHolyDetailDialog:updateRightPanel()
	self:updateRightAttr()
	self:updateShowNature()
end

--设置属性数据
function TeamHolyDetailDialog:updateRightAttr()
	local propScroll = self:getUI("bg.layer.layer_right.propertyScroll")
	-- propScroll:removeAllChildren()
	-- propScroll:setInnerContainerSize(propScroll:getContentSize())
    local holyBaseAttr, holyAddAttr = self._teamModel:getStoneAttrByParam(self._teamData.rune,self._runes)

    local baseAttr = {}
	local addAttr = {}

    for n = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
        if holyBaseAttr[n] ~= 0 then
            table.insert(baseAttr, UIUtils:getAttrStrWithAttrName(n, holyBaseAttr[n]))
        end
		if holyAddAttr[n] ~= 0 then
            table.insert(addAttr, UIUtils:getAttrStrWithAttrName(n, holyAddAttr[n]))
        end
    end
	
	local baseTitle = cc.Label:createWithTTF("基础属性", UIUtils.ttfName, 24)
	baseTitle:setAnchorPoint(0.5, 0)
	local totalHeight = baseTitle:getContentSize().height + 10
	baseTitle:setColor(cc.c3b(138, 92, 29))
	propScroll:addChild(baseTitle)
	
	local baseLineImg = ccui.ImageView:create()
	baseLineImg:loadTexture("globalImageUI12_cutline2.png",1)
	--	baseLineImg:setVisible(true)
	baseLineImg:setAnchorPoint(0.5, 0)
	totalHeight = totalHeight + baseLineImg:getContentSize().height+5
	propScroll:addChild(baseLineImg)
	local containerSize = propScroll:getInnerContainerSize()
	
	local baseAttrLab = {}
	local tipLab
	if table.nums(baseAttr)>0 then
		for i,v in ipairs(baseAttr) do
			local baseLabel = cc.Label:createWithTTF(v, UIUtils.ttfName, 18)
			baseLabel:setAnchorPoint(0, 0)
			baseLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
			local height = baseLabel:getContentSize().height
			if i%2==1 then
				totalHeight = totalHeight + height + 5
			end
			propScroll:addChild(baseLabel)
			table.insert(baseAttrLab, baseLabel)
		end
	else
		tipLab = cc.Label:createWithTTF("暂未镶嵌任何圣徽", UIUtils.ttfName, 18)
		tipLab:setAnchorPoint(0.5, 0)
		tipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
		local height = tipLab:getContentSize().height
		totalHeight = totalHeight + height + 15
		propScroll:addChild(tipLab)
	end
	
	local plusTitle = cc.Label:createWithTTF("附加属性", UIUtils.ttfName, 24)
	plusTitle:setAnchorPoint(0.5, 0)
	totalHeight = totalHeight + plusTitle:getContentSize().height + 20
	plusTitle:setColor(cc.c3b(138, 92, 29))
	propScroll:addChild(plusTitle)
	
	local plusLineImg = ccui.ImageView:create()
	plusLineImg:loadTexture("globalImageUI12_cutline2.png",1)
	--	plusLineImg:setVisible(true)
	plusLineImg:setAnchorPoint(0.5, 0)
	totalHeight = totalHeight + plusLineImg:getContentSize().height+5
	propScroll:addChild(plusLineImg)
	
	local plusTipLab
	local addAttrLab = {}
	if table.nums(addAttr)==0 then
		plusTipLab = cc.Label:createWithTTF("暂未镶嵌任何圣徽", UIUtils.ttfName, 18)
		plusTipLab:setAnchorPoint(0.5, 0)
		plusTipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
		local height = plusTipLab:getContentSize().height
		totalHeight = totalHeight + height + 15
		propScroll:addChild(plusTipLab)
		
	else
		for i,v in ipairs(addAttr) do
			local addLab = cc.Label:createWithTTF(v, UIUtils.ttfName, 18)
			addLab:setAnchorPoint(0, 0)
			addLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
			local height = addLab:getContentSize().height
			if i%2==1 then
				totalHeight = totalHeight + height + 5
			end
			propScroll:addChild(addLab)
			table.insert(addAttrLab, addLab)
		end
	end
	
	if totalHeight>containerSize.height then
		propScroll:setInnerContainerSize(cc.size(containerSize.width, totalHeight))
		containerSize.height = totalHeight
		propScroll:jumpToPercentVertical(0)
	end
	
	--设置坐标
	baseTitle:setPosition(cc.p(containerSize.width/2, containerSize.height-baseTitle:getContentSize().height-10))
	baseLineImg:setPosition(cc.p(containerSize.width/2, baseTitle:getPositionY()-baseLineImg:getContentSize().height-5))
	local countLine = 0
	local posY = baseLineImg:getPositionY()
	if table.nums(baseAttr)>0 then
		for i,v in ipairs(baseAttrLab) do
			local posX = containerSize.width/2+15
			if i%2==1 then
				posX = 15
				posY = posY-v:getContentSize().height-5
			end
			v:setPosition(cc.p(posX, posY))
		end
	else
		posY = posY - tipLab:getContentSize().height - 15
		tipLab:setPosition(cc.p(containerSize.width/2, posY))
	end
	plusTitle:setPosition(cc.p(containerSize.width/2, posY - plusTitle:getContentSize().height-20))
	plusLineImg:setPosition(cc.p(containerSize.width/2, plusTitle:getPositionY()-plusLineImg:getContentSize().height-5))
	if table.nums(addAttr)==0 then
		plusTipLab:setPosition(cc.p(containerSize.width/2, plusLineImg:getPositionY()-plusTipLab:getContentSize().height-15))
	else
		posY = plusLineImg:getPositionY()
		for i,v in ipairs(addAttrLab) do
			local posX = containerSize.width/2+15
			if i%2==1 then
				posX = 15
				posY = posY-v:getContentSize().height-5
			end
			v:setPosition(cc.p(posX, posY))
		end
	end
end

--设置套装
function TeamHolyDetailDialog:updateShowNature()
	-- if true then return end
	local suitData, backNum = self._teamModel:getTeamSuitByDataAndParam(self._teamData,self._holyData)
	-- [[suitData[102] = {[2] = 10204}
	-- suitData[103] = {[2] = 10305}
	local suitScroll = self:getUI("bg.layer.layer_right.suitScroll")
	local suitTipLab = self:getUI("bg.layer.layer_right.suitTipLab")
	
	-- dump(suitData,"suitData==>",5)
	local effectTab = tab:Setting("GEM_EFFECT_NUM").value
	local count = 0
	local hight = 0
	for k,v in pairs(suitData) do
		if table.nums(v)>0 then
			local suitTab = tab:RuneClient(k)			
			for _, data in ipairs(v) do
				count = count + 1
				local stoneTab = tab:Rune(data.stoneId)
				local quality = stoneTab.quality
				local amountStr = data.suitNum.."/"..data.suitNum
				local param = {quality = quality, noAmountStr = true, amountStr = amountStr, tabConfig = suitTab}
				local itemNode = IconUtils:createTeamHolySuitIcon(param)
				itemNode:setName("itemNode"..count)
				itemNode:setPosition(cc.p(16*count + (count*2-1)/2*itemNode:getContentSize().width, suitScroll:getContentSize().height/2+10))
				suitScroll:addChild(itemNode)

			end
		end
	end
	
	suitScroll:setVisible(count>0)
	suitTipLab:setVisible(count==0)
end
-- 接收自定义消息
function TeamHolyDetailDialog:reflashUI(data)

end

-- 处理圣徽仓库里的runes数据
function TeamHolyDetailDialog:processData( data )
	local backData = {}
	-- dump(data,"runes--")
    for k,v in pairs(data) do
    	local value = clone(v)
        local indexId = tonumber(k)
        local runeId = v.id 
        local runeTab = tab:Rune(runeId)
        value.quality = runeTab.quality 
        value.jackType = runeTab.type  
        value.make = runeTab.make
        if v.p and type(v.p) ~= "" then 
       		value.p = json.decode(v.p)
       	else
       		value.p = {}
       	end
        value.key = indexId
        backData[indexId] = value
    end
    return backData
end

-- 
--[[
--! @function getStoneAttrByParam
--! @desc 获取兵团套装
--! @param  teamData 装备圣徽  runes 仓库里已有圣徽
--! @return 
--]]
--[[ 
function TeamHolyDetailDialog:getTeamSuitByParam(teamData,runes)
    if not teamData then
        return 
    end
    -- local suitData = self:getSuitDataByTeam(teamData)

    local rune = teamData.rune or {}
    -- dump(rune,"--->rune",4)
    -- dump(runes,"--->runes",5)
    local suitData = {}
    for i=1,6 do
        local indexId = tostring(i)
        if rune and rune[indexId] and rune[indexId] ~= 0 then
            local stoneKey = rune[indexId]
            local stoneData = runes[tonumber(stoneKey)]
            local stoneId = stoneData.id
            local make = stoneData.make
            if not suitData[make] then
                suitData[make] = {}
            end
            table.insert(suitData[make], stoneData)
        end
    end

    -- dump(suitData,"suitData==>",5)

    local backData = {}
    local backNum = {}
    local effectTab = tab:Setting("GEM_EFFECT_NUM").value
    for k,v in pairs(suitData) do
        local sortFunc = function(a, b)
            local aquality = a.quality
            local bquality = b.quality
            local aid = a.id
            local bid = b.id
            local akey = a.key
            local bkey = b.key
            if aquality ~= bquality then
                return aquality > bquality
            elseif aid ~= bid then
                return aid < bid
            elseif akey ~= bkey then
                return akey < bkey
            end
        end
        table.sort(v, sortFunc)
        -- dump(v,"vvvvvv",5)
        local _suitData = {}
        local strNum = table.nums(v)
        if table.nums(v) >= effectTab[3] then
            strNum = strNum .. "/6"
            _suitData[2] = v[2]["id"]
            _suitData[4] = v[4]["id"]
            _suitData[6] = v[6]["id"]
        elseif table.nums(v) >= effectTab[2] then
            strNum = strNum .. "/4"
            _suitData[2] = v[2]["id"]
            _suitData[4] = v[4]["id"]
        elseif table.nums(v) >= effectTab[1] then
            strNum = strNum .. "/2"
            _suitData[2] = v[2]["id"]
        end
        backNum[k] = strNum
        backData[k] = _suitData
    end

    return backData, backNum
end 
--]]

return TeamHolyDetailDialog