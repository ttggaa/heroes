--
-- Author: huangguofang
-- Date: 2016-10-24 15:41:03
--
local BattleResultTrainingLose = class("BattleResultTrainingLose", BasePopView)

function BattleResultTrainingLose:ctor(data)
    BattleResultTrainingLose.super.ctor(self, data)

    self._result = data.result
    self._callback = data.callback
    self._battleInfo = data.data

    self._trainingData = self._battleInfo.trainingData or {}

end

function BattleResultTrainingLose:onInit()

    self._touchPanel = self:getUI("touchPanel")
    self._touchPanel:setSwallowTouches(false)
    self._touchPanel:setEnabled(false)
    self:registerClickEvent(self._touchPanel, specialize(self.onQuit, self))
    -- 防止流程中报错无法关界面
    ScheduleMgr:delayCall(8000, self, function( )
        if tolua.isnull(self._touchPanel) then return end
        self._touchPanel:setEnabled(true)
    end)
    --关闭事件
    -- self._closeBtn = self:getUI("bg.closeBtn")
    -- self:registerClickEvent(self._closeBtn, specialize(self.onQuit, self))

    self._bg1 = self:getUI("bg.bg1")
    self._bg1:setContentSize(480,210)
    self._bg1:setOpacity(0)
    self._bg1:setCascadeOpacityEnabled(true)

    self._tips = self:getUI("tips")
    self._tips:setOpacity(0)

    for i=1,3 do
        local conBg = self:getUI("bg.bg1.condition" .. i )
        conBg:setScaleX(1.05)
        conBg:setPositionX(conBg:getPositionX()+8)
        conBg:setOpacity(150)
        local conTxt = self:getUI("bg.bg1.desTxt" .. i)
        conBg:setVisible(false)
        conTxt:setVisible(false)
        if self._trainingData["explain" .. i] then
            --菱形
            -- conTxt:setVisible(true)
            conBg:setVisible(true)
            local rtxStr = lang(self._trainingData["explain" .. i])
            local txt = RichTextFactory:create(rtxStr,374,50)
            txt:setVisible(false)
            txt:setName("explainTxt" .. i)
            txt:setPosition(conTxt:getPositionX()+185, conTxt:getPositionY())
            self._bg1:addChild(txt)
        end
    end

    self:animBegin()
end

function BattleResultTrainingLose:animBegin()
    
    local animPos = self:getUI("bg.animPos")
    --添加精灵动画
    spineMgr:createSpine("xinshouyindao", function (spine)
        -- spine:setVisible(false)
        spine.endCallback = function ()
            spine:setAnimation(0, "pingdan", true)
        end 
        local anim = "pingdan"
        spine:setAnimation(0, anim, true)
        spine:setPosition(animPos:getPositionX()-100,animPos:getPositionY())
        -- spine:setScale(scale)
        animPos:getParent():addChild(spine,2)

        local action = cc.MoveTo:create(0.1,cc.p(animPos:getPositionX() ,animPos:getPositionY()))
        spine:runAction(action)

    end)

    ScheduleMgr:delayCall(200, self, function ()         
        -- 动画恭喜通关
        for i=1,3 do
            local txt = self._bg1:getChildByFullName("explainTxt" .. i)
            txt:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function ( )
                txt:setVisible(true)
            end)))
        end
        local action = cc.Sequence:create(cc.ScaleTo:create(0.1,1.2),cc.ScaleTo:create(0.05,1))
        local spawn = cc.Spawn:create(action,cc.FadeIn:create(0.1))
        local seq = cc.Sequence:create(spawn,cc.CallFunc:create(function ()
            self._touchPanel:setEnabled(true)
        end))
        self._bg1:runAction(seq)
     end)

    self._tips:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.FadeIn:create(0.2)))

end

function BattleResultTrainingLose:onQuit()
    if self._callback then
        self._callback()
    end
end


-- function BattleResultTrainingLose:onCount()
--  self._viewMgr:showView("battle.BattleCountView",self._battleInfo,true)
-- end



function BattleResultTrainingLose.dtor()
    BattleResultTrainingLose = nil
end

return BattleResultTrainingLose