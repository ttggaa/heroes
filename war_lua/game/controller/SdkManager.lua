--[[
    Filename:    SdkManager.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-06-17 15:16:33
    Description: File description
--]]


local SdkManager = class("SdkManager")

local _sdkManager = nil
SdkManager.SDK_STATE = {
    SDK_INIT_SUCCESS = 0,
    SDK_INIT_FAIL = 1,
    
    SDK_LOGIN_SUCCESS = 2,
    SDK_LOGIN_FAIL = 3,
    SDK_LOGIN_CANCEL = 4,
    
    SDK_LOGOUT_SUCCESS = 5, 
    SDK_LOGOUT_FAIL = 6,
    SDK_LOGOUT_CANCEL = 7,
    
    SDK_CHARGE_SUCCESS = 8,
    SDK_CHARGE_FAIL = 9,
    SDK_CHARGE_CANCEL = 10,
    SDK_CHARGE_FORBIDDEN = 11,
    
    SDK_SWITCH_USER_SUCCESS = 12,
    SDK_SWITCH_USER_FAIL = 13,
    
    SDK_SHARE_SUCCESS = 14,
    SDK_SHARE_FAIL = 15,
    SDK_SHARE_CANCEL = 16,

    SDK_NEED_LOGIN = 1001,
    SDK_QUERY_SUCCESS = 1002,
    SDK_SEND_SECURITY = 1003,

    SDK_OTHER_ERROR = 99,

    SDK_GROUP_CREATE = 1004,
    SDK_GROUP_JOIN_SUCCESS = 1005,
    SDK_GROUP_JOIN_FAIL = 1006,

    SDK_GROUP_QUERY_SUCCESS = 1007,

    SDK_GROUP_QUERY_FAIL = 1008,

    SDK_GROUP_UNBIND_SUCCESS = 1009,
    SDK_GROUP_UNBIND_FAIL = 1010,

    -- 客户端拉起分类
    SDK_WAKEUP_DATA = 1011,

    -- 语音相关
    VOICE_UP_SUCCESS = 2001,
    VOICE_UP_FAIL = 2002,
    VOICE_DOWN_SUCCESS = 2003,
    VOICE_DOWN_FAIL = 2004,
    VOICE_PLAY_SUCCESS = 2005,
    VOICE_PLAY_FAIL = 2006,
    VOICE_APPLY_KEY_SUCCESS = 2007,
    VOICE_APPLY_KEY_FAIL = 2008,
    VOICE_STT_SUCCESS = 2009,
    VOICE_STT_FAIL = 2010,

    VOICE_JOIN_SUCCESS = 2011,
    VOICE_JOIN_FAIL    = 2012,
    VOICE_QUIT_SUCCESS = 2013,
    VOICE_QUIT_FAIL    = 2014,
    VOICE_MEM_VOICE    = 2015,
    
    GFM_JOIN_SUCCESS = 3001,
    GFM_JOIN_FAIL    = 3002,
    GFM_QUIT_SUCCESS = 3003,
    GFM_QUIT_FAIL    = 3004,

}

-- kGroupStatus = {
--     CAN_BIND          = 1,--可以绑定群组
--     CAN_JOIN          = 2,--可以加入群组
--     IN_GROUP          = 3,--在群中
--     CAN_REMOVEBIND    = 4,--可以解绑群组
--     REFRESH           = 5,--刷新群组状态
--     REFRESHING        = 6,--刷新群组状态中
--     INEXISTENCE_GROUP = 7,--不存在群
-- }

SdkManager.SDK_EVENT_TYPE = {
    TYPE_INIT = {
        SdkManager.SDK_STATE.SDK_INIT_SUCCESS, 
        SdkManager.SDK_STATE.SDK_INIT_FAIL,
    },

    TYPE_LOGIN = {
        SdkManager.SDK_STATE.SDK_LOGIN_SUCCESS, 
        SdkManager.SDK_STATE.SDK_LOGIN_FAIL, 
        SdkManager.SDK_STATE.SDK_LOGIN_CANCEL
    },

    TYPE_LOGOUT = {
        SdkManager.SDK_STATE.SDK_LOGOUT_SUCCESS, 
        SdkManager.SDK_STATE.SDK_LOGOUT_FAIL, 
        SdkManager.SDK_STATE.SDK_LOGOUT_CANCEL
    },

    TYPE_CHARGE = {
        SdkManager.SDK_STATE.SDK_CHARGE_SUCCESS, 
        SdkManager.SDK_STATE.SDK_CHARGE_FAIL, 
        SdkManager.SDK_STATE.SDK_CHARGE_CANCEL, 
        SdkManager.SDK_STATE.SDK_CHARGE_FORBIDDEN,
    },

    TYPE_SWITCH_USER = {
        SdkManager.SDK_STATE.SDK_SWITCH_USER_SUCCESS, 
        SdkManager.SDK_STATE.SDK_SWITCH_USER_FAIL
    },


    TYPE_SHARE = {
        SdkManager.SDK_STATE.SDK_SHARE_SUCCESS, 
        SdkManager.SDK_STATE.SDK_SHARE_FAIL,
        SdkManager.SDK_STATE.SDK_SHARE_CANCEL,
    },
    TYPE_GROUP = {
        SdkManager.SDK_STATE.SDK_GROUP_CREATE,
        SdkManager.SDK_STATE.SDK_GROUP_JOIN_SUCCESS,
        SdkManager.SDK_STATE.SDK_GROUP_JOIN_FAIL,
        SdkManager.SDK_STATE.SDK_GROUP_QUERY_SUCCESS,
        SdkManager.SDK_STATE.SDK_GROUP_QUERY_FAIL,
    },

    TYPE_NEED_LOGIN = {SdkManager.SDK_STATE.SDK_NEED_LOGIN},

    TYPE_QUERY_SUCCESS = {SdkManager.SDK_STATE.SDK_QUERY_SUCCESS},

    TYPE_SEND_SECURITY = {SdkManager.SDK_STATE.SDK_SEND_SECURITY},

    TYPE_OTHER_ERROR = {SdkManager.SDK_STATE.SDK_OTHER_ERROR},

    TYPE_GVOICE_UP = {
        SdkManager.SDK_STATE.VOICE_UP_SUCCESS,
        SdkManager.SDK_STATE.VOICE_UP_FAIL,
    },
    TYPE_GVOICE_DOWN = {
        SdkManager.SDK_STATE.VOICE_DOWN_SUCCESS,
        SdkManager.SDK_STATE.VOICE_DOWN_FAIL,
    },
    TYPE_GVOICE_PLAY = {
        SdkManager.SDK_STATE.VOICE_PLAY_SUCCESS,
        SdkManager.SDK_STATE.VOICE_PLAY_FAIL,
    },
    TYPE_GVOICE_APPLY = {
        SdkManager.SDK_STATE.VOICE_APPLY_KEY_SUCCESS,
        SdkManager.SDK_STATE.VOICE_APPLY_KEY_FAIL,
    },
    TYPE_GVOICE_STT = {
        SdkManager.SDK_STATE.VOICE_STT_SUCCESS,
        SdkManager.SDK_STATE.VOICE_STT_FAIL,
    },  
    TYPE_GVOICE_JOIN = {
        SdkManager.SDK_STATE.VOICE_JOIN_SUCCESS,
        SdkManager.SDK_STATE.VOICE_JOIN_FAIL,
    },  
    TYPE_GVOICE_QUIT = {
        SdkManager.SDK_STATE.VOICE_QUIT_SUCCESS,
        SdkManager.SDK_STATE.VOICE_QUIT_FAIL,
    },  
    TYPE_GVOICE_ROOM = {
        SdkManager.SDK_STATE.VOICE_MEM_VOICE,
    },
    TYPE_GFM_JOIN = {
        SdkManager.SDK_STATE.GFM_JOIN_SUCCESS,
        SdkManager.SDK_STATE.GFM_JOIN_FAIL,
    },  
    TYPE_GFM_QUIT = {
        SdkManager.SDK_STATE.GFM_QUIT_SUCCESS,
        SdkManager.SDK_STATE.GFM_QUIT_FAIL,
    },  

}

