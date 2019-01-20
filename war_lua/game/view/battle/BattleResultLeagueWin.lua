--[[
    Filename:    BattleResultLeagueWin.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-12-11 11:22:50
    Description: File description
--]]


local BattleResultLeagueWin = class("BattleResultLeagueWin", BasePopView)

function BattleResultLeagueWin:ctor(data)
    BattleResultLeagueWin.super.ctor(self)
    self._result = data.result
    self._callback = data.callback
    self._battleInfo = data.data
    self._data = data
    -- dump(self._battleInfo,"self._battleInfo")
end
function BattleResultLeagueWin:getBgName()
    return "battleResult_bg.jpg"
end
function BattleResultLeagueWin:onInit()
    print("winis lllllll",self._battleInfo.win)
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
    self._bg1 = self:getUI("bg.bg1")
    self._bg3 = self:getUI("bg.bg3")

    --countBtn
    self._countBtn = self:getUI("bg_click.countBtn")
    self._countBtn:setSwallowTouches(true)
    self._countBtn:setEnabled(false)
    self._countBtn:setOpacity(0)
    self._countBtn:setCascadeOpacityEnabled(true)
    -- UIUtils:formatBattleResultBtnTxt(self._countBtn:getChildByFullName("nameTxt"))

    --shareBtn by wangyan
    self._shareNode = require("game.view.share.GlobalShareBtnNode").new({mType = "ShareLeagueWinModule"})
    self._shareNode:setPosition(220, 82)
    self._shareNode:setSwallowTouches(true)
    self._shareNode:setEnabled(false)
    self._shareNode:setOpacity(0)
    self._shareNode:setCascadeOpacityEnabled(true, true)
    self:getUI("bg_click"):addChild(self._shareNode, 10)
    
    self:initLabel(self:getUI("bg.bg1.des"),false)
    self:initLabel(self:getUI("bg.bg1.des1"),false)
    self:initLabel(self:getUI("bg.bg1.rank"),true)
    self:initLabel(self:getUI("bg.bg1.des2"),true)
    self:initLabel(self:getUI("bg.bg1.upRank"),true)

    -- self:initLabel(self:getUI("bg.bg3.des"),false)
    self:initLabel(self:getUI("bg.bg3.zone"),false)
    self._bg2 = self:getUI("bg.bg2") 
    self._bg2:setVisible(false)
    self._gold = self:getUI("bg.bg2.gold")
    self._gold:loadTexture("globalImageUI_leagueCoin.png",1)             
    -- local scaleNum1 = math.floor((32/self._gold:getContentSize().width)*100)
    -- self._gold:setScale(scaleNum1/100)
    self._goldLabel = self:getUI("bg.bg2.goldLabel")
    self._goldLabel:enableOutline(cc.c4b(48,20,0,255),2)
    self._goldLabel:setScale(1) 
    
    self._rank = self:getUI("bg.bg1.rank") 
    self._upRank = self:getUI("bg.bg1.upRank") 
    self._upArrow = self:getUI("bg.bg1.upArrow") 
    self._upArrow:runAction(cc.RepeatForever:create(cc.JumpBy:create(0.8,cc.p(0,0),5,1))) --cc.Sequence:create(cc.JumpBy:create(0.5,cc.p(0,5),5,1),cc.JumpBy:create(0.5,cc.p(0,0),0,1)) ))
    local leagueInfo = self._result.leagueInfo
    dump(leagueInfo,"leagueInfo.......in battle.....")
    if leagueInfo then
        local currentPoint = leagueInfo.currentPoint or 0
        local prePoint = leagueInfo.prePoint or 0
        local preHRank = leagueInfo.preHRank or prePoint or 0
        local preZone = leagueInfo.preZone 
        local curZone = leagueInfo.currentZone
        self._bg1:setVisible(true)
        local des = self:getUI("bg.bg1.des")
        des:setString(lang("WIN_LEAGUE_01"))
        local des1 = self:getUI("bg.bg1.des1")
        des1:setString(lang("SOCORE_LEAGUE_01"))
        local des2 = self:getUI("bg.bg1.des2")

        if currentPoint ~= prePoint then
            self._rank:setString(currentPoint)
            self._upRank:setString(math.abs(currentPoint-prePoint) .. ")")
            if currentPoint < prePoint then
                des:setString(lang("LOSE_LEAGUE_01"))
                des1:setString(lang("SOCORE_LEAGUE_02"))
                des:setColor(cc.c3b(255, 23, 23))
                des1:setColor(cc.c3b(255, 23, 23))
                self._rank:setColor(cc.c3b(255, 23, 23))
                self._upRank:setColor(cc.c3b(255, 23, 23))
                des2:setColor(cc.c3b(255, 23, 23))
                self._upArrow:loadTexture("globalImageUI4_downArrow2.png",1)
            end
        else
            des:setString(lang("EQUAL_LEAGUE_01"))
            des1:setString(lang("SOCORE_LEAGUE_03"))
        end
        if self._result and self._result.isTimeUp then
            des:setString(lang("EQUAL_LEAGUE_01"))
        end
        -- if preZone < curZone then
            self._bg3:setVisible(true)
            -- self._bg3:removeAllChildren()
            self._bg1:setPositionY(self._bg1:getPositionY()-150)
            local curLeagueRank = tab:LeagueRank(curZone or 1)
            -- self:showChangeAnim(8,8,5300,5320)
            self:hideProBar(false)
            if preZone == #tab.leagueRank then
                self:hideProBar(curZone == #tab.leagueRank)
            end
            self:showChangeAnim(preZone,curZone,prePoint,currentPoint)
            if preZone == #tab.leagueRank then
                self:reflashRankPanel()
            else
                ScheduleMgr:delayCall(2000, self, function( )
                    if self and self.reflashRankPanel then
                        self:reflashRankPanel()
                    end
                end)
            end
            -- local stageImg = self._bg3:getChildByName("stageImg")
            -- stageImg:loadTexture(curLeagueRank.icon .. ".png",1)
            -- local zoneLab = self._bg3:getChildByName("zone")
            -- zoneLab:setString(lang(curLeagueRank.name) or "")
        -- else
        --     self._bg3:setVisible(false)
        -- end
        -- local progress = self:doScoreChangeAnim(preZone,curZone,prePoint,currentPoint)
        -- self._bg3:addChild(progress)

        local awardCoin = leagueInfo.awardLeagueCoin
        if awardCoin and awardCoin > 0 then
            self._bg2:setVisible(true)
            self._goldLabel:setString(awardCoin)
        end
        -- if leagueInfo.award then
        --  self._goldLabel:setString(leagueInfo.award.val or "20")
        -- else
        --     self._goldLabel:setVisible(false)
        --     self._title:setVisible(false)
        --     self._gold:setVisible(false)
        -- end
    --     self._bg2:setVisible(true)
    -- else
    --     self._bg2:setVisible(false)
    end
    
    self:registerClickEvent(self._countBtn, specialize(self.onCount, self))
    self._shareNode:registerClick(function()
        local _stage1 = self._modelMgr:getModel("LeagueModel"):getCurZone()
        local _stage2 = self._modelMgr:getModel("LeagueModel"):getEnemyZone()
        return {moduleName = "ShareLeagueWinModule", data = self._data, stage1 = _stage1, stage2 = _stage2}
        end)

    local children1 = self._bg1:getChildren()
    for k,v in pairs(children1) do
        v:setOpacity(0)
    end
    local children2 = self._bg2:getChildren()
    for k,v in pairs(children2) do
        v:setOpacity(0)
    end

    -- self._expLabel:setString("")
    -- self._goldLabel:setString("")

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
     
    -- print(self._bestOutID ,"=====================",outputValue)
    -- print(self._lihuiId,"=====================",outputLihuiV)

    self._time = self._battleInfo.time

    self:animBegin()
end

function BattleResultLeagueWin:initLabel(node,isGreen) 
    if not node then return end    
    node:setFontName(UIUtils.ttfName_Title)
    if isGreen then
        node:setColor(cc.c4b(39,250,0,255))
    else
        node:setColor(cc.c4b(255,255,221,255))
        node:enable2Color(1, cc.c4b(253,229,123,255)) 
    end
    node:setFontSize(28)    
    -- node:enableShadow(cc.c4b(0, 0, 0, 255))
    node:enableOutline(cc.c4b(0,0,0,255),1) 
end

function BattleResultLeagueWin:onQuit()
    -- if self._arenaCallback then
    --  print("in arena callbakc....")
    --  self._arenaCallback(self._callback)
 --    else
        if self._callback then
            self._callback()
        end
        
    -- end
end

function BattleResultLeagueWin:onCount()
    self._viewMgr:showView("battle.BattleCountView",self._battleInfo,true)
end

-- local delaytick = {1000, 1500, 380}
function BattleResultLeagueWin:animBegin()
    audioMgr:stopMusic()
    audioMgr:playSoundForce("WinBattle")

    local liziAnim = mcMgr:createViewMC("liziguang_commonwin", true, false) 
    liziAnim:setPosition(MAX_SCREEN_WIDTH * 0.5, 135)
    self:getUI("bg_click"):addChild(liziAnim, 1000)

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
        local teamName, art1, art2, art3 = TeamUtils:getTeamAwakingTab(tdata, self._lihuiId)
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
    local moveDis = 436
    local posRoleX,posRoleY = self._rolePanel:getPosition()
  
    self._rolePanel:setPositionY(-moveDis)
    local moveRole = cc.Sequence:create(cc.MoveTo:create(0.1,cc.p(posRoleX,posRoleY+20)),cc.MoveTo:create(0.01,cc.p(posRoleX,posRoleY)))
    self._rolePanel:runAction(moveRole)
    
    -- 右侧旗子
    self._posBgX = self._bgImg:getPositionX()
    self._posBgY = self._bgImg:getPositionY()
    self._bgImg:setPositionY(self._posBgY+615)

    local animPos = self:getUI("bg.animPos") 
    ScheduleMgr:delayCall(100, self, function(sender)
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
                    sender:gotoAndPlay(80)         
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
function BattleResultLeagueWin:animNext()
    local animPos = self:getUI("bg.animPos")

    local mc3 = mcMgr:createViewMC("shenglixing_commonwin", true)
    mc3:setPosition(animPos:getPositionX(),animPos:getPositionY() - 70)
    self._bg:addChild(mc3, 4)
    
    -- local leagueInfo = self._result.leagueInfo
    -- if leagueInfo then
    --     self._timeLabel = cc.Label:createWithTTF(self._result.leagueInfo.currentPoint, UIUtils.ttfName, 32)
    --     self._timeLabel:setColor(cc.c3b(245, 20, 34))
    --     self._timeLabel:enableOutline(cc.c4b(0,0,0,255),2)
    --     self._timeLabel:setPosition(-1, -63)
    --     mc2:getChildren()[1]:getChildren()[1]:addChild(self._timeLabel)
    -- end

    self._timeLabel = cc.Label:createWithTTF("00:00", UIUtils.ttfName, 26)
    self._timeLabel:setColor(cc.c3b(245, 20, 34))
    self._timeLabel:enableOutline(cc.c4b(0,0,0,255),2)
    self._timeLabel:setPosition(animPos:getPositionX(),animPos:getPositionY() - 125)
    self._bg:addChild(self._timeLabel,99)
    -- mc2:getChildren()[1]:getChildren()[1]:addChild(self._timeLabel)
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

    self._countBtn:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.FadeIn:create(0.3),cc.CallFunc:create(function( )
        self._countBtn:setEnabled(true)
        if self._arenaCallback then
            self._arenaCallback()
        end   
    end)))

    self._shareNode:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.FadeIn:create(0.3), cc.CallFunc:create(function()
        self._shareNode:setEnabled(true)
        end)))

    self._touchPanel:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function()
        self._touchPanel:setEnabled(true)
    end)))
