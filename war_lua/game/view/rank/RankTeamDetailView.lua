--
-- Author: huangguofang
-- Date: 2016-07-08 18:07:17
--
local RankTeamDetailView = class("RankTeamDetailView", BasePopView)
function RankTeamDetailView:ctor(params)
    self.super.ctor(self)

    self._teamData = params.data.team
    self._pokedexData = params.data.pokedex
    self._treasureData = params.data.treasures
    self._teamId = tonumber(params.data.team.teamId)
    self._heroData = params.data.heros or {}
    self._runes = params.data.runes or {}
    self._battleArray = params.data.battleArray
    self._pTalents = params.data.pTalents
    self._teamModel = self._modelMgr:getModel("TeamModel")
    -- self._crusadeModel = self._modelMgr:getModel("CrusadeModel")
    -- self._arenaModel = self._modelMgr:getModel("ArenaModel")
    -- self._guildMapModel = self._modelMgr:getModel("GuildMapModel")

end

-- 初始化UI后会调用, 有需要请覆盖
function RankTeamDetailView:onInit()
	self:registerClickEventByName("bg.layer.btn_close", function()
        self:close()
        UIUtils:reloadLuaFile("rank.RankTeamDetailView")
    end)
    --配表 兵团信息
    self._teamTableData = tab:Team(tonumber(self._teamId))

    self._title = self:getUI("bg.layer.titleBg.title")
    UIUtils:setTitleFormat(self._title, 1)

    -- left layer
    self._teamName = self:getUI("bg.layer.layer_left.image_info_bg.label_name")
    self._teamName:setFontName(UIUtils.ttfName)
    self._teamName:setColor(UIUtils.colorTable.ccUIBaseColor1)
    self._teamName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    self._classType = self:getUI("bg.layer.layer_left.image_info_bg.layer_class")
    self._classType:setScale(0.7)
    self._teamImg = self:getUI("bg.layer.layer_left.layer_body.team_img")
    -- self._teamImg:setVisible(false)
    self._starLayer = self:getUI("bg.layer.layer_left.image_info_bg.layer_star")

    self._equipPanel = self:getUI("bg.layer.layer_left.equipPanel")

    -- right layer
    self._fightScore = self:getUI("bg.layer.layer_right.label_fight_score")
    self._fightScore:setFntFile(UIUtils.bmfName_zhandouli)
    self._fightScore:setScale(0.6)

    self._teamInfo1 = self:getUI("bg.layer.layer_right.team_info_1")
    local label_title1 = self:getUI("bg.layer.layer_right.team_info_1.label_title")
    UIUtils:setTitleFormat(label_title1, 3)
    self._teamInfo2 = self:getUI("bg.layer.layer_right.team_info_2")
    self._teamInfo3 = self:getUI("bg.layer.layer_right.team_info_3")
    self._teamInfo2:setVisible(false)
    self._teamInfo3:setVisible(false)
    local label_title2 = self:getUI("bg.layer.layer_right.team_info_2.label_title")
    UIUtils:setTitleFormat(label_title2, 3)
    local label_title3 = self:getUI("bg.layer.layer_right.team_info_3.label_title")
    UIUtils:setTitleFormat(label_title3, 3)

    self._isAwaking,self._awakingLvl = TeamUtils:getTeamAwaking(self._teamData)
    self:updateLeftPanel()
    self:updateRightPanel()
    -- 新逻辑:增加放大镜按钮点击出 cg图 by guojun 
    UIUtils:createShowCGBtn( self:getUI("bg.layer.layer_left") ,{id=self._teamId,isTeam=true,pos = cc.p(240,410)} )
    UIUtils:createHolyDetailBtn( self:getUI("bg.layer.layer_left") ,{teamData = self._teamData,runes = self._runes,pos = cc.p(240,350)} )
    UIUtils:createExclusiveInfoNode(self:getUI("bg.layer.layer_left"), {teamData = self._teamData, pos = cc.p(240, 290)})
end

