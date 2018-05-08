--[[
    Filename:    TeamRuneView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-05-25 17:18:48
    Description: File description
--]]

local TeamRuneView = class("TeamRuneView", BasePopView)

function TeamRuneView:ctor(param)
    TeamRuneView.super.ctor(self)
    self._dataValue = {}
    self._teamData = param.teamData
    self._curSelectIndex = param.equipId
end

function TeamRuneView:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        if self._closeCallback ~= nil then 
            self._closeCallback()
        end
        UIUtils:reloadLuaFile("team.TeamRuneView")
        self:close()
    end)  

    local title1 = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title1, 1, 1)

    local title1 = self:getUI("bg.panel1.titlebg1")
    UIUtils:adjustTitle(title1)

    local title2 = self:getUI("bg.panel1.titlebg2")
    UIUtils:adjustTitle(title2)

    local title3 = self:getUI("bg.shuxingBg.title1")
    UIUtils:adjustTitle(title3)

    local title4 = self:getUI("bg.shuxingBg.title2")
    UIUtils:adjustTitle(title4)

    local nameLab1 = self:getUI("bg.Image_111.labName")
    nameLab1:setFontSize(29)
    nameLab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    local levelLab = self:getUI("bg.panel1.upgradeBg.levelLab")
    self:listenReflash("IntanceModel", self.updateRuneStageItemData)
    self:listenReflash("IntanceEliteModel", self.updateRuneStageItemData)
    self:listenReflash("UserModel", self.switchRune)

    self:animBegin()

    local tempBaseInfoNode = self:getUI("bg.panel1")
    local runeIcon = self:getUI("bg.Image_111.runeIcon")
    local tempEquip = tab:Team(self._teamData.teamId)
    local sysEquip = tab:Equipment(tempEquip.equip[self._curSelectIndex])
    local filename = IconUtils.iconPath .. sysEquip.art .. ".png"
    runeIcon:loadTexture(filename, 1)

    self._animFlag = {}
    for i=1,3 do
        self._animFlag[i] = false
    end
    
    for i=1,4 do
        local selectRune = self:getUI("bg.equiptList.equip" .. i .. ".selectRune")
        selectRune:setVisible(false)
        local equip = self:getUI("bg.equiptList.equip" .. i)
     
        equip:setAnchorPoint(0.5,0.5)
        equip:setPosition(equip:getPositionX()+50,equip:getPositionY()+50)
        equip:setScaleAnim(true)

        
        local xuanzhong = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
        xuanzhong:setName("xuanzhong")
        xuanzhong:gotoAndStop(1)
        xuanzhong:setPosition(equip:getContentSize().width*0.5-3, equip:getContentSize().height*0.5-5)
        xuanzhong:setScale(0.9)
        xuanzhong:setVisible(false)
        equip:addChild(xuanzhong,5)

        self:registerClickEvent(equip, function()
            self:updateEquipUI(i)
        end)
    end
    self:setChangeData()
end

function TeamRuneView:qianghuachenggong(_type)
    local runeIcon = self:getUI("bg.Image_111.runeIcon")
    local tempMc1 = mcMgr:createViewMC("bingtuanqianghua_qianghua", false, true, function (_, sender)
    end)
    tempMc1:setPosition(runeIcon:getContentSize().width*0.5, runeIcon:getContentSize().height*0.5-20)
    runeIcon:addChild(tempMc1)

    if _type == 1 then
        self:teamPiaoNature(0.5, runeIcon, 1)
    else
        self:teamPiaoNature(2.5, runeIcon, 2)
    end

    local tempRuneIcon = runeIcon:getParent():getChildByName("tempRuneIcon")
    if tempRuneIcon then
        tempRuneIcon:stopAllActions()
        tempRuneIcon:removeFromParent()
    end
    tempRuneIcon = runeIcon:clone()
    tempRuneIcon:setPurityColor(255, 255, 255)
    tempRuneIcon:setName("tempRuneIcon")
    runeIcon:getParent():addChild(tempRuneIcon)

    local teamImgBg = self:getUI("bg")
    TeamUtils:setFightAnim(teamImgBg, {oldFight = self._oldFight, newFight = TeamUtils:updateFightNum(), x = teamImgBg:getContentSize().width*0.5-100, y = teamImgBg:getContentSize().height - 170})

    local seqnature = cc.Sequence:create(cc.FadeOut:create(0.2),
        cc.RemoveSelf:create(true))
    tempRuneIcon:runAction(seqnature)

    self:teamPiaoNature1()
