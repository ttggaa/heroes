--[[
    Filename:    ToolsServer.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-12-21 17:11:39
    Description: File description
--]]


local ToolsServer = class("ToolsServer", BaseServer)

function ToolsServer:ctor(data)
    ToolsServer.super.ctor(self,data)

end

function ToolsServer:onClearUser(result, error)
	if error ~= 0 then 
		return
	end

    self:callback()
end


return ToolsServer