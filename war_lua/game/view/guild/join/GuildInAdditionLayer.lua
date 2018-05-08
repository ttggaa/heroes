-- --[[
--     Filename:    GuildInAdditionLayer.lua
--     Author:      <qiaohuan@playcrab.com>
--     Datetime:    2016-04-20 20:09:08
--     Description: File description
-- --]]

-- -- 联盟加入
-- local GuildInAdditionLayer = class("GuildInAdditionLayer", BaseLayer)

-- function GuildInAdditionLayer:ctor()
--     GuildInAdditionLayer.super.ctor(self)
--     self._allianceListData = {}
-- end

-- function GuildInAdditionLayer:onInit()
--     local name = self:getUI("bg.titleBg.name")
--     local personNum = self:getUI("bg.titleBg.personNum")
--     local limit = self:getUI("bg.titleBg.limit")

--     name:setFontName(UIUtils.ttfName)
--     personNum:setFontName(UIUtils.ttfName)
--     limit:setFontName(UIUtils.ttfName)
--     name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     personNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     limit:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     name:setFontSize(24)
--     personNum:setFontSize(24)
--     limit:setFontSize(24)

--     local quickAdd = self:getUI("bg.titleBg.quickAdd")
--     quickAdd:setTitleFontSize(22)
--     quickAdd:setTitleFontName(UIUtils.ttfName)
--     quickAdd:setTitleColor(cc.c3b(255,255,255))
--     quickAdd:getTitleRenderer():enableOutline(cc.c4b(60,30,10,255), 2)
--     self:registerClickEvent(quickAdd, function()
--         self:quickJoinGuild()
--     end)
--     -- self:getApplyGuildList()
--     -- self:reflashUI()
--     self:addTableView()
-- end

-- function GuildInAdditionLayer:reflashUI(data)
--     self._allianceListData = {}
--     print("刷新数据")
--     print(table.nums(self._allianceListData))
--     -- if table.nums(self._allianceListData) == 0 then
--         self._page = 0
--         self:getApplyGuildList()
--     -- end

-- end

-- function GuildInAdditionLayer:getApplyGuildList()
--     print("载入=============数据====")
--     local param = {teamId = self._page or 0}
--     self._serverMgr:sendMsg("GuildServer", "getApplyGuildList", param, true, {}, function (result)
--         -- dump(result)
--         self:getApplyGuildListFinish(result)
--     end)
-- end

-- function GuildInAdditionLayer:getApplyGuildListFinish(result)
--     if result == nil then 
--         return 
--     end
--     self._allianceListData = result["guildList"]
--     self._page = result["nowPage"]
--     self._tableView:reloadData()
-- end

-- function GuildInAdditionLayer:quickJoinGuild()
--     local allianceId = self._modelMgr:getModel("UserModel"):getData().guildId
--     if allianceId and allianceId ~= 0 then
--         self._viewMgr:showTip("你已加入联盟")
--         self._viewMgr:showView("guild.GuildView")
--         self._viewMgr:popView()
--         return
--     end
--     print("快速加入")
--     self._serverMgr:sendMsg("GuildServer", "joinGuildQuickly", {}, true, {}, function(result)
--         dump(result)
--         self._viewMgr:showView("guild.GuildView")
--         self._viewMgr:popView()
--     end, function(errorId)
--         if tonumber(errorId) == 2715 then
--             self._viewMgr:showTip("未找到合适的联盟")
--         end
--     end)
-- end

