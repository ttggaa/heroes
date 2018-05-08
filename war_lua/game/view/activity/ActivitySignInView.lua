--[[
    Filename:    ActivitySignInView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-02-02 19:23:39
    Description: File description
--]]

local cc = cc
local ActivitySignInView = class("ActivitySignInView", BasePopView)

function ActivitySignInView:ctor(data)
    ActivitySignInView.super.ctor(self)
    self._itemCell = {}
    self._callback = data.callback
    self._labIndex = {}
end

function ActivitySignInView:onInit()
    self._monthDays = 1
    self._first = true

    self._signModel = self._modelMgr:getModel("SignModel")
    self._signModel:setSignDateTip() 
    self:registerClickEventByName("bg.closeBtn", function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("activity.ActivitySignInView")
        end
        if self._callback then
            self._callback()
        end
        self:close()
    end)

    self._des1 = self:getUI("bg.possess.timesNumBg.des1")
    self._des2 = self:getUI("bg.possess.timesNumBg.des2")
    self._des3 = self:getUI("bg.possess.timesNumBg.des3")
    self._num1 = self:getUI("bg.possess.timesNumBg.num1")
    self._num2 = self:getUI("bg.possess.timesNumBg.num2")
    self._buqianNum = self:getUI("bg.bg.buqianNum")

 
    self._des1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._des2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._des3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._num1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._num2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    -- 左侧英雄立汇
    self:setHeroLiHui()

    -- -- 背景
    -- local bg = self:getUI("bg")
    -- bg:loadTexture("asset/bg/bg_sign.png")

    for i=1,5 do
        local dayNum = self:getUI("bg.possess.dayNumBg" .. i .. ".dayNum")
        dayNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end

    self._scrollView = self:getUI("bg.scrollView")
    self._scrollView:setBounceEnabled(true)

    self._guize = self:getUI("bg.possess.guize")
    self._tishi = self:getUI("bg.possess.tishi")
    -- self._tishi:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._dajiang = self:getUI("bg.possess.dajiang")

    self._possess = self:getUI("bg.possess")

    self._month = self:getUI("bg.month")
    self._month:setColor(cc.c3b(255, 253, 253))
    self._month:enable2Color(1, cc.c4b(253, 229, 175, 255))

    local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    self._lastTime = tonumber(TimeUtils.getDateString(curServerTime,"%Y%m%d") .. "05")
    
    self:listenReflash("VipModel", self.reflashSign)
    self:listenReflash("SignModel", self.reflashSign)
    self._userModel = self._modelMgr:getModel("UserModel")
    self._userLvl = self._userModel:getPlayerLevel()
    self:listenReflash("UserModel", self.levelUpNeedClose)

    self._updateMonth = false
    -- self._createCell = false

    self:registerClickEvent(self._guize, function()
        local signData = self._signModel:getData()
        dump(signData, "signData============")
     
        local str = lang("signrule")
        self._viewMgr:showDialog("activity.ActivitySignDescDialog", {str = str})
    end)

    local txt = self:getUI("bg.possess.qipao.txt")    
    txt:setColor(cc.c3b(255,248,192))
    txt:enable2Color(1, cc.c4b(255, 197, 20, 255))
    txt:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    local txt = self:getUI("bg.possess.dayNumBg5.dayNum")
    txt:setColor(cc.c3b(255,215,251))
    txt:enable2Color(1, cc.c4b(255, 8, 246, 255))
    txt:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self._qipao = self:getUI("bg.possess.qipao")    
    local seq = cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(0, 5)), cc.MoveBy:create(0.5, cc.p(0, -5)))
    self._qipao:runAction(cc.RepeatForever:create(seq))

    self:setTencent()
end

--关闭当前界面
function ActivitySignInView:levelUpNeedClose()
    -- 如果等级没有发生变化 不作处理  
    local userLvl = self._userModel:getPlayerLevel()
    if self._userLvl >= userLvl then
        return
    end
    
    local lvData = tab.userLevel[userLvl]
    local gotoview = 0
    if lvData then
        gotoview = lvData["gotoview"] or 0
    end
    -- 升级 & 返回主界面
    if 1 == gotoview then  
        if self._callback then
            self._callback()
        end
        self:close()
    end
end

function ActivitySignInView:reflashSign()
    self:reflashUI()
    self:scrollToNext()
end

function ActivitySignInView:scrollToNext()
    local scrollView = self:getUI("bg.scrollView")
    local innerScroll = scrollView:getInnerContainer()
    innerScroll:stopAllActions()
    local posY = 345 - innerScroll:getContentSize().height  -- -318
    if self._monthDays > 20 and self._monthDays <= 30 then
        posY = posY + 318
    elseif self._monthDays > 15 and self._monthDays <= 20 then
        posY = posY + 212
    elseif self._monthDays > 30 then
        posY = 0
    end
    innerScroll:runAction(cc.MoveTo:create(0.2, cc.p(0, posY)))

    -- local posY = -104
    -- if self._monthDays > 15 and self._monthDays <= 30 then
    --     posY = 220
    -- elseif self._monthDays > 30 then
    --     posY = 320
    -- end
    -- print("posY============",posY, self._monthDays)
    -- local seq = cc.Sequence:create(cc.DelayTime:create(0.5), cc.MoveTo:create(0.2, cc.p(0, posY)))
    -- innerScroll:runAction(seq)
    -- innerScroll:setPositionY(posY)
end

