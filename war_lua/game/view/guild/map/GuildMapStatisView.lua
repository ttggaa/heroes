--[[
    Filename:    GuildMapStatisView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-6-30 22:44:10
    Description: 统计报告界面
--]]

local GuildMapStatisView = class("GuildMapStatisView", BasePopView)

function GuildMapStatisView:ctor()
    GuildMapStatisView.super.ctor(self)
    self._guildMapModel = self._modelMgr:getModel("GuildMapModel")
end

function GuildMapStatisView:onInit()
    local title = self:getUI("bg.titleBg.title")
    title:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)

    self._cellItem = self:getUI("cellItem")
    self._cellH = self._cellItem:getContentSize().height
    self._cellW = self._cellItem:getContentSize().width

    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function()
        self:close()
        UIUtils:reloadLuaFile("guild.map.GuildMapStatisView")
        end)

    for i=1, 3 do
        local title = self:getUI("bg.title" .. i)
        title:setVisible(false)
    end

    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 

        elseif eventType == "enter" then
            ScheduleMgr:delayCall(250, self, function ()
                self:getStatisInfo()
                end)
        end
    end)
end

function GuildMapStatisView:getStatisInfo()
    self._serverMgr:sendMsg("GuildMapServer", "getMapStatisMsg", {}, true, {}, function (result)
        -- dump(result, "getMapStatisMsg", 10)
        self._data = result
        self:refreshUI()
        end)
end

function GuildMapStatisView:refreshUI()
    if not self._data or next(self._data) == nil then
        return
    end

    --取横纵坐标
    self._guilds = {}
    self._builds = {}
    local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
    for i,v in pairs(self._data) do
        if tostring(i) == tostring(guildId) then
            table.insert(self._guilds, 1, i)
        else
            table.insert(self._guilds, i)
        end

        if self._serverLv == nil then
            self._serverLv = v["servLv"]
        end

        if next(self._builds) == nil then
            if v["goldMine"] and next(v["goldMine"]) ~= nil then
                self._builds = table.keys(v["goldMine"]) 
            end
        end
    end

    -- dump(self._guilds)
    -- dump(self._builds)

    --统计排名
    self:calculateStatisRank()

    local tableBg = self:getUI("bg.tableBg")
    local tableW, tableH = tableBg:getContentSize().width, tableBg:getContentSize().height
    self._tableView = cc.TableView:create(cc.size(tableW, tableH))
    self._tableView:setPosition(0, 0)
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setDelegate()
    -- self._tableView:setBounceable(true) 
    self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(function(table, cell ) return self:tableCellWillRecycle(table,cell) end ,cc.TABLECELL_WILL_RECYCLE)
    tableBg:addChild(self._tableView)
    if self._tableView.setDragSlideable ~= nil then 
        self._tableView:setDragSlideable(true)
    end

    self._tableView:reloadData()
end

