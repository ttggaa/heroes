--[[
    Filename:    GuildMapSecondEventView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-06-30 18:00:10
    Description: File description
--]]


local GuildMapSecondEventView = class("GuildMapSecondEventView", BasePopView)

function GuildMapSecondEventView:ctor(data)
    GuildMapSecondEventView.super.ctor(self)
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("guild.map.GuildMapSecondEventView")
        elseif eventType == "enter" then 
        end
    end)   

    self._userId = self._modelMgr:getModel("UserModel"):getData()._id
    self._guildId = self._modelMgr:getModel("UserModel"):getData().guildId

    self._guildMapModel = self._modelMgr:getModel("GuildMapModel")
    self._eventType = data.eventType
    self._callback = data.callback
    self._targetId = data.targetId
    self._eleId = data.eleId

    self._parentView = data.parentView

    self._isRemote = data.isRemote
end

function GuildMapSecondEventView:onInit()
    for i=10, 18 do
        local event = self:getUI("event" .. i )
        if event ~= nil then
            event:setVisible(false)    
        end
    end

    self._sysGuildMapThing = tab:GuildMapThing(self._eleId)

    local subTitleLab = self:getUI("event" .. self._eventType .. ".bg.infoBg.titleLab")
    local titleLab = self:getUI("event" .. self._eventType .. ".bg.titleBg.titleLab")
    UIUtils:setTitleFormat(titleLab, 1)
    -- titleLab:setFontName(UIUtils.ttfName)
    -- titleLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
    if subTitleLab == nil then 
        titleLab:setString(lang(self._sysGuildMapThing.name))
    else
        subTitleLab:setString(lang(self._sysGuildMapThing.name))
        UIUtils:adjustTitle(self:getUI("event" .. self._eventType .. ".bg.infoBg"))
    end


    local descBg = self:getUI("event" .. self._eventType .. ".bg.descBg")
    if descBg ~= nil and self._sysGuildMapThing.des ~= nil then 
        local str = lang(self._sysGuildMapThing.des)
        if string.find(str, "color=") == nil then
            str = "[color=000000]"..str.."[-]"
        end          
        local rtx = RichTextFactory:create(str,descBg:getContentSize().width,descBg:getContentSize().height)
        rtx:formatText()
        rtx:setVerticalSpace(3)
        rtx:setAnchorPoint(cc.p(0,0.5))
        rtx:setPosition(-rtx:getInnerSize().width/2,descBg:getContentSize().height/2)
        descBg:addChild(rtx)
    end


    local eventBg = self:getUI("event" .. self._eventType)
    eventBg:setVisible(true)

    local closeBtn = self:getUI("event" .. self._eventType .. ".bg.closeBtn")
    self:registerClickEvent(closeBtn, function ()
        self:close(true)
    end)

    print("self._eventType=====",self._eventType)
    self["onInit" .. self._eventType](self)
end

--[[
--! @function onInit18
--! @desc 先知小屋 初始化
--! @return 
--]]
function GuildMapSecondEventView:onInit18()
    local desc2 = self:getUI("event18.bg.desc2")
    local rtxW, rtxH = desc2:getContentSize().width - 20,desc2:getContentSize().height
    local desTemp = ""
    if self._sysGuildMapThing["des"] then
        desTemp = self._sysGuildMapThing["des"] .."_b"
    else
        desTemp = "GUILDMAPDES_" .. self._eleId .. "_b"
    end
    local rtx = RichTextFactory:create(lang(desTemp), rtxW, rtxH)
    rtx:formatText()
    rtx:setVerticalSpace(3)
    rtx:setAnchorPoint(cc.p(0,1))
    rtx:setPosition(-rtx:getInnerSize().width/2 + 10,desc2:getContentSize().height + 50)
    desc2:addChild(rtx)

    -- 所需消耗
    local useItem = self._sysGuildMapThing.use[1]
    if useItem == nil then 
        return
    end
    
    local useBg = self:getUI("event18.bg.useBg")
    local tips1 = {}
    if useItem[1] == "gem" then
        tips1[1] = cc.Sprite:createWithSpriteFrameName("globalImageUI_diamond.png")
    else
        tips1[1] = cc.Sprite:createWithSpriteFrameName("globalImageUI_gold1.png")
    end
    tips1[1]:setScale(0.62)
    tips1[2] = cc.Label:createWithTTF(" "..useItem[3],UIUtils.ttfName, 16)
    tips1[2]:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
   
    local nodeTip1 = UIUtils:createHorizontalNode(tips1)
    nodeTip1:setAnchorPoint(cc.p(0.5, 0.5))
    nodeTip1:setPosition(useBg:getContentSize().width/2, useBg:getContentSize().height/2 - 2)
    useBg:addChild(nodeTip1)

    --icon
    local infoBg = self:getUI("event18.bg.infoBg")
    local tempPic = cc.Sprite:createWithSpriteFrameName(self._sysGuildMapThing.art1 .. ".png")
    tempPic:setAnchorPoint(0.5, 0)
    tempPic:setPosition(cc.p(infoBg:getContentSize().width * 0.5 - 15, 30))
    infoBg:addChild(tempPic)
    
    --打听btn
    local enterBtn = self:getUI("event18.bg.enterBtn")
    self:registerClickEvent(enterBtn, function()
        local curGold = self._modelMgr:getModel("UserModel"):getData().gold
        local needGold = useItem[3]
        if curGold < needGold then
            DialogUtils.showLackRes({goalType = "gold"})
            return
        end

        self._serverMgr:sendMsg("GuildMapServer", "acMTask1", {tagPoint = self._targetId}, true, {}, function (result)
            self._viewMgr:lock(-1)
            local jihuoAim = mcMgr:createViewMC("huoderenwu_lianmengjihuo", false, true, function()
                local goGuildName = self._guildMapModel:getPassGuildName()
                local curTip = string.gsub(lang("GUILDMAPDES_3101_tip"), "${name}", goGuildName)
                self._viewMgr:showTip(curTip)
                if self._callback ~= nil then 
                    self:_callback()
                end
                self._viewMgr:unlock()
                self:close()
            end)
            jihuoAim:setPosition(self:getContentSize().width*0.5, self:getContentSize().height*0.5 + 50)
            self:addChild(jihuoAim, 1000000)
                
            end)
        end)

    --离开btn
    local cancelBtn = self:getUI("event18.bg.cancelBtn")
    self:registerClickEvent(cancelBtn, function()
        self:close()
        end)
