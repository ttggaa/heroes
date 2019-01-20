--[[
    Filename:    BagAutoUseDialog.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-07-30 14:39:47
    Description: File description
    --背包自动使用材料箱
    --点击加速开箱
--]]
local iconIdMap = IconUtils.iconIdMap

local transferText = {
    avatarFrame = lang("DIAMONDPRICE_4"),
    avatar = lang("DIAMONDPRICE_5"),
    hSkin = lang("DIAMONDPRICE_6"),
    heroShadow = lang("DIAMONDPRICE_7"),
    tSkin = lang("DIAMONDPRICE_6"),
}

local BagAutoUseDialog = class("BagAutoUseDialog",BasePopView)
function BagAutoUseDialog:ctor(data)
    self.super.ctor(self)
    self.callback = data.callback or nil
    self.addition = data.addition   --by wangyan 远征加成显示
    self._items = {} -- 物品图标列表
    self._heros = {} -- 英雄
    self._isFam = data.isFam
    self._newTreasures = {} -- 宝物
    self._avatarInfo = {}  -- 头像相关
    self._skinInfo = {}     -- 皮肤相关
    self._tSkinInfo = {}     -- 皮肤相关
    self._txPlusMap = {} -- qq 会员 超级会员 微信游戏中心加成
    self._txPlusIconMap = {} -- 记录加成图标
    self.bgName = "bg.bg1"
    self._transferStr = ""
    if data.btnTitle then
        self._btnTitle = data.btnTitle
    end
    -- self._hideView = data.hide
    -- 腾讯特权
    self._tencentPriModel = self._modelMgr:getModel("TencentPrivilegeModel")
end

function BagAutoUseDialog:onDestroy()
    if self._hideView then
        self._hideView:setVisible(true)
    end
    self.super.onDestroy(self)
end

function BagAutoUseDialog:getMaskOpacity()
    return 230
end

-- 初始化UI后会调用, 有需要请覆盖
function BagAutoUseDialog:onInit()
    -- self._scrollView = self:getUI("bg.scrollView")
    self._bg = self:getUI("bg")
    self._bg0 = self:getUI("bg.bg0")
    self._bg0:setVisible(false)
    self._bg1 = self:getUI("bg.bg1")
    self._bg1:setVisible(false)
    self._bg1:setSwallowTouches(false)

    self._bg1ScrollView = self:getUI("bg.bg1.scrollview")

    self._roleImg = self:getUI("bg.bg0.role_img")
    self._roleImg:loadTexture("asset/bg/global_reward_img.png")
    self._confirmBtn = self:getUI("confirmBtn")
    self._confirmBtn:setVisible(false)
    -- self._confirmBtn:setOpacity(0)

    -- self._scrollView:setClippingType(1)
    self.bgWidth,self.bgHeight = self._bg1:getContentSize().width,self._bg1:getContentSize().height
    self._closePanel = self:getUI("closePanel")
    self._closePanel:setSwallowTouches(false)
    self._bg1:setVisible(true)

    self._rewardPanel = self:getUI("bg.bg0.reward_panel")

    -- 动画相关
    self._itemNames = {}
    self._touchLab = self:getUI("bg.touchLab")
    self._touchLab:setVisible(true)
    self._touchLab:setOpacity(255)
    self._touchLab:setString("点击任意位置快速查看结果")

    self:getUI("bg.bg0.addPanel"):setVisible(false)
    
    if self._hideView then
        self._hideView:setVisible(false)
    end
end
function BagAutoUseDialog:animBegin(callback)
    audioMgr:playSound("ItemGain_1")
    local showXian 
    local bgW,bgH = self._bg1:getContentSize().width,self._bg1:getContentSize().height
    self:addPopViewTitleAnim(self._bg, "gongxihuode_huodetitleanim", 480, 480)
    ScheduleMgr:delayCall(400, self, function( )
        if callback and self._bg1 then
            callback()
        end
    end)
end