-- 设置累计签到数据
function ActivitySignInView:setPossess()
    local signData = self._modelMgr:getModel("SignModel"):getData()
    -- local num1 = self:getUI("bg.Image_12.num1")
    -- num1:setString(signData.day)
    -- dump(signData, "signData ===", 10)
    --     local signData = {}

    -- signData["day"]          = 19
    -- signData["resetTime"]    = 1485926094
    -- signData["signTime"]     = 1487481269
    -- signData["totalSign"]    = 19
    -- signData["totalSignGot"] = {
    -- }
    -- signData["vipReward"] = {
    -- }

    local tMonth, monthNum = self:getTodayMonth()
    local day, lackNum = self:getLackDayNum()
    local tSignNum = (day-lackNum)
    print("==========", day, lackNum)
    if tSignNum < 0 then
        tSignNum = 0
    end
    self._num1:setString(tSignNum .. "/" .. monthNum)
    self._num2:setString(lackNum)
    -- self._num2:setVisible(true)
    -- self._des2:setVisible(true)
    if lackNum <= 0 then
        -- self._des2:setString("次")
        self._buqianNum:setVisible(false)
        -- self._des3:setVisible(false)
    else
        -- self._des2:setString("次，缺勤")
        self._buqianNum:setVisible(true)
        -- self._des3:setVisible(true)
    end
    self._buqianNum:setString("补签机会: " .. signData.rNum .. "次")
    local showbuqian = self:isMonthBuqian()
    if showbuqian == false then
        self._buqianNum:setVisible(false)
    else
        self._buqianNum:setVisible(true)
    end

    -- local playerInfo = self._modelMgr:getModel("PlayerTodayModel"):getData()
    -- if playerInfo["day43"] == 1 or lackNum == 0 then
    --     -- self._tishi:setVisible(false)
    --     -- self._goChongzhi:setVisible(false)
    --     -- self._dajiang:setVisible(true)
    -- else
    --     -- self._tishi:setVisible(true)
    --     -- self._goChongzhi:setVisible(true)
    --     -- self._dajiang:setVisible(false)
    -- end

    self._num1:setPositionX(self._des1:getPositionX()+self._des1:getContentSize().width)
    -- self._des2:setPositionX(self._num1:getPositionX()+self._num1:getContentSize().width)
    self._num2:setPositionX(self._des2:getPositionX()+self._des2:getContentSize().width)
    -- self._des3:setPositionX(self._num2:getPositionX()+self._num2:getContentSize().width)


    local countTab = {}
    for i=1,5 do
        local dayNumBg = self:getUI("bg.possess.dayNumBg" .. i)
        local dayNum = self:getUI("bg.possess.dayNumBg" .. i .. ".dayNum")
        local awardBtn = self:getUI("bg.possess.dayNumBg" .. i .. ".award")
        local yiling = self:getUI("bg.possess.dayNumBg" .. i .. ".yiling")
        local zhehei = self:getUI("bg.possess.dayNumBg" .. i .. ".zhehei")
        awardBtn:setVisible(true)
        if yiling then
            yiling:setVisible(false)
        end
        if zhehei then
            zhehei:setVisible(false)
        end
        
        local indexId = tMonth .. "0" .. i

        -- print("indexId=========", indexId)
        local signCountTab = tab:SignCount(tonumber(indexId))
        if not signCountTab then
            self._viewMgr:showTip("暂无签到数据" .. tMonth .. "，请联系管理员")
            return
        end
        countTab[i] = signCountTab.count
        dayNum:setString(signCountTab.count .. "天")
        if i == 5 then
            dayNum:setString("全勤")
        end
        if not signData.totalSignGot[tostring(i)] then
            if i == 5 then
                local openAward = self:getUI("bg.possess.dayNumBg5.openAward")
                openAward:setVisible(false)

                -- local rewardMc = awardBtn:getChildByName("rewardMc")
                -- if not rewardMc then
                --     rewardMc = mcMgr:createViewMC("baoxiang3_baoxiang", true, false)
                --     rewardMc:gotoAndStop(1)
                --     awardBtn:addChild(rewardMc, 100)
                --     rewardMc:setPosition(awardBtn:getContentSize().width*0.5, awardBtn:getContentSize().height*0.5)
                --     rewardMc:setName("rewardMc")
                -- end

                local baoxiangguang = awardBtn:getChildByName("baoxiangguang")
                if not baoxiangguang then
                    baoxiangguang = mcMgr:createViewMC("baoxiangguang1_baoxiang", true, false)
                    baoxiangguang:setVisible(false)
                    awardBtn:addChild(baoxiangguang, 100)
                    baoxiangguang:setPosition(awardBtn:getContentSize().width*0.5-3, awardBtn:getContentSize().height*0.5+5)
                    baoxiangguang:setName("baoxiangguang")
                end


                if (day-lackNum) >= signCountTab.count then
                    -- rewardMc:gotoAndPlay(1)
                    baoxiangguang:setVisible(true)
                end
            else
                local award = signCountTab.content[1]
                local awardIcon = awardBtn:getChildByName("awardIcon")
                local num = award[3]
                local itemId = award[2]
                if award[1] == "hero" then
                    local sysHeroData = tab:Hero(itemId)
                    local param = {sysHeroData = sysHeroData, effect = false}
                    if (day-lackNum) >= signCountTab.count then
                        param = {sysHeroData = sysHeroData, effect = false}
                    end
                    if awardIcon then
                        IconUtils:updateHeroIconByView(awardIcon, param)
                        awardIcon:getChildByName("starBg"):setVisible(false)
                        awardIcon:getChildByName("iconStar"):setVisible(false)
                    else
                        awardIcon = IconUtils:createHeroIconById(param)
                        awardIcon:setName("awardIcon")
                        awardIcon:setAnchorPoint(0.5,0.5)
                        awardIcon:setScale(0.66)
                        awardIcon:setPosition(34,40)
                        awardBtn:addChild(awardIcon)
                        awardIcon:getChildByName("starBg"):setVisible(false)
                        awardIcon:getChildByName("iconStar"):setVisible(false)
                    end
                else
                    if award[1] == "tool" then
                        itemId = award[2]
                    else
                        itemId = IconUtils.iconIdMap[award[1]]
                    end
                    local param = {itemId = itemId, num = num,effect = true,eventStyle = 4, swallowTouches = true}
                    if (day-lackNum) >= signCountTab.count then
                        param = {itemId = itemId, num = num,effect = false,eventStyle = 4, swallowTouches = true}
                    end
                    if awardIcon then
                        IconUtils:updateItemIconByView(awardIcon, param)
                    else
                        awardIcon = IconUtils:createItemIconById(param)
                        awardIcon:setName("awardIcon")
                        awardIcon:setScale(0.74)
                        awardIcon:setPosition(0,6)
                        awardBtn:addChild(awardIcon)
                    end
                end
                awardIcon:setSwallowTouches(false)
            end

            -- awardBtn.bgMc = awardBtn:getChildByName("bgMc")
            if not awardBtn.bgMc then
                awardBtn.bgMc = mcMgr:createViewMC("huodewupindiguang_itemeffectcollection", true, false, nil, RGBA8888)
                awardBtn.bgMc:setPosition(cc.p(awardBtn:getContentSize().width/2,awardBtn:getContentSize().height/2+3))
                awardBtn.bgMc:setScale(0.9)
                awardBtn.bgMc:setName("bgMc")
                awardBtn:addChild(awardBtn.bgMc,-1)
            else
                
            end
            if (day-lackNum) >= signCountTab.count then
                awardBtn.bgMc:setVisible(true)
            else
                awardBtn.bgMc:setVisible(false)
            end
            awardBtn:setAnchorPoint(0.5, 0.5)
            awardBtn:setScaleAnim(true)
            self:registerClickEvent(awardBtn, function()
                -- print("day =====", day, lackNum, signCountTab.count)
                if (day-lackNum) >= signCountTab.count then
                     print("领取累签奖励", i)
                     self:getTotalSignReward(i)
                elseif i == 5 then
                    self._viewMgr:showTip("继续签到，全勤大奖就在眼前哦~")
                else
                    if signCountTab.content[1][1] == "hero" then
                        local heroId = signCountTab.content[1][2] or 60001
                        local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                        self._viewMgr:showDialog("formation.NewFormationDescriptionView", {iconType = NewFormationIconView.kIconTypeLocalHero, iconId = heroId}, true)
                    end
                end
            end)
        elseif signData.totalSignGot[tostring(i)] and signData.totalSignGot[tostring(i)] == 1 then
            if yiling then
                yiling:setVisible(true)
            end
            if zhehei then
                zhehei:setVisible(true)
            end
            if i == 5 then
                local openAward = self:getUI("bg.possess.dayNumBg5.openAward")
                openAward:setVisible(true)
                awardBtn:setVisible(false)
            else
                local award = signCountTab.content[1]
                local awardIcon = awardBtn:getChildByName("awardIcon")
                local num = award[3]
                local itemId = award[2]
                if award[1] == "hero" then
                    local sysHeroData = tab:Hero(itemId)
                    if awardIcon then
                        IconUtils:updateHeroIconByView(awardIcon, {sysHeroData = sysHeroData, effect = false})
                        awardIcon:getChildByName("starBg"):setVisible(false)
                        awardIcon:getChildByName("iconStar"):setVisible(false)
                    else
                        awardIcon = IconUtils:createHeroIconById({sysHeroData = sysHeroData, effect = false})
                        awardIcon:setName("awardIcon")
                        awardIcon:setAnchorPoint(0.5,0.5)
                        awardIcon:setScale(0.66)
                        awardIcon:setPosition(34,40)
                        awardBtn:addChild(awardIcon)
                        awardIcon:getChildByName("starBg"):setVisible(false)
                        awardIcon:getChildByName("iconStar"):setVisible(false)
                    end
                else
                    if award[1] == "tool" then
                        itemId = award[2]
                    else
                        itemId = IconUtils.iconIdMap[award[1]]
                    end
                    if awardIcon then
                        IconUtils:updateItemIconByView(awardIcon, {itemId = itemId, num = num,effect = true,eventStyle = 5, swallowTouches = true})
                    else
                        awardIcon = IconUtils:createItemIconById({itemId = itemId, num = num,effect = true,eventStyle = 5, swallowTouches = true})
                        awardIcon:setName("awardIcon")
                        awardIcon:setScale(0.74)
                        awardIcon:setPosition(0,6)
                        awardBtn:addChild(awardIcon)
                    end
                end
                awardIcon:setSwallowTouches(false)
            end
            if awardBtn.bgMc then
                awardBtn.bgMc:setVisible(false)
            end
            self:registerClickEvent(awardBtn, function()
            end)
        end
    end

    if signData.totalSignGot[tostring(5)] and signData.totalSignGot[tostring(5)] == 1 then
        self._qipao:setVisible(false)
    else
        self._qipao:setVisible(true)
    end
                
    self._progessBar = self:getUI("bg.possess.progessBg.progessBar")

    local signPT = {}
    local tempvalue = 25/(countTab[5]-20)
    for i=1,countTab[5] do
        local value = 0
        if i <= countTab[1] then
            value = 3*i
        elseif i <= countTab[2] then
            value = 9+7*(i-3)
        elseif i <= countTab[3] then
            value = 30+5*(i-6)
        elseif i <= countTab[4] then
            value = 50+2.5*(i-10)
        else
            value = 75+tempvalue*(i-20)
        end
        signPT[i] = value 
    end
    local signDayP = (day-lackNum)
    local value = 0
    if signDayP and signDayP >= 0 then
        value = signPT[signDayP] or 0
    end
    value = value * 0.01
    self._progessBar:setScaleX(value)
