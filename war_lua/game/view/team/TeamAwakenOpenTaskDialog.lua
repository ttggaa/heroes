--[[
    Filename:    TeamAwakenOpenTaskDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-08-22 14:55:34
    Description: File description
--]]

-- 开启任务弹窗
local TeamAwakenOpenTaskDialog = class("TeamAwakenOpenTaskDialog", BasePopView)

function TeamAwakenOpenTaskDialog:ctor(param)
    TeamAwakenOpenTaskDialog.super.ctor(self)
    self._teamId = param.teamId 
    self._callback = param.callback
end

function TeamAwakenOpenTaskDialog:onInit()
    local bg = self:getUI("bg")
    -- bg:setVisible(false)

    self._newSkillOpen = 0
    self._closeBtn = self:getUI("closeBtn")
    self:registerClickEvent(self._closeBtn, function ()
        print("关=================")
        if self._newSkillOpen == 1 then
            self:close(true, self._callback)
            -- ViewManager:getInstance():showView()
            UIUtils:reloadLuaFile("team.TeamAwakenOpenTaskDialog")
        end
        if self._newSkillOpen == 0 then
            self:addRichText()
            self._newSkillOpen = 1
        end
    end)
    -- self._viewMgr:lock() 
end

function TeamAwakenOpenTaskDialog:reflashUI(inData)
    self._teamId = inData.teamId
    local sysTeam = tab:Team(self._teamId)

    local teamModel = self._modelMgr:getModel("TeamModel")

    local race = sysTeam["race"][1]
    local raceTab = tab:Race(race)

    local raceBg = self:getUI("raceBg")
    raceBg:loadTexture("asset/uiother/race/awake_racefg_" .. raceTab.pic .. ".jpg", 0)
    raceBg:setScale(MAX_SCREEN_WIDTH/1136)

    local tishi = self:getUI("bg.tipBg.tishi")
    tishi:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    tishi:setString("点击任意位置前往任务")
    tishi:setVisible(false)

    local tPosTab = {250, 156}
    local raceTipPos = raceTab.raceTipPos or tPosTab

    local tipBg = self:getUI("bg.tipBg")
    tipBg:setPosition(raceTipPos[1], raceTipPos[2])

    local title = self:getUI("bg.tipBg.title")
    title:setAnchorPoint(0.5, 0.5)
    title:setOpacity(0)
    title:setScale(3)

    local fade = cc.FadeIn:create(0.3)
    local scale = cc.ScaleTo:create(0.2, 1)
    local seq1 = cc.Sequence:create(cc.Spawn:create(fade, scale))
    title:runAction(seq1)
    local callFunc1 = cc.CallFunc:create(function()
        -- local desc = "[color=ffffff,fontsize=24,outlinecolor=3c1e0aff,outlinesize=2]多年以后，罗伊德成为了泰拉里昂森林的守护者，就连精灵的长老们也常来寻求他的指引。[-]"
        local desc = lang(raceTab.awakingDes)
        local richtextBg = self:getUI("bg.tipBg.richtextBg")
        local richText = RichTextFactory:create(desc, richtextBg:getContentSize().width-30, richtextBg:getContentSize().height, false)
        richText:enablePrinter(true)
        richText:formatText()
        richText:setPosition((richText:getInnerSize().width+30)/2, richtextBg:getContentSize().height-25-richText:getInnerSize().height/2)
        richText:setName("descRichText")
        richtextBg:addChild(richText)
        richText:setPrintInterval(-5)
    end)

    local callFunc2 = cc.CallFunc:create(function()
        local tishi = self:getUI("bg.tipBg.tishi")
        self._newSkillOpen = 1
        tishi:setVisible(true)
    end)
    local seq = cc.Sequence:create(cc.DelayTime:create(0.2), callFunc1, cc.DelayTime:create(6), callFunc2)
    tipBg:runAction(seq)
end

function TeamAwakenOpenTaskDialog:addRichText()
    local richtextBg = self:getUI("bg.tipBg.richtextBg")
    local richText = richtextBg:getChildByName("descRichText")
    if richText then
        richText:enablePrinter(false)
        richText:formatText()
    end
    local tishi = self:getUI("bg.tipBg.tishi")
    tishi:setVisible(true)
    self._closeBtn:setTouchEnabled(false)
    local callFunc = cc.CallFunc:create(function()
        self._closeBtn:setTouchEnabled(true)
    end)
    tishi:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), callFunc))
end


function TeamAwakenOpenTaskDialog:getMaskOpacity()
    return 230
end


return TeamAwakenOpenTaskDialog