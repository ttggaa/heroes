--[[
    Filename:    AudioManager.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-08-19 10:21:56
    Description: File description
--]]

-- android 6.0 以后 用audioEngine 会出现pools只增加不减少的状况
-- 因此android使用SimpleAudioEngine
-- ios使用AudioManager
local AudioManager = class('AudioManager')

local _audioManager = nil
local _engine
local _engineEx
local MUSIC_PATH = "asset/music/"
local SOUND_PATH = "asset/sound/"
local AUDIO_EX = ".mp3"

-- local useSimpleAudioEngine = OS_IS_WINDOWS
local useSimpleAudioEngine = OS_IS_ANDROID

local MAX_VOLUME_MUSIC = 0.2
local MAX_VOLUME_SOUND = 0.4
if useSimpleAudioEngine then
    MAX_VOLUME_MUSIC = 0.4
    MAX_VOLUME_SOUND = 0.8
    if not OS_IS_WINDOWS then
        MUSIC_PATH = "asset/music_ogg/"
        SOUND_PATH = "asset/sound_ogg/"
        AUDIO_EX = ".ogg"
    end
end
local volume_level = {0, 0.05, 0.12, 0.18, 0.3, 0.5}
local musicTab = {}

local soundPlayed = {}
function AudioManager:ctor()
	self:init()
    if self:isOtherAudioPlaying() then
        self:disable()
    end
end

local function getAudioName(filename)
    if string.find(filename, ".mp3") then
        return string.gsub(filename, ".mp3", AUDIO_EX)
    else
        return filename .. AUDIO_EX
    end
end

function AudioManager:getInstance()
    if _audioManager == nil  then 
        _audioManager = AudioManager.new()
        return _audioManager
    end
    return _audioManager
end

function AudioManager:isOtherAudioPlaying()
    if useSimpleAudioEngine then
        return false
    else
        return _engine:isOtherAudioPlaying()
    end
end

function AudioManager:clear()
    ScheduleMgr:cleanMyselfTicker(self)
    self._updateId = nil
    for k, v in pairs(musicTab) do
        ScheduleMgr:unregSchedule(k)
    end
    if useSimpleAudioEngine then
        _engineEx:stopMusic()
        _engineEx:stopAllEffects()
    else
        _engine:stopAll()
    end
    self._musicId = nil
    self._musicFileName = nil
end

function AudioManager:enable()
    self._enable = true
    ScheduleMgr:delayCall(1000, self, function()
        self:resumeAll()
    end)
    self:shouldPlayMusic()
    if self._updateId == nil then
        self._updateId = ScheduleMgr:regSchedule(50, self, function(self, dt)
            self:update()
        end)
    end
end

function AudioManager:disable()
    self:clear()
    self._enable = false
end

function AudioManager:adjustMusicVolume(value)
    if useSimpleAudioEngine then
        local oldVolume = MAX_VOLUME_MUSIC
        MAX_VOLUME_MUSIC = volume_level[value + 1] * 0.8
        if oldVolume == MAX_VOLUME_MUSIC then
            return
        end
        if self._musicEnable then
            if oldVolume ~= 0 and MAX_VOLUME_MUSIC == 0 then
                _engineEx:stopMusic()
                self._musicFileName = nil
            elseif MAX_VOLUME_MUSIC ~= 0 and oldVolume == 0 then
                self:shouldPlayMusic()
            end
            _engineEx:setMusicVolume(MAX_VOLUME_MUSIC)
        end
    else
        local oldVolume = MAX_VOLUME_MUSIC
        MAX_VOLUME_MUSIC = volume_level[value + 1] * 0.4
        if oldVolume == MAX_VOLUME_MUSIC then
            return
        end
        if self._musicEnable then
            if oldVolume ~= 0 and MAX_VOLUME_MUSIC == 0 then
                if self._musicId then
                    _engine:stop(self._musicId)
                    if musicTab[self._musicId] then
                        ScheduleMgr:unregSchedule(musicTab[self._musicId])
                        musicTab[self._musicId] = nil
                    end
                    self._musicFileName = nil
                    self._musicId = nil
                end
                return
            elseif MAX_VOLUME_MUSIC ~= 0 and oldVolume == 0 then
                self:shouldPlayMusic()
            end
            if self._musicId then
                _engine:setVolume(self._musicId, MAX_VOLUME_MUSIC)
            end
        end
    end