end

function ActivitySignInView:reflashUI()
    local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local dayHour = tonumber(TimeUtils.getDateString(curServerTime,"%d%H"))
    -- self._todayDate = tonumber(TimeUtils.getDateString(curServerTime,"%Y%m%d%H"))
    self._yearMonth = tonumber(TimeUtils.getDateString(curServerTime,"%Y%m"))
    self._dayNum = tonumber(TimeUtils.getDaysOfMonth(curServerTime))
    self._todayTime = tonumber(TimeUtils.getDateString(curServerTime,"%Y%m%d%H"))
    -- if self._lastMonth ~= self._yearMonth then
    if self._lastTime ~= self._todayTime then
        self._updateMonth = false
    end
 
    -- if self._first == false then
    --     self:setPossess()
    --     -- self:getSignInfo()
    -- end

    if self._updateMonth == false then
        local tempMonth = TimeUtils.getDateString(curServerTime,"%m")
        if dayHour == 105 then
            local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
            local minTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:01"))
            self._month:setString(tonumber(tempMonth))
            self:setHeroLiHui()
            -- self._month:loadTexture("activitySignImg_num" .. tonumber(tempMonth) .. ".png",1)
            if curServerTime >= minTime then
                self._lastTime = self._todayTime
                self._first = false
                self._signModel:initSignData()
                self:getSignInfo()
            end
        elseif dayHour <= 105 then
            self._dayNum = tonumber(TimeUtils.getDaysOfMonth(curServerTime - 86400))
            self._yearMonth = tonumber(TimeUtils.getDateString(curServerTime - 86400,"%Y%m")) 
            self._lastTime = self._dayNum
            tempMonth = TimeUtils.getDateString(curServerTime - 86400,"%m")
            self._month:setString(tonumber(tempMonth))
            -- self._month:loadTexture("activitySignImg_num" .. tonumber(tempMonth - 1) .. ".png",1)
        else
            self._month:setString(tonumber(tempMonth))
            -- self._month:loadTexture("activitySignImg_num" .. tonumber(tempMonth) .. ".png",1)
        end
        self:createSignInCell()
        self._updateMonth = true
    end

    -- if self._createCell == false then
    --     self:createSignInCell()
    --     self._createCell = true
    -- end

    local line = 6
    if tonumber(self._dayNum) > 30 then
        line = 7
    end
    local itemBg = self:getUI("itemBg")
    local maxHeight = (105 + 3) * line  + 10
    self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, maxHeight))


    local signModel = self._modelMgr:getModel("SignModel")
    local signData = signModel:getData()
    if not signData.signTime then
        signModel:setData()
        signData = signModel:getData()
    end

    local state, monthDays, isRet = self:getSignState()
    self._monthDays = monthDays
    self._signState = state
    self._isRet = isRet

    local state1, monthDays1, isRet1 = self:getSignState2()
    if state ~= 1 then
        self._monthDays1 = monthDays1
    else
        self._monthDays1 = monthDays1 - 1
    end

    self._signState1 = state1
    self._isRet1 = isRet1
    -- print("pppp=================", state, monthDays, isRet)

    local day = tonumber(string.format("%s%.2d", self._yearMonth,1))
    -- print("========", day)
    local tabSign = tab:Sign(tonumber(day))
    if tabSign == nil then 
        self._scrollView:removeAllChildren()
        self._viewMgr:showTip("暂无签到数据，请联系管理员")
    else
        local flag = false
        for i=1,31 do
            -- if i <= self._dayNum then
            if math.fmod(i, 5) == 0 then
                flag = true
            end
            self:updateSignInCell(i, flag)
            flag = false
            -- end
        end
    end

    self:setPossess()
end

function ActivitySignInView:onShow()
    self:scrollToNext()
end

-- 更新签到状态
function ActivitySignInView:updateSignIn()
    local oldindex = self._monthDays
    local oldindex1 = self._monthDays1

    local state, monthDays, isRet = self:getSignState()
    self._monthDays = monthDays
    self._signState = state
    self._isRet = isRet

    local state1, monthDays1, isRet1 = self:getSignState2()
    self._monthDays1 = monthDays1
    self._signState1 = state1
    self._isRet1 = isRet1

    local monthFunc = function(monthDay)
        local flag = true
        if math.fmod(monthDay, 5) == 0 then
            flag = true
        end
        self:updateSignInCell(monthDay, flag)
    end

    -- print("oldindex=====", oldindex, self._monthDays)
    -- print("oldindex1=====", oldindex1, self._monthDays1)

    if oldindex == self._monthDays then
        monthFunc(oldindex)
    else
        monthFunc(oldindex)
        monthFunc(self._monthDays)
    end
    monthFunc(self._monthDays1)

    -- if oldindex1 == self._monthDays1 then
    --     monthFunc(oldindex1)
    -- else
    --     monthFunc(oldindex1)
    -- end

    -- if oldindex == self._monthDays then
    --     local flag = true
    --     if math.fmod(oldindex, 5) == 0 then
    --         flag = true
    --     end
    --     self:updateSignInCell(oldindex, flag)
    -- else
    --     local flag = true
    --     if math.fmod(oldindex, 5) == 0 then
    --         flag = true
    --     end
    --     self:updateSignInCell(oldindex, flag)

    --     if math.fmod(self._monthDays, 5) == 0 then
    --         flag = true
    --     end
    --     self:updateSignInCell(self._monthDays, flag)
    -- end

    self:setPossess()
end 

function ActivitySignInView:setItemVisible(inView, flag)
    if inView then
        if flag == true then
            inView.vipValue:setVisible(true)
            inView.labBg:setVisible(true)
            inView.signBg:setVisible(true)
            inView.itemBg:setVisible(true)
            inView.carryRewardIcon:setVisible(true)
            inView.rewardIconBg:setVisible(true)
            inView.rewardIcon:setVisible(true)
        else
            inView.vipValue:setVisible(false)
            inView.labBg:setVisible(false)
            inView.signBg:setVisible(false)
            inView.itemBg:setVisible(false)
            inView.carryRewardIcon:setVisible(false)
            inView.rewardIconBg:setVisible(false)
            inView.rewardIcon:setVisible(false)
        end
    end
end

