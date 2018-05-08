--[[
    Filename:    GuildManageDetailLayer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-04-22 17:02:35
    Description: File description
--]]

-- local GuildManageDetailLayer = class("GuildManageDetailLayer", BaseLayer)

-- function GuildManageDetailLayer:ctor(param)
--     GuildManageDetailLayer.super.ctor(self)
--     self._callback = param.callback
--     self._membersData = {}
-- end

-- function GuildManageDetailLayer:onInit()
--     for i=1,4 do
--         local lab = self:getUI("bg.panel.lab" .. i)
--         lab:setFontName(UIUtils.ttfName)
--         lab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     end

--     local allianceName = self:getUI("bg.allianceName")
--     allianceName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     allianceName:setFontName(UIUtils.ttfName)
--     local allianceLevel = self:getUI("bg.allianceLevel")
--     allianceLevel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     allianceLevel:setFontName(UIUtils.ttfName)
--     local allianceLab1 = self:getUI("bg.allianceLab1")
--     allianceLab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     local allianceLab3 = self:getUI("bg.allianceLab3")
--     allianceLab3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     local allianceLab2 = self:getUI("bg.allianceLab2")
--     allianceLab2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     local allianceLab4 = self:getUI("bg.allianceLab4")
--     allianceLab4:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     local allianceValue1 = self:getUI("bg.allianceValue1")
--     allianceValue1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     local allianceValue2 = self:getUI("bg.allianceValue2")
--     allianceValue2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     local allianceValue3 = self:getUI("bg.allianceValue3")
--     allianceValue3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     local allianceValue4 = self:getUI("bg.allianceValue4")
--     allianceValue4:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     local lab1 = self:getUI("bg.panel.lab1")
--     lab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     local lab2 = self:getUI("bg.panel.lab2")
--     lab2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     local lab3 = self:getUI("bg.panel.lab3")
--     lab3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     local lab4 = self:getUI("bg.panel.lab4")
--     lab4:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)

--     local changeName = self:getUI("bg.changeName")
--     changeName:setTitleFontSize(22)
--     changeName:setTitleFontName(UIUtils.ttfName)
--     changeName:setTitleColor(cc.c3b(255,255,255))
--     changeName:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     local exitBtn = self:getUI("bg.exitBtn")
--     exitBtn:setTitleFontSize(22)
--     exitBtn:setTitleFontName(UIUtils.ttfName)
--     exitBtn:setTitleColor(cc.c3b(255,255,255))
--     exitBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)

--     self._modelMgr:getModel("GuildModel"):setGuildTempData(true)

--     self._playerCell = self:getUI("cell")
--     self:addTableView()

--     local iconBg = self:getUI("bg.iconBg")
--     local changeName = self:getUI("bg.changeName")
--     if self._modelMgr:getModel("UserModel"):getData()["roleGuild"]["pos"] ~= 3 then
        
--         self._acatar = {}
--         self:registerClickEvent(iconBg, function()
--             if self._modelMgr:getModel("UserModel"):getData()["roleGuild"]["pos"] == 3 then
--                 self._viewMgr:showTip("你已不是联盟管理成员")
--                 return
--             end
--             self._viewMgr:showDialog("guild.dialog.GuildSelectFlagsDialog", {callback = function(param)
--                 self._acatar = param
--                 local guildModel = self._modelMgr:getModel("GuildModel")
--                 local allianceD = guildModel:getAllianceDetail()
--                 allianceD.avatar1 = self._acatar.avatar1
--                 allianceD.avatar2 = self._acatar.avatar2
--                 self:createAvatar()
--             end})
--             print("修改联盟旗子")
--         end)
--         self:registerClickEvent(changeName, function()
--             if self._modelMgr:getModel("UserModel"):getData()["roleGuild"]["pos"] == 3 then
--                 self._viewMgr:showTip("你已不是联盟管理成员")
--                 return
--             end
--             self._viewMgr:showDialog("guild.manager.GuildChangeNameDialog",{callback = function(str)
--                 local allianceName = self:getUI("bg.allianceName")
--                 allianceName:setString(str)
--             end})
--             print("修改联盟名称")
--         end)
--     else
--         changeName:setVisible(false)
--     end
--     local exitBtn = self:getUI("bg.exitBtn")
--     self:registerClickEvent(exitBtn, function()
--         self._viewMgr:showDialog("global.GlobalSelectDialog", {desc = "你确定要退出联盟？", button1 = "", callback1 = function( )
--                 self:quitGuild()
--             end, 
--             button2 = "", callback2 = nil,titileTip=true},true)
--         print("退出联盟")
--     end)
-- end

