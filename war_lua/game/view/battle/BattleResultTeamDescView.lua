--[[
    Filename:    BattleResultTeamDescView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2017-08-17 11:11:27
    Description: File description
--]]

local tab = tab
local lang = lang
local SkillUtils = SkillUtils

local BattleResultTeamDescView = class("BattleResultTeamDescView", BasePopView)

BattleResultTeamDescView.kTeamScale = 0.75

function BattleResultTeamDescView:ctor(params)
    BattleResultTeamDescView.super.ctor(self)
    self._teamData = params.teamData
    self._teamTempData = params.teamD

    self._teamModel = self._modelMgr:getModel("TeamModel")
end

function BattleResultTeamDescView:onDestroy()
    local tc = cc.Director:getInstance():getTextureCache()
    if self._steamFileName then tc:removeTextureForKey(self._steamFileName) end
    BattleResultTeamDescView.super.onDestroy(self)
end

function BattleResultTeamDescView:disableTextEffect(element)
    if element == nil then
        element = self._widget
    end
    local desc = element:getDescription()
    if desc == "Label" then
        element:disableEffect()
        element:setFontName(UIUtils.ttfName)
    end
    local count = #element:getChildren()
    for i = 1, count do
        self:disableTextEffect(element:getChildren()[i])
    end
end

function BattleResultTeamDescView:onInit()

    self:disableTextEffect()

    self._title = self:getUI("bg.layer.titleImg.titleTxt")
    UIUtils:setTitleFormat(self._title, 1)

    self._team = {}
    self._team._layer = self:getUI("bg.layer.layer_team")
    self._team._layerClass = self:getUI("bg.layer.layer_team.layer_left.image_info_bg.layer_class")    
    self._team._layerClass:setAnchorPoint(0.5,0.5)
    self._team._layerClass:setScaleAnim(true)
    self._team._layerClass:setPosition(28,22)
    self._team._labelName = self:getUI("bg.layer.layer_team.layer_left.image_info_bg.label_name")
    self._team._labelName:setFontName(UIUtils.ttfName)
    self._team._labelName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local label_title = self:getUI("bg.layer.layer_team.layer_right.team_info_1.label_title")
    UIUtils:setTitleFormat(label_title, 3)
    local label_title1 = self:getUI("bg.layer.layer_team.layer_right.team_info_2.label_title")
    UIUtils:setTitleFormat(label_title1, 3)
    local label_title2 = self:getUI("bg.layer.layer_team.layer_right.team_info_3.label_title")
    UIUtils:setTitleFormat(label_title2, 3)

    self._team._star = {}
    for i = 1, 6 do
        self._team._star[i] = {}
        self._team._star[i]._normal = self:getUI("bg.layer.layer_team.layer_left.image_info_bg.layer_star.star_n_" .. i)
        self._team._star[i]._disable = self:getUI("bg.layer.layer_team.layer_left.image_info_bg.layer_star.star_d_" .. i)
    end
    self._team._layerBody = self:getUI("bg.layer.layer_team.layer_left.layer_body")
    self._team._labelFightScore = self:getUI("bg.layer.layer_team.layer_left.label_fight_score")
    -- self._team._labelFightScore:setScale(0.7)
    self._team._labelFightScore:setFntFile(UIUtils.bmfName_zhandouli_little)
    self._team._labelFightScore:setScale(0.6)

    self._team._labelLocked = self:getUI("bg.layer.layer_team.layer_left.label_locked")
    -- self._team._labelLocked:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._team._labelGroupDes = self:getUI("bg.layer.layer_team.layer_right.team_info_1.label_group_des")
    self._team._labelNumDes = self:getUI("bg.layer.layer_team.layer_right.team_info_1.label_num_des")
    self._team._labelZiZhiDes = self:getUI("bg.layer.layer_team.layer_right.team_info_1.label_zizhi_des")
    self._team._labelLocationDes = self:getUI("bg.layer.layer_team.layer_right.team_info_1.label_location_des")
    self._team._labelLocationDes:setTextAreaSize(cc.size(264,60))
    self._team._teamInfo = self:getUI("bg.layer.layer_team.layer_right.team_info_2")
    self._team._teamInfo1 = self:getUI("bg.layer.layer_team.layer_right.team_info_3")
    self._team._teamInfo:setVisible(true)
    self._team._teamInfo1:setVisible(false)
    self._team._skill = {}
    for i = 1, 4 do
        self._team._skill[i] = {}
        self._team._skill[i]._icon = self:getUI("bg.layer.layer_team.layer_right.team_info_2.layer_skill_icon_" .. i)
        self._team._skill[i]._name = self:getUI("bg.layer.layer_team.layer_right.team_info_2.layer_skill_icon_" .. i .. ".label_skill_name")
        self._team._skill[i]._name:setFontName(UIUtils.ttfName)
        self._team._skill[i]._name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        -- self._team._skill[i]._name:enableShadow(UIUtils.colorTable.ccUIBaseShadowColor, cc.size(0, -2))
        self._team._skill[i]._level = self:getUI("bg.layer.layer_team.layer_right.team_info_2.layer_skill_icon_" .. i .. ".label_skill_level")
        self._team._skill[i]._locked = self:getUI("bg.layer.layer_team.layer_right.team_info_2.layer_skill_icon_" .. i .. ".image_skill_locked")
    end

    self._team._skill1 = {}
    for i = 1, 5 do
        self._team._skill1[i] = {}
        self._team._skill1[i]._icon = self:getUI("bg.layer.layer_team.layer_right.team_info_3.layer_skill_icon_" .. i)
        self._team._skill1[i]._name = self:getUI("bg.layer.layer_team.layer_right.team_info_3.layer_skill_icon_" .. i .. ".label_skill_name")
        self._team._skill1[i]._name:setFontName(UIUtils.ttfName)
        self._team._skill1[i]._name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        -- self._team._skill1[i]._name:enableShadow(UIUtils.colorTable.ccUIBaseShadowColor, cc.size(0, -2))
        self._team._skill1[i]._level = self:getUI("bg.layer.layer_team.layer_right.team_info_3.layer_skill_icon_" .. i .. ".label_skill_level")
        self._team._skill1[i]._locked = self:getUI("bg.layer.layer_team.layer_right.team_info_3.layer_skill_icon_" .. i .. ".image_skill_locked")
    end

    self:updateTeamInformation()

    self:registerClickEventByName("bg.layer.btn_close", function()
        if self._closeCallback and type(self._closeCallback) == "function" then
            self._closeCallback()
        end
        self:close()
        UIUtils:reloadLuaFile("battle.BattleResultTeamDescView")
    end)