function ActivitySignInView:updateSignInCell(index, heroSao)
    -- self._vipDouble = false
    local saoguang = false
    local kelingqu = false
    local itemCell = self._itemCell[index]
    local day = tonumber(string.format("%s%.2d", self._yearMonth,index))
    local tabSign = tab:Sign(tonumber(day))

    local maxSignNum = self._monthDays
    if self._monthDays1 > self._monthDays then
        maxSignNum = self._monthDays1
    end
    -- print("======", self._monthDays, self._monthDays1, maxSignNum, index)
    if maxSignNum < index and heroSao == true then
        saoguang = true
    end
    if not itemCell then
        return
    elseif index > self._dayNum and itemCell then
        -- itemCell:setVisible(false)
        self:setItemVisible(itemCell, false)
        return
    elseif index > self._dayNum then
        return
    end

    local imgId = math.fmod(index, 15)
    if imgId == 0 then
        imgId = 15
    end
    local signBgImg = "activityPanel_bg1.png"
    local kelingquImg = "activityPanel_kelingqu.png"
    local signData = self._modelMgr:getModel("SignModel"):getData()

    local itemId = 0
    if tabSign.reward[1] == "hero" then
        -- itemId = tabSign.reward[2]
        -- itemCell.itemIcon = itemCell.itemBg:getChildByName("itemIcon")
        -- local sysHeroData = tab:Hero(itemId)
        -- if itemCell.itemIcon then
        --     IconUtils:updateHeroIconByView(itemCell.itemIcon, {sysHeroData = sysHeroData})
        -- else
        --     itemCell.itemIcon =IconUtils:createHeroIconById({sysHeroData = sysHeroData})
        --     itemCell.itemIcon:setName("itemIcon")
        --     itemCell.itemIcon:setAnchorPoint(cc.p(0,0))
        --     itemCell.itemIcon:setScale(0.8)
        --     itemCell.itemIcon:setPosition(cc.p(-10,-8))
        --     itemCell.itemBg:addChild(itemCell.itemIcon)
        --     itemCell.itemIcon:getChildByName("starBg"):setVisible(false)
        --     -- itemCell.itemIcon:getChildByName("star1"):setVisible(false)
        --     -- for i=1,6 do
        --     --     if itemCell.itemIcon:getChildByName("star" .. i) then
        --     --         itemCell.itemIcon:getChildByName("star" .. i):setPositionY(itemCell.itemIcon:getChildByName("star" .. i):getPositionY() + 5)
        --     --     end
        --     -- end
        -- end
    else
        local num = tabSign.reward[3]
        if tabSign.reward[1] == "gold" then
            itemId = IconUtils.iconIdMap.gold
        elseif tabSign.reward[1] == "gem" then
            itemId = IconUtils.iconIdMap.gem 
        else -- if tabSign.reward[1] == "tool" then
            itemId = tabSign.reward[2]
        end

        -- itemCell.itemIcon = itemCell.itemBg:getChildByName("itemIcon")
        if itemCell.itemIcon then
            IconUtils:updateItemIconByView(itemCell.itemIcon, {itemId = itemId, num = num,effect = true,eventStyle = 1, swallowTouches = true})
        else
            itemCell.itemIcon = IconUtils:createItemIconById({itemId = itemId, num = num,effect = true,eventStyle = 1, swallowTouches = true})
            itemCell.itemIcon:setName("itemIcon")
            itemCell.itemIcon:setAnchorPoint(0,0)
            itemCell.itemIcon:setScale(0.8)
            
            itemCell.itemIcon:setPosition(-4,-2)
            itemCell.itemBg:addChild(itemCell.itemIcon)
            
            -- itemCell.itemIcon:setPosition(cc.p(itemCell.itemBg.posX-42,itemCell.itemBg.posY-45))
            -- self._scrollView:addChild(itemCell.itemIcon, 5)
        end
    end

    local signFunc = function(signSd, teflag, itemCell)
        print("====signSdself._signState=======", signSd)
        if signSd == 1 then
            itemCell.rewardIconBg:setVisible(false)
            itemCell.rewardIcon:setVisible(false)
            itemCell.carryRewardIcon:setVisible(false)
            itemCell.signBg:loadTexture(kelingquImg, 1)
            kelingqu = true
            local viplevel = self._modelMgr:getModel("VipModel"):getData().level
            local vipDouble = false
            if tabSign.vip then
                if viplevel >= tabSign.vip then
                    vipDouble = true
                end
            end
            -- local vip = signData.vipReward[tostring(index)]
            self:registerClickEvent(itemCell.itemIcon, function()
                -- print("qiandaoqiandao=============", vipDouble)
                self:signIn(teflag, vipDouble)
            end) 
            if teflag == true then
                itemCell.rewardIcon:setScale(1)
                itemCell.rewardIcon:setVisible(true)
                itemCell.rewardIcon:setSpriteFrame("activityPanel_kebuqian.png")
                itemCell.rewardIcon:stopAllActions()
                local seq = cc.Sequence:create(cc.ScaleTo:create(0.3, 1.1), cc.ScaleTo:create(0.3, 0.9))
                itemCell.rewardIcon:runAction(cc.RepeatForever:create(seq))
            end
        elseif signSd == 2 then
            -- print(" 还可以 ====签到",index)
            self:registerClickEvent(itemCell.itemIcon, function()
                -- print(" 还可以 ====签到",index)
                self:signIn(teflag)
            end) 
            kelingqu = true
            itemCell.signBg:loadTexture(kelingquImg, 1)
            itemCell.rewardIconBg:setVisible(false)
            itemCell.rewardIcon:setVisible(false)
            itemCell.carryRewardIcon:setVisible(true)
            if teflag == true then
                itemCell.rewardIcon:setScale(1)
                itemCell.rewardIcon:setVisible(true)
                itemCell.rewardIcon:setSpriteFrame("activityPanel_kebuqian.png")
                itemCell.rewardIcon:stopAllActions()
                local seq = cc.Sequence:create(cc.ScaleTo:create(0.3, 1.1), cc.ScaleTo:create(0.3, 0.9))
                itemCell.rewardIcon:runAction(cc.RepeatForever:create(seq))
            end
        elseif signSd == 3 then
            self:registerClickEvent(itemCell.itemIcon, function()
                DialogUtils.showNeedCharge({desc = "VIP等级不足，是否前去充值",callback1=function( )
                    -- print("充值去！")
                    local viewMgr = ViewManager:getInstance()
                    viewMgr:showView("vip.VipView", {viewType = 0})
                end})
            end) 
            kelingqu = true
            itemCell.signBg:loadTexture(kelingquImg, 1)
            itemCell.rewardIconBg:setVisible(false)
            itemCell.rewardIcon:setVisible(false)
            itemCell.carryRewardIcon:setVisible(true)
        elseif signSd == 4 then
            self:registerClickEvent(itemCell.itemIcon, function()
                self:getBuqianDialog()
            end) 
            kelingqu = false
            itemCell.signBg:loadTexture(kelingquImg, 1)
            itemCell.rewardIconBg:setVisible(false)
            itemCell.rewardIcon:setScale(1)
            itemCell.rewardIcon:setVisible(true)
            itemCell.rewardIcon:setSpriteFrame("activityPanel_kebuqian.png")
            itemCell.rewardIcon:stopAllActions()
            local seq = cc.Sequence:create(cc.ScaleTo:create(0.3, 1.1), cc.ScaleTo:create(0.3, 0.9))
            itemCell.rewardIcon:runAction(cc.RepeatForever:create(seq))
            itemCell.carryRewardIcon:setVisible(false)
        elseif signSd == 5 then
            itemCell.rewardIconBg:setVisible(false)
            itemCell.rewardIcon:stopAllActions()
            itemCell.rewardIcon:setVisible(false)
            itemCell.rewardIcon:setScale(1)
            itemCell.rewardIcon:setSpriteFrame("activityPanel_yiqiandao.png")
            itemCell.carryRewardIcon:setVisible(false)
            -- itemCell:setEnabled(false)
            itemCell.signBg:loadTexture(signBgImg, 1)
            kelingqu = false
            if heroSao == true then
                saoguang = true
            end
            -- print("今日签到已领完")
        elseif signSd == 0 then
            itemCell.rewardIconBg:setVisible(true)
            itemCell.rewardIcon:stopAllActions()
            itemCell.rewardIcon:setVisible(true)
            itemCell.rewardIcon:setScale(1)
            itemCell.rewardIcon:setSpriteFrame("activityPanel_yiqiandao.png")
            itemCell.carryRewardIcon:setVisible(false)
            -- itemCell:setEnabled(false)
            itemCell.signBg:loadTexture(signBgImg, 1)
            kelingqu = false
        end
    end

    -- print("====signSdnState=======", self._signState, self._signState1)

    if self._monthDays == index then
        signFunc(self._signState, false, itemCell)
    elseif self._monthDays1 == index and self._isRet ~= 3 then
        signFunc(self._signState1, true, itemCell)
    elseif self._monthDays > index then
        kelingqu = false
        itemCell.signBg:loadTexture(signBgImg, 1)
        itemCell.rewardIcon:setSpriteFrame("activityPanel_yiqiandao.png")
        itemCell.rewardIcon:stopAllActions()
        itemCell.rewardIcon:setScale(1)
        itemCell.rewardIcon:setVisible(true)
        itemCell.rewardIconBg:setVisible(true)
        itemCell.carryRewardIcon:setVisible(false)
    else -- if heroSao == true then
        kelingqu = false
        itemCell.signBg:loadTexture(signBgImg, 1)
        itemCell.rewardIconBg:setVisible(false)
        itemCell.rewardIcon:setVisible(false)
        itemCell.carryRewardIcon:setVisible(false)
    end

    if tabSign.vip then
        itemCell.labBg:setVisible(true)
        -- itemCell.vipLab:setVisible(true)
        itemCell.vipValue:setVisible(true)
        -- itemCell.double:setVisible(true)
        self._labIndex[index] = true
        itemCell.vipValue:setString( "V" .. tabSign.vip)
    end


    itemCell.itemIcon:setSwallowTouches(true)
    -- itemCell.itemEffect = itemCell.itemBg:getChildByName("itemEffect")
    -- itemCell.spLight = itemCell.itemBg:getChildByName("spLight")
    -- print("saoguang==========", saoguang)
    if saoguang == true then
        if itemCell.spLight then
            itemCell.spLight:setVisible(true)
        else
            itemCell.spLight = mcMgr:createViewMC("diguang_itemeffectcollection", true, false, nil, RGBA8888)
            itemCell.spLight:setName("spLight")
            itemCell.spLight:setScale(0.8)
            itemCell.spLight:setPosition(itemCell.itemBg.posX-5, itemCell.itemBg.posY)
            self._scrollView:addChild(itemCell.spLight, 2)
            itemCell.spLight:setVisible(true)
        end

        if itemCell.itemEffect then
            itemCell.itemEffect:setVisible(true)
        else
            itemCell.itemEffect = IconUtils:addEffectByName({"tongyongdibansaoguang_itemeffectcollection"},itemCell.itemIcon)
            itemCell.itemEffect:setName("itemEffect")
            itemCell.itemEffect:setScale(0.8)
            itemCell.itemEffect:setPosition(itemCell.itemBg.posX-38, itemCell.itemBg.posY-38)
            -- itemCell.itemEffect:setPlaySpeed(1)
            itemCell.itemEffect:setVisible(true)
            self._scrollView:addChild(itemCell.itemEffect,8)
        end
        local heroId = tabSign.reward[2]
        if heroId > 300000 then
            heroId = heroId -300000
        end
        registerClickEvent(itemCell.itemIcon, function()
            local NewFormationIconView = require "game.view.formation.NewFormationIconView"
            local tempHeroId = heroId or 60001
            self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = tempHeroId}, true)
        end)
        itemCell.itemIcon:setSwallowTouches(true)
    else
        if itemCell.itemEffect then
            itemCell.itemEffect:setVisible(false)
        end
        if itemCell.spLight then
            itemCell.spLight:setVisible(false)
        end
        itemCell.itemIcon:setSwallowTouches(true)
    end

    -- itemCell.kelingqu = itemCell.itemBg:getChildByName("kelingqu")
    if kelingqu == true then
        if itemCell.kelingqu then
            itemCell.kelingqu:setVisible(true)
        else
            -- 替换新动画 hgf
            itemCell.kelingqu = ccui.Layout:create()  
            itemCell.kelingqu:setContentSize(88,88)
            itemCell.kelingqu:setName("kelingqu")
            -- itemCell.kelingqu:setBackGroundColorOpacity(128)
            -- itemCell.kelingqu:setBackGroundColorType(1)
            itemCell.kelingqu:setScale(0.9)        
            itemCell.kelingqu:setPosition(-3, 0)
            itemCell.itemBg:addChild(itemCell.kelingqu)

            -- local mc1 = mcMgr:createViewMC("wupinguang_itemeffectcollection", true, false)
            local mc1 = IconUtils:addEffectByName({"wupinguang_itemeffectcollection"},itemCell.kelingqu)
            mc1:setScale(0.9)
            itemCell.kelingqu:addChild(mc1)
            -- local mc2 = mcMgr:createViewMC("wupinkuangxingxing_itemeffectcollection", true, false)
            -- mc2:setScale(0.9)
            -- itemCell.kelingqu:addChild(mc2)
        end
    else
        if itemCell.kelingqu then
            itemCell.kelingqu:setVisible(false)
        end
    end
