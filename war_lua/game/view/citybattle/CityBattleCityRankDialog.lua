--[[
    Filename:    CityBattleCityRankDialog.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-06-28 11:04:24
    Description: File description
--]]


local cityImage = {"citybattle_serverIcon2.png","citybattle_serverIcon1.png","citybattle_serverIcon3.png"}

local CityBattleCityRankDialog = class("CityBattleCityRankDialog", BaseLayer)

function CityBattleCityRankDialog:ctor()
    CityBattleCityRankDialog.super.ctor(self)
    self._cityBattleModel = self._modelMgr:getModel("CityBattleModel")
    self._leagueModel = self._modelMgr:getModel("LeagueModel")
    self:initData()
end

function CityBattleCityRankDialog:initData()
    self._tabData = clone(tab.cityBattle)
    local cityData = self._cityBattleModel:getCityAllData()
    self._isHaveServerData = false
    self._rankData = {}
    self._serverData = {}
    local co = self._cityBattleModel:getData().c.co
    dump(co)
    self._serverNum = table.nums(co)
    self._co = co

    local setData = tab:Setting("G_CITYBATTLE_START_"..self._serverNum)
    local specialCity = {}
    -- dump(setData.value)
    if setData then
        for _,value in pairs (setData.value) do 
            specialCity[tonumber(value)] = 1
        end
    end

    local function getSec(co)
        for sec,color in pairs (self._co) do 
            if co == color then
                return sec
            end
        end
    end

    for cid,data in pairs(cityData) do
        if data.b and data.b ~= "npc" then
            self._isHaveServerData = true
            local key = co[data.b]
            if not self._serverData[key] then
                self._serverData[key] = {}
                self._serverData[key]["serverNum"] = data.b
            end
            if not self._serverData[key].num then
                self._serverData[key].num = 1
            else
                self._serverData[key].num = 1 + self._serverData[key].num
            end
        end
        data.id = tonumber(cid)
        if not specialCity[data.id] then
            table.insert(self._rankData,data)
        end
    end
    table.sort(self._rankData,function(a,b)
        local alv = self._tabData[a.id]["citylv" .. self._serverNum]
        local blv = self._tabData[b.id]["citylv" .. self._serverNum]
        if alv ~= blv then
            return alv > blv
        else
            return a.id < b.id
        end
        
    end)
    -- dump(self._rankData)
    for i=1,self._serverNum do 
        if not self._serverData[i] then
            self._serverData[i] ={}
            self._serverData[i].num = 0
            self._serverData[i].serverNum = getSec(i)
        end
    end
    local serverdata = clone(self._cityBattleModel:getCityServerList())
    for k,v in pairs (serverdata) do 
        v.num = self._serverData[v.color].num
    end
    self._serverData = serverdata
    dump(self._serverData)
    -- dump(serverData)
    -- if self._isHaveServerData then
    --     local temp = clone(serverData[1])
    --     serverData[1] = serverData[2]
    --     serverData[2] = temp
    -- end
    -- dump(serverData)

end

function CityBattleCityRankDialog:onInit()


    self._cloneCell = self:getUI("cell")
    self._cloneCell:setVisible(false)    

    -- self._nothing = self:getUI("bg.nothing")
    -- self._nothing:setVisible(false)

    -- self._tishi = self:getUI("bg.tishi")
    -- local ruleBtn = self:getUI("bg.ruleBtn")
    -- self:registerClickEvent(ruleBtn, function()
    --     self._viewMgr:showDialog("guild.redgift.GuildRedDescDialog", {wordType = "GET"})
    -- end)

    
    self:updateTopData()
    self:addTableView()

    local titleTxt = self:getUI("cityPanel.topPanel.titleBg.titleTxt")
    titleTxt:setString(lang("CITYBATTLE_TIP_31"))
    if self._cityBattleModel:checkNewGvg() then
        local s1OverTime,s2OverTime,s3OverTime,s4OverTime,s5OverTime,s6OverTime = self._cityBattleModel:getOverTime()
        SystemUtils.saveAccountLocalData("CITYBATTLE_NUM_TIME",s6OverTime+363600)
    end

end

