--[[
    Filename:    TestSdkGuideView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-12-28 16:23:46
    Description: File description
--]]

local TestSdkGuideView = class("TestSdkGuideView", BaseView)

function TestSdkGuideView:ctor(inData)
    TestSdkGuideView.super.ctor(self)

end
function TestSdkGuideView:onInit()
	self._requestBindState =  0
	self._guildModel = self._modelMgr:getModel("GuildModel")
	self._userModel = self._modelMgr:getModel("UserModel")
end

function TestSdkGuideView:reflashUI()
	print("TestSdkGuideView:onInit===================")
	if sdkMgr:isOpenBindGroup() and sdkMgr:isOpenJoinGroup() then
		self._guildNameLab = cc.Label:createWithTTF("绑定", UIUtils.ttfName, 35)
	    self._guildNameLab:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2+300)
	    self._guildNameLab:setColor(cc.c3b(255, 50, 50))
	    self._guildNameLab:enableOutline(cc.c4b(0,0,0,255), 2)
	    self:addChild(self._guildNameLab, 10)

	    local button1 = ccui.Button:create("globalImageUI_dice.png", "globalImageUI_dice.png", "", 1)
	    button1:setPosition(MAX_SCREEN_WIDTH/2 - 300, MAX_SCREEN_HEIGHT/2)
	    self:addChild(button1)
	    registerClickEvent(button1, function()
	    	print("bindPlatformGroup===============")
	    	self:getBindGuildInfo()
	    end)

		local tipLab = cc.Label:createWithTTF("查看绑定状态", UIUtils.ttfName, 35)
	    tipLab:setPosition(0, 0)
	    tipLab:setColor(cc.c3b(255, 50, 50))
	    tipLab:enableOutline(cc.c4b(0,0,0,255), 2)
	    button1:addChild(tipLab, 10)
	end

    local button4 = ccui.Button:create("globalBtnUI_closeimg.png", "globalBtnUI_closeimg.png", "", 1)
    button4:setPosition(MAX_SCREEN_WIDTH /2, MAX_SCREEN_HEIGHT/2 - 200)
    self:addChild(button4)
	registerClickEvent(button4, function()
		print("test=====================")
		self:close() 
		UIUtils:reloadLuaFile("dev.TestSdkGuideView")
	end)


    local button4 = ccui.Button:create("globalBtnUI_closeimg.png", "globalBtnUI_closeimg.png", "", 1)
    button4:setPosition(MAX_SCREEN_WIDTH /2 + 200, MAX_SCREEN_HEIGHT/2 - 200)
    self:addChild(button4)
	registerClickEvent(button4, function()
		UIUtils:reloadLuaFile("controller.SdkManager")
	    SdkManager = require("game.controller.SdkManager")
	    sdkMgr = SdkManager:getInstance()
	end)
	self:updateBindState()

end


function TestSdkGuideView:getBindGuildInfo()
	print("getBindGuildInfo=========================")
    self._serverMgr:sendMsg("GuildServer", "getBindGuildInfo", {}, true, {}, function (result)
    	if result == nil then 
    		return
    	end

    	dump(result, "test", 10)
    	print("test==============-------------")
    	local userData = self._userModel:getData()
    	print("userData.guildId======================", userData.guildId, userData.sec)
    	local roleGuild = userData.roleGuild

    	
    	self._guildModel:getAllianceDetail().bindGroup = result
		-- local bindGroup = guildModel:getAllianceDetail().bindGroup
    	self:removeAllChildren()
    	self:reflashUI()


    	self:updateBindState(result.error)
    end)
end

