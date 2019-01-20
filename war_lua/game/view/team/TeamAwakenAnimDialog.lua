--[[
    Filename:    TeamAwakenAnimDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-08-21 19:47:53
    Description: File description
--]]


local TeamAwakenAnimDialog = class("TeamAwakenAnimDialog", BasePopView)
local AnimAp = require "base.anim.AnimAP"
function TeamAwakenAnimDialog:ctor(param)
    TeamAwakenAnimDialog.super.ctor(self)
    if not param then
        param = {}
    end
    self._param = param
    self._teamId = param.teamId or 106
    self._callback = param.callback
end

function TeamAwakenAnimDialog:onInit()
    self._closeBtn = self:getUI("closeBtn")
    self:registerClickEvent(self._closeBtn, function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("team.TeamAwakenAnimDialog")
        end
        ViewManager:getInstance():showDialog("team.TeamAwakenSuccessDialog", self._param)
        local callback = function()
        end
        self:close(true, self._callback)
    end)
    self._closeBtn:setTouchEnabled(false)
    -- local closeTip = self:getUI("bg.closeTip")
    -- closeTip:setVisible(false)
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._viewMgr:enableScreenWidthBar()

end

function TeamAwakenAnimDialog:onComplete()
    self._viewMgr:enableScreenWidthBar()
end

-- function TeamAwakenAnimDialog:onPopEnd()
--     self._viewMgr:enableScreenWidthBar()
-- end

function TeamAwakenAnimDialog:onDestroy()
    self._viewMgr:disableScreenWidthBar()
    TeamAwakenAnimDialog.super.onDestroy(self)
end


function TeamAwakenAnimDialog:reflashUI()
    local teamD = tab:Team(self._teamId)
    local race = tab:Race(teamD["race"][1])

    local fScale = 1136/1024
    local sScale = 1024/1136
    local raceBg = self:getUI("bg2.raceBg")
    local bgImg1 = ccui.ImageView:create()
    bgImg1:setName("bgImg1")
    bgImg1:setScale(fScale)
    bgImg1:loadTexture("asset/uiother/raceawake/awakingrace_" .. race.pic .. "_1.jpg", 0)
    bgImg1:setAnchorPoint(0, 0)
    bgImg1:setPosition(0, 0)
    raceBg:addChild(bgImg1)

    local bgImg2 = ccui.ImageView:create()
    bgImg2:setName("bgImg2")
    bgImg2:setScale(fScale)
    bgImg2:loadTexture("asset/uiother/raceawake/awakingrace_" .. race.pic .. "_2.jpg", 0)
    bgImg2:setAnchorPoint(0, 0)
    bgImg2:setPosition(1136, 0)
    raceBg:addChild(bgImg2)


    local mcStr = "juesedonghua_" .. (race.awaking or "renleijuexingrenwu")
    local bg2 = self:getUI("bg2")
    local mc1 = mcMgr:createViewMC(mcStr, false, false)
    mc1:setPosition(0, raceBg:getContentSize().height)
    mc1:setScale(fScale)
    mc1:addCallbackAtFrame(393, function()
        mc1:gotoAndPlay(367)
    end)
    raceBg:addChild(mc1, 20)

    local teamBg
    local children = mc1:getChildren()
    for k,v in pairs(children) do
        if k == 7 then
            teamBg = v
        end
    end

    local teamBgNode1 = self:addTeamVoluem(teamBg, self._teamId, false, "teamBgNode1")
    teamBgNode1:setPosition(10, -100)
    teamBg:addChild(teamBgNode1)
    teamBgNode1:setVisible(true)

    local teamBgNode2 = self:addTeamVoluem(teamBg, self._teamId, true, 'teamBgNode2')
    teamBgNode2:setPosition(10, -100)
    teamBg:addChild(teamBgNode2)
    teamBgNode2:setVisible(false)

    local move1 = cc.MoveBy:create(2.6, cc.p(-600, 0))
    local move2 = cc.MoveBy:create(0.4, cc.p(-524, 0))
    local callFunc1 = cc.CallFunc:create(function()
        local mc1 = mcMgr:createViewMC("juexingdonghua_juexing", false, true)
        mc1:setPosition(0, -80)
        local awakingRaceColor = TeamUtils.awakingRaceColor[race.pic]
        mc1:setContrast(awakingRaceColor.contrast)
        mc1:setBrightness(awakingRaceColor.brightness)
        mc1:setSaturation(awakingRaceColor.saturation)
        mc1:setHue(awakingRaceColor.hue)
        
        mc1:setScale(sScale)
        teamBg:addChild(mc1, 20)
    end)
    local callFunc2 = cc.CallFunc:create(function()
        local mc1 = mcMgr:createViewMC("kapaijuexing_juexing", false, false)
        mc1:setPosition(0, -100)
        mc1:setScale(sScale)
        teamBg:addChild(mc1, 20)
        -- mc1:setVisible(false)

        mc1:addCallbackAtFrame(10, function()
            local teamData = self._teamModel:getTeamAndIndexById(self._teamId)
            local sysTeam = tab:Team(self._teamId)
            local param = {teamD = sysTeam, level = teamData.level, star = teamData.star, teamData = teamData}
            local cardTeam
            if cardTeam then
                CardUtils:updateTeamCard(cardTeam, param)
            else
                cardTeam = CardUtils:createTeamCard(param)
                cardTeam:setScale(0.60)
                cardTeam:setPosition(10, -30)
                teamBg:addChild(cardTeam, 1)
            end

            local mc2 = mcMgr:createViewMC("choukahuodeguang_flashchoukahuode", true, false)
            mc2:setScale(3)
            mc2:setPosition(cardTeam:getContentSize().width*0.5, cardTeam:getContentSize().height*0.5)
            cardTeam:addChild(mc2, -1)

            self._closeBtn:setTouchEnabled(true)
        end)
    end)
    local callFunc3 = cc.CallFunc:create(function()
        -- local teamBgNode = teamBg:getChildByFullName("teamBgNode")
        -- if teamBgNode then
        --     teamBgNode:removeFromParent()
        -- end
        -- self:addTeamVoluem(teamBg, self._teamId, true)
        local teamBgNode1 = teamBg:getChildByFullName("teamBgNode1")
        if teamBgNode1 then
            teamBgNode1:setVisible(false)
        end
        local teamBgNode2 = teamBg:getChildByFullName("teamBgNode2")
        if teamBgNode2 then
            teamBgNode2:setVisible(true)
        end
    end)

    local move3 = cc.MoveBy:create(0.1, cc.p(0, -10))
    local move4 = cc.MoveBy:create(0.1, cc.p(0, 10))
    local seq1 = cc.Sequence:create(move3, move4)
    local repeatseq = cc.Repeat:create(seq1, 12)
    local seq = cc.Sequence:create(move1, cc.DelayTime:create(3), move2, 
        cc.DelayTime:create(1.2), repeatseq, cc.DelayTime:create(1), -- move3, move4, move5, move6, move7, move8, move9, move10,
        callFunc1, cc.DelayTime:create(0.8), callFunc3, cc.DelayTime:create(2), 
        callFunc2)
    raceBg:runAction(seq)
