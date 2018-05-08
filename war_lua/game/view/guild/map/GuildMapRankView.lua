--[[
    Filename:    GuildMapRankView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-04-13 20:58:27
    Description: File description
--]]

local GuildMapRankView = class("GuildMapRankView", BasePopView)


function GuildMapRankView:ctor(data)
    GuildMapRankView.super.ctor(self)
end



function GuildMapRankView:onInit()
    self._rankModel = self._modelMgr:getModel("RankModel")
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("guild.map.GuildMapRankView")
            UIUtils:reloadLuaFile("guild.map.GuildMapRankCell")
            
        elseif eventType == "enter" then 
        end
    end)  
    self:registerClickEventByName("bg.bgPanel.closeBtn", function ()
        self:close()
    end)

    local title1 = self:getUI("bg.bgPanel.titlebg.title")
    UIUtils:setTitleFormat(title1, 1)

    local tab1 = self:getUI("bg.bgPanel.tab1")  --剧情
    local tab2 = self:getUI("bg.bgPanel.tab2")  --支线 

    self._rankItem = self:getUI("bg.bgPanel.rankItem")
    local txt = self._rankItem:getChildByFullName("txt")
    if txt ~= nil then 
        txt:setVisible(false)
    end
    
    self._tableCellW, self._tableCellH = self._rankItem:getContentSize().width - 14 , self._rankItem:getContentSize().height
    self._btnList = {}
    table.insert(self._btnList, tab1)
    table.insert(self._btnList, tab2) 
    for k,v in pairs(self._btnList) do
        v:setTitleFontName(UIUtils.ttfName)
        v:setTitleFontSize(28)
        local text = v:getTitleRenderer()
        v:setTitleColor(UIUtils.colorTable.ccUITabColor1)
        text:disableEffect()   
    end

    UIUtils:setTabChangeAnimEnable(tab1,-36,function( ) self:tabButtonClick(tab1) end)
    UIUtils:setTabChangeAnimEnable(tab2,-36,function( ) self:tabButtonClick(tab2) end)

    self._noRankBg = self:getUI("bg.bgPanel.noRankBg")
    self._titleBg1 = self:getUI("bg.bgPanel.titleBg1")

    self._tableNode = self:getUI("bg.bgPanel.tableNode")

    local tableBg = self:getUI("bg.bgPanel.tableNode")
    self._tableView = cc.TableView:create(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 50))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setPosition(cc.p(5,6))
    self._tableView:setDelegate()
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    -- self._tableView:setBounceEnabled(false)
    tableBg:addChild(self._tableView,999)
    self._tableView:registerScriptHandler(function ( table,cell )
        return self:tableCellTouched(table,cell)
    end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function( table,index )
        return self:cellSizeForTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function ( table,index )
        return self:tableCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function ( table )
        return self:numberOfCellsInTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    
end



function GuildMapRankView:reflashUI(inData)
    local tab1 = self:getUI("bg.bgPanel.tab1")
    self:tabButtonClick(tab1)
end

function GuildMapRankView:tabButtonClick(sender)
    self._rankModel:clearRankList()
    self:reflashNoRankUI()
    self:reflashUserInfo(true)
    if sender == nil then
        return
    end
    audioMgr:playSound("Tab")
    if self._tableView then
        self._tableView:stopScroll()
    end    


    for k,v in pairs(self._btnList) do
        if v ~= sender then 
            local text = v:getTitleRenderer()
            text:disableEffect()
            v:setTitleColor(UIUtils.colorTable.ccUITabColor1)
            v:setScaleAnim(false)
            v:stopAllActions()

            v:setBright(true)
            v:setEnabled(true)
        end
    end
    if self._preBtn then
        UIUtils:tabChangeAnim(self._preBtn,nil,true,true)
    end
    self._preBtn = tabBtn 
    self._curChannel = sender:getName()
    UIUtils:tabChangeAnim(sender,function( )
        local text = sender:getTitleRenderer()
        text:disableEffect()
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor2)
        sender:setBright(false)
        sender:setEnabled(false)
    end)
    ScheduleMgr:delayCall(0, self, function ()
        if sender:getName()== "tab1" then 
            self:showUserInfo(14)
        else
            self:showUserInfo(13)
        end
    end)
end

