--[[
    Filename:    TeamSkillNode.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-05-21 18:20:37
    Description: File description
--]]

local TeamSkillNode = class("TeamSkillNode", BaseLayer)

function TeamSkillNode:ctor(param)
    TeamSkillNode.super.ctor(self)
    self._skillNode = {}
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._fightCallback = param.fightCallback
end

function TeamSkillNode:onInit()
    self._listNode2 = self:getUI("listNode2")
    self._listNode2:setVisible(false)
    self._listNode3 = self:getUI("listNode3")
    self._listNode3:setVisible(false)
    self._scrollView = self:getUI("bg.scrollView")

    local title = self:getUI("bg.scrollView.titleBg1")
    UIUtils:adjustTitle(title, 3, 1)
    local title = self:getUI("bg.scrollView.titleBg2")
    UIUtils:adjustTitle(title, 3, 1)
    local title = self:getUI("bg.scrollView.titleBg3.titleLab")
    title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- UIUtils:adjustTitle(title, 3, 1)
    self._skillTop = true
end

function TeamSkillNode:reflashUI(data)
    -- dump(data, "data", 10)
    if self._teamData == nil 
        or self._teamData.teamId ~= data.teamData.teamId then 
        self._curSelectIndex = 0
    end
    self._teamData = data.teamData

    self._skillShowSort = self._teamModel:getTeamSkillShowSort(self._teamData)

    local sysTeam = tab:Team(self._teamData.teamId)

    if #self._skillShowSort ~= #self._skillNode then
        for k, v in pairs(self._skillNode) do
            if v then
                v:removeFromParentAndCleanup()
                v = nil
            end
        end
        self._skillNode = {}
        self:createNode()
    end

    local isGray = false
    local icon
    local isSuoDown = false
    local skillCount = #self._skillShowSort
    for k = 1, skillCount do
        repeat
            local skillTemp = self._skillShowSort[k]     --skill index转换
            v = sysTeam.skill[skillTemp]
            if not v then
                break
            end

            --data
            local sysTeamStarData = tab:Star(self._teamData.star)
            local tempLevel = self._teamData["sl" .. skillTemp]
            local maxLevel = sysTeamStarData.skilllevel

            --表数据
            local skillType = v[1]
            local skillId = v[2]
            if skillType == nil or skillId == nil then
                self._viewMgr:showTip("技能数据错误，请联系管理员")
                skillType = 1
                skillId = 59055
            end
            local sysSkill = SkillUtils:getTeamSkillByType(skillId, skillType)
            --技能类型flag
            self._skillNode[k].nameLab:setString(lang(sysSkill.name))
            self._skillNode[k].classSkill:setColor(cc.c3b(240,200,145))
            self._skillNode[k].classSkill:setString(lang("TEAMSKILL_LABEL" .. (sysSkill.label or 3)))
            self._skillNode[k].classSkillBg:setVisible(true)

            if not (k == skillCount and self._teamData["ss"]) then
                self._skillNode[k].classSkillBg:setVisible(false)
            end

            --圣徽加成 技能等级
            local rune = self._teamData.rune
            local uSkill = false    -- 是否大招技能加成
            local sSkill = false    -- 是否普通技能加成
            local addLevel = 0      -- 额外增加等级
            if rune and rune.suit and rune.suit["4"] then
                local id,level = TeamUtils:getRuneIdAndLv(rune.suit["4"])
                if id == 104 then
                    sSkill = true
                    addLevel = level
                end
                if k == 1 then
                    if id == 403 then
                        uSkill = true 
                        addLevel = level
                    end
                end
            end

            --当前等级
            self._skillNode[k].levelLab:setString("Lv." .. (tempLevel+addLevel) .. "/" .. (maxLevel+addLevel))
            self._skillNode[k].levelLab:setFontSize(24)
            self._skillNode[k].levelLab:setVisible(true)
            if uSkill and k == 1 then
                self._skillNode[k].levelLab:setColor(cc.c3b(28,162,22))
            elseif sSkill then
                self._skillNode[k].levelLab:setColor(cc.c3b(28,162,22))
            else
                self._skillNode[k].levelLab:setColor(cc.c3b(62,40,30))
            end
            
            --data
            local sysTeamStarData = tab:Star(self._teamData.star)
            local level = self._teamData["sl" .. skillTemp]

            -- 特技
            --level:-1红色未开启 0未解锁 1已解锁但未选择 "ss"~=nil解锁且已选择（红色开启时，sl字段还是-1，手动置成0）
            if k == skillCount and level < 1 then  
                local quality = self._teamModel:getTeamQualityByStage(self._teamData["stage"])
                if quality[1] == 6 then
                    level = 0
                end
            end

            -- 16资质第4个常规技能需要6星解锁
            if skillTemp == 7 and level < 0 then
                if self._teamData.star and self._teamData.star >= 6 then
                    level = 0
                end
            end

            --大招/特技 flag
            if sysSkill.dazhao or (k == skillCount and self._teamData["ss"]) then
                self._skillNode[k].dazhao:setVisible(true)
            else
                self._skillNode[k].dazhao:setVisible(false)
            end

            local lingyuImg = self._skillNode[k]:getChildByFullName("lingyuImg")
            if lingyuImg then
                lingyuImg:setVisible(false)
            end
            if sysSkill.lingyu and sysSkill.lingyu == 1 then
                if not lingyuImg then
                    lingyuImg = ccui.ImageView:create()
                    lingyuImg:loadTexture("label_big_skill_lingyu.png", 1)
                    lingyuImg:setPosition(lingyuImg:getContentSize().width / 2 +10, self._skillNode[k]:getContentSize().height - 20)
                    lingyuImg:setRotation(-25)
                    self._skillNode[k]:addChild(lingyuImg, 1)
                    lingyuImg:setScale(0.85)
                end
                lingyuImg:setVisible(true)
            end

            local userData = self._modelMgr:getModel("UserModel"):getData()

            local systemName = "TeamSkill"
            local isOpen, toBeOpen
            if systemName then
                isOpen, toBeOpen, isLevel = SystemUtils["enable" .. systemName]()
            end 

            if isOpen == false then
                self._skillNode[k].openLabel:setString((isLevel or 23) .. "级后可突破此技能")
                self._skillNode[k].openLabel:setVisible(true)
                self._skillNode[k].openLabel:setFontSize(20)
                self._skillNode[k].openLabel:setColor(UIUtils.colorTable.ccUIUnLockColor)
                self._skillNode[k].openLabel:setPositionX(self._skillNode[k].levelLab:getPositionX())
                self._skillNode[k].levelLab:setVisible(false)
                self._skillNode[k].levelUpdateBtn:setVisible(false)
            else
                self._skillNode[k].levelUpdateBtn:setVisible(true)
                self._skillNode[k].openLabel:setVisible(false)
            end

            -- 技能升级解锁/升级动画
            if self._skillNode[k].mc1 then
                self._skillNode[k].mc1:setVisible(false)
            end
            if self._skillNode[k].mc2 then
                self._skillNode[k].mc2:setVisible(false)
            end

            --已解锁 / 未开启 / 未解锁
            if level > 0 and level <= sysTeamStarData.skilllevel then --已解锁
                self._skillNode[k].permit:setVisible(true)
                self._skillNode[k].warn2:setVisible(false)
                self._skillNode[k].warning:setVisible(false)
                self._skillNode[k].dazhao:setBrightness(0)
                self._skillNode[k].nameLab:setColor(cc.c3b(70,40,0))
                if lingyuImg then
                    lingyuImg:setBrightness(0)
                end
                self:registerClickEvent(self._skillNode[k].levelUpdateBtn, function ()
                    if tempLevel == maxLevel then
                        self._viewMgr:showTip("技能已达当前最高等级")
                    else
                        self._viewMgr:showDialog("team.TeamSkillUpdateView", {teamData = self._teamData, index = k}, true) 
                    end
                end)

                if k == skillCount and not self._teamData["ss"] then
                    self:setAnim(k, 1, level)
                end
            else
                self._skillNode[k].permit:setVisible(false)
                self._skillNode[k].warn2:setVisible(false)
                self._skillNode[k].dazhao:setBrightness(-40)
                self._skillNode[k].nameLab:setColor(UIUtils.colorTable.ccUIUnLockColor)
                if lingyuImg then
                    lingyuImg:setBrightness(-40)
                end
                isGray = true
                if level == -1 then -- 未开启
                    self._skillNode[k].warn1:setVisible(true)
                    self._skillNode[k].warn2:setVisible(false)
                    self._skillNode[k].warning:setVisible(true)
                    
                    local showStr = "进阶到%s解锁"
                    if skillTemp == 2 then
                        showStr = string.format(showStr, "蓝色")
                    elseif skillTemp == 3 then
                        showStr = string.format(showStr, "紫色")
                    elseif skillTemp == 4 then
                        showStr = string.format(showStr, "橙色")
                    elseif skillTemp == 5 then
                        showStr = string.format(showStr, "红色")
                    elseif skillTemp == 6 then
                        showStr = string.format(showStr, "红色")
                    elseif skillTemp == 7 then
                        showStr = "升星到六星解锁"
                    end
                    self._skillNode[k].Label_69_0:setString(showStr)
                    -- self._skillNode[k].nextLab:setPositionX(self._skillNode[k].Label_69_0:getPositionX() + self._skillNode[k].Label_69_0:getContentSize().width)
                    -- self._skillNode[k].Label_69:setPositionX(self._skillNode[k].nextLab:getPositionX() + self._skillNode[k].nextLab:getContentSize().width)
                elseif level == 0 then -- 未解锁
                    if (tonumber(k) == 3 or tonumber(k) == 4) then
                        isSuoDown = true
                    end
                    self._skillNode[k].warn1:setVisible(false)
                    self._skillNode[k].warning:setVisible(false)
                    self._skillNode[k].warn2:setVisible(true)
                    self:setAnim(k, 1, level)
                    local userData = self._modelMgr:getModel("UserModel"):getData()

                    local goldValue = tab:Setting("G_TEAMSKILL_UNLOCK").value[skillTemp] or 0
                    self._skillNode[k].goldValue:setString(goldValue)
                    
                    if userData.gold >= goldValue then
                        self:registerClickEvent(self._skillNode[k].suo, function()
                            local positionId = skillTemp
                            if positionId == 5 or positionId == 6 then
                                positionId = 5
                            end
                            self:openSkill(positionId, level, k)
                            -- if not self._teamData["ss"] and k == #self._skillShowSort then
                            --     self:setAnim(k, 1, level)
                            -- else
                            --     print("")
                            --     self:setAnim(k, 2, level)
                            -- end
                        end)
                    else
                        self:registerClickEvent(self._skillNode[k].suo, function()
                            DialogUtils.showLackRes( {goalType = "gold"})
                        end)
                    end
                end
            end

            --兵团icon点击详情
            local param = {}
            if k == skillCount then
                if self._teamData["ss"] then
                    param = {teamSkill = sysSkill ,isGray = isGray ,eventStyle = 3, teamData = self._teamData, level = tempLevel,addLevel = addLevel, clickCallback = function()
                        self._pos = {}
                        self._pos.x = self._scrollView:getPositionX()
                        self._pos.y = self._scrollView:getPositionY()
                        self._viewMgr:showDialog("team.TeamSpecialSkillSwitchDialog", {teamId = self._teamData["teamId"]})
                        end}
                else
                    local sysSkillTemp = SkillUtils:getTeamSkillByType(6900051, 2)
                    param = {teamSkill = sysSkillTemp ,isGray = isGray ,eventStyle = 3, teamData = self._teamData, level = tempLevel,addLevel = addLevel, clickCallback = function()
                        -- self._pos = {}
                        -- self._pos.x = self._scrollView:getPositionX()
                        -- self._pos.y = self._scrollView:getPositionY()
                        -- self._viewMgr:showDialog("team.TeamSpecialSkillSwitchDialog", {teamId = self._teamData["teamId"]})
                        end}
                end
                
            else
                param = {teamSkill = sysSkill ,isGray = isGray ,eventStyle = 1, teamData = self._teamData, level = tempLevel,addLevel = addLevel}
            end
            icon = self._skillNode[k]:getChildByName("iconCell")
            if icon ~= nil then 
                IconUtils:updateTeamSkillIconByView(icon, param)
            else
                icon = IconUtils:createTeamSkillIconById(param)
                icon:setName("iconCell")
                icon:setPosition(cc.p(5, -3))
                icon:setScale(0.9)
                self._skillNode[k]:addChild(icon)
            end
            icon:setVisible(true)
            isGray = false

            --技能演示动画
            self._skillNode[k].skillShow:setVisible(false)
            if sysTeam.showskill then
                for kk,vv in pairs(sysTeam.showskill) do
                    if vv[1] == tonumber(k) then
                        self._skillNode[k].skillShow:setVisible(true)
                        self:registerClickEvent(self._skillNode[k].skillShow, function()
                            self._viewMgr:showDialog("global.GlobalSkillPreviewDialog", {teamId = vv[2], skillId = vv[3]})
                        end)
                        break
                    end
                end
            end

            --特技特殊处理
            if k == skillCount then
                local addAnim = self._skillNode[k]:getChildByName("Image_40")
                local addBtn = self._skillNode[k]:getChildByName("Image_40_0")
                addBtn:setVisible(false)
                addAnim:setVisible(false)
                addAnim:setSaturation(0)
                if not self._teamData["ss"] then   --未选择特技
                    addBtn:setVisible(true)
                    addAnim:setVisible(true)
                    if level <= 0 then  --未解锁
                        addAnim:setSaturation(-100)
                    end

                    self._skillNode[k].levelUpdateBtn:setVisible(false)
                    self._skillNode[k].nameLab:setString("待选择")
                    self._skillNode[k].levelLab:setString(lang("SKILLDES_6900050"))
                    self._skillNode[k].levelLab:setColor(cc.c3b(62,40,30))
                    self._skillNode[k].levelLab:setFontSize(18)

                    self:registerClickEvent(addBtn, function()
                        if not self._teamData or next(self._teamData) == nil then
                            return
                        end

                        self._pos = {}
                        self._pos.x = self._scrollView:getPositionX()
                        self._pos.y = self._scrollView:getPositionY()
                        self._viewMgr:showDialog("team.TeamSpecialSkillSwitchDialog", {teamId = self._teamData["teamId"]})
                        end)
                end
            end

        until true
    end

    if not data.refTop then
        return
    end
    if self._pos then
        self._scrollView:setPosition(self._pos.x, self._pos.y)
        self._pos = nil
        self._skillTop = false
        return
    end
    if isSuoDown == true then
        self._scrollView:scrollToBottom(0.2, true)
    elseif self._skillTop == true then
        self._scrollView:jumpToTop()
    else
        self._skillTop = true
    end

