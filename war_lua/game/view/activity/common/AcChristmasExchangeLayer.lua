--
-- Author: huangguofang
-- Date: 2017-12-15 10:57:13
-- Description: 圣诞节皮肤兑换

local AcChristmasExchangeLayer = class("AcChristmasExchangeLayer", require("game.view.activity.common.ActivityCommonLayer"))

function AcChristmasExchangeLayer:getAsyncRes()
    return 
    {
        -- {"asset/ui/activityShare.plist", "asset/ui/activityShare.png"},
    }
end

function AcChristmasExchangeLayer:ctor(data)
    self.super.ctor(self)
    -- print("=============================",data.activityId)
    self._activityId = tonumber(data.activityId) or 98
    self._activityData = {}
    self._acServerData = {}
    
end

function AcChristmasExchangeLayer:onInit()
    self.super.onInit(self)

    self._activityModel = self._modelMgr:getModel("ActivityModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._ItemModel = self._modelMgr:getModel("ItemModel")
    --静态表数据
    -- print("=============================",self._activityId )
    -- self._activityId = 98
    
    self._activityData = tab:DailyActivity(self._activityId)
    self._bg = self:getUI("bg")
    self._bg:setBackGroundImage("asset/bg/" .. self._activityData.titlepic1 .. ".jpg")

    local acDes = self:getUI("bg.acDes")
    self._endTime = self:getUI("bg.activity_date")

    local desTxt = self:getUI("bg.desTxt")
    local str = lang(self._activityData.description) or ""
    if string.find(str, "color=") == nil then
        str = "[color=fff9b2]"..str.."[-]"
    end
    print("==========str===",str)
    local desTxtRich = RichTextFactory:create(str, 330, 40)
    desTxtRich:formatText()
    desTxtRich:setName("desTxtRichTxt")
    -- desTxtRich:setVerticalSpace(3)
    -- desTxtRich:setAnchorPoint(cc.p(0,1))
    desTxtRich:setPosition(192,402)
    -- desTxtRich:setPosition(desTxt:getPosition())
    self._bg:addChild(desTxtRich, 5)
    desTxt:setString("")

    -- local mc = mcMgr:createViewMC("xuanshihuodong_carnivaltargetanim", true,false)
    -- mc:setPosition(70, 70)
    -- self._bg:addChild(mc,10)
    self._awardPanel = self:getUI("bg.awardPanel")

    local taskList = self._activityData and self._activityData.task_list
    local taskId = taskList and taskList[1]
    local taskData
    self._awardData = {}
    if taskId then
    	taskData = tab:DailyActivityTask(taskId)
    end
    if taskData then
    	self._awardData = taskData.exchange_num or {}
    end
    self._exchangeBtn = self:getUI("bg.exchangeBtn")
    self._getImg = self:getUI("bg.getImg")
    self._getImg:setVisible(false)
    self:updateAwardPanel()
    self:reflashUI()
    -- dump(self._activityModel:getActivityTaskData(),"==>",5)
end

function AcChristmasExchangeLayer:updateAwardPanel()
	local allTaskData = self._activityModel:getActivityTaskData()
	local taskData = allTaskData[tostring(self._activityId)]
	-- dump(taskData,"taskData=>",5)
	for k,v in pairs(self._awardData) do
		local icon = self:getUI("bg.awardPanel.icon" .. k)
		local numTxt = self:getUI("bg.awardPanel.icon" .. k ..".numTxt")
		if not icon then break end
		-- print("=========1111111====","bg.awardPanel.icon" .. k ..".numTxt")
		if icon._awardIcon then
			icon._awardIcon:removeFromParent()
			icon._awardIcon = nil
		end
		local needNum = v[3] or 0
		local itemId = v[2]
		local _,num = self._ItemModel:getItemsById(itemId)
		local toolD = tab:Tool(itemId)
		local itemIcon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,eventStyle = 0})
		itemIcon:setScale(0.8)
		itemIcon:setPosition(icon:getContentSize().width*0.5, icon:getContentSize().height*0.5-2)
		icon:addChild(itemIcon)
	    itemIcon:setAnchorPoint(0.5,0.5)
	    itemIcon:setScaleAnim(true)
	    itemIcon._itemId = itemId
		self:registerClickEvent(itemIcon,function(sender) 
			DialogUtils.showItemApproach(sender._itemId)
		end)
		local addImg = ccui.ImageView:create()
	    addImg:loadTexture("golbalIamgeUI5_add.png", 1)
	    addImg:setScale(0.5)
	    addImg:setPosition(itemIcon:getContentSize().width*0.5,itemIcon:getContentSize().height*0.5)
	    itemIcon:addChild(addImg,10)
        addImg:setVisible(num < needNum)
		icon._awardIcon = itemIcon

		numTxt:setString(num .. "/" .. needNum)
		numTxt:setColor(num >= needNum and UIUtils.colorTable.ccUIBaseColor2 or UIUtils.colorTable.ccUIBaseColor6)
		

	end
	local status = (taskData.taskList 
					and taskData.taskList[1] 
					and taskData.taskList[1].statusInfo) 
					and taskData.taskList[1].statusInfo.status or -1

	-- self._exchangeBtn:setVisible(status ~= 0)
    self._exchangeBtn:setSaturation(status ~= 0 and 0 or -100)
    self._exchangeBtn:setBright(status ~= 0 )
    self._exchangeBtn:setEnabled(status ~= 0 )
    self._exchangeBtn:setTitleText(status ~= 0 and "兑换皮肤" or "已兑换")
	-- self._getImg:setVisible(status == 0)
	registerClickEvent(self._exchangeBtn,function(sender)
		self:updateAwardPanel() 
		if status == -1 then
			self._viewMgr:showTip(lang("CHRISMAS_EXCHANGE_TIPS1"))
		elseif status == 0 then
			self._viewMgr:showTip("已兑换")
		elseif status == 1 then
			-- 领奖
			local context = { acId = self._activityId, taskId = taskData.taskList[1].id}
	        self._serverMgr:sendMsg("ActivityServer", "getTaskAcReward", context, true, {}, function(success, data)
	            if not success then return end
	            DialogUtils.showGiftGet( {gifts = data.reward})
	            -- 更新显示
	            -- self:updateAwardPanel()
        	end)			
		end
   	end)

