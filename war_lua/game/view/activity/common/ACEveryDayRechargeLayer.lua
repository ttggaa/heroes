--[[
    Filename:    ACEveryDayRechargeLayer.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-03-31 16:02:14
    Description: File description
--]]
-- 每日充值活动

local ACEveryDayRechargeLayer = class("ACEveryDayRechargeLayer", require("game.view.activity.common.ActivityCommonLayer"))

-- function ACEveryDayRechargeLayer:getAsyncRes()
--     return 
--     {
--     	"asset/bg/ac_bg_1.jpg",
--         {"asset/ui/acERecharge.plist", "asset/ui/acERecharge.png"},
-- 	}
-- end

function ACEveryDayRechargeLayer:ctor()
    ACEveryDayRechargeLayer.super.ctor(self)
    self._rechargeDay = 1
    self._allDay = 1
end

function ACEveryDayRechargeLayer:destroy()
	
	ACEveryDayRechargeLayer.super.destroy(self)
end

function ACEveryDayRechargeLayer:onInit()
	ACEveryDayRechargeLayer.super.onInit(self)

    local lab1 = self:getUI("bg.itemShowBg.lab1")
    local rechargeNum = self:getUI("bg.itemShowBg.rechargeNum")
    local lab2 = self:getUI("bg.itemShowBg.lab2")
    lab1:setFontSize(20)
    lab2:setFontSize(20)

    rechargeNum:setFontSize(20)
    rechargeNum:enableOutline(cc.c4b(60,30,10,255), 1)

    local showTrsu = self:getUI("bg.showTrsu")
    self:registerClickEvent(showTrsu, function()
        -- self._viewMgr:showDialog("treasure.TreasurePreview", { cid = 10 }, true)
    end)

    local activityModel = self._modelMgr:getModel("ActivityModel")
    local everyRechargeData = activityModel:getACERechargeShowList() 
    local bg = self:getUI("bg")
    self._templateId = everyRechargeData.templateId

    self._acBaowu = {}
    local activity102 = tab.activity102
    for i=1,self._templateId do
        self._acBaowu[i] = 1
        local reward = activity102[i*10+1].reward
        if reward then
            local _reward = reward[2]
            if _reward then
                local treasureId = _reward[2]
                if treasureId == 40321 then
                    self._acBaowu[i] = 3
                end
            end
        end
    end
    self._acBaowu[2] = 2 -- 开服第二周鬼王每日活动
    
    if self._templateId == 1 then
        bg:setBackGroundImage("asset/bg/ac_bg_1.jpg")
    else
        bg:setBackGroundImage("asset/bg/ac_bg_1.jpg")
    end
    if table.nums(everyRechargeData) == 0 then
        return
    end
    self:setAnim()
    self:reflashUI()
    self:updateUI()
end


function ACEveryDayRechargeLayer:setAnim()
    local reward = self:getUI("bg.itemShowBg.reward")
    self._btnAnim = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true)
    self._btnAnim:setPosition(cc.p(reward:getContentSize().width*0.5, reward:getContentSize().height*0.5))
    reward:addChild(self._btnAnim)
end  

function ACEveryDayRechargeLayer:reflashUI()  
    -- print("==ACEveryDayRechargeLayer:reflashUI()  ========")
    local activityModel = self._modelMgr:getModel("ActivityModel")
    -- 活动统一信息
    local everyRechargeData = activityModel:getACERechargeShowList() 
    dump(everyRechargeData,"everyRechargeData ====================")

    -- 达成天数
    local rechargeDayNum = activityModel:getACERechargeDay()
    -- dump(activityModel:getACERechargeDay(),"self._rechargeDay ====================")

    -- 详细数据
    local rechargeSpecial = activityModel:getACERechargeSpecialData() 
    dump(rechargeSpecial,"rechargeSpecial ====================")

    -- 当日充值数据
    local todayRechargeData = activityModel:getTodayRechargeData() 
    dump(todayRechargeData, "todayRechargeData =========================")
    -- 

    -- 充值时间
    -- 领取时间
    -- 当前时间
    -- 是否领取
    
    -- 每日数据Id
    local activity102IndexId
    if rechargeSpecial["progress"] and rechargeSpecial["progress"] ~= 0 then
        local tempReflash, tempIndexId
        local userTime = self._modelMgr:getModel("UserModel"):getCurServerTime()

        local lastSignIn = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(rechargeSpecial["rewardTime"],"%Y-%m-%d %H:%M:%S"))
        -- 2016-04-05 05:03:00
        local tempSignDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(rechargeSpecial["rewardTime"],"%Y-%m-%d 05:00:00"))
        -- 2016-04-05 00:00:00
        local tempRealSignDayTime = tempSignDayTime
        if tempSignDayTime < lastSignIn then
            tempRealSignDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(rechargeSpecial["rewardTime"] + 86400,"%Y-%m-%d 05:00:00"))
        end
        if userTime >= tempRealSignDayTime then
            tempReflash = true
        end
       
        if tempReflash == true then
            tempIndexId = rechargeSpecial["progress"] + 1
        else
            tempIndexId = rechargeSpecial["progress"]
        end
        
        if tempIndexId > 5 then
            activity102IndexId = everyRechargeData.templateId .. 5
        else
            activity102IndexId = everyRechargeData.templateId .. tempIndexId
        end
    else
        activity102IndexId = everyRechargeData.templateId .. 1
    end

    local everyRecharge = tab:Activity102(tonumber(activity102IndexId))
