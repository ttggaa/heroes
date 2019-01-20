--[[
    Filename:    GuildMapEquipTipView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-04-07 17:56:44
    Description: File description
--]]

local GuildMapEquipTipView = class("GuildMapEquipTipView", BaseLayer)
function GuildMapEquipTipView:ctor(params)
    GuildMapEquipTipView.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
    self._Atts = {}
end

function GuildMapEquipTipView:onInit()
    self._bg = self:getUI("bg")
    self._attrPanel    = self:getUI("bg.attrPanel")
    self._basePanel    = self:getUI("bg.basePanel")
    self._equipImg  = self:getUI("bg.basePanel.equipImg")
    self._nameLab      = self:getUI("bg.basePanel.nameLab")
    self._bgW = 400
end

function GuildMapEquipTipView:setAttrs(id)
    self._curComData = tab.guildEquipment[id]

    self._nameLab:setString(lang(self._curComData.name))
    self._equipImg:loadTexture(self._curComData.art .. ".png", 1)

    if #self._curComData.arrt <= 0 then 
        local attrPanel = self:getUI("bg.attrPanel")
        attrPanel:setVisible(false)
        return
    end
    -- level 
    local lv = self._userModel:getPlayerLevel() or 20
    local arrt = self._curComData.arrt
    local lowLevel = 0
    local highLevel = 0
    local lvlArr = {}
    local leftEquipAttr = {}--self._curComData.arrt[1]    
    local rightEquipAttr = {}--self._curComData.arrt[2]
    for k,v in pairs(arrt) do
        lvlArr = v[1]
        lowLevel = lvlArr[1]
        highLevel = lvlArr[2]
        if lowLevel <= lv and lv <= highLevel then
            leftEquipAttr = v[2][1]
            rightEquipAttr = v[2][2]
            break
        end
    end

    local leftTipLab = self:getUI("bg.attrPanel.leftTipLab")
    leftTipLab:setString(lang("SHOW_ATTR_" .. leftEquipAttr[1]))
    
    local leftLab = self:getUI("bg.attrPanel.leftLab")
    leftLab:setString("+" .. leftEquipAttr[2])
    leftLab:setColor(UIUtils.colorTable.ccUIBaseColor2)

    
    if not rightEquipAttr then return end


    local rightTipLab = self:getUI("bg.attrPanel.rightTipLab")
    rightTipLab:setString(lang("SHOW_ATTR_" .. rightEquipAttr[1]))

    local rightLab = self:getUI("bg.attrPanel.rightLab")
    rightLab:setString("+" .. rightEquipAttr[2])
    rightLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
end


return GuildMapEquipTipView