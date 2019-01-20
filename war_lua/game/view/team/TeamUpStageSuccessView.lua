--[[
    Filename:    TeamUpStageSuccessView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-05-28 15:32:26
    Description: File description
--]]

local TeamUpStageSuccessView = class("TeamUpStageSuccessView", BasePopView)

function TeamUpStageSuccessView:ctor()
    TeamUpStageSuccessView.super.ctor(self)
end


function TeamUpStageSuccessView:onInit()

    local bg = self:getUI("bg")
    bg:setVisible(false)

    local img1 = self:getUI("bg1.layer.attrLab1.img") 
    if img1 then
        img1:loadTexture("teamImageUI4_iconAtk.png", 1)
    end
    
    local img2 = self:getUI("bg1.layer.attrLab2.img") 
    if img2 then
        img2:loadTexture("teamImageUI4_iconAck.png", 1)
    end

    local img3 = self:getUI("bg1.layer.attrLab3.img") 
    if img3 then
        img3:loadTexture("teamImageUI4_iconDef.png", 1)
    end

    local bg1 = self:getUI("bg1")
    bg1:setVisible(false)
    
    self._newSkillOpen = 0
    -- self._tishi = self:getUI("bg.tishi")
    self._closeBtn = self:getUI("closeBtn")
    -- self._bg = self:getUI("bg.bg3")
    -- local skillBg = self:getUI("bg1.skillBg")
    -- skillBg:setVisible(true)
    self._viewMgr:lock() 
    
end

function TeamUpStageSuccessView:setElement()
    
    self._anim = {}
    for i=1,8 do
        if i == 1 then
            self._anim[i] = self._layerBg:getChildByFullName("icon") -- self:getUI("bg.oldIcon")
        elseif i == 2 then
            self._anim[i] = self._layerBg:getChildByFullName("jiantou") -- self:getUI("bg.jiantou")
        -- elseif i == 3 then
        --     self._anim[i] = self._layerBg:getChildByFullName("icon") -- self:getUI("bg.icon.newIcon")
        elseif i == 3 then
            self._anim[i] = self._layerBg:getChildByFullName("fight") -- self:getUI("bg.fight")
        elseif i == 8 then
            self._anim[i] = self._layerBg:getChildByFullName("skillBg") -- self:getUI("bg.newSkillBg")
        else -- if i == 5 then
            self._anim[i] = self._layerBg:getChildByFullName("attrLab" .. (i - 4)) -- self:getUI("bg.attrLab" .. (i - 4))
        end 
        if self._anim[i] then
            self._anim[i]:setVisible(false)
        end
    end
    self._tishi = self._layerBg:getChildByFullName("tishi") -- self:getUI("bg.tishi")
end

