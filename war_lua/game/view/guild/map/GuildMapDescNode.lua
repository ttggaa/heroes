--[[
    Filename:    GuildMapDescNode.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-6-24 17:05:10
    Description: 规则说明界面
--]]

local GuildMapDescNode = class("GuildMapDescNode", BasePopView)

function GuildMapDescNode:ctor()
    GuildMapDescNode.super.ctor(self)
end

function GuildMapDescNode:onInit()
    -- local title = self:getUI("bg.bg1.titleBg.title")
    -- UIUtils:setTitleFormat(title, 1)
    -- title:setFontName(title.ttfName_Title)

    self:getUI("bg.bg1"):loadTexture("asset/bg/activity_bg_paper.png")
    
    self._cellItem = self:getUI("itemCell")
    self._cellItem:setVisible(false)
    self._cellItem:setAnchorPoint(cc.p(0,0))

    local tab1 = self:getUI("bg.bg1.tab1")  --基础
    local tab2 = self:getUI("bg.bg1.tab2")  --个人 
    local tab3 = self:getUI("bg.bg1.tab3")  --联盟
    local tab4 = self:getUI("bg.bg1.tab4")  --争夺
    tab1:getChildByName("icon"):loadTexture("guild_map_tujian_1.png", 1)
    tab2:getChildByName("icon"):loadTexture("guild_map_tujian_9.png", 1)
    tab3:getChildByName("icon"):loadTexture("guild_map_tujian_17.png", 1)
    tab4:getChildByName("icon"):loadTexture("guild_map_tujian_21.png", 1)
    tab1:setScaleAnim(false)
    tab2:setScaleAnim(false)
    tab3:setScaleAnim(false)
    tab4:setScaleAnim(false)
    tab1.type = 1
    tab2.type = 2
    tab3.type = 3
    tab4.type = 4

    self._btnList = {}
    table.insert(self._btnList, tab1)
    table.insert(self._btnList, tab2)  
    table.insert(self._btnList, tab3)
    table.insert(self._btnList, tab4)
    for k,v in pairs(self._btnList) do
        local iconName = v:getChildByName("name")
        iconName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end

    self:registerClickEvent(tab1, function(sender) self:tabButtonClick(sender) end)
    self:registerClickEvent(tab2, function(sender) self:tabButtonClick(sender) end)
    self:registerClickEvent(tab3, function(sender) self:tabButtonClick(sender) end)
    self:registerClickEvent(tab4, function(sender) self:tabButtonClick(sender) end)

    -- UIUtils:setTabChangeAnimEnable(tab1,-39,handler(self, self.tabButtonClick))
    -- UIUtils:setTabChangeAnimEnable(tab2,-39,handler(self, self.tabButtonClick))
    -- UIUtils:setTabChangeAnimEnable(tab3,-39,handler(self, self.tabButtonClick))
    -- UIUtils:setTabChangeAnimEnable(tab4,-39,handler(self, self.tabButtonClick))
    
    --整理数据
    self._data = {}
    for i,v in ipairs(clone(tab.guildMapTujian)) do
        if not self._data[v["type"]] then
            self._data[v["type"]] = {}
        end
        v.revertType = 1   --1图标 2描述 【翻转当前状态】
        table.insert(self._data[v["type"]], v)
    end
    
    -- dump(self._data, "tujian")

    self:registerClickEventByName("bg.bg1.closeBtn", function ()   
        self:close()
        UIUtils:reloadLuaFile("guild.map.GuildMapDescNode")
    end)

    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 

        elseif eventType == "enter" then
            local tab1 = self:getUI("bg.bg1.tab1")  --基础
            self:tabButtonClick(tab1)
        end
    end)
end

