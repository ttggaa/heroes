--[[
    Filename:    HeroUnlockView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-03-12 15:14:15
    Description: File description
--]]

local mcMgr = mcMgr
local HeroUnlockView = class("HeroUnlockView", BaseLayer)
local sfc = cc.SpriteFrameCache:getInstance()
local tc = cc.Director:getInstance():getTextureCache() 
HeroUnlockView.kBgScale = 1.38

function HeroUnlockView:ctor(params)
    HeroUnlockView.super.ctor(self)
    self._heroId = params.heroId
    self._callBack = params.callBack
    self._modelMgr = ModelManager:getInstance()
    self._heroModel = self._modelMgr:getModel("HeroModel")
end

function HeroUnlockView:disableTextEffect(element)
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

function HeroUnlockView:resetLabel( root )
    if true then return end
    if root == nil then 
        root = self._widget 
    end
    local desc = root:getDescription()
    if desc == "Label" then
        local str = root:getName()
        if str then
            if str == "label_title" then
                -- root:setColor(cc.c3b(117, 255, 239))
                -- root:enableOutline(cc.c4b(0, 81, 65, 255),1)
            elseif str == "label_hero_name" then
                root:setColor(cc.c3b(255, 255, 255))
                root:enable2Color(1,cc.c4b(227, 159, 7, 255))
                root:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
                root:setFontName(UIUtils.ttfName)
                root:setFontSize(24)
            -- else
            --     root:enableOutline(cc.c4b(0, 68, 55, 255),2)
            end
        end
    end
    local children = root:getChildren()
    for k,v in pairs(children) do
        self:resetLabel(v)
    end
end

