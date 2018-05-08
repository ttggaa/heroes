--[[
    Filename:    CityBFChangeDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-11-28 11:30:47
    Description: File description
--]]

-- GVG布阵编辑

local CityBFChangeDialog = class("CityBFChangeDialog", BasePopView)

function CityBFChangeDialog:ctor()
    CityBFChangeDialog.super.ctor(self)
end

function CityBFChangeDialog:onInit()
    self._formationModel = self._modelMgr:getModel("FormationModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._heroModel = self._modelMgr:getModel("HeroModel")
    self._citybattleModel = self._modelMgr:getModel("CityBattleModel")
    self._userModel = self._modelMgr:getModel("UserModel")

    self:registerClickEventByName("bg.closeBtn", function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("citybattle.CityBFChangeDialog")
        end
        self:close()
    end)

    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 4)

    self._formationCell = self:getUI("cell")

    self:addTableView()

    self:listenReflash("FormationModel", self.reflashUI)
end

function CityBFChangeDialog:reflashUI()
    self._tableView:reloadData()
end

function CityBFChangeDialog:reflashData()

end

--[[
用tableview实现
--]]
function CityBFChangeDialog:addTableView()
    print("==============+++")
    local tableViewBg = self:getUI("bg.tableViewBg")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    -- self._tableView:setBounceable(true)
    -- self._tableView:reloadData()
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    
    tableViewBg:addChild(self._tableView)
end

-- 触摸时调用
function CityBFChangeDialog:tableCellTouched(table,cell)
end

-- cell的尺寸大小
function CityBFChangeDialog:cellSizeForTable(table,idx) 
    local width = 280 
    local height = 339
    return height, width
end

-- 创建在某个位置的cell
function CityBFChangeDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    -- local param = self._peerageData[idx+1]
    local indexId = idx+1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local formationCell = self._formationCell:clone() 
        formationCell:setVisible(true)
        formationCell:setAnchorPoint(cc.p(0,0))
        formationCell:setPosition(cc.p(0,5))
        formationCell:setName("formationCell")
        cell:addChild(formationCell)

        local lookFM = formationCell:getChildByFullName("lookFM")
        lookFM:getTitleRenderer():enableOutline(cc.c4b(124, 64, 0, 255), 2)
        local lookFM = formationCell:getChildByFullName("lookFM")
        lookFM:getTitleRenderer():enableOutline(cc.c4b(124, 64, 0, 255), 2)

        local titleBg = formationCell:getChildByFullName("titleBg")
        local fightLab = cc.LabelBMFont:create("1", UIUtils.bmfName_zhandouli_little)
        fightLab:setName("fightLab")
        fightLab:setScale(0.8)
        fightLab:setAnchorPoint(cc.p(0.5, 0.5))
        fightLab:setPosition(cc.p(110, -20))
        titleBg:addChild(fightLab, 1)

        local name = formationCell:getChildByFullName("titleBg.name")
        UIUtils:setTitleFormat(name, 3, 1)
    end

    local formationCell = cell:getChildByName("formationCell")
    if formationCell then
        self:updateCell(formationCell, param, indexId)
        formationCell:setSwallowTouches(false)
    end

    return cell
end

-- 返回cell的数量
function CityBFChangeDialog:numberOfCellsInTableView(table)
    return 4 
end


-- 1复活 2编辑 3未解锁 4创建 5查看可撤回 6不可撤回
function CityBFChangeDialog:getFMState(_type, formation, indexId)
    local gvgffd = self._citybattleModel:getGVGFmdFightData()
    local userLvl = self._userModel:getData().lvl
    local suoLv = tab:Setting("G_CITYBATTLE_FORMATION_LV").value

    local state = 0
    if userLvl < suoLv[indexId] then
        state = 3
    elseif conditions then
        --todo
    elseif conditions then
        --todo
    elseif formation["heroId"] and formation["heroId"] == 0 then
        state = 4
    elseif gvgffd[_type] and gvgffd[_type] == 1 then
        state = 5
    elseif gvgffd[_type] and gvgffd[_type] == 2 then
        state = 6
    end

    -- local gvgud = self._citybattleModel:getGVGUserData()
    -- dump(gvgud)

    return state
end

