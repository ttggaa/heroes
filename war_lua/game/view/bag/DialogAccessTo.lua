--[[
    Filename:    DialogAccessTo.lua
    Author:      <libolong@playcrab.com>
    Datetime:    2015-05-28 19:54:34
    Description: File description
--]]

local DialogAccessTo = class("DialogAccessTo", BasePopView)

function DialogAccessTo:ctor(data)
    DialogAccessTo.super.ctor(self)
    self._itemData = data
    self._toolData = clone(tab:Tool(data.goodsId))
    self._callback = data.callback

    self._picMap = {}
end

function DialogAccessTo:onDestroy()
    local tc = cc.Director:getInstance():getTextureCache()
    for tex, _ in pairs(self._picMap) do
        tc:removeTextureForKey(tex)
    end
    DialogAccessTo.super.onDestroy(self)
end

function DialogAccessTo:onInit()
    self._scrollItem = self:getUI("bg.scrollItem")
    self._scrollItem.notUse = true
    self._scrollItem:setVisible(false)
    self._closeBtn = self:getUI("bg.closeBtn")
    self._scrollView = self:getUI("bg.scrollView")
    self._noneDes = self:getUI("bg.noneIcon.noneDes")
    self._noneIcon = self:getUI("bg.noneIcon")
    -- self._noneDes:enableOutline(cc.c4b(106,72,42,255),0)
    
    self:registerClickEvent(self._closeBtn, function ()
        if self._callback then
            self._callback()
        end
        self:close()
        UIUtils:reloadLuaFile("bag.DialogAccessTo")
    end)

    -- 设置title
    self._title = self:getUI("bg.headBg.title")
    -- self._title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._title:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._title,1)
    -- 添加icon
    local itemIcon = IconUtils:createItemIconById({itemId = self._itemData.goodsId,itemData = self._toolData,eventStyle = 0,effect = true})
    itemIcon:setName("itemIcon")
    itemIcon:setContentSize(cc.size(80,80))
    self._itemNode = self:getUI("bg.itemNode")
    self._itemNode:addChild(itemIcon)
    -- 物品名字
    self._itemName = self:getUI("bg.itemName")
    if OS_IS_WINDOWS then
        self._itemName:setString(lang(self._toolData.name) .. " [" .. self._toolData.id .. "]")
    else
        self._itemName:setString(lang(self._toolData.name))
    end
    self._itemName:setColor(UIUtils.colorTable["ccUIBaseColor" .. self._toolData.color] or UIUtils.colorTable["ccUIBaseColor1"])
    -- self._itemName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    UIUtils:setTitleFormat(self._itemName,2)
    self._itemBg = self:getUI("bg.itemBg")
    self._itemBg:setVisible(false)
    self._itemBg:setContentSize(cc.size(self._itemName:getContentSize().width+125,32))
    -- 数量
    self._itemNum = self:getUI("bg.itemNum")
    -- self._itemNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._itemCountDes = self:getUI("bg.itemCountDes")
    
    self:listenReflash("ItemModel",self.reflashUI)
    self:listenReflash("IntanceModel",self.reflashUI)
    self:listenReflash("IntanceEliteModel",self.reflashUI)
end

--[[
--! @function createApproatchCell
--! @desc 创建道具列表的cell
--! @param data table 数据表
--! @param x int 坐标x
--! @param y int 坐标y
--! @return 
--]]

