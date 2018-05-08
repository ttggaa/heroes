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
    self._fightCallback = param.fightCallback
end


function TeamSkillNode:onInit()
    self._listNode1 = self:getUI("listNode1")
    self._listNode1:setVisible(false)
    self._listNode2 = self:getUI("listNode2")
    self._listNode2:setVisible(false)
    self._scrollView = self:getUI("bg.scrollView")
    -- self._scrollView:setBounceEnabled(true)

    local title = self:getUI("bg.scrollView.titleBg1")
    UIUtils:adjustTitle(title, 3, 1)
    local title = self:getUI("bg.scrollView.titleBg2")
    UIUtils:adjustTitle(title, 3, 1)

    -- local maxHeight = self._listNode1:getContentSize().height +*5+10*(5-1)
    self._skillTop = true
end

function TeamSkillNode:reflashUI(data)
    if self._teamData == nil 
        or self._teamData.teamId ~= data.teamData.teamId then 
        self._curSelectIndex = 0
    end
    self._teamData = data.teamData
    local sysTeam = tab:Team(self._teamData.teamId)

    if table.nums(self._skillNode) == 0 then
        self:createNode()
    end
    local isGray = false
    local icon
    local isSuoDown = false
    for k,v in pairs(sysTeam.skill) do
        local skillType = v[1]
        local skillId = v[2]
        if skillType == nil or skillId == nil then
            self._viewMgr:showTip("技能数据错误，请联系管理员")
            skillType = 1
            skillId = 59055
        end
        local sysSkill = SkillUtils:getTeamSkillByType(skillId, skillType)
        -- local skillBg = self._skillNode[k]

        self._skillNode[k].nameLab:setString(lang(sysSkill.name))
        -- if sysSkill.label then
            -- if tonumber(sysSkill.label or 3) > 3 then
            --     self._skillNode[k].classSkill:setColor(cc.c3b(244,67,33))
            --     self._skillNode[k].classSkill:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
            -- else
                self._skillNode[k].classSkill:setColor(cc.c3b(240,200,145))
                -- self._skillNode[k].classSkill:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
            -- end
            self._skillNode[k].classSkill:setString(lang("TEAMSKILL_LABEL" .. (sysSkill.label or 3)))
        -- end

        if sysSkill.dazhao then
            self._skillNode[k].dazhao:setVisible(true)
        else
            self._skillNode[k].dazhao:setVisible(false)
        end

        local sysTeamStarData = tab:Star(self._teamData.star)
        local tempLevel = self._teamData["sl" .. k]
        local maxLevel = sysTeamStarData.skilllevel

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
        self._skillNode[k].levelLab:setString("Lv." .. (tempLevel+addLevel) .. "/" .. (maxLevel+addLevel))

        self._skillNode[k].levelLab:setFontSize(24)
        if uSkill and k == 1 then
            self._skillNode[k].levelLab:setColor(cc.c3b(39,247,58))
        elseif sSkill then
            self._skillNode[k].levelLab:setColor(cc.c3b(39,247,58))
        else
            self._skillNode[k].levelLab:setColor(cc.c3b(62,40,30))
        end
        -- self._skillNode[k].levelLab:enableOutline(cc.c4b(84,57,27,255), 2)
        
        local sysTeamStarData = tab:Star(self._teamData.star)
        local level = self._teamData["sl" .. k]

        local userData = self._modelMgr:getModel("UserModel"):getData()

        local systemName = "TeamSkill"
        local isOpen,toBeOpen
        if systemName then
            isOpen,toBeOpen,isLevel = SystemUtils["enable"..systemName]()
        end 

        if isOpen == false then
            -- self._skillNode[k].levelUpdateBtn:setEnabled(false)
            -- self._skillNode[k].levelUpdateBtn:setBright(false)
            -- self._skillNode[k].levelLab:setFontSize(16)
            self._skillNode[k].openLabel:setString((isLevel or 23) .. "级后可突破此技能")
            self._skillNode[k].openLabel:setVisible(true)
            self._skillNode[k].openLabel:setFontSize(20)
            self._skillNode[k].openLabel:setColor(UIUtils.colorTable.ccUIUnLockColor)
            self._skillNode[k].openLabel:setPositionX(self._skillNode[k].levelLab:getPositionX())
            self._skillNode[k].levelLab:setVisible(false)
            -- self._skillNode[k].levelLab:setString("Lv.1")
            self._skillNode[k].levelUpdateBtn:setVisible(false)
            -- if userData.lvl >= 35 then
            --     self._skillNode[k].openLabel:setVisible(true)
            -- else
            --     self._skillNode[k].openLabel:setVisible(false)
            -- end
        else
            -- self._skillNode[k].levelLab:setFontSize(20)
            -- self._skillNode[k].levelUpdateBtn:setBright(true)
            -- self._skillNode[k].levelUpdateBtn:setEnabled(true)
            self._skillNode[k].levelUpdateBtn:setVisible(true)
            self._skillNode[k].openLabel:setVisible(false)
        end

        -- local warningLab = skillBg:getChildByName("warning")
        -- self:registerTouchEvent(icon, function ()
        --    showDialog(sysSkill, self._skillNode[k].warning)
        -- end,nil,closeDialog,closeDialog)

        -- 技能升级
        -- local levelUpdateBtn = self._skillNode[k]:getChildByName("permit.Image_52")
        if self._skillNode[k].mc1 then
            self._skillNode[k].mc1:setVisible(false)
        end
        if self._skillNode[k].mc2 then
            self._skillNode[k].mc2:setVisible(false)
        end
        if level > 0 and level <= sysTeamStarData.skilllevel then 
            -- self._skillNode[k].levelLab:setVisible(true)
            -- self._skillNode[k].warningLab:setVisible(false)
            self._skillNode[k].permit:setVisible(true)
            self._skillNode[k].warn2:setVisible(false)
            self._skillNode[k].warning:setVisible(false)
            self._skillNode[k].dazhao:setBrightness(0)
            self._skillNode[k].nameLab:setColor(cc.c3b(70,40,0))
            -- self._skillNode[k].nameLab:enableOutline(cc.c4b(60, 30, 10, 255), 1)
            self:registerClickEvent(self._skillNode[k].levelUpdateBtn, function ()
                if tempLevel == maxLevel then
                    self._viewMgr:showTip("技能已达当前最高等级")
                else
                    self._viewMgr:showDialog("team.TeamSkillUpdateView", {teamData = self._teamData, index = k}, true) 
                end
            end)
        else
            self._skillNode[k].permit:setVisible(false)
            self._skillNode[k].warn2:setVisible(false)

            self._skillNode[k].dazhao:setBrightness(-40)
            
            self._skillNode[k].nameLab:setColor(UIUtils.colorTable.ccUIUnLockColor)
            -- self._skillNode[k].nameLab:enableOutline(cc.c4b(60, 30, 10, 255), 1)
            isGray = true
            if level == -1 then -- 未开启
                self._skillNode[k].warn1:setVisible(true)
                self._skillNode[k].warn2:setVisible(false)
                self._skillNode[k].warning:setVisible(true)
                
                local tempStr
                if k == 2 then
                    -- tempStr = "进阶到蓝色解锁"
                    tempStr = "蓝色"
                    -- self._skillNode[k].nextLab:setColor(cc.c3b(72,210,255))
                    -- self._skillNode[k].nextLab:enableOutline(cc.c4b(0,44,118,255), 1)
                elseif k == 3 then
                    -- tempStr = "进阶到紫色解锁"
                    tempStr = "紫色"
                    -- self._skillNode[k].nextLab:setColor(cc.c3b(239,109,254))
                    -- self._skillNode[k].nextLab:enableOutline(cc.c4b(71,0,143,255), 1)
                elseif k == 4 then
                    -- tempStr = "进阶到橙色解锁"
                    tempStr = "橙色"
                    -- self._skillNode[k].nextLab:setColor(cc.c3b(255,122,15))
                    -- self._skillNode[k].nextLab:enableOutline(cc.c4b(95,38,0,255), 1)
                end
                
                -- self:setGray(self._skillNode[k].iconBg,false)
                self._skillNode[k].nextLab:setString(tempStr)
                self._skillNode[k].nextLab:setPositionX(self._skillNode[k].Label_69_0:getPositionX() + self._skillNode[k].Label_69_0:getContentSize().width)
                self._skillNode[k].Label_69:setPositionX(self._skillNode[k].nextLab:getPositionX() + self._skillNode[k].nextLab:getContentSize().width)
            elseif level == 0 then -- 未解锁
                if tonumber(k) == 3 or tonumber(k) == 4 then
                    isSuoDown = true
                end
                self._skillNode[k].warn1:setVisible(false)
                self._skillNode[k].warning:setVisible(false)
                self._skillNode[k].warn2:setVisible(true)
                self:setAnim(k,1)
                local userData = self._modelMgr:getModel("UserModel"):getData()

                local goldValue = tab:Setting("G_TEAMSKILL_UNLOCK").value[k] or 0
                -- UIUtils:setGoldValueColor(self._skillNode[k].goldValue, goldValue, userData.gold)
                self._skillNode[k].goldValue:setString(goldValue)
                
                if userData.gold >= goldValue then
                    self:registerClickEvent(self._skillNode[k].suo, function()
                        self:openSkill(k)
                        self:setAnim(k,2)
                    end)
                else
                    self:registerClickEvent(self._skillNode[k].suo, function()
                        DialogUtils.showLackRes( {goalType = "gold"})
                    end)
                end

            end
        end

        local param = {teamSkill = sysSkill ,isGray = isGray ,eventStyle = 1, teamData = self._teamData, level = tempLevel,addLevel = addLevel}
        if self._skillNode[k]:getChildByName("iconCell") ~= nil then 
            icon = self._skillNode[k]:getChildByName("iconCell") 
            IconUtils:updateTeamSkillIconByView(icon, param)
        else
            -- icon = IconUtils:createTeamSkillIconById({teamSkill = sysSkill ,eventStyle = 0})
            icon = IconUtils:createTeamSkillIconById(param)
            icon:setName("iconCell")
            icon:setPosition(cc.p(5, -3))
            -- if k ~= 1 then
            --     icon:setScale(0.9)
            -- end
            icon:setScale(0.9)
            -- icon:setScale(0.8)
            -- icon:setPosition(cc.p(9, 7))
            self._skillNode[k]:addChild(icon)
        end
        isGray = false

        self._skillNode[k].skillShow:setVisible(false)
        if sysTeam.showskill then
            -- for k,v in pairs(sysTeam.showskill) do
            --     dump(v)
            --     if conditions then
            --         --todo
            --     end
            -- end
            -- for i=1,table.nums(sysTeam.showskill) do

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
        self._scrollView:jumpToTop() --:scrollToTop(0.01,false)
    else
        self._skillTop = true
    end

