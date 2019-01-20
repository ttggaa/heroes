--[[
    Filename:    FriendCell.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-07-26 16:49
    Description: 好友cell
--]]

local FriendCell = class("FriendCell", cc.TableViewCell)

function FriendCell:ctor()
    self._viewMgr = ViewManager:getInstance()
    self._modelMgr = ModelManager:getInstance()
    require("game.view.friend.FriendConst")
    self._friendModel = self._modelMgr:getModel("FriendModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._userModelData = self._modelMgr:getModel("UserModel"):getData()
    self._versionT = TimeUtils.getIntervalByTimeString(tab.setting["FRIEND_BACK_TIME"].value)

    self._gameEle = {}
    self._platformEle = {}
end

function FriendCell:onInit()

end

function FriendCell:reflashUI(userData, inType, callback, idx)
	if not userData or next(userData) == nil then
		return
	end

	self:setContentSize(cc.size(739, 120))
	self._data = userData
	self._callback = callback

	-- self._data["tequan"] = "sq_gamecenter"
	-- dump(userData, "123", 10)

	if self._bg == nil then
		self._bg = ccui.ImageView:create("globalPanelUI7_cellBg1.png", 1)
		self._bg:setScale9Enabled(true)
		self._bg:setCapInsets(cc.rect(41, 41, 1, 1))
		self._bg:ignoreContentAdaptWithSize(false)
		self._bg:setContentSize(self:getContentSize().width + 8, self:getContentSize().height + 8)
		self._bg:setPosition(cc.p(self:getContentSize().width*0.5, self:getContentSize().height*0.5))
		self:addChild(self._bg)
	else
		self._bg:loadTexture("globalPanelUI7_cellBg1.png", 1)
	end 

	-- if self._mask == nil then
	-- 	self._mask = ccui.Layout:create()
	-- 	self._mask:setAnchorPoint(cc.p(0.5, 0.5))
	--     self._mask:setBackGroundColorOpacity(100)
	--     self._mask:setBackGroundColorType(1)
	--     self._mask:setBackGroundColor(cc.c3b(100, 100, 0))
	--     self._mask:setContentSize(self:getContentSize().width, self:getContentSize().height)
	--     self._mask:setPosition(self:getContentSize().width*0.5, self:getContentSize().height*0.5)
	--     self:addChild(self._mask)
	-- end

    --名字
	if self._nameLab == nil then
		self._nameLab = ccui.Text:create()
		self._nameLab:setString(userData["name"] or " ")
		self._nameLab:setFontName(UIUtils.ttfName)
        self._nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        self._nameLab:setFontSize(24)
		self._nameLab:setAnchorPoint(cc.p(0,0.5))
		self:addChild(self._nameLab, 2)
	else
		self._nameLab:setString(userData["name"] or " ")
	end  

	--分隔符
	if self._disImg == nil then
		self._disImg = ccui.ImageView:create("globalImageUI12_cutline1.png", 1)
		self._disImg:setScale9Enabled(true)
		self._disImg:setCapInsets(cc.rect(1, 12, 1, 1))
		self._disImg:ignoreContentAdaptWithSize(false)
		self:addChild(self._disImg)
	end 

	--vip
    userData.vipLvl = userData.vipLvl or 0
    if self._vipImg == nil then
        self._vipImg = cc.Sprite:createWithSpriteFrameName("chatPri_vipLv"..math.max(1, userData.vipLvl)..".png")  
        self:addChild(self._vipImg)
    else
        self._vipImg:setSpriteFrame("chatPri_vipLv".. math.max(1, userData.vipLvl) ..".png")
    end
    -- dump(userData,"userData=============")
    local isHideVip = UIUtils:isHideVip(userData.hideVip,"friend")
    self._vipImg:setVisible((userData.vipLvl > 0) and not isHideVip)

	----------------------------------------------
	-- 元件显示/隐藏 及位置调整
	local isPlatform = inType == FriendConst.FRIEND_TYPE.PLATFORM
	for i,v in ipairs(self._platformEle) do
		v:setVisible(isPlatform)
	end
	for i,v in ipairs(self._gameEle) do
		v:setVisible(not isPlatform)
	end
	if isPlatform then	--平台好友cell
		self:reflashPlatformUI(userData, inType, callback, idx)   	
	else
		self:reflashOtherUI(userData, inType, callback, idx)  		
	end

	----------------------------------------------------
	-- 按钮事件处理
	if inType == FriendConst.FRIEND_TYPE.PLATFORM then
		self:reflashPlatFriendBtns(inType)

	elseif inType == FriendConst.FRIEND_TYPE.FRIEND then
		self:reflashCommonFriendBtns(inType)

	elseif inType == FriendConst.FRIEND_TYPE.ADD then
		self:reflashAddBtns()

	elseif inType == FriendConst.FRIEND_TYPE.APPLY then
		self:reflashApplyBtns()

	elseif inType == FriendConst.FRIEND_TYPE.DELETE then
		self:reflashDeleteBtns()
	end
end

function FriendCell:reflashPlatformUI(userData, inType, callback, idx)
	self._nameLab:setPosition(210, 86) 
	self._vipImg:setPosition(475, 86)
	self._disImg:setPosition(387, 86)

	local nameSub = userData["nickName"] or " "
	if utf8.len(nameSub) > 7 then
		nameSub = utf8.sub(nameSub, 1, 6) .. "..."
	end
	self._nameLab:setString(nameSub)

    --头像
	if not self._avatarP then
        self._avatarP = IconUtils:createUrlHeadIconById({name = self._data["nickName"], url = self._data["picUrl"], openid = self._data["openid"], tencetTp = self._data["qqVip"], tp = 4})
        self._avatarP:setAnchorPoint(0, 0.5)
        self._avatarP:setPosition(105, self:getContentSize().height*0.5 - 1)
        self:addChild(self._avatarP, 2)

        registerClickEvent(self._avatarP, function() 
			if self._callback then
				local callParam = {tagId = self._data["rid"] or self._data["_id"],  lvl = (self._data["level"] or 0), fsec = self._data.sec, inTequan = self._data["tequan"]}
				self._callback[1](self._data["openid"], callParam)
			end
		end)
    else
        IconUtils:updateUrlHeadIconByView(self._avatarP,{name = self._data["nickName"], url = self._data["picUrl"], openid = self._data["openid"], tencetTp = self._data["qqVip"], tp = 4})  
    end

    --lv
	if self._lvLabP == nil then
		self._lvLabP = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
		self._lvLabP:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
		self._lvLabP:setAnchorPoint(cc.p(0,0.5))
		self._lvLabP:setPosition(400, 86) 
		self:addChild(self._lvLabP)
		table.insert(self._platformEle, self._lvLabP)
	end
	local inParam = {lvlStr = "Lv." .. (userData["level"] or 0), lvl = userData["lvl"], plvl = userData["plvl"]}
	UIUtils:adjustLevelShow(self._lvLabP, inParam, 1)

	--排名
	local rankImgData = {"arenaRank_first.png","arenaRank_second.png","arenaRank_third.png"}
	if self._rank ~= nil then
		self._rank:removeFromParent(true)
		self._rank = nil
	end
	if idx + 1 <= 3 then
		self._rank = ccui.ImageView:create(rankImgData[idx + 1],1)
	    self._rank:setPosition(cc.p(60,self:getContentSize().height*0.5)) --58
	    self._rank:setAnchorPoint(cc.p(0.5,0.5))	
		self:addChild(self._rank)
	else
		self._rank = cc.Label:createWithBMFont(UIUtils.bmfName_rank, "00")
		self._rank:setString(idx + 1)
		self._rank:setAnchorPoint(cc.p(0.5,0))  
	    self._rank:setPosition(cc.p(60,self:getContentSize().height*0.5))  --47
	    self:addChild(self._rank)
	end
	-- table.insert(self._platformEle, self._rank)	

	--本人标签
	if self._selfMark == nil then
		self._selfMark = ccui.ImageView:create("arenaRankUI_selfTag.png",1)
	    self._selfMark:setPosition(cc.p(5,self:getContentSize().height - 4)) --58
	    self._selfMark:setAnchorPoint(cc.p(0,1))	
		self:addChild(self._selfMark)
	end
	self._selfMark:setVisible(userData.rid == self._userModelData._id)

	--主线名
	if userData.storyId == 0 then 
		userData.storyId = nil
	end
	local sysStage = tab:MainStage(tonumber(userData.storyId or 7100101))
	if sysStage ~= nil then 
		stageName = "主线 " .. lang(sysStage.title)
	else
		stageName = "主线 "
	end

	if self._mainLine == nil then
		self._mainLine = cc.Label:createWithTTF("主线：", UIUtils.ttfName, 18)
		self._mainLine:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
		self._mainLine:setPosition(210, 60) 
		self._mainLine:setAnchorPoint(cc.p(0,0.5))
		self:addChild(self._mainLine)
		table.insert(self._platformEle, self._mainLine)	
	end
	
	if self._mainLineDes == nil then
		self._mainLineDes = cc.Label:createWithTTF(lang(sysStage.title), UIUtils.ttfName, 18)
		self._mainLineDes:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
		self._mainLineDes:setPosition(255, 60) 
		self._mainLineDes:setAnchorPoint(cc.p(0,0.5))
		self:addChild(self._mainLineDes)
		table.insert(self._platformEle, self._mainLineDes)	
	else
		self._mainLineDes:setString(lang(sysStage.title))
	end

	--服务器名
	if self._server == nil then
		self._server = cc.Label:createWithTTF("服务器：", UIUtils.ttfName, 18)
		self._server:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
		self._server:setPosition(210, 35) 
		self._server:setAnchorPoint(cc.p(0,0.5))
		self:addChild(self._server)
		table.insert(self._platformEle, self._server)	
	end
	if self._serverDes == nil then
		self._serverDes = cc.Label:createWithTTF(userData.secName or "无", UIUtils.ttfName, 18)
		self._serverDes:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
		self._serverDes:setPosition(272, 35) 
		self._serverDes:setAnchorPoint(cc.p(0,0.5))
		self:addChild(self._serverDes)
		table.insert(self._platformEle, self._serverDes)	
	else
		self._serverDes:setString(userData.secName or "无")
	end
end

function FriendCell:reflashOtherUI(userData, inType, callback, idx)
	self._nameLab:setPosition(116, 86)  --117
	self._nameLab:setString(userData["name"] or " ")
	self._vipImg:setPosition(385, 86)   --400
    self._disImg:setPosition(291, 86)

    --头像
    local headP = {avatar = userData["avatar"], tp = 4,avatarFrame = userData["avatarFrame"], tencetTp = userData["qqVip"], plvl = userData["plvl"]}
	if not self._avatar then
		local tencetTp = self._modelMgr:getModel("TencentPrivilegeModel"):getQQVip()
        self._avatar = IconUtils:createHeadIconById(headP)   
        self._avatar:setAnchorPoint(0, 0.5)
        self._avatar:setPosition(17, self:getContentSize().height*0.5 - 1)
        self:addChild(self._avatar, 2)

        registerClickEvent(self._avatar, function() 
			if self._callback then
				local callParam = {tagId = self._data["rid"] or self._data["_id"], lvl = (self._data["lvl"] or 0), inTequan = self._data["tequan"]}
				self._callback[1](self._data["usid"], callParam)
			end
		end)
    else
    	local tencetTp = self._modelMgr:getModel("TencentPrivilegeModel"):getQQVip()
        IconUtils:updateHeadIconByView(self._avatar, headP) 
    end

    --lv
	if self._lvLab == nil then
		self._lvLab = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
		self._lvLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
		self._lvLab:setAnchorPoint(cc.p(0,0.5))
		self._lvLab:setPosition(302, 86)
		self:addChild(self._lvLab)
		table.insert(self._gameEle, self._lvLab)
	end
	local inParam = {lvlStr = "Lv." .. (userData["lvl"] or 0), lvl = userData["lvl"], plvl = userData["plvl"]}
	UIUtils:adjustLevelShow(self._lvLab, inParam, 1)

    --战斗力
	if self._battleLab == nil then
		self._battleLab = ccui.Text:create()
		self._battleLab:setString("战斗力")
		self._battleLab:setAnchorPoint(cc.p(0,0))
		self._battleLab:setPosition(117, 27) --19
		self._battleLab:setFontName(UIUtils.ttfName)
		self._battleLab:setFontSize(18)
		self._battleLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
		self:addChild(self._battleLab)
		table.insert(self._gameEle, self._battleLab)	
	end

	--战斗力值
	if self._battleNum == nil then
		self._battleNum = ccui.Text:create()
		self._battleNum:setString(userData["score"] or 0)
		self._battleNum:setAnchorPoint(cc.p(0,0))
		self._battleNum:setPosition(175, 24) --19
		self._battleNum:setFontName(UIUtils.ttfName)
		self._battleNum:setFontSize(22)
		self._battleNum:setColor(UIUtils.colorTable.ccUIMenuBtnColor1)
		self._battleNum:enable2Color(1, UIUtils.colorTable.ccUIMenuBtnColor2)
		self._battleNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
		self:addChild(self._battleNum)
		table.insert(self._gameEle, self._battleNum)	
	else
		self._battleNum:setString(userData["score"] or 0)
	end
	
	--login1
	if self._loginLab11 == nil then
		self._loginLab11 = cc.Label:createWithTTF("登录:", UIUtils.ttfName, 20)
		self._loginLab11:setAnchorPoint(cc.p(0,0)) 
		self._loginLab11:setPosition(300, 27)  --23 
		self._loginLab11:setColor(UIUtils.colorTable.ccUIBaseTextColor2) 
		self:addChild(self._loginLab11)
		table.insert(self._gameEle, self._loginLab11)
	end

	--login
	if self._loginLab == nil then
		self._loginLab = cc.Label:createWithTTF(loginDes, UIUtils.ttfName, 20)
		self._loginLab:setAnchorPoint(cc.p(0,0)) 
		self._loginLab:setPosition(355, 27)  --23  
		self:addChild(self._loginLab)
		table.insert(self._gameEle, self._loginLab)
	end
	local disNum = userData["_lt"] and self._modelMgr:getModel("UserModel"):getCurServerTime() - userData["_lt"] or 10000000
	local loginDes 
	if userData["online"] and userData["online"] == 1 then
    	loginDes = "在线"
    	self._loginLab:setColor(cc.c4b(63, 125, 0, 255))
    else
    	loginDes = TimeUtils:getTimeDisByFormat(disNum) .. "前"
    	self._loginLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    end
    self._loginLab:setString(loginDes)
end

--平台 / 游戏好友界面
function FriendCell:reflashFriendBtns(inType)
	--领取
	if self._getBtn == nil then
		self._getBtn = ccui.Button:create("friend_getBtn.png", "friend_getBtn.png", "", 1)
		self._getBtn:setPosition(cc.p(595, self:getContentSize().height*0.5))
		self._getBtn:setScale(0.9)
		self:addChild(self._getBtn)
		if inType == FriendConst.FRIEND_TYPE.FRIEND then
			table.insert(self._gameEle, self._getBtn)
		else
			table.insert(self._platformEle, self._getBtn)
		end
		
		registerClickEvent(self._getBtn, function() 
			if self._callback then
				if inType == FriendConst.FRIEND_TYPE.FRIEND then
					self._callback[2](self._data["usid"])
				else
					self._callback[2](self._data["openid"])
				end
			end
		end)
	end

	--赠送
	if self._giveBtn == nil then
		self._giveBtn = ccui.Button:create("friend_giveBtn.png", "friend_giveBtn.png", "", 1)
		self._giveBtn:setPosition(cc.p(685, self:getContentSize().height*0.5))
		self._giveBtn:setScale(0.9)
		self:addChild(self._giveBtn)
		if inType == FriendConst.FRIEND_TYPE.FRIEND then
			table.insert(self._gameEle, self._giveBtn)
		else
			table.insert(self._platformEle, self._giveBtn)
		end

		registerClickEvent(self._giveBtn, function() 
			if self._callback then
				if inType == FriendConst.FRIEND_TYPE.FRIEND then
					self._callback[3](self._data["usid"])
				else
					self._callback[3](self._data["openid"])
				end
				
			end
		end)
	end

	--已赠送
	if self._hasGiveImg == nil then
		self._hasGiveImg = ccui.ImageView:create("friend_haveGiveImg.png", 1)
		self._hasGiveImg:setPosition(cc.p(685, self:getContentSize().height*0.5))
		self._hasGiveImg:setScale(0.9)
		self:addChild(self._hasGiveImg)
		if inType == FriendConst.FRIEND_TYPE.FRIEND then
			table.insert(self._gameEle, self._hasGiveImg)
		else
			table.insert(self._platformEle, self._hasGiveImg)
		end
	end

	--启动特权类型
	-- self._data["tequan"] = "wx_gamecenter"
	local tequanImg = FriendConst.TEQUAN_TYPE[self._data["tequan"]] or "globalImageUI6_meiyoutu.png"
	if self._tequan == nil then
		self._tequan = ccui.ImageView:create(tequanImg, 1)
		self:addChild(self._tequan)
		registerClickEvent(self._tequan,function( )
            self._viewMgr:showDialog("tencentprivilege.TencentPrivilegeView")
        end)
		if inType == FriendConst.FRIEND_TYPE.FRIEND then
			table.insert(self._gameEle, self._tequan)
		else
			table.insert(self._platformEle, self._tequan)
		end
	else
		self._tequan:loadTexture(tequanImg, 1)
	end
	
	self._getBtn:setVisible(false)
	self._giveBtn:setVisible(false)
	self._hasGiveImg:setVisible(false)

	if self._data.rid ~= self._userModelData._id then
		if self._data["getPhy"] == 1 then   --未收取1 没赠送0  已领取2
			self._getBtn:setVisible(true)
		end

		if self._data["sendPhy"] == 0 then  --可赠送0 已赠送1
			self._giveBtn:setVisible(true)
		else
			self._hasGiveImg:setVisible(true)
		end
	end
end

--普通好友
function FriendCell:reflashCommonFriendBtns(inType)
	--领取/赠送/已赠送
	self:reflashFriendBtns(inType)
	self._getBtn:setPositionX(628)
	self._getBtn:setScale(0.78)
	self._giveBtn:setPositionX(695)
	self._giveBtn:setScale(0.78)
	self._hasGiveImg:setPositionX(695)
	self._hasGiveImg:setScale(0.78)

	--特权
	self._tequan:setScale(0.9)
	self._tequan:setPosition(cc.p(472, self:getContentSize().height*0.5 + 25))

	--一键加好友
	if self._addFriBtn == nil then
		self._addFriBtn = ccui.Button:create("friend_applyBtn.png", "friend_applyBtn.png", "", 1)
		self._addFriBtn:setScale(0.78)
		self:addChild(self._addFriBtn)
		table.insert(self._gameEle, self._addFriBtn)

		registerClickEvent(self._addFriBtn, function() 
			if self._callback then
				self._callback[4](self._data["pid"], self._data["nickName"])
			end
		end)
	end
	self._addFriBtn:setVisible(false)
	if self._getBtn:isVisible() then
		self._addFriBtn:setPosition(cc.p(561, self:getContentSize().height*0.5))
	else
		self._addFriBtn:setPosition(cc.p(628, self:getContentSize().height*0.5))
	end

	local timeCheck = self._friendModel:isCanAddQQFriend(self._data["pid"])
	if CPP_VERSION > 212 and sdkMgr:isQQ() and self._data.rid ~= self._userModelData._id 
		and self._data["isPlatFri"] == 0 and timeCheck then
		self._addFriBtn:setVisible(true)
	end

	--背景条
	if self._data.rid ~= self._userModelData._id and 
	 (self._data["getPhy"] == 0 or self._data["getPhy"] == 2) and 
	 self._data["sendPhy"] == 1 then
		self._bg:loadTexture("globalPanelUI7_cellBg2.png", 1)
	end
end

--平台好友
function FriendCell:reflashPlatFriendBtns(inType)
	--领取/赠送/已赠送
	self:reflashFriendBtns(inType)

	--特权
	self._tequan:setPosition(cc.p(465, self:getContentSize().height*0.5 - 10))

	if self._data.rid ~= self._userModelData._id then
		if (self._data["getPhy"] == 0 or self._data["getPhy"] == 2) and 
			self._data["sendPhy"] == 1 then
			self._bg:loadTexture("globalPanelUI7_cellBg2.png", 1)
		end
	end
end

--删除界面
function FriendCell:reflashDeleteBtns()
	if self._selectBg == nil then
		self._selectBg = ccui.ImageView:create("friend_selectBg.png", 1)
		self._selectBg:setPosition(cc.p(655, self:getContentSize().height*0.5))
		self:addChild(self._selectBg)
		table.insert(self._gameEle, self._selectBg)
		registerClickEvent(self._selectBg, function() 
			if self._callback then
				self._callback[2](self._data["usid"])
			end
		end)
	end

	if self._selectImg == nil then
		self._selectImg = ccui.ImageView:create("friend_selectImg.png", 1)
		self._selectImg:setPosition(cc.p(self._selectBg:getContentSize().width*0.5, self._selectBg:getContentSize().height*0.5))
		self._selectBg:addChild(self._selectImg)
		table.insert(self._gameEle, self._selectImg)
	end

	--启动特权类型
	local tequanImg = FriendConst.TEQUAN_TYPE[self._data["tequan"]] or "globalImageUI6_meiyoutu.png"
	if self._tequan == nil then
		self._tequan = ccui.ImageView:create(tequanImg, 1)
		self._tequan:setPosition(cc.p(480, self:getContentSize().height*0.5 + 25))
		self:addChild(self._tequan)
		table.insert(self._gameEle, self._tequan)

		registerClickEvent(self._tequan,function( )
            self._viewMgr:showDialog("tencentprivilege.TencentPrivilegeView")
        end)
	else
		self._tequan:loadTexture(tequanImg, 1)
	end

	local isSelected = self._modelMgr:getModel("FriendModel"):getDeleteUsid(self._data["usid"])
	self._selectImg:setVisible(isSelected)
end

--申请界面
function FriendCell:reflashAddBtns()
	if self._rejectBtn == nil then
		self._rejectBtn = ccui.Button:create()
		self._rejectBtn:loadTextures("globalButtonUI13_3_2.png", "globalButtonUI13_3_2.png", "", 1)
		self._rejectBtn:setTitleText("拒绝")
		self._rejectBtn:setScale(0.8)
		self._rejectBtn:setPosition(cc.p(475 + self._rejectBtn:getContentSize().width*0.5, self:getContentSize().height*0.5 - 13))
		self._rejectBtn:setTitleFontName(UIUtils.ttfName)
		self._rejectBtn:setTitleColor(UIUtils.colorTable.ccUICommonBtnColor2)
		self._rejectBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine2, 2)
		self._rejectBtn:setTitleFontSize(24)	
		self:addChild(self._rejectBtn)
		table.insert(self._gameEle, self._rejectBtn)
		registerClickEvent(self._rejectBtn, function()
			if self._callback then
				self._callback[2](self._data["usid"], 0)
			end
		end)
	end

	if self._agreeBtn == nil then
		self._agreeBtn = ccui.Button:create()
		self._agreeBtn:loadTextures("globalButtonUI13_1_2.png", "globalButtonUI13_1_2.png", "", 1)
		self._agreeBtn:setTitleText("同意")
		self._agreeBtn:setPosition(cc.p(603 + self._agreeBtn:getContentSize().width*0.5, self:getContentSize().height*0.5 - 13))
		self._agreeBtn:setTitleFontName(UIUtils.ttfName)
		self._agreeBtn:setScale(0.8)
		self._agreeBtn:setTitleColor(UIUtils.colorTable.ccUICommonBtnColor1)
		self._agreeBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine1, 2)
		self._agreeBtn:setTitleFontSize(24)	
		self:addChild(self._agreeBtn)
		table.insert(self._gameEle, self._agreeBtn)
		registerClickEvent(self._agreeBtn, function()
			if self._callback then
				self._callback[2](self._data["usid"], 1)
			end
		end)
	end

	--启动特权类型
	local tequanImg = FriendConst.TEQUAN_TYPE[self._data["tequan"]] or "globalImageUI6_meiyoutu.png"
	if self._tequan == nil then
		self._tequan = ccui.ImageView:create(tequanImg, 1)
		self._tequan:setPosition(cc.p(480, self:getContentSize().height*0.5 + 25))
		self:addChild(self._tequan)
		table.insert(self._gameEle, self._tequan)

		registerClickEvent(self._tequan,function( )
            self._viewMgr:showDialog("tencentprivilege.TencentPrivilegeView")
        end)
	else
		self._tequan:loadTexture(tequanImg, 1)
	end
