--[[
    Filename:    GlobalResTipDialog.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-11-25 10:47:18
    Description: File description
--]]

local GlobalResTipDialog = class("GlobalResTipDialog",BasePopView)
function GlobalResTipDialog:ctor()
    GlobalResTipDialog.super.ctor(self)

end

-- 初始化UI后会调用, 有需要请覆盖
function GlobalResTipDialog:onInit()
	local isClose = false
	self:registerClickEventByName("bg.closeBtn", function( )
		if isClose == false then
			isClose = true
			self:close()
		end
	end)

	self:registerClickEventByName("bg.okBtn", function( )
		if isClose == false then
			isClose = true
			local vipLevel = self._modelMgr:getModel("VipModel"):getData().level or 0
			if not self._fullOfVip then
				self._viewMgr:showView("vip.VipView", {viewType = 1,index=vipLevel+1})
			end
			self:close(true)
		end
	end)
	self._des1 = self:getUI("bg.des2")
	self._des1:setString("今日次数已经用完")
	self._okBtn = self:getUI("bg.okBtn")
	self._okBtn:setBright(true)
    self._okBtn:setTitleText("查看VIP")

	self._title = self:getUI("bg.title_bg.title")
    UIUtils:setTitleFormat(self._title, 6)
end


-- 接收自定义消息
function GlobalResTipDialog:reflashUI(data)
	if data.des1 then
		self._des1:setString(data.des1)
	end
	if self._des1:getVirtualRenderer():getStringNumLines() > 1 then  
        self._des1:setTextHorizontalAlignment(3)
    end
	local vip = self._modelMgr:getModel("VipModel"):getData().level
	print("vip >= table.nums(tab.vip)",vip , table.nums(tab.vip))
	if vip >= table.nums(tab.vip)-1 or data.btnTitle then
		self._okBtn:setTitleText(data.btnTitle or "确定")
		self._fullOfVip = true
		return
	end
	if true then return end
	if data.des1 and data.des2 then
		self._des1:setString(data.des1..data.des2)
	end

	if self._des1:getVirtualRenderer():getStringNumLines() > 1 then  
        self._des1:setTextHorizontalAlignment(3)
    end

end

return GlobalResTipDialog