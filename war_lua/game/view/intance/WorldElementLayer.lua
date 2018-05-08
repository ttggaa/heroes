--[[
    Filename:    WorldElementLayer.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-10-27 16:55:46
    Description: File description
--]]

local WorldElementLayer = class("WorldElementLayer", BaseLayer)

local qipaoIdList = {22008, 22009,20008,20009,20010,20011,20012} -- 需展示活动气泡列表

--[[
 @desc  创建
 @param inParent 上层界面
 @return 
--]]
function WorldElementLayer:ctor(inParam)
    WorldElementLayer.super.ctor(self)

    self._parentView1 = inParam.parent
    self._showType = inParam.showType or 1
    self._callBck = inParam.callBack
    self._target = inParam.target
    self._barState = 0
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("intance.WorldElementLayer")
            self:onExit()
        elseif eventType == "enter" then 
            self:onEnter()
        end
    end)
end

function WorldElementLayer:onExit()

end

function WorldElementLayer:onEnter() 

end

function WorldElementLayer:onInit()

    local mainViewModel = self._modelMgr:getModel("MainViewModel")
    local worldTips = mainViewModel:getWorldTipsQipao()
    self._worldTips = {}
    for k,v in pairs(worldTips) do
        self._worldTips[v.qipao] = v
    end

    for i=1,2 do
        local quickBg = self:getUI("quickBg"  .. i)
        quickBg:setVisible(false)
    end

    self._pvpBtn = self:getUI("leftBtnBg.pvpBtn")
    self._intanceBtn = self:getUI("leftBtnBg.intanceBtn")
    
    local scaleBg = self:getUI("scaleBg")
    if self._showType == 1 then
        self._curSelectedName = "intanceBtn"
        scaleBg:setVisible(false)
    else
        self._curSelectedName = "gvgBtn"
        scaleBg:setVisible(false)
    end

    local quickBg = self:getUI("quickBg1")
    quickBg:setVisible(true)

    local tempImg = self:getUI("quickBg1.Image_41")
    tempImg:setVisible(false)

    registerClickEvent(self:getUI("quickBg1.mainBtn"), function()
        if self._parentView1 ~= nil and self._parentView1.getLockTouch ~= nil and  self._parentView1:getLockTouch() == true then return end
        ViewManager:getInstance():returnMain()
    end)
    self._widget:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    if ADOPT_IPHONEX and not self.isPopView and not self.dontAdoptIphoneX then
        if self.fixMaxWidth then
            self._widget:setContentSize((MAX_SCREEN_WIDTH >= self.fixMaxWidth) and self.fixMaxWidth or MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        else
            self._widget:setContentSize(MAX_SCREEN_WIDTH - 120, MAX_SCREEN_HEIGHT)
            self._widget:setPosition(self._widget:getPositionX()+60, self._widget:getPositionY())
        end
    end
    self._scalePoints = {5, 170}


    self._scaleBg = self:getUI("scaleBg")
    -- self._scaleBg:setVisible(false)
    self._scaleBg:setCascadeOpacityEnabled(true, true)

    self._scaleBg:setOpacity(0)

    self._curScaleNum = self:getUI("scaleBg.scalePointImg")
    self._curScaleNum:setAnchorPoint(cc.p(0, 0.5))
    self._curScaleNum:setPosition(cc.p(self._scalePoints[1], self._curScaleNum:getPositionY()))

    

    local gvgBtn = self:getUI("leftBtnBg.gvgBtn")
    local pvpBtn = self:getUI("leftBtnBg.pvpBtn")
    local intanceBtn = self:getUI("leftBtnBg.intanceBtn")
    local opacityBtn = {gvgBtn, pvpBtn, intanceBtn}
    for j,h in pairs(opacityBtn) do
        local nameBg = h:getChildByName("nameBg")
        local title = nameBg:getChildByName("title")
        title:enableOutline(cc.c4b(60, 30, 10,255), 1)

        local opacityEf = h:getChildByName("opacityEf")
        opacityEf:setBrightness(-50)
        opacityEf:setSaturation(-60)
        opacityEf:setOpacity(50)
        opacityEf:setVisible(false)
        h.opacityEf = opacityEf
        h.unActive = function(sender)
            local nameBg = h:getChildByName("nameBg")
            nameBg:setBrightness(-50)
            nameBg:setSaturation(-60)
            sender.opacityEf:setVisible(true)
        end
        h.active = function(sender)
            local nameBg = h:getChildByName("nameBg")
            nameBg:setVisible(true)
            nameBg:setBrightness(0)
            nameBg:setSaturation(0)            
            sender.opacityEf:setVisible(false)
        end        
    end

    self:resetLeftBtnState()
    self._extendInfo = {}
    print("self._showType============================================", self._showType)
    if self._showType == 1 then
        self._extendInfo = {
            {"world_cloudcity_btn",    "world_cloudcity_btn1.png",       lang("WORLD_YUNZHONGCHENG"),        "cloudcity.CloudCityView", "CloudCity"},
            {"world_mf_btn",         "world_mf_btn1.png",        lang("WORLD_CHUANWU"),         "MF.MFView", "MF"},
            {"world_elite_btn",    "world_elite_btn1.png",       lang("WORLD_DIXIACHENG"),        "intance.IntanceEliteView", "Elite"},   
            {"world_guild_btn",    "world_guild_btn1.png",       lang("WORLD_LIANMENGTANSUO"),        function()
                local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
                if guildId == nil or guildId == 0 then 
                    local param = {indexId = 9}
                    self._viewMgr:showDialog("global.GlobalPromptDialog", param)
                    return
                end
                self._viewMgr:showView("guild.map.GuildMapView")
            end, "GuildMap"},
            {"world_element_btn",    "world_element_btn1.png",       lang("WORLD_ELEMENT"),        "elemental.ElementalView", "Element"},
            {"world_purgatory_btn",    "world_purgatory_btn1.png",       lang("WORLD_PURGATORY"),        function (  )
                local purModel = self._modelMgr:getModel("PurgatoryModel")
                local open, txt = purModel:isOpenPurgatory()
                if open then
                    self._viewMgr:showView("purgatory.PurgatoryView")
                else
                    self._viewMgr:showTip(txt)
                end
                return
            end, "Purgatory"},     
        }

        if self._modelMgr:getModel("SiegeModel"):isSiegeDailyOpen() then
            table.insert(self._extendInfo, 5,
                {"world_siege_btn",  
                 "world_siege_btn1.png", 
                 lang("WORLD_STEADWICK"),        
                 function()
                    self._viewMgr:showDialog("siegeDaily.SiegeDailySelectView")
                 end, 
                 "CloudCity"
                 })       
        end
    elseif self._showType == 2 then
        self._extendInfo = {
            -- {"world_history_btn",    "world_citybattle_history.png",       "历史战绩",        self._callBck, "Elite",self._target},
            {"world_report_btn",    "globalBtnUI7_guize.png",       "记录",        self._callBck, "CloudCity",self._target},
            {"world_reward_btn",         "globalBtnUI7_jiangli.png",        "奖励",         self._callBck, "MF",self._target},
            -- {"world_rank_btn",    "globalBtnUI7_paihang.png",       "排行",        self._callBck, "Elite",self._target}, 
            {"world_shop_btn",    "globalBtnUI7_shangdian.png",       "商店",        self._callBck, "Elite",self._target}, 
            {"world_guize_btn",    "globalBtnUI7_guize.png",       "规则",        self._callBck, "Elite",self._target},

        }       
    end

    -- 活动气泡
    local qipaoAcList = {}
    for i = 1, #qipaoIdList do
        table.insert(qipaoAcList, tab:Activityqipao(qipaoIdList[i]))
    end

    local param = {}
    param.extendInfo = self._extendInfo
    -- 指定按钮宽度
    param.btnWidth = 82
    -- 预留宽度
    param.reserveWidth = 141
    -- 初始化状态1伸展，0收缩
    param.initState = 1
    -- 初始化风格，按照按钮宽度
    param.style = 1
    param.redTipCallback = function(inBtnName, inBtnNode)
        if inBtnNode:getChildByName(inBtnName .. "qipaoAc") ~= nil then
            inBtnNode:getChildByName(inBtnName .. "qipaoAc"):removeFromParent()
        end
        
        for i = 1, #qipaoAcList do
            local sysAcQipao = qipaoAcList[i]
            if inBtnName == sysAcQipao.btn and self._modelMgr:getModel("MainViewModel"):getHuodongQipao(sysAcQipao.type) then
                if inBtnNode:getChildByName(sysAcQipao.btn .. "qipaoAc") then
                    inBtnNode:getChildByName(sysAcQipao.btn .. "qipaoAc"):removeFromParent()
                end
                local tempQipaoNode = UIUtils:addShowBubble(nil, sysAcQipao)
                tempQipaoNode:setName(sysAcQipao.btn .. "qipaoAc")
                tempQipaoNode:setPosition(sysAcQipao.position[1], sysAcQipao.position[2])
                inBtnNode:addChild(tempQipaoNode, 100)
            end
        end

        if self._worldTips[inBtnName] == nil then return end
        local name = inBtnName .. "qipao"
        if inBtnNode:getChildByName(name) ~= nil then 
            inBtnNode:getChildByName(name):removeFromParent()
        end    

        local worldTip = self._worldTips[inBtnName]
        local sysQiqao = tab:Qipao(worldTip.id)
        if worldTip.callback ~= nil and  worldTip:callback() == true and sysQiqao ~= nil then 
            if inBtnNode:isVisible() then
                local imgRed = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
                imgRed:setName(sysQiqao.btn .. "qipao")
                imgRed:setPosition(inBtnNode:getContentSize().width - 10, inBtnNode:getContentSize().height - 10)
                inBtnNode:addChild(imgRed)
            end
        end
    end
    param.motionCallback = function(inState)
    -- inState 1展开，0收缩

    end
    -- 横向方向1左侧，2右侧
    param.horizontal = 2
    param.fontSize = 16
    self._extendBar = require("game.view.global.GlobalExtendBarNode").new(param)
    local quickBg = self:getUI("quickBg1")
    quickBg:addChild(self._extendBar)
    self._extendBar:setAnchorPoint(1, 0.5)
    self._extendBar:setPosition(quickBg:getContentSize().width, 60)
    self._extendBar:checkLockStateCallback(
        function()
            if self._parentView1 ~= nil and self._parentView1.getLockTouch ~= nil and  self._parentView1:getLockTouch() == true then return false end
            return true
        end)

    --self:initExtendBar()
end

function WorldElementLayer:resetLeftBtnState() 
    print("resetLeftBtnState========================================================")
    local gvgBtn = self:getUI("leftBtnBg.gvgBtn")
    local pvpBtn = self:getUI("leftBtnBg.pvpBtn")
    local intanceBtn = self:getUI("leftBtnBg.intanceBtn")
    self._positionX = intanceBtn:getPositionX()
    self._funOpenList = {
        {intanceBtn, "intance.IntanceView", nil, nil},
        {gvgBtn, "citybattle.CityBattleView", 102,"globalImageUI8_worldMenuTip2"},
        {pvpBtn, "CrossArea", 105, "globalCrossAreaBtn",function()
            return self._modelMgr:getModel("CrossModel"):getCrossMainState() == 1
        end},
    }  
    for i,v in ipairs(self._funOpenList) do
        if v[1].positionX == nil then 
            v[1].positionX = v[1]:getPositionX()
        end
        self:addBtnFunction(v)
    end
    self:initLeftBtnTip()
    self:resetLeftBtnState1()
end

function WorldElementLayer:resetLeftBtnState1() 
    for i,v in ipairs(self._funOpenList) do
        if self._curSelectedName == v[1]:getName() then 
            v[1]:setVisible(false)
        end
    end
    self._pvpBtn:setVisible( not self._intanceBtn:isVisible())

    local intanceBtn = self:getUI("leftBtnBg.intanceBtn")
    local positionX = intanceBtn.positionX
    for i,v in ipairs(self._funOpenList) do
        if v[1]:isVisible() ==  true then
            v[1]:setPositionX(positionX)
            positionX = positionX + v[1]:getContentSize().width + 15
            --蛋疼得红点
            if v[5] then --check red point
                UIUtils.addRedPoint(v[1],v[5]())
            end
        end
    end
    local leftBg = self:getUI("leftBtnBg.leftBg")
    print("positionX==============================================================================", positionX)
    local gap = ADOPT_IPHONEX and 60 or 0
    if positionX < 130  then
        leftBg:setContentSize(130+gap, leftBg:getContentSize().height)
    else
        leftBg:setContentSize(positionX+gap, leftBg:getContentSize().height)
    end
    leftBg:setPositionX(-gap)
    
end

--开服后第一个周五5点开始
function WorldElementLayer:getGvgFirstOpenTime()
    local userModel = self._modelMgr:getModel("UserModel")
    local userData = userModel:getData()

    local serverNowTime = userModel:getCurServerTime()
    print("userData.sec_open_time",userData.sec_open_time)
    -- userData.sec_open_time = 1498511281
    local t = TimeUtils.date("*t", userData.sec_open_time)
    local time_ = userData.sec_open_time
    if t.hour < 5 then
        local day = userData.sec_open_time - 86400
        t = TimeUtils.date("*t", day)
        time_ = day
    end
    local openTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(time_,"%Y-%m-%d 5:00:00"))
    -- local openTime = os.time({year = t.year, month = t.month, day = t.day, hour = 5, min = 0, sec = 0})
    local time1 = openTime + 19*86400
    print("time1 ====",time1)
    local week = tonumber(TimeUtils.date("%w",time1))
    local add = 0
    -- dump(t1)
    if week == 0 then
        add =  5 * 86400
    elseif week <= 5 then
        add = (5-week)*86400
    else
        add = 6 * 86400
    end
    local finalTime = time1 + add
    print("finalTime================>>>>>>>>>>>>>>>>>",finalTime)
    return finalTime
