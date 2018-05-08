--[[
    Filename:    GuildManageRankLayer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-04-22 18:17:11
    Description: File description
--]]

-- local GuildManageRankLayer = class("GuildManageRankLayer", BaseLayer)

-- function GuildManageRankLayer:ctor()
--     GuildManageRankLayer.super.ctor(self)
--     self._allianceRank = {}
-- end

-- function GuildManageRankLayer:onInit()
--     self._cell = self:getUI("rankItem")
--     -- local test = self._cell:clone()
--     -- test:setPosition(cc.p(20,200))
--     -- self:addChild(test)  
--     local lab1 = self:getUI("bg.panel.lab1")
--     lab1:setFontName(UIUtils.ttfName)
--     lab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     lab1:setFontSize(24)
--     local lab2 = self:getUI("bg.panel.lab2")
--     lab2:setFontName(UIUtils.ttfName)
--     lab2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     lab2:setFontSize(24)
--     local lab3 = self:getUI("bg.panel.lab3")
--     lab3:setFontName(UIUtils.ttfName)
--     lab3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     lab3:setFontSize(24)
--     local lab4 = self:getUI("bg.panel.lab4")
--     lab4:setFontName(UIUtils.ttfName)
--     lab4:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     lab4:setFontSize(24)

--     self:getGuildListRank()
--     self:addTableView()
-- end



-- --[[
-- 用tableview实现
-- --]]
-- function GuildManageRankLayer:addTableView()
--     local tableViewBg = self:getUI("bg.tableViewBg")
--     self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
--     self._tableView:setDelegate()
--     self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
--     self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
--     self._tableView:setPosition(cc.p(0, -5))
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


-- -- 触摸时调用
-- function GuildManageRankLayer:tableCellTouched(table,cell)
--     local indexId = cell:getIdx() + 1
--     self._viewMgr:showDialog("guild.dialog.GuildDetailDialog", {allianceD = self._allianceRank[indexId]})
-- end

-- -- cell的尺寸大小
-- function GuildManageRankLayer:cellSizeForTable(table,idx) 
--     local width = 757 
--     local height = 88
--     return height, width
-- end

-- -- 创建在某个位置的cell
-- function GuildManageRankLayer:tableCellAtIndex(table, idx)
--     local cell = table:dequeueCell()
--     local param = {typeId = 3, id = 1}
--     local indexId = idx + 1
--     local param = {allianceD = self._allianceRank[indexId], indexId = indexId}
--     if nil == cell then
--         cell = cc.TableViewCell:new()
--         local agreeCell = self._cell:clone() -- self._viewMgr:createLayer("guild.GuildInCell")
--         agreeCell:setAnchorPoint(cc.p(0, 0))
--         agreeCell:setPosition(cc.p(6, 0))
--         agreeCell:setName("agreeCell")
--         cell:addChild(agreeCell)

--         local UIscoreLab = agreeCell:getChildByFullName("scoreLab")
--         UIscoreLab:setVisible(false)
--         local scoreLab = ccui.TextBMFont:create("0", UIUtils.bmfName_zhandouli_little)
--         scoreLab:setAnchorPoint(cc.p(0.1, 0.5))
--         scoreLab:setName("scoreLab1")
--         scoreLab:setScale(0.8)
--         scoreLab:setPosition(UIscoreLab:getPosition())
--         UIscoreLab:getParent():addChild(scoreLab,1)

--         local nameLab = agreeCell:getChildByFullName("nameLab")
--         nameLab:setFontName(UIUtils.ttfName)
--         nameLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2) 

--         local playerName = agreeCell:getChildByFullName("playerName")
--         playerName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2) 

--         local levelLab = agreeCell:getChildByFullName("levelLab")
--         levelLab:setFontName(UIUtils.ttfName)
--         levelLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2) 

--         local rankLab = agreeCell:getChildByFullName("rankLab")
--         rankLab:setFntFile(UIUtils.bmfName_rank)
--         -- rankLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2) 
--         -- rankLab:setColor(cc.c3b(250, 250, 58))
--         -- rankLab:enable2Color(1, cc.c4b(239, 149, 52, 255))
--         -- rankLab:setFontSize(48)

--         self:updateCell(agreeCell, param)
--         -- agreeCell:setSwallowTouches(false)
--     else
--         local agreeCell = cell:getChildByName("agreeCell")
--         if agreeCell then
--             self:updateCell(agreeCell, param)
--             -- agreeCell:setSwallowTouches(false)
--         end
--     end
--     return cell
-- end

-- -- 返回cell的数量
-- function GuildManageRankLayer:numberOfCellsInTableView(table)
--     return self:tableNum() 
-- end

-- function GuildManageRankLayer:tableNum()
--     return table.nums(self._allianceRank)
-- end