-- function CityBFChangeDialog:getGVGFmDeadData()
--     local gvgud = self._citybattleModel:getGVGUserData()
--     dump(gvgud)
--     local tform = {}
--     for k,v in pairs(gvgud["c"]) do
--         for k1,v1 in pairs(v) do
--             tform[k1] = v1
--         end
--     end
-- end

-- 更新tableView数据
function CityBFChangeDialog:updateCell(inView, data, indexId)
    if not inView then
        return
    end

    local fmType = self._formationModel["kFormationTypeCityBattle" .. indexId]
    local formation = self._formationModel:getFormationDataByType(fmType)
    local teamState = self:getFMState(fmType, formation, indexId)
    -- print("self._cityBattleModel============", self._cityBattleModel)
    -- if not self._cityBattleModel then
    --     return
    -- end
    local tform = self._modelMgr:getModel("CityBattleModel"):getGVGFmdFightData()
    dump(tform, "formation=======" .. fmType)
        
    local titleBg = inView:getChildByFullName("titleBg")
    local heroBg = inView:getChildByFullName("heroBg")
    local teamNode = inView:getChildByFullName("teamNode")
    local revive = inView:getChildByFullName("revive")
    local lookFM = inView:getChildByFullName("lookFM")
    local nothing = inView:getChildByFullName("nothing")
    local suo = inView:getChildByFullName("suo")

    -- 解锁等级
    local suoLv = tab:Setting("G_CITYBATTLE_FORMATION_LV").value
    local suoLab = inView:getChildByFullName("suo.lvlLab")
    suoLab:setString("Lv. " .. suoLv[indexId] .. "解锁")

    -- 名字
    local name = inView:getChildByFullName("titleBg.name")
    if tform and tform[fmType] then
        local cityBattleTab = tab:CityBattle(tform[fmType])
        name:setString("第" .. indexId .. "队 " .. lang(cityBattleTab.name))
    else
        name:setString("第" .. indexId .. "队")
    end

    -- 战力
    local fight = inView:getChildByFullName("titleBg.fightLab")
    local scoreFight = self._formationModel:getCurrentFightScoreByType(fmType)
    fight:setString("a" .. (scoreFight or 0))

    -- 英雄
    -- local heroBg = inView:getChildByFullName("heroBg")
    if formation["heroId"] and formation["heroId"] ~= 0 then
        local inHeroData = self._heroModel:getHeroData(formation["heroId"])
        local heroD = clone(tab:Hero(formation["heroId"]))
        heroD.star = inHeroData["star"]
        local param = {sysHeroData = heroD}
        self:createHeroGrid(heroBg, 1, param)
    else
        self:createHeroGrid(heroBg)
    end

    -- if indexId == 4 then
    --     print("teamNum========", indexId)
    --     dump(formation)
    --     dump(inHeroData)
    -- end

    -- 兵团
    -- local teamF = self:getFormationTeamNum(formation)
    -- dump(formation, "teamF=====")
    -- dump(teamF, "teamF=====")
    for i=1,16 do
        local teamBg = inView:getChildByFullName("teamNode.teamBg" .. i)
        teamBg:setVisible(false)
    end
    for i=1,8 do
        local teamPos = formation["g" .. i]
        local teamId = formation["team" .. i]
        local teamBg = inView:getChildByFullName("teamNode.teamBg" .. teamPos)
        if teamId and teamId ~= 0 then
            local inTeamData = self._teamModel:getTeamAndIndexById(teamId)
            local backQuality = self._teamModel:getTeamQualityByStage(inTeamData.stage)
            local sysTeam = tab:Team(teamId)
            local param = {teamData = inTeamData, sysTeamData = sysTeam,quality = backQuality[1] , quaAddition = backQuality[2],  eventStyle = 0}
            self:createTeamGrid(teamBg, 1, param)
        end
    end

    self:registerClickEvent(revive, function()
        print("fuhuo========")
        self:openFormation(indexId)
    end)
    
    self:registerClickEvent(lookFM, function()
        self:openFormation(indexId)
    end)
    -- self:registerClickEvent(nothing, function()
    --     self:openFormation(indexId)
    -- end)

    local clickFlag, downX
    self:registerTouchEvent(nothing,
        function (_, x, y)
            downX = x
            clickFlag = false
        end,
        function (_, x, y)
            if downX and math.abs(downX-x) > 5 then
                clickFlag = true
            end
        end,
        function (_, x, y)
            if clickFlag == false then
                self:openFormation(indexId)
            end
        end,
        function()
        end)
    nothing:setSwallowTouches(false)


    if teamState == 1 then -- 带复活
        titleBg:setVisible(true)
        heroBg:setVisible(true)
        teamNode:setVisible(true)
        revive:setVisible(true)
        lookFM:setVisible(false)
        nothing:setVisible(false)
        suo:setVisible(false)
    elseif teamState == 2 then -- 可编辑
        titleBg:setVisible(true)
        heroBg:setVisible(true)
        teamNode:setVisible(true)
        revive:setVisible(false)
        lookFM:setVisible(true)
        lookFM:setTitleText("编辑")
        nothing:setVisible(false)
        suo:setVisible(false)
    elseif teamState == 3 then -- 未解锁
        titleBg:setVisible(false)
        heroBg:setVisible(false)
        teamNode:setVisible(false)
        revive:setVisible(false)
        lookFM:setVisible(false)
        nothing:setVisible(false)
        suo:setVisible(true)
    elseif teamState == 4 then -- 可创建
        titleBg:setVisible(false)
        heroBg:setVisible(false)
        teamNode:setVisible(false)
        revive:setVisible(false)
        lookFM:setVisible(false)
        nothing:setVisible(true)
        suo:setVisible(false)
    else    -- 不可编辑
        titleBg:setVisible(true)
        heroBg:setVisible(true)
        teamNode:setVisible(true)
        revive:setVisible(false)
        lookFM:setVisible(true)
        lookFM:setTitleText("查看")
        nothing:setVisible(false)
        suo:setVisible(false)
    end


    -- if formation["score"] and formation["score"] == 0 then
    --     titleBg:setVisible(false)
    --     heroBg:setVisible(false)
    --     teamNode:setVisible(false)
    --     revive:setVisible(false)
    --     lookFM:setVisible(false)
    --     nothing:setVisible(true)
    -- else
    --     titleBg:setVisible(true)
    --     heroBg:setVisible(true)
    --     teamNode:setVisible(true)
    --     nothing:setVisible(false)
    -- end