end

function BattleResultLeagueWin:labelAnimTo(label, src, dest, isTime)
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

function BattleResultLeagueWin:showChangeAnim( preZ,aftZ,preP,aftP )
    local proBar = self:getUI("bg.bg3.proBar")
    local proDark = self:getUI("bg.bg3.proDark")
    proDark:setPurityColor(255, 0, 0)
    proDark:setOpacity(240)
    proDark:setVisible(false)
    local stageImg1 = self:getUI("bg.bg3.stageImg1")
    stageImg1:setPosition(44,131)
    local stageImg2 = self:getUI("bg.bg3.stageImg2")
    local zone1 = self:getUI("bg.bg3.zone1")
    zone1:setPosition(13,75)
    zone1:setFontSize(30)
    zone1:setFontName(UIUtils.ttfName)
    zone1:setColor(cc.c3b(250, 242, 192))
    zone1:enable2Color(2,cc.c4b(255, 195, 17, 255))
    zone1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    local zone2 = self:getUI("bg.bg3.zone2")
    zone2:setFontSize(30)
    zone2:setFontName(UIUtils.ttfName)
    zone2:setColor(cc.c3b(250, 242, 192))
    zone2:enable2Color(2,cc.c4b(255, 195, 17, 255))
    zone2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    local preLD = tab:LeagueRank(preZ)
    local preND = tab:LeagueRank(math.min(preZ+1,#tab.leagueRank))
    local deno = preLD.gradeup-preLD.gradedown
    local curNum = (preP-preLD.gradedown)/deno*100
    proBar:setScaleX(math.min(1,curNum/100))
    print(curNum,"curNum...")
    proDark:setScaleX(math.min(1,curNum/100))
    local nextNum = aftP/deno*100 -- 0到100对应百分比 ，负数是回退段位
    stageImg1:loadTexture(preLD.icon .. ".png",1)
    zone1:setString(lang(preLD.name))
    stageImg2:loadTexture(preND.icon .. ".png",1)
    zone2:setString(lang(preND.name))
    if preZ == #tab.leagueRank then -- 最高段位
        stageImg2:setVisible(false)
        zone2:setVisible(false)
        stageImg1:setPositionX(180)
        zone1:setPositionX(150)
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
    -- 传奇需要5200+加前十名 所以有王者段位超过5200+ 进度条显示满格
    if nextNum > 100 and preZ == (#tab.leagueRank-1) and aftZ == (#tab.leagueRank-1) and( preP > tab:LeagueRank(aftZ).gradeup or aftP > tab:LeagueRank(aftZ).gradeup) then
        nextNum = 100
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
                            if aftZ == #tab.leagueRank then
                                self:hideProBar(true)
                            end
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
                                        stageImg1:setPositionX(180)
                                        zone1:setPositionX(150)
                                        stageImg1:setScaleX(.5)
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
                            ),
                            cc.CallFunc:create(function( )
                                stageImg1:setScaleX(0.5)
                            end)
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
                                    stageImg1:setScaleX(0.5)
                                end)
                            ),
                            cc.CallFunc:create(function( )
                                stageImg1:setScaleX(0.5)
                            end)
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

