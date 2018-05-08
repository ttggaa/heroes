--[[
    Filename:    BattleResultCommonLose.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-12-09 16:22:54
    Description: File description
--]]

local BattleResultCommonLose = class("BattleResultCommonLose", BasePopView)

function BattleResultCommonLose:ctor(data)
    BattleResultCommonLose.super.ctor(self, data)
    self._result = data.result
    self._callback = data.callback
    self._battleInfo = data.data
end
function BattleResultCommonLose:getAsyncRes()
    return 
        {
            -- {"asset/ui/battle.plist", "asset/ui/batranktle.png"},
        }
end
--跳转
-- 1:兵团
-- 2：英雄
-- 3：图鉴
-- 4：宝物
-- 5：学院"
-- 6: 布阵
local toIndexView = {
    [1]="team.TeamListView",
    [2]="hero.HeroView",
    [3]="pokedex.PokedexView",
    [4]="treasure.TreasureView",
    [5]="talent.TalentView",
    [6]="formation.NewFormationView",
}

function BattleResultCommonLose:onInit()
    self._bg = self:getUI("bg")
    self._bg:setEnabled(true)
    self._bg:setSwallowTouches(false)
    self._quitBtn = self:getUI("bg.quitBtn")
    self._countBtn = self:getUI("bg.countBtn")
    self._countBtn:setSwallowTouches(true)
    self._countBtn:setOpacity(0)
    self._countBtn:setCascadeOpacityEnabled(true)
    UIUtils:formatBattleResultBtnTxt(self._countBtn:getChildByFullName("btnName"))
    self._bg1 = self:getUI("bg.bg1")
    self._bg1:setEnabled(true)
    self._bg1:setSwallowTouches(false)
    self._title = self:getUI("bg.title")
    self._title:setFontName(UIUtils.ttfName)
    self._touchPanel = self:getUI("touchPanel")
    self._touchPanel:setEnabled(false)
    self._countBtn:setEnabled(false)
    self:registerClickEvent(self._quitBtn, specialize(self.onQuit, self))
    self:registerClickEvent(self._touchPanel, specialize(self.onQuit, self))
    self:registerClickEvent(self._countBtn, specialize(self.onCount, self))
    -- 防止流程中报错无法关界面
    ScheduleMgr:delayCall(8000, self, function( )
        if tolua.isnull(self._touchPanel) then return end
        self._touchPanel:setEnabled(true)
    end)

    self._bg1:setOpacity(0)
    self._bg1:setCascadeOpacityEnabled(true,true)
    self._title:setPositionY(self._title:getPositionY()+10)

    self._button = {}
    for i=1,3 do
        local btn = self:getUI("bg.bg1.upFight" .. i)
        btn:setCascadeOpacityEnabled(true,true)
        btn:setScaleAnim(true)
        btn:setOpacity(0)
        local desTxt =  btn:getChildByFullName("desTxt")
        desTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

        -- 进度条啥的，先隐藏吧
        local progressBg = btn:getChildByFullName("progressBg")
        progressBg:setVisible(false)
        local progress = btn:getChildByFullName("progress")
        progress:setVisible(false)
        local progressTxt = btn:getChildByFullName("progressTxt")
        progressTxt:setVisible(false)

        table.insert(self._button,btn)
    end

    self._iconTable = {}
    self._fightData = clone(tab.standardopen)
    self:initFightData()
    --初始化按钮显示
    self:initUIbutton(self._button)

    self:animBegin()

end

--新界面 1.20
function BattleResultCommonLose:initUIbutton(btnTable)
    -- print("=========================================")
    -- dump(btnTable)
    for i=1,#btnTable do
        local fightData = self._fightData[i]
        btnTable[i]:setEnabled(true)
        btnTable[i]:setSwallowTouches(true)
        local upTxt = btnTable[i]:getChildByFullName("upTxt")
        upTxt:setFontName(UIUtils.ttfName)
        upTxt:setString(lang(fightData.name))

        local upImg = btnTable[i]:getChildByFullName("upImg")
        upImg:loadTexture(fightData.pic .. ".png",1)

        local desTxt =  btnTable[i]:getChildByFullName("desTxt")
        desTxt:setString(lang(fightData.des))

        local recommend = btnTable[i]:getChildByFullName("recommend")
        if recommend then
            if fightData.lock then
                recommend:setVisible(false)
            else                
                if fightData.percent < 100 then                    
                    recommend:setVisible(true)
                else
                    recommend:setVisible(false)
                end
            end
        end 
        local lockTxt = self:getUI("bg.bg1.lockTxt" .. i)
        lockTxt:setFontName(UIUtils.ttfName)
        lockTxt:setString(fightData.openLvl .. "级开启")
    
        lockTxt:setVisible(fightData.lock)
        desTxt:setVisible(not fightData.lock)
       
        btnTable[i]:setSaturation(fightData.lock and -100 or 0)
        self:registerClickEvent(btnTable[i], function()
            if not fightData.lock then
                BattleUtils.loseReturnMainind = true
                self:_quit(1, function ()
                    ViewManager:getInstance():returnMain(toIndexView[tonumber(fightData.jump)])  --, {team = ModelManager:getInstance():getModel("TeamModel"):getData()[1],index = 2})
                    BattleUtils.loseReturnMainind = false
                end)
            else
                ViewManager:getInstance():showTip("功能" .. fightData.openLvl .. "级开启")
            end
        end)     
    end
