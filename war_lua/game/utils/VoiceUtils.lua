--
-- Author: huachangmiao@playcrab.com
-- Date: 2017-03-30 11:21:17
--
-- 语音系统
-- 屏幕中间的正在录音和取消录音的面板，由此控制


local VoiceUtils = {}
local fu = cc.FileUtils:getInstance()
VoiceUtils.inited = false
local viewMgr = ViewManager:getInstance()

local VOICEUTILS_INIT_SUCCESS = 0
local VOICEUTILS_INIT_FAILED = 1

local VOICEUTILS_RECORD_SUCCESS = 0
local VOICEUTILS_RECORD_UNINIT = 1   -- 未进行初始化
local VOICEUTILS_RECORD_TOOSHORT = 2 -- 录音时间太短
local VOICEUTILS_RECORD_CANCEL = 3   -- 主动取消
local VOICEUTILS_RECORD_ERROR = 4 	 -- 错误

local VOICEUTILS_PATH = cc.FileUtils:getInstance():getWritablePath() .."gvoice/"
fu:createDirectory(VOICEUTILS_PATH)
local updateId
-- 初始化, 登录loading的时候调用
function VoiceUtils.init(callback)
	if GameStatic.useGVoice then
		if GLOBAL_VALUES.VoiceInited then
			VoiceUtils.inited = true
			callback(VOICEUTILS_INIT_SUCCESS)
		else
			local errorCode = sdkMgr:gvoice_applyMessageKey(function ()
				VoiceUtils.inited = true
				GLOBAL_VALUES.VoiceInited = true
				callback(VOICEUTILS_INIT_SUCCESS)
			end)
			if tonumber(errorCode) ~= 0 then
				viewMgr:showTip(errorCode)
				VoiceUtils.inited = false
				GLOBAL_VALUES.VoiceInited = false
				callback(VOICEUTILS_INIT_FAILED)
				return
			end
		end
		local gvoice_poll = sdkMgr.gvoice_poll
		local gfm_poll = sdkMgr.gfmPoll
		updateId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()
			gvoice_poll(sdkMgr)
			gfm_poll(sdkMgr)
		end, 0.5, false)
	else
		callback(VOICEUTILS_INIT_FAILED)
	end
end

function VoiceUtils.callRecordCallback(code, value, time)
	if VoiceUtils.recordCallback then
		print("[VoiceUtils] ", code, value, time)
		VoiceUtils.recordCallback(code, value, time)
		VoiceUtils.recordCallback = nil
	end
end

-- 开始录音
-- 如果 录音+上传 成功，会执行回调
local DEFAULT_RECORD_LONG = 60000 --ms
function VoiceUtils.startRecording(_type, callback, long)
	sdkMgr:gvoice_setMessageMode()
	ScheduleMgr:delayCall(20, VoiceUtils, function()
		if VoiceUtils.playFileID then
			VoiceUtils.toStopPlay = true
			sdkMgr:gvoice_stopPlayVoice()
			sdkMgr:gvoice_poll()
		end
		VoiceUtils.recordCallback = callback
		if not VoiceUtils.inited then 
			viewMgr:showTip("敬请期待")
			VoiceUtils.callRecordCallback(VOICEUTILS_RECORD_UNINIT)
			return 
		end
		local delay = long
		if delay == nil then
			delay = DEFAULT_RECORD_LONG
		end
		VoiceUtils.recording = true
		VoiceUtils.startRecordingTick = socket.gettime()
		
		local errorCode = sdkMgr:gvoice_startRecVoice(VOICEUTILS_PATH .. "tmpRecord")
		if tonumber(errorCode) ~= 0 then
			viewMgr:showTip(errorCode)
		end

		VoiceUtils.showRecordUI(_type, delay)
		ScheduleMgr:delayCall(delay, VoiceUtils, function()
			-- 如果到时间主动停止
			VoiceUtils.stopRecording()
		end)
	end)
end

