--[[
    Filename:    ActivitySignInDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-05-12 23:46:28
    Description: File description
--]]


local ActivitySignInDialog = class("ActivitySignInDialog", BasePopView)

function ActivitySignInDialog:ctor()
    ActivitySignInDialog.super.ctor(self)
end


function ActivitySignInDialog:onInit()

end

function ActivitySignInDialog:reflashUI(data)
    local showType = data.showType
    local sumBuy = data.sumBuy
    self._callback = data.callback

    local titleTip = self:getUI("bg.titleTip")
    titleTip:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    
    -- UIUtils:setTitleFormat(titleTip, 2)

    local des1 = self:getUI("bg.des1")
    local des2 = self:getUI("bg.des2")
    local img1 = self:getUI("bg.img1")

    local desValue = self:getUI("bg.desValue")
    local buqianstr
    local callback
    if showType == 1 then
        buqianstr = lang("buqian1")
        callback = function()
            local viewMgr = ViewManager:getInstance()
            local userlevel = self._modelMgr:getModel("UserModel"):getData().lvl
            if userlevel < 12 then
                viewMgr:showTip("每日任务12级开启")
            else
                viewMgr:showView("task.TaskView", {viewType = 2})
            end
        end
        des1:setVisible(false)
        des2:setVisible(false)
        img1:setVisible(false)
        desValue:setVisible(false)
    else
        buqianstr = lang("buqian2")
        callback = function()
            local viewMgr = ViewManager:getInstance()
            viewMgr:showView("vip.VipView", {viewType = 0})
        end
        des1:setVisible(true)
        des2:setVisible(false)
        img1:setVisible(true)
        desValue:setVisible(true)
        desValue:setString(sumBuy)
        -- desValue:setPositionX(des1:getPositionX()+des1:getContentSize().width)
        -- des2:setPositionX(desValue:getPositionX()+desValue:getContentSize().width)
    end

    local descLabel = self:getUI("bg.descLabel")
    local richText = RichTextFactory:create(buqianstr, descLabel:getContentSize().width, 0)
    richText:formatText()
    local height  = descLabel:getContentSize().height
    if height < richText:getRealSize().height then
        height = richText:getRealSize().height
    end
    richText:setPosition(descLabel:getContentSize().width/2, descLabel:getContentSize().height - richText:getRealSize().height/2)
    descLabel:addChild(richText)


    local btn1 = self:getUI("bg.btn1")
    self:registerClickEvent(btn1, function()
        if self._callback then
            self._callback()
        end
        if callback then
            callback()
        end
        self:close()
    end)

    local btn2 = self:getUI("bg.btn2")
    self:registerClickEvent(btn2, function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("activity.ActivitySignInDialog")
        end
        self:close()
    end)
end

return ActivitySignInDialog