end

function BattleResultTeamDescView:updateTeamInformation()
    --print("NewFormationDescriptionView:updateNpcTeamInformation")
    self._team._layer:setVisible(true)
    self._title:setString("兵团信息")

    local teamData = self._teamData.teamData
    local skillData = self._teamData.skillLevels
    local isJx = self._teamData.jx
    if not teamData then print("invalid team icon id", teamData.id) end

    local teamTempData = clone(self._teamTempData)
    local isNpc = not tab.team[teamData.id] and tab.npc[teamData.id]
    local isAwaking,awakingLvl  
    if isJx then  
        if isNpc then
            isAwaking, awakingLvl = true, teamTempData.jxLv
        else 
            isAwaking,awakingLvl = TeamUtils:getTeamAwaking(teamData)
        end
    end
    
    local nameStr = nil
    local rolePic = nil
    if not tab.npc[self._teamData.ID] then
        nameStr, head, pic, rolePic = TeamUtils:getTeamAwakingTab(teamData, teamData.match or self._teamData.ID)
    else
        nameStr = teamTempData.name
        rolePic = TeamUtils.getNpcTableValueByTeam(teamTempData, "steam")
        local isChanged = TeamUtils:checkTeamChanged(teamTempData.id)

        --判断是否有皮肤属性
        if teamTempData.sId and (not isChanged) then
            local sysSkinData = tab.teamSkin[teamTempData.sId]
            rolePic = sysSkinData.skinsteam
        end
    end
    local className = TeamUtils:getClassIconNameByTeamD(teamData, "classlabel", teamTempData, true)
    self._team._layerClass:setBackGroundImage(IconUtils.iconPath .. className .. ".png", 1)
    TeamUtils.showTeamLabelTip(self._team._layerClass, 7, teamTempData.match or teamTempData.id)
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)
    self._team._labelName:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
    local _name = lang(nameStr) .. (0 == quality[2] and "" or  "+" .. quality[2])
    if OS_IS_WINDOWS then
        self._team._labelName:setString(_name)
        self._team._labelName:setAnchorPoint(0, 0.5)
        self._team._labelName:setPositionX(self._team._labelName:getPositionX() - self._team._labelName:getContentSize().width * 0.5)
        _name = _name .. " [" .. teamTempData.id .. "]"
        self._team._labelName:setString(_name)
    else
        self._team._labelName:setString(_name)
    end

    for i = 1, 6 do
        self._team._star[i]._disable:setVisible(false)
        local imgName = ""
        if i <= teamData.star then
            imgName = "globalImageUI6_star1.png"
            if isAwaking and i <= awakingLvl then
                imgName = "globalImageUI_teamskillBigStar1.png"
            end
        else            
            imgName = "globalImageUI6_star2.png"
            if isAwaking and i <= awakingLvl then
                imgName = "globalImageUI_teamskillBigStar2.png"
            end
        end

        self._team._star[i]._normal:loadTexture(imgName,1)
    end

    local offsetX , offsetY = 0,0
    if teamData.xiaoren then
        offsetX , offsetY  = tonumber(teamData.xiaoren[1]) ,tonumber(teamData.xiaoren[2])
    end
    self._steamFileName = "asset/uiother/steam/".. rolePic ..".png"
    local teamBody = ccui.ImageView:create(self._steamFileName)
    teamBody:setAnchorPoint(cc.p(0.5, 0.1))
    teamBody:setScale(BattleResultTeamDescView.kTeamScale)
    teamBody:setPosition(self._team._layerBody:getContentSize().width / 2+offsetX, self._team._layerBody:getContentSize().height / 4.5+offsetY)
    self._team._layerBody:addChild(teamBody)

    --  team  race$cs   data[1]   race表 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bg")
    local receData = teamTempData.race
    local race = tab:Race(receData[1]).pic
    image_body_bg:loadTexture("asset/uiother/race/race_" .. race ..".png")
    local image_body_bottom = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        if receData[1] > 105 then
            image_body_bottom:loadTexture("asset/uiother/dizuo/teamBgDizuo101.png", 0)
        else
            image_body_bottom:loadTexture("asset/uiother/dizuo/teamBgDizuo" .. receData[1] .. ".png", 0)
        end
    end

    if teamData.score then
        self._team._labelFightScore:setVisible(true)
        self._team._labelFightScore:setString("a" .. teamData.score)
    else
        self._team._labelFightScore:setVisible(false)
    end

    self._team._labelLocked:setVisible(false)

    self._team._labelGroupDes:setString(lang(tab:Race(receData[1]).name))
    self._team._labelNumDes:setString((6 - TeamUtils.getNpcTableValueByTeam(teamTempData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTempData, "volume")))
    self._team._labelZiZhiDes:setString(self._modelMgr:getModel("TeamModel"):getTeamZiZhiText(teamTempData.zizhi))
    self._team._labelLocationDes:setString(lang(teamTempData.dingwei))
    
    local showSkill = self._teamModel:getTeamSkillShowSort(teamData, true)
    local skillList = self._team._skill
    local dazhaoImg = self:getUI("bg.layer.layer_team.layer_right.team_info_2.dazhao")
    local iconScale = 0.8
    if #showSkill == 5 then
        skillList = self._team._skill1
        dazhaoImg = self:getUI("bg.layer.layer_team.layer_right.team_info_3.dazhao")
        iconScale = 0.7
        self._team._teamInfo:setVisible(false)
        self._team._teamInfo1:setVisible(true)
    end

    dazhaoImg:setZOrder(10)
    dazhaoImg:setVisible(false)

    local teamSkillData = TeamUtils.getNpcTableValueByTeam(teamTempData, "skill")
    local iconTeamData = clone(teamData)
    iconTeamData.teamId = self._teamData.ID
    if isAwaking and isNpc then
        iconTeamData.ast = 3
        iconTeamData.aLvl = awakingLvl
        iconTeamData.tree = {
            b1 = iconTeamData.jxSkill1, 
            b2 = iconTeamData.jxSkill2, 
            b3 = iconTeamData.jxSkill3
        }
    end

    for i = 1, #showSkill do
        local showSkillIndex = showSkill[i]
        local iconParent = skillList[i]._icon
        local labelName = skillList[i]._name
        local labelLevel = skillList[i]._level
        local imageLocked = skillList[i]._locked
        local skillLevel = 1     --skillLevel
        if teamData.sl then
            skillLevel = teamData.sl[showSkillIndex] or 1
        elseif skillData then
            skillLevel = skillData[showSkillIndex] or 1
        end
        local skillType = teamSkillData[showSkillIndex][1]
        local skillId = teamSkillData[showSkillIndex][2]
        local skillTableData = SkillUtils:getTeamSkillByType(skillId, skillType)
