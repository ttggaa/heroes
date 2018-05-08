--
-- Author: <ligen@playcrab.com>
-- Date: 2016-08-31 16:32:03
--
local CloudCityBattleView = class("CloudCityBattleView", BasePopView)

function CloudCityBattleView:ctor(data)
    self.super.ctor(self)

    self._formationModel = self._modelMgr:getModel("FormationModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._cloudCityModel = self._modelMgr:getModel("CloudCityModel")

    self._kDarkC3b = cc.c3b(128, 128, 128)

    self.popAnim = false

    self._stageId = data.stageId
    self.overCallBack = data.callBack
    self.resetCallBack = data.resetCallBack
    self._selectViewCallBack = data.selectViewCallBack
    self.stageList = nil

    -- 选择入口的subId
    self._subId = 0

    -- 最终进入战斗的subId
    self._battleSubId = 1

    self._fightTab = tab.towerFight
end

function CloudCityBattleView:getMaskOpacity()
    return 229
end

-- 初始化UI后会调用, 有需要请覆盖
function CloudCityBattleView:onInit()
    self._bgNode = self:getUI("bg")
    self._centerLayer = self:getUI("bg.layer")

    local closeBtn = self:getUI("bg.closeNode.closeBtn")
    self:registerClickEvent(closeBtn, function()
        self:close()
        UIUtils:reloadLuaFile("cloudcity.CloudCityBattleView")
    end )

    closeBtn:setPositionX(ADOPT_IPHONEX and 41 or 161)


    self._bgLeft = self._centerLayer:getChildByFullName("bgLeft")
    self._bgRight = self._centerLayer:getChildByFullName("bgRight")

    self._bgAniLeft = self._centerLayer:getChildByFullName("bgAniLeft")
    self._bgAniRight = self._centerLayer:getChildByFullName("bgAniRight")

    self:registerClickEvent(self._bgLeft, function()
        self:onChangeBoss("left")
    end )

    self:registerClickEvent(self._bgRight, function()
        self:onChangeBoss("right")
    end )
     
    self._leftSelectMc = mcMgr:createViewMC("xuanzhongkuang_qianjin", true)
    self._leftSelectMc:setScaleX(-1)
    self._leftSelectMc:setPosition(self._bgLeft:getContentSize().width/2 + 28, self._bgLeft:getContentSize().height/2 + 26)
    self._leftSelectMc:setVisible(false)
    self._bgAniLeft:addChild(self._leftSelectMc)

    local aniSpritList = self._leftSelectMc:getChildren()
    for i= 1, #aniSpritList do
        local sprite = aniSpritList[i]:getChildren()[1]
        sprite:setHue(180)
        sprite:setSaturation(30)
    end

    self._rightSelectMc = mcMgr:createViewMC("xuanzhongkuang_qianjin", true)
    self._rightSelectMc:setPosition(self._bgRight:getContentSize().width/2+28, self._bgRight:getContentSize().height/2 + 26)
    self._rightSelectMc:setVisible(false)
    self._bgAniRight:addChild(self._rightSelectMc)

    self._leftBuffBg = self._centerLayer:getChildByFullName("buffBgLeft")
    self._rightBuffBg = self._centerLayer:getChildByFullName("buffBgRight")

    local maxRealWidth = ADOPT_IPHONEX and 1136 or MAX_SCREEN_WIDTH
    self._leftBuffBg:setPositionX((MAX_DESIGN_WIDTH - maxRealWidth)*0.5)
    self._rightBuffBg:setPositionX(MAX_DESIGN_WIDTH + (maxRealWidth - MAX_DESIGN_WIDTH)*0.5)

    self._bgFlag1 = self:getUI("bg.layer.bgFlag1")
    self._bgFlag1:setContentSize(278, 92 + (MAX_SCREEN_HEIGHT - MAX_DESIGN_HEIGHT) * 0.5)

    local leftTabData = self._fightTab[self:getFightId(self._stageId, 1)]
    self._leftBuffLabel = RichTextFactory:create(lang(leftTabData.buffDes), 320, 40)
    self._leftBuffLabel:formatText()
    self._leftBuffLabel:setVerticalSpace(7)
    local lW = self._leftBuffLabel:getInnerSize().width
    self._leftBuffLabel:setPosition(lW / 2, 42)
	UIUtils:alignRichText(self._leftBuffLabel,{hAlign = "left"})
    self._leftBuffBg:addChild(self._leftBuffLabel, 99)

    local rightTabData = self._fightTab[self:getFightId(self._stageId, 2)]
    self._rightBuffLabel = RichTextFactory:create(lang(rightTabData.buffDes), 320, 40)
    self._rightBuffLabel:formatText()
    self._rightBuffLabel:setVerticalSpace(7)
    local rW = self._rightBuffLabel:getInnerSize().width
    self._rightBuffLabel:setPosition(rW / 2 - 27, 42)
	UIUtils:alignRichText(self._rightBuffLabel,{hAlign = "right"})
    self._rightBuffBg:addChild(self._rightBuffLabel, 99)

    self._battleBtn = self._centerLayer:getChildByFullName("battleBtn")
    self:registerClickEvent(self._battleBtn, function()
        self:onBattle()
    end )

    self._battleAniLeft = mcMgr:createViewMC("anniutexiao_qianjin", true)
    self._battleAniLeft:setPosition(135,124)
    self._battleBtn:addChild(self._battleAniLeft)

    local aniSpritList = self._battleAniLeft:getChildren()
    for i= 1, #aniSpritList do
        local sprite = aniSpritList[i]:getChildren()[1]
        sprite:setBrightness(-15)
        sprite:setContrast(-6)
        sprite:setHue(180)
        sprite:setSaturation(10)
    end

    self._battleAniRight = mcMgr:createViewMC("anniutexiao_qianjin", true)
    self._battleAniRight:setPosition(135,124)
    self._battleBtn:addChild(self._battleAniRight)

    self._passLabel = self._centerLayer:getChildByFullName("passLabel")

    local watchBtn = self._centerLayer:getChildByFullName("watchBtn")
    self:registerClickEvent(watchBtn, function()
        self:onWatch()
    end )

    self:registerClickEventByName("bg.layer.sweepBtn", function()
        local openFloor, openStage = self:getFloorAndStageById(self._stageId)
        self._viewMgr:showDialog("cloudcity.CloudCityLevelSelectView",
            {curFloor = openFloor, curStage = openStage, callback = specialize(self.showLevelSelect, self)},
             true)
    end)

    -- 层奖励信息
    self._rewardNode = self._centerLayer:getChildByFullName("rewardNode")
    self:addRewardInfo()

    self:onChangeBoss("left", true)
end

-- 通关奖励信息
function CloudCityBattleView:addRewardInfo() 
    local infoEndPos = self._passLabel:getPositionX() + self._passLabel:getContentSize().width / 2

    local rewardDataArr = nil
    local rewardSpace = 15
    if self._cloudCityModel:getIsFirstFight(self._stageId) then
        rewardDataArr = tab:TowerStage(self._stageId).firstReward
        self._passLabel:setString("首通奖励")

        rewardSpace = 15
    else
        rewardDataArr = tab:TowerStage(self._stageId).reward
        self._passLabel:setString("通关奖励")

        rewardSpace = 30
    end

    local iconWidth = 72
    local offsetX = 8
    for i = 1, #rewardDataArr do 
        local rData = rewardDataArr[i]

        local itemType = rData[1]
        local itemId = nil
        if itemType == "tool" then
            itemId = rData[2]
        else 
            itemId = IconUtils.iconIdMap[itemType]
        end
        local toolD = tab:Tool(tonumber(itemId))
        local rewardIcon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD, num = rData[3]})
        rewardIcon:setScale(iconWidth / rewardIcon:getContentSize().width)
        rewardIcon:setPosition(39+(i - 1) * (iconWidth + offsetX) , 15)
        self._rewardNode:addChild(rewardIcon)
    end
