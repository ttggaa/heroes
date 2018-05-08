--[[
    Filename:    TeamAwakenDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-08-11 14:52:02
    Description: File description
--]]

-- 觉醒
local TeamAwakenDialog = class("TeamAwakenDialog", BasePopView)
local TeamUtils = TeamUtils

function TeamAwakenDialog:ctor(params)
    TeamAwakenDialog.super.ctor(self)
    if not params then
        params = {}
    end
    self._selectTeamId = params.teamId or 102
end


function TeamAwakenDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("team.TeamAwakenDialog")
        end
        self:close()
    end)
    self._teamModel = self._modelMgr:getModel("TeamModel")

    self._selectSkill = 0

    self:updateRightData()
    self:selectClick(true)

    local raceImg = self:getUI("bg.raceBg.raceImg")
    local systeam = tab.team[self._selectTeamId]
    local race = tab:Race(systeam["race"][1])
    self._raceImg = race
    raceImg:loadTexture("asset/uiother/race/awake_race_" .. race.pic .. ".jpg", 0)
    raceImg:setCapInsets(cc.rect(1012, 0, 1, 1))

    -- 选择觉醒升级
    local starIcon = self:getUI("bg.leftLayer.starIcon")
    self:registerClickEvent(starIcon, function()
        self:selectClick(false)
        self._selectSkill = 0
        self:selectClick(true)
        self:updateRightData()
    end)

    -- 觉醒升级
    local saveBtn = self:getUI("bg.rightLayer2.saveBtn")
    self:registerClickEvent(saveBtn, function()
        local selectTeamData = self._teamModel:getTeamAndIndexById(self._selectTeamId)
        local purpleStar = selectTeamData.aLvl or 1
        local yellowStar = selectTeamData.star or 1
        local systeam = tab:Team(self._selectTeamId)
        local awakingUpTab = systeam.awakingUpNum
        local itemId = systeam.awakingUp
        local costNum = awakingUpTab[purpleStar]
        local _, tempItemCount = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
        if costNum and tempItemCount < costNum then
            print("============" .. itemId or "")
            self._viewMgr:showDialog("bag.DialogAccessTo",{goodsId = itemId, needItemNum = 0},true)
            return
        end
        if purpleStar >= yellowStar then
            self._viewMgr:showTip(lang("AWAKING_TIPS_2"))
            return
        end
        self:upAwakingLevel()
    end)


    self:listenReflash("ItemModel", self.updateRightData)

    -- local saveBtn = self:getUI("bg.rightLayer1.saveBtn")
    -- self:registerClickEvent(saveBtn, function()
    --     -- self:openAwakingTask() -- 开启觉醒任务
    --     -- self:awakingActivate() -- 觉醒
    -- end)
end

function TeamAwakenDialog:selectClick(flag)
    local tree, class = self:getTreeAndClass()
    if tree == 0 then
        local skillbg = self:getUI("bg.leftLayer.starIcon")
        local selectSkill = skillbg:getChildByFullName("selectSkill")
        if not selectSkill then
            selectSkill = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
            selectSkill:setName("selectSkill")
            selectSkill:gotoAndStop(1)
            selectSkill:setPosition(skillbg:getContentSize().width*0.5, skillbg:getContentSize().height*0.5)
            selectSkill:setScale(0.7)
            selectSkill:setVisible(false)
            skillbg:addChild(selectSkill,2)       
        end
        selectSkill:setVisible(flag)
    else
        if class == 1 then
            local skillbg = self:getUI("bg.leftLayer.skillcircle" .. tree .. class)
            local selectSkill = skillbg:getChildByFullName("selectSkill")
            if not selectSkill then
                selectSkill = mcMgr:createViewMC("xuanzhong_tianfushu", true, false)
                selectSkill:setName("selectSkill")
                selectSkill:setPosition(skillbg:getContentSize().width*0.5, skillbg:getContentSize().height*0.5)
                selectSkill:setScale(1.1)
                skillbg:addChild(selectSkill,1)       
            end
            selectSkill:setVisible(flag)
        else
            local skillbg = self:getUI("bg.leftLayer.skillcircle" .. tree .. class)
            local selectSkill = skillbg:getChildByFullName("selectSkill")
            if not selectSkill then
                selectSkill = mcMgr:createViewMC("xuanzhong1_tianfushu", true, false)
                selectSkill:setName("selectSkill")
                selectSkill:setPosition(skillbg:getContentSize().width*0.5, skillbg:getContentSize().height*0.5)
                selectSkill:setScale(1.1)
                skillbg:addChild(selectSkill,1)       
            end
            selectSkill:setVisible(flag)
        end
    end