-- function GuildManageDetailLayer:getGuildInfo()
--     self._serverMgr:sendMsg("GuildServer", "getGameGuildInfo", {}, true, {}, function (result)
--         self._modelMgr:getModel("GuildModel"):setGuildTempData(false)
--         self._tableView:reloadData()
--         -- self:getGuildInfoFinish(result)
--     end)
-- end

-- -- function GuildManageDetailLayer:getGuildInfoFinish(result)
-- --     -- dump(result,"result ===================")
-- --     -- if result == nil then
-- --     --     self._onBeforeAddCallback(2)
-- --     --     return 
-- --     -- end
-- --     -- self._onBeforeAddCallback(1)
-- --     -- self:reflashUI()
-- -- end

-- function GuildManageDetailLayer:reflashUI(data)
--     print("刷新数据")
--     local guildModel = self._modelMgr:getModel("GuildModel")
--     self._membersData = guildModel:getAllianceList()

--     local allianceD = guildModel:getAllianceDetail()
--     -- dump(self._membersData,"allianceD ========")
--     local allianceName = self:getUI("bg.allianceName")
--     allianceName:setString(allianceD.name)
--     local allianceLevel = self:getUI("bg.allianceLevel")
--     allianceLevel:setString("Lv. " .. allianceD.level)
--     local allianceValue1 = self:getUI("bg.allianceValue1")
--     allianceValue1:setString(allianceD.mName)
--     local allianceValue2 = self:getUI("bg.allianceValue2")
--     allianceValue2:setString(allianceD.guildId)
--     local allianceValue3 = self:getUI("bg.allianceValue3")
--     allianceValue3:setString(allianceD.rank)
--     local allianceValue4 = self:getUI("bg.allianceValue4")
--     allianceValue4:setString(allianceD.roleNum .. "/" .. allianceD.roleNumLimit)

--     self._acatar = {avatar1 = allianceD.avatar1, avatar2 = allianceD.avatar2}
--     self:createAvatar()

--     local changeName = self:getUI("bg.changeName")
--     if self._modelMgr:getModel("UserModel"):getData()["roleGuild"]["pos"] ~= 3 then
--         changeName:setVisible(true)
--     else
--         changeName:setVisible(false)
--     end

--     if self._modelMgr:getModel("GuildModel"):getGuildTempData() == true then
--         self:getGuildInfo()
--     else
--         self._tableView:reloadData()
--     end
-- end

-- function GuildManageDetailLayer:updateCell(inView, data)
--     if data == nil then
--         return
--     end
--     -- dump(data,"data ====================")
--     local userId = self._modelMgr:getModel("UserModel"):getData()["_id"]
--     local cellBg = inView:getChildByFullName("cellBg")
--     if cellBg then
--         if userId == data["memberId"] then
--             cellBg:loadTexture("globalPanelUI7_cellBg1.png", 1)
--         else
--             cellBg:loadTexture("globalPanelUI7_cellBg1.png", 1)
--         end
--     end

--     local iconBg = inView:getChildByFullName("iconBg")
--     if iconBg then
--         local param1 = {avatar = data.avatar, tp = 3,avatarFrame = data["avatarFrame"]}
--         local icon = iconBg:getChildByName("icon")
--         if not icon then
--             icon = IconUtils:createHeadIconById(param1)
--             icon:setName("icon")
--             icon:setScale(0.8)
--             icon:setPosition(cc.p(-5,-5))
--             iconBg:addChild(icon)
--         else
--             IconUtils:updateHeadIconByView(icon, param1)
--         end
--     end

--     local name = inView:getChildByFullName("name")
--     if name then
--         name:setString(data.name)
--     end

--     local vipLab = inView:getChildByFullName("vipLab")
--     if vipLab then
--         if data.vipLvl == 0 then
--             vipLab:setVisible(false)
--         else
--             vipLab:setVisible(true)
--         end
--         vipLab:setString("V" .. data.vipLvl)
--         vipLab:setPositionX(name:getPositionX() + name:getContentSize().width + 5)
--     end


--     local level = inView:getChildByFullName("level")
--     if level then
--         level:setString("Lv. " .. data.lvl)
--     end

--     local jobLab = inView:getChildByFullName("jobLab")
--     if jobLab then
--         if data.pos == 1 then
--             jobLab:setString("联盟长")
--             jobLab:setColor(cc.c3b(255,214,24))
--             jobLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--         elseif data.pos == 2 then
--             jobLab:setString("副联盟长")
--             jobLab:setColor(cc.c3b(255,214,24))
--             jobLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--         elseif data.pos == 3 then
--             jobLab:setString("成员")
--             jobLab:setColor(cc.c3b(72,210,255))
--             jobLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--         end
--     end