end

function AudioManager:adjustSoundVolume(value)
    if useSimpleAudioEngine then
        MAX_VOLUME_SOUND = volume_level[value + 1] * 1.6
        if self._soundEnable then
            _engineEx:setEffectsVolume(MAX_VOLUME_SOUND)
        end
    else
        MAX_VOLUME_SOUND = volume_level[value + 1] * 0.8
        if self._soundEnable then
            _engine:setAllVolume(MAX_VOLUME_SOUND)
        end
        if self._musicId then
            if self._musicEnable then
                _engine:setVolume(self._musicId, MAX_VOLUME_MUSIC)
            else
                _engine:setVolume(self._musicId, 0)
            end
        end
    end
end

function AudioManager:init()
    self._enable = true
	self._musicId = nil
    self._musicFileName = nil

    self._soundEnable = true
    self._musicEnable = true

    if useSimpleAudioEngine then
        _engineEx = cc.SimpleAudioEngine:getInstance()
        _engine = ccexp.AudioEngine
    else
        _engine = ccexp.AudioEngine
    end
    self._updateId = ScheduleMgr:regSchedule(50, self, function(self, dt)
        self:update()
    end)
end

function AudioManager:shouldPlayMusic()
    if self._shouldPlayMusicFileName and self._musicId == nil then
        self:playMusic(self._shouldPlayMusicFileName, true)
        print("shouldPlayMusic", self._shouldPlayMusicFileName)
    end
end

function AudioManager:getMusicFileName()
    return self._musicFileName
end

function AudioManager:playMusic(filename, loop)
    self._shouldPlayMusicFileName = filename
    if not self._enable then return end
    if self._musicFileName == filename then return end
    print("music", filename)
    if useSimpleAudioEngine then
        if MAX_VOLUME_MUSIC == 0 then return end
        _engineEx:playMusic(MUSIC_PATH..getAudioName(filename), loop)
        self._musicFileName = filename
    else
        if self._musicId then
            if self._musicEnable then
                local fadeoutid = self._musicId
                self:fadeOutMusic(fadeoutid)
                self._musicId = _engine:play2d(MUSIC_PATH..getAudioName(filename), loop, 0)
                self._musicFileName = filename
                self:fadeInMusic(self._musicId)
            else
                _engine:stop(self._musicId)
                self._musicId = _engine:play2d(MUSIC_PATH..getAudioName(filename), loop, 0)
                _engine:setVolume(self._musicId, 0)
            end
        else
            if MAX_VOLUME_MUSIC == 0 then return end
            self._musicId = _engine:play2d(MUSIC_PATH..getAudioName(filename), loop, 0)
            self._musicFileName = filename
            if self._musicEnable then
                self:fadeInMusic(self._musicId)
            else
                _engine:setVolume(self._musicId, 0)
            end
        end
    end
end

function AudioManager:stopMusic()
    self._shouldPlayMusicFileName = nil
    if not self._enable then return end
    if useSimpleAudioEngine then
        _engineEx:stopMusic()
        self._musicFileName = nil
    else
        if self._musicId then
            self:fadeOutMusic(self._musicId)
            self._musicFileName = nil
            self._musicId = nil
        end
    end
end

-- audioEngine
function AudioManager:fadeInMusic(musicId)
    local _musicId = musicId
    local volume = 0
    musicTab[_musicId] = ScheduleMgr:regSchedule(0, self, function(self, dt)
        if ScheduleMgr == nil then return end
        if _engine == nil then return end
        volume = volume + dt * 0.4
        _engine:setVolume(_musicId, volume)
        if volume > MAX_VOLUME_MUSIC then
            _engine:setVolume(_musicId, MAX_VOLUME_MUSIC)
            ScheduleMgr:unregSchedule(musicTab[_musicId])
            musicTab[_musicId] = nil
        end
    end)
end

