--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-04-25 15:17:12
--

-- 选择兵团
local MFSelectHeroTeamView = class("MFSelectHeroTeamView",BasePopView)
function MFSelectHeroTeamView:ctor(param)
    self.super.ctor(self)
    self._selType = param.selType or "team"
    self._callback = param.callback
    self._selectIndex = param.selectIndex
    self._selectData = param.selectData
    self._heros = {} -- tonumber(param.heroId) 
    self._teams = {}
    self._index = 1
end

-- 初始化UI后会调用, 有需要请覆盖
function MFSelectHeroTeamView:onInit()
    self:setSelectData()

    self._title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(self._title, 1)
    -- self._title:setFontName(UIUtils.ttfName)
    -- self._title:setFontSize(30)

    self:registerClickEventByName("bg.closeBtn", function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("MF.MFSelectHeroTeamView")
        end
        self:close()
    end)

    -- 确定
    self:registerClickEventByName("bg.confirm", function()
        self._callback(self._selectData)
        self:close()
    end)

    self._tabEventTarget = {}
    for i=1,2 do
        local tab = self:getUI("bg.tab" .. i)
        tab:setScaleAnim(false)
        self:registerClickEvent(tab, function(sender) self:tabButtonClick(sender) end)
        table.insert(self._tabEventTarget, tab)
        tab:setVisible(false)
    end

    local nothing = self:getUI("bg.nothing")
    nothing:setVisible(false)

    local des1 = self:getUI("bg.scrollBg.des1")
    des1:setFontName(UIUtils.ttfName)
    des1:setColor(cc.c3b(255, 225, 24))
    des1:enable2Color(1, cc.c4b(255, 226, 147, 255))
    des1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    des1:setFontSize(26)
    local des2 = self:getUI("bg.scrollBg.des2")
    des2:setColor(cc.c3b(240,240,0))
    des2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    des2:setFontSize(24)
    local des3 = self:getUI("bg.scrollBg.des3")
    des3:setColor(cc.c3b(240,240,0))
    des3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    des3:setFontSize(24)

    -- 条件显示
    local con1 = self:getUI("bg.layer.panel2.con1")
    con1:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- con1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
    local con2 = self:getUI("bg.layer.panel2.con2")
    con2:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- con2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)

    self._con1 = self:getUI("bg.layer.panel1.con1")
    self._con1:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- self._con1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
    self._con2 = self:getUI("bg.layer.panel1.con2")
    self._con2:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- self._con2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)

    self._teamNode = self:getUI("bg.teamNode")
    self._teamNode:setVisible(false)
    self._heroNode = self:getUI("bg.heroNode")
    self._heroNode:setVisible(false)

    self:addTableView()

    -- self:reflashUI()
    
    if self._selType == "team" then
        self:tabButtonClick(self:getUI("bg.tab2"), false)
    end
end

-- 选项卡状态切换
function MFSelectHeroTeamView:tabButtonState(sender, isSelected)
    -- local tabtxt01 = sender:getChildByFullName("tabtxt_01")
    -- local tabtxt02 = sender:getChildByFullName("tabtxt_02")
    local tabtxt = sender:getChildByFullName("tabtxt")
    tabtxt:setFontName(UIUtils.ttfName)

    sender:setBright(not isSelected)
    sender:setEnabled(not isSelected)
    -- tabtxt01:setVisible(not isSelected)
    -- tabtxt02:setVisible( isSelected)

    if isSelected then
        tabtxt:setColor(cc.c3b(255,250,220))
        tabtxt:enableOutline(cc.c4b(65,65,65,255), 1)
        tabtxt:setFontSize(32)
    else
        tabtxt:setColor(cc.c3b(39,26,11))
        tabtxt:disableEffect()
        tabtxt:setFontSize(32)
    end
end

function MFSelectHeroTeamView:tabButtonClick(sender, infirst)
    if sender == nil then 
        return 
    end
    if self._tabName == sender:getName() then 
        return 
    end
    for k,v in pairs(self._tabEventTarget) do
        self:tabButtonState(v, false)
    end
    self:tabButtonState(sender, true)

    if sender:getName() == "tab1" then
        self._index = 1 
        self._tableData = clone(self._modelMgr:getModel("MFModel"):getMFTeamRaceData(self._selectIndex))
        if infirst == false then
            if table.nums(self._tableData) == 0 then
                self:tabButtonClick(self:getUI("bg.tab2"), false)
            end
            
        end
        
        self:setThisTeams()

    elseif sender:getName() == "tab2" then 
        print("升级")
        self._index = 2
        self._tableData = clone(self._modelMgr:getModel("MFModel"):getMFTeamData(self._selectIndex))
        self:setThisTeams()
        -- self._tableView:reloadData()
    end
