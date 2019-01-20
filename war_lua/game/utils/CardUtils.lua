--[[
    Filename:    CardUtils.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-12-30 15:59:50
    Description: File description
--]]

local CardUtils = {}

local CARD_WIDTH = 317
local CARD_HEIGHT = 547

CardUtils.kNormalCardBorder = {name = "card_bg.png", offsetX = 0, offsetY = 0, scaleNum = 1.075}
CardUtils.kHeroDuelCardBorder = {name = "card_team_bg.png", offsetX = 0, offsetY = 0, scaleNum = 1.075}

--[[
--! @desc 创建兵团卡牌
--! @param inView 操作卡牌
--! @param inTable 属性参数
            teamD 兵团配置信息
            star 星数
--]]
function CardUtils:createTeamCard(inTable)
    local teamD = inTable.teamD
    if teamD == nil then
        return
    end
    local level = inTable.level or 1
    local star = inTable.star or 1
	local race = teamD["race"][1]
	if race == 108 then
		race = 101
	end

	local cardbg = ccui.Layout:create()
	cardbg:setAnchorPoint(0.5, 0.5)
    cardbg:setBackGroundColorOpacity(0)
    cardbg:setBackGroundColorType(1)
    cardbg:setBackGroundColor(cc.c3b(255,255,255))
    cardbg:setContentSize(CARD_WIDTH, CARD_HEIGHT)
    cardbg:setName("cardbg")

    local centerx, centery = CARD_WIDTH * 0.5, CARD_HEIGHT * 0.5

    local bg = cc.Sprite:create("asset/uiother/card/card_bg_" .. race .. ".jpg")
    bg:setPosition(centerx - 9, centery - 15)
    bg:setScale(1.01)
    bg:setName("bg")

    local lihui = string.sub(teamD["art1"], 4, string.len(teamD["art1"]))
    
    local cardoffset = teamD["card"]

 	local roleSp = cc.Sprite:create("asset/uiother/team/t_"..lihui..".png")
 	roleSp:setAnchorPoint(0, 0)
    roleSp:setPosition(cardoffset[1], cardoffset[2])
    roleSp:setScale(cardoffset[3])
    roleSp:setName("roleSp")
    cardbg.picName = "asset/uiother/team/t_"..lihui..".png"
 	-- local w, h = roleSp:getContentSize().width, roleSp:getContentSize().height
 	-- if w / h > CARD_WIDTH / CARD_HEIGHT then
 	-- 	roleSp:setScale(CARD_HEIGHT / h)
 	-- else
 	-- 	roleSp:setScale(CARD_WIDTH / w)
 	-- end
 	local cardClip = ccui.Layout:create()
 	cardClip:setAnchorPoint(0.5, 0.5)
 	cardClip:setPosition(centerx, centery)
	cardClip:setClippingEnabled(true)
	cardClip:setContentSize(CARD_WIDTH - 18, CARD_HEIGHT - 22)
    cardClip:setName("cardClip")
 	cardbg:addChild(cardClip)     -- 1
    cardClip:addChild(bg)         -- 1-1
 	cardClip:addChild(roleSp)     -- 1-2
 	

    local fg = cc.Sprite:create("asset/uiother/card/card_fg_" .. race .. ".png")
    fg:setPosition(centerx - 9, centery - 15)
    fg:setScale(1.01)
    fg:setName("fg")
    cardClip:addChild(fg)          -- 1-3

    local zhaozi = cc.Sprite:create("asset/uiother/card/card_bg.png")
	zhaozi:setPosition(centerx, centery)
    zhaozi:setScale(1.075)
    zhaozi:setName("zhaozi")
    -- zhaozi:setOpacity(50)
    cardbg:addChild(zhaozi) -- 2
    local className = TeamUtils:getClassIconNameByTeamId(teamD.id, "classlabel", teamD)
    local classlabel = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. className .. ".png")
    classlabel:setPosition(54, 505)
    classlabel:setScale(1.1)
    classlabel:setName("classlabel")
    cardbg:addChild(classlabel) -- 3

    -- local newstr = ""
    -- local str = lang(teamD["name"])
    -- for i = 1, string.len(str)/3 do
    -- 	local s = string.sub(str, 1 + (i - 1) * 3, i * 3)
    -- 	if i ~= string.len(str)/3 then
    -- 		newstr = newstr .. s .. " "
    -- 	else
    -- 		newstr = newstr .. s
    -- 	end
    -- end
    local name = cc.Label:createWithTTF(lang(teamD["name"]), UIUtils.ttfName, 48)
	name:setPosition(166, CARD_HEIGHT - 40)
    name:setScale(.7)
    name:setColor(cc.c3b(255, 243, 174))
    name:enable2Color(1, cc.c4b(251, 197, 67, 255))
    name:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    name:setName("name")
    cardbg:addChild(name) -- 4

 --    if level then
	--     local lv = cc.Label:createWithTTF("Lv." .. level, UIUtils.ttfName, 40)
	--     lv:enableOutline(cc.c4b(128, 128, 128, 255), 2)
	-- 	lv:setPosition(90, 40)
 --        lv:setScale(.7)
	--     cardbg:addChild(lv)
	-- end

    self:updateTeamCard(cardbg, inTable)
	return cardbg
