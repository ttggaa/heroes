--[[
    Filename:    GodWarFightDetailDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-06-05 15:57:15
    Description: File description
--]]

-- 战况详情
local GodWarFightDetailDialog = class("GodWarFightDetailDialog", BasePopView)
local jiange = GodWarUtil.fightTime -- 每场间隔
local readlyTime = GodWarUtil.readlyTime -- 准备间隔
local fightTime = GodWarUtil.fightTime -- 战斗间隔
function GodWarFightDetailDialog:ctor(param)
    GodWarFightDetailDialog.super.ctor(self)
    -- self._groupId = param.groupId
    -- self._index = param.indexId
    -- self._callbackFight = param.callbackFight
    -- self._scrollId = param.scrollId
    self._tableData = {}
end

-- 初始化UI后会调用, 有需要请覆盖
function GodWarFightDetailDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("godwar.GodWarFightDetailDialog")
        end
        self:close()
    end)

    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._godWarModel = self._modelMgr:getModel("GodWarModel")

    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)

    self._fightCell = self:getUI("fightCell")
    self._fightCell:setVisible(false)

    self:addTableView()
    self:reciprocalTime()
end


-- 接收自定义消息
function GodWarFightDetailDialog:reflashUI(data)
    -- dump(data)
    self._transmissionData = data 
    self._serverData = data.serverData
    self._differ = data.differ
    self._callbackFight = data.callbackFight
    self._fightData = data.fightData 
    if self._differ == 1 then
        local serverData = data.serverData
        local gpData = self._godWarModel:getGroupById(serverData.gp)
        if serverData.round and serverData.ju then
            local round = tostring(serverData.round)
            local ju = tostring(serverData.ju)
            self._fightData = gpData[round][ju]
        end
    end
    if self._fightData["gp"] then
        self._showDraw = true
    end
    self._reverse = self._fightData.onReverse or false
    self:progressTableData(data.list)
    local nothing = self:getUI("bg.nothing")
    if table.nums(self._tableData) == 0 then
        nothing:setVisible(true)
    else
        nothing:setVisible(false)
    end
    self._tableView:reloadData()
    -- self:updateConditionDes()
end

function GodWarFightDetailDialog:progressTableData(data)
    dump(self._fightData, "data===", 3)
    local tableData = {}
    local reps = self._fightData["reps"]
    if not reps then
        reps = {}
    end
    local userid = self._userModel:getData()._id
    self._winlose = {0,0,0}
    for i=1,3 do
        local indexId = tostring(i)
        local repData = data[indexId]
        local battleD = reps[indexId]
        if battleD and repData then
            local atkId = repData.atk.rid
            local atkData = self._godWarModel:getPlayerById(atkId)
            repData.atk.name = atkData.name
            local defId = repData.def.rid
            local defData = self._godWarModel:getPlayerById(defId)
            repData.def.name = defData.name

            self._winlose[i] = battleD["w"] or 0
            if self._showDraw == true then
                if userid == defId then
                    if battleD["w"] == 1 then
                        self._winlose[i] = 2
                    elseif battleD["w"] == 2 then
                        self._winlose[i] = 1
                    end
                end
            end
            if not battleD.battleReport then
                battleD.battleReport = repData
            end
        end
        table.insert(tableData, repData)
    end
    self._tableData = tableData

end

--[[
用tableview实现
--]]
function GodWarFightDetailDialog:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")

    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setAnchorPoint(0, 0)
    self._tableView:setPosition(0, 5)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(true)
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    tableViewBg:addChild(self._tableView)
end

-- cell的尺寸大小
function GodWarFightDetailDialog:cellSizeForTable(table,idx) 
    local width = 690
    local height = 195
    return height, width
end

