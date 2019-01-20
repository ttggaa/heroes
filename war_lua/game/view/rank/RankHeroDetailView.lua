--
-- Author: huangguofang
-- Date: 2016-07-08 18:08:14
--
local FormationIconView = require("game.view.formation.FormationIconView")
local RankHeroDetailView = class("RankHeroDetailView",BasePopView)
function RankHeroDetailView:ctor(params)
    self.super.ctor(self)

    -- dump(params,"params==>",5)
    self._heroData = params.data.heros or {}
    self._globalSpecial = params.data.globalSpecial
    self._playerLvl = params.data.level or params.data.lvl
    
    local heroData = params.data.heros
    -- dump(heroData.slot,"self._heroData",10)
    self._heroId = heroData and tonumber(heroData.heroId) or 60102
    self._isHaveSpellSkill = false --是否有刻印的法术
    self._spellBooks = params.data.spellBooks
    if heroData and heroData.slot and heroData.slot.sid then
        local id = tonumber(heroData.slot.sid)
        if id > 0 then
            self._isHaveSpellSkill = true
            self._spellId = id
            if not heroData.skillex then 
                if heroData.slot.sLvl then
                    heroData.skillex = {heroData.slot.sid,heroData.slot.s,heroData.slot.sLvl}
                elseif self._spellBooks then
                    local bookLvl = self._spellBooks[tostring(heroData.slot.sid)] and 
                                    self._spellBooks[tostring(heroData.slot.sid)].l or self._spellBooks.l 
                    heroData.skillex = {heroData.slot.sid,heroData.slot.s,bookLvl}
                end
            end 
        end
    end
    if not self._heroId then
        self._heroId = 60102
    end
    self._treasures = params.data.treasures
    self._heroModel = self._modelMgr:getModel("HeroModel")
    local userModel = self._modelMgr:getModel("UserModel")
    -- hab 包含皮肤属性
    self._hAb = params.data.hAb or userModel:getGlobalAttributes()

    self._talentData = params.data.talentData or params.data.talent
    if not self._talentData then
        self._talentData = self._modelMgr:getModel("TalentModel"):getData()
    end
    self._uMastery = params.data.uMastery or userModel:getuMastery()

    self._spTalent = params.data.spTalent
    self._backupData = params.data.backups
    self._pTalents = params.data.pTalents
    -- self._hSkin = params.data.hSkin or userModel:getUserSkinData()
end

-- 初始化UI后会调用, 有需要请覆盖
function RankHeroDetailView:onInit()
	self:registerClickEventByName("bg.layer.btn_close", function()
        self:close()
        UIUtils:reloadLuaFile("rank.RankHeroDetailView")
    end)

    --配表 英雄信息
    self._heroTableData = tab:Hero(tonumber(self._heroId))

    self._title = self:getUI("bg.layer.titleBg.title")
    UIUtils:setTitleFormat(self._title, 1)

    -- left layer
    self._heroName = self:getUI("bg.layer.layer_left.image_info_bg.label_name")
    self._heroName:setFontName(UIUtils.ttfName)
    self._heroName:setColor(UIUtils.colorTable.ccUIBaseColor1)
    self._heroName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    self._classType = self:getUI("bg.layer.layer_left.image_info_bg.layer_class")
    self._classType:setScale(0.6)
    self._heroImg = self:getUI("bg.layer.layer_left.layer_body.heroImg")
    -- self._teamImg:setVisible(false)
    self._starLayer = self:getUI("bg.layer.layer_left.image_info_bg.layer_star")

    self._masteryPanel = self:getUI("bg.layer.layer_left.masteryPanel")

    -- right layer
    self._fightScore = self:getUI("bg.layer.layer_right.fighht_score")
    self._fightScore:setFntFile(UIUtils.bmfName_zhandouli)
    self._fightScore:setScale(0.6)

    self._teamInfo1 = self:getUI("bg.layer.layer_right.team_info_1")
    local label_title1 = self:getUI("bg.layer.layer_right.team_info_1.label_title")
    UIUtils:setTitleFormat(label_title1, 3)
    if not self._isHaveSpellSkill then
        self._teamInfo2 = self:getUI("bg.layer.layer_right.team_info_2")
        self._teamInfo2:setVisible(true)
        local label_title2 = self:getUI("bg.layer.layer_right.team_info_2.label_title")
        UIUtils:setTitleFormat(label_title2, 3)
        self:getUI("bg.layer.layer_right.team_info_keyin"):setVisible(false)
    else
        self._teamInfo2 = self:getUI("bg.layer.layer_right.team_info_keyin")
        self._teamInfo2:setVisible(true)
        local label_title2 = self:getUI("bg.layer.layer_right.team_info_keyin.label_title")
        UIUtils:setTitleFormat(label_title2, 3)
        self:getUI("bg.layer.layer_right.team_info_2"):setVisible(false)
    end
    

    self:updateLeftPanel()
    self:updateRightPanel()
