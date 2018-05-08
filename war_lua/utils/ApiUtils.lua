--[[
    Filename:    ApiUtils.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-02-23 18:35:00
    Description: File description
--]]

local ApiUtils = {}

local netServer = pc.NetServer:getInstance()
local PCTools = pc.PCTools
local FileUtils = cc.FileUtils:getInstance()

local CUR_PLATFORM = cc.Application:getInstance():getTargetPlatform()
local PLATFORM_NAMES = {"windows", "linux", "mac", "android", "iphone", "ipad", "blackberry", "nacl", "emscripten", "tizen", "winrt", "wp8"}
local CUR_PLATFORM_NAME = PLATFORM_NAMES[CUR_PLATFORM + 1]
--[[
    ======================================================================
        玩蟹科技出品
        lua报错上传
    ======================================================================
--]]
local luabridge, className
if cc.PLATFORM_OS_IPHONE == CUR_PLATFORM
    or cc.PLATFORM_OS_IPAD == CUR_PLATFORM then
    luabridge = require "cocos.cocos2d.luaoc"
    className = "SDKUtils"
elseif cc.PLATFORM_OS_ANDROID == CUR_PLATFORM then
    luabridge = require "cocos.cocos2d.luaj"
    className = "com/utils/core/SDKUtils"
end

function ApiUtils.saveGlobalLocalData(key, data)
    UserDefault:setStringForKey("global_" .. key, data)
end

function ApiUtils.loadGlobalLocalData(key)
    return UserDefault:getStringForKey("global_" .. key, nil)
end


function ApiUtils.getDeviceIP()
    if not OS_IS_WINDOWS then 
        return ""
    end
    function GetIP(hostname)
        local ip, resolved = socket.dns.toip(hostname)
        local ListTab = {}
        for k, v in ipairs(resolved.ip) do
            table.insert(ListTab, v)
        end
        return ListTab
    end
    local ipAddress = unpack(GetIP(socket.dns.gethostname()))
    if ipAddress == nil or ipAddress == "" then 
        ipAddress = WINDOWS_DEVICEID
    end
    return ipAddress
end

-- 获取设备唯一ID
function ApiUtils.getDeviceID()
    if cc.PLATFORM_OS_IPHONE == CUR_PLATFORM
        or cc.PLATFORM_OS_IPAD == CUR_PLATFORM then
        local ret, deviceid = luabridge.callStaticMethod("SDKUtils", "getDeviceID", {})
        return deviceid
    elseif cc.PLATFORM_OS_ANDROID == CUR_PLATFORM then
        local ret, deviceid = luabridge.callStaticMethod("com/utils/core/SDKUtils", "getDeviceID", {})
        return deviceid
    else
        return CUR_PLATFORM_NAME.."_" .. ApiUtils.getDeviceIP()
    end
end

-- 获取公告
function ApiUtils.getNotice(scene)
    if not GameStatic.openNotice then return end
    local viewMgr = ViewManager:getInstance()
    if OS_IS_WINDOWS then
        viewMgr:lock(2000)
        local noticeUrl = AppInformation:getInstance():getValue("global_server_url", GameStatic.httpAddress_notice)
        HttpManager:getInstance():sendMsg(noticeUrl, nil, {mod="global", method="Notice.getNotice", pGroup=GameStatic.userSimpleChannel, rand=math.random()}, 
        function(inData)
            if not viewMgr then return end
            viewMgr:unlock()
            dump(inData)
            if inData == nil or inData.result == nil or type(inData.result) ~= "string" or string.len(inData.result) <= 0 then 
                viewMgr:showTip("暂无公告")
                return 
            end
            viewMgr:showDialog("login.LoginNoticeView",{data = inData.result}, true)
        end,
        function()
            if not viewMgr then return end
            viewMgr:unlock()
            viewMgr:showTip("暂无公告")
        end,
        GameStatic.useHttpDns_Notice)
    else
        -- scene为公告栏ID
        -- 1为登录前 2为登陆后
        local jsonData = sdkMgr:getNoticeData(scene)
        if jsonData ~= "" then
            local data = json.decode(jsonData)
            if #data > 0 then
                -- msg_title
                -- 取最新一条
                table.sort(data, function (a, b)
                    return tonumber(a.msg_id) > tonumber(b.msg_id)
                end)
                ApiUtils.playcrab_device_monitor_action("gonggao")
                function showNotice(index)
                    if index > #data then return end
                    viewMgr:showDialog("login.LoginNoticeView", {data = data[index]["msg_content"], 
                        callback = function ()
                            showNotice(index + 1)
                        end}, true)
                end
                showNotice(1)
            else
                viewMgr:showTip("暂无公告")
            end
        else
            viewMgr:showTip("暂无公告")
        end
    end
