--[[
    Filename:    HeroDuelAwardView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-2-8 10:50
    Description: 英雄交锋奖励界面
--]]

local HeroDuelAwardView = class("HeroDuelAwardView", BasePopView)

function HeroDuelAwardView:ctor(param)
	HeroDuelAwardView.super.ctor(self)

    self._hModel = self._modelMgr:getModel("HeroDuelModel")
    self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")

    self._data = param.data
    self._keyList = table.keys(self._data)
    table.sort(self._keyList, function(a, b) return tonumber(a) < tonumber(b) end)
end

function HeroDuelAwardView:onInit()
    self:registerClickEventByName("bg.mainBg.closeBtn",function( )
        self:close()
         UIUtils:reloadLuaFile("heroduel.HeroDuelAwardView")
    end)

    self._activePanel = self:getUI("bg.mainBg.activePanel")

    local anum = self._activePanel:getChildByName("num")
    anum:setFontName(UIUtils.ttfName)
    anum:setColor(cc.c3b(255, 252, 226))
    anum:enable2Color(1, cc.c4b(255, 232, 125, 255))
    anum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    self._atipDes = self._activePanel:getChildByName("tipDes")
    self._atipDes:setFontName(UIUtils.ttfName)
    self._atipDes:setColor(cc.c3b(255, 252, 226))
    self._atipDes:enable2Color(1, cc.c4b(255, 232, 125, 255))
    self._atipDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    self:registerClickEventByName("bg.mainBg.activePanel.maskNode1",function( ) end)
    self:registerClickEventByName("bg.mainBg.activePanel.maskNode2",function( ) end)
    
    self:refreshUI()
    -- 创建列表
    self:addActiveTableView()
end

function HeroDuelAwardView:refreshUI()
    --当前场次
    local curNum = 0
    for k,v in ipairs(self._keyList) do
        if self._data[v] == 1 or self._data[v] == 2 then
            curNum = v
        end
    end
    local anum = self._activePanel:getChildByName("num")
    anum:setString(tostring(self._hModel:getHeroDuelData("seasonWins")))

    -- 持续时间
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local year = tonumber(TimeUtils.date("%Y",nowTime))
    local month = TimeUtils.date("%m",nowTime)
    local daySum = TimeUtils.getDaysOfMonth(nowTime)

    self._atipDes:setString("赛季持续时间："..year.."."..month..".01 - "..year.."."..month.."."..daySum)
end

function HeroDuelAwardView:addActiveTableView( )
    local tableBg = self:getUI("bg.mainBg.activePanel.backTexture")
    local tableView = cc.TableView:create(cc.size(tableBg:getContentSize().width - 2, tableBg:getContentSize().height - 16))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(30, 21))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._activePanel:addChild(tableView,1)
    tableView:registerScriptHandler(function( view ) return self:scrollViewActiveDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function( table,index ) return self:cellSizeForActiveTable(table,index) end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index ) return self:tableActiveCellAtIndex(table,index) end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table ) return self:numberOfCellsInActiveTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    self._ActiveTableView = tableView
end

function HeroDuelAwardView:scrollViewActiveDidScroll(view)
end

function HeroDuelAwardView:cellSizeForActiveTable(table,idx) 
    return 135,730
end

function HeroDuelAwardView:tableActiveCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    end

    local cellBoard = cell:getChildByName("cellBoard")
    if not cellBoard then
        cellBoard = self:getUI("cell1"):clone()
        cellBoard:setSwallowTouches(false)
        cellBoard:setName("cellBoard")
        cellBoard:setPosition(0,0)
        cell:addChild(cellBoard)
    end
    self:updateActiveCell(cellBoard, idx)

    return cell
end

function HeroDuelAwardView:numberOfCellsInActiveTableView(table)
    return #self._keyList
end

function HeroDuelAwardView:updateActiveCell(cell, idx)
    local curKey = self._keyList[idx+1]  --string
    --num
    local num = cell:getChildByName("num")
    num:setFontName(UIUtils.ttfName)
    num:setColor(cc.c3b(255, 252, 226))
    num:enable2Color(1, cc.c4b(255, 232, 125, 255))
    num:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    num:setString(self._keyList[idx+1])

    --title
    local title = cell:getChildByName("title")
    title:setFontName(UIUtils.ttfName)
    title:setColor(cc.c3b(255, 255, 255))
    title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    --award
    local awards = tab.heroDuelSeason[tonumber(curKey)]["award"]
    for i,v in ipairs(awards) do
        local itemId
        if v[1] == "tool" then
            itemId = v[2]
        else
            itemId = IconUtils.iconIdMap[v[1]]
        end
        local icon = cell:getChildByName("icon" .. i)
        if not icon then
            icon = IconUtils:createItemIconById({itemId = itemId,num = v[3]})
            icon:setName("icon" .. i)
            icon:setPosition((i-1)*110+160, 24)
            icon:setScale(0.8)
            cell:addChild(icon)
        else
            IconUtils:updateItemIconByView(icon,{itemId = itemId,num = v[3]})
        end
    end

    --getBtn  0不可领取；1可领取；2已领取
    local awardBtn = cell:getChildByName("awardBtn")
    awardBtn:setVisible(false)
    local getImg = cell:getChildByName("getImg")
    getImg:setVisible(false)

    if self._data[curKey] == 0 then
        getImg:setVisible(true)
        getImg:loadTexture("globalImageUI_weidacheng.png",1)

    elseif self._data[curKey] == 1 then
        awardBtn:setVisible(true)

    elseif self._data[curKey] == 2 then
        getImg:setVisible(true)
        getImg:loadTexture("globalImageUI5_yilingqu2.png",1)
    end

    self:registerClickEvent(awardBtn,function( )
        self._serverMgr:sendMsg("HeroDuelServer", "hDuelGetSeasonAward", {id = tonumber(curKey)}, true, {}, function(result)
            -- dump(result, "onHDuelGetSeasonAward", 5)
            self._data[curKey] = 2
            self._ActiveTableView:updateCellAtIndex(idx)
            self:refreshUI()

            DialogUtils.showGiftGet({gifts = result.award,notPop = true})
        end,
        function(error)
            if error == 100 then
                self._viewMgr:showTip("奖励不可领")
            end
        end)
    end)
end

function HeroDuelAwardView:onDestroy( )
    if self._fiveSche then
        ScheduleMgr:unregSchedule(self._fiveSche)
        self._fiveSche = nil
    end
    self.super.onDestroy(self)
end

return HeroDuelAwardView