end


--function CloudCityBattleView:onShow()
--    self:lock(-1)
--    self._centerNode:setScale(0.8)
--    self._leftNode:setPositionX(self._leftNode:getPositionX() + 20)
--    self._rightNode:setPositionX(self._rightNode:getPositionX() - 20)
--    self._desLabel:setPositionY(self._desLabel:getPositionY() - 10)
--    self._passLabel:setPositionY(self._passLabel:getPositionY() + 10)
--    self._rewardNode:setPositionY(self._rewardNode:getPositionY() + 10)
--    self._selectArrow:setRotation(-90)

--    ScheduleMgr:delayCall(100, self, function()
--        self._centerNode:setVisible(true)
--        self._centerNode:runAction(cc.Sequence:create(
--            cc.EaseBackOut:create(cc.ScaleTo:create(0.2, 1)), cc.CallFunc:create(function()
--                self._leftNode:setVisible(true)
--                self._rightNode:setVisible(true)
--                self._bottomNode:setVisible(true)
--                self._leftNode:runAction(cc.EaseBackOut:create(cc.MoveBy:create(0.2, cc.p(-20, 0))))
--                self._rightNode:runAction(cc.EaseBackOut:create(cc.MoveBy:create(0.2, cc.p(20, 0))))
--                self._desLabel:runAction(cc.Sequence:create(cc.MoveBy:create(0.1, cc.p(0, 20)), cc.MoveBy:create(0.1, cc.p(0, -10))))
--                self._passLabel:runAction(cc.Sequence:create(cc.MoveBy:create(0.1, cc.p(0, -20)), cc.MoveBy:create(0.1, cc.p(0, 10))))
--                self._rewardNode:runAction(cc.Sequence:create(cc.MoveBy:create(0.1, cc.p(0, -20)), cc.MoveBy:create(0.1, cc.p(0, 10))))
--            end)))
--    end)