end

-- 获取设备信息
function ApiUtils.getDeviceInfo()
    if cc.PLATFORM_OS_IPHONE == CUR_PLATFORM
        or cc.PLATFORM_OS_IPAD == CUR_PLATFORM then
        local ret, deviceinfo = luabridge.callStaticMethod("SDKUtils", "getDeviceInfo", {})
        return json.decode(deviceinfo)
    elseif cc.PLATFORM_OS_ANDROID == CUR_PLATFORM then
        local ret, deviceinfo = luabridge.callStaticMethod("com/utils/core/SDKUtils", "getDeviceInfo", {})
        return json.decode(deviceinfo)
    else
        return json.decode("{\"os_version\": \"1.0\", \"system_name\":\"windows\", \"model\":\"windowss\"}")
    end
end

-- 获取包信息
function ApiUtils.getPackageInfo()
    if cc.PLATFORM_OS_IPHONE == CUR_PLATFORM
        or cc.PLATFORM_OS_IPAD == CUR_PLATFORM then
        local ret, packageInfo = luabridge.callStaticMethod("SDKUtils", "getPackageInfo", {})
        if not ret then return false end
        return true, json.decode(packageInfo)
    elseif cc.PLATFORM_OS_ANDROID == CUR_PLATFORM then
        local ret, packageInfo = luabridge.callStaticMethod("com/utils/core/SDKUtils", "getPackageInfo", {})
        if not ret then return false end
        return true, json.decode(packageInfo)
    end
end

-- 替换url端口号
function ApiUtils.changeUrlPort(url, newport)
    local dot = string.find(url,":")
    local slash = string.find(url,"/",dot+3)
    if slash == nil then 
        slash = 0
    end
    local name = string.sub(url,dot+3,slash-1)
    local host, port = string.match(name,"([%w%.]+):?([%d]*)")
    if port == "" then
        -- 端口不存在
        local newhost = host .. ":" .. newport
        return string.gsub(url, host, function()
            return newhost
        end)
    else
        return string.gsub(url, port, function()
            return newport
        end)
    end
end

-- HttpDns同步解析接口
ApiUtils.DnsUrlCache = {}
function ApiUtils.getAddrByName(domain)
    if ApiUtils.DnsUrlCache[domain] then
        return ApiUtils.DnsUrlCache[domain]
    end
    if cc.PLATFORM_OS_IPHONE == CUR_PLATFORM
        or cc.PLATFORM_OS_IPAD == CUR_PLATFORM then
        local ret, addrByName = luabridge.callStaticMethod("SDKUtils", "getAddrByName", {domain = domain})
        if not ret then return domain end
        ApiUtils.DnsUrlCache[domain] = addrByName
        return addrByName
        --[[
        local ret, addrByName = luabridge.callStaticMethod("SDKUtils", "getAddrByName", {domain = domain})
        if not ret then return domain end
        return string.split(addrByName, ";")[1]
        return domain
        ]]
    elseif cc.PLATFORM_OS_ANDROID == CUR_PLATFORM then
        local ret, addrByName = luabridge.callStaticMethod("com/utils/core/SDKUtils", "getAddrByName", {domain = domain})
        if not ret then return domain end
        local result = string.split(addrByName, ";")[1]
        if string.find(result, ":") ~= nil then
            -- ipv6 增加中括号
            result = "[" .. result .. "]"
        end
        ApiUtils.DnsUrlCache[domain] = result
        return result
    end
    return domain
end

ApiUtils.domainCache = {}
function ApiUtils.getHttpDnsUrl(domain)
    if ApiUtils.domainCache[domain] then
        return ApiUtils.domainCache[domain]
    end
    local ret, newIp, urlhost = trycall("getHttpDnsUrl", ApiUtils._getHttpDnsUrl, domain)
    if not ret then
        return domain
    else
        return newIp, urlhost
    end
end

