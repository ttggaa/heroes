--
-- Author: huangguofang
-- Date: 2018-03-15 19:23:16
--
local AcLuckyLotteryDialog = class("AcLuckyLotteryDialog",BasePopView)
function AcLuckyLotteryDialog:ctor(param)
    self.super.ctor(self)
    self.initAnimType = 1
    print("================initAnimType===",self.initAnimType)
    self._runeLotteryModel = self._modelMgr:getModel("RuneLotteryModel")
	self._runeLotteryProModel = self._modelMgr:getModel("RuneLotteryProModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._closeCallBack = param.closeCallBack
    self._viewType = 1
end
function AcLuckyLotteryDialog:getAsyncRes()
    return 
    {
        {"asset/ui/acLuckyLottery.plist", "asset/ui/acLuckyLottery.png"},
    }
end

-- function AcLuckyLotteryDialog:getBgName()
--     return "acLuckyLottery_bg_img.jpg"
-- end

function AcLuckyLotteryDialog:onDestroy()
    AcLuckyLotteryDialog.super.onDestroy(self)
    
end

-- 第一次被加到父节点时候调用
function AcLuckyLotteryDialog:onAdd()

end

function AcLuckyLotteryDialog:onInit()
    print("===============幸运夺宝==============")
    self._limitNum = tab:Setting("GEM_BACKPACK_CAPPED").value
    self._bg = self:getUI("bg")
    local bgImg = self:getUI("bg.bgImg")
    bgImg:loadTexture("asset/bg/acLuckyLottery_bg_img.jpg")
    local w = bgImg:getContentSize().width
    local h = bgImg:getContentSize().height
    local scaleW = MAX_SCREEN_WIDTH / w
    local scaleH = MAX_SCREEN_HEIGHT / h
    -- 背景图片适配
    bgImg:setScale(scaleW > scaleH and scaleW or scaleH)

    self._closeBtn = self:getUI("bg.bg1.closeBtn")
    self:registerClickEvent(self._closeBtn, function ()
        self:close()
        if self._closeCallBack then
            self._closeCallBack()
        end
        UIUtils:reloadLuaFile("activity.acLuckyLottery.AcLuckyLotteryDialog")
    end)

    local rightPanel = self:getUI("bg.bg1.rightPanel")
    rightPanel:setSwallowTouches(false)
    self:registerClickEventByName("bg.bg1.leftPanel.luckyBtn", function ()
        DialogUtils.showBuyRes({goalType = "luckyCoin"})
    end)
    self:registerClickEventByName("bg.bg1.leftPanel.gemBtn", function ()
        DialogUtils.showBuyRes({goalType = "gem"})
    end) 
    self._luckyNum = self:getUI("bg.bg1.leftPanel.luckyNum")
    self._diamondNum = self:getUI("bg.bg1.leftPanel.diamondNum")

    self._hotPanel  = self:getUI("bg.bg1.leftPanel.btnPanel.hotPanel")
    self._cdTxt     = self:getUI("bg.bg1.leftPanel.btnPanel.cdTxt")
    self._ruleBtn   = self:getUI("bg.bg1.leftPanel.btnPanel.ruleBtn")
    self:registerClickEvent(self._ruleBtn, function () 
    --  
        print("============打开规则界面======")
        self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = lang("runeLottery_rule")},true)
    end)
    self._itemArr = {}
    self._lotteryPanel = self:getUI("bg.bg1.leftPanel.lotteryPanel")
    for i=1,14 do
        local item = self:getUI("bg.bg1.leftPanel.lotteryPanel.item" .. i)
        if i == 1 then
            item:loadTexture("acLuckyLottery_selected_img.png",1)
        end
        self._itemArr[i] = item
        self._itemArr[i]._index = i
    end
    self._buyBgImg = self:getUI("bg.bg1.leftPanel.lotteryPanel.buyBgImg")
    self._buyPanel = self:getUI("bg.bg1.leftPanel.lotteryPanel.buyPanel")


    self:onInitBuyPanel()
    -- 字色
    self:updateBuyBtnCost()

    self:registerClickEvent(self._buyBtn1, function ()
        self._buyNum = 1
        self:lotteryBtnClicked()
    end)
    self:registerClickEvent(self._buyBtn5, function ()
        self._buyNum = 5
        self:lotteryBtnClicked()
    end)

    self._exchangeBtn = self:getUI("bg.bg1.leftPanel.exchangeBtn")
    UIUtils:addFuncBtnName( self._exchangeBtn,"热点商店",nil,true,16)
    self:registerClickEvent(self._exchangeBtn, function ()
        print("============打开兑换界面======")
		if self._viewType==1 then
			if not self._runeLotteryModel:isLotteryOpen() then
				self._viewMgr:showTip("幸运夺宝活动已结束")
				return
			end
			self._viewMgr:showView("activity.acLuckyLottery.AcLuckyLotteryShopDialog", {viewType = 1})
		else
			if not self._runeLotteryProModel:isLotteryOpen() then
				self._viewMgr:showTip("幸运夺宝活动已结束")
				return
			end
			if OS_IS_WINDOWS then
				UIUtils:reloadLuaFile("activity.acLuckyLottery.AcLuckyLotteryShopDialog")
			end
			self._viewMgr:showView("activity.acLuckyLottery.AcLuckyLotteryShopDialog", {viewType = 2})
		end
    end)
    self._goodsData     = self._runeLotteryModel:getGoodsData() or {}
    self._serverData    = self._runeLotteryModel:getLotteryData() or {}
    self._rewardData    = self._runeLotteryModel:getRewardData() or {}
    self._hotData       = self._rewardData.rewardDisplay or {}
    self:initLeftPanel()
    self:initRightPanel()

    -- local timeTxt = self:getUI("bg.bg1.leftPanel.btnPanel.timeTxt")
    -- timeTxt:setString("服务器")
	
	local lotteryProModel = self._modelMgr:getModel("RuneLotteryProModel")
	for i=1, 2 do
		local tabBtn = self:getUI("bg.bg1.leftPanel.tabBtn"..i)
		self:registerClickEvent(tabBtn, function()
			for i=1, 2 do
				local tempTabBtn = self:getUI("bg.bg1.leftPanel.tabBtn"..i)
				if tempTabBtn:getName()~=tabBtn:getName() then
					tempTabBtn:setEnabled(true)
					tempTabBtn:setBright(true)
					break
				end
			end
			self._viewType = i
			tabBtn:setEnabled(false)
			tabBtn:setBright(false)
			self:reloadViewData()
		end)
		tabBtn:setEnabled(i~=1)
		tabBtn:setBright(i~=1)
		if not lotteryProModel:isLotteryProOpen() and i==2 then
			tabBtn:setEnabled(false)
			tabBtn:setBright(false)
			tabBtn:setSaturation(-100)
		else
			self._serverMgr:sendMsg("RuneLotteryProServer", "getInfo", {}, true, {}, function(result)
				-- 播放动画
--				self._viewMgr:showTip("ssssssssssss")
			end)
		end
	end

    -- 倒计时
    self:reflashCD()
    self._timer = ScheduleMgr:regSchedule(1000, self, function( )
        self:reflashCD()
    end)

    self:listenReflash("UserModel", self.updateBuyBtnCost)