--    ScheduleMgr:delayCall(500, self, function()
--        self:onChangeBoss("left", true)
--        self:unlock()
--    end)
--end

function CloudCityBattleView:addLoading(loadingStr)
    if self._lockMask ~= nil then
        self._lockMask:removeFromParent()
        self._lockMask = nil
    end

    self._lockMask = ccui.Layout:create()
    self._lockMask:setBackGroundColorOpacity(255)
    self._lockMask:setBackGroundColorType(1)
    self._lockMask:setBackGroundColor(cc.c3b(0,0,0))
    self._lockMask:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._lockMask:setTouchEnabled(true)
    self._lockMask:setOpacity(230)
    self._bgNode:addChild(self._lockMask, 99)
    
 	cc.SpriteFrameCache:getInstance():addSpriteFrames("asset/anim/datianshiimage.plist", "asset/anim/datianshiimage.png")
    
    local tianshiMc = mcMgr:createMovieClip("run_datianshi")
	tianshiMc:setPurityColor(255, 255, 204)
 	tianshiMc:setScale(0.35)
 	tianshiMc:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 + 30)
 	self._lockMask:addChild(tianshiMc)

    local label = cc.Label:createWithTTF(loadingStr, UIUtils.ttfName, 22)
    label:setPosition(MAX_SCREEN_WIDTH * 0.5 - 10, MAX_SCREEN_HEIGHT * 0.5 -10)
    self._lockMask:addChild(label)
    
    self._loadingMc = mcMgr:createViewMC("xiayichangzhandou_qianjin", true)
    self._loadingMc:setPosition(label:getPositionX() + label:getContentSize().width/2 + 10, MAX_SCREEN_HEIGHT * 0.5 -10)
    self._lockMask:addChild(self._loadingMc)
end

function CloudCityBattleView:removeLoading()
    if self._lockMask ~= nil then
        self._lockMask:removeFromParent()
        self._lockMask = nil
    end
end

function CloudCityBattleView:onChangeBoss(changeType)
    if (changeType == "left" and self._subId == 1) or (changeType == "right" and self._subId == 2) then
        return
    end

    if changeType == "left" then
        self._battleAniLeft:setVisible(true)
        self._battleAniRight:setVisible(false)
        self._rightSelectMc:setVisible(false)
        self._leftSelectMc:setVisible(true)
        self._bgLeft:setBrightness(0)
        self._bgRight:setBrightness(-70)

        self._subId = 1
    else
        self._battleAniLeft:setVisible(false)
        self._battleAniRight:setVisible(true)
        self._leftSelectMc:setVisible(false)
        self._rightSelectMc:setVisible(true)
        self._bgLeft:setBrightness(-70)
        self._bgRight:setBrightness(0)
        self._subId = 2
    end
end

-- NPC图标设置亮或暗
function CloudCityBattleView:setObjectColor(object, color)
    for k, v in pairs(object:getChildren()) do
        if v:getChildren() ~= nil and next(v:getChildren()) ~= nil  then
            self:setObjectColor(v, color)
        else
            v:setColor(color)
        end
    end