end

-- 接收自定义消息
function MFSelectHeroTeamView:reflashUI()
    if self._selType == "team" then
        for i=1,2 do
            local tab = self:getUI("bg.tab" .. i)
            if tab then
                tab:setVisible(false)
            end
        end


        -- self._title:setString("选择兵团")
        -- if self._index == 1 then
        --     self._tableData = self._modelMgr:getModel("MFModel"):getMFTeamRaceData(self._selectIndex)
        -- else
        --     self._tableData = self._modelMgr:getModel("MFModel"):getMFTeamData(self._selectIndex)
        -- end
        -- -- self._tableData = self._modelMgr:getModel("MFModel"):getMFTeamData(self._selectIndex)
        -- self._tableData = clone(teamData)
        -- self:setThisTeams()
        -- for k,v in pairs(self._tableData) do
        --     for i=1,table.nums(self._teams) do
        --         if v.teamId == tonumber(self._teams[i]) then
        --             v["selectTeamMf"] = 1
        --         end
        --     end
        -- end
    else
        -- 隐藏标签
        for i=1,2 do
            local tab = self:getUI("bg.tab" .. i)
            if tab then
                tab:setVisible(false)
            end
        end
        self._title:setString("选择英雄")
        local heroData = self._modelMgr:getModel("MFModel"):getMFHeroData()
        self._tableData = clone(heroData)
        for k,v in pairs(self._tableData) do
            if v.heroId == tonumber(self._heros) then
                v["selectMf"] = 1
            end
        end
    end
    -- dump(self._tableData)

    self._tableView:reloadData()
    self:updateConditionDes()
    
end

function MFSelectHeroTeamView:setThisTeams()
    print("========", self._teams)
    dump(self._teams)
    for k,v in pairs(self._tableData) do
        for i=1,table.nums(self._teams) do
            if v.teamId == tonumber(self._teams[i]) then
                v["selectTeamMf"] = 1
            end
        end
    end

    local nothing = self:getUI("bg.nothing")
    if table.nums(self._tableData) > 0 then
        nothing:setVisible(false)
    else
        nothing:setVisible(true)
    end

    self._tableView:reloadData()
end

--[[
用tableview实现
--]]
function MFSelectHeroTeamView:addTableView()
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
function MFSelectHeroTeamView:tableCellTouched(table,cell)
    -- self._viewMgr:showDialog("guild.GuildScienceDetailDialog", {detailData = nil})
end

-- cell的尺寸大小
function MFSelectHeroTeamView:cellSizeForTable(table,idx) 
    local width = 434
    local height = 128
    return height, width
end

-- 创建在某个位置的cell
function MFSelectHeroTeamView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    -- local param = self._technology[idx+1]
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        if self._selType == "team" then
            for i=1,2 do
                local teamNode = self._teamNode:clone() 
                teamNode:setAnchorPoint(cc.p(0,0))
                teamNode:setPosition(cc.p((i-1)*263+10,0)) --0
                teamNode:setName("teamNode" .. i)
                cell:addChild(teamNode)

                local shangzhen = teamNode:getChildByName("shangzhen")
                shangzhen:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnColor4, 2)
                local xiazhen = teamNode:getChildByName("xiazhen")
                xiazhen:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnColor4, 2)
            end
        else
            for i=1,2 do
                local heroNode = self._heroNode:clone() 
                heroNode:setAnchorPoint(cc.p(0,0))
                heroNode:setPosition(cc.p((i-1)*263+10,0)) --0
                heroNode:setName("heroNode" .. i)
                cell:addChild(heroNode)

                local shangzhen = heroNode:getChildByName("shangzhen")
                shangzhen:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnColor4, 2)
                local xiazhen = heroNode:getChildByName("xiazhen")
                xiazhen:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnColor4, 2)
            end
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
function MFSelectHeroTeamView:numberOfCellsInTableView(table)
    return self:cellLineNum() -- 
end

function MFSelectHeroTeamView:cellLineNum()
    local num
    if self._selType == "team" then
        num = math.ceil(table.nums(self._tableData)*0.5)
    else
        num = math.ceil(table.nums(self._tableData)*0.5)
    end
    return num 
end