end
--[[
-- 有进度条  注释 1.20
function BattleResultCommonLose:initUIbutton(btnTable)
    -- print("=========================================")
    -- dump(btnTable)
    for i=1,#btnTable do
        local fightData = self._fightData[i]
        btnTable[i]:setEnabled(true)
        btnTable[i]:setSwallowTouches(true)
        local upTxt = btnTable[i]:getChildByFullName("upTxt")
        upTxt:setFontName(UIUtils.ttfName)
        upTxt:setString(lang(fightData.name))
        local upImg = btnTable[i]:getChildByFullName("upImg")
        upImg:loadTexture(fightData.pic .. ".png",1)

        local progressBg =  btnTable[i]:getChildByFullName("progressBg")
        local progress = btnTable[i]:getChildByFullName("progress")
        -- local progressR = btnTable[i]:getChildByFullName("progressR")
        -- progress:setPercent(fightData.percent)
        -- progressR:setPercent(fightData.percent)
        local progressTxt = btnTable[i]:getChildByFullName("progressTxt")
        progressTxt:setString("评分：" .. fightData.percent .. "分") -- .. "%")
        progressTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
        local recommend = btnTable[i]:getChildByFullName("recommend")
        if recommend then
            if fightData.lock then
                recommend:setVisible(false)
            else                
                if fightData.percent < 100 then
                    -- local text = recommend:getChildByFullName("recTxt")
                    -- text:setColor(UIUtils.colorTable.ccUIBaseColor1)
                    -- text:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
                    -- text:setFontName(UIUtils.ttfName)
                    recommend:setVisible(true)
                else
                    recommend:setVisible(false)
                end
            end
        end 
        local lockTxt = self:getUI("bg.bg1.lockTxt" .. i)
        lockTxt:setFontName(UIUtils.ttfName)
        lockTxt:setString(fightData.openLvl .. "级开启")
    
        lockTxt:setVisible(fightData.lock)
        progressBg:setVisible(not fightData.lock)
        progress:setVisible(not fightData.lock)
        progressTxt:setVisible(not fightData.lock)
        btnTable[i]:setSaturation(fightData.lock and -100 or 0)
        self:registerClickEvent(btnTable[i], function()
            -- print("======================btnTable[i]======",btnTable[i]:getName())
            if not fightData.lock then
                self:_quit(1, function ()
                    ViewManager:getInstance():returnMain(toIndexView[tonumber(fightData.jump)])  --, {team = ModelManager:getInstance():getModel("TeamModel"):getData()[1],index = 2})
                    -- ViewManager:getInstance():showDialog(fightData.toView)
                end)
            else
                -- print("=========================系统没开放")
                ViewManager:getInstance():showTip("功能" .. fightData.openLvl .. "级开启")
            end
        end)     
    end
end
--]]
--获取当前五个战斗力，计算百分比升序排序，取前四数据   -- 1.20 取前三
function BattleResultCommonLose:initFightData()
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

function BattleResultCommonLose:_quit(type, callback)
    if self._viewMgr then
        self._viewMgr:closeHintView()
    end
    if self._callback then
        self._callback(type, callback)
    end
end

function BattleResultCommonLose:onQuit()
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

function BattleResultCommonLose:onCount()
	self._viewMgr:showView("battle.BattleCountView",self._battleInfo,true)
end

