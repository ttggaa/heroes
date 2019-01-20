--
-- Author: huangguofang
-- Date: 2017-06-28 20:58:50
--

local AcCelebrationView = class("AcCelebrationView",BasePopView)

function AcCelebrationView:ctor(data)
    AcCelebrationView.super.ctor(self)
    self._callback = data.callback
	self._currBtn = data.currIdx or 1

	self._userModel = self._modelMgr:getModel("UserModel")	
	self._celebrationModel = self._modelMgr:getModel("CelebrationModel")
end


function AcCelebrationView:getAsyncRes()
    return 
    {
        {"asset/ui/acCelebration.plist", "asset/ui/acCelebration.png"},
        {"asset/ui/acCelebration1.plist", "asset/ui/acCelebration1.png"},
    }
end

-- 第一次被加到父节点时候调用
function AcCelebrationView:onAdd()

end
-- 初始化UI后会调用, 有需要请覆盖
function AcCelebrationView:onInit()

	self._celeData = self._celebrationModel:getData() or {}
	self._celebrationLayer = {
		[1] = {key="collectionCele",	titleTxt = "集字狂欢",uiName = "activity.celebration.AcCelebrationCollectLayer"},
		[2] = {key="punctualityCele",	titleTxt = "整点狂欢",uiName = "activity.celebration.AcIntegralPointLayer"},
		[3] = {key="friendCele",		titleTxt = "好友狂欢",uiName = "activity.celebration.AcCelebrationFriendLayer"},
	}

	-- 注册关闭按钮
	self:registerClickEventByName("bg.closeBtn", function()
		if self._callback then
			self._callback()
		end
		
		self:doClose()
	end)

	local bg_img = self:getUI("bg.bg_img")
    bg_img:setZOrder(-1)
    bg_img:loadTexture("asset/bg/activity_bg_paper.png")  --bg_activityCarnival2    

    self._rightPanel = self:getUI("bg.rightPanel")

    self._btnArr = {}
  	self:addLeftBtn()

  	self:setListenReflashWithParam(true)
  	self:listenReflash("CelebrationModel", self.updateCeleData)
end

function AcCelebrationView:doClose(noAnim)	

    if OS_IS_WINDOWS then
    	UIUtils:reloadLuaFile("activity.celebration.AcCelebrationView")
    end
    self:close(noAnim)
end


function AcCelebrationView:addLeftBtn()
	local leftPanel = self:getUI("bg.leftPanel")
	local key
	local clickData
	for i=1,3 do
		local btn = self:getUI("bg.leftPanel.acBtn" .. i)
		local text = btn:getTitleRenderer()
        btn:setTitleColor(UIUtils.colorTable.ccUITabColor1)
        text:disableEffect()
		btn:setTitleText(self._celebrationLayer[i].titleTxt)
		btn:setTitleColor(cc.c4b(242,224,200,255))
		btn:setTitleFontSize(26)
		local lock = cc.Sprite:createWithSpriteFrameName("pokeImage_suo.png")
    	lock:setScale(0.8)
    	lock:setPosition(btn:getContentSize().width - lock:getContentSize().width*lock:getScale() + 5, btn:getContentSize().height/2)
    	btn:addChild(lock,1)
    	key = self._celebrationLayer[i] and self._celebrationLayer[i].key or ""
	    clickData = self._celeData[key]
    	lock:setVisible(not (clickData and clickData.open == 1))
    	local noticeDot = self:addNoticeDot(btn,btn:getContentSize().width-15,btn:getContentSize().height-15)
    	noticeDot:setVisible(false)
    	if self["buttonDotVisible" .. i] then
    		noticeDot:setVisible(self["buttonDotVisible" .. i](self))
    	end

    	btn.__lockImg = lock
		btn.__index = i
		self._btnArr[i] = btn

		registerClickEvent(btn,function(sender)
	    	-- +1 设置查看次日信息，可点击
	    	local key = self._celebrationLayer[sender.__index] and self._celebrationLayer[sender.__index].key or ""
	    	local clickData = self._celeData[key]
	    	if clickData and clickData.open == 1 then
	    		self._currBtn = sender.__index
	    		self:buttonChangeState(self._currBtn)
	    		self:changeLayerByIdx(self._currBtn)
	    	else
	    	   	self._viewMgr:showTip("未到开启时间，请明天再来哦~")	
	    	end   	
        end)
	end

	self:buttonChangeState(self._currBtn)
	self:changeLayerByIdx(self._currBtn)