function ApiUtils._getHttpDnsUrl(domain)
    if string.find(domain,"http://") == nil and  
        string.find(domain,"ws://") == nil and
        string.find(domain,"wss://") == nil and
        string.find(domain,"https://") == nil then
        print("不符合规格url")
        return domain, domain
    end
    local dot = string.find(domain,":")
    local slash = string.find(domain,"/",dot+3)
    if slash == nil then 
        slash = 0
    end
    local name = string.sub(domain,dot+3,slash-1)
    local host,port = string.match(name,"([%w%.]+):?([%d]*)")
    local splitHost = string.split(host, "%.")
    local isIpAddress = true
    for k,v in pairs(splitHost) do
        if tonumber(v) == nil then 
            isIpAddress = false
            break
        end
    end
    if isIpAddress then 
        return domain, host
    end
    local newIpAddres = ApiUtils.getAddrByName(host)
    if newIpAddres == host then 
        return domain, host
    end
    local tempDesc = string.gsub(domain, host,function(inSubStr)
        return newIpAddres, host
    end)
    ApiUtils.domainCache[domain] = tempDesc
    return tempDesc
end

local CHANNEL = "playcrab"
local GAME = "war"
local PLATFORM = kakura.Config:getInstance():getValue("APP_DEPLOYMENT")
local DEVICE_ID = ApiUtils.getDeviceID()

-- lua报错 开关
local ENABLE_UPLOAD_LUA_ERROR = not OS_IS_WINDOWS
-- 客户端打点 开关
local ENABLE_UPLOAD_MONITOR = OS_IS_WINDOWS
-- 问题反馈 开关
local ENABLE_PROPOSAL = true--not OS_IS_WINDOWS
--[[
    ======================================================================
        玩蟹科技出品
        lua报错上传
    ======================================================================
--]]

-- 全局报错处理, C++调用此方法
local last_lua_error_msg = ""
function playcrab_lua_error(msg)
    -- 过滤重复报错
    if msg ~= last_lua_error_msg then
        last_lua_error_msg = msg
        local funcName = ""
        local pos1 = string.find(msg, "LUA ERROR: ")
        local pos2 = string.find(msg, "---- TRACEBACK")
        local funcName = string.sub(msg, pos1 + 11, pos2)
        -- local level = 0
        -- local info = debug.getinfo(level)
        -- while info do
        --     if info.namewhat == "method" then
        --         funcName = info.name
        --         break
        --     end
        --     level = level + 1
        --     info = debug.getinfo(level)
        -- end
        ApiUtils.playcrab_lua_error(funcName, msg)

        -- PCLuaError(msg)
    end
    if GameStatic and ViewManager then
        if GameStatic.showLuaError then
            ViewManager:getInstance():onLuaError(msg)
        end
    else
        pc.PCTools:showError(msg)
    end
end

local URL_UPLOAD_LUA_ERROR = "http://api.war.lua.playcrab.com/v1/upload/api/"
local FILEPATH_UPLOAD_LUA_ERROR = cc.FileUtils:getInstance():getWritablePath() .."lua.error"
local MAX_SIZE_UPLOAD_LUA_ERROR = 0 --1024 * 5 -- 文件超过5K 上传
-- 报错写成文件
local errorMap = {} -- 检查重复报错

local _json
local _tab
local version_base = ""
_json = cc.FileUtils:getInstance():getStringFromFile("game.conf")
if _json ~= "" then
    _tab = json.decode(_json)
    version_base = _tab["APP_BUILD_NUM"]
end
local version_current = kakura.Config:getInstance():getValue("APP_BUILD_NUM")
local deviceInfo = ApiUtils.getDeviceInfo()
local sys_version = "getDeviceInfo failed"
if deviceInfo and type(deviceInfo) == "table" then
    sys_version = deviceInfo["system_name"] .. " " .. deviceInfo["os_version"]
end

function ApiUtils.updateVersion()
    local _json = cc.FileUtils:getInstance():getStringFromFile("game.conf")
    if _json ~= "" then
        local _tab = json.decode(_json)
        version_base = _tab["APP_BUILD_NUM"]
    end
    version_current = kakura.Config:getInstance():getValue("APP_BUILD_NUM")
end

