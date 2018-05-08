--[[
    Filename:    WeaponsView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-09-04 16:37:48
    Description: File description
--]]

local WeaponsView = class("WeaponsView", BaseView)

function WeaponsView:ctor(data)
    WeaponsView.super.ctor(self)
    self.initAnimType = 2
    -- self._pageIndex = data.index
end

function WeaponsView:onInit()
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._weaponsModel = self._modelMgr:getModel("WeaponsModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    -- local userData = self._userModel:getData()

    self._weaponType = 1
    self._selectWeaponId = 1
    self._selectWeaponData = {}
    self._selectWeaponData.indexId = 1
    self._selectIndex = 1
    self._pageIndex = 1

    -- 该设备进过该功能
    self._weaponsModel:setWeapon()
    self._weaponsModel:setWeaponsSkillLock({0, 0})

    -- 进阶
    local tab1 = self:getUI("bg.rightSubBg.tab1")
    -- 升级
    local tab2 = self:getUI("bg.rightSubBg.tab2")
    -- 升星
    -- local tab3 = self:getUI("bg.rightSubBg.tab3")

    local ruleBtn = self:getUI("bg.weaponsLayer.weaPanel.ruleBtn")
    self:registerClickEvent(ruleBtn, function()
        self._viewMgr:showDialog("weapons.WeaponsDescDialog")
    end)

    UIUtils:setTabChangeAnimEnable(tab1,400,function(sender)self:tabButtonClick(sender, 1)end,nil,true)
    UIUtils:setTabChangeAnimEnable(tab2,400,function(sender)self:tabButtonClick(sender, 2)end,nil,true)
    -- UIUtils:setTabChangeAnimEnable(tab3,400,function(sender)self:tabButtonClick(sender, 3)end,nil,true)

    self._tabEventTarget = {}
    table.insert(self._tabEventTarget, tab1)
    table.insert(self._tabEventTarget, tab2)
    -- table.insert(self._tabEventTarget, tab3)

    self._itemCell = self:getUI("itemCell")
    self._itemCell:setVisible(false)

    local weaPanel = self:getUI("bg.weaponsLayer.weaPanel")
    self._zhandouliLab = cc.LabelBMFont:create("", UIUtils.bmfName_zhandouli_little)
    self._zhandouliLab:setName("zhandouli")
    self._zhandouliLab:setAnchorPoint(cc.p(0.5,0.5))
    self._zhandouliLab:setScale(0.6)
    self._zhandouliLab:setPosition(157, 150)
    weaPanel:addChild(self._zhandouliLab, 100)

    self._tips = self:getUI("bg.weaponsLayer.weaPanel.tableViewBg.tips")

    local natureTip = self:getUI("bg.natureTip")
    natureTip:setVisible(false)
    local closeTip = self:getUI("bg.natureTip.closeTip")
    self:registerClickEvent(closeTip, function()
        local natureTip = self:getUI("bg.natureTip")
        natureTip:setVisible(false)
    end)
    self:updateRightUI()
    self:addTableView()

    self:setRepleace()
    self:updateLeftPanel()

    self:updateRightSubBg()

    self:tabButtonClick(self:getUI("bg.rightSubBg.tab" .. (self._pageIndex or 1)), (self._pageIndex or 1))
    -- self:tabButtonClick(self:getUI("bg.rightSubBg.tab" .. (self._pageIndex or 1)), (self._pageIndex or 1))

    self:listenReflash("WeaponsModel", self.reflashWeaponUI)
    self:listenReflash("UserModel", self.reflashWeaponUI)

    local txt = self:getUI("bg.bagBtn.txt")
    txt:enableOutline(UIUtils.colorTable.titleOutLineColor, 1)
    local txt = self:getUI("bg.extractBtn.txt")
    txt:enableOutline(UIUtils.colorTable.titleOutLineColor, 1)

    local bagBtn = self:getUI("bg.bagBtn")
    self:registerClickEvent(bagBtn, function()
        self._viewMgr:showView("weapons.WeaponsToolsBagView")
    end)

    local extractBtn = self:getUI("bg.extractBtn")
    self:registerClickEvent(extractBtn, function()
        self._viewMgr:showView("siege.SigeCardView")
    end)
    local cCostData = tab:Setting("DRAW_SW_COST4").value[1]
    local CostType = cCostData[1]
    local CostCount = cCostData[3]
    local have = self._userModel:getData()[CostType] or 0
    local status = false
    if have >= CostCount then
        status = true
    end
    UIUtils.addRedPoint(extractBtn,status,cc.p(60,60))

    local arrawImage = self:getUI("bg.weaponsLayer.leftRepleaceBtn.arrawImage")
    local fade1 = cc.MoveBy:create(0.5, cc.p(-5, 0))
    local fade2 = cc.MoveBy:create(0.5, cc.p(5, 0))
    local seq = cc.Sequence:create(fade1,fade2)
    local rep = cc.RepeatForever:create(seq)
    arrawImage:runAction(rep)

    local arrawImage = self:getUI("bg.weaponsLayer.rightRepleaceBtn.arrawImage")
    local fade1 = cc.MoveBy:create(0.5, cc.p(5, 0))
    local fade2 = cc.MoveBy:create(0.5, cc.p(-5, 0))
    local seq = cc.Sequence:create(fade1,fade2)
    local rep = cc.RepeatForever:create(seq)
    arrawImage:runAction(rep)

    local decomposeBtn = self:getUI("bg.decomposeBtn")
    decomposeBtn:setVisible(false)
    self:registerClickEvent(decomposeBtn, function()
        UIUtils:reloadLuaFile("weapons.WeaponsGradeNode")
        UIUtils:reloadLuaFile("weapons.WeaponsReformNode")
        UIUtils:reloadLuaFile("weapons.WeaponsBreakView")
        -- UIUtils:reloadLuaFile("weapons.WeaponsUnlockSuccessDialog")
        
        -- self._viewMgr:showDialog("weapons.WeaponsBreakView")
        -- self._viewMgr:showDialog("weapons.WeaponsUnlockSuccessDialog", {weaponId = 11, weaponType = 1})

        local weaponData = self._weaponsModel:checkTips()
        local weaponData = self._weaponsModel:getWeaponsAllData()
        dump(weaponData, "6666666========", 10)
        -- local weaponData = self._weaponsModel:getWeaponsDataByType(1)
        -- dump(weaponData, "6666666========", 10)
        -- local weaponData = self._weaponsModel:getAllWeaponsData()
        -- dump(weaponData, "6666666========", 10)
        -- local weaponData = self._weaponsModel:getWeaponsData()
        -- dump(weaponData, "6666666========", 10)
        -- local weaponData = self._weaponsModel:getUsePropsIdData()
        -- dump(weaponData, "6666666========", 10)
        -- local weaponData = self._weaponsModel:getNewPropsData()
        -- dump(weaponData, "6666666========", 10)
        -- print('weaponData==========', table.nums(weaponData))
        -- local weaponData = self._weaponsModel:getCanBreakProps()
        -- dump(weaponData, "6666666========", 10)
        -- self:test()
        -- local weaponData = self:getCanBreakProps()
        -- dump(weaponData, "6666666========", 10)

        -- self:checkTips()
    end)
    self:updateTip()
end

function WeaponsView:reflashWeaponUI()
    self:updateLeftPanel(self._selectWeaponId)
    if self._infoNode ~= nil and self._pageIndex == 1 then
        local param = {selectType = self._weaponType, selectWeaponId = self._selectWeaponId}
        self._infoNode:reflashUI(param)
    end
    if self._reformNode ~= nil and self._pageIndex == 2 then
        local param = {selectType = self._weaponType, selectWeaponId = self._selectWeaponId}
        self._reformNode:reflashUI(param)
    end
    self:updateTip()
end 


function WeaponsView:updateLeftPanel(weaponId)
    local siegeType = {
        [1] = {1,2,4},
        [2] = {2,3,1},
        [3] = {3,4,2},
        [4] = {4,1,3},
    }
    self._unLockWeapon = self._weaponsModel:getWeaponsData()
    self._weaponTypeData = self._weaponsModel:getWeaponsDataByType(self._weaponType) or {}
    local siegeTab = tab:SiegeWeaponType(self._weaponType)
    self._siegeListData = siegeTab.weaponId

    self._selectWeaponId = weaponId or self._siegeListData[1]
    if not weaponId then
        self._selectWeaponData.indexId = 1
    end

    self._tableView:reloadData()
    print("self._weaponType======66666666666==", self._weaponType)

    local tsiegeType = siegeType[self._weaponType]
    for i=1,3 do
        local weabg = self:getUI("bg.weaponsLayer.weabg" .. i)
        weabg:loadTexture("weaponImageUI_img" .. tsiegeType[i] .. ".png", 1)
    end

    local weaponImgBg = self:getUI("bg.weaponsLayer.weaPanel.weaponImgBg")
    if self._weaponType == 4 then
        weaponImgBg:loadTexture("weaponImageUI_img24.png", 1)
    else
        weaponImgBg:loadTexture("weaponImageUI_img25.png", 1)
    end

    local typeNameStr = lang(siegeTab.name)
    local typeName = self:getUI("bg.weaponsLayer.weaPanel.typeName")
    typeName:setString(typeNameStr)

    -- local tScore = self:getWeaponScore()
    -- self._zhandouliLab:setString(tScore)

    self:updateCurrencyUI()
    self:updateRightSubBg()

    local str = lang("SIEGECON_TIPS" .. (6 + self._weaponType))
    if self._pageIndex == 2 then
        str = lang("SIEGECON_TIPS" .. (10 + self._weaponType))
    end
    self._tips:setString(str)
end

function WeaponsView:getWeaponScore()
    local tScore = 0
    local weaponData = self._weaponsModel:getWeaponsData()
    -- self._unLockWeapon[weaponId]
    if weaponData[self._selectWeaponId] then
        tScore = weaponData[self._selectWeaponId]
        local weaponTypeData = self._weaponTypeData
        local propsData = self._weaponsModel:getPropsData()
        for i=1,4 do
            local sp = weaponTypeData["sp" .. i]
            if sp ~= 0 then
                if propsData[sp] and propsData[sp].score then
                    tScore = tScore + propsData[sp].score
                end
            end
        end
    end

    if tScore == 0 then
        tScore = ""
    else
        tScore = "a" .. tScore
    end
    return tScore
end 

function WeaponsView:isTeamLockWeapons(data)
    local flag = 0
    local teamId = data[1]
    local teamStar = data[2]
    local teamStage = data[3]
    local teamData = self._teamModel:getTeamAndIndexById(teamId)

    if teamData then
        flag = 1
        local _teamStar = teamData.star
        local _teamStage = teamData.stage
        if _teamStar >= teamStar and _teamStage >= teamStage then
            flag = 2
        end
    end
    return flag
end


function WeaponsView:getAttrData()
    local attr = {}
    for i=1,6 do
        attr[i] = 0
    end
    local wattrData = self._weaponsModel:getWeaponsAttr(self._selectWeaponId, self._weaponType)
    for key=1,6 do
        attr[key] = attr[key] + wattrData[key]
    end
    local weaponTypeData = self._weaponsModel:getWeaponsDataByType(self._weaponType)
    for i=1,4 do
        local propKey = weaponTypeData["sp" .. i]
        if propKey ~= 0 then
            local attrData = self._weaponsModel:getPropsAttr(propKey)
            for key=1,6 do
                attr[key] = attr[key] + attrData[key]
            end
        end
    end
    return attr
end

function WeaponsView:updateRightLockState(weaponsId)
    local weaponsTab = tab:SiegeWeapon(weaponsId)
    local lockTeam = weaponsTab.weaponLock or {}

    -- 描述
    local richtextBg = self:getUI("bg.rightSubBg.panel.richtextBg")
    local richText = richtextBg:getChildByName("richText")
    if richText ~= nil then
        richText:removeFromParent()
    end
    local desc = lang(weaponsTab.des)
    if string.find(desc, "color=") == nil then
        desc = "[color=462800]"..desc.."[-]"
    end   
    richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5)
    richText:setName("richText")
    richtextBg:addChild(richText)

    -- 技能展示
    local skillBg = self:getUI("bg.rightSubBg.panel.skillBg")
    local wSkill = weaponsTab.skill
    for i=1,table.nums(wSkill) do
        local _skill = wSkill[i]
        local skillEffect = tab:SiegeSkillDes(_skill)
        -- print("_skill==========", _skill)
        local param = {sysSkill = skillEffect}
        local skillIcon = skillBg:getChildByFullName("skillIcon" .. i)
        if not skillIcon then
            skillIcon = IconUtils:createWeaponsSkillIcon(param)
            skillIcon:setName("skillIcon" .. i)
            skillIcon:setScale(0.7)
            skillIcon:setPosition(80*i-80, 0)
            skillBg:addChild(skillIcon)
        else
            IconUtils:updateWeaponsSkillIcon(skillIcon, param)
        end

        self:registerClickEvent(skillIcon, function()
            local attrData = self:getAttrData()
            local attrValue = self._weaponsModel:getAttrValue(attrData)
            self:showHintView("global.GlobalTipView",{tipType = 24, node = skillIcon,attrValue=attrValue, id = _skill, posCenter = true})
            -- self:showHintView("global.GlobalTipView",{tipType = 2, node = skillIcon, id = _skill, posCenter = true})
        end)
    end

    -- 兵团限制
    local teamLockBg = self:getUI("bg.rightSubBg.panel.teamLockBg")
    -- for i,v in ipairs(lockTeam) do
    local tlock = true
    for i=1,table.nums(lockTeam) do
        local v = lockTeam[i]
        local lockWeapons = self:isTeamLockWeapons(v)
        print("lockWeapons=========", lockWeapons)
        local tteamIcon
        if lockWeapons == 0 then
            local teamIcon = teamLockBg:getChildByName("teamIcon" .. i)
            if teamIcon then
                teamIcon:setVisible(false)
            end
            local sysTeam = tab:Team(v[1])
            local param = {sysTeamData = sysTeam,isGray = true ,eventStyle = 0}
            local teamIcon = teamLockBg:getChildByFullName("teamSysIcon" .. i)
            if not teamIcon then
                teamIcon = IconUtils:createSysTeamIconById(param)
                teamIcon:setName("teamSysIcon" .. i)
                teamIcon:setScale(0.6)
                teamIcon:setPosition(100*i-90, 20)
                teamLockBg:addChild(teamIcon)
            else
                IconUtils:updateSysTeamIconByView(teamIcon, param)
            end
            teamIcon:setVisible(true)
            tteamIcon = teamIcon
        else
            local teamIcon = teamLockBg:getChildByFullName("teamSysIcon" .. i)
            if teamIcon then
                teamIcon:setVisible(false)
            end

            local sysTeam = tab:Team(v[1])
            local teamData = self._teamModel:getTeamAndIndexById(v[1])
            local backQuality = self._teamModel:getTeamQualityByStage(teamData.stage)
            local teamIcon = teamLockBg:getChildByName("teamIcon" .. i)
            local param = {teamData = teamData, sysTeamData = sysTeam, quality = backQuality[1], quaAddition = backQuality[2],  eventStyle = 0} 
            if teamIcon == nil then 
                teamIcon = IconUtils:createTeamIconById(param)
                teamIcon:setName("teamIcon" .. i)
                teamIcon:setPosition(100*i-90, 20)
                teamIcon:setAnchorPoint(0, 0)
                teamIcon:setScale(0.6)
                teamLockBg:addChild(teamIcon, 10)
            else
                IconUtils:updateTeamIconByView(teamIcon, param)
            end
            teamIcon:setVisible(true)
            tteamIcon = teamIcon
        end

        local limitStr = v[2] .. "星" .. lang("SIEGECON_ADVANCED_" .. v[3])
        local limitLab = teamLockBg:getChildByName("limitLab" .. i)
        if not limitLab then
            limitLab = cc.Label:createWithTTF(limitStr, UIUtils.ttfName, 16)
            limitLab:setName("limitLab" .. i)
            limitLab:setColor(cc.c3b(138,92,29))
            limitLab:setPosition(100*i-59, 10)
            limitLab:setAnchorPoint(0.5, 0.5)
            teamLockBg:addChild(limitLab,3)
        else
            limitLab:setString(limitStr)
        end

        local limitStr = "未达成"
        local conLab = teamLockBg:getChildByName("conLab" .. i)
        if not conLab then
            conLab = cc.Label:createWithTTF(limitStr, UIUtils.ttfName, 16)
            conLab:setName("conLab" .. i)
            conLab:setColor(cc.c3b(138,92,29))
            conLab:setPosition(100*i-59, -8)
            conLab:setAnchorPoint(0.5, 0.5)
            teamLockBg:addChild(conLab,3)
        end

        if lockWeapons == 0 then
            if tlock == true then
                tlock = false
            end
            limitStr = "未获得"
            conLab:setColor(cc.c3b(100,82,82))
            self:registerClickEvent(tteamIcon, function()
                print("未获得")
                local goods = tab.team[v[1]].goods
                self._viewMgr:showDialog("bag.DialogAccessTo",{goodsId = goods, needItemNum = 0},true)
            end)
        elseif lockWeapons == 1 then
            if tlock == true then
                tlock = false
            end
            limitStr = "未达成"
            conLab:setColor(cc.c3b(205,32,30))
            self:registerClickEvent(tteamIcon, function()
                print("未达成")
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", {iconType = 1, iconId = v[1]}, true)
            end)
        elseif lockWeapons == 2 then
            limitStr = "已达成"
            conLab:setColor(cc.c3b(28,162,22))
            self:registerClickEvent(tteamIcon, function()
                print("已达成")
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", {iconType = 1, iconId = v[1]}, true)
            end)
        end
        conLab:setString(limitStr)
    end

    local weaponLockCost = weaponsTab.weaponLockCost or {}
    local costValue = weaponLockCost[1][3]
    local costNum = self:getUI("bg.rightSubBg.panel.costBg.costNum")
    costNum:setString(costValue)
    local userData = self._userModel:getData()
    local userSiegePropExp = userData.siegePropExp or 0
    if userSiegePropExp >= costValue then
        costNum:setColor(cc.c3b(78,50,13))
        local unlockBtn = self:getUI("bg.rightSubBg.panel.unlockBtn")
        self:registerClickEvent(unlockBtn, function()
            if tlock == true then
                local param = {type = self._weaponType, weaponId = weaponsId}
                self:unlockWeapon(param, weaponsId)
            else
                self._viewMgr:showTip(lang("SIEGECON_TIPS19"))
            end
        end)
    else
        costNum:setColor(cc.c3b(205,32,30))
        local unlockBtn = self:getUI("bg.rightSubBg.panel.unlockBtn")
        self:registerClickEvent(unlockBtn, function()
            local param = {indexId = 14}
            self._viewMgr:showDialog("global.GlobalPromptDialog", param)
        end)
    end

