--[[
    @FileName   GuildMercenaryListView.lua
    @Authors    zhangtao
    @Date       2017-08-09 14:39:09
    @Email      <zhangtao@playcrad.com>
    @Description   派遣佣兵列表
--]]
local GuildMercenaryListView = class("GuildMercenaryListView",BasePopView)
function GuildMercenaryListView:ctor()
    self.super.ctor(self)
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._guildModel = self._modelMgr:getModel("GuildModel")
end

-- 初始化UI后会调用, 有需要请覆盖
function GuildMercenaryListView:onInit()
    local closeBtn = self:getUI("bg.layer.btn_close")
    self:registerClickEvent(closeBtn, function()
        self:close()
        UIUtils:reloadLuaFile("guild.mercenary.GuildMercenaryListView")
    end)

    local title = self:getUI("bg.layer.titleBg.title")
    UIUtils:setTitleFormat(title, 1)

    self._cellWidth = self:getUI("cell"):getContentSize().width
    self._cell = self:getUI("cell")
    self._cell:setVisible(false)
end

--删除已经派遣的佣兵
function GuildMercenaryListView:reloadTeamData()
    -- dump(self._guildModel:getGuildMercenary())
    local tempTable = {}
    if #self._teamModel:getData() == 0 then return end
    local teamData = clone(self._teamModel:getData())
    for k , v in pairs(teamData) do
        local isInclude = 0
        if next(self._guildModel:getGuildMercenary()) then
            for _,info in pairs(self._guildModel:getGuildMercenary()["mercenaryDetails"]) do
                if v.teamId == info.teamId then
                    isInclude = 1
                end
            end
        end
        if isInclude == 0 then
            local tempData = clone(v)
            tempData["score"] = tempData["score"] - tempData["pScore"]
            table.insert(tempTable,tempData)
        end
        isInclude = 0
    end
    table.sort(tempTable, function(a, b)
        if a.score == b.score then
            return tonumber(a.teamId) < tonumber(b.teamId)
        else
            return a.score > b.score
        end

    end)

    self._teameData = tempTable
end

--佣兵列表
function GuildMercenaryListView:createTableView()
    if self._tableView then
        self._tableView:reloadData()
        return 
    end
    
    local tableNode = self:getUI("bg.layer.listNode")
    local tableView = cc.TableView:create(cc.size(560, 490))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setAnchorPoint(0,0)
    tableView:setPosition(0 ,0)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    tableNode:addChild(tableView,999)
    tableView:registerScriptHandler(function( view ) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function ( table,cell ) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( table,index ) return self:cellSizeForTable(table,index) end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index ) return self:tableCellAtIndex(table,index) end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table ) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    -- UIUtils:ccScrollViewAddScrollBar(tableView, cc.c3b(169, 124, 75), cc.c3b(64, 32, 12), -4, 6)
    self._tableView = tableView
    -- self._inScrolling = false
end



function GuildMercenaryListView:scrollViewDidScroll(view)
    -- self._inScrolling = view:isDragging()
    -- self._tableOffset = view:getContentOffset()
    -- UIUtils:ccScrollViewUpdateScrollBar(view)
end


function GuildMercenaryListView:tableCellTouched(table,cell)
end

function GuildMercenaryListView:cellSizeForTable(table,idx) 
    return 125,500
end

