--[[
    Filename:    MovieClipManager.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-07-16 11:40:49
    Description: File description
--]]

local MovieClipManager = class("MovieClipManager")
local cc = cc
local DF = pc.DisplayNodeFactory:getInstance()
local sfc = cc.SpriteFrameCache:getInstance()
local tc = cc.Director:getInstance():getTextureCache()
local fu = cc.FileUtils:getInstance()
local _movieClipManager = nil
local ALR = pc.PCAsyncLoadRes:getInstance()

-- 需要使用8888格式的资源名称
local rgba8888ResName = 
{
    --airenpaoxiao = true,
}

function MovieClipManager:getInstance()
    if _movieClipManager == nil then 
        _movieClipManager = MovieClipManager.new()
        return _movieClipManager
    end
    return _movieClipManager
end

function MovieClipManager:ctor()
    -- clear的时候根据reference来决定是否释放资源
    -- loadRes并不会增加reference, 只有create mc的时候才会增加
    self._reference = {}
    self._request = {}

    self.animPath = "asset/anim/"
    self.animPathEx = "asset/anim/"
end

function MovieClipManager:retain(name)
    if self._reference[name] == nil then
        self._reference[name] = 1
    else
        self._reference[name] = self._reference[name] + 1
    end
end

function MovieClipManager:release(name)
    if self._reference[name] ~= nil and self._reference[name] > 0 then
        self._reference[name] = self._reference[name] - 1
    end
end

