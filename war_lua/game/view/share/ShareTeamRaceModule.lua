--[[
    Filename:    ShareTeamRaceModule.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-02-14 21:11:18
    Description: File description
--]]

local ShareBaseView = require("game.view.share.ShareBaseView")

-- function ShareBaseView:transferData(data)
--     local tempRaceData = {101, 102, 104, 103, 105, 106}
--     print("data.raceId================", data.raceId)
--     self._raceId = tempRaceData[data.raceId] 
-- end

function ShareBaseView:transferData(data)
    local tempRaceData1 = {101, 102, 104, 103, 105, 106, 107, 108, 109}
    local tempRaceData2 = {
        [101] = 101, [102] = 102, [104] = 104, [103] = 103, 
        [105] = 105, [106] = 106, [107] = 107, [108] = 108, [109] = 109}
    if data.raceId ~= nil then
        self._raceId = tempRaceData1[data.raceId]
    elseif data.race ~= nil then
        self._raceId = tempRaceData2[data.race]
    end
end

function ShareBaseView:updateModuleView()
    local shareBg = self:getShareLayer():getChildByName("share_bg")
    local teamModel = self._modelMgr:getModel("TeamModel")
    local sysRaceTeams = {}
    sysRaceTeams[101] = {101, 102, 103, 104, 105, 106, 107}
    sysRaceTeams[102] = {201, 202, 203, 204, 205, 206, 207}
    sysRaceTeams[103] = {401, 402, 403, 404, 405, 406, 407}
    sysRaceTeams[104] = {301, 302, 303, 304, 305, 306, 307}
    sysRaceTeams[105] = {501, 502, 503, 504, 505, 506, 507}
    sysRaceTeams[106] = {601, 602, 603, 604, 605, 606, 607}
    sysRaceTeams[107] = {701, 702, 703, 704, 705, 706, 707}
    sysRaceTeams[108] = {801, 802, 803, 804, 805, 806, 807}
    sysRaceTeams[109] = {901, 902, 903, 904, 905, 906, 907}

    local niubility = {[203] = 1, [205] = 1}
    local userRaceTeams = teamModel:getTeamWithRace(self._raceId)
    if userRaceTeams == nil  then userRaceTeams = {} end
    local userRaceTeamKeys = {}
    for k,v in pairs(userRaceTeams) do
        if v.class == nil then
            userRaceTeamKeys[v.teamId] = 1
        end
    end

    local x, y = shareBg:getContentSize().width * 0.5, shareBg:getContentSize().height * 0.5
    for k,v in pairs(sysRaceTeams[self._raceId]) do
        if userRaceTeamKeys[v] == nil then 
            local tempSprite = cc.Sprite:createWithSpriteFrameName("plist_share_race_team_" .. v .. ".png")
            tempSprite:setPosition(x, y)
            shareBg:addChild(tempSprite)
            if niubility[v] ~= nil then 
                local tempSprite = cc.Sprite:createWithSpriteFrameName("plist_share_race_team_nb_" .. v .. ".png")
                tempSprite:setPosition(x, y)
                shareBg:addChild(tempSprite)
            end
        end
    end
end

function ShareBaseView:onDestroy()
    if self._plistName ~= nil then 
        cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("asset/uiother/share/" .. self._plistName .. ".plist")
        cc.Director:getInstance():getTextureCache():removeTextureForKey("asset/uiother/share/" .. self._plistName .. ".png")
    end
    ShareBaseView.super.onDestroy(self)
end

function ShareBaseView:getShareBgName()
    local plistGroups = {}
    plistGroups[101] = "share_group_1"
    plistGroups[102] = "share_group_1"
    plistGroups[103] = "share_group_1"
    plistGroups[104] = "share_group_2"
    plistGroups[105] = "share_group_2"
    plistGroups[106] = "share_group_3"
    plistGroups[107] = "share_group_4"
    plistGroups[108] = "share_group_4"
    plistGroups[109] = "share_group_3"
    self._plistName = plistGroups[self._raceId]
    
    cc.SpriteFrameCache:getInstance():addSpriteFrames("asset/uiother/share/" .. self._plistName .. ".plist", "asset/uiother/share/" .. self._plistName .. ".png")
    return "asset/bg/share/share_team_race_" .. self._raceId .. ".jpg"
end

function ShareBaseView:getShareId()
    return 12
end

function ShareBaseView:getMonitorContent()
    return self._raceId
end