function TeamUpStageSuccessView:nextAnimFunc()
    -- audioMgr:playSound("adTitle")

    local bgW,bgH = self._bg:getContentSize().width,self._bg:getContentSize().height
  
    ScheduleMgr:delayCall(300, self, function()
        if not self._anim then return end
        self._anim[1]:setVisible(true)
        local oldIcon = self._anim[1]:getChildByFullName("oldIcon")
        oldIcon:runAction(cc.Sequence:create(cc.MoveBy:create(0, cc.p(60, 0)),cc.MoveBy:create(0.15, cc.p(-60, 0)))) -- ,cc.JumpBy:create(0.15, cc.p(-60, 0),10,1)))
        local newIcon = self._anim[1]:getChildByFullName("newIcon")
        newIcon:runAction(cc.Sequence:create(cc.MoveBy:create(0, cc.p(-60, 0)),cc.MoveBy:create(0.15, cc.p(60, 0)))) -- ,cc.JumpBy:create(0.15, cc.p(60, 0),10,1)))
    end)

    ScheduleMgr:delayCall(350, self, function()
        if not self._anim then return end
        self._anim[2]:setVisible(true)
    end)

    for i=3,7 do
        local des = self._anim[i]
        ScheduleMgr:delayCall(200*i + 100, self, function()
            if not self._anim then return end
            print("========", i)
            des:setVisible(true)
            -- des:runAction(cc.JumpBy:create(0.2,cc.p(0,0),10,1))

            local mcShua = mcMgr:createViewMC("shuxingshuguang_itemeffectcollection", true, false, function (_, sender)
                sender:removeFromParent()
            end,RGBA8888)
            mcShua:setPosition(cc.p(des:getContentSize().width*0.5-80, 12))
            mcShua:setScaleY(0.8)
            audioMgr:playSound("adTag")
            des:addChild(mcShua)
        end)
    end

    if self._newSkillOpen == 1 then
        ScheduleMgr:delayCall(1500, self, function()
            if not self._anim then return end
            self._anim[8]:setVisible(true)
            local Image_163 = self:getUI("bg1.layer.skillBg.Image_163")
            local newSkillBg = self:getUI("bg1.layer.skillBg.newSkillBg")
            newSkillBg:setVisible(false)
            Image_163:setVisible(false)
            local callFunc = cc.CallFunc:create(function()
                local newSkillBg1 = self:getUI("bg1.layer.skillBg.newSkillBg")
                newSkillBg1:setVisible(true)
                local Image163 = self:getUI("bg1.layer.skillBg.Image_163")
                Image163:setVisible(true)
                local panel200 = self:getUI("bg1.layer.skillBg.newSkillBg.Panel_200")
                panel200:setVisible(true)
            end)
            Image_163:runAction(cc.Sequence:create(cc.MoveBy:create(0.01, cc.p(-300, 0)),cc.MoveBy:create(0.3, cc.p(300, 0)))) -- ,cc.JumpBy:create(0.3, cc.p(400, 0),10,1)))
            newSkillBg:runAction(cc.Sequence:create(cc.MoveBy:create(0.01, cc.p(300, 0)),callFunc,cc.MoveBy:create(0.3, cc.p(-300, 0)))) --,cc.JumpBy:create(0.3, cc.p(-400, 0),10,1)))
            self._tishi:setVisible(true)
        end)
        ScheduleMgr:delayCall(1800, self, function()
            if not self._anim then return end
            -- local mcStar = mcMgr:createViewMC("shanguang_intancenopen", false, true, nil, RGBA8888)
            -- mcStar:setPosition(cc.p(226, 52))
            -- self._anim[7]:addChild(mcStar)
            self._viewMgr:unlock()
        end)
    else
        ScheduleMgr:delayCall(1500, self, function()
            if not self._tishi then return end
            self._tishi:setVisible(true)
            self._viewMgr:unlock()
        end)
    end
end