-- audioEngine
function AudioManager:fadeOutMusic(musicId)
    local _musicId = musicId
    if musicTab[_musicId] then
        ScheduleMgr:unregSchedule(musicTab[_musicId])
        musicTab[_musicId] = nil
    end
    local volume = _engine:getVolume(_musicId)
    musicTab[_musicId] = ScheduleMgr:regSchedule(0, self, function(self, dt)
        if ScheduleMgr == nil then return end
        if _engine == nil then return end
        volume = volume + (0 - volume) * 0.04
        _engine:setVolume(_musicId, volume)
        if math.abs(volume - 0) <= 0.04 then
            ScheduleMgr:unregSchedule(musicTab[_musicId])
            musicTab[_musicId] = nil
            _engine:stop(_musicId)
        end
    end)
end


function AudioManager:preloadSound(filename)
    if useSimpleAudioEngine then
        print("preloadSound", filename)
        _engineEx:preloadEffect(SOUND_PATH..getAudioName(filename))
        -- _engineEx:playEffect(SOUND_PATH..getAudioName(filename), false, 1, 0, 0)
    end
end

function AudioManager:stopSoundForce(id)
    if not self._enable then return end
    if id == nil then return end
    if useSimpleAudioEngine then
        _engine:stop(id)
    else
        _engine:stop(id)
    end
end

function AudioManager:playSoundForce(filename, loop, volume, volumeEx)
    if not self._enable then return end
    if volume == nil then
        volume = MAX_VOLUME_SOUND
    end
    if volume > MAX_VOLUME_SOUND then
        volume = MAX_VOLUME_SOUND
    end
    if volumeEx then
        volume = volumeEx
    end
    if not self._soundEnable then
        volume = 0
    end
    if loop == nil then
        loop = false
    end
    if not loop and volume == 0 then return end
    print("sound", filename)
    if not loop then
        if soundPlayed[filename] then return end
        soundPlayed[filename] = true
    end
    if useSimpleAudioEngine then
            -- virtual unsigned int playEffect(const char* pszFilePath, bool bLoop = false,
            --                         float pitch = 1.0f, float pan = 0.0f, float gain = 1.0f);
            -- gain 为百分比
        return _engine:play2d(SOUND_PATH..getAudioName(filename), loop, volume)
    else
        return _engine:play2d(SOUND_PATH..getAudioName(filename), loop, volume)
    end
end

function AudioManager:playSound(filename, loop, volume)
    if not self._enable then return end
    if volume == nil then
        volume = MAX_VOLUME_SOUND
    end
    if volume > MAX_VOLUME_SOUND then
        volume = MAX_VOLUME_SOUND
    end
    if not self._soundEnable then
        volume = 0
    end
    if loop == nil then
        loop = false
    end
    if not loop and volume == 0 then return end
    print("sound", filename)
    if not loop then
        if soundPlayed[filename] then return end
        soundPlayed[filename] = true
    end
    if useSimpleAudioEngine then
            -- virtual unsigned int playEffect(const char* pszFilePath, bool bLoop = false,
            --                         float pitch = 1.0f, float pan = 0.0f, float gain = 1.0f);
            -- gain 为百分比
        local pro
        if MAX_VOLUME_SOUND == 0 then
            pro = 0
        else
            pro = volume / MAX_VOLUME_SOUND
        end
        return _engineEx:playEffect(SOUND_PATH..getAudioName(filename), loop, 1, 0, pro)
    else
        return _engine:play2d(SOUND_PATH..getAudioName(filename), loop, volume)
    end
end

function AudioManager:playSoundEx(filename, loop, volumePro)
    if not self._enable then return end
    if not self._soundEnable then
        volumePro = 0
    end
    if loop == nil then
        loop = false
    end
    if not loop and volumePro == 0 then return end
    print("sound", filename)
    if not loop then
        if soundPlayed[filename] then return end
        soundPlayed[filename] = true
    end
    if useSimpleAudioEngine then
            -- virtual unsigned int playEffect(const char* pszFilePath, bool bLoop = false,
            --                         float pitch = 1.0f, float pan = 0.0f, float gain = 1.0f);
            -- gain 为百分比
        return _engineEx:playEffect(SOUND_PATH..getAudioName(filename), loop, 1, 0, volumePro)
    else
        return _engine:play2d(SOUND_PATH..getAudioName(filename), loop, volumePro * MAX_VOLUME_SOUND)
    end
