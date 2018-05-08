--[[
    Filename:    IntanceWideRewardView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-12-10 17:08:14
    Description: File description
--]]

local IntanceWideRewardView = class("IntanceWideRewardView", BasePopView)

function IntanceWideRewardView:ctor()
    IntanceWideRewardView.super.ctor(self)
end


function IntanceWideRewardView:onInit()
    local closeFunction = function ()
        self:close()
        UIUtils:reloadLuaFile("intance.IntanceWideRewardView")
        if self._callback ~= nil then
            self._callback()
        end
    end

    self._bgLayer = ccui.Layout:create()
    self._bgLayer:setBackGroundColorOpacity(0)
    self._bgLayer:setBackGroundColorType(1)
    self._bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    self._bgLayer:setTouchEnabled(true)
    self._bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._widget:addChild(self._bgLayer, 0)
    -- registerClickEvent(self._bgLayer, function()
    --     -- if self._offsetTime == 1 then 
    --     --     self._offsetTime = 4 
    --     --     self._bgLayer:setTouchEnabled(false)
    --     --     return
    --     -- end
    --     -- closeFunction()

    -- end)


    local dropOffsetY = 0
    registerTouchEvent(self._bgLayer, 
    function(sender, x, y)
        dropOffsetY = y
    end,
    nil,
    function(sender, x, y)
        if math.abs(y - dropOffsetY) > 5 then 
            return
        end
        if self._quickShowFin == 2 then 
            local bgPanel = self:getUI("bg.bg1")
            local pt = bgPanel:convertToWorldSpace(cc.p(0, 0))
            if x >= pt.x and x <= pt.x + bgPanel:getContentSize().width and y >= pt.y and y < pt.y + bgPanel:getContentSize().height then 
                return
            end
            closeFunction()
            return
        end

        if self._quickShowFin == 1 then 
            return
        end
        self._quickShowFin = 1
        for k,v in pairs(self._reward) do
            local rewardBg  = self._scrollView:getContainer():getChildByName("REWARD_BG_" .. k)
            rewardBg:setScale(1)
            rewardBg:setVisible(true)
            rewardBg:setOpacity(255)
            rewardBg:stopAllActions()
                -- if self._tipItem ~= nil and IntanceConst.WIDE_REWARD_NEED_ITEM_NUM ~= nil 
                -- and IntanceConst.WIDE_REWARD_NEED_ITEM_NUM > 0 then
                -- -- self._rewardNodeSize.height = (#self._reward + 1) * 144 + 10   --wangyan
                --     rewardBg:setPosition(cc.p(self._scrollView:getContentSize().width/2, (#self._reward - k + 2) * 144 + 10))
                -- else
                --     rewardBg:setPosition(cc.p(self._scrollView:getContentSize().width/2, (#self._reward - k + 1) * 144 + 10))
                -- end
                rewardBg:setPosition(cc.p(self._scrollView:getContentSize().width/2, rewardBg.goPosY))

        end
        local rewardBg = self._scrollView:getContainer():getChildByName("REWARD_BG_100")
        if rewardBg ~= nil  then
            rewardBg:setScale(1)
            rewardBg:setVisible(true)
            rewardBg:setOpacity(255)
            rewardBg:stopAllActions()
            self:showFinish(#self._reward + 1)
            -- rewardBg:setPosition(cc.p(self._scrollView:getContentSize().width/2, (1) * 144 + 10))
        else
            self:showFinish(#self._reward)
        end        
        -- if self._offsetTime == 1 then 
        --     self._offsetTime = 8 
        --     self._bgLayer:setTouchEnabled(false)
        --     return
        -- end
        -- closeFunction()
    end)

    self._offsetTime = 8 

    local closeBtn = self:getUI("bg.closeBtn")
    local againBtn = self:getUI("bg.bg1.againBtn")
    local enterBtn = self:getUI("bg.bg1.enterBtn")

    local titleLab = self:getUI("bg.bg1.titleBg.title")
    UIUtils:setTitleFormat(titleLab, 1)

    self:registerClickEvent(closeBtn, closeFunction)
    self:registerClickEvent(enterBtn, closeFunction)

end


function IntanceWideRewardView:reflashUI(inData)
    self._quickShowFin = 0

    if self._finishMc ~= nil then 
        self._finishMc:stop()
        self._finishMc:removeFromParent()
        self._finishMc = nil
    end
    local againBtn = self:getUI("bg.bg1.againBtn")
    local enterBtn = self:getUI("bg.bg1.enterBtn")
    againBtn:setVisible(false)
    enterBtn:setVisible(false)

    self._callback = nil 
    self._offsetTime = 8 
    self._rewardType = inData.type
    if self._scrollView ~= nil then 
        self._scrollView:removeFromParent(true)
        self._scrollView = nil
    end
    local scrollBg = self:getUI("bg.bg1.scrollBg")
    

    self._scrollView = cc.ScrollView:create()
    -- self._scrollView:setContainer(self._containerLayer)
    -- self._containerLayer = self._scrollView:getContainer()
    self._scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._scrollView:setViewSize(cc.size(scrollBg:getContentSize().width,scrollBg:getContentSize().height))
    self._scrollView:setBounceable(true)

    self._scrollView:setContentSize(cc.size(scrollBg:getContentSize().width,scrollBg:getContentSize().height))
    
    scrollBg:addChild(self._scrollView, 2)
    

	-- self._scrollView:removeAllChildren()
    self._callback = inData.callback
	self._reward = inData.reward
    self._autoClose = inData.autoClose

    self._rewardNodeSize = cc.size(0,0)

	local closeBtn = self:getUI("bg.closeBtn")
    closeBtn:setVisible(false)

    local againBtn = self:getUI("bg.bg1.againBtn")
    againBtn:setVisible(false)

    local enterBtn = self:getUI("bg.bg1.enterBtn")
    enterBtn:setVisible(false)
    enterBtn:setTitleText("确定")
    
    if inData.againCallback ~= nil then
	    self:registerClickEvent(againBtn, function()
            -- audioMgr:playSound("Sweep")
	    	inData.againCallback()
	    end)
	end

    if self._reward == nil then 
        return
    end
 
    local subBg1 = self:getUI("bg.bg1")
    subBg1:setVisible(true)

    self._rewardNodeSize.width = self._scrollView:getContentSize().width
    
    self._tipItem = nil
    for k,v in pairs(self._reward) do
        local complex = {}
        if nil ~= v.items then 
            for k,e in pairs(v.items) do 
                e.type = 1
                table.insert(complex, e)
                if IntanceConst.WIDE_REWARD_ITEM_ID ~= nil and 
                	tonumber(e.goodsId) == tonumber(IntanceConst.WIDE_REWARD_ITEM_ID) then 
                    e.showEffect = true
                	if self._tipItem == nil then 
                		self._tipItem = table.deepCopy(e)
                	else
                		self._tipItem.num = self._tipItem.num + e.num
                	end
                end
            end
        end
        if nil ~= v.texp then
            local tmpItem = {}
            tmpItem.num = v.texp
            tmpItem.type = 2
            table.insert(complex, tmpItem)  
        end
        v.complex = complex
        v.items = nil
    end

    if self._tipItem == nil and IntanceConst.WIDE_REWARD_ITEM_ID ~= nil then 
        -- 默认显示0
        self._tipItem = {}
        self._tipItem.goodsId = IntanceConst.WIDE_REWARD_ITEM_ID
        self._tipItem.num = 0
    end

    if self._tipItem ~= nil and IntanceConst.WIDE_REWARD_NEED_ITEM_NUM ~= nil 
        and IntanceConst.WIDE_REWARD_NEED_ITEM_NUM > 0 then
    	self._rewardNodeSize.height = (#self._reward + 1) * 137 + 5   --wangyan
    else 
    	self._rewardNodeSize.height = #self._reward  * 137 + 5
    end
    self._scrollView:setContentSize(self._rewardNodeSize.width, self._rewardNodeSize.height)
    self._scrollView:setContentOffset(cc.p(0, self._scrollView:getViewSize().height - self._rewardNodeSize.height))
    self._scrollView:setTouchEnabled(false)
    self._rewardIndex = 1
    self._rewardNodeSize.height = self._rewardNodeSize.height - 5

    for i=1,#self._reward do
    	local rewardInfo = self._reward[i]
	    local rewardBg = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI7_cellBg21.png")
	    rewardBg:setPosition(cc.p(self._rewardNodeSize.width/2, self._rewardNodeSize.height))
	    rewardBg:setAnchorPoint(cc.p(0.5, 1))
	    rewardBg:setContentSize(cc.size(530, 132)) 
        rewardBg:setCapInsets(cc.rect(41, 41, 1, 1))
	    rewardBg:setName("REWARD_BG_" .. i)
	    self._scrollView:addChild(rewardBg)

    	-- local levelBg = cc.Sprite:createWithSpriteFrameName("globalImageUI6_connerTag_r.png")  
	    -- -- stepBg:setContentSize(cc.size(480,31))
     --    levelBg:setFlipX(true)
	    -- levelBg:setPosition(cc.p(30, rewardBg:getContentSize().height - 22))
	    -- levelBg:setAnchorPoint(cc.p(0.5, 0.5))
	    -- rewardBg:addChild(levelBg)

	    local labStepTitle = cc.Label:createWithTTF("第 " .. i .. " 次扫荡，获得:", UIUtils.ttfName, 22)
        labStepTitle:setAnchorPoint(cc.p(0, 0.5))
        labStepTitle:setPosition(17, rewardBg:getContentSize().height - 25)
        labStepTitle:setColor(UIUtils.colorTable.ccUIBaseTextColor2) 
	    rewardBg:addChild(labStepTitle, 1)



        local awardPosX = 220
	    local tips1 = {}
	    tips1[1] = cc.Sprite:createWithSpriteFrameName("globalImageUI_gold1.png")
        local scaleNum1 = math.floor((30/tips1[1]:getContentSize().width)*100)
        tips1[1]:setScale(scaleNum1/100)
	    tips1[2] = cc.Label:createWithTTF(" " .. rewardInfo.gold,UIUtils.ttfName, 22)
        tips1[2]:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        -- tips1[2]:setColor(UIUtils.colorTable.ccColor1)
        -- tips1[2]:enableOutline(cc.c4b(116,62,34,255),2)
	    -- tips1[2]:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(1, -1))

	    local nodeTip1 = UIUtils:createHorizontalNode(tips1)
	    nodeTip1:setAnchorPoint(cc.p(0, 0.5))
	    nodeTip1:setPosition(awardPosX, rewardBg:getContentSize().height - 24)
	    rewardBg:addChild(nodeTip1, 1)
        awardPosX = awardPosX + nodeTip1:getContentSize().width + 10

        -- 腾讯登录特权和QQVIP加成
        if rewardInfo.goldTxPlus ~= nil and next(rewardInfo.goldTxPlus) ~= nil then
            local tModel = self._modelMgr:getModel("TencentPrivilegeModel")
            local tTab = tab.qqVIP

            local iconValue = {}
            iconValue[tModel.QQ_GAME_CENTER] = {fileName = "tencentIcon_qq.png", scale = 1, plusV = tTab[3].up}
            iconValue[tModel.IS_QQ_VIP] = {fileName = "tencentIcon_qqVip.png", scale = 1, plusV = tTab[5].up}
            iconValue[tModel.IS_QQ_SVIP] = {fileName = "tencentIcon_qqSVip.png", scale = 1, plusV = tTab[6].up}
            iconValue[tModel.WX_GAME_CENTER] = {fileName = "tencentIcon_wxHead.png", scale = 1, plusV = tTab[1].up}

            local tips1 = {}
            local plusNum = 0
            for k, v in pairs(rewardInfo.goldTxPlus) do
                local iconParam = iconValue[k]
                if iconParam then
                    tips1[#tips1 + 1] = cc.Sprite:createWithSpriteFrameName(iconParam.fileName)
                    plusNum = plusNum + iconParam.plusV
                end
            end
            
            tips1[#tips1 + 1] = cc.Label:createWithTTF("+" .. plusNum .. "%", UIUtils.ttfName, 22)
            tips1[#tips1]:setColor(UIUtils.colorTable.ccUIBaseTextColor1)

	        local nodeTip1 = UIUtils:createHorizontalNode(tips1)
	        nodeTip1:setAnchorPoint(cc.p(0, 0.5))
	        nodeTip1:setPosition(awardPosX, rewardBg:getContentSize().height - 24)
	        rewardBg:addChild(nodeTip1, 1)

            awardPosX = awardPosX + nodeTip1:getContentSize().width + 10
        end

        --只有经验数值大于0，才会显示经验获得
        if rewardInfo.exp and rewardInfo.exp > 0 then
            local tips1 = {}
            tips1[1] = cc.Sprite:createWithSpriteFrameName("globalImageUI_exp1.png")
            tips1[2] = cc.Label:createWithTTF(" " .. rewardInfo.exp, UIUtils.ttfName, 22)
            tips1[2]:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
            -- tips1[2]:setColor(UIUtils.colorTable.ccColor1)
            -- tips1[2]:enableOutline(cc.c4b(116,62,34,255),2)
            -- tips1[2]:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(1, -1))

            local nodeTip1 = UIUtils:createHorizontalNode(tips1)
            nodeTip1:setAnchorPoint(cc.p(0, 0.5))
            nodeTip1:setPosition(awardPosX, rewardBg:getContentSize().height - 24)
            rewardBg:addChild(nodeTip1, 1)
            awardPosX = awardPosX + nodeTip1:getContentSize().width + 10
        end

        --经验货币展示
        if rewardInfo.expCoin and rewardInfo.expCoin > 0 then
            local tips1 = {}
            tips1[1] = cc.Sprite:createWithSpriteFrameName("globalImageUI_exp3.png")
            tips1[1]:setScale(0.6)
            tips1[2] = cc.Label:createWithTTF(" " .. rewardInfo.expCoin, UIUtils.ttfName, 22)
            tips1[2]:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
            -- tips1[2]:setColor(UIUtils.colorTable.ccColor1)
            -- tips1[2]:enableOutline(cc.c4b(116,62,34,255),2)
            -- tips1[2]:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(1, -1))

            local nodeTip1 = UIUtils:createHorizontalNode(tips1)
            nodeTip1:setAnchorPoint(cc.p(0, 0.5))
            nodeTip1:setPosition(awardPosX, rewardBg:getContentSize().height - 24)
            rewardBg:addChild(nodeTip1, 1)
        end
	    


	    if nil == rewardInfo.complex or #rewardInfo.complex <= 0 then 
	        self:showNonTip(rewardBg)
	    else 
	        self:showItem(rewardBg, rewardInfo.complex)
	    end

	    rewardBg:setCascadeOpacityEnabled(true, true)
	    rewardBg:setOpacity(0)
	    self._rewardNodeSize.height = self._rewardNodeSize.height - rewardBg:getContentSize().height - 5
        rewardBg.goPosY = rewardBg:getPositionY()
    end
    if self._tipItem ~= nil and IntanceConst.WIDE_REWARD_NEED_ITEM_NUM ~= nil 
    	and IntanceConst.WIDE_REWARD_NEED_ITEM_NUM > 0 then 
	    local rewardBg = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI7_cellBg21.png")
	    rewardBg:setPosition(cc.p(self._rewardNodeSize.width/2, self._rewardNodeSize.height))
	    rewardBg:setAnchorPoint(cc.p(0.5, 1))
	    rewardBg:setContentSize(cc.size(530, 132))  
        rewardBg:setCapInsets(cc.rect(41, 41, 1, 1)) 
	    rewardBg:setName("REWARD_BG_100")
	    self._scrollView:addChild(rewardBg)


        local iconTable = {}
        iconTable.itemId = self._tipItem.goodsId
        -- iconTable.num = self._tipItem.num
        iconTable.eventStyle = 1
        local itemIcon = IconUtils:createItemIconById(iconTable)
        itemIcon:setPosition(cc.p(129, rewardBg:getContentSize().height/2 + 1))
        itemIcon:setAnchorPoint(cc.p(0, 0.5))
        rewardBg:addChild(itemIcon, 1)
        itemIcon:setScale(0.8)

        local sysItem = tab:Tool(self._tipItem.goodsId)
 	    local tips1 = {}
	    tips1[1] = cc.Label:createWithTTF(lang(sysItem.name), UIUtils.ttfName, 22)
	    tips1[1]:setColor(UIUtils.colorTable.ccUIBaseTextColor2) 

	    tips1[2] = cc.Label:createWithTTF("*" .. self._tipItem.num, UIUtils.ttfName, 22)
	    tips1[2]:setColor(UIUtils.colorTable.ccUIBaseTextColor1) 

        local nodeTip1 = UIUtils:createHorizontalNode(tips1)
        nodeTip1:setAnchorPoint(cc.p(0, 0.5))
        nodeTip1:setPosition(219, rewardBg:getContentSize().height/2 + 22)
        rewardBg:addChild(nodeTip1, 1)


        local tips1 = {}
        tips1[1] = cc.Label:createWithTTF("当前收集进度 ", UIUtils.ttfName, 22)
        tips1[1]:setColor(UIUtils.colorTable.ccUIBaseTextColor2) 

		local itemModel = self._modelMgr:getModel("ItemModel")
		local userItems, tempCount = itemModel:getItemsById(self._tipItem.goodsId)
		if tempCount == nil then
            tempCount = 0
		end
        tips1[2] = cc.Label:createWithTTF(tempCount, UIUtils.ttfName, 22)
        tips1[2]:setColor(UIUtils.colorTable.ccUIBaseColor2) 
        tips1[2]:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

	    tips1[3] = cc.Label:createWithTTF("/" .. IntanceConst.WIDE_REWARD_NEED_ITEM_NUM, UIUtils.ttfName, 22)
	    tips1[3]:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
        tips1[3]:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

        if IntanceConst.WIDE_REWARD_NEED_ITEM_NUM > tempCount then 
            tips1[2]:setColor(UIUtils.colorTable.ccUIBaseColor6)
            tips1[3]:setColor(UIUtils.colorTable.ccUIBaseColor6)
        else
            tips1[2]:setColor(UIUtils.colorTable.ccUIBaseColor2)
            tips1[3]:setColor(UIUtils.colorTable.ccUIBaseColor2)
        end

	    local nodeTip1 = UIUtils:createHorizontalNode(tips1)
	    nodeTip1:setAnchorPoint(cc.p(0, 0.5))
	    nodeTip1:setPosition(219, rewardBg:getContentSize().height/2 - 18)
	    rewardBg:addChild(nodeTip1)
        rewardBg:setCascadeOpacityEnabled(true, true)
        rewardBg:setOpacity(0)
	end
    self:showRewardAnimation()
end

-- function IntanceWideRewardView:scrollViewDidScroll(view)
--     local tableOffset = view:getContentOffset()
--     if tableOffset.y < 0 then 

--     end
-- end

function IntanceWideRewardView:showRewardAnimation()
    print("showRewardAnimation==============================================")
    if self._rewardIndex > #self._reward and self._tipItem == nil then
        self._quickShowFin = 1
        self:showFinish(self._rewardIndex-1)
        return
    end
    local rewardBg = nil
    if self._rewardIndex <= #self._reward then 
    	rewardBg = self._scrollView:getContainer():getChildByName("REWARD_BG_" .. self._rewardIndex)
    else 
    	rewardBg = self._scrollView:getContainer():getChildByName("REWARD_BG_100")
    	self._tipItem = nil
    end
    if rewardBg == nil then 
    	self:showFinish(self._rewardIndex)
        self._quickShowFin = 1
    	return
    end
    function nextAmin()
    	self._rewardIndex = self._rewardIndex + 1
        self:showRewardAnimation()
    end
    if self._rewardIndex == 1 then 
		rewardBg:setScale(1.2) 
        local delay1 = cc.CallFunc:create(function()
            cc.DelayTime:create(0.1)
            audioMgr:playSound("adTag")
        end)
        local fade1 = cc.FadeIn:create(0.3)
        local scale2 = cc.ScaleTo:create(0.3, 1.0)
        local call1 = cc.CallFunc:create(function()
        	nextAmin()
        end)
        
        rewardBg:runAction(cc.Speed:create(cc.Sequence:create(delay1, cc.Spawn:create(fade1, scale2), call1), 1.0 * self._offsetTime)) 
    elseif  self._rewardIndex == 2 then
        local y = rewardBg:getPositionY()
        local x = rewardBg:getPositionX()
        rewardBg.goPosY = rewardBg:getPositionY()
        rewardBg:setPositionY(rewardBg:getContentSize().height + 10)
        local delay1 = cc.DelayTime:create(0.2)
        local fade1 = cc.FadeIn:create(0.3)
        local moveTo = cc.MoveTo:create(0.3, cc.p(x, y))
        local call1 = cc.CallFunc:create(function()
            self:handleScrollView(0, 0.3)
            audioMgr:playSound("adTag")
        end)
        local delay2 = cc.DelayTime:create(0.5)
        local call2 = cc.CallFunc:create(function()
			nextAmin()
        end)
        
        rewardBg:runAction(cc.Speed:create(cc.Sequence:create(delay1, cc.Spawn:create(fade1, moveTo), call1, delay2, call2), 1.0 * self._offsetTime))
    else
    	local delay1 = cc.DelayTime:create(0.1)
        local fade1 = cc.FadeIn:create(0.3)
        local call1 = cc.CallFunc:create(function()
        	self:handleScrollView(rewardBg:getContentSize().height + 10, 0.3)
            audioMgr:playSound("adTag")
        end)
        local delay2 = cc.DelayTime:create(0.3)
        local call2 = cc.CallFunc:create(function()
			nextAmin()
        end)
        
        rewardBg:runAction(cc.Speed:create(cc.Sequence:create(delay1, cc.Spawn:create(fade1, call1), delay2, call2), 1.0 * self._offsetTime))
    end
end

function IntanceWideRewardView:handleScrollView(inHeight, inDt)
    local height = 0
    if self._scrollView:getContentSize().height > self._scrollView:getViewSize().height then 
        height = self._scrollView:getContainer():getPositionY() + inHeight 
    else
        height = self._scrollView:getContainer():getPositionY()
    end
    if self._offsetTime == 1 then 

        self._scrollView:setContentOffsetInDuration(cc.p(0, height + 15), inDt / self._offsetTime)

    	local delay1 = cc.DelayTime:create(inDt)
        local call1 = cc.CallFunc:create(function()
        	self._scrollView:stopAllActions()
        	self._scrollView:setContentOffsetInDuration(cc.p(0, height), 0.05)
        end)
        local delay2 = cc.DelayTime:create(0.05)
        self:runAction(cc.Speed:create(cc.Sequence:create(delay1, call1, delay2), 1.0 * self._offsetTime))
    else
        self._scrollView:setContentOffsetInDuration(cc.p(0, height), inDt / self._offsetTime)
    end
end

function IntanceWideRewardView:showItem(inNode, inComplex)
    local index = 0
    local x = 0
    local showItems = {}
    for k,v in pairs(inComplex) do
        local icon = nil
        if v.type == 1 then 
            local toolD = tab:Tool(v.goodsId)
            local iconTable = {}
            iconTable.itemId = v.goodsId
            iconTable.num = v.num
            iconTable.eventStyle = 1
            iconTable.itemData = toolD
            local itemIcon = IconUtils:createItemIconById(iconTable)
            -- itemIcon:setPosition(cc.p(x + 15 * k + ((k - 1) * 65), inNode:getContentSize().height/2 - 18))
            -- itemIcon:setAnchorPoint(cc.p(0, 0.5))
            -- inNode:addChild(itemIcon)
            table.insert(showItems, itemIcon)
            itemIcon:setScale(0.8)
            if v.showEffect == true then 
                local mc1 = mcMgr:createViewMC("wupinguang_itemeffectcollection", true)
                mc1:setPosition(cc.p(itemIcon:getContentSize().width/2,itemIcon:getContentSize().height/2))                    
                -- 不加渐显示，会导致动画跳跃
                mc1:setCascadeOpacityEnabled(true, true)
                mc1:setOpacity(0)
                mc1:runAction(cc.FadeIn:create(0.2))
                itemIcon:addChild(mc1, 100)

                -- mc1:setScale(0.8)
            end
            if itemIcon.iconColor ~= nil and itemIcon.iconColor:getChildByName("bgMc") ~= nil then 
                local bgMc = itemIcon.iconColor:getChildByName("bgMc")
                if bgMc ~= nil then
                    bgMc:setCascadeOpacityEnabled(true, true)
                    bgMc:setOpacity(0)
                    bgMc:runAction(cc.FadeIn:create(0.2))
                end
            end
        elseif v.type == 2 then 
            local itemIcon = IconUtils:createItemIconById({itemId = IconUtils.iconIdMap.texp,num = v.num})
            -- itemIcon:setPosition(cc.p(x + 15 * k + ((k - 1) * 65),inNode:getContentSize().height/2 - 18))
            -- itemIcon:setAnchorPoint(cc.p(0, 0.5))
            -- inNode:addChild(itemIcon)
            itemIcon:setScale(0.8)
            table.insert(showItems, itemIcon)
        end
    end
    if #showItems > 0 then
        local nodeTip1 = UIUtils:createHorizontalNode(showItems, nil, nil, 10)
        nodeTip1:setAnchorPoint(cc.p(0, 1))
        nodeTip1:setPosition(15, inNode:getContentSize().height - 44)
        inNode:addChild(nodeTip1, 1)
    end
end

function IntanceWideRewardView:showNonTip(inNode, callBack)
    local labNonTip = cc.Label:createWithTTF("此次扫荡未获得东西", UIUtils.ttfName, 15)
    labNonTip:setColor(cc.c3b(251,222,157))
    labNonTip:setAnchorPoint(cc.p(0, 0.5))
    labNonTip:setPosition(cc.p(20, inNode:getContentSize().height/2))
    inNode:addChild(labNonTip)
    labNonTip:setScale(1.1)
	labNonTip:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(1, -1))

    local scale1 = cc.ScaleTo:create(0.1, 1.0)
    local delay1 = cc.DelayTime:create(0.2)
    local call1 = cc.CallFunc:create(function()
        if nil ~= callBack then
            callBack()
        end
    end)
    labNonTip:runAction(cc.Sequence:create(scale1, delay1, call1))
end



function IntanceWideRewardView:showFinish(num)

    if self._scrollView:getContentSize().height > self._scrollView:getViewSize().height then
        ScheduleMgr:delayCall(0, self, function()
            self._scrollView:setContentOffset(cc.p(0, 0))
        end)
    end
    
    audioMgr:playSound("sweepOver")
    self._finishMc = mcMgr:createViewMC("fubensaodang_shuaxinguangxiao", false, true, function()
        self._finishMc = nil
        if self._autoClose ==  true then
            if self._callback ~= nil then
                self._callback()
            end
            if self.close then 
                self:close()
            end
            return 
        end        
    end)
    local scrollBg = self:getUI("bg.bg1.scrollBg")
    if num == 1 then
        self._finishMc:setPosition(cc.p(self:getContentSize().width/2 + 10, self:getContentSize().height/2))
        self:addChild(self._finishMc,10)  
    else
        self._finishMc:setPosition(cc.p(self:getContentSize().width/2 + 10, self:getContentSize().height/2)) 
        self:addChild(self._finishMc,10)
    end
    
    -- 关闭按钮
    local closeBtn = self:getUI("bg.closeBtn")
    closeBtn:setVisible(true)


    self._offsetTime = 8

    
    self._quickShowFin = 2
    if self._autoClose ==  true then
        return 
    end
    local enterBtn = self:getUI("bg.bg1.enterBtn")
    local againBtn = self:getUI("bg.bg1.againBtn")
    -- if self._rewardType == 1 then 
        enterBtn:setVisible(false)
        againBtn:setVisible(true)
    -- else
    --     againBtn:setVisible(false)
    --     enterBtn:setVisible(true)
    -- end    
    self._scrollView:setTouchEnabled(true)
end


return IntanceWideRewardView