--[[
    Filename:    GuildInView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-04-18 21:33:26
    Description: File description
--]]

-- 加入联盟界面
local GuildInView = class("GuildInView", BaseView)

function GuildInView:ctor(data)
    GuildInView.super.ctor(self)
    self.initAnimType = 3
    self._allianceListData = {}
    self._inFirst = false

    self._cellHeight = 106

    self._guildModel = self._modelMgr:getModel("GuildModel")
end

function GuildInView:onInit()
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("guild.join.GuildInView")
        end
    end)
    -- [[ 板子动画
    self._playAnimBg = self:getUI("bg.frame")
    self._playAnimBgOffX = 0
    self._playAnimBgOffY = -24
    --]]
    -- local xiaoren = self:getUI("bg.xiaoren.xiaoren")
    -- xiaoren:loadTexture("asset/bg/global_reward_img.png")

    local seedAlliance = self:getUI("bg.titleBg.seedAlliance")
    self:registerClickEvent(seedAlliance, function()
        print("搜索联盟")
        self._viewMgr:showDialog("guild.join.GuildInSeekLayer")
    end)

    local createAlliance = self:getUI("bg.titleBg.createAlliance")
    self:registerClickEvent(createAlliance, function()
        print("创建联盟")
        --加联盟24小时限制
        if not self._guildModel:canJoin() then
            local str = self._guildModel:getJoinLeftTime()
            self._viewMgr:showTip(lang("GUILD_EXIT_TIPS_2")..str)
            return
        end
        self._viewMgr:showDialog("guild.join.GuildInEstablishLayer")
    end)

    local createNoneAlliance = self:getUI("bg.noneIcon.createAlliance")
    self:registerClickEvent(createNoneAlliance, function()
        print("创建联盟")
        --加联盟24小时限制
        if not self._guildModel:canJoin() then
            local str = self._guildModel:getJoinLeftTime()
            self._viewMgr:showTip(lang("GUILD_EXIT_TIPS_2")..str)
            return
        end
        self._viewMgr:showDialog("guild.join.GuildInEstablishLayer")
    end)


    local quickAdd = self:getUI("bg.titleBg.quickAdd")
    self:registerClickEvent(quickAdd, function()
        self:quickJoinGuild()
    end)

    local noneIcon = self:getUI("bg.noneIcon")
    noneIcon:setVisible(false)

    local topTitle = self:getUI("bg.topTitle")
    if topTitle then
        topTitle:setVisible(true)
    end
    -- self:getApplyGuildList()
    -- self:reflashUI()
    self:addTableView()
    self:addAnimBg()

    -- 添加加载中动画
    local tableViewBg = self:getUI("bg.tableViewBg")
    self._loadingMc = mcMgr:createViewMC("jiazaizhong_rankjiazaizhong", true, false, function (_, sender)      end)
    self._loadingMc:setPosition(cc.p(tableViewBg:getContentSize().width * 0.5 - 30, 330))
    tableViewBg:addChild(self._loadingMc, 0)
    self._loadingMc:setVisible(false)

    self._modelMgr:getModel("GuildModel"):forceCleanBubble()

end

function GuildInView:reflashUI(data)
    -- self._allianceListData = {}
    -- print("刷新数据")
    -- print(table.nums(self._allianceListData))
    -- if table.nums(self._allianceListData) == 0 then
        -- self._nowPage = 0
        -- self:getApplyGuildList()
    -- end
end

function GuildInView:onBeforeAdd(callback, errorCallback)
    self._onBeforeAddCallback = function(inType)
        if inType == 1 then 
            callback()
        else
            errorCallback()
        end
    end
    self:getApplyGuildList(false, 1)
end

function GuildInView:getApplyGuildList(inFirst, lastPage)
    -- print("载入=============数据====", lastPage)
    if not self._nowPage then
        self._nowPage = 0
        self._maxpage = 2
    end
    if (self._maxpage - 1) >= self._nowPage + lastPage then
        local param = {page = self._nowPage + lastPage or 0}
        if inFirst == false then
            param = {page = 0}
        end
        self._page = self._nowPage
        self._serverMgr:sendMsg("GuildServer", "getApplyGuildList", param, true, {}, function (result)
            -- dump(result)
            if inFirst == false then
                self:getApplyGuildListFinish(result)
            else
                self:getApplyGuildListFinish1(result, lastPage)
            end
        end)
    end
