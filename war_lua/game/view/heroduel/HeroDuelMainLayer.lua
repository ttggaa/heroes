--
-- Author: <ligen@playcrab.com>
-- Date: 2017-01-24 15:23:20
--
local HeroDuelMainLayer = class("HeroDuelMainLayer", BaseLayer)

function HeroDuelMainLayer:ctor(data)
    HeroDuelMainLayer.super.ctor(self)

    self._mainData = data.mainData
    self._mainCallBack = data.callBack

    self._hModel = self._modelMgr:getModel("HeroDuelModel")

    self._winNum = nil
    self._loseNum = nil

    -- 判断刷新界面时表现胜利或失败
    self._isWin = nil

    self._kShieldType = {
        [1] = {name = "shitoudun_gezhongdun", mcX = 10, mcY = -10, fontX = 0, fontY = 0, scale = 1},
        [2] = {name = "tongdun_gezhongdun", mcX = 10, mcY = -20, fontX = -1, fontY = 0, scale = 1},
        [3] = {name = "yindun_gezhongdun", mcX = 10, mcY = -20, fontX = 0, fontY = -6, scale = 1},
        [4] = {name = "jindun_gezhongdun", mcX = -31, mcY = 0, fontX = -41, fontY = 0, scale = 0.9}
    }

    self._kErrorTpStr = {
        [1] = "HERODUEL21",
        [2] = "HERODUEL20"
    }

    -- 开始交锋通信时间戳（用于判断网络延迟状况）
    self._netTimeStamp = nil
end

function HeroDuelMainLayer:onInit()
    self._bg = self:getUI("bg")
    self:setContentSize(self._bg:getContentSize().width, self._bg:getContentSize().height)

    self._bgTitle = self._bg:getChildByFullName("bgTitle")
    self._bgTitle:setPositionY(MAX_SCREEN_HEIGHT - 30 - (MAX_SCREEN_HEIGHT-MAX_DESIGN_HEIGHT)*0.5)
    self._bgTitle:setCascadeOpacityEnabled(true)

    self._titleLabel = self._bgTitle:getChildByFullName("titleLabel")
    UIUtils:setTitleFormat(self._titleLabel, 1)

    self._topBar = self._bg:getChildByFullName("topBar")
    self._topBar:setPosition(self._topBar:getPositionX() + (1136 - MAX_SCREEN_WIDTH)*0.5, 
        MAX_SCREEN_HEIGHT - 26 - (MAX_SCREEN_HEIGHT-MAX_DESIGN_HEIGHT)*0.5)

    self._timeLabel = self._bg:getChildByFullName("topBar.time")
    self._timeLabel:setString(TimeUtils.date("%H:%M", ModelManager:getInstance():getModel("UserModel"):getCurServerTime()))



    self._battery = self._bg:getChildByFullName("topBar.batteryBg.battery")
    self._battery:setPercent(sdkMgr:getBatteryPercent() * 100)

    self._bgRecord = self._bg:getChildByFullName("bgRecord")
    self._bgRecord:setCascadeOpacityEnabled(true)

    self._rewardNode = self:getUI("bg.bgRecord.rewardNode")
    self._rewardNode:setCascadeOpacityEnabled(true)
    self._rewardNode:ignoreContentAdaptWithSize(false)

    self:getUI("bg.bgRecord.crossNode"):setCascadeOpacityEnabled(true)

    self._pointList = {}
    table.insert(self._pointList, self:getUI("bg.bgRecord.crossNode.crossIcon3_1"))
    table.insert(self._pointList, self:getUI("bg.bgRecord.crossNode.crossIcon2_1"))
    table.insert(self._pointList, self:getUI("bg.bgRecord.crossNode.crossIcon1_1"))

    self._crossList = {}
    table.insert(self._crossList, self:getUI("bg.bgRecord.crossNode.crossIcon3"))
    table.insert(self._crossList, self:getUI("bg.bgRecord.crossNode.crossIcon2"))
    table.insert(self._crossList, self:getUI("bg.bgRecord.crossNode.crossIcon1"))

    self._crossBgList = {}
    table.insert(self._crossBgList, self:getUI("bg.bgRecord.bgCross3"))
    table.insert(self._crossBgList, self:getUI("bg.bgRecord.bgCross2"))
    table.insert(self._crossBgList, self:getUI("bg.bgRecord.bgCross1"))

    self._winTimesLabel = self._bgRecord:getChildByFullName("winTimesLabel")
    self._winTimesLabel:setString("0/12")
    self._winTimesLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._winTimesBar = self._bgRecord:getChildByFullName("winTimesBar")
    self._winTimesBar:setPercent(0)

    self._giveupBtn = self._bg:getChildByFullName("giveupBtn")
    self._giveupBtn:setPositionX(MAX_SCREEN_WIDTH < 1136 and 60 or 30)
    self:registerClickEvent(self._giveupBtn, specialize(self.onGiveUp, self))

    self._recordNode = self._bg:getChildByFullName("recordNode")
    self._recordNode:setCascadeOpacityEnabled(true)