function MFSelectHeroTeamView:updateCell(cell, indexLine)    
    if self._selType == "team" then
        for i=1,2 do
            local teamNode = cell:getChildByFullName("teamNode" .. i)
            if teamNode then
                local indexId = (indexLine-1)*2+i
                self:updateTeamNode(teamNode, self._tableData[indexId], indexId)  
            end
        end
    else
        for i=1,2 do
            local heroNode = cell:getChildByFullName("heroNode" .. i)
            if heroNode then
                local indexId = (indexLine-1)*2+i
                self:updateHeroNode(heroNode, self._tableData[indexId], indexId)  
            end
        end
    end
end

-- 更新兵团界面Cell
function MFSelectHeroTeamView:updateTeamNode(inView, nodeData, indexId) 
    local teamModel = self._modelMgr:getModel("TeamModel")
    if nodeData then
        inView:setVisible(true)
        local sysTeam = tab:Team(nodeData.teamId)
        local backQuality = teamModel:getTeamQualityByStage(nodeData.stage)
        local teamIcon = inView:getChildByName("teamIcon")
        local param = {teamData = nodeData, sysTeamData = sysTeam,quality = backQuality[1] , quaAddition = backQuality[2],  eventStyle = 0, classType = true} 
        if teamIcon == nil then 
            teamIcon = IconUtils:createTeamIconById(param)
            teamIcon:setName("teamIcon")
            teamIcon:setPosition(cc.p(6,12))
            teamIcon:setAnchorPoint(cc.p(0, 0))
            -- icon:setRotation(-90)
            teamIcon:setScale(0.9)
            inView:addChild(teamIcon, 10)
        else
            IconUtils:updateTeamIconByView(teamIcon, param)
        end
        teamIcon:setCascadeOpacityEnabled(true)
        -- teamIcon:setOpacity(150)
        -- teamIcon:setSwallowTouches(true)
        local pokeScore = inView:getChildByFullName("pokeScore")
        if pokeScore then
            local taxTeamScore = teamModel:getTeamAddPingScore(nodeData)
            pokeScore:setString("评分: " .. taxTeamScore)
        end

        -- 职业
        -- local des1 = inView:getChildByFullName("des1")
        -- if des1 then
        --     des1:setString("职业: " .. lang(sysTeam.classname))
        --     if nodeData.tsort202 == 2 and nodeData.selectTeamMf ~= 3 then
        --         des1:setColor(cc.c3b(0,255,30))
        --         des1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
        --     else
        --         des1:disableEffect()
        --         des1:setColor(cc.c3b(61,31,0))
        --     end
        -- end

        -- 阵营
        local zhenying = inView:getChildByFullName("zhenying")
        if zhenying then
            zhenying:setString("阵营: " .. lang(tab:Race(sysTeam.race[1])["name"] .. "_1"))
            -- if nodeData.tsort201 == 2 and nodeData.selectTeamMf ~= 3 then
            --     zhenying:setColor(cc.c3b(0,255,30))
            --     zhenying:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
            -- else
            --     zhenying:disableEffect()
            --     zhenying:setColor(cc.c3b(61,31,0))
            -- end
        end

        -- 人数
        -- local des3 = inView:getChildByFullName("des3")
        -- if des3 then
        --     local num 
        --     if sysTeam.volume == 2 then
        --         num = 16
        --     elseif sysTeam.volume == 3 then
        --         num = 9
        --     elseif sysTeam.volume == 4 then
        --         num = 4
        --     elseif sysTeam.volume == 5 then
        --         num = 1
        --     end
        --     des3:setString("人数: " .. num)
        --     if nodeData.tsort205 == 2 and nodeData.selectTeamMf ~= 3 then
        --         des3:setColor(cc.c3b(0,255,30))
        --         des3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
        --     else
        --         des3:disableEffect()
        --         des3:setColor(cc.c3b(61,31,0))
        --     end
        -- end

        local shang = inView:getChildByFullName("shang")
        if shang then
            shang:setVisible(false)
        end
        -- local tishiLab = inView:getChildByFullName("shang.tishiLab")
        -- local tishiLab1 = inView:getChildByFullName("shang.tishiLab1")
        -- if tishiLab then
        --     tishiLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        -- end
        -- if tishiLab then
        --     tishiLab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        -- end

        local shangzhen = inView:getChildByFullName("shangzhen")
        local xiazhen = inView:getChildByFullName("xiazhen")
        local state = inView:getChildByFullName("state")
        if nodeData.selectTeamMf == 1 then
            if shangzhen then
                shangzhen:setVisible(false)
            end
            if xiazhen then
                xiazhen:setVisible(true)
            end
            if state then
                state:setVisible(false)
            end
            self:registerClickEvent(xiazhen, function()
                nodeData["selectTeamMf"] = 2
                for i=1,table.nums(self._teams) do
                    if self._teams[i] == nodeData.teamId then
                        table.remove(self._teams, i)
                        break
                    end
                end
                self:updateTeamNode(inView, nodeData, indexId) 
                self:updateConditionDes()
            end)
            local downY, clickFlag
            registerTouchEvent(
                inView,
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
                        nodeData["selectTeamMf"] = 2
                        for i=1,table.nums(self._teams) do
                            if self._teams[i] == nodeData.teamId then
                                table.remove(self._teams, i)
                                break
                            end
                        end
                        self:updateTeamNode(inView, nodeData, indexId) 
                        self:updateConditionDes()
                    end
                end,
                function ()
                end)
            -- if shang then
            --     shang:setVisible(true)
            -- end
            -- -- if teamIcon then
            -- --     teamIcon:setOpacity(150)
            -- -- end
            -- if tishiLab then
            --     tishiLab:setString("取消")
            --     tishiLab1:setString("选择")
            -- end
        elseif nodeData.selectTeamMf == 2 then
            if shangzhen then
                shangzhen:setVisible(true)
            end
            if xiazhen then
                xiazhen:setVisible(false)
            end 
            if state then
                state:setVisible(false)
            end
            self:registerClickEvent(shangzhen, function()
                local mfData = self._modelMgr:getModel("MFModel"):getTasksById(self._selectIndex)
                local taskTab = tab:MfTask(mfData["taskId"])
                if table.nums(self._teams) >= taskTab.num then
                    self._viewMgr:showTip("上阵兵团达到上限")
                    return
                elseif nodeData["selectTeamMf"] == 2 then
                    nodeData["selectTeamMf"] = 1
                    table.insert(self._teams, nodeData.teamId)
                end
                self:updateTeamNode(inView, nodeData, indexId) 
                self:updateConditionDes()
            end)
            local downY, clickFlag
            registerTouchEvent(
                inView,
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
                        local mfData = self._modelMgr:getModel("MFModel"):getTasksById(self._selectIndex)
                        local taskTab = tab:MfTask(mfData["taskId"])
                        if table.nums(self._teams) >= taskTab.num then
                            self._viewMgr:showTip("上阵兵团达到上限")
                            return
                        elseif nodeData["selectTeamMf"] == 2 then
                            nodeData["selectTeamMf"] = 1
                            table.insert(self._teams, nodeData.teamId)
                        end
                        self:updateTeamNode(inView, nodeData, indexId) 
                        self:updateConditionDes()
                    end
                end,
                function ()
                end)
            -- if shang then
            --     shang:setVisible(false)
            -- end
            -- if teamIcon then
            --     teamIcon:setOpacity(255)
            -- end
        elseif nodeData.selectTeamMf == 3 then
            if shangzhen then
                shangzhen:setVisible(false)
            end
            if xiazhen then
                xiazhen:setVisible(false)
            end
            if state then
                state:setVisible(true)
            end
            local downY, clickFlag
            registerTouchEvent(
                inView,
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
                    end
                end,
                function ()
                end)
            -- if shang then
            --     shang:setVisible(true)
            -- end
            -- if teamIcon then
            --     teamIcon:setOpacity(150)
            -- end
            -- if tishiLab then
            --     tishiLab:setString("执行")
            --     tishiLab1:setString("任务中")
            -- end
        end

        -- if nodeData.selectTeamMf == 3 then
        --     local downY, clickFlag
        --     registerTouchEvent(
        --         teamIcon,
        --         function (_, _, y)
        --             downY = y
        --             clickFlag = false
                    
        --         end, 
        --         function (_, _, y)
        --             if downY and math.abs(downY - y) > 5 then
        --                 clickFlag = true
        --             end
        --         end, 
        --         function ()
        --             if clickFlag == false then 
        --                 self._viewMgr:showTip("该兵团正在任务中")
        --             end
        --         end,
        --         function ()
        --         end)
        -- else
        --     local downY, clickFlag
        --     registerTouchEvent(
        --         teamIcon,
        --         function (_, _, y)
        --             downY = y
        --             clickFlag = false
        --         end, 
        --         function (_, _, y)
        --             if downY and math.abs(downY - y) > 5 then
        --                 clickFlag = true
        --             end
        --         end, 
        --         function ()
        --             if clickFlag == false then 
        --                 local mfData = self._modelMgr:getModel("MFModel"):getTasksById(self._selectIndex)
        --                 local taskTab = tab:MfTask(mfData["taskId"])
        --                 -- if table.nums(self._teams) >= taskTab.num then
        --                 --     self._viewMgr:showTip("上阵兵团达到上限")
        --                 --     return
        --                 -- end
        --                 if nodeData["selectTeamMf"] == 1 then
        --                     nodeData["selectTeamMf"] = 2
        --                     for i=1,table.nums(self._teams) do
        --                         if self._teams[i] == nodeData.teamId then
        --                             table.remove(self._teams, i)
        --                             break
        --                         end
        --                     end
        --                 elseif table.nums(self._teams) >= taskTab.num then
        --                     self._viewMgr:showTip("上阵兵团达到上限")
        --                     return
        --                 elseif nodeData["selectTeamMf"] == 2 then
        --                     nodeData["selectTeamMf"] = 1
        --                     table.insert(self._teams, nodeData.teamId)
        --                 end
        --                 self:updateTeamNode(inView, nodeData, indexId) 
        --                 -- self:updateTeamNode(inView, nodeData, indexId) 
        --                 -- self._tableView:reloadData()
        --                 print("+++++")
        --                 self:updateConditionDes()
        --             end
        --         end,
        --         function ()
        --         end)
        -- end

        -- teamIcon:setTouchEnabled(false)
        teamIcon:setSwallowTouches(false)
        teamIcon:getChildByFullName("teamIcon"):setSwallowTouches(false)
        inView:setSwallowTouches(false)

    else
        inView:setVisible(false)
    end
