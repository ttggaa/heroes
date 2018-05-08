--[[
    Filename:    WeaponsReformNode.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-09-08 15:26:18
    Description: File description
--]]


local WeaponsReformNode = class("WeaponsReformNode", BaseLayer)

function WeaponsReformNode:ctor(param)
    WeaponsReformNode.super.ctor(self)
    self._animValue = {}
    self._fightCallback = param.fightCallback
    self._selectType = param.selectType
    self._selectWeaponId = param.selectWeaponId
end

function WeaponsReformNode:onInit()
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._weaponsModel = self._modelMgr:getModel("WeaponsModel")

    -- self._infoNode = self:getUI("bg.infoNode")
    -- self._selectPosId = self:getSelectPosId()


    local title3 = self:getUI("bg.shuxingBg.title1")
    UIUtils:adjustTitle(title3)

    local title4 = self:getUI("bg.shuxingBg.title2")
    UIUtils:adjustTitle(title4)

    local upgradeBtn = self:getUI("bg.upgradeBtn")
    self:registerClickEvent(upgradeBtn, function()
        print("强化======")
        local weaponTypeData = self._weaponsModel:getWeaponsDataByType(self._selectType)
        local selectPosId = self._selectPosId
        dump(weaponTypeData)
        if (not selectPosId) or weaponTypeData["sp" .. selectPosId] == 0 then
            selectPosId = nil 
            for i=1,4 do
                local sp = weaponTypeData["sp" .. i]
                if sp and sp ~= 0 then
                    selectPosId = i
                    break
                end
            end
        end
        if not selectPosId then
            self._viewMgr:showTip(lang("SIEGECON_TIPS18"))
            return
        end
        self._viewMgr:showDialog("weapons.WeaponsPropsView", {selectType = self._selectType, selectPosId = selectPosId})
    end)
    self._upgradeBtn = upgradeBtn

    local repleaceBtn = self:getUI("bg.repleaceBtn")
    self:registerClickEvent(repleaceBtn, function()
        if self._selectPosId then
            local equipBg = self:getUI("bg.equipBg" .. self._selectPosId)
            local xuanzhong = equipBg.xuanzhong
            if xuanzhong then
                xuanzhong:setVisible(false)
            end
        end
        print("替换======")
        -- self._viewMgr:showDialog("weapons.WeaponsReplaceView", {selectType = self._selectType, selectPosId = self._selectPosId})
        self._viewMgr:showDialog("weapons.WeaponsReplaceView", {selectType = self._selectType, selectPosId = 1})
    end)
    self._repleaceBtn = repleaceBtn
    self._tuijian = self:getUI("bg.repleaceBtn.tuijian")
    self._tuijian:setAnchorPoint(0.2, 0)
    local seq = cc.Sequence:create(cc.ScaleTo:create(1, 1), cc.ScaleTo:create(1, 0.8))
    self._tuijian:runAction(cc.RepeatForever:create(seq))

    local repleaceBtn1 = self:getUI("bg.repleaceBtn1")
    self:registerClickEvent(repleaceBtn1, function()
        if self._selectPosId then
            local equipBg = self:getUI("bg.equipBg" .. self._selectPosId)
            local xuanzhong = equipBg.xuanzhong
            if xuanzhong then
                xuanzhong:setVisible(false)
            end
        end
        print("替换======")
        -- self._viewMgr:showDialog("weapons.WeaponsReplaceView", {selectType = self._selectType, selectPosId = self._selectPosId})
        self._viewMgr:showDialog("weapons.WeaponsReplaceView", {selectType = self._selectType, selectPosId = 1})
    end)
    self._repleaceBtn1 = repleaceBtn1
    self._tuijian1 = self:getUI("bg.repleaceBtn1.tuijian")
    self._tuijian1:setAnchorPoint(0.2, 0)
    local seq = cc.Sequence:create(cc.ScaleTo:create(1, 1), cc.ScaleTo:create(1, 0.8))
    self._tuijian1:runAction(cc.RepeatForever:create(seq))
end