function GuildMapDescNode:tabButtonClick(sender)
    if sender == nil then
        return
    end
    self._curChannel = sender.type
   
    --页签切换
    self:setBtnState(sender)

    --重置翻页状态
    for i,v in pairs(self._data[self._curChannel]) do
        v["revertType"] = 1
    end

    self:getUI("bg.bg1.tips.des1"):setString(lang("GUILDMAP_RULE_" .. self._curChannel .. "_1"))
    self:getUI("bg.bg1.tips.des2"):setString(lang("GUILDMAP_RULE_" .. self._curChannel .. "_2"))
    self:getUI("bg.bg1.tips.des3"):setString(lang("GUILDMAP_RULE_" .. self._curChannel .. "_3"))

    if self._tableView ~= nil then 
        self._tableView:removeFromParent()
        self._tableView = nil
    end

    local tableBg = self:getUI("bg.bg1.tableBg")
    self._tableView = cc.TableView:create(cc.size(tableBg:getContentSize().width - 8 , tableBg:getContentSize().height - 0))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self._tableView:setPosition(cc.p(4, 0))
    self._tableView:setDelegate()
    self._tableView:setBounceable(true) 
    self._tableView:setHorizontalFillOrder(cc.TABLEVIEW_FILL_LEFTRIGHT)
    self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(function(table, cell ) return self:tableCellWillRecycle(table,cell) end ,cc.TABLECELL_WILL_RECYCLE)
    tableBg:addChild(self._tableView)
    if self._tableView.setDragSlideable ~= nil then 
        self._tableView:setDragSlideable(true)
    end
    self._tableView:reloadData()
end

function GuildMapDescNode:setBtnState(sender)
    for k,v in pairs(self._btnList) do
        v:setBright(true)
        v:setEnabled(true)
    end
    sender:setBright(false)
    sender:setEnabled(false)


    -- for k,v in pairs(self._btnList) do
    --     if v ~= sender then 
    --         local text = v:getTitleRenderer()
    --         v:setTitleColor(UIUtils.colorTable.ccUITabColor1)
    --         text:disableEffect()
    --         v:setScaleAnim(false)
    --         v:stopAllActions()
    --         if v:getChildByName("changeBtnStatusAnim") then 
    --             v:getChildByName("changeBtnStatusAnim"):removeFromParent()
    --         end
    --         v:setBright(true)
    --         v:setEnabled(true)

    --         if ( self._preBtn and self._preBtn == v) then
    --             UIUtils:tabChangeAnim(self._preBtn,nil,true)
    --         end
    --     end
    -- end

    -- self._preBtn = sender
    -- UIUtils:tabChangeAnim(sender,function( )
    --     local text = sender:getTitleRenderer()
    --     text:disableEffect()
    --     sender:setTitleColor(UIUtils.colorTable.ccUITabColor2)
    --     sender:setBright(false)
    --     sender:setEnabled(false)
    -- end)
end

function GuildMapDescNode:scrollViewDidScroll(view)
end

function GuildMapDescNode:cellSizeForTable(table,idx)
    return 298, 162  --298/163
end

function GuildMapDescNode:tableCellWillRecycle(table,cell)
end

function GuildMapDescNode:numberOfCellsInTableView(table)
    return #self._data[self._curChannel]
end

function GuildMapDescNode:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    end

    if cell._item == nil then
        local cellItem= self:createCell(cell, idx)
        cellItem:setPosition(0, 0)
        cell._item = cellItem
        cell:addChild(cellItem)
    else
        cell._item:setVisible(true)
        cell._item:setTouchEnabled(true)
        cell._item:setSwallowTouches(false)
        self:updateCell(cell._item, idx)
    end
    

    return cell
end

function GuildMapDescNode:createCell(cell, idx)
    local cellData = inData or self._data[self._curChannel][idx + 1]
    --item
    local item = self._cellItem:clone()
    item:setVisible(true)
    item:setTouchEnabled(true)
    item:setSwallowTouches(false)
   
    return self:updateCell(item, idx)
end