-- android层崩溃通知, C++调用此方法
function playcrab_crash_notify_to_lua(code, msg)
    local str = ""
    pcall(function ()
        local data = {}
        data.time = os.time()
        data.platform = PLATFORM
        if ModelManager then
            local userModel = ModelManager:getInstance():getModel("UserModel")
            data.uid = userModel:getUID()
            data.pid = userModel:getPID()
            data.usid = userModel:getUSID()
            data.level = userModel:getPlayerLevel()
        end
        if data.uid == nil then
            data.uid = "unlogin"
            data.pid = "unlogin"
            data.usid = "unlogin"
        end

        data.version_base = version_base
        data.version_current = version_current

        data.sys_version = sys_version
        data.devices_id = DEVICE_ID
        if ViewManager then
            data.now_view = ViewManager:getInstance():getCurViewName()
            data.lastShowDialogName = ViewManager:getInstance():getLastShowDialogName()
        end
        if ServerManager then
            data.lastReq = ServerManager:getInstance():getLastSendAction()
            data.reinitData = ServerManager:getInstance():getReinitData()
        end
        if GLOBAL_VALUES and GLOBAL_VALUES.last_click_ui_name then
            table.sort(GLOBAL_VALUES.last_click_ui_name, function (a, b)
                return a[2] < b[2]
            end)   
            data.last_click_ui = GLOBAL_VALUES.last_click_ui_name
        end
        if last_lua_error_msg then
            data.last_lua_error_msg = last_lua_error_msg
        end
        if GLOBAL_VALUES.last_restart_tick then
            data.last_restart_tick = last_restart_tick
        end
        if ApplicationUtils then
            data.applicationWillEnterForegroundTime = ApplicationUtils.applicationWillEnterForegroundTime
            data.applicationDidEnterBackgroundTime = ApplicationUtils.applicationDidEnterBackgroundTime
            data.applicationDidBecomeActiveTime = ApplicationUtils.applicationDidBecomeActiveTime
            data.applicationWillResignActiveTime = ApplicationUtils.applicationWillResignActiveTime
        end
        data.writablePath = cc.FileUtils:getInstance():getWritablePath()
        str = json.encode(data)
        if ServerManager then
            if GLOBAL_VALUES and GLOBAL_VALUES.last_onResponse then
                -- dump(GLOBAL_VALUES.last_onResponse)
                table.sort(GLOBAL_VALUES.last_onResponse, function (a, b)
                    return a[1] < b[1]
                end)   
                local _dd
                for i = 1, #GLOBAL_VALUES.last_onResponse do
                    _dd = GLOBAL_VALUES.last_onResponse[i]
                    str = str .. "\n" .. json.encode(_dd)
                end
            end
        end
    end)
    if pc and pc.PCTools then
        return pc.PCTools:getOpenGLInfo() .. str
    else
        return str
    end
end

-- 错误cache，如果报错正在上传中，则暂存在这里
local errorStrCache = ""
-- 报错文件上传中
local errorUpdateing = false
function ApiUtils.playcrab_lua_error(function_name, error_stack, error_code)
    if ENABLE_UPLOAD_LUA_ERROR and GameStatic and GameStatic.playcrab_Lua_error then
        pcall(function ()
            local log_time = os.time()
            local md5Key = PCTools:md5(log_time..error_stack)
            if errorMap[md5Key] then return end
            errorMap[md5Key] = true
            -- dump(errorMap)
            local data = {module = "", game = "", platform = "", pid = "", uid = "", usid = "",
                            version_base = "", version_current = "", sys_version = "", 
                            devices_id = "", log_time = "", function_name = "", error_stack = "",
                            error_code = "", section_id = ""}
            data.module = "error"
            if error_code then
                data.error_code = error_code
            else
                data.error_code = "lua"
            end
            data.game = GAME
            data.platform = PLATFORM
            if ModelManager then
                local userModel = ModelManager:getInstance():getModel("UserModel")
                data.uid = userModel:getUID()
                data.pid = userModel:getPID()
                data.usid = userModel:getUSID()
                log_time = userModel:getCurServerTime()
            end
            if data.uid == nil then
                data.uid = "unlogin"
                data.pid = "unlogin"
                data.usid = "unlogin"
            end

            data.version_base = tostring(version_base) .. "_" .. tostring(require "game.GameVersion")
            data.version_current = version_current

            data.sys_version = sys_version
            data.devices_id = DEVICE_ID
            data.log_time = log_time

            data.function_name = function_name
            data.error_stack = string.gsub(error_stack, "\'", "\"") -- 这里把单引号换成双引号, 否则会解析失败
            
            data.section_id = GameStatic.sec

            local str = json.encode(data)
            errorStrCache = errorStrCache .. str .. "\n"
            if not errorUpdateing then
                ApiUtils.playcrab_flesh_lua_error()
            end
        end)
    end