end

-- function MFSelectHeroTeamView:updateSelectTeam(cell, indexLine, index, )    
--     local shang = inView:getChildByFullName("shang")
--     local tishiLab = inView:getChildByFullName("shang.tishiLab")
--     if nodeData.selectTeamMf == 1 then
--         if shang then
--             shang:setVisible(true)
--         end
--         if tishiLab then
--             tishiLab:setString("已选择")
--         end
--     elseif nodeData.selectTeamMf == 2 then
--         if shang then
--             shang:setVisible(false)
--         end
--     elseif nodeData.selectTeamMf == 3 then
--         if shang then
--             shang:setVisible(true)
--         end
--         if tishiLab then
--             tishiLab:setString("任务中")
--         end
--     end
-- end

function MFSelectHeroTeamView:updateHeroNode(inView, nodeData, indexId)  
    if nodeData then
        inView:setVisible(true)
        local heroIcon = inView:getChildByName("heroIcon")
        local sysHeroData = clone(tab:Hero(tonumber(nodeData["heroId"])))
        sysHeroData.star = nodeData["star"]
        if heroIcon then
            IconUtils:updateHeroIconByView(heroIcon, {sysHeroData = sysHeroData})
        else
            heroIcon =IconUtils:createHeroIconById({sysHeroData = sysHeroData})
            heroIcon:setName("heroIcon")
            heroIcon:setAnchorPoint(cc.p(0,0))
            heroIcon:setScale(0.90)
            heroIcon:setPosition(cc.p(7,15))
            inView:addChild(heroIcon)
        end
        heroIcon:setCascadeOpacityEnabled(true)
        
        heroIcon:getChildByName("starBg"):setVisible(false)

        local pokeScore = inView:getChildByFullName("pokeScore")
        if pokeScore then
            local taxHeroScore = self._modelMgr:getModel("HeroModel"):getHeroGrade(nodeData["heroId"])
            pokeScore:setString("评分: " .. taxHeroScore)
        end

        local shang = inView:getChildByFullName("shang")
        if shang then
            shang:setOpacity(255)
            shang:setVisible(false)
        end
        
        -- local tishiLab = inView:getChildByFullName("shang.tishiLab")
        -- if tishiLab then
        --     tishiLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        -- end

        local shangzhen = inView:getChildByFullName("shangzhen")
        local xiazhen = inView:getChildByFullName("xiazhen")
        local state = inView:getChildByFullName("state")
        if nodeData.selectMf == 1 then
            if shangzhen then
                shangzhen:setVisible(false)
            end
            if xiazhen then
                xiazhen:setVisible(true)
                xiazhen:setScale(0.8)
            end
            if state then
                state:setVisible(false)
            end
            self:registerClickEvent(xiazhen, function()
                if nodeData["selectMf"] == 1 then
                    nodeData["selectMf"] = 2
                    self._heros = nil 
                end

                -- self:updateHeroNode(inView, nodeData, indexId) 
                self._tableView:reloadData()
                self:updateConditionDes()
            end)
            local downY, clickFlag
            registerTouchEvent(
                inView,
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
                        if nodeData["selectMf"] == 1 then
                            nodeData["selectMf"] = 2
                            self._heros = nil 
                        end

                        -- self:updateHeroNode(inView, nodeData, indexId) 
                        self._tableView:reloadData()
                        self:updateConditionDes()
                    end
                end,
                function ()
                end)
        elseif nodeData.selectMf == 2 then
            if shangzhen then
                shangzhen:setVisible(true)
                shangzhen:setScale(0.8)
            end
            if xiazhen then
                xiazhen:setVisible(false)
            end 
            if state then
                state:setVisible(false)
            end
            self:registerClickEvent(shangzhen, function()
                if self._heros and tonumber(self._heros) ~= tonumber(nodeData.heroId) then
                    local oldHeros = tonumber(self._heros)
                    for k,v in pairs(self._tableData) do
                        print("+++++==========",v.heroId, oldHeros, v["selectMf"])
                        if tonumber(v.heroId) == oldHeros then
                            v["selectMf"] = 2
                        elseif tonumber(v.heroId) == tonumber(nodeData.heroId) then
                            v["selectMf"] = 1
                        end
                    end
                    self._heros = nodeData.heroId
                    -- self._viewMgr:showTip("只能上阵1个英雄")
                    -- return
                elseif nodeData["selectMf"] == 2 then
                    nodeData["selectMf"] = 1
                    self._heros = nodeData.heroId
                end
                self._tableView:reloadData()
                self:updateConditionDes()
            end)
            local downY, clickFlag
            registerTouchEvent(
                inView,
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
                        if self._heros and tonumber(self._heros) ~= tonumber(nodeData.heroId) then
                            local oldHeros = tonumber(self._heros)
                            for k,v in pairs(self._tableData) do
                                print("+++++==========",v.heroId, oldHeros, v["selectMf"])
                                if tonumber(v.heroId) == oldHeros then
                                    v["selectMf"] = 2
                                elseif tonumber(v.heroId) == tonumber(nodeData.heroId) then
                                    v["selectMf"] = 1
                                end
                            end
                            self._heros = nodeData.heroId
                            -- self._viewMgr:showTip("只能上阵1个英雄")
                            -- return
                        elseif nodeData["selectMf"] == 2 then
                            nodeData["selectMf"] = 1
                            self._heros = nodeData.heroId
                        end
                        self._tableView:reloadData()
                        self:updateConditionDes()
                    end
                end,
                function ()
                end)
        elseif nodeData.selectMf == 3 then
            if shangzhen then
                shangzhen:setVisible(false)
            end
            if xiazhen then
                xiazhen:setVisible(false)
            end
            if state then
                state:setVisible(true)
            end
            local downY, clickFlag
            registerTouchEvent(
                inView,
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
                    end
                end,
                function ()
                end)
        end


        -- if nodeData.selectMf == 3 then
        --     local downY
        --     registerTouchEvent(
        --         heroIcon,
        --         function (_, _, y)
        --             downY = y
        --             clickFlag = false
                    
        --         end, 
        --         function (_, _, y)
        --             if downY and math.abs(downY - y) > 5 then
        --                 clickFlag = true
        --             end
        --         end, 
        --         function ()
        --             if clickFlag == false then 
        --                 self._viewMgr:showTip("该英雄正在任务中")
        --             end
        --         end,
        --         function ()
        --         end)
        -- else
        --     local downY
        --     registerTouchEvent(
        --         heroIcon,
        --         function (_, _, y)
        --             downY = y
        --             clickFlag = false
                    
        --         end, 
        --         function (_, _, y)
        --             if downY and math.abs(downY - y) > 5 then
        --                 clickFlag = true
        --             end
        --         end, 
        --         function ()
        --             if clickFlag == false then 
        --                 -- local oldHeros = self._heros
        --                 -- for k,v in pairs(self._tableData) do
        --                 --     if v.heroId == oldHeros then
        --                 --         v["selectMf"] = 2
        --                 --     end
        --                 --     if v.heroId == nodeData.heroId then
        --                 --         v["selectMf"] = 1
        --                 --     end
        --                 -- end

        --                 if nodeData["selectMf"] == 1 then
        --                     nodeData["selectMf"] = 2
        --                     self._heros = nil 
        --                 elseif self._heros and tonumber(self._heros) ~= tonumber(nodeData.heroId) then
        --                     local oldHeros = tonumber(self._heros)
        --                     for k,v in pairs(self._tableData) do
        --                         print("+++++==========",v.heroId, oldHeros, v["selectMf"])
        --                         if tonumber(v.heroId) == oldHeros then
        --                             v["selectMf"] = 2
        --                         elseif tonumber(v.heroId) == tonumber(nodeData.heroId) then
        --                             v["selectMf"] = 1
        --                         end
        --                     end
        --                     self._heros = nodeData.heroId
        --                     -- self._viewMgr:showTip("只能上阵1个英雄")
        --                     -- return
        --                 elseif nodeData["selectMf"] == 2 then
        --                     nodeData["selectMf"] = 1
        --                     self._heros = nodeData.heroId
        --                 end

        --                 -- self:updateHeroNode(inView, nodeData, indexId) 
        --                 self._tableView:reloadData()
        --                 self:updateConditionDes()
        --             end
        --         end,
        --         function ()
        --         end)
        -- end
        heroIcon:setSwallowTouches(false)
        -- heroIcon:getChildByName("heroIcon"):setSwallowTouches(false)
        inView:setSwallowTouches(false)
    else
        inView:setVisible(false)
    end
