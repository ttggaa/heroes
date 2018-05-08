--[[
    Filename:    LoadingView.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-03-22 10:48:00
    Description: File description
--]]

-- loading界面 2.0
local LoadingView = class("LoadingView", BaseLayer)
local tc = cc.Director:getInstance():getTextureCache()
local sfc = cc.SpriteFrameCache:getInstance()
local ALR = pc.PCAsyncLoadRes:getInstance()
local fu = cc.FileUtils:getInstance()
function LoadingView:ctor(data)
    LoadingView.super.ctor(self)

    self._isGuide = data.isGuide
    self._dontInit = data.dontInit
    self._checkValue = data.checkValue
    self._noLoading = data.noLoading
    self._noText = data.noText

    -- 0 是登录    非0 是战斗类型
    self._loadType = data.type
    self._loadSubType = data.subtype

    self._teamId = data.teamId
 	if self._teamId == nil then
 		self._teamId = 101
	end

 	local teamD = tab.team[self._teamId]

 	self._race = data.race
 	if self._race == nil then
 		self._race = teamD["race"][1]
 	end

 	self._battleId = data.battleId
 	self._isPass = data.isPass
end

local loadingPicTab = 
{
	[1101] = {1, 1}, [1102] = {1, 1}, [1103] = {1, 1}, [1104] = {1, 1}, [1105] = {1, 1}, [1106] = {1, 1}, [1107] = {1, 1}, [1108] = {1, 1},
	[1201] = {2, 1}, [1202] = {2, 1}, [1203] = {2, 1}, [1204] = {2, 1}, [1205] = {2, 1}, [1206] = {2, 1}, [1207] = {2, 1},[1208] = {2, 1},
	[1301] = {2, 1}, [1302] = {2, 1}, [1303] = {2, 1}, [1304] = {2, 1}, [1305] = {2, 1}, [1306] = {2, 1}, [1307] = {2, 1}, [1308] = {2, 1},
	[1401] = {4, 1}, [1402] = {4, 1}, [1403] = {4, 1}, [1404] = {4, 1}, [1405] = {4, 1}, [1406] = {4, 1}, [1407] = {4, 1},
	[1501] = {3, 1}, [1502] = {3, 1}, [1503] = {3, 1}, [1504] = {3, 1}, [1505] = {3, 1}, [1506] = {3, 1}, [1507] = {3, 1},
	[1601] = {1, 1}, [1602] = {1, 1}, [1603] = {1, 1}, [1604] = {1, 1}, [1605] = {1, 1}, [1606] = {1, 1}, [1607] = {1, 1},
	[1701] = {1, 1}, [1702] = {1, 1}, [1703] = {1, 1}, [1704] = {1, 1}, [1705] = {1, 1}, [1706] = {1, 1}, [1707] = {1, 1},
	[1801] = {1, 1}, [1802] = {1, 1}, [1803] = {1, 1}, [1804] = {1, 1}, [1805] = {1, 1}, [1806] = {1, 1}, 
	[1901] = {1, 1}, [1902] = {1, 1}, [1903] = {1, 1}, [1904] = {1, 1}, [1905] = {1, 1}, [1906] = {1, 1}, [1907] = {1, 1},

	[2101] = {1, 1}, [2102] = {2, 1}, [2103] = {4, 1}, [2104] = {1, 1}, [2105] = {3, 1}, [2106] = {1, 1}, [2107] = {1, 1}, [2108] = {1, 1},

	[3001] = {4, 1}, [3002] = {2, 1}, [3003] = {2, 1}, [3004] = {4, 1}, [3005] = {4, 1},

	[4001] = {2, 1}, [4002] = {2, 1}, [4003] = {2, 1}, [4004] = {2, 1}, [4005] = {2, 1}, [4006] = {2, 1}, [4007] = {2, 1},

	[9999] = {3, 1},
}
local loadingEffTab = 
{
	{0, 0, 0, 0}, 		-- 蓝
	{0, 0, 0, -79}, 	-- 绿
	{32, 0, 3, -169}, 	-- 红
	{6, 0, 100, 170}, 	-- 黄
}

