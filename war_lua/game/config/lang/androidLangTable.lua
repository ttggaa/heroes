--[[
    Filename:    androidLangTable.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-03-12 16:08:55
    Description: File description
--]]
local langTab = {}

langTab["zn"] = "cn"
langTab["zh"] = "cn"

local key = GameStatic.languageKey

if langTab[key] then
	return langTab[key]
else
	return  "cn"
end