SdkManager.SHARE_TAG = {
    MSG_INVITE = "MSG_INVITE",                   -- 邀请
    MSG_SHARE_MOMENT_HIGH_SCORE = "MSG_SHARE_MOMENT_HIGH_SCORE",  --分享本周最高到朋友圈
    MSG_SHARE_MOMENT_BEST_SCORE = "MSG_SHARE_MOMENT_BEST_SCORE",  --分享历史最高到朋友圈
    MSG_SHARE_MOMENT_CROWN = "MSG_SHARE_MOMENT_CROWN",       --分享金冠到朋友圈
    MSG_SHARE_FRIEND_HIGH_SCORE = "MSG_SHARE_FRIEND_HIGH_SCORE",  --分享本周最高给好友
    MSG_SHARE_FRIEND_BEST_SCORE = "MSG_SHARE_FRIEND_BEST_SCORE",  --分享历史最高给好友
    MSG_SHARE_FRIEND_CROWN = "MSG_SHARE_FRIEND_CROWN",       --分享金冠给好友
    MSG_FRIEND_EXCEED = "MSG_FRIEND_EXCEED",             -- 超越炫耀
    MSG_HEART_SEND = "MSG_HEART_SEND",                -- 送心
    MSG_SHARE_FRIEND_PVP = "MSG_SHARE_FRIEND_PVP",    -- PVP对战
    MSG_SHOW = "MSG_SHOW",    -- 炫耀
    MSG_INVITE_NEW = "MSG_INVITE_NEW"                   -- 推广员邀请好友
}

SdkManager.SHARE_QQ_TAG = {
    MSG_INVITE = "gameobj.msg_invite",
    MSG_FRIEND_EXCEED = "gameobj.msg_exceed",
    MSG_HEART_SEND = "gameobj.msg_heart",
    MSG_SHARE_FRIEND_PVP = "gameobj.msg_pvp",
    MSG_SHOW = "gameobj.msg_show",
    MSG_INVITE_NEW = "gameobj.msg_invite" 
}

function SdkManager:getInstance()
    if _sdkManager == nil  then 
        _sdkManager = SdkManager.new()
        _sdkManager:init()
    end
    return _sdkManager
end

function SdkCallback(code, data)
    SdkManager:getInstance():sdkCallback(code, data)
end

function SdkManager:sdkCallback(code, data)
    xpcall(function ()
        if code == SdkManager.SDK_STATE.SDK_NEED_LOGIN then
            ViewManager:getInstance():sdk_need_login(data)
            return
        end
    
        local callback = self._callBack[tonumber(code)]
        if callback and type(callback) == "function" then
            self:private_unregisterCallbackAfterTrigger(code)
            callback(tonumber(code), data)

        end
    end, __G__TRACKBACK__)
end

function SdkManager:NoSdkCallback(code)
    print("Error:You should *NEVER* get here, error code:", code)
    if code == SdkManager.SDK_STATE.SDK_LOGOUT_SUCCESS then
        ViewManager:getInstance():restart()
        return
    end
end

function SdkManager:otherErrorCallback(code)
    print("SdkManager:otherErrorCallback, error code:", code)
end

function SdkManager:wakeUpCallback(code, inResult)
    if code == SdkManager.SDK_STATE.SDK_WAKEUP_DATA then
        local result = json.decode(inResult)
        WakeUpUtils.wakeUpCallback(string.urldecode(result.ext_data))
        print("SdkManager:wakeUpCallback, code:", code)
    end
end

function SdkManager:initCallback()
    self._callBack = {}
    for _, state in pairs(SdkManager.SDK_STATE) do
        self._callBack[tonumber(state)] = handler(self, self.NoSdkCallback)
    end
    self._callBack[tonumber(SdkManager.SDK_STATE.SDK_OTHER_ERROR)] = handler(self, self.otherErrorCallback)

    -- 客户端你拉起回调
    self._callBack[tonumber(SdkManager.SDK_STATE.SDK_WAKEUP_DATA)] = handler(self, self.wakeUpCallback)
end

function SdkManager:registerCallbackByEventType(eventType, callback)
    if not SdkManager.SDK_EVENT_TYPE[eventType] then return end

    for _, state in ipairs(SdkManager.SDK_EVENT_TYPE[eventType]) do
        self._callBack[tonumber(state)] = callback
    end
end