end

function TeamSkillNode:openSkill(positionId, inLvl, realPosition) -- 解锁
    self._oldTeamData = clone(self._teamData)
    local param = {teamId = self._teamData.teamId, positionId = positionId}
    self._pos = {}
    self._pos.x = self._scrollView:getPositionX()
    self._pos.y = self._scrollView:getPositionY()
    self._oldFight = TeamUtils:updateFightNum()

    self._serverMgr:sendMsg("TeamServer", "openSkill", param, true, {}, function (result)
        self._skillTop = false
        local tempTeam,_ = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(self._teamData.teamId)
        self._fightCallback({newFight = tempTeam.score, oldFight = self._oldTeamData.score})
        if not self._teamData["ss"] and realPosition == #self._skillShowSort then
            self:setAnim(realPosition, 1, inLvl)
        else
            self:setAnim(realPosition, 2, inLvl)
        end
        audioMgr:playSound("ItemGain_2")

        local fightBg = self:getUI("bg")
        TeamUtils:setFightAnim(fightBg, {oldFight = self._oldFight, newFight = TeamUtils:updateFightNum(), x = -200, y = fightBg:getContentSize().height - 110})
    end)
end

function TeamSkillNode:setAnim(index, animType, inLvL)
    local skillNode = self._skillNode[index]
    if animType == 1 then    --锁动画
        if not skillNode.mc1 then
            skillNode.mc1 = mcMgr:createViewMC("jinengsuo_qianghua", true, false)
            skillNode.mc1:setPosition(cc.p(56,51))
            skillNode:addChild(skillNode.mc1, 20)
        end
        skillNode.mc1:setVisible(true)

        if not skillNode.mc2 then
            skillNode.mc2 = mcMgr:createViewMC("jinengkejiesuosaoguang_qianghua", true, false)
            skillNode.mc2:setPosition(cc.p(56,51))
            skillNode:addChild(skillNode.mc2, 19)
        end
        skillNode.mc2:setVisible(true)

        if index == #self._skillShowSort and not self._teamData["ss"] then  --特技技能未选
            local addBtn = skillNode:getChildByFullName("Image_40")
            addBtn:stopAllActions()
            if inLvL and inLvL > 0 then  --已解锁
                skillNode.mc1:setVisible(false)
                skillNode.mc2:setVisible(false)

                addBtn:runAction(cc.RepeatForever:create(
                    cc.Sequence:create(
                        cc.ScaleTo:create(0.6, 1.3),
                        cc.ScaleTo:create(0.6, 1.4)
                    )))
            end
        end

    --解锁 / 突破动画
    elseif animType == 2 then
        if skillNode.mc1 ~= nil then
            skillNode.mc1:removeFromParent()
            skillNode.mc1 = nil
        end
        if skillNode.mc2 ~= nil then
            skillNode.mc2:removeFromParent()
            skillNode.mc2 = nil
        end
        local mc2 = mcMgr:createViewMC("jinengjiesuo1_qianghua", false, true, function(_, sender) 
        end)

        mc2:setPosition(cc.p(skillNode:getPositionX()+55,skillNode:getPositionY()+49))
        mc2:addCallbackAtFrame(5, function()
            local mc3 = mcMgr:createViewMC("jinengsuo1_qianghua", false, true)
            mc3:setPosition(cc.p(55,49))
            skillNode:addChild(mc3,5)
        end)

        self._scrollView:addChild(mc2,10)
    end