end

--[[
--! @desc 更新兵团卡牌
--! @param inView 操作卡牌
--! @param inTable 属性参数
            teamD 兵团配置信息
            star 星数
--]]
function CardUtils:updateTeamCard(inView, inTable)
    -- dump(inTable)
    local race = inTable.teamD["race"][1]
    if race == 108 then
        race = 101
    end

    local centerx, centery = CARD_WIDTH * 0.5, CARD_HEIGHT * 0.5
    local cardClip = inView:getChildByFullName("cardClip")

    local bg = cardClip:getChildByFullName("bg")
    if bg then
        bg:setTexture("asset/uiother/card/card_bg_" .. race .. ".jpg")
        bg:setPosition(centerx - 9, centery - 15)
    end
    local inTeamData = inTable.teamData or inTable.teamD
    local teamName, art1, art2, art3 = TeamUtils:getTeamAwakingTab(inTeamData, inTable.teamD.id)

    -- local lihui = string.sub(inTable.teamD["art1"], 4, string.len(inTable.teamD["art1"]))
    
    local cardoffset = inTable.teamD["card"]

    local roleSp = cardClip:getChildByFullName("roleSp")
    if roleSp then
        local teamArt = "asset/uiother/team/"..art2..".png"
        if inView.picName ~= teamArt then
            roleSp:setTexture(teamArt)
            cc.Director:getInstance():getTextureCache():removeTextureForKey(inView.picName)
            inView.picName = teamArt
        end
        roleSp:setPosition(cardoffset[1], cardoffset[2])
        roleSp:setScale(cardoffset[3])
    end

    -- local w, h = roleSp:getContentSize().width, roleSp:getContentSize().height
    -- if w / h > CARD_WIDTH / CARD_HEIGHT then
    --  roleSp:setScale(CARD_HEIGHT / h)
    -- else
    --  roleSp:setScale(CARD_WIDTH / w)
    -- end

    local fg = cardClip:getChildByFullName("fg")
    if fg then
        fg:setTexture("asset/uiother/card/card_fg_" .. race .. ".png")
        fg:setPosition(centerx - 9, centery - 15)
    end

    local classlabel = inView:getChildByFullName("classlabel")
    if classlabel then
        -- classlabel:setSpriteFrame(IconUtils.iconPath .. inTable.teamD["classlabel"] .. ".png")
        local raceLab = tab:Race(race)
        classlabel:setSpriteFrame(IconUtils.iconPath .. raceLab.art .. ".png")
    end

    local name = inView:getChildByFullName("name")
    if name then
        name:setString(lang(teamName))
    end
 --    if level then
    --     local lv = cc.Label:createWithTTF("Lv." .. level, UIUtils.ttfName, 40)
    --     lv:enableOutline(cc.c4b(128, 128, 128, 255), 2)
    --  lv:setPosition(90, 40)
 --        lv:setScale(.7)
    --     inView:addChild(lv)
    -- end

    -- 星星
    if inTable.star then
        local starAllWidth = inTable.star * 50
        local beginX  = inView:getContentSize().width / 2 - starAllWidth / 2 + 2
        for i= 1 , 6 do
            local iconStar = inView:getChildByFullName("star" .. i)
            if i <= inTable.star then 
                if iconStar == nil then
                    iconStar = ccui.ImageView:create()

                    local iconStarLayout = ccui.LayoutComponent:bindLayoutComponent(iconStar)
                    iconStarLayout:setHorizontalEdge(ccui.LayoutComponent.HorizontalEdge.Left)
                    iconStarLayout:setVerticalEdge(ccui.LayoutComponent.VerticalEdge.Top)
                    iconStarLayout:setStretchWidthEnabled(false)
                    iconStarLayout:setStretchHeightEnabled(false)
                    iconStarLayout:setSize(iconStar:getContentSize())
                    iconStarLayout:setLeftMargin(0)
                    iconStarLayout:setTopMargin(0)
                    iconStar:setAnchorPoint(cc.p(0, 0))
                    iconStar:ignoreContentAdaptWithSize(true)
                    iconStar:loadTexture("globalImageUI6_star1.png", 1)
                    iconStar:setScale(1)
                    inView:addChild(iconStar,3) 
                end
                iconStar:setVisible(true)
                iconStar:setPosition(beginX + (i - 1) * 50, 20)
                iconStar:setName("star" .. i)
            else
                if iconStar ~= nil then
                    iconStar:setVisible(false)
                end
            end
        end
    end