end

function RankHeroDetailView:updateLeftPanel()

	-- self._classType:setBackGroundImage(IconUtils.iconPath .. "h_prof_" .. self._heroTableData.prof ..".png", 1)
    self._classType:setAnchorPoint(0.5,0.5)
    self._classType:setScaleAnim(true)
    self._classType:setPosition(28,22)
	-- TeamUtils.showTeamLabelTip(self._classType, 11, self._heroTableData.prof)
    self._heroName:setString(lang(self._heroTableData.heroname))

    -- 判空处理
    local star = self._heroData and self._heroData.star or 0
    if not star then
        star = 0
    end
    for i = 1, 4 do
        if i <= star then
            self._starLayer:getChildByFullName("star_n_" .. i):setVisible(true)
        else
            self._starLayer:getChildByFullName("star_n_" .. i):setVisible(false)
        end
    end

    local sHero = self._heroTableData.shero
    local heroSkinPort = nil -- 皮肤换立绘
    if self._heroData.skin then
        local skinTableData = tab:HeroSkin(tonumber(self._heroData.skin))
        sHero = skinTableData and skinTableData.shero or sHero
        heroSkinPort = skinTableData and skinTableData.heroport
    end
    self._heroImg:loadTexture("asset/uiother/shero/" .. sHero .. ".png")
    self._heroImg:setScale(0.7)
    -- 新逻辑:增加放大镜按钮点击出 cg图 by guojun
    UIUtils:createShowCGBtn( self:getUI("bg.layer.layer_left") ,{id=self._heroId,isHero=true,heroSkinImgName = heroSkinPort,pos = cc.p(240,410)} )

    -- hero mestery    rece 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_left.layer_body.image_body_bg")
    image_body_bg:loadTexture("asset/uiother/race/race_" .. self._heroTableData.masterytype ..".png")
    local image_body_bottom = self:getUI("bg.layer.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        image_body_bottom:loadTexture("asset/uiother/dizuo/heroDizuo.png", 0)
    end

    --添加专精icon
    self:updateHeroMastery()

end

function RankHeroDetailView:updateHeroMastery()
    local x = 31
    local y = 30
	for i=1, 4 do
        local iconGrid = self._masteryPanel:getChildByFullName("mastery" .. i)
        -- iconGrid:setEnabled(true)
        iconGrid:setVisible(true)
        iconGrid:setScaleAnim(true)
        iconGrid:setAnchorPoint(0.5,0.5)
        iconGrid:setPosition(x,y)
        x = x + iconGrid:getContentSize().width + 6
        if self._heroData["m" .. i] then           
            local levelTxt = iconGrid:getChildByFullName("level")
            levelTxt:setFontSize(16)
            levelTxt:setFontName(UIUtils.ttfName)
            local icon = iconGrid:getChildByFullName("masteryIcon")
            if not icon then
                icon = FormationIconView.new({ iconType = FormationIconView.kIconTypeHeroMastery, iconId = self._heroData["m" .. i], container = { _container = self }, })
                icon:setScale(0.9)
                icon:setTouchEnabled(false)
                icon:setPosition(iconGrid:getContentSize().width / 2, iconGrid:getContentSize().height / 2)
                icon:setName("masteryIcon")
                iconGrid:addChild(icon)
            end 
            icon = iconGrid:getChildByFullName("masteryIcon")
            icon:setIconType(FormationIconView.kIconTypeHeroMastery)
            icon:setIconId(self._heroData["m" .. i])
            icon:updateIconInformation()
            self:registerClickEvent(iconGrid, function(x, y)
                -- print("----------------------------------------")
                self:showHintView("global.GlobalTipView",{tipType = 2, node = iconGrid, id = tonumber(self._heroData["m" .. i]), des = BattleUtils.getDescription(18, tonumber(self._heroData["m" .. i]), BattleUtils.getHeroAttributes(self._heroData)),posCenter = true})
                
            end)
            
            local dataCurrent = tab:HeroMastery(self._heroData["m" .. i])
            local currentLv = dataCurrent.masterylv
            local color = nil
            local outlineColor = UIUtils.colorTable.ccUIBaseOutlineColor
            local levelName = nil
            if 1 == currentLv then
                color = UIUtils.colorTable.ccUIBaseColor2
                levelName = "初级"
            elseif 2 == currentLv then
                color = UIUtils.colorTable.ccUIBaseColor3
                levelName = "中级"
            elseif 3 == currentLv then
                color = UIUtils.colorTable.ccUIBaseColor4
                levelName = "高级"
            end
            if levelName then
                levelTxt:setString(levelName)    
            end
            levelTxt:setColor(color)
            if outlineColor then
                levelTxt:enableOutline(outlineColor, 2)
            else
                levelTxt:disableEffect()
            end
        else
            iconGrid:setVisible(false)
        end
    end
end

function RankHeroDetailView:onIconPressOn(node, iconType, iconId)
    -- print("onIconPressOn")
    iconType = node.getIconType and node:getIconType() or iconType
    iconId = node.getIconId and node:getIconId() or iconId
 
    self:showHintView("global.GlobalTipView",{tipType = 2, node = node, id = iconId, des = BattleUtils.getDescription(iconType, iconId, self._attributeValues),center = true})
   -- self:showHintView("global.GlobalTipView",{tipType = 2, node = iconGrid, id = tonumber(self._heroData["m" .. i]), des = BattleUtils.getDescription(18, tonumber(self._heroData["m" .. i]), BattleUtils.getHeroAttributes(self._heroData)),center = true})
end

function RankHeroDetailView:updateRightPanel()
    local score = self._heroData.score or 0
	self._fightScore:setString("a" .. score)

 --    self._heroData = params.data.heros
 --    self._globalSpecial = params.data.globalSpecial
 --    self._playerLvl = params.data.level
 --    -- dump(self._heroData,"self._heroData")
 --    self._heroId = tonumber(params.data.heros.heroId)
 --    self._treasures = params.data.treasures
-- getRankHeroAttributes(playerLvl,heroData,,globalSpecial,treasureData)
    -- dump(self._globalSpecial,"self._globalSpecial")
    if not self._globalSpecial then
        self._globalSpecial = {}
    else
        self._globalSpecial = json.decode(self._globalSpecial)
    end

    local attrData = BattleUtils.getRankHeroAttributes(self._playerLvl,
                                                        self._heroData,
                                                        self._globalSpecial,
                                                        self._treasures,
                                                        self._talentData,
                                                        self._hAb,
                                                        self._uMastery,
                                                        self._backupData,
                                                        self._pTalents)
    -- dump(attrData,"attrData==>>")
	--详细信息
    local information = self._teamInfo1:getChildByFullName("information")
    --[[
	local gongjiTxt = information:getChildByFullName("gongjiTxt")
    local gongjiAdd = information:getChildByFullName("gongjiAdd")
	local zhishiTxt = information:getChildByFullName("zhishiTxt")
    local zhishiAdd = information:getChildByFullName("zhishiAdd")
	local fangyuTxt = information:getChildByFullName("fangyuTxt")
    local fangyuAdd = information:getChildByFullName("fangyuAdd")
	local zhiliTxt = information:getChildByFullName("zhiliTxt")
    local zhiliAdd = information:getChildByFullName("zhiliAdd")

    gongjiAdd:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    zhishiAdd:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    fangyuAdd:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    zhiliAdd:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    --]]

    -- 全局英雄属性
    self._attValue1 = information:getChildByFullName("gongjiTxt")
    self._attValue2 = information:getChildByFullName("fangyuTxt")
    self._attValue3 = information:getChildByFullName("zhiliTxt")
    self._attValue4 = information:getChildByFullName("zhishiTxt")

    -- local skinAtt = self._heroModel:getHeroSkinAttr(self._hSkin)
    local changeMap = {[1] = "atk",[2] = "def", [3]="int",[4] = "ack"}
    -- local starAttr = self._modelMgr:getModel("UserModel"):getStarHeroAttr() or {}
    -- local starAttrKey = {[1] = "110",[2] = "113", [3]="116",[4] = "119"}
    -- for i=1,4 do
    --     if attrData[changeMap[i]] then
    --         attrData[changeMap[i]] = attrData[changeMap[i]] + skinAtt[changeMap[i]]
    --     else
    --         attrData[changeMap[i]] = skinAtt[changeMap[i]]
    --     end
    -- end

    for i=1,4 do
        if attrData[changeMap[i]] then
            self["_attValue" .. i]:setString(string.format("%.01f",attrData[changeMap[i]]))
        else
            -- print("=========heroDetail hAb===========",i)
            self["_attValue" .. i]:setString(0)
        end
    end

    --[[
    self._attImg1 = information:getChildByFullName("fangyu")
    self._attImg2 = information:getChildByFullName("zhili")
    self._attTxt1 = information:getChildByFullName("fangyu.des_txt")
    self._attTxt2 = information:getChildByFullName("zhili.des_txt")
    self._attValue1 = information:getChildByFullName("fangyuTxt")
    self._attValue2 = information:getChildByFullName("zhiliTxt")    
    self._attAddition1 = information:getChildByFullName("fangyuAdd")
    self._attAddition2 = information:getChildByFullName("zhiliAdd")

    local attributes = {"atk", "def", "int", "ack"}
    local attributesName = {atk = "攻击：", def = "防御：", int = "智力：", ack = "知识："}
    local index = 1
    local star = self._heroData.star
    local heroTableData = self._heroTableData
    -- local heroMaxStar = tab:Setting("G_HERO_MAX_STAR").value
    for _, att in ipairs(attributes) do
        if heroTableData[att] then
            local attImg = att .. ".png"
            if att == "ack" then
                attImg = "zhishi.png"
            end
            local value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]  --(star - self._heroTableData.star)
            self["_attImg" .. index]:loadTexture(attImg, 1)
            self["_attTxt" .. index]:setString(attributesName[att])

            self["_attValue" .. index]:setString(string.format("%d", value))
            if attrData[att] then
                local addition = attrData[att] - value      
                -- print(att,"=====================attrData[att]===",attrData[att])      
                self["_attAddition" .. index]:setVisible(addition > 0)

                self["_attAddition" .. index]:setPositionX(self["_attValue" .. index]:getPositionX() + self["_attValue" .. index]:getContentSize().width+5)
                self["_attAddition" .. index]:setString(string.format("+%d", math.ceil(addition)))
            end
            index = math.min(index + 1, 2)
        end
    end
    ]]

    --[[
    -- 添加额外加成显示
    local star = self._heroData.star
    -- self._heroTableData
    --攻击
    local value = self._heroTableData.atk[1] + (star - self._heroTableData.star) * self._heroTableData.atk[2]
    local addition = attrData.atk - value
    gongjiTxt:setString(string.format("%d", value))
    gongjiAdd:setVisible(addition > 0)
    gongjiAdd:setPositionX(gongjiTxt:getPositionX() + gongjiTxt:getContentSize().width)
    gongjiAdd:setString(string.format("+%d", math.ceil(addition)))

    --防御
    value = self._heroTableData.def[1] + (star - self._heroTableData.star) * self._heroTableData.def[2]
    addition = attrData.def - value
    fangyuTxt:setString(string.format("%d", value))
    fangyuAdd:setVisible(addition > 0)
    fangyuAdd:setPositionX(fangyuTxt:getPositionX() + fangyuTxt:getContentSize().width)
    fangyuAdd:setString(string.format("+%d", math.ceil(addition)))
    
    -- --智力
    value = self._heroTableData.int[1] + (star - self._heroTableData.star) * self._heroTableData.int[2]
    addition = attrData.int - value
    zhiliTxt:setString(string.format("%d", value))
    zhiliAdd:setVisible(addition > 0)
    zhiliAdd:setPositionX(zhiliTxt:getPositionX() + zhiliTxt:getContentSize().width)
    zhiliAdd:setString(string.format("+%d", math.ceil(addition)))

    --知识
    value = self._heroTableData.ack[1] + (star - self._heroTableData.star) * self._heroTableData.ack[2]
    addition = attrData.ack - value
    zhishiTxt:setString(string.format("%d", value))
    zhishiAdd:setVisible(addition > 0)
    zhishiAdd:setPositionX(zhishiTxt:getPositionX() + zhishiTxt:getContentSize().width)
    zhishiAdd:setString(string.format("+%d", math.ceil(addition)))
    --]]

    local specialBg = self._teamInfo1:getChildByFullName("specialBg") 
    local heroSpecialtyData = clone(self._heroData)
    if tonumber(heroSpecialtyData.star) > 0 then
        specialBg:setVisible(true)
        local layer_specialty = specialBg:getChildByFullName("layer_specialty")
        -- layer_specialty:setTouchEnabled(true)
        local label_specialty_name = specialBg:getChildByFullName("label_specialty_name")
        label_specialty_name:setString(lang("HEROSPECIAL_" .. self._heroTableData.special))
        label_specialty_name:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        -- label_specialty_name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)


        local findHeroSpecialFirstEffectData = function(specialBaseId)
            local specialTableData = clone(tab.heroMastery)
            for k, v in pairs(specialTableData) do
                if 1 == v.class and specialBaseId == v.baseid then
                    return v
                end
            end
        end
        --专长图标
        local heroMasteryData = findHeroSpecialFirstEffectData(self._heroTableData.special)
        layer_specialty:setSwallowTouches(false)
        layer_specialty:setBackGroundImage(IconUtils.iconPath .. heroMasteryData.icon .. ".jpg", 1)
        
        heroSpecialtyData.special = self._heroTableData.special
        layer_specialty.tipOffset = cc.p(-365, 0)
        specialBg:setScaleAnim(true)
        self:registerClickEvent(specialBg, function(x, y)
            -- self:showSpecialtyTip(layer_specialty, heroSpecialtyData)
            self:showHintView("global.GlobalTipView",{tipType = 2, node = layer_specialty, id = heroSpecialtyData.special, heroData = heroSpecialtyData})
        end)

        --当前专长星级
        local image_specialty_frame = specialBg:getChildByFullName("image_specialty_frame")
        local starImg = ccui.ImageView:create()
        starImg:loadTexture("globalImageUI_heroStar" .. heroSpecialtyData.star .. ".png",1)
        starImg:setAnchorPoint(cc.p(0.5,0))
        starImg:setPosition(image_specialty_frame:getContentSize().width/2,5)
        image_specialty_frame:addChild(starImg)
    else
        specialBg:setVisible(false)
    end
    if self._isHaveSpellSkill then
        self:updateHeroSkillDetail2()
    else
        self:updateHeroSkillDetail1()
    end
