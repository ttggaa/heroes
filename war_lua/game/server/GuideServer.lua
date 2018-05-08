--[[
    Filename:    GuideServer.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-05-17 10:21:35
    Description: File description
--]]

local GuideServer = class("GuideServer",BaseServer)

function GuideServer:ctor(data)
    GuideServer.super.ctor(self,data)

end

function GuideServer:onSetGuildTrigger(result, error)
	self:callback(result)
end 

return GuideServer