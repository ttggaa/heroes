--[[
    Filename:    TeamUpStarSuccessView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-05-23 17:50:40
    Description: File description
--]]

local TeamUpStarSuccessView = class("TeamUpStarSuccessView", BasePopView)

function TeamUpStarSuccessView:ctor()
    TeamUpStarSuccessView.super.ctor(self)

end


function TeamUpStarSuccessView:onInit()

   
    local bg1 = self:getUI("bg.layer.bg1")
    bg1:setContentSize(cc.size(1136,402))

    local bg = self:getUI("bg")
 
    local closeBtn = self:getUI("closeBtn")
    registerClickEvent(closeBtn, function()
        self:close()
        UIUtils:reloadLuaFile("team.TeamUpStarSuccessView")
    end)

    self._anim = {}
    for i=1,10 do
        if i == 1 then
            self._anim[i] = self:getUI("bg.layer.oldIcon")
        elseif i == 2 then
            self._anim[i] = self:getUI("bg.layer.jiantou")
        elseif i == 3 then
            self._anim[i] = self:getUI("bg.layer.newIcon")
        elseif i == 4 then
            self._anim[i] = self:getUI("bg.layer.fight")
        elseif i == 10 then
            self._anim[i] = self:getUI("bg.layer.maxLevel")
        else -- if i == 5 then
            self._anim[i] = self:getUI("bg.layer.attrLab" .. (i - 5))
        end
        if self._anim[i] then
            self._anim[i]:setVisible(false)
        end
    end

    -- self._newSkillOpen = 0
    self._tishi = self:getUI("bg.layer.tishi")
    self._bg = self:getUI("bg")
    self._layer = self:getUI("bg.layer")
    self._bgImg = self:getUI("bg.layer.bg1")
   
    self._viewMgr:lock()
end