end



-- function TeamAwakenDialog:openAwakingTask()
--     local param = {teamId = 102}
--     self._serverMgr:sendMsg("AwakingServer", "openAwakingTask", param, true, {}, function (result)
--         dump(result, "result ===", 10)
--         -- self:openAwakingTaskFinish(result)
--         local selectTeamData = self._teamModel:getTeamAndIndexById(self._selectTeamId)
--         dump(selectTeamData, "tttttttttt")
--     end)
-- end

function TeamAwakenDialog:saveRightAnim(animType)
    if animType == 1 then
        local alreadySave = self:getUI("bg.rightLayer1.alreadySave")
        local saveBtn = self:getUI("bg.rightLayer1.saveBtn")
        if saveBtn then
            saveBtn:setVisible(false)
        end
        if alreadySave then
            alreadySave:setVisible(true)
        end
        -- local seq = CCSequence:create(arrayOfActions)
    end
end

function TeamAwakenDialog:saveAwakingTree()
    local tree, class = self:getTreeAndClass()
    print("tree, class==========", tree, class, type(class))
    if tree == 0 then
        return
    end
    local param = {teamId = self._selectTeamId, branchId = tree, posId = class}
    self._serverMgr:sendMsg("AwakingServer", "saveAwakingTree", param, true, {}, function (result)
        -- local selectTeamData = self._teamModel:getTeamAndIndexById(self._selectTeamId)
        -- dump(selectTeamData, "tttttttttt")
        self:updateLeftData()
        self:saveRightAnim(1)
    end)
end

function TeamAwakenDialog:upAwakingLevel()
    -- self._oldTeamData = clone(self._teamModel:getTeamAndIndexById(self._selectTeamId))
    -- local tempTeamData = {}
    -- tempTeamData.old = self._oldTeamData
    -- tempTeamData.new = self._oldTeamData
    -- self._viewMgr:showDialog("team.TeamAwakenStarSuccessDialog",tempTeamData,true) 
    
    local param = {teamId = self._selectTeamId}
    self._oldTeamData = clone(self._teamModel:getTeamAndIndexById(self._selectTeamId))
    self._serverMgr:sendMsg("AwakingServer", "upAwakingLevel", param, true, {}, function (result)
        -- dump(result, "result ===", 10)
        local backTeamData = self._teamModel:getTeamAndIndexById(self._selectTeamId)
        local tempTeamData = {}
        tempTeamData.old = self._oldTeamData
        tempTeamData.new = backTeamData
        self._viewMgr:showDialog("team.TeamAwakenStarSuccessDialog",tempTeamData,true) 
        self._oldTeamData = nil
        self:updateSkillStarData()
    end)
end




function TeamAwakenDialog:reflashUI(data)
    -- local selectTeamData = self._teamModel:getTeamAndIndexById(self._selectTeamId)
    -- dump(selectTeamData, "selectTeamData")
    self:updateLeftData()
end