function BattleResultCommonLose:animBegin()
    audioMgr:stopMusic()
	audioMgr:playSoundForce("SurrenderBattle")

    local mc2 = mcMgr:createViewMC("shibai_commonlose", true, false, function (_, sender)
        sender:gotoAndPlay(100)
    end)
    mc2:setPosition(self:getUI("bg.animPos"):getPosition())
    self._bg:addChild(mc2)

    -- self._bg1:runAction(cc.Spawn:create(cc.FadeIn:create(0.3),cc.ScaleTo:create(0.2,1)))
    self._bg1:runAction(cc.FadeIn:create(0.1))
    self._title:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Spawn:create(cc.FadeIn:create(0.2),cc.JumpBy:create(0.3,cc.p(0,-10),-15,1))))
    -- self._schedulerTable = {}
    for i=1,#self._button do
        local btn = self._button[i]        
        local fightData = self._fightData[i]
        local lock = fightData.lock
        btn:setScale(0.8)
        btn:setEnabled(false)
        local recommend = btn:getChildByFullName("recommend")

        local progress = btn:getChildByFullName("progress")
        -- local progressR = btn:getChildByFullName("progressR")
        local progressTxt = btn:getChildByFullName("progressTxt") 
        local lockTxt = self:getUI("bg.bg1.lockTxt" .. i)
        -- 动画需要
        if recommend and fightData.percent < 100 then        
            -- recommend:setVisible(false)
            recommend:setScale(2)
            recommend:setOpacity(0)
        end
        if not lock then
            progress:setVisible(false)
            -- progressR:setVisible(false)
            -- progressTxt:setVisible(false)
            progressTxt:setOpacity(0)
        else
            lockTxt:setVisible(false)
            lockTxt:setOpacity(0)
        end
        local action = cc.Spawn:create(cc.FadeIn:create(0.1),cc.ScaleTo:create(0.1,1.2))
        local seqAction = cc.Sequence:create(cc.DelayTime:create(0.5+0.1*i),
            action,
            cc.ScaleTo:create(0.05,1),
            cc.CallFunc:create(function()
               
            end))
        btn:runAction(seqAction)

        --如果有推荐，动画
        if not lock then
            if recommend and fightData.percent < 100 then 
                recommend:setVisible(true)
                -- 推荐动画延迟 = title bg1 动画时间0.5 + 0.1*i的延迟 + btn到放大动画的时间
                recommend:runAction(cc.Sequence:create(cc.DelayTime:create(0.5+0.1*i+0.2),cc.FadeIn:create(0.05),cc.ScaleTo:create(0.1, 0.7),cc.ScaleTo:create(0.05, 1)))     
            end  
            -- -- 进度条前进动画
            -- if fightData.percent < 50 then
            --     -- progress = btn:getChildByFullName("progressR")
            --     progress:loadTexture("battleResult_progress_r.png",1)
            -- end
            -- if progress then
            --     progress:setVisible(true)
            --     -- progress:setPercent(0)
            --     progress:setScaleX(0)   
            --     progress:runAction(cc.Sequence:create(cc.DelayTime:create(0.5+0.1*i+0.2),cc.ScaleTo:create(1*fightData.percent / 100,fightData.percent / 100,1)))
            -- end
            -- -- -- 进度文字动画
            -- if progressTxt then
            --     -- progressTxt:setVisible(true)
            --     progressTxt:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.Spawn:create(cc.FadeIn:create(0.1),cc.JumpBy:create(0.2,cc.p(0,15),15,1))))
            -- end
        else
            lockTxt:setVisible(true)
            lockTxt:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.Spawn:create(cc.FadeIn:create(0.1),cc.JumpBy:create(0.2,cc.p(0,15),15,1))))
        end
    end
 
    -- 设置按钮可点击
    for i=1,#self._button do
        local btn = self._button[i]
        local seqAction = cc.Sequence:create(cc.DelayTime:create(1.6),cc.CallFunc:create(function() 
            if btn then
                btn:setEnabled(true) 
            end
        end))
        btn:runAction(seqAction)
    end
    
    self._touchPanel:runAction(cc.Sequence:create(cc.DelayTime:create(1.6), cc.CallFunc:create(function() 
        if self._touchPanel then
            self._touchPanel:setEnabled(true) 
        end
    end)))
    self._countBtn:runAction(cc.Sequence:create(cc.DelayTime:create(1.1), cc.FadeIn:create(0.3),cc.CallFunc:create(function ()
        if self._countBtn then
            self._countBtn:setEnabled(true)
        end
    end)))
end

function BattleResultCommonLose.dtor()
    BattleResultCommonLose = nil
    toIndexView = nil
end

return BattleResultCommonLose