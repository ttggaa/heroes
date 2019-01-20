--[[
    Filename:    LeagueBattleReport.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2016-07-08 11:53:25
    Description: File description
--]]

local LeagueBattleReport = class("LeagueBattleReport",BasePopView)
function LeagueBattleReport:ctor()
    self.super.ctor(self)

end

-- 第一次被加到父节点时候调用
function LeagueBattleReport:onAdd()

end
-- 初始化UI后会调用, 有需要请覆盖
function LeagueBattleReport:onInit()
	self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("league.LeagueBattleReport")
    end)
    self._title = self:getUI("bg.headBg.title")
    UIUtils:setTitleFormat(self._title,4)
    -- self._title:setFontName(UIUtils.ttfName)
    -- self._title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    -- self._title:setColor(cc.c3b(250, 242, 192))
    -- self._title:enable2Color(1,cc.c4b(255, 195, 20,255))
    self._tableBg = self:getUI("bg.tableBg")
    -- self._scrollViewH = self._scrollView:getContentSize().height
    self._noReportImg = self:getUI("bg.noReportImg")

    self._scrollItem = self:getUI("bg.scrollItem")
    self._scrollItem:setVisible(false)
    self._itemW,self._itemH = self._scrollItem:getContentSize().width,self._scrollItem:getContentSize().height
    self:listenReflash("LeagueModel",self.reflashUI)
    self._tableData = {}
    self:addTableView()
end

function LeagueBattleReport:reflashLeftBoard( )
    local leagueD = self._modelMgr:getModel("LeagueModel"):getData()

    local allbattleCount = self._modelMgr:getModel("LeagueModel"):getBattleCount()
    local numSetting = {
        leagueD.league.currentPoint,
        lang(tab:LeagueRank(leagueD.league.currentZone).name),-- leagueD.rank,
        allbattleCount,
        leagueD.league.win or 0,
        (leagueD.league.lose or 0),
        ( allbattleCount~=0 and string.format("%d",(leagueD.league.win or 0)/allbattleCount*100) or 0) .. "%",
    }
    for i=1,6 do
        local numLab = self:getUI("bg.leftBoard.num" .. i)
        numLab:setString(numSetting[i])
    end
end