end

--[[
--! @desc 创建英雄交锋兵团卡牌
--! @param inView 操作卡牌
--! @param inTable 属性参数
            teamD 兵团配置信息
            star 星数
            borderTp 边框参数
--]]

local HDUEL_TEAM_WIDTH = 266
local HDUEL_TEAM_HEIGHT= 446
function CardUtils:createHeroDuelTeamCard(inTable)
    local teamD = inTable.teamD
    if teamD == nil then
        return
    end

	local cardbg = ccui.Layout:create()
	cardbg:setAnchorPoint(0.5, 0.5)
    cardbg:setBackGroundColorOpacity(0)
    cardbg:setBackGroundColorType(1)
    cardbg:setBackGroundColor(cc.c3b(255,255,255))
    cardbg:setContentSize(HDUEL_TEAM_WIDTH, HDUEL_TEAM_HEIGHT)
    cardbg:setName("cardbg")

    local centerx, centery = HDUEL_TEAM_WIDTH * 0.5, HDUEL_TEAM_HEIGHT * 0.5

 	local roleSp = cc.Sprite:create("asset/uiother/cteam/"..teamD["heroDuelIm"]..".jpg")
 	roleSp:setAnchorPoint(0, 0)
    roleSp:setPosition(-120, 0)
    roleSp:setScale(1.5)
    roleSp:setName("roleSp")
    cardbg.picName = "asset/uiother/cteam/"..teamD["heroDuelIm"]..".jpg"


 	local cardClip = ccui.Layout:create()
 	cardClip:setAnchorPoint(0.5, 0.5)
 	cardClip:setPosition(centerx, centery + 24)
	cardClip:setClippingEnabled(true)
	cardClip:setContentSize(HDUEL_TEAM_WIDTH - 32, HDUEL_TEAM_HEIGHT - 22)
    cardClip:setName("cardClip")
 	cardbg:addChild(cardClip)     -- 1
 	cardClip:addChild(roleSp)     -- 1-2
    cardClip:setCascadeOpacityEnabled(true)
 	
    local zhaozi = ccui.Scale9Sprite:create("asset/uiother/card/card_team_bg.png")
    zhaozi:setCapInsets(cc.rect(170, 100, 1, 1))
    zhaozi:setContentSize(315, 515)
	zhaozi:setPosition(centerx, centery)
    zhaozi:setScale(0.8)
    zhaozi:setName("zhaozi")
    -- zhaozi:setOpacity(50)
    cardbg:addChild(zhaozi) -- 2

    local zhaoziJx = cc.Scale9Sprite:create("asset/uiother/card/card_teamAwake_bg.png")
    zhaoziJx:setCapInsets(cc.rect(170, 100, 1, 1))
    zhaoziJx:setContentSize(320, 525)
	zhaoziJx:setPosition(centerx, centery + 2)
    zhaoziJx:setScale(0.8)
    zhaoziJx:setName("zhaoziJx")
    cardbg:addChild(zhaoziJx) -- 2

    local className = teamD["classlabel"]
    if inTable.isAwaking then
        className = className .. "_awake"
    end
    local classlabel = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. className .. ".png")
    classlabel:setPosition(49, 400)
    classlabel:setName("classlabel")
    cardbg:addChild(classlabel) -- 3

    local name = cc.Label:createWithTTF(lang(teamD["name"]), UIUtils.ttfName, 28)
	name:setPosition(156, HDUEL_TEAM_HEIGHT - 46)
    name:setColor(cc.c3b(255, 243, 174))
    name:enable2Color(1, cc.c4b(251, 197, 67, 255))
    name:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    name:setName("name")
    cardbg:addChild(name) -- 4

    self:updateHeroDuelTeamCard(cardbg, inTable)

	return cardbg
