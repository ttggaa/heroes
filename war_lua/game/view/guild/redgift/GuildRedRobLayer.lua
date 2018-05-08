--[[
    Filename:    GuildRedRobLayer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-06-06 19:55:24
    Description: File description
--]]

-- 抢红包
local GuildRedRobLayer = class("GuildRedRobLayer", BaseLayer)

function GuildRedRobLayer:ctor()
    GuildRedRobLayer.super.ctor(self)
    self._redRobData = {}
end

function GuildRedRobLayer:onInit()

    self._nothing = self:getUI("bg.nothing")
    self._nothing:setVisible(false)

    self._tishi = self:getUI("bg.tishi")
    local ruleBtn = self:getUI("bg.ruleBtn")
    self:registerClickEvent(ruleBtn, function()
        self._viewMgr:showDialog("guild.redgift.GuildRedDescDialog", {wordType = "GET"})
    end)
    local rankBtn = self:getUI("bg.rankBtn")
    self:registerClickEvent(rankBtn, function()
        self._viewMgr:showDialog("guild.redgift.GuildRedRankDialog", {redType = 2})
    end)

    self._modelMgr:getModel("GuildRedModel"):setUpdateRobList(false)
    self._redGift = self:getUI("redGift")
    local gift = self._redGift:getChildByFullName("gift")
    self._redGift:reorderChild(gift,2)
    self:addTableView()
end

--[[
用tableview实现
--]]
function GuildRedRobLayer:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(true)
    -- self._tableView:reloadData()
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    
    tableViewBg:addChild(self._tableView)
end


-- 触摸时调用
function GuildRedRobLayer:tableCellTouched(table,cell)
    -- self._viewMgr:showDialog("guild.GuildScienceDetailDialog", {detailData = nil})
end

-- cell的尺寸大小
function GuildRedRobLayer:cellSizeForTable(table,idx) 
    local width = 770 
    local height = 272  --232
    return height, width
end

-- 创建在某个位置的cell
function GuildRedRobLayer:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    -- local param = self._technology[idx+1]
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        for i=1,4 do
            local redGift = self._redGift:clone() 
            redGift:setAnchorPoint(cc.p(0,0))
            redGift:setPosition(cc.p((i-1)*190+4,19)) --0
            redGift:setName("redGift" .. i)
            cell:addChild(redGift)

            -- local donateBtn = detailCell:getChildByFullName("donateBtn")
            -- donateBtn:getTitleRenderer():enableOutline(cc.c4b(153,93,0, 255), 3)

            -- local name = detailCell:getChildByFullName("name")
            -- name:enableOutline(cc.c4b(55,42,28,255), 2)
            -- local lab1 = detailCell:getChildByFullName("lab1")
            -- lab1:enableOutline(cc.c4b(55,42,28,255), 2)
            -- local teamNum = detailCell:getChildByFullName("teamNum")
            -- teamNum:enableOutline(cc.c4b(0,78,0,255), 2)
        end

        self:updateCell(cell, indexId)
        -- detailCell:setSwallowTouches(false)
    else
        print("wo shi shua xin")
        self:updateCell(cell, indexId)
    end

    return cell
end

-- 返回cell的数量
function GuildRedRobLayer:numberOfCellsInTableView(table)
    return self:cellLineNum() -- #self._backupData -- #self._technology --table.nums(self._membersData)
end

function GuildRedRobLayer:cellLineNum()
    return math.ceil(table.nums(self._redRobData)/4)
end

function GuildRedRobLayer:updateCell(cell, indexLine)    
    for i=1,4 do
        local redGift = cell:getChildByFullName("redGift" .. i)
        if redGift then
            local indexId = (indexLine-1)*4+i
            self:updateCellUI(redGift, self._redRobData[indexId], indexId)  
            redGift:setSwallowTouches(false)
        end
    end
end