end

function AcLuckyLotteryDialog:onInitBuyPanel()
	local costData1, costData5
	if self._viewType==1 then
		costData1 = tab:Setting("GEM_LOTTERY_NUM_1").value
		costData5 = tab:Setting("GEM_LOTTERY_NUM_5").value
	else
		costData1 = tab:Setting("GEM_LOTTERYPRO_NUM_1").value
		costData5 = tab:Setting("GEM_LOTTERYPRO_NUM_5").value
	end
	self._costType = costData1[1][1]

	self._buyBtn1 = self:getUI("bg.bg1.leftPanel.lotteryPanel.buyPanel.buyBtn1")
	self._buyBtn1Cost = self:getUI("bg.bg1.leftPanel.lotteryPanel.buyPanel.buyBtn1.costNum")
	self._buyBtnCostNum1 = costData1[1][3]
	self._buyBtn1Cost:setString(costData1[1][3] or 0)
	self._buyBtn1Cost:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)    
	local buyBtn1Txt1 = self:getUI("bg.bg1.leftPanel.lotteryPanel.buyPanel.buyBtn1.getTxt1")
	buyBtn1Txt1:setString("购买".. (costData1[2][3] or 0) .. "灵魂石")
	local buyBtn1Txt2 = self:getUI("bg.bg1.leftPanel.lotteryPanel.buyPanel.buyBtn1.getTxt2")
	buyBtn1Txt2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	local costType1 = self:getUI("bg.bg1.leftPanel.lotteryPanel.buyPanel.buyBtn1.costType")
	costType1:loadTexture(IconUtils.resImgMap[self._costType],1)
	self._costTypeOne = costType1
	self._freeLabel = self:getUI("bg.bg1.leftPanel.lotteryPanel.buyPanel.buyBtn1.freeLabel")
	self._freeLabel:setColor(UIUtils.colorTable.ccUIBaseColor2)
	self._freeLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

	self._buyBtn5 = self:getUI("bg.bg1.leftPanel.lotteryPanel.buyPanel.buyBtn5")
	self._buyBtn5Cost = self:getUI("bg.bg1.leftPanel.lotteryPanel.buyPanel.buyBtn5.costNum")
	self._buyBtnCostNum5 = costData5[1][3]
	self._buyBtn5Cost:setString(costData5[1][3] or 0)
	self._buyBtn5Cost:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	local buyBtn5Txt1 = self:getUI("bg.bg1.leftPanel.lotteryPanel.buyPanel.buyBtn5.getTxt1")
	buyBtn5Txt1:setString("购买".. (costData5[2][3] or 0) .. "灵魂石")
	local buyBtn5Txt2 = self:getUI("bg.bg1.leftPanel.lotteryPanel.buyPanel.buyBtn5.getTxt2")
	buyBtn5Txt2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	local costType5 = self:getUI("bg.bg1.leftPanel.lotteryPanel.buyPanel.buyBtn5.costType")
	costType5:loadTexture(IconUtils.resImgMap[self._costType],1)
