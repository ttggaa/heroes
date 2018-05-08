--
-- Author: <ligen@playcrab.com>
-- Date: 2016-08-23 21:19:18
--
local CloudCityView = class("CloudCityView", BaseView)
function CloudCityView:ctor(data)
    CloudCityView.super.ctor(self)

    self._curStageData = nil

    -- 当前关卡（对应配置表ID）
    self._globalStageId = data and data.stageId or nil

    self._cModel = self._modelMgr:getModel("CloudCityModel")

    self._aniPosList = {10, 20, 30, 40}

    -- 三种状态（前进按钮，宝箱，穿梭门）
    self._isShowArrow = false
    self._isShowDoor  = false
    self._isShowBox   = false

    -- 场景正在切换
    self._isMoveing = false

    self._needStartAni = true

    self._chanllengeTimes = nil
end

function CloudCityView:getAsyncRes()
    return {
        { "asset/ui/cloudCity.plist", "asset/ui/cloudCity.png" },
        {"asset/bg/cloudCityBg1.plist", "asset/bg/cloudCityBg1.png"},
        {"asset/bg/cloudCityBg2.plist", "asset/bg/cloudCityBg2.png"}
    }
end


function CloudCityView:onBeforeAdd(callback, errorCallback)
    local curStageId = self._globalStageId and self._globalStageId or self._cModel:getAttainStageId()
    self._serverMgr:sendMsg("CloudyCityServer", "getCloudyCityStagePassInfo", {stageId = curStageId}, true, {}, function(result)
        cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION3_D)

        callback()
        self:reflashUI(result, true)

        if self._needStartAni then
            self:refalshBg3D()
        else
            self:afterReflashBg3D()
--            self:showMenu(true)
        end
    end)
end

function CloudCityView:onInit()
     self._preBGMName = audioMgr:getMusicFileName()
     audioMgr:playMusic("SaintHeaven", true)

    self:addBg3D()

    self:registerClickEventByName("bg.closeBtn", function()
        self:close()
        UIUtils:reloadLuaFile("cloudcity.CloudCityView")
    end )

    -- 中上
    self._levelLabel = self:getUI("bg.titleBg.levelLabel")
    self._levelLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._levelLabel:setFontName(UIUtils.ttfName_Title)

    -- 左上角
    self._topPlayerBg = self:getUI("bg.topPlayerBg")
    self._shouTongLabel = self:getUI("bg.topPlayerBg.shouTongLabel")
    self._shouTongLabel:setString(lang("towertip_1"))
    self._shouTongLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._shouTongLabel:setColor(cc.c3b(255, 232, 153))
    self._nameLabel = self:getUI("bg.topPlayerBg.nameLabel")
    self._nameLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._renShuLabel = self:getUI("bg.topPlayerBg.renShuLabel")
    self._renShuLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._renShuLabel:setColor(cc.c3b(255, 232, 153))
    self._numLabel = self:getUI("bg.topPlayerBg.numLabel")
    self._numLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    -- 右下角
    self._rewardLabel = self:getUI("bg.rewardBg.rewardLabel")
    self._rewardLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    -- 中下
    self._startNode = self:getUI("bg.startNode")
    self._cishuLabel = self:getUI("bg.startNode.cishuLabel")
    self._cishuLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._maxTimesLabel = self:getUI("bg.startNode.maxTimesLabel")
    self._maxTimesLabel:setColor(UIUtils.colorTable.ccColorQuality2)
    self._maxTimesLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    local maxTimes = tab:Setting("G_CLOUD_CITY_TIME").value
    local privilegesTimes = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.CloudCityTimes)
    if privilegesTimes and privilegesTimes > 0 then
        maxTimes = maxTimes + privilegesTimes
    end
    self._maxTimesLabel:setString("/" .. maxTimes)

    self._timesLabel = self:getUI("bg.startNode.timesLabel")
    self._timesLabel:setColor(UIUtils.colorTable.ccColorQuality2)
    self._timesLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._hintLabel = self:getUI("bg.hintLabel")
    self._hintLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._tequanIcon = self:getUI("bg.startNode.tequanIcon")
    self._tequanIcon:setVisible(privilegesTimes and privilegesTimes > 0)

    self._addBtn = self._startNode:getChildByFullName("addBtn")
    self._addBtn:setVisible(false)

    -- 右下角奖励显示
    self._rewardNode = self:getUI("bg.rewardBg.rewardNode")

    -- 宝箱触摸
    self._rewardBoxNode = self:getUI("bg.rewardNode")
    self:registerClickEvent(self._rewardBoxNode, function()
        self:getFloorAward()
    end )
    self._rewardBoxNode:setTouchEnabled(false) 

    -- 传送门触摸
    self._doorNode = self:getUI("bg.doorNode")
    self:registerClickEvent(self._doorNode, function()
        self:enterTheDoor()
    end )

    -- 滑屏触摸
    local downY = 0,0
    self._touchBg = self:getUI("bg")
    self:registerTouchEvent(self._touchBg, function(sender, x, y)
        downY = y
    end, nil, function(sender, x, y)
        -- 有箭头，宝箱，门打开时，不能滑动
        if self._isShowArrow then
            self._viewMgr:showTip(lang("towertip_7"))
            return
        elseif self._isShowBox then
            self._viewMgr:showTip(lang("towertip_8"))
            return
        elseif self._isShowDoor then
            self._viewMgr:showTip(lang("towertip_9"))
            return
        elseif self._isMoveing then
            return
        end

        if y - downY < -20 then
            self._isMoveing = true
            self:updateToLevel(self._globalStageId + 1)
        elseif y - downY > 20 then
            self._isMoveing = true
            self:updateToLevel(self._globalStageId - 1)
        end 
    end)