function CityBattleCityRankDialog:updateTopData()
    local topPanel = self:getUI("cityPanel.topPanel")
    local middle_ima = self:getUI("cityPanel.middle_ima")
    local middle_ima_top = self:getUI("cityPanel.middle_ima_top")
    middle_ima:setTouchEnabled(true)
    middle_ima:setZOrder(5)

    local maxLen = 526

    local function getFinalNum(num)
        num = math.max(0,num)
        num = math.min(30,num)
        return num
    end

    local off = 11
    local barImage = {
        {
            {{"citybattle_red_bar1",0,-off}, {"citybattle_red_bar2",0,0}, {"citybattle_red_bar3",0,0}},
            {{"citybattle_blue_bar1",180,0}, {"citybattle_blue_bar2",0,0}, {"citybattle_blue_bar1",0,0}},
            {{"citybattle_green_bar1",180,0}, {"citybattle_green_bar2",0,0}, {"citybattle_green_bar1",0,0} }
        },
        {
            {{"citybattle_red_bar1",0,0}, {"citybattle_red_bar2",0,0}, {"citybattle_red_bar3",0,0}},
            {{"citybattle_blue_bar1",180,-off}, {"citybattle_blue_bar2",0,0}, {"citybattle_blue_bar1",0,0}},
            {{"citybattle_green_bar1",180,-off}, {"citybattle_green_bar2",0,0}, {"citybattle_green_bar1",0,0} }
        },
        {
            {{"citybattle_red_bar1",0,-off}, {"citybattle_red_bar2",0,0}, {"citybattle_red_bar3",0,0}},
            {{"citybattle_blue_bar1",180,0}, {"citybattle_blue_bar2",0,0}, {"citybattle_blue_bar1",0,0}},
            {{"citybattle_green_bar1",180,0}, {"citybattle_green_bar2",0,0}, {"citybattle_green_bar1",0,0} }
        }
    }

    if self._isHaveServerData then
        local barkey = {"blueBar2","redBar2","greenBar2"}
        --1 红 2 蓝 3 绿
        local imageCity = {"citybattle_serverIcon2.png","citybattle_serverIcon1.png","citybattle_serverIcon3.png"}
        for i=1,3 do 
            local name = topPanel:getChildByFullName("cityName"..i)
            local bar = topPanel:getChildByFullName(barkey[i])
            local city = topPanel:getChildByFullName("city"..i)
            if self._serverData[i] then
                local serverName = self._cityBattleModel:getServerName(self._serverData[i].sec)
                name:setString(serverName)
                -- name:setFontSize(14)
                name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor)
                local width = getFinalNum(self._serverData[i].num)/30*maxLen
                bar:setContentSize(width,bar:getContentSize().height)
                name:setVisible(true)
                bar:setVisible(true)
                city:setVisible(true)
                city:loadTexture(imageCity[self._serverData[i].color],1)
            else
                name:setVisible(false)
                bar:setVisible(false)
                city:setVisible(false)
            end
        end

        local blueBar1 = topPanel:getChildByFullName("blueBar1")
        blueBar1:setRotation(0)
        local blueBar2 = topPanel:getChildByFullName("blueBar2")
        blueBar2:setRotation(0)
        local redBar1 = topPanel:getChildByFullName("redBar1")
        redBar1:setRotation(0)
        local redBar2 = topPanel:getChildByFullName("redBar2")
        redBar2:setRotation(0)
        local redBar3 = topPanel:getChildByFullName("redBar3")
        redBar3:setRotation(0)
        local greenBar1 = topPanel:getChildByFullName("greenBar1")
        greenBar1:setRotation(0)
        local greenBar2 = topPanel:getChildByFullName("greenBar2")
        greenBar2:setRotation(0)
        local greenBar3 = topPanel:getChildByFullName("greenBar3")
        greenBar3:setRotation(0)
        

        local x
        x = blueBar2:getPositionX()+blueBar2:getContentSize().width
        redBar1:setPositionX(x+1)
        redBar2:setPositionX(x)
        if not greenBar2:isVisible() then
            greenBar1:setVisible(false)
            greenBar3:setVisible(false)
            redBar3:setVisible(true)
            redBar3:setPositionX(x+redBar2:getContentSize().width-1)
        else
            x = redBar2:getPositionX()+redBar2:getContentSize().width
            greenBar1:setPositionX(x+1)
            greenBar2:setPositionX(x)
            x = greenBar2:getPositionX() + greenBar2:getContentSize().width
            greenBar3:setPositionX(x-1)
            redBar3:setVisible(false)
        end
        middle_ima:setVisible(true)
        middle_ima_top:setVisible(false)


        local data = barImage[1][self._serverData[1].color]
        blueBar1:loadTexture(data[1][1] .. ".png",1)
        blueBar1:setRotation(data[1][2])
        blueBar1:setPositionX(blueBar1:getPositionX()+data[1][3])
        blueBar2:loadTexture(data[2][1] .. ".png",1)
        blueBar2:setRotation(data[2][2])
        blueBar2:setPositionX(blueBar2:getPositionX()+data[2][3])

        data = barImage[2][self._serverData[2].color]
        redBar1:loadTexture(data[1][1] .. ".png",1)
        redBar1:setRotation(data[1][2])
        redBar1:setPositionX(redBar1:getPositionX()+data[1][3])
        redBar2:loadTexture(data[2][1] .. ".png",1)
        redBar2:setRotation(data[2][2])
        redBar2:setPositionX(redBar2:getPositionX()+data[2][3])
        redBar3:loadTexture(data[3][1] .. ".png",1)
        redBar3:setRotation(data[3][2])
        redBar3:setPositionX(redBar3:getPositionX()+data[3][3])

        if greenBar2:isVisible() then
            data = barImage[3][self._serverData[3].color]
            greenBar1:loadTexture(data[1][1] .. ".png",1)
            greenBar1:setRotation(data[1][2])
            greenBar1:setPositionX(greenBar1:getPositionX()+data[1][3])
            greenBar2:loadTexture(data[2][1] .. ".png",1)
            greenBar2:setRotation(data[2][2])
            greenBar2:setPositionX(greenBar2:getPositionX()+data[2][3])
            greenBar3:loadTexture(data[3][1] .. ".png",1)
            greenBar3:setRotation(data[3][2])
            greenBar3:setPositionX(greenBar3:getPositionX()+data[3][3])
        end

    else
        topPanel:setVisible(false)
        
        middle_ima:setPositionY(middle_ima:getPositionY()+120)
        local tableViewBg = self:getUI("cityPanel.tableViewBg")
        local cellBg = self:getUI("cityPanel.cellBg")
        tableViewBg:setContentSize(cellBg:getContentSize().width,cellBg:getContentSize().height-50)
        middle_ima:setVisible(false)
        middle_ima_top:setVisible(true)
    end
