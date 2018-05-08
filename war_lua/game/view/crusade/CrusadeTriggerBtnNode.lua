--[[
    Filename:    CrusadeTriggerBtnNode.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-06-12 13:39:58
    Description: File description
--]]

-- local CrusadeTriggerBtnNode = class("IntanceGuideTalkLayer",BaseMvcs, ccui.Widget)

local CrusadeTriggerBtnNode = class("CrusadeTriggerBtnNode", BasePopView)

function CrusadeTriggerBtnNode:ctor(param)
    CrusadeTriggerBtnNode.super.ctor(self)
    self._data = param
    -- self:onInit()
end

function CrusadeTriggerBtnNode:getAsyncRes()
    return  
    {
        {"asset/ui/crusade2.plist", "asset/ui/crusade2.png"}
    }
end

function CrusadeTriggerBtnNode:onInit()
    local data = self._data
    self._callBack = data.callBack
    -- SystemUtils.saveAccountLocalData("crusadeTriggerSelect", false)

    local tip1, tip2, dialogTip1, dialogTip2 
    if data.triType == 1 then
        tip1,tip2 = lang("CRUSADE_CHOSE_TRIG_1"), lang("CRUSADE_CHOSE_TRIG_2")
        dialogTip1, dialogTip2 = lang("CRUSADE_CHOSE_TRIG_5"), lang("CRUSADE_CHOSE_TRIG_6")
    elseif data.triType == 2 then
        tip1,tip2 = lang("CRUSADE_CHOSE_TRIG_3"), lang("CRUSADE_CHOSE_TRIG_4")
        dialogTip1, dialogTip2 = lang("CRUSADE_CHOSE_TRIG_7"), lang("CRUSADE_CHOSE_TRIG_8")
    end

    --压黑背景
	local bgLayer = ccui.Layout:create()
    bgLayer:setBackGroundColorOpacity(50)
    bgLayer:setBackGroundColorType(1)
    bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    bgLayer:setTouchEnabled(true)
    bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self:addChild(bgLayer, -1)

    --------------天使  
    self._btnUp = ccui.ImageView:create("crusadeTrigger_spLeft.png", 1)  --img
    self._btnUp:setAnchorPoint(cc.p(0,1))
    self._btnUp:setPosition(cc.p(-305, MAX_SCREEN_HEIGHT))  
    self:addChild(self._btnUp, 1)
    self._btnUp:setVisible(false)

    self._btnUp1 = ccui.ImageView:create("crusadeTrigger_spLeft.png", 1)  --1 
    self._btnUp1:setAnchorPoint(cc.p(0,1))
    self._btnUp1:setOpacity(100)
    self._btnUp1:setPosition(cc.p(-65, MAX_SCREEN_HEIGHT))  
    self:addChild(self._btnUp1, 1)
    self._btnUp1:setVisible(false)

    self._btnUp2 = ccui.ImageView:create("crusadeTrigger_spLeft.png", 1)  --2 
    self._btnUp2:setAnchorPoint(cc.p(0,1))
    self._btnUp2:setPosition(cc.p(-65, MAX_SCREEN_HEIGHT)) 
    self._btnUp2:setOpacity(30) 
    self:addChild(self._btnUp2, 1)
    self._btnUp2:setVisible(false)

    self._upLab = RichTextFactory:create(tip1, 350, 50)                 --文字
    self._upLab:formatText()
    self._upLab:setAnchorPoint(cc.p(0,0.5))
    self._upLab:setPosition(cc.p(165, 70))
    self._btnUp:addChild(self._upLab)

    self._btnUp3 = ccui.Layout:create()                                 --点击区域
    self._btnUp3:setBackGroundColorOpacity(0)
    self._btnUp3:setBackGroundColorType(1)
    self._btnUp3:setBackGroundColor(cc.c3b(255, 255, 0 ))
    self._btnUp3:setContentSize(390, 140)
    self._btnUp3:setPosition(280, 0)
    self._btnUp:addChild(self._btnUp3, -1)

    ---------------恶魔
    self._btnDown = ccui.ImageView:create("crusadeTrigger_spRight.png", 1)   --295
    self._btnDown:setAnchorPoint(cc.p(1,0))
    self._btnDown:setPosition(cc.p(MAX_SCREEN_WIDTH + 295, 90))
    self:addChild(self._btnDown)
    self._btnDown:setVisible(false)

    self._btnDown1 = ccui.ImageView:create("crusadeTrigger_spRight.png", 1)   --1
    self._btnDown1:setAnchorPoint(cc.p(1,0))
    self._btnDown1:setPosition(cc.p(MAX_SCREEN_WIDTH + 65, 90))
    self._btnDown1:setOpacity(100)
    self:addChild(self._btnDown1)
    self._btnDown1:setVisible(false)

    self._btnDown2 = ccui.ImageView:create("crusadeTrigger_spRight.png", 1)   --2
    self._btnDown2:setAnchorPoint(cc.p(1,0))
    self._btnDown2:setPosition(cc.p(MAX_SCREEN_WIDTH + 65, 90))
    self._btnDown2:setOpacity(30)
    self:addChild(self._btnDown2)
    self._btnDown2:setVisible(false)
 
    self._downLab = RichTextFactory:create(tip2, 350, 50)
    self._downLab:formatText()
    self._downLab:setAnchorPoint(cc.p(0,0.5))
    self._downLab:setPosition(cc.p(-90, 95))
    self._btnDown:addChild(self._downLab)

    self._btnDown3 = ccui.Layout:create()
    self._btnDown3:setBackGroundColorOpacity(0)
    self._btnDown3:setBackGroundColorType(1)
    self._btnDown3:setBackGroundColor(cc.c3b(0, 255, 0))
    self._btnDown3:setContentSize(390, 140)
    self._btnDown3:setPosition(80, 20)
    self._btnDown:addChild(self._btnDown3, -1)
  
    registerClickEvent(self._btnUp3, function()
        self._viewMgr:showDialog("global.GlobalSelectDialog",
            {desc = dialogTip1,
            button1 = "确定" ,
            button2 = "取消", 
            callback1 = function()
                self._btnUp3:setTouchEnabled(false)
                self._btnDown3:setTouchEnabled(false)
                --anim
                local tianshiAnim = mcMgr:createViewMC("tianshi_intancetriggerjueze", false, false)
                tianshiAnim:setPosition(self._btnUp:getContentSize().width/2, self._btnUp:getContentSize().height/2)
                self._btnUp:addChild(tianshiAnim)
                tianshiAnim:addCallbackAtFrame(15, function()  
                    tianshiAnim:setVisible(false)
                    self:selectFinish(1)
                    end)

                --右下降
                local move = cc.MoveTo:create(0.2, cc.p(MAX_SCREEN_WIDTH, -self._btnDown:getContentSize().height))
                local fade = cc.FadeOut:create(0.2)
                self._btnDown:runAction(cc.Spawn:create(move, fade))
                
            end,
            callback2 = function()
            end}, true)
    end)

    registerClickEvent(self._btnDown3, function()  
        self._viewMgr:showDialog("global.GlobalSelectDialog",
            {desc = dialogTip2,
            button1 = "确定" ,
            button2 = "取消", 
            callback1 = function()
                self._btnUp3:setTouchEnabled(false)
                self._btnDown3:setTouchEnabled(false)
                --anim
                local emoAnim = mcMgr:createViewMC("emo_intancetriggerjueze", false, false)
                emoAnim:setPosition(self._btnDown:getContentSize().width/2, self._btnDown:getContentSize().height/2)
                self._btnDown:addChild(emoAnim)
                emoAnim:addCallbackAtFrame(15, function()
                    emoAnim:setVisible(false)
                    self:selectFinish(0)
                    end)

                --左上升
                local move = cc.MoveTo:create(0.2, cc.p(0, MAX_SCREEN_HEIGHT + self._btnDown:getContentSize().height))
                local fade = cc.FadeOut:create(0.2)
                self._btnUp:runAction(cc.Spawn:create(move, fade))
            end,
            callback2 = function()
            end}, true)    
    end)

    self:enterAnim()