end

--添加界面
function FriendCell:reflashApplyBtns()
	if self._applyBtn == nil then
		self._applyBtn = ccui.Button:create("globalButtonUI13_1_2.png", "globalButtonUI13_1_2.png", "", 1)
		self._applyBtn:setPosition(cc.p(655, self:getContentSize().height*0.5 - 3))
		self._applyBtn:setTitleText("申请")
		self._applyBtn:setScale(0.8)
		self._applyBtn:setTitleFontName(UIUtils.ttfName)
		self._applyBtn:setTitleColor(UIUtils.colorTable.ccUICommonBtnColor1)
		self._applyBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine1, 2)
		self._applyBtn:setTitleFontSize(24)	
		self:addChild(self._applyBtn)
		table.insert(self._gameEle, self._applyBtn)
		registerClickEvent(self._applyBtn, function()
			if self._callback then
				self._callback[2](self._data["usid"])
			end
		end)
	end

	--已申请
	if self._hadApply == nil then
		self._hadApply = ccui.ImageView:create("friend_hadApply.png", 1)
		self._hadApply:setPosition(cc.p(655, self:getContentSize().height*0.5))
		self:addChild(self._hadApply)
		table.insert(self._gameEle, self._hadApply)
	end

	--启动特权类型
	local tequanImg = FriendConst.TEQUAN_TYPE[self._data["tequan"]] or "globalImageUI6_meiyoutu.png"
	if self._tequan == nil then
		self._tequan = ccui.ImageView:create(tequanImg, 1)
		self._tequan:setPosition(cc.p(480, self:getContentSize().height*0.5 + 25))
		self:addChild(self._tequan)
		table.insert(self._gameEle, self._tequan)

		registerClickEvent(self._tequan,function( )
            self._viewMgr:showDialog("tencentprivilege.TencentPrivilegeView")
        end)
	else
		self._tequan:loadTexture(tequanImg, 1)
	end
	
	if self._data["sendApply"] == 0 then  --未申请0  已申请1   
		self._applyBtn:setVisible(true)
		self._hadApply:setVisible(false)
	else
		self._applyBtn:setVisible(false)
		self._hadApply:setVisible(true)
		self._bg:loadTexture("globalPanelUI7_cellBg2.png", 1)
	end	
end

return FriendCell

