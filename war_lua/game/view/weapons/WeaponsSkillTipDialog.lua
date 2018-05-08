--[[
    Filename:    WeaponsSkillTipDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-10-11 16:46:20
    Description: File description
--]]

local WeaponsSkillTipDialog = class("WeaponsSkillTipDialog", BasePopView)
function WeaponsSkillTipDialog:ctor()
    WeaponsSkillTipDialog.super.ctor(self)
    -- self._callback = param.callback
    self._selectItem = {}
end

function WeaponsSkillTipDialog:onInit()
    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)

    self:registerClickEventByName("bg.closeBtn", function ()
        UIUtils:reloadLuaFile("weapons.WeaponsSkillTipDialog")
        self:close()
    end)

    local determineBtn = self:getUI("bg.determineBtn")
    self:registerClickEvent(determineBtn, function()
        -- if self._callback then
        --     self._callback(self._selectItem)
        -- end
        self:close()
    end)

    self._weaponsModel = self._modelMgr:getModel("WeaponsModel")

end

function WeaponsSkillTipDialog:reflashUI(data)
    dump(data)
    local skillEffect = data.skillEffect
    local posIdx = data.posIdx
    local weaponTypeData = data.weaponTypeData
    local attValueMap = data.attrValue or {}

    local skillTitle = self:getUI("bg.skillTitle")
    skillTitle:setString(lang(skillEffect.name))

    local skillBg = self:getUI("bg.iconBg")
    local param = {sysSkill = skillEffect, lock = lock}
    local skillIcon = skillBg:getChildByFullName("skillIcon" .. posIdx)
    if not skillIcon then
        skillIcon = IconUtils:createWeaponsSkillIcon(param)
        skillIcon:setName("skillIcon" .. posIdx)
        skillIcon:setScale(0.9)
        skillIcon:setPosition(-8, 0)
        skillBg:addChild(skillIcon)
    else
        IconUtils:updateWeaponsSkillIcon(skillIcon, param)
    end

    -- 描述
    local richtextBg = self:getUI("bg.richtextBg")
    local richText = richtextBg:getChildByName("richText")
    local desc = lang(skillEffect.des1)
    desc = string.gsub(desc,"{[^}]+}",function( inStr )
        inStr = string.gsub(inStr,"{","")
        inStr = string.gsub(inStr,"}","")
        if string.find(inStr,"$atk") then
            inStr = string.gsub(inStr,"$atk",attValueMap[1] or 0)
        end
        if string.find(inStr,"$def") then
            inStr = string.gsub(inStr,"$def",attValueMap[2] or 0)
        end
        if string.find(inStr,"$int") then
            inStr = string.gsub(inStr,"$int",attValueMap[3] or 0)
        end

        if string.len(inStr) > 0 then 
            local a = "return " .. inStr
            inStr = TeamUtils.getNatureNums(loadstring(a)())
        end
        return inStr
    end)

    desc = "[color=462800]"..desc.."[-]"
    richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5)
    richText:setName("richText")
    richtextBg:addChild(richText)

    local weaponType = weaponTypeData.weaponType
    local weaponTypeTab = tab:SiegeWeaponType(weaponType)
    local limLv = 0
    if posIdx == 2 then
        limLv = weaponTypeTab["skill1Lock"]
    elseif posIdx == 3 then
        limLv = weaponTypeTab["skill1Lock1"]
    end

    local showLv = limLv*4

    local des1 = self:getUI("bg.des1")
    des1:setString("配件总等级达到" .. showLv .. "级时解锁此技能")

    local des3 = self:getUI("bg.des3")
    local currentLv = self:getCurrentLevel(weaponTypeData)
    des3:setString(currentLv .. "/" .. showLv)
end

function WeaponsSkillTipDialog:getCurrentLevel(weaponTypeData)
    local cLv = 0
    for i=1,4 do
        local sp = weaponTypeData["sp" .. i]
        if sp and sp ~= 0 then
            local propData = self._weaponsModel:getPropsDataByKey(sp)
            cLv = cLv + propData.lv or 0
        end
    end
    return cLv
end

return WeaponsSkillTipDialog