-- 创建在某个位置的cell
function GodWarFightDetailDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local param = self._tableData[idx+1]
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local fightCell = self._fightCell:clone() 
        fightCell:setVisible(true)
        fightCell:setAnchorPoint(0, 0)
        fightCell:setPosition(0, 0) --0
        fightCell:setName("fightCell")
        cell:addChild(fightCell)

        -- local fightPanel = self:getUI("bg.fightPanel")
        -- fightPanel:setVisible(false)
        -- local fightPanel = fightCell:getChildByFullName("fightPanel")
        -- fightPanel:setVisible(false)
        -- nameBg:setOpacity(100)
        -- local name = fightCell:getChildByFullName("name")


        -- local bg1 = fightCell:getChildByFullName("bg1")
        -- -- local bg2 = fightCell:getChildByFullName("bg2")
        -- titleCell:setCapInsets(cc.rect(25, 25, 1, 1))
        -- bg1:setCapInsets(cc.rect(25, 25, 1, 1))
        self:updateCell(fightCell, param, indexId)
    else
        print("wo shi shua xin")
        local fightCell = cell:getChildByName("fightCell")
        if fightCell then
            self:updateCell(fightCell, param, indexId)
        end
    end

    return cell
end

-- 返回cell的数量
function GodWarFightDetailDialog:numberOfCellsInTableView(table)
    return self:cellLineNum() -- 
end

function GodWarFightDetailDialog:cellLineNum()
    return table.nums(self._tableData) 
end

function GodWarFightDetailDialog:updateCell(inView, param, indexId)
    local chakanBtn = inView:getChildByFullName("chakanBtn")
    if chakanBtn then
        self:registerClickEvent(chakanBtn, function()
            if self._callbackFight then
                self._callbackFight(param, self._winlose, self._showDraw)
            end
        end)
    end

    local stateLab = inView:getChildByFullName("stateLab")
    if stateLab then
        stateLab:setString("第" .. indexId .. "局")
    end

    local leftPanel = inView:getChildByFullName("left")
    local rightPanel = inView:getChildByFullName("right")
    local leftData = param.atk
    local rightData = param.def
    local leftWin = true
    local rightWin = false

    local reps = self._fightData["reps"]
    local tIndexId = tostring(indexId)
    if reps and reps[tIndexId] and reps[tIndexId]["w"] == 1 then
        leftWin = true
        rightWin = false
    elseif reps and reps[tIndexId] and reps[tIndexId]["w"] == 2 then
        leftWin = false
        rightWin = true
    else
        leftWin = false
        rightWin = false
    end

    if self._reverse == true then
        leftData = param.def
        rightData = param.atk
        -- 反转时换红蓝点
        local rightPoint = rightPanel:getChildByFullName("Image_28")
        rightPoint:loadTexture("godwarImageUI_img148.png",1)
        rightPoint:setContentSize(cc.size(13,13))
        local leftPoint = leftPanel:getChildByFullName("Image_27")
        leftPoint:loadTexture("godwarImageUI_img147.png",1)
        leftPoint:setContentSize(cc.size(13,13))
    end
    self:updatePanel(leftPanel, leftData, indexId, leftWin)
    self:updatePanel(rightPanel, rightData, indexId, rightWin)
end

function GodWarFightDetailDialog:updatePanel(inView, data, indexId, win)
    -- local victory = inView:getChildByFullName("victory")
    local winImg = inView:getChildByFullName("winImg")
    if winImg then
        if win == true then
            -- victory:setVisible(true)
            winImg:setVisible(true)
        else
            -- victory:setVisible(false)
            winImg:setVisible(false)
        end
    end

    local tname = inView:getChildByFullName("tname")
    if tname then
        tname:setString(data.name)
    end

    local formationData = data.formation
    local teamsData = data.teams
    local heroId = formationData.heroId
    if heroId == 0 then
        heroId = 60102
        data.hero = {
            m1     = 62221,
            m2     = 62111,
            m3     = 62021,
            m4     = 62001,
            score  = 11601,
            se1    = 0,
            se2    = 0,
            se3    = 0,
            se4    = 0,
            skin   = 26030101,
            sl1    = 1,
            sl2    = 1,
            sl3    = 1,
            sl4    = 1,
            st     = 1497409581,
            star   = 1,
            status = 0,
        }
    end
    local heroData = data.hero

    local heroBg = inView:getChildByFullName("heroBg")
    if heroBg then
        if not heroBg.heroIcon then
            local heroIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
            heroIcon:setScale(0.7)
            heroIcon:setPosition(heroBg:getContentSize().width * 0.5, heroBg:getContentSize().height * 0.5)
            heroBg:addChild(heroIcon)
            heroBg.heroIcon = heroIcon
        else
            IconUtils:updateHeroIconByView(heroBg.heroIcon, {sysHeroData = heroData})
        end

        self:registerClickEvent(heroBg.heroIcon,function( )
            local detailData = {}
            detailData.heros = data.hero
            detailData.heros.heroId = data.formation.heroId
            if data.globalSpecial and data.globalSpecial ~= "" then
                detailData.globalSpecial = data.globalSpecial
            end
            detailData.level = data.lv 
            detailData.treasures = data.treasures
            detailData.hAb = data.hAb
            detailData.talentData = data.talentData or data.talent
            detailData.uMastery = data.uMastery
            detailData.hSkin = data.hSkin
            -- ViewManager:getInstance():showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeArenaHero, iconId = data.formation.heroId}, true)
            ViewManager:getInstance():showDialog("rank.RankHeroDetailView", {data=detailData}, true)
        end)
    end

    for i=1,6 do
        local teamBg = inView:getChildByFullName("teamBg" .. i)
        local teamId = formationData["team" .. i]
        if teamId == 0 then
            self:createGrid(teamBg,isLocked)
        else
            local teamData = teamsData[tostring(teamId)]
            self:createTeams(teamBg, teamId, teamData, heroData, heroId, data)
        end
    end
