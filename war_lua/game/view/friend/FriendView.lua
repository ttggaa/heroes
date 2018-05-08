--[[
    Filename:    FriendView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-07-26 16:13
    Description: 好友系统
--]]

local FriendView = class("FriendView", BaseView)

function FriendView:ctor(param)
	FriendView.super.ctor(self)
	self.initAnimType = 3

	self._friendModel = self._modelMgr:getModel("FriendModel")
	self._userModel = self._modelMgr:getModel("UserModel")
	self._userModelData = self._modelMgr:getModel("UserModel"):getData()
	require("game.view.friend.FriendConst")

    self._data = {}
    self._pageNum = 1
    
    if param and param.openType then
    	self._openType = param.openType
    else
    	self._openType = FriendConst.FRIEND_TYPE.FRIEND
    end

    self._cellW, self._cellH = 739, 120
end

function FriendView:onInit()
	self._friendModel:resetData()
	-- 通用动态背景
    self:addAnimBg()

    self._bg = self:getUI("bg.bg1")
    self._nothingBg = self:getUI("bg.bg1.nothing")

    self:getUI("bg.bg1.platformView"):setSwallowTouches(false)
    self:getUI("bg.bg1.friendView"):setSwallowTouches(false)
	self:getUI("bg.bg1.addView"):setSwallowTouches(false)
	self:getUI("bg.bg1.applyView"):setSwallowTouches(false)
	self:getUI("bg.bg1.deleteView"):setSwallowTouches(false)

	--初始化默认显示
	self:getUI("bg.bg1.platformView"):setVisible(false)
	self:getUI("bg.bg1.friendView"):setVisible(true)
	self:getUI("bg.bg1.addView"):setVisible(false)
	self:getUI("bg.bg1.applyView"):setVisible(false)
	self:getUI("bg.bg1.deleteView"):setVisible(false)

	local friLab = self:getUI("bg.bg1.friLab")
	local friNum = self:getUI("bg.bg1.friNum")
	local Panel_29 = self:getUI("bg.bg1.Panel_29")
	local Panel_49 = self:getUI("bg.bg1.Panel_49")
	friLab:setVisible(false)
	friNum:setVisible(false)
	Panel_29:setVisible(false)
	Panel_49:setVisible(false)

	self._tableBg = self:getUI("bg.bg1.listView")

	self._platformBtn = self:getUI("bg.bg1.platformBtn")
	self._platformBtn:setName("platform")
    self._friendBtn = self:getUI("bg.bg1.friendBtn")   
    self._friendBtn:setName("friend")
    self._addBtn = self:getUI("bg.bg1.addBtn")
    self._addBtn:setName("add")
    self._applyBtn = self:getUI("bg.bg1.applyBtn")
    self._applyBtn:setName("apply")

    self:getUI("bg.bg1.Panel_49.signDes"):setString("")

	self._tabEventTarget = {}
	table.insert(self._tabEventTarget, self._platformBtn)
    table.insert(self._tabEventTarget, self._friendBtn)  
    table.insert(self._tabEventTarget, self._addBtn)
    table.insert(self._tabEventTarget, self._applyBtn)
    for k,button in pairs(self._tabEventTarget) do
        button:setTitleFontName(UIUtils.ttfName)
        -- button:setTitleFontSize(24) -- 统一大小24 不用单独设
    end

    -- [[ 板子动画
    self._playAnimBg = self:getUI("bg.bg1")
    self._playAnimBgOffX = 42
    self._playAnimBgOffY = -26
    self._animBtns = self._tabEventTarget
    --]]

    ---[[
    if GameStatic.appleExamine then
		self._platformBtn:setVisible(false)
		self:getUI("bg.bg1.platformView"):setVisible(false)
		for i=1,#self._tabEventTarget do
			if self._tabEventTarget[i]:getName() ~= "platform" then
				self._tabEventTarget[i]:setPositionY(self._tabEventTarget[i]:getPositionY() + 80)
			end
		end
    else
	    if sdkMgr:isQQ() == true then
			self._platformBtn:setTitleText("QQ")
		elseif sdkMgr:isWX() == true then
			self._platformBtn:setTitleText("微信")
		else
			self._platformBtn:setVisible(false)
			self:getUI("bg.bg1.platformView"):setVisible(false)
			for i=1,#self._tabEventTarget do
				if self._tabEventTarget[i]:getName() ~= "platform" then
					self._tabEventTarget[i]:setPositionY(self._tabEventTarget[i]:getPositionY() + 80)
				end
			end
		end
	end
	---]]

 	-- self:registerClickEvent(self._platformBtn, function(sender) self:tabButtonClick(sender) end)
	-- self:registerClickEvent(self._friendBtn, function(sender) self:tabButtonClick(sender) end)
	-- self:registerClickEvent(self._addBtn, function(sender) self:tabButtonClick(sender) end)
	-- self:registerClickEvent(self._applyBtn, function(sender) self:tabButtonClick(sender) end)
	UIUtils:setTabChangeAnimEnable(self._platformBtn,-22,handler(self, self.tabButtonClick))
	UIUtils:setTabChangeAnimEnable(self._friendBtn,-22,handler(self, self.tabButtonClick))
	UIUtils:setTabChangeAnimEnable(self._addBtn,-22,handler(self, self.tabButtonClick))
	UIUtils:setTabChangeAnimEnable(self._applyBtn,-22,handler(self, self.tabButtonClick))
	--common
	self._friNum = self:getUI("bg.bg1.friNum")
	self._friNum:setString("")
	self:getUI("bg.bg1.Panel_29.myUIDNum"):setString(self._userModelData["usid"])

	self:onInitPlatform()  	--platform
	self:onInitFriend()  	--friend
	self:onInitApply()   	--apply
	self:onInitAdd()	 	--add
	self:onInitDelete()  	--delete

    self:setListenReflashWithParam(true)
	self:listenReflash("FriendModel", self.reflashView) 

	self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
        	self._friendModel:setIsLoadDataByType()
        	self._friendModel:setCurChannel()
        	UIUtils:reloadLuaFile("friend.FriendView")
        	UIUtils:reloadLuaFile("friend.FriendCell")
        	-- UIUtils:reloadLuaFile("friend.FriendUserInfoView")
        	-- UIUtils:reloadLuaFile("friend.FriendRecallRuleView")

        elseif eventType == "enter" then
	        if self._openType == FriendConst.FRIEND_TYPE.APPLY then 
	        	-- _appearSelect = true 页签进入动画 调层级用
	        	self._applyBtn._appearSelect = true
	         	self:tabButtonClick(self._applyBtn)
			else
				self._friendBtn._appearSelect = true
				self:tabButtonClick(self._friendBtn)
			end 
        end
    end)
