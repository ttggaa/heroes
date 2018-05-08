--[[
    Filename:    DialogArenaReport.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-09-17 18:22:40
    Description: File description
--]]

local DialogArenaReport = class("DialogArenaReport",BasePopView)
function DialogArenaReport:ctor()
    self.super.ctor(self)

end

-- 第一次被加到父节点时候调用
function DialogArenaReport:onAdd()

end
-- 初始化UI后会调用, 有需要请覆盖
function DialogArenaReport:onInit()
	self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("arena.DialogArenaReport")
    end)
    self._title = self:getUI("bg.headBg.title")
    self._title:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._title,1)
    -- self._title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    -- self._title:setColor(cc.c3b(250, 242, 192))
    -- self._title:enable2Color(1,cc.c4b(255, 195, 20,255))
    self._tableBg = self:getUI("bg.tableBg")
    -- self._scrollViewH = self._scrollView:getContentSize().height
    self._scrollItem = self:getUI("bg.scrollItem")
    self._scrollItem:setVisible(false)
    self._itemW,self._itemH = self._scrollItem:getContentSize().width,self._scrollItem:getContentSize().height
    self:listenReflash("ArenaModel",self.reflashUI)
    self._serverMgr:sendMsg("ArenaServer","getReportList",{time = 0},true,{},function( result )
    	-- dump(result)
    end)
    self._tableData = {}
    self._noneNode = self:getUI("bg.noneNode")
    self._noneNode:setVisible(false)
    self._bg = self:getUI("bg")
    self._bg:reorderChild(self._noneNode, 9999)

    self:addTableView()

    -- 查看所有战报···
    self._okBtn = self:getUI("bg.okBtn")
    self._textFeild = self:getUI("bg.textFeild")
    if OS_IS_WINDOWS and self._okBtn then
        self._okBtn:setVisible(true)
        self._textFeild:setVisible(true)
        self._textFeild:addEventListener(function(sender, eventType)
        if eventType == 0 then
            -- event.name = "ATTACH_WITH_IME"
            self._textFeild:setPlaceHolder("")
        elseif eventType == 1 then
           --  event.name = "DETACH_WITH_IME"
           self._textFeild:setPlaceHolder("请输入战报ID！")
        elseif eventType == 2 then
            -- event.name = "INSERT_TEXT"
        elseif eventType == 3 then
            -- event.name = "DELETE_BACKWARD"
            if self._textFeild:getString() == "" then
                self._textFeild:setPlaceHolder("请输入战报ID！")
            end
        end
    end)
    -- 确定按钮
    self:registerClickEventByName("bg.okBtn", function( )
        local reportID = self._textFeild:getString()
        self._serverMgr:sendMsg("BattleServer","getBattleReport",{reportKey = reportID},true,{},function( result )
            self:reviewTheBattle(result,data,isMeAtk,isWin)
        end)
    end)
    else
        self._okBtn:setVisible(false)
        self._textFeild:setVisible(false)
    end

    --wangyan
    self:getUI("bg.shareLayer"):setVisible(false)
end

