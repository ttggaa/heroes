--[[
    Filename:    TeamSkillUpdateView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-08-13 15:47:53
    Description: File description
--]]

local TeamSkillUpdateView = class("TeamSkillUpdateView", BasePopView)

function TeamSkillUpdateView:ctor(param)
    TeamSkillUpdateView.super.ctor(self)
    self._teamData = param.teamData
    self._curSelectIndex = param.index or 1
    self._expLevel = 0
    self._tiaochu = false
end


function TeamSkillUpdateView:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
    end)

    self._teamModel = self._modelMgr:getModel("TeamModel")

    local title1 = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title1, 1, 1)
    self._scrollView = self:getUI("bg.Panel_28.scrollView")
    self._scrollView:addEventListener(function(inView,inType)
        self._touchState = 2
        self:stopAllActions()
        if self._depleteSchedule ~= nil then 
            ScheduleMgr:unregSchedule(self._depleteSchedule)
            self._depleteSchedule = nil
        end
        return true
    end)

    -- local mcMgr = MovieClipManager:getInstance()
    -- mcMgr:loadRes("teamskillanim", function ()
    self:animBegin()    
    -- end)
    local expTipLab = self:getUI("bg.Panel_10.expTipLab")
    expTipLab:setFontSize(20)
    expTipLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._tableNode = self:getUI("bg.equiptList")
    self._skillCell = self:getUI("skillCell")
    self._tableCellW, self._tableCellH = self._skillCell:getContentSize().width, self._skillCell:getContentSize().height
    self._specialSkillId = self._teamData.ss
    self:createSkillData()
    self:addTableView()
end