end



-- function CityBattleCityRankDialog:getRewardByRank(rank)
--     for i =1,table.nums(self._tabData) do 
--         if rank >= self._tabData[i].pos[1] and rank <= self._tabData[i].pos[2] then
--             return self._tabData[i].monthlyawards
--         end      
--     end
--     return {}
-- end

--[[
用tableview实现
--]]
function CityBattleCityRankDialog:addTableView()
    local tableViewBg = self:getUI("cityPanel.tableViewBg")
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
    self._tableView:setBounceable(true)
    self._tableView:reloadData()
    tableViewBg:addChild(self._tableView)
end


-- 触摸时调用
function CityBattleCityRankDialog:tableCellTouched(table,cell)
end


-- cell的尺寸大小
function CityBattleCityRankDialog:cellSizeForTable(table,idx) 
    local width = 550 
    local height = 114  --232
    return height, width
end

-- 创建在某个位置的cell
function CityBattleCityRankDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx+1
    local param = self._rankData[indexId]
    if nil == cell then
        cell = cc.TableViewCell:new()
        local detailCell = self._cloneCell:clone() 
        detailCell:setVisible(true)
        detailCell:setPosition(cc.p(11,3))
        detailCell:setName("detailCell")
        cell:addChild(detailCell)
    end

    local detailCell = cell:getChildByName("detailCell")
    if detailCell then
        
        -- local cityIma = detailCell:getChildByFullName("cityIma")
        -- local server = detailCell:getChildByFullName("server")
        -- local cityDes = detailCell:getChildByFullName("cityDes")
        -- if self._isHaveServerData then
        --     noGet:setVisible(false)
        --     cityIma:setVisible(true)
        --     server:setVisible(true)
        --     cityDes:setVisible(true)
        -- else
        --     noGet:setVisible(true)
        --     cityIma:setVisible(false)
        --     server:setVisible(false)
        --     cityDes:setVisible(false)
        -- end
        self:updateCell(detailCell, param, indexId)
        detailCell:setSwallowTouches(false)
    end
    return cell