end

--[[
    判断是否处于周五4:55 ~ 5:10分的区间内
]]
function WorldElementLayer:checkCitybattleServerEnable()
    local userModel = self._modelMgr:getModel("UserModel")
    local serverNowTime = userModel:getCurServerTime()
    local t = TimeUtils.date("*t", serverNowTime)
    if tonumber(t.wday) ~= 6 then
        return
    end
    local time1 = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverNowTime,"%Y-%m-%d 4:55:00"))
    local time2 = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverNowTime,"%Y-%m-%d 5:10:00"))
    -- local time1 = os.time({year = t.year, month = t.month, day = t.day, hour = 4, min = 55, sec = 0})
    -- local time2 = os.time({year = t.year, month = t.month, day = t.day, hour = 5, min = 10, sec = 0})
    if serverNowTime >= time1 and serverNowTime < time2 then
        return true
    end
    return false
end


function WorldElementLayer:addBtnFunction(data) 
    print("addBtnFunction=========================================")  
    local btn = data[1]
    local viewName = data[2]
    local systemName = data[3]
    local btnpic = data[4]
    local param = data[5]

    local isOpen = 1
    local showTip = ""
    local subTime = 0
    if systemName then
        local openTab = tab:STimeOpen(systemName)
        if openTab ~= nil then 
            local userModel = self._modelMgr:getModel("UserModel")
            local openLvl = openTab.level
            local userData = userModel:getData()
            local userLvl = userData.lvl
            if openLvl > userLvl then
                isOpen = -1
                showTip = lang(openTab.systemOpenTip)
            end
            local openTime = openTab.opentime
            local openHour = openTab.openhour
            local serverBeginTime = userData.sec_open_time or 0
            local serverHour = tonumber(TimeUtils.date("%H",serverBeginTime)) or 0
            local nowTime = userModel:getCurServerTime()
            local openDay = openTime-1
            local openHourStr = string.format("%02d:00:00",openHour)
            local openTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime + openDay*86400,"%Y-%m-%d " .. openHourStr))
            if tonumber(systemName) == 102 then
                openTime = self:getGvgFirstOpenTime()
                if self:checkCitybattleServerEnable() then
                    isOpen = -1
                    showTip = lang("CITYBATTLE_TIP_33")
                end
            end
            if nowTime < openTime then
                isOpen = -2
                showTip = lang(openTab.systemTimeOpenTip)
                subTime = openTime - nowTime
            end
        end
    end 


    btn.noSound = true
    btn:setScaleAnim(true)
    local touchX, touchY = 0, 0

    registerClickEvent(btn ,function()
        if self._parentView1 ~= nil and self._parentView1.getLockTouch ~= nil and self._parentView1:getLockTouch() == true then return end
        if self._curSelectedName == btn:getName() then return end 
        if viewName == "CrossArea" then
            local state = self._modelMgr:getModel("CrossModel"):getOpenActionState()
            if state == 1 then
                self._viewMgr:showTip(lang("cp_tips_openday"))
            elseif state == 2 then
                self._viewMgr:showTip(lang("cp_tips_openlv"))
            elseif state == 3 then
                self._viewMgr:showTip(lang("cp_tips_openlv"))
            elseif state == 4 then
                UIUtils:reloadLuaFile("cross.CrossMainView")
                self._viewMgr:showView("cross.CrossMainView", {})
            elseif state == 5 then
                self._viewMgr:showTip(lang("cp_tips_maintain"))
            elseif state == 6 then
                self._viewMgr:showTip(lang("cp_tips_clickicon"))
            elseif state == 0 then
                self._viewMgr:showTip(lang("cp_tips_maintain"))
            end
        elseif viewName ~= nil and string.len(viewName) > 0 then
            self._viewMgr:showView(viewName, param)
        else
            self._viewMgr:showTip("暂未开放")
        end
    end)

    btn:active()
    if isOpen < 1 and not GameStatic.openAllSystem then 
        btn:setEnabled(false)
        if btn.title ~= nil then
            btn.title:setVisible(false)  
        end
        btn:unActive()
        if viewName == "citybattle.CityBattleView" or viewName == "CrossArea" then
            btn:setEnabled(true)
            registerClickEvent(btn ,function()
                if string.len(showTip) > 0 then
                    self._viewMgr:showTip(showTip)
                end
            end)
            if isOpen == -2 and subTime > 0 then
                local nameBg = btn:getChildByName("nameBg")
                nameBg:stopAllActions()
                nameBg:runAction(
                    cc.RepeatForever:create(
                        cc.Sequence:create(
                            cc.DelayTime:create(subTime), 
                            cc.CallFunc:create(
                                function()
                                    self:addBtnFunction(data)
                                end
                            )
                        )
                    )
                )
  
            end
        else
            btn:setTouchEnabled(false)
        end
    end
    if viewName == nil or string.len(viewName) <= 0 then
        local whiteTitle = cc.Sprite:createWithSpriteFrameName("world_not_open.png")
        whiteTitle:setPosition(btn:getContentSize().width * 0.5, btn:getContentSize().height * 0.5 + 15)
        btn:addChild(whiteTitle, 10)        
        btn:unActive()
        -- btn.whiteTitle:setVisible(true)
    end
