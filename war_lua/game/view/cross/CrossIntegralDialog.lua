--[[
    Filename:    CrossIntegralDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-11-13 16:29:28
    Description: File description
--]]

-- 数据
local CrossIntegralDialog = class("CrossIntegralDialog", BasePopView)

local rankImg = {
    [1] = "crossUI_img26.png",
    [2] = "crossUI_img24.png",
    [3] = "crossUI_img25.png",
}

function CrossIntegralDialog:ctor(param)
    CrossIntegralDialog.super.ctor(self)
    self._tableList = param.crossPK
    self._arenaType = param.arenaType
    self._callback = param.callback
end

function CrossIntegralDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("cross.CrossIntegralDialog")
        end
        if self._callback then
            self._callback()
        end
        self:close()
    end)

    self._crossModel = self._modelMgr:getModel("CrossModel")


    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)

    self._rankCell = self:getUI("rankCell")
    self._rankCell:setVisible(false)

    local replaceBtn = self:getUI("bg.barpanel.replaceBtn")
    self:registerClickEvent(replaceBtn, function()
        local param = {region = self._arenaType}
        self._serverMgr:sendMsg("CrossPKServer", "getNowFTen", param, true, {}, function(result) 
            dump(result, "resu===========", 5)
            result["d"]["crossPK"]["arenaType"] = self._arenaType
            UIUtils:reloadLuaFile("cross.CrossBalanceDialog")
            self._viewMgr:showView("cross.CrossBalanceDialog", result["d"]["crossPK"])
            -- self._viewMgr:showDialog("cross.CrossBalanceDialog", result["d"]["crossPK"])
        end)
    end)

    self:updateArenaScore()

    self:addTableView()

    self:refreshUI()
end


function CrossIntegralDialog:updateArenaScore()
    local arenaData = self._crossModel:getData()
    dump(arenaData)
    local setStr1 = arenaData["sec1"]
    local setStr2 = arenaData["sec2"]
    local sec = arenaData[setStr] 
    local sNameStr1 = self._crossModel:getServerName(setStr1)
    local sNameStr2 = self._crossModel:getServerName(setStr2)

    local bProgress = self:getUI("bg.barpanel.expBg.sProgress1")
    -- local sProgress2 = self:getUI("bg.barpanel.expBg.sProgress2")
    local sname1 = self:getUI("bg.barpanel.sname1")
    local sname2 = self:getUI("bg.barpanel.sname2")
    local sscore1 = self:getUI("bg.barpanel.sscore1")
    local sscore2 = self:getUI("bg.barpanel.sscore2")
    sname1:setString(sNameStr1)
    sname2:setString(sNameStr2)

    local titleLab = self:getUI("bg.server1.titleLab")
    titleLab:setString(sNameStr1)
    local titleLab = self:getUI("bg.server2.titleLab")
    titleLab:setString(sNameStr2)

    local server1 = self:getUI("bg.server1")
    UIUtils:adjustTitle(server1)
    local server2 = self:getUI("bg.server2")
    UIUtils:adjustTitle(server2)

    local sec1score = arenaData["sec1region" .. self._arenaType .. "score"] or 0
    local sec2score = arenaData["sec2region" .. self._arenaType .. "score"] or 0
    local scoreStr = "(" .. sec1score .. "分)"
    sscore1:setString(scoreStr)
    local scoreStr = "(" .. sec2score .. "分)"
    sscore2:setString(scoreStr)

    sscore1:setPositionX(sname1:getPositionX()+sname1:getContentSize().width)
    sscore2:setPositionX(sname2:getPositionX()-sname2:getContentSize().width)

    if sec1score == 0 then
        sec1score = 1
    end
    if sec2score == 0 then
        sec2score = 1
    end
    local percentStr = sec1score/(sec1score+sec2score)
    if percentStr < 0 then
        percentStr = 0
    end
    if percentStr > 1 then
        percentStr = 1
    end
    bProgress:setScaleX(percentStr)

end

function CrossIntegralDialog:progressData()
    local tableData = {}
    local tableList = self._tableList.ft
    dump(tableList)
    local serverId = 1
    local arenaData = self._crossModel:getData()
    local sec1 = tostring(arenaData.sec1)
    local sec2 = tostring(arenaData.sec2)
    for k,v in pairs(tableList) do
        local tListData = {}
        for i=1,3 do
            local indexId = tostring(i)
            tListData[i] = v[indexId]
            if tListData[i] then
                tListData[i].sec = k
            end
        end
        if k == sec1 then
            tableData[1] = tListData
        else
            tableData[2] = tListData
        end
    end
    self._tableData = tableData
end 

function CrossIntegralDialog:refreshUI()
    dump(self._tableList)
    self:progressData()

    self._tableView:reloadData()
end


--[[
用tableview实现
--]]
function CrossIntegralDialog:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    print("MAX_SCREEN_HEIGHT=============", MAX_SCREEN_HEIGHT)
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    -- self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end, cc.SCROLLVIEW_SCRIPT_SCROLL)
    
    self._tableView:setBounceable(false)
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    tableViewBg:addChild(self._tableView, 1)
end


-- 触摸时调用
function CrossIntegralDialog:tableCellTouched(table,cell)
end

-- cell的尺寸大小
function CrossIntegralDialog:cellSizeForTable(table,idx) 
    local width = 760 
    local height = 103
    return height, width
end