--    self._winCountLabel = self._recordNode:getChildByFullName("winCountLabel")
--    self._winCountLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--    self._winCountLabel:setColor(cc.c3b(244,219,103))
--    self._winCountLabel:enable2Color(1, cc.c4b(144,91,13,255))
--    self._winCountLabel:setVisible(false)
--    self._winCountLabel:setPosition(110, 208)

    self._winCountLabel = cc.LabelBMFont:create("1", UIUtils.bmfName_hduel_win)
    self._winCountLabel:setPosition(80, 185)
    self._winCountLabel:setVisible(false)
    self._recordNode:addChild(self._winCountLabel, 9)


    self._btnFireMc = mcMgr:createViewMC("jiaofenganiuguang_duizhanui", true, false)
    self._btnFireMc:setPositionX(-20)
    self._btnFireMc:setCascadeOpacityEnabled(true)
    self._btnFireMc:setOpacity(60)
    self._fireClipNode = cc.ClippingNode:create()
    self._fireClipNode:setPosition(170,35)
    local mask = ccui.Scale9Sprite:createWithSpriteFrameName("mask_btn_heroDuel.png")
    mask:setCapInsets(cc.rect(33, 1, 1, 1))
    mask:setContentSize(322, 54)
--    self._fireClipNode:setInverted(true)
    self._fireClipNode:setStencil(mask)
    self._fireClipNode:setAlphaThreshold(0.5)
    self._fireClipNode:addChild(self._btnFireMc)
    self._fireClipNode:setCascadeOpacityEnabled(true)

    self._btnNode = self._bg:getChildByFullName("btnNode")
    self._btnNode:setCascadeOpacityEnabled(true)
    self._btnNode:setZOrder(2)

    self._continueBtn = self._btnNode:getChildByFullName("continueBtn")
    self._continueBtn:setCascadeOpacityEnabled(true)
    local continueLabel = self._continueBtn:getChildByFullName("btnLabel")
    continueLabel:setColor(cc.c3b(248,244,201))
    continueLabel:enableOutline(cc.c4b(136,33,27,255),2)
    continueLabel:setFontName(UIUtils.ttfName_Title)
    local continueMc = mcMgr:createViewMC("jixuzujian_duizhanui", true, false)
    continueMc:setPosition(85, 36)
    continueMc:setScaleX(-1)
    continueMc:setCascadeOpacityEnabled(true)
    self._continueBtn:addChild(continueMc, 1)

    self:registerClickEvent(self._continueBtn, specialize(self.onContinue, self))

    self._bgTips = self._btnNode:getChildByFullName("bgTips")
    self._bgTips:setCascadeOpacityEnabled(true)

    local tipsLabel = self._bgTips:getChildByFullName("tipsLabel")
    tipsLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    tipsLabel:setString("您的卡组还没有组建完成哦~")

    self._unopenBtn = self._btnNode:getChildByFullName("unopenBtn")
    self._unopenBtn:setCascadeOpacityEnabled(true)
    local unopenLabel = self._unopenBtn:getChildByFullName("btnLabel")
    unopenLabel:setColor(cc.c3b(224,224,224))
    unopenLabel:enableOutline(cc.c4b(35,35,35,255),2)
    unopenLabel:setString("暂未开启")
    self:registerClickEvent(self._unopenBtn, function()
        self._viewMgr:showTip(lang("HERODUEL1"))
    end)
    self._unopenDesLabel = self._btnNode:getChildByFullName("unopenDesLabel")
    self._unopenDesLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
    self._unopenDesLabel:setString(lang("HERODUEL12"))

    self._fightBtn = self._btnNode:getChildByFullName("fightBtn")
    self._fightBtn:setCascadeOpacityEnabled(true)
    local fightLabel = self._fightBtn:getChildByFullName("btnLabel")
    fightLabel:setColor(cc.c3b(248,244,201))
    fightLabel:enableOutline(cc.c4b(136,33,27,255),2)
    fightLabel:setFontName(UIUtils.ttfName_Title)
    local fightMc = mcMgr:createViewMC("kaishijiaofeng_duizhanui", true, false)
    fightMc:setPosition(95, 36)
    fightMc:setCascadeOpacityEnabled(true)
    self._fightBtn:addChild(fightMc, 1)
    self._fightBtn:addChild(self._fireClipNode)

    self._forbiddenLabel = cc.Label:createWithTTF(lang("HERODUEL13"), UIUtils.ttfName, 22)
    self._forbiddenLabel:setPositionX(202)
    self._forbiddenLabel:setVisible(false)
    self._btnNode:addChild(self._forbiddenLabel)

    self:registerClickEvent(self._fightBtn, specialize(self.onFight, self))

    self._boxNode = self._bg:getChildByFullName("boxNode")
    self:registerClickEvent(self._boxNode, specialize(self.onGetAward, self))

    self:reflashUI(self._mainData)

    local forbiddenTime = self._mainData.banMT or 0
    if forbiddenTime > 0 then
        self._forbiddenLabel:setVisible(true)

        local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
        local leftTime = forbiddenTime - nowTime
        if leftTime > 0 then
            local tipStr = string.gsub(lang("HERODUEL13"),"{$time}", TimeUtils.getTimeStringMS(leftTime))
            self._forbiddenLabel:setString(tipStr)
        else
            self._forbiddenLabel:setVisible(false)
        end
    end

    self._updateId = ScheduleMgr:regSchedule(500, self, function(self, dt)
        self._timeLabel:setString(TimeUtils.date("%H:%M", ModelManager:getInstance():getModel("UserModel"):getCurServerTime()))

        if self._forbiddenLabel:isVisible() then
            local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
            local leftTime = forbiddenTime - nowTime
            if leftTime > 0 then
                local tipStr = string.gsub(lang("HERODUEL13"),"{$time}", TimeUtils.getTimeStringMS(leftTime))
                self._forbiddenLabel:setString(tipStr)
            else
                self._forbiddenLabel:setVisible(false)
            end
        end
    end)

    if self._shareNode then
        self._shareNode:setVisible(false)
    end