--     local loginTime = inView:getChildByFullName("loginTime")
--     if loginTime then
--         -- local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
--         -- if not data.leaveTime then
--         --     data.leaveTime = 0
--         -- end
--         -- local tempTime = curServerTime - data.leaveTime
--         if data.online == 1 then
--             loginTime:setString("在线")
--         else
--             loginTime:setString(GuildUtils:getDisTodayTime(data.leaveTime))
--         -- elseif tempTime > 86400 then
--         --     loginTime:setString(math.ceil(tempTime/86400) .. "天前")
--         -- elseif tempTime > 3600 then
--         --     loginTime:setString(math.ceil(tempTime/3600) .. "小时前")
--         -- elseif tempTime > 0 then
--         --     loginTime:setString(math.ceil(tempTime/60) .. "分钟前")
--         end
--     end

--     local contribeValue = inView:getChildByFullName("contribeValue")
--     if contribeValue then
--         contribeValue:setString(data.dNum)
--     end
-- end

-- -- 退出联盟
-- function GuildManageDetailLayer:quitGuild()
--     print("载入=============数据====")
--     self._serverMgr:sendMsg("GuildServer", "quitGuild", {}, true, {}, function (result)
--         self._callback()
--         -- self:quitGuildFinish(result)
--     end)
-- end 

-- -- function GuildManageDetailLayer:quitGuildFinish(result)
-- --     if result == nil then 
-- --         return 
-- --     end
-- -- end

-- function GuildManageDetailLayer:createAvatar()
--     local iconBg = self:getUI("bg.iconBg")
--     local avatarIcon = iconBg:getChildByName("avatarIcon")
--     local param = {flags = self._acatar.avatar1, logo = self._acatar.avatar2}
--     if not avatarIcon then
--         avatarIcon = IconUtils:createGuildLogoIconById(param)
--         iconBg:addChild(avatarIcon)
--     else
--         IconUtils:updateGuildLogoIconByView(avatarIcon, param)
--     end
-- end

-- --[[
-- 用tableview实现
-- --]]
-- function GuildManageDetailLayer:addTableView()
--     local tableViewBg = self:getUI("bg.tableViewBg")
--     self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
--     self._tableView:setDelegate()
--     self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
--     self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
--     self._tableView:setPosition(cc.p(0, 0))
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
-- function GuildManageDetailLayer:tableCellTouched(table,cell)
--     self._viewMgr:showDialog("guild.dialog.GuildPlayerDialog", {detailData = self._membersData[cell:getIdx()+1], dataType = 1}, true)
--     print("==========================", cell:getIdx())
-- end

-- -- cell的尺寸大小
-- function GuildManageDetailLayer:cellSizeForTable(table,idx) 
--     local width = 760 
--     local height = 122
--     return height, width
-- end

-- -- 创建在某个位置的cell
-- function GuildManageDetailLayer:tableCellAtIndex(table, idx)
--     local cell = table:dequeueCell()
--     local param = self._membersData[idx+1]
--     if nil == cell then

--         cell = cc.TableViewCell:new()
--         local playerCell = self._playerCell:clone() 
--         playerCell:setAnchorPoint(cc.p(0,0))
--         playerCell:setPosition(cc.p(1,0))
--         playerCell:setName("playerCell")
--         cell:addChild(playerCell)

--         local vipLab = playerCell:getChildByFullName("vipLab")
--         vipLab:setFntFile(UIUtils.bmfName_vip)
--         local name = playerCell:getChildByFullName("name")
--         name:setFontName(UIUtils.ttfName)
--         name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--         local level = playerCell:getChildByFullName("level")
--         level:setFontName(UIUtils.ttfName)
--         level:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--         local loginTime = playerCell:getChildByFullName("loginTime")
--         loginTime:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--         local contribeValue = playerCell:getChildByFullName("contribeValue")
--         contribeValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)

--         self:updateCell(playerCell, param)
--         playerCell:setSwallowTouches(false)
--     else
--         local playerCell = cell:getChildByName("playerCell")
--         if playerCell then
--             self:updateCell(playerCell, param)
--             playerCell:setSwallowTouches(false)
--         end
--     end

--     return cell
-- end

-- -- 返回cell的数量
-- function GuildManageDetailLayer:numberOfCellsInTableView(table)
--     return #self._membersData --table.nums(self._membersData)
-- end



-- return GuildManageDetailLayer