-- 创建在某个位置的cell
function CrossIntegralDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx+1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local rankCell = self._rankCell:clone() 
        rankCell:setVisible(true)
        rankCell:setAnchorPoint(0,0)
        rankCell:setPosition(0,0)
        rankCell:setName("rankCell")
        cell:addChild(rankCell)
        cell.rankCell = rankCell

        self:updateCell(rankCell, indexId)
        rankCell:setSwallowTouches(false)
    else
        local rankCell = cell.rankCell
        -- local rankCell = cell:getChildByName("rankCell")
        if rankCell then
            self:updateCell(rankCell, indexId)
            rankCell:setSwallowTouches(false)
        end
    end

    return cell
end

-- 返回cell的数量
function CrossIntegralDialog:numberOfCellsInTableView(table)
    return 3
end

function CrossIntegralDialog:updateCell(rankCell, indexId)
    -- local bg = rankCell:getChildByFullName("bg")
    -- if bg then
    --     bg:setAnchorPoint(0, 0)
    --     bg:setPosition(0, 0)
    --     if indexId == 0 then
    --         bg:loadTexture("asset/bg/crossbg0.jpg", 0)
    --     elseif indexId == 1 then
    --         bg:loadTexture("asset/bg/crossbg1.jpg", 0)
    --     else
    --         bg:loadTexture("asset/bg/crossbg2.jpg", 0)
    --     end
    --     bg:setScale(1136/1022)
    -- end

    -- for i=1,3 do
    --     local arena = rankCell:getChildByFullName("arena" .. i)
    --     local tindex = (indexId-1)*3+i
    --     self:updateEnemyData(arena, tindex)
    -- end

    print("indexId======", indexId)

    local bPanel = rankCell:getChildByFullName("bPanel")
    local data = self._tableData[1][indexId]
    self:updateRankCell(bPanel, data, indexId)

    local rPanel = rankCell:getChildByFullName("rPanel")
    local data = self._tableData[2][indexId]
    self:updateRankCell(rPanel, data, indexId)
end

function CrossIntegralDialog:updateRankCell(inView, data, indexId)
    -- dump(data)

    -- inView:setVisible(true)
    local rankBg = inView:getChildByFullName("rankBg")
    if rankBg then
        rankBg:loadTexture(rankImg[indexId], 1)
    end

    local pname = inView:getChildByFullName("rankBg.pname")
    local fightScore = inView:getChildByFullName("rankBg.fightScore")
    local pscore = inView:getChildByFullName("rankBg.pscore")



    local clipNode = inView.clipNode
    local mask = inView.mask
    local mc1 = inView.mc1
    if not clipNode then
        local mask = cc.Sprite:create()
        mask:setSpriteFrame("crossUI_img55.png")
        inView.mask = mask

        mc1 = cc.Sprite:create()
        mc1:setSpriteFrame("crossUI_img52.png")
        inView.mc1 = mc1

        local clipNode = cc.ClippingNode:create()
        clipNode:setInverted(false)

        clipNode:setStencil(mask)
        clipNode:setAlphaThreshold(0.8)
        clipNode:addChild(mc1)
        clipNode:setName("clipNode")
        clipNode:setAnchorPoint(cc.p(0.5,0.5))
        clipNode:setPosition(68,inView:getContentSize().height*0.5)
        clipNode:setRotation(-0.1)
        inView:addChild(clipNode,2)
        inView.clipNode = clipNode
    end

    if not data then
        pname:setString("虚位以待")
        fightScore:setString("")
        pscore:setString("")
        return
    end
    if pname then
        pname:setString(data.name)
    end
    if fightScore then
        local fightScoreStr = "战斗力:" .. data.score
        fightScore:setString(fightScoreStr)
    end
    if pscore then
        local pscoreStr = "贡献积分:" .. data.scoreA
        pscore:setString(pscoreStr)
    end

    local heroImg = inView:getChildByFullName("heroPanel.heroImg")
    local heroId = data.heroId
    local heroD = tab:Hero(heroId)
    local heroArt = heroD["herobg"]
    local skin = data["heroSkin"]
    local cpPos = heroD["cpPos"]
    if skin and skin ~= 0 then
        local heroSkinD = tab.heroSkin[skin]
        heroArt = heroSkinD["herobg"]
        cpPos = heroSkinD["cpPos"]
    end

    -- local cpPos = {0, 0, 0.8, 1}
    if mc1 then
        local fileName = "asset/uiother/hero/" .. heroArt .. ".jpg"
        mc1:setTexture(fileName)
        mc1:setPosition(cpPos[1], cpPos[2])
        mc1:setScale(0.8)
        if cpPos[4] == 1 then
            mc1:setFlippedX(true)
        end
    end

    self:registerClickEvent(inView, function()
        local param = {rank = data.rank, region = self._arenaType, aimSec = data.sec, aimId = data.rid}
        self:getDetailInfo(param, data)
    end)

    -- if heroImg then
    --     local fileName = "asset/uiother/hero/" .. heroArt .. ".jpg"
    --     heroImg:loadTexture(fileName, 0)
    --     heroImg:setVisible(false)

    --     if mc1 then
    --         mc1:setTexture(fileName)
    --     end

    --     heroImg:setScale(0.8)
    --     heroImg:setFlippedX(true)
    -- end
end

-- 玩家信息展示
function CrossIntegralDialog:getDetailInfo(param, enemyData)
    self._serverMgr:sendMsg("CrossPKServer", "getDetailInfo", param, true, {}, function(result) 
        dump(result, "result========", 4)
        local info = result["d"]["crossPK"]["defInfo"]
        info.rank = enemyData.rank
        info.rid = enemyData.rid
        info.isNotShowBtn = true
        if not info.name then
            info.name = lang("cp_npcName" .. self._arenaId)
        end
        self._viewMgr:showDialog("arena.DialogArenaUserInfo",info,true)
    end)
end


return CrossIntegralDialog