end

function TeamSkillNode:getTypeAndLvByStr(str)
    local type = tonumber(string.sub(str,1,3))
    local lv = tonumber(string.sub(str,5))
    return type,lv
end

function TeamSkillNode:openSkill(positionId) -- 解锁
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
        self:setAnim(positionId,2)
        audioMgr:playSound("ItemGain_2")

        local fightBg = self:getUI("bg")
        TeamUtils:setFightAnim(fightBg, {oldFight = self._oldFight, newFight = TeamUtils:updateFightNum(), x = -200, y = fightBg:getContentSize().height - 110})
        -- print("解锁")
        -- self:openSkillFinish(result)
    end)
end

function TeamSkillNode:setAnim(index,animType) -- 解锁
    local skillNode = self._skillNode[index]
    if animType == 1 then
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

        -- jinengkejiesuosaoguang
        -- self._skillNode[i].suoBtnAnim:setVisible(true)
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
        -- mc2:setScale(0.8)

        mc2:setPosition(cc.p(skillNode:getPositionX()+55,skillNode:getPositionY()+49))
        mc2:addCallbackAtFrame(5, function()
            mc3 = mcMgr:createViewMC("jinengsuo1_qianghua", false, true)
            mc3:setPosition(cc.p(55,49))
            skillNode:addChild(mc3,5)
        end)

        self._scrollView:addChild(mc2,10)
    end
