--[[
    Filename:    NewFormationView_League.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2017-01-12 20:44:02
    Description: File description
--]]

local NewFormationIconView = require("game.view.formation.NewFormationIconView")
local NewFormationView = require("game.view.formation.NewFormationView")

function NewFormationView:onInitEx()
    self._leagueModel = self._modelMgr:getModel("LeagueModel")
    self._layerLeft._layerList._imageBubble = self:getUI("bg.layer_left.layer_list.image_bubble")
    self._layerLeft._layerList._imageBubble:setVisible(self:isShowHeroBubble())
    if self:isShowHeroBubble() then
        self._layerLeft._layerList._imageBubble:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(10, 0)), cc.MoveBy:create(0.5, cc.p(-10, 0)))))
    end
    local isCurBatchFirstIn = self._modelMgr:getModel("LeagueModel"):isCurBatchFirstInFomation()
    self._layerLeft._layerList._imageBubble:setVisible(isCurBatchFirstIn)
end

function NewFormationView:isShowHeroBubble()
    return self._extend and self._extend.showHelpTag
end

function NewFormationView:switchLayerList(iconType, force)
    if self._context._gridType[self._context._formationId] == iconType and not force then return end

    if NewFormationView.kGridTypeHero == iconType then
        if self:isShowHeroBubble() then
            self._layerLeft._layerList._imageBubble:setVisible(false)
            self._layerLeft._layerList._imageBubble:stopAllActions()
        end
    end

    self._context._gridType[self._context._formationId] = iconType
    self._layerLeft._layerList._btnTabTeam:setEnabled(NewFormationView.kGridTypeTeam ~= iconType)
    self._layerLeft._layerList._btnTabTeam:setBright(NewFormationView.kGridTypeTeam ~= iconType)

    self._layerLeft._layerList._btnTabHero:setEnabled(NewFormationView.kGridTypeHero ~= iconType)
    self._layerLeft._layerList._btnTabHero:setBright(NewFormationView.kGridTypeHero ~= iconType)

    self._layerLeft._layerList._btnFilter:setEnabled(NewFormationView.kGridTypeTeam == iconType)
    self._layerLeft._layerList._btnFilter:setSaturation(NewFormationView.kGridTypeTeam == iconType and 0 or -100)

    if self:isShowInsFormation() then
        self._layerLeft._layerList._btnTabIns:setEnabled(NewFormationView.kGridTypeIns ~= iconType)
        self._layerLeft._layerList._btnTabIns:setBright(NewFormationView.kGridTypeIns ~= iconType)
    end

    if NewFormationView.kGridTypeTeam == iconType then
        self._layerLeft._layerList._btnTabTeam:setTitleColor(cc.c4b(252, 244, 197, 255))
        --self._layerLeft._layerList._btnTabTeam:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

        self._layerLeft._layerList._btnTabHero:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabHero:getTitleRenderer():disableEffect()

        self._layerLeft._layerList._btnTabHireTeam:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabHireTeam:getTitleRenderer():disableEffect()

        self._layerLeft._layerList._btnTabIns:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabHireTeam:getTitleRenderer():disableEffect()
    elseif NewFormationView.kGridTypeHero == iconType then
        self._layerLeft._layerList._btnTabHero:setTitleColor(cc.c4b(252, 244, 197, 255))
        --self._layerLeft._layerList._btnTabHero:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

        self._layerLeft._layerList._btnTabTeam:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabTeam:getTitleRenderer():disableEffect()

        self._layerLeft._layerList._btnTabHireTeam:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabHireTeam:getTitleRenderer():disableEffect()

        self._layerLeft._layerList._btnTabIns:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabHireTeam:getTitleRenderer():disableEffect()
    elseif NewFormationView.kGridTypeHireTeam == iconType and self:isShowHireTeam() then
        self._layerLeft._layerList._btnTabHireTeam:setTitleColor(cc.c4b(252, 244, 197, 255))
        --self._layerLeft._layerList._btnTabHireTeam:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

        self._layerLeft._layerList._btnTabHero:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabHero:getTitleRenderer():disableEffect()

        self._layerLeft._layerList._btnTabTeam:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabTeam:getTitleRenderer():disableEffect()

        self._layerLeft._layerList._btnTabIns:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabHireTeam:getTitleRenderer():disableEffect()
    elseif NewFormationView.kGridTypeIns == iconType and self:isShowInsFormation() then

        if self:isInsBubbleShow() then
            self._layerLeft._layerList._imageInsBubble:setVisible(false)
            self._layerLeft._layerList._imageInsBubble:stopAllActions()
            self._formationModel:setWeaponTipsShowed(self._context._formationId)
        end

        self._layerLeft._layerList._btnTabIns:setTitleColor(cc.c4b(252, 244, 197, 255))
        --self._layerLeft._layerList._btnTabHireTeam:getTitleRenderer():disableEffect()

        self._layerLeft._layerList._btnTabHero:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabHero:getTitleRenderer():disableEffect()

        self._layerLeft._layerList._btnTabTeam:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabTeam:getTitleRenderer():disableEffect()

        self._layerLeft._layerList._btnTabHireTeam:setTitleColor(cc.c4b(147, 107, 81, 255))
        --self._layerLeft._layerList._btnTabHireTeam:getTitleRenderer():disableEffect()
    end

    self:updateLeftTeamFormationAddition(not (NewFormationView.kGridTypeTeam == iconType or NewFormationView.kGridTypeHireTeam == iconType))
    self:updateLeftHeroAddition(NewFormationView.kGridTypeHero ~= iconType)
    self:updateLeftInsFormationAddition(NewFormationView.kGridTypeIns ~= iconType)

    self:refreshItemsTableView(true)