function TeamSkillUpdateView:createSkillData(  )
    self._skillData = {}
    local sysTeam = tab:Team(self._teamData.teamId)
    local showSort = self._teamModel:getTeamSkillShowSort(self._teamData)

    for k, v in pairs(showSort) do
        if (k ~= #showSort) or (k == #showSort and v == self._specialSkillId) then
            local skillId = sysTeam.skill[v][2]
            local skillType = sysTeam.skill[v][1]
            local skill = SkillUtils:getTeamSkillByType(skillId, skillType)
            skill = clone(skill)
            skill.sysSkillIndex = v
            skill.teji = (v == self._specialSkillId)
            table.insert(self._skillData, clone(skill))
        end
    end
end

function TeamSkillUpdateView:changeSpecialSkill(  )
    if not self._specialSkillId then return end
    local changeSkillId = 5 + 6 - self._specialSkillId
    self._serverMgr:sendMsg("TeamServer", "switchSpecialSkill", {ssId = changeSkillId, teamId = self._teamData.teamId}, true, {}, function ( result )
        self._teamData = self._teamModel:getTeamAndIndexById(self._teamData.teamId)
        local oldTableViewH = self._tableView:getContentOffset()
        self._specialSkillId = self._teamData.ss
        self:createSkillData()
        self._tableView:reloadData()
        self._tableView:setContentOffset(oldTableViewH, false)
        self:updateEquipUI(self._curSelectIndex, true)
        --头像特效
        local panel39 = self:getUI("bg.Image_9.Panel_39")
        local mc2 = mcMgr:createViewMC("zhuangbeiqianghuatexiao_teamupgrade", false, true, function()
        end)
        mc2:setScale(1.2)
        mc2:setPosition(panel39:getContentSize().width*0.5, panel39:getContentSize().height*0.5)
        panel39:addChild(mc2, 7)
    end)
end

function TeamSkillUpdateView:addTableView(  )
    local tableView = cc.TableView:create(cc.size(self._tableNode:getContentSize().width, self._tableNode:getContentSize().height))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    tableView:setName("tableView")
    self._tableNode:addChild(tableView)

    tableView:registerScriptHandler(function( table,index )
        return self:cellSizeForTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)

    tableView:registerScriptHandler(function ( table,index )
        return self:tableCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)

    tableView:registerScriptHandler(function ( table )
        return self:numberOfCellsInTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

    tableView:reloadData()
    self._tableView = tableView

    if self._curSelectIndex >= 5 then  --5个会超
        if self._curSelectIndex == #self._skillData then   --最后一个
            self._tableView:setContentOffset(cc.p(0, 0))
        else
            local offsetY = (#self._skillData - self._curSelectIndex - 0.5) * self._tableCellH
            self._tableView:setContentOffset(cc.p(0, -offsetY))
        end
    end
end

function TeamSkillUpdateView:cellSizeForTable(table,idx) 
    return self._tableCellH, self._tableCellW
end

function TeamSkillUpdateView:numberOfCellsInTableView(table)
   return #self._skillData
end

function TeamSkillUpdateView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    end

    local skillItem = cell:getChildByFullName("skillItem")
    if tolua.isnull(skillItem) then
        skillItem = self._skillCell:clone()
        skillItem:setPosition(0, 0)
        skillItem:setCascadeOpacityEnabled(true, true)
        skillItem:setSwallowTouches(false)
        skillItem:setName("skillItem")
        skillItem:setVisible(true)
        cell:addChild(skillItem, 1)
    end

    self:updateCellInfo(cell, idx)
    return cell
end

function TeamSkillUpdateView:updateCellInfo( cell, idx )
    local skillItem = cell:getChildByFullName("skillItem.skill")
    local skillData = self._skillData[idx + 1]
    local sysSkillIndex = skillData.sysSkillIndex

    local dazhao = skillItem:getChildByFullName("dazhao")
    if skillData.dazhao then
        dazhao:loadTexture("label_big_skill_hero.png", 1)
        dazhao:setVisible(true)
    elseif skillData.teji then
        dazhao:loadTexture("teamImageUI_updateRed2.png", 1)
        dazhao:setVisible(true)
    else
        dazhao:setVisible(false)
    end

    local skillIcon = skillItem:getChildByFullName("skillIcon")
    local param = {teamSkill = skillData, eventStyle = 0, level = self._teamData["sl" .. sysSkillIndex], levelLab = false, teamData = self._teamData}
    if skillIcon then
        IconUtils:updateTeamSkillIconByView(skillIcon, param)
    else
        skillIcon = IconUtils:createTeamSkillIconById(param)
        skillIcon:setPosition(cc.p(skillItem:getContentSize().width * 0.5, skillItem:getContentSize().height * 0.5))
        skillIcon:setAnchorPoint(cc.p(0.5,0.5))
        skillIcon:setName("skillIcon")
        skillItem:addChild(skillIcon)
    end

    local skillLvl = skillItem:getChildByFullName("skillLvl")
    if skillLvl then
        skillLvl:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end
    local suo = skillItem:getChildByFullName("suo")
    if self._teamData["sl" .. sysSkillIndex] <= 0 then
        if suo then
            suo:setVisible(true)
        end
        if skillLvl then
            skillLvl:setVisible(false)
        end
    else
        if suo then
            suo:setVisible(false)
        end
        if skillLvl then
            skillLvl:setVisible(true)

            local addLevel = 0      -- 额外增加等级
            local rune = self._teamData.rune
            if rune and rune.suit and rune.suit["4"] then
                local id, level = TeamUtils:getRuneIdAndLv(rune.suit["4"])
                if id == 104 then
                    addLevel = level
                end
                if (idx + 1) == 1 then
                    if id == 403 then
                        addLevel = level 
                    end
                end
            end
            local sysTeamStarData = tab:Star(self._teamData.star)
            local maxLevel = sysTeamStarData.skilllevel
            skillLvl:setString("Lv." .. (self._teamData["sl" .. sysSkillIndex] + addLevel) .. "/" .. (maxLevel + addLevel))
            skillLvl.addLevel = addLevel
        end
    end

    local selectRune = skillItem:getChildByFullName("selectRune")
    selectRune:setVisible(false)

    local xuanzhong = skillItem:getChildByFullName("xuanzhong")
    if xuanzhong == nil then
        xuanzhong = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
        xuanzhong:setName("xuanzhong")
        xuanzhong:gotoAndStop(1)
        xuanzhong:setPosition(skillItem:getContentSize().width * 0.5, skillItem:getContentSize().height * 0.5 + 1)
        xuanzhong:setScale(0.85)
        xuanzhong:setVisible(false)
        skillItem:addChild(xuanzhong,0)
    end
    if self._curSelectIndex == (idx + 1) then
        if xuanzhong then
            xuanzhong:setVisible(true)
        end
    else
        if xuanzhong then
            xuanzhong:setVisible(false)
        end
    end

    self:registerClickEvent(skillItem, function()
        self:updateEquipUI(idx + 1)
    end)

    skillItem:setSwallowTouches(false)
end

function TeamSkillUpdateView:updateEquipUI(equipId, force)
    if self._curSelectIndex ~= equipId or force then
        local skillData = self._skillData[equipId]
        local sysSkillIndex = skillData.sysSkillIndex
        if self._teamData["sl" .. sysSkillIndex] > 0 or skillData.teji then
            self._curSelectIndex = equipId
            local tempTeamData, tempTeamIndex = self._teamModel:getTeamAndIndexById(self._teamData.teamId)
            local tempData = {}
            tempData.teamData = tempTeamData
            tempData.index = self._curSelectIndex
            self._touchState = 0

            self._depleteItems = {}
            self._tempLevel = 0
            self._expLevel = 0
            self._tempExp = 0
            -- local blueExpProg = self:getUI("bg.Panel_10.blueExpProg")
            -- blueExpProg:setPercent(0)
            self:updateLeftSkillList()

            self:updateSkillView()
        else
            self._viewMgr:showTip("该技能暂未解锁")
        end

        -- local backQuality = self._teamModel:getTeamQualityByStage(self._teamData["es" .. equipId])
        -- local param = {teamData = self._teamData, index = equipId, sysRuneData = sysEquip,isUpdate = -2, quality = backQuality[1], quaAddition = backQuality[2], eventStyle = 0}
        -- local equip = self:getUI("bg.equiptList.equip" .. equipId)
        -- local iconRune = equip:getChildByFullName("runeIcon")
        -- if iconRune == nil then 
        --     iconRune = IconUtils:createTeamRuneIconById(param)
        --     iconRune:setName("runeIcon")
        --     iconRune:setScale(0.9)
        --     iconRune:setAnchorPoint(cc.p(0, 0))
        --     iconRune:setPosition(cc.p(30,30))
        --     equip:addChild(iconRune)
        -- else 
        --     IconUtils:updateTeamRuneIconByView(iconRune, param)
        -- end
    end
end

function TeamSkillUpdateView:updateLeftSkillList()
    -- self._tableView:reloadData()
    for i = 1, #self._skillData do
        repeat
            local skillItem = self._tableView:cellAtIndex(i - 1)
            if not skillItem then
                break
            end
            
            local xuanzhong = skillItem:getChildByFullName("skillItem.skill.xuanzhong")
            if self._curSelectIndex == i  then
                if xuanzhong then
                    xuanzhong:setVisible(true)
                end
            else
                if xuanzhong then
                    xuanzhong:setVisible(false)
                end
            end

            local addLevel = 0      -- 额外增加等级
            local rune = self._teamData.rune
            if rune and rune.suit and rune.suit["4"] then
                local id,level = TeamUtils:getRuneIdAndLv(rune.suit["4"])
                if id == 104 then
                    addLevel = level
                end
                if i == 1 then
                    if id == 403 then
                        addLevel = level 
                    end
                end
            end
            local skillItem = self._tableView:cellAtIndex(i - 1)
            local skillLvl = skillItem:getChildByFullName("skillItem.skill.skillLvl")
            if skillLvl then
                local skillData = self._skillData[i]
                local sysSkillIndex = skillData.sysSkillIndex
                local sysTeamStarData = tab:Star(self._teamData.star)
                local maxLevel = sysTeamStarData.skilllevel
                skillLvl:setString("Lv." .. (self._teamData["sl" .. sysSkillIndex] + addLevel) .. "/" .. (maxLevel + addLevel))
                skillLvl.addLevel = addLevel
            end
        until true
    end
end

function TeamSkillUpdateView:reflashSkillUI()
    local tempTeamData,tempTeamIndex = self._teamModel:getTeamAndIndexById(self._teamData.teamId)
    local tempData = {}
    tempData.teamData = tempTeamData
    tempData.index = self._curSelectIndex
    self._touchState = 0
    self._depleteItems = {}
    self._tempLevel = 0
    self._tempExp = 0
    self._expLevel = 0
    self:reflashUI(tempData)
end

function TeamSkillUpdateView:reflashUI(inData)
    self._teamData = inData.teamData
    self._curSelectIndex = inData.index

    self._touchState = 0
    self._depleteItems = {}
    self._tempLevel = 0
    self._tempExp = 0
    self._expLevel = 0
    self:updateLeftSkillList()
    self:switchSkill()
end


function TeamSkillUpdateView:switchSkill()
    local itemModel = self._modelMgr:getModel("ItemModel")
    self._itemMaterials = itemModel:getItemsByType(ItemUtils.ITEM_TYPE_MATERIAL)
    
    local sysTeam = tab:Team(self._teamData.teamId)
    
    self._scrollView:removeAllChildren()

    local skillItem = self._tableView:cellAtIndex(self._curSelectIndex - 1)
    local skillLvl = skillItem:getChildByFullName("skillItem.skill.skillLvl")
    local addLevel = skillLvl.addLevel

    local skillData = self._skillData[self._curSelectIndex]
    local sysSkillIndex = skillData.sysSkillIndex
    local skillLevel = self._teamData["sl" .. sysSkillIndex]
    local skillId = sysTeam.skill[sysSkillIndex][2]
    local skillType = sysTeam.skill[sysSkillIndex][1]

    self._sysSkill = SkillUtils:getTeamSkillByType(skillId, skillType)

    if self._sysSkill ~= nil then 
        -- 技能图标
        local panel39 = self:getUI("bg.Image_9.Panel_39")
        local skillIcon = panel39:getChildByName("skillIcon")

        local param = {teamSkill = self._sysSkill, eventStyle = 0, teamData = self._teamData}
        if skillIcon then
            IconUtils:updateTeamSkillIconByView(skillIcon, param)
        else
            skillIcon = IconUtils:createTeamSkillIconById(param)
            skillIcon:setPosition(cc.p(panel39:getContentSize().width*0.5,panel39:getContentSize().height*0.5))
            skillIcon:setAnchorPoint(cc.p(0.5,0.5))
            skillIcon:setScale(1.1)
            skillIcon:setName("skillIcon")
            panel39:addChild(skillIcon)
        end

        local panel323 = self:getUI("bg.Image_9.Panel_323")
        -- local descLab = panel323:getChildByName("descLab")
        -- if descLab ~= nil then
        --     descLab:removeFromParent()
        -- end
        local originWidth,originHeight = panel323:getContentSize().width,panel323:getContentSize().height
        print("originWidth:" .. originWidth)
        -- 技能描述
        local richText = panel323:getChildByName("richText")
        if richText ~= nil then
            richText:removeFromParent()
        end
        local desc = SkillUtils:handleSkillDesc1(lang(self._sysSkill.des), self._teamData, (skillLevel+addLevel) ,self._tempLevel)
        if string.find(desc, "color=") == nil then
            desc = "[color=fae6c8]"..desc.."[-]"
        end   
        print("desc ================", self._sysSkill.des)
        desc = string.gsub(desc, "fae6c8", "462800")
        richText = RichTextFactory:create(desc, originWidth-30, panel323:getContentSize().height)
        richText:formatText()
        richText:enablePrinter(true)
        local rtRealHeight = richText:getRealSize().height
        richText:setPosition(originWidth*0.5 - 15,  rtRealHeight*0.5)
        richText:setName("richText")
        UIUtils:alignRichText(richText)
        panel323:addChild(richText)
        local realHeight = math.max(originHeight,rtRealHeight)
        panel323:setInnerContainerSize(cc.size(originWidth,rtRealHeight))
        panel323:setTouchEnabled(rtRealHeight > originHeight)
        panel323:getInnerContainer():setPositionY(originHeight - rtRealHeight)
        ScheduleMgr:nextFrameCall(self, function()
            panel323:getInnerContainer():setPositionY(originHeight - rtRealHeight)
        end)
    end 

    self._nameLab = self:getUI("bg.Image_9.nameLab")
    self._nameLab:setColor(cc.c3b(60,42,30))
    self._nameLab:setString(lang(self._sysSkill.name))
    local btn_change = self:getUI("bg.Image_9.btn_change")
    if skillData.teji then
        btn_change:setVisible(true)
    else
        btn_change:setVisible(false)
    end
    self:registerClickEvent(btn_change, function ()
        self:changeSpecialSkill()
    end)

    self._levelLab1 = self:getUI("bg.Image_9.levelLab1")
    local addLvStr = ""
    if addLevel > 0 then
        addLvStr = string.format(" (+%s)",addLevel)
    end
    self._levelLab1:setString( "Lv." .. skillLevel..addLvStr)
    self._levelLab1:disableEffect()
    self._levelLab1:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local image44 = self:getUI("bg.Image_9.Image_44")
    image44:setVisible(false)
    image44:setPositionX(self._levelLab1:getPositionX()+self._levelLab1:getContentSize().width+30)

    self._levelLab2 = self:getUI("bg.Image_9.levelLab2")
    self._levelLab2:setString("Lv." .. skillLevel..addLvStr)
    self._levelLab2:setVisible(false)
    self._levelLab2:setPositionX(image44:getPositionX()+image44:getContentSize().width+5)
    self._levelLab2:disableEffect()
    self._levelLab2:setColor(UIUtils.colorTable.ccUIBaseColor9)

    local sysLevelSkillData = tab:LevelSkill(skillLevel)
    local tmpSysLevelSkillData = tab:LevelSkill(skillLevel + 1)
    local needExp = sysLevelSkillData.exp
    if skillData.teji then
        needExp = sysLevelSkillData.redexp
    end

    local teamSkillExp = self._teamData["se" .. sysSkillIndex]
    local blueExpProg = self:getUI("bg.Panel_10.blueExpProg")
    blueExpProg:setVisible(false)
    local expProg = self:getUI("bg.Panel_10.expProg")

    expProg:setScaleX(teamSkillExp / needExp)
    blueExpProg:setScaleX(teamSkillExp / needExp)
    expProg:setVisible(true)

    local isActive = true
    local panel10 = self:getUI("bg.Panel_10")
    local updateBtn = self:getUI("bg.Panel_10.updateBtn")
    local maxlevel = self:getUI("bg.maxlevel")
    if skillLevel > 0 and tmpSysLevelSkillData ~= nil then 
        updateBtn:setEnabled(true)
        panel10:setVisible(true)
        maxlevel:setVisible(false)
    else
        isActive = false
        updateBtn:setEnabled(false)
        panel10:setVisible(false)
        maxlevel:setVisible(true)
    end

    -- 创建物品列表
    local x = 10
    local maxHeight = 100 * math.ceil(#self._itemMaterials / 6)
    if maxHeight < self._scrollView:getContentSize().height then 
        maxHeight = self._scrollView:getContentSize().height
    end
    -- local maxHeight = 230
    local y = maxHeight - 92
    self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width,maxHeight))
    local tempMaterial
    for i=1,#self._itemMaterials do
        tempMaterial = self._itemMaterials[i]
        self:createSkillCell(tempMaterial, x, y,isActive, i)
        x = x + 102
        if i % 6 == 0 then 
            x = 10
            y = y - 100
        end
    end

    self:registerClickEvent(updateBtn, function ()
        self:upgradeSkill()
    end)

    self._tempExp = teamSkillExp
   
    local expTipLab = self:getUI("bg.Panel_10.expTipLab")
    expTipLab:setFontSize(20)
    expTipLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    expTipLab:setString(self._tempExp .. "/" ..  needExp)

    self:setMaxLevelShow()
end


function TeamSkillUpdateView:updateSkillView()
    -- 获取物品数据
    local itemModel = self._modelMgr:getModel("ItemModel")
    self._itemMaterials = itemModel:getItemsByType(ItemUtils.ITEM_TYPE_MATERIAL)
    
    local sysTeam = tab:Team(self._teamData.teamId)
    
    local skillItem = self._tableView:cellAtIndex(self._curSelectIndex - 1)
    local skillLvl = skillItem:getChildByFullName("skillItem.skill.skillLvl")
    local addLevel = skillLvl.addLevel

    local skillData = self._skillData[self._curSelectIndex]
    local sysSkillIndex = skillData.sysSkillIndex
    local skillLevel = self._teamData["sl" .. sysSkillIndex]
    local skillId = sysTeam.skill[sysSkillIndex][2]
    local skillType = sysTeam.skill[sysSkillIndex][1]
    self._sysSkill = SkillUtils:getTeamSkillByType(skillId, skillType)

    -- 更新技能描述
    if self._sysSkill ~= nil then 
        local panel39 = self:getUI("bg.Image_9.Panel_39")
        local skillIcon = panel39:getChildByName("skillIcon")
        
        local param = {teamSkill = self._sysSkill ,eventStyle = 0, teamData = self._teamData}
        if skillIcon then
            IconUtils:updateTeamSkillIconByView(skillIcon, param)
        else
            skillIcon = IconUtils:createTeamSkillIconById(param)
            skillIcon:setPosition(cc.p(panel39:getContentSize().width*0.5,panel39:getContentSize().height*0.5))
            skillIcon:setAnchorPoint(cc.p(0.5,0.5))
            skillIcon:setScale(1.1)
            skillIcon:setName("skillIcon")
            panel39:addChild(skillIcon)
        end
        
        local panel323 = self:getUI("bg.Image_9.Panel_323")
        local richText = panel323:getChildByName("richText")
        if richText ~= nil then
            richText:removeFromParent()
        end
        local desc = SkillUtils:handleSkillDesc1(lang(self._sysSkill.des), self._teamData, skillLevel+addLevel ,self._tempLevel)
        if string.find(desc, "color=") == nil then
            desc = "[color=000000]"..desc.."[-]"
        end   
        desc = string.gsub(desc, "fae6c8", "000000")
        -- richText = RichTextFactory:create(desc, panel323:getContentSize().width - 10, panel323:getContentSize().height)
        -- richText:formatText()
        -- richText:enablePrinter(true)
        -- richText:setPosition(panel323:getContentSize().width*0.5 - 5, panel323:getContentSize().height - richText:getInnerSize().height*0.5)
        -- richText:setName("richText")
        -- panel323:addChild(richText)
        local originWidth,originHeight = panel323:getContentSize().width,panel323:getContentSize().height
        richText = RichTextFactory:create(desc, panel323:getContentSize().width-30, panel323:getContentSize().height)
        richText:formatText()
        richText:enablePrinter(true)
        local rtRealHeight = richText:getRealSize().height
        richText:setPosition(originWidth*0.5 - 15,  rtRealHeight*0.5)
        richText:setName("richText")
        UIUtils:alignRichText(richText)
        panel323:addChild(richText)
        local realHeight = math.max(originHeight,rtRealHeight)
        panel323:setInnerContainerSize(cc.size(originWidth,rtRealHeight))
        panel323:setTouchEnabled(rtRealHeight > originHeight)
        panel323:getInnerContainer():setPositionY(originHeight - rtRealHeight)

    end 

    self._nameLab = self:getUI("bg.Image_9.nameLab")
    self._nameLab:setString(lang(self._sysSkill.name))
    self._nameLab:disableEffect()
    local btn_change = self:getUI("bg.Image_9.btn_change")
    if skillData.teji then
        btn_change:setVisible(true)
    else
        btn_change:setVisible(false)
    end
    self:registerClickEvent(btn_change, function ()
        self:changeSpecialSkill()
    end)

    local addLvStr = ""
    if addLevel > 0 then
        addLvStr = string.format(" (+%s)",addLevel)
    end

    self._levelLab1 = self:getUI("bg.Image_9.levelLab1")
    self._levelLab1:setString( "Lv." .. skillLevel .. addLvStr)
    self._levelLab1:disableEffect()
    self._levelLab1:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local image44 = self:getUI("bg.Image_9.Image_44")
    image44:setVisible(false)
    image44:setPositionX(self._levelLab1:getPositionX()+self._levelLab1:getContentSize().width+30)

    self._levelLab2 = self:getUI("bg.Image_9.levelLab2")
    self._levelLab2:setString("Lv." .. skillLevel .. addLvStr)
    self._levelLab2:setVisible(false)
    self._levelLab2:setPositionX(image44:getPositionX()+image44:getContentSize().width+5)

    local sysLevelSkillData = tab:LevelSkill(skillLevel)
    local tmpSysLevelSkillData = tab:LevelSkill(skillLevel + 1)

    local needExp = sysLevelSkillData.exp
    if skillData.teji then
        needExp = sysLevelSkillData.redexp
    end

    local teamSkillExp = self._teamData["se" .. sysSkillIndex]
    local blueExpProg = self:getUI("bg.Panel_10.blueExpProg")
    blueExpProg:setVisible(false)
    local expProg = self:getUI("bg.Panel_10.expProg")

    expProg:setScaleX(teamSkillExp / needExp)
    blueExpProg:setScaleX(teamSkillExp / needExp)
    expProg:setVisible(true)

    local isActive = true
    local panel10 = self:getUI("bg.Panel_10")
    local maxlevel = self:getUI("bg.maxlevel")
    local updateBtn = self:getUI("bg.Panel_10.updateBtn")
    -- local anim1 = updateBtn:getChildByName("anim1")
    if skillLevel > 0 and tmpSysLevelSkillData ~= nil then 
        updateBtn:setEnabled(true)
        panel10:setVisible(true)
        maxlevel:setVisible(false)
    else
        isActive = false
        updateBtn:setEnabled(false)
        panel10:setVisible(false)
        maxlevel:setVisible(true)
    end

-- 创建物品列表
    local tempMaterial
    for i=1,#self._itemMaterials do
        tempMaterial = self._itemMaterials[i]
        local itembg = self._scrollView:getChildByName("itemSkillBg" .. i)
        self:updateSkillCell(itembg, tempMaterial, isActive)
    end

    self._tempExp = teamSkillExp
   
    local expTipLab = self:getUI("bg.Panel_10.expTipLab")
    expTipLab:setString(self._tempExp .. "/" ..  needExp)

    self:registerClickEvent(updateBtn, function ()
        self:upgradeSkill()
    end)

    local anim1 = updateBtn:getChildByName("anim1")
    if anim1 ~= nil then
        anim1:setVisible(false)
    end

    self:setMaxLevelShow()
end 

function TeamSkillUpdateView:updateSkillCell(inView, inMaterial, inIsActive)
    if not inView then
        return
    end

    local subItemCountBtn = inView:getChildByName("subItemCountBtn")
    if subItemCountBtn then
        subItemCountBtn:setVisible(false)
    end

    local itemIcon = inView:getChildByName("itemIcon")

    local itemCount = itemIcon:getChildByName("itemCount")
    local tempMaterial = inMaterial
    local showMaxNum = tempMaterial.num
    if showMaxNum > 999 then 
        showMaxNum = "999+"
    end
    if itemCount then
        itemCount:setString(showMaxNum)
    end

    if itemIcon then
        IconUtils:setIeamIconBlack(itemIcon, false)
        local subItemBtn = subItemCountBtn
        if subItemBtn then
            self:registerTouchEvent(itemIcon, 
                function(_, x, y)
                    -- local subItemBtnPointX,subItemBtnPointY = subItemBtn:getPosition()
                    -- local touchPoint = subItemBtn:convertToNodeSpace(cc.p(x, y))
                    -- if touchPoint.x > 0 and touchPoint.y > 0 
                    --     and touchPoint.x < subItemBtn:getContentSize().width 
                    --     and touchPoint.y < subItemBtn:getContentSize().height then 
                    --     return false
                    -- end 

                    if inIsActive == false then
                        self._viewMgr:showTip(lang("TIPS_BINGTUAN_10"))
                        return false
                    end 

                    self:touchItem(itemIcon, tempMaterial, subItemBtn)
                end, 
                nil, 
                function(_, x, y)
                    if inIsActive == false then
                        self:shifangdingshi()
                        return
                    end 
                    self:touchItemEnd(itemIcon, tempMaterial, subItemBtn)
                end,        
                function(_, x, y)
                    if inIsActive == false then
                        self:shifangdingshi()
                        return
                    end 
                    self:touchItemEnd(itemIcon, tempMaterial, subItemBtn)
                end
            )


            self:registerTouchEvent(subItemBtn, 
                function(_, x, y)
                    -- local subItemBtnPointX,subItemBtnPointY = subItemBtn:getPosition()
                    -- local touchPoint = subItemBtn:convertToNodeSpace(cc.p(x, y))
                    -- if touchPoint.x > 0 and touchPoint.y > 0 
                    --     and touchPoint.x < subItemBtn:getContentSize().width 
                    --     and touchPoint.y < subItemBtn:getContentSize().height then 
                    --     return false
                    -- end 
                    if subItemBtn:isVisible() == true then
                        -- self:clickSubItemCount(itemIcon, tempMaterial)
                        self:subItem(itemIcon, tempMaterial, subItemBtn)
                    end 
                end, 
                nil, 
                function(_, x, y)
                    if subItemBtn:isVisible() == true then
                        self:subItemEnd(itemIcon, tempMaterial, subItemBtn)                
                    end 
                end,        
                function(_, x, y)
                    if subItemBtn:isVisible() == true then
                        self:subItemEnd(itemIcon, tempMaterial, subItemBtn)
                    end 
                end
            )
        end
    end
end 


--[[
--! @function createSkillCell
--! @desc 创建道具列表的cell
--! @param index int 索引
--! @param x int 坐标x
--! @param y int 坐标y
--! @return 
--]]
function TeamSkillUpdateView:createSkillCell(inMaterial, x, y,inIsActive, index)
    local itemBg = ccui.Widget:create()
    itemBg:setName("itemSkillBg" .. index)
    itemBg:setAnchorPoint(cc.p(0,0))
    itemBg:setPosition(cc.p(x, y))
    itemBg:setContentSize(cc.size(90, 90))
    itemBg:setScale(0.95)
    self._scrollView:addChild(itemBg)

    local tempMaterial = inMaterial

    -- local bgNode = ccui.Widget:create()
    -- bgNode:setAnchorPoint(cc.p(0,0))
    -- bgNode:setContentSize(cc.size(80, 80))
    local sysItem = tab:Tool(inMaterial.goodsId)
    local itemIcon = IconUtils:createItemIconById({itemId = tempMaterial.goodsId,itemData = sysItem,eventStyle = 0})
    itemIcon:setPosition(cc.p(x,y))
    itemIcon:setName("itemIcon")
    itemIcon:setPosition(cc.p(0,0))
    itemBg:addChild(itemIcon)

    -- 数量
    local numLab = ccui.Text:create()
    numLab:setString(inNum)
    numLab:setName("itemCount")
    numLab:setFontSize(20)
    numLab:setAnchorPoint(cc.p(1, 0))
    numLab:setPosition(cc.p(itemIcon:getContentSize().width-11, 6))
    numLab:setFontName(UIUtils.ttfName)
    numLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
    numLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local showMaxNum = tempMaterial.num
    if tempMaterial.num > 999 then 
        showMaxNum = "999+"
        -- numLab:setFontSize(20)
    end
    numLab:setString(showMaxNum)
    -- numLab:setColor(UIUtils.colorTable.ccColor1)
    -- numLab:enableShadow(UIUtils.colorTable.ccItemNumShadowValue)
    itemIcon:addChild(numLab,10)
    -- itemIcon:setScale(0.9)

    -- local subItemBtn = ccui.Button:create()
    local subItemBtn = ccui.ImageView:create()

    -- local iconColorLayout = ccui.LayoutComponent:bindLayoutComponent(subItemBtn)
    -- iconColorLayout:setHorizontalEdge(ccui.LayoutComponent.HorizontalEdge.Left)
    -- iconColorLayout:setVerticalEdge(ccui.LayoutComponent.VerticalEdge.Top)
    -- iconColorLayout:setStretchWidthEnabled(false)
    -- iconColorLayout:setStretchHeightEnabled(false)
    -- -- iconColorLayout:setSize(subItemBtn:getContentSize())
    -- iconColorLayout:setLeftMargin(0)
    -- iconColorLayout:setTopMargin(0)
    
    -- iconColorLayout:addChild(itemIcon)
    -- self._scrollView:addChild(iconColorLayout)

--商品上的按钮
    subItemBtn:loadTexture("globalBtnUI_bigSubBtn_n.png",1)
    -- subItemBtn:setScale(0.9)
    subItemBtn:setAnchorPoint(cc.p(1, 1))
    subItemBtn:setName("subItemCountBtn")
    -- subItemBtn:setPosition(cc.p(itemIcon:getContentSize().width, itemIcon:getContentSize().height))
    -- subItemBtn:setPosition(cc.p(x+95, y+95))
    subItemBtn:setPosition(95, 95)
    subItemBtn:ignoreContentAdaptWithSize(false)
    subItemBtn:setVisible(false)
    -- itemIcon:addChild(subItemBtn,20)
    itemBg:addChild(subItemBtn,20)
    -- self:registerClickEvent(subItemBtn, function ()
    -- self:clickSubItemCount(itemIcon, tempMaterial)
 --        return true
    -- end)
    self:registerTouchEvent(subItemBtn, 
        function(_, x, y)
            -- local subItemBtnPointX,subItemBtnPointY = subItemBtn:getPosition()
            -- local touchPoint = subItemBtn:convertToNodeSpace(cc.p(x, y))
            -- if touchPoint.x > 0 and touchPoint.y > 0 
            --     and touchPoint.x < subItemBtn:getContentSize().width 
            --     and touchPoint.y < subItemBtn:getContentSize().height then 
            --     return false
            -- end 
            if subItemBtn:isVisible() == true then
                -- self:clickSubItemCount(itemIcon, tempMaterial)
                self:subItem(itemIcon, tempMaterial, subItemBtn)
            end 
        end, 
        nil, 
        function(_, x, y)
            if subItemBtn:isVisible() == true then
                self:subItemEnd(itemIcon, tempMaterial, subItemBtn)                
            end 
        end,        
        function(_, x, y)
            if subItemBtn:isVisible() == true then
                self:subItemEnd(itemIcon, tempMaterial, subItemBtn)
            end 
        end
    )
    
    
    -- local tempSch = scheduler.unscheduleGlobal(handle)
    local downX,downY
    self:registerTouchEvent(itemIcon, 
        function(_, x, y)
            -- local subItemBtnPointX,subItemBtnPointY = subItemBtn:getPosition()
            -- local touchPoint = subItemBtn:convertToNodeSpace(cc.p(x, y))
            -- if touchPoint.x > 0 and touchPoint.y > 0 
            --     and touchPoint.x < subItemBtn:getContentSize().width 
            --     and touchPoint.y < subItemBtn:getContentSize().height then 
            --     return false
            -- end 

            if inIsActive == false then
                self._viewMgr:showTip(lang("TIPS_BINGTUAN_10"))
                return false
            end 

            self:touchItem(itemIcon, tempMaterial, subItemBtn)
        end, 
        nil, 
        function(_, x, y)
            if inIsActive == false then
                self:shifangdingshi()
                return
            end 
            -- self:unlock()
            self:touchItemEnd(itemIcon, tempMaterial, subItemBtn)
        end,        
        function(_, x, y)
            if inIsActive == false then
                self:shifangdingshi()
                return
            end 
            -- self:unlock()
            self:touchItemEnd(itemIcon, tempMaterial, subItemBtn)
        end
    )

    -- local tempScrollItem = self._scrollItem:clone()
    -- tempScrollItem:setPosition(cc.p(x,y))
    -- tempScrollItem:setVisible(true)

    -- local itemIcon = tempScrollItem:getChildByFullName("itemIcon")
    -- itemIcon:loadTexture(IconUtils:getItemIconById(tempMaterial.goodsId),1)
    -- local itemCount = tempScrollItem:getChildByFullName("itemCount")
    -- itemCount:setString(tempMaterial.num)


    -- local subItemCountBtn = tempScrollItem:getChildByFullName("subItemCountBtn")
    -- subItemCountBtn:setVisible(false)

    -- self:registerClickEvent(subItemCountBtn, function ()
    --  self:clickSubItemCount(tempScrollItem, tempMaterial)
    -- end)

    -- self:registerTouchEvent(itemIcon, 
    --  function(x, y)
    --      self:touchItem(tempScrollItem, tempMaterial)
    --  end, 
    --  nil, 
    --  function(x, y)
    --      self:touchItemEnd(tempScrollItem, tempMaterial)
    --  end,nil
    -- )

    -- self._scrollView:addChild(tempScrollItem) 
    -- itemBg:setName("itemBg" .. inMaterial.goodsId)
    return 
end

-- 物品框特效
function TeamSkillUpdateView:setAnim(inView)
    -- self:lock()
    local mc2 = mcMgr:createViewMC("wupinguang_teamupgrade", true, false, function (_, sender)
        sender:gotoAndPlay(0)
        sender:removeFromParent()
    end)
    mc2:setName("anim2")
    mc2:setScale(1.2)
    mc2:setPosition(48, 45)
    inView:addChild(mc2, 2)

-- 物品移动
    local bg = self:getUI("bg")  
    local mc3 = inView:clone()
    
    mc3:setTouchEnabled(false)
    mc3:setAnchorPoint(cc.p(0.5, 0.5))
    mc3:setScale(0.5)
    mc3:setCascadeOpacityEnabled(true)
    bg:addChild(mc3, 10)
    local itemCount = mc3:getChildByFullName("itemCount")
    if itemCount then
        itemCount:removeFromParent()
    end

    local expProg = self:getUI("bg.Panel_10.soulProgBg")
    local expProgWorldPoint = expProg:convertToWorldSpace(cc.p(233, 13))
    local mcPos = bg:convertToNodeSpace(cc.p(expProgWorldPoint.x,expProgWorldPoint.y))

    local itemWorldPoint = inView:convertToWorldSpace(cc.p(50, 50))
    local pos1 = bg:convertToNodeSpace(cc.p(itemWorldPoint.x,itemWorldPoint.y))
    mc3:setPosition(cc.p(pos1.x,pos1.y))

    moveSp = cc.MoveTo:create(0.15, cc.p(mcPos.x,mcPos.y)) 

    local seq = cc.Sequence:create(cc.Spawn:create(moveSp,cc.FadeTo:create(0.5, 100)), cc.RemoveSelf:create(true))
    mc3:runAction(seq)



--     local bg = self:getUI("bg")  
--     local itemBg = self:getUI("bg.Panel_28")
--     local mc3 = mcMgr:createViewMC("feixingguang_teamskillanim", true, false, function (_, sender)
--         -- sender:gotoAndPlay(0)
--         sender:removeFromParent()
--         -- self:unlock()
--         local expProg = self:getUI("bg.Panel_10.soulProgBg")
--         local expProgWorldPoint = expProg:convertToWorldSpace(cc.p(226, 13))
--         local mcPos = bg:convertToNodeSpace(cc.p(expProgWorldPoint.x,expProgWorldPoint.y))
--         -- local mc4 = mcMgr:createViewMC("jindutiaofankui_teamskillanim", false, true, function (_, sender)

--         -- end)
--         -- mc4:setPosition(mcPos.x + 7, mcPos.y+3)
--         -- bg:addChild(mc4, 20)

--         -- local soulProgBg = self:getUI("bg.Panel_10.soulProgBg")
--         -- local mc5 = mcMgr:createViewMC("jindutiao_teamskillanim", false, true)
--         -- mc5:setPosition(expProg:getContentSize().width*0.5 + 1, expProg:getContentSize().height*0.5 - 3)
--         -- expProg:addChild(mc5, 21)
--     end)
--     mc3:setName("anim3")
--     mc3:setPlaySpeed(1.7)

-- -- 光线移动
--     bg:addChild(mc3, 10)
--     local soulProgBg = self:getUI("bg.Panel_10.soulProgBg")
--     local itemWorldPoint = inView:convertToWorldSpace(cc.p(50, 50))
--     local pos1 = bg:convertToNodeSpace(cc.p(itemWorldPoint.x,itemWorldPoint.y))
--     local expWorldPoint = soulProgBg:convertToWorldSpace(cc.p(235, 11))
--     local pos2 = bg:convertToNodeSpace(cc.p(expWorldPoint.x,expWorldPoint.y))

--     local angle = -1 * math.deg(math.atan((pos2.x - pos1.x)/(pos2.y - pos1.y))) 
--     local pos3 = {}
--     local pos4 = {}
--     local moveSp = nil
--     if angle > 0 then --右方材料
--         angle = 90 - angle + 180
--         pos3.y = math.sin(math.rad(math.abs(angle-180))) * 150
--         pos3.x = math.sin(math.rad(90-math.abs(angle-180))) * 150
--         -- pos3.y = 0
--         -- pos3.x = 0
--         pos4.y = math.sin(math.rad(math.abs(angle))) * 150 
--         pos4.x = math.sin(math.rad(90-math.abs(angle))) * 150
--         -- mc3:setPosition(cc.p(pos1.x-pos3.x, pos1.y+pos3.y))
--         mc3:setPosition(cc.p(pos1.x-pos3.x, pos1.y+pos3.y))
--         moveSp = cc.MoveBy:create(0.2, cc.p(pos2.x - pos1.x - pos4.x, pos2.y - pos1.y + pos4.y))
--     else -- 左方材料
--         angle = -1 * (90 + angle)
--         pos3.y = math.sin(math.rad(math.abs(angle))) * 150
--         pos3.x = math.sin(math.rad(90-math.abs(angle))) * 150
--         -- pos3.y = 0
--         -- pos3.x = 0
--         pos4.y = math.sin(math.rad(math.abs(angle))) * 150
--         pos4.x = math.sin(math.rad(90-math.abs(angle))) * 150
--         mc3:setPosition(cc.p(pos1.x+pos3.x, pos1.y+pos3.y))
--         moveSp = cc.MoveBy:create(0.2, cc.p(pos2.x - pos1.x - pos4.x, pos2.y - pos1.y - pos4.y))
--     end
--     mc3:setRotation(angle)
--     mc3:runAction(moveSp)
    -- local bg = self:getUI("bg")
    -- local expProg = self:getUI("bg.Panel_10.expProg")
    -- local itemWorldPoint = inView:convertToWorldSpace(cc.p(0,0))
    -- local pos1 = bg:convertToNodeSpace(cc.p(itemWorldPoint.x,itemWorldPoint.y))
    -- local expWorldPoint = expProg:convertToWorldSpace(cc.p(0, 0))
    -- local pos2 = bg:convertToNodeSpace(cc.p(expWorldPoint.x,expWorldPoint.y))
    -- moveSp = cc.MoveTo:create(1, cc.p(pos1.x - pos2.x + 5, pos1.y - pos2.y + 5))
    -- inView:runAction(moveSp)


end

function TeamSkillUpdateView:distanceBetweenPointAndPoint(pos1, pos2)
    return math.sqrt((pos2.x - pos1.x)*(pos2.x - pos1.x)  + (pos2.y - pos1.y)*(pos2.y - pos1.y))
end

--[[
--! @function touchItemEnd
--! @desc 点击道具开始
--! @param inView object 操作材料view
--! @param inData table 操作材料数据
--! @return 
--]]
function TeamSkillUpdateView:touchItem(inView, inData, subItemBtn)
    -- self._isTouch = true
    self._touchState = 1
    self._itemAnim = true
    local delay = cc.DelayTime:create(0.5)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(function()
            numsch = 100
            self._depleteSchedule = ScheduleMgr:regSchedule(numsch, self, function()
                if numsch > 1000 then
                    ScheduleMgr:unregSchedule(self._depleteSchedule)
                    self._depleteSchedule = nil
                    self._depleteSchedule = ScheduleMgr:regSchedule(50, self, function()
                        numsch = numsch + 25
                        if math.fmod(numsch, 200) == 0 then
                            self:updateAboutExp(inView, inData, 5, true, subItemBtn)
                        else
                            self:updateAboutExp(inView, inData, 5, false, subItemBtn)
                        end
                    end)
                end
                numsch = numsch + 50
                if math.fmod(numsch, 200) == 0 then
                    self:updateAboutExp(inView, inData, 1, true, subItemBtn)
                else
                    self:updateAboutExp(inView, inData, 1, false, subItemBtn)
                end
            end)
        end))
    self:runAction(sequence)

    -- ScheduleMgr:delayCall(200, self, function()
    --     numsch = 100
    --     self._depleteSchedule = ScheduleMgr:regSchedule(numsch, self, function()
    --         if numsch > 1000 then
    --             ScheduleMgr:unregSchedule(self._depleteSchedule)
    --             self._depleteSchedule = ScheduleMgr:regSchedule(5, self, function()
    --                 numsch = numsch + 25
    --                 if math.fmod(numsch, 400) == 0 then
    --                     self:updateAboutExp(inView, inData, 1, true, subItemBtn)
    --                 else
    --                     self:updateAboutExp(inView, inData, 1, false, subItemBtn)
    --                 end
    --             end)
    --         end
    --         numsch = numsch + 50
    --         if math.fmod(numsch, 200) == 0 then
    --             self:updateAboutExp(inView, inData, 1, true, subItemBtn)
    --         else
    --             self:updateAboutExp(inView, inData, 1, false, subItemBtn)
    --         end
    --     end)
    -- end)
end


--[[
--! @function touchItemEnd
--! @desc 点击道具结束
--! @return 
--]]
function TeamSkillUpdateView:touchItemEnd(inView, inData, subItemBtn)
    -- self._isTouch = false
    self:stopAllActions()
    if self._depleteSchedule ~= nil then 
        ScheduleMgr:unregSchedule(self._depleteSchedule)
        self._depleteSchedule = nil
    else
        if self._touchState == 1 then 
            self:updateAboutExp(inView, inData, 1, true, subItemBtn)
        end
    end
    self._touchState = 0
    self._itemAnim = false
end

--[[
--! @function touchPiaoExp
--! @desc 点击道具飘字
--! @param exp 飘字经验值 
--! @param count 飘字 
--! @return 
--]]
function TeamSkillUpdateView:touchPiaoExp(exp)
    -- self._isTouch = true
    local expBar = self:getUI("bg.Panel_10.soulProgBg")
    local str = "+" .. exp
    local expLab = cc.Label:createWithTTF(str, UIUtils.ttfName, 30)
    expLab:setName("expLabLab")
    expLab:setColor(cc.c3b(250,146,26))
    -- expLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    expLab:setPosition(cc.p(expBar:getContentSize().width*0.5,0))
    expBar:addChild(expLab,10)
    expLab:setOpacity(0)
    local moveExp = cc.MoveBy:create(0.2, cc.p(0,5))
    local fadeExp = cc.FadeOut:create(0.2)
    local spawnExp = cc.Spawn:create(moveExp,fadeExp)
    local spawnExp0 = cc.Spawn:create(cc.MoveBy:create(0.1, cc.p(0,40)),cc.FadeIn:create(0.1))
    local callFunc = cc.CallFunc:create(function()
        expLab:removeFromParent()
    end)
    local seqExp = cc.Sequence:create(spawnExp0, cc.MoveBy:create(0.4, cc.p(0,20)), spawnExp,callFunc)
    expLab:runAction(seqExp)

end


function TeamSkillUpdateView:shifangdingshi()
    -- self._isTouch = false
    self:stopAllActions()
    print (" =========++++++++++++++++++++++++++点击道具结束")
    if self._depleteSchedule ~= nil then 
        ScheduleMgr:unregSchedule(self._depleteSchedule)
        self._depleteSchedule = nil
    end
    self._touchState = 0
    self._itemAnim = false
end

function TeamSkillUpdateView:setMaxLevelShow()
    local skillData = self._skillData[self._curSelectIndex]
    local sysSkillIndex = skillData.sysSkillIndex

    local skillLevel = self._teamData["sl" .. sysSkillIndex]
    local sysTeamStarData = tab:Star(self._teamData.star)
    local flag = false
    if (skillLevel + self._tempLevel) >= sysTeamStarData.skilllevel then
        flag = true
    end

    local tishi = self:getUI("bg.Panel_10.tishi")
    local maxLab = self:getUI("bg.Panel_10.maxLab")
    local expTipLab = self:getUI("bg.Panel_10.expTipLab")
    if (skillLevel + self._tempLevel) < 15 then
        tishi:setVisible(flag)
    end
    
    maxLab:setVisible(false)
    if flag == true then
        expTipLab:setString("已达当前最高级")
    end
end


--[[
--! @function subItem
--! @desc 点击取消开始
--! @param inView object 操作材料view
--! @param inData table 操作材料数据
--! @return 
--]]
function TeamSkillUpdateView:subItem(inView, inData, subItemBtn)
    -- self._isTouch = true
    self._touchState = 1
    local delay = cc.DelayTime:create(0.5)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(function()
            local numsch = 10
            self._depleteSchedule = ScheduleMgr:regSchedule(numsch, self, function()
                -- if numsch > 1000 then
                --     print("*************************")
                -- end
                -- numsch = numsch + 20
                self:updateAboutExp(inView, inData, -1, false, subItemBtn)
            end)
        end))
    self:runAction(sequence)