end

--[[
--! @desc 更新英雄交锋兵团卡牌
--! @param inView 操作卡牌
--! @param inTable 属性参数
            teamD 兵团配置信息
            star 星数
--]]
function CardUtils:updateHeroDuelTeamCard(inView, inTable)
    local centerx, centery = HDUEL_TEAM_WIDTH * 0.5, HDUEL_TEAM_HEIGHT * 0.5
    local cardClip = inView:getChildByFullName("cardClip")


    local roleSp = cardClip:getChildByFullName("roleSp")
    if roleSp then
        local rolePicName = "asset/uiother/cteam/"..inTable.teamD["heroDuelIm"]..".jpg"
        if inTable.isAwaking then
            local roleTemp = inTable.teamD["heroDuelIm"]
            roleTemp = "cta_" .. string.sub(roleTemp, 4)
            rolePicName = "asset/uiother/cteam/"..roleTemp..".jpg"
        end

        if inView.picName ~= rolePicName then
            roleSp:setTexture(rolePicName)
            cc.Director:getInstance():getTextureCache():removeTextureForKey(inView.picName)
            inView.picName = rolePicName
        end
    end

    local classlabel = inView:getChildByFullName("classlabel")
    if classlabel then
        local className = inTable.teamD["classlabel"]
        if inTable.isAwaking then
            className = className .. "_awake"
        end
        classlabel:setSpriteFrame(IconUtils.iconPath .. className .. ".png")
    end

    local name = inView:getChildByFullName("name")
    if name then
        if inTable.isAwaking then 
            name:setString(lang(inTable.teamD["awakingName"]))
            name:setPositionY(HDUEL_TEAM_HEIGHT - 48)
        else
            name:setString(lang(inTable.teamD["name"]))
            name:setPositionY(HDUEL_TEAM_HEIGHT - 46)
        end
    end

    local zhaozi = inView:getChildByFullName("zhaozi")
    local zhaoziJx = inView:getChildByFullName("zhaoziJx")
    if zhaozi and zhaoziJx then
        if inTable.isAwaking then 
            zhaozi:setVisible(false)
            zhaoziJx:setVisible(true)

        else
            zhaozi:setVisible(true)
            zhaoziJx:setVisible(false)
        end
    end
end

--[[
--! @desc 创建英雄交锋英雄卡牌
--! @param inView 操作卡牌
--! @param inTable 属性参数
            heroD 英雄配置信息
--]]

