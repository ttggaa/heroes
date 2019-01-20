--
-- Author: huangguofang
-- Date: 2018-07-12 15:35:49
--

local AcElementGiftLayer = class("AcElementGiftLayer", require("game.view.activity.common.ActivityCommonLayer"))

function AcElementGiftLayer:ctor(param)
    self.super.ctor(self)
    self._parent = param.container
    self._activityId = tonumber(param.activityId) or 98
    self._acModel = self._modelMgr:getModel("ActivityModel")
    self._userModel = self._modelMgr:getModel("UserModel")
end

function AcElementGiftLayer:onInit()
    self.super.onInit(self)
    self._bg = self:getUI("bg")
    local bgImg = self:getUI("bg.bgImg")
    bgImg:loadTexture("asset/bg/ac_elemGiftBg.jpg")    
    self._tabData = clone(tab.eleGift)
	self._dayNum = self:getUI("bg.dayNum")
	self._awardPanel = self:getUI("bg.awardPanel")
	self._porBar = self:getUI("bg.proBar")
    self:upadateBoxPanel()
    self._itemArr = {}
   	-- 元素馈赠每天首次红点
	local curServerTime = self._userModel:getCurServerTime()
    local timeDate
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime > tempCurDayTime then
        timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    else
        timeDate = TimeUtils.getDateString(curServerTime - 86400,"%Y%m%d")
    end
    local tempdate = SystemUtils.loadAccountLocalData("ACTIVITY_ELEMGIFT")
    -- print(tempdate,"=============123123=tempdate,timeDate======",timeDate)
    if tempdate ~= timeDate then            
	    SystemUtils.saveAccountLocalData("ACTIVITY_ELEMGIFT", timeDate)
	    if self._parent and self._parent.updateTabRed then
	    	self._parent:updateTabRed()
	    end
    end

    local ruleBtn = ccui.Button:create()
    ruleBtn:loadTextures("globalImage_info.png","globalImage_info.png","",1)
    ruleBtn:setPosition(615, 120)  
    self._bg:addChild(ruleBtn,10) 
    -- 规则
    registerClickEvent(ruleBtn,function(sender) 
        local ruleDesc = lang("salier_rule")
    	self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = ruleDesc},true)
    end)
end

function AcElementGiftLayer:upadateBoxPanel()
	self._acData = self._userModel:getElementGiftData()
    local dayStr = self._acData.aday or 0
    self._dayNum:setString(dayStr .. "天")

	local gIds = self._acData.gIds or {}
	self._awardPanel:removeAllChildren()
	local posY = 62
	local maxLen = 483
	local subX = 483 / (#self._tabData - 1)
	local maxDay = self._tabData[#self._tabData]["Active_day"] or 100
	local awardData
	local itemId
	for k,v in pairs(self._tabData) do
		local award = (v.reward and v.reward[1]) and v.reward[1] or {}
		if award[1] == "tool" then
	        itemId = award[2]
	    else
	        itemId = IconUtils.iconIdMap[award[1]]
	    end
	    awardData = tab:Tool(itemId)
		local icon = IconUtils:createItemIconById(
			{itemId = itemId,
			itemData = awardData,
			num = award[3],
			eventStyle=0})

		local Active_day = v.Active_day or 0
		icon:setPosition(subX*(k-1), posY)
		icon:setScale(0.8)
		icon:setAnchorPoint(0.5,0.5)
		icon:setScaleAnim(true)
		self._awardPanel:addChild(icon,5)
		print("==========gIds[tostring(v.id)]====",gIds[tostring(v.id)])
		if gIds[tostring(v.id)] ~= nil then
			icon._state = 2   	-- 已领
		elseif tonumber(Active_day) <= tonumber(dayStr) then
			icon._state = 1 	--可领
			local getMc = mcMgr:createViewMC("huodewupindiguang_itemeffectcollection", true, false, nil, RGBA8888)
            getMc:setPosition(cc.p(icon:getContentSize().width*0.5,icon:getContentSize().height*0.5))
            getMc:setName("getMc")
            icon:addChild(getMc,-1)
		else
			icon._state = 0
		end
		icon._id = v.id
		self:registerClickEvent(icon, function (sender)
			self:clickAwardIcon(sender)
		end)

		if icon._state == 2 then
			icon:setBrightness(-30)
			local getItImg = ccui.ImageView:create()
			getItImg:loadTexture("globalImageUI_activity_getIt.png",1)
			getItImg:setPosition(icon:getContentSize().width*0.5,icon:getContentSize().height*0.5)
			icon:addChild(getItImg,100)			
		end
		local txt = ccui.Text:create()
	    txt:setString(lang(v.description))
	    txt:setColor(cc.c4b(147,179,207,255))
	    txt:setFontName(UIUtils.ttfName)
	    txt:setFontSize(18)
	    txt:setPosition(subX*(k-1), posY - 50)
	    self._awardPanel:addChild(txt, 5)
	end
	local subPro = 100 / (#self._tabData - 1)
	local proNum = 0
	if dayStr > 5 then
		proNum= dayStr - 5
	end
	self._porBar:setPercent(proNum/5*subPro)
end

function AcElementGiftLayer:clickAwardIcon(sender)
	local state = sender._state or 0
	if 0 == state then
		self._viewMgr:showTip("累计活跃天数未达到")
	elseif 1 == state then
		self._serverMgr:sendMsg("ActivityServer", "getEleGfit", {id=sender._id}, true, {}, function(success, data)
            if not success then return end
            self:upadateBoxPanel()
            if data.reward then
                DialogUtils.showGiftGet( {gifts = data.reward,notPop = true})
            end
        end)
	else
		self._viewMgr:showTip("奖励已领取")
	end
end
function AcElementGiftLayer:reflashUI()

end
return AcElementGiftLayer