function TeamUpStarSuccessView:nextAnimFunc()
    -- audioMgr:playSound("adTitle")
    local bgW,bgH = self._bg:getContentSize().width,self._bg:getContentSize().height
    self._bgW,self._bgH = bgW,bgH
  
    local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl 

    local animTimes = 10
    if userlvl < 40 then
        animTimes = 9
    end
    for i=1,animTimes do
        local des = self._anim[i]
        -- print("========", des:getName())
        ScheduleMgr:delayCall(i*120, self, function( )
            des:setVisible(true)
            des:runAction(cc.JumpBy:create(0.1,cc.p(0,0),10,1))--cc.Sequence:create(,cc.CallFunc:create(function ( )
                if i < 4 then
                    audioMgr:playSound("adIcon")
                end
                if i >= 4 and i <= 9 then
                    local mcShua = mcMgr:createViewMC("shuxingshuguang_itemeffectcollection", true, false, function (_, sender)
                        sender:removeFromParent()
                    end,RGBA8888)
                    mcShua:setPosition(cc.p(des:getContentSize().width*0.5-80, 12))
                    mcShua:setScaleY(0.8)
                    audioMgr:playSound("adTag")
                    -- mcShua:setPlaySpeed(0.2)
                    des:addChild(mcShua)
                end
                if i == animTimes then
                    self._tishi:setVisible(true)
                    self._viewMgr:unlock()
                end
        end)
    end
end

function TeamUpStarSuccessView:reflashUI(inData)
    local oldTeamData = inData.old
    local newTeamData = inData.new

    -- dump(inData)
    local teamModel = self._modelMgr:getModel("TeamModel")
    -- newTeamData.stage = newTeamData.stage - 1
    -- local backQuality = teamModel:getTeamQualityByStage(newTeamData.stage)
    -- -- local leftIcon = IconUtils:createTeamIconById({teamData = newTeamData,sysTeamData = sysTeam, quality = backQuality[1] , quaAddition = backQuality[2],  eventStyle = 0})
    -- local leftIconBg = self:getUI("bg.layer.Panel_137_0")
    -- leftIcon:setPosition(cc.p(leftIconBg:getContentSize().width/2, leftIconBg:getContentSize().height/2))
    -- leftIcon:setAnchorPoint(cc.p(0.5, 0.5))
    -- leftIconBg:addChild(leftIcon)

    -- 名称显示处理
    self._curSelectSysTeam = tab:Team(newTeamData.teamId)
    local teamName, art1, art2, art3, teamArt = TeamUtils:getTeamAwakingTab(newTeamData)
    local sysLangName = lang(teamName)

	-- 隐藏无用的星星
    local oldSysTeam = tab:Team(oldTeamData.teamId)

    local oldFight = self:getUI("bg.layer.fight.oldFight")
    oldFight:setString("a" .. oldTeamData.score)
    oldFight:setFntFile(UIUtils.bmfName_zhandouli)
    oldFight:setScale(0.5)

    local leftPanelBg = self:getUI("bg.layer.oldIcon")

    local teamModel = self._modelMgr:getModel("TeamModel")
    
    local leftBackQuality = teamModel:getTeamQualityByStage(oldTeamData.stage)
    icon = IconUtils:createTeamIconById({teamData = oldTeamData, sysTeamData = oldSysTeam, quality = leftBackQuality[1] , quaAddition = leftBackQuality[2],  eventStyle = 0})
    icon:setName("teamIcon")
    icon:setScale(0.9)
    icon:setPosition(cc.p(leftPanelBg:getContentSize().width/2, leftPanelBg:getContentSize().height/2))
    icon:setAnchorPoint(cc.p(0.5, 0.5))
    leftPanelBg:addChild(icon)

    if leftBackQuality[2] ~= 0 then 
        sysLangName = sysLangName .. "+" .. leftBackQuality[2]
    end
    local leftPanelName = self:getUI("bg.layer.oldIcon.name")
    leftPanelName:setColor(cc.c3b(17,132,239))
    leftPanelName:setColor(cc.c3b(17,132,239))
    leftPanelName:setFontSize(20)
    leftPanelName:setString(sysLangName)
    leftPanelName:setColor(UIUtils.colorTable["ccColorQuality" .. leftBackQuality[1]])


    local sysLangName = lang(teamName)
    local rightPanelBg = self:getUI("bg.layer.newIcon")
    local rightBackQuality = teamModel:getTeamQualityByStage(newTeamData.stage)
    icon = IconUtils:createTeamIconById({teamData = newTeamData, sysTeamData = oldSysTeam,  quality = rightBackQuality[1] , quaAddition = rightBackQuality[2],  eventStyle = 0})
    icon:setName("teamIcon")
    icon:setScale(0.9)
    icon:setPosition(cc.p(rightPanelBg:getContentSize().width/2, rightPanelBg:getContentSize().height/2))
    icon:setAnchorPoint(cc.p(0.5, 0.5))
    rightPanelBg:addChild(icon)

    if rightBackQuality[2] ~= 0 then 
        sysLangName = sysLangName .. "+" .. rightBackQuality[2]
    end

    local newFight = self:getUI("bg.layer.fight.newFight")
    newFight:setString("a" .. newTeamData.score)
    newFight:setFntFile(UIUtils.bmfName_zhandouli)
    newFight:setScale(0.5)
    
    local rightPanelName = self:getUI("bg.layer.newIcon.name")
    rightPanelName:setColor(UIUtils.colorTable["ccColorQuality" .. rightBackQuality[1]])
    rightPanelName:setString(sysLangName)

    local leftAttrTipLab0 = self:getUI("bg.layer.attrLab0.leftAttrTipLab")
    leftAttrTipLab0:setString(lang("ATTR_999").. "：")

    local leftAttrTipLab1 = self:getUI("bg.layer.attrLab1.leftAttrTipLab")
    leftAttrTipLab1:setString(lang("ATTR_93").. "：")

    local leftAttrTipLab2 = self:getUI("bg.layer.attrLab2.leftAttrTipLab")
    leftAttrTipLab2:setString(lang("ATTR_94").. "：") 

    local leftAttrTipLab3 = self:getUI("bg.layer.attrLab3.leftAttrTipLab")
    leftAttrTipLab3:setString(lang("ATTR_95").. "：") 

    local leftAttrTipLab4 = self:getUI("bg.layer.attrLab4.leftAttrTipLab")
    leftAttrTipLab4:setString(lang("ATTR_97").. "：") 
   
    local leftAttrLab0 = self:getUI("bg.layer.attrLab0.leftAttrLab")
    local posStr = self._modelMgr:getModel("TeamModel"):getTeamAddPingScore(oldTeamData)
    leftAttrLab0:setString(posStr) 

    local leftAttrLab1 = self:getUI("bg.layer.attrLab1.leftAttrLab")
    leftAttrLab1:setString(TeamUtils.getNatureNums(oldSysTeam.atkadd[oldTeamData.star])) 


    local leftAttrLab2 = self:getUI("bg.layer.attrLab2.leftAttrLab")
    leftAttrLab2:setString(TeamUtils.getNatureNums(oldSysTeam.hpadd[oldTeamData.star]))

    local leftAttrLab3 = self:getUI("bg.layer.attrLab3.leftAttrLab")
    leftAttrLab3:setString(TeamUtils.getNatureNums(oldSysTeam.defadd[oldTeamData.star]))

    local leftAttrLab4 = self:getUI("bg.layer.attrLab4.leftAttrLab")
    leftAttrLab4:setString(TeamUtils.getNatureNums(oldSysTeam.atkspeedbase[oldTeamData.star])) 


    local newSysTeam = tab:Team(newTeamData.teamId)

    local rightAttrLab0 = self:getUI("bg.layer.attrLab0.rightAttrLab")
    local posStr = self._modelMgr:getModel("TeamModel"):getTeamAddPingScore(newTeamData)
    rightAttrLab0:setString(posStr) 

    local rightAttrLab1 = self:getUI("bg.layer.attrLab1.rightAttrLab")
    rightAttrLab1:setString(TeamUtils.getNatureNums(newSysTeam.atkadd[newTeamData.star]))

    local rightAttrLab2 = self:getUI("bg.layer.attrLab2.rightAttrLab")
    rightAttrLab2:setString(TeamUtils.getNatureNums(newSysTeam.hpadd[newTeamData.star])) 

    local rightAttrLab3 = self:getUI("bg.layer.attrLab3.rightAttrLab")
    rightAttrLab3:setString(TeamUtils.getNatureNums(newSysTeam.defadd[newTeamData.star])) 


    local rightAttrLab4 = self:getUI("bg.layer.attrLab4.rightAttrLab")
    rightAttrLab4:setString(TeamUtils.getNatureNums(newSysTeam.atkspeedbase[newTeamData.star])) 

    local maxSkillLab = self:getUI("bg.layer.maxLevel")
    maxSkillLab:setString("技能等级上限提高至：" .. tab:Star(newTeamData.star).skilllevel)


    local sizeSchedule
    local step = 0.5
    local stepConst = 30
    local bg1Height = 150 
    self.bgWidth = 1136   
    
    local maxHeight = 405 --self._bgImg:getContentSize().height
    print(self._bgImg:getContentSize().height,"=======self._bgImg:getContentSize().height=========maxHeight========",maxHeight)
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

function TeamUpStarSuccessView:animBegin(callback)
    -- 播放获得音效
    audioMgr:playSound("ItemGain_1")
    --升星成功
    self:addPopViewTitleAnim(self._bg, "shengxingchenggong_huodetitleanim", 568, 480)

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

function TeamUpStarSuccessView:getMaskOpacity()
    return 230
end

return TeamUpStarSuccessView