-- 停止录音
function VoiceUtils.stopRecording()
	if not VoiceUtils.inited then return end
	ScheduleMgr:delayCall(60, VoiceUtils, function()
		if not VoiceUtils.recording then return end
		VoiceUtils.recording = false
		ScheduleMgr:cleanMyselfDelayCall(VoiceUtils)
		VoiceUtils.hideRecordUI()
		
		local errorCode = sdkMgr:gvoice_stopRecVoice()
		if tonumber(errorCode) ~= 0 then
			viewMgr:showTip(errorCode)
		end

		local time = socket.gettime() - VoiceUtils.startRecordingTick
		if time < 1 then
			viewMgr:showTip("说话时间太短")
			sdkMgr:gvoice_setNationalMode()
			VoiceUtils.callRecordCallback(VOICEUTILS_RECORD_TOOSHORT)
		else
			viewMgr:lock(-1)
			local errorCode = sdkMgr:gvoice_uploadRecVoice(VOICEUTILS_PATH .. "tmpRecord", function (code, jsondata)
				viewMgr:unlock()
				-- dump(jsondata)
				local json = cjson.decode(jsondata)
				local file_path = json.file_path
				local fileID = json.file_id
				print("录音成功 ", fileID)
				VoiceUtils.callRecordCallback(VOICEUTILS_RECORD_SUCCESS, fileID, math.floor(time))
				sdkMgr:gvoice_setNationalMode()
			end)
			if tonumber(errorCode) ~= 0 then
				viewMgr:showTip(errorCode)
				viewMgr:unlock()
				VoiceUtils.callRecordCallback(VOICEUTILS_RECORD_ERROR)
				viewMgr:showTip("发送语音消息失败")
				sdkMgr:gvoice_setNationalMode()
			end
		end
	end)
end

-- 取消录音
function VoiceUtils.cancelRecording()
	if not VoiceUtils.inited then return end
	ScheduleMgr:delayCall(60, VoiceUtils, function()
		if not VoiceUtils.recording then return end
		VoiceUtils.recording = false
		ScheduleMgr:cleanMyselfDelayCall(VoiceUtils)
		VoiceUtils.hideRecordUI()
		
		sdkMgr:gvoice_stopRecVoice()
		sdkMgr:gvoice_setNationalMode()
		VoiceUtils.callRecordCallback(VOICEUTILS_RECORD_CANCEL)
	end)
end

-- 播放录音
local playCallbacks = {}
local function onPlayCallback(code, jsondata)
	local json = cjson.decode(jsondata)
	local file_path = json.file_path
	if playCallbacks[file_path] then
		playCallbacks[file_path]()
		playCallbacks[file_path] = nil
	end
	VoiceUtils.playFileID = nil
	if VoiceUtils.toStopPlay then
		VoiceUtils.toStopPlay = false
	else
		sdkMgr:gvoice_setNationalMode()
	end
end

function VoiceUtils.play(fileID, callback)
	if not VoiceUtils.inited then 
		viewMgr:showTip("语音系统初始化失败")
		callback()
		return 
	end
	sdkMgr:gvoice_setMessageMode()
	ScheduleMgr:delayCall(50, VoiceUtils, function()
		if OS_IS_WINDOWS then
			if VoiceUtils.playFileID ~= fileID then
				VoiceUtils.playFileID = fileID
				print("播放成功 ", fileID)
				ScheduleMgr:delayCall(2000, VoiceUtils, function()
					VoiceUtils.playFileID = nil
					callback()
				end)
			else
				VoiceUtils.playFileID = nil
				ScheduleMgr:cleanMyselfDelayCall(VoiceUtils)
				callback()
				print("停止播放 ", fileID)
			end
		else
			local fileName = VOICEUTILS_PATH .. pc.PCTools:md5(fileID)
			if fu:isFileExist(fileName) then
				local _fileID = VoiceUtils.playFileID
				if _fileID then
					VoiceUtils.toStopPlay = true
				end
				sdkMgr:gvoice_stopPlayVoice()
				sdkMgr:gvoice_poll()
				if _fileID ~= fileID then
					playCallbacks[fileName] = callback
					VoiceUtils.playFileID = fileID
					local errorCode = sdkMgr:gvoice_startPlayVoice(fileName, onPlayCallback)
					if tonumber(errorCode) ~= 0 then
						viewMgr:showTip(errorCode)
						sdkMgr:gvoice_setNationalMode()
						callback()
					else
						print("播放成功 ", fileName)
					end
				else
					VoiceUtils.playFileID = nil
					callback()
					print("停止播放 ", fileName)
					sdkMgr:gvoice_setNationalMode()
				end
			else
				if VoiceUtils.playFileID then
					VoiceUtils.toStopPlay = true
				end
				sdkMgr:gvoice_stopPlayVoice()
				sdkMgr:gvoice_poll()
				viewMgr:lock(-1)
				print("开始下载 ", fileName)
				local errorCode = sdkMgr:gvoice_downloadRecVoice(fileName, fileID, function ()
					playCallbacks[fileName] = callback
					VoiceUtils.playFileID = fileID
					local errorCode = sdkMgr:gvoice_startPlayVoice(fileName, onPlayCallback)
					if tonumber(errorCode) ~= 0 then
						viewMgr:showTip(errorCode)
						sdkMgr:gvoice_setNationalMode()
						callback()
					else
						print("播放成功 ", fileName)
					end
					viewMgr:unlock()
				end)
				if tonumber(errorCode) ~= 0 then
					viewMgr:showTip(errorCode)
					viewMgr:unlock()
					callback()
					viewMgr:showTip("下载语音消息失败")
					sdkMgr:gvoice_setNationalMode()
				end
			end
		end
	end)
