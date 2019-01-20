--[[
    Filename:    PokedexSFromDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-12-21 15:32:09
    Description: File description
--]]

local PokedexSFromDialog = class("PokedexSFromDialog", BaseLayer)
function PokedexSFromDialog:ctor(param)
    self.super.ctor(self)
    if not param then
        param = {}
    end
end

-- 初始化UI后会调用, 有需要请覆盖
function PokedexSFromDialog:onInit()
    self._userModel = self._modelMgr:getModel("UserModel")
    self._pokedexModel = self._modelMgr:getModel("PokedexModel")

    self._pokCell = self:getUI("bg.cell")
    self._pokCell:setVisible(false)
    self:addTableView()

    local userData = self._userModel:getData()
    self._userPfId = userData.pfId or 1
    self._selectPokedex = userData.pfId or 1
end


function PokedexSFromDialog:changePFormation()
    if self._userPfId == self._selectPokedex then
        return
    end
    local param = {id = self._selectPokedex}
    self._serverMgr:sendMsg("PokedexServer", "changePFormation", param, true, {}, function (result)
        self._userPfId = self._selectPokedex or 1
    end)
end


-- 接收自定义消息
function PokedexSFromDialog:reflashUI(data)
    local pFormation = self._pokedexModel:getPFormation()
    self._tableData = pFormation
    dump(self._tableData)
    self._tableView:reloadData()
end

function PokedexSFromDialog:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(0, -5)
    self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(false)

    tableViewBg:addChild(self._tableView)
end


-- 触摸时调用
function PokedexSFromDialog:tableCellTouched(table,cell)
    -- self._viewMgr:showDialog("guild.GuildScienceDetailDialog", {detailData = nil})
end

-- cell的尺寸大小
function PokedexSFromDialog:cellSizeForTable(table,idx) 
    local width = 400
    local height = 82
    return height, width
end

-- 创建在某个位置的cell
function PokedexSFromDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    -- local param = self._technology[idx+1]
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        for i=1,2 do
            local pokCell = self._pokCell:clone() 
            pokCell:setVisible(true)
            pokCell:setAnchorPoint(0,0)
            if i == 1 then
                pokCell:setPosition(5,0) 
            else
                pokCell:setPosition(275,0) 
            end
            pokCell:setName("pokCell" .. i)
            cell:addChild(pokCell)
            cell["pokCell" .. i] = pokCell
        end
    end
    self:updateCell(cell, indexId)  
    return cell
end

-- 返回cell的数量
function PokedexSFromDialog:numberOfCellsInTableView(table)
    return 4 -- self:cellLineNum() -- #self._tableData
end

function PokedexSFromDialog:updateCell(inView, indexLine)    
    for i=1,2 do
        local indexId = (indexLine-1)*2+i
        local pokCell = inView["pokCell" .. i]
        self:updateFormationCell(pokCell, indexId, i)
    end
end

function PokedexSFromDialog:updateFormationCell(inView, indexId, cellNum)
    local data = self._tableData[tostring(indexId)]
    -- dump(data,"dzrta...data.....")
    -- local cell = inView
    local lock = inView:getChildByFullName("lock")
    local lockDes = lock:getChildByFullName("des")
    local btn = inView:getChildByFullName("btn")
    local onUse = inView:getChildByFullName("onUse")
    local tname = inView:getChildByFullName("tname")

    if data then
        lock:setVisible(false)
        tname:setVisible(true)
        local pformationName = data
        if data == "" then
            pformationName = "图鉴编组".. indexId
        end
        tname:setString(pformationName)
        btn:loadTextures("globalButtonUI13_1_2.png","globalButtonUI13_1_2.png",nil,1)
        btn:setTitleText("使用")
        self:registerClickEvent(btn, function()
            self._selectPokedex = indexId
            self._tableView:reloadData()
            self:changePFormation()
        end)
    else
        lockDes:setString("编组名".. indexId .."\n尚未解锁")
        btn:loadTextures("globalButtonUI13_3_2.png","globalButtonUI13_3_2.png",nil,1)
        btn:setTitleText("解锁")
        lock:setVisible(true)
        tname:setVisible(false)
        self:registerClickEvent(btn, function()
            -- local userData = self._userModel:getData()
            -- dump(userData.pFormation)
            self:sendUnlockMsg(indexId)
        end)
    end

    self:L10N_Text(btn)
    local inUse = self._selectPokedex == indexId
    btn:setVisible(not inUse)
    onUse:setVisible(inUse)
end

function PokedexSFromDialog:sendUnlockMsg()
    -- 添加编组
    local slotMaxNum = table.nums(tab.tujianjiesuo)
    local formNum
    for i=1,slotMaxNum do
        if not self._tableData[tostring(i)] then
            formNum = i
            break
        end
    end

    if not formNum or formNum > slotMaxNum then
        self._viewMgr:showTip("编组已满")
        return 
    end
    local cost = tab:Tujianjiesuo(formNum).expend
    local costNum = cost[3]
    local gem = self._modelMgr:getModel("UserModel"):getData().gem 
    if gem < costNum then
        DialogUtils.showNeedCharge({desc = "钻石不足，是否前去充值",callback1=function( )
            -- print("充值去！")
            local viewMgr = ViewManager:getInstance()
            viewMgr:showView("vip.VipView", {viewType = 0})
        end})
        return
    end
    local descStr =  "[color=462800,fontsize=24]是否使用[pic=globalImageUI_littleDiamond.png][-][color=3d1f00,fontsize=24]" .. (costNum or 0) 
                    .. "[-][-]" .. "[color=462800,fontsize=24]".. "解锁图鉴编组" .. formNum .."[-]"
    self._viewMgr:showSelectDialog( descStr, "", function( )
            self._serverMgr:sendMsg("PokedexServer", "openPFormation", {}, true, { }, function(result)
                self:reflashUI()
            end)
        end, 
    "", nil)
end

return PokedexSFromDialog