end


function WorldElementLayer:runScale(inScale, inMinScale, inMaxScale)
    if self._scaleBg.isOpen == false then return end
    local percentScale = (inScale - inMinScale) / (inMaxScale - inMinScale)
    local newX = percentScale * (self._scalePoints[2] - self._scalePoints[1])
    self._curScaleNum:setPosition(cc.p(self._scalePoints[1] + newX, self._curScaleNum:getPositionY()))
    if tostring(percentScale) ~= "0.5" then 
        -- self._scaleBg:setVisible(true)
        self._scaleBg:runAction(cc.FadeIn:create(0.5))
    else
        -- self._scaleBg:setVisible(false)
        self._scaleBg:runAction(cc.FadeOut:create(0.5))
    end
end

function WorldElementLayer:standByFirstEnterAction()
    local quickBg = self:getUI("quickBg1")
    local leftBtnBg = self:getUI("leftBtnBg")
    local scaleBg = self:getUI("scaleBg")
    scaleBg.isOpen = false
    local children = leftBtnBg:getChildren()
    for k,v in pairs(children) do
        v.positionX = v:getPositionX()
        v:setPositionX(v:getPositionX() - 250)
    end

    local mainBtn = self:getUI("quickBg1.mainBtn")
    mainBtn:setVisible(false)
    local tempImg = self:getUI("quickBg1.Image_41")
    tempImg:setVisible(true)
    local children = quickBg:getChildren()
    for k,v in pairs(children) do
        if v:getName() ~= "mainBtn" then
            v.positionX = v:getPositionX()
            v:setPositionX(v:getPositionX() + 250)
        end
    end    

    local children = scaleBg:getChildren()
    for k,v in pairs(children) do
        v.positionX = v:getPositionX()
        print("v:getName()=",v:getName(), v.positionX)
        
        v:setPositionX(v:getPositionX() + 250)
    end