function DialogAccessTo:createApproatchCell(data, x, y, index)
    local item
    -- if self._scrollItem.notUse then
    --     self._scrollItem.notUse = false
    --     item = self._scrollItem
    --     -- item:setPosition(cc.p(x,y))
    --     self._scrollItem:retain()
    --     self._scrollItem:removeFromParent()
    --     self._scrollView:addChild(item)
    --     self._scrollItem:release()
    -- else
    item = self._scrollItem:clone()
    item:setVisible(true)
    item:setName(index)
    item:setAnchorPoint(0.5,0.5)
    item:setScaleAnim(true)
    item.__scaleMin = 0.95
    self._scrollView:addChild(item)
    -- end
    item:setPosition(x+200,y+40)
    local lvType = data[1]
    local lvSectionId = data[2]
    local lvBaseId = data[3]
    local bgName = "asset/accessto/ia_".. (data[4] or 15) ..".png"
    self._picMap[bgName] = 1
    -- 添加副本显示图片
    -- local sp = ccui.ImageView:create()
    -- sp:loadTexture(data.art,1)
    -- item:getChildByFullName("iconNode"):addChild(sp)
        
    local typeTitleColors = {
        cc.c4b(46, 185, 237, 255),
        cc.c4b(251, 149, 48, 255),
        cc.c4b(237, 46, 226, 255),
        cc.c4b(237, 46, 226, 255),
        cc.c4b(46, 185, 237, 255),
        cc.c4b(251, 149, 48, 255),
        cc.c4b(251, 149, 48, 255),
        cc.c4b(251, 149, 48, 255),
        cc.c4b(237, 46, 226, 255),
        cc.c4b(251, 149, 48, 255),
        cc.c4b(251, 149, 48, 255),
    }
    local bg = cc.Sprite:create(bgName)
    bg:setPosition(item:getContentSize().width * 0.5 + 3, item:getContentSize().height * 0.5)
    item:addChild(bg, -1)
    local accessType =  item:getChildByFullName("accessType")
    accessType:enableOutline(cc.c4b(55,42,27,255),2)
    local restLabel = item:getChildByFullName("restLabel")
    local lock = item:getChildByFullName("lock") 
    restLabel:enableOutline(cc.c4b(55,42,27,255),2)

    if lvType <= 2 -- 副本类型 显示两行
        or (lvType == 5 and lvSectionId == 2) 
        or (lvType == 6 and (lvSectionId == 2 or lvSectionId == 3)) 
        or lvType == 13 -- 云中城
        then
        
        restLabel:setVisible(true)
    else
        -- 其它类型 显示一行
        accessType:setPositionY(41)
        restLabel:setVisible(false)
    end
    if lvType <= 2 then
        local mainStageD = clone(tab:MainStage(lvBaseId))
        if mainStageD then
            local sectionName = lang(mainStageD.title) --lang(string.gsub("SECTIONTITLE_name","name",string.sub(tostring(lvBaseId),1,5)) )
            if sectionName then
                restLabel:setString(sectionName or "SECTIONTITLE_" .. lvBaseId)
            end
        end
    end
    local baoxiangFubenId = 0
    local needNum = 0
    local stageInfo = {}
    local shopInfo = {}
    --跳转到关卡
    local goFunc = function( )
        if lvType == 1 then
            self._viewMgr:showView("intance.IntanceView", {sectionId= lvSectionId, quickStageId = lvBaseId,itemId = self._itemData.goodsId,needItemNum = self._itemData.needItemNum})
            if self._callback then
                self._callback()
            end
            self:close()
        elseif lvType == 2 then
            if not SystemUtils:enableElite() then
                self._viewMgr:showTip(lang("TIP_JINGYING_1"))
                return 
            end
            self._viewMgr:showView("intance.IntanceEliteView", {sectionId= lvSectionId, quickStageId = lvBaseId,itemId = self._itemData.goodsId,needItemNum = self._itemData.needItemNum})
        elseif lvType == 3 then
            -- 各种商店

            local shopIdx = lvSectionId
            if lvSectionId ~= 6 then
                -- 商店
                local isOpen = false
                if lvSectionId == 1 then
                    isOpen = SystemUtils["enableMysteryShop"]()
                elseif lvSectionId == 2 then
                    isOpen = SystemUtils["enableArena"]()
                elseif lvSectionId == 3 then
                    isOpen = SystemUtils["enableCrusade"]() 
                elseif lvSectionId == 4 then
                    isOpen = SystemUtils["enableTreasure"]()
                elseif lvSectionId == 5 then 
                    isOpen = SystemUtils["enableGuildShop"]() and self._modelMgr:getModel("UserModel"):getIdGuildOpen()
                    if not isOpen and SystemUtils["enableGuildShop"]() then
                        self._viewMgr:showTip("请先加入联盟")
                        return 
                    end
                elseif lvSectionId == 7 then
                    isOpen = SystemUtils["enableTreasure"]()
                elseif lvSectionId == 8 then
                    isOpen = self._modelMgr:getModel("CityBattleModel"):checkIsGvgOpen()
                elseif lvSectionId == 9 then
                    isOpen = SystemUtils["enableElementShop"]()
                elseif lvSectionId == 10 then
                    isOpen = SystemUtils["enableSkillBook"]()
                elseif lvSectionId == 11 then
                    isOpen = SystemUtils["enableCrossPK"]()
                elseif lvSectionId == 12 then
                    isOpen = SystemUtils["enableHoly"]()
                elseif lvSectionId == 13 then
                    shopIdx = 10
                    isOpen = SystemUtils["enableCrossGodWar"]()  
                elseif lvSectionId == 14 then
                    isOpen = SystemUtils["enableSignShop"]()  
                elseif lvSectionId == 15 then
                    isOpen = SystemUtils["enableCrossArena"]()
                end
                if not isOpen then
                    self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
                    return 
                end
                if lvSectionId == 7 then
                    self._viewMgr:showView("treasure.TreasureShopView")
                elseif lvSectionId == 9 then
                    -- self._viewMgr:showView("elemental.ElementShopView")
                    self._viewMgr:showView("shop.ShopView", {idx = 7})
                elseif lvSectionId == 10 then
                    self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = "skillbook"}, true, {}, function(result)
                        self._viewMgr:showDialog("skillCard.SkillCardShopView",{},true)
                    end)
                elseif lvSectionId == 11 then
                    self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = "cp"}, true, {}, function(result) 
                        self._viewMgr:showView("shop.ShopView", {idx = 9})
                    end)
                elseif lvSectionId == 8 then
                    local sfc = cc.SpriteFrameCache:getInstance()
                    local tc = cc.Director:getInstance():getTextureCache() 
                    if not tc:getTextureForKey("citybattle_nbGirl.png") then
                        sfc:addSpriteFrames("asset/ui/citybattle.plist", "asset/ui/citybattle.png")
                    end
                    self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = "citybattle"}, true, {}, function(result)
                        -- self._viewMgr:showDialog("citybattle.CityBattleShopView",{},true)
                        self._viewMgr:showView("shop.ShopView", {idx = 8})
                    end)
                elseif lvSectionId == 12 then
                    local sfc = cc.SpriteFrameCache:getInstance()
                    local tc = cc.Director:getInstance():getTextureCache()
                    --if not tc:getTextureForKey("TeamHolyUI_img27.png") then
                        sfc:addSpriteFrames("asset/ui/team2.plist", "asset/ui/team2.png")
                    --end
                    self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type="rune"}, true, {}, function(result)
                        self._viewMgr:showView("team.TeamHolyShopView", {callback = function(isChange)
                            if isChange then
                                --self:updateBagData()
                            end
                        end})
                    end)
                elseif lvSectionId == 14 then   --签到商店
                    self._viewMgr:showDialog("activity.sign.AcSignShopView", {}, true)
                elseif lvSectionId == 15 then -- 荣耀商店
                    self._viewMgr:showView("shop.ShopView", {idx = 11})
                else
                    self._viewMgr:showView("shop.ShopView", {idx = shopIdx,showDialogTreasure = lvSectionId == 7})
                end
            else
                local isOpen = LeagueUtils:isLeagueOpen()
                if not isOpen then
                    self._viewMgr:showTip(lang("TIP_GUILD_OPEN_5"))
                    return  
                end
                -- 积分联赛重置时间内 无法获得 数据 拦截
                if self._modelMgr:getModel("LeagueModel"):isMondayRest() then
                    ViewManager:getInstance():showTip(lang("LEAGUETIP_18"))
                    return
                end
                local shopData = self._modelMgr:getModel("ShopModel"):getShopGoods("league") or {}
                if not next(shopData) then
                    self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = "league"}, true, {}, function(result)
                        self._viewMgr:showView("shop.ShopView", {idx = 6})
                    end)
                else
                    self._viewMgr:showView("shop.ShopView", {idx = 6})
                end
            end
        elseif lvType == 4 then
            -- 联盟
            if not SystemUtils:enableGuild() then
                self._viewMgr:showTip(lang("TIP_JINGYING_1"))
                return 
            end
            if not self._modelMgr:getModel("UserModel"):getIdGuildOpen() then
                self._viewMgr:showTip(lang("TIPS_RANK_02"))
                return
            end
            local level = self._modelMgr:getModel("GuildModel"):getData().level
            if lvSectionId == 1 then -- 联盟战
                if level < tab:GuildRoad(5).limit then
                    self._viewMgr:showTip(lang("TIP_GUILD_OPEN_5"))
                    return 
                end
                self._viewMgr:showView("guild.map.GuildMapView")
            elseif lvSectionId == 2 then -- 联盟交易？支援
                if level < tab:GuildRoad(8).limit then
                    self._viewMgr:showTip(lang("TIP_GUILD_OPEN_8"))
                    return 
                end
                self._viewMgr:showView("guild.backup.GuildBackupView")
            end
        elseif lvType == 5 then
            if not stageInfo.isOpen then
                self._viewMgr:showTip("暂未开放")
                return 
            end
            if lvSectionId == 1 then
                local intanceModel = self._modelMgr:getModel("IntanceModel")
                local sectionId = intanceModel:getCurMainSectionId()
                local stageId --= intanceModel:getData().mainsData.curStageId
                print("sectionId,stageId",sectionId,stageId)
                self._viewMgr:showView("intance.IntanceView", {sectionId= sectionId, quickStageId = stageId,itemId = self._itemData.goodsId,needItemNum = self._itemData.needItemNum})
            elseif lvSectionId == 2 then
                -- 星级宝箱
                local baseId
                if type(lvBaseId) == "table" then
                    for i,sectionId in ipairs(lvBaseId) do
                        local section = self._modelMgr:getModel("IntanceModel"):getSectionInfo(tonumber(sectionId))
                        dump(section,"section" .. sectionId)
                        if section.hasUnRecStarBox then
                            baseId = sectionId 
                            print("baseId......",baseId)
                            break
                        end
                    end
                else
                    print("lvBaseId......",lvBaseId)
                    baseId = lvBaseId
                end
                dump(data,"星级宝箱" .. (baseId or 0))
                -- local stageId = baseId*100+1
                if baseId then
                    self._viewMgr:showView("intance.IntanceView", {sectionId= baseId or baoxiangFubenId, quickStageId = 0,itemId = self._itemData.goodsId,needItemNum = self._itemData.needItemNum})
                else
                    self._viewMgr:showTip("已经没有宝箱可以领取了")
                end
            end       
        elseif lvType == 6 then
            if lvSectionId ~= 1 then
                local stageInfo = {}
                if lvBaseId and lvBaseId[1] then
                    stageInfo = self._modelMgr:getModel("IntanceEliteModel"):getStageInfo(lvBaseId[1]*100+1)
                end
                if not SystemUtils:enableElite() or not stageInfo.isOpen then
                    self._viewMgr:showTip("暂未开放")
                    return 
                end
            end
            if lvSectionId == 1 then
                local intanceModel = self._modelMgr:getModel("IntanceEliteModel")
                local sectionId = intanceModel:getCurSectionId()
                local stageId --= intanceModel:getData().curStageId
                self._viewMgr:showView("intance.IntanceEliteView", {sectionId= sectionId, quickStageId = stageId,itemId = self._itemData.goodsId,needItemNum = self._itemData.needItemNum})
            elseif lvSectionId == 2 then
                -- 星级宝箱
                local baseId
                if type(lvBaseId) == "table" then
                    local beginId = lvBaseId[1]
                    local endId = lvBaseId[#lvBaseId]
                    if #lvBaseId >= 2 then
                        for i=beginId,endId do
                            local section = self._modelMgr:getModel("IntanceEliteModel"):getSectionInfo(i)
                            local stageInfoTmp = self._modelMgr:getModel("IntanceEliteModel"):getStageInfo(i*100+1)
                            if section.hasUnRecStarBox and stageInfoTmp.isOpen then
                                baseId = i
                            end
                        end
                    else
                        for i,sectionId in ipairs(lvBaseId) do
                            local section = self._modelMgr:getModel("IntanceEliteModel"):getSectionInfo(sectionId)
                            local stageInfoTmp = self._modelMgr:getModel("IntanceEliteModel"):getStageInfo(sectionId*100+1)
                            if section.hasUnRecStarBox and stageInfoTmp.isOpen then
                                baseId = sectionId 
                                break
                            end
                        end
                    end

                else
                    baseId = lvBaseId
                end
                -- dump(data,"星级宝箱" .. (baseId or 0))
                -- local stageId = baseId*100+1
                if baseId then
                    self._viewMgr:showView("intance.IntanceEliteView", {sectionId= baseId or baoxiangFubenId, quickStageId = 0,itemId = self._itemData.goodsId,needItemNum = self._itemData.needItemNum})
                else
                    self._viewMgr:showTip("已经没有宝箱可以领取了")
                end
            elseif lvSectionId == 3 then
                -- 地下城关卡
                self._viewMgr:showView("intance.IntanceEliteView", {sectionId= baoxiangFubenId, quickStageId = nil,itemId = self._itemData.goodsId,needItemNum = self._itemData.needItemNum})
            end  
        elseif lvType == 7 then
            -- 各种玩法
            if lvSectionId == 1 then
                if not SystemUtils:enableDwarvenTreasury() then
                    self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
                    return 
                end
                self._viewMgr:showView("pve.AiRenMuWuView") 
            elseif lvSectionId == 2 then
                if not SystemUtils:enableCrypt() then
                    self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
                    return 
                end
                self._viewMgr:showView("pve.ZombieView")
            elseif lvSectionId == 3 then
                if not SystemUtils:enableBoss() then
                    self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
                    return 
                end
                self._viewMgr:showView("pve.DragonView")
            elseif lvSectionId == 4 then  -- 玩法云中城
                if not SystemUtils:enableCloudCity() then
                    self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
                    return 
                end
                self._viewMgr:showView("cloudcity.CloudCityView",{})
            end
        elseif lvType == 8 then
            if not (SystemUtils:enableCrusade()) then
                self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
                return 
            end
            self._viewMgr:showView("crusade.CrusadeView")
        elseif lvlType == 9 then
            if not SystemUtils:enableMF() then
                self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
                return 
            end
            self._viewMgr:showView("MF.MFView")
        elseif lvType == 10 then
            if not SystemUtils:enableTask() then
                self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
                return 
            end
            self._viewMgr:showView("task.TaskView",{viewType = 2})
        elseif lvType == 11 then
            self._viewMgr:showView("flashcard.FlashCardView")
        elseif lvType == 12 then
            if not SystemUtils:enableMF() then
                self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
                return 
            end
            self._viewMgr:showView("MF.MFView")
        elseif lvType == 13 then
            local stageId = lvBaseId
            if not SystemUtils:enableCloudCity() then
                self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
                return 
            end
            local isOpen = self._modelMgr:getModel("CloudCityModel"):canArriveStage(stageId)
            if not isOpen then
                -- local notOpenStr = 
                self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
                return 
            end
            self._viewMgr:showView("cloudcity.CloudCityView",{stageId = stageId})
        elseif lvType == 14 then -- 积分联赛 （冠军对决）
            local isOpen,openDes = LeagueUtils:isLeagueOpen()
            if not isOpen then
                self._viewMgr:showTip(lang("TIP_GUILD_OPEN_5"))
                return 
            end
            -- 积分联赛重置时间内 无法获得 数据 拦截
            if self._modelMgr:getModel("LeagueModel"):isMondayRest() then
                ViewManager:getInstance():showTip(lang("LEAGUETIP_18"))
                return
            end
            self._viewMgr:showView("league.LeagueView")
        elseif lvType == 15 then -- 英雄交锋
            local isOpen = LeagueUtils:isLeagueOpen(104)
            if not isOpen then
                -- local notOpenStr = 
                self._viewMgr:showTip(lang("TIP_GUILD_OPEN_5"))
                return 
            end
            self._viewMgr:showView("heroduel.HeroDuelMainView")
        elseif lvType == 16 then -- 巢穴
            local isOpen = SystemUtils:enableNests()
            if not isOpen then
                self._viewMgr:showTip(lang("TIP_GUILD_OPEN_5"))
                return 
            end
            self._viewMgr:showView("nests.NestsView",{tId = lvSectionId})
        elseif lvType == 17 then -- 联盟探索
            local isOpen = true
            if not SystemUtils:enableGuild() or not self._modelMgr:getModel("UserModel"):getIdGuildOpen() then
                isOpen = false
            end
            if not isOpen and SystemUtils["enableGuild"]() then
                self._viewMgr:showTip("请先加入联盟")
                return 
            end
            if not isOpen then
                -- local notOpenStr = 
                self._viewMgr:showTip(lang("TIP_GUILD_OPEN_5"))
                return 
            end
            self._viewMgr:showView("guild.map.GuildMapView")
        elseif lvType == 18 then
            local isOpen = SystemUtils:enableSkillBook()
            if not isOpen then
                self._viewMgr:showTip(lang("TIP_GUILD_OPEN_5"))
                return 
            end
            self._viewMgr:showView("skillCard.SkillCardTakeView")
        elseif lvType == 20 then
            local isOpen = SystemUtils:enableCrossArena()
            if not isOpen then
                self._viewMgr:showTip(lang("TIP_GUILD_OPEN_5"))
                return
            end
            self._modelMgr:getModel("GloryArenaModel"):lOpenGloryArena()
        end
    end
    local limitNumLabel = item:getChildByFullName("limitNum")
    limitNumLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    limitNumLabel:setVisible(false)
    
    if lvType == 1 then
        -- 普通副本
        stageInfo = self._modelMgr:getModel("IntanceModel"):getStageInfo(lvBaseId)
        local preId = tab:MainStage(lvBaseId).PreId
        print("lvBaseId",lvBaseId,preId)
        if preId ~= 0 then 
            stageInfo.notOpenTipDes = "通关剧情副本" .. ((math.floor(preId/100)%100 .. "-" .. preId%100) or "神秘关卡") .. "开启"
        end
        accessType:setString(lang("SOURCE_1"))
    elseif lvType == 2 then
        -- 精英副本
        stageInfo = self._modelMgr:getModel("IntanceEliteModel"):getStageInfo(lvBaseId)
        local preId = tab:MainStage(lvBaseId).PreId
        if preId ~= 0 then
            local preStageInfo = self._modelMgr:getModel("IntanceModel"):getStageInfo(preId)
            local addtionDes = "剧情副本"
            if lvBaseId%100 ~= 1 or (lvBaseId%100 == 1 and preStageInfo.isOpen) then
                if lvBaseId%100 == 1 then
                    preId = lvBaseId-100+4
                end
                addtionDes = "地下副本"
            end
            if not tab:MainStage(preId) then
                preId = tab:MainStage(lvBaseId).PreId
            end
            if preId ~= 0 then 
                stageInfo.notOpenTipDes = "通关".. addtionDes .. ((math.floor(preId/100)%100 .. "-" .. preId%100) or "神秘关卡") .. "开启"
            end
        end
        accessType:setString(lang("SOURCE_2"))
        limitNumLabel:setVisible(true)
        limitNumLabel:setString("(" ..(stageInfo.lNum or math.max(stageInfo.maxNum-stageInfo.num,0)) .. "/" .. stageInfo.maxNum .. ")")
        dump(stageInfo,"stageInfo.....")
        limitNumLabel:setPositionX(restLabel:getPositionX()+restLabel:getContentSize().width)
        if stageInfo.maxNum-stageInfo.num > 0 then
            limitNumLabel:setColor(cc.c3b(0, 255, 30))
        else
            limitNumLabel:setColor(cc.c3b(255, 23, 23))
        end
    elseif lvType == 3 then
        -- 商店
        accessType:setString(lang("SOURCE_3"..lvSectionId))
        if lvSectionId == 1 then
            isOpen = SystemUtils["enableMysteryShop"]()
        elseif lvSectionId == 2 then
            isOpen = SystemUtils["enableArena"]()
        elseif lvSectionId == 3 then
            isOpen = SystemUtils["enableCrusade"]() 
        elseif lvSectionId == 4 then
            isOpen = SystemUtils["enableTreasure"]()
        elseif lvSectionId == 5 then 
            isOpen = SystemUtils["enableGuildShop"]() and self._modelMgr:getModel("UserModel"):getIdGuildOpen()
        elseif lvSectionId == 6 then 
            isOpen = LeagueUtils:isLeagueOpen()
        elseif lvSectionId == 7 then
            isOpen = SystemUtils["enableTreasure"]()
        elseif lvSectionId == 8 then
            isOpen = self._modelMgr:getModel("CityBattleModel"):checkIsGvgOpen()
        elseif lvSectionId == 9 then
            isOpen = SystemUtils["enableElementShop"]()
        elseif lvSectionId == 10 then
            isOpen = SystemUtils["enableSkillBook"]()
        elseif lvSectionId == 11 then
            isOpen = SystemUtils["enableCrossPK"]()
        elseif lvSectionId == 12 then
            isOpen = SystemUtils["enableHoly"]()
        elseif lvSectionId == 13 then
            isOpen = SystemUtils["enableCrossGodWar"]() 
        elseif lvSectionId == 14 then
            isOpen = SystemUtils["enableSignShop"]() 
        elseif lvSectionId == 15 then
            isOpen = SystemUtils["enableCrossArena"]()
        end
        shopInfo = {isOpen = isOpen}
    elseif lvType == 4 then
        local sourceStr = lang("SOURCE_4" .. lvSectionId) or ""
        local isOpen = true
        if not SystemUtils:enableGuild() or not self._modelMgr:getModel("UserModel"):getIdGuildOpen() then
            isOpen = false
        else
            local level = self._modelMgr:getModel("GuildModel"):getData().level
            if lvSectionId == 1 then -- 联盟战
                if level < tab:GuildRoad(5).limit then
                    isOpen = false
                end
                if sourceStr == "" then
                    sourceStr = "联盟战"
                end
            elseif lvSectionId == 2 then -- 联盟交易？支援
                if level < tab:GuildRoad(8).limit then
                    isOpen = false
                end
                if sourceStr == "" then
                    sourceStr = "联盟交易"
                end
            end
        end
        accessType:setString(sourceStr or "未知之地")
        shopInfo = {isOpen = isOpen}
    elseif lvType == 5 then
        if lvSectionId == 1 then
            accessType:setString(lang("SOURCE_51"))
            stageInfo = {isOpen = true}
        else
            -- 星级宝箱
            if lvBaseId[1] == lvBaseId[2] then
                accessType:setString(lang("SOURCE_1") .. lang("CHAR_DI") .. lang("NUM_"..lvBaseId[1] - 71000) .. lang("CHAR_ZHANG"))
            else
                accessType:setString(lang("SOURCE_1") .. lang("CHAR_DI") .. "" .. lang("NUM_"..lvBaseId[1] - 71000) .. "至" .. lang("NUM_"..lvBaseId[2] - 71000) .. "" .. lang("CHAR_ZHANG"))
            end
            restLabel:setString(lang("SOURCE_52"))
            -- 开放条件是最低的章节满足
            stageInfo = self._modelMgr:getModel("IntanceModel"):getStageInfo(lvBaseId[1]*100+1)
            if not stageInfo.isOpen then
                stageInfo.notOpenTipDes = "暂未开放"
            end
            -- 跳到最高的章节
            for i = lvBaseId[2], lvBaseId[1], -1 do
                if self._modelMgr:getModel("IntanceModel"):getStageInfo(i*100+1).isOpen then
                    baoxiangFubenId = i
                    break
                end
            end
        end
    elseif lvType == 6 then
        if lvSectionId == 1 then
            accessType:setString(lang("SOURCE_61"))
            stageInfo = {isOpen = SystemUtils["enableElite"]()}
            if not stageInfo.isOpen then
                stageInfo.notOpenTipDes = "暂未开放"
            end
        else
            -- 星级宝箱
            if lvSectionId == 2 then
                if lvBaseId[1] == lvBaseId[2] then
                    accessType:setString(lang("SOURCE_2") .. lang("CHAR_DI") .. lang("NUM_"..lvBaseId[1] - 72000) .. lang("CHAR_ZHANG"))
                else
                    accessType:setString(lang("SOURCE_2") .. lang("CHAR_DI") .. "" .. lang("NUM_"..lvBaseId[1] - 72000) .. "至" .. lang("NUM_"..lvBaseId[2] - 72000) .. "" .. lang("CHAR_ZHANG"))
                end
                restLabel:setString(lang("SOURCE_62"))
            else-- 地下城关卡
                accessType:setString(lang("SOURCE_2") .. lang("CHAR_DI") .. lang("NUM_"..lvBaseId[1] - 72000) .. lang("CHAR_ZHANG"))
                restLabel:setString( lang("HEAD_LINK_1") or "地下城关卡" or lang("SOURCE_52"))
            end
            -- 开放条件是最低的章节满足
            stageInfo = self._modelMgr:getModel("IntanceEliteModel"):getStageInfo(lvBaseId[1]*100+1)
            if not stageInfo.isOpen then
                stageInfo.notOpenTipDes = "暂未开放"
            end
            -- 跳到最高的章节
            for i = lvBaseId[2], lvBaseId[1], -1 do
                if self._modelMgr:getModel("IntanceEliteModel"):getStageInfo(i*100+1).isOpen then
                    baoxiangFubenId = i
                    break
                end
            end
        end
    elseif lvType == 7 then
        -- 玩法
        accessType:setString(lang("SOURCE_7"..lvSectionId))
        if lvSectionId == 1 then
            stageInfo = { isOpen = SystemUtils["enableDwarvenTreasury"]()}
        elseif lvSectionId == 2 then
            stageInfo = { isOpen = SystemUtils["enableCrypt"]()}
        elseif lvSectionId == 3 then
            stageInfo = { isOpen = SystemUtils["enableBoss"]()}
        elseif lvSectionId == 4 then
            accessType:setString(lang("SOURCE_13") or "云中城")
            stageInfo = { isOpen = SystemUtils["enableCloudCity"]()}
        end             
    elseif lvType == 8 then
        -- 远征
        accessType:setString(lang("SOURCE_8"))
        stageInfo = {
            isOpen = SystemUtils["enableCrusade"]()
        }
    elseif lvType == 10 then
        accessType:setString(lang("SOURCE_10"))
        stageInfo = {
            isOpen = SystemUtils["enableDailyTask"]()
        }
    elseif lvType == 11 then
        accessType:setString(lang("SOURCE_11"))
        stageInfo = {
            isOpen = true
        }
    elseif lvType == 12 then
        accessType:setString(lang("SOURCE_12") or "航海")
        stageInfo = {
            isOpen = SystemUtils["enableMF"]()
        }
    elseif lvType == 13 then
        local stageId = lvBaseId
        accessType:setString(lang("SOURCE_13") or "云中城")
        local guanNum = stageId%4
        if guanNum == 0 then
            guanNum = 4 
        end
        restLabel:setString("第".. math.ceil(stageId/4) .."层第" .. guanNum .."关")
        stageInfo = {
            isOpen = SystemUtils:enableCloudCity() and self._modelMgr:getModel("CloudCityModel"):canArriveStage(stageId) or false,
            notOpenTipDes = "通关第".. math.ceil(stageId/4) .."层第" .. guanNum .."关开启",
        }
    elseif lvType == 14 then
        accessType:setString(lang("SOURCE_14") or "积分联赛")
        stageInfo = {
            isOpen = LeagueUtils:isLeagueOpen()
        }
    elseif lvType == 15 then
        accessType:setString("英雄交锋")
        stageInfo = {
            isOpen = LeagueUtils:isLeagueOpen(104) -- 暂时关闭 -- LeagueUtils:isLeagueOpen()
        }
    elseif lvType == 16 then
        accessType:setString("兵营兑换")
        stageInfo = {
            isOpen = SystemUtils:enableNests() -- 暂时关闭 -- LeagueUtils:isLeagueOpen()
        }
    elseif lvType == 17 then
        accessType:setString("联盟探索")
        local isOpen = true
        if not SystemUtils:enableGuild() or not self._modelMgr:getModel("UserModel"):getIdGuildOpen() then
            isOpen = false
        end
        stageInfo = {
            isOpen = isOpen
        }
    elseif lvType == 18 then
        accessType:setString(lang("SOURCE_18"))
        stageInfo = {
            isOpen = SystemUtils:enableSkillBook() -- 暂时关闭 -- LeagueUtils:isLeagueOpen()
        }
    elseif lvType == 20 then
        accessType:setString(lang("SOURCE_20"))
        stageInfo = {
            isOpen = SystemUtils:enableCrossArena()
        }
    end
    self:registerClickEvent(item, function (data)
        print("lvType",lvType)
        goFunc()
    end)
    if not(stageInfo.isOpen or shopInfo.isOpen) then
        accessType:setColor(cc.c3b(182, 182, 182))
        restLabel:setColor(cc.c3b(182, 182, 182))
        accessType:enableOutline(cc.c4b(0,0,0,255),1)
        restLabel:enableOutline(cc.c4b(0,0,0,255),1)
        limitNumLabel:setVisible(false)
        -- local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 182))
        -- layer:setContentSize(cc.size(bg:getContentSize().width, bg:getContentSize().height))
        -- bg:addChild(layer, 10000)
        -- bg:setSaturation(-100)
        bg:setColor(cc.c4b(100, 100, 100,182))
        lock:setVisible(true)
        if stageInfo.notOpenTipDes then
            self:registerClickEvent(item, function (data)
                print("lvType============",lvType)
                if lvType == 1 then
                    local param = {indexId = 6}
                    self._viewMgr:showDialog("global.GlobalPromptDialog", param)
                elseif lvType == 2 then
                    local param = {indexId = 7}
                    if not SystemUtils["enableElite"]() then
                        param.indexId = 6
                    end
                    self._viewMgr:showDialog("global.GlobalPromptDialog", param)
                elseif lvType == 5 then
                    local param = {indexId = 6}
                    self._viewMgr:showDialog("global.GlobalPromptDialog", param)
                elseif lvType == 6 then
                    local param = {indexId = 7}
                    if not SystemUtils["enableElite"]() then
                        param.indexId = 6
                    end
                    self._viewMgr:showDialog("global.GlobalPromptDialog", param)
                else
                    self._viewMgr:showTip(stageInfo.notOpenTipDes)
                end
            end)
        end
    end

    item:setSwallowTouches(false)
    local children = item:getChildren()
    for k,v in pairs(children) do
        if v.setSwallowTouches then
            v:setSwallowTouches(false)
        end
    end