end

function FriendView:onInitPlatform()
	local phyGetNum = self:getUI("bg.bg1.platformView.phyGetNum")
	phyGetNum:setString("")

	--quickGet
	self._quickGetPlatBtn = self:getUI("bg.bg1.platformView.quickGet")
	-- self._quickGetPlatBtn:setVisible(false)
	self:registerClickEvent(self._quickGetPlatBtn, function()
		if self._quickGetPlatBtn:getSaturation() == -180 then
			self._viewMgr:showTip(lang("FRIEND_18"))
			return
		end
		local phyLast = self._userModel:getData().physcal
		local curCanGet = self._friendModel:getPhyUperPlat()
		if curCanGet == 0 then
			self._viewMgr:showTip(lang("FRIEND_12"))
			return
		end
		if phyLast >= tab.setting["PHYSCAL_MAX"].value - 1 then
			self._viewMgr:showTip("当前体力已达上限")
			return
		end
		self._serverMgr:sendMsg("GameFriendServer", "getPlatPhy", {type = 2}, true, {}, function(result, error)
			-- self._viewMgr:showTip("一键领取成功")
			if not result or not result["d"] then
				self:tabButtonClick(self._platformBtn)
				return
			end

			-- dump(result, "123", 10)
			--更新体力 
			if result.d.dayInfo then
				self._modelMgr:getModel("PlayerTodayModel"):updateDayInfo(result.d.dayInfo)
				result.d.dayInfo = nil
			end
			result.d.pids = nil

			self._modelMgr:getModel("UserModel"):updateUserData(result.d)

			local phyDis = 0
			if result.d.physcal then
				phyDis = math.max(math.floor((result.d.physcal - phyLast)/2) * 2, 0)
			end

			if phyDis >= curCanGet then
				self._viewMgr:showTip("成功领取"..curCanGet.."体力，已达到今日可领取上限")
			else
				self._viewMgr:showTip("成功领取".. phyDis .."点体力，还有".. (curCanGet - phyDis).."点达到今日可领取上限")
			end

			self._friendModel:setPhyUperPlat(phyDis)
			self:tabButtonClick(self._platformBtn)
			end)
		end)

	--quickSend
	self._quickGivePlatBtn = self:getUI("bg.bg1.platformView.quickGive")
	-- self._quickGivePlatBtn:setVisible(false)
	self:registerClickEvent(self._quickGivePlatBtn, function()
		if self._quickGivePlatBtn:getSaturation() == -180 then
			self._viewMgr:showTip(lang("FRIEND_17"))
			return
		end
		self._serverMgr:sendMsg("GameFriendServer", "sendPlatPhy", {type = 2}, true, {}, function(result, error)
				self._viewMgr:showTip("赠送好友成功")
				self:tabButtonClick(self._platformBtn)
			end)
		end)

	--inviteBtn
	self._invitePlatBtn = self:getUI("bg.bg1.platformView.inviteBtn")
	-- local title, desc = "邀请好友", "邀请好友参与游戏，互送体力，好处多多！"
	-- if sdkMgr:isQQ() == true then
	-- 	title = "邀请QQ好友"
	-- 	desc = "邀请QQ好友参与游戏，互送体力，好处多多！"
	-- elseif sdkMgr:isQQ() == true then
	-- 	title = "邀请微信好友"
	-- 	desc = "邀请微信好友参与游戏，互送体力，好处多多！"
	-- end
	-- self._invitePlatBtn:setVisible(false)
	self:registerClickEvent(self._invitePlatBtn, function()
		local param = {}
        param.scene = 2
        param.title = lang("FRIEND_INVITE1")
        param.desc = lang("FRIEND_INVITE2")
        -- param.path = "/storage/emulated/0/Android/data/com.tencent.tmgp.yxwdzzjy/share.png"
        param.media_tag = sdkMgr.SHARE_TAG.MSG_INVITE
        sdkMgr:sendToPlatform(param, function(code, data)

        end)
		end)
end

function FriendView:onInitFriend()
	local phyGetNum = self:getUI("bg.bg1.friendView.phyGetNum")
	phyGetNum:setString("")

	--quickGet
	self._quickGetBtn = self:getUI("bg.bg1.friendView.quickGet")
	self:registerClickEvent(self._quickGetBtn, function()
		if self._quickGetBtn:getSaturation() == -180 then
			self._viewMgr:showTip(lang("FRIEND_18"))
			return
		end
		local phyLast = self._userModel:getData().physcal
		local curCanGet = self._friendModel:getPhysicalUper()
		if curCanGet <= 0 then
			self._viewMgr:showTip(lang("FRIEND_12"))
			return
		end
		if phyLast >= tab.setting["PHYSCAL_MAX"].value - 1 then
			self._viewMgr:showTip("当前体力已达上限")
			return
		end

		self._serverMgr:sendMsg("GameFriendServer", "onekeyGetPhysical", {}, true, {}, function(result, error)
			-- self._viewMgr:showTip("一键领取成功")
			if not result or not result["d"] or not result.d.dayInfo then
				self:tabButtonClick(self._friendBtn)
				return
			end
			-- dump(result, "123", 10)
			--更新体力  
			self._modelMgr:getModel("PlayerTodayModel"):updateDayInfo(result.d.dayInfo)
			result.d.dayInfo = nil
			result.d.getlist = nil
			self._modelMgr:getModel("UserModel"):updateUserData(result.d)


			local phyDis = 0
			if result.d.physcal then
				phyDis = math.max(math.floor((result.d.physcal - phyLast)/2) * 2, 0)
			end

			if phyDis >= curCanGet then
				self._viewMgr:showTip("成功领取"..curCanGet.."体力，已达到今日可领取上限")
			else
				self._viewMgr:showTip("领取".. phyDis .."点体力，还有"..(curCanGet - phyDis).."点达到今日可领取上限")
			end

			self._friendModel:setPhysicalUper(phyDis)
			self:tabButtonClick(self._friendBtn)
			end)
		end)

	--quickGive
	self._quickGiveBtn = self:getUI("bg.bg1.friendView.quickGive")
	self:registerClickEvent(self._quickGiveBtn, function()
		if self._quickGiveBtn:getSaturation() == -180 then
			self._viewMgr:showTip(lang("FRIEND_17"))
			return
		end
		self._serverMgr:sendMsg("GameFriendServer", "onekeySendPhysical", {}, true, {}, function()
			self._viewMgr:showTip("赠送好友成功")
			self:tabButtonClick(self._friendBtn)
			end)
		end)

	--deleteBtn
	self._deleteBtnFri = self:getUI("bg.bg1.friendView.deleteBtn")
	self:registerClickEvent(self._deleteBtnFri, function()
		if self._deleteBtnFri:getSaturation() == -180 then
			self._viewMgr:showTip(lang("FRIEND_22"))
			return
		end
		self:tabButtonClick(self._friendBtn, FriendConst.FRIEND_TYPE.DELETE)
		end)

	--refreshBtn
	self._refreshBtn = self:getUI("bg.bg1.friendView.refreshBtn")
	self:registerClickEvent(self._refreshBtn, function()
		if self._refreshBtn:getSaturation() == -180 then
			self._viewMgr:showTip(lang("FRIEND_22"))
			return
		end
		self._friendModel:sortFriendData()
		self._viewMgr:showTip("刷新成功")
		self:tabButtonClick(self._friendBtn, self._curChannel)
		end)