end


function WeaponsView:getLockWeapon(weaponsId)
    local weaponsTab = tab:SiegeWeapon(weaponsId)
    local lockTeam = weaponsTab.weaponLock or {}
    -- 兵团限制
    local tlock = true
    for i=1,table.nums(lockTeam) do
        local v = lockTeam[i]
        local lockWeapons = self:isTeamLockWeapons(v)
        if lockWeapons == 0 then
            if tlock == true then
                tlock = false
            end
            -- limitStr = "未获得"
        elseif lockWeapons == 1 then
            if tlock == true then
                tlock = false
            end
        --     limitStr = "未达成"
        -- elseif lockWeapons == 2 then
        --     limitStr = "已达成"
        end
    end
    return tlock
end

function WeaponsView:unlockWeapon(param, weaponsId)
    dump(param)
    self._serverMgr:sendMsg("WeaponServer", "unlockWeapon", param, true, {}, function (result)
        local callback = function()
            local fightBg = self:getUI("bg")
            local powercount = tab:SiegeWeapon(weaponsId).powercount
            TeamUtils:setFightAnim(fightBg, {oldFight = 0, newFight = powercount, x = fightBg:getContentSize().width*0.5-100, y = fightBg:getContentSize().height - 200})
        end
        self._viewMgr:showDialog("weapons.WeaponsUnlockSuccessDialog", {weaponId = self._selectWeaponId, weaponType = self._weaponType, callback = callback})
        -- dump(result, "result=======", 10)
        -- self:updateCurrencyUI()
        -- self:updateRightSubBg()
        -- self:updateLeftPanel(self._selectWeaponId)

        self:updateLeftPanel(self._selectWeaponId)
    end)