end

function ActivitySignInView:createSignInCell()
    local itemBg = self:getUI("itemBg")
    itemBg:setVisible(false)

    local itemBgWidth = 104
    local itemBgHeight = 105
    local line = 6
    if tonumber(self._dayNum) > 30 then
        line = 7
    end
    -- print("=_dayNum===========", self._dayNum)
    local maxHeight = (itemBgHeight + 3) * line + 10
    -- self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, maxHeight))
    -- local maxHeight = (self._peerageCell:getContentSize().height + 8) * 10
    -- self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, maxHeight))
    local w, h, row
    row = 0
    w = 3
    h = maxHeight - itemBgHeight + 48
    
    self._scrollView:removeAllChildren()
    for i=1,31 do
        self._itemCell[i] = {}
        w = (itemBgWidth + 3) * row + 50

        -- self._itemCell[i] = itemBg:clone()
        -- self._itemCell[i]:setName("itemCell" .. i)
        -- self._itemCell[i]:setVisible(true)
        -- self._scrollView:addChild(self._itemCell[i])
        -- self._itemCell[i]:setPosition(cc.p(w, h))

        self._itemCell[i].vipValue = cc.Label:createWithTTF(i, UIUtils.ttfName, 18)
        -- self._itemCell[i].vipValue:setColor(cc.c3b(255,255,255))
        self._itemCell[i].vipValue:setVisible(false)
        self._itemCell[i].vipValue:setRotation(41)
        self._itemCell[i].vipValue:setPosition(w+11, h+45)
        self._itemCell[i].vipValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        self._scrollView:addChild(self._itemCell[i].vipValue, 22)

        self._itemCell[i].labBg = cc.Sprite:createWithSpriteFrameName("activityPanel_biaoqian.png")
        self._itemCell[i].labBg:setVisible(false)
        self._itemCell[i].labBg:setPosition(w+18, h+23)
        self._scrollView:addChild(self._itemCell[i].labBg, 21)

        self._itemCell[i].signBg = ccui.ImageView:create() -- cc.Sprite:createWithSpriteFrameName(signBgImg)
        local imgId = math.fmod(i, 15)
        if imgId == 0 then
            imgId = 15
        end
        local signBgImg = "activityPanel_bg1.png"
        self._itemCell[i].signBg:loadTexture(signBgImg, 1)
        self._itemCell[i].signBg:setVisible(true)
        self._itemCell[i].signBg:setPosition(w, h)
        self._scrollView:addChild(self._itemCell[i].signBg, 2)

        self._itemCell[i].itemBg = ccui.Layout:create()
        self._itemCell[i].itemBg:setAnchorPoint(0.5, 0.5)
        self._itemCell[i].itemBg:setBackGroundColorOpacity(0)
        self._itemCell[i].itemBg:setBackGroundColorType(1)
        -- self._itemCell[i].itemBg:setBackGroundColor(cc.c3b(255,255,255))
        self._itemCell[i].itemBg:setContentSize(68, 68)
        self._itemCell[i].itemBg.posX = w+1
        self._itemCell[i].itemBg.posY = h+1
        self._itemCell[i].itemBg:setPosition(w+1, h-1)
        self._scrollView:addChild(self._itemCell[i].itemBg, 3)
        -- self._itemCell[i].itemBg:setVisible(true)

        self._itemCell[i].carryRewardIcon = cc.Sprite:createWithSpriteFrameName("activityPanel_bg2.png")
        self._itemCell[i].carryRewardIcon:setVisible(true)
        self._itemCell[i].carryRewardIcon:setPosition(w, h)
        self._scrollView:addChild(self._itemCell[i].carryRewardIcon, 7)

        self._itemCell[i].rewardIconBg = cc.Scale9Sprite:createWithSpriteFrameName("activityPanel_huadongBg.png")
        self._itemCell[i].rewardIconBg:setContentSize(102, 102)
        self._itemCell[i].rewardIconBg:setCapInsets(cc.rect(21, 21, 1, 1))
        self._itemCell[i].rewardIconBg:setVisible(true)
        self._itemCell[i].rewardIconBg:setPosition(w, h)
        self._scrollView:addChild(self._itemCell[i].rewardIconBg, 6)

        self._itemCell[i].rewardIcon = cc.Sprite:createWithSpriteFrameName("activityPanel_yiqiandao.png")
        self._itemCell[i].rewardIcon:setPosition(w, h)
        self._itemCell[i].rewardIcon:setVisible(true)
        self._scrollView:addChild(self._itemCell[i].rewardIcon, 7)

        -- self:registerClickEvent(self._itemCell[i], function()
        --     print("===========", i, w, h)
        -- end) 

        if math.fmod(i, 5) == 0 then
            h = h - itemBgHeight - 5
        end
        row = math.fmod(i, 5)
    end
end


function ActivitySignInView:signIn(flag, vipDouble)
    -- print("签到===========", flag, vipDouble)
    -- print(abc.abc)
    -- if self._isRet == true then
    local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local minCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 04:59:55"))
    local maxCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:10"))

    if (curServerTime > minCurDayTime) and (curServerTime < maxCurDayTime) then
        self._viewMgr:showTip("小精灵正在整理签到面板，请稍后重试哦~")
        return
    end

    if flag == true then
        self._serverMgr:sendMsg("SignServer", "replenishSign", {}, true, {}, function (result)
            self:signInFinish(result, vipDouble)
        end)
    else
        self._serverMgr:sendMsg("SignServer", "sign", {}, true, {}, function (result)
            self:signInFinish(result, vipDouble, true)
        end)
    end
end