end

function CrusadeTriggerBtnNode:enterAnim()
    local selectAnim = cc.CallFunc:create(function()
        local selectAnim = mcMgr:createViewMC("jueze_intancetriggerjueze", false, true)
        selectAnim:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2)
        self:addChild(selectAnim)
        end)

    local enter = cc.CallFunc:create(function()
        self._btnUp:setVisible(true)
        self._btnDown:setVisible(true)

        local _leftMove1 = cc.MoveTo:create(0.13, cc.p(130, MAX_SCREEN_HEIGHT))
        local _leftMove2 = cc.MoveTo:create(0.1, cc.p(-65, MAX_SCREEN_HEIGHT))
        self._btnUp:runAction(cc.Sequence:create(_leftMove1, _leftMove2))

        local _rightMove1 = cc.MoveTo:create(0.13, cc.p(MAX_SCREEN_WIDTH - 130, self._btnDown:getPositionY()))
        local _rightMove2 = cc.MoveTo:create(0.1, cc.p(MAX_SCREEN_WIDTH + 65, self._btnDown:getPositionY()))
        self._btnDown:runAction(cc.Sequence:create(_rightMove1, _rightMove2))
        end)

    self:runAction(cc.Sequence:create(selectAnim, cc.DelayTime:create(1.7), enter))