end

function AcLuckyLotteryDialog:reloadViewData()
	local model = self._viewType==1 and self._runeLotteryModel or self._runeLotteryProModel
	self._goodsData = model:getGoodsData() or {}
	self._serverData = model:getLotteryData() or {}
	self._rewardData = model:getRewardData() or {}
	self._hotData = self._rewardData.rewardDisplay or {}
	self:onInitBuyPanel()
	self:initLeftPanel()
	self:initRightPanel()
	self:updateDataAndPanel()
end

function AcLuckyLotteryDialog:reflashCD()

    local currentTime = self._userModel:getCurServerTime()
    local endTime = self._serverData.endTime or 1521320400

    local remainTime = endTime - currentTime

    local tempValue = remainTime    
    local day = math.floor(tempValue/86400) 
    tempValue = tempValue - day*86400
    
    local hour = math.floor(tempValue/3600)
    tempValue = tempValue - hour*3600

    local minute = math.floor(tempValue/60)
    tempValue = tempValue - minute*60
   
    local second = math.fmod(tempValue, 60)
    local showTime = string.format("%.2d天%.2d:%.2d:%.2d", day, hour, minute, second)
    if day == 0 then
        showTime = string.format("00天%.2d:%.2d:%.2d", hour, minute, second)
    end
    if remainTime <= 0 then
        if self._timer then
            ScheduleMgr:unregSchedule(self._timer)
            self._timer = nil
        end
        showTime = "00天00:00:00"
    end
    self._cdTxt:setString(showTime)

end

function AcLuckyLotteryDialog:initLeftPanel()
    -- dump(self._goodsData,"self._goodsData==>",5)
    -- dump(self._serverData,"self._serverData==>",5)
    -- dump(self._hotData,"self._hotData==>",5)
    -- 热点显示
    local height = self._hotPanel:getContentSize().height
    local width  = self._hotPanel:getContentSize().width
    local iconH = 120
    local posX = (width - 90)*0.5
    local posY = height - iconH + 10
    local rewardNum = #self._hotData
	
	self._hotPanel:removeAllChildren()
	
    for k,v in ipairs(self._hotData) do        
        local icon        
        local itemId 
        local reward = v
        local itemId = reward[2]
        local rType = reward[1]
        local itemNum = reward[3]
        local nameStr = ""
        local qualityNum = 1
        if type(reward[2]) == "string" then
            local dataTemp = itemType[tonumber(acOpenId)]
            itemId = dataTemp[reward[2]][2]
            rType = dataTemp[reward[2]][1]
            -- print("===========reward[2]===",reward[2])
        end

        if rType == "siegeProp" then
            local propsTab = tab:SiegeEquip(itemId)
            local param = {itemId = itemId, level = 1, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 1}
            icon = IconUtils:createWeaponsBagItemIcon(param)
            local iconColor = icon:getChildByName("iconColor")
            if iconColor and iconColor.lvlLabel then
                iconColor.lvlLabel:setVisible(false)
            end
            nameStr = lang(propsTab.name)
            icon:setName("icon" .. k)
            icon:setScale(0.9)
            qualityNum = propsTab.quality
        else
            if rType == "tool"then
                local toolD = tab:Tool(tonumber(itemId))
                icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = itemNum})
                icon:setScale(0.9)
                nameStr = lang(toolD.name)
                qualityNum = ItemUtils.findResIconColor(itemId,1)

            elseif rType == "rune" then
                -- print("==================itemId====",itemId)
                local itemData = tab:Rune(itemId)
                icon = IconUtils:createHolyIconById({suitData = itemData})
                icon:setScale(0.9)
                if icon.holyIcon and itemData.make then
                    local makeData = tab:RuneClient(itemData.make)
                    if makeData and makeData.icon then
                        icon.holyIcon:loadTexture(makeData.icon .. ".png",1)
                    end
                end
                nameStr = lang(itemData.name)
                qualityNum = itemData.quality
            else
                itemId = IconUtils.iconIdMap[rType]
                local toolD = tab:Tool(tonumber(itemId))
                icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = itemNum})
                icon:setScale(0.9)
                nameStr = lang(toolD.name)
                qualityNum = ItemUtils.findResIconColor(itemId,1)
            end
        end
        if itemNum and itemNum > 1 then
            nameStr = nameStr .. "x" .. itemNum
        end
        icon:setPosition(posX,posY)
        icon:setAnchorPoint(0,0)
        self._hotPanel:addChild(icon)

        local boxIcon = icon.boxIcon
        local iconColor = icon.iconColor
        if boxIcon then
            boxIcon:setVisible(false)
        end
        if iconColor then
            iconColor:setVisible(false)
        end
        local nameTxt = ccui.Text:create()
        nameTxt:setFontSize(20)
        nameTxt:setFontName(UIUtils.ttfName)
        nameTxt:setString(nameStr)
        nameTxt:setColor(UIUtils.colorTable["ccColorQuality" .. qualityNum])
        nameTxt:setPosition(icon:getContentSize().width*0.5,0)
        nameTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        icon:addChild(nameTxt,5)
        icon._nameTxt = nameTxt
        if k ~= rewardNum then
            -- print("================11111====",posY)
            local imgLine = ccui.ImageView:create()
            imgLine:loadTexture("acLuckyLottery_line_img.png", 1)
            imgLine:setPosition(width*0.5,posY - 25)
            posY = posY - 20
            self._hotPanel:addChild(imgLine)
        end  
        posY = posY - iconH

    end
	
	self:initLuckDraw()

    -- 设置幸运值
    local numTxt = self:getUI("bg.bg1.leftPanel.lotteryPanel.buyPanel.numTxt")
    numTxt:setVisible(false)
	
	local luckyTxt = self._buyPanel:getChildByName("luckyText")
	if luckyTxt then
		luckyTxt:removeFromParent()
	end
    local num = self._serverData.luckyScore or 0
    luckyTxt = cc.LabelBMFont:create(num, UIUtils.bmfName_Lottery)
    luckyTxt:setScale(0.45)
	luckyTxt:setName("luckyText")
    luckyTxt:setAnchorPoint(cc.p(0,0.5))
    luckyTxt:setPosition(numTxt:getPositionX()-5,numTxt:getPositionY()+6)
    self._buyPanel:addChild(luckyTxt, 1)
    self._numTxt = luckyTxt
