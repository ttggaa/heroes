--[[
    Filename:    UpdateView.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-04-20 16:31:14
    Description: File description
--]]

local UpdateView = class("UpdateView")

local MAX_SCREEN_WIDTH = cc.Director:getInstance():getWinSizeInPixels().width 
local MAX_SCREEN_HEIGHT = cc.Director:getInstance():getWinSizeInPixels().height
local MAX_SCREEN_REAL_WIDTH, MAX_SCREEN_REAL_HEIGHT = MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT
if MAX_SCREEN_WIDTH > 1600 then
    MAX_SCREEN_WIDTH = 1600
end
local SCREEN_X_OFFSET = (MAX_SCREEN_REAL_WIDTH - MAX_SCREEN_WIDTH) * 0.5
local tc = cc.Director:getInstance():getTextureCache()
local sfc = cc.SpriteFrameCache:getInstance()
local ttf = cc.FileUtils:getInstance():fullPathForFilename("static/common.ttf")
local ttf_title = cc.FileUtils:getInstance():fullPathForFilename("static/common.ttf")
local ttf_number = cc.FileUtils:getInstance():fullPathForFilename("static/common.ttf")
local ALR = pc.PCAsyncLoadRes:getInstance()
local fu = cc.FileUtils:getInstance()

local function ButtonBeginAnim(view)
    if view:isScaleAnim() then
        local ax, ay = view:getAnchorPoint().x, view:getAnchorPoint().y
        if ax == 0.5 and ay == 0.5 then
            if view.__oriScale == nil then
                view.__oriScale = view:getScaleX()
            end
            local scaleMin = 0.8
            if view.__scaleMin then
                scaleMin = view.__scaleMin
            end
            view:stopAllActions()
            view:setScale(view.__oriScale * 0.95)
            view:runAction(cc.EaseIn:create(cc.ScaleTo:create(0.05, view.__oriScale * scaleMin), 2))
        end
    end
end

local function ButtonEndAnim(view)
    if view:isScaleAnim() then
        local ax, ay = view:getAnchorPoint().x, view:getAnchorPoint().y
        if ax == 0.5 and ay == 0.5 then
            view:stopAllActions()
            if view.__oriScale then
                local scaleMin = 0.8
                if view.__scaleMin then
                    scaleMin = view.__scaleMin
                end
                local rate = 1 - ((view:getScaleX() - view.__oriScale * scaleMin) / (view.__oriScale * 0.2))
                view:runAction(cc.Sequence:create(
                    cc.ScaleTo:create(0.02 + 0.03 * rate, view.__oriScale * (1.00 + 0.05 * rate)), 
                    cc.ScaleTo:create(0.02 + 0.03 * rate, view.__oriScale * (1.00 - 0.05 * rate)),
                    cc.ScaleTo:create(0.02 + 0.03 * rate, view.__oriScale)
                ))
            end
        end
    end
end

function UpdateView:ctor(scene)
    scene:setPositionX(SCREEN_X_OFFSET)
    self._rootLayer = scene
    
	self._bg = cc.Sprite:create("asset/bg/bg_071.jpg")
    if self._bg == nil then return end
    local xscale = MAX_SCREEN_WIDTH / self._bg:getContentSize().width
    local yscale = MAX_SCREEN_HEIGHT / self._bg:getContentSize().height
    if xscale > yscale then
        self._bg:setScale(xscale)
    else
        self._bg:setScale(yscale)
    end
    self._bg:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    self._rootLayer:addChild(self._bg)

    self._mask = ccui.Layout:create()
    self._mask:setBackGroundColorOpacity(40)
    self._mask:setBackGroundColorType(1)
    self._mask:setBackGroundColor(cc.c3b(0,0,0))
    self._mask:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._rootLayer:addChild(self._mask)

    self._widget = ccs.GUIReader:getInstance():widgetFromBinaryFile("asset/ui/UpdateView.csb")
    self._widget:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._rootLayer:addChild(self._widget)

    self._widget:setCascadeOpacityEnabled(true, true)
    self._widget:setOpacity(0)

    self._dialog0 = self:getUI("bg.dialog0")
    self._dialog1 = self:getUI("bg.dialog1")
    self._probg = self:getUI("probg")
    self._proLabel1 = self:getUI("probg.label1")
    self._proLabel2 = self:getUI("probg.label2")
    self._proLabel3 = self:getUI("probg.label3")
    self._pro = self:getUI("probg.pro")
    
    self._probg:setVisible(false)
    self._proLabel1:enableShadow(cc.c4b(0, 0, 0, 255))
    self._proLabel2:enableShadow(cc.c4b(0, 0, 0, 255))
    self._proLabel3:enableShadow(cc.c4b(0, 0, 0, 255))

    self._network = self:getUI("network")
    self._network:setString("网络环境: 局域网")

    self._dialog0:setVisible(false)
    local des = cc.Label:createWithTTF("", ttf, 18)
    des:setColor(cc.c3b(255, 255, 255))
    des:setAnchorPoint(0.5, 0.5)
    des:setDimensions(308, 86)
    des:setHorizontalAlignment(1)
    des:setVerticalAlignment(1)
    des:setPosition(self._dialog0:getContentSize().width*0.5, self._dialog0:getContentSize().height*0.5)
    self._dialog0:addChild(des)
    self._dialog0.des = des

    self._dialog1:setVisible(false)
    local des = cc.Label:createWithTTF("", ttf, 18)
    des:setColor(cc.c3b(255, 255, 255))
    des:setAnchorPoint(0.5, 0.5)
    des:setDimensions(308, 86)
    des:setHorizontalAlignment(1)
    des:setVerticalAlignment(1)
    des:setPosition(174, 94)

    self._dialog1:addChild(des)
    self._dialog1.des = des
    self._dialog1.error = self:getUI("bg.dialog1.error")

    self._dialog1.btn1 = self:getUI("bg.dialog1.btn1")
    self._cacheBtn1PosX = self._dialog1.btn1:getPositionX()

    self._dialog1.btn2 = self:getUI("bg.dialog1.btn2")

    self._dialog1.btn1:getTitleRenderer():enableOutline(cc.c4b(140, 52, 7, 255), 2)
    self._dialog1.btn1:setTitleFontSize(26)
    self._dialog1.btn2:getTitleRenderer():enableOutline(cc.c4b(115, 63, 32, 255), 2)
    self._dialog1.btn2:setTitleFontSize(26)

    local mc = pc.DisplayNodeFactory:getInstance():createMovieClip("jiazaizhong_rankjiazaizhong")
    mc:getChildren()[1]:setVisible(false)
    mc:setScale(1.5)
    mc:setPosition(4, 106)
    self._dialog1:addChild(mc)

    self._udpateAsset = false
    -- [[
    if SCREEN_X_OFFSET == 0 then return end
    
    local leftBar = cc.Sprite:create("asset/bg/screen_width_bar.jpg")
    leftBar:setAnchorPoint(1,0.5)
    leftBar:setPosition(0,self._bg:getContentSize().height/2)
    leftBar:setFlipX(true)
    local barWidth = leftBar:getContentSize().width 
    local barHeight = leftBar:getContentSize().height
    local antiScale = self._bg:getScale()
    if MAX_SCREEN_REAL_HEIGHT > barHeight then
        local scale = MAX_SCREEN_REAL_HEIGHT / barHeight
        leftBar:setScale(scale/antiScale)
    end
    self._bg:addChild(leftBar,100)

    local rightBar = cc.Sprite:create("asset/bg/screen_width_bar.jpg")
    rightBar:setAnchorPoint(0,0.5)
    rightBar:setPosition(self._bg:getContentSize().width,self._bg:getContentSize().height/2)
    local barWidth = rightBar:getContentSize().width 
    local barHeight = rightBar:getContentSize().height
    if MAX_SCREEN_REAL_HEIGHT > barHeight then
        local scale = MAX_SCREEN_REAL_HEIGHT / barHeight
        rightBar:setScale(scale/antiScale)
    end
    self._bg:addChild(rightBar,100)
    --]]