end

function TeamRuneView:updateEquipUI(equipId)
    if self._curSelectIndex ~= equipId then
        self._curSelectIndex = equipId
        local runeIcon = self:getUI("bg.Image_111.runeIcon")
        local tempEquip = tab:Team(self._teamData.teamId)
        local sysEquip = tab:Equipment(tempEquip.equip[self._curSelectIndex])
        local filename = IconUtils.iconPath .. sysEquip.art .. ".png"
        runeIcon:loadTexture(filename, 1)

        self:reflashItemData()
    end
end

function TeamRuneView:animBegin()
    local upgradeStageBtn = self:getUI("bg.panel1.upgradeStageBtn")
    local mc1 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
    mc1:setName("anim")
    mc1:setScaleX(1.5)
    mc1:setPosition(upgradeStageBtn:getContentSize().width*upgradeStageBtn:getScaleX()*0.5, upgradeStageBtn:getContentSize().height*upgradeStageBtn:getScaleY()*0.5+1)
    upgradeStageBtn:addChild(mc1, 1)
    mc1:setVisible(false)
end

function TeamRuneView:reflashItemData()
    self:switchRune()
    local label_114 = self:getUI("bg.panel1.Label_114")
    label_114:disableEffect()   
end


function TeamRuneView:reflashUI(inData)
    self._curSelectIndex = inData.equipId
    self._teamData = inData.teamData
    self._closeCallback = inData.closeCallback
    self:reflashItemData()       
end