end

function CloudCityBattleView:onBattle()
    local battle = function(battleData)
        self._serverMgr:sendMsg("CloudyCityServer", "beforeAttackCloudyCity", {stageId = self._stageId, 
            subId = self:getFightId(self._stageId, self._battleSubId), serverInfoEx = BattleUtils.getBeforeSIE()}, true, {}, function(result)

            self._token = result.token
            self._viewMgr:popView()
            BattleUtils.enterBattleView_CloudCity(BattleUtils.jsonData2lua_battleData(result["atk"]),
                self:getFightId(self._stageId, self._battleSubId), 
                self:getFightId(self._stageId, self._buffSubId),
                false, -- true为看录像 
                false,
                specialize(self.onBattleResult, self),
                specialize(self.onBattleQuit, self))
        end)
    end

    -- 设置两个子关卡过滤的兵团和位置
    local filterList1,maxCount1 = self:getFilterListAndCounts(self._stageId, 1)
    local subData1 = self._fightTab[self:getFightId(self._stageId, 1)]
    local filterPosList1 = subData1.posi or {}
    self._formationModel:dealWithFormationDataByTypeWithCondition(self._formationModel.kFormationTypeCloud1,filterList1,filterPosList1,maxCount1)

    local filterList2, maxCount2 = self:getFilterListAndCounts(self._stageId, 2)
    local subData2 = self._fightTab[self:getFightId(self._stageId, 2)]
    local filterPosList2 = subData2.posi or {}
    self._formationModel:dealWithFormationDataByTypeWithCondition(self._formationModel.kFormationTypeCloud2,filterList2,filterPosList2,maxCount2)


    -- buffId固定为第一次进入的子关卡buff
    if self.passSubId ~= nil then
        self._buffSubId = tonumber(self.passSubId)
    else
        self._buffSubId = self._subId
    end

    local formationType = nil
    local canBattle1 = nil
    local canBattle2 = nil
    if self._subId == 1 then
        formationType = self._formationModel.kFormationTypeCloud1

        if self.passSubId == "1" then
            self._battleSubId = 2
        else
            self._battleSubId = 1
        end

        if self.passSubId == "2" then
            canBattle1 = true
            canBattle2 = false
        else
            canBattle1 = false
            canBattle2 = true
        end
    elseif self._subId == 2 then
        formationType = self._formationModel.kFormationTypeCloud2

        if self.passSubId == "2" then
            self._battleSubId = 1
        else
            self._battleSubId = 2
        end

        if self.passSubId == "1" then
            canBattle1 = false
            canBattle2 = true
        else
            canBattle1 = true
            canBattle2 = false
        end
    end

    local teamData1 = {}
    local teamData2 = {}
    local teamScore1 = 0
    local teamScore2 = 0
    for gI = 1, 8 do
        local data1 = {}
        data1.id = subData1["m" .. gI] and subData1["m" .. gI][1] or 0
        data1.pos = subData1["m" .. gI] and subData1["m" .. gI][2] or 0
        if data1.id ~= 0 then
            teamScore1 = teamScore1 + tab:Npc(data1.id).score
        end
        table.insert(teamData1, data1)

        local data2 = {}
        data2.id = subData2["m" .. gI] and subData2["m" .. gI][1] or 0
        data2.pos = subData2["m" .. gI] and subData2["m" .. gI][2] or 0
        if data2.id ~= 0 then
            if tab:Npc(data2.id) == nil then
                self._viewMgr:showTip("请检查NPC表")
                return
            elseif tab:Npc(data2.id).score == nil then
                self._viewMgr:showTip("请检查NPC表中战力字段")
                return
            end
            teamScore2 = teamScore2 + tab:Npc(data2.id).score
        end
        table.insert(teamData2, data2)
    end

    if subData1["hero"] ~= nil then
        teamScore1 = teamScore1 + tab.npcHero[subData1["hero"]].score
    end

    if subData2["hero"] ~= nil then
        teamScore2 = teamScore2 + tab.npcHero[subData2["hero"]].score
    end

