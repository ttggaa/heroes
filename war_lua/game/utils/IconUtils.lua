--[[
    Filename:    IconUtils.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-05-25 18:24:42
    Description: File description
--]]
local cc = cc
local ItemUtils = ItemUtils
local IconUtils = {}
local NewFormationIconView = require("game.view.formation.NewFormationIconView")
local tc = cc.Director:getInstance():getTextureCache()
local viewMgr = ViewManager:getInstance()
local ALR = pc.PCAsyncLoadRes:getInstance()
IconUtils.iconPath = ""--"asset/icon/"

local ccSprite = cc.Sprite
local ccuiImageView = ccui.ImageView
local ccLabel = cc.Label
local ccuiText = ccui.Text
local ccuiWidget = ccui.Widget
local ccuiLayout = ccui.Layout
local ccc3b = cc.c3b
local ccc4b = cc.c4b

IconUtils.iconIdMap = 
{
    guildCoin = 39990,
    exp = 39991,
    gem = 39992,
    gold = 39993,
    physcal = 39994,
    active = 39995,
    texp = 39996,
    currency = 39997,
    crusading = 39998,
    treasureCoin = 39999,
    starNum = 39989,
    vexp = 39979,
    guildPower=39988,
    mapHurt=39987,
    leagueCoin=39986,
    payGem = 39978,
    fake = 39980,
    arrowNum = 39984,
    dice = 39985,
    nests1 = 39975,
    nests2 = 39974,
    nests3 = 39973,
    nests4 = 39972,
    hDuelCoin = 40000,
    fans = 39971,
    souvenir = 39970,
    starfrag = 39969,
    cbCoin = 39968,
    expCoin = 40001,
    luckyCoin = 40002,
    planeCoin = 40003,
    skillBookCoin = 40004,
    friendCoin = 40006,
    siegeWeaponExp = 40007,
    siegePropExp = 40008,
    siegePropCoin = 40009,
    cpCoin = 40010,
    runeCoin = 40011,
    soulRime = 40012,
    soulStar = 40014,
    crossGodWarCoin = 40015,
    signCoin = 40016,  
    honorCertificate = 40021,
	battleSoul = 40019,
	alchemy = 40020,
    pTalentPoint = 40022,
}

IconUtils.resImgMap = {
    guildCoin = "globalImageUI_allied.png",
    exp = "globalImageUI_exp1.png",
    gem = "globalImageUI_diamond.png",
    gold = "globalImageUI_gold1.png",
    physcal = "globalImageUI4_power.png",
    active = "",
    -- texp = IconUtils.iconPath .. "i_106.jpg",
    currency = "globalImage_jingjibi.png",
    crusading = "golbalIamgeUI5_yuanzhengbi.png", -- 暂用
    treasureCoin = "golbalIamgeUI5_treasureCoin.png", -- 暂用
    texp = "globalImageUI_texp.png",
    privilege = "globalImageUI_tequan.png",
    vexp = "globalImageUI_exp1.png",
    guildPower = "globalImageUI7_guildPower.png",
    mapHurt = "globalImageUI7_mapHurt.png",
    leagueCoin= "globalImageUI_leagueCoin.png",
    arrow = "globalImageUI7_mapHurt.png",
    dice = "globalImageUI_dice.png",
    ["41003"] = "globalImageUI_treasurecoupon.png", -- 黑市币
    nests1 = "globalImageUI_nests1.png",
    nests2 = "globalImageUI_nests2.png",
    nests3 = "globalImageUI_nests3.png",
    nests4 = "globalImageUI_nests4.png",
    hDuelCoin = "globalImageUI_hDuelCoin.png",
    fans= "globalImageUI12_gfans2.png",
    souvenir= "globalImageUI12_gsouvenir2.png",
    cbCoin = "globalImageUI_cbCoin.png", --征战印记
    expCoin = "globalImageUI_exp3.png", --经验货币
    luckyCoin = "globalImageUI_luckyCoin.png",
    planeCoin = "globalImageUI_planeCoin.png",
    skillBookCoin = "globalImageUI_keyin1.png",
    friendCoin = "globalImageUI_friendCoin.png",
    siegeWeaponExp = "globalImageUI_siegeWeaponExp.png", -- 器械经验
    siegePropExp = "globalImageUI_siegePropExp.png", -- 器械配件经验
    siegePropCoin = "globalImageUI_siegePropCoin.png", -- 器械抽卡
    cpCoin = "globalImageUI_kuafuCoin.png", -- 跨服竞技币
    runeCoin = "globalImageUI_holyCoin.png", -- 圣徽货币
    soulRime = "globalImageUI_soulRime_img.png",  --灵魂结晶
    crossGodWarCoin = "globalImageUI_crossGodWarCoin.png",  --跨服诸神货币资源
    signCoin = "globalImageUI_signCoin.png",    --签到币
    honorCertificate = "globalImageUI_gloryArenaIcon_min.png", --荣耀竞技场
	alchemy = "i_40020.png",		--炼金工坊货币
    pTalentPoint = "globalImageUI_pTalentPoint.png",   --巅峰天赋点
}

IconUtils.playWay = {
    [1] = "ta_putongfuben.png",
    [2] = "ta_jingjichangcishu.png",
    [3] = "ta_longzhiguocishu.png",
    [4] = "ta_yinsenmuxue.png",
    [5] = "ta_airenbaowu.png",
    [6] = "ta_jingyingfuben.png",
}

IconUtils.attLittleIcon = {
    [2] = "teamImageUI4_iconAtk.png", -- 兵团攻击
    [5] = "teamImageUI4_iconAck.png", -- 兵团生命
    [112] = "golbalIamgeUI6_atkIcon.png", -- 英雄攻击(额外) 
    [115] = "golbalIamgeUI6_defIcon.png", -- 英雄防御(额外)
    [118] = "golbalIamgeUI6_ackIcon.png", -- 英雄智力(额外)
    [121] = "golbalIamgeUI6_intIcon.png", -- 英雄知识(额外)
    [131] = "golbalIamgeUI6_heroHurtIcon.png", -- 英雄法伤
}

IconUtils.tencentIcon = {
    wx_gamecenter = "tencentIcon_wxTequan.png",
    sq_gamecenter = "tencentIcon_qqTequan.png",
    is_qq_vip_head = "tencentIcon_vipHead.png",
    is_qq_svip_head = "tencentIcon_sVipHead.png",
    is_qq_vip_icon = "tencentIcon_qqVip.png",
    is_qq_vip_icon = "tencentIcon_qqSVip.png"
}

local fu = cc.FileUtils:getInstance()

-- [[ 需要与baseEvent 的按钮事件代码同步
local function ButtonBeginAnim(view)
    if view:isScaleAnim() then
        local ax, ay = view:getAnchorPoint().x, view:getAnchorPoint().y
        if ax == 0.5 and ay == 0.5 then
            if view.__oriScale == nil then
                view.__oriScale = view:getScaleX()
            end
            local scaleMin = 0.8
            if view.__scaleMin then
                scaleMin = view.__scaleMin
            end
            view:stopAllActions()
            view:setScale(view.__oriScale * 0.95)
            view:runAction(cc.EaseIn:create(cc.ScaleTo:create(0.05, view.__oriScale * scaleMin), 2))
        end
    end
end

local function ButtonEndAnim(view)
    if view:isScaleAnim() then
        local ax, ay = view:getAnchorPoint().x, view:getAnchorPoint().y
        if ax == 0.5 and ay == 0.5 then
            view:stopAllActions()
            if view.__oriScale then
                local scaleMin = 0.8
                if view.__scaleMin then
                    scaleMin = view.__scaleMin
                end
                local rate = 1 - ((view:getScaleX() - view.__oriScale * scaleMin) / (view.__oriScale * 0.2))
                view:runAction(cc.Sequence:create(
                    cc.ScaleTo:create(0.02 + 0.03 * rate, view.__oriScale * (1.00 + 0.05 * rate)), 
                    cc.ScaleTo:create(0.02 + 0.03 * rate, view.__oriScale * (1.00 - 0.05 * rate)),
                    cc.ScaleTo:create(0.02 + 0.03 * rate, view.__oriScale)
                ))
            end
        end
    end
end
--]]

--[[
--! @function createGoldIcon
--! @desc 金币icon
--! @param inTable table 相关控制
           num int 数量
--! @return
--]]
function IconUtils:createGoldIcon(inNum)
    local bgNode = ccuiWidget:create()
    bgNode:setContentSize(80, 80)

    local goldIcon = ccuiImageView:create()

    goldIcon:setName("goldIcon")
    goldIcon:loadTexture(IconUtils:getSkillIconById(1), 1)
    goldIcon:setContentSize(80, 80)
    -- goldIcon:setAnchorPoint(cc.p(0.5, 0.5))
    -- goldIcon:setPosition(cc.p(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2))

    goldIcon:ignoreContentAdaptWithSize(false)
    --print("goldIcon:getContentSize().width====",goldIcon:getContentSize().width)

    if inNum > 0  then 
        local numLab = ccuiText:create()
        numLab:setString(inNum)
        numLab:setName("numLab")
        numLab:setFontName(UIUtils.ttfName)
        numLab:setFontSize(15)
        numLab:setAnchorPoint(1, 0)
        numLab:setPosition(goldIcon:getContentSize().width - 7, 7)
        goldIcon:addChild(numLab)
    end

   local boxIcon = ccuiImageView:create()

    -- boxIcon:setAnchorPoint(0.5, 0.5)
    boxIcon:setName("boxIcon")
    boxIcon:setPosition(goldIcon:getContentSize().width/2, goldIcon:getContentSize().height/2)
    boxIcon:ignoreContentAdaptWithSize(false)
    boxIcon:loadTexture("globalImageUI6_meiyoutu.png", 1)
    boxIcon:setContentSize(80, 80)
    

    goldIcon:addChild(boxIcon)

    return goldIcon
end


-- local table = {itemId = 112312312,num = 10 ,eventStyle = 3,clickCallback = function()
-- end}
--[[
--! @function createItemIconById
--! @desc 创建物品icon
--! @param inTable table 相关控制
           itemId int 物品id
           name string 名字
           num int 数量
           itemData table 数据
           swallowTouches bool 是否会点穿, 默认是false
           eventStyle int 事件类型 
                    0:无事件响应,
                    1:长按显示信息,
                    2:点击显示弹出框信息,
                    3:回调点击事件
           clickCallback 点击毁掉事件
           battleSoulType   战魂类型。特殊处理10种战魂icon

--! @return bgNode node 
--]]

local itemEffect = {
    [1] = "wupinguang_itemeffectcollection",                -- 转光
    [2] = "wupinkuangxingxing_itemeffectcollection",        -- 星星
    [3] = "tongyongdibansaoguang_itemeffectcollection",     -- 扫光
    [4] = "diguang_itemeffectcollection",                   -- 底光
}

function IconUtils:createItemIconById(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(92, 92)
    bgNode:setCascadeOpacityEnabled(true)

    local itemIcon = ccuiImageView:create()

    -- itemIcon:setAnchorPoint(0.5, 0.5)
    itemIcon:setName("itemIcon")
    itemIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    itemIcon:ignoreContentAdaptWithSize(false)

    bgNode.itemIcon = itemIcon
    bgNode:addChild(itemIcon,1)

    local boxIcon = ccuiImageView:create()

    -- boxIcon:setAnchorPoint(0.5, 0.5)
    boxIcon:setName("boxIcon")
    boxIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    boxIcon:ignoreContentAdaptWithSize(false)

    bgNode.boxIcon = boxIcon
    bgNode:addChild(boxIcon,-1)

    local iconColor = ccuiImageView:create()
    -- iconColor:setAnchorPoint(0.5, 0.5)
    iconColor:setName("iconColor")
    iconColor:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    iconColor:ignoreContentAdaptWithSize(false)
    iconColor:setCascadeOpacityEnabled(true)
    iconColor:setContentSize(92, 92)
-- iconColor:setVisible(false)
    bgNode.iconColor = iconColor
    bgNode:addChild(iconColor,6)

    -- [[ iconColor 作为附加的碎片标记 iconMark,数量 numLab 等的父节点来管理
    --    用于处理按钮缩小事件 by guojun 2016.12.29
    --]]

    local iconMark = ccuiImageView:create()
    iconMark:setAnchorPoint(0, 1)
    iconMark:setName("iconMark")
    iconMark:setPosition(-4, bgNode:getContentSize().height+3)
    iconMark:ignoreContentAdaptWithSize(false)
    -- bgNode:addChild(iconMark,100)
    iconColor.iconMark = iconMark
    iconColor:addChild(iconMark,100)

    -- if inTable.num ~= nil then 
    local numLab =  ccuiText:create()
    numLab:setString("")
    numLab:setName("numLab")
    numLab:setFontSize(20)

    numLab:setFontName(UIUtils.ttfName)
    -- numLab:disableEffect()
    numLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
    numLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    numLab:setAnchorPoint(1, 0)
    numLab:setPosition(bgNode:getContentSize().width - 10, 5)

    -- bgNode:addChild(numLab,11)
    iconColor.numLab = numLab
    iconColor:addChild(numLab,11)

        -- local numBg = ccuiImageView:create()
        -- numBg:loadTexture("globalImageUI_iconNumBg.png",1)
        -- numBg:setAnchorPoint(cc.p(1, 0))
        -- numBg:setPosition(cc.p(bgNode:getContentSize().width - 11, 11))
        -- numBg:setName("numBg")
        -- bgNode:addChild(numBg,10)
    -- end
    -- 符文材料特别显示
    local runeLab =  ccuiText:create()
    runeLab:setString("")
    runeLab:setName("runeLab")
    runeLab:setFontSize(22)
    runeLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
    -- runeLab:disableEffect()
    runeLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    runeLab:setAnchorPoint(.5, 1)
    runeLab:setPosition(20, bgNode:getContentSize().height - 1)
    runeLab:setFontName(UIUtils.ttfName)
    -- bgNode:addChild(runeLab,9)
    iconColor.runeLab = runeLab
    iconColor:addChild(runeLab,9)

    local runeBg = ccuiImageView:create()
    -- runeBg:loadTexture("globalImageUI_fuwennumbg.png",1)
    runeBg:setAnchorPoint(0, 1)
    runeBg:setPosition(5, bgNode:getContentSize().height)
    runeBg:setName("runeBg")
    runeBg:setVisible(false)
    -- bgNode:addChild(runeBg,8)
    iconColor.runeBg = runeBg
    iconColor:addChild(runeBg,8)

    if inTable.name ~= nil then 
        local nameLab = ccuiText:create()
        nameLab:setString("")
        nameLab:setName("nameLab")
        nameLab:setFontName(UIUtils.ttfName)
        nameLab:setFontSize(20)
        nameLab:setAnchorPoint(1, 0)
        nameLab:setPosition(bgNode:getContentSize().width - 11, 13)
        -- bgNode:addChild(nameLab,12)
        iconColor.nameLab = nameLab
        iconColor:addChild(nameLab,12)
    end

    IconUtils:updateItemIconByView(bgNode, inTable)
    return bgNode
end

--[[
--! @function updateItemIconByView
--! @desc 更新物品icon相关信息与事件
--! @param inView object 操作icon
--! @param inTable table 相关控制
           itemId int 物品id
           num int 数量
           effect bool 背景光效
           name string 名字
           itemData table 数据
           swallowTouches bool 是否会点穿, 默认是false
           eventStyle int 事件类型 
                    0:无事件响应,
                    1:长按显示信息,
                    2:点击显示弹出框信息,
                    3:回调点击事件
           clickCallback 点击毁掉事件
--! @return
--]]


function IconUtils:updateItemIconByView(inView, inTable)
    if inTable == nil or 
        inTable.itemId == nil then
        return 
    end
    -- dump(inTable)
    local itemIcon = inView.itemIcon
    if itemIcon == nil then 
        return
    end
    local scaleNum = 1
    -- 额外添加的节点 除了动画 都加在iconColor上管理
    local iconColor = inView.iconColor
    iconColor:setScale(scaleNum)
    -- local sysItem = tab:Tool(inTable.itemId)
    -- 会增加类型判断获取不同底图
    -- inView:loadTexture(IconUtils:getItemIconById(inTable.itemId), 1)
    -- 增加forceColor 强换框体颜色 2016.8.5 by guojun
    -- 如果是碎片重设图标
    local isSplice = false
    -- 如果itemId 是 leaguehero 做转化
    if inTable.itemId == "leaguehero" then
        inTable.itemId = ModelManager:getInstance():getModel("LeagueModel"):changeLeagueHero2ItemId(inTable.itemId)
    end
    
    local playerSkillID
    local num_itemid = tonumber(inTable.itemId)
    local battleSoulType = inTable.battleSoulType
    local toolD = tab.tool[num_itemid] 
    local color = inTable.forceColor or ( (toolD and toolD.color ~= 9) and toolD.color or ItemUtils.findResIconColor(inTable.itemId,inTable.num))
    if toolD then
        local typeId = toolD["typeId"]
        if battleSoulType and typeId == 106 then
            itemIcon:loadTexture("battleSoul_" .. battleSoulType .. ".png", 1)
        elseif toolD.art then
            local filename = IconUtils.iconPath .. toolD.art .. ".png"
            local sfc = cc.SpriteFrameCache:getInstance()
            if not sfc:getSpriteFrameByName(filename) then
                filename = IconUtils.iconPath .. toolD.art .. ".jpg"
            end
            itemIcon:loadTexture(filename, 1)
        end
        -- print("typeId",inTable.itemId,typeId,ItemUtils.ITEM_BUT_SPLICE)
        if typeId == ItemUtils.ITEM_TYPE_SPLICE or typeId == ItemUtils.ITEM_TYPE_HEROSPLICE
        or typeId == ItemUtils.ITEM_TYPE_AWAKESPLICE or typeId == ItemUtils.ITEM_TYPE_SKILL 
        or typeId == ItemUtils.ITEM_TYPE_EXCLUSIVE_SPLICE then
            isSplice = true
            -- 添加碎片标记
            local mark = iconColor.iconMark
            if typeId == ItemUtils.ITEM_TYPE_HEROSPLICE then
                mark:loadTexture("globalImageUI_heroSplice.png",1)
                local color = inTable.color or toolD.color or 1
                if color == 4 then  -- 染成紫色 为紫色图标特做 2017.2.6
                    mark:setHue(-125)
                end 
            elseif typeId == ItemUtils.ITEM_TYPE_AWAKESPLICE then
                mark:loadTexture("globalImageUI_splice_jx.png",1)
            else
                mark:loadTexture("globalImageUI_splice".. (inTable.color or toolD.color or 1) ..".png",1)
            end
            mark:setContentSize(35, 35)
            mark:setVisible(true)
            inView._isSplice = isSplice
        else
            if typeId == 5 then -- 宝物图标缩放
                itemIcon:setScale(0.85)
            end
            if iconColor.iconMark then 
                iconColor.iconMark:setVisible(false)
            end
        end
     --     local iconColor = inView:getChildByFullName("iconColor")
        --  iconColor:loadTexture("globalImagUI_spliceFrame.png", 1)
        --  iconColor:setContentSize(cc.size(98, 98))

        --  itemIcon:setContentSize(cc.size(96, 96))
        --     itemIcon:setScale(80/102)
        --     -- itemIcon:setPosition(cc.p(50,50))
        --     -- local icon = IconUtils:setRoundedCorners(itemIcon, toolD.art, "globalImageUI_spliceBg.png")
        --     -- icon:setName("itemIcon")
        -- else
            
        itemIcon:setContentSize(89, 89) -- 防止漏角
        itemIcon:setScale(scaleNum)
        -- itemIcon:setScale(80/98)
            -- local icon = IconUtils:setRoundedCorners(itemIcon, toolD.art)
            -- icon:setName("itemIcon")
        -- end

        iconColor:setContentSize(92, 92)
        if not inTable.itemData then
            inTable.itemData = toolD
        end
        local runeBg = iconColor.runeBg
        local runeLab = iconColor.runeLab
        if runeBg and runeLab and (toolD.art1 or inTable.stage) then
            runeBg:loadTexture("globalImageUI4_iquality" .. color .. ".png", 1)
            runeLab:setString("+".. (toolD.art1 or inTable.stage))
            runeLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
            runeLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
            runeBg:setVisible(true)
        else
            runeLab:setString("")
            runeBg:setVisible(false)
        end

        local skinTag = iconColor:getChildByName("skinTag")
        if not skinTag and (typeId == 102 or typeId == 105) then -- 皮肤
            skinTag = ccui.ImageView:create()
            skinTag:loadTexture("globalImageUI6_connerTag_b.png",1)
            skinTag:setName("skinTag")
            skinTag:setAnchorPoint(cc.p(0,1))
            -- skinTag:setFlippedX(true)
            skinTag:setPosition(40,iconColor:getContentSize().height)
            -- skinTag:setCascadeOpacityEnabled(true)
            -- skinTag:setOpacity(0)

            local skinName = ccui.Text:create()
            skinName:setString("皮肤")
            skinName:setFontSize(26)
            skinName:setScale(-1,1)
            skinName:setFontName(UIUtils.ttfName)
            skinName:setColor(cc.c3b(255, 255, 255))
            skinName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
            skinName:setRotation(41)
            skinName:setPosition(44,36)
            skinTag:addChild(skinName)
            skinTag:setScale(-0.6,0.6)
            iconColor:addChild(skinTag)
        elseif skinTag then
            skinTag:setVisible(typeId == 102 or typeId == 105)
        end

        ---法术书类型
        local skillId = ModelManager:getInstance():getModel("SpellBooksModel"):getCacheTab()[num_itemid]
        -- print("skillId",skillId)
        local skillBookFrameImage = iconColor:getChildByName("skillBookFrameImage")
        -- local skillBookTypeImage = iconColor:getChildByName("skillBookTypeImage")
        if skillId then
            local skillData = tab:SkillBookBase(skillId)
            local skill_type = skillData.type
            playerSkillID = skillData.skill_id
            --[[ 暂时注释掉，后面可能会恢复
            --碎片角标
            if not skillBookTypeImage then
                skillBookTypeImage = ccuiImageView:create()
                skillBookTypeImage:setAnchorPoint(1, 1)
                skillBookTypeImage:setName("skillBookTypeImage")
                skillBookTypeImage:setPosition(inView:getContentSize().width, inView:getContentSize().height)
                skillBookTypeImage:loadTexture("globalImageUI_skillBookType"..skill_type..".png",1)
                iconColor:addChild(skillBookTypeImage,100)
            else
                skillBookTypeImage:loadTexture("globalImageUI_skillBookType"..skill_type..".png",1)
                skillBookTypeImage:setVisible(true)
            end
            -]]
            --icon上圆圈
            if not skillBookFrameImage then
                skillBookFrameImage = ccuiImageView:create()
                skillBookFrameImage:loadTexture("globalImageUI_skillBookFram" .. color ..".png",1)
                skillBookFrameImage:setName("skillBookFrameImage")
                skillBookFrameImage:setPosition(iconColor:getContentSize().width/2+0.5, iconColor:getContentSize().height/2+2)
                iconColor:addChild(skillBookFrameImage,7)
                -- skillBookFrameImage:setScale(0.85)
            else
                skillBookFrameImage:loadTexture("globalImageUI_skillBookFram" .. color ..".png",1)
                skillBookFrameImage:setVisible(true)
            end
            itemIcon:setScale(0.86)
        else
            if skillBookFrameImage then
                skillBookFrameImage:setVisible(false)
            end
            -- if skillBookTypeImage then
            --     skillBookTypeImage:setVisible(false)
            -- end
        end
    end



    -- local accessIsOpen = self._modelMgr:getModel("ItemModel"):approatchIsOpen(inTable.itemId)
    -- 1 加锁  2 加加号
    if inTable.suo then
        local suoBg = iconColor:getChildByFullName("suoBg")
        local black = iconColor:getChildByFullName("black")
        if inTable.suo == 1 then
            if not suoBg then
                suoBg = ccuiImageView:create()
                suoBg:loadTexture("globalPanelUI7_zhezhao.png",1)
                -- suoBg:setAnchorPoint(0.5, 0.5)
                suoBg:setPosition(inView:getContentSize().width*0.5, inView:getContentSize().height*0.5)
                suoBg:setName("suoBg")
                iconColor:addChild(suoBg,100)

                local suo = ccuiImageView:create()
                suo:loadTexture("globalImageUI5_treasureLock.png",1)
                -- suo:setAnchorPoint(0.5, 0.5)
                suo:setPosition(inView:getContentSize().width*0.5, inView:getContentSize().height*0.5)
                suo:setName("suo")
                suoBg:addChild(suo)

            else
                suoBg:setVisible(true)
            end
        elseif inTable.suo == 2 then
            if not black then
                black = cc.LayerColor:create(ccc4b(0,0,0,80),iconColor:getContentSize().width,iconColor:getContentSize().height) 
                black:setName("black")
                -- black:setAnchorPoint(cc.p(0.5,0.5))
                black:setPosition(0,0)
                -- black:setPosition(inView:getContentSize().width/2,inView:getContentSize().height/2)
                iconColor:addChild(black,8)
                local itemRedBg = ccuiImageView:create()
                itemRedBg:loadTexture("golbalIamgeUI5_add.png",1)
                itemRedBg:setScale(0.5)
                itemRedBg:setName("itemRedBg")
                -- itemRedBg:setAnchorPoint(0.5,0.5)
                itemRedBg:setPosition(iconColor:getContentSize().width/2,iconColor:getContentSize().height/2)
                black:addChild(itemRedBg,10)
            end
            black:setVisible(true)
        else
            if suoBg then
                suoBg:setVisible(false)
            end
            if black then
                black:setVisible(false)
            end
        end
    end

    if iconColor.numLab ~= nil
        and not inTable.hideNumLab and inTable.num ~= nil and  (inTable.num ~= nil and inTable.num ~= -1) then 
        local numLab = iconColor.numLab
        if inTable.num == 0 then
            numLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
        else
            numLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
        end
        local formatNum = ItemUtils.formatItemCount(inTable.num,"w")
        numLab:setString(formatNum)
        numLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        iconColor.numLab:setVisible(true)

        -- if symbol ~= "" then
        --  local index = string.find(formatNum,symbol)
        --  local length = string.len(formatNum)
        --  for i=1 ,string.len(symbol) do
        --      local tail = numLab:getVirtualRenderer():getLetter(length-i)
        --      tail:setPositionY(tail:getPositionY()-4+i)
        --  end
        -- end
    else
        iconColor.numLab:setVisible(false)
        -- inView:getChildByFullName("numBg"):setVisible(false)
    end

    if iconColor.nameLab ~= nil
        and inTable.name ~= nil 
        and inTable.name > 0 then 
        iconColor.nameLab:setString(inTable.name)
    end

    
    local boxIcon = inView.boxIcon
    if boxIcon ~= nil and inTable.itemData then 
        -- color = color or inTable.itemData.color or 1
        -- print("string.sub(inTable.itemId or inTable.itemData.id,1,2) == ",string.sub(inTable.itemId or inTable.itemData.id,1,2) == "40")
        boxIcon:setScale(scaleNum)
        boxIcon:loadTexture("globalImageUI6_itembg_".. color ..".png", 1)
        boxIcon:setContentSize(92, 92)
        -- boxIcon:setOpacity(0)
    end
    
    -- local iconColor = inView:getChildByFullName("iconColor")
    if inTable.itemData then
        -- --print("itemData,color",inTable.itemId,inTable.itemData.color)
        color = color or inTable.itemData.color or 1

        local colorPng = "globalImageUI4_squality" .. color .. ".png"
        iconColor:loadTexture(colorPng, 1)
        inView.textureName = colorPng
        local treasureCorner = iconColor:getChildByName("treasureCorner")
        local treasureStar = iconColor:getChildByName("treasureStar")
        if toolD and toolD.typeId == 5 and not inTable.treasureCircle then -- 非圆
            -- iconColor:setVisible(false)
            if not treasureCorner then
                treasureCorner = ccuiImageView:create()
                treasureCorner:loadTexture("globalImageUI_treasureIcon" .. color ..".png",1)
                treasureCorner:setName("treasureCorner")
                treasureCorner:setPosition(iconColor:getContentSize().width/2+0.5, iconColor:getContentSize().height/2)
                iconColor:addChild(treasureCorner,7)
                treasureCorner:setScale(0.85)
            else
                treasureCorner:loadTexture("globalImageUI_treasureIcon" .. color ..".png",1)
                treasureCorner:setVisible(true)
            end
            -- 显示星级
            -- local disInfo = ModelManager:getInstance():getModel("TreasureModel"):getTreasureById(inTable.itemId)
            local starNum = inTable.starNum or ModelManager:getInstance():getModel("TreasureModel"):getDisTreasureStar(inTable.itemId)
            -- local smallStar = disInfo and disInfo.ss or 0
            if (starNum > 0) and inTable.showStar then
                if not treasureStar then
                    treasureStar = ccuiImageView:create()
                    treasureStar:loadTexture("globalImageUI6_iconStar" .. starNum ..".png",1)
                    treasureStar:setName("treasureStar")
                    treasureStar:setPosition(inView:getContentSize().width/2, 10)
                    iconColor:addChild(treasureStar,7)
                    treasureStar:setScale(1)
                else
                    treasureStar:loadTexture("globalImageUI6_iconStar" .. starNum ..".png",1)
                    treasureStar:setVisible(true)
                end
            elseif treasureStar then
                treasureStar:setVisible(false)
            end
        else
            if treasureCorner then
                treasureCorner:setVisible(false)
            end
            if treasureStar then
                treasureStar:setVisible(false)
            end
        end
        -- 加背景光效
        local bgMc
        local bgMcname2

        --[[
        -- special
        -- local noEffectItem = {905001,905002,905003,905004,905005,
        --                    905006,905007,905008,905009,905010,
        --                    905011,905012,905013,905014,905015,
        --                   39991,39993,39994,39995,39996,39999}
        local haveEffect4 = {904001,904002,904003,304002,310001}
        local sacleNum = 1
        local offsetX = 0

        local effect = inTable.effect --true 不加特效
        local bgEffect = iconColor:getChildByName("bgMc")
        if not effect then
            if not inTable.isBranchDrop then
                if inTable.itemData.color == 5 then
                    -- bgMcName = "huangguang_toolgetanim"
                    --屏蔽IconUtils.iconIdMap里道具特效
                    if table.find(IconUtils.iconIdMap, inTable.itemId) == nil  then
                        -- sacleNum = 0.98
                        if inTable.fromChouka then
                            -- bgMcName1 = "wupinguang_itemeffectcollection"
                            bgMc = IconUtils:addEffectByName({"wupinguang_itemeffectcollection"})
                            offsetX = -3
                        else
                            bgMc = IconUtils:addEffectByName({"wupinguang_itemeffectcollection",
                                                              "tongyongdibansaoguang_itemeffectcollection",
                                                              "wupinkuangxingxing_itemeffectcollection"})
                        end
                    end
                elseif inTable.itemData.color == 4 then
                    -- bgMcName1 = "wupinguangxia_itemiconeffect"
                    if table.find(IconUtils.iconIdMap, inTable.itemId) == nil then
                        local tabId = toolD["tabId"]
                        if tabId == 9 and table.find(haveEffect4, inTable.itemId) ~= nil then 
                            -- sacleNum = 1.22
                            bgMc = IconUtils:addEffectByName({"tongyongdibansaoguang_itemeffectcollection",
                                                              "wupinkuangxingxing_itemeffectcollection"})
                        elseif tabId ~= 9 and tabId ~= 2 then
                            -- sacleNum = 1.22
                             bgMc = IconUtils:addEffectByName({"tongyongdibansaoguang_itemeffectcollection",
                                                              "wupinkuangxingxing_itemeffectcollection"})
                        end
                    end
                end
            else
                -- sacleNum = 0.98
                bgMc = IconUtils:addEffectByName({"wupinguang_itemeffectcollection",
                                                  "tongyongdibansaoguang_itemeffectcollection",
                                                  "wupinkuangxingxing_itemeffectcollection"})
            end
            --]]

        -- [[
        local sacleNum = 1
        local offsetX = 0
        local effect = inTable.effect --true 不加特效
        local bgEffect = iconColor:getChildByName("bgMc")
        if bgEffect then  -- 用于刷新
            bgEffect:removeFromParent()
            bgEffect = nil
        end
        local diguang = boxIcon:getChildByFullName("diguangMc")
        if not effect then
            local shineData = inTable.itemData.shine
            if shineData then
                local isDiguang = false
                local mcTb = {}
                for k,v in pairs(shineData) do
                    if 4 == v then
                        isDiguang = true
                    else
                        table.insert(mcTb, itemEffect[v])
                    end 
                end
                bgMc = IconUtils:addEffectByName(mcTb,iconColor)

                if not bgEffect and bgMc then  
                    bgMc:setScale(sacleNum) 
                    bgMc:setName("bgMc")
                    iconColor:addChild(bgMc,10)
                else
                    if bgEffect then
                        bgEffect:setVisible(true)
                    end
                end
                
                if isDiguang and not diguang then  
                    local diguangMc =  mcMgr:createViewMC(itemEffect[4], true, false, function (_, sender)
                        sender:gotoAndPlay(0)
                    end,RGBA8888) 
                    diguangMc:setName("diguangMc")
                    diguangMc:setPosition(boxIcon:getContentSize().width*0.5-4,boxIcon:getContentSize().height*0.5)
                    -- diguangMc:setScale(1.2)    
                    boxIcon:addChild(diguangMc,-2)
                else
                    if diguang then
                        diguang:setVisible(true)
                    end
                end
            end
            --]]
        else
            if bgEffect then
                bgEffect:setVisible(false)
            end
            if diguang then
                diguang:setVisible(false)
            end
        end

    end

    -- 部分地方只为展示icon 无任何事件
    if not inTable.eventStyle then inTable.eventStyle = 1 end
    if inTable.eventStyle ~= 0 then
        inView:setTouchEnabled(true)
        if inTable.swallowTouches == nil then
            inView:setSwallowTouches(false)
        else
            inView:setSwallowTouches(inTable.swallowTouches)
        end
        local showView = nil
        local viewMgr = ViewManager:getInstance()
        local function endTouchEvent(inTempView)
            --print("endTouchEvent=======")
            -- inTempView:setScale(inTempView:getScale() + 0.05)
            if inTable.eventStyle == 1 and 
                showView ~= nil then
                --viewMgr:closeDialog(showView)
            end
        end
        if inTable.eventStyle == 1 or inTable.eventStyle == 3 then
            inView:setScaleAnim(true)
            iconColor:setScaleAnim(true)
            itemIcon:setScaleAnim(true)
            boxIcon:setScaleAnim(true)
        elseif inTable.eventStyle == 4 then
            inView:setScaleAnim(false)
            iconColor:setScaleAnim(false)
            itemIcon:setScaleAnim(false)
            boxIcon:setScaleAnim(false)
            inTable.eventStyle = 1
        elseif inTable.eventStyle == 5 then 
            inView:setScaleAnim(false)
            iconColor:setScaleAnim(false)
            itemIcon:setScaleAnim(false)
            boxIcon:setScaleAnim(false)
            registerTouchEvent(inView, function()
                -- body
            end, function()
                -- body
            end, function()
                -- body
            end, function()
                -- body
            end, function()
                -- body
            end)
            return
        end

        local downX, downY
        registerTouchEvent(inView, function (_, x, y)
            viewMgr:closeHintView()
            if inTable.eventStyle == 1 then
                downX = x
                downY = y
                -- boxIcon:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function( )
                --  viewMgr:showHintView("global.GlobalTipView",{tipType = 1, node = boxIcon, id = inTable.itemId,forceColor = color})
                -- end)))
                -- down

                showView = 1
                -- 展示view
            end
            -- [[因为相应缩放事件需要锚点为0.5,0.5 inview本身是0,0 为了不去修改游戏内大量代码，
            --   将事件相应的缩放动画 直接应用于子节点。
            --   父节点其他动画效果与缩放action也可以隔离 stopallaction
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonBeginAnim(iconColor)
                ButtonBeginAnim(itemIcon)
                ButtonBeginAnim(boxIcon)
            end
            --]] 
        end, function(_, x, y)
            if inTable.eventStyle == 1 then
                -- if (downX and math.abs(downX - x) > 5) or math.abs(downY - y) > 5 then
                --  -- boxIcon:stopAllActions()
                -- end
                -- viewMgr:closeHintView()
            end
        end, 
        function ()
            endTouchEvent(inView)
            -- 2017.5.11 duyuye改tip 为点击出
            if inTable.eventStyle ~= 3 or inTable.showTip == true then
                -- if inTable.showSpecailSkillBookTip and playerSkillID then
                --     viewMgr:showHintView("global.GlobalTipView",{tipType = 2, node = boxIcon, id = playerSkillID, notAutoClose=true})
                -- else
                    viewMgr:showHintView("global.GlobalTipView",{tipType = 1, node = boxIcon, id = tonumber(inTable.itemId),hideTipNum = inTable.hideTipNum,forceColor = color,notAutoClose=true, battleSoulType = inTable.battleSoulType})
                -- end
            end

            if inTable.eventStyle == 1 then
                -- boxIcon:stopAllActions()
                -- viewMgr:closeHintView()
            elseif inTable.eventStyle == 2 then 
                -- 展示需要点击view 
                print("==============================================")
            end
            -- 回调
            if inTable.eventStyle == 3 and
            inTable.clickCallback ~= nil then 
                inTable.clickCallback(inTable.itemId, inTable.num)
            end
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonEndAnim(iconColor)
                ButtonEndAnim(itemIcon)
                ButtonEndAnim(boxIcon)
            end
        end,
        function ()
            if inTable.eventStyle == 1 then
                -- boxIcon:stopAllActions()
                -- viewMgr:closeHintView()
            end
            endTouchEvent(inView)
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonEndAnim(iconColor)
                ButtonEndAnim(itemIcon)
                ButtonEndAnim(boxIcon)
            end
        end--)
        ,
        function( )
            -- if inTable.eventStyle ~= 3 or inTable.showTip == true then
            --     viewMgr:showHintView("global.GlobalTipView",{tipType = 1, node = boxIcon, id = inTable.itemId,forceColor = color})
            -- end
        end)
    end