end

function CityBattleCityRankDialog:numberOfCellsInTableView(table)
    return self:cellLineNum() 
end

function CityBattleCityRankDialog:cellLineNum()
    return table.nums(self._rankData)
end

function CityBattleCityRankDialog:updateCell(cell, data, index)
    local stageImg = cell:getChildByFullName("stageImg")
    local iconPanel = cell:getChildByFullName("iconPanel")
    local cityName = cell:getChildByFullName("cityName")
    local num = cell:getChildByFullName("num")
    local cityIma = cell:getChildByFullName("cityIma")
    local server = cell:getChildByFullName("server")
    local cityDes = cell:getChildByFullName("cityDes")
    local noGet = cell:getChildByFullName("noGet")
    server:setVisible(false)
    cityDes:setVisible(false)
    noGet:setVisible(false)
    cityIma:setVisible(false)

    local tab = self._tabData[data.id]
    local _num = self._serverNum
    local imageName = "citybattle_map_0" .. tab["type"] .. tab["citylv" .. _num] .. ".png"
    stageImg:loadTexture(imageName,1)
    cityName:setString(lang(tab.name))
    cityName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor)
    if data.b and data.b ~= "" and data.b ~= "npc" then
        print("lishunan",self._co[data.b])
        cityIma:loadTexture(cityImage[self._co[data.b]],1)
        cityIma:setVisible(true)
        cityDes:setVisible(true)
        local des = self._cityBattleModel:getServerName(data.b)
        -- server:setFontSize(14)
        server:setString(des)

        server:setVisible(true)
        local serverName = self._leagueModel:getServerName(data.b)
        local name_ = string.split(serverName," ")
        cityDes:setString(name_[2] or "")
    else
        noGet:setVisible(true)
    end

    -- local imageIndex = data.image or 1
    -- cityIma:loadTexture(cityImage[imageIndex],1)
    -- if data.image then
    --     server:setVisible(true)
    --     cityDes:setVisible(true)
    --     server:setString(data.serverNum .. "服")
    --     cityDes:setString(data.serverName) self._serverNum
    -- end

    local reward = tab["cityreward" .. self._serverNum]
    local itemId = reward[2]
    if reward[1] ~= "tool" then
        itemId = IconUtils.iconIdMap[reward[1]]
    end
    local param = {itemId = itemId, effect = true, eventStyle = 1}
    local itemIcon = iconPanel:getChildByName("itemIcon")
    if itemIcon then
        IconUtils:updateItemIconByView(itemIcon, param)
    else
        itemIcon = IconUtils:createItemIconById(param)
        itemIcon:setAnchorPoint(0.5,0.5)
        itemIcon:setName("itemIcon")
        itemIcon:setScale(0.8)
        itemIcon:setPosition(iconPanel:getContentSize().width/2,iconPanel:getContentSize().height/2)
        iconPanel:addChild(itemIcon)
    end
    num:setString("x" .. reward[3])

end


function CityBattleCityRankDialog:reflashUI()
    -- local times = self._modelMgr:getModel("GuildModel"):getRedRobTimes()
    -- local todayTimes = self._modelMgr:getModel("PlayerTodayModel"):getData()
    -- self._tishi:setString("今日剩余可抢红包数量: " .. (times - (todayTimes["day15"] or 0)) .. "/" .. times)

    -- self._redRobData = self._modelMgr:getModel("GuildRedModel"):getRobList() --.list
    -- self._tableView:reloadData()

    -- local robRed = self._modelMgr:getModel("GuildRedModel"):getUpdateRobList()
    -- if not robRed then
    --     self:getGuildUserRed()
    -- end
end


return CityBattleCityRankDialog