end

--[[
--! @function subItemEnd
--! @desc 点击取消结束
--! @return 
--]]
function TeamSkillUpdateView:subItemEnd(inView, inData, subItemBtn)
    -- self._isTouch = false
    self:stopAllActions()
    if self._depleteSchedule ~= nil then 
        ScheduleMgr:unregSchedule(self._depleteSchedule)
        self._depleteSchedule = nil
    else
        if self._touchState == 1 then 
            self:updateAboutExp(inView, inData, -1, false, subItemBtn)
        end
    end
    self._touchState = 0
end


--[[
--! @function clickSubItemCount
--! @desc 点击取消道具升级
--! @param inView object 操作材料view
--! @param inData table 操作材料数据
--! @return 
--]]
-- function TeamSkillUpdateView:clickSubItemCount(inView, inData)
--  -- self._isTouch = true
--  self:updateAboutExp(inView, inData, -1)
--  -- self._isTouch = false
-- end

--[[
--! @function updateAboutExp
--! @desc 更新经验变更影响的相关内容
--! @param inView object 操作材料view
--! @param inData table 操作材料数据
--! @param inOperate int 操作加减（1或-1）
--! @return 
--]]
function TeamSkillUpdateView:updateAboutExp(inView, inData, inOperate, piaoSpeed, subItemBtn)
    if self._tiaochu == true then
        self:shifangdingshi()
        self._tiaochu = false
        return
    end
    local updateBtn = self:getUI("bg.Panel_10.updateBtn")
    local anim1 = updateBtn:getChildByName("anim1")
    if self._depleteItems[tostring(inData.goodsId)] == nil then 
        self._depleteItems[tostring(inData.goodsId)] = 0
    end
    if not inView then
        print("=type(inView)===========",inView, type(inView))
        return
    end
    local subItemCountBtn = inView:getChildByFullName("subItemCountBtn")

    local operateResult = self._depleteItems[tostring(inData.goodsId)] + 1 * inOperate

    -- 判断是否消耗光所有物品
    if inData.num - operateResult < 0 then 
        self._viewMgr:showTip("没有多余的材料可添加")
        self._tiaochu = true
        return
    end
    -- 最多消耗999
    if operateResult >= 1000 then 
        self._viewMgr:showTip("请强化完毕再次添加")
        self._tiaochu = true
        return 
    end

    local skillData = self._skillData[self._curSelectIndex]
    local sysSkillIndex = skillData.sysSkillIndex

    local skillLevel = self._teamData["sl" .. sysSkillIndex]
    -- 最大等级判断
    -- local tmpSysLevelSkillData = tab:LevelSkill(skillLevel + self._tempLevel + 1)
    -- if tmpSysLevelSkillData == nil then
 --        self._viewMgr:showTip("技能已达当前最高等级")
    --  return 
    -- end
    local sysTeamStarData = tab:Star(self._teamData.star)
    if inOperate >= 1 then
        if (skillLevel + self._tempLevel) >= sysTeamStarData.skilllevel then
            self._tiaochu = true
            self._viewMgr:showTip("技能已达当前最高等级") 
            return
        end
    end

