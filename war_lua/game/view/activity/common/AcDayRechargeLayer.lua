--[[
    Filename:    AcDayRechargeLayer.lua
    Author:      wangyan@playcrab.com
    Datetime:    2017-09-19 18:12:14
    Description: 每日充值活动2
--]]

local AcDayRechargeLayer = class("AcDayRechargeLayer", require("game.view.activity.common.ActivityCommonLayer"))

function AcDayRechargeLayer:ctor()
    AcDayRechargeLayer.super.ctor(self)
    self._acModel = self._modelMgr:getModel("ActivityModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._curIndex = 0
end

function AcDayRechargeLayer:destroy()
	AcDayRechargeLayer.super.destroy(self)
end

function AcDayRechargeLayer:onInit()
    local rechargeNum = self:getUI("bg.itemShowBg.rechargeNum")
    rechargeNum:enableOutline(cc.c4b(60,30,10,255), 1)

    local bg = self:getUI("bg")
    bg:setBackGroundImage("asset/bg/ac_dayRecharge_bg1.jpg")

    --查看btn
    local showTrsu = self:getUI("bg.checkBtn")
    self:registerClickEvent(showTrsu, function()
        local isOpen = tab.systemOpen["Treasure"]
        local userData = self._userModel:getData()
        if userData.lvl < isOpen[1] then
            self._viewMgr:showTip(lang(isOpen[3]))
            return
        end
        
        self._viewMgr:showView("treasure.TreasureView",{treasureId = 33})
    end)

    --按钮动画
    local rwdBtn = self:getUI("bg.itemShowBg.rwdBtn")
    self._btnAnim = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true)
    self._btnAnim:setPosition(cc.p(rwdBtn:getContentSize().width*0.5, rwdBtn:getContentSize().height*0.5 - 1))
    rwdBtn:addChild(self._btnAnim)

    local rechargeData = self._acModel:getACERechargeShowList() 
    if next(rechargeData) == nil then
        return
    end

    self:reflashUI()
    self:updateUI()
end

function AcDayRechargeLayer:reflashUI()  
    -- 活动统一信息
    self._dayRData = self._acModel:getACERechargeShowList() 
    dump(self._dayRData,"dayRData ====================")
    
    -- 详细数据
    self._daySRData = self._acModel:getACERechargeSpecialData() 
    dump(self._daySRData,"daySRData ====================")

    if next(self._dayRData) == nil then
        return
    end

    if self._daySRData["progress"] and self._daySRData["progress"] ~= 0 then
        local userTime = self._userModel:getCurServerTime()
        local lastRwdT = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(self._daySRData["rewardTime"],"%Y-%m-%d %H:%M:%S"))
        local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(self._daySRData["rewardTime"],"%Y-%m-%d 05:00:00"))
        if tempTime < lastRwdT then
            tempTime = tempTime + 86400
        end

        local index
        if userTime >= tempTime then
            index = self._daySRData["progress"] + 1
        else
            index = self._daySRData["progress"]
        end
        
        if index > 5 then
            self._curIndex = tonumber(self._dayRData.templateId .. 5)
        else
            self._curIndex = tonumber(self._dayRData.templateId .. index)
        end 
    else
        self._curIndex = tonumber(self._dayRData.templateId .. 1)
    end
    
    -- 上部ui
    self:setCostUI()
    
    -- 下部ui
    self:setRewardBox()
end

--充值数 + 奖励
function AcDayRechargeLayer:setCostUI()
    local curData = tab:Activity102(self._curIndex)

    --充值数
    local lab1 = self:getUI("bg.itemShowBg.lab1")
    local costNum = self:getUI("bg.itemShowBg.rechargeNum")
    local lab2 = self:getUI("bg.itemShowBg.lab2")
    costNum:setString(curData.amount .. "钻石")
    costNum:setPositionX(lab1:getPositionX() + lab1:getContentSize().width + 2)
    lab2:setPositionX(costNum:getPositionX() + costNum:getContentSize().width + 5)

    --奖励
    local rwd = curData.reward
    for i=1,3 do
        local itemBg = self:getUI("bg.itemShowBg.itemBg" .. i)
        if i <= table.nums(rwd) then
            local num = rwd[i][3]
            local itemId = rwd[i][2]
            if rwd[i][1] ~= "tool" then
                itemId = IconUtils.iconIdMap[rwd[i][1]]
            end

            local param = {itemId = itemId, num = num}
            local itemIcon = itemBg:getChildByName("itemIcon")
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

    -- rewardBtn
    self:setRewardBtn()

    -- 进度条
    self:setProgress() 