function GuildRedRobLayer:updateCellUI(redGift, redRobData, indexId)  
    if redRobData then
        -- self:removeRobRed(indexId)
        redGift:runAction(cc.RepeatForever:create(
            cc.Sequence:create(cc.CallFunc:create(function()
            if not redGift then
                return
            end

            local curServerTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
            local tempTime = curServerTime - redRobData.cTime

            if tempTime >= 86400 then
                -- self:reflashUI()
                self:removeRobRed(indexId)
            end
        end), cc.DelayTime:create(1))
        ))

        local classType
        local redTab = tab:GuildUserRed(self._redRobData[indexId]["id"])
        local tempType = redTab.type 
        if tempType == "gold" then
            classType = 1
        elseif tempType == "gem" then
            classType = 2
        elseif tempType == "treasureCoin" then
            classType = 3
        end

        local imageBg = {"guild_red_huangjin.png","guil_red_zuanshi.png","guild_red_baowu.png"}
        local bg = redGift:getChildByFullName("gu")
        if bg then
            bg:loadTexture(imageBg[classType],1)
        end


        -- local name = redGift:getChildByFullName("name")
        -- if name then
        --     name:loadTexture("allicance_redname" .. classType .. ".png", 1)
        -- end

        local statusImage = {"status_get.png","allicance_redziyuan5.png"}
        
        local gift = redGift:getChildByFullName("gift")

        if gift then
            gift:setVisible(false)
            if self._redRobData[indexId].robRed == 1 then
                classType = 4
                gift:setVisible(true)
                gift:loadTexture(statusImage[1], 1)
            elseif self._redRobData[indexId].robRed == 2 then
                if self._redRobData[indexId].rob >= redTab.people then
                    gift:setVisible(true)
                    classType = 5
                     gift:loadTexture(statusImage[2], 1)
                end
            end
        end
        
        local playName = redGift:getChildByFullName("playName")
        if playName and self._redRobData[indexId].name ~= "" then
            playName:setString(self._redRobData[indexId].name)
        end
        local redData = self._redRobData[indexId]
        local downY, clickFlag
        registerTouchEvent(
            redGift,
            function (_, _, y)
                downY = y
                clickFlag = false
                
            end, 
            function (_, _, y)
                if downY and math.abs(downY - y) > 5 then
                    clickFlag = true
                end
            end, 
            function ()
                if clickFlag == false then 
                    self:robGuildUserRed(redData)
                end
            end,
            function ()
            end)
        -- self:registerClickEvent(redGift, function()
        --     self:robGuildUserRed(redData)
        -- end)
        redGift:setVisible(true)
        self:addRedGiftEffect(redGift, classType)
    else
        redGift:setVisible(false)
    end
end

--红包闪光特效  wangyan
function GuildRedRobLayer:addRedGiftEffect(redGift, classType)
    if redGift:getChildByName("redGiftAnim") then
        redGift:getChildByName("redGiftAnim"):removeFromParent(true)
    end
    local gu = redGift:getChildByFullName("gu")
    if classType > 3 then
        gu:setBrightness(-40)
        gu:setContrast(-40)

        -- local gift = redGift:getChildByFullName("gift")
        -- if gift then
        --     gift:setBrightness(40)
        --     gift:setContrast(40)
        -- end
        return
    else
        gu:setBrightness(0)
        gu:setContrast(0)
    end

    local anim = mcMgr:createViewMC("hongbaokelingqu_keling", true)   
    anim:setPosition(redGift:getContentSize().width/2, redGift:getContentSize().height/2)

    local clipNode = cc.ClippingNode:create()   
    clipNode:setInverted(false)   

    local mask = cc.Sprite:createWithSpriteFrameName("guil_red_zuanshi.png")  --遮罩
    mask:setPosition(cc.p(redGift:getContentSize().width/2 * 1.2 + 3, redGift:getContentSize().height/2 * 1.2 + 4))   
    mask:setAnchorPoint(0.5, 0.5)
    clipNode:setStencil(mask)  
    clipNode:setAlphaThreshold(0.01)
    clipNode:addChild(anim)  
    clipNode:setAnchorPoint(cc.p(0,0))
    clipNode:setPosition(0, 0)
    clipNode:setName("redGiftAnim")
    clipNode:setScale(0.8)
    redGift:addChild(clipNode, 100)
end

function GuildRedRobLayer:reflashUI()
    local times = self._modelMgr:getModel("GuildModel"):getRedRobTimes()
    local todayTimes = self._modelMgr:getModel("PlayerTodayModel"):getData()
    self._tishi:setString("今日剩余可抢红包数量: " .. (times - (todayTimes["day15"] or 0)) .. "/" .. times)

    self._redRobData = self._modelMgr:getModel("GuildRedModel"):getRobList() --.list
    self._tableView:reloadData()

    local robRed = self._modelMgr:getModel("GuildRedModel"):getUpdateRobList()
    if not robRed then
        self:getGuildUserRed()
    end
