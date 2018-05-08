--[[
    Filename:    BattleResultLeague2Lose.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-12-11 11:23:12
    Description: File description
--]]


local BattleResultLeague2Lose = class("BattleResultLeague2Lose", BasePopView)

function BattleResultLeague2Lose:ctor(data)
    BattleResultLeague2Lose.super.ctor(self, data)

    self._result = data.result
    self._callback = data.callback
    self._battleInfo = data.data
    -- dump(data,"data....",5)
end

function BattleResultLeague2Lose:onInit()
    self._touchPanel = self:getUI("touchPanel")
    self._touchPanel:setSwallowTouches(false)
    self._touchPanel:setEnabled(false)
    self:registerClickEvent(self._touchPanel, specialize(self.onQuit, self))
    self._rolePanel = self:getUI("rolePanel.role_panel")
    self._roleImg = self:getUI("rolePanel.role_panel.role_img")
    -- self._roleImg:loadTexture("asset/uiother/team/t_qishi.png")
    self._roleImgShadow = self:getUI("rolePanel.role_panel.roleImg_shadow")
    -- self._roleImgShadow:loadTexture("asset/uiother/team/t_qishi.png")
    self._bgImg = self:getUI("bgPanel.bg_img")
    self._bgImg:loadTexture("asset/bg/commonWin_bg.png")
    self._bgImg:setHue(173)
    self._rolePanel:setVisible(false)
    self._bgImg:setVisible(false)
    self._bgImg:setVisible(false)
    self._bg = self:getUI("bg")
    local bg_click =  self:getUI("bg_click")
    bg_click:setSwallowTouches(false)
    self._countBtn = self:getUI("bg_click.countBtn")
    self._countBtn:setSwallowTouches(true)
    self._countBtn:setEnabled(false)
    self._countBtn:setOpacity(0)
    self._countBtn:setCascadeOpacityEnabled(true)
    UIUtils:formatBattleResultBtnTxt(self._countBtn:getChildByFullName("nameTxt"))

    -- 四个板子，失败，降级，胜利，升级
    self._bg1 = self:getUI("bg.bg1")
    self._bg1:setVisible(false)
    self._bg3 = self:getUI("bg.bg3")
    self._bg3:setVisible(false)
    self._bg1_0 = self:getUI("bg.bg1_0")
    self._bg1_0:setVisible(false)
    self._bg3_0 = self:getUI("bg.bg3_0")
    self._bg3_0:setVisible(false)

    self:initLabel(self:getUI("bg.bg1.des"),false)
    self:initLabel(self:getUI("bg.bg1.des1"),false)

    self._bg2 = self:getUI("bg.bg2")
    self._bg2:setVisible(false)
    self._gold = self:getUI("bg.bg2.gold")
    self._gold:loadTexture("globalImageUI_leagueCoin.png",1)  
    self._goldLabel = self:getUI("bg.bg2.goldLabel") 
    self._goldLabel:enableOutline(cc.c4b(48,20,0,255),2)


    -- self._rank = self:getUI("bg.bg1.rank") 
    -- self._upRank = self:getUI("bg.bg1.upRank") 
    -- self._upArrow = self:getUI("bg.bg1.upArrow") 
    -- self._upArrow:runAction(cc.RepeatForever:create(cc.JumpBy:create(0.8,cc.p(0,0),5,1))) --cc.Sequence:create(cc.JumpBy:create(0.5,cc.p(0,5),5,1),cc.JumpBy:create(0.5,cc.p(0,0),0,1)) ))
    local leagueInfo = self._result.leagueInfo
    -- dump(leagueInfo)
    self:onShow()
    self._isDraw = self._battleInfo.isTimeUp
    if leagueInfo then
        local currentPoint = leagueInfo.currentPoint or 0
        local prePoint = leagueInfo.prePoint or 0
        local preZone = leagueInfo.preZone or 1
        local curZone = leagueInfo.currentZone
        if self._isDraw then
            if prePoint == currentPoint then
                self:showDrawResult( currentPoint,prePoint,preZone,curZone )
            elseif prePoint < currentPoint then
                self:showPointUpResult( currentPoint,prePoint,preZone,curZone )
            else
                self:showPointDownResult( currentPoint,prePoint,preZone,curZone )
            end
        else
            self:showLoseResult( currentPoint,prePoint,preZone,curZone )
        end
        self._bg3:setVisible(false)
        -- self._bg3:removeAllChildren()
        self._bg1:setPositionY(self._bg1:getPositionY()-150)
        -- local progress = self:doScoreChangeAnim(preZone,curZone,prePoint,currentPoint)
        -- self._bg3:addChild(progress)
        self:showChangeAnim(preZone,curZone,prePoint,currentPoint)
        local awardCoin = leagueInfo.awardLeagueCoin
        if awardCoin and awardCoin > 0 then
            self._bg2:setVisible(true)
            self._goldLabel:setString(awardCoin)
        end
        -- local des = self:getUI("bg.bg1.des")
        -- des:setString(lang("LOSE_LEAGUE_01"))
        -- local des1 = self:getUI("bg.bg1.des1")
        -- des1:setString(lang("SOCORE_LEAGUE_02"))
        -- self._bg1:setVisible(true)
        -- if currentPoint ~= prePoint then
        --     self._rank:setString(currentPoint)
        --     self._upRank:setString((prePoint-currentPoint) .. ")")
        -- end
        -- if preZone > curZone then
        --     self._bg3:setVisible(true)
        --     self._bg1:setPositionY(self._bg1:getPositionY()-150)
        --     local curLeagueRank = tab:LeagueRank(curZone or 1)
        --     local stageImg = self._bg3:getChildByName("stageImg")
        --     stageImg:loadTexture(curLeagueRank.icon .. ".png",1)
        --     local zoneLab = self._bg3:getChildByName("zone")
        --     zoneLab:setString(lang(curLeagueRank.name) or "")
        -- else
        --     self._bg3:setVisible(false)
        --     if self._isDraw then
        --         local des = self._bg1:getChildByName("des")
        --         des:setString(lang("EQUAL_LEAGUE_01"))
        --         -- local des1 = self._bg1:getChildByName("des1")
        --         -- des1:setString("您的积分没有变化")
        --         local des2 = self._bg1:getChildByName("des2")
        --         -- des2:setVisible(false)
        --         self._rank:setColor(cc.c3b(255, 255, 255))
        --         self._rank:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
        --         -- self._upArrow:setVisible(false)
        --         -- self._upRank:setVisible(false)
        --         -- des1:setPositionX(des1:getPositionX()+60)
        --         -- self._rank:setPositionX(self._rank:getPositionX()+60)
        --     end
        -- end
    end
    self._bestOutID = self._battleInfo.leftData[1].D["id"]
    self._lihuiId = self._battleInfo.leftData[1].D["id"]
    local outputValue = self._battleInfo.leftData[1].damage or 0
    local outputLihuiV = self._battleInfo.leftData[1].damage or 0
    for i = 1,#self._battleInfo.leftData do
        if self._battleInfo.leftData[i].damage then
            if tonumber(self._battleInfo.leftData[i].damage) > tonumber(outputValue) then
                outputValue = self._battleInfo.leftData[i].damage
                self._bestOutID = self._battleInfo.leftData[i].D["id"]
            end
            if tonumber(self._battleInfo.leftData[i].damage) > tonumber(outputLihuiV) and self._battleInfo.leftData[i].original then
                outputLihuiV = self._battleInfo.leftData[i].damage
                self._lihuiId = self._battleInfo.leftData[i].D["id"]
            end
        end
    end
