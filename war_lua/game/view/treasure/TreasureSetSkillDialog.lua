--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-08-01 11:35:21
--
local TreasureSetSkillDialog = class("TreasureSetSkillDialog",BasePopView)
function TreasureSetSkillDialog:ctor(param)
    self.super.ctor(self)
    self._callback = param and param.callback
    self._title    = param and param.title
    self._formId   = param and param.formId or 1
    self._tfModel  = self._modelMgr:getModel("TformationModel")
end

-- 初始化UI后会调用, 有需要请覆盖
function TreasureSetSkillDialog:onInit()
	self._nameLabel = self:getUI("bg.nameLabel")
	local curFormData = self._tfModel:getData()[self._formId]
	local curName = curFormData and curFormData.name 
	if not curName or curName == "" then
		curName = ("宝物编组" .. self._formId)
	end
	self._nameLabel:setString(curName)
    self._nameLabel:addEventListener(function(sender, eventType)
        self._nameLabel:setColor(cc.c3b(70, 40, 0))
        if self._nameLabel:getString() == "" then
            self._nameLabel:setColor(cc.c3b(255, 255, 255))
            self._nameLabel:setPlaceHolderColor(cc.c4b(135,128,128,255))
            self._nameLabel:setPlaceHolder("请输入宝物编组名称")
        end
    end)
	self:registerClickEventByName("bg.btn1",function() 
		self:close()
		UIUtils:reloadLuaFile("treasure.TreasureSetSkillDialog")
		local name = self:getUI("bg.nameLabel"):getString()
		if self._callback and name and name ~= "" then
			self._callback(name)
		end
	end)

	self:registerClickEventByName("bg.btn2",function() 
		self:close()
		UIUtils:reloadLuaFile("treasure.TreasureSetSkillDialog")
	end)

	if self._title then
		local title = self:getUI("bg.title")
		UIUtils:setTitleFormat(title,3)
		title:setString(self._title)
	end
end

-- 接收自定义消息
function TreasureSetSkillDialog:reflashUI(data)

end

return TreasureSetSkillDialog