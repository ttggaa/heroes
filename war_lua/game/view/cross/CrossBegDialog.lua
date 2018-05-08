--[[
    Filename:    CrossBegDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-11-18 13:00:52
    Description: File description
--]]

-- 跨服开始

local CrossBegDialog = class("CrossBegDialog", BasePopView)

function CrossBegDialog:ctor(param)
    CrossBegDialog.super.ctor(self)
    if not param then
        param = {}
    end
    self._callback = param.callback
end

function CrossBegDialog:onInit()
    self:registerClickEventByName("closeBtn", function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("cross.CrossBegDialog")
        end
        if self._callback then
            self._callback()
        end
        self:close()
    end)

    self._crossModel = self._modelMgr:getModel("CrossModel")
    self._userModel = self._modelMgr:getModel("UserModel")

    self._crossModel:setCrossMainOpenDialog()

    -- local title = self:getUI("bg.title")
    -- UIUtils:setTitleFormat(title, 1)

    self._bg = self:getUI("bg.bg")
    -- self._bg:setCascadeOpacityEnabled(true)

    self._server1 = self:getUI("bg.bg.server1")
    self._server1:setCascadeOpacityEnabled(true)
    self._server1:setOpacity(0)
    self._server2 = self:getUI("bg.bg.server2")
    self._server2:setCascadeOpacityEnabled(true)
    self._server2:setOpacity(0)
    self._animBg = self:getUI("bg.bg.animBg")
    self._animBg:setCascadeOpacityEnabled(true)
    self._animBg:setVisible(false)
    self._animBg:setOpacity(0)
    self._animBg:setScale(3)

    self._title = self:getUI("bg.title")
    self._title:setCascadeOpacityEnabled(true)
    self._title:setOpacity(0)
    self._title:setScale(3)
    self._arenaPanel = self:getUI("bg.arenaPanel")
    self._arenaPanel:setCascadeOpacityEnabled(true)
    self._arenaPanel:setOpacity(0)

    for i=1,3 do
        self:updateArenaScore(i)
    end

    -- self:registerClickEvent(title, function()
    --     self:test()
    -- end)
    self:refreshUI()
end


function CrossBegDialog:updateArenaScore(indexId)
    local arenaData = self._crossModel:getData()
    local regiontype = arenaData["regiontype" .. indexId]

    local arenaImg = self:getUI("bg.arenaPanel.arenaImg" .. indexId)
    if arenaImg then
        arenaImg:loadTexture("cross_section_" .. regiontype .. ".png", 1)
    end

    local aname = self:getUI("bg.arenaPanel.aname" .. indexId)
    if aname then
        aname:setString(lang("cp_nameRegion" .. regiontype))
    end

    local sec = arenaData[setStr] 
    -- local sNameStr1 = self._crossModel:getFightServerName(setStr1)
    -- local sNameStr2 = self._crossModel:getFightServerName(setStr2)

    local sNameStr1, sNameStr2 = self._crossModel:getWarZoneName()
    local timeLab = self:getUI("bg.title.timeLab")
    -- local openTime = self._crossModel:getOpenTime()
    local showStr = self._crossModel:getShowStr()
    timeLab:setString(showStr)

    local serverName1 = self:getUI("bg.bg.server1.serverName1")
    local serverName2 = self:getUI("bg.bg.server2.serverName1")
    serverName1:setString(sNameStr1)
    serverName2:setString(sNameStr2)

    serverName1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    serverName2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    local zhanquLab = self:getUI("bg.bg.server1.zhanquLab")
    zhanquLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local zhanquLab = self:getUI("bg.bg.server2.zhanquLab")
    zhanquLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
end