function ActivitySignInView:signInFinish(result, vipDouble, shareopen)
    dump(result, "result==========")
    if result == nil then
        return
    end

    self:updateSignIn(self._monthDays)
    -- self:updateVipLab()
    if result.reward then
        if vipDouble == true then
            local vipPlusValue = 0
            -- 判断是否有腾讯特权登录加成
            if result.reward[1].txPlus then
                for _, v in pairs(result.reward[1].txPlus) do
                    vipPlusValue = (result.reward[1].num - v)*0.5
                end
            else
                vipPlusValue = result.reward[1].num*0.5
            end
            DialogUtils.showGiftGet({
                hide = self,
                gifts = result.reward,
                title = lang("FINISHSTAGETITLE"),
                vipPlus = vipPlusValue, 
                callback = function()
                    local userInfo = self._modelMgr:getModel("UserModel"):getData()
                    local signNum = userInfo.statis.snum28
                    print("signNum=====+++++++++=======", signNum)
                    local haveShare = tab:SignShare(signNum)
                    if haveShare and shareopen == true then
                        self:addShareNode(1, signNum)
                    end
            end})
        else
            DialogUtils.showGiftGet( {
                hide = self,
                gifts = result.reward,
                title = lang("FINISHSTAGETITLE"),
                callback = function()
                    local userInfo = self._modelMgr:getModel("UserModel"):getData()
                    local signNum = userInfo.statis.snum28
                    print("signNum======+++++++++======", signNum)
                    local haveShare = tab:SignShare(signNum)
                    if haveShare and shareopen == true then
                        self:addShareNode(1, signNum)
                    end
            end})
        end
    end
end

function ActivitySignInView:getTotalSignReward(indexId)
    -- print("累计签到===========")
    local param = {id = indexId}
    self._serverMgr:sendMsg("SignServer", "getTotalSignReward", param, true, {}, function (result)
        self:totalSignRewardFinish(result, indexId)
    end)
end

function ActivitySignInView:totalSignRewardFinish(result, indexId)
    if result == nil then
        return
    end
    self:updateSignIn(self._monthDays)
    if result.reward then
        local reward = result.reward
        DialogUtils.showGiftGet( {
            hide = self,
            gifts = result.reward,
            title = lang("FINISHSTAGETITLE"),
            callback = function()
                if indexId == 5 then
                    self:addShareNode(2, reward)
                end
        end})
    end
end

function ActivitySignInView:getSignInfo()
    -- print("获取签到===========")
    self._serverMgr:sendMsg("SignServer", "getSignInfo", {}, true, {}, function (result)
        -- self:totalSignRewardFinish(result)
        self._first = true
    end)
end

function ActivitySignInView:getAsyncRes()
    return 
    {
        {"asset/ui/activitysign.plist", "asset/ui/activitysign.png"},
        {"asset/ui/activitysign1.plist", "asset/ui/activitysign1.png"},
    }
end

function ActivitySignInView:setHeroLiHui()
    -- 12 个英雄位置
    local rolePos = {
        [60001] = {scale = 1.25, pos = {409,292}, roleName = "crusade_Adelaide"},
        [60101] = {scale = 1.0, pos = {330,292}, flip = 0, roleName = "crusade_Mullich"},
        [60701] = {scale = 0.8, pos = {330,340}, flip = 0, roleName = "crusade_Luna"},
        [60901] = {scale = 1, pos = {380,340}, flip = 0, roleName = "crusade_Zydar"},
        [60702] = {scale = 1, pos = {360,340}, flip = 1, roleName = "crusade_Monere"},
        [61401] = {scale = 1, pos = {400,340}, flip = 0, roleName = "crusade_Jeddite"},
        [61402] = {scale = 1, pos = {408,300}, flip = 1, roleName = "crusade_Sephinroth"},
        [61301] = {scale = 0.9, pos = {350,310}, flip = 0, roleName = "crusade_Mutare"},
        [60703] = {scale = 0.9, pos = {350,350}, flip = 1, roleName = "crusade_Erdamon"},
        [61502] = {scale = 0.95, pos = {425,337}, flip = 1, roleName = "crusade_Korbac"},
        [60704] = {scale = 1, pos = {400,337}, flip = 0, roleName = "crusade_Fiur"},
        [60202] = {scale = 1, pos = {365,340}, flip = 1, roleName = "crusade_Ylthin"},
    }
    local tMonth, _ = self:getTodayMonth()
    local indexId = tMonth .. "03"
    local signCountTab = tab:SignCount(tonumber(indexId))
    local heroId = signCountTab.content[1][2]

    local tempMonth = heroId or 60001
    local heroRole = rolePos[tempMonth] 
    if not heroRole then
        local heroTab = tab:Hero(tempMonth)
        if heroTab and heroTab.signPos then
            local signPos = heroTab.signPos or {350,350,0.9,1}
            heroRole = {}
            heroRole.scale = signPos[3] or 1
            heroRole.pos = {signPos[1] or 0, signPos[2] or 0}
            heroRole.flip = signPos[4] or 1
            heroRole.roleName = heroTab.crusadeRes or "crusade_Erdamon"
        else
            self._viewMgr:showTip("找邢涛配表，不配，hero表没有signPos, heroId" .. tempMonth)
        end
    end

    local lihuiIcon = self:getUI("bg.lihuiIconBg.roleBg.lihuiIcon")
    lihuiIcon:loadTexture("asset/uiother/hero/" .. heroRole["roleName"] .. ".png")
    lihuiIcon:setScale(heroRole["scale"])
    if heroRole["flip"] == 1 then
        lihuiIcon:setFlippedX(false)
    end
    lihuiIcon:setPosition(heroRole["pos"][1],heroRole["pos"][2])

    local heroLab = self:getUI("bg.lihuiIconBg.heroLab")
    -- local buchong1 = self:getUI("bg.lihuiIconBg.buchong1")
    -- local buchong2 = self:getUI("bg.lihuiIconBg.buchong2")

    -- if buchong1 then
    --     if rolePos[tempMonth]["bu1"] then
    --         buchong1:loadTexture("acSign_" .. rolePos[tempMonth]["roleName"] .. "_bc1.png", 1)
    --         buchong1:setAnchorPoint(cc.p(0.5,0.5))
    --         buchong1:setVisible(true)
    --         buchong1:setScale(rolePos[tempMonth]["scale"])
    --         buchong1:setPosition(cc.p(rolePos[tempMonth]["bu1"][1],rolePos[tempMonth]["bu1"][2]))
    --     else 
    --         buchong1:setVisible(false)
    --     end
    -- end

    -- if buchong2 then
    --     if rolePos[tempMonth]["bu2"] then
    --         buchong2:loadTexture("acSign_" .. rolePos[tempMonth]["roleName"] .. "_bc2.png", 1)
    --         buchong2:setAnchorPoint(cc.p(0.5,0.5))
    --         buchong2:setVisible(true)
    --         buchong2:setScale(rolePos[tempMonth]["scale"])
    --         buchong2:setPosition(cc.p(rolePos[tempMonth]["bu2"][1],rolePos[tempMonth]["bu2"][2]))
    --     else 
    --         buchong2:setVisible(false)
    --     end
    -- end

    if heroLab then
        heroLab:loadTexture("acSign_" .. heroRole["roleName"] .. ".png", 1)
    end
end