--    -- 第一次进入有坑洞关卡，显示解释动画
--    local needShowExplain = false
--    if tab:Setting("G_TEAM_TOWER_SHOW").value == self._stageId and not SystemUtils.loadAccountLocalData("showExpalin") then
--        SystemUtils.saveAccountLocalData("showExpalin", 1)
--        needShowExplain = true
--    end

    self._viewMgr:showView("formation.NewFormationView", {
        formationType = formationType,
        filter = {
            [self._formationModel.kFormationTypeCloud1] = filterList1,
            [self._formationModel.kFormationTypeCloud2] = filterList2
        },
        wall = {
            [self._formationModel.kFormationTypeCloud1] = filterPosList1,
            [self._formationModel.kFormationTypeCloud2] = filterPosList2
        },
        enemyFormationData = {
            [self._formationModel.kFormationTypeCloud1] = {
                team1 = teamData1[1].id,
                team2 = teamData1[2].id,
                team3 = teamData1[3].id,
                team4 = teamData1[4].id,
                team5 = teamData1[5].id,
                team6 = teamData1[6].id,
                team7 = teamData1[7].id,
                team8 = teamData1[8].id,
                g1 = teamData1[1].pos,
                g2 = teamData1[2].pos,
                g3 = teamData1[3].pos,
                g4 = teamData1[4].pos,
                g5 = teamData1[5].pos,
                g6 = teamData1[6].pos,
                g7 = teamData1[7].pos,
                g8 = teamData1[8].pos,
                filter = "",
                score = teamScore1,
                heroId = subData1["hero"],
            },
            [self._formationModel.kFormationTypeCloud2] = {
                team1 = teamData2[1].id,
                team2 = teamData2[2].id,
                team3 = teamData2[3].id,
                team4 = teamData2[4].id,
                team5 = teamData2[5].id,
                team6 = teamData2[6].id,
                team7 = teamData2[7].id,
                team8 = teamData2[8].id,
                g1 = teamData2[1].pos,
                g2 = teamData2[2].pos,
                g3 = teamData2[3].pos,
                g4 = teamData2[4].pos,
                g5 = teamData2[5].pos,
                g6 = teamData2[6].pos,
                g7 = teamData2[7].pos,
                g8 = teamData2[8].pos,
                filter = "",
                score = teamScore2,
                heroId = subData2["hero"],
            },
        },

        extend = {
            count = {
                [self._formationModel.kFormationTypeCloud1] = maxCount1,
                [self._formationModel.kFormationTypeCloud2] = maxCount2,
            },
            allowBattle = {
                [self._formationModel.kFormationTypeCloud1] = not(self.passSubId == "1"),
                [self._formationModel.kFormationTypeCloud2] = not(self.passSubId == "2")
            },
            enterBattle = {
                [self._formationModel.kFormationTypeCloud1] = canBattle1,
                [self._formationModel.kFormationTypeCloud2] = canBattle2
            },
            isShowBattleGuide = {
                [self._formationModel.kFormationTypeCloud1] = self:getIsShowExPlain(self:getFightId(self._stageId, 1)),
                [self._formationModel.kFormationTypeCloud2] = self:getIsShowExPlain(self:getFightId(self._stageId, 2))
            },
            cloudData1 = self._fightTab[self:getFightId(self._stageId, 1)],
            cloudData2 = self._fightTab[self:getFightId(self._stageId, 2)],
            isShowCloseTips = self.passSubId ~= nil,
--            isShowWallGuide = needShowExplain
        },
        callback = function(formationType1, formationData1, formationType2, formationData2)
            if self._battleSubId == 1 then
                battle(formationData1)

            elseif self._battleSubId == 2 then
                battle(formationData2)
            end
        end,
        closeCallback = function()
            self:onReset()
            self:removeLoading()
        end
    })
end