function TeamRuneView:switchRune()
    local tempEquip = tab:Team(self._teamData.teamId)
    local sysEquip = tab:Equipment(tempEquip.equip[self._curSelectIndex])
    local teamModel = self._modelMgr:getModel("TeamModel")

    local backQuality = teamModel:getTeamQualityByStage(self._teamData["es" .. self._curSelectIndex])

    local index = self._curSelectIndex 
    local sysTeam = tab:Team(self._teamData.teamId)

    local teamModel = self._modelMgr:getModel("TeamModel")
    local sysEquipment = tab:Equipment(sysTeam.equip[self._curSelectIndex])

    local leftEquipLevel = tonumber(self._teamData["el" .. self._curSelectIndex])
    local leftEquipStage = tonumber(self._teamData["es" .. self._curSelectIndex])
    local leftBackQuality = teamModel:getTeamQualityByStage(leftEquipStage)

    -- 符文图标
    local levelLab = self:getUI("bg.panel1.upgradeBg.levelLab")
    levelLab:setString("Lv." .. leftEquipLevel)

    local nameLab1 = self:getUI("bg.Image_111.labName")
    if leftBackQuality[2] > 0 then
        nameLab1:setString(lang(sysEquipment.name) .. "+" .. leftBackQuality[2])
    else
        nameLab1:setString(lang(sysEquipment.name))
    end

    local labNameBg = self:getUI("bg.Image_111.Image_37")
    labNameBg:loadTexture("globalImageUI12_tquality" .. leftBackQuality[1] .. ".png", 1)

    local runeBg = self:getUI("bg.Image_111.stageBg")
    local runeAnim = runeBg:getChildByName("runeAnim")
    if runeAnim then
        runeAnim:removeFromParent()
    end
   
    local leftArr1Result = BattleUtils.getEquipAttr(sysEquipment, leftEquipStage, leftEquipLevel)
    local ttipLab1 = self:getUI("bg.shuxingBg.infoBg.attr1TipLab")
    ttipLab1:setString(lang("ATTR_" .. sysEquipment["attr"]) .."：")
    ttipLab1:disableEffect()
    ttipLab1:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local vvalueLab1 = self:getUI("bg.shuxingBg.infoBg.attr1Lab")
    vvalueLab1:setString("+" .. TeamUtils.getNatureNums(leftArr1Result))
    vvalueLab1:disableEffect()
    vvalueLab1:setPosition(cc.p(ttipLab1:getPositionX()+ttipLab1:getContentSize().width,vvalueLab1:getPositionY()))

    local Label_40 = self:getUI("bg.shuxingBg.infoBg.Label_40")
    local str = TeamUtils.getNatureNums(sysEquipment.num[leftEquipStage])
    Label_40:setString("(+" .. str .. ")")
    Label_40:disableEffect()
    Label_40:setPosition(cc.p(vvalueLab1:getPositionX()+vvalueLab1:getContentSize().width+10,vvalueLab1:getPositionY()))
    Label_40:setColor(UIUtils.colorTable.ccUIBaseColor9)


    local leftArr2Result = BattleUtils.getEquipAttr1(sysEquipment, leftEquipStage, leftEquipLevel)
    local ttipLab2 = self:getUI("bg.shuxingBg.infoBg.attr2TipLab")
    ttipLab2:setString(lang("ATTR_" .. sysEquipment["attr1"]) .."：")
    ttipLab2:disableEffect()
    ttipLab2:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local vvalueLab2 = self:getUI("bg.shuxingBg.infoBg.attr2Lab")
    vvalueLab2:setString("+" .. TeamUtils.getNatureNums(leftArr2Result))
    vvalueLab2:disableEffect()
    vvalueLab2:setPosition(cc.p(ttipLab2:getPositionX()+ttipLab2:getContentSize().width,vvalueLab2:getPositionY()))

    local Label_41 = self:getUI("bg.shuxingBg.infoBg.Label_41")
    str = TeamUtils.getNatureNums(sysEquipment.num1[leftEquipStage]) --string.format("%.2f", sysEquipment.num1[leftEquipStage])--math.ceil(sysEquipment.num1[leftEquipStage])
    Label_41:setString("(+" .. str .. ")")
    Label_41:disableEffect()
    Label_41:setPosition(cc.p(vvalueLab2:getPositionX()+vvalueLab2:getContentSize().width+10,vvalueLab2:getPositionY()))
    Label_41:setColor(UIUtils.colorTable.ccUIBaseColor9)

    -- 附加属性
    for i=1,4 do
        local tipLab = self:getUI("bg.shuxingBg.expertBg.tipLab" .. i)
        local valueLab = self:getUI("bg.shuxingBg.expertBg.valueLab" .. i)
        local tip = ""
        local value = ""
        local isOpen = false
        local sysAdatrr1 = sysEquipment["adattr" .. 1]
        local sysAdatrr2 = sysEquipment["adattr" .. 2]
        local sysAdatrr3 = sysEquipment["adattr" .. 3]
        local sysAdatrr4 = sysEquipment["adattr" .. 4]
        local warningLab = self:getUI("bg.shuxingBg.expertBg.warningLab" .. i)
        
        local tempArr = {2, 5, 14, 17, 23, 25, 26}

        if i == 1 then
            value = sysAdatrr1[2]
            value = TeamUtils.getNatureNums(value)
            tip = lang("ATTR_" .. sysAdatrr1[1])
            if table.indexof(tempArr, sysAdatrr1[1]) ~= false then 
                value = value .. "%"
            end 
            if leftEquipStage >= 3 then 
                isOpen = true
            end 
        elseif i == 2 then 
            value = sysAdatrr2[2]
            value = TeamUtils.getNatureNums(value)
            tip = lang("ATTR_" .. sysAdatrr2[1])
            if table.indexof(tempArr, sysAdatrr2[1]) ~= false then 
                value = value .. "%"
            end     
            if leftEquipStage >= 6 then 
                isOpen = true
            end 
        elseif i == 3 then
            value = sysAdatrr3[2]
            value = TeamUtils.getNatureNums(value)
            tip = lang("ATTR_" .. sysAdatrr3[1])
            if table.indexof(tempArr, sysAdatrr3[1]) ~= false then 
                value = value .. "%"
            end     
            if leftEquipStage >= 10 then                  
                isOpen = true                  
            end

        else
            value = sysAdatrr4[2]
            value = TeamUtils.getNatureNums(value)
            tip = lang("ATTR_" .. sysAdatrr4[1])
            if table.indexof(tempArr, sysAdatrr4[1]) ~= false then 
                value = value .. "%"
            end     
            if leftEquipStage >= 16 then                  
                isOpen = true                  
            end
        end

        -- 处理激活状态
        if isOpen == true then 
            if self._animFlag[i] == true then
                self._animFlag[i] = false
            end

            tipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            valueLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            warningLab:setVisible(false)
        else
            tipLab:disableEffect()
            valueLab:disableEffect()
            warningLab:disableEffect()
            tipLab:setColor(cc.c3b(120,120,120))
            valueLab:setColor(cc.c3b(120,120,120))
            warningLab:setColor(cc.c3b(120,120,120))
            warningLab:setPositionX(valueLab:getPositionX()+valueLab:getContentSize().width+5) 
            warningLab:setVisible(true)
        end
        tipLab:setString(tip .. "：")
        valueLab:setString("+" .. value)
        valueLab:setPosition(cc.p(tipLab:getPositionX()+tipLab:getContentSize().width,valueLab:getPositionY()))
        warningLab:setPositionX(valueLab:getPositionX()+valueLab:getContentSize().width+5) 
    end



    self:updateRuneStageItemData()

    local upgradeBtn = self:getUI("bg.panel1.upgradeBg.upgradeBtn")
    local upgradefiveBtn = self:getUI("bg.panel1.upgradeBg.upgradefiveBtn")
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local sysEquipmentLevel = tab:EquipmentLevel(leftEquipLevel)
    if (leftEquipLevel) > tab.setting["G_MAX_TEAMLEVEL"].value then
        sysEquipmentLevel = tab:EquipmentLevel(tab.setting["G_MAX_TEAMLEVEL"].value)
    end

    local goldValue = self:getUI("bg.panel1.upgradeBg.goldValue")
    goldValue:disableEffect()

    local activityModel = self._modelMgr:getModel("ActivityModel")
    local openActivity = activityModel:getAbilityEffect(activityModel.PrivilegIDs.PrivilegID_23)
    local costGold = sysEquipmentLevel.cost
    costGold = costGold * (1 + openActivity)
    goldValue:setString(costGold)
    local goldImg = self:getUI("bg.panel1.upgradeBg.goldImg")
    goldValue:setPositionX(goldImg:getPositionX()+goldImg:getContentSize().width * goldImg:getScale() + 5)

    local function btnTip()
        if userData.gold < sysEquipmentLevel.cost then 
            -- self._viewMgr:showTip(lang("TIPS_BINGTUAN_05"))
            DialogUtils.showLackRes( )
        end
        if self._teamData.level <= leftEquipLevel then 
            self._viewMgr:showTip(lang("TIPS_BINGTUAN_06"))
        elseif self._teamData.level > tab.setting["G_MAX_TEAMLEVEL"].value then
            self._viewMgr:showTip(lang("TIPS_BINGTUAN_06"))
        end
    end

    if sysEquipmentLevel == nil or 
        userData.gold < sysEquipmentLevel.cost or 
        self._teamData.level == leftEquipLevel then

        self:registerClickEvent(upgradeBtn, function ()
            btnTip()
        end)
    else
        self:registerClickEvent(upgradeBtn, function ()
            btnTip()
            self:upgradeEquip(1)
        end)
    end

    if sysEquipmentLevel == nil or 
        userData.gold < sysEquipmentLevel.cost or 
        self._teamData.level == leftEquipLevel then

        self:registerClickEvent(upgradefiveBtn, function ()
            btnTip()
        end)
    else
        self:registerClickEvent(upgradefiveBtn, function ()
            btnTip()
            self:upgradeEquip(5)
        end)
    end