-- --[[
-- 用tableview实现
-- --]]
-- function GuildInAdditionLayer:addTableView()
--     local tableViewBg = self:getUI("bg.tableViewBg")
--     self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
--     self._tableView:setDelegate()
--     self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
--     self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
--     self._tableView:setPosition(cc.p(0, 0))
--     self._tableView:registerScriptHandler(function( view ) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
--     self._tableView:registerScriptHandler(function( view ) return self:scrollViewDidZoom(view) end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
--     self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
--     self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
--     self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
--     self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
--     self._tableView:setBounceable(true)
--     -- if self._tableView.setDragSlideable ~= nil then 
--     --     self._tableView:setDragSlideable(true)
--     -- end
    
--     tableViewBg:addChild(self._tableView)
-- end

-- function GuildInAdditionLayer:scrollViewDidScroll(view)
--     self._inScrolling = view:isDragging()
--     -- -- if self._inScrolling then
--     self._tableOffset = view:getContentOffset()
-- end

-- function GuildInAdditionLayer:scrollViewDidZoom(view)

-- end

-- -- 触摸时调用
-- function GuildInAdditionLayer:tableCellTouched(table,cell)

--     -- self._viewMgr:showDialog("guild.GuildDetailDialog")
--     -- print("==========================", cell:getIdx() + 1)
-- end

-- -- cell的尺寸大小
-- function GuildInAdditionLayer:cellSizeForTable(table,idx) 
--     local width = 760 
--     local height = 122
--     return height, width
-- end

-- -- 创建在某个位置的cell
-- function GuildInAdditionLayer:tableCellAtIndex(table, idx)
--     local cell = table:dequeueCell()
--     -- local typeId = 4
--     -- if math.fmod(idx+1, 4) ~= 0 then
--     --     typeId = math.fmod(idx+1, 4)
--     -- end
--     -- local flag = false
--     -- if idx+1 > self:tableNum() then
--     --     flag = true
--     --     self._page = 1
--     -- elseif idx+1 < self:tableNum() then
--     --     flag = true
--     --     self._page = -1
--     -- end
--     -- if flag == true then
--     --     print("请求数据")
--     --     return
--     -- end

--     local indexId = idx+1
--     local param = {allianceD = self._allianceListData[indexId], id = indexId}
--     if nil == cell then
--         cell = cc.TableViewCell:new()
--         local aiCell = self._viewMgr:createLayer("guild.join.GuildInCell",{applyJoinBack = function(tempId, hadApply)
--             -- print ("加入数据", tempId, hadApply)
--             -- dump(self._allianceListData[tempId],"self._allianceListData[tempId] ==========")
--             -- self._allianceListData[tempId].hadApply = hadApply
--             -- dump(self._allianceListData[tempId],"self._allianceListData[tempId] =====++++++++++++++++++++++=====")
--         end, cancelApplyJoinBack = function(tempId)
--             -- print ("数据", tempId)
--             -- dump(self._allianceListData[tempId],"self._allianceListData[tempId] ==========")
--             -- self._allianceListData[tempId].hadApply = 1
--             -- dump(self._allianceListData[tempId],"self._allianceListData[tempId] =====================")
--         end})
--         aiCell:setName("aiCell")
--         cell:addChild(aiCell)
--         aiCell:reflashUI(param)
--         aiCell:setSwallowTouches(false)
--     else
--         local aiCell = cell:getChildByName("aiCell")
--         if aiCell then
--             aiCell:reflashUI(param)
--             aiCell:setSwallowTouches(false)
--         end
--     end
--     return cell
-- end

-- -- 返回cell的数量
-- function GuildInAdditionLayer:numberOfCellsInTableView(table)
--     return self:tableNum() -- 10 -- #self._allianceListData -- 20 --table.nums(self._guildData)
-- end

-- function GuildInAdditionLayer:tableNum()
--     return table.nums(self._allianceListData)
-- end

-- -- local callback = function(guildId, id, typeId)
-- --     if typeId == 1 then
-- --         print("申请" .. allianceD._id)
-- --         self:applyJoin(allianceD._id, data.id, typeId)
-- --     elseif typeId == 2 then
-- --         self:cancelApplyJoin(allianceD._id, data.id)
-- --         print("取消申请" .. allianceD._id)
-- --     elseif typeId == 3 then
-- --         self:applyJoin(allianceD._id, data.id, typeId)
-- --         -- self:JoinAlliance(allianceD._id)
-- --         print("加入" .. allianceD._id)
-- --     end
-- -- end

-- -- -- 请求改变数据
-- -- function GuildInAdditionLayer:getGuildById(guildId)
-- --     print("载入=============数据====")
-- --     local param = {guildId = guildId}
-- --     self._serverMgr:sendMsg("GuildServer", "getGameGuildBaseInfo", param, true, {}, function (result)
-- --         dump(result)
-- --     end)
-- -- end 

-- -- -- 加入联盟
-- -- function GuildInAdditionLayer:applyJoin(guildId, id, typeId)
-- --     print("载入=============数据====")
-- --     local param = {guildId = guildId}
-- --     self._serverMgr:sendMsg("GuildServer", "applyJoin", param, true, {}, function (result)
-- --         -- dump(result)
-- --         if not result["d"] then
-- --             print ("=============", typeId)
-- --             self._limitLab:setString("需审批")
-- --             self._allianceData["allianceD"]["hadApply"] = 1
-- --             self:reflashUI(self._allianceData)
-- --             self._applyJoinBack(id, 1)
-- --         else 
-- --             self._viewMgr:showView("guild.GuildView")
-- --             self._viewMgr:popView()
-- --         end
-- --         -- self:applyJoinFinish(result)
-- --     end,function(errorId)
-- --         if tonumber(errorId) == 2711 then
-- --             self._viewMgr:showTip("联盟申请人数已满")
-- --         end
-- --     end)
-- -- end 

-- -- -- 取消申请
-- -- function GuildInAdditionLayer:cancelApplyJoin(guildId, id)
-- --     print("载入=============数据====")
-- --     local param = {guildId = guildId}
-- --     self._serverMgr:sendMsg("GuildServer", "cancelApplyJoin", param, true, {}, function (result)
-- --         self._allianceData["allianceD"]["hadApply"] = 0
-- --         self:reflashUI(self._allianceData)
-- --         self._applyJoinBack(id, 0)
-- --         -- self:cancelApplyJoinFinish(result)
-- --     end)
-- -- end

-- return GuildInAdditionLayer
