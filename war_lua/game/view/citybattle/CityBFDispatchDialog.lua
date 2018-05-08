--[[
    Filename:    CityBFDispatchDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-11-26 11:59:30
    Description: File description
--]]

-- GVG 部队派遣
local CityBFDispatchDialog = class("CityBFDispatchDialog", BasePopView)

function CityBFDispatchDialog:ctor(param)
    CityBFDispatchDialog.super.ctor(self)
    self._cityId = param.cityId
end

function CityBFDispatchDialog:onInit()
    self._formationModel = self._modelMgr:getModel("FormationModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._heroModel = self._modelMgr:getModel("HeroModel")
    self._cityBattleModel = self._modelMgr:getModel("CityBattleModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    
    self:registerClickEventByName("bg.closeBtn", function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("citybattle.CityBFDispatchDialog")
        end
        self:close()
    end)
    -- local burst = self:getUI("bg.layer.burst")

    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 4)

    self._formationCell = self:getUI("cell")

    self:addTableView()
end

function CityBFDispatchDialog:reflashUI()
    local tform = self._cityBattleModel:getGVGFmdFightData()
    dump(tfor, "form====", 10)

    self._tableView:reloadData()
end


function CityBFDispatchDialog:reflashData()

end


--[[
用tableview实现
--]]
function CityBFDispatchDialog:addTableView()
    print("==============+++")
    local tableViewBg = self:getUI("bg.tableViewBg")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self._tableView:setPosition(cc.p(0, 6))
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
function CityBFDispatchDialog:tableCellTouched(table,cell)
end

-- cell的尺寸大小
function CityBFDispatchDialog:cellSizeForTable(table,idx) 
    local width = 272 
    local height = 339
    return height, width
end

-- 创建在某个位置的cell
function CityBFDispatchDialog:tableCellAtIndex(table, idx)
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

        local dispatch = formationCell:getChildByFullName("dispatch")
        dispatch:getTitleRenderer():enableOutline(cc.c4b(124, 64, 0, 255), 2)

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
function CityBFDispatchDialog:numberOfCellsInTableView(table)
    return 4 
end

-- 1复活 2未编辑 3未解锁 4创建 5查看可撤回 6不可撤回
function CityBFDispatchDialog:getFMState(_type, formation, indexId)
    -- local gvgffd = self._citybattleModel:getGVGFmdFightData()
    -- dump(formation, "formation======", 10)
    local userLvl = self._userModel:getData().lvl
    local suoLv = tab:Setting("G_CITYBATTLE_FORMATION_LV").value

    local state = 0
    if userLvl < suoLv[indexId] then
        state = 3
    elseif formation.heroId == 0 then
        state = 2
    -- elseif conditions then
    --     --todo
    -- elseif formation["score"] and formation["score"] == 0 then
    --     state = 4
    -- elseif gvgffd[_type] and gvgffd[_type] == 1 then
    --     state = 5
    -- elseif gvgffd[_type] and gvgffd[_type] == 2 then
    --     state = 6
    end

    -- local gvgud = self._citybattleModel:getGVGUserData()
    -- dump(gvgud)

    return state
end

-- 更新tableView数据
function CityBFDispatchDialog:updateCell(inView, data, indexId)
    if not inView then
        return
    end

    local fmType = self._formationModel["kFormationTypeCityBattle" .. indexId]
    local formation = self._formationModel:getFormationDataByType(fmType)
    local teamState = self:getFMState(fmType, formation, indexId)
    local tform = self._cityBattleModel:getGVGFmdFightData()
    dump(tform, "tform=====", 10)
        
    local titleBg = inView:getChildByFullName("titleBg")
    local heroBg = inView:getChildByFullName("heroBg")
    local dispatch = inView:getChildByFullName("dispatch")
    local nothing = inView:getChildByFullName("nothing")
    local suo = inView:getChildByFullName("suo")

    -- 解锁等级
    local suoLv = tab:Setting("G_CITYBATTLE_FORMATION_LV").value
    local suoLab = inView:getChildByFullName("suo.lvlLab")
    suoLab:setString("Lv. " .. suoLv[indexId] .. "解锁")

    -- 战力
    local fight = inView:getChildByFullName("titleBg.fightLab")
    local scoreFight = self._formationModel:getCurrentFightScoreByType(fmType)
    fight:setString("a" .. scoreFight)

    -- 英雄
    local heroBg = inView:getChildByFullName("heroBg")
    if formation["heroId"] and formation["heroId"] ~= 0 then
        if heroBg.heroArt then
            heroBg.heroArt:removeFromParent()
        end
        local heroD = tab:Hero(formation["heroId"])
        heroBg.heroArt = mcMgr:createViewMC("stop_" .. heroD.heroart, true,false,function( )
        end)
        heroBg.heroArt:setPosition(100, 22)
        heroBg.heroArt:setScale(0.8)
        -- heroBg.heroArt:gotoAndStop(1)
        heroBg:addChild(heroBg.heroArt)
        -- HeroAnim.new(heroBg, heroD.heroart, {"stop", "run"}, function (mc)
        --     mc:stop()
        --     mc:setPosition(100, 22)
        --     mc:setScale(0.4)
        --     mc:changeMotion("stop")
        --     heroBg.heroArt = mc
        -- end, false, nil, nil, false)
        heroBg:setVisible(true)
    else
        heroBg:setVisible(false)
    end

    -- if indexId == 4 then
    --     print("teamNum========", indexId)
    --     dump(formation)
    --     dump(inHeroData)
    -- end

    -- 名字
    local name = inView:getChildByFullName("titleBg.name")
    if tform and tform[fmType] then
        print("========", tform[fmType])
        local cityBattleTab = tab:CityBattle(tform[fmType])
        name:setString("第" .. indexId .. "队 " .. lang(cityBattleTab.name))
        -- dispatch:setTitleText("查看")
        dispatch:setTitleText("撤回")
        self:registerClickEvent(dispatch, function()
            local desStr = "将XXX撤回"
            self._viewMgr:showDialog("global.GlobalSelectDialog", {desc = desStr, button1 = "", 
                callback1 = function()
                    local param = {fid = fmType, cid = tform[fmType]}
                    local callback = function()
                        self:updateCell(inView, data, indexId)
                    end
                    self:withDrawTeam(param, callback)
                    -- self:updateCell(inView, data, indexId)
                end, 
                button2 = "", callback2 = nil,titileTip=true},true)
            -- local param = {fid = fmType, cid = self._cityId}
            -- local callback = function()
            --     self:updateCell(inView, data, indexId)
            -- end
            -- self:sendTeam(param, callback)
        end)
    else
        name:setString("第" .. indexId .. "队")
        dispatch:setTitleText("派遣")
        self:registerClickEvent(dispatch, function()
            local param = {fid = fmType, cid = self._cityId}
            local callback = function()
                self:updateCell(inView, data, indexId)
            end
            self:sendTeam(param, callback)
        end)
    end

    local dispatchBg = inView:getChildByFullName("dispatchBg")
    dispatchBg:setVisible(false)

    if teamState == 3 then
        titleBg:setVisible(false)
        dispatch:setVisible(false)
        heroBg:setVisible(false)
        suo:setVisible(true)
    elseif teamState == 2 then
        titleBg:setVisible(false)
        dispatch:setVisible(false)
        heroBg:setVisible(false)
        suo:setVisible(true)
        suoLab:setString("该编组未编辑")
    else
        titleBg:setVisible(true)
        dispatch:setVisible(true)
        heroBg:setVisible(true)
        suo:setVisible(false)
    end

    -- self:registerClickEvent(nothing, function()
    --     self:openFormation(indexId)
    -- end)

    -- local clickFlag, downX
    -- self:registerTouchEvent(nothing,
    --     function (_, x, y)
    --         downX = x
    --         clickFlag = false
    --     end,
    --     function (_, x, y)
    --         if downX and math.abs(downX-x) > 5 then
    --             clickFlag = true
    --         end
    --     end,
    --     function (_, x, y)
    --         if clickFlag == false then
    --             self:openFormation(indexId)
    --         end
    --     end,
    --     function()
    --     end)
    -- nothing:setSwallowTouches(false)
end

-- 撤回兵团
function CityBFDispatchDialog:withDrawTeam(param, callback)
    if not param then
        return
    end
    self._serverMgr:sendMsg("CityBattleServer", "withDrawTeam", param, true, {}, function(result) 
        -- local tempData = {param["cid"] = param["fid"]}
        -- self._cityBattleModel:retreatFormation(tempData)
        dump(result, "result===", 10)
        if callback then
            callback()
        end
    end)
end

-- 派遣兵团
function CityBFDispatchDialog:sendTeam(param, callback)
    self._serverMgr:sendMsg("CityBattleServer", "sendTeam", param, true, {}, function (result)
        dump(result, "result=========", 10)
        if self.sendTeamFinish then
            self:sendTeamFinish(result)
            if callback then
                callback()
            end
            
        end
    end)
end

function CityBFDispatchDialog:sendTeamFinish(result)
    
end

return CityBFDispatchDialog