--[[
    Filename:    PushUtils.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-05-31 12:29:10
    Description: File description
--]]
local PushUtils = {}

--[[
    @function setLocalPhysicalPush
    @desc  本地体力push
--]]
function PushUtils:setLocalPhysicalPush()
    if sdkMgr and ModelManager then 
        -- 注意这个方法被调用时可能有些表没有载入，需要有容错机制
        if GameStatic and not GameStatic.setting_PushPhysic then return end
        local physicFullTime = ModelManager:getInstance():getModel("UserModel"):getPhysicFullTime()
        if physicFullTime > 0 then 
            local param = {timestamp = physicFullTime + os.time(), message = lang("push1")}
            sdkMgr:setLocalPush(param)
        end
        local guildPowerFullTime = ModelManager:getInstance():getModel("UserModel"):getGuildPowerFullTime()
        if guildPowerFullTime > 0 then
            local param = {timestamp = guildPowerFullTime + os.time(), message = lang("push2")}
            sdkMgr:setLocalPush(param)
        end
    end
end

--[[
    @function cancelLocalPhysicalPush
    @desc  取消本地
--]]
function PushUtils:cancelLocalPush()
    -- 本地push
    if sdkMgr then 
        sdkMgr:cancelLocalPush()
    end
end

return PushUtils
