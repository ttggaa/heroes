


local OneRechargeView = class("OneRechargeView",BasePopView)

function OneRechargeView:ctor(param)
    OneRechargeView.super.ctor(self)
    self.initAnimType = 1
    self._isInBackGround = false
    self._callBack = param.callback
end

function OneRechargeView:getAsyncRes()
    return 
    {
    	{"asset/ui/first.plist", "asset/ui/first.png"},
        "asset/bg/oneCharge.png",
    }
end

function OneRechargeView:onDestroy()
	cc.Director:getInstance():getTextureCache():removeTextureForKey("asset/bg/oneCharge.png")
	OneRechargeView.super.onDestroy(self)
end

-- 初始化UI后会调用, 有需要请覆盖
function OneRechargeView:onInit()
	--关闭当前UI
	self:registerClickEventByName("bg.closeBtn", function() 
		if self._callBack then
			self._callBack()
		end
		self:close() 
		UIUtils:reloadLuaFile("activity.OneRechargeView")
	end)

	local btn = self:getUI("bg.buyBtn")
	btn:setTitleText("¥1 购买")
	self:registerClickEventByName("bg.buyBtn", function ()
         self:onBuy()
   	end)


	local imageBg = self:getUI("bg.image")
	imageBg:loadTexture("asset/bg/oneCharge.png")
	self.award_panel = self:getUI("bg.award_panel")

	--data
	--一元购对应的直购商品id
	local goodsId = tab:Setting("G_SPECIALONE_REWARD").value

	self.itemID = goodsId

	local limit = tab:Setting("G_SPECIALONE_LIMIT").value

	local giftId = tab:CashGoodsLib(goodsId).reward[2]

	self._iosPid = tab:CashGoodsLib(goodsId).payment_ios

	self._price = tab:CashGoodsLib(goodsId).cash

	self.goodsData = clone(tab:ToolGift(giftId))

	local des = tab:CashGoodsLib(goodsId).des or ""
	
	self.itemDes = lang(des)

	self:addReward()

	self:listenReflash("DirectShopModel", self.onGetGift)
	-- self:listenReflash("UserModel", self.updateBtnState)
end


function OneRechargeView:onBuy()
	print("一元购")
	if not OS_IS_WINDOWS then
		local param = {}
	    param.ftype = 3
	    param.gname = self.itemDes
	    param.gdes = self.itemDes
	    param.ext = ""
	    local price =1
	    if OS_IS_IOS then
            param.product_id = "com.tencent.yxwdzzjy."..self._iosPid
            price = tonumber(self._price)*10
        end

	    local ext = "com.tencent.yxwdzzjy.".. self._iosPid .."*".. price .."*".. 1
	    self._modelMgr:getModel("PaymentModel"):chargeDirect(param,ext)
	end
end

--支付完成后，获得展示
function OneRechargeView:applicationWillEnterForeground()
    local rmbResult = self._modelMgr:getModel("DirectShopModel"):getOneCashReslut()
    if rmbResult then
        self:buySuccess(rmbResult)
        self._modelMgr:getModel("DirectShopModel"):clearOneCashResult()
    end
    self._isInBackGround = false
end

function OneRechargeView:applicationDidEnterBackground()
    self._isInBackGround = true
end

function OneRechargeView:onGetGift()
    if self._isInBackGround == false then
        local rmbResult = self._modelMgr:getModel("DirectShopModel"):getOneCashReslut()
	    if rmbResult then
	        self:buySuccess(rmbResult)
	        self._modelMgr:getModel("DirectShopModel"):clearOneCashResult()
	    end
    end
end

function OneRechargeView:buySuccess(result)
	dump(result)
	DialogUtils.showGiftGet( {
        gifts = result["reward"],
        title = "恭喜获得",
        callback = function()
    end})
    if self._callBack then
		self._callBack()
	end
	self:close()
end

function OneRechargeView:addReward()

	local rewardData = self.goodsData.giftContain
	for k,v in pairs(rewardData) do
		local icon 
		local off = 20
		if v[1] == "tool" then 
			local toolData = tab:Tool(v[2])			
			icon = IconUtils:createItemIconById({itemId = v[2],num = v[3],eventStyle = 1,effect = true})
			icon:setScale(0.9)
			icon:setPosition((k-1)*(icon:getContentSize().width)+off, 5)
		elseif v[1] == "team" then 
			local teamD = tab:Team(v[2])		
			icon = IconUtils:createSysTeamIconById({sysTeamData = teamD,isGray = false ,eventStyle = 1,isJin = true})
			local diguang = mcMgr:createViewMC("diguang_itemeffectcollection", true, false, nil, RGBA8888) 
			diguang:setPosition(icon:getContentSize().width/2-2, icon:getContentSize().height/2-2)
			local diguangParent = icon:getChildByName("teamIcon") or icon
			diguangParent:addChild(diguang,-1)
			local saoguang = IconUtils:addEffectByName({"tongyongdibansaoguang_itemeffectcollection","wupinkuangxingxing_itemeffectcollection"})
			local effectParent = icon:getChildByName("iconColor") or icon
			effectParent:addChild(saoguang,5)  
			icon:setScale(0.79)
			icon:setPosition((k-1)*(icon:getContentSize().width-16)+off,4)
		else
			local dataId = IconUtils.iconIdMap[v[1]]
			icon = IconUtils:createItemIconById({itemId = dataId,num = v[3],eventStyle = 1,effect = true})
	 		icon:setScale(0.9)
    		icon:setPosition((k-1)*(icon:getContentSize().width)+off, 5)
		end
    	self.award_panel:addChild(icon,1)
	end
end


-- 成为topView会调用, 有需要请覆盖
function OneRechargeView:onTop()
	print("接收自定义消息    成为topView会调用, 有需要请覆盖")
	-- self:updateBtnState()
end



return OneRechargeView