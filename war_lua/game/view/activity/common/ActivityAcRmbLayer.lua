--[[
    Filename:    ActivityAcRmbLayer.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-11-04 16:17:29
    Description: File description
--]]

local ActivityTaskItemView = require("game.view.activity.ActivityTaskItemView")

local ActivityAcRmbLayer = class("ActivityAcRmbLayer", require("game.view.activity.common.ActivityCommonLayer"))

function ActivityAcRmbLayer:ctor(params)
    ActivityAcRmbLayer.super.ctor(self)

    self._activityId = params.activityId
    self._activityTaskData = {}

    self._activityModel = self._modelMgr:getModel("ActivityModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._vipModel = self._modelMgr:getModel("VipModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._paymentModel = self._modelMgr:getModel("PaymentModel")
end

function ActivityAcRmbLayer:onDestroy()
    ActivityAcRmbLayer.super.onDestroy(self)
end

function ActivityAcRmbLayer:disableTextEffect(element)
    if element == nil then
        element = self._widget
    end
    local desc = element:getDescription()
    if desc == "Label" then
        element:disableEffect()
        element:setFontName(UIUtils.ttfName)
    end
    local count = #element:getChildren()
    for i = 1, count do
        self:disableTextEffect(element:getChildren()[i])
    end
end


function ActivityAcRmbLayer:onInit()
    self:disableTextEffect()
    self._scheduler = cc.Director:getInstance():getScheduler()
    self._sysAcData = tab:DailyActivity(self._activityId)

    local bg = self:getUI("bg")
    bg:setBackGroundImage("asset/bg/ac_bg_2.jpg")

    local timeDes = self:getUI("bg.timeDes")
    timeDes:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    timeDes:setFontName(UIUtils.ttfName)

    local timeNum = self:getUI("bg.timeNum")
    timeNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    timeNum:setFontName(UIUtils.ttfName)

    --临时修改
    local titleTb = {"进阶特惠礼包", "泰坦神箭礼包", "巫妖特惠礼包"}
    local discountTb = {"50%折扣", "50%折扣", "88%折扣"}
    local btnTitle = {"98元购买", "168元购买", "328元购买"}
    for i=1,3 do
        local giftList = self:getUI("bg.gift" .. i)

        --title
        local title = giftList:getChildByName("title")
        title:setString(titleTb[i])

        --tip
        local tip = giftList:getChildByName("tip")
        tip:setString(discountTb[i])

        --lvLimit
        local vipDes = giftList:getChildByName("tip2")
        vipDes:setVisible(false)
    end

    local ruleBtn = ccui.Button:create("globalImage_info.png", "globalImage_info.png", "globalImage_info.png", 1)
    ruleBtn:setPosition(624, 399)
    bg:addChild(ruleBtn)
    self:registerClickEvent(ruleBtn, function ()
        local ruleDesc = lang("zhigourule")
        self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = ruleDesc},true)
    end)

    self:refreshUI()

    for i=1,3 do
        local buyBtn = self:getUI("bg.gift" .. i .. ".buyBtn")
        self:registerClickEvent(buyBtn, function ()
            self:onButtonClicked(i)
        end)
    end

    self:registerScriptHandler(function(state)
        if state == "exit" then
            -- UIUtils:reloadLuaFile("activity.common.ActivityAcRmbLayer")
            self:endClock()
        end 
    end)  
end