local HDUEL_HERO_WIDTH = 266
local HDUEL_HERO_HEIGHT= 446
function CardUtils:createHeroDuelHeroCard(inTable)
    local heroD = inTable.heroD
    if heroD == nil then
        return
    end

	local cardbg = ccui.Layout:create()
	cardbg:setAnchorPoint(0.5, 0.5)
    cardbg:setBackGroundColorOpacity(0)
    cardbg:setBackGroundColorType(1)
    cardbg:setBackGroundColor(cc.c3b(255,255,255))
    cardbg:setContentSize(HDUEL_HERO_WIDTH, HDUEL_HERO_HEIGHT)
    cardbg:setName("cardbg")

    local centerx, centery = HDUEL_HERO_WIDTH * 0.5, HDUEL_HERO_HEIGHT * 0.5

 	local roleSp = cc.Sprite:create("asset/uiother/dhero/".. heroD["heromp"]..".jpg")
 	roleSp:setAnchorPoint(0.5, 0.5)
    roleSp:setPosition(centerx, centery + 5)
    roleSp:setScale(1.2)
    roleSp:setName("roleSp")
    cardbg.picName = "asset/uiother/dhero/".. heroD["heromp"]..".jpg"
    cardbg:addChild(roleSp)

    local zhaozi = ccui.Scale9Sprite:create("asset/uiother/card/card_hero_bg.png")
    zhaozi:setCapInsets(cc.rect(170, 222, 1, 1))
    zhaozi:setContentSize(330, 531)
    zhaozi:setScale(0.8)
	zhaozi:setPosition(centerx, centery + 10)
    zhaozi:setName("zhaozi")
    -- zhaozi:setOpacity(50)
    cardbg:addChild(zhaozi) -- 2

    local name = cc.Label:createWithTTF(lang(heroD["heroname"]), UIUtils.ttfName, 26)
	name:setPosition(centerx, HDUEL_HERO_HEIGHT - 48)
    name:setColor(cc.c3b(255, 243, 174))
    name:enable2Color(1, cc.c4b(251, 197, 67, 255))
    name:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    name:setName("name")
    cardbg:addChild(name) -- 4

    self:updateHeroDuelHeroCard(cardbg, inTable)
	return cardbg
end

--[[
--! @desc 更新英雄交锋英雄卡牌
--! @param inView 操作卡牌
--! @param inTable 属性参数
            heroD 英雄配置信息
--]]
function CardUtils:updateHeroDuelHeroCard(inView, inTable)
    local heroD = inTable.heroD
    if heroD == nil then
        return
    end

    -- dump(inTable)
    local centerx, centery = HDUEL_HERO_WIDTH * 0.5, HDUEL_HERO_HEIGHT * 0.5

    local roleSp = inView:getChildByFullName("roleSp")
    if roleSp then
        if inView.picName ~= "asset/uiother/dhero/".. heroD["heromp"]..".jpg" then
            roleSp:setTexture("asset/uiother/dhero/".. heroD["heromp"]..".jpg")
            cc.Director:getInstance():getTextureCache():removeTextureForKey(inView.picName)
            inView.picName = "asset/uiother/dhero/".. heroD["heromp"]..".jpg"
        end
    end

    local name = inView:getChildByFullName("name")
    if name then
        name:setString(lang(inTable.heroD["heroname"]))
    end
end


local CARD_TEAM_WIDTH = 162
local CARD_TEAM_HEIGHT = 249
local CARD_COLOR_FRAME = {
    [1] = {brightness = 0, contrast = 0, color = cc.c3b(255, 255, 255)},
    [2] = {brightness = 12, contrast = 16, color = cc.c3b(66, 214, 8)},
    [3] = {brightness = 2, contrast = -22, color = cc.c3b(25, 120, 255)},
    [4] = {brightness = 16, contrast = 38, color = cc.c3b(217, 77, 242)},
    [5] = {brightness = 12, contrast = 30, color = cc.c3b(242, 161, 20)}
}

