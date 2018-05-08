--
-- Author: huangguofang
-- Date: 2017-09-14 22:27:52
--

local ActivityLotteryLayer = class("ActivityLotteryLayer", require("game.view.activity.common.ActivityCommonLayer"))

function ActivityLotteryLayer:ctor(data)
    self.super.ctor(self)
    self._container = data.container
    self._userModel = self._modelMgr:getModel("UserModel")
    self._acLotteryModel = self._modelMgr:getModel("AcLotteryModel")    
end

function ActivityLotteryLayer:onInit()
    self.super.onInit(self)
    self._isFirst = true

    self._size = {width = MAX_SCREEN_WIDTH, height = MAX_SCREEN_HEIGHT}
    self._scheduler = cc.Director:getInstance():getScheduler()

    self._bg = self:getUI("bg")
    self._bg:setBackGroundImage("asset/bg/acLotteryBg.jpg")

    self._layer_reward = self:getUI("layer_reward")
    self._layer_reward:setVisible(false)
    self._layer_reward:setContentSize(self._size)
    self._layer_reward:setBackGroundImage("asset/bg/ac_celebration_int_point_reward_Bg.jpg")

    self._layer_reward_element = self:getUI("layer_reward.layer_fazhen")

    self._elementRewardMC = mcMgr:createViewMC("kaijiang_kuanghuan", false, false)
    self._elementRewardMC:stop()
    self._elementRewardMC:setVisible(false)
    self._elementRewardMC:setPosition(self._layer_reward_element:getContentSize().width / 2 + 13, self._layer_reward_element:getContentSize().height / 2 + 30)
    self._layer_reward_element:addChild(self._elementRewardMC)

    self._reward_bg = self:getUI("layer_reward.image_reward_bg")
    self._label_reward_name = self:getUI("layer_reward.image_reward_bg.label_reward_name")
    self._label_reward_name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._elementRewardMC1 = mcMgr:createViewMC("guang_kuanghuan", false, false)
    self._elementRewardMC1:stop()
    self._elementRewardMC1:setVisible(false)
    self._elementRewardMC1:setPosition(self._reward_bg:getContentSize().width / 2, self._reward_bg:getContentSize().height / 2)
    self._reward_bg:addChild(self._elementRewardMC1)

    self._elementRewardMC2 = mcMgr:createViewMC("saoguang_kuanghuan", true, false)
    self._elementRewardMC2:setPlaySpeed(1, true)
    self._elementRewardMC2:setVisible(false)
    self._elementRewardMC2:setPosition(self._reward_bg:getContentSize().width / 2, self._reward_bg:getContentSize().height / 2)
    self._reward_bg:addChild(self._elementRewardMC2)

    self._image_reward_elements = {}
    for i=1, 6 do
        self._image_reward_elements[i] = self:getUI("layer_reward.layer_fazhen.image_fazhen_" .. i)
        self._image_reward_elements[i]:setVisible(false)
    end

    self:registerClickEvent(self._layer_reward, function(sender)
        if sender then 
            sender:setVisible(false)
        end
    end)

    if self._container._layerReward then 
        -- print("=========移除reward界面===========")
        self._container._layerReward:removeFromParent()
        self._container._layerReward = nil
    end
    self._layer_reward:retain()
    self._layer_reward:removeFromParent()
    self._container._layerReward = self._layer_reward
    self._container:addChild(self._layer_reward, 1000)
    self._layer_reward:release()
    self._label_time_title = self:getUI("bg.label_time_title")
    self._label_time_title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._label_count_down = self:getUI("bg.label_count_down")
    self._label_count_down:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._label_count_title = self:getUI("bg.label_count_title")
    self._label_count_title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._label_count = self:getUI("bg.label_count")
    self._label_count:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._label_reward_title = self:getUI("bg.label_reward_title")
    self._label_reward_title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._label_reward = self:getUI("bg.label_reward")
    self._label_reward:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._image_contract_title = self:getUI("bg.image_contract_title")

    self._layer_count_down = self:getUI("bg.layer_count_down")
    self._contract_count_down = cc.Label:createWithBMFont(UIUtils.bmfName_activity, "00:00:00")
    self._contract_count_down:setAdditionalKerning(2)
    self._contract_count_down:setPosition(self._layer_count_down:getContentSize().width / 2, self._layer_count_down:getContentSize().height / 2 - 10)
    self._layer_count_down:addChild(self._contract_count_down, 1)

    self._label_my_element = self:getUI("bg.label_my_element")
    self._label_my_element:setFontName(UIUtils.ttfName_Title)
    self._label_my_element:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._image_team = self:getUI("bg.image_team")

    self._stars = {}
    for i=1, 3 do
        self._stars[i] = self:getUI("bg.image_star_n_" .. i)
    end

    self._image_class = self:getUI("bg.image_class")
    self._image_name = self:getUI("bg.image_name")
    self._btnCheck = self:getUI("bg.btn_check")
    self._btnCheck:setPosition(50,290)

    self._btn_join = self:getUI("bg.btn_join")
    self:registerClickEvent(self._btn_join, function ()
        self:onJoinButtonClicked()
    end)

    self._layer_element = self:getUI("bg.layer_fazhen")
    self._elementMC1 = mcMgr:createViewMC("fazhen_kuanghuan", false, false)
    self._elementMC1:stop()
    self._elementMC1:setPosition(self._layer_element:getContentSize().width / 2, self._layer_element:getContentSize().height / 2 - 20)
    self._layer_element:addChild(self._elementMC1)
    self._elementMC2 = mcMgr:createViewMC("choujiang_kuanghuan", false, false)
    self._elementMC2:stop()
    self._elementMC2:setPosition(self._layer_element:getContentSize().width / 2, self._layer_element:getContentSize().height / 2 - 5)
    self._layer_element:addChild(self._elementMC2, 6)
    self._elementMC2:setVisible(false)
    self._image_elements = {}
    for i=1, 6 do
        self._image_elements[i] = self:getUI("bg.layer_fazhen.image_fazhen_" .. i)
        -- self._image_elements[i]:setVisible(false)
        self._image_elements[i]:setOpacity(0)
    end

    self._image_des_bg = self:getUI("bg.image_des_bg")
    self._label_des = self:getUI("bg.image_des_bg.label_des")
    self._label_des:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._image_des1_bg = self:getUI("bg.image_des1_bg")
    self._image_des1_bg:setVisible(false)
    self._label_des1 = self:getUI("bg.image_des1_bg.label_des")
    self._label_des1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._label_des2 = self:getUI("bg.image_des1_bg.label_des")
    self._label_des2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)  

    self._step = -1
    self._playOpenEffect = false
    self._playRewardEffect = false
    -- print("==============onInit=============")
    self:getCelebrationData()
    self:registerClickEventByName("bg.image_info", function()
        -- dump(self._intPointData,"intPointData==>",5)
        self._viewMgr:showDialog("activity.celebration.AcIntegralPointRuleView", {des=lang("acqingdianrule")})
    end)

    self:registerClickEventByName("bg.btn_check", function()
        self:onCheckButtonClicked()
    end)

    self:registerScriptHandler(function(state)
        if state == "exit" then
            self:endClock()
        end 
    end)