-- function GuildManageRankLayer:reflashUI(data)
--     -- local flag = self._modelMgr:getModel("GuildModel"):getRankReflashDeclare()
--     -- if flag == true then
--     if true then
--         local guildId = self._modelMgr:getModel("UserModel"):getData()["guildId"]
--         local guildData = self._modelMgr:getModel("GuildModel"):getAllianceDetail()
--         for k,v in pairs(self._allianceRank) do
--             if v["_id"] == guildId then
--                 v["declare"] = guildData["declare"]
--                 break
--             end
--         end
--     end
--     self._tableView:reloadData()
-- end

-- function GuildManageRankLayer:updateCell(inView, data)
--     if data["allianceD"] == nil then
--         return
--     end

--     -- dump (data, "data ================")
--     local allianceD = data["allianceD"]

--     local userId = self._modelMgr:getModel("GuildModel"):getAllianceDetail()["guildId"]
--     -- dump (userId, "data ================")
--     -- local cellBg = inView:getChildByFullName("cellBg")
--     if inView then
--         if userId == allianceD["_id"] then
--             inView:loadTexture("arenaRankUI_cellBg1.png", 1)
--         else
--             inView:loadTexture("arenaRankUI_cellBg1.png", 1)
--         end
--     end
--     -- 头像
--     -- local iconBg = self:getUI("bg.iconBg")
--     local headNode = inView:getChildByName("headNode")
--     local avatarIcon = headNode:getChildByName("avatarIcon")
--     local param = {flags = allianceD.avatar1 or 101, logo = allianceD.avatar2 or 201}
--     if not avatarIcon then
--         avatarIcon = IconUtils:createGuildLogoIconById(param)
--         avatarIcon:setName("avatarIcon")
--         avatarIcon:setScale(0.7)
--         avatarIcon:setPosition(cc.p(5, -2))
--         headNode:addChild(avatarIcon)
--     else
--         IconUtils:updateGuildLogoIconByView(avatarIcon, param)
--     end

--     local nameLab = inView:getChildByFullName("nameLab")
--     if nameLab then
--         local str = allianceD.name
--         nameLab:setString(str)
--         print("nameLab:getContentSize().width ==========" .. nameLab:getContentSize().width)
--         if nameLab:getContentSize().width > 200 then
--             str = self:limitLen(str, 10) .. "..."
--         end
--         nameLab:setString(str)
--     end

--     local playerName = inView:getChildByFullName("playerName")
--     if playerName then
--         playerName:setString(allianceD.mName)
--     end

--     local levelLab = inView:getChildByFullName("levelLab")
--     if levelLab then
--         levelLab:setString("Lv." .. allianceD.level)
--     end

--     local scoreLab = inView:getChildByFullName("scoreLab1")
--     if scoreLab then
--         scoreLab:setString(allianceD.score)
--     end

--     local rankLab = inView:getChildByFullName("rankLab")
--     if rankLab then
--         rankLab:setString(allianceD.rank)
--         rankLab:setVisible(false)
--     end

--     for i=1,3 do
--         local rankImg = inView:getChildByFullName("rankImg" .. i)
--         if rankImg then
--             rankImg:setVisible(false)
--         end
--     end
--     if allianceD.rank == 1 then
--         playerName:setColor(cc.c3b(253,195,33))
--         local rankImg = inView:getChildByFullName("rankImg1")
--         local rankmc1 = rankImg:getChildByName("rankmc1")
--         if not rankmc1 then
--             rankmc1 = mcMgr:createViewMC("diyiming_paimingeffect", true, false, function (_, sender)
--             end)
--             rankmc1:setName("rankmc1")
--             rankmc1:setScale(0.8)
--             rankmc1:setPosition(cc.p(rankImg:getContentSize().width*0.5, rankImg:getContentSize().height*0.5 - 2))
--             rankImg:addChild(rankmc1, -1)
--         end
--         -- local rankmc2 = rankImg:getChildByName("rankmc2")
--         -- if not rankmc2 then
--         --     rankmc2 = mcMgr:createViewMC("ersanming_paimingeffect", true, false, function (_, sender)
--         --     end)
--         --     rankmc2:setName("rankmc2")
--         --     rankmc2:setScale(0.8)
--         --     rankmc2:setPosition(cc.p(rankImg:getContentSize().width*0.5, rankImg:getContentSize().height*0.5))
--         --     rankImg:addChild(rankmc2, -1)
--         -- else
--         --     rankmc2:setVisible(true)
--         -- end
--         -- local rankmc3 = rankImg:getChildByName("rankmc3")
--         -- if not rankmc3 then
--         --     rankmc3 = mcMgr:createViewMC("ersanming_paimingeffect", true, false, function (_, sender)
--         --     end)
--         --     rankmc3:setName("rankmc3")
--         --     rankmc3:setScale(0.8)
--         --     rankmc3:setPosition(cc.p(rankImg:getContentSize().width*0.5, rankImg:getContentSize().height*0.5))
--         --     rankImg:addChild(rankmc3, -1)
--         -- else
--         --     rankmc3:setVisible(true)
--         -- end

--         if rankImg then
--             rankImg:setVisible(true)
--         end
--     elseif allianceD.rank == 2 then
--         playerName:setColor(cc.c3b(183,212,218))
--         local rankImg = inView:getChildByFullName("rankImg2")