end

function AcLuckyLotteryDialog:initLuckDraw()-- 初始化item
	local acOpenId = self._runeLotteryModel:getAcOpenID()
	if self._viewType==2 then
		acOpenId = self._runeLotteryProModel:getAcOpenID()
	end
	local itemType = tab.itemType
	for k,v in ipairs(self._goodsData) do
		local index = v.grid and v.grid[1] or 1
		local item = self._itemArr[index]
		item:removeAllChildren()
		local reward = v.itemId
		local rType = reward[1]
		local icon
		local itemId = reward[2]
		local nameStr = ""
		local qualityNum = 1
		local itemNum = reward[3]
		if type(reward[2]) == "string" then
			local dataTemp = itemType[tonumber(acOpenId)]--]]
				itemId = dataTemp[reward[2]][2]
				rType = dataTemp[reward[2]][1]
		end
		if rType == "siegeProp" then
			local propsTab = tab:SiegeEquip(itemId)
			nameStr = lang(propsTab.name)
			qualityNum = propsTab.quality
			local param = {itemId = itemId, level = 1, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 1}
			icon = IconUtils:createWeaponsBagItemIcon(param)
			local iconColor = icon:getChildByName("iconColor")
			if iconColor and iconColor.lvlLabel then
				iconColor.lvlLabel:setVisible(false)
			end
			icon:setName("icon" .. k)
			icon:setScale(0.9)
		else
			if rType == "tool"then
				local toolD = tab:Tool(tonumber(itemId))
				icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = itemNum})
				icon:setScale(0.9)
				nameStr = lang(toolD.name)
				qualityNum = ItemUtils.findResIconColor(itemId,1)
			elseif rType == "rune" then                
				local itemData = tab:Rune(itemId)
				icon =IconUtils:createHolyIconById({suitData = itemData})
				icon:setScale(0.9)
				nameStr = lang(itemData.name)
				qualityNum = itemData.quality
			else
				itemId = IconUtils.iconIdMap[rType]
				local toolD = tab:Tool(tonumber(itemId))
				icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = itemNum})
				icon:setScale(0.9)
				nameStr = lang(toolD.name)
				qualityNum = ItemUtils.findResIconColor(itemId,1)
			end
			
		end
		local boxIcon = icon.boxIcon
		local iconColor = icon.iconColor
		if boxIcon then
			boxIcon:setVisible(false)
		end
		if iconColor then
			iconColor:setVisible(false)
			if icon._isSplice then
				local iconMark = iconColor.iconMark
				if iconMark then
					local iconMarkCopy = iconMark:clone()
					icon:addChild(iconMarkCopy,10)
				end
			end
		end
		icon:setAnchorPoint(0.5,0.5)
		icon:setScaleAnim(true)
		icon:setPosition(item:getContentSize().width*0.5, item:getContentSize().height*0.5)
		item.__icon = icon 
		item:addChild(icon,5) 

		local selectAnim = mcMgr:createViewMC("xuanzhuanguang_xingyunduobao", false,false)
		selectAnim:setPosition(69, 50)
		selectAnim:setVisible(false)
		item:addChild(selectAnim,1)
		item._selectAnim = selectAnim

		local nameTxt = ccui.Text:create()
		nameTxt:setFontSize(14)
		nameTxt:setFontName(UIUtils.ttfName)
		nameTxt:setString(nameStr)
		if itemNum > 1 then
		  nameTxt:setString(nameStr .. "x" .. itemNum)  
		end
		nameTxt:setColor(UIUtils.colorTable["ccColorQuality" .. qualityNum])
		nameTxt:setPosition(item:getContentSize().width*0.5,15)
		nameTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
		item:addChild(nameTxt,5)
		item._nameTxt = nameTxt
	end