end

function TeamAwakenAnimDialog:addTeamVoluem(inView, teamId, flag, nodeName)
    local teamBgNode = ccui.Widget:create()
    teamBgNode:setName(nodeName)
    local teamRolesMap = TeamUtils.teamRolesMap
    local teamVolume = TeamUtils.teamVolume

    local teamD = tab:Team(teamId or 101)
    print("teamId=======", teamId, teamD)
    local teamNum = teamNum or teamVolume[tonumber(teamD.volume)]
    local sizeLim = {}
    if teamNum > 1 then
        sizeLim.width = 140
        sizeLim.height = 160
    end
    local teamRoleMap = teamRolesMap[teamNum] or {}
    local artZoom = teamD.artzoom/100
    local posScaleX,posScaleY = 0.6*artZoom,0.6*artZoom
    local offsetY = teamRoleMap[#teamRoleMap].pos.y*posScaleY*0.5
    for i,roleInfo in ipairs(teamRoleMap) do
        print("i,roleInfo========",i,roleInfo)
        local specialOffx = 0
        if teamId == 907 then
            specialOffx = 0
        elseif teamId == 407 then
            specialOffx = 80
        end

        local param = {}
        param[1] = roleInfo.pos.x*posScaleX
        param[2] = roleInfo.pos.y*posScaleY-offsetY+40 + specialOffx
        param[3] = roleInfo.scale
        param[4] = roleInfo.zOrder
        if teamId == 407 or teamId == 906 then
            param[3] = 0.4
        end
        self:addTeam(teamBgNode, param, 1, flag)
    end
    return teamBgNode
    -- teamBgNode:setPosition(10, -100)
    -- inView:addChild(teamBgNode)
end

function TeamAwakenAnimDialog:addTeam(inView, param, indexId, flag)
    local teamId = self._teamId
    local teamD = tab:Team(teamId)
    local indexId = indexId
    -- local teamArt = teamD.art 
    local teamName, art1, art2, art3, teamArt = TeamUtils:getTeamAwakingTab(teamD, teamId, flag)
    -- dump(AnimAp, "AnimAp==========")
    -- local teamScale = {906}
    if AnimAp["mcList"][teamArt] then
        MovieClipAnim.new(inView, teamArt, function (_sp) 
            _sp:setPosition(param[1], param[2])
            _sp:setScale(param[3])
            _sp:setLocalZOrder(param[4])
            -- _sp:setName("spteam" .. indexId)
            _sp:changeMotion(1)
            _sp:play()
            self._teamRole = _sp
        end, false, nil, nil, false) 
    else
        SpriteFrameAnim.new(inView, teamArt, function (_sp)
            _sp:setPosition(param[1], param[2])
            _sp:setScale(param[3])
            _sp:setLocalZOrder(param[4])
            _sp:setName("spteam" .. indexId)
            _sp:changeMotion(1)
            _sp:play()
            self._teamRole = _sp
        end)
    end
end


return TeamAwakenAnimDialog