-- 强化按钮上的特效
    local subItemCountBtn = subItemBtn --inView:getChildByName("subItemCountBtn")
    if inData.num - operateResult <= 0 then
        IconUtils:setIeamIconBlack(inView, true)

    else
        IconUtils:setIeamIconBlack(inView, false)
    end
    IconUtils:setIeamIconBlack(subItemCountBtn, false)

-- 动画
    if self._itemAnim == true then
        self:setAnim(inView)
        self._itemAnim = false
    end

    if subItemCountBtn ~= nil then 
        if operateResult == 0 then 
            subItemCountBtn:setVisible(false)
        else
            subItemCountBtn:setVisible(true)
        end
    end
    if operateResult < 0 then 
        subItemCountBtn:setVisible(false)
        if self._depleteSchedule ~= nil then 
            ScheduleMgr:unregSchedule(self._depleteSchedule)
            self._depleteSchedule = nil
        end
        return 
    end

    local sysLevelSkillData = tab:LevelSkill(skillLevel + self._tempLevel)
    local needExp = sysLevelSkillData.exp
    if skillData.teji then
        needExp = sysLevelSkillData.redexp
    end
    print("===========", skillLevel + self._tempLevel)
-- 设置按钮光效
    self._depleteItems[tostring(inData.goodsId)] = operateResult
    local expProg = self:getUI("bg.Panel_10.expProg")
    if anim1 ~= nil then
        local animFlag = false
        for k,v in pairs(self._depleteItems) do
            if v ~= 0 then
                animFlag = true
                break
            end
        end
        if animFlag == true then
            anim1:setVisible(true)
            -- expProg:setVisible(false)
        else
            anim1:setVisible(false)
            -- expProg:setVisible(true)
        end
    end

    local itemCount = inView:getChildByFullName("itemCount")

    local showMaxNum = inData.num
    if inData.num > 999 then 
        showMaxNum = "999+"
    end

    if operateResult > 0 then
        itemCount:setString(operateResult .. "/" .. showMaxNum)
    else
        local tempNum = inData.num + operateResult * inOperate
        if tempNum > 999 then
            tempNum = "999+"
        end
        itemCount:setString(tempNum)
    end
    local sysToolSkilllevelData = tab:ToolSkillLevel(inData.goodsId)

    -- 当前怪兽技能经验值
    -- local teamSkillExp = self._teamData["se" .. selectIndex]
    
    -- 点选材料增加临时经验
    local tempExp = self._tempExp
    self._tempExp = self._tempExp + sysToolSkilllevelData.skillexp * inOperate
    if self._shengyuExp and self._shengyuExp > 0 then
        self._shengyuExp = self._shengyuExp + sysToolSkilllevelData.skillexp * inOperate
        if self._shengyuExp >= 0 then
            self._tempExp = self._tempExp + sysToolSkilllevelData.skillexp
        elseif self._shengyuExp < 0 then
            self._tempExp = self._shengyuExp + tempExp
            self._shengyuExp = -10000
        end
    end
    
    -- print("=========================self._tempExp",self._tempExp-tempExp)
    if inOperate == 1 and piaoSpeed == true then
        self:touchPiaoExp(self._tempExp-tempExp)
    end

    local updateBtn = self:getUI("bg.Panel_10.updateBtn")
    if self._tempExp > 0 or self._tempLevel > 0 then 
        updateBtn:setEnabled(true)
    end

    local flag = false

    -- 如果点选经验超过1级以上，则需要对界面做处理
    print("self._tempExp >= sysLevelSkillData.exp",self._tempExp, needExp, self._tempLevel)
    if self._tempExp >= needExp then
        for i=1,50 do
            self._tempExp = self._tempExp - needExp
            self._tempLevel = self._tempLevel + 1
            sysLevelSkillData = tab:LevelSkill(skillLevel + self._tempLevel)
            needExp = sysLevelSkillData.exp
            if skillData.teji then
                needExp = sysLevelSkillData.redexp
            end
            if self._tempExp < needExp then
                break
            end
        end
        if (skillLevel + self._tempLevel) > sysTeamStarData.skilllevel then
            self._tempLevel = self._tempLevel - 1
            self._shengyuExp = self._tempExp + 1
            sysLevelSkillData = tab:LevelSkill(skillLevel + self._tempLevel)
            needExp = sysLevelSkillData.exp
            if skillData.teji then
                needExp = sysLevelSkillData.redexp
            end
            self._tempExp = needExp - 1
        end
        local soulProgBg = self:getUI("bg.Panel_10.soulProgBg")
        flag = true
    -- 如果点选经验超过1级以上，消除经验时需要处理
    elseif self._tempExp < 0 and self._tempLevel > 0 then 
        local skillLevel = self._teamData["sl" .. sysSkillIndex]
        for i=1,50 do
            self._tempLevel = self._tempLevel - 1
            sysLevelSkillData = tab:LevelSkill(skillLevel + self._tempLevel)
            needExp = sysLevelSkillData.exp
            if skillData.teji then
                needExp = sysLevelSkillData.redexp
            end
            self._tempExp = self._tempExp + needExp
            if self._tempExp >= 0 then
                break
            end
        end

        -- self._tempLevel = self._tempLevel - 1
        -- sysLevelSkillData = tab:LevelSkill(skillLevel + self._tempLevel)
        -- 如果删除已经点选的材料后导致临时经验成负数则用下一级的升级经验减去负数
        -- self._tempExp = sysLevelSkillData.exp + self._tempExp 
        flag = true
    end
    local expTipLab = self:getUI("bg.Panel_10.expTipLab")
    -- 等级达到最大时进行经验处理
    if (skillLevel + self._tempLevel) >= table.nums(tab.levelSkill) then
        local tempMaxLevelSkillData = tab:LevelSkill(table.nums(tab.levelSkill) - 1)
        local tempMaxExp = tempMaxLevelSkillData.exp
        if skillData.teji then
            tempMaxExp = tempMaxLevelSkillData.redexp
        end
        expTipLab:setString(tempMaxExp .. "/" ..  tempMaxExp)
        self._maxExpBar = true
    else
        expTipLab:setString(self._tempExp .. "/" ..  needExp)
        self._maxExpBar = false
    end
    
    expTipLab:setFontSize(20)
    -- expTipLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    local image44 = self:getUI("bg.Image_9.Image_44")

    -- local levelLab2 = self:getUI("bg.Image_9.levelLab2")

    if self._tempLevel > 0 and flag  == true then 
        self._levelLab2:setString( "Lv." .. (skillLevel + self._tempLevel))
    end
    -- 如果等级=0时则隐藏右侧等级
    if self._tempLevel > 0 then 
        self._levelLab2:setVisible(true)
        image44:setVisible(true)
    else
        self._levelLab2:setVisible(false)
        image44:setVisible(false)
    end

    if self._sysSkill ~= nil and flag == true then 
        local panel323 = self:getUI("bg.Image_9.Panel_323")
        -- local desc = SkillUtils:handleSkillDesc1(lang(self._sysSkill.des), self._teamData, skillLevel ,self._tempLevel)
        -- desc = string.gsub(desc,"%b[]","")
        -- local descLab = panel323:getChildByFullName("Label_36")
        -- descLab:setString(desc)
        -- descLab:setAnchorPoint(cc.p(0,1))
        -- -- descLab:setColor(cc.c3b(111,70,32))
        -- descLab:setColor(cc.c3b(255,235,191))
        -- descLab:setPosition(-10, panel323:getContentSize().height)
        local richText = panel323:getChildByName("richText")
        if richText ~= nil then
            richText:removeFromParent()
        end
        local skillItem = self._tableView:cellAtIndex(self._curSelectIndex - 1)
        local skillLvl = skillItem:getChildByFullName("skillItem.skill.skillLvl")
        local addLevel = skillLvl.addLevel or 0
        local desc = SkillUtils:handleSkillDesc1(lang(self._sysSkill.des), self._teamData, skillLevel+addLevel ,self._tempLevel)
        desc = string.gsub(desc, "fae6c8", "462800")
        -- richText = RichTextFactory:create(desc, panel323:getContentSize().width, panel323:getContentSize().height)
        -- richText:formatText()
        -- richText:enablePrinter(true)
        -- richText:setPosition(panel323:getContentSize().width*0.5, panel323:getContentSize().height - richText:getInnerSize().height*0.5)
        -- richText:setName("richText")
        -- panel323:addChild(richText)
        local originWidth,originHeight = panel323:getContentSize().width,panel323:getContentSize().height
        richText = RichTextFactory:create(desc, panel323:getContentSize().width-5, panel323:getContentSize().height)
        richText:formatText()
        richText:enablePrinter(true)
        local rtRealHeight = richText:getRealSize().height
        richText:setPosition(originWidth*0.5,  rtRealHeight*0.5)
        richText:setName("richText")
        UIUtils:alignRichText(richText)
        panel323:addChild(richText)
        local realHeight = math.max(originHeight,rtRealHeight)
        panel323:setInnerContainerSize(cc.size(originWidth,rtRealHeight))
        panel323:setTouchEnabled(rtRealHeight > originHeight)
        panel323:getInnerContainer():setPositionY(originHeight - rtRealHeight)

    end 
    -- 经验条操控
    local expProg = self:getUI("bg.Panel_10.expProg")
    local blueExpProg = self:getUI("bg.Panel_10.blueExpProg")
    if self._tempLevel == 0 then
        -- expProg:setVisible(true)
    else
        expProg:setVisible(false)
    end
    blueExpProg:setVisible(true)
    if inOperate > 0 then
        local tempAnim = blueExpProg:getScaleX() * 100
        if tempAnim == 100 then
            tempAnim = 0
        end
 
        local nowExp = self._tempExp/needExp * 100
        local addTempExp = nowExp + 100*(self._tempLevel-self._expLevel) -- - tempAnim
        self._expLevel = self._tempLevel
        if addTempExp - tempAnim >= 0 then
            local addExp = 18
            blueExpProg:stopAllActions()
            blueExpProg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
                if addTempExp - tempAnim < 3.9 then
                    blueExpProg:stopAllActions()

                    local percent = self._tempExp / needExp
                    if (skillLevel + self._tempLevel) == 15 then
                        blueExpProg:setScaleX(1)
                    else
                        if percent > 1 then
                            percent = 1
                        end
                        if percent < 0 then
                            percent = 0
                        end
                        blueExpProg:setScaleX(percent)
                    end

                elseif tempAnim < addTempExp then
                    local str = addTempExp
                    if addTempExp > 100 then
                        str = math.fmod(tempAnim, 100)
                    else
                        str = tempAnim
                    end
                    local percent = str*0.01
                    if percent > 1 then
                        percent = 1
                    end
                    if percent < 0 then
                        percent = 0
                    end
                    blueExpProg:setScaleX(percent)
                else
                    blueExpProg:stopAllActions()
                    percent = self._tempExp / needExp
                    -- print("===percentpercent===========", percent, self._tempExp, needExo)
                    -- blueExpProg:setScaleX(percent)
                    if (skillLevel + self._tempLevel) == 15 then
                        blueExpProg:setScaleX(1)
                    else
                        if percent > 1 then
                            percent = 1
                        end
                        if percent < 0 then
                            percent = 0
                        end
                        blueExpProg:setScaleX(percent)
                    end
                end
                tempAnim = tempAnim + addExp
            end), cc.DelayTime:create(0.0001))))
        end
        -- blueExpProg:setScaleX(self._tempExp / needExp * 100)
        -- self._expLevel = self._tempLevel
    else
        local tempAnim = blueExpProg:getScaleX() * 100
        if tempAnim == 100 then
            tempAnim = 0
        end

        -- print("“nowexp ===", self._tempExp, needExp)
        local nowExp = self._tempExp/needExp * 100
        -- print("temp ==========",nowExp, self._tempLevel, self._expLevel)
        local addTempExp = nowExp + 100*(self._tempLevel-self._expLevel) -- - tempAnim
        self._expLevel = self._tempLevel

        print ("===addTempExp========", addTempExp, tempAnim)
        if addTempExp - tempAnim < 0 then
            blueExpProg:stopAllActions()
            local addExp = -19.9
            blueExpProg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
                -- print ("addTempExp+++======", tempAnim ,addTempExp)
                if tempAnim - addTempExp < 3.9 then
                    blueExpProg:stopAllActions()

                    local str =  self._tempExp / needExp
                    if str > 1 then
                        str = 1
                    end
                    if str < 0 then
                        str = 0
                    end
                    blueExpProg:setScaleX(str)
                    
                    if self._tempLevel == 0 then
                        expProg:setVisible(true)
                    end
                elseif tempAnim > addTempExp then
                    local str = addTempExp -- math.fmod(tempAnim, 100)
                    if str < 0 then
                        str = math.fmod(tempAnim, 100)
                        str = 100 + str
                    else
                        str = addTempExp
                    end
                    local percent = str*0.01
                    if percent > 1 then
                        percent = 1
                    end
                    if percent < 0 then
                        percent = 0
                    end
                    blueExpProg:setScaleX(percent)
                else
                    blueExpProg:stopAllActions()
                    percent = self._tempExp / needExp
                    -- print("===percentpercent===========", percent, self._tempExp, needExp)
                    -- blueExpProg:setScaleX(percent)
                    if (skillLevel + self._tempLevel) == 0 then
                        blueExpProg:setScaleX(1)
                    else
                        if percent > 1 then
                            percent = 1
                        end
                        if percent < 0 then
                            percent = 0
                        end
                        blueExpProg:setScaleX(percent)
                    end
                    if self._tempLevel == 0 then
                        expProg:setVisible(true)
                    end
                end
                tempAnim = tempAnim + addExp
            end), cc.DelayTime:create(0.0001))))
        end
    end
    print("self._maxExpBar=====", self._maxExpBar)

    if self._maxExpBar == true then
        blueExpProg:setScaleX(1)
    end
    self:setMaxLevelShow()
