--
-- Author: <ligen@playcrab.com>
-- Date: 2017-01-19 20:32:26
--
local HeroDuelMainView = class("HeroDuelMainView", BaseView)
function HeroDuelMainView:ctor()
    HeroDuelMainView.super.ctor(self)
    self.fixMaxWidth = ADOPT_IPHONEX and 1136
    self.initAnimType = 3

    self._kLayerType = {
        ["enterance"] = {name = "heroduel.HeroDuelEnteranceLayer"},
        ["main"] = {name = "heroduel.HeroDuelMainLayer"},
        ["select"] = {name = "heroduel.HeroDuelSelectLayer"}
    }

    -- 当前显示子页面
    self._curLayer = nil

    self._mainData = nil

    self._hModel = self._modelMgr:getModel("HeroDuelModel")
end

function HeroDuelMainView:getBgName()
    return "heroDuelBg.jpg"
end

function HeroDuelMainView:getAsyncRes()
    return
    {
        { "asset/ui/heroDuel.plist", "asset/ui/heroDuel.png" },
        { "asset/ui/heroDuel1.plist", "asset/ui/heroDuel1.png"},
        { "asset/ui/heroDuel2.plist", "asset/ui/heroDuel2.png"},
        { "asset/ui/heroDuel3.plist", "asset/ui/heroDuel3.png"}
    }
end

function HeroDuelMainView:setNavigation()
    if self._curLayer and self._curLayer.lType == "enterance" then
        self._viewMgr:showNavigation("global.UserInfoView",{types= {"Gem","HDuelCoin","3042"},hideHead = true, hideBtn = true},nil,self.fixMaxWidth)
    else
        self._viewMgr:hideNavigation("global.UserInfoView")
    end
end

function HeroDuelMainView:onBeforeAdd(callback, errorCallback)
    self._serverMgr:sendMsg("HeroDuelServer", "hDuelGetMainInfo", {}, true, {}, function(result)

        self._mainData = result
        self:reflashUI(result)

        callback()
    end)
end


function HeroDuelMainView:onComplete()
    self._viewMgr:enableScreenWidthBar()
end