end

function AcLuckyLotteryDialog:initRightPanel()
    -- self._serverData

    local mcName = {
        [1] = "baoxiang1_baoxiang",
        [2] = "baoxiang2_baoxiang",
        [3] = "baoxiang2_baoxiang",
        [4] = "baoxiang3_baoxiang",
        [5] = "baoxiang3_baoxiang",
    }
    local normalImg = {
        [1] = "box_1_n",
        [2] = "box_2_n",
        [3] = "box_2_n",
        [4] = "box_3_n",
        [5] = "box_3_n",
    }
    local getImg = {
        [1] = "box_1_p",
        [2] = "box_2_p",
        [3] = "box_2_p",
        [4] = "box_3_p",
        [5] = "box_3_p",
    }

    local boxData = self._serverData["box"] or {}
    local allBox = self._rewardData.frequency or {}
    local boxNum = #allBox
    local awardData = self._rewardData.reward or {}
    local drawCount = self._serverData["drawCount"] or 0
    self._boxArr = {}
    local coutNum
    local needCount
    local getMc
    self._maxCount = allBox[boxNum] or 100

    -- dump(awardData,'awardData=》',5)      
    local proW = 360 / self._maxCount -- 总长360 100份
    for i=1,boxNum do
        local box = self:getUI("bg.bg1.rightPanel.box" .. i)
		if box._getMc then
			box._getMc:removeFromParent()
		end
        coutNum = self:getUI("bg.bg1.rightPanel.box" .. i .. ".coutNum")
        coutNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        needCount = allBox[i]
        coutNum:setString(needCount) 
        if i > 1 and 70 + proW*needCount < 160 then
            box:setPositionY(160)
        else
            box:setPositionY(70 + proW*needCount)
        end    
        box._coutNumTxt = countNum
        box._needCount = needCount 
        if not mcName[i] then
            mcName[i] = "baoxiang3_baoxiang"
        end        
        if not normalImg[i] then
            getImg[i] = "box_3_n"
        end
        if not normalImg[i] then
            getImg[i] = "box_3_p"
        end
        getMc = mcMgr:createViewMC(mcName[i], true,false)
        getMc:setPosition(38,32)
        box:addChild(getMc)
        box._getMc = getMc
        box._normalImg = normalImg[i]
        box._getImg = getImg[i]
        local rewardD = awardData[i] or {}
        box._rewardArr = {}
        table.insert(box._rewardArr, rewardD)
        -- dump(awardData[i],"awardData[i]==>",4)

        box._normal = true
        box._isCanGet = false
        if drawCount >= needCount then
            box._isCanGet = true
            box._normal = false
        end
        if boxData[tostring(needCount)] then
            box._normal = false
            box._isCanGet = false
        end

        getMc:setVisible(box._isCanGet)
        
        local imgName = box._normal and box._normalImg .. ".png" or box._getImg .. ".png"
        box:loadTextures(imgName,imgName,"",1)
        box:setOpacity(box._isCanGet and 0 or 255)

        self:registerClickEvent(box, function (sender)
            self:luckyBoxClicked(sender)
        end)
        self._boxArr[i] = box
    end

	for i=1, 5 do
		local box = self:getUI("bg.bg1.rightPanel.box"..i)
		if box then
			box:setVisible(i<=boxNum)
		end
	end
    self._progressBar = self:getUI("bg.bg1.rightPanel.progressBar")
    self._progressBar:setPercent((self._maxCount == 0) and 0 or drawCount/self._maxCount*100)
end

function AcLuckyLotteryDialog:updateDataAndPanel()
	local model = self._viewType==1 and self._runeLotteryModel or self._runeLotteryProModel
    self._serverData    = model:getLotteryData() or {}
    self._numTxt:setString(self._serverData.luckyScore or 0)

    local drawCount = self._serverData["drawCount"] or 0
    local boxData = self._serverData["box"] or {}
    --更新宝箱
    for k,v in pairs(self._boxArr) do
        local box = v
        local needCount = box._needCount
        local getMc = box._getMc
        local normalImg = box._normalImg
        local getImg = box._getImg

        if drawCount >= needCount then
            box._isCanGet = true
            box._normal = false
        end
        if boxData[tostring(needCount)] then
            box._normal = false
            box._isCanGet = false
        end

        getMc:setVisible(box._isCanGet)
        
        local imgName = box._normal and box._normalImg .. ".png" or box._getImg .. ".png"
        box:loadTextures(imgName,imgName,"",1)
        box:setOpacity(box._isCanGet and 0 or 255)
    end

    self._progressBar:setPercent((self._maxCount == 0) and 0 or drawCount/self._maxCount*100)
    self:updateBuyBtnCost()
end

