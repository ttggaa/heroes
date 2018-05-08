--[[
    Filename:    CustomServiceUtils.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-04-06 19:40:27
    Description: File description
--]]

-- 所有需要呼叫客户的方法的汇总

local CustomServiceUtils = {}

function CustomServiceUtils.topPay()
    if sdkMgr:isQQ() then
        sdkMgr:loadUrl({url = GameStatic.CustomService_topPay_qq_url})
        print(GameStatic.CustomService_topPay_qq_url)
    elseif sdkMgr:isWX() or OS_IS_WINDOWS then
        ViewManager:getInstance():showDialog("global.GlobalOkDialog", {desc = lang("TOP_PAY_101"), button = "确定", 
        callback = function ()
        end}, true)
    end
end

function CustomServiceUtils.loginFailed()
    if OS_IS_ANDROID then
        sdkMgr:loadUrl({url = GameStatic.CustomService_login_android_url})
        print(GameStatic.CustomService_login_android_url)
    elseif OS_IS_IOS or OS_IS_WINDOWS then
        sdkMgr:loadUrl({url = GameStatic.CustomService_login_ios_url})
        print(GameStatic.CustomService_login_ios_url)  
    end
end

function CustomServiceUtils.setting()
    if OS_IS_ANDROID then
        sdkMgr:loadUrl({url = GameStatic.CustomService_setting_android_url})
        print(GameStatic.CustomService_setting_android_url)
    elseif OS_IS_IOS or OS_IS_WINDOWS then
        sdkMgr:loadUrl({url = GameStatic.CustomService_setting_ios_url})
        print(GameStatic.CustomService_setting_ios_url)  
    end
end

function CustomServiceUtils.rechargeFailed()
    if OS_IS_ANDROID then
        sdkMgr:loadUrl({url = GameStatic.CustomService_recharge_android_url})
        print(GameStatic.CustomService_recharge_android_url)
    elseif OS_IS_IOS or OS_IS_WINDOWS then
        sdkMgr:loadUrl({url = GameStatic.CustomService_recharge_ios_url})
        print(GameStatic.CustomService_recharge_ios_url)  
    end
end

return CustomServiceUtils