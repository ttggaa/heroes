--[[
    Filename:    IndexServer.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2017-01-04 15:25:05
    Description: File description
--]]
local IndexServer = class("IndexServer", BaseServer)

function IndexServer:ctor(data)
    IndexServer.super.ctor(self, data)
end

function IndexServer:onReadIdipMsg(result, error)
    print("IndexServer:onReadIdipMsg")
end

return IndexServer