function TeamAwakenDialog:updateSkillStarData()
    local rightLayer1 = self:getUI("bg.rightLayer1")
    rightLayer1:setVisible(false)
    local rightLayer2 = self:getUI("bg.rightLayer2")
    rightLayer2:setVisible(true)

    local selectTeamData = self._teamModel:getTeamAndIndexById(self._selectTeamId)
    local yellowStar = selectTeamData.star or 1
    local purpleStar = selectTeamData.aLvl or 1
    local systeam = tab:Team(self._selectTeamId)

    -- 创建星星
    local starBg = self:getUI("bg.rightLayer2.starBg")
    local starx = starBg:getContentSize().width - 22
    local stary = starBg:getContentSize().height - 10
    for i= 1 , 6 do
        local iconStar = starBg:getChildByName("star" .. i)
        if i <= 6 - yellowStar then 
            local fileName = "globalImageUI6_star2.png"
            if i > 6 - purpleStar then
                fileName = "globalImageUI_teamskillBigStar2.png"
            end
            if iconStar == nil then
                iconStar = cc.Sprite:createWithSpriteFrameName(fileName)
                iconStar:setAnchorPoint(cc.p(0.5, 1))
                starBg:addChild(iconStar,3) 
                iconStar:setScale(0.7)
                iconStar:setName("star" .. i)
                iconStar:setPosition(starx, stary)
                starx = starx - iconStar:getContentSize().width * iconStar:getScale()/2 - 10
            else
                iconStar:setSpriteFrame(fileName)
            end
        else
            local fileName = "globalImageUI6_star2.png"
            if i > 6 - purpleStar then
                fileName = "globalImageUI_teamskillBigStar1.png"
            end
            if iconStar == nil then
                iconStar = cc.Sprite:createWithSpriteFrameName(fileName)
                iconStar:setAnchorPoint(cc.p(0.5, 1))
                iconStar:setScale(0.7)
                starBg:addChild(iconStar,3)    
                iconStar:setName("star" .. i)
                iconStar:setPosition(starx, stary)
                starx = starx - iconStar:getContentSize().width * iconStar:getScale()/2 - 10
            else
                iconStar:setSpriteFrame(fileName)
            end
        end
    end
    -- for i= 1, 6 do
    --     local iconStar = starBg:getChildByName("star" .. i)
    --     if i <= 6 - purpleStar then 
    --         if iconStar == nil then
    --             iconStar = cc.Sprite:createWithSpriteFrameName("globalImageUI6_star2.png")
    --             iconStar:setAnchorPoint(cc.p(0.5, 1))
    --             starBg:addChild(iconStar,3) 
    --             iconStar:setScale(0.7)
    --             iconStar:setName("star" .. i)
    --             iconStar:setPosition(starx, stary)
    --             starx = starx - iconStar:getContentSize().width * iconStar:getScale()/2 - 10
    --         else
    --             iconStar:setSpriteFrame("globalImageUI6_star2.png")
    --         end
    --     else
    --         if iconStar == nil then
    --             iconStar = cc.Sprite:createWithSpriteFrameName("globalImageUI_teamskillSmallStar.png")
    --             iconStar:setAnchorPoint(cc.p(0.5, 1))
    --             starBg:addChild(iconStar,3)              
    --             iconStar:setScale(0.7)
    --             iconStar:setName("star" .. i)
    --             iconStar:setPosition(starx, stary)
    --             starx = starx - iconStar:getContentSize().width * iconStar:getScale()/2 - 10
    --         else
    --             iconStar:setSpriteFrame("globalImageUI_teamskillSmallStar.png")
    --         end
    --     end
    -- end

    -- 头像
    local iconBg = self:getUI("bg.rightLayer2.iconBg")
    local backQuality = self._teamModel:getTeamQualityByStage(selectTeamData.stage)
    local icon = iconBg:getChildByName("teamIcon")
    local param = {teamData = selectTeamData, sysTeamData = systeam,quality = backQuality[1] , quaAddition = backQuality[2],  eventStyle = 0}
    if icon == nil then 
        icon = IconUtils:createTeamIconById(param)
        icon:setName("teamIcon")
        icon:setPosition(cc.p(116/2+2,116/2+2))
        icon:setAnchorPoint(cc.p(0.5, 0.5))
        icon:setScale(0.90)
        iconBg:addChild(icon)
    else
        IconUtils:updateTeamIconByView(iconBg, param)
    end

    -- 属性
    local arrow1 = self:getUI("bg.rightLayer2.natureBg1.arrow")
    local oldValue1 = self:getUI("bg.rightLayer2.natureBg1.oldValue")
    local oldValue2 = self:getUI("bg.rightLayer2.natureBg2.oldValue")
    local atktalent = systeam.atktalent
    local hptalent = systeam.hptalent
    local atkStr = TeamUtils.getNatureNums(atktalent[purpleStar])
    local hpStr = TeamUtils.getNatureNums(hptalent[purpleStar])
    oldValue1:setString("+" .. atkStr)
    oldValue2:setString("+" .. hpStr)
    local arrow2 = self:getUI("bg.rightLayer2.natureBg2.arrow")
    local addValue1 = self:getUI("bg.rightLayer2.natureBg1.addValue")
    local addValue2 = self:getUI("bg.rightLayer2.natureBg2.addValue")
    if (purpleStar + 1) > 6 then
        arrow1:setVisible(false)
        arrow2:setVisible(false)
        addValue1:setString("(Max)")
        addValue2:setString("(Max)")
        local posx = oldValue1:getPositionX() + oldValue1:getContentSize().width
        addValue1:setPositionX(posx)
        posx = oldValue2:getPositionX() + oldValue2:getContentSize().width
        addValue2:setPositionX(posx)
    else
        local nextLvl = purpleStar + 1
        atkStr = TeamUtils.getNatureNums(atktalent[nextLvl])
        hpStr = TeamUtils.getNatureNums(hptalent[nextLvl])
        addValue1:setString("+" .. atkStr)
        addValue2:setString("+" .. hpStr)
        -- local posx = oldValue1:getPositionX() + oldValue1:getContentSize().width
        -- arrow1:setPositionX(posx)
        -- posx = arrow1:getPositionX() + arrow1:getContentSize().width
        -- addValue1:setPositionX(posx)
        -- local posx = oldValue2:getPositionX() + oldValue2:getContentSize().width
        -- arrow2:setPositionX(posx)
        -- posx = arrow2:getPositionX() + arrow2:getContentSize().width
        -- addValue2:setPositionX(posx)
    end

    -- 消耗
    local costImg = self:getUI("bg.rightLayer2.alreadySave.costImg")
    local costLab = self:getUI("bg.rightLayer2.alreadySave.costLab")
    local alreadySave = self:getUI("bg.rightLayer2.alreadySave")
    local saveBtn = self:getUI("bg.rightLayer2.saveBtn")

    local awakingUpTab = systeam.awakingUpNum
    local costNum = awakingUpTab[purpleStar]
    local itemId = systeam.awakingUp
    local _, tempItemCount = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
    local toolTab = tab:Tool(itemId)
    if not costNum then
        costImg:setVisible(false)
        costLab:setVisible(false)
        alreadySave:setVisible(false)
        saveBtn:setVisible(false)
    else
        if tempItemCount >= costNum then
            costLab:setColor(UIUtils.colorTable.ccUIBaseColor9)
        else
            costLab:setColor(UIUtils.colorTable.ccColorQuality6)
        end
        costLab:setString(tempItemCount .. "/" .. costNum)
        costImg:loadTexture("globalImageUI_splice_jx.png", 1)
        -- costImg:loadTexture(toolTab.art .. ".jpg", 1)
        costImg:setScale(0.7)
        costImg:setVisible(true)
        costLab:setVisible(true)
        alreadySave:setVisible(true)
        saveBtn:setVisible(true)
        local posx = 0.5*(alreadySave:getContentSize().width - costImg:getContentSize().width*costImg:getScaleX() - costLab:getContentSize().width)
        costImg:setPositionX(posx)
        posx = costImg:getPositionX() + costImg:getContentSize().width*costImg:getScaleX()+2
        costLab:setPositionX(posx)
    end
