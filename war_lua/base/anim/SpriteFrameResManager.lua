--[[
	Filename:    SpriteFrameResManager.lua
	Author:      <huachangmiao@playcrab.com>
	Datetime:    2015-02-02 15:03:45
	Description: File description
--]]

-- 序列帧资源管理器
-- 异步加载 并cache spriteframe

-- *******打图策略*******
-- 蓝色: qishi/qishi_0x_0x.png
-- 红色: qishi_e/qishi_e_0x_0x.png
-- 为了2的幂次方使用率最大化
-- 支持单颜色多图集
-- 蓝色: qishi/qishi_0x_0x.png  qishi1/qishi_0x_0x.png  qishi2/qishi_0x_0x.png
-- 红色: qishi_e/qishi_e_0x_0x.png  qishi_e1/qishi_e_0x_0x.png  qishi_e2/qishi_e_0x_0x.png
-- 支持混色图集
-- 蓝色&红色 qishi/qishi_0x_0x.png  qishi/qishi_e_0x_0x.png

local SpriteFrameResManager = class("SpriteFrameResManager")
local cc = cc

local _spriteFrameResManager = nil
local fu = cc.FileUtils:getInstance()
local tc = cc.Director:getInstance():getTextureCache()
local sfc = cc.SpriteFrameCache:getInstance()
local ALR = pc.PCAsyncLoadRes:getInstance()

function SpriteFrameResManager:getInstance()
	if _spriteFrameResManager == nil  then 
		_spriteFrameResManager = SpriteFrameResManager.new()
		return _spriteFrameResManager
	end
	return _spriteFrameResManager
end

function SpriteFrameResManager:ctor()
	self._cache = {} 
	self._request = {}
end

function SpriteFrameResManager:retain(name)
    if self._cache[name] == nil then
        self._cache[name] = {reference = 1}
    else
        self._cache[name].reference = self._cache[name].reference + 1
    end
end

function SpriteFrameResManager:release(name)
    if self._cache[name] ~= nil and self._cache[name].reference > 0 then
        self._cache[name].reference = self._cache[name].reference - 1
    end
end

function SpriteFrameResManager:referenceAdd(name)
	if self._cache[name] then
		self._cache[name].reference = self._cache[name].reference + 1
	end
end

function SpriteFrameResManager:referenceDec(name)
	if self._cache[name] then
		self._cache[name].reference = self._cache[name].reference - 1
	end
end

-- 是否清除请求
function SpriteFrameResManager:clear(keepRequest)
	for k, v in pairs(self._cache) do
		if self._cache[k].reference <= 0 and self._request[k] == nil then
			-- print("sf."..k)
			sfc:removeSpriteFramesFromFile("asset/role/".. k ..".plist")
			tc:removeTextureForKey("asset/role/".. k .. ".png")
			if self._cache[k].add ~= nil then
				for i = 1, self._cache[k].add do
					sfc:removeSpriteFramesFromFile("asset/role/".. k .. i .. ".plist")
					tc:removeTextureForKey("asset/role/".. k .. i .. ".png")
				end
			end
			self._cache[k] = nil
		end
	end
    if not keepRequest then
        self._request = {}
    end
end

local slen = string.len
local tonumber = tonumber
local sub = string.sub
local unserialize = unserialize
function SpriteFrameResManager:cache(filename)
	local resname
	local len = slen(filename)
	local add =  tonumber(sub(filename, len, len))
	if add == nil then
		resname = filename
		if self._cache[resname] == nil then
			self._cache[resname] = {reference = 0}
		end
	else
		resname = sub(filename, 1,  len - 1)
		if self._cache[resname] == nil then
			sfc:removeSpriteFramesFromFile("asset/role/".. filename .. ".plist")
			tc:removeTextureForKey("asset/role/".. filename ..".png")
			return
		end
	end
	if self._cache[resname] == nil then
		self._cache[resname] = {reference = 0, width = 0, height = 0, has2color = false}
	end
	self._cache[resname].add = add
	local len, motion, frame, cache
	local index = 1
	local changeColor = false
	if string.find(filename, "_e_") then
		changeColor = true
	end
	local colorType
	if not fu:isFileExist("asset/role/".. filename ..".plist") then return end
	local map = fu:getValueMapFromFile("asset/role/".. filename ..".plist")
	for k, v in pairs(map["frames"]) do
		len = slen(k)
		if string.find(k, "_e_") then
			colorType = true
		else
			colorType = false
		end
		motion = tonumber(sub(k, len - 8, len - 7))
		frame = tonumber(sub(k, len - 5, len - 4))
		if motion ~= nil then
			if frame == nil then
				frame = index
				index = index + 1
			end
			local sf = sfc:getSpriteFrame(k)

			cache = self._cache[resname]
			if cache[motion] == nil then
				cache[motion] = {}
			end
			if cache[motion][frame] == nil then
				cache[motion][frame] = {}
			end
			if changeColor == colorType then
				cache[motion][frame].sf = sf
			else
				cache[motion][frame].sf1 = sf
				cache.has2color = true
			end

			if motion == 1 and frame == 1 then
				-- cache.centerX = (sf:getOriginalSize().width - sf:getRectInPixels().width) * 0.5
				-- cache.centerY = (sf:getOriginalSize().height - sf:getRectInPixels().height) * 0.5
				cache.width = sf:getRectInPixels().width
				cache.height = sf:getRectInPixels().height
			end
		end
	end
end

function SpriteFrameResManager:getCache(filename)
	return self._cache[filename]
end