end

function CrusadeTriggerBtnNode:selectFinish(inType)
    local selectType1 = cc.CallFunc:create(function()
        local run1 = cc.CallFunc:create(function()
            local move = cc.MoveTo:create(0.2, cc.p(MAX_SCREEN_WIDTH, self._btnUp:getPositionY()))
            local fade = cc.FadeOut:create(0.2)
            self._btnUp:setPosition(0, MAX_SCREEN_HEIGHT)
            self._btnUp:runAction(cc.Spawn:create(move, fade))
            end)
        local run2 = cc.CallFunc:create(function()
            local move1 = cc.MoveTo:create(0.2, cc.p(MAX_SCREEN_WIDTH, self._btnUp:getPositionY()))
            local fade1 = cc.FadeOut:create(0.2)
            self._btnUp1:setVisible(true)
            self._btnUp1:runAction(cc.Spawn:create(move1, fade1))
            end)
        local run3 = cc.CallFunc:create(function()
            local move2 = cc.MoveTo:create(0.2, cc.p(MAX_SCREEN_WIDTH, self._btnUp:getPositionY()))
            local fade2 = cc.FadeOut:create(0.2)
            self._btnUp2:setVisible(true)
            self._btnUp2:runAction(cc.Spawn:create(move2, fade2))
            end)

        self:runAction(cc.Sequence:create(run1, cc.DelayTime:create(0.1), run2, cc.DelayTime:create(0.1), run3))
        end)

    local selectType2 = cc.CallFunc:create(function()
        local run1 = cc.CallFunc:create(function()
            local move = cc.MoveTo:create(0.2, cc.p(-self._btnDown:getContentSize().width, self._btnDown:getPositionY()))
            local fade = cc.FadeOut:create(0.2)
            self._btnDown:runAction(cc.Spawn:create(move, fade))
            end)
        local run2 = cc.CallFunc:create(function()
            local move1 = cc.MoveTo:create(0.2, cc.p(-self._btnDown:getContentSize().width, self._btnDown:getPositionY()))
            local fade1 = cc.FadeOut:create(0.2)
            self._btnDown1:setVisible(true)
            self._btnDown1:runAction(cc.Spawn:create(move1, fade1))
            end)
        local run3 = cc.CallFunc:create(function()
            local move2 = cc.MoveTo:create(0.2, cc.p(-self._btnDown:getContentSize().width, self._btnDown:getPositionY()))
            local fade2 = cc.FadeOut:create(0.2)
            self._btnDown2:setVisible(true)
            self._btnDown2:runAction(cc.Spawn:create(move2, fade2))
            end)

        self:runAction(cc.Sequence:create(run1, cc.DelayTime:create(0.1), run2, cc.DelayTime:create(0.1), run3))
        end)

    local leaveCallBack = cc.CallFunc:create(function()
        -- self:close()
        -- UIUtils:reloadLuaFile("crusade.CrusadeTriggerBtnNode")
        if inType == 1 then
            self._serverMgr:sendMsg("CrusadeServer", "enterTriggerCrusade", {type = 1}, true, {}, 
                function (result)
                    if self._callBack then
                        self._callBack(result, true)
                        -- SystemUtils.saveAccountLocalData("crusadeTriggerSelect", true)
                    end
                    if self.close then
                        self:close()
                    end
                end,
                function(errorCode, errorMsg)
                    if errorCode and self.close then
                        self:close()
                    end
                end)
        else
            self._serverMgr:sendMsg("CrusadeServer", "enterTriggerCrusade", {type = 0}, true, {}, 
                function (result)
                    if self._callBack then
                        self._callBack(result, false)
                        -- SystemUtils.saveAccountLocalData("crusadeTriggerSelect", true)
                    end
                    if self.close then
                        self:close()
                    end
                end,
                function(errorCode, errorMsg)
                    if errorCode and self.close then
                        self:close()
                    end
                end)
        end
    end)

    if inType == 1 then  --up
        self:runAction(cc.Sequence:create(selectType1, cc.DelayTime:create(0.5), leaveCallBack))
    else
        self:runAction(cc.Sequence:create(selectType2, cc.DelayTime:create(0.5), leaveCallBack))
    end
end

return CrusadeTriggerBtnNode