end

function UpdateView:aysncLoadRes(list, callback)
    if #list > 0 then
        self:loadRes(list, callback, 1)
    else
        if callback then
            callback()
        end
    end
end

function UpdateView:loadRes(list, callback, index)
    local task
    if string.find(list[index][1], "asset/ui") ~= nil then
        local filename = string.sub(list[index][2], 10, string.len(list[index][2]))
        if UI_EX[filename] then
            local plistname = string.sub(list[index][1], 10, string.len(list[index][1]))
            local taskex = pc.LoadResTask:createPlistTask(UI_EX..plistname, UI_EX..filename, RGBAUTO)
            taskex:setLuaCallBack(function ()
                task = pc.LoadResTask:createPlistTask(list[index][1], list[index][2])
                task:setLuaCallBack(function ()
                    ScheduleMgr:delayCall(0, self, function()
                        if index < #list then
                            self:loadRes(list, callback, index + 1)
                        else
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
            task = pc.LoadResTask:createPlistTask(list[index][1], list[index][2])
            task:setLuaCallBack(function ()
                ScheduleMgr:delayCall(0, self, function()
                    if index < #list then
                        self:loadRes(list, callback, index + 1)
                    else
                        if callback then
                            callback()
                        end
                    end
                end)
            end)
            ALR:addTask(task) 
        end
    else
        if string.find(list[index][1], "asset/anim") ~= nil then
            local animjson = string.gsub(list[index][1], "image.plist", ".animxml.json")
            local jtask = pc.LoadResTask:createAnimJsonTask(animjson)
            jtask:setLuaCallBack(function ()
                ScheduleMgr:delayCall(0, self, function()
                    if list[index][3] then
                        task = pc.LoadResTask:createPlistTask(list[index][1], list[index][2], list[index][3])
                    else
                        task = pc.LoadResTask:createPlistTask(list[index][1], list[index][2])
                    end
                    task = pc.LoadResTask:createPlistTask(list[index][1], list[index][2])
                    task:setLuaCallBack(function ()
                        ScheduleMgr:delayCall(0, self, function()
                            if index < #list then
                                self:loadRes(list, callback, index + 1)
                            else
                                if callback then
                                    callback()
                                end
                            end
                        end)
                    end)
                    ALR:addTask(task) 
                end)
            end)
            ALR:addTask(jtask) 
        else
            if list[index][3] then
                task = pc.LoadResTask:createPlistTask(list[index][1], list[index][2], list[index][3])
            else
                task = pc.LoadResTask:createPlistTask(list[index][1], list[index][2])
            end
            task = pc.LoadResTask:createPlistTask(list[index][1], list[index][2])
            task:setLuaCallBack(function ()
                ScheduleMgr:delayCall(0, self, function()
                    if index < #list then
                        self:loadRes(list, callback, index + 1)
                    else
                        if callback then
                            callback()
                        end
                    end
                end)
            end)
            ALR:addTask(task) 
        end
    end
end

function UpdateView:getUI(name)
    return self._widget:getChildByFullName(name)
end

function UpdateView:delayCall(time, func)
    local updateId
	updateId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(updateId) 
		func()
	end, time, false)
end

-- 显示提示信息
function UpdateView:showInfo(des, callback)
    if self._dialog1:isVisible() then
        self:closeDialog(function ()
            self:_showInfo(des, callback)
        end)
    else
        self:_showInfo(des, callback)
    end
end

function UpdateView:_showInfo(des, callback)
	self._dialog0:stopAllActions()
	self._dialog0.des:setString(des)
	self._dialog0:setVisible(true)
    self._dialog0:setScale(0)
    self._dialog0:runAction(cc.Sequence:create(cc.EaseOut:create(cc.ScaleTo:create(0.1, 1.00), 2), cc.DelayTime:create(0.05), cc.CallFunc:create(function ()
    	if callback then callback() end
    end)))
end

-- 关闭提示信息
function UpdateView:closeInfo(callback)
	self._dialog0:stopAllActions()
    self._dialog0:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 0.7), cc.CallFunc:create(function () self._dialog0:setVisible(false) end), 
    	cc.DelayTime:create(0.05), 
        cc.CallFunc:create(function ()
	        if callback then
	            callback()
	        end
    end)))
end

-- 打开对话框
function UpdateView:waitBeforeConfim()
    if self._waitUpdateId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._waitUpdateId) 
        self._waitUpdateId = nil
    end
    local waitBeginTick = os.time()
    self._dialog1.btn1:setSaturation(-100)
    self._dialog1.btn1:setTitleText("3")
    self._dialog1.btn1:setTouchEnabled(false)
    -- self._dialog1.btn2:setSaturation(-100)
    -- self._dialog1.btn2:setTitleText("3")
    -- self._dialog1.btn2:setTouchEnabled(false)
    self._waitUpdateId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()
        local tick = os.time()
        self._dialog1.btn1:setTitleText((3 - math.floor(tick - waitBeginTick)))
        -- self._dialog1.btn2:setTitleText((3 - math.floor(tick - waitBeginTick)))
        if tick >= waitBeginTick + 3 then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._waitUpdateId) 
            self._waitUpdateId = nil
            self._dialog1.btn1:setSaturation(0)
            self._dialog1.btn1:setTitleText("确定")
            self._dialog1.btn1:setTouchEnabled(true)
            -- self._dialog1.btn2:setSaturation(0)
            -- self._dialog1.btn2:setTitleText("取消")
            -- self._dialog1.btn2:setTouchEnabled(true)
        end
    end, 0.01, false)
end