function CloudCityBattleView:onBattleResult(info, callback)
    -- dump(info, "battle info", 3)
    if info.isSurrender then
        callback(info)
        return
    end
    local hpPercent = self:getHpPercent(info.hp)
    local zzid = GameStatic.zzid3
    local args = {win = info.win and 1 or 0, 
                    zzid = zzid,
                    skillList = info.skillList,
                    serverInfoEx = info.serverInfoEx,
                    fId = self._battleSubId == 1 and self._formationModel.kFormationTypeCloud1 or self._formationModel.kFormationTypeCloud2,
                    hp = hpPercent,
                    time = info.time
                  }
    self._serverMgr:sendMsg("CloudyCityServer", "afterAttackCloudyCity", {token = self._token, stageId = self._stageId, subId = self:getFightId(self._stageId, self._battleSubId), args = json.encode(args)}, true, {}, function(result)
        if result["extract"] then
            dump(result["extract"]["hp"], "a", 10)
        end
        result.fightId = self:getFightId(self._stageId, self._battleSubId)
        result.subId = tostring(self._battleSubId)
        result.isFirstPass = self._cloudCityModel:getIsFirstFight(self._stageId)

        if info.win and result["cheat"] ~= 1 then
            -- 有奖励代表已过两关
            if result.reward ~= nil and next(result.reward) ~= nil then
                self._isGotoNext = false
                self.overCallBack(result)
                self:removeLoading()
                self._isClose = true
            else
                self.stageList = result.d.cloudycity.stageList
                if self.stageList ~= nil and next(self.stageList) ~= nil then
                    local passData = self.stageList[tostring(self._stageId)].subList
                    if passData ~= nil then
                        for k,_ in pairs(passData) do
                            self.passSubId = (tonumber(k) + 1) % 2 + 1
                            self.passSubId = tostring(self.passSubId)
                        end
                    end
                end

                if self.passSubId == "1" then
                    self:onChangeBoss("right")

                elseif self.passSubId == "2" then
                    self:onChangeBoss("left")
                end

                self:addLoading(lang("towertip_15"))
                
                self._isGotoNext = true
            end
        else
            if self.passSubId ~= nil then
                self:addLoading(lang("towertip_16"))
                self._isGotoNext = true
            else
                self:onReset()
                self:removeLoading()
                self._isGotoNext = false
            end
        end
        if result["cheat"] == 1 then
            result.failed = true
        end
        callback(result, result.reward)
    end)
end

function CloudCityBattleView:onBattleQuit(info)
    if self._isGotoNext == true then
        self._isGotoNext = nil
        self:onBattle()

    elseif self._isGotoNext == nil then
        self:addLoading(lang("towertip_16"))
        self:onBattle()
    end

    if self._isClose then
        self:close(true)
    end
end

-- 观看排行榜评论
function CloudCityBattleView:onWatch()
    self._serverMgr:sendMsg("CloudyCityServer", "getCCFirstData", {stageId = self._stageId}, true, {}, function(result) 
        if result and result.rankData then
            self._viewMgr:showDialog("cloudcity.CloudCityCommentView", {data = result.rankData, stageId = self._stageId, cData = result.commentList, ctype = 3, rankType = 10})
        else
            self._viewMgr:showTip("还没有录像，赶快痛快创造纪录吧")
        end
    end)
end


function CloudCityBattleView:showLevelSelect(data)
    self._selectViewCallBack(data)

    if data.cType == "advanceStage" then
        self:close()
    end
end

function CloudCityBattleView:onReset()
    if self.passSubId == nil then


    else
        self:onChangeBoss(self._buffSubId == 1 and "left" or "right")
        self._serverMgr:sendMsg("CloudyCityServer", "resetCloudyCityFight", {stageId = self._stageId}, true, {}, function(result)
            print("resetComplete")


            self.passSubId = nil
            self.stageList = nil
            
            if needBattleAgain then
                self:onBattle()
            end
        end)

        self.resetCallBack()
    end
end

-- 返回血量百分比  格式 eg. 30.13% 格式为 3013 
function CloudCityBattleView:getHpPercent(hpData)
    if hpData[1] ~= nil and hpData[2] ~= nil then
        local hpPercent = string.format("%.4f", hpData[1] / hpData[2])
        return tonumber(hpPercent) * 10000
    else
        return 0
    end
end

-- 根据stageId和subId获得FightId
function CloudCityBattleView:getFightId(stageId, subId)
    return (stageId - 1) * 2 + subId
end

-- 根据总的阶ID获得对应层数和本层阶数
function CloudCityBattleView:getFloorAndStageById(stageId)
    return tab:TowerStage(stageId).floor, stageId % 4 == 0 and 4 or stageId % 4
end


function CloudCityBattleView:getIsShowExPlain(fightId)
    if type(tab:TowerFight(fightId).show) == "table" and
        not SystemUtils.loadAccountLocalData("showExpalin_" .. tab:TowerFight(fightId).show[1])
    then
        return true
    else
        return false
    end
