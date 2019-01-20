--[[
    Filename:    GlobalSelectAwardDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-01-19 11:57:06
    Description: File description
--]]

-- 物品多选1
local GlobalSelectAwardDialog = class("GlobalSelectAwardDialog", BasePopView)

function GlobalSelectAwardDialog:ctor(param)
    GlobalSelectAwardDialog.super.ctor(self)
    self._gift = param.gift
    self._callback = param.callback
    self._selectItem = 0
end

function GlobalSelectAwardDialog:onInit()
    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)

    -- self._gift = clone(tab:Setting("G_FIRST_RECHARGE").value)
    -- self._gift[1] = self._gift[2]
    -- self._gift[2] = self._gift[3]
    -- self._gift[3] = self._gift[4]
    -- self._gift[4] = self._gift[3]
    -- self._gift[5] = self._gift[3]
    -- self._gift[6] = self._gift[3]

    self:registerClickEventByName("bg.closeBtn", function ()
        UIUtils:reloadLuaFile("global.GlobalSelectAwardDialog")
        self:close()
    end)

    local determineBtn = self:getUI("bg.determineBtn")
    self:registerClickEvent(determineBtn, function()
        if self._selectItem == 0 then
            self._viewMgr:showTip("领主大人请先选择您的奖励哦~")
            return
        end
        if self._callback then
            self._callback(self._selectItem)
        end
        self:close()
    end)
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._treasureModel = self._modelMgr:getModel("TreasureModel")


    dump(self._gift, "data ===", 10)
    self._itemCell = self:getUI("itemCell")
    self._itemCell:setVisible(false)

    self:addTableView()
end

function GlobalSelectAwardDialog:reflashUI(data)
    if not self._gift then
        return
    end

    self._tableView:reloadData()
end



--[[
用tableview实现
--]]
function GlobalSelectAwardDialog:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(true)
    
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    tableViewBg:addChild(self._tableView)
end


-- 触摸时调用
function GlobalSelectAwardDialog:tableCellTouched(table,cell)

end

-- cell的尺寸大小
function GlobalSelectAwardDialog:cellSizeForTable(table,idx) 
    local width = 380 
    local height = 80
    return height, width
end

-- 创建在某个位置的cell
function GlobalSelectAwardDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local param = self._gift[idx + 1] -- {typeId = 3, id = 1}
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local itemCell = self._itemCell:clone()
        itemCell:setAnchorPoint(cc.p(0,0))
        itemCell:setPosition(cc.p(0,0))
        itemCell:setVisible(true)
        itemCell:setName("itemCell")
        cell:addChild(itemCell)

        self:updateCell(itemCell, param, indexId)
        itemCell:setSwallowTouches(false)
    else
        local itemCell = cell:getChildByName("itemCell")
        if itemCell then
            self:updateCell(itemCell, param, indexId)
            itemCell:setSwallowTouches(false)
        end
    end
    return cell
end

-- 返回cell的数量
function GlobalSelectAwardDialog:numberOfCellsInTableView(table)
    return self:tableNum() 
end

function GlobalSelectAwardDialog:tableNum()
    return table.nums(self._gift)
end