function UpdateView:showDialog(errorCode, des, callback, callback1, callback2, ex)
    if self._dialog0:isVisible() then
        self:closeInfo(function ()
            self:_showDialog(errorCode, des, callback, callback1, callback2, ex)
        end)
    else
        self:_showDialog(errorCode, des, callback, callback1, callback2, ex)
    end
end
function UpdateView:_showDialog(errorCode, des, callback, callback1, callback2, ex)
	self._dialog1:stopAllActions()
	self._dialog1.des:setString(des)
	self._dialog1:setVisible(true)
    self._dialog1:setScale(0)
    self._dialog1:runAction(cc.Sequence:create(cc.EaseOut:create(cc.ScaleTo:create(0.1, 1.00), 2), cc.DelayTime:create(0.05), cc.CallFunc:create(function ()
    	if callback then callback() end
    end)))
    self._dialog1.btn1:addTouchEventListener(function (sender, eventType)
        if eventType == 0 then
            ButtonBeginAnim(sender)
        elseif eventType == 2 then
            ButtonEndAnim(sender)
    		self:closeDialog(callback1)
    	elseif eventType == 3 then
            ButtonEndAnim(sender)
        end
    end)
    if callback2 == nil then 
        self._dialog1.btn1:setPositionX(self._dialog1:getContentSize().width/2)
        self._dialog1.btn2:setVisible(false)
    else
        self._dialog1.btn1:setPositionX(self._cacheBtn1PosX)
        self._dialog1.btn2:setVisible(true)
        self._dialog1.btn2:addTouchEventListener(function (sender, eventType)
            if eventType == 0 then
                ButtonBeginAnim(sender)
            elseif eventType == 2 then
                ButtonEndAnim(sender)
                self:closeDialog(callback2)
            elseif eventType == 3 then
                ButtonEndAnim(sender)
            end
        end)
    end   
    if errorCode then
        self._dialog1.error:setString(errorCode)
        if GameStatic.uploadErrorCode then
            if ex == nil then
                ex = ""
            end
            ApiUtils.playcrab_lua_error("errorCode_"..tostring(errorCode), ex, "code")
        end
    else
        self._dialog1.error:setString("")
    end 
end 

-- 关闭对话框
function UpdateView:closeDialog(callback)
	self._dialog1:stopAllActions()
    self._dialog1:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 0.7), cc.CallFunc:create(function () self._dialog1:setVisible(false) end), 
    	cc.DelayTime:create(0.05), 
        cc.CallFunc:create(function ()
	        if callback then
	            callback()
	        end
    end)))	
end

-- 启动进度条
-- 设置 self._realProgress 来更新进度条
function UpdateView:enableProgress()
    
    self._updateFinish = false
    self._curprogress = 0
	self._realProgress = 0
	self._showProgress = 0
	self._probg:setVisible(true)
	self._pro:setPercent(0)
    self._pro:setVisible(false)
    if self._proMc == nil then
        self._proMc = pc.DisplayNodeFactory:getInstance():createMovieClip("jindutiao_jindutiao")
        self._pro:addChild(self._proMc)
    end
	-- self._proLabel1:setString("正在下载更新... ( " .. 0 .. "% )")
	if self._updateId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._updateId) 
		self._updateId = nil
	end
	-- self._proCallback = callback
    self._proLabel1:setVisible(false)
    self._proLabel2:setVisible(false)
    self._proLabel3:setVisible(false)
	self._updateId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()
		-- self._realProgress = self._realProgress + 5
		-- if self._realProgress > 100 then self._realProgress = 100 end
		self:updateProgress()
	end, 0, false)
end

function UpdateView:stopProgress()
    if self._updateId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._updateId) 
        self._updateId = nil
    end
    self._probg:setVisible(false)
end

function UpdateView:setProgressString(str)
    self._probg:setVisible(true)
    self._proLabel2:setString(str)
    self._proLabel1:setVisible(false)
    self._proLabel3:setVisible(false)
    self._pro:setVisible(false)
end

function UpdateView:num2str(byte)
    if byte < 1024 then
        return byte.."B"
    elseif byte < 1024 * 1024 then
        return string.format("%d", byte / 1024) .."KB"
    else
        return string.format("%.2f", byte / 1024 / 1024) .."MB"
    end
end

function UpdateView:updateProgress()
    local pro = self._realProgress
    if pro > 100 then pro = 100 end
    -- local progress = 150 * pro / (pro + 50)
    local progress = pro
	if progress > self._showProgress then
		local d = (progress - self._showProgress) * 0.1
		if d < 0.1 then
			d = 0.1
		end
		if d > 4 then
			d = 4
		end
		self._showProgress = self._showProgress + d
		if math.abs(progress - self._showProgress) < 0.1 then
			self._showProgress = progress
		end
	end
    if self._showProgress >= 2 then
	    self._pro:setPercent(self._showProgress)
        self._pro:setVisible(true)
        self._proMc:setPosition(self._showProgress * 7.72 - 5, 9)
    else
        self._pro:setVisible(false)
    end
    
    local newCPP = pc.PCTools.gsdkEnd ~= nil
    local v1, v2
    if newCPP then
        v1 = 49.5
        v2 = 0.495
    else
        v1 = 45
        v2 = 0.45
    end
    -- self._proLabel1:setString("正在下载更新文件" .. self._curFileIndex .. "/" .. self._totalFileCount .. " ... ( " .. math.floor(self._showProgress) .. "% )")
    if progress < v1 then
        self._proLabel1:setString("下载文件".. " " .. math.floor(progress / v2) .. "%")
        self._proLabel2:setString(self:num2str(progress / v2 * 0.01 * self._packageSize).."/"..self:num2str(self._packageSize))
        if self._downSpeed then
            self._proLabel3:setString("速度"..self:num2str(self._downSpeed).."/s")
        end
        self._proLabel1:setVisible(true)
        self._proLabel2:setVisible(true)
        self._proLabel3:setVisible(true)
    elseif progress < 50 then
        self._proLabel1:setVisible(false)
        self._proLabel2:setVisible(true)
        self._proLabel3:setVisible(false)
        self._proLabel2:setString("正在写入文件..")    
    else
        self._proLabel1:setVisible(false)
        self._proLabel2:setVisible(true)
        self._proLabel3:setVisible(false)
        self._proLabel2:setString("解压缩文件".. " " .. math.floor((progress - 50) * 2) .. "%")
    end

	if self._showProgress == 100 then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._updateId) 
		self:delayCall(0.1, function ()
			self._probg:setVisible(false)
            if self._updateId ~= nil then 
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._updateId)
            end
            ApiUtils.gsdkSetEvent({tag = "2", status = "true", msg = "0-success"})
            self:updateRes(self._udpateAsset)
            
		end)
	end
end


local APP_NETWORK_NO = 1
local APP_NETWORK_WIFI = 2
local APP_NETWORK_3G = 3
local APP_NETWORK_STRING = {"未连通", "无线局域网", "移动网络"}

