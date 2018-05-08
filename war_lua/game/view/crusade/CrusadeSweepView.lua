--[[
    Filename:    CrusadeSweepView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2018-01-17 15:48:20
    Description: 一键扫荡奖励界面
--]]

local CrusadeSweepView = class("CrusadeSweepView", BasePopView)

function CrusadeSweepView:ctor(param)
	self.super.ctor(self)
	self._crusadeModel = self._modelMgr:getModel("CrusadeModel")
	self._privilModel = self._modelMgr:getModel("PrivilegesModel")
	self._vipModel = self._modelMgr:getModel("VipModel")
	
	self._parentView = param.parentView
	self._callback1 = param.callback1
	self._callback2 = param.callback2
	self._oneKeySweep = param.oneKeySweep
	self._priviNum = self._privilModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_15)  --免费次数
	self._reward1 = {}
	self._reward2 = {}
	if param.reward and next(param.reward) then
		for i,v in ipairs(param.reward) do
			if v["type"] == "gold" or v["type"] == "crusading" then
				table.insert(self._reward1, v)
			else
				table.insert(self._reward2, v)
			end
		end
	end
end

function CrusadeSweepView:onInit()
	self:registerClickEventByName("bg.bg1.closeBtn", function()
		self:closeUI()
		end)

	self:registerClickEventByName("bg.bg1.enterBtn", function()
		self:closeUI()
		end)

	local titleLab = self:getUI("bg.bg1.titleBg.des")
	UIUtils:setTitleFormat(titleLab, 1)

	self:getUI("rwd3.cost1.buyBtn1"):setTitleText("开启")

	local rwd1 = self:getUI("rwd1")
	local rwd2 = self:getUI("rwd2")
	local rwd3 = self:getUI("rwd3")
	local rwd4 = self:getUI("rwd4")
	rwd1:setVisible(false)
	rwd2:setVisible(false)
	rwd3:setVisible(false)
	rwd4:setVisible(false)

	self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
        	UIUtils:reloadLuaFile("crusade.CrusadeSweepView")

        elseif eventType == "enter" then
	        
        end
    end)

end

function CrusadeSweepView:reflashUI()	
	--重组数据
	local cModelData = self._crusadeModel:getData()
	local userCrusade = self._crusadeModel:getData().crusadeData
	local sweepId = cModelData["sweepId"] * 2
	local oneKeyId = cModelData["oneKeyId"]
	local sysCrusadeMains = tab.crusadeMain

	self._spRwd, self._buff, self._treasure = self._crusadeModel:checkSencondSweepState()

	local sysCrusadeEvent = tab:CrusadeEvent(1)
	local v = sysCrusadeEvent.showReward[1]
	local tipLab = self:getUI("rwd3.num")
	tipLab:setString(v[3] .. "~" .. v[4])

    self._scrollView = self:getUI("bg.bg1.tableBg.scrollView")
	local hei1, rwdNode1 = self:createReward1()
	local hei2, rwdNode2 = self:createReward2()
	local hei3, rwdNode3 = self:createReward3()
	local hei4, rwdNode4 = self:createReward4()
	local height = hei1 + hei2 + hei3 + hei4

	if height >= 428 then
		self._scrollView:setContentSize(cc.size(492, 428))
		self._scrollView:setPosition(0, 0)
		self._scrollView:setInnerContainerSize(cc.size(492, height))
	else
		self._scrollView:setContentSize(cc.size(492, height))
		self._scrollView:setPosition(0, 428 - height)
		self._scrollView:setInnerContainerSize(cc.size(492, height))
	end
	
	if rwdNode1 then
		rwdNode1:setPosition(0, height - hei1)
	end

	if rwdNode2 then
		rwdNode2:setPosition(0, height - hei2 - hei1)
	end

	if rwdNode3 then
		rwdNode3:setPosition(0, height - hei3 - hei2 - hei1)
	end

	if rwdNode4 then
		rwdNode4:setPosition(0, height - hei4 - hei3 - hei2 - hei1)
	end
end

