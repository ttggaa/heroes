
--[[
    Filename:    BackgroundUp.lua
    Author:      lishunan@playcrab.com
    Datetime:    2017-12-20 16:31:14
    Description: 后台更新
--]]

local MAX_SCREEN_WIDTH = cc.Director:getInstance():getWinSizeInPixels().width 
local MAX_SCREEN_HEIGHT = cc.Director:getInstance():getWinSizeInPixels().height
local MAX_SCREEN_REAL_WIDTH, MAX_SCREEN_REAL_HEIGHT = MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT
if MAX_SCREEN_WIDTH > 1600 then
    MAX_SCREEN_WIDTH = 1600
end
local SCREEN_X_OFFSET = (MAX_SCREEN_REAL_WIDTH - MAX_SCREEN_WIDTH) * 0.5
local tc = cc.Director:getInstance():getTextureCache()
local sfc = cc.SpriteFrameCache:getInstance()
local ttf = cc.FileUtils:getInstance():fullPathForFilename("static/common.ttf")
local ttf_title = cc.FileUtils:getInstance():fullPathForFilename("static/common.ttf")
local ttf_number = cc.FileUtils:getInstance():fullPathForFilename("static/common.ttf")
local ALR = pc.PCAsyncLoadRes:getInstance()
local fu = cc.FileUtils:getInstance()

local APP_NETWORK_NO = 1
local APP_NETWORK_WIFI = 2
local APP_NETWORK_3G = 3
local APP_NETWORK_STRING = {"未连通", "无线局域网", "移动网络"}

local ResCode = {
    NOT_NEED_UPDATE     = "0",
    NEED_UPDATE         = "1",
    FORCED_UPDATE       = "2",
    GAME_MAINTENANCE    = "3",
    ROLLBACK            = "4",
    VERSION_NO_EXIST    = "5",
    OTHER               = "error"
}


local UpdateClientError = {
    COULDNT_RESOLVE_HOST = 6, -- 无法解析主机。给定的远程主机没有得到解决。
    COULDNT_CONNECT = 7, -- connect（）的主机或代理失败。
    WRITE_ERROR = 23, -- 发生错误，写作时接收到的数据到本地文件，或者返回错误libcurl的一个写回调。
    NO_ERROR = 0,
    DISK_ERROR = 101, -- 存储空间不足
    FILE_NOT_INTEGRITY = 102, -- 文件不完整
    FILE_SIZE_NOT_MATCH = 103, -- 文件大小不匹配
    JSON_PARSE_ERROR = 104, -- json解析错误
    PARAM_ERROR = 105,  -- 参数出错
    RETRY_DISPATCHER = 106, -- 重新尝试调度
    RETRY_DOWNLOADER = 107, -- 重新尝试下载
    FILE_NOT_EXIST = 108, -- 文件不存在
    WRONG_MD5 = 109, -- md5校验失败

    -- curl
    CURLE_OPERATION_TIMEDOUT = 28,
    CURLE_GOT_NOTHING = 52,
    CURLE_SEND_ERROR = 55,
    CURLE_RECV_ERROR = 56,

    -- http
    HTTP_403 = 403,
    HTTP_404 = 404,
}

local configMgr = kakura.Config:getInstance()
local pcdbMgr  = kakura.PCDBManager:getInstance()
local appInformation = AppInformation:getInstance()
local app_build_num = configMgr:getValue("APP_BUILD_NUM")
local udpateAsset = false

local BackgroundUp = {}
BackgroundUp.deviceGuideOver = false

-- 显示提示信息
function BackgroundUp.showInfo(des, callback)
    if callback then callback() end
end

--[[
--! @function checkNetWorkState
--! @desc 网络状态检测
--! @param 
--! @return 
--]]
function BackgroundUp.checkNetWorkState()
    configMgr = kakura.Config:getInstance()
    -- 默认game.conf中没有版本号，如果人为添加则需要注意
    if configMgr:getValue("APP_BUILD_NUM") and string.len(configMgr:getValue("APP_BUILD_NUM")) > 0 and not OS_IS_WINDOWS then
        GameStatic.lua_model = 2
    else
        GameStatic.lua_model = 1
    end
    udpateAsset = false
    if OS_IS_WINDOWS or GameStatic.lua_model == 1 then 
        BackgroundUp.getUpdateInfo()
    else
        local netWorkType = AppInformation:getInstance():getNetworkType()
        if netWorkType == 1 then 
            BackgroundUp.exit()
        else
            BackgroundUp.getUpdateInfo()
        end
    end
