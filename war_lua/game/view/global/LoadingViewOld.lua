--[[
    Filename:    LoadingView.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-05-06 10:48:00
    Description: File description
--]]

local LoadingView = class("LoadingView", BaseLayer)
local AnimAP = require "base.anim.AnimAP"
local tc = cc.Director:getInstance():getTextureCache()
local sfc = cc.SpriteFrameCache:getInstance()
local ALR = pc.PCAsyncLoadRes:getInstance()
function LoadingView:ctor(data)
    LoadingView.super.ctor(self)
    self._showCursor = data.cursor
    self._showCursor = true
    self._isGuide = data.isGuide
    self._checkValue = data.checkValue
    self._noLoading = data.noLoading
    self._title = lang("TIESHI_0")..lang("TIESHI_"..GRandom(20)) .. " "

    self._teamId = data.teamId
 	if self._teamId == nil then
	 	local keyArray = {}
	 	for k, v in pairs(tab.team) do
	 		if v.show1 == 1 then
	 			keyArray[#keyArray + 1] = v
	 		end
	 	end
	 	self._teamId = keyArray[GRandom(#keyArray)].id
	end

 	local teamD = tab.team[self._teamId]
 	self._race = teamD["race"][1]
 	if self._race == 109 then
 		self._race = 102
 	elseif self._race > 106 then
 		self._race = 101
 	end
    sfc:addSpriteFrames("asset/ui/loading"..self._race..".plist", "asset/ui/loading"..self._race..".png")
end

function LoadingView:onInit()
	self:setFullScreen()
	local up = self:getUI("up")
	up:loadTexture("asset/uiother/loading/bg_zuo_"..self._race..".png")

	local xia = self:getUI("xia")
	xia:setLocalZOrder(50)
	xia:setPositionY(xia:getPositionY() - 34)
    self._jiantou = self:getUI("xia.progress.jiantou")
 	self._progress = self:getUI("xia.progress")
 	self._progress:setPercent(0)
 	self._jiantou:setPositionX(0)
 	self._jiantou:setVisible(self._showCursor ~= nil)
 	self._text = self:getUI("xia.bar.text")
 	self._text:setString(self._title .. "(100%)")
 	self._text:setAnchorPoint(0, 0.5)
 	self._text:setPositionX((924 - self._text:getContentSize().width) * 0.5)
 	self._text:setString("")

 	self._layer = self:getUI("bg")
 	self._namebg = self:getUI("layer")

 	local teamD = tab.team[self._teamId]

 	local x, y, scale = teamD["samallartposition"][1], teamD["samallartposition"][2], teamD["samallartposition"][3]

 	self._lihui = string.sub(teamD["art1"], 4, string.len(teamD["art1"]))
 	self._lihui = "asset/uiother/team/t_".. self._lihui ..".png"
 	local roleSp = cc.Sprite:create(self._lihui)
 	roleSp:setPosition(x - 200, 320 + y - 30)
 	if scale then
 		roleSp:setScale(scale)
 	end
 	self._layer:addChild(roleSp)


 	-- 名字
 	local name = cc.Label:createWithTTF(lang(teamD["name"]), UIUtils.ttfName_Title, 58)
 	name:setAnchorPoint(0.5, 0)
 	name:setPosition(156, 419)
 	name:setColor(cc.c3b(255, 255, 255))
 	name:enable2Color(1, cc.c4b(180, 254, 255, 255))
 	self._namebg:addChild(name)

 	local englishName = cc.Label:createWithTTF(lang(teamD["ename"]), UIUtils.ttfName_Title, 24)
 	englishName:setAnchorPoint(0, 0)
 	englishName:setColor(cc.c3b(134, 241, 237))
 	if englishName:getContentSize().width > name:getContentSize().width then
 		englishName:setAnchorPoint(0.5, 0)
 		englishName:setPosition(158, 476)
 	else
 		englishName:setPosition(156 - name:getContentSize().width * 0.5 + 2, 476)
 	end
 	self._namebg:addChild(englishName)

    local kind = cc.Sprite:createWithSpriteFrameName(teamD["classlabel"]..".png")
    kind:setPosition(120, 40)
    kind:setScale(0.7)
    self._namebg:addChild(kind)

    local des = cc.Label:createWithTTF(lang(teamD["des"]), UIUtils.ttfName, 20)
    des:setAnchorPoint(0, 1)
    des:setDimensions(234, 300)
    des:setVerticalAlignment(0)
    des:setPosition(52, 190)
    self._namebg:addChild(des)

 	local tip = cc.Label:createWithTTF(lang("CARDDES_"..teamD["carddes"]), UIUtils.ttfName_Title, 22)
 	tip:setAnchorPoint(0.5, 0)
 	tip:setColor(cc.c3b(255, 237, 86))
 	tip:setPosition(155, 396)
 	self._namebg:addChild(tip)

 	local r, g, b
 	if self._race == 101 then
 		self._text:setColor(cc.c3b(249, 251, 238))
 		r, g, b = 254, 254, 254
 		name:setColor(cc.c3b(255, 255, 255))
 		name:enable2Color(1, cc.c4b(180, 254, 255, 255))
 		englishName:setColor(cc.c3b(134, 241, 237))
 		des:setColor(cc.c3b(0, 25, 63))
 	elseif self._race == 102 then
 		self._text:setColor(cc.c3b(243, 248, 241))
 		r, g, b = 243, 248, 244
 		name:setColor(cc.c3b(255, 255, 255))
 		name:enable2Color(1, cc.c4b(247, 255, 180, 255))
 		englishName:setColor(cc.c3b(134, 241, 138))
 		des:setColor(cc.c3b(20, 51, 0))
 	elseif self._race == 103 then
 		self._text:setColor(cc.c3b(255, 251, 238))
 		r, g, b = 255, 255, 255
 		name:setColor(cc.c3b(255, 255, 255))
 		name:enable2Color(1, cc.c4b(255, 166, 86, 255))
 		englishName:setColor(cc.c3b(255, 187, 22))
 		des:setColor(cc.c3b(56, 32, 0))
 	elseif self._race == 104 then
 		self._text:setColor(cc.c3b(255, 251, 238))
 		r, g, b = 255, 255, 255
 		name:setColor(cc.c3b(255, 255, 255))
 		name:enable2Color(1, cc.c4b(113, 255, 253, 255))
 		englishName:setColor(cc.c3b(77, 192, 255))
 		des:setColor(cc.c3b(0, 16, 27))
 	elseif self._race == 105 then
 		self._text:setColor(cc.c3b(255, 251, 238))
 		r, g, b = 255, 255, 255
 		name:setColor(cc.c3b(255, 255, 255))
 		name:enable2Color(1, cc.c4b(255, 151, 127, 255))
 		englishName:setColor(cc.c3b(255, 119, 160))
 		des:setColor(cc.c3b(42, 0, 0))
 	elseif self._race == 106 then
 		self._text:setColor(cc.c3b(249, 251, 238))
 		r, g, b = 254, 254, 254
 		name:setColor(cc.c3b(255, 255, 255))
 		name:enable2Color(1, cc.c4b(180, 254, 255, 255))
 		englishName:setColor(cc.c3b(134, 241, 237))
 		des:setColor(cc.c3b(0, 25, 63))
 	elseif self._race == 109 then
 		-- 凤凰
 		self._text:setColor(cc.c3b(243, 248, 241))
 		r, g, b = 243, 248, 244
 		name:setColor(cc.c3b(255, 255, 255))
 		name:enable2Color(1, cc.c4b(247, 255, 180, 255))
 		englishName:setColor(cc.c3b(134, 241, 138))
 		des:setColor(cc.c3b(20, 51, 0))
 	end


 	self._jiantou:setOpacity(0)
 	if not self._noLoading then
	 	if AnimAP["mcList"][teamD["art"]] then
	 		if teamD["art"] == "daemo" then
	 			self._daemo = true
	 		end
	 		cc.SpriteFrameCache:getInstance():addSpriteFrames("asset/anim/"..teamD["art"].."image.plist", "asset/anim/"..teamD["art"].."image.png")
	 		local mc
	 		if self._daemo then
	 			mc = mcMgr:createMovieClip("stop_" .. teamD["art"])
	 		else
	 			mc = mcMgr:createMovieClip("run_" .. teamD["art"])
	 		end
			mc:setPurityColor(r, g, b)
	 		mc:setScale(0.25)
	 		mc:setPosition(self._jiantou:getContentSize().width * 0.5, 5)
	 		self._jiantou:addChild(mc)
	 		self._jiantou.mc = mc
	 	else
		    SpriteFrameAnim.new(self._jiantou, teamD["art"], function (_sp)
		 		_sp._sp:setPurityColor(r, g, b)
		        _sp:setPosition(self._jiantou:getContentSize().width * 0.5, 5)
		        _sp:changeMotion(2)
		        _sp:play()
		    end, false, 40, 48)
		end

		if self._daemo then
			local str = lang("TIESHI_21")
			self._text:setString(str .. "(100%)")
	 		self._text:setAnchorPoint(0, 0.5)
	 		local x1 = (924 - self._text:getContentSize().width) * 0.5
	 		local y1 = self._text:getPositionY()
	 		self._text:setPositionX(x1)
	 		local w1 = self._text:getContentSize().width
	 		self._text:setString("(0%)")

	 		local fontsize = self._text:getFontSize()
	 		local parent = self._text:getParent()
	 		local str = lang("TIESHI_21")
	 		local number = #str / 3
		 	for i = 1, #str - 2, 3 do
			 	local label = cc.Label:createWithTTF(string.sub(str, i, i + 2), UIUtils.ttfName, fontsize)
			 	label:setPosition(x1, y1)
			 	label:setColor(cc.c3b(255, 120, 120))
			 	x1 = x1 + label:getContentSize().width
			 	parent:addChild(label)
			 	ScheduleMgr:delayCall(200, self, function ()
				 	ScheduleMgr:delayCall((i - 1) / 3 * 60, self, function()
					 	label:runAction(cc.RepeatForever:create(cc.Sequence:create(
					        cc.TintTo:create(0.75, cc.c3b(255, 255, 120)),
					        cc.TintTo:create(0.75, cc.c3b(120, 255, 120)),
					        cc.TintTo:create(0.75, cc.c3b(120, 255, 255)),
					        cc.TintTo:create(0.75, cc.c3b(120, 120, 255)),
					        cc.TintTo:create(0.75, cc.c3b(255, 120, 255)),
					        cc.TintTo:create(0.75, cc.c3b(255, 120, 120))
					    )))
					end)
				end)
			end
			self._text:setPositionX(x1)
		end
	end

    -- 技能
    for i = 1, #teamD["skill"] do
    	local skillId = teamD["skill"][i][2]
    	local skillD = SkillUtils:getTeamSkillByType(skillId, teamD["skill"][i][1])
    	
    	local icon = IconUtils:createTeamSkillIconById({teamSkill = skillD, eventStyle = 0, noBox = true})
    	icon:setPosition(-17, -17)
    	icon:setScale(1.18)
    	self:getUI("layer.skill"..i):addChild(icon)

    	-- local label = cc.Label:createWithTTF(lang(skillD["name"]), UIUtils.ttfName, 20)
    	-- label:setColor(cc.c3b(255, 216, 00))
    	-- label:enableOutline(cc.c4b(1, 55, 00, 255), 2)
    	-- label:setPosition(10 + (i - 1) * 120 + 58, 156)
    	-- self._layer:addChild(label)
    end

    if not self._noLoading then
	 	self._updateId = ScheduleMgr:regSchedule(1, self, function(self, dt)
	        self:update()
	    end)
	end
 	self._realProgress = 0
    self._showProgress = 0
    self:setFullScreen()

    self._stopProgress = 0
    self._stopTick = 0
    self._play = false
    self._playTick = socket.gettime()
end

function LoadingView:reflashUI(data)
	if data.progress then
		local progress = data.progress
		self._realProgress = 150 * progress / (progress + 50)
	end
end

function LoadingView:showStopEffect(x, y)
	local stop = mcMgr:createViewMC("stop_loading", false, true)
	stop:setPosition(x, y)
	self._progress:addChild(stop)
	self._play = true
	self._playTick = socket.gettime()
end

function LoadingView:update()
	if self._realProgress > self._showProgress then
		local d = (self._realProgress - self._showProgress) * 0.1
		if d < 0.05 then
			d = 0.05
		end
		if d > 2 then
			d = 2
		end
		self._showProgress = self._showProgress + d
		if math.abs(self._realProgress - self._showProgress) < 0.05 then
			self._showProgress = self._realProgress
		end
	end

	self._progress:setPercent(self._showProgress)
	if self._daemo then

	else
		self._jiantou:setPositionX(self._showProgress * 9.24)
	end
	if self._daemo then
		self._text:setString("("..math.floor(self._showProgress).."%)")
	else
		self._text:setString(self._title .. "("..math.floor(self._showProgress).."%)")
	end

	if self._daemo then
		if self._showProgress >= 92 and not self._daemoshunyi then
			self._daemoshunyi = true
			self._jiantou.mc:removeFromParent()
 			local mc = mcMgr:createMovieClip("atk3_daemo")
			mc:setPurityColor(255, 255, 255)
	 		mc:setScale(0.25)
	 		mc:setPosition(self._jiantou:getContentSize().width * 0.5, 5)
	 		mc:addCallbackAtFrame(25, function ()
	 			self._jiantou:setPositionX(924)
	 		end)
	 		mc:addEndCallback(function ()
		 		self._daemoover = true
		 		if self._showProgress < 100 then
			 		local stop = mcMgr:createMovieClip("stop_daemo")
					stop:setPurityColor(255, 255, 255)
			 		stop:setScale(0.25)
			 		stop:setPosition(self._jiantou:getContentSize().width * 0.5, 5)
			 		self._jiantou:addChild(stop)	
			 		mc:setVisible(false)
			 	else
			 		mc:stop()
			 	end
	        end)
	 		self._jiantou:addChild(mc)	
		end
		if self._showProgress == 100 and self._daemoover then
			ScheduleMgr:unregSchedule(self._updateId)
			ScheduleMgr:delayCall(10, self, function()
				self:loadingDone()
		    end)
		end
	else
		if self._showProgress == 100 then
			ScheduleMgr:unregSchedule(self._updateId)
			ScheduleMgr:delayCall(10, self, function()
				self:loadingDone()
		    end)
		end
	end
end

function LoadingView:loadingDone()
	sfc:removeSpriteFramesFromFile("asset/ui/loading"..self._race..".plist")
    tc:removeTextureForKey("asset/ui/loading"..self._race..".png")
    tc:removeTextureForKey("asset/uiother/loading/bg_zuo_"..self._race..".png")
	tc:removeTextureForKey(self._lihui)

	if self._endCallback then
		self._endCallback()
	end
end


function LoadingView:setCallBack(endCallback)
	self._endCallback = endCallback
end
-- 1 texture
-- 2 plist
-- 3 send
-- 4 mc
-- 5 sf
-- 6 table
-- 7 sound
-- 开始载入
function LoadingView:loadStart(list, endCallback)
	if self._checkValue then
		print("检查静态表")
		local tick = socket.gettime()
		local cv = self._checkValue
	    local res = tab:checkSignatureTabs(cv[1], cv[2], cv[3], cv[4], cv[5], cv[6], cv[7], cv[8])
	    print("查表耗时: ", socket.gettime() - tick)
	    if res ~= nil then
	        if OS_IS_WINDOWS then
	            ViewManager:getInstance():onLuaError("配置表被更改: "..res)
	        else
	            ApiUtils.playcrab_lua_error("tab_xiugai", res)
	            if GameStatic.kickTable then
	                AppExit()
	            end
	        end
	        ScheduleMgr:unregSchedule(self._updateId)
	        return false
	    end
	end
	self._endCallback = endCallback
	self._doList = 
	{
		{list = {}, count = 0}, 
		{list = {}, count = 0}, 
		{list = {}, count = 0}, 
		{list = {}, count = 0}, 
		{list = {}, count = 0}, 
		{list = {}, count = 0},
		{list = {}, count = 0},
	}
	local type
	-- 请求分类
	for i = 1, #list do
		type = list[i][1]
		self._doList[type].list[#self._doList[type].list + 1] = list[i][2]
	end
	-- 统计总数
	self._doList[1].count = #self._doList[1].list
	self._doList[2].count = #self._doList[2].list
	self._doList[3].count = #self._doList[3].list
	self._doList[4].count = #self._doList[4].list * 2
	self._doList[5].count = sfResMgr:getResListRealCount(self._doList[5].list)
	self._doList[6].count = tab:getInitCount(self._isGuide)
	self._doList[7].count = #self._doList[7].list
	self._allCount = 0
	for i = 1, #self._doList do
		self._allCount = self._allCount + self._doList[i].count
	end
	self._doneCount = 0

	self:loadTable(function ()
		self:sendRequest(function ()

		end)
		self:loadSFRes(function ()
			self:loadTexture(function ()
				self:loadPlist(function ()
					self:loadMCRes(function ()
						self:loadSound(function ()

						end)
					end)
				end)
			end)	
		end)
	end)
	return true
end
-- 载入纹理
local tc = cc.Director:getInstance():getTextureCache()
local fu = cc.FileUtils:getInstance()
function LoadingView:loadTexture(callback)
	self._loadTexture = function (index)
		self._viewMgr:addGlobalTexture(self._doList[1].list[index], socket.gettime() + 30)
		if tc:getTextureForKey(self._doList[1].list[index]) then
        	self:countChange(1)
        	if index < self._doList[1].count then
        		self._loadTexture(index + 1)
        	else
        		if self.countChange == nil then return end
        		if callback then
        			callback()
        		end
        	end
		else
			if fu:isFileExist(self._doList[1].list[index]) then
				tc:addImageAsync(self._doList[1].list[index], function ()
		        	if self.countChange == nil then return end
		        	self:countChange(1)
		        	if index < self._doList[1].count then
		        		self._loadTexture(index + 1)
		        	else
		        		if self.countChange == nil then return end
		        		if callback then
		        			callback()
		        		end
		        	end
				end)
			else
	        	if self.countChange == nil then return end
	        	self:countChange(1)
	        	if index < self._doList[1].count then
	        		self._loadTexture(index + 1)
	        	else
	        		if self.countChange == nil then return end
	        		if callback then
	        			callback()
	        		end
	        	end
			end
		end
	end
	if self._doList[1].count > 0 then
		self._loadTexture(1)
	else
        if callback then
			callback()
		end
	end
end
-- 载入Plist
function LoadingView:loadPlist(callback)
	self._loadPlist = function (index)
		if tc:getTextureForKey(self._doList[2].list[index][2]) then
			self:countChange(1)
        	if index < self._doList[2].count then
        		self._loadPlist(index + 1)
        	else
        		if self.countChange == nil then return end
        		if callback then
        			callback()
        		end
        	end
		else
	        local task = pc.LoadResTask:createPlistTask(self._doList[2].list[index][1], self._doList[2].list[index][2])
	        task:setLuaCallBack(function ()
	        	ScheduleMgr:delayCall(0, self, function()
		        	if self.countChange == nil then return end
		        	self:countChange(1)
		        	if index < self._doList[2].count then
		        		self._loadPlist(index + 1)
		        	else
		        		if self.countChange == nil then return end
		        		if callback then
		        			callback()
		        		end
		        	end
		        end)
	        end)
	        ALR:addTask(task) 
	    end
	end
	if self._doList[2].count > 0 then
		self._loadPlist(1)
	else
		if callback then
			callback()
		end
	end
end
-- 载入静态数据表
function LoadingView:loadTable(callback)
	if self._doList[6].count > 0 then
		local _type = 1
		if self._isGuide then
			_type = 2
		end
	    tab:initTab_Async(_type, function (count)
	    	if self.countChange == nil then return end
	        self:countChange(count)
	    end,
	    function ()
	    	if self.countChange == nil then return end
	    	if callback then
	    		callback()
	    	end
	    end)
	else
        if callback then
			callback()
		end
	end
end
-- 发送网络请求
function LoadingView:sendRequest(callback)
	self._sendRequest = function (index)
		self._sendRequestIndex = index
	    local systemName = self._doList[3].list[index][3]
	    local isOpen = true

	    if systemName then
	        isOpen = SystemUtils["enable"..systemName]()
	    end
	    if isOpen then
	    	local param = {}
	    	if self._doList[3].list[index][4] ~= nil then 
	    		param = self._doList[3].list[index][4]
	    	end
	        self._serverMgr:sendMsg(self._doList[3].list[index][1], self._doList[3].list[index][2], param, true, {}, 
	        function ()  
	        	if self._sendRequestIndex ~= index then return end
	        	if self.countChange == nil then return end
	            self:countChange(1)
	            if index < self._doList[3].count then
	            	self._sendRequest(index + 1)
	            else
	            	if self.countChange == nil then return end
		        	if callback then
		        		callback()
		        	end
		        end
	        end, 
	        function (error)
	        	if error then
	        		local info = {__error = error, param = param}
	        		ApiUtils.playcrab_lua_error("loginRequest_"..self._doList[3].list[index][1].."_"..self._doList[3].list[index][2], serialize(info), "login")
		        	if self._sendRequestIndex ~= index then return end
		        	if self.countChange == nil then return end
		            self:countChange(1)
		            if index < self._doList[3].count then
		            	self._sendRequest(index + 1)
		            else
		            	if self.countChange == nil then return end
			        	if callback then
			        		callback()
			        	end
			        end
			    end
	        end, true)
	    else
	    	if self.countChange == nil then return end
	        self:countChange(1)
	        
	        if index < self._doList[3].count then
	        	self._sendRequest(index + 1)
	        else
	        	if callback then
	        		callback()
	        	end
	        end
	    end
	end
	if self._doList[3].count > 0 then
		self._sendRequest(1)
	else
        if callback then
			callback()
		end
	end
end
-- 载入mc资源
function LoadingView:loadMCRes(callback)
    if self._doList[4].count > 0 then
        mcMgr:loadResList(self._doList[4].list, 
            function ()
            	if self.countChange == nil then return end
                self:countChange(1)
            end,
            function ()
            	if self.countChange == nil then return end
                if callback then
                	callback()
                end
            end)
    else
        if callback then
        	callback()
        end
    end
end
-- 载入人物资源
function LoadingView:loadSFRes(callback)
    if self._doList[5].count > 0 then
        sfResMgr:loadResList(self._doList[5].list, 
            function (_, _, name)
            	if self.countChange == nil then return end
                self:countChange(1)
            end,
            function ()
            	if self.countChange == nil then return end
		        if callback then
		        	callback()
		        end
            end)
    else
        if callback then
        	callback()
        end
    end
end

function LoadingView:loadSound(callback)
    if self._doList[7].count > 0 then
    	audioMgr:preloadSounds(self._doList[7].list,
    		function ()
            	if self.countChange == nil then return end
                self:countChange(1)
            end,
            function ()
            	if self.countChange == nil then return end
		        if callback then
		        	callback()
		        end
            end)
    else
        if callback then
        	callback()
        end
    end
end


function LoadingView:countChange(count)
	self._doneCount = self._doneCount + count
	self:reflashUI({progress = math.floor(self._doneCount / self._allCount * 100)})
end

function LoadingView.dtor()
	local tab = {101, 102, 103, 104, 105}
	for i = 1, #tab do
		sfc:removeSpriteFramesFromFile("asset/ui/loading"..tab[i]..".plist")
	    tc:removeTextureForKey("asset/ui/loading"..tab[i]..".png")
	end
	AnimAP = nil
	LoadingView = nil
	sfc = nil
	tc = nil
end

return LoadingView