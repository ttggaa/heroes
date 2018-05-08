--[[
    Filename:    DragonRuleView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-11-09 15:59:06
    Description: File description
--]]

local DragonRuleView = class("DragonRuleView", BasePopView)

function DragonRuleView:ctor(params)
    DragonRuleView.super.ctor(self)
    self._tableData = params.tableData
    self._dragonId = params.dragonId or 1
    self._teamModel = self._modelMgr:getModel("TeamModel")
end

function DragonRuleView:onInit()
    self._touchIdx = 0
    self._skillArr = {}
    self._dragonLayer = {}  
    for i = 1, 3 do
        self._dragonLayer[i] = {}
        self._dragonLayer[i]._layer = self:getUI("bg.image_dragon_bg.layer_dragon.layer_dragon_" .. i)
        --[[
        -- 兵团icon
        local teamId = self._tableData[i].NPC[1]
        local teamTableData = tab:Npc(teamId)
        local backQuality = self._teamModel:getTeamQualityByStage(teamTableData.stage)
        local icon = IconUtils:createTeamIconById({teamData = {id = teamId, star = teamTableData.star}, sysTeamData = teamTableData, quality = backQuality[1], quaAddition = backQuality[2], tipType = 9, eventStyle = 0})
        icon:setTouchEnabled(false)
        icon:setPosition(-2, 2)
        icon:setScale(0.9)
        IconUtils:setTeamIconStarVisible(icon, false)
        IconUtils:setTeamIconStageVisible(icon, false)
        IconUtils:setTeamIconLevelVisible(icon, false)
        self._dragonLayer[i]._layer:addChild(icon)
        ]]
        local layer_icon = self:getUI("bg.image_dragon_bg.layer_dragon.layer_dragon_" .. i .. ".layer_icon")
        self._dragonLayer[i]._selected = mcMgr:createViewMC("dargon" .. i .. "1_dragonselectedanim", true,false)
        self._dragonLayer[i]._selected:setPosition(layer_icon:getContentSize().width*0.5, layer_icon:getContentSize().height*0.5)
        self._dragonLayer[i]._selected:setVisible(false)
        layer_icon:addChild(self._dragonLayer[i]._selected,-1)

        self:registerClickEvent(self._dragonLayer[i]._layer, function()
            self:onDragonButtonClicked(i)
        end)
       
        self._dragonLayer[i]._name = self:getUI("bg.image_dragon_bg.layer_dragon.layer_dragon_" .. i .. ".label_name")
        self._dragonLayer[i]._name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        self._dragonLayer[i]._name:setString(lang(string.format("TIPS_PVE_BOSS_%d0", i)))
    end
    local title = self:getUI("bg.dragon_title_bg.dragonTitle")
    UIUtils:setTitleFormat(title, 6)

    -- detailTxt:setFontName(UIUtils.ttfName)
    self._scrollview = self:getUI("bg.scrollview")
    local label_boss_name = self._scrollview:getChildByFullName("label_boss_name")
    -- label_boss_name:enableOutline(cc.c4b(36,27,18,255),2)
    local label_dragon_name = self._scrollview:getChildByFullName("label_dragon_name")
    -- label_dragon_name:enableOutline(cc.c4b(36,27,18,255),2)
    local act_time = self._scrollview:getChildByFullName("act_time")
    -- act_time:enableOutline(cc.c4b(36,27,18,255),2)
    local label_time_value = self._scrollview:getChildByFullName("label_time_value")
    -- label_time_value:enableOutline(cc.c4b(36,27,18,255),2)
    local recommend_team = self._scrollview:getChildByFullName("recommend_team")
    -- recommend_team:enableOutline(cc.c4b(36,27,18,255),2)
    for i = 1, #self._scrollview:getChildren() do
        self._scrollview:getChildren()[i].oriHeight = self._scrollview:getChildren()[i]:getPositionY()
    end
    self._dragonInfo = {}
    self._dragonInfo._labelDragonName = self:getUI("bg.scrollview.label_dragon_name")
    self._dragonInfo._labelTimeValue = self:getUI("bg.scrollview.label_time_value")

    self._dragonInfo._recommendTeam = {}
    for i = 1, 5 do
        self._dragonInfo._recommendTeam[i] = self:getUI("bg.scrollview.team_" .. i)
    end

    self._dragonInfo._skillDescription = {}
    for i = 1, 5 do
        self._dragonInfo._skillDescription[i] = self:getUI("bg.scrollview.skill_" .. i)
    end

    self._recommend_team = self:getUI("bg.scrollview.recommend_team")
    self._recommend_teamY = self._recommend_team:getPositionY()
    self:onDragonButtonClicked(self._dragonId)

    self:registerClickEventByName("bg.btn_close", function()
        self:close()
        UIUtils:reloadLuaFile("pve.DragonRuleView")
    end)