end

function FriendView:onInitAdd()
	--rejectAllBtn
	self._rejectAllBtn = self:getUI("bg.bg1.addView.rejectAllBtn")
	self:registerClickEvent(self._rejectAllBtn, function()
		if self._rejectAllBtn:getSaturation() == -180 then
			self._viewMgr:showTip(lang("FRIEND_19"))
			return
		end
		self._serverMgr:sendMsg("GameFriendServer", "onekeyAcceptGameFriend", {accept = 0}, true, {}, function(error, result)
			self._friendModel:quickDealFriendApply(0)
			self:tabButtonClick(self._addBtn)
			end)
		end)

	--agreeAllBtn
	self._agreeAllBtn = self:getUI("bg.bg1.addView.agreeAllBtn")
	self:registerClickEvent(self._agreeAllBtn, function()
		if self._agreeAllBtn:getSaturation() == -180 then
			self._viewMgr:showTip(lang("FRIEND_60"))
			return
		end
		local friendNum = #clone(self._friendModel:getDataByType(FriendConst.FRIEND_TYPE.FRIEND))	
		if friendNum >= FriendConst.FRIEND_TOP_NUM then
			self._viewMgr:showTip(lang("FRIEND_7"))
			return
		end
		self._serverMgr:sendMsg("GameFriendServer", "onekeyAcceptGameFriend", {accept = 1}, true, {}, function(error, result)
			if #result["d"] == 0 then   
				self._viewMgr:showTip(lang("FRIEND_6"))
				return
			end

			self._friendModel:quickDealFriendApply(1, result["d"])
			if friendNum + #result["d"] > FriendConst.FRIEND_TOP_NUM then  
				self._viewMgr:showTip(lang("FRIEND_7"))
			else
				self._viewMgr:showTip(lang("FRIEND_5"))  
			end
			self:tabButtonClick(self._addBtn)
			end)
		end) 
end

function FriendView:onInitApply()
	self._contextTextField = self:getUI("bg.bg1.applyView.inputBg.Panel_30.textField")
    self._contextTextField:setTouchEnabled(false)
    self._contextTextField.rectifyPos = true  
    self._contextTextField.openCustom = true
    self._contextTextField.maxLengTip = lang("CHAT_SYSTEM_LENTH_TIP")
    self._contextTextField:setPlaceHolder(lang("FRIEND_2"))
    self._contextTextField:setTextColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._contextTextField:setPlaceHolderColor(UIUtils.colorTable.ccUIInputTipColor)
    self:registerClickEventByName("bg.bg1.applyView.inputBg.Panel_30", function ()
        self._contextTextField:attachWithIME()
    end)

    --changeAllBtn
    self._changeAllBtn = self:getUI("bg.bg1.applyView.changeAllBtn")
	self:registerClickEvent(self._changeAllBtn, function()
		self._viewMgr:lock(-1)
		self._serverMgr:sendMsg("GameFriendServer", "recommendGameFriend", {}, true, {}, function(result)
			-- dump(result)
			self._contextTextField:setString("")
			self:tabButtonClick(self._applyBtn)
			self._viewMgr:unlock()
			end)
		end)

	--applyAllBtn
	self._applyAllBtn = self:getUI("bg.bg1.applyView.applyAllBtn") 
	self:registerClickEvent(self._applyAllBtn, function()
		if self._applyAllBtn:getSaturation() == -180 then
			self._viewMgr:showTip(lang("FRIEND_21"))
			return
		end

		local friendNum = #clone(self._friendModel:getDataByType(FriendConst.FRIEND_TYPE.FRIEND))	
		if friendNum >= FriendConst.FRIEND_TOP_NUM then
			self._viewMgr:showTip(lang("FRIEND_7"))
			return
		end

		local ids = self._friendModel:getQuickApplyID() 
		if #ids == 0 then
			return
		end
		self._serverMgr:sendMsg("GameFriendServer", "onekeyApplyGameFriend", {idlist = json.encode({idlist = ids})}, true, {}, function(result, error)
			-- dump(result, "123", 10)
			-- if #result["d"] == 0 then
			-- 	self._viewMgr:showTip("对方申请列表已满或")
			-- end
			self._friendModel:quickApply(result["d"])
			self:tabButtonClick(self._applyBtn)
			end)
		end)

	--findBtn
    self:registerClickEventByName("bg.bg1.applyView.findBtn", function()
    	local input = self._contextTextField:getString()
    	if input == "" then
    		self._viewMgr:showTip(lang("FRIEND_2"))
    		return
    	end

    	local userModel = self._modelMgr:getModel("UserModel"):getData()
    	if userModel["usid"] == input or userModel["name"] == input then
    		self._viewMgr:showTip("不能查找自身")
    		self._contextTextField:setString("")
    		return
    	end

    	local isFriend = self._friendModel:checkIsFriend(input)
    	if isFriend then
    		self._viewMgr:showTip(lang("FRIEND_13"))
    		self._contextTextField:setString("")
    		return
    	end

    	local isInApply = self._friendModel:checkIsInApply(input)
    	if isInApply then
    		self._viewMgr:showTip("对方已在您的申请列表中")
    		self._contextTextField:setString("")
    		return
    	end

		self._serverMgr:sendMsg("GameFriendServer", "searchGameFriend", {param = input}, true, {}, function(result, error)
			self._applyAllBtn:setSaturation(-180)
			self._applyAllBtn:setTouchEnabled(false)
			self._data = clone(self._friendModel:getDataByType(self._curChannel))
			self._tableView:reloadData()
			-- dump(self._data, "123", 10)
	    	end)
		end)
