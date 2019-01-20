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
    local sysTeam = tab:Team(self._data.teamId)
    if sysTeam == nil then return end
    local shareH5Id = sysTeam.id
    if sysTeam.shareUrl ~= nil and sysTeam.shareUrl ~= "" then 
        shareH5Id = sysTeam.shareUrl
    end
    self._messageAction = "MESSAGE_ACTION_JUMP_H5_1#tid=" .. shareH5Id

    --特效添加  by wangyan
    local effectId = {
        [109] = "fenxiangtushenpanguan_fenxiangtushenpanguan",
        [609] = "kuileilongfenxiangtu_kuileilongfenxiangtu",
        [9907] = "haihoufenxiangtutexiao_haihoufenxiangtu",
        [309] = "sishenfenxiangtu_sishenfenxiangtu",
        [709] = "xiemonvfenxiangtu_xiemonvfenxiangtu",
        [209] = "tanglangfenxiangtu_tanglangfenxiangtu",
    }
    
    local shareBg = self:getShareLayer():getChildByName("share_bg")
    local posX, posY = shareBg:getContentSize().width * 0.5, shareBg:getContentSize().height * 0.5
    local effectPos = {
        [9907] = cc.p(shareBg:getContentSize().width * 0.5 - 15, shareBg:getContentSize().height * 0.5 - 15)
    }
    for i,v in pairs(effectId) do
        if i == sysTeam.id then
            local anim = mcMgr:createViewMC(v, true, false)
            anim:setPosition(posX, posY)
            if effectPos[i] then
                anim:setPosition(effectPos[i])
            end
            anim:setCascadeOpacityEnabled(true)
            
            local clipNode = cc.ClippingNode:create()
            clipNode:setPosition(0, 0)
            local mask = cc.Scale9Sprite:createWithSpriteFrameName("globalImageUI_select_bg.png")
            mask:setContentSize(cc.size(posX * 2, posY * 2))
            mask:setCapInsets(cc.rect(11, 11, 1, 1))
            mask:setPosition(posX, posY)
            clipNode:setStencil(mask)
            clipNode:setAlphaThreshold(0.05)
            clipNode:setCascadeOpacityEnabled(true)
            -- clipNode:setInverted(true)
            clipNode:addChild(anim)
            shareBg:addChild(clipNode)
          
            break
        end
    end
end

function ShareBaseView:getShareBgName()
    if self._data.teamId == nil then return "" end

    local teamId = self._data.teamId
    local teamData = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(teamId) or {}
    if teamData.sId then
        local sysSkinData = tab.teamSkin[teamData.sId]
        if sysSkinData.skinget == 1 then
            return "asset/bg/share/share_team_" .. teamId .. ".jpg"
        elseif sysSkinData.skinget == 2 then
            return "asset/bg/share/share_teamjx_" .. teamId .. ".jpg"
        else  
            --此处预留运营活动皮肤                  
        end
    end
    
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