function HeroDuelMainView:onInit()
    self._isShowActivity, self._needUpdate = self:getIsActivityOpen()

    self._closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(self._closeBtn, function()
        self:hideLayer(self._curLayer)
        self:close()
        UIUtils:reloadLuaFile("heroduel.HeroDuelMainView")
        UIUtils:reloadLuaFile("heroduel.HeroDuelEnteranceLayer")
        UIUtils:reloadLuaFile("heroduel.HeroDuelMainLayer")
        UIUtils:reloadLuaFile("heroduel.HeroDuelSelectLayer")
    end )

    local bg = self:getUI("bg")
    local bgNode = bg:getChildByFullName("bgNode")
    self._bgLeft = bgNode:getChildByFullName("bgLeft")
    self._bgRight = bgNode:getChildByFullName("bgRight")
    self._bgFeature = bg:getChildByFullName("bgFeature")
    self._bgFeature:setCascadeOpacityEnabled(true)

    self._bgActivity = bg:getChildByFullName("bgActivity")

    if self._needUpdate then
        self._timerId = ScheduleMgr:regSchedule(60000,self,function( )
            local isShow, needUpdate = self:getIsActivityOpen()
            if isShow ~= self._isShowActivity then
                self._bgActivity:setVisible(isShow and self._curLayer ~= nil and self._curLayer.lType ~= "select")

                if self._curLayer.lType == "main" then
                    trycall("setGiveUpBtnPos", self._curLayer.setGiveUpBtnPos, self._curLayer, self:getIsActivityOpen())
                end
            end

            if not needUpdate then
                if self._timerId then
                    ScheduleMgr:unregSchedule(self._timerId)
                end
            end
        end)
    end

    local featureId = tab:HeroDuel(self._hModel:getWeekNum()).char1
    local featurePath = tab:HeroDuelSelect(featureId).image1
    self._bgFeature:loadTexture(featurePath .. ".png", 1)

    self._bgLeft:setScaleY(MAX_SCREEN_HEIGHT/MAX_DESIGN_HEIGHT)
    self._bgRight:setScaleY(MAX_SCREEN_HEIGHT/MAX_DESIGN_HEIGHT)

    local seasonLabel = self._bgFeature:getChildByFullName("seasonLabel")
    seasonLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    -- 赛季时间
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local year = tonumber(TimeUtils.date("%Y",nowTime))
    local month = TimeUtils.date("%m",nowTime)
    local daySum = TimeUtils.getDaysOfMonth(nowTime)
    seasonLabel:setString(year.."."..month..".01~"..year.."."..month.."."..daySum)

    self:registerClickEvent(self._bgFeature, function()
        self._viewMgr:showDialog("heroduel.HeroDuelFeatureView")
    end)

    self:registerClickEvent(self._bgActivity, function()
        self._viewMgr:showDialog("heroduel.HeroDuelActivityView")
    end)

    self._viewLayer = self:getUI("bg.layer")

    local fireMc = mcMgr:createViewMC("jiaofenghuoyan_duizhanui", true, false)
    fireMc:setPosition(508, 320)
    bgNode:addChild(fireMc)

    self._leftMenuNode = self:getUI("bg.bgNode.leftMenuNode")
    self._leftMenuNode:setCascadeOpacityEnabled(true)
    self._rightMenuNode = self:getUI("bg.bgNode.rightMenuNode")
    self._rightMenuNode:setCascadeOpacityEnabled(true)

    self._cardBagNode = self:getUI("bg.bgNode.cardBagNode")
    self._cardBagNode:setCascadeOpacityEnabled(true)

    self._classLabelList = {}
    self._classLabelList[1] = self._cardBagNode:getChildByFullName("gongLabel")
    self._classLabelList[2] = self._cardBagNode:getChildByFullName("fangLabel")
    self._classLabelList[3] = self._cardBagNode:getChildByFullName("tuLabel")
    self._classLabelList[4] = self._cardBagNode:getChildByFullName("sheLabel")
    self._classLabelList[5] = self._cardBagNode:getChildByFullName("moLabel")

    self._classLabelList[1]:setColor(UIUtils.colorTable.ccUIBaseColor6)
    self._classLabelList[2]:setColor(UIUtils.colorTable.ccUIBaseColor5)
    self._classLabelList[3]:setColor(UIUtils.colorTable.ccUIBaseColor3)
    self._classLabelList[4]:setColor(UIUtils.colorTable.ccUIBaseColor2)
    self._classLabelList[5]:setColor(UIUtils.colorTable.ccUIBaseColor4)

    self:registerClickEvent(self._cardBagNode, function()
        self._viewMgr:showDialog("heroduel.HeroDuelCardsCheckView")
    end)

    -- 适配
    if MAX_SCREEN_WIDTH < 1136 then
--        self._bgLeft:setVisible(false)
--        self._bgRight:setVisible(false)
--        self._bgFeature:setPositionX(self._bgFeature:getContentSize().width * 0.5 - 1)
--        self._cardBagNode:setPositionX(MAX_DESIGN_WIDTH*0.5-218)
--        self._rightMenuNode:setPositionX(MAX_DESIGN_WIDTH-343)

--        local leftList = self._leftMenuNode:getChildren()
--        local offsetX = (1136 - MAX_SCREEN_WIDTH) * 0.5
--        for lI = 1, #leftList do
--            leftList[lI]:setPositionX(leftList[lI]:getPositionX() - (35+lI*10))
--        end

