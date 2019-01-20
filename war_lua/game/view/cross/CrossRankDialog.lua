--[[
    Filename:    CrossRankDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-11-23 11:28:32
    Description: File description
--]]


local CrossRankDialog = class("CrossRankDialog", BasePopView)

local rankImg = {
    [1] = "arenaRank_first.png",
    [2] = "arenaRank_second.png",
    [3] = "arenaRank_third.png",
}

local itemImg = {
    [40010] = "globalImageUI_kuafuCoinmin.png",
    [30203] = "globalImageUI_texp.png",
    [907016] = "i_907016.png",
    [41001] = "allicance_redziyuan3.png",
}

function CrossRankDialog:ctor(param)
    self.super.ctor(self)
    self.initAnimType = 1
    param = param or {}
    self._arenaType = param.arenaType
    self._crossModel = self._modelMgr:getModel("CrossModel")
    -- self._arenaType = tonumber(param.rankType) or 11   --英雄争锋排行榜
end

-- 第一次被加到父节点时候调用
function CrossRankDialog:onBeforeAdd(callback, errorCallback)
    if self._arenaType then
        local curStart = self._crossModel:getRankNextStart()
        self:sendGetRankMsg(self._arenaType,curStart,function (_error)
            if _error then
                errorCallback()
                return
            end
            callback()
        end)
    else
        callback()
    end
end
-- 初始化UI后会调用, 有需要请覆盖
function CrossRankDialog:onInit()
    self._itemData = nil
    self._leftBoard = self:getUI("bg.leftBoard")
    -- self._noRankBg = self:getUI("bg.bgPanel.noRankBg")
    -- self._noRankBg:setVisible(false)
    self._titleBg = self:getUI("bg.titleBg")
    self._titleBg:getChildByFullName("title1"):setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    self._titleBg:getChildByFullName("title2"):setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    self._titleBg:getChildByFullName("title3"):setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    self._titleBg:getChildByFullName("title4"):setColor(UIUtils.colorTable.ccUIBaseTextColor1)

    self:registerClickEventByName("bg.closeBtn", function ()
        self._crossModel:clearRankList()
        self:close()
        UIUtils:reloadLuaFile("cross.CrossRankDialog")
    end)

    local arenaData = self._crossModel:getData()
    self._arenaId = arenaData["regiontype" .. self._arenaType]
    -- local arenaData = self._crossModel:getData()
    -- dump(arenaData)
    -- self._arenaId = arenaData["regiontype" .. ]
    

    -- self._tableNode = self:getUI("bg.bgPanel.tableNode")

    self._selfItem = self:getUI("bg.rankItem")
    self._selfAward = self:getUI("bg.selfAward")
    

    self._rankItem = self:getUI("rankItem")
    self._rankItem:setVisible(false)
    -- self._rankItem:setVisible(false)

    self._tableNode = self:getUI("bg.tableViewBg")
    self._tableCellW,self._tableCellH = self._rankItem:getContentSize().width,self._rankItem:getContentSize().height

    -- self._tableData = {}
    -- self._allRankData = {}
    -- -- 递进刷新控制
    local flashData = tab:Setting("G_RANK_DUEL_SHOW").value
    self.beginIdx = tonumber(flashData[1]) or 20
    self.addStep = tonumber(flashData[1]) or 20
    self.endIdx = tonumber(flashData[2]) or 500

    -- self._offsetX = nil
    -- self._offsetY = nil
    -- self._tableView = nil


    self:addTableView()

    -- 暂时不做监听刷新
    -- self:listenReflash("RankModel", self.reflashUI)
end