end



function WeaponsView:updateRightAllState(weaponsId)

end


function WeaponsView:updateRightSubBg()
    local weaponsId = self._selectWeaponId
    local weaponsData = self._weaponsModel:getWeaponsData()

    if not weaponsData[weaponsId] then
        local tab1 = self:getUI("bg.rightSubBg.tab1")
        local tab2 = self:getUI("bg.rightSubBg.tab2")
        tab1:setVisible(false)
        tab2:setVisible(false)

        local panel = self:getUI("bg.rightSubBg.panel")
        panel:setVisible(true)

        local panel1 = self:getUI("bg.rightSubBg.panel1")
        panel1:setVisible(false)

        self:updateRightLockState(weaponsId)
    else
        local tab1 = self:getUI("bg.rightSubBg.tab1")
        local tab2 = self:getUI("bg.rightSubBg.tab2")
        tab1:setVisible(true)
        tab2:setVisible(true)

        local panel = self:getUI("bg.rightSubBg.panel")
        panel:setVisible(false)

        local panel1 = self:getUI("bg.rightSubBg.panel1")
        panel1:setVisible(true)

    end
end



function WeaponsView:tabButtonClick(sender, key)
    if sender == nil then 
        return 
    end
    if self._tabName == sender:getName() then 
        return 
    end
    for k,v in pairs(self._tabEventTarget) do
        if v ~= sender then
            self:tabButtonState(v, false, k)
        end
    end
    local isFirst = not self._preBtn
    if self._preBtn then
        UIUtils:tabChangeAnim(self._preBtn,nil,true,true)
    else
        self:switchPanel( sender,key )
    end
    self._preBtn = sender
    UIUtils:tabChangeAnim(sender,function( )
        self:tabButtonState(sender, true, key)
        ScheduleMgr:delayCall(5, self, function( )
            if not self.switchPanel then return end
            self:switchPanel( sender,key )
        end)
    end,nil,true)


