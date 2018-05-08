--[[
    Filename:    PrivilegesAbilityDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-03-11 16:39:05
    Description: File description
--]]


local PrivilegesAbilityDialog = class("PrivilegesAbilityDialog", BasePopView)

function PrivilegesAbilityDialog:ctor(param)
    PrivilegesAbilityDialog.super.ctor(self)
    self._abilityId = param.abilityId or 103
    self._peerageId = param.peerageId or {1,1}
    self._callback = param.callback
    -- self._detailCell = {}
end

function PrivilegesAbilityDialog:onInit()

    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)

    self._burst = self:getUI("bg.burst")
    self._anim = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
    self._anim:setPosition(self._burst:getContentSize().width*self._burst:getScaleX()/2-2, self._burst:getContentSize().height*self._burst:getScaleY()/2)
    self._anim:setVisible(false)
    self._burst:addChild(self._anim)

    self._abilityName = self:getUI("bg.abilityBg.abilityName")
    self._abilityName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._abilityName:setFontSize(24)

    local oldAbilityLevel = self:getUI("bg.abilityBg.oldAbilityLevel")
    oldAbilityLevel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local newAbilityLevel = self:getUI("bg.abilityBg.newAbilityLevel")
    newAbilityLevel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)    

    local starNum3 = self:getUI("bg.starNum3")
    local starNum2 = self:getUI("bg.starNum2")
    local starNum1 = self:getUI("bg.starNum1")

    local oldLab = self:getUI("bg.effectBg.oldLab")
    oldLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    local newLab = self:getUI("bg.effectBg.nextLab")
    newLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)

    local peerage = self:getUI("bg.closeBtn")
    self:registerClickEvent(peerage, function()
        if self._callback then
            self._callback()
        end
        self:close()
    end)

    self:listenReflash("PrivilegesModel", self.reflashUI)
    self:listenReflash("UserModel", self.reflashUI)
    self:listenReflash("ItemModel", self.reflashUI)
    self:seConstantUI()
    self:reflashUI()
end