end

function TeamAwakenDialog:updateRightData()
    print("self._selectSkill===========", self._selectSkill, type(self._selectSkill))
    local tree, class = self:getTreeAndClass()
    if tree == 0 then
        self:updateSkillStarData()
        return
    end
    local rightLayer1 = self:getUI("bg.rightLayer1")
    rightLayer1:setVisible(true)
    local rightLayer2 = self:getUI("bg.rightLayer2")
    rightLayer2:setVisible(false)

    local teamId = self._selectTeamId
    local selectTeamData = self._teamModel:getTeamAndIndexById(teamId)
    local teamTab = tab.team[teamId]
    local tskill = teamTab.skill 
    local talentTree = teamTab["talentTree" .. tree]
    local _tskill = tskill[talentTree[1]]

    local indexId = class + 1
    -- local skillbg = self:getUI("bg.leftLayer.skillcircle" .. tree .. class)
    local skillType = talentTree[indexId][1]
    local skillId = talentTree[indexId][2]

    local sysSkill = SkillUtils:getTeamSkillByType(skillId, skillType)
    -- dump(sysSkill)
    local batchType = 3
    local awakingLimit = tab:Setting("AWAKINGLIMIT").value
    local teamStage = selectTeamData.stage
    local teamTree = selectTeamData.tree 
    if teamStage >= awakingLimit[tree] then
        batchType = 1
        if teamTree["b" .. tree] == class then
            batchType = 2
        end
    end

    -- 名字
    local skillName = self:getUI("bg.rightLayer1.skillName")
    skillName:setString(lang(sysSkill.name))
    if class == 1 then
        skillName:setColor(cc.c3b(55, 107, 165))
        skillName:enable2Color(1, cc.c4b(14, 55, 76, 255))
    else
        skillName:setColor(cc.c3b(179, 99, 39))
        skillName:enable2Color(1, cc.c4b(102, 46, 21, 255))
    end

    -- 图标
    local param = {teamSkill = sysSkill, styleType = 1, teamTree = class}
    local skillbg = self:getUI("bg.rightLayer1.iconBg")
    local skillIcon = skillbg:getChildByName("skillIcon")
    if not skillIcon then
        skillIcon = self:createSkillIcon(param)
        skillIcon:setName("skillIcon")
        skillIcon:setAnchorPoint(0.5, 0.5)
        skillIcon:setScale(1.1)
        skillIcon:setPosition(skillbg:getContentSize().width*0.5, skillbg:getContentSize().height*0.5)
        skillbg:addChild(skillIcon)
    else
        self:updateTeamSkillIconByView(skillIcon, param)
    end

    -- 描述
    local richtextBg = self:getUI("bg.rightLayer1.richtextBg")
    local richText = richtextBg:getChildByName("richText")
    if richText ~= nil then
        richText:removeFromParent()
    end

    local desc = SkillUtils:handleSkillDesc1(lang(sysSkill.des), selectTeamData, 1, 1)
    if string.find(desc, "color=") == nil then
        desc = "[color=fae6c8]"..desc.."[-]"
    end
    print("desc ================", sysSkill.des, lang(sysSkill.des))
    desc = string.gsub(desc, "fae6c8", "8a5c1d")
    richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5)
    richText:setName("richText")
    richtextBg:addChild(richText)

    local saveBtn = self:getUI("bg.rightLayer1.saveBtn")
    self:registerClickEvent(saveBtn, function()
        local selectTeamData = self._teamModel:getTeamAndIndexById(self._selectTeamId)
        dump(selectTeamData, "tttttttttt")
        self:saveAwakingTree()
    end)

    local openLab = self:getUI("bg.rightLayer1.openLab")
    local alreadySave = self:getUI("bg.rightLayer1.alreadySave")
    local saveBtn = self:getUI("bg.rightLayer1.saveBtn")
    if batchType == 1 then
        saveBtn:setVisible(true)
        alreadySave:setVisible(false)
        openLab:setVisible(false)
    elseif batchType == 2 then
        saveBtn:setVisible(false)
        alreadySave:setVisible(true)
        openLab:setVisible(false)
    elseif batchType == 3 then
        saveBtn:setVisible(false)
        alreadySave:setVisible(false)
        openLab:setVisible(true)
        local str = lang("AWAKING_BUTTON_" .. tree) or ""
        openLab:setString(str .. "解锁")
    end