end
function ApiUtils.playcrab_flesh_lua_error()
    errorUpdateing = false
    if string.len(errorStrCache) > 0 then
        local _file = io.open(FILEPATH_UPLOAD_LUA_ERROR, "a")
        _file:write(errorStrCache)
        _file:close()
        errorStrCache = ""
        if FileUtils:getFileSize(FILEPATH_UPLOAD_LUA_ERROR) > MAX_SIZE_UPLOAD_LUA_ERROR then
            ApiUtils.playcrab_upload_lua_error()
        end  
    end
end
-- 上传并删除文件, 游戏登录之后上传一回, 之后每5K 上传一回
function ApiUtils.playcrab_upload_lua_error()
    if ENABLE_UPLOAD_LUA_ERROR and FileUtils:getFileSize(FILEPATH_UPLOAD_LUA_ERROR) > -1 then
        errorUpdateing = true
        netServer:registHttpEventHandler(function (_, state, msg) 
            -- msg {"data":[],"code":200,"message":1017}
            if msg == "null" then 
                ApiUtils.playcrab_flesh_lua_error()
                return 
            end
            local utf8Str = utf8.unicode_to_utf8(msg) 
            if string.find(utf8Str, "{") and string.find(utf8Str, "}") then
                local res
                if not pcall(function () res = json.decode(utf8Str) end) then
                    ApiUtils.playcrab_flesh_lua_error()
                    return
                end
                if res.code == 200 then
                    -- 成功
                    print("playcrab_upload_lua_error success! "..res.message)
                    FileUtils:removeFile(FILEPATH_UPLOAD_LUA_ERROR)
                else
                    print("playcrab_upload_lua_error error: "..res.code.."msg: "..res.message)
                end
            end
            ApiUtils.playcrab_flesh_lua_error()
        end)
        netServer:sendHttpUpload(FILEPATH_UPLOAD_LUA_ERROR, URL_UPLOAD_LUA_ERROR)
    end
end

--[[
    ======================================================================
        玩蟹科技出品
        客户端打点
    ======================================================================
--]]
local URL_UPLOAD_MONITOR = "http://api.war.client.playcrab.com/v1/upload/api/"
local FILEPATH_UPLOAD_MONITOR_EX = cc.FileUtils:getInstance():getWritablePath() .."game.monitor"
local FILEPATH_UPLOAD_MONITOR_COUNT = 1
local FILEPATH_UPLOAD_MONITOR = FILEPATH_UPLOAD_MONITOR_EX .. FILEPATH_UPLOAD_MONITOR_COUNT
local MAX_SIZE_UPLOAD_MONITOR = 0--512 -- 文件超过512 上传

-- 客户端打点记录
local function initdata_monitor()
    local sec
    if GameStatic then
        sec = GameStatic.sec
    else
        sec = ""
    end
    local time
    if ModelManager then
        time = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
        --时区校验
        if TimeUtils.serverTimezone then
            time = time - (TimeUtils.localTimezone - TimeUtils.serverTimezone)
        end
    else
        time = os.time()
    end
    return {device_id = DEVICE_ID, time = time, game = GAME,
            platform = PLATFORM, section = sec, channel = CHANNEL}
end

local function playcrab_monitor(data)
    local str = json.encode(data)
    local _file = io.open(FILEPATH_UPLOAD_MONITOR, "a")
    _file:write(str.."\n")
    _file:close()
end

-- 登录
function ApiUtils.playcrab_monitor_login()
    if not ENABLE_UPLOAD_MONITOR then return end
    local data = initdata_monitor()
    data.module = "login"
    if ModelManager then
        data.rid = ModelManager:getInstance():getModel("UserModel"):getRID() 
        data.vip = ModelManager:getInstance():getModel("VipModel"):getLevel() 
    end
    playcrab_monitor(data)
end

-- 充值
function ApiUtils.playcrab_monitor_recharge(cash)
    if not ENABLE_UPLOAD_MONITOR then return end
    local data = initdata_monitor()
    data.module = "cash"
    if ModelManager then
        data.rid = ModelManager:getInstance():getModel("UserModel"):getRID() 
    end
    data.cash = cash
    playcrab_monitor(data)
end

-- 设备打点, 只记录一次
function ApiUtils.playcrab_device_monitor_action(action)
    local has = ApiUtils.loadGlobalLocalData("deviceAction_"..action)
    if has == nil or has == "" then
        ApiUtils.saveGlobalLocalData("deviceAction_"..action, 1)
        ApiUtils.playcrab_monitor_action(action, true)
    end