end

function GuildInView:getApplyGuildListFinish1(result, lastPage)
    if result == nil then
        return 
    end
    -- local num
    -- if lastPage > 0 then
    --     num = 1 -- tonumber(table.nums(self._allianceListData)) - 9
    -- else
    --     num = 2 -- tonumber(table.nums(self._allianceListData)) - 8
    -- end
    local posNum = tonumber(table.nums(self._allianceListData))

    -- if next(result["guildList"]) then
    --     local flag = false
    --     for i=1,#result["guildList"] do
    --         for k,v in pairs(self._allianceListData) do
    --             if result["guildList"][i]["_id"] == v["_id"] then
    --                 flag = true
    --             end
    --         end
    --         if flag == false then
    --             num = num + 1
    --             -- table.insert(self._allianceListData, result["guildList"][i])
    --         end
    --         flag = false
    --     end
    -- end

    -- self._allianceListData = result["guildList"]
    -- if table.nums(self._allianceListData) == 0 then
    --     self:nothingAlliance()5
    -- end
    self._allianceListData = result["guildList"]
    self._nowPage = result["nowPage"]
    self._maxpage = result["maxPage"]

    -- local offsetY = self._tableView:getContentOffset().y

    self._tableView:reloadData()
    -- self:scrollToNext(num)

    local num
    if lastPage > 0 then
        num = tonumber(table.nums(self._allianceListData)) - 12
    else
        num = tonumber(table.nums(self._allianceListData)) - 11
    end

    -- print("+++,", self._page, self._nowPage)
    if (table.nums(self._allianceListData) - 10) >= 2 then
        if self._nowPage == 1 and self._page == self._nowPage then
            return
        end
        self._tableView:setContentOffset(cc.p(0, -1*num*self._cellHeight))
    else
        print("+++++2")
        if table.nums(self._allianceListData) < 4 then
            print("+++++21")
        else
            self._tableView:setContentOffset(cc.p(0, 0))
            print("+++++22")
        end
    end
end

function GuildInView:getApplyGuildListFinish(result)
    if result == nil then
        self._onBeforeAddCallback(2)
        return 
    end
    self._onBeforeAddCallback(1)
    self._allianceListData = result["guildList"]
    if table.nums(self._allianceListData) == 0 then
        self:nothingAlliance()
    end
    self._nowPage = result["nowPage"]
    self._maxpage = result["maxPage"]
    self._tableView:reloadData()

    -- 首次进入游戏定位
    if self._inFirst == false then
        self:scrollToNext()
        self._inFirst = true
    end
end

function GuildInView:nothingAlliance()
    -- local xiaoren = self:getUI("bg.xiaoren.xiaoren")
    -- xiaoren:setVisible(false)
    local seedAlliance = self:getUI("bg.titleBg.seedAlliance")
    seedAlliance:setVisible(false)
    local createAlliance = self:getUI("bg.titleBg.createAlliance")
    createAlliance:setVisible(false)
    local quickAdd = self:getUI("bg.titleBg.quickAdd")
    quickAdd:setVisible(false)

    local noneIcon = self:getUI("bg.noneIcon")
    noneIcon:setVisible(true)

    local topTitle = self:getUI("bg.topTitle")
    if topTitle then
        topTitle:setVisible(false)
    end

    -- spineMgr:createSpine("xinshouyindao", function (spine)
    --     -- spine:setVisible(false)
    --     spine.endCallback = function ()
    --         spine:setAnimation(0, "pingdan", true)
    --     end 
    --     local anim = "pingdan"
    --     spine:setAnimation(0, anim, true)
    --     spine:setPosition(-80, 0)
    --     spine:setScale(0.8)
    --     noneIcon:addChild(spine)
    -- end)
end