end

function DragonRuleView:updateDragonButtonStatus(index)
    for i = 1, 3 do
        self._dragonLayer[i]._selected:setVisible(i == index)
        self._dragonLayer[i]._name:setColor(i == index and UIUtils.colorTable.ccUIBaseColor7 or UIUtils.colorTable.ccUIBaseColor5)
        self._dragonLayer[i]._name:setFontSize(i == index and 24 or 24)
    end
end

function DragonRuleView:onDragonButtonClicked(index)
    print("onDragonButtonClicked ", index)
    if self._touchIdx == index then
        return
    end
    self._touchIdx = index
    local dateInfo = {
        [1] = "周一",
        [2] = "周二",
        [3] = "周三",
        [4] = "周四",
        [5] = "周五",
        [6] = "周六",
        [7] = "周日",
    }
    self:updateDragonButtonStatus(index)
    self._dragonInfo._labelDragonName:setString(lang(string.format("TIPS_PVE_BOSS_%d0", index)))
    self._recommend_team:setString(lang(string.format("TIPS_PVE_BOSS_%d0", index)) .. "介绍:")
    local date = ""
    for i = 1, #self._tableData[index].time do
        date = date .. dateInfo[self._tableData[index].time[i]]
        if i < #self._tableData[index].time then
            date = date .. "、"
        end
    end
    self._dragonInfo._labelTimeValue:setString(date)
    --[[
    for i = 1, #self._tableData[index]["recommend"] do
        local iconGrid = self._dragonInfo._recommendTeam[i]
        iconGrid:removeAllChildren()
        local id = self._tableData[index]["recommend"][i]
        local icon = nil
        print("=====================",id)
        if string.sub(id, 1, 2) == "60" and string.len(id) == 5 then
            local sysHeroData = tab:Hero(id)
            dump(sysheroData,"60001")
            icon = IconUtils:createHeroIconById({sysHeroData = sysHeroData})
            icon:setAnchorPoint(cc.p(0,0))
            -- icon:setScale(0.67)
            icon:getChildByName("starBg"):setVisible(false)
            for i=1,6 do
                if icon:getChildByName("star" .. i) then
                    icon:getChildByName("star" .. i):setPositionY(icon:getChildByName("star" .. i):getPositionY() + 5)
                end
            end
            icon:setSwallowTouches(false)
            icon:setPosition(0, 2)
            icon:setScale(0.77)
            registerClickEvent(icon, function()
                local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = id}, true)
            end)

        else
            local teamId = id
            local teamTableData = tab:Team(teamId)
            -- dump(teamTableData,"teamTableData")
            local star = 0
            local stage = 1
            if teamTableData then
                star = teamTableData.star
                stage = teamTableData.stage
            end
            local backQuality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(stage)
            -- icon = IconUtils:createTeamIconById({teamData = {id = teamId, star = teamTableData.star}, sysTeamData = teamTableData, quality = backQuality[1], quaAddition = backQuality[2], tipType = 9, eventStyle = 2})
            icon = IconUtils:createSysTeamIconById({teamData = {id = teamId, star = star}, sysTeamData = tab:Team(teamId), quality = backQuality[1], quaAddition = backQuality[2], tipType = 8, eventStyle = 1})
           
            icon:setScale(0.75)
            icon:setPosition(0, 0)
            if star == 0 then
                icon:setSaturation(-100)
            end
            -- IconUtils:setTeamIconStarVisible(icon, false)
            -- IconUtils:setTeamIconStageVisible(icon, false)
            -- IconUtils:setTeamIconLevelVisible(icon, false)            
        end        
        iconGrid:setVisible(true)
        iconGrid:addChild(icon, 15)
    end    
    ]]
    --添加技能介绍
    for k,v in pairs(self._skillArr) do
        if v then 
            v:removeFromParent()
            v = nil
        end
    end
    self._skillArr = {}
    local height = 120
    local oriH = self._recommend_teamY - self._recommend_team:getContentSize().height*0.5
    local panelH = 85
    for i = 1, #self._tableData[index]["skill"] do
       local skillPanel = self:createDragonSkill(self._tableData[index]["skill"][i],panelH)
       skillPanel.oriHeight = oriH - i*panelH
       height = height + panelH
       self._scrollview:addChild(skillPanel)
    end

    local labelDiscription = self._dragonInfo._skillDescription[1]
    local desc = lang("RULE_DRAGON_"..index)
    if not string.find(desc, "color") then
        desc = "[color=3d1f00]" .. desc .. "[-]"
    end
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - 5 - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)
    labelDiscription.oriHeight = oriH - #self._tableData[index]["skill"]*panelH - labelDiscription:getContentSize().height
    
    height = height + richText:getInnerSize().height + 5
    self._scrollview:setInnerContainerSize(cc.size(450, height))
   
    for i = 1, #self._scrollview:getChildren() do
        if self._scrollview:getChildren()[i].oriHeight then
            self._scrollview:getChildren()[i]:setPositionY(self._scrollview:getChildren()[i].oriHeight - (670 - height))
        end
    end
    -- self._scrollview:scrollToTop(0.01, false)
    self._scrollview:scrollToPercentVertical(0.1, 0, false)