end

--分享按钮
function HeroDuelMainLayer:addShareBtn()
    if self._shareNode ~= nil then
        self._shareNode:removeFromParent(true)
        self._shareNode = nil
    end

    self._shareNode = require("game.view.share.GlobalShareBtnNode").new({mType = "ShareHeroDuelModel"})
    self._shareNode:setPosition(-25, 48)
    self._shareNode:setCascadeOpacityEnabled(true, true)
    self:getUI("bg.btnNode"):addChild(self._shareNode, 10) 
    self._shareNode:registerClick(function()
        return {moduleName = "ShareHeroDuelModel", winNum = self._winNum}
        end)
end

function HeroDuelMainLayer:reflashUI(data)
    self:updateState(data.status)

    if self._winNum and data.wins > self._winNum then
        self._isWin = true
    elseif self._loseNum and data.loses > self._loseNum then
        self._isWin = false
    end

    self._winNum = data.wins or 0
    self._loseNum = data.loses or 0

    if self._winNum == 12 or self._loseNum == 3 then
        self._gameOver = true
    end

    local rewardData = tab:HeroDuelAward(self._winNum).award
    self:updateRewards(rewardData)

    for crossI = 1, #self._crossList do 
        self._crossList[crossI]:setVisible(crossI <= (data.loses or 0))
        self._pointList[crossI]:setVisible(crossI > (data.loses or 0))
    end


    self._winTimesBar:setPercent(self._winNum /12*100)
    self._winTimesLabel:setString(self._winNum .. "/12")
    self._winCountLabel:setString(tostring(self._winNum))
end

