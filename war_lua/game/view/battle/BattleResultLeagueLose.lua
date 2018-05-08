--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-09-08 14:14:12
--
local BattleResultLeagueLose = class("BattleResultLeagueLose", BasePopView)

function BattleResultLeagueLose:ctor(data)
    BattleResultLeagueLose.super.ctor(self, data)
    -- dump(data.data,"data.data==>")
    self._result = data.result
    self._callback = data.callback
    self._battleInfo = data.data
    -- dump(data.data.leftData[1],"leftData[1]==>")
end
function BattleResultLeagueLose:getAsyncRes()
    return 
        {
            -- {"asset/ui/battle.plist", "asset/ui/battle.png"},
        }
end
--跳转
-- "1:兵团
-- 2：英雄
-- 3：图鉴
-- 4：宝物
-- 5：学院"
local toIndexView = {
    [1]="team.TeamListView",
    [2]="hero.HeroView",
    [3]="pokedex.PokedexView",
    [4]="treasure.TreasureView",
    [5]="talent.TalentView",
}

function BattleResultLeagueLose:onInit()
    self._bg = self:getUI("bg")
    self._bg:setEnabled(true)
    self._bg:setSwallowTouches(false)
    self._quitBtn = self:getUI("bg.quitBtn")
    self._countBtn = self:getUI("bg.countBtn")
    self._countBtn:setSwallowTouches(true)
    -- self._countBtn:setEnabled(false)
    self._bg1 = self:getUI("bg.bg1")
    self._bg3 = self:getUI("bg.bg3")
    self._bg1:setScaleY(0.1)
    self._bg1:setEnabled(true)
    self._bg1:setSwallowTouches(false)
    -- self._title = self:getUI("bg.title")
    -- self._title:setFontName(UIUtils.ttfName)
    self._touchPanel = self:getUI("touchPanel")
    self._touchPanel:setEnabled(false)
    self._countBtn:setEnabled(false)
    self._countBtn:setOpacity(0)
    self._countBtn:setCascadeOpacityEnabled(true)
    UIUtils:formatBattleResultBtnTxt(self._countBtn:getChildByFullName("nameTxt"))
    self:registerClickEvent(self._quitBtn, specialize(self.onQuit, self))
    self:registerClickEvent(self._touchPanel, specialize(self.onQuit, self))
    self:registerClickEvent(self._countBtn, specialize(self.onCount, self))
    -- 防止流程中报错无法关界面
    ScheduleMgr:delayCall(8000, self, function( )
        if tolua.isnull(self._touchPanel) then return end
        self._touchPanel:setEnabled(true)
    end)
    
    -- self._quitBtn:setOpacity(0)
    -- self._quitBtn:setTouchEnabled(false)
    
    self._bg1:setOpacity(0)
    self._bg1:setCascadeOpacityEnabled(true,true)
    -- self._title:setOpacity(0)
    -- self._title:setPositionY(self._title:getPositionY()+10)

    -- self._button = {}
    -- for i=1,4 do
    --     local btn = self:getUI("bg.bg1.upFight" .. i)
    --     btn:setCascadeOpacityEnabled(true,true)
    --     btn:setOpacity(0)
    --     table.insert(self._button,btn)
    -- end

    self._iconTable = {}
    self._fightData = clone(tab.standardopen)
    -- dump(self._fightData,"self._fightData")
    -- self._fightData = 
    self:initFightData()
    --初始化按钮显示
    -- self:initUIbutton(self._button)

    self:animBegin()
    --ViewManager:getInstance():returnMain("team.TeamView", {team = ModelManager:getInstance():getModel("TeamModel"):getData()[1],index = 2})
    --ViewManager:getInstance():returnMain("team.TeamView", {team = ModelManager:getInstance():getModel("TeamModel"):getData()[1],index = 1})

end