function SdkManager:private_unregisterCallbackAfterTrigger(code)
    -- only login and logout need to be unregisted
    if code == SdkManager.SDK_STATE.SDK_LOGIN_SUCCESS or
       code == SdkManager.SDK_STATE.SDK_LOGIN_FAIL or
       code == SdkManager.SDK_STATE.SDK_LOGIN_CANCEL then
       self:unregisterCallbackByEventType("TYPE_LOGIN")
    elseif code == SdkManager.SDK_STATE.SDK_LOGOUT_SUCCESS or
       code == SdkManager.SDK_STATE.SDK_LOGOUT_FAIL or
       code == SdkManager.SDK_STATE.SDK_LOGOUT_CANCEL then
       self:unregisterCallbackByEventType("TYPE_LOGOUT")
    end
    --[[
    if not (code == SdkManager.SDK_STATE.SDK_LOGIN_SUCCESS or
       code == SdkManager.SDK_STATE.SDK_LOGIN_FAIL or
       code == SdkManager.SDK_STATE.SDK_LOGIN_CANCEL or
       code == SdkManager.SDK_STATE.SDK_LOGOUT_SUCCESS or
       code == SdkManager.SDK_STATE.SDK_LOGOUT_FAIL or
       code == SdkManager.SDK_STATE.SDK_LOGOUT_CANCEL) then
        return
    end
    for eventType, states in pairs(SdkManager.SDK_EVENT_TYPE) do
        for _, state in ipairs(states) do
            if tonumber(state) == tonumber(code) then
                self:unregisterCallbackByEventType(eventType)
                return
            end
        end
    end
    ]]
end

function SdkManager:unregisterCallbackByEventType(eventType)
    if not SdkManager.SDK_EVENT_TYPE[eventType] then return end

    for _, state in ipairs(SdkManager.SDK_EVENT_TYPE[eventType]) do
        self._callBack[tonumber(state)] = handler(self, self.NoSdkCallback)
    end
end

function SdkManager:init()
    self._luaBridge = nil
    self:initCallback()
    if OS_IS_IOS then
        self._luaBridge = require "cocos.cocos2d.luaoc"
        self._className = "SDKUtils"
    elseif OS_IS_ANDROID then
        self._luaBridge = require "cocos.cocos2d.luaj"
        self._className = "com/utils/core/SDKUtils"
    end
end

--[[
--! @function handleParam
--! @desc 公共处理参数
--! @param param table 传递参数
--! @return 
--]]
function SdkManager:handleParam(param)
    --[[
    if param == nil or type(param) ~= "string" then 
        param = ""
    else
        param = json.encode(param)
    end 
    ]]
end

function SdkManager:loginWithLocalInfo(param, callback)
    self:registerCallbackByEventType("TYPE_LOGIN", callback)
    if OS_IS_IOS then
        self._luaBridge.callStaticMethod(self._className, "loginWithLocalInfo", {})
    elseif OS_IS_ANDROID then
        self._luaBridge.callStaticMethod(self._className, "loginWithLocalInfo", {})
    else
        callback(SdkManager.SDK_STATE.SDK_INIT_FAIL)
    end
end

--[[
--! @function login
--! @desc 登录
--! @param param table 传递参数
--! @param callback 登录回调
--! @return 
--]]
function SdkManager:login(param, callback)
    self:registerCallbackByEventType("TYPE_LOGIN", callback)
    if OS_IS_IOS then
        self._luaBridge.callStaticMethod(self._className, "login", {["type"] = param.type})
    elseif OS_IS_ANDROID then
        self._luaBridge.callStaticMethod(self._className, "login", {["type"] = param.type})
    else
        callback(SdkManager.SDK_STATE.SDK_LOGIN_FAIL)
    end
end

--[[
--! @function logout
--! @desc 登出
--! @param param table 传递参数
--! @param callback 登出回调
--! @return 
--]]
function SdkManager:logout(param, callback)
    self:registerCallbackByEventType("TYPE_LOGOUT", callback)
    if OS_IS_IOS then
        self._luaBridge.callStaticMethod(self._className, "logout", {})
    elseif OS_IS_ANDROID then
        self._luaBridge.callStaticMethod(self._className, "logout", {})
    end
end

function SdkManager:loadUrl(param, callback)
    if OS_IS_IOS then
        self._luaBridge.callStaticMethod(self._className, "loadUrl", {["type"] = param.type, ["url"] = param.url})
    elseif OS_IS_ANDROID then
        self._luaBridge.callStaticMethod(self._className, "loadUrl", {["type"] = param.type, ["url"] = param.url})
    end
    if OS_IS_WINDOWS then 
        ViewManager:getInstance():showTip("已假装请求")
    end
end

-- 掌趣sdk传值，其他sdk有所不同
-- @params string
    -- role_id: 角色id
    -- sec: 分区标识
    -- product_id: 商品id
    -- product_name: 商品名称
    -- product_num: 商品数量
    -- product_price: 商品单价 单位分
    -- notify_url: 发货地址
    -- ext: 透传字段，对应服务端支付通知的透传字段
--[[
--! @function charge
--! @desc 充值
--! @param param table 传递参数
--! @param callback 充值回调
--! @return 
--]]
function SdkManager:charge(param, callback)
    self:registerCallbackByEventType("TYPE_CHARGE", callback)
    if OS_IS_WINDOWS and GameStatic.openVipInWindows then
        return SdkCallback(SdkManager.SDK_STATE.SDK_CHARGE_SUCCESS, json.encode({dev_pay_id = param.product_id}))
    end
    print("SdkManager:charge 1")
    dump(param)
    print("SdkManager:charge 2")
    if OS_IS_IOS then
        self._luaBridge.callStaticMethod(self._className, "charge", {["product_id"] = param.product_id, ["game_coin"] = param.game_coin, ["sec"] = param.sec, ["price"] = param.price , ["server_code"] = param.service_code ,["payitem"] = param.payitem })
    elseif OS_IS_ANDROID then
        self._luaBridge.callStaticMethod(self._className, "charge", {["product_id"] = param.product_id, ["game_coin"] = param.game_coin, ["sec"] = param.sec, ["price"] = param.price, ["service_code"] = param.service_code,["token_url"] = param.token_url})
    end
end
--[[
function SdkManager:getNetworkStatus(callback)
    self._callBack = callback
    if OS_IS_IOS then
    elseif OS_IS_ANDROID then
        self._luaBridge.callStaticMethod(self._className, "getNetworkStatus")
    end
end
]]
-- key和value必须是string
function SdkManager:saveDataInDevice(key, value, callback)
    if OS_IS_IOS then
        self._luaBridge.callStaticMethod(self._className, "saveDataInDevice", {key = key, value = value})
    elseif OS_IS_ANDROID then
        self._luaBridge.callStaticMethod(self._className, "saveDataInDevice", {key = key, value = value})
    end
end

-- key必须是字符串, 如果没存过这个值, 返回""
function SdkManager:getDataFromDevice(key, callback)
    if OS_IS_IOS then
        local _, res = self._luaBridge.callStaticMethod(self._className, "getDataFromDevice", {key = key})
        return res
    elseif OS_IS_ANDROID then
        local _, res = self._luaBridge.callStaticMethod(self._className, "getDataFromDevice", {key = key})
        return res
    end
end

