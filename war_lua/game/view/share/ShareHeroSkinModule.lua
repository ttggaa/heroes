--[[
    Filename:    ShareHeroSkinModule.lua
    Author:      <huangguofang@playcrab.com>
    Datetime:    2017-06-1 14:42:52
    Description: File description
--]]

local ShareBaseView = require("game.view.share.ShareBaseView")

function ShareBaseView:transferData(data)
   	self._skinData = data.skinData
end

function ShareBaseView:updateModuleView(data)
   
	local shareLayer = self:getShareLayer()
	local centerX, centerY = shareLayer:getContentSize().width * 0.5, shareLayer:getContentSize().height * 0.5

	local desBg = ccui.ImageView:create()
	desBg:loadTexture("heroSkin_shareSkin_nameBg.png",1)
	desBg:setPosition(centerX-300,centerY-90)
	shareLayer:addChild(desBg)

	local nameBg = ccui.ImageView:create()
	nameBg:loadTexture("heroSkin_titleImg_" .. self._skinData.id .. ".png",1)
	nameBg:setPosition(centerX-300,centerY-10)
	shareLayer:addChild(nameBg)

	-- des
	local rtxStr = lang(self._skinData.skinDescr)
	local rtx = RichTextFactory:create(rtxStr,325,100)
    rtx:formatText()
    rtx:setVerticalSpace(3)
    rtx:setName("rtx")
    rtx:setAnchorPoint(cc.p(0.5,0.5))
    rtx:setPosition(centerX-300,centerY-122)
	shareLayer:addChild(rtx)

	-- logo
	local logoImg = ccui.ImageView:create()
	logoImg:setScale(0.5)
	logoImg:setAnchorPoint(1,0)
	logoImg:loadTexture("asset/bg/logo.png")
	logoImg:setPosition(centerX+575,centerY-330)
	shareLayer:addChild(logoImg)

    if self._skinData.quality and self._skinData.quality ~= 1 then 
        local flagImg = ccui.ImageView:create()
        flagImg:setScale(0.6)
        flagImg:setAnchorPoint(1,0)
        flagImg:loadTexture("heroSkin_skinAttr_flag" .. self._skinData.quality .. ".png",1)
        flagImg:setPosition(centerX+420,centerY-300)
        shareLayer:addChild(flagImg,1)
    end

end

function ShareBaseView:onDestroy()
    if self._resName ~= nil then
        for i,v in ipairs(self._resName) do
            cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("asset/ui/"..v..".plist")
            cc.Director:getInstance():getTextureCache():removeTextureForKey("asset/ui/"..v..".png")
         end    

    end
    ShareBaseView.super.onDestroy(self)
end

function ShareBaseView:getShareBgName(inData)
    if inData ~= nil and inData.isAsyncRes and inData.isAsyncRes == true then
        self._resName = {"heroSkin","heroSkin1"} --,"heroSkin2"
        for i,v in ipairs(self._resName) do
            cc.SpriteFrameCache:getInstance():addSpriteFrames("asset/ui/"..v..".plist", "asset/ui/"..v..".png")
        end
    end

    local imgName = self._skinData.heroport or "b_Catherine" 
	local filename = "asset/uiother/hero/" .. imgName .. ".jpg"
	if not cc.FileUtils:getInstance():isFileExist(filename) then
		filename = "asset/uiother/hero/b_Catherine.jpg"
	end
    return filename
end

function ShareBaseView:getInfoPosition()
    return nil, nil
end

function ShareBaseView:getShareId()
    return 14
end