--    -- 左下角功能菜单
--    self._menuNode = self:getUI("bg.menu")

--    self._menuBg = self._menuNode:getChildByFullName("menuBg1")
--    self._menuBg:setCascadeOpacityEnabled(true)

--    self._menuBtnNode = self._menuBg:getChildByFullName("btnNode")

    self._startBtn = self:getUI("bg.startNode.startBtn")
    self._startBtn:getChildByFullName("btnLabel"):enableOutline(cc.c3b(124, 64, 0), 2)
    self:registerClickEvent(self._startBtn, function()
        self:startBattle(self._globalStageId)
    end )

    self:registerClickEvent(self._addBtn, function()
        self:buyChallengeTimes(lang("towertip_19"))
    end )

    self._btnNode = self:getUI("bg.btnNode")
    local btnNodeBg = self:getUI("bg.btnNode.bg")
    btnNodeBg:setScale9Enabled(true)
	btnNodeBg:setCapInsets(cc.rect(20, 20, 1, 1))
	btnNodeBg:setContentSize(cc.size(378, 70))
    btnNodeBg:setPositionX(114)

    self._levelBtn = self._btnNode:getChildByFullName("levelBtn")
    self._levelBtn:setScaleAnim(true)
    self._levelBtn:setCascadeOpacityEnabled(true)

    local levelLabel = self._levelBtn:getChildByFullName("name")
    levelLabel:setString("扫荡")
    levelLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._rankBtn = self._btnNode:getChildByFullName("rankBtn")
    self._rankBtn:setScaleAnim(true)
    self._rankBtn:setCascadeOpacityEnabled(true)

    local rankLabel = self._rankBtn:getChildByFullName("name")
    rankLabel:setString("排行")
    rankLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._ruleBtn = self._btnNode:getChildByFullName("ruleBtn")
    self._ruleBtn:setScaleAnim(true)
    self._ruleBtn:setCascadeOpacityEnabled(true)

    local ruleLabel = self._ruleBtn:getChildByFullName("name")
    ruleLabel:setString("规则")
    ruleLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

--    self._showMenuBtn = self._menuBg:getChildByFullName("showBtn")
--    self._showMenuBtn:setScaleAnim(true)
    
    self:registerClickEvent(self._levelBtn, function()
        self._viewMgr:showDialog("cloudcity.CloudCityLevelSelectView",
             {curFloor = self._curFloor, curStage = self._curStage, callback = specialize(self.selectViewCallBack, self)},
              true)
        self:hideQiPao()
    end )

    self:registerClickEvent(self._rankBtn, function()
        local rankModel = self._modelMgr:getModel("RankModel")
        rankModel:setRankTypeAndStartNum(rankModel.kRankTypeCloudCity_NEW_fight, 1)
        self._serverMgr:sendMsg("RankServer", "getRankList", {type = rankModel.kRankTypeCloudCity_NEW_fight, startRank = 1, id = self._globalStageId}, true, {}, function(result)
            self._viewMgr:showDialog("cloudcity.CloudCityRankView", {stageId = self._globalStageId}, true)
        end)
    end )

    self:registerClickEvent(self._ruleBtn, function()
        self._viewMgr:showDialog("cloudcity.CloudCityRuleView", {}, true)
    end )

--    self:registerClickEvent(self._showMenuBtn, function()
--        self:showMenu(not self._isShowMenu)
--    end )

    self._goClickNode = self:getUI("bg.goClickNode")
    self._goClickNode:setVisible(false)

    self._goForwardMc = mcMgr:createViewMC("qianjinanniu_qianjin", true, false)
    self._goForwardMc:setPosition(self._goClickNode:getContentSize().width / 2, self._goClickNode:getContentSize().height / 2)
    self._goClickNode:addChild(self._goForwardMc, 999)

    self:registerClickEvent(self._goClickNode, function()
        self._goClickNode:setVisible(false)
        self._isShowArrow = false
        self:updateToLevel(self._globalStageId + 1)
    end)

    self._qipaoTips = self._btnNode:getChildByFullName("tipsBg")
    self._qipaoTips:setCascadeOpacityEnabled(true)
    self._qipaoTips:ignoreContentAdaptWithSize(false)
    self._qipaoLabel = self._qipaoTips:getChildByFullName("tipsLabel")
    self._qipaoLabel:setFontName(UIUtils.ttfName)
    self._qipaoLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._qipaoLabel:setString(lang("towertip_17"))
    self._qipaoLabel:setPositionX(self._qipaoLabel:getContentSize().width*0.5 + 10)
    self._qipaoTips:setContentSize(self._qipaoLabel:getContentSize().width + 20, 50)

    self:listenReflash("PlayerTodayModel", function()
        self._chanllengeTimes = self._cModel:getChallengeTimes()
        self:updateTimes(self._chanllengeTimes)
    end)
end