function AcLuckyLotteryDialog:updateBuyBtnCost()    
    local userData = self._userModel:getData()
	local model = self._viewType==1 and self._runeLotteryModel or self._runeLotteryProModel
    self._luckyNum:setString(ItemUtils.formatItemCount(userData[self._costType]))
    self._diamondNum:setString(ItemUtils.formatItemCount(userData["gem"]))
    local haveCostNum = userData[self._costType]
    self._buyBtn1Cost:setColor(haveCostNum >= self._buyBtnCostNum1 
                and UIUtils.colorTable.ccUIBaseColor1
                or UIUtils.colorTable.ccUIBaseColor6)
    self._buyBtn5Cost:setColor(haveCostNum >= self._buyBtnCostNum5 
                and UIUtils.colorTable.ccUIBaseColor1
                or UIUtils.colorTable.ccUIBaseColor6)

    self._buyBtn1Cost:setVisible(not model:isHaveFreeCount())
    self._costTypeOne:setVisible(not model:isHaveFreeCount())
    self._freeLabel:setVisible(model:isHaveFreeCount())
end

function AcLuckyLotteryDialog:lotteryBtnClicked(IsAgain)
	local buyNum = self._buyNum or 1
	local holyData = self._teamModel:getHolyData()
	local userData = self._userModel:getData()
	if self._viewType==1 then
		if not self._runeLotteryModel:isLotteryOpen() then
			self._viewMgr:showTip("幸运夺宝活动已结束")
			return
		end
		if self._limitNum <= table.nums(holyData) then
			self._viewMgr:showTip("圣徽背包已满，请前往分解")
			return
		end
		local haveCostNum = userData[self._costType]
		local costNum = self["_buyBtnCostNum" .. buyNum]
		if haveCostNum >= costNum or (buyNum == 1 and self._runeLotteryModel:isHaveFreeCount()) then
			self._serverMgr:sendMsg("RuneLotteryServer", "drawRunes", {type=buyNum}, true, {}, function(result)
				ScheduleMgr:nextFrameCall(self, function()
					if IsAgain then 
						self:clickedAgain(result["reward"],function()
							self:updateDataAndPanel()
						end)
					else
						-- 播放动画
						self:playAnim(result["reward"],function()
							self:updateDataAndPanel()
						end)
					end
				end) 
			end)
		else
			DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_LUCKYCOIN"),button1 = "前往",title = "幸运币不足",callback1=function( )
				DialogUtils.showBuyRes({goalType = "luckyCoin",inputNum = costNum - haveCostNum})
			end})
		end
	else
		if not self._runeLotteryProModel:isLotteryOpen() then
			self._viewMgr:showTip("幸运夺宝活动已结束")
			return
		end
		if self._limitNum <= table.nums(holyData) then
			self._viewMgr:showTip("圣徽背包已满，请前往分解")
			return
		end
		local haveCostNum = userData[self._costType]
		local costNum = self["_buyBtnCostNum" .. buyNum]
		if haveCostNum >= costNum or (buyNum == 1 and self._runeLotteryProModel:isHaveFreeCount()) then
			self._serverMgr:sendMsg("RuneLotteryProServer", "drawRunes", {type=buyNum}, true, {}, function(result)
				ScheduleMgr:nextFrameCall(self, function()
					if IsAgain then 
						self:clickedAgain(result["reward"],function()
							self:updateDataAndPanel()
						end)
					else
						-- 播放动画
						self:playAnim(result["reward"],function()
							self:updateDataAndPanel()
						end)
					end
				end) 
			end)
		else
			DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_LUCKYCOIN"),button1 = "前往",title = "幸运币不足",callback1=function( )
				DialogUtils.showBuyRes({goalType = "luckyCoin",inputNum = costNum - haveCostNum})
			end})
		end
	end
end


-- 宝箱点击
function AcLuckyLotteryDialog:luckyBoxClicked(sender)
	local model = self._viewType==1 and self._runeLotteryModel or self._runeLotteryProModel
	local serverName = self._viewType==1 and "RuneLotteryServer" or "RuneLotteryProServer"
    if not model:isLotteryOpen() then
        self._viewMgr:showTip("幸运夺宝活动已结束")
        return
    end
    if sender._isCanGet then
        print("================发送领宝箱协议============")
        self._serverMgr:sendMsg(serverName, "getRuneBox", {id=sender._needCount}, true, {}, function(data)
            if data["reward"] then 
                DialogUtils.showGiftGet({ gifts = data["reward"], hide = self, callback = function()                    
                    -- 更新宝箱状态
                    sender._normal = false
                    sender._isCanGet = false
                    sender._getMc:setVisible(false)
                
                    sender:loadTextures(sender._getImg .. ".png",sender._getImg .. ".png","",1)
                    sender:setOpacity(255)
                    self._serverData    = model:getLotteryData() or {}
                end,notPop = false})
            end 
        end)       
    elseif sender._normal then
        -- 预览
        -- dump(sender._rewardArr,"sender._rewardArr",3)
        local tipStr = lang("SHOPRUNE_TIPS_1")
        tipStr = string.gsub(tipStr,"{N}",sender._needCount)
        DialogUtils.showGiftGet({ gifts = sender._rewardArr, viewType = 2,des=tipStr}) -- des = ""
    else
        self._viewMgr:showTip(lang("TiPS_YILINGQU"))
    end

end
function AcLuckyLotteryDialog:reflashUI(data)
    print("=========================reflashUI()=====")