-- 获取缺勤天数
function ActivitySignInView:getLackDayNum()
    local lackNum = 0
    local dayNum = 0
    local signData = self._signModel:getData()
    local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-01 05:00:00"))
    local day = tonumber(TimeUtils.getDateString(curServerTime,"%d")) -- 天数
    -- print("signData.day == day", signData.day, day)

    local userData = self._modelMgr:getModel("UserModel"):getData()
    local openTime = userData.sec_open_time
    -- 开服时间小于5点大于12点
    local tempsecOpenTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(openTime,"%Y-%m-%d 05:00:00"))
    print("openTime < tempsecOpenTime===", openTime, tempsecOpenTime)
    if openTime < tempsecOpenTime then
        openTime = openTime - 43200
    end
    local secOpenDay = tonumber(TimeUtils.getDateString(openTime,"%Y%m")) -- 开服时间月
    local tDay = tonumber(TimeUtils.getDateString(curServerTime,"%Y%m")) -- 当前月

    local tCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    -- 当前时间小于1号凌晨5点
    if curServerTime < tCurDayTime then
        local curServerTime = curServerTime - 86400
        day = tonumber(TimeUtils.getDateString(curServerTime,"%d")) -- 天数
        tDay = tonumber(TimeUtils.getDateString(curServerTime,"%Y%m")) -- 当前月
    end

    -- 当前时间小于1号凌晨5点
    -- print("===========", curServerTime, tempCurDayTime)
    if curServerTime < tempCurDayTime then
        local curServerTime = curServerTime - 86400
        day = tonumber(TimeUtils.getDateString(curServerTime,"%d")) -- 天数
        tDay = tonumber(TimeUtils.getDateString(curServerTime,"%Y%m")) -- 当前月
    end

    -- print("==========", day, tDay)
    if tDay == secOpenDay then -- 开服时间同月
        local secOpenDayt = tonumber(TimeUtils.getDateString(openTime,"%d")) -- 开服时间天 15 - 15
        -- print("====secOpenDay========", day, secOpenDayt)
        day = day - secOpenDayt + 1
    end
    -- print("=dayday===========", day)
    
    dayNum = day
    lackNum = day - signData.day
    local flag = self:isSign()
    -- print("============", flag, dayNum)
    if flag == true then
        dayNum = dayNum - 1
        lackNum = lackNum - 1
    end
    if lackNum <= 0 then
        lackNum = 0
    end

    -- print('lackNum==========', dayNum, lackNum)
    return dayNum, lackNum
end

-- 是否可以补签
-- flag  0, 1, 2， 3 : 未补签， 可补签， 已补签, 不可补签
-- lackNum 缺勤天数
function ActivitySignInView:isRetroactive()
    local flag = 0

    local playerInfo = self._modelMgr:getModel("PlayerTodayModel"):getData()
    if playerInfo["day44"] == 1 then
        return 2, 0
    end

    local signData = self._signModel:getData()

    local day, lackNum = self:getLackDayNum()

    if lackNum <= 0 then
        return 3, 0
    end

    if day <= 1 then -- 第一天
        flag = 0
    elseif day > 1 then 
        if signData.day == day then
            flag = 0
        elseif signData.day < day then
            flag = 1
        end
    end
    -- 是否充值，或充值之后是否已经签过
    if flag == 1 then
        local kebuqian = signData.rNum
        if kebuqian > 0 then
            flag = 1
        else
            flag = 0
        end
        -- if playerInfo["day43"] >= 1 then
        --     flag = 1
        -- else
        --     flag = 0
        -- end
    end
    -- print("===playerInfo=====", playerInfo["day44"], playerInfo["day43"])
    return flag, lackNum
end

-- 今天是否已经签到
function ActivitySignInView:isSign()
    local state = 0
    local flag = false
    local signData = self._signModel:getData()

    local monthDays = 1
    local tabSign -- = tab:Sign(tonumber(todayDate))
    if signData.day and signData.day ~= 0 then
        monthDays = signData.day
    end

    -- 月份
    local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-01 05:00:00"))
    local todayMonth = tonumber(TimeUtils.getDateString(curServerTime,"%Y%m"))

    -- 当前时间小于1号凌晨5点
    if curServerTime < tempCurDayTime then
        todayMonth = tonumber(TimeUtils.getDateString(curServerTime - 86400,"%Y%m")) -- 当前月
    end

    if signData.signTime and signData.signTime ~= 0 then
        local lastSignIn = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(signData.signTime,"%Y-%m-%d %H:%M:%S"))
        -- 2016-04-05 05:03:00
        local tempSignDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(signData.signTime,"%Y-%m-%d 05:00:00"))
        -- 2016-04-05 00:00:00
        local tempRealSignDayTime = tempSignDayTime
        if tempSignDayTime < lastSignIn then
            tempRealSignDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(signData.signTime + 86400,"%Y-%m-%d 05:00:00"))
        end
        if curServerTime >= tempRealSignDayTime then
            monthDays = signData.day + 1
            -- tabSign = tab:Sign(tonumber(TimeUtils.getDateString((self._data.signTime + 86400),"%Y%m%d")))
        end
    end

    tabSign = tab:Sign(tonumber(string.format("%d%.2d", todayMonth, monthDays)))
    -- print("monthDays, tabSign, signData===", monthDays, tabSign, signData)
    state = self:getSignState1(monthDays, tabSign, signData)
    -- print("··state=========·", state)
    if state == 1 then
        flag = true
    end
    -- print("flag======", flag)
    return flag 
end


-- 签到状态
-- 是否可以签到
-- 状态 天数 是否补签
function ActivitySignInView:getSignState()
    local state = 0
    local isRet = 0
    local lackNum = 0
    local monthDays = 1

    local signData = self._signModel:getData()

    local tabSign -- = tab:Sign(tonumber(todayDate))
    if signData.day ~= 0 then
        monthDays = signData.day
    end

    -- 月份
    local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-01 05:00:00"))
    local todayMonth = tonumber(TimeUtils.getDateString(curServerTime,"%Y%m"))

    -- 当前时间小于1号凌晨5点
    if curServerTime < tempCurDayTime then
        todayMonth = tonumber(TimeUtils.getDateString(curServerTime - 86400,"%Y%m")) -- 当前月
    end

    if signData.signTime and signData.signTime ~= 0 then
        local lastSignIn = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(signData.signTime,"%Y-%m-%d %H:%M:%S"))
        -- 2016-04-05 05:03:00
        local tempSignDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(signData.signTime,"%Y-%m-%d 05:00:00"))
        -- 2016-04-05 00:00:00
        local tempRealSignDayTime = tempSignDayTime
        if tempSignDayTime < lastSignIn then
            tempRealSignDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(signData.signTime + 86400,"%Y-%m-%d 05:00:00"))
        end
        if curServerTime >= tempRealSignDayTime then
            monthDays = signData.day + 1
            -- tabSign = tab:Sign(tonumber(TimeUtils.getDateString((self._data.signTime + 86400),"%Y%m%d")))
        end
    end

    -- print("monthDays============", monthDays)
    local playerInfo = self._modelMgr:getModel("PlayerTodayModel"):getData()
    -- print("playerInfo=======", playerInfo["day44"], monthDays)
    if playerInfo["day44"] == 1 then
        monthDays = monthDays - 1
    end

    tabSign = tab:Sign(tonumber(string.format("%d%.2d", todayMonth, monthDays)))
    -- print("monthDays, tabSign, signData==", monthDays, tabSign, signData)
    
    state = self:getSignState1(monthDays, tabSign, signData)

    local isRet, lackNum = self:isRetroactive()

    print("geState=======", state, monthDays, isRet, lackNum)
    return state, monthDays, isRet
end

function ActivitySignInView:getSignState2()
    local signData = self._signModel:getData()
    local state, monthDays, isRet = self:getSignState()

    local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-01 05:00:00"))

    local todayMonth = tonumber(TimeUtils.getDateString(curServerTime,"%Y%m"))

    -- 当前时间小于1号凌晨5点
    if curServerTime < tempCurDayTime then
        todayMonth = tonumber(TimeUtils.getDateString(curServerTime - 86400,"%Y%m")) -- 当前月
    end

    -- if state ~= 1 then
        local isRet, lackNum = self:isRetroactive()
        -- print("===lackNum===isRet====", isRet, lackNum)
        if isRet == 1 then
            monthDays = monthDays + 1
            local tabSign = tab:Sign(tonumber(string.format("%d%.2d", todayMonth, monthDays)))
            state = self:getSignState1(monthDays, tabSign, signData)
        elseif isRet == 2 then
            monthDays = monthDays + 1
            local tabSign = tab:Sign(tonumber(string.format("%d%.2d", todayMonth, monthDays)))
            state = self:getSignState1(monthDays, tabSign, signData)
        elseif isRet == 0 and lackNum > 0 then
            monthDays = monthDays + 1
            local tabSign = tab:Sign(tonumber(string.format("%d%.2d", todayMonth, monthDays)))
            state = 4
        end
    -- end
    if state == 4 then
        local list1 = tab:Setting("G_RESIGN_ACTIVE").value[2]
        local list2 = table.nums(tab:Setting("G_RESIGN_RECHARGE").value)
        if signData["cList"] then
            local cList1 = signData["cList"]["1"]
            local cList2 = signData["cList"]["2"]
            if list1 == cList1 and list2 == cList2 then
                state = 5
            end
        end
    end

    print("getSignState2=======", state, monthDays, isRet)
    return state, monthDays, isRet
end

