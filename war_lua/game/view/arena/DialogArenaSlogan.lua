--[[
    Filename:    DialogArenaSlogan.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-10-28 20:37:38
    Description: File description
--]]

local DialogArenaSlogan = class("DialogArenaSlogan",BasePopView)
function DialogArenaSlogan:ctor(param)
	param = param or {}
    self.super.ctor(self)
    self._callback = param.callback
end

-- 第一次被加到父节点时候调用
function DialogArenaSlogan:onAdd()

end
-- 初始化UI后会调用, 有需要请覆盖
function DialogArenaSlogan:onInit()
	self:registerClickEventByName("bg.closeBtn", function( )
		self:close()
	end)
	self._sloganLabel = self:getUI("bg.sloganLabel")
	self._sloganLabel:setPlaceHolderColor(cc.c4b(255,251,215,255))
	-- self._sloganLabel:setPlace
	-- local arenaD = self._modelMgr:getModel("ArenaModel"):getArena()
	local userData = self._modelMgr:getModel("UserModel"):getData()
	if userData.msg == nil or userData.msg == "" then
		self._sloganLabel:setPlaceHolder(lang("TIPS_ARENA_03"))
		if self._sloganLabel:getString() == "" then
        	self._sloganLabel:setColor(cc.c3b(255, 255, 255))
		    self._sloganLabel:setPlaceHolderColor(cc.c4b(135,128,128,255))
        end
	else
		self._sloganLabel:setString(userData.msg or "")
	end

	local  sloganTitle = self:getUI("bg.title")    
    UIUtils:setTitleFormat(sloganTitle, 6)

    local  slogantitleTip = self:getUI("bg.titleTip")   
    UIUtils:setTitleFormat(slogantitleTip, 1)

	local des1 = self:getUI("bg.des1")
	des1:setString(lang("TIPS_ARENA_02"))
	-- local des2 = self:getUI("bg.des2")
	-- des2:setString(lang("TIPS_ARENA_03"))
	self._sloganLabel:addEventListener(function(sender, eventType)
        	self._sloganLabel:setColor(cc.c3b(70, 40, 0))
        	print("eventType",eventType)
	       --  if eventType == 0 then
	       --      -- event.name = "ATTACH_WITH_IME"
	       --      self._sloganLabel:setPlaceHolder("")
	       --  elseif eventType == 1 then
	       --     --  event.name = "DETACH_WITH_IME"
	       --      if self._sloganLabel:getString() == "" then
	       --      	self._sloganLabel:setColor(cc.c3b(255, 255, 255))
				    -- self._sloganLabel:setPlaceHolderColor(cc.c4b(135,128,128,255))
	       --      	self._sloganLabel:setPlaceHolder("请输入宣言！")
	       --      end
	       --  elseif eventType == 2 then
	       --      -- event.name = "INSERT_TEXT"
	       --  elseif eventType == 3 then
	       --      -- event.name = "DELETE_BACKWARD"
	       --  end
            if self._sloganLabel:getString() == "" then
            	self._sloganLabel:setColor(cc.c3b(255, 255, 255))
			    self._sloganLabel:setPlaceHolderColor(cc.c4b(135,128,128,255))
            	self._sloganLabel:setPlaceHolder("请输入宣言！")
            end
	    end)
	-- 确定按钮
	self:registerClickEventByName("bg.btn1", function( )
		self._sloganLabel:setColor(cc.c3b(70, 40, 0))
		local slogan = self._sloganLabel:getString()
		if slogan == "" then
			self._viewMgr:showTip("请输入宣言！")
		elseif utf8.len(slogan) < 2 or utf8.len(slogan) > 20 then
			self._viewMgr:showTip("宣言长度需2~20个字！")
		else
			self:sendSvaeDeclarationMsg(slogan)
		end
	end)
	self:registerClickEventByName("bg.btn2", function( )
		self._sloganLabel:setColor(cc.c3b(70, 40, 0))
		self:close()
	end)	
end

-- 接收自定义消息
function DialogArenaSlogan:reflashUI(data)

end

function DialogArenaSlogan:sendSvaeDeclarationMsg( slogan )
	local msg = slogan--string.urlencode(slogan)
	local param = {msg = msg}
    self._serverMgr:sendMsg("UserServer", "svaeDeclaration", param, true, {}, function(result)
    	self._viewMgr:showTip("设置成功！")
        self._modelMgr:getModel("UserModel"):setSlogan(self._sloganLabel:getString())
        if self._callback then
			self._callback()
		end
		self:close()
    end)
end

return DialogArenaSlogan