-- 接收自定义消息
function BagAutoUseDialog:reflashUI(data)
    -- dump(data,"...data...in BagAutoUseDialog:reflashUI")
    local gifts = data.gifts or data
    if gifts and #gifts == 0 then
        gifts = {}
        table.insert(gifts,data.gifts or data)
    end
    self._gifts = gifts
    -- dump(gifts,"gifts....guojun")
    -- -- 过滤英雄 头像框 头像 qq会员 信息
    for k,v in pairs(gifts) do
        if type(v) == "table" then
            if ((v[1] and v[1] == "hero") or (v.type and v.type == "hero") or  (v[1] and v[1] == "team") or (v.type and v.type == "team")) then
                table.insert(self._heros,v)
                gifts[k] = nil
                -- else-- 判断太长分段
                --     local heroId = tonumber(string.sub(tostring(v[2]),2,string.len(tostring(v[2]))))
                --     local isHeroSplice = tab:Hero(heroId)
                --     if isHeroSplice then
                --         table.insert(self._heros,v)
                --         gifts[k] = nil
                --     end
            elseif ((v[1] and v[1] == "avatarFrame") or (v.type and v.type == "avatarFrame")) then                
                table.insert(self._avatarInfo,gifts[k])
                self._haveNewAvatar = true   -- 有头像或者头像框
                gifts[k] = nil
            elseif ((v[1] and v[1] == "avatar") or (v.type and v.type == "avatar")) then
                local id = v.typeId or v[2]
                local avatarData = tab:RoleAvatar(id)
                if avatarData and avatarData.deblocking and 1 == avatarData.deblocking then
                    table.insert(self._avatarInfo,gifts[k])
                    self._haveNewAvatar = true   -- 有头像或者头像框
                end
                gifts[k] = nil
            elseif (v[1] and v[1] == "hSkin") or (v.type and v.type == "hSkin") then
                table.insert(self._skinInfo,gifts[k])
                self._haveNewSkin = true   -- 有皮肤
                gifts[k] = nil
            elseif (v[1] and v[1] == "tSkin") or (v.type and v.type == "tSkin") then
                table.insert(self._tSkinInfo,gifts[k])
                self._haveNewTeamSkin = true   -- 有皮肤
                gifts[k] = nil
            end
            -- 过滤出 qq会员和微信特权
            -- print("v.txPlus..?",v.txPlus)
            if v.txPlus then
                table.merge(self._txPlusMap,v.txPlus)
                -- dump(self._txPlusMap,"map.........")
                if type(v.txPlus) == "table" then
                    for k1,v1 in pairs(v.txPlus) do
                        self._txPlusIconMap[k1] = v
                    end
                end
                -- dump(self._txPlusIconMap)
                
            end
        end
    end
    self._gifts = {}
    for k,v in pairs(self._heros) do
        if type(v) == "table" then
            table.insert(self._gifts,v)
        end
    end
    for k,v in pairs(gifts) do
        if type(v) == "table" then
            table.insert(self._gifts,v)
        end
    end
    gifts = self._gifts
    -- gifts[#gifts + 1] = {["type"] = "heroshadow",["typeId"] = 1001,["num"] = 1}
    -- 英雄放到最后
    -- dump(gifts,"=======gifts======")

    local haveTreasure
    -- 如果有可批量使用的礼包进入背包，通知主界面 by guojun 2016.8.20
    for k,v in pairs(gifts) do
        local id = v.typeId or v[2]
        if id == 0 then
            id = IconUtils.iconIdMap[id]
        end 
        local giftData = tab.toolGift[id] or tab.equipmentBox[id]
        if giftData then
            self._modelMgr:getModel("MainViewModel"):reflashMainView()
            break
        end
        -- 遍历时增加判断是够有宝物
        local toolD = tab.tool[id]
        if toolD and toolD.typeId == 5 then
            haveTreasure = true
        end
    end
    local maxHeight = self._bg1:getContentSize().height
    -- 自适应关闭label
    self._touchLab:setPositionY(self._bg:getContentSize().height/2-maxHeight/2-30)
    --
    if haveTreasure then
        self:showTreasureNotOpen()
    end
    -- self._:removeAllChildren()
    local colMax = 5
    local itemHeight,itemWidth = 140,127
    local maxScrollHeight = itemHeight * math.ceil( #gifts / colMax)+5
    self._bg1ScrollView:setInnerContainerSize(cc.size(1136,maxScrollHeight))

    local x = 0
    local y = 0

    -- print("gifts===",#gifts)
    local offsetX,offsetY = 0,0
    local row = math.ceil( #gifts / colMax)
    local col = #gifts
    if col > colMax then
        col = colMax
    end

    offsetX = (self._bg1ScrollView:getContentSize().width-(col-1)*itemWidth)*0.5 -- (self.bgWidth-(col-1)*itemWidth)*0.5
    --    矫正 - (row - 2) * 15  2行 +15 2行不加
    offsetY = maxScrollHeight/2 + row*itemHeight/2 - itemHeight/2 + 30
    if row == 1 then
        offsetY = maxScrollHeight/2 + row*itemHeight/2 + 30
    end

    x = x+offsetX-itemWidth
    y = y+offsetY-5
    if data.vipPlus then
        y = y + 10
    end

    self:registerClickEventByName("bg", function()
        print("============快速展示结果===============")
        self._isAgain = true 
    end)

    local showItems
    showItems = function( idx )
        if not gifts[idx] then 
            -- vip双倍提示 -- 先做签到的加成
            if data.vipPlus and #gifts == 1 or next(self._txPlusMap) then
                self:addVipPlusDes(maxHeight,data.vipPlus)
            end
            -- pve扫荡提示
            if data.pveDes then
                self:addDespveDes(#gifts < 5,data.pveDes)
            end
            return 
        end
        -- for i=1,#gifts do
            x = x + itemWidth
            if  idx ~= 1 and (idx-1) % colMax == 0 then 
                x =  offsetX
                y = y - itemHeight
            end
            if not self._isAgain and idx > 10 and idx%5 == 1 then -- 多一行就 滚屏
                local offsetY = -(maxScrollHeight - 5 - 2*itemHeight)+(math.ceil((idx-10)/5))*itemHeight
                local container = self._bg1ScrollView:getInnerContainer()
                container:runAction(cc.Sequence:create(
                    cc.EaseOut:create(cc.MoveTo:create(0.2,cc.p(0,offsetY)),0.7),
                    cc.CallFunc:create(function( )
                        self:createItem(gifts[idx], x, y, idx,showItems)
                    end)
                ))
            else
                self:createItem(gifts[idx], x, y, idx,showItems)
            end
        -- end  
    end
    if self._isAgain then
        -- offsetY = offsetY + 15
        showItems(1)
    else
        local bg1Height = 200
        self._bg1:setOpacity(0)
        self._bg1:setContentSize(cc.size(self.bgWidth,bg1Height))
        self:animBegin(function( )
            self._bg1:setOpacity(255)
            local sizeSchedule
            local step = 0.5
            local stepConst = 30
            -- self._bg1:setAnchorPoint(0.5,1)
            -- self._bg1:setPositionY(self._bg1:getPositionY()+self._bg1:)
            sizeSchedule = ScheduleMgr:regSchedule(1,self,function( )
                stepConst = stepConst-step
                if stepConst < 1 then 
                    stepConst = 1
                end
                bg1Height = bg1Height+stepConst
                if bg1Height < maxHeight then
                    self._bg1:setContentSize(cc.size(self.bgWidth,bg1Height))
                else
                    self._bg1:setContentSize(cc.size(self.bgWidth,maxHeight))
                    self._bg1:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05,1,1.05),cc.ScaleTo:create(0.1,1,1)))
                    ScheduleMgr:unregSchedule(sizeSchedule)
                    self:addDecorateCorner()
                    if self._codeTitle then
                        self._codeTitle:setVisible(true)
                    end
                end
            end)
            -- ScheduleMgr:delayCall(200, self, function( )
            showItems(1)
            -- end)
        end)
    end
    if data.title then
        if self._title then
            self._title:setString(data.title or "")
        end
    end
    if data.title2 then
        local titleDes = data.title2
        if string.sub(titleDes,1,1) ~= "[" then
            titleDes = "[color=ffebbf]" .. titleDes .. "[-]"
        end
        local rtx = RichTextFactory:create(titleDes,1136,80)
        rtx:formatText()
        -- rtx:setAnchorPoint(cc.p(0,0.5))
        local w = rtx:getInnerSize().width
        local h = rtx:getInnerSize().height
        local posX = self._bg1:getContentSize().width/2
        local posY = 260
        rtx:setPosition(posX,posY)
        UIUtils:alignRichText(rtx,{hAlign = center})
        self._bg1:addChild(rtx,10)
        self._codeTitle = rtx
        self._codeTitle:setVisible(false)
    end
    local des = data.des or data.desc
    if des and self._title then
        -- local txt = ccui.Text:create()        
        -- txt:setString(des)
        if string.sub(des,1,1) ~= "[" then
            des = "[color=ebb45a]" .. des .. "[-]"
        end
        local rtx = RichTextFactory:create(des,500,80)
        rtx:formatText()
        rtx:setAnchorPoint(cc.p(0,0.5))
        local h = rtx:getInnerSize().height
        local posX = self._title:getPositionX() - 260
        local posY = self._rewardPanel:getPositionY()+self._rewardPanel:getContentSize().height + 20
        rtx:setPosition(posX,posY)
        -- UIUtils:alignRichText(rtx)
        self._bg0:addChild(rtx,10)
    end

    -- 底部家描述
    local bottomDes = data.bottomDes 
    if bottomDes then
        -- txt:setString(des)
        if string.sub(bottomDes,1,1) ~= "[" then
            bottomDes = "[color=ffebbf]" .. bottomDes .. "[-]"
        end
        local rtx = RichTextFactory:create(bottomDes,1136,80)
        rtx:formatText()
        -- rtx:setAnchorPoint(cc.p(0,0.5))
        local w = rtx:getInnerSize().width
        local h = rtx:getInnerSize().height
        local posX = self._bg1:getContentSize().width/2
        local posY = 40
        rtx:setPosition(posX,posY)
        UIUtils:alignRichText(rtx,{hAlign = center})
        self._bg1.__rtx = rtx
        self._bg1:addChild(rtx,10)
        rtx:setVisible(false)
        rtx:runAction(CCSequence:create(CCDelayTime:create(1),CCCallFunc:create(function()
            if self._bg1.__rtx then
                self._bg1.__rtx:setVisible(true)
            end
        end)))
    end

end

-- pve扫荡提示
function BagAutoUseDialog:addDespveDes(isAdd,pveDes)
    if not isAdd then return end
    
    if string.sub(pveDes,1,1) ~= "[" then
        pveDes = "[color=ffebbf]" .. pveDes .. "[-]"
    end
    local rtx = RichTextFactory:create(pveDes,1136,80)
    rtx:formatText()
    -- rtx:setAnchorPoint(cc.p(0,0.5))
    local w = rtx:getInnerSize().width
    local h = rtx:getInnerSize().height
    local posX = self._bg1:getContentSize().width/2
    local posY = 260
    rtx:setPosition(posX,posY)
    UIUtils:alignRichText(rtx,{hAlign = center})
    self._bg1:addChild(rtx,10)
end

function BagAutoUseDialog:createItem( data,x,y,index,nextFunc )
    local itemData
    local itemType = data[1] or data.type
    local itemId = data[2] or data.typeId 
    local itemNum = data[3] or data.num
    local isChange = data[4] or data.isChange
    local transfer = data.transfer
    if transfer then
        self._transferStr = self._transferStr .. transferText[transfer]
    end
    -- dump(data,"data i n createitem")
    if itemType ~= "tool" 
        and itemType ~= "hero" 
        and itemType ~= "team" 
        and itemType ~= "avatarFrame" 
        and itemType ~= "avatar" 
        and itemType ~= "hSkin" 
        and itemType ~= "siegeProp"
        and itemType ~= "rune"
        and itemType ~= "heroShadow"
        and itemType ~= "arrow" --add by wangyan
        and itemType ~= "tSkin"
    then
        itemId = iconIdMap[itemType]
    end
    
    if itemId == "leaguehero" then
        itemId = ModelManager:getInstance():getModel("LeagueModel"):changeLeagueHero2ItemId(itemId)
    end
    
    -- if data.isItem then
    itemData = tab.tool[itemId]
    if itemData == nil 
        and itemType ~= "avatarFrame" 
        and itemType ~= "avatar" 
        and itemType ~= "hSkin" 
        and itemType ~= "arrow"
        and itemType ~= "tSkin"
    then
        itemData = tab.team[itemId]
    end
    local item
    if itemType == "hero" then
        itemData = tab.hero[tonumber(itemId)]
        -- itemData.name = itemData.name or itemData.heroname
        item = IconUtils:createHeroIconById({sysHeroData = itemData})
        local starBg = item:getChildByName("starBg")
        if starBg then
            starBg:setVisible(false)
        end
        local iconStar = item:getChildByName("iconStar")
        if iconStar then
            iconStar:setVisible(false)
        end
        registerClickEvent(item, function()
            local NewFormationIconView = require "game.view.formation.NewFormationIconView"
            self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = itemId}, true)
        end)
    elseif itemType == "team" then
        local teamId  = itemId
        local teamD = tab.team[teamId]
        itemData = teamD
        item = IconUtils:createSysTeamIconById({sysTeamData = teamD})
        local iconColor = item:getChildByName("iconColor")
        -- iconColor:setSpriteFrame("globalImageUI_squality_jin.png")
        iconColor:loadTexture("globalImageUI_squality_jin.png",1)
        iconColor:setContentSize(cc.size(107, 107))
    elseif itemType == "siegeProp" then
        itemData = tab:SiegeEquip(itemId)
        local param = {itemId = itemId, level = 1, itemData = itemData, quality = itemData.quality, iconImg = itemData.art, eventStyle = 1}
        item = IconUtils:createWeaponsBagItemIcon(param)
    elseif itemType == "rune" then
        itemData = tab:Rune(itemId)
        item =IconUtils:createHolyIconById({suitData = itemData})
    elseif itemType == "heroShadow" then
        print("======itemId========"..itemId)
        itemData = clone(tab:HeroShadow(itemId))
        item = IconUtils:createShadowIcon({itemData = itemData,count = itemNum})
        item.iconColor.nameLab:setVisible(false)
    elseif itemType == "arrow" then
        item = IconUtils:createArrowBoxRewadById(data)
    elseif itemType == "battleSoul" then
		item = IconUtils:createItemIconById({itemId = itemId,num = itemNum, eventStyle = 0, battleSoulType = data[2] or data.typeId })
	else
        --todo
        item = IconUtils:createItemIconById({itemId = itemId,num = itemNum,itemData = itemData,effect = false })
        local isHadItemInTreasure = self._modelMgr:getModel("TreasureModel"):getTreasureById(itemId)
        local _,itemCount = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
        -- print("(isHadItemInBag>0 or isHadItemInTreasure)",(itemCount>1 or isHadItemInTreasure),"....",itemCount,  isHadItemInTreasure)
        if itemData and itemData.typeId == 5 and tab.disTreasure[itemId] and tab.disTreasure[itemId].produce == 1 and not (isHadItemInTreasure or itemCount > 1) then -- 宝物显示二次弹窗
            local tempdate = SystemUtils.loadAccountLocalData("hadTreasure_" .. itemId)
            if not tempdate then
                SystemUtils.saveAccountLocalData("hadTreasure_" .. itemId)
                if itemCount < 2 then
                    table.insert(self._newTreasures,data)
                end
            end
        end
        --获得界钻石icon加底光特效
        --gem = 39992, payGem = 39978,
        -- print("==========================itemId============",itemId,IconUtils.iconIdMap.gem,IconUtils.iconIdMap.payGem)
        if itemId == IconUtils.iconIdMap.gem or itemId == IconUtils.iconIdMap.payGem then
             local mc = mcMgr:createViewMC("huodewupindiguang_itemeffectcollection", true, false, function (_, sender)
                sender:gotoAndPlay(0)
            end,RGBA8888) 
            mc:setPosition(item:getContentSize().width*0.5,item:getContentSize().height*0.5)      
            mc:setScale(1.1)
            mc:setName("itemMc")
            mc:setVisible(false)
            item:addChild(mc,-5) 
        end
        
    end
    -- item:setScale()
    table.insert(self._items,item)
    item:setSwallowTouches(true)
    item:setScale(0.85)
    item:setScaleAnim(false)
    item:setAnchorPoint(0,0)
    if #self._gifts>1 then
        item:setPosition(x,y)
    else
        item:setPosition(self._isFam and self._rewardPanel:getContentSize().width/4+x or x,y)
    end
    item:setVisible(true)
    local itemNormalScale = .9 --80/item:getContentSize().width
    if itemData and (itemData.name or itemData.heroname) then
        local itemName = ccui.Text:create()
        itemName:setFontName(UIUtils.ttfName)
        itemName:setTextAreaSize(cc.size(100,65))
        -- itemName:ignoreContentAdaptWithSize(false)
        -- itemName:setContentSize(cc.size(50,100))
        itemName:setTextHorizontalAlignment(1)
        itemName:setTextVerticalAlignment(0)
        itemName:setString(lang(tostring(itemData.name or itemData.heroname)))
        itemName:setFontSize(20)
        itemName:getVirtualRenderer():setLineHeight(20)
        local color = 1
        if itemType=="rune" then
            color = itemData.quality
        else
            color = ItemUtils.findResIconColor(itemId,itemNum)
        end
        itemName:setColor(UIUtils.colorTable["ccColorQuality" .. (color or 1)])
        itemName:setFontName(UIUtils.ttfName)        
        -- itemName:getVirtualRenderer():setLineHeight(100.0)
        -- itemName:enableOutline(cc.c4b(0,0,0,255),2)
        itemName:setAnchorPoint(0.5,1)
        itemName:setPosition(item:getContentSize().width/2,0)
        itemName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        item:addChild(itemName)
        itemName:setVisible(false)
        table.insert(self._itemNames,itemName)
    end

    item:setAnchorPoint(0.5,0.5)
    self._bg1ScrollView:addChild(item)

    item:setOpacity(0)
    local children = item:getChildren()
    for k,v in pairs(children) do
        if v:getName() == "numLab" then
            v:setVisible(false)
        else
            v:setOpacity(0)
        end
        if v.setSwallowTouches then
            v:setSwallowTouches(true)
        end
    end
    local iconColor = item:getChildByFullName("iconColor")
    local bgMc
    if iconColor then
        bgMc= iconColor:getChildByName("bgMc")
    end
    if bgMc then
        bgMc:setVisible(false)
    end
    local boxIcon = item:getChildByFullName("boxIcon")
    local diguangMc
    if boxIcon then
        diguangMc = boxIcon:getChildByFullName("diguangMc")
    end
    if diguangMc then
        diguangMc:setVisible(false)
    end
    local delayT = 120
    if self._isAgain then 
        delayT = 0
    end                        
    ScheduleMgr:delayCall(delayT, self, function( )--index*

        audioMgr:playSound("ItemGain_2")
        -- if bgMc then
        --     bgMc:setVisible(true)
        -- end
        if not self._isAgain then
            item:setScale(2)
            if index == #self._gifts then
                item:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeIn:create(0.1),cc.ScaleTo:create(0.1,itemNormalScale*0.6)),cc.ScaleTo:create(0.1,itemNormalScale),cc.CallFunc:create(function( )
                    local mc = item:getChildByFullName("itemMc")
                    if mc then
                        mc:setVisible(true)
                    end
                    for k,v in pairs(self._itemNames) do
                        v:setVisible(true)
                    end
                    local boxIcon = item:getChildByFullName("boxIcon")
                    local diguangMc
                    if boxIcon then
                        diguangMc = boxIcon:getChildByFullName("diguangMc")
                    end
                    if diguangMc then
                        diguangMc:setVisible(true)
                    end
                    local iconColor = item:getChildByFullName("iconColor")
                    local bgMc
                    if iconColor then
                        bgMc= iconColor:getChildByName("bgMc")
                    end
                    if bgMc then
                        bgMc:setVisible(true)
                    end
                end)))
            else
                item:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeIn:create(0.1),cc.ScaleTo:create(0.1,itemNormalScale*0.6)),
                                cc.ScaleTo:create(0.1,itemNormalScale),
                                cc.CallFunc:create(function()
                                    local mc = item:getChildByFullName("itemMc")
                                    if mc then
                                        mc:setVisible(true)
                                    end
                                    local boxIcon = item:getChildByFullName("boxIcon")
                                    local diguangMc = boxIcon and boxIcon:getChildByFullName("diguangMc")
                                    if diguangMc then
                                        diguangMc:setVisible(true)
                                    end
                                    local iconColor = item:getChildByFullName("iconColor")
                                    local bgMc
                                    if iconColor then
                                        bgMc= iconColor:getChildByName("bgMc")
                                    end
                                    if bgMc then
                                        bgMc:setVisible(true)
                                    end

                                end)))
            end
        else
            item:setScale(itemNormalScale)
            item:setScaleAnim(true)
            item:setOpacity(255)
        end
        
            
        local children = item:getChildren()
        for k,v in pairs(children) do
                -- print("v:getName",v:getName() ~= "bgMc",v:getName())
            if v:getName() == "numLab" then
                v:setVisible(true)
            end
            if v:getName() ~= "bgMc" then
                v:runAction(cc.FadeIn:create(0.1))--cc.Spawn:create(cc.FadeIn:create(0.1),cc.ScaleTo:create(0.1,1)))
            end
        end
        if index == #self._gifts then

            local setCanCloseFunc = function ()
                -- print("====================可以关闭当前界面==============")
                    self._touchLab:runAction(cc.FadeOut:create(0.1))                
                    -- self._confirmBtn:runAction(cc.FadeIn:create(0.1))   
                    local hadClose

                    self:registerClickEventByName("closePanel", function()
                        if not hadClose then
                            hadClose = true
                            self:closeFunc()
                        end
                    end)
                    
                    self:registerClickEventByName("bg.bg1.scrollview.scrollInnerClose", function()
                        if not hadClose then
                            hadClose = true
                            self:closeFunc()
                        end
                    end)

                    self:registerClickEventByName("bg.bg1", function()
                        if not hadClose then
                            hadClose = true
                            self:closeFunc()
                        end
                    end)

                    self:registerClickEventByName("bg", function()
                        if not hadClose then
                            hadClose = true
                            self:closeFunc()
                        end
                    end)

                    -- 设置 scaleAnim
                    self:processItemsAfterAction() 
                    -- self:registerClickEventByName("confirmBtn", function()
                    --     if not hadClose then
                    --         hadClose = true
                    --         if self.callback and type(self.callback) == "function" then
                    --             self.callback()
                    --         end
                    --         self:close(true)
                    --     end
                    -- end)
            end
            -- 添加转换提示
            if self._transferStr ~= "" then
                local desTxt = ccui.Text:create()
                -- print("=================_transferStr======",self._transferStr)
                desTxt:setString(self._transferStr)
                desTxt:setFontSize(22)
                desTxt:setFontName(UIUtils.ttfName)
                desTxt:setColor(UIUtils.colorTable.ccUIBasePromptColor)
                desTxt:setPosition(self._bg1:getContentSize().width/2,40)
                self._bg1:addChild(desTxt,3)
                desTxt:setOpacity(0)
                desTxt:runAction(cc.FadeIn:create(0.1))
            end
            ScheduleMgr:delayCall(300, self, function( )
                setCanCloseFunc()
            end)
        end
        if itemType == "hero" then
            local heroView = self._viewMgr:createLayer("hero.HeroUnlockView", {heroId = itemId, callBack = function() 
                nextFunc(index+1)
            end})
            self:addChild(heroView,999)
        elseif itemType == "team" then
            local teamId  = itemId
            DialogUtils.showTeam({teamId = teamId,callback = function (  )
                nextFunc(index+1)
            end})
        
        elseif isChange and isChange == 1 and tab.team[tonumber(string.sub(itemId,2,string.len(itemId)))] then
            DialogUtils.showCard({itemId = itemId,changeNum= itemNum ,callback = function (  )
                nextFunc(index+1)
            end})
        else
            local isDis = tab.disTreasure[itemId] and tab.disTreasure[itemId].produce == 2
            -- local isHadItemInTreasure = self._modelMgr:getModel("TreasureModel"):getTreasureById(itemId)
            -- local _,itemCount = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
            local isOTreasure = isDis --and not isHadItemInTreasure and itemCount < 2
            if isOTreasure and itemType == "tool" then
                self._viewMgr:showDialog("global.GlobalShowTreasureDialog", {itemId = itemId, callback = function() 
                    nextFunc(index+1)
                end})
            else
                nextFunc(index+1)
            end
        end
    end)
    -- local toShow 