local function getResFileName(resname)
    local list = string.split(resname, "_")
    return list[#list]
end

function MovieClipManager:createMovieClip(name, pixelFormat, returnNull)
    local resname = getResFileName(name)
    if pixelFormat == nil then
        pixelFormat = RGBAUTO
    end
    if rgba8888ResName[resname] then
        pixelFormat = RGBAUTO
    end
    cc.Texture2D:setDefaultAlphaPixelFormat(pixelFormat)
    local filename = resname .. "image.png"
    if MOVIECLIP_EX[filename] then
        if not tc:getTextureForKey(self.animPathEx .. filename) then
            sfc:addSpriteFrames(self.animPathEx .. resname .. "image.plist", self.animPathEx .. filename)
        end
    end
    local mc = DF:createMovieClip(name)
    cc.Texture2D:setDefaultAlphaPixelFormat(RGBAUTO)
    if mc then
        mc:registerScriptHandler(function (state)
            if state == "enter" then
                if self._reference[resname] == nil then
                    self._reference[resname] = 1
                else
                    self._reference[resname] = self._reference[resname] + 1
                end
            elseif state == "exit" then
                if self._reference[resname] then
                    self._reference[resname] = self._reference[resname] - 1
                end
            end
        end)
    elseif not returnNull then
        mc = DF:createMovieClip("click_click-HD")
        local label = cc.Label:createWithTTF(name, UIUtils.ttfName, 16)
        label:setPosition(0, -20)
        label:setScaleX(-1)
        label:enableOutline(cc.c4b(0,0,0,255), 2)
        label:setGlobalZOrder(999)
        mc:addChild(label)
        local label = cc.Label:createWithTTF(name, UIUtils.ttfName, 16)
        label:setPosition(0, 20)
        label:enableOutline(cc.c4b(0,0,0,255), 2)
        label:setGlobalZOrder(999)
        mc:addChild(label)
        print("cannot found mc = "..name)
    end
	return mc
end

function MovieClipManager:loadResList(list, progresscallback, endcallback)
    self._progresscallback = progresscallback
    self._endcallback = endcallback
    self._list = list
    self._loadResList = function ()
        local __count = #list
        local __index = 0
        for i = 1, #list do
            ScheduleMgr:delayCall((i - 1) * 5, self, function()
                local item = list[i]
                if self._reference[item] == nil then
                    self._reference[item] = 0
                end
                if fu:isFileExist(self.animPath.. item .."image.png") then
                    if tc:getTextureForKey(self.animPath.. item .."image.png") then
                        if self._progresscallback then
                            self._progresscallback(item)
                            self._progresscallback()
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
                        local format = RGBAUTO
                        if rgba8888ResName[item] then
                            format = RGBAUTO
                        end
                        local filename = item .."image.png"
                        local jtask = pc.LoadResTask:createAnimJsonTask(self.animPath.. item ..".animxml.json")
                        jtask:setLuaCallBack(function ()
                            ScheduleMgr:delayCall(0, self, function()
                                if self._progresscallback then
                                    self._progresscallback()
                                end
                                if MOVIECLIP_EX[filename] then
                                    -- 这里必须嵌套载入，因为需要保证spriteFrame的顺序
                                    local taskex = pc.LoadResTask:createPlistTask(self.animPathEx.. item .."image.plist", self.animPathEx.. filename, format)
                                    taskex:setLuaCallBack(function ()
                                        local task = pc.LoadResTask:createPlistTask(self.animPath.. item .."image.plist", self.animPath.. filename, format)
                                        task:setLuaCallBack(function ()
                                            ScheduleMgr:delayCall(0, self, function()
                                                if self._progresscallback then
                                                    self._progresscallback(item)
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
                                    end)
                                    ALR:addTask(taskex)
                                else
                                    local task = pc.LoadResTask:createPlistTask(self.animPath.. item .."image.plist", self.animPath.. filename, format)
                                    task:setLuaCallBack(function ()
                                        ScheduleMgr:delayCall(0, self, function()
                                            if self._progresscallback then
                                                self._progresscallback(item)
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
                        end)
                        ALR:addTask(jtask)
                    end
                else
                    if self._progresscallback then
                        self._progresscallback(item)
                        self._progresscallback()
                        __index = __index + 1
                    end
                    if __index >= __count then
                        if self._endcallback then
                            self._endcallback()
                            self._progresscallback = nil
                            self._endcallback = nil
                        end
                    end
                end
            end)
        end
    end
    if #self._list > 0 then
        self._loadResList()
    else
        if self._endcallback then
            self._endcallback()
            self._progresscallback = nil
            self._endcallback = nil
        end
    end
end

function MovieClipManager:clear(keepRequest)
    -- dump(self._reference)
    local filename
    for name, reference in pairs(self._reference) do
        if reference <= 0 then
            -- print("mc."..name)
            filename = name .."image.png"
            if MOVIECLIP_EX[filename] then
                sfc:removeSpriteFramesFromFile(self.animPathEx.. name .."image.plist")
                tc:removeTextureForKey(self.animPathEx.. filename)
            end
            sfc:removeSpriteFramesFromFile(self.animPath.. name .."image.plist")
            tc:removeTextureForKey(self.animPath.. filename)
            self._reference[name] = nil
        end
    end
    if not keepRequest then
        self._request = {}
    end
end

local insert = table.insert
function MovieClipManager:loadRes(name, callback, pixelFormat)
    if pixelFormat == nil then
        pixelFormat = RGBAUTO
    end
    local resname = getResFileName(name)
    if self._request[resname] == nil then
        self._request[resname] = {}
        if callback then
            insert(self._request[resname], callback)
        end
        self:_loadRes(resname, pixelFormat)
    else
        if callback then
            insert(self._request[resname], callback)
        end
    end
end

function MovieClipManager:_loadRes(resname, pixelFormat)
    local filename = resname .."image.png"
    if tc:getTextureForKey(self.animPath.. filename) then
        if self._reference[resname] == nil then
            self._reference[resname] = 0
        end
        if self._request[resname] then
            local count = #self._request[resname]
            for i = 1, count do
                self._request[resname][i](resname)
            end
            self._request[resname] = nil
        end
    else
        local jtask = pc.LoadResTask:createAnimJsonTask(self.animPath.. resname ..".animxml.json")
        jtask:setLuaCallBack(function ()
            if MOVIECLIP_EX[filename] then
                local taskex = pc.LoadResTask:createPlistTask(self.animPathEx.. resname .."image.plist", self.animPathEx.. filename, pixelFormat)
                taskex:setLuaCallBack(function ()
                    local task = pc.LoadResTask:createPlistTask(self.animPath.. resname .."image.plist", self.animPath.. filename, pixelFormat)
                    task:setLuaCallBack(function ()
                        ScheduleMgr:delayCall(0, self, function()
                            if self._reference[resname] == nil then
                                self._reference[resname] = 0
                            end
                            if self._request[resname] then
                                local count = #self._request[resname]
                                for i = 1, count do
                                    self._request[resname][i](resname)
                                end
                                self._request[resname] = nil
                            end
                        end)
                    end)
                    ALR:addTask(task)
                end)
                ALR:addTask(taskex)
            else
                local task = pc.LoadResTask:createPlistTask(self.animPath.. resname .."image.plist", self.animPath.. filename, pixelFormat)
                task:setLuaCallBack(function ()
                    ScheduleMgr:delayCall(0, self, function()
                        if self._reference[resname] == nil then
                            self._reference[resname] = 0
                        end
                        if self._request[resname] then
                            local count = #self._request[resname]
                            for i = 1, count do
                                self._request[resname][i](resname)
                            end
                            self._request[resname] = nil
                        end
                    end)
                end)
                ALR:addTask(task)
            end
        end)
        ALR:addTask(jtask)
    end
end

function MovieClipManager:isResLoaded(name)
    local resname = getResFileName(name)
    local filename = resname .."image.png"
    return tc:getTextureForKey(self.animPath.. filename) ~= nil
end

-- void addCallbackAtFrame(int, function)
-- int getCurrentFrame();
-- int getTotalFrames();
-- int getFPS();
-- float getPlaySpeed() { return _speed; }
-- void setPlaySpeed(float val);

-- void play();
-- void stop();
-- void gotoAndPlay(int frame);
-- void gotoAndPlay(const std::string& label);
-- void gotoAndStop(int frame);
-- void gotoAndStop(const std::string& label);
-- bool isPlaying();
-- View用
-- loop 是否循环播放
-- endRemove 播放结束是否释放
function MovieClipManager:createViewMC(name, loop, endRemove, callback, pixelFormat, affectSub, clearCall)
    if pixelFormat == nil then
        pixelFormat = RGBAUTO
    end
    if affectSub == nil then 
        affectSub = true 
    end

    if clearCall == nil then
        clearCall = true 
    end
    cc.Texture2D:setDefaultAlphaPixelFormat(pixelFormat)
    local mc = self:createMovieClip(name, pixelFormat)
    cc.Texture2D:setDefaultAlphaPixelFormat(RGBAUTO)
    mc:addEndCallback(function (_, sender)
        if callback then
            callback(_, sender)
        end
        if not loop and clearCall then
            sender:clearCallbacks()
            sender:stop(affectSub)
        end
        if endRemove then
            sender:clearCallbacks()
            sender:stop(affectSub)
            sender:removeFromParent()
        end
    end)
    return mc
end

function MovieClipManager.dtor()
    _movieClipManager = nil
    cc = nil
    DF = nil
    fu = nil
    getResFileName = nil
    insert = nil
    MovieClipManager = nil
    rgba8888ResName = nil
    sfc = nil
    tc = nil
end

return MovieClipManager