function CloudCityView:reflashUI(data, isInit)
    if isInit then
        if self._globalStageId ~= nil and self._globalStageId ~= self._cModel:getAttainStageId() then
            if self._globalStageId > self._cModel:getAttainStageId() then
                print("未达到此关卡")
                return
            end

            local openFloor, openStage = self:getFloorAndStageById(self._globalStageId)
            self._viewMgr:showDialog("cloudcity.CloudCityLevelSelectView",
                {curFloor = openFloor, needShowBtnAni = true, curStage = openStage, callback = specialize(self.selectViewCallBack, self)},
                 true)
                  
            if not self._onFireSoundId then
                self._onFireSoundId = audioMgr:playSound("clound_flame", true)
            end

            self._needStartAni = false
        else
            self._globalStageId = data.stageId
        end

        local _, jumpStage = self:getFloorAndStageById(self._globalStageId)
        self:moveBg3D(jumpStage, false, false)
    end

    self._curStageData = data

    self._curFloor, self._curStage = self:getFloorAndStageById(self._globalStageId)

    self._levelLabel:setString("第" .. self._curFloor .. "层 " .. "第" .. self._curStage .. "关")
    self._nameLabel:setString(data.firstPass == "" and "暂无" or data.firstPass)
    self._numLabel:setString(data.totalPass or "0")

    if self._rewardNode then
        self._rewardNode:removeAllChildren()
    end

    local rewardData = tab:TowerFloor(self._curFloor).reward

    local iconWidth = 62
    local offsetX = 8
    for i = 1, #rewardData do
        local itemType = rewardData[i][1]
        local itemId = nil
        if itemType == "tool" then
            itemId = rewardData[i][2]
        else 
            itemId = IconUtils.iconIdMap[itemType]
        end
        local toolD = tab:Tool(tonumber(itemId))
        local rewardIcon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD, num = rewardData[i][3]})
        rewardIcon:setScale(iconWidth / rewardIcon:getContentSize().width)
        rewardIcon:setPosition((i - 1) * (iconWidth + offsetX) , 0)
        self._rewardNode:addChild(rewardIcon)
    end

    self._chanllengeTimes = self._cModel:getChallengeTimes()
    self:updateTimes(self._chanllengeTimes)

    -- 判断是否显示火焰
    for lI = 1, 3 do
        if (self._curFloor - 1) * 4 + lI < self._cModel:getAttainStageId() then
            self._lightList[#self._lightList-(lI-1)*2]:gotoAndPlay(35)
            self._lightList[#self._lightList-(lI-1)*2-1]:gotoAndPlay(35)
        else
            self._lightList[#self._lightList-(lI-1)*2]:gotoAndStop(1)
            self._lightList[#self._lightList-(lI-1)*2-1]:gotoAndStop(1)
        end
    end

    if SystemUtils.loadAccountLocalData("cloudcityLevelQipao") ~= nil and self._cModel:getAttainStageId() <= SystemUtils.loadAccountLocalData("cloudcityLevelQipao") then
        self:showQiPao()
    end
end

-- 跳到指定关卡
function CloudCityView:updateToLevel(stageId)
    if stageId < 1 or stageId > self._cModel:getAttainStageId() then 
        self._isMoveing = false
        return
    end

    if not self._cModel:getIsFirstFight(stageId) and stageId % 4 ~= 0 then
        if not self._onFireSoundId then
            self._onFireSoundId = audioMgr:playSound("clound_flame", true)
        end
    else
        audioMgr:stopSound(self._onFireSoundId)
        self._onFireSoundId = nil
    end

    if self._doorMc ~= nil and  self._doorMc:getCurrentFrame() ~= 1 and self._globalStageId == #tab.towerStage then
        self._doorMc:gotoAndStop(1)
        self._doorMc:retain()
        self._doorMc:removeFromParent()
        self._floorLayer:addChild(self._doorMc)
        self._doorMc:release()
        self._doorNode:setVisible(false)

        self._hintLabel:setVisible(false)
    end
    
    self._globalStageId = stageId

    local toFloor, toStage = self:getFloorAndStageById(self._globalStageId)

    self._serverMgr:sendMsg("CloudyCityServer", "getCloudyCityStagePassInfo", {stageId = stageId}, true, {}, function(result)
        if toFloor ~= self._curFloor then
            audioMgr:playSound("clound_switch")
            local mc = mcMgr:createViewMC("qiehuanguangxiao_yunzhongcheng", false, true)
            mc:setName("anim")
            mc:setPosition(MAX_SCREEN_WIDTH / 2, MAX_SCREEN_HEIGHT / 2 + 70)
            self:addChild(mc, 999)

            self._viewMgr:lock(-1)
            ScheduleMgr:delayCall(1500, self, function()
                self._viewMgr:unlock()
                self:moveBg3D(toStage, false, false)
                self:reflashUI(result)

                self:refalshBg3D()
            end)
        else
            self._viewMgr:lock(-1)
            ScheduleMgr:delayCall(100, self, function()
                self._viewMgr:unlock()
                self:reflashUI(result)
                self:moveBg3D(toStage, true, true)
            end)
        end
    end)
end



-- 开始挑战
function CloudCityView:startBattle(stageId)
    if self._chanllengeTimes > 0 then
        self._viewMgr:showDialog("cloudcity.CloudCityBattleView",
            {
                stageId = stageId,
                callBack = specialize(self.battleComplete, self),
                resetCallBack = specialize(self.resetStage, self),
                selectViewCallBack = specialize(self.selectViewCallBack, self),
            },
            true)
    else
        self:buyChallengeTimes("挑战次数已用尽")
    end
end

function CloudCityView:battleComplete(data)
    -- 有奖励通过本层，无奖励是通过一小关
    if data.reward ~= nil then
        if self._globalStageId % 4 ~= 0 then
            if self._globalStageId == self._cModel:getAttainStageId() then
                self._isShowArrow = true
                self._startBtn:setVisible(false)

                self._isFireEffect = true
            end

        else
            if self._globalStageId == self._cModel:getAttainStageId() and self._cModel:getMaxRewardId() < self._curFloor then
                self._isRewardBoxEffect = true
                self._startBtn:setVisible(false)
            end
        end

        self._isPlayComepleteAni = true
--        if self._globalStageId == self._cModel:getAttainStageId() and self._globalStageId < #tab.towerStage then
--            self._isPlayTimesEffect = true
--            self._chanllengeTimes = self._cModel:getChallengeTimes() - 1

--        else

--            self._chanllengeTimes = self._cModel:getChallengeTimes()
--        end

        self._chanllengeTimes = self._cModel:getChallengeTimes()
        self:updateTimes(self._chanllengeTimes)

        if data.firstPass ~= self._nameLabel:getString() then
            self._isNameEffect = true
        end

        if tostring(data.totalPass) ~= self._numLabel:getString() then
            self._isNumberEffect = true
        end

        self._nameLabel:setString(data.firstPass == "" and "暂无" or data.firstPass)
        self._numLabel:setString(data.totalPass or "0")

        if SystemUtils.loadAccountLocalData("cloudcityLevelQipao") ~= nil and self._globalStageId >= SystemUtils.loadAccountLocalData("cloudcityLevelQipao") then
            self:hideQiPao()
        end
    end
end

-- 领取层奖励
function CloudCityView:getFloorAward()
    local function finishGet()
        self._doorMc:gotoAndPlay(2)
        self._vortexMc:retain()
        self._vortexMc:removeFromParent()
        self._floorLayer:addChild(self._vortexMc)
        self._vortexMc:release()

        self._rewardBoxMc:removeFromParent()
        self._rewardBoxMc = nil

        self._hintLabel:setVisible(true)
        self._startNode:setVisible(false)
        self._doorNode:setVisible(true)

        if self._globalStageId < #tab.towerStage then
            self._isShowDoor = true
            self._hintLabel:setString("点击神门前往下一层")
        else
            self._hintLabel:setString(lang("towertip_13"))
        end
    end
    if self._rewardBoxMc ~= nil then

        self._rewardBoxNode:setTouchEnabled(false)
        self._isShowBox = false

        self._rewardBoxMc:addEndCallback(function (_, sender)
            sender:clearCallbacks()
            sender:stop(true)
        end)

        self._rewardBoxMc:gotoAndPlay(11)

        self._serverMgr:sendMsg("CloudyCityServer", "getCloudyCityFloorReward", {}, true, {}, function(result)
            print("getReward")

            DialogUtils.showGiftGet( {gifts = result.reward, callback = finishGet})
        end)
    end
end

-- 更新次数
function CloudCityView:updateTimes(timesNum)
    if tonumber(timesNum) == 0 then
        self._addBtn:setVisible(true)
        self._tequanIcon:setOpacity(0)
    else
        self._addBtn:setVisible(false)
        self._tequanIcon:setOpacity(255)
    end
    self._timesLabel:setString(tostring(timesNum))
end

-- 购买次数
-- @param desStr 到达购买上限提示语
function CloudCityView:buyChallengeTimes(desStr)
    local gem = self._modelMgr:getModel("UserModel"):getData()["gem"]
    local buyTimes = self._modelMgr:getModel("PlayerTodayModel"):getData()["day41"]
    local vipLv = self._modelMgr:getModel("VipModel"):getData().level
    local costNum = tab:ReflashCost(buyTimes + 1)["costCloud"]

    if tab:Vip(vipLv)["buyCloud"] > buyTimes then
        DialogUtils.showBuyDialog({costNum = costNum,goods = "购买一次挑战次数",callback1 = function( )
            if costNum < gem then
                self._serverMgr:sendMsg("CloudyCityServer", "buyCloudyCityNum", {}, true, {}, function(result) 
                    self._viewMgr:showTip("购买成功")
                    self._chanllengeTimes = self._chanllengeTimes + 1
                    self:updateTimes(self._chanllengeTimes)
                end)
            else
                DialogUtils.showNeedCharge({callback1=function( )
                    local viewMgr = ViewManager:getInstance()
                    viewMgr:showView("vip.VipView", {viewType = 0})
                end})
            end
        end})
    else
        self._viewMgr:showTip(desStr)
    end
end

-- 开启下一层
function CloudCityView:enterTheDoor()
    if self._globalStageId + 1 > #tab.towerStage then
        self._viewMgr:showTip(lang("towertip_14"))
        return
    end
    self:updateToLevel(self._globalStageId + 1)

    self._viewMgr:lock(-1)
    ScheduleMgr:delayCall(1000, self, function()
        self._viewMgr:unlock()

        self._doorMc:gotoAndStop(1)
        self._doorMc:retain()
        self._doorMc:removeFromParent()
        self._floorLayer:addChild(self._doorMc)
        self._doorMc:release()

        self._hintLabel:setVisible(false)
    end)

    self._doorNode:setVisible(false)
    self._isShowDoor = false
end

-- 失败重置本关数据
function CloudCityView:resetStage()
    self._curStageData = {}

    if SystemUtils.loadAccountLocalData("cloudcityLevelQipao") == nil then
        SystemUtils.saveAccountLocalData("cloudcityLevelQipao", self._globalStageId)
        self:showQiPao()
    end
end

-- 关卡选择界面回调方法
function CloudCityView:selectViewCallBack(data)
    if self._isShowArrow then
        self._viewMgr:showTip(lang("towertip_7"))
        return
    elseif self._isShowBox then
        self._viewMgr:showTip(lang("towertip_8"))
        return
    elseif self._isShowDoor then
        self._viewMgr:showTip(lang("towertip_9"))
        return
    end 

    if data.cType == "advanceStage" then
        self._goClickNode:setVisible(false)
        self._isShowArrow = false
        self:updateToLevel(self:getIdByFloorAndStage(data.toFloor, data.toStage))

    elseif data.cType == "sweepStage" then

        self._chanllengeTimes = self._cModel:getChallengeTimes()
        self:updateTimes(self._chanllengeTimes)
    end
end

function CloudCityView:onTop()
    self:openCamera()

    if self._isRewardBoxEffect or self._isFireEffect then
        self:lock(-1)
    end

    self:playPassAni()
end

function CloudCityView:onHide()
    self:closeCamera()
end

function CloudCityView:onShow()
--    ScheduleMgr:delayCall(1000, self, function()
--        self:playPassAni()
--    end)
end

function CloudCityView:closeCamera()
    self._bgCamera:setVisible(false)
    self._camera:setVisible(false)
end

function CloudCityView:openCamera()
    self._bgCamera:setVisible(true)
    self._camera:setVisible(true)
end

-- 播放通关动画
function CloudCityView:playPassAni()
--    self._isPlayComepleteAni = true
--    self._isPlayTimesEffect = true
--    self._isFireEffect = true
--    self._isNameEffect = true
--    self._isNumberEffect = true
--    self._isRewardBoxEffect = true
    

    if self._isPlayComepleteAni then

--        if self._isPlayTimesEffect then
--            self._timesLabel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.5), cc.CallFunc:create(function()

--                self._timesLabel:setBrightness(255)
--                self:updateTimes(self._chanllengeTimes)

--                self._viewMgr:lock(-1)
--                ScheduleMgr:delayCall(100, self, function()
--                    self._viewMgr:unlock()

--                    self._timesLabel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1) , cc.CallFunc:create(function()
--                        self._timesLabel:setBrightness(1)

--                        local flyLabel = self._timesLabel:clone()
--                        flyLabel:setString("+1")
--                        flyLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--                        self._startNode:addChild(flyLabel)
--                        flyLabel:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveBy:create(0.5, cc.p(0, 40)), cc.FadeOut:create(0.5)), cc.CallFunc:create(function()
--                            flyLabel:removeFromParent()
--                        end)))
--                    end)))
--                end)
--            end)))
--        end

        if self._isRewardBoxEffect then
            if self._rewardBoxMc == nil then
                self._rewardBoxMc = mcMgr:createViewMC("lingjiangbaoxiang2_lingqujiangli", true)
                self._rewardBoxMc:gotoAndStop(1)
                self._rewardBoxMc:setCascadeOpacityEnabled(true)
                self._rewardBoxMc:setOpacity(125)
                self._rewardBoxNode:addChild(self._rewardBoxMc)
            end
            self._rewardBoxMc:setVisible(false)
            self._rewardBoxMc:setPosition(self._rewardBoxNode:getContentSize().width / 2, 500)

            local function closePassView()
                audioMgr:playSound("clound_reward")
                
                local lightPillar = mcMgr:createViewMC("lingjiang_lingqujiangli", false, true)
                lightPillar:setPosition(self._rewardBoxNode:getContentSize().width / 2, 60)
                self._rewardBoxNode:addChild(lightPillar)
                self._rewardBoxNode:setVisible(true)
                self._isShowBox = true

                lightPillar:addCallbackAtFrame(23, function (_, sender)
                    UIUtils:shakeWindow(self)
                end)

                lightPillar:addCallbackAtFrame(30, function (_, sender)
                    self._rewardBoxMc:setVisible(true)
                    local rewardAction = cc.Spawn:create(cc.FadeIn:create(0.3), 
                        cc.EaseSineOut:create(cc.MoveTo:create(0.3, cc.p(self._rewardBoxNode:getContentSize().width / 2, 5))))

                    self._rewardBoxMc:runAction(cc.Sequence:create(rewardAction, cc.CallFunc:create(function()
                        self._rewardBoxMc:addCallbackAtFrame(5, function (_, sender)
                            self._rewardBoxMc:gotoAndPlay(5)
                        end)
                        self._rewardBoxMc:play()
                    end)))
                    self._rewardBoxNode:setTouchEnabled(true)
                    self._isShowBox = true

                end)
            end
            self._viewMgr:showDialog("cloudcity.CloudCityPassView", {passCount = tonumber(self._numLabel:getString()), callBack = closePassView})