function BattleResultLeagueWin:hideProBar( isHideProBar )
    -- isHideProBar = true
    local hideMap = {
        "bg.bg3.proBg",
        -- "bg.bg3.proDark",
        -- "bg.bg3.proBar2",
        "bg.bg3.proBar",
    }
    for k,v in pairs(hideMap) do
        self:getUI(v):setVisible(not isHideProBar)
    end
    self:getUI("bg.bg3.rankPanel"):setVisible(isHideProBar)
end

-- 2017.4.25 新需求 传奇进度条始终是满条，改成显示排名
function BattleResultLeagueWin:reflashRankPanel( )
    local curZone = self._modelMgr:getModel("LeagueModel"):getCurZone()

    if curZone < #tab.leagueRank then return end
    local isGodWarOpen = self._modelMgr:getModel("GodWarModel").isGodWarOpenFightWeek and self._modelMgr:getModel("GodWarModel"):isGodWarOpenFightWeek()
    local panel = self:getUI("bg.bg3.rankPanel")
    local textBg = self:getUI("bg.bg3.rankPanel.textBg")
    local rankLab = self:getUI("bg.bg3.rankPanel.rank")
    rankLab:setFontName(UIUtils.ttfName_Title)
    rankLab:setColor(cc.c3b(255, 238, 160))
    -- rankLab:enable2Color(1,cc.c4b(63, 255, 19, 255)) 
    local des1Lab = self:getUI("bg.bg3.rankPanel.des1")
    des1Lab:setFontName(UIUtils.ttfName_Title)
    des1Lab:setColor(cc.c3b(255, 238, 160))
    -- des1Lab:enable2Color(1,cc.c4b(63, 255, 19, 255)) 
    local upArrow = self:getUI("bg.bg3.rankPanel.upArrow")
    local upRankLab = self:getUI("bg.bg3.rankPanel.upRank")
    local rankInDes = self:getUI("bg.bg3.rankPanel.32Des")
    local stampt = self:getUI("bg.bg3.rankPanel.stampt")
    rankInDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    local des = self:getUI("bg.bg1.des")
    
    local curRank,preRank = self._modelMgr:getModel("LeagueModel"):getCurRank()
    curRank = curRank or 0
    preRank = preRank or 0
    local in32Rank = self._modelMgr:getModel("LeagueModel"):getData().sRank or curRank
    local deltRank = preRank - curRank 
    local tail = deltRank>0 and "(" or ""
    rankLab:setString(curRank .. tail)
    upRankLab:setString(deltRank .. ")" )
    
    upArrow:setVisible(deltRank > 0)
    upRankLab:setVisible(deltRank > 0)

    local curZone = self._modelMgr:getModel("LeagueModel"):getCurZone()
    local isInRank = in32Rank <= 32 and curZone >= #tab.leagueRank

    stampt:setVisible(isInRank and isGodWarOpen)
    rankInDes:setVisible(isInRank and isGodWarOpen)
    des:setVisible(not isInRank)

    local stageImg1 = self:getUI("bg.bg3.stageImg1")

    local rankInImg = ccui.Text:create()
    rankInImg:setFontSize(32)
    rankInImg:setColor(cc.c4b(255,255,221,255))
    rankInImg:setFontName(UIUtils.ttfName)
    rankInImg:setPosition(stageImg1:getContentSize().width/2,stageImg1:getContentSize().height/2-15)
    rankInImg:setString(curRank)
    stageImg1:addChild(rankInImg)
    if isInRank then
        local zoneD = tab:LeagueRank(#tab.leagueRank)
        stageImg1:loadTexture(zoneD.icon .. "_1.png",1)
    end

    local allWidth = des1Lab:getContentSize().width
    -- 对齐
    rankLab:setPositionX(allWidth)
    allWidth = allWidth + rankLab:getContentSize().width
    if deltRank > 0 then
        upArrow:setPositionX(allWidth)
        allWidth = allWidth + upArrow:getContentSize().width
        upRankLab:setPositionX(allWidth)
        allWidth = allWidth + upRankLab:getContentSize().width
    end

    panel:setContentSize(cc.size(allWidth,80))
    textBg:setContentSize(cc.size(math.max(200,allWidth+80),48))
    textBg:setAnchorPoint(0.5,0.5)
    textBg:setPositionX(allWidth/2)
    panel:setPositionX(175-allWidth/2)
    rankInDes:setPositionX(allWidth/2)
end

function BattleResultLeagueWin.dtor()
    BattleResultLeagueWin = nil
    -- delaytick = nil
end

return BattleResultLeagueWin