end

-- 处理关闭事件 因为关闭时有其他判断 所以重新封装
function BagAutoUseDialog:closeFunc( )
    if self._hideView then
        self._hideView:setVisible(true)
    end
    local callback = self.callback
    local treasures = self._newTreasures       
    if treasures and next(treasures) then
        ViewManager:getInstance():showDialog("global.GlobalNewTreasureGetDialog",{gifts=treasures,callback=callback})
    else
        if callback and type(callback) == "function" then
            callback()
        end 
    end
    -- 关闭恭喜获得然后关闭头像框
    if self._haveNewAvatar then
        local param = {gifts = self._avatarInfo,callBack=function()
            -- setCanCloseFunc()
        end}
        DialogUtils.showAvatarFrameGet(param)    
    end

    if self._haveNewSkin then 
        local skinItemID = self._skinInfo[1].typeId or self._skinInfo[1][2]
        DialogUtils.showSkinGetDialog({skinId = skinItemID})
    end
    if self._haveNewTeamSkin then 
        local skinItemID = self._skinInfo[1].typeId or self._skinInfo[1][2]
        DialogUtils.showTeamSkinGetDialog({skinId = skinItemID})
    end

    if self.close then                       
        self:close(true)
    end
    UIUtils:reloadLuaFile("bag.BagAutoUseDialog")