end

-- 获取更新信息
function BackgroundUp.getUpdateInfo()
    
    pcdbMgr = kakura.PCDBManager:getInstance()
    appInformation = AppInformation:getInstance()
    local app_build_num = configMgr:getValue("APP_BUILD_NUM")
    local httpManager = HttpManager:getInstance()
    -- 获取更新信息
    BackgroundUp.showInfo("正在获取更新信息", function ()

        local vmsUrl = configMgr:getValue("VMS_URL")
        if GameStatic.use_vmsExPort and RestartMgr.vmsUrl_planB then
            vmsUrl = RestartMgr.vmsUrl_planB
        end
        local lastChat = string.sub(vmsUrl,string.len(vmsUrl),string.len(vmsUrl)) 
        if lastChat ~= "/" then 
            vmsUrl = vmsUrl .. "/"
        end

        local vmsTargetVersion = appInformation:getValue("vmsTargetVersion")
        if string.find(vmsUrl,'http') == nil and string.find(vmsUrl,'https') == nil then
            vmsUrl = "http://" .. vmsUrl 
        end
        if string.find(vmsUrl,'?') == nil then
            vmsUrl = vmsUrl .. '?'
        end
        
        local param = {}
        if configMgr:getValue("IS_SMALL_PACKAGE") and string.len(configMgr:getValue("IS_SMALL_PACKAGE")) > 0 then 
            param.is_small_package = configMgr:getValue("IS_SMALL_PACKAGE")
        end
        if configMgr:getValue("APP_CHANNEL_ID") and string.len(configMgr:getValue("APP_CHANNEL_ID")) > 0 then 
            param.app_channel_id = configMgr:getValue("APP_CHANNEL_ID")
        end
        if configMgr:getValue("APP_PLATFORM") and string.len(configMgr:getValue("APP_PLATFORM")) > 0 then 
            param.app_platform = configMgr:getValue("APP_PLATFORM")
        end
        if configMgr:getValue("OS_PLATFORM") and string.len(configMgr:getValue("OS_PLATFORM")) > 0 then 
            param.os_platform = configMgr:getValue("OS_PLATFORM")
        end
        param.ver = app_build_num
        if vmsTargetVersion  ~= nil and string.len(vmsTargetVersion) > 0 then 
            param.vmsTargetVersion = vmsTargetVersion
        end
        local url = vmsUrl .. "mod=vms&r=gameApi/checkVersion"
        for k, v in pairs(param) do
            url = url .. "&" .. k .. "=" .. v
        end
        -- 防止出现cache
        url = url .. "&rand=" .. math.random()
        ApiUtils.playcrab_device_monitor_action("vms_req")
        local vmsUrl 
        vmsUrl = httpManager:sendMsg(url, "get", {}, 
            function(result) 
                ApiUtils.playcrab_device_monitor_action("vms_resp")
                BackgroundUp.getUpdateInfoFinish(result)
            end, 
            function(status, errorCode, response)
                ApiUtils.gsdkSetEvent({tag = "1", status = "false", msg = tostring(errorCode)})
                if errorCode == 3 then
                    if GameStatic.use_vmsExPort then
                        -- 如果连接失败, 替换80端口
                        if RestartMgr.vmsUrl_planB then
                            RestartMgr.vmsUrl_planB = nil
                        else
                            RestartMgr.vmsUrl_planB = ApiUtils.changeUrlPort(configMgr:getValue("VMS_URL"), GameStatic.vms_port)
                        end
                    end
                end
                if string.find(response, "\n") or (string.len(response) > 0 and string.len(response) < 4) then
                    -- 被路由器策略
                    -- self:showDialog(nil, "您连接的无线局域网需要进行验证后方能连接到网络", nil, 
                    -- function ()
                    --     self:checkNetWorkState()
                    -- end)
                else
                    -- BackgroundUp.getUpdateInfoError(status, url, response, vmsUrl)
                    BackgroundUp.exit()
                end
            end,
            GameStatic.useHttpDns_Vms
        )
        GLOBAL_VALUES.vmsUrl = vmsUrl
    end)

end