end

function TeamAwakenDialog:getTreeAndClass(selectSkill)
    local selectSkill = selectSkill or self._selectSkill
    local tree = math.floor(selectSkill/10)
    local class = math.fmod(selectSkill, 10)
    return tree, class
end

function TeamAwakenDialog:updateLeftData()
    local teamId = self._selectTeamId
    local inTeamData = self._teamModel:getTeamAndIndexById(self._selectTeamId)
    local branchData = inTeamData.tree
    local teamStage = inTeamData.stage
    local teamTab = tab.team[teamId]
    local tskill = teamTab.skill 
    local awakingColor = TeamUtils.awakingRaceLineColor[self._raceImg.pic]
    local awakingLimit = tab:Setting("AWAKINGLIMIT").value
    for tree=1,3 do
        local talentTree = teamTab["talentTree" .. tree]
        local _tskill = tskill[talentTree[1]]
        for class=1,2 do
            local indexId = class + 1
            local skillbg = self:getUI("bg.leftLayer.skillcircle" .. tree .. class)
            local skillType = talentTree[indexId][1]
            local skillId = talentTree[indexId][2]
            if skillType == nil or skillId == nil then
                self._viewMgr:showTip("技能数据错误，请联系管理员")
                skillType = 1
                skillId = 59055
            end
            local skillLine = self:getUI("bg.leftLayer.skillLine" .. tree .. class)
            if skillLine then
                skillLine:setOpacity(150)
            end
            -- 技能图标
            local sysSkill = SkillUtils:getTeamSkillByType(skillId, skillType)
            local param = {teamSkill = sysSkill, styleType = 2, teamTree = class}
            -- local skillIcon = skillbg:getChildByName("skillIcon" .. tree .. class)
            local skillIcon = skillbg:getChildByName("skillIcon")
            if not skillIcon then
                skillIcon = self:createSkillIcon(param)
                skillIcon:setName("skillIcon")
                skillIcon:setAnchorPoint(0.5, 0.5)
                skillIcon:setScale(1.1)
                skillIcon:setPosition(skillbg:getContentSize().width*0.5, skillbg:getContentSize().height*0.5)
                skillbg:addChild(skillIcon, 5)
            else
                self:updateTeamSkillIconByView(skillIcon, param)
            end

            -- 连接线
            local liudongxian = skillbg:getChildByFullName("liudongxian")
            if not liudongxian then
                liudongxian = mcMgr:createViewMC("liudongxian_tianfushu", true, false)
                liudongxian:setHue(awakingColor.hue)
                liudongxian:setSaturation(awakingColor.saturation)
                liudongxian:setBrightness(awakingColor.brightness)
                liudongxian:setContrast(awakingColor.contrast)
                liudongxian:setName("liudongxian")
                liudongxian:setPosition(skillbg:getContentSize().width*0.5+90, skillbg:getContentSize().height*0.5+50)
                skillbg:addChild(liudongxian,1)       
                if class == 2 then
                    liudongxian:setScaleX(-1)
                    liudongxian:setRotation(5)
                    if tree == 1 then
                        liudongxian:setPosition(skillbg:getContentSize().width*0.5-90, skillbg:getContentSize().height*0.5+60)
                    elseif tree == 2 then
                        liudongxian:setPosition(skillbg:getContentSize().width*0.5-90, skillbg:getContentSize().height*0.5+50)
                    elseif tree == 3 then
                        liudongxian:setPosition(skillbg:getContentSize().width*0.5-90, skillbg:getContentSize().height*0.5+50)
                    end
                else
                    liudongxian:setRotation(-5)
                    if tree == 1 then
                        liudongxian:setPosition(skillbg:getContentSize().width*0.5+90, skillbg:getContentSize().height*0.5+60)
                    elseif tree == 2 then
                        liudongxian:setPosition(skillbg:getContentSize().width*0.5+90, skillbg:getContentSize().height*0.5+50)
                    elseif tree == 3 then
                        liudongxian:setPosition(skillbg:getContentSize().width*0.5+90, skillbg:getContentSize().height*0.5+50)
                    end
                end
            end

            print("branchData=======", tree, branchData["b" .. tree], class)
            if branchData and branchData["b" .. tree] ~= 0 then
                if branchData["b" .. tree] == class then
                    skillIcon:setSaturation(0)
                    liudongxian:setVisible(true)
                else
                    skillIcon:setSaturation(-100)
                    liudongxian:setVisible(false)
                end
            else
                skillIcon:setSaturation(-100)
                liudongxian:setVisible(false)
            end

            self:registerClickEvent(skillIcon, function()
                self:selectClick(false)
                self._selectSkill = tree*10+class
                self:selectClick(true)
                self:updateRightData()
            end)
        end

        local skillBtnLineBg = self:getUI("bg.leftLayer.skillBtnLineBg" .. tree)
        -- 上下连接线
        local skillBtnLine = skillBtnLineBg:getChildByFullName("skillBtnLine")
        if not skillBtnLine then
            skillBtnLine = mcMgr:createViewMC("liudongxian1_tianfushu", true, false)
            skillBtnLine:setName("skillBtnLine")
            skillBtnLine:setPosition(skillBtnLineBg:getContentSize().width*0.5, skillBtnLineBg:getContentSize().height*0.5)
            skillBtnLineBg:addChild(skillBtnLine,1)    
            skillBtnLine:setHue(awakingColor.hue)
            skillBtnLine:setSaturation(awakingColor.saturation)
            skillBtnLine:setBrightness(awakingColor.brightness)
            skillBtnLine:setContrast(awakingColor.contrast)   
        end
        
        if teamStage >= awakingLimit[tree] then
            skillBtnLine:setVisible(true)
        else
            skillBtnLine:setVisible(false)
        end

        local skillLimitLab = self:getUI("bg.leftLayer.skillBtn" .. tree .. ".lab")
        local str = lang("AWAKING_BUTTON_" .. tree)
        skillLimitLab:setString(str)
        skillLimitLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end

    local starIcon = self:getUI("bg.leftLayer.starIcon")
    local backQuality = self._teamModel:getTeamQualityByStage(inTeamData.stage)
    local icon = starIcon:getChildByName("teamIcon")
    local param = {teamData = inTeamData, sysTeamData = teamTab,quality = backQuality[1] , quaAddition = backQuality[2],  eventStyle = 0}
    if icon == nil then 
        icon = IconUtils:createTeamIconById(param)
        icon:setName("teamIcon")
        icon:setPosition(116/2-15,116/2-15)
        icon:setAnchorPoint(cc.p(0.5, 0.5))
        icon:setScale(0.63)
        starIcon:addChild(icon)
    else
        IconUtils:updateTeamIconByView(starIcon, param)
    end
