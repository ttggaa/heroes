--[[
    Filename:    DirectChargeSureDialog.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-04-14 17:22:54
    Description: File description
--]]


local DirectChargeSureDialog = class("DirectChargeSureDialog",BasePopView)


function DirectChargeSureDialog:ctor(param)
    DirectChargeSureDialog.super.ctor(self)
    self._tag = 0
    self._callBack = param.callback
    self._localTxt = param.localTxt or "DIRECT_NO_WARING"
    self._contentTxt = param.contentTxt or "zhigouremind1"
end

function DirectChargeSureDialog:selectBtn()
    if self._tag == 0 then
        self._tag = 1
        self._select:setVisible(true)
    else
        self._tag = 0
        self._select:setVisible(false)
    end
end

function DirectChargeSureDialog:onInit()

    local noWarning = self:getUI("bg.noWarning")
    self._select = noWarning:getChildByFullName("select") 
    self._select:setVisible(false)

    self:registerClickEventByName("bg.noWarning", function ()
        self:selectBtn()
    end)

    self:registerClickEventByName("bg.sure", function ()
         SystemUtils.saveAccountLocalData(self._localTxt, self._tag)
         self:close()
         if self._callBack then
            self._callBack()
         end
    end)

    self:registerClickEventByName("bg.give_up", function ()
        self:close()
    end)
    local content = self:getUI("bg.content")
    -- content:setString("直购金额会增加相应的VIP经验，但无法激活任何充值类活动。是否继续购买？")
    content:setString(lang(self._contentTxt))
    content:setPositionY(content:getPositionY()-30)

  
end

return DirectChargeSureDialog