end

-- 设置宝箱
function AcDayRechargeLayer:setRewardBox() 
    local rSpecialData = self._acModel:getACERechargeSpecialData() 
    local rechargeData = self._acModel:getACERechargeShowList() 

    for i=1, 4 do
        local rewardDay = self:getUI("bg.baoxiangBg.rewardDay" .. i)
        local zhezhao = self:getUI("bg.baoxiangBg.rewardDay" .. i .. ".zhezhao")
        local lingquLab = self:getUI("bg.baoxiangBg.rewardDay" .. i .. ".lingquLab")
        zhezhao:setVisible(false)
        lingquLab:setVisible(false)

        local reward = tab:Activity102(tonumber(rechargeData.templateId .. i))
        local num = reward["show"][3]
        local itemId = reward["show"][2]
        if reward["show"][1] ~= "tool" then
            itemId = IconUtils.iconIdMap[reward["show"][1]]
        end

        local itemIcon = rewardDay:getChildByName("itemIcon")
        local param = {itemId = itemId, num = num}
        if i <= rSpecialData["progress"] then
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
    end
end

--常态
function AcDayRechargeLayer:updateUI()
    --宝物动画
    local rechargeData = self._acModel:getACERechargeShowList() 
    local sysAc102 = tab.activity102
    local startIndex = rechargeData["templateId"] * 10
    local animName = "huanyingshengong_treasurehuanyingshengong"       --幻影神弓
    for i=1, 4 do
        local acData = sysAc102[startIndex + i]
        if acData then
            local rwdId = acData.reward[2][2]
            if rwdId == 40321 then
                animName = "guiwangdoupeng_treasureguiwangdoupeng"      --鬼王斗篷
            elseif rwdId == 41001 then
                animName = "huotiyingyan_treasureyingyan"  --活体鹰眼
            end
        end
    end

    local showTrsuBg = self:getUI("bg.showTrsu")
    local showTrsu = mcMgr:createViewMC(animName, true, false)
    showTrsu:setName("showTrsu")
    showTrsu:setScale(1.1)
    showTrsu:setPosition(cc.p(showTrsuBg:getContentSize().width/2 - 10, showTrsuBg:getContentSize().height/2 - 15))
    showTrsuBg:addChild(showTrsu)

    -- 倒计时时间
    self:setCountDown()
end

--进度条
function AcDayRechargeLayer:setProgress()
    local curData = tab:Activity102(self._curIndex)
    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()   --当前时间
    local start_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 05:00:00"))  --当日开启时间
    if curTime < start_time then   --过零点判断
        start_time = start_time - 86400
    end

    local lingqu = 0  --充值且未领奖  0不可领 1可领
    if self._daySRData["rechargeTime"] and self._daySRData["rechargeTime"] > start_time and
        self._daySRData["amount"] and self._daySRData["amount"] >= curData.amount and 
        self._daySRData["rewardTime"] and self._daySRData["rewardTime"] < start_time then
        lingqu = 1
    end

    local proNum = {0, 33, 66, 100}
    local dayNum = self._daySRData["progress"] or 0
    if lingqu == 1 then
        dayNum = self._daySRData["progress"] + 1
    end

    local str = 0 
    if dayNum < 1 then
        str = 0
    elseif dayNum > 4 then
        str = 100
    else
        str = proNum[dayNum]
    end

    local progress = self:getUI("bg.baoxiangBg.progressBg.progress")
    progress:setPercent(str)
end

--宝箱领奖
function AcDayRechargeLayer:getSpecialAcReward(inId)
    if not inId then
        self._viewMgr:showTip("参数有误")
        return
    end

    local param = {acId = 102, args = json.encode({id = inId})}
    self._serverMgr:sendMsg("ActivityServer", "getSpecialAcReward", param, true, {}, function (result)
        if result == nil then
            return
        end

        if result.reward then
            DialogUtils.showGiftGet( {
                gifts = result.reward,
                title = lang("FINISHSTAGETITLE"),
                callback = function()
            end})
        end

        self:reflashUI()
    end)
end