end

-- 选项卡状态切换
function WeaponsView:tabButtonState(sender, isSelected, key)
    local titleNames = {
        "  升级 ",
        "  改造 ",
        "  技能 ",
    }
    local shortTitleNames = {
        "  升级 ",
        "  改造 ",
        "  技能 ",
    }
    local tabtxt = sender:getChildByFullName("tabtxt")
    tabtxt:setString("")

    sender:setBright(not isSelected)
    sender:setEnabled(not isSelected)
    sender:getTitleRenderer():disableEffect()
    -- sender:setTitleFontSize(32)
    if isSelected then
        sender:setTitleText(titleNames[key])
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor2)
    else
        sender:setTitleText(shortTitleNames[key])
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor1)
    end
end

function WeaponsView:switchPanel(sender,key )
    -- for k,v in pairs(self._tabEventTarget) do
    --     if v:getName() ~= sender:getName() then 
    --         self:tabButtonState(v, false)
    --     end
    -- end
    -- self:tabButtonState(sender, true)
    local baseInfoNode = self:getUI("bg.rightSubBg.panel1")
    if sender:getName() == "tab1" then  -- 升级
        self._pageIndex = 1
        -- self._viewMgr:showTip("升级暂未开放")
        if self._infoNode == nil then 
            local callback = function()
                self:updateNatureTip()
            end
            self._infoNode = self:createLayer("weapons.WeaponsGradeNode", {callback = callback})
            self._infoNode:setPosition(-10, 0)
            baseInfoNode:addChild(self._infoNode,5)
        end
        local param = {selectType = self._weaponType, selectWeaponId = self._selectWeaponId}
        self._infoNode:reflashUI(param)
        self._infoNode:setVisible(true)

        if self._reformNode ~= nil then 
            self._reformNode:setVisible(false)
        end
    elseif sender:getName() == "tab2" then -- 改造
        self._pageIndex = 2
        -- self._viewMgr:showTip("改造暂未开放")
        -- print("升级")

        local param = {selectType = self._weaponType, selectWeaponId = self._selectWeaponId}
        if self._reformNode == nil then 
            self._reformNode = self:createLayer("weapons.WeaponsReformNode", param)
            baseInfoNode:addChild(self._reformNode,5)
        end
        self._reformNode:reflashUI(param)
        self._reformNode:setVisible(true)

        if self._infoNode ~= nil then 
            self._infoNode:setVisible(false)
        end
    end
    local str = lang("SIEGECON_TIPS" .. (6 + self._weaponType))
    if self._pageIndex == 2 then
        str = lang("SIEGECON_TIPS" .. (10 + self._weaponType))
    end
    self._tips:setString(str)
    self:setNavigation()