end

function ActivityLotteryLayer:getNextTime()
    local currentTime = self._userModel:getCurServerTime()
    local startTime = self._acData.startTime
    local endTime = self._acData.endTime
    local beginHour = self._intPointData.hourStart
    local endHour = self._intPointData.hourEnd
    local nowTime = TimeUtils.date("*t", currentTime)
    local nextTime = 0
    if nowTime.hour < beginHour then
        self._step = 0  -- 抽奖未开始
        local timeString = string.format("%d-%d-%d %d:00:00", nowTime.year, nowTime.month, nowTime.day, beginHour)
        nextTime = TimeUtils.getIntervalByTimeString(timeString)
        -- 活动结束时的倒计时到活动结束
        if nextTime >= endTime then
            nextTime = endTime
            self._step = 5  -- 活动要结束，没有机会抽奖
        end
    elseif nowTime.hour >= beginHour and nowTime.hour < endHour then
        if beginHour % 2 == nowTime.hour % 2 then
            if #self._intPointData.drawCode > 0 then
                self._step = 2  -- 抽奖时间 参与了抽奖
            else
                self._step = 1  -- 抽奖时间 未参与抽奖
            end
        else
            if #self._intPointData.drawCode > 0 then             	
                self._step = 6  -- 开奖时间 参与了抽奖
            else
                self._step = 3  -- 开奖时间 未参与抽奖
            end
        end
        local timeString = string.format("%d-%d-%d %d:00:00", nowTime.year, nowTime.month, nowTime.day, nowTime.hour + 1)
        nextTime = TimeUtils.getIntervalByTimeString(timeString)
        if nowTime.hour == endHour -1 then
            local nextDayTime = currentTime + 86400
            local nextDayTimeDate = TimeUtils.date("*t", nextDayTime)
            local nextDayTimeString = string.format("%d-%d-%d %d:00:00", nextDayTimeDate.year, nextDayTimeDate.month, nextDayTimeDate.day, beginHour)
            nextTime = TimeUtils.getIntervalByTimeString(nextDayTimeString)
            -- 活动结束倒计时
            if nextTime >= endTime then
                nextTime = endTime
            end
        end
    else
        local nextDayTime = currentTime + 86400
        local nextDayTimeDate = TimeUtils.date("*t", nextDayTime)
        local nextDayTimeString = string.format("%d-%d-%d %d:00:00", nextDayTimeDate.year, nextDayTimeDate.month, nextDayTimeDate.day, beginHour)
        nextTime = TimeUtils.getIntervalByTimeString(nextDayTimeString)
        if nextTime >= endTime then
            nextTime = endTime            
            self._step = 5  -- 活动要结束，没有机会抽奖
        else
            self._step = 4  -- 还有机会下次抽奖
        end
    end

    return nextTime
