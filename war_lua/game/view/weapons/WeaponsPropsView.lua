--[[
    Filename:    WeaponsPropsView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-09-14 16:43:27
    Description: File description
--]]


local WeaponsPropsView = class("WeaponsPropsView", BasePopView)

function WeaponsPropsView:ctor(param)
    WeaponsPropsView.super.ctor(self)
    dump(param)
    self._selectType = param.selectType or 1
    self._selectPosId = param.selectPosId or 1
end

function WeaponsPropsView:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        if self._closeCallback ~= nil then 
            self._closeCallback()
        end
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("weapons.WeaponsPropsView")
        end
        self:close()
    end)  

    self._weaponsModel = self._modelMgr:getModel("WeaponsModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._selectPosId = self._selectPosId

    local weaponTypeData = self._weaponsModel:getWeaponsDataByType(self._selectType)
    local propsIndexId = weaponTypeData["sp" .. self._selectPosId]

    local propsData = self._weaponsModel:getPropsData()
    self._propsData = propsData[propsIndexId]
    dump(self._propsData)

    local title1 = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title1, 1, 1)

    local title3 = self:getUI("bg.layer.title1")
    UIUtils:adjustTitle(title3)
    local title3 = self:getUI("bg.layer.title2")
    UIUtils:adjustTitle(title3)

    local title3 = self:getUI("bg.shuxingBg.scrollView.title1")
    UIUtils:adjustTitle(title3)

    local title4 = self:getUI("bg.shuxingBg.scrollView.title2")
    UIUtils:adjustTitle(title4)

    local propsBg = self:getUI("bg.propsBg")
    -- local zhandouli1 = cc.Label:createWithTTF("战斗力", UIUtils.ttfName, 30)
    -- zhandouli1:setAnchorPoint(0, 0.5)
    -- zhandouli1:setColor(cc.c3b(255, 238, 160))
    -- zhandouli1:enableOutline(UIUtils.colorTable.titleOutLineColor, 1)
    -- zhandouli1:setPosition(118, 25)
    -- zhandouli1:setName("zhandouli1")
    -- propsBg:addChild(zhandouli1) -- 4

    self._zhandouliLab = cc.LabelBMFont:create("", UIUtils.bmfName_zhandouli_little)
    self._zhandouliLab:setName("zhandouli")
    self._zhandouliLab:setAnchorPoint(0,0.5)
    self._zhandouliLab:setScale(0.6)
    self._zhandouliLab:setPosition(-55, -160)
    propsBg:addChild(self._zhandouliLab, 1)

    local nameLab1 = self:getUI("bg.propsBg.labName")
    nameLab1:setColor(cc.c3b(78, 50, 13))
    nameLab1:setFontSize(24)
    -- nameLab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    local upgradeBtn = self:getUI("bg.upgradeBtn")
    self:registerClickEvent(upgradeBtn, function()
        local propsId = self._propsData.id
        local level = self._propsData.lv
        local maxLvl = self._propsData.maxLevel -- tab:Setting("WEAPON_LV_LIMIT").value 

        if maxLvl <= level then
            self._viewMgr:showTip(lang("SIEGECON_TIPS16"))
            return
        end

        local quality = tab:SiegeEquip(propsId).quality
        local costData = tab:SiegeEquipExp(level)["exp" .. quality]
        local costValue = costData[1][3]

        local userData = self._userModel:getData()
        local siegePropExp = userData.siegePropExp or 0
        if siegePropExp >= costValue then
            self:upgradeProp()
        else
            local param = {indexId = 14}
            self._viewMgr:showDialog("global.GlobalPromptDialog", param)
            -- self._viewMgr:showTip("资源不足")
        end
    end)
    local upgradefiveBtn = self:getUI("bg.upgradefiveBtn")
    self:registerClickEvent(upgradefiveBtn, function()
        local propsId = self._propsData.id
        local level = self._propsData.lv
        local maxLvl = self._propsData.maxLevel -- tab:Setting("WEAPON_LV_LIMIT").value 
        if maxLvl <= level then
            self._viewMgr:showTip(lang("SIEGECON_TIPS16"))
            return
        end

        local quality = tab:SiegeEquip(propsId).quality
        local costData = tab:SiegeEquipExp(level)["exp" .. quality]
        local costValue = costData[1][3]

        local userData = self._userModel:getData()
        local siegePropExp = userData.siegePropExp or 0
        if siegePropExp >= costValue then
            self:upgradeFiveProp()
        else
            local param = {indexId = 14}
            self._viewMgr:showDialog("global.GlobalPromptDialog", param)
            -- self._viewMgr:showTip("资源不足")
        end
    end)

    self:listenReflash("WeaponsModel", self.reflashUI)
    self:listenReflash("UserModel", self.updateCost)