end


function WeaponsView:updateTip()
    local weaponTypeData = self._weaponsModel:getWeaponsDataByType(self._weaponType) or {}
    local hint1 = self:getUI("bg.rightSubBg.tab1.hint")
    hint1:setVisible(false)
    local hint2 = self:getUI("bg.rightSubBg.tab2.hint")
    hint2:setVisible(false)

    if weaponTypeData.onGrade == true then
        hint1:setVisible(true)
    end
    if weaponTypeData.onInsert == true or weaponTypeData.onReplace ~= 0 then
        hint2:setVisible(true)
    end
end


--[[
用tableview实现
--]]
function WeaponsView:addTableView()
    local tableViewBg = self:getUI("bg.weaponsLayer.weaPanel.tableViewBg")
    local theight = tableViewBg:getContentSize().height+100
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width-25, theight))
    self._tableView:setDelegate()
    self._tableView:setDirection(0)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(10, 0)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(true)
    -- self._tableView:reloadData()
    if self._tableView.setDragSlideable ~= nil then 
        self._tableView:setDragSlideable(true)
    end
    tableViewBg:addChild(self._tableView)
end

-- 返回cell的数量
function WeaponsView:numberOfCellsInTableView(table)
   return self:getTableNum()
end

function WeaponsView:getTableNum()
   return table.nums(self._siegeListData)