end

function WorldElementLayer:runFirstEnterAction()
    local quickBg = self:getUI("quickBg1")
    local leftBtnBg = self:getUI("leftBtnBg")
    local scaleBg = self:getUI("scaleBg")
    
    local children = leftBtnBg:getChildren()
    for k,v in pairs(children) do
        v:runAction(
            cc.Sequence:create(
                cc.MoveTo:create(0.2, cc.p(v.positionX + 10, v:getPositionY())),
                cc.MoveTo:create(0.2, cc.p(v.positionX, v:getPositionY()))  
                ))
    end


    local children = quickBg:getChildren()
    for k,v in pairs(children) do
        if v:getName() ~= "mainBtn" then
            v:runAction(
                cc.Sequence:create(
                    cc.MoveTo:create(0.2, cc.p(v.positionX - 10, v:getPositionY())),
                     cc.MoveTo:create(0.2, cc.p(v.positionX, v:getPositionY()))  
                    ))
        end
    end    
    local mainBtn = self:getUI("quickBg1.mainBtn")
    local tempImg = self:getUI("quickBg1.Image_41")
    mainBtn:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(0.4), 
            cc.CallFunc:create(
                function()
                    mainBtn:setLocalZOrder(10000)
                    mainBtn:setVisible(true)
                    tempImg:setVisible(false)
                    scaleBg.isOpen = true
                end)
            )
        )
    scaleBg:setOpacity(255)
    local children = scaleBg:getChildren()
    for k,v in pairs(children) do
        print("v:getName()=",v:getName(), v.positionX)
        v:runAction(
            cc.Sequence:create(
                cc.MoveTo:create(0.2, cc.p(v.positionX - 10, v:getPositionY())),
                cc.MoveTo:create(0.2, cc.p(v.positionX, v:getPositionY()))  
                ))
    end      
