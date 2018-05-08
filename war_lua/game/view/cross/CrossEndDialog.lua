--[[
    Filename:    CrossEndDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-11-18 13:00:57
    Description: File description
--]]

-- 跨服结算
local CrossEndDialog = class("CrossEndDialog", BasePopView)

function CrossEndDialog:ctor(param)
    CrossEndDialog.super.ctor(self)
    if not param then
        param = {}
    end
    self._callback = param.callback
end


function CrossEndDialog:getBgName()
    return "gvg/citybattle_result2.jpg"
end


function CrossEndDialog:onInit()
    self:registerClickEventByName("closeBtn", function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("cross.CrossEndDialog")
        end
        if self._callback then
            self._callback()
        end
        self:close()
    end)

    self._crossModel = self._modelMgr:getModel("CrossModel")
    self._crossModel:setCrossMainOpenDialog()

    self._leftPanel = self:getUI("bg.bg.leftPanel")
    self._leftPanel:setCascadeOpacityEnabled(true)
    self._leftPanel:setOpacity(0)
    self._rightPanel = self:getUI("bg.bg.rightPanel")
    self._rightPanel:setCascadeOpacityEnabled(true)
    self._rightPanel:setOpacity(0)

    self._vsImg = self:getUI("bg.vsImg")
    self._vsImg:setOpacity(0)


    self:refreshUI()
end

function CrossEndDialog:refreshUI()
    local arenaData = self._crossModel:getData()
    dump(arenaData)
    local setStr1 = arenaData["sec1"]
    local setStr2 = arenaData["sec2"]
    local sNameStr1 = self._crossModel:getServerName(setStr1)
    local sNameStr2 = self._crossModel:getServerName(setStr2)
    
    local sname1 = self:getUI("bg.bg.leftPanel.serName")
    local sname2 = self:getUI("bg.bg.rightPanel.serName")
    sname1:setString(sNameStr1)
    sname2:setString(sNameStr2)

    local sscore1 = self:getUI("bg.bg.leftPanel.serScore")
    local sscore2 = self:getUI("bg.bg.rightPanel.serScore")

    local sec1score = arenaData["sec1score"] or 0
    local sec2score = arenaData["sec2score"] or 0
    local scoreStr = sec1score
    sscore1:setString(scoreStr)
    local scoreStr = sec2score
    sscore2:setString(scoreStr)

    local serverTh = self._crossModel:getMyServerTh(1)
    for i=1,3 do
        local rankName = self:getUI("bg.bg.leftPanel.rName" .. i)
        local rScore = self:getUI("bg.bg.leftPanel.rScore" .. i)
        -- rankName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        local playData = serverTh[i]
        dump(playData)
        if playData then
            local rankNameStr = playData.name 
            rankName:setString(rankNameStr)
            rScore:setString(playData.scoreA)
        else
            local rankNameStr = "虚位以待"
            rankName:setString(rankNameStr)
            rScore:setString("")
        end
    end

    local serverTh = self._crossModel:getMyServerTh(2)
    for i=1,3 do
        local rankName = self:getUI("bg.bg.rightPanel.rName" .. i)
        local rScore = self:getUI("bg.bg.rightPanel.rScore" .. i)
        -- rankName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        local playData = serverTh[i]
        if playData then
            local rankNameStr = playData.name 
            rankName:setString(rankNameStr)
            rScore:setString(playData.scoreA)
        else
            local rankNameStr = "虚位以待"
            rankName:setString(rankNameStr)
            rScore:setString("")
        end
    end

    local winImg1 = self:getUI("bg.bg.leftPanel.winImg")
    local winImg2 = self:getUI("bg.bg.rightPanel.winImg")

    local winner = tonumber(self._crossModel:getArenaWinner())
    local winImg = 0
    print("winner===========", winner)
    if winner == tonumber(setStr1) then
        winImg1:setVisible(true)
        winImg2:setVisible(false)
        winImg = 1
    elseif winner == tonumber(setStr2) then
        winImg1:setVisible(false)
        winImg2:setVisible(true)
        winImg = 2
    else
        winImg1:setVisible(false)
        winImg2:setVisible(false)
    end
    self:nextAnimFunc(winImg)
end

function CrossEndDialog:nextAnimFunc(winImg)
    local bg = self:getUI("bg.bg")
    local callFunc1 = cc.CallFunc:create(function()
        local posx, posy = self._leftPanel:getPositionX(), self._leftPanel:getPositionY()
        self._leftPanel:setPositionX(posx-200)
        self._leftPanel:setVisible(true)
        local move = cc.MoveTo:create(0.2, cc.p(posx, posy))
        local fade = cc.FadeTo:create(0.2, 255)
        local spawn = cc.Spawn:create(move, fade)
        self._leftPanel:runAction(spawn)
        local posx, posy = self._rightPanel:getPositionX(), self._rightPanel:getPositionY()
        self._rightPanel:setPositionX(posx+200)
        local move = cc.MoveTo:create(0.2, cc.p(posx, posy))
        local fade = cc.FadeTo:create(0.2, 255)
        local spawn = cc.Spawn:create(move, fade)
        self._rightPanel:runAction(spawn)

        local fade = cc.FadeTo:create(0.4, 255)
        local seq = cc.Sequence:create(cc.DelayTime:create(0.3), fade)
        self._vsImg:runAction(seq)
    end)

    local callFunc2 = cc.CallFunc:create(function()
        local winAnim = self:getUI("bg.bg.leftPanel.winImg")
        if winImg == 2 then
            winAnim = self:getUI("bg.bg.rightPanel.winImg")
        end

        local shengli = mcMgr:createViewMC("shengli_crosskuafurokou", false, false)
        shengli:setPosition(winAnim:getContentSize().width*0.5, winAnim:getContentSize().height*0.5)
        winAnim:addChild(shengli, 10)
    end)
    local seq = cc.Sequence:create(cc.DelayTime:create(0.3), callFunc1, cc.DelayTime:create(0.3), callFunc2)
    bg:runAction(seq)
end

return CrossEndDialog