local ResCode = {
    NOT_NEED_UPDATE     = "0",
    NEED_UPDATE         = "1",
    FORCED_UPDATE       = "2",
    GAME_MAINTENANCE    = "3",
    ROLLBACK            = "4",
    VERSION_NO_EXIST    = "5",
    OTHER               = "error"
}


local UpdateClientError = {
    COULDNT_RESOLVE_HOST = 6, -- 无法解析主机。给定的远程主机没有得到解决。
    COULDNT_CONNECT = 7, -- connect（）的主机或代理失败。
    WRITE_ERROR = 23, -- 发生错误，写作时接收到的数据到本地文件，或者返回错误libcurl的一个写回调。
    NO_ERROR = 0,
    DISK_ERROR = 101, -- 存储空间不足
    FILE_NOT_INTEGRITY = 102, -- 文件不完整
    FILE_SIZE_NOT_MATCH = 103, -- 文件大小不匹配
    JSON_PARSE_ERROR = 104, -- json解析错误
    PARAM_ERROR = 105,  -- 参数出错
    RETRY_DISPATCHER = 106, -- 重新尝试调度
    RETRY_DOWNLOADER = 107, -- 重新尝试下载
    FILE_NOT_EXIST = 108, -- 文件不存在
    WRONG_MD5 = 109, -- md5校验失败

    -- curl
    CURLE_OPERATION_TIMEDOUT = 28,
    CURLE_GOT_NOTHING = 52,
    CURLE_SEND_ERROR = 55,
    CURLE_RECV_ERROR = 56,

    -- http
    HTTP_403 = 403,
    HTTP_404 = 404,
}

function UpdateView:showJGLauncher()
    if OS_IS_WINDOWS then return end
    if (pc.PCTools.getCppVersion and pc.PCTools:getCppVersion() or 212) <= 213 then return end
    if OS_IS_IOS then
        self._luaBridge = require "cocos.cocos2d.luaoc"
        self._className = "SDKUtils"
    elseif OS_IS_ANDROID then
        self._luaBridge = require "cocos.cocos2d.luaj"
        self._className = "com/utils/core/SDKUtils"
    end
    local k = cc.Director:getInstance():getOpenGLView():getFrameSize().height / MAX_SCREEN_HEIGHT
    self._luaBridge.callStaticMethod(self._className, "showJGLauncher", {xx = math.floor(16 * k), yy = math.floor(78 * k)})
end
-- 入口
function UpdateView:show()
    print("updateView:show")
	require "game.GameStatic"
    ApiUtils.gsdkSetEvent({tag = "0", status = "true", msg = "success"})
    local ret, packageInfo = ApiUtils.getPackageInfo()
    if ret then
        GameStatic.version = packageInfo.version_text
    end
    -- self:showJGLauncher()
    self._widget:runAction(cc.Sequence:create(
    	cc.FadeIn:create(0.2), 
    	cc.CallFunc:create(function ()
            self:checkNetWorkState()
    	end)
    ))
    -- self._pcdbMgr = kakura.PCDBManager:getInstance()

    -- local reslibTableNames = self._pcdbMgr:execute_sqlite3('select name from sqlite_master where type = "table" order by name', "reslib")
    -- dump(reslibTableNames)
end

--[[
--! @function checkNetWorkState
--! @desc 网络状态检测
--! @param 
--! @return 
--]]
function UpdateView:checkNetWorkState()
    if GLOBAL_VALUES.NeedUpdateAsset then
        GLOBAL_VALUES.NeedUpdateAsset = false
        self:updateRes(true)
        return
    end
    self._retryDownNum = 0
    self._configMgr = kakura.Config:getInstance()
    -- 默认game.conf中没有版本号，如果人为添加则需要注意
    if self._configMgr:getValue("APP_BUILD_NUM") and string.len(self._configMgr:getValue("APP_BUILD_NUM")) > 0 and not OS_IS_WINDOWS then
        GameStatic.lua_model = 2
    else
        GameStatic.lua_model = 1
    end
    if OS_IS_WINDOWS or GameStatic.lua_model == 1 then 
        self:showInfo("正在获取更新信息", function ()
            self:enterGame()
        end)
    else
        local netWorkType = AppInformation:getInstance():getNetworkType()
        self._network:setString("网络环境: " .. APP_NETWORK_STRING[netWorkType])
        if netWorkType == 1 then 
            self:showDialog(nil, "网络未连通，请稍后重试",nil , 
                function ()
                    self:checkNetWorkState()
                end, 
                function ()
                    self:logoutGame()
                end)
        else
            self:getUpdateInfo()
        end
    end
end

--[[
--! @function logoutGame
--! @desc 退出游戏
--! @param 
--! @return 
--]]
function UpdateView:logoutGame()
    AppExit()
end