end

--[[
--! @function onInit14
--! @desc 城池 初始化
--! @return 
--]]
function GuildMapSecondEventView:onInit14()



    local event = self:getUI("event14")
    event:setVisible(false)
    --by wangyan
    local tipLayer
    local tipLayer = self:getUI("event14.popLayer")
    tipLayer:setVisible(false)
    local tipBg = self:getUI("event14.popLayer.tipDesBg")
    self:registerClickEvent(tipLayer, function()
        tipLayer:setVisible(false)
        if tipBg:getChildByName("tipRtx") then
            tipBg:getChildByName("tipRtx"):removeFromParent(true)
        end
        end)

    self:registerClickEventByName("event14.bg.infoBg.tipBtn", function()
        if not tipLayer:isVisible() then
            tipLayer:setVisible(true)
            local desRtx = RichTextFactory:create(lang("GUILD_MAP_CITY_EXPLAIN"), 350, 0)
            desRtx:setPosition(tipBg:getContentSize().width/2, tipBg:getContentSize().height/2)
            desRtx:setName("tipRtx")
            tipBg:addChild(desRtx)
        end
        end)

    for i=3, 9 do
        local tipLab = self:getUI("event14.bg.tipLab" .. i)
        if tipLab ~= nil then
            tipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        end
    end

    local tipLab10 = self:getUI("event14.bg.tipLab10")
    tipLab10:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    tipLab10:setString("(21:30结算)")

    local showImg = self:getUI("event14.bg.leftBg")
    showImg:loadTexture(self._sysGuildMapThing.art1 .. ".png", 1)

    local gemLab = self:getUI("event14.bg.gemLab")
    gemLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
    gemLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    -- 驻扎人数tip
    local tipLab1 = self:getUI("event14.bg.tipLab1")
    tipLab1:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local enterBtn1 = self:getUI("event14.bg.enterBtn1")
    -- enterBtn1:setPositionY(enterBtn1:getPositionY() + 20)

    local tipLab2 = self:getUI("event14.bg.tipLab2")
    tipLab2:setColor(cc.c3b(118, 110, 117))
    -- local tapLab2 = cc.Label:createWithTTF("周六周日城池奖励双倍", UIUtils.ttfName ,20)
    -- tapLab2:setColor(cc.c3b(118, 110, 117))
    -- tapLab2:setPosition(enterBtn1:getPositionX(), enterBtn1:getPositionY() - 40)
    -- enterBtn1:getParent():addChild(tapLab2)

    self:getPointInfo()
    -- self:onInit14_1()
end