function TeamUpStageSuccessView:reflashUI(inData)
    self:registerClickEvent(self._closeBtn, function ()
        print("关=================")
        self:close(true, inData.callback)
        UIUtils:reloadLuaFile("team.TeamUpStageSuccessView")
    end)

    self._teamData = inData.teamData
    local oldTeamData = inData.oldTeamData
    local skillIndex = inData.skillIndex
    local sysTeam = tab:Team(oldTeamData.teamId)

    local teamModel = self._modelMgr:getModel("TeamModel")

    print("skillIndex==========", skillIndex)
    if skillIndex <= 0 then 
        self._newSkillOpen = 0
        self._layerBg = self:getUI("bg.layer")
        self._layerBg:setVisible(true)
        self._bg = self:getUI("bg")
        self._layer = self:getUI("bg.layer")
        self._bgImg = self:getUI("bg.bg3")
        self._bg:setVisible(true)
        self._titlePosY = 471
    else
        self._newSkillOpen = 1 
        local sysTeam = tab:Team(self._teamData.teamId)
        if sysTeam.skill == nil then 
            return
        end

        local skillId, skillType
        if skillIndex == 5 then   --新特技icon显示
            skillId = 6900050
            skillType = 2
        else
            skillId = sysTeam.skill[skillIndex][2]
            skillType = sysTeam.skill[skillIndex][1]
        end
        
        local sysSkill = SkillUtils:getTeamSkillByType(skillId, skillType)

        if sysSkill ~= nil then 
            local panel203 = self:getUI("bg1.layer.skillBg.newSkillBg.Panel_203")
            local desc = SkillUtils:handleSkillDesc1(lang(sysSkill.des1), self._teamData, 1)
            desc = string.gsub(desc,"%b[]",function( catchStr )
                local _,pos1 = string.find(catchStr,"%[color=")
                if pos1 then
                    return string.sub(catchStr,1,pos1) .. "fae0bc" .. string.sub(catchStr,pos1+7,string.len(catchStr))
                else
                    return catchStr 
                end
            end) 

            local richText = RichTextFactory:create(desc, panel203:getContentSize().width, panel203:getContentSize().height)
            richText:formatText()
            richText:enablePrinter(true)
            richText:setPosition(panel203:getContentSize().width/2, panel203:getContentSize().height - richText:getInnerSize().height/2)
            panel203:addChild(richText)

            local Label_12 = self:getUI("bg1.layer.skillBg.newSkillBg.Label_12")
            Label_12:setString("新技能：")

            local nameLab = self:getUI("bg1.layer.skillBg.newSkillBg.nameLab")
            nameLab:setString(lang(sysSkill.name))

            local panel200 = self:getUI("bg1.layer.skillBg.newSkillBg.Panel_200")
            panel200:setVisible(false)
            local icon = IconUtils:createTeamSkillIconById({teamSkill = sysSkill ,eventStyle = 0})
            icon:setPosition(panel200:getContentSize().width/2, panel200:getContentSize().height/2)
            icon:setAnchorPoint(0.5, 0.5)
            panel200:addChild(icon)
        end
        self._layerBg = self:getUI("bg1.layer")
        self._layerBg:setVisible(true)
        self._bg = self:getUI("bg1")
        self._bgImg = self:getUI("bg1.bg2")
        self._layer = self:getUI("bg1.layer")
        self._bg:setVisible(true)
        local skillBg = self:getUI("bg1.layer.skillBg")
        skillBg:setVisible(false)
        self._titlePosY = 490
    end

    self:setElement()
    -- self._teamData.stage = self._teamData.stage - 1
    local backQuality = teamModel:getTeamQualityByStage(oldTeamData.stage)
    local leftIcon = IconUtils:createTeamIconById({teamData = oldTeamData,sysTeamData = sysTeam, quality = backQuality[1] , quaAddition = backQuality[2],  eventStyle = 0})
    local leftIconBg = self._layerBg:getChildByFullName("icon.oldIcon") -- self:getUI("bg.oldIcon")
    leftIcon:setPosition(cc.p(leftIconBg:getContentSize().width/2, leftIconBg:getContentSize().height/2))
    leftIcon:setAnchorPoint(cc.p(0.5, 0.5))
    leftIcon:setScale(0.9)
    leftIconBg:addChild(leftIcon)

 -- 战斗力显示处理
    local oldFight = self._layerBg:getChildByFullName("fight.oldFight") -- self:getUI("bg.fight.oldFight")
    oldFight:setString("a" .. oldTeamData.score)
    oldFight:setFntFile(UIUtils.bmfName_zhandouli)
    oldFight:setScale(0.5)

    -- 名称显示处理
    self._curSelectSysTeam = tab:Team(oldTeamData.teamId)
    local teamName, art1, art2, art3, teamArt = TeamUtils:getTeamAwakingTab(oldTeamData)
    local sysLangName = lang(teamName)
    if backQuality[2] ~= 0 then 
        sysLangName = sysLangName .. "+" .. backQuality[2]
    end

    local leftName = self._layerBg:getChildByFullName("icon.oldIcon.name") -- self:getUI("bg.oldIcon.name")
    -- leftName:setColor(cc.c3b(17,132,239))
    -- local leftBackQuality = teamModel:getTeamQualityByStage(leftEquipStage)
    leftName:setColor(UIUtils.colorTable["ccColorQuality" .. backQuality[1]])
    leftName:setFontSize(20)
    leftName:setString(sysLangName)

    local tempEquips = {}
    for i=1,4 do
        local tempEquip = {}
        local equipLevel = self._teamData["el" .. i]
        local equipStage = self._teamData["es" .. i]
        tempEquip.stage = equipStage
        tempEquip.level = equipLevel
        table.insert(tempEquips, tempEquip)
    end

    local oldBackData, oldBackSpeed = BattleUtils.getTeamBaseAttr(oldTeamData, tempEquips, self._modelMgr:getModel("PokedexModel"):getScore(), nil, nil, nil, nil, nil, self._modelMgr:getModel("BattleArrayModel"):getData(), self._modelMgr:getModel("ParagonModel"):getData())
    -- 获取宝物属性
    local attr = teamModel:getTeamTreasure(oldTeamData.volume)
    local treasureAttr = teamModel:getTeamTreasureAttrData(oldTeamData.teamId)
    -- 获取英雄属性
    local heroAttr = teamModel:getTeamHeroAttrByTeamId(oldTeamData.teamId)
    for i=BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
        oldBackData[i] = oldBackData[i] + heroAttr[i] + treasureAttr[i] + attr[i]
    end

    print("self._layerBg======", self._layerBg:getName())
    local leftAttrTipLab0 = self._layerBg:getChildByFullName("attrLab0.leftAttrTipLab") -- self:getUI("bg.attrLab1.tipLab1")
    leftAttrTipLab0:setString(lang("ATTR_999").. "：")

    local leftAttrTipLab1 = self._layerBg:getChildByFullName("attrLab1.leftAttrTipLab") -- self:getUI("bg.attrLab1.tipLab1")
    leftAttrTipLab1:setString(lang("ATTR_93").. "：")

    local leftAttrTipLab2 = self._layerBg:getChildByFullName("attrLab2.leftAttrTipLab") -- self:getUI("bg.attrLab2.leftAttrTipLab")
    leftAttrTipLab2:setString(lang("ATTR_94").. "：")

    local leftAttrTipLab3 = self._layerBg:getChildByFullName("attrLab3.leftAttrTipLab") -- self:getUI("bg.attrLab3.tipLab3")
    leftAttrTipLab3:setString(lang("ATTR_95").. "：")

    -- local tipLab4 = self:getUI("bg.tipLab4")
    -- tipLab4:setString(lang("ATTR_8") .. "：")

    local leftAttrLab0 = self._layerBg:getChildByFullName("attrLab0.leftAttrLab") 
    local posStr = self._modelMgr:getModel("TeamModel"):getTeamAddPingScore(oldTeamData)
    leftAttrLab0:setString(posStr) 

    local leftAttrLab1 = self._layerBg:getChildByFullName("attrLab1.leftAttrLab") -- self:getUI("bg.attrLab1.attrLab1")
    local attack = BattleUtils.getTeamAttackAttr(oldBackData, true)
    attack = TeamUtils.getNatureNums(attack)
    leftAttrLab1:setString(attack)

    local leftAttrLab2 = self._layerBg:getChildByFullName("attrLab2.leftAttrLab") -- self:getUI("bg.attrLab2.attrLab2")
    local hp = BattleUtils.getTeamHpAttr(oldBackData, true) 
    hp = TeamUtils.getNatureNums(hp)
    leftAttrLab2:setString(hp)

    local leftAttrLab3 = self._layerBg:getChildByFullName("attrLab3.leftAttrLab") -- self:getUI("bg.attrLab3.attrLab3")
    leftAttrLab3:setString(TeamUtils.getNatureNums(oldBackData[7]))

    -- local attrLab4 = self:getUI("bg.attrLab4.attrLab4")
    -- attrLab4:setString(TeamUtils.getNatureNums(oldBackData[8]))

    -- local Image_142 = self:getUI("bg.Image_142")
    -- Image_142:setVisible(false)
    -- tipLab4:setVisible(false)
    -- attrLab4:setVisible(false)


    -- self._teamData.stage = self._teamData.stage + 1
    backQuality = teamModel:getTeamQualityByStage(self._teamData.stage)
    local rightIcon = IconUtils:createTeamIconById({teamData = self._teamData,sysTeamData = sysTeam, quality = backQuality[1] , quaAddition = backQuality[2],  eventStyle = 0})
    local rightIconBg = self._layerBg:getChildByFullName("icon.newIcon") -- self:getUI("bg.icon.newIcon")
    rightIcon:setPosition(cc.p(rightIconBg:getContentSize().width/2, rightIconBg:getContentSize().height/2))
    rightIcon:setAnchorPoint(cc.p(0.5, 0.5))
    rightIcon:setScale(0.9)
    rightIconBg:addChild(rightIcon)

    local sysLangName = lang(teamName)
    if backQuality[2] ~= 0 then 
        sysLangName = sysLangName .. "+" .. backQuality[2]
    end
    local rightName = self._layerBg:getChildByFullName("icon.newIcon.name") -- self:getUI("bg.icon.newIcon.name")
    -- rightName:setColor(cc.c3b(17,132,239))
    rightName:setColor(UIUtils.colorTable["ccColorQuality" .. backQuality[1]])
    rightName:setFontSize(20)
    rightName:setString(sysLangName)


    local newTeamData,_ = teamModel:getTeamAndIndexById(self._teamData.teamId)
    local newFight = self._layerBg:getChildByFullName("fight.newFight") -- self:getUI("bg.fight.newFight")
    newFight:setString("a" .. newTeamData.score)
    newFight:setFntFile(UIUtils.bmfName_zhandouli)
    newFight:setScale(0.5)

    local backData, backSpeed = BattleUtils.getTeamBaseAttr(self._teamData, tempEquips, self._modelMgr:getModel("PokedexModel"):getScore(), nil, nil, nil, nil, nil, self._modelMgr:getModel("BattleArrayModel"):getData(), self._modelMgr:getModel("ParagonModel"):getData())
    for i=BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
        backData[i] = backData[i] + heroAttr[i] + treasureAttr[i] + attr[i]
    end
    local rightAttrLab1 = self._layerBg:getChildByFullName("attrLab0.rightAttrLab") 
    local posStr = self._modelMgr:getModel("TeamModel"):getTeamAddPingScore(self._teamData)
    rightAttrLab1:setString(posStr) 

    local attack = BattleUtils.getTeamAttackAttr(backData, true)
    local rightAttrLab1 = self._layerBg:getChildByFullName("attrLab1.rightAttrLab") -- self:getUI("bg.attrLab1.rattrLab1")
    rightAttrLab1:setString(TeamUtils.getNatureNums(attack))

    local rightAttrLab2 = self._layerBg:getChildByFullName("attrLab2.rightAttrLab") -- self:getUI("bg.attrLab2.rattrLab2")
    local hp = BattleUtils.getTeamHpAttr(backData, true)
    rightAttrLab2:setString(TeamUtils.getNatureNums(hp))

    local rightAttrLab3 = self._layerBg:getChildByFullName("attrLab3.rightAttrLab") -- self:getUI("bg.attrLab3.rattrLab3")
    rightAttrLab3:setString(TeamUtils.getNatureNums(backData[7]))

    -- local attrLab4 = self:getUI("bg.rattrLab4")
    -- attrLab4:setString(TeamUtils.getNatureNums(backData[8]))
    -- attrLab4:setVisible(false)


    -- local stageLab = self:getUI("bg.stageLab")
    -- stageLab:setString("+" .. self._teamData.stage)

    -- for i= 1 , 6 do
    --  local starImg = self:getUI("bg.star" .. i)
    --  if i <= self._teamData.star  then 
    --      starImg:setVisible(true)

    --  else
    --      starImg:setVisible(false)
    --  end
    -- end
    print("skillIndex ============", inData.skillIndex)
    -- local newSkillBg = self:getUI("bg1.newSkillBg")

    local sizeSchedule
    local step = 0.5
    local stepConst = 30
    local bg1Height = 150    
    self.bgWidth = self._bgImg:getContentSize().width    
    local maxHeight = self._bgImg:getContentSize().height
    self._bgImg:setOpacity(0)
    self._layer:setVisible(false)
    self._bgImg:setPositionX(self._layer:getContentSize().width*0.5)
    self._bgImg:setContentSize(cc.size(self.bgWidth,bg1Height))
    self:animBegin(function( )
        self._bgImg:setOpacity(255)
        self._layer:setVisible(true) 
        sizeSchedule = ScheduleMgr:regSchedule(1,self,function( )
            stepConst = stepConst-step
            if stepConst < 1 then 
                stepConst = 1
            end
            bg1Height = bg1Height+stepConst
            if bg1Height < maxHeight then
                self._bgImg:setContentSize(cc.size(self.bgWidth,bg1Height))                   
            else
                self._bgImg:setContentSize(cc.size(self.bgWidth,maxHeight))
                ScheduleMgr:unregSchedule(sizeSchedule)
                self:addDecorateCorner() 
                self:nextAnimFunc()            
            end
        end)
    end)
end

function TeamUpStageSuccessView:animBegin(callback)
    -- 播放获得音效
    audioMgr:playSound("ItemGain_1")
    --升星成功
    self:addPopViewTitleAnim(self._bg, "jinjiechenggong_huodetitleanim", 568, self._titlePosY)

    ScheduleMgr:delayCall(400, self, function( )
        if self._bg then                    
            --震屏
            -- UIUtils:shakeWindow(self._bg)
            -- ScheduleMgr:delayCall(200, self, function( )
            if callback and self._bg then
                callback()
            end
            -- end)
        end
    end)
   
end

function TeamUpStageSuccessView:getMaskOpacity()
    return 230
end

return TeamUpStageSuccessView