-- 接收自定义消息
function LeagueBattleReport:reflashUI(data)
	local reports = self._modelMgr:getModel("LeagueModel"):getLeagueReport().list
	local playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
	-- if playerTodayModel:getBubble().b1 and playerTodayModel:getBubble().b1 > 0 then
	-- 	playerTodayModel:updateBubble({b1=0})
	-- end
	if reports and #reports > 0 then
        self._tableData = reports 
        if self._tableView then
            self._tableView:reloadData()
        end
		-- local viewHeight = math.max(self._scrollViewH,#reports*self._itemH)
		-- self._scrollView:setInnerContainerSize(cc.size(self._itemW,viewHeight))
		-- local x,y = 0,0
		-- local offsetX,offsetY = 15,-5
		-- for k,v in pairs(reports) do
		-- 	x = offsetX
		-- 	y = viewHeight-k*self._itemH+offsetY
		-- 	self:createItem(v,x,y)
		-- end
	end
    self._noReportImg:setVisible(not (reports and #reports > 0))

    self:reflashLeftBoard()
end

function LeagueBattleReport:addTableView( )
    local tableView = cc.TableView:create(cc.size(625, 465))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(13,10))
    tableView:setAnchorPoint(cc.p(0,0))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._tableBg:addChild(tableView)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(function ( table,cell )
        return self:tableCellTouched(table,cell)
    end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( table,index )
        return self:cellSizeForTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index )
        return self:tableCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table )
        return self:numberOfCellsInTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    self._tableView = tableView
end

function LeagueBattleReport:scrollViewDidScroll(view)
    -- print("scrollViewDidScroll")
end

function LeagueBattleReport:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function LeagueBattleReport:tableCellTouched(table,cell)
    -- print("cell touched at index: " .. cell:getIdx())
end

function LeagueBattleReport:cellSizeForTable(table,idx) 
    return 103,638
end

function LeagueBattleReport:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end

    local item = self:createItem(self._tableData[idx+1])
    item:setPosition(cc.p(-5,0))    
    item:setSwallowTouches(false)
    cell:addChild(item)

    return cell
end

function LeagueBattleReport:numberOfCellsInTableView(table)
   return #self._tableData
end

function LeagueBattleReport:createItem( data,x,y )
    -- dump(data)
	local item = self._scrollItem:clone()
	item:setVisible(true)
    item:setAnchorPoint(cc.p(0,0))
	-- item:setPosition(cc.p(x,y))
	-- self._scrollView:addChild(item)

	local winImg = item:getChildByFullName("winImg")
	local failImg = item:getChildByFullName("failImg")
    local level = item:getChildByFullName("level")
    level:enableOutline(cc.c4b(0,0,0,255),1)
    local itemNode = item:getChildByFullName("itemNode")
    local itemName = item:getChildByFullName("itemName")
    itemName:setFontName(UIUtils.ttfName)
    local timeLab = item:getChildByFullName("time")
    local rank = item:getChildByFullName("rank")
    -- local upImg = item:getChildByFullName("upImg")
    -- local downImg = item:getChildByFullName("downImg")
	local upImg = item:getChildByFullName("upImg")
    upImg:setVisible(false)
	local downImg = item:getChildByFullName("downImg")
    downImg:setVisible(false)
    local drawImg = item:getChildByFullName("drawImg")
    drawImg:setVisible(false)
    
    local atkId = data.atkId
    local defId = data.defId
    local userId = self._modelMgr:getModel("UserModel"):getUID()
    local isDef = true
    local prefix = "atk"
    if atkId == userId then
        prefix = "def"
    else
         prefix = "atk"
    end
    -- print("atkId,defId,userId",atkId,defId,userId)
    local win = data.win


    -- 判断胜负
    local isMeAtk = userId == atkId
    local isWin = false
    if (win == 1 and userId == atkId) or (win == 0 and userId == defId) then
        winImg:setVisible(true)
        failImg:setVisible(false)
        isWin = true
    else
        winImg:setVisible(false)
        failImg:setVisible(true)
    end
    if win == 2 then
        winImg:setVisible(true)
        winImg:loadTexture("globalImageUi_battleResult_ping.png",1)
        failImg:setVisible(false)
    end
    -- 判断积分是否变化
    local upZone = data.zone 
    local zoneChangeImg = item:getChildByFullName("zoneChangeImg")
    local offsetX = 0
    if upZone and upZone ~= 0 then
        zoneChangeImg:setVisible(true)
        if upZone > 0 then
            zoneChangeImg:loadTexture("zoneUp_league.png",1)
        else
            zoneChangeImg:loadTexture("zoneDwon_league.png",1)
        end
    else
        zoneChangeImg:setVisible(false)
        offsetX = 0-- 40
    end
    local addPoint = data.point 
    if addPoint then
        if addPoint == 0 then
           drawImg:setVisible(true)
           drawImg:setPositionX(200+offsetX)
        elseif addPoint > 0 then
            upImg:setVisible(true)
            upImg:setPositionX(200+offsetX)
            local diff = upImg:getChildByFullName("diff")
            diff:enableOutline(cc.c4b(42,66,16,255),1)
            diff:setFontName(UIUtils.ttfName)
            upImg:setVisible(true)
            diff:setString("")
            -- diff:enableOutline(cc.c4b(0,78,0,255),1.5)
            local diffNum = diff:clone()
            diffNum:setString(math.abs(addPoint))
            diffNum:setPosition(cc.p(diff:getContentSize().width+2,diff:getContentSize().height/2-2))
            diffNum:enableOutline(cc.c4b(42,66,16,255),1)
            diff:addChild(diffNum,99)
        else
            downImg:setVisible(true)
            downImg:setPositionX(200+offsetX)
            local diff = downImg:getChildByFullName("diff")
            diff:enableOutline(cc.c4b(48,13,13,255),1)
            diff:setFontName(UIUtils.ttfName)
            downImg:setVisible(true)
            diff:setString("")
            -- diff:enableOutline(cc.c4b(0,78,0,255),1.5)
            local diffNum = diff:clone()
            diffNum:setString(math.abs(addPoint))
            diffNum:setPosition(cc.p(diff:getContentSize().width+2,diff:getContentSize().height/2-2))
            -- diff:enableOutline(cc.c4b(0,78,0,255),1.5)
            diffNum:enableOutline(cc.c4b(48,13,13,255),1)
            diff:addChild(diffNum,99)
        end
    end

	local lv = data[prefix .. "Lvl"]
    local plvl = data[prefix .. "Plvl"]
	local name = data[prefix .. "Name"]
	local avatar = data[prefix .. "Avatar"]
	local time = data.time
    
	level:setString("")
    level:setVisible(false)
	itemName:setString(name or "avatar")
	if not avatar or avatar==0 then--safecode toberemove
	   avatar = 1203--safecode toberemove
	end--safecode toberemove
	-- local avatarName = tab:RoleAvatar(avatar).icon
	-- local icon = ccui.ImageView:create()
    local icon = IconUtils:createHeadIconById({avatar = avatar,level = lv or "0" ,tp = 4,avatarFrame=data[prefix .. "AvatarFrame"], plvl = plvl}) 
	-- icon:loadTexture(avatarName,1)
	icon:setAnchorPoint(cc.p(0,0))
    icon:setPosition(cc.p(0,-6))
	-- icon:setPosition(cc.p(itemNode:getContentSize().width/2,itemNode:getContentSize().height/2))
	itemNode:addChild(icon)
    itemNode:setSwallowTouches(false)
	local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
	local deltTime = curTime - time
	local timeStr = ""
	if math.floor(deltTime/86400) > 0 then
		timeStr = math.floor(deltTime/86400) .. "天前"
	elseif math.floor(deltTime/3600) > 0 then
		timeStr = math.floor(deltTime/3600) .. "小时前"
	elseif math.floor(deltTime/60) > 0 then
		timeStr = math.floor(deltTime/60) .. "分钟前"
	end
	timeLab:setString(timeStr)

    -- 战斗力
    local  scoreNum = data[prefix .. "Score"] or 0
    local fightTxt  = ccui.TextBMFont:create("0", UIUtils.bmfName_zhandouli_little)
    fightTxt:setAnchorPoint(cc.p(0,0.5))
    fightTxt:setPosition(202,51)
    fightTxt:setScale(0.5)
    fightTxt:setString("a" .. scoreNum)
    item:addChild(fightTxt,99)
    fightTxt:setVisible(tonumber(scoreNum) > 0)

	local reviewBtn = item:getChildByFullName("reviewBtn")
    reviewBtn:setColor(cc.c4b(255, 255, 255, 255))
    reviewBtn:getTitleRenderer():enableOutline(cc.c4b(153, 93, 0, 178), 2)
    if data.reportKey then
    	self:registerClickEvent(reviewBtn,function( )
    		self._serverMgr:sendMsg("BattleServer","getBattleReport",{reportKey = data.reportKey},true,{},function( result )
                -- dump(data)
                -- dump(result,"result",10)
    			self:reviewTheBattle(result,data,isMeAtk,isWin)
    		end)
    	end)
    else
        reviewBtn:setEnabled(false)
        reviewBtn:setBright(false)
        UIUtils:setGray(reviewBtn,true)
    end
    -- 加战报ID
    local reportIdLab = ccui.Text:create()
    reportIdLab:setFontSize(16)
    reportIdLab:setFontName(UIUtils.ttfName)
    reportIdLab:setString("战斗ID:" .. (data.reportKey or ""))
    reportIdLab:setColor(cc.c3b(134, 92, 48))
    reportIdLab:setAnchorPoint(1,0)
    reportIdLab:setPosition(cc.p(item:getContentSize().width-20,0))
    -- reportIdLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    item:addChild(reportIdLab,10)
    item._data = data
    item._prefix = prefix
    -- 点击查看详情
    self:registerClickEvent(item,function(sender)
        local itemData = sender._data
        local itemPrefix = sender._prefix
        local rivalSec = itemData.rivalSec
        if not rivalSec then
            print("=====sec为空=====")
            return
        end
        if not itemData[prefix .. "Id"] then
            print("=====id为空=====")
            return
        end
        self._serverMgr:sendMsg("LeagueServer", "GetInfo", {id = itemData[itemPrefix .. "Id"],sec=rivalSec}, true, {}, function(result) 
            if next(result) then
                local data1 = clone(result)
                data1.isNotShowBtn = true
                data1.hScore = itemData[itemPrefix .. "Score"] or 0
                self._viewMgr:showDialog("arena.DialogArenaUserInfo",data1,true)
            end
        end)
    end)
	return item
end

function LeagueBattleReport:initBattleData( reportData )
	return BattleUtils.jsonData2lua_battleData(reportData)
end

function LeagueBattleReport:getLeagueHero( id )
    local arenaHero = tab["arenaHero"]
    for k,v in pairs(arenaHero) do
        if v.heroid == id then
            return v
        end
    end
    return arenaHero[1]
end

function LeagueBattleReport:reviewTheBattle(result,reportData,isMeAtk,isWin )
    -- dump(reportData)
	local left 
	local right 
    -- if isMeAtk then
        left  = self:initBattleData(result.atk)
        right = self:initBattleData(result.def)
    -- else
    --     left  = self:initBattleData(result.def)
    --     right = self:initBattleData(result.atk)
    -- end
    -- if result.atk.skillList then
    --     left.skillList = cjson.decode(result.atk.skillList)
    -- end
    BattleUtils.disableSRData()
	BattleUtils.enterBattleView_League(left, right, result.r1, result.r2, true,
    function (info, callback)
        -- 战斗结束
        -- arenaInfo.award = reportData.award
        -- arenaInfo.rank = reportData.rank
        -- arenaInfo.preRank = defrank
        -- if isMeAtk and isWin then
        --     local arenaInfo = {}
        --     arenaInfo.rank,arenaInfo.preRank,arenaInfo.preHRank = reportData.defRank,reportData.atkRank,reportData.atkRank
        --     info.arenaInfo = arenaInfo
        -- end
        -- if true then return end
        callback(info)
        -- self:afterArenaBattle(info)
        -- self._viewMgr:popView()
    end,
    function (info)
        -- 退出战斗
    end)
end

return LeagueBattleReport