-- 更新状态
-- @param stateType 1:继续组建  2:开始交锋 3:领奖
function HeroDuelMainLayer:updateState(stateType)
    self._giveupBtn:setVisible(false)
    self._recordNode:setVisible(false)
    self._continueBtn:setVisible(false)
    self._bgTips:setVisible(false)
    self._unopenBtn:setVisible(false)
    self._unopenDesLabel:setVisible(false)
    self._fightBtn:setVisible(false)
    self._boxNode:setVisible(false)

    self:addShareBtn()  --by wangyan

    if stateType == 1 then
        self._continueBtn:setVisible(true)
        if self._fireClipNode ~= nil and self._fireClipNode:getParent() ~= nil then
            self._fireClipNode:retain()
            self._fireClipNode:removeFromParent()
            self._continueBtn:addChild(self._fireClipNode)
            self._fireClipNode:release()
        end
        self._bgTips:setVisible(true)
        self._recordNode:setVisible(true)
        self._titleLabel:setString("选取卡组")

    elseif stateType == 2 then
        if self._fireClipNode ~= nil and self._fireClipNode:getParent() ~= nil then
            self._fireClipNode:retain()
            self._fireClipNode:removeFromParent()
            self._fightBtn:addChild(self._fireClipNode)
            self._fireClipNode:release()
        end
        self._giveupBtn:setVisible(true)
        self._recordNode:setVisible(true)
        self._fightBtn:setVisible(true)
        self._titleLabel:setString("匹配交锋")

        
    elseif stateType == 3 then
        self._boxNode:setVisible(true)
        self._titleLabel:setString("领取奖励")

--        self:updateBoxMc()
    end

    if self._mainData.open ~= 1 then
        self._unopenBtn:setVisible(true)
        self._unopenBtn:setVisible(true)
        self._unopenDesLabel:setVisible(true)
        self._fightBtn:setVisible(false)
        self._continueBtn:setVisible(false)
        self._bgTips:setVisible(false)
        return
    end
end

function HeroDuelMainLayer:onGiveUp()
    local rewardData = tab:HeroDuelAward(self._winNum).award
    self._viewMgr:showDialog("heroduel.HeroDuelGiveUpView", {data = rewardData, callBack = specialize(self.onGetAward, self)})
end

function HeroDuelMainLayer:onGetAward()
    self._serverMgr:sendMsg("HeroDuelServer", "hDuelGetSingleAward", {}, true, {}, function(result)
        if result.award ~= nil then
            DialogUtils.showGiftGet(result.award)
        end
    end)
end

function HeroDuelMainLayer:updateShieldMC(winNum)
    self._winCountLabel:setVisible(false)
    local shieldType = nil
    if winNum >= 9 then
        shieldType = self._kShieldType[4]
    elseif winNum >= 5 then
        shieldType = self._kShieldType[3]
        
    elseif winNum >= 1 then
        shieldType = self._kShieldType[2]

    else
        shieldType = self._kShieldType[1]

    end

    local fontX = shieldType.fontX
    fontX = winNum == 4 and (fontX - 7) or fontX
    self._winCountLabel:setPosition(80 + fontX, 185 + shieldType.fontY)
    if self._shieldMC ~= nil then
        if shieldType.name == self._shieldMC.name then
            self._shieldMC:gotoAndPlay(1)

            if winNum > 0 then
                self._shieldMC:addCallbackAtFrame(11, function (_, sender)
                    self._winCountLabel:setVisible(true)
                end)

            end
            self._shieldMC:addEndCallback(function (_, sender)
                self._shieldMC:stop()
            end)
            return
        end
        self._shieldMC:removeFromParent(true)
        self._shieldMC = nil
    end
    self._shieldMC = mcMgr:createViewMC(shieldType.name, false, false)
    self._shieldMC:setScale(shieldType.scale)
    self._shieldMC.name = shieldType.name
    self._shieldMC:setPosition(69 + shieldType.mcX, 174 + shieldType.mcY)
    self._recordNode:addChild(self._shieldMC)
    self._shieldMC:gotoAndPlay(1)


    if winNum > 0 then
        self._shieldMC:addCallbackAtFrame(11, function (_, sender)
            self._winCountLabel:setVisible(true)
        end)
    end
end

-- 更新宝箱动画
function HeroDuelMainLayer:updateBoxMc()

    if self._boxMC == nil then
        local yanhuaMc = mcMgr:createViewMC("yanhua_gezhongdun", false, true)
        yanhuaMc:setPosition(339, 150)
        self._boxNode:addChild(yanhuaMc)

        self._boxMC = mcMgr:createViewMC("baoxiang_gezhongdun", true, false,function(_,sender )
		    sender:gotoAndPlay(26)
	    end)
        self._boxMC:setPosition(109, 70)
        self._boxNode:addChild(self._boxMC)
    end
end