end

function AudioManager:stopSound(id)
    if not self._enable then return end
    if id == nil then return end
    if useSimpleAudioEngine then
        _engineEx:stopEffect(id)
    else
        _engine:stop(id)
    end
end

function AudioManager:setVolume(id, volume)
    if not self._enable then return end
    if not self._soundEnable then return end
    if id ~= self._musicId then return end
    if id == nil then return end
    if useSimpleAudioEngine then
        -- todo
        if _engineEx.setEffectVolume then
            _engineEx.setEffectVolume(id, volume)
        end
    else
        _engine:setVolume(id, volume)
    end
end

function AudioManager:setVolumeEx(id, volumePro)
    if not self._enable then return end
    if not self._soundEnable then return end
    if id ~= self._musicId then return end
    if id == nil then return end
    if useSimpleAudioEngine then
        -- todo
        if _engineEx.setEffectVolume then
            _engineEx.setEffectVolume(id, volumePro * MAX_VOLUME_SOUND)
        end
    else
        _engine:setVolume(id, volumePro * MAX_VOLUME_SOUND)
    end
end

function AudioManager:pauseAll(all)
    if not self._enable then return end
    if useSimpleAudioEngine then
        if all then
            _engineEx:pauseMusic()
        end
        _engineEx:pauseAllEffects()
    else
        _engine:pauseAll()
        if not all then
            if self._musicId then
                _engine:resume(self._musicId)
            end
        end
    end
end

function AudioManager:resumeAll()
    if not self._enable then return end
    if useSimpleAudioEngine then
        _engineEx:resumeMusic()
        _engineEx:resumeAllEffects()
    else
        _engine:resumeAll()
    end
end

function AudioManager:stopAll()
    if not self._enable then return end
    if useSimpleAudioEngine then
        _engineEx:stopMusic()
        _engineEx:stopAllEffects()
    else
        _engine:stopAll()
    end
    self._musicFileName = nil
    self._musicId = nil
end

-- audioEngine
function AudioManager:setAllVolume(volume)
    if not self._enable then return end
    _engine:setAllVolume(volume)
end

function AudioManager:setSoundEnable(enable)
    if self._soundEnable == enable then return end
    self._soundEnable = enable
    if useSimpleAudioEngine then
        if enable then
            _engineEx:setEffectsVolume(MAX_VOLUME_SOUND)
        else
            _engineEx:setEffectsVolume(0)
        end
    else
        if enable then
            self:setAllVolume(MAX_VOLUME_SOUND)
        else
            self:setAllVolume(0)
        end
    end
    self:setMusicEnable(self._musicEnable)
end

function AudioManager:setMusicEnable(enable)
    self._musicEnable = enable
    if useSimpleAudioEngine then
        if enable then
            _engineEx:setMusicVolume(MAX_VOLUME_MUSIC)
        else
            _engineEx:setMusicVolume(0)
        end
    else
        if self._musicId == nil then return end
        if enable then
            _engine:setVolume(self._musicId, MAX_VOLUME_MUSIC)
        else
            _engine:setVolume(self._musicId, 0)
        end
    end
end

function AudioManager:preloadSounds(list, callback1, callback2)
    local index = 1
    self._loadUpdateId = ScheduleMgr:regSchedule(1, self, function(self, dt)
        self:preloadSound(list[index])
        callback1()
        index = index + 1
        if index > #list then
            ScheduleMgr:unregSchedule(self._loadUpdateId)
            callback2()
        end
    end)
end

function AudioManager:playTalk(filename)
    if self._talkId then
        self:stopSoundForce(self._talkId)
        self._talkId = nil
    end
    self._talkId = self:playSoundForce(filename)
end

function AudioManager:update()
    -- audioManager的update
    -- 主要用来限制每一帧播放的sound数量
    if next(soundPlayed) ~= nil then
        soundPlayed = {}
    end
end

function AudioManager.dtor()
    _audioManager = nil
    _engine = nil
    AudioManager = nil
    MAX_VOLUME_MUSIC = nil
    MAX_VOLUME_SOUND = nil
    musicTab = nil
    volume_level = nil
    soundPlayed = nil
end

return AudioManager