--[[
    Filename:    BulletServer.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-01-20 14:41:57
    Description: File description
--]]


local BulletServer = class("BulletServer", BaseServer)

function BulletServer:ctor(data)
    BulletServer.super.ctor(self)
    self._bulletModel = self._modelMgr:getModel("BulletModel")
    if data then
        self._bulletD = data.bulletD
    end
end

function BulletServer:onSendBullet(result, error)
    -- dump(result)
    self:callback(result, error)
end

function BulletServer:onGetBullet(result, error)
    -- dump(result)
    if error == 0 then
        if self._bulletD["live"] ~= 1 then
            self._bulletModel:setChannelData(self._bulletD["id"], result)
        end
    end
    self:callback(result, error)
end

-- 实时弹幕
function BulletServer:onSendLiveBullet(result, error)
    self:callback(result, error)
end

function BulletServer:onPushMessage(result, error)
    if BulletScreensUtils.enable then
        if result.sid == BulletScreensUtils.bulletD["id"] then
            local info = result.info
            if info.cross == 1 then
                BulletScreensUtils.showBulletNow(info.p + 5, {0, info.w, info.c})
            else
                BulletScreensUtils.showBulletNow(info.p, {0, info.w, info.c})
            end 
        end
    end
end

return BulletServer