end

-- cell的尺寸大小
function WeaponsView:cellSizeForTable(table,idx) 
    local width = 100 
    local height = 86
    return height, width
end

-- 创建在某个位置的cell
function WeaponsView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx + 1
    local param = self._siegeListData[indexId]
    if nil == cell then
        cell = cc.TableViewCell:new()
        local listCell = self._itemCell:clone()
        listCell:setName("listCell")
        listCell:setVisible(true)
        listCell:setAnchorPoint(0, 0)
        listCell:setPosition(10, 0)
        cell:addChild(listCell)
    end

    local listCell = cell:getChildByName("listCell")
    self:updateCell(listCell, indexId, param)

    return cell
end


function WeaponsView:updateCell(inView, indexId, weaponId)
    print("==========", weaponId, indexId)
    local weaponsTab = tab:SiegeWeapon(weaponId)

    local itemName = inView:getChildByName("itemName")
    local itemStr = lang(weaponsTab.name)
    itemName:setString(itemStr)

    local lockImg = inView:getChildByName("lockImg")
    local param = {weaponsTab = weaponsTab}
    local weaponIcon = inView:getChildByName("weaponIcon")
    if not weaponIcon then
        weaponIcon = IconUtils:createWeaponsIconById(param)
        weaponIcon:setName("weaponIcon")
        weaponIcon:setScale(0.9)
        weaponIcon:setPosition(-2, 25)
        inView:addChild(weaponIcon)
    else
        IconUtils:updateWeaponsIcon(weaponIcon, param)
    end
    if weaponIcon.mc1 then
        weaponIcon.mc1:setVisible(false)
    end
    if weaponIcon.mc2 then
        weaponIcon.mc2:setVisible(false)
    end
    if self._unLockWeapon[weaponId] then
        if lockImg then
            lockImg:setVisible(false)
        end
        weaponIcon:setSaturation(0)
    else
        local tlock = self:getLockWeapon(weaponId)
        weaponIcon:setSaturation(-100)
        if tlock == true then
            if not weaponIcon.mc1 then
                weaponIcon.mc1 = mcMgr:createViewMC("jinengsuo_qianghua", true, false)
                weaponIcon.mc1:setPosition(44, 70)
                inView:addChild(weaponIcon.mc1, 20)
            else
                weaponIcon.mc1:setVisible(true)
            end

            if not weaponIcon.mc2 then
                weaponIcon.mc2 = mcMgr:createViewMC("jinengkejiesuosaoguang_qianghua", true, false)
                weaponIcon.mc2:setPosition(44, 70)
                inView:addChild(weaponIcon.mc2, 19)
            else
                weaponIcon.mc2:setVisible(true)
            end
            if lockImg then
                lockImg:setVisible(false)
            end
        else
            if lockImg then
                lockImg:setVisible(true)
            end
        end
            -- param = {weaponsTab = weaponsTab, suo = true}
    end

    local xuanzhong = inView.xuanzhong
    if not xuanzhong then
        xuanzhong = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
        xuanzhong:setName("xuanzhong")
        xuanzhong:gotoAndStop(1)
        xuanzhong:setPosition(43, 70)
        xuanzhong:setScale(0.86)
        inView:addChild(xuanzhong,50)
        inView.xuanzhong = xuanzhong
    end

    if self._selectWeaponData and (self._selectWeaponData.indexId == indexId) then
        if xuanzhong then
            xuanzhong.indexId = indexId
            xuanzhong:setVisible(true)
            self._selectWeaponData = xuanzhong
        end
    else
        if xuanzhong then
            xuanzhong:setVisible(false)
        end
    end

    self:registerClickEvent(weaponIcon, function()
        local txz = self._selectWeaponData
        if txz then
            txz:setVisible(false)
            txz.indexId = nil
        end
        self._selectWeaponData = xuanzhong
        xuanzhong:setVisible(true)
        xuanzhong.indexId = indexId
        self._selectWeaponId = weaponId
        self:updateCurrencyUI()
        self:updateRightSubBg()
        self:reflashWeaponUI()
        -- self:updateCell(inView, indexId, weaponId)
    end)