--[[
--! @desc 创建兵团卡牌
--! @param inView 操作卡牌
--! @param inTable 属性参数
            teamD 兵团配置信息
            systeam 兵团配表信息
--]]
function CardUtils:createTeamListCard(inTable)
    local cardbg = ccui.Layout:create()
    cardbg:setAnchorPoint(0.5, 0.5)
    cardbg:setBackGroundColorOpacity(0)
    cardbg:setBackGroundColorType(1)
    cardbg:setBackGroundColor(cc.c3b(255,255,255))
    cardbg:setContentSize(CARD_TEAM_WIDTH, CARD_TEAM_HEIGHT)
    cardbg:setName("cardbg")

    local centerx, centery = CARD_TEAM_WIDTH * 0.5, CARD_TEAM_HEIGHT * 0.5

    -- -- 裁剪框
    -- local cardClip = ccui.Layout:create()
    -- cardClip:setAnchorPoint(0.5, 0.5)
    -- cardClip:setPosition(centerx, centery)
    -- cardClip:setClippingEnabled(true)
    -- cardClip:setContentSize(CARD_TEAM_WIDTH-6, CARD_TEAM_HEIGHT-10)
    -- cardClip:setName("cardClip")
    -- cardbg:addChild(cardClip)     -- 1

    -- 背景
    local mask = cc.Sprite:create("asset/uiother/cteam/cardt_framebg1-HD.png")
    mask:setPosition(centerx, centery)
    mask:setName("mask")

    -- 裁剪框
    local cardClip = cc.ClippingNode:create()
    cardClip:setInverted(false)
    cardClip:setStencil(mask)
    cardClip:setAlphaThreshold(0.9)
    cardClip:setName("cardClip")
    cardClip:setAnchorPoint(cc.p(0.5,0.5))
    -- cardClip:setPosition(centerx*0.5, centery*0.5)
    cardbg:addChild(cardClip)

    local roleSp = cc.Sprite:create()
    roleSp:setAnchorPoint(1, 0)
    roleSp:setPosition(CARD_TEAM_WIDTH, 2)
    roleSp:setName("roleSp")
    cardClip:addChild(roleSp)     -- 1-2

    -- 遮黑框
    local cardClipBg = ccui.Layout:create()
    cardClipBg:setBackGroundColorOpacity(175)
    cardClipBg:setBackGroundColorType(1)
    cardClipBg:setBackGroundColor(cc.c3b(0,0,0))
    cardClipBg:setContentSize(CARD_TEAM_WIDTH-2, CARD_TEAM_HEIGHT-10)
    cardClipBg:setPosition(centerx, centery)
    cardClipBg:setName("cardClipBg")
    cardClip:addChild(cardClipBg, 20)     -- 1

    local classlabel = cc.Sprite:create()
    classlabel:setPosition(CARD_TEAM_WIDTH-26, CARD_TEAM_HEIGHT-26)
    classlabel:setScale(0.5)
    classlabel:setName("classlabel")
    cardClip:addChild(classlabel, 3) -- 3

    local name = cc.Label:createWithTTF("123", UIUtils.ttfName, 16)
    name:setAnchorPoint(1, 0.5)
    name:setPosition(CARD_TEAM_WIDTH - 10, 60)
    name:setName("name")
    cardClip:addChild(name) -- 4

    local level = cc.Label:createWithTTF("123", UIUtils.ttfName, 16)
    level:setAnchorPoint(0, 0.5)
    level:setPosition(5, 60)
    level:setName("level")
    cardClip:addChild(level) -- 4

    -- 星星
    local teamstar = cc.Sprite:createWithSpriteFrameName("globalImageUI6_cardteamStar1.png")
    teamstar:setAnchorPoint(1, 0.5)
    teamstar:setScale(0.7)
    teamstar:setPosition(CARD_TEAM_WIDTH-10, centery-32)
    teamstar:setName("teamstar")
    cardClip:addChild(teamstar, 3) -- 3

    -- 框
    local zhaozi = cc.Sprite:create()
    zhaozi:setPosition(centerx, centery)
    zhaozi:setName("zhaozi")
    cardbg:addChild(zhaozi) -- 2

    -- 红点
    local onTeamIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
    onTeamIcon:setAnchorPoint(1, 1)
    onTeamIcon:setPosition(CARD_TEAM_WIDTH+12, CARD_TEAM_HEIGHT+12)
    onTeamIcon:setName("onTeamIcon")
    cardbg:addChild(onTeamIcon, 20) -- 3

    -- 进度条
    local progressBg = cc.Sprite:createWithSpriteFrameName("teamImageUI_img57.png")
    progressBg:setPosition(centerx, centery + 20)
    progressBg:setName("progressBg")
    cardbg:addChild(progressBg) -- 3

    local prox = progressBg:getContentSize().width*0.5
    local proy = progressBg:getContentSize().height*0.5
    local progressBar = cc.Sprite:createWithSpriteFrameName("teamImageUI_img59.png")
    progressBar:setPosition(prox, proy)
    progressBar:setName("progressBar")
    progressBg:addChild(progressBar, 2) -- 3

    local progressFrame = cc.Sprite:createWithSpriteFrameName("teamImageUI_img58.png")
    progressFrame:setPosition(prox, proy)
    progressFrame:setName("progressFrame")
    progressBg:addChild(progressFrame, 5) -- 3

    local itemNumLab = cc.Label:createWithTTF("123", UIUtils.ttfName, 18)
    itemNumLab:setAnchorPoint(0, 0.5)
    itemNumLab:setPosition(0, proy-15)
    itemNumLab:setName("itemNumLab")
    itemNumLab:setColor(cc.c3b(252, 200, 100))
    itemNumLab:enableOutline(UIUtils.colorTable.titleOutLineColor, 1)
    progressBg:addChild(itemNumLab) -- 4

    local tName = cc.Label:createWithTTF("123", UIUtils.ttfName, 24)
    tName:enableOutline(UIUtils.colorTable.titleOutLineColor, 1)
    tName:setPosition(prox, proy+15)
    tName:setName("tName")
    progressBg:addChild(tName) -- 4

    self:updateTeamListCard(cardbg, inTable)
    return cardbg
