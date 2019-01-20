--[[
    Filename:    CrossGodWarShowTuDialog.lua
    Author:      <lannan@playcrab.com>
    Datetime:    2017-05-12 21:40:51
    Description: File description
--]]


local CrossGodWarShowTuDialog = class("CrossGodWarShowTuDialog",BasePopView)

local maxPage = 4
	
function CrossGodWarShowTuDialog:ctor(param)
	CrossGodWarShowTuDialog.super.ctor(self)
	self._curIndex = 1
	if not param then
		param = {}
	end
	self._callback = param.callback
end

-- 初始化UI后会调用, 有需要请覆盖
function CrossGodWarShowTuDialog:onInit()
	self:registerClickEventByName("bg.layer.closeBtn", function ()
		if self._callback then
			self._callback()
		end
		self:close()
		if OS_IS_WINDOWS then
			package.loaded["game.view.godwar.CrossGodWarShowTuDialog"] = nil
		end
	end)
	self._layer = self:getUI("bg.layer")

	self._titleLabel = self:getUI("bg.layer.titleLabel")
	self._titleLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	self._titleLabel:setFontName(UIUtils.ttfName_Title)

	self._desImg = self:getUI("bg.layer.imgDes")

	self._modelMgr:getModel("GodWarModel"):setShowGuide()

	self:registerClickEventByName("bg.layer.leftBtn", function ()
		self:changePage("left")
	end)

	self:registerClickEventByName("bg.layer.rightBtn", function ()
		self:changePage("right")
	end)

	local space = 24
	local startPosX = 460-space*(maxPage-1)/2

	self._pointList = {}
	for i = 1 , maxPage do
		local pointBg = cc.Sprite:createWithSpriteFrameName("globaImageUI_pagePointGray.png")
		pointBg:setPosition(startPosX + (i-1)*space, 30)
		self._layer:addChild(pointBg)
		table.insert(self._pointList, pointBg)
	end

	self:updateUI(self._curIndex)
end

function CrossGodWarShowTuDialog:changePage(tp)
	if tp == "left" then
		self._curIndex = self._curIndex - 1
		self._curIndex = self._curIndex == 0 and maxPage or self._curIndex
	elseif tp == "right" then
		self._curIndex = self._curIndex + 1
		self._curIndex = self._curIndex == maxPage+1 and 1 or self._curIndex
	end

	self:updateUI(self._curIndex)
end

function CrossGodWarShowTuDialog:updateUI(index)
	if self._curPoint == nil then
		self._curPoint = cc.Sprite:createWithSpriteFrameName("globaImageUI_pagePointRed.png")
		self._layer:addChild(self._curPoint)
	end
	self._curPoint:setPosition(self._pointList[index]:getPosition())

	self._titleLabel:setString(lang("CROSSFIGHT_TITLE" .. index))

	if self._desRich ~= nil then
		self._desRich:removeFromParent(true)
		self._desRich = nil
	end
	self._desRich = RichTextFactory:create(lang("CROSSFIGHT_TIPS" .. index), 820, 30)
	self._desRich:formatText()
	self._desRich:enablePrinter(true)
	self._desRich:setPosition(473, 57)
	self._layer:addChild(self._desRich)
	UIUtils:alignRichText(self._desRich,{hAlign = "center"})
	local showImg = {
		[1] = "crossGodWarHelpImage1.png",
		[2] = "crossGodWarHelpImage2.png",
		[3] = "crossGodWarHelpImage3.png",
		[4] = "crossGodWarHelpImage4.png",
	}
	self._desImg:loadTexture(showImg[index], 1)
end

return CrossGodWarShowTuDialog