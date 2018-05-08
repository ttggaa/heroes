--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-11-10 16:16:57
--
local SpellCaseSlotView = class("SpellCaseSlotView",BasePopView)
function SpellCaseSlotView:ctor()
    self.super.ctor(self)
    self._spbModel = self._modelMgr:getModel("SpellBooksModel")
    self._heroModel = self._modelMgr:getModel("HeroModel")
    self._spbInfo = self._spbModel:getData()
end

function SpellCaseSlotView:getAsyncRes( )
    return 
    {
        {"asset/ui/guildMap1.plist", "asset/ui/guildMap1.png"},
    }
end

-- 初始化UI后会调用, 有需要请覆盖
function SpellCaseSlotView:onInit()
	self:registerClickEventByName("bg.closeBtn",function( )
        self.dontRemoveRes = true
	    self:close()
	    UIUtils:reloadLuaFile("spellbook.SpellCaseSlotView")
	end)
    self._title = self:getUI("bg.headBg.title")
    UIUtils:setTitleFormat(self._title,1)
	self._cell = self:getUI("bg.cell")
    self._cell:setVisible(false)
	self._tableBg = self:getUI("bg.tableBg")
    self._tableData = self:initTableData() or {}
	self:addTableView()

    local zhandouliLab = ccui.TextBMFont:create("0", UIUtils.bmfName_zhandouli_little)
    zhandouliLab:setAnchorPoint(cc.p(1,0))
    zhandouliLab:setPosition(420,20)
    zhandouliLab:setScale(.6)
    self:getUI("bg.desBg"):addChild(zhandouliLab,99)
    self._zhandouliLab = zhandouliLab
    local totalScore = self._spbModel:sumHeroSlotScore()
    zhandouliLab:setString(totalScore or 0)
end

function SpellCaseSlotView:initTableData( )
    local tableData = {}
    for k,v in pairs(self._spbInfo) do
        if tonumber(v.b) and tonumber(v.b) ~= 0 then
            local heroData = self._heroModel:getHeroData(v.b)
            if heroData then
                local sid = heroData.slot and heroData.slot.sid or nil
                if tonumber(sid) and tonumber(sid) ~= 0 then
                    dump(heroData.slot)
                    local skillD = tab.playerSkillEffect[tonumber(sid)] or tab.heroMastery[tonumber(sid)]
                    if skillD then
                        local heroInfo = {}
                        heroInfo.name = lang(skillD.name)
                        heroInfo.score = heroData.slot and heroData.slot.score or 0
                        heroInfo.heroId = tonumber(v.b)
                        heroInfo.sid = sid
                        table.insert(tableData,heroInfo)
                    end
                end 
            end
        end
    end
    return tableData
end

-- 第一次进入调用, 有需要请覆盖
function SpellCaseSlotView:onShow()

end

-- 接收自定义消息
function SpellCaseSlotView:reflashUI(data)

end

function SpellCaseSlotView:addTableView( )
    local tableView = cc.TableView:create(cc.size(460, 320))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(0,0))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._tableBg:addChild(tableView)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(function ( table,cell )
        return self:tableCellTouched(table,cell)
    end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( table,index )
        return self:cellSizeForTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index )
        return self:tableCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table )
        return self:numberOfCellsInTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    self._tableView = tableView
end

function SpellCaseSlotView:scrollViewDidScroll(view)
    -- print("scrollViewDidScroll")
end

function SpellCaseSlotView:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function SpellCaseSlotView:tableCellTouched(table,cell)
    -- print("cell touched at index: " .. cell:getIdx())
end

function SpellCaseSlotView:cellSizeForTable(table,idx) 
    return 80,460
end

function SpellCaseSlotView:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    end

    local cellBoard = cell:getChildByName("cellBoard")
    if not cellBoard then
        cellBoard = self._cell:clone()
        cellBoard:setVisible(true)
        cellBoard:setSwallowTouches(false)
        cellBoard:setName("cellBoard")
        cellBoard:setAnchorPoint(0,0)
        cellBoard:setPosition(0,0)
        cell:addChild(cellBoard)
    end
    self:updateCell(cellBoard,idx+1)

    return cell
end

function SpellCaseSlotView:updateCell( cellBoard,index )
    print(index,"index...-----")
    local data = self._tableData[index]
    -- if not data then return end
    cellBoard:setOpacity(index%2 == 0 and 255 or 0)
    local skillName = cellBoard:getChildByName("skillName")
    local score = cellBoard:getChildByName("score")
    if data then
        skillName:setString(data.name or "")
        score:setString(data.score or 0)
        skillName:setColor(cc.c3b(196,73,4))
        score:setColor(cc.c3b(196,73,4))
    else
        skillName:setString("--")
        score:setString("--")
        skillName:setColor(cc.c3b(79,68,67))
        score:setColor(cc.c3b(79,68,67))
    end

    local hero = data and data.heroId
    local heroIcon = cellBoard._heroIcon
    if hero and hero ~= 0 then
        local heroData = clone(tab.hero[hero])
        if not heroIcon then
            heroIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
            --heroIcon:setAnchorPoint(cc.p(0, 0))
            heroIcon:setPosition(75,40)
            heroIcon:setScale(0.6)
            cellBoard:addChild(heroIcon,20)
            cellBoard._heroIcon = heroIcon
        end
        heroIcon:setVisible(true)
        IconUtils:updateHeroIconByView(heroIcon,{sysHeroData = heroData})
        heroIcon:getChildByName("starBg"):setVisible(false)
        local iconStar = heroIcon:getChildByFullName("iconStar")
        if iconStar then
            iconStar:setVisible(false)
        end
    else
        if heroIcon then 
            heroIcon:setVisible(false)
        end
    end
	-- body
end

function SpellCaseSlotView:numberOfCellsInTableView(table)
    local tableNum = math.max(4,#self._tableData)
    return tableNum
end



return SpellCaseSlotView