end

-- 获取屏蔽的兵团
function CloudCityBattleView:getFilterListAndCounts(stageId, subId)
    local filterList = {}
    local filterCounts = nil
    -- 已用过编组，屏蔽
    if self.stageList ~= nil and next(self.stageList) ~= nil then
        local usedListData = self.stageList[tostring(stageId)]["usedList"]
        if usedListData ~= nil then
            local usedStr = nil
            if subId == 1 then
                usedStr = usedListData[tostring(self._formationModel.kFormationTypeCloud2)]
            elseif subId == 2 then
                usedStr = usedListData[tostring(self._formationModel.kFormationTypeCloud1)]
            end

            if usedStr ~= nil then
                filterList = string.split(usedStr, ",")
                for i = 1, #filterList do
                    filterList[i] = tonumber(filterList[i])
                end
            end
        end
    end

    local limitConfig = self._fightTab[self:getFightId(stageId, subId)].limit
    if limitConfig ~= nil then
        for k, v in pairs(limitConfig) do
            -- 1:限制人数上限  2:限制阵营  3:限制某个兵种
            if v[1] == 1 then
                filterCounts = v[2]
            elseif v[1] == 2 then
                self:mergeFilterList(filterList, self._teamModel:getTeamWithRace(v[2]))
            elseif v[1] == 3 then
                self:mergeFilterList(filterList, self._teamModel:getTeamWithClass(v[2]))
            end
        end
    end

    self:mergeFilterList(filterList, self._fightTab[self:getFightId(stageId, subId)].crop)
    return filterList, filterCounts
end

-- 合并两个兵团数组
function CloudCityBattleView:mergeFilterList(filterList, teamData)
    if teamData == nil then return end

    local mergeList = {}
    for _, filterV in pairs(filterList) do
        mergeList[filterV] = 1
    end

    for _, dataV in pairs(teamData) do
        if type(dataV) == "table" then
            if mergeList[dataV.teamId] == nil then
                table.insert(filterList, 1, dataV.teamId)
            end
        else
            if mergeList[dataV] == nil then
                table.insert(filterList, 1, dataV)
            end
        end
    end
end


--[[ 隐藏敌人信息 (改动)]]--
--function CloudCityBattleView:getHeroIconById(heroId)
--    local icon = nil
--    local sysHeroData = tab.npcHero[heroId]
--    icon = IconUtils:createHeroIconById({sysHeroData = sysHeroData})
--    icon:setAnchorPoint(cc.p(0,0))
--    -- icon:setScale(0.67)
--    icon:getChildByName("starBg"):setVisible(false)
--    for i=1,6 do
--        if icon:getChildByName("star" .. i) then
--            icon:getChildByName("star" .. i):setPositionY(icon:getChildByName("star" .. i):getPositionY() + 5)
--        end
--    end
--    icon:setSwallowTouches(false)
--    icon:setPosition(0, 1)
--    icon:setScale(88 / icon:getContentSize().width)
--    registerClickEvent(icon, function()
----        local NewFormationIconView = require "game.view.formation.NewFormationIconView"
----        self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeCloudHero, iconId = heroId}, true)
--    end)
--    return icon
--end

--function CloudCityBattleView:getTeamIconById(teamId)
--    local icon = nil
--    local teamTableData = tab:Npc(teamId)
--    local backQuality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(teamTableData.stage)
----    icon = IconUtils:createTeamIconById({teamData = {id = teamId, star = teamTableData.star}, sysTeamData = teamTableData, quality = backQuality[1], quaAddition = backQuality[2], tipType = 9, eventStyle = 2})
--    icon = IconUtils:createTeamIconById({teamData = {id = teamId, star = teamTableData.star}, sysTeamData = teamTableData, quality = nil, quaAddition = backQuality[2], tipType = 9, eventStyle = 2})
--    IconUtils:setTeamIconStarVisible(icon, false)
--    IconUtils:setTeamIconStageVisible(icon, false)
--    IconUtils:setTeamIconLevelVisible(icon, false)            
--    icon:setPosition(0, 0)
--    icon:setScale(84 / icon:getContentSize().width)
--    return icon
--end
return CloudCityBattleView