-- 更新奖励信息
function HeroDuelMainLayer:updateRewards(rewardData)
    self._rewardNode:removeAllChildren()
    self._rewardNode:setPositionX(76)
    local infoEndPos = -10
    local rewardSpace = 15
    for i = 1, #rewardData do
        local cData = rewardData[i]

        local icon = nil
        local iconWidth = 53
        if cData[1] == "tool" then
            local iconPath = tab:Tool(cData[2]).art
            icon = cc.Sprite:createWithSpriteFrameName(iconPath .. ".png")
        else
            local iconPath = IconUtils.resImgMap[cData[1]]

            if iconPath == nil then
                local itemId = tonumber(IconUtils.iconIdMap[cData[1]])
                local toolD = tab:Tool(itemId)
                iconPath = IconUtils.iconPath .. toolD.art .. ".png"
                icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD})
            end
            icon = cc.Sprite:createWithSpriteFrameName(iconPath)
        end
        icon:setScale(iconWidth / icon:getContentSize().width)
        icon:setPosition(infoEndPos + iconWidth / 2 + rewardSpace, 30)
        self._rewardNode:addChild(icon)
        infoEndPos = icon:getPositionX() + iconWidth / 2

        local countTxt = tostring(cData[3])
        local rewardCount = cc.Label:createWithTTF("x" .. countTxt, UIUtils.ttfName, 26) 
        rewardCount:setPosition(infoEndPos + rewardCount:getContentSize().width / 2 + 2, 30)
        self._rewardNode:addChild(rewardCount)
        infoEndPos = rewardCount:getPositionX() + rewardCount:getContentSize().width / 2
    end
    self._rewardNode:setPositionX(76 + (self._rewardNode:getContentSize().width - infoEndPos)*0.5)
end

function HeroDuelMainLayer:onShow()
    self:playOnShowAni()

    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.5),
        cc.CallFunc:create(function()
            if self._gameOver then
                if self._shieldMC then
                    self._shieldMC:removeFromParent(true)
                    self._shieldMC = nil
                end
                self:updateBoxMc()

            else
                self:updateShieldMC(self._winNum)
            end

            if self._shareNode then
                self._shareNode:setVisible(true)
            end
        end)
    ))
end


function HeroDuelMainLayer:playOnShowAni()
    self._bgRecord:setPositionX(self._bgRecord:getPositionX() + 60)
    self._bgTitle:setPositionY(self._bgTitle:getPositionY() + 10)
    self._btnNode:setPositionY(self._btnNode:getPositionY() - 20)
    self._bgRecord:setOpacity(0)
    self._bgTitle:setOpacity(0)
    self._btnNode:setOpacity(0)
    self._giveupBtn:setOpacity(0)

    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.2),
        cc.CallFunc:create(function()
            self._bgRecord:runAction(cc.Sequence:create(
                cc.Spawn:create(cc.EaseOut:create(cc.MoveBy:create(0.1, cc.p(-80,0)),3), cc.FadeIn:create(0.1)),
                cc.MoveBy:create(0.1, cc.p(20,0))
            ))

            self._bgTitle:runAction(cc.Sequence:create(
                cc.Spawn:create(cc.EaseOut:create(cc.MoveBy:create(0.1, cc.p(0, -15)),3), cc.FadeIn:create(0.1)),
                cc.MoveBy:create(0.1, cc.p(0,5))
            ))

            self._btnNode:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.1),
                cc.Spawn:create(cc.EaseOut:create(cc.MoveBy:create(0.1, cc.p(0,25)),3), cc.FadeIn:create(0.1)),
                cc.MoveBy:create(0.1, cc.p(0,-5))
            ))

            self._giveupBtn:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.2),
                cc.FadeIn:create(0.1)
            ))
        end)
    ))
end