end

function AcLuckyLotteryDialog:playAnim(reward,callBack)
    self:lock(-1)
    if not reward or type(reward) ~= "table" then
        return
    end

    local rewardGifts = {}
   
    local randNum = math.random(1, 2)
    local time = 0
    
    -- print("=========randNum============",randNum)
    for i=1,randNum do
        for k,v in pairs(self._itemArr) do
            local item = v
            local selectAnim = item._selectAnim
            -- print("==============time===",time)
            local action = cc.Sequence:create(cc.DelayTime:create(time),
                cc.CallFunc:create(function()
                    selectAnim:setVisible(true)
                end),
                cc.DelayTime:create(0.05),
                cc.CallFunc:create(function()
                    selectAnim:setVisible(false)
                end)
                )
            item:runAction(action)
            time = time + 0.05
        end
    end
    
    self._buyPanel:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function( ... )
        self._buyPanel:setVisible(false)
    end)))
    local rewardCount = #reward
    local rewardIndex = 1
    -- print("===========rewardCount===",rewardCount)
    local buyItemPosX = 42
    local buyItemPosY = 98

    for i=1,5 do
        if rewardIndex > rewardCount then
            break
        end
        for k,v in pairs(self._itemArr) do
            if rewardIndex > rewardCount then
                break
            end
            local item = v
            local selectAnim = item._selectAnim
            -- print("=========111111111111111====",rewardIndex,reward[rewardIndex]["grid"])
            if reward[rewardIndex] and item._index == reward[rewardIndex]["grid"] then
                -- dump(reward[rewardIndex],"reward[rewardIndex]==>",5)
                -- print("==============time===",time)
                if not item._selectReward then 
                    item._selectReward = {}
                end
                local icon = self:createShowItem(reward[rewardIndex]["itemId"],buyItemPosX,buyItemPosY)
                buyItemPosX = buyItemPosX + 78
                table.insert(rewardGifts, reward[rewardIndex]["itemId"])
                rewardIndex = rewardIndex + 1
                icon:setVisible(false)
                table.insert(item._selectReward, icon)

                local action = cc.Sequence:create(cc.DelayTime:create(time),
                    cc.CallFunc:create(function()
                        selectAnim:setVisible(true)
                    end),
                    cc.DelayTime:create(0.08),
                    cc.CallFunc:create(function()
                        selectAnim:setVisible(false)
                    end),
                    cc.DelayTime:create(0.08),
                    cc.CallFunc:create(function()
                        selectAnim:setVisible(true)
                    end),
                    cc.DelayTime:create(0.08),
                    cc.CallFunc:create(function()
                        selectAnim:setVisible(false)
                    end),
                    cc.DelayTime:create(0.08),
                    cc.CallFunc:create(function()
                        selectAnim:setVisible(true)
                    end),
                    cc.DelayTime:create(0.08),
                    cc.CallFunc:create(function()
                        selectAnim:setVisible(false)
                    end),
                    cc.CallFunc:create(function()
                        if item._selectReward and item._selectReward[1] then
                            item._selectReward[1]:setVisible(true)
                            table.remove(item._selectReward,1)
                        end
                    end)
                    )
                item:runAction(action)
                -- print("============rewardIndex==",rewardIndex)
                time = time + 0.8
            else                
                -- print("==============time===",time)
                local action = cc.Sequence:create(cc.DelayTime:create(time),
                    cc.CallFunc:create(function()
                        selectAnim:setVisible(true)
                    end),
                    cc.DelayTime:create(0.05),
                    cc.CallFunc:create(function()
                        selectAnim:setVisible(false)
                    end)
                    )
                item:runAction(action)
                time = time + 0.05
            end
        end
    end

    self._bg:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function( ... )
        -- dump(rewardGifts,"rewardGifts==>",5)
        self:unlock()
        local closeFunc = function()
            for k,v in pairs(self._itemArr) do 
                if v._selectReward then
                    v._selectReward = nil
                end
            end                 
            self._buyBgImg:removeAllChildren()
            if callBack then
                callBack()
            end
            self._buyPanel:setVisible(true)
        end
        self._viewMgr:showDialog("activity.acLuckyLottery.AcLuckyLotteryGetDialog", { 
            buyNum = self._buyNum,
            gifts = rewardGifts, 
            hide = self, 
            againCallBack = function()
                closeFunc() 
                ScheduleMgr:delayCall(1, self, function()
                      self:lotteryBtnClicked(true)
                      -- self:btnClickedAgain()
                 end)
            end,
            closeCallback = function()  
                closeFunc()
            end,
            notPop = false}, true,false,nil,true)
    end)))
end