-- 快速加入
function GuildInView:quickJoinGuild()
    local allianceId = self._modelMgr:getModel("UserModel"):getData().guildId
    if allianceId and allianceId ~= 0 then
        self._viewMgr:showTip("你已加入联盟")
        self._viewMgr:showView("guild.GuildView")
        self._viewMgr:popView()
        return
    end
    --加联盟24小时限制
    if not self._guildModel:canJoin() then
        local str = self._guildModel:getJoinLeftTime()
        self._viewMgr:showTip(lang("GUILD_EXIT_TIPS_2")..str)
        return
    end

    print("快速加入")
    self._viewMgr:showDialog("global.GlobalSelectDialog", {
        desc = lang("GUILD_JOIN_TIP1"),
        button1 = "确认", 
        button2 = "取消", 
        callback1 = function()
            self._serverMgr:sendMsg("GuildServer", "joinGuildQuickly", {}, true, {}, function(result)
                dump(result)
                self._viewMgr:showView("guild.GuildView")
                self._viewMgr:popView()
            end, function(errorId)
                if tonumber(errorId) == 2715 then
                    self._viewMgr:showTip("未找到合适的联盟")
                end
            end)
        end}, true)
end

--[[
用tableview实现
--]]
function GuildInView:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:registerScriptHandler(function( view ) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:registerScriptHandler(function( view ) return self:scrollViewDidZoom(view) end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(true)
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    
    tableViewBg:addChild(self._tableView)
    self._tableViewHeight = tableViewBg:getContentSize().height
end

--刷新之后tableView 的定位
-- function GuildInView:searchForPosition() 
--     self._tableData = self._leagueModel:getRank()

--     local tab = self._leagueModel:getCurrRankTab()
--     local subNum = #self._tableData - (tab - 1)*20
--     if subNum < 20 then
--         self._offsetY = -1 * (tonumber(subNum) * (self._tableCellH+5))          
--     else
--         self._offsetY = -1 * 20 * (self._tableCellH+5)          
--     end
    
-- end

function GuildInView:scrollViewDidScroll(view)
    self._offsetY = view:getContentOffset().y
    local minY = 0 - #self._allianceListData * self._cellHeight + self._tableViewHeight 
    local isDragging = view:isDragging()
    
    if isDragging then
        -- print("minY ===", isDragging, minY, self._offsetY)
        if self._offsetY >= 0 then
            if (self._offsetY - minY) > 60 and not self._reRequest then
                self._loadingMc:setPositionY(20)
                self._reRequest = true
                self._loadingMc:setVisible(true)
            elseif self._offsetY < 260 and not self._reRequest then
                self._loadingMc:setPositionY(330)
                self._reRequest = true
                self._loadingMc:setVisible(true)
            end

            if self._offsetY < 30 and self._reRequest then
                self._reRequest = false
                self._loadingMc:setVisible(false)
            end
        else
            if self._offsetY < minY - 60 and not self._reRequest then
                self._loadingMc:setPositionY(330)
                self._reRequest = true
                self._loadingMc:setVisible(true)
            end
            if self._offsetY > minY - 30 and self._reRequest then
                self._reRequest = false
                self._loadingMc:setVisible(false)
            end
        end
    else
        -- if self._reRequest and minY == self._offsetY then
        --     self._reRequest = false
        --     -- 请求
        --     self._loadingMc:setVisible(false)
        --     if self._updateMailTick == nil or socket.gettime() > self._updateMailTick + 5 then
        --         self:attain()
        --         self._updateMailTick = socket.gettime()
        --     end
        -- end
        if self._reRequest and 0 == self._offsetY then
            self._reRequest = false
            -- 请求
            self._loadingMc:setVisible(false)
            if self._updateMailTick == nil or socket.gettime() > self._updateMailTick + 5 then
                self:getApplyGuildList(true, 1)
                self._updateMailTick = socket.gettime()
            end
        elseif self._reRequest and minY == self._offsetY then
            self._reRequest = false
            -- 请求
            self._loadingMc:setVisible(false)
            if self._updateMailTick == nil or socket.gettime() > self._updateMailTick + 5 then
                self:getApplyGuildList(true, -1)
                self._updateMailTick = socket.gettime()
            end
        end
    end
end

-- function GuildInView:attain()
--     print("++++++++++++++selectedIndex========")
-- end

function GuildInView:scrollToNext(selectedIndex)
    -- dump(self._allianceListData, "self._allianceListData===")

    selectedIndex = selectedIndex or 0
    for k,v in pairs(self._allianceListData) do
        if v.roleNumLimit <= v.roleNum then
            selectedIndex = selectedIndex + 1
        end
    end
    -- print("selectedIndex========", selectedIndex)

    local tempheight = self._cellHeight*(#self._allianceListData) -- self._tableView:getContentSize().height
    local downBg = self:getUI("bg.tableViewBg")
    local tabHeight = tempheight - downBg:getContentSize().height
    if tempheight < downBg:getContentSize().height then
        print("+++1")
        self._tableView:setContentOffset(cc.p(0, self._tableView:getContentOffset().y))
    else
        if (tempheight - (selectedIndex)*self._cellHeight) > downBg:getContentSize().height then
            print("+++4")
            self._tableView:setContentOffset(cc.p(0, -1*(tabHeight - self._cellHeight*selectedIndex)))
        else
            print("+++5")
            self._tableView:setContentOffset(cc.p(0, -1*tabHeight))
        end
    end
end

function GuildInView:scrollViewDidZoom(view)

end

-- 触摸时调用
function GuildInView:tableCellTouched(table,cell)
    -- self._viewMgr:showDialog("guild.GuildDetailDialog")
    -- print("==========================", cell:getIdx() + 1)
end

-- cell的尺寸大小
function GuildInView:cellSizeForTable(table,idx) 
    local width = 840 
    local height = self._cellHeight
    return height, width
end

-- 创建在某个位置的cell
function GuildInView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()

    local indexId = idx+1
    local param = {allianceD = self._allianceListData[indexId], id = indexId}
    if nil == cell then
        cell = cc.TableViewCell:new()
        local aiCell = self._viewMgr:createLayer("guild.join.GuildInCell",{applyJoinBack = function(tempId, hadApply)
            -- print ("加入数据", tempId, hadApply)
            -- dump(self._allianceListData[tempId],"self._allianceListData[tempId] ==========")
            -- self._allianceListData[tempId].hadApply = hadApply
            -- dump(self._allianceListData[tempId],"self._allianceListData[tempId] =====++++++++++++++++++++++=====")
        end, cancelApplyJoinBack = function(tempId)
            -- print ("数据", tempId)
            -- dump(self._allianceListData[tempId],"self._allianceListData[tempId] ==========")
            -- self._allianceListData[tempId].hadApply = 1
            -- dump(self._allianceListData[tempId],"self._allianceListData[tempId] =====================")
        end})
        aiCell:setName("aiCell")
        cell:addChild(aiCell)
        aiCell:reflashUI(param)
        aiCell:setSwallowTouches(false)
    else
        local aiCell = cell:getChildByName("aiCell")
        if aiCell then
            aiCell:reflashUI(param)
            aiCell:setSwallowTouches(false)
        end
    end
    return cell

end

-- 返回cell的数量
function GuildInView:numberOfCellsInTableView(table)
    return self:tableNum() -- 10 -- #self._allianceListData -- 20 --table.nums(self._guildData)
end

function GuildInView:tableNum()
    return table.nums(self._allianceListData)
end


-- function GuildInView:setNavigation()
--      self._viewMgr:showNavigation("global.UserInfoView",{hideBtn = true,hideInfo=true})
-- end

function GuildInView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{types = {"Texp","Gold","Gem"},title = "globalTitleUI_alliance.png",titleTxt = "联盟"})
end

function GuildInView:getAsyncRes()
    return {
        {"asset/ui/alliance2.plist", "asset/ui/alliance2.png"},
        {"asset/ui/alliance1.plist", "asset/ui/alliance1.png"}
    }
end

function GuildInView:getBgName()
    return "bg_001.jpg" 
end

function GuildInView:setNoticeBar()
    self._viewMgr:hideNotice(false)
end

-- function GuildInView:onDoGuide(config)
--     -- dump(config, "config===", 10)
--     if config.showYindao ~= nil then
--         local yindao = self:getUI("yindao")
--         yindao:loadTexture("asset/bg/alliance_fenxiang1.png")
--         yindao:setVisible(true)
--     end
-- end

return GuildInView
