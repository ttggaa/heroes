--[[
    Filename:    WXSubscriberView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-04-03 15:57:25
    Description: File description
--]]

local WXSubscriberView = class("WXSubscriberView", BasePopView)

function WXSubscriberView:ctor()
    WXSubscriberView.super.ctor(self)

end

function WXSubscriberView:onInit()

    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("main.WXSubscriberView")
        elseif eventType == "enter" then 

        end
    end)   
    local title = self:getUI("bg.title")    
    title:setColor(UIUtils.colorTable.ccUITabColor2)
    title:setFontSize(28)
    
    self:registerClickEventByName("bg.closeBtn", function ()
        self:submitData()
    end)

    local leftImg = self:getUI("bg.Image_65")
    leftImg:loadTexture("asset/bg/comment_roleImg.png")

    --设置面板
    for i = 1, 3 do
        local checkBoxDes = self:getUI("bg.checkBg.checkBoxDes"..i)
        checkBoxDes:setColor(UIUtils.colorTable.ccUIBaseColor1)
        checkBoxDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    end

    
end

function WXSubscriberView:reflashUI(data)
    local userModel = self._modelMgr:getModel("UserModel")
    local subscribe = userModel:getWXSubscribe()
    dump(subscribe, "htestr", 10)

    self._selSubscriber = {}
    -- 注意1是退订，0是订阅，有疑问找二狗
    -- 领取体力提醒
    local checkBox = self:getUI("bg.checkBg.checkBox1")
    checkBox:setSelected(subscribe["154"] == 1)
    checkBox:addEventListener(function (_, state)
        self._selSubscriber["154"] = state
    end)

    -- 英雄交锋开展提醒
    local checkBox = self:getUI("bg.checkBg.checkBox2")
    checkBox:setSelected(subscribe["156"] == 1)
    checkBox:addEventListener(function (_, state)
        self._selSubscriber["156"] = state
    end)

    local checkBox = self:getUI("bg.checkBg.checkBox3")
    checkBox:setSelected(subscribe["157"] == 1)
    checkBox:addEventListener(function (_, state)
        self._selSubscriber["157"] = state

    end)    
end

function WXSubscriberView:submitData()
    local userModel = self._modelMgr:getModel("UserModel")
    local subscribe = userModel:getWXSubscribe()
    local param = {}
    param.msgId = json.encode(self._selSubscriber)
    self._serverMgr:sendMsg("UserServer", "subscribe_setlist", param, true, {}, function (result)
        for k,v in pairs(self._selSubscriber) do
            if result[k] == nil or result[k].msg ~= "success" then 
                if k == "154" then 
                    self._viewMgr:showTip("设置领取体力提醒失败")
                end
                if k == "156" then 
                    self._viewMgr:showTip("设置英雄交锋开战提醒失败")
                end  
                if k == "157" then 
                    self._viewMgr:showTip("设置诸神之战开战提醒失败")
                end
                self:reflashUI()
                return
            end
            if v == 0 then 
                subscribe[k] = 1
            else
                subscribe[k] = 0
            end
        end
        self:close()
    end)
end

return WXSubscriberView