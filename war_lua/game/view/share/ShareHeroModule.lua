--[[
    Filename:    ShareHeroModule.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-02-04 17:41:35
    Description: File description
--]]

local ShareBaseView = require("game.view.share.ShareBaseView")


function ShareBaseView:transferData(data)
    self._data = data
end

function ShareBaseView:getShareBgName()
    if self._data.heroId == nil then return "" end
    -- if self._data.heroId ~= 60001 then
    --     self._viewMgr:showTip("就一个英雄图啊，找昊然啊")
    --     return
    -- end
    return "asset/bg/share/share_hero_" .. self._data.heroId .. ".jpg"
end


function ShareBaseView:getShareId()
    return 1
end

function ShareBaseView:getMonitorContent()
    return self._data.heroId
end