-- 获取更新信息
function UpdateView:getUpdateInfo()
    
    self._pcdbMgr = kakura.PCDBManager:getInstance()
    self._appInformation = AppInformation:getInstance()
    self._app_build_num = self._configMgr:getValue("APP_BUILD_NUM")
    local httpManager = HttpManager:getInstance()
    -- 获取更新信息
    self:showInfo("正在获取更新信息", function ()

        local vmsUrl = self._configMgr:getValue("VMS_URL")
        if GameStatic.use_vmsExPort and RestartMgr.vmsUrl_planB then
            vmsUrl = RestartMgr.vmsUrl_planB
        end
        local lastChat = string.sub(vmsUrl,string.len(vmsUrl),string.len(vmsUrl)) 
        if lastChat ~= "/" then 
            vmsUrl = vmsUrl .. "/"
        end

        local vmsTargetVersion = self._appInformation:getValue("vmsTargetVersion")
        if string.find(vmsUrl,'http') == nil and string.find(vmsUrl,'https') == nil then
            vmsUrl = "http://" .. vmsUrl 
        end
        if string.find(vmsUrl,'?') == nil then
            vmsUrl = vmsUrl .. '?'
        end
        
        local param = {}
        if self._configMgr:getValue("IS_SMALL_PACKAGE") and string.len(self._configMgr:getValue("IS_SMALL_PACKAGE")) > 0 then 
            param.is_small_package = self._configMgr:getValue("IS_SMALL_PACKAGE")
        end
        if self._configMgr:getValue("APP_CHANNEL_ID") and string.len(self._configMgr:getValue("APP_CHANNEL_ID")) > 0 then 
            param.app_channel_id = self._configMgr:getValue("APP_CHANNEL_ID")
        end
        if self._configMgr:getValue("APP_PLATFORM") and string.len(self._configMgr:getValue("APP_PLATFORM")) > 0 then 
            param.app_platform = self._configMgr:getValue("APP_PLATFORM")
        end
        if self._configMgr:getValue("OS_PLATFORM") and string.len(self._configMgr:getValue("OS_PLATFORM")) > 0 then 
            param.os_platform = self._configMgr:getValue("OS_PLATFORM")
        end
        param.ver = self._app_build_num
        if vmsTargetVersion  ~= nil and string.len(vmsTargetVersion) > 0 then 
            param.vmsTargetVersion = vmsTargetVersion
        end
        local url = vmsUrl .. "mod=vms&r=gameApi/checkVersion"
        for k, v in pairs(param) do
            url = url .. "&" .. k .. "=" .. v
        end
        -- 防止出现cache
        url = url .. "&rand=" .. math.random()
        ApiUtils.playcrab_device_monitor_action("vms_req")
        self._vmsUrl = httpManager:sendMsg(url, "get", {}, 
            function(result) 
                ApiUtils.playcrab_device_monitor_action("vms_resp")
                self:getUpdateInfoFinish(result)
            end, 
            function(status, errorCode, response)
                ApiUtils.gsdkSetEvent({tag = "1", status = "false", msg = tostring(errorCode)})
                if errorCode == 3 then
                    if GameStatic.use_vmsExPort then
                        -- 如果连接失败, 替换80端口
                        if RestartMgr.vmsUrl_planB then
                            RestartMgr.vmsUrl_planB = nil
                        else
                            RestartMgr.vmsUrl_planB = ApiUtils.changeUrlPort(self._configMgr:getValue("VMS_URL"), GameStatic.vms_port)
                        end
                    end
                end
                if string.find(response, "\n") or (string.len(response) > 0 and string.len(response) < 4) then
                    -- 被路由器策略
                    self:showDialog(nil, "您连接的无线局域网需要进行验证后方能连接到网络", nil, 
                    function ()
                        self:checkNetWorkState()
                    end)
                else
                    self:getUpdateInfoError(status, url, response, self._vmsUrl)
                end
            end,
            GameStatic.useHttpDns_Vms
        )
        GLOBAL_VALUES.vmsUrl = self._vmsUrl
    end)

end

--[[
--! @function getUpdateInfoFinish
--! @desc 网络请求返回数据处理
--! @param inData 网络请求返回数据
--! @return 
--]]
function UpdateView:getUpdateInfoFinish(inData)
    self:closeInfo(nil)
    if inData == nil then 
        self:showDialog(6661002, "请求更新失败，请点击确定重试", nil, 
            function ()
                self:checkNetWorkState()
            end) 
        self:waitBeforeConfim()
        return
    end    
    if inData.patch~=nil and inData.patch~= cjson.null and inData.patch~="" then
        local f = loadstring(inData.patch)
        G_patchTab = {}
        pcall(f)
    end
    if type(inData.GameStatic) == "table" then
        -- 更新游戏配置
        self._GameStaticPatch = {}
        for key,value in pairs(inData.GameStatic or {}) do
            GameStatic[key] = value
            self._GameStaticPatch[key] = value
            -- self._configMgr:setValue(key, tostring(value))
        end
    end
    if inData.error ~= nil and inData.error.code ~= nil and tostring(inData.error.code) == "-800" then 
        local _inData = inData
        if not _inData then inData = {} end
        ApiUtils.gsdkSetEvent({tag = "1", status = "false", msg = "6661003"})
        self:showDialog(6661003, "未知错误，请点击确定重试", nil, 
            function ()
                self:checkNetWorkState()
            end, nil, serialize(inData))    
        self:waitBeforeConfim()     
        return
    end
    self._configMgr:save()
    local status = tostring(inData.s)
    print("status====", status, ResCode.NOT_NEED_UPDATE)
    if status == ResCode.NOT_NEED_UPDATE and 
        (inData.global_server_url or inData.appstore_review_global_server_url) then
        ApiUtils.gsdkSetEvent({tag = "1", status = "true", msg = "0-success"})
        -- http://119.254.97.56:8083/index.php?mod=global
        -- 无更新进入游戏
        -- GameStatic.
        -- 更换global server 地址
        -- self._appInformation = AppInformation:getInstance()
        if inData.global_server_url then
            IS_APPLE_EXAMINE = nil
            self._appInformation:setValue("global_server_url", inData.global_server_url)
        else
            IS_APPLE_EXAMINE = true
            self._appInformation:setValue("global_server_url", inData.appstore_review_global_server_url)
        end
        self:enterGame()
    elseif status == ResCode.GAME_MAINTENANCE then
        -- 服务器维护
        self:showDialog(nil, "服务器当前正在维护，请稍后重试哦", nil, 
            function ()
                self:checkNetWorkState()
            end)
        self:waitBeforeConfim()
    elseif status == ResCode.VERSION_NO_EXIST  then
        -- 客户端版本在服务器端不存在
        ApiUtils.gsdkSetEvent({tag = "1", status = "true", msg = "2-success"})
        self:showDialog(6661005, "当前客户端版本失效，请重新下载客户端", nil, 
            function ()
                self:logoutGame()
            end)
    elseif status == ResCode.FORCED_UPDATE  then
        -- 客户端版本已经停用，需要下载新的客户端
        ApiUtils.gsdkSetEvent({tag = "1", status = "true", msg = "3-success"})
        -- 测试阶段把这里暂时改成测试已结束
        self:showDialog(nil, inData.msg, nil, 
            function ()
                if inData.update_url then
                    local url
                    if OS_IS_IOS then
                        url = inData.update_url.ios
                    else
                        url = inData.update_url.android
                    end
                    cc.Application:getInstance():openURL(url)
                end
            end)
    elseif status == ResCode.NEED_UPDATE  then
        -- 客户端需要更新，返回更新压缩包下载地址
        ApiUtils.gsdkSetEvent({tag = "1", status = "true", msg = "1-success"})
        self:handleUpdatePackage(inData)
    elseif status == ResCode.ROLLBACK  then
        -- 灰度更新后的版本回滚
        self:handleRollBack(inData)
    elseif status == ResCode.OTHER then
        -- 其他错误
        ApiUtils.gsdkSetEvent({tag = "1", status = "false", msg = "6661007"})
        self:showDialog(6661007, "获取更新数据出错，请点击确定重试", nil, 
            function ()
                self:checkNetWorkState()
            end)
        self:waitBeforeConfim()
    else
        ApiUtils.gsdkSetEvent({tag = "1", status = "false", msg = "6661008"})
        self:showDialog("6661008."..status, "未知错误，请点击确定重试", nil, 
            function ()
                self:checkNetWorkState()
            end)
        self:waitBeforeConfim() 
    end
end