end

-- 设置 scaleAnim
function BagAutoUseDialog:processItemsAfterAction( )
    for k,v in pairs(self._items) do
        v:setScaleAnim(true)
    end
end

-- 额外的板子
-- 判断获得物品里是否有宝物 且 宝物系统未开放
function BagAutoUseDialog:showTreasureNotOpen( )
    -- 宝物开启返回
    local isTreasureOpen, _, openLvl = SystemUtils["enableTreasure"]()
    local bgNode = self._bg1:getChildByName("treasureOpenDes")
    if isTreasureOpen then
        if bgNode then
            bgNode:setVisible(false)
        end
        return 
    end
    if not bgNode then
        self._touchLab:setPositionY(60)
        bgNode = ccui.Widget:create()
        bgNode:setName("treasureOpenDes")
        bgNode:setPosition(self._bg1:getContentSize().width/2,30)
        self._bg1:addChild(bgNode)

        local bgPic = ccui.ImageView:create()
        bgPic:loadTexture("globalImage6_titleBg2.png",1)
        bgPic:setScale9Enabled(true)
        bgPic:setColor(cc.c4b(128, 128, 128,128))
        bgPic:setCapInsets(cc.rect(40,15,1,1))
        bgPic:setContentSize(cc.size(420,30))
        bgPic:setPosition(cc.p(0,-80))
        bgNode:addChild(bgPic,-1)

        local openDesLab = ccui.Text:create()
        openDesLab:setFontSize(20)
        openDesLab:setFontName(UIUtils.ttfName)
        openDesLab:setAnchorPoint(0.5,0.5)
        openDesLab:setColor(cc.c3b(250, 230, 200))
        openDesLab:setString("宝物系统将在" .. (openLvl or 25) .. "级开放")
        openDesLab:setPosition(cc.p(0,-80))
        bgNode:addChild(openDesLab)
    else
        bgNode:setVisible(true)
    end
