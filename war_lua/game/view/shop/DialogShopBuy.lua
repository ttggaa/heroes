--[[
    Filename:    DialogShopBuy.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-10-09 17:22:54
    Description: File description
--]]
local DialogShopBuy = class("DialogShopBuy",BasePopView)
function DialogShopBuy:ctor()
    self.super.ctor(self)
    self._itemModel = self._modelMgr:getModel("ItemModel")
end

-- 第一次被加到父节点时候调用
function DialogShopBuy:onAdd()

end
-- 初始化UI后会调用, 有需要请覆盖
function DialogShopBuy:onInit()
    
    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("shop.DialogShopBuy")
    end)

    self:registerClickEventByName("closePanel", function ()
        self:close()
    end)

    self._title = self:getUI("bg.title_txt")
    -- self._title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._title:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._title,1)
    
    self._nameBg = self:getUI("bg.nameBg")    
    self._priceLab = self:getUI("bg.priceLab")	
    -- self._priceLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	self._itemNum = self:getUI("bg.itemNum")
    self._des2 = self:getUI("bg.des2")
    self._des3 = self:getUI("bg.des3")
    self._des4 = self:getUI("bg.des4")
    self._buyNum = self:getUI("bg.bugNum")
    -- self._buyNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

    self._itemNode = self:getUI("bg.itemNode")
    self._itemName = self:getUI("bg.itemName")
    self._itemDes = self:getUI("bg.itemDes")
    self._itemDes:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._itemName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    -- self._itemNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

    self._typeMap = {
        gold = {tipDes = "TIP_GLOBAL_LACK_GOLD",img = "",goto = function( )
            DialogUtils.showLackRes( {goalType = "gold",callback = function( selectIdx )
                if selectIdx == 3 and (self._shopBuyType =="intance") then
                    self._viewMgr:showTip("您已经在副本中")
                    return 
                end
            end})
        end},
        currency = {tipDes = "TIP_GLOBAL_LACK_CURRENCY",img = ""},
        gem = {tipDes = "TIP_GLOBAL_LACK_GEM",img = ""},
        crusading = {tipDes = "TIP_GLOBAL_LACK_CRUSADING",img = ""},
        treasureCoin = {tipDes = "BUY_TREASURE_FAIL",img = ""},
        guildCoin = {tipDes = "TIP_GUILD_SHOP",img = ""},
        leagueCoin = {tipDes = "LEAGUETIP_11" --[["LEAGUETIP_07"]],img = ""},
        hDuelCoin = {tipDes = "HERODUEL_SHOP" --[["LEAGUETIP_07"]],img = ""},
        fans = {tipDes = "GODWARSHOPTIPS_1" --[["LEAGUETIP_07"]],img = ""},
        souvenir = {tipDes = "GODWARSHOPTIPS_2" --[["LEAGUETIP_07"]],img = ""},
        cbCoin = {tipDes = "CITYBATTLE_SHOP_TIP_01" --[["LEAGUETIP_07"]],img = ""},
        expCoin = {tipDes = "EXPCOIN_INS" --[["LEAGUETIP_07"]],img = ""},
        planeCoin = {tipDes = "TIPS_AWARDS_05",img = ""},
        skillBookCoin = {tipDes = "SHOPSKILLBOOK_TIPS1",img = ""},
        friendCoin = {tipDes = "FRIEND_TEXT_TIPS_8",img = ""},
		cpCoin = {tipDes = "TIP_GLOBAL_LACK_CPCOIN", img = ""},
    }
    self._buyBtn = self:getUI("bg.btn1")
    self:registerClickEventByName("bg.btn1", function()
        self._buyBtn:setEnabled(false)
        if self._data.activityCallBack and "function" == type(self._data.activityCallBack) then
            self._data.activityCallBack()
            self:close()
            return 
        end
        if self._costType == "guildCoin" then
            local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
            if not guildId or guildId == 0 then
                self._viewMgr:returnMain()
                self._modelMgr:getModel("GuildModel"):setQuitAlliance(false)
                -- ViewManager:getInstance():showTip("您已被踢出联盟")
                return
            end
        end
        local isArenaFree = false
        if self._shopBuyType == "arena" and self._modelMgr:getModel("ShopModel"):isArenaShopFree() then
            isArenaFree = true
        end
        local canCostNum = self._modelMgr:getModel("UserModel"):getData()[self._data.costType] or 0
        self._canBuy = (canCostNum >= self._data.costNum) or isArenaFree
        if self._shopBuyType == "league" then
            if self._modelMgr:getModel("LeagueModel"):isMondayRest() then
                self._viewMgr:showTip("商店数据已刷新")
                self:close()
                return 
            end
        end
        if self._canBuy then
        	self:buyItem()
        else
            self._buyBtn:setEnabled(true)
            if self._costType == "gem" then
                local costName = lang("TOOL_" .. IconUtils.iconIdMap[self._costType])
                DialogUtils.showNeedCharge({desc = costName .. "不足，请前往充值",callback1=function( )
                    local viewMgr = ViewManager:getInstance()
                    viewMgr:showView("vip.VipView", {viewType = 0})
                end})
            elseif self._costType == "treasureCoin" then 
                local param = {indexId = 8}
                self._viewMgr:showDialog("global.GlobalPromptDialog", param)
            else 
                print("self._costType========",self._costType)
                dump(self._typeMap)
                if self._typeMap[self._costType]["goto"] then
                    self._typeMap[self._costType]["goto"]()
                else
                    local lackTipDes = lang(self._typeMap[self._costType]["tipDes"]) --"缺少足够的联赛币"
                    if not lackTipDes or lackTipDes == "" then
                        lackTipDes = self._typeMap[self._costType]["tipDes"]
                    end
                    self._viewMgr:showTip(lackTipDes or "")
                end
            end
        end
    end)
    self:listenReflash("ShopModel", function( )
        self:close()
    end)

    self:listenReflash("FriendRecallModel", function()
        self:close()
        end)

    self:listenReflash("UserModel", function( )
        if self._costType == "guildCoin" then
            local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
            if not guildId or guildId == 0 then
                self._viewMgr:returnMain()
                -- ViewManager:getInstance():showTip("您已被踢出联盟")
                self._modelMgr:getModel("GuildModel"):setQuitAlliance(false)
                return
            end
        end
    end)

