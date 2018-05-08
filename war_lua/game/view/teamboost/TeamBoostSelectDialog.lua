--[[
    Filename:    TeamBoostSelectDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-10-27 21:52:23
    Description: File description
--]]


local TeamBoostSelectDialog = class("TeamBoostSelectDialog", BasePopView)

function TeamBoostSelectDialog:ctor(params)
    TeamBoostSelectDialog.super.ctor(self)
    -- self._selectPokedex = params.pokedexType
    self._teamId = params.teamId
    self._callback = params.callback
    -- self._teamsData = params.teamsData
    -- self._pokedexDV = params.pokDV
end

function TeamBoostSelectDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("teamboost.TeamBoostSelectDialog")
        end
        self:close()
    end)

    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)
    title:setString("选择兵团")

    -- local none = self:getUI("bg.noneBg.none")
    -- none:setFontName(UIUtils.ttfName)
    -- none:setFontSize(28)
    -- none:enableOutline(cc.c4b(60,30,10,255), 2)

    self:addTableView()

    -- self._scrollView = self:getUI("bg.sceollBg.scrollView")
    self._tempTeam = self:getUI("bg.teamBg")
    self._tempTeam:setVisible(false)
    -- local tempScore = self:getUI("bg.teamBg.teamFen")



    self._none = self:getUI("bg.noneBg")

    -- tempScore:setFontSize(20)

    -- -- 首次进入需要排序
    -- self._teamModel = self._modelMgr:getModel("TeamModel")
    -- self._teamModel:refreshDataOrder()
    -- self._teamModel:initGetSysTeams()

    -- self:setTeam(2)
end

function TeamBoostSelectDialog:reflashUI()
    self._teamModel = self._modelMgr:getModel("TeamModel")
    local tempTeamData = self._teamModel:getBoostTeamData(self._teamId)
    self._teamsData = tempTeamData
    -- dump(self._teamsData)
    if table.nums(self._teamsData) > 0 then
        self._tableView:reloadData()
        self._none:setVisible(false)
    else
        self._none:setVisible(true)
    end
end


--[[
用tableview实现
--]]
function TeamBoostSelectDialog:addTableView()
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
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    
    tableViewBg:addChild(self._tableView)
end


-- 触摸时调用
function TeamBoostSelectDialog:tableCellTouched(table,cell)
end

-- cell的尺寸大小
function TeamBoostSelectDialog:cellSizeForTable(table,idx) 
    local width = 608 
    local height = 125
    return height, width
end

-- 创建在某个位置的cell
function TeamBoostSelectDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    -- local param = self._technology[idx+1]
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        for i=1,2 do
            local teamCell = self._tempTeam:clone() 
            teamCell:setVisible(true)
            teamCell:setAnchorPoint(cc.p(0,0))
            teamCell:setPosition(cc.p((i-1)*(self._tempTeam:getContentSize().width + 5),0))
            teamCell:setName("teamCell" .. i)
            cell:addChild(teamCell)

            local nameLab = teamCell:getChildByFullName("nameLab")
            -- nameLab:setFontName(UIUtils.ttfName)
            nameLab:setFontSize(26)
            nameLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            local nowLvl = teamCell:getChildByFullName("nowLvl")
            nowLvl:setFontSize(22)
            -- nowLvl:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
            -- local score = teamCell:getChildByFullName("score")
            -- score:setFontSize(22)

            local titleBg = teamCell:getChildByFullName("titleBg")
            titleBg:setOpacity(150)
            local txt = teamCell:getChildByFullName("biaoqian.txt")
            txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
            -- txt:setString("上阵")
            -- txt:setFontName(UIUtils.ttfName)
        end

        self:updateCell(cell, indexId)
        -- teamCell:setSwallowTouches(false)
    else
        print("wo shi shua xin")
        self:updateCell(cell, indexId)
    end

    return cell
end

-- 获取等级
function TeamBoostSelectDialog:getTeamBoostLevel(teamData)
    local level = 0
    if not teamData then
        return level
    end
    if not teamData.tb then
        return level
    end

    local boostD = teamData.tb
    if boostD and table.nums(boostD) > 0 then
        for k,v in pairs(boostD) do
            level = level + v
        end
    end
    return level
end

-- 判断是否满级
function TeamBoostSelectDialog:isTeamBoostMaxLevel(teamData, nowLvl)
    local flag = false
    if not teamData then
        return flag
    end
    if not teamData.tb then
        return flag
    end


    local maxLvl = tab:TeamQuality(teamData.stage).techniqueLevel

    if (maxLvl*4) == nowLvl then
        flag = true
    end
    return flag
end

-- 判断加锁
function TeamBoostSelectDialog:getTeamBoostLock(index)
    local flag = true -- false
    local boostD = self._curSelectTeam.tb
    local highAttrLock = tab:Setting("G_TECHNIQUE_UNLOCK").value
    if boostD and table.nums(boostD) > 0 then
        for k,v in pairs(boostD) do
            if v < highAttrLock[index] then
                flag = false
                break
            end
        end
    end
    return flag
end

-- 返回cell的数量
function TeamBoostSelectDialog:numberOfCellsInTableView(table)
    return self:cellLineNum() -- #self._teamsData -- #self._technology --table.nums(self._membersData)
end

function TeamBoostSelectDialog:cellLineNum()
    return math.ceil(table.nums(self._teamsData)*0.5)
end