--            self:unlock()
        end

        if self._isFireEffect then
            audioMgr:playSound("clound_fireup")
            self._lightList[#self._lightList-(self._curStage-1)*2]:gotoAndPlay(1)
            self._lightList[#self._lightList-(self._curStage-1)*2-1]:gotoAndPlay(1) 
            self._onFireSoundId = audioMgr:playSound("clound_flame", true)

            self._viewMgr:lock(-1)
            ScheduleMgr:delayCall(1500, self, function()
                self._viewMgr:unlock()

                self._goClickNode:setVisible(true)
                
                self._viewMgr:showDialog("cloudcity.CloudCityPassView", {passCount = tonumber(self._numLabel:getString())})
--                self:unlock()
            end)
        end

        if self._isNameEffect then
            local saoguangMc = mcMgr:createViewMC("shuaxinguangxiao_shuaxinguangxiao", false, true)
            saoguangMc:setPosition(170, 50)
            saoguangMc:setScale(0.6)
            self._topPlayerBg:addChild(saoguangMc)
        end

        if self._isNumberEffect then
            local saoguangMc2 = mcMgr:createViewMC("shuaxinguangxiao_shuaxinguangxiao", false, true)
            saoguangMc2:setPosition(170, 15)
            saoguangMc2:setScale(0.6)
            self._topPlayerBg:addChild(saoguangMc2)
        end
    end

    self._isPlayComepleteAni = false
    self._isPlayTimesEffect = false
    self._isRewardBoxEffect = false
    self._isFireEffect = false
    self._isNameEffect = false
    self._isNumberEffect = false
end

-- 3D背景移动结束
function CloudCityView:afterReflashBg3D()
    self._isMoveing = false

    for lI = 1, #self._lightList do
        self._lightList[lI]:setVisible(true)
--        self._lightList[lI]:gotoAndPlay(1)
    end

    -- 最后一关单独判断是否已领奖
    if self._cModel:getPassMaxStageId() == #tab.towerStage and self._cModel:getMaxRewardId() == self._curFloor then
        self._startNode:setVisible(true)
        self._startBtn:setVisible(true)
        return
    end

    if self._globalStageId == self._cModel:getPassMaxStageId() and self._cModel:getPassMaxStageId() == self._cModel:getAttainStageId() then
        if self._rewardBoxMc == nil then
            self._rewardBoxMc = mcMgr:createViewMC("lingjiangbaoxiang2_lingqujiangli", true)
            self._rewardBoxMc:gotoAndStop(5)
            self._rewardBoxMc:setPosition(self._rewardBoxNode:getContentSize().width / 2, 5)
            self._rewardBoxNode:addChild(self._rewardBoxMc)
        end

        self._rewardBoxNode:setVisible(true)
        self._rewardBoxNode:setTouchEnabled(true)
        self._isShowBox = true

        self._startNode:setVisible(false)
    else
--        self._rewardBoxNode:setVisible(false)
        self._startNode:setVisible(true)
        self._startBtn:setVisible(true)
    end

end

--function CloudCityView:showMenu(bool, delayTime)
--    if bool == self._isShowMenu then return end
--    self._isShowMenu = bool
--    if bool then
--        self._showMenuBtn:setFlippedX(false)
--        local seq = cc.EaseBackOut:create(cc.MoveTo:create(delayTime or 0.2, cc.p(205, 21)))
--        self._menuBg:runAction(seq)

--        self._menuBtnNode:setVisible(true)
--    else
--        self._showMenuBtn:setFlippedX(true)
--        local seq = cc.EaseBackIn:create(cc.MoveTo:create(delayTime or 0.1, cc.p(-75, 21)))
--        self._menuBg:runAction(seq)

--        self._menuBtnNode:setVisible(false)
--    end
--end


-- 添加3D背景
function CloudCityView:addBg3D() 
    self._bgLayer = cc.Layer:create()
    self:addChild(self._bgLayer, 0)

    self._Layer3D = cc.Layer:create()
    self:addChild(self._Layer3D, 0)

    self._cloudLayer = cc.Node:create()
    self._bgLayer:addChild(self._cloudLayer, 0)

    self._pillarLayer = cc.Layer:create()
    self._Layer3D:addChild(self._pillarLayer, 0)

    self._floorLayer = cc.Layer:create()
    self._Layer3D:addChild(self._floorLayer, 0)

    local bg = cc.Sprite:create("asset/bg/cloudCityBg_1.jpg")
    local xscale = MAX_SCREEN_WIDTH / bg:getContentSize().width
    local yscale = MAX_SCREEN_HEIGHT / bg:getContentSize().height
    if xscale > yscale then
        bg:setScale(xscale)
    else
        bg:setScale(yscale)
    end
    bg:setPosition3D(cc.vec3(MAX_SCREEN_WIDTH / 2, MAX_SCREEN_HEIGHT / 2, -1))
    self._bgLayer:addChild(bg)

    self._cloudList = {}
    local cloudLeftBottom = cc.Sprite:createWithSpriteFrameName("cloudCityBg_CloudLeftBottom.png")
    cloudLeftBottom:setPosition3D(cc.vec3(cloudLeftBottom:getContentSize().width / 2, cloudLeftBottom:getContentSize().height / 2, -1))
    cloudLeftBottom.pos = "leftBottom"
    cloudLeftBottom.startX = cloudLeftBottom:getPositionX()
    cloudLeftBottom.startY = cloudLeftBottom:getPositionY()
    self._bgLayer:addChild(cloudLeftBottom)
    table.insert(self._cloudList, cloudLeftBottom)

    local cloudLeftTop = cc.Sprite:createWithSpriteFrameName("cloudCityBg_CloudLeftTop.png")
    cloudLeftTop:setPosition3D(cc.vec3(cloudLeftTop:getContentSize().width / 2, MAX_SCREEN_HEIGHT - cloudLeftTop:getContentSize().height / 2, -1))
    cloudLeftTop.pos = "leftTop"
    cloudLeftTop.startX = cloudLeftTop:getPositionX()
    cloudLeftTop.startY = cloudLeftTop:getPositionY()
    self._bgLayer:addChild(cloudLeftTop)
    table.insert(self._cloudList, cloudLeftTop)


    local cloudRightBottom = cc.Sprite:createWithSpriteFrameName("cloudCityBg_CloudRightBottom.png")
    cloudRightBottom:setPosition3D(cc.vec3(MAX_SCREEN_WIDTH - cloudRightBottom:getContentSize().width / 2, cloudRightBottom:getContentSize().height / 2, -1))
    cloudRightBottom.pos = "rightBottom"
    cloudRightBottom.startX = cloudRightBottom:getPositionX()
    cloudRightBottom.startY = cloudRightBottom:getPositionY()
    self._bgLayer:addChild(cloudRightBottom)
    table.insert(self._cloudList, cloudRightBottom)

    local cloudRightTop = cc.Sprite:createWithSpriteFrameName("cloudCityBg_CloudRightTop.png")
    cloudRightTop:setPosition3D(cc.vec3(MAX_SCREEN_WIDTH - cloudRightTop:getContentSize().width / 2,MAX_SCREEN_HEIGHT - cloudRightTop:getContentSize().height / 2, -1))
    cloudRightTop.pos = "rightTop"
    cloudRightTop.startX = cloudRightTop:getPositionX()
    cloudRightTop.startY = cloudRightTop:getPositionY()
    self._bgLayer:addChild(cloudRightTop)
    table.insert(self._cloudList, cloudRightTop)

    self._bgCamera = cc.Camera:createOrthographic(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT, 0, 10)
    self._bgCamera:setPosition(cc.vec3(0, 0, 0))
    self._bgCamera:lookAt(cc.vec3(0, 0, -1), cc.vec3(0, 1, 0))
    self._bgCamera:setCameraFlag(cc.CameraFlag.USER1)
    self._bgLayer:setCameraMask(cc.CameraFlag.USER1)
    self._bgLayer:addChild(self._bgCamera)

    local startPos = cc.vec3(70, -20, -81)
    local posList = {
                 {pos = cc.vec3(-startPos.x, startPos.y,  startPos.z - 180), isFlippedX = true},
                 {pos = cc.vec3(startPos.x, startPos.y,  startPos.z - 180), isFlippedX = false},
                 {pos = cc.vec3(-startPos.x, startPos.y,  startPos.z - 80), isFlippedX = true},
                 {pos = cc.vec3(startPos.x, startPos.y,  startPos.z - 80), isFlippedX = false},
                 {pos = cc.vec3(-startPos.x, startPos.y,  startPos.z - 20), isFlippedX = true},
                 {pos = cc.vec3(startPos.x, startPos.y,  startPos.z - 20), isFlippedX = false},
                }

    self._pillarList = {}
    self._fogList = {}
    self._lightList = {}
    for i = 1, #posList do
        local pillarSpr2 = cc.Sprite:createWithSpriteFrameName("cloudCityBg_pillar2.png")
        pillarSpr2:setFlippedX(posList[i].isFlippedX)
        pillarSpr2:setScale(0.2)
        pillarSpr2:setPosition3D(posList[i].pos)
        self._pillarLayer:addChild(pillarSpr2)
        table.insert(self._pillarList, pillarSpr2)

        local pillarSpr1 = cc.Sprite:createWithSpriteFrameName("cloudCityBg_pillar1.png")
        pillarSpr1:setFlippedX(posList[i].isFlippedX)
        if posList[i].isFlippedX then
            pillarSpr1:setPosition(74, 1370)
        else
            pillarSpr1:setPosition(168, 1370)
        end
        pillarSpr2:addChild(pillarSpr1) 

        local fogSpr = cc.Sprite:createWithSpriteFrameName("cloudCityBg_CloudFront.png")
        fogSpr:setScale(0.4)
        fogSpr:setAnchorPoint(0.5, 0)
        fogSpr:setPosition3D(cc.vec3(posList[i].pos.x * 1.5, posList[i].pos.y - 80, posList[i].pos.z))
        self._pillarLayer:addChild(fogSpr)
        table.insert(self._fogList, fogSpr)

        local fireMc = mcMgr:createViewMC("dianliang_dianliang", true)
        if posList[i].isFlippedX then
            fireMc:setPosition3D(cc.vec3(posList[i].pos.x, posList[i].pos.y + 69, posList[i].pos.z))
            fireMc:setScaleX(-0.2)
        else
            fireMc:setPosition3D(cc.vec3(posList[i].pos.x, posList[i].pos.y + 69, posList[i].pos.z))
            fireMc:setScaleX(0.2)
        end
        fireMc:setScaleY(0.2)
        fireMc:gotoAndStop("1")
        self._pillarLayer:addChild(fireMc)
        table.insert(self._lightList, fireMc)

        fireMc:addCallbackAtFrame(50, function (_, sender)
            fireMc:gotoAndPlay(35)
        end)
    end

    local startZ = -248
    local offsetZ = -128
    for fI = 1, 4 do
        local floorSpr = cc.Sprite:create("asset/bg/cloudCityBg_floor.png")
        floorSpr:setScale(0.4)
        floorSpr:setAnchorPoint(0.5, 0)
        floorSpr:setPosition3D(cc.vec3(0, -70, startZ + (fI - 1) * offsetZ))
        floorSpr:setRotation3D(cc.vec3(90, 0, 0))
        self._floorLayer:addChild(floorSpr)
    end

--    local doorSpr = cc.Sprite:createWithSpriteFrameName("cloudCityBg_door.png")
--    doorSpr:setScale(0.4)
--    doorSpr:setPosition3D(cc.vec3(0, 57, -630))
--    self._floorLayer:addChild(doorSpr)

    local vorterBg = mcMgr:createViewMC("xuanwo2_lingqujiangli", true)
    vorterBg:setScale(0.5)
    vorterBg:setPosition3D(cc.vec3(0, 8, -632))
    self._floorLayer:addChild(vorterBg) 

    self._vortexMc = mcMgr:createViewMC("xuanwo1_lingqujiangli", true)
    self._vortexMc:setScale(0.5)
    self._vortexMc:setPosition3D(cc.vec3(0, 8, -631))
    self._floorLayer:addChild(self._vortexMc)

    self._doorMc = mcMgr:createViewMC("yunzhongchengdakai_lingqujiangli", false, false)
    self._doorMc:setScale(0.4)
    self._doorMc:gotoAndStop(1)
    self._doorMc:setPosition3D(cc.vec3(0, -19, -631))
    self._floorLayer:addChild(self._doorMc)

    local doorBottomSpr = cc.Sprite:create("asset/bg/cloudCityBg_doorBottom.png")
    doorBottomSpr:setScale(0.4)
    doorBottomSpr:setPosition3D(cc.vec3(0, -47, -630))
    self._floorLayer:addChild(doorBottomSpr)

    self._camera = cc.Camera:createPerspective(60, MAX_SCREEN_WIDTH / MAX_SCREEN_HEIGHT, 0, 1000)
    self._camera:setPosition3D(cc.vec3(0, 0, 0))
    self._camera:lookAt(cc.vec3(0, 0, -1), cc.vec3(0, 1, 0))
    self._camera:setCameraFlag(cc.CameraFlag.USER2)
    self._Layer3D:setCameraMask(cc.CameraFlag.USER2)
    self._Layer3D:addChild(self._camera)

    self:setPositionX(-SCREEN_X_OFFSET)
    self._widget:setPositionX(SCREEN_X_OFFSET)
end


-- 背景前进或后退
-- @param toStage:前去的层数
-- @param isAni:是否滑动动画
-- @param isCallBack:到达指定层后是否回调
local cameraPosList = {0, -60, -160, -380}
local cloudPosList = {leftBottom  = {cc.p(0, 0),cc.p(-10,-10),cc.p(-20,-20),cc.p(-30,-30)},
                      leftTop     = {cc.p(0, 0),cc.p(-10, 10),cc.p(-20, 20),cc.p(-30, 30)},
                      rightBottom = {cc.p(0, 0),cc.p( 10,-10),cc.p( 20,-20),cc.p( 30,-30)},
                      rightTop    = {cc.p(0, 0),cc.p( 10, 10),cc.p( 20, 20),cc.p( 30, 30)}
                      }
local scaleQuotiety = 0.1
function CloudCityView:moveBg3D(toStage, isAni, isCallBack)
    self._isMoveing = true

    local function arriveFun()
        if isCallBack then
            self:afterReflashBg3D()
        end
    end

    self._startNode:setVisible(false)

    if isAni then
        self._camera:runAction(
            cc.Sequence:create(cc.MoveTo:create(0.5,cc.vec3(0, 0, cameraPosList[toStage])),
                cc.CallFunc:create(arriveFun)))

        for _, cloudSpr in pairs(self._cloudList) do
            local toX = cloudSpr.startX + cloudPosList[cloudSpr.pos][toStage].x
            local toY = cloudSpr.startY + cloudPosList[cloudSpr.pos][toStage].y
            cloudSpr:runAction(
                cc.Spawn:create(cc.MoveTo:create(0.5,cc.p(toX, toY)),
                    cc.ScaleTo:create(0.5, 1 + scaleQuotiety * (toStage - 1))))
        end
    else
        self._camera:setPosition3D(cc.vec3(0, 0, cameraPosList[toStage]))

        for _, cloudSpr in pairs(self._cloudList) do
            local toX = cloudSpr.startX + cloudPosList[cloudSpr.pos][toStage].x
            local toY = cloudSpr.startY + cloudPosList[cloudSpr.pos][toStage].y
            cloudSpr:setPosition(toX, toY)
            cloudSpr:setScale(1 + scaleQuotiety * (toStage - 1))
        end

        arriveFun()
    end
end

-- 开场或切层上升动画
local distanceYList = {20, 20, 40, 40, 70, 70}
function CloudCityView:refalshBg3D(callBack)
    self._isMoveing = true
    local function arriveFun()
        if callBack then
            callBack()
        end

        self:afterReflashBg3D()
--        self:showMenu(true)
    end

    self._startNode:setVisible(false)

    self._floorLayer:setPosition3D(cc.vec3(0, -70, 0))
    self._floorLayer:runAction(cc.EaseIn:create(cc.MoveTo:create(0.5,cc.vec3(0, 0, 0)), 1))
    self._floorLayer:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(arriveFun)))