end

function AcChristmasExchangeLayer:reflashUI(data)
  
    self._acServerData = self._activityModel:getACCommonShowList(self._activityId)
    -- dump(self._acServerData,"self._acServerData==>") 
    -- dump(sData,"sData==>")
    local starTime = self._acServerData.start_time or self._userModel:getCurServerTime() 
    local endTime = self._acServerData.end_time or self._userModel:getCurServerTime() 
    local tempTime = self._acServerData.end_time - self._userModel:getCurServerTime() 
    -- local startTb = TimeUtils.getDateString(starTime,"*t")
    -- local endTb = TimeUtils.getDateString(endTime,"*t")
    -- local dateString = string.format("%d月%d日%d时-%d月%d日%d时",startTb.month,startTb.day,startTb.hour,endTb.month,endTb.day,endTb.hour)  
    -- self._activityDate:setString(dateString)

    local day, hour, minute, second, tempValue    
    self:runAction(cc.RepeatForever:create(
        cc.Sequence:create(cc.CallFunc:create(function()
            tempTime = tempTime - 1
            tempValue = tempTime
            -- print("day======", tempValue)
            day = math.floor(tempValue/86400) 
            tempValue = tempValue - day*86400
            -- print("hour======", tempValue)
            hour = math.floor(tempValue/3600)
            tempValue = tempValue - hour*3600
            -- print("minute r======", tempValue)
            minute = math.floor(tempValue/60)
            tempValue = tempValue - minute*60
            -- print("second ======", tempValue)
            second = math.fmod(tempValue, 60)
            local showTime = string.format("%.2d天%.2d:%.2d:%.2d", day, hour, minute, second)
            if day == 0 then
                showTime = string.format("00天%.2d:%.2d:%.2d", hour, minute, second)
            end
            if tempTime <= 0 then
                showTime = "00天00:00:00"
            end
            self._endTime:setString(showTime)
            
        end), cc.DelayTime:create(1))
    ))

end

return AcChristmasExchangeLayer