function HeroUnlockView:onInit()
    self:disableTextEffect()
    self:setFullScreen()
    self:resetLabel()

    audioMgr:playSound("NewHero")

    -- 手动管理hero 图
    local tc = cc.Director:getInstance():getTextureCache() 
    if not tc:getTextureForKey("d_Mephala.png") then
        sfc:addSpriteFrames("asset/ui/hero1.plist", "asset/ui/hero1.png")
        sfc:addSpriteFrames("asset/ui/hero.plist", "asset/ui/hero.png")
        self._toDelSprites = true
    end


    --share  by wangyan
    local shareBtn = self:getUI("bg.layer.shareBtn")
    self._shareNode = require("game.view.share.GlobalShareBtnNode").new({mType = "ShareHeroModule", curType = 1})
    self._shareNode:setPosition(ADOPT_IPHONEX and 200 or 100, 62)
    self._shareNode:setCascadeOpacityEnabled(true, true)
    self:addChild(self._shareNode, 20)

    local heroTableData = tab:Hero(self._heroId)
    self._bg0 = self:getUI("bg0")
    self._bg = self:getUI("bg")
    self._imageBg = ccui.ImageView:create("asset/bg/bg_showCard.jpg")
    self._imageBg:setBrightness(-30)
    self._imageBg:setPosition(cc.p(self._bg0:getContentSize().width / 2, self._bg0:getContentSize().height / 2))
    self._imageBg:setScale(HeroUnlockView.kBgScale)
    self._bg0:addChild(self._imageBg)

    -- 重新设置cocostudio 元素 by guojun
    self._skill_icon_bg = self:getUI("bg.layer.image_skill_bg.layer_skill_icon_4.skill_icon_bg")
    self._skill_icon_bg:loadTexture("hero_skill_bg1_forma.png",1)
    self._skill_icon_bg:setScale(0.88)
    
    self._image_big_skill = self:getUI("bg.layer.image_skill_bg.layer_skill_icon_4.image_big_skill")
    self._image_big_skill:loadTexture("label_big_skill_hero.png",1)
    self._image_big_skill:setPositionX(35)
    self._image_specialty_frame = self:getUI("bg.layer.image_specialty_bg.image_specialty_frame")
    self._image_specialty_frame:loadTexture("globalImageUI4_squality3.png",1)
    
    self._titleImg = self:getUI("bg.layer.image_title")
    local titleMc = mcMgr:createViewMC("jingjichangpaimingshanguang_commonwin", true)
    titleMc:setPlaySpeed(1, true)
    --titleMc:setPosition(self._bg:getContentSize().width / 2 + 10, self._bg:getContentSize().height / 2 - 55)
    titleMc:setPosition(self._titleImg:getContentSize().width / 2, self._titleImg:getContentSize().height / 2+25)
    titleMc:setScale(3,0.3)
    -- titleMc:setPlaySpeed(0.5)
    self._titleImg:addChild(titleMc, 4)
    titleMc:setCascadeOpacityEnabled(true,true)
    -- self._titleImg:loadTexture("title_gongxihuode.png",1)

    self._layer = self:getUI("bg.layer")
    self._layer:setVisible(false)
    self._offsetX = (MAX_SCREEN_WIDTH-1136)/2
    self._layer:setPositionX(self._offsetX)
    self._labelHeroName = self:getUI("bg.layer.label_hero_name")
    self._labelHeroName:loadTexture(heroTableData.heromp .. ".png",1)
    -- self._labelHeroName:setString(lang(heroTableData.heroname))
    -- self._labelHeroName:setFontSize(28)
    -- self._labelHeroName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2) 
    self._labelHeroBody = self:getUI("bg.layer.layer_hero_body")
    local heroBody = ccui.ImageView:create("asset/uiother/shero/" .. heroTableData.shero .. ".png")
    heroBody:setScale(0.75)
    heroBody:setAnchorPoint(0.5,0)
    heroBody:setPosition(self._labelHeroBody:getContentSize().width / 2, 0)
    self._labelHeroBody:addChild(heroBody, 10)
    self._heroBody  = heroBody
    --[[
    self._skillTitle = self:getUI("bg.layer.image_skill_bg.label_title")
    self._skillTitle:setFontName(UIUtils.ttfName)
    self._skillIcon = {}
    for i = 1, 5 do
        local skillData = tab:PlayerSkillEffect(heroTableData["spell" .. i])
        self._skillIcon[i] = self:getUI("bg.layer.image_skill_bg.layer_skill_icon_" .. i)
        local icon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. skillData.art .. ".png")
        icon:setScale(0.8)
        icon:setPosition(self._skillIcon[i]:getContentSize().width / 2, self._skillIcon[i]:getContentSize().height / 2)
        self._skillIcon[i]:addChild(icon)
    end
    ]] 

    self._desTitle = self:getUI("bg.layer.image_des_bg.label_title")
    self._desTitle:setFontName(UIUtils.ttfName)
    self._desTitle:enableOutline(cc.c4b(0, 81, 65), 1)
    self._labelHeroDes = self:getUI("bg.layer.image_des_bg.label_hero_des")
    local labelDescription = self._labelHeroDes
    local desc = "[color=aaa082, fontsize=16]" .. lang(heroTableData.herodes) .. "[-]"
    local richText = labelDescription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDescription:getContentSize().width, labelDescription:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDescription:getContentSize().width / 2, labelDescription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDescription:addChild(richText)
    --[[
    self._posDesTitle = self:getUI("bg.layer.image_pos_des_bg.label_title")
    self._posDesTitle:setFontName(UIUtils.ttfName)
    self._posDesTitle:enableOutline(cc.c4b(0, 81, 65), 2)
    self._labelPosHeroDes = self:getUI("bg.layer.image_pos_des_bg.label_hero_des")
    local labelDescription = self._labelPosHeroDes
    local desc = "[color=ffffff, fontsize=18, outlinecolor=3C1E0A, outlinesize=1]" .. lang("HEROSPECIALDES_" ..  heroTableData.special) .. "[-]"
    local richText = labelDescription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDescription:getContentSize().width, labelDescription:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDescription:getContentSize().width / 2, labelDescription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDescription:addChild(richText)
    ]]

    self._posDes = self:getUI("bg.layer.label_hero_pos")
    self._posDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1) 
    self._posDes:enable2Color(1,cc.c4b(227, 159, 7, 255))
    self._posDes:setString(lang("HEROSPECIALDES_" ..  heroTableData.special))

    self._skillTitle = self:getUI("bg.layer.image_skill_bg.label_title")
    self._skillTitle:setFontName(UIUtils.ttfName)
    self._skillIcon = self:getUI("bg.layer.image_skill_bg.layer_skill_icon_4")
    local skillData = tab:PlayerSkillEffect(heroTableData.spell[4])
    local icon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. skillData.art .. ".png")
    icon:setScale(0.8)
    icon:setPosition(self._skillIcon:getContentSize().width / 2, self._skillIcon:getContentSize().height / 2)
    self._skillIcon:addChild(icon)
    self._skillDes = self:getUI("bg.layer.image_skill_bg.label_skill_des")
    local labelDescription = self._skillDes
    local desc = "[color=aaa082, fontsize=16]" .. lang("PLAYERSKILLDES4_" .. heroTableData.spell[4]) .. "[-]"
    local richText = labelDescription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDescription:getContentSize().width, labelDescription:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDescription:getContentSize().width / 2, labelDescription:getContentSize().height - richText:getInnerSize().height / 2-10)
    richText:setName("descRichText")
    labelDescription:addChild(richText)

    self._specialtyTitle = self:getUI("bg.layer.image_specialty_bg.label_title")
    self._specialtyTitle:setFontName(UIUtils.ttfName)
    -- self._specialtyTitle:enableOutline(cc.c4b(0, 81, 65), 1)

    self._specialtyName = self:getUI("bg.layer.image_specialty_bg.label_specialty_name")
    -- self._specialtyName:enableOutline(cc.c4b(60, 30, 10), 1)
    self._specialtyName:setString(lang("HEROSPECIAL_" .. heroTableData.special))

    local findHeroSpecialFirstEffectData = function(specialBaseId)
        local specialTableData = clone(tab.heroMastery)
        for k, v in pairs(specialTableData) do
            if 1 == v.class and specialBaseId == v.baseid then
                return v
            end
        end
    end

    local heroMasteryData = findHeroSpecialFirstEffectData(heroTableData.special)
    self._layerSpecialty = self:getUI("bg.layer.image_specialty_bg.layer_specialty")
    self._layerSpecialty:ignoreContentAdaptWithSize(false)
    self._layerSpecialty:loadTexture(IconUtils.iconPath .. heroMasteryData.icon .. ".jpg", 1)
    self._layerSpecialty:setContentSize(cc.size(100,100))
    -- self._layerSpecialty:setBackGroundImage(IconUtils.iconPath .. heroMasteryData.icon .. ".jpg")

    self._attributeTitle = self:getUI("bg.layer.image_attribute_bg.label_title")
    self._attributeTitle:setFontName(UIUtils.ttfName)

    self._label_hero_star = self:getUI("bg.layer.label_hero_star")
    if heroTableData and heroTableData.star > 0 then
        self._label_hero_star:loadTexture("globalImageUI6_star5.png",1)
    else
        self._label_hero_star:setVisible(false)
    end
    -- self._attributeTitle:enableOutline(cc.c4b(0, 81, 65), 1)
    --[[
    self._labelAtk = self:getUI("bg.layer.image_attribute_bg.layer_atk_icon.label_atk")
    self._labelAtk:enableOutline(cc.c4b(60, 30, 10), 1)
    self._labelAtkValue = self:getUI("bg.layer.image_attribute_bg.layer_atk_icon.label_atk_value")
    self._labelAtkValue:enableOutline(cc.c4b(60, 30, 10), 1)
    self._labelAtkValue:setString(heroTableData.atk[1])
    self._labelDef = self:getUI("bg.layer.image_attribute_bg.layer_def_icon.label_def")
    self._labelDef:enableOutline(cc.c4b(60, 30, 10), 1)
    self._labelDefValue = self:getUI("bg.layer.image_attribute_bg.layer_def_icon.label_def_value")
    self._labelDefValue:enableOutline(cc.c4b(60, 30, 10), 1)
    self._labelDefValue:setString(heroTableData.def[1])
    self._labelInt = self:getUI("bg.layer.image_attribute_bg.layer_int_icon.label_int")
    self._labelInt:enableOutline(cc.c4b(60, 30, 10), 1)
    self._labelIntValue = self:getUI("bg.layer.image_attribute_bg.layer_int_icon.label_int_value")
    self._labelIntValue:enableOutline(cc.c4b(60, 30, 10), 1)
    self._labelIntValue:setString(heroTableData.int[1])
    self._labelAck = self:getUI("bg.layer.image_attribute_bg.layer_ack_icon.label_ack")
    self._labelAck:enableOutline(cc.c4b(60, 30, 10), 1)
    self._labelAckValue = self:getUI("bg.layer.image_attribute_bg.layer_ack_icon.label_ack_value")
    self._labelAckValue:enableOutline(cc.c4b(60, 30, 10), 1)
    self._labelAckValue:setString(heroTableData.ack[1])
    ]]
    --[[
    self._labelContinue = self:getUI("bg.layer.label_continue")
    self._labelContinue:enableOutline(cc.c4b(60, 30, 10), 1)
    ]]
    self:showCardAnim(function( )
        mcMgr:loadRes("herounlockanim", function()
            -- local backgroundMC = mcMgr:createViewMC("beijing_herounlockanim", true)
            -- backgroundMC:setPlaySpeed(1, true)
            -- --backgroundMC:setPosition(self._bg:getContentSize().width / 2 + 10, self._bg:getContentSize().height / 2 - 55)
            -- backgroundMC:setPosition(self._bg:getContentSize().width / 2, self._bg:getContentSize().height / 2)
            -- self._bg:addChild(backgroundMC, 5)

            ScheduleMgr:delayCall(0, self, function()
                if not self._bg then return end
                local bottomMC = mcMgr:createViewMC("choukahuodeguang_flashchoukahuode", true)
                bottomMC:setPlaySpeed(1, true)
                --bottomMC:setPosition(self._bg:getContentSize().width / 2 + 10, self._bg:getContentSize().height / 2 - 55)
                bottomMC:setPosition(self._layer:getContentSize().width / 2-self._offsetX, self._layer:getContentSize().height / 2-25)
                self._layer:addChild(bottomMC, 4)

                -- local lightMC = mcMgr:createViewMC("guangxian_herounlockanim", true)
                -- lightMC:setPlaySpeed(1, true)
                -- --lightMC:setPosition(self._bg:getContentSize().width / 2 + 10, self._bg:getContentSize().height / 2 - 55)
                -- lightMC:setPosition(self._bg:getContentSize().width / 2, self._bg:getContentSize().height / 2.5 - 5)
                -- self._bg:addChild(lightMC, 50)
            end)

            -- local foregroundMC = mcMgr:createViewMC("guangxiao_herounlockanim", false)
            -- foregroundMC:addEndCallback(function ()
            --     foregroundMC:stop()
            -- end)
            -- foregroundMC:gotoAndPlay(0)
            -- --foregroundMC:setPosition(self._bg:getContentSize().width / 2 + 10, self._bg:getContentSize().height / 2 - 55)
            -- foregroundMC:setPosition(self._bg:getContentSize().width / 2, self._bg:getContentSize().height / 2)
            -- self._bg:addChild(foregroundMC, 5)

            -- self._imageBg:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveBy:create(0.1, cc.p(0, 0)), cc.ScaleTo:create(0.1, 1.5 * HeroUnlockView.kBgScale)), cc.ScaleTo:create(0.1, HeroUnlockView.kBgScale)))

            ScheduleMgr:delayCall(0, self, function()
                if self._layer then
                    self._layer:setVisible(true)
                    self._layer:setCascadeOpacityEnabled(true,true)
                    self._layer:setOpacity(0)
                    self._layer:runAction(cc.FadeIn:create(0.2))
                end
            end)
        end)
    end)

    self:registerClickEvent(self._layer, function()
        self:retain()
        if self._callBack and type(self._callBack) == "function" then
            self._callBack()
            if heroTableData.zuhe then
                DialogUtils.showZuHe(tonumber(self._heroId))
            end
        end
        if self._toDelSprites then
            cc.Director:getInstance():getTextureCache():removeTextureForKey("hero.png")
        end
        self:removeFromParentAndCleanup()
        self:release()
    end)

    if self._heroId == 60102 then
        self._shareNode:setVisible(false)
    end
    self._shareNode:registerClick(function()
        return {moduleName = "ShareHeroModule", heroId = self._heroId, isHideBtn = true}
        end)