end

--组合特效
function IconUtils:addEffectByName(nameTable,parentNode)    
    local bgMc = ccui.Layout:create()  
    -- bgMc:setBackGroundColorOpacity(128)
    -- bgMc:setBackGroundColorType(1)
    bgMc:setName("bgMc")
    local width = 0
    if parentNode then
        width = parentNode:getContentSize().width
        bgMc:setContentSize(parentNode:getContentSize().width,parentNode:getContentSize().height)  
    else
        width = 108
        bgMc:setContentSize(108, 108)
    end
    local i = 0
    for k,v in pairs(nameTable) do
        -- print(k,v)
        i = i + 1
        local effectAnim = mcMgr:createViewMC(v, true, false, function (_, sender)
            sender:gotoAndPlay(0)
        end,RGBA8888) 
        effectAnim:setPosition(bgMc:getContentSize().width*0.5,bgMc:getContentSize().height*0.5)         
        effectAnim:setZOrder(i) 
        effectAnim:setScale(width/90)
        bgMc:addChild(effectAnim)

    end
            
    return bgMc
end

--! @desc 更改物品数量
function IconUtils:setItemIconByNum(inView, inNum)
    if inView == nil then
        return
    end
    local numLab    = inView:getChildByFullName("numLab")
    local iconColor = inView:getChildByFullName("iconColor")
    if not numLab and iconColor then
        numLab = iconColor:getChildByFullName("numLab")
    end
    if not numLab then
        return 
    end
    if inNum ~= nil then 
        local formatNum = ItemUtils.formatItemCount(inNum,"w")
        numLab:setString(formatNum)
    else
        numLab:setVisible(false)
    end
end

--[[
--! @function setIeamIconBlack
--! @desc 物品置灰
--! @param inView bgNode node
           inBlack bool 
--! @return bgNode node 
--]]
function IconUtils:setIeamIconBlack(inView, inBlack)
    if inView == nil then
        return
    end
    if inBlack == true then
        inView:setSaturation(-100)
    else
        inView:setSaturation(0)
    end
end

--[[
--! @function createHeadIconById
--! @desc 创建头像icon
--! @param inTable table    相关控制
           art int avatar   字段
           tp  int          1 默认方框 2 英雄圆框 
           avatarFrame int  传入对应框的id
           isSelf      bool 如果是玩家自己的头像，默认取身上的框id
           isQQVip str 玩家qq会员类型
--! @return bgNode node 
--]]
local headIconModelMap = {
    --frame外框统一成圆框  bg_head_mainView 17.01.12 hgf
    {bg = "globalImageUI4_itemBg3.png",frame = "bg_head_mainView.png",frameSize = cc.size(98,98),bgSize = cc.size(85,85)},-- 方框
    {bg = "globalImageUI4_heroBg2.png",frame = "bg_head_mainView.png",frameSize = cc.size(97, 97),bgSize = cc.size(86, 86)},-- 人物框--圆框
    {bg = "globalImageUI4_heroBg2.png",frame = "bg_head_mainView.png",frameSize = cc.size(98, 98),bgSize = cc.size(86, 86)},-- 人物框--圆框
    {bg = "globalImageUI4_itemBg3.png",frame = "bg_head_mainView.png",frameSize = cc.size(92, 92),bgSize = cc.size(80, 80)},-- 人物框--圆框
}

-- 头像框特效
local frameEffect = {
    [1] = {name="touxiangkuangtexiao_touxiangkuang"},                                -- 普通特效
    [2] = {name="qqhuiyuan_touxiangkuang",clipImg="avatarFrame_16_zhezhao.png"},     -- qq会员
    [3] = {name="shijiuzhixin_touxiangkuang",clipImg="avatarFrame_6_zhezhao.png"},   -- 狮鹫之心
    [4] = {name="wujinlianyu_wujinlianyutouxiangkuang"},
    [5] = {name="zhushentouxiangkuang_zhushentouxiangkuangtexiao"},
    [6] = {name="zhubotouxiangtexiao_zhubotouxiang"},
    [7] = {name="tebiefangtantouxiang_tebiefangtantouxiang"},
    [8] = {name="shenpanguantouxiangkuang_shenpanguantouxiangkuang"},
    [9] = {name="kuileilongtouxiangkuang_kuileilongtouxiangkuang"},
    [10] = {name="yonghengzunxiang_yonghengzunxiang"},
    [11] = {name="haihoutouxiangkuang_haihoutouxiangkuang"},
    [12] = {name="sishentouxiangkuang_sishentouxiangkuang"},
    [13] = {name="xiemonvtouxiangkuang_xiemonvtouxiangkuangtexiao"},
    [14] = {name="tanglangtouxiangkuan_tanglangtouxiangkuang"}
}

-- 头像特效
local headEffect = {
    [1] = {name="weideninatouxiangtexiao_weideninapifu"},                                -- 维德尼娜糖果
    [2] = {name="guowangganenjietouxiang_guowangganenjie"},
}