--获取当前五个战斗力，计算百分比升序排序，取前四数据
function BattleResultLeagueLose:initFightData()
    -- body    
    local userModel = self._modelMgr:getModel("UserModel")

    -- 计算各个标准的百分比 降序排序 得到前四的数据
    local leftData = self._battleInfo.leftData
    local teamNumTotal = tonumber(#leftData)
    local teamNum = 0       --山珍兵团数 不包括召唤物
    local teamsStar = 0     --星级总数
    local teamsLevel = 0    --兵团等级总数
    local teamsStage = 0    --兵团总阶数
    local skillLevel = 0    --兵团技能等级总和
    local equipLevel = 0    --兵团装备等级总和

    local teamModel = self._modelMgr:getModel("TeamModel")    
    local PokedexModel = self._modelMgr:getModel("PokedexModel")
    local heroModel = self._modelMgr:getModel("HeroModel")
    for i=1, teamNumTotal do
        local id = leftData[i].D["id"]
        local teamD = tab:Team(id)
        -- dump(self._battleInfo.leftData[i].D,"self.battleInfo.leftData[i].D...")
        local teamData = teamModel:getTeamAndIndexById(id)
        -- dump(teamData,"teamData==>")
        if teamData and leftData[i].original then 
            teamNum = teamNum + 1
            if tonumber(teamData.star) > 0 then                
                teamsStar = teamsStar + tonumber(teamData.star)
            end
            if tonumber(teamData.level) > 0 then 
                teamsLevel = teamsLevel + tonumber(teamData.level)
            end
            if tonumber(teamData.stage) > 0 then 
                teamsStage = teamsStage + tonumber(teamData.stage)
            end
            -- dump()
            for k=1,4 do
                -- print(teamData["el" .. i]"==========================teamData[sl .. i]==",teamData["sl" .. i])
                if teamData["sl" .. k] and tonumber(teamData["sl" .. k]) > 0 then
                    skillLevel = skillLevel + tonumber(teamData["sl" .. k])
                end
                if teamData["el" .. k] and tonumber(teamData["el" .. k]) > 0 then
                    equipLevel = equipLevel + tonumber(teamData["el" .. k])
                end
            end
        else
            print("========error haven't this team ~ teamId = ",id) 
        end
    end

    local heroData = heroModel:getHeroData(tonumber(self._battleInfo.hero1.id))
    -- dump(heroData,"heroData==>")
    local spellLv = 0
    local masteryLv = 0
    
    if heroData then
        for i=1,4 do
            if heroData["sl" .. i] and tonumber(heroData["sl" .. i]) > 0 then
                spellLv = spellLv + tonumber(heroData["sl" .. i])
            end
            -- masterylv
            if heroData["m" .. i] then
                local mastery = tab:HeroMastery(tonumber(heroData["m" .. i]))
                if mastery and tonumber(mastery.masterylv) > 0 then
                   masteryLv = masteryLv + tonumber(mastery.masterylv)
                end
            end
        end
    end
    -- local 
    --1 计算上阵人数 
    self._fightData[1].haveScore = teamNum
    -- print("=======shangzhenrenshu ============",self._fightData[1].haveScore)
   
    -- 2 计算兵团平均星级-->上阵兵团总星级/上阵兵团数
    local averageStar = string.format("%.2f",tonumber(teamsStar) / teamNum)
    self._fightData[2].haveScore = averageStar
    
    -- 3  兵团平均等级 -->上阵兵团总等级/上阵兵团数
    -- print("================tonumber(teamsLevel  teamNum ==",tonumber(teamsLevel),teamNum)
    local averageLvl = string.format("%.2f",tonumber(teamsLevel) / teamNum)
    self._fightData[3].haveScore = averageLvl
    -- print("================teamsLevel  teamNum  averageLvl ===s==",tonumber(teamsLevel),teamNum,averageLvl)
    
    -- 4  兵团技能等级-->兵团技能lvl总和 / 山珍兵团数
    -- print("======skillLevle===teamNum===========",skillLevel,teamNum)
    local averageSkillLvl = string.format("%.2f",tonumber(skillLevel) / teamNum)
    self._fightData[4].haveScore = averageSkillLvl
    
    -- 5  上阵兵团平均阶-->上阵兵团总阶数/上阵兵团数 
    local averageLvl = string.format("%.2f",tonumber(teamsStage) / teamNum)
    self._fightData[5].haveScore = averageLvl
    
    -- 6  兵团装备平均等级-->上阵兵团装备等级总和/上阵兵团数/4
    local equipLvl = string.format("%.2f",tonumber(equipLevel) / teamNum / 4)
    self._fightData[6].haveScore = equipLvl
   
    -- 7  图鉴总评分-->图鉴总评分总和    
    local pokScoreTable = PokedexModel:getScore()
    local pokedexScore = 0
    if pokScoreTable then
        for k,v in pairs(pokScoreTable) do
            if tonumber(v) > 0 then
                pokedexScore = pokedexScore + tonumber(v)
            end
        end
    end
    self._fightData[7].haveScore = pokedexScore
    
    -- 8  图鉴总等级-->图鉴等级总和
    local pokLvlTable = PokedexModel:getPokedexLevel()
    local pokedexLvl = 0
    if pokLvlTable then
        for k,v in pairs(pokLvlTable) do
            if tonumber(v) > 0 then
                pokedexLvl = pokedexLvl + tonumber(v)
            end
        end
    end
    self._fightData[8].haveScore = pokedexLvl
    
    -- 9  英雄升星-->英雄星级
    local heroStars = 0
    if heroData then
        heroStars = heroData.star
    end
    self._fightData[9].haveScore = heroStars   --tonumber(self._battleInfo.hero1.star) or 0
    
    -- 10 法术升级-->法术等级总和
    self._fightData[10].haveScore = tonumber(spellLv)
    
    -- 11 专精刷新-->专精总等级
    self._fightData[11].haveScore = tonumber(masteryLv)
    
    -- 12 宝物战斗力
    local userFightData = userModel:getUserScore()
    self._fightData[12].haveScore = tonumber(userFightData.treasure) or 0

    -- 13 学院战斗力
    self._fightData[13].haveScore = tonumber(userFightData.talent) or 0

    --  dump(userFightData,"userFightData==>>")
    local userData = userModel:getData()
    local userLv = userData.lvl or userData.level or 1
    -- print("==========userLv====",userLv,type(userLv))    
    local standardTable = tab:Standardscore(tonumber(userLv))   --tab:Standard(tonumber(userLv))
    -- dump(standardTable,"standardTable")
    for i=1,#self._fightData do
        local data = self._fightData[i]
        local level = data.open  --tab:Setting("G_LOSE_VIEW_SYSTEM_LEVEL_" .. i).value
        data.openLvl = level
        if userLv < level then
            data.lock = true
            data.percent = 0
        else
            data.lock = false 
            -- print("================data.func===",data.func )
            local standardFight = tonumber(standardTable[tostring(data.func)])
            -- print("============standardTable[tostring(data.func)]=======",standardTable[tostring(data.func)])
            if standardFight and tonumber(standardFight) > 0 then
                -- data.percent = string.format("%.2f",(tonumber(data.haveScore) / tonumber(standardFight))*100)
                -- print("========================",data.percent)
                data.percent = math.floor((tonumber(data.haveScore) / tonumber(standardFight))*100)
                -- print(data.id,(tonumber(data.haveScore) / tonumber(standardFight)),"========---------",tonumber(data.haveScore),tonumber(standardFight),data.percent)
                if tonumber(data.percent) < 0 then
                    data.percent = 0
                end
            else
                data.percent = 0
            end
        end
        data.percent = math.min(data.percent,100)
    end

    table.sort(self._fightData,function(a,b)
        -- local result = true
        if a.lock ~= b.lock then
            return b.lock
        elseif a.percent ~= b.percent then
            return a.percent < b.percent
        else
            return a.id < b.id
        end

    end)
    -- dump(self._fightData,"self._fightData==>>")
    -- table.remove(self._fightData, 5)
    -- return
end

function BattleResultLeagueLose:_quit(type, callback)
    if self._callback then
        self._callback(type, callback)
    end
end

function BattleResultLeagueLose:onQuit()
    -- print("==========onquite()======================")  
    -- if self._schedulerTable then  
    --     for i=1,4 do
    --         if self._schedulerTable[i] then
    --             ScheduleMgr:unregSchedule(self._schedulerTable[i])
    --             self._schedulerTable[i] = nil
    --         end
    --     end
    -- end
	self:_quit()
end

function BattleResultLeagueLose:onCount()
	self._viewMgr:showView("battle.BattleCountView",self._battleInfo,true)
end

function BattleResultLeagueLose:animBegin()
    audioMgr:stopMusic()
	audioMgr:playSoundForce("SurrenderBattle")

    local mc2 = mcMgr:createViewMC("shibai_commonlose", true, false, function (_, sender)
        sender:gotoAndPlay(100)
    end)
    mc2:setPosition(self:getUI("bg.animPos"):getPosition())
    self._bg:addChild(mc2)

    self._bg1:runAction(cc.Spawn:create(cc.FadeIn:create(0.3),cc.ScaleTo:create(0.2,1)))
    -- self._title:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.Spawn:create(cc.FadeIn:create(0.2),cc.JumpBy:create(0.3,cc.p(0,-10),-15,1))))
   	self._arrow = self:getUI("bg.bg1.arrow")
    self._arrow:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.3,cc.p(10,0)),cc.MoveBy:create(0.3,cc.p(-10,0)))))
    self._rank = self:getUI("bg.bg1.textBg.rank")
    self._rank:setFontName(UIUtils.ttfName_Title)
    self._rank:setColor(cc.c3b(255, 255, 255))
    self._rank:enable2Color(1,cc.c4b(63, 255, 19, 255)) 
	self._upRank = self:getUI("bg.bg1.textBg.upRank")
    self._upRank:setFontName(UIUtils.ttfName_Title) 
    self._upRank:setColor(cc.c3b(255, 255, 255))
    self._upRank:enable2Color(1,cc.c4b(63, 255, 19, 255)) 
	self._upArrow = self:getUI("bg.bg1.textBg.upArrow") 
	self._upArrow:runAction(cc.RepeatForever:create(cc.JumpBy:create(0.8,cc.p(0,0),5,1))) --cc.Sequence:create(cc.JumpBy:create(0.5,cc.p(0,5),5,1),cc.JumpBy:create(0.5,cc.p(0,0),0,1)) ))
	local leagueInfo = self._result.leagueInfo
    dump(leagueInfo,"------------,lllllllll")
    if leagueInfo then
    	local currentPoint = leagueInfo.currentPoint or 0
    	local prePoint = leagueInfo.prePoint or 0
    	local preHRank = leagueInfo.preHRank or prePoint or 0
        local preZone = leagueInfo.preZone 
        local curZone = leagueInfo.currentZone
        self._bg1:setVisible(true)
        -- local des = self:getUI("bg.bg1.des")
        -- des:setString(lang("WIN_LEAGUE_01"))
        local des1 = self:getUI("bg.bg1.textBg.des1")
        des1:setFontName(UIUtils.ttfName_Title)
        des1:setColor(cc.c3b(255, 255, 255))
        des1:enable2Color(1,cc.c4b(255, 218, 24, 255))
        des1:setString(lang("SOCORE_LEAGUE_01"))
        
        local des2 = self:getUI("bg.bg1.textBg.des2")
        des2:setFontName(UIUtils.ttfName_Title)
        des2:setColor(cc.c3b(255, 255, 255))
        des2:enable2Color(1,cc.c4b(63, 255, 19, 255))

		self._rank:setString(currentPoint)
        if currentPoint ~= prePoint then
    		self._upRank:setString(math.abs(currentPoint-prePoint) .. ")")
        else
            self._upRank:setString("")
            des2:setString("")
            des1:setString("您的积分保持不变")
            self._upArrow:setVisible(false)
    	end
        -- if preZone < curZone then
            self._bg3:setVisible(true)
            -- self._bg3:removeAllChildren()
            -- self._bg1:setPositionY(self._bg1:getPositionY()-150)
            local curLeagueRank = tab:LeagueRank(curZone or 1)
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
        local awardCoin = leagueInfo.awardLeagueCoin
        if awardCoin and awardCoin > 0 then
            self._bg2:setVisible(true)
            self._goldLabel:setString(awardCoin)
        end
    end
    self._touchPanel:runAction(cc.Sequence:create(cc.DelayTime:create(1.8), cc.CallFunc:create(function() 
        if self._touchPanel then
            self._touchPanel:setEnabled(true) 
        end
    end)))
    self._countBtn:runAction(cc.Sequence:create(cc.DelayTime:create(1.3), cc.FadeIn:create(0.3),cc.CallFunc:create(function ()
        if self._countBtn then
            self._countBtn:setEnabled(true)
        end
    end)))
