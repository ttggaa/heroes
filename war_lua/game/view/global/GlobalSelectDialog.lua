--[[
    Filename:    GlobalSelectDialog.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-05-29 15:01:12
    Description: File description
--]]

local GlobalSelectDialog = class("GlobalSelectDialog", BasePopView)

function GlobalSelectDialog:ctor()
    GlobalSelectDialog.super.ctor(self)

end

function GlobalSelectDialog:onInit()
    self._descLabel = self:getUI("bg.descLabel")
    self._bg = self:getUI("bg")
    self._desBg = self:getUI("bg.desBg")
    self._descLabel:getVirtualRenderer():setMaxLineWidth(335)
    self._descLabel:getVirtualRenderer():setLineHeight(30)
    self._btn1 = self:getUI("bg.btn1")
    self._btn2 = self:getUI("bg.btn2")

    self:registerClickEvent(self._btn1, function ()
        if self._callback3 then self._callback3() end
        self:close(false,self._callback1)
    end)

    self:registerClickEvent(self._btn2, function ()
        if self._callback4 then self._callback4() end
        self:close(false,self._callback2)
        UIUtils:reloadLuaFile("global.GlobalSelectDialog")
    end)
    self._title = self:getUI("bg.title")   
    UIUtils:setTitleFormat(self._title, 6)

    self._titleTip = self:getUI("bg.titleTip")  
    UIUtils:setTitleFormat(self._titleTip, 6)
end

function GlobalSelectDialog:reflashUI(data)
    if type(data.desc) == "string" then
        if string.find(data.desc,"[-]") then
            self._descLabel:setString("")
            local rtx = DialogUtils.createRtxLabel( data.desc,{width = 375} )
            rtx:formatText()
            rtx:setPosition(cc.p(self._bg:getContentSize().width/2-3,self._bg:getContentSize().height/2+20))
            self._bg:addChild(rtx,10)
            UIUtils:alignRichText(rtx,{hAlign = "center"})
        else
            self._descLabel:setString(data.desc)
        end
            
    elseif type(data.desc) == "userdata" then
        self._descLabel:setString("")
        data.desc:setPosition(cc.p(self._bg:getContentSize().width/2,self._bg:getContentSize().height/2+20))
        self._bg:addChild(data.desc,99)
    end
    if not data.button1 or data.button1 == "" then data.button1 = "确定" end
    if not data.button2 or data.button2 == "" then data.button2 = "取消" end
    self._btn1:setTitleText(data.button1)
    self._btn2:setTitleText(data.button2)

    if data.titileTip then
        self._title:setVisible(false)
        self._titleTip:setVisible(true)
    else
        self._title:setVisible(true)
        self._titleTip:setVisible(false)
    end
    if not data.alignNum then
        if self._descLabel:getVirtualRenderer():getStringNumLines() > 1 then  
            self._descLabel:setTextHorizontalAlignment(3)
        else
            self._descLabel:setTextHorizontalAlignment(1)
        end
    else
        self._descLabel:setTextHorizontalAlignment(data.alignNum)
    end

    self._callback1 = data.callback1
    self._callback2 = data.callback2
    self._callback3 = data.callback3
    self._callback4 = data.callback4

    if data.addValue ~= nil then
        self:showAddValue(data.addValue)
    end

    if data.title then
        self._title:setString(data.title)
        self._titleTip:setString(data.title)
    end
end

-- 显示VIP、活动加成信息
function GlobalSelectDialog:showAddValue(tp)
    self._addPanel = self:getUI("bg.addPanel")
    local vipTxtImg = self._addPanel:getChildByFullName("vipTxtImg")
    local vipCoinIcon = self._addPanel:getChildByFullName("vipCoinIcon")
    vipCoinIcon:setCascadeOpacityEnabled(true)
    local vipAddLabel = self._addPanel:getChildByFullName("vipAddLabel")
    local activityTxtImg = self._addPanel:getChildByFullName("activityTxtImg")
    local activityCoinIcon = self._addPanel:getChildByFullName("activityCoinIcon")
    local activityAddLabel = self._addPanel:getChildByFullName("activityAddLabel")

    local abilityValue = 0 

    self._acModel = self._modelMgr:getModel("ActivityModel")

    if tp == "airen" then
        local vipLv = self._modelMgr:getModel("VipModel"):getLevel()
        local vipAddValue = tab:Vip(self._modelMgr:getModel("VipModel"):getLevel()).buyOccupation
        abilityValue = self._acModel:getAbilityEffect(self._acModel.PrivilegIDs.PrivilegID_9)

        if tonumber(vipAddValue) > 0 then
            vipTxtImg:setVisible(true)
            vipCoinIcon:setVisible(true)
            vipAddLabel:setVisible(true)

            vipAddLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
--            vipAddLabel:enable2Color(1, cc.c4b(255, 232, 125, 255))
--            vipAddLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            vipAddLabel:setString("+" .. vipAddValue .. "%")

            if abilityValue <= 0 then
                vipTxtImg:setPositionX(vipTxtImg:getPositionX() + 96)
                vipCoinIcon:setPositionX(vipCoinIcon:getPositionX() + 96)
                vipAddLabel:setPositionX(vipAddLabel:getPositionX() + 96)
            end
        end

        if abilityValue > 0 then
            activityTxtImg:setVisible(true)
            activityCoinIcon:setVisible(true)
            activityAddLabel:setVisible(true)

            activityAddLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
--            activityAddLabel:enable2Color(1, cc.c4b(255, 232, 125, 255))
--            activityAddLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            activityAddLabel:setString("+" .. abilityValue * 100 .. "%")

            if vipAddValue <= 0 then
                activityTxtImg:setPositionX(activityTxtImg:getPositionX() - 80)
                activityCoinIcon:setPositionX(activityCoinIcon:getPositionX() - 80)
                activityAddLabel:setPositionX(activityAddLabel:getPositionX() - 80)
            end
        end

    elseif tp == "zombie" then

        abilityValue = self._acModel:getAbilityEffect(self._acModel.PrivilegIDs.PrivilegID_10)
        if abilityValue > 0 then
            activityTxtImg:setVisible(true)
            activityCoinIcon:setVisible(true)
            activityCoinIcon:loadTexture("globalImageUI_texp.png", 1)

            activityAddLabel:setVisible(true)
            activityAddLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
--            activityAddLabel:enable2Color(1, cc.c4b(255, 232, 125, 255))
--            activityAddLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            activityAddLabel:setString("+" .. abilityValue * 100 .. "%")

            activityTxtImg:setPositionX(activityTxtImg:getPositionX() - 80)
            activityCoinIcon:setPositionX(activityCoinIcon:getPositionX() - 80)
            activityAddLabel:setPositionX(activityAddLabel:getPositionX() - 80)
        end
    end
end
return GlobalSelectDialog