end

function ActivityLotteryLayer:updateTimeCountDown()
    local isOpen = self._acLotteryModel:isLotteryOpen()
    if not isOpen then
        self._label_count_down:setString("00天00:00:00")
        self._contract_count_down:setString("00:00:00")
        self:endClock()
        return 
    end

    local currentTime = self._userModel:getCurServerTime()
    local endTime = self._acData.endTime

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
        self:countDownAcOver()
        showTime = "00天00:00:00"
    end
    self._label_count_down:setString(showTime)

    local beginHour = self._intPointData.hourStart
    local endHour = self._intPointData.hourEnd
    local intRemainTime = 0

    if not self._nextTime then
        self._nextTime = self:getNextTime()
    end

    if self._nextTime then
        intRemainTime = self._nextTime - currentTime
    end

    local tempValue = intRemainTime    
    local hour = math.floor(tempValue/3600)
    tempValue = tempValue - hour*3600

    local minute = math.floor(tempValue/60)
    tempValue = tempValue - minute*60
   
    local second = math.fmod(tempValue, 60)
    local showIntTime = string.format("%.2d:%.2d:%.2d", hour, minute, second)
    if intRemainTime <= 0 then
        showIntTime = "00:00:00"
        -- print("=========================123213123====")
        self:countDownIntOver()
    end
    self._contract_count_down:setString(showIntTime)

    if self._updateNum then
        self:getLotteryActiveNum()
    end

    self._updateNum = not self._updateNum
end

function ActivityLotteryLayer:countDownIntOver()

    local doNext = function()
        self._nextTime = self:getNextTime()
        self:updateUI()
    end

    -- print("===============countDownIntOver======")
    if 1 == self._step or 2 == self._step then
        self:updateCelebrationData(function()
            self._playRewardEffect = true
            doNext()
        end)
    elseif 5 == self._step then
        self:endClock()
    else
        self:updateCelebrationData(function()
            doNext()
        end)
    end
end

-- 22点刷新数据
function ActivityLotteryLayer:reflashCD(eventName)
    if eventName == "OutOfDate" then
        self:countDownIntOver()
    end
end

function ActivityLotteryLayer:countDownAcOver()
    print("activity is over")
end

function ActivityLotteryLayer:startClock()
    if self._timer_id then return end
    self._timer_id = self._scheduler:scheduleScriptFunc(handler(self, self.updateTimeCountDown), 1, false)
end

function ActivityLotteryLayer:endClock()
    if not self._timer_id then return end
    if self._timer_id then 
        self._scheduler:unscheduleScriptEntry(self._timer_id)
        self._timer_id = nil
    end
end

function ActivityLotteryLayer:initAcIntData()
    self._intPointData = self._acLotteryModel:getData() or {}
    self._acData = self._intPointData
    -- dump(self._intPointData,"self._intPointData==>",5)
    if self._intPointData.drawCode and type(self._intPointData.drawCode) == "string" then
        self._intPointData.drawCode = json.decode(self._intPointData.drawCode)
    end
    -- dump(self._intPointData,"self._intPointData",5)
end

