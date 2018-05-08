local value = SystemUtils.loadGlobalLocalData("uploadDEVICEINFO")
if value == nil then
    SystemUtils.saveGlobalLocalData("uploadDEVICEINFO", 1)
    local DEVICE_INFO = {model = "unknown", max_texture_size = 4096, etc1 = false, npot = false}
    pcall(function ()
        local openGLInfo = pc.PCTools:getOpenGLInfo()
        -- print(openGLInfo)
        local deviceInfo = ApiUtils.getDeviceInfo()

        -- 手机型号
        DEVICE_INFO.model = deviceInfo.model

        -- 最大纹理尺寸
        local pos = string.find(openGLInfo, "gl.max_texture_size:")
        if pos then
            if string.sub(openGLInfo, pos + 26, pos + 26) == "\n" then
                DEVICE_INFO.max_texture_size = tonumber(string.sub(openGLInfo, pos + 21, pos + 25))
            else
                DEVICE_INFO.max_texture_size = tonumber(string.sub(openGLInfo, pos + 21, pos + 26))
            end
        end

        -- ETC支持
        local pos = string.find(openGLInfo, "gl.supports_ETC1:")
        if pos then
            if string.sub(openGLInfo, pos + 22, pos + 22) == "\n" then
                DEVICE_INFO.etc1 = string.sub(openGLInfo, pos + 18, pos + 21) == "true"
            else
                DEVICE_INFO.etc1 = string.sub(openGLInfo, pos + 18, pos + 22) == "true"
            end
        end

        -- NPOT支持
        local pos = string.find(openGLInfo, "gl.supports_NPOT:")
        if pos then
            if string.sub(openGLInfo, pos + 22, pos + 22) == "\n" then
                DEVICE_INFO.npot = string.sub(openGLInfo, pos + 18, pos + 21) == "true"
            else
                DEVICE_INFO.npot = string.sub(openGLInfo, pos + 18, pos + 22) == "true"
            end
        end
        dump(DEVICE_INFO)
        -- 如果支持纹理小于4096，则上传设备信息
        if type(DEVICE_INFO.max_texture_size) == "number" and DEVICE_INFO.max_texture_size < 4096 then
            ApiUtils.playcrab_lua_error(DEVICE_INFO.model, openGLInfo, "deviceInfo")
        end
    end)
end