function SdkManager:getPokeballValue(key, callback)
    if OS_IS_IOS then
        local _, res = self._luaBridge.callStaticMethod(self._className, "getPokeballValue", {key = key})
        return res
    elseif OS_IS_ANDROID then
        local _, res = self._luaBridge.callStaticMethod(self._className, "getPokeballValue", {key = key})
        return res
    end
end

function SdkManager:getBatteryPercent()
    if OS_IS_IOS then
        local result, percent = self._luaBridge.callStaticMethod(self._className, "getBatteryPercent", {})
        if not result then return 1 end
        return tonumber(percent)
    elseif OS_IS_ANDROID then
        local result, percent = self._luaBridge.callStaticMethod(self._className, "getBatteryPercent", {})
        if not result then return 1 end
        return tonumber(percent)
    else
        return math.random()
    end
end

function SdkManager:getNoticeData(scene)
    if OS_IS_IOS then
        local result, json = self._luaBridge.callStaticMethod(self._className, "getNoticeData", {scene = tostring(scene)})
        if not result then return "" end
        return json
    elseif OS_IS_ANDROID then
        local result, json = self._luaBridge.callStaticMethod(self._className, "getNoticeData", {scene = tostring(scene)})
        if not result then return "" end
        return json
    end
end

-- 安全Sdk

function SdkManager:setSecurityCallback(callback)
    self:registerCallbackByEventType("TYPE_SEND_SECURITY", callback)
end

function SdkManager:sendSecurityData(sec, role_id)
    if OS_IS_IOS then
        self._luaBridge.callStaticMethod(self._className, "sendSecurityData", {sec = sec, role_id = role_id})
    elseif OS_IS_ANDROID then
        self._luaBridge.callStaticMethod(self._className, "sendSecurityData", {sec = sec, role_id = role_id})
    end
end

function SdkManager:receiveSecurityData(data)
    if OS_IS_IOS then
        self._luaBridge.callStaticMethod(self._className, "receiveSecurityData", {data = data})
    elseif OS_IS_ANDROID then
        self._luaBridge.callStaticMethod(self._className, "receiveSecurityData", {data = data})
    end
end

function SdkManager:hasPlatform(platform)
    if OS_IS_IOS then
        local result, found = self._luaBridge.callStaticMethod(self._className, "hasPlatform", {["type"] = tostring(platform)})
        if not result then return false end
        return tostring(found) == "true" and true or false
    elseif OS_IS_ANDROID then
        local result, percent = self._luaBridge.callStaticMethod(self._className, "hasPlatform", {["type"] = tostring(platform)})
        if not result then return false end
        return tostring(found) == "true" and true or false
    end
end

--[[
function SdkManager:getPackageInfo(param, callback)
    self._callBack = callback
    if OS_IS_IOS then
        local ret, packageInfo = self._luaBridge.callStaticMethod(self._className, "getPackageInfo", {})
        if not ret then
            return false
        end
        return true, json.decode(packageInfo)
    elseif OS_IS_ANDROID then
        local ret, packageInfo = self._luaBridge.callStaticMethod(self._className, "getPackageInfo", {})
        if not ret then
            return false
        end
        return true, json.decode(packageInfo)
    end
end
]]
-- 掌趣sdk传值，其他sdk有所不同
-- /**
--  * @params sting
--  * role_id: 角色id
--  * role_name:角色名称
--  * sec: 分区标识
--  * sec_name: 分区名称
--  * vip: vip等级
--  * level: 角色等级
--  * balance: 货币余额
--  * type: 0 代表注册用户,1代表登录
--  */

--[[
--! @function sendUserInfo
--! @desc 发送用户信息
--! @param param table 传递参数
--! @param callback 回调
--! @return 
--]]
--[[
function SdkManager:sendUserInfo(param, callback)
    self._callBack = callback
    if OS_IS_IOS then
        --self:handleParam(param)
        --self._sdkManager:sendMessage("sendUserInfo", param)
    elseif OS_IS_ANDROID then
    end
end
]]

--[[
--! @function switchUser
--! @desc SDK切换用户
--! @param param table 传递参数
--! @param callback 回调
--! @return 
--]]

--[[
function SdkManager:switchUser(param, callback)
    self._callBack = callback
    if OS_IS_IOS then
        --self:handleParam(param)
        --self._sdkManager:sendMessage("switchUser", param)
    elseif OS_IS_ANDROID then
    end
end
]]
-- -- 掌趣sdk传值，其他sdk有所不同
-- -- /**
-- --  * 分享
-- --  * @param params
-- --  * title: 分享标题
-- --  * type:  分享的类型，由具体接入的SDK决定
-- --  * description: 分享内容
-- --  * imageUrl: 图片地址 支持本地图片和网络图片
-- --  * url: 跳转地址
-- --  */

-- --[[
-- --! @function share
-- --! @desc 分享
-- --! @param param table 传递参数
-- --! @param callback 回调
-- --! @return 
-- --]]
-- function SdkManager:share(param, callback)
--     self._callBack = callback
--     self:handleParam(param)
--     self._sdkManager:sendMessage("switchUser", param)
-- end


--[[
--! @function openUserCenter
--! @desc SDK打开用户中心
--! @param param table 传递参数
--! @param callback 回调
--! @return 
--]]
--[[
function SdkManager:openUserCenter(param, callback)
    self._callBack = callback
    if OS_IS_IOS then
        --self:handleParam(param)
        --self._sdkManager:sendMessage("openUserCenter", param)
    elseif OS_IS_ANDROID then
    end
end
]]
--[[
--! @function setLocalPush
--! @desc 设置推送（SdkManager虽然启动晚于ApplicationUtils但是第一次进入游戏无需push）
--! @return 
--]]
function SdkManager:setLocalPush(param)
    if OS_IS_WINDOWS then return end
    self._luaBridge.callStaticMethod(self._className, "setLocalPush", param)
end

--[[
--! @function cancelLocalPush
--! @desc 取消推送（SdkManager虽然启动晚于ApplicationUtils但是第一次进入游戏无需push）
--! @return 
--]]
function SdkManager:cancelLocalPush()
    if OS_IS_WINDOWS then return end
    self._luaBridge.callStaticMethod(self._className, "cancelLocalPush", {})
end

--[[
--! @function isOpenSharePlatform
--! @desc 判断当前合作方是否提供分享
--! @return 
--]]
function SdkManager:isOpenSharePlatform()
    if OS_IS_WINDOWS then return false end
    if self._channelAlias == "qq" or 
        self._channelAlias == "wx" then
        return true
    end
    return false
end

