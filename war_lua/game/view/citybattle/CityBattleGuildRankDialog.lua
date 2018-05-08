--[[
    Filename:    CityBattleGuildRankDialog.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-06-28 11:04:24
    Description: File description
--]]

local cellMine
local cellRank
local tabData
local allRankData
local mineRankData
local TableViewH
local CityImage = {"citybattle_view_temp6.png","citybattle_view_temp8.png","citybattle_view_temp7.png"}
local CityBattleGuildRankDialog = class("CityBattleGuildRankDialog", BaseLayer)

function CityBattleGuildRankDialog:ctor(param)
    CityBattleGuildRankDialog.super.ctor(self)
    tabData = clone(tab.cityBattleHonor)
    self._userModel = self._modelMgr:getModel("UserModel")
    self:initData(param.list)
    
end

function CityBattleGuildRankDialog:initData(param)
    self._co = self._modelMgr:getModel("CityBattleModel"):getData().c.co
    local guildID = tonumber(self._userModel:getData().roleGuild.guildId)
    self._isHaveServerData = false
    if param and table.nums(param) > 0 then
        self._isHaveServerData = true
        allRankData = param
        for _,data in pairs (allRankData) do 
            if guildID == tonumber(data.id) then
                mineRankData = clone(data)
                break
            end
        end
        return
    end
    if not self._isHaveServerData then
        allRankData = {}
        -- for i=1,20 do 
        --     table.insert(allRankData,{rank = i})
        -- end
    end
    
end

function CityBattleGuildRankDialog:onInit()


    cellMine = self:getUI("cell1")

    cellRank = self:getUI("cell2")
    cellRank:setVisible(false)    

    self:updateMineCell()
    self:addTableView()


end

function CityBattleGuildRankDialog:moreRefresh(data)
    local guildID = tonumber(self._userModel:getData().roleGuild.guildId)
    for _,value in pairs (data) do
        -- if self._nowPage then
        --     value.rank = self._nowPage*20 + value.rank
        -- end 
        table.insert(allRankData,value)
    end
    -- table.merge(allRankData,data)
    for _,data in pairs (allRankData) do 
        if guildID == data.id then
            mineRankData = clone(data)
            break
        end
    end
    -- dump(allRankData)
    self:updateMineCell()
    self:reloadTableViewWithoutOff()
end

function CityBattleGuildRankDialog:reloadTableViewWithoutOff()
    if self._tableView then
        local off = self._tableView:getContentOffset()
        local oldHeight = self._tableView:getContainer():getContentSize().height
        self._tableView:reloadData()
        local newHeight = self._tableView:getContainer():getContentSize().height
        -- print("aaaaaa",off.x,off.y-(newHeight-oldHeight))
        self._tableView:setContentOffset(cc.p(off.x,off.y-(newHeight-oldHeight)))
    end
end

--判断是否可以领取，周日 22:30 结点,周五 8：45备战
function CityBattleGuildRankDialog:checkIsCanGet()
    local curServerTime =  self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    local timeAdd = weekday == 0 and 0 or (7-weekday)*86400
    -- local overT = TimeUtils.date("*t", curServerTime+timeAdd)
    -- local overTime = os.time({year = overT.year, month = overT.month, day = overT.day, hour = 22, min = 30, sec = 0})
    local overTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime+timeAdd,"%Y-%m-%d 22:30:00"))
    if weekday >= 1 and weekday <= 5  then
        return true
    else
        return curServerTime >= overTime,overTime-curServerTime
    end
end
 