end

--按钮动画
function TeamSkillUpdateView:animBegin()
    local updateBtn = self:getUI("bg.Panel_10.updateBtn")
    local mc1 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false, function (_, sender)
        -- sender:gotoAndPlay(80)
    end)
    mc1:setName("anim1")
    mc1:setPosition(updateBtn:getContentSize().width*0.5, updateBtn:getContentSize().height*0.5)
    updateBtn:addChild(mc1, 1)
    mc1:setVisible(false)
end

--[[
--! @function resetUpdateData
--! @desc 重置数据（用于报错的时候）
--! @return 
--]]
function TeamSkillUpdateView:resetUpdateData()
    self:reflashUI(self._teamData)
end

--[[
--! @function upgradeSkill
--! @desc 点击升级技能按钮
--! @return 
--]]
function TeamSkillUpdateView:upgradeSkill()
    local updateBtn = self:getUI("bg.Panel_10.updateBtn")
    local anim1 = updateBtn:getChildByName("anim1")
    if anim1 ~= nil then
        anim1:setVisible(false)
    end
    for k,v in pairs(self._depleteItems) do
        if v == 0 then
            self._depleteItems[k] = nil
        end
    end
    if next(self._depleteItems) == nil then 
        self._viewMgr:showTip(lang("TIPS_BINGTUAN_11"))
        return 
    end
    local items = {}
    items["items"] = {}
    for k,v in pairs(self._depleteItems) do
        local tempData = {}
        table.insert(tempData, tonumber(k))
        table.insert(tempData, tonumber(v))
        table.insert(items.items,tempData)
    end
    self._oldFight = TeamUtils:updateFightNum()

    local skillData = self._skillData[self._curSelectIndex]
    local sysSkillIndex = skillData.sysSkillIndex
    local param = {args = json.encode(items), positionId = sysSkillIndex, teamId = self._teamData.teamId}
    self._serverMgr:sendMsg("TeamServer", "upgradeSkill", param, true, {}, function (result)
        return self:upgradeSkillFinish(result)
    end)