end

-- 接收自定义消息
function DialogShopBuy:reflashUI(param)
    local data = param.shopData or param
    self._closeCallBack = param.closeCallBack
    -- dump(data)
    if data.award and data.award[1] then 
        self._awardData = data
        self._isAvatarFrame = data.award[1] == "avatarFrame"
    end
    local itemId = tonumber(data.itemId)
    if string.find(data.itemId,"leaguehero")  then
        local batchId = self._modelMgr:getModel("LeagueModel"):getData().batchId 
        local leagueActD = tab:LeagueAct(tonumber(batchId))
        itemId = leagueActD[data.itemId]
    end
    self._data = data
    self._shopBuyType = data.shopBuyType
    if itemId == 0 and self._shopBuyType then
        itemId = IconUtils.iconIdMap[self._shopBuyType]
    end
    if not itemId then
        itemId = IconUtils.iconIdMap[data.itemId]
    end
	self.awardId = data.pos or data.id
	if data.shopBuyType=="cp" then
		self.awardId = tonumber(data.grid[1])
	end
    self.itemId = tonumber(data.itemId) or data.itemId -- fix bug 积分联赛商店是id ，其他的是 格子位置
    self._costType = data.costType
    local toolD = tab:Tool(itemId)
	--加图标
    self._itemNode:removeAllChildren()
    local icon 
    -- print("===================itemType=========",self._isAvatarFrame)
    if self._isAvatarFrame then
        param = {itemId = itemId,itemData = toolD,eventStyle = 0}
        icon = IconUtils:createHeadFrameIconById(param)
    else
        icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,eventStyle = 0})
    end
    icon:setScaleAnim(true)
    icon:setAnchorPoint(0.5,0.5)
    icon:setPosition(50,50)
    self._itemNode:addChild(icon)
    -- print("=================itemId===",itemId)


    self._itemName:setString((lang(toolD.name) or "没有名字"))
    self._itemName:setColor(UIUtils.colorTable["ccColorQuality".. (ItemUtils.findResIconColor(itemId,data.num) or 1)])
    local bgWidth = self._itemName:getContentSize().width
    bgWidth = bgWidth + 100
    self._nameBg:setContentSize(bgWidth,self._nameBg:getContentSize().height)
    

    -- self._des3:setString("个消耗")
    self._buyNum:setString(ItemUtils.formatItemCount(data.num,"w"))
    self._buyNum:setPositionX(self._des3:getPositionX()-self._des3:getContentSize().width-self._buyNum:getContentSize().width/2)
    self._des4:setPositionX(self._buyNum:getPositionX()-self._buyNum:getContentSize().width/2)

    self._priceLab:setString(ItemUtils.formatItemCount(data.costNum) or "")
    local canCostNum = self._modelMgr:getModel("UserModel"):getData()[data.costType] or 0
    self._canBuy = (canCostNum >= data.costNum)
    local _,haveNum = self._itemModel:getItemsById(itemId)
    -- [[ 获得资源数量
    if haveNum == 0 then
        if itemId == 39978 then -- payGem 特殊处理 gem在model里整合了 payGem freeGem等
            haveNum = self._modelMgr:getModel("UserModel"):getData()["gem"]
        else
            for k,v in pairs(IconUtils.iconIdMap) do
                if v == itemId then
                    haveNum = self._modelMgr:getModel("UserModel"):getData()[k] or 0
                    break
                end
            end
        end
    end
    if itemId == 39977 or itemId == 39976 then -- 月卡特殊处理
        haveNum = 1 
    end
    if itemId == 39984 then -- arrowNum特殊处理
        haveNum = (haveNum + 1) / 111 
    end
    --]]
    print("haveNum",haveNum)

    local numTail = ""
    local desc = lang(toolD.des)

    local teamId = string.sub(itemId,2,string.len(itemId))
    local teamD = tab:Team(tonumber(teamId))
    if teamD and toolD.typeId == 1 then
        registerClickEvent(icon, function()
            -- iconType = 15   -- NewFormationIconView.kIconTypeLocalTeam = 15 本地数据兵团
            ViewManager:getInstance():showDialog("formation.NewFormationDescriptionView", { iconType = 15, iconId = tonumber(teamId)}, true)    
        end)
        local hadTeam = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(tonumber(teamId))
        if hadTeam and lang(toolD.des .. "_1") then
            desc = lang(toolD.des .. "_1")
        end
    end
    if toolD.typeId == 6 then
        local heroId = tonumber(string.sub(tostring(itemId),2,string.len(tostring(itemId))))
        heroD = tab:Hero(heroId)
        
        local heroData = self._modelMgr:getModel("HeroModel"):getHeroData(heroId)
        
        if heroData then
            desc = lang(toolD["adddes"]) or desc
            desc = string.gsub(desc,"%b{}",function( )
                if heroD.starcost and heroD.starcost[heroData.star] and heroD.starcost[heroData.star][1] and heroD.starcost[heroData.star][1][3] then
                    numTail =  "/" .. heroD.starcost[heroData.star][1][3]
                    return heroD.starcost[heroData.star][1][3]
                else
                    if heroD.starcost[heroData.star] then
                        numTail = "/" .. heroD.unlockcost[3]
                    end
                    return heroD.unlockcost[3]
                end
            end)
            if heroD then
                registerClickEvent(icon, function()
                    -- iconType = 15   -- NewFormationIconView.kIconTypeLocalTeam = 15 本地数据兵团
                    local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                    self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeHero, iconId = heroId}, true)
                end)
            end
        else  -- 没有英雄及零星
            numTail = "/" .. heroD.unlockcost[3]
            if heroD then
                registerClickEvent(icon, function()
                    -- iconType = 15   -- NewFormationIconView.kIconTypeLocalTeam = 15 本地数据兵团
                    local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                    self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = heroId}, true)
                end)
            end
        end
    end
    self._itemNum:setString((haveNum or "0") .. numTail)
    self._itemDes:setString(desc or "没有 描述")
    if self._itemDes:getVirtualRenderer():getStringNumLines() > 1 then  
        self._itemDes:setTextHorizontalAlignment(3)
    end
    
    local diamondImg = self:getUI("bg.diamondImg") 
    local scale = 32     
    if data.costType == "tool" then
        scale = 40
        local costTD = tab:Tool(data.costItemId)
        if costTD.art then
            local filename = IconUtils.iconPath .. costTD.art .. ".png"
            local sfc = cc.SpriteFrameCache:getInstance()
            if not sfc:getSpriteFrameByName(filename) then
                filename = IconUtils.iconPath .. costTD.art .. ".jpg"
            end
            diamondImg:loadTexture(filename, 1)
        end
    else
        diamondImg:loadTexture(IconUtils.resImgMap[self._costType],1)
    end
    local scaleNum = math.floor((scale/diamondImg:getContentSize().width)*100)
    diamondImg:setScale(scaleNum/100)
    --
    self._des2:setPositionX(self._itemNum:getPositionX()+self._itemNum:getContentSize().width+string.len(haveNum or 0)*1.2+1) 
    -- 传入购买回调
    self.buyCallback = data.callback

    local canCostNum = self._modelMgr:getModel("UserModel"):getData()[self._data.costType] or 0
    if data.costType == "tool" then
        local itemInfo,itemCount = self._modelMgr:getModel("ItemModel"):getItemsById(data.costItemId)
        canCostNum = itemCount
    end
    if (canCostNum >= self._data.costNum) then
        self._priceLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    else
        self._priceLab:setColor(cc.c3b(255, 23, 23))
    end
    if self._shopBuyType == "arena" and self._modelMgr:getModel("ShopModel"):isArenaShopFree() then
        self._priceLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        self._priceLab:setString("本次免费")
    end
