--[[
	Filename:    SpriteFrameResManager.lua
	Author:      <huachangmiao@playcrab.com>
	Datetime:    2015-02-02 15:03:45
	Description: File description
--]]

-- 序列帧资源管理器
-- 异步加载 并cache spriteframe
local SpriteFrameResManager = class("SpriteFrameResManager")
local cc = cc

-- "资源名称中含有siege的视为城墙, 需要用png后缀"
local _spriteFrameResManager = nil
local fu = cc.FileUtils:getInstance()
local tc = cc.Director:getInstance():getTextureCache()
local sfc = cc.SpriteFrameCache:getInstance()
function SpriteFrameResManager:getInstance()
	if _spriteFrameResManager == nil  then 
		_spriteFrameResManager = SpriteFrameResManager.new()
		return _spriteFrameResManager
	end
	return _spriteFrameResManager
end

function SpriteFrameResManager:ctor()

end

function SpriteFrameResManager:init()
	self._cache = {} 
	self._request = {}
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
			-- print("sf."..name)
			sfc:removeSpriteFramesFromFile("asset/role/".. k ..".plist")
			tc:removeTextureForKey("asset/role/".. k .. ".png")
			if self._cache[k].add ~= nil then
				for i = 1, self._cache[k].add do
					sfc:removeSpriteFramesFromFile("asset/role/".. k .. i .. ".plist")
					tc:removeTextureForKey("asset/role/".. k .. i .. ".png")
				end
			end
			local has = true
			for m, _ in pairs(self._cache[k]) do
				if type(m) == "number" then
					for f = 1, #self._cache[k][m] do
						if self._cache[k][m][f].sf1 then
							self._cache[k][m][f].sf1:release()
						else
							has = false
							break
						end
					end
				end
				if not has then
					break
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
-- onlyColor 是否只有变色, 可以删除原色纹理
function SpriteFrameResManager:cache(filename, cacheColor, onlyColor)
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
		self._cache[resname] = {reference = 0}
	end
	self._cache[resname].add = add
	local len, motion, frame, cache
	local index = 1
	local map = fu:getValueMapFromFile("asset/role/".. filename ..".plist")
	for k, v in pairs(map["frames"]) do
		len = slen(k)
		motion = tonumber(sub(k, len - 8, len - 7))
		frame = tonumber(sub(k, len - 5, len - 4))
		if motion ~= nil then
			if frame == nil then
				frame = index
				index = index + 1
			end
			local sf = sfc:getSpriteFrame(k)
			local sfframe = {sf = sf}
			cache = self._cache[resname]
			if cache[motion] == nil then
				cache[motion] = {}
				cache[motion][frame] = sfframe
			else
				if cache[motion][frame] then
					-- print(resname, motion, frame)
					cache[motion][frame].sf = sf
				else
					cache[motion][frame] = sfframe
				end
			end
			if motion == 1 and frame == 1 then
				-- cache.centerX = (sf:getOriginalSize().width - sf:getRectInPixels().width) * 0.5
				-- cache.centerY = (sf:getOriginalSize().height - sf:getRectInPixels().height) * 0.5
				cache.width = sf:getRectInPixels().width
				cache.height = sf:getRectInPixels().height
			end
		end
	end
	-- 缓存替换特征颜色
	if cacheColor and fu:isFileExist("asset/role/".. filename .."_e"..".png") then
		self._cache[resname].cacheColor = true
		local sp = cc.Sprite:create("asset/role/".. filename ..".png")
		local width = sp:getContentSize().width
		local height = sp:getContentSize().height
		sp:setPosition(width * 0.5, height * 0.5)

		local rt = cc.RenderTexture:create(width, height, RGBART)
		rt:begin()
		sp:setScaleY(-1)
		sp:visit()

		local list = {}

		local map1 = cc.FileUtils:getInstance():getValueMapFromFile("asset/role/".. filename ..".plist")
		local map2 = cc.FileUtils:getInstance():getValueMapFromFile("asset/role/".. filename .."_e.plist")
		-- cc.Texture2D:setDefaultAlphaPixelFormat(RGBA4444)
		local tex = tc:addImage("asset/role/".. filename .."_e"..".png")
		-- cc.Texture2D:setDefaultAlphaPixelFormat(RGBAUTO)
		local frames = map2["frames"]
		local frame1, frame2, key, source, offset1, offset2
		local x, y, w, h
		local rotated1, rotated2
		for k, v in pairs(map1["frames"]) do
			local len = slen(k)
			key = sub(k, 1, len - 10) .. "_e" .. sub(k, len - 9, len)
			if list[v["frame"]] == nil then
				frame1 = unserialize(v["frame"])
				frame2 = unserialize(frames[key]["frame"])
				source = unserialize(frames[key]["sourceSize"])
				offset1 = unserialize(v["offset"])
				offset2 = unserialize(frames[key]["offset"])
				sp = cc.Sprite:createWithTexture(tex)
				local rr = tostring(frames[key]["rotated"])
				if rr == "true" or rr == "1" then
					rotated1 = true
				else
					rotated1 = false
				end
				rr = tostring(v["rotated"])
				if rr == "true" or rr == "1" then
					rotated2 = true
				else
					rotated2 = false
				end
				sp:setTextureRect(cc.rect(frame2[1][1], frame2[1][2], frame2[2][1], frame2[2][2]), rotated1, cc.size(source[1], source[2]))
				
				x, y, w, h = frame1[1][1], frame1[1][2], frame1[2][1], frame1[2][2]       
				if rotated2 then
					sp:setScaleX(-1)
					sp:setRotation(90)
					sp:setPosition((x + h * 0.5 - offset1[2] + offset2[2]), (y + w * 0.5 - offset1[1] + offset2[1]))
				else
					sp:setScaleY(-1)
					sp:setPosition((x + w * 0.5 - offset1[1] + offset2[1]), (y + h * 0.5 + offset1[2] - offset2[2]))
				end
				sp:visit()
				list[v["frame"]] = true
			end
		end
		rt:endToLua()

		list = {}
		local len
		local texture = rt:getSprite():getTexture()
		texture:setAntiAliasTexParameters()
		for k, v in pairs(map1["frames"]) do
			len = slen(k)
			motion = tonumber(sub(k, len - 8, len - 7))
			frame = tonumber(sub(k, len - 5, len - 4))
			if list[v["frame"]] == nil then
				offset1 = unserialize(v["offset"])
				frame1 = unserialize(v["frame"])
				source = unserialize(v["sourceSize"])
				local rr = tostring(v["rotated"])
				if rr == "true" or rr == "1" then
					rotated1 = true
				else
					rotated1 = false
				end
				local sf = cc.SpriteFrame:createWithTexture(texture, cc.rect(frame1[1][1], frame1[1][2], frame1[2][1], frame1[2][2]),
															rotated1, cc.p(offset1[1], offset1[2]), cc.size(source[1], source[2]))
				sf:retain()
				self._cache[resname][motion][frame].sf1 = sf
				list[v["frame"]] = sf
			else
				self._cache[resname][motion][frame].sf1 = list[v["frame"]]
				list[v["frame"]]:retain()
			end
		end   
		self._cache[resname].texture = texture
		tc:removeTextureForKey("asset/role/".. filename .."_e"..".png")
		if onlyColor then
			tc:removeTextureForKey("asset/role/".. filename ..".png")
		end
	else
		self._cache[resname].cacheColor = false
	end
