--[[
    Filename:    ChatPrivateUserCell.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-05-20 17:19
    Description: 私聊左侧人物cell
--]]
local ChatPrivateUserCell = class("ChatPrivateUserCell", cc.TableViewCell)

function ChatPrivateUserCell:ctor()
    -- ChatPrivateUserCell.super.ctor(self)
    self._viewMgr = ViewManager:getInstance()
    self._modelMgr = ModelManager:getInstance()
end


function ChatPrivateUserCell:onInit()

end

function ChatPrivateUserCell:reflashUI(userData, isClick, isUnread, inCallback)
	self:setContentSize(cc.size(250, 125))
	self._userData = userData

	--当前聊天 高亮
	if self._showMark == nil then
		self._showMark = ccui.ImageView:create()
		self._showMark:setAnchorPoint(cc.p(0.5, 0.5))
		self._showMark:setPosition(cc.p(self:getContentSize().width/2 , self:getContentSize().height/2))
		self._showMark:ignoreContentAdaptWithSize(false)
		self._showMark:setContentSize(self:getContentSize().width + 10, self:getContentSize().height + 10)
		self._showMark:setVisible(false)
		self:addChild(self._showMark, 10)
	end
	self._showMark:loadTexture("chatPri_light.png", 1)  --252/116
	if isClick == true then
		self._showMark:setVisible(true)
	else
		self._showMark:setVisible(false)
	end

	--名片区域
	if self._layout == nil then   
		self._layout = ccui.Widget:create()  
		self._layout:setContentSize(cc.size(250, 135)) --233/98
		self._layout:setAnchorPoint(cc.p(0.5, 0.5))
		self._layout:setPosition(cc.p(self:getContentSize().width/2 , self:getContentSize().height/2))
		self:addChild(self._layout)
	end

	--名片背景
	if self._bg == nil then
		self._bg = ccui.ImageView:create()
		self._bg:loadTexture("globalPanelUI7_cellBg1.png", 1)
		self._bg:setScale9Enabled(true)
		self._bg:setCapInsets(cc.rect(41, 41, 1, 1))
		self._bg:setContentSize(cc.size(260, 135))
		self._bg:ignoreContentAdaptWithSize(false)
		self._bg:setPosition(cc.p(self._layout:getContentSize().width/2, self._layout:getContentSize().height/2))
		self._layout:addChild(self._bg)
	end

	--名字
	if self._nameLab == nil then
		self._nameLab = ccui.Text:create()
		self._nameLab:setString(userData["user"].name or " ")
		self._nameLab:setFontName(UIUtils.ttfName)
		UIUtils:setTitleFormat(self._nameLab, 2)
		self._nameLab:setFontSize(20)
		self._nameLab:setAnchorPoint(cc.p(0,0.5))
		self._nameLab:setPosition(87, 85)
		self._layout:addChild(self._nameLab, 2)
	else
		self._nameLab:setString(userData["user"].name)
	end

	-- --名字背景
	-- if self._nameBg == nil then
	-- 	self._nameBg = ccui.ImageView:create()
	-- 	self._nameBg:loadTexture("globalPanelUI7_subInner2TitleBg.png", 1)
	-- 	self._nameBg:setScale9Enabled(true)
	-- 	self._nameBg:setCapInsets(cc.rect(19, 17, 1, 1))
	-- 	self._nameBg:setAnchorPoint(cc.p(0, 0.5))
	-- 	self._nameBg:ignoreContentAdaptWithSize(false)
	-- 	self._nameBg:setOpacity(150)
	-- 	self._nameBg:setPosition(38 , 80)
	-- 	self._layout:addChild(self._nameBg)
	-- end
	-- local dis = math.max(self._nameLab:getContentSize().width - 141, 0)
 --    self._nameBg:setContentSize(200 + dis, 34)

	--头像
	if self._headIcon == nil then
		if self._userData["user"].rid == "bug_op" then
			self._headIcon = IconUtils:createHeadIconById({art = "ti_xiaojingling", level = 0, tp = 4, avatarFrame=userData["user"]["avatarFrame"]})
		else
			self._headIcon = IconUtils:createHeadIconById({avatar = userData["user"].avatar, tp = 4, avatarFrame=userData["user"]["avatarFrame"]})
		end
		self._headIcon:setScale(0.73)
		self._headIcon:setAnchorPoint(cc.p(0, 0.5))
		self._headIcon:setPosition(13, self._layout:getContentSize().height/2)  --18
		self._layout:addChild(self._headIcon)
	else
		IconUtils:updateHeadIconByView(self._headIcon,{avatar = userData["user"].avatar, tp = 4,avatarFrame=userData["user"]["avatarFrame"]})
	end

	registerClickEvent(self._headIcon, function() 
		local curPriId = self._modelMgr:getModel("ChatModel"):getCacheUserData().rid
		if curPriId ~= self._userData["user"]["rid"] then
			return
		end

		if self._userData["user"].rid == "bug_op" then
			return
		end

		if self._userData["user"].userType == "arena" then
			ServerManager:getInstance():sendMsg("ArenaServer", "getDetailInfo", {roleId = self._userData["user"]["rid"]}, true, {}, function(result) 
                local info = result.info
                info.battle.msg = info.msg
                info.battle.rank = info.rank
                if self._viewMgr then
                	self._viewMgr:showDialog("chat.DialogFriendHandle",
                		{detailData = info.battle, openType = "private", isFakeNpc = true, callback = inCallback}, true)
                end
            	end)

		else
			local fId = (self._userData["user"].lvl and self._userData["user"].lvl >= 15) and 101 or 1
            ServerManager:getInstance():sendMsg("UserServer", "getTargetUserBattleInfo", {tagId = self._userData["user"]["rid"], fid = fId, fsec = self._userData["user"]["sec"]}, true, {}, function(result)                 
                if self._viewMgr then
                    self._viewMgr:showDialog("chat.DialogFriendHandle", 
                    	{detailData = result, openType = "private", callback = inCallback}, true)
                end
            	end)
		end
	end)
	self._headIcon:setSwallowTouches(false)
	local curPriId = self._modelMgr:getModel("ChatModel"):getCacheUserData().rid
	if curPriId ~= self._userData["user"]["rid"] then
		self._headIcon:setTouchEnabled(false)
	else
		self._headIcon:setTouchEnabled(true)
	end


	--lv
	if self._userData["user"].rid ~= "bug_op" then
		if self._lvLab == nil then
			self._lvLab = cc.Label:createWithTTF("Lv." .. userData["user"].lvl, UIUtils.ttfName, 20)
			self._lvLab:setColor(cc.c4b(134, 92, 48, 255))
			self._lvLab:setAnchorPoint(cc.p(0,0.5))
			self._lvLab:setPosition(87, 44)
			self._layout:addChild(self._lvLab)
		else
			self._lvLab:setString("Lv." .. userData["user"].lvl)
		end
	end
	
	--未读标志 红点
	if self._unreadMark == nil then
		self._unreadMark = ccui.ImageView:create()
		self._unreadMark:loadTexture("globalImageUI_bag_keyihecheng.png", 1)
		self._unreadMark:setPosition(cc.p(237, 117))
		self._layout:addChild(self._unreadMark)
	end
	if isUnread == true then
		self._unreadMark:setVisible(true)
	else
		self._unreadMark:setVisible(false)
	end

	--GM标志
	if self._userData["user"].rid == "bug_op" then
		if self._gmMark == nil then
			self._gmMark = cc.Label:createWithTTF("GM", UIUtils.ttfName, 18)
			self._gmMark:setColor(cc.c4b(249, 212, 37, 255))
			self._gmMark:enable2Color(1,cc.c4b(255,154,49,255))
			self._gmMark:enableOutline(cc.c4b(60, 30, 10, 255), 1)
			self._gmMark:setAnchorPoint(cc.p(0,0.5))
			self._gmMark:setPosition(54, 35)
			self._layout:addChild(self._gmMark, 10)
		end
	else
		if self._gmMark ~= nil then
			self._gmMark:removeFromParent(true)
		end
	end
	
end

--[[
--! @function switchListItemState
--! @desc 切换list item 选中状态
--! @param sender object 操作list item
--! @param isSelected bool 是否选中
--! @return 
--]]
function ChatPrivateUserCell:switchListItemState(isSelected)
    if isSelected then 
    	self._showMark:setVisible(true)   --高亮
    	if self._unreadMark:isVisible() then
            self._unreadMark:setVisible(false)  --红点
            self._modelMgr:getModel("ChatModel"):removePriUnread(self._userData["user"].rid)
        end
        self._headIcon:setTouchEnabled(true)
        self._headIcon:setSwallowTouches(true)
        -- self._headIcon:setSwallowTouches(true)
    else
    	self._showMark:setVisible(false)
    	self._headIcon:setTouchEnabled(false)
    	self._headIcon:setSwallowTouches(false)
    end
end

return ChatPrivateUserCell