-- 接收自定义消息
function CrossRankDialog:reflashUI(data)
    -- local curRankData = self._crossModel:getRankList()

    local offsetX = nil
    local offsetY = nil
    if self._offsetX and self._offsetY then
        offsetX = self._offsetX
        offsetY = self._offsetY
    end
    self._allRankData = self._crossModel:getRankList(self._rankType)

    -- dump(self._allRankData)
    self._tableData = self:updateTableData(self._allRankData,self.beginIdx)
    -- self._tableData = self._crossModel:getRankList() or {}
    -- print("************&&&&&&&&&&&&-----------",#self._tableData)
    if self._tableData and self._tableView then     
        self._tableView:reloadData()
        if offsetX and offsetY and not self._firstIn then
            -- print("=========================",offsetX,offsetY)
            self._tableView:setContentOffset(cc.p(offsetX,offsetY))
            self._canRequest = false
        end     
        self._firstIn = false
    end

    -- local noneNode = self:getUI("bg.noneNode")
    -- if table.nums(self._tableData) ~= 0 then
    --     noneNode:setVisible(false)
    -- else
    --     noneNode:setVisible(true)
    -- end 
    if #self._tableData > 0 then
        self:reflashUserInfo()
    end
    if self._tableData then
        self:reflashNo1(self._tableData[1])
    end

    -- dump(self._tableData)
end

--刷心排行榜后显示的数据
function CrossRankDialog:updateTableData(rankList,index)
    -- print("*************************",index)
    local data = {}
    for k,v in pairs(rankList) do
        if tonumber(v.rank) <= tonumber(index) then
            data[k] = v
        end
    end
    return data
end

--[[
用tableview实现
--]]
function CrossRankDialog:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height-50))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(0, 5)
    self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end, cc.SCROLLVIEW_SCRIPT_SCROLL)
    
    self._tableView:setBounceable(true)
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    tableViewBg:addChild(self._tableView, 1)
end


-- 触摸时调用
function CrossRankDialog:tableCellTouched(table,cell)
end

-- cell的尺寸大小
function CrossRankDialog:cellSizeForTable(table,idx) 
    local width = 625 
    local height = 94
    return height, width
end

-- 创建在某个位置的cell
function CrossRankDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx+1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local rankItem = self._rankItem:clone() 
        rankItem:setVisible(true)
        rankItem:setAnchorPoint(0,0)
        rankItem:setPosition(8,2)
        rankItem:setName("rankItem")
        cell:addChild(rankItem)
        cell.rankItem = rankItem

        -- local zhandouliLab = cc.LabelBMFont:create("a100", UIUtils.bmfName_zhandouli_little)
        -- zhandouliLab:setName("zhandouli")
        -- zhandouliLab:setScale(0.5)
        -- zhandouliLab:setAnchorPoint(0,0.5)
        -- zhandouliLab:setPosition(200, 50)
        -- rankItem:addChild(zhandouliLab, 1000)
        -- rankItem.zhandouliLab = zhandouliLab
        self:updateCell(rankItem, indexId)
        rankItem:setSwallowTouches(false)
    else
        local rankItem = cell.rankItem
        -- local rankItem = cell:getChildByName("rankItem")
        if rankItem then
            self:updateCell(rankItem, indexId)
            rankItem:setSwallowTouches(false)
        end
    end

    return cell
end

-- 返回cell的数量
function CrossRankDialog:numberOfCellsInTableView(table)
    return #self._tableData
end

function CrossRankDialog:updateCell(inView, indexId)
    local data = self._tableData[indexId]
    if not data then
        return
    end

    local secServer = data.sec
    local cpTab = tab:CpRegionSwitch(self._arenaId)
    local nameStr = lang(cpTab.npcName)
    local serverName = lang(cpTab.npcRegion)
    if secServer ~= "npcsec" then
        nameStr = data.name
        serverName = self._crossModel:getServerName(secServer)
    end

    local pname = inView:getChildByFullName("nameLab")
    if pname then
        pname:setString(nameStr)
    end

    local snameLab = inView:getChildByFullName("snameLab")
    if snameLab then
        snameLab:setString(serverName)
    end

    local scoreLab = inView:getChildByFullName("scoreLab")
    if scoreLab then
        local scoreStr = data.score
        scoreLab:setString(scoreStr)
    end

    local iconBg = inView:getChildByFullName("headNode")
    if iconBg then
        local param1 = {avatar = data.avatar, tp = 4,avatarFrame = data["avatarFrame"], level = data.lv, plvl = data.plvl}
        local icon = iconBg:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(param1)
            icon:setScale(0.75)
            icon:setName("icon")
            icon:setPosition(-20, -30)
            iconBg:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param1)
        end

        self:registerClickEvent(icon, function()
            local param = {region = self._arenaType, aimSec = data.sec, aimId = data.rid, rank = data.rank}
            self:getDetailInfo(param, data)
            -- dump(data)
        end)
    end

    local firstImg = inView:getChildByFullName("firstImg")
    local rankLab = inView:getChildByFullName("rankLab")
    local rank = data.rank
    if rank == 1 or rank == 2 or rank == 3 then
        firstImg:setVisible(true)
        rankLab:setVisible(false)
        firstImg:loadTexture(rankImg[rank], 1)
    else
        rankLab:setVisible(true)
        firstImg:setVisible(false)
        rankLab:setString(rank)
    end
