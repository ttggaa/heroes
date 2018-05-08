--[[
    Filename:    SystemServer.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-07-07 12:43:12
    Description: File description
--]]

local SystemServer = class("SystemServer", BaseServer)
function SystemServer:ctor(data)
    SystemServer.super.ctor(self, data)
end

function SystemServer:onPlatformLogin(result, error)
    if error ~= 0 then

    else
        self._serverMgr:setPid(result["pid"])
        self:callback()
    end
end

function SystemServer:onGetSecs(result, error)
    if error ~= 0 then

    end
    self:callback(result)
end

function SystemServer:onBroadcast(result)
    print("5 ==== 点刷新")
    if not self._initModel then
        self._taskModel = self._modelMgr:getModel("TaskModel")
        self._activityModel = self._modelMgr:getModel("ActivityModel")
        self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
        self._mainViewModel = self._modelMgr:getModel("MainViewModel")
        self._bossModel = self._modelMgr:getModel("BossModel")
        self._initModel = true
    end
    self._activityModel:updateActivityUI()
    self._playerTodayModel:checkDay()
    self._taskModel:setOutOfDate()
    self._bossModel:setOutOfDate()
    self._mainViewModel:reflashMainView()
    self:callback(result)
end

return SystemServer