function PrivilegesAbilityDialog:reflashUI(data)
    local privilegeData = self._modelMgr:getModel("PrivilegesModel"):getData()
    local itemModel = self._modelMgr:getModel("ItemModel")

    local abilityTab = tab:Ability(tab:Peerage(self._peerageId[1])["condition"][self._peerageId[2]])

    self._abilityLvl = (privilegeData.abilityList[tostring(self._abilityId)] or 0) -- - tab:Peerage(self._peerageId[1])["lvCondition"][self._peerageId[2]]
    local abilityLevelMax = tab:Peerage(self._peerageId[1])["lvLimit"][self._peerageId[2]] - tab:Peerage(self._peerageId[1])["lvCondition"][self._peerageId[2]] -- tab:Peerage(index)["lvLimit"][i] - tab:Peerage(index)["lvCondition"][i]
    -- print("=======================",self._abilityLvl, tab:Peerage(self._peerageId[1])["lvLimit"][self._peerageId[2]] , tab:Peerage(self._peerageId[1])["lvCondition"][self._peerageId[2]] )
    local tempLvl = self._abilityLvl
    if tab:Peerage(self._peerageId[1])["lvCondition"][self._peerageId[2]] ~= 0 then
         -- print("====",tempLvl ,(tab:Peerage(self._peerageId[1])["lvCondition"][self._peerageId[2]] or 0))
        tempLvl = tempLvl - (tab:Peerage(self._peerageId[1])["lvCondition"][self._peerageId[2]] or 0)
    end

    if tempLvl >= abilityLevelMax then
        tempLvl = abilityLevelMax
    elseif tempLvl < 0 then 
        tempLvl = 0
    end
    local tempLevel
    if (privilegeData.abilityList[tostring(self._abilityId)] or 0) >= tab:Peerage(self._peerageId[1])["lvLimit"][self._peerageId[2]] then
        tempLevel = tab:Peerage(self._peerageId[1])["lvLimit"][self._peerageId[2]]
        self._abilityLvl = tab:Peerage(self._peerageId[1])["lvLimit"][self._peerageId[2]]
        self._abilityNextLvl = tab:Peerage(self._peerageId[1])["lvLimit"][self._peerageId[2]] or 1 -- self._abilityLvl -- self._abilityLvl
    else -- if self._abilityLvl == 0 then
        self._abilityNextLvl = self._abilityLvl + 1
        tempLevel = self._abilityLvl - abilityLevelMax
    end

    local oldAbilityLevel = self:getUI("bg.abilityBg.oldAbilityLevel")
    local newAbilityLevel = self:getUI("bg.abilityBg.newAbilityLevel")
    local jiantou = self:getUI("bg.abilityBg.jiantou")

    if self._abilityLvl > 0 then
        oldAbilityLevel:setString("Lv." .. tempLvl)
        newAbilityLevel:setString("Lv." .. tempLvl + 1)

    else
        oldAbilityLevel:setString("Lv.0")
        newAbilityLevel:setString("Lv.1")
    end
    jiantou:setPositionX(oldAbilityLevel:getPositionX() + oldAbilityLevel:getContentSize().width + 17)
    newAbilityLevel:setPositionX(jiantou:getPositionX() + jiantou:getContentSize().width + 13)
    -- oldAbilityLevel:setString(abilityTab.abilityList[self._abilityId])

    -- Max Level
    local starNum1 = self:getUI("bg.starNum1")
    local starNum2 = self:getUI("bg.starNum2")
    local starNum3 = self:getUI("bg.starNum3")
    local need = self:getUI("bg.need")
    local starIcon = self:getUI("bg.starIcon")
    starIcon:setScale(0.3)
    starIcon:loadTexture("" .. tab:Tool(tab:Setting("G_PRIVILEGES_LVUP_ITEMID").value).art .. ".png", 1)
    local nextLab = self:getUI("bg.effectBg.nextLab")
    local nextEffect = self:getUI("bg.effectBg.nextEffect")
    local maxLevel = self:getUI("bg.maxLevel")
    local tempItems, tempItemCount = itemModel:getItemsById(tab:Setting("G_PRIVILEGES_LVUP_ITEMID").value)
    if self._abilityLvl >= tab:Peerage(self._peerageId[1])["lvLimit"][self._peerageId[2]] then
        newAbilityLevel:setVisible(false)
        jiantou:setVisible(false)
        nextLab:setVisible(false)
        nextEffect:setVisible(false)
        need:setVisible(false)
        starNum1:setVisible(false)
        starNum2:setVisible(false)
        starNum3:setVisible(false)
        starIcon:setVisible(false)
        self._burst:setVisible(false)
        maxLevel:setVisible(true)
    else
        if tempItemCount >= tab:AbilityEffect(self._abilityId)["cost"][self._abilityNextLvl] then
            starNum2:setColor(UIUtils.colorTable.ccUIBaseColor9)
        else
            starNum2:setColor(UIUtils.colorTable.ccUIBaseColor6)
        end
        -- starNum1:setString(tempItemCount)
        starNum2:setString(tempItemCount .. "/" .. tab:AbilityEffect(self._abilityId)["cost"][self._abilityNextLvl])
        -- starNum3:setString(tab:AbilityEffect(self._abilityId)["cost"][self._abilityNextLvl]) -- tab:Peerage(index)["lvCondition"][i] -- abilityTab.cost[self._abilityNextLvl])
        starNum2:setPositionX(starIcon:getPositionX() + starIcon:getContentSize().width*starIcon:getScale() + 5)
        -- starNum1:setPositionX(starIcon:getPositionX() + starIcon:getContentSize().width*starIcon:getScale() + 5)
        -- starNum2:setPositionX(starNum1:getPositionX() + starNum1:getContentSize().width*starNum1:getScale() + 5)
        -- starNum3:setPositionX(starNum2:getPositionX() + starNum2:getContentSize().width*starNum2:getScale() + 5)
        
    end



    if privilegeData.peerage < self._peerageId[1] then
        self:registerClickEvent(self._burst, function()
            -- self._viewMgr:showTip("您的爵位不足，不能解锁")
            self._viewMgr:showTip(lang("TIPS_UI_DES_5"))
        end)
    else
        if tempItemCount < tab:AbilityEffect(self._abilityId)["cost"][self._abilityNextLvl] then
            starNum3:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            -- starNum2:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            starNum1:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            self._anim:setVisible(false)
            self:registerClickEvent(self._burst, function()
                print("=========星星不够")
                self._viewMgr:showTip(lang("TIPS_UI_DES_6"))
                -- self._viewMgr:showTip("您的能力点不足，不能解锁")
            end)
        else -- if conditions then
            -- starNum3:setColor(cc.c3b(115,240,0))
            self._anim:setVisible(true)
            self:registerClickEvent(self._burst, function()
                audioMgr:playSound("privilegeUnlock")   --特权解锁
                self:upAbility()
            end)
        end
    end

    -- 效果
    local oldEffectBg = self:getUI("bg.effectBg.oldEffect")
    local nextEffectBg = self:getUI("bg.effectBg.nextEffect")
    local oldEffect = oldEffectBg:getChildByName("oldEffect")
    if oldEffect then
        oldEffect:removeFromParent()
    end
    local nextEffect = nextEffectBg:getChildByName("nextEffect")
    if nextEffect then
        nextEffect:removeFromParent()
    end

    if tempLvl == 0 then 
        desc = "[color=462800]暂无[-]"
        -- desc = "[color=ffd618,outlinecolor=002d0000]暂无[-]"
        oldEffect = RichTextFactory:create(desc, oldEffectBg:getContentSize().width, oldEffectBg:getContentSize().height)
        oldEffect:formatText()
        oldEffect:setName("oldEffect")
        oldEffect:enablePrinter(true)
        oldEffect:setPosition(oldEffectBg:getContentSize().width/2, oldEffectBg:getContentSize().height - oldEffect:getInnerSize().height/2)
        oldEffectBg:addChild(oldEffect)

        desc = self:split(lang(abilityTab.effectDes), tempLvl + 1) -- (self._abilityNextLvl - abilityLevelMax))
        nextEffect = RichTextFactory:create(desc, nextEffectBg:getContentSize().width, nextEffectBg:getContentSize().height)
        nextEffect:formatText()
        nextEffect:setName("nextEffect")
        nextEffect:enablePrinter(true)
        nextEffect:setPosition(nextEffectBg:getContentSize().width/2, nextEffectBg:getContentSize().height - oldEffect:getInnerSize().height/2)
        nextEffectBg:addChild(nextEffect)
    else
        desc = self:split(lang(abilityTab.effectDes),tempLvl)
        oldEffect = RichTextFactory:create(desc, oldEffectBg:getContentSize().width, oldEffectBg:getContentSize().height)
        oldEffect:formatText()
        oldEffect:setName("oldEffect")
        oldEffect:enablePrinter(true)
        oldEffect:setPosition(oldEffectBg:getContentSize().width/2, oldEffectBg:getContentSize().height - oldEffect:getInnerSize().height/2)
        oldEffectBg:addChild(oldEffect)
        
        desc = self:split(lang(abilityTab.effectDes), tempLvl + 1) -- (self._abilityNextLvl - abilityLevelMax))
        nextEffect = RichTextFactory:create(desc, nextEffectBg:getContentSize().width, nextEffectBg:getContentSize().height)
        nextEffect:formatText()
        nextEffect:setName("nextEffect")
        nextEffect:enablePrinter(true)
        nextEffect:setPosition(nextEffectBg:getContentSize().width/2, nextEffectBg:getContentSize().height - oldEffect:getInnerSize().height/2)
        nextEffectBg:addChild(nextEffect)
    end
