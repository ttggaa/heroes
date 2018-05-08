--[[
    Filename:    BulletSettingView.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-01-20 11:40:50
    Description: File description
--]]

local BulletSettingView = class("BulletSettingView", BasePopView)

function BulletSettingView:ctor(data)
    BulletSettingView.super.ctor(self)
    self._bulletD = data.bulletD
    --是否跨服弹幕
    self._isShowKuaFu = data.kuaFuEnable
    -- 用于传递当前开关状态的回调
    self._callback = data.callback
    self._vip = self._modelMgr:getModel("VipModel"):getData().level
    self._bulletModel = self._modelMgr:getModel("BulletModel")
    self._userModel = self._modelMgr:getModel("UserModel")
end

function BulletSettingView:onInit()
    self._kuafuPanel = self:getUI("bg.kuafuPanel")
    self._kuafuPanel:setVisible(self._isShowKuaFu)

    for i = 1, 4 do
        local btn = self:getUI("bg.bulletBtn"..i)
        btn.select = self:getUI("bg.bulletBtn"..i..".select")
        self["_btn"..i] = btn
        btn.select:setVisible(false)
        self:registerClickEvent(btn, function ()
            self:setPos(i)
        end)
    end
    self._btn1.select:setVisible(true)
    self._pos = 1

    if self._vip < 4 then
        self._btn4:setSaturation(-100)
        self._btn4:setScaleAnim(false)
    end

    local title = self:getUI("bg.title")
    UIUtils:setTitleFormat(title, 1)

    self._openBtn = self:getUI("bg.openBtn")
    self._openBtn.select = self:getUI("bg.openBtn.select")

    self:registerClickEvent(self._openBtn, function ()
        self:onOpen()
    end)
    self._open = BulletScreensUtils.getBulletChannelEnabled(self._bulletD)
    self._openBtn.select:setVisible(self._open)

    self._pushBtn1 = self:getUI("bg.btn1")
    self._pushBtn1:setVisible(true)
    self._pushBtn2 = self:getUI("bg.btn2")
    self._pushBtn2:setVisible(true)
    if self._isShowKuaFu then
        self._pushBtn1:setVisible(false)
        self._pushBtn2:setVisible(false)
        self._pushBtn1 = self:getUI("bg.kuafuPanel.btn1")
        self._pushBtn2 = self:getUI("bg.kuafuPanel.btn2")
        self._gemCost = tab:Setting("G_CITYBATTLE_KUAFUDANMU").value
        local costLabel = self:getUI("bg.kuafuPanel.costLabel")
        costLabel:setString(self._gemCost)
    end

    self._pushBtn3 = self:getUI("bg.kuafuPanel.btn3")
    self._pushBtn2:setTitleText("发射彩弹")
    self._pushBtn3:setTitleText("跨服弹幕")

    self:registerClickEvent(self._pushBtn1, function ()
        self:onPush(1)
    end)

    self:registerClickEvent(self._pushBtn2, function ()
        self:onPush(2)
    end)

    self:registerClickEvent(self._pushBtn3, function ()
        self:onPush(3)
    end)

    if self._vip < 4 then
        self._pushBtn2:setSaturation(-100)
        self._pushBtn2:setScaleAnim(false)
    end
    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
    end)

    self:registerClickEventByName("bg.btn_info", function (  )
        local ruleDes = lang("BULLET_TIPS_RULES")
        self._viewMgr:showDialog("global.GlobalRuleDescView", {desc = ruleDes}, true)
    end)

    self._input = self:getUI("bg.bg.input")
    self._input:setPlaceHolderColor(cc.c4b(0, 0, 0, 130))
    self._input:setMaxLengthEnabled(true)
    self._input:setMaxLength(self._bulletD["maxlength"])

    self._inputBg = self:getUI("bg.inputBg")
    self:registerClickEvent(self._inputBg, function ()  
        self._input:attachWithIME()
    end)

end

function BulletSettingView:setPos(pos)
    if self._vip < 4 and pos == 4 then
        self._viewMgr:showTip("Vip等级不足")
        return
    end
    if self._pos == pos then return end
    self["_btn"..self._pos].select:setVisible(false)
    self._pos = pos
    self["_btn"..pos].select:setVisible(true)
end

