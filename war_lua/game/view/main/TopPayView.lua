--[[
    Filename:    TopPayView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-04-04 11:30:20
    Description: File description
--]]

local TopPayView = class("TopPayView", BasePopView)

function TopPayView:ctor()
    TopPayView.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
end

function TopPayView:onInit()
    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function ()
        self:close()
        UIUtils:reloadLuaFile("main.TopPayView")
    end)

    -- local bg1 = self:getUI("bg1")
    -- bg1:loadTexture("asset/bg/bg_001.jpg")

    local bg = self:getUI("bg")
    bg:loadTexture("asset/bg/bg_topPay.png")

    local leftImg = self:getUI("bg.Image_2")
    leftImg:loadTexture("asset/bg/global_reward3_img.png")


    local descBg = self:getUI("bg.descBg")
    local str = ""
    if sdkMgr:isQQ() == true then
        str = lang("TOP_PAY_100")
    elseif sdkMgr:isWX() == true then
        str = lang("TOP_PAY_200")
    else
        -- windows 增加默认显示值
        str = lang("TOP_PAY_100")
    end
    if string.find(str, "color=") == nil then
        str = "[color=000000]".. str .."[-]"
    end
    
    local printerText = RichTextFactory:create(str, descBg:getContentSize().width - 10, 0)
    printerText:setPrintInterval(0.1)
    printerText:setPixelNewline(true)
    printerText:formatText()

    local height  = descBg:getContentSize().height
    if height < printerText:getRealSize().height then
        height = printerText:getRealSize().height
    end
    printerText:setPosition(descBg:getContentSize().width/2, descBg:getContentSize().height - printerText:getRealSize().height/2)
    descBg:addChild(printerText)
    self:updtaeBtnState()

end


function TopPayView:getWeeklyVipGiftMail()
    local rewardState = self._userModel:getTopPayWeekRewardState()
    print("rewardState============", rewardState)
    if rewardState == true then 
        self._viewMgr:showTip(lang("VIP_TIPS4"))
        return
    end
    self._serverMgr:sendMsg("UserServer", "getWeeklyVipGiftMail", {}, true, {}, function (result)
        if result == nil or next(result) == nil then 
            self._viewMgr:showTip("领取失败")
            return
        end
        self:updtaeBtnState()
        self._viewMgr:showTip(lang("VIP_TIPS3"))
    end)
end



function TopPayView:getVipGiftMail()
    local vipGift = self._userModel:getVipGift()
    if vipGift == 1 then 
        self._viewMgr:showTip(lang("VIP_TIPS2"))
        return
    end
    self._serverMgr:sendMsg("UserServer", "getVipGiftMail", {}, true, {}, function (result)
        if result == nil or next(result) == nil then 
            self._viewMgr:showTip("领取失败")
            return
        end
        self._userModel:setVipGift(1)

        self._viewMgr:showTip(lang("VIP_TIPS1"))
    end)
end


function TopPayView:updtaeBtnState()
    local callBtn = self:getUI("bg.callBtn")
    callBtn:setTitleFontSize(22)
    callBtn:ignoreContentAdaptWithSize(false)    

    local curTime = self._userModel:getCurServerTime()
    local labTip = self:getUI("bg.labTip")
    labTip:enableOutline(cc.c4b(60, 30, 10, 255), 2)
    local vipGift = self._userModel:getVipGift()
    if vipGift == 1 then 
        callBtn:setSaturation(-100)
        local rewardState = self._userModel:getTopPayWeekRewardState()
        if rewardState == false then
            callBtn:setSaturation(0)
            callBtn:setContentSize(240,54)
            callBtn:setTitleText("领取贵宾专属周礼包")    
        else
            callBtn:setSaturation(-100)
            callBtn:setContentSize(240,54)
            callBtn:setTitleText("领取贵宾专属周礼包")  

        end
        self:registerClickEvent(callBtn, function ()
            self:getWeeklyVipGiftMail()
        end)
    else
        callBtn:setContentSize(200,54)
        callBtn:setTitleText("点击领取贵宾礼包")
        callBtn:setSaturation(0)
        self:registerClickEvent(callBtn, function ()
            self:getVipGiftMail()
        end)   
        labTip:setVisible(false)
    end
end
return TopPayView