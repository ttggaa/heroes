--[[
    Filename:    ShareTeamSkinModule.lua
    Author:      <cuiyake@playcrab.com>
    Datetime:    2018-05-08 14:22:52
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
    local teamId = self._data.teamId
    local sysTeam = tab:Team(teamId)
    if sysTeam == nil then return end
    local shareH5Id = sysTeam.id
    if sysTeam.shareUrl ~= nil and sysTeam.shareUrl ~= "" then 
        shareH5Id = sysTeam.shareUrl
    end
    self._messageAction = "MESSAGE_ACTION_JUMP_H5_1#tid=" .. shareH5Id
end

function ShareBaseView:getShareBgName()
    if self._data.skinData == nil or self._data.skinData.sharepicid == nil then return "" end
    local sharepicid = self._data.skinData.sharepicid
    return "asset/bg/share/" .. sharepicid .. ".jpg"


    -- local teamId = self._data.teamId
    -- print("========teamId============"..teamId)
    -- local teamData = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(teamId)
    -- if teamData.sId then
    --     local sysSkinData = tab.teamSkin[teamData.sId]
    --     if sysSkinData.skinget == 1 then
    --         return "asset/bg/share/share_team_" .. teamId .. ".jpg"
    --     elseif sysSkinData.skinget == 2 then
    --         return "asset/bg/share/share_teamjx_" .. teamId .. ".jpg"
    --     else  
    --         --此处预留运营活动皮肤                  
    --     end
    -- end
    
    -- local isJX = TeamUtils:getTeamAwaking(teamData)
    -- if isJX then
    --     return "asset/bg/share/share_teamjx_" .. teamId .. ".jpg"
    -- else
    --     return "asset/bg/share/share_team_" .. teamId .. ".jpg"
    -- end


end

function ShareBaseView:getShareId()
    return 17
end

function ShareBaseView:getMonitorContent()
    return self._data.teamId
end