end

function WeaponsPropsView:reflashUI()
    self:updateEquiptList()
    local weaponTypeData = self._weaponsModel:getWeaponsDataByType(self._selectType)
    local propsIndexId = weaponTypeData["sp" .. self._selectPosId]
    local propsData = self._weaponsModel:getPropsData()
    local tpropsData = {}
    if propsIndexId and propsIndexId ~= 0 then
        tpropsData = propsData[propsIndexId] or {}
    end
    self:upgradeRightData(tpropsData)
end

function WeaponsPropsView:updateEquiptList()
    local weaponTypeData = self._weaponsModel:getWeaponsDataByType(self._selectType)
    local siegeTab = tab:SiegeWeaponType(self._selectType)
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
    local propsData = self._weaponsModel:getPropsData()
    local equip
    for i=1,4 do
        local equipBg = self:getUI("bg.equiptList.equipBg" .. i)
        local propsIndexId = weaponTypeData["sp" .. i]
        local tpropsData = {}
        if propsIndexId and propsIndexId ~= 0 then
            tpropsData = propsData[propsIndexId] or {}
        end
        self:updateEquipCell(equipBg, tpropsData, i)
    end
end

function WeaponsPropsView:updateEquipCell(inView, propsData, indexId)
    local propsId = propsData.id or 0
    print("propsId===========", propsId, indexId)
    local notEquip = self:getUI("bg.equiptList.equipBg" .. indexId .. ".notEquip")

    if (not propsId) or (propsId == 0) then
        if notEquip then
            notEquip:setVisible(true)
            -- self:registerClickEvent(notEquip, function()
            --     -- self._viewMgr:showDialog("weapons.WeaponsPropsView", {})
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
        local propsTab = tab:SiegeEquip(propsId)
        local propsIcon = inView.propsIcon
        local param = {itemId = propsId, level = propsData.lv, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 0}
        if not propsIcon then
            propsIcon = IconUtils:createWeaponsBagItemIcon(param)
            propsIcon:setName("propsIcon")
            propsIcon:setPosition(-10, -7)
            propsIcon:setScale(0.98)
            inView:addChild(propsIcon)
            inView.propsIcon = propsIcon
        else
            IconUtils:updateWeaponsBagItemIcon(propsIcon, param)
        end
        propsIcon:setVisible(true)
    end

    -- self._zhandouliLab:setString(propsData.score)

    local xuanzhong = inView.xuanzhong
    if not xuanzhong then
        xuanzhong = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
        xuanzhong:setName("xuanzhong")
        xuanzhong:gotoAndStop(1)
        xuanzhong:setPosition(39, 42)
        -- xuanzhong:setScale(0.75)
        inView:addChild(xuanzhong,50)
        inView.xuanzhong = xuanzhong
    end

    if self._selectPosId == indexId then
        xuanzhong:setVisible(true)
    else
        xuanzhong:setVisible(false)
    end

    self:registerClickEvent(inView, function()
        if not propsData.id then
            self._viewMgr:showTip(lang("SIEGECON_TIPS15"))
            return
        end
        local equipBg = self:getUI("bg.equiptList.equipBg" .. self._selectPosId)
        local xuanzhong = equipBg.xuanzhong
        if xuanzhong then
            xuanzhong:setVisible(false)
        end
        dump(propsData)
        print("self._selectPosId=============", self._selectPosId)
        self._selectPosId = indexId
        self._propsData = propsData
        self:updateEquipCell(inView, propsData, self._selectPosId)
        self:upgradeRightData(propsData)
    end)
end

function WeaponsPropsView:updateCost()
    local propsId = self._propsData.id
    local level = self._propsData.lv
    local maxLvl = self._propsData.maxLevel 
    local quality = tab:SiegeEquip(propsId).quality
    local siegeEquipExpTab = tab:SiegeEquipExp(level)
    local costData = 0
    local costValue = 0

    local upgradeBtn = self:getUI("bg.upgradeBtn")
    local upgradefiveBtn = self:getUI("bg.upgradefiveBtn")
    local goldValue = self:getUI("bg.goldValue")
    local goldImg = self:getUI("bg.goldImg")
    local maxLevel = self:getUI("bg.maxLevel")
    if level < maxLvl then
        costData = siegeEquipExpTab["exp" .. quality]
        costValue = costData[1][3]

        upgradeBtn:setVisible(true)
        upgradefiveBtn:setVisible(false)
        goldValue:setVisible(true)
        goldImg:setVisible(true)
        maxLevel:setVisible(false)
    else
        upgradeBtn:setVisible(false)
        upgradefiveBtn:setVisible(false)
        goldValue:setVisible(false)
        goldImg:setVisible(false)
        maxLevel:setVisible(true)
    end
    local userData = self._userModel:getData()
    local siegePropExp = userData.siegePropExp or 0
    local tstr = siegePropExp .. "/" .. costValue
    goldValue:setString(tstr)

    if siegePropExp >= costValue then
        goldValue:setColor(UIUtils.colorTable.ccUITabColor2)
    else
        goldValue:setColor(UIUtils.colorTable.ccColorQuality6)
    end
end


function WeaponsPropsView:upgradeRightData(propsData)
    local propsId = propsData.id
    if not propsId then
        return
    end
    local propsTab = tab:SiegeEquip(propsId)
    -- 抬头部分
    local labName = self:getUI("bg.propsBg.labName")
    labName:setString(lang(propsTab.name))
    local levelLab = self:getUI("bg.propsBg.levelLab")
    local maxLvl = propsData.maxLevel
    local lvStr = "Lv." .. propsData.lv .. "/" .. maxLvl
    levelLab:setString(lvStr)
    local weaponTypeImg = self:getUI("bg.propsBg.weaponTypeImg")
    weaponTypeImg:loadTexture("weaponImageUI_propsType" .. propsTab.type .. ".png", 1)
    local runeIcon = self:getUI("bg.propsBg.runeIcon")
    runeIcon:loadTexture(propsTab.art .. ".png", 1)

    self._zhandouliLab:setString("a" .. propsData.score)
    -- 属性部分

    self:updateProperty()
    self:updateCost()
end

function WeaponsPropsView:upgradeProp()
    local param = {type = self._selectType, slotId = self._selectPosId}
    dump(param)
    local propKey = self._propsData.key 
    self._oldAttrData = self._weaponsModel:getPropsAttr(propKey)
    dump(self._oldAttrData, "attrData=====")
    local weaponTypeData = clone(self._weaponsModel:getWeaponsDataByType(self._selectType))
    local oldPropData = self._weaponsModel:getPropsDataByKey(propKey)
    local oldPropFight = 0
    if oldPropData then
        oldPropFight = oldPropData.score
    end
    local propLock = self._propLock
    self._serverMgr:sendMsg("WeaponServer", "upgradeProp", param, true, {}, function (result)
        -- dump(result, "result=======", 10)
        -- self:updateCurrencyUI()
        -- self:updateRightSubBg()
        -- self:updateLeftPanel(weaponId, weaponsId)
        local newWeaponTypeData = self._weaponsModel:getWeaponsDataByType(self._selectType)
        local skillLock = self._weaponsModel:getWeaponsSkillLock()
        for i=1,2 do
            local indexId = "ss" .. i
            local oldSkill = weaponTypeData[indexId]
            local newSkill = newWeaponTypeData[indexId]
            if newSkill == 1 and oldSkill == 0 then
                skillLock[i] = i
            end
        end

        self._newAttrData = self._weaponsModel:getPropsAttr(propKey)

        local propData = self._weaponsModel:getPropsDataByKey(propKey)
        local propFight = propData.score
        local fightBg = self:getUI("bg")
        TeamUtils:setFightAnim(fightBg, {oldFight = oldPropFight, newFight = propFight, x = fightBg:getContentSize().width*0.5-100, y = fightBg:getContentSize().height - 100})
        
        local equipLimitLv = tab:Setting("SIEGE_EQUIP_LV").value
        local propLevel = propData.lv
        local scrollView = self:getUI("bg.shuxingBg.scrollView")
        local desLab = scrollView["desLab" .. propLock]
        if desLab then
            if table.indexof(equipLimitLv, propLevel) then
                print("===propLock======", propLock, propLevel)
                local mc2 = mcMgr:createViewMC("shuxingshuguang_itemeffectcollection", false, true)
                mc2:setScaleY(0.65)
                mc2:setPosition(0, desLab:getPositionY())
                scrollView:addChild(mc2)
            end
        end


        self:qianghuachenggong()
    end)
end

function WeaponsPropsView:upgradeFiveProp()
    local param = {type = self._selectType, slotId = self._selectPosId, quick = 1}
    dump(param)
    local propKey = self._propsData.key 
    self._oldAttrData = self._weaponsModel:getPropsAttr(propKey)
    dump(self._oldAttrData, "attrData=====")
    self._serverMgr:sendMsg("WeaponServer", "upgradeProp", param, true, {}, function (result)
        dump(result, "result=======", 10)
        -- self:updateCurrencyUI()
        -- self:updateRightSubBg()
        -- self:updateLeftPanel(weaponId, weaponsId)

        self._newAttrData = self._weaponsModel:getPropsAttr(propKey)
        dump(self._newAttrData, "attrData=====")

        self:qianghuachenggong()
    end)
    -- self:resolveProp()
end

function WeaponsPropsView:updateProperty()
    local weaponTypeData = self._weaponsModel:getWeaponsDataByType(self._selectType)
    print("propKey================", self._selectPosId)
    local natureLab = {}
    local natureValue = {}
    local warningLab = {}
    local addValue = {}

    -- local infoBg = self:getUI("bg.shuxingBg.infoBg")
    local propKey = self._propsData.key 
    local propId = self._propsData.id 
    local propLevel = self._propsData.lv
    local propTab = tab:SiegeEquip(propId)

    local attrData = self._weaponsModel:getPropsAttr(propKey)
 
    -- natureLab[1] = "战斗力"
    -- natureValue[1] = propsData.score
    -- warningLab[1] = 0
    table.insert(natureLab, 0)
    table.insert(natureValue, 0)
    table.insert(warningLab, 0)
    table.insert(addValue, 0)

    local intproperty = propTab.intproperty
    for i=1,3 do
        local _intproperty = intproperty[i]
        if _intproperty then
            table.insert(natureLab, lang("SIEGEWEAPONT_" .. _intproperty[1]))
            table.insert(natureValue, "+" .. attrData[_intproperty[1]])
            table.insert(warningLab, 0)
            table.insert(addValue, "(成长:+" .. _intproperty[3] .. ")")
        end
    end
    table.insert(natureLab, 0)
    table.insert(natureValue, 0)
    table.insert(warningLab, 0)
    table.insert(addValue, 0)

    self._propLock = 0
    local equipLimitLv = tab:Setting("SIEGE_EQUIP_LV").value
    for i=1,6 do
        local percent = propTab["percent" .. i]
        if percent then
            table.insert(natureLab, lang("SIEGEWEAPONTS_" .. percent[1]))
            table.insert(natureValue, "+" .. percent[2] .. "%")
            table.insert(addValue, 0)
            if propLevel < equipLimitLv[i] then
                table.insert(warningLab, "(配件" .. equipLimitLv[i] .. "级激活)")
            else
                table.insert(warningLab, 0)
            end
        end
    end

    -- dump(natureLab)
    -- dump(natureValue)
    dump(warningLab, 'warningLab=====')
    -- dump(addValue, 'addValue==========')

    local scrollView = self:getUI("bg.shuxingBg.scrollView")
    local natureNum = table.nums(natureLab)
    local maxHeight = natureNum*24 + 60
    print("maxHight========", maxHeight)
    -- scrollView:setInnerContainerSize(cc.size(200, maxHeight))
    maxHeight = scrollView:getInnerContainerSize().height
    local indexId = 1
    local sheight = 0
    for i=1,11 do
        local desLab = scrollView["desLab" .. i]
        if not desLab then
            desLab = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
            desLab:setAnchorPoint(0, 0.5)
            desLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            desLab:setName("desLab")
            scrollView:addChild(desLab, 10) -- 4r3
            scrollView["desLab" .. i] = desLab 
        end

        local valueLab = scrollView["valueLab" .. i]
        if not valueLab then
            valueLab = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
            valueLab:setAnchorPoint(0, 0.5)
            valueLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            valueLab:setName("valueLab")
            scrollView:addChild(valueLab) -- 4r3
            scrollView["valueLab" .. i] = valueLab 
        end

        local addValueLab = scrollView["addValueLab" .. i]
        if not addValueLab then
            addValueLab = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
            addValueLab:setAnchorPoint(0, 0.5)
            addValueLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            addValueLab:setName("addValueLab")
            scrollView:addChild(addValueLab) -- 4r3
            scrollView["addValueLab" .. i] = addValueLab 
        end

        if natureLab[i] ~= 0 then
            if natureLab[i] ~= 0 then
                desLab:setVisible(true)
                desLab:setString(natureLab[i])
                desLab:setPosition(16, maxHeight-sheight)
            else
                desLab:setVisible(false)
            end
            if natureValue[i] ~= 0 then
                valueLab:setVisible(true)
                valueLab:setString(natureValue[i])
                valueLab:setPosition(106, maxHeight-sheight)
            else
                valueLab:setVisible(false)
            end

            local aValue = ""
            if addValue[i] ~= 0 then
                aValue = addValue[i]
                addValueLab:setColor(UIUtils.colorTable.ccUIBaseColor9)
                addValueLab:setPosition(170, maxHeight-sheight)
                addValueLab:setVisible(true)
            elseif warningLab[i] ~= 0 then
                if self._propLock == 0 then
                    self._propLock = i
                end
                aValue = warningLab[i]
                addValueLab:setColor(UIUtils.colorTable.ccUIBaseColor8)
                addValueLab:setPosition(170, maxHeight-sheight)
                addValueLab:setVisible(true)
            else
                addValueLab:setVisible(false)
            end
            print("indexId=========",indexId)
            if indexId == 3 then
                valueLab:setPosition(120, maxHeight-sheight)
                addValueLab:setPosition(180, maxHeight-sheight)
            end
            addValueLab:setString(aValue)
            sheight = sheight + 25
        else
            local title = self:getUI("bg.shuxingBg.scrollView.title" .. indexId)
            if title then
                if indexId == 1 then
                    sheight = sheight + 30
                    title:setPositionY(maxHeight-sheight)
                elseif indexId == 2 then
                    sheight = sheight + 10
                    title:setPositionY(maxHeight-sheight)
                end
                indexId = indexId + 1
                sheight = sheight + 26
            end
            desLab:setVisible(false)
            valueLab:setVisible(false)
            addValueLab:setVisible(false)
            -- desLab:setPosition(10, maxHeight-sheight)
            -- valueLab:setPosition(100, maxHeight-sheight)
        end
        if warningLab[i] ~= 0 then
            desLab:setColor(UIUtils.colorTable.ccUIBaseColor8)
            valueLab:setColor(UIUtils.colorTable.ccUIBaseColor8)
        else
            desLab:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
            valueLab:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
        end
    end

end



-- function WeaponsPropsView:updateProperty()
--     local weaponTypeData = self._weaponsModel:getWeaponsDataByType(self._selectType)
--     print("propKey================", self._selectPosId)

--     -- local infoBg = self:getUI("bg.shuxingBg.infoBg")
--     local propKey = self._propsData.key 
--     local propId = self._propsData.id 
--     local propLevel = self._propsData.lv
--     local propTab = tab:SiegeEquip(propId)

--     local attrData = self._weaponsModel:getPropsAttr(propKey)
--     -- dump(attrData)
--     local attr1TipLab = self:getUI("bg.shuxingBg.infoBg.attr1TipLab")
--     local attr1Lab = self:getUI("bg.shuxingBg.infoBg.attr1Lab")
--     local addValue1 = self:getUI("bg.shuxingBg.infoBg.addValue1")
--     local attr2TipLab = self:getUI("bg.shuxingBg.infoBg.attr2TipLab")
--     local attr2Lab = self:getUI("bg.shuxingBg.infoBg.attr2Lab")
--     local addValue2 = self:getUI("bg.shuxingBg.infoBg.addValue2")
--     local attr3TipLab = self:getUI("bg.shuxingBg.infoBg.attr3TipLab")
--     local attr3Lab = self:getUI("bg.shuxingBg.infoBg.attr3Lab")
--     local addValue3 = self:getUI("bg.shuxingBg.infoBg.addValue3")

--     local intproperty = propTab.intproperty
--     if intproperty[1] then
--         attr1TipLab:setVisible(true)
--         attr1Lab:setVisible(true)
--         addValue1:setVisible(true)
--         attr1TipLab:setString(lang("SIEGEWEAPONT_" .. intproperty[1][1]))
--         attr1Lab:setString("+" .. attrData[1])
--         addValue1:setString("(成长:+" .. intproperty[1][3] .. ")")
--     else
--         attr1TipLab:setVisible(false)
--         attr1Lab:setVisible(false)
--         addValue1:setVisible(false)
--     end

--     if intproperty[2] then
--         attr2TipLab:setVisible(true)
--         attr2Lab:setVisible(true)
--         addValue2:setVisible(true)
--         attr2TipLab:setString(lang("SIEGEWEAPONT_" .. intproperty[2][1]))
--         attr2Lab:setString("+" .. attrData[2])
--         addValue2:setString("(成长:+" .. intproperty[2][3] .. ")")
--     else
--         attr2TipLab:setVisible(false)
--         attr2Lab:setVisible(false)
--         addValue2:setVisible(false)
--     end

--     if intproperty[3] then
--         attr3TipLab:setVisible(true)
--         attr3Lab:setVisible(true)
--         addValue3:setVisible(true)
--         attr3TipLab:setString(lang("SIEGEWEAPONT_" .. intproperty[3][1]))
--         attr3Lab:setString("+" .. attrData[3])
--         addValue3:setString("(成长:+" .. intproperty[3][3] .. ")")
--     else
--         attr3TipLab:setVisible(false)
--         attr3Lab:setVisible(false)
--         addValue3:setVisible(false)
--     end

--     local tipLab1 = self:getUI("bg.shuxingBg.expertBg.tipLab1")
--     local valueLab1 = self:getUI("bg.shuxingBg.expertBg.valueLab1")
--     local warningLab1 = self:getUI("bg.shuxingBg.expertBg.warningLab1")
--     local tipLab2 = self:getUI("bg.shuxingBg.expertBg.tipLab2")
--     local valueLab2 = self:getUI("bg.shuxingBg.expertBg.valueLab2")
--     local warningLab2 = self:getUI("bg.shuxingBg.expertBg.warningLab2")
--     local tipLab3 = self:getUI("bg.shuxingBg.expertBg.tipLab3")
--     local valueLab3 = self:getUI("bg.shuxingBg.expertBg.valueLab3")
--     local warningLab3 = self:getUI("bg.shuxingBg.expertBg.warningLab3")

--     local equipLimitLv = tab:Setting("SIEGE_EQUIP_LV").value
--     local percent = propTab["percent1"]
--     if percent then
--         tipLab1:setVisible(true)
--         valueLab1:setVisible(true)
--         warningLab1:setVisible(true)
--         tipLab1:setString(lang("SIEGEWEAPONT_" .. percent[1]))
--         valueLab1:setString("+" .. percent[2] .. "%")
--         if propLevel < equipLimitLv[1] then
--             warningLab1:setString("(配件" .. equipLimitLv[1] .. "级激活)")
--             warningLab1:setVisible(true)
--             tipLab1:setColor(UIUtils.colorTable.ccUIBaseColor8)
--             valueLab1:setColor(UIUtils.colorTable.ccUIBaseColor8)
--         else
--             warningLab1:setVisible(false)
--             tipLab1:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
--             valueLab1:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
--         end
--     else
--         tipLab1:setVisible(false)
--         valueLab1:setVisible(false)
--         warningLab1:setVisible(false)
--     end

--     local percent = propTab["percent2"]
--     if percent then
--         tipLab2:setVisible(true)
--         valueLab2:setVisible(true)
--         tipLab2:setString(lang("SIEGEWEAPONT_" .. percent[1]))
--         valueLab2:setString("+" .. percent[2] .. "%")
--         if propLevel < equipLimitLv[2] then
--             warningLab2:setString("(配件" .. equipLimitLv[2] .. "级激活)")
--             warningLab2:setVisible(true)
--             tipLab2:setColor(UIUtils.colorTable.ccUIBaseColor8)
--             valueLab2:setColor(UIUtils.colorTable.ccUIBaseColor8)
--         else
--             warningLab2:setVisible(false)
--             tipLab2:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
--             valueLab2:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
--         end
--     else
--         tipLab2:setVisible(false)
--         valueLab2:setVisible(false)
--         warningLab2:setVisible(false)
--     end

--     local percent = propTab["percent3"]
--     if percent then
--         tipLab3:setVisible(true)
--         valueLab3:setVisible(true)
--         tipLab3:setString(lang("SIEGEWEAPONT_" .. percent[1]))
--         valueLab3:setString("+" .. percent[2] .. "%")
--         if propLevel < equipLimitLv[3] then
--             warningLab3:setString("(配件" .. equipLimitLv[3] .. "级激活)")
--             warningLab3:setVisible(true)
--             tipLab3:setColor(UIUtils.colorTable.ccUIBaseColor8)
--             valueLab3:setColor(UIUtils.colorTable.ccUIBaseColor8)
--         else
--             warningLab3:setVisible(false)
--             tipLab3:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
--             valueLab3:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
--         end
--     else
--         tipLab3:setVisible(false)
--         valueLab3:setVisible(false)
--         warningLab3:setVisible(false)
--     end
-- end


function WeaponsPropsView:qianghuachenggong()
    local runeIcon = self:getUI("bg.propsBg.runeIcon")
    local tempMc1 = mcMgr:createViewMC("bingtuanqianghua_qianghua", false, true, function (_, sender)
    end)
    tempMc1:setPosition(runeIcon:getContentSize().width*0.5, runeIcon:getContentSize().height*0.5-20)
    runeIcon:addChild(tempMc1)

    self:teamPiaoNature(0.5, runeIcon, 1)

    local tempRuneIcon = runeIcon:getParent():getChildByName("tempRuneIcon")
    if tempRuneIcon then
        tempRuneIcon:stopAllActions()
        tempRuneIcon:removeFromParent()
    end
    tempRuneIcon = runeIcon:clone()
    tempRuneIcon:setPurityColor(255, 255, 255)
    tempRuneIcon:setName("tempRuneIcon")
    runeIcon:getParent():addChild(tempRuneIcon)

    -- local teamImgBg = self:getUI("bg")
    -- TeamUtils:setFightAnim(teamImgBg, {oldFight = self._oldFight, newFight = TeamUtils:updateFightNum(), x = teamImgBg:getContentSize().width*0.5-100, y = teamImgBg:getContentSize().height - 170})

    local seqnature = cc.Sequence:create(cc.FadeOut:create(0.2),
        cc.RemoveSelf:create(true))
    tempRuneIcon:runAction(seqnature)

    self:teamPiaoNature1()
end

function WeaponsPropsView:teamPiaoNature(time, runeIcon, str)
    str = "weaponImageUI_img26"
    local natureLab = runeIcon:getChildByName("natureLab")
    if natureLab then
        natureLab:stopAllActions()
        natureLab:removeFromParent()
    end
    natureLab = cc.Sprite:create() 
    natureLab:setSpriteFrame(str .. ".png")
    natureLab:setName("natureLab")
    natureLab:setPosition(cc.p(runeIcon:getContentSize().width*0.5, runeIcon:getContentSize().height*0.5-20))
    natureLab:setOpacity(0)
    runeIcon:addChild(natureLab,100)

    local seqnature = cc.Sequence:create(cc.ScaleTo:create(0, 0.2), cc.DelayTime:create(0.2), 
        cc.Spawn:create(cc.ScaleTo:create(0.2, 1),cc.FadeIn:create(0.2),cc.MoveBy:create(0.2, cc.p(0,38))), 
        cc.MoveBy:create(0.38, cc.p(0,17)),
        cc.Spawn:create(cc.MoveBy:create(0.4, cc.p(0,10)),cc.FadeOut:create(0.7)),
        cc.RemoveSelf:create(true))
    natureLab:runAction(seqnature)
end

function WeaponsPropsView:teamPiaoNature1()
    local runeIcon = self:getUI("bg.propsBg.runeIcon")

    local param = {}
    for i=1,3 do
        local oldData = self._oldAttrData[i]
        local newData = self._newAttrData[i]
        local data = newData - oldData
        if data ~= 0 then
            local indexId = i 
            if i > 3 then
                indexId = i - 3
            end
            local tstr = lang("SIEGEWEAPONT_" .. indexId) .. "+" .. TeamUtils.getNatureNums(data)
            table.insert(param, tstr)
        end
    end

    for i=1,table.nums(param) do
        local natureLab = runeIcon:getChildByName("natureLab" .. i)
        if natureLab then
            natureLab:stopAllActions()
            natureLab:removeFromParent()
        end
        natureLab = cc.Label:createWithTTF(param[i], UIUtils.ttfName, 24)
        natureLab:setName("natureLab" .. i)
        natureLab:setColor(UIUtils.colorTable.ccColorQuality2)
        natureLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        natureLab:setPosition(cc.p(runeIcon:getContentSize().width*0.5, runeIcon:getContentSize().height*0.5-35*i - 35))
        natureLab:setOpacity(0)
        runeIcon:addChild(natureLab,100)

        local seqnature = cc.Sequence:create(cc.ScaleTo:create(0, 0.2), cc.DelayTime:create(0.2+0.1*i), 
            cc.Spawn:create(cc.ScaleTo:create(0.2, 1),cc.FadeIn:create(0.2),cc.MoveBy:create(0.2, cc.p(0,38))), 
            cc.MoveBy:create(0.38, cc.p(0,17)),
            cc.Spawn:create(cc.MoveBy:create(0.4, cc.p(0,10)),cc.FadeOut:create(0.7)),
            cc.RemoveSelf:create(true))
        natureLab:runAction(seqnature)
    end
end


return WeaponsPropsView