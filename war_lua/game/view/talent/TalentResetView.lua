--[[
    Filename:    TalentResetView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-12-25 14:25:14
    Description: 魔法行会重置界面
--]]

local TalentResetView = class("TalentResetView", BasePopView)

function TalentResetView:ctor(param)
	self.super.ctor(self)
	self._callback1 = param.callback1
    self._callback2 = param.callback2
end

function TalentResetView:onInit()
    local desNode = self:getUI("bg.desNode")
    local richText = RichTextFactory:create(lang("magicResetTip_1"), 370 , 0)
    richText:formatText()
    richText:setPosition(richText:getContentSize().width * 0.5, desNode:getContentSize().height * 0.5)
    desNode:addChild(richText)

    local cost1Num = tab.setting["G_TALENT_RESET_CONSUME"].value
    local cost1 = self:getUI("bg.rwd1.num")
    cost1:setString(cost1Num)

    local cost2Num = tab.setting["G_TALENT_RESET_CONSUME_2"].value
    local cost2 = self:getUI("bg.rwd2.num")
    cost2:setString(cost2Num)

    self:registerClickEventByName("bg.closeBtn", function()
    	UIUtils:reloadLuaFile("talent.TalentResetView")
    	self:close()
        UIUtils:reloadLuaFile("talent.TalentResetView")
    	end) 

    self:registerClickEventByName("bg.allBtn", function()
    	if self._callback1 then
    		self._callback1()
    	end
    	self:close()
    	UIUtils:reloadLuaFile("talent.TalentResetView")
    	end)

    self:registerClickEventByName("bg.oneBtn", function()
    	if self._callback2 then
    		self._callback2()
    	end
    	self:close()
    	UIUtils:reloadLuaFile("talent.TalentResetView")
    	end)

end

return TalentResetView