end


-- 显示vip签到双(?若干)倍等
-- 对应图片map
local vipImgMap = { 
    wx_gamecenter = "tencentIcon_wxHead.png",
    sq_gamecenter = "tencentIcon_qq.png",
    is_qq_vip     = "tencentIcon_qqVip.png",
    is_qq_svip    = "tencentIcon_qqSVip.png",
    z_vip_doubble   = "txt_vip_battle.png", -- z开头保证排序
}

local vipDesMap = {
    is_qq_svip = "QQ超级会员专享加成",
    is_qq_vip  = "QQ会员专享加成"
}
function BagAutoUseDialog:addVipPlusDes( maxHeight,vipPlus )
    self._touchLab:setPositionY(self._bg:getContentSize().height/2-maxHeight/2-30-40)
    local bgNode = ccui.Widget:create()
    bgNode:setPosition(self._bg1:getContentSize().width/2,-30)
    self._bg1:addChild(bgNode)

    -- vip  s双倍
    local plusMap = {}
    table.merge(plusMap,self._txPlusMap)
    if vipPlus then
        plusMap["z_vip_doubble"] = vipPlus 
    end
    -- dump(plusMap,"plusMap....")
    local cellWidth = 160
    local offsetX = 20
    local bgWidth = math.max(table.nums(plusMap)*cellWidth+offsetX*2,420)
    local bgPic = ccui.ImageView:create()
    bgPic:loadTexture("globalImage6_titleBg2.png",1)
    bgPic:setScale9Enabled(true)
    bgPic:setColor(cc.c4b(128, 128, 128,128))
    bgPic:setCapInsets(cc.rect(40,15,1,1))
    bgPic:setContentSize(cc.size(bgWidth,30))
    bgNode:addChild(bgPic,-1)

    
    
    local count = 0
    local lastWidth = 0
    local plusNodes = {}
    local allCellWidth = table.nums(plusMap)*cellWidth 
    offsetX = offsetX + (bgWidth-allCellWidth)/2
    for k,num in pairs(plusMap) do
        -- print(k,num,#plusMap)
        local vipImgName = vipImgMap[k]
        local vipDes = table.nums(plusMap) == 1 and vipDesMap[k]
        local awardData = self._txPlusIconMap[k] or self._gifts[1] 
        -- 
        local iconType = awardData[1] or awardData.type
        local iconId = awardData[2] or awardData.typeId
        local iconPicName = ""
        if iconType == "tool" then
            iconPicName = tab.tool[iconId].art
        else
            iconPicName = tab.tool[IconUtils.iconIdMap[iconType]].art
        end   
        local filename = iconPicName .. ".png"
        local sfc = cc.SpriteFrameCache:getInstance()
        if not sfc:getSpriteFrameByName(filename) then
            filename = iconPicName .. ".jpg"
        end
        -- 
        local plusNode,width = self:createPlusItem( vipImgName,filename,num,vipDes )
        -- plusNode:setPosition(count*cellWidth-bgWidth*0.5+offsetX+5,0)
        bgNode:addChild(plusNode)
        count = count+1
        lastWidth = width
        table.insert(plusNodes,plusNode)
    end

    -- local resetOffsetX = (cellWidth-lastWidth-10)*0.5
    -- for i,v in ipairs(plusNodes) do
    --     v:setPositionX(v:getPositionX()+resetOffsetX)
    -- end
    UIUtils:alignNodesToPos(plusNodes,0,20)
end

function BagAutoUseDialog:createPlusItem( vipImgName,resImgName,num,vipDes )
    local bgNode = ccui.Widget:create()
    local alignNodes = {}
    local vipPic = ccui.ImageView:create()
    vipPic:setAnchorPoint(cc.p(0,0.5))
    vipPic:loadTexture(vipImgName,1)
    vipPic:setPositionY(15)
    -- vipPic:setScale(20/vipPic:getContentSize().height)
    bgNode:addChild(vipPic)
    table.insert(alignNodes,vipPic)

    if vipDes then
        local vipDesLab = ccui.Text:create()
        vipDesLab:setFontSize(20)
        vipDesLab:setFontName(UIUtils.ttfName)
        vipDesLab:setAnchorPoint(0,0.5)
        vipDesLab:setString(vipDes)
        vipDesLab:setPositionY(15)
        bgNode:addChild(vipDesLab)
        table.insert(alignNodes,vipDesLab)
    end

    local iconPic = ccui.ImageView:create()
    iconPic:loadTexture(resImgName ,1)
    iconPic:setAnchorPoint(0,0.5)
    iconPic:setPositionY(15)
    iconPic:setScale(30/iconPic:getContentSize().height)
    bgNode:addChild(iconPic)
    table.insert(alignNodes,iconPic)

    local addLab = ccui.Text:create()
    addLab:setFontSize(20)
    addLab:setFontName(UIUtils.ttfName)
    addLab:setAnchorPoint(0,0.5)
    addLab:setPositionY(15)
    addLab:setString("x" .. num)
    bgNode:addChild(addLab)
    table.insert(alignNodes,addLab)

    local width = UIUtils:sumNodesWidth(alignNodes,2)
    bgNode:setContentSize(cc.size(width,30))
    UIUtils:alignNodesToPos(alignNodes,width/2,2)
    return bgNode,width
end

return BagAutoUseDialog