end

function DragonRuleView:createDragonSkill(skillId,height)

    local bgNode = ccui.Layout:create()
    bgNode:setBackGroundColorOpacity(0)
    bgNode:setAnchorPoint(0,0)
    bgNode:setBackGroundColorType(1)
    bgNode:setBackGroundColor(cc.c3b(0,0,0))
    bgNode:setContentSize(418, height-1)    

    local skillIcon = IconUtils:createPveBossSkillIconById(
       {bossSkill = {id = tostring(skillId), 
                     art = "sk_longzhiguo_".. skillId,
                     name = "LONGZHIGUO_" .. skillId,
                     des = "LONGZHIGUODES_" .. skillId
                     },
                      eventStyle = 1
       })
       skillIcon:setScale(80 / skillIcon:getContentSize().width)
       skillIcon:setPosition(10, 2)
       bgNode:addChild(skillIcon)

    local name = ccui.Text:create()
    name:setFontSize(22)
    name:setName("name")
    name:setFontName(UIUtils.ttfName)
    name:setColor(cc.c4b(134,92,48,255))   --UIUtils.colorTable.ccUIBaseTextColor2)
    name:setString(lang("LONGZHIGUO_" .. skillId))
    name:setAnchorPoint(0,0.5)
    name:setPosition(100, 65)
    bgNode:addChild(name,1)

    local des = ccui.Text:create()
    des:setFontSize(20)
    des:setName("des")
    des:setFontName(UIUtils.ttfName)
    des:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    des:setString(lang("LONGZHIGUODES_" .. skillId))
    des:setTextAreaSize(cc.size(320,65))
    des:setTextVerticalAlignment(1)
    des:setAnchorPoint(0,0.5)
    des:setPosition(100, 28)
    bgNode:addChild(des,1)

    table.insert(self._skillArr, bgNode)

    return bgNode
end

return DragonRuleView