--        local rightList = self._rightMenuNode:getChildren()
--        for rI = 1, #rightList do
--            dump(rightList[rI]:getPositionX() + (35- (#rightList-rI)*10))
--            rightList[rI]:setPositionX(rightList[rI]:getPositionX() + (45 + (#rightList-rI)*10))
--        end
    end

--    self._bgFeature:setPositionX(self._bgFeature:getPositionX() + (1136 - MAX_SCREEN_WIDTH)*0.5)
--    self._closeBtn:setPositionX(self._closeBtn:getPositionX() + (MAX_SCREEN_WIDTH - 1136)*0.5)
    self._leftMenuNode:setPositionY((MAX_DESIGN_HEIGHT - MAX_SCREEN_HEIGHT)*0.5)
    self._rightMenuNode:setPositionY((MAX_DESIGN_HEIGHT - MAX_SCREEN_HEIGHT)*0.5)
    self._cardBagNode:setPositionY((MAX_DESIGN_HEIGHT - MAX_SCREEN_HEIGHT)*0.5 + 17)

    local rankBtn = self._leftMenuNode:getChildByFullName("rankBtn")
    local ruleBtn = self._leftMenuNode:getChildByFullName("ruleBtn")
    local reportBtn = self._leftMenuNode:getChildByFullName("reportBtn")
    local analyzeBtn = self._rightMenuNode:getChildByFullName("analyzeBtn")
    local rewardBtn = self._rightMenuNode:getChildByFullName("rewardBtn")
    local shopBtn = self._rightMenuNode:getChildByFullName("shopBtn")

    local recommendBtn = self._leftMenuNode:getChildByFullName("recommendBtn")
    UIUtils:addFuncBtnName(recommendBtn, "阵容推荐", cc.p(rankBtn:getContentSize().width/2, -3), true, 18)

    UIUtils:addFuncBtnName(rankBtn, "排行", cc.p(rankBtn:getContentSize().width/2, -3), true, 18)
    UIUtils:addFuncBtnName(ruleBtn, "规则", cc.p(ruleBtn:getContentSize().width/2, -3), true, 18)
    UIUtils:addFuncBtnName(reportBtn, "精彩对局", cc.p(reportBtn:getContentSize().width/2, -3), true, 18)
    
    UIUtils:addFuncBtnName(analyzeBtn, "统计", cc.p(analyzeBtn:getContentSize().width/2, -3), true, 18)
    UIUtils:addFuncBtnName(rewardBtn, "累计奖励", cc.p(rewardBtn:getContentSize().width/2, -3), true, 18)
    UIUtils:addFuncBtnName(shopBtn, "商店", cc.p(shopBtn:getContentSize().width/2, -3), true, 18)

    self:registerClickEvent(recommendBtn, function()
        local rankModel = self._modelMgr:getModel("RankModel")
        rankModel:setRankTypeAndStartNum(rankModel.kRankDuelRecommend1, 1)
        self._serverMgr:sendMsg("RankServer", "getRankList", {type = rankModel.kRankDuelRecommend1, startRank = 1}, true, {}, function(result)
            self._viewMgr:showDialog("heroduel.HeroDuelRecommendView", {}, true)
        end)
    end)

    -- 排行榜
    self:registerClickEvent(rankBtn, function()
        self._viewMgr:showView("heroduel.HeroduelRankView", {})
    end)

    -- 规则
    self:registerClickEvent(ruleBtn, function()
        self._viewMgr:showDialog("heroduel.HeroDuelRuleView", {data = result})
    end)

    -- 战报
    self:registerClickEvent(reportBtn, function()
        self._serverMgr:sendMsg("HeroDuelServer", "hDuelGetSeasonShow", {}, true, {}, function(result)
            if result == nil or next(result) == nil then
                self._viewMgr:showTip(lang("HERODUEL19"))
                return
            end
            dump(result)
            self._viewMgr:showDialog("heroduel.HeroDuelReportView", {data = result})
        end)
    end)

    -- 数据统计
    self:registerClickEvent(analyzeBtn, function()
        self._serverMgr:sendMsg("HeroDuelServer", "hDuelGetStatis", {}, true, {}, function(result)
            self._viewMgr:showDialog("heroduel.HeroDuelAnalyzeView", {data = result})
        end)
    end)

    -- 累计胜场奖励
    self:registerClickEvent(rewardBtn, function()
        self._serverMgr:sendMsg("HeroDuelServer", "hDuelGetAwardList", {}, true, {}, function(result)
            self._viewMgr:showDialog("heroduel.HeroDuelAwardView", {data = result})
        end)
    end)

    -- 商店
    self:registerClickEvent(shopBtn, function()
        self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = "heroDuel"}, true, {}, function(result)
            -- if result.shop["league"] and  
            --     result.shop["league"].lastUpTime and 
            --     result.shop["league"].lastUpTime > self._nextRefreshTime then 
            --     self._nextRefreshTime = self._shopModel:getShopRefreshTime("league")
            -- end
            self._viewMgr:showDialog("heroduel.HeroduelShopView", {})
        end)
    end)


    self:setOpenQuickDispatch()
    self:setListenReflashWithParam(true)
    self:listenReflash("HeroDuelModel", self.onModelReflash)
    self:listenReflash("ItemModel", self.reflashEnterance)
end

function HeroDuelMainView:reflashUI(data)
    self:updateCardsPanel()

    -- 0:未报名  1:选卡中  2:可匹配  3:可领奖
    if data.status == 0 then
        self:showLayer("enterance", {buyTimes = data.buyTimes, open = data.open, callBack = specialize(self.enterCallBack, self)})
    elseif data.status == 1 then
        self:showLayer("main", {mainData = data, callBack = specialize(self.mainCallBack, self)})

    elseif data.status == 2 then
        self:showLayer("main", {mainData = data, callBack = specialize(self.mainCallBack, self)})

    elseif data.status == 3 then
        self:showLayer("main", {mainData = data, callBack = specialize(self.mainCallBack, self)})

    end
end


function HeroDuelMainView:onModelReflash(eventName)
    if eventName == self._hModel.CARDS_UPDATE then  
        self:updateCardsPanel()

    elseif eventName == self._hModel.HD_DATA_UPDATE then
        if self._curLayer and self._curLayer.lType == "main" then
            local hdData = self._hModel:getHeroDuelData()
            self._curLayer:reflashUI(hdData)
            self._curLayer:onTop()
        end

    elseif eventName == self._hModel.HD_DATA_RESET then
        self._serverMgr:sendMsg("HeroDuelServer", "hDuelGetMainInfo", {}, true, {}, function(result)
            self._mainData = result
            self:reflashUI(result)
        end)

    elseif eventName == self._hModel.HD_CLOSE then
        self._mainData.open = 0
        self._curLayer:onHDuelClose()
    elseif eventName == self._hModel.HD_OPEN then
        self._mainData.open = 1
        self._curLayer:onHDuelOpen()
    end
end

-- 物品更新
function HeroDuelMainView:reflashEnterance()
    if self._curLayer and self._curLayer.lType == "enterance" then
        self._curLayer:reflashUI()
    end
end

-- 更新记牌板数量
function HeroDuelMainView:updateCardsPanel()
    for k, labelV in pairs(self._classLabelList) do
        local cardsCount = self._hModel:getNumByClass(k)
        if cardsCount > tonumber(labelV:getString()) and labelV:getString() ~= "30" then

            local preColor = labelV:getColor()
            labelV:setColor(cc.c3b(255, 255, 255))
            local action = cc.Sequence:create(
                cc.ScaleTo:create(0.1,1.7),
                cc.CallFunc:create(function()
                    labelV:setColor(preColor)
                    labelV:setString(tostring(cardsCount))
                end),
                cc.DelayTime:create(0.1),
                cc.ScaleTo:create(0.3,1)
            )
            labelV:runAction(action)
        else
            labelV:setString(tostring(cardsCount))
        end
    end
end


-- 显示子页面
function HeroDuelMainView:showLayer(lType, param)
    local needPop = false
    if self._curLayer ~= nil then
        needPop = true
    end

    if self._curLayer and self._curLayer.lType == lType then
        
    else

        self:hideLayer(self._curLayer)

        local layerName = self._kLayerType[lType].name

        self._viewMgr:lock(-1)
        self:createLayer(layerName, param, true, function (_layer)
            self._viewMgr:unlock()
            self._curLayer = _layer
            self._curLayer.lType = lType
        end)
        self._viewLayer:addChild(self._curLayer)
        local realWidth = MAX_SCREEN_WIDTH >= 1136 and self.fixMaxWidth or MAX_SCREEN_WIDTH
        self._curLayer:setPosition((realWidth - self._curLayer:getContentSize().width) * 0.5,
            (MAX_SCREEN_HEIGHT - self._curLayer:getContentSize().height) * 0.5)
    end

    self._cardBagNode:setVisible(lType ~= "enterance")
    self._bgActivity:setVisible(lType ~= "select" and self:getIsActivityOpen())
    if lType == "main" then
        trycall("setGiveUpBtnPos", self._curLayer.setGiveUpBtnPos, self._curLayer, self:getIsActivityOpen())
    end

--    self._recommendBtn:setVisible(lType ~= "select")

    if lType == "enterance" then
        self._viewMgr:showNavigation("global.UserInfoView",{types= {"Gem","HDuelCoin","3042"},hideHead = true, hideBtn = true},nil,self.fixMaxWidth)
    else
        self._viewMgr:hideNavigation("global.UserInfoView")
    end

    if needPop and self._curLayer.onShow then
        self._curLayer:onShow()
    end
end

-- 隐藏子页面
-- @param  hLayer 需要隐藏的layer
function HeroDuelMainView:hideLayer(hLayer)
    if hLayer ~= nil then
        if hLayer.onDestroy then
            hLayer:onDestroy()
        end
        hLayer:removeFromParent(true)
    end
end

-- 入场回调
function HeroDuelMainView:enterCallBack(cardsInfo)
    print("入场")
    self._mainData["toSelect"] = cardsInfo["toSelect"]
    self:showLayer("select", {mainData = self._mainData, callBack = specialize(self.selectCallBack, self)})
end

-- mainlayer操作回调
function HeroDuelMainView:mainCallBack(data)
    if data.acType == "continue" then
        self._mainData["toSelect"] = data["toSelect"]
        self:showLayer("select", {mainData = self._mainData, callBack = specialize(self.selectCallBack, self)})
    else

    end
end

-- 选卡结束回调
function HeroDuelMainView:selectCallBack(data)
    self._mainData.status = 2
    self:showLayer("main", {mainData = self._mainData, callBack = specialize(self.mainCallBack, self)})
end

function HeroDuelMainView:showActivityView()
    if self:getIsActivityOpen() and SystemUtils.loadAccountLocalData("showHDuelActivity") ~= 1 then
        self._viewMgr:showDialog("heroduel.HeroDuelActivityView")
    end
end

function HeroDuelMainView:onShow()
    self:playOnShowAni()

    if self._mainData.award ~= nil then
        DialogUtils.showGiftGet({gifts = self._mainData.award, callback = function()
            if self._mainData.popChar == 1 then
                self._viewMgr:showDialog("heroduel.HeroDuelDesView")
            end
        end})
    else
        if self._mainData.popChar == 1 then
            self._viewMgr:showDialog("heroduel.HeroDuelFeatureView", {callBack = specialize(function()
                self:showActivityView()
            end, self)})
        else
            self:showActivityView()
        end
    end

    if self._curLayer and self._curLayer.onShow then
        self._curLayer:onShow()
    end
end

function HeroDuelMainView:onTop()
    self._viewMgr:enableScreenWidthBar()
    print("HeroDuelMainView:onTop")
    if self._curLayer and self._curLayer.onTop then
        self._curLayer:onTop()
    end
end

function HeroDuelMainView:onHide()
    self._viewMgr:disableScreenWidthBar()
    print("HeroDuelMainView:onHide")

end

function HeroDuelMainView:beforePopAnim()
	HeroDuelMainView.super.beforePopAnim(self)

    self._bgLeft:setPositionX(self._bgLeft:getPositionX() - 121)
    self._bgRight:setPositionX(self._bgRight:getPositionX() + 121) 
    self._bgFeature:runAction(cc.MoveBy:create(0.01, cc.p(-60, 0)))
    self._bgActivity:runAction(cc.MoveBy:create(0.01, cc.p(-60, 0)))
    self._closeBtn:runAction(cc.MoveBy:create(0.01, cc.p(121, 0)))
    self._bgLeft:setOpacity(0)
    self._bgRight:setOpacity(0)
    self._bgFeature:setOpacity(0)
    self._bgActivity:setOpacity(0)
    self._closeBtn:setOpacity(0)
--    self._recommendBtn:setOpacity(0)

    self._leftMenuNode:setPositionY(self._leftMenuNode:getPositionY() - 10)
    self._rightMenuNode:setPositionY(self._rightMenuNode:getPositionY() - 10)
    self._cardBagNode:setPositionY(self._cardBagNode:getPositionY() - 10)
    self._leftMenuNode:setOpacity(0)
    self._rightMenuNode:setOpacity(0)
    self._cardBagNode:setOpacity(0)
end

function HeroDuelMainView:playOnShowAni()
    self._bgLeft:runAction(cc.Sequence:create(
        cc.Spawn:create(cc.EaseOut:create(cc.MoveBy:create(0.1, cc.p(121,0)),3), cc.FadeIn:create(0.1)),
        cc.MoveBy:create(0.1, cc.p(-10,0))
    ))

    self._bgFeature:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.1),
        cc.Spawn:create(cc.EaseOut:create(cc.MoveBy:create(0.2, cc.p(65,0)),3), cc.FadeIn:create(0.1)),
        cc.MoveBy:create(0.1, cc.p(-5,0))
    ))

    self._bgActivity:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.1),
        cc.Spawn:create(cc.EaseOut:create(cc.MoveBy:create(0.2, cc.p(65,0)),3), cc.FadeIn:create(0.1)),
        cc.MoveBy:create(0.1, cc.p(-5,0))
    ))