--普通奖励
function CrusadeSweepView:createReward1()
	if next(self._reward1) == nil then
		return 0
	end

	local rwd1 = self:getUI("rwd1"):clone()
	rwd1:setVisible(true)
	self._scrollView:addChild(rwd1)

	local num1 = rwd1:getChildByName("num1")
	local num2 = rwd1:getChildByName("num2")
	local num3 = rwd1:getChildByName("num3")
	for i,v in ipairs(self._reward1) do
	
		if v["type"] == "gem" then
			num1:setString(v["num"])
		elseif v["type"] == "gold" then
			num2:setString(v["num"])
		elseif v["type"] == "crusading" then
			num3:setString(v["num"])
		end
	end

	local rwdHei = rwd1:getContentSize().height
	return rwdHei, rwd1
end

--宝物
function CrusadeSweepView:createReward2()
	if next(self._reward2) == nil then
		return 0
	end

	local rwd2 = self:getUI("rwd2"):clone()
	rwd2:setVisible(true)
	self._scrollView:addChild(rwd2)

	for i,v in ipairs(self._reward2) do
		local tool = self:createToolIcon(v)
		tool:setScale(0.85)
		tool:setPosition(30 + (i - 1) * (tool:getContentSize().width + 10) * tool:getScale(), 11)
		rwd2:addChild(tool)
	end

	local rwdHei = rwd2:getContentSize().height 
	return rwdHei, rwd2
end

--小精灵奖励
function CrusadeSweepView:createReward3()
	local scrollHei =  0 
	if next(self._spRwd) == 0 then
		return scrollHei
	end

	local temp = self:getUI("rwd3")
	local tempWid, tempHei = temp:getContentSize().width, temp:getContentSize().height

	local max = #table.keys(self._spRwd)
	scrollHei = tempHei * max
	local node = ccui.Layout:create()
	node:setContentSize(cc.size(tempWid, scrollHei))
	self._scrollView:addChild(node)
	
	local userCrusade = self._crusadeModel:getData().crusadeData
	-- dump(userCrusade, "daf", 10)

	local num = 0
	for k,v in pairs(self._spRwd) do
		repeat
			num = num + 1
			local rwd3 = temp:clone()
			rwd3:setVisible(true)
			rwd3:setPosition(0, tempHei * (max - num))
			rwd3._id = k
			node:addChild(rwd3)

			local title = rwd3:getChildByName("title")
			local free = rwd3:getChildByFullName("cost1.free")
			local privFreeDes = rwd3:getChildByFullName("cost1.privFree.costNum")
			local costNum1 = rwd3:getChildByFullName("cost1.diamCost.costNum")
			local costNum2 = rwd3:getChildByFullName("cost2.diamCost.costNum")
			free:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
			privFreeDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
			costNum1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
			costNum2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
			title:setString("精灵馈赠" .. num)

			--状态判断
			v["id"] = k
			v["ui"] = rwd3
			v["requestNum"] = userCrusade[k]["buyTimes"] or 0   --已请求次数
			v["buyTimes"] = userCrusade[k]["buyTimes"] or 0   	--已购买次数
			v["unCostNum"] = 0    	--免费次数

			for m,n in pairs(tab.crusadeEvent) do
		        if n["cost"] == 0 and tonumber(m) < 20 then   --排除特权次数
		            v["unCostNum"] = v["unCostNum"] + 1
		        end
		    end

		    self:updateInfoSp(k)

		    local buyBtn1 = rwd3:getChildByFullName("cost1.buyBtn1")
		    self:registerClickEvent(buyBtn1, function()
		    	if v["requestNum"] < (self._priviNum + v["unCostNum"]) then  
		            self:getCrusadeSpReward(1, k)
		        else
		            self:buyCrusadeSpReward(1, k)
	        	end
		    	end)

		    local buyBtn2 = rwd3:getChildByFullName("cost2.buyBtn2")
		    self:registerClickEvent(buyBtn2, function()
		    	self:buyCrusadeSpReward(v["fCBuyNum"],k)
		    	end)


		until true
	end

	return scrollHei, node
end

