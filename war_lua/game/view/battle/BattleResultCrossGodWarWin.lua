--[[
 	@FileName 	BattleResultCrossGodWarWin.lua
	@Authors 	yuxiaojing
	@Date    	2018-05-16 14:49:55
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]
local BattleResultCrossGodWarWin = class("BattleResultCrossGodWarWin", BasePopView)

function BattleResultCrossGodWarWin:ctor(data)
    BattleResultCrossGodWarWin.super.ctor(self)
    self._result = data.result
    self._callback = data.callback
    self._battleInfo = data.battleInfo
    -- dump(self._battleInfo, "self._battleInfo")
end
function BattleResultCrossGodWarWin:getBgName()
    return "battleResult_bg.jpg"
end
function BattleResultCrossGodWarWin:onInit()
    self._touchPanel = self:getUI("touchPanel")
    self._touchPanel:setSwallowTouches(false)
    self._touchPanel:setEnabled(false)
    self:registerClickEvent(self._touchPanel, specialize(self.onQuit, self))
    -- 防止流程中报错无法关界面
    ScheduleMgr:delayCall(8000, self, function( )
        if tolua.isnull(self._touchPanel) then return end
        self._touchPanel:setEnabled(true)
    end)
    
    self._bg = self:getUI("bg")
    self._rolePanel = self:getUI("bg.role_panel")
    self._rolePanelX , self._rolePanelY = self._rolePanel:getPosition()
    self._roleImg = self:getUI("bg.role_panel.role_img")    
    self._roleImgShadow = self:getUI("bg.role_panel.roleImg_shadow")

    self._bgImg = self:getUI("bg.bg_img")
    self._bgImg:loadTexture("asset/bg/battleResult_flagBg.png")

    local bg_click =  self:getUI("bg_click")
    bg_click:setSwallowTouches(false)
    self._countBtn = self:getUI("bg_click.countBtn")
    self._countBtn:setSwallowTouches(true)
    self._countBtn:setEnabled(false)
    self._countBtn:setOpacity(0)
    self._countBtn:setCascadeOpacityEnabled(true)
    UIUtils:formatBattleResultBtnTxt(self._countBtn:getChildByFullName("nameTxt"))
    self._bg1 = self:getUI("bg.bg1")

    local info = self._battleInfo.playerInfo
    local info1 = self._battleInfo.enemyInfo
    local lihuiData = self._result.leftData

    if not info1.isShowInc and info1.isMySelf then
        lihuiData = self._result.rightData
    end
    
    if info1.isMySelf then
        info = self._battleInfo.enemyInfo
        info1 = self._battleInfo.playerInfo
    end

    local des1 = self:getUI("bg.bg1.des")
    local des = self:getUI("bg.bg1.des1")
    local score = self:getUI("bg.bg1.score")
    local score_txt = self:getUI("bg.bg1.des2")
    local score_arrow = self:getUI("bg.bg1.scoreArrow")
    local score_up = self:getUI("bg.bg1.upScore")
    local inc = info.inc
    local isHaveShow = false
    local test_score_tip = ""
    if info.isShowInc then
        local nowScore = info.newScore
        if not inc or not nowScore then
            local myScore = info.gpsScore
            local otherScore = info1.gpsScore
            if myScore and otherScore then
                local Sa = tab.setting["CROSS_FIGHT_RATIO_V"].value
                local Ea = 1 / (1 + math.pow(10, ((otherScore - myScore) / 400)))
                local kv = tab.setting["CROSS_FIGHT_SCORE_RATIO"].value
                local enemyScore = info1.curScore or 10000000
                local score_R_V = tab.setting["CROSS_FIGHT_SCORE_R_V"].value
                local highestScore = info.highestFightScore
                local pv = 1 + score_R_V * enemyScore / highestScore
                nowScore = math.ceil(myScore + pv * kv * (Sa - Ea))
                inc = nowScore - myScore
                local score_limit = tab.setting["CROSS_FIGHT_SCORE_LIMIT"].value
                if inc < score_limit[1] or inc > score_limit[2] then
                    inc = inc > 0 and score_limit[2] or score_limit[1]
                end
                nowScore = myScore + inc
                test_score_tip = test_score_tip .. "\nmy:" .. myScore .. ", otherScore:" .. otherScore .. "\nEa:" .. Ea .. "\nkv:" .. kv .. "\nenemyFight:" .. enemyScore .. "\nhighestScore:" .. highestScore
            end
        end
        if inc and nowScore then
            isHaveShow = true
        	if inc > 0 then
        		self:initLabel(score, true)
        		self:initLabel(score_txt, true)
        		self:initLabel(score_up, true)
        		des:setString("您的积分上升至")
        		score_arrow:loadTexture("globalImageUI5_upArrow.png", 1)
        		score_arrow:runAction(cc.RepeatForever:create(cc.JumpBy:create(0.8,cc.p(0,0),5,1)))
        	elseif inc < 0 then
        		self:initLabel(score, false)
        		self:initLabel(score_txt, false)
        		self:initLabel(score_up, false)
        		des:setString("您的积分下降至")
        		score_arrow:loadTexture("arenaReport_jiantou1.png", 1)
        		score_arrow:runAction(cc.RepeatForever:create(cc.JumpBy:create(0.8,cc.p(0,0),-5,1)))
        	else
        		des:setString("您的积分上升至")
        		self:initLabel(score, true)
        		score_txt:setVisible(false)
        		score_arrow:setVisible(false)
        		score_up:setVisible(false)
        	end
    	    score:setString(nowScore)
    	    score_up:setString(math.abs(inc) .. ")")
        end
    end
    if not isHaveShow then
    	des1:setVisible(false)
    	score_txt:setVisible(false)
		score_arrow:setVisible(false)
		score_up:setVisible(false)
		des:setVisible(false)
		score:setVisible(false)
    end

    local rewardBg = self:getUI("bg_click.rewardBg")
    local rewardTip = self:getUI("bg.bg1.Label_69")
    rewardBg:setVisible(false)
    rewardTip:setVisible(false)
    local tipsText = lang("crossFight_tips_9")
    if info.isShowInc then
        tipsText = lang("crossFight_tips_8")
    end
    if OS_IS_WINDOWS then
        tipsText = tipsText .. test_score_tip
    end
    rewardTip:setString(tipsText)
    if not info.isReviewReport then
        local rewardId = info.crossGodWarRewardId
        if rewardId then
            rewardId = rewardId .. "1"
            local data = tab.crossFightReward[tonumber(rewardId)] or {}
            data = data.Reward
            if data then
                local itemType = data[1][1]
                local itemId = data[1][2]
                local itemNum = data[1][3]
                if itemType ~= "tool" then
                    itemId = IconUtils.iconIdMap[itemType]
                end
                local itemData = tab:Tool(itemId)
                local item = IconUtils:createItemIconById({
                    itemId = itemId, 
                    num = itemNum, 
                    itemData = itemData,
                    effect = true,
                    isBranchDrop = true
                    })
                item:setVisible(true)
                item:setSwallowTouches(false)
                item:setAnchorPoint(cc.p(0.5, 0.5))
                item:setPosition(cc.p(rewardBg:getContentSize().width / 2, rewardBg:getContentSize().height / 2 - 5))
                item:setScale(0.7)
                item:setOpacity(0)
                rewardBg:addChild(item)

                self._rewardItem = item

                rewardTip:setVisible(true)
                rewardBg:setVisible(true)
            end
        end
    end


    self:registerClickEvent(self._countBtn, specialize(self.onCount, self))

    local children1 = self._bg1:getChildren()
    for k,v in pairs(children1) do
        v:setOpacity(0)
    end

    self._bestOutID = lihuiData[1].D["id"]
    self._lihuiId = lihuiData[1].D["id"]
    local outputValue = lihuiData[1].damage or 0
    local defendValue = lihuiData[1].hurt or 0
    local outputLihuiV = lihuiData[1].damage or 0
    self._shareLeftDamageD = lihuiData[1].D
    self._shareLeftHurtD = lihuiData[1].D
    for i = 1,#lihuiData do
        if lihuiData[i].damage then
            if tonumber(lihuiData[i].damage) > tonumber(outputValue) then
                outputValue = lihuiData[i].damage
                self._bestOutID = lihuiData[i].D["id"]
                if lihuiData[i].original then
                    self._shareLeftDamageD = lihuiData[i].D
                end
            end
            if tonumber(lihuiData[i].damage) > tonumber(outputLihuiV) and lihuiData[i].original then
                outputLihuiV = lihuiData[i].damage
                self._lihuiId = lihuiData[i].D["id"]
            end

            if lihuiData[i].hurt then
                if tonumber(lihuiData[i].hurt) > tonumber(defendValue) and lihuiData[i].original then
                    outputValue = lihuiData[i].hurt
                    self._shareLeftHurtD = lihuiData[i].D
                end
            end
        end
    end

    -- 分享 过滤出敌方 防御和输出 teamData
    -- self._shareRightDamageD = self._result.rightData[1].D
    -- self._shareRightHurtD = self._result.rightData[1].D
    -- for i = 1,#self._result.rightData do
    --     if self._result.rightData[i].damage then
    --         if tonumber(self._result.rightData[i].damage) > tonumber(outputValue) and self._result.rightData[i].original then
    --             outputValue = self._result.rightData[i].damage
    --             if self._result.rightData[i].original then
    --                 self._shareRightDamageD = self._result.rightData[i].D
    --             end
    --         end
    --     end
    --     if self._result.rightData[i].hurt then
    --         if tonumber(self._result.rightData[i].hurt) > tonumber(defendValue) and self._result.rightData[i].original then
    --             outputValue = self._result.rightData[i].hurt
    --             self._shareRightHurtD = self._result.rightData[i].D
    --         end
    --     end
    -- end
     
    -- print(self._bestOutID ,"=====================",outputValue)
    -- print(self._lihuiId,"=====================",outputLihuiV)

    self._time = self._result.time

    local mcMgr = MovieClipManager:getInstance()
    self:animBegin()
end

function BattleResultCrossGodWarWin:initLabel(node,isGreen)     
    if isGreen then
        node:setColor(cc.c4b(39,250,0,255))
    else
        node:setColor(cc.c4b(255,255,221,255))
        node:enable2Color(1, cc.c4b(253,229,123,255)) 
    end
    node:setFontSize(28)    
    -- node:enableShadow(cc.c4b(0, 0, 0, 255))
    node:enableOutline(cc.c4b(0,0,0,255),2) 
end

function BattleResultCrossGodWarWin:onQuit()
    -- if self._arenaCallback then
    --  print("in arena callbakc....")
    --  self._arenaCallback(self._callback)
 --    else
        if self._callback then
            self._callback()
        end
    -- end
end

function BattleResultCrossGodWarWin:onCount()
    self._viewMgr:showView("battle.BattleCountView", self._result)
end

local delaytick = {1000, 1500, 380}
function BattleResultCrossGodWarWin:animBegin()
    audioMgr:stopMusic()
    audioMgr:playSoundForce("WinBattle")

    local liziAnim = mcMgr:createViewMC("liziguang_commonwin", true, false) 
    liziAnim:setPosition(MAX_SCREEN_WIDTH * 0.5, 135)
    self:getUI("bg_click"):addChild(liziAnim, 1000)

    -- 右侧旗子
    self._posBgX = self._bgImg:getPositionX()
    self._posBgY = self._bgImg:getPositionY()
    self._bgImg:setPositionY(self._posBgY+615)

    -- 如果兵团有变身技能，这里改变立汇
    local curHeroId = self._result.hero1["id"]
    local isChange = false
    local lihuiId = self._lihuiId
    if curHeroId then 
        local _,newId = TeamUtils.changeArtForHeroMastery(curHeroId,self._lihuiId)
        if newId then
            self._lihuiId = newId
            isChange = true
        end
    end

    local teamData = tab:Team(self._lihuiId) 
    if teamData then
        local imgName = string.sub(teamData["art1"], 4, string.len(teamData["art1"]))
        local artUrl = "asset/uiother/team/t_"..imgName..".png"
        -- 觉醒优先
        local teamModel = self._modelMgr:getModel("TeamModel")
        local tdata,_idx = teamModel:getTeamAndIndexById(lihuiId)
        local isAwaking,_ = TeamUtils:getTeamAwaking(tdata)
        local teamName, art1, art2, art3 = TeamUtils:getTeamAwakingTab(tdata, tdata.id)
        -- if isAwaking then 
        --     -- 结算例会单独处理 读配置
        --     imgName = teamData.jxart2
        --     artUrl = "asset/uiother/team/"..imgName..".png"
        -- end
        artUrl = "asset/uiother/team/".. art2 ..".png"
        if  teamData["jisuan"] then
            local teamX ,teamY = teamData["jisuan"][1], teamData["jisuan"][2]
            local scale = teamData["jisuan"][3] 
            self._roleImg:setPosition(teamX ,teamY)     
            self._roleImgShadow:setPosition(teamX+2,teamY-2)
            self._roleImg:setScale(scale)
            self._roleImgShadow:setScale(scale)
        end
        self._roleImg:loadTexture(artUrl)
        self._roleImgShadow:loadTexture(artUrl) 
    end 
    local moveDis = 600
    local posRoleX,posRoleY = self._rolePanel:getPosition()
    local posBgX,posBgY = self._bgImg:getPosition()
    -- if not self._rolePanelLow then 
    --     self._rolePanelLow = self._rolePanel:clone()
    --     self._rolePanelLow:setOpacity(150)
    --     self._rolePanelLow:setCascadeOpacityEnabled(true)
    --     self._rolePanelLow:setPosition(self._rolePanel:getPosition())
    --     self._rolePanel:getParent():addChild(self._rolePanelLow, self._rolePanel:getZOrder()-1)
    -- end
    -- self._rolePanelLow:setPositionX(-moveDis)
    self._rolePanel:setPositionY(-moveDis)
    
    local moveRole = cc.Sequence:create(cc.MoveTo:create(0.1,cc.p(posRoleX,posRoleY+20)),cc.MoveTo:create(0.01,cc.p(posRoleX,posRoleY)))
    self._rolePanel:runAction(moveRole)
    -- local moveRoleLow = cc.Sequence:create(cc.DelayTime:create(0.06), cc.MoveTo:create(0.1,cc.p(posRoleX+20,posRoleY)),cc.MoveTo:create(0.01,cc.p(posRoleX,posRoleY)))
    -- self._rolePanelLow:runAction(moveRoleLow)

    local animPos = self:getUI("bg.animPos")
    ScheduleMgr:delayCall(200, self, function(sender)
        local posBgX,posBgY = self._posBgX,self._posBgY
        local mc2
        local moveBg = cc.Sequence:create(
            cc.MoveTo:create(0.15,cc.p(posBgX,posBgY-20)),
            cc.MoveTo:create(0.01,cc.p(posBgX,posBgY)),
            cc.CallFunc:create(function()
                --胜利动画
                mc2 = mcMgr:createViewMC("shengli_commonwin", false)
                mc2:setPlaySpeed(1.5)
                mc2:setPosition(animPos:getPositionX(), animPos:getPositionY())
                self._bg:addChild(mc2, 5)
            end),
            cc.DelayTime:create(0.15),
            cc.CallFunc:create(function()
                -- 底光动画
                local mc1 = mcMgr:createViewMC("huodedaojudiguang_commonlight", true, false, function (_, sender)
                    sender:gotoAndPlay(20)         
                end,RGBA8888)
                mc1:setPosition(animPos:getPosition())

                local clipNode2 = cc.ClippingNode:create()
                clipNode2:setInverted(false)

                local mask = cc.Sprite:createWithSpriteFrameName("globalImage_IconMaskHalfCircle.png")
                mask:setScale(2.5)
                mask:setPosition(animPos:getPositionX(), animPos:getPositionY() + 140)
                clipNode2:setStencil(mask)
                clipNode2:setAlphaThreshold(0.01)
                clipNode2:addChild(mc1)
                clipNode2:setAnchorPoint(cc.p(0, 0))
                clipNode2:setPosition(0, 0)
                self._bg:addChild(clipNode2,4)
            end),
            cc.DelayTime:create(0.3),
            cc.CallFunc:create(function()
                --震屏
                UIUtils:shakeWindowRightAndLeft2(self._bg)
                end),
            cc.DelayTime:create(0.15),
            cc.CallFunc:create(function()
                self:animNext(mc2)
                end)

            )
        self._bgImg:runAction(moveBg)
    end)    
end

function BattleResultCrossGodWarWin:labelAnimTo(label, src, dest, isTime)
    self._countSound = audioMgr:playSound("TimeCount")
    label.src = src
    label.now = src
    label.dest = dest
    label:setString(src)
    label.isTime = isTime
    label.step = 1
    label.updateId = ScheduleMgr:regSchedule(1, self, function(self, dt)
        if label:isVisible() then
            if label.isTime then
                local value = math.floor((label.dest - label.now) * 0.05)
                if value < 1 then
                    value = 1
                end
                label.now = label.now + value
            else
                label.now = label.src + math.floor((label.dest - label.src) * (label.step / 50))
                label.step = label.step + 1
            end
            if math.abs(label.dest - label.now) < 5 then
                label.now = label.dest
                ScheduleMgr:unregSchedule(label.updateId)
                audioMgr:stopSound(self._countSound)
            end
            if label.isTime then
                label:setString(formatTime(label.now))
            else
                label:setString(label.now)
            end
        end
    end)
end

function BattleResultCrossGodWarWin:animNext(mc2)
    local animPos = self:getUI("bg.animPos")

    --倒计时
    self._timeLabel = cc.Label:createWithTTF("00:00", UIUtils.ttfName, 28)
    self._timeLabel:setColor(cc.c3b(255, 150, 97))
    self._timeLabel:enableOutline(cc.c4b(60, 30, 0,255), 1)
    self._timeLabel:setPosition(212, -30)  -- -35/-16
    mc2:getChildren()[1]:getChildren()[1]:addChild(self._timeLabel)
    if self._time then
    	self:labelAnimTo(self._timeLabel, 0, self._time, true)
    	if self._time <= 60 then
    		self._timeLabel:setColor(cc.c3b(20, 255, 34))
    	end
    end

    local mc3 = mcMgr:createViewMC("shenglixing_commonwin", true)
    mc3:setPosition(animPos:getPositionX(),animPos:getPositionY() - 70)
    self._bg:addChild(mc3, 4)
    
    -- local arenaInfo = self._result.arenaInfo
    -- if arenaInfo then
    --     self._timeLabel = ccui.TextBMFont:create("r" .. math.min(self._result.arenaInfo.rank,10000), UIUtils.bmfName_timecount)
    --     self._timeLabel:setScale(0.46)
    --     self._timeLabel:setPosition(animPos:getPositionX()-2, animPos:getPositionY() - 120)
    --     self._timeLabel:setAnchorPoint(0.5,1)
    --     self._timeLabel:setOpacity(0)
    --     self._bg:addChild(self._timeLabel,10)

    --     self._labelMc = mcMgr:createViewMC("jingjichangpaimingshanguang_commonwin", true, false, function (_, sender)
    --         sender:gotoAndPlay(0)
    --     end,RGBA8888)
    --     self._labelMc:setVisible(false)
    --     self._labelMc:setPosition(animPos:getPositionX()+10, animPos:getPositionY() - 124)
    --     self._bg:addChild( self._labelMc,10)

    --     self._timeLabel:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.FadeIn:create(0.3),cc.CallFunc:create(function()
    --         self._labelMc:setVisible(true)
    --     end
    --     ))) 
    -- end
    -- local children2 = self._bg2:getChildren()
    -- for k,v in pairs(children2) do
    --     v:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.FadeIn:create(0.3)))
    -- end

    local children1 = self._bg1:getChildren()
    self._bg1:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.JumpBy:create(0.2,cc.p(0,5),10,1)))
    for k,v in pairs(children1) do
        v:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.FadeIn:create(0.1)))
    end

    if self._rewardItem then
        self._rewardItem:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.JumpBy:create(0.2,cc.p(0,5),10,1)))
        self._rewardItem:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.FadeIn:create(0.1)))
    end

    self._countBtn:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.FadeIn:create(0.3),cc.CallFunc:create(function( )
        self._countBtn:setEnabled(true)
        if self._arenaCallback then
            self._arenaCallback()
        end   
    end)))

    -- self._shareNode:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.FadeIn:create(0.3), cc.CallFunc:create(function()
    --     self._shareNode:setEnabled(true)
    -- end)))

    self._touchPanel:runAction(cc.Sequence:create(cc.DelayTime:create(1.9), cc.CallFunc:create(function()
        self._touchPanel:setEnabled(true)
    end)))
end

function BattleResultCrossGodWarWin.dtor()
    BattleResultCrossGodWarWin = nil
    delaytick = nil
end

return BattleResultCrossGodWarWin