end

function PrivilegesAbilityDialog:seConstantUI()

    local abilityTab = tab:Ability(tab:Peerage(self._peerageId[1])["condition"][self._peerageId[2]]) -- tab:Ability(self._abilityId)
    -- 图标
    local abilityIconBg = self:getUI("bg.abilityBg.abilityIconBg")
    
    local abilityIcon = abilityIconBg:getChildByName("abilityIcon")
    if not abilityIcon then
        abilityIcon = IconUtils:createPeerageIconById({image = abilityTab["res"] .. ".png", quality = abilityTab.iconColor}) -- IconUtils:createTeamPlayIconById({image = abilityTab["res"] .. ".jpg"})
        abilityIcon:setName("abilityIcon")
        abilityIcon:setScale(0.9)
        abilityIcon:setPosition(cc.p(-7,-7))
        abilityIconBg:addChild(abilityIcon)
    end

    -- 名称
    local abilityName = self:getUI("bg.abilityBg.abilityName")
    abilityName:setString(lang(abilityTab.name))

    -- 能力描述
    local abilityLabBg = self:getUI("bg.abilityBg.abilityLabBg")
    local desc = lang(abilityTab.des) -- "[color=cc8945]副本中获得的玩家经验提高555%副本中获得的玩家经验提高555%副本中获得中获得的玩家经验提高555%[-]" -- SkillUtils:handleSkillDesc1(lang(sysSkill.des1), self._teamData, 1)
    local abilityLab = RichTextFactory:create(desc, abilityLabBg:getContentSize().width, abilityLabBg:getContentSize().height)
    abilityLab:formatText()
    abilityLab:setName("abilityLab")
    abilityLab:enablePrinter(true)
    abilityLab:setPosition(abilityLabBg:getContentSize().width/2, abilityLabBg:getContentSize().height - abilityLab:getInnerSize().height/2)
    abilityLabBg:addChild(abilityLab)
end

function PrivilegesAbilityDialog:split(str,reps)
    local des = string.gsub(str,"%b{}",function( lvStr )
        local str = string.gsub(lvStr,"%$level",reps)
        return loadstring("return " .. string.gsub(str, "[{}]", ""))()
    end)
    return des 
end

function PrivilegesAbilityDialog:upAbility()
    local param = {abilityId = self._abilityId}
    -- self:upAbilityFinish(result)
    self._serverMgr:sendMsg("PrivilegesServer", "upAbility", param, true, {}, function (result)
        self:upAbilityFinish(result)
    end)
end

function PrivilegesAbilityDialog:upAbilityFinish()
    local abilityIconBg = self:getUI("bg.abilityBg.abilityIconBg")
    local skillIcon = abilityIconBg:getChildByName("abilityIcon")
    -- local mc2 = mcMgr:createViewMC("qianghua_teamskillanim", true, false, function (_, sender)
    --     sender:gotoAndPlay(0)
    --     sender:removeFromParent()
    -- end)
    local mc2 = mcMgr:createViewMC("jinengjiesuo_qianghua", false, true)
    -- local mc2 = mcMgr:createViewMC("qianghua_teamskillanim", true, false)
    mc2:setScale(1.2)
    mc2:setPosition(skillIcon:getContentSize().width*0.5, skillIcon:getContentSize().height*0.5)
    skillIcon:addChild(mc2, 111)

    print("++++++++解锁完成")
end

return PrivilegesAbilityDialog