end

-- 增加卡牌界面
function HeroUnlockView:showCardAnim( callback )
    local mcCardShow = mcMgr:createViewMC( "huodeyingxiong_huodeyingxiongui", false, false, function (_, sender)
        -- self:close()
        -- UIUtils:reloadLuaFile("league.LeagueOpenFlyView")
    end,RGBA8888)
    mcCardShow:setPosition(568+self._offsetX,320)
    -- mcCardShow:gotoAndStop(30)
    mcCardShow:addCallbackAtFrame(40,function( )
        if not self._card then
            self._card = CardUtils:createHeroDuelHeroCard({heroD = clone(tab.hero[self._heroId])})
            self._card:setScale(1.29)
            self._bg:addChild(self._card,90)
            -- local itemIconLayout = ccui.LayoutComponent:bindLayoutComponent(self._card)
            -- itemIconLayout:setHorizontalEdge(ccui.LayoutComponent.HorizontalEdge.Center)
            -- itemIconLayout:setVerticalEdge(ccui.LayoutComponent.VerticalEdge.Center)
            -- itemIconLayout:setStretchWidthEnabled(false)
            -- itemIconLayout:setStretchHeightEnabled(false)
            -- itemIconLayout:setSize(self._card:getContentSize())
            -- itemIconLayout:setLeftMargin(0)
            -- itemIconLayout:setTopMargin(0)
            self._card:setPosition(572+self._offsetX,315)
            self._card:setCascadeOpacityEnabled(true,true)
            self._card:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.8),
                cc.ScaleTo:create(0.15,1.54),
                cc.Spawn:create(
                    cc.FadeOut:create(0.2),
                    cc.ScaleTo:create(0.2,0.77)
                ),
                -- cc.DelayTime:create(0.8),
                cc.CallFunc:create(function(  )
                    self._heroBody:setBrightness(100)
                    local brigthness = 100
                    self._heroBody:runAction(cc.Repeat:create(
                        cc.Sequence:create(
                            cc.DelayTime:create(0.02),
                            cc.CallFunc:create(function(  )
                                brigthness = brigthness - 5
                                self._heroBody:setBrightness(brigthness)
                            end)
                        )
                    ,20))
                    self._card:setVisible(false)
                    self:showHeroInfoAnim()
                    if callback then
                        callback()
                    end
                end)
            ))
        end
    end)
    -- mcCardShow:setPlaySpeed(0.2)
    self._bg:addChild(mcCardShow,99)