end

-- function MFSelectHeroTeamView:updateHeros() 
--     for k,v in pairs(self._tableData) do
--         if v.heroId == self._heros then
--             v["selectMf"] = 1
--         end
--     end
-- end

function MFSelectHeroTeamView:split(str,param,reps)
    -- print("str,param,reps ================", str,param,reps)
    if str == "" then
        return str
    end
    local des = string.gsub(str,"%b{}",function( lvStr )
        return string.gsub(string.gsub(lvStr,param,reps),"[{}]","")
    end, 1)
    -- print(des)
    return des 
end


function MFSelectHeroTeamView:getSelectData()
    local tempData
    if self._selType == "team" then
        tempData = {}
        for i=1,table.nums(self._teams) do
            tempData[i] = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(self._teams[i])
        end
        self._selectData.teamData = tempData
    else
        local heroData = self._modelMgr:getModel("HeroModel"):getData()
        for k,v in pairs(heroData) do
            if tonumber(k) == tonumber(self._heros) then
                v.heroId = tonumber(k)
                tempData = clone(v)
            end
        end
        self._selectData.heroData = tempData
    end
end

function MFSelectHeroTeamView:setSelectData(data)
    local tempData
    if self._selType == "team" then
        for i=1,table.nums(self._selectData.teamData) do
            self._teams[i] = self._selectData.teamData[i]["teamId"]
        end
    else
        self._heros = self._selectData.heroData["heroId"]
    end
