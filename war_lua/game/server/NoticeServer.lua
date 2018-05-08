--[[
    Filename:    NoticeServer.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-03-02 17:23:33
    Description: File description
--]]

local NoticeServer = class("NoticeServer", BaseServer)

function NoticeServer:ctor()
	NoticeServer.super.ctor(self,data)
	self._noticeModel = self._modelMgr:getModel("NoticeModel")
end

function NoticeServer:onPushNotice(result, error)
	self._noticeModel:insertData(result)
end

function NoticeServer:onGetFlauntNotice(result, error)
    if error ~= 0 then
        return
    end
    self._noticeModel:insertData(result)
    self:callback(result)
end

function NoticeServer:onGetSysNotice(result, error)
    if error ~= 0 then
        return
    end
    self._noticeModel:insertData(result)
    self:callback(result)
end

function NoticeServer:onPushSysNotice(result, error)
    self._noticeModel:insertData(result)
    self:callback(result)
end

return NoticeServer