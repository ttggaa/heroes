--[[
 	@FileName 	TeamExclusiveNode.lua
	@Authors 	yuxiaojing
	@Date    	2018-08-15 14:50:50
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local TeamExclusiveNode = class("TeamExclusiveNode", BaseLayer)

function TeamExclusiveNode:ctor(param)
    TeamExclusiveNode.super.ctor(self)
end

function TeamExclusiveNode:onInit()
	self._teamModel = self._modelMgr:getModel("TeamModel")

	local btn_upgrade = self:getUI("bg.btn_upgrade")
	self:registerClickEvent(btn_upgrade, function (  )
		self._viewMgr:showDialog("team.TeamExclusiveUpView", {selectTag = 1, teamData = self._curSelectTeam})
	end)

	local btn_awake = self:getUI("bg.btn_awake")
	self:registerClickEvent(btn_awake, function (  )
		self._viewMgr:showDialog("team.TeamExclusiveUpView", {selectTag = 2, teamData = self._curSelectTeam})
	end)

	local btn_upstar = self:getUI("bg.btn_upstar")
	self:registerClickEvent(btn_upstar, function (  )
		self._viewMgr:showDialog("team.TeamExclusiveUpView", {selectTag = 2, teamData = self._curSelectTeam})
	end)
end

function TeamExclusiveNode:reflashUI(data)
	if not data then return end
	self._curSelectTeam = data.teamData
	if not self._curSelectTeam then return end

	self._exclusiveData = tab.exclusive[self._curSelectTeam.teamId]

	local level = self._curSelectTeam.zLv or 0
	local starLv = (self._curSelectTeam.zStar or 0) - 1
	local qualityType = self._exclusiveData.type or 1
	local nameLab = self:getUI("bg.name")
	nameLab:setString("Lv." .. level .. " " .. lang(self._exclusiveData.name))
	nameLab:setColor(TeamUtils.exclusiveNameColorTab[qualityType].color)
	nameLab:enable2Color(1, TeamUtils.exclusiveNameColorTab[qualityType].color2)

	local btn_awake = self:getUI("bg.btn_awake")
	local btn_upstar = self:getUI("bg.btn_upstar")
	local starBg = self:getUI("bg.star_bg")
	local icon_bg = self:getUI("bg.icon")
	local artName = self._exclusiveData.art1 or "pic_artifact_30"
	local offset = self._exclusiveData.position or {}
	local offset1 = self._exclusiveData.position1 or {}
	if starLv < 0 then
		btn_awake:setVisible(true)
		btn_upstar:setVisible(false)
		starBg:setVisible(false)
	else
		btn_awake:setVisible(false)
		btn_upstar:setVisible(true)
		starBg:setVisible(true)
		for i = 1, 6 do
			starBg:getChildByFullName("star" .. i):loadTexture(i <= starLv and "globalImageUI6_star3.png" or "globalImageUI6_star4.png", 1)
		end
		artName = self._exclusiveData.art2 or "pic_artifact_31"
	end
	local artImg = icon_bg:getChildByFullName("artImg")
	if artImg then
		artImg:removeFromParent()
	end
	if starLv < 0 then
		local artName = self._exclusiveData.art1 or "pic_artifact_30"
		artImg = ccui.ImageView:create()
		artImg:setName("artImg")
		artImg:setPosition(icon_bg:getContentSize().width / 2 + (offset[1] or 0) - 5, icon_bg:getContentSize().height / 2 + 20 + (offset[2] or 0))
		artImg:loadTexture(artName .. ".png", 1)
		artImg:setScale(offset[3] or 1)
		icon_bg:addChild(artImg)
	else
		artImg = mcMgr:createViewMC(self._exclusiveData.art2, true, false)
		artImg:setPosition(icon_bg:getContentSize().width / 2 + (offset1[1] or 0) - 5, icon_bg:getContentSize().height / 2 + 20 + (offset1[2] or 0))
		artImg:setName("artImg")
		artImg:setScale(offset1[3] or 1)
		icon_bg:addChild(artImg)
	end

	icon_bg:stopAllActions()
	icon_bg:setPosition(179, 156)
	local moveUp = cc.MoveBy:create(1.5, cc.p(0, 8))
    local moveDown = cc.MoveBy:create(1.5, cc.p(0, -8))
    local seq = cc.Sequence:create(moveUp, moveDown)
    local repeateMove = cc.RepeatForever:create(seq)
    icon_bg:runAction(repeateMove)
end

return TeamExclusiveNode