end

--[[
    右下角英雄法术(有刻印)
]]
function RankHeroDetailView:updateHeroSkillDetail2()
    for i = 1, 5 do

        local _skillID = self._heroTableData.spell[i]
        if i <= 4 then            
            local isReplaced, skillReplacedId = self._heroModel:isSpellReplacedByData(tonumber(self._heroTableData.id), _skillID,self._heroData)
            if isReplaced then
                _skillID = skillReplacedId
            end
        else
            _skillID = self._spellId
        end
        if not tab:PlayerSkillEffect(_skillID) then
            local bookLvl = self._heroData.slot and self._heroData.slot.sLvl 
            if not bookLvl and self._spellBooks then
                bookLvl = self._spellBooks.l or (self._spellBooks and self._spellBooks[tostring(_skillID)] and self._spellBooks[tostring(_skillID)].l)
            end
            if bookLvl and bookLvl > 1 then
                _skillID = tonumber(_skillID .. (bookLvl-1))
            end
        end
        local skillData = tab:PlayerSkillEffect(_skillID) or tab:HeroMastery(_skillID)
        local iconParent = self._teamInfo2:getChildByFullName("layer_skill_icon_" .. i)
        local iconBg = iconParent:getChildByFullName("skill_icon_bg")

        local lableName = iconParent:getChildByFullName("label_skill_name")
        local labelLevel = iconParent:getChildByFullName("label_skill_level")
        local icon = ccui.ImageView:create()
        icon:loadTexture(IconUtils.iconPath .. (skillData.art or skillData.icon) .. ".png",1)
        icon:setScale(0.9)
        icon:setAnchorPoint(0.5,0.5)
        icon:setPosition(iconBg:getContentSize().width*0.5, iconBg:getContentSize().height*0.5)
        iconBg:addChild(icon,-1)
        iconBg:setScaleAnim(true)
        self:registerTouchEvent(iconBg, function(x, y)
            local attrData = BattleUtils.getRankHeroAttributes(self._playerLvl,self._heroData,self._globalSpecial,self._treasures)
            local skillLevel = i == 5 and self._heroData.slot and self._heroData.slot.sLvl or nil
            local slotMastery = i == 5 and tab.heroMastery[skillData.id or 0]
            local stage = i == 5 and self._heroData.slot and self._heroData.slot.s or nil
            self:showHintView("global.GlobalTipView",{
                tipType = 2, 
                node = iconParent, 
                id = skillData.id, 
                heroData = not slotMastery and clone(self._heroData),
                attributes = attrData, 
                skillLevel = skillLevel,
                sklevel = stage,
                posCenter = true,
                spTalent = self._spTalent
            })
        end)
        local skillType = skillData.type
        
        lableName:setColor(UIUtils.colorTable["ccUIHeroSkillColor" .. skillType])
        lableName:setString(lang(skillData.name))
        lableName:setFontSize(16)
        local level = i <= 4 and self._heroData["sl" .. i] or self._heroData.slot.s
        labelLevel:setString(level .. "阶")
        labelLevel:setPositionX(lableName:getPositionX()+lableName:getContentSize().width)
        labelLevel:setFontSize(16)
    end
