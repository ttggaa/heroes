--[[
    Filename:    AcSpringRedNoticeView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2018-01-27 13:42:21
    Description: File description
--]]

local AcSpringRedNoticeView = class("AcSpringRedNoticeView",BaseMvcs, ccui.Widget)

function AcSpringRedNoticeView:ctor()
	AcSpringRedNoticeView.super.ctor(self)

	self._viewMgr = ViewManager:getInstance()
	self._modelMgr = ModelManager:getInstance()
    self._sRedModel = self._modelMgr:getModel("SpringRedModel")

	self._isShow = false
	self:refreshUI()
end

function AcSpringRedNoticeView:refreshUI()
	if self._isShow == true then
		return 
	end

	local noticeData = self._sRedModel:getNotice()
	if noticeData == nil then 
		self._isShow = false
        if self:getParent().springNoticeLayer ~= nil then
        	self:getParent().springNoticeLayer = nil
        end
        self:removeFromParent(true)
		return
	end

	self._isShow = true

	if not self._textBg then
		self._textBg =  ccui.Layout:create()
		self._textBg:setAnchorPoint(0.5, 0.5)
		self._textBg:setBackGroundColorOpacity(0)
	    self._textBg:setBackGroundColorType(1)
	    self._textBg:setBackGroundColor(cc.c3b(0, 100, 0))
		self._textBg:setContentSize(480, 40)
		self._textBg:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 + 200)
		self:addChild(self._textBg)
	else
		self._textBg:stopAllActions()
		self._textBg:removeAllChildren()
	end

	local bgW, bgH = self._textBg:getContentSize().width, self._textBg:getContentSize().height

	local bgAnim = mcMgr:createViewMC("xinnianpaomadeng_xinnianpaomadeng", false, false)
	bgAnim:setPosition(bgW * 0.5, 3)
	self._textBg:addChild(bgAnim)

	local tName = "[color=0fd7ce,outlinecolor=3c1e0aff,fontsize=20]".. noticeData["name"] .. "[-]"
	local tWords = "[color=f7daa5,outlinecolor=3c1e0aff,fontsize=20]:".. lang(noticeData["wishId"]) .. "[-]"
	local richText = RichTextFactory:create(tName .. tWords, 500, 0)
    richText:setPixelNewline(true)
	richText:formatText()
	richText:setScaleX(0)
	self._textBg:addChild(richText)

	local x = richText:getRealSize().width / 2
    if richText:getRealSize().width < richText:getContentSize().width then 
        x = richText:getContentSize().width / 2
    end
    richText:setPosition(bgW * 0.5 - 175 + x, bgH * 0.5 - 7)

	richText:runAction(cc.Sequence:create(
		cc.ScaleTo:create(0.2, 1),
		cc.DelayTime:create(2.3),
		cc.CallFunc:create(function()
			self._isShow = false
			self:refreshUI()
			end)
		))
end

return AcSpringRedNoticeView