end

function DialogAccessTo:getNeedNum( itemId )
    
end

function DialogAccessTo:reflashUI(data)
    local item,icount = self._modelMgr:getModel("ItemModel"):getItemsById(self._itemData.goodsId)
    if icount == 0 then
        if self._itemData.goodsId == 39978 then -- payGem 特殊处理 gem在model里整合了 payGem freeGem等
            icount = self._modelMgr:getModel("UserModel"):getData()["gem"] or 0
        else
            for k,v in pairs(IconUtils.iconIdMap) do
                if v == self._itemData.goodsId then
                    icount = self._modelMgr:getModel("UserModel"):getData()[k] or 0
                    break
                end
            end
        end
    end
    self._itemNum:setString(ItemUtils.formatItemCount(icount) or "0")
    self._itemCountDes:disableEffect()
    self._itemCountDes:setPositionX(self._itemNum:getPositionX()+self._itemNum:getContentSize().width)
    local approachData1 = self._toolData.approach or {}
    local approachData2 = self._toolData.approach2 or {}
    local approachData3 = self._toolData.approach3 or {}
    
    local approachData = {}
    
    for i = 1, #approachData2 do
        approachData[#approachData + 1] = approachData2[i]
    end
    for i = 1, #approachData1 do
        approachData[#approachData + 1] = approachData1[i]
    end

    if self._toolData.typeId == 5 then
        local disTreasureD = tab.disTreasure[self._toolData.id]
        local actived = self._modelMgr:getModel("TreasureModel"):getTreasureById(self._toolData.id)
        local _,num = self._modelMgr:getModel("ItemModel"):getItemsById(self._toolData.id)
        if disTreasureD and disTreasureD.produce == 1 and not (actived or num > 0) then
            for i,v in ipairs(approachData) do
                if v[1] == 3 and v[2] == 4 then
                    table.remove(approachData,i)
                    break
                end
            end
        end
    end

    self._noneIcon:setVisible((#approachData+#approachData3) == 0)

    self._scrollView:removeAllChildren()
    local x = -5
    local itemHeight = self._scrollItem:getContentSize().height
    local maxHeight = itemHeight * (#approachData+#approachData3) + 2 * (#approachData+#approachData3 - 1)
    if maxHeight < self._scrollView:getContentSize().height then 
        maxHeight = self._scrollView:getContentSize().height
    end
    local y = maxHeight - self._scrollItem:getContentSize().height

    self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width,maxHeight))
    for i = 1,#approachData do
        self:createApproatchCell(approachData[i], x, y, i)
        y = y - (itemHeight + 2)
    end

    -- 特殊 1 活动 2 月卡
    local notNormal = #approachData == 0
    for i = 1, #approachData3 do --#approachData3
        self:createSpecialGetCell(approachData3[i],i,x,y,notNormal)
        y = y - (itemHeight + 2)
    end
end

local specialTypeMap = {"精彩活动获得","累计签到获得"}
-- 特殊来源展示
function DialogAccessTo:createSpecialGetCell( celltp,i,x,y, notSplit )
    local item = self._scrollItem:clone()
    item:setPosition(x,y)
    item:setVisible(true)
    item:removeAllChildren()
    self._scrollView:addChild(item)
    local itemW,itemH = item:getContentSize().width,item:getContentSize().height
    local cellOffsetY = 40
    if notSplit then
        if i == 1 then
            cellOffsetY = 0
        else
            cellOffsetY = -20
        end
    end
    if not self._specialSplit and not notSplit then
        cellOffsetY = 60
        local offX,offY = 110,-30
        local exImg = ccui.ImageView:create()
        exImg:loadTexture("globalImageUI_approach_moreTitle.png",1)
        exImg:setPosition(x+itemW/2,y+itemH+offY)
        exImg:setScale9Enabled(true)
        exImg:setCapInsets(cc.rect(84,22,1,1))
        exImg:setContentSize(cc.size(319,43))
        self._scrollView:addChild(exImg)
        local text = ccui.Text:create()
        text:setFontName(UIUtils.ttfName_Title)
        text:setFontSize(26)
        text:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        text:setPosition(x+itemW/2,y+itemH+offY)
        text:setString("更多")
        self._scrollView:addChild(text,999)

        self._specialSplit = text
    end
    local offX,offY = 110,-20-cellOffsetY
    local spL = ccui.ImageView:create()
    spL:loadTexture("globalImageUI_approach_decorate.png",1)
    spL:setPosition(x+itemW/2-offX,y+itemH+offY)
    self._scrollView:addChild(spL)

    local spR = ccui.ImageView:create()
    spR:loadTexture("globalImageUI_approach_decorate.png",1)
    spR:setPosition(x+itemW/2+offX,y+itemH+offY)
    spR:setScaleX(-1)
    self._scrollView:addChild(spR)

    local spImg = ccui.ImageView:create()
    spImg:loadTexture("globalImageUI_approach_split.png",1)
    spImg:setPosition(x+itemW/2,y+itemH-30+offY)
    self._scrollView:addChild(spImg)

    local text = ccui.Text:create()
    text:setFontName(UIUtils.ttfName_Title)
    text:setFontSize(22)
    text:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    text:setPosition(x+itemW/2,y+itemH+offY)
    text:setString(specialTypeMap[celltp] or "")
    self._scrollView:addChild(text,999)
    return item
end

return DialogAccessTo