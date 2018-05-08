--
-- Author: huangguofang
-- Date: 2017-03-31 21:17:50
--

local BattleResultBiographyLose = class("BattleResultBiographyLose", BasePopView)

function BattleResultBiographyLose:ctor(data)
    BattleResultBiographyLose.super.ctor(self)

    self._result = data.result
    self._callback = data.callback   
    
end

function BattleResultBiographyLose:onInit()

    self._bg = self:getUI("bg")
    self._touchPanel = self:getUI("touchPanel")
    self._touchPanel:setSwallowTouches(false)
    self._touchPanel:setEnabled(false)
    self:registerClickEvent(self._touchPanel, specialize(self.onQuit, self))
    -- 防止流程中报错无法关界面
    ScheduleMgr:delayCall(8000, self, function( )
        if tolua.isnull(self._touchPanel) then return end
        self._touchPanel:setEnabled(true)
    end)
    
    self._tipsTxt = self:getUI("tipsTxt")
    self._tipsTxt:setOpacity(0)

    local desTxt = self:getUI("bg.desTxt")
    desTxt:setColor(cc.c4b(251,251,251,255))
    desTxt:enable2Color(1, cc.c4b(143,143,143,255)) 
    desTxt:setFontSize(28)   
    desTxt:setTextAreaSize(cc.size(270,80))
    desTxt:enableOutline(cc.c4b(0,0,0,255),2) 

    self:animBegin()

end

function BattleResultBiographyLose:animBegin()

    audioMgr:stopMusic()
    audioMgr:playSoundForce("SurrenderBattle")

    local animPos = self:getUI("bg.animPos")
    local mc1 = mcMgr:createViewMC("huodedaojudiguang_commonlight", true, false, function (_, sender)
            sender:gotoAndPlay(20)
        end,RGBA8888)
    mc1:setPosition(animPos:getPosition())
    self._bg:addChild(mc1)
   
    local mc2 = mcMgr:createViewMC("shibai_commonlose", false)
    mc2:setPosition(animPos:getPosition())
    self._bg:addChild(mc2, 5)

    self._timeLabel = cc.Label:createWithTTF("00:00", UIUtils.ttfName, 26)
    self._timeLabel:setColor(cc.c3b(245, 20, 34))
    self._timeLabel:enableOutline(cc.c4b(0,0,0,255),2)
    self._timeLabel:setPosition(animPos:getPositionX(),animPos:getPositionY()-80)    
    self._bg:addChild(self._timeLabel,99)

    self._time = self._result.time
    if self._time then
        self:labelAnimTo(self._timeLabel, 0, self._time, true)
    end

    self._tipsTxt:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.FadeIn:create(0.3)))
    self._touchPanel:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
        self._touchPanel:setEnabled(true)
    end)))

end

-- 时间
function BattleResultBiographyLose:labelAnimTo(label, src, dest, isTime)
    audioMgr:playSound("TimeCount")
    label.src = src
    label.now = src
    label.dest = dest
    label:setString(src)
    label.isTime = isTime
    label.step = 1
    label.updateId = ScheduleMgr:regSchedule(1, self, function(self, dt)
        if label:isVisible() then
            if label.isTime then
                local value = math.floor((label.dest - label.now) * 0.05)
                if value < 1 then
                    value = 1
                end
                label.now = label.now + value
            else
                label.now = label.src + math.floor((label.dest - label.src) * (label.step / 50))
                label.step = label.step + 1
            end
            if math.abs(label.dest - label.now) < 5 then
                label.now = label.dest
                ScheduleMgr:unregSchedule(label.updateId)
            end
            if label.isTime then
                label:setString(formatTime(label.now))
            else
                label:setString(label.now)
            end
        end
    end)
end

function BattleResultBiographyLose:onQuit()
    if self._callback then
        self._callback()
    end
    -- UIUtils:reloadLuaFile("battle.BattleResultBiographyLose")
end

-- function BattleResultBiographyLose:onCount()
--  self._viewMgr:showView("battle.BattleCountView",self._battleInfo,true)
-- end

function BattleResultBiographyLose.dtor()
    BattleResultBiographyLose = nil 

end

return BattleResultBiographyLose