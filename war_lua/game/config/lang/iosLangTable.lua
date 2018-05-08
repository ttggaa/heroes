--[[
    Filename:    iosLangTable.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-03-12 16:02:48
    Description: File description
--]]

local key = GameStatic.languageKey 
if string.find(key, "zh-") then
	-- 汉语
	if string.find(key, "zh-TW") then
		-- 台湾繁体
		return "cn"
	elseif string.find(key, "zh-HK") then
		-- 香港繁体
		return "cn"
	elseif string.find(key, "zh-Hant") then
		-- 繁体
		return "cn"
	else
		-- 简体
		return "cn"
	end
else
	return "cn"
end