--  print(self._bestOutID ,"=====================",outputValue)
--  print(self._lihuiId,"=====================",outputLihuiV)
    self:registerClickEvent(self._countBtn, specialize(self.onCount, self))

    local children1 = self._bg1:getChildren()
    for k,v in pairs(children1) do
        v:setOpacity(0)
    end
    local children2 = self._bg2:getChildren()
    for k,v in pairs(children2) do
        v:setOpacity(0)
    end

    self._time = self._battleInfo.time
    self:animBegin()
end

-- 战斗结果有四种
-- 失败
function BattleResultLeague2Lose:showLoseResult( currentPoint,prePoint,preZone,curZone )
    local bg1 = self._bg1
    bg1:setVisible(true)
    local des = bg1:getChildByName("des")
    des:setString(lang("LOSE_LEAGUE_01"))
    local des1 = bg1:getChildByName("des1")
    des1:setString(lang("SOCORE_LEAGUE_02"))
    local rank = bg1:getChildByName("rank")
    rank:setString(currentPoint or 0)
    local upArrow = bg1:getChildByName("upArrow")
    upArrow:stopAllActions()
    upArrow:runAction(cc.RepeatForever:create(cc.JumpBy:create(0.8,cc.p(0,0),5,1)))
    local upRank = bg1:getChildByName("upRank")
    upRank:setString(math.abs(currentPoint-prePoint) .. ")")
    -- local bg3 = self._bg3
    -- if curZone ~= preZone then
    --     bg3:setVisible(true)
        bg1:setPositionY(bg1:getPositionY()-150)
    --     local curLeagueRank = tab:LeagueRank(curZone or 1)
    --     local stageImg = bg3:getChildByName("stageImg")
    --     stageImg:loadTexture(curLeagueRank.icon .. ".png",1)
    --     local zoneLab = bg3:getChildByName("zone")
    --     zoneLab:setString(lang(curLeagueRank.name) or "")
    -- end