end


function NewFormationView:isHeroHelp(heroId)
    if not (heroId and self._extend and self._extend.helpHero) then return false end
    heroId = tonumber(heroId)
    local found = false
    for k, v in pairs(self._extend.helpHero) do
        if v == heroId then
            found = true
            break
        end
    end
    return found
end

function NewFormationView:isNextHeroHelp(heroId)
    if not (heroId and self._extend and self._extend.nextHelpHero) then return false end
    heroId = tonumber(heroId)
    local found = false
    for k, v in pairs(self._extend.nextHelpHero) do
        if v == heroId then
            found = true
            break
        end
    end
    return found
end

function NewFormationView:isDoubleHeroHelp(heroId)
    if not (heroId and self._extend and self._extend.helpHero and self._extend.nextHelpHero) then return false end
    heroId = tonumber(heroId)
    return (self:isHeroHelp(heroId) and self:isNextHeroHelp(heroId))
end

function NewFormationView:isFiltered(iconId)
    if 0 == iconId then return false end

    local found = false
    local data = self._layerLeft._teamFormation._data[self._context._formationId]
    if data.filter then
        for k, v in pairs(data.filter) do
            if v == iconId then
                found = true
                break
            end
        end
    end

    found = self:isNextHeroHelp(iconId) and not self:isHeroHelp(iconId)

    return found
end

function NewFormationView:initCustomHeroData()
    if not (self._extend and self._extend.heroes) then return end
    local t = {}
    for _, id in ipairs(self._extend.heroes) do
        repeat
            local data = clone(self._leagueModel:getMyHeroData(id))
            if not data then break end
            data.heroId = id
            data.custom = true
            data.id = nil
            t[data.heroId] = data
        until true
    end
    self._extend.heroes = t
end