end

function BattleResultLeagueLose:showChangeAnim( preZ,aftZ,preP,aftP )
    local proBar = self:getUI("bg.bg3.proBar")
    local proDark = self:getUI("bg.bg3.proDark")
    proDark:setPurityColor(255, 0, 0)
    proDark:setOpacity(240)
    proDark:setVisible(false)
    local stageImg1 = self:getUI("bg.bg3.stageImg1")
    stageImg1:setPosition(-31,77)
    local stageImg2 = self:getUI("bg.bg3.stageImg2")
    local zone1 = self:getUI("bg.bg3.zone1")
    zone1:setPosition(-62,21)
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
        stageImg1:setPosition(158,70)
         self._arrow:setVisible(false)
        zone1:setPosition(122,10)
    else
        stageImg1:setPosition(-31,77)
        zone1:setPosition(-62,21)
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
                            self:hideProBar(aftZ == #tab.leagueRank)
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
                                        stageImg1:setPosition(158,70)
                                        -- zone1:setPositionX(150)
                                        zone1:setPosition(122,10)
                                        self._arrow:setVisible(false)
                                        stageImg1:setScaleX(.5)
                                        -- nextNum = 200 -- 最高段位后进度条边满
                                    else
                                        stageImg1:setPosition(-31,77)
                                        zone1:setPosition(-62,21)
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
                            -- stageImg1:setPositionX(44)
                            -- zone1:setPositionX(13)
                            stageImg1:setPosition(-31,77)
                            zone1:setPosition(-62,21)
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

function BattleResultLeagueLose:hideProBar( isHideProBar )
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
function BattleResultLeagueLose:reflashRankPanel( )
    local curZone = self._modelMgr:getModel("LeagueModel"):getCurZone()
    if curZone < #tab.leagueRank then return end
    local isGodWarOpen = self._modelMgr:getModel("GodWarModel").isGodWarOpenFightWeek and self._modelMgr:getModel("GodWarModel"):isGodWarOpenFightWeek()
    local panel = self:getUI("bg.bg3.rankPanel")
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

    local rankInDes = self:getUI("bg.bg3.rankPanel.32Des")
    rankInDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    local curZone = self._modelMgr:getModel("LeagueModel"):getCurZone()
    local isInRank = in32Rank <= 32 and curZone >= #tab.leagueRank
    rankInDes:setVisible( not isInRank and isGodWarOpen)

    local stageImg1 = self:getUI("bg.bg3.stageImg1")
    local rankInImg = ccui.Text:create()
    rankInImg:setFontSize(32)
    rankInImg:setFontName(UIUtils.ttfName)
    rankInImg:setPosition(stageImg1:getContentSize().width/2,stageImg1:getContentSize().height/2-15)
    rankInImg:setColor(cc.c4b(255,255,221,255))
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
    panel:setPositionX(155-allWidth/2)
    rankInDes:setPositionX(allWidth/2)
end

function BattleResultLeagueLose.dtor()
    BattleResultLeagueLose = nil
    -- fightDataTable = nil
    -- fightTypeData = nil
    toIndexView = nil
end

return BattleResultLeagueLose