function GuildMercenaryListView:tableCellAtIndex(table,idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local teamCell = self:getUI("cell")
    local row = idx*2
    if nil == cell then
        cell = cc.TableViewCell:new()
        for i=0,1 do
            local item = cell:getChildByName("cellItem".. i)
            local isNewCreateItem = true
            if i+row+1>#self._teameData then
                if item then
                    item:setVisible(false)
                end
            else
                if item then
                    self:createItem(item,i+row+1,self._teameData[i+row+1])
                end
                if not item then
                    item = teamCell:clone()
                    self:createItem(item,i+row+1,self._teameData[i+row+1])
                    print("i+row+10",i+row+10)
                    cell:addChild(item,100 - i+row)
                end
                item._indexNum = i+row+1
                item:setPosition(i*(self._cellWidth+10)+self._cellWidth/2+5,60)
                item:setName("cellItem".. i)    
            end
        end
    else
        for i=0,1 do
            local item = cell:getChildByName("cellItem".. i)
            if i+row+1>#self._teameData then
                if item then
                    item:setVisible(false)
                end
            else
                if item then
                    self:createItem(item,i+row+1,self._teameData[i+row+1])
                else
                    item = teamCell:clone()
                    self:createItem(item,i+row+1,self._teameData[i+row+1])
                    cell:addChild(item,100 - i+row)
                    item._indexNum = i+row+1
                    item:setPosition(i*(self._cellWidth+10)+self._cellWidth/2+5,60)
                    item:setName("cellItem".. i)  
                end   
            end
        end
    end
    return cell
end

function GuildMercenaryListView:numberOfCellsInTableView(table)
   local itemRow = math.ceil(#self._teameData/2)
    if itemRow < 2 then
        itemRow = 2
    end
    return itemRow
end

function GuildMercenaryListView:createItem(teamCell,index,teamInfo)
    local teamId = teamInfo["teamId"]
    teamCell:setVisible(true)
    teamCell:setAnchorPoint(0.5,0.5)

    teamCell.cell = teamCell:getChildByFullName("teamIconBg")
    -- local teamData = self._teamModel:getTeamAndIndexById(teamId)
    local teamData = teamInfo
    local teamTableData = tab:Team(teamData.teamId)
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)  
    --军团Icon
    if teamCell.cell then
        teamCell.cell:removeAllChildren()
    end

    teamCell.teamIcon = IconUtils:createTeamIconById({teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],isShowOriginScore = true,eventStyle = 1})
    teamCell.teamIcon:setSwallowTouches(false)
    teamCell.teamIcon:setScale(0.9)
    teamCell.teamIcon:setAnchorPoint(0.5,0.5)
    teamCell.teamIcon:setPosition(50,50)
    teamCell.cell:addChild(teamCell.teamIcon)
    --名字
    teamCell.name = teamCell:getChildByFullName("name")
    local isAwaking,awakingLvl = TeamUtils:getTeamAwaking(teamData)
    local teamName = teamTableData.name
    local useless1 = nil
    local useless2 = nil
    if isAwaking then
        teamName, useless1, useless2 = TeamUtils:getTeamAwakingTab(teamData)
    end
    teamCell.name:setString(lang(teamName))

    --战力
    teamCell.fightValue = teamCell:getChildByFullName("fightValue")
    teamCell.fightValue:setString("战斗力:"..teamData["score"])  
    --收益
    teamCell.profitValue = teamCell:getChildByFullName("costValue")
    teamCell.profitValueNode = teamCell:getChildByFullName("costValueTitle")
    -- local fightTeamData = clone(teamData)
    local profitValue = self:getProfitValue(teamData["score"])
    teamCell.profitValue:setString(profitValue)

    local posX,posY = teamCell.profitValue:getPosition()
    local anchorPointX = teamCell.profitValue:getAnchorPoint().x
    local contsizeWidth = teamCell.profitValue:getContentSize().width
    teamCell.profitValueNode:setPosition(posX + (1-anchorPointX)*contsizeWidth , posY)

    teamCell:setBrightness(0)
    local clickFlag = false
    local downY
    local posX, posY
    registerTouchEvent(
        teamCell,
        function (_, _, y)
            downY = y
            clickFlag = false
            teamCell:setBrightness(40)
        end, 
        function (_, _, y)
            if downY and math.abs(downY - y) > 5 then
                clickFlag = true
            end
        end, 
        function ()
            teamCell:setBrightness(0)
            if clickFlag == false then 
                self:close()
                self._viewMgr:showDialog("guild.mercenary.GuildMercenarySendView", {parent = self, teamData = self._teameData[index],pos = self._pos})
            end
        end,
        function ()
            teamCell:setBrightness(0)
        end)
    teamCell:setSwallowTouches(false)
    --添加气泡
    if index == 1 then
        self:addShowBubble(teamCell.cell)

    end
    -- return teamCell
end


--添加气泡
function GuildMercenaryListView:addShowBubble(addNode)
    local tipbg = cc.Scale9Sprite:createWithSpriteFrameName("mercenaryQipao_recommend.png")     
    tipbg:setAnchorPoint(0, 0.5)
    tipbg:setPosition(210,85)
    local scale = 0.9
    tipbg:setScale(scale)
    local seq = cc.Sequence:create(cc.ScaleTo:create(0.8, scale+scale*0.2), cc.ScaleTo:create(0.8, scale))
    tipbg:runAction(cc.RepeatForever:create(seq))
    addNode.qipao = tipbg
    addNode:addChild(tipbg, 100)
end

--计算收益值
function GuildMercenaryListView:getProfitValue(score)
    local tecAdd = self._guildModel:getMercenaryScienceAdd() or 0
    print("tecAdd==========",tecAdd)
    local userLevel = self._modelMgr:getModel("UserModel"):getData().lvl
    local m = tab.lansquenet[self._pos]["m"]  --战斗力系数
    local k = tab.lansquenet[self._pos]["k"]*(1+(tecAdd/100))  --基础奖励
    local n = tab.lansquenet[self._pos]["n"]*(1+(tecAdd/100))
    local perValue = string.format("%0.2f",tonumber(userLevel)*k + math.pow(score/m,2)*n)
    print("perValue",perValue)
    return math.ceil(tonumber(perValue)*(3600/tab.lansquenet[self._pos]["time"]))
end

function GuildMercenaryListView:reloadTableView()
    self:reloadTeamData()
    self._tableView:reloadData()
end

-- 第一次进入调用, 有需要请覆盖
function GuildMercenaryListView:onShow()

end

-- 接收自定义消息
function GuildMercenaryListView:reflashUI(data)
    self._pos = data.pos
    self:reloadTeamData()
    self:createTableView()
end

return GuildMercenaryListView