-- 接收自定义消息
function DialogArenaReport:reflashUI(data)
	local reports = self._modelMgr:getModel("ArenaModel"):getArenaReport().list
	local playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
	if playerTodayModel:getBubble().b1 and playerTodayModel:getBubble().b1 > 0 then
		playerTodayModel:updateBubble({b1=0})
	end 
    self._noneNode:setVisible(not(reports and #reports > 0))
	if reports and #reports > 0 then
        self._tableData = reports 
        if self._tableView then
            self._tableView:reloadData()
            -- print("self._tableData",#self._tableData==0,#self._tableData)           
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
end

function DialogArenaReport:addTableView( )
    local tableView = cc.TableView:create(cc.size(640, 465))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(10,10))
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

function DialogArenaReport:scrollViewDidScroll(view)
    -- print("scrollViewDidScroll")
end

function DialogArenaReport:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function DialogArenaReport:tableCellTouched(table,cell)
    -- print("cell touched at index: " .. cell:getIdx())
end

function DialogArenaReport:cellSizeForTable(table,idx) 
    return 103,638
end

function DialogArenaReport:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end

    local item = self:createItem(self._tableData[idx+1])
    item:setPosition(cc.p(0,0))
    item:setSwallowTouches(false)
    cell:addChild(item)    

    return cell
end

function DialogArenaReport:numberOfCellsInTableView(table)
   return #self._tableData
end

function DialogArenaReport:createItem( data,x,y )
    -- dump(data)
	local item = self._scrollItem:clone()
	item:setVisible(true)
    item:setAnchorPoint(cc.p(0,0))
	-- item:setPosition(cc.p(x,y))
	-- self._scrollView:addChild(item)

	local winImg = item:getChildByFullName("winImg")
	local failImg = item:getChildByFullName("failImg")
    local resultImgBg = item:getChildByFullName("resultImgBg")
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
    -- downImg:setPositionX(376)
    local drawImg = item:getChildByFullName("drawImg")
    drawImg:setVisible(false)
    -- drawImg:setPositionX(387)
    
    local atkId = data.atkId
    local defId = data.defId
    local userId = self._modelMgr:getModel("UserModel"):getUID()
    local isDef = true
    local prefix = "atk"
    local antiPrefix = "def"
    if atkId == userId then
        prefix = "def"
        antiPrefix = "atk"
    else
        prefix = "atk"
        antiPrefix = "def"
        resultImgBg:loadTexture("globalImageUI_flagBg_red.png",1)
        resultImgBg:setScale(1)
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
    -- 判断排名是否变化
    local diffRank = data.atkRank-data.defRank
    if isWin and userId == atkId then
        if diffRank > 0 then
            local diff = upImg:getChildByFullName("diff")
            diff:enableOutline(cc.c4b(42,66,16,255),1)
            diff:setFontName(UIUtils.ttfName)
            upImg:setVisible(true)
            diff:setString("+")
            -- diff:enableOutline(cc.c4b(0,78,0,255),1.1)
            local diffNum = diff:clone()
            diffNum:setString(math.abs(data.atkRank-data.defRank))
            diffNum:setPosition(cc.p(diff:getContentSize().width+2,diff:getContentSize().height/2-2))
            diffNum:enableOutline(cc.c4b(42,66,16,255),1)
            diff:addChild(diffNum,99)
        else
            drawImg:setVisible(true)
        end
    elseif not isWin and userId == defId then
        if diffRank > 0 then
            local diff = downImg:getChildByFullName("diff")
            diff:enableOutline(cc.c4b(48,13,13,255),1)
            diff:setFontName(UIUtils.ttfName)
            downImg:setVisible(true)
            diff:setString("-")
            -- diff:enableOutline(cc.c4b(0,78,0,255),1.1)
            local diffNum = diff:clone()
            diffNum:setString(math.abs(data.atkRank-data.defRank))
            diffNum:setPosition(cc.p(diff:getContentSize().width+2,diff:getContentSize().height/2-2))
            -- diff:enableOutline(cc.c4b(0,78,0,255),1.1)
            diffNum:enableOutline(cc.c4b(48,13,13,255),1)
            diff:addChild(diffNum,99)
        else
            drawImg:setVisible(true)
        end
    else
        drawImg:setVisible(true)
    end

	local lv = data[prefix .. "Lvl"]
	local name = data[prefix .. "Name"]
    self._shareMyName = data[antiPrefix .. "Name"]
    self._shareEnemyName = name
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
    local icon = IconUtils:createHeadIconById({avatar = avatar,level = lv or "0" ,tp = 4,avatarFrame=data[prefix .. "AvatarFrame"]}) 
	-- icon:loadTexture(avatarName,1)
	-- icon:setScale(0.9)
	icon:setAnchorPoint(cc.p(0,0))
    icon:setPosition(cc.p(0,-8))
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
    reviewBtn:setTitleFontSize(24)
    reviewBtn:setColor(cc.c4b(255, 255, 255, 255))
    reviewBtn:getTitleRenderer():enableOutline(cc.c4b(153, 93, 0, 178), 1)
    reviewBtn:getTitleRenderer():setAnchorPoint(0.5,1)
    UIUtils:setGray(reviewBtn,false)
    if data.reportKey then
        self:registerClickEvent(reviewBtn,function( )
            self._serverMgr:sendMsg("BattleServer","getBattleReport",{reportKey = data.reportKey},true,{},function( result )
                self:reviewTheBattle(result,data,isMeAtk,isWin)
            end)
        end)
        local shareBtn = item:getChildByFullName("shareBtn")
        shareBtn:setColor(cc.c4b(255, 255, 255, 255))
        shareBtn:getTitleRenderer():enableOutline(cc.c4b(60, 30, 10, 178), 1)
        shareBtn:setTitleFontSize(24)
        shareBtn:getTitleRenderer():setAnchorPoint(0.5,1)
        if shareBtn then
            self:registerClickEvent(shareBtn,function( )
                self:shareBtnClickEvent(shareBtn, data,isMeAtk,isWin)  --by wangyan
            end)
        end
    else
        reviewBtn:setEnabled(false)
        reviewBtn:setBright(false)
        UIUtils:setGray(reviewBtn,true)
        local shareBtn = item:getChildByFullName("shareBtn")
        if shareBtn then
            shareBtn:setEnabled(false)
            shareBtn:setBright(false)
            UIUtils:setGray(shareBtn,true)
        end
    end
    -- 加战报
    if data.reportKey and OS_IS_WINDOWS then
        local reportIdLab = ccui.Text:create()
        reportIdLab:setFontSize(16)
        reportIdLab:setFontName(UIUtils.ttfName)
        reportIdLab:setString("战斗ID:" .. data.reportKey)
        reportIdLab:setColor(cc.c3b(134, 92, 48))
        reportIdLab:setAnchorPoint(1,0)
        reportIdLab:setPosition(cc.p(item:getContentSize().width-25,0))
        -- reportIdLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        item:addChild(reportIdLab,10)
    end
    item._data = data
    item._prefix = prefix
    self:registerClickEvent(item,function(sender)
        local itemData = sender._data
        local itemPrefix = sender._prefix
        if not itemData[itemPrefix .. "Id"] then
            print("=====id为空=====")
            return
        end
        self._serverMgr:sendMsg("ArenaServer", "getDetailInfo", {roleId = itemData[itemPrefix .. "Id"] }, true, {}, function(result) 
            local info = result.info
            info.battle.msg = info.msg
            info.battle.rank = info.rank
            info.battle.hScore = itemData[itemPrefix .. "Score"] or 0
            self._viewMgr:showDialog("arena.DialogArenaUserInfo",info.battle,true)
        end)
    end)
	return item
end

--分享方式选择界面 by wangyan
function DialogArenaReport:shareBtnClickEvent(inBtn, data,isMeAtk,isWin)
    local shareLayer = self:getUI("bg.shareLayer")
    shareLayer:setVisible(true)
    self:registerClickEvent(shareLayer, function()
        shareLayer:setVisible(false)
        end)

    local bg = shareLayer:getChildByFullName("bg")
    local point1 = inBtn:convertToWorldSpace(cc.p(0, 0)) 
    point1 = shareLayer:convertToNodeSpace(point1)
    local disY = bg:getContentSize().height
    if point1.y - disY - 5 <= 10 then
        bg:setPosition(point1.x, point1.y + disY * 0.5 - 7 + inBtn:getContentSize().height)
    else
        bg:setPosition(point1.x, point1.y - disY * 0.5 - 5)
    end

    -- 竞技场战斗 世界聊天分享
    shareLayer:getChildByFullName("bg.shareBtn1.title"):enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine2, 2)
    local shareBtn1 = shareLayer:getChildByFullName("bg.shareBtn1")
    shareBtn1:getTitleRenderer():enableOutline(cc.c4b(124, 64, 0, 255), 2)
    self:registerClickEvent(shareBtn1, function()
        shareLayer:setVisible(false)
        local preShareTime = self._modelMgr:getModel("ArenaModel"):getLastShareTime()
        local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
        if nowTime - preShareTime < 300 then
            self._viewMgr:showTip(lang("REPLAY_TIP_FREQ"))
            return 
        end
        local desTxt = lang("REPLAY_ARENA")
        local enemyName = ""
        if isMeAtk then
            enemyName = data.defName 
        else
            enemyName = data.atkName
        end
        desTxt = string.gsub(desTxt,"{$enemyname}",enemyName)
        local param1 = {
            reportInfo = {
                reportKey = data.reportKey, 
                enemyName = enemyName}
        }
        local _, isInfoBanned, sendData = self._modelMgr:getModel("ChatModel"):paramHandle("replay", param1)
        if isInfoBanned == true then
            self._chatModel:pushData(sendData)
        else
            self._serverMgr:sendMsg("ChatServer", "sendMessage", sendData, true, {}, function (result)
                ViewManager:getInstance():showTip(lang("REPLAY_TIP"))
                ModelManager:getInstance():getModel("ArenaModel"):updateShareTime()
            end)  
        end
        end)

    -- 分享给好友
    local shareBtn2 = shareLayer:getChildByFullName("bg.shareBtn2")
    shareLayer:getChildByFullName("bg.shareBtn2.title"):enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine2, 2)
    if not GameStatic.appleExamine and (sdkMgr:isWX() or sdkMgr:isQQ()) then
        shareBtn2:setVisible(true)
    else
        shareBtn2:setVisible(false)
        local _bg = shareLayer:getChildByFullName("bg")
        _bg:setContentSize(_bg:getContentSize().width, 80)
        shareBtn1:setPositionY(38)
    end

    local platIcon = shareLayer:getChildByFullName("bg.shareBtn2.icon")
    if sdkMgr:isQQ() == true then
        platIcon:loadTexture("tencentIcon_qq.png", 1)
    elseif sdkMgr:isWX() == true then
        platIcon:loadTexture("tencentIcon_wx.png", 1)
    else
        -- platIcon:loadTexture("tencentIcon_qq.png", 1)
        -- shareBtn2:setVisible(false)
    end 
    
    self:registerClickEvent(shareBtn2, function()
        shareLayer:setVisible(false)

        local enemyName = ""
        if isMeAtk then
            enemyName = data.defName 
        else
            enemyName = data.atkName
        end
        local desTxt = lang("REPORTSHARE_DES1")
        local userData = self._modelMgr:getModel("UserModel"):getData()
        desTxt = string.gsub(desTxt,"{$name1}",userData["name"] or "")
        desTxt = string.gsub(desTxt,"{$name2}",enemyName)

        local param = {}
        param.message_ext = "t=1,k=".. data.reportKey ..",s=".. GameStatic.sec ..",bt=1,l=".. self._shareMyName ..",r=".. self._shareEnemyName ..""
        param.scene = 2
        param.title = lang("REPORTSHARE_TITLE1")
        param.desc  = desTxt
        param.media_tag = sdkMgr.SHARE_TAG.MSG_INVITE
        sdkMgr:sendToPlatform(param, function(code, data) 
        end)
    end)