--设置领取按钮
function AcDayRechargeLayer:setRewardBtn()
    local curData = tab:Activity102(self._curIndex)
    local curTime = self._userModel:getCurServerTime()   --当前时间
    local rwdBtn = self:getUI("bg.itemShowBg.rwdBtn")

    if self._daySRData["progress"] and self._daySRData["progress"] >= 5 or 
     self._dayRData.end_time <= curTime or self._dayRData.start_time + 1 > curTime then
        rwdBtn:setSaturation(-100)
        self:registerClickEvent(rwdBtn, function()
            self._viewMgr:showTip("活动结束")
        end)   
        return
    end

    local lingqu = 0
    local lingquflag = 0  
    
    local start_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 05:00:00"))  --当日开启时间
    if curTime < start_time then   --过零点判断
        start_time = start_time - 86400
    end

    local lingqu = 0
    local lingquflag = 0 
    if self._daySRData["rechargeTime"] and self._daySRData["rechargeTime"] > start_time then
        if self._daySRData["amount"] and self._daySRData["amount"] >= curData.amount then
            lingqu = 1
        end

        if self._daySRData["rewardTime"] and self._daySRData["rewardTime"] > start_time then
            lingquflag = 2
            lingqu = 0
        end
    end

    local userlvl = self._userModel:getData().lvl
    local rwdBtn = self:getUI("bg.itemShowBg.rwdBtn")

    if userlvl < 6 then
        self:registerClickEvent(rwdBtn, function()
            self._viewMgr:showTip("达到6级可领取奖励")
        end) 

    elseif lingqu == 1 and lingquflag ~= 2 then
        rwdBtn:setTitleText("领取")
        rwdBtn:setSaturation(0) 
        self._btnAnim:setVisible(true)

        local dayNumData = self._acModel:getACERechargeDay()  --达成天数
        local rewardId
        for i=1, table.nums(dayNumData) do
            if not self._daySRData[tostring(i)] then
                rewardId = i
                break
            end
        end
        self:registerClickEvent(rwdBtn, function()
            self:getSpecialAcReward(rewardId)
        end)  

    elseif lingqu == 0 then
        self._btnAnim:setVisible(false)
        if lingquflag == 2 then
            rwdBtn:setTitleText("已领取")
            rwdBtn:setSaturation(-100)
            self:registerClickEvent(rwdBtn, function()
                self._viewMgr:showTip("你已经领取了奖励")
            end)   
        else
            rwdBtn:setTitleText("领取")
            rwdBtn:setSaturation(0)
            self:registerClickEvent(rwdBtn, function()
                DialogUtils.showNeedCharge({desc = "充值额度不足，请前往充值", callback1=function( )
                    local viewMgr = ViewManager:getInstance()
                    viewMgr:showView("vip.VipView", {viewType = 0})
                end})
            end) 
        end
    else
        self:registerClickEvent(rwdBtn, function()
            self._viewMgr:showTip("")
        end)  
    end
end

--倒计时
function AcDayRechargeLayer:setCountDown()
    local endNum = self:getUI("bg.endBg.endNum")
    local endLab = self:getUI("bg.endBg.endLab")
    
    local rechargeData = self._acModel:getACERechargeShowList() 
    local curTime = self._userModel:getCurServerTime()
    local tempTime = rechargeData.end_time - curTime

    local day, hour, minute, second, tempValue
    self:runAction(cc.RepeatForever:create(
        cc.Sequence:create(cc.CallFunc:create(function()
            tempTime = tempTime - 1
            tempValue = tempTime
            day = math.floor(tempValue/86400) 
            tempValue = tempValue - day*86400
            hour = math.floor(tempValue/3600)
            tempValue = tempValue - hour*3600
            minute = math.floor(tempValue/60)
            tempValue = tempValue - minute*60
            second = math.fmod(tempValue, 60)
            local showTime = string.format("%.2d天%.2d:%.2d:%.2d", day, hour, minute, second)
            if day == 0 then
                showTime = string.format("00天%.2d:%.2d:%.2d", hour, minute, second)
            end
            if tempTime <= 0 then
                showTime = "00天00:00:00"
            end
            endNum:setString(showTime)
            endNum:setPositionX(endLab:getPositionX() + endLab:getContentSize().width + 5)
        end),cc.DelayTime:create(1))
    ))
end

return AcDayRechargeLayer