end

function CityBFChangeDialog:openFormation(indexId)
    print("===========")
    self._playerModel = self._modelMgr:getModel("PlayerTodayModel")
    local playerData = self._playerModel:getData()
    local receive = playerData["day37"]

    local ftcb1 = self._formationModel.kFormationTypeCityBattle1
    local ftcb2 = self._formationModel.kFormationTypeCityBattle2
    local ftcb3 = self._formationModel.kFormationTypeCityBattle3
    local ftcb4 = self._formationModel.kFormationTypeCityBattle4

    local cityBattleInfo = 
        {
            -- 复活次数
            reviveInfo = {
                [ftcb1] = receive,
                [ftcb2] = receive,
                [ftcb3] = receive,
                [ftcb4] = receive,
            },

            -- 是否死亡， 死亡为秒
            deadInfo = {
                [ftcb1] = self:getFormationDead(ftcb1),
                [ftcb2] = self:getFormationDead(ftcb2),
                [ftcb3] = self:getFormationDead(ftcb3),
                [ftcb4] = self:getFormationDead(ftcb4),
            },

            -- 是否出战
            fightInfo = {
                [ftcb1] = self:getFormationFight(ftcb1),
                [ftcb2] = self:getFormationFight(ftcb2),
                [ftcb3] = self:getFormationFight(ftcb3),
                [ftcb4] = self:getFormationFight(ftcb4),
            },  
        }
    self._viewMgr:showView("formation.NewFormationView", {
        formationType = self._formationModel.kFormationTypeCityBattle1 + indexId - 1,
        extend = {cityBattleInfo = cityBattleInfo}
    })
end

-- 兵团死亡时间
function CityBFChangeDialog:getFormationDead(fType)
    local gvguser = self._citybattleModel:getGVGUserData()
    dump(gvguser, "gvguser=========")

    local flag = false
    if (not gvguser["s"]) or (not gvguser["s"][fType]) then
        return flag
    end

    local fmationDead = gvguser["s"][fType]
    if fmationDead["t"] ~= 0 then
        flag = fmationDead["t"]
    end

    return flag
end

