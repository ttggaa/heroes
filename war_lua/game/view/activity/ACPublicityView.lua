--
-- Author: huangguofang
-- Date: 2016-05-23 18:19:15
-- 活动宣传界面

local ACPublicityView = class("ACPublicityView",BasePopView)
function ACPublicityView:ctor()
    self.super.ctor(self)

end
function ACPublicityView:getAsyncRes()
    return 
    {

    }
end

function ACPublicityView:onDestroy()
	ACPublicityView.super.onDestroy(self)
	if self._isUseImg ~= "" then
		-- print("=removeImag =======================")
		cc.Director:getInstance():getTextureCache():removeTextureForKey(self._isUseImg)
	end
	-- cc.Director:getInstance():getTextureCache():removeTextureForKey("asset/uiother/activity/activity_mujingling.png")
end

-- 第一次被加到父节点时候调用
function ACPublicityView:onAdd()

end
-- 初始化UI后会调用, 有需要请覆盖
-- panelType 
-- 0     	木精灵 跳转到登录奖励
-- 1 		罗伊德的宣传图 （全屏，无跳转）
-- 2 		弹木精灵的宣传图
-- 3  		弹格鲁的宣传图     
function ACPublicityView:onInit()
	-- print("=========活动宣传界面=============")
	self._isUseImg = ""
	self._bg1 = self:getUI("bg")
	self._rolePanel = self:getUI("bg.rolePanel")
	self._getBtn = self:getUI("bg.rolePanel.getBtn")
	self._getBtn:setTitleFontName(UIUtils.ttfName)
    self._getBtn:setColor(cc.c4b(255, 250, 220, 255))
    self._getBtn:getTitleRenderer():enableOutline(cc.c4b(178, 103, 3, 255), 3) --(cc.c4b(101, 33, 0, 255), 2)
    self._getBtn:setTitleFontSize(36)
    self._getBtn:setTitleText("关闭")
	self:registerClickEvent(self._getBtn, function ()
        -- self:goSevenDaysView()
        self:close()
     end)	
	self._closeLoginBtn = self:getUI("bg.closeLoginBtn")
	self:registerClickEventByName("bg.closeLoginBtn", function() self:close() end)
	--全屏宣传图
	self._bg2 = self:getUI("bg2")
	self._bg2:setScale(0)

	self._image = ccui.ImageView:create()

	-- self._image:loadTexture("activity_close_btn.png",1)

	self._bg2:addChild(self._image)

	-- self._bg2:setScale(1.11)
	-- self._bg2:setBackGroundImage("asset/uiother/activity/activity_full_1.jpg")
	-- self._bg2:loadTexture("asset/uiother/activity/activity_full_1.jpg")
	self._closeBtn = self:getUI("closeBtn")
	self:registerClickEventByName("closeBtn", function() 
		self:runSeqEndAction(self._bg2)
	end)
	
end

function ACPublicityView:goSevenDaysView()
	-- -- body
	local isOpen = true
	local toBeOpen = true
	isOpen,toBeOpen = SystemUtils["enableSevenDay"]()
	if isOpen then			
        self._viewMgr:showDialog("activity.ActivitySevenDaysView", {})			
		self:close()
	end
	-- -- print("===========------------------")