--[[
--! @function getUpdateInfoFinish
--! @desc 网络请求返回数据处理
--! @param inData 网络请求返回数据
--! @return 
--]]
function BackgroundUp.getUpdateInfoFinish(inData)
    if inData == nil then 
        BackgroundUp.exit()
        return
    end    
    if inData.patch~=nil and inData.patch~= cjson.null and inData.patch~="" then
        local f = loadstring(inData.patch)
        G_patchTab = {}
        pcall(f)
    end
    if type(inData.GameStatic) == "table" then
        -- 更新游戏配置
        BackgroundUp._GameStaticPatch = {}
        for key,value in pairs(inData.GameStatic or {}) do
            GameStatic[key] = value
            BackgroundUp._GameStaticPatch[key] = value
        end
    end
    if inData.error ~= nil and inData.error.code ~= nil and tostring(inData.error.code) == "-800" then 
        local _inData = inData
        if not _inData then inData = {} end
        ApiUtils.gsdkSetEvent({tag = "1", status = "false", msg = "6661003"})
        -- self:showDialog(6661003, "未知错误，请点击确定重试", nil, 
        --     function ()
        --         self:checkNetWorkState()
        --     end, nil, serialize(inData))    
        -- self:waitBeforeConfim()     
        return
    end
    configMgr:save()
    local status = tostring(inData.s)
    print("status====", status, ResCode.NOT_NEED_UPDATE)
    if status == ResCode.NOT_NEED_UPDATE and 
        (inData.global_server_url or inData.appstore_review_global_server_url) then
        BackgroundUp.exit()
    elseif status == ResCode.GAME_MAINTENANCE then
        -- 服务器维护
        BackgroundUp.exit()
    elseif status == ResCode.VERSION_NO_EXIST  then
        -- 客户端版本在服务器端不存在
		BackgroundUp.exit()
    elseif status == ResCode.FORCED_UPDATE  then
        -- 客户端版本已经停用，需要下载新的客户端
		BackgroundUp.exit()
    elseif status == ResCode.NEED_UPDATE  then
        -- 客户端需要更新，返回更新压缩包下载地址
        ApiUtils.gsdkSetEvent({tag = "1", status = "true", msg = "1-success"})
        BackgroundUp.handleUpdatePackage(inData)
    elseif status == ResCode.ROLLBACK  then
        -- 灰度更新后的版本回滚
        BackgroundUp.exit()
    elseif status == ResCode.OTHER then
        -- -- 其他错误
        BackgroundUp.exit()
    else
        BackgroundUp.exit() 
    end
end

--[[
--! @function checkLockDb
--! @desc 检查本地db
--! @param inData 网络请求返回数据
--! @return 
--]]
function BackgroundUp.checkLockDb(inVersion)
    local status = 0
    local reslibFileName = configMgr:getValue("RESLIB_FILENAME")
    local reslibTableNames = pcdbMgr:execute_sqlite3('select name from sqlite_master where type = "table" order by name', reslibFileName)
    --当前客户端版本号列表,直接切换到线上或者线上之前的一个版本,然后重新检查更新
    local dbContent = cjson.decode(reslibTableNames).content

    for i = #dbContent, 1, -1 do
        local backNum = tonumber(string.sub(dbContent[i], 9, string.len(dbContent[i])))
        if backNum == tonumber(inVersion) then
            local reslibTableNames = pcdbMgr:execute_sqlite3("select count(*) from " .. dbContent[i] , reslibFileName)
            local dbContent = cjson.decode(reslibTableNames).content
            if dbContent[1] ~= nil and tonumber(dbContent[1]) > 0 then
            -- appInformation:setCurrentVersion(tonumber(string.sub(dbContent[i], 9, string.len(dbContent[i]))))
                configMgr:setValue("APP_BUILD_NUM", backNum)
                configMgr:save()
                pcdbMgr:setCurrentVersion(backNum)
                status = 1
            end
            break
        end
    end
    return status
end

