--[[
    Filename:    RankWeaponsDetailView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-09-22 20:25:28
    Description: File description
--]]

local RankWeaponsDetailView = class("RankWeaponsDetailView", BasePopView)
function RankWeaponsDetailView:ctor(params)
    self.super.ctor(self)
end
function RankWeaponsDetailView:getAsyncRes()
    return 
    {
        {"asset/ui/arena1.plist", "asset/ui/arena1.png"},
    }
end
-- 初始化UI后会调用, 有需要请覆盖
function RankWeaponsDetailView:onInit()
    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function()
        self.dontRemoveRes = true
        self:close()
        UIUtils:reloadLuaFile("rank.RankWeaponsDetailView")
    end)

    self._title = self:getUI("bg.layer.titleBg.title")
    UIUtils:setTitleFormat(self._title, 1)
    self._weaponsModel = self._modelMgr:getModel("WeaponsModel")

    local label_title1 = self:getUI("bg.rightLayer.panel1.label_title")
    UIUtils:setTitleFormat(label_title1, 3)
    local label_title2 = self:getUI("bg.rightLayer.panel2.label_title")
    UIUtils:setTitleFormat(label_title2, 3)
    local label_title3 = self:getUI("bg.rightLayer.panel3.label_title")
    UIUtils:setTitleFormat(label_title3, 3)

    
    local leftLayer = self:getUI("bg.leftLayer")
    self._zhandouliLab = cc.LabelBMFont:create("", UIUtils.bmfName_zhandouli_little)
    self._zhandouliLab:setName("zhandouli")
    self._zhandouliLab:setAnchorPoint(0.5,0.5)
    self._zhandouliLab:setScale(0.6)
    self._zhandouliLab:setPosition(135, 104)
    leftLayer:addChild(self._zhandouliLab, 100)

    -- left layer
    self._wname = self:getUI("bg.leftLayer.nameBg.wname")
    self._wname:setFontName(UIUtils.ttfName)
    self._wname:setColor(UIUtils.colorTable.ccUIBaseColor1)
    self._wname:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    self._weaponImg = self:getUI("bg.leftLayer.layer_body.image_body_bottom")
    self._weaponImg:setVisible(false)
    self._weaponImg = self:getUI("bg.leftLayer.layer_body.team_img")
end



-- 接收自定义消息
function RankWeaponsDetailView:reflashUI(data)
    self._userWeaponData = data.userWeapon
    self._weaponId = data.weaponId
    self._weaponType = data.weaponType or 1
    dump(data)
    self:updateRightPanel()
    self:updateLeftPanel()

end

function RankWeaponsDetailView:updateLeftPanel()

    -- local quality = self._teamModel:getTeamQualityByStage(self._teamData.stage)
    -- self._wname:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
    -- self._wname:setString(lang(teamName) .. (0 == quality[2] and "" or  "+" .. quality[2]))
    local weaponsTab = tab:SiegeWeapon(self._weaponId)
    local nameStr = lang(weaponsTab.name)
    self._wname:setString(nameStr)

    local fileName = "asset/uiother/weapon/" .. weaponsTab.art .. ".png"
    self._weaponImg:loadTexture(fileName, 0)
    -- self._teamImg:loadTexture("asset/uiother/steam/" .. steam .. ".png")
    -- self._teamImg:setScale(0.8)

    local weaponType = self:getUI("bg.leftLayer.nameBg.weaponType")
    weaponType:setScale(1.1)
    weaponType:loadTexture("qx_weapontype_" .. self._weaponType .. ".png", 1)

    local weaponData = self._userWeaponData
    local score = 0
    if weaponData and weaponData["unlockIds"] then
        local wScore = weaponData["unlockIds"][tostring(self._weaponId)]
        if not wScore then
            wScore = weaponData["unlockIds"][tonumber(self._weaponId)]
        end
        score = wScore or 0
    end
    for i=1,4 do
        local sp = weaponData["sp" .. i]
        if sp and sp.score then
            score = score + sp.score
        end
    end
    self._zhandouliLab:setString("a" .. score)

    local image_body_bottom = self:getUI("bg.leftLayer.layer_body.image_body_bottom")
    if image_body_bottom then
        image_body_bottom:loadTexture("arenaMain_heroBg5.png", 1)
    end
end


function RankWeaponsDetailView:updateRightPanel()
    self:updateAttr()
    self:updateEquiptList()
    self:updateSkill()
end