function ActivityAcRmbLayer:refreshUI()
    self._activityTaskData = self:initActivityData()
    self._acData = self:getAcShowList()
    self:startClock()
    self:updateTimeCountDown()
    -- dump(self._activityTaskData, "da5ta", 10)

    for i=1,3 do
        local currData = self._activityTaskData[i]

        local giftList = self:getUI("bg.gift" .. i)
        --btn
        local btn = giftList:getChildByName("buyBtn")
        if btn._mc then
            btn._mc:removeFromParent(true)
            btn._mc = nil
        end

        --btn title
        -- local titleNum = {1, 3, 6}
        local titleNum = {98, 168, 328}
        if 0 == currData.statusInfo.status then
            btn:setTitleText("已购买")
            btn:setSaturation(-180)
            btn:setTouchEnabled(false)
            btn:setTitleFontSize(26)
        else
            btn:setTitleText(titleNum[i].."元购买")
            btn:setSaturation(0)
            btn:setTouchEnabled(true)
            btn:setTitleFontSize(22)

            local btnMc = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true)
            btnMc:setPosition(btn:getContentSize().width / 2 - 2, btn:getContentSize().height / 2)
            btn._mc = btnMc
            btn:addChild(btnMc)
        end

        --lvLimit
        local vipDes = giftList:getChildByName("tip2")
        vipDes:setString("v" .. currData.viplimit .. "尊享")

        --rwd
        local rewardIcon = giftList:getChildByName("reward")
        rewardIcon:setVisible(false)
        local _rewards = currData.reward
        for i=1, #_rewards do
            local giftItem = rewardIcon
            rewardIcon:setVisible(true)
            local itemIcon = rewardIcon._itemIcon
            if itemIcon then 
                itemIcon:removeFromParent() 
            end

            local itemId = _rewards[i][2]
            local itemType = _rewards[i][1]
            local num = _rewards[i][3]
            local eventStyle = 1

            if itemType == "hero" then
                local heroData = clone(tab:Hero(itemId))
                itemIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
                itemIcon:getChildByName("starBg"):setVisible(false)
                for i=1,6 do
                    if itemIcon:getChildByName("star" .. i) then
                        itemIcon:getChildByName("star" .. i):setPositionY(itemIcon:getChildByName("star" .. i):getPositionY() + 5)
                    end
                end
                itemIcon:setSwallowTouches(false)
                registerClickEvent(itemIcon, function()
                    local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                    self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = itemId}, true)
                end)

            elseif itemType == "team" then
                local teamTeam = clone(tab:Team(itemId))
                itemIcon = IconUtils:createSysTeamIconById({sysTeamData = teamTeam})

            else
                if itemType ~= "tool" then
                    itemId = IconUtils.iconIdMap[itemType]
                end
                itemIcon = IconUtils:createItemIconById({itemId = itemId, num = num,eventStyle = eventStyle})
            end
            itemIcon:setAnchorPoint(cc.p(0.5, 0.5))
            itemIcon:setScale(0.65)
            rewardIcon._itemIcon = itemIcon
            rewardIcon:addChild(itemIcon)
        end
    end  
end

function ActivityAcRmbLayer:initActivityData()
    local result = {}
    local acTableData = tab.acRmb
    local acTaskData = self._activityModel:getAcRmbData()
    acTaskData = acTaskData[tostring(self._activityId)]
    if not acTaskData then
        acTaskData = {[tostring(self._activityId)] = {}}
    end

    local findacData = function(key)
        for k, v in pairs(acTaskData) do
            if tonumber(k) == tonumber(key) then
                return true, v
            end
        end
        return false
    end

    for k, v in ipairs(self._sysAcData.task_list) do
        repeat
            local d = clone(tab:AcRmb(v))
            if d then
                local f, t = findacData(v)
                if f then
                    d.statusInfo = {
                        status = 0,
                        value = 0,
                        condition = 1
                    }
                else
                    d.statusInfo = {
                        status = 1,
                        value = 0,
                        condition = 1
                    }
                end
                d.button = 0
                d.description = d.desc
                d.reward = tab:CashGoodsLib(d.goodsId).reward
                d.uitype = ActivityAcRmbLayer.kActivityType1
                table.insert(result, d)
            end
        until true
    end
    -- dump(result, "result", 5)

    return result
end

