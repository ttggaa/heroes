
--[[
    Filename:    BulletModel.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    Datetime:    2017-01-20 14:41:57
    Description: File description
--]]

local BulletModel = class("BulletModel", BaseModel)

function BulletModel:ctor()
    BulletModel.super.ctor(self)
    self._data = {}
    -- 用来判断是否需要重新取数据
    self._dataTick = {}

    -- 发送CD
    self._dataPushTick = {}
end

function BulletModel:setData(data)
    self._data = data
end

function BulletModel:getData()
    return self._data
end

function BulletModel:setChannelData(key, data)
    local _data = {}
    -- 整理数据
    for _, __data in pairs(data) do
        if not self:checkRepeatBullet(__data.w, _data) then
            if __data.cross == 1 then
                _data[#_data + 1] = {__data.t, __data.w, __data.c, __data.p + 5}
            else
                _data[#_data + 1] = {__data.t, __data.w, __data.c, __data.p}
            end
        end
    end
    self._data[key] = _data
    self._dataTick[key] = socket.gettime()
end

function BulletModel:getChannelData(key)
    if self._dataTick[key] == nil then
        return nil
    end
    if socket.gettime() > self._dataTick[key] + 300 then
        return nil
    else
        return self._data[key]
    end
end

function BulletModel:setBulletCanPushTick(key, tick)
    self._dataPushTick[key] = tick
end

function BulletModel:getBulletCanPushTick(key)
    return self._dataPushTick[key]
end

function BulletModel:checkRepeatBullet( str, data )
    if str == nil or str == "" then
        return true
    end
    if data == nil then
        return false
    end
    local count = 0
    for k, v in pairs(data) do
        if v[2] and v[2] == str then
            count = count + 1
        end
    end
    local maxCount = tonumber(tab.setting["G_BULLET_COMMON_LIMIT"].value)
    if count >= maxCount then
        return true
    end
    return false
end

return BulletModel