function TeamBoostSelectDialog:updateCell(cell, indexLine)    
    for i=1,2 do
        local teamCell = cell:getChildByFullName("teamCell" .. i)
        if teamCell then
            local indexId = (indexLine-1)*2+i
            if self._teamsData[indexId] then
                local teamBg = teamCell:getChildByFullName("teamBg")
                local teamIcon = teamBg:getChildByName("teamIcon")
                local backQuality = self._teamModel:getTeamQualityByStage(self._teamsData[indexId].stage)
                local sysTeam = tab:Team(self._teamsData[indexId].teamId)
                local param = {teamData = self._teamsData[indexId], sysTeamData = sysTeam,quality = backQuality[1] , quaAddition = backQuality[2],  eventStyle = 0}
                if not teamIcon then
                    teamIcon = IconUtils:createTeamIconById(param)
                    teamIcon:setName("teamIcon")
                    teamIcon:setScale(0.9)
                    teamIcon:setPosition(cc.p(0,0))
                    teamBg:addChild(teamIcon)
                else
                    IconUtils:updateTeamIconByView(teamIcon, param)
                end

                local nameLab = teamCell:getChildByFullName("nameLab")
                if backQuality[2] > 0 then
                    nameLab:setString(lang(sysTeam.name) .. "+" .. backQuality[2])
                else
                    nameLab:setString(lang(sysTeam.name))
                end
                nameLab:setColor(UIUtils.colorTable["ccColorQuality" .. backQuality[1]])
                

                local nowLvl = teamCell:getChildByFullName("nowLvl")
                local tempLevel = self:getTeamBoostLevel(self._teamsData[indexId])
                if tempLevel == 0 then
                    nowLvl:setString("未学习")
                else
                    nowLvl:setString("已学习: Lv " .. tempLevel)
                end

                -- local score = teamCell:getChildByFullName("score")
                -- score:setString("战斗力: " .. self._teamsData[indexId].score)

                local onBoost = teamCell:getChildByFullName("onBoost")
                if onBoost then
                    if self._teamsData[indexId].isInFormation == 1 then
                        onBoost:setVisible(self._teamsData[indexId].onBoost)
                    else
                        onBoost:setVisible(false)
                    end
                end
                
                local maxLvl = teamCell:getChildByFullName("maxLvl")
                if self:isTeamBoostMaxLevel(self._teamsData[indexId], tempLevel) then
                    maxLvl:setVisible(true)
                else
                    maxLvl:setVisible(false)
                end
                
                -- local txt = teamCell:getChildByFullName("biaoqian.txt")
                -- if self._teamsData[indexId].sortId == 1 then
                --     txt:setString("当前")
                -- else
                --     txt:setString("上阵")
                -- end

                -- for i=1,3 do
                --     local highAttr = teamCell:getChildByFullName("highAttr" .. i)
                --     local highIcon = teamCell:getChildByFullName("highAttr" .. i .. ".highIcon")
                --     if highAttr and highIcon then
                --         if self:getTeamBoostLock(i, self._teamsData[indexId]) then
                --             highIcon:setVisible(true)
                --             highAttr:loadTexture("teamboost_img4.png", 1)
                --             local tempIndex = sysTeam["highAttr"][i][1] or 1
                --             highIcon:loadTexture("teamboost_nature" .. tempIndex .. ".png", 1)
                --         else
                --             highIcon:setVisible(false)
                --             highAttr:loadTexture("teamboost_img3.png", 1)
                --         end
                --     end
                -- end
                for i=1,9 do
                    local highAttr = teamCell:getChildByFullName("highAttr" .. i)
                    -- local highIcon = teamCell:getChildByFullName("highAttr" .. i .. ".highIcon")
                    if highAttr then
                        if self:getTeamBoostLock(i, self._teamsData[indexId]) then
                            highAttr:loadTexture("teamboost_img5.png", 1)
                        else
                            highAttr:loadTexture("teamboost_img4.png", 1)
                        end
                    end
                end

                local shang = teamCell:getChildByFullName("shang")
                if self._teamsData[indexId].isInFormation == 1 then
                    shang:setVisible(true)
                else
                    shang:setVisible(false)
                end
             
                local biaoqian = teamCell:getChildByFullName("biaoqian")
                if self._teamsData[indexId].sortId == 1 then
                    biaoqian:setVisible(true)
                else
                    biaoqian:setVisible(false)
                end
                
                local downY
                local clickFlag = false
                registerTouchEvent(
                    teamCell,
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
                        if self._callback ~= nil and clickFlag == false then 
                            self._callback(self._teamsData[indexId].teamId)
                            self:close()
                        end
                    end,
                    function ()
                    end)
                teamCell:setSwallowTouches(false)

                teamCell:setVisible(true)
            else
                teamCell:setVisible(false)
            end
        end
    end
end

-- 判断加锁
function TeamBoostSelectDialog:getTeamBoostLock(index, teamData)
    local flag = true -- false
    local boostD = teamData.tb
    local highAttrLock = tab:Setting("G_TECHNIQUE_UNLOCK").value
    if boostD and table.nums(boostD) > 0 then
        for k,v in pairs(boostD) do
            if v < highAttrLock[index] then
                flag = false
                break
            end
        end
        if flag == true and table.nums(boostD) < 4  then
            flag = false
        end
    else
        flag = false
    end

    return flag
end

return TeamBoostSelectDialog