--[[
--! @function sendToPlatform
--! @param scene 1:qzone  2:给好友（微信无朋友圈）
--! @param title 分享的标题
--! @param desc 分享描述
--! @param message_ext 游戏透传信息
--! @param media_tag 请根据实际情况填入下列值的一个, 此值会传到微信供统计用, 在分享返回时也>会带回此值, 可以用于区分分享来源
         "MSG_INVITE"                   // 邀请
         "MSG_SHARE_MOMENT_HIGH_SCORE";  //分享本周最高到朋友圈
         "MSG_SHARE_MOMENT_BEST_SCORE";  //分享历史最高到朋友圈
         "MSG_SHARE_MOMENT_CROWN";       //分享金冠到朋友圈
         "MSG_SHARE_FRIEND_HIGH_SCORE";  //分享本周最高给好友
         "MSG_SHARE_FRIEND_BEST_SCORE";  //分享历史最高给好友
         "MSG_SHARE_FRIEND_CROWN";       //分享金冠给好友
         "MSG_friend_exceed"             // 超越炫耀
         "MSG_heart_send"                // 送心
--! @desc 分享图片到qq和wx
--! @return 
--]]
function SdkManager:sendToPlatform(param, callback)
    if callback then
        if OS_IS_WINDOWS then return callback(SdkManager.SDK_STATE.SDK_SHARE_FAIL) end
        self:registerCallbackByEventType("TYPE_SHARE", callback)
    else
        if OS_IS_WINDOWS then return end
    end
    -- if OS_IS_WINDOWS then return end
    if param.message_ext ~= nil and string.len(param.message_ext) > 0 then 
        param.message_ext = string.urlencode(param.message_ext)
    end
    if self._channelAlias == "qq" then
        param.game_tag = SdkManager.SHARE_TAG.MSG_FRIEND_EXCEED        
        if CPP_VERSION <= 213 then 
            if param.media_tag ~= nil and SdkManager.SHARE_QQ_TAG[string.upper(param.media_tag)] then 
                param.game_tag = SdkManager.SHARE_QQ_TAG[string.upper(param.media_tag)]
            end
        else
            if param.media_tag ~= nil then 
                param.game_tag = param.media_tag
            end
            if param.media_tag ~= nil and SdkManager.SHARE_QQ_TAG[string.upper(param.media_tag)] then 
                param.adtag = SdkManager.SHARE_QQ_TAG[string.upper(param.media_tag)]
            end
        end
        param.media_tag = nil
        param.path = GameStatic.sharePicUrl
        self:sendToQQ(param)
    elseif self._channelAlias == "wx" then
        self:sendToWX(param)
    end
end

--[[
--! @function sendToQQ
--! @param scene 1:qzone  2:给好友
--! @param title 分享的标题
--! @param desc 分享的简介
--! @param path 分享的图片路径
--! @desc 不拉起手Q和微信的客户端直接分享
--! @return 
--]]
function SdkManager:sendToQQ(param)
    self._luaBridge.callStaticMethod(self._className, "sendToQQ", param)
end

--[[
--! @function sendToWX
--! @param title 分享标题
--! @param desc 分享描述
--! @param mediaId  string  消息图片的id；通过服务端接口/share/upload_wx获取，填空则默认为游戏icon
--! @param media_tag 请根据实际情况填入下列值的一个, 此值会传到微信供统计用, 在分享返回时也>会带回此值, 可以用于区分分享来源
         "MSG_INVITE";                   // 邀请
         "MSG_SHARE_MOMENT_HIGH_SCORE";  //分享本周最高到朋友圈
         "MSG_SHARE_MOMENT_BEST_SCORE";  //分享历史最高到朋友圈
         "MSG_SHARE_MOMENT_CROWN";       //分享金冠到朋友圈
         "MSG_SHARE_FRIEND_HIGH_SCORE";  //分享本周最高给好友
         "MSG_SHARE_FRIEND_BEST_SCORE";  //分享历史最高给好友
         "MSG_SHARE_FRIEND_CROWN";       //分享金冠给好友
         "MSG_friend_exceed"             // 超越炫耀
         "MSG_heart_send"                // 送心
--! @param ext_info 游戏自定义透传字段，通过分享结果shareRet.extInfo返回给游戏，游戏可以用extInfo区分request         
--! @desc 不拉起手Q和微信的客户端直接分享
--! @return 
--]]
function SdkManager:sendToWX(param)
    self._luaBridge.callStaticMethod(self._className, "sendToWX", param)
end

--[[
--! @function sendToPlatformFriend
--! @param fopenid 好友的openid
--! @param title 分享标题
--! @param path 图片路径
--! @param desc 分享描述
--! @param message_ext 游戏透传信息
--! @param media_tag 请根据实际情况填入下列值的一个, 此值会传到微信供统计用, 在分享返回时也>会带回此值, 可以用于区分分享来源
         "MSG_INVITE"                   // 邀请
         "MSG_SHARE_MOMENT_HIGH_SCORE";  //分享本周最高到朋友圈
         "MSG_SHARE_MOMENT_BEST_SCORE";  //分享历史最高到朋友圈
         "MSG_SHARE_MOMENT_CROWN";       //分享金冠到朋友圈
         "MSG_SHARE_FRIEND_HIGH_SCORE";  //分享本周最高给好友
         "MSG_SHARE_FRIEND_BEST_SCORE";  //分享历史最高给好友
         "MSG_SHARE_FRIEND_CROWN";       //分享金冠给好友
         "MSG_friend_exceed"             // 超越炫耀
         "MSG_heart_send"                // 送心
--! @desc 分享图片到qq和wx
--! @return 
--]]
function SdkManager:sendToPlatformFriend(param)
    if OS_IS_WINDOWS then return end
    if self._channelAlias == "qq" then
        param.act = 1 -- 不传会导致崩溃
        param.game_tag = SdkManager.SHARE_TAG.MSG_FRIEND_EXCEED        
        if CPP_VERSION <= 213 and OS_IS_IOS then 
            if param.media_tag ~= nil and SdkManager.SHARE_QQ_TAG[string.upper(param.media_tag)] then 
                param.game_tag = SdkManager.SHARE_QQ_TAG[string.upper(param.media_tag)]
            end
            if param.media_tag then
                param.text = param.media_tag
            else
                param.text = SdkManager.SHARE_TAG.MSG_FRIEND_EXCEED 
            end
        else
            if param.media_tag ~= nil then 
                param.game_tag = param.media_tag
            end
            if param.media_tag ~= nil and SdkManager.SHARE_QQ_TAG[string.upper(param.media_tag)] then 
                param.adtag = SdkManager.SHARE_QQ_TAG[string.upper(param.media_tag)]
            end
            param.text = param.title
        end

        -- if param.path == nil or string.len(param.path) == 0 then 
        --     print("path 不能为空")
        --     return
        -- end
        
        param.image_url = GameStatic.sharePicUrl
        param.path = nil
        param.media_tag = nil
        dump(param, "test" ,10)
        self:sendToQQFriend(param)
    elseif self._channelAlias == "wx" then

        self:sendToWXFriend(param)
    end
