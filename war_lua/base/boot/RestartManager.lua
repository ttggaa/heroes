--[[
    Filename:    RestartManager.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-05-07 15:35:07
    Description: File description
--]]

local RestartManager = class("RestartManager")
local _RestartManager = nil

local reqFunction = require

local DEFAULT_LANGUAGE = "cn"

function AppExit()
    APP_EXIT = true
    local scene = cc.Director:getInstance():getRunningScene()
    if scene then scene:setPosition(-10000, -10000) end
    if OS_IS_IOS then
        cc.Director:getInstance():endToLua()
        os.exit()
    else
        cc.Director:getInstance():endToLua()
    end
end

function AppStack()
    print(debug.traceback("a", 2))
end

-- 改写SpriteFrameCache的方法，来处理ui外挂包
local sfc = cc.SpriteFrameCache:getInstance()
local sfc_addSpriteFrames = sfc.addSpriteFrames
local find = string.find
local sub = string.sub
local len = string.len
local gsub = string.gsub
sfc.addSpriteFrames = function (_, plist, image)
    if plist == nil then return end
    if find(plist, "asset/ui") ~= nil then
        local filename = sub(image, 10, len(image))
        if UI_EX[filename] then
            local plistname = sub(plist, 10, len(plist)) 
            sfc_addSpriteFrames(_, UI_EX_PATH .. plistname, UI_EX_PATH .. filename)
        end
    end
    return sfc_addSpriteFrames(_, plist, image)
end

local tc = cc.Director:getInstance():getTextureCache()
local sfc_removeSpriteFramesFromFile = sfc.removeSpriteFramesFromFile
local tc_removeTextureForKey = tc.removeTextureForKey
sfc.removeSpriteFramesFromFile = function (_, plist)
    if plist == nil then return end
    sfc_removeSpriteFramesFromFile(_, plist)
    if find(plist, "asset/ui") ~= nil then
        local plistname = sub(plist, 10, len(plist))
        local filename = sub(plistname, 1, len(plistname) - 6)
        local filenamepng = filename .. ".png"
        local filenamejpg = filename .. ".jpg"
        if UI_EX[filenamepng] then
            tc_removeTextureForKey(tc, UI_EX_PATH .. filenamepng)
        end
        if UI_EX[filenamejpg] then
            tc_removeTextureForKey(tc, UI_EX_PATH .. filenamejpg)
        end
    end
end

function RestartManager:ctor()
    if OS_IS_WINDOWS then
        cc.Director:getInstance():getOpenGLView():setViewName("魔法门之英雄无敌：战争纪元")
    end
    require("base.boot.GlobalErrorCode")

    -- self.vmsUrl_planB
    -- self.globalUrl_planB

    -- 此为全局变量，不受热重启的管控
    GLOBAL_VALUES = {}
end

