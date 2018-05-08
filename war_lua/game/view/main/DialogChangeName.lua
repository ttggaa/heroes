--[[
    Filename:    DialogChangeName.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2016-01-25 12:03:17
    Description: File description
--]]

local DialogChangeName = class("DialogChangeName",BasePopView)

function DialogChangeName:ctor()
    self.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
end

-- 初始化UI后会调用, 有需要请覆盖
function DialogChangeName:onInit()
	self:registerClickEventByName("bg.btn1", function ()
		local name = self._nameLabel:getString()
        local renameTime = self._modelMgr:getModel("UserModel"):getData().renameTime
        local gem = self._modelMgr:getModel("UserModel"):getData().gem
        if gem < 100 and ( renameTime and renameTime ~= 0) then 
            DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
                local viewMgr = ViewManager:getInstance()
                viewMgr:showView("vip.VipView", {viewType = 0})
            end})
            return 
        end
        if name and utf8.len(name) < 2 then
            self._viewMgr:showTip(lang("INFORMATION_NAME_ERROR_01"))
            return 
        end
		if  name == nil or name == "" or name == self._userModel:getData().name then
			self._viewMgr:showTip("请重新设置名称")
		else
			local param = {name = name}
	        self._serverMgr:sendMsg("UserServer","setName", param, true, {}, function(result) 
	        	self._viewMgr:showTip("设置成功！")
	        	self:close()
		    end)
		end
    end)
    self:registerClickEventByName("bg.btn2", function ()
        self:close()
        UIUtils:reloadLuaFile("main.DialogChangeName")
    end)
    self._randName = self:getUI("bg.randName")
    self._randNum = 0
    self:registerClickEventByName("bg.randName", function ()
        self._randNum = self._randNum + 1
        local num = self._randNum%3 + 1
        self._randName:loadTexture("saizi_mainview"..num..".png",1)
        local name = ItemUtils.randUserName()
        self._nameLabel:setColor(cc.c3b(70, 40, 0))
        self._nameLabel:setString(name)
    end)
    self._nameLabel = self:getUI("bg.nameLabel")

    self._title = self:getUI("bg.title")
    UIUtils:setTitleFormat(self._title, 6)

    self._nameLabel:setColor(cc.c3b(70, 40, 0))

    -- self._nameLabel:setPlaceHolder("请输入名称")
    -- self._nameLabel:setColor(cc.c3b(255, 255, 255))
    -- self._nameLabel:setColor(cc.c3b(70, 40, 0))
    -- self._nameLabel:setPlaceHolderColor(cc.c4b(60,60,60,255))
    self._icon2_0 = self:getUI("bg.icon2_0")
    self._gemLab_0 = self:getUI("bg.gemLab_0")
    self._des1 = self:getUI("bg.des1")

    if self._nameLabel:getString() == "" then
        self._nameLabel:setColor(cc.c3b(255, 255, 255))
        self._nameLabel:setPlaceHolderColor(cc.c4b(135,128,128,255))
        self._nameLabel:setPlaceHolder("请输入名称!")
    end

    self._nameLabel:addEventListener(function(sender, eventType)
        self._nameLabel:setColor(cc.c3b(70, 40, 0))
        if self._nameLabel:getString() == "" then
            self._nameLabel:setColor(cc.c3b(255, 255, 255))
            self._nameLabel:setPlaceHolderColor(cc.c4b(135,128,128,255))
            self._nameLabel:setPlaceHolder("请输入名称!")
        end
    end)
end

-- 接收自定义消息
function DialogChangeName:reflashUI(data)
	local curName = self._userModel:getData().name
    self._nameLabel:setString(curName)
    self._nameLabel:setColor(cc.c3b(70, 40, 0))
    local renameTime = self._modelMgr:getModel("UserModel"):getData().renameTime
    if not renameTime or renameTime == 0 then
        self._des1:setString("本次免费")
        self._icon2_0:setVisible(false)
        self._gemLab_0:setVisible(false)
    else
        self._des1:setString("改名花费")
        self._des1:setVisible(false)
        self._icon2_0:setVisible(true)
        self._gemLab_0:setVisible(true)
    end 
end

return DialogChangeName	