end

function TeamSkillNode:createNode()
    local nodeCount = #self._skillShowSort
    local nodeHei = self._listNode2:getContentSize().height
    local titleHei = self:getUI("bg.scrollView.titleBg1"):getContentSize().height

    local maxHeight = nodeHei * nodeCount + titleHei * 3
    self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, maxHeight))

    for i = 1, nodeCount do
        if i == nodeCount and not self._isSelected then
            self._skillNode[i] = self._listNode3:clone()
        else
            self._skillNode[i] = self._listNode2:clone()
        end

        local skillNode = self._skillNode[i]
        skillNode:setVisible(true)
        skillNode:setName("skillBg" .. i)
        skillNode.levelLab = skillNode:getChildByFullName("permit.levelLab")
        skillNode.levelLab:setFontSize(24)
        skillNode.levelLab:setFontName(UIUtils.ttfName)
        skillNode.levelLab:disableEffect()

        skillNode.classSkillBg = skillNode:getChildByFullName("classSkillBg")
      
        skillNode.classSkill = skillNode:getChildByFullName("classSkillBg.classSkill")
        skillNode.classSkill:setFontSize(20)
        skillNode.classSkill:setFontName(UIUtils.ttfName)
        skillNode.classSkill:setColor(cc.c3b(255,188,102))
        skillNode.classSkill:disableEffect()
        
        skillNode.nameLab = skillNode:getChildByFullName("nameLab")
        skillNode.nameLab:disableEffect()
        skillNode.nameLab:setFontSize(26)
        skillNode.nameLab:setFontName(UIUtils.ttfName)        
        skillNode.nameLab:setPositionY( skillNode.nameLab:getPositionY())

        skillNode.Label_69_0 = skillNode:getChildByFullName("warning.warn1.Label_69_0")
        skillNode.Label_69 = skillNode:getChildByFullName("warning.warn1.Label_69")
        skillNode.Label_69_0:disableEffect()
        skillNode.Label_69:disableEffect()

        skillNode.nextLab = skillNode:getChildByFullName("warning.warn1.nextLab")
        skillNode.nextLab:disableEffect()

        skillNode.nextLab:setVisible(false)
        skillNode.Label_69:setVisible(false)

        skillNode.iconBg = skillNode:getChildByFullName("icon")
        skillNode.iconBg:setScale(0.8)

        skillNode.gold = skillNode:getChildByFullName("warn2.gold")
        local scaleNum1 = math.floor((32/skillNode.gold:getContentSize().width)*100)
        skillNode.gold:setScale(scaleNum1/100)        
        skillNode.goldValue = skillNode:getChildByFullName("warn2.goldValue")
        skillNode.suo = skillNode:getChildByFullName("warn2.suo")
        UIUtils:setButtonFormat(skillNode.suo, 7)

        skillNode.suoBtnAnim = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
        skillNode.suoBtnAnim:setScale(0.7)
        skillNode.suoBtnAnim:setPosition(cc.p(skillNode.suo:getContentSize().width*0.5,skillNode.suo:getContentSize().height*0.5))
        skillNode.suo:addChild(skillNode.suoBtnAnim, 20)

        skillNode.openLabel = skillNode:getChildByFullName("permit.openLabel")
        skillNode.openLabel:setString("(23级开启技能升级)")
        skillNode.permit = skillNode:getChildByFullName("permit")
        skillNode.warning = skillNode:getChildByFullName("warning")
        skillNode.warn1 = skillNode:getChildByFullName("warning.warn1")
        skillNode.warn2 = skillNode:getChildByFullName("warn2")
        skillNode.dazhao = skillNode:getChildByFullName("dazhao")
        skillNode.dazhao:setVisible(false)
        skillNode.skillShow = skillNode:getChildByFullName("skillShow")
        skillNode.skillShow:setVisible(false)
        skillNode.levelUpdateBtn = skillNode:getChildByFullName("permit.Image_52")
        UIUtils:setButtonFormat(skillNode.levelUpdateBtn, 7)

        self._scrollView:addChild(skillNode, 10)

        if i == 1 then
            skillNode.iconBg:setScale(0.8)
        end
    end

    local tempPosY = 0
    local titleBg1 = self:getUI("bg.scrollView.titleBg1")
    titleBg1:setPositionY(maxHeight - titleHei * 0.5)

    local titleBg2 = self:getUI("bg.scrollView.titleBg2")
    local tempPosY = maxHeight - nodeHei * 1 - titleHei * 1.5
    titleBg2:setPositionY(tempPosY)

    local titleBg3 = self:getUI("bg.scrollView.titleBg3")
    tempPosY = maxHeight - nodeHei * (nodeCount - 1) - titleHei * 2.5 - 53
    titleBg3:setPositionY(tempPosY)

    local offsetY = 0
    for i=1, nodeCount do
        if i == 1 then
            offsetY = titleHei
        elseif i <= (nodeCount - 1) then
            offsetY = titleHei * 2
        else
            offsetY = titleHei * 3
        end

        self._skillNode[i]:setPosition(cc.p(99, maxHeight - nodeHei * i - offsetY))
    end
end

return TeamSkillNode