end
-- function ACPublicityView:getMaskOpacity()
--     return 0
-- end
function ACPublicityView:reflashUI(data)
	-- -- body
	if not data or not data.panelType then
		data = {}
		data.panelType = 0
	end
	if 0 == data.panelType then
		self._isUseImg = "asset/uiother/activity/activity_mujingling.png"
		self._rolePanel:setBackGroundImage(self._isUseImg)
		self._bg1:setVisible(true)
		self._closeLoginBtn:setTouchEnabled(true)
		self._getBtn:setTouchEnabled(true)
		self._bg2:setVisible(false)
		self._closeBtn:setVisible(false)
		self._closeBtn:setTouchEnabled(false)
	else
		self._bg1:setVisible(false)
		self._closeLoginBtn:setTouchEnabled(false)
		self._getBtn:setTouchEnabled(false)
		self._bg2:setVisible(true)
		self._closeBtn:setVisible(false)
		self._closeBtn:setTouchEnabled(false)
		self._bg2:setScale(0)
		self._bg2:setOpacity(0)
		self._bg2:setCascadeOpacityEnabled(true)
		self:runSeqOpenAction(self._bg2)
		--替换不同的宣传图		
	 --    self._isUseImg = "asset/uiother/activity/activity_full_"..data.panelType..".jpg"	    
		-- self._image:loadTexture(self._isUseImg)
		-- 屏幕分辨率
		if data.panelType == 1 then 
		    local actMc = mcMgr:createViewMC("luoyide_activity_luoyide", false, false)
		    actMc:setCascadeOpacityEnabled(true,true)
		    actMc:setPosition(self._bg2:getContentSize().width * 0.5, self._bg2:getContentSize().height * 0.5)
		    actMc:addCallbackAtFrame(80,function( )
                actMc:play()
                actMc:gotoAndStop(79)
            end)
		    self._bg2:addChild(actMc)
		elseif data.panelType == 2 then 
		    local actMc = mcMgr:createViewMC("mujingling_activity_mujingling", false, false)
		    actMc:setCascadeOpacityEnabled(true,true)
		    actMc:setPosition(self._bg2:getContentSize().width * 0.5, self._bg2:getContentSize().height * 0.5)
		    actMc:addCallbackAtFrame(80,function( )
                actMc:play()
                actMc:gotoAndStop(79)
            end)
		    self._bg2:addChild(actMc)
		elseif data.panelType == 3 then 
		    local actMc = mcMgr:createViewMC("gelu_activity_gelufla", false, false)
		    actMc:setCascadeOpacityEnabled(true,true)
		    actMc:setPosition(self._bg2:getContentSize().width * 0.5, self._bg2:getContentSize().height * 0.5)
		    actMc:addCallbackAtFrame(80,function( )
                actMc:play()
                actMc:gotoAndStop(79)
            end)
		    self._bg2:addChild(actMc)
		end

	    local screenW = MAX_SCREEN_WIDTH
	    local screenH = MAX_SCREEN_HEIGHT
	    local scaleW = screenW / self._image:getContentSize().width
	    local scaleH = screenH / 640
	    local scale = 1
	    if scaleW > scaleH then
	    	scale = scaleW
	    else
	    	scale = scaleH
	    end
	   	-- print("====scaleH,scaleW,scale===========",scaleH,scaleW,scale)
	    self._image:setScale(scale)
		-- print("=========================",self._bg2:getContentSize().width,self._bg2:getContentSize().height)
		self._image:setPosition(self._bg2:getContentSize().width/2, self._bg2:getContentSize().height/2)
		
	end
end

function ACPublicityView:runSeqOpenAction(node)
	local seqAction = cc.Sequence:create(cc.Spawn:create(cc.FadeIn:create(0.2),cc.ScaleTo:create(0.2, 1.05)),
		cc.ScaleTo:create(0.15, 1),CCCallFunc:create(function ( )			
			self._closeBtn:setVisible(true)
			self._closeBtn:setTouchEnabled(true)
		end))
	if node then
		node:runAction(seqAction)
	end
end
function ACPublicityView:runSeqEndAction(node)
	node:setOpacity(255)
	self._closeBtn:setOpacity(255)
	self._closeBtn:runAction(cc.FadeOut:create(0.2))
	local seqAction = cc.Sequence:create(cc.ScaleTo:create(0.15, 1.05),
		cc.Spawn:create(cc.FadeOut:create(0.1),cc.ScaleTo:create(0.1, 0.3)),
		cc.CallFunc:create(function ( )
			self:close()
			UIUtils:reloadLuaFile("activity.ACPublicityView")
		end))
	if node then
		node:runAction(seqAction)
	end
end

function ACPublicityView:onTop()

end

return ACPublicityView