end


-- local rankImgs = {"firstImg","secondImg","thirdImg"}
function CrossRankDialog:reflashUserInfo()
    local item = self._selfItem
    local selfAward = self._selfAward
    local rankData = self._crossModel:getSelfRankInfo()
    local rankLab = item:getChildByFullName("rankLab")

    local myData = self._crossModel:getMyInfo()
    local playRankStr = myData["rank" .. self._arenaType]
    -- local playScoreStr = myData["score" .. self._arenaType]

    local tRank = playRankStr
    local hourId = 1
    local cpServerScoreTab = tab.cpRankReward
    for i,v in ipairs(cpServerScoreTab) do
        local rankTab = v.pos
        if tRank >= rankTab[1] and tRank <= rankTab[2] then
            hourId = i
            break
        end
    end

    local rankAwardTab = tab.cpRankReward[hourId]
    local award = rankAwardTab["reward" .. self._arenaType]
    for i=1,2 do
        local awardImg = selfAward:getChildByFullName("awardImg" .. i)
        local awardTxt = selfAward:getChildByFullName("awardTxt" .. i)
        local _award = award[i]
        if _award then
            local itemType = _award[1]
            local itemId = _award[2]
            if IconUtils.iconIdMap[itemType] then
                itemId = IconUtils.iconIdMap[itemType]
            end
            local itemNum = _award[3]
            local failName = IconUtils.resImgMap[itemType]
            if itemType == "tool" then
                local toolD = tab:Tool(itemId)
                failName = toolD.art .. ".png"
            end
            awardImg:loadTexture(failName, 1)
            awardTxt:setString(itemNum)
        end
    end

    rankLab:setString(playRankStr)

    local ruleBtn = selfAward:getChildByFullName("ruleBtn")
    ruleBtn:setVisible(false)
    self:registerClickEvent(ruleBtn, function()
        self:searchForPosition(20,20,100)
    end)
    
    -- local nameLab = item:getChildByFullName("nameLab")
    -- nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- local winLab = item:getChildByFullName("winLab")
    -- winLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- local UIscoreLab = item:getChildByFullName("scoreLab")
    -- UIscoreLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    -- local rank = rankData.rank
    -- local rankLab = item:getChildByName("rankLab")
    -- if not rankLab then
    --     rankLab = cc.LabelBMFont:create("4", UIUtils.bmfName_rank)
    --     rankLab:setAnchorPoint(cc.p(0.5,0.5))
    --     rankLab:setPosition(70, 50)
    --     rankLab:setName("rankLab")
    --     item:addChild(rankLab, 1)
    -- end
    -- rankLab:setScale(0.9)
    -- -- --玩家名称
    -- -- local userData = self._modelMgr:getModel("UserModel"):getData()
    -- -- nameLab:setString(userData.name)

    -- -- --联盟label
    -- -- local winTimes = (rankData.i1 or "") .. "胜" .. (rankData.i2 or "") .. "次"
    -- -- winLab:setVisible(true)
    -- -- if rankData.rank ~= 0 then 
    -- --     winLab:setString(winTimes)
    -- -- else 
    -- --     winLab:setString("未入榜")     --联盟击杀排行榜一般不会出现这种情况
    -- -- end

    -- -- --得分label
    -- -- UIscoreLab:setString(rankData.i3 or "")

    -- for i=1,3 do
    --     local rankImg = item:getChildByFullName(rankImgs[tonumber(i)])
    --     rankImg:setVisible(false)
    -- end
    -- if rank then  
    --     rankLab:setString(rank)
    --     if rankImgs[tonumber(rank)] then
    --         rankLab:setVisible(false)
    --         local rankImg = item:getChildByFullName(rankImgs[tonumber(rank)])
    --         rankImg:setVisible(true)
    --     else
    --         if rank > 999 then
    --             rankLab:setScale(0.7)
    --         end
    --         rankLab:setVisible(true)
    --     end
    -- end
    -- local txt  = item:getChildByFullName("rankTxt")
    -- if txt then
    --     txt:setVisible(false)
    --     txt:removeFromParent()
    -- end
    -- if not rank or rank > 9999 or rank == 0 or rank == "" then
    --     rankLab:setVisible(false)   

    --     local txt = ccui.Text:create()
    --     txt:setName("rankTxt")
    --     txt:setString("暂未上榜")
    --     txt:setFontSize(30)
    --     txt:setPosition(rankLab:getPositionX(), rankLab:getPositionY() - 10)
    --     txt:setFontName(UIUtils.ttfName)
    --     txt:setColor(UIUtils.colorTable.ccUIBaseColor1)
    --     txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    --     item:addChild(txt)      
    -- end

    self:registerClickEvent(item,function()
        -- dump(rankData)
        -- self:selfItemClicked(rankData)          
       self:searchForPosition(20,20,100)
    end)