function TestSdkGuideView:updateBindState()
	local userData = self._userModel:getData()
	local roleGuild = userData.roleGuild
	local bindGroup = self._guildModel:getAllianceDetail().bindGroup
	if bindGroup == nil then 
		bindGroup = {}
	end
	dump(bindGroup, "test", 10)
	local status = 0
	if bindGroup.hadBind == nil or bindGroup.hadBind == "" or tonumber(bindGroup.hadBind) == 0 then 
		status = 1
	end
	if bindGroup.groupName ~= nil then 
		self._guildNameLab:setString(bindGroup.groupName) 
	end
	print("status==================", status)
	if status == 1 then 
    	if roleGuild.pos == 1 then 
	    	local button1 = ccui.Button:create("globalImageUI8_worldMenuIcon1.png", "globalImageUI8_worldMenuIcon1.png", "", 1)
		    button1:setPosition(MAX_SCREEN_WIDTH/2 - 200, MAX_SCREEN_HEIGHT/2)
		    self:addChild(button1)
		    registerClickEvent(button1, function()
		    	self._requestBindState = 1
		    	print("bindPlatformGroup===============")
		    	local param = {}
		    	param.union_id = userData.guildId
		    	param.union_name = "测一下"
		    	param.sec = userData.sec
		    	param.nick_name = "能测不"
		    	sdkMgr:bindPlatformGroup(param, function(code, data)

		    	end)
		    end)
			local tipLab = cc.Label:createWithTTF("绑定", UIUtils.ttfName, 35)
		    tipLab:setPosition(0, 0)
		    tipLab:setColor(cc.c3b(255, 50, 50))
		    tipLab:enableOutline(cc.c4b(0,0,0,255), 2)
		    button1:addChild(tipLab, 10)
		end
	elseif status == 0 then 
	    local button2 = ccui.Button:create("globalImageUI8_worldMenuIcon2.png", "globalImageUI8_worldMenuIcon2.png", "", 1)
	    button2:setPosition(MAX_SCREEN_WIDTH /2, MAX_SCREEN_HEIGHT/2)
	    self:addChild(button2)
	    registerClickEvent(button2, function()	
	    	print("queryQQGroup===============")    	
	    	local param = {}
	    	param.union_id = userData.guildId
	    	-- 公会名称
	    	param.union_name = "测一下"
	    	param.sec = userData.sec
	    	-- 昵称
	    	param.nick_name = "能测不"
	    	sdkMgr:queryQQGroup(param, function(code, data)
	    	end)
	    end)
		local tipLab = cc.Label:createWithTTF("SDK查看", UIUtils.ttfName, 35)
	    tipLab:setPosition(0, 0)
	    tipLab:setColor(cc.c3b(255, 50, 50))
	    tipLab:enableOutline(cc.c4b(0,0,0,255), 2)
	    button2:addChild(tipLab, 10)
	    if roleGuild.pos ~= 1 and (bindGroup.hadJoin == nil or bindGroup.hadJoin == 0) then 
		    local button3 = ccui.Button:create("globalImageUI8_worldMenuIcon3.png", "globalImageUI8_worldMenuIcon3.png", "", 1)
		    button3:setPosition(MAX_SCREEN_WIDTH /2 + 200, MAX_SCREEN_HEIGHT/2)
		    self:addChild(button3)
		    registerClickEvent(button3, function()
		    	self._requestBindState = 1
		    	local param = {}
		    	param.union_id = userData.guildId
		    	param.union_name = "测一下"
		    	param.sec = userData.sec
		    	param.nick_name = "能测不"
		    	param.group_key = bindGroup.groupKey
		    	sdkMgr:joinPlatformGroup(param, function(code, data)
		    		pritn("code=====", code)
		    	end)

		    end)
			local tipLab = cc.Label:createWithTTF("加入", UIUtils.ttfName, 35)
		    tipLab:setPosition(0, 0)
		    tipLab:setColor(cc.c3b(255, 50, 50))
		    tipLab:enableOutline(cc.c4b(0,0,0,255), 2)
		    button3:addChild(tipLab, 10)
		elseif roleGuild.pos == 1 then 
			local button1 = ccui.Button:create("globalImageUI8_worldMenuIcon1.png", "globalImageUI8_worldMenuIcon1.png", "", 1)
		    button1:setPosition(MAX_SCREEN_WIDTH/2 + 400, MAX_SCREEN_HEIGHT/2)
		    self:addChild(button1)
		    registerClickEvent(button1, function()
		    	self:unBindGuild()
		    end)
			local tipLab = cc.Label:createWithTTF("解绑", UIUtils.ttfName, 35)
		    tipLab:setPosition(0, 0)
		    tipLab:setColor(cc.c3b(255, 50, 50))
		    tipLab:enableOutline(cc.c4b(0,0,0,255), 2)
		    button1:addChild(tipLab, 10)

		    
		end
	end
end

function TestSdkGuideView:unBindGuild()
    self._serverMgr:sendMsg("GuildServer", "unBindGuild", {}, true, {}, function (result)
    	dump(result, "test" , 10)
    	if result.res == 1 then
    		local bindGroup = self._guildModel:getAllianceDetail().bindGroup
    		self._guildModel:getAllianceDetail().bindGroup = {}
    	end
    end)
end

function TestSdkGuideView:onBeforeAdd(callback, errorCallback)
    -- self._members = self._modelMgr:getModel("GuildModel"):getRunAllianceList()
    -- if table.nums(self._members) == 0 then
    if self._guildModel:isEmpty() then
        self._onBeforeAddCallback = function(inType)
            if inType == 1 then 
                callback()
            else
                errorCallback()
            end
        end
        self:getGuildInfo()
    else
        callback()
    end
end

function TestSdkGuideView:getGuildInfo()
    self._serverMgr:sendMsg("GuildServer", "getGameGuildInfo", {}, true, {}, function (result)
        dump(result, "result===", 10)
        if self.getGuildInfoFinish then
            self:getGuildInfoFinish(result)
        end
    end)

end

function TestSdkGuideView:getGuildInfoFinish(result)
    -- dump(result)
    if result == nil then
        self._onBeforeAddCallback(2)
        return 
    end
    self:reflashUI()
    self._onBeforeAddCallback(1)
end

function TestSdkGuideView:bindGuild()

    self._serverMgr:sendMsg("GuildServer", "bindGuild", {}, true, {}, function (result)
    	if result == nil then 
    		return
    	end
    	self._guildModel:getAllianceDetail().bindGroup = result
    	self:removeAllChildren()
    	self:reflashUI()
    end)
end

function TestSdkGuideView:applicationWillEnterForeground()
	if self._requestBindState == 1 then 
		local userData = self._userModel:getData()
		local roleGuild = userData.roleGuild
		if roleGuild.pos == 1 then 
	    	self:bindGuild()
		else
			self:getBindGuildInfo()
		end
		self._requestBindState = 0
	end
end

function TestSdkGuideView:getAsyncRes()
    return 
        {
           {"asset/ui/intance.plist", "asset/ui/intance.png"},
           {"asset/ui/intance-HD.plist", "asset/ui/intance-HD.png"},
        }
end

function TestSdkGuideView:hideNoticeBar()

end

return TestSdkGuideView