end

function CardUtils:updateHaveTeamUI(inView, inTable)
    local systeam = inTable.systeam
    local teamD = inTable.teamD
    if not systeam then
        return
    end

    local centerx, centery = CARD_TEAM_WIDTH * 0.5, CARD_TEAM_HEIGHT * 0.5
    local teamId = teamD.teamId
    local backQuality = self._teamModel:getTeamQualityByStage(teamD["stage"])

    local cardClip = inView:getChildByFullName("cardClip")
    cardClip:setSaturation(0)

    local cardClipBg = cardClip:getChildByFullName("cardClipBg")
    if cardClipBg then
        cardClipBg:setVisible(false)
    end

    local roleSp = cardClip:getChildByFullName("roleSp")
    if roleSp then
        UIUtils:asyncLoadTexture(roleSp, "asset/uiother/cteam/ct_" .. teamId .. ".jpg")
    end

    local classlabel = cardClip:getChildByFullName("classlabel")
    if classlabel then
        local tclasslabel = TeamUtils:getClassIconNameByTeamD(inTable, "classlabel", systeam)
        classlabel:setSpriteFrame(tclasslabel .. ".png")
    end

    local level = cardClip:getChildByFullName("level")
    if level then
        level:setString("Lv." .. (teamD.level or 1))
    end

    local name = cardClip:getChildByFullName("name")
    if name then
        local str = lang(systeam["name"])
        if backQuality[2] ~= 0 then
            str = str .. "+" .. backQuality[2]
        end
        name:setString(str)
    end

    local zhaozi = inView:getChildByFullName("zhaozi")
    if zhaozi then
        local colorframe = CARD_COLOR_FRAME[backQuality[1]]
        zhaozi:setBrightness(colorframe.brightness)
        zhaozi:setContrast(colorframe.contrast)
        zhaozi:setColor(colorframe.color)
        -- UIUtils:asyncLoadTexture(zhaozi, "asset/uiother/cteam/cardt_frame" .. backQuality[1] .. ".png")
    end

    local onTeamIcon = inView:getChildByFullName("onTeamIcon")
    if onTeamIcon then
        if teamD.isInFormation == true and teamD.onTeam == true then 
            onTeamIcon:setVisible(true)
        else
            onTeamIcon:setVisible(false)
        end
    end

    local progressBg = inView:getChildByFullName("progressBg")
    if progressBg then
        progressBg:setVisible(false)
    end
    if level then
        level:setVisible(true)
    end