end

function CrossRankDialog:reflashNo1(data)
    local name = self._leftBoard:getChildByFullName("name")
    local level = self._leftBoard:getChildByFullName("level")
    local guild = self._leftBoard:getChildByFullName("guild")
    local guildDes = self._leftBoard:getChildByFullName("guildDes")
--    local detailBtn = self._leftBoard:getChildByFullName("showDetail")
--    detailBtn:setVisible(false)
    name:setString("暂无榜首")
    level:setString("") 
    guild:setString("")
    guildDes:setString("")

    if not data then return end
--    detailBtn:setVisible(true)
    local secServer = data.sec
    local cpTab = tab:CpRegionSwitch(self._arenaId)
    local nameStr = lang(cpTab.npcName)
    local serverName = lang(cpTab.nameRegion)
    if secServer ~= "npcsec" then
        nameStr = data.name
        serverName = self._crossModel:getServerName(secServer)
    end

    local name = self._leftBoard:getChildByFullName("name")
    name:setString(nameStr)
    local level = self._leftBoard:getChildByFullName("level")
    level:setString("Lv." .. (data.lv or 0))
    guildDes:setString(serverName)

    local avatarIcon = self._leftBoard:getChildByFullName("avatarIcon")
    if avatarIcon then
        avatarIcon:setVisible(false)
        avatarIcon:removeFromParent()
    end
    
    local roleAnim = self._leftBoard._roleAnim
    if roleAnim then
        roleAnim:setVisible(false)
        roleAnim:removeFromParent()
    end
    -- 左侧人物形象
    local heroId = data.fHeroId  or 60001
    local heroD = tab:Hero(heroId)
    local heroArt = heroD["heroart"]
    if data.heroSkin then
        local heroSkinD = tab.heroSkin[data.heroSkin]
        heroArt = (heroSkinD and heroSkinD["heroart"]) and heroSkinD["heroart"] or heroD["heroart"]
    end
    local sp = mcMgr:createViewMC("stop_" .. heroArt, true)
    sp:setScale(0.8)
    sp:setAnchorPoint(0.5,0)
    sp:setPosition(self._leftBoard:getContentSize().width*0.5,220)
    self._leftBoard._roleAnim = sp
    self._leftBoard:addChild(sp,1)
    
    self:registerClickEventByName("bg.bgPanel.leftBoard",function( )
        self:itemClicked(data)
    end)
end

function CrossRankDialog:createLoadingMc()
    if self._loadingMc then return end
    -- 添加加载中动画
    self._loadingMc = mcMgr:createViewMC("jiazaizhong_rankjiazaizhong", true, false, function (_, sender)      end)
    self._loadingMc:setName("loadingMc")
    self._loadingMc:setPosition(cc.p(self._tableNode:getContentSize().width*0.5 - 30, self._tableView:getPositionY() + 20))
    self._tableNode:addChild(self._loadingMc, 1000)
    self._loadingMc:setVisible(false)
end