end
function AcCelebrationView:updateLeftBtn()
	local key
	local clickData
	for i=1,3 do
		local btn = self:getUI("bg.leftPanel.acBtn" .. i)
    	local lock = btn.__lockImg
    	key = self._celebrationLayer[i] and self._celebrationLayer[i].key or ""
	    clickData = self._celeData[key]
    	lock:setVisible(not (clickData and clickData.open == 1))

    	local noticeDot = btn:getChildByName("noticeTip")
    	if self["buttonDotVisible" .. i] then
    		noticeDot:setVisible(self["buttonDotVisible" .. i](self))
    	end
	end
end


function AcCelebrationView:addNoticeDot(btn,x,y)
    local dot = btn:getChildByName("noticeTip")
    if dot then 
    	dot:removeFromParent()
    end
    local dot = ccui.ImageView:create()
    dot:loadTexture("globalImageUI_bag_keyihecheng.png", 1)
    dot:setPosition(x,y)--node:getContentSize().width,node:getContentSize().height))
    dot:setName("noticeTip")
    btn:addChild(dot)
    return dot
end

-- 集字红点
function AcCelebrationView:buttonDotVisible1()
	return self._celebrationModel:isCollectionNeedRed()
end
-- 整点红点
function AcCelebrationView:buttonDotVisible2()
	return self._celebrationModel:isIntPointNeedRed()
end
-- 好友红点
function AcCelebrationView:buttonDotVisible3()
	return self._celebrationModel:isFriendNeedRed()
end
function AcCelebrationView:buttonChangeState(btnNum)
	local buttonNum = btnNum
	if not btnNum then 
		buttonNum = 1
	end
	if buttonNum > 3 then return end

	for k,v in pairs(self._btnArr) do
		if k == tonumber(buttonNum) then
			if v then
				v:setEnabled(false)
				v:setBright(false)
				v:setTitleColor(cc.c4b(255,255,255,255))
			end
		else
			if v then
				v:setEnabled(true)
				v:setBright(true)
				v:setTitleColor(cc.c4b(130,86,40,255))
			end
		end
	end
end

-- 切换页签
function AcCelebrationView:changeLayerByIdx(idx)
	local index = idx
	if not index then
		index = self._currBtn or 1 
	end
	local layerName = self._celebrationLayer[idx] and self._celebrationLayer[idx].uiName or nil
	self._rightPanel:removeAllChildren()
	if not layerName then return end
	
	self._viewMgr:lock(-1)
	local key = self._celebrationLayer[self._currBtn] and self._celebrationLayer[self._currBtn].key or ""
	local clickData = self._celeData[key]
	-- dump(clickData,"clickData==>",5)
	self:createLayer(layerName, {data=clickData,container = self}, true, function (_layer)
        self._viewMgr:unlock()
        -- _layer:setPosition(10,10)
        self._currLayer = _layer
        self._rightPanel:addChild(_layer)
    end)

end

-- 被其他View盖住会调用, 有需要请覆盖
function AcCelebrationView:onHide()
    
end

function AcCelebrationView:reflashUI(data)
	
end

-- 更新庆典数据 & 刷新界面
function AcCelebrationView:updateCeleData(data)
	self._celeData = self._celebrationModel:getData() or {}
	-- 更新按钮状态
	self:updateLeftBtn()
	-- 刷新当前layer显示
	if self._currLayer and self._currLayer.reflashUI then
		self._currLayer:reflashUI(data)
	end
end

function AcCelebrationView.dtor()
	
end

return AcCelebrationView