end

function MFSelectHeroTeamView:getConditionDes(data)
    local str
    if data["param1"] == 0 then
        str = self:split(lang("MFDES_" .. data["conId"]), "$des", data["param2"])
    else
        str = self:split(lang("MFDES_" .. data["conId"]), "$des", lang("MFDES_" .. data["conId"] .. "_" .. data["param1"]))
        str = self:split(str, "$num", data["param2"])
    end
    return str
end

function MFSelectHeroTeamView:updateConditionDes()
    self:getSelectData()
    local mfModel = self._modelMgr:getModel("MFModel")
    local mfData = mfModel:getTasksById(self._selectIndex)

    local taskTab = tab:MfTask(mfData["taskId"])
    -- self._taskDes:setString("派遣1名英雄和" .. taskTab["num"] .. "个兵团")
    dump(mfData, 'mfData ======')
    -- dump(self._selectData, "self._selectData===")
    if self._selType == "team" then
        
        local str = lang("MFDES_" .. mfData["condition"]["1"]["conId"] .. "_" .. mfData["condition"]["1"]["param1"])
        self:getUI("bg.tab1.tabtxt"):setString(str)

        if mfData["condition"]["1"]["conId"] < 200 then
            local panel1 = self:getUI("bg.layer.panel1")
            panel1:setVisible(false)
            local panel2 = self:getUI("bg.layer.panel2")
            panel2:setVisible(true)
            self._con1 = self:getUI("bg.layer.panel2.con1")
            self._con1:setVisible(false)
            self._con2 = self:getUI("bg.layer.panel2.con2")
            self._con2:setVisible(true)
        else
            local panel1 = self:getUI("bg.layer.panel1")
            panel1:setVisible(true)
            local panel2 = self:getUI("bg.layer.panel2")
            panel2:setVisible(false)
            self._con1 = self:getUI("bg.layer.panel1.con1")
            self._con1:setVisible(true)
            self._con2 = self:getUI("bg.layer.panel1.con2")
            self._con2:setVisible(true)
        end
    end

    local str1 = self:getConditionDes(mfData["condition"]["1"])

    local num = mfModel:getMFConditionsByNum(self._selectData, mfData["condition"]["1"], tab:MfTask(mfData["taskId"])["num"])
    local str2 = num .. "/" .. mfData["condition"]["1"]["param2"]
    self._con1:setString(str1 .. "(" .. str2 .. ")")
    local str1 = self:getConditionDes(mfData["condition"]["2"])
    if num >= mfData["condition"]["1"]["param2"] then
        self._con1:setColor(UIUtils.colorTable.ccUIBaseColor9)
        -- self._con1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    else
        self._con1:disableEffect()
        self._con1:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    end

    local num = mfModel:getMFConditionsByNum(self._selectData, mfData["condition"]["2"], tab:MfTask(mfData["taskId"])["num"])
    local str2 = num .. "/" .. mfData["condition"]["2"]["param2"]
    self._con2:setString(str1 .. "(" .. str2 .. ")")
    if num >= mfData["condition"]["2"]["param2"] then
        self._con2:setColor(UIUtils.colorTable.ccUIBaseColor9)
        -- self._con2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    else
        self._con2:disableEffect()
        self._con2:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    end
    -- 设置英雄条件显示
    if self._selType ~= "team" then
        local panel1 = self:getUI("bg.layer.panel1")
        panel1:setVisible(false)
        local panel2 = self:getUI("bg.layer.panel2")
        panel2:setVisible(true)
        self._con1 = self:getUI("bg.layer.panel2.con1")
        self._con1:setVisible(false)
        self._con2 = self:getUI("bg.layer.panel2.con2")
        self._con2:setVisible(true)
        self._con2:setString(str1 .. "(" .. str2 .. ")")
        -- print("mfData ========", mfData["condition"]["2"]["conId"])
        if mfData["condition"]["2"]["conId"] > 200 and mfData["condition"]["2"]["conId"] < 300 then
            self._con2:setString("该任务对英雄没有额外条件")
            self._con2:disableEffect()
            self._con2:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        -- elseif mfData["condition"]["1"]["conId"] > 300 then
        --     self._con1 = self:getUI("bg.layer.panel2.con1")
        --     self._con1:setVisible(true)
        --     self._con2 = self:getUI("bg.layer.panel2.con2")
        --     self._con2:setVisible(false)
        end
    end

    -- 更新评分金币
    self._taxScore = self:getTaxScore()
    self._goldNum = self:getMFGoldNum(self._taxScore)

    local des1 = self:getUI("bg.scrollBg.des1")
    local des2 = self:getUI("bg.scrollBg.des2")
    local goldIcon = self:getUI("bg.scrollBg.goldIcon")
    local des3 = self:getUI("bg.scrollBg.des3")
    des1:setString("总评分:")
    des2:setString(self._taxScore .. " (产出")
    des3:setString(self._goldNum .. ")")

    -- local scrollBg = self:getUI("bg.scrollBg")
    -- local posX = scrollBg:getContentSize().width + des1:getContentSize().width*des1:getScaleX() 
    -- + des2:getContentSize().width*des2:getScaleX() + 
    des2:setPositionX(des1:getPositionX()+des1:getContentSize().width*des1:getScaleX())
    goldIcon:setPositionX(des2:getPositionX()+des2:getContentSize().width*des2:getScaleX()+5)
    des3:setPositionX(goldIcon:getPositionX()+goldIcon:getContentSize().width*goldIcon:getScaleX()+5)