end

--[[
    右下角英雄法术(无刻印)
]]
function RankHeroDetailView:updateHeroSkillDetail1()
    --大招
    local dazhaoImg = self._teamInfo2:getChildByFullName("dazhao")
    dazhaoImg:setZOrder(10)
    dazhaoImg:setVisible(false)
    for i = 1, 4 do
        local _skillID = self._heroTableData.spell[i]
        local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(self._heroTableData.id), _skillID)
        if isReplaced then
            _skillID = skillReplacedId
        end
        local skillData = tab:PlayerSkillEffect(_skillID)
        local iconParent = self._teamInfo2:getChildByFullName("layer_skill_icon_" .. i)
        local iconBg = iconParent:getChildByFullName("skill_icon_bg")

        local lableName = iconParent:getChildByFullName("label_skill_name")
        -- lableName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        -- lableName:enableShadow(UIUtils.colorTable.ccUIBaseShadowColor, cc.size(0, -2))
        local labelLevel = iconParent:getChildByFullName("label_skill_level")
        local icon = ccui.ImageView:create()
        icon:loadTexture(IconUtils.iconPath .. skillData.art .. ".png",1)
        icon:setScale(0.97)
        icon:setPosition(iconBg:getPositionX()+7, iconBg:getPositionY()+7)
        iconBg:addChild(icon,-1)
        iconBg:setScaleAnim(true)
        self:registerTouchEvent(iconBg, function(x, y)
            -- self:onIconPressOn(iconParent, skillData.id, clone(heroData))     
            local attrData = BattleUtils.getRankHeroAttributes(self._playerLvl,self._heroData,self._globalSpecial,self._treasures)
            self:showHintView("global.GlobalTipView",{tipType = 2, node = iconParent, id = skillData.id, heroData = clone(self._heroData), attributes = attrData, posCenter = true,spTalent = self._spTalent})
        end)
        local skillType = skillData.type
        
        lableName:setColor(UIUtils.colorTable["ccUIHeroSkillColor" .. skillType])
        lableName:setString(lang(skillData.name))
        lableName:setFontSize(22)
        labelLevel:setString(self._heroData["sl" .. i] .. "阶")

        if i == 4 then
            icon:setPosition(48, 48)
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+15, iconParent:getPositionY()+60)         
        end
    end
end

function RankHeroDetailView:startClock(node, iconId, heroData)
    -- if self._timer_id then self:endClock() end
    -- self._first_tick = true
    -- self._timer_id = self._scheduler:scheduleScriptFunc(function()
    --     if not self._first_tick then return end
    --     self._first_tick = false
    self:onIconPressOn(node, iconId, heroData)
    -- end, 0.2, false)
end

function RankHeroDetailView:endClock()
   -- if self._timer_id then 
   --      self._scheduler:unscheduleScriptEntry(self._timer_id)
   --      self._timer_id = nil
   --  end
    -- self:onIconPressOff()
end

-- 接收自定义消息
function RankHeroDetailView:reflashUI(data)

end

function RankHeroDetailView.dtor( ... )
    -- body
    FormationIconView = nil
end

return RankHeroDetailView