end
-- 平局积分上升
function BattleResultLeague2Lose:showPointUpResult( currentPoint,prePoint,preZone,curZone )
    local bg1 = self._bg1_0
    bg1:setVisible(true)
    local des = bg1:getChildByName("des")
    des:setString(lang("WIN_LEAGUE_01"))
    local des1 = bg1:getChildByName("des1")
    des1:setString(lang("SOCORE_LEAGUE_01"))
    local rank = bg1:getChildByName("rank")
    rank:setString(currentPoint or 0)
    local upArrow = bg1:getChildByName("upArrow")
    upArrow:stopAllActions()
    upArrow:runAction(cc.RepeatForever:create(cc.JumpBy:create(0.8,cc.p(0,0),5,1)))
    local upRank = bg1:getChildByName("upRank")
    upRank:setString(math.abs(currentPoint-prePoint) .. ")")
    -- local bg3 = self._bg3_0
    -- if curZone ~= preZone then
        -- bg3:setVisible(true)
        bg1:setPositionY(bg1:getPositionY()-150)
        -- local curLeagueRank = tab:LeagueRank(curZone or 1)
        -- local stageImg = bg3:getChildByName("stageImg")
        -- stageImg:loadTexture(curLeagueRank.icon .. ".png",1)
        -- local zoneLab = bg3:getChildByName("zone")
        -- zoneLab:setString(lang(curLeagueRank.name) or "")
    -- end
end
-- 平局积分下降
function BattleResultLeague2Lose:showPointDownResult( currentPoint,prePoint,preZone,curZone )
    local bg1 = self._bg1
    bg1:setVisible(true)
    local des = bg1:getChildByName("des")
    des:setString(lang("LOSE_LEAGUE_01"))
    local des1 = bg1:getChildByName("des1")
    des1:setString(lang("SOCORE_LEAGUE_02"))
    local rank = bg1:getChildByName("rank")
    rank:setString(currentPoint or 0)
    local upArrow = bg1:getChildByName("upArrow")
    upArrow:stopAllActions()
    upArrow:runAction(cc.RepeatForever:create(cc.JumpBy:create(0.8,cc.p(0,0),5,1)))
    local upRank = bg1:getChildByName("upRank")
    upRank:setString(math.abs(currentPoint-prePoint) .. ")")
    local bg3 = self._bg3
    if curZone ~= preZone then
        bg3:setVisible(true)
        bg1:setPositionY(bg1:getPositionY()-150)
        local curLeagueRank = tab:LeagueRank(curZone or 1)
        local stageImg = bg3:getChildByName("stageImg")
        stageImg:loadTexture(curLeagueRank.icon .. ".png",1)
        local zoneLab = bg3:getChildByName("zone")
        zoneLab:setString(lang(curLeagueRank.name) or "")
    end
end

-- 平局积分不变化
function BattleResultLeague2Lose:showDrawResult(currentPoint,prePoint,preZone,curZone )
    local bg1 = self._bg1
    bg1:setVisible(true)
    local des = bg1:getChildByName("des")
    des:setString(lang("EQUAL_LEAGUE_01"))
    local des1 = bg1:getChildByName("des1")
    des1:setString(lang("SOCORE_LEAGUE_02"))
    local rank = bg1:getChildByName("rank")
    rank:setString(currentPoint or 0)
    local upArrow = bg1:getChildByName("upArrow")
    upArrow:stopAllActions()
    upArrow:runAction(cc.RepeatForever:create(cc.JumpBy:create(0.8,cc.p(0,0),5,1)))
    local upRank = bg1:getChildByName("upRank")
    upRank:setString(math.abs(currentPoint-prePoint) .. ")")
    local des = self._bg1:getChildByName("des")
    des:setString(lang("EQUAL_LEAGUE_01"))
    local des2 = bg1:getChildByName("des2")
    des2:setVisible(false)
    rank:setColor(cc.c3b(255, 255, 255))
    rank:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    upArrow:setVisible(false)
    upRank:setVisible(false)
    des1:setPositionX(des1:getPositionX()+60)
    rank:setPositionX(self._rank:getPositionX()+60)