end

-- 强化完成
function TeamSkillUpdateView:upgradeSkillFinish(inResult)
    if inResult["d"] == nil then 
        return
    end
    audioMgr:playSound("crSkLvUp")
    local tempTeamData,tempTeamIndex = self._teamModel:getTeamAndIndexById(self._teamData.teamId)
    local tempData = {}
    tempData.teamData = tempTeamData
    tempData.index = self._curSelectIndex
    -- self:reflashUI(tempData)
    
    local teamImgBg = self:getUI("bg")
    TeamUtils:setFightAnim(teamImgBg, {oldFight = self._oldFight, newFight = TeamUtils:updateFightNum(), x = teamImgBg:getContentSize().width*0.5-100, y = teamImgBg:getContentSize().height - 170})

    --头像特效
    local panel39 = self:getUI("bg.Image_9.Panel_39")
    -- panel39:setAnchorPoint(cc.p(0.5, 0.5))
    local skillIcon = panel39:getChildByName("skillIcon")
    local mc2 = mcMgr:createViewMC("jinengjiesuo_qianghua", true, false, function (_, sender)
        sender:gotoAndPlay(0)
        sender:removeFromParent()
    end)
    
    mc2:setScale(1.2)
    mc2:setPosition(panel39:getContentSize().width*0.5, panel39:getContentSize().height*0.5)
    -- mc2:setPosition(78, 57)
    panel39:addChild(mc2, 7)

    self:reflashSkillUI()

end

--进度条反馈特效
function TeamSkillUpdateView:successSkill()
    -- local expProg = self:getUI("bg.Panel_10.expProg")
    -- local mc2 = mcMgr:createViewMC("jindutiaofankui_teamskillanim", true, false, function (_, sender)
    --     sender:gotoAndPlay(0)
    --     sender:removeFromParent()
    -- end)
    -- mc2:setPosition(233, 12)
    -- expProg:addChild(mc2, 2)

-- 头像特效

end



return TeamSkillUpdateView