end

function GodWarFightDetailDialog:createGrid(teamBg,isLocked)
    local bagGrid = ccui.Widget:create()
    bagGrid:setContentSize(cc.size(107,107))
    bagGrid:setAnchorPoint(cc.p(0,0))

    local bagGridFrame = ccui.ImageView:create()
    bagGridFrame:loadTexture("globalImageUI4_squality1.png", 1)
    bagGridFrame:setName("bagGridFrame")
    bagGridFrame:setContentSize(cc.size(107, 107))
    bagGridFrame:ignoreContentAdaptWithSize(false)
    bagGridFrame:setAnchorPoint(cc.p(0,0))
    bagGrid:addChild(bagGridFrame,1)

    local bagGridBg = ccui.ImageView:create()
    bagGridBg:loadTexture("globalImageUI4_itemBg3.png", 1)
    bagGridBg:setName("bagGridBg")
    bagGridBg:setContentSize(cc.size(107, 107))
    bagGridBg:ignoreContentAdaptWithSize(false)
    bagGridBg:setAnchorPoint(cc.p(0.5,0.5))
    bagGridBg:setPosition(cc.p(bagGrid:getContentSize().width/2,bagGrid:getContentSize().height/2))
    bagGrid:addChild(bagGridBg,-1)

    -- locked
    if isLocked then
        local lockImg = ccui.ImageView:create()
        lockImg:loadTexture("globalImageUI5_treasureLock.png", 1)
        lockImg:setName("lockImg")
        lockImg:setAnchorPoint(cc.p(0.5,0.5))
        lockImg:setScale(1.5)
        lockImg:setPosition(cc.p(bagGrid:getContentSize().width/2,bagGrid:getContentSize().height/2))
        bagGrid:addChild(lockImg,2)
    end
    bagGrid:setScale(0.5)
    bagGrid:setPosition(5, 5)
    teamBg:addChild(bagGrid)
end

function GodWarFightDetailDialog:createTeams(teamBg, teamId, teamData, heroData, heroId, data)
    -- dump(teamData)
    local teamD = tab:Team(teamId)
    -- print("===========data.formation.heroId,teamId=>",data.formation.heroId,teamId)
    local _,changeId = TeamUtils.changeArtForHeroMasteryByData(heroData,heroId,teamId)
    -- print("===========cahngeId=========",changeId)
    if changeId then
        teamD = tab:Team(changeId)
    end
    local quality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(teamData.stage)
    local teamParam = {teamData = teamData,sysTeamData = teamD, quality = quality[1] , quaAddition = quality[2],eventStyle=3,clickCallback = function( )        
        local detailData = {}
        detailData.team = teamData
        detailData.team.teamId = teamId
        if changeId then
            detailData.team.teamId = changeId
        end    
        detailData.pokedex = data.pokedex 
        detailData.treasures = data.treasures
        detailData.runes = data.runes
        detailData.heros = data.heros
        ViewManager:getInstance():showDialog("rank.RankTeamDetailView", {data=detailData}, true)
        -- ViewManager:getInstance():showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeArenaTeam, iconId = teamId}, true)
    end}
    -- local teamIcon = teamBg:getChildByName("teamBg")
    if not teamBg.teamIcon then
        local teamIcon = IconUtils:createTeamIconById(teamParam)
        teamIcon:setScale(0.5)
        teamIcon:setName("teamIcon")
        teamIcon:setPosition(5, 5)
        teamBg:addChild(teamIcon)
        teamBg.teamIcon = teamIcon
    else
        IconUtils:updateTeamIconByView(teamBg.teamIcon, teamParam)
    end