function ActivityLotteryLayer:reflashUI(eventName)
    -- print("===============eventName===========",eventName)  
    if eventName == "getLotteryActiveNum" then return end
    
    self:initAcIntData()
    self:startClock()
    self:updateTimeCountDown()
    self:updateUI()

end

function ActivityLotteryLayer:updateParticipateNum()
    self._label_count:setString(checkint(self._intPointData.participateNum))
end

--[[
	self._step = 0  -- 抽奖未开始
				 2  -- 抽奖时间 参与了抽奖
				 1  -- 抽奖时间 未参与抽奖
				 6  -- 开奖时间 参与了抽奖
				 3  -- 开奖时间 未参与抽奖
				 5  -- 活动要结束，没有机会抽奖
				 4  -- 还有机会下次抽奖

		status -1	--未参与
				0	--参与了未开奖
				1	--未中奖未领取
				2	--未中奖已领取
				3	--中奖未领取
				4	--中奖已领取
]]
function ActivityLotteryLayer:updateUI()
    -- print("======================updateUI", self._step, self._intPointData.status)
    self:updateParticipateNum()
    for i=1, 6 do
        -- self._image_elements[i]:setVisible(false)
        self._image_elements[i]:setOpacity(0)
    end
    self._image_des_bg:setVisible(true)
    self._image_des1_bg:setVisible(false)
    local status = self._intPointData.status
    -- 未参与
    if -1 == status then
        -- 开奖了
        if 3 == self._step or 4 == self._step or 5 == self._step then   --or 6 == self._step 
			self._label_reward:setString(self._intPointData.luckyName)
		else
			self._label_reward:setString("虚位以待")
        end
        if 0 == self._step or 3 == self._step or 4 == self._step then  --or 6 == self._step 
            self._image_contract_title:loadTexture("contract_reset_celebration.png", 1) --契约重置
            self._btn_join:setEnabled(true)
            self._btn_join:setBright(true)
            self._btn_join:setSaturation(0)
            self._btn_join:setVisible(true)
            self._btn_join:setTitleText("召唤法阵")
            self._image_des1_bg:setVisible(false)
        elseif 1 == self._step then
            self._image_contract_title:loadTexture("element_contract_celebration.png", 1) --契约开启
            self._btn_join:setEnabled(true)
            self._btn_join:setBright(true)
            self._btn_join:setSaturation(0)
            self._btn_join:setVisible(true)
            self._btn_join:setTitleText("召唤法阵")
            self._image_des1_bg:setVisible(false)
        elseif 5 == self._step then
            self._image_contract_title:loadTexture("contract_reset_celebration.png", 1)
            self._btn_join:setEnabled(false)
            self._btn_join:setBright(false)
            self._btn_join:setSaturation(-100)
            self._btn_join:setVisible(true)
            self._btn_join:setTitleText("活动结束")
        end
        self._image_des_bg:setVisible(false)
    -- 参与 未开奖
    elseif 0 == status then
    	self._label_reward:setString("虚位以待")
    	self._image_contract_title:loadTexture("element_contract_celebration.png", 1)
        self._btn_join:setEnabled(false)
        self._btn_join:setBright(false)
        self._btn_join:setSaturation(-100)
        self._btn_join:setVisible(false)
        self._btn_join:setTitleText("召唤法阵")
        self._image_des1_bg:setVisible(true)
        self._image_des_bg:setVisible(false)
    -- 未中奖 未领 
    elseif 1 == status then
        self._label_reward:setString(self._intPointData.luckyName)
        self._image_contract_title:loadTexture("contract_reset_celebration.png", 1)
        self._label_des:setString("下次也许运气会更好哦!")
        self._btn_join:setEnabled(6 == self._step)
        self._btn_join:setBright(6 == self._step)
        self._btn_join:setSaturation((6 == self._step) and 0 or -100)
        self._btn_join:setVisible(true)
        self._btn_join:setTitleText("参与奖励")
        self._image_des1_bg:setVisible(false)
	-- 未中奖 已领 
   	elseif 2 == status then
   		self._label_reward:setString(self._intPointData.luckyName)
        self._image_contract_title:loadTexture("contract_reset_celebration.png", 1)
        self._label_des:setString("下次也许运气会更好哦!")
        self._btn_join:setEnabled(false)
        self._btn_join:setBright(false)
        self._btn_join:setSaturation(-100)
        self._btn_join:setVisible(true)
        self._btn_join:setTitleText("已领取")
        self._image_des1_bg:setVisible(false)
        -- 中奖 未领 
    elseif 3 == status then
        self._label_reward:setString(self._intPointData.luckyName)
        self._image_contract_title:loadTexture("contract_reset_celebration.png", 1)
        self._label_des:setString("恭喜您赢得大奖!")
        self._btn_join:setEnabled(0 ~= self._step and 4 ~= self._step and 5 ~= self._step)
        self._btn_join:setBright(0 ~= self._step and 4 ~= self._step and 5 ~= self._step)
        self._btn_join:setSaturation((0 ~= self._step and 4 ~= self._step and 5 ~= self._step) and 0 or -100)
        self._btn_join:setVisible(true)
        self._btn_join:setTitleText("领取奖励")
        self._image_des1_bg:setVisible(false)
        -- 中奖 已领
    elseif 4 == status then
        self._label_reward:setString(self._intPointData.luckyName)
        self._image_contract_title:loadTexture("contract_reset_celebration.png", 1)
        self._label_des:setString("恭喜您赢得大奖!")
        self._btn_join:setEnabled(false)
        self._btn_join:setBright(false)
        self._btn_join:setSaturation(-100)
        self._btn_join:setVisible(true)
        self._btn_join:setTitleText("已领取")
        self._image_des1_bg:setVisible(false)
    end

    if #self._intPointData.drawCode > 0 then
        for k, v in ipairs(self._intPointData.drawCode) do
            self._image_elements[k]:loadTexture("ele_" .. v .. "_celebration.png", 1)
            self._image_elements[k]:setVisible(true)
            self._image_elements[k]:runAction(cc.FadeIn:create(0.15))
        end
    end

    if #self._intPointData.drawCode > 0 and not self._playOpenEffect then
        self._elementMC2:setVisible(false)
    else
        self._elementMC2:setVisible(true)
    end

    -- 开奖时在当前界面 或者 参与抽奖，没有播放开奖动画
    -- print("=======开奖时开奖时=======",self._playRewardEffect,self._acLotteryModel:isIntPointNeedPlayEffect())
    if self._playRewardEffect or self._acLotteryModel:isIntPointNeedPlayEffect() then
        self:playRewardEffect()
        self._playRewardEffect = false
    end

    if not self._intPointData.rewardTeamId then
        self._intPointData.rewardTeamId = 3604
    end

    local teamTableData = tab:Team(tonumber(self._intPointData.rewardTeamId - 3000))
    if teamTableData then
        self._image_team:setOpacity(0)
        self._image_team:loadTexture("asset/uiother/steam/"..TeamUtils.getNpcTableValueByTeam(teamTableData, "steam")..".png")
        self._image_class:loadTexture(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
        self._image_name:loadTexture("team_" .. (self._intPointData.rewardTeamId - 3000) .. "_ac.png", 1)
        self._image_team:runAction(cc.FadeIn:create(0.15))        
    end
end

function ActivityLotteryLayer:updateCelebrationData(callback)
    -- print("===========updateCelebrationData=========")
    local isOpen = self._acLotteryModel:isLotteryOpen()
    if not isOpen then
        return 
    end
    self._serverMgr:sendMsg("ActivityServer", "getLotteryInfo", {}, true, {}, function(result,succ)
        self:initAcIntData()
        callback()
    end)
end

function ActivityLotteryLayer:getCelebrationData()
    local isOpen = self._acLotteryModel:isLotteryOpen()
    if not isOpen then
        self:reflashUI()
        return 
    end
    if self._intPointData then
        self:reflashUI()
    else
        self._serverMgr:sendMsg("ActivityServer", "getLotteryInfo", {}, true, {}, function(result,succ)
            self:reflashUI()
        end)
    end
end

function ActivityLotteryLayer:getLotteryActiveNum()
    if not self or not self._serverMgr then return end
    local isOpen = self._acLotteryModel:isLotteryOpen()
    if not isOpen then
        return 
    end
    self._serverMgr:sendMsg("ActivityServer", "getLotteryActiveNum", {}, true, {}, function(result,succ)
        if not (self._acData and self._intPointData and self._acLotteryModel and self.updateParticipateNum) then return end
        self._intPointData = self._acLotteryModel:getData() or {}
        self._acData = self._intPointData
        self:updateParticipateNum()
    end)
end

function ActivityLotteryLayer:playOpenEffect()
    for i=1, 6 do
        self._image_elements[i]:setRotation3D(cc.Vertex3F(0, 50, 0))
        self._image_elements[i]:setOpacity(0)
        self._image_elements[i]:runAction(cc.Sequence:create({
            cc.DelayTime:create(0.22 * i),
            cc.Spawn:create({
                cc.FadeIn:create(0.3),
                cc.RotateTo:create(0.3, cc.Vertex3F(0, 0, 0))
            })
        }))
    end

    self._elementMC2:addEndCallback(function()
        self._elementMC2:stop()
        self._elementMC2:setVisible(false)
        self._playOpenEffect = false
    end)
    self._elementMC2:setVisible(true)
    self._elementMC2:gotoAndPlay(0)
end

function ActivityLotteryLayer:playRewardEffect()
    self._layer_reward:setVisible(true)

    if self._intPointData.luckyCode then
        for k, v in ipairs(self._intPointData.luckyCode) do
            self._image_reward_elements[k]:loadTexture("ele_" .. v .. "_celebration.png", 1)
            self._image_reward_elements[k]:setVisible(true)
        end
    end

    for i=1, 6 do
        self._image_reward_elements[i]:setRotation3D(cc.Vertex3F(0, 50, 0))
        self._image_reward_elements[i]:setOpacity(0)
        self._image_reward_elements[i]:runAction(cc.Sequence:create({
            cc.DelayTime:create(3.0 + 0.22 * i),
            cc.Spawn:create({
                cc.FadeIn:create(0.3),
                cc.RotateTo:create(0.3, cc.Vertex3F(0, 0, 0))
            })
        }))
    end

    self._elementRewardMC:addEndCallback(function()
        self._elementRewardMC:stop()
        self._elementRewardMC:setVisible(false)
    end)
    self._elementRewardMC:setVisible(true)
    self._elementRewardMC:gotoAndPlay(0)

    self._reward_bg:setVisible(true)
    self._reward_bg:setScale(0.0)
    self._reward_bg:runAction(cc.Sequence:create({
        cc.DelayTime:create(5.0),
        cc.ScaleTo:create(0.15, 1.0)
    }))
    self._label_reward_name:setString(self._intPointData.luckyName)

    self._elementRewardMC1:addEndCallback(function()
        self._elementRewardMC1:stop()
        self._elementRewardMC1:setVisible(false)
    end)
    self._elementRewardMC1:setVisible(true)
    self._elementRewardMC1:gotoAndPlay(0)

    self._elementRewardMC2:setVisible(true)

    self._acLotteryModel:setIntPointEffectPlayed(true)
end

function ActivityLotteryLayer:showRewardDialog(taskData)
    DialogUtils.showGiftGet({gifts = taskData.reward})
end

function ActivityLotteryLayer:onJoinButtonClicked()
    local isOpen = self._acLotteryModel:isLotteryOpen()
    if not isOpen then
        self._viewMgr:showTip("活动已结束")
        return 
    end

    if 0 == self._step then 
        self._viewMgr:showTip(lang("acqingdiantip2"))
        return
    elseif 3 == self._step or 4 == self._step then
        self._viewMgr:showTip(lang("acqingdiantip1"))
        return
    end
    self._btn_join:setEnabled(false)
    self._btn_join:setBright(false)
    self._btn_join:setSaturation(-100)
    local status = self._intPointData.status
    if -1 == status then
    	-- 参与抽奖
        self._serverMgr:sendMsg("ActivityServer", "participateLottery", {}, true, {}, function(result, success)
            if not success then return end
            self._step = 2
            self._playOpenEffect = true
            self:reflashUI()
            self:playOpenEffect()
        end)
    elseif 1 == status or 3 == status then
    	-- 获取奖励
        self._serverMgr:sendMsg("ActivityServer", "getLotteryReward", {}, true, {}, function(result, success)
            --dump(result, "result", 5)
            -- print("===========getLotteryReward==============")
            if not success then return end
            self:showRewardDialog(result)
            self:reflashUI()
        end)
    end
end

function ActivityLotteryLayer:onCheckButtonClicked()
    local rewardTeamId = 0
    if self._intPointData and self._intPointData.rewardTeamId then
        rewardTeamId = self._intPointData.rewardTeamId - 3000
    else
        rewardTeamId = 604
    end

    local NewFormationIconView = require "game.view.formation.NewFormationIconView"
    self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = 1000, iconId = rewardTeamId}, true)
end

function ActivityLotteryLayer:isNoReflash()
    return true
end

return ActivityLotteryLayer