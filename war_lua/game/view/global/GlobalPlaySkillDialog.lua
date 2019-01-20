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
    self._effectType = param.effectType or 0
    self._param = param.effectParam or {}
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
        self:createSkillAnimWithClip()

        if self._effectType == 1 then
            if self._clipNode ~= nil then
                if self._param[1] then
                    local upperMc = mcMgr:createViewMC(self._param[1], true)
                    if upperMc then
                        upperMc:setPosition(0, self._skillBg:getContentSize().height)
                        self._clipNode:addChild(upperMc, 3)
                    end
                end
                if self._param[2] then
                    local lowerMc = mcMgr:createViewMC(self._param[2], true)
                    if lowerMc then
                        lowerMc:setPosition(0, self._skillBg:getContentSize().height)
                        self._clipNode:addChild(lowerMc, 1)
                    end
                end
            end
             
        end

    end

    local titleLabel = self:getUI("bg.titleLabel")
    titleLabel:setString(self._teamName or "")

    local skillDes = self:getUI("bg.skillDes")
    skillDes:setString(lang("specialdes1_" .. self._teamId))

    local skillDes2 = self:getUI("bg.skillDes2")
    skillDes2:setString(lang("specialdes2_" .. self._teamId))
    
end

function GlobalPlaySkillDialog:createSkillAnimWithClip()
    local posX, posY = 0, self._skillBg:getContentSize().height
    if self._teamId == 609 then
        posY = posY - 5
    end
    local mc = mcMgr:createViewMC(self._mcName, true)
    mc:setPosition(posX, posY)
    local clipNode = cc.ClippingNode:create()
    clipNode:setPosition(0, 0)
    -- self._skillBg:addChild(mc, 12)
    local mask = cc.Scale9Sprite:createWithSpriteFrameName("globalImageUI_select_bg.png")
    mask:setContentSize(653, 258)
    mask:setCapInsets(cc.rect(10, 10, 1, 1))
    mask:setAnchorPoint(cc.p(0.5, 0.5))
    mask:setPosition(327, 129)
    clipNode:setStencil(mask)
    clipNode:setAlphaThreshold(0.05)
    clipNode:setCascadeOpacityEnabled(true)
    clipNode:setInverted(false)
    clipNode:addChild(mc, 2)
    self._clipNode = clipNode
    self._skillBg:addChild(clipNode)
end

return GlobalPlaySkillDialog