function CrusadeSweepView:updateInfoSp(inId)
	local data = self._spRwd[inId]
	data["fCBuyNum"] = 0     	--可连购次数
	data["fCostNum"] = 0    	--连购次数花费
	data["costNum"] = data["requestNum"] - self._priviNum + 1  --当前购买次数
	
	local sysCrusadeEvent
    if self._priviNum > data["requestNum"] then
        sysCrusadeEvent = tab:CrusadeEvent(1)
    else
        sysCrusadeEvent = tab:CrusadeEvent(data["requestNum"] - self._priviNum + 1)
    end

    local rwd3 = data["ui"]
    local cost1 = rwd3:getChildByName("cost1")
	local cost2 = rwd3:getChildByName("cost2")
	local tips = rwd3:getChildByName("tips")
	local rwdNum = rwd3:getChildByName("num")
	local free = rwd3:getChildByFullName("cost1.free")
	local diamCost = rwd3:getChildByFullName("cost1.diamCost")
	local discount1 = rwd3:getChildByFullName("cost1.discount")
	local discount2 = rwd3:getChildByFullName("cost2.discount")
	local discNum1 = rwd3:getChildByFullName("cost1.discount.num")
	local discNum2 = rwd3:getChildByFullName("cost2.discount.num") 
	local privFree = rwd3:getChildByFullName("cost1.privFree")
	tips:setVisible(false)
	cost2:setVisible(false)
	diamCost:setVisible(false)
	privFree:setVisible(false)
	free:setVisible(false)
	discount1:setVisible(false)
	discount2:setVisible(false)

    if not sysCrusadeEvent then   --最大次数
    	cost1:setVisible(false)
    	tips:setVisible(true)
    	return 
    end

    -- rwd
    local reward = sysCrusadeEvent.showReward[1]
    rwdNum:setString(reward[3] .. "~" .. reward[4])

    if self._priviNum > data["requestNum"] then   --特权免费
    	privFree:setVisible(true)
    else
    	if sysCrusadeEvent.cost > 0 then   --花钻石
    		diamCost:setVisible(true)
    		local diamCost1 = rwd3:getChildByFullName("cost1.diamCost")
    		diamCost1:setPositionX(47)
    		local diamCost2 = rwd3:getChildByFullName("cost2.diamCost")
    		diamCost2:setPositionX(29)
    		local costNum1 = rwd3:getChildByFullName("cost1.diamCost.costNum")
			local costNum2 = rwd3:getChildByFullName("cost2.diamCost.costNum")
    		
    		-- 活动折扣
	        local activityModel = self._modelMgr:getModel("ActivityModel") 
	        local discount = activityModel:getAbilityEffect(activityModel.PrivilegIDs.PrivilegID_13) or 0
	        local costNum = sysCrusadeEvent.cost
	        if discount ~= 0 and sysCrusadeEvent.cost > 0 then 
	            costNum = math.ceil(costNum * (1 + discount))
	            discount1:setVisible(true)
	            discount2:setVisible(true)

	            local discNum = (1 + discount) * 10
	            local words = {"一","二","三","四","五","六","七","八","九","十",}

	            discNum1:setString(words[discNum] .. "折") 
	            costNum1:setColor(UIUtils.colorTable.ccUIBaseColor2)

	            discNum2:setString(words[discNum] .. "折") 
	            costNum2:setColor(UIUtils.colorTable.ccUIBaseColor2)
	        else
	            costNum1:setColor(UIUtils.colorTable.ccUIBaseColor1)
	            costNum2:setColor(UIUtils.colorTable.ccUIBaseColor1)
	        end
	        costNum1:setString(costNum)

	        --连购
    		local sysCru = tab.crusadeEvent
    		for i= data["requestNum"] - self._priviNum + 1, 100 do
    			if not sysCru[i] or data["fCBuyNum"] >= 5 then
                    break
                end

                if sysCru[i]["cost"] ~= 0 then   --可连刷次数
	                data["fCBuyNum"] = data["fCBuyNum"] + 1
	                data["fCostNum"] = data["fCostNum"] + sysCru[i]["cost"]
	            end
    		end
            data["fCostNum"] = math.ceil(data["fCostNum"] * (1 + discount))

            if data["fCBuyNum"] > 1 then
            	cost2:setVisible(true)
            	cost2:getChildByName("buyBtn2"):setTitleText("开启" .. data["fCBuyNum"] .. "次")
            	costNum2:setString(data["fCostNum"])
            end

            if costNum > 99 then 
		        diamCost1:setPositionX(diamCost1:getPositionX() - 8)
		    end

		    if data["fCostNum"] > 999 then 
		        diamCost2:setPositionX(diamCost2:getPositionX() - 10)
		    end

    	else   								--免费
    		free:setVisible(true)
    	end
    end
end