-- 提示文字
    local lab1 = self:getUI("bg.itemShowBg.lab1")
    local rechargeNum = self:getUI("bg.itemShowBg.rechargeNum")
    local lab2 = self:getUI("bg.itemShowBg.lab2")
    rechargeNum:setString(everyRecharge.amount .. "钻石")
    rechargeNum:setPositionX(lab1:getPositionX() + lab1:getContentSize().width + 2)
    lab2:setPositionX(rechargeNum:getPositionX() + rechargeNum:getContentSize().width + 5)

    local minGem = self:getUI("bg.minGem")
    local ttempId = self._acBaowu[everyRechargeData["templateId"]] or 1
    minGem:loadTexture("acERecharge_tipImg" .. ttempId .. ".png", 1)

    local rwdBg = self:getUI("bg.itemShowBg.rewardBg")
    local failName = "acERecharge_rewardBg1.png"
    if ttempId == 2 or ttempId == 3 then
        failName = "acERecharge_rewardBg2.png"
    end
    rwdBg:loadTexture(failName, 1)

    if not rechargeSpecial["progress"] then
        rechargeSpecial["progress"] = 0
    end
    self._allDay = rechargeSpecial["progress"]

-- 领取按钮
    local reward = self:getUI("bg.itemShowBg.reward")
    local userModel = self._modelMgr:getModel("UserModel")
    local userTimes = userModel:getCurServerTime()

    -- rechargeSpecial 领取的天数
    -- rechargeDayNum 达成条件的天数
    -- print("达成条件的天数， 领取的天数", table.nums(rechargeDayNum), rechargeSpecial["progress"]) --table.nums(rechargeSpecial))
    -- dump(rechargeDayNum)
    -- dump(rechargeSpecial)
    local userTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local todayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(userTime,"%Y-%m-%d 05:00:00"))
    local yesdayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(userTime-86400,"%Y-%m-%d 05:00:00"))
    local lingqu = 0
    local lingquflag = 0  
    -- print(" userTime > todayTime ========", userTime, todayTime, rechargeSpecial["rechargeTime"])
    if userTime > todayTime then -- 5~24
        if rechargeSpecial["rechargeTime"] and rechargeSpecial["rechargeTime"] > todayTime then
            if rechargeSpecial["amount"] and rechargeSpecial["amount"] >= everyRecharge.amount then
                lingqu = 1
            end
            if rechargeSpecial["rewardTime"] and rechargeSpecial["rewardTime"] > todayTime then
                lingquflag = 2
                lingqu = 0
            end
        end
    else -- 0~5
        if rechargeSpecial["rechargeTime"] and rechargeSpecial["rechargeTime"] < todayTime and rechargeSpecial["rechargeTime"] > yesdayTime then
            if rechargeSpecial["amount"] and rechargeSpecial["amount"] >= everyRecharge.amount then
                lingqu = 1
            end
            if rechargeSpecial["rewardTime"] and rechargeSpecial["rewardTime"] > yesdayTime then
                lingquflag = 2
                lingqu = 0
            end
        end
    end

    -- print("lingqu ===================", lingqu, lingquflag)
    local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl
    if userlvl < 6 then
        self:registerClickEvent(reward, function()
            self._viewMgr:showTip("达到6级可领取奖励")
        end) 

    elseif lingqu == 1 and lingquflag ~= 2 then
        local rewardId
        reward:setTitleText("领取")
        reward:setSaturation(0) 
        self._btnAnim:setVisible(true)
        for i=1,table.nums(rechargeDayNum) do
            if not rechargeSpecial[tostring(i)] then
                rewardId = i
                break
            end
        end
        self:registerClickEvent(reward, function()
            self:getSpecialAcReward(rewardId)
        end)  

    elseif lingqu == 0 then
        self._btnAnim:setVisible(false)
        if lingquflag == 2 then
            reward:setTitleText("已领取")
            reward:setSaturation(-100)
            self:registerClickEvent(reward, function()
                self._viewMgr:showTip("你已经领取了奖励")
            end)   
        else
            reward:setTitleText("领取")
            reward:setSaturation(0)
            self:registerClickEvent(reward, function()
                DialogUtils.showNeedCharge({desc = "充值额度不足，请前往充值", callback1=function( )
                    local viewMgr = ViewManager:getInstance()
                    viewMgr:showView("vip.VipView", {viewType = 0})
                end})
            end) 
        end
    else
        self:registerClickEvent(reward, function()
            self._viewMgr:showTip("")
        end)  
    end

    -- reward icon
    local everyReward = everyRecharge.reward
    for i=1,3 do
        local itemBg = self:getUI("bg.itemShowBg.itemBg" .. i)
        if i <= table.nums(everyReward) then
            local num = everyReward[i][3]
            local itemId = everyReward[i][2]
            if everyReward[i][1] ~= "tool" then
                itemId = IconUtils.iconIdMap[everyReward[i][1]]
            end
            local itemIcon = itemBg:getChildByName("itemIcon")
            local param = {itemId = itemId, num = num}
            if itemICon then
                IconUtils:updateItemIconByView(itemIcon, param)
            else
                itemIcon = IconUtils:createItemIconById(param)
                itemIcon:setScale(0.9)
                itemIcon:setName("itemIcon")
                itemBg:addChild(itemIcon)
            end
            itemBg:setVisible(true)
        else
            itemBg:setVisible(false)
        end
    end
    self:setReward()

    -- 设置进度条
    self:setProgress(everyRecharge.amount)
    if rechargeSpecial["progress"] and rechargeSpecial["progress"] >= 5 then
        reward:setSaturation(-100)
        reward:setTitleText("已领取")
        self:registerClickEvent(reward, function()
            self._viewMgr:showTip("活动结束")
        end)   
        return

    elseif everyRechargeData.end_time <= userTimes then
        reward:setSaturation(-100)
        self:registerClickEvent(reward, function()
            self._viewMgr:showTip("活动结束")
        end)   
        return
    elseif everyRechargeData.start_time+1 > userTimes then
        reward:setSaturation(0)
        self:registerClickEvent(reward, function()
            self._viewMgr:showTip("活动结束")
        end)   
        return
    end