function CityBattleGuildRankDialog:updateMineCell()
    local isGet
    local rankData = mineRankData

    local getBtn = cellMine:getChildByFullName("awardBtn")
    getBtn:setVisible(false)
    local time = cellMine:getChildByFullName("time")
    time:setVisible(false)
    local timeDes = cellMine:getChildByFullName("timeDes")
    timeDes:setVisible(false)
    local rank = cellMine:getChildByFullName("num")
    local middle_ima = self:getUI("guildPanel.middle_ima")
    local middle_ima_top = self:getUI("guildPanel.middle_ima_top")
    middle_ima_top:setZOrder(4)
    middle_ima_top:setTouchEnabled(true)
    middle_ima:setTouchEnabled(true)
    middle_ima:setZOrder(4)

    cellMine:setVisible(false)
    -- middle_ima:setVisible(false)
    -- middle_ima_top:setVisible(true)
    -- middle_ima:setPositionY(middle_ima:getPositionY()+120)
    -- local tableViewBg = self:getUI("guildPanel.tableViewBg")
    -- local cellBg = self:getUI("guildPanel.cellBg")
    -- tableViewBg:setContentSize(cellBg:getContentSize().width,cellBg:getContentSize().height-50)


    if rankData and table.nums(rankData) > 0 then --有服务器数据
        -- local isCanGet,leftTime = self:checkIsCanGet()
        -- if leftTime and leftTime > 0 then --未到领取时间
        --     time:setVisible(true)
        --     timeDes:setVisible(true)
        --     leftFormatTime = string.format("%01d天%02d小时",math.floor(leftTime/86400),math.floor(leftTime%86400/3600))
        --     time:setString(leftFormatTime)
        -- else
        --     if isGet then
        --         local getImage = cc.Sprite:createWithSpriteFrameName("globalImageUI5_yilingqu2.png")
        --         getImage:setPosition(getBtn:getPosition())
        --         cellMine:addChild(getImage)
        --     else
        --         getBtn:setVisible(true)
        --         self:registerClickEvent(getBtn,function ()
        --             print("领奖")
        --         end)
        --     end
        -- end
        cellMine:setVisible(true)
        -- if not rankData then
        --     rank:setString("暂未上榜")
        -- else

            
        -- end
        rank:setString(rankData.rank or 0)
        local rewards = self:getRewardByRank(rankData.rank)

        for i=1,table.nums(rewards) do
            local itemId = rewards[i][2]
            if rewards[i][1] ~= "tool" then
                itemId = IconUtils.iconIdMap[rewards[i][1]]
            end
            local param = {itemId = itemId, effect = true, eventStyle = 1, num = rewards[i][3]}
            local itemIcon = cellMine["award" .. i]
            if itemIcon then
                IconUtils:updateItemIconByView(itemIcon, param)
            else
                itemIcon = IconUtils:createItemIconById(param)
                itemIcon:setName("itemIcon")
                -- local itemNormalScale = 90/itemIcon:getContentSize().width
                itemIcon:setScale(0.8)
                itemIcon:setPosition(cc.p(85*i+49, 23))
                cellMine:addChild(itemIcon)
                cellMine["award" .. i] = itemIcon
            end
        end
        middle_ima:setVisible(true)
        middle_ima_top:setVisible(false)
    else
        cellMine:setVisible(false)
        middle_ima:setVisible(false)
        middle_ima_top:setVisible(true)
        middle_ima:setPositionY(middle_ima:getPositionY()+120)
        local tableViewBg = self:getUI("guildPanel.tableViewBg")
        local cellBg = self:getUI("guildPanel.cellBg")
        tableViewBg:setContentSize(cellBg:getContentSize().width,cellBg:getContentSize().height-50)
    end


    

    
end

function CityBattleGuildRankDialog:getRewardByRank(rank)
    for i =1,table.nums(tabData) do 
        if rank >= tabData[i].pos[1] and rank <= tabData[i].pos[2] then
            return tabData[i].monthlyawards
        end      
    end
    return {}
end

