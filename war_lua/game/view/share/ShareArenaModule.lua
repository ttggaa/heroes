--[[
    Filename:    ShareArenaModule.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-02-02 14:42:52
    Description: File description
--]]

local ShareBaseView = require("game.view.share.ShareBaseView")

--[[
    云中称通关分享
    data
        排名 rank
        战斗力 score
        层 floor
        关 stage
--]]

function ShareBaseView:onDestroy()
    local tc = cc.Director:getInstance():getTextureCache()
    local resList = self._resList
    if resList then
        for i = 1, #resList do
            tc:removeTextureForKey(resList[i])
        end
    end

    ShareBaseView.super.onDestroy(self)
end

function ShareBaseView:updateModuleView(data)
    local shareLayer = self:getShareLayer()

    local centerX, centerY = shareLayer:getContentSize().width * 0.5, shareLayer:getContentSize().height * 0.5

    resList = {}
    local pic = "asset/bg/share_arena.png"
    resList[#resList + 1] = pic
    local mask = cc.Sprite:create(pic)
    mask:setPosition(centerX, centerY)
    mask:setScale(1.1111)
    shareLayer:addChild(mask, 9999)

    local pic = "asset/bg/logo.png"
    resList[#resList + 1] = pic
    local logo = cc.Sprite:create(pic)
    logo:setPosition(130, 560)
    logo:setScale(0.6)
    shareLayer:addChild(logo, 10000)
    
    self._curRank = data.rank
    local rank = cc.Label:createWithTTF(data.rank, UIUtils.ttfName, 70)
    rank:setColor(cc.c3b(255, 224, 5))
    rank:setPosition(706, 136)
    rank:setAnchorPoint(0, 0.5)
    shareLayer:addChild(rank, 10001)

    local formationModel = self._modelMgr:getModel("FormationModel")
    local formationData = formationModel:getFormationDataByType(2)
    dump(formationData)

    local heroD = tab:Hero(formationData.heroId)
    local pic = "asset/uiother/shero/"..heroD.shero..".png"
    resList[#resList + 1] = pic
    local hero = cc.Sprite:create(pic)
    hero:setScale(0.55)
    hero:setPosition(204, 442)
    shareLayer:addChild(hero)

    local teamD, team, pos
    local posTab = 
    {
        {458, 490, 0.30}, {560, 490, 0.30}, {660, 490, 0.30}, {760, 490, 0.30},
        {450, 410, 0.34}, {562, 410, 0.34}, {672, 410, 0.34}, {780, 410, 0.34},
        {446, 315, 0.38}, {565, 315, 0.38}, {691, 315, 0.38}, {810, 315, 0.38},
        {438, 200, 0.45}, {570, 200, 0.45}, {710, 200, 0.45}, {846, 200, 0.45},
    }
    -- dump(formationData)
    for i = 1, 8 do
        if formationData["team"..i] ~= 0 then
            teamD = tab.team[formationData["team"..i]]
            local pic = "asset/uiother/steam/" .. teamD.steam .. ".png"
            resList[#resList + 1] = pic 
            team = cc.Sprite:create(pic)
            team:setAnchorPoint(0.5, 0.1)
            
            pos = formationData["g"..i]
            team:setPosition(posTab[pos][1], posTab[pos][2])
            team:setScale(posTab[pos][3])
            team:setLocalZOrder(pos)
            shareLayer:addChild(team)
        end
    end

    self._resList = resList
end

function ShareBaseView:getShareBgName()
    return "asset/bg/share/share_arena.jpg"
end

function ShareBaseView:getInfoPosition()
    return 846, 510
end

function ShareBaseView:getShareId()
    return 6
end

function ShareBaseView:getMonitorContent()
    return self._curRank
end