end

-- action
function ApiUtils.playcrab_monitor_action(action, isDevice)
    local data = initdata_monitor()
    if ModelManager then
        data.rid = ModelManager:getInstance():getModel("UserModel"):getRID() 
    end
    if data.rid and not isDevice then
        data.module = "roleaction"
        -- print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%", action)
    else
        data.module = "action"
        -- print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$", action)
    end
    data.action = action
    if not ENABLE_UPLOAD_MONITOR then return end
    playcrab_monitor(data)
end

-- Vip升级
function ApiUtils.playcrab_monitor_vip_upgrade(old_vip, vip)
    if not ENABLE_UPLOAD_MONITOR then return end
    local data = initdata_monitor()
    data.module = "vip"
    if ModelManager then
        data.rid = ModelManager:getInstance():getModel("UserModel"):getRID() 
    end
    data.old_vip = old_vip
    data.vip = vip
    playcrab_monitor(data)
end

-- 上传打点记录
function ApiUtils.playcrab_upload_monitor(filename)
    if ENABLE_UPLOAD_MONITOR and GameStatic and GameStatic.playcrab_Monitor and FileUtils:getFileSize(filename) > -1 then
        netServer:registHttpEventHandler(function (_, state, msg) 
            if msg == "null" then return end
            local utf8Str = utf8.unicode_to_utf8(msg) 
            if string.find(utf8Str, "{") and string.find(utf8Str, "}") then
                local res
                if not pcall(function () res = json.decode(utf8Str) end) then
                    return
                end

                if res.code == 200 then
                    -- 成功
                    print("playcrab_upload_monitor success! "..res.message)
                    FileUtils:removeFile(filename)
                else
                    print("playcrab_upload_monitor error: "..res.code.."msg: "..res.message)
                end
            end
        end)
        netServer:sendHttpUpload(filename, URL_UPLOAD_MONITOR)
    end
end

--[[
    ======================================================================
        玩蟹科技出品
        lua报错上传
    ======================================================================
--]]
local URL_PROPOSAL = "http://proposal.web.playcrab.com/v1/question"
local PUBLIC_KEY_PROPOSAL = "4ca9d3dcd"
local PRIVATE_KEY_PROPOSAL = "1cc813118920ed48cd5aa1cd3159f318"
local function get_proposal_Authorization()
    local date = os.date("%Y-%m-%d %H:%M:%S", os.time())
    local md5 = PCTools:md5("PlayCrab"..PRIVATE_KEY_PROPOSAL..date)
    return "PLAYCRAB "..PUBLIC_KEY_PROPOSAL..":"..md5
end
-- 提交问题
function ApiUtils.playcrab_commit_question( param )
    if not ENABLE_PROPOSAL then return end
    if not ModelManager then return end
    param = param or {}
    local modelMgr = ModelManager:getInstance()
    local uid = tostring(modelMgr:getModel("UserModel"):getUID())
    if uid == nil then return end
    local req = cc.XMLHttpRequest:new()
    req.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    req:registerScriptHandler(function()
        if req.status == 200 then -- 成功
            print("playcrab_commit_question success!")
            if param.callback then 
                param.callback()
            end
        else
            print("playcrab_commit_question failed!", req.status, req.response, req.statusText)
        end
    end)
    req:open("post", URL_PROPOSAL)
    req:setRequestHeader("Authorization", get_proposal_Authorization())
    req:setRequestHeader("Date", os.date("%Y-%m-%d %H:%M:%S", os.time()))

    local data = 
    {
        pid = modelMgr:getModel("UserModel"):getPID(), 
        version = GameStatic.version,
        package_version = GameStatic.version,
        game = GAME,
        platform = PLATFORM,
        area_service = GameStatic.sec,
        vip = modelMgr:getModel("VipModel"):getData().level or 0,
        role = modelMgr:getModel("UserModel"):getData().name,
        title = "test",
        content = param.content or "test123",
        device = DEVICE_ID,
    }
    local msg = "uid=".. uid
    for k, v in pairs(data) do
        msg = msg .. "&" .. k .. "=" .. v
    end
    req:send(msg)

end