function RankWeaponsDetailView:updateAttr()
    local baseAttr = self:getAttrData()
    dump(baseAttr)
    local attr = self._weaponsModel:getAttrValue(baseAttr)
    dump(attr)
    local labTip1 = self:getUI("bg.rightLayer.panel1.labTip1")
    local labTip2 = self:getUI("bg.rightLayer.panel1.labTip2")
    local labTip3 = self:getUI("bg.rightLayer.panel1.labTip3")
    labTip1:setString(lang("SIEGEWEAPONT_1") .. ":")
    labTip2:setString(lang("SIEGEWEAPONT_2") .. ":")
    labTip3:setString(lang("SIEGEWEAPONT_3") .. ":")

    local labelValue1 = self:getUI("bg.rightLayer.panel1.labelValue1")
    local value = TeamUtils.getNatureNums(attr[1])
    labelValue1:setString(value)

    local labelValue2 = self:getUI("bg.rightLayer.panel1.labelValue2")
    local value = TeamUtils.getNatureNums(attr[2])
    labelValue2:setString(value)

    local labelValue3 = self:getUI("bg.rightLayer.panel1.labelValue3")
    local value = TeamUtils.getNatureNums(attr[3])
    labelValue3:setString(value)
    self._attr = attr
end

function RankWeaponsDetailView:getAttrData()
    local attr = {}
    for i=1,6 do
        attr[i] = 0
    end
    local wattrData = self:getWeaponsAttr()
    for key=1,6 do
        attr[key] = attr[key] + wattrData[key]
    end
    local weaponTypeData = self._userWeaponData
    for i=1,4 do
        local propId = weaponTypeData["sp" .. i].id
        if propId then
            local attrData = self:getPropsAttr(i)
            for key=1,6 do
                attr[key] = attr[key] + attrData[key]
            end
        end
    end
    return attr
end



function RankWeaponsDetailView:getWeaponsAttr()
    -- local weaponsId = 1
    local attr = {}
    for i=1,6 do
        attr[i] = 0
    end
    local weaponsData = self._userWeaponData
    local weaponsId = self._weaponId
    if not weaponsData then
        return attr
    end
    local weaponsLevel = weaponsData.lv
    local weaponsTab = tab:SiegeWeapon(weaponsId)
    local intproperty = weaponsTab.intproperty
    for i=1,table.nums(intproperty) do
        local oneproperty = intproperty[i]
        local ptype = oneproperty[1]
        local pbaseattr = oneproperty[2]
        local pgrow = oneproperty[3]
        attr[ptype] = attr[ptype] + pgrow*(weaponsLevel-1) + pbaseattr
    end

    return attr 
end 


function RankWeaponsDetailView:getPropsAttr(indexId)
    local attr = {}
    for i=1,6 do
        attr[i] = 0
    end
    local weaponData = self._userWeaponData
    local propsData = weaponData["sp" .. indexId]
    if not propsData then
        return attr
    end
    local propsId = propsData.id 
    local propsLevel = propsData.lv 
    local propsTab = tab:SiegeEquip(propsId)
    local intproperty = propsTab.intproperty
    for i=1,table.nums(intproperty) do
        local oneproperty = intproperty[i]
        local ptype = oneproperty[1]
        local pbaseattr = oneproperty[2]
        local pgrow = oneproperty[3]
        attr[ptype] = attr[ptype] + pgrow*(propsLevel-1) + pbaseattr
    end
    local equipLimitLv = tab:Setting("SIEGE_EQUIP_LV").value
    for i=1,6 do
        local percent = propsTab["percent" .. i]
        if percent then
            local ptype = percent[1] + 3
            local pvalue = percent[2]
            if propsLevel >= equipLimitLv[i] then
                attr[ptype] = attr[ptype] + pvalue
            end
        end
    end
    return attr
end 


-- 装备
function RankWeaponsDetailView:updateEquiptList()
    local weaponTypeData = self._userWeaponData
    -- dump(weaponTypeData)
    -- local siegeTab = tab:SiegeWeaponType(self._selectType)
    -- local baseInfoLevelLab = self._infoNode:getChildByFullName("levelLab")
    -- baseInfoLevelLab:setString("Lv." .. level)

    -- local equipTypeTab = siegeTab.equipType
    -- for i=1,4 do
    --     local equipBg = self:getUI("bg.equipBg" .. i)
    --     local equipType = self:getUI("bg.equipBg" .. i .. ".equipType")
    --     equipType:loadTexture("weaponImageUI_propsType" .. equipTypeTab[i][2] .. ".png", 1)

    --     local propsId = weaponTypeData["sp" .. i]
    --     self:updateEquipCell(equipBg, propsId, i)
    -- end
    local equip
    for i=1,4 do
        equipBg = self:getUI("bg.rightLayer.equiptList.equipBg" .. i)
        local tpropsData = weaponTypeData["sp" .. i]
        self:updateEquipCell(equipBg, tpropsData, i)
    end