end

-- 英雄信息动画
function HeroUnlockView:showHeroInfoAnim( )
    local moveFromBorder = function( panel,fromX,toX,delay,callback )
        panel:setCascadeOpacityEnabled(true,true)
        panel:setOpacity(0)
        panel:setPositionX(fromX)
        panel:runAction(cc.Sequence:create(
            cc.DelayTime:create(delay),
            cc.Spawn:create(
                cc.FadeIn:create(0.3),
                cc.MoveTo:create(0.3,cc.p(toX,panel:getPositionY()))
            ),
            cc.CallFunc:create(function( )
                if callback then
                    callback()
                end
            end)
        ))
    end

    local moveDistance = 300

    local moveConfig = {
        -- 左边两个
        {name = "bg.layer.image_specialty_bg",fromX = 125-moveDistance,toX = 125,delay = 0,callback = function( )
            
        end},
        {name = "bg.layer.image_skill_bg",fromX = 125-moveDistance,toX = 125,delay = 0.05,callback = function( )
            
        end},
        -- 右边三个
        {name = "bg.layer.label_hero_name",fromX = 818+moveDistance,toX = 818,delay =0,callback = function( )
            
        end},
        {name = "bg.layer.label_hero_pos",fromX = 862+moveDistance,toX = 862,delay = 0.05,callback = function( )
            
        end},
        -- {name = "bg1.rightTopPanel",fromX = 685+50,toX = 685,delay = 0.1,callback = function( )
            
        -- end},
        
    }
    for i,conf in ipairs(moveConfig) do
        local panel = self:getUI(conf.name)
        if panel then
            moveFromBorder(panel,conf.fromX,conf.toX,conf.delay)
        end
    end
end

return HeroUnlockView