end

function WeaponsView:updateCurrencyUI()
    local weaponId = self._selectWeaponId
    local weaponsTab = tab:SiegeWeapon(weaponId)
    local weaponTypeData = self._weaponTypeData
    local weaponImgPos = weaponsTab.pos or {0, 0}
    if self._weaponImg then
        local fileName = "asset/uiother/weapon/Weapon_" .. weaponId .. ".png"
        self._weaponImg:loadTexture(fileName, 0)
        self._weaponImg:setPosition(157+weaponImgPos[1] , 226+weaponImgPos[2])
    end

    if self._lockImg then
        local lvStr
        local level = weaponTypeData.lv or 1
        local nameStr = lang(weaponsTab.name) 
        if self._unLockWeapon[weaponId] then
            self._lockImg:setVisible(false)
            if self._weaponName then
                lvStr = level .. "级" .. nameStr
            end
            self._weaponName:setString(lvStr)
            local tScore = self:getWeaponScore()
            self._zhandouliLab:setString(tScore)
        else
            self._weaponName:setString(nameStr)
            self._lockImg:setVisible(true)
            local tScore = self:getWeaponScore()
            self._zhandouliLab:setString(tScore)
        end
    end
end

function WeaponsView:reflashUI()

end


function WeaponsView:getAsyncRes()
    return 
        {
            {"asset/ui/weapons.plist", "asset/ui/weapons.png"},
            {"asset/ui/weapons1.plist", "asset/ui/weapons1.png"},
        }
end

function WeaponsView:getBgName()
    return "bg_005.jpg"
end

function WeaponsView:setNavigation()
    if not self._naviTypes then
        self._naviTypes = {
            [1] = {"SiegeWeaponExp","SiegePropExp","Gem"},
            [2] = {"SiegePropExp","Gold","Gem"},
        }
    end
    self._viewMgr:showNavigation("global.UserInfoView",{types = self._naviTypes[1],titleTxt = "战争器械"})
    -- self._viewMgr:showNavigation("global.UserInfoView",{types = self._naviTypes[self._pageIndex],titleTxt = "战争器械"})
    -- if not self.__popAnimOver then 
    --     self._viewMgr:getNavigation("global.UserInfoView"):setOpacity(0)
    -- end

    -- self._viewMgr:showNavigation("global.UserInfoView",{types = {"SiegeWeaponExp","Gold","siegePropExp"},title = "globalTitleUI_team.png",titleTxt = "兵团"})
end

-- function WeaponsView:setNoticeBar()
--     self._viewMgr:hideNotice(true)
-- end

-- function WeaponsView:getCommentData()
--     -- dump(self._curSelectTeam)
--     local param = {ctype = 1, id = self._curSelectTeam.teamId}
--     self._serverMgr:sendMsg("CommentServer", "getCommentData", param, true, {}, function(result)
--         dump(result)
--         self._viewMgr:showDialog("team.TeamCommentDialog", {teamId = self._curSelectTeam.teamId})
--     end)
-- end