end

-- 设置宝箱
function ACEveryDayRechargeLayer:setReward() 
    local activityModel = self._modelMgr:getModel("ActivityModel")
    local rechargeDay = activityModel:getACERechargeDay()
    local rechargeSpecial = activityModel:getACERechargeSpecialData() 
    local everyRechargeData = activityModel:getACERechargeShowList() 

    -- 展示奖品
    for i=1,5 do
        local everyReward = tab:Activity102(tonumber(everyRechargeData.templateId .. i))

        local num = everyReward["show"][3]
        local itemId = everyReward["show"][2]
        if everyReward["show"][1] ~= "tool" then
            itemId = IconUtils.iconIdMap[everyReward["show"][1]]
        end
        local rewardDay = self:getUI("bg.baoxiangBg.rewardDay" .. i)
        local zhezhao = self:getUI("bg.baoxiangBg.rewardDay" .. i .. ".zhezhao")
        local lingquLab = self:getUI("bg.baoxiangBg.rewardDay" .. i .. ".lingquLab")
        zhezhao:setVisible(false)
        lingquLab:setVisible(false)
        local itemIcon = rewardDay:getChildByName("itemIcon")
        local param = {itemId = itemId, num = num}
        if i <= rechargeSpecial["progress"] then
            param.effect = true
            zhezhao:setVisible(true)
            lingquLab:setVisible(false)
        end
        
        if itemIcon then
            IconUtils:updateItemIconByView(itemIcon, param)
        else
            itemIcon = IconUtils:createItemIconById(param)
            itemIcon:setName("itemIcon")
            itemIcon:setPosition(cc.p(2, 2))
            itemIcon:setScale(0.6)
            rewardDay:addChild(itemIcon)
        end
        param = nil 
    end
end