--[[
--! @function onInit14
--! @desc 城池 初始化
--! @return 
--]]
function GuildMapSecondEventView:onInit14_1()

    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local limitTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 05:00:00"))
    local operateTime = curTime
    if limitTime > curTime then
        operateTime = curTime - 86400
    end
    local curDate = TimeUtils.date("*t", operateTime)
    local curWakeDay = 1
    if curDate.wday == 1 then 
        curWakeDay = 7
    else
        curWakeDay = curDate.wday - 1
    end
    local isDoubleReward = false
    if self._sysGuildMapThing.doubletime ~= nil then
        for k,v in pairs(self._sysGuildMapThing.doubletime) do
            local subWakeDay = v - curWakeDay

            local openTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(operateTime + subWakeDay * 86400,"%Y-%m-%d 05:00:00"))

            local closeTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(operateTime + (subWakeDay + 1) * 86400,"%Y-%m-%d 05:00:00"))
            if curTime >= openTime and curTime < closeTime then 
                isDoubleReward = true
            end
        end
    end
    print("isDoubleReward=======", isDoubleReward)
    local event = self:getUI("event14")
    event:setVisible(true)
    event:runAction(
        cc.Sequence:create(
        cc.DelayTime:create(1),
        cc.CallFunc:create(function()
            event:stopAllActions()
            self:onInit14_1()
        end)
        ))
    local mapList = self._guildMapModel:getData().mapList
    local thisTarget = mapList[self._targetId]
    if thisTarget == nil then 
        self:closeInit()
        self._viewMgr:showTip("数据不匹配")
        return
    end
    local thisEle = thisTarget.common
    local closeBtn = self:getUI("event16.bg.closeBtn")
    self:registerClickEvent(closeBtn, function ()
        self:close(true)
    end)

    if thisEle == nil or next(thisEle) == nil then 
        self:closeInit()
        self._viewMgr:showTip("数据不匹配")
        return
    end



    local battleBtn = self:getUI("event14.bg.battleBtn")
    battleBtn:setVisible(false)
    self:registerClickEvent(battleBtn, function ()
        local mapList = self._guildMapModel:getData().mapList
        local stayPlayer = mapList[self._targetId].player
        if stayPlayer == nil or table.nums(stayPlayer) <= 0 then 
            self._viewMgr:showTip("已无可攻击玩家")
            self:close()
            return
        end
        local tempUserIds = {}
        for k,v in pairs(stayPlayer) do
            table.insert(tempUserIds, k)
        end
        self._parentView:showPVPEvent(self._targetId, tempUserIds)
        self:close()
    end)

    local viewFunction = function()
        local mapList = self._guildMapModel:getData().mapList
        local stayPlayer = mapList[self._targetId].player
        if stayPlayer == nil or table.nums(stayPlayer) <= 0 then 
            self._viewMgr:showTip("无人驻防")
            self:close()
            return
        end
        local tempUserIds = {}
        for k,v in pairs(stayPlayer) do
            table.insert(tempUserIds, k)
        end
        self._parentView:showPVPEvent(self._targetId, tempUserIds, true)
        self:close()
    end
    
    local viewBtn1 = self:getUI("event14.bg.viewBtn1")
    viewBtn1:setVisible(false)
    self:registerClickEvent(viewBtn1, function ()
        if viewBtn1.inNum == 0 then 
            self._viewMgr:showTip("无人驻守")
            return
        end
        viewFunction()
    end)

    local viewBtn = self:getUI("event14.bg.viewBtn")
    viewBtn:setVisible(false)
    self:registerClickEvent(viewBtn, function ()
        viewFunction()
    end)

    local leaveBtn = self:getUI("event14.bg.leaveBtn")
    leaveBtn:setVisible(false)
    self:registerClickEvent(leaveBtn, function ()
        self:close(true)
    end)

    local enterBtn = self:getUI("event14.bg.enterBtn")
    enterBtn:setVisible(false)
    self:registerClickEvent(enterBtn, function ()
        self:defendCenterCity()
    end)

    local enterBtn1 = self:getUI("event14.bg.enterBtn1")
    enterBtn1:setVisible(false)
    self:registerClickEvent(enterBtn1, function ()
        self:defendCenterCity()
    end)


    local serverLvl = self._guildMapModel:getData().servLv
    local rewardGemNum1 = 0
    local rewardGemNum2 = 0

    for i=1, 6 do
        local award = self._sysGuildMapThing["produceAward"][i]
        if award ~= nil and serverLvl >= award[1] and serverLvl <= award[2] then 
            rewardGemNum1 = award[3][1][3]
            break
        end
    end        
    for i=1, 6 do
        local award = self._sysGuildMapThing["doubleAward1"][i]
        if award ~= nil and serverLvl >= award[1] and serverLvl <= award[2] then 
            rewardGemNum2 = award[3][1][3]
            break
        end
    end  

    print("rewardGemNum===============", rewardGemNum1, serverLvl)
    local gemLab = self:getUI("event14.bg.gemLab")
    if isDoubleReward ==  true then 
        gemLab:setString(60 / self._sysGuildMapThing.point * rewardGemNum2)
    else
        gemLab:setString(60 / self._sysGuildMapThing.point * rewardGemNum1)
    end

    if isDoubleReward == true then
        if gemLab.doubleTip == nil then
            
            local doubleTip = cc.Sprite:createWithSpriteFrameName("globalImageUI_skilltag_2.png")
            doubleTip:setAnchorPoint(0, 0)
            doubleTip:setPosition(gemLab:getPositionX() + 100, gemLab:getPositionY() - 10)
            gemLab:getParent():addChild(doubleTip)


            local layer = cc.LayerColor:create(cc.c4b(207, 46, 0, 180))
            layer:setPosition(doubleTip:getContentSize().width  * 0.5 - 15, doubleTip:getContentSize().height  * 0.5 - 10)
            layer:setContentSize(30, 20)

            doubleTip:addChild(layer)

            local doubleText = cc.Label:createWithTTF("双倍", UIUtils.ttfName, 14)
            doubleText:setAnchorPoint(0.5, 0.5)
            doubleText:setPosition(cc.p(doubleTip:getContentSize().width  * 0.5, doubleTip:getContentSize().height * 0.5))
            doubleText:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
            doubleTip:addChild(doubleText) 

            gemLab.doubleTip = doubleTip
        end
    else
        if gemLab.doubleTip ~= nil then 
            gemLab.doubleTip:removeFromParent()
            gemLab.doubleTip = nil
        end
    end


    local image_29 = self:getUI("event14.bg.Image_29")
    image_29:setPosition(gemLab:getPositionX() + gemLab:getContentSize().width* gemLab:getScaleX(), image_29:getPositionY())
    -- gemLab:setVisible(false)

    local tipLab5 = self:getUI("event14.bg.tipLab5")
    tipLab5:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    tipLab5:setPosition(image_29:getPositionX() + image_29:getContentSize().width* image_29:getScaleX(), tipLab5:getPositionY())

    local str = nil
    local guildNameLab = self:getUI("event14.bg.guildNameLab")
    

    local stayPlayer = mapList[self._targetId].player
    if stayPlayer == nil then 
        stayPlayer = {}
    end


    local numLab = self:getUI("event14.bg.numLab")
    
    local timeLab = self:getUI("event14.bg.timeLab")
    timeLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
    timeLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    
    local timeTipLab = self:getUI("event14.bg.timeTipLab")
    timeTipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    


    local rewardLab = self:getUI("event14.bg.rewardLab")
    rewardLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
    rewardLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    local rewardImg = self:getUI("event14.bg.rewardImg")

    local userList = self._guildMapModel:getData().userList
    -- 当前地形有限制
    local curOp = userList[self._userId].curOp

    local tipLab7 = self:getUI("event14.bg.tipLab7")
    local tipLab9 = self:getUI("event14.bg.tipLab9") 
    
    local function updateGuildState(inState, inGuildName, inNum)
        if stayPlayer[self._userId] == nil then 
            tipLab7:setVisible(false)
            tipLab9:setVisible(false)
            timeLab:setVisible(false)
            timeTipLab:setVisible(false)
            rewardLab:setVisible(false)
            rewardImg:setVisible(false)
        else
            tipLab7:setVisible(true)
            tipLab9:setVisible(true)
            timeLab:setVisible(true)
            timeTipLab:setVisible(true)
            rewardLab:setVisible(true)
            rewardImg:setVisible(true)            
        end
        if inState == 1 then 
            numLab:disableEffect()
            numLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            numLab:setString(0)
            guildNameLab:disableEffect()
            guildNameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            guildNameLab:setString("无人占领")
        elseif inState == 2 then 
            numLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
            numLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
            numLab:setString(inNum)
            guildNameLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
            guildNameLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
            guildNameLab:setString("我方占领")
            if stayPlayer[self._userId] ~= nil then
                if inNum == 0 then 
                    timeLab:setString(0)
                    rewardLab:setString(0)
                else
                    local tempDoubleTime = {}
                    for k,v in pairs(self._sysGuildMapThing.doubletime) do
                        tempDoubleTime[v] = 1
                    end

                    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()   
                    local operateTime = curOp.defendst
                    local rewardNum = 0
                    local rewardTime = 0
                    -- 特殊情况的时间保留
                    local surplusTime = 0
                    while true do
                        local tmpTime = 0
                        -- 系数
                        local rewardGemNum = rewardGemNum1
                        local endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(operateTime,"%Y-%m-%d 05:00:00"))
                        if operateTime >= endTime then 
                            tmpTime = operateTime
                            endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(operateTime + 86400,"%Y-%m-%d 05:00:00"))
                            subTime = endTime - operateTime
                        else
                            tmpTime = operateTime - 86400
                            subTime = endTime - operateTime
                        end
                        if subTime > (curTime - operateTime) then 
                            subTime = (curTime - operateTime) 
                        end
                        
                        -- 计算周几
                        local operateDate = TimeUtils.date("*t", tmpTime)
                        local curWakeDay = 1
                        if operateDate.wday == 1 then 
                            curWakeDay = 7
                        else
                            curWakeDay = operateDate.wday - 1
                        end

                        if tempDoubleTime[curWakeDay] == 1 then  
                            rewardGemNum = rewardGemNum2
                        end
                        
                        local midTime = 0
                        local singleRewardNum = 0
                        -- 跨今天5点时候   那么昨天的数往上取  当天的往下取 
                        if curTime >= endTime  then 
                            midTime =  math.ceil(subTime / 3600 * 10) / 10
                            singleRewardNum = math.ceil((midTime * 60 / self._sysGuildMapThing.point) * rewardGemNum) 
                        else
                            midTime = math.floor(subTime / 3600 * 10) / 10
                            singleRewardNum = math.floor((midTime * 60 / self._sysGuildMapThing.point) * rewardGemNum) 
                        end
                        rewardTime = rewardTime + midTime
                        rewardNum = rewardNum + singleRewardNum

                        if operateTime + subTime >= curTime then 
                            break
                        end
                        operateTime = operateTime + subTime
                    end

                    timeLab:setString(rewardTime)
                    rewardLab:setString(rewardNum)
                end
                timeTipLab:setPositionX(timeLab:getPositionX() + timeLab:getContentSize().width)
                rewardImg:setPositionX(rewardLab:getPositionX() + rewardLab:getContentSize().width)
            end            
        else
            numLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
            numLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
            numLab:setString(inNum)
            guildNameLab:setString(inGuildName .. "占领中")
            guildNameLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
            guildNameLab:disableEffect()
        end

    end
    -- 远程访问
    if self._isRemote == true  then 
        local guildList = self._guildMapModel:getData().guildList
        if thisEle.nowguildId == nil or 
            tostring(thisEle.nowguildId) == "0" then 
            str = lang("GUILD_CITY_DES_5")
            viewBtn1.inNum = 0
            updateGuildState(1, "", 0)
        elseif thisEle.nowguildId ~= nil and tostring(self._guildId) == tostring(thisEle.nowguildId) then
            str = lang("GUILD_CITY_DES_7")
            viewBtn:setVisible(true)
            viewBtn1.inNum = table.nums(stayPlayer)
            updateGuildState(2, guildList[tostring(thisEle.nowguildId)].name, table.nums(stayPlayer))           
        else
            str = lang("GUILD_CITY_DES_6")
            viewBtn:setVisible(true)
            viewBtn1.inNum = table.nums(stayPlayer)
            updateGuildState(3, guildList[tostring(thisEle.nowguildId)].name, table.nums(stayPlayer))           
        end

    else
        -- 无人无公会驻守
        if thisEle.nowguildId == nil or 
            tostring(thisEle.nowguildId) == "0" then 

            enterBtn1:setVisible(true)

            str = lang("GUILD_CITY_DES_3")
            
            viewBtn1.inNum = 0
            updateGuildState(1, "", 0)
        -- 有公会驻守
        elseif thisEle.nowguildId ~= nil then
            local guildList = self._guildMapModel:getData().guildList
            -- 同一公会相关处理
            if tostring(self._guildId) == tostring(thisEle.nowguildId) then
                -- 已经驻守过
                if stayPlayer[self._userId] ~= nil then 
                    str = lang("GUILD_CITY_DES_4")
                    viewBtn:setVisible(true)
                else
                    str = lang("GUILD_CITY_DES_2")
                    enterBtn:setVisible(true)
                    viewBtn1:setVisible(true)
                end
                viewBtn1.inNum = table.nums(stayPlayer)
                updateGuildState(2, guildList[tostring(thisEle.nowguildId)].name, table.nums(stayPlayer))    
            else
                viewBtn1.inNum = table.nums(stayPlayer)
                updateGuildState(3, guildList[tostring(thisEle.nowguildId)].name, table.nums(stayPlayer))    
                -- 不同公会相关处理
                str = lang("GUILD_CITY_DES_1")
                if table.nums(stayPlayer) > 0 then
                    battleBtn:setVisible(true)
                else
                    enterBtn:setVisible(true)
                end
                leaveBtn:setVisible(true)
            end 
        end
    end
    
    local rewardBg = self:getUI("event14.bg.rewardBg")
    if rewardBg.isDoubleReward ~= isDoubleReward  then 
        if rewardBg.rewardInfo ~= nil then 
            rewardBg.rewardInfo:removeFromParent(true)
            rewardBg.rewardInfo = nil
        end
    end
    if rewardBg.rewardInfo == nil then
        local reward = {}
        local readField = "calculate"
        if isDoubleReward == true then
            readField = "doubleAward2"
        end

        for i=1, 6 do
            local award = self._sysGuildMapThing[readField][i]
            if award ~= nil  and serverLvl >= award[1] and serverLvl <= award[2] then 
                for k,v in pairs(award[3]) do
                    reward[#reward + 1] = v 
                end
            end
        end

        -- 奖励
        local GuildMapUtils = require "game.view.guild.map.GuildMapUtils"
        local backNode = GuildMapUtils:showItems(reward, 0.9, nil, nil, nil, isDoubleReward)
        backNode:setAnchorPoint(0, 1)
        backNode:setPosition(0, rewardBg:getContentSize().height)
        backNode:setScale(0.6)
        rewardBg:addChild(backNode)
        rewardBg.rewardInfo = backNode
        rewardBg.isDoubleReward = isDoubleReward
    end

    -- local descBg = self:getUI("event14.bg.descBg2")
    -- if descBg ~= nil and str ~= nil then 
    --     descBg:removeAllChildren()
    --     if string.find(str, "color=") == nil then
    --         str = "[color=000000]"..str.."[-]"
    --     end          
    --     local rtx = RichTextFactory:create(str,descBg:getContentSize().width,descBg:getContentSize().height)
    --     rtx:formatText()
    --     rtx:setVerticalSpace(3)
    --     rtx:setAnchorPoint(cc.p(0,0.5))
    --     rtx:setPosition(-rtx:getInnerSize().width/2,descBg:getContentSize().height/2)
    --     descBg:addChild(rtx)
    -- end

end


--[[
--! @function onInit16
--! @desc 地下城入口 初始化
--! @return 
--]]
function GuildMapSecondEventView:onInit16()
    local mapList = self._guildMapModel:getData().mapList
    local thisTarget = mapList[self._targetId]
    if thisTarget == nil then 
        self._viewMgr:showTip("数据不匹配")
        self:closeInit()
        return
    end
    local thisEle = thisTarget.common

    local closeBtn = self:getUI("event16.bg.closeBtn")
    self:registerClickEvent(closeBtn, function ()
        self:close(true)
    end)

    if thisEle == nil or next(thisEle) == nil then 
        self:closeInit()
        self._viewMgr:showTip("数据不匹配")
        return
    end

    local infoBg = self:getUI("event16.bg.infoBg")
    infoBg:loadTexture(self._sysGuildMapThing.art1 .. ".png", 1)

    local enterBtn = self:getUI("event16.bg.enterBtn")
    self:registerClickEvent(enterBtn, function ()
        self:passPortal("center")
    end)
end

--[[
--! @function onInit13
--! @desc 方尖塔 初始化
--! @return 
--]]
function GuildMapSecondEventView:onInit13()
    local mapList = self._guildMapModel:getData().mapList
    local thisTarget = mapList[self._targetId]
    if thisTarget == nil then 
        self:closeInit()
        self._viewMgr:showTip("数据不匹配")
        return
    end

    local thisEle = thisTarget.guild

    local closeBtn = self:getUI("event13.bg.closeBtn")
    self:registerClickEvent(closeBtn, function ()
        -- 某些建筑关闭时需要回调
        if self._callback ~= nil then 
            self:_callback()
        end
        self:close(true)
    end)

    if thisEle == nil or next(thisEle) == nil then 
        self:closeInit()
        self._viewMgr:showTip("数据不匹配")
        return
    end
    local tipLab1 = self:getUI("event13.bg.tipLab1")
    tipLab1:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local tipLab3 = self:getUI("event13.bg.tipLab3")
    tipLab3:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local tipLab2 = self:getUI("event13.bg.tipLab2")
    tipLab2:setVisible(false)
    tipLab2:setColor(UIUtils.colorTable.ccUIBaseColor2)
    tipLab2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    local infoBg = self:getUI("event13.bg.infoBg")
    infoBg:loadTexture(self._sysGuildMapThing.art1 .. ".png", 1)

    self._fogTipLab = self:getUI("event13.bg.tipLab")
    self._fogTipLab:setFontName(UIUtils.ttfName)
    self._fogTipLab:setString("未激活")
    self._fogTipLab:setColor(UIUtils.colorTable.ccColorQuality6)
    self._fogTipLab:disableEffect()

    self._actNum = self._guildMapModel:getTaskCompleteState(GuildConst.TASK_TYPE.GUILD_MAP_ST_GLOBAL_AC_TOWER)
    tipLab2:setString(self._actNum)
    tipLab2:setVisible(true)

    local activeBtn = self:getUI("event13.bg.activeBtn")
    activeBtn:setVisible(false)
    -- 如果已经激活
    if thisEle.haduse ~= nil and 
        tonumber(thisEle.haduse) >= 1 then

        tipLab2:setVisible(true)
        tipLab2:setString(self._guildMapModel:getTaskCompleteState(GuildConst.TASK_TYPE.GUILD_MAP_ST_GLOBAL_AC_TOWER))

        self._fogTipLab:setString("已激活")
        self._fogTipLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
        self._fogTipLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        return
    end
    
    if self._isRemote == true then 
        self._fogTipLab:setString("未激活")
        self._fogTipLab:setColor(UIUtils.colorTable.ccColorQuality6)     
        self._fogTipLab:disableEffect()   
        return
    end

    activeBtn:setVisible(true)
    -- if activeBtn.mc1 == nil then
    --     local mc1 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
    --     mc1:setName("anim")
    --     mc1:setPosition(activeBtn:getContentSize().width*activeBtn:getScaleX()*0.5, activeBtn:getContentSize().height*activeBtn:getScaleY()*0.5)
    --     activeBtn:addChild(mc1, 1)
    -- end
    self:registerClickEvent(activeBtn, function ()
        self._fogTipLab:setString("")
        activeBtn:setVisible(false)
        local mapList = self._guildMapModel:getData().mapList
        local thisTarget = mapList[self._targetId]
        if thisTarget == nil then 
            self._viewMgr:showTip("建筑不存在")
            self:close()
            return
        end
        local thisEle = thisTarget.guild
        if thisEle ~= nil and thisEle.haduse ~= nil and tonumber(thisEle.haduse) >= 1 then 
            self._viewMgr:showTip("建筑已激活")
            self:close()
            return
        end
        self:acGuildTower()
    end)  
    
end


--[[
--! @function onInit10
--! @desc 传送门 初始化
--! @return 
--]]
function GuildMapSecondEventView:onInit10()
    local mapList = self._guildMapModel:getData().mapList
    local thisTarget = mapList[self._targetId]
    if thisTarget == nil  then 
        self:closeInit()
        self._viewMgr:showTip("数据不匹配")
        return
    end    
    local thisEle = thisTarget.common

    local closeBtn = self:getUI("event10.bg.closeBtn")
    self:registerClickEvent(closeBtn, function ()
        self:close(true)
    end)

    if thisEle == nil or next(thisEle) == nil then 
        self:closeInit()
        self._viewMgr:showTip("数据不匹配")
        return
    end

    local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
    local guildList = self._guildMapModel:getData().guildList
    local currentGuildId = self._guildMapModel:getData().currentGuildId
    local j = 0 
    for k,v in pairs(guildList) do
        if tostring(k) ~= tostring(currentGuildId) then
            j = j + 1

            --联盟名
            local guildLab1 = self:getUI("event10.bg.rightBg.guild" .. j .. ".guildLab")
            guildLab1:setString(guildList[k].name)
            guildLab1:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
            guildLab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

            --选中
            local guildSelect = self:getUI("event10.bg.rightBg.guild" .. j .. ".guildIcon")
            guildSelect:setVisible(false)

            --背景图
            local tempJ = j
            local guildBg = self:getUI("event10.bg.rightBg.guild" .. j .. ".guildBg")

            --自己/敌方
            local isMyself = self:getUI("event10.bg.rightBg.guild" .. j .. ".isM")
            if tostring(guildId) == tostring(k) then 
                isMyself:loadTexture("guildMapUI_door_mine1.png", 1)
                guildBg:loadTexture("guildMapUI_door_mine.png", 1)
            else
                isMyself:loadTexture("guildMapUI_door_enemy1.png", 1)
                guildBg:loadTexture("guildMapUI_door_enemy.png", 1)
            end

            self:registerClickEvent(guildBg, function ()
                if self._curSelectGuildIndex ~= nil then 
                    local guildSelect1 = self:getUI("event10.bg.rightBg.guild" .. self._curSelectGuildIndex .. ".guildIcon")
                    guildSelect1:setVisible(false)
                    local guildBgSelect = self:getUI("event10.bg.rightBg.guild" .. self._curSelectGuildIndex .. ".guildBg")
                    if guildBgSelect.anim ~= nil then
                        guildBgSelect.anim:setVisible(false)
                    end
                end

                local guildSelect2 = self:getUI("event10.bg.rightBg.guild" .. tempJ .. ".guildIcon")
                guildSelect2:setVisible(true)
                if guildBg.anim ~= nil then
                    guildBg.anim:setVisible(true)
                end

                self._curSelectGuildIndex = tempJ
                self._curSelectGuildId = k
            end)

            --特效
            local animNode = ccui.Layout:create()
            animNode:setContentSize(cc.size(70, 70))
            animNode:setAnchorPoint(cc.p(0.5, 0.5))
            animNode:setPosition(guildBg:getContentSize().width/2 + 14, guildBg:getContentSize().height/2 - 20)
            animNode:setVisible(false)
            guildBg:addChild(animNode)
            guildBg.anim = animNode

            local anim = mcMgr:createViewMC("chuansongmenlan_intanceportal", true)
            anim:setPosition(animNode:getContentSize().width/2, animNode:getContentSize().height/2)
            animNode:addChild(anim)

            --联盟旗子
            local param = {flags = guildList[k].avatar1 or 101, logo = guildList[k].avatar2 or 201}
            local guildIconBg = self:getUI("event10.bg.rightBg.guild" .. j .. ".guildIconBg")
            if guildIconBg then
                avatarIcon = IconUtils:createGuildLogoIconById(param)
                avatarIcon:setScale(0.75)
                guildIconBg:addChild(avatarIcon)
            end

            --任务提示
			local hasTask = false
            local task = self:getUI("event10.bg.rightBg.guild" .. j .. ".task")   --guildIconBg1
            task:setVisible(false)
            local goGuildName = self._guildMapModel:getPassGuildName()

            local taskType = GuildConst.TASK_TYPE.GUILD_MAP_ST_FIND_XUEZHE
            local taskId = self._guildMapModel:getTaskIdByStatis(taskType)
            local taskState = self._guildMapModel:getTaskStateById(taskId)
            if goGuildName == guildList[k].name and taskState == 1 then
				hasTask = true
                task:setVisible(true)
                local taskName = task:getChildByName("tip2")
                taskName:setString(lang(tab.guildMapTask[taskId]["name"]))
            end
			
			--军需官
			local officerTask = self:getUI("event10.bg.rightBg.guild"..j..".officerTask")
			officerTask:setVisible(false)
			local officerGuildId = self._guildMapModel:getOfficerTargetGuildId()
			local officerGuildName = ""
			if officerGuildId and officerGuildId~=0 then
				officerGuildName = self._guildMapModel:getPassGuildName(officerGuildId)
			end
			if officerGuildName == guildList[k].name then
				officerTask:setVisible(true)
				local nameLab = officerTask:getChildByName("officerTip")
				nameLab:setString("军需官")
				if not hasTask then
					officerTask:setPositionY(officerTask:getPositionY() - officerTask:getContentSize().height )
				end
			end
            
            --传送btn
            local transferBtn = self:getUI("event10.bg.transferBtn")
            self:registerClickEvent(transferBtn, function ()
                if self._curSelectGuildId == nil then 
                    self._viewMgr:showTip(lang("GUILDMAPTIPS_12"))
                    return
                end
                self:passPortal(self._curSelectGuildId)
                end)
            
        end
    end    
end



--[[
--! @function onInit17
--! @desc 地图内传送 初始化
--! @return 
--]]
function GuildMapSecondEventView:onInit17()
    local mapList = self._guildMapModel:getData().mapList
    local thisTarget = mapList[self._targetId]
    if thisTarget == nil then 
        self:closeInit()
        self._viewMgr:showTip("数据不匹配")
        return
    end
    local thisEle = mapList[self._targetId].common

    local closeBtn = self:getUI("event17.bg.closeBtn")
    self:registerClickEvent(closeBtn, function ()
        self:close(true)
    end)

    if thisEle == nil or next(thisEle) == nil then 
        self:closeInit()
        self._viewMgr:showTip("数据不匹配")
        return
    end

    local infoBg = self:getUI("event17.bg.infoBg")
    infoBg:loadTexture(self._sysGuildMapThing.art1 .. ".png", 1)

    local enterBtn = self:getUI("event17.bg.enterBtn")
    self:registerClickEvent(enterBtn, function ()
        self:skipPos()
    end)
end



function GuildMapSecondEventView:skipPos(inGuildId)
    self._serverMgr:sendMsg("GuildMapServer", "skipPos", {tagPoint = self._targetId}, true, {}, function(result)
        if self._callback ~= nil then 
            self._callback(result)
        end
        self:close()        
    end)
end

function GuildMapSecondEventView:acGuildTower()
    self._serverMgr:sendMsg("GuildMapServer", "acGuildTower", {tagPoint = self._targetId}, true, {}, function(result)
        if result == nil then 
            self._fogTipLab:setString("激活失败,请重试")
            self._fogTipLab:setColor(UIUtils.colorTable.ccColorQuality6)
            self._fogTipLab:disableEffect()
            return
        end
        self._viewMgr:lock(-1)
        self:showActiveAnim(function()
            self._viewMgr:unlock()
            self._fogTipLab:setString("已激活")
            self._fogTipLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
            self._fogTipLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
            if result.code == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_TENT_HAD_AC then 
                return
            end
            local tipLab2 = self:getUI("event13.bg.tipLab2")
            tipLab2:setVisible(true)
            tipLab2:setString((self._actNum + 1))
            if result["reward"] ~= nil then
                DialogUtils.showGiftGet({
                  gifts = result["reward"],
                })
            end            
            
            -- if self._callback ~= nil then 
            --     self._callback(result)
            -- end
        end)
    end)
end


function GuildMapSecondEventView:passPortal(inGuildId)
    self._serverMgr:sendMsg("GuildMapServer", "passPortal", {tagGid = inGuildId, tagPoint = self._targetId}, true, {}, function(result)
        if self._callback ~= nil then 
            self._callback(result)
        end
        self:close()        
    end)
end


function GuildMapSecondEventView:defendCenterCity()
    self._serverMgr:sendMsg("GuildMapServer", "defendCenterCity", {tagPoint = self._targetId}, true, {}, function(result)
        if self._callback ~= nil then 
            self._callback(1, result)
        end
        self:close()        
    end)
end

function GuildMapSecondEventView:getPointInfo()
    self._serverMgr:sendMsg("GuildMapServer", "getPointInfo", {tagPoint = self._targetId}, true, {}, function(result, error)
        dump(result)
        if error ~= 0 then 
            self._viewMgr:showTip("请求数据出错")
            self:close()
            return
        end
        if self.onInit14_1 == nil then
            return
        end
        self:onInit14_1()
    end)
end

--激活动画  by wangyan
function GuildMapSecondEventView:showActiveAnim(inCallback)
    local activeAim = mcMgr:createViewMC("gongxijihuo_lianmengjihuo", false, true)
    activeAim:addCallbackAtFrame(13, function()
        if inCallback ~= nil then
            inCallback()
        end
    end)
    activeAim:setPosition(self:getContentSize().width*0.5, self:getContentSize().height*0.5 + 50)
    self:addChild(activeAim, 1000000)
end



function GuildMapSecondEventView:closeInit()
    self:setVisible(false)
    self._viewMgr:lock(-1)
    ScheduleMgr:delayCall(0, self, function ()
        self._viewMgr:unlock()
        if self._closePopCallback ~= nil then 
            self._closePopCallback(self.parentView)
        end
        if self.close ~= nil then
            self:close(true)
        end
    end)
end
return GuildMapSecondEventView


