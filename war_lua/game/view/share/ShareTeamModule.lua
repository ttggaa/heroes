--[[
    Filename:    ShareTeamModule.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-01-22 14:42:52
    Description: File description
--]]

local ShareBaseView = require("game.view.share.ShareBaseView")

function ShareBaseView:transferData(data)
    self._data = data
end


function ShareBaseView:updateModuleView()
    -- local sysTeam = tab:Team(self._data.teamId)
    -- local shareLayer = self:getShareLayer()
    -- local labTeamDes = UIUtils:createMultiLineLabel(
    --         {
    --         text = lang(sysTeam.sharedsc), 
    --         color = cc.c3b(255, 255, 255), 
    --         width = 400,
    --         fontsize = 24,
    --         fontname = UIUtils.ttfName,
    --         })
    -- labTeamDes:setAnchorPoint(0, 1)
    -- labTeamDes:setPosition(45, 365) 
    -- shareLayer:addChild(labTeamDes)
    local sysTeam = tab:Team(self._data.teamId)
    if sysTeam == nil then return end
    local shareH5Id = sysTeam.id
    if sysTeam.shareUrl ~= nil and sysTeam.shareUrl ~= "" then 
        shareH5Id = sysTeam.shareUrl
    end
    self._messageAction = "MESSAGE_ACTION_JUMP_H5_1#tid=" .. shareH5Id
end

function ShareBaseView:getShareBgName()
    if self._data.teamId == nil then return "" end

    local teamId = self._data.teamId
    local teamData = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(teamId)
    local isJX = TeamUtils:getTeamAwaking(teamData)
    if isJX then
        return "asset/bg/share/share_teamjx_" .. teamId .. ".jpg"
    else
        return "asset/bg/share/share_team_" .. teamId .. ".jpg"
    end
    
end

function ShareBaseView:getShareId()
    return 2
end

function ShareBaseView:getMonitorContent()
    return self._data.teamId
end