--[[
--! @function handleRollBack
--! @desc 处理回滚数据（灰度）
--! @param inData 网络请求返回数据
--! @return 
--]]
function UpdateView:handleRollBack(inData)
    self:closeInfo(nil)
    local reslibFileName = self._configMgr:getValue("RESLIB_FILENAME")
    local reslibTableNames = self._pcdbMgr:execute_sqlite3('select name from sqlite_master where type = "table" order by name', reslibFileName)
    --当前客户端版本号列表,直接切换到线上或者线上之前的一个版本,然后重新检查更新
    local dbContent = cjson.decode(reslibTableNames).content
    local status = 0
    for i = #dbContent, 1, -1 do
        local backNum = tonumber(string.sub(dbContent[i], 9, string.len(dbContent[i])))
        if backNum <= tonumber(inData.v.version) then
            -- self._appInformation:setCurrentVersion(tonumber(string.sub(dbContent[i], 9, string.len(dbContent[i]))))
            self._configMgr:setValue("APP_BUILD_NUM", backNum)
            self._configMgr:save()
            self._pcdbMgr:setCurrentVersion(backNum)
            status = 1
            break
        end
    end
    if status == 1 then 
        self:updateRes(true)
    end
end

--[[
--! @function checkLockDb
--! @desc 检查本地db
--! @param inData 网络请求返回数据
--! @return 
--]]
function UpdateView:checkLockDb(inVersion)
    self:closeInfo(nil)
    local status = 0
    local reslibFileName = self._configMgr:getValue("RESLIB_FILENAME")
    local reslibTableNames = self._pcdbMgr:execute_sqlite3('select name from sqlite_master where type = "table" order by name', reslibFileName)
    --当前客户端版本号列表,直接切换到线上或者线上之前的一个版本,然后重新检查更新
    local dbContent = cjson.decode(reslibTableNames).content

    for i = #dbContent, 1, -1 do
        local backNum = tonumber(string.sub(dbContent[i], 9, string.len(dbContent[i])))
        if backNum == tonumber(inVersion) then
            local reslibTableNames = self._pcdbMgr:execute_sqlite3("select count(*) from " .. dbContent[i] , reslibFileName)
            local dbContent = cjson.decode(reslibTableNames).content
            if dbContent[1] ~= nil and tonumber(dbContent[1]) > 0 then
            -- self._appInformation:setCurrentVersion(tonumber(string.sub(dbContent[i], 9, string.len(dbContent[i]))))
                self._configMgr:setValue("APP_BUILD_NUM", backNum)
                self._configMgr:save()
                self._pcdbMgr:setCurrentVersion(backNum)
                status = 1
            end
            break
        end
    end
    return status
end


--[[
--! @function checkIsNeedUnLoginGuide
--! @desc 检查是否开启后台下载
--! @param size 更新包的大小 单位m
--! @return  true 开启后台更新
--]]
function UpdateView:checkIsNeedUnLoginGuide(size)
    -- if OS_IS_WINDOWS then return false end
    local need = false
    if not pcall(function()
            if GameStatic.deviceGuideOpen then
                local SdkManager = require("game.controller.SdkManager")
                local sdkMgr = SdkManager:getInstance()
                local SystemUtils = require "game.utils.SystemUtils"
                local playVideo
                if OS_IS_ANDROID or OS_IS_IOS then
                    playVideo = sdkMgr:getDataFromDevice(GameStatic.deviceGuideKey_Video)
                    if playVideo == "" then
                        playVideo = nil
                    else
                        playVideo = tonumber(playVideo)
                    end
                    playVideo = playVideo or SystemUtils.loadGlobalLocalData(GameStatic.deviceGuideKey_Video)
                end
                if playVideo == nil or playVideo ~= 1 then
                    need = true
                else
                    local unloginGuideEnable = SystemUtils.loadGlobalLocalData(GameStatic.deviceGuideKey_Enable)
                    if not unloginGuideEnable or unloginGuideEnable == 0 then
                        need = false
                    else
                        need = true
                    end
                end
            end
            if OS_IS_64 then
                package.loaded["game.controller.SdkManager64"] = nil
                package.loaded["game.utils.SystemUtils64"] = nil
            else
                package.loaded["game.controller.SdkManager"] = nil
                package.loaded["game.utils.SystemUtils"] = nil
            end
            
        end) then
        need = false
    end

    if need then
        local netType = AppInformation:getInstance():getNetworkType()
        if netType == 2 then
            BackgroundUp = require("base.boot.BackgroundUp")
            BackgroundUp.checkNetWorkState()
            return true
        elseif netType == 3 then
            if size > 5 then
                return true
            else
                BackgroundUp = require("base.boot.BackgroundUp")
                BackgroundUp.checkNetWorkState()
                return true
            end
        end
    end
    return false
end