end

function RankWeaponsDetailView:updateEquipCell(inView, propsData, indexId)
    print("propsId===========", propsId, indexId)
    local propsId = propsData.id or 0
    print("propsId===========", propsId, indexId)
    local notEquip = self:getUI("bg.rightLayer.equiptList.equipBg" .. indexId .. ".notEquip")

    if (not propsId) or (propsId == 0) then
        if notEquip then
            notEquip:setVisible(true)
            -- self:registerClickEvent(notEquip, function()
            --     -- self._viewMgr:showDialog("weapons.RankWeaponsDetailView", {})
            -- end)
        end
        local propsIcon = inView.propsIcon
        if propsIcon then
            propsIcon:setVisible(false)
        end
    else
        if notEquip then
            notEquip:setVisible(false)
        end
        print("propsId==========", propsId)
        local propsTab = tab:SiegeEquip(propsId)
        local propsIcon = inView.propsIcon
        local param = {itemId = propsId, level = propsData.lv, tagShow = true, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 1}
        if not propsIcon then
            propsIcon = IconUtils:createWeaponsBagItemIcon(param)
            propsIcon:setName("propsIcon")
            propsIcon:setPosition(-2, -3)
            propsIcon:setScale(80/propsIcon:getContentSize().width)
            inView:addChild(propsIcon)
            inView.propsIcon = propsIcon
        else
            IconUtils:updateWeaponsBagItemIcon(propsIcon, param)
        end
        propsIcon:setVisible(true)
    end

    -- local siegeTab = tab:SiegeWeaponType(self._selectType)
    -- local tequipType = siegeTab.equipType[indexId][1]
    -- local equipType = self:getUI("bg.rightLayer.equiptList.equipBg" .. indexId .. ".equipType")
    -- equipType:loadTexture("weaponImageUI_propsType" .. tequipType .. ".png", 1)

    -- self:registerClickEvent(inView, function()
    --     local equipBg = self:getUI("bg.equiptList.equipBg" .. self._selectPosId)
    --     local xuanzhong = equipBg.xuanzhong
    --     if xuanzhong then
    --         xuanzhong:setVisible(false)
    --     end
    --     print("self._selectPosId=============", self._selectPosId)
    --     self._selectPosId = indexId
    --     self:updateEquipCell(inView, propsData, self._selectPosId)
    --     self:reloadData()
    -- end)
end


-- 技能展示
function RankWeaponsDetailView:updateSkill()
    local skillBg = self:getUI("bg.rightLayer.skillBg")
    local weaponsTab = tab:SiegeWeapon(self._weaponId)
    local weaponTypeData = self._userWeaponData
    local wSkill = weaponsTab.skill or {}
    for i=1,table.nums(wSkill) do
        local _skill = wSkill[i]
        local skillEffect = tab:SiegeSkillDes(_skill)
        local lock = false
        local lockSkill = weaponTypeData["ss" .. (i - 1)]
        if lockSkill and lockSkill == 0 then
            lock = true
        end
        local param = {sysSkill = skillEffect, lock = lock}
        local skillIcon = skillBg:getChildByFullName("skillIcon" .. i)
        if not skillIcon then
            skillIcon = IconUtils:createWeaponsSkillIcon(param)
            skillIcon:setName("skillIcon" .. i)
            skillIcon:setScale(0.9)
            skillIcon:setPosition(95*i-90, 0)
            skillBg:addChild(skillIcon)
        else
            IconUtils:updateWeaponsSkillIcon(skillIcon, param)
        end

        if i == 1 then
            local iconColor = ccui.ImageView:create()
            iconColor:setName("iconColor")
            iconColor:loadTexture("globalImageUI_weaponskillTip.png", 1)
            iconColor:setPosition(30, 70)
            skillBg.iconColor = iconColor
            skillBg:addChild(iconColor,1)
        end

        self:registerClickEvent(skillIcon, function()
            local attrValue = self._attr
            self:showHintView("global.GlobalTipView",{tipType = 24, node = skillIcon, attrValue=attrValue, id = _skill, posCenter = true})
        end)
    end
end




return RankWeaponsDetailView