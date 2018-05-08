--
-- Author: <ligen@playcrab.com>
-- Date: 2016-11-08 11:18:20
--
local TreasureExchangePreview = class("TreasureExchangePreview", BasePopView)
require("game.view.treasure.TreasureConst")

function TreasureExchangePreview:ctor(param)
    TreasureExchangePreview.super.ctor(self)
    param = param or {}
    self._allOpen = param.allOpen
    self.popAnim = false

    self._comTable = {}
    self._menuTable = {}

    self._tModel = self._modelMgr:getModel("TreasureModel")

    self._selectIndex = 0
end

-- 只在宝物界面开 
-- 此方法会在关闭界面的时候卸掉资源 弹窗不适合使用该方法 慎用
function TreasureExchangePreview:getAsyncRes()
    return 
    {
        {"asset/ui/treasureshop2.plist", "asset/ui/treasureshop2.png"},
        {"asset/ui/treasure4.plist", "asset/ui/treasure4.png"},         
    }
end

function TreasureExchangePreview:getMaskOpacity()
    return 200
end

function TreasureExchangePreview:onInit()
    self._layer = self:getUI("bg.layer")

    self:registerClickEventByName("bg.closeNode.closeBtn", function()
        UIUtils:reloadLuaFile("treasure.TreasureExchangePreview")
        self.dontRemoveRes = true
        self:close()
    end )

    self._comItem = self:getUI("bg.layer.comItem")
    self._comItem:setVisible(false)

    self._menuItem = self:getUI("bg.layer.menuItem")
    self._menuItem:setVisible(false)

    self._comTableCellW = self._comItem:getContentSize().width
    self._comTableCellH = self._comItem:getContentSize().height

    self._menuTableCellW = self._menuItem:getContentSize().width
    self._menuTableCellH = self._menuItem:getContentSize().height 

    local desLabel = self:getUI("bg.layer.desLabel")
    if self._allOpen then
        desLabel:setString("小贴士：购买宝物精华可获得随机宝物散件，可用于散件进阶、激活组合宝物等")
    else
        desLabel:setString("")
    end

    for k, v in pairs(tab.comTreasure) do
        if not (self._allOpen and v.produce == 1) then
            table.insert(self._comTable, v)
            table.insert(self._menuTable, v)
        end
    end

    table.sort(self._comTable, function(a,b)
        return a.rank < b.rank
    end)

    table.sort(self._menuTable, function(a,b)
        return a.rank < b.rank
    end)

    self:addComTableView()
    self:addMenuTableView()
    self._selectComIndex = 0
    -- self._update = ScheduleMgr:regSchedule(1, self, function( )
    --     self:update()
    -- end)
end

