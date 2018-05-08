--[[
    Filename:    TeamTalentUpgradeDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-04-08 16:14:30
    Description: File description
--]]


local TeamTalentUpgradeDialog = class("TeamTalentUpgradeDialog", BasePopView)

function TeamTalentUpgradeDialog:ctor(param)
    TeamTalentUpgradeDialog.super.ctor(self)
end

function TeamTalentUpgradeDialog:onInit()
    local bg = self:getUI("bg")
    -- local bgLayer = ccui.Layout:create()
    -- bgLayer:setBackGroundColorOpacity(180)
    -- bgLayer:setBackGroundColorType(1)
    -- bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    -- bgLayer:setTouchEnabled(true)
    -- bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    -- bg:getParent():addChild(bgLayer, -1)
    local closeBtn = self:getUI("closeBtn")
    registerClickEvent(closeBtn, function()        
        self:close()
        UIUtils:reloadLuaFile("team.TeamTalentUpgradeDialog")
    end)
    closeBtn:setTouchEnabled(false)


    -- -- local oldName = self:getUI("bg.layer.oldIcon.name")
    -- local oldName = self:getUI("bg.layer.attrImg.oldName")
    -- oldName:setFontName(UIUtils.ttfName)
    -- oldName:setColor(cc.c3b(255, 249, 181))
    -- oldName:enable2Color(1, cc.c4b(233, 160, 0, 255))
    -- oldName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 3)
    -- oldName:setFontSize(30)
    -- -- local newName = self:getUI("bg.layer.newIcon.name")
    -- local newName = self:getUI("bg.layer.attrImg.newName")
    -- newName:setFontName(UIUtils.ttfName)
    -- newName:setColor(cc.c3b(255, 249, 181))
    -- newName:enable2Color(1, cc.c4b(233, 160, 0, 255))
    -- newName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 3)
    -- newName:setFontSize(30)
    local attrImg = self:getUI("bg.layer.attrImg")
    local pScoreBg = self:getUI("bg.layer.pScoreBg")
    local richtextBg = self:getUI("bg.layer.richtextBg")
    attrImg:setVisible(false)
    pScoreBg:setVisible(false)
    richtextBg:setVisible(false)

    self._viewMgr:lock(-1)
    self._tishi = self:getUI("bg.layer.tishi")
    self._bg = self:getUI("bg")
    self._bgImg = self:getUI("bg.bg3")
    self._layer = self:getUI("bg.layer")
    -- self._closeBtn = self:getUI("closeBtn")
    -- local mcMgr = MovieClipManager:getInstance()
end