end

function DialogShopBuy:buyItem()
    if self._shopBuyType == "intance" then 
        if self._data.intanceCallback ~= nil then 
            self._data.intanceCallback(self.itemId)
            self:close()
        end
        return 
    end
    self._serverMgr:sendMsg("ShopServer", "buyShopItem", {id = self.awardId,itemId = self.itemId,["type"] = self._shopBuyType}, true, {}, function(result)
        dump(result)
        audioMgr:playSound("consume")
        if self._closeCallBack then
            self._closeCallBack()
        end
        if result and result.reward and table.nums(result.reward) > 0 then
            -- if self._shopBuyType == "exp" then
                DialogUtils.showGiftGet({gifts = result.reward,notPop=true})
                return
            -- end
        end

        if self._awardData and self._awardData.award and (self._awardData.award[1] == "avatar" or self._awardData.award[1] == "avatarFrame") then
            local tempdata = {}
            tempdata[1] = self._awardData.award[1]
            tempdata[2] = self._awardData.award[2]   --self._awardData.itemId
            tempdata[3] = self._awardData.award[3]

            local giftD = {}
            table.insert(giftD,tempdata)
            local param = {gifts = giftD, callback = function()
                if self and self.close then
                    self:close()
                end
            end}
            DialogUtils.showAvatarFrameGet(param)
            return
        end
        if self._awardData and self._awardData.award and self._awardData.award[1] == "hSkin" then
            DialogUtils.showSkinGetDialog( {skinId = self._awardData.award[2]})
            return
        end

        if self then
            ViewManager:getInstance():showTip(lang("STORE_SYSTEM_BUY") or "购买成功！") 
            if self and self.close then
                self:close()
            end
        end
    end)
end

return DialogShopBuy