--    self._recommendBtn:runAction(cc.Sequence:create(
--        cc.DelayTime:create(0.3),
--        cc.FadeIn:create(0.1)
--    ))

    self._bgRight:runAction(cc.Sequence:create(
        cc.Spawn:create(cc.EaseOut:create(cc.MoveBy:create(0.1, cc.p(-121,0)),3), cc.FadeIn:create(0.1)),
        cc.MoveBy:create(0.1, cc.p(10,0))
    ))

    self._closeBtn:runAction(cc.Sequence:create(
        cc.Spawn:create(cc.EaseOut:create(cc.MoveBy:create(0.1, cc.p(-131,0)),3), cc.FadeIn:create(0.1)),
        cc.MoveBy:create(0.1, cc.p(10,0))
    ))

    self._leftMenuNode:runAction(cc.Sequence:create(
        cc.Spawn:create(cc.EaseOut:create(cc.MoveBy:create(0.1, cc.p(0,15)),3), cc.FadeIn:create(0.05)),
        cc.MoveBy:create(0.1, cc.p(0,-5))
    ))

    self._rightMenuNode:runAction(cc.Sequence:create(
        cc.Spawn:create(cc.EaseOut:create(cc.MoveBy:create(0.1, cc.p(0,15)),3), cc.FadeIn:create(0.05)),
        cc.MoveBy:create(0.1, cc.p(0,-5))
    ))

    self._cardBagNode:runAction(cc.Sequence:create(
        cc.Spawn:create(cc.EaseOut:create(cc.MoveBy:create(0.1, cc.p(0,15)),3), cc.FadeIn:create(0.05)),
        cc.MoveBy:create(0.1, cc.p(0,-5))
    ))
