--[[
    Filename:    CityBattleBattleEnterDialog.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-07-08 18:08:56
    Description: File description
--]]


local CityBattleBattleEnterDialog = class("CityBattleBattleEnterDialog", BasePopView)

function CityBattleBattleEnterDialog:ctor()
    CityBattleBattleEnterDialog.super.ctor(self)
end


function CityBattleBattleEnterDialog:onInit()
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
        
        local checkBox = self:getUI("bg.checkBox1")
        if self._callback2 ~= nil then 
            self._callback2(checkBox:isSelected())
        end
        UIUtils:reloadLuaFile("citybattle.CityBattleBattleEnterDialog")
        self:close(false)
    end)
    self._title = self:getUI("bg.title")   
    UIUtils:setTitleFormat(self._title, 6)

end

function CityBattleBattleEnterDialog:reflashUI(data)
    local checkBox = self:getUI("bg.checkBox1")
    checkBox:addEventListener(function (_, state)
        print("state==============", state)
        if state == 0 then
            self._btn1:setTouchEnabled(false)
            self._btn1:setSaturation(-150)
        else
            self._btn1:setTouchEnabled(true)
            self._btn1:setSaturation(0)           
        end
    end)
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
    -- self._btn2:setTitleText(data.button2)

    if data.titileTip then
        self._title:setVisible(false)
    else
        self._title:setVisible(true)
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
end

return CityBattleBattleEnterDialog