end


function TeamRuneView:updateRuneStageItemData()    
    local itemModel = self._modelMgr:getModel("ItemModel")
    for i=1,4 do
        local flag = 1
        local sysEquip = tab:Equipment(tab:Team(self._teamData.teamId).equip[i])
        local sysMater = sysEquip["mater" .. self._teamData["es" .. i]]
        -- 所需材料
        if sysMater then
            for k1,mater in pairs(sysMater) do
                -- systemItem = tab:Tool(mater[1])
                local _, tempItemCount = itemModel:getItemsById(mater[1])
                local approatchIsFlag = itemModel:approatchIsOpen(mater[1])
                if tempItemCount < mater[2] then
                    -- print("材料不够")
                    flag = -1
                    if approatchIsFlag == false then
                        flag = -2
                        break
                    end
                end
            end    
        else
            flag = -3
        end

        local tempEquip = tab:Team(self._teamData.teamId)
        local teamModel = self._modelMgr:getModel("TeamModel")
        local equip = self:getUI("bg.equiptList.equip" .. i)
        local backQuality = teamModel:getTeamQualityByStage(self._teamData["es" .. i])
        local sysEquip = tab:Equipment(tempEquip.equip[i])
        local param = {teamData = self._teamData, index = i, sysRuneData = sysEquip,isUpdate = flag, quality = backQuality[1], quaAddition = backQuality[2], eventStyle = 0}
        local iconRune = equip:getChildByFullName("runeIcon")
        if iconRune == nil then 
            iconRune = IconUtils:createTeamRuneIconById(param)
            iconRune:setName("runeIcon")
            -- iconRune:setScale(0.9)
            iconRune:setAnchorPoint(cc.p(0, 0))
            iconRune:setPosition(20,20)
            equip:addChild(iconRune)
        else 
            IconUtils:updateTeamRuneIconByView(iconRune, param)
        end

        local xuanzhong = equip:getChildByName("xuanzhong")
        if self._curSelectIndex == i then
            if xuanzhong then
                xuanzhong:setVisible(true)
            end
        else
            if xuanzhong then
                xuanzhong:setVisible(false)
            end
        end
    end

    local image_113 = self:getUI("bg.Image_113")
    local upgradeStageBtn = self:getUI("bg.panel1.upgradeStageBtn")
    local animBtn = upgradeStageBtn:getChildByName("anim")

    local sysTeam = tab:Team(self._teamData.teamId)

    local teamModel = self._modelMgr:getModel("TeamModel")
    local sysEquipment = tab:Equipment(sysTeam.equip[self._curSelectIndex])

    local leftEquipLevel = tonumber(self._teamData["el" .. self._curSelectIndex])
    local leftEquipStage = tonumber(self._teamData["es" .. self._curSelectIndex])
    local flag = false
    if not sysEquipment["mater" .. leftEquipStage] then
        flag = true
    end

    local isActive = 1 

    local stageTipLab = self:getUI("bg.panel1.Label_114")
    if leftEquipStage < tab.setting["G_MAX_TEAMSTAGE"].value and sysEquipment.level[leftEquipStage] > leftEquipLevel then
        stageTipLab:setString("需要:装备" .. sysEquipment.level[leftEquipStage] .. "级")
        isActive = 2
    else
        stageTipLab:setString("")
    end

    if leftEquipStage < tab.setting["G_MAX_TEAMSTAGE"].value then
        local itemModel = self._modelMgr:getModel("ItemModel")
        local maters = sysEquipment["mater" .. leftEquipStage]

        -- 所需材料
        for i=1,#maters do
            local systemItem = tab:Tool(maters[i][1])
            local tempItems, tempItemCount = itemModel:getItemsById(maters[i][1])
            local itemBg = image_113:getChildByFullName("Image" .. i)

            local haveItemNum = itemBg:getChildByFullName("haveNumLab")
            
            local tmpLab = itemBg:getChildByFullName("tmpLab")
            local needItemNum = itemBg:getChildByFullName("needNumLab")

            haveItemNum:disableEffect()
            tmpLab:disableEffect()
            needItemNum:disableEffect()

            haveItemNum:setString(tempItemCount)
            needItemNum:setString(maters[i][2])

            haveItemNum:setAnchorPoint(cc.p(0,0.5))

            haveItemNum:setVisible(false)
            needItemNum:setVisible(false)
            local tmpLabStr = tempItemCount .. "/" .. maters[i][2]
            tmpLab:setString(tmpLabStr)
            tmpLab:setAnchorPoint(cc.p(0,0.5))
            local tmpLabx = (itemBg:getContentSize().width - tmpLab:getContentSize().width)*0.5
            tmpLab:setPositionX(tmpLabx)
            
            if tempItemCount < maters[i][2] then
                self._haveItemFlag = true
                isActive = 3
                haveItemNum:setColor(UIUtils.colorTable.ccUIBaseColor6)
                tmpLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
                needItemNum:setColor(UIUtils.colorTable.ccUIBaseColor6)
            else
                self._haveItemFlag = false
                haveItemNum:setColor(UIUtils.colorTable.ccUIBaseColor9)
                tmpLab:setColor(UIUtils.colorTable.ccUIBaseColor9)
                needItemNum:setColor(UIUtils.colorTable.ccUIBaseColor9)
            end
            local itemIcon = itemBg:getChildByFullName("itemIcon")
            if itemIcon then
                itemIcon:removeFromParent()
            end
           
            local itemRedFlag = self._modelMgr:getModel("ItemModel"):approatchIsOpen(maters[i][1])
            local suo = (itemRedFlag == true and self._haveItemFlag) and 2 or nil
            itemIcon = IconUtils:createItemIconById({itemId = maters[i][1],num = -1,suo = suo ,itemData = systemItem,eventStyle = 3,clickCallback = function( )
                local toolD = tab:Tool( maters[i][1] )
                local approach = toolD["approach"]
                    self._viewMgr:showDialog("bag.DialogAccessTo", {goodsId =  maters[i][1],needItemNum = maters[i][2]}, true)
            end})
            itemIcon:setScale(0.76)
            itemBg:addChild(itemIcon)
            itemIcon:setName("itemIcon")
            local itemIconx = (itemBg:getContentSize().width - itemIcon:getContentSize().width*itemIcon:getScaleX())*0.5
            itemIcon:setPosition(itemIconx,itemBg:getPositionY() + tmpLab:getContentSize().height - 38)

            if itemRedFlag == true and self._haveItemFlag then
                self._haveItemFlag = false
            end

            if itemIcon == nil then
                break
            end

            itemBg:setVisible(true)
        end

        -- 设置材料位置
        local image1 = image_113:getChildByFullName("Image1")
        local tempPosX = (image_113:getContentSize().width - image1:getContentSize().width * #maters)*0.5 
        + image1:getContentSize().width*0.5 - 5
        for i=1,#maters do    
            local itemBg = image_113:getChildByFullName("Image" .. i)
            itemBg:setPositionX(tempPosX)
            tempPosX = tempPosX + 75
        end
        
        for i=#maters + 1, 4 do
            local itemBg = image_113:getChildByFullName("Image" .. i)
            if itemBg == nil then 
                break
            end
            itemBg:setVisible(false)
        end
        -- 装备进阶
        if isActive == 1 then
            if animBtn then
                animBtn:setVisible(true)
            end
            self:registerClickEvent(upgradeStageBtn, function ()
                self:upgradeStageEquip()
            end)

        else
            if animBtn then
                animBtn:setVisible(false)
            end
            self:registerClickEvent(upgradeStageBtn, function ()
                if isActive == 2 then
                    self._viewMgr:showTip(lang("TIPS_BINGTUAN_03"))
                else
                    self._viewMgr:showTip(lang("TIPS_BINGTUAN_04"))
                end
            end)
        end

        local topstage = self:getUI("bg.Image_113.topstage")
        topstage:setVisible(false)
        local maxStage = self:getUI("bg.Image_113.maxstage")
        maxStage:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        maxStage:setVisible(false)
        upgradeStageBtn:setEnabled(true)
        upgradeStageBtn:setBright(true)
        upgradeStageBtn:setVisible(true)
    else
        if flag then
            flag = false
            for i=1,4 do
                local itemBg = image_113:getChildByFullName("Image" .. i)
                itemBg:setVisible(false)
            end
            local maxStage = self:getUI("bg.Image_113.maxstage")
            maxStage:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            maxStage:setVisible(true)
            local topstage = self:getUI("bg.Image_113.topstage")
            topstage:setVisible(true)
            upgradeStageBtn:setVisible(false)
            if animBtn then
                animBtn:setVisible(false)
            end
            upgradeStageBtn:setEnabled(false)
            upgradeStageBtn:setBright(false)
            self:registerClickEvent(upgradeStageBtn, function ()
                self._viewMgr:showTip("装备已达最高品阶")
            end)
        end
    end
end

--! @desc 装备升级
function TeamRuneView:upgradeEquip(inIsAuto)
    self:setChangeData()
    self._oldFight = TeamUtils:updateFightNum() -- self._teamData.score
    self._oldDataValue = clone(self._dataValue)
    local param = {teamId = self._teamData.teamId, positionId = self._curSelectIndex, level = inIsAuto}
    self._serverMgr:sendMsg("TeamServer", "upgradeEquip", param, true, {}, function (result)
        if self.upgradeEquipFinish then
            self:upgradeEquipFinish(result)
        end
        
    end)
end

function TeamRuneView:upgradeEquipFinish(inResult)
    if inResult["d"] == nil then 
        self._viewMgr:showTip("升级失败")
        return
    end

    audioMgr:playSound("Forge")
    local teamModel = self._modelMgr:getModel("TeamModel")
    local tempTeamData,tempTeamIndex = teamModel:getTeamAndIndexById(self._teamData.teamId)
    self._teamData = tempTeamData
    self:setChangeData()
    self:reflashItemData()

    self:qianghuachenggong(1)
end

--[[
--! @function upgradeStageEquip
--! @desc 装备进阶
--! @param 
--! @return 
--]]
function TeamRuneView:upgradeStageEquip()
    self._oldFight = TeamUtils:updateFightNum()
    self:setChangeData()
    self._oldDataValue = clone(self._dataValue)
    local param = {teamId = self._teamData.teamId, positionId = self._curSelectIndex}
    self._serverMgr:sendMsg("TeamServer", "upgradeStageEquip", param, true, {}, function (result)
        if self.upgradeStageEquipFinish then
            self:upgradeStageEquipFinish(result)
        end
    end)
    -- self:upgradeStageEquipFinish(result)
end

function TeamRuneView:upgradeStageEquipFinish(inResult)
    audioMgr:playSound("Craft")

    local tempTeamData, tempTeamIndex = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(self._teamData.teamId)
    self._teamData = tempTeamData

    self:setChangeData()
    
    --进阶成功特效
    local image_113 = self:getUI("bg.Image_113")
    local runeBg = self:getUI("bg.Image_111.Panel_39")
    local runeWoldPoint = runeBg:convertToWorldSpace(cc.p(0,0))
    local bg = self:getUI("bg")
    local pos1 = bg:convertToNodeSpace(cc.p(runeWoldPoint.x,runeWoldPoint.y))

    self:qianghuachenggong(2)
end


function TeamRuneView:setChangeData()
    local sysTeam = tab:Team(self._teamData.teamId)
    local sysEquipment = tab:Equipment(sysTeam.equip[self._curSelectIndex])
    local leftEquipLevel = tonumber(self._teamData["el" .. self._curSelectIndex])
    local leftEquipStage = tonumber(self._teamData["es" .. self._curSelectIndex])
    local leftArr1Result = BattleUtils.getEquipAttr(sysEquipment, leftEquipStage, leftEquipLevel)
    self._dataValue[1] = TeamUtils.getNatureNums(leftArr1Result)
    local leftArr2Result = BattleUtils.getEquipAttr1(sysEquipment, leftEquipStage, leftEquipLevel)
    self._dataValue[2] = TeamUtils.getNatureNums(leftArr2Result)
end

--[[
--! @function teamPiaoNature
--! @desc 点击道具飘字
--! @param param 飘字列表
--! @param count 飘字 
--! @return 
--]]
function TeamRuneView:teamPiaoNature(time, runeIcon, str)
    if str == 1 then
        str = "teamImageUI_img24"
    else
        str = "teamImageUI_img25"
    end

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

function TeamRuneView:teamPiaoNature1()
    local runeIcon = self:getUI("bg.Image_111.runeIcon")

    local sysTeam = tab:Team(self._teamData.teamId)
    local sysEquipment = tab:Equipment(sysTeam.equip[self._curSelectIndex])

    local param = {}
    for i=1,2 do
        local oldData = self._oldDataValue[i]
        local newData = self._dataValue[i]
        local data = newData - oldData
        if i == 1 then
            param[i] = lang("ATTR_" .. sysEquipment["attr"]) .. "+" .. TeamUtils.getNatureNums(data)
        else
            param[i] = lang("ATTR_" .. sysEquipment["attr1"]) .. "+" .. TeamUtils.getNatureNums(data)
        end
    end

    for i=1,2 do
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


return TeamRuneView