-- 兵团是否派遣
function CityBFChangeDialog:getFormationFight(fType)
    local gvgffd = self._citybattleModel:getGVGFmdFightData()
    local flag = false
    if gvgffd[fType] then
        flag = true
    end
    return flag
end

function CityBFChangeDialog:createHeroGrid(inView, _type, inTable)
    if not inView then
        return
    end
    local heroIcon = inView:getChildByName("heroIcon")
    local heroGrid = inView:getChildByName("heroGrid")
    if _type == 1 then
        if heroIcon then
            IconUtils:updateHeroIconByView(heroIcon, inTable)
        else
            heroIcon =IconUtils:createHeroIconById(inTable)
            heroIcon:setName("heroIcon")
            heroIcon:setAnchorPoint(cc.p(0,0))
            heroIcon:setScale(0.6)
            heroIcon:setPosition(cc.p(5, 5))
            inView:addChild(heroIcon)
        end
        heroIcon:setVisible(true)
        if heroGrid then
            heroGrid:setVisible(false)
        end
    else
        if not heroGrid then
            heroGrid = self:createGrid(1)
            heroGrid:setScale(0.6)
            heroGrid:setPosition(cc.p(0, 0))
            heroGrid:setName("heroGrid")
            inView:addChild(heroGrid)
        else
            heroGrid:setVisible(true)
        end
        if heroIcon then
            heroIcon:setVisible(false)
        end
    end
end

-- 创建兵团Icon
function CityBFChangeDialog:createTeamGrid(inView, _type, inTable)
    if not inView then
        return
    end
    local teamIcon = inView:getChildByName("teamIcon")
    local bagGrid = inView:getChildByName("bagGrid")
    if _type == 1 then
        if teamIcon then
            IconUtils:updateTeamIconByView(teamIcon, inTable)
        else
            teamIcon = IconUtils:createTeamIconById(inTable)
            teamIcon:setName("teamIcon")
            teamIcon:setScale(0.5)
            teamIcon:setPosition(cc.p(0,0))
            teamIcon:setAnchorPoint(cc.p(0, 0))
            inView:addChild(teamIcon)
        end
        teamIcon:setVisible(true)
        if bagGrid then
            bagGrid:setVisible(false)
        end
        inView:setVisible(true)
    else
        -- if not bagGrid then
        --     bagGrid = self:createGrid()
        --     bagGrid:setScale(0.5)
        --     bagGrid:setName("bagGrid")
        --     inView:addChild(bagGrid)
        -- else
        --     bagGrid:setVisible(true)
        -- end
        -- if teamIcon then
        --     teamIcon:setVisible(false)
        -- end
    end
end

-- 空框
function CityBFChangeDialog:createGrid(_type)
    local bagGrid = ccui.Widget:create()
    bagGrid:setContentSize(cc.size(107,107))
    bagGrid:setAnchorPoint(cc.p(0,0))

    local bagGridFrame = ccui.ImageView:create()
    bagGridFrame:loadTexture("globalImageUI4_squality1.png", 1)
    bagGridFrame:setName("bagGridFrame")
    bagGridFrame:setAnchorPoint(cc.p(0,0))
    bagGrid:addChild(bagGridFrame,1)

    local bagGridBg = ccui.ImageView:create()
    bagGridBg:loadTexture("globalImageUI4_itemBg3.png", 1)
    bagGridBg:setName("bagGridBg")
    bagGridBg:setContentSize(cc.size(98, 98))
    bagGridBg:ignoreContentAdaptWithSize(false)
    bagGridBg:setAnchorPoint(cc.p(0.5,0.5))
    bagGridBg:setPosition(cc.p(bagGrid:getContentSize().width/2,bagGrid:getContentSize().height/2))
    bagGrid:addChild(bagGridBg,-1)

    if _type == 1 then
        bagGridFrame:loadTexture("globalImageUI4_heroBg1.png", 1)
        bagGridFrame:setScale(1.05)
    end

    return bagGrid
end

function CityBFChangeDialog:getFormationTeamNum(data)
    local teamNum = 0
    local teamF = {}
    for i=1,8 do
        if data["team" .. i] and data["team" .. i] ~= 0 then
            teamNum = teamNum + 1
            teamF[teamNum] = data["team" .. i]
        end
    end
    -- return teamNum, teamF
    return teamF
end

return CityBFChangeDialog