end

-- 获取玩家红包列表
function GuildRedRobLayer:getGuildUserRed()
    self._serverMgr:sendMsg("GuildRedServer", "getGuildUserRed", {}, true, {}, function (result)
        self:getGuildUserRedFinish(result)
    end)
end 

function GuildRedRobLayer:getGuildUserRedFinish(result)
    if result == nil then 
        return 
    end
    -- dump(result, "result==============")
    self._redRobData = self._modelMgr:getModel("GuildRedModel"):getRobList() --.list
    self._tableView:reloadData()
    if table.nums(self._redRobData) == 0 then
        -- local nothing = self:getUI("bg.nothing")
        self._nothing:setVisible(true)
        -- local panelBg = self:getUI("bg.panelBg")
        -- nothing:setVisible(false)
    else
        -- local nothing = self:getUI("bg.nothing")
        self._nothing:setVisible(false)
        -- local panelBg = self:getUI("bg.panelBg")
        -- nothing:setVisible(true)
    end
end

function GuildRedRobLayer:removeRobRed(indexId)
    if self._redRobData[indexId] then
        table.remove(self._redRobData, indexId)
        self._tableView:reloadData()
    end
    if table.nums(self._redRobData) == 0 then
        -- local nothing = self:getUI("bg.nothing")
        self._nothing:setVisible(true)
    else
        -- local nothing = self:getUI("bg.nothing")
        self._nothing:setVisible(false)
    end
end


-- 抢红包
function GuildRedRobLayer:robGuildUserRed(redData)
    if redData.robRed == 0 then
        self._serverMgr:sendMsg("GuildRedServer", "robGuildUserRed", {redId = redData.redId}, true, {}, function (result)
            -- redData.robRed = 1
            dump(result)
            self:robGuildUserRedFinish(result)

            --刷新全局抢红包界面  wangyan
            if self._viewMgr._redBoxLayer.robLayer ~= nil then
                self._viewMgr._redBoxLayer.robLayer:removeSingleRed(redData.redId)
            end
        end, function(errorId)
            if tonumber(errorId) == 2808 then
                self._viewMgr:showTip("大人，您今天没有次数了")
            elseif tonumber(errorId) == 2802 then
                self._viewMgr:showTip("这个红包已过期")
            end
        end)
    else
        self._serverMgr:sendMsg("GuildRedServer", "getGuildRedRobRank", {redId = redData.redId}, true, {}, function (result)
            if result == nil then 
                return 
            end
            local redRank = result
            self:robProcessData(redRank, redData)
            self._viewMgr:showDialog("guild.redgift.GuildRedRobRankDialog", {redData = redData, redRank = redRank, redType = 2})
            -- self:getGuildRedRobRankFinish(redData, result)
        end)
    end
end 

function GuildRedRobLayer:robProcessData(data, redData)
    for i,v in ipairs(data) do
        v.rank = i 
        v.gemValue = v.score
        if redData["best"] == v["name"] then
            v.rank = 0
        end
    end
    if table.nums(data) <= 1 then
        return
    end

    local sortFunc = function(a, b) 
        -- local acheck = a.rank
        -- local bcheck = b.rank
        local acheck = a.score
        local bcheck = b.score
        if acheck == nil then
            return
        end
        if bcheck == nil then
            return
        end 
        if acheck ~= bcheck then
            return acheck > bcheck
        end

        -- if acheck == bcheck then
        --     -- if atime ~= btime then
        --     --     return atime < btime
        --     -- end
        -- else
        --     return acheck > bcheck
        -- end
    end

    table.sort(data, sortFunc)
    return tempData
end

function GuildRedRobLayer:robGuildUserRedFinish(result)
    if result == nil then 
        return 
    end

    self._viewMgr:lock(-1)

    self._viewMgr:showDialog("guild.redgift.GuildEffectLayer", {data = result, callback = function()
        self._viewMgr:unlock()
        DialogUtils.showGiftGet({gifts = result["reward"]})
        self._redRobData = self._modelMgr:getModel("GuildRedModel"):getRobList()
        self._tableView:reloadData()
        end}, true)

    if table.nums(self._redRobData) == 0 then
        self._nothing:setVisible(true)
    else
        self._nothing:setVisible(false)
    end
end


return GuildRedRobLayer