-- btnClickedAgain
function AcLuckyLotteryDialog:clickedAgain(reward,callBack)
    self:lock(-1)
    if not reward or type(reward) ~= "table" then
        return
    end
    local rewardGifts = {}
    local time = 0
   
    self._buyPanel:setVisible(false)
   
    local rewardCount = #reward
    -- print("===========rewardCount===",rewardCount)
    local buyItemPosX = 42
    local buyItemPosY = 98

    for i=1,rewardCount do
        table.insert(rewardGifts, reward[i]["itemId"])
        local icon = self:createShowItem(reward[i]["itemId"],buyItemPosX,buyItemPosY)
        buyItemPosX = buyItemPosX + 78
        icon:setVisible(false)
        icon:runAction(cc.Sequence:create(
                    cc.DelayTime:create((i-1)*0.1),
                    cc.CallFunc:create(function()
                        icon:setVisible(true)
                    end)))
        time = time + (i-1)*0.1
          
    end

    self._bg:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function( ... )
        -- dump(rewardGifts,"rewardGifts==>",5)
        self:unlock()
        local closeFunc = function()               
            self._buyBgImg:removeAllChildren()
            if callBack then
                callBack()
            end
            self._buyPanel:setVisible(true)
        end
        self._viewMgr:showDialog("activity.acLuckyLottery.AcLuckyLotteryGetDialog", { 
            buyNum = self._buyNum,
            gifts = rewardGifts, 
            hide = self, 
            againCallBack = function()
                closeFunc() 
                ScheduleMgr:delayCall(1, self, function()
                      self:lotteryBtnClicked(true)
                      -- self:btnClickedAgain()
                 end)
            end,
            closeCallback = function()  
                closeFunc()
            end,
            notPop = false}, true,false,nil,true)
    end)))
end

function AcLuckyLotteryDialog:createShowItem(rewardD,posX,posY)    
    local icon        
    local itemId 
    local nameStr = ""
    local qualityNum = 1
    local itemNum = rewardD[3]
    if rewardD[1] == "tool"then
        itemId = rewardD[2]
        local toolD = tab:Tool(tonumber(itemId))
        icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = itemNum})
        nameStr = lang(toolD.name)
        qualityNum = ItemUtils.findResIconColor(itemId,1)
    elseif rewardD[1] == "rune" then
        if type(rewardD[2]) == "string" then
            local dataTemp = itemType[tonumber(acOpenId)]
            itemId = dataTemp[rewardD[2]][2]
            -- print("===========rewardD[2]===",rewardD[2])
        else
            itemId = rewardD[2]
        end
        -- print("==================itemId====",itemId)
        local itemData = tab:Rune(itemId)
        icon =IconUtils:createHolyIconById({suitData = itemData})
        nameStr = lang(itemData.name)
        qualityNum = itemData.quality

    else
        itemId = IconUtils.iconIdMap[rewardD[1]]
        local toolD = tab:Tool(tonumber(itemId))
        icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = itemNum})
        nameStr = lang(toolD.name)
        qualityNum = ItemUtils.findResIconColor(itemId,1)
        
    end
    icon:setScale(0.8)
    icon:setPosition(posX,posY)
    icon:setAnchorPoint(0.5,0.5)
    self._buyBgImg:addChild(icon)
    
    local boxIcon = icon.boxIcon
    local iconColor = icon.iconColor
    if boxIcon then
        boxIcon:setVisible(false)
    end
    if iconColor then
        iconColor:setVisible(false)
        if icon._isSplice then
            local iconMark = iconColor.iconMark
            if iconMark then
                local iconMarkCopy = iconMark:clone()
                icon:addChild(iconMarkCopy,10)
            end
        end
    end

    local nameTxt = ccui.Text:create()
    nameTxt:setFontSize(16)
    nameTxt:setFontName(UIUtils.ttfName)
    nameTxt:setString(nameStr)
    if itemNum > 1 then
      nameTxt:setString(nameStr .. "x" .. itemNum)  
    end
    -- print("==qualityNum====",qualityNum)
    nameTxt:setColor(UIUtils.colorTable["ccColorQuality" .. qualityNum])
    nameTxt:setPosition(icon:getContentSize().width*0.5,0)
    nameTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    icon:addChild(nameTxt,5)
    icon._nameTxt = nameTxt

    return icon

end
--[[
-- do动画调试
function AcLuckyLotteryDialog:debugFunc( ... )
        print("==================self_buyNum==",self._buyNum)
        local reward = {
            [1] = {
                grid   = 2,
                itemId = {
                    [1] = "rune",
                    [2] = 20404,
                    [3] = 1,
                }
            },
            [2] = {
                grid   = 7,
                itemId = {
                    [1] = "rune",
                    [2] = 20404,
                    [3] = 1,
                }
            },
            [3] = {
                grid   = 9,
                itemId = {
                    [1] = "rune",
                    [2] = 20404,
                    [3] = 1,
                }
            },
            [4] = {
                grid   = 14,
                itemId = {
                    [1] = "rune",
                    [2] = 20404,
                    [3] = 1,
                }
            },
            [5] = {
                grid   = 9,
                itemId = {
                    [1] = "rune",
                    [2] = 20404,
                    [3] = 1,
                }
            }

        }
        
        self:clickedAgain(reward,function( ... )
            self:updateDataAndPanel()
        end)
        -- self:playAnim(reward,function( ... )
        --     self:updateDataAndPanel()
        -- end)
end
-- ]]

return AcLuckyLotteryDialog