end

-- UI相关

local UIUpdateId
function VoiceUtils.showRecordUI(_type, long)
	local layer = viewMgr:getVoiceLayer()

	if VoiceUtils.recordUI1 == nil then
		local ui1 = cc.Sprite:createWithSpriteFrameName("chat_voice_1.png")
		ui1:setPosition(318, MAX_SCREEN_HEIGHT * 0.5)
		layer:addChild(ui1)
		VoiceUtils.recordUI1 = ui1
	end
	if VoiceUtils.recordUI2 == nil then
		local ui2 = cc.Sprite:createWithSpriteFrameName("chat_voice_2.png")
		ui2:setPosition(318, MAX_SCREEN_HEIGHT * 0.5)
		layer:addChild(ui2)
		VoiceUtils.recordUI2 = ui2
	end
	VoiceUtils.recordUI1:setVisible(true)
	VoiceUtils.recordUI2:setVisible(false)
	if _type == 1 then
		VoiceUtils.recordUI1:setPosition(318, MAX_SCREEN_HEIGHT * 0.5)
		VoiceUtils.recordUI2:setPosition(318, MAX_SCREEN_HEIGHT * 0.5)
	else
		VoiceUtils.recordUI1:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
		VoiceUtils.recordUI2:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
	end
	-- UIUpdateId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()
	-- 	local time = math.ceil(socket.gettime() - VoiceUtils.startRecordingTick)

	-- end, 1, false)
end

function VoiceUtils.hideRecordUI()
	if UIUpdateId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(UIUpdateId)
		UIUpdateId = nil
	end
	if VoiceUtils.recordUI1 then
		VoiceUtils.recordUI1:setVisible(false)
	end
	if VoiceUtils.recordUI2 then
		VoiceUtils.recordUI2:setVisible(false)
	end
end

function VoiceUtils.changeRecordUI(idx)
	if not VoiceUtils.recording then return end
	if VoiceUtils.recordUI1 then
		VoiceUtils.recordUI1:setVisible(idx == 1)
	end
	if VoiceUtils.recordUI2 then
		VoiceUtils.recordUI2:setVisible(idx == 2)
	end
end

function VoiceUtils.clear()
	local layer = viewMgr:getVoiceLayer()
	layer:removeAllChildren()
	VoiceUtils.recordUI1 = nil
	VoiceUtils.recordUI2 = nil
	if UIUpdateId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(UIUpdateId)
		UIUpdateId = nil
	end
	if updateId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(updateId)
		updateId = nil
	end
end

function VoiceUtils.diantai_Open(callback)
    sdkMgr:gvoice_setNationalMode()
    local errorCode = sdkMgr:gvoice_JoinNationalRoom(GameStatic.diantai_roomName, "2", function ()
        sdkMgr:gvoice_OpenSpeaker()
        VoiceUtils.diantaiOpen = true
        audioMgr:setMusicEnable(false)
        audioMgr:setSoundEnable(false)
        callback()
    end)
    return errorCode
end

function VoiceUtils.diantai_Close(callback)
    sdkMgr:gvoice_setNationalMode()
    local errorCode = sdkMgr:gvoice_QuitRoom(GameStatic.diantai_roomName, function ()
    	VoiceUtils.diantaiOpen = false
    	audioMgr:setMusicEnable(true)
        audioMgr:setSoundEnable(true)
    	callback()
    end)
    return errorCode
end

-- 获取当前正在直播的主播详情
-- 如果返回空则表示当前无直播
--[[
{
	name: 主播名称
	head_url: 头像url
}
]]
function VoiceUtils.diantai_getCurAnchorInfo(callback)
	local httpManager = HttpManager:getInstance()
	httpManager:sendMsg(GameStatic.diantai_url3, "post", 
		{
			appid = GameStatic.diantai_url3_param1,
			appkey = GameStatic.diantai_url3_param2,
			roomid = GameStatic.diantai_url3_param3,
			ckey = GameStatic.diantai_url3_param4,
		}, 
        function(result) 
        	for k, v in ipairs(result["data"]["anchor_list"]) do
        		if v.play_status ~= 0 then
        			dump(v)
        			callback(
        			{
        				name = v.anchor_nick,
        				head_url = v.anchor_img_url,
        			})
        			return
        		end
        	end
        	if callback then callback() end
        end, 
        function(status, errorCode, response)
         	if callback then callback() end
        end,
        false)
end

function VoiceUtils.dtor()
	fu = nil
	viewMgr = nil
	onPlayCallback = nil
	playCallbacks = nil
end

return VoiceUtils
