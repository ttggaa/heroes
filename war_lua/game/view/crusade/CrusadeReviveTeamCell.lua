--[[
    Filename:    CrusadeReviveTeamCell.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-12-03 18:05:42
    Description: File description
--]]

local CrusadeReviveTeamCell = class("CrusadeReviveTeamCell", BaseLayer)


function CrusadeReviveTeamCell:ctor()
    CrusadeReviveTeamCell.super.ctor(self)
end


function CrusadeReviveTeamCell:onInit()
	self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
    end)
    local bg = self:getUI("bg")
    self:setContentSize(bg:getContentSize().width, bg:getContentSize().height)
end

function CrusadeReviveTeamCell:reflashUI(data)
    CrusadeReviveTeamCell.super.reflashUI(self)
    
	self._callback = data.callback
	local formationModel = self._modelMgr:getModel("FormationModel")
    local formationData = formationModel:getFormationDataByType(formationModel.kFormationTypeCrusade)
    -- dump(formationData)
    local sysTeam = tab:Team(data.teamId)
    
    local teamModel = self._modelMgr:getModel("TeamModel")
    local teamD = teamModel:getTeamAndIndexById(data.teamId)
    local backQuality = teamModel:getTeamQualityByStage(teamD.stage)
    local icon = IconUtils:createTeamIconById({teamData = teamD, sysTeamData = sysTeam,
                                                quality = backQuality[1] , quaAddition = backQuality[2],  
                                                isGray = true, eventStyle = 0})

    -- local icon = IconUtils:createSysTeamIconById({sysTeamData = sysTeam, isGray = true ,eventStyle = 0})
    local iconPanel = self:getUI("bg.iconPanel")
    icon:setPosition(iconPanel:getContentSize().width/2, iconPanel:getContentSize().height/2)
    icon:setAnchorPoint(0.5, 0.5)
    iconPanel:addChild(icon)

    local dieTip = cc.Sprite:createWithSpriteFrameName("globalImageUI4_dead.png")
    dieTip:setPosition(icon:getContentSize().width/2,icon:getContentSize().height/2)
    icon:addChild(dieTip, 100)

    local nameLab = self:getUI("bg.nameLab")
    nameLab:setString(lang(sysTeam.name))
    nameLab:setPosition(icon:getContentSize().width/2 - 3, icon:getContentSize().height + 15)

	self:registerClickEventByName("bg",function() 
		if self._callback ~= nil  then 
			self._callback()
		end
	end)
end

return CrusadeReviveTeamCell