end

local SKILL_WIDTH, SKILL_HEIGHT = 80, 80
function TeamAwakenDialog:createSkillIcon(inTable)
    local cardbg = ccui.Layout:create()
    cardbg:setAnchorPoint(0.5, 0.5)
    cardbg:setBackGroundColorOpacity(0)
    cardbg:setBackGroundColorType(1)
    cardbg:setBackGroundColor(cc.c3b(255,255,255))
    cardbg:setContentSize(SKILL_WIDTH, SKILL_HEIGHT)
    cardbg:setName("cardbg")

    local centerx, centery = SKILL_WIDTH * 0.5, SKILL_HEIGHT * 0.5

    -- 遮罩
    -- 背景
    local mask = cc.Sprite:createWithSpriteFrameName("globalImage_IconMaskCircle.png")
    mask:setScale(0.8)
    mask:setPosition(centerx, centery)

    -- 裁剪框
    local cardClip = cc.ClippingNode:create()
    cardClip:setInverted(false)
    cardClip:setStencil(mask)
    cardClip:setAlphaThreshold(0.1)
    cardClip:setName("cardClip")
    cardClip:setAnchorPoint(cc.p(0.5,0.5))
    -- cardClip:setPosition(centerx*0.5, centery*0.5)
    cardbg:addChild(cardClip)

    local skillIcon = cc.Sprite:create()
    skillIcon:setPosition(centerx, centery)
    skillIcon:setName("skillIcon")
    cardClip:addChild(skillIcon)

    -- icon
    local iconFrame = cc.Sprite:createWithSpriteFrameName("globalImageUI_teamskillFrame1.png")
    iconFrame:setPosition(centerx, centery)
    iconFrame:setName("iconFrame")
    cardbg:addChild(iconFrame)

    self:updateTeamSkillIconByView(cardbg, inTable)
    return cardbg