function GlobalSelectAwardDialog:updateCell(inView, data, indexId)
    if data == nil then
        return
    end

    local itemId
    local teamId
    local heroId
    local frameId
    local runeId
    local num
    local starlevel 
    if data[1] == "tool" then
        itemId = data[2]
        num = data[3]
    elseif data[1] == "team" then 
        teamId = data[2]
        num = data[3]
        starlevel = data[4]
    elseif data[1] == "hero" then
        heroId = data[2]
        num = data[3]
    elseif data[1] == "avatarFrame" then
        frameId = data[2]
        num = data[3]
    elseif data[1] == "rune" then
        runeId = data[2]
        num = data[3]
    else
        itemId = IconUtils.iconIdMap[data[1]]
        num = data[3]
    end
    local isDisTreasure = false
    if itemId and tab:DisTreasure(itemId) then
        isDisTreasure = true
    end
    print(" isDisTreasure  ",tostring(isDisTreasure))
    local itemIcon = inView:getChildByName("itemIcon")
    local teamIcon = inView:getChildByName("teamIcon")
    local heroIcon = inView:getChildByName("heroIcon")
    local frameIcon = inView:getChildByName("frameIcon")
    local runeIcon = inView:getChildByName("runeIcon")
    if itemIcon then
        itemIcon:setVisible(false)
    end
    if teamIcon then
        teamIcon:setVisible(false)
    end
    if heroIcon then
        heroIcon:setVisible(false)
    end
    if frameIcon then
        frameIcon:setVisible(false)
    end
    if runeIcon then
        runeIcon:setVisible(false)
    end

    if itemId then
        local param = {itemId = itemId, effect = true, eventStyle = 0, num = num}
        if itemIcon then
            IconUtils:updateItemIconByView(itemIcon, param)
        else
            itemIcon = IconUtils:createItemIconById(param)
            itemIcon:setName("itemIcon")
            local itemNormalScale = 65/itemIcon:getContentSize().width
            itemIcon:setScale(itemNormalScale)
            itemIcon:setPosition(10, 5)
            inView:addChild(itemIcon)
        end
        itemIcon:setVisible(true)
    elseif teamId then
        local sysTeamData = clone(tab.team[teamId])
        if starlevel ~= nil  then 
            sysTeamData.starlevel = starlevel
        end
        local param = {sysTeamData = sysTeamData, effect = true, eventStyle = 0, isJin = true}
        if teamIcon then
            IconUtils:updateSysTeamIconByView(teamIcon, param)
        else
            teamIcon = IconUtils:createSysTeamIconById(param)
            teamIcon:setName("teamIcon")
            local itemNormalScale = 65/teamIcon:getContentSize().width
            teamIcon:setScale(itemNormalScale)
            teamIcon:setPosition(10, 5)
            inView:addChild(teamIcon)
        end
        teamIcon:setVisible(true)
    elseif heroId then
        local sysHeroData = tab:Hero(heroId)
        local param = {sysHeroData = sysHeroData, effect = false}
        if heroIcon then
            IconUtils:updateHeroIconByView(heroIcon, param)
            heroIcon:getChildByName("starBg"):setVisible(false)
            -- heroIcon:getChildByName("iconStar"):setVisible(false)
        else
            heroIcon = IconUtils:createHeroIconById(param)
            heroIcon:setName("heroIcon")
            local itemNormalScale = 67/heroIcon:getContentSize().width
            heroIcon:setScale(itemNormalScale)
            heroIcon:setPosition(43,38)
            inView:addChild(heroIcon)
            heroIcon:getChildByName("starBg"):setVisible(false)
            -- heroIcon:getChildByName("iconStar"):setVisible(false)
        end
        heroIcon:setVisible(true)
    elseif frameId then
        local frameData = tab:AvatarFrame(frameId)
        param = {itemId = frameId, itemData = frameData}
        local frameIcon = inView:getChildByName("frameIcon")
        if frameIcon then
            IconUtils:updateHeadFrameIcon(frameIcon, param)
        else
            frameIcon = IconUtils:createHeadFrameIconById(param)
            frameIcon:setName("frameIcon")
            local itemNormalScale = 65/frameIcon:getContentSize().width
            frameIcon:setScale(itemNormalScale)
            frameIcon:setPosition(10, 5)
            inView:addChild(frameIcon)
        end
        frameIcon:setVisible(true)
    elseif runeId then
        local runeData = tab:Rune(runeId)

        local runeIcon = inView:getChildByName("runeIcon")
        if runeIcon then
            IconUtils:updateHolyIcon(runeIcon, {suitData = runeData,num = num})
        else
            runeIcon = IconUtils:createHolyIconById({suitData = runeData,num = num})
            runeIcon:setName("runeIcon")
            local itemNormalScale = 70/runeIcon:getContentSize().width
            runeIcon:setScale(itemNormalScale)
            runeIcon:setPosition(8, 5)
            inView:addChild(runeIcon)
        end
        runeIcon:setVisible(true)
    end
    -- 名字
    local itemTab = tab:Tool(itemId) 
                    or tab:Team(teamId) 
                    or tab:Hero(heroId) 
                    or tab:AvatarFrame(frameId)
                    or tab:Rune(runeId)
    if not itemTab then
        return
    end

    local tname = inView:getChildByFullName("tname")
    if tname then
        tname:setString(lang(itemTab.name))
        if heroId then
            tname:setString(lang(itemTab.heroname))
        end
        local tColor = ItemUtils.findResIconColor(itemId, num)
        if runeId then
            tColor = itemTab.quality
        end
        tname:setColor(UIUtils.colorTable["ccColorQuality" .. tColor])
        tname:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        tname:setLineBreakWithoutSpace(true)
    end
    local tnum = inView:getChildByFullName("tnum")
    local iconStage = inView:getChildByName("iconStage")
    if iconStage then
        iconStage:removeFromParent()
        iconStage = nil
    end

    if data[1] == "tool" or data[1] == "rune" then
        tname:setPositionY(55)
        tnum:setVisible(true)
        if tnum then
            local _ , nums
            print(" itemId ",itemId)
            if itemId then
                _ , nums = self._itemModel:getItemsById(itemId)
            elseif runeId then
                _ , nums = self._teamModel:getRunesById(runeId)
            end
            tnum:setColor(cc.c4b(140, 92, 48, 255))
            if isDisTreasure then
                local disTreasureData = tab:DisTreasure(itemId)
                local comId = self._treasureModel:getComIdByDisId(itemId)
                local ComInfo = self._treasureModel:getComTreasureById(comId)
                dump(ComInfo)
                local stage = (ComInfo and ComInfo.treasureDev) and ComInfo.treasureDev[tostring(itemId)].s or 0
                local need = tab:DevDisTreasure(stage) and tab:DevDisTreasure(stage).treasureNum or 0
                local iconStage = ccui.ImageView:create()
                iconStage:setName("iconStage")
                iconStage:loadTexture("globalImageUI4_iquality" .. (disTreasureData.quality or 2) ..".png",1)
                iconStage:setAnchorPoint(cc.p(0,1))
                iconStage:setPosition(80,40)
                inView:addChild(iconStage,100)

                local stageTxt = ccui.Text:create()
                stageTxt:setString("+" .. stage)
                stageTxt:setFontName(UIUtils.ttfName)
                if tonumber(stage) < 10 then
                    stageTxt:setFontSize(20)
                else
                    stageTxt:setFontSize(18)
                end
                stageTxt:setColor(UIUtils.colorTable.ccUIBaseColor1)
                stageTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
                stageTxt:setAnchorPoint(cc.p(0.5,0.5))
                stageTxt:setPosition(iconStage:getContentSize().width/2, iconStage:getContentSize().height/2+2)
                iconStage:addChild(stageTxt,1)
                local x = iconStage ~= nil and iconStage:getPositionX() + 36 or 84
                tnum:setPositionX(x)
                local needNum = (need == 0 and stage > 0) and "--" or need
                if stage == 0 then needNum = 1 end   --未激活默认显示1
                tnum:setString("("..nums.."/"..needNum..")")
                if nums >= need and stage < 20 and nums ~= 0 then
                    tnum:setColor(UIUtils.colorTable["ccUIBaseColor9"])
                end
            else
                tnum:setString("已拥有:".. nums)
            end
        end
    else
        tname:setPositionY(38)
        tnum:setVisible(false)
    end
    
    local selectBg = inView:getChildByFullName("selectBg")
    local pitch = inView:getChildByFullName("selectBg.pitch")
    if pitch then
        if self._selectItem == indexId then
            pitch:setVisible(true)
        else
            pitch:setVisible(false)
        end
    end
    if selectBg then
        self:registerClickEvent(selectBg, function()
            self._selectItem = indexId
            self:reloadData()
        end)
    end
end

function GlobalSelectAwardDialog:reloadData()
    local offset = self._tableView:getContentOffset()
    self._tableView:reloadData()
    self._tableView:setContentOffset(offset, false)
end

return GlobalSelectAwardDialog