function TeamTalentUpgradeDialog:reflashUI(inData)
    dump(inData,"inData")
    if not inData then
        return
    end
    self._teamData = inData.teamData
    local skillLvl = inData.skillLvl
    self._teamId = self._teamData.teamId

    self._systeam = tab:Team(self._teamId)
    local cs = self._systeam.cs
    local skillType = cs[1]
    local skillId = cs[2]
    local sysSkill = SkillUtils:getTeamSkillByType(skillId, skillType)
    local skillBg = self:getUI("bg.layer.skillBg")
    local skillIcon = skillBg:getChildByName("skillIcon")
    if skillIcon ~= nil then 
        IconUtils:updateTeamSkillIconByView(skillIcon, {teamSkill = sysSkill ,isGray = isGray ,eventStyle = 0, teamData = self._teamData, level = tempLevel})
    else
        skillIcon = IconUtils:createTeamSkillIconById({teamSkill = sysSkill, eventStyle = 0, teamData = self._teamData, level = 0})
        skillIcon:setName("skillIcon")
        skillIcon:setPosition(-10, -8)
        skillBg:addChild(skillIcon)
    end


    local name = self:getUI("bg.layer.skillBg.name")
    name:setString(lang(sysSkill.name))

    local level,pScore = self._modelMgr:getModel("TeamModel"):getSkillLevelAndScore(self._teamData)

    -- local oldName = self:getUI("bg.layer.oldIcon.name")
    local oldName = self:getUI("bg.layer.attrImg.oldName")
    oldName:setString("Lv." .. skillLvl[1])
    
    -- local newName = self:getUI("bg.layer.newIcon.name")
    local newName = self:getUI("bg.layer.attrImg.newName")
    newName:setString("Lv." .. skillLvl[2])

    local pScoreBg = self:getUI("bg.layer.pScoreBg")
    local des1 = self:getUI("bg.layer.pScoreBg.des1")
    local des2 = self:getUI("bg.layer.pScoreBg.des2")
    local str = "+" .. pScore
    des2:setString(str)
    des2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- desc = "[color=fae6c8]图鉴评分[-][color=00ff22,fontsize=20,outlinecolor=3c1e0aff,outlinesize=1]+" .. pScore .. "[-]"
    -- desc = string.gsub(desc, "562600", "fae6c8")
    -- local richText = RichTextFactory:create(desc, pScoreBg:getContentSize().width, pScoreBg:getContentSize().height)
    -- richText:formatText()
    -- richText:enablePrinter(true)
    -- richText:setPosition(pScoreBg:getContentSize().width*0.5, pScoreBg:getContentSize().height - richText:getInnerSize().height*0.5)
    -- richText:setName("richText")
    -- pScoreBg:addChild(richText)

    local richtextBg = self:getUI("bg.layer.richtextBg")
    local desc = SkillUtils:handleSkillDesc1(lang(sysSkill.des), self._teamData, skillLvl[2], 0)

    -- desc = "[][-][color=fae6c8]图鉴评分[-][color=00ff22,fontsize=20,outlinecolor=3c1e0aff,outlinesize=1]+" .. pScore .. "[-]" .. desc
    desc = string.gsub(desc, "562600", "fae6c8")
    local richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5)
    richText:setName("richText")
    richtextBg:addChild(richText)

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
        sizeSchedule = ScheduleMgr:regSchedule(1,self,function( )
            stepConst = stepConst-step
            if stepConst < 1 then 
                stepConst = 1
            end
            bg1Height = bg1Height+stepConst
            if bg1Height < maxHeight then
                self._bgImg:setContentSize(cc.size(self.bgWidth,bg1Height))                   
            else
                self._layer:setVisible(true)
                self._bgImg:setContentSize(cc.size(self.bgWidth,maxHeight))
                ScheduleMgr:unregSchedule(sizeSchedule)
                self:addDecorateCorner()
                self:nextAnimFunc()      
                -- nextAnimFunc()   
                -- self._viewMgr:unlock()          
            end
        end)
    end)
end

function TeamTalentUpgradeDialog:nextAnimFunc()
    local bgW,bgH = self._bg:getContentSize().width,self._bg:getContentSize().height
  
    ScheduleMgr:delayCall(300, self, function()
        local attrImg = self:getUI("bg.layer.attrImg")
        if not attrImg then return end
        attrImg:setVisible(true)
        local mcShua = mcMgr:createViewMC("shuxingshuguang_itemeffectcollection", true, false, function (_, sender)
            sender:removeFromParent()
        end,RGBA8888)
        mcShua:setPosition(cc.p(attrImg:getContentSize().width*0.5-80, 12))
        mcShua:setScaleY(0.8)
        audioMgr:playSound("adTag")
        attrImg:addChild(mcShua)
    end)
    ScheduleMgr:delayCall(500, self, function()
        local pScoreBg = self:getUI("bg.layer.pScoreBg")
        if not pScoreBg then return end
        pScoreBg:setVisible(true)
    end)
    ScheduleMgr:delayCall(700, self, function()
        local richtextBg = self:getUI("bg.layer.richtextBg")
        if not richtextBg then return end
        richtextBg:setVisible(true)
    end)
    ScheduleMgr:delayCall(1000, self, function()
        if not self._tishi then return end
        self._tishi:setVisible(true)
        local closeBtn = self:getUI("closeBtn")
        closeBtn:setTouchEnabled(true)
        self._viewMgr:unlock()
    end)
end

function TeamTalentUpgradeDialog:animBegin(callback)
    -- 播放获得音效
    audioMgr:playSound("ItemGain_1")

    self._bg = self:getUI("bg")
    self:addPopViewTitleAnim(self._bg, "jinshengchenggong_huodetitleanim", 568, 480)

    ScheduleMgr:delayCall(450, self, function( )
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

function TeamTalentUpgradeDialog:getMaskOpacity()
    return 230
end

return TeamTalentUpgradeDialog