-- 滚动完成之后回弹
function TreasureExchangePreview:update( )
    if not self._inScrolling then
        local container = self._comTableView:getContainer()
        local dir = 1
        local speed = 2
        if container and self._offsetX and self._comTable then
            local correctIdx = self._selectComIndex-1
            correctIdx = math.max(correctIdx,0)
            correctIdx = math.min(correctIdx,#self._comTable-2)
            local endPosX = -(correctIdx)*(self._comTableCellW + 48)
            endPosX = math.max(endPosX,-2855)
            local containerX = container:getPositionX()
            if not self._correctDir then
                self._correctDir = containerX > endPosX and 1 or -1
            end
            if containerX > endPosX then
                if self._correctDir == -1 then return end
                container:setPositionX(containerX-5)
            else
                if self._correctDir == 1 then return end
                container:setPositionX(containerX+5)
            end
        end
    end  
end

-- 宝物预览TableView
function TreasureExchangePreview:addComTableView()
    local tableView = cc.TableView:create(cc.size(MAX_SCREEN_WIDTH, self._comTableCellH + 10))
    tableView:setColor(cc.c3b(255,255,255))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setPosition(cc.p(-(MAX_SCREEN_WIDTH-MAX_DESIGN_WIDTH)*0.5,112))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    -- tableView:setBounceEnabled(false)
    self._layer:addChild(tableView)
    tableView:registerScriptHandler(function( view )
        return self:comTableViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)

    tableView:registerScriptHandler(function( view )
        return self:comTableViewDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)

    tableView:registerScriptHandler(function ( table,cell )
        return self:comTableCellTouched(table,cell)
    end,cc.TABLECELL_TOUCHED)

    tableView:registerScriptHandler(function( table,index )
        return self:comCellSizeForTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)

    tableView:registerScriptHandler(function ( table,index )
        return self:comTableCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)

    tableView:registerScriptHandler(function ( table )
        return self:comNumberOfCellsInTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

    tableView:reloadData()
    self._comTableView = tableView
    self:updateComCell(0)

end

function TreasureExchangePreview:comTableViewDidScroll(view)
    self._inScrolling = view:isDragging()
    
    self._offsetX = view:getContentOffset().x

    -- if self._offsetX < view:minContainerOffset().x or self._offsetX > view:maxContainerOffset().x then
    --     return
    -- end
    if self._comOffsetX == nil then
        local curIndex = math.floor((-self._offsetX) / (self._comTableCellW + 48))+1
        -- print(self._offsetX,curIndex)
        if self._offsetX >= 0 then
            curIndex = 0
        end
        if self._offsetX <= -#self._comTable*(self._comTableCellW + 48)+MAX_SCREEN_WIDTH then
            curIndex = #self._comTable-1
        end
        self:updateMenuCellIndex(curIndex)
        self:updateComCell(curIndex)
    elseif self._offsetX == self._comOffsetX then
        self._comOffsetX = nil
    end

    -- print(self._offsetX)
    if not self._inScrolling then
        view:stopScroll()
        self._correctDir = nil
        -- if not self._correctDir then
        --     local correctIdx = string.format("%.1f",(-self._offsetX) / (self._comTableCellW + 48)*0.1)
        --     correctIdx = tonumber(correctIdx)
        --     correctIdx = math.abs(correctIdx)*10
        --     local offsetPosX = (correctIdx) / (self._comTableCellW + 48)
        --     view:setContentOffsetInDuration(cc.p(offsetPosX, 0), 0.3)
        --     ScheduleMgr:delayCall(300, self, function( )
        --         self._correctDir = false
        --     end)
        -- end
    else
        self._correctDir = nil
        self:closeHintView()
    end
end

function TreasureExchangePreview:comTableViewDidZoom(view)
end

function TreasureExchangePreview:comTableCellTouched(table,cell)
end

function TreasureExchangePreview:comCellSizeForTable(table,idx) 
    return self._comTableCellH + 10,self._comTableCellW + 48
end

function TreasureExchangePreview:comTableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    -- else
    --     cell:removeAllChildren()
    end
    local item = self:createComItem(self._comTable[idx+1],idx)
    -- print("idx item",idx,item)
    item:setName("comCellItem")
    local item = cell:getChildByFullName("comCellItem")
    if not item then
        item = self:createComItem(self._comTable[idx+1],idx)
        -- print("idx item",idx,item)
        item:setName("comCellItem")
        if item then
            item:setPosition(cc.p(7, 30))
            item:setAnchorPoint(cc.p(0,0))
            cell:addChild(item)
        end
    else
        item = self:createComItem(self._comTable[idx+1],idx,item)
    end
    return cell
end

function TreasureExchangePreview:comNumberOfCellsInTableView(table)
   return #self._comTable
end

local comMcs = TreasureConst.comMcs or {
    [10] = "huanyingshengong_treasurehuanyingshengong",
    [11] = "shenshengxueping_treasureshenshengxueping",

    [22] = "fashizhijie_treasurefashizhijie",
    [21] = "moliyuanquan_treasuremoliyuanquan",

    [30] = "zuzhoukaijia_treasurezuzhoukaijia",
    [31] = "yemanzhifu_treasurezhifu",
    [32] = "guiwangdoupeng_treasureguiwangdoupeng",

    [40] = "shenglongkaijia_treasureshenglongkaijia",
    [41] = "jian_treasureicon",
    [42] = "taitanshenjian_treasuretaitanshenjian",
}
local comMcOffset =
{
    [11] = {-8,-5},
    [21] = {-8,0},
    [22] = {-5,0},
    [10] = {-12,-5},
    [32] = {-2,0},
    [30] = {-8,0},
    [31] = {0,20},
    [40] = {-5,0},
    [41] = {-3,20},
    [42] = {0,20},
}

local disPos =
{
    [3] = {{0, 140}, {-111, -91}, {111, -91}},
    [4] = {{-103, 118},{-103, -100},{103, -100},{103, 118}},
    [6] = {{-78, 142}, {-146, 14},{-78, -108},{78,-108},{146,14},{78,142}}
}

function TreasureExchangePreview:createComItem(data,idx,dirtItem)
    if data == nil then return end

    local item = dirtItem or self._comItem:clone()
    item:setVisible(true)

    local disCount = #data.form

    -- 紫色品质，组件数量为4时用中级紫底框
    if data.quality == 4 and disCount == 4 then
        item:getChildByFullName("comBg"):loadTexture("treasureshop_comBg_color" .. data.quality .. "_2.png", 1)
    else
        item:getChildByFullName("comBg"):loadTexture("treasureshop_comBg_color" .. data.quality .. ".png", 1)
    end

    local aniNode = item:getChildByFullName("aniNode")
    if data.produce == 0 then
        item:getChildByFullName("lightEffect"):setColor(UIUtils.colorTable["ccColorQuality" .. data.quality])
        UIUtils:createTreasureNameLab(data.id,nil,40,item:getChildByFullName("comName"),true)
    elseif data.produce == 1 then
        item:getChildByFullName("lightEffect"):setVisible(false)
        item:getChildByFullName("comName"):setVisible(false)
        item:getChildByFullName("unknowIcon"):setVisible(true)
        item:getChildByFullName("unknowName"):setVisible(true)
        item:getChildByFullName("comBg"):setBrightness(-40)
        item:getChildByFullName("lightMask"):setBrightness(-40)
    end

    for i=1,6 do
        local disItem = item:getChildByFullName("disItem" .. i)
        if not tolua.isnull(disItem) then
            disItem:setVisible(false)
        end
    end


    local comHasActive = true
    for i = 1, disCount do
        local itemData = tab:Tool(data.form[i])
        if itemData == nil then
            print("==================itemID 不存在=====",itemId)
        end

        local eventType = 1
        if data.produce == 1 then
            eventType = 0
        end
        local disItem = item:getChildByFullName("disItem" .. i)
        if not disItem then
            disItem = IconUtils:createItemIconById({itemId = itemData.id,num = itemNum,itemData = itemData,effect = true,treasureCircle=true, eventStyle = eventType})  --effect = true 不加特效 --treasureCircle 不加内框
            disItem:setName("disItem" .. i)
            disItem:setScale(0.9)
            item:addChild(disItem)
        else
            IconUtils:updateItemIconByView(disItem,{itemId = itemData.id,num = itemNum,itemData = itemData,effect = true,treasureCircle=true, eventStyle = eventType})
        end
        disItem:setVisible(true)
        disItem:setAnchorPoint(cc.p(0,0))
        disItem:setPosition(cc.p(disPos[disCount][i][1] + 149,disPos[disCount][i][2] + 100))

        local itemIcon = disItem:getChildByFullName("itemIcon")
        itemIcon:setScale(0.85)

	    local color = itemData.color or 2
        local boxIcon = disItem:getChildByFullName("boxIcon")
	    if boxIcon ~= nil and itemData then 
		    boxIcon:loadTexture("treasureShop_color".. color ..".png", 1)
		    boxIcon:setContentSize(cc.size(116, 117))
	    end
	    local iconColor = disItem:getChildByFullName("iconColor")
	    if iconColor then
		    iconColor:setVisible(false)
	    end

        -- 激活标签
        local activeProSp = item:getChildByFullName("activeProSp" .. i) --

        
        if data.produce == 1 then
            boxIcon:setBrightness(-50)
            itemIcon:setColor(cc.c3b(0,0,0))
            comHasActive = false

            self:registerClickEvent(disItem, function()
                self._viewMgr:showTip(lang("TIPS_ARTIFACT_08"))
            end )



        elseif not self:getHasActive(data.form[i]) then
        --            boxIcon:setColor(cc.c4b(128, 128, 128, 255))
        --            boxIcon:setSaturation(-100)
            itemIcon:setColor(cc.c4b(128, 128, 128, 255))
            itemIcon:setSaturation(-100)
            comHasActive = false
            local disProduce = tab:DisTreasure(data.form[i]).produce == 1
            if disProduce then 
                if not activeProSp then
                    activeProSp = ccui.ImageView:create()
                    -- activeProSp:setPosition(disItem:)
                    activeProSp:setName("activeProSp" .. i)
                    activeProSp:setPosition(disPos[disCount][i][1] + 195,disPos[disCount][i][2] + 150)
                    item:addChild(activeProSp,999)
                    activeProSp:setSaturation(100)
                end
                activeProSp:setVisible(true)
                activeProSp:loadTexture("treasureShop_active_" .. color .. ".png",1)
            end
        elseif activeProSp then
            activeProSp:setVisible(false)
        end


        disItem:setSwallowTouches(false)
        boxIcon:setSwallowTouches(false)
    end
    comHasActive = self:hasActiveCom(data.id)
    if comHasActive or self._allOpen then
        -- local mc = mcMgr:createViewMC(comMcs[data.id], true, false)
        -- mc:setPlaySpeed(0.25)
        -- mc:setScale(0.5)
        -- mc:setPosition(78 + comMcOffset[data.id][1], 73 + comMcOffset[data.id][2])
        -- aniNode:addChild(mc)
        local comPic = aniNode:getChildByFullName("comPic")
        if not comPic then
            comPic = ccui.ImageView:create()
            comPic:setName("comPic")
            comPic:loadTexture(data.art .. ".png",1)
            -- comPic = cc.Sprite:createWithSpriteFrameName(data.art .. ".png")
            comPic:setScale(0.6)
            comPic:setPosition(aniNode:getContentSize().width*0.5, aniNode:getContentSize().height*0.5)
            -- comPic:setSaturation(-100)
            -- comPic:setColor(cc.c4b(128, 128, 128, 255))
            aniNode:addChild(comPic)
        else
            comPic:loadTexture(data.art .. ".png",1)
        end
    else
        local comPic = aniNode:getChildByFullName("comPic")
        if not comPic then
            comPic = ccui.ImageView:create()
            comPic:setName("comPic")
            comPic:loadTexture(data.art .. ".png",1)
            -- comPic = cc.Sprite:createWithSpriteFrameName(data.art .. ".png")
            comPic:setScale(0.6)
            comPic:setPosition(aniNode:getContentSize().width*0.5, aniNode:getContentSize().height*0.5)
            -- comPic:setSaturation(-100)
            -- comPic:setColor(cc.c4b(128, 128, 128, 255))
            aniNode:addChild(comPic)
        else
            comPic:loadTexture(data.art .. ".png",1)
        end
        comPic:setScale(0.6)
        comPic:setSaturation(-100)
        comPic:setColor(cc.c4b(128, 128, 128, 255))
    end

    
    local sel = item:getChildByFullName("sel")
    if sel then
        if self._selectComIndex then
            sel:setVisible(self._selectComIndex == idx)
        else
            sel:setVisible(false)
        end
    end

    --    local icon = node:getChildByFullName("icon")
    --    local isGray = data.isGray
    --    local iconImage = icon:getChildByFullName("image")
    --    local lock = node:getChildByFullName("lock")
    --    local treasureCorner = node:getChildByFullName("treasureCorner")
    --    if isGray then
    --        -- iconImage:setSaturation(-180)
    --        icon:setColor(cc.c4b(128, 128, 128, 255))
    --        icon:setBrightness(-50)
    --        treasureCorner:setColor(cc.c4b(128, 128, 128, 255))
    --        treasureCorner:setBrightness(-50)
    --        lock:setVisible(true)
    --    else
    --        -- iconImage:setSaturation(0)
    --        icon:setColor(cc.c4b(255, 255, 255, 255))
    --        icon:setBrightness(0)
    --        treasureCorner:setColor(cc.c4b(255, 255, 255, 255))
    --        treasureCorner:setBrightness(0)
    --        lock:setVisible(false)
    --    end

    return item
end

-- 更新宝物cell
function TreasureExchangePreview:updateComCell( index )
    if self._comTableView ~= nil then
        local preIdx = self._selectComIndex or 1
        self._selectComIndex = index
        local cellPre = self._comTableView:cellAtIndex(preIdx)
        if cellPre then
            local item = cellPre:getChildByFullName("comCellItem")
            if item then
                local sel = item:getChildByFullName("sel")
                if sel then
                    sel:setVisible(false)
                end
            end
        end
        local cellNow = self._comTableView:cellAtIndex(index)
        -- print(debug.traceback())
        if cellNow then
            local item = cellNow:getChildByFullName("comCellItem")
            if item then
                local sel = item:getChildByFullName("sel")
                if sel then
                    sel:setVisible(true)
                end
            end
        end
    end
end


-- 宝物菜单TableView
function TreasureExchangePreview:addMenuTableView()
    local tableView = cc.TableView:create(cc.size(796, 60))
    tableView:setColor(cc.c3b(255,255,255))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setPosition(cc.p(4, 5))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(false)
    self._layer:getChildByFullName("menuBg"):addChild(tableView)
    tableView:registerScriptHandler(function( view )
        return self:menuTableViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)

    tableView:registerScriptHandler(function( view )
        return self:menuTableViewDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)

    tableView:registerScriptHandler(function ( table,cell )
        return self:menuTableCellTouched(table,cell)
    end,cc.TABLECELL_TOUCHED)

    tableView:registerScriptHandler(function( table,index )
        return self:menuCellSizeForTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)

    tableView:registerScriptHandler(function ( table,index )
        return self:menuTableCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)

    tableView:registerScriptHandler(function ( table )
        return self:menuNumberOfCellsInTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

    tableView:reloadData()
    self._menuTableView = tableView
    self:updateMenuCellIndex(0)

end

function TreasureExchangePreview:menuTableViewDidScroll(view)
    self._inScrolling = view:isDragging()
    
    self._offsetX = view:getContentOffset().x
    self._offsetY = view:getContentOffset().y
    -- print("====================view:getContentOffset().y---------",view:getContentOffset().y)
end

function TreasureExchangePreview:menuTableViewDidZoom(view)
end

function TreasureExchangePreview:menuTableCellTouched(table,cell)
end

function TreasureExchangePreview:menuCellSizeForTable(table,idx) 
    return self._menuTableCellH + 3,self._menuTableCellW + 26
end

function TreasureExchangePreview:menuTableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end
    local item = self:createMenuItem(self._menuTable[idx+1], idx)
    -- print("idx item",idx,item)
    if item then
        item:setPosition(cc.p(0, 0))
        item:setAnchorPoint(cc.p(0,0))
        cell:addChild(item)
    end
    return cell
end

function TreasureExchangePreview:menuNumberOfCellsInTableView(table)
    -- print("table num...",#self._tableData)
   return #self._menuTable
end

function TreasureExchangePreview:createMenuItem(data, idx)
    if data == nil then  return end

    local item = self._menuItem:clone()
    item:setVisible(true)

    item:getChildByFullName("comMenuIcon"):loadTexture("treasureshop_" .. data.art .. ".png", 1)

    if idx ~= self._selectIndex then
        item:getChildByFullName("selectBound"):setVisible(false)
    else
        item:getChildByFullName("selectBound"):setVisible(true)
    end

    local isActive = false
    -- 注销 改成组合宝物激活才算 2017.2.2 
    -- for i = 1, #data.form do
    --     if self:getHasActive(data.form[i]) and data.produce == 0  then
    --         item:getChildByFullName("comMenuIcon"):setColor(cc.c3b(255,155,48))
    --         isActive = true
    --     end
    -- end
    if self:hasActiveCom(data.id) then
        isActive = true
        -- print("isActive com .?",data.id)
        item:getChildByFullName("comMenuIcon"):setColor(cc.c3b(255,155,48))
    end

    if not isActive then
        item:getChildByFullName("comMenuIcon"):setColor(cc.c3b(104,104,104))
    end

    if data.produce == 1 then
        item:getChildByFullName("unknowIcon"):setVisible(true)
    end

    self:registerClickEvent(item, function()
        self._comTableView:stopScroll()
        local offsetX = -idx*(self._comTableCellW + 48)
        if idx ~= 0 then
            offsetX = offsetX+self._comTableCellW + 48
        end
        if idx == #self._comTable then
            offsetX = offsetX+self._comTableCellW + 48
        end

        local minX = self._comTableView:minContainerOffset().x
        local maxX = self._comTableView:maxContainerOffset().x 
        offsetX = offsetX < minX and minX or offsetX
        offsetX = offsetX < maxX and offsetX or maxX
        self._comOffsetX = offsetX

        if self._comOffsetX ~= self._comTableView:getContentOffset().x then
            local maxDistance = -5000 -- 偏移最大值容错 增加宝物需要改数值现在支持13个
            self._comTableView:setContentOffsetInDuration(cc.p(math.max(offsetX,maxDistance), 0), 0.3)
        end

        --        item:getChildByFullName("selectBound"):setVisible(true)
        --        local curIndex = self._selectIndex
        --        self._selectIndex = idx
        --        self._menuTableView:updateCellAtIndex(curIndex)
        self:updateMenuCellIndex(idx)
        self:updateComCell(idx)
    end)
    return item
end

function TreasureExchangePreview:updateMenuCellIndex(index)
    if self._menuTableView ~= nil then
        local curIndex = self._selectIndex
        self._selectIndex = index
        self._menuTableView:updateCellAtIndex(curIndex)
        self._menuTableView:updateCellAtIndex(self._selectIndex)
    end
end

function TreasureExchangePreview:getHasActive(disId)
    local _, count = self._modelMgr:getModel("ItemModel"):getItemsById(disId)
    local disProduce = tab:DisTreasure(disId).produce
    local disTInfo = self._tModel:getTreasureById(tostring(disId))
    if (((disTInfo and disTInfo.s > 0 ) or count > 0) and disProduce == 1) or disProduce ~= 1 or self._allOpen then
        return true
    else
        return false
    end
end

function TreasureExchangePreview:hasActiveCom( comId )
    local comTreasureInfo = self._modelMgr:getModel("TreasureModel"):getTreasureById(comId)
    -- dump(comTreasureInfo,comId)
    local comData = tab.comTreasure[comId]
    local form = comData.form 
    if not form then return false end
    local isProduceOpen
    for k,v in pairs(form) do
        if self:getHasActive(v) then
            isProduceOpen = true 
            break
        end
    end
    return self._allOpen or isProduceOpen or (comTreasureInfo and comTreasureInfo.stage > 0)
end
return TreasureExchangePreview