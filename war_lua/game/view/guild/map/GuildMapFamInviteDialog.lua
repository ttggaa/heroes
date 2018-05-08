--[[
    Filename:    GuildMapFamInviteDialog.lua
    Author:      <lannan@playcrab.com>
    Datetime:    2016-04-27 21:29:47
    Description: File description
--]]

local GuildMapFamInviteDialog = class("GuildMapFamInviteDialog", BasePopView)

function GuildMapFamInviteDialog:ctor(data)
    GuildMapFamInviteDialog.super.ctor(self)
	self._gridKey = data.gridKey
end

function GuildMapFamInviteDialog:onInit()
	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn, function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("guild.map.GuildMapFamInviteDialog")
        end
		self:close()
	end)
	local guildInviteBtn = self:getUI("bg.guildInviteBtn")
	self:registerClickEvent(guildInviteBtn, function()
		self:inviteByGuild()
	end)
	
	local qunInviteBtn = self:getUI("bg.qunInviteBtn")
	self:registerClickEvent(qunInviteBtn, function()
		self:inviteByGroup()
	end)
	
    local richTextBg = self:getUI("bg.richTextBg")
    local richText = RichTextFactory:create(lang("GUILD_FAM_TIPS_6"), richTextBg:getContentSize().width, 0)
    richText:formatText()
    richText:setPosition(richTextBg:getContentSize().width/2, richTextBg:getContentSize().height - richText:getRealSize().height/2)
    richTextBg:addChild(richText)
	
end


function GuildMapFamInviteDialog:inviteByGroup()
    local isInQun = false
    local bindGroup = self._modelMgr:getModel("GuildModel"):getAllianceDetail().bindGroup or {}
    if bindGroup.hadJoin == 1 then
        isInQun = true
    end
    if not isInQun then
        self._viewMgr:showTip(lang("GUILDBOSS_INVITE_TIP4"))
        return
    end
    --[[self._serverMgr:sendMsg("GuildServer", "getLastInviteTime", {}, true, {}, function (result)
        if result == nil then 
            return
        end
        local lastTime = result.time or 0
        local curentTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
        if curentTime >= lastTime + 3600 then--]]
            self:sendToPlatform()--上下屏蔽内容为防止以后要加cd
		--[[else
            local _viewMgr = self._viewMgr or ViewManager:getInstance()
            _viewMgr:showTip(lang("GUILDBOSS_INVITE_TIP5"))
        end
    end)--]]
end

function GuildMapFamInviteDialog:sendToPlatform()
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local guildID = userData.guildId
    local title = lang("GUILD_FAM_TIPS_21")
    local desTxt = lang("GUILD_FAM_TIPS_22")

    local param = {}
	local gridKey = string.split(self._gridKey, ",")
    param.message_ext = "t=3,gid=".. guildID ..",inGridX="..gridKey[1]..",inGridY="..gridKey[2]..","
    param.scene = 2
    param.title = title
    param.desc  = desTxt
    param.media_tag = sdkMgr.SHARE_TAG.MSG_INVITE
    sdkMgr:sendToPlatform(param, function(code, data) 
        if code == sdkMgr.SDK_STATE.SDK_SHARE_SUCCESS then --分享成功，加cd
            local _serverMgr = self._serverMgr or ServerManager:getInstance()
--            _serverMgr:sendMsg("GuildServer", "setLastInviteTime", {}, false, {}, function(result)
			_serverMgr:sendMsg("GuildMapServer", "addSecretLandSendTlog", {type = 0}, false, {}, function(res)
				--打点TLog
			end)
--            end)
        end
        sdkMgr:unregisterCallbackByEventType("TYPE_SHARE")
    end)
end

function GuildMapFamInviteDialog:inviteByGuild()
    --联盟聊天频道  wangyan
    local param1 = {}
    param1["famData"] = {
        --body 想要传入的数据
		gridKey = self._gridKey
    }

    local _, isInfoBanned,sendData = self._modelMgr:getModel("ChatModel"):paramHandle("famInvite", param1)
    if isInfoBanned == true then
        self._chatModel:pushData(sendData)
    else
        self._serverMgr:sendMsg("ChatServer", "sendMessage", sendData, true, {}, function (result) 
			self._viewMgr:showTip(lang("GUILD_FAM_TIPS_10"))
				local _serverMgr = self._serverMgr or ServerManager:getInstance()
				_serverMgr:sendMsg("GuildMapServer", "addSecretLandSendTlog", {type = 1}, false, {}, function(res)

				end)
			self:close()
		end)
    end
end

return GuildMapFamInviteDialog