function IconUtils:createHeadIconById(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(headIconModelMap[inTable.tp or 1].frameSize)

    local iconColor = ccuiImageView:create()

    -- iconColor:setAnchorPoint(0.5, 0.5)
    iconColor:setContentSize(headIconModelMap[inTable.tp or 1].frameSize)
    iconColor:setName("iconColor")
    iconColor:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    iconColor:ignoreContentAdaptWithSize(false)
-- iconColor:setVisible(false)
    bgNode:addChild(iconColor,6)

    local headIcon = ccuiImageView:create()

    -- headIcon:setAnchorPoint(0.5, 0.5)
    headIcon:setName("headIcon")
    headIcon:setPosition(iconColor:getContentSize().width/2, iconColor:getContentSize().height/2)
    headIcon:ignoreContentAdaptWithSize(false)


    iconColor:addChild(headIcon,-1)

    local headVipIcon = ccuiImageView:create()
    headVipIcon:setName("headVipIcon")
    headVipIcon:setPosition(5, iconColor:getContentSize().height-5)
    headVipIcon:ignoreContentAdaptWithSize(false)
    iconColor:addChild(headVipIcon,10)

    local boxIcon = ccuiImageView:create()

    -- boxIcon:setAnchorPoint(0.5, 0.5)
    boxIcon:setName("boxIcon")
    boxIcon:setPosition(iconColor:getContentSize().width/2, iconColor:getContentSize().height/2)
    boxIcon:ignoreContentAdaptWithSize(false)

    iconColor:addChild(boxIcon,-2)

    local levelTxt = ccuiText:create()
    levelTxt:setString("")    
    levelTxt:setFontName(UIUtils.ttfName)
    levelTxt:setName("levelTxt")
    levelTxt:setFontSize(18)
    levelTxt:setColor(ccc4b(255,255,255,255))
    levelTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    levelTxt:setAnchorPoint(1, 0)
    levelTxt:setPosition(bgNode:getContentSize().width-8, 10)
    iconColor:addChild(levelTxt,11)


    local tencentIcon = ccuiImageView:create()
    tencentIcon:setAnchorPoint(0.5, 0.5)
    tencentIcon:setName("tencentIcon")
    tencentIcon:setPosition(24, 23)
    tencentIcon:setPosition(iconColor:getContentSize().width * 0.5 - 28, iconColor:getContentSize().height * 0.5 - 30)
    iconColor:addChild(tencentIcon,11) 

    IconUtils:updateHeadIconByView(bgNode, inTable)
    return bgNode
end

--[[
--! @function updateHeadIconByView
--! @desc 更新头像icon相关信息与事件
--! @param inView object 操作icon
--! @param inTable table 相关控制
           art int avatar 字段
           tp int 1 默认方框 2 英雄圆框 
           isQQVip str 玩家qq会员类型
--! @return
--]]

function IconUtils:updateHeadIconByView(inView, inTable)
    if inTable == nil or 
        not (inTable.avatar or inTable.art) then
        return 
    end
    local iconColor = inView:getChildByFullName("iconColor")
    local headIcon = iconColor:getChildByFullName("headIcon")
    if headIcon == nil then 
        return
    end


    -- local sysItem = tab:Tool(inTable.itemId)
    -- 会增加类型判断获取不同底图

    local headIconInfo = headIconModelMap[inTable.tp or 1]
    local boxIcon = iconColor:getChildByFullName("boxIcon")
    if boxIcon ~= nil then 
        boxIcon:loadTexture(headIconInfo.bg, 1)
        boxIcon:setContentSize(headIconInfo.bgSize)
    end
    if iconColor ~= nil then
        local colorPng = "globalImageUI4_heroBg1.png"
        local avatarFrame = inTable.avatarFrame --ModelManager:getInstance():getModel("UserModel"):getData().avatarFrame
        if inTable.isSelf then
            avatarFrame = ModelManager:getInstance():getModel("UserModel"):getData().avatarFrame
        end
        -- if not avatarFrame then
            -- print("++++++没有头像信息++++++++++++")
        -- end
        if avatarFrame then
            local frameTab = tab.avatarFrame[tonumber(avatarFrame)]
            if frameTab then
                local offsetX,offsetY = 0, 0
                local bounderW = 0
                local fu = cc.FileUtils:getInstance()
                local sfc = cc.SpriteFrameCache:getInstance()
                local art = frameTab.icon
                if art == "bg_head_mainView" then
                    offsetX,offsetY = 0, 0
                    bounderW = -10
                end 
                if sfc:getSpriteFrameByName(art ..".jpg") then
                    iconColor:loadTexture("" .. art ..".jpg", 1)
                elseif sfc:getSpriteFrameByName(art ..".png") then
                    iconColor:loadTexture("" .. art ..".png", 1) 
                else
                    -- print("头像资源是空或者需要显示默认头像框......",art)
                    iconColor:loadTexture("bg_head_mainView.png",1)
                    offsetX,offsetY = 0, 0
                    bounderW = -10
                end
                -- iconColor:ignoreContentAdaptWithSize(false)
                local size = headIconInfo.frameSize
                iconColor:setContentSize(size.width+10+bounderW,size.height+10+bounderW)
                -- iconColor:setAnchorPoint(cc.p(0,0))
                -- iconColor:setPosition(cc.p(-20+offsetX,-18+offsetY))
                iconColor:setPosition(inView:getContentSize().width/2-0+offsetX, inView:getContentSize().height/2+offsetY)

                -- 头像框加特效
                -- shine
                local bgEffect = iconColor:getChildByName("bgMc")
                if bgEffect then
                    bgEffect:removeFromParent()
                end
                if frameTab.shine then
                    local shineData = frameTab.shine 
                    if shineData then
                        local realWidth = 117   -- 头像框图片真实宽度                       
                        local bgMc = IconUtils:addHeadFrameMc(iconColor,shineData[1],frameTab.effect ,iconColor:getContentSize().width/realWidth)
                        bgMc:setName("bgMc")                                  
                    end       
                end
            end
        else
          iconColor:loadTexture(headIconInfo.frame, 1)
          iconColor:setContentSize(headIconInfo.frameSize)
        end 
    end
    inView:setContentSize(headIconInfo.frameSize)
    headIcon:setPosition(iconColor:getContentSize().width/2, iconColor:getContentSize().height/2)
    boxIcon:setPosition(iconColor:getContentSize().width/2, iconColor:getContentSize().height/2)

    local avatar = tonumber(inTable.avatar)
    if avatar == 0 then
        avatar = 1101
    end
    local avatarData = tab:RoleAvatar(avatar)
    local avatarShine = avatarData and avatarData.shine or nil
    local art = inTable.art or ( avatarData and tab:RoleAvatar(avatar).icon) or tab:RoleAvatar(1101).icon
    local fu = cc.FileUtils:getInstance()
    local sfc = cc.SpriteFrameCache:getInstance()
    local filename = art .. ".jpg"
    if sfc:getSpriteFrameByName(filename) then
        filename = art .. ".jpg"
    elseif sfc:getSpriteFrameByName(art ..".png") then
        filename = art .. ".png"
    end
    headIcon:loadTexture(filename, 1)
    -- headIcon:loadTexture(IconUtils.iconPath .. art .. ".jpg")
    headIcon:setContentSize(80,80)
    -- end
    if headIcon.__shine then 
        headIcon.__shine:removeFromParent()
        headIcon.__shine = nil
    end
    -- 添加头像特效
    if avatarShine then 
        -- 头像加特效
        local realWidth = 82   -- 头像图片真实宽度                       
        headIcon.__shine = IconUtils:addHeadFrameMc(headIcon,avatarShine[1],avatarData.effect ,headIcon:getContentSize().width/realWidth,true)
    end

    local levelTxt = iconColor:getChildByFullName("levelTxt")
    if inTable.level then
        local param = {lvlStr = inTable.level, lvl = inTable.level, plvl = inTable.plvl, disScale = 0.8}
        UIUtils:adjustLevelShow(levelTxt, param, 2)
    end

    local headVipIcon = iconColor:getChildByFullName("headVipIcon")
    if inTable.vipLvl then
        headVipIcon:setString(tonumber(inTable.vipLvl))
        headVipIcon:setVisible(tonumber(inTable.vipLvl) > 0)
    end
    

    local tencentIcon = iconColor:getChildByFullName("tencentIcon")
    if inTable.tencetTp ~= nil and inTable.tencetTp ~= "" then
        tencentIcon:setVisible(true)

        local tencentModel = ModelManager:getInstance():getModel("TencentPrivilegeModel")
        local vipIconName = nil
        if tencentModel.IS_QQ_VIP == inTable.tencetTp then 
            vipIconName = "tencentIcon_vipHead.png"
        elseif tencentModel.IS_QQ_SVIP == inTable.tencetTp then 
            vipIconName = "tencentIcon_sVipHead.png"
        elseif tencentModel.WX_GAME_CENTER == inTable.tencetTp then 
            vipIconName = "tencentIcon_wxHead.png"
        end
        tencentIcon:loadTexture(vipIconName, 1)
        tencentIcon:setPosition(iconColor:getContentSize().width * 0.5 - 28, iconColor:getContentSize().height * 0.5 - 30)
    else
        tencentIcon:setVisible(false)
    end

    if inTable.eventStyle and inTable.eventStyle ~= 0 then
        iconColor:setScaleAnim(true)
        iconColor.__scaleMin = 0.95
        registerClickEvent(iconColor,function() 
        end)
        iconColor:setSwallowTouches(false)
    end

    -- 动态头像 by guojun 2017.3.23
    local roleAvatarD = tab:RoleAvatar(avatar)
    local mc = iconColor:getChildByName("iconMc")
    if roleAvatarD and roleAvatarD.specially then
        if mc and mc._mcname ~= roleAvatarD.specially then
            mc:removeFromParent()
            mc = nil
        end
        if not mc then
            mc = mcMgr:createViewMC(roleAvatarD.specially .. "_touxiangui", true, false, nil, RGBA8888)
            mc:setPosition(iconColor:getContentSize().width/2,iconColor:getContentSize().height/2)
            -- mc:setScale(1.1)
            mc:setName("iconMc")
            mc._mcname = roleAvatarD.specially
            iconColor:addChild(mc,0)
        end
    else
        local mc = iconColor:getChildByName("iconMc")
        if mc then 
            mc:removeFromParent()
        end
    end
end

--[[
--! @function createUrlHeadIconById
--! @desc 创建头像icon
--! @param inTable table 相关控制
           art int avatar 字段
           tp int 1 默认方框 2 英雄圆框 
           tencetTp 玩家qq会员类型

--! @return bgNode node 
--]]
local headIconModelMap = {
    {bg = "globalImageUI4_itemBg3.png",frame = "globalImageUI4_iquality0.png",frameSize = cc.size(98,98),bgSize = cc.size(85,85)},-- 方框
    {bg = "globalImageUI4_heroBg2.png",frame = "globalImageUI4_heroBg1.png",frameSize = cc.size(97, 97),bgSize = cc.size(86, 86)},-- 人物框--圆框
    {bg = "globalImageUI4_heroBg2.png",frame = "globalImageUI5_headBg.png",frameSize = cc.size(93, 94),bgSize = cc.size(86, 86)},-- 人物框--圆框
    {bg = "bg_head_mainView.png",frame = "bg_head_mainView.png",frameSize = cc.size(102, 103),bgSize = cc.size(86, 86)},-- 人物框--圆框
}
function IconUtils:createUrlHeadIconById(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(headIconModelMap[inTable.tp or 1].frameSize)

    local headIcon = ccuiImageView:create()

    -- headIcon:setAnchorPoint(0.5, 0.5)
    headIcon:setName("headIcon")
    headIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    headIcon:ignoreContentAdaptWithSize(false)    

    bgNode:addChild(headIcon,1)

    local boxIcon = ccuiImageView:create()

    -- boxIcon:setAnchorPoint(0.5, 0.5)
    boxIcon:setName("boxIcon")
    boxIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    boxIcon:ignoreContentAdaptWithSize(false)


    bgNode:addChild(boxIcon,-1)

    local iconColor = ccuiImageView:create()

    -- iconColor:setAnchorPoint(0.5, 0.5)
    iconColor:setName("iconColor")
    iconColor:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    iconColor:ignoreContentAdaptWithSize(false)
-- iconColor:setVisible(false)
    bgNode:addChild(iconColor,6)


    local levelTxt = ccuiText:create()
    levelTxt:setString("")    
    levelTxt:setFontName(UIUtils.ttfName)
    levelTxt:setName("levelTxt")
    levelTxt:setFontSize(24)
    levelTxt:setColor(ccc4b(255,255,255,255))
    levelTxt:enableOutline(ccc4b(0, 0, 0, 255),2)
    levelTxt:setAnchorPoint(1, 0)
    levelTxt:setPosition(bgNode:getContentSize().width - 9, 4)
    bgNode:addChild(levelTxt,11)

    local tencentIcon = ccuiImageView:create()
    tencentIcon:setAnchorPoint(0.5, 0.5)
    tencentIcon:setName("tencentIcon")
    tencentIcon:setPosition(iconColor:getContentSize().width * 0.5 - 28, iconColor:getContentSize().height * 0.5 - 30)
    iconColor:addChild(tencentIcon,11) 

    IconUtils:updateUrlHeadIconByView(bgNode, inTable)
    return bgNode
end

--[[
--! @function updateUrlHeadIconByView
--! @desc 更新头像icon相关信息与事件
--! @param inView object 操作icon
--! @param inTable table 相关控制
           art int avatar 字段
           tp int 1 默认方框 2 英雄圆框 
--! @return
--]]

function IconUtils:updateUrlHeadIconByView(inView, inTable)
    if inTable == nil or 
        not (inTable.url or inTable.openid) then
        return 
    end
    local headIcon = inView:getChildByFullName("headIcon")
    if headIcon == nil then 
        return
    end

    -- local sysItem = tab:Tool(inTable.itemId)
    -- 会增加类型判断获取不同底图

    local headIconInfo = headIconModelMap[inTable.tp or 1]
    local boxIcon = inView:getChildByFullName("boxIcon")
    local iconColor = inView:getChildByFullName("iconColor")
    if boxIcon ~= nil then 
        boxIcon:loadTexture(headIconInfo.bg, 1)
        boxIcon:setContentSize(headIconInfo.bgSize)
    end
    if iconColor ~= nil then
        local colorPng = "globalImageUI4_heroBg1.png"
        iconColor:loadTexture(headIconInfo.frame, 1)
        iconColor:setContentSize(headIconInfo.frameSize)
    end
    inView:setContentSize(headIconInfo.frameSize)
    
    local fileUtils = cc.FileUtils:getInstance()

    local writablePath = fileUtils:getWritablePath()
    local downloadLocalPath = writablePath .. "imageCache/"
    if OS_IS_ANDROID then
        local appInformation = AppInformation:getInstance()
        if appInformation:getValue("external_asset_path") ~= nil and appInformation:getValue("external_asset_path") ~= "" then
            -- 如果 sd 卡可用 , 存储到sd下
            downloadLocalPath = appInformation:getValue("external_asset_path") .. "imageCache/"
        end
    end
    
    if (not fileUtils:isDirectoryExist(downloadLocalPath)) then
        fileUtils:createDirectory(downloadLocalPath)
    end

    local fileName = "url_" .. inTable.openid
    local filePath = downloadLocalPath .. fileName
    headIcon:removeAllChildren()
    if fileUtils:isFileExist(filePath) then
        local hasImage = true
        if not pcall(function ()
            hasImage = (cc.Director:getInstance():getTextureCache():addImage(filePath) ~= nil)
        end) then
            hasImage = false
        end
        if hasImage then
            headIcon:loadTexture(filePath, 2)
        else
            local sp
            pcall(function ()
                sp = CacheGif:create(filePath)
                headIcon:loadTexture("globalImageUI6_meiyoutu.png", 1)
            end)
            if sp then
                sp:setPosition(42, 42)
                sp:setScale(85 / sp:getContentSize().width)
                headIcon:addChild(sp)
            else
                headIcon:loadTexture("ti_jibing.jpg", 1)
                fileUtils:removeFile(filePath)
            end
        end
    else
        headIcon:loadTexture("ti_jibing.jpg", 1)
        if IconUtils.urlImageCache == nil then
            IconUtils.urlImageCache = {}
        end
        inView.fileName = filePath
        inTable.url = string.gsub(inTable.url, "https", "http")
        pc.NetServer:getInstance():registHttpEventHandler(function (_, state, msg) 
            if state == 0 then
                for _filename, _headIcon in pairs(IconUtils.urlImageCache) do
                    if _headIcon._filename == _filename and fileUtils:isFileExist(_filename) then
                        local hasImage = true
                        if not pcall(function ()
                            hasImage = (cc.Director:getInstance():getTextureCache():addImage(_filename) ~= nil)
                        end) then
                            hasImage = false
                        end
                        _headIcon:removeAllChildren()
                        if hasImage then
                            _headIcon:loadTexture(_filename, 2)
                        else
                            local sp
                            pcall(function ()
                                sp = CacheGif:create(_filename)
                                _headIcon:loadTexture("globalImageUI6_meiyoutu.png", 1)
                            end)
                            if sp then
                                sp:setPosition(42, 42)
                                sp:setScale(85 / sp:getContentSize().width)
                                _headIcon:addChild(sp)
                            else
                                _headIcon:loadTexture("ti_jibing.jpg", 1)
                                fileUtils:removeFile(_filename)
                            end
                        end
                        IconUtils.urlImageCache[_filename] = nil
                    end
                end
            end
        end)
        
        local taskid = pc.NetServer:getInstance():sendHttpFile(filePath, inTable.url)
        IconUtils.urlImageCache[filePath] = headIcon
        headIcon._filename = filePath
    end
    headIcon:setContentSize(85,85)

    local levelTxt = inView:getChildByFullName("levelTxt")
    if inTable.level then
        levelTxt:setString(tonumber(inTable.level))
    end

    local tencentIcon = iconColor:getChildByFullName("tencentIcon")
    if inTable.tencetTp ~= nil and inTable.tencetTp ~= "" then
        tencentIcon:setVisible(true)

        local tencentModel = ModelManager:getInstance():getModel("TencentPrivilegeModel")
        local vipIconName = nil
        if tencentModel.IS_QQ_VIP == inTable.tencetTp then 
            vipIconName = "tencentIcon_vipHead.png"
        elseif tencentModel.IS_QQ_SVIP == inTable.tencetTp then 
            vipIconName = "tencentIcon_sVipHead.png"
        elseif tencentModel.WX_GAME_CENTER == inTable.tencetTp then 
            vipIconName = "tencentIcon_wxHead.png"
        end
        tencentIcon:loadTexture(vipIconName, 1)
        tencentIcon:setPosition(iconColor:getContentSize().width * 0.5 - 28, iconColor:getContentSize().height * 0.5 - 30)
    else
        tencentIcon:setVisible(false)
    end
end

--[[
--! @function createTreasureIcon
--! @desc 更新头像icon相关信息与事件
--! @param inView object 操作icon
--! @param inTable table 相关控制
           art int avatar 字段

--! @return
--]]
function IconUtils:createTreasureIcon(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(123,123)

    local TreasureIcon = ccuiImageView:create()

    -- TreasureIcon:setAnchorPoint(0.5, 0.5)
    TreasureIcon:setName("TreasureIcon")
    TreasureIcon:setPosition(bgNode:getContentSize().width/2+5, bgNode:getContentSize().height/2+5)
    TreasureIcon:ignoreContentAdaptWithSize(false)


    bgNode:addChild(TreasureIcon,1)

    local boxIcon = ccuiImageView:create()

    -- boxIcon:setAnchorPoint(0.5, 0.5)
    boxIcon:setName("boxIcon")
    boxIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    boxIcon:ignoreContentAdaptWithSize(false)


    bgNode:addChild(boxIcon,-1)

    local iconColor = ccuiImageView:create()

    -- iconColor:setAnchorPoint(0.5, 0.5)
    iconColor:setName("iconColor")
    iconColor:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    iconColor:ignoreContentAdaptWithSize(false)
-- iconColor:setVisible(false)
    bgNode:addChild(iconColor,6)

    local lock = ccuiImageView:create()
    -- lock:setAnchorPoint(0.5, 0.5)
    lock:setName("lock")
    lock:setPosition(bgNode:getContentSize().width/2+5, bgNode:getContentSize().height/2+5)
    lock:ignoreContentAdaptWithSize(false)
    lock:loadTexture("globalImageUI5_treasureLock.png",1)
    lock:setContentSize(49,57)
-- lock:setVisible(false)
    bgNode:addChild(lock,10)

    local numLab = ccuiText:create()
    numLab:setString("")
    numLab:setName("numLab")
    numLab:setFontSize(20)
    numLab:setColor(UIUtils.colorTable.ccColor1)
    -- numLab:disableEffect()
    numLab:enableOutline(ccc4b(0, 0, 0, 255),2)
    numLab:setAnchorPoint(1, 0)
    numLab:setPosition(bgNode:getContentSize().width - 11, 11)
    numLab:setFontName(UIUtils.ttfName)
    bgNode:addChild(numLab,11)

    IconUtils:updateTreasureIconByView(bgNode, inTable)
    return bgNode
end

--[[
--! @function updateTreasureIconByView
--! @desc 更新头像icon相关信息与事件
--! @param inView object 操作icon
--! @param inTable table 相关控制
           art int avatar 字段
           tp int 1 默认方框 2 英雄圆框 
--! @return
--]]
local TreasureColorMap = {2,3,4,5}
function IconUtils:updateTreasureIconByView(inView, inTable)
    if inTable == nil or 
        not (inTable.id or inTable.treasureData) then
        return 
    end
    local TreasureIcon = inView:getChildByFullName("TreasureIcon")
    if TreasureIcon == nil then 
        return
    end
    if inTable.treasureData == nil then
        inTable.treasureData = tab:ComTreasure(inTable.id)
    end

    -- local sysItem = tab:Tool(inTable.itemId)
    -- 会增加类型判断获取不同底图

    
    local boxIcon = inView:getChildByFullName("boxIcon")
    local iconColor = inView:getChildByFullName("iconColor")
    local lock = inView:getChildByFullName("lock")
    if boxIcon ~= nil then 
        -- boxIcon:loadTexture("globalImageUI4_itemBg2.png", 1)
        boxIcon:loadTexture("treasureShop_color" .. (inTable.treasureData.quality or 2) .. ".png", 1)
        boxIcon:setContentSize(121,121)
    end
    -- if iconColor ~= nil then
    --  iconColor:loadTexture("globalImageUI4_squality" .. (inTable.treasureData.quality or 1) .. ".png", 1)
    --  iconColor:setContentSize(inView:getContentSize())
    -- end

    local art = inTable.treasureData.icon 

    local filename = IconUtils.iconPath .. art .. ".png"
    TreasureIcon:loadTexture(filename, 1)
    local isGray = inTable.isGray
    if isGray then
        TreasureIcon:setSaturation(-180)
        -- TreasureIcon:setVisible(false)
        lock:setVisible(true)
    else
        TreasureIcon:setSaturation(0)
        -- TreasureIcon:setVisible(true)
        lock:setVisible(false)
    end
    local numLab = inView:getChildByFullName("numLab")
    if inTable.stage and inTable.stage > 0 then
        numLab:setString("+" .. inTable.stage)
    else
        numLab:setString("")
    end
    -- TreasureIcon:loadTexture(IconUtils.iconPath .. art .. ".jpg")
    TreasureIcon:setContentSize(100,100)
    -- end
end
--[[
--! @function createTeamIconById
--! @desc 创建怪兽icon
--! @param inTable table 相关控制
           teamData table 数据
           sysTeamData table 数据
           quality int 品质
           quaAddition int 品质加成
           eventStyle int 事件类型 
                    0:无事件响应,
                    1:长按显示信息,
                    2:点击显示弹出框信息,
                    3:回调点击事件
           clickCallback 点击毁掉事件
           isGray bool 是否置灰

--! @return bgNode node 
--]]
function IconUtils:createTeamIconById(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(107, 107)

    local teamIcon = ccuiImageView:create()

 --    if not inTable.noIconBg then
    --     local teamIconBg = ccuiImageView:create() -- ccSprite:createWithSpriteFrameName("globalImageUI6_itembg_1.png")
    --     teamIconBg:setAnchorPoint(cc.p(0.5, 0.5))
    --     teamIconBg:setName("teamIconBg")
    --     teamIconBg:loadTexture("globalImageUI4_squalitybg.png", 1)
    --     teamIconBg:setPosition(cc.p(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2))
    --     bgNode:addChild(teamIconBg)
    -- end

    -- local teamIconBg = ccuiImageView:create() -- ccSprite:createWithSpriteFrameName("globalImageUI6_itembg_1.png")
    -- teamIconBg:setAnchorPoint(cc.p(0.5, 0.5))
    -- teamIconBg:setName("teamIconBg")
    -- teamIconBg:setPosition(cc.p(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2))
    -- bgNode:addChild(teamIconBg)

    -- teamIcon:setAnchorPoint(0.5, 0.5)
    teamIcon:setName("teamIcon")

    teamIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    teamIcon:ignoreContentAdaptWithSize(false)
    bgNode.teamIcon = teamIcon
    bgNode:addChild(teamIcon)

    -- local boxIcon = ccuiImageView:create()

    -- boxIcon:setAnchorPoint(0.5, 0.5)
    -- boxIcon:setName("boxIcon")
    -- boxIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    -- boxIcon:ignoreContentAdaptWithSize(false)

    -- local qualityBg = ccuiImageView:create()
    -- qualityBg:setAnchorPoint(cc.p(0, 1))
    -- qualityBg:setName("qualityBg")
    -- qualityBg:setPosition(cc.p(12, bgNode:getContentSize().height - 2))
    -- qualityBg:ignoreContentAdaptWithSize(false)
    -- bgNode:addChild(qualityBg,2)

    local iconColor = ccuiImageView:create()
    -- iconColor:setAnchorPoint(0.5, 0.5)
    iconColor:setName("iconColor")
    iconColor:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    iconColor:ignoreContentAdaptWithSize(false)    
    iconColor:setContentSize(107, 107)
    iconColor:setCascadeOpacityEnabled(true)
    bgNode.iconColor = iconColor
    bgNode:addChild(iconColor,1)

    local numLabBg = ccuiImageView:create()
    numLabBg:loadTexture("globalImageUI4_flag7.png", 1)
    numLabBg:setAnchorPoint(0, 0)
    numLabBg:setName("numLabBg")
    numLabBg:setPosition(7, 22)
    numLabBg:setCascadeOpacityEnabled(true)
    iconColor.numLabBg = numLabBg
    iconColor:addChild(numLabBg,2)


    -- 数量
    local numLab = ccuiText:create()
    numLab:setString(1000)
    numLab:setName("numLab")
    numLab:setFontName(UIUtils.ttfName)
    numLab:setFontSize(18)
    -- numLab:setAnchorPoint(0.5, 0.5)
    numLab:setPosition(10, 11)
    numLabBg.numLab = numLab
    numLabBg:addChild(numLab,10)
    numLab:enableOutline(ccc4b(0, 0, 0, 255), 1)
    numLab:setColor(UIUtils.colorTable.ccColorNew2)

    -- 品质豆豆
    local iconGem = ccuiImageView:create()
    iconGem:setAnchorPoint(1, 1)
    iconGem:setPosition(iconColor:getContentSize().width - 2, bgNode:getContentSize().height+5)
    iconGem:ignoreContentAdaptWithSize(true)
    -- print("inTable.quality===",inTable.quality)
    iconGem:setName("iconGem")
    iconColor.iconGem = iconGem
    iconColor:addChild(iconGem,3) 

    -- 星级
    local iconStar = ccuiImageView:create()
    iconStar:setName("iconStar")
    iconStar:loadTexture("globalImageUI6_iconStar1.png", 1)
    iconStar:setPosition(iconColor:getContentSize().width/2,iconStar:getContentSize().height/2+2)
    iconStar:ignoreContentAdaptWithSize(true)
    iconColor.iconStar = iconStar
    iconColor:addChild(iconStar,4) 

    -- 标签 ？
    local teamType = ccuiImageView:create()
    teamType:setName("teamType")
    teamType:loadTexture("globalImageUI6_iconStar1.png", 1)
    teamType:setAnchorPoint(0, 1)
    teamType:setPosition(-3,iconColor:getContentSize().height+2)
    teamType:setScale(0.6)
    -- teamType:ignoreContentAdaptWithSize(true)
    iconColor.teamType = teamType
    iconColor:addChild(teamType,4) 

     -- 觉醒后的眼睛标识
    local iconJxEyes = ccuiImageView:create()
    iconJxEyes:setName("iconJxEyes")
    iconJxEyes:loadTexture("globalImageUI_juexingEyes.png", 1)
    iconJxEyes:setPosition(iconColor:getContentSize().width - iconJxEyes:getContentSize().width / 2 - 10 ,iconJxEyes:getContentSize().height + 6)
    iconJxEyes:ignoreContentAdaptWithSize(true)
    iconColor.iconJxEyes = iconJxEyes
    iconColor:addChild(iconJxEyes,5) 

    -- local qualityLab = ccuiText:create()
    -- qualityLab:setString(inTable.quality)
    -- qualityLab:setName("qualityLab")
    -- qualityLab:setFontName(UIUtils.ttfName)
    -- qualityLab:setFontSize(12)
    -- qualityLab:setAnchorPoint(cc.p(0.5, 0.5))
    -- qualityLab:setPosition(cc.p(11, 9))
    -- iconGem:addChild(qualityLab,10)
    -- qualityLab:disableEffect()
    -- qualityLab:enableOutline(ccc4b(0, 0, 0, 255), 1)
    -- qualityLab:setColor(UIUtils.colorTable.ccColorNew2)

    -- 玩家名字
    local userName = ccuiText:create()
    userName:setString("")
    userName:setName("userName")
    userName:setFontName(UIUtils.ttfName)
    userName:setFontSize(18)
    userName:setAnchorPoint(0.5, 0.5)
    userName:setPosition(bgNode:getContentSize().width / 2, -10)
    bgNode.userName = userName
    bgNode:addChild(userName, 10)
    userName:enableOutline(ccc4b(0, 0, 0, 255), 1)
    userName:setColor(UIUtils.colorTable.ccColorNew2)
       
    IconUtils:updateTeamIconByView(bgNode, inTable)
    return bgNode
end 

--[[
--! @function updateItemIconByView
--! @desc 更新怪兽icon
--! @param inTable table 相关控制
           teamData table 数据
           sysTeamData table 数据
           quality int 品质
           quaAddition int 品质加成
           eventStyle int 事件类型 
                    0:无事件响应,
                    1:长按显示信息,
                    2:点击显示弹出框信息,
                    3:回调点击事件
           clickCallback 点击毁掉事件

--! @return bgNode node 
--]]
function IconUtils:updateTeamIconByView(inView, inTable)
    if inTable == nil or 
        inTable.teamData == nil then
        return 
    end
    local teamIcon = inView.teamIcon

    if teamIcon == nil then 
        return
    end
    local isHeroDuel = inTable.isHeroDuel or 0
    inView.userData = inTable
    local isAwaking, aLvl = TeamUtils:getTeamAwaking(inTable.teamData)
    

    local getArtName = function()
        local artName = TeamUtils.getNpcTableValueByTeam(inTable.sysTeamData, "art1")
        if inTable.teamData.sId and tonumber(inTable.teamData.sId) ~= 0 and tonumber(isHeroDuel) == 0 then
            local isChanged = TeamUtils:checkTeamChanged(inTable.sysTeamData.id)
            local skinType = tab.teamSkin[inTable.teamData.sId]["skinget"] or 1
            if tonumber(skinType) == 3 or not isChanged then
                local sysSkinData = tab.teamSkin[inTable.teamData.sId]
                artName = sysSkinData.skinart1
            else
                if tonumber(skinType) == 2 then 
                    local tartName = TeamUtils.getNpcTableValueByTeam(inTable.sysTeamData, "jxart1")
                    if tartName then
                        artName = tartName
                    end
                end
            end
        else
            if isAwaking == true then
                local tartName = TeamUtils.getNpcTableValueByTeam(inTable.sysTeamData, "jxart1")
                if tartName then
                    artName = tartName
                end
            end
        end
        return artName
    end

    local artName = getArtName()
    local filename = IconUtils.iconPath .. artName .. ".jpg"
    local sfc = cc.SpriteFrameCache:getInstance()
    if not sfc:getSpriteFrameByName(filename) then
        local artName = getArtName()
        filename = IconUtils.iconPath .. artName .. ".png"
    end
    teamIcon:loadTexture(filename, 1)

    teamIcon:setContentSize(94, 94)
    
    if inTable.isGray == true then 
        teamIcon:setSaturation(-100)
    else
        teamIcon:setSaturation(0)
    end

    local iconColor = inView.iconColor
    -- local teamIconBg = inView:getChildByFullName("teamIconBg")
    --    teamIconBg:loadTexture("globalImageUI6_itembg_" .. inTable.quality .. ".png")
    local colorPng = nil 
    -- print("inTable.quality",inTable.quality)   
    if inTable.teamData.isSummon then -- 是否为召唤物
        colorPng = "globalImageUI4_iquality0.png"
    else
        if inTable.quality == nil then
            colorPng = "globalImageUI_squality_jin.png"
        else
            local saqualityHorn = iconColor:getChildByFullName("saqualityHorn")
            if not saqualityHorn then
                saqualityHorn = ccuiImageView:create()
                saqualityHorn:setName("saqualityHorn")
                local fScale = 107/97
                saqualityHorn:setScale(fScale)
                saqualityHorn:setPosition(iconColor:getContentSize().width*0.5, iconColor:getContentSize().height*0.5)
                iconColor:addChild(saqualityHorn)
            end
            if isAwaking == true and inTable.quality >= 5 then
                if saqualityHorn then
                    local tstrimg = "globalImageUI4_saquality" .. inTable.quality .. "1.png"
                    saqualityHorn:loadTexture(tstrimg, 1)
                    saqualityHorn:setVisible(true)
                end
                colorPng = "globalImageUI4_saquality" .. inTable.quality .. ".png"
            else
                if saqualityHorn then
                    saqualityHorn:setVisible(false)
                end
                colorPng = "globalImageUI4_squality" .. inTable.quality .. ".png"
            end
        end

    end
    iconColor:loadTexture(colorPng, 1)

    -- local sysItem = tab:Tool(inTable.itemId)
    -- 会增加类型判断获取不同底图
    -- inView:loadTexture(IconUtils:getItemIconById(inTable.itemId), 1)

    local teamType = iconColor.teamType
    if teamType ~= nil then 
        local classlabel = TeamUtils:getClassIconNameByTeamD(inTable.teamData, "classlabel", inTable.sysTeamData)
        if inTable.sysTeamData["match"] then
            local teamD2 = tab.team[inTable.sysTeamData["match"]]
            classlabel = classlabel or TeamUtils:getClassIconNameByTeamD(inTable.teamData, "classlabel", teamD2)
        end
        teamType:loadTexture(classlabel .. ".png", 1)
        if inTable.classType == true then
            teamType:setVisible(true)
        else
            teamType:setVisible(false)
        end
    end


    -- local boxIcon = inView:getChildByFullName("boxIcon")
    -- if boxIcon ~= nil then 
    --  boxIcon:loadTexture("globalImageUI4_iquality0.png", 1)
    --  boxIcon:setContentSize(cc.size(96, 96))
    -- end

    -- 阶
    local iconGem = iconColor:getChildByFullName("gem")
    if iconGem == nil then
        iconGem = ccuiImageView:create()
        iconGem:setAnchorPoint(0.5, 1)
        iconGem:ignoreContentAdaptWithSize(true)
        iconColor:addChild(iconGem,3) 
    end


    if inTable.quaAddition == 0 then
        iconGem:setVisible(false)
    elseif inTable.quaAddition > 1 then
        iconGem:setVisible(true)
        iconGem:loadTexture("globalImageUI_quality" .. inTable.quality .. "_" .. inTable.quaAddition .. ".png", 1)
    else
        iconGem:setVisible(true)
        iconGem:loadTexture("globalImageUI_quality" .. inTable.quality .. ".png", 1)
    end
    iconGem:setPosition(iconColor:getContentSize().width / 2, iconColor:getContentSize().height+8)
    iconGem:setName("gem")
    iconGem:setScale(1.15)

    if inTable.quaAddition == 5 then
        iconGem:setPositionY(iconGem:getPositionY() - 1)
    end

    -- local iconGem = inView:getChildByFullName("iconGem")
    -- if inTable.quaAddition >= 1 then
    --     -- print(inTable.quaAddition, "******************", inTable.quality)
    --     iconGem:loadTexture("globalImageUI_gemQuality" .. (inTable.quality-1) .. ".png", 1)
    --     local qualityLab = iconGem:getChildByFullName("qualityLab")
    --     qualityLab:setString("+" .. inTable.quaAddition)  
    --     iconGem:setVisible(true)
    -- else
    --     iconGem:setVisible(false)
    -- end
    -- 通用特效 guojun_
    if inTable.effect then
        local mc = mcMgr:createViewMC("diguang_itemeffectcollection", true, false, nil, RGBA8888)
        if mc then
            mc:setPosition(iconColor:getContentSize().width/2,iconColor:getContentSize().height/2)
            -- mc:setScale(1.1)
            mc:setName("bgMc")
            inView:addChild(mc,-1)
        end
        local mc = IconUtils:addEffectByName({"tongyongdibansaoguang_itemeffectcollection","wupinkuangxingxing_itemeffectcollection"})  
        if mc then
            -- mc:setPosition(cc.p(iconColor:getContentSize().width/2- 15,iconColor:getContentSize().height/2- 15))
            iconColor:addChild(mc,10)
        end
    end

    local numLabBg = iconColor.numLabBg --:setString(inTable.teamData.level)
    -- numLabBg:loadTexture("globalImageUI4_flag7.png", 1)
    local level = inTable.lzylvdis and inTable.lzylvdis or inTable.teamData.level
    if level then
        if inTable.teamData.isSummon then -- 是否为召唤物
            numLabBg:setVisible(false)
        else
            numLabBg.numLab:setString(level)
        end
    else
        numLabBg:setVisible(false)
    end

    
    -- 星星
    local iconStar = iconColor.iconStar
    if inTable.teamData.isSummon then -- 是否为召唤物
        iconStar:setVisible(false)
    else
        iconStar:setVisible(true)
        local star = inTable.lzystar and inTable.lzystar or inTable.teamData.star
        if iconStar and star and star > 0 then
            iconStar:loadTexture("globalImageUI6_iconStar".. star ..".png",1)
        end
    end

    -- 觉醒标识
    local iconJxEyes = iconColor.iconJxEyes
    iconJxEyes:setVisible(isAwaking)

    -- local starAllWidth = inTable.teamData.star * 14
    -- local beginX  = inView:getContentSize().width / 2 - starAllWidth / 2 - 3
    -- for i= 1 , 6 do
    --     local iconStar = inView:getChildByFullName("star" .. i)
    --     if i <= inTable.teamData.star then 
    --         if iconStar == nil then
    --              iconStar = ccuiImageView:create()

             --    iconStar:setAnchorPoint(cc.p(0, 0))
             --    iconStar:ignoreContentAdaptWithSize(true)
                -- iconStar:loadTexture("globalImageUI6_star1.png", 1)
                -- iconStar:setScale(0.45)
                -- inView:addChild(iconStar,3) 
    --         end
    --         iconStar:setVisible(true)
    --         -- beginX + (i - 1) * starAllWidth
    --         iconStar:setPosition(beginX + (i - 1) * 14, 5)
    --         iconStar:setName("star" .. i)
    --     else
    --         if iconStar ~= nil then
    --             iconStar:setVisible(false)
    --         end
    --     end
    -- end
    -- 部分地方只为展示icon 无任何事件
    if inTable.eventStyle == nil then inTable.eventStyle = 1 end
    if inTable.eventStyle ~= nil
        and inTable.eventStyle ~= 0 then

        teamIcon:setTouchEnabled(true)
        local showView = nil
        local viewMgr = ViewManager:getInstance()
        local function endTouchEvent(inTempView)
            --print("endTouchEvent=======")
            -- inTempView:setScale(inTempView:getScale() + 0.05)
            if inTable.eventStyle == 1 and 
                showView ~= nil then
                --viewMgr:closeDialog(showView)
            end
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            --  -- 判断锚点是不是0.5是为了防止在外部修改inview的锚点为（0.5,0.5），inview（父）和子节点同时有动画，导致动画播放不正常
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonEndAnim(iconColor)
                ButtonEndAnim(teamType) 
                ButtonEndAnim(teamIcon)
            end
        end
        local downX, downY

        -- if inTable.eventStyle ~= 0 then
            -- print("icon .... setScaleAnim true")
            inView:setScaleAnim(true)
            iconColor:setScaleAnim(true)
            teamType:setScaleAnim(true)
            teamIcon:setScaleAnim(true)
        -- end

        registerTouchEvent(teamIcon, function (_, x, y)
            -- inView:setScale(inView:getScale() - 0.05)

            if inTable.eventStyle == 1 then
                -- down
                showView = 1
                local teamIconType
                if inTable.lzylvdis then
                    teamIconType = NewFormationIconView.kIconTypeClimbTowerTeam
                elseif tab:Npc(inTable.teamData.teamId or inTable.teamData.id) then
                    teamIconType = NewFormationIconView.kIconTypeInstanceTeam
                end
                ViewManager:getInstance():showDialog("formation.NewFormationDescriptionView", { iconType = teamIconType or NewFormationIconView.kIconTypeTeam, iconId = inTable.teamData.teamId or inTable.teamData.id,formationType = inTable.formationType,isCustom = inTable.isCustom,isShowOriginScore = inTable.isShowOriginScore }, true)
                -- 展示view
            elseif inTable.eventStyle == 2 then
                downX = x
                downY = y
                inView:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function( )
                    viewMgr:showHintView("global.GlobalTipView",{tipType = inTable.tipType or 8, node = inView, id = inTable.teamData.teamId or inTable.teamData.id,teamData = inTable.teamData,sysTeamData = inTable.sysTeamData})
                end)))
            -- elseif inTable.eventStyle == 3 then
            --     downX = x
            --     downY = y
            --     inView:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function( )
            --         viewMgr:showHintView("global.GlobalTipView",{tipType = inTable.tipType or 8, node = inView, id = inTable.teamData.teamId or inTable.teamData.id,teamData = inTable.teamData,sysTeamData = inTable.sysTeamData})
            --     end)))
            end

                local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
                --  -- 判断锚点是不是0.5是为了防止在外部修改inview的锚点为（0.5,0.5），inview（父）和子节点同时有动画，导致动画播放不正常
                if ax ~= 0.5 or ay ~= 0.5 then
                    ButtonBeginAnim(iconColor)
                    ButtonBeginAnim(teamType)
                    ButtonBeginAnim(teamIcon)
                end
       
        end, nil, 
        function (_, x, y)
            endTouchEvent(inView)

            if inTable.eventStyle == 2 then 
                -- 展示需要点击view 
                if math.abs(downX - x) > 5 or math.abs(downY - y) > 5 then
                    inView:stopAllActions()
                end
                -- viewMgr:closeHintView()
            end
            -- 回调
            if inTable.eventStyle == 3 and
            inTable.clickCallback ~= nil then 
                inTable.clickCallback(inTable.teamData.itemId)
            end  
        end,
        function ()
            if inTable.eventStyle == 2 then 
                -- 展示需要点击view 
                inView:stopAllActions()
                -- viewMgr:closeHintView()
            end
            endTouchEvent(inView)
        end)
    end