function GuildMapRankView:reflashNoRankUI()
    if (not self._tableData or #self._tableData <= 0) then
        self._noRankBg:setVisible(true)
        self._tableNode:setVisible(false)
        self._titleBg1:setVisible(false)
    else
        self._noRankBg:setVisible(false)
        self._tableNode:setVisible(true)
        self._titleBg1:setVisible(true)
    end
end



function GuildMapRankView:cellSizeForTable(table,idx) 
    return self._tableCellH + 5, self._tableCellW
end

-- 创建在某个位置的cell
function GuildMapRankView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        local rankCell = self._rankItem:clone()
        rankCell:setContentSize(self._tableCellW,self._tableCellH)
        cell = require("game.view.guild.map.GuildMapRankCell").new(rankCell)
    end
    cell:reflashUI(self._tableData[idx + 1])
    return cell
end
function GuildMapRankView:numberOfCellsInTableView(table)

    return #self._tableData
    
end


function GuildMapRankView:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
    local curlUser = self._tableData[cell:getIdx() + 1]
    self:selfItemClicked(curlUser)  
end




function GuildMapRankView:showUserInfo(inType)
    local title4 = self:getUI("bg.bgPanel.titleBg1.title4")

    self._rankType = inType

    local rankData = self._rankModel:getRankList(inType)
    if rankData ~= nil and next(rankData) ~= nil then
        self._tableData = rankData
        self._tableView:reloadData()
        self:reflashUserInfo()
        self:reflashNoRankUI()
        return
    end
    


    self._rankModel:setRankTypeAndStartNum(inType, 1)
    self._serverMgr:sendMsg("RankServer", "getRankList", {type = inType, startRank = 1}, true, {}, function(result)

        if result == nil then 
            self:reflashNoRankUI()
            return 
        end
        if self._rankType == 13 then 
            title4:setString("击败玩家数量")
        else
            title4:setString("累积获得钻石")
        end
        print("test======")
        self._tableData = self._rankModel:getRankList(inType) or {}
        self._tableView:reloadData()

        self:reflashUserInfo()
        self:reflashNoRankUI()        
    end)
end


local rankImgs = {"firstImg","secondImg","thirdImg"}
function GuildMapRankView:reflashUserInfo(isInit)
    local item  = self._rankItem
    local nameLab = item:getChildByFullName("nameLab")
    -- nameLab:setColor(cc.c4b(255,255,255,255))
    local guildNameLab = item:getChildByFullName("guildNameLab")
    -- levelLab:setColor(cc.c4b(255,255,255,255))
    local UIscoreLab = item:getChildByFullName("scoreLab")
    nameLab:setString("")
    guildNameLab:setString("")
    UIscoreLab:setString("")

    -- UIscoreLab:setColor(cc.c4b(255,255,255,255))

    local rankData = self._rankModel:getSelfRankInfo(self._rankType)
    if not rankData then print("no rankInfo....",self._rankType) return end
    local rank = rankData.rank

    local rankLab = item:getChildByName("rankLab")
    if not rankLab then
        rankLab = cc.LabelBMFont:create("4", UIUtils.bmfName_rank)
        rankLab:setAnchorPoint(cc.p(0.5,0.5))
        rankLab:setPosition(60, 50)
        rankLab:setName("rankLab")
        item:addChild(rankLab, 1)
    end
    rankLab:setScale(0.9)
    for i=1,3 do
        local rankImg = item:getChildByFullName(rankImgs[tonumber(i)])
        rankImg:setVisible(false)
    end
    if rank then  
        rankLab:setString(rank)     
        -- item:loadTexture("arenaRankUI_cellBg5.png",1) --自己板子
        if rankImgs[tonumber(rank)] then
            rankLab:setVisible(false)
            local rankImg = item:getChildByFullName(rankImgs[tonumber(rank)])
            rankImg:setVisible(true)
        else
            rankLab:setVisible(true)
            if rank >= 999 then
                rankLab:setScale(0.7)
            end
            rankLab:setPosition(70,50)
        end
    end
    
    local txt = item:getChildByFullName("txt")
    if not txt then
        txt = ccui.Text:create()
        txt:setName("txt")
        txt:setString("暂未上榜")
        txt:setFontSize(22)
        txt:setPosition(70, 40)
        txt:setFontName(UIUtils.ttfName)
        txt:setColor(cc.c4b(70,40,0,255))
        -- txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        item:addChild(txt)
    end
    txt:setVisible(false)
    
    -- 没有排名或者大于一万 显示暂未上榜
    if not rank or rank > 9999 or rank == 0 or rank == "" then
        rankLab:setVisible(false)
        print("isInit=================", isInit)
        if isInit ~= true then
            txt:setVisible(true)
        end
    end 

    local userData = self._modelMgr:getModel("UserModel"):getData()
    nameLab:setString(userData.name)
    guildNameLab:setString(userData.guildName)
    UIscoreLab:setString(rankData.score or "")
    rankData._id = userData._id
    self:registerClickEvent(item,function( )
        -- print("==========*********************")
        self:selfItemClicked(rankData)          
       
    end)

end

function GuildMapRankView:selfItemClicked(curlUser)
    local formationModel = self._modelMgr:getModel("FormationModel")
    self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", {tagId = curlUser._id, fid= formationModel.kFormationTypeGuildDef}, true, {}, function(result) 
        local data = result
        data.rank = curlUser.rank
        data.usid = curlUser.usid
        -- data.isNotShowBtn = true
        self._viewMgr:showDialog("arena.DialogArenaUserInfo",data,true)
    end)  
end

return GuildMapRankView