-- 设置语言版本
function RestartManager:setLanguage()
    -- 本地语言设置，切换的时候储存到本地，然后重启游戏即可
    local LANGUAGE = UserDefault:getStringForKey("global_LANGUAGE", "")
    if LANGUAGE == "" then
        LANGUAGE = nil
    end
    if LANGUAGE then
        GLOBAL_VALUES.LANGUAGE = LANGUAGE
    else
        GLOBAL_VALUES.LANGUAGE = DEFAULT_LANGUAGE
        UserDefault:setStringForKey("global_LANGUAGE", DEFAULT_LANGUAGE)
    end
    print("语言环境：", GLOBAL_VALUES.LANGUAGE)
    I18N = {}

    -- 载入cocosstudio、单图和代码种的语言表

    -- 翻译包在语言相对的路径下 ex:  asset/ui_cn/  asset/ui_zh/
    -- ui信息
    UI_EX = {}
    UI_EX_PATH = ""

    -- 单图信息
    SIM_EX = {}
    SIM_EX_PATH =  ""

    UI_FONT_EX = {}
    if GLOBAL_VALUES.LANGUAGE then
        pcall(function ()
            I18N = require("game.config.lang.I18N_" .. GLOBAL_VALUES.LANGUAGE)
        end)
        if #I18N == 0  and GLOBAL_VALUES.LANGUAGE ~= "cn" then 
            AppExit()
        end

        print("语言包==="..GLOBAL_VALUES.LANGUAGE)
        if cc.FileUtils:getInstance():isFileExist("asset/ui_" .. GLOBAL_VALUES.LANGUAGE .."/ui_ex.lua") then
            UI_EX = require ("asset/ui_" .. GLOBAL_VALUES.LANGUAGE .."/ui_ex")
        end
        UI_EX_PATH = "asset/ui_".. GLOBAL_VALUES.LANGUAGE .."/"

        if cc.FileUtils:getInstance():isFileExist("asset/sim_" .. GLOBAL_VALUES.LANGUAGE .."/sim_ex.lua") then
            SIM_EX = require ("asset/sim_" .. GLOBAL_VALUES.LANGUAGE .."/sim_ex")
        end
        SIM_EX_PATH = "asset/sim_".. GLOBAL_VALUES.LANGUAGE .."/"

        pcall(function ()
            UI_FONT_EX = require("game.config.lang.UIFont")
        end)
    end
end

function RestartManager:start()    

    -- 设置UI默认属性
    -- c++ 中默认的是static/title.ttf
    ccs.GUIReader:setButtonDefaultTitleFontName("static/common.ttf")
    ccs.GUIReader:setButtonDefaultTitleFontSize(22)

    -- 打补丁
    G_patchTab = {}

	self._mirrorTable1 = {}
    self._mirrorTable2 = {}

    self._tolua_value_root = {}
    self._toluafix_refid_function_mapping = {}
    self._toluafix_refid_ptr_mapping = {}
    self._toluafix_refid_type_mapping = {}

    self._Del_toluafix_refid_function_mapping = {}

    self._mirrorTable3 = {}

    -- dump(debug.getregistry())

    
    for k, v in pairs(_G) do
        self._mirrorTable1[k] = v
    end

    local _table
    local root = debug.getregistry()
    for k, v in pairs(root) do
        self._mirrorTable2[k] = v
        if type(v) == "table" and v.tolua_ubox then
            _table = {}
            for kk, vv in pairs(v.tolua_ubox) do
                _table[kk] = vv
            end
            self._mirrorTable3[k] = _table
        end
    end
    for k, v in pairs(root.tolua_value_root) do
        self._tolua_value_root[k] = v
    end
    for k, v in pairs(root.toluafix_refid_function_mapping) do
        self._toluafix_refid_function_mapping[k] = v
    end
    for k, v in pairs(root.toluafix_refid_ptr_mapping) do
        self._toluafix_refid_ptr_mapping[k] = v
    end
    for k, v in pairs(root.toluafix_refid_type_mapping) do
        self._toluafix_refid_type_mapping[k] = v
    end

    self._requireList = {}
    if OS_IS_64 then
        require = function (name)
            self._requireList[name .. "64"] = true
            local res = reqFunction(name)
            if G_patchTab[name] then     
                G_patchTab[name](res)
            end

            return res
        end
    else
        require = function (name)
            self._requireList[name] = true
            local res = reqFunction(name)
            if G_patchTab[name] then     
                G_patchTab[name](res)
            end

            return res
        end
    end
    self:setLanguage()
    self._oldprint = print
    self._olddump = dump
    local scene = cc.Scene:create()
    cc.Director:getInstance():runWithScene(scene)
	require("base.boot.LogoView").new(scene):show()
    ApiUtils.init()
end  

