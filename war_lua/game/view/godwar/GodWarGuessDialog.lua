--[[
    Filename:    GodWarGuessDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-04-18 20:48:23
    Description: File description
--]]

-- 支持选手
local GodWarGuessDialog = class("GodWarGuessDialog", BasePopView)

function GodWarGuessDialog:ctor(param)
    GodWarGuessDialog.super.ctor(self)
    self._callback = param.callback
    self._playerId = param.rid 
    self._subTime = param.subTime 
    self._support = param.support or 0
    self._rate = param.rate
    self._powId = param.powId
end

function GodWarGuessDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("godwar.GodWarGuessDialog")
        end
        self:close()
    end)  

    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)

    self._godWarModel = self._modelMgr:getModel("GodWarModel")

    local headBg = self:getUI("bg.headBg")
    local fightLab = cc.LabelBMFont:create("1", UIUtils.bmfName_zhandouli_little)
    fightLab:setName("fightLab")
    fightLab:setAnchorPoint(0, 0.5)
    fightLab:setPosition(225, 75)
    fightLab:setScale(0.6)
    headBg:addChild(fightLab, 1)
    headBg.fightLab = fightLab

    local stopTime = self:getUI("bg.stopTime")
    local subTime = self._subTime
    local callFunc = cc.CallFunc:create(function()
        subTime = subTime - 1
        if subTime <= 0 then
            self:close()
        end
        local minTime = math.floor(subTime/60)
        local secTime = math.fmod(subTime, 60)
        local ddTime = string.format("00:%.2d:%.2d", minTime, secTime)
        stopTime:setString(ddTime) 
    end)
    local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
    stopTime:runAction(cc.RepeatForever:create(seq))

    local zhichiValue = self:getUI("bg.headBg.zhichiValue")
    zhichiValue:setString(self._support .. "人支持他")
end

function GodWarGuessDialog:reflashUI()
    local data = self._godWarModel:getDispersedData()
    local winId = self._playerId
    local winData = self._godWarModel:getPlayerById(winId)
    if not winData then
        return
    end

    local headBg = self:getUI("bg.headBg")
    local iconBg = self:getUI("bg.headBg.headIcon")
    local param = {avatar = winData.avatar, level = winData.lvl, tp = 4, avatarFrame = winData["avatarFrame"], plvl = winData.plvl}
    local icon = iconBg:getChildByName("icon")
    if not icon then
        icon = IconUtils:createHeadIconById(param)
        icon:setName("icon")
        icon:setPosition(cc.p(2,2))
        iconBg:addChild(icon)
    else
        IconUtils:updateHeadIconByView(icon, param)
    end

    local tname = self:getUI("bg.headBg.name")
    tname:setString(winData.name)

    if headBg.fightLab then
        headBg.fightLab:setString(winData.score)
    end

    local rate = self._rate
    local baseRate = tab:Setting("G_GODWAR_STAGE" .. self._powId).value[1][1]
    local numValue1 = self:getUI("bg.numValue1")
    local value = math.ceil(baseRate*rate)
    numValue1:setString(value)
    local numValue2 = self:getUI("bg.numValue2")
    numValue2:setString(baseRate)

    local guessBtn = self:getUI("bg.guessBtn")
    self:registerClickEvent(guessBtn, function()
        if self._callback then
            self._callback()
        end
        self:close()
    end)
end

return GodWarGuessDialog