function GuildMapStatisView:calculateStatisRank()
    local sysMapInfo = tab.guildMapInfo
    local guild1 = self._guilds[1]
    local guild2 = self._guilds[2]
    local guild3 = self._guilds[3]

    local rankList = {}
    rankList[guild1] = {}
    rankList[guild2] = {}
    rankList[guild3] = {}

    --以统计类型为统计值的得分
    local function calculateFunc1(inTable) 
        local score = {3, 2, 1}
        for k = 1, #inTable do  
            for p,q in ipairs(inTable[k]) do
                table.insert(rankList[q["guild"]], score[k])
            end
        end
        inTable = nil
    end

    --每个统计值对应联盟的排名【分数一样的存一个数组】
    local function calculateFunc(aa, bb, cc)
        local changeTable = {}  --排序
        table.insert(changeTable, aa)
        table.insert(changeTable, bb)
        table.insert(changeTable, cc)
        table.sort(changeTable, function(a, b) return a.perc > b.perc end)

        local changeTable1 = {}  --平手按数组存
        for k = 1, #changeTable do
            if changeTable[k - 1] then
                if changeTable[k - 1].perc and changeTable[k - 1].perc == changeTable[k].perc then
                    table.insert(changeTable1[#changeTable1], changeTable[k])
                else
                    table.insert(changeTable1, {changeTable[k]})
                end
            else
                table.insert(changeTable1, {changeTable[k]})
            end
        end
        changeTable = nil

        calculateFunc1(changeTable1) 
    end

    --前四个个人点
    for i,v in ipairs(self._builds) do
        local aa = self._data[guild1]["goldMine"][v]
        aa["guild"] = guild1
        local bb = self._data[guild2]["goldMine"][v]
        bb["guild"] = guild2
        local cc = self._data[guild3]["goldMine"][v]
        cc["guild"] = guild3

        calculateFunc(aa, bb, cc)
    end

    --其它统计值
    for i = 5, #sysMapInfo do
        if self._data[guild1]["statis"][tostring(i)] then
            local aa = {}
            aa["perc"] = self._data[guild1]["statis"][tostring(i)]
            aa["guild"] = guild1
            local bb = {}
            bb["perc"] = self._data[guild2]["statis"][tostring(i)]
            bb["guild"] = guild2
            local cc = {}
            cc["perc"] = self._data[guild3]["statis"][tostring(i)]
            cc["guild"] = guild3

            calculateFunc(aa, bb, cc)
        end
    end

    -- dump(rankList, "rankList")
    local guildList = self._guildMapModel:getData().guildList
    local curGuildId = self._modelMgr:getModel("UserModel"):getData().guildId
    --算分数 并排序
    local scoreList = {}
    for k,v in pairs(rankList) do
        local dd = {guild = k, score = 0}
        for m, n in ipairs(v) do
            dd["score"] = dd["score"] + n
        end
        table.insert(scoreList, dd)
    end
    table.sort(scoreList, function(a,b) return a.score > b.score end)
    rankList = nil
    -- dump(scoreList, "scoreList", 10)

    --相同排名 默认自己在前排
    local scoreList1 = {}
    for i,v in ipairs(scoreList) do
        if tostring(curGuildId) == tostring(v["guild"]) then
            if i - 1 > 0 then
                local insertIndex = #scoreList1 + 1
                for k = i - 1, 1, -1 do
                    if v["score"] == scoreList1[k]["score"] then
                        insertIndex = math.max(insertIndex - 1, 1)
                    end
                end
                table.insert(scoreList1, insertIndex, v)
            else
                table.insert(scoreList1, v)
            end
        else
            table.insert(scoreList1, v)
        end
    end
    scoreList = nil
    -- dump(scoreList1, "scoreList1======", 10)

    --标记排名
    self._guilds = {}
    local rankIndex = 0
    for i,v in ipairs(scoreList1) do
        table.insert(self._guilds, v["guild"])
        if i - 1 > 0 then
            if v["score"] == scoreList1[i - 1]["score"] then
                v["rank"] = rankIndex
            else
                v["rank"] = rankIndex + 1
                rankIndex = rankIndex + 1
            end
        else
            v["rank"] = rankIndex + 1
            rankIndex = rankIndex + 1
        end
    end
    -- dump(scoreList1, "scoreList1111111111111======", 10)
    -- dump(self._guilds, "self._guilds")

    --排序显示
    for i = 1, 3 do
        local title = self:getUI("bg.title" .. i)
        title:setVisible(true)

        local name = title:getChildByName("name")
        local rank = title:getChildByName("rank")
        local light = title:getChildByName("light")
        
        --联盟名
        local guildId = self._guilds[i]
        name:setString(guildList[guildId].name)

        
        if tostring(guildId) == tostring(curGuildId) then
            title:loadTexture("guildMap2Img_title2.png", 1)
            light:loadTexture("guildMap2Img_titleLight2.png", 1)
        else
            title:loadTexture("guildMap2Img_title3.png", 1)
            light:loadTexture("guildMap2Img_titleLight3.png", 1)
        end

        local index = scoreList1[i]["rank"]
        rank:loadTexture("guildMap_rank" .. index .. ".png", 1)
        rank:setScale(1)
    end

    scoreList1 = nil
end

function GuildMapStatisView:scrollViewDidScroll(view)
end

function GuildMapStatisView:numberOfCellsInTableView(table)
    return 10
end

function GuildMapStatisView:tableCellWillRecycle(table,cell)
end

function GuildMapStatisView:cellSizeForTable(table,idx)
    return self._cellH, self._cellW
end

function GuildMapStatisView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if cell == nil then
        cell = cc.TableViewCell:create()
    end

    if cell._item == nil then
        local cellItem = self:createCell(cell, idx)
        cellItem:setPosition(0, 0)
        cell._item = cellItem
        cell:addChild(cellItem)
    else
        self:updateCell(cell._item, idx)
    end

    return cell
end

function GuildMapStatisView:createCell(cell, idx)
    --item
    local item = self._cellItem:clone()
    return self:updateCell(item, idx)
end

function GuildMapStatisView:updateCell(item, idx)
    local sysStatisData = tab.guildMapInfo[idx + 1]
    local sysMapThing = tab.guildMapThing
    local index = idx + 1

    --bg
    local bg = item:getChildByName("bg")
    local _, modf2 = math.modf(index / 2)
    if modf2 == 0 then
        bg:setVisible(true)
    else
        bg:setVisible(false)
    end

    --rwdDes
    local uiRwdDes = item:getChildByName("rwdDes")
    uiRwdDes:setVisible(false)
    local uiRwdIcon = item:getChildByName("rwdIcon")
    uiRwdIcon:setVisible(false)
    uiRwdIcon:removeAllChildren()

    --rwdNode
    local uiRwdNode = item:getChildByName("rwdNode")
    uiRwdNode:removeAllChildren()
    uiRwdNode:setVisible(false)

    --isActive
    for i = 1, 3 do
        local uiAc = item:getChildByFullName("statis"..i..".isActive")
        local uiName = item:getChildByFullName("statis"..i..".num")
        local product = item:getChildByFullName("statis"..i..".product")
        local product1 = item:getChildByFullName("statis"..i..".product1")
        local spliceImg = item:getChildByFullName("statis"..i..".product.spliceImg")

        uiAc:setVisible(false)
        uiName:setVisible(false)
        product:setVisible(false)
        product1:setVisible(false)
        spliceImg:setVisible(false)

        uiAc:setPositionY(46)
        uiName:setPositionY(46)
        product:setPositionX(37)
        product1:setPositionX(28)

        uiAc:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        uiName:setColor(UIUtils.colorTable.ccUIBaseColor5)

        spliceImg:removeAllChildren()
    end

    if index <= 4 then
        self:initStatisGoldMine(index, item)
    else
        self:initStatisOther(index, item)
    end
    
    return item
end

function GuildMapStatisView:initStatisOther(index, inItem)
    local sysMapThing = tab.guildMapThing
    local sysMapInfo = tab.guildMapInfo
    local curId = self._builds[index]
    local cellData = sysMapInfo[tonumber(index)]

    --icon
    local icon = inItem:getChildByName("icon")
    icon:loadTexture(cellData["icon"] .. ".png", 1)
    icon:setScale(0.8)

    --name
    local name = inItem:getChildByName("name")
    name:setString(lang(cellData["name"]))

    --rwdDes
    if cellData["des"] then
        local rwdDes = lang(cellData["des"])
        if string.find(rwdDes, "color=") == nil then
            rwdDes = "[color=645252, fontsize=18]".. rwdDes .."[-]"
        end

        local rwdNode = item:getChildByName("rwdNode")
        rwdNode:setVisible(true)

        local richTxt = RichTextFactory:create(rwdDes, 150, 22)                 
        richTxt:formatText()
        richTxt:setAnchorPoint(cc.p(0.5,0.5))
        richTxt:setPosition(richTxt:getContentSize().width*0.5, rwdNode:getContentSize().height * 0.5)
        rwdNode:addChild(richTxt)
    end

    for i=1, 3 do
        local curGuildID = self._guilds[i]
        local perc = self._data[curGuildID]["statis"][tostring(index)]
        
        local uiName = inItem:getChildByFullName("statis"..i..".num")
        uiName:setVisible(true)

        if index == 5 or index == 7 then
            local maxNum = cellData["den"] or 0
            uiName:setString(perc .. "/" .. maxNum)
            if perc == maxNum then
                uiName:setColor(UIUtils.colorTable.ccUIBaseColor9)
            end

        elseif index == 6 or index == 8 or index == 9 or index == 10 then
            uiName:setString(perc)
        end   
    end
end

function GuildMapStatisView:initStatisGoldMine(index, inItem)
    local sysMapThing = tab.guildMapThing
    local curId = self._builds[index]
    local cellData = sysMapThing[tonumber(curId)]

    --icon
    local icon = inItem:getChildByName("icon")
    icon:loadTexture((cellData["art1"] or "globalImageUI6_meiyoutu") .. ".png", 1)
    icon:setScale(0.4)

    --name
    local name = inItem:getChildByName("name")
    name:setString(lang(cellData["name"]))

    --rwdDes
    if cellData["award1"] then
        local nameList = {tool = "碎片", texp = "经验", gold = "金币", gem = "钻石"}
        local imgList = {
            texp = "globalImageUI_littleTexp", 
            gold = "globalImageUI_littleGold", 
            gem = "globalImageUI_littleDiamond",
            tool = "globalImageUI6_meiyoutu",
        }
        local rwd = cellData["award1"][1][3][1] 
        local rwdName = nameList[rwd[1]]
        local picName = imgList[rwd[1]]

        local uiRwdDes = inItem:getChildByName("rwdDes")
        local rwdIcon = inItem:getChildByName("rwdIcon")
        if rwdName then
            uiRwdDes:setVisible(true)
            uiRwdDes:setString("产出:" .. rwdName)
        end
        -- if rwdName and picName then
            rwdIcon:setVisible(true)
            rwdIcon:loadTexture("globalImageUI6_meiyoutu.png", 1)
            rwdIcon:setPositionX(uiRwdDes:getPositionX() + uiRwdDes:getContentSize().width + rwdIcon:getContentSize().width * 0.5)

            -- if rwd[1] == "tool" then
                local itemType = rwd[1]
                local itemId = rwd[2]
                if itemType ~= "tool" then
                    itemId = IconUtils.iconIdMap[itemType]
                end
                local sysItem1 = tab:Tool(itemId)
                local tempSp = IconUtils:createItemIconById({itemId = itemId, itemData = sysItem1})
                tempSp:setScale(0.25)  --0.35
                tempSp:setAnchorPoint(cc.p(0, 0.5))
                tempSp:setPosition(2, 0)
                rwdIcon:addChild(tempSp)
            -- end
        -- end
    end

    --statis
    for i=1, 3 do
        local curGuildID = self._guilds[i]
        local isAc = self._data[curGuildID]["goldMine"][curId]["ac"]
        local perc = self._data[curGuildID]["goldMine"][curId]["perc"]

        local uiAc = inItem:getChildByFullName("statis"..i..".isActive")
        local uiName = inItem:getChildByFullName("statis"..i..".num")
        local product = inItem:getChildByFullName("statis"..i..".product")
        local numLab = inItem:getChildByFullName("statis"..i..".product.numLab")
        local spliceImg = inItem:getChildByFullName("statis"..i..".product.spliceImg")
        local product1 = inItem:getChildByFullName("statis"..i..".product1")
        local tipLab1 = inItem:getChildByFullName("statis"..i..".product1.tipLab1")
        local tipLab = inItem:getChildByFullName("statis"..i..".product.tipLab")

        if isAc == 1 then  --1激活 0未激活
            product:setVisible(true)
            product1:setVisible(true)
            
            local rewardNum = 0
            local reward = {}
            for k,v in pairs(cellData.produceAward) do
                if self._serverLv >= v[1] and self._serverLv <= v[2] then 
                    for k,v1 in pairs(v[3]) do
                        local tempV = clone(v1)
                        tempV[3] = ((100 / cellData.point) * v1[3])
                        rewardNum = rewardNum + tempV[3]
                        reward[#reward + 1] = tempV
                    end
                end
            end

            tipLab1:setString(perc)
            tipLab1:setColor(UIUtils.colorTable.ccUIBaseColor5)

            numLab:setString(rewardNum)
            numLab:setColor(UIUtils.colorTable.ccUIBaseColor5) 

            if next(reward) ~= nil then
                local reward1 = reward[1]
                local itemType = reward1[1]
                local itemId = reward1[2]
                if itemType ~= "tool" then
                    itemId = IconUtils.iconIdMap[itemType]
                end
                local sysItem1 = tab:Tool(itemId)
                local tempSp = IconUtils:createItemIconById({itemId = itemId, itemData = sysItem1})
                tempSp:setScale(0.4)  --0.35
                tempSp:setAnchorPoint(cc.p(0, 0.5))
                tempSp:setPosition(0, 0)
                spliceImg:addChild(tempSp)

                spliceImg:setVisible(true)
                spliceImg:setPositionX(numLab:getContentSize().width + tempSp:getContentSize().width * 0.5 * tempSp:getScale() - 10)
                tipLab:setPositionX(numLab:getContentSize().width + tempSp:getContentSize().width * tempSp:getScale())
            else
                tipLab:setPositionX(numLab:getContentSize().width)
            end

            local widDis = (tipLab:getPositionX() + tipLab:getContentSize().width - 80) / 2
            if widDis > 0 then
                product:setPositionX(30 - widDis + 10)
            end

        else
            uiAc:setVisible(true)
            uiAc:setString("(未激活)")
        end
    end
end

return GuildMapStatisView