function CrusadeSweepView:getCrusadeSpReward(inNum, inId)
	local data = self._spRwd[inId]
    self._serverMgr:sendMsg("CrusadeServer", "openSweepCrusadeBox", {id = inId, num = inNum}, true, {}, function (result)
        self:getCrusadeSpRewardFinish(result, inNum, inId)
    end)
end

function CrusadeSweepView:buyCrusadeSpReward(inNum, inId)
	local data = self._spRwd[inId]
   	local vipInfo = self._vipModel:getData()
    local sysVip = tab:Vip(vipInfo.level)

    local limitVipLevel, limitVipTimes = self._vipModel:getSysVipMaxLimitByField("sectionReset")
    local sysCrusadeEvent
    if self._priviNum > data["requestNum"] then
        sysCrusadeEvent = tab:CrusadeEvent(1)
    else
        sysCrusadeEvent = tab:CrusadeEvent(data["requestNum"] - self._priviNum + 1)
    end

    local buyTime = math.max(data["requestNum"] - self._priviNum, 0)
    if buyTime >= sysVip.crusadeBoxTimes then
        if limitVipLevel >= vipInfo.level then
            self._viewMgr:showTip(lang("TIPS_CRUSADE_OPENBOX"))
        else
            self._viewMgr:showTip(lang("TIPS_CRUSADE_OPENBOX_MAX"))
        end
        return
    end
    if sysCrusadeEvent == nil then 
        self._viewMgr:showTip(lang("CRUSADE_TIPS_12"))
        return
    end
    local player = self._modelMgr:getModel("UserModel"):getData()
    local fCost = inNum > 1 and data["fCostNum"] or sysCrusadeEvent.cost
    if player.gem < fCost then
        DialogUtils.showNeedCharge({
            desc = lang("TIP_GLOBAL_LACK_GEM"),
            callback1 = function( )
                local viewMgr = ViewManager:getInstance()
                viewMgr:showView("vip.VipView", {viewType = 0})
            end})
        return
    end

    self._serverMgr:sendMsg("CrusadeServer", "openSweepCrusadeBox", {id = inId, num = inNum}, true, {}, function (result)
        self:getCrusadeSpRewardFinish(result, inNum, inId)
    end)
end

function CrusadeSweepView:getCrusadeSpRewardFinish(result, inNum, inId)
	local data = self._spRwd[inId]
	if result["reward"] ~= nil then
        DialogUtils.showGiftGet( {
            gifts = result["reward"], 
            callback = nil,
            notPop = true
            })

        data["requestNum"] = data["requestNum"] + inNum
        self:updateInfoSp(inId)
    end
end