--[[
--! @function handleUpdatePackage
--! @desc 处理更新数据
--! @param inData 网络请求返回数据
--! @return 
--]]
function UpdateView:handleUpdatePackage(inData)
        -- 需要下载7z包         
    local newVersion = inData.v and inData.v.version
    local resUrl = inData.resource_url_root
    local filenameArr = {}
    -- local tipText = "更新数据包大小为："..self._packageSize.."MB，正在使用移动网络，是否继续下载？"

    if self:checkLockDb(newVersion) == 1  then 
        self:updateRes(true)
        return 
    end

    self._packageSize = 0
    self._showErrorCode = false
    for _,v in pairs(inData.package or {}) do
        if v.url then
            table.insert(filenameArr, v.url)
            self._packageSize = self._packageSize + tonumber(v.size)
        end
    end
    if #filenameArr > 0 and newVersion and resUrl and self._packageSize > 0 then
        self._curFileIndex = 1
        self._totalFileCount = #filenameArr
        local writablePath = cc.FileUtils:getInstance():getWritablePath()
        local location = 2
        local downloadLocalPath = writablePath
        if OS_IS_ANDROID then
            if self._appInformation:getValue("external_asset_path") ~= nil and self._appInformation:getValue("external_asset_path") ~= "" then
                -- 如果 sd 卡可用 , 存储到sd下
                downloadLocalPath = self._appInformation:getValue("external_asset_path")
                location = 3
            end
        end


        local function downloadOnePackage(filename)
            print("开始下始 "..self._curFileIndex.."/"..self._totalFileCount.." 更新包")
            -- local isUpdate = true
            local params = {}
            params['filePath'] = downloadLocalPath.."package.7z"
            params['intervalTime'] = 100
            params['dirPath'] = downloadLocalPath
            params['threadCount'] = 4
            if GameStatic.useHttpDns_Update then
                local url = ApiUtils.getHttpDnsUrl(resUrl .. "/" .. filename)
                params['url'] = url
            else
                params['url'] = resUrl .. "/" .. filename        
            end

            if GameStatic.CDN_cdncer then
                params['cdncer'] = cc.FileUtils:getInstance():fullPathForFilename(GameStatic.CDN_cdncer)
            end
            -- https由c++部分添加，这里先全部转回来，并用https参数来控制
            params['url'] = string.gsub(params['url'], "https", "http")
            params['checkMD5'] = GameStatic.CDN_checkMD5
            params['https'] = GameStatic.CDN_https

            dump(params, "update", 5)
            -- self._realProgress = (curFileIndex * tonumber(100)) / (totalFileCount * 200) * 100
            
            kakura.UpdateClient:update(cjson.encode(params), function(jsonStr, errCode)
                if errCode == UpdateClientError.NO_ERROR then
                    self._showErrorCode = false
                    local progress = cjson.decode(jsonStr)
                    self._realProgress = progress.percent * 0.5
                    self._downSpeed = progress.bytesPerSecond

                    if progress.percent == 200 then
                        local sqlFileName = "update.sql"
                        if not fu:isFileExist(downloadLocalPath .. sqlFileName) then                          
                            return
                        end
                        self._retryDownNum = 0
                        local oldTable = "version_" .. self._configMgr:getValue("APP_BUILD_NUM")
                        local newTable = "version_" .. tostring(newVersion)

                        local reslibFileName = self._configMgr:getValue("RESLIB_FILENAME")

                        self._pcdbMgr:execute_sqlite3("create table if not exists " .. newTable .. " (filename varchar(512) PRIMARY KEY, type varchar(16), size int, md5 varchar(32), url varchar(512), location int)", reslibFileName)

                        self._pcdbMgr:execute_sqlite3( "insert into " .. newTable .. " select filename, type, size, md5, url, location from " .. oldTable, reslibFileName)
                        
                        local state = self._pcdbMgr:execute_sqlite3_UpdatInsert(reslibFileName, downloadLocalPath .. sqlFileName)   
                        if state == false  then 
                            return 
                        end
                        
                        local  reslibTableNames = self._pcdbMgr:execute_sqlite3("select count(*) from " .. newTable .. " where location = 0 and type = 'asset' ", reslibFileName)
                        local dbContent = cjson.decode(reslibTableNames).content
                        if dbContent[1] ~= nil and tonumber(dbContent[1]) > 0 then
                            self._udpateAsset = true
                            print("self._udpateAsset===", self._udpateAsset)
                        end

                        self._pcdbMgr:execute_sqlite3("update " .. newTable .. " set location = " .. location .. " where location = 0", reslibFileName)
                        
                        if self._curFileIndex == self._totalFileCount then                                      
                            print(self._totalFileCount.."个包全部下载完成")
                            pcall(function ()
                                UserDefault:setStringForKey("lastAppBuildNum", tostring(self._configMgr:getValue("APP_BUILD_NUM")))
                            end)
                            self._configMgr:setValue("APP_BUILD_NUM", inData.v.version)
                            self._configMgr:save()
                            self._pcdbMgr:setCurrentVersion(inData.v.version)
                            pcall(function ()
                                local __data = clone(inData)
                                __data.patch = nil
                                UserDefault:setStringForKey("vms__Resp", serialize(__data))
                            end)
                            -- self:over(true)
                            -- self:checkNetWorkState()
                            -- self:logoutGame()
                            self._updateFinish = true
                            -- self:updateRes(self._udpateAsset)
                        elseif self._curFileIndex < self._totalFileCount then
                            --继续下载
                            self._curFileIndex = self._curFileIndex + 1
                            downloadOnePackage(filenameArr[self._curFileIndex])
                        end                                 
                    end
                    -- self._realProgress
                    -- if progressFunc then                                                            
                    --     progressFunc(curFileIndex, totalFileCount, progress)
                    -- end
                    
                elseif errCode ~= UpdateClientError.RETRY_DISPATCHER and errCode ~= UpdateClientError.RETRY_DOWNLOADER and not self._showErrorCode then
                    if false then --self._retryDownNum < 3 then
                        self:stopProgress()
                        self:setProgressString("正在准备开始下载更新包")
                        self:delayCall(1, function ()
                            self._retryDownNum = self._retryDownNum + 1
                            self:enableProgress()
                            downloadOnePackage(filenameArr[self._curFileIndex])
                        end)
                    else
                        self._retryDownNum = 0
                        self:stopProgress()
                        self._showErrorCode = true
                        local msg = ""
                        if errCode == UpdateClientError.DISK_ERROR then
                            msg = "手机存储空间不足，请确保一定的存储下载，以便游戏正常更新"
                        elseif errCode == UpdateClientError.FILE_SIZE_NOT_MATCH then
                            msg = "更新包获取失败"
                        elseif errCode == UpdateClientError.HTTP_403 then
                            msg = "服务器拒绝访问"
                        elseif errCode == UpdateClientError.HTTP_404 then
                            msg = "更新包不存在"
                        elseif errCode == UpdateClientError.WRONG_MD5 then
                            msg = "更新文件校验失败"
                        else
                            msg = "游戏更新数据下载失败！"
                        end
                        ApiUtils.gsdkSetEvent({tag = "2", status = "false", msg = tostring(errCode)})
                        self:showDialog("6661009."..errCode, msg .. "\n请稍后尝试", nil, 
                            function ()
                                -- downloadOnePackage(filenameArr[self._curFileIndex])
                                self:checkNetWorkState()
                            end,
                            function()
                                self:logoutGame()
                            end, serialize(params))
                        self:waitBeforeConfim()
                    end
                    return false
                end
            end)  
        end
        local tipUnit = "MB"
        local showUpdateSize = self._packageSize/1024/1024
        if self:checkIsNeedUnLoginGuide(showUpdateSize) and not GameStatic.stopBackgroundUp then
            self:enterGame()
            return
        end
        if self._packageSize/1024 <= 1024 then 
            tipUnit = "KB"
            showUpdateSize = self._packageSize/1024
        end   

        local ntype = AppInformation:getInstance():getNetworkType()
        local netWorkType = APP_NETWORK_STRING[ntype]
        self._network:setString("网络环境: " .. netWorkType)
        if ntype == 1 then 
            self:showDialog(6661010, "网络无法连接，请确定网络状况后点击确定重试",nil , 
                function ()
                    self:checkNetWorkState()
                end,  
                function ()
                    self:logoutGame()
                end)
            self:waitBeforeConfim()
        else
            if ntype == 2 then 
                self:enableProgress()
                downloadOnePackage(filenameArr[self._curFileIndex])
            else
                self:showDialog(nil, "更新数据包大小为：".. string.format("%.1f", showUpdateSize) .. tipUnit .."，正在使用移动网络，是否继续下载？",nil,
                    function()
                        -- self._realProgress = 100
                        -- self._showProgress = 0
                        self:enableProgress()
                        downloadOnePackage(filenameArr[self._curFileIndex])
                    end,
                    function()
                        self:logoutGame()
                    end)
            end
        end
    elseif (not inData.package or #inData.package <= 0) and newVersion then

        print("不需要下载，只需要更新版本号")
        local oldTable = "version_" .. self._configMgr:getValue("APP_BUILD_NUM")
        local newTable = "version_" .. tostring(newVersion)
        -- 获取表是否存在
        local reslibFileName = self._configMgr:getValue("RESLIB_FILENAME")
        local reslibTableNames = self._pcdbMgr:execute_sqlite3('select name from sqlite_master where type = "table" and name = "' .. newTable .. '" order by name', reslibFileName)
        --当前客户端版本号列表,直接切换到线上或者线上之前的一个版本,然后重新检查更新
        local dbContent = cjson.decode(reslibTableNames).content

        local isHaveVersion = false
        if #dbContent > 0 then 
            isHaveVersion = true
        end

        if isHaveVersion == false then
            local reslibFileName = self._configMgr:getValue("RESLIB_FILENAME")

            self._pcdbMgr:execute_sqlite3("create table if not exists " .. newTable .. " (filename varchar(512) PRIMARY KEY, type varchar(16), size int, md5 varchar(32), url varchar(512), location int)", reslibFileName)

            self._pcdbMgr:execute_sqlite3("insert into " .. newTable .. " select filename, type, size, md5, url, location from " .. oldTable, reslibFileName)
        end
        pcall(function ()
            UserDefault:setStringForKey("lastAppBuildNum", tostring(self._configMgr:getValue("APP_BUILD_NUM")))
        end)
        self._configMgr:setValue("APP_BUILD_NUM", newVersion)                     
        self._configMgr:save()
        self._pcdbMgr:setCurrentVersion(newVersion)
        pcall(function ()
            local __data = clone(inData)
            __data.patch = nil
            UserDefault:setStringForKey("vms__Resp", serialize(__data))
        end)
        -- 清除fileutils中cache
        cc.FileUtils:getInstance():purgeCachedEntries()

        if inData.global_server_url then
            -- 直接进入游戏
            IS_APPLE_EXAMINE = nil
            ApiUtils.gsdkSetEvent({tag = "1", status = "true", msg = "0-success"})
            self._appInformation:setValue("global_server_url", inData.global_server_url)
            self:enterGame()
        elseif inData.appstore_review_global_server_url then
            -- 直接进入游戏
            IS_APPLE_EXAMINE = true
            ApiUtils.gsdkSetEvent({tag = "1", status = "true", msg = "0-success"})
            self._appInformation:setValue("global_server_url", inData.appstore_review_global_server_url)
            self:enterGame()        
        else
            self:checkNetWorkState()
        end
    else
        print("下载需要的参数不全")
        self:enterGame()
    end
end

--[[
--! @function getUpdateInfoError
--! @desc 网络请求错误
--! @param inStatus 网络请求返回状态
--! @return 
--]]
function UpdateView:getUpdateInfoError(inStatus, url, response, url2)
    self:showDialog("6661011."..inStatus, "获取更新数据失败，请点击确定重试", nil, 
        function ()
            -- self:enterGame()
            self:checkNetWorkState()
        end, nil, serialize({url = url, response = response, httpDns = GameStatic.useHttpDns_Vms, httpDnsUrl = url2}))
    self:waitBeforeConfim()
    -- self:over(false)
    if GameStatic.useGetIP then
        GameStatic.useGetIP = false
        ApiUtils.getPublicIP(function (state, response)
            if response and response ~= "" then
                ApiUtils.playcrab_lua_error("errorCode_6661011."..inStatus, response, "code")
            end
        end)
    end
end

-- 是否多线程载入资源
local ENABLE_AYSNC_LOADRES = false
function UpdateView:updateRes(isUpdateAsset)
    cc.FileUtils:getInstance():purgeCachedEntries()
    local fileTable = require("game.GamePreLoadRes")
    
    -- 自动更新界面重载I18N
    if OS_IS_64 then
        package.loaded["game.config.lang.I18N_".. GLOBAL_VALUES.LANGUAGE .."64"] = nil
    else
        package.loaded["game.config.lang.I18N_".. GLOBAL_VALUES.LANGUAGE] = nil
    end

    pcall(function ()
        I18N = require("game.config.lang.I18N_" .. GLOBAL_VALUES.LANGUAGE)
    end)

    if isUpdateAsset then 
        -- 如果有更新, 则重新载入资源
        local DisplayNodeFactory = pc.DisplayNodeFactory:getInstance()
        DisplayNodeFactory:clearIndices()
        DisplayNodeFactory:clearMCLibrary()
        DisplayNodeFactory:loadIndices("asset/anim/animxml.index.json")
        DisplayNodeFactory:loadIndices("asset/anim/plist.index.json")

        for i = 1, #fileTable do
            sfc:removeSpriteFramesFromFile(fileTable[i][1])
            tc:removeTextureForKey(fileTable[i][2])
        end
        if OS_IS_64 then
            package.loaded["game.GamePreLoadRes64"] = nil
        else
            package.loaded["game.GamePreLoadRes"] = nil
        end
        
        local fileTable = require("game.GamePreLoadRes")

        if ENABLE_AYSNC_LOADRES then
            self:aysncLoadRes(fileTable, function ()
                self:checkNetWorkState()
            end)
        else
            for i = 1, #fileTable do
                if fu:isFileExist(fileTable[i][2]) then
                    sfc:addSpriteFrames(fileTable[i][1], fileTable[i][2])
                end
            end
            self:checkNetWorkState()
        end
        return
    end
    self:checkNetWorkState()
end

function UpdateView:enterGame()
    -- require "base.boot.PatchTest"
    ApiUtils.updateVersion()
    ApiUtils.playcrab_device_monitor_action("update")
    pcall(function () self:reloadGameStatic() end)
    require("game.Game").new():startup()
end

function UpdateView:reloadGameStatic()
    local version = GameStatic.version
    local lua_model = GameStatic.lua_model
    local useGetIP = GameStatic.useGetIP
    if OS_IS_64 then
        package.loaded["game.GameStatic64"] = nil
    else
        package.loaded["game.GameStatic"] = nil
    end
    require "game.GameStatic"
    GameStatic.version = version
    GameStatic.lua_model = lua_model
    GameStatic.useGetIP = useGetIP
    for k, v in pairs(self._GameStaticPatch or {}) do
        GameStatic[k] = v
    end
end


function UpdateView.dtor()
    APP_NETWORK_3G = nil
    APP_NETWORK_NO = nil
    APP_NETWORK_STRING = nil
    APP_NETWORK_WIFI = nil
    ENABLE_AYSNC_LOADRES = nil
    MAX_SCREEN_HEIGHT = nil
    MAX_SCREEN_WIDTH = nil
    ResCode = nil
    sfc = nil
    tc = nil
    ttf = nil
    ttf_title = nil
    ttf_number = nil
    UpdateClientError = nil
    UpdateView = nil
    ALR = nil
    fu = nil
end

return UpdateView