function WeaponsView:setRepleace()
    local leftRepleaceBtn = self:getUI("bg.weaponsLayer.leftRepleaceBtn")
    self:registerClickEvent(leftRepleaceBtn, function()
        self._weaponsModel:setWeaponsSkillLock({0, 0})
        self._selectIndex = 1
        self:repleaceData(-1)
        self:updateLeftPanel()
        self:reflashWeaponUI()
        print("self.leftRepleaceBtn=========", self._weaponType)
    end)

    local rightRepleaceBtn = self:getUI("bg.weaponsLayer.rightRepleaceBtn")
    self:registerClickEvent(rightRepleaceBtn, function()
        self._weaponsModel:setWeaponsSkillLock({0, 0})
        self._selectIndex = 1
        self:repleaceData(1)
        self:updateLeftPanel()
        self:reflashWeaponUI()
        print("self.rightRepleaceBtn=========", self._weaponType)
    end)

    local typeName = self:getUI("bg.weaponsLayer.weaPanel.typeName")
    typeName:setColor(cc.c3b(255,255,255))
    typeName:enable2Color(1, cc.c4b(255,227,113,255))

    local weaponName = self:getUI("bg.weaponsLayer.weaPanel.weaponName")
    weaponName:setColor(cc.c3b(252,244,197))
    -- weaponName:enable2Color(1, cc.c4b(255,227,113,255))
    weaponName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._weaponName = weaponName

    self._weaponImg = self:getUI("bg.weaponsLayer.weaPanel.weaponImg")
    self._lockImg = self:getUI("bg.weaponsLayer.weaPanel.lockImg")
end



function WeaponsView:repleaceData(inIndex)
    local ttype = self._weaponType
    ttype = ttype + inIndex
    if ttype >= 5 then
        ttype = 1
    end
    if ttype <= 0 then
        ttype = 4
    end
    self._weaponType = ttype
end

function WeaponsView:updateRightUI()
    local title = self:getUI("bg.rightSubBg.panel.titleBg1")
    UIUtils:adjustTitle(title, 10)
    local title = self:getUI("bg.rightSubBg.panel.titleBg2")
    UIUtils:adjustTitle(title, 10)
end

function WeaponsView:updateNatureTip()
    local natureTip = self:getUI("bg.natureTip")
    natureTip:setVisible(true)

    local attr = {}
    for i=1,6 do
        attr[i] = 0
    end

    -- 器械升级
    local wattrData = self._weaponsModel:getWeaponsAttr(self._selectWeaponId, self._weaponType)
    for i=1,3 do
        local natureValue = self:getUI("bg.natureTip.natureValue1_" .. i)
        local value = math.floor(wattrData[i]*10)*0.1
        natureValue:setString(value)
        attr[i] = attr[i] + wattrData[i]
    end

    local pattrData = self:getAttrData()
    for key=1,6 do
        attr[key] = attr[key] + pattrData[key]
    end
    -- 器械升级
    for i=1,3 do
        local natureValue = self:getUI("bg.natureTip.natureValue2_" .. i)
        local value = math.floor(pattrData[i]*10)*0.1
        natureValue:setString(value)
    end

    -- 配件激活(%)
    local attrValue = {}
    for i=1,3 do
        attrValue[i] = attr[i]*(attr[3+i]*0.01)
    end
    for i=1,3 do
        local natureValue = self:getUI("bg.natureTip.natureValue3_" .. i)
        local value = math.floor(attrValue[i]*10)*0.1
        natureValue:setString(value)
    end

    for i=1,3 do
        local natureValue = self:getUI("bg.natureTip.natureValue4_" .. i)
        local str = "(" .. pattrData[i+3] .. "%)"
        natureValue:setString(str)
    end

    local attrValue = {}
    for i=1,3 do
        attrValue[i] = attr[i]*(1 + attr[3+i]*0.01)
    end
    for i=1,3 do
        local natureValue = self:getUI("bg.natureTip.natureValue5_" .. i)
        local value = math.floor(attrValue[i]*10)*0.1
        natureValue:setString(value)
    end
end


function WeaponsView:getAttrData()
    local attr = {}
    for i=1,6 do
        attr[i] = 0
    end
    local weaponTypeData = self._weaponsModel:getWeaponsDataByType(self._weaponType)
    for i=1,4 do
        local propKey = weaponTypeData["sp" .. i]
        if propKey ~= 0 then
            local attrData = self._weaponsModel:getPropsAttr(propKey)
            for key=1,6 do
                attr[key] = attr[key] + attrData[key]
            end
        end
    end
    return attr
end


-- liushuai
function WeaponsView:onTop()
    local extractBtn = self:getUI("bg.extractBtn")
    local cCostData = tab:Setting("DRAW_SW_COST4").value[1]
    local CostType = cCostData[1]
    local CostCount = cCostData[3]
    local have = self._userModel:getData()[CostType] or 0
    local status = false
    if have >= CostCount then
        status = true
    end
    UIUtils.addRedPoint(extractBtn,status,cc.p(60,60))
end
return WeaponsView