-- 是否装备配件
function WeaponsReformNode:isParts()
    local weaponTypeData = self._weaponsModel:getWeaponsDataByType(self._selectType)
    local selectPosId = self._selectPosId
    if (not selectPosId) or weaponTypeData["sp" .. selectPosId] == 0 then
        selectPosId = nil 
        for i=1,4 do
            local sp = weaponTypeData["sp" .. i]
            if sp and sp ~= 0 then
                selectPosId = i
                break
            end
        end
    end
    local flag = true
    if selectPosId then
        flag = false
    end
    return flag
end

function WeaponsReformNode:reflashUI(data)
    print("selectPosId=====666666666=", self._selectPosId)
    -- self._aminBg = inView
    self._selectType = data.selectType
    self._selectWeaponId = data.selectWeaponId
    local weaponTypeData = self._weaponsModel:getWeaponsDataByType(self._selectType)
    -- dump(weaponTypeData)
    local level = weaponTypeData.lv
    local siegeTab = tab:SiegeWeaponType(self._selectType)
    -- dump(siegeTab)
    -- local baseInfoLevelLab = self._infoNode:getChildByFullName("levelLab")
    -- baseInfoLevelLab:setString("Lv." .. level)

    local propsData = self._weaponsModel:getPropsData()
    local equipTypeTab = siegeTab.equipType
    for i=1,4 do
        local equipBg = self:getUI("bg.equipBg" .. i)
        local equipType = self:getUI("bg.equipBg" .. i .. ".equipType")
        equipType:loadTexture("weaponImageUI_propsType" .. equipTypeTab[i][1] .. ".png", 1)

        local propsIndexId = weaponTypeData["sp" .. i]
        local tpropsData = {}
        if propsIndexId and propsIndexId ~= 0 then
            tpropsData = propsData[propsIndexId]
        end
        self:updateEquipCell(equipBg, tpropsData, i)
    end

    local flag = self:isParts()
    if flag == false then
        self._repleaceBtn1:setVisible(false)
        self._repleaceBtn:setVisible(true)
        self._upgradeBtn:setVisible(true)
    else
        self._repleaceBtn1:setVisible(true)
        self._repleaceBtn:setVisible(false)
        self._upgradeBtn:setVisible(false)
    end

    if weaponTypeData.onReplace ~= 0 then
        self._tuijian:setVisible(true)
        self._tuijian1:setVisible(true)
    else
        self._tuijian:setVisible(false)
        self._tuijian1:setVisible(false)
    end

    self:updateProperty()
end

function WeaponsReformNode:updateEquipCell(inView, propsData, indexId)
    -- print("propsId===========", propsId, indexId)
    local propsId = propsData.id or 0
    local notEquip = self:getUI("bg.equipBg" .. indexId .. ".notEquip")

    if (not propsId) or (propsId == 0) then
        if notEquip then
            notEquip:setVisible(true)
            self:registerClickEvent(notEquip, function()
                if self._selectPosId then
                    local equipBg = self:getUI("bg.equipBg" .. self._selectPosId)
                    local xuanzhong = equipBg.xuanzhong
                    if xuanzhong then
                        xuanzhong:setVisible(false)
                    end
                end
                -- self._selectPosId = indexId
                print("self._selectPosId=============", self._selectPosId)
                -- self._selectPosId = indexId -- self:getSelectPosId()
                -- self:updateEquipCell(inView, propsData, self._selectPosId)
                self._viewMgr:showDialog("weapons.WeaponsReplaceView", {selectType = self._selectType, selectWeaponId = self._selectWeaponId, selectPosId = indexId})
                -- self._viewMgr:showDialog("weapons.WeaponsReplaceView", {})
            end)
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
        local param = {itemId = propsId, level = propsData.lv, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 1}
        if not propsIcon then
            propsIcon = IconUtils:createWeaponsBagItemIcon(param)
            propsIcon:setName("propsIcon")
            propsIcon:setPosition(0, 0)
            propsIcon:setScale(0.75)
            inView:addChild(propsIcon)
            inView.propsIcon = propsIcon
        else
            IconUtils:updateWeaponsBagItemIcon(propsIcon, param)
        end
        propsIcon:setVisible(true)
    end

    local xuanzhong = inView.xuanzhong
    if not xuanzhong then
        xuanzhong = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
        xuanzhong:setName("xuanzhong")
        xuanzhong:gotoAndStop(1)
        xuanzhong:setPosition(38, 38)
        xuanzhong:setScale(0.75)
        inView:addChild(xuanzhong,50)
        inView.xuanzhong = xuanzhong
    end

    if self._selectPosId == indexId then
        xuanzhong:setVisible(false)
    else
        xuanzhong:setVisible(false)
    end

    -- self:registerClickEvent(inView, function()
    --     if self._selectPosId then
    --         local equipBg = self:getUI("bg.equipBg" .. self._selectPosId)
    --         local xuanzhong = equipBg.xuanzhong
    --         if xuanzhong then
    --             xuanzhong:setVisible(false)
    --         end
    --     end

    --     print("self._selectPosId=============", self._selectPosId)
    --     self._selectPosId = indexId -- self:getSelectPosId()
    --     self:updateEquipCell(inView, propsData, self._selectPosId)
    --     -- self:updateProperty()
    -- end)