function GuildMapDescNode:updateCell(item, idx)
    local cellData = self._data[self._curChannel][idx + 1]
    --翻转
    registerTouchEvent(item,    
        function(_, _x, _y)
            self._vPosX1, self.vPosY1 = _x, _y
            self._vDisX, self._vDisY = 0, 0  --cell滑动距离
        end,
        --move
        function(_, _x, _y)
            local disX, disY = math.abs(self._vPosX1 - _x), math.abs(self.vPosY1 - _y)
            if disX > self._vDisX then
                self._vDisX = disX
            end
            if disY > self._vDisY then
                self._vDisY = disY
            end
        end,
        --pop
        function(sender, _x, _y)
            if self._vDisX >= 7 or self._vDisY >= 7 then
                return
            end
            item:setTouchEnabled(false)
            self:revertCard(item, idx)
        end)

    --------------------card1
    local card1 = item:getChildByFullName("card1")
    card1:stopAllActions()
    card1:setScaleX(1)

    --icon1
    local icon1 = item:getChildByFullName("card1.icon1")
    local iconImg1 = item:getChildByFullName("card1.icon1.icon")
    iconImg1:loadTexture(cellData["pic"][1]..".jpg", 1)
    local name1 = item:getChildByFullName("card1.icon1.nameBg.name")
    name1:setString(lang(cellData["name"][1]))
    name1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    --icon2
    local icon2 = item:getChildByFullName("card1.icon2")
    local iconImg2 = item:getChildByFullName("card1.icon2.icon")
    if cellData["pic"][2] then
        iconImg2:loadTexture(cellData["pic"][2] .. ".jpg", 1)
    else
        iconImg2:loadTexture("globalImageUI6_meiyoutu.png", 1)
    end
    local name2 = item:getChildByFullName("card1.icon2.nameBg.name")
    name2:setString(lang(cellData["name"][2]) or "")

    --------------------card2
    local card2 = item:getChildByFullName("card2")
    card2:stopAllActions()
    card2:setScaleX(1)

    --title
    local title = item:getChildByFullName("card2.title")
    title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    --desc
    local desc = item:getChildByFullName("card2.desc")
    desc:setLineBreakWithoutSpace(true)
    desc:setString(lang(cellData["lang"]))

    icon1:setVisible(false)
    icon2:setVisible(false)
    card1:setVisible(false)
    card2:setVisible(false)

    if cellData["revertType"] == 1 then
        card1:setVisible(true)
    else
        card2:setVisible(true)
    end

    if #cellData["pic"] >= 2 then   
        icon1:setVisible(true)
        icon2:setVisible(true)
        icon1:setPosition(38, 192)
        icon2:setPosition(38, 57)
    else
        icon1:setVisible(true)
        icon1:setPosition(38, 116)
    end    

    return item
end

function GuildMapDescNode:revertCard(item, idx)
    --正面
    local card1 = item:getChildByFullName("card1")
    --反面
    local card2 = item:getChildByFullName("card2")
    --先
    function copy1Action(inObj)  
        inObj:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.2, 0, 1),
            cc.CallFunc:create(function()
                inObj:setVisible(false)
                end)
            ))
    end

    --后
    function copy2Action(inObj)  
        inObj:runAction(cc.Sequence:create(
            cc.CallFunc:create(function()
                inObj:setVisible(true)
                inObj:setScaleX(0)
                end),
            cc.DelayTime:create(0.2),
            cc.ScaleTo:create(0.2, 1, 1),
            cc.CallFunc:create(function()
                item:setTouchEnabled(true)
                item:setSwallowTouches(false)
                end)
            ))
    end

    local lastRevert = self._data[self._curChannel][idx + 1]["revertType"]
    if lastRevert == 1 then
        self._data[self._curChannel][idx + 1]["revertType"] = 2
        copy1Action(card1)
        copy2Action(card2)
    else
        self._data[self._curChannel][idx + 1]["revertType"] = 1
        copy1Action(card2)
        copy2Action(card1)
    end
end

return GuildMapDescNode