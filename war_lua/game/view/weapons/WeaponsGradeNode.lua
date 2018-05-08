--[[
    Filename:    WeaponsGradeNode.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-09-08 15:25:33
    Description: File description
--]]

local WeaponsGradeNode = class("WeaponsGradeNode", BaseLayer)

local volumeChar = {"输出", "防御", "突击", "远程", "魔法"}

function WeaponsGradeNode:ctor(param)
    WeaponsGradeNode.super.ctor(self)
    self._animValue = {}
    self._callback = param.callback
    -- self._aminBg = param.inView
end

function WeaponsGradeNode:onInit()
    self._userModel = self._modelMgr:getModel("UserModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._weaponsModel = self._modelMgr:getModel("WeaponsModel")
    -- self._bottom = self:getUI("bg.bottom")
    -- local mc1 = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    -- mc1:setPosition(cc.p(self._bottom:getContentSize().width*0.5, self._bottom:getContentSize().height*0.5))
    -- self._bottom:addChild(mc1)


    self._infoNode = self:getUI("bg.infoNode")

    local title = self._infoNode:getChildByFullName("titleBg1.title")
    UIUtils:setTitleFormat(title, 3, 1)
    self._title = title

    -- local closeAttr = self._attr:getChildByFullName("closeAttr")
    -- self:registerClickEvent(closeAttr, function()
    --     -- self:close()
    --     self._attr:setVisible(false)
    -- end)

    local decBtn = self:getUI("bg.infoNode.decBtn")
    self:registerClickEvent(decBtn, function()
        if self._callback then
            self._callback()
        end
    end)

    local updateTeamBtn = self:getUI("bg.infoNode.updateTeamBtn")
    local upFiveTeamBtn = self:getUI("bg.infoNode.upFiveTeamBtn")

    self:registerClickEvent(updateTeamBtn, function()
        if self._callUpGradeOne then
            self._callUpGradeOne(1)
        end
    end)
    self:registerClickEvent(upFiveTeamBtn, function()
        if self._callUpGradeOne then
            self._callUpGradeOne(5)
        end
    end)

end

function WeaponsGradeNode:reflashUI(data)
    -- self._aminBg = inView
    self._selectType = data.selectType
    self._selectWeaponId = data.selectWeaponId
    local weaponTypeData = self._weaponsModel:getWeaponsDataByType(self._selectType)
    -- dump(weaponTypeData)
    local userData = self._userModel:getData()
    local level = weaponTypeData.lv
    local maxLvl = userData.lvl - tab:Setting("SIEGE_WEAPON_LV").value
    local baseInfoLevelLab = self._infoNode:getChildByFullName("levelLab")
    baseInfoLevelLab:setString("Lv." .. level .. "/" .. maxLvl)

    local weaponMaxExp = tab:SiegeWeaponExp(level)
    local maxExp = 0
    -- if level >= maxLvl then
    --     weaponMaxExp = nil
    -- end
    --经验条
    local exp = self._infoNode:getChildByFullName("expBg.exp")
    local expBar = self._infoNode:getChildByFullName("expBg.expBar")
    exp:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    if weaponMaxExp then
        maxExp = weaponMaxExp.cost1
        exp:setString(weaponTypeData.exp .. "/" .. maxExp)

        str = (weaponTypeData.exp / maxExp)
        if str > 1 then
            str = 1
        end
        if str < 0 then
            str = 0
        end
        expBar:setScaleX(str)

        --升级
        local siegeWeaponExp = userData.siegeWeaponExp or 0

        if level >= maxLvl then
            self._callUpGradeOne = function()
                self._viewMgr:showTip(lang("SIEGECON_TIPS1"))
            end
        elseif siegeWeaponExp > 0 then
            self._callUpGradeOne = function(level)
                if level == 1 then
                    self:upgradeWeapon()
                else
                    self:upgradeFiveWeapon()
                end
            end
        else
            self._callUpGradeOne = function()
                local param = {indexId = 16}
                self._viewMgr:showDialog("global.GlobalPromptDialog", param)
                -- DialogUtils.showLackRes({goalType = "siegeWeaponExp"})
                -- DialogUtils.showLackRes({goalType = "texp"})
            end
        end
    else
        exp:setString("Max")
        expBar:setScaleX(1)

        self._callUpGradeOne = function()
            self._viewMgr:showTip(lang("SIEGECON_TIPS1"))
        end
    end
    
    -- exp:setString("升级还需" .. teamMaxExp.exp-weaponTypeData.exp .. "经验")





    local weaponsTab = tab:SiegeWeapon(self._selectWeaponId) or {}

    local desc = lang(weaponsTab.des)
    desc = string.gsub(desc, "%b[]", "")
    
    local valueLab = self._infoNode:getChildByFullName("tip5.valueLab")
    valueLab:setString(desc)
    
    local attrData = self:getAttrData()
    -- dump(attrData)
    local attrValue = self._weaponsModel:getAttrValue(attrData)
    -- dump(attrValue)
    local intproperty = weaponsTab.intproperty
    for i=1,3 do
        local str1 = "tip" .. i .. ".valueLab"--"bg.scrollView.infoNode.tip" .. i .. ".valueLab" --"tip" .. i .. ".valueLab"
        local valueLabNum = self._infoNode:getChildByFullName(str1)--self:getUI(str) --self._infoNode:getChildByFullName(str)
        str1 = "tip" .. i .. ".addValue"
        local addValueNum = self._infoNode:getChildByFullName(str1)
        str1 = "tip" .. i .. ".addValue1"
        local addValue1 = self._infoNode:getChildByFullName(str1)
        str1 = "tip" .. i .. ".addValue2"
        local addValue2 = self._infoNode:getChildByFullName(str1)
        local value = 0
        local addValue = 0
        if i == 1 then
            value = attrValue[1]
            -- value = TeamUtils.getNatureNums(value)
            value = math.floor(value*10)*0.1
            addValue = intproperty[1][3]
        elseif i == 2 then
            value = attrValue[3]
            -- value = TeamUtils.getNatureNums(value)
            value = math.floor(value*10)*0.1
            addValue = intproperty[3][3]
        elseif i == 3 then
            value = attrValue[2]
            -- value = TeamUtils.getNatureNums(value)
            value = math.floor(value*10)*0.1
            addValue = intproperty[2][3]
        end
        addValue = TeamUtils.getNatureNums(addValue) --math.ceil(addValue * 10) / 10
        -- 
        if value then
            valueLabNum:setString(value)
        end

        if tonumber(addValue) ~= 0 then
            addValueNum:setString("+" .. addValue)
            addValueNum:setVisible(true)
            addValue2:setPositionX(valueLabNum:getPositionX()+valueLabNum:getContentSize().width + 8)
            addValueNum:setPositionX(addValue2:getPositionX()+addValue2:getContentSize().width + 5)
            addValue1:setPositionX(addValueNum:getPositionX()+addValueNum:getContentSize().width + 3)
        else
            addValueNum:setVisible(false)
            addValue1:setVisible(false)
            addValue2:setVisible(false)
        end
    end

    -- 技能抬头
    if self._selectType == 4 then
        self._title:setString("主城设施")
    else
        self._title:setString("器械技能")
    end

    -- 技能展示
    -- local skillBg = self:getUI("bg.rightSubBg.panel.skillBg")
    local skillBg = self._infoNode:getChildByFullName("skillBg")
    print("self._selectWeaponId======", self._selectWeaponId)
    local wSkill = weaponsTab.skill or {}
    local skillLock = self._weaponsModel:getWeaponsSkillLock()
    dump(skillLock)
    for i=1,table.nums(wSkill) do
        local _skill = wSkill[i]
        -- local skillEffect = tab:PlayerSkillEffect(_skill)
        local skillEffect = tab:SiegeSkillDes(_skill)
        -- print("_skill==========", _skill)
        local lock = false
        local lockSkill = weaponTypeData["ss" .. (i - 1)]
        print("lockSkill==========", lockSkill)
        if lockSkill and lockSkill == 0 then
            lock = true
        end
        local param = {sysSkill = skillEffect, lock = lock}
        local skillIcon = skillBg:getChildByFullName("skillIcon" .. i)
        if not skillIcon then
            skillIcon = IconUtils:createWeaponsSkillIcon(param)
            skillIcon:setName("skillIcon" .. i)
            skillIcon:setScale(0.8)
            skillIcon:setPosition(90*i-90, -8)
            skillBg:addChild(skillIcon)
        else
            IconUtils:updateWeaponsSkillIcon(skillIcon, param)
        end
        if skillLock and skillLock[i-1] and skillLock[i-1] ~= 0 then
            local mc1 = mcMgr:createViewMC("tianfujiesuo_mofahanghui", false, true)
            mc1:setPosition(skillIcon:getContentSize().width*0.5, skillIcon:getContentSize().height*0.5)
            skillIcon:addChild(mc1)
        end
        self:registerClickEvent(skillIcon, function()
            if lock == false then
                self:showHintView("global.GlobalTipView",{tipType = 24, node = skillIcon,attrValue=attrValue, id = _skill, posCenter = true})
            else
                self._viewMgr:showDialog("weapons.WeaponsSkillTipDialog", {skillEffect = skillEffect, attrValue=attrValue, weaponId = self._selectWeaponId, posIdx = i, weaponTypeData = weaponTypeData})
                -- self:showHintView("global.GlobalTipView",{tipType = 2, node = skillIcon, id = _skill, posCenter = true})
            end
        end)
    end
    
    self._weaponsModel:setWeaponsSkillLock({0, 0})
end

function WeaponsGradeNode:getAttrData()
    local attr = {}
    for i=1,6 do
        attr[i] = 0
    end
    local wattrData = self._weaponsModel:getWeaponsAttr(self._selectWeaponId, self._selectType)
    for key=1,6 do
        attr[key] = attr[key] + wattrData[key]
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
    return attr
end

function WeaponsGradeNode:upgradeWeapon()
    local param = {type = self._selectType}
    self._oldWeaponTypeData = clone(self._weaponsModel:getWeaponsDataByType(self._selectType))
    self._serverMgr:sendMsg("WeaponServer", "upgradeWeapon", param, true, {}, function (result)
        dump(result, "result=======", 10)
        -- self:updateCurrencyUI()
        -- self:updateRightSubBg()
        -- self:updateLeftPanel(weaponId, weaponsId)
        self:upgradeWeaponFinish(result)
    end)
    -- self:resolveProp()
end

function WeaponsGradeNode:upgradeFiveWeapon()
    local param = {type = self._selectType, quick = 1}
    self._oldWeaponTypeData = clone(self._weaponsModel:getWeaponsDataByType(self._selectType))
    self._serverMgr:sendMsg("WeaponServer", "upgradeWeapon", param, true, {}, function (result)
        dump(result, "result=======", 10)
        -- self:updateCurrencyUI()
        -- self:updateRightSubBg()
        -- self:updateLeftPanel(weaponId, weaponsId)
        self:upgradeWeaponFinish(result)
    end)
    -- self:resolveProp()
end


function WeaponsGradeNode:upgradeWeaponFinish(inResult)
    if inResult["d"] == nil then 
        return 
    end
    -- local fightBg = self:getUI("bg")
    -- TeamUtils:setFightAnim(fightBg, {oldFight = self._oldFight, newFight = TeamUtils:updateFightNum(), x = -200, y = fightBg:getContentSize().height - 110})

    audioMgr:playSound("crLvUp")

    local weaponTypeData = self._weaponsModel:getWeaponsDataByType(self._selectType)
    local oldWeaponTypeData = self._oldWeaponTypeData
    local expNum = 0 
    local tempParent = 0
    local percent = 0
    local oldlevel = oldWeaponTypeData.lv
    local newlevel = weaponTypeData.lv
    for i=oldlevel, newlevel do
        if i == oldlevel and oldWeaponTypeData.exp ~= 0 then
            expNum = expNum + tab:SiegeWeaponExp(i).cost1 - oldWeaponTypeData.exp
            tempParent = tempParent + 100 -- (oldWeaponTypeData.exp / tab:SiegeWeaponExp(i).exp) * 100
        elseif i == newlevel and weaponTypeData.exp ~= 0 and i ~= 1 then
            expNum = expNum + weaponTypeData.exp 
            percent = (weaponTypeData.exp / tab:SiegeWeaponExp(newlevel).cost1) * 100
            tempParent = tempParent + percent
        elseif i == newlevel and weaponTypeData.exp == 0 then
            expNum = expNum
            tempParent = tempParent
        else
            expNum = expNum + tab:SiegeWeaponExp(i).cost1
            tempParent = tempParent + 100
        end
    end
    if oldlevel == newlevel then
        expNum = weaponTypeData.exp - oldWeaponTypeData.exp
    end
    if expNum <= 0 then
        expNum = weaponTypeData.exp - oldWeaponTypeData.exp 
    end

    local expBar = self._infoNode:getChildByFullName("expBg.expBar")


    local tempExp = (oldWeaponTypeData.exp / tab:SiegeWeaponExp(oldlevel).cost1) * 100

    local addExp = 5
    if tempParent > 100 then
        addExp = 10
    end
    expBar:stopAllActions()
    expBar:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
        if tempExp < tempParent then
            local str = math.fmod(tempExp, 100)
            if str + 10 >= 100 then
                str = 100
            end
            local percent = str*0.01
            if percent > 1 then
                percent = 1
            end
            if percent < 0 then
                percent = 0
            end
            expBar:setScaleX(percent)
            -- expBar:setPercent(str)
        else
            local weaponMaxExp = tab:SiegeWeaponExp(newlevel)
            if weaponMaxExp then
                percent = (weaponTypeData.exp / tab:SiegeWeaponExp(newlevel).cost1)
            else
                percent = 1
            end
            if percent > 1 then
                percent = 1
            end
            if percent < 0 then
                percent = 0
            end
            expBar:setScaleX(percent)

            expBar:stopAllActions()
        end
        tempExp = tempExp + addExp
    end), cc.DelayTime:create(0.001))))
    
    self:teamSheng()

    -- self:teamPiaoNature(expNum)
    -- self:setAnim()
    -- self._fightCallback({newFight = tempTeam.score, oldFight = oldWeaponTypeData.score})
    -- self._viewMgr:showTip("升级成功")
    
    -- local teamModel = self._modelMgr:getModel("TeamModel")
    -- self:reflashUI({teamData = teamModel:getTeamAndIndexById(weaponTypeData.teamId)})
end

function WeaponsGradeNode:teamSheng()
    local str = "升级成功"
    local expBar = self._infoNode:getChildByFullName("expBg")

    local expBarLab = cc.Sprite:create() 
    expBarLab:setSpriteFrame("weaponImageUI_img23.png")
    expBarLab:setPosition(cc.p(expBar:getContentSize().width - 30, 5))
    expBarLab:setOpacity(0)
    expBar:addChild(expBarLab,10)
    local movenature = cc.MoveBy:create(0.3, cc.p(0,25))
    local fadenature = cc.FadeIn:create(0.3)
    local spawnnature = cc.Spawn:create(movenature,fadenature)
    local seq = cc.Sequence:create(cc.DelayTime:create(0.25),spawnnature,cc.Spawn:create(cc.MoveBy:create(0.5, cc.p(0,5)),cc.FadeOut:create(0.5)))
    local callFunc = cc.CallFunc:create(function()
        expBarLab:removeFromParent()
    end)
    expBarLab:runAction(cc.Sequence:create(seq,callFunc))
end


return WeaponsGradeNode