end

function WeaponsReformNode:updateProperty()
    local noselect = self:getUI("bg.noselect")
    local shuxingBg = self:getUI("bg.shuxingBg")
    local flag = self:getSelectPosId()
    if flag == true then
        shuxingBg:setVisible(true)
        noselect:setVisible(false)
    else
        shuxingBg:setVisible(false)
        noselect:setVisible(true)
    end
    print("propKey================", propKey)

    local attr = {}
    for i=1,6 do
        attr[i] = 0
    end
    local weaponTypeData = self._weaponsModel:getWeaponsDataByType(self._selectType)
    for i=1,4 do
        local propKey = weaponTypeData["sp" .. i]
        if propKey ~= 0 then
            local attrData = self._weaponsModel:getPropsAttr(propKey)
            for key=1,6 do
                attr[key] = attr[key] + attrData[key]
            end
        end
    end


    local attrData = attr
    local attr1TipLab = self:getUI("bg.shuxingBg.infoBg.attr1TipLab")
    local attr1Lab = self:getUI("bg.shuxingBg.infoBg.attr1Lab")
    local attr2TipLab = self:getUI("bg.shuxingBg.infoBg.attr2TipLab")
    local attr2Lab = self:getUI("bg.shuxingBg.infoBg.attr2Lab")
    local attr3TipLab = self:getUI("bg.shuxingBg.infoBg.attr3TipLab")
    local attr3Lab = self:getUI("bg.shuxingBg.infoBg.attr3Lab")

    attr1TipLab:setString(lang("SIEGEWEAPONT_1"))
    attr1Lab:setString("+" .. attrData[1])

    attr2TipLab:setString(lang("SIEGEWEAPONT_2"))
    attr2Lab:setString("+" .. attrData[2])

    attr3TipLab:setString(lang("SIEGEWEAPONT_3"))
    attr3Lab:setString("+" .. attrData[3])



    local tipLab1 = self:getUI("bg.shuxingBg.expertBg.tipLab1")
    local valueLab1 = self:getUI("bg.shuxingBg.expertBg.valueLab1")
    local tipLab2 = self:getUI("bg.shuxingBg.expertBg.tipLab2")
    local valueLab2 = self:getUI("bg.shuxingBg.expertBg.valueLab2")
    local tipLab3 = self:getUI("bg.shuxingBg.expertBg.tipLab3")
    local valueLab3 = self:getUI("bg.shuxingBg.expertBg.valueLab3")

    tipLab1:setString(lang("SIEGEWEAPONTS_" .. 1))
    valueLab1:setString("+" .. attrData[4] .. "%")

    tipLab2:setString(lang("SIEGEWEAPONTS_" .. 2))
    valueLab2:setString("+" .. attrData[5] .. "%")

    tipLab3:setString(lang("SIEGEWEAPONTS_" .. 3))
    valueLab3:setString("+" .. attrData[6] .. "%")

end

function WeaponsReformNode:getSelectPosId()
    local selectPosId = false
    local weaponTypeData = self._weaponsModel:getWeaponsDataByType(self._selectType)
    for i=1,4 do
        local sp = weaponTypeData["sp" .. i]
        if sp and sp ~= 0 then
            selectPosId = true
            break
        end
    end
    return selectPosId
end

return WeaponsReformNode