end

function BattleResultLeague2Lose:initLabel(node,isGreen)      
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

function BattleResultLeague2Lose:onQuit()
	if self._callback then
		self._callback()
	end
end
function BattleResultLeague2Lose:onShow( )
    self._countBtn:setVisible(false)
    local leftAllDie = true
    for k,v in ipairs(self._result.leftData) do
        if v.die ~= -1 then
            leftAllDie = false
            break
        end
        if v.damage > 0 or v.hurt > 0 or v.heal > 0 then
            self._countBtn:setVisible(true)
            -- return 
        end
    end
    local rightAllDie = true
    for k,v in ipairs(self._result.rightData) do
        if v.die ~= -1 then
            rightAllDie = false
            break
        end
        if v.damage > 0 or v.hurt > 0 or v.heal > 0 then
            self._countBtn:setVisible(true)
            -- return 
        end
    end
    if not (leftAllDie or rightAllDie) then
        self._countBtn:setVisible(false)
        -- self._isDraw = true
    end
    -- self._isDraw = true -- 测试平局显示
end

function BattleResultLeague2Lose:onCount()
	self._viewMgr:showView("battle.BattleCountView",self._battleInfo,true)
end

function BattleResultLeague2Lose:animBegin()
    audioMgr:stopMusic()
	audioMgr:playSoundForce("SurrenderBattle")

    -- 如果兵团有变身技能，这里改变立汇
    local curHeroId = self._battleInfo.hero1["id"]
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
        if isAwaking then 
            -- 结算例会单独处理 读配置
            imgName = teamData.jxart2
            artUrl = "asset/uiother/team/"..imgName..".png"
        end

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
    if not self._rolePanelLow then 
        self._rolePanelLow = self._rolePanel:clone()
        self._rolePanelLow:setOpacity(150)
        self._rolePanelLow:setCascadeOpacityEnabled(true)
        self._rolePanelLow:setPosition(self._rolePanel:getPosition())
        self._rolePanel:getParent():addChild(self._rolePanelLow, self._rolePanel:getZOrder()-1)
    end
    self._rolePanelLow:setPositionX(-moveDis)
    self._rolePanel:setPositionX(-moveDis)
    self._bgImg:setPositionX(posBgX+1220)
    self._rolePanel:setVisible(true)
    self._bgImg:setVisible(true)
    local moveRole = cc.Sequence:create(cc.MoveTo:create(0.05,cc.p(posRoleX+20,posRoleY)),cc.MoveTo:create(0.01,cc.p(posRoleX,posRoleY)))
    self._rolePanel:runAction(moveRole)
    local moveRoleLow = cc.Sequence:create(cc.DelayTime:create(0.06), cc.MoveTo:create(0.1,cc.p(posRoleX+20,posRoleY)),cc.MoveTo:create(0.01,cc.p(posRoleX,posRoleY)))
    self._rolePanelLow:runAction(moveRoleLow)
    local time = 615/moveDis*0.05
    local moveBg = cc.Sequence:create(cc.MoveTo:create(time,cc.p(posBgX-20,posBgY)),cc.MoveTo:create(0.01,cc.p(posBgX,posBgY)))
    self._bgImg:runAction(moveBg)

    ScheduleMgr:delayCall(200, self, function(sender)
        self:animNext()
    end)    