--    self:showMenu(false, 0)
    
    for pI = 1, #self._pillarList do
        local distanceY = math.floor((pI + 1) / 2) * 10
        self._pillarList[pI]:setPositionY(self._pillarList[pI]:getPositionY() - distanceYList[pI])
        self._pillarList[pI]:runAction(cc.EaseOut:create(cc.MoveBy:create(1,cc.vec3(0, distanceYList[pI], 0)), 1))
    end

    for fI = 1, #self._fogList do
        self._fogList[fI]:setOpacity(0)
        self._fogList[fI]:runAction(cc.Sequence:create(cc.DelayTime:create(0.8),cc.FadeIn:create(0.5)))
    end

    for lI = 1, #self._lightList do
        self._lightList[lI]:setVisible(false)
    end
end

function CloudCityView:showQiPao()
    if self._qipaoTips:isVisible() then return end
    self._qipaoTips:setVisible(true)
    self._qipaoTips:runAction(
        cc.RepeatForever:create(
        cc.Sequence:create(
        cc.MoveTo:create(0.4, cc.p(-10, 131)), 
        cc.MoveTo:create(0.4, cc.p(-10, 125))
    )))
end

function CloudCityView:hideQiPao()
    self._qipaoTips:setVisible(false)
    self._qipaoTips:stopAllActions()
end

-- 根据总的阶ID获得对应层数和本层阶数
function CloudCityView:getFloorAndStageById(stageId)
    return tab:TowerStage(stageId).floor, stageId % 4 == 0 and 4 or stageId % 4
end

-- 根据层数和对应阶数获得总的阶ID
function CloudCityView:getIdByFloorAndStage(floor, stage)
    return (floor - 1) * 4 + stage
end


function CloudCityView:destroy()
    cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION2_D)
    if self._onFireSoundId then
        audioMgr:stopSound(self._onFireSoundId)
    end
    if self._preBGMName then
        audioMgr:playMusic(self._preBGMName, true)
    end
    CloudCityView.super.destroy(self, true)
end
return CloudCityView