end

--[[
--! @function sendToQQFriend
--! @param scene 1:qzone  2:给好友
--! @param title 分享的标题
--! @param image_url 分享缩略图URL,可以为空
--! @param text 可选, 预览文字
--! @param summary 分享的简介
--! @desc 不拉起手Q和微信的客户端直接分享
--! @return 
--]]
function SdkManager:sendToQQFriend(param)
    self._luaBridge.callStaticMethod(self._className, "sendToQQFriend", param)
end

--[[
--! @function sendToWXFriend
--! @param fopenid 好友的openid
--! @param title 分享标题
--! @param desc 分享描述
--! @param mediaId  string  消息图片的id；通过服务端接口/share/upload_wx获取，填空则默认为游戏icon
--! @param media_tag 请根据实际情况填入下列值的一个, 此值会传到微信供统计用, 在分享返回时也>会带回此值, 可以用于区分分享来源
         "MSG_INVITE";                   // 邀请
         "MSG_SHARE_MOMENT_HIGH_SCORE";  //分享本周最高到朋友圈
         "MSG_SHARE_MOMENT_BEST_SCORE";  //分享历史最高到朋友圈
         "MSG_SHARE_MOMENT_CROWN";       //分享金冠到朋友圈
         "MSG_SHARE_FRIEND_HIGH_SCORE";  //分享本周最高给好友
         "MSG_SHARE_FRIEND_BEST_SCORE";  //分享历史最高给好友
         "MSG_SHARE_FRIEND_CROWN";       //分享金冠给好友
         "MSG_friend_exceed"             // 超越炫耀
         "MSG_heart_send"                // 送心
--! @param ext_info 游戏自定义透传字段，通过分享结果shareRet.extInfo返回给游戏，游戏可以用extInfo区分request         
--! @desc 不拉起手Q和微信的客户端直接分享
--! @return 
--]]
function SdkManager:sendToWXFriend(param)
    if param.media_id == nil then 
        param.media_id = ""
    end
    self._luaBridge.callStaticMethod(self._className, "sendToWXFriend", param)
end


--[[
--! @function sendToPlatformWithPhoto
--! @param scene 1:分享到微信朋友圈  2:分享到微信会话 or 1:分享到微信朋友圈  2:分享到微信会话
--! @param path 需要分享图片的本地文件路径
--! @param media_tag 请根据实际情况填入下列值的一个, 此值会传到微信供统计用, 在分享返回时也>会带回此值, 可以用于区分分享来源
         "MSG_INVITE"                   // 邀请
         "MSG_SHARE_MOMENT_HIGH_SCORE";  //分享本周最高到朋友圈
         "MSG_SHARE_MOMENT_BEST_SCORE";  //分享历史最高到朋友圈
         "MSG_SHARE_MOMENT_CROWN";       //分享金冠到朋友圈
         "MSG_SHARE_FRIEND_HIGH_SCORE";  //分享本周最高给好友
         "MSG_SHARE_FRIEND_BEST_SCORE";  //分享历史最高给好友
         "MSG_SHARE_FRIEND_CROWN";       //分享金冠给好友
         "MSG_friend_exceed"             // 超越炫耀
         "MSG_heart_send"                // 送心
--! @desc 分享图片到qq和wx
--! @return 
--]]
function SdkManager:sendToPlatformWithPhoto(param, callback)
    if OS_IS_WINDOWS then return callback(SdkManager.SDK_STATE.SDK_SHARE_FAIL) end
    self:registerCallbackByEventType("TYPE_SHARE", callback)    
    if self._channelAlias == "qq" then
        param.media_tag = nil
        param.action = nil
        self:sendToQQWithPhoto(param)
    elseif self._channelAlias == "wx" then
        self:sendToWXWithPhoto(param)
    end
end

--[[
--! @function sendToQQWithPhoto
--! @param scene 1:qzone  2:给好友
--! @param path 需要分享图片的本地文件路径, 图片需放在sdcard分区。
--! @desc 分享图片到qq
--! @return 
--]]
function SdkManager:sendToQQWithPhoto(param)
    self._luaBridge.callStaticMethod(self._className, "sendToQQWithPhoto", param)
end

--[[
--! @function sendToWXWithPhoto
--! @param scene 1:分享到微信朋友圈  2:分享到微信会话
--! @param path 需要分享图片的本地文件路径
--! @param media_tag 请根据实际情况填入下列值的一个, 此值会传到微信供统计用, 在分享返回时也>会带回此值, 可以用于区分分享来源
         "MSG_INVITE";                   // 邀请
         "MSG_SHARE_MOMENT_HIGH_SCORE";  //分享本周最高到朋友圈
         "MSG_SHARE_MOMENT_BEST_SCORE";  //分享历史最高到朋友圈
         "MSG_SHARE_MOMENT_CROWN";       //分享金冠到朋友圈
         "MSG_SHARE_FRIEND_HIGH_SCORE";  //分享本周最高给好友
         "MSG_SHARE_FRIEND_BEST_SCORE";  //分享历史最高给好友
         "MSG_SHARE_FRIEND_CROWN";       //分享金冠给好友
         "MSG_friend_exceed"             // 超越炫耀
         "MSG_heart_send"                // 送心
--! @desc 分享图片到wx
--! @return 
--]]
function SdkManager:sendToWXWithPhoto(param)
    self._luaBridge.callStaticMethod(self._className, "sendToWXWithPhoto", param)
end

--[[
--! @function isOpenBindGroup
--! @desc 判断当前合作方是否提供绑定公会
--! @return 
--]]
function SdkManager:isOpenBindGroup()
    if OS_IS_WINDOWS then return false end
    if self._channelAlias == "qq" or 
        self._channelAlias == "wx" then
        return true
    end
    return false
end

function SdkManager:isOpenJoinGroup()
    return self:isOpenBindGroup()
end

--[[
--! @function isOpenUnBindGroup
--! @desc 判断当前合作方是否提供绑定公会
--! @return 
--]]
function SdkManager:isOpenUnBindGroup()
    if OS_IS_WINDOWS then return false end
    if self._channelAlias == "qq" then
        return true
    end
    return false
end