-- 设置不刷新的数据
function ACEveryDayRechargeLayer:updateUI()
    local activityModel = self._modelMgr:getModel("ActivityModel")
    local everyRechargeData = activityModel:getACERechargeShowList() 
    local templateId = self._acBaowu[everyRechargeData["templateId"]] or 1
    if templateId == 1 then
        --神弓动画
        local showTrsuBg = self:getUI("bg.showTrsu")
        local showTrsu = mcMgr:createViewMC("huanyingshengong_treasurehuanyingshengong", true, false)
        showTrsu:setName("showTrsu")
        showTrsu:setScale(0.8)
        showTrsu:setPosition(cc.p(showTrsuBg:getContentSize().width/2, showTrsuBg:getContentSize().height/2))
        showTrsuBg:addChild(showTrsu)
    else
        -- 鬼王斗篷
        local showTrsuBg = self:getUI("bg.showTrsu")
        local showTrsu = mcMgr:createViewMC("guiwangdoupeng_treasureguiwangdoupeng", true, false)
        showTrsu:setName("showTrsu")
        showTrsu:setScale(0.8)
        showTrsu:setPosition(cc.p(showTrsuBg:getContentSize().width/2, showTrsuBg:getContentSize().height/2))
        showTrsuBg:addChild(showTrsu)
    end

    
    -- 倒计时时间
    local activityModel = self._modelMgr:getModel("ActivityModel")
    local everyRechargeData = activityModel:getACERechargeShowList() 
    local userModel = self._modelMgr:getModel("UserModel")
    local userTimes = userModel:getCurServerTime()
    local endTime = self:getUI("bg.endBg.endTime")
    endTime:setFontSize(18)
    local endLab = self:getUI("bg.endBg.endLab")
    endLab:setFontSize(18)
    local tempTime = everyRechargeData.end_time - userModel:getCurServerTime() -- 85600 -- userTimes
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
            endTime:setString(showTime)
            endTime:setPositionX(endLab:getPositionX() + endLab:getContentSize().width + 5)
        end),cc.DelayTime:create(1))
    ))
end


function ACEveryDayRechargeLayer:setProgress(amount)
    local activityModel = self._modelMgr:getModel("ActivityModel")
    local rechargeSpecial = activityModel:getACERechargeSpecialData() 
    local userTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local todayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(userTime,"%Y-%m-%d 05:00:00"))
    local yesdayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(userTime-86400,"%Y-%m-%d 05:00:00"))

    local lingqu = 0
    -- print(" userTime > todayTime ========", userTime, todayTime, rechargeSpecial["rechargeTime"])
    if userTime > todayTime then -- 5~24
        if rechargeSpecial["rechargeTime"] and rechargeSpecial["rechargeTime"] > todayTime then
            if rechargeSpecial["amount"] and rechargeSpecial["amount"] >= amount then
                if rechargeSpecial["rewardTime"] and rechargeSpecial["rewardTime"] < todayTime then
                    lingqu = 1
                end
            end

        end
    else -- 0~5
        if rechargeSpecial["rechargeTime"] and rechargeSpecial["rechargeTime"] < todayTime and rechargeSpecial["rechargeTime"] > yesdayTime then
            if rechargeSpecial["amount"] and rechargeSpecial["amount"] >= amount then
                if rechargeSpecial["rewardTime"] and rechargeSpecial["rewardTime"] < yesdayTime then
                    lingqu = 1
                end
            end

        end
    end

    local rechargeDayNum = self._allDay
    if lingqu == 1 then
        rechargeDayNum = self._allDay + 1
    end

    local progress = self:getUI("bg.baoxiangBg.progressBg.progress")
    local str = 0 
    
    -- print("rechargeDayNum =======", rechargeDayNum)
    if rechargeDayNum < 1 then
        str = 0
    elseif rechargeDayNum > 4 then
        str = 100
    else
        str = (rechargeDayNum-1) * 25
    end
    progress:setPercent(str)

end

function ACEveryDayRechargeLayer:getSpecialAcReward(rewardId)
    if not rewardId then
        self._viewMgr:showTip("参数有误")
        return
    end
    self._serverMgr:sendMsg("ActivityServer", "getSpecialAcReward", {acId = 102, args = json.encode({id = rewardId})}, true, {}, function (result)
        self:getSpecialAcRewardFinish(result)
    end)
end

function ACEveryDayRechargeLayer:getSpecialAcRewardFinish(result)
    if result == nil then
        return
    end

    -- dump(result, "result ==============")
    if result.reward then
        DialogUtils.showGiftGet( {
            gifts = result.reward,
            title = lang("FINISHSTAGETITLE"),
            callback = function()
        end})
    end
    self:reflashUI()
end

function ACEveryDayRechargeLayer:isACERechargeTip()
    local activityModel = self._modelMgr:getModel("ActivityModel")
    return activityModel:isACERechargeTip()
end

return ACEveryDayRechargeLayer