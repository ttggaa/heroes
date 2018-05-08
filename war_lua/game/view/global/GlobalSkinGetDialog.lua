--
-- Author: huangguofang
-- Date: 2017-05-17 14:43:39
--

local GlobalSkinGetDialog = class("GlobalSkinGetDialog",BasePopView)
function GlobalSkinGetDialog:ctor(param)
    self.super.ctor(self)
    self._skinId = param.skinID
end

-- function GlobalSkinGetDialog:getAsyncRes()
--     return 
--     {
--         {"asset/ui/heroSkin.plist", "asset/ui/heroSkin.png"},
--     }
-- end

-- 初始化UI后会调用, 有需要请覆盖
function GlobalSkinGetDialog:onInit()
	self._bg = self:getUI("bg")
	local closePanel = self:getUI("closePanel")
    closePanel:setTouchEnabled(false)	

	self._bgImg = self:getUI("bg.bgImg")
    self._name = self:getUI("bg.nameBg.nameTxt")
    self._name:setFontName(UIUtils.ttfName)
    self._name:setFontSize(20)
    self._name:setPositionX(self._name:getPositionX() - 2)
    self._name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._name:ignoreContentAdaptWithSize(true)
    self._name:setTextAreaSize(cc.size(24,500))
    self._name:getVirtualRenderer():setLineHeight(24)

    self._titleTxt = self:getUI("bg.titleTxt")
    self._titleTxt1 = self:getUI("bg.titleTxt1")
    self._buttomBg = self:getUI("buttomBg.buttomBg")
    self._titleTxt:setOpacity(0)
    self._titleTxt1:setOpacity(0)
    self._titleTxt1:setCascadeOpacityEnabled(true)
    self._buttomBg:setOpacity(0)
    self._buttomBg:setCascadeOpacityEnabled(true,true)
    self._titleTxt:setPositionX(self._titleTxt:getPositionX()-100)

    self._flagImg = self:getUI("flagImg")

    -- 皮肤分享按钮
    self._shareNode = require("game.view.share.GlobalShareBtnNode").new({mType = "ShareHeroSkinModule",curType = 1})
    self._shareNode:setPosition(100, 100)
    self._shareNode:setCascadeOpacityEnabled(true, true)
    self:addChild(self._shareNode, 100)
    self._shareNode:setOpacity(0)

end


-- 接收自定义消息
function GlobalSkinGetDialog:reflashUI(data)
	if not self._skinId then return end
	-- 皮肤信息
	local skinData = tab:HeroSkin(tonumber(self._skinId)) or {}
	local imgName = skinData.heroport or "b_Catherine"
    if imgName then
    	local filename = "asset/uiother/hero/" .. imgName .. ".jpg"
		if cc.FileUtils:getInstance():isFileExist(filename) then
			self._bgImg:loadTexture(filename)
		else
			print("===========have no image==============")
		end
    end

    if ADOPT_IPHONEX then
        self._bgImg:setAnchorPoint(0.5,1)
        self._bgImg:setScale(MAX_SCREEN_WIDTH/self._bgImg:getContentSize().width + 0.1)
        self._bgImg:setPositionY(MAX_SCREEN_HEIGHT)
    else
        self._bgImg:setAnchorPoint(0.5,0.5)
        self._bgImg:setScale(1.11)
    end 
    local nameStr = lang(skinData.skinName)
    if string.find(nameStr,"·") then
        nameStr = string.gsub(nameStr,"·"," ·")
    end
    self._name:setString(nameStr)

    self:getUI("buttomBg"):setOpacity(0)
    local buttom = self:getUI("buttomBg.buttomBg.buttom")
    local posX = 10
    if skinData.skinFeatures then
        for i=1,4 do
            if skinData.skinFeatures[i] then
                --点
                local pointImg = ccui.ImageView:create()
                pointImg:loadTexture("heroSkin_getSkin_point.png",1)
                pointImg:setAnchorPoint(cc.p(0,0.5))
                pointImg:setPosition(posX,buttom:getContentSize().height*0.5 - 3)
                -- pointImg:setVisible(false)
                buttom:addChild(pointImg,5) 
                posX = posX + pointImg:getContentSize().width + 2

                local nameTxt = ccui.Text:create()
                nameTxt:setFontSize(20)
                nameTxt:setFontName(UIUtils.ttfName)
                nameTxt:setString(lang(skinData.skinFeatures[i]))
                nameTxt:setColor(UIUtils.colorTable.ccUIBasePromptColor)
                nameTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
                nameTxt:setAnchorPoint(cc.p(0,0.5))
                nameTxt:setPosition(posX ,buttom:getContentSize().height*0.5 - 3)
                buttom:addChild(nameTxt,3)
                posX = posX + nameTxt:getContentSize().width + 20
            end
        end
    end
    buttom:setPositionX(buttom:getPositionX() + (buttom:getContentSize().width - posX) * 0.5)

    -- 属性标志
    self._flagImg:setVisible(false)
    if skinData.quality and skinData.quality ~= 1 then 
        self._flagImg:setVisible(true)
        self._flagImg:loadTexture("heroSkin_skinAttr_flag" .. skinData.quality .. ".png",1)
    end

    self._shareNode:registerClick(function()
        return {moduleName = "ShareHeroSkinModule",skinData = skinData,isAsyncRes = true, isHideBtn = true}
    end)
    self:playSkinAnim()
end

function GlobalSkinGetDialog:playSkinAnim( ) 

    self._buttomBg:setPositionY(self._buttomBg:getPositionY() - 50)
    self._bg = self:getUI("bg")
    local closePanel = self:getUI("closePanel")
    local titleTxt1 = self._titleTxt1:clone()
    titleTxt1:setOpacity(125)
    titleTxt1:setScale(1.1)
    titleTxt1:setPosition(self._titleTxt1:getContentSize().width*0.5, self._titleTxt1:getContentSize().height*0.5)
    self._titleTxt1:addChild(titleTxt1,5)

    self._titleTxt1:setScale(3)
    self._titleTxt:setOpacity(0)

    local closePanel = self:getUI("closePanel")
    local action1 = cc.Sequence:create(cc.DelayTime:create(0.1),
        cc.Spawn:create(cc.FadeIn:create(0.3), cc.MoveBy:create(0.3, cc.p(100,0))) )

    local action2 = cc.Sequence:create(cc.DelayTime:create(0.4), 
        cc.CallFunc:create(function ( )
            titleTxt1:setOpacity(100)
        end),
        cc.Spawn:create(cc.FadeIn:create(0.1), cc.ScaleTo:create(0.3, 1)),
        cc.CallFunc:create(function( ... )
            titleTxt1:removeFromParent()
        end))

    local action3 = cc.Sequence:create(cc.DelayTime:create(0.8),
     cc.Spawn:create(cc.FadeIn:create(0.2), cc.MoveTo:create(0.2, cc.p(480,24))) ,
     cc.CallFunc:create(function ( )
        self:registerClickEvent(closePanel, function ( )        
            self:close(true)
            UIUtils:reloadLuaFile("global.GlobalSkinGetDialog")
        end)
    end))

    self._shareNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.8),cc.FadeIn:create(0.2)))

    self._titleTxt:runAction(action1)
    self._titleTxt1:runAction(action2)
    self._buttomBg:runAction(action3)
end

return GlobalSkinGetDialog
