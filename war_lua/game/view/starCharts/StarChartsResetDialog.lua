--[[
    @FileName   StarChartsResetDialog.lua
    @Authors    cuiyake
    @Date       2018-03-22 10:59:42
    @Email      <cuiyake@playcrad.com>
    @Description   星图重置UI
--]]

local StarChartsResetDialog = class("StarChartsResetDialog",BasePopView)
function StarChartsResetDialog:ctor(params)
    self.super.ctor(self)
    self._parent = params.container
    self._heroId = params.heroId
    self._starInfo = self._modelMgr:getModel("StarChartsModel"):getStarInfo()
    self._starChartsModel = self._modelMgr:getModel("StarChartsModel")
end

-- 初始化UI后会调用, 有需要请覆盖
function StarChartsResetDialog:onInit()
    -- self:registerScriptHandler(function (state)
    --     if state == "exit" then
    --         UIUtils:reloadLuaFile("starCharts.StarChartsResetDialog")
    --     end
    -- end)

    --关闭按钮
    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("starCharts.StarChartsResetDialog")
    end)
    self._title = self:getUI("bg.title")
    self._resetDesc = self:getUI("bg.resetDesc")
    self._returnDesc = self:getUI("bg.returnDesc")
    self._resPanel = self:getUI("bg.resPanel")
    self._goldimg = self:getUI("bg.goldimg")
    self._goldLab = self:getUI("bg.goldLab")
    self._resetBtn = self:getUI("bg.resetBtn")
    self:registerClickEvent(self._resetBtn, function ()
        if self._parent:checkCondition(self._costTable[3]) == false then
            return
        end
        self._serverMgr:sendMsg("StarChartsServer", "reset", {heroId = self._heroId}, true, {}, function(result, success) 
        
            dump(result)
            self:close()
    
        end)
    end)

    self._awardTable = self:getResetTable()
    --self._awardTable = {{"soulStar",0,20}}
    --dump(self._awardTable)
    self._costTable = self:getCostTable()[1]
    if self._costTable ~= nil then
        local itemType = self._costTable[1]
        local itemId = self._costTable[2]
        local itemNum = self._costTable[3]
        local iconRes = IconUtils.resImgMap[itemType]
        if iconRes and iconRes ~= "" then
            self._goldimg:loadTexture(iconRes,1)
            self._goldimg:setScale(1.0)
        end
        self._goldLab:setString(itemNum)
    end
    

    self._starSoulNum = self:getSatrSoulNum()
    self:createTableView()

end

-- 第一次进入调用, 有需要请覆盖
function StarChartsResetDialog:onShow()

end

-- 接收自定义消息
function StarChartsResetDialog:reflashUI(data)
    
    
end

function StarChartsResetDialog:getResetTable()
    if not self._starChartsModel:checkStarListOrNull() then return nil end
    local resetSoulNum = self:getSatrSoulNum();
    local tempAwardTable = {{"soulStar",0,resetSoulNum}}
    local activedTable = self._starInfo["ssIds"]
    local addResetAward = function(awardTable)
        local itemType = awardTable[1]
        local itemId = awardTable[2]
        local itemNum = awardTable[3]
        local count = 0
        for k,tData in pairs(tempAwardTable) do
            if itemType == tData[1] and itemId == tData[2] then
                tData[3] = tData[3] + itemNum
                return
            end
        end
        table.insert(tempAwardTable,awardTable)
    end
    -- dump(activedTable)
    for starid , data in pairs(activedTable) do 
        local resetTable = clone(tab.starChartsStars[tonumber(starid)]["resetting"])
        -- dump(resetTable,"----resetTable------")
        if resetTable ~= nil then
            for _,aData in pairs(resetTable) do
                addResetAward(aData)
            end
        end
    end 
    return tempAwardTable
end

function StarChartsResetDialog:getCostTable()
    if not self._starChartsModel:checkStarListOrNull() then return nil end
    local tempCostTable = {}
    local activedTable = self._starInfo["ssIds"]
    local addCost = function(costData)
        local itemType = costData[1]
        local itemId = costData[2]
        local itemNum = costData[3]
        local count = 0
        for k,tData in pairs(tempCostTable) do
            if itemType == tData[1] and itemId == tData[2] then
                tData[3] = tData[3] + itemNum
                return
            end
        end
        table.insert(tempCostTable,costData)
    end
    -- dump(activedTable)
    for starid , data in pairs(activedTable) do 
        local costTable = clone(tab.starChartsStars[tonumber(starid)]["resetting_cost"])
        -- dump(resetTable,"----resetTable------")
        if costTable ~= nil then
            for _,cData in pairs(costTable) do
                addCost(cData)
            end
        end
    end 
    return tempCostTable
end