end

function IconUtils:setTeamIconStarVisible(inView, inVisible)
    if inView == nil then
        return
    end
    local iconColor = inView.iconColor
    local iconStar = iconColor.iconStar
    if iconStar then
        iconStar:setVisible(false)
    end

    -- if inView.userData == nil then
    --  return
    -- end
    -- local tempTable = inView.userData
    -- for i= 1 , 6 do
 --        local iconStar = inView:getChildByFullName("star" .. i)
 --        if iconStar ~= nil and i <= tempTable.teamData.star then 
 --         iconStar:setVisible(inVisible)
 --        end
 --    end
end

function IconUtils:setTeamIconLevelVisible(inView, inVisible)
    if inView.userData == nil then
        return
    end
    local iconColor = inView:getChildByFullName("iconColor")
    local tempTable = inView.userData
    -- for i= 1 , 4 do
        local iconGem = iconColor:getChildByFullName("numLabBg")
        if iconGem ~= nil then 
            iconGem:setVisible(inVisible)
        end
    -- end
end

function IconUtils:setTeamIconStageVisible(inView, inVisible)
    if inView.userData == nil then
        return
    end
    local iconColor = inView:getChildByFullName("iconColor")
    local tempTable = inView.userData
    for i= 1 , 4 do
        local iconGem = iconColor:getChildByFullName("gem" .. i)
        if iconGem ~= nil then 
            iconGem:setVisible(inVisible)
        end
    end
end


function IconUtils:setTeamIconAwake(inView, isAwaking)
    if inView == nil then 
        return
    end
    local teamIcon = inView.teamIcon
    local artName = TeamUtils.getNpcTableValueByTeam(inTable.sysTeamData, "art1")
    if isAwaking == true then
        local tartName = TeamUtils.getNpcTableValueByTeam(inTable.sysTeamData, "jxart1")
        if tartName then
            artName = tartName
        end
    end

    local filename = IconUtils.iconPath .. artName .. ".jpg"
    teamIcon:loadTexture(filename, 1)
end

--[[
--! @function createSysTeamIconById
--! @desc 创建怪兽系统icon
--! @param inTable table 相关控制
           sysTeamData table 数据
           isGray int 是否灰
           eventStyle int 事件类型 
                    0:无事件响应,
                    1:长按显示信息,
                    2:点击显示弹出框信息,
                    3:回调点击事件
           clickCallback 点击毁掉事件

--! @return bgNode node 
--]]
function IconUtils:createSysTeamIconById(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(107, 107)

    -- local teamIconBg = ccuiImageView:create() -- ccSprite:createWithSpriteFrameName("globalImageUI6_itembg_1.png")
    -- teamIconBg:setAnchorPoint(cc.p(0.5, 0.5))
    -- teamIconBg:setName("teamIconBg")
    -- teamIconBg:loadTexture("globalImageUI4_squalitybg.png", 1)
    -- teamIconBg:setPosition(cc.p(bgNode:getContentSize().width/2 - 1, bgNode:getContentSize().height/2 - 1))
    -- bgNode:addChild(teamIconBg)

    local teamIcon = ccuiImageView:create()
    -- teamIcon:setAnchorPoint(0.5, 0.5)
    teamIcon:setName("teamIcon")
    teamIcon:ignoreContentAdaptWithSize(false)
    teamIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    
    -- teamIcon:setScale(1.2)
    bgNode:addChild(teamIcon)

    local boxIcon = ccuiImageView:create()
    -- boxIcon:setAnchorPoint(0.5, 0.5)
    boxIcon:setName("boxIcon")
    boxIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    boxIcon:ignoreContentAdaptWithSize(false)
    bgNode:addChild(boxIcon)

    local iconColor = ccuiImageView:create()
    -- iconColor:setAnchorPoint(0.5, 0.5)
    iconColor:setName("iconColor")
    iconColor:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    iconColor:ignoreContentAdaptWithSize(false)    
    iconColor:setContentSize(107, 107)
    iconColor:setCascadeOpacityEnabled(true)
    bgNode:addChild(iconColor,1)

    local iconStar = ccuiImageView:create()
    iconStar:setName("iconStar")
    iconStar:ignoreContentAdaptWithSize(true)
    iconStar:loadTexture("globalImageUI6_iconStar1.png", 1)
    iconStar:setPosition(bgNode:getContentSize().width/2,iconStar:getContentSize().height/2+2)
    iconColor:addChild(iconStar,4) 
       
    IconUtils:updateSysTeamIconByView(bgNode, inTable)
    -- print("bgNode===",bgNode:getContentSize().height)
    return bgNode
end

--[[
--! @function updateItemIconByView
--! @desc 更新怪兽系统icon
--! @param inTable table 相关控制
           sysTeamData table 数据
           isGray int 是否灰
           eventStyle int 事件类型 
                    0:无事件响应,
                    1:长按显示信息,
                    2:点击显示弹出框信息,
                    3:回调点击事件

--! @return bgNode node 
--]]
function IconUtils:updateSysTeamIconByView(inView, inTable)
    if inTable == nil then
        return 
    end
    local teamIcon = inView:getChildByName("teamIcon")

    if teamIcon == nil then 
        return
    end
    teamIcon:setContentSize(98, 98)
    local filename = IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(inTable.sysTeamData, "art1") .. ".jpg"
    local sfc = cc.SpriteFrameCache:getInstance()
    if not sfc:getSpriteFrameByName(filename) then
        filename = IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(inTable.sysTeamData, "art1") .. ".png"
    end
    teamIcon:loadTexture(filename,1)

    local boxIcon = inView:getChildByName("boxIcon")
    if boxIcon ~= nil then 
        boxIcon:setContentSize(100, 100)
    end

    local iconColor = inView:getChildByName("iconColor")

    local colorPng = "globalImageUI4_squality1.png"
    if inTable.isJin then  -- 金色框
        colorPng = "globalImageUI_squality_jin.png"
    end
    -- iconColor:setSpriteFrame(colorPng)
    iconColor:loadTexture(colorPng,1)
    iconColor:setContentSize(107, 107)
    local iconStar = iconColor:getChildByFullName("iconStar")
    if inTable.isGray == true then
        teamIcon:setSaturation(-100)
        iconColor:setSaturation(-100)
        iconStar:setVisible(false)
    end 
        local iconStar = iconColor:getChildByFullName("iconStar")
        if iconStar and inTable.sysTeamData.starlevel and inTable.sysTeamData.starlevel > 0 then
            iconStar:loadTexture("globalImageUI6_iconStar".. inTable.sysTeamData.starlevel ..".png",1)
            iconStar:setVisible(true)
        end
        if inTable.star == false then
            iconStar:setVisible(false)
        end
    -- end
    -- 通用特效 guojun_
    if iconColor.effect then
        local mc = mcMgr:createViewMC("diguang_itemeffectcollection", true, false, nil, RGBA8888)
        if mc then
            mc:setPosition(iconColor:getContentSize().width/2,iconColor:getContentSize().height/2)
            -- mc:setScale(1.1)
            mc:setName("bgMc")
            inView:addChild(mc,-1)
        end
        local mc = IconUtils:addEffectByName({"tongyongdibansaoguang_itemeffectcollection","wupinkuangxingxing_itemeffectcollection"},iconColor) 
        if mc then
            -- mc:setPosition(cc.p(iconColor:getContentSize().width/2- 15,iconColor:getContentSize().height/2- 15))
            iconColor:addChild(mc,10)
        end
    end
    -- 星星
    if inTable.eventStyle == 0 then
        inView:setTouchEnabled(false)
    else
        inView:setTouchEnabled(true)
    end
    if inTable.eventStyle == nil then
        inTable.eventStyle = 1
    end
    -- 部分地方只为展示icon 无任何事件
    if inTable.eventStyle ~= nil
        and inTable.eventStyle ~= 0 then

        inView:setTouchEnabled(true)
        if inTable.swallowTouches == nil then
            inView:setSwallowTouches(false)
        else
            inView:setSwallowTouches(inTable.swallowTouches)
        end

        local showView = nil
        local viewMgr = ViewManager:getInstance()
        local function endTouchEvent(inTempView)
            if inTable.eventStyle == 1 and showView ~= nil then
            end
             -- 判断锚点是不是0.5是为了防止在外部修改inview的锚点为（0.5,0.5），inview（父）和子节点同时有动画，导致动画播放不正常
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then                
                ButtonEndAnim(iconColor)
                ButtonEndAnim(teamIcon)
                ButtonEndAnim(boxIcon)
            end

        end

        inView:setScaleAnim(true)
        iconColor:setScaleAnim(true)
        boxIcon:setScaleAnim(true)
        teamIcon:setScaleAnim(true)

        local clickFlag, downX, downY

        registerTouchEvent(inView, function(sender, x, y)
            clickFlag = false
            downX = x 
            downY = y
            -- 点击动画
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            -- 判断锚点是不是0.5是为了防止在外部修改inview的锚点为（0.5,0.5），inview（父）和子节点同时有动画，导致动画播放不正常
            if ax ~= 0.5 or ay ~= 0.5 then                
                ButtonBeginAnim(iconColor)
                ButtonBeginAnim(teamIcon)
                ButtonBeginAnim(boxIcon)
            end
            
        end, function(sender, x, y)
            if downX and math.abs(downX - x) > 5 and downY and math.abs(downY - y) > 5 then
                clickFlag = true
            end
        end, 
        function(sender, x, y)
            endTouchEvent()
            if clickFlag == false then
                if inTable.eventStyle == 1 then
                    showView = 1
                    ViewManager:getInstance():showDialog("formation.NewFormationDescriptionView", {iconType = NewFormationIconView.kIconTypeLocalTeam, iconId = inTable.sysTeamData.teamId or inTable.sysTeamData.id}, true)
                    -- 展示view
                end

                if inTable.eventStyle == 2 then 
                    -- 展示需要点击view 
                end
                -- 回调
                if inTable.eventStyle == 3 and
                inTable.clickCallback ~= nil then 
                    inTable.clickCallback(inTable.sysTeamData.teamId)
                end
            end
        end,
        function(sender, x, y)
            endTouchEvent()           
        end)
    end
end




--[[
--! @function createTeamRuneIconById
--! @desc 创建怪兽符文系统icon
--! @param inTable table 相关控制
           teamData object 怪兽对象
           sysRuneData table 数据
           quality int 品质
           quaAddition int 品质加成
           isUpdate int 是否有更新
           clickCallback 点击毁掉事件
--! @return bgNode node 
--]]
function IconUtils:createTeamRuneIconById(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(46, 46)

    local runeIconBg = ccSprite:createWithSpriteFrameName("globalImageUI6_itembg_1.png")
    -- runeIconBg:setAnchorPoint(0.5, 0.5)
    runeIconBg:setName("runeIconBg")
    runeIconBg:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    bgNode:addChild(runeIconBg)

    local runeIcon = ccSprite:create()
    -- runeIcon:setAnchorPoint(0.5, 0.5)
    runeIcon:setName("runeIcon")
    runeIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    bgNode:addChild(runeIcon)


    -- local redBg = ccSprite:createWithSpriteFrameName("globalImageUI6_itemRedBg.png")
    -- redBg:setAnchorPoint(cc.p(0.5, 0.5))
    -- redBg:setName("redBg")
    -- -- redBg:setOpacity(123)
    -- redBg:setSaturation(-100)
    -- redBg:setPosition(cc.p(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2))
    -- bgNode:addChild(redBg)

    local iconColor = ccSprite:createWithSpriteFrameName("globalImageUI4_squality" .. inTable.quality .. ".png")
    -- iconColor:setAnchorPoint(0.5, 0.5)
    iconColor:setName("iconColor")
    iconColor:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    bgNode:addChild(iconColor,1)

    local arrowUp = ccSprite:createWithSpriteFrameName("globalImageUI5_upArrow.png")
    arrowUp:setAnchorPoint(0.5, 0)
    arrowUp:setName("arrowUp")
    arrowUp:setPosition(bgNode:getContentSize().width, -20)
    bgNode:addChild(arrowUp,1)
        -- arrowUp:setScale(2)

    -- local levelLabBg = ccuiImageView:create()
    -- levelLabBg:loadTexture("globalImageUI4_flag7.png", 1)
    -- levelLabBg:setAnchorPoint(cc.p(0, 1))
    -- levelLabBg:setName("levelLabBg")
    -- -- levelLabBg:setPosition(cc.p(-23, bgNode:getContentSize().height + 24))
    -- levelLabBg:setPosition(cc.p(-16, 20))
    -- bgNode:addChild(bgNode,2)

    local levelLab = ccLabel:createWithTTF(inTable.teamData["el" .. inTable.index] or " 无等级", UIUtils.ttfName, 20)
    -- levelLab:setPosition(12,17)
    levelLab:setPosition(-15, -15)
    levelLab:setAnchorPoint(0, 0)
    bgNode:addChild(levelLab,3)
    levelLab:enableOutline(ccc4b(60,30,10,255), 1)
    levelLab:setName("levelLab")
    levelLab:setColor(ccc3b(255,255,255))
    -- levelLab:setFontSize(18)
    -- levelLab:enableShadow(UIUtils.colorTable.ccTeamNumShadowValue)
    self:updateTeamRuneIconByView(bgNode,inTable)
    return bgNode
end



--[[
--! @function updateTeamRuneIconByView
--! @desc 更新怪兽符文系统icon
--! @param inTable table 相关控制
           sysRuneData table 数据
           quality int 品质
           quaAddition int 品质加成
           isUpdate int 是否有更新
           clickCallback 点击毁掉事件
--! @return bgNode node 
--]]
function IconUtils:updateTeamRuneIconByView(inView, inTable)
    if inTable == nil then
        return 
    end

    local runeIcon = inView:getChildByName("runeIcon")
    if runeIcon == nil then 
        return
    end

    -- local filename = IconUtils.iconPath .. inTable.sysRuneData.art .. ".png"
    local filename = IconUtils.iconPath .. inTable.sysRuneData.art .. ".png"
    local sfc = cc.SpriteFrameCache:getInstance()
    if not sfc:getSpriteFrameByName(filename) then
        filename = IconUtils.iconPath .. inTable.sysRuneData.art .. ".jpg"
    end
    runeIcon:setSpriteFrame(filename)

    -- runeIcon:setTexture(IconUtils.iconPath .. inTable.sysRuneData.art .. ".png")

    -- 品质
    local iconGem = inView:getChildByFullName("gem")
    if iconGem == nil then
        iconGem = ccuiImageView:create()
        iconGem:setAnchorPoint(0.5, 1)
        iconGem:ignoreContentAdaptWithSize(true)
        inView:addChild(iconGem,3) 
    end
    if inTable.quaAddition == 0 then
        iconGem:setVisible(false)
    elseif inTable.quaAddition > 1 then
        iconGem:setVisible(true)
        iconGem:loadTexture("globalImageUI_quality" .. inTable.quality .. "_" .. inTable.quaAddition .. ".png", 1)
    else
        iconGem:setVisible(true)
        iconGem:loadTexture("globalImageUI_quality" .. inTable.quality .. ".png", 1)
    end
    
    iconGem:setPosition(inView:getContentSize().width / 2, inView:getContentSize().height+30)
    iconGem:setName("gem")


    local stageLabBg = inView:getChildByName("stageLabBg")
    if stageLabBg ~= nil then
        local stageLab = stageLabBg:getChildByName("stageLab")
        if inTable.quaAddition ~= 0 then 
            if stageLab ~= nil then 
                stageLab:setString("+" .. inTable.quaAddition)
            end
        else
            if stageLabBg ~= nil then 
                stageLabBg:setVisible(false)
            end
        end
    end

    -- 底图
    local runeIconBg = inView:getChildByName("runeIconBg")
    if runeIconBg == nil then
        return
    end

    local iconColor = inView:getChildByName("iconColor")
    if iconColor ~= nil then 
        iconColor:setSpriteFrame("globalImageUI4_squality" .. inTable.quality .. ".png")
        runeIconBg:setSpriteFrame("globalImageUI6_itembg_" .. inTable.quality .. ".png")
    end
    
    local arrowUp = inView:getChildByName("arrowUp")

    local equLevel = inTable.teamData["el" .. inTable.index]
    local equStage = inTable.teamData["es" .. inTable.index]
    if inTable.isUpdate >= 0 then 
        if arrowUp ~= nil then 
            -- print(inTable.teamData.level , equLevel,"11111111111111" , inTable.index,inTable.quaAddition)
            -- print(".................",equLevel , inTable.sysRuneData.level[inTable.quality],inTable.quality)
            -- if inTable.teamData.level >= inTable.sysRuneData.level[inTable.quality] then
            -- print("=============",equLevel , inTable.sysRuneData.level[equStage])
            if equLevel >= inTable.sysRuneData.level[equStage] and inTable.isUpdate == 1 then
            -- if equLevel >= inTable.sysRuneData.level[equStage] then
            -- if inTable.teamData.level > equLevel then
                arrowUp:setSpriteFrame("globalImageUI5_upArrow.png")  --绿色箭头
                arrowUp:setPosition(inView:getContentSize().width, -20)
                arrowUp:stopAllActions()
                self:setTeamRuneAction(inView)
                arrowUp:setScale(1)
            else -- if inTable.isUpdate == 0 then
                arrowUp:setSpriteFrame("globalImageUI5_upArrow1.png")  -- 黄色箭头
                arrowUp:setPosition(inView:getContentSize().width, -20)
                arrowUp:stopAllActions()
                arrowUp:setScale(1)
            end
            
            arrowUp:setVisible(true)
        end
    else -- if inTable.isUpdate == 0 then 
        if arrowUp ~= nil then
            arrowUp:setVisible(false)
        end
        if arrowUp and inTable.isUpdate == -1 then
            arrowUp:stopAllActions()
            arrowUp:setPosition(inView:getContentSize().width + 0, -20)
            arrowUp:setSpriteFrame("globalImageUI6_team_cha.png")
            arrowUp:setScale(1)
            arrowUp:setVisible(true)
        end
        local modelMgr = ModelManager:getInstance()
        local userlvl = modelMgr:getModel("UserModel"):getData().lvl
        if userlvl >= 4 and userlvl <= 9 then
            arrowUp:setVisible(false)
        end
    end
    -- print("========",inTable.isUpdate)
    -- local redBg = inView:getChildByName("redBg")
    -- if inTable.isUpdate == -1 then
    --     if redBg then
    --         redBg:setVisible(true)
    --     end
    -- else
    --     if redBg ~= nil then
    --         redBg:setVisible(false)
    --     end
    -- end

    -- local levelLabBg = inView:getChildByName("levelLabBg")
    -- local levelLab = levelLabBg:getChildByName("levelLab")
    local levelLab = inView:getChildByName("levelLab")
    -- levelLab:setString(inTable.teamData["el" .. inTable.index])
    -- print(".............",levelLab)
    if levelLab ~= nil then 
        levelLab:setString(inTable.teamData["el" .. inTable.index])
    end
end

-- 控制符文上箭头的大小
function IconUtils:setTeamRuneScale(inView, inScale)
    if inView == nil then
        return
    end
    -- local tempTable = inView.userData
    local arrowUp = inView:getChildByFullName("arrowUp")
    if arrowUp ~= nil then 
        arrowUp:setScale(inScale)
    end
end

-- 控制符文上箭头的抖动
function IconUtils:setTeamRuneAction(inView)
    if inView == nil then
        return
    end
    -- local tempTable = inView.userData
    local arrowUp = inView:getChildByFullName("arrowUp")
    if arrowUp ~= nil then 
        -- arrowUp:setScale(inScale)
        -- local moveUp = cc.MoveTo:create(0.5, cc.p(inView:getContentSize().width, 2))
        -- local moveDown = cc.MoveTo:create(0.5, cc.p(inView:getContentSize().width, -2))
        local moveUp = cc.MoveBy:create(0.5, cc.p(0, 3))
        local moveDown = cc.MoveBy:create(0.5, cc.p(0, -3))
        local seq = cc.Sequence:create(moveUp,moveDown)
        local repeateMove = cc.RepeatForever:create(seq)
        arrowUp:runAction(repeateMove)
    end
end


function IconUtils:setTeamRuneLevelVisible(inView, inVisible)
    if inView == nil then
        return
    end
    -- local tempTable = inView.userData
    -- for i= 1 , 4 do
        local iconGem = inView:getChildByFullName("levelLab")
        if iconGem ~= nil then 
            iconGem:setVisible(inVisible)
        end
    -- end
end

function IconUtils:setTeamRuneStageVisible(inView, inVisible)
    if inView == nil then
        return
    end
    local tempTable = inView.userData
    -- for i= 1 , 4 do
        local iconGem = inView:getChildByFullName("stageLabBg")
        if iconGem ~= nil then 
            iconGem:setVisible(inVisible)
        end
    -- end
end
    

--[[
--! @function createTeamSkillIconById
--! @desc 创建怪兽icon
--! @param inTable table 相关控制
           teamSkill table 数据
           level int 等级
           eventStyle int 事件类型 
                    0:无事件响应,
                    1:长按显示信息,
                    2:点击显示弹出框信息,
                    3:回调点击事件
           clickCallback 点击毁掉事件

--! @return bgNode node 
--]] 
function IconUtils:createTeamSkillIconById(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(116, 116)

    local icon = ccuiImageView:create()

    -- icon:setAnchorPoint(0.5, 0.5)
    icon:setName("icon")
    icon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    icon:ignoreContentAdaptWithSize(false)
    bgNode:addChild(icon)
       

    local boxIcon = ccuiImageView:create()

    -- boxIcon:setAnchorPoint(0.5, 0.5)
    boxIcon:setName("boxIcon")
    boxIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    boxIcon:ignoreContentAdaptWithSize(false)
    bgNode:addChild(boxIcon,8)

    local levelLab = ccLabel:createWithTTF("111", UIUtils.ttfName, 24)
    -- levelLab:setPosition(12,17)
    levelLab:setPosition(18, 13)
    levelLab:setAnchorPoint(0, 0)
    bgNode:addChild(levelLab,3)
    levelLab:enableOutline(ccc4b(60,30,10,255), 2)
    levelLab:setName("levelLab")
    levelLab:setColor(ccc3b(255,255,255))

    IconUtils:updateTeamSkillIconByView(bgNode, inTable)
    return bgNode
end

--[[
--! @function updateTeamSkillIconByView
--! @desc 更新怪兽icon
--! @param inTable table 相关控制
           teamSkill table 数据
           level int 等级
           iconFrame 用户自定义边框
           -- eventStyle int 事件类型 
           --           0:无事件响应,
           --           1:长按显示信息,
           --           2:点击显示弹出框信息,
           --           3:回调点击事件
           clickCallback 点击毁掉事件

--! @return bgNode node 
--]]
function IconUtils:updateTeamSkillIconByView(inView, inTable)
    if inTable == nil or 
        inTable.teamSkill == nil then
        return 
    end
    local icon = inView:getChildByFullName("icon")

    if icon == nil then 
        return
    end

    -- 处理觉醒数据
    local teamData = inTable.teamData 
    if not teamData then
        teamData = {}
    end
    local skillTab = teamData.skillTab
    if not skillTab then
        skillTab = TeamUtils:getTeamAwakingSkill(teamData)
    end
    local teamId = teamData.teamId
    local selectSkill = 0
    local systeam = tab:Team(teamId) or tab:Npc(teamId)
    if systeam then
        local _skill = systeam.skill
        local skillId = inTable.teamSkill.id 
        if _skill and table.nums(_skill) > 0 then

            -- modify by hxp : 觉醒技能的显示框匹配逻辑添加
            local talentTree = {}
            for i=1,4 do
                local d = systeam["talentTree"..i]
                local t = {}
                if d then
                    local baseSkill = _skill[d[1]][2]      -- 对应的基础技能
                    t[1] = d[2][2]                         -- 觉醒技能1
                    t[2] = d[3][2]                         -- 觉醒技能2
                    talentTree[baseSkill] = t
                else
                    talentTree["0"] = t
                end
               
            end
            for i=1,4 do
                local cfgSkillId = _skill[i][2]
                local talentSkill = talentTree[cfgSkillId]
                if cfgSkillId == skillId or (talentSkill and skillId == talentSkill[1]) or (talentSkill and skillId == talentSkill[2]) then
                    selectSkill = i
                    break
                end
            end

        end
    end
    local skillAwaking = skillTab[selectSkill] or {}
    local filename = IconUtils.iconPath .. (inTable.teamSkill.art or "notupian") .. ".jpg"
    local sfc = cc.SpriteFrameCache:getInstance()
    if not sfc:getSpriteFrameByName(filename) then
        filename = IconUtils.iconPath .. (inTable.teamSkill.art or "notupian") .. ".png"
    end
    icon:loadTexture(filename, 1)

    -- icon:loadTexture(IconUtils.iconPath .. inTable.teamSkill.art .. ".jpg")
    icon:setContentSize(80, 80)
    if inTable.isGray == true then
        icon:setSaturation(-100)
    else
        icon:setSaturation(0)
    end

    -- local icon1 = IconUtils:setRoundedCorners(icon, inTable.teamSkill.art)
    -- icon1:setName("icon")
    -- local sysItem = tab:Tool(inTable.itemId)
    -- 会增加类型判断获取不同底图
    -- inView:loadTexture(IconUtils:getItemIconById(inTable.itemId), 1)

    local levelLab = inView:getChildByFullName("levelLab")
    if levelLab then
        if inTable.levelLab == true and inTable.level and inTable.level > 0 then
            dump(inTable,"inTable=============")
            levelLab:setVisible(true)
            levelLab:setString(inTable.level)
        else
            levelLab:setVisible(false)
        end
    end

    local boxIcon = inView:getChildByFullName("boxIcon")
    if boxIcon ~= nil then 
        local frame = "globalImageUI7_iquality0.png"
        if skillAwaking[2] == 1 then
            frame = "globalImageUI_teamawakeskill1.png"
        elseif skillAwaking[2] == 2 then
            frame = "globalImageUI_teamawakeskill2.png"
        end
        boxIcon:loadTexture(frame, 1)
        boxIcon:setContentSize(96, 96)
    end
    if inTable.noBox then
        boxIcon:setVisible(false)
    else
        boxIcon:setVisible(true)
    end
    if inTable.isGray == true then
        boxIcon:setSaturation(-100)
    else
        boxIcon:setSaturation(0)
    end

    -- local iconColor = inView:getChildByFullName("iconColor")
    -- iconColor:setScaleAnim(true)
    icon:setScaleAnim(true)
    boxIcon:setScaleAnim(true)
    -- 部分地方只为展示icon 无任何事件
    if inTable.eventStyle == nil then inTable.eventStyle = 1 end
    if inTable.eventStyle ~= nil
        and inTable.eventStyle ~= 0 then

        icon:setTouchEnabled(true)
        local showView = nil
        local viewMgr = ViewManager:getInstance()
        local notScroll = true
        local downX, downY
        registerTouchEvent(boxIcon, function (_, x, y)
            if inTable.eventStyle == 1 then
                downX = x
                downY = y
                -- boxIcon:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function( )
                    if inTable.level <= 1 then
                        inTable.level = 1
                    end
                    -- viewMgr:showHintView("global.GlobalTipView",{tipType = 4, node = boxIcon, id = inTable.teamSkill.id,teamData = inTable.teamData,level = inTable.level,center = true})
                -- end)))
                -- down
                showView = 1
                -- 展示view
            end
            -- [[因为相应缩放事件需要锚点为0.5,0.5 inview本身是0,0 为了不去修改游戏内大量代码，
            --   将事件相应的缩放动画 直接应用于子节点。
            --   父节点其他动画效果与缩放action也可以隔离 stopallaction
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                -- ButtonBeginAnim(iconColor)
                ButtonBeginAnim(icon)
                ButtonBeginAnim(boxIcon)
            end
        end, function(_, x, y)
            if inTable.eventStyle == 1 then
                if downX and downY then
                    if math.abs(downX - x) > 5 or math.abs(downY - y) > 5 then
                        notScroll = false
                    end
                end
            end
        end, 
        function ()

            if inTable.eventStyle == 1 then
                -- boxIcon:stopAllActions()
                -- viewMgr:closeHintView()
                if notScroll then
                    viewMgr:showHintView("global.GlobalTipView",{tipType = 4, node = boxIcon,iconFrame = inTable.iconFrame, id = inTable.teamSkill.id,teamData = inTable.teamData,level = inTable.level,addLevel = inTable.addLevel,center = true,teamSkillS = inTable.teamSkillS})
                end
                notScroll = true
            elseif inTable.eventStyle == 2 then 
                -- 展示需要点击view 
            end
            -- 回调
            if inTable.eventStyle == 3 and
            inTable.clickCallback ~= nil then 
                inTable.clickCallback(inTable.itemId, inTable.num)
            end
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                -- ButtonEndAnim(iconColor)
                ButtonEndAnim(icon)
                ButtonEndAnim(boxIcon)
            end
        end,
        function ()
            if inTable.eventStyle == 1 then
                -- boxIcon:stopAllActions()
                -- viewMgr:closeHintView()
            end
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                -- ButtonEndAnim(iconColor)
                ButtonEndAnim(icon)
                ButtonEndAnim(boxIcon)
            end
        end)
    end
end

--[[
--! @function createPveBossSkillIconById
--! @desc 创建PVE的BOSS技能icon
--! @param inTable table 相关控制
           bossSkill table 数据
           eventStyle int 事件类型 
                    0:无事件响应,
                    1:长按显示信息,
                    2:点击显示弹出框信息,
                    3:回调点击事件
           clickCallback 点击回调事件

--! @return bgNode node 
--]] 
function IconUtils:createPveBossSkillIconById(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(107, 107)

    local icon = ccuiImageView:create()
    -- icon:setAnchorPoint(0.5, 0.5)
    icon:setName("icon")
    icon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    icon:ignoreContentAdaptWithSize(false)
    bgNode:addChild(icon)
       

    local boxIcon = ccuiImageView:create()
    -- boxIcon:setAnchorPoint(0.5, 0.5)
    boxIcon:setName("boxIcon")
    boxIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    boxIcon:ignoreContentAdaptWithSize(false)
    bgNode:addChild(boxIcon,8)

    IconUtils:updatePveBossSkillIconByView(bgNode, inTable)
    return bgNode
end

--[[
--! @function updatePveBossSkillIconByView
--! @desc 更新PVE的BOSS技能icon
--! @param inTable table 相关控制
           bossSkill table 数据
           -- eventStyle int 事件类型 
           --           0:无事件响应,
           --           1:长按显示信息,
           --           2:点击显示弹出框信息,
           --           3:回调点击事件
           clickCallback 点击毁掉事件

--! @return bgNode node 
--]]
function IconUtils:updatePveBossSkillIconByView(inView, inTable)
    if inTable == nil or 
        inTable.bossSkill == nil then
        return 
    end
    local icon = inView:getChildByFullName("icon")

    if icon == nil then 
        return
    end

    local filename = IconUtils.iconPath .. (inTable.bossSkill.art or "notupian") .. ".jpg"
    local sfc = cc.SpriteFrameCache:getInstance()
    if not sfc:getSpriteFrameByName(filename) then
        filename = IconUtils.iconPath .. (inTable.bossSkill.art or "notupian") .. ".png"
    end
    icon:loadTexture(filename, 1)

    icon:setContentSize(90, 90)
    if inTable.isGray == true then
        icon:setSaturation(-100)
    else
        icon:setSaturation(0)
    end

    local boxIcon = inView:getChildByFullName("boxIcon")
    if boxIcon ~= nil then 
        boxIcon:loadTexture("globalImageUI4_iquality0.png", 1)
        boxIcon:setContentSize(100, 100)
    end
    if inTable.noBox then
        boxIcon:setVisible(false)
    else
        boxIcon:setVisible(true)
    end
    if inTable.isGray == true then
        boxIcon:setSaturation(-100)
    else
        boxIcon:setSaturation(0)
    end

    if inTable.eventStyle == 1 or inTable.eventStyle == 3 then
        inView:setScaleAnim(true)
        icon:setScaleAnim(true)
        boxIcon:setScaleAnim(true)
    end
    local downX, downY
    registerTouchEvent(icon, function (_, x, y)
        if inTable.eventStyle == 1 then
            downX = x
            downY = y
            inView:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function( )
                viewMgr:showHintView("global.GlobalTipView",
                    {tipType = 12, 
                     node = inView, 
                     id = inTable.bossSkill.id, 
                     name = inTable.bossSkill.name, 
                     desStr = inTable.bossSkill.des,
                     art = inTable.bossSkill.art
                    })
            end)))

            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonBeginAnim(icon)
                ButtonBeginAnim(boxIcon)
            end
        end
    end, nil, 
    function (_, x, y)
        if inTable.eventStyle == 1 then 
            -- 展示需要点击view 
            if math.abs(downX - x) > 5 or math.abs(downY - y) > 5 then
                inView:stopAllActions()
            end
            -- viewMgr:closeHintView()
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonEndAnim(icon)
                ButtonEndAnim(boxIcon)
            end
        end
    end,
    function ()
        if inTable.eventStyle == 1 then 
            -- 展示需要点击view 
            inView:stopAllActions()
            -- viewMgr:closeHintView()
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonEndAnim(icon)
                ButtonEndAnim(boxIcon)
            end
        end
    end) 