end



-- -- 根据等级开放, 重新排列按钮位置
-- function WorldElementLayer:updateExtendBar()
--     local anim_W = 10 -- 动画预留
--     local button_W = 92 -- 每个按钮的宽度

--     self._extendVisibleBtns = {}
--     for i = 1, #self._extendInfo do
--         local info = self._extendInfo[i]
--         self._extendBtns[i]:setVisible(false)
--         local systemName = info[5]
--         if systemName then
--             local _, show = SystemUtils["enable"..systemName]() 
--             print("_, show===========", _, show, systemName)
--             if show then
--                 self._extendVisibleBtns[#self._extendVisibleBtns + 1] = self._extendBtns[i]
--             end
--         else
--             self._extendVisibleBtns[#self._extendVisibleBtns + 1] = self._extendBtns[i]
--         end
--     end

--     self._extendBarAniming = false -- 是否在动画中

--     self._extendBtn:setRotation(0)
--     self._extendBtn:stopAllActions()
--     local count = #self._extendVisibleBtns
--     local width = 171 + anim_W + button_W * count
--     self._extendBg:setContentSize(width, 90)

--     self._extendBg.___extendPosY = self._extendBg:getPositionY()
    

--     if #self._extendVisibleBtns == 0 then
--         self._extendBtn:setSaturation(-100)
--         self._extendBtn:setTouchEnabled(false)
--     else
--         self._extendBtn:setSaturation(0)
--         self._extendBtn:setTouchEnabled(true)
--     end 

--     self._extendBg.___extendPosX = 190 + anim_W
--     self._extendBg.___extendPosX2 = self._extendBg.___extendPosX + (button_W * count)
--     if self._barState == 2 then 
--         self._extendBg:setPositionX(self._extendBg.___extendPosX2)
--         self._extendBarIsExtend = false -- 是否处于拓展状态
--         for i = 1, #self._extendVisibleBtns do
--             local btn = self._extendVisibleBtns[i]
--             btn:setVisible(true)
--             btn:setOpacity(0)
--             btn.___extendPosX = (i - 1) * button_W + 75
--             btn.___extendPosY = 55        
--             btn:setPosition(btn.___extendPosX + 500, 55)
--         end
--     else
--         self._extendBarIsExtend = true -- 是否处于拓展状态
--         self._extendBg:setPositionX(190 + anim_W)

--         for i = 1, #self._extendVisibleBtns do
--             local btn = self._extendVisibleBtns[i]
--             btn:setVisible(true)
--             btn:setOpacity(255)
--             btn:setPosition((i - 1) * button_W + 75, 55)
--             btn.___extendPosX = (i - 1) * button_W + 75
--             btn.___extendPosY = 55        
--         end
--     end   
-- end

-- 初始化伸缩条
function WorldElementLayer:initExtendBar()
    local count = #self._extendInfo
    self._extendBtns = {}
    self._extendVisibleBtns = {}
    for i = 1, count do
        local info = self._extendInfo[i]
        local btn = ccui.Button:create(info[2], info[2], info[2], 1)
        btn:setCascadeOpacityEnabled(true)
        btn:setName(info[1])
        
        local label = cc.Label:createWithTTF(info[3], UIUtils.ttfName, 30)
        label:setColor(UIUtils.colorTable.ccUIMenuBtnColor1)
        label:enable2Color(1, UIUtils.colorTable.ccUIMenuBtnColor2)
        label:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        btn:addChild(label)

        label:setPosition(btn:getContentSize().width * 0.5, (btn:getContentSize().height - 79) * 0.5 + 6)
 

        self:registerClickEvent(btn, function ()
            self._viewMgr:lock(-1)
            ScheduleMgr:delayCall(75, self, function()
                if type(info[4]) == "function" then
                    info[4]()
                    self._viewMgr:unlock()
                else
                    self._viewMgr:showView(info[4])
                    self._viewMgr:unlock()
                end
            end)
        end)

        self._extendBg:addChild(btn)
        self._extendBtns[i] = btn
    end

    self:registerClickEvent(self._extendBtn, function ()
        self:doExtendBarAnim()
    end)

    self:updateExtendBar()
end


function WorldElementLayer:initLeftBtnTip()
    self._worldTipRichText = nil
    local mainViewModel = self._modelMgr:getModel("MainViewModel")
    local worldTips = mainViewModel:getWorldTipsQipao()
    for k,v in pairs(self._funOpenList) do
        local name = v[1]:getName() .. "qipao"
        if v[1]:getChildByName(name) ~= nil then 
            v[1]:getChildByName(name):removeFromParent()
        end
    end

    for i=1, #worldTips do
        if worldTips[i].callback ~= nil and  worldTips[i]:callback() == true then 
            local sysQiqao = tab:Qipao(worldTips[i].id)
            if sysQiqao ~= nil then 
                local tempBtn = self:getUI("leftBtnBg." .. sysQiqao.btn)
                local tempQipaoNode = UIUtils:addShowBubble(nil, sysQiqao)
                if tempBtn ~= nil and tempBtn:isVisible() == true and tempQipaoNode ~= nil then
                    tempQipaoNode:setName(sysQiqao.btn .. "qipao")
                    tempBtn:addChild(tempQipaoNode, 100)
                    break 
                end
            end
        end
    end

    --更新王国联赛红点
    for i,v in ipairs(self._funOpenList) do
        if v[1]:isVisible() ==  true then
            if v[5] then --check red point
                UIUtils.addRedPoint(v[1],v[5]())
            end
        end
    end
end

-- 根据等级开放, 重新排列按钮位置
function WorldElementLayer:updateExtendBar()
    self._extendBar:updateExtendBar()
end


return WorldElementLayer