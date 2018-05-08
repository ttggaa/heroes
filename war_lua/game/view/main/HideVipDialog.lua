--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-07-04 17:05:57
--
local HideVipDialog = class("HideVipDialog",BasePopView)
function HideVipDialog:ctor()
    self.super.ctor(self)

end

-- 初始化UI后会调用, 有需要请覆盖
function HideVipDialog:onInit()
	self:registerClickEventByName("bg.closeBtn", function ()
		self:sendHideMsg()
        self:close()
        UIUtils:reloadLuaFile("main.HideVipDialog")
    end)
	local userData = self._modelMgr:getModel("UserModel"):getData()
	local extra = userData.extra
	local hideVip = {}
	if extra and extra.hideVip then
		hideVip = extra.hideVip or {}
	end 
	self._hideVip = {}
    for i=1,4 do
    	local checkBox = self:getUI("bg.checkBg.checkBox" .. i)
	    checkBox:setSelected(hideVip[tostring(i)] == 1)
	    self._hideVip[tostring(i)] = hideVip[tostring(i)] == 1 and 1 or 0
	    checkBox:addEventListener(function (_, state)
	    	state = state == 0 and 1 or 0
	        self._hideVip[tostring(i)] = state
	    end)
    end
end

-- 接收自定义消息
function HideVipDialog:reflashUI(data)

end

function HideVipDialog:sendHideMsg( )
	local uM = self._modelMgr:getModel("UserModel")
	self._serverMgr:sendMsg("VipServer", "hiddenVip", {hType=self._hideVip}, true, {}, function(success,result)
		dump(result,"hide vip infol.......")
		dump(uM:getData().extra)
    end)
end

return HideVipDialog