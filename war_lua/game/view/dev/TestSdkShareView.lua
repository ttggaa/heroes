--[[
    Filename:    TestSdkShareView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-01-05 14:58:36
    Description: File description
--]]

local TestSdkShareView = class("TestSdkShareView", BaseView)

function TestSdkShareView:ctor(inData)
    TestSdkShareView.super.ctor(self)

end


--! @param title 分享标题
--! @param desc 分享描述
--! @param media_tag 请根据实际情况填入下列值的一个, 此值会传到微信供统计用, 在分享返回时也>会带回此值, 可以用于区分分享来源

function TestSdkShareView:onInit()
    local test = cc.Sprite:create("asset/bg/bg_072.jpg")

    -- test:setScale(0.8)
    test:setAnchorPoint(0, 0)
    test:setPosition(MAX_SCREEN_WIDTH * 0.5 - test:getContentSize().width * 0.5, MAX_SCREEN_HEIGHT * 0.5 - test:getContentSize().height * 0.5)
    self:addChild(test)
    -- 不拉起客户端分享，例如好友赠送体力的通知他，这个需要有用户的openid
    local button1 = ccui.Button:create("globalImageUI_dice.png", "globalImageUI_dice.png", "", 1)
    button1:setPosition(MAX_SCREEN_WIDTH / 2 , MAX_SCREEN_HEIGHT - 100)
    self:addChild(button1)
    registerClickEvent(button1, function()
        self:getPlatFriendList()
    end)
                       
    local tipLab = cc.Label:createWithTTF("查看好友", UIUtils.ttfName, 35)
    tipLab:setPosition(0, 0)
    tipLab:setColor(cc.c3b(255, 50, 50))
    tipLab:enableOutline(cc.c4b(0,0,0,255), 2)
    button1:addChild(tipLab, 10) 


    -- 不拉起客户端分享，例如好友赠送体力的通知他，这个需要有用户的openid
    local button1 = ccui.Button:create("globalImageUI_dice.png", "globalImageUI_dice.png", "", 1)
    button1:setPosition(150, MAX_SCREEN_HEIGHT - 100)
    self:addChild(button1)
    registerClickEvent(button1, function()
        local test = cc.Sprite:create("/storage/emulated/0/Android/data/com.tencent.tmgp.yxwdzzjy/share.png")
        test:setScale(0.2)
        test:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2)
        self:addChild(test)
        local param = {}
        param.fopenid = "41B0C4E84D7F6EF098F4DCFD9A33205C"
        param.title = "英雄无敌送体力"
        param.desc = "送了体力给您哦，你也送我一些吧"
        param.media_tag = sdkMgr.SHARE_TAG.MSG_FRIEND_EXCEED
        -- param.path = "/storage/emulated/0/Android/data/com.tencent.tmgp.yxwdzzjy/share.png"
        sdkMgr:sendToPlatformFriend(param, function(code, data)

        end)
    end)
                       
    local tipLab = cc.Label:createWithTTF("通知他", UIUtils.ttfName, 35)
    tipLab:setPosition(0, 0)
    tipLab:setColor(cc.c3b(255, 50, 50))
    tipLab:enableOutline(cc.c4b(0,0,0,255), 2)
    button1:addChild(tipLab, 10) 



    -- 拉起文字分享，主要是文字类，注意微信无法分享朋友圈，只能分享好友
    local button1 = ccui.Button:create("globalImageUI_dice.png", "globalImageUI_dice.png", "", 1)
    button1:setPosition(300, MAX_SCREEN_HEIGHT - 200)
    self:addChild(button1)
    registerClickEvent(button1, function()
        local param = {}
        param.scene = 2
        param.title = "测试一下"
        param.desc = "测试测试看看分享行不"
        -- param.path = "/storage/emulated/0/Android/data/com.tencent.tmgp.yxwdzzjy/share.png"
        param.media_tag = sdkMgr.SHARE_TAG.MSG_FRIEND_EXCEED
        sdkMgr:sendToPlatform(param, function(code, data)

        end)
    end)

    local tipLab = cc.Label:createWithTTF("分享好友", UIUtils.ttfName, 35)
    tipLab:setPosition(0, 0)
    tipLab:setColor(cc.c3b(255, 50, 50))
    tipLab:enableOutline(cc.c4b(0,0,0,255), 2)
    button1:addChild(tipLab, 10)

    -- 只要qq可以分享空间，微信不能分享朋友圈
    if sdkMgr:isQQ() then
        local button1 = ccui.Button:create("globalImageUI_dice.png", "globalImageUI_dice.png", "", 1)
        button1:setPosition(400, MAX_SCREEN_HEIGHT - 300)
        self:addChild(button1)
        registerClickEvent(button1, function()
            local param = {}
            param.scene = 1
            param.title = "测试一下"
            param.desc = "测试测试看看分享行不"
            param.media_tag = sdkMgr.SHARE_TAG.MSG_FRIEND_EXCEED
            sdkMgr:sendToPlatform(param, function(code, data)

            end)
        end)

        local tipLab = cc.Label:createWithTTF("分享空间", UIUtils.ttfName, 35)
        tipLab:setPosition(0, 0)
        tipLab:setColor(cc.c3b(255, 50, 50))
        tipLab:enableOutline(cc.c4b(0,0,0,255), 2)
        button1:addChild(tipLab, 10)    
    end

    local button1 = ccui.Button:create("globalImageUI_dice.png", "globalImageUI_dice.png", "", 1)
    button1:setPosition(500, MAX_SCREEN_HEIGHT - 400)
    self:addChild(button1)
    registerClickEvent(button1, function()
        self._viewMgr:lock()
        -- test:setScale(0.8)
        -- local xscale = MAX_SCREEN_WIDTH / test:getContentSize().width
        -- local yscale = MAX_SCREEN_HEIGHT / test:getContentSize().height
        -- if xscale > yscale then
        --     test:setScale(xscale)
        -- else
        --     test:setScale(yscale)
        -- end
        UIUtils:shareToPlatfrom(1, test, function(imgPath)
            print("imgPath======", imgPath)
            local param = {}
            param.scene = 1
            param.path = imgPath
            self._viewMgr:unlock()
            test:setScale(1)
            param.media_tag = sdkMgr.SHARE_TAG.MSG_FRIEND_EXCEED
            -- sdkMgr:sendToPlatformWithPhoto(param, function(code, data)
            -- end)
        end)
    end)

    local tipLab = cc.Label:createWithTTF("分享大图朋友圈", UIUtils.ttfName, 35)
    tipLab:setPosition(0, 0)
    tipLab:setColor(cc.c3b(255, 50, 50))
    tipLab:enableOutline(cc.c4b(0,0,0,255), 2)
    button1:addChild(tipLab, 10)
        


    local button1 = ccui.Button:create("globalImageUI_dice.png", "globalImageUI_dice.png", "", 1)
    button1:setPosition(600, MAX_SCREEN_HEIGHT - 500)
    self:addChild(button1)
    registerClickEvent(button1, function()
        self._viewMgr:lock(-1)
        UIUtils:shareToPlatfrom(1, self, function(imgPath)
            print("imgPath======", imgPath)
            local param = {}
            param.scene = 2
            param.path = imgPath
            param.media_tag = sdkMgr.SHARE_TAG.MSG_FRIEND_EXCEED
            self._viewMgr:unlock()
            sdkMgr:sendToPlatformWithPhoto(param, function(code, data)
            end)
        end)
    end)

    local tipLab = cc.Label:createWithTTF("分享大图好友", UIUtils.ttfName, 35)
    tipLab:setPosition(0, 0)
    tipLab:setColor(cc.c3b(255, 50, 50))
    tipLab:enableOutline(cc.c4b(0,0,0,255), 2)
    button1:addChild(tipLab, 10)

    local button4 = ccui.Button:create("globalBtnUI_closeimg.png", "globalBtnUI_closeimg.png", "", 1)
    button4:setPosition(MAX_SCREEN_WIDTH /2 + 200, MAX_SCREEN_HEIGHT/2 - 200)
    self:addChild(button4)
    registerClickEvent(button4, function()
        print("test=====================")
        self:close() 
        UIUtils:reloadLuaFile("dev.TestSdkShareView")
    end)
end


function TestSdkShareView:getPlatFriendList()
    self._serverMgr:sendMsg("GameFriendServer", "getPlatFriendList", {}, true, {}, function (result)
        if result == nil then 
            return
        end
        dump(result, "test", 10)
    end)
end


function TestSdkShareView:getBgName()
    return "bg_071.jpg"
end

return TestSdkShareView