function HeroDuelMainLayer:onTop()
    if self._isWin == false then
        local curPoint = self._pointList[self._loseNum]
        curPoint:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.2),
            cc.Spawn:create(
                cc.ScaleTo:create(0.2, 0),
                cc.FadeOut:create(0.2)
            )
        ))

        local curCross = self._crossList[self._loseNum]
        curCross:setScale(7)
        curCross:setVisible(true)
        curCross:setOpacity(0)
        curCross:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.4),
            cc.Spawn:create(
                cc.EaseIn:create(cc.ScaleTo:create(0.2, 0.9), 3),
                cc.FadeIn:create(0.05)
            ),
            cc.ScaleTo:create(0.05, 1)
        ))
    
    elseif self._isWin == true and not self._gameOver then
        if self._shieldMC then
            self._shieldMC:setVisible(false)

        end
        self._winCountLabel:setVisible(false)

        self:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.2),
            cc.CallFunc:create(function()
                if self._shieldMC then
                    self._shieldMC:setVisible(true)
                end
                self:updateShieldMC(self._winNum)

                -- 评论引导
                local param = {inType = 3, num = self._winNum}
                local isPop, popData = self._modelMgr:getModel("CommentGuideModel"):checkCommentGuide(param)
                if isPop == true then
                    self._viewMgr:showDialog("global.GlobalCommentGuideView", popData, true)
                end
            end)))
    end
    
    self._isWin = nil
    
    if self._gameOver then
        if self._shieldMC then
            self._shieldMC:removeFromParent(true)
            self._shieldMC = nil
        end
        self:updateBoxMc()
    end
    
   
    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(function()
            local errorType = self._hModel:getErrorType()
            if errorType ~= nil then
                self._viewMgr:showTip(lang(self._kErrorTpStr[errorType]))
            end
        end)
    ))
end

function HeroDuelMainLayer:onContinue()
    self._serverMgr:sendMsg("HeroDuelServer", "hDuelGetSelectInfo", {}, true, {}, function(result)
        self._mainCallBack({acType = "continue", toSelect = result.toSelect})
    end)
end

function HeroDuelMainLayer:onFight()
    --罚站开始时间戳
    local forbiddenTime = self._mainData.banMT or 0

    self._netTimeStamp = socket.gettime()
    self._serverMgr:sendMsg("HeroDuelServer", "hDuelMatchRival", {}, true, {}, function(result)
        if result.mode == "punish" then
            -- 战斗异常退出导致罚站
            if forbiddenTime > 0 then
                local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
                local leftTime = forbiddenTime - nowTime
                if forbiddenTime > 0 and leftTime > 0 then
                    local tipStr = string.gsub(lang("HERODUEL23"),"{$time}", TimeUtils.getTimeStringMS(leftTime))
                    self._viewMgr:showTip(tipStr)
                    return
                end
            end

            -- 匹配出现异常，让玩家等待
            local matchErrorTime = self._hModel:getMatchError()
            if (matchErrorTime and matchErrorTime > 0) 
                or (result.banMT and result.banMT > 0)
            then
                local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
                local leftTime = result.banMT - nowTime
                local tipStr = "由于当前匹配的人数过多，请等待" .. TimeUtils.getTimeString(leftTime)
                self._viewMgr:showTip(tipStr)
                return
            end
        end

        -- 杀进程罚站结束后，获得上一局结果
        if result.win == nil then
            if socket.gettime() - self._netTimeStamp > result.delay then
                self._viewMgr:showDialog("global.GlobalSelectDialog",
                    {desc = "当前网络状态不稳定，建议在稳定的网络环境下游戏，是否要继续匹配？",titileTip = true,
                        callback1 = function()
                            self._viewMgr:showDialog("heroduel.HeroDuelMatchView", {callback = specialize(self.onTop, self)})
                        end
                     }
                )
            else
                self._viewMgr:showDialog("heroduel.HeroDuelMatchView", {callback = specialize(self.onTop, self)})
            end
        else
            self._viewMgr:showTip(lang("HERODUEL22"))
        end
    end)
end

-- 改变放弃按钮位置（有活动和无活动）
function HeroDuelMainLayer:setGiveUpBtnPos(hasActivity)
    self._giveupBtn:setPositionY(hasActivity and 418 or 500)
end


-- 交锋关闭
function HeroDuelMainLayer:onHDuelClose()
    self._mainData.open = 0
    if not self._hModel:getIsCorrectState(self._hModel.TEAM_BAN) then
        self._viewMgr:showTip(lang("HERODUEL16"))
    end
    self:updateState(self._mainData.status)
end

-- 交锋开启
function HeroDuelMainLayer:onHDuelOpen()
    self._mainData.open = 1
    if not self._hModel:getIsCorrectState(self._hModel.TEAM_BAN) then
        self._viewMgr:showTip(lang("HERODUEL17"))
    end
    self:updateState(self._mainData.status)
end

function HeroDuelMainLayer:onDestroy()
    if self._updateId then
        ScheduleMgr:unregSchedule(self._updateId)
        self._updateId = nil
    end
end
return HeroDuelMainLayer