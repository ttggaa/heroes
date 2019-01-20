--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-11-30 16:20:19
--
local TreasureShopPreView = class("TreasureShopPreView",BasePopView)
function TreasureShopPreView:ctor(param)
    self.super.ctor(self)
    self.imgs = param and param.imgs
end

-- 初始化UI后会调用, 有需要请覆盖
function TreasureShopPreView:onInit()
	self._infoBoard = self:getUI("bg.infoBoard")
	self._infoBoard:loadTexture("asset/bg/bg_treasureshop_pre.jpg")
	self._title = self:getUI("bg.title")
	self._title:setString(lang("DRAWTREASURETE_TIPS"))
	self._titleDes = self:getUI("bg.titleDes")
	self._titleDes:setColor(cc.c3b(255,255,255))
	self._titleDes:enable2Color(1,cc.c4b(239,214,77,255))
	self:registerClickEventByName("closePanel",function() 
		self:close()
	end)
	self._treasure1 = self:getUI("bg.treasure1")
    self._treasure2 = self:getUI("bg.treasure2")
    if not self.imgs then return end
	self._treasure1:loadTexture((self.imgs[2] or "globalImageUI6_meiyoutu.png") ,1)
    self._treasure1:setScale(0.9)
    self._treasure1:setPosition(420,280)
	self._treasure2:loadTexture((self.imgs[1] or "globalImageUI6_meiyoutu.png"),1)
    self._treasure2:setScale(0.85)
    self._treasure2:setPosition(730,280)
end

-- 第一次进入调用, 有需要请覆盖
function TreasureShopPreView:onShow()

end

-- 接收自定义消息
function TreasureShopPreView:reflashUI(data)
	
end

return TreasureShopPreView