end

function IconUtils:createArrowBoxRewadById(inTable)
    if inTable == nil then
        inTable = {}
    end
    
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(80, 61)

    local icon = ccuiImageView:create()
    icon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    icon:ignoreContentAdaptWithSize(false)
    bgNode._icon = icon
    bgNode:addChild(icon)

    local numLab =  ccuiText:create()
    numLab:setString("")
    numLab:setFontSize(22)
    numLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
    numLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    numLab:setAnchorPoint(1, 0.5)
    numLab:setFontName(UIUtils.ttfName)
    bgNode._numLab = numLab
    bgNode:addChild(numLab)

    local nameLab =  ccuiText:create()
    nameLab:setString("")
    nameLab:setFontSize(22)
    nameLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
    nameLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    nameLab:setFontName(UIUtils.ttfName)
    bgNode._nameLab = nameLab
    bgNode:addChild(nameLab)
       
    IconUtils:updateArrowBoxRewadById(bgNode, inTable)
    return bgNode
end

--[[
--! @function updateArrowBoxRewadById
--! @desc 更新射箭宝箱奖励icon
--! @param inTable table 相关控制
--! @return bgNode node 
--]]
function IconUtils:updateArrowBoxRewadById(inView, inTable)
    if inTable == nil or not inView._icon or not inView._numLab then
        return 
    end

    local icon = inView._icon 
    local imgId = inTable.typeId or 3
    icon:loadTexture("global_arrow_box" .. imgId .. ".png", 1)
    icon:setContentSize(cc.size(80, 61))

    local numLab = inView._numLab
    numLab:setString(inTable.num or 0)
    numLab:setPosition(inView:getContentSize().width - 3, 3)

    local nameLab = inView._nameLab
    nameLab:setString("射箭金宝箱")
    nameLab:setPosition(inView:getContentSize().width * 0.5, -30)
end