-- kGroupStatus = {
--     CAN_BIND          = 1,--可以绑定群组
--     CAN_JOIN          = 2,--可以加入群组
--     IN_GROUP          = 3,--在群中
--     CAN_REMOVEBIND    = 4,--可以解绑群组
--     REFRESH           = 5,--刷新群组状态
--     REFRESHING        = 6,--刷新群组状态中
--     INEXISTENCE_GROUP = 7,--不存在群
-- }
function SdkManager:bindPlatformGroup(param, callback)
    if OS_IS_WINDOWS then return end
    self:registerCallbackByEventType("TYPE_GROUP", callback)    
    if self._channelAlias == "qq" then
        self:bindQQGroup(param)
    elseif self._channelAlias == "wx" then
        self:bindWXGroup(param)
    end
end

function SdkManager:joinPlatformGroup(param, callback)
    if OS_IS_WINDOWS then return end
    self:registerCallbackByEventType("TYPE_GROUP", callback)    
    if self._channelAlias == "qq" then
        self:joinQQGroup(param)
    elseif self._channelAlias == "wx" then
        self:joinWXGroup(param)
    end
end

--[[
--! @function bindWXGroup
--! @param union_id 公会ID，opensdk限制只能填数字，字符可能会导致绑定失败     
--! @param union_name 公会名称
--! @param sec 大区ID，opensdk限制只能填数字，字符可能会导致绑定失败     
--! @desc 绑定微信公会
--! @return 
--]]
function SdkManager:bindWXGroup(param)
    self._luaBridge.callStaticMethod(self._className, "createWXGroup", param)
end

--[[
--! @function joinWXGroup
--! @param group_key 需要添加的QQ群对应的key，游戏可通过调用WGQueryQQGroupKey获取
--! @desc 分享图片到wx
--! @return 
--]]
function SdkManager:joinWXGroup(param)
    self._luaBridge.callStaticMethod(self._className, "joinWXGroup", param)
end

--[[
--! @function queryQQGroup
--! @param union_id 公会ID，opensdk限制只能填数字，字符可能会导致绑定失败 
--! @param sec 大区ID，opensdk限制只能填数字，字符可能会导致绑定失败  
--! @desc 查询信息
--! @return 
--]]
function SdkManager:queryQQGroup(param, callback)
    self:registerCallbackByEventType("TYPE_GROUP", callback)   
    self._luaBridge.callStaticMethod(self._className, "queryQQGroup", param)
end



--[[
--! @function bindQQGroup
--! @param union_id 公会ID，opensdk限制只能填数字，字符可能会导致绑定失败     
--! @param union_name 公会名称
--! @param sec 大区ID，opensdk限制只能填数字，字符可能会导致绑定失败     
--! @desc 绑定qq群
--! @return 
--]]
function SdkManager:bindQQGroup(param)
    if OS_IS_WINDOWS then return end
    self._luaBridge.callStaticMethod(self._className, "bindQQGroup", param)
end

--[[
--! @function joinQQGroup
--! @param qqGroupKey 需要添加的QQ群对应的key，游戏可通过调用WGQueryQQGroupKey获取
--! @desc 加入qq群
--! @return 
--]]
function SdkManager:joinQQGroup(param)
    if OS_IS_WINDOWS then return end
    self._luaBridge.callStaticMethod(self._className, "joinQQGroup", param)
end



--[[
--! @function isQQ
--! @desc 增加判断你是否是qq平台
--! @return 
--]]
function SdkManager:isQQ()
    if OS_IS_WINDOWS then return false end
    if self._channelAlias == "qq" then
        return true
    end
    return false
end

--[[
--! @function isWX
--! @desc 增加判断你是否是微信平台
--! @return 
--]]
function SdkManager:isWX()
    if OS_IS_WINDOWS then return false end
    if self._channelAlias == "wx" then
        return true
    end
    return false
end

--[[
--! @function isGuest
--! @desc 增加判断你是否是游客
--! @return 
--]]
function SdkManager:isGuest()
    if OS_IS_WINDOWS then return false end
    if self._channelAlias == "guest" then
        return true
    end
    return false
end

function SdkManager:setChannelAlias(inChannelAlias)
    self._channelAlias = inChannelAlias
end


function SdkManager:getChannelAlias()
    return self._channelAlias or ""
end

-- GVoice
function SdkManager:gvoice_applyMessageKey(callback)
    if OS_IS_WINDOWS then
        callback()
        return 0
    else
        self:registerCallbackByEventType("TYPE_GVOICE_APPLY", callback)
        local result, ret = self._luaBridge.callStaticMethod(self._className, "applyMessageKey", {timeout = 5000})
        return ret
    end
end

function SdkManager:gvoice_poll()
    if OS_IS_WINDOWS then return end
    self._luaBridge.callStaticMethod(self._className, "poll", {})
end

function SdkManager:gvoice_setMaxMessageLength(msTime)
    if OS_IS_WINDOWS then return 0 end
    local result, ret = self._luaBridge.callStaticMethod(self._className, "setMaxMessageLength", {time = msTime})
    return ret
end

function SdkManager:gvoice_startRecVoice(file_path)
    if OS_IS_WINDOWS then return 0 end
    local result, ret = self._luaBridge.callStaticMethod(self._className, "startRecVoice", {file_path = file_path})
    return ret
end

function SdkManager:gvoice_stopRecVoice()
    if OS_IS_WINDOWS then return 0 end
    local result, ret = self._luaBridge.callStaticMethod(self._className, "stopRecVoice", {})
    return ret
end

function SdkManager:gvoice_uploadRecVoice(file_path, callback)
    if OS_IS_WINDOWS then
        ScheduleMgr:delayCall(500, VoiceUtils, function()
            callback(0, cjson.encode({file_path = file_path, file_id = math.random(1000000)}))
        end)
        return 0
    else
        self:registerCallbackByEventType("TYPE_GVOICE_UP", callback)
        local result, ret = self._luaBridge.callStaticMethod(self._className, "uploadRecVoice", {file_path = file_path, timeout = 5000})
        return ret
    end
end

function SdkManager:gvoice_downloadRecVoice(file_path, file_id, callback)
    self:registerCallbackByEventType("TYPE_GVOICE_DOWN", callback)
    local result, ret = self._luaBridge.callStaticMethod(self._className, "downloadRecVoice", {file_path = file_path, file_id = file_id, timeout = 5000})
    return ret
end

function SdkManager:gvoice_startPlayVoice(file_path, callback)
    if OS_IS_WINDOWS then
        ScheduleMgr:delayCall(2000, self, callback)
        return 0
    else
        self:registerCallbackByEventType("TYPE_GVOICE_PLAY", callback)
        local result, ret = self._luaBridge.callStaticMethod(self._className, "startPlayVoice", {file_path = file_path})
        return ret
    end
end