-- 0 不可签到
-- 1 签到
-- 2 继续领取
-- 3 vip等级不足
-- 4 可补签
function ActivitySignInView:getSignState1(monthDays, tabSign, signData)
    if tabSign == nil then
        state = 0
        return state
    end
    local state = 0
    if monthDays > signData.day then
        state = 1 -- 可签到
    else
        local viplevel = self._modelMgr:getModel("VipModel"):getData().level
        if tabSign.vip then
            if signData.vipReward[tostring(monthDays)] then
                state = 0
            else
                if viplevel >= tabSign.vip then
                    state = 2  -- vip继续领取
                else
                    state = 3
                end
            end
        else
            state = 0
        end
    end
    return state
end


function ActivitySignInView:getBuqianDialog()
    local signData = self._signModel:getData()
    local kebuqian = signData.rNum
    local showFlag = 0

    local list1 = tab:Setting("G_RESIGN_ACTIVE").value[2]
    local list2 = table.nums(tab:Setting("G_RESIGN_RECHARGE").value)
    if signData["cList"] then
        local viplevel = self._modelMgr:getModel("VipModel"):getData().level
        local userlevel = self._modelMgr:getModel("UserModel"):getData().lvl
        local cList1 = signData["cList"]["1"]
        local cList2 = signData["cList"]["2"]
        print("cList1======", cList1, cList2)
        if viplevel < 10 then
            if userlevel >= 12 and ((not cList1) or (cList1 and cList1 < list1)) then
                showFlag = 1
            elseif userlevel < 12 then
                showFlag = 1
            elseif (not cList2) or (cList2 and cList2 < list2) then
                showFlag = 2
            elseif signData["rNum"] == list1 + list2 then
                showFlag = 3
            end
        else
            if (not cList2) or (cList2 and cList2 < list2) then
                showFlag = 2
            elseif userlevel >= 12 and ((not cList1) or (cList1 and cList1 < list1)) then
                showFlag = 1
            elseif signData["rNum"] == list1 + list2 then
                showFlag = 3
            end
        end
    end
    if showFlag == 2 then
        local param = {showType = 2, sumBuy = signData.monRec, callback = function()
            self._first = false
        end}
        self._viewMgr:showDialog("activity.ActivitySignInDialog", param)
    elseif showFlag == 1 then
        local param = {showType = 1, callback = function()
            self._first = false
        end}
        self._viewMgr:showDialog("activity.ActivitySignInDialog", param)
    elseif showFlag == 3 then
        return showFlag
    elseif showFlag == 4 then
        self._viewMgr:showTip("每日任务12级开启")
    end
    print("showFlag=======", showFlag)
end

-- 当前月是否可补签
function ActivitySignInView:isMonthBuqian()
    local signData = self._signModel:getData()
    local kebuqian = signData.rNum
    local list1 = tab:Setting("G_RESIGN_ACTIVE").value[2]
    local list2 = table.nums(tab:Setting("G_RESIGN_RECHARGE").value)
    local flag = false
    if kebuqian == 0 then
        local cList1 = signData["cList"]["1"]
        local cList2 = signData["cList"]["2"]
        if signData["cList"] then
            if (not cList1) or cList1 < list1 then
                flag = true
            elseif (not cList2) or cList2 < list2 then
                flag = true
            end
        end
    else
        flag = true
    end
    return flag
end


-- 获取月份和月最大天数
function ActivitySignInView:getTodayMonth()
    -- 月份
    local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-01 05:00:00"))
    local todayMonth = tonumber(TimeUtils.getDateString(curServerTime,"%Y%m"))

    -- 当前时间小于1号凌晨5点
    if curServerTime < tempCurDayTime then
        curServerTime = curServerTime - 86400
        todayMonth = tonumber(TimeUtils.getDateString(curServerTime,"%Y%m")) -- 当前月
    end
    
    local monthNum = tonumber(TimeUtils.getDaysOfMonth(curServerTime))
    return todayMonth, monthNum
end

function ActivitySignInView:setTencent()
    local _tencentModel = self._modelMgr:getModel("TencentPrivilegeModel")
    if GameStatic.appleExamine or not _tencentModel:isOpenPrivilege() then
        return 
    end

    -- 腾讯特权加成
    local additionalNode = self:getUI("bg.additional")
    if sdkMgr:isQQ() then
        additionalNode:setVisible(true)
        local qqNode = additionalNode:getChildByFullName("qqNode")
        qqNode:setVisible(true)

        local isQQVip, isQQTeQuan
        if _tencentModel:getQQVip() == _tencentModel.IS_QQ_VIP then
            qqNode:getChildByFullName("qqVip1"):loadTexture("tencentIcon_qqVip.png", 1)
            qqNode:getChildByFullName("qqVip3"):setString("x " .. tab:QqVIP(7).up[1][3])
            isQQVip = true
        elseif _tencentModel:getQQVip() == _tencentModel.IS_QQ_SVIP then
            qqNode:getChildByFullName("qqVip1"):loadTexture("tencentIcon_qqSVip.png", 1)
            qqNode:getChildByFullName("qqVip3"):setString("x " .. tab:QqVIP(8).up[1][3])
            isQQVip = true
        end

        if _tencentModel:getTencentTeQuan() == _tencentModel.QQ_GAME_CENTER then
            qqNode:getChildByFullName("qqNormal4"):setString("x " .. tab:QqVIP(4).up[1][3])
            isQQTeQuan = true
        end

        if isQQVip and not isQQTeQuan then
--            for vipI = 1, 3 do
--                local qqVip = qqNode:getChildByFullName("qqVip" .. vipI)
--                qqVip:setPositionX(qqVip:getPositionX() + 150)
--            end

            for nI = 1, 4 do
                qqNode:getChildByFullName("qqNormal" .. nI):setVisible(false)
            end

            qqNode:getChildByFullName("qqVip1"):setPositionX(qqNode:getChildByFullName("qqNormal1"):getPositionX() - 40)

            if _tencentModel:getQQVip() == _tencentModel.IS_QQ_VIP then
                qqNode:getChildByFullName("qqNormal2"):setString("QQ会员专享签到加成")
            elseif _tencentModel:getQQVip() == _tencentModel.IS_QQ_SVIP  then
                qqNode:getChildByFullName("qqNormal2"):setString("QQ超级会员专享签到加成")
            end
            qqNode:getChildByFullName("qqNormal2"):setVisible(true)
            qqNode:getChildByFullName("qqVip2"):setPositionX(qqNode:getChildByFullName("qqNormal3"):getPositionX() + 30)
            qqNode:getChildByFullName("qqVip3"):setPositionX(qqNode:getChildByFullName("qqNormal4"):getPositionX() + 30)


        elseif not isQQVip and isQQTeQuan then
            for vipI = 1, 3 do
                qqNode:getChildByFullName("qqVip" .. vipI):setVisible(false)
            end

            for nI = 1, 4 do
                local qqNormal = qqNode:getChildByFullName("qqNormal" .. nI)
                qqNormal:setPositionX(qqNormal:getPositionX() - 70)
            end


        elseif not isQQVip and not isQQTeQuan then
            additionalNode:setVisible(false)
        end

    elseif _tencentModel:getTencentTeQuan() == _tencentModel.WX_GAME_CENTER then
        additionalNode:setVisible(true)
        local wxNode = additionalNode:getChildByFullName("wxNode")
        wxNode:setVisible(true)

        wxNode:getChildByFullName("wx4"):setString("x " .. tab:QqVIP(2).up[1][3])

    else
        additionalNode:setVisible(false)
    end
end

-- shareType 
-- 1 累签分享
-- 2 全勤分享
function ActivitySignInView:addShareNode(shareType, haveShare)
    print("shareType=========", shareType)
    dump(haveShare)
    local param = {moduleName = "ShareSignModule"}
    if shareType == 1 and haveShare ~= nil then
        -- 累签分享
        local userModel = self._modelMgr:getModel("UserModel")
        local userInfo = userModel:getData()
        local signNum = userInfo.statis.snum28 or 1
        param.signNum = signNum
        param.shareType = shareType
    elseif shareType == 2 and haveShare ~= nil then
        -- 全勤分享
        if haveShare and haveShare[1] and haveShare[1]["typeId"] then
            param.treasureId = haveShare[1]["typeId"]
        end
        param.shareType = shareType
    end
    if not param then
        return
    end
    local userModel = self._modelMgr:getModel("UserModel")
    if userModel:checkPlatShareState() == true then
        self._viewMgr:showDialog("share.ShareBaseView", param)
    end
end


function ActivitySignInView.dtor()
    cc = nil
end

return ActivitySignInView