--[[
--! @function createCrusadeHeroIconById
--! @desc 创建英雄系统icon
--! @param inTable table 相关控制
           sysHeroData table 数据
--! @return bgNode node 
--]]
function IconUtils:createCrusadeHeroIconById(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(100, 100)


    local heroIcon = ccSprite:create()
    -- heroIcon:setAnchorPoint(0.5, 0.5)
    heroIcon:setName("heroIcon")
    heroIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    bgNode:addChild(heroIcon)


    local boxIcon = ccSprite:create()
    -- boxIcon:setAnchorPoint(0.5, 0.5)
    boxIcon:setName("boxIcon")
    boxIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    bgNode:addChild(boxIcon)

    IconUtils:updateCrusadeHeroIconByView(bgNode, inTable)
    return bgNode
end

--[[
--! @function updateItemIconByView
--! @desc 更新怪兽系统icon
--! @param inTable table 相关控制
           sysHeroData table 数据
--! @return bgNode node 
--]]
function IconUtils:updateCrusadeHeroIconByView(inView, inTable)
    if inTable == nil then
        return 
    end
    local heroIcon = inView:getChildByName("heroIcon")

    if heroIcon == nil then 
        return
    end
    -- heroIcon:setTexture(IconUtils.iconPath .. inTable.sysHeroData.herohead .. ".png")
    local herohead
    if inTable.skin then
        local heroSkinD = tab.heroSkin[tonumber(inTable.skin)]
        if heroSkinD and heroSkinD["herohead"] then
            herohead = heroSkinD["herohead"]
        else
            herohead = inTable.sysHeroData.herohead
        end
        
    else
        herohead = inTable.sysHeroData.herohead
    end
    heroIcon:setSpriteFrame(IconUtils.iconPath .. herohead .. ".jpg")
    if inTable.isGray == true then
        heroIcon:setSaturation(-100)
    end

    -- 通用特效 guojun_
    if inView.effect then
        local mc = mcMgr:createViewMC("diguang_itemeffectcollection", true, false, nil, RGBA8888)
        if mc then
            mc:setPosition(iconColor:getContentSize().width/2,iconColor:getContentSize().height/2)
            -- mc:setScale(1.1)
            mc:setName("bgMc")
            inView:addChild(mc,-1)
        end
        local mc = IconUtils:addEffectByName({"tongyongdibansaoguang_itemeffectcollection","wupinkuangxingxing_itemeffectcollection"}) 
        if mc then
            -- mc:setPosition(cc.p(iconColor:getContentSize().width/2- 15,iconColor:getContentSize().height/2- 15))
            iconColor:addChild(mc,10)
        end
    end
    
    local boxIcon = inView:getChildByName("boxIcon")
    if boxIcon ~= nil then
        boxIcon:setSpriteFrame("globalImageUI4_heroBg1.png")
        if inTable.isGray == true then
            boxIcon:setSaturation(-100)
        end     
    end

end



-- 圆角遮罩80*80
-- 尺寸
IconUtils.iconCache = {}
function IconUtils:clearCache()
    for k, v in pairs(IconUtils.iconCache) do
        v:release()
    end
    IconUtils.iconCache = nil
    IconUtils.iconCache = {}
end

--[[
--! @function createTeamPlayIconById
--! @desc 创建推荐玩法icon
--! @param inTable table 相关控制
           playWay 对应玩法 
--! @return bgNode node 
--]]
function IconUtils:createTeamPlayIconById(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(100, 100)


    -- local teamIcon = ccSprite:create()
    local teamIcon = ccuiImageView:create()
    -- teamIcon:setAnchorPoint(0.5, 0.5)
    teamIcon:setName("teamIcon")
    teamIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    -- teamIcon:setScale(1.2)
    bgNode:addChild(teamIcon)

    -- local boxIcon = ccSprite:create()
    local boxIcon = ccuiImageView:create()
    -- boxIcon:setAnchorPoint(0.5, 0.5)
    boxIcon:setName("boxIcon")
    boxIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    boxIcon:setScale(0.8)
    bgNode:addChild(boxIcon, -1)


    -- local iconColor = ccSprite:create()
    local iconColor = ccuiImageView:create()
    -- iconColor:setAnchorPoint(0.5, 0.5)
    iconColor:setName("iconColor")
    iconColor:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    iconColor:setContentSize(94,94)
    iconColor:ignoreContentAdaptWithSize(false)
    bgNode:addChild(iconColor,1)


    local iconLock = ccuiImageView:create()
    -- iconLock:setAnchorPoint(0.5, 0.5)
    iconLock:setName("iconLock")
    iconLock:loadTexture("globalPanelUI7_zhezhao.png",1) 
    iconLock:setContentSize(94,94)
    iconLock:ignoreContentAdaptWithSize(false)

    local suo = ccuiImageView:create()
    -- suo:setAnchorPoint(0.5, 0.5)
    suo:setName("suo")
    suo:setScale(1.2)
    suo:loadTexture("globalImageUI5_treasureLock.png",1) 
    suo:setPosition(iconLock:getContentSize().width*0.5,iconLock:getContentSize().height*0.5)
    iconLock:addChild(suo,1)

    iconLock:setPosition(iconColor:getContentSize().width*0.5,iconColor:getContentSize().height*0.5)    
    iconColor:addChild(iconLock,10)
       
    IconUtils:updateTeamPlayIconByView(bgNode, inTable)
    return bgNode
end


--[[
--! @function updateTeamPlayIconByView
--! @desc 更新推荐玩法icon
--! @param inTable table 相关控制
           playWay 对应玩法 
--! @return bgNode node 
--]]
function IconUtils:updateTeamPlayIconByView(inView, inTable)
    if inTable == nil then
        return 
    end

    local teamIcon = inView:getChildByName("teamIcon")

    if teamIcon == nil then 
        return
    end
    
    local filename
    if inTable.playWay then -- 玩法创建
        filename = IconUtils.iconPath .. IconUtils.playWay[inTable.playWay]
    elseif inTable.image then -- 英雄专长创建
        filename = IconUtils.iconPath .. inTable.image
    end
    teamIcon:loadTexture(filename,1)

    -- teamIcon:setTexture(IconUtils.iconPath .. IconUtils.playWay[inTable.playWay])

    local boxIcon = inView:getChildByName("boxIcon")
    if boxIcon ~= nil then 
        local qulityName = ""
        if inTable.quality then
            -- boxIcon:setSpriteFrame("globalImageUI_quality" .. inTable.quality .. ".png")
            qulityName = "globalImageUI_quality" .. inTable.quality .. ".png"
        elseif inTable.qualityImage then
            -- boxIcon:setSpriteFrame(inTable.qualityImage)
            qulityName = inTable.qualityImage
        else
            -- boxIcon:setSpriteFrame("globalImageUI_quality0.png")
            qulityName = "globalImageUI_quality0.png"
        end
        boxIcon:loadTexture(qulityName,1)
    end

    local iconColor = inView:getChildByName("iconColor")
    -- iconColor:setSpriteFrame("globalImageUI4_iquality0.png")
    iconColor:loadTexture("globalImageUI4_iquality0.png",1)
    -- 英雄专长边框用
    if inTable.heroFrame then -- 专长品阶
        -- iconColor:setScale(1.2)
        if inTable.globalHeroFrame == true then -- 是否全局
            -- iconColor:setSpriteFrame("globalImageUI7_ghsquality" .. inTable.heroFrame .. ".png")
            iconColor:loadTexture("globalImageUI7_ghsquality" .. inTable.heroFrame .. ".png",1)
        else
            -- iconColor:setSpriteFrame("globalImageUI7_hsquality" .. inTable.heroFrame .. ".png")
            iconColor:loadTexture("globalImageUI7_hsquality" .. inTable.heroFrame .. ".png",1)
        end
    end

    -- 英雄星级显示
    if inTable.star then
        local starIcon = iconColor:getChildByName("starIcon")
        -- starIcon:setScale(0.9)
        local colorPng = "globalImageUI_heroStar" .. inTable.star .. ".png"
        if not starIcon then
            starIcon = ccSprite:create()
            -- starIcon:setAnchorPoint(0.5, 0.5)
            starIcon:setName("starIcon")
            starIcon:setPosition(iconColor:getContentSize().width/2, 20)
            iconColor:addChild(starIcon, 2)
            starIcon:setSpriteFrame(colorPng)
        else
            starIcon:setSpriteFrame(colorPng)
        end
    end

-- {tipType = 2, node = node, id = heroData.special,heroData = clone(heroData), 
-- des = BattleUtils.getDescription(BattleUtils.kIconTypeHeroSpecialty, 
-- heroData.special, self._attributeValues)})

    -- 部分地方只为展示icon 无任何事件
    if inTable.eventStyle ~= nil
        and inTable.eventStyle ~= 0 then
        inView:setTouchEnabled(true)
        local showView = nil
        local viewMgr = ViewManager:getInstance()
        local function endTouchEvent(inTempView)
            --print("endTouchEvent=======")
            -- inTempView:setScale(inTempView:getScale() + 0.05)
            if inTable.eventStyle == 1 and 
                showView ~= nil then
                --viewMgr:closeDialog(showView)
            end
        end

        if inTable.eventStyle == 1 or inTable.eventStyle == 3 then
            -- print("icon .... setScaleAnim true")
            inView:setScaleAnim(true)
            teamIcon:setScaleAnim(true)
            boxIcon:setScaleAnim(true)
            iconColor:setScaleAnim(true)
        end

        registerTouchEvent(inView, function ()
                local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
                if ax ~= 0.5 or ay ~= 0.5 then
                    ButtonBeginAnim(teamIcon)
                    ButtonBeginAnim(boxIcon)
                    ButtonBeginAnim(iconColor)
                end
            end, nil, 
            function ()
                endTouchEvent(inView)
                if inTable.eventStyle == 1 then
                    -- down
                    showView = 1
                    viewMgr:showHintView("global.GlobalTipView",{tipType = 2, node = inView, id = inTable.heroData.special, heroData = inTable.heroData, star = inTable.maxStar or inTable.star,showCurStarOnly = inTable.showCurStarOnly})
                    -- 展示view
                end

                if inTable.eventStyle == 2 then 
                    -- 展示需要点击view 
                end
                -- 回调
                if inTable.eventStyle == 3 and
                inTable.clickCallback ~= nil then 
                    inTable.clickCallback(inTable.sysTeamData.teamId)
                end
                local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
                if ax ~= 0.5 or ay ~= 0.5 then
                    ButtonEndAnim(teamIcon)
                    ButtonEndAnim(boxIcon)
                    ButtonEndAnim(iconColor)
                end
            end,
            function ()
                endTouchEvent(inView)
                local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
                if ax ~= 0.5 or ay ~= 0.5 then
                    ButtonEndAnim(teamIcon)
                    ButtonEndAnim(boxIcon)
                    ButtonEndAnim(iconColor)
                end
            end)
    end
end




--[[
--! @function createTExpIconById
--! @desc 创建怪兽经验图标
--! @param inTable table 相关控制
--! @return bgNode node 
--]]
function IconUtils:createTExpIconById(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(98, 98)

    local texpIcon = ccSprite:create(IconUtils.resImgMap.texp)
    -- texpIcon:setAnchorPoint(0.5, 0.5)
    texpIcon:setName("texpIcon")
    texpIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    bgNode:addChild(texpIcon)

    if inTable.num ~= nil and  inTable.num > 0  then 
        local numLab = ccLabel:createWithTTF(inTable.num, UIUtils.ttfName, 20)
        numLab:setColor(UIUtils.colorTable.ccColor1)
        numLab:enableOutline(ccc4b(0, 0, 0, 255),2)
        numLab:setAnchorPoint(1, 0)
        numLab:setPosition(bgNode:getContentSize().width - 11, 11)
        bgNode:addChild(numLab)
    end

    local boxIcon = ccSprite:createWithSpriteFrameName("globalImageUI4_iquality0.png")
    -- boxIcon:setAnchorPoint(0.5, 0.5)
    boxIcon:setName("boxIcon")
    boxIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    bgNode:addChild(boxIcon)

    return bgNode
end

--[[
--! @function createPeerageIconById
--! @desc 创建特权icon
--! @param inTable table 相关控制
           playWay 对应玩法 
--! @return bgNode node 
--]]
function IconUtils:createPeerageIconById(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(100, 100)


    local teamIcon = ccSprite:create()
    -- teamIcon:setAnchorPoint(0.5, 0.5)
    teamIcon:setName("teamIcon")
    teamIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    -- teamIcon:setScale(1.2)
    bgNode:addChild(teamIcon)

    local boxIcon = ccSprite:create()

    -- boxIcon:setAnchorPoint(0.5, 0.5)
    boxIcon:setName("boxIcon")
    boxIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    -- boxIcon:setScale(0.8)
    bgNode:addChild(boxIcon, -1)


    local iconColor = ccSprite:create()

    -- iconColor:setAnchorPoint(0.5, 0.5)
    iconColor:setName("iconColor")
    iconColor:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    bgNode:addChild(iconColor,1)
       
    IconUtils:updatePeerageIconByView(bgNode, inTable)
    return bgNode
end


--[[
--! @function updatePeerageIconByView
--! @desc 更新特权icon
--! @param inTable table 相关控制
           playWay 对应玩法 
--! @return bgNode node 
--]]
function IconUtils:updatePeerageIconByView(inView, inTable)
    if inTable == nil then
        return 
    end
    local teamIcon = inView:getChildByName("teamIcon")

    if teamIcon == nil then 
        return
    end

    local filename
    if inTable.playWay then
        filename = IconUtils.iconPath .. IconUtils.playWay[inTable.playWay]
    elseif inTable.image then
        filename = IconUtils.iconPath .. inTable.image
    end
    teamIcon:setSpriteFrame(filename)
    if inTable.scale then
        teamIcon:setScale(inTable.scale)
    end

    -- teamIcon:setTexture(IconUtils.iconPath .. IconUtils.playWay[inTable.playWay])

    local boxIcon = inView:getChildByName("boxIcon")
    if boxIcon ~= nil then 
        if inTable.quality then
            boxIcon:setSpriteFrame("globalImageUI6_itembg_" .. inTable.quality .. ".png")
        else
            boxIcon:setSpriteFrame("globalImageUI6_itembg_1.png")
        end
    end

    local iconColor = inView:getChildByName("iconColor")
    if iconColor ~= nil then 
        if inTable.bigpeer then
            iconColor:setSpriteFrame("globalImageUI4_squality5.png")
        else
            iconColor:setSpriteFrame("globalImageUI4_squality1.png")
        end
    end
end

----------------------------------------------------------------------------------------

--[[
--! @function createHeroIconById
--! @desc 创建英雄系统icon
--! @param inTable table 相关控制
           sysHeroData table 数据
           skin 皮肤
--! @return bgNode node 
--]]

function IconUtils:createHeroIconById(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    -- bgNode:setAnchorPoint(0.5, 0.5)
    bgNode:setContentSize(107, 107)
    -- bgNode:
    bgNode:setScaleAnim(true)

    local heroIcon = ccui.ImageView:create()
    -- heroIcon:setAnchorPoint(0.5, 0.5)
    heroIcon:setName("heroIcon")
    heroIcon:ignoreContentAdaptWithSize(false)
    heroIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    bgNode:addChild(heroIcon)


    local boxIcon = ccui.ImageView:create()
    -- boxIcon:setAnchorPoint(0.5, 0.5)
    boxIcon:setName("boxIcon")
    boxIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    boxIcon:ignoreContentAdaptWithSize(false)
    bgNode:addChild(boxIcon, 2)

    local starBg = ccSprite:create()
    -- starBg:setAnchorPoint(0.5, 0.5)
    starBg:setName("starBg")
    starBg:setPosition(bgNode:getContentSize().width/2, 10)
    starBg:setScale(1.2)
    bgNode:addChild(starBg,4)

    local iconStar = ccuiImageView:create()
    iconStar:setName("iconStar")
    iconStar:loadTexture("globalImageUI_heroStar1.png", 1)
    iconStar:setPosition(bgNode:getContentSize().width/2,iconStar:getContentSize().height/5 + 5)
    iconStar:ignoreContentAdaptWithSize(true)
    bgNode:addChild(iconStar,4)

    IconUtils:updateHeroIconByView(bgNode, inTable)
    return bgNode
end

--[[
--! @function updateHeroIconByView
--! @desc 更新怪兽系统icon
--! @param inTable table 相关控制
           sysHeroData table 数据
           skin 皮肤
--! @return bgNode node 
--]]
function IconUtils:updateHeroIconByView(inView, inTable)
    if inTable == nil then
        return 
    end
    local heroIcon = inView:getChildByName("heroIcon")

    if heroIcon == nil then 
        return
    end
    -- heroIcon:setTexture(IconUtils.iconPath .. inTable.sysHeroData.herohead .. ".png")
    local herohead
    if inTable.sysHeroData.skin then
        local heroSkinD = tab.heroSkin[inTable.sysHeroData.skin]
        herohead = heroSkinD["herohead"] or inTable.sysHeroData.herohead
    else
        herohead = inTable.sysHeroData.herohead
    end
    heroIcon:setContentSize(100,100)
    heroIcon:loadTexture(IconUtils.iconPath .. herohead .. ".jpg",1)
    if inTable.isGray == true then
        heroIcon:setSaturation(-100)
    end
    
    local boxIcon = inView:getChildByName("boxIcon")
    if boxIcon ~= nil then
        boxIcon:loadTexture("globalImageUI4_heroBg1.png",1)
        boxIcon:setContentSize(105,105)
        if inTable.isGray == true then
            boxIcon:setSaturation(-100)
        end
    end

    local starBg = inView:getChildByName("starBg")
    if starBg ~= nil then
        starBg:setSpriteFrame("globalImageUI6_heroStarBg.png")
        if inTable.isGray == true then
            starBg:setSaturation(-100)
        end
        starBg:setVisible(not (inTable.sysHeroData.hideFlag or inTable.sysHeroData.star == 0))
    end

    -- 通用特效 guojun_
    if inTable.effect then
        local mc = inView:getChildByName("bgMc")
        if not mc then
            mc = mcMgr:createViewMC("huodewupindiguang_itemeffectcollection", true, false, nil, RGBA8888)
            mc:setPosition(cc.p(boxIcon:getContentSize().width/2-5,boxIcon:getContentSize().height/2+3))
            mc:setScale(1.2)
            mc:setName("bgMc")
            inView:addChild(mc,-1)
        else
            mc:setVisible(true)
        end
        local mc1 = boxIcon:getChildByName("bgMc1")

        if not mc1 then
            mc1 = IconUtils:addEffectByName({"tongyongdibansaoguang_itemeffectcollection"}) 
            -- mc1 = IconUtils:addEffectByName({"tongyongdibansaoguang_itemeffectcollection","wupinkuangxingxing_itemeffectcollection"}) 
            -- mc:setPosition(cc.p(boxIcon:getContentSize().width/2- 15,boxIcon:getContentSize().height/2- 15))
            mc1:setName("bgMc1")
            boxIcon:addChild(mc1,10)
        else
            mc1:setVisible(true)
        end
    else
        local mc = inView:getChildByName("bgMc")
        if mc then
            mc:setVisible(false)
        end

        local mc1 = boxIcon:getChildByName("bgMc1")
        if mc1 then
            mc1:setVisible(false)
        end
    end

    local star = inTable.sysHeroData.star or inTable.sysHeroData.herostar
    if star == nil then
        star = 0
    end
    local iconStar = inView:getChildByFullName("iconStar")
    iconStar:setVisible(not (inTable.sysHeroData.hideFlag or inTable.sysHeroData.star == 0))
    local filename = "globalImageUI_heroStar".. star ..".png"
    local sfc = cc.SpriteFrameCache:getInstance()
    if not sfc:getSpriteFrameByName(filename) then
        filename ="globalImageUI6_iconStar".. star ..".png"
    end
    if iconStar and star and star > 0 then
        iconStar:loadTexture(filename,1)
    end
    -- local starAllWidth = star * 15
    -- local beginX  = inView:getContentSize().width / 2 - starAllWidth / 2 - 3
    -- for i= 1 , 4 do
    --     local iconStar = inView:getChildByFullName("star" .. i)
    --     if i <= star then 
    --         if iconStar == nil then
    --             iconStar = ccuiImageView:create()
    --             iconStar:setAnchorPoint(cc.p(0, 0))
    --             iconStar:ignoreContentAdaptWithSize(true)
    --             iconStar:loadTexture("globalImageUI6_star1.png", 1)
    --             inView:addChild(iconStar,4) 
    --         end
    --         iconStar:setVisible(true)
    --         -- beginX + (i - 1) * starAllWidth
    --         iconStar:setPosition(beginX + (i - 1) * 15, 0)
    --         iconStar:setName("star" .. i)
    --     else
    --         if iconStar ~= nil then
    --             iconStar:setVisible(false)
    --         end
    --     end
    -- end

end

--[[
--! @function createTreasureIconById
--! @desc 创建宝物icon
--! @param inTable table 相关控制
           playWay 对应玩法 
--! @return bgNode node 
--]]
function IconUtils:createTreasureIconById(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(100, 100)


    local teamIcon = ccuiImageView:create()
    -- teamIcon:setAnchorPoint(0.5, 0.5)
    teamIcon:ignoreContentAdaptWithSize(false)
    teamIcon:setName("teamIcon")
    teamIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    bgNode:addChild(teamIcon)

    local boxIcon = ccuiImageView:create()
    boxIcon:ignoreContentAdaptWithSize(false)
    -- boxIcon:setAnchorPoint(0.5, 0.5)
    boxIcon:setName("boxIcon")
    boxIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    -- boxIcon:setScale(0.8)
    bgNode:addChild(boxIcon, -1)


    local iconColor = ccuiImageView:create()

    -- iconColor:setAnchorPoint(0.5, 0.5)
    iconColor:setName("iconColor")
    iconColor:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    bgNode:addChild(iconColor,1)
       

    IconUtils:updateTreasureIcon(bgNode, inTable)
    return bgNode
end


--[[
--! @function updateTreasureIcon
--! @desc 更新宝物icon
--! @param inTable table 相关控制
           playWay 对应玩法 
--! @return bgNode node 
--]]
function IconUtils:updateTreasureIcon(inView, inTable)
    if inTable == nil then
        return 
    end
    local teamIcon = inView:getChildByName("teamIcon")

    if teamIcon == nil then 
        return
    end

    local _x = inTable.x or 80
    local _y = inTable.y or 80

    local filename
    if inTable.image then
        teamIcon:setContentSize(_x, _y)
        filename = inTable.image
    end
    teamIcon:loadTexture(filename, 1)

    -- teamIcon:setTexture(IconUtils.iconPath .. IconUtils.playWay[inTable.playWay])

    local boxIcon = inView:getChildByName("boxIcon")
    if boxIcon ~= nil then 
        if inTable.frame then
            boxIcon:setContentSize(_x, _y)
            boxIcon:loadTexture(inTable.frame, 1)
        end
    end

    -- local iconColor = inView:getChildByName("iconColor")
    -- if iconColor ~= nil then
    --     if inTable.frame then
    --         iconColor:setContentSize(cc.size(100,100))
    --         iconColor:setSpriteFrame(inTable.frame)
    --     -- else
    --     --     iconColor:setSpriteFrame("globalImageUI4_iquality0.png")
    --     end
    -- end
    
end


-- function IconUtils:createBattleIcon()
--     local bgNode = ccuiWidget:create()
--     bgNode:setAnchorPoint(cc.p(0,0))
--     bgNode:setContentSize(cc.size(97, 97))

--  local button = ccui.Button:create("globalBtnUI5_battleNormal.png", "globalBtnUI5_battleDown.png.png", "globalBtnUI5_battleDown.png.png", 1)


--     button:setAnchorPoint(cc.p(0.5, 0.5))
--     button:setName("button")
--     button:setPosition(cc.p(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2))
--     button:ignoreContentAdaptWithSize(false)
--     bgNode:addChild(button)



--     local itemIcon = ccuiImageView:create("golbalIamgeUI5_battleTitle.png", 1)


--     itemIcon:setAnchorPoint(cc.p(0.5, 0.5))
--     itemIcon:setName("itemIcon")
--     itemIcon:setPosition(cc.p(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2))
--     itemIcon:ignoreContentAdaptWithSize(false)


--     bgNode:addChild(itemIcon,1)

--     return bgNode
-- end



-- 创建联盟旗帜
-- @param inTable table 相关控制
-- flags 旗面   logo 旗子 
function IconUtils:createGuildLogoIconById(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(110, 110)


    local flagsIcon = ccSprite:create()
    -- flagsIcon:setAnchorPoint(0.5, 0.5)
    flagsIcon:setName("flagsIcon")
    flagsIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    bgNode:addChild(flagsIcon)

    local logoIcon = ccSprite:create()
    -- logoIcon:setAnchorPoint(0.5, 0.5)
    logoIcon:setName("logoIcon")
    logoIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    bgNode:addChild(logoIcon)


    -- local iconColor = ccSprite:create()

    -- iconColor:setAnchorPoint(cc.p(0.5, 0.5))
    -- iconColor:setName("iconColor")
    -- iconColor:setPosition(cc.p(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2))
    -- bgNode:addChild(iconColor,1)
       
    IconUtils:updateGuildLogoIconByView(bgNode, inTable)
    return bgNode
end

-- 更新联盟旗帜
function IconUtils:updateGuildLogoIconByView(inView, inTable)
    if inTable == nil then
        return 
    end
    if not inTable.flags or not inTable.logo then
        return
    end
    if inTable.flags > 108 then
        inTable.flags = 101
    end
    -- print("===updateGuildLogoIconByView===========", inTable.flags, inTable.logo)
    -- print("tab:GuildFlag(inTable.flags).pic======", tab:GuildFlag(inTable.flags).pic,inTable.flags)
    local flags = tab:GuildFlag(inTable.flags).pic .. ".png"
    local logo = tab:GuildFlag(inTable.logo).pic .. ".png"

    local flagsIcon = inView:getChildByName("flagsIcon")
    if flagsIcon then
        flagsIcon:setSpriteFrame(flags)
    end
    local logoIcon = inView:getChildByName("logoIcon")
    if logoIcon then
        logoIcon:setSpriteFrame(logo)
    end
end

-- frameEffect  {name="qqhuiyuan_touxiangkuang",clipImg="avatarFrame_16_zhezhao.png"}, 
-- 添加头像框&头像特效
function IconUtils:addHeadFrameMc(mcParent,shineNum,shineEffect,scaleNum,isAvatar)
    local scale = scaleNum or 1
    local idx = shineNum
    local mcData 
    if not idx then  
        idx = 1 
    end
    if not isAvatar then        
        mcData = frameEffect[tonumber(idx)]
        if not mcData then
            mcData = frameEffect[1]
        end
    else
        if type(idx) == "string" then
            mcData = {}
            mcData.name = idx
        else
            mcData = headEffect[tonumber(idx)]
            if not mcData then
                mcData = headEffect[1]
            end
        end
    end
    local mc
    if mcData.clipImg then
        local clipNode = cc.ClippingNode:create()
        clipNode:setPosition(0,0)
        clipNode:setContentSize(mcParent:getContentSize().width, mcParent:getContentSize().height)
        local mask = cc.Sprite:createWithSpriteFrameName(mcData.clipImg)
        mask:setAnchorPoint(0,0)
        clipNode:setStencil(mask)
        clipNode:setAlphaThreshold(0.05)
        -- clipNode:setInverted(true)

        local mc1 = mcMgr:createViewMC(mcData.name, true,false)
        -- local mc1 = mcMgr:createViewMC("diguang_itemeffectcollection",true,false)
        mc1:setPosition(mcParent:getContentSize().width*0.5, mcParent:getContentSize().height*0.5)
        -- clipNode:setScale(0.5)
        clipNode:addChild(mc1)
        clipNode:setScale(scale)
        mcParent:addChild(clipNode,100)
        mc = clipNode
    else
        mc = mcMgr:createViewMC(mcData.name, true,false)   
        mc:setPosition(mcParent:getContentSize().width*0.5, mcParent:getContentSize().height*0.5)   
        mc:setScale(scale)  
        mcParent:addChild(mc,100)
    end
    if shineEffect then
        mc:setBrightness(shineEffect[1]or 0)
        mc:setContrast(shineEffect[2]or 0)
        mc:setHue(shineEffect[3]or 0)
        mc:setSaturation(shineEffect[4]or 0)
    end

    return mc

end

--[[
--! @function createHeadFrameIconById
--! @desc   创建头像框icon
--! @param inTable table 相关控制
            itemId int 物品id
            num int 数量
            itemData table 数据
            eventStyle int 事件类型  默认为1
                    0:无事件响应,
                    1:长按显示信息,
                    -- 2:点击显示弹出框信息,(无)
                    -- 3:回调点击事件(无)
            clickCallback 点击回调事件（3）
--! @return bgNode node 
--]]
function IconUtils:createHeadFrameIconById(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(107, 107)  

    local boxIcon = ccuiImageView:create()
    boxIcon:setName("boxIcon")
    -- boxIcon:setAnchorPoint(0.5,0.5)
    boxIcon:setPosition(bgNode:getContentSize().width*0.5, bgNode:getContentSize().height*0.5)
    -- boxIcon:ignoreContentAdaptWithSize(false)
    -- boxIcon:setContentSize(cc.size(107,107))
    bgNode:addChild(boxIcon)

    local iconColor = ccuiImageView:create()
    iconColor:setName("iconColor")
    iconColor:setPosition(bgNode:getContentSize().width*0.5,bgNode:getContentSize().height*0.5)
    -- iconColor:setAnchorPoint(0.5,0.5)
    -- iconColor:ignoreContentAdaptWithSize(false)
    -- iconColor:setContentSize(cc.size(107,107))
    bgNode:addChild(iconColor,5)

    IconUtils:updateHeadFrameIcon(bgNode, inTable)

    return bgNode
end

--[[
--! @function updateHeadFrameIcon
--! @desc   更新头像框icon
--! @param inTable table 相关控制
             
--! @return bgNode node 
--]]
-- 
function IconUtils:updateHeadFrameIcon(inView, inTable)
    if inTable == nil then
        return 
    end
    local boxIcon = inView:getChildByName("boxIcon")

    if boxIcon == nil then 
        return
    end
    -- dump(inTable,"intable==>",6)
    local itemData = inTable.itemData

    if not itemData then 
        itemData = {}
    end
    -- boxIcon:loadTexture("globalImageUI6_itembg_" .. (itemData.color or 1) .. ".png", 1)
    boxIcon:loadTexture("globalImageUI4_itemBg3.png", 1)
    local iconColor = inView:getChildByName("iconColor")
    if not iconColor then
        return
    end

    local frameImg = (itemData.art or itemData.icon or "globalImageUI4_itemBg3" )
    local filename = frameImg .. ".png"
    local sfc = cc.SpriteFrameCache:getInstance()
    if not sfc:getSpriteFrameByName(filename) then
        filename = frameImg .. ".jpg"
    end
    iconColor:loadTexture(filename, 1)  

    
    -- 添加特效
    local effect = inTable.effect    -- 默认添加特效
    local bgEffect = iconColor:getChildByName("bgMc")
    if bgEffect then
        bgEffect:removeFromParent()
    end
    if not effect then
        local shineData = inTable.itemData.shine 
        if shineData then
            local bgMc = IconUtils:addHeadFrameMc(iconColor,shineData[1],inTable.itemData.effect)
            bgMc:setName("bgMc")                       
        end     
    end

    -- 部分地方只为展示icon 无任何事件
    if not inTable.eventStyle then inTable.eventStyle = 1 end
    if inTable.eventStyle ~= 0 and inTable.eventStyle <= 3 then
        inView:setTouchEnabled(true)
        inView:setSwallowTouches(true)
        local showView = nil
        local viewMgr = ViewManager:getInstance()
        local function endTouchEvent(inTempView)
            --print("endTouchEvent=======")
            -- inTempView:setScale(inTempView:getScale() + 0.05)
            if inTable.eventStyle == 1 and 
                showView ~= nil then
                --viewMgr:closeDialog(showView)
            end
        end
        if inTable.eventStyle == 1 or inTable.eventStyle == 3 then
            inView:setScaleAnim(true)
            iconColor:setScaleAnim(true)
            boxIcon:setScaleAnim(true)
        end

        local downX, downY
        
        registerTouchEvent(inView, function (_, x, y)
            -- downCallback
            if inTable.eventStyle == 1 then
                downX = x
                downY = y
              
                showView = 1
                -- 展示view
            end
            -- 因为相应缩放事件需要锚点为0.5,0.5 inview本身是0,0 为了不去修改游戏内大量代码，
            --   将事件相应的缩放动画 直接应用于子节点。
            --   父节点其他动画效果与缩放action也可以隔离 stopallaction
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonBeginAnim(iconColor)              
                ButtonBeginAnim(boxIcon)
            end

            if inTable.itemData and inTable.itemData.newTips then
                viewMgr:showTip(lang(inTable.itemData.newTips))
            end
            --
        end, function(_, x, y)
            -- moveCallback            
            if inTable.eventStyle == 1 then
                
            end
        end, 
        function ()
            -- upCallback
            endTouchEvent(inView)

            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonEndAnim(iconColor)
                ButtonEndAnim(boxIcon)
            end
        end,
        function ()       
            --outCallback
            endTouchEvent(inView)
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonEndAnim(iconColor)
                ButtonEndAnim(boxIcon)
            end
        end
        ,
        function( )
            -- longCallback
        end)
    end
end

--[[
--! @function createAvatarIconById
--! @desc   创建头像icon
--! @param inTable table 相关控制
             
--! @return bgNode node 
--]]
function IconUtils:createAvatarIconById(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(107, 107)     

    local boxIcon = ccuiImageView:create()
    boxIcon:setName("boxIcon")
    -- boxIcon:setAnchorPoint(0.5,0.5)
    boxIcon:setPosition(bgNode:getContentSize().width*0.5, bgNode:getContentSize().height*0.5)
    -- boxIcon:ignoreContentAdaptWithSize(false)
    -- boxIcon:setContentSize(cc.size(107,107))
    bgNode:addChild(boxIcon)

    local iconColor = ccuiImageView:create()
    iconColor:setName("iconColor")
    iconColor:setPosition(bgNode:getContentSize().width*0.5,bgNode:getContentSize().height*0.5)
    -- iconColor:setAnchorPoint(0.5,0.5)
    -- iconColor:ignoreContentAdaptWithSize(false)
    -- iconColor:setContentSize(cc.size(107,107))
    bgNode:addChild(iconColor,5)

    IconUtils:updateAvatarIcon(bgNode, inTable)

    return bgNode
end

--[[
--! @function updateAvatarIcon
--! @desc   更新头像框icon
--! @param inTable table 相关控制
             
--! @return bgNode node 
--]]
-- 
function IconUtils:updateAvatarIcon(inView, inTable)
    if inTable == nil then
        return 
    end

    local boxIcon = inView:getChildByName("boxIcon")

    if boxIcon == nil then 
        return
    end
    -- dump(inTable,"intable==>",6)
    local itemData = inTable.itemData

    if not itemData then 
        itemData = {}
    end
    local frameImg = (itemData.art or itemData.icon or "globalImageUI6_itembg_" .. (itemData.color or 1) )
    local filename = frameImg .. ".png"
    local sfc = cc.SpriteFrameCache:getInstance()
    if not sfc:getSpriteFrameByName(filename) then
        filename = frameImg .. ".jpg"
    end
    boxIcon:loadTexture(filename, 1)  

    local iconColor = inView:getChildByName("iconColor")
    if not iconColor then
        return
    end

    iconColor:loadTexture("bg_head_mainView.png", 1)  

    -- 部分地方只为展示icon 无任何事件
    if not inTable.eventStyle then inTable.eventStyle = 0 end
    if inTable.eventStyle ~= 0 and inTable.eventStyle <= 3 then
        inView:setTouchEnabled(true)
        inView:setSwallowTouches(true)
        local viewMgr = ViewManager:getInstance()
        local function endTouchEvent(inTempView)
            
        end
        if inTable.eventStyle == 1 or inTable.eventStyle == 3 then
            inView:setScaleAnim(true)
            iconColor:setScaleAnim(true)
            boxIcon:setScaleAnim(true)
        end

        local downX, downY
        
        registerTouchEvent(inView, function (_, x, y)
            -- downCallback
            if inTable.eventStyle == 1 then
                downX = x
                downY = y
              
            end
            -- 因为相应缩放事件需要锚点为0.5,0.5 inview本身是0,0 为了不去修改游戏内大量代码，
            --   将事件相应的缩放动画 直接应用于子节点。
            --   父节点其他动画效果与缩放action也可以隔离 stopallaction
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonBeginAnim(iconColor)              
                ButtonBeginAnim(boxIcon)
            end

            if inTable.itemData and inTable.itemData.newTips then
                viewMgr:showTip(lang(inTable.itemData.newTips))
            end
            --
        end, function(_, x, y)
            -- moveCallback            
            if inTable.eventStyle == 1 then
                
            end
        end, 
        function ()
            -- upCallback
            endTouchEvent(inView)

            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonEndAnim(iconColor)
                ButtonEndAnim(boxIcon)
            end
        end,
        function ()       
            --outCallback
            endTouchEvent(inView)
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonEndAnim(iconColor)
                ButtonEndAnim(boxIcon)
            end
        end
        ,
        function( )
            -- longCallback
        end)
    end

end
--------------------------------------------
----------------------------------------------------------------------
--[[
--! @function createTeamPlayIconById
--! @desc 领土争夺备战Icon， 仅展示用
--! @param inTable table 相关控制
           playWay 对应玩法 
--! @return bgNode node 
--]]
function IconUtils:createReadlyIconById(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(100, 100)


    local teamIcon = ccSprite:create()
    -- teamIcon:setAnchorPoint(0.5, 0.5)
    teamIcon:setName("teamIcon")
    teamIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    teamIcon:setScale(0.9)
    bgNode:addChild(teamIcon)

    -- local boxIcon = ccSprite:create()
    -- boxIcon:setAnchorPoint(cc.p(0.5, 0.5))
    -- boxIcon:setName("boxIcon")
    -- boxIcon:setPosition(cc.p(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2))
    -- boxIcon:setScale(0.8)
    -- bgNode:addChild(boxIcon, -1)

    local iconColor = ccSprite:create()
    -- iconColor:setAnchorPoint(0.5, 0.5)
    iconColor:setName("iconColor")
    iconColor:setScale(0.9)
    iconColor:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    bgNode:addChild(iconColor,1)
       
    IconUtils:updateReadlyIconByIcon(bgNode, inTable)
    return bgNode
end


--[[
--! @function updateTeamPlayIconByView
--! @desc 更新推荐玩法icon
--! @param inTable table 相关控制
           playWay 对应玩法 
--! @return bgNode node 
--]]
function IconUtils:updateReadlyIconByIcon(inView, inTable)
    if inTable == nil then
        return 
    end

    local teamIcon = inView:getChildByName("teamIcon")

    if teamIcon == nil then 
        return
    end
    
    local filename
    if inTable.readlyIcon then -- 玩法创建
        filename = inTable.readlyIcon
    end
    teamIcon:setSpriteFrame(filename)

    -- teamIcon:setTexture(IconUtils.iconPath .. IconUtils.playWay[inTable.playWay])

    -- local boxIcon = inView:getChildByName("boxIcon")
    -- if boxIcon ~= nil then 
    --     -- if inTable.quality then
    --     --     boxIcon:setSpriteFrame("globalImageUI_quality" .. inTable.quality .. ".png")
    --     -- elseif inTable.qualityImage then
    --     --     boxIcon:setSpriteFrame(inTable.qualityImage)
    --     -- else
    --     --     boxIcon:setSpriteFrame("globalImageUI_quality0.png")
    --     -- end
    --     boxIcon:setVisible(false)
    -- end

    local iconColor = inView:getChildByName("iconColor")
    local tabData = tab:Setting("G_CITYBATTLE_PREPARE_COLOR").value
    local level = inTable.level or 1
    local quality = 1
    if level >= tabData[1] and level < tabData[2] then
        quality = 1
    elseif level >=tabData[2] and level < tabData[3] then
        quality = 2
    elseif level >= tabData[3] and  level < tabData[4] then
        quality = 3
    elseif level >=tabData[4] and  level < tabData[5] then
        quality = 4
    else
        quality = 5
    end
    local imageName = "globalImageUI4_squality" .. quality .. ".png"
    iconColor:setSpriteFrame(imageName)
    -- iconColor:setVisible(false)
end


-- 创建攻城器械icon
function IconUtils:createWeaponsIconById(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(100, 100)

    local weaponsIcon = ccuiImageView:create()
    weaponsIcon:setName("weaponsIcon")
    weaponsIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    bgNode.weaponsIcon = weaponsIcon
    bgNode:addChild(weaponsIcon)

    local boxIcon = ccuiImageView:create()
    boxIcon:setName("boxIcon")
    boxIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    bgNode.boxIcon = boxIcon
    bgNode:addChild(boxIcon, -1)

    local iconColor = ccuiImageView:create()
    iconColor:setName("iconColor")
    iconColor:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    iconColor:setContentSize(93,93)
    iconColor:ignoreContentAdaptWithSize(false)
    bgNode.iconColor = iconColor
    bgNode:addChild(iconColor,1)

    local suoIcon = ccuiImageView:create()
    suoIcon:setName("suoIcon")
    suoIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    bgNode.suoIcon = suoIcon
    bgNode:addChild(suoIcon, 10)

    local levelLab = ccLabel:createWithTTF("", UIUtils.ttfName, 20)
    levelLab:setPosition(10, 10)
    levelLab:setAnchorPoint(0, 0)
    bgNode:addChild(levelLab,3)
    levelLab:enableOutline(ccc4b(60,30,10,255), 1)
    levelLab:setName("levelLab")
    levelLab:setColor(ccc3b(255,255,255))
    bgNode.levelLab = levelLab

    self:updateWeaponsIcon(bgNode, inTable)
    return bgNode
end


-- 更新攻城器械icon
function IconUtils:updateWeaponsIcon(inView, inTable)
    if inTable == nil then
        return 
    end

    local weaponsIcon = inView.weaponsIcon -- inView:getChildByName("weaponsIcon")

    if weaponsIcon == nil then 
        return
    end
    
    local weaponsTab = inTable.weaponsTab
    weaponsIcon:loadTexture(weaponsTab.art1 .. ".jpg",1)

    local boxIcon = inView.boxIcon -- inView:getChildByName("boxIcon")
    if boxIcon ~= nil then 
        local qulityName = "globalImageUI_quality0.png"
        boxIcon:loadTexture(qulityName,1)
    end

    -- local iconColor = inView:getChildByName("iconColor")
    local iconColor = inView.iconColor
    if iconColor then
        iconColor:loadTexture("globalImageUI4_iquality0.png",1)
    end

    
    local levelLab = inView.levelLab
    if levelLab then
        if inTable.level then
            levelLab:setString("Lv." .. inTable.level)
        else
            levelLab:setString("")
        end
    end

    -- 类型
    local weaponTypeIcon = inView.weaponTypeIcon
    if inTable.wType then
        if not weaponTypeIcon then
            weaponTypeIcon = ccuiImageView:create()
            weaponTypeIcon:loadTexture("globalImageUI_weaponType" .. weaponsTab.type .. ".png", 1)
            weaponTypeIcon:setName("weaponTypeIcon")
            weaponTypeIcon:setPosition(10, inView:getContentSize().height-10)
            inView.weaponTypeIcon = weaponTypeIcon
            inView:addChild(weaponTypeIcon, 50)
        end
        weaponTypeIcon:setVisible(true)
    else
        if weaponTypeIcon then
            weaponTypeIcon:setVisible(false)
        end
    end

    -- 锁
    local suoIcon = inView.suoIcon 
    if suoIcon then
        suoIcon:loadTexture("globalImageUI5_treasureLock.png",1)
    end
    if inTable.suo == true then
        if suoIcon then
            suoIcon:setVisible(true)
        end
        if iconColor then
            iconColor:setSaturation(-100)
        end
        if weaponsIcon then
            weaponsIcon:setSaturation(-100)
        end
    else
        if suoIcon then
            suoIcon:setVisible(false)
        end
        if iconColor then
            iconColor:setSaturation(0)
        end
        if weaponsIcon then
            weaponsIcon:setSaturation(0)
        end
    end
end


-- 创建攻城器械技能icon
function IconUtils:createWeaponsSkillIcon(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(100, 100)

    local weaponsIcon = ccuiImageView:create()
    weaponsIcon:setName("weaponsIcon")
    weaponsIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    bgNode.weaponsIcon = weaponsIcon
    bgNode:addChild(weaponsIcon)

    local iconColor = ccuiImageView:create()
    iconColor:setName("iconColor")
    iconColor:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    -- iconColor:setContentSize(90,90)
    -- iconColor:ignoreContentAdaptWithSize(false)
    bgNode.iconColor = iconColor
    bgNode:addChild(iconColor,1)

    self:updateWeaponsSkillIcon(bgNode, inTable)
    return bgNode
end


-- 更新攻城器械技能icon
function IconUtils:updateWeaponsSkillIcon(inView, inTable)
    if inTable == nil then
        return 
    end

    -- local weaponsIcon = inView:getChildByName("weaponsIcon")
    local weaponsIcon = inView.weaponsIcon 
    if weaponsIcon == nil then 
        return
    end
    
    -- 图标
    local sysSkill = inTable.sysSkill
    
    local frameImg = sysSkill.art
    local filename = frameImg .. ".png"
    local sfc = cc.SpriteFrameCache:getInstance()
    if not sfc:getSpriteFrameByName(filename) then
        filename = frameImg .. ".jpg"
    end
    weaponsIcon:loadTexture(filename, 1)  

    -- 框
    -- local iconColor = inView:getChildByName("iconColor")
    local iconColor = inView.iconColor
    if iconColor then
        local frameImg = "globalImageUI_skillWeaponFrame.png"
        if sysSkill.passive == 1 then
            frameImg = "globalImageUI_skillWeaponFrame1.png"
        end
        iconColor:loadTexture(frameImg,1)
    end

    -- 锁
    local lockImg = inView.lockImg
    if inTable.lock == true then
        if not lockImg then
            lockImg = ccuiImageView:create()
            lockImg:loadTexture("globalImageUI5_treasureLock.png", 1)
            lockImg:setName("lockImg")
            lockImg:setPosition(inView:getContentSize().width/2, inView:getContentSize().height/2)
            inView.lockImg = lockImg
            inView:addChild(lockImg, 50)
        end
        lockImg:setVisible(true)
        weaponsIcon:setSaturation(-100)
        iconColor:setSaturation(-100)
    else
        if lockImg then
            lockImg:setVisible(false)
        end
        weaponsIcon:setSaturation(0)
        iconColor:setSaturation(0)
    end
end


--创建城池站武器库icon
local l_tbTagImg = {
    [1] = "weaponImageUI_propsType1.png",
    [2] = "weaponImageUI_propsType2.png",
    [3] = "weaponImageUI_propsType3.png",
    [4] = "weaponImageUI_propsType4.png",
    [5] = "weaponImageUI_propsType5.png"
}
local l_tbUseImg = {
    [1] = "globalImageUI_weaponPropType1.png",
    [2] = "globalImageUI_weaponPropType2.png",
    [3] = "globalImageUI_weaponPropType3.png",
    [4] = "globalImageUI_weaponPropType4.png"
}
function IconUtils:createWeaponsBagItemIcon(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(100, 100)

    local boxIcon = ccuiImageView:create()
    boxIcon:setName("boxIcon")
    boxIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    boxIcon:ignoreContentAdaptWithSize(false)
    bgNode.boxIcon = boxIcon
    boxIcon:setVisible(true)
    bgNode:addChild(boxIcon)

    local iconColor = ccuiImageView:create()
    iconColor:setName("iconColor")
    iconColor:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    iconColor:setContentSize(94,94)
    iconColor:ignoreContentAdaptWithSize(false)
    bgNode:addChild(iconColor)

    local weaponsIcon = ccuiImageView:create()
    weaponsIcon:setName("weaponsIcon")
    weaponsIcon:setPosition(iconColor:getContentSize().width/2, iconColor:getContentSize().height/2)
    iconColor:addChild(weaponsIcon)

    local lvlLabel = ccuiText:create()
    lvlLabel:setString("")
    lvlLabel:setName("lvlLabel")
    lvlLabel:setTextHorizontalAlignment(1)
    lvlLabel:setFontName(UIUtils.ttfName)
    lvlLabel:setFontSize(20)
    lvlLabel:setAnchorPoint(0, 0)
    lvlLabel:setPosition(5, 5)
    iconColor.lvlLabel = lvlLabel
    iconColor:addChild(lvlLabel)
    
    if inTable.tagShow then
        local tagImg = ccuiImageView:create()
        tagImg:setName("tagImg")
        tagImg:setAnchorPoint(1, 1)
        tagImg:setPosition(iconColor:getContentSize().width, iconColor:getContentSize().height)
        iconColor:addChild(tagImg, 5)
        
        --[[local tagLabel = ccuiText:create()
        tagLabel:setString("")
        tagLabel:setFontName(UIUtils.ttfName)
        tagLabel:setFontSize(20)
        tagLabel:setName("tagLabel")
        tagLabel:setRotation(45)
        tagLabel:setColor(cc.c4b(255, 238, 160, 255))
        tagLabel:setAnchorPoint(1, 1)
        tagLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        tagImg:addChild(tagLabel)--]]
    end
    
    
    self:updateWeaponsBagItemIcon(bgNode, inTable)
    return bgNode
end

--更新城池站武器库icon
function IconUtils:updateWeaponsBagItemIcon(inView, inTable)
    if inTable == nil then
        return 
    end

    local itemData = inTable.itemData
    
    -- 框
    local iconColor = inView:getChildByName("iconColor")
    local iconFrame = "globalImageUI4_squality" .. itemData.quality_show .. ".png"
    iconColor:loadTexture(iconFrame, 1)
    
    -- 图标
    local weaponsIcon = iconColor:getChildByName("weaponsIcon")
    if weaponsIcon then 
        weaponsIcon:loadTexture(itemData.art..".png", 1)
    end

    local lvlLabel = iconColor.lvlLabel
    if lvlLabel then
        lvlLabel:setColor(UIUtils.colorTable.ccUIBaseColor1)
        local level = inTable.level or itemData.lvl
        if level then
            level = "Lv." .. level
            lvlLabel:setString(level)
            lvlLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        else
            lvlLabel:setString("")
        end
    end
    
    --品质底色
    local boxIcon = inView:getChildByName("boxIcon")
    if boxIcon then
        local underFrame = "globalImageUI6_itembg_" .. itemData.quality_show .. ".png"
        boxIcon:loadTexture(underFrame, 1)
        boxIcon:setContentSize(92, 92)
    end
    
    --设置标签
    --由于标签资源黄色与其他颜色资源的方向不同，所以特殊处理，即itemData.type3==4时
    if inTable.tagShow then
        local tagImg = iconColor:getChildByName("tagImg")
        tagImg:loadTexture(l_tbTagImg[itemData.type], 1)
--      tagImg:setScaleX( itemData.type3==4 and -1 or 1)
        tagImg:setAnchorPoint(1, 1)
        
        --[[local tagLabel = tagImg:getChildByName("tagLabel")
        tagLabel:setString(lang("SIEGE_EQUIP_TYPE"..itemData.type))
        tagLabel:setRotation(itemData.type3==4 and -45 or 45)
        tagLabel:setScaleX(itemData.type3==4 and -1 or 1)
        local posX = itemData.type3==4 and 3 or tagImg:getContentSize().width-3
        tagLabel:setPosition( posX, tagImg:getContentSize().height-tagLabel:getContentSize().height )--]]
    end
    
    local useImg = iconColor:getChildByName("useImg")
--  useImg:setVisible(inTable.isInUse~=0)
    if not useImg then
        if inTable.isInUse and inTable.isInUse~=0 then
            local useImg = ccuiImageView:create()
            useImg:setName("useImg")
            useImg:loadTexture(l_tbUseImg[inTable.isInUse], 1)
            useImg:setAnchorPoint(0, 0.5)
            useImg:setPosition(cc.p(-10, iconColor:getContentSize().height*3/4+10))
            iconColor:addChild(useImg, 6)
        end
    else
        if inTable.isInUse and inTable.isInUse~=0 then
            useImg:setVisible(true)
            useImg:loadTexture(l_tbUseImg[inTable.isInUse], 1)
        else
            useImg:setVisible(false)
        end
    end
    
    local bgMc
    local bgMcName
    local scaleNum = 1
    local offsetX = 0
    local effect = inTable.effect -- true加特效
    local bgEffect = iconColor:getChildByName("bgMc")
    if bgEffect then
        bgEffect:removeFromParent()
        bgEffect = nil
    end
    local diguang = boxIcon:getChildByFullName("diguangMc")
    if effect then
        local shineData = itemData.splight
        if shineData then
            local isDiguang = false
            local mcTb = {}
            for i,v in ipairs(shineData) do
                if 4==v then
                    isDiguang = true
                else
                    table.insert(mcTb, itemEffect[v])
                end
            end
            bgMc = IconUtils:addEffectByName(mcTb, iconColor)
            if not bgEffect and bgMc then
                bgMc:setScale(scaleNum)
                bgMc:setName("bgMc")
                iconColor:addChild(bgMc, 10)
            else
                if bgEffect then
                    bgEffect:setVisible(true)
                end
            end
            if isDiguang and not diguang then
                local diguangMc = mcMgr:createViewMC(itemEffect[4], true, false, function(_, sender)
                    sender:gotoAndPlay(0)
                end, RBGA8888)
                diguangMc:setName("diguangMc")
                diguangMc:setPosition(boxIcon:getContentSize().width/2-4, boxIcon:getContentSize().height/2)
                boxIcon:addChild(diguangMc, -2)
            else
                if diguang then
                    diguang:setVisible(true)
                end
            end
        end
    else
        if bgEffect then
            bgEffect:setVisible(false)
        end
        if diguang then
            diguang:setVisible(false)
        end
    end
    
    -- 部分地方只为展示icon 无任何事件
    if not inTable.eventStyle then inTable.eventStyle = 1 end
    if inTable.eventStyle ~= 0 then
        inView:setTouchEnabled(true)
        if inTable.swallowTouches == nil then
            inView:setSwallowTouches(false)
        else
            inView:setSwallowTouches(inTable.swallowTouches)
        end
        local viewMgr = ViewManager:getInstance()
        if inTable.eventStyle == 1 or inTable.eventStyle == 3 then
            inView:setScaleAnim(true)
            iconColor:setScaleAnim(true)
            boxIcon:setScaleAnim(true)
        elseif inTable.eventStyle == 4 then
            inView:setScaleAnim(false)
            iconColor:setScaleAnim(false)
            boxIcon:setScaleAnim(false)
            inTable.eventStyle = 1
        elseif inTable.eventStyle == 5 then 
            inView:setScaleAnim(false)
            iconColor:setScaleAnim(false)
            boxIcon:setScaleAnim(false)
            registerTouchEvent(inView, function()
                -- body
            end, function()
                -- body
            end, function()
                -- body
            end, function()
                -- body
            end, function()
                -- body
            end)
            return
        end
        
        local downX, downY
        registerTouchEvent(inView, function (_, x, y)
            if inTable.eventStyle == 1 then
                downX = x
                downY = y
            end
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonBeginAnim(iconColor)
                ButtonBeginAnim(boxIcon)
            end
            --]] 
        end, function(_, x, y)
            if inTable.eventStyle == 1 then
                -- if (downX and math.abs(downX - x) > 5) or math.abs(downY - y) > 5 then
                --  -- boxIcon:stopAllActions()
                -- end
                -- viewMgr:closeHintView()
            end
        end, 
        function ()
            if inTable.eventStyle == 1 then
                -- boxIcon:stopAllActions()
                -- viewMgr:closeHintView()
                 if inTable.eventStyle ~= 3 or inTable.showTip == true then
                    viewMgr:showHintView("global.GlobalTipView",{tipType = 23, node = boxIcon, id = inTable.itemId,level = inTable.level or itemData.lvl,notAutoClose = true,forceColor = color})
                end
            elseif inTable.eventStyle == 2 then 
                -- 展示需要点击view 
                print("==============================================")
            end
            -- 回调
            if inTable.eventStyle == 3 and
            inTable.clickCallback ~= nil then 
                inTable.clickCallback(inTable.itemId, inTable.num)
            end
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonEndAnim(iconColor)
                -- ButtonEndAnim(weaponsIcon)
                ButtonEndAnim(boxIcon)
            end
        end,
        function ()
            if inTable.eventStyle == 1 then
                -- boxIcon:stopAllActions()
                -- viewMgr:closeHintView()
            end
            -- endTouchEvent(inView)
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonEndAnim(iconColor)
                -- ButtonEndAnim(weaponsIcon)
                ButtonEndAnim(boxIcon)
            end
        end--)
        ,
        function( )
            -- if inTable.eventStyle ~= 3 or inTable.showTip == true then
            --     viewMgr:showHintView("global.GlobalTipView",{tipType = 23, node = boxIcon, id = inTable.itemId,level = inTable.level or itemData.lvl,forceColor = color})
            -- end
        end)
    end
end



-----------------------------------------------------------------------
--[[
--! @function createWeaponIcon
--! @desc 创建配件icon
--! @param inTable table 相关控制
           itemId int 物品id
           name string 名字
           num int 数量
           swallowTouches bool 是否会点穿, 默认是false
           eventStyle int 事件类型 
                    0:无事件响应,
                    1:长按显示信息,
                    2:点击显示弹出框信息,
                    3:回调点击事件
           clickCallback 点击毁掉事件
--! @return bgNode node 
--]]

-- local itemEffect = {
--     [1] = "wupinguang_itemeffectcollection",                -- 转光
--     [2] = "wupinkuangxingxing_itemeffectcollection",        -- 星星
--     [3] = "tongyongdibansaoguang_itemeffectcollection",     -- 扫光
--     [4] = "diguang_itemeffectcollection",                   -- 底光
-- }

function IconUtils:createWeaponIcon(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(92, 92)
    bgNode:setCascadeOpacityEnabled(true)

    local itemIcon = ccuiImageView:create()
    itemIcon:setName("itemIcon")
    itemIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    itemIcon:ignoreContentAdaptWithSize(false)

    bgNode.itemIcon = itemIcon
    bgNode:addChild(itemIcon,1)

    local boxIcon = ccuiImageView:create()

    boxIcon:setName("boxIcon")
    boxIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    boxIcon:ignoreContentAdaptWithSize(false)

    bgNode.boxIcon = boxIcon
    bgNode:addChild(boxIcon,-1)

    local iconColor = ccuiImageView:create()
    iconColor:setName("iconColor")
    iconColor:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    iconColor:ignoreContentAdaptWithSize(false)
    iconColor:setCascadeOpacityEnabled(true)
    iconColor:setContentSize(92, 92)
    bgNode.iconColor = iconColor
    bgNode:addChild(iconColor,6)

    -- [[ iconColor 作为附加的碎片标记 iconMark,数量 numLab 等的父节点来管理
    --    用于处理按钮缩小事件 by guojun 2016.12.29
    --]]

    -- local iconMark = ccuiImageView:create()
    -- iconMark:setAnchorPoint(0, 1)
    -- iconMark:setName("iconMark")
    -- iconMark:setPosition(-4, bgNode:getContentSize().height+3)
    -- iconMark:ignoreContentAdaptWithSize(false)
    -- -- bgNode:addChild(iconMark,100)
    -- iconColor.iconMark = iconMark
    -- iconColor:addChild(iconMark,100)

    -- if inTable.num ~= nil then 
    local numLab =  ccuiText:create()
    numLab:setString("")
    numLab:setName("numLab")
    numLab:setFontSize(20)

    numLab:setFontName(UIUtils.ttfName)
    numLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
    numLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    numLab:setAnchorPoint(1, 0)
    numLab:setPosition(bgNode:getContentSize().width - 10, 5)

    iconColor.numLab = numLab
    iconColor:addChild(numLab,11)

    if inTable.name ~= nil then 
        local nameLab = ccuiText:create()
        nameLab:setString("")
        nameLab:setName("nameLab")
        nameLab:setFontName(UIUtils.ttfName)
        nameLab:setFontSize(20)
        nameLab:setAnchorPoint(1, 0)
        nameLab:setPosition(bgNode:getContentSize().width - 11, 13)
        iconColor.nameLab = nameLab
        iconColor:addChild(nameLab,12)
    end

    if inTable.tagShow then
        local tagImg = ccuiImageView:create()
        tagImg:setName("tagImg")
        tagImg:setAnchorPoint(1, 1)
        tagImg:setPosition(iconColor:getContentSize().width, iconColor:getContentSize().height)
        iconColor:addChild(tagImg, 55)
        
        -- local tagLabel = ccuiText:create()
        -- tagLabel:setString("")
        -- tagLabel:setFontName(UIUtils.ttfName)
        -- tagLabel:setFontSize(20)
        -- tagLabel:setName("tagLabel")
        -- tagLabel:setRotation(45)
        -- tagLabel:setColor(cc.c4b(255, 238, 160, 255))
        -- tagLabel:setAnchorPoint(1, 1)
        -- tagLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        -- tagImg:addChild(tagLabel)
    end

    IconUtils:updateWeaponIconByView(bgNode, inTable)
    return bgNode
end

--[[
--! @function updateWeaponIconByView
--! @desc 更新物品icon相关信息与事件
--! @param inView object 操作icon
--! @param inTable table 相关控制
           itemId int 物品id
           num int 数量
           effect bool 背景光效
           name string 名字
           swallowTouches bool 是否会点穿, 默认是false
           eventStyle int 事件类型 
                    0:无事件响应,
                    1:长按显示信息,
                    2:点击显示弹出框信息,
                    3:回调点击事件
           clickCallback 点击毁掉事件
--! @return
--]]


function IconUtils:updateWeaponIconByView(inView, inTable)
    -- dump(inTable)
    if inTable == nil or 
        inTable.itemId == nil then
        return 
    end
    local itemIcon = inView.itemIcon
    if itemIcon == nil then 
        return
    end
    local scaleNum = 1
    -- 额外添加的节点 除了动画 都加在iconColor上管理
    local iconColor = inView.iconColor
    iconColor:setScale(scaleNum)

    local isSplice = false
    
    local playerSkillID
    local num_itemid = tonumber(inTable.itemId)
    local toolD = tab.siegeEquip[num_itemid] 
    local color = inTable.forceColor or toolD.quality_show
    if toolD then
        if toolD.art then
            local filename = toolD.art .. ".png"
            local sfc = cc.SpriteFrameCache:getInstance()
            if not sfc:getSpriteFrameByName(filename) then
                filename = toolD.art .. ".jpg"
            end
            itemIcon:loadTexture(filename, 1)
        end
        -- local typeId = toolD["typeId"]
        -- -- print("typeId",inTable.itemId,typeId,ItemUtils.ITEM_BUT_SPLICE)
        -- if typeId == ItemUtils.ITEM_TYPE_SPLICE or typeId == ItemUtils.ITEM_TYPE_HEROSPLICE
        -- or typeId == ItemUtils.ITEM_TYPE_AWAKESPLICE or typeId == ItemUtils.ITEM_TYPE_SKILL then
        --     isSplice = true
        --     -- 添加碎片标记
        --     local mark = iconColor.iconMark
        --     if typeId == ItemUtils.ITEM_TYPE_HEROSPLICE then
        --         mark:loadTexture("globalImageUI_heroSplice.png",1)
        --         local color = inTable.color or toolD.color or 1
        --         if color == 4 then  -- 染成紫色 为紫色图标特做 2017.2.6
        --             mark:setHue(-125)
        --         end 
        --     elseif typeId == ItemUtils.ITEM_TYPE_AWAKESPLICE then
        --         mark:loadTexture("globalImageUI_splice_jx.png",1)
        --     else
        --         mark:loadTexture("globalImageUI_splice".. (inTable.color or toolD.color or 1) ..".png",1)
        --     end
        --     mark:setContentSize(35, 35)
        --     mark:setVisible(true)
        -- else
        --     if typeId == 5 then -- 宝物图标缩放
        --         itemIcon:setScale(0.85)
        --     end
        --     if iconColor.iconMark then 
        --         iconColor.iconMark:setVisible(false)
        --     end
        -- end
     --     local iconColor = inView:getChildByFullName("iconColor")
        --  iconColor:loadTexture("globalImagUI_spliceFrame.png", 1)
        --  iconColor:setContentSize(cc.size(98, 98))

        --  itemIcon:setContentSize(cc.size(96, 96))
        --     itemIcon:setScale(80/102)
        --     -- itemIcon:setPosition(cc.p(50,50))
        --     -- local icon = IconUtils:setRoundedCorners(itemIcon, toolD.art, "globalImageUI_spliceBg.png")
        --     -- icon:setName("itemIcon")
        -- else
            
        itemIcon:setContentSize(89, 89) -- 防止漏角
        -- itemIcon:setScale(scaleNum)
        -- itemIcon:setScale(80/98)
            -- local icon = IconUtils:setRoundedCorners(itemIcon, toolD.art)
            -- icon:setName("itemIcon")
        -- end

        iconColor:setContentSize(92, 92)
        if not inTable.itemData then
            inTable.itemData = toolD
        end
    end


    if iconColor.numLab ~= nil
        and not inTable.hideNumLab and inTable.num ~= nil and  (inTable.num ~= nil and inTable.num ~= -1) then 
        local numLab = iconColor.numLab
        if inTable.num == 0 then
            numLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
        else
            numLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
        end
        -- local formatNum = ItemUtils.formatItemCount(inTable.num,"w")
        -- numLab:setString(formatNum)
        -- numLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        -- iconColor.numLab:setVisible(true)
    else
        -- iconColor.numLab:setVisible(false)
    end

    -- if iconColor.nameLab ~= nil
    --     and inTable.name ~= nil 
    --     and inTable.name > 0 then 
    --     iconColor.nameLab:setString(inTable.name)
    -- end

    --设置标签
    --由于标签资源黄色与其他颜色资源的方向不同，所以特殊处理，即itemData.type3==4时
    local itemData = inTable.itemData
    if inTable.tagShow then
        -- local tagImg = iconColor:getChildByName("tagImg")
        -- tagImg:loadTexture(l_tbTagImg[itemData.type3], 1)
        -- tagImg:setScaleX( itemData.type3==4 and -1 or 1)
        -- tagImg:setAnchorPoint( itemData.type3==4 and cc.p(0, 1) or cc.p(1, 1))
        local tagImg = iconColor:getChildByName("tagImg")
        tagImg:loadTexture(l_tbTagImg[itemData.type], 1)
--      tagImg:setScaleX( itemData.type3==4 and -1 or 1)
        tagImg:setAnchorPoint(1, 1)
        
        -- local tagLabel = tagImg:getChildByName("tagLabel")
        -- tagLabel:setString(lang("SIEGE_EQUIP_TYPE"..itemData.type))
        -- tagLabel:setRotation(itemData.type3==4 and -45 or 45)
        -- tagLabel:setScaleX(itemData.type3==4 and -1 or 1)
        -- local posX = itemData.type3==4 and 3 or tagImg:getContentSize().width-3
        -- tagLabel:setPosition( posX, tagImg:getContentSize().height-tagLabel:getContentSize().height )
    end

    
    local boxIcon = inView.boxIcon
    if boxIcon ~= nil and inTable.itemData then 
        boxIcon:setScale(scaleNum)
        boxIcon:loadTexture("globalImageUI6_itembg_".. color ..".png", 1)
        boxIcon:setContentSize(92, 92)
    end
    
    if inTable.itemData then
        color = color or inTable.itemData.quality or 1

        local colorPng = "globalImageUI4_squality" .. color .. ".png"
        iconColor:loadTexture(colorPng, 1)
        inView.textureName = colorPng
        -- 加背景光效
        local bgMc
        local bgMcname2
        
        local sacleNum = 1
        local offsetX = 0
        local effect = inTable.effect --true 不加特效
        local bgEffect = iconColor:getChildByName("bgMc")
        if bgEffect then  -- 用于刷新
            bgEffect:removeFromParent()
            bgEffect = nil
        end
        local diguang = boxIcon:getChildByFullName("diguangMc")
        if not effect then
            local shineData = inTable.itemData.splight
            if shineData then
                local isDiguang = false
                local mcTb = {}
                for k,v in pairs(shineData) do
                    if 4 == v then
                        isDiguang = true
                    else
                        table.insert(mcTb, itemEffect[v])
                    end 
                end
                bgMc = IconUtils:addEffectByName(mcTb,iconColor)

                if not bgEffect and bgMc then  
                    bgMc:setScale(sacleNum) 
                    bgMc:setName("bgMc")
                    iconColor:addChild(bgMc,10)
                else
                    if bgEffect then
                        bgEffect:setVisible(true)
                    end
                end
                
                if isDiguang and not diguang then  
                    local diguangMc =  mcMgr:createViewMC(itemEffect[4], true, false, function (_, sender)
                        sender:gotoAndPlay(0)
                    end,RGBA8888) 
                    diguangMc:setName("diguangMc")
                    diguangMc:setPosition(boxIcon:getContentSize().width*0.5-4,boxIcon:getContentSize().height*0.5)
                    boxIcon:addChild(diguangMc,-2)
                else
                    if diguang then
                        diguang:setVisible(true)
                    end
                end
            end
            --]]
        else
            if bgEffect then
                bgEffect:setVisible(false)
            end
            if diguang then
                diguang:setVisible(false)
            end
        end

    end

    -- 部分地方只为展示icon 无任何事件
    if not inTable.eventStyle then inTable.eventStyle = 1 end
    if inTable.eventStyle ~= 0 then
        inView:setTouchEnabled(true)
        if inTable.swallowTouches == nil then
            inView:setSwallowTouches(false)
        else
            inView:setSwallowTouches(inTable.swallowTouches)
        end
        local showView = nil
        local viewMgr = ViewManager:getInstance()
        local function endTouchEvent(inTempView)
            --print("endTouchEvent=======")
            -- inTempView:setScale(inTempView:getScale() + 0.05)
            if inTable.eventStyle == 1 and 
                showView ~= nil then
                --viewMgr:closeDialog(showView)
            end
        end
        if inTable.eventStyle == 1 or inTable.eventStyle == 3 then
            inView:setScaleAnim(true)
            iconColor:setScaleAnim(true)
            itemIcon:setScaleAnim(true)
            boxIcon:setScaleAnim(true)
        elseif inTable.eventStyle == 4 then
            inView:setScaleAnim(false)
            iconColor:setScaleAnim(false)
            itemIcon:setScaleAnim(false)
            boxIcon:setScaleAnim(false)
            inTable.eventStyle = 1
        elseif inTable.eventStyle == 5 then 
            inView:setScaleAnim(false)
            iconColor:setScaleAnim(false)
            itemIcon:setScaleAnim(false)
            boxIcon:setScaleAnim(false)
            registerTouchEvent(inView, function()
                -- body
            end, function()
                -- body
            end, function()
                -- body
            end, function()
                -- body
            end, function()
                -- body
            end)
            return
        end

        local downX, downY
        registerTouchEvent(inView, function (_, x, y)
            viewMgr:closeHintView()
            if inTable.eventStyle == 1 then
                downX = x
                downY = y
                -- boxIcon:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function( )
                --  viewMgr:showHintView("global.GlobalTipView",{tipType = 1, node = boxIcon, id = inTable.itemId,forceColor = color})
                -- end)))
                -- down

                showView = 1
                -- 展示view
            end
            -- [[因为相应缩放事件需要锚点为0.5,0.5 inview本身是0,0 为了不去修改游戏内大量代码，
            --   将事件相应的缩放动画 直接应用于子节点。
            --   父节点其他动画效果与缩放action也可以隔离 stopallaction
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonBeginAnim(iconColor)
                ButtonBeginAnim(itemIcon)
                ButtonBeginAnim(boxIcon)
            end
            --]] 
        end, function(_, x, y)
            if inTable.eventStyle == 1 then
                -- if (downX and math.abs(downX - x) > 5) or math.abs(downY - y) > 5 then
                --  -- boxIcon:stopAllActions()
                -- end
                -- viewMgr:closeHintView()
            end
        end, 
        function ()
            endTouchEvent(inView)
            -- 2017.5.11 duyuye改tip 为点击出
            if inTable.eventStyle ~= 3 or inTable.showTip == true then
                -- if inTable.showSpecailSkillBookTip and playerSkillID then
                --     viewMgr:showHintView("global.GlobalTipView",{tipType = 2, node = boxIcon, id = playerSkillID, notAutoClose=true})
                -- else
                    viewMgr:showHintView("global.GlobalTipView",{tipType = 23, node = boxIcon, id = tonumber(inTable.itemId),forceColor = color,notAutoClose=true, level = inTable.itemData.lvlimit,showMax=inTable.showMax})
                -- end
            end

            if inTable.eventStyle == 1 then
                -- boxIcon:stopAllActions()
                -- viewMgr:closeHintView()
            elseif inTable.eventStyle == 2 then 
                -- 展示需要点击view 
                print("==============================================")
            end
            -- 回调
            if inTable.eventStyle == 3 and
            inTable.clickCallback ~= nil then 
                inTable.clickCallback(inTable.itemId, inTable.num)
            end
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonEndAnim(iconColor)
                ButtonEndAnim(itemIcon)
                ButtonEndAnim(boxIcon)
            end
        end,
        function ()
            if inTable.eventStyle == 1 then
                -- boxIcon:stopAllActions()
                -- viewMgr:closeHintView()
            end
            endTouchEvent(inView)
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonEndAnim(iconColor)
                ButtonEndAnim(itemIcon)
                ButtonEndAnim(boxIcon)
            end
        end--)
        ,
        function( )

        end)
    end
end


-----------------------------------------------------------------------

-- 创建符文宝石icon
-- 方形
function IconUtils:createHolyIconById(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(100, 100)

    local holyIcon = ccuiImageView:create()
    holyIcon:setName("holyIcon")
    holyIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    bgNode.holyIcon = holyIcon
    bgNode:addChild(holyIcon)

    local boxIcon = ccuiImageView:create()
    boxIcon:setName("boxIcon")
    boxIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    bgNode.boxIcon = boxIcon
    bgNode:addChild(boxIcon, -1)

    local iconColor = ccuiImageView:create()
    iconColor:setName("iconColor")
    iconColor:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    iconColor:setContentSize(93,93)
    iconColor:ignoreContentAdaptWithSize(false)
    bgNode.iconColor = iconColor
    bgNode:addChild(iconColor,1)

    local suoIcon = ccuiImageView:create()
    suoIcon:setName("suoIcon")
    suoIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    bgNode.suoIcon = suoIcon
    bgNode:addChild(suoIcon, 10)

    --[[local levelLab = ccLabel:createWithTTF("666", UIUtils.ttfName, 20)
    levelLab:setPosition(10, 10)
    levelLab:setAnchorPoint(0, 0)
    bgNode:addChild(levelLab,3)
    levelLab:enableOutline(ccc4b(60,30,10,255), 1)
    levelLab:setName("levelLab")
    levelLab:setColor(ccc3b(255,255,255))
    bgNode.levelLab = levelLab--]]

    local numLab =  ccuiText:create()
    numLab:setString("")
    numLab:setName("numLab")
    numLab:setFontSize(20)
    numLab:setFontName(UIUtils.ttfName)
    numLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
    numLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    numLab:setAnchorPoint(1, 0)
    numLab:setPosition(bgNode:getContentSize().width - 10, 5)
    iconColor.numLab = numLab
    iconColor:addChild(numLab,11)
    
    local lvlImg = ccuiImageView:create()
    lvlImg:setName("lvlImg")
    bgNode.lvlImg = lvlImg
    bgNode:addChild(lvlImg, 10)
    
    local lvlLab = ccuiText:create()
    lvlLab:setFontName(UIUtils.ttfName)
    lvlLab:setFontSize(15)
    lvlLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    lvlImg.lvlLab = lvlLab
    lvlImg:addChild(lvlLab)

    self:updateHolyIcon(bgNode, inTable)
    return bgNode
end


-- 更新攻城器械icon
function IconUtils:updateHolyIcon(inView, inTable)
    if inTable == nil then
        return 
    end

    local holyIcon = inView.holyIcon 

    if holyIcon == nil then 
        return
    end
    
    local suitData = inTable.suitData
    holyIcon:loadTexture(suitData.art .. ".png",1)

    local boxIcon = inView.boxIcon -- inView:getChildByName("boxIcon")
    if boxIcon ~= nil then 
        local qulityName = "globalImageUI_quality0.png"
        boxIcon:loadTexture(qulityName,1)
    end

    -- local iconColor = inView:getChildByName("iconColor")
    local iconColor = inView.iconColor
    if iconColor then
        local quality = suitData.quality
        if quality then
            iconColor:loadTexture("globalImageUI4_squality" .. quality .. ".png",1)
        else
            iconColor:loadTexture("globalImageUI4_iquality0.png",1)
        end
    end
    
    local stoneData = inTable.stoneData
    if stoneData then
        local lvlImg = inView.lvlImg
        if lvlImg then
            lvlImg:loadTexture("globalImageUI4_iquality" .. stoneData.quality .. ".png", 1)
            local posX = holyIcon:getPositionX()-holyIcon:getContentSize().width/2 + lvlImg:getContentSize().width/2
            local posY = holyIcon:getPositionY()+holyIcon:getContentSize().height/2 - lvlImg:getContentSize().height/2+1
            lvlImg:setPosition(cc.p(posX, posY))
            
            local lvlLab = lvlImg.lvlLab
            if lvlLab then
                lvlLab:setString("+"..stoneData.lv-1)
                lvlLab:setPosition(cc.p(lvlImg:getContentSize().width/2, lvlImg:getContentSize().height/2+2))
                lvlImg:setVisible(stoneData.lv>1)
            end
        end
    end

    if iconColor.numLab ~= nil and not inTable.hideNumLab and inTable.num ~= nil and inTable.num ~= -1 then 
        local numLab = iconColor.numLab
        if inTable.num == 0 then
            numLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
        else
            numLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
        end
        local formatNum = ItemUtils.formatItemCount(inTable.num,"w")
        numLab:setString(formatNum)
        numLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        iconColor.numLab:setVisible(true)

    else
        iconColor.numLab:setVisible(false)
    end
    
    --[[local levelLab = inView.levelLab
    if levelLab then
        if inTable.level then
            levelLab:setString("Lv." .. inTable.level)
        else
            levelLab:setString("")
        end
    end--]]

    -- -- 类型
    -- local weaponTypeIcon = inView.weaponTypeIcon
    -- if inTable.wType then
    --     if not weaponTypeIcon then
    --         weaponTypeIcon = ccuiImageView:create()
    --         weaponTypeIcon:loadTexture("globalImageUI_weaponType" .. suitData.type .. ".png", 1)
    --         weaponTypeIcon:setName("weaponTypeIcon")
    --         weaponTypeIcon:setPosition(10, inView:getContentSize().height-10)
    --         inView.weaponTypeIcon = weaponTypeIcon
    --         inView:addChild(weaponTypeIcon, 50)
    --     end
    --     weaponTypeIcon:setVisible(true)
    -- else
    --     if weaponTypeIcon then
    --         weaponTypeIcon:setVisible(false)
    --     end
    -- end

    -- 锁
    local suoIcon = inView.suoIcon 
    if suoIcon then
        suoIcon:loadTexture("globalImageUI5_treasureLock.png",1)
    end
    if inTable.suo == true then
        if suoIcon then
            suoIcon:setVisible(true)
        end
        if iconColor then
            iconColor:setSaturation(-100)
        end
        if holyIcon then
            holyIcon:setSaturation(-100)
        end
    else
        if suoIcon then
            suoIcon:setVisible(false)
        end
        if iconColor then
            iconColor:setSaturation(0)
        end
        if holyIcon then
            holyIcon:setSaturation(0)
        end
    end
    if inTable.isTouch~=false then
        if not inTable.notAnim then
            inView:setScaleAnim(true)
            iconColor:setScaleAnim(true)
            holyIcon:setScaleAnim(true)
            boxIcon:setScaleAnim(true)
        end
        
        local downX, downY
        registerTouchEvent(inView, function (_, x, y)
            viewMgr:closeHintView()
            if inTable.eventStyle == 1 then
                downX = x
                downY = y
            end
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonBeginAnim(iconColor)
                ButtonBeginAnim(holyIcon)
                ButtonBeginAnim(boxIcon)
            end
        end, function(_, x, y)
            if inTable.eventStyle == 1 then
                
            end
        end, 
        function ()
--          endTouchEvent(inView)
            if inTable.eventStyle ~= 3 or inTable.showTip == true then
                viewMgr:showHintView("team.TeamHolyTipView",{hintType = 5, key = inTable.stoneData and inTable.stoneData.key or nil, holyData = inTable.suitData, node = inView})
                if inTable.clickCallback then
                    inTable.clickCallback(true)
                end
            end
            -- 回调
            --[[if inTable.eventStyle == 3 and inTable.clickCallback ~= nil then 
                inTable.clickCallback(inTable.suitData.id, inTable.num)
            end--]]
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonEndAnim(iconColor)
                ButtonEndAnim(holyIcon)
                ButtonEndAnim(boxIcon)
            end
        end,
        function ()
            if inTable.eventStyle == 1 then
                
            end
--          endTouchEvent(inView)
            local ax, ay = inView:getAnchorPoint().x, inView:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonEndAnim(iconColor)
                ButtonEndAnim(holyIcon)
                ButtonEndAnim(boxIcon)
            end
        end,
        function( )
            
        end)
        inView:setSwallowTouches(false)
    end
end


-- -- 创建符文宝石icon
-- -- 圆形
-- function IconUtils:createStoneIconById(inTable)
--     if inTable == nil then
--         inTable = {}
--     end
--     local bgNode = ccuiWidget:create()
--     bgNode:setAnchorPoint(0,0)
--     bgNode:setContentSize(100, 100)

--     local holyIcon = ccuiImageView:create()
--     holyIcon:setName("holyIcon")
--     holyIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
--     bgNode.holyIcon = holyIcon
--     bgNode:addChild(holyIcon)

--     local boxIcon = ccuiImageView:create()
--     boxIcon:setName("boxIcon")
--     boxIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
--     bgNode.boxIcon = boxIcon
--     bgNode:addChild(boxIcon, -1)

--     local iconColor = ccuiImageView:create()
--     iconColor:setName("iconColor")
--     iconColor:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
--     iconColor:setContentSize(93,93)
--     iconColor:ignoreContentAdaptWithSize(false)
--     bgNode.iconColor = iconColor
--     bgNode:addChild(iconColor,1)

--     local suoIcon = ccuiImageView:create()
--     suoIcon:setName("suoIcon")
--     suoIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
--     bgNode.suoIcon = suoIcon
--     bgNode:addChild(suoIcon, 10)

--     local levelLab = ccLabel:createWithTTF("666", UIUtils.ttfName, 20)
--     levelLab:setPosition(10, 10)
--     levelLab:setAnchorPoint(0, 0)
--     bgNode:addChild(levelLab,3)
--     levelLab:enableOutline(ccc4b(60,30,10,255), 1)
--     levelLab:setName("levelLab")
--     levelLab:setColor(ccc3b(255,255,255))
--     bgNode.levelLab = levelLab

--     self:updateStoneIcon(bgNode, inTable)
--     return bgNode
-- end


-- -- 更新攻城器械icon
-- function IconUtils:updateStoneIcon(inView, inTable)
--     if inTable == nil then
--         return 
--     end

--     local holyIcon = inView.holyIcon 

--     if holyIcon == nil then 
--         return
--     end
    
--     local suitData = inTable.suitData
--     holyIcon:loadTexture(suitData.art .. ".png",1)

--     local boxIcon = inView.boxIcon -- inView:getChildByName("boxIcon")
--     if boxIcon ~= nil then 
--         local qulityName = "globalImageUI_skillWeaponFrame.png"
--         boxIcon:loadTexture(qulityName,1)
--     end

--     -- local iconColor = inView:getChildByName("iconColor")
--     local iconColor = inView.iconColor
--     if iconColor then
--         local quality = suitData.quality
--         if quality then
--             iconColor:loadTexture("globalImageUI4_squality" .. quality .. ".png",1)
--         else
--             iconColor:loadTexture("globalImageUI4_iquality0.png",1)
--         end
--         iconColor:loadTexture("globalImageUI_skillWeaponFrame.png",1)
--     end
    
--     local levelLab = inView.levelLab
--     if levelLab then
--         if inTable.level then
--             levelLab:setString("Lv." .. inTable.level)
--         else
--             levelLab:setString("")
--         end
--     end

--     -- 锁
--     local suoIcon = inView.suoIcon 
--     if suoIcon then
--         suoIcon:loadTexture("globalImageUI5_treasureLock.png",1)
--     end
--     if inTable.suo == true then
--         if suoIcon then
--             suoIcon:setVisible(true)
--         end
--         if iconColor then
--             iconColor:setSaturation(-100)
--         end
--         if holyIcon then
--             holyIcon:setSaturation(-100)
--         end
--     else
--         if suoIcon then
--             suoIcon:setVisible(false)
--         end
--         if iconColor then
--             iconColor:setSaturation(0)
--         end
--         if holyIcon then
--             holyIcon:setSaturation(0)
--         end
--     end
-- end


function IconUtils:createBuffIconById(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(92, 92)
    bgNode:setCascadeOpacityEnabled(true)

    local itemIcon = ccuiImageView:create()

    itemIcon:setName("itemIcon")
    itemIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    itemIcon:loadTexture(inTable.image, 1)
    itemIcon:setContentSize(89, 89)
    itemIcon:ignoreContentAdaptWithSize(false)

    bgNode.itemIcon = itemIcon
    bgNode:addChild(itemIcon,1)

    local boxIcon = ccuiImageView:create()
    boxIcon:setName("boxIcon")
    boxIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    if inTable.quality then
        boxIcon:loadTexture("globalImageUI6_itembg_" .. inTable.quality .. ".png", 1)
    else
        boxIcon:loadTexture("globalImageUI6_itembg_1.png", 1)
    end
    boxIcon:setContentSize(92, 92)
    boxIcon:ignoreContentAdaptWithSize(false)

    bgNode.boxIcon = boxIcon
    bgNode:addChild(boxIcon,-1)

    local iconColor = ccuiImageView:create()
    iconColor:setName("iconColor")
    iconColor:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    iconColor:ignoreContentAdaptWithSize(false)
    iconColor:setCascadeOpacityEnabled(true)
    iconColor:setContentSize(92, 92)
    if inTable.bigpeer then
        iconColor:loadTexture("globalImageUI4_squality5.png", 1)
    else
        iconColor:loadTexture("globalImageUI4_squality1.png", 1)
    end
    iconColor:setContentSize(92, 92)
    bgNode.iconColor = iconColor
    bgNode:addChild(iconColor,6)
    
    local descBg = cc.Scale9Sprite:createWithSpriteFrameName("allianceScicene_lvlBarBg.png")
    descBg:setCapInsets(cc.rect(10, 10, 1, 1))
    descBg:setContentSize(bgNode:getContentSize().width, 20)
    descBg:setOpacity(255*0.6)
    descBg:setPosition(bgNode:getContentSize().width/2, descBg:getContentSize().height/2)--由于巫师秘境的人物小，所以要根据不同类型设置名字位置
    bgNode:addChild(descBg, 30)
    
    local desText = string.gsub(lang(inTable.buffConfig.des), "$num", inTable.buffConfig.buff[2])
    desText = string.gsub(desText, "20", "12")
    local desc = RichTextFactory:create(desText, descBg:getContentSize().width, 0)
    desc:formatText()
    desc:setName("desc")
    desc:setPosition(descBg:getContentSize().width/2, descBg:getContentSize().height/2)
    descBg:addChild(desc)
    UIUtils:alignRichText(desc)
    
    bgNode:setScale(inTable.scale)
    
    

    return bgNode
end


function IconUtils:createTeamHolySuitIcon(inTable)
    if inTable == nil then
        inTable = {}
    end
    
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0.5,0.5)
    bgNode:setContentSize(89, 89)
    bgNode:setCascadeOpacityEnabled(true)
    local bgSize = bgNode:getContentSize()
    
    local itemIcon = ccuiImageView:create()
    itemIcon:setName("itemIcon")
    itemIcon:setPosition(bgSize.width/2, bgSize.height/2)
    itemIcon:loadTexture(inTable.tabConfig.icon..".png", 1)
    itemIcon:setContentSize(85, 85)
    itemIcon:ignoreContentAdaptWithSize(false)
    bgNode.itemIcon = itemIcon
    bgNode:addChild(itemIcon)
    
    local boxIcon = ccuiImageView:create()
    boxIcon:setName("boxIcon")
    boxIcon:setPosition(bgSize.width/2, bgSize.height/2)
    if inTable.quality then
        boxIcon:loadTexture("teamHoly_iteamBg" .. inTable.quality .. ".png", 1)
    else
        boxIcon:loadTexture("globalImageUI6_itembg_2.png", 1)
    end
    boxIcon:setContentSize(89, 89)
    boxIcon:ignoreContentAdaptWithSize(false)
    bgNode.boxIcon = boxIcon
    bgNode:addChild(boxIcon,-1)
    
    --[[local iconColor = ccuiImageView:create()
    iconColor:setName("iconColor")
    iconColor:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    iconColor:ignoreContentAdaptWithSize(false)
    if inTable.quality then
        iconColor:loadTexture("globalImageUI4_squality"..inTable.quality..".png", 1)
    else
        iconColor:loadTexture("globalImageUI4_squality1.png", 1)
    end
    iconColor:setCascadeOpacityEnabled(true)
    iconColor:setContentSize(89, 89)
    bgNode.iconColor = iconColor
    bgNode:addChild(iconColor,6)--]]
    
    if inTable.amountStr then
        local nameLab = ccuiText:create()
        local nameStr = lang(inTable.tabConfig.name)
        if inTable.noAmountStr then
            nameLab:setString(nameStr)
            local tbSuitSplit = string.split(inTable.amountStr, "/")
            local suitType = tonumber(tbSuitSplit[2])
            local suitNumImg = ccuiImageView:create()
            suitNumImg:setName("suitNumImg")
            suitNumImg:loadTexture("teamHoly_suit"..suitType..".png", 1)
            suitNumImg:setPosition(cc.p(bgSize.width-suitNumImg:getContentSize().width/4, bgSize.height-suitNumImg:getContentSize().height/4))
            bgNode.suitNumImg = suitNumImg
            bgNode:addChild(suitNumImg)
        else
            nameLab:setString(nameStr.."("..inTable.amountStr..")")
        end
        nameLab:setName("nameLab")
        nameLab:setFontName(UIUtils.ttfName)
        nameLab:setFontSize(16)
        nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    --  numLab:setAnchorPoint(0.5, 0.5)
        nameLab:setPosition(bgSize.width/2+2, -15)
        bgNode.nameLab = nameLab
        bgNode:addChild(nameLab)
        
        registerClickEvent(bgNode, function()
            local tabData = ModelManager:getInstance():getModel("TeamModel"):getHolyTabBySuitIdAndQuality(inTable.tabConfig.id, inTable.quality)
            -- ViewManager:getInstance():showTip("Tips界面制作中~")
            local tbSuitSplit = string.split(inTable.amountStr, "/")
            local suitType = tonumber(tbSuitSplit[2])
            local desc = tabData["des"..suitType]
            ViewManager:getInstance():showHintView("global.GlobalTipView",
            {
                tipType = 25,
                node = bgNode,
                id = inTable.id,
                runeData = inTable,
                desc = lang(desc),
                posCenter = true,
            })
        end)
    end
    
    return bgNode
end


-- 创建符文宝石背包icon
function IconUtils:createHolyBagIcon(inTable)
    --[[if inTable == nil then
        inTable = {}
    end--]]
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(80, 80)

    local holyIcon = ccuiImageView:create()
    holyIcon:setName("holyIcon")
    holyIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    holyIcon:ignoreContentAdaptWithSize(false)
    holyIcon:setContentSize(78, 78)
    bgNode.holyIcon = holyIcon
    bgNode:addChild(holyIcon)

    local boxIcon = ccuiImageView:create()
    boxIcon:setName("boxIcon")
    boxIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    boxIcon:ignoreContentAdaptWithSize(false)
    boxIcon:setContentSize(80, 80)
    bgNode.boxIcon = boxIcon
    bgNode:addChild(boxIcon, -1)

    local iconColor = ccuiImageView:create()
    iconColor:setName("iconColor")
    iconColor:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    iconColor:setContentSize(80,80)
    iconColor:ignoreContentAdaptWithSize(false)
    bgNode.iconColor = iconColor
    bgNode:addChild(iconColor,1)

    local suoIcon = ccuiImageView:create()
    suoIcon:setName("suoIcon")
    suoIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    bgNode.suoIcon = suoIcon
    bgNode:addChild(suoIcon, 10)

    --[[local levelLab = ccLabel:createWithTTF("666", UIUtils.ttfName, 20)
    levelLab:setPosition(10, 10)
    levelLab:setAnchorPoint(0, 0)
    bgNode:addChild(levelLab,3)
    levelLab:enableOutline(ccc4b(60,30,10,255), 1)
    levelLab:setName("levelLab")
    levelLab:setColor(ccc3b(255,255,255))
    bgNode.levelLab = levelLab--]]
    
    
    local lvlImg = ccuiImageView:create()
    lvlImg:setName("lvlImg")
    bgNode.lvlImg = lvlImg
    bgNode:addChild(lvlImg, 10)
    
    local lvlLab = ccuiText:create()
    lvlLab:setFontName(UIUtils.ttfName)
    lvlLab:setFontSize(15)
    lvlLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    lvlImg.lvlLab = lvlLab
    lvlImg:addChild(lvlLab)

    self:updateHolyBagIcon(bgNode, inTable)
    return bgNode
end


-- 更新符文宝石背包icon
function IconUtils:updateHolyBagIcon(inView, inTable)
    inView.holyIcon:setVisible(inTable~=nil)
    if inTable == nil then
        inView.boxIcon:loadTexture("globalImageUI_quality0.png", 1)
        inView.iconColor:loadTexture("globalImageUI4_iquality0.png",1)
--      inView.levelLab:setString("")
        inView.lvlImg:setVisible(false)
        inView:setTouchEnabled(false)
        return 
    end

    local holyIcon = inView.holyIcon 

    if holyIcon == nil then 
        return
    end

    local suitData = inTable.suitData
    if not suitData then
        print("fffff")
    end
    holyIcon:loadTexture(suitData.art .. ".png",1)

    local boxIcon = inView.boxIcon -- inView:getChildByName("boxIcon")
    if boxIcon ~= nil then 
        local qulityName = "globalImageUI_quality0.png"
        boxIcon:loadTexture(qulityName,1)
    end

    -- local iconColor = inView:getChildByName("iconColor")
    local iconColor = inView.iconColor
    if iconColor then
        local quality = suitData.quality
        if quality then
            iconColor:loadTexture("globalImageUI4_squality" .. quality .. ".png",1)
        else
            iconColor:loadTexture("globalImageUI4_iquality0.png",1)
        end
    end
    
    local stoneData = inTable.stoneData
    if stoneData then
        local lvlImg = inView.lvlImg
        if lvlImg then
            lvlImg:loadTexture("globalImageUI4_iquality" .. stoneData.quality .. ".png", 1)
            lvlImg:setPosition(cc.p(lvlImg:getContentSize().width/2, inView:getContentSize().height - lvlImg:getContentSize().height/2))
            
            local lvlLab = lvlImg.lvlLab
            if lvlLab then
                lvlLab:setString("+"..stoneData.lv-1)
                lvlLab:setPosition(cc.p(lvlImg:getContentSize().width/2, lvlImg:getContentSize().height/2+2))
                lvlImg:setVisible(stoneData.lv>1)
            end
        end
    end
    --[[local levelLab = inView.levelLab
    if levelLab then
        if inTable.level then
            levelLab:setString("Lv." .. inTable.level)
        else
            levelLab:setString("")
        end
    end--]]

    -- 锁
    local suoIcon = inView.suoIcon 
    if suoIcon then
        suoIcon:loadTexture("globalImageUI5_treasureLock.png",1)
    end
    if inTable.suo == true then
        if suoIcon then
            suoIcon:setVisible(true)
        end
        if iconColor then
            iconColor:setSaturation(-100)
        end
        if holyIcon then
            holyIcon:setSaturation(-100)
        end
    else
        if suoIcon then
            suoIcon:setVisible(false)
        end
        if iconColor then
            iconColor:setSaturation(0)
        end
        if holyIcon then
            holyIcon:setSaturation(0)
        end
    end
    local downX, downY
    registerTouchEvent(inView, function (_, x, y)
            
        end,
        function(_, x, y)
            
        end, 
        function ()
            if inTable.callback then
                inTable.callback(inTable.suitData, inTable.stoneData, inView)
            end
        end,
        function ()
            
        end,
        function( )
            
        end)
    inView:setSwallowTouches(false)
end




function IconUtils:createGuildMapEquipment(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccuiWidget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(92, 92)
    bgNode:setCascadeOpacityEnabled(true)
    
    local itemIcon = ccuiImageView:create()
    itemIcon:setName("itemIcon")
    itemIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    itemIcon:ignoreContentAdaptWithSize(false)
    bgNode.itemIcon = itemIcon
    bgNode:addChild(itemIcon,1)

    local boxIcon = ccuiImageView:create()
    boxIcon:setName("boxIcon")
    boxIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    boxIcon:ignoreContentAdaptWithSize(false)
    bgNode.boxIcon = boxIcon
    bgNode:addChild(boxIcon,-1)

    local iconColor = ccuiImageView:create()
    iconColor:setName("iconColor")
    iconColor:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    iconColor:ignoreContentAdaptWithSize(false)
    iconColor:setCascadeOpacityEnabled(true)
    iconColor:setContentSize(92, 92)
    bgNode.iconColor = iconColor
    bgNode:addChild(iconColor,6)

    local numLab =  ccuiText:create()
    numLab:setString("")
    numLab:setName("numLab")
    numLab:setFontSize(20)
    numLab:setFontName(UIUtils.ttfName)
    numLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
    numLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    numLab:setAnchorPoint(1, 0)
    numLab:setPosition(bgNode:getContentSize().width - 10, 5)
    iconColor.numLab = numLab
    iconColor:addChild(numLab,11)
    
    self:updateGuildMapEquipment(bgNode, inTable)
    return bgNode
end

function IconUtils:updateGuildMapEquipment(bgNode, inTable)
    if inTable == nil or inTable.equipId == nil then
        return
    end
    local tabData = tab.guildEquipment[inTable.equipId]
    local itemIcon = bgNode.itemIcon
    itemIcon:loadTexture(tabData.art..".png", 1)
    itemIcon:setContentSize(89, 89)
    
    local boxIcon = bgNode.boxIcon
    boxIcon:loadTexture("globalImageUI6_itembg_1.png", 1)
    boxIcon:setContentSize(92, 92)
    
    local iconColor = bgNode.iconColor
    iconColor:loadTexture("globalImageUI4_squality1.png", 1)
    
    local numLab = iconColor.numLab
    numLab:setString(inTable.num)
    if not inTable.num or inTable.num==1 then
        numLab:setVisible(false)
    else
        numLab:setVisible(true)
    end
end

---法相Icon
function IconUtils:createShadowIcon(inTable)
    if inTable == nil then
        inTable = {}
    end
    local bgNode = ccui.Widget:create()
    bgNode:setContentSize(cc.size(92,92))
    bgNode:setAnchorPoint(cc.p(0,0))
    bgNode:setCascadeOpacityEnabled(true)

    local itemIcon = ccuiImageView:create()
    itemIcon:setName("itemIcon")
    itemIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    itemIcon:ignoreContentAdaptWithSize(false)
    itemIcon:setContentSize(89, 89)
    bgNode.itemIcon = itemIcon
    bgNode:addChild(itemIcon,2)

    local iconColor = ccuiImageView:create()
    iconColor:setName("iconColor")
    iconColor:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    iconColor:ignoreContentAdaptWithSize(false)
    iconColor:setCascadeOpacityEnabled(true)
    iconColor:setContentSize(92, 92)
    bgNode.iconColor = iconColor
    bgNode:addChild(iconColor,6)

    local nameLab = ccui.Text:create()
    nameLab:setFontSize(20)
    nameLab:setFontName(UIUtils.ttfName)
    nameLab:setName("nameLab")
    nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    nameLab:setPosition(bgNode:getContentSize().width*0.5,-15)
    iconColor.nameLab = nameLab
    iconColor:addChild(nameLab,11)


    local numLab =  ccuiText:create()
    numLab:setString("")
    numLab:setName("numLab")
    numLab:setFontSize(20)
    numLab:setFontName(UIUtils.ttfName)
    numLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
    numLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    numLab:setAnchorPoint(1, 0)
    numLab:setPosition(bgNode:getContentSize().width - 10, 5)
    iconColor.numLab = numLab
    iconColor:addChild(numLab,10)

    self:updateShadowIcon(bgNode, inTable)
    return bgNode
end

function IconUtils:updateShadowIcon(bgNode, inTable)
    if inTable == nil then
        return
    end
    local sfc = cc.SpriteFrameCache:getInstance()
    local art = inTable.itemData.icon
    if sfc:getSpriteFrameByName(art ..".jpg") then
        bgNode.itemIcon:loadTexture(art ..".jpg", 1)
    elseif sfc:getSpriteFrameByName(art ..".png") then
        bgNode.itemIcon:loadTexture(art ..".png", 1) 
    else
        print("头像资源是空...",art)
    end

    local quality = inTable.itemData.avaQuality and (inTable.itemData.avaQuality + 3) or 1
    bgNode.iconColor:loadTexture("globalImageUI4_squality" .. quality .. ".png",1) 


    bgNode.iconColor.nameLab:setVisible(false)
    if inTable.itemData.name then
        bgNode.iconColor.nameLab:setString(lang(inTable.itemData.name))
        bgNode.iconColor.nameLab:setVisible(true)
    end

    if inTable.count then
        bgNode.iconColor.numLab:setVisible(true)
        bgNode.iconColor.numLab:setString(inTable.count)
    else
        bgNode.iconColor.numLab:setVisible(false)
    end

    -- 部分地方只为展示icon 无任何事件
    if not inTable.eventStyle then inTable.eventStyle = 0 end
    if inTable.eventStyle ~= 0 and inTable.eventStyle <= 3 then
        bgNode:setTouchEnabled(true)
        bgNode:setSwallowTouches(true)
        local showView = nil
        local viewMgr = ViewManager:getInstance()
        local function endTouchEvent(inTempView)
            if inTable.eventStyle == 1 and 
                showView ~= nil then
            end
        end
        if inTable.eventStyle == 1 or inTable.eventStyle == 3 then
            bgNode:setScaleAnim(true)
            bgNode.iconColor:setScaleAnim(true)
            bgNode.itemIcon:setScaleAnim(true)
        end

        local downX, downY
        
        registerTouchEvent(bgNode, function (_, x, y)
            -- downCallback
            if inTable.eventStyle == 1 then
                downX = x
                downY = y
              
                showView = 1
                -- 展示view
            end
            -- 因为相应缩放事件需要锚点为0.5,0.5 bgNode本身是0,0 为了不去修改游戏内大量代码，
            --   将事件相应的缩放动画 直接应用于子节点。
            --   父节点其他动画效果与缩放action也可以隔离 stopallaction
            local ax, ay = bgNode:getAnchorPoint().x, bgNode:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonBeginAnim(bgNode.iconColor)              
                ButtonBeginAnim(bgNode.itemIcon)
            end

            if inTable.itemData and inTable.itemData.newTips then
                viewMgr:showTip("法相：" .. lang(inTable.itemData.name))
            end
            --
        end, function(_, x, y)
            -- moveCallback            
            if inTable.eventStyle == 1 then
                
            end
        end, 
        function ()
            -- upCallback
            endTouchEvent(bgNode)

            local ax, ay = bgNode:getAnchorPoint().x, bgNode:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonEndAnim(bgNode.iconColor)
                ButtonEndAnim(bgNode.itemIcon)
            end
        end,
        function ()       
            --outCallback
            endTouchEvent(bgNode)
            local ax, ay = bgNode:getAnchorPoint().x, bgNode:getAnchorPoint().y
            if ax ~= 0.5 or ay ~= 0.5 then
                ButtonEndAnim(bgNode.iconColor)
                ButtonEndAnim(bgNode.itemIcon)
            end
        end
        ,
        function( )
            -- longCallback
        end)
    end


end


function IconUtils:createAlchemyIcon(inTable)
	local bgNode = ccuiWidget:create()
--	bgNode:setAnchorPoint(0,0)
	bgNode:setContentSize(68, 68)

	local icon = ccuiImageView:create()
	icon:setName("icon")
	icon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
	icon:ignoreContentAdaptWithSize(false)
	icon:setContentSize(66, 66)
	bgNode.icon = icon
	bgNode:addChild(icon)

	local bgIcon = ccuiImageView:create()
	bgIcon:setName("bgIcon")
	bgIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
	bgIcon:ignoreContentAdaptWithSize(false)
	bgIcon:setContentSize(65, 65)
	bgNode.bgIcon = bgIcon
	bgNode:addChild(bgIcon, -1)

	local frameIcon = ccuiImageView:create()
	frameIcon:setName("frameIcon")
	frameIcon:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
	frameIcon:setContentSize(68,68)
	frameIcon:ignoreContentAdaptWithSize(false)
	bgNode.frameIcon = frameIcon
	bgNode:addChild(frameIcon,1)
	
	local tagIcon = ccuiImageView:create()
	tagIcon:setName("tagIcon")
	tagIcon:setPosition(cc.p(10, bgNode:getContentSize().height-11))
	bgNode.tagIcon = tagIcon
	bgNode:addChild(tagIcon, 2)

	--[[local levelLab = ccLabel:createWithTTF("666", UIUtils.ttfName, 20)
	levelLab:setPosition(10, 10)
	levelLab:setAnchorPoint(0, 0)
	bgNode:addChild(levelLab,3)
	levelLab:enableOutline(ccc4b(60,30,10,255), 1)
	levelLab:setName("levelLab")
	levelLab:setColor(ccc3b(255,255,255))
	bgNode.levelLab = levelLab

	local lvlLab = ccuiText:create()
	lvlLab:setFontName(UIUtils.ttfName)
	lvlLab:setFontSize(15)
	lvlLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	lvlImg.lvlLab = lvlLab
	lvlImg:addChild(lvlLab)--]]

	self:updateAlchemyIcon(bgNode, inTable)
	return bgNode
end

function IconUtils:updateAlchemyIcon(bgNode, inTable)
	local qualityImg = "globalImageUI4_squality1.png"
	local bgImg = "globalImageUI4_itemBg1.png"
	local tagImg = "alchemy_quality1.png"
	if inTable then
		qualityImg = "globalImageUI4_squality" .. inTable.planQuality .. ".png"
		bgImg = "globalImageUI6_itembg_"..inTable.planQuality..".png"
		tagImg = "alchemy_quality"..inTable.planQuality..".png"
	end
	
	local icon = bgNode:getChildByFullName("icon")
	if icon then
		if inTable then
			icon:setVisible(true)
			icon:loadTexture(inTable.icon, 1)
		else
			icon:setVisible(false)
		end
	end
	
	
	local bgIcon = bgNode:getChildByFullName("bgIcon")
	if bgIcon then
		bgIcon:loadTexture(bgImg, 1)
	end
	
	local frameIcon = bgNode:getChildByFullName("frameIcon")
	if frameIcon then
		frameIcon:loadTexture(qualityImg, 1)
	end
	
	local tagIcon = bgNode:getChildByFullName("tagIcon")
	if tagIcon then
		if inTable then
			tagIcon:setVisible(true)
			tagIcon:loadTexture(tagImg, 1)
		else
			tagIcon:setVisible(false)
		end
	end
end

-----------------------------------------------------------------------

function IconUtils.dtor()
    fu = nil
    headIconModelMap = nil
    NewFormationIconView = nil
    tc = nil
    TreasureColorMap = nil
    viewMgr = nil
    ccSprite = nil
    ccuiImageView = nil
    ccLabel = nil
    ccuiText = nil
    ccuiWidget = nil
    ccuiLayout = nil
    ccc3b = nil
    ccc4b = nil
    cc = nil
    ItemUtils = nil
end

-- 自适应父节点的大小
function IconUtils:adjustIconScale(parent, icon)
    if not parent or not icon  then return end
    local parentW = parent:getContentSize().width
    local parentH = parent:getContentSize().height
    
    local iconW = icon:getContentSize().width
    local iconH = icon:getContentSize().height

    local scaleX = 1
    if iconW > parentW then
        scaleX = parentW/iconW
    end 
    local scaleY = 1
    if iconH > parentH then
        scaleY = parentH/iconH
    end 
    icon:setScaleX(scaleX)
    icon:setScaleY(scaleY)    
end

return IconUtils