function SdkManager:gvoice_stopPlayVoice()
    if OS_IS_WINDOWS then return end
    local result, ret = self._luaBridge.callStaticMethod(self._className, "stopPlayVoice", {})
    return ret
end

function SdkManager:gvoice_speechToText(file_id, callback)
    if OS_IS_WINDOWS then
        ScheduleMgr:delayCall(2000, self, callback)
        return 0
    else
        self:registerCallbackByEventType("TYPE_GVOICE_STT", callback)
        local result, ret = self._luaBridge.callStaticMethod(self._className, "speechToText", {file_id = file_id})
        return ret
    end
end

function SdkManager:gvoice_setMessageMode()
    if OS_IS_WINDOWS then return end
    local result, ret = self._luaBridge.callStaticMethod(self._className, "setMessageMode", {})
    return ret
end

function SdkManager:gvoice_setTranslationMode()
    if OS_IS_WINDOWS then return end
    local result, ret = self._luaBridge.callStaticMethod(self._className, "setTranslationMode", {})
    return ret
end

-- TYPE_GVOICE_JOIN = {
--     SdkManager.SDK_STATE.VOICE_JOIN_SUCCESS,
--     SdkManager.SDK_STATE.VOICE_JOIN_FAIL,
-- },  
-- TYPE_GVOICE_QUIT = {
--     SdkManager.SDK_STATE.VOICE_QUIT_SUCCESS,
--     SdkManager.SDK_STATE.VOICE_QUIT_FAIL,
-- },  
-- TYPE_GVOICE_ROOM = {
--     SdkManager.SDK_STATE.VOICE_MEM_VOICE,
--     SdkManager.SDK_STATE.VOICE_STATE_UPDATE,
-- },   
-- 国战相关
-- if pc.PCTools.hasNationalVoice then

-- end
function SdkManager:gvoice_setNationalMode()
    if OS_IS_WINDOWS then return end
    local result, ret = self._luaBridge.callStaticMethod(self._className, "setNationalMode", {})
    return ret
end

function SdkManager:gvoice_JoinNationalRoom(roomName, role, callback)
    if OS_IS_WINDOWS then
        ScheduleMgr:delayCall(2000, self, callback)
        return 0
    else
        self:registerCallbackByEventType("TYPE_GVOICE_JOIN", callback)
        local result, ret = self._luaBridge.callStaticMethod(self._className, "JoinNationalRoom", {roomName = roomName, role = OS_IS_IOS and tostring(role) or tonumber(role)})
        return ret
    end
end

function SdkManager:gvoice_QuitRoom(roomName, callback)
    if OS_IS_WINDOWS then
        ScheduleMgr:delayCall(2000, self, callback)
        return 0
    else
        self:registerCallbackByEventType("TYPE_GVOICE_QUIT", callback)
        local result, ret = self._luaBridge.callStaticMethod(self._className, "QuitRoom", {roomName = roomName})
        return ret
    end
end

function SdkManager:gvoice_OpenMic()
    if OS_IS_WINDOWS then return end
    local result, ret = self._luaBridge.callStaticMethod(self._className, "OpenMic", {})
    return ret
end

function SdkManager:gvoice_CloseMic()
    if OS_IS_WINDOWS then return end
    local result, ret = self._luaBridge.callStaticMethod(self._className, "CloseMic", {})
    return ret
end

function SdkManager:gvoice_OpenSpeaker()
    if OS_IS_WINDOWS then return end
    local result, ret = self._luaBridge.callStaticMethod(self._className, "OpenSpeaker", {})
    return ret
end

function SdkManager:gvoice_CloseSpeaker()
    if OS_IS_WINDOWS then return end
    local result, ret = self._luaBridge.callStaticMethod(self._className, "CloseSpeaker", {})
    return ret
end

function SdkManager:gvoice_memberVoice(callback)
    if OS_IS_WINDOWS then return end
    self:registerCallbackByEventType("TYPE_GVOICE_ROOM", callback)
end

-- 渠道号
function SdkManager:getChannelID()
    if not OS_IS_ANDROID then return "0" end
    local result, ret = self._luaBridge.callStaticMethod(self._className, "getChannelID", {})
    return ret
end

-- 应用内评分 ios10.3
function SdkManager:requestReview()
    if not OS_IS_IOS then return end
    local result, ret = self._luaBridge.callStaticMethod(self._className, "requestReview", {})
    return ret
end

--! @function 一键加好友
--! @param fopenid 
--! @param desc 
--! @param messages
--! @return 
--]]
function SdkManager:addGameFriendToQQ(param)
    if OS_IS_WINDOWS then return end
    if CPP_VERSION <= 212 then return end
    self._luaBridge.callStaticMethod(self._className, "addGameFriendToQQ", param)
end

function SdkManager:showJGLauncher()
    if OS_IS_WINDOWS then return end
    if CPP_VERSION <= 213 then return end
    -- local k = cc.Director:getInstance():getOpenGLView():getFrameSize().height / MAX_SCREEN_HEIGHT
    -- self._luaBridge.callStaticMethod(self._className, "showJGLauncher", {xx = math.floor(16 * k), yy = math.floor(78 * k)})
end

function SdkManager:hideJGLauncher()
    if OS_IS_WINDOWS then return end
    if CPP_VERSION <= 213 then return end
    self._luaBridge.callStaticMethod(self._className, "hideJGLauncher", {})
end

function SdkManager:gfmInit(strUserName,strAreaId,channelId,headUrl,areaName,roleId,roleName)
    if OS_IS_WINDOWS then return end
    if CPP_VERSION <= 214 then return end
    self._luaBridge.callStaticMethod(self._className, "gfmInit", {
        strUserName = strUserName or "123",
        strAreaId = strAreaId or "123",
        channelId = channelId or "123",
        headUrl = headUrl or "123",
        areaName = areaName or "123",
        roleId = roleId or "123",
        roleName = roleName or "123"
    })
end

function SdkManager:gfmShowLive()
    if OS_IS_WINDOWS then return end
    if CPP_VERSION <= 214 then return end
    self._luaBridge.callStaticMethod(self._className, "gfmShowLive", {})
end

function SdkManager:gfmPoll()
    if OS_IS_WINDOWS then return end
    if CPP_VERSION <= 214 then return end
    self._luaBridge.callStaticMethod(self._className, "gfmPoll", {})
end

function SdkManager:gfmCloseLive()
    if OS_IS_WINDOWS then return end
    if CPP_VERSION <= 214 then return end
    self._luaBridge.callStaticMethod(self._className, "gfmCloseLive", {})
end

function SdkManager.dtor()
    _sdkManager = nil
    SdkManager = nil
end

return SdkManager