end

function CardUtils:updateNoTeamUI(inView, inTable)
    local systeam = inTable.systeam
    local teamD = inTable.teamD
    if not systeam then
        return
    end

    local centerx, centery = CARD_TEAM_WIDTH * 0.5, CARD_TEAM_HEIGHT * 0.5
    local teamId = teamD.teamId

    local cardClip = inView:getChildByFullName("cardClip")
    cardClip:setSaturation(-100)

    local cardClipBg = cardClip:getChildByFullName("cardClipBg")
    if cardClipBg then
        cardClipBg:setVisible(true)
    end

    local roleSp = cardClip:getChildByFullName("roleSp")
    if roleSp then
        UIUtils:asyncLoadTexture(roleSp, "asset/uiother/cteam/ct_" .. teamId .. ".jpg")
    end

    local zhaozi = inView:getChildByFullName("zhaozi")
    if zhaozi then
        local colorframe = CARD_COLOR_FRAME[1]
        zhaozi:setBrightness(colorframe.brightness)
        zhaozi:setContrast(colorframe.contrast)
        zhaozi:setColor(colorframe.color)
        -- UIUtils:asyncLoadTexture(zhaozi, "asset/uiother/cteam/cardt_frame1.png")
    end
    
    local onTeamIcon = inView:getChildByFullName("onTeamIcon")
    if onTeamIcon then
        local zhaoFlag = self._teamModel:isCanGatTeams(teamId)
        if zhaoFlag == true then
            onTeamIcon:setVisible(true)
        else
            onTeamIcon:setVisible(false)
        end
    end

    local classlabel = inView:getChildByFullName("classlabel")
    if classlabel then
        local tclasslabel = TeamUtils:getClassIconNameByTeamD(inTable, "classlabel", systeam)
        classlabel:setSpriteFrame(tclasslabel .. ".png")
    end

    local name = inView:getChildByFullName("name")
    local namestr = lang(systeam["name"])
    if name then
        name:setString(namestr)
    end

    local level = inView:getChildByFullName("level")
    if level then
        level:setVisible(false)
    end

    local progressBg = inView:getChildByFullName("progressBg")
    if progressBg then
        progressBg:setVisible(true)
    end

    local progressBar = progressBg:getChildByFullName("progressBar")
    if progressBar then
        progressBar:setVisible(true)
    end

    local progressFrame = progressBg:getChildByFullName("progressFrame")
    if progressFrame then
        progressFrame:setVisible(true)
    end

    local itemNumLab = progressBg:getChildByFullName("itemNumLab")
    if itemNumLab then
        local sameSouls, sameSoulCount = self._itemModel:getItemsById(systeam.goods)
        local teamStar = tab.star[systeam.starlevel]
        local str = sameSoulCount .. "/" .. teamStar.sum
        itemNumLab:setString(str)
    end

    local tName = progressBg:getChildByFullName("tName")
    if tName then
        tName:setString(namestr)
    end
end

function CardUtils:updateTeamListCard(inView, inTable)
    local teamD = inTable.teamD
    if not teamD then
        return
    end

    if teamD.showType == 1 then
        touchType = 1
        self:updateHaveTeamUI(inView, inTable)
    else
        self:updateNoTeamUI(inView, inTable)
    end
end

function CardUtils.dtor()
    CARD_TEAM_WIDTH = nil
    CARD_TEAM_HEIGHT = nil
    CARD_COLOR_FRAME = nil
    CARD_HEIGHT = nil
    CARD_WIDTH = nil
    CardUtils = nil

    HDUEL_HERO_WIDTH = nil
    HDUEL_HERO_HEIGHT = nil

    HDUEL_TEAM_WIDTH = nil
    HDUEL_TEAM_HEIGHT = nil
end

return CardUtils