function BulletSettingView:onOpen()
    self._open = not self._openBtn.select:isVisible()
    if self._open then
        local enable = BulletScreensUtils.enable
        -- 开启
        self._openBtn.select:setVisible(true)
        BulletScreensUtils.setBulletChannelEnabled(self._bulletD, true)
        if self._callback then
            self._callback(true)
        end
        if not enable then
            BulletScreensUtils.initBullet(self._bulletD)
        else
            BulletScreensUtils.show()
        end
    else
        -- 关闭
        self._openBtn.select:setVisible(false)
        BulletScreensUtils.setBulletChannelEnabled(self._bulletD, false)
        if self._callback then
            self._callback(false)
        end
        BulletScreensUtils.hide()
    end
end

function BulletSettingView:onPush(type)
    if self._vip < 4 and type == 2 then
        self._viewMgr:showTip("Vip等级不足")
        return    
    end
    if type == 3 then
        local cost = self._gemCost
        local userGemCount = self._userModel:getData().gem
        if userGemCount < cost then
            -- self._viewMgr:showTip("钻石不足")
            DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
                local viewMgr = ViewManager:getInstance()
                viewMgr:showView("vip.VipView", {viewType = 0})
            end})
            return
        end
    end

    local w = self._input:getString()
    if string.len(w) == 0 then
        self._viewMgr:showTip("请输入文字后发射")
        return
    end
    if not BulletScreensUtils.enable then
        self._viewMgr:showTip("请先开启弹幕")
        return
    end
    local tick = self._bulletModel:getBulletCanPushTick(self._bulletD["id"])
    if tick == nil then tick = 0 end
    if socket.gettime() < tick then
        self._viewMgr:showTip("发射频繁，请在"..math.ceil(tick - socket.gettime()).."秒后尝试")
        return
    end
    function pushSuccess()
        self._viewMgr:showTip("发射成功")
        self._input:setString("")
        self._bulletModel:setBulletCanPushTick(self._bulletD["id"], socket.gettime() + self._bulletD["cd"])
        ScheduleMgr:delayCall(self._bulletD["cd"] * 1000, self, function()
            self._pushBtn1:setScaleAnim(true)
            if self._vip >= 4 then
                self._pushBtn2:setScaleAnim(true)
            end
        end)
    end
    self._pushBtn1:setScaleAnim(false)
    self._pushBtn2:setScaleAnim(false)
    self._pushBtn3:setScaleAnim(false)

    local actionName
    local t = BulletScreensUtils.getPushTime()
    local isLive = self._bulletD["live"] == 1
    if isLive then
        actionName = "sendLiveBullet"
        t = 0
    else
        actionName = "sendBullet"
    end
    if type == 1 then
        local c = 1
        local p = self._pos
        self._serverMgr:sendMsg("BulletServer", actionName, {sid = self._bulletD["id"], bullet = json.encode({t = t, p = p, c = c, w = w})},
         true, {}, function(data, error)
            if error ~= 0 then
                if error == 100 then
                    self._viewMgr:showTip("您的弹幕中含有非法字符，请重新输入") 
                    self._input:setString("")
                end
                return
            end
            if not isLive then
                BulletScreensUtils.pushBullet(data.w, p, c)
            end
            pushSuccess()
        end)  
    elseif type == 2 then
        local c = math.random(8)
        local p = self._pos
        self._serverMgr:sendMsg("BulletServer", actionName, {sid = self._bulletD["id"], bullet = json.encode({t = t, p = p, c = c, w = w})},
         true, {}, function(data, error)
            if error ~= 0 then
                if error == 100 then
                    self._viewMgr:showTip("您的弹幕中含有非法字符，请重新输入")
                    self._input:setString("")
                end
                return
            end
            if not isLive then
                BulletScreensUtils.pushBullet(data.w, p, c)
            end
            pushSuccess()
        end)
    elseif type == 3 then
        local c = math.random(8)
        local p = self._pos
        self._serverMgr:sendMsg("BulletServer", actionName, {sid = self._bulletD["id"], bullet = json.encode({t = t, p = p, c = c, w = w}), cross = true},
         true, {}, function(data, error)
            if error ~= 0 then
                if error == 100 then
                    self._viewMgr:showTip("您的弹幕中含有非法字符，请重新输入")
                    self._input:setString("")
                end
                return
            end
            if not isLive then
                BulletScreensUtils.pushBullet(data.w, p, c)
            end
            if error == 0 then
                local u = data.u
                if u then
                    self._userModel:updateUserData(u["d"])
                end
            end
            pushSuccess()
        end)

    end 
end

return BulletSettingView