--         local rankmc2 = rankImg:getChildByName("rankmc2")
--         if not rankmc2 then
--             rankmc2 = mcMgr:createViewMC("ersanming_paimingeffect", true, false, function (_, sender)
--             end)
--             rankmc2:setName("rankmc2")
--             rankmc2:setScale(0.8)
--             rankmc2:setPosition(cc.p(rankImg:getContentSize().width*0.5, rankImg:getContentSize().height*0.5))
--             rankImg:addChild(rankmc2, -1)
--         else
--             rankmc2:setVisible(true)
--         end
--         -- local rankmc2 = rankImg:getChildByName("rankmc2")
--         -- if rankmc2 then
--         --     rankmc2:setVisible(true)
--         -- end
--         -- local rankmc3 = rankImg:getChildByName("rankmc3")
--         -- if rankmc3 then
--         --     rankmc3:setVisible(true)
--         -- end

--         if rankImg then
--             rankImg:setVisible(true)
--         end
--     elseif allianceD.rank == 3 then
--         playerName:setColor(cc.c3b(255,159,101))
--         local rankImg = inView:getChildByFullName("rankImg3")

--         local rankmc3 = rankImg:getChildByName("rankmc3")
--         if not rankmc3 then
--             rankmc3 = mcMgr:createViewMC("ersanming_paimingeffect", true, false, function (_, sender)
--             end)
--             rankmc3:setName("rankmc3")
--             rankmc3:setScale(0.8)
--             rankmc3:setPosition(cc.p(rankImg:getContentSize().width*0.5, rankImg:getContentSize().height*0.5))
--             rankImg:addChild(rankmc3, -1)
--         else
--             rankmc3:setVisible(true)
--         end

--         -- local rankmc1 = rankImg:getChildByName("rankmc1")
--         -- if not rankmc1 then
--         --     rankmc1 = mcMgr:createViewMC("diyiming_paimingeffect", true, false, function (_, sender)
--         --     end)
--         --     rankmc1:setName("rankmc1")
--         --     rankmc1:setPosition(cc.p(rankImg:getContentSize().width*0.5, rankImg:getContentSize().height*0.5))
--         --     rankImg:addChild(rankmc1, 1)
--         -- end
--         -- local rankmc2 = rankImg:getChildByName("rankmc2")
--         -- if rankmc2 then
--         --     rankmc2:setVisible(true)
--         -- end
--         -- local rankmc3 = rankImg:getChildByName("rankmc3")
--         -- if rankmc3 then
--         --     rankmc3:setVisible(true)
--         -- end

--         if rankImg then
--             rankImg:setVisible(true)
--         end
--     else
--         if inView then
--             inView:loadTexture("arenaRankUI_cellBg2.png", 1)
--         end
--         playerName:setColor(cc.c3b(183,181,149))
--         if rankLab then
--             rankLab:setVisible(true)
--         end
--     end
--     -- local rankImg = inView:getChildByFullName("rankImg" .. allianceD.rank)
--     -- if allianceD.rank >= 1 and allianceD.rank <= 3 then
--     --     if rankImg then
--     --         rankImg:setVisible(true)
--     --     end
--     -- else
--     --     if rankLab then
--     --         rankLab:setVisible(true)
--     --     end
--     -- end
-- end

-- -- 数据
-- function GuildManageRankLayer:getGuildListRank()
--     print("载入=============数据====")
--     self._serverMgr:sendMsg("GuildServer", "getGuildListRank", {}, true, {}, function (result)
--         self:getGuildListRankFinish(result)
--     end)
-- end 

-- function GuildManageRankLayer:getGuildListRankFinish(result)
--     if result == nil then 
--         return 
--     end
--     dump(result, "result==============")

--     self._allianceRank = result
--     self:processData(self._allianceRank)
--     self._tableView:reloadData()
-- end

-- function GuildManageRankLayer:processData(data)
--     if table.nums(data) <= 1 then
--         return
--     end
--     local sortFunc = function(a, b) 
--         local acheck = a.rank
--         local bcheck = b.rank
--         if acheck == nil then
--             return
--         end
--         if bcheck == nil then
--             return
--         end
--         if acheck < bcheck then
--             return true
--         end
--     end

--     table.sort(data, sortFunc)
--     -- return tempData
-- end

-- function GuildManageRankLayer:limitLen(str, maxNum)
--     local lenInByte = #str
--     local lenNum = 0
--     for i=1,lenInByte do
--         local curByte = string.byte(str, i)
--         if curByte>0 and curByte<=127 then
--             lenNum = lenNum + 1
--         elseif curByte>=192 and curByte<=247 then
--             lenNum = lenNum + 3
--             maxNum = maxNum + 1
--         end
--         if lenNum >= maxNum then
--             break
--         end
--     end
--     str = string.sub(str, 1, lenNum)
--     return str
-- end


-- return GuildManageRankLayer