end

function SpriteFrameResManager:getCache(filename, cacheColor)
	return self._cache[filename]
end

local insert = table.insert
function SpriteFrameResManager:loadRes(filename, cacheColor, callback)
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
		self:_loadRes(filename, fileList, cacheColor, callback, 1)
	else
		if callback then
			insert(self._request[filename], callback)
		end
	end
end

function SpriteFrameResManager:_loadRes(filename, list, cacheColor, callback, index)
	local name = list[index]
	if tc:getTextureForKey("asset/role/".. name ..".png") then
		self:cache(name, cacheColor)
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
			self:_loadRes(filename, list, cacheColor, callback, index + 1)
		end
	else
		local task = pc.LoadResTask:createPlistTask("asset/role/".. name ..".plist", "asset/role/".. name ..".png", RGBAUTO)
		task:setLuaCallBack(function ()
			ScheduleMgr:delayCall(0, self, function()
				self:cache(name, cacheColor)
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
					self:_loadRes(filename, list, cacheColor, callback, index + 1)
				end
			end)
		end)
		pc.PCAsyncLoadRes:getInstance():addTask(task)
	end
end

function SpriteFrameResManager:getResListRealCount(list)
	local count = #list
	local realCount = count
	for i = 1, count do
		local k = 1
		while true do
			if fu:isFileExist("asset/role/".. list[i][1] .. k .. ".png") then
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
	local count = #list
	for i = 1, count do
		local k = 1
		while true do
			if fu:isFileExist("asset/role/".. list[i][1] .. k .. ".png") then
				list[#list + 1] = {list[i][1] .. k, list[i][2]}
			else
				break
			end
			k = k + 1
		end
	end
	if #list > 0 then
		self:_loadResList(list, 1)
	end
end

function SpriteFrameResManager:_loadResList(list, index)
	local count = #list
	local pixelFormat = RGBAUTO
	if tc:getTextureForKey("asset/role/".. list[index][1] ..".png") then
		self:cache(list[index][1], list[index][2] >= 2, list[index][2] == 2)
		if self._progresscallback then
			self._progresscallback(index, count, list[index][1])
		end
		if count == index then
			if self._endcallback then
				self._endcallback()
				self._progresscallback = nil
				self._endcallback = nil
			end
		else
			self:_loadResList(list, index + 1)
		end
	else
		local task = pc.LoadResTask:createPlistTask("asset/role/".. list[index][1] ..".plist", "asset/role/".. list[index][1] ..".png", pixelFormat)
		task:setLuaCallBack(function ()
			self:cache(list[index][1], list[index][2] >= 2, list[index][2] == 2)
			if self._progresscallback then
				self._progresscallback(index, count, list[index][1])
			end
			if count == index then
				if self._endcallback then
					self._endcallback()
					self._progresscallback = nil
					self._endcallback = nil
				end
			else
				self:_loadResList(list, index + 1)
			end
		end)
		pc.PCAsyncLoadRes:getInstance():addTask(task)
	end
end

return SpriteFrameResManager
