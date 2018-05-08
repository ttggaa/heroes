--[[
    Filename:    ShareTrainingModule.lua
    Author:      <huangguofang@playcrab.com>
    Datetime:    2017-06-1 14:42:52
    Description: File description
--]]

local ShareBaseView = require("game.view.share.ShareBaseView")

function ShareBaseView:transferData(data)
    self._data = data
    self._HScore = data.Hscore or 0     --黄执中时间
    self._userScore = data.score or 0   --玩家时间
    self._userModel = self._modelMgr:getModel("UserModel")
    self._leagueModel = self._modelMgr:getModel("LeagueModel")
    
end

function ShareBaseView:updateModuleView(data)
    local shareLayer = self:getShareLayer()
    local centerX, centerY = shareLayer:getContentSize().width * 0.5, shareLayer:getContentSize().height * 0.5

    -- 左黄执中信息   
    -- 黄执中头像 
    local Hicon = IconUtils:createHeadIconById({avatar = 1101,tp = 4, eventStyle=0})   --,tp = 2
    local iconColor = Hicon:getChildByFullName("iconColor")
    if iconColor then
        iconColor:loadTexture("globalImageUI4_heroBg1.png",1)
        local headIcon = iconColor:getChildByFullName("headIcon")
        if headIcon then
            headIcon:loadTexture("trainingView_ac_head.png",1)
        end
    end
    -- Hicon:setScale(0.6)
    Hicon:setPosition(centerX-150,centerY-262)
    shareLayer:addChild(Hicon)

    -- des
    local HdesTxt = ccui.Text:create()
    HdesTxt:setFontName(UIUtils.ttfName)
    HdesTxt:setFontSize(16)
    HdesTxt:setColor(cc.c4b(255,252,0,255))
    HdesTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    HdesTxt:setString("绝辩鬼才")
    HdesTxt:setAnchorPoint(0,0.5)
    HdesTxt:setPosition(centerX-50,centerY-185)
    shareLayer:addChild(HdesTxt)

    -- name
    local HnameTxt = ccui.Text:create()
    HnameTxt:setFontName(UIUtils.ttfName)
    HnameTxt:setFontSize(20)
    HnameTxt:setColor(cc.c4b(255,231,193,255))
    HnameTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    HnameTxt:setString("黄执中")
    HnameTxt:setAnchorPoint(0,0.5)
    HnameTxt:setPosition(centerX-50,centerY-208)
    shareLayer:addChild(HnameTxt)

    -- score
    local Hscore = ccui.Text:create()
    Hscore:setFontName(UIUtils.ttfName)
    Hscore:setFontSize(20)
    Hscore:setColor(cc.c4b(255,252,0,255))
    Hscore:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    Hscore:setString(self._HScore .. "秒")
    Hscore:setAnchorPoint(0,0.5)
    Hscore:setPosition(centerX-50,centerY-250)
    shareLayer:addChild(Hscore)

    -- -- 右玩家信息
    local userInfo = self._userModel:getData()
    
    -- des
    local serverTxt = ccui.Text:create()
    serverTxt:setFontName(UIUtils.ttfName)
    serverTxt:setFontSize(16)
    serverTxt:setColor(cc.c4b(255,252,0,255))
    serverTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    local serverLab = self._leagueModel:getServerName(userInfo.sec) or ""
    serverTxt:setString("" .. serverLab)
    serverTxt:setAnchorPoint(0,0.5)
    serverTxt:setPosition(centerX+320,centerY-185)
    shareLayer:addChild(serverTxt)

    -- name
    local nameTxt = ccui.Text:create()
    nameTxt:setFontName(UIUtils.ttfName)
    nameTxt:setFontSize(20)
    nameTxt:setColor(cc.c4b(255,231,193,255))
    nameTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    nameTxt:setString(userInfo.name)
    nameTxt:setAnchorPoint(0,0.5)
    nameTxt:setPosition(centerX+320,centerY-208)
    shareLayer:addChild(nameTxt)

    -- score
    local uScore = ccui.Text:create()
    uScore:setFontName(UIUtils.ttfName)
    uScore:setFontSize(20)
    uScore:setColor(cc.c4b(255,252,0,255))
    uScore:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    uScore:setString(self._userScore .. "秒")
    uScore:setAnchorPoint(0,0.5)
    uScore:setPosition(centerX+320,centerY-250)
    shareLayer:addChild(uScore)

    -- 头像 （放最后，防止有遮罩的时候名称等信息看不见）
    local icon = IconUtils:createHeadIconById({avatar = userInfo.avatar,tp = 4, isSelf = true, eventStyle=0})   --,tp = 2
    -- icon:setScale(0.6)
    icon:setPosition(centerX+220,centerY-262)
    shareLayer:addChild(icon)


end

function ShareBaseView:onDestroy()
    ShareBaseView.super.onDestroy(self)
end

function ShareBaseView:getShareBgName()
    return "asset/bg/share/share_train_01.jpg"
end

function ShareBaseView:getInfoPosition()
    return nil, nil
end

function ShareBaseView:getShareId()
    return 13
end