function StarChartsResetDialog:getSatrSoulNum()
    if not self._starChartsModel:checkStarListOrNull() then return nil end
    local starSoulNum = 0
    local activedTable = self._starInfo["ssIds"]
    for starid , data in pairs(activedTable) do 
        local soulNum = clone(tab.starChartsStars[tonumber(starid)]["cost1"])
        -- dump(resetTable,"----resetTable------")
        if soulNum ~= nil then
            starSoulNum = starSoulNum + soulNum
        end
    end 
    return starSoulNum
end

function StarChartsResetDialog:funcname(args)

end

function StarChartsResetDialog:createTableView()
    local tableViewWidth = self._resPanel:getContentSize().width
    local tableViewHeight = self._resPanel:getContentSize().height

    local tableView = cc.TableView:create(cc.size(tableViewWidth, tableViewHeight))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setPosition(0,0)
    tableView:setDelegate()
    tableView:setBounceable(true)
    self._resPanel:addChild(tableView,999)
 
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(function ( table,cell )
        return self:tableCellTouched(table,cell)
    end ,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( table,index )
        return self:cellSizeForTable(table,index)
    end ,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index )
        return self:tableCellAtIndex(table,index)
    end ,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function (view)
        return self:numberOfCellsInTableView(view)
    end ,cc.NUMBER_OF_CELLS_IN_TABLEVIEW) 
    tableView:reloadData()
    self._tableView = tableView
end

function StarChartsResetDialog:scrollViewDidScroll(view)
    print("scrollViewDidScroll")
end

function StarChartsResetDialog:scrollViewDidZoom(view)
    print("scrollViewDidZoom")
end

function StarChartsResetDialog:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function StarChartsResetDialog:cellSizeForTable(table,idx) 
    return 90,90
end

function StarChartsResetDialog:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    print("-------------strValue------------" .. strValue)

    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end
    
    if self._awardTable ~= nil then
        local cellData = self._awardTable[idx + 1]
        local item = self:createItem(cellData)
        item:setPosition(0,self._resPanel:getContentSize().height / 2)
        item:setAnchorPoint(cc.p(0,0.5))
        cell:addChild(item)
    end
    

    --[[local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
        local sprite = cc.Sprite:createWithSpriteFrameName("starCharts_common.png")
        sprite:setAnchorPoint(cc.p(0,0))
        sprite:setPosition(cc.p(0, 0))
        cell:addChild(sprite)

        label = cc.Label:createWithSystemFont(strValue, "Helvetica", 20.0)
        label:setPosition(cc.p(0,0))
        label:setAnchorPoint(cc.p(0,0))
        label:setTag(123)
        cell:addChild(label)
    else
        label = cell:getChildByTag(123)
        if nil ~= label then
            label:setString(strValue)
        end
    end]]

    return cell
end

function StarChartsResetDialog:numberOfCellsInTableView(view)
   return #self._awardTable
end

function StarChartsResetDialog:createItem( data )
    if data == nil then return end  
  
    local itemIcon = nil
    local itemType = data[1]
    local itemId = data[2]
    local itemNum = data[3]
    local eventStyle = 1 --{itemId = itemId, num = num,eventStyle = 0} 
    if itemType == "hero" then
        local heroData = clone(tab:Hero(itemId))
        itemIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
        --itemIcon:getChildByName("starBg"):setVisible(false)
        for i=1,6 do
            if itemIcon:getChildByName("star" .. i) then
                itemIcon:getChildByName("star" .. i):setPositionY(itemIcon:getChildByName("star" .. i):getPositionY() + 5)
            end
        end

        registerClickEvent(itemIcon, function()
            local NewFormationIconView = require "game.view.formation.NewFormationIconView"
            self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = itemId}, true)
        end)
    elseif itemType == "team" then
        local teamTeam = clone(tab:Team(itemId))
        itemIcon = IconUtils:createSysTeamIconById({sysTeamData = teamTeam,isJin=true})
       
    elseif itemType == "avatarFrame" then
        local frameData = tab:AvatarFrame(itemId)
        param = {itemId = itemId, itemData = frameData}
        itemIcon = IconUtils:createHeadFrameIconById(param)
    elseif itemType == "siegeProp" then
        local propsTab = tab:SiegeEquip(itemId)
        local param = {itemId = itemId, level = 1, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 1}
        itemIcon = IconUtils:createWeaponsBagItemIcon(param)
    else
        if itemType ~= "tool" then
            itemId = IconUtils.iconIdMap[itemType]
        end
        
        if itemType == "soulStar" then
            itemIcon = IconUtils:createItemIconById({itemId = itemId,hideTipNum = true, num =itemNum ,eventStyle = eventStyle})
        else
            itemIcon = IconUtils:createItemIconById({itemId = itemId, num = itemNum,eventStyle = eventStyle})
        end
        
    end

    local scale = 0.71
    if itemType == "team" or itemType == "hero" then
        scale = 0.61
    elseif itemType == "avatarFrame" then
        scale = 0.58
    end
    itemIcon:setScale(scale)
    itemIcon:setAnchorPoint(0.5,0.5)

    return itemIcon
end


return StarChartsResetDialog