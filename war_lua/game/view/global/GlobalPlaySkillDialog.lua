--
-- Author: huangguofang
-- Date: 2017-05-20 04:02:10
--
local GlobalPlaySkillDialog = class("GlobalPlaySkillDialog",BasePopView)

function GlobalPlaySkillDialog:ctor(param)
    self.super.ctor(self)
    self._mcName = param.mcName
    self._bgImg = param.bgImg
    self._teamId = param.teamId or 0
    self._teamName = param.teamName 
end

function GlobalPlaySkillDialog:onInit()
    self.super.onInit(self)

    self:registerClickEvent(self:getUI("touchPanel"), function ( )
        self:close()
         UIUtils:reloadLuaFile("global.GlobalPlaySkillDialog")
    end)

	self._skillBg = self:getUI("bg.skillBg")
    if self._bgImg then
	    self._skillBg:loadTexture("asset/bg/" .. self._bgImg)
	end

	if self._mcName then
		local mc = mcMgr:createViewMC(self._mcName, true)
        mc:setName("mc")
        mc:setPosition(0, self._skillBg:getContentSize().height)
        self._skillBg:addChild(mc)
    end

    local titleLabel = self:getUI("bg.titleLabel")
    titleLabel:setString(self._teamName or "")

    local skillDes = self:getUI("bg.skillDes")
    skillDes:setString(lang("specialdes1_" .. self._teamId))

    local skillDes2 = self:getUI("bg.skillDes2")
    skillDes2:setString(lang("specialdes2_" .. self._teamId))
    
end

function GlobalPlaySkillDialog:reflashUI(data)
  
end

return GlobalPlaySkillDialog