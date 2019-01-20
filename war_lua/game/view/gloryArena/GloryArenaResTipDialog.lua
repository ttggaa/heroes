--[[
    Filename:    GloryArenaResTipDialog.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-11-25 10:47:18
    Description: File description
--]]

local GloryArenaResTipDialog = class("GloryArenaResTipDialog", BasePopView)
function GloryArenaResTipDialog:ctor(params)
    GloryArenaResTipDialog.super.ctor(self)
    self._callback = params.callback
end

-- 初始化UI后会调用, 有需要请覆盖
function GloryArenaResTipDialog:onInit()
	self:registerClickEventByName("bg.closeBtn", function( )
		if isClose == false then
			isClose = true
			self:close()
		end
	end)
    local bg = self:getUI("bg")
    self:getUI("bg.closeBtn"):setVisible(false)
	self:registerClickEventByName("bg.okBtn", function( )
        self:getUI("bg"):runAction(cc.Sequence:create(
            cc.DelayTime:create(0.5),
            cc.ScaleTo:create(0.05, 1.1),
            cc.ScaleTo:create(0.09, 0.6), cc.CallFunc:create(function () bg:setVisible(false) end), cc.DelayTime:create(0.05), 
            cc.CallFunc:create(function ()
                if self._callback then
                    self._callback()
                end
        end)))
--		self:close(false, function()
--            if self._callback then
--                self._callback()
--            end
--            UIUtils:reloadLuaFile("gloryArena.GloryArenaResTipDialog")
--        end)
	end)
	self._des1 = self:getUI("bg.des2")
	self._des1:setString(lang("honorArena_tip_21"))
	self._okBtn = self:getUI("bg.okBtn")
--	self._okBtn:setBright(true)
    self._okBtn:setTitleText("确定")

	self._title = self:getUI("bg.title_bg.title")
    UIUtils:setTitleFormat(self._title, 6)
end


-- 接收自定义消息
function GloryArenaResTipDialog:reflashUI(data)
--	if data.des1 then
--		self._des1:setString(data.des1)
--	end
--	if self._des1:getVirtualRenderer():getStringNumLines() > 1 then  
--        self._des1:setTextHorizontalAlignment(3)
--    end
--	local vip = self._modelMgr:getModel("VipModel"):getData().level
--	print("vip >= table.nums(tab.vip)",vip , table.nums(tab.vip))
--	if vip >= table.nums(tab.vip)-1 or data.btnTitle then
--		self._okBtn:setTitleText(data.btnTitle or "确定")
--		self._fullOfVip = true
--		return
--	end
--	if true then return end
--	if data.des1 and data.des2 then
--		self._des1:setString(data.des1..data.des2)
--	end

--	if self._des1:getVirtualRenderer():getStringNumLines() > 1 then  
--        self._des1:setTextHorizontalAlignment(3)
--    end

end

return GloryArenaResTipDialog