end

function TeamAwakenDialog:updateTeamSkillIconByView(inView, inTable)
    if not inView then
        return
    end

    local sysSkill = inTable.teamSkill
    local skillIcon = inView:getChildByFullName("cardClip.skillIcon")
    if skillIcon then
        local fileName = sysSkill.art .. ".png"
        print("fileName=============", fileName)
        skillIcon:setSpriteFrame(fileName)
    end

    local teamTree = inTable.teamTree or 1
    local iconFrame = inView:getChildByFullName("iconFrame")
    if iconFrame then
        local fileName = "globalImageUI_teamskillFrame" .. teamTree .. ".png"
        iconFrame:setSpriteFrame(fileName)
    end

    local styleType = inTable.styleType
    if styleType == 2 then
        local skillName = inView:getChildByFullName("skillName")
        local sysSkillName = lang(sysSkill.name)
        if not skillName then
            skillName = cc.Label:createWithTTF(sysSkillName, UIUtils.ttfName, 18)
            skillName:setPosition(inView:getContentSize().width*0.5, 0)
            skillName:setColor(cc.c3b(252, 244, 197))
            skillName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            skillName:setName("skillName")
            inView:addChild(skillName, 5) -- 4
        else
            skillName:setString(sysSkillName)
        end
        local skillNameBg = inView:getChildByFullName("skillNameBg")
        if not skillNameBg then
            skillNameBg = cc.Sprite:createWithSpriteFrameName("TeamAwakenImageUI_img2.png")
            skillNameBg:setPosition(inView:getContentSize().width*0.5, 0)
            skillNameBg:setName("skillNameBg")
            inView:addChild(skillNameBg)
        end
    else
        local skillName = inView:getChildByFullName("skillName")
        if skillName then
            skillName:setVisible(false)
        end
        local skillNameBg = inView:getChildByFullName("skillNameBg")
        if skillNameBg then
            skillNameBg:setVisible(false)
        end
    end
end

-- function TeamAwakenDialog:getAsyncRes()
--     return {
--         {"asset/ui/team.plist", "asset/ui/team.png"},
--         {"asset/ui/team1.plist", "asset/ui/team1.png"},
--     }
-- end

return TeamAwakenDialog
