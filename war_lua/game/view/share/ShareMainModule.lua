--[[
    Filename:    ShareMainModule.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-02-02 14:42:52
    Description: File description
--]]

local ShareBaseView = require("game.view.share.ShareBaseView")

--[[ 
	主界面分享
--]]
function ShareBaseView:updateModuleView(data)
    local shareLayer = self:getShareLayer()
    local centerX, centerY = shareLayer:getContentSize().width * 0.5, shareLayer:getContentSize().height * 0.5
    local userData = self._modelMgr:getModel("UserModel"):getData()

    local name = ccui.Text:create()
    name:setString(userData.name or "")
    name:setColor(UIUtils.colorTable.ccUIMenuBtnColor1)
    name:enable2Color(1, UIUtils.colorTable.ccUIMenuBtnColor2)
    name:setFontName(UIUtils.ttfName)
    name:setFontSize(24)
    name:setPosition(centerX, 56)
    shareLayer:addChild(name)

    local serverName = self._modelMgr:getModel("LeagueModel"):getServerName(userData.sec) or ""
    local name2 = ccui.Text:create()
    name2:setString(serverName)
    name2:setColor(UIUtils.colorTable.ccUIMenuBtnColor1)
    name2:enable2Color(1, UIUtils.colorTable.ccUIMenuBtnColor2)
    name2:setFontName(UIUtils.ttfName)
    name2:setFontSize(24)
    name2:setPosition(centerX, 22)
    shareLayer:addChild(name2)
end

function ShareBaseView:getShareBgName()
    return "asset/bg/share/share_mainUser.jpg"
end

function ShareBaseView:getShareId()
    return 9
end