end
function BattleResultLeague2Lose:animNext()
    local animPos = self:getUI("bg.animPos")
    -- local mc1 = mcMgr:createViewMC("huodedaojudiguang_commonlight", true, false, function (_, sender)
    --         sender:gotoAndPlay(20)
    --     end,RGBA8888)
    -- mc1:setPosition(animPos:getPosition())
    -- mc1:setScale(0.8)
    -- self._bg:addChild(mc1)
    local mc2 
    if self._isDraw then
        mc2 = mcMgr:createViewMC("pingju_leaguepingju", false)
    else
        mc2 = mcMgr:createViewMC("shibai_commonlose", false)
    end
    mc2:setPosition(animPos:getPosition())
    self._bg:addChild(mc2, 5)

    self._timeLabel = cc.Label:createWithTTF("00:00", UIUtils.ttfName, 26)
    self._timeLabel:setColor(cc.c3b(245, 20, 34))
    self._timeLabel:enableOutline(cc.c4b(0,0,0,255),2)
    if self._isDraw then
        self._timeLabel:setPosition(0, -63)
    else
        self._timeLabel:setPosition(100, -33)
    end
    mc2:getChildren()[1]:getChildren()[1]:addChild(self._timeLabel)
    if self._time then
        self:labelAnimTo(self._timeLabel, 0, self._time, true)
    end
    
    local children2 = self._bg2:getChildren()
    for k,v in pairs(children2) do
        v:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.FadeIn:create(0.3)))
    end

    local children1 = self._bg1:getChildren()
    self._bg1:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.JumpBy:create(0.2,cc.p(0,5),10,1)))
    for k,v in pairs(children1) do
        v:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.FadeIn:create(0.1)))
    end

    self._countBtn:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.FadeIn:create(0.3),cc.CallFunc:create(function ()
        self._countBtn:setEnabled(true)
    end)))
     self._touchPanel:runAction(cc.Sequence:create(cc.DelayTime:create(1.9), cc.CallFunc:create(function()
        self._touchPanel:setEnabled(true)
    end)))
end

function BattleResultLeague2Lose:labelAnimTo(label, src, dest, isTime)
    audioMgr:playSound("TimeCount")
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
            end
            if label.isTime then
                label:setString(formatTime(label.now))
            else
                label:setString(label.now)
            end
        end
    end)
end