end

function MFSelectHeroTeamView:getTaxScore()
    local teamModel = self._modelMgr:getModel("TeamModel")
    local heroModel = self._modelMgr:getModel("HeroModel")
    local taxHeroScore = 0
    if self._selectData["heroData"] then
        taxHeroScore = heroModel:getHeroGrade(self._selectData["heroData"]["heroId"])
    end
    
    local taxTeamScore = 0
    if self._selectData["teamData"] then
        for i=1,table.nums(self._selectData["teamData"]) do
            taxTeamScore = taxTeamScore + teamModel:getTeamAddPingScore(self._selectData["teamData"][i])
        end
    end

    print("taxHeroScore ===", taxTeamScore, "taxHeroScore ===", taxHeroScore)
    return taxTeamScore + taxHeroScore
end

function MFSelectHeroTeamView:getMFGoldNum(taxScore)
    local mfModel = self._modelMgr:getModel("MFModel")
    local mfData = mfModel:getTasksById(self._selectIndex)

    -- local taxScore = self:getTaxScore()

    local taskTab = tab:MfTask(mfData["taskId"])
    local goldNum = taskTab["coefficientA"] * taxScore + taskTab["coefficientB"]
    print("goldNum=====", taskTab["coefficientA"] * taxScore, taskTab["coefficientA"], taskTab["coefficientB"])
    return math.ceil(goldNum*0.1)*10
end


return MFSelectHeroTeamView