-- 获取问题反馈
function ApiUtils.playcrab_get_question_result(callback)
    if not ENABLE_PROPOSAL then return end
    if not ModelManager then return end
    local uid = tostring(ModelManager:getInstance():getModel("UserModel"):getUID())
    if uid == nil then return end
    local req = cc.XMLHttpRequest:new()
    req.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    req:registerScriptHandler(function()
        if req.status == 200 then -- 成功
            local str = req.response
            if string.find(str, "{") and string.find(str, "}") then
                local res
                if not pcall(function () res = json.decode(str) end) then
                    if callback then
                        callback()
                    end
                    return
                end
                if callback then
                    callback(res)
                end
            end
        else

        end
    end)
    req:open("get", URL_PROPOSAL.."?uid=".. uid.."&platform="..PLATFORM)
    req:setRequestHeader("Authorization", get_proposal_Authorization())
    req:setRequestHeader("Date", os.date("%Y-%m-%d %H:%M:%S", os.time()))
    req:send()
end

local updateID
function ApiUtils.init()
    updateID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        function ()
            ApiUtils.update()
        end, 
        10, false)
end

function ApiUtils.destroy()
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(updateID) 
end

function ApiUtils.update()
    -- 客户端打点 按时上传, 1分钟一次
    if ENABLE_UPLOAD_MONITOR and GameStatic and GameStatic.playcrab_Monitor then
        if FileUtils:getFileSize(FILEPATH_UPLOAD_MONITOR) > -1 then
            ApiUtils.playcrab_upload_monitor(FILEPATH_UPLOAD_MONITOR)
            FILEPATH_UPLOAD_MONITOR_COUNT = FILEPATH_UPLOAD_MONITOR_COUNT + 1
            if FILEPATH_UPLOAD_MONITOR_COUNT >= 3 then
                FILEPATH_UPLOAD_MONITOR_COUNT = 1
            end
            FILEPATH_UPLOAD_MONITOR = FILEPATH_UPLOAD_MONITOR_EX .. FILEPATH_UPLOAD_MONITOR_COUNT
        end
    end
end
--[[
    ======================================================================
        腾讯出品
        信鸽push
    ======================================================================
--]]
-- 设置本地通知
function ApiUtils.createLocalPush()

end

-- 删除本地通知
function ApiUtils.destroyLocalPush()

end

--[[
    ======================================================================
        腾讯出品
        gsdk
    ======================================================================
--]]
-- -- ApiUtils.gsdkSetEvent({tag = tag, status = status, msg = msg})
-- function ApiUtils.gsdkSetEvent(param)
--     if not GameStatic.useGsdk or not GameStatic.useGsdk_SetEvent then return end
--     if not OS_IS_ANDROID then return end
--     luabridge.callStaticMethod(className, "gsdkSetEvent", param)
-- end
-- -- ApiUtils.gsdkStart({zone_id = zone_id, tag = tag, room_ip = room_ip})
-- function ApiUtils.gsdkStart(param)
--     if not GameStatic.useGsdk or not GameStatic.useGsdk_Start_End then return end
--     if not OS_IS_ANDROID then return end
--     luabridge.callStaticMethod(className, "gsdkStart", param)
-- end
-- -- ApiUtils.gsdkEnd({})
-- function ApiUtils.gsdkEnd(param)
--     if not GameStatic.useGsdk or not GameStatic.useGsdk_Start_End then return end
--     if not OS_IS_ANDROID then return end
--     luabridge.callStaticMethod(className, "gsdkEnd", param)
-- end
-- -- ApiUtils.gsdkPay({tag = tag, status = status, msg = msg})
-- function ApiUtils.gsdkPay(param)
--     if not GameStatic.useGsdk or not GameStatic.useGsdk_Pay then return end
--     if not OS_IS_ANDROID then return end
--     luabridge.callStaticMethod(className, "gsdkPay", param)
-- end

--[[
    ======================================================================
        腾讯出品
        gsdk2.0
    ======================================================================
--]]
-- ApiUtils.gsdkSetEvent({tag = tag, status = status, msg = msg})
function ApiUtils.gsdkSetEvent(param)
    if OS_IS_ANDROID then
        if not GameStatic.useGsdk2_android or not GameStatic.useGsdk2_android_SetEvent then return end
    elseif OS_IS_IOS then
        if not GameStatic.useGsdk2_ios or not GameStatic.useGsdk2_ios_SetEvent then return end
    end
    if pc.PCTools.gsdkSetEvent then
        pc.PCTools:gsdkSetEvent(tonumber(param.tag), param.status == "true", param.msg)
    end