end

function DialogArenaReport:initBattleData( reportData )
	return BattleUtils.jsonData2lua_battleData(reportData)
end

function DialogArenaReport:getArenaHero( id )
    local arenaHero = tab["arenaHero"]
    for k,v in pairs(arenaHero) do
        if v.heroid == id then
            return v
        end
    end
    return arenaHero[1]
end

function DialogArenaReport:reviewTheBattle(	result,reportData,isMeAtk,isWin )
    -- dump(reportData)
    -- dump(result, "a", 20)
	local left 
	local right 
    -- if isMeAtk then
        left  = self:initBattleData(result.atk)
        right = self:initBattleData(result.def)
    -- else
    --     left  = self:initBattleData(result.def)
    --     right = self:initBattleData(result.atk)
    -- end
    BattleUtils.disableSRData()
	BattleUtils.enterBattleView_Arena(left, right, result.r1, result.r2, 1, not isMeAtk,
    function (info, callback)
        -- 战斗结束
        -- arenaInfo.award = reportData.award
        -- arenaInfo.rank = reportData.rank
        -- arenaInfo.preRank = defrank
        if isMeAtk and isWin then
            local arenaInfo = {}
            arenaInfo.rank,arenaInfo.preRank,arenaInfo.preHRank = reportData.defRank,reportData.atkRank,reportData.atkRank
            info.arenaInfo = arenaInfo
        end
        -- if true then return end
        callback(info)
        -- self:afterArenaBattle(info)
        -- self._viewMgr:popView()
    end,
    function (info)
        -- 退出战斗
    end)
end

return DialogArenaReport