--buff奖励
function CrusadeSweepView:createReward4()
	local scrollHei = 0
	if next(self._buff) == nil then
		return scrollHei
	end

	-- dump(self._buff, "buff", 10)

	local temp1 = self:getUI("rwd4")
	local temp2 = self:getUI("buffNode")
	local tempWid1, tempHei1 = temp1:getContentSize().width, temp1:getContentSize().height
	local tempWid2, tempHei2 = temp2:getContentSize().width, temp2:getContentSize().height
	local node = ccui.Layout:create()
	node:setContentSize(cc.size(tempWid1, 100))
	self._scrollView:addChild(node)

	local userCrusade = self._crusadeModel:getData().crusadeData
	local max = #table.keys(self._buff)
	local num = 0
	for i,v in pairs(self._buff) do
		num = num + 1
		self:getUI("name")

		local rwd4 = temp1:clone()
		rwd4:setVisible(true)
		node:addChild(rwd4)

		rwd4:getChildByName("title"):setString("选择增益状态" .. (max - num + 1))

		local buffList = userCrusade[i]["buffList"]
		-- dump(userCrusade[i])

		for p,q in ipairs(buffList) do
			local buffNode = temp2:clone()
			local line = math.floor((p - 1) / 2) + 1
			local row = p - (line - 1) * 2
			buffNode:setPosition(7 + tempWid2 * 0.5 + (tempWid2 + 3) * (row -1), 50 - (tempHei2 + 4) * (line - 1))
			rwd4:addChild(buffNode)

			buffNode["id"] = i
			buffNode["index"] = p
			buffNode["buff"] = q

			self:updateInfoBuff(buffNode)  --buff
		end

		local lineMax = math.floor((#buffList - 1) / 2) + 1
		scrollHei = scrollHei + 50 + lineMax * (tempHei2 + 4)

		rwd4:setPosition(0, scrollHei - 140)
	end

	return scrollHei, rwd4
end

function CrusadeSweepView:updateInfoBuff(inObj)
	local inId, index, sysBuf = inObj["id"], inObj["index"], inObj["buff"]
	local isOpenthirdBuffer = self._privilModel:getPeerageEffect(PrivilegeUtils.peerage_ID.YuanZhengBUFF)
	local userCrusade = self._crusadeModel:getData().crusadeData
    local buffPic = tab.crusadeBuffPic

	local icon = inObj:getChildByName("icon")
	local unlock = inObj:getChildByName("unlock")
	unlock:setVisible(false)
	local selectImg = inObj:getChildByName("select")
	selectImg:setVisible(false)
	if userCrusade[inId] and userCrusade[inId]["isFinish"] == 1 then
		selectImg:setVisible(true)
	end

	local str = ""
	if isOpenthirdBuffer == 0 and index == 3 then
		unlock:setVisible(true)

		str = lang("CRUSADE_BUFF_TIPS") .. "[color=ffffff,outlinecolor=3c1e0aff,fontsize=20]可以解锁[-]"
        local uresult,count1 = string.gsub(str, "$peerage", lang(tab:Peerage(PrivilegeUtils.peerage_ID.YuanZhengBUFF).name))
        if count1 > 0 then 
            str = uresult
        end
	else
		icon:loadTexture(buffPic[sysBuf[1]].pic .. ".png", 1)

		str = lang("CRUSADE_BUFF_" .. sysBuf[1])
        local result, count = string.gsub(str, "$num", sysBuf[2])
        if count > 0 then 
            str = result 
        end
	end

	if inObj._richText then
		inObj._richText:removeFromParent(true)
		inObj._richText = nil
	end

    local richText = RichTextFactory:create(str, 145, 0)
    richText:setAnchorPoint(cc.p(0, 0.5))
    richText:setPixelNewline(true)
	richText:formatText()
	richText:setPosition(20, inObj:getContentSize().height/2)
	inObj._richText = richText
	inObj:addChild(richText)

	self:registerClickEvent(inObj, function()
		self:enterBuffSelected(inObj, str)
		end)
end

function CrusadeSweepView:enterBuffSelected(inObj, cstr)
	local isOpenthirdBuffer = self._privilModel:getPeerageEffect(PrivilegeUtils.peerage_ID.YuanZhengBUFF)
	local sysBuf, id, index = inObj["buff"], inObj["id"], inObj["index"]
	local userCrusade = self._crusadeModel:getData().crusadeData

	if isOpenthirdBuffer == 0 and index == 3 then
		self._viewMgr:showTip(lang("CRUSADE_TIPS_8"))
	 	return
	end

	local isSelected = userCrusade[id]["isFinish"]
	if isSelected == 1 then
	 	self._viewMgr:showTip(lang("CRUSADE_TIPS_22"))
	 	return
	end 

    if sysBuf[1] == 999 then 
        local formationModel = self._modelMgr:getModel("FormationModel")
        local formationData = formationModel:getFormationDataByType(formationModel.kFormationTypeCrusade)
        local teamNum, inTeamdieNum, dieNum = formationModel:getFormationTeamCountWithFilter(formationModel.kFormationTypeCrusade)

        if dieNum <= 0 then 
            self._viewMgr:showTip(lang("CRUSADE_TIPS_10"))
            return
        end
        self:setVisible(false)
        self._viewMgr:showDialog("crusade.CrusadeReviveTeamNode",{
                    crusadeId = id, 
                    buffId = sysBuf[1], 
                    inType = 1,
                    callback = function()
                        self:setVisible(true)
                    end},true) 
    else
        local tipInfo = "[color=3c2a1e,fontsize=20]是否确认选择[-]" .. string.gsub(cstr, "ffffff", "00ff22")  
        self._viewMgr:showDialog("global.GlobalSelectDialog",
            {
                desc = tipInfo,
                button1 = "确定" ,
                button2 = "取消", 
                callback1 = function ()
                    self:getCrusadeBuffReward(inObj)
                end,
                callback2 = function()
                end
            }, true)       
    end
end

function CrusadeSweepView:getCrusadeBuffReward(inObj)
    local param = {id = inObj["id"], args = {buffId = inObj["buff"][1]}}
    self._serverMgr:sendMsg("CrusadeServer", "chooseSweepCrusadeBuff", param, true, {}, function (result)
    	self:updateInfoBuff(inObj)
        self:getCrusadeBuffRewardFinish(inObj)
    end)
end

function CrusadeSweepView:getCrusadeBuffRewardFinish(inObj)
    local buffId = inObj["buff"][1]
    --point1
    local bufferIcon = inObj:getChildByName("icon")
    local point1 = bufferIcon:convertToWorldSpace(cc.p(0, 0))
    point1 = self:convertToNodeSpace(point1)

    --point2
    local bufferBtn = self._parentView:getUI("bufferBtn")
    local point2 = bufferBtn:convertToWorldSpace(cc.p(0, 0)) 
    point2 = self:convertToNodeSpace(point2)
    point2.x = point2.x + bufferBtn:getContentSize().width/2
    point2.y = point2.y + bufferBtn:getContentSize().height/2

    self._viewMgr:lock(99999)
    local tempPoint = cc.p(point1.x + bufferIcon:getContentSize().width/2 * 0.9, point1.y + bufferIcon:getContentSize().height/2 * 0.9)

    --pic
    local buffPic = tab.crusadeBuffPic  
    local bufferSp = ccui.ImageView:create(buffPic[buffId].pic .. ".png", 1)
    bufferSp:setAnchorPoint(0.5, 0.5)
    bufferSp:setPosition(point1.x + bufferIcon:getContentSize().width/2 * 0.9, point1.y + bufferIcon:getContentSize().height/2 * 0.9)
    self:addChild(bufferSp, 1000)

    --picFrame
    local picFrame = ccui.ImageView:create("globalImageUI4_squality5.png", 1)
    picFrame:setPosition(bufferSp:getContentSize().width/2, bufferSp:getContentSize().height/2)
    bufferSp:addChild(picFrame)

    --angle
    local angle = 360 - MathUtils.angleAtan2(tempPoint, point2) + 90

    --widget
    local pointDis = MathUtils.pointDistance(point1, point2)
    local moveX = (point2.x - tempPoint.x) * 100 / pointDis
    local moveY = (point2.y - tempPoint.y) * 100 / pointDis
    local wiget = ccui.Layout:create()
    wiget:setPosition(tempPoint.x + moveX, tempPoint.y + moveY)
    wiget:setRotation(angle)
    self:addChild(wiget)

    local buffmc = mcMgr:createViewMC("buffguangxiao_crusademap", false, true)
    buffmc:addCallbackAtFrame(20, function()  
        local buffmc1 = mcMgr:createViewMC("guangquan_crusademap", false, true, function()
            --feixing1 xingxing
            local feixing1 = mcMgr:createViewMC("guangqiu_lianmengjihuo", true)
            wiget:addChild(feixing1)

            --feixing2
            local wiget1 = ccui.Layout:create()
            wiget1:setScaleX(1.5)
            wiget:addChild(wiget1)
            local feixing2 = mcMgr:createViewMC("lashentiao_lianmengjihuo", true)
            wiget1:addChild(feixing2)

            wiget:runAction(cc.Sequence:create(
                cc.MoveTo:create(0.5, cc.p(point2.x, point2.y)),
                cc.DelayTime:create(0.1),
                cc.CallFunc:create(function()
                    wiget:removeAllChildren()
                    wiget:removeFromParent(true)
                    wiget = nil

                    local endAinm = mcMgr:createViewMC("fankui_lianmengjihuo", false, true)
                    endAinm:setPosition(point2)
                    self:addChild(endAinm, 1000)
                    endAinm:addCallbackAtFrame(8, function() 
                        self._viewMgr:unlock()
                        self._widget:setVisible(true)
                        end)
                    end)
                ))
            end)
        buffmc1:setPosition(tempPoint)
        self:addChild(buffmc1, 1001)
        end)
    buffmc:setPosition(point1.x + bufferSp:getContentSize().width/2 - 5, point1.y+ bufferSp:getContentSize().height/2 + 4)
    self:addChild(buffmc, 1001)

    bufferSp:runAction(cc.Sequence:create(
        cc.DelayTime:create(1),
        cc.ScaleTo:create(0.1, 0.5),
        cc.CallFunc:create(function()
            bufferSp:removeFromParent()
         end)
        ))

    local bg = self:getUI("bg")
    bg:setAnchorPoint(0.5, 0.5)
    bg:stopAllActions()
    bg:runAction(cc.Sequence:create(cc.CallFunc:create(function ()
        self._widget:setVisible(false)
        self._parentView:setMaskLayerOpacity(0)
    end)))
end

function CrusadeSweepView:closeUI()
	local crusadeData = self._crusadeModel:getData().crusadeData
	local isFinished1 = true
	local isFinished2 = true
	for k,v in pairs(self._spRwd) do
		if self._priviNum + v["unCostNum"] > v["requestNum"] then
			isFinished1 = false
			break
		end
	end
	
	for k,v in pairs(self._buff) do
		if crusadeData[k] and crusadeData[k]["isFinish"] ~= 1 then
			isFinished2 = false
			break
		end
	end

	local tips = ""
	if not isFinished1 and not isFinished2 then
		tips = lang("CRUSADE_TIPS_TRIG_16")
	elseif not isFinished1 then
		tips = lang("CRUSADE_TIPS_TRIG_14")
	elseif not isFinished2 then
		tips = lang("CRUSADE_TIPS_TRIG_15")
	end

	local function finishChoose()
		self._serverMgr:sendMsg("CrusadeServer", "finishOneKeySweepCrusade", {}, true, {}, function (result)
			--上一次关游戏之前扫荡未结束状态
		    if self._oneKeySweep ~= 1 then
		    	if self._callback1 then
					self._callback1()
				end
		    end
			self:showTreasureView()
    	end)	
	end

	if tips ~= "" then
        self._viewMgr:showDialog("global.GlobalSelectDialog",
            {
                desc = tips,
                button1 = "确定" ,
                button2 = "取消", 
                callback1 = function ()
                    finishChoose()
                end,
                callback2 = function()
                end
            }, true) 
    else
    	finishChoose()
	end
end

function CrusadeSweepView:showTreasureView()
	if next(self._treasure) == nil then
		if self.close then
			self:close(true)
		end
		return
	end

	local crusadeData = self._crusadeModel:getData()
    local usePcs = crusadeData.usePcs
    local needPcs = crusadeData.needPcs
    local unusePcs = crusadeData.unusePcs
    if (usePcs + unusePcs) == needPcs then 
	    crusadeData.playEffect = 1
	end

    if (usePcs + unusePcs) <= needPcs then
    	self:setVisible(false) 
        audioMgr:playSound("MapFrag")
	    self._viewMgr:showDialog("crusade.CrusadeTreasureMapNode", {
	    	amin = true,
	    	callback = function(inNeedScroll)
	    		if self._callback2 then
	    			self._callback2(inNeedScroll)
	    		end
	    		if self.close then
					self:close(true)
				end
	    	end
	        }, true) 
	else
		if self._callback2 then
			self._callback2(false)
		end
		if self.close then
			self:close(true)
		end
        return
    end
end

function CrusadeSweepView:createToolIcon(inRwd)
	-- 物品
    if inRwd.type == "tool" then

	elseif inRwd.type == "crusading" then
		inRwd["typeId"] = IconUtils.iconIdMap["crusading"]

	elseif inRwd.type == "gold" then
		inRwd["typeId"] = IconUtils.iconIdMap["gold"]

	elseif inRwd.type == "gem" then
		inRwd["typeId"] = IconUtils.iconIdMap["gem"]

	elseif inRwd.type == "treasureCoin" then
		inRwd["typeId"] = IconUtils.iconIdMap["treasureCoin"]
	end

	local sysItem = tab:Tool(inRwd["typeId"])
    local item = IconUtils:createItemIconById({itemId = inRwd["typeId"], num = inRwd["num"], itemData = sysItem})

    -- if sysItem.typeId == ItemUtils.ITEM_TYPE_TREASURE then
    --     local mc1 = mcMgr:createViewMC("wupinguang_itemeffectcollection", true)
    --     mc1:setPosition(item:getContentSize().width/2 ,item:getContentSize().height/2)
    --     item:addChild(mc1, 10)
    -- end

    return item
end

return CrusadeSweepView