--[[
用tableview实现
--]]
function CityBattleGuildRankDialog:addTableView()
    local tableViewBg = self:getUI("guildPanel.tableViewBg")
    TableViewH = tableViewBg:getContentSize().height
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:registerScriptHandler(function(table, cell) 
        return self:tableCellTouched(table,cell) 
        end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) 
        return self:cellSizeForTable(table,idx) 
        end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) 
        return self:tableCellAtIndex(table, idx) 
        end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) 
        return self:numberOfCellsInTableView(table) 
        end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(function( view )
        return self:scrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:setBounceable(true)
    self._tableView:reloadData()
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end

    
    
    tableViewBg:addChild(self._tableView)
end


-- 触摸时调用
function CityBattleGuildRankDialog:tableCellTouched(table,cell)
end

function CityBattleGuildRankDialog:createLoadingMc()
    if self._loadingMc then return end
    -- 添加加载中动画
    local tableViewBg = self:getUI("guildPanel.tableViewBg")
    self._loadingMc = mcMgr:createViewMC("jiazaizhong_rankjiazaizhong", true, false, function (_, sender)      end)
    self._loadingMc:setPosition(cc.p(tableViewBg:getContentSize().width * 0.5, 5))
    self._loadingMc:setName("loadingMc")
    tableViewBg:addChild(self._loadingMc, 0)
    self._loadingMc:setVisible(false)
end

function CityBattleGuildRankDialog:scrollViewDidScroll(view)
    if not self._isHaveServerData then return end
    self._inScrolling = view:isDragging()
    local offsetY = view:getContentOffset().y  
    -- print("offsetY",offsetY)     
    if offsetY >= 60 and #allRankData > 5 and not self._canRequest then
        -- print("lishunan1")
        self._canRequest = true
        self:createLoadingMc()
        if not self._loadingMc:isVisible() then
            self._loadingMc:setVisible(true)
        end
    end 

    local showAniNum = 4
    if mineRankData then
        showAniNum = 3
    end
        -- print("aa",#allRankData)
    if self._inScrolling and #allRankData > showAniNum then
        if offsetY >= 5 and not self._canRequest then
            self._canRequest = true
            self:createLoadingMc()
            if not self._loadingMc:isVisible() then
                self._loadingMc:setVisible(true)
            end
        end
        if offsetY <= 0 and self._canRequest then
            self._canRequest = false
            self:createLoadingMc()
            if self._loadingMc:isVisible() then
                self._loadingMc:setVisible(false)
            end 
        end
    else
        -- 满足请求更多数据条件
        if self._canRequest and offsetY >=0 and offsetY <= 5 then 
            self._canRequest = false    
            -- self._viewMgr:lock(1)
            -- self:sendMessageAgain()
            self:createLoadingMc()
            if self._loadingMc:isVisible() then
                self._loadingMc:setVisible(false)
            end 
            print("请求新的数据")
            if self._updateMailTick == nil or socket.gettime() > self._updateMailTick + 5 then
                self._updateMailTick = socket.gettime()
                self:getListMore() 
            end
        end
    end

end

function CityBattleGuildRankDialog:getListMore()
    if not self._nowPage then
        self._nowPage = 1
    end
    local param = {page = self._nowPage+1}
    -- dump(param)
    self._serverMgr:sendMsg("CityBattleServer", "getGuildRank", param, true, {}, function (result)
        -- print("self._nowPage",self._nowPage)
        -- dump(result,"CityBattleGuildRankDialog",100)
        if result and result.list and  table.nums(result.list) > 0 then
            self:moreRefresh(result.list)
            self._nowPage = self._nowPage + 1
        else
            print("没有更多数据了")
        end
    end)
end

-- cell的尺寸大小
function CityBattleGuildRankDialog:cellSizeForTable(table,idx) 
    local width = 550 
    local height = 116  --232
    return height, width
end

-- 创建在某个位置的cell
function CityBattleGuildRankDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx+1
    local param = allRankData[indexId]
    if nil == cell then
        cell = cc.TableViewCell:new()
        local detailCell = cellRank:clone() 
        detailCell:setVisible(true)
        detailCell:setPosition(cc.p(11,3))
        detailCell:setName("detailCell")
        cell:addChild(detailCell)
    end

    local detailCell = cell:getChildByName("detailCell")
    if detailCell then
        local norank = detailCell:getChildByFullName("noRank")
        local cityImage = detailCell:getChildByFullName("cityImage")
        local guildName = detailCell:getChildByFullName("guildName")
        local score = detailCell:getChildByFullName("score")
        cityImage:setPositionX(408)
        guildName:setPositionX(424)
        score:setPositionX(424)
        norank:setPositionX(456)
        score:setFontSize(16)
        if self._isHaveServerData then
            norank:setVisible(false)
            cityImage:setVisible(true)
            guildName:setVisible(true)
            score:setVisible(true)
        else
            norank:setVisible(true)
            cityImage:setVisible(false)
            guildName:setVisible(false)
            score:setVisible(false)
        end
        self:updateCell(detailCell, param, indexId)
        detailCell:setSwallowTouches(false)
    end
    return cell
end

function CityBattleGuildRankDialog:numberOfCellsInTableView(table)
    return self:cellLineNum() 
end

function CityBattleGuildRankDialog:cellLineNum()
    if self._isHaveServerData then
        return table.nums(allRankData)
    else
        return 1000        
    end
end

function CityBattleGuildRankDialog:updateCell(cell, data, index)
    if not data and not self._isHaveServerData then
        data = {rank = index}
    end
    local rankNum = cell:getChildByFullName("num")
    rankNum:setVisible(false)
    local rankImage = cell:getChildByFullName("rankImage")  
    rankImage:setVisible(false)
    local cityImage_ = cell:getChildByFullName("cityImage")
    local guildName = cell:getChildByFullName("guildName")
    local score = cell:getChildByFullName("score")

    if data.rank == 1 then
        rankImage:setVisible(true)
        rankImage:loadTexture("arenaRank_first.png",1)
    elseif data.rank == 2 then
        rankImage:setVisible(true)
        rankImage:loadTexture("arenaRank_second.png",1)
    elseif data.rank == 3 then
        rankImage:setVisible(true)
        rankImage:loadTexture("arenaRank_third.png",1)
    else
        rankNum:setVisible(true)
        rankNum:setString(data.rank)
    end

    if data.score then
        score:setString("总积分:"..data.score)
    end
    if data.name then
        guildName:setString(data.name)
    end
    if data.sec then
        cityImage_:loadTexture(CityImage[self._co[data.sec]],1)
    end

    local rewards = self:getRewardByRank(data.rank)
    for i=1,table.nums(rewards) do
        local itemId = rewards[i][2]
        if rewards[i][1] ~= "tool" then
            itemId = IconUtils.iconIdMap[rewards[i][1]]
        end
        local param = {itemId = itemId, effect = true, eventStyle = 1, num = rewards[i][3]}
        local itemIcon = cell["award" .. i]
        if itemIcon then
            IconUtils:updateItemIconByView(itemIcon, param)
        else
            itemIcon = IconUtils:createItemIconById(param)
            itemIcon:setName("itemIcon")
            itemIcon:setScale(0.8)
            itemIcon:setPosition(cc.p(85*i+50, 23))
            cell:addChild(itemIcon)
            cell["award" .. i] = itemIcon
        end
    end
end


function CityBattleGuildRankDialog:reflashUI()

end

function CityBattleGuildRankDialog:dtor( ... )
    cellMine = nil
    cellRank = nil
    tabData = nil
    allRankData = nil
    TableViewH = nil
end



return CityBattleGuildRankDialog