function RankTeamDetailView:updateLeftPanel()
    --   名字、头像、立汇、小人、动画小人
    --   teamName, art1, art2, art3 ,art4
    local teamName = self._teamTableData.name
    local steam = self._teamTableData.steam
    -- if self._isAwaking then
        teamName,_,_,steam = TeamUtils:getTeamAwakingTab(self._teamData)
    -- end
    local className = TeamUtils:getClassIconNameByTeamD(self._teamData, "classlabel", self._teamTableData)
	self._classType:setBackGroundImage(IconUtils.iconPath .. className .. ".png", 1)
    self._classType:setAnchorPoint(0.5,0.5)
    self._classType:setScaleAnim(true)
    self._classType:setPosition(28,22)
	TeamUtils.showTeamLabelTip(self._classType, 7, self._teamId)
    local quality = self._teamModel:getTeamQualityByStage(self._teamData.stage)
    self._teamName:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
    self._teamName:setString(lang(teamName) .. (0 == quality[2] and "" or  "+" .. quality[2]))

    for i = 1, 6 do
        local star_n = self._starLayer:getChildByFullName("star_n_" .. i)
        local star_d = self._starLayer:getChildByFullName("star_d_" .. i)
        star_d:setVisible(false)
        local imgName = "globalImageUI6_star1.png"
        if i <= self._teamData.star then
            if self._isAwaking and i <= self._awakingLvl then
                imgName = "globalImageUI_teamskillBigStar1.png"
            end
        else            
            imgName = "globalImageUI6_star2.png"
            if self._isAwaking and i <= self._awakingLvl then
                imgName = "globalImageUI_teamskillBigStar2.png"
            end
        end

        star_n:loadTexture(imgName,1)
    end
    
    self._teamImg:loadTexture("asset/uiother/steam/" .. steam .. ".png")
    self._teamImg:setScale(0.8)
    --  team  race$cs   data[1]   race表 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_left.layer_body.image_body_bg")
    local receData = self._teamTableData.race
    local race = tab:Race(receData[1]).pic
    image_body_bg:loadTexture("asset/uiother/race/race_" .. race ..".png")

    local image_body_bottom = self:getUI("bg.layer.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        local filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
        if receData[1] then
            filePath = "asset/uiother/dizuo/teamBgDizuo" .. receData[1] .. ".png"
            if not cc.FileUtils:getInstance():isFileExist(filePath) then
                filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
            end
        end
        image_body_bottom:loadTexture(filePath, 0)
    end

    self:updateTeamEquip()

end
function RankTeamDetailView:updateTeamEquip()
	for k,v in pairs(self._teamTableData.equip) do
        local equipIcon = self._equipPanel:getChildByFullName("equip" .. k)
        local flag = -3   --没有更新 不显示箭头
        local sysEquip = tab:Equipment(v)
       
        local backQuality = self._teamModel:getTeamQualityByStage(self._teamData["es" .. k])

        local param = {teamData = self._teamData, index = k, sysRuneData = sysEquip,isUpdate = flag, quality = backQuality[1], quaAddition = backQuality[2]}
        local iconRune = equipIcon:getChildByFullName("runeIcon")
        if iconRune == nil then 
            iconRune = IconUtils:createTeamRuneIconById(param)
            iconRune:setName("runeIcon")
            iconRune:setScale(0.58)
            iconRune:setAnchorPoint(cc.p(0, 0))
            iconRune:setPosition(cc.p(20,20))
            equipIcon:addChild(iconRune)
        else 
            IconUtils:updateTeamRuneIconByView(iconRune, param)
        end
    end
end
function RankTeamDetailView:updateRightPanel()
	self._fightScore:setString("a" .. self._teamData.score)
	--详细信息
    --  team阵营  data[1]   race表 1，2，3，4
    local raceImg = self._teamInfo1:getChildByFullName("raceImg_bg.raceImg")
    local receData = self._teamTableData.race
    local race = tab:Race(receData[1]).pic
    raceImg:loadTexture("globalUI_teamRace_" .. race ..".png",1)

	local label_zizhi_des = self._teamInfo1:getChildByFullName("label_zizhi_des")
    -- label_zizhi_des:setColor(UIUtils.colorTable.ccUIBaseColor1)
    -- label_zizhi_des:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	local label_fangyu_des = self._teamInfo1:getChildByFullName("label_fangyu_des")
    -- label_fangyu_des:setColor(UIUtils.colorTable.ccUIBaseColor1)
    -- label_fangyu_des:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	local label_gongji_des = self._teamInfo1:getChildByFullName("label_gongji_des")
    -- label_gongji_des:setColor(UIUtils.colorTable.ccUIBaseColor1)
    -- label_gongji_des:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	local label_life_des = self._teamInfo1:getChildByFullName("label_life_des")
    -- label_life_des:setColor(UIUtils.colorTable.ccUIBaseColor1)
    -- label_life_des:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	label_zizhi_des:setString(self._modelMgr:getModel("TeamModel"):getTeamZiZhiText(tonumber(self._teamTableData.zizhi)))
	local tempEquips = {}
    for i=1,4 do
    	local tempEquip = {}
        local equipLevel = self._teamData["el" .. i]
        local equipStage = self._teamData["es" .. i]
        tempEquip.stage = equipStage
        tempEquip.level = equipLevel
        table.insert(tempEquips, tempEquip)
    end

    local backData, backSpeed, atkSpeed = BattleUtils.getTeamBaseAttr(self._teamData, tempEquips, self._pokedexData, nil, nil, nil, nil, nil, self._battleArray, self._pTalents)
	-- dump(backData,"backData===>")
    -- local attr = BattleUtils.getTeamBaseAttr_treasure(self._treasureData)
    local teamModel = self._modelMgr:getModel("TeamModel")
    local volume = teamModel:getTeamVolume(self._teamData)
    local attr = self._modelMgr:getModel("TeamModel"):getOtherTeamTreasure(volume,self._treasureData)
    local treasureAttr = self._teamModel:getOtherTeamTreasureAttrData(self._teamId,self._treasureData)

    -- 获取英雄属性
    -- self._heroData = self._modelMgr:getModel("HeroModel"):getData()
    local heroAttr = self._teamModel:getOtherTeamHeroAttrByTeamId(self._teamId,self._heroData)
    -- 圣徽属性
    local holyData,holyAddAttr = self._teamModel:getStoneAttrByParam(self._teamData.rune,self._runes)
    for i=BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
        backData[i] = backData[i] + 
                      heroAttr[i] + 
                      treasureAttr[i] + 
                      holyData[i] + 
                      holyAddAttr[i]
    end
    --增加圣徽精通 攻击 防御 额外属性
    local holyAtk,holyDef = self:getHolyExtPorp(self._teamData.rune)
    backData[66] = backData[66] + holyAtk
    backData[67] = backData[67] + holyDef

    -- 暂时只加2和5属性
    backData[2] = backData[2] + attr[2]
    backData[5] = backData[5] + attr[5]
    -- 增加宝物属性  17.7.28
    backData[3] = backData[3] + attr[3]
    backData[6] = backData[6] + attr[6]

    --防
    value = backData[7]*(0.01*backData[35]+1)
    value = TeamUtils.getNatureNums(value)    
    label_fangyu_des:setString(value)
    --攻
    value = BattleUtils.getTeamAttackAttr(backData, true)   --getTeamAttackAttr
    local holyValue =  value *((holyData[64]*(100+0.3* holyData[64])/(100+holyData[64]))*0.01)
    value = value + holyValue
    value = TeamUtils.getNatureNums(value)
    label_gongji_des:setString(value)
    --生命
    value = BattleUtils.getTeamHpAttr(backData, true)
    local holyValue = value *(( holyData[65]*(100+0.3* holyData[65])/(100+holyData[65]))*0.01)
    value = value + holyValue
    value = TeamUtils.getNatureNums(value)
    label_life_des:setString(value)

    local showSkill = self._teamModel:getTeamSkillShowSort(self._teamData, true)
    local teamInfoNode = self._teamInfo2
    local iconScale = 0.8
    if #showSkill == 5 then
        teamInfoNode = self._teamInfo3
        iconScale = 0.7
    end
    teamInfoNode:setVisible(true)
    local dazhaoImg = teamInfoNode:getChildByFullName("dazhao")
    dazhaoImg:setZOrder(10)
    dazhaoImg:setVisible(false)
    --展示技能Icon
    local rune = self._teamData.rune
	for i = 1, #showSkill do
        local iconPanel = teamInfoNode:getChildByFullName("layer_skill_icon_" .. i)
        local labelName = iconPanel:getChildByFullName("label_skill_name")
        labelName:setFontName(UIUtils.ttfName)
        labelName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        -- labelName:enableShadow(UIUtils.colorTable.ccUIBaseShadowColor, cc.size(0, -2))
        local labelLevel = iconPanel:getChildByFullName("label_skill_level")
        local imageLocked = iconPanel:getChildByFullName("image_skill_locked")

        local showIndex = showSkill[i]
        local lv = self._teamData["sl" .. showIndex] or 0
        local skillLevel = lv
        local skillType = self._teamTableData.skill[showIndex][1]
        local skillId = self._teamTableData.skill[showIndex][2]
        local skillTableData = SkillUtils:getTeamSkillByType(skillId, skillType)

        --圣徽加成 技能等级
        local rune = self._teamData.rune
        local uSkill = false    -- 是否大招技能加成
        local sSkill = false    -- 是否普通技能加成
        local addLevel = 0      -- 额外增加等级
        if rune and rune.suit and rune.suit["4"] then
            local id,level = TeamUtils:getRuneIdAndLv(rune.suit["4"])
            if id == 104 then
                sSkill = true
                uSkill = true
            end
            if i == 1 then
                if id == 403 then
                    uSkill = true 
                end
            end
            addLevel = level
        end
        labelLevel:setVisible(skillLevel > 0)
        imageLocked:setVisible(skillLevel <= 0)
        -- dump(skillTableData,"skillTableData")
        labelLevel:setString("Lv." .. lv)
        
        if skillLevel > 0 and addLevel > 0 and ((uSkill and i == 1) or (sSkill and i ~= 1)) then
            local addTxt = ccui.Text:create()
            addTxt:setFontName(UIUtils.ttfName)
            addTxt:setFontSize(22)
            addTxt:setAnchorPoint(0,0.5)
            addTxt:setString("(+" .. addLevel ..")")
            addTxt:setColor(UIUtils.colorTable.ccUIBaseColor9)
            addTxt:setPosition(labelLevel:getPositionX()+labelLevel:getContentSize().width,labelLevel:getPositionY())
            iconPanel:addChild(addTxt,2)
        else
            addLevel = 0
        end
        local icon = IconUtils:createTeamSkillIconById({teamSkill = skillTableData, teamData = self._teamData, level = lv,addLevel=addLevel, eventStyle = 1})
        icon:setScale(iconScale)
        icon:setPosition(cc.p(-5, -5))
        iconPanel:addChild(icon)
        labelName:setString(lang(skillTableData.name))
        if skillTableData.dazhao and skillTableData.dazhao == 1 then 
            dazhaoImg:setVisible(true)  
            local dazhaoPos = cc.p(iconPanel:getPositionX()+18, iconPanel:getPositionY()+64)
            if #showSkill == 5 then
                dazhaoPos = cc.p(iconPanel:getPositionX()+18, iconPanel:getPositionY()+55)
            end
            dazhaoImg:setPosition(dazhaoPos)    
            -- 大招跟着icon缩放
            -- local dazhaoImg = ccui.ImageView:create()
            -- dazhaoImg:loadTexture("label_big_skill_hero.png",1)
            -- dazhaoImg:setRotation(-30)
            -- dazhaoImg:setPosition(14,80)  
            -- dazhaoImg:setScale(1.2)
            -- local dazhaoParent = icon:getChildByFullName("boxIcon") or icon
            -- dazhaoParent:addChild(dazhaoImg)     
        end

        local lingyuImg = iconPanel:getChildByFullName("lingyuImg")
        if lingyuImg then
            lingyuImg:setVisible(false)
        end
        if skillTableData.lingyu and skillTableData.lingyu == 1 then
            if not lingyuImg then
                lingyuImg = ccui.ImageView:create()
                lingyuImg:loadTexture("label_big_skill_lingyu.png", 1)
                lingyuImg:setPosition(15, iconPanel:getContentSize().height - 15)
                lingyuImg:setRotation(-25)
                iconPanel:addChild(lingyuImg)
                lingyuImg:setScale(0.85)
            end
            lingyuImg:setVisible(true)
        end
    end

end


--计算圣徽精通额外属性
function RankTeamDetailView:getHolyExtPorp(rune)
    local atk = 0
    local def = 0
    local lv = 0
    if rune then
        for i=1,6 do
            local key = rune[tostring(i)]
            if key and key ~= 0 then
                local stoneData = self._runes[tostring(key)] or self._runes[key]
                lv = lv + stoneData.lv-1
            end
        end
    end
    local tempLv = 0
    for i,tabData in ipairs(tab.runeCastingMastery) do
        if lv < tabData.level then
            tempLv = i - 1
            break
        end
        tempLv = i
    end
    print("========tempLv====",tempLv)
    local rData = tab.runeCastingMastery[tempLv]
    if rData then
        atk = rData.castingMastery[1][2]
        def = rData.castingMastery[2][2]
    end
    return atk,def
end
-- 接收自定义消息
function RankTeamDetailView:reflashUI(data)

end

return RankTeamDetailView