local insert = table.insert
function SpriteFrameResManager:loadRes(filename, callback)
	if self._request[filename] == nil then
		self._request[filename] = {}
		if callback then
			insert(self._request[filename], callback)
		end
		local fileList = {filename}
		local k = 1
		while true do
			if fu:isFileExist("asset/role/".. filename .. k .. ".png") then
				fileList[#fileList + 1] = filename .. k
			else
				break
			end
			k = k + 1
		end
		self:_loadRes(filename, fileList, callback, 1)
	else
		if callback then
			insert(self._request[filename], callback)
		end
	end
end

function SpriteFrameResManager:_loadRes(filename, list, callback, index)
	local name = list[index]
	if tc:getTextureForKey("asset/role/".. name ..".png") then
		self:cache(name)
		if index == #list then
			if self._request[filename] then
				local count = #self._request[filename]
				for i = 1, count do
					self._request[filename][i](self._cache[filename])
					self._request[filename][i] = nil
				end
				self._request[filename] = nil
			end
		else
			self:_loadRes(filename, list, callback, index + 1)
		end
	else
		local task = pc.LoadResTask:createPlistTask("asset/role/".. name ..".plist", "asset/role/".. name ..".png", RGBAUTO)
		task:setLuaCallBack(function ()
			ScheduleMgr:delayCall(0, self, function()
				self:cache(name)
				if index == #list then
					if self._request[filename] then
						local count = #self._request[filename]
						for i = 1, count do
							self._request[filename][i](self._cache[filename])
							self._request[filename][i] = nil
						end
						self._request[filename] = nil
					end
				else
					self:_loadRes(filename, list, callback, index + 1)
				end
			end)
		end)
		ALR:addTask(task)
	end
end

function SpriteFrameResManager:getResListRealCount(list)
	local realList = {}
	local count = #list
	for i = 1, count do
		if list[i][2] == 1 then
			if fu:isFileExist("asset/role/".. list[i][1] .. ".png") then
				realList[#realList + 1] = list[i][1]
			end
		elseif list[i][2] == 2 then
			if fu:isFileExist("asset/role/".. list[i][1] .. "_e.png") then
				realList[#realList + 1] = list[i][1] .. "_e"
			elseif fu:isFileExist("asset/role/".. list[i][1] .. ".png") then
				realList[#realList + 1] = list[i][1]
			end
		else
			if fu:isFileExist("asset/role/".. list[i][1] .. ".png") then
				realList[#realList + 1] = list[i][1]
			end
			if fu:isFileExist("asset/role/".. list[i][1] .. "_e.png") then
				realList[#realList + 1] = list[i][1] .. "_e"
			end
		end
	end

	local count = #realList
	local realCount = count
	for i = 1, count do
		local k = 1
		while true do
			if fu:isFileExist("asset/role/".. realList[i] .. k .. ".png") then
				realCount = realCount + 1
			else
				break
			end
			k = k + 1
		end
	end
	return realCount
end

function SpriteFrameResManager:loadResList(list, progresscallback, endcallback)
	self._progresscallback = progresscallback
	self._endcallback = endcallback

	local realList = {}
	local count = #list
	for i = 1, count do
		if list[i][2] == 1 then
			if fu:isFileExist("asset/role/".. list[i][1] .. ".png") then
				realList[#realList + 1] = list[i][1]
			end
		elseif list[i][2] == 2 then
			if fu:isFileExist("asset/role/".. list[i][1] .. "_e.png") then
				realList[#realList + 1] = list[i][1] .. "_e"
			elseif fu:isFileExist("asset/role/".. list[i][1] .. ".png") then
				realList[#realList + 1] = list[i][1]
			end
		else
			if fu:isFileExist("asset/role/".. list[i][1] .. ".png") then
				realList[#realList + 1] = list[i][1]
			end
			if fu:isFileExist("asset/role/".. list[i][1] .. "_e.png") then
				realList[#realList + 1] = list[i][1] .. "_e"
			end
		end
	end

	local count = #realList
	for i = 1, count do
		local k = 1
		while true do
			if fu:isFileExist("asset/role/".. realList[i] .. k .. ".png") then
				realList[#realList + 1] = realList[i] .. k
			else
				break
			end
			k = k + 1
		end
	end
	if #list > 0 then
		self:_loadResList(realList)
	end
end

function SpriteFrameResManager:_loadResList(list)
	local __count = #list
	local __index = 0
	for i = 1, __count do
		ScheduleMgr:delayCall((i - 1) * 5, self, function()
			local pixelFormat = RGBAUTO
			local filename = list[i]
			if tc:getTextureForKey("asset/role/".. filename ..".png") then
				self:cache(filename)
				if self._progresscallback then
					self._progresscallback(i, __count, filename)
				end
				__index = __index + 1
				if __index >= __count then
					if self._endcallback then
						self._endcallback()
						self._progresscallback = nil
						self._endcallback = nil
					end
				end
			else
				local task = pc.LoadResTask:createPlistTask("asset/role/".. filename ..".plist", "asset/role/".. filename ..".png", pixelFormat)
				task:setLuaCallBack(function ()
					ScheduleMgr:delayCall(0, self, function()
						trycall("SpriteFrameResManager:_loadResList", self.cache, self, filename)
						if self._progresscallback then
							self._progresscallback(i, __count, filename)
						end
						__index = __index + 1
						if __index >= __count then
							if self._endcallback then
								self._endcallback()
								self._progresscallback = nil
								self._endcallback = nil
							end
						end
					end)
				end)
				ALR:addTask(task)
			end
		end)
	end
end

function SpriteFrameResManager.dtor()
	_spriteFrameResManager = nil
	cc = nil
	fu = nil
	insert = nil
	sfc = nil
	slen = nil
	SpriteFrameResManager = nil
	sub = nil
	tc = nil
	tonumber = nil
	unserialize = nil
end

return SpriteFrameResManager