--        dump(teamData)
        
        local icon = IconUtils:createTeamSkillIconById({teamSkill = skillTableData, teamData = iconTeamData, level = skillLevel, eventStyle = 1})
        icon:setScale(iconScale)
        icon:setPosition(cc.p(-5, -5))
        iconParent:addChild(icon)
        labelName:setString(lang(skillTableData.name))
        labelLevel:setVisible(skillLevel > 0)
        imageLocked:setVisible(skillLevel <= 0)
        labelLevel:setString("Lv." .. skillLevel)
        if skillTableData.dazhao and skillTableData.dazhao == 1 then 
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+18, iconParent:getPositionY()+64)         
        end

        local lingyuImg = iconParent:getChildByFullName("lingyuImg")
        if lingyuImg then
            lingyuImg:setVisible(false)
        end
        if skillTableData.lingyu and skillTableData.lingyu == 1 then
            if not lingyuImg then
                lingyuImg = ccui.ImageView:create()
                lingyuImg:loadTexture("label_big_skill_lingyu.png", 1)
                lingyuImg:setPosition(15, iconParent:getContentSize().height - 15)
                lingyuImg:setRotation(-25)
                iconParent:addChild(lingyuImg)
                lingyuImg:setScale(0.85)
            end
            lingyuImg:setVisible(true)
        end
    end
end

return BattleResultTeamDescView