end


-- 战斗时间段刷新
function GodWarFightDetailDialog:reciprocalTime()
    self._refshUI = 0
    local title = self:getUI("bg.titleBg.title")
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    if weekday == 2 or weekday == 3 or weekday == 4 then
        local minTime = 0 
        local lastTime = 0
        local begTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        local endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:36:00"))
        if weekday == 2 then
            endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
            local middleTime = 2
            for i=1,9 do
                local strTime = i*middleTime+1
                local ttempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:" .. strTime .. ":00"))
                print("curServerTime < ttempTime=========", curServerTime, ttempTime)
                if curServerTime < ttempTime then
                    minTime = ttempTime
                    lastTime = ttempTime - 120
                    break
                else
                    minTime = 1697952865
                end
            end
        elseif weekday == 3 then
            endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:36:05"))
            local middleTime = math.floor((readlyTime + fightTime)/60)
            for i=1,12 do
                local strTime = i*middleTime
                local ttempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:" .. strTime .. ":05"))
                if curServerTime < ttempTime then
                    minTime = ttempTime
                    lastTime = ttempTime - 180
                    break
                else
                    minTime = 1697952865
                end
            end
        elseif weekday == 4 then
            for i=1,11 do
                local strTime = i*5
                local ttempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:" .. strTime .. ":05"))
                if curServerTime < ttempTime then
                    minTime = ttempTime
                    lastTime = ttempTime - 180
                    break
                else
                    minTime = 1697952865
                end
            end
        end
        self._reloadFlag = lastTime
        local callFunc = cc.CallFunc:create(function()
            local curServerTime = self._userModel:getCurServerTime()
            if curServerTime > begTime and curServerTime <= endTime then
                -- if minTime ~= 0 then
                --     if self._refshUI <= curServerTime then
                --         print("刷新+++++++++++++++++")
                --         self._refshUI = minTime
                --         self._refshUI = self._refshUI + 300
                --     end
                -- end
                -- print("curServerTime=======", minTime, curServerTime, self._reloadFlag)
                if curServerTime >= minTime then
                    if self._reloadFlag ~= minTime then
                        self._reloadFlag = minTime
                        print("_reloadFlag==========", minTime)
                        if self._differ == 1 then
                            self:getGroupBattleInfo()
                        else
                            self:getWarBattleInfo()
                        end
                        self:reciprocalTime()
                    end
                end
            end
        end)
        local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
        title:stopAllActions()
        title:runAction(cc.RepeatForever:create(seq))
    end
end

function GodWarFightDetailDialog:getGroupBattleInfo()
    local param = self._serverData or {}
    dump(param)
    self._serverMgr:sendMsg("GodWarServer", "getGroupBattleInfo", param, true, {}, function(result)
        self._transmissionData.list = result
        self:reflashUI(self._transmissionData)
    end, function(errorId)
        if tonumber(errorId) == 113 then
            self._viewMgr:showTip(lang("REPLAY_CLEAR_TIP"))
        end
    end)
end

function GodWarFightDetailDialog:getWarBattleInfo()
    local param = self._serverData or {}
    dump(param)
    self._serverMgr:sendMsg("GodWarServer", "getWarBattleInfo", param, true, {}, function(result) 
        self._transmissionData.list = result
        self:reflashUI(self._transmissionData)
    end, function(errorId)
        if tonumber(errorId) == 113 then
            self._viewMgr:showTip(lang("REPLAY_CLEAR_TIP"))
        end
    end)
end

return GodWarFightDetailDialog