function RestartManager:restart()
    
    if OS_IS_WINDOWS then
        cc.Director:getInstance():getOpenGLView():setViewName("魔法门之英雄无敌：战争纪元")
    end
    GLOBAL_VALUES.last_restart_tick = os.time()
    -- pc.DisplayNodeFactory:getInstance():clearMCLibrary()
    GameStatic.showClickMc = true
    ApiUtils.destroy()
    -- cc.Director:getInstance():getScheduler():unscheduleAll()
	print = self._oldprint
	dump = self._olddump

    local root = _G

    for k, v in pairs(root) do
        if self._mirrorTable1[k] == nil then
            root[k] = nil
        end
    end

    local root = debug.getregistry()
    for k, v in pairs(root.tolua_value_root) do
        if self._tolua_value_root[k] == nil then
            root.tolua_value_root[k] = nil
        end
    end
    -- 延迟一帧卸载
    for k, v in pairs(root.toluafix_refid_function_mapping) do
        if self._toluafix_refid_function_mapping[k] == nil then
            self._Del_toluafix_refid_function_mapping[k] = true
            -- root.toluafix_refid_function_mapping[k] = nil
        end
    end
    for k, v in pairs(root.toluafix_refid_ptr_mapping) do
        if self._toluafix_refid_ptr_mapping[k] == nil then
            -- root.toluafix_refid_ptr_mapping[k] = nil
        end
    end
    for k, v in pairs(root.toluafix_refid_type_mapping) do
        if self._toluafix_refid_type_mapping[k] == nil then
            -- root.toluafix_refid_type_mapping[k] = nil
        end
    end

    local _root1, _root2
    for k, v in pairs(root) do
        if self._mirrorTable2[k] == nil then
            root[k] = nil
        end
        if self._mirrorTable3[k] then
            _root1 = root[k].tolua_ubox
            _root2 = self._mirrorTable3[k]
            for kk, vv in pairs(_root1) do
                if _root2[kk] == nil then
                    _root1[kk] = nil
                end
            end
        end
    end

    for k, v in pairs(self._requireList) do
        print(k)
        local req = package.loaded[k]
        if req and type(req) == "table" then 
            if req.dtor then req.dtor() end -- print(k, "dtor") end
            if req.dtor1 then req.dtor1() end -- print(k, "dtor1") end
            if req.dtor2 then req.dtor2() end -- print(k, "dtor2") end
            if req.dtor3 then req.dtor3() end -- print(k, "dtor3") end
            if not req.dtor and not req.dtor1 and not req.dtor2 and not req.dtor3 and string.find(k, "%.") then
                -- print("----"..k)
            end
        end
        package.loaded[k] = nil
    end
    self._requireList = {}

    collectgarbage("collect")
    collectgarbage("collect")
    collectgarbage("collect")

    -- dump(debug.getregistry())
    print("　")
    print("　")
    print("****************************************************")
    print("**　　　　　　　　　　重启游戏　　　　　　　　　　**")
    print("****************************************************")
    print("　")
    print("　")
    self:setLanguage()
    local scene = cc.Scene:create()
    cc.Director:getInstance():replaceScene(scene)
	require("base.boot.UpdateView").new(scene):show()
    ApiUtils.init()

    self._updateId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._updateId) 
        local root = debug.getregistry()
        for k, v in pairs(self._Del_toluafix_refid_function_mapping) do
            root.toluafix_refid_function_mapping[k] = nil
        end
        self._Del_toluafix_refid_function_mapping = {}
        collectgarbage("collect")
        collectgarbage("collect")
        collectgarbage("collect")
    end, 0.001, false)
end

function RestartManager:updateWindosTitle()
    if not OS_IS_WINDOWS then return end
    local UserModel = ModelManager:getInstance():getModel("UserModel")
    local data = UserModel:getData()
    local str = data.name 
    .. "  lv" .. data.lvl
    .. "  exp" .. data.exp .. "/" .. (tab:UserLevel(data.lvl).exp or 0)
    .. "  金" .. data.gold
    .. "  钻" .. data.gem --.. "(免" .. data.freeGem .. "充" .. data.payGem .. ")"
    .. "  " .. UserModel:getUID() 
    .. "  " .. UserModel:getUSID()
    .. "  " .. UserModel:getUUID()
    cc.Director:getInstance():getOpenGLView():setViewName(str)
end

return RestartManager