function BattleResultLeague2Lose:showChangeAnim( preZ,aftZ,preP,aftP )
    local proBar = self:getUI("bg.bg3_3.proBar")
    local proDark = self:getUI("bg.bg3_3.proDark")
    proDark:setPurityColor(255, 0, 0)
    proDark:setOpacity(240)
    proDark:setVisible(false)
    local stageImg1 = self:getUI("bg.bg3_3.stageImg1")
    local stageImg2 = self:getUI("bg.bg3_3.stageImg2")
    local zone1 = self:getUI("bg.bg3_3.zone1")
    zone1:setFontSize(30)
    zone1:setFontName(UIUtils.ttfName)
    zone1:setColor(cc.c3b(250, 242, 192))
    zone1:enable2Color(2,cc.c4b(255, 195, 17, 255))
    zone1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    local zone2 = self:getUI("bg.bg3_3.zone2")
    zone2:setFontSize(30)
    zone2:setFontName(UIUtils.ttfName)
    zone2:setColor(cc.c3b(250, 242, 192))
    zone2:enable2Color(2,cc.c4b(255, 195, 17, 255))
    zone2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    local preLD = tab:LeagueRank(preZ)
    local preND = tab:LeagueRank(math.min(preZ+1,#tab.leagueRank))
    local deno = preLD.gradeup-preLD.gradedown
    local curNum = (preP-preLD.gradedown)/deno*100
    proBar:setScaleX(curNum/100)
    print(curNum,"curNum...")
    proDark:setScaleX(curNum/100)
    local nextNum = aftP/deno*100 -- 0到100对应百分比 ，负数是回退段位
    stageImg1:loadTexture(preLD.icon .. ".png",1)
    zone1:setString(lang(preLD.name))
    stageImg2:loadTexture(preND.icon .. ".png",1)
    zone2:setString(lang(preND.name))
    if preZ == #tab.leagueRank then -- 最高段位
        stageImg2:setVisible(false)
        zone2:setVisible(false)
        stageImg1:setPositionX(180)
        zone1:setPositionX(180)
    end
    if preZ == aftZ then
        nextNum = (aftP-preLD.gradedown)/(preLD.gradeup-preLD.gradedown)*100
    elseif preZ < aftZ then
        local aftLD = tab:LeagueRank(aftZ)
        deno = aftLD.gradeup-aftLD.gradedown
        nextNum = 100+(aftP-aftLD.gradedown)/deno*100
    elseif preZ > aftZ then
        local aftLD = tab:LeagueRank(aftZ)
        deno = aftLD.gradeup-aftLD.gradedown
        nextNum = -(aftP-aftLD.gradedown)/deno*100
    end
    ScheduleMgr:delayCall(1500, self, function( )
        if self.showChangeAnim then
            if nextNum <= 100 and nextNum > 0 then 
                proBar:runAction(cc.Sequence:create(
                    cc.ScaleTo:create(0.5,nextNum/100,1)
                ))
                if preP > aftP then
                    proDark:setVisible(true)
                    proDark:runAction(cc.Sequence:create(
                        cc.FadeOut:create(1),
                        cc.CallFunc:create(function( )
                            
                        end)
                    ))
                end
            elseif nextNum > 100 then
                proBar:runAction(cc.Sequence:create(
                    cc.ScaleTo:create(0.5,1,1),
                    cc.CallFunc:create(function( )
                        local orbit = cc.ScaleTo:create(.25,0,.5)
                        local orbit1 = cc.ScaleTo:create(.25,-.5,.5)
                        stageImg1:runAction(cc.Sequence:create(
                            orbit:clone(),
                            cc.Spawn:create(
                                orbit1:clone(),
                                cc.CallFunc:create(function( )
                                    stageImg1:loadTexture(tab:LeagueRank(aftZ).icon .. ".png",1)
                                    zone1:setString(lang(tab:LeagueRank(aftZ).name))
                                    if aftZ == #tab.leagueRank then -- 最高段位
                                        stageImg2:setVisible(false)
                                        zone2:setVisible(false)
                                        stageImage1:setPositionX(180)
                                        zone1:setPositionX(150)
                                        -- nextNum = 200 -- 最高段位后进度条边满
                                    end
                                end)
                            )
                        ))
                        stageImg2:runAction(cc.Sequence:create(
                            orbit:clone(),
                            cc.Spawn:create(
                                orbit1:clone(),
                                cc.CallFunc:create(function( )
                                    if aftZ+1 <= #tab.leagueRank then
                                        stageImg2:loadTexture(tab:LeagueRank(aftZ+1).icon .. ".png",1)
                                        zone2:setString(lang(tab:LeagueRank(aftZ+1).name))
                                    else
                                        stageImg2:setVisible(false)
                                    end
                                end)
                            )
                        ))
                        proBar:stopAllActions()
                        proBar:setScale(0,1)
                        proBar:runAction(cc.Sequence:create(
                            cc.ScaleTo:create(0.5,(nextNum-100)/100,1)
                        ))
                    end)
                ))
            elseif nextNum < 0 then
                proDark:setVisible(true)
                proDark:runAction(cc.Sequence:create(
                    cc.FadeOut:create(0.5),
                    cc.CallFunc:create(function( )
                        
                    end)
                ))
                proBar:runAction(cc.Sequence:create(
                    cc.ScaleTo:create(0.5,0,1),
                    cc.CallFunc:create(function( )
                        proBar:setScaleX(1)
                        proDark:setScaleX(1)
                        proDark:setOpacity(255)
                        proDark:setVisible(true)
                        proDark:stopAllActions()
                        proDark:runAction(cc.Sequence:create(
                            cc.FadeOut:create(0.5),
                            cc.CallFunc:create(function( )
                                
                            end)
                        ))
                        if aftZ ~= #tab.leagueRank then -- 最高段位
                            stageImg2:setVisible(true)
                            zone2:setVisible(true)
                            stageImg1:setPositionX(44)
                            zone1:setPositionX(13)
                        end
                        local orbit = cc.ScaleTo:create(.25,0,.5)
                        local orbit1 = cc.ScaleTo:create(.25,-.5,.5)
                        stageImg1:runAction(cc.Sequence:create(
                            orbit:clone(),
                            cc.Spawn:create(
                                orbit1:clone(),
                                cc.CallFunc:create(function( )
                                    stageImg1:loadTexture(tab:LeagueRank(aftZ).icon .. ".png",1)
                                    zone1:setString(lang(tab:LeagueRank(aftZ).name))
                                    proDark:setVisible(true)
                                    proDark:setOpacity(240)
                                end)
                            )
                        ))
                        stageImg2:runAction(cc.Sequence:create(
                            orbit:clone(),
                            cc.Spawn:create(
                                orbit1:clone(),
                                cc.CallFunc:create(function( )
                                    if aftZ+1 <= #tab.leagueRank then
                                        stageImg2:loadTexture(tab:LeagueRank(aftZ+1).icon .. ".png",1)
                                        zone2:setString(lang(tab:LeagueRank(aftZ+1).name))
                                    else
                                        stageImg2:setVisible(false)
                                    end
                                end)
                            )
                        ))
                        proBar:stopAllActions()
                        proBar:setScale(1,1)
                        proBar:runAction(cc.Sequence:create(
                            cc.ScaleTo:create(0.5,math.abs(nextNum)/100,1)
                        ))
                    end)
                ))
            end
        end
    end)
    -- if true then return end
end

function BattleResultLeague2Lose.dtor()
    BattleResultLeague2Lose = nil
end

return BattleResultLeague2Lose