function NewFormationView:initHeroListData()
    self._layerLeft._layerList._heroData = {}
    local data = {}
    if not self._extend.heroesInit then
        self:initCustomHeroData()
        self._extend.heroesInit = true
    end
    data = clone(self._extend.heroes)

    -- sort edit by yuxiaojing 2018/04/19 bug#21708
    local leagueHeroOrder = tab.leagueHeroOrder
    local function isLeagueHeroOrder( id )
        for k, v in pairs(leagueHeroOrder) do
            if v.hero == id then
                return v.id
            end
        end
        return nil
    end
    local ts1, t1, t2 = {}, {}, {}
    for k, v in pairs(data) do
        repeat
            if self:isLoaded(NewFormationView.kGridTypeHero, tonumber(k)) then break end
            if not self:isFiltered(tonumber(k)) then
                v.id = tonumber(k)
                if self:isHeroHelp(tonumber(k)) then
                    table.insert(ts1, v)
                else
                    local sortId = isLeagueHeroOrder(tonumber(k))
                    if sortId then
                        v.sortId = sortId
                        table.insert(t1, v)
                    else
                        table.insert(t2, v)
                    end
                end
            end
        until true
    end

    table.sort(t2, function(a, b)
        return a.score > b.score
    end)

    table.sort(t1, function(a, b)
        return a.sortId < b.sortId
    end)


    for i = 1, #ts1 do
        self._layerLeft._layerList._heroData[#self._layerLeft._layerList._heroData + 1] = ts1[i]
    end

    for i = 1, #t2 do
        self._layerLeft._layerList._heroData[#self._layerLeft._layerList._heroData + 1] = t2[i]
    end

    for i = 1, #t1 do
        self._layerLeft._layerList._heroData[#self._layerLeft._layerList._heroData + 1] = t1[i]
    end

    for k, v in pairs(self._layerLeft._layerList._heroData) do
        print(v.id)
    end

    -- local ts2, ts1, t0, t1, t2 = {}, {}, {}, {}, {}
    -- for k, v in pairs(data) do
    --     repeat
    --         if self:isLoaded(NewFormationView.kGridTypeHero, tonumber(k)) then break end
    --         if not self:isFiltered(tonumber(k)) then
    --             v.id = tonumber(k)
    --             if self:isDoubleHeroHelp(tonumber(k)) then
    --                 table.insert(ts2, v)
    --             elseif self:isHeroHelp(tonumber(k)) then
    --                 table.insert(ts1, v)
    --             elseif self:isNextHeroHelp(tonumber(k)) then
    --                 table.insert(t0, v)
    --             else
    --                 table.insert(t1, v)
    --             end
    --         else
    --             v.id = tonumber(k)
    --             table.insert(t2, v)
    --         end
    --     until true
    -- end

    -- table.sort(ts2, function(a, b)
    --     return a.score > b.score
    -- end)

    -- table.sort(ts1, function(a, b)
    --     return a.score > b.score
    -- end)

    -- table.sort(t0, function(a, b)
    --     return a.score > b.score
    -- end)

    -- table.sort(t1, function(a, b)
    --     return a.score > b.score
    -- end)

    -- table.sort(t2, function(a, b)
    --     return a.score > b.score
    -- end)

    -- for i = 1, #ts2 do
    --     self._layerLeft._layerList._heroData[#self._layerLeft._layerList._heroData + 1] = ts2[i]
    -- end

    -- for i = 1, #ts1 do
    --     self._layerLeft._layerList._heroData[#self._layerLeft._layerList._heroData + 1] = ts1[i]
    -- end

    -- for i = 1, #t0 do
    --     self._layerLeft._layerList._heroData[#self._layerLeft._layerList._heroData + 1] = t0[i]
    -- end

    -- for i = 1, #t1 do
    --     self._layerLeft._layerList._heroData[#self._layerLeft._layerList._heroData + 1] = t1[i]
    -- end

    -- for i = 1, #t2 do
    --     self._layerLeft._layerList._heroData[#self._layerLeft._layerList._heroData + 1] = t2[i]
    -- end
end

function NewFormationView:getTableData(iconType, iconId)
    local tableData = nil
    if iconType == NewFormationView.kGridTypeTeam then
        if self:isTeamCustom(iconId) then
            tableData = tab:Npc(iconId)
        else
            tableData = tab:Team(iconId)
        end
    else
        tableData = self._leagueModel:getMyHeroData(iconId)
    end
    return tableData
end

function NewFormationView:showItemFlag(item)
    local itemType = item:getIconType()
    local itemId = item:getIconId()

    if itemType ~= NewFormationView.kGridTypeHero then return end

    item:showDoubleHeroHelpFlag(false)
    item:showHeroHelpFlag(false)
    item:showNextHeroHelpFlag(false)

    if self:isDoubleHeroHelp(itemId) then
        return item:showDoubleHeroHelpFlag(true)
    end

    if self:isHeroHelp(itemId) then
        return item:showHeroHelpFlag(true)
    end

    if self:isNextHeroHelp(itemId) then
        return item:showNextHeroHelpFlag(true)
    end
end

function NewFormationView:itemsTableViewCellAtIndex(tableView, idx)
    local cell = tableView:dequeueCell()
    local data = self:getCurrentIconData()
    if nil == cell then
        cell = cc.TableViewCell:new()
        local item = NewFormationIconView.new({iconType = self._context._gridType[self._context._formationId], iconId = data[idx + 1].id, iconSubtype = data[idx + 1].teamSubtype, iconState = NewFormationIconView.kIconStateImage, formationType = self._formationType, isCustom = data[idx + 1].custom, container = self})
        item:setPosition(self._context._gridType[self._context._formationId] == NewFormationView.kGridTypeHero and cc.p(50, 60) or cc.p(50, 50))
        item:setTag(NewFormationView.kItemTag)
        item:showFilter(self:isFiltered(data[idx + 1].id))
        item:showRecommand(self:isRecommend(data[idx + 1].id))
        self:showItemFlag(item)
        item:updateState(NewFormationIconView.kIconStateImage, true)
        item:setName("item_"..idx)
        cell:setName("cell_"..idx)
        cell:addChild(item)
    else
        local item = cell:getChildByTag(NewFormationView.kItemTag)
        item:setIconId(data[idx + 1].id)
        item:showFilter(self:isFiltered(data[idx + 1].id))
        item:showRecommand(self:isRecommend(data[idx + 1].id))
        self:showItemFlag(item)
        item:setCustom(data[idx + 1].custom)
        item:updateState(NewFormationIconView.kIconStateImage, true)
    end
    return cell
end

function NewFormationView:applicationWillEnterForeground(second)
    local countNode = self._layerLeft._layerCountDown:getChildByFullName("leagueCountDownNode")
    local countLab 
    local countNum 
    if countNode then
        countLab = countNode:getChildByFullName("countLab")
        if countLab then
            countNum = tonumber(countLab:getString())
            if (countNum-second) > 0 then 
                countLab._forceNum = countNum-second
                countLab:setString(string.format("%02d",countNum-second))
            end
        end
    end
    if second >= 20 or (countNum and (countNum-second)<0) then
        ScheduleMgr:delayCall(1, self,function( )
            if self._viewMgr then
                if not tolua.isnull(countLab) then
                    countLab:setString(0)
                end
                if self:isSaveRequired() then
                    self:doSave(function(success)
                        if type(self._customCallBack) == "function" then
                            self._customCallBack()
                        end
                    end)
                else
                    if type(self._customCallBack) == "function" then
                        self._customCallBack()
                    end
                end
                self._viewMgr:closeHintView()
                -- self._viewMgr:popView()
                -- ViewManager:getInstance():showTip("您中途退出了游戏，本局以失败结算" or lang("TIP_LEAGUE_QUIT"))
                -- ServerManager:getInstance():onError("999724")
            end
        end)
    end
end