function LoadingView:initLoadingPic()
	local loadingD = tab.loading[self._battleId]
	if loadingD and not self._isPass then
		-- 定制化loading
		self._title = lang("TIESHI_0").." "..lang(loadingD["tips"]) .. ""
		local picname = loadingD["img"]
		picname = tonumber(string.sub(picname, 3, 3)) * 1000 + string.sub(picname, 5, 7)
		local _type = tonumber(string.sub(picname, 1, 1))
		local _index = tonumber(string.sub(picname, 2, 4))
		self._picName = "l_" .. string.sub(picname, 1, 1) .. "_" .. string.sub(picname, 2, 4) .. ".jpg"
		local _data = loadingPicTab[tonumber(picname)]
		if _data then
			self._loadingEffIndex = _data[1]
		else
			self._loadingEffIndex = 1
			-- self._viewMgr:showTip(self._picName)
			self._picName = "l_2_101.jpg"
		end
	else
		local BattleUtils = BattleUtils
		local randomTab, picname
		local loadType = self._loadType
		local loadSubType = self._loadSubType
		if loadType == 0 then
			-- 登录
			randomTab = {2101, 2102, 2103, 2104, 2105, 2106, 2107, 2108, 3001, 3002, 3003, 3004, 3005}
			picname = tostring(randomTab[GRandom(#randomTab)])
		else
			local modeT = {
				[BattleUtils.BATTLE_TYPE_Fuben] 			= 1,
				[BattleUtils.BATTLE_TYPE_ClimbTower] 		= 1,
				[BattleUtils.BATTLE_TYPE_ServerArenaFuben]  = 1,
			}
			if loadType == BattleUtils.BATTLE_TYPE_Guide then
				picname = "9999"
			elseif (loadType and modeT[loadType]) or (loadSubType and modeT[loadSubType]) then
				-- 副本
				if loadingPicTab[1000 + self._teamId] then
					if loadingPicTab[2000 + self._race] then
						randomTab = {1000 + self._teamId, 2000 + self._race}
						picname = tostring(randomTab[GRandom(#randomTab)])
					else
						picname = tostring(1000 + self._teamId)
					end
				else
					picname = "2101"
				end
			elseif loadType == BattleUtils.BATTLE_TYPE_GuildPVP then
				if BattleUtils.LOADING_GuildPVP_pic then
					picname = BattleUtils.LOADING_GuildPVP_pic
					BattleUtils.LOADING_GuildPVP_pic = nil
				else
					local race = 2000 + self._race
					if loadingPicTab[race] then
						randomTab = {race, race, race, 3005}
						picname = tostring(randomTab[GRandom(#randomTab)])
					else
						picname = "3005"
					end
					BattleUtils.LOADING_GuildPVP_pic = picname
				end
            elseif loadType == BattleUtils.BATTLE_TYPE_GuildPVE or loadType == BattleUtils.BATTLE_TYPE_GuildFAM then
				local race = 2000 + self._race
				if loadingPicTab[race] then
					randomTab = {race, race, race, 3005}
					picname = tostring(randomTab[GRandom(#randomTab)])
				else
					picname = "3005"
				end
			elseif loadType == BattleUtils.BATTLE_TYPE_CloudCity or loadType == BattleUtils.BATTLE_TYPE_CCSiege then
				local race = 2000 + self._race
				if loadingPicTab[race] then
					picname = tostring(race)
				else
					picname = "2101"
				end
			elseif loadType == BattleUtils.BATTLE_TYPE_BOSS_DuLong 
				or loadType == BattleUtils.BATTLE_TYPE_BOSS_XnLong 
				or loadType == BattleUtils.BATTLE_TYPE_BOSS_SjLong then
				local race = 2000 + self._race
				if loadingPicTab[race] then
					randomTab = {race, race, race, 3003}
					picname = tostring(randomTab[GRandom(#randomTab)])
				else
					picname = "3003"
				end
			elseif loadType == BattleUtils.BATTLE_TYPE_AiRenMuWu then
				local race = 2000 + self._race
				if loadingPicTab[race] then
					randomTab = {race, race, race, 3001}
					picname = tostring(randomTab[GRandom(#randomTab)])
				else
					picname = "3001"
				end
			elseif loadType == BattleUtils.BATTLE_TYPE_Zombie then
				local race = 2000 + self._race
				if loadingPicTab[race] then
					randomTab = {race, race, race, 3002}
					picname = tostring(randomTab[GRandom(#randomTab)])
				else
					picname = "3002"
				end
			else
				local race = 2000 + self._race
				if loadingPicTab[race] then
					randomTab = {race, race, race, 4001, 4002, 4003, 4004, 4005, 4006, 4007}
					picname = tostring(randomTab[GRandom(#randomTab)])
				else
					randomTab = {4001, 4002, 4003, 4004, 4005, 4006, 4007}
					picname = tostring(randomTab[GRandom(#randomTab)])
				end
			end
		end
		local _type = tonumber(string.sub(picname, 1, 1))
		local _index = tonumber(string.sub(picname, 2, 4))
		self._picName = "l_" .. string.sub(picname, 1, 1) .. "_" .. string.sub(picname, 2, 4) .. ".jpg"
		local _data = loadingPicTab[tonumber(picname)]
		if _data then
			self._loadingEffIndex = _data[1]
		else
			self._loadingEffIndex = 1
			-- self._viewMgr:showTip(self._picName)
			self._picName = "l_2_101.jpg"
		end
		print(self._loadingEffIndex)
		if loadType == BattleUtils.BATTLE_TYPE_Guide then
			self._title = "　　　　首都斯坦德威克被恶魔包围，在火海中孤立无援……"
		elseif not self._noText then
			if loadType == BattleUtils.BATTLE_TYPE_GuildPVP and BattleUtils.LOADING_GuildPVP_str then
				self._title = BattleUtils.LOADING_GuildPVP_str
				BattleUtils.LOADING_GuildPVP_str = nil
			else
				local count3 = {4, 4, 5, 2, 2}
				local count4 = {1, 1, 1, 1, 1, 2, 1}
				local count5 = 33

				local str, ran
				if _type == 1 then
					-- 兵团 1对1
					ran = GRandom(count5 + 1)
					if ran <= count5 then
						str = "TIESHI_5_"..string.format("%03d", GRandom(count5))
					else
						str = "TIESHI_1_".._index
					end
				elseif _type == 2 then
					str = "TIESHI_5_"..string.format("%03d", GRandom(count5))
				elseif _type == 3 then
					ran = GRandom(count5 + count3[_index])
					if ran <= count5 then
						str = "TIESHI_5_"..string.format("%03d", GRandom(count5))
					else
						str = "TIESHI_3_"..string.format("%03d_", _index)..string.format("%03d", ran - count5)
					end
				elseif _type == 4 then
					ran = GRandom(count5 + count4[_index])
					if ran <= count5 then
						str = "TIESHI_5_"..string.format("%03d", GRandom(count5))
					else
						str = "TIESHI_4_"..string.format("%03d_", _index)..string.format("%03d", ran - count5)
					end
				end
				print("tip", str)
		    	self._title = lang("TIESHI_0").." "..lang(str) .. ""
		    	if loadType == BattleUtils.BATTLE_TYPE_GuildPVP then
		    		BattleUtils.LOADING_GuildPVP_str = self._title
		    	end
		    end
	    else
	    	self._title = nil
	    end
	end
end

function LoadingView:onInit()
	self:setFullScreen()

	self:initLoadingPic()

	self._bg = cc.Sprite:create("asset/bg/loading-HD/"..self._picName)
	tc:removeTextureForKey("asset/bg/loading-HD/"..self._picName)
	self._bg:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
	self:addChild(self._bg)

    local xscale = MAX_SCREEN_WIDTH / 1022
    local yscale = MAX_SCREEN_HEIGHT / 648
    if xscale > yscale then
        self._bg:setScale(xscale)
    else
        self._bg:setScale(yscale)
    end

    if self._title then
	    local text = cc.Label:createWithTTF(self._title.."（3％）", UIUtils.ttfName, 18)
	    text:enableOutline(cc.c4b(130,85,40,255), 2)
	    text:setAnchorPoint(0, 0.5)
	    text:setPosition(MAX_SCREEN_WIDTH * 0.5 - text:getContentSize().width * 0.5, 30)
	    self:addChild(text)
	    self._text = text
	end

    local proBg = cc.Scale9Sprite:createWithSpriteFrameName("loading_bar_bg.png")
    proBg:setContentSize(MAX_SCREEN_WIDTH, 14)
    proBg:setPosition(MAX_SCREEN_WIDTH * 0.5, 0)
    proBg:setAnchorPoint(0.5, 0)
    self:addChild(proBg)

    local proBarSp = cc.Sprite:createWithSpriteFrameName("loading_bar_" .. self._loadingEffIndex .. ".png")
    local proBar = cc.ProgressTimer:create(proBarSp)
    proBar:setPosition(MAX_SCREEN_WIDTH * 0.5, 7)
    proBar:setScaleX(xscale)
    proBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    proBar:setMidpoint(cc.p(0, 0.5))
    proBar:setBarChangeRate(cc.p(1, 0))    
    proBar:setPercentage(3)
    self:addChild(proBar)

    self._proBar = proBar

    local mc = mcMgr:createViewMC("jindutiao_jindutiao", true)
    mc:setPosition(MAX_SCREEN_WIDTH * 0.03, 7)
    self:addChild(mc)
    self._proMc = mc
    local effData = loadingEffTab[self._loadingEffIndex]
    mc:setBrightness(effData[1])
    mc:setContrast(effData[2])
    mc:setSaturation(effData[3])
    mc:setHue(effData[4])

    if not self._noLoading then
	 	self._updateId = ScheduleMgr:regSchedule(1, self, function(self, dt)
	        self:update()
	    end)
	end
 	self._realProgress = 0
    self._showProgress = 0

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

function LoadingView:update()
	if self._realProgress > self._showProgress then
		local d = (self._realProgress - self._showProgress) * 0.75
		if d < 0.05 then
			d = 0.05
		end
		self._showProgress = self._showProgress + d
		if math.abs(self._realProgress - self._showProgress) < 0.05 then
			self._showProgress = self._realProgress
		end
	end
	if self._realProgress >= 100 then
		self._showProgress = 100
	end
	if self._showProgress < 3 then
		self._proBar:setPercentage(3)
		self._proMc:setPositionX(MAX_SCREEN_WIDTH * 0.03)
		if self._title then
			if self._loadType ~= BattleUtils.BATTLE_TYPE_Guide then
				self._text:setString(self._title .. "（3％）")
			else
				self._text:setString(self._title)
			end
		end
	else
		self._proBar:setPercentage(self._showProgress)
    	self._proMc:setPositionX(MAX_SCREEN_WIDTH * self._showProgress * 0.01)
    	if self._title then
    		if self._loadType ~= BattleUtils.BATTLE_TYPE_Guide then
				self._text:setString(self._title .. "（"..math.floor(self._showProgress).."％）")
			else
				self._text:setString(self._title)
			end
		end
	end



	if self._showProgress >= 100 then
		ScheduleMgr:unregSchedule(self._updateId)
		ScheduleMgr:delayCall(10, self, function()
			self:loadingDone()
	    end)
	end
end

function LoadingView:loadingDone()
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
	            ApiUtils.playcrab_lua_error("tab_xiugai_loading", res)
	            if GameStatic.kickTable then
	                do _G["AppExit"..math.random(10)]() if not APP_EXIT then ServerManager = nil ModelManager = nil end return end
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
		{list = {}, count = 0},
	}
	local _type
	-- 由于改成多核加载，所以这块需要过滤重复请求
	local _map = {{}, {}, {}, {}, {}, {}, {}, {}}
	-- 请求分类
	local _item
	for i = 1, #list do
		_type = list[i][1]
		_item = list[i][2]
		local filter = false
		if _type == 1 then
			if _map[_type][_item] == nil then
				_map[_type][_item] = true
			else
				print("---1", _item)
				filter = true
			end
		elseif _type == 2 then
			if _map[_type][_item[1]] == nil then
				_map[_type][_item[1]] = true
			else
				print("---2", _item[1])
				filter = true
			end
		elseif _type == 4 then
			if _map[_type][_item] == nil then
				_map[_type][_item] = true
			else
				print("---4", _item)
				filter = true
			end
		elseif _type == 5 then
			if _map[_type][_item[1]] == nil then
				_map[_type][_item[1]] = true
			else
				print("---5", _item[1])
				filter = true
			end
		end

		if not filter then
			self._doList[_type].list[#self._doList[_type].list + 1] = _item
		end
	end
	-- 统计总数

	-- texture
	self._doList[1].count = #self._doList[1].list
	-- plist
	self._doList[2].count = #self._doList[2].list
	-- sendmsg
	self._doList[3].count = #self._doList[3].list
	-- mc
	self._doList[4].count = #self._doList[4].list * 2
	-- sf
	self._doList[5].count = sfResMgr:getResListRealCount(self._doList[5].list)
	-- tab
	self._doList[6].count = tab:getInitCount(self._isGuide, self._dontInit)
	-- sound
	self._doList[7].count = #self._doList[7].list
	-- voice
	self._doList[8].count = #self._doList[8].list
	-- dump(self._doList)
	self._allCount = 0
	for i = 1, #self._doList do
		self._allCount = self._allCount + self._doList[i].count
	end
	self._doneCount = 0

	self:initVoice(function ()

	end)
	self:loadTable(function ()
		self:sendRequest(function ()

		end)
		self:loadSound(function ()

		end)
		self:loadSFRes(function ()
			self:loadTexture(function ()
				self:loadPlist(function ()
					self:loadMCRes(function ()

					end)
				end)
			end)	
		end)
	end)
	if self._allCount == 0 then
		self._proBar:setPercentage(100)
		self._text:setString(self._title .. "（"..math.floor(100).."％）")
		self._proMc:setPositionX(MAX_SCREEN_WIDTH)
		ScheduleMgr:unregSchedule(self._updateId)
		ScheduleMgr:delayCall(10, self, function()
			self:loadingDone()
	    end)
	end
	return true
end
-- 载入纹理
function LoadingView:loadTexture(callback)
	self._loadTexture = function ()
		local __count = #self._doList[1].list
		local __index = 0
		for i = 1, __count do
			local item = self._doList[1].list[i]
			self._viewMgr:addGlobalTexture(item, socket.gettime() + 30)
			if tc:getTextureForKey(item) then
	        	self:countChange(1)
	        	__index = __index + 1
	        	if __index >= __count then
	        		if self.countChange == nil then return end
	        		if callback then
	        			callback()
	        		end
	        	end
			else
				if fu:isFileExist(item) then
					local task = pc.LoadResTask:createImageTask(item, RGBAUTO)
	                task:setLuaCallBack(function ()
	                    ScheduleMgr:delayCall(0, self, function()
				        	if self.countChange == nil then return end
				        	self:countChange(1)
				        	__index = __index + 1
				        	if __index >= __count then
				        		if self.countChange == nil then return end
				        		if callback then
				        			callback()
				        		end
				        	end
	                    end)
	                end)
	                ALR:addTask(task) 
				else
		        	if self.countChange == nil then return end
		        	self:countChange(1)
		        	__index = __index + 1
		        	if __index >= __count then
		        		if self.countChange == nil then return end
		        		if callback then
		        			callback()
		        		end
		        	end
				end
			end
		end
	end
	if self._doList[1].count > 0 then
		self._loadTexture()
	else
        if callback then
			callback()
		end
	end
end
-- 载入Plist
function LoadingView:loadPlist(callback)
	self._loadPlist = function ()
		local __count = #self._doList[2].list
		local __index = 0
		for i = 1, __count do
			local item = self._doList[2].list[i]
			if tc:getTextureForKey(item[2]) then
				self:countChange(1)
				__index = __index + 1
	        	if __index >= __count then
	        		if self.countChange == nil then return end
	        		if callback then
	        			callback()
	        		end
	        	end
			else
				if string.find(item[1], "asset/ui") ~= nil then
                    local filename = string.sub(item[2], 10, string.len(item[2]))
                    local plistname = string.sub(item[1], 10, string.len(item[1]))
                    if UI_EX[filename] then
                    	local taskex = pc.LoadResTask:createPlistTask(UIUtils.uiPathEx..plistname, UIUtils.uiPathEx..filename)
                    	taskex:setLuaCallBack(function ()
					        local task = pc.LoadResTask:createPlistTask(item[1], item[2])
					        task:setLuaCallBack(function ()
					        	ScheduleMgr:delayCall(0, self, function()
						        	if self.countChange == nil then return end
						        	self:countChange(1)
						        	__index = __index + 1
						        	if __index >= __count then
						        		if self.countChange == nil then return end
						        		if callback then
						        			callback()
						        		end
						        	end
						        end)
					        end)
					        ALR:addTask(task)
					    end)
					    ALR:addTask(taskex)
				    else
				    	if fu:isFileExist(item[1]) then
					    	local task = pc.LoadResTask:createPlistTask(item[1], item[2])
					        task:setLuaCallBack(function ()
					        	ScheduleMgr:delayCall(0, self, function()
						        	if self.countChange == nil then return end
						        	self:countChange(1)
						        	__index = __index + 1
						        	if __index >= __count then
						        		if self.countChange == nil then return end
						        		if callback then
						        			callback()
						        		end
						        	end
						        end)
					        end)
					        ALR:addTask(task)
				        else
				        	self:countChange(1)
				        	__index = __index + 1
				        	if __index >= __count then
				        		if self.countChange == nil then return end
				        		if callback then
				        			callback()
				        		end
				        	end
				        end
                    end
				else
					if fu:isFileExist(item[1]) then
				        local task = pc.LoadResTask:createPlistTask(item[1], item[2])
				        task:setLuaCallBack(function ()
				        	ScheduleMgr:delayCall(0, self, function()
					        	if self.countChange == nil then return end
					        	self:countChange(1)
					        	__index = __index + 1
					        	if __index >= __count then
					        		if self.countChange == nil then return end
					        		if callback then
					        			callback()
					        		end
					        	end
					        end)
				        end)
				        ALR:addTask(task)
				    else
			        	self:countChange(1)
			        	__index = __index + 1
			        	if __index >= __count then
			        		if self.countChange == nil then return end
			        		if callback then
			        			callback()
			        		end
			        	end
				    end
			    end
		    end
		end
	end
	if self._doList[2].count > 0 then
		self._loadPlist()
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
-- 预加载sound
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
-- 初始化语音系统
function LoadingView:initVoice(callback)
	if self._doList[8].count > 0 then
		VoiceUtils.init(function ()
        	if self.countChange == nil then return end
            self:countChange(1)
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
	ALR = nil
	sfc = nil
	tc = nil
	ALR = nil
	fu = nil
	loadingPicTab = nil
	loadingEffTab = nil
end

return LoadingView