end

function FriendView:onInitDelete()
	--enterBtn
	local enterBtn = self:getUI("bg.bg1.deleteView.enterBtn")
	self:registerClickEvent(enterBtn, function()
		local delUsic = self._friendModel:getDeleteUsid()
		if #delUsic == 0 then
			self._viewMgr:showTip("请先勾选要删除好友")
		else
			self._viewMgr:showDialog("global.GlobalSelectDialog", 
				{desc = "确定要删除"..#delUsic.."个好友么？", 
				button1 = "确定", 
				button2 = "取消" ,
				callback1 = function ()
	                self._serverMgr:sendMsg("GameFriendServer", "deleteGameFriend", {usid = json.encode({usid = delUsic})}, true, {}, function(result)
	                	self._data = clone(self._friendModel:getDataByType(self._curChannel))
	                	if #self._data == 0 then
	                		self:tabButtonClick(self._friendBtn)
	                	else
	                		self:tabButtonClick(self._friendBtn, self._curChannel)
	                	end
			   			
			   			self._viewMgr:showTip("成功删除".. #delUsic.. "个好友")
			   			self._friendModel:setDeleteUsid() --重置
			    	end)     
            	end,
            	callback2 = function()
	            end})
		end
		end) 

	--cancelBtn
	local cancelBtn = self:getUI("bg.bg1.deleteView.cancelBtn")
	self:registerClickEvent(cancelBtn, function()
		self._friendModel:setDeleteUsid(inUsid)
		self:tabButtonClick(self._friendBtn) 
		end)
end

function FriendView:reflashView(data)  
	if data ==nil then
		return
	end
	-----红点处理
	if data == "redPoint" then
		self:refreshRedPoint()
		return
	end

	----推送数据处理
	local data = string.split(data, "_")
	if not (data[1] and data[2]) then
		return
	end
	if self._curChannel == "delete" and data[2] == "friend" then  --好友与删除界面处理
		data[2] = FriendConst.FRIEND_TYPE.DELETE
	end

	if data[2] ~= self._curChannel then 
		self:refreshRedPoint()  
		return
	end

	self._data = self._friendModel:getDataByType(self._curChannel)
	self:refreshCurUI()   --视图
	self._tableView:reloadData()  --数据刷新
end

function FriendView:tabButtonClick(sender, btnType)
	if sender == nil then
		return
	end

	-- lock
	self._viewMgr:lock(-1)

	self._curChannel = btnType or sender:getName()
	self._friendModel:setCurChannel(self._curChannel)
	if self._curChannel == FriendConst.FRIEND_TYPE.ADD then
		self._friendModel:resetAddUnread()  --add红点重置
	end

    --页签状态
    if self._curChannel ~= FriendConst.FRIEND_TYPE.DELETE then
    	self:setBtnState(sender)
    end

    if self._tableView ~= nil then 
    	if self._tableView.__scrollBg then self._tableView.__scrollBg:removeFromParent() end
    	if self._tableView.__scrollBar then self._tableView.__scrollBar:removeFromParent() end
        self._tableView:removeFromParent()
        self._tableView = nil
    end

    local tableBg = self:getUI("bg.bg1.listView") --786/345  747/128
    self._tableView = cc.TableView:create(cc.size(tableBg:getContentSize().width - 20, tableBg:getContentSize().height - 20))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setPosition(cc.p(10, 10))
    self._tableView:setDelegate()
    self._tableView:setBounceable(true) 
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(function(table, cell ) return self:tableCellWillRecycle(table,cell) end ,cc.TABLECELL_WILL_RECYCLE)
    tableBg:addChild(self._tableView)
    if self._tableView.setDragSlideable ~= nil then 
        self._tableView:setDragSlideable(true)
    end
    UIUtils:ccScrollViewAddScrollBar(self._tableView, cc.c3b(169, 124, 75), cc.c3b(32, 16, 6), 2, 6)

    --请求数据
    ScheduleMgr:delayCall(0, self, function ()
    	local isHasLoad = self._friendModel:getIsLoadDataByType(self._curChannel)
        if not isHasLoad then 
            self:getMessageByType(self._curChannel)
            return
        end
        
        self._data = clone(self._friendModel:getDataByType(self._curChannel))
        -- dump(self._data, "djalf", 10)
        self:refreshUI()
        self._tableView:reloadData()
        -- self:locateShowCell()

        self._viewMgr:unlock()  -- unlock
    end)
end

--召回好友定位
function FriendView:locateShowCell()
    if self._curChannel == FriendConst.FRIEND_TYPE.PLATFORM then
	    local recallNum = self._friendModel:getPlatRecallNum()
		local numMax = tab.setting["FRIEND_RETURN_GIFT_NUM"].value
		if recallNum >= numMax then
			return
		end

		local curT= self._userModel:getCurServerTime()
    	for i,v in ipairs(self._data) do
    		local recallT = v["recallTime"] or 0
			local loginTime = v["loginTime"]
			if loginTime == nil then
				loginTime = v["logoutTime"] or 0
			end
    		local disT1 = curT - recallT
			local disT2 = curT - loginTime

			local limitT = 86400 * tab.setting["FRIEND_RETURN_DAY"].value
			local versionT = TimeUtils.getIntervalByTimeString(tab.setting["FRIEND_BACK_TIME"].value)
			if disT1 >= limitT and disT2 >= limitT and recallT < versionT then
				local cellH
				if i > 2 then
					if i == #self._data then
						cellH = 0
					else
						cellH = self._cellH * (#self._data - i - 1)
					end
				end				

				if cellH then
					local offsetX = self._tableView:getContentOffset().x
					self._tableView:setContentOffset(cc.p(offsetX, -cellH))
				end
				
				return
			end
    	end
    end
end

function FriendView:setBtnState(sender)
	for k,v in pairs(self._tabEventTarget) do
        if v ~= sender then 
            local text = v:getTitleRenderer()
            v:setTitleColor(UIUtils.colorTable.ccUITabColor1)
            text:disableEffect()
            v:setScaleAnim(false)
            v:stopAllActions()
            if v:getChildByName("changeBtnStatusAnim") then 
                v:getChildByName("changeBtnStatusAnim"):removeFromParent()
            end
            v:setBright(true)
    		v:setEnabled(true)

            if ( self._preBtn and self._preBtn == v) then
                UIUtils:tabChangeAnim(self._preBtn,nil,true)
            end
        end
    end

    self._preBtn = sender
    UIUtils:tabChangeAnim(sender,function( )
        local text = sender:getTitleRenderer()
        text:disableEffect()
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor2)
        sender:setBright(false)
    	sender:setEnabled(false)
    end)
end

function FriendView:refreshUI()
	--panel
	self:getUI("bg.bg1.platformView"):setVisible(false)
	self:getUI("bg.bg1.friendView"):setVisible(false)
	self:getUI("bg.bg1.deleteView"):setVisible(false)
	self:getUI("bg.bg1.addView"):setVisible(false)
	self:getUI("bg.bg1.applyView"):setVisible(false)
	self:getUI("bg.bg1."..self._curChannel.."View"):setVisible(true)

	if self._curChannel == FriendConst.FRIEND_TYPE.ADD or self._curChannel == FriendConst.FRIEND_TYPE.APPLY then
		self:getUI("bg.bg1.Panel_29"):setVisible(true)
	else
		self:getUI("bg.bg1.Panel_29"):setVisible(false)
	end

	self:getUI("bg.bg1.friLab"):setVisible(true)
	self:getUI("bg.bg1.friNum"):setVisible(true)

	--签名
	self:refreshUserMark()
	--UI刷新
	self:refreshCurUI()
end

function FriendView:refreshCurUI()
	--玩家数
	if self._curChannel == FriendConst.FRIEND_TYPE.PLATFORM then
		self._friNum:setString(#self._friendModel:getDataByType(FriendConst.FRIEND_TYPE.PLATFORM))
	else
		self._friNum:setString(#self._friendModel:getDataByType(FriendConst.FRIEND_TYPE.FRIEND) .. "/".. FriendConst.FRIEND_TOP_NUM)
	end	

	--按钮
	self:hideBtnsByType()
	--红点
	self:refreshRedPoint()
	--界面其它
	self:refreshCurUIByType()
end

function FriendView:refreshCurUIByType()
	if self._curChannel == FriendConst.FRIEND_TYPE.PLATFORM then
		local pfPhy = self:getUI("bg.bg1.platformView.phyGetNum")
		pfPhy:setString(self._friendModel:getPhyUperPlat().."/"..tab.setting["FRINEDS_GIVE"].value)

	elseif self._curChannel == FriendConst.FRIEND_TYPE.FRIEND then
		local friPhy = self:getUI("bg.bg1.friendView.phyGetNum")
		friPhy:setString(self._friendModel:getPhysicalUper().."/"..FriendConst.FRIEND_PHY_TOP)
	end
end

--红点
function FriendView:refreshRedPoint()
	for i,v in ipairs(self._tabEventTarget) do
		v:getChildByName("btnRed"):setVisible(false)
	end

	local friRedPoint = self._friendModel:checkFriendRedPoint()  --好友
	local isPhyUper = self._friendModel:checkIsPhysicalUper()   --体力领取上限
	if friRedPoint and not isPhyUper then
		self._friendBtn:getChildByName("btnRed"):setVisible(true)
	end
	
	local addRedPoint = self._friendModel:checkAddRedPoint()  --添加
	if addRedPoint then
		self._addBtn:getChildByName("btnRed"):setVisible(true)
	end
end

--隐藏按钮
function FriendView:hideBtnsByType()
	--platform
	self._quickGivePlatBtn:setSaturation(0)
	self._quickGetPlatBtn:setSaturation(0)
	self._invitePlatBtn:setSaturation(0)
	--friend
	self._deleteBtnFri:setSaturation(0)
	self._quickGiveBtn:setSaturation(0)
	self._quickGetBtn:setSaturation(0)
	self._refreshBtn:setSaturation(0)
	--add
	self._agreeAllBtn:setSaturation(0)
	self._rejectAllBtn:setSaturation(0)
	--apply
	self._applyAllBtn:setSaturation(0)
	self._applyAllBtn:setTouchEnabled(true)

	self._nothingBg:setVisible(false)
	--数据为空时
	if #self._data == 0 then
		if self._curChannel == FriendConst.FRIEND_TYPE.PLATFORM then 
			self._quickGivePlatBtn:setSaturation(-180)
			self._quickGetPlatBtn:setSaturation(-180)
			self._invitePlatBtn:setSaturation(-180)
			
		elseif self._curChannel == FriendConst.FRIEND_TYPE.FRIEND then
			self._deleteBtnFri:setSaturation(-180)
			self._quickGiveBtn:setSaturation(-180)
			self._quickGetBtn:setSaturation(-180)
			self._refreshBtn:setSaturation(-180)

			self._nothingBg:setVisible(true)
			self._nothingBg:getChildByName("noneLabel"):setString("快去添加好友吧~")

		elseif self._curChannel == FriendConst.FRIEND_TYPE.ADD then
			self._agreeAllBtn:setSaturation(-180)
			self._rejectAllBtn:setSaturation(-180)

			self._nothingBg:setVisible(true)
			self._nothingBg:getChildByName("noneLabel"):setString("暂时没有好友申请喔")

		elseif self._curChannel == FriendConst.FRIEND_TYPE.APPLY then
			self._applyAllBtn:setSaturation(-180)
		end

	else  --数据非空
		if self._curChannel == FriendConst.FRIEND_TYPE.PLATFORM then
			local isCanGet = self._friendModel:checkIsCanGet(self._curChannel)
			if not isCanGet then
				self._quickGetPlatBtn:setSaturation(-180)
			end

			local isCanSend = self._friendModel:checkIsCanSend(self._curChannel)
			if not isCanSend then
				self._quickGivePlatBtn:setSaturation(-180)
			end
			
		elseif self._curChannel == FriendConst.FRIEND_TYPE.FRIEND then	  
			local isCanGet = self._friendModel:checkIsCanGet()
			if not isCanGet then
				self._quickGetBtn:setSaturation(-180)
			end

			local isCanSend = self._friendModel:checkIsCanSend()
			if not isCanSend then
				self._quickGiveBtn:setSaturation(-180)
			end

		elseif self._curChannel == FriendConst.FRIEND_TYPE.APPLY then
			local isCanQuickApply = self._friendModel:checkIsCanQuickApply()
			if not isCanQuickApply then
				self._applyAllBtn:setSaturation(-180)
			end
		end
	end
end 

function FriendView:refreshUserMark()
	local signPanel = self:getUI("bg.bg1.Panel_49")
	if self._curChannel == FriendConst.FRIEND_TYPE.APPLY then
		signPanel:setVisible(false)
	else
		signPanel:setVisible(true)
	end
	local msg = self._modelMgr:getModel("UserModel"):getSlogan()
	if not msg or msg == "" then
		msg = "这家伙很懒，什么也没有留下"
	end
	signPanel:getChildByName("signDes"):setString(msg)
end

function FriendView:getMessageByType(inType)
	if inType == FriendConst.FRIEND_TYPE.PLATFORM then    --平台好友
		self._serverMgr:sendMsg("GameFriendServer", "getPlatFriendList", {}, true, {}, function (result)
			-- dump(result,"PLATFORM", 10)
	        self:getMessageFinish()
	    end)

	elseif inType == FriendConst.FRIEND_TYPE.FRIEND then    --好友 列表
		self._serverMgr:sendMsg("GameFriendServer", "getGameFriendList", {}, true, {}, function (result)
			-- dump(result,"FRIEND", 10)
	        self:getMessageFinish()
	    end)

	elseif inType == FriendConst.FRIEND_TYPE.ADD then   --处理好友 列表
		self._serverMgr:sendMsg("GameFriendServer", "getApplyList", {}, true, {}, function (result)
			-- dump(result,"ADD", 10)
	        self:getMessageFinish()
	    end)

	elseif inType == FriendConst.FRIEND_TYPE.APPLY then --申请加好友 列表
		self._serverMgr:sendMsg("GameFriendServer", "recommendGameFriend", {}, true, {}, function (result)	
			-- dump(result,"APPLY", 10)
	        self:getMessageFinish()
	    end)
	end
end

function FriendView:getMessageFinish()
	-- unlock
	self._viewMgr:unlock()

	self._friendModel:setIsLoadDataByType(self._curChannel)
	self._data = clone(self._friendModel:getDataByType(self._curChannel))
	self:refreshUI()
	-- dump(self._data, "123", 10)

    self._tableView:reloadData()
    -- self:locateShowCell()
    
end

function FriendView:scrollViewDidScroll(view) 
	-- local tableOffset = view:getContentOffset()
 --    if tableOffset.y < 0 then 
	-- 	local insertData = clone(self._friendModel:getDataByTurn(self._curChannel, self._pageNum+1))
	-- 	if (self._pageNum-1)*10 > #curData then  --已加载过
	-- 		return
	-- 	end

	-- 	self._pageNum = self._pageNum + 1
	-- 	self._viewMgr:lock(-1)
	-- 	for i,tempData in ipairs(insertData) do
	-- 		table.insert(self._data, clone(tempData))
	-- 	    self._tableView:insertCellAtIndex(#self._data-1)
	-- 	end
	-- 	self._viewMgr:unlock()
 --    end
    UIUtils:ccScrollViewUpdateScrollBar(view)
end

function FriendView:tableCellWillRecycle(table,cell)
end

function FriendView:cellSizeForTable(table,idx)
	return self._cellH, self._cellW
end

function FriendView:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell()
	local cellData = self._data[idx + 1]
    if nil == cell then
        cell = require("game.view.friend.FriendCell"):new()
    end
   	local callbackParam = {}
   	callbackParam[1] = function(inId, reqData) self:showUserInfoView(inId, reqData) end

   	if self._curChannel == FriendConst.FRIEND_TYPE.PLATFORM then   --平台好友
   		callbackParam[2] = function(inOpenId) self:reqGetPlatPhy(inOpenId) end
    	callbackParam[3] = function(inOpenId) self:reqSendPlatPhy(inOpenId) end
    	-- callbackParam[4] = function(inOpenId) self:reqPlatRecall(inOpenId) end

    elseif self._curChannel == FriendConst.FRIEND_TYPE.FRIEND then   --好友
    	callbackParam[2] = function(inUsid) self:reqGetSendPhysical(inUsid) end
    	callbackParam[3] = function(inUsid) self:reqSendPhysical(inUsid) end
    	callbackParam[4] = function(inPid, inName) self:reqAddGameFriendToQQ(inPid, inName) end

    elseif self._curChannel == FriendConst.FRIEND_TYPE.ADD then  --处理好友申请
    	callbackParam[2] = function(inUsid, isAccept) self:reqAcceptGameFriend(inUsid, isAccept) end

    elseif self._curChannel == FriendConst.FRIEND_TYPE.APPLY then  --申请加好友
    	callbackParam[2] =  function(inUsid) self:reqApplyGameFriend(inUsid) end

    elseif self._curChannel == FriendConst.FRIEND_TYPE.DELETE then  --删除好友
    	callbackParam[2] =  function(inUsid) self:deleteFriendHandle(inUsid) end
    end
    cell:reflashUI(cellData, self._curChannel, callbackParam, idx)
    return cell   
end

function FriendView:numberOfCellsInTableView(table)
	return #self._data
end

function FriendView:getCellIdx(inID)
	local dataLast = clone(self._friendModel:getDataByType(self._curChannel))
	local index
	for i,v in ipairs(dataLast) do
		if v["usid"] == inID or v["openid"] == inID or v["pid"] == inID then
			index = i
			break
		end
	end

	return index - 1
end

--头像点击
function FriendView:showUserInfoView(inID, reqData)
	local inCallback
	local idx = self:getCellIdx(inID)
	
	if self._curChannel == FriendConst.FRIEND_TYPE.FRIEND or self._curChannel == FriendConst.FRIEND_TYPE.ADD then
		inCallback = function()
			self._data = clone(self._friendModel:getDataByType(self._curChannel))
			self:refreshCurUI()
			-- self._tableView:removeCellAtIndex(idx)

			local offsetLast = self._tableView:getContentOffset()
            self._tableView:reloadData()
            local offsetNew = self._tableView:getContentOffset()

            if offsetNew.y < 0 then   --多于一屏数据
                if offsetLast.y > -128 and offsetNew.y < -128 then 
                    self._tableView:setContentOffset(cc.p(offsetLast.x, offsetLast.y)) --下移
                else
                    self._tableView:setContentOffset(cc.p(offsetLast.x, offsetLast.y + 128))   --上移
                end
            end
		end

	elseif self._curChannel == FriendConst.FRIEND_TYPE.APPLY then
		inCallback = function()
			self._data = clone(self._friendModel:getDataByType(self._curChannel))
			self:refreshCurUI()
			self._tableView:updateCellAtIndex(idx)
		end
	end

	-- 更改接口，获取玩家详情
	local fid = (reqData["lvl"] and reqData["lvl"] >= 15) and 101 or 1
	self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", {tagId = reqData["tagId"], fid = fid, fsec = reqData["fsec"]}, true, {}, function(result) 
		if not result then
			self._viewMgr:showTip("请求数据失败")
			return
		end

		-- dump(result, "getTargetUserBattleInfo", 10)
		if result["tequan"] == nil then
			result["tequan"] = reqData["inTequan"]
		end

		if result["qqVip"] == nil then
			result["qqVip"] = reqData["qqVip"]
		end
		self._viewMgr:showDialog("friend.FriendUserInfoView", {data = result, viewType = self._curChannel,fsec = reqData["fsec"], callback = inCallback}, true)
    end)
end

--平台好友
function FriendView:reqGetPlatPhy(inOpenId)  --get
	local phyLast = self._userModel:getData().physcal
	local idx = self:getCellIdx(inOpenId)

	local curCanGet = self._friendModel:getPhyUperPlat()
	if curCanGet <= 0 then
		self._viewMgr:showTip(lang("FRIEND_12"))
		return
	end
	if phyLast >= tab.setting["PHYSCAL_MAX"].value - 1 then
		self._viewMgr:showTip("当前体力已达上限")
		return
	end
	self._serverMgr:sendMsg("GameFriendServer", "getPlatPhy", {type = 1, aimPid = inOpenId}, true, {}, function(result, error)
		--更新体力
		if not result or not result["d"] then
			self._viewMgr:showTip("请求失败")
			return
		end
		if result.d.dayInfo then
			self._modelMgr:getModel("PlayerTodayModel"):updateDayInfo(result.d.dayInfo)
			result.d.dayInfo = nil
		end
		
		self._modelMgr:getModel("UserModel"):updateUserData(result.d)
		
		local phyDis = 0
		if result.d.physcal then
			phyDis = math.max(math.floor((result.d.physcal - phyLast)/2) * 2, 0)
		end
		self._viewMgr:showTip("领取".. phyDis .."点体力")

		self._friendModel:setPhyUperPlat(phyDis)
		self._friendModel:getPlatPhysical(inOpenId)

		self._data = clone(self._friendModel:getDataByType(self._curChannel))
		self:refreshUI()
		self._tableView:updateCellAtIndex(idx)
		end)
	
end

function FriendView:reqSendPlatPhy(inOpenId)  --send
	local idx = self:getCellIdx(inOpenId)
	self._serverMgr:sendMsg("GameFriendServer", "sendPlatPhy", {type = 1, aimPid = inOpenId}, true, {}, function(result, error)
		-- self._viewMgr:showTip("赠送好友成功")
    	self._friendModel:sendPlatPhysical(inOpenId)
		self._data = clone(self._friendModel:getDataByType(self._curChannel))
		self:refreshCurUI()
		self._tableView:updateCellAtIndex(idx)

		self._viewMgr:showDialog("friend.FriendPhyTipView", {openid = inOpenId}, true)
		end)
end

function FriendView:reqPlatRecall(inOpenId)
	self._viewMgr:showDialog("global.GlobalSelectDialog",
    {   title = lang("HELP_FRIEND_TITLE2"),	
    	desc = lang("HELP_FRIENDTIPS2"),
        button1 = "确定",
        button2 = "取消", 
        callback1 = function ()
           	local idx = self:getCellIdx(inOpenId)
			self._serverMgr:sendMsg("GameFriendServer", "sendRecall", {targetPid = inOpenId}, true, {}, function(result, error)
				self._friendModel:setPlatRecallSuccess(inOpenId, result)
				self._data = clone(self._friendModel:getDataByType(self._curChannel))
				-- dump(result, "sendRecall")
				self:refreshCurUI()

				local numMax = tab.setting["FRIEND_RETURN_GIFT_NUM"].value
				if result["d"] and result["d"]["recall"] and result["d"]["recall"]["num"] >= numMax then
					local offsetLast = self._tableView:getContentOffset()
		            self._tableView:reloadData()
		            local offsetNew = self._tableView:getContentOffset()
		            self._tableView:setContentOffset(cc.p(offsetLast.x, offsetLast.y))
				else
					self._tableView:updateCellAtIndex(idx)
				end

		        local param = {}
		        param.fopenid = inOpenId
		        param.title = lang("HELP_FRIEND_TITLE1")
		        param.desc = lang("HELP_FRIEND_DES1")
		        param.media_tag = sdkMgr.SHARE_TAG.MSG_INVITE
		        sdkMgr:sendToPlatformFriend(param, function(code, data) end)
				
				if result["reward"] then
					DialogUtils.showGiftGet({
			            gifts = result["reward"],
			            callback = function() 
						end})
				end
			end)
        end,
        callback2 = function()
            
        end})
end

--普通好友
function FriendView:reqGetSendPhysical(inUsid)  --get
	local phyLast = self._userModel:getData().physcal
	local idx = self:getCellIdx(inUsid)

	local curCanGet = self._friendModel:getPhysicalUper()
	if curCanGet <= 0 then
		self._viewMgr:showTip(lang("FRIEND_12"))
		return
	end
	if phyLast >= tab.setting["PHYSCAL_MAX"].value - 1 then
		self._viewMgr:showTip("当前体力已达上限")
		return
	end

	self._serverMgr:sendMsg("GameFriendServer", "getSendPhysical", {usid = inUsid}, true, {}, function(result, error)
  		--更新体力
		if not result or not result["d"] or not result.d.dayInfo then
			self._viewMgr:showTip("请求失败")
			return
		end
		self._modelMgr:getModel("PlayerTodayModel"):updateDayInfo(result.d.dayInfo)
		result.d.dayInfo = nil
		self._modelMgr:getModel("UserModel"):updateUserData(result.d)

		local phyDis = 0
		if result.d.physcal then
			phyDis = math.max(math.floor((result.d.physcal - phyLast)/2) * 2, 0)
		end
		self._viewMgr:showTip("领取".. phyDis .."点体力")

		self._friendModel:setPhysicalUper(phyDis)
		self._friendModel:getFriendPhysical(inUsid)

		self._data = clone(self._friendModel:getDataByType(self._curChannel))
		self:refreshUI()
		self._tableView:updateCellAtIndex(idx)
	end)
end

function FriendView:reqSendPhysical(inUsid)    --send
	local idx = self:getCellIdx(inUsid)
	self._serverMgr:sendMsg("GameFriendServer", "sendPhysical", {usid = inUsid}, true, {}, function(result)
		self._viewMgr:showTip("赠送好友成功")
    	self._friendModel:sendFriendPhysical(inUsid)
		self._data = clone(self._friendModel:getDataByType(self._curChannel))
		self:refreshCurUI()
		self._tableView:updateCellAtIndex(idx)
	end)
end

function FriendView:reqAddGameFriendToQQ(inPid, inName) 
	if not inPid or not inName then
		return
	end

	local userData = self._userModel:getData()
	local msg = string.gsub(lang("FRIEND_24"), "{$name}", userData.name or "")

	local param = {}
    param.fopenid = inPid
    param.messages = msg
    param.desc = inName
    sdkMgr:addGameFriendToQQ(param)

    self._friendModel:setAddQQRecord(inPid)
    local idx = self:getCellIdx(inPid)
    self._tableView:updateCellAtIndex(idx)
end

--删除好友
function FriendView:deleteFriendHandle(inUsid)
	local idx = self:getCellIdx(inUsid)
	self._modelMgr:getModel("FriendModel"):setDeleteUsid(inUsid)
	self._data = clone(self._friendModel:getDataByType(self._curChannel))
	self:refreshCurUI()
    self._tableView:updateCellAtIndex(idx)
end

--处理好友申请
function FriendView:reqAcceptGameFriend(inUsid, isAccept)
	if isAccept == 1 then
		local friendNum = #clone(self._friendModel:getDataByType(FriendConst.FRIEND_TYPE.FRIEND))	
		if friendNum >= FriendConst.FRIEND_TOP_NUM then
			self._viewMgr:showTip(lang("FRIEND_7"))
			return
		end
	end

	self._serverMgr:sendMsg("GameFriendServer", "acceptGameFriend", {usid = inUsid, accept = isAccept}, true, {}, function(error, result)
		if isAccept == 1 then
			self._viewMgr:showTip(lang("FRIEND_5"))
		end

    	self._friendModel:dealfriendApply(inUsid, isAccept)
    	self._data = clone(self._friendModel:getDataByType(self._curChannel))
    	self:refreshCurUI()
    	-- dump(self._data)
		-- self._tableView:removeCellAtIndex(idx)

		local offsetLast = self._tableView:getContentOffset()
        self._tableView:reloadData()
        local offsetNew = self._tableView:getContentOffset()

        if offsetNew.y < 0 then   --多于一屏数据
            if offsetLast.y > -128 and offsetNew.y < -128 then 
                self._tableView:setContentOffset(cc.p(offsetLast.x, offsetLast.y)) --下移
            else
                self._tableView:setContentOffset(cc.p(offsetLast.x, offsetLast.y + 128))   --上移
            end
        end
	end)
end

--申请加好友
function FriendView:reqApplyGameFriend(inUsid)
	local friendNum = #clone(self._friendModel:getDataByType(FriendConst.FRIEND_TYPE.FRIEND))	
	if friendNum >= FriendConst.FRIEND_TOP_NUM then
		self._viewMgr:showTip(lang("FRIEND_7"))
		return
	end

	local idx = self:getCellIdx(inUsid)
	self._serverMgr:sendMsg("GameFriendServer", "applyGameFriend", {usid = inUsid}, true, {}, function(result, error)
    	self._friendModel:applyAddFriend(inUsid)
    	self._data = clone(self._friendModel:getDataByType(self._curChannel))
    	self:refreshCurUI()
    	self._tableView:updateCellAtIndex(idx)
	end)
end

function FriendView:onBeforeAdd(callback, errorCallback)
	local chatOpen = tab.systemOpen["GameFriend"]
	local userModelData = self._userModel:getData()
    if userModelData.lvl < chatOpen[1] then
    	errorCallback()
    	self._viewMgr:unlock(51)
    	self._viewMgr:showTip(lang(chatOpen[3]))
        return
    end

    callback()
end

function FriendView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{title = "globalTitleUI_friend.png",titleTxt = "好友"})
end

function FriendView:getAsyncRes()
    return {{"asset/ui/friend.plist", "asset/ui/friend.png"}}
end

function FriendView:getBgName()
    return "bg_007.jpg"
end

function FriendView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end


return FriendView