end
-- ApiUtils.gsdkStart({zone_id = zone_id, tag = tag, room_ip = room_ip})
function ApiUtils.gsdkStart(param)
    if OS_IS_ANDROID then
        if not GameStatic.useGsdk2_android or not GameStatic.useGsdk2_android_Start_End then return end
    elseif OS_IS_IOS then
        if not GameStatic.useGsdk2_ios or not GameStatic.useGsdk2_ios_Start_End then return end
    end
    if pc.PCTools.gsdkStart then
        pc.PCTools:gsdkStart(tonumber(param.zone_id), param.tag, param.room_ip)
    end
end
-- ApiUtils.gsdkEnd({})
function ApiUtils.gsdkEnd(param)
    if OS_IS_ANDROID then
        if not GameStatic.useGsdk2_android or not GameStatic.useGsdk2_android_Start_End then return end
    elseif OS_IS_IOS then
        if not GameStatic.useGsdk2_ios or not GameStatic.useGsdk2_ios_Start_End then return end
    end
    if pc.PCTools.gsdkEnd then
        pc.PCTools:gsdkEnd()
    end
end
-- ApiUtils.gsdkPay({tag = tag, status = status, msg = msg})
function ApiUtils.gsdkPay(param)

end
-- ApiUtils.gsdkPay({openId = openId})
function ApiUtils.gsdkSetUserName(param)
    if OS_IS_ANDROID then
        if not GameStatic.useGsdk2_android or not GameStatic.useGsdk2_android_User then return end
    elseif OS_IS_IOS then
        if not GameStatic.useGsdk2_ios or not GameStatic.useGsdk2_ios_User then return end
    end
    if pc.PCTools.gsdkSetUserName then
        local plat = 0
        if sdkMgr:isQQ() then
            plat = 2
        elseif sdkMgr:isWX() then
            plat = 1
        elseif sdkMgr:isGuest() then
            plat = 5
        end
        pc.PCTools:gsdkSetUserName(plat, param.openId)
    end
end

--[[
    ======================================================================
        不知道谁出品
        获取公网IP
    ======================================================================
--]]
local _publicIPCache_state = 0
local _publicIPCache_response = ""
local _canGetIPTick = 0
function ApiUtils.getPublicIP(callback)
    if GameStatic and socket.gettime() > _canGetIPTick then
        HttpManager:getInstance():simpleReq(GameStatic.useGetIP_url, GameStatic.useGetIP_timeout, 
        function (state, response)
            if callback then
                callback(state, response)
                _publicIPCache_state = state
                _publicIPCache_response = response
            end
        end)
        _canGetIPTick = socket.gettime() + 10
    else
        if callback then
            callback(_publicIPCache_state, _publicIPCache_response)
        end
    end
end

function ApiUtils.dtor()
    _publicIPCache_state = nil
    _publicIPCache_response = nil
    _canGetIPTick = nil
    updateID = nil
    ApiUtils = nil -- {}
    CHANNEL = nil -- "playcrab"
    CUR_PLATFORM = nil 
    CUR_PLATFORM_NAME = nil
    DEVICE_ID = nil 
    ENABLE_PROPOSAL = nil 
    ENABLE_UPLOAD_LUA_ERROR = nil 
    ENABLE_UPLOAD_MONITOR = nil
    errorMap = nil 
    FILEPATH_UPLOAD_LUA_ERROR = nil 
    FILEPATH_UPLOAD_MONITOR = nil 
    FileUtils = nil -- cc.FileUtils:getInstance()
    get_proposal_Authorization = nil
    initdata_monitor = nil
    playcrab_monitor = nil
    GAME = nil -- "war"
    last_lua_error_msg = nil -- ""
    luabridge = nil
    MAX_SIZE_UPLOAD_LUA_ERROR = nil 
    MAX_SIZE_UPLOAD_MONITOR = nil 
    netServer = nil 
    PCTools = nil 
    PLATFORM_NAMES = nil
    PRIVATE_KEY_PROPOSAL = nil
    PUBLIC_KEY_PROPOSAL = nil -- "4ca9d3dcd"
    URL_PROPOSAL = nil 
    URL_UPLOAD_LUA_ERROR = nil 
    URL_UPLOAD_MONITOR = nil 
    FILEPATH_UPLOAD_MONITOR_EX = nil
    version_base = nil
    version_current = nil
    sys_version = nil
    errorStrCache = nil
    errorUpdateing = nil
end

return ApiUtils