end

-- function TeamSkillNode:setGray(icon,inGray)
--     local tempIcon 
--     if inGray == true then
--         icon:setSaturation(-100)
--         tempIcon = icon:getChildByFullName("iconCell")
--         tempIcon:setSaturation(-100)
--     else
--         icon:setSaturation(0)
--         tempIcon = icon:getChildByFullName("iconCell")
--         tempIcon:setSaturation(0)
--     end
    
-- end

function TeamSkillNode:createNode()
    local nodeCount = 4
    local maxHeight = self._listNode2:getContentSize().height + self._listNode2:getContentSize().height*(nodeCount-1)+5*nodeCount
    maxHeight = maxHeight + 62
    self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, maxHeight))
    
    for i=1,nodeCount do
        if i == 1 then
            self._skillNode[i] = self._listNode2:clone()
            self._skillNode[i]:setVisible(true)
            self._skillNode[i]:setName("skillBg" .. i)
            self._skillNode[i].levelLab = self._skillNode[i]:getChildByFullName("permit.levelLab")
            self._skillNode[i].levelLab:setFontSize(24)
            self._skillNode[i].levelLab:setFontName(UIUtils.ttfName)
            self._skillNode[i].levelLab:disableEffect()
            -- self._skillNode[i].levelLab:enableOutline(cc.c4b(110,69,37), 1)

            self._skillNode[i].classSkill = self._skillNode[i]:getChildByFullName("classSkillBg.classSkill")
            self._skillNode[i].classSkill:setFontSize(20)
            self._skillNode[i].classSkill:setFontName(UIUtils.ttfName)
            self._skillNode[i].classSkill:setColor(cc.c3b(255,188,102))
            self._skillNode[i].classSkill:disableEffect()
            
            -- self._skillNode[i].levelLab:enableShadow(cc.c4b(90,48,3,255), cc.size(0, 0))
            self._skillNode[i].nameLab = self._skillNode[i]:getChildByFullName("nameLab")
            self._skillNode[i].nameLab:disableEffect()
            self._skillNode[i].nameLab:setFontSize(26)
            self._skillNode[i].nameLab:setFontName(UIUtils.ttfName)        
            self._skillNode[i].nameLab:setPositionY( self._skillNode[i].nameLab:getPositionY())

            -- self._skillNode[i].nameLab:enableShadow(cc.c4b(90,48,3,255), cc.size(0, 0))
            -- self._skillNode[i].nameLab:setFontName(UIUtils.ttfName)
            self._skillNode[i].Label_69_0 = self._skillNode[i]:getChildByFullName("warning.warn1.Label_69_0")
            self._skillNode[i].Label_69 = self._skillNode[i]:getChildByFullName("warning.warn1.Label_69")
            self._skillNode[i].Label_69_0:disableEffect()
            self._skillNode[i].Label_69:disableEffect()

            self._skillNode[i].nextLab = self._skillNode[i]:getChildByFullName("warning.warn1.nextLab")
            self._skillNode[i].nextLab:disableEffect()
            self._skillNode[i].iconBg = self._skillNode[i]:getChildByFullName("icon")
            -- self._skillNode[i].nameLab = self._skillNode[i]:getChildByFullName("permit.nameLab")

            self._skillNode[i].gold = self._skillNode[i]:getChildByFullName("warn2.gold")
            local scaleNum1 = math.floor((32/self._skillNode[i].gold:getContentSize().width)*100)
            self._skillNode[i].gold:setScale(scaleNum1/100)        
            self._skillNode[i].goldValue = self._skillNode[i]:getChildByFullName("warn2.goldValue")
            self._skillNode[i].suo = self._skillNode[i]:getChildByFullName("warn2.suo")
            UIUtils:setButtonFormat(self._skillNode[i].suo, 7)

            self._skillNode[i].suoBtnAnim = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
            self._skillNode[i].suoBtnAnim:setScale(0.7)
            self._skillNode[i].suoBtnAnim:setPosition(cc.p(self._skillNode[i].suo:getContentSize().width*0.5,self._skillNode[i].suo:getContentSize().height*0.5))
            self._skillNode[i].suo:addChild(self._skillNode[i].suoBtnAnim, 20)
            -- self._skillNode[i].suo:setTitleFontName(UIUtils.ttfName)
            -- self._skillNode[i].suo:setTitleFontSize(32) 
            -- self._skillNode[i].suo:setColor(UIUtils.colorTable.ccUICommonBtnColor3) 
            -- self._skillNode[i].suo:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnColor4, 2)

            self._skillNode[i].openLabel = self._skillNode[i]:getChildByFullName("permit.openLabel")
            self._skillNode[i].openLabel:setString("(23级开启技能升级)")
            self._skillNode[i].permit = self._skillNode[i]:getChildByFullName("permit")
            self._skillNode[i].warning = self._skillNode[i]:getChildByFullName("warning")
            self._skillNode[i].warn1 = self._skillNode[i]:getChildByFullName("warning.warn1")
            self._skillNode[i].warn2 = self._skillNode[i]:getChildByFullName("warn2")
            self._skillNode[i].dazhao = self._skillNode[i]:getChildByFullName("dazhao")
            self._skillNode[i].dazhao:setVisible(false)
            self._skillNode[i].skillShow = self._skillNode[i]:getChildByFullName("skillShow")
            self._skillNode[i].skillShow:setVisible(false)
            self._skillNode[i].levelUpdateBtn = self._skillNode[i]:getChildByFullName("permit.Image_52")
            UIUtils:setButtonFormat(self._skillNode[i].levelUpdateBtn, 7)

            -- self._skillNode[i].levelUpdateBtn:setName("upgradeSkill")
            -- self._skillNode[i].levelUpdateBtn:setTitleFontName(UIUtils.ttfName)
            -- self._skillNode[i].levelUpdateBtn:setColor(UIUtils.colorTable.ccUIBaseColor1)
            -- self._skillNode[i].levelUpdateBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 3)
            self._scrollView:addChild(self._skillNode[i])
        else
            self._skillNode[i] = self._listNode2:clone()
            self._skillNode[i]:setVisible(true)
            self._skillNode[i]:setName("skillBg" .. i)
            self._skillNode[i].levelLab = self._skillNode[i]:getChildByFullName("permit.levelLab")
            self._skillNode[i].levelLab:setFontSize(24)
            self._skillNode[i].levelLab:setFontName(UIUtils.ttfName)
            self._skillNode[i].levelLab:disableEffect()
            -- self._skillNode[i].levelLab:enableOutline(cc.c4b(110,69,37), 1)

            self._skillNode[i].classSkill = self._skillNode[i]:getChildByFullName("classSkillBg.classSkill")
            self._skillNode[i].classSkill:setFontSize(20)
            self._skillNode[i].classSkill:setFontName(UIUtils.ttfName)
            self._skillNode[i].classSkill:setColor(cc.c3b(255,188,102))
            self._skillNode[i].classSkill:disableEffect()
            
            -- self._skillNode[i].levelLab:enableShadow(cc.c4b(90,48,3,255), cc.size(0, 0))
            self._skillNode[i].nameLab = self._skillNode[i]:getChildByFullName("nameLab")
            self._skillNode[i].nameLab:disableEffect()
            self._skillNode[i].nameLab:setFontSize(26)
            self._skillNode[i].nameLab:setFontName(UIUtils.ttfName)        
            self._skillNode[i].nameLab:setPositionY( self._skillNode[i].nameLab:getPositionY())

            -- self._skillNode[i].nameLab:enableShadow(cc.c4b(90,48,3,255), cc.size(0, 0))
            -- self._skillNode[i].nameLab:setFontName(UIUtils.ttfName)
            self._skillNode[i].Label_69_0 = self._skillNode[i]:getChildByFullName("warning.warn1.Label_69_0")
            self._skillNode[i].Label_69 = self._skillNode[i]:getChildByFullName("warning.warn1.Label_69")
            self._skillNode[i].Label_69_0:disableEffect()
            self._skillNode[i].Label_69:disableEffect()

            self._skillNode[i].nextLab = self._skillNode[i]:getChildByFullName("warning.warn1.nextLab")
            self._skillNode[i].nextLab:disableEffect()
            self._skillNode[i].iconBg = self._skillNode[i]:getChildByFullName("icon")
            self._skillNode[i].iconBg:setScale(0.8)
            -- self._skillNode[i].nameLab = self._skillNode[i]:getChildByFullName("permit.nameLab")

            self._skillNode[i].gold = self._skillNode[i]:getChildByFullName("warn2.gold")
            local scaleNum1 = math.floor((32/self._skillNode[i].gold:getContentSize().width)*100)
            self._skillNode[i].gold:setScale(scaleNum1/100)        
            self._skillNode[i].goldValue = self._skillNode[i]:getChildByFullName("warn2.goldValue")
            self._skillNode[i].suo = self._skillNode[i]:getChildByFullName("warn2.suo")
            UIUtils:setButtonFormat(self._skillNode[i].suo, 7)
            -- self._skillNode[i].suo:setTitleFontName(UIUtils.ttfName)
            -- self._skillNode[i].suo:setTitleFontSize(32) 
            -- self._skillNode[i].suo:setColor(cc.c4b(255, 243, 193, 255)) 
            -- self._skillNode[i].suo:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

            self._skillNode[i].suoBtnAnim = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
            self._skillNode[i].suoBtnAnim:setScale(0.7)
            self._skillNode[i].suoBtnAnim:setPosition(cc.p(self._skillNode[i].suo:getContentSize().width*0.5,self._skillNode[i].suo:getContentSize().height*0.5))
            self._skillNode[i].suo:addChild(self._skillNode[i].suoBtnAnim, 20)

            self._skillNode[i].openLabel = self._skillNode[i]:getChildByFullName("permit.openLabel")
            self._skillNode[i].openLabel:setString("(23级开启技能升级)")
            self._skillNode[i].permit = self._skillNode[i]:getChildByFullName("permit")
            self._skillNode[i].warning = self._skillNode[i]:getChildByFullName("warning")
            self._skillNode[i].warn1 = self._skillNode[i]:getChildByFullName("warning.warn1")
            self._skillNode[i].warn2 = self._skillNode[i]:getChildByFullName("warn2")
            self._skillNode[i].dazhao = self._skillNode[i]:getChildByFullName("dazhao")
            self._skillNode[i].dazhao:setVisible(false)
            self._skillNode[i].skillShow = self._skillNode[i]:getChildByFullName("skillShow")
            self._skillNode[i].skillShow:setVisible(false)
            self._skillNode[i].levelUpdateBtn = self._skillNode[i]:getChildByFullName("permit.Image_52")
            UIUtils:setButtonFormat(self._skillNode[i].levelUpdateBtn, 7)
            -- self._skillNode[i].levelUpdateBtn:setName("upgradeSkill")
            -- self._skillNode[i].levelUpdateBtn:setTitleFontName(UIUtils.ttfName)
            -- self._skillNode[i].levelUpdateBtn:setColor(cc.c4b(255, 255, 255, 255))
            -- self._skillNode[i].levelUpdateBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 3)
            self._scrollView:addChild(self._skillNode[i])
        end
    end

    local titleBg1 = self:getUI("bg.scrollView.titleBg1")
    titleBg1:setPositionY(maxHeight-19)
    local titleBg2 = self:getUI("bg.scrollView.titleBg2")
    maxHeight = maxHeight - self._listNode2:getContentSize().height - 48
    titleBg2:setPositionY(maxHeight-19)
    maxHeight = maxHeight - 18
    for i=1,nodeCount do
        if i == 1 then
            self._skillNode[i]:setPosition(cc.p(99,maxHeight+29))
        else
            self._skillNode[i]:setPosition(cc.p(99,maxHeight-19))
        end
        
        maxHeight = maxHeight - (0 + self._skillNode[i]:getContentSize().height)
    end

end

return TeamSkillNode