-- function CrossBegDialog:doPop(callback)
--     self._widget:setBackGroundColorOpacity(0)
--     self._widget:setTouchEnabled(true)
--     local bg = self:getUI("bg")
--     if bg then
--         bg:setAnchorPoint(0.5, 0.5)
--         bg:setVisible(false)
--         bg:stopAllActions()
--         bg:setScale(0.2)
--         self._doPopCallback = callback
--         audioMgr:playSound("Popup")
--         ScheduleMgr:delayCall(0, self, function()
--             if not bg then return end
--             local bgposx = bg:getPositionX()
--             local bgposy = bg:getPositionY()
--             local posx = 100 -- MAX_SCREEN_WIDTH + 100
--             local posy = MAX_SCREEN_HEIGHT - 100
--             bg:setPosition(posx, posy)
--             bg:setVisible(true)
--             local move1 = cc.MoveTo:create(0.1, cc.p(bgposx, bgposy))
--             local ease = cc.EaseOut:create(cc.ScaleTo:create(0.1, 1.05), 3)
--             local spawn = cc.Spawn:create(ease, move1)
--             bg:runAction(cc.Sequence:create(spawn, 
--                 cc.ScaleTo:create(0.07, 1.0),
--                 cc.CallFunc:create(function ()
--                 self._viewMgr:doPopShowGuide(self)
--                 if callback then
--                     callback()
--                 end
--                 self._doPopCallback = nil
--                 self:onPopEnd()
--             end)))
--         end)
--     else
--         callback()
--         audioMgr:playSound("Popup")
--         self._viewMgr:doPopShowGuide(self)
--         self:onPopEnd()
--     end 
-- end


function CrossBegDialog:nextAnimFunc()
    local bg = self:getUI("bg.bg")

    local callFunc1 = cc.CallFunc:create(function()
        local title = self:getUI("bg.title")
        local scale = cc.ScaleTo:create(0.2, 1)
        local fade = cc.FadeTo:create(0.2, 255)
        local spawn = cc.Spawn:create(scale, fade)
        -- local seq1 = cc.Sequence:create(arrayOfActions)
        title:runAction(spawn)
    end)
    local callFunc2 = cc.CallFunc:create(function()
        -- self._server2:setPositionX(560)
        local posx, posy = self._server1:getPositionX(), self._server1:getPositionY()
        self._server1:setPositionX(posx-800)
        self._server1:setVisible(true)
        local move = cc.MoveTo:create(0.2, cc.p(posx, posy))
        local fade = cc.FadeTo:create(0.2, 255)
        local spawn = cc.Spawn:create(move, fade)
        self._server1:runAction(spawn)
        local posx, posy = self._server2:getPositionX(), self._server2:getPositionY()
        self._server2:setPositionX(posx+800)
        self._server2:setVisible(true)
        local move = cc.MoveTo:create(0.2, cc.p(posx, posy))
        local fade = cc.FadeTo:create(0.2, 255)
        local spawn = cc.Spawn:create(move, fade)
        self._server2:runAction(spawn)
    end)
    local callFunc3 = cc.CallFunc:create(function()
        self._animBg:setVisible(true)
        local scale = cc.ScaleTo:create(0.2, 1)
        local fade = cc.FadeTo:create(0.2, 255)
        local spawn = cc.Spawn:create(scale, fade)
        self._animBg:runAction(spawn)

        self._mcVs = mcMgr:createViewMC("buffguangxiaoxia_duizhanui", true, false)
        self._mcVs:setPosition(self._animBg:getContentSize().width*0.5, 30)
        self._animBg:addChild(self._mcVs, 10)
    end)

    local callFunc4 = cc.CallFunc:create(function()
        local scale = cc.ScaleTo:create(0.2, 1)
        local fade = cc.FadeTo:create(0.2, 255)
        local spawn = cc.Spawn:create(scale, fade)
        -- local seq1 = cc.Sequence:create(arrayOfActions)
        self._arenaPanel:runAction(spawn)
    end)
    local seq = cc.Sequence:create(cc.DelayTime:create(0.1), callFunc1, cc.DelayTime:create(0.3), callFunc2, cc.DelayTime:create(0.3), callFunc3, cc.DelayTime:create(0.3), callFunc4)

    bg:runAction(seq)
end

function CrossBegDialog:refreshUI()
    self:nextAnimFunc()
end

return CrossBegDialog