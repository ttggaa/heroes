--[[
    Filename:    ShareLeagueUpstageModule.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-02-02 14:42:52
    Description: File description
--]]

local ShareBaseView = require("game.view.share.ShareBaseView")

--[[
    积分联赛晋升分享
    data
        段位 stage
--]]

function ShareBaseView:updateModuleView(data)
    local shareLayer = self:getShareLayer()

    local centerX, centerY = shareLayer:getContentSize().width * 0.5, shareLayer:getContentSize().height * 0.5

    local leagueRankD = tab:LeagueRank(data.stage)

    local icon = cc.Sprite:createWithSpriteFrameName(leagueRankD["icon"]..".png")
    icon:setPosition(centerX, centerY + 96)
    shareLayer:addChild(icon)

    local stage = cc.Sprite:createWithSpriteFrameName("zone" .. data.stage .. "_league.png")
    stage:setPosition(centerX, centerY - 155)
    shareLayer:addChild(stage)


    local label = cc.Label:createWithTTF("领主大人", UIUtils.ttfName_Title, 26)
    label:setColor(cc.c3b(252, 236, 177))
    label:setPosition(centerX, 258)
    shareLayer:addChild(label)

    local icon = cc.Sprite:createWithSpriteFrameName("leagueStart_docImg.png")
    icon:setScale(0.6)
    icon:setPosition(centerX - 75, 258)
    shareLayer:addChild(icon)

    local icon = cc.Sprite:createWithSpriteFrameName("leagueStart_docImg.png")
    icon:setScale(-0.6, 0.6)
    icon:setPosition(centerX + 75, 258)
    shareLayer:addChild(icon)

    local label = cc.Label:createWithTTF("祝贺您晋升为", UIUtils.ttfName_Title, 32)
    label:setColor(cc.c3b(252, 236, 177))
    label:setPosition(centerX, 226)
    shareLayer:addChild(label)

    local label = cc.Label:createWithTTF("愿您在埃拉西亚百战百胜", UIUtils.ttfName_Title, 34)
    label:setColor(cc.c3b(252, 236, 177))
    label:setPosition(centerX, 106)
    shareLayer:addChild(label)
end

function ShareBaseView:getShareBgName()
    return "asset/bg/share/share_league.jpg"
end

function ShareBaseView:getInfoPosition()
    return 846, 20
end

function ShareBaseView:getShareId()
    return 4
end