function CrossRankDialog:scrollViewDidScroll(view)
    self._inScrolling = view:isDragging()

    local offsetY = view:getContentOffset().y       
    if offsetY >= 100 and #self._tableData > 5 and #self._tableData < self.endIdx and not self._canRequest then
        self._canRequest = true
        self:createLoadingMc()
        if not self._loadingMc:isVisible() then
            self._loadingMc:setVisible(true)
        end
    end 
        
    local condY = 0
    if self._tableData and #self._tableData < 4 then
        -- tableView height 330
        condY = self._tableViewH - #self._tableData*(self._tableCellH+5)
    end
    if self._inScrolling then
        if offsetY >= condY+100 and not self._canRequest then
            self._canRequest = true         
            self:createLoadingMc()            
            if not self._loadingMc:isVisible() then
                self._loadingMc:setVisible(true)
            end
        end
        if offsetY < condY+20 and self._canRequest then
            self._canRequest = false
            self:createLoadingMc() 
            if self._loadingMc:isVisible() then
                self._loadingMc:setVisible(false)
            end 
        end
    else
        -- 满足请求更多数据条件
        if self._canRequest and offsetY == condY then       
            self._viewMgr:lock(1)
            self:sendMessageAgain()
            if self._loadingMc:isVisible() then
                self._loadingMc:setVisible(false)
            end     
        end
    end
end

-- function CrossRankDialog:reflashNoRankUI()
--     if (not self._tableData or #self._tableData <= 0) then
        
--         self._noRankBg:setVisible(true)
--         self._selfItem:setVisible(false)
--         self._tableNode:setVisible(false)
--         self._titleBg:setVisible(false)
--         -- self._norankFlag = UIUtils:addBlankPrompt( self._noRankBg,{scale = 0.7,x=165,y=245,des="排行榜还没有整理完成哦~"} )
--     else
--         -- if self._norankFlag then
--         --  self._norankFlag:removeFromParent()
--         --  self._norankFlag = nil
--         -- end
--         self._noRankBg:setVisible(false)
--         self._selfItem:setVisible(true)
--         self._tableNode:setVisible(true)
--         self._titleBg:setVisible(true)
--     end
-- end

--是否要刷新排行榜
function CrossRankDialog:sendMessageAgain()
    -- self.beginIdx -- self.endIdx -- self.addStep
    self._allRankData = self._crossModel:getRankList(self._arenaType)
    local starNum = self._crossModel:getRankNextStart(self._arenaType)
    local statCount = tonumber(self.beginIdx)
    local endCount = 100
    local addCount = tonumber(self.addStep)

    if #self._tableData == #self._allRankData and #self._allRankData%addCount == 0 and #self._allRankData < endCount then
        --如果本地没有更多数据则向服务器请求
        self:sendGetRankMsg(self._arenaType,starNum,function()
            if #self._allRankData > statCount then
                self:searchForPosition(statCount,addCount,endCount)
            end
            self._viewMgr:unlock()
        end)
    else
        self._canRequest = false
        self._viewMgr:unlock()
    end
end
--刷新之后tableView 的定位
function CrossRankDialog:searchForPosition(statCount,addCount,endCount)   
    print("statCount==============", statCount,addCount,endCount) 
    self._offsetX = 0
    if statCount + addCount <= endCount then
        self.beginIdx = statCount + addCount
        local subNum = #self._allRankData - statCount
        print("statCount==============", subNum,addCount) 
        if subNum < addCount then
            self._offsetY = -1 * (tonumber(subNum) * (self._tableCellH+5))          
        else
            self._offsetY = -1 * (tonumber(self.addStep) * (self._tableCellH+5))            
        end
        
    else
        self.beginIdx = endCount
        self._offsetY = -1 * (endCount - statCount) * (self._tableCellH+5)
    end
end
--获取当前排行榜数据
function CrossRankDialog:sendGetRankMsg(tp,start,callback)
    self._crossModel:setRankTypeAndStartNum(tp,start)
    self._serverMgr:sendMsg("CrossPKServer", "getRankList", {region=self._arenaType, start = start}, true, {}, function(result) 
        if callback then
            callback()
        end
        self:reflashUI()
        -- self:reflashNoRankUI()
    end)
end


-- 玩家信息展示
function CrossRankDialog:getDetailInfo(param, enemyData)
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

function CrossRankDialog.dtor()
    itemImg = nil  
    rankImg = nil 
end

return CrossRankDialog
