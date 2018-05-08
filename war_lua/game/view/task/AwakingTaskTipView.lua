--[[
    Filename:    AwakingTaskTipView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2017-08-29 16:51:52
    Description: File description
--]]

local AwakingTaskTipView = class("AwakingTaskTipView", BaseView)

function AwakingTaskTipView:ctor()
    AwakingTaskTipView.super.ctor(self)
    self._awakingModel = self._modelMgr:getModel("AwakingModel")
end

function AwakingTaskTipView:onInit()
    self._image_bg = self:getUI("bg.layer.image_bg")
    self._contentSizeWidth = self._image_bg:getContentSize().width / 2.0
    self._label_des = self:getUI("bg.layer.image_bg.label_des")
    self._label_value = self:getUI("bg.layer.image_bg.label_value")
    self:refreshUI()
end

function AwakingTaskTipView:refreshUI()
    self._image_bg:setPositionX(-self._contentSizeWidth)
    local awakingData = self._awakingModel:getAwakingTaskData()
    if not awakingData then return end
    local awakingTaskData = tab:AwakingTask(awakingData.taskId)
    if not awakingTaskData then return end
    local isReach = self._awakingModel:isCurrentAwakingTaskReach()
    self._label_des:setString(lang(awakingTaskData["taskDone"]))
    self._label_value:setPositionX(self._label_des:getPositionX() + self._label_des:getContentSize().width + 5)
    self._label_value:setColor(isReach and cc.c3b(39, 247, 58) or cc.c3b(251, 47, 44))
    if awakingTaskData.type and 1 == awakingTaskData.type then
        local value = isReach and 1 or 0
        self._label_value:setString(value .. "/1")
    else
        local value = awakingData["value"]
        local condition = awakingTaskData["condition"][1]
        if value > condition then
            value = condition
        end
        self._label_value:setString(value .. "/" .. condition)
    end
    self:setVisible(true)
    self._image_bg:runAction(cc.Sequence:create(
        cc.MoveTo:create(0.3, cc.p(self._contentSizeWidth, self._image_bg:getPositionY())),
        cc.DelayTime:create(1.0), 
        cc.MoveTo:create(0.3, cc.p(-self._contentSizeWidth, self._image_bg:getPositionY())),
        cc.CallFunc:create(function()
            self:setVisible(false)
    end)))
end

return AwakingTaskTipView