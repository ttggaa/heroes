--[[
    Filename:    GuildUtils.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-04-22 12:22:54
    Description: File description
--]]
local GuildUtils = {}

-- 用于显示玩家当前在线状态
function GuildUtils:getDisTodayTime(leaveTime)
    if not leaveTime then
        return "在线"
    end
    local loginTime
    local curServerTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
    local tempTime = curServerTime - leaveTime
    if tempTime > 86400 then
        loginTime = math.ceil(tempTime/86400) .. "天前"
    elseif tempTime > 3600 then
        loginTime = math.ceil(tempTime/3600) .. "小时前"
    -- elseif tempTime > 0 then
    --     loginTime = math.ceil(tempTime/60) .. "分钟前"
    else
        loginTime = "在线"
    end
    return loginTime 
end

--[[
    显示联盟成员列表，玩家登录时间
]]
function GuildUtils:getLoginTimeDes(loginTime)
    local curServerTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
    -- print("loginTime",loginTime)
    local diff = curServerTime - loginTime
    local des
    local color
    if diff > 86400 then
        des = math.floor(diff/86400) .. "天前登录"
    elseif diff > 3600 then
        des = math.floor(diff/3600) .. "小时前登录"
    else
        des = "在线"
        color = cc.c4b(28, 162, 22, 255)
    end
    return des,color
end

-- 用于显示战报时间
function GuildUtils:getDisNowTime(leaveTime)
    if not leaveTime then
        return "1分钟前"
    end
    local loginTime
    local curServerTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
    local tempTime = curServerTime - leaveTime
    if tempTime > 86400 then
        loginTime = math.ceil(tempTime/86400) .. "天前"
    elseif tempTime > 3600 then
        loginTime = math.ceil(tempTime/3600) .. "小时前"
    elseif tempTime > 0 then
        loginTime = math.ceil(tempTime/60) .. "分钟前"
    else
        loginTime = "1分钟前"
    end
    return loginTime 
end

function GuildUtils:getRedType(redType)
    local classType, className
    if redType == "gold" then
        classType = 1
        className = "金币红包"
    elseif redType == "gem" then
        classType = 2
        className = "钻石红包"
    else -- if redType == "treasureCoin" then
        classType = 3
        className = "宝物红包"
    end
    return classType, className
end


return GuildUtils