function ActivityAcRmbLayer:getAcShowList()
    local acShowList = self._activityModel:getActivityShowList()
    for k, v in pairs(acShowList) do
        if v.activity_id == self._activityId then
            return v
        end
    end
end

function ActivityAcRmbLayer:getTimeInfo()
    local currentTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local isClose = 1 == self._acData.isClose
    local appearTime = self._acData.appear_time
    local startTime = self._acData.start_time
    local endTime = self._acData.end_time
    local remainTime = 0
    
    if not isClose then
        tips = "%02d天%02d:%02d:%02d"
        remainTime = endTime - currentTime
    elseif currentTime >= appearTime and currentTime < startTime then
        tips = "%02d天%02d:%02d:%02d"
        remainTime = startTime - currentTime
    end
    
    return remainTime, tips
end


function ActivityAcRmbLayer:updateTimeCountDown()
    if self._timerDirty then
        self._remainTime = self:getTimeInfo()
        self._timerDirty = false
    else
        self._remainTime = self._remainTime - 1
    end

    local tempValue = self._remainTime    
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
    if self._remainTime <= 0 then
        showTime = "00天00:00:00"
    end

     local timeNum = self:getUI("bg.timeNum")
    timeNum:setString(showTime)
end

function ActivityAcRmbLayer:startClock()
    self._timerDirty = true
    if self._timeSchedule then return end
    self._timeSchedule = self._scheduler:scheduleScriptFunc(handler(self, self.updateTimeCountDown), 1, false)
end

function ActivityAcRmbLayer:endClock()
    if not self._timeSchedule then return end
    if self._timeSchedule then 
        self._scheduler:unscheduleScriptEntry(self._timeSchedule)
        self._timeSchedule = nil
        self._timerDirty = false
    end
end

function ActivityAcRmbLayer:showRewardDialog(taskData)
    local params = clone(taskData.acRmbReward)
    DialogUtils.showGiftGet({gifts = params})
end

--getBtm
function ActivityAcRmbLayer:onButtonClicked(inType)
    --任务尚未完成
    local taskData = self._activityTaskData[inType]
    if 0 == taskData.statusInfo.status then
        self._viewMgr:showTip("已购买")
        return
    end

    --等级不足
    if taskData.viplimit then
        local vipLevel = self._vipModel:getLevel()
        if vipLevel < taskData.viplimit then 
            DialogUtils.showNeedCharge({desc = "VIP等级不足，是否前去充值", callback1=function()
                self._viewMgr:showView("vip.VipView", {viewType = 0})
            end})
            return
        end
    end

    --充值
    self._paymentModel:charge(self._paymentModel.kProductType2, {activityId = self._activityId, itemId = taskData.id}, function(success, data)
        if not success then return end
        if not (self.refreshUI and self.showRewardDialog) then return end
        if data and data.acRmbReward then
            self:showRewardDialog(data)
        end
        self:refreshUI()
    end)
end

function ActivityAcRmbLayer:hasTaskCanGet(index)
    if not (self._activity and self._activity[index]) then return false end
    if ActivityAcRmbLayer.kActivityType1 == self._activity[index].acType then
        if not self._activity[index].taskList then return false end
        for _, v in ipairs(self._activity[index].taskList) do
            if 1 == v.statusInfo.status then
                return true
            end
        end
        if self._activity[index].redTag then
            return true
        end
    else
        if self._activity[index].redTag then
            return true
        end

        if 101 == self._activity[index].id then
            return self._activityModel:isACERebateDateTip()
        elseif 102 == self._activity[index].id then
            return self._activityModel:isACERechargeTip()
        elseif 99 == self._activity[index].id then
            return self._activityModel:isShareDataTip()                    
        elseif 100 == self._activity[index].id then
            return self._activityModel:isMonthCardCandGet()
        elseif 99999 == self._activity[index].id then
            return self._activityModel:isPhysicalCandGet()
        end
    end   
    
    return false
end

return ActivityAcRmbLayer