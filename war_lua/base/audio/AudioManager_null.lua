--[[
    Filename:    AudioManager_null.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-11-24 17:18:37
    Description: File description
--]]

local AudioManager = class('AudioManager')

function AudioManager:ctor() end
function AudioManager:getInstance() end
function AudioManager:enable() end
function AudioManager:disable() end
function AudioManager:init() end
function AudioManager:playMusic() end
function AudioManager:playSoundForce() end
function AudioManager:stopMusic() end
function AudioManager:playSound() end
function AudioManager:playSoundEx() end
function AudioManager:stopSound() end
function AudioManager:setVolume() end
function AudioManager:setVolumeEx() end
function AudioManager:pauseAll() end
function AudioManager:resumeAll() end
function AudioManager:stopAll() end
function AudioManager:setAllVolume() end
function AudioManager:setSoundEnable() end
function AudioManager:setMusicEnable() end
function AudioManager:setSoundEnable() end
function AudioManager:preloadSound() end
function AudioManager:fadeInMusic() end
function AudioManager:fadeOutMusic() end
function AudioManager:playTalk() end

return AudioManager