end

function HeroDuelMainView:addFuncBtnName(btn, label)
    local txt = ccui.Text:create()
    txt:setName("titleName")
    txt:setFontSize(fontSize or 24)
    txt:setFontName(UIUtils.ttfName)
    txt:setString(titleTxt or "")
    txt:setPosition(pos or cc.p(btn:getContentSize().width/2,20))
    txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    btn:addChild(txt,1)

    if hasTextBg then
        local txtBg = ccui.ImageView:create()
        txtBg:loadTexture("globalImageUI11_btnTextBg.png",1)
        txtBg:setPosition(pos or cc.p(btn:getContentSize().width/2,20))
        btn:addChild(txtBg,0)
    end
    return txt
end

-- 判断活动是否开启
function HeroDuelMainView:getIsActivityOpen()
    if self._activityBeginTime == nil then
        local showActivityTime = tab:Setting("DUEL_LIVE_TIME").value
        self._activityBeginTime = os.time({
            year = showActivityTime[1][1], 
            month = showActivityTime[1][2],
            day = showActivityTime[1][3],
            hour = showActivityTime[1][4]
        })

        self._activityEndTime = os.time({
            year = showActivityTime[2][1], 
            month = showActivityTime[2][2],
            day = showActivityTime[2][3],
            hour = showActivityTime[2][4]
        })
    end

    local serverTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    return serverTime >= self._activityBeginTime and serverTime <= self._activityEndTime, serverTime <= self._activityEndTime
end

function HeroDuelMainView:onDestroy()
    self._viewMgr:disableScreenWidthBar()
    if self._timerId then
        ScheduleMgr:unregSchedule(self._timerId)
    end

    HeroDuelMainView.super.onDestroy(self)
end

function HeroDuelMainView:dtor()
    HeroDuelMainView = nil
end

return HeroDuelMainView