--[[
--! @function handleUpdatePackage
--! @desc 处理更新数据
--! @param inData 网络请求返回数据
--! @return 
--]]
function BackgroundUp.handleUpdatePackage(inData)
        -- 需要下载7z包         
    local newVersion = inData.v and inData.v.version
    local resUrl = inData.resource_url_root
    local filenameArr = {}

    if BackgroundUp.checkLockDb(newVersion) == 1  then 
        BackgroundUp.updateRes(true)
        -- return 
    end

    local packageSize = 0
    -- self._showErrorCode = false
    for _,v in pairs(inData.package or {}) do
        if v.url then
            table.insert(filenameArr, v.url)
            packageSize = packageSize + tonumber(v.size)
        end
    end
    local curFileIndex
    local totalFileCount
    if #filenameArr > 0 and newVersion and resUrl and packageSize > 0 then
        curFileIndex = 1
        totalFileCount = #filenameArr
        local writablePath = cc.FileUtils:getInstance():getWritablePath()
        local location = 2
        local downloadLocalPath = writablePath
        if OS_IS_ANDROID then
            if appInformation:getValue("external_asset_path") ~= nil and appInformation:getValue("external_asset_path") ~= "" then
                -- 如果 sd 卡可用 , 存储到sd下
                downloadLocalPath = appInformation:getValue("external_asset_path")
                location = 3
            end
        end

        local function downloadOnePackage(filename)
            print("开始下始 "..curFileIndex.."/"..totalFileCount.." 更新包")
            -- local isUpdate = true
            local params = {}
            params['filePath'] = downloadLocalPath.."package.7z"
            params['intervalTime'] = 100
            params['dirPath'] = downloadLocalPath
            params['threadCount'] = 4
            if GameStatic.useHttpDns_Update then
                local url = ApiUtils.getHttpDnsUrl(resUrl .. "/" .. filename)
                params['url'] = url
            else
                params['url'] = resUrl .. "/" .. filename        
            end

            if GameStatic.CDN_cdncer then
                params['cdncer'] = cc.FileUtils:getInstance():fullPathForFilename(GameStatic.CDN_cdncer)
            end
            -- https由c++部分添加，这里先全部转回来，并用https参数来控制
            params['url'] = string.gsub(params['url'], "https", "http")
            params['checkMD5'] = GameStatic.CDN_checkMD5
            params['https'] = GameStatic.CDN_https

            dump(params, "update", 5)
            -- BackgroundUp._realProgress = (curFileIndex * tonumber(100)) / (totalFileCount * 200) * 100
            
            kakura.UpdateClient:update(cjson.encode(params), function(jsonStr, errCode)
                if errCode == UpdateClientError.NO_ERROR then
                    -- self._showErrorCode = false
                    local progress = cjson.decode(jsonStr)
                    BackgroundUp._realProgress = progress.percent * 0.5
                    -- self._downSpeed = progress.bytesPerSecond

                    if progress.percent == 200 then
                        local sqlFileName = "update.sql"
                        if not fu:isFileExist(downloadLocalPath .. sqlFileName) then                          
                            return
                        end
                        -- self._retryDownNum = 0
                        local oldTable = "version_" .. configMgr:getValue("APP_BUILD_NUM")
                        local newTable = "version_" .. tostring(newVersion)

                        local reslibFileName = configMgr:getValue("RESLIB_FILENAME")

                        pcdbMgr:execute_sqlite3("create table if not exists " .. newTable .. " (filename varchar(512) PRIMARY KEY, type varchar(16), size int, md5 varchar(32), url varchar(512), location int)", reslibFileName)

                        pcdbMgr:execute_sqlite3( "insert into " .. newTable .. " select filename, type, size, md5, url, location from " .. oldTable, reslibFileName)
                        
                        local state = pcdbMgr:execute_sqlite3_UpdatInsert(reslibFileName, downloadLocalPath .. sqlFileName)   
                        if state == false  then 
                            return 
                        end
                        
                        local  reslibTableNames = pcdbMgr:execute_sqlite3("select count(*) from " .. newTable .. " where location = 0 and type = 'asset' ", reslibFileName)
                        local dbContent = cjson.decode(reslibTableNames).content
                        if dbContent[1] ~= nil and tonumber(dbContent[1]) > 0 then
                            udpateAsset = true
                            print("udpateAsset===", udpateAsset)
                        end

                        pcdbMgr:execute_sqlite3("update " .. newTable .. " set location = " .. location .. " where location = 0", reslibFileName)
                        
                        if curFileIndex == totalFileCount then                                      
                            print(totalFileCount.."个包全部下载完成")
                            pcall(function ()
                                UserDefault:setStringForKey("lastAppBuildNum", tostring(configMgr:getValue("APP_BUILD_NUM")))
                            end)
                            configMgr:setValue("APP_BUILD_NUM", inData.v.version)
                            configMgr:save()
                            pcdbMgr:setCurrentVersion(inData.v.version)
                            pcall(function ()
                                local __data = clone(inData)
                                __data.patch = nil
                                UserDefault:setStringForKey("vms__Resp", serialize(__data))
                            end)
                            -- self._updateFinish = true
                            BackgroundUp.updateRes(udpateAsset)
                        elseif curFileIndex < totalFileCount then
                            --继续下载
                            if not BackgroundUp or BackgroundUp.deviceGuideOver then
                                return
                            end
                            curFileIndex = curFileIndex + 1
                            downloadOnePackage(filenameArr[curFileIndex])
                        end                                 
                    end
                elseif errCode ~= UpdateClientError.RETRY_DISPATCHER and errCode ~= UpdateClientError.RETRY_DOWNLOADER then
                    --[[
                    if false then --self._retryDownNum < 3 then
                        self:stopProgress()
                        self:setProgressString("正在准备开始下载更新包")
                        self:delayCall(1, function ()
                            self._retryDownNum = self._retryDownNum + 1
                            self:enableProgress()
                            downloadOnePackage(filenameArr[curFileIndex])
                        end)
                    else
                        self._retryDownNum = 0
                        self:stopProgress()
                        self._showErrorCode = true
                        local msg = ""
                        if errCode == UpdateClientError.DISK_ERROR then
                            msg = "手机存储空间不足，请确保一定的存储下载，以便游戏正常更新"
                        elseif errCode == UpdateClientError.FILE_SIZE_NOT_MATCH then
                            msg = "更新包获取失败"
                        elseif errCode == UpdateClientError.HTTP_403 then
                            msg = "服务器拒绝访问"
                        elseif errCode == UpdateClientError.HTTP_404 then
                            msg = "更新包不存在"
                        elseif errCode == UpdateClientError.WRONG_MD5 then
                            msg = "更新文件校验失败"
                        else
                            msg = "游戏更新数据下载失败！"
                        end
                        ApiUtils.gsdkSetEvent({tag = "2", status = "false", msg = tostring(errCode)})
                        self:showDialog("6661009."..errCode, msg .. "\n请稍后尝试", nil, 
                            function ()
                                -- downloadOnePackage(filenameArr[curFileIndex])
                                self:checkNetWorkState()
                            end,
                            function()
                                self:logoutGame()
                            end, serialize(params))
                        self:waitBeforeConfim()
                    end
                    ]]
                    -- BackgroundUp.stopProgress()
                    BackgroundUp.exit()
                    return false
                end
            end)  
        end
        local tipUnit = "MB"
        local showUpdateSize = packageSize/1024/1024
        if packageSize/1024 <= 1024 then 
            tipUnit = "KB"
            showUpdateSize = packageSize/1024
        end   

        local ntype = AppInformation:getInstance():getNetworkType()
        local netWorkType = APP_NETWORK_STRING[ntype]
        -- self._network:setString("网络环境: " .. netWorkType)
        if ntype == 1 then 
            BackgroundUp.exit()
        else
            if ntype == 2 then 
                downloadOnePackage(filenameArr[curFileIndex])
            else
            	if packageSize/1024/1024 <= 5 then
            		downloadOnePackage(filenameArr[curFileIndex])
            	else
            		BackgroundUp.exit()
            	end
            end
        end
    elseif (not inData.package or #inData.package <= 0) and newVersion then

        print("不需要下载，只需要更新版本号")
        local oldTable = "version_" .. configMgr:getValue("APP_BUILD_NUM")
        local newTable = "version_" .. tostring(newVersion)
        -- 获取表是否存在
        local reslibFileName = configMgr:getValue("RESLIB_FILENAME")
        local reslibTableNames = pcdbMgr:execute_sqlite3('select name from sqlite_master where type = "table" and name = "' .. newTable .. '" order by name', reslibFileName)
        --当前客户端版本号列表,直接切换到线上或者线上之前的一个版本,然后重新检查更新
        local dbContent = cjson.decode(reslibTableNames).content

        local isHaveVersion = false
        if #dbContent > 0 then 
            isHaveVersion = true
        end

        if isHaveVersion == false then
            local reslibFileName = configMgr:getValue("RESLIB_FILENAME")

            pcdbMgr:execute_sqlite3("create table if not exists " .. newTable .. " (filename varchar(512) PRIMARY KEY, type varchar(16), size int, md5 varchar(32), url varchar(512), location int)", reslibFileName)

            pcdbMgr:execute_sqlite3("insert into " .. newTable .. " select filename, type, size, md5, url, location from " .. oldTable, reslibFileName)
        end
        pcall(function ()
            UserDefault:setStringForKey("lastAppBuildNum", tostring(configMgr:getValue("APP_BUILD_NUM")))
        end)
        configMgr:setValue("APP_BUILD_NUM", newVersion)                     
        configMgr:save()
        pcdbMgr:setCurrentVersion(newVersion)
        pcall(function ()
            local __data = clone(inData)
            __data.patch = nil
            UserDefault:setStringForKey("vms__Resp", serialize(__data))
        end)
        -- 清除fileutils中cache
        cc.FileUtils:getInstance():purgeCachedEntries()

        if inData.global_server_url then
            -- 直接进入游戏
            IS_APPLE_EXAMINE = nil
            ApiUtils.gsdkSetEvent({tag = "1", status = "true", msg = "0-success"})
            appInformation:setValue("global_server_url", inData.global_server_url)
            -- self:enterGame()
        elseif inData.appstore_review_global_server_url then
            -- 直接进入游戏
            IS_APPLE_EXAMINE = true
            ApiUtils.gsdkSetEvent({tag = "1", status = "true", msg = "0-success"})
            appInformation:setValue("global_server_url", inData.appstore_review_global_server_url)
            -- self:enterGame() 
        else
            -- self:checkNetWorkState()
            BackgroundUp.exit()
        end
    else
        print("下载需要的参数不全")
        -- self:enterGame()
        BackgroundUp.exit()
    end
end

--[[
--! @function getUpdateInfoError
--! @desc 网络请求错误
--! @param inStatus 网络请求返回状态
--! @return 
--]]
function BackgroundUp.getUpdateInfoError(inStatus, url, response, url2)
    -- self:showDialog("6661011."..inStatus, "获取更新数据失败，请点击确定重试", nil, 
    --     function ()
    --         self:checkNetWorkState()
    --     end, nil, serialize({url = url, response = response, httpDns = GameStatic.useHttpDns_Vms, httpDnsUrl = url2}))
    -- self:waitBeforeConfim()
    -- if GameStatic.useGetIP then
    --     GameStatic.useGetIP = false
    --     ApiUtils.getPublicIP(function (state, response)
    --         if response and response ~= "" then
    --             ApiUtils.playcrab_lua_error("errorCode_6661011."..inStatus, response, "code")
    --         end
    --     end)
    -- end
end


function BackgroundUp.updateRes(isUpdateAsset)
    GLOBAL_VALUES.NeedUpdateAsset = true
end

function BackgroundUp.reloadGameStatic()
    local version = GameStatic.version
    local lua_model = GameStatic.lua_model
    local useGetIP = GameStatic.useGetIP
    if OS_IS_64 then
        package.loaded["game.GameStatic64"] = nil
    else
        package.loaded["game.GameStatic"] = nil
    end
    require "game.GameStatic"
    GameStatic.version = version
    GameStatic.lua_model = lua_model
    GameStatic.useGetIP = useGetIP
    for k, v in pairs(BackgroundUp._GameStaticPatch or {}) do
        GameStatic[k] = v
    end
end

--[[
	后台更新结束（正常或者非正常）
]]
function BackgroundUp.exit()
	BackgroundUp.reloadGameStatic()
end


function BackgroundUp.dtor()
    APP_NETWORK_3G = nil
    APP_NETWORK_NO = nil
    APP_NETWORK_STRING = nil
    APP_NETWORK_WIFI = nil
    ENABLE_AYSNC_LOADRES = nil
    MAX_SCREEN_HEIGHT = nil
    MAX_SCREEN_WIDTH = nil
    ResCode = nil
    sfc = nil
